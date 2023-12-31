#!/bin/bash

# Make make Geyser-Spigot directory for config file
mkdir -p /papermc/plugins/Geyser-Spigot/

# Move config file into the plugins folder for Geyser
mv ./geyeserMCConfig.yml /papermc/plugins/Geyser-Spigot/config.yml

# Enter server directory
cd papermc

# Get version information and build download URL and jar name
URL=https://papermc.io/api/v2/projects/paper
if [ ${MC_VERSION} = latest ]
then
  # Get the latest MC version
  MC_VERSION=$(wget -qO - $URL | jq -r '.versions[-1]') # "-r" is needed because the output has quotes otherwise
fi
URL=${URL}/versions/${MC_VERSION}
if [ ${PAPER_BUILD} = latest ]
then
  # Get the latest build
  PAPER_BUILD=$(wget -qO - $URL | jq '.builds[-1]')
fi
JAR_NAME=paper-${MC_VERSION}-${PAPER_BUILD}.jar
URL=${URL}/builds/${PAPER_BUILD}/downloads/${JAR_NAME}

# Update if necessary
if [ ! -e ${JAR_NAME} ]
then
  # Remove old server jar(s)
  rm -f *.jar
  # Download new server jar
  wget ${URL} -O ${JAR_NAME}
  
  # If this is the first run, accept the EULA
  if [ ! -e eula.txt ]
  then
    # Run the server once to generate eula.txt
    java -jar ${JAR_NAME}
    # Edit eula.txt to accept the EULA
    sed -i 's/false/true/g' eula.txt
  fi
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
exec java -server ${JAVA_OPTS} -jar ${JAR_NAME} nogui

#kubectl exec --stdin --tty mcs-0 -- bin/bash get a bash to the pod