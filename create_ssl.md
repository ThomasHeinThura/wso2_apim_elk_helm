Create SSL cert for nginx
Execute following commands,

openssl genrsa -des3 -out amwso2com.key 2048
openssl req -new -key amwso2com.key -out amserver.csr

Use *.am.wso2.com as CN

cp amwso2com.key amwso2com.key.org

openssl rsa -in amwso2com.key.org -out amwso2com.key
openssl x509 -req -days 365 -in amserver.csr -signkey amwso2com.key -out amwso2com.crt

Copy the certificate and Key files to nginx/conf or in Mac nginx/ssl.

Import Certificate to APIM

keytool -import -alias amwso2com -file amwso2com.crt -keystore client-truststore.jks -storepass wso2carbon