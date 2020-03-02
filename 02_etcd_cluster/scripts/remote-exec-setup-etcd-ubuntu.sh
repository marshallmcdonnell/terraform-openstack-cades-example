# args
NODE_NAME=$1
NODE_IP_ADDRESS=$2

# variables
CERTS_TMP_DIR="/tmp/certs"
CERTS_DIR="${HOME}/certs"

# import functions
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/functions.sh"

# certificates for TLS
echo "Installing CFSSL..."
install_cfssl

echo "Creating local-issued certs..."
create_local_certs ${NODE_NAME} ${NODE_IP_ADDRESS} ${CERTS_DIR}

echo "Move certs from ${CERTS_TMP_DIR} to ${CERTS_DIR} directory..."
move_certs_from_dir_to_dir ${CERTS_TMP_DIR} ${CERTS_DIR}

# etcd setup
echo "Installing etcd..."
install_etcd

echo "Discover key..."
DISCOVERY_KEY=$(cat ${CERTS_DIR}/discovery_key.txt)
echo ${DISCOVERY_KEY}

echo "Starting up etcd cluster..."
start_etcd_using_discovery ${NODE_NAME} ${NODE_IP_ADDRESS} ${DISCOVERY_KEY} ${CERTS_DIR}

echo "Done!!!"
