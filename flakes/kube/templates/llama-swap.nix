---
apiVersion: v1
kind: Service
metadata:
  name: llama-swap
  namespace: @namespace@
  labels:
    app.kubernetes.io/name: llama-swap
    app.kubernetes.io/instance: llama-swap
  annotations:
    tailscale.com/expose: "true"
    tailscale.com/hostname: "llama-swap"
    tailscale.com/tags: "tag:http"
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: llama-swap
      protocol: TCP
      name: llama-swap
  selector:
    app.kubernetes.io/name: llama-swap
    app.kubernetes.io/instance: llama-swap
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: llama-swap-config
  namespace: @namespace@
data:
  config.yaml: |-
    healthCheckTimeout: 300
    logLevel: info
    logToStdout: "proxy"

    models:
      "llama3.1:8b":
        proxy: "http://127.0.0.1:${PORT}"
        cmd: >-
          llama-server
          --model /models/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf
          --port ${PORT}
          --host 127.0.0.1
          --ctx-size 8192
          --threads 4
          -ngl 99
  download.sh: |-
    #!/bin/sh
    MODEL="/models/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf"
    URL="https://huggingface.co/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf"
    if [ -f "${MODEL}" ]; then
      echo "Model already exists, skipping download"
    else
      echo "Downloading model..."
      curl -C - -L "${URL}" -o "${MODEL}"
    fi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: llama-swap
  namespace: @namespace@
  labels:
    app.kubernetes.io/name: llama-swap
    app.kubernetes.io/instance: llama-swap
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: llama-swap
      app.kubernetes.io/instance: llama-swap
  template:
    metadata:
      labels:
        app.kubernetes.io/name: llama-swap
        app.kubernetes.io/instance: llama-swap
    spec:
      securityContext:
        {}
      initContainers:
        - name: model-downloader
          image: docker.io/curlimages/curl
          securityContext:
            runAsUser: 1000
          command:
            - "/download.sh"
          volumeMounts:
            - name: models
              mountPath: /models
            - name: llama-swap-downloader
              mountPath: /download.sh
              subPath: download.sh
      containers:
        - name: llama-swap
          securityContext:
            privileged: true
          image: "@image@"
          imagePullPolicy: IfNotPresent
          ports:
            - name: llama-swap
              containerPort: 8080
              protocol: TCP
          volumeMounts:
            - name: models
              mountPath: /models
            - name: llama-swap-config
              mountPath: /app/config.yaml
              subPath: config.yaml
          resources:
            requests:
              gpu.intel.com/i915: "1"
            limits:
              gpu.intel.com/i915: "1"
      volumes:
        - name: models
          hostPath:
            path: @hostfolder@
            type: DirectoryOrCreate
        - name: llama-swap-config
          configMap:
            name: llama-swap-config
            items:
              - key: config.yaml
                path: config.yaml
        - name: llama-swap-downloader
          configMap:
            name: llama-swap-config
            defaultMode: 0777
            items:
              - key: download.sh
                path: download.sh
