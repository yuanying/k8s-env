# Setup

## Working with RBAC

    $ kubectl create clusterrolebinding \
              tiller-cluster-rule \
              --clusterrole=cluster-admin \
              --serviceaccount=kube-system:default

## Setup local repository

    $ git clone https://github.com/yuanying/charts.git ~/.helm/charts
