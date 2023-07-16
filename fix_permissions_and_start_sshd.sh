#!/bin/bash
echo "Fixing permissions"

# Fix permissions on openshift cluster
my_id=$(id -u)
my_grp=$(id -g)

sed "s/999:999/$my_id:$my_grp/" /etc/passwd > /tmp/passwd
cat /tmp/passwd > /etc/passwd
sed "s/postgres_data/postgres/" /etc/passwd > /tmp/passwd
cat /tmp/passwd > /etc/passwd

# Create home directory. This is created during runtime to have proper permissions on openshift
mkdir /home/postgres
chmod 700 /home/postgres

# Create directories with correct permissions for ssh client
SSH_DIR=/home/postgres/.ssh
mkdir $SSH_DIR
chmod 700 $SSH_DIR

if [ -d /ssh_keys ]; then
   cp /ssh_keys/* $SSH_DIR
fi


if [ -f $SSH_DIR/id_rsa.pub ]; then
   chmod 644  $SSH_DIR/id_rsa.pub
fi

if [ -f $SSH_DIR/id_rsa ]; then
   chmod 600  $SSH_DIR/id_rsa
fi


if [ -f $SSH_DIR/known_hosts ]; then
   chmod 600  $SSH_DIR/known_hosts
fi


   
#if [ ! -f $SSH_CONF/ ]; then
#   ssh-keygen -q -N "" -t ecdsa -f $SSH_CONF/ssh_host_ecdsa_key
#   ssh-keygen -q -N "" -t ed25519 -f $SSH_CONF/ssh_host_ed25519_key
#   ssh-keygen -q -N "" -t rsa -f $SSH_CONF/ssh_host_rsa_key
#fi
if [ $START_SSHD = true ]; then

   SSH_CONF=/ssh_conf_template
   
   mkdir /home/postgres/sshd
   
   # Generate server keys if not existing
   if [ ! -f $SSH_CONF/ssh_host_ecdsa_key ]; then 
      ssh-keygen -q -N "" -t ecdsa -f $SSH_CONF/ssh_host_ecdsa_key
   fi
   if [ ! -f $SSH_CONF/ssh_host_ed25519_key ]; then 
      ssh-keygen -q -N "" -t ed25519 -f $SSH_CONF/ssh_host_ed25519_key
   fi
   if [ ! -f $SSH_CONF/ssh_host_rsa_key ]; then 
      ssh-keygen -q -N "" -t rsa -f $SSH_CONF/ssh_host_rsa_key
   fi
   
   # Copy the keys and the config to the home directory  
   cp -r $SSH_CONF/* /home/postgres/sshd/

   # Copy authorized keys
   if [ -f $SSH_DIR/authorized_keys ]; then
      chmod 600  $SSH_DIR/authorized_keys
   fi

   chmod 600 /home/postgres/sshd/ssh_host*

   /usr/sbin/sshd -f /home/postgres/sshd/sshd_config

fi   

cd /home/postgres

# If KNOWN_HOSTS is set and known hosts file does not exist, create it
if [ ! -s /home/postgres/.ssh/known_hosts ] && [ ! -z "$KNOWN_HOSTS" ]; then
     echo "$KNOWN_HOSTS" | jq -r .[] | while read host; do
         until ssh-keyscan -H $host >> /home/postgres/.ssh/known_hosts; do
             echo "Could not load key for $host...retrying in 5s"
	     sleep 5
         done    
     done
     chmod 600 /home/postgres/.ssh/known_hosts   

elif [ -f $SSH_CONF/known_hosts ]; then 
   cp $SSH_CONF/known_hosts /home/postgres/.ssh/known_hosts
   chmod 600 /home/postgres/.ssh/known_hosts   
fi



# Start monitoring
/start_monitoring.sh


#if [ ! -z "$@" ]; then
#  "$@"
#else	
#  /entrypoint.sh 
#fi  
