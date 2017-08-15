# Remittance
B9 Labs Project

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
