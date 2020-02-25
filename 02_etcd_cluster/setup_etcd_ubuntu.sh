
export ETCD_RELEASE="3.3.18"
export ETCD_DIR="etcd-v${ETCD_RELEASE}-linux-amd64"


sudo apt -y install wget
wget https://github.com/etcd-io/etcd/releases/download/v${ETCD_RELEASE}/${ETCD_DIR}.tar.gz
tar xvf ${ETCD_DIR}.tar.gz
cd ${ETCD_DIR}
sudo mv etcd etcdctl /usr/local/bin 

cat > /etc/default/etcd <<EOF
ETCD_NAME="controller"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"
ETCD_INITIAL_CLUSTER="controller=http://10.0.0.11:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.0.0.11:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://10.0.0.11:2379"
ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"
ETCD_LISTEN_CLIENT_URLS="http://10.0.0.11:2379"
EOF

systemctl enable etcd
systemctl restart etcd
