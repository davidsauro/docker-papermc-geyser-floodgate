# JRE base
FROM openjdk:17-slim

# Environment variables
ENV MC_VERSION="latest" \
    PAPER_BUILD="latest" \
    MC_RAM="4g" \
    JAVA_OPTS=""

COPY papermc.sh .
RUN apt-get update \
    && apt-get install -y wget \
    && apt-get install -y jq \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /papermc

COPY ./geyeserMCConfig.yaml /papermc/plugins/Geyser-Spigot/config.yaml

# Start script
CMD ["sh", "./papermc.sh"]

#kubectl exec --stdin --tty shell-demo -- /bin/bash

# Container setup
EXPOSE 25565/tcp
EXPOSE 19132/udp
VOLUME /papermc
