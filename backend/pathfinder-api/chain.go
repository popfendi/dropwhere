package main

import (
	"fmt"
	"os"
	"pathfinder-api/contracts/dropmanager"
	"strings"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
)

var client *ethclient.Client
var dmContract *dropmanager.Dropmanager

func initClient() error {
	c, err := ethclient.Dial(os.Getenv("WS_NODE"))
	if err != nil {
		return err
	}
	
	client = c
	
	ca := common.HexToAddress(os.Getenv("DM_CA"))
	dm, err := dropmanager.NewDropmanager(ca, client)
	if err != nil {
		return err
	}

	dmContract = dm
	return err
}

func listenForLocks() {
	sink := make(chan *dropmanager.DropmanagerDropAdded)
	sub, err := dmContract.WatchDropAdded(nil, sink, nil, nil)
	if err != nil {
		Sugar.Fatal(err)
	}

	delay := time.Second * 10

	for {
		select {
		case err := <-sub.Err():
			if err != nil {
				Sugar.Error(err)
				if os.IsTimeout(err) {
					sub.Unsubscribe()
					listenForLocks()
				}
			}
		case log := <-sink:
			sender := strings.ToLower(log.Sender.Hex())
			id := fmt.Sprintf("0x%v", log.Id)
			err := updatePrizeLockFields(log.PrizeType, sender, id, log.Amount, true)
			if err != nil {
				Sugar.Error(err)
			}
		}
		time.Sleep(delay) // delay so it's not so resource intensive
	}
}

func listenForUnlocks() {
	sink := make(chan *dropmanager.DropmanagerDropUnlocked)
	sub, err := dmContract.WatchDropUnlocked(nil, sink, nil, nil, nil)
	if err != nil {
		Sugar.Fatal(err)
	}

	delay := time.Second * 10

	for {
		select {
		case err := <-sub.Err():
			if err != nil {
				Sugar.Error(err)
				if os.IsTimeout(err) {
					sub.Unsubscribe()
					listenForLocks()
				}
			}
		case log := <-sink:
			sender := strings.ToLower(log.Sender.Hex())
			id := fmt.Sprintf("0x%v", log.Id)
			err := updatePrizeLockFields(log.PrizeType, sender, id, log.Amount, false)
			if err != nil {
				Sugar.Error(err)
			}
		}
		time.Sleep(delay) // delay so it's not so resource intensive
	}
}