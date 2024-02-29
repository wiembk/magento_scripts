# magento_scripts
all scripts that you can use within magento



# TO MAKE WAMIA COMMAND TAKE YOU TO MAGENTO MATH WHEN YOU RUN IT 
nano ~/.bashrc

function wamia() {
    cd /bitnami/magento
    /usr/local/bin/wamia "$@"
}

source ~/.bashrc
 # 