## WSO2 APIM Analytic with ELK solution

### Architecture

![alt text](<APIM Analytics with ELK Solution.png>)


### Version
- wso2 apim - v4.3.0 all in one (am-pattern-one)
- All ELK (filebeat,metricbeat,logstash,elasticssearch,kibana) - v8.14.3
- kube-state-metrics : v2.8.2 from google container 

### What this repo solve (real life difficulty)
- There is some tricky in analytic set up for wso2 kubernets. 
- Usually wso2 suggests to use choreo analytic cloud solution for analytic solution, but choreo only show hit count. It doesn't trace the log. So, when in real time deployment. it is hard to trace the log when there is debug reason. 
- While there is a way to look the log from `kubectl command` and others methods, but it is not make sense to trace the bugs when there are hundred of APIs invoke. If we want to trace older logs, there is no luck on that.
- If come to kubernetes, wso2 also suggest to use `wso2 apk` [APIM for kubernetes](https://apk.docs.wso2.com/en/latest/setup/prerequisites/). 
- There is also methods for [ELK in wso2 apk](https://apk.docs.wso2.com/en/latest/setup/analytics/configure-analytics-for-elk-stack/), but that solution only show streaming logs.  Not APIs logs. 

- According to Documents, it needs to use `choreo` for **metric counts** and `ELK` for **logs**. It doesn't suitable to use two dashboard for one APIM app.
- In website wso2 suggest to use the `ELK` solution for [analytic](https://apim.docs.wso2.com/en/latest/api-analytics/on-prem/elk-installation-guide/). But this docs doesn't have enough when come to Docker and kubernetes. Because we need to compeletely resetup the SVC routes and another TraceLog manually.
- The main problem is the log is inside the pods as files. `apim_metric files` which are in `/home/wso2carbon/wso2am-4.3.0./repository/logs`.
- This repo solve analytic problems to whose using old APIM kubernetes architecture like am-pattern-one. After this setup, we can use dashboard and logs for APIMs.

### Downside of this repo
- You will need advanced knowledge on kubernetes setup. 
- This is solution for APIM runinning as a Pods not  as a micro-service. 
- ELK stack original repo are now archieved and Now `Elastic` suggest to `ECK` version. [Elastic cloud on kubernetes](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-stack-helm-chart.html) (I don't use eck setup because there is alot to add when deep dive config for performance.)
- wso2 have [new helm chart for APIM kubernets](https://github.com/wso2/helm-apim) and what I use is old [kubernetes pattern](https://github.com/wso2/kubernetes-apim)
- Also wso2 have [wso2 APK solution](https://apk.docs.wso2.com/en/latest/setup/prerequisites/).

> [!WARNING] This is semi-production setup. Neither suitable nor recommend to depoly as production setup.
> Make sure to read the production security Guide line in [this link.](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/deployment-best-practices/security-guidelines-for-production-deployment/)  
> ### Summrize the whole APIM Docs
> * Authentication and Authorization inside wso2 APIM.
>   + API keys token and Role-based Access Control. (create internal dev user with roles).
>   * Network Security
>     + Separate Gateway URL and Control Plane URL. Control Plane(Publisher, dev portal, admin, carbon portal) URL for the internal developer and Gateway is for client APP.
>       - Whitelist certain API domains can go through outside.
>       - If needed, Block the control plane access from outside or whitelist the IP. 
>     + Private Connection to Backend. Can also add OAuth in Endpoint.
>     + Network Policies and Firewall and Security Group. 
>   * Data Encryption 
>     + TLS and SSL.
>   * Secret Management. 
>     + Kubernetes Config. 
>       - Change default keystores
>       - Vault enable 
>       - Encrypt all usernames and passwords inside the config.
>   * Compliance and Audit.
>     + Check with ELK analytics
>   * API Gateway Security 
>     + Rate limiting (build-in feature in APIM)
---

> [!NOTE] Original link 
>Here is a original link for whose need to add custom tls certification and security to ELK. you can see inside the helm zip -> examples. The Elk config file version is 8.5.1
>- apim - https://artifacthub.io/packages/helm/wso2/am-pattern-1
>- filebeat - https://artifacthub.io/packages/helm/elastic/filebeat
>- metricbeat - https://artifacthub.io/packages/helm/elastic/metricbeat
>- logstash - https://artifacthub.io/packages/helm/elastic/logstash
>- elasticsearch - https://artifacthub.io/packages/helm/elastic/elasticsearch
>- Kibana - https://artifacthub.io/packages/helm/elastic/kibana
---


### Requirements 
> [!TIP] 
> This setup is for 2 nodes APIM cluster. And nearly use 24 core and 32GB of memory. But you can install what really you want. if you want to skip kubernetes metric phase, you can skip installing metricbeat and filebeat-k. You can install only filebeat -> logstash -> elasticsearch -> kibana. And you can also reduce the infrastructure by editing replica as 1.     

- We need a cluster at least 1 master, 1 node with 6core 8 GB clusters. (replica 1)
- We need basic kubernetes tools like: `helm`, `kubectl`.
- `Nginx-ingress` is a must and if you don't have ingress, you have to port-forward the service.

This wos2 use external database for user store and APIM store. You need to download wso2 zip file from website to create the script. 
First, we need to install MySQL Database Setup according to the [guide](Database_creation.md).  
#### Check list for database creation
- [ ] user creation for connection 
- [ ] database creation
- [ ] table creation
- [ ] check connection

```sql
mysql -h <IP> -u wso2carbon -p -e "show databases;"
```
---

### setup

1. Add Database IP or host name in `am-pattern-1` values file under `db:`
2. change `pvc.yaml` and edit `pv` location. 
3. then add pv to your kubernetes cluster by

```bash
        kubectl create -f yaml/pvc.yaml 
```

4.  manually add `pvc` to both `am-pattern-1` deployment.yml and `filebeat` value.yaml if we use original config. 


The am-pattern-1 deployemt is in `am-pattern-1/templates/am/instance-*/` folder. 
To add the config in both `am-pattern-1/templates/am/instance-1/` and `am-pattern-1/templates/am/instance-2/`

```yaml
# in initContainers
    spec:
      initContainers:
       - name: init-set-permissions
          image: busybox:1.32
          command: ['sh', '-c', 'chown -R 802:802 /home/wso2carbon/wso2am-4.3.0/repository/logs/']
          volumeMounts:
            - name: wso2am-logs
              mountPath: /home/wso2carbon/wso2am-4.3.0/repository/logs/

# in containers:              
      containers:
          volumeMounts:
            - name: wso2am-logs
              mountPath: /home/wso2carbon/wso2am-4.3.0/repository/logs/
```

5. Then install `am-pattern-1` and `filebeat` with 

```bash
# create namespace call elk
  kubectl create ns elk

# install apim
  helm install apim am-pattern-1/ -n elk

# install filebeat
  helm install filebeat filebeat/ -n elk
```
6. before installing the `logstash` and `elasticsearch`, be sure you need to mount pv which is same as volume calim. I will lead that steps to you. if you are install in localhost the claim become standard and take automatically. 

```bash

# install logstash 
  helm install logstash logstash/ -n elk

# install elasticsearch 
  helm install elasticsearch elasticsearch/ -n elk
```
7. be sure to wait til the elasticsearch finish to install. You will find the error when you rash install kibana without elasticsearch running. After all the setup running, install kibana

```bash
# install kibana
  helm install kibana kibana/ -n elk
```

8. Make sure you add your ing `domain name` and `ip` to  `/etc/host`. Then you can login with domain name in browser. 
9. After login to kibana dashboard, add `wso2.ndjson` to stackmonitoring > saved_object > import file. 
10. Then you can use the dashboard in `dscover` tag. 

---
