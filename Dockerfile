FROM debian:latest

RUN apt update -y && apt upgrade && apt install openssl vim -y
RUN mkdir /root/catools/
WORKDIR /root/ca/

COPY make_cas.sh /root/catools/make_cas.sh
RUN chmod +x /root/catools/make_cas.sh

CMD ["/bin/bash", "-c", "/root/catools/make_cas.sh"]
