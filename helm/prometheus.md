# Install prometheus

## Install Prometheus

    $ helm install stable/prometheus --name prom0 -f helm/prometheus.yaml

## Upgrade Prometheus

    $ helm upgrade -f helm/prometheus.yaml prom0 local/prometheus
