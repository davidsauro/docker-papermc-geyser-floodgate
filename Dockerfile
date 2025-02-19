# JRE base
FROM eclipse-temurin:21

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

#get the config file into the root
COPY ./geyeserMCConfig.yml .
COPY ./server.properties .

# Start script
CMD ["sh", "./papermc.sh"]

# Container setup
EXPOSE 25565/tcp
EXPOSE 19132/udp
VOLUME /papermc
