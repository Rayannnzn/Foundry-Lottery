//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";  
import {HelperConfig} from "./Helperconfig.s.sol";
import {CreateSubscription,FundSubscription,AddConsumer} from "./Interactions.s.sol";


contract DeployRaffle is Script {
    

    function run() public returns (Raffle){
       (Raffle raffle,) = DeployRafflee();
       return raffle;
    }



    function DeployRafflee() public returns(Raffle, HelperConfig){

        
        HelperConfig helperconfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperconfig.getconfig();

            // Create Subscription
        if(config.subscriptionid == 0){
            CreateSubscription createsubcription = new CreateSubscription();
            (config.subscriptionid,config.vrfCordinator) = createsubcription.createSubscription(config.vrfCordinator);
        }

        // Fund 
        FundSubscription fundsubscription = new FundSubscription();
        fundsubscription.fundSubscription(config.vrfCordinator,config.subscriptionid,config.link);


        // Local -> Deploy Mocks and Get Config
        // Sepolia -> get Sepolia Config
        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.entrancefee,
            config.interval,
            config.vrfCordinator,
            config.gasLane,
            config.subscriptionid,
            config.callgasLimit
        );
        vm.stopBroadcast();

        
            // ADD Consumer (Contract)
        AddConsumer addconsumer = new AddConsumer();
        // dont need to broadcast this !
        addconsumer.addConsumer(address(raffle),config.subscriptionid,config.vrfCordinator);

        return (raffle,helperconfig);



    } 




}