#!/usr/bin/env bash

SECRET=${1:-atlas-api-main-secret}
NAMESPACE=${2:-default}
CLONE_DB_NAME=${3:-atlas-dev}

JOB_NAME=${JOB_NAME:-"clone-db-001"}

kubectl delete job $JOB_NAME --namespace $NAMESPACE --ignore-not-found

cat <<EOF | kubectl create -f -
apiVersion: batch/v1
kind: Job
metadata:
 name: $JOB_NAME
 namespace: $NAMESPACE
spec:
  template:
    metadata:
      name: $JOB_NAME
      labels:
        job: $JOB_NAME
    spec:
      containers:
      - name: mycloner
        image: webonyx/mycloner:latest
        imagePullPolicy: Always
        envFrom:
          - secretRef:
              name: $SECRET
        env:
          - name: CLONE_DB_NAME
            value: $CLONE_DB_NAME
          - name: EXTRA_MYDUMPER_ARGS
            value: --threads=8
          - name: EXTRA_MYLOADER_ARGS
            value: --threads=8
      restartPolicy: Never
EOF

set -x

kubectl wait pods -n $NAMESPACE -l job=$JOB_NAME --for condition=Ready --timeout=10s

kubectl -n $NAMESPACE logs -f -l job=$JOB_NAME

kubectl -n $NAMESPACE describe pod -l job=$JOB_NAME

kubectl delete job $JOB_NAME --namespace $NAMESPACE
