package main

import (
	"math/big"
	"testing"
)

func TestNormalizeAddress(t *testing.T) {
	address := "0xAbC1234567890DefABc1234567890DefAbC12345"
	expected := "0xabc1234567890defabc1234567890defabc12345"
	result := normalizeAddress(address)
	if result != expected {
		t.Errorf("normalizeAddress(%s) = %s; want %s", address, result, expected)
	}
}

func TestNormalizePrizeAddresses(t *testing.T) {
	prize := Prize{
		ID:              "0xAbC1234567890DefABc1234567890DefAbC12345",
		ContractAddress: "0xDef4567890abcdef1234567890abcdef12345678",
	}
	expectedID := "0xabc1234567890defabc1234567890defabc12345"
	expectedContractAddress := "0xdef4567890abcdef1234567890abcdef12345678"
	prize.normalizePrizeAddresses()
	if prize.ID != expectedID || prize.ContractAddress != expectedContractAddress {
		t.Errorf("normalizePrizeAddresses() = %s, %s; want %s, %s",
			prize.ID, prize.ContractAddress, expectedID, expectedContractAddress)
	}
}

func TestHaversine(t *testing.T) {
	lat1, lon1 := 51.4578328, -0.0360868
	lat2, lon2 := 51.4687367, -0.0399826
	expectedDistance := 1.24 // Approximate expected distance in km
	distance, _ := haversine(lat1, lon1, lat2, lon2)
	if distance < expectedDistance-0.01 || distance > expectedDistance+0.01 {
		t.Errorf("haversine(%f, %f, %f, %f) = %f; want %f",
			lat1, lon1, lat2, lon2, distance, expectedDistance)
	}
}

func TestGetDistanceAndDirection(t *testing.T) {
	lat1, lon1 := 51.4578328, -0.0360868
	lat2, lon2 := 51.4687367, -0.0399826
	expectedDistance := 1.24
	distance, _ := getDistanceAndDirection(lat1, lon1, lat2, lon2)
	if distance < expectedDistance-0.01 || distance > expectedDistance+0.01 {
		t.Errorf("getDistanceAndDirection(%f, %f, %f, %f) = %f; want %f",
			lat1, lon1, lat2, lon2, distance, expectedDistance)
	}
}

func TestIsWithinDistance(t *testing.T) {
	lat1, lon1 := 51.4578328, -0.0360868
	lat2, lon2 := 51.4687367, -0.0399826
	distance := 1.25
	if !isWithinDistance(lat1, lon1, lat2, lon2, distance) {
		t.Errorf("isWithinDistance(%f, %f, %f, %f, %f) = false; want true",
			lat1, lon1, lat2, lon2, distance)
	}
}

func TestFilterPrizeDeltas(t *testing.T) {
	userLocation := UserLocation{
		Latitude:  51.4687367,
		Longitude: -0.0399826,
	}
	prize := Prize{
		ID:              "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
		Sender:          "0xAbC1234567890DefABc1234567890DefAbC12345",
		Latitude:        51.4578328,
		Longitude:       -0.0360868,
		Password:        "mySecretPassword",
		HashedPassword:  "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890ab",
		Type:            "erc20",
		ContractAddress: "0xDef4567890abcdef1234567890abcdef12345678",
		Name:            "SampleToken",
		Symbol:          "STK",
		Amount:          big.NewInt(1000000000000000000),
		Expires:         1748864684,
		Active:          true,
	}
	prizes := []Prize{prize}
	deltas := filterPrizeDeltas(userLocation, prizes)
	if len(deltas) != 1 {
		t.Errorf("filterPrizeDeltas() = %d; want %d", len(deltas), 1)
	}
	if deltas[0].ID != prize.ID {
		t.Errorf("filterPrizeDeltas() = %s; want %s", deltas[0].ID, prize.ID)
	}
}

