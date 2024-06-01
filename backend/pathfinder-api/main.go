// main.go
package main

import (
	"encoding/json"
	"log"
	"math"
	"math/big"
	"net/http"
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
}

func NormalizeAddress(address string) string {
    return strings.ToLower(address)
}

var prizes = []Prize{
    {ID: "0xblabla", Latitude: 51.46772766113281, Longitude: -0.04456249997019768, Password: "pass123", },
    {ID: "0x......", Latitude: 51.56018644177826, Longitude: -0.0705879740416937, Password: "pass456", OtherData: "test2"},
}

func getDistanceAndDirection(lat1, lon1, lat2, lon2 float64) (float64, float64) {
    const R = 6371 // Radius of the Earth in km
    dLat := (lat2 - lat1) * (math.Pi / 180)
    dLon := (lon2 - lon1) * (math.Pi / 180)
    a := math.Sin(dLat/2)*math.Sin(dLat/2) +
        math.Cos(lat1*(math.Pi/180))*math.Cos(lat2*(math.Pi/180))*
            math.Sin(dLon/2)*math.Sin(dLon/2)
    c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
    distance := R * c

    y := math.Sin(dLon) * math.Cos(lat2*(math.Pi / 180))
    x := math.Cos(lat1*(math.Pi / 180))*math.Sin(lat2*(math.Pi / 180)) -
        math.Sin(lat1*(math.Pi / 180))*math.Cos(lat2*(math.Pi / 180))*math.Cos(dLon)
    bearing := math.Atan2(y, x) * (180 / math.Pi)

    return distance, bearing
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
        ID        string  `json:"id"`
        Direction float64 `json:"direction"`
        Proximity string  `json:"proximity"`
    }

    for _, prize := range prizes {
        distance, direction := getDistanceAndDirection(userLocation.Latitude, userLocation.Longitude, prize.Latitude, prize.Longitude)
        proximity := ">10km"
        if distance <= 10 {
            proximity = "<10km"
        }
        if distance <= 8 {
            proximity = "<8km"
        }
        if distance <= 5 {
            proximity = "<5km"
        }

        deltas = append(deltas, struct {
            ID        string  `json:"id"`
            Direction float64 `json:"direction"`
            Proximity string  `json:"proximity"`
        }{
            ID:        prize.ID,
            Direction: direction,
            Proximity: proximity,
        })
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(deltas)
}

func main() {
    r := mux.NewRouter()
    r.HandleFunc("/delta", getDelta).Methods("POST")

	headersOk := handlers.AllowedHeaders([]string{"X-Requested-With", "Content-Type"})
	originsOk := handlers.AllowedOrigins([]string{"https://localhost:3000"})
	methodsOk := handlers.AllowedMethods([]string{"GET", "HEAD", "POST", "PUT", "OPTIONS"})

    log.Println("Server is running on http://localhost:3001")
    log.Fatal(http.ListenAndServe(":3001", handlers.CORS(originsOk, headersOk, methodsOk)(r)))
}
