// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LazySanta} from "../src/LazySanta.sol";

contract DeployLazySanta is Script {
    function run() external returns (LazySanta) {
        vm.startBroadcast();
        LazySanta lazySanta = new LazySanta(msg.sender);
        vm.stopBroadcast;
        return lazySanta;
    }
}
