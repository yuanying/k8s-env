
```bash
$ kubectl apply -R -f configs/manifests/owncloud/
$ kubectl config set-context cluster --namespace owncloud
```

```bash
$ helm install stable/owncloud \
  --name oc0 -f configs/helm/owncloud.yaml \
  --namespace owncloud
```

```bash
$ helm upgrade oc0 \
  stable/owncloud \
  --namespace owncloud \
  -f configs/helm/owncloud.yaml
```
