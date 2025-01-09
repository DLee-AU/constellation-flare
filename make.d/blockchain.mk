#!/usr/bin/env make

# SHELL := /bin/sh -x

# define code_check
# 	$(call log_success,"Code Check $(1)"); \
# 	params='["$(1)","latest"]'; \
# 	printf "Params: %s\n" "$$params"
# endef

define code_check
	$(call log_info,"Params: $(1)")
	$(call log_success,"Code Check $(1)"); \
	addr="$(1)"; \
	params="[\"$$addr\",\"latest\"]"; \
	$(call log_info,"Params: $$params")
endef

# Generalized JSON-RPC call function with error handling
define rpc_call
$(QUIET)if [ -f .env ]; then \
	set -a; \
	. ./.env; \
	set +a; \
	set +x; \
	response=$$(curl -s -u "$$RPC_USER:$$RPC_PASSWORD" \
		--data '{"jsonrpc":"2.0","id":"1","method":"$(1)","params":$(2)}' \
		-H 'Content-Type: application/json;' \
		$$RPC_URL/$(3)); \
	echo "$$response" | jq . > /dev/null 2>&1 || { \
		echo "Invalid JSON response: $$response" >&2; \
		exit 1; \
	}; \
	if echo "$$response" | jq -e '.error' > /dev/null 2>&1; then \
		echo "$$response" | jq -r '.error.message' >&2; \
		exit 1; \
	else \
		echo "$$response" | jq .; \
	fi; \
fi
endef

.PHONY: generate-eth-password
generate-eth-password:
	$(QUIET)if [ "$(FORCE)" = "true" ] || [ ! -f ./jwt.hex ]; then \
		rm -f ./jwt.hex; \
		$(call log_info,"Creating/Regenerating Password for ${COMPONENT_NAME} resources..."); \
		openssl rand -hex 32 > ./jwt.hex; \
		$(call log_info,"JWT password file created/regenerated at ./jwt.hex"); \
	else \
		$(call log_warn,"JWT password file already exists. Use FORCE=true to regenerate."); \
	fi

.PHONY: generate-btc-password
generate-btc-password:
	$(QUIET)if [ "$(FORCE)" = "true" ] || [ ! -f ./btc_credentials.txt ]; then \
		rm -f ./btc_credentials.txt; \
		# Remove lines containing #rpcauth and rpcauth=, including any blank lines that follow \
		sed -i '/#rpcauth/d;/^$$/d' ./bitcoin.conf; \
		sed -i '/rpcauth=/d;/^$$/d' ./bitcoin.conf; \
		$(call log_info,"Creating/Regenerating Password for ${COMPONENT_NAME} resources..."); \
		password=$$(openssl rand -hex 32); \
		printf "Generated Password: %s\n" "$$password"; \
		./rpcauth.py admin "$$password" > ./btc_credentials.txt; \
		$(call log_info,"BTC password file created/regenerated at ./btc_credentials.txt"); \
	else \
		$(call log_warn,"BTC password file already exists. Use FORCE=true to regenerate."); \
	fi

.PHONY: generate-doge-password
generate-doge-password:
	$(QUIET)if [ "$(FORCE)" = "true" ] || [ ! -f ./doge_credentials.txt ]; then \
		rm -f ./doge_credentials.txt; \
		# Remove lines containing #rpcauth and rpcauth=, including any blank lines that follow \
		sed -i '/#rpcauth/d;/^$$/d' ./dogecoin.conf; \
		sed -i '/rpcauth=/d;/^$$/d' ./dogecoin.conf; \
		$(call log_info,"Creating/Regenerating Password for ${COMPONENT_NAME} resources..."); \
		password=$$(openssl rand -hex 32); \
		printf "Generated Password: %s\n" "$$password"; \
		./rpcauth.py admin "$$password" > ./doge_credentials.txt; \
		$(call log_info,"DOGE password file created/regenerated at ./doge_credentials.txt"); \
	else \
		$(call log_warn,"DOGE password file already exists. Use FORCE=true to regenerate."); \
	fi

