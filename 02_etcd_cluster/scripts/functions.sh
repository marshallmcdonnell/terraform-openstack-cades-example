# release versions
export ETCD_RELEASE="3.3.18"
export ETCD_DISCOVERY_FILE="discovery_key.txt"
export CFSSL_RELEASE="1.2"

# execs
export CFSSL="/tmp/cfssl"
export CFSSLJSON="/tmp/cfssljson"
export OPENSSL="openssl"

# functions (alphabetically sorted)
create_local_certs () {
    NAME="$1"
    IP="$2"
    CERTS_DIR="$3"

    CERTS_TMP_DIR="/tmp/certs"

    mkdir -p ${CERTS_TMP_DIR}
    ls -l ${CERTS_DIR}

    cat > ${CERTS_TMP_DIR}/${NAME}-ca-csr.json <<EOF
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

    ${CFSSL} gencert \
      --ca     ${CERTS_DIR}/etcd-root-ca.pem \
      --ca-key ${CERTS_DIR}/etcd-root-ca-key.pem \
      --config ${CERTS_DIR}/etcd-gencert.json \
      ${CERTS_TMP_DIR}/${NAME}-ca-csr.json | ${CFSSLJSON} --bare ${CERTS_DIR}/${NAME}

    # verify
    echo "Verify..."
    ${OPENSSL} x509 -in ${CERTS_DIR}/${NAME}.pem -text -noout
}

create_root_cert () {
    CERTS_DIR=$1

    CA_CERT="etcd-root-ca"
    CA_CERT_JSON="${CA_CERT}.json"
    CA_CERT_PEM="${CA_CERT}.pem"
    GENCERT_JSON="etcd-gencert.json"

    # Generate self-signed root CA cert
    cat > ${CERTS_DIR}/${CA_CERT_JSON} <<EOF
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
      "CN": "${CA_CERT}"
    }
EOF
    ${CFSSL} gencert --initca=true ${CERTS_DIR}/${CA_CERT_JSON} | ${CFSSLJSON} --bare ${CERTS_DIR}/${CA_CERT}

    # verify
    ${OPENSSL} x509 -in ${CERTS_DIR}/${CA_CERT_PEM} -text -noout

    # cert-generation configuration
    cat > ${CERTS_DIR}/${GENCERT_JSON} <<EOF
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

install_cfssl () {
  curl -L https://pkg.cfssl.org/R${CFSSL_RELEASE}/cfssl_linux-amd64 -o ${CFSSL}
  chmod +x ${CFSSL}

  curl -L https://pkg.cfssl.org/R${CFSSL_RELEASE}/cfssljson_linux-amd64 -o ${CFSSLJSON}
  chmod +x ${CFSSLJSON}

  ${CFSSL} version
  ${CFSSLJSON} -h

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

move_certs_from_dir_to_dir() {
  FROM_DIR=$1
  TO_DIR=$2

  mkdir -p ${TO_DIR}
  cp ${FROM_DIR}/* ${TO_DIR}
  ls -l ${TO_DIR}
}

start_etcd_using_discovery () {
  NAME="$1"
  IP="$2"
  DISCOVERY_URL="$3"
  CERTS_DIR="$4"

  echo "CERTS DIR: ${CERTS_DIR} ..."
  ls -l ${CERTS_DIR}

  etcd \
    --name                        ${NAME} \
    --initial-advertise-peer-urls https://${IP}:2380 \
    --listen-peer-urls            https://${IP}:2380 \
    --listen-client-urls          https://${IP}:2379,http://127.0.0.1:2379 \
    --advertise-client-urls       https://${IP}:2379 \
    --discovery                   ${DISCOVERY_URL} \
    --peer-client-cert-auth=true \
    --peer-trusted-ca-file        ${CERTS_DIR}/etcd-root-ca.pem \
    --peer-cert-file              ${CERTS_DIR}/${NAME}.pem \
    --peer-key-file               ${CERTS_DIR}/${NAME}-key.pem \
    --client-cert-auth \
    --trusted-ca-file             ${CERTS_DIR}/etcd-root-ca.pem \
    --cert-file                   ${CERTS_DIR}/${NAME}.pem \
    --key-file                    ${CERTS_DIR}/${NAME}-key.pem
}
