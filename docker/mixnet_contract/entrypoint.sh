tail -f /dev/null
cd nym/contracts/mixnet
rustup target add wasm32-unknown-unknown
RUSTFLAGS='-C link-arg=-s' cargo wasm
cp /nym/contracts/target/wasm32-unknown-unknown/release/mixnet_contract.wasm /contract_volume