# Blockchain Calls
# Base target to ensure RPC configuration is loaded
.check-rpc-config:
	@$(call log_info,"check-rpc-config")
	$(QUIET)if [ -f .env ]; then \
		set -a; \
		. ./.env; \
		set +a; \
		if [ -z "$$RPC_USER" ] || [ -z "$$RPC_PASSWORD" ] || [ -z "$$RPC_URL" ]; then \
			$(call log_error,"Missing RPC configuration in .env file"); \
			exit 1; \
		fi \
	else \
		$(call log_error,".env file not found"); \
		exit 1; \
	fi

# Target for info.getBlockchainID
.info-get-isbootstrapped: .check-rpc-config
	@$(call log_info,"Fetching Bootstrap for chain C")
	@$(call rpc_call,info.isBootstrapped,'{"\"chain\"":"\"C\""}',ext/info) | jq .result.isBootstrapped
	@$(call log_info,"Fetching Bootstrap for chain X")
	@$(call rpc_call,info.isBootstrapped,'{"\"chain\"":"\"X\""}',ext/info) | jq .result.isBootstrapped
	@$(call log_info,"Fetching Bootstrap for chain P")
	@$(call rpc_call,info.isBootstrapped,'{"\"chain\"":"\"P\""}',ext/info) | jq .result.isBootstrapped

# Target for info.getNetworkID
.info-get-network-id: .check-rpc-config
	@$(call log_info,"Fetching Network ID")
	@$(call rpc_call,info.getNetworkID,'{}',ext/info) | jq .result.networkID

# Target for info.getNetworkName
.info-get-network-name: .check-rpc-config
	@$(call log_info,"Fetching Network Name")
	@$(call rpc_call,info.getNetworkName,'{}',ext/info) | jq .result.networkName

# Target for ext/admin example
.info-get-node-ip: .check-rpc-config
	@$(call log_info,"Fetching NODE IP")
	@$(call rpc_call,info.getNodeIP,'{}',ext/info) | jq .result.ip

# Target for ext/admin example
.info-get-node-id: .check-rpc-config
	@$(call log_info,"Fetching NODE IP")
	@$(call rpc_call,info.getNodeID,'{}',ext/info) | jq .result.nodeID

# Target for ext/admin example
.info-get-node-version: .check-rpc-config
	@$(call log_info,"Fetching NODE Version")
	@$(call rpc_call,info.getNodeVersion,'{}',ext/info) | jq .result

# Target for ext/admin example
.info-get-peers: .check-rpc-config
	@$(call log_info,"Fetching Peers")
# @$(call rpc_call,info.peers,'{}',ext/info) | jq -r '.result.peers[]'
	@printf "IP Address\t\tNode ID\t\t\t\t\t\tVersion\t\tLast Sent\t\tLast Received\n"
	@$(call rpc_call,info.peers,'{}',ext/info) | jq -r '.result.peers[] | "\(.ip)\t\(.nodeID)\t\(.version)\t\(.lastSent)\t\(.lastReceived)"'

# Include common logging and RPC call functions here if not already included
# e.g., define call log_info, log_error, and rpc_call

# # Target: Fetch the latest block number
latest-block-number: .check-rpc-config
	@$(call log_info,"Fetching the latest block number")
	@$(call rpc_call,eth_blockNumber,'[]',ext/bc/C/rpc) | jq -r '.result' | xargs printf "Latest Block: %d\n"

# Target: Fetch the latest block details
latest-block-details:
	@$(call log_info,"Fetching the latest block details")
	@params='["latest", true]'; \
	$(call rpc_call,eth_getBlockByNumber,$$params,ext/bc/C/rpc)

# Target: Check syncing status
syncing-status:
	@$(call log_info,"Checking syncing status")
	@$(call rpc_call,eth_syncing,'{}',ext/bc/C/rpc) | jq '.result'

# Target: Get gas price
gas-price:
	@$(call log_info,"Fetching the gas price") && \
	$(call rpc_call,eth_gasPrice,'{}',ext/bc/C/rpc) | jq -r '.result | "Gas Price: $((16#\(.))) wei"'

