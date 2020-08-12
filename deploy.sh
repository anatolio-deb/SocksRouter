#!bin/sh

##########################################################
# deploy.sh - a router deployment script for debian 10.5 #
#                                                        #
#                                   Anatolio Nikiforides #
#                                             12.08.2020 #
#                                                        #
# ################                                       #
# # Requirements #                                       #
# ################                                       #
#                                                        #
# Debian 10.5                                            #
# git                                                    #
# make                                                   #
# cmake                                                  #
# badvpn-tun2socks                                       #
# systemd-networkd                                       #
# tor                                                    #
# obfs4proxy                                             #
# dnscrypt-proxy (optional)                              #
# hostapd (optional)                                     #
##########################################################

echo "Stage 1: setting up badvpn-tun2socks."
echo "Getting resources."
apt install git
git clone https://github.com/ambrop72/badvpn/
apt install make cmake
echo "Procceding to build."
mkdir badvpn-build
cd badvpn-build
cmake ../badvpn -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_TUN2SOCKS=1
make install
echo "Installed to the system."
echo "Creating systemd service."
wget -P /etc/systemd/system/ https://raw.githubusercontent.com/anatolio-deb/SocksRouter/master/systemd/system/tun2socks.service
systemctl daemon-reload
echo "The service created."
echo "Stage 2: Setting up systemd-networkd."
wget -P /etc/systemd/network/ https://raw.githubusercontent.com/anatolio-deb/SocksRouter/master/systemd/network/25-wlp6s0.network
wget -P /etc/systemd/network/ https://raw.githubusercontent.com/anatolio-deb/SocksRouter/master/systemd/network/25-tun2socks.netdev
wget -P /etc/systemd/network/ https://raw.githubusercontent.com/anatolio-deb/SocksRouter/master/systemd/network/25-tun2socks.network
#wget -P /etc/systemd/network/ https://raw.githubusercontent.com/anatolio-deb/SocksRouter/master/systemd/network/25-ap0.network
echo "Stage 3: Installing tor."
apt install tor obfs4proxy
wget -P /etc/tor/ https://raw.githubusercontent.com/anatolio-deb/SocksRouter/master/tor/torrc
echo "Optional stage."
while true; do
    read -p "Do you want to use dnscrypt-proxy over tor?" yn
    case $yn in
        [Yy]* ) apt install dnscrypt-proxy && \
            wget -P /etc/dnscrypt-proxy/ https://raw.githubusercontent.com/anatolio-deb/SocksRouter/master/dnscrypt-proxy/dnscrypt-proxy.toml && \
            echo 'nameserver 127.0.2.1' > /etc/resolv.conf;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
while true; do
    read -p "Do you want to have a virtual access point?" yn
    case $yn in
        [Yy]* ) apt install util-linux procps iw hostapd && \
            git clone https://github.com/oblique/create_ap && \
            cd create_ap && \
            make install && \
            # get dnscrypt-proxy.socket && \
            wget -P /etc/  https://raw.githubusercontent.com/anatolio-deb/SocksRouter/master/create_ap.conf;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
