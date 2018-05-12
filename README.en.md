What is this about?
--------------------
This project has a sample configure, that can be used for a Freifunk-Node.
You can copy this configuration to router, change and apply it.

You need OpenWRT/LEDE 17.0.1 installed on a router and enough free flash space. The router has to be
connected to the internet (wan port) an to a pc or laptop (lan port).

This intro assumes, that you're familiar with linux console (or Mac OS, Unix, etc.)
and that can `ssh` to your router. In addition, `git` is required.

Kick start
------------------------
#### Let's go

Execute this commands on your pc / laptop.

1. Clone the repository `git clone https://github.com/yanosz/node-config.git`
2. Copy files to your router: `cd node-config; scp -r freifunk root@192.168.1.1:/lib`
3. Setup your router interactily: `ssh root@192.168.1.1 /lib/freifunk/install.sh`

#### Note:
* Depending on your commity, IP addresses should be published in a wiki - for Freifunk KBU:  https://kbu.freifunk.net/wiki/index.php?title=IP_Subnetze#Dezentrale_Nodes
* `192.168.1.1` is the lan IP address of your router. If you've changed that, it has to changed accordingly.


Bekannte Probleme
-----------------------
1. The installation of ebtales errrors, since modules are already loaded. This can be ignored.
2. DHCPv6 prefix delegation is untested an probably broken.

Wanna share your internet?
------------------------
Yo can share your internet directly or using an VPN-Tunnel

#### OpenVPN tunnel

To use a vpn tunnel (i.e. mullvad), you can use a configuration in `/lib/freifunk/vpn`
and activate it in [`/etc/config/openvpn`](freifunk/initial_configuration/openvpn.uci).

If you want to use a provider not included in `/lib/freifunk/vpn`,
you can place your provider's configuration there.
Pleas mind adding `route-nopull`, `script-security 2` and `up /lib/freifunk/vpn/up.sh` for default route handling.
([Example:](freifunk/vpn/yanosz/client.conf)).

#### No VPN

If you want to share your internet without a vpn connection, execute these commands:
```bash
uci set network.internet_share.disabled=0
uci set network.internet_share6.disabled=0
uci firewall.freifunk_internet.dest='wan'
uci commit firewall
uci commet network
/etc/init.d/firewall restart
/etc/init.d/network restart
```

By activating `internet_share` and `internet_share6` your default route is copied to the freifunk routing table.
Setting `dest` to `wan` makes the firewall passing packets to your wan ports.

**Note**: *Mind, that not using a vpn probably requires some thoughts on abuse handling.*

Low on flash?
----------------------
If your node only has 4 MB of flash (i.e. TP-Link WR841n), then create a LEDE-Image not having a WebGUI (luci). Examle:

```bash
wget http://downloads.lede-project.org/releases/17.01.4/targets/ar71xx/generic/lede-imagebuilder-17.01.4-ar71xx-generic.Linux-x86_64.tar.xz
tar xf lede-imagebuilder-17.01.4-ar71xx-generic.Linux-x86_64.tar.xz
cd lede-imagebuilder-17.01.4-ar71xx-generic.Linux-x86_64
make image PROFILE="TLWR841" PACKAGES="ip openvpn-mbedtls  babeld fastd owipcalc batctl haveged kmod-nf-nathelper-extra kmod-pptp ppp-mod-pptp  ebtables kmod-ebtables-ipv4"
```

If you are interested in using pptp instead of OpenVPN the command is:
```bash
make image PROFILE="TLWR841" PACKAGES="ip babeld fastd owipcalc batctl haveged kmod-nf-nathelper-extra kmod-pptp ppp-mod-pptp  ebtables kmod-ebtables-ipv4 kmod-nf-nathelper-extra kmod-pptp ppp-mod-pptp"
```


Local supernode?
---------------------
If you want to use your node as a Gluon supernode, you have to enable the corresponding fastd configuration.
After that, restarting the services is needed.

```bash
uci set fastd.supernode.enabled=1
uci commit
/etc/init.d/fastd restart
/etc/init.d/fastd show_key supernode
```
The last command shows your public fastd key. It can be embedded using in a Gluon Makefile.

LEDE packages? Graphical User Interface (GUI)? Firmware ?
-----------------------------

You can also build LEDE / OpenWRT packages. Have a look at the [Makefile](Makefile): `make world` builds all packages

The GUI is under development. For details see: https://github.com/yanosz/firmware-wizard-frontend

LEDE Firwmare images are placed at https://kbu.freifunk.net/files/node-config/ - it is built by
For the build repository have a look at https://git.kbu.freifunk.net/yanosz/node-config-feed.

