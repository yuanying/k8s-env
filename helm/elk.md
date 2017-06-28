# Install ELK

```bash
$ helm install ./charts/elasticsearch --name escluster -f helm/elasticsearch.yaml
$ helm install ./charts/kibana -n kibana -f helm/kibana.yaml
$ helm install ./charts/logstash -n lscluster -f helm/logstash.yaml
```

# Update

```bash
$ helm upgrade lscluster ./charts/logstash -f helm/logstash.yaml
```
