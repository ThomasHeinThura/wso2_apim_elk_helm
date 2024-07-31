helm install elasticsearch elasticsearch/ 

kubectl create -f yaml/pvc.yaml

helm install filebeat filebeat/

helm install filebeat-k filebeat-k/

helm install logstash logstash/ 

helm install metric metricbeat/

helm install apim an-pattern-one/

