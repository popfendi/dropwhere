package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"math"
	"math/big"
	"net/http"
	"os"
	"strconv"
	"strings"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
)

type Prize struct {
    ID              string      `json:"id,omitempty"` // will be keccak256(sender, nonce)
    Sender          string      `json:"sender"`
    Latitude        float64     `json:"latitude"`
    Longitude       float64     `json:"longitude"`
    Password        string      `json:"password,omitempty"`
    HashedPassword  string      `json:"hashedPassword,omitempty"`
    Type            string      `json:"type"`
    ContractAddress string      `json:"contractAddress"`
    Name            string      `json:"name,omitempty"`
    Symbol          string      `json:"symbol,omitempty"`
    Amount          *big.Int    `json:"amount,omitempty"`
    Expires         int64       `json:"expires"`
    Active          bool        `json:"active,omitempty"`
}

type Message struct {
    ID              int64       `json:"id,omitempty"`
    Sender          string      `json:"sender"`
    Text            []int16     `json:"text"`
    Latitude        float64     `json:"latitude"`
    Longitude       float64     `json:"longitude"`
    Expires         int64       `json:"expires,omitempty"`
    Active          bool        `json:"active,omitempty"`
}

func normalizeAddress(address string) string {
    return strings.ToLower(address)
}

func (p *Prize) normalizePrizeAddresses(){
    p.ID = normalizeAddress(p.ID)
    p.ContractAddress = normalizeAddress(p.ContractAddress)
}

func (p *Prize) UnmarshalJSON(data []byte) error {
	type Alias Prize 

	aux := &struct {
		Amount string `json:"amount"` 
		*Alias
	}{
		Alias: (*Alias)(p),
	}

	if err := json.Unmarshal(data, &aux); err != nil {
		return err
	}

	if aux.Amount != "" {
		p.Amount = new(big.Int)
		_, ok := p.Amount.SetString(aux.Amount, 10)
		if !ok {
			return fmt.Errorf("invalid big.Int string: %s", aux.Amount)
		}
	}

	return nil
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

type Delta struct {
    ID              string      `json:"id"`
    Direction       float64     `json:"direction"`
    Proximity       string      `json:"proximity"`
    Sender          string      `json:"sender"`
    Password        string      `json:"password,omitempty"`
    Message         []int8      `json:"message,omitempty"`
    HashedPassword  string      `json:"hashedPassword,omitempty"`
    Type            string      `json:"type"`
    ContractAddress string      `json:"contractAddress"`
    Name            string      `json:"name,omitempty"`
    Symbol          string      `json:"symbol,omitempty"`
    Amount          *big.Int    `json:"amount,omitempty"`
    Text            []int16     `json:"text,omitempty"`
} 

type UserLocation struct {
    Latitude  float64 `json:"latitude"`
    Longitude float64 `json:"longitude"`
}

func filterPrizeDeltas(userLocation UserLocation, prizes []Prize) []Delta{
    var deltas []Delta

    for _, prize := range prizes {
        distance, direction := getDistanceAndDirection(userLocation.Latitude, userLocation.Longitude, prize.Latitude, prize.Longitude)
        proximity := "10km"
        switch true {
        case distance <= 0.01:
            proximity = "<10m"
        case distance <= 0.1:
            proximity = "<100m"
        case distance <= 0.25:
            proximity = "<250m"
        case distance <= 0.5:
            proximity = "<500m"
        case distance <= 1:
            proximity = "<1km"
        case distance <= 3:
            proximity = "<3km"
        case distance <= 5:
            proximity = "<5km"
        case distance <= 8:
            proximity = "<8km"
        case distance <= 10:
            proximity = "<10km"
        }

        if isWithinDistance(userLocation.Latitude, userLocation.Longitude, prize.Latitude, prize.Longitude, 0.01) {
            deltas = append(deltas, Delta{
                ID:        prize.ID,
                Direction: direction,
                Proximity: proximity,
                Password: prize.Password,
                HashedPassword: prize.HashedPassword,
                Sender: prize.Sender,
                Type: prize.Type,
                ContractAddress: prize.ContractAddress,
                Name: prize.Name,
                Symbol: prize.Symbol,
                Amount: prize.Amount,
            })
        } else {
            deltas = append(deltas, Delta{
                ID:        prize.ID,
                Direction: direction,
                Proximity: proximity,
                HashedPassword: prize.HashedPassword,
                Sender: prize.Sender,
                Type: prize.Type,
                ContractAddress: prize.ContractAddress,
                Name: prize.Name,
                Symbol: prize.Symbol,
                Amount: prize.Amount,
            })
        }

    }
    return deltas
}

func filterMessages(userLocation UserLocation, messages []Message) []Delta{
    var deltas []Delta

    for _, message := range messages {
        distance, direction := getDistanceAndDirection(userLocation.Latitude, userLocation.Longitude, message.Latitude, message.Longitude)
        proximity := "10km"
        switch true {
        case distance <= 0.01:
            proximity = "<10m"
        case distance <= 0.1:
            proximity = "<100m"
        case distance <= 0.25:
            proximity = "<250m"
        case distance <= 0.5:
            proximity = "<500m"
        case distance <= 1:
            proximity = "<1km"
        case distance <= 3:
            proximity = "<3km"
        case distance <= 5:
            proximity = "<5km"
        case distance <= 8:
            proximity = "<8km"
        case distance <= 10:
            proximity = "<10km"
        }

        deltas = append(deltas, Delta{
            ID:        strconv.Itoa(int(message.ID)),
            Direction: direction,
            Proximity: proximity,
            Type: "message",
            ContractAddress: message.Sender,
            Text: message.Text,
        })

    }
    
    return deltas
}


func getDelta(w http.ResponseWriter, r *http.Request) {
    var userLocation UserLocation

    if err := json.NewDecoder(r.Body).Decode(&userLocation); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        Sugar.Error(err)
        return
    }


    prizes, err := getPrizeLocksWithinRadius(userLocation.Latitude, userLocation.Longitude, 10) // 10km (could be configurable)
    if err != nil {
        http.Error(w, "Failed to retrieve prize deltas", http.StatusInternalServerError)
        Sugar.Error(err)
        return
    }

   prizeDeltas := filterPrizeDeltas(userLocation, prizes)

   messages, err := getMessagesWithinRadius(userLocation.Latitude, userLocation.Longitude, 8) //8km for messages
    if err != nil {
        http.Error(w, "Failed to retrieve message deltas", http.StatusInternalServerError)
        Sugar.Error(err)
        return
    }

    messageDeltas := filterMessages(userLocation, messages)

    deltas := append(prizeDeltas, messageDeltas...)

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(deltas)
}

