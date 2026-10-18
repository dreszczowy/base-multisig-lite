// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWallet {
    address[] public owners;
    uint public required;
    mapping(address => bool) public isOwner;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint confirmations;
    }

    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) public confirmed;

    event Submit(uint indexed txId);
    event Confirm(address indexed owner, uint indexed txId);
    event Execute(uint indexed txId);

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "Owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid required");

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;
    }

    function submit(address _to, uint _value, bytes calldata _data) external {
        require(isOwner[msg.sender], "Not owner");
        uint txId = transactions.length;
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            confirmations: 0
        }));
        emit Submit(txId);
    }

    function confirm(uint _txId) external {
        require(isOwner[msg.sender], "Not owner");
        require(_txId < transactions.length, "Tx does not exist");
        require(!confirmed[_txId][msg.sender], "Already confirmed");

        confirmed[_txId][msg.sender] = true;
        transactions[_txId].confirmations += 1;
        emit Confirm(msg.sender, _txId);
    }

    function execute(uint _txId) external {
        require(_txId < transactions.length, "Tx does not exist");
        Transaction storage transaction = transactions[_txId];
        require(!transaction.executed, "Already executed");
        require(transaction.confirmations >= required, "Not enough confirmations");

        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "Tx failed");
        emit Execute(_txId);
    }

    receive() external payable {}
}
