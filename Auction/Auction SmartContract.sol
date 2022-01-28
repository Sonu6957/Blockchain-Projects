pragma solidity >0.5.0<0.9.0;



contract AuctionCreator{
    Auction[] public auctionaddress;
    function createAuction() public {
        Auction newAuction = new Auction(msg.sender);
        auctionaddress.push(newAuction);
    }
}
contract Auction{
    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;
    
    enum auctionState{Running,cancelled,ended}
    auctionState public State;
    
    address payable public Highestbidder;
    uint public Highestbid;
    
    mapping(address=>uint) public bids;
    uint bidIncrement=100;
    
    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }
    
    modifier notOwner(){
        require(msg.sender!=owner);
        _;
    }
    modifier afterStart(){
        require(block.number>=startBlock);
        _;
    }
    modifier beforeEnd(){
        require(block.number<=endBlock);
        _;
    }
    
    constructor(address eoa){
        owner=payable(eoa);
        startBlock=block.number;
        endBlock = startBlock+40300;
        ipfsHash="";
    }
    function cancelAuction() public onlyOwner{
        State=auctionState.cancelled;
    }
    function min(uint a , uint b) pure public returns(uint){
        if(a<=b)
            return a;
        else 
        return b;
    }
    function placeBid() payable notOwner afterStart beforeEnd public{
        require(State==auctionState.Running);
        require(msg.value>=100);
        
        uint currentBid=bids[msg.sender]+msg.value;
        require(currentBid>Highestbid);
        bids[msg.sender]=currentBid;
        
        if(currentBid<bids[Highestbidder]){
            Highestbid=min(currentBid+bidIncrement,bids[Highestbidder]);
        }
        else{
            Highestbid=min(bids[Highestbidder]+bidIncrement,currentBid);
            Highestbidder=payable(msg.sender);
        }
        
    }
    function finalizeAuction() public {
        require(State==auctionState.cancelled || block.number>endBlock);
        require(msg.sender==owner|| bids[msg.sender]>0);
        
        address payable recepient;
        uint value;
        
        if(State==auctionState.cancelled){
            recepient=payable(msg.sender);
            value=bids[msg.sender];
        }
        else{
            if(msg.sender==owner){
                recepient=owner;
                value=Highestbid;
            }
            else{
                if(msg.sender==Highestbidder){
                    recepient=Highestbidder;
                    value=bids[Highestbidder]-Highestbid;
                }
                else{
                    recepient=payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }
        bids[recepient]=0;
        recepient.transfer(value);
    }
}