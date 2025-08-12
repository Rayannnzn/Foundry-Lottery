// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions




//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/* Imports */
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";


/* Errors */
error Raffle__TransferFailed();
error Raffle__SendMoreEthToEnterRaffle();




/**
 * @title This is a Sample Raffle Contract
 * @author Rayan
 * @notice This Implements Chainlink VRFv2.5
 */

contract Raffle is VRFConsumerBaseV2Plus{
    error Raffle__upKeepNotNeeded(uint256 balance,uint256 players,uint256 rafflestate);
    error Raffle__RaffleNotOpen();
    /** Type Declarations */
    enum RaffleState{
        OPEN,
        Calculating
    }

    /* State Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 immutable i_entrancefee;
    address payable[] private s_players;
    address private s_recentWinner;
    uint256 private immutable i_interval; // The Interval will be in Seconds
    uint256 private s_LastTimeStamp;
    uint256 private immutable i_subscriptionid;
    uint32 private immutable i_callbackGasLimit;
    bytes32 private immutable i_keyhash; 
    RaffleState public s_rafflestate; 

    /* Events */
    event RaffleEnter(address indexed player);
    event WinnerPicked(address indexed winner);
    event RandomNumberRequested(uint256 indexed requestnumber);
                /** Constructor */
constructor(uint256 entracefee,uint256 interval, address vrfCoordinator,bytes32 gasLane,uint256 subscriptionId,uint32 callgaslimit) VRFConsumerBaseV2Plus(vrfCoordinator) {
    i_entrancefee = entracefee;
    i_interval = interval;
    s_LastTimeStamp = block.timestamp;
    i_keyhash = gasLane;
    i_subscriptionid = subscriptionId;
    i_callbackGasLimit = callgaslimit;
    s_rafflestate = RaffleState.OPEN;
}



        /*Functions */
    function EnterRaffle() external payable {
    //require(msg.value >= i_entrancefee,"Not Enough Sent");
    if(s_rafflestate != RaffleState.OPEN){
        revert Raffle__RaffleNotOpen(); 
    }

    if(msg.value < i_entrancefee){
        revert Raffle__SendMoreEthToEnterRaffle();
    }
    s_players.push(payable(msg.sender));
    // Makes Migration Easier
    // Makes Frontend Indexing Easier
    emit RaffleEnter(msg.sender);

    }

    /**
     * @dev This is the function that Chainlink Nodes will call
     * If the Lottery is ready to have a Winner Picked
     * The Following Should be Needed to true in order for UpkeepNeeded to be true:
     * The Time Interval has passed between Raffle runs
     * The Lottery is Open
     * The Contract has ETH
     * Implicitly,Your Subscription has Link
     * @param -ignored
     * @return upkeepNeeded /* true if its Time to restart the lottery /*
     * @return -ignored
     */
    function checkUpkeep(bytes memory/* checkData */ ) public view returns(bool upkeepNeeded,bytes memory /* */){
        bool timePassed = ((block.timestamp - s_LastTimeStamp) >= i_interval);
        bool isOpen = s_rafflestate == RaffleState.OPEN;
        bool hasBalance = (address(this).balance > 0);
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = timePassed && isOpen && hasBalance && hasPlayers;

        return (upkeepNeeded,"");

    }




    // Get a Random Number
    //Pick a Player using the Random Number
    // Be automatically Called 
     function performUpkeep(bytes calldata /* performData */) external {
            (bool upkeepNeeded,) = checkUpkeep("");
            
            if(!upkeepNeeded){
                revert Raffle__upKeepNotNeeded(address(this).balance,s_players.length,uint256(s_rafflestate));
            }

        s_rafflestate = RaffleState.Calculating;


        VRFV2PlusClient.RandomWordsRequest memory request =  VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyhash,
                subId: i_subscriptionid,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,  // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            });
        uint256 requestid = s_vrfCoordinator.requestRandomWords(request);

        emit RandomNumberRequested(requestid);

    }

        // CEI: Checks, Effects, Interactions Pattern
    function fulfillRandomWords(uint256 /*requestId*/, uint256[] calldata randomWords) internal virtual override {
            // Checks
            // Conditions for Function
            // if/else,require() etc
            //We dont have currently !

            // Effects (Internal Contract State)
        uint256 winnerindex = randomWords[0] % s_players.length;
        address payable recentwinner = s_players[winnerindex];
            s_recentWinner = recentwinner;
            s_players = new address payable [](0);

            s_LastTimeStamp = block.timestamp;

            s_rafflestate = RaffleState.OPEN;
            emit WinnerPicked(recentwinner);

                // Interactions (External Contract Interactions)
            (bool success,) = recentwinner.call{value: address(this).balance}("");
            if(!success){
                revert Raffle__TransferFailed();
            }       
    }



    /** Getter Functions */
    function getEntranceFee() external view returns (uint256){
        return i_entrancefee;
    }

    function getRaffleState() external view returns (RaffleState){
        return s_rafflestate;
    }

    function getplayerbyindex(uint256 index) public view returns(address){
        return s_players[index];
    }

    function setRaffleState(RaffleState _state) external {
    s_rafflestate = _state;
    }

    function getLasttimestamp() external view returns(uint256){
        return s_LastTimeStamp;
    }

    function getRecentWinner() external view returns(address){
        return s_recentWinner;
    }

    

}