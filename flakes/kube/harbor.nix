{
  pkgs,
  kubelib,
  harbor-helm,
}:
let
  chart = kubelib.buildHelmChart {
    name = "harbor-chart";
    chart = "${harbor-helm}";
    namespace = "harbor";
    values = {
      expose = {
        type = "clusterIP";
        tls.enabled = false;
      };
      externalURL = "http://harbor.barn-banana.ts.net";
      existingSecretAdminPassword = "harbor-chart-core";
      existingSecretAdminPasswordKey = "HARBOR_ADMIN_PASSWORD";
      existingSecretSecretKey = "harbor-chart-core";
      core = {
        existingSecret = "harbor-chart-core";
        secretName = "harbor-chart-core";
        existingXsrfSecret = "harbor-chart-core";
      };
      jobservice.existingSecret = "harbor-chart-jobservice";
      registry = {
        existingSecret = "harbor-chart-registry";
        credentials.existingSecret = "harbor-chart-registry";
      };
      # The chart only permits an existing database password through the
      # external-database interface.  Its host continues to be the internal
      # database Service, while this dedicated secret supplies the password.
      database.external.existingSecret = "harbor-chart-database-password";
      updateStrategy.type = "Recreate";
      persistence = {
        enabled = true;
        persistentVolumeClaim = {
          registry.existingClaim = "harbor-registry";
          database.existingClaim = "harbor-database";
          redis.existingClaim = "harbor-redis";
        };
      };
      trivy.enabled = false;
      portal.resources = {
        requests = {
          cpu = "50m";
          memory = "64Mi";
        };
        limits = {
          cpu = "250m";
          memory = "256Mi";
        };
      };
      core.resources = {
        requests = {
          cpu = "100m";
          memory = "256Mi";
        };
        limits = {
          cpu = "1";
          memory = "1Gi";
        };
      };
      jobservice.resources = {
        requests = {
          cpu = "50m";
          memory = "128Mi";
        };
        limits = {
          cpu = "500m";
          memory = "512Mi";
        };
      };
      nginx.resources = {
        requests = {
          cpu = "50m";
          memory = "64Mi";
        };
        limits = {
          cpu = "250m";
          memory = "256Mi";
        };
      };
      registry = {
        registry.resources = {
          requests = {
            cpu = "100m";
            memory = "128Mi";
          };
          limits = {
            cpu = "1";
            memory = "1Gi";
          };
        };
        controller.resources = {
          requests = {
            cpu = "50m";
            memory = "64Mi";
          };
          limits = {
            cpu = "500m";
            memory = "512Mi";
          };
        };
      };
      database.internal.resources = {
        requests = {
          cpu = "100m";
          memory = "256Mi";
        };
        limits = {
          cpu = "1";
          memory = "1Gi";
        };
      };
      redis.internal.resources = {
        requests = {
          cpu = "50m";
          memory = "64Mi";
        };
        limits = {
          cpu = "250m";
          memory = "256Mi";
        };
      };
    };
  };
  extras = pkgs.writeText "harbor-extras.yaml" ''
    ---
    apiVersion: v1
    kind: Namespace
    metadata:
      name: harbor
    ---
    apiVersion: onepassword.com/v1
    kind: OnePasswordItem
    metadata:
      name: harbor-chart-core
      namespace: harbor
    spec:
      itemPath: "vaults/kubernetes/items/2bal2uetofmakaktswbwjq6ktm"
    ---
    apiVersion: onepassword.com/v1
    kind: OnePasswordItem
    metadata:
      name: harbor-chart-database
      namespace: harbor
    spec:
      itemPath: "vaults/kubernetes/items/2bal2uetofmakaktswbwjq6ktm"
    ---
    apiVersion: onepassword.com/v1
    kind: OnePasswordItem
    metadata:
      name: harbor-chart-database-password
      namespace: harbor
    spec:
      itemPath: "vaults/kubernetes/items/harbor-db-password"
    ---
    apiVersion: onepassword.com/v1
    kind: OnePasswordItem
    metadata:
      name: harbor-chart-jobservice
      namespace: harbor
    spec:
      itemPath: "vaults/kubernetes/items/2bal2uetofmakaktswbwjq6ktm"
    ---
    apiVersion: onepassword.com/v1
    kind: OnePasswordItem
    metadata:
      name: harbor-chart-registry
      namespace: harbor
    spec:
      itemPath: "vaults/kubernetes/items/2bal2uetofmakaktswbwjq6ktm"
    ---
    apiVersion: onepassword.com/v1
    kind: OnePasswordItem
    metadata:
      name: harbor-chart-registryctl
      namespace: harbor
    spec:
      itemPath: "vaults/kubernetes/items/2bal2uetofmakaktswbwjq6ktm"
    ---
    apiVersion: onepassword.com/v1
    kind: OnePasswordItem
    metadata:
      name: harbor-chart-registry-htpasswd
      namespace: harbor
    spec:
      itemPath: "vaults/kubernetes/items/2bal2uetofmakaktswbwjq6ktm"
    ---
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: harbor-registry
    spec:
      capacity:
        storage: 500Gi
      accessModes: [ReadWriteOnce]
      persistentVolumeReclaimPolicy: Retain
      storageClassName: ""
      hostPath:
        path: /media/data-ssd/harbor/registry
        type: Directory
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: harbor-registry
      namespace: harbor
    spec:
      accessModes: [ReadWriteOnce]
      resources:
        requests:
          storage: 500Gi
      storageClassName: ""
      volumeName: harbor-registry
    ---
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: harbor-database
    spec:
      capacity:
        storage: 50Gi
      accessModes: [ReadWriteOnce]
      persistentVolumeReclaimPolicy: Retain
      storageClassName: ""
      hostPath:
        path: /media/data-ssd/harbor/database
        type: Directory
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: harbor-database
      namespace: harbor
    spec:
      accessModes: [ReadWriteOnce]
      resources:
        requests:
          storage: 50Gi
      storageClassName: ""
      volumeName: harbor-database
    ---
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: harbor-redis
    spec:
      capacity:
        storage: 10Gi
      accessModes: [ReadWriteOnce]
      persistentVolumeReclaimPolicy: Retain
      storageClassName: ""
      hostPath:
        path: /media/data-ssd/harbor/redis
        type: Directory
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: harbor-redis
      namespace: harbor
    spec:
      accessModes: [ReadWriteOnce]
      resources:
        requests:
          storage: 10Gi
      storageClassName: ""
      volumeName: harbor-redis
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: harbor
      namespace: harbor
      annotations:
        tailscale.com/expose: "true"
        tailscale.com/hostname: harbor
        tailscale.com/tags: tag:http
    spec:
      type: ClusterIP
      selector:
        component: nginx
        release: harbor
      ports:
        - name: http
          port: 80
          targetPort: http
  '';
in
pkgs.runCommand "harbor" { nativeBuildInputs = [ pkgs.yq-go ]; } ''
  yq eval 'select(.kind != "Secret")' ${chart} > "$out"
  printf '\n---\n' >> "$out"
  cat ${extras} >> "$out"
''
