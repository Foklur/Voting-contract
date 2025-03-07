// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    address public owner;
    uint public candidateFee = 0.01 ether;
    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public hasVoted;
    uint public candidatesCount;
    uint public totalBalance;
    
    event CandidateAdded(uint id, string name);
    event Voted(address voter, uint candidateId);
    event WinnerDeclared(string winnerName, uint votes);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action!");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addCandidate(string memory _name) public payable {
        require(msg.value == candidateFee, "Incorrect fee amount");
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        totalBalance += msg.value;
        emit CandidateAdded(candidatesCount, _name);
        candidatesCount++;
    }

    function vote(uint _candidateId) public {
        require(!hasVoted[msg.sender], "You have already voted");
        require(_candidateId < candidatesCount, "Invalid candidate ID");
        
        hasVoted[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        emit Voted(msg.sender, _candidateId);
    }

    function getBalance() public view returns (uint) {
        return totalBalance;
    }

    function determineWinner() public view onlyOwner returns (string memory) {
        require(candidatesCount > 0, "No candidates available");
        
        uint maxVotes = 0;
        string memory winner;
        for (uint i = 0; i < candidatesCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winner = candidates[i].name;
            }
        }
        
        return winner;
    }
}
