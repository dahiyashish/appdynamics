#! /bin/bash
#Styling my Inputs
ansi()          { echo -e "\e[${1}m${*:2}\e[0m"; }
bold()          { ansi 1 "$@"; }
italic()        { ansi 3 "$@"; }
underline()     { ansi 4 "$@"; }
strikethrough() { ansi 9 "$@"; }
red()           { ansi 31 "$@"; }

# Get the AppDynamics Environment Details from user 
while read -rep "Please enter BRAND_ENVIRONMENT :" userInput && [[ -z "$userInput" ]] ; 
    do
    printf  "\n  $(red No-no, please, no blank BRAND_ENVIRONMENT!) \n\n "
    done
BRAND_ENVIRONMENT=$userInput


while read -rep "Please enter APPLICATION NAME :" userInput && [[ -z "$userInput" ]] ; 
    do
    printf  "\n  $(red No-no, please, no blank APPLICATION NAME!) \n\n "
    done
APPLICATION_NAME=$userInput


while read -rep "Please enter CONTROLLER HOST NAME :" userInput && [[ -z "$userInput" ]] ; 
    do
    printf  "\n  $(red No-no, please, no blank CONTROLLER HOST NAME!) \n\n "
    done
CONTROLLER_HOST_NAME=$userInput


while read -rep "Please enter ACCOUNT NAME :" userInput && [[ -z "$userInput" ]] ; 
    do
    printf  "\n  $(red No-no, please, no blank ACCOUNT NAME!) \n\n "
    done
ACCOUNT_NAME=$userInput


while read -rep "Please enter ACCOUNT ACCESS KEY :" userInput && [[ -z "$userInput" ]] ; 
    do
    printf  "\n  $(red No-no, please, no blank ACCOUNT ACCESS KEY!) \n\n "
    done
ACCOUNT_ACCESS_KEY=$userInput


while read -rep "Please enter PHP VERSION :" userInput && [[ -z "$userInput" ]] ; 
    do
    printf  "\n  $(red No-no, please, no blank PHP VERSION!) \n\n "
    done
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
printf  "\n $(bold Download all the Dependencies...) \n\n"
apt-get update -qq; apt-get install tar bzip2 procps -qy

# Delete Working Directory
printf  "\n $(bold Deleting Working Directory) --> $(red ${APPDYNAMICS_WORKDIR}) \n\n"
rm -rf ${APPDYNAMICS_WORKDIR}

# Clone Scripts and Agents
git clone https://github.com/dahiyashish/appdynamics.git ${APPDYNAMICS_WORKDIR}

sleep 15 #wait for cloning repository

# Extract the Agent and Depending Files
tar -xjvf ${APPDYNAMICS_PATH}/appdynamics-php-agent-linux_x64.tar.bz2 --directory ${APPDYNAMICS_WORKDIR}

# Change the Permission of Files
chmod -R 777 ${APPDYNAMICS_WORKDIR}

# Installing AppDynamics with following attributes
printf  "\n $(bold Installing AppDynamics with following attributes...)"
printenv | grep -e APPDYNAMICS -e PHP_VERSION | while read line; do printf  "\n $(bold $line) \n"; done;

bash ${APPDYNAMICS_PATH}/install.sh -s -a=${APPDYNAMICS_AGENT_ACCOUNT_NAME}@${APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY} -v ${PHP_VERSION} ${APPDYNAMICS_CONTROLLER_HOST_NAME} ${APPDYNAMICS_CONTROLLER_PORT} ${APPDYNAMICS_AGENT_APPLICATION_NAME} ${APPDYNAMICS_AGENT_TIER_NAME} ${APPDYNAMICS_AGENT_NODE_PREFIX_NAME}

# Copy the Generated ini file to atcual path or create link
# ln -s /etc/php/7.2/cli/conf.d/appdynamics_agent.ini  /etc/php/7.2/fpm/conf.d/appdynamics_agent.ini
printf  "\n $(bold Copying... ini file From ) \n\n /etc/php/7.2/cli/conf.d/appdynamics_agent.ini --> /etc/php/7.2/fpm/conf.d/appdynamics_agent.ini \n"
cp /etc/php/7.2/cli/conf.d/appdynamics_agent.ini /etc/php/7.2/fpm/conf.d/appdynamics_agent.ini

# Restart the Services like PHP and Nginx to Reflect the changes
printf  "\n $(bold Restarting the PHP FPM Service ) \n\n"
/etc/init.d/php7.2-fpm restart

printf  "\n $(bold Restarting the Nginx Service) \n\n"
/etc/init.d/nginx restart

#Check the Services of AppDynamics
echo  " $(bold Check the service with this command:)  ps -aux | grep java"