#!/bin/bash

install_ubuntu_prereqs() {
  echo -e "\n*** install_ubuntu_prereqs ***\n"
  PACKAGES="build-essential libtool git docker.io python-pip"
  apt -y install $PACKAGES
  echo -e "*** DONE ***\n"
}

# Install Nodejs
install_nodejs() {
  echo -e "\n*** install_nodejs ***\n"
  cd /tmp
  wget -q https://nodejs.org/dist/v6.9.5/node-v6.9.5-linux-s390x.tar.gz
  cd /usr/local && tar --strip-components 1 -xzf /tmp/node-v6.9.5-linux-s390x.tar.gz
  npm install gulp -g
  echo -e "*** DONE ***\n"
}


# Install the Golang compiler for the s390x platform
install_golang() {
  echo -e "\n*** install_golang ***\n"
  export GOROOT="/opt/go"
  cd /tmp
  wget --quiet --no-check-certificate https://storage.googleapis.com/golang/go1.7.3.linux-s390x.tar.gz
  tar -xvf go1.7.3.linux-s390x.tar.gz
  mv go /opt
  chmod 775 /opt/go
  rm -f /etc/profile.d/goroot.sh || :
  echo "export GOROOT=/opt/go" >> /etc/profile.d/goroot.sh
  echo "export PATH=$PATH:/opt/go/bin" >> /etc/profile.d/goroot.sh
  echo "export GOPATH=~/git" >> /etc/profile.d/goroot.sh
  echo -e "*** DONE ***\n"
}

install_docker_images() {
  echo -e "\n*** install_docker_images ***\n"
  for IMAGES in peer orderer couchdb ccenv javaenv kafka zookeeper ca; do
    echo "*** Pulling Fabric Image:  $IMAGES"
    echo
    docker pull hyperledger/fabric-$IMAGES:s390x-1.0.0-alpha
    docker tag hyperledger/fabric-$IMAGES:s390x-1.0.0-alpha hyperledger/fabric-$IMAGES
  done
  echo -e "*** DONE ***\n"
}

install_docker_compose() {
  echo -e "\n*** install_docker_compose ***\n"
  pip install -U pip
  pip install docker-compose
  echo -e "*** DONE ***\n"
}

install_ubuntu_prereqs
install_golang
install_nodejs
install_docker_images
install_docker_compose

echo "Fabric bootstrapping complete."
exit 0
