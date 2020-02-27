# variables
export NODE_NAME="$1"
export NODE_IP_ADDRESS="$2"

export CFSSL_RELEASE="1.2"

export ETCD_RELEASE="3.3.18"
export ETCD_DISCOVERY_FILE="discovery_key.txt"

# functions
install_cfssl () {
    rm -f /tmp/cfssl* && rm -rf /tmp/certs && mkdir -p /tmp/certs

    curl -L https://pkg.cfssl.org/R${CFSSL_RELEASE}/cfssl_linux-amd64 -o /tmp/cfssl
    chmod +x /tmp/cfssl
    sudo mv /tmp/cfssl /usr/local/bin/cfssl

    curl -L https://pkg.cfssl.org/R${CFSSL_RELEASE}/cfssljson_linux-amd64 -o /tmp/cfssljson
    chmod +x /tmp/cfssljson
    sudo mv /tmp/cfssljson /usr/local/bin/cfssljson

    /usr/local/bin/cfssl version
    /usr/local/bin/cfssljson -h

    mkdir -p /tmp/certs
}

create_self_signed_root_cert () {
    # Generate self-signed root CA cert
    cat > /tmp/certs/etcd-root-ca-csr.json <<EOF
    {
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "O": "ORNL",
          "OU": "RSE",
          "L": "Oak Ridge",
          "ST": "Tennessee",
          "C": "USA"
        }
      ],
      "CN": "etcd-root-ca"
    }
EOF
    cfssl gencert --initca=true /tmp/certs/etcd-root-ca-csr.json | cfssljson --bare /tmp/certs/etcd-root-ca

    # verify
    openssl x509 -in /tmp/certs/etcd-root-ca.pem -text -noout

    # cert-generation configuration
    cat > /tmp/certs/etcd-gencert.json <<EOF
    {
      "signing": {
        "default": {
            "usages": [
              "signing",
              "key encipherment",
              "server auth",
              "client auth"
            ],
            "expiry": "87600h"
        }
      }
    }
EOF
}


create_local_certs () {
    NAME="$1"
    IP="$2"
    mkdir -p /tmp/certs

    cat > /tmp/certs/${NAME}-ca-csr.json <<EOF
    {
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "O": "ORNL",
          "OU": "RSE",
          "L": "Oak Ridge",
          "ST": "Tennessee",
          "C": "USA"
        }
      ],
      "CN": "${NAME}",
      "hosts": [
        "127.0.0.1",
        "localhost",
        "${IP}"
      ]
    }
EOF

    cfssl gencert \
      --ca /tmp/certs/etcd-root-ca.pem \
      --ca-key /tmp/certs/etcd-root-ca-key.pem \
      --config /tmp/certs/etcd-gencert.json \
      /tmp/certs/${NAME}-ca-csr.json | cfssljson --bare /tmp/certs/${NAME}

    # verify
    openssl x509 -in /tmp/certs/${NAME}.pem -text -noout
}

move_certs_to_home () {
  mkdir -p ${HOME}/certs
  cp /tmp/certs/* ${HOME}/certs
  ls -l $HOME/certs
}

install_etcd () {
    export ETCD_DIR="etcd-v${ETCD_RELEASE}-linux-amd64"
    export ETCD_DOWLOAD_URL="https://github.com/etcd-io/etcd/releases/download"
    export ETCD_TAR=${ETCD_DIR}.tar.gz

    curl -L ${ETCD_DOWLOAD_URL}/v${ETCD_RELEASE}/${ETCD_TAR} -o /tmp/${ETCD_TAR}
    tar xvzf /tmp/${ETCD_TAR}
    sudo cp ${ETCD_DIR}/etcd* /usr/local/bin 

    # verify
    etcd --version
    ETCDCTL_API=3 etcdctl version
}

start_etcd_using_discovery () {
  NAME="$1"
  IP="$2"
  DISCOVERY_URL="$3"

  etcd \
    --name ${NAME} \
    --data-dir /tmp/etcd/${NAME} \
    --listen-client-urls https://${IP}:2379 \
    --advertise-client-urls https://${IP}:2379 \
    --listen-peer-urls https://${IP}:2380 \
    --initial-advertise-peer-urls https://${IP}:2380 \
    --initial-cluster-state new \
    --discovery ${DISCOVERY_URL} \
    --client-cert-auth \
    --trusted-ca-file ${HOME}/certs/etcd-root-ca.pem \
    --cert-file ${HOME}/certs/${NAME}.pem \
    --key-file ${HOME}/certs/${NAME}-key.pem \
    --peer-client-cert-auth \
    --peer-trusted-ca-file ${HOME}/certs/etcd-root-ca.pem \
    --peer-cert-file ${HOME}/certs/${NAME}.pem \
    --peer-key-file ${HOME}/certs/${NAME}-key.pem
}


# main
echo "Installing CFSSL..."
install_cfssl

echo "Creating self signed root cert..."
create_self_signed_root_cert

echo "Creating local-issued certs..."
create_local_certs ${NODE_NAME} ${NODE_IP_ADDRESS}

echo "Move certs to home directory..."
move_certs_to_home 

echo "Installing etcd..."
install_etcd

echo "Discover key..."
DISCOVERY_KEY=$(cat discovery_key.txt)
echo ${DISCOVERY_KEY}

echo "Starting up etcd cluster..."
start_etcd_using_discovery ${NODE_NAME} ${NODE_IP_ADDRESS} ${DISCOVERY_KEY}

echo "Done!!!"
