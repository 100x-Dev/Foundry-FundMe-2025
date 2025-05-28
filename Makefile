-include .env

build:; forge build

deploy-sepolia:
	forge script script/DeployFundMe.s.sol --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

deploy-anvil:
	forge script script/DeployFundMe.s.sol --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL) --broadcast


#interactions
fund-anvil:
	forge script script/Interactions.s.sol:FundFundMe --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL) --broadcast

fund-sepolia:
	forge script script/Interactions.s.sol:FundFundMe --rpc-url $(RPC_URL_ETHEREUM_SEPOLIA) --private-key $(PRIVATE_KEY) --broadcast

withdraw-anvil:
	forge script script/Interactions.s.sol:WithdrawFundMe --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL) --broadcast

withdraw-sepolia:
	forge script script/Interactions.s.sol:WithdrawFundMe --rpc-url $(RPC_URL_ETHEREUM_SEPOLIA) --private-key $(PRIVATE_KEY) --broadcast



# create a folder with coverage report in .html format
coverage-report:
	forge coverage --report lcov
	genhtml -o coverage_report --branch-coverage lcov.info

# testing
fork-test_mainnet-eth:
	forge test --fork-url $(MAINNET_RPC_URL)
