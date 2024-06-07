package main

import (
	"database/sql"
	"fmt"
	"math/big"
	"os"
	"time"

	"github.com/lib/pq"
	_ "github.com/lib/pq"
)

var db *sql.DB

func initDB() {
    var err error
    connStr := fmt.Sprintf("host=%s user=%s dbname=%s sslmode=%s password=%s", os.Getenv("DB_HOST"), os.Getenv("DB_USER"), os.Getenv("DB_NAME"), os.Getenv("DB_SSL_MODE"), os.Getenv("DB_PASSWORD"))
    db, err = sql.Open("postgres", connStr)
    if err != nil {
        Sugar.Fatalf("DB ERROR: %s", err.Error())
    }

    if err = db.Ping(); err != nil {
        Sugar.Fatalf("DB ERROR: %s", err.Error())
    }

    initQuery := `
    CREATE TABLE IF NOT EXISTS messages (
        id SERIAL PRIMARY KEY,
        sender TEXT,
        text SMALLINT[],
        latitude FLOAT8,
        longitude FLOAT8,
        expires BIGINT,
        active BOOLEAN
    );

    CREATE TABLE IF NOT EXISTS prizes (
        id TEXT PRIMARY KEY,
        sender TEXT,
        latitude DOUBLE PRECISION,
        longitude DOUBLE PRECISION,
        password TEXT,
        hashed_password TEXT,
        type TEXT,
        contract_address TEXT,
        name TEXT,
        symbol TEXT,
        amount NUMERIC,
        expires BIGINT,
        active BOOLEAN
    );
    `

    _, err = db.Exec(initQuery)
    if err != nil {
        Sugar.Error(err)
    }
}

func insertPrizeLockToDB(prize Prize) error {
    query := `
    INSERT INTO prizes (id, sender, latitude, longitude, password, hashed_password, type, contract_address, name, symbol, amount, expires, active)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
`
    amountStr := prize.Amount.String()
    _, err := db.Exec(query, prize.ID, prize.Sender, prize.Latitude, prize.Longitude, prize.Password, prize.HashedPassword,
        prize.Type, prize.ContractAddress, prize.Name, prize.Symbol, amountStr, prize.Expires, prize.Active)
    return err
}

func getPrizeLocksWithinRadius(lat, lon, radius float64) ([]Prize, error) {
    rows, err := db.Query(`
        SELECT id, sender, latitude, longitude, password, hashed_password, type, contract_address, name, symbol, amount, expires, active
        FROM prizes
        WHERE active = TRUE AND expires > $1
    `, time.Now().Unix())
    if err != nil {
        return nil, err
    }
    defer rows.Close()

    var prizes []Prize
    for rows.Next() {
        var prize Prize
        var amountStr string
        if err := rows.Scan(&prize.ID, &prize.Sender, &prize.Latitude, &prize.Longitude, &prize.Password, &prize.HashedPassword,
            &prize.Type, &prize.ContractAddress, &prize.Name, &prize.Symbol, &amountStr, &prize.Expires, &prize.Active); err != nil {
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

func insertMessageToDB(msg Message) (int64, error) {
    msg.Active = true
    msg.Expires = time.Now().Unix() + 86400

    query := `
    INSERT INTO messages (sender, text, latitude, longitude, expires, active)
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING id
    `

    var id int64
    err := db.QueryRow(query, msg.Sender, pq.Array(msg.Text), msg.Latitude, msg.Longitude, msg.Expires, msg.Active).Scan(&id)
    if err != nil {
        return 0, err
    }

    msg.ID = id
    fmt.Printf("Inserted message with ID: %d\n", id)
    return id, nil
}