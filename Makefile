
# This is for security 
elasaticsearh-secrets:
	docker rm -f elastic-helm-charts-certs || true
	rm -f elastic-certificates.p12 elastic-certificate.pem elastic-certificate.crt elastic-stack-ca.p12 || true
	docker run --name elastic-helm-charts-certs -i -w /tmp \
		docker.elastic.co/elasticsearch/elasticsearch:8.14.3 \
		/bin/sh -c " \
	elasticsearch-certutil ca --out /tmp/elastic-stack-ca.p12 --pass '' && \
	elasticsearch-certutil cert --name security-master --dns security-master --ca /tmp/elastic-stack-ca.p12 --pass '' --ca-pass '' --out /tmp/elastic-certificates.p12" && \
		docker cp elastic-helm-charts-certs:/tmp/elastic-certificates.p12 ./ && \
		docker rm -f elastic-helm-charts-certs && \
		openssl pkcs12 -nodes -passin pass:'' -in elastic-certificates.p12 -out elastic-certificate.pem && \
		openssl x509 -outform der -in elastic-certificate.pem -out elastic-certificate.crt && \
		kubectl create secret generic elastic-certificates --from-file=elastic-certificates.p12 -n elk && \
		kubectl create secret generic elastic-certificate-pem --from-file=elastic-certificate.pem -n elk && \
		kubectl create secret generic elastic-certificate-crt --from-file=elastic-certificate.crt -n elk && \
		rm -f elastic-certificates.p12 elastic-certificate.pem elastic-certificate.crt elastic-stack-ca.p12


kibana-secrets:
	@encryptionkey=$$(docker run --rm docker.elastic.co/kibana/kibana:8.14.3 /bin/sh -c "< /dev/urandom tr -dc _A-Za-z0-9 | head -c 50") && \
	kubectl create secret generic kibana --from-literal=encryptionkey=$$encryptionkey -n elk
