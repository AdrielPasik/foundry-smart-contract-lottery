//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

uint256 constant LOCAL_CHAIN_ID = 31337;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2_5Mock} from
    "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

abstract contract CodeConstants {
    /* VRF Mock Values */
    uint256 public MOCK_BASE_FEE = 0.25 ether;
    uint256 public MOCK_GAS_PRICE_LINK = 1e9; // 0.
    //LINK / ETH price
    int256 public MOCK_WEI_PER_UINT_LINK = 4e15; // 0.004 LINK per ETH
    // Alias para compatibilidad con código que podría usar el otro nombre
    int256 public MOCK_WEI_PER_UNIT_LINK = 4e15;

    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
}

contract HelperConfig is CodeConstants, Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
        address link;
        address account;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 => NetworkConfig) public networkConfig;

    constructor() {
        networkConfig[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getConfigByCHainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (networkConfig[chainId].vrfCoordinator != address(0)) {
            return networkConfig[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByCHainId(block.chainid);
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B, // <-- Checksum corregido
            gasLane: 0xe9f223d7d83ec85c4f78042a4845af3a1c8df7757b4997b815ce4b8d07aca68c,
            subscriptionId: 16167634609565561491100488804143546983072294655768501533415360843733013476434,
            callbackGasLimit: 500000,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            account: address(0)
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.vrfCoordinator != address(0)) {
            return localNetworkConfig;
        }

        // Crear los mocks
        VRFCoordinatorV2_5Mock vrfCoordinator = new VRFCoordinatorV2_5Mock(
            uint96(MOCK_BASE_FEE),
            uint96(MOCK_GAS_PRICE_LINK),
            MOCK_WEI_PER_UINT_LINK  // <-- Cambiado de MOCK_WEI_PER_UNIT_LINK a MOCK_WEI_PER_UINT_LINK
        );
        LinkToken linkToken = new LinkToken();

        // Crear y fondear la suscripción para el mock
        uint256 subId = vrfCoordinator.createSubscription();
        // Fondear directamente (IMPORTANTE - esto es lo que falta en el CI)
        vrfCoordinator.fundSubscription(subId, 100 ether);

        // Configuración local
        localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinator),
            gasLane: 0xe9f223d7d83ec85c4f78042a4845af3a1c8df7757b4997b815ce4b8d07aca68c,
            subscriptionId: subId,
            callbackGasLimit: 500000,
            link: address(linkToken),
            account: address(this)
        });

        return localNetworkConfig;
    }
}
