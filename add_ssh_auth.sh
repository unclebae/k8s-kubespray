#! /usr/bin/env bash

#ssh key 생성
sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@192.168.10.11
sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@192.168.10.12
sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@192.168.10.13
sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@192.168.10.21
sshpass -p vagrant ssh -T -o StrictHostKeyChecking=no vagrant@192.168.10.22