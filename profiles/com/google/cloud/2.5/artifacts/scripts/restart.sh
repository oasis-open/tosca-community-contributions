#!/bin/bash

# A simple script that restarts VMs with memory usage numbers above a
# specified threshold.

ZONE=us-central1-a
MIN_MEMORY=5000
for instance in $(gcloud compute instances list --format="value(name)"
		  --filter="zone:$ZONE status:running" --quiet)
do
  free_memory=$(gcloud compute ssh $instance --zone=$ZONE --command="free -m |
                awk '/^Mem:/{print \$4}'" --quiet)
  if (( $free_memory < $MIN_MEMORY ))
  then
    echo "Restarting instance : $instance"
    gcloud compute instances stop $instance --zone=$ZONE --quiet
    gcloud compute instances start $instance --zone=$ZONE --quiet
  fi
done
