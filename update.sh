#!/bin/bash


cd /var/www/html/magento2

while true; do
    echo "Choose a Magento command to run:"
    echo -e "\e[32m1: Update\e[0m"
    echo -e "\e[32m2: Di:compile\e[0m"
    echo -e "\e[32m3: Clean\e[0m"
    echo -e "\e[32m4: Reindex\e[0m"
    echo -e "\e[32m5: All\e[0m"
    echo -e "\e[32m6: exit\e[0m"

    read -p "Enter your choice (1-6):  " choice

    case $choice in
        1)
            echo -e "\e[32mRunning: bin/magento setup:upgrade\e[0m"
            bin/magento setup:upgrade
            ;;
        2)
            echo -e "\e[32mRunning: bin/magento setup:di:compile\e[0m"
            bin/magento setup:di:compile
            ;;
        3)
            echo -e "\e[32mRunning: bin/magento clean"\e[0m
            bin/magento cache:clean
            bin/magento cache:flush
            ;;
        4)
            echo -e "\e[32mRunning: bin/magento indexer:reindex\e[0m"
            bin/magento indexer:reindex
            ;;
        5)
            echo -e "\e[32mRunning all commands\e[0m"
            bin/magento setup:upgrade
            bin/magento setup:di:compile
            bin/magento cache:clean
            bin/magento cache:flush
            bin/magento indexer:reindex
            ;;
        6)
            echo -e "\e[32mExiting script.\e[0m"
            exit 0
            ;;
        *)
            echo -e "\e[32mInvalid choice. Please enter a number between 1 and 6.\e[0m"
            ;;
    esac
done

