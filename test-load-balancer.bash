#!/bin/bash
dns_hostname=$(kubectl get service -n return-hostname return-hostname-loadbalancer -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
url="$dns_hostname:8080"
curl "$url"
