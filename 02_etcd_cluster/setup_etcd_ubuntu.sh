# Install cfssl
rm -f /tmp/cfssl* && rm -rf /tmp/certs && mkdir -p /tmp/certs

curl -L https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -o /tmp/cfssl
chmod +x /tmp/cfssl
sudo mv /tmp/cfssl /usr/local/bin/cfssl

curl -L https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -o /tmp/cfssljson
chmod +x /tmp/cfssljson
sudo mv /tmp/cfssljson /usr/local/bin/cfssljson

/usr/local/bin/cfssl version
/usr/local/bin/cfssljson -h

mkdir -p /tmp/certs

# Generate self-signed cert
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

# Install Etcd
export ETCD_RELEASE="3.3.18"
export ETCD_DIR="etcd-v${ETCD_RELEASE}-linux-amd64"


sudo apt -y install wget
wget https://github.com/etcd-io/etcd/releases/download/v${ETCD_RELEASE}/${ETCD_DIR}.tar.gz
tar xvf ${ETCD_DIR}.tar.gz
cd ${ETCD_DIR}
sudo mv etcd etcdctl /usr/local/bin 
