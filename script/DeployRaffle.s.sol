// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployRaffle is Script {
    function run() external {
        vm.startBroadcast();
        // --- IGNORE ---
        vm.stopBroadcast();
    }

    function deployContract() public returns(Raffle, HelperConfig){
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        //local => deploy mocks
        //Seplolia => get seplolia config

        vm.startBroadcast();
        // Deploy the Raffle contract with the configuration
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit
        );
        vm.stopBroadcast();
        return (raffle, helperConfig);
    }

}