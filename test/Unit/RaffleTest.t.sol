//SPDX-License-Identifier: MIT 

pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/Helperconfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {CodeConstants} from "../../script/Helperconfig.s.sol";

contract RaffleTest is Test,CodeConstants{

    Raffle public raffle;
    HelperConfig helperconfig;

    event RaffleEnter(address indexed player);
    event WinnerPicked(address indexed winner);
    event RandomNumberRequested(uint256 requestnumber);

    address public USER = makeAddr("user");    
    address public HACKER = makeAddr("hacko");    
    uint256 public constant STARTING_BALANCE = 10 ether;
    uint256 public constant SEND_BALANCE = 0.1 ether;
    uint256 public constant SEND_LOW = 0.001 ether; 

        uint256 entrancefee;
        uint256 interval;
        address vrfCordinator;
        bytes32 gasLane;
        uint256 subscriptionid;
        uint32 callgasLimit;


    function setUp() external {

    DeployRaffle deploy = new DeployRaffle();
    (raffle,helperconfig) = deploy.DeployRafflee();
    
    HelperConfig.NetworkConfig memory config = helperconfig.getconfig();
        entrancefee = config.entrancefee;
         interval = config.interval;
         vrfCordinator = config.vrfCordinator;
         gasLane = config.gasLane;
         subscriptionid = config.subscriptionid;
         callgasLimit = config.callgasLimit;
         vm.deal(USER,STARTING_BALANCE);
         vm.deal(HACKER,STARTING_BALANCE);
    }

    function testRaffleState() public view {
            assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);        
    }

    function testEntranceFee() public {
        vm.prank(USER);
        vm.expectRevert();
        raffle.EnterRaffle{value: SEND_LOW}();
    }

    function testplayersarray() public {
        // Arrange
        vm.prank(USER);
        // Act 
        raffle.EnterRaffle{value: SEND_BALANCE}();
        // Assert
        assertEq(USER,raffle.getplayerbyindex(0));
    }

    function testEvents() public {
        vm.prank(USER);

        vm.expectEmit(true,false,false,false,address(raffle)); 
        emit RaffleEnter(USER);

       raffle.EnterRaffle{value: SEND_BALANCE}();         
    }


    function testNotLetPlayersInWhileCalculating() public {
        vm.prank(USER);
        raffle.EnterRaffle{value: SEND_BALANCE}();
        vm.warp(block.timestamp + interval + 5);
        vm.roll(block.number + 1);

        raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(HACKER);
        raffle.EnterRaffle{value: SEND_BALANCE}();
        



    }


    function testUpKeepwhennoBalance() public {
        vm.warp(block.timestamp + interval + 5);
        vm.roll(block.number + 1);

            (bool upkeepNeeded,) = raffle.checkUpkeep("");

                assert(!upkeepNeeded);
    }

    function testUpkeepfalsewhenStateis() public {
        vm.prank(USER);
        raffle.EnterRaffle{value: SEND_BALANCE}();
        vm.warp(block.timestamp + interval + 5);
        vm.roll(block.number + 1);
        raffle.setRaffleState(Raffle.RaffleState.Calculating);
        (bool upkeepNeeded,) = raffle.checkUpkeep("");

        assert(!upkeepNeeded);

    }

    function testperformUpkeepOnlyRunifcheckupKeepIsTrue() public {
        vm.prank(USER);
        raffle.EnterRaffle{value: SEND_BALANCE}();
        vm.warp(block.timestamp + interval + 5);
        vm.roll(block.number + 1);

        raffle.performUpkeep("");

        
    }


    function performUpkeepRevertsifCheckupkeepisFalse() public {
        uint256 currentbalance = 0;
        uint256 numPlayers = 0;
        Raffle.RaffleState s_state = raffle.getRaffleState();

        vm.prank(USER);
        raffle.EnterRaffle{value: entrancefee}();

        vm.expectRevert(abi.encodeWithSelector(Raffle.Raffle__upKeepNotNeeded.selector,currentbalance,numPlayers,s_state));
        raffle.performUpkeep("");

    }


    modifier RaffleEntered() {
    vm.prank(USER);
    raffle.EnterRaffle{value: entrancefee}();
     vm.warp(block.timestamp + interval + 1);
     vm.roll(block.number + 1);
    _;
    }

    modifier skipFork(){
        if(block.chainid != LOCAL_CHAIN_ID){
            return;
        }
        _;
    }



function testEventEmitted() public RaffleEntered {
        vm.recordLogs();
        raffle.performUpkeep("");

    Vm.Log[] memory entries = vm.getRecordedLogs();
    bytes32 requestid = entries[1].topics[1];

    assert(uint256(requestid) > 0);


}

    function testfulFillRandomWordsOnlyCalledAfterPerformUpkeep(uint256 reqid) public RaffleEntered{

        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCordinator).fulfillRandomWords(reqid,address(raffle));
    }


    function testFullFillRandomWordsPicksWinnerResestsAndSendMoney() public RaffleEntered{
                // Arrange
            uint256 additionalEntrants = 3;
            uint256 startingindex = 1;
            address expectedwinner = address(1);

            for(uint256 i = startingindex; i < startingindex + additionalEntrants; i++){
                address newplayer = address(uint160(i));
                hoax(newplayer,10 ether);
                raffle.EnterRaffle{value: entrancefee}();
            }


            uint256 starttingtimestamp = raffle.getLasttimestamp();
            uint256 expectedWinnerStartingbalance = expectedwinner.balance;

                            // Act
            vm.recordLogs();
            raffle.performUpkeep("");
            Vm.Log[] memory entries = vm.getRecordedLogs();
            bytes32 requestId = entries[1].topics[1];
            VRFCoordinatorV2_5Mock(vrfCordinator).fulfillRandomWords(uint256(requestId), address(raffle));

            // Assert
            address recentWinner = raffle.getRecentWinner();
            Raffle.RaffleState raffleState = raffle.getRaffleState();
            uint256 winnerBalance = recentWinner.balance;
            uint256 endingTimeStamp = raffle.getLasttimestamp();
            uint256 prize = entrancefee * (additionalEntrants + 1);

            assert(recentWinner == expectedwinner);
            assert(uint256(raffleState) == 0);
            assert(winnerBalance == expectedWinnerStartingbalance + prize);
            assert(endingTimeStamp > starttingtimestamp);





    }


    receive() external payable {

    }

    fallback() external {

    }








    







    
}
