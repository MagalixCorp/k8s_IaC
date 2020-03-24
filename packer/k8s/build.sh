#!/bin/bash
sudo apt update && sudo apt install python python-pip -y
pip install --user ansible
export PATH=$PATH:~/.local/bin
pip install -U Jinja2
sudo sysctl -w net.ipv4.ip_forward=1
