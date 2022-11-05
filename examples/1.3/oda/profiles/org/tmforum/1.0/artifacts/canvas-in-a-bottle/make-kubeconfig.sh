#!/bin/bash
TOKEN=$(docker container exec tmf-canvas-in-a-bottle bash -c "/root/get_dashboard_token" | grep "^token")
cat << EOF > kc.yaml
apiVersion: v1
clusters:
- cluster:
    server: http://127.0.0.1:30303
  name: canvas
contexts:
- context:
    cluster: canvas
    namespace: canvas
    user: canvas
  name: canvas
current-context: "canvas"
kind: Config
preferences: {}
users:
- name: admin
  user:
    $TOKEN
EOF