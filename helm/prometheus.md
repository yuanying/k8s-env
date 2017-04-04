# Install prometheus

## Install customized prometheus charts to local repository

    $ helm package ~/.helm/charts/stable/prometheus/
    $ mv prometheus-* ~/.helm/repository/local/
    $ helm repo index ~/.helm/repository/local/

## Install Prometheus

    $ helm install local/prometheus --name prom0 -f helm/prometheus.yaml
