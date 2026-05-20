#!/bin/bash

ZONE=us-central1-a
gcloud compute instances list --format="value(name)" \
  --filter="zone:$ZONE status:running" --quiet
