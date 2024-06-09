// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package dropmanager

import (
	"errors"
	"math/big"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
	_ = abi.ConvertType
)

// DropManagerProofData is an auto generated low-level Go binding around an user-defined struct.
type DropManagerProofData struct {
	A0  [32]byte
	A1  [32]byte
	B00 [32]byte
	B01 [32]byte
	B10 [32]byte
	B11 [32]byte
	C0  [32]byte
	C1  [32]byte
}

// DropmanagerMetaData contains all meta data concerning the Dropmanager contract.
var DropmanagerMetaData = &bind.MetaData{
	ABI: "[{\"type\":\"constructor\",\"inputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"createDropLockERC20\",\"inputs\":[{\"name\":\"hashedPassword\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"contractAddress\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"expiry\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"createDropLockERC721\",\"inputs\":[{\"name\":\"hashedPassword\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"contractAddress\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"tokenId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"expiry\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"createDropLockETH\",\"inputs\":[{\"name\":\"hashedPassword\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"expiry\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[],\"stateMutability\":\"payable\"},{\"type\":\"function\",\"name\":\"drops\",\"inputs\":[{\"name\":\"\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"}],\"outputs\":[{\"name\":\"sender\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"hashedPassword\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"prizeType\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"contractAddress\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"expiry\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"getDropLockById\",\"inputs\":[{\"name\":\"id\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"}],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"\",\"type\":\"string\",\"internalType\":\"string\"},{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"onERC721Received\",\"inputs\":[{\"name\":\"operator\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"from\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"tokenId\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[{\"name\":\"\",\"type\":\"bytes4\",\"internalType\":\"bytes4\"}],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"unlockDrop\",\"inputs\":[{\"name\":\"proof\",\"type\":\"tuple\",\"internalType\":\"structDropManager.ProofData\",\"components\":[{\"name\":\"a0\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"a1\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"b00\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"b01\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"b10\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"b11\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"c0\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"c1\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"}]},{\"name\":\"lockId\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"},{\"name\":\"unlockHash\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"unlockExpiredLock\",\"inputs\":[{\"name\":\"lockId\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"userNonces\",\"inputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"verifier\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"contractVerifier\"}],\"stateMutability\":\"view\"},{\"type\":\"event\",\"name\":\"DropAdded\",\"inputs\":[{\"name\":\"id\",\"type\":\"bytes32\",\"indexed\":true,\"internalType\":\"bytes32\"},{\"name\":\"sender\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"hashedPassword\",\"type\":\"bytes32\",\"indexed\":false,\"internalType\":\"bytes32\"},{\"name\":\"prizeType\",\"type\":\"string\",\"indexed\":false,\"internalType\":\"string\"},{\"name\":\"contractAddress\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"expiry\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"DropUnlocked\",\"inputs\":[{\"name\":\"id\",\"type\":\"bytes32\",\"indexed\":true,\"internalType\":\"bytes32\"},{\"name\":\"sender\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"reciever\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"hashedPassword\",\"type\":\"bytes32\",\"indexed\":false,\"internalType\":\"bytes32\"},{\"name\":\"prizeType\",\"type\":\"string\",\"indexed\":false,\"internalType\":\"string\"},{\"name\":\"contractAddress\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"expiry\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"}],\"anonymous\":false}]",
}

// DropmanagerABI is the input ABI used to generate the binding from.
// Deprecated: Use DropmanagerMetaData.ABI instead.
var DropmanagerABI = DropmanagerMetaData.ABI

// Dropmanager is an auto generated Go binding around an Ethereum contract.
type Dropmanager struct {
	DropmanagerCaller     // Read-only binding to the contract
	DropmanagerTransactor // Write-only binding to the contract
	DropmanagerFilterer   // Log filterer for contract events
}

