#!/bin/bash
set -euo pipefail

# Download and install awscli
if ! command -v aws &> /dev/null; then
    wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip"
	unzip awscliv2.zip
	./aws/install
fi

# Download and install mkcert
wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64 -O mkcert
mv mkcert /usr/local/bin
chmod +x /usr/local/bin/mkcert

mkcert -ecdsa -install
mkcert -ecdsa -cert-file relay-server.crt -key-file relay-server.key localhost 127.0.0.1 ::1 relay 192.168.14.33
cp $(mkcert -CAROOT)/rootCA.pem .

upload_file() {
    local file=$1
    if [ -f "${file}" ]; then
        echo "Uploading ${file} to S3..."
        aws s3 cp "${file}" "${S3_DESTINATION}/${file}"
        echo "${file} uploaded successfully!"
    else
        echo "Error: ${file} not found."
        exit 1
    fi
}

upload_file relay-server.crt
upload_file relay-server.key
upload_file rootCA.pem

echo "Certificates and keys are uploaded successfully!"
