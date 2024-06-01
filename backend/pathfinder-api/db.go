package main

import (
	"database/sql"
	"fmt"
	"math/big"
	"os"

	_ "github.com/lib/pq"
)

var db *sql.DB

func initDB() {
    var err error
    connStr := fmt.Sprintf("host=%s user=%s dbname=%s sslmode=%s password=%s", os.Getenv("DB_HOST"), os.Getenv("DB_USER"), os.Getenv("DB_NAME"), os.Getenv("DB_SSL_MODE"), os.Getenv("DB_PASSWORD"))
    db, err = sql.Open("postgres", connStr)
    if err != nil {
        //handle err
    }

    if err = db.Ping(); err != nil {
        //handler err
    }
}

func insertPrizeLockToDB(prize Prize) error {
    query := `
        INSERT INTO prizes (id, sender, latitude, longitude, password, hashed_password, type, contract_address, name, symbol, amount)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
    `
    _, err := db.Exec(query, prize.ID, prize.Sender, prize.Latitude, prize.Longitude, prize.Password, prize.HashedPassword,
        prize.Type, prize.ContractAddress, prize.Name, prize.Symbol, prize.Amount.String())
    return err
}

func getPrizeLocksWithinRadius(lat, lon, radius float64) ([]Prize, error) {
    rows, err := db.Query(`
        SELECT id, sender, latitude, longitude, password, hashed_password, type, contract_address, name, symbol, amount
        FROM prizes
    `)
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var prizes []Prize
    for rows.Next() {
        var prize Prize
        var amountStr string
        if err := rows.Scan(&prize.ID, &prize.Sender, &prize.Latitude, &prize.Longitude, &prize.Password, &prize.HashedPassword,
            &prize.Type, &prize.ContractAddress, &prize.Name, &prize.Symbol, &amountStr); err != nil {
            return nil, err
        }

        prize.Amount = new(big.Int)
        prize.Amount.SetString(amountStr, 10)

		distance, _ := haversine(lat, lon, prize.Latitude, prize.Longitude)

        if distance <= radius {
            prizes = append(prizes, prize)
        }
    }
    return prizes, nil
}