func storePrizeLockHandler(w http.ResponseWriter, r *http.Request) {
    var prize Prize
    if err := json.NewDecoder(r.Body).Decode(&prize); err != nil {
        http.Error(w, "Invalid request payload", http.StatusBadRequest)
        Sugar.Error(err)
        return
    }

    prize.normalizePrizeAddresses()
    prize.Active = false

    if err := upsertPrizeLockToDB(prize); err != nil {
        http.Error(w, "Failed to store prize", http.StatusInternalServerError)
        Sugar.Error(err)
        return
    }

    w.WriteHeader(http.StatusCreated)
    w.Write([]byte("Prize stored successfully"))
}

type MessageInput struct {
    Message     Message     `json:"message"`
    Signature   string      `json:"signature"`
}

type VerifyResponse struct {
	Success bool   `json:"success"`
	Error   string `json:"error,omitempty"`
}

func verifySig(msgInput MessageInput) (bool, error) {
    msg := fmt.Sprintf("%s%.3f%.3f", msgInput.Message.Sender, msgInput.Message.Latitude, msgInput.Message.Longitude)

	reqBody := struct{
        Address string `json:"address"`
        Message string `json:"message"`
        Signature string `json:"signature"`
        }{
		Address:   msgInput.Message.Sender,
		Message:   msg,
		Signature: msgInput.Signature,
	}

	jsonReqBody, err := json.Marshal(reqBody)
	if err != nil {
		return false, err
	}

	resp, err := http.Post(fmt.Sprintf("%s/verify", os.Getenv("SIG_VERIFY_HOST")), "application/json", bytes.NewBuffer(jsonReqBody))
	if err != nil {
		return false, err
	}
	defer resp.Body.Close()

	var verifyResp VerifyResponse
	err = json.NewDecoder(resp.Body).Decode(&verifyResp)
	if err != nil {
		return false, err
	}

	if verifyResp.Success {
		return true, nil
	} else {
		return false, nil
	}

}

func storeMessageHandler(w http.ResponseWriter, r *http.Request) {
    var msgInput MessageInput
    if err := json.NewDecoder(r.Body).Decode(&msgInput); err != nil {
        http.Error(w, "Invalid request payload", http.StatusBadRequest)
        Sugar.Error(err)
        return
    }
    
    if msgInput.Signature == "" {
        http.Error(w, "Signature can't be empty", http.StatusBadRequest)
        return
    }

    verifyResult, err := verifySig(msgInput) 
    if err != nil {
        http.Error(w, "Invalid signature", http.StatusBadRequest)
        Sugar.Error(err)
        return
    }

    if !verifyResult {
        http.Error(w, "Signature must be signed by sender", http.StatusBadRequest)
        Sugar.Error(err)
        return
    }

    msgInput.Message.Sender = normalizeAddress(msgInput.Message.Sender)

    id, err := insertMessageToDB(msgInput.Message)
    if err != nil {
        http.Error(w, "Insert Message error", http.StatusInternalServerError)
        Sugar.Error(err)
        return
    }

    w.WriteHeader(http.StatusCreated)
    w.Write([]byte(fmt.Sprintf("id: %d", id)))
}

func main() {
    initLogger()
    initDB()
    initClient()
    port := os.Getenv("SERVER_PORT")
    allowedHosts := os.Getenv("ALLOWED_HOSTS")
    origins := strings.Split(allowedHosts, ",")
    r := mux.NewRouter()
    r.HandleFunc("/delta", getDelta).Methods("POST")
    r.HandleFunc("/prizes", storePrizeLockHandler).Methods("POST")
    r.HandleFunc("/messages", storeMessageHandler).Methods("POST")

	headersOk := handlers.AllowedHeaders([]string{"X-Requested-With", "Content-Type"})
	originsOk := handlers.AllowedOrigins(origins)
	methodsOk := handlers.AllowedMethods([]string{"GET", "HEAD", "POST", "PUT", "OPTIONS"})

    go listenForLocks()
    go listenForUnlocks()

    Sugar.Infof("Server is running on port %s", port)
    Sugar.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), handlers.CORS(originsOk, headersOk, methodsOk)(r)))
}
