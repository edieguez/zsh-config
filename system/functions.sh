0x0() {
    if [ $# -lt 1 ]; then
        echo "Usage: 0x0 <file>"
        return 1
    fi

    echo "Uploading $1 to 0x0.st. Please wait..."
    curl -F "file=@$1" -Fsecret= https://0x0.st
}

docker() {
    systemctl status docker.service | grep 'active (running)' > /dev/null
    [ $? -ne 0 ] && sudo systemctl start docker.service

    /usr/bin/docker $@
}

google-translate() {
    trans en:es "$*"
}

# Load functions for local environment
source_if_exist "$ROOT_DIR/system/functions_local.sh"
