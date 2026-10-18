// Placeholder for a simple multisig contract
// To be expanded with owners, threshold, execute function
pragma solidity ^0.8.20;

contract SimpleMultiSig {
    address[] public owners;
    uint public threshold;

    constructor(address[] memory _owners, uint _threshold) {
        owners = _owners;
        threshold = _threshold;
    }
}
