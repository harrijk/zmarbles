#!/bin/bash

CHAN=$1

function display_msg() {
  MSG=$1
  echo ""
  echo "=================================================================="
  echo "   "$MSG
  echo "=================================================================="
  echo ""
}

function setorderer() {
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/orderer/localMspConfig
export CORE_PEER_LOCALMSPID="OrdererMSP"
}

function setpeer() {
NUM=$1
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer/peer${NUM}/localMspConfig
export CORE_PEER_ADDRESS=peer${NUM}:7051

if [ $1 -eq 1 -o $1 -eq 2 ] ; then
  export CORE_PEER_LOCALMSPID="Org1MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer/peer${NUM}/localMspConfig/cacerts/peerOrg1-cert.pem
else
  export CORE_PEER_LOCALMSPID="Org2MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer/peer${NUM}/localMspConfig/cacerts/peerOrg2-cert.pem
fi
}

# Create channel
setorderer
display_msg "Creating channel $CHAN"
peer channel create -o orderer0:7050 -c $CHAN -f ./crypto/orderer/channel.tx
if [ $? = 0 ]; then
  display_msg "Channel $CHAN was successfully created"
else
  display_msg "ERROR: Could not create channel $CHAN"
  exit 1
fi

# Join peers to channel
for i in 1 2 3 4
do
  setpeer $i
  display_msg "Joining peer$i to channel $CHAN"
  peer channel join -b ${CHAN}.block
  if [ $? = 0 ]; then
    display_msg "peer$i successfully joined channel $CHAN"
  else
    display_msg "ERROR: peer$i could not join channel $CHAN"
    exit 1
  fi
done

# Install and instantiate marbles chaincode on peer1
setpeer 1
display_msg "Installing marbles chaincode on peer1"
peer chaincode install -n marbles -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/marbles
if [ $? = 0 ]; then
  display_msg "Successfully installed marbles chaincode on peer1"
else
  display_msg "ERROR: could not install marbles chaincode on peer1"
  exit 1
fi

display_msg "Instantiating marbles chaincode on peer1"
peer chaincode instantiate -o orderer0:7050 -C $CHAN -n marbles -v 1.0 -c '{"Args":["init","1"]}' -P "OR ('Org1MSP.member','Org2MSP.member')"
if [ $? = 0 ]; then
  display_msg "Successfully instantiated marbles chaincode on peer1"
else
  display_msg "ERROR: could not instantiate marbles chaincode on peer1"
  exit 1
fi

# Install marbles chaincode on peer3 and invoke marbles chaincode transactions
setpeer 3
display_msg "Installing marbles chaincode on peer3"
peer chaincode install -n marbles -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/marbles
if [ $? = 0 ]; then
  display_msg "Successfully installed marbles chaincode on peer3"
else
  display_msg "ERROR: could not install marbles chaincode on peer3"
  exit 1
fi

sleep 5

display_msg "Invoke init_owner chaincode transaction on peer3"
peer chaincode invoke -C $CHAN -o orderer0:7050 -n marbles -c '{"Args":["init_owner","john","Marbles Inc"]}'
if [ $? = 0 ]; then
  display_msg "Successfully invoked init_owner transaction on peer3"
else
  display_msg "ERROR: could not invoke init_owner transaction on peer3"
  exit 1
fi

sleep 5

display_msg "Invoke init_marble chaincode transaction on peer3"
peer chaincode invoke -C $CHAN -o orderer0:7050 -n marbles -c '{"Args":["init_marble","mymarble","blue","35","john","Marbles Inc","Marbles Inc"]}'
if [ $? = 0 ]; then
  display_msg "Successfully invoked init_marble transaction on peer3"
else
  display_msg "ERROR: could not invoke init_marble transaction on peer3"
  exit 1
fi

display_msg "The marbles app config and setup have successfully completed"
display_msg "Press Ctrl-c if you are tailing the cli container log"
exit 0