For opkg-feeds you can access the server without TLS: http://opkg.freifunk.net/files/node-config/
Die
The details Details
-----------------------
#### Shell-Scripts
Shell-Scripts are used to install the configuration. There is:
* [freifunk/install_software.sh](freifunk/install_software.sh) - installs all needed packages
* [freifunk/import_configuration.sh](freifunk/import_configuration.sh) - imports the configuration
* [freifunk/set_ip.sh](freifunk/set_ip.sh) - Sets all  IP-adresses and subnets in the complete configuration
* [freifunk/install.sh](freifunk/install.sh) - wraps all scripts; executes them in the right order

#### Configuration
The configuration is split into .uci-files, which are imported: Except: ebtables and wireless: Here, settings have to be generated dynamically.
An overview is provided in the following. All files have comments (German) with further explainations.

##### Babeld - [freifunk/initial_configuration/babeld.uci](freifunk/initial_configuration/babeld.uci)
Babel is uses as routing protocol. It uses ad-hoch interfaces for meshing and fastd instance to connect to other nodes and the Inter City VPN (ICVPN).

##### batman-adv - [freifunk/initial_configuration/batman-adv.uci](freifunk/initial_configuration/batman-adv.uci)
batman-adv is used for roaming within the mesh segment. Every node is a gateway and operates a dhcp-server.

##### dhcp / radvd - [freifunk/initial_configuration/dhcp.uci](freifunk/initial_configuration/dhcp.uci)
The access point runs dhcp and radvd services for its clients. It uses private (resp. ULA) addresses.
If public IPv6 addresses are available, they are used, too.

This configuration is supported using a shell script for `/etc/firewall.user`, that is not managed using uci.

##### Multicast-Filter - [freifunk/initial_configuration/firewall.sh](freifunk/initial_configuration/firewall.sh)
Multicast / Anycast is restricted in the batman-adv mesh, since it is used for roaming, only.
Also, ip rules are set within this file.

##### fastd - [freifunk/initial_configuration/fastd.uci](freifunk/initial_configuration/fastd.uci)
fastd is used to connect to nodes without radio contact. For testing, a node accessing the icvpn is used.
Routing is done using babeld. [freifunk/initial_configuration/fastd_binding.sh](freifunk/initial_configuration/fastd_binding.sh)
is used to bind fastd to the correct interfaces.

A fastd instance for running a gluon supernode is available but inactive.

##### Firewall - [freifunk/initial_configuration/firewall.uci](freifunk/initial_configuration/firewall.uci)
The firewall defines zones for Freifunk and vpn tunnels connecting to the internet.
Traffic from Freifunk to WAN / LAN is rejected by default. This can be turned off for internet sharing.

**The node is reachable using ssh from the freifunk zone.**

##### Network - [freifunk/initial_configuration/network.uci](freifunk/initial_configuration/network.uci)
The network configuration defines all interfaces for wifi, fatd, and vpn. In addition it configures routing tables
for policy routing.

Also, there is a configuration for PPtP, in case you want to use it for a vpn uplink.

##### OpenVPN - [freifunk/initial_configuration/openvpn.uci](freifunk/initial_configuration/openvpn.uci)
The uci file lists examples for vpn configuration of different providers. The provider configuration is placed in [freifunk/vpn](freifunk/vpn).
Depending on the vpn provider, you need to place keys or certificates in there. After that, you can enable
providers by editing `/etc/config/openvpn`.

- Mullvad
    - certificate: `/lib/freifunk/vpn/mullvad/mullvad.crt`
    - Key: `/lib/freifunk/vpn/mullvad/mullvad.key`
- Freifunk Berlin
    -  Certificate: `/lib/freifunk/vpn/freifunk_berlin/berlin.crt`
    -  Key: `/lib/freifunk/vpn/freifunk_berlin/berlin.key`
    -  Infos:  https://wiki.freifunk.net/Vpn03
- Freifunk KBU:
    - Zertfikat `/lib/freifunk/vpn/freifunk_kbu/<Deine E-Mail-Adresse>.crt`
    - Key: `/lib/freifunk/vpn/freifunk_kbu/<Deine E-Mail-Adresse>.`
    - Infos: https://kbu.freifunk.net/wiki/vpn-exit
- yanosz (For testing):
    - Zertfikat `/lib/freifunk/vpn/yanosz/<Deine E-Mail-Adresse>.crt`
    - Key: `/lib/freifunk/vpn/yanosz/<Deine E-Mail-Adresse>.key`
    - Infos: freifunk@yanosz.net

##### Wifi - [freifunk/initial_configuration/wireless.sh](freifunk/initial_configuration/wireless.sh)
The wifi configuration defines to network (ad-hoc + ap).

If a second wifi device is available, 5 Ghz is assumed.

If there is a unused lede default configuration on this adapter, it is set inactive.
