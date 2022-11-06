#!/bin/bash
#Install canvas as per https://github.com/tmforum-oda/oda-canvas-charts
cd ~
git clone https://github.com/tmforum-oda/oda-canvas-charts.git
cd oda-canvas-charts
#Step 1
helm install oda-ri-enablers clusterenablers
#Step 2
pushd ReferenceImplementation/cert-manager
bash install_cert-manager.sh
popd
#Step 3
bash install_canvas_cert-manager.sh
