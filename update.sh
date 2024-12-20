#!/bin/bash
# DESCRIPTION: Refreshes magento in one command , you can use --s tag to make it with maintenance mode or --f to make it faster by stopping the Apache.
# It performs a specific task or operation.

# cd /var/www/html/magento2
if [ "$1" == "--s" ]
then
    while true; do
        echo "Running in safe mode..."
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
                bin/magento maintenance:enable
                bin/magento setup:upgrade
                bin/magento maintenance:disable
                ;;
            2)
                echo -e "\e[32mRunning: bin/magento setup:di:compile\e[0m"
                bin/magento maintenance:enable
                bin/magento setup:di:compile
                bin/magento maintenance:disable
                ;;
            3)
                echo -e "\e[32mRunning: bin/magento clean\e[0m"
                bin/magento cache:clean
                bin/magento cache:flush
                ;;
            4)
                echo -e "\e[32mRunning: bin/magento indexer:reindex\e[0m"
                bin/magento indexer:reindex
                ;;
            5)
                echo -e "\e[32mRunning all commands\e[0m"
                bin/magento maintenance:enable
                bin/magento setup:upgrade
                bin/magento setup:di:compile
                bin/magento s:s:d -f
                bin/magento cache:clean
                bin/magento cache:flush
                bin/magento maintenance:disable
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
elif [ "$1" == "--f" ]; then
    while true; do
        echo "Running in fast mode..."
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
                sudo gonit stop apache
                bin/magento setup:upgrade
                sudo gonit start apache
                ;;
            2)
                echo -e "\e[32mRunning: bin/magento setup:di:compile\e[0m"
                sudo gonit stop apache
                bin/magento setup:di:compile
                sudo gonit start apache
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
                sudo gonit stop apache
                bin/magento setup:upgrade
                bin/magento setup:di:compile
                bin/magento s:s:d -f
                bin/magento cache:clean
                bin/magento cache:flush
                sudo gonit start apache
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
else
    echo -e "\e[31mInvalid argument. Please use \e[0m--s\e[31m or \e[0m--f\e[31m.\e[0m"
fi