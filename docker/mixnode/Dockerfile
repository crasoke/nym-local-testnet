FROM rust:latest

RUN apt-get update \
    && apt-get -y install pkg-config build-essential libssl-dev curl jq git

WORKDIR /app
RUN git clone https://github.com/nymtech/nym.git \
    && cd nym \
    && git checkout master \
    && cargo build --release

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]