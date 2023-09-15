# hummingbird-docker
Docker container for AirVPN's hummingbird OpenVPN client

This is a docker container for [AirVPN](https://gitlab.com/AirVPN/hummingbird)'s hummingbird client.  (https://gitlab.com/AirVPN/hummingbird)  My motivation for making a docker version is to simplify the tunneling of other docker containers through the VPN tunnel.

An example docker-compose file is included.

## Installation
Refer to the docker-compose file for details.

In the example below, config files are stored in a subdirectory off the docker-compose.yml root called ```openvpn-client```.  You can change the name and location of this directory to whatever you want, as long as you update the entry in docker-compose.yml.

1. Download the docker-compose.yml file included, or create your own based on the example.
2. Create a subdirectory ```openvpn-client/``` to hold the config file and the ovpn file.  
3. From your AirVPN client area, use the config generator to create a ovpn file.  Keep this file private — it contains login information linked to your account. Put this file into ```openvpn-client/```
4. Create the file ```hummingbird.ini``` in ```openvpn-client/```.
5. Add the required line ```ovpn-config``` pointing to the ovpn file you downloaded in step 3.  Make sure the path matches the path from inside the container, not on the host filesystem.

