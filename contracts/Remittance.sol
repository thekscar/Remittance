// There are three people: Alice, Bob & Carol.

// Alice wants to send funds to Bob, but she only has ether & Bob wants to be paid in local currency.
// Luckily, Carol runs an exchange shop that converts ether to local currency.
// Therefore, to get the funds to Bob, Alice will allow the funds to be transferred through Carol's Exchange Shop. 
// Carol will convert the ether from Alice into local currency for Bob (possibly minus commission).

// To successfully withdraw the ether from Alice, 
//Carol needs to submit two passwords to Alice's Remittance contract: one password that Alice gave to Carol in an email 
//and another password that Alice sent to Bob over SMS. Since they each have only half of the puzzle, 
//Bob & Carol need to meet in person so they can supply both passwords to the contract. This is a security measure. 
//It may help to understand this use-case as similar to a 2-factor authentication.

// Once Carol & Bob meet and Bob gives Carol his password from Alice, 
//Carol can submit both passwords to Alice's remittance contract. 
//If the passwords are correct, the contract will release the ether to 
//Carol who will then convert it into local funds and give those to Bob (again, possibly minus commission).

// Of course, for safety, no one should send their passwords to the blockchain in the clear.

// Stretch goals:

// add a deadline, after which Alice can claim back the unchallenged Ether
// add a limit to how far in the future the deadline can be
// add a kill switch to the whole contract
// make the contract a utility that can be used by David, Emma and anybody with an address
// make you, the owner of the contract, take a cut of the Ethers smaller than 
// what it would cost Alice to deploy the same contract herself

pragma solidity ^0.4.6;

contract Remittance{
    address public owner; //Me - to get funds
    address public sendR; //Alice 
    address public exchanger; //Carol
    address public bobby; //Bob's address
    bytes32 public correctPass; //Correct passwords hashed together
    bytes32 public submitPass; //Var for passwords submitted by Carol
    //Stretch goals
    uint    public deadline; //Assume to use block numbers, 
    uint    public limit; //Assume to use block timestamp, should be given in seconds (?)

function Remittance(address alice, address carol, address bob, uint noOBlocks, uint lim)
// Not payable - avoid sending ether during deployment
//I assume that I input all addresses for Alice, Bob & Carol? 
//I assume that I choose the deadline or does Alice? 
{
    owner = msg.sender; 
    sendR = alice; 
    exchanger = carol; 
    bobby = bob; 
    deadline = block.number + noOBlocks; //However many more blocks 
    limit = block.timestamp + lim; //However far into the future
    
}

//Function to check if campaign has passed deadline
function isStillGoing()
    public
    returns (bool stillGoing)
{
    //Tells you if blockchain is at the blocks before the deadline or if 
    //time limit has been reached
    if(limit >= block.timestamp){
        return false;
    } else if(deadline < block.number){
        return false;
    } else {
        return true;
    }
}

//Function so that Alice can send funds to the contract 
function aliceSendEth()
    public
    payable
    returns (bool success)
{
    //Cases to throw, not contract owner or no positive ether value
    if (msg.sender != sendR) throw; 
    if (msg.value <= 0) throw;
    //Send owner of contract a cut
    owner.transfer(msg.value/20);
    return true;
    
}

//Function so that Alice can send passwords to the contract
// Assuming bytes32 are already hashed
function aliceSendPas(bytes32 firstPassHash, bytes32 secondPassHash)
    public
    returns (bool success)
{
    if (msg.sender != sendR) throw; 
    //Hash together the two passwords 
    correctPass = keccak256(firstPassHash, secondPassHash);  
    return true; 
}

//Function that takes in Carol's passwords and sends her the balance
function carolEx(bytes32 bPass, bytes32 cPass)
    public
    returns (bool success)
{
    //Cases to throw, if not send by Carol's address or passwords wrong
    if (msg.sender != exchanger) throw;
    //Assuming passwords are sent hashed
    submitPass = keccak256(bPass, cPass);
    if (submitPass != correctPass) throw; 
    //Throw if passsed the deadline
    if (isStillGoing()) throw; 
    //Send balance to Carol
    exchanger.transfer(this.balance); //transfer funds to carol
    return true;
}

//Function where Carol sends back the funds to be sent to Bob
//Assuming Carol does here conversions outside of this contract
//Do we need to validate Bob's address from Carol? 
function carolSend(address bobAd)
    public
    payable //Carol should send value to the contract
    returns (bool success)
{
    if (msg.sender != exchanger) throw; 
    if (bobAd != bobby) throw;
    if (msg.value <= 0) throw; //Make sure that Bob gets something
    //Do we want this to throw after the deadline because Carol will have the
    //money stuck with her if we don't let her send it? 
    bobby.transfer(this.balance);
    return true;
}

//Kill switch funtion, should send funds back to Alice
function stopIt()
    public 
    returns (bool success)
    {
    if (msg.sender != owner) throw; //extra check, just in case
    selfdestruct(sendR); //send all funds back to Alice
    return true;
    }

}