// DropmanagerCaller is an auto generated read-only Go binding around an Ethereum contract.
type DropmanagerCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// DropmanagerTransactor is an auto generated write-only Go binding around an Ethereum contract.
type DropmanagerTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// DropmanagerFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type DropmanagerFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// DropmanagerSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type DropmanagerSession struct {
	Contract     *Dropmanager      // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// DropmanagerCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type DropmanagerCallerSession struct {
	Contract *DropmanagerCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts      // Call options to use throughout this session
}

// DropmanagerTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type DropmanagerTransactorSession struct {
	Contract     *DropmanagerTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts      // Transaction auth options to use throughout this session
}

// DropmanagerRaw is an auto generated low-level Go binding around an Ethereum contract.
type DropmanagerRaw struct {
	Contract *Dropmanager // Generic contract binding to access the raw methods on
}

// DropmanagerCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type DropmanagerCallerRaw struct {
	Contract *DropmanagerCaller // Generic read-only contract binding to access the raw methods on
}

// DropmanagerTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type DropmanagerTransactorRaw struct {
	Contract *DropmanagerTransactor // Generic write-only contract binding to access the raw methods on
}

// NewDropmanager creates a new instance of Dropmanager, bound to a specific deployed contract.
func NewDropmanager(address common.Address, backend bind.ContractBackend) (*Dropmanager, error) {
	contract, err := bindDropmanager(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &Dropmanager{DropmanagerCaller: DropmanagerCaller{contract: contract}, DropmanagerTransactor: DropmanagerTransactor{contract: contract}, DropmanagerFilterer: DropmanagerFilterer{contract: contract}}, nil
}

// NewDropmanagerCaller creates a new read-only instance of Dropmanager, bound to a specific deployed contract.
func NewDropmanagerCaller(address common.Address, caller bind.ContractCaller) (*DropmanagerCaller, error) {
	contract, err := bindDropmanager(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &DropmanagerCaller{contract: contract}, nil
}

// NewDropmanagerTransactor creates a new write-only instance of Dropmanager, bound to a specific deployed contract.
func NewDropmanagerTransactor(address common.Address, transactor bind.ContractTransactor) (*DropmanagerTransactor, error) {
	contract, err := bindDropmanager(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &DropmanagerTransactor{contract: contract}, nil
}

// NewDropmanagerFilterer creates a new log filterer instance of Dropmanager, bound to a specific deployed contract.
func NewDropmanagerFilterer(address common.Address, filterer bind.ContractFilterer) (*DropmanagerFilterer, error) {
	contract, err := bindDropmanager(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &DropmanagerFilterer{contract: contract}, nil
}

// bindDropmanager binds a generic wrapper to an already deployed contract.
func bindDropmanager(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := DropmanagerMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Dropmanager *DropmanagerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Dropmanager.Contract.DropmanagerCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Dropmanager *DropmanagerRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Dropmanager.Contract.DropmanagerTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Dropmanager *DropmanagerRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Dropmanager.Contract.DropmanagerTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Dropmanager *DropmanagerCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Dropmanager.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Dropmanager *DropmanagerTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Dropmanager.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Dropmanager *DropmanagerTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Dropmanager.Contract.contract.Transact(opts, method, params...)
}

// Drops is a free data retrieval call binding the contract method 0x49af2001.
//
// Solidity: function drops(bytes32 ) view returns(address sender, bytes32 hashedPassword, string prizeType, address contractAddress, uint256 amount, uint256 expiry)
func (_Dropmanager *DropmanagerCaller) Drops(opts *bind.CallOpts, arg0 [32]byte) (struct {
	Sender          common.Address
	HashedPassword  [32]byte
	PrizeType       string
	ContractAddress common.Address
	Amount          *big.Int
	Expiry          *big.Int
}, error) {
	var out []interface{}
	err := _Dropmanager.contract.Call(opts, &out, "drops", arg0)

	outstruct := new(struct {
		Sender          common.Address
		HashedPassword  [32]byte
		PrizeType       string
		ContractAddress common.Address
		Amount          *big.Int
		Expiry          *big.Int
	})
	if err != nil {
		return *outstruct, err
	}

	outstruct.Sender = *abi.ConvertType(out[0], new(common.Address)).(*common.Address)
	outstruct.HashedPassword = *abi.ConvertType(out[1], new([32]byte)).(*[32]byte)
	outstruct.PrizeType = *abi.ConvertType(out[2], new(string)).(*string)
	outstruct.ContractAddress = *abi.ConvertType(out[3], new(common.Address)).(*common.Address)
	outstruct.Amount = *abi.ConvertType(out[4], new(*big.Int)).(**big.Int)
	outstruct.Expiry = *abi.ConvertType(out[5], new(*big.Int)).(**big.Int)

	return *outstruct, err

}

// Drops is a free data retrieval call binding the contract method 0x49af2001.
//
// Solidity: function drops(bytes32 ) view returns(address sender, bytes32 hashedPassword, string prizeType, address contractAddress, uint256 amount, uint256 expiry)
func (_Dropmanager *DropmanagerSession) Drops(arg0 [32]byte) (struct {
	Sender          common.Address
	HashedPassword  [32]byte
	PrizeType       string
	ContractAddress common.Address
	Amount          *big.Int
	Expiry          *big.Int
}, error) {
	return _Dropmanager.Contract.Drops(&_Dropmanager.CallOpts, arg0)
}

// Drops is a free data retrieval call binding the contract method 0x49af2001.
//
// Solidity: function drops(bytes32 ) view returns(address sender, bytes32 hashedPassword, string prizeType, address contractAddress, uint256 amount, uint256 expiry)
func (_Dropmanager *DropmanagerCallerSession) Drops(arg0 [32]byte) (struct {
	Sender          common.Address
	HashedPassword  [32]byte
	PrizeType       string
	ContractAddress common.Address
	Amount          *big.Int
	Expiry          *big.Int
}, error) {
	return _Dropmanager.Contract.Drops(&_Dropmanager.CallOpts, arg0)
}

// GetDropLockById is a free data retrieval call binding the contract method 0x92405464.
//
// Solidity: function getDropLockById(bytes32 id) view returns(address, bytes32, string, address, uint256, uint256)
func (_Dropmanager *DropmanagerCaller) GetDropLockById(opts *bind.CallOpts, id [32]byte) (common.Address, [32]byte, string, common.Address, *big.Int, *big.Int, error) {
	var out []interface{}
	err := _Dropmanager.contract.Call(opts, &out, "getDropLockById", id)

	if err != nil {
		return *new(common.Address), *new([32]byte), *new(string), *new(common.Address), *new(*big.Int), *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)
	out1 := *abi.ConvertType(out[1], new([32]byte)).(*[32]byte)
	out2 := *abi.ConvertType(out[2], new(string)).(*string)
	out3 := *abi.ConvertType(out[3], new(common.Address)).(*common.Address)
	out4 := *abi.ConvertType(out[4], new(*big.Int)).(**big.Int)
	out5 := *abi.ConvertType(out[5], new(*big.Int)).(**big.Int)

	return out0, out1, out2, out3, out4, out5, err

}

// GetDropLockById is a free data retrieval call binding the contract method 0x92405464.
//
// Solidity: function getDropLockById(bytes32 id) view returns(address, bytes32, string, address, uint256, uint256)
func (_Dropmanager *DropmanagerSession) GetDropLockById(id [32]byte) (common.Address, [32]byte, string, common.Address, *big.Int, *big.Int, error) {
	return _Dropmanager.Contract.GetDropLockById(&_Dropmanager.CallOpts, id)
}

// GetDropLockById is a free data retrieval call binding the contract method 0x92405464.
//
// Solidity: function getDropLockById(bytes32 id) view returns(address, bytes32, string, address, uint256, uint256)
func (_Dropmanager *DropmanagerCallerSession) GetDropLockById(id [32]byte) (common.Address, [32]byte, string, common.Address, *big.Int, *big.Int, error) {
	return _Dropmanager.Contract.GetDropLockById(&_Dropmanager.CallOpts, id)
}

// UserNonces is a free data retrieval call binding the contract method 0x2f7801f4.
//
// Solidity: function userNonces(address ) view returns(uint256)
func (_Dropmanager *DropmanagerCaller) UserNonces(opts *bind.CallOpts, arg0 common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Dropmanager.contract.Call(opts, &out, "userNonces", arg0)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// UserNonces is a free data retrieval call binding the contract method 0x2f7801f4.
//
// Solidity: function userNonces(address ) view returns(uint256)
func (_Dropmanager *DropmanagerSession) UserNonces(arg0 common.Address) (*big.Int, error) {
	return _Dropmanager.Contract.UserNonces(&_Dropmanager.CallOpts, arg0)
}

// UserNonces is a free data retrieval call binding the contract method 0x2f7801f4.
//
// Solidity: function userNonces(address ) view returns(uint256)
func (_Dropmanager *DropmanagerCallerSession) UserNonces(arg0 common.Address) (*big.Int, error) {
	return _Dropmanager.Contract.UserNonces(&_Dropmanager.CallOpts, arg0)
}

// Verifier is a free data retrieval call binding the contract method 0x2b7ac3f3.
//
// Solidity: function verifier() view returns(address)
func (_Dropmanager *DropmanagerCaller) Verifier(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _Dropmanager.contract.Call(opts, &out, "verifier")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Verifier is a free data retrieval call binding the contract method 0x2b7ac3f3.
//
// Solidity: function verifier() view returns(address)
func (_Dropmanager *DropmanagerSession) Verifier() (common.Address, error) {
	return _Dropmanager.Contract.Verifier(&_Dropmanager.CallOpts)
}

// Verifier is a free data retrieval call binding the contract method 0x2b7ac3f3.
//
// Solidity: function verifier() view returns(address)
func (_Dropmanager *DropmanagerCallerSession) Verifier() (common.Address, error) {
	return _Dropmanager.Contract.Verifier(&_Dropmanager.CallOpts)
}

// CreateDropLockERC20 is a paid mutator transaction binding the contract method 0xee087e76.
//
// Solidity: function createDropLockERC20(bytes32 hashedPassword, address contractAddress, uint256 amount, uint256 expiry) returns()
func (_Dropmanager *DropmanagerTransactor) CreateDropLockERC20(opts *bind.TransactOpts, hashedPassword [32]byte, contractAddress common.Address, amount *big.Int, expiry *big.Int) (*types.Transaction, error) {
	return _Dropmanager.contract.Transact(opts, "createDropLockERC20", hashedPassword, contractAddress, amount, expiry)
}

// CreateDropLockERC20 is a paid mutator transaction binding the contract method 0xee087e76.
//
// Solidity: function createDropLockERC20(bytes32 hashedPassword, address contractAddress, uint256 amount, uint256 expiry) returns()
func (_Dropmanager *DropmanagerSession) CreateDropLockERC20(hashedPassword [32]byte, contractAddress common.Address, amount *big.Int, expiry *big.Int) (*types.Transaction, error) {
	return _Dropmanager.Contract.CreateDropLockERC20(&_Dropmanager.TransactOpts, hashedPassword, contractAddress, amount, expiry)
}

// CreateDropLockERC20 is a paid mutator transaction binding the contract method 0xee087e76.
//
// Solidity: function createDropLockERC20(bytes32 hashedPassword, address contractAddress, uint256 amount, uint256 expiry) returns()
func (_Dropmanager *DropmanagerTransactorSession) CreateDropLockERC20(hashedPassword [32]byte, contractAddress common.Address, amount *big.Int, expiry *big.Int) (*types.Transaction, error) {
	return _Dropmanager.Contract.CreateDropLockERC20(&_Dropmanager.TransactOpts, hashedPassword, contractAddress, amount, expiry)
}

// CreateDropLockERC721 is a paid mutator transaction binding the contract method 0x05de4c18.
//
// Solidity: function createDropLockERC721(bytes32 hashedPassword, address contractAddress, uint256 tokenId, uint256 expiry) returns()
func (_Dropmanager *DropmanagerTransactor) CreateDropLockERC721(opts *bind.TransactOpts, hashedPassword [32]byte, contractAddress common.Address, tokenId *big.Int, expiry *big.Int) (*types.Transaction, error) {
	return _Dropmanager.contract.Transact(opts, "createDropLockERC721", hashedPassword, contractAddress, tokenId, expiry)
}

// CreateDropLockERC721 is a paid mutator transaction binding the contract method 0x05de4c18.
//
// Solidity: function createDropLockERC721(bytes32 hashedPassword, address contractAddress, uint256 tokenId, uint256 expiry) returns()
func (_Dropmanager *DropmanagerSession) CreateDropLockERC721(hashedPassword [32]byte, contractAddress common.Address, tokenId *big.Int, expiry *big.Int) (*types.Transaction, error) {
	return _Dropmanager.Contract.CreateDropLockERC721(&_Dropmanager.TransactOpts, hashedPassword, contractAddress, tokenId, expiry)
}

// CreateDropLockERC721 is a paid mutator transaction binding the contract method 0x05de4c18.
//
// Solidity: function createDropLockERC721(bytes32 hashedPassword, address contractAddress, uint256 tokenId, uint256 expiry) returns()
func (_Dropmanager *DropmanagerTransactorSession) CreateDropLockERC721(hashedPassword [32]byte, contractAddress common.Address, tokenId *big.Int, expiry *big.Int) (*types.Transaction, error) {
	return _Dropmanager.Contract.CreateDropLockERC721(&_Dropmanager.TransactOpts, hashedPassword, contractAddress, tokenId, expiry)
}

// CreateDropLockETH is a paid mutator transaction binding the contract method 0xa512c06a.
//
// Solidity: function createDropLockETH(bytes32 hashedPassword, uint256 expiry) payable returns()
func (_Dropmanager *DropmanagerTransactor) CreateDropLockETH(opts *bind.TransactOpts, hashedPassword [32]byte, expiry *big.Int) (*types.Transaction, error) {
	return _Dropmanager.contract.Transact(opts, "createDropLockETH", hashedPassword, expiry)
}

// CreateDropLockETH is a paid mutator transaction binding the contract method 0xa512c06a.
//
// Solidity: function createDropLockETH(bytes32 hashedPassword, uint256 expiry) payable returns()
func (_Dropmanager *DropmanagerSession) CreateDropLockETH(hashedPassword [32]byte, expiry *big.Int) (*types.Transaction, error) {
	return _Dropmanager.Contract.CreateDropLockETH(&_Dropmanager.TransactOpts, hashedPassword, expiry)
}

// CreateDropLockETH is a paid mutator transaction binding the contract method 0xa512c06a.
//
// Solidity: function createDropLockETH(bytes32 hashedPassword, uint256 expiry) payable returns()
func (_Dropmanager *DropmanagerTransactorSession) CreateDropLockETH(hashedPassword [32]byte, expiry *big.Int) (*types.Transaction, error) {
	return _Dropmanager.Contract.CreateDropLockETH(&_Dropmanager.TransactOpts, hashedPassword, expiry)
}

// OnERC721Received is a paid mutator transaction binding the contract method 0x150b7a02.
//
// Solidity: function onERC721Received(address operator, address from, uint256 tokenId, bytes data) returns(bytes4)
func (_Dropmanager *DropmanagerTransactor) OnERC721Received(opts *bind.TransactOpts, operator common.Address, from common.Address, tokenId *big.Int, data []byte) (*types.Transaction, error) {
	return _Dropmanager.contract.Transact(opts, "onERC721Received", operator, from, tokenId, data)
}

// OnERC721Received is a paid mutator transaction binding the contract method 0x150b7a02.
//
// Solidity: function onERC721Received(address operator, address from, uint256 tokenId, bytes data) returns(bytes4)
func (_Dropmanager *DropmanagerSession) OnERC721Received(operator common.Address, from common.Address, tokenId *big.Int, data []byte) (*types.Transaction, error) {
	return _Dropmanager.Contract.OnERC721Received(&_Dropmanager.TransactOpts, operator, from, tokenId, data)
}

// OnERC721Received is a paid mutator transaction binding the contract method 0x150b7a02.
//
// Solidity: function onERC721Received(address operator, address from, uint256 tokenId, bytes data) returns(bytes4)
func (_Dropmanager *DropmanagerTransactorSession) OnERC721Received(operator common.Address, from common.Address, tokenId *big.Int, data []byte) (*types.Transaction, error) {
	return _Dropmanager.Contract.OnERC721Received(&_Dropmanager.TransactOpts, operator, from, tokenId, data)
}

// UnlockDrop is a paid mutator transaction binding the contract method 0x76ac1264.
//
// Solidity: function unlockDrop((bytes32,bytes32,bytes32,bytes32,bytes32,bytes32,bytes32,bytes32) proof, bytes32 lockId, bytes32 unlockHash) returns()
func (_Dropmanager *DropmanagerTransactor) UnlockDrop(opts *bind.TransactOpts, proof DropManagerProofData, lockId [32]byte, unlockHash [32]byte) (*types.Transaction, error) {
	return _Dropmanager.contract.Transact(opts, "unlockDrop", proof, lockId, unlockHash)
}

// UnlockDrop is a paid mutator transaction binding the contract method 0x76ac1264.
//
// Solidity: function unlockDrop((bytes32,bytes32,bytes32,bytes32,bytes32,bytes32,bytes32,bytes32) proof, bytes32 lockId, bytes32 unlockHash) returns()
func (_Dropmanager *DropmanagerSession) UnlockDrop(proof DropManagerProofData, lockId [32]byte, unlockHash [32]byte) (*types.Transaction, error) {
	return _Dropmanager.Contract.UnlockDrop(&_Dropmanager.TransactOpts, proof, lockId, unlockHash)
}

// UnlockDrop is a paid mutator transaction binding the contract method 0x76ac1264.
//
// Solidity: function unlockDrop((bytes32,bytes32,bytes32,bytes32,bytes32,bytes32,bytes32,bytes32) proof, bytes32 lockId, bytes32 unlockHash) returns()
func (_Dropmanager *DropmanagerTransactorSession) UnlockDrop(proof DropManagerProofData, lockId [32]byte, unlockHash [32]byte) (*types.Transaction, error) {
	return _Dropmanager.Contract.UnlockDrop(&_Dropmanager.TransactOpts, proof, lockId, unlockHash)
}

// UnlockExpiredLock is a paid mutator transaction binding the contract method 0x07f32665.
//
// Solidity: function unlockExpiredLock(bytes32 lockId) returns()
func (_Dropmanager *DropmanagerTransactor) UnlockExpiredLock(opts *bind.TransactOpts, lockId [32]byte) (*types.Transaction, error) {
	return _Dropmanager.contract.Transact(opts, "unlockExpiredLock", lockId)
}

// UnlockExpiredLock is a paid mutator transaction binding the contract method 0x07f32665.
//
// Solidity: function unlockExpiredLock(bytes32 lockId) returns()
func (_Dropmanager *DropmanagerSession) UnlockExpiredLock(lockId [32]byte) (*types.Transaction, error) {
	return _Dropmanager.Contract.UnlockExpiredLock(&_Dropmanager.TransactOpts, lockId)
}

// UnlockExpiredLock is a paid mutator transaction binding the contract method 0x07f32665.
//
// Solidity: function unlockExpiredLock(bytes32 lockId) returns()
func (_Dropmanager *DropmanagerTransactorSession) UnlockExpiredLock(lockId [32]byte) (*types.Transaction, error) {
	return _Dropmanager.Contract.UnlockExpiredLock(&_Dropmanager.TransactOpts, lockId)
}

// DropmanagerDropAddedIterator is returned from FilterDropAdded and is used to iterate over the raw logs and unpacked data for DropAdded events raised by the Dropmanager contract.
type DropmanagerDropAddedIterator struct {
	Event *DropmanagerDropAdded // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *DropmanagerDropAddedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(DropmanagerDropAdded)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(DropmanagerDropAdded)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *DropmanagerDropAddedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *DropmanagerDropAddedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// DropmanagerDropAdded represents a DropAdded event raised by the Dropmanager contract.
type DropmanagerDropAdded struct {
	Id              [32]byte
	Sender          common.Address
	HashedPassword  [32]byte
	PrizeType       string
	ContractAddress common.Address
	Amount          *big.Int
	Expiry          *big.Int
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterDropAdded is a free log retrieval operation binding the contract event 0x5fad606300e26030482ed62e94f0a80aad0566453391da21f5157ddd559073ce.
//
// Solidity: event DropAdded(bytes32 indexed id, address indexed sender, bytes32 hashedPassword, string prizeType, address contractAddress, uint256 amount, uint256 expiry)
func (_Dropmanager *DropmanagerFilterer) FilterDropAdded(opts *bind.FilterOpts, id [][32]byte, sender []common.Address) (*DropmanagerDropAddedIterator, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}
	var senderRule []interface{}
	for _, senderItem := range sender {
		senderRule = append(senderRule, senderItem)
	}

	logs, sub, err := _Dropmanager.contract.FilterLogs(opts, "DropAdded", idRule, senderRule)
	if err != nil {
		return nil, err
	}
	return &DropmanagerDropAddedIterator{contract: _Dropmanager.contract, event: "DropAdded", logs: logs, sub: sub}, nil
}

// WatchDropAdded is a free log subscription operation binding the contract event 0x5fad606300e26030482ed62e94f0a80aad0566453391da21f5157ddd559073ce.
//
// Solidity: event DropAdded(bytes32 indexed id, address indexed sender, bytes32 hashedPassword, string prizeType, address contractAddress, uint256 amount, uint256 expiry)
func (_Dropmanager *DropmanagerFilterer) WatchDropAdded(opts *bind.WatchOpts, sink chan<- *DropmanagerDropAdded, id [][32]byte, sender []common.Address) (event.Subscription, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}
	var senderRule []interface{}
	for _, senderItem := range sender {
		senderRule = append(senderRule, senderItem)
	}

	logs, sub, err := _Dropmanager.contract.WatchLogs(opts, "DropAdded", idRule, senderRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(DropmanagerDropAdded)
				if err := _Dropmanager.contract.UnpackLog(event, "DropAdded", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseDropAdded is a log parse operation binding the contract event 0x5fad606300e26030482ed62e94f0a80aad0566453391da21f5157ddd559073ce.
//
// Solidity: event DropAdded(bytes32 indexed id, address indexed sender, bytes32 hashedPassword, string prizeType, address contractAddress, uint256 amount, uint256 expiry)
func (_Dropmanager *DropmanagerFilterer) ParseDropAdded(log types.Log) (*DropmanagerDropAdded, error) {
	event := new(DropmanagerDropAdded)
	if err := _Dropmanager.contract.UnpackLog(event, "DropAdded", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// DropmanagerDropUnlockedIterator is returned from FilterDropUnlocked and is used to iterate over the raw logs and unpacked data for DropUnlocked events raised by the Dropmanager contract.
type DropmanagerDropUnlockedIterator struct {
	Event *DropmanagerDropUnlocked // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *DropmanagerDropUnlockedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(DropmanagerDropUnlocked)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(DropmanagerDropUnlocked)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *DropmanagerDropUnlockedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *DropmanagerDropUnlockedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// DropmanagerDropUnlocked represents a DropUnlocked event raised by the Dropmanager contract.
type DropmanagerDropUnlocked struct {
	Id              [32]byte
	Sender          common.Address
	Reciever        common.Address
	HashedPassword  [32]byte
	PrizeType       string
	ContractAddress common.Address
	Amount          *big.Int
	Expiry          *big.Int
	Raw             types.Log // Blockchain specific contextual infos
}

// FilterDropUnlocked is a free log retrieval operation binding the contract event 0x8f13e273c468229cf2a077c033f34cb0f5952f93bc780b4ba6800f3cfcb683ec.
//
// Solidity: event DropUnlocked(bytes32 indexed id, address indexed sender, address indexed reciever, bytes32 hashedPassword, string prizeType, address contractAddress, uint256 amount, uint256 expiry)
func (_Dropmanager *DropmanagerFilterer) FilterDropUnlocked(opts *bind.FilterOpts, id [][32]byte, sender []common.Address, reciever []common.Address) (*DropmanagerDropUnlockedIterator, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}
	var senderRule []interface{}
	for _, senderItem := range sender {
		senderRule = append(senderRule, senderItem)
	}
	var recieverRule []interface{}
	for _, recieverItem := range reciever {
		recieverRule = append(recieverRule, recieverItem)
	}

	logs, sub, err := _Dropmanager.contract.FilterLogs(opts, "DropUnlocked", idRule, senderRule, recieverRule)
	if err != nil {
		return nil, err
	}
	return &DropmanagerDropUnlockedIterator{contract: _Dropmanager.contract, event: "DropUnlocked", logs: logs, sub: sub}, nil
}

// WatchDropUnlocked is a free log subscription operation binding the contract event 0x8f13e273c468229cf2a077c033f34cb0f5952f93bc780b4ba6800f3cfcb683ec.
//
// Solidity: event DropUnlocked(bytes32 indexed id, address indexed sender, address indexed reciever, bytes32 hashedPassword, string prizeType, address contractAddress, uint256 amount, uint256 expiry)
func (_Dropmanager *DropmanagerFilterer) WatchDropUnlocked(opts *bind.WatchOpts, sink chan<- *DropmanagerDropUnlocked, id [][32]byte, sender []common.Address, reciever []common.Address) (event.Subscription, error) {

	var idRule []interface{}
	for _, idItem := range id {
		idRule = append(idRule, idItem)
	}
	var senderRule []interface{}
	for _, senderItem := range sender {
		senderRule = append(senderRule, senderItem)
	}
	var recieverRule []interface{}
	for _, recieverItem := range reciever {
		recieverRule = append(recieverRule, recieverItem)
	}

	logs, sub, err := _Dropmanager.contract.WatchLogs(opts, "DropUnlocked", idRule, senderRule, recieverRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(DropmanagerDropUnlocked)
				if err := _Dropmanager.contract.UnpackLog(event, "DropUnlocked", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseDropUnlocked is a log parse operation binding the contract event 0x8f13e273c468229cf2a077c033f34cb0f5952f93bc780b4ba6800f3cfcb683ec.
//
// Solidity: event DropUnlocked(bytes32 indexed id, address indexed sender, address indexed reciever, bytes32 hashedPassword, string prizeType, address contractAddress, uint256 amount, uint256 expiry)
func (_Dropmanager *DropmanagerFilterer) ParseDropUnlocked(log types.Log) (*DropmanagerDropUnlocked, error) {
	event := new(DropmanagerDropUnlocked)
	if err := _Dropmanager.contract.UnpackLog(event, "DropUnlocked", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
