#!/bin/bash

echo "Hello!"

while getopts p:v:j: flag
do
    case "${flag}" in
        p) platform=${OPTARG};;
        v) version=${OPTARG};;
        j) json_file=${OPTARG};;
    esac
done


whoami
mkdir /home/airflow/workspace
cd /home/airflow/workspace
git clone https://github.com/openshift-scale/scale-ci-deploy
git clone https://${SSHKEY_TOKEN}@github.com/redhat-performance/perf-dept.git
export PUBLIC_KEY=/home/airflow/workspace/perf-dept/ssh_keys/id_rsa_pbench_ec2.pub
export PRIVATE_KEY=/home/airflow/workspace/perf-dept/ssh_keys/id_rsa_pbench_ec2 
export ANSIBLE_FORCE_COLOR=true
export AWS_REGION=us-west-2
chmod 600 ${PRIVATE_KEY}


cd scale-ci-deploy
# Create inventory File:
echo "[orchestration]" > inventory
echo "${ORCHESTRATION_HOST}" >> inventory
cat inventory
cat ${json_file}

sed -i 's/timeout = 30/timeout = 60/g' ansible.cfg
echo "[ssh_connection]" >> ansible.cfg
echo "pipelining = True" >> ansible.cfg
echo "retries = 3" >> ansible.cfg
echo "control_path = /tmp/ansible-ssh-%%h-%%p-%%r" >> ansible.cfg
echo "ssh_args = -o ServerAliveInterval=30" >> ansible.cfg
cat ansible.cfg
ansible-playbook -vv -i inventory OCP-$version.X/install-on-$platform.yml --extra-vars "@${json_file}"