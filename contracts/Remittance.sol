//Remittance practice contract

pragma solidity ^0.4.6;

contract Remittance{
    address public owner; //Me, as contract maker to get funds. 
    address public sendR; //Alice.
    address public exchanger; //Carol.

    bytes32 private correctPass; //Correct passwords hashed together.
    
    //Stretch goals - Adding a time limit
    uint    public limit; //Assume to use block timestamp, should be given in seconds (?)

function Remittance(address alice, address carol, uint lim)
// Not payable - avoid sending ether during deployment
//I assume that I input all addresses for Alice, Bob & Carol? 
//I assume that I choose the deadline or does Alice? 
{
    owner = msg.sender; 
    sendR = alice; 
    exchanger = carol; 
    limit = block.timestamp + lim; //However far into the future
}

//Function to check if campaign has passed deadline
function isStillGoing()
    public
    returns (bool stillGoing)
{
    //Tells you if the time limit has been reached
    if(block.timestamp >= limit){
        return false;
    } else {
        return true;
    }
}

//Function so that Alice can send funds and passwords to the contract 
//Assumming that Alice hashes the passwords together prior to sending them to a 
//the contract. This way the passwords are not publicly known.
function aliceSendEth(bytes32 hashofBoth)
    public
    payable
    returns (bool success)
{
    //Cases to throw, not Alice or no positive ether value
    if (msg.sender != sendR) throw; 
    if (msg.value <= 0) throw;
    //Send owner of contract a cut
    var forOwner = msg.value/20;
    if (!owner.send(forOwner)) throw;
    correctPass = hashofBoth; 
    return true;
}



//Function that takes in Carol's passwords and sends her the balance
function carolEx(bytes32 pass1, bytes32 pass2)
    public
    returns (bool success)
{
    //Cases to throw, if not send by Carol's address or passwords wrong
    if (msg.sender != exchanger) throw;
    //Passwords are sent in as is, and then hash to compare with original hash sent by Alice
    var submitPass = keccak256(pass1, pass2);
    if (submitPass != correctPass) throw; 
    //Throw if passsed the deadline
    if (!isStillGoing()) throw; 
    //Send balance to Carol
    var toSend = this.balance; //Accounting.
    if(!msg.sender.send(toSend))throw; //Send funds to Carol.
    submitPass = bytes32 (0); //To prevent someone else coming in to reclaim
    correctPass = bytes32 (0);
    return true;
}

//If Carol fails to send, Alice can retrieve funds.
function failedToSend()
    public
    returns (bool success)
{
    if (msg.sender != sendR) throw; 
    if (!isStillGoing()) throw; 
    var moneyToSend = this.balance; 
    if (!msg.sender.send(moneyToSend)) throw; 
    return true;
}

//Kill switch funtion, should send funds back to Alice
function stopIt()
    public 
    {
    if (msg.sender != owner) throw; 
    selfdestruct(sendR); //send all funds back to Alice
    }

}
