//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Raffle} from "../../src/Raffle.sol";
import {Test} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/Helperconfig.s.sol";
// import {CreateSubscription,FundSubscription,AddConsumer} from "../../script/Interactions.s.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {console} from "forge-std/console.sol";

contract Interactions is Test{
        Raffle public raffle;
        address USER = makeAddr("user");
        uint256 constant SEND_VALUE = 0.1 ether;
        uint256 constant STARTING_BALANCE = 10 ether;

        function setUp() public {
            vm.deal(USER,STARTING_BALANCE);
            DeployRaffle deploy = new DeployRaffle();
            raffle = deploy.run();
        }

        function testmakeUserFundandEnterRaffle() public {
                vm.prank(USER);
                raffle.EnterRaffle{value: SEND_VALUE}();

                assertEq(USER,raffle.getplayerbyindex(0));
                
        }




}