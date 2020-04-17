#! /bin/bash
#Styling my Inputs
ansi()          { echo -e "\e[${1}m${*:2}\e[0m"; }
bold()          { ansi 1 "$@"; }
italic()        { ansi 3 "$@"; }
underline()     { ansi 4 "$@"; }
strikethrough() { ansi 9 "$@"; }
red()           { ansi 31 "$@"; }

# Validate the User Input
check_userInput()
{
    if [[ -z "$userInput" ]];
    then
        printf '%s\n' "No input entered"
        exit 1
    else
        printf "You entered %s "  "$userInput"
        printf '%s\n'
    fi

}

# Get the AppDynamics Environment Details from user 
read -p "Please enter BRAND_ENVIRONMENT :" userInput;
check_userInput
BRAND_ENVIRONMENT=$userInput

read -p "Please enter APPLICATION NAME :" userInput;
check_userInput
APPLICATION_NAME=$userInput

read -p "Please enter CONTROLLER HOST NAME :" userInput;
check_userInput
CONTROLLER_HOST_NAME=$userInput

read -p "Please enter ACCOUNT NAME :" userInput;
check_userInput
ACCOUNT_NAME=$userInput

read -p "Please enter ACCOUNT ACCESS KEY :" userInput;
check_userInput
ACCOUNT_ACCESS_KEY=$userInput

read -p "Please enter PHP VERSION :" userInput;
check_userInput
PHP_VERSION=$userInput

# Set the Environment Variables
export APPDYNAMICS_CONTROLLER_HOST_NAME="${CONTROLLER_HOST_NAME}"
export APPDYNAMICS_CONTROLLER_PORT=443
export APPDYNAMICS_CONTROLLER_SSL_ENABLED=true
export APPDYNAMICS_AGENT_APPLICATION_NAME="${BRAND_ENVIRONMENT}"
export APPDYNAMICS_AGENT_TIER_NAME="${APPLICATION_NAME}"
export APPDYNAMICS_AGENT_NODE_PREFIX_NAME="${HOSTNAME}"
export APPDYNAMICS_AGENT_ACCOUNT_NAME="${ACCOUNT_NAME}"
export APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="${ACCOUNT_ACCESS_KEY}"
export APPDYNAMICS_WORKDIR="/opt/appdynamics"
export APPDYNAMICS_PATH="${APPDYNAMICS_WORKDIR}/appdynamics-php-agent-linux_x64"
export PHP_VERSION="${PHP_VERSION}"

#Download all the Dependencies
echo "Download all the Dependencies..."
apt-get update -qq; apt-get install tar bzip2 procps -qy

# Delete Working Directory
echo Deleting Working Directory ${APPDYNAMICS_WORKDIR}
rm -rf ${APPDYNAMICS_WORKDIR}

# Clone Scripts and Agents
git clone https://github.com/dahiyashish/appdynamics.git ${APPDYNAMICS_WORKDIR}

sleep 15 #wait for cloning repository

# Extract the Agent and Depending Files
tar -xjvf ${APPDYNAMICS_PATH}/appdynamics-php-agent-linux_x64.tar.bz2 --directory ${APPDYNAMICS_WORKDIR}

# Change the Permission of Files
chmod -R 777 ${APPDYNAMICS_WORKDIR}

# Installing AppDynamics with following attributes
printenv | grep -e APPDYNAMICS -e PHP_VERSION

bash ${APPDYNAMICS_PATH}/install.sh -s -a=${APPDYNAMICS_AGENT_ACCOUNT_NAME}@${APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY} -v ${PHP_VERSION} ${APPDYNAMICS_CONTROLLER_HOST_NAME} ${APPDYNAMICS_CONTROLLER_PORT} ${APPDYNAMICS_AGENT_APPLICATION_NAME} ${APPDYNAMICS_AGENT_TIER_NAME} ${APPDYNAMICS_AGENT_NODE_PREFIX_NAME}

# Copy the Generated ini file to atcual path or create link
# ln -s /etc/php/7.2/cli/conf.d/appdynamics_agent.ini  /etc/php/7.2/fpm/conf.d/appdynamics_agent.ini
echo Copying... ini file from \n /etc/php/7.2/cli/conf.d/appdynamics_agent.ini to /etc/php/7.2/fpm/conf.d/appdynamics_agent.ini
cp /etc/php/7.2/cli/conf.d/appdynamics_agent.ini /etc/php/7.2/fpm/conf.d/appdynamics_agent.ini

# Restart the Services like PHP and Nginx to Reflect the changes
echo "Restarting the PHP FPM Service"
/etc/init.d/php7.2-fpm restart

echo "Restarting the Nginx Service"
/etc/init.d/nginx restart

#Check the Services of AppDynamics
echo "Check the service with this command: ps -aux | grep java"