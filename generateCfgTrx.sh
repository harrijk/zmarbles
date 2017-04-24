#!/bin/bash

export PEER_CFG_PATH="`dirname $(realpath -s $0)`"
export GOPATH=""

CHANNEL_NAME=$1
if [ -z "$1" ]; then
	echo "Setting channel to default name 'mychannel'"
	CHANNEL_NAME="mychannel"
fi

echo "Channel name - "$CHANNEL_NAME
echo

echo "Generating genesis block"
./configtxgen -profile TwoOrgs -outputBlock orderer.block
mv orderer.block ./crypto/orderer/orderer.block

echo "Generating channel configuration transaction"
./configtxgen -profile TwoOrgs -outputCreateChannelTx channel.tx -channelID $CHANNEL_NAME
mv channel.tx ./crypto/orderer/channel.tx
