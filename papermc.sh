#!/bin/bash

# Make make Geyser-Spigot directory for config file
mkdir -p /papermc/plugins/Geyser-Spigot/

# Move config file into the plugins folder for Geyser
mv ./geyeserMCConfig.yml /papermc/plugins/Geyser-Spigot/config.yml
mv ./server.properties /papermc/server.properties

# Enter server directory
cd papermc

# Get version information and build download URL and jar name
#!/usr/bin/env sh

PROJECT="paper"
MINECRAFT_VERSION="1.21.4"

LATEST_BUILD=$(curl -s https://api.papermc.io/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds | \
    jq -r '.builds | map(select(.channel == "default") | .build) | .[-1]')

if [ "$LATEST_BUILD" != "null" ]; then
    JAR_NAME=${PROJECT}-${MINECRAFT_VERSION}-${LATEST_BUILD}.jar
    PAPERMC_URL="https://api.papermc.io/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds/${LATEST_BUILD}/downloads/${JAR_NAME}"

    # Download the latest Paper version
    curl -o server.jar $PAPERMC_URL
    echo "Download completed"
else
    echo "No stable build for version $MINECRAFT_VERSION found :("
fi

# Update if necessary
# If this is the first run, accept the EULA
if [ ! -e eula.txt ]
then
  # Run the server once to generate eula.txt
  java -jar server.jar
  # Edit eula.txt to accept the EULA
  sed -i 's/false/true/g' eula.txt
fi

# Add RAM options to Java options if necessary
if [ ! -z "${MC_RAM}" ]
then
  JAVA_OPTS="-Xms${MC_RAM} -Xmx${MC_RAM} ${JAVA_OPTS}"
fi

# Download Geyser and Floodgate
wget -O Geyser-Spigot.jar https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot
wget -O floodgate-spigot.jar https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot

# Put the downloaded Geyser-Spigot JAR file into the plugins directory
mv ./Geyser-Spigot.jar ./plugins
# Put the downloaded floodgate-spigot JAR file into the plugins directory
mv ./floodgate-spigot.jar ./plugins

# Start server
exec java -server ${JAVA_OPTS} -jar server.jar nogui

#kubectl exec --stdin --tty mcs-0 -- bin/bash get a bash to the pod