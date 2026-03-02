// SPDX-License-Identifier: Meta-Microsoft
pragma solidity ^0.8.20;

contract MyContract {
    string public message;

    constructor() {
        message = "Pedrosa's Emergence: Contextual Intelligence";
    }

    function setMessage(string calldata newMessage) public {
        message = newMessage;
    }

    function getMessage() public view returns (string memory) {
        return message;
    }
}
