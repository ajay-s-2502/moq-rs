FROM debian:bookworm-slim

RUN apt update && \
	apt install -y --no-install-recommends ca-certificates libssl3 wget unzip

WORKDIR /app
COPY dev/install-certs.sh .

ENV AWS_ACCESS_KEY_ID=XXXXX
ENV AWS_SECRET_ACCESS_KEY=XXXXX
ENV AWS_DEFAULT_REGION=XXXXX
ENV S3_DESTINATION=XXXXX

ENTRYPOINT [ "bash", "install-certs.sh" ]
