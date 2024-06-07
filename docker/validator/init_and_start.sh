#!/bin/sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root
PASSWORD=passphrase
cd /root

if [ "$1" = "genesis" ]; then
  if [ ! -f "/root/.nymd/config/genesis.json" ]; then

    # create testnet
    nyxd init test1 --chain-id nymtest-1

    # rename stake to unyx
    sed -i. "s/\"stake\"/\"unyx\"/" /root/.nyxd/config/genesis.json

    # create account alice + bob
    (echo "$PASSWORD"; echo "$PASSWORD") | nyxd keys add alice 2>&1 | tail -n 1 > /genesis_volume/alice_mnemonic
    (echo "$PASSWORD"; echo "$PASSWORD") | nyxd keys add bob 2>&1 | tail -n 1 > /genesis_volume/bob_mnemonic
    (echo "$PASSWORD"; echo "$PASSWORD") | nyxd keys add mix1 2>&1 | tail -n 1 > /genesis_volume/mix1_mnemonic

    # add alice + bob to the genesis accounts with some initial tokens
    echo "$PASSWORD" | nyxd genesis add-genesis-account alice 1000000000000000unym,1000000000000000unyx
    echo "$PASSWORD" | nyxd genesis add-genesis-account bob 1000000000000000unym,1000000000000000unyx

    # make alice + bob a proper validator
    echo "$PASSWORD" | nyxd genesis gentx alice 1000000000unyx --chain-id nymtest-1
    nyxd genesis collect-gentxs
    nyxd genesis validate-genesis

    # copy genesis file for bob
    cp /root/.nyxd/config/genesis.json /genesis_volume/genesis.json
  else
    echo "Validator already initialized, starting with the existing configuration."
    echo "If you want to re-init the validator, destroy the existing container"
	fi
	nyxd start --rpc.laddr tcp://0.0.0.0:26657 --api.enable --api.address tcp://0.0.0.0:1317 --log_level=info --trace
elif [ "$1" = "secondary" ]; then
  if [ ! -f "/root/.nymd/config/genesis.json" ]; then
    
    nyxd init test2 --chain-id nymtest-1

    # Wait until the genesis node writes the genesis.json to the shared volume
    while ! [ -s /genesis_volume/genesis.json ]; do
      sleep 1
    done

    # just don't ask
    sleep 5

    # copy genesis + bob mnemonic
    cp /genesis_volume/genesis.json /root/.nyxd/config/genesis.json
    cp /genesis_volume/bob_mnemonic /root/.nyxd/bob_mnemonic
    (cat /root/.nyxd/bob_mnemonic; echo "$PASSWORD"; echo "$PASSWORD") | nyxd keys add bob --recover

    # insert Peer into config
    GENESIS_PEER=$(cat /root/.nyxd/config/genesis.json | grep '"memo"' | cut -d'"' -f 4)
    sed -i 's/persistent_peers = ""/persistent_peers = "'"${GENESIS_PEER}"'"/' /root/.nyxd/config/config.toml

    # Create validator
    (echo "$PASSWORD";sleep 3;yes) | nyxd tx staking create-validator \
      --amount=1000000000unyx \
      --pubkey=$(nyxd tendermint show-validator) \
      --moniker=bob \
      --chain-id=nymtest-1 \
      --commission-rate="0.10" \
      --commission-max-rate="0.20" \
      --commission-max-change-rate="0.01" \
      --min-self-delegation="1" \
      --gas="auto" \
      --gas-adjustment=1.15 \
      --gas-prices="0.0025unyx" \
      --from=bob \
      --node=tcp://10.0.0.2:26657
    sleep 3
  else
    echo "Validator already initialized, starting with the existing configuration."
    echo "If you want to re-init the validator, destroy the existing container"
  fi
	nyxd start
else
	echo "Wrong command. Usage: ./$0 [genesis/secondary]"
fi
