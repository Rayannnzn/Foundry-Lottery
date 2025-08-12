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


import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

error HelperConfigNotSupported();

abstract contract CodeConstants {
    uint96 public constant MOCK_BASE_FEE = 0.25 ether;
    uint96 public constant MOCK_GAS_PRICE_LINK = 1e9;
    // LINK / ETH price
    int256 public constant MOCK_WEI_PER_UINT_LINK = 4e15;
    address public constant FOUNDRY_DEFAULT_SENDER = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
    uint256 public constant FUND_AMOUNT = 3 ether;
}


contract HelperConfig is Script,CodeConstants{ 

    struct NetworkConfig {
        uint256 entrancefee;
        uint256 interval;
        address vrfCordinator;
        bytes32 gasLane;
        uint256 subscriptionid;
        uint32 callgasLimit;
        address link;
    }


        // State Variables 
    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainid => NetworkConfig) public networkconfigs;




    constructor(){
        networkconfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliEthConfig();
    }


    function getConfigbyChainid(uint256 chainid) public returns(NetworkConfig memory){
        if(networkconfigs[chainid].vrfCordinator != address(0)){
            return networkconfigs[chainid];
        }
        else if(chainid == LOCAL_CHAIN_ID){
            return getorCreateAnvilConfig();
        }
        else{
            revert HelperConfigNotSupported();
        }
    }

    function getconfig() public returns (NetworkConfig memory){
        return getConfigbyChainid(block.chainid);
    }


    function getorCreateAnvilConfig() public returns (NetworkConfig memory){
        // Check To see if we have a networkconfig
        if(localNetworkConfig.vrfCordinator != address(0)){
            return localNetworkConfig;
        }
        // Deploy Mocks and Get address
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorV2_5Mock = new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE,MOCK_GAS_PRICE_LINK,MOCK_WEI_PER_UINT_LINK);
        LinkToken linktoken = new LinkToken();
        vm.stopBroadcast();

            localNetworkConfig = NetworkConfig({

            entrancefee: 0.01 ether, //1e18
            interval: 30, //30 Seconds
            vrfCordinator: address(vrfCoordinatorV2_5Mock),
            //This Does'nt Matter Much
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionid: 0, // Might have to Fix This !
            callgasLimit: 500000,
            link: address(linktoken)
            });

            return localNetworkConfig;

    }




    function getSepoliEthConfig() public pure returns (NetworkConfig memory){

            return NetworkConfig({
                    entrancefee: 0.01 ether, //1e18
                    interval: 30, //30 Seconds
/* chainlink (VRF)*/vrfCordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
/* (keyhash)*/      gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                    subscriptionid: 78035589039525028327036872746149425565996519304551076304124521820463216685047,
                    callgasLimit: 500000,
/*(Link Token)*/    link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
            });
    }



}











