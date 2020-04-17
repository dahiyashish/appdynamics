#! /bin/bash
read -p "Please enter BRAND_ENVIRONMENT :" userInput;
BRAND_ENVIRONMENT=$userInput
read -p "Please enter APPLICATION NAME :" userInput;
APPLICATION_NAME=$userInput
export APPDYNAMICS_CONTROLLER_HOST_NAME=data2020041323193915.saas.appdynamics.com
export APPDYNAMICS_CONTROLLER_PORT=443
export APPDYNAMICS_CONTROLLER_SSL_ENABLED=true
export APPDYNAMICS_AGENT_APPLICATION_NAME=${BRAND_ENVIRONMENT}
export APPDYNAMICS_AGENT_TIER_NAME=${APPLICATION_NAME}
export APPDYNAMICS_AGENT_NODE_PREFIX_NAME=${HOSTNAME}
export APPDYNAMICS_AGENT_ACCOUNT_NAME=data2020041323193915
export APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY=k6bc8ssk4zzc
export APPDYNAMICS_PATH=appdynamics-php-agent-linux_x64
export PHP_VERSION=7.2
cd /tmp && rm -rf php-agent.zip /tmp/appdynamics* /opt/appDynamics
wget -O php-agent.zip https://download-files.appdynamics.com/tmp-custom-downloads/custom_agent_g29pj6wyL81kPwxExKQBg_OQGXr6bFrlySEytpDEWzFDQbfTUqc/appdynamics-php-agent-x64-linux-20.3.1.3604.zip?Expires=1587107060&Signature=NyA0R2edbl3K7c1IjfpJq~9SvcdeUw-J4zspec-~iaton74immSJMWuS7l9dziipIXAzTnns1ONdYH62BbC3arKxPfYKzBr298BldHeotTAfDOXk0yUZNWxzOt9evdUTVWzp1HC5p9q3N~1pU00HBvFEobeuvJ28bLGg3LTbxNAVL-HLJGualMGx99L~l42NWIoB9APRarWb4UelgyG6QjFspYGuC9WilXRZmpefnMILrGpHoMcur140VXXe~jF6nMVG8idlgveUX5FMbaO6A5obZDr39UslX2~eaca~KflZ9KzGd6c2Z~OJu~teLCJd0qO~mxXdZ~8UjRwUiBtUoQ__&Key-Pair-Id=APKAI6PWCU7XQZAIYFCA
sleep 30
unzip php-agent.zip
apt-get update -qq; apt-get install tar bzip2 procps -qy  ; mkdir /opt/appDynamics  ; tar -xjvf /tmp/appdynamics-php-agent-linux_x64/appdynamics-php-agent-linux_x64.tar.bz2 --directory /opt/appDynamics/ ; chmod -R 777 /opt/appDynamics/appdynamics-php-agent-linux_x64/ ; cd /opt/appDynamics/appdynamics-php-agent-linux_x64/
bash install.sh -s -a=${APPDYNAMICS_AGENT_ACCOUNT_NAME}@${APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY} -v ${PHP_VERSION} ${APPDYNAMICS_CONTROLLER_HOST_NAME} ${APPDYNAMICS_CONTROLLER_PORT} ${APPDYNAMICS_AGENT_APPLICATION_NAME} ${APPDYNAMICS_AGENT_TIER_NAME} ${APPDYNAMICS_AGENT_NODE_PREFIX_NAME}
cp /etc/php/7.2/cli/conf.d/appdynamics_agent.ini /etc/php/7.2/fpm/conf.d/appdynamics_agent.ini
/etc/init.d/php7.2-fpm restart
/etc/init.d/nginx restart
sleep 3
ps -aux | grep java