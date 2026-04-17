#!/bin/bash

domain=$(cat /etc/data/domain)
token=$(cat /etc/data/token.json | jq -r .access_token)

sleep 2

# // VAR
if [[ $(netstat -ntlp | grep -i nginx | grep -i 0.0.0.0:8081 | awk '{print $4}' | cut -d: -f2 | xargs | sed -e 's/ /, /g') == '8081' ]]; then
    NGINX="Online";
else
    NGINX="Offline";
fi
if [[ $(netstat -ntlp | grep -i python | grep -i "127.0.0.1:7879" | awk '{print $4}' | cut -d: -f2 | xargs | sed -e 's/ /, /g') == "7879" ]]; then
    MARZ="Online";
else
    MARZ="Offline";
fi
if [[ $(systemctl status ufw | grep -w Active | awk '{print $2}' | sed 's/(//g' | sed 's/)//g' | sed 's/ //g') == 'active' ]]; then
    UFW="Online";
else
    UFW="Offline";
fi

# Function to fetch system information from Marzban API
function get_marzban_info() {

    local marzban_api="https://${domain}/api/system"
    local marzban_info=$(curl -s -X 'GET' "$marzban_api" -H 'accept: application/json' -H "Authorization: Bearer $token")

    if [[ $? -eq 0 ]]; then
# Parsing Marzban API response
marzban_version=$(echo "$marzban_info" | jq -r '.version')
    else
        echo -e "Failed to fetch Marzban information."
        exit 1
    fi
}
# Usage of the function
get_marzban_info "your_domain_here" "your_token_here"

versimarzban=$(grep 'image: gozargah/marzban:' /opt/marzban/docker-compose.yml | awk -F: '{print $3}')
  # Replace values and specific version
  case "${versimarzban}" in
    "latest") versimarzban="Stable";;
    "dev") versimarzban="Beta";;
  esac
# Function to get Xray Core version
function get_xray_core_version() {
    xray_core_info=$(curl -s -X 'GET' \
        "https://${domain}/api/core" \
        -H 'accept: application/json' \
        -H "Authorization: Bearer ${token}"
    )
    xray_core_version=$(echo "$xray_core_info" | jq -r '.version')

    echo "$xray_core_version"
}
# Get Xray Core version
xray_core_version=$(get_xray_core_version "$domain" "$token")

# System Information
os_version=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')

# Cpu Usage
cpu_usage1="$(ps aux | awk 'BEGIN {sum=0} {sum+=$3}; END {print sum}')"
cpu_usage="$((${cpu_usage1/\.*} / ${corediilik:-1}))"
cpu_usage+=" %"

# Ram Usage
ram_usage1="$(ps aux | awk 'BEGIN {sum=0} {sum+=$4}; END {print sum}')"
ram_usage="${ram_usage1/\.*}"
ram_usage+=" %"

# Uptime & Latency
uptime_vps=$(uptime -p | cut -d " " -f 2-10)
ping=$(ping -c 1 -W 1 -q "1.1.1.1" 2>/dev/null | grep rtt | cut -d'=' -f2 | cut -d'/' -f1 | tr -d ' ')

# Get IP
myip=$(curl -s ipv4.icanhazip.com)
isp=$(curl -s ipinfo.io/org)

# Login info
userpanel=$(cat /etc/data/userpanel)
passpanel=$(cat /etc/data/passpanel)

echo -e "———————————————————————————————————————————————————————"
echo -e "                  ⇱ System Information ⇲               "
echo -e "———————————————————————————————————————————————————————"
echo -e "  System            : ${os_version}"
echo -e "  CPU Usage         : ${cpu_usage}"
echo -e "  RAM Usage         : ${ram_usage}"
echo -e "  Uptime            : ${uptime_vps}"
echo -e "  Domain            : ${domain}"
echo -e "  IP                : ${myip}"
echo -e "  ISP               : ${isp}"
echo -e "  Latency           : ${ping} ms"
echo -e "———————————————————————————————————————————————————————"
echo -e "                    ⇱ Service Status ⇲                 "
echo -e "———————————————————————————————————————————————————————"
echo -e "  Marzban Version   : ${marzban_version} ${versimarzban}"
echo -e "  Core Version      : Xray ${xray_core_version}"
echo -e "  Nginx             : ${NGINX}"
echo -e "  Firewall          : ${UFW}"
echo -e "  Marzban Panel     : ${MARZ}"
echo -e "———————————————————————————————————————————————————————"
echo -e "                   ⇱ Dashboard Login ⇲                 "
echo -e "———————————————————————————————————————————————————————"
echo -e "  URL Dashboard     : https://${domain}/dashboard"
echo -e "  Username          : ${userpanel}"
echo -e "  Password          : ${passpanel}"
echo -e "  Support           : t.me/dudulrealnofek"
echo -e "  Group Chat        : t.me/tfnuklir"
echo -e "———————————————————————————————————————————————————————"
echo -e "            ⇱ Thanks For Using Our Services ⇲          "
echo -e "———————————————————————————————————————————————————————"
echo ""
