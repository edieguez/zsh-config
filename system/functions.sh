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
