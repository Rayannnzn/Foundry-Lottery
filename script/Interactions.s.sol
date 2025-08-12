//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {HelperConfig,CodeConstants} from "./Helperconfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {Script,console} from "forge-std/Script.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";


contract CreateSubscription is Script{

    function createSubscriptioUsingconfig() public returns (uint256,address){
        HelperConfig helperconfig = new HelperConfig();
        address vrfcordinator = helperconfig.getconfig().vrfCordinator;
        

        (uint256 SubId,) = createSubscription(vrfcordinator);
        return (SubId,vrfcordinator);
    }

    function createSubscription(address vrfcordinator) public returns (uint256,address){
        console.log("Creating Subscription ID on chain block",block.chainid);

        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfcordinator).createSubscription();
        vm.stopBroadcast();

        console.log("Your Subscription ID is",subId);
        console.log("Please Update Your Subscription id in Your Helperconfig");

        return (subId,vrfcordinator);
    }

    function run() public {
    createSubscriptioUsingconfig();
    }

}





contract FundSubscription is CodeConstants,Script {

            uint256 public constant FUND_SUBSCRIPTION = 3 ether;

        function FundSubscriptionbyconfig() public {
            HelperConfig helperconfig = new HelperConfig();
            address vrfcordinator = helperconfig.getconfig().vrfCordinator;
            uint256 Subscriptionid = helperconfig.getconfig().subscriptionid;
            address linktoken = helperconfig.getconfig().link;
            

            fundSubscription(vrfcordinator,Subscriptionid,linktoken);
        }

        function fundSubscription(address vrfcordinator,uint256 Subsid,address linktoken) public {
             console.log("Funding Subscription",Subsid); 
             console.log("Using vrfCordinator",vrfcordinator);
             console.log("With Chainid",block.chainid);

             if(block.chainid == LOCAL_CHAIN_ID){
                vm.startBroadcast();
                VRFCoordinatorV2_5Mock(vrfcordinator).fundSubscription(Subsid,FUND_AMOUNT * 100);
                vm.stopBroadcast();
             }

             else{
                vm.startBroadcast();
                LinkToken(linktoken).transferAndCall(vrfcordinator,FUND_AMOUNT,abi.encode(Subsid));
                vm.stopBroadcast();
             }

        }



    function run() public {
    FundSubscriptionbyconfig();
} 

}

contract AddConsumer is Script {

    function AddConsumerUsingconfig(address mostrecentdeployed) public {
        HelperConfig helperconfig = new HelperConfig();
        address vrfcordinator = helperconfig.getconfig().vrfCordinator;
        uint256 SubsId = helperconfig.getconfig().subscriptionid;

        addConsumer(mostrecentdeployed,SubsId,vrfcordinator);
    }

    function addConsumer(address mostrecent,uint256 subid,address vrfcordinator) public {
            console.log("Adding CONSUMER TO THE CONTRACT ",mostrecent);
            console.log("The Chain id is ",block.chainid);
            
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfcordinator).addConsumer(subid,mostrecent);
            vm.stopBroadcast();
    }


    function run () public {
        address mostrecent = DevOpsTools.get_most_recent_deployment("Raffle",block.chainid);
        AddConsumerUsingconfig(mostrecent);
    }
} 