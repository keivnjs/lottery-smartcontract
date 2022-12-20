// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Election is Ownable {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Voter {
        bool authorized;
        bool voted;
        uint256 vote;
    }

    string public electionName;

    mapping(address => Voter) public voters;
    mapping(uint256 => address[]) private votersIndex;
    Candidate[] public candidates;
    uint256 public totalVotes;
    uint256 public totalRewards;

    State public state;

    enum State {
        Created,
        Voting,
        Ended
    }

    /* ========== MODIFIERS ========== */

    modifier createdState() {
        require(state == State.Created, "it must be in Started");
        _;
    }

    modifier votingState() {
        require(state == State.Voting, "it must be in Voting Period");
        _;
    }

    modifier endedState() {
        require(state == State.Ended, "it must be in Ended Period");
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(string memory _name) payable {
        electionName = _name;
    }

    /* ========== RESRICTED FUNCTION ========== */

    function addCandidate(string memory _name) public onlyOwner {
        candidates.push(Candidate(_name, 0));
    }

    function startVote() public onlyOwner createdState {
        state = State.Voting;
    }

    function endVote() public onlyOwner votingState {
        state = State.Ended;
    }

    function authorize(address _person) public onlyOwner {
        voters[_person].authorized = true;
    }

    function getNumCandidate() public view returns (uint256) {
        return candidates.length;
    }

    function vote(uint256 _voteIndex) public votingState {
        require(
            !voters[msg.sender].voted,
            "You are not allowed to voted twice"
        );
        require(
            voters[msg.sender].authorized,
            "You are not authorized to vote"
        );

        voters[msg.sender].vote = _voteIndex;
        voters[msg.sender].voted = true;

        candidates[_voteIndex].voteCount += 1;
        votersIndex[_voteIndex].push(msg.sender);
        totalVotes += 1;
    }

    function countTotalVotes() internal view returns (uint256 _totalVotes) {
        uint256 winningVoteCount = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                _totalVotes = i;
            }
        }
    }

    function seeWinner() public view returns (string memory, uint256) {
        return (
            candidates[countTotalVotes()].name,
            candidates[countTotalVotes()].voteCount
        );
    }

    function winnerCandidate()
        public
        view
        endedState
        returns (string memory _winnerName)
    {
        uint256 winningVoteCount = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                _winnerName = candidates[i].name;
            }
        }
    }

    function random(uint256 _winnerVoterLength) private view returns (uint8) {
        return
            uint8(
                uint256(
                    keccak256(
                        abi.encodePacked(block.difficulty, block.timestamp)
                    )
                ) % _winnerVoterLength
            );
    }

    function winnerVoter() external onlyOwner endedState {
        address[] memory listAddress = getVoters(countTotalVotes());
        uint256 r = random(listAddress.length);
        payable(listAddress[r]).transfer(address(this).balance);
    }

    function getVoters(uint256 _index) public view returns (address[] memory) {
        uint256 length = votersIndex[_index].length;
        address[] memory member = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            member[i] = votersIndex[_index][i];
        }
        return member;
    }
}
