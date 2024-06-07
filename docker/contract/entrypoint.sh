#!/bin/sh
PASSWORD=passphrase

while ! [ -s /genesis_volume/genesis.json ]; do
  sleep 1
done

cp /genesis_volume/alice_mnemonic /root/alice_mnemonic
(cat /root/alice_mnemonic; echo "$PASSWORD"; echo "$PASSWORD") | nyxd keys add alice --recover

sleep 5

ALICE_ADDRESS=$(echo "$PASSWORD" | nyxd keys show alice -a)

(echo "$PASSWORD";sleep 3;yes) | nyxd tx wasm store /contract_volume/mixnet_contract.wasm  \
  --from=alice \
  --chain-id=nymtest-1 \
  --gas="auto" \
  --gas-adjustment=1.15 \
  --chain-id=nymtest-1 \
  --node=tcp://10.0.0.2:26657

sleep 5

(echo "$PASSWORD";sleep 3;yes) | nyxd tx wasm instantiate 1 \
  "{\"rewarding_validator_address\": \"$ALICE_ADDRESS\",\"vesting_contract_address\": \"$ALICE_ADDRESS\",\"rewarding_denom\": \"unym\",\"epochs_in_interval\": 720,\"epoch_duration\": {\"secs\": 3600,\"nanos\": 0},\"initial_rewarding_params\": {\"initial_reward_pool\": \"100000\",\"initial_staking_supply\": \"90000\",\"staking_supply_scale_factor\": \"1.0\",\"sybil_resistance\": \"0.3\",\"active_set_work_factor\": \"10\",\"interval_pool_emission\": \"0.02\",\"rewarded_set_size\": 240,\"active_set_size\": 240}}" \
  --admin="$ALICE_ADDRESS" \
  --from alice \
  --label "testcontract" \
  --gas="auto" \
  --gas-adjustment=1.15 \
  --amount="100000unym" \
  --chain-id=nymtest-1 \
  --node=tcp://10.0.0.2:26657