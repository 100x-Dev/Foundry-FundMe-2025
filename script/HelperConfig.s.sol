//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

//1. Deploy mocks when we are on a local anvil chain
//2. keep track of contract address across different address chains
// Seploia ETH/USD HAS DIIFERENT ADDRESS
//Mainnet  ETH/USD HAS DIIFERENT ADDRESS

contract HelperConfig is Script {
    //If we are on a local anvil, we deploy mocks
    //Otherwise , grab the existinng addrress from live network

    NetworkConfig public activeNetworkConfig;

    uint8 public constant Decimals = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
           address priceFeed; //ETH/USD price feed
    }

    constructor() {
        if (block.chainid == 11155111) {
            //11155111 is the chainid of sepolia
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
        NetworkConfig memory MainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return MainnetConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        
        //Deploy the mocks from here itself
        //Return the mock address

        vm.startBroadcast();

        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(Decimals, INITIAL_PRICE);

        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
