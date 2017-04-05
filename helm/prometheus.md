# Install prometheus

## Install customized prometheus charts to local repository

    $ cd ~/.helm/charts
    $ git checkout node-exporter-support-extra-mounts
    $ helm package ~/.helm/charts/stable/prometheus/
    $ mv prometheus-* ~/.helm/repository/local/
    $ helm repo index ~/.helm/repository/local/
    $ helm serve

## Install Prometheus

    $ helm install local/prometheus --name prom0 -f helm/prometheus.yaml

## Upgrade Prometheus

    $ helm upgrade -f helm/prometheus.yaml prom0 local/prometheus
