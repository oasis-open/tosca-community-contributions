#!/bin/bash

# A small but mighty script to automatically delete terminated VMs.

for instance in  $(gcloud compute instances list --filter="status=terminated"
                   --format="value(name)" --quiet)
do
  zone=$(gcloud compute instances list --filter="name=$instance"
         --format="value(zone)" --quiet)
  status=$(gcloud compute instances describe $instance --zone=$zone
           --format="value(status)" --quiet)
  created_on=$(gcloud compute instances describe $instance --zone=$zone
               --format="value(creationTimestamp.date('%Y-%m-%d'))" --quiet)
  echo "Instance name: $instance"
  echo "Created on $created_on"
  gcloud compute instances delete $instance --zone=$zone --quiet
done