# Target: Get chain ID
chain-id:
	@$(call log_info,"Fetching chain ID") && \
	$(call rpc_call,eth_chainId,'{}',ext/bc/C/rpc) | jq -r '.result | "Chain ID: $((16#\(.)))"'

# Target: Get accounts
eth-accounts:
	@$(call log_info,"Fetching Ethereum accounts") && \
	$(call rpc_call,eth_accounts,'{}',ext/bc/C/rpc) | jq '.result[]'

# Target: Get network version
network-version:
	@$(call log_info,"Fetching network version") && \
	$(call rpc_call,net_version,'{}',ext/bc/C/rpc) | jq -r '.result | "Network Version: \(.))"'

# Target: Get peer count
peer-count:
	@$(call log_info,"Fetching peer count") && \
	$(call rpc_call,net_peerCount,'{}',ext/bc/C/rpc) | jq -r '.result | "Peer Count: $((16#\(.)))"'

# Target: Get block transaction count by block number
block-tx-count:
	@$(call log_info,"Fetching transaction count for block number") && \
	block_number=latest && \
	$(call rpc_call,eth_getBlockTransactionCountByNumber,"{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"eth_getBlockTransactionCountByNumber\",\"params\":[\"$$block_number\"]}",ext/bc/C/rpc) | jq -r '.result | "Transaction Count: $((16#\(.)))"'

# health_status=$$(echo "$$response" | jq -r '.result.healthy');
## Hit the RPC using variables from the .env file
test-rpc-node-evm: .info-get-network-name .info-get-network-id .info-get-node-id .info-get-node-ip .info-get-node-version .info-get-isbootstrapped .info-get-peers
	@$(call log_info, "Running target: $@ from directory: $(CURDIR)")
	@$(call log_info,"Testing connection to RPC(EVM): $$RPC_URL - Completed")


# Check balances for all specified addresses
balances: .check-rpc-config
	$(QUIET)if [ -f .env ]; then \
		set -a; \
		. ./.env; \
		set +a; \
		set +x; \
		$(call log_info,"Checking Wallet Balances: $${WALLET_ADDRESSES}"); \
	fi; \
	IFS=','; for addr in $${WALLET_ADDRESSES}; do \
		$(call check_single_balance,$$addr); \
	done

# Check balance for specific addresses (allows overriding WALLET_ADDRESSES)
# balance:
# 	@$(call log_info,"Checking Wallet Balances: $(WALLET_ADDRESSES)")
# 	@for addr in $(WALLET_ADDRESSES) ; do \
# 		printf "Hello\n": \
# 	done

balance:
	@$(call log_info,"Checking Wallet Balances: $(WALLET_ADDRESSES)")
	@for number in $(WALLET_ADDRESSES) ; do \
		echo $$number ; \
		printf "Hello\n"; \
		$(call code_check,$$number); \
	done

# @params='["$(1)", "latest"]'; \
# printf "Params: $$params\n";

# Check balance for a single address
# define check_single_balance
# 	$(call log_info,"Checking balance for $(1)"); \
# 	addr="$(1)"; \
# 	params="[\"$$addr\",\"latest\"]"; \
# 	printf "Params: %s\n" "$$params"; \
# 	$(call rpc_call,eth_getBalance,$$params,eth) | \
# 		jq -r '.result' | \
# 		xargs -I {} sh -c 'echo "Balance for $(1): $$(echo "obase=10; ibase=16; $(shell echo {} | sed 's/^0x//')" | bc) Wei"' | \
# 		xargs -I {} sh -c 'echo "Balance for $(1): $$(echo "scale=18; $${1}/1000000000000000000" | bc) ETH"' {}
# endef

define check_single_balance
	$(call log_info,"Checking balance for $(1)"); \
	addr="$(1)"; \
	params="[\"$$addr\",\"latest\"]"; \
	printf "Params: %s\n" "$$params"; \
	$(call code_check,$$params)
endef
