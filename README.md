📘 README: Mathematical Proof NFT Smart Contract

Overview

The Mathematical Proof NFT Contract is a Clarity smart contract designed to mint NFTs representing verified mathematical proofs, validated by a community oracle system.
Each proof submission is tokenized as a unique NFT after passing a validation process managed by trusted oracle validators.

This contract promotes trust, transparency, and recognition for mathematical problem-solving in a decentralized way.

🧩 Key Features

NFT Representation of Proofs:
Each accepted mathematical proof is minted as a unique non-fungible token (proof-nft) linked to the submitter’s principal.

Oracle-Based Validation:
Registered oracles can validate or reject proofs. When the number of validations reaches a defined threshold, the proof is marked as validated.

Community Governance:
The contract owner can manage oracles (add/remove) and adjust the required validation threshold.

Immutable Record:
Each proof includes metadata (title, description, proof hash) ensuring authenticity and immutability on-chain.

⚙️ Data Structures
Non-Fungible Token

proof-nft uint — Represents a validated mathematical proof.

Data Variables
Variable	Type	Description
last-token-id	uint	Tracks the most recently minted NFT ID.
oracle-threshold	uint	Minimum number of validations required for a proof to be verified. Default: 3
Data Maps
Map	Key	Value	Description
proofs	{ token-id: uint }	{ title, description, proof-hash, submitter, validation-count, is-validated }	Stores metadata and validation state of proofs.
oracle-votes	{ token-id, oracle }	{ validated: bool }	Tracks each oracle’s vote for a given proof.
oracles	{ oracle }	{ is-active: bool }	Stores authorized oracle validators.
🔐 Access Control

Contract Owner:
The deployer (CONTRACT-OWNER) can manage oracles and system parameters.

Oracles:
Only active oracles can validate proofs.

Submitters:
Anyone can submit a new proof for validation.

🧮 Core Functions
Public Functions
Function	Description
submit-proof(title, description, proof-hash)	Submits a new proof and mints a new NFT token for it.
validate-proof(token-id, is-valid)	Allows an oracle to validate or reject a proof. Increments validation count and checks if threshold is met.
add-oracle(oracle)	Adds a new oracle (owner-only).
remove-oracle(oracle)	Removes an oracle (owner-only).
set-oracle-threshold(new-threshold)	Updates the minimum number of validations required for proof verification.
Read-Only Functions
Function	Description
get-proof(token-id)	Retrieves proof details by token ID.
get-last-token-id()	Returns the most recently minted proof ID.
get-oracle-status(oracle)	Checks if a principal is an active oracle.
get-oracle-vote(token-id, oracle)	Fetches an oracle’s vote for a proof.
get-oracle-threshold()	Returns the current validation threshold.
get-owner()	Returns the contract owner’s principal.
🧑‍🏫 Example Workflow

Submit Proof:

(contract-call? .math-proof-nft submit-proof "Fermat's Last Theorem" "Proof using elliptic curves" 0x1234...)


Add Oracles (Owner Only):

(contract-call? .math-proof-nft add-oracle 'ST1234...)


Oracles Validate:

(contract-call? .math-proof-nft validate-proof u1 true)


Check Proof Status:

(contract-call? .math-proof-nft get-proof u1)

🧱 Deployment Notes

The deploying wallet automatically becomes the contract owner and first oracle.

Threshold defaults to 3 validations for proof acceptance.

Error codes are defined for authorization, existence, and validation checks (u100–u105).

⚠️ Error Codes
Code	Meaning
u100	Not authorized
u101	Proof not found
u102	Oracle already voted
u103	Invalid proof submission
u104	Proof not yet validated
u105	Invalid input data

🧠 Summary

This contract decentralizes mathematical proof recognition through NFT-backed verification and community-based validation, providing a transparent, verifiable record of mathematical contributions.