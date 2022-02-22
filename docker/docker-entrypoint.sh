
# We have to copy the certificates because we cannot change permissions on them as mounted secrets and
# voms-proxy is particular about permissions
echo -e "Generating proxy..."
cp /opt/certs/hostcert.pem /tmp/cert.pem
cp /opt/certs/hostkey.pem /tmp/key.pem
chmod 400 /tmp/key.pem

# Generate a proxy with the voms extension if requested
voms-proxy-init --debug \
    -rfc \
    -valid 96:00 \
    -cert /tmp/cert.pem \
    -key /tmp/key.pem \
    -out /tmp/x509up \
    -voms ${VOMS_STR} \
    -timeout 5

mkdir /opt/proxy
cp /tmp/x509up /opt/proxy/x509up

while [ 1 ]
do
    sleep 10000
done