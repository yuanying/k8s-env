# Install ELK

```bash
$ helm install ./charts/elasticsearch --name escluster -f helm/elasticsearch.yaml
$ helm install ./charts/kibana -n kibana -f helm/kibana.yaml
```
