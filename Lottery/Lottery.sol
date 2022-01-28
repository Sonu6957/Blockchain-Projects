//SPDX-License-Identifier: GPL-3

pragma solidity >=0.5.8<0.9.0;

contract Lottery{
    address payable[] public players;
    address public manager;
    
    constructor(){ //making manager,the owner
        manager=msg.sender;
    }
    receive() external payable{
        require(msg.value==0.1 ether,"Value should be 0.1 ether");
        players.push(payable (msg.sender));
    }
    function getbalance() public view returns(uint){
        require(msg.sender==manager,"Sorry you're not allowed.");
        return address(this).balance;
    }
    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,players.length)));
    }
    function pickWinner() public{
        require(msg.sender==manager,"You are not a manager");
        require(players.length>=3,"Less no. of players");
        
        address payable winner;
        uint r = random();
        uint win= r%players.length;
        winner=players[win];
        
        winner.transfer(address(this).balance);
        
        players = new address payable[](0); 
    }
}