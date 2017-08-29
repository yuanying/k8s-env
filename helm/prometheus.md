# Install prometheus

## Install Prometheus

    $ helm install stable/prometheus --name prom0 -f helm/prometheus.yaml

## Upgrade Prometheus

    $ helm upgrade -f helm/prometheus.yaml prom0 local/prometheus

## Install Grafana

    $ helm install stable/grafana --name gra0 -f helm/grafana.yaml
    $ helm upgrade gra0 stable/grafana -f helm/grafana.yaml --recreate-pods
