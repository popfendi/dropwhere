// main.go
package main

import (
	"encoding/json"
	"fmt"
	"math"
	"math/big"
	"net/http"
	"os"
	"strings"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
)

type Prize struct {
    ID              string      `json:"id"` // will be keccak256(sender, nonce)
    Sender          string      `json:"sender"`
    Latitude        float64     `json:"latitude"`
    Longitude       float64     `json:"longitude"`
    Password        string      `json:"password"`
    HashedPassword  string      `json:"hashedPassword"`
    Type            string      `json:"type"`
    ContractAddress string      `json:"contractAddress"`
    Name            string      `json:"name"`
    Symbol          string      `json:"symbol"`
    Amount          *big.Int    `json:"amount"`
    Expires         int64       `json:"expires"`
    Active          bool        `json:"active"`
}

func NormalizeAddress(address string) string {
    return strings.ToLower(address)
}

func haversine(lat1, lon1, lat2, lon2 float64) (float64, float64) {
    const R = 6371 // Radius of the Earth in kilometers
    dLat := (lat2 - lat1) * (math.Pi / 180)
    dLon := (lon2 - lon1) * (math.Pi / 180)
    a := math.Sin(dLat/2)*math.Sin(dLat/2) +
        math.Cos(lat1*(math.Pi/180))*math.Cos(lat2*(math.Pi/180))*
            math.Sin(dLon/2)*math.Sin(dLon/2)
    c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
    return R * c, dLon
}

func getDistanceAndDirection(lat1, lon1, lat2, lon2 float64) (float64, float64) {
    distance, dLon := haversine(lat1, lon1, lat2, lon2)

    y := math.Sin(dLon) * math.Cos(lat2*(math.Pi / 180))
    x := math.Cos(lat1*(math.Pi / 180))*math.Sin(lat2*(math.Pi / 180)) -
        math.Sin(lat1*(math.Pi / 180))*math.Cos(lat2*(math.Pi / 180))*math.Cos(dLon)
    bearing := math.Atan2(y, x) * (180 / math.Pi)

    return distance, bearing
}

func isWithinDistance(lat1, lon1, lat2, lon2, distance float64) bool {
    r, _ := haversine(lat1, lon1, lat2, lon2)
    return r <= distance
}

func getDelta(w http.ResponseWriter, r *http.Request) {
    var userLocation struct {
        Latitude  float64 `json:"latitude"`
        Longitude float64 `json:"longitude"`
    }

    if err := json.NewDecoder(r.Body).Decode(&userLocation); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    var deltas []struct {
        ID              string      `json:"id"`
        Direction       float64     `json:"direction"`
        Proximity       string      `json:"proximity"`
        Password        string      `json:"password,omitempty"`
        HashedPassword  string      `json:"hashedPassword"`
        Type            string      `json:"type"`
        ContractAddress string      `json:"contractAddress"`
        Name            string      `json:"name"`
        Symbol          string      `json:"symbol"`
        Amount          *big.Int    `json:"amount"`
    }

    prizes, err := getPrizeLocksWithinRadius(userLocation.Latitude, userLocation.Latitude, 10) // 10km (could be configurable)
    if err != nil {
        http.Error(w, "Failed to retrieve prizes", http.StatusInternalServerError)
        return
    }

    for _, prize := range prizes {
        distance, direction := getDistanceAndDirection(userLocation.Latitude, userLocation.Longitude, prize.Latitude, prize.Longitude)
        proximity := "10km"
        switch true {
        case distance <= 10:
            proximity = "<10km"
        case distance <= 8:
            proximity = "<8km"
        case distance <= 5:
            proximity = "<5km"
        case distance <= 3:
            proximity = "<3km"
        case distance <= 1:
            proximity = "<1km"
        case distance <= .5:
            proximity = "<500m"
        case distance <= .25:
            proximity = "<250m"
        case distance <= .1:
            proximity = "<100m"
        }

        if isWithinDistance(userLocation.Latitude, userLocation.Longitude, prize.Latitude, prize.Longitude, 0.005) {
            deltas = append(deltas, struct {
                ID              string      `json:"id"`
                Direction       float64     `json:"direction"`
                Proximity       string      `json:"proximity"`
                Password        string      `json:"password,omitempty"`
                HashedPassword  string      `json:"hashedPassword"`
                Type            string      `json:"type"`
                ContractAddress string      `json:"contractAddress"`
                Name            string      `json:"name"`
                Symbol          string      `json:"symbol"`
                Amount          *big.Int    `json:"amount"`
            }{
                ID:        prize.ID,
                Direction: direction,
                Proximity: proximity,
                Password: prize.Password,
                HashedPassword: prize.HashedPassword,
                Type: prize.Type,
                ContractAddress: prize.ContractAddress,
                Name: prize.Name,
                Symbol: prize.Symbol,
                Amount: prize.Amount,
            })
        } else {
            deltas = append(deltas, struct {
                ID              string      `json:"id"`
                Direction       float64     `json:"direction"`
                Proximity       string      `json:"proximity"`
                Password        string      `json:"password,omitempty"`
                HashedPassword  string      `json:"hashedPassword"`
                Type            string      `json:"type"`
                ContractAddress string      `json:"contractAddress"`
                Name            string      `json:"name"`
                Symbol          string      `json:"symbol"`
                Amount          *big.Int    `json:"amount"`
            }{
                ID:        prize.ID,
                Direction: direction,
                Proximity: proximity,
                HashedPassword: prize.HashedPassword,
                Type: prize.Type,
                ContractAddress: prize.ContractAddress,
                Name: prize.Name,
                Symbol: prize.Symbol,
                Amount: prize.Amount,
            })
        }

    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(deltas)
}

func storePrizeLockHandler(w http.ResponseWriter, r *http.Request) {
    var prize Prize
    if err := json.NewDecoder(r.Body).Decode(&prize); err != nil {
        http.Error(w, "Invalid request payload", http.StatusBadRequest)
        return
    }

    if err := insertPrizeLockToDB(prize); err != nil {
        http.Error(w, "Failed to store prize", http.StatusInternalServerError)
        return
    }

    w.WriteHeader(http.StatusCreated)
    w.Write([]byte("Prize stored successfully"))
}

func main() {
    initLogger()
    initDB()
    port := os.Getenv("SERVER_PORT")
    allowedHost := os.Getenv("ALLOWED_HOST")
    r := mux.NewRouter()
    r.HandleFunc("/delta", getDelta).Methods("POST")
    r.HandleFunc("/prizes", storePrizeLockHandler).Methods("POST")

	headersOk := handlers.AllowedHeaders([]string{"X-Requested-With", "Content-Type"})
	originsOk := handlers.AllowedOrigins([]string{allowedHost})
	methodsOk := handlers.AllowedMethods([]string{"GET", "HEAD", "POST", "PUT", "OPTIONS"})

    Sugar.Infof("Server is running on port %s", port)
    Sugar.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), handlers.CORS(originsOk, headersOk, methodsOk)(r)))
}
