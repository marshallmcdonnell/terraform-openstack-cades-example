
# args
NODE_COUNT="$1"
CERTS_DIR="$2"

# import functions
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/functions.sh"

# make certificates (and discovery key) directroy we will send to remotes
echo "Making directory for certificates and discovery key at ${CERTS_DIR}..."
rm -rf ${CERTS_DIR}
mkdir -p ${CERTS_DIR}

# discovery key for etcd nodes to discover eachother w/o pre-known IP addresses
echo "Creating discovery key..."
curl https://discovery.etcd.io/new?size=${NODE_COUNT} > ${CERTS_DIR}/discovery_key.txt

echo "Installing CFSSL..."
install_cfssl

echo "Creating self signed root cert..."
create_root_cert ${CERTS_DIR}

echo "Done!!!"
