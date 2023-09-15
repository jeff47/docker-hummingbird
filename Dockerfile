FROM ubuntu:22.04

RUN export TZ=Etc/UTC && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone

RUN apt-get update -y && \
	apt-get upgrade -y && \
	apt-get install -y \
	  curl \
	  dnsutils \
	  iproute2 \
	  iptables \
	  tini && \
	groupadd -r vpn

COPY ./AirVPN-Suite-x86_64-1.3.0/bin/hummingbird /usr/local/bin
COPY startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*

HEALTHCHECK --timeout=5s --interval=60s --retries=1 --start-period=15s \
  CMD curl -s https://airvpn.org/api/whatismyip/ | awk '{if (/"airvpn": false,/) { exit 1;}}'

ENTRYPOINT ["tini", "-g",  "--", "/usr/local/bin/startup.sh"]
