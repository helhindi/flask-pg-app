/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  cluster_type = "deploy-service"
}

provider "google" {
  version = "~> 2.18.0"
  region  = var.region
}

provider "kubernetes" {
  load_config_file       = false
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

data "google_client_config" "default" {
}

module "gke" {
  source     = "terraform-google-modules/kubernetes-engine/google"
  project_id = var.project_id
  name       = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  region     = var.region
  network    = var.network
  subnetwork = var.subnetwork

  ip_range_pods          = var.ip_range_pods
  ip_range_services      = var.ip_range_services
  create_service_account = false
  service_account        = var.compute_engine_service_account
}

# Namespace
resource "kubernetes_namespace" "myapps" {
  metadata {
    annotations {
      name = "myapps"
    }
    name = "myapps"
    
    labels = {
      maintained_by = "terraform"
      env           = "develop"
    }
  }
}

# Config Map
resource "kubernetes_config_map" "postgres-configmap" {
  metadata {
    name      = "postgres-configmap"
    namespace = "${kubernetes_namespace.myapps.metadata.0.name}"
    
    labels = {
      maintained_by = "terraform"
      app           = "postgres"
      env           = "develop"
    }
  }

  data = {
    POSTGRES_DB       = "pg_db"
    POSTGRES_USER     = "helhindi"
    POSTGRES_PASSWORD = "${file("postgres.secret")}"
  }
}

# Secret
resource "kubernetes_secret" "postgres-secret" {
  metadata {
    name      = "postgres-secret"
    namespace = "${kubernetes_namespace.monitoring.myapps.0.name}"
  }
  data {
    "POSTGRES_PASSWORD" = "${file("postgres.secret")}"
  }
  type = "Opaque"
}

# Peristent volume Claim
resource "kubernetes_persistent_volume_claim" "postgres-pv-claim" {
  metadata {
    name      = "postgres-pv-claim"
    namespace = "${kubernetes_namespace.myapps.metadata.0.name}"

    labels = {
      maintained_by = "terraform"
      app           = "postgres"
      env           = "develop"
    }
  }

  spec {
    resources {
      requests {
        storage = "5Gi"
      }
    }

    access_modes = ["ReadWriteOnce"]
  }
}
resource "kubernetes_pod" "postgres" {
  metadata {
    name      = "flask"
    namespace = "${kubernetes_namespace.myapps.metadata.0.name}"

    labels = {
      maintained_by = "terraform"
      app           = "postgres"
      env           = "develop"
    }
  }

  spec {
    container {
      image = "postgres:9.6.2"
      name  = "postgres"
      env {
        - name: "POSTGRES_DB"
          valueFrom:
            configMapKeyRef:
              key: "POSTGRES_DB"
              name: "postgres-config"
        - name: "POSTGRES_USER"
          valueFrom:
            configMapKeyRef:
              key: "POSTGRES_USER"
              name: "postgres-config"
        - name: "POSTGRES_PASSWORD"
          valueFrom:
            configMapKeyRef:
              key: "POSTGRES_PASSWORD"
              name: "postgres-config"
      }
        port {
          container_port = 5432
        }
        volumeMounts {
          - name: postgres-storage
            mountPath: /var/lib/postgresql/db-data
        }
        volumes:
          - name: postgres-storage
            persistentVolumeClaim:
              claimName: postgres-pv-claim
    }
  }

  depends_on = [module.gke]
}


resource "kubernetes_pod" "flask" {
  metadata {
    name          = "flask"
    namespace:    = "develop"

    labels = {
      maintained_by = "terraform"
      app           = "flask"
      env           = "develop"
    }
  }

  spec {
    container {
      image = "elhindi/flask-pg-app:v0.1"
      name  = "flask"
    }
  }

  depends_on = [module.gke]
}

resource "kubernetes_service" "flask-svc" {
  metadata {
    name      = "flask"
    namespace = "develop"

    labels = {
      maintained_by = "terraform"
      app           = "flask"
      env           = "develop"
  }

  spec {
    selector = {
      app = kubernetes_pod.flask.metadata[0].labels.app
    }

    session_affinity = "ClientIP"

    port {
      port        = 5000
      target_port = 80
    }

    type = "LoadBalancer"
  }

  depends_on = [module.gke]
}
