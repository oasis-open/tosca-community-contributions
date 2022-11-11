#!/bin/bash
##Install microk8s on ubuntu
sudo snap install microk8s --channel=1.21/stable --classic
sudo usermod -a -G microk8s jordanpm
sudo chown -f -R jordanpm ~/.kube
newgrp microk8s
#check
microk8s status --wait-ready
##configure
microk8s enable dashboard dns registry istio
##configure kubectl
#mkdir $HOME/.kube
microk8s config > $HOME/.kube/config
##stop
#microk8s stop
##restart
#microk8s start
##reset
#microk8s  reset
#sudo usermod -a -G microk8s jordanpm
#sudo chown -f -R jordanpm ~/.kube
#newgrp microk8s
#microk8s enable dashboard dns registry istio
#microk8s config > $HOME/.kube/config