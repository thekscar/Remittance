//Remittance practice contract

pragma solidity ^0.4.18;

contract Remittance {

    address public owner; //Me, as contract maker to get funds. 
    
    struct Remittances {
        address exchanger;
        address thesender; 
        uint    thelimit;
        bool    withdraw; //True of false if the funds have been withdrawn by Carol or Alice after timelimit
    }
    
    mapping(bytes32 => Remittances) public remittances; 
    mapping(address => uint) public balances; 

    event RemitStart(address sender, address exchanger, uint limit, bytes32 hashOfBoth);
    event RemitWithdraw(address sender, address exchanger, uint amount);
    event TimeUpWithdraw(address sender, uint amount);

function Remittance()

{
    owner = msg.sender; 
}

/* A function to simplify a user and testing experience for hashing. Realize that 
all can be seen on the blockchain, but for testing with truffle it makes 
things easier as Truffle is not currently downloading with web3 1.0.0 with 
web3.utils.soliditySha3() */
function hashPlease(bytes32 one, bytes32 two)
    view
    public
    returns (bytes32 yourhash)
{
    return keccak256(one, two);
}

/*  
Stretch goals - Adding a time limit using block.timestamp. Using how many seconds
far into the future that Carol can pull funds. If not met, funds go back to Alice.
Each remittance is tied to its hash, so you can check the limit of each remittance by
the hash. 
*/

function isStillGoing(bytes32 hashofBoth)
    view
    public
    returns (bool stillGoing)
{
    //Tells you if the time limit has been reached
    uint checklimit = remittances[hashofBoth].thelimit;
    if (block.timestamp >= checklimit) {
        return false;
    } else {
        return true;
    }
}

//Safemath
function sub(uint256 a, uint256 b) 
    internal 
    pure 
    returns (uint256) 
{
    assert(b <= a);
    return a - b;
}

/*
Function for Alice (or whomever wants to sent in the remittance) to 
send Eth to the contract along with a hash of the combined password for (1) Carol
and (2) Bob. This way the passwords are not publicly known or calculated. 
Also, Alice sets a time limit for which Carol may withdrawl the funds. Limit
is enter in seconds and is measured by the block.timestamp. 
*/
function sendEth(bytes32 hashOfBoth, uint limit, address exchanger)
    public
    payable
    returns (bool success)
{
    require(msg.value != 0);
    //Limit must be less than one week. 
    require(limit <= 604800);
    remittances[hashOfBoth].exchanger = exchanger;
    remittances[hashOfBoth].thelimit = limit + block.timestamp; 
    remittances[hashOfBoth].thesender = msg.sender;
    remittances[hashOfBoth].withdraw = false;
    //Send owner of contract a cut 
    balances[owner] += msg.value/20; 
    balances[exchanger] += sub(msg.value, msg.value/20);
    RemitStart(msg.sender, exchanger, limit, hashOfBoth);
    return true;
}

/* Function for Carol or whomever the exchanger is to withdraw their allotted balance by
supplying the two secrets (both already hashed) to unlock the funds.  */
function exchangerWithdrawl(bytes32 hashone, bytes32 hashtwo)
    public
    returns (bool success)
{
    bytes32 completepass = keccak256(hashone, hashtwo);
    address exchanger = remittances[completepass].exchanger; 
    /* Require that only the allotted exchanger can access. This checks that this exchanger is 
    allotted to this 'hash'or this remittance case. */
    require(msg.sender == exchanger);
    require(isStillGoing(completepass) == true);
    require(balances[msg.sender] > 0);
    require(remittances[completepass].withdraw == false);
    uint tosend = balances[msg.sender];
    balances[msg.sender] = 0;
    remittances[completepass].withdraw = true; 
    msg.sender.transfer(tosend);
    RemitWithdraw(remittances[completepass].thesender, exchanger, tosend);   
    return true;
}

/* If Carol fails to withdrawl funds before the timeline ends, 
Alice needs to be able retrieve funds. This function allows Alice to withdrawl funds after the deadline.*/
function timeLimitUp(bytes32 hashOfBoth)
    public
    returns (bool success)
{
    require(isStillGoing(hashOfBoth) == false);
    require(remittances[hashOfBoth].thesender == msg.sender);
    require(remittances[hashOfBoth].withdraw == false);
    /* Allowing Alice  to withdraw the amount that she allotted to Carol. */
    uint tosend = balances[remittances[hashOfBoth].exchanger];
    balances[remittances[hashOfBoth].exchanger] = 0; 
    remittances[hashOfBoth].withdraw = true; 
    msg.sender.transfer(tosend);
    TimeUpWithdraw(msg.sender, tosend);
    return true;
}

//Kill switch funtion, should send funds back to Alice
function stopIt()
    public 
    {
    assert(msg.sender == owner);
    selfdestruct(owner); //send all funds back to Alice
    }

}
