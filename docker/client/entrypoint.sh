#!/bin/sh
while ! [ -f "/bin_volume/nym-client" ] || ! [ -s "/nyx_volume/mixnet_contract_address" ] || ! [ -s "/nyx_volume/vesting_contract_address" ]; do
  sleep 1
done

until curl --output /dev/null --silent --head --fail http://10.0.0.99/v1/api-status/health; do
  echo "Waiting for nym API..."
  sleep 10
done

while [ "$(curl -s http://10.0.0.99/v1/mixnodes/active)" = "[]" ]; do
    echo "Waiting for Mixnodes to be selected..."
    sleep 20
done

if [ ! -f "/root/nym-node" ]; then
  cp /bin_volume/nym-client /root/
  /root/nym-client init --id $CLIENT_NAME --nym-apis http://10.0.0.99
fi

/root/nym-client run --id $CLIENT_NAME