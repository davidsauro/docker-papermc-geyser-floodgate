## Forked From:
- (https://github.com/smcbride-ca/papermc-geyser-docker).

## Why Fork?
Originally the above image was a great starting point but the shell script was a bit out of date and the jar files specified to be downloaded were returning 404s. This was also not setup to run in a kubernetes cluster which I am trying (my brain hurts) to get working. There is a work in progress kubernetes.yaml file in this repo that you SHOULD be able to deploy to a cluster, but I make no promises of it working at this time. I am still trying to figure some of this out. See the Kubernetes section for more info

# PaperMC-Geyser-Floodgate
This is a Linux Docker image for the PaperMC Minecraft server, GeyserMC, and Floodgate.

PaperMC is an optimized Minecraft server with plugin support (Bukkit, Spigot, Sponge, etc.).
This image provides a PaperMC server with the Geyser and Floodgate plugins, which allow Bedrock players to join a Java server. Floodgate allows a user to log in with their Microsoft Account 
# Install Docker
It is assumed that the user has already acquired a working Docker installation. If that is not the case, go do that and come back here when you're done. [Docker Install Guide](https://docs.docker.com/get-docker/)

Docker can also be installed by running the following commands
```shell
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh --dry-run
```

# Pull / Build
This image is available here: `docker pull etharis/minecraft:latest`

If you want to build it yourself. This is a very simple process.

```shell
git clone https://github.com/davidsauro/docker-papermc-geyser-floodgate.git
cd papermc-geyser-docker
docker build . -t etharis/minecraft:latest
```
## Command
### Important Note
*Don't run the following commands as the root user or with root privileges. That isn't needed if docker is set up correctly along with your file permissions. This applies to any command that says `docker run`*

With this image, you can create a new PaperMC Minecraft server with one command (note that running said command indicates agreement to the Minecraft EULA). Here is an example:

```docker run -p 25565:25565 -p 19132:19132/udp etharis/minecraft```

While this command will work just fine in many cases, it is only the bare minimum required to start a functional server and can be vastly improved by specifying some...
## Options
There are several command line options that users may want to specify when utilizing this image. These options are listed below with some brief explanation. An example will be provided with each. In the example, the part that the user can change will be surrounded by angle brackets (`< >`). Remember to *remove the angle brackets* before running the command.
- Port
  - This option must be specified. Use ports `25565` and `19132` if you don't know what this is.
  - Set this to the port number that the server will be accessed from.
  - If RCON is to be used, this option must be specified a third time for port `25575`.
  - `-p <12345>:25565 -p <23456>:19132/udp`
  - `-p <12345>:25565 -p <23456>:19132/udp -p <34567>:25575`
  - *Do not* remove the `/udp` after `19132`. It is essential for Bedrock support.

- Volume
  - Set this to a name for the server's Docker volume (defaults to randomized gibberish).
  - Alternatively, set this to a path to a folder on your computer.
  - `-v <my_volume_name>:/papermc`
  - `-v </path/to/files>:/papermc`
- Detached
  - Include this to make the container independent from the current command line.
  - `-d`
- Terminal/Console
  - Include these flags if you want access to the server's command line via `docker attach`.
  - These flags can be specified separately or as one option.
  - `-t` and `-i` in any order
  - `-ti` or `-it`
- Restart Policy
  - If you include this, the server will automatically restart if it crashes.
  - Stopping the server from its console will still stop the container.
  - It is highly recommended to only stop the server from its console (not via Docker).
  - `--restart on-failure`
- Name
  - Set this to a name for the container (defaults to a couple of random words).
  - `--name "<my-container-name>"`
- User
	- Set the UID of the user that will be running this container. This helps avoid file permission issues.
	- `--user 1000:1000`

The command I would recommend using goes something like this:

```docker run -p 25565:25565 -p 19132:19132/udp -v /home/minecraft/server:/papermc -d -ti --restart on-failure -e MC_RAM="4G" -e TZ="America/Toronto" --name "minecraft" --user 1001:1001 smcbride/papermc-geyser-floodgate```

Replace the timezone, uid, and allocated ram with the correct values for your system.

There is one more command line option, but it is a bit special and deserves its own section.

### Environment Variables
Environment variables are options that are specified in the format `-e <NAME>="<VALUE>"` where `<NAME>` is the name of the environment variable and `<VALUE>` is the value that the environment variable is being set to. Please note that setting an evironment variable with no value does not leave it at default; instead, this sets it to an empty string, which may cause issues. This image has four environment variables:
- Minecraft Version
  - **Name:** `MC_VERSION`
  - **NOT SUPPORTED WITH GEYSER**
    - This requires ViaVersion and in certain cases, ViaBackwards/ViaRewind
  - Set this to the Minecraft version that the server should support.
  - Note: there must be a PaperMC release for the specified version of Minecraft.
  - If this is not set, the latest version supported by PaperMC will be used.
  - Changing this on an existing server will change the version *without wiping the server*.
  - `-e MC_VERSION="<latest>"`

- PaperMC Build
  - **Name:** `PAPER_BUILD`
  - Set this to the number of the PaperMC build that the server should use (**not the Minecraft version**).
  - If this is not set, the latest PaperMC build for the specified `MC_VERSION` will be used.
  - Changing this on an existing server will change the version *without wiping the server*.
  - `-e PAPER_BUILD="<latest>"`
- RAM
  - **Name:** `MC_RAM`
  - Set this to the amount of RAM the server can use.
  - Must be formatted as a number followed by `M` for "Megabytes" or `G` for "Gigabytes".
  - If this is not set, Java allocates its own RAM based on total system/container RAM.
  - `-e MC_RAM="<4G>"`
- Java options
  - **Name:** `JAVA_OPTS`
  - **ADVANCED USERS ONLY**
  - Set to any additional Java command line options that you would like to include.
  - By default, this environment variable is set to the empty string.
  - `-e JAVA_OPTS="<-XX:+UseConcMarkSweepGC -XX:+UseParNewGC>"`
## Further Setup
From this point, the server should be configured in the same way as any other Minecraft server. The server's files, including `server.properties`, can be found in the volume that was specified earlier. The port that was specified earlier will probably need to be forwarded as well. For details on how to do this and other such configuration, Google it, because it works the same as any other Minecraft server.

There is one change required in `server.properties` for Bedrock support to function. You must set `enforce-secure-profile=false`
- Please note that this will allow users with chat signing disabled to join your world.
# Technical
This project *does **NOT** redistribute the Minecraft server files*. Instead, the (very small) script that is inside of the image, `papermc.sh`, downloads these files from their official sources during installation.

## Kubernetes
With this config, (see kubernetes.yaml) I can't get the traffic to forward to the kuberneties cluser IP, so I need
to do some port forwarding, but as far as I can tell kubectl doesn't support UDP forwarding for 
some stupid reason so I had to install a plugin to accomplish it
here is the command I used -  kubectl relay --address 0.0.0.0 pod/mcs-0 19132:19132

The plugin I used is from [here](https://github.com/knight42/krelay) installed via [Krew](https://krew.sigs.k8s.io/)

This probably has something to do with the fact that I am using MiniKube on an M1 Mac running Linux. I haven't tested this in a cloud provider yet, but I plan on doing that soon.

**PLEASE NOTE:** 
This is an unofficial project.

I did not create PaperMC. [This is the official PaperMC website.](https://papermc.io/)

I did not create Geyser or Floodgate [This is the official GeyserMC website](https://geysermc.org/)

## Project Pages
- [GitHub page](https://github.com/davidsauro/docker-papermc-geyser-floodgate.git).
