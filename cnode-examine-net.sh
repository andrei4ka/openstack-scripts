#!/bin/bash

## needed packages (ubuntu) - iproute, iptables, dialog, ebtables, traceroute, libvirt-bin, bridge-utils

function check_root()
{
    if test "$(whoami)" != "root" ; then
        echo "$0 must be run as root" >&2
        exit 1
    fi
}

function echo_n()
{
	echo -n "$1 ... $2"
}

function echo_done()
{
	echo "done."
}


check_root

LABEL=$(hostname)-$(date --utc +%y%m%d%H%M)-net
TMP_DIR=$(mktemp -d)
OUT=$TMP_DIR/$LABEL
ARCHIVE=./$LABEL.tar.gz
USER=${SUDO_USER:-$(whoami)}
GROUP=$(groups $USER | cut -f 1 -d ':')

mkdir $OUT

echo_n "ps aux"
ps aux > "$OUT/ps_aux"
echo_done

echo_n "ip a"
ip a > "$OUT/ip_a"
echo_done

echo_n "ip route"
ip route > "$OUT/ip_route"
echo_done

echo_n "brctl show"
brctl show > "$OUT/brctl_show"
echo_done

echo_n "virsh list"
virsh list > "$OUT/virsh_list"
echo_done

echo_n "iptables-save"
iptables-save > "$OUT/iptables-save"
echo_done

echo_n "traceroute to 8.8.8.8"
traceroute -n 8.8.8.8 > "$OUT/trace"
echo_done

echo_n "ebtables dump"
ebtables -t filter -L > "$OUT/ebtables"
ebtables -t nat -L >> "$OUT/ebtables"
echo_done

echo_n "config files copy"
cp -ax /etc/nova $OUT/nova
cp -ax /etc/quantum $OUT/quantum
echo_done


dialog --yesno "Can we restart nova-network?" 10 40
if [ $? -eq 0 ]; then
echo_n "nova-network logs"
reload nova-network
sleep 10
cp /var/log/nova-network.log $OUT
echo_done
fi

echo_n "creating archive" "$ARCHIVE"
tar -C $TMP_DIR -cvzf $ARCHIVE $LABEL
chown $USER.$GROUP $ARCHIVE


echo_n "cleaning up"
rm -rf "$TMP_DIR"
echo_done
