#!/bin/bash
set -e
M='\033[38;5;121m'
P='\033[38;5;141m'
K='\033[38;5;211m'
C='\033[38;5;117m'
R='\033[0m'
B='\033[1m'
IP=$(ip -4 route get 1 2>/dev/null|awk '{print $7;exit}'||hostname -I|awk '{print $1}')
SNI=("www.bayer.de" "www.siemens-healthineers.com" "www.swarovski.com" "www.berghaus.com" "www.deutsche-bank.de" "www.wittchen.com" "www.conrad.de" "www.kloeckner.de" "www.groupon.de" "www.lamy.com" "www.moleskine.com" "www.fissler.com" "www.vaillant.de" "www.wilo.com" "www.brother.de" "www.epson.de" "www.canon.at" "www.nikon.fr" "www.olympus-europa.com" "www.leifheit.de" "www.electrolux.de" "www.miele.de" "www.liebherr.com" "www.neff-home.com" "www.gaggenau.com" "www.blanco.com" "www.schock.de" "www.franke.com" "www.roca.com" "www.hansgrohe.com" "www.grohe.de" "www.duravit.de" "www.villeroy-boch.com" "www.geberit.com" "www.ifworlddesignguide.com" "www.design-milk.com" "www.dezeen.com" "www.archdaily.com" "www.wallpaper.com" "www.ignant.com" "www.itsnicethat.com" "www.creativereview.co.uk")
OS="";[ -f /etc/os-release ]&&{ . /etc/os-release;OS=$ID; }
h(){ clear;echo -e "${K}       _      _";echo -e "${K}      / \\${P}    / \\";echo -e "${K}     (   \\${P}  /   )";echo -e "${P}      \\   \/   /  ${C}   [ re minor ]";echo -e "${P}       \\  /\\  /   ${B}${R}    автоматическая конфигурация vpn";echo -e "${C}       /  /\\  \\ ";echo -e "${C}      (  /  \\  )  ${P}    status: ready to deploy";echo -e "${C}       \\_/    \\_/ ";echo -e "${R} --------------------------------------------------------"; }
g(){ local t="$1" c=("$K" "$P" "$C" "$M") l=${#t} r="";for((i=0;i<l;i++));do r+="${c[$((i%4))]}${t:$i:1}";done;echo -e "${r}${R}"; }
p(){ echo -ne "${K}re minor ${P}> ${R}"; }
wp(){ local l=true a=0;while [ "$l" = true ]&&[ $a -lt 15 ];do l=false;for x in dpkg apt yum dnf;do if pgrep -x "$x">/dev/null 2>&1;then l=true;h;g "[ re minor ] ожидание освобождения системного менеджера пакетов...";sleep 1;a=$((a+1));break;fi;done;[ "$l" = false ]&&break;done;if [ $a -ge 15 ];then for x in dpkg apt yum dnf;do pkill -9 "$x" 2>/dev/null||true;done;sleep 2;fi; }
pkg(){ wp;case "$OS" in ubuntu|debian) apt-get update -y&&apt-get install -y "$1";; almalinux|rocky|rhel|centos) dnf install -y "$1" 2>/dev/null||yum install -y "$1";; arch|manjaro) pacman -S --noconfirm "$1";; fedora) dnf install -y "$1";; esac; }
deps(){ local a=(curl wget jq qrencode openssl uuid-runtime net-tools bc);if ! command -v ss>/dev/null 2>&1;then a+=(iproute2);fi;for x in "${a[@]}";do if ! command -v "$x">/dev/null 2>&1;then pkg "$x"||true;fi;done;if ! command -v qrencode>/dev/null 2>&1;then pkg libqrencode-dev||pkg qrencode-libs||true;fi; }
pp(){ h;g "Выбор портов";echo -e "${C}[ 1 ] авто (случайные непопулярные)";echo -e "${C}[ 2 ] ввести вручную";p;read ppch;if [ "$ppch" = "2" ];then echo -ne "${K}VLESS/Trojan порт: ${R}";read VLESS_PORT;VLESS_PORT=$(fp "$VLESS_PORT");TROJAN_PORT="$VLESS_PORT";echo -ne "${K}Hysteria порт: ${R}";read HYSTERIA_PORT;HYSTERIA_PORT=$(fp "$HYSTERIA_PORT");else VLESS_PORT=$(rp);TROJAN_PORT=$(rp);HYSTERIA_PORT=$(rp);fi;g "Порты: VLESS/Trojan ${VLESS_PORT}, Hysteria ${HYSTERIA_PORT}";sleep 1; }
rp(){ while true;do local p=$((10000+RANDOM%50001));if ! ss -tulpn 2>/dev/null|grep -q ":${p}\\b";then echo "$p";return;fi;done; }
fp(){ local p=$1;while ss -tulpn 2>/dev/null|grep -q ":${p}\\b";do p=$((p+1));done;echo "$p"; }
op(){ local p=$1 t=${2:-tcp};if command -v ufw>/dev/null 2>&1;then ufw allow "${p}/${t}">/dev/null 2>&1||true;elif command -v firewall-cmd>/dev/null 2>&1;then firewall-cmd --permanent --add-port="${p}/${t}">/dev/null 2>&1||true;firewall-cmd --reload>/dev/null 2>&1||true;elif command -v iptables>/dev/null 2>&1;then iptables -I INPUT -p "$t" --dport "$p" -j ACCEPT>/dev/null 2>&1||true;fi; }
ap(){ op "$VLESS_PORT" tcp;op "$TROJAN_PORT" tcp;op "$HYSTERIA_PORT" udp;op "$HYSTERIA_PORT" tcp;op 51820 udp; }
sb(){ if command -v sing-box>/dev/null 2>&1;then return 0;fi;local u=$(curl -sL "https://api.github.com/repos/SagerNet/sing-box/releases/latest"|grep -o '"browser_download_url": "[^"]*linux_amd64\\.deb"'|head -1|sed 's/.*"\\(.*\\)".*/\\1/');if [ -z "$u" ];then u=$(curl -sL "https://api.github.com/repos/SagerNet/sing-box/releases/latest"|grep -o '"browser_download_url": "[^"]*linux_amd64[^"]*"'|head -1|sed 's/.*"\\(.*\\)".*/\\1/');fi;if [ -n "$u" ];then wget -q -O /tmp/sb.pkg "$u";case "$OS" in ubuntu|debian) dpkg -i /tmp/sb.pkg>/dev/null 2>&1||apt-get install -f -y>/dev/null 2>&1;; *) if [[ "$u" == *.tar.gz ]];then tar -xzf /tmp/sb.pkg -C /tmp/;cp /tmp/sing-box*/sing-box /usr/local/bin/sing-box 2>/dev/null||cp /tmp/sing-box /usr/local/bin/sing-box 2>/dev/null;chmod +x /usr/local/bin/sing-box;fi;;esac;rm -f /tmp/sb.pkg;fi;if ! command -v sing-box>/dev/null 2>&1;then curl -sL "https://github.com/SagerNet/sing-box/releases/latest/download/install.sh"|bash||{ wget -qO /usr/local/bin/sing-box "https://github.com/SagerNet/sing-box/releases/latest/download/sing-box-linux-amd64";chmod +x /usr/local/bin/sing-box; };fi; }
gu(){ if command -v uuidgen>/dev/null 2>&1;then uuidgen;else cat /proc/sys/kernel/random/uuid 2>/dev/null||openssl rand -hex 16|sed 's/\\(..\\)/\\1-/g;s/-\\(.\\)-\\(.\\)-\\(.\\)-\\(.\\)/-\\1\\2-\\3\\4/;s/^\\(.*\\)-$/\\1/';fi; }
gp(){ openssl rand -base64 16; }
ga(){ local JC=$((1+RANDOM%1000)) JMIN=$((1+RANDOM%1000)) JMAX=$((1+RANDOM%1000));while [ "$JMIN" -ge "$JMAX" ];do JMAX=$((1+RANDOM%1000));done;echo "$JC $JMIN $JMAX"; }
sp(){ h;g "Выбор SNI";echo -e "${C}[ 1 ] авто (непопулярный домен)";echo -e "${C}[ 2 ] ввести свой";p;read spch;if [ "$spch" = "2" ];then echo -ne "${K}Ваш SNI: ${R}";read SNI_OVERRIDE;fi; }
gs(){ if [ -n "$SNI_OVERRIDE" ];then echo "$SNI_OVERRIDE";return;fi;local i=$((RANDOM%${#SNI[@]}));echo "${SNI[$i]}"; }
sc(){ local a=($1) f="/etc/sing-box/config.json" i=() o='[{"type":"direct","tag":"direct"},{"type":"block","tag":"block"}]' r='{"rules":[{"ip_is_private":true,"outbound":"direct"},{"outbound":"direct"}],"final":"direct","auto_detect_interface":true}';local u=$(gu) w=$(gp) s=$(gs) rk=$(sing-box generate reality-keypair 2>/dev/null) pk=$(echo "$rk"|grep "PrivateKey"|awk '{print $2}') bk=$(echo "$rk"|grep "PublicKey"|awk '{print $2}');mkdir -p /etc/sing-box;echo "{\"uuid\":\"${u}\",\"password\":\"${w}\",\"sni\":\"${s}\",\"public_key\":\"${bk}\",\"private_key\":\"${pk}\",\"vless_port\":${VLESS_PORT},\"trojan_port\":${TROJAN_PORT},\"hysteria_port\":${HYSTERIA_PORT}}">/etc/sing-box/meta.json;for x in "${a[@]}";do case "$x" in vless) i+=("{\"type\":\"vless\",\"listen\":\"::\",\"listen_port\":${VLESS_PORT},\"users\":[{\"uuid\":\"${u}\",\"flow\":\"xtls-rprx-vision\"}],\"tls\":{\"enabled\":true,\"server_name\":\"${s}\",\"reality\":{\"enabled\":true,\"handshake\":{\"server\":\"${s}\",\"server_port\":443},\"private_key\":\"${pk}\",\"short_id\":\"$(openssl rand -hex 4)\"}},\"transport\":{\"type\":\"tcp\"}}");; trojan) i+=("{\"type\":\"trojan\",\"listen\":\"::\",\"listen_port\":${TROJAN_PORT},\"users\":[{\"password\":\"${w}\"}],\"tls\":{\"enabled\":true,\"server_name\":\"${s}\",\"reality\":{\"enabled\":true,\"handshake\":{\"server\":\"${s}\",\"server_port\":443},\"private_key\":\"${pk}\",\"short_id\":\"$(openssl rand -hex 4)\"}}}");; hysteria) hc;i+=("{\"type\":\"hysteria2\",\"listen\":\"::\",\"listen_port\":${HYSTERIA_PORT},\"users\":[{\"password\":\"${w}\"}],\"tls\":{\"enabled\":true,\"certificate_path\":\"/etc/sing-box/certs/hysteria.crt\",\"key_path\":\"/etc/sing-box/certs/hysteria.key\"},\"masquerade\":\"https://www.bing.com\",\"ignore_client_bandwidth\":false}");; amneziawg) read -r JC JMIN JMAX<<<"$(ga)";local ap=$(wg genkey 2>/dev/null||openssl rand -base64 32) ab=$(echo "$ap"|wg pubkey 2>/dev/null||echo "$ap");echo "{\"awg_private\":\"${ap}\",\"awg_public\":\"${ab}\",\"jc\":${JC},\"jmin\":${JMIN},\"jmax\":${JMAX}}">/etc/sing-box/awg_meta.json;i+=("{\"type\":\"amneziawg\",\"listen_port\":51820,\"private_key\":\"${ap}\",\"peers\":[{\"allowed_ips\":\"0.0.0.0/0,::/0\",\"persistent_keepalive\":25,\"persistent_keepalive_interval\":25}]}");;esac;done;local ij=$(IFS=,;echo "${i[*]}");echo "{\"log\":{\"level\":\"info\",\"output\":\"/var/log/sing-box.log\"},\"dns\":{\"servers\":[{\"address\":\"tls://1.1.1.1\"},{\"address\":\"tls://8.8.8.8\"},{\"address\":\"rcode://success\",\"tag\":\"block\"}]},\"inbounds\":[${ij}],\"outbounds\":${o},\"route\":${r}}"|jq .>"$f";chmod 600 "$f"; }
eb(){ if [ -f /proc/sys/net/ipv4/tcp_congestion_control ];then local c=$(cat /proc/sys/net/ipv4/tcp_congestion_control);if [ "$c" != "bbr" ];then modprobe tcp_bbr 2>/dev/null||true;echo "net.core.default_qdisc=fq">>/etc/sysctl.conf 2>/dev/null||true;echo "net.ipv4.tcp_congestion_control=bbr">>/etc/sysctl.conf 2>/dev/null||true;sysctl -p>/dev/null 2>&1||true;fi;fi; }
st(){ cat >/etc/systemd/system/sing-box.service <<EOF
[Unit]
Description=sing-box service
After=network.target nss-lookup.target
[Service]
Type=simple
ExecStart=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload;systemctl enable sing-box>/dev/null 2>&1;systemctl restart sing-box;sleep 2; }
vl(){ local m="/etc/sing-box/meta.json";local u=$(jq -r '.uuid' "$m") s=$(jq -r '.sni' "$m") b=$(jq -r '.public_key' "$m") p=$(jq -r '.vless_port' "$m") i=$(openssl rand -hex 4);echo "vless://${u}@${IP}:${p}?security=reality&sni=${s}&fp=chrome&pbk=${b}&sid=${i}&type=tcp&flow=xtls-rprx-vision#re-minor-vless"; }
tl(){ local m="/etc/sing-box/meta.json";local w=$(jq -r '.password' "$m") s=$(jq -r '.sni' "$m") b=$(jq -r '.public_key' "$m") p=$(jq -r '.trojan_port' "$m") i=$(openssl rand -hex 4);echo "trojan://${w}@${IP}:${p}?security=reality&sni=${s}&fp=chrome&pbk=${b}&sid=${i}&type=tcp#re-minor-trojan"; }
hl(){ local m="/etc/sing-box/meta.json";local w=$(jq -r '.password' "$m") p=$(jq -r '.hysteria_port' "$m");echo "hysteria2://${w}@${IP}:${p}?sni=www.bing.com&insecure=1#re-minor-hysteria2"; }
aw(){ local a="/etc/sing-box/awg_meta.json";[ ! -f "$a" ]&&return;local j=$(jq -r '.jc' "$a") n=$(jq -r '.jmin' "$a") x=$(jq -r '.jmax' "$a") b=$(jq -r '.awg_public' "$a");cat<<EOF
[Interface]
PrivateKey = YOUR_PRIVATE_KEY
Address = 10.0.0.2/32
DNS = 1.1.1.1, 8.8.8.8
Jc = ${j}
Jmin = ${n}
Jmax = ${x}
S1 = 0
S2 = 0
H1 = 1
H2 = 2
H3 = 3
H4 = 4
[Peer]
PublicKey = ${b}
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
Endpoint = ${IP}:51820
EOF
}
sub(){ local c=$1;local v=$(vl) t=$(tl) y=$(hl);local l="${v}\\n${t}\\n${y}";mkdir -p /var/www/html;printf "%b" "$l">/var/www/html/re-minor-sub.txt;if [ "$c" = "hiddify" ];then local e=$(echo -e "$l"|base64 -w0);echo "$e">/var/www/html/re-minor-hiddify.txt;fi;echo "http://${IP}/re-minor-sub.txt"; }
qr(){ local l="$1" n="$2";echo -e "\\n${C}${n}${R}";echo -e "${M}${l}${R}";echo "$l"|qrencode -t ansiutf8 -l L 2>/dev/null||echo -e "${K}[ qrencode не установлен ]${R}"; }
bt(){ local t="$1" i="$2";cat >/usr/local/bin/re_minor_bot.sh <<EOF
#!/bin/bash
T="${t}"
C="${i}"
A="https://api.telegram.org/bot\${T}"
sm(){ local t="\$1";curl -s -X POST "\${A}/sendMessage" -d "chat_id=\${C}" -d "text=\${t}" -d "parse_mode=Markdown">/dev/null 2>&1; }
pb(){ local p=\$1 f=\$((p/10)) e=\$((10-f)) b="";for((x=0;x<f;x++));do b+="█";done;for((x=0;x<e;x++));do b+="░";done;echo "\${b} \${p}%"; }
gc(){ top -bn1 2>/dev/null|grep "Cpu(s)"|awk '{print \$2}'|cut -d'%' -f1||echo "0"; }
gr(){ free -m 2>/dev/null|awk 'NR==2{printf "%.1f/%.1f ГБ",\$3/1024,\$2/1024}'||echo "N/A"; }
gn(){ cat /proc/net/dev 2>/dev/null|awk '/eth0|ens|wlan/{rx=\$2;tx=\$10;exit} END{printf "↓ %.0f KB/s ↑ %.0f KB/s",rx/1024,tx/1024}'||echo "N/A"; }
gv(){ if [ -f /var/log/sing-box.log ];then grep -c "inbound" /var/log/sing-box.log 2>/dev/null||echo "0";else echo "0";fi; }
ss(){ local c=\$(gc) ci=\${c%.*} cb=\$(pb \${ci:-0});local r=\$(gr) n=\$(gn) v=\$(gv);sm "🖥️ ЦП: \${cb}%0A📟 ОЗУ: \${r}%0A🌐 Сеть: \${n}%0A👥 VPN: \${v} сессий"; }
shb(){ local m='       _      _ \n      / \\    / \\\n     (   \\  /   )\n      \\   \/   /       [ re minor ]\n       \\  /\\  /        автоматическая конфигурация vpn\n       /  /\\  \\ \n      (  /  \\  )        status: monitoring\n       \\_/    \\_/ ';sm "\${m}"; }
shb
o=0
while true;do
 u=\$(curl -s "\${A}/getUpdates?offset=\${o}&limit=1")
 if [ -n "\${u}" ];then
  ui=\$(echo "\${u}"|grep -o '"update_id":[0-9]*'|head -1|cut -d':' -f2)
  if [ -n "\${ui}" ];then
   o=\$((ui+1))
   m=\$(echo "\${u}"|grep -o '"text":"[^"]*"'|head -1|sed 's/"text":"//;s/"$//')
   [ "\${m}" = "/status" ]&&ss
  fi
 fi
 sleep 2
done
EOF
chmod +x /usr/local/bin/re_minor_bot.sh; }
ts(){ cat >/etc/systemd/system/re-minor-bot.service <<EOF
[Unit]
Description=re minor Telegram Monitor
After=network.target
[Service]
Type=simple
ExecStart=/bin/bash /usr/local/bin/re_minor_bot.sh
Restart=always
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload;systemctl enable re-minor-bot>/dev/null 2>&1;systemctl restart re-minor-bot; }
tb(){ h;g "Подключить Telegram-бота?";echo -e "${C}[ 1 ] Да";echo -e "${C}[ 2 ] Нет";p;read bc;if [ "$bc" = "1" ];then echo -ne "${K}Bot Token: ${R}";read tk;echo -ne "${K}Chat ID: ${R}";read cid;bt "$tk" "$cid";ts;g "Telegram-бот активирован.";sleep 1;fi; }
bm(){ h;g "Инициализация блиц-режима...";sleep 1;deps;sb;pp;sp;ap;eb;sc "vless trojan hysteria amneziawg";st;h;g "Развертывание завершено.";local v=$(vl) t=$(tl) y=$(hl);local s=$(sub hiddify);qr "$v" "VLESS + Reality";qr "$t" "Trojan + Reality";qr "$y" "Hysteria 2";echo -e "\\n${P}AmneziaWG конфиг:${R}";aw;echo -e "\\n${C}Подписка: ${R}${s}";echo -e "\\n${M}Данные в /etc/sing-box/${R}";tb;if [ -f /usr/local/bin/re_minor_bot.sh ];then local b=$(grep 'T=' /usr/local/bin/re_minor_bot.sh|head -1|cut -d'"' -f2) c=$(grep 'C=' /usr/local/bin/re_minor_bot.sh|head -1|cut -d'"' -f2);if [ -n "$b" ]&&[ -n "$c" ];then curl -s -X POST "https://api.telegram.org/bot${b}/sendMessage" -d "chat_id=${c}" -d "text=VLESS: ${v}"$'\n'"Trojan: ${t}"$'\n'"Hysteria: ${y}"$'\n'"Подписка: ${s}" -d "parse_mode=Markdown">/dev/null 2>&1||true;fi;fi;echo -e "\\n${K}Нажмите Enter...${R}";read; }
cs(){ h;local sp=();g "Выберите протоколы (через пробел):";echo -e "${C}[ 1 ] VLESS + Reality";echo -e "${C}[ 2 ] Trojan + Reality";echo -e "${C}[ 3 ] Hysteria 2";echo -e "${C}[ 4 ] AmneziaWG";p;read pc;for n in $pc;do case "$n" in 1)sp+=("vless");;2)sp+=("trojan");;3)sp+=("hysteria");;4)sp+=("amneziawg");;esac;done;if [ ${#sp[@]} -eq 0 ];then g "Не выбрано. Возврат.";sleep 2;return;fi;h;g "Выберите клиент:";echo -e "${C}[ 1 ] Hiddify Next";echo -e "${C}[ 2 ] v2rayNG / Nekobox";echo -e "${C}[ 3 ] FoXray / Streisand";echo -e "${C}[ 4 ] Amnezia VPN App";p;read cc;local cl="hiddify";case "$cc" in 1)cl="hiddify";;2)cl="v2rayng";;3)cl="foxray";;4)cl="amnezia";;esac;h;g "Настройка: ${sp[*]}...";deps;sb;pp;sp;ap;eb;sc "${sp[*]}";st;h;g "Генерация...";local s=$(sub "$cl");if [[ " ${sp[*]} " =~ " vless " ]];then qr "$(vl)" "VLESS + Reality";fi;if [[ " ${sp[*]} " =~ " trojan " ]];then qr "$(tl)" "Trojan + Reality";fi;if [[ " ${sp[*]} " =~ " hysteria " ]];then qr "$(hl)" "Hysteria 2";fi;if [[ " ${sp[*]} " =~ " amneziawg " ]];then echo -e "\\n${P}AmneziaWG:${R}";aw;fi;echo -e "\\n${C}Подписка: ${R}${s}";tb;if [ -f /usr/local/bin/re_minor_bot.sh ];then local b=$(grep 'T=' /usr/local/bin/re_minor_bot.sh|head -1|cut -d'"' -f2) c=$(grep 'C=' /usr/local/bin/re_minor_bot.sh|head -1|cut -d'"' -f2);if [ -n "$b" ]&&[ -n "$c" ];then local msg="";[[ " ${sp[*]} " =~ " vless " ]]&&msg+="VLESS: $(vl)"$'\n';[[ " ${sp[*]} " =~ " trojan " ]]&&msg+="Trojan: $(tl)"$'\n';[[ " ${sp[*]} " =~ " hysteria " ]]&&msg+="Hysteria: $(hl)"$'\n';msg+="Подписка: ${s}";curl -s -X POST "https://api.telegram.org/bot${b}/sendMessage" -d "chat_id=${c}" -d "text=${msg}" -d "parse_mode=Markdown">/dev/null 2>&1||true;fi;fi;echo -e "\\n${K}Нажмите Enter...${R}";read; }
un(){ h;g "Деинсталляция и очистка...";systemctl stop sing-box 2>/dev/null||true;systemctl disable sing-box 2>/dev/null||true;systemctl stop re-minor-bot 2>/dev/null||true;systemctl disable re-minor-bot 2>/dev/null||true;rm -f /etc/systemd/system/sing-box.service /etc/systemd/system/re-minor-bot.service;systemctl daemon-reload;rm -rf /etc/sing-box /usr/local/bin/sing-box /usr/local/bin/re_minor_bot.sh /var/www/html/re-minor-*;if command -v apt-get>/dev/null 2>&1;then apt-get purge -y sing-box 2>/dev/null||true;fi;g "Очистка завершена.";sleep 2; }
while true;do h;g "[ 01 ] автоматический блиц-режим (рекомендуется)";g "[ 02 ] кастомный сетап";g "[ 03 ] деинсталляция и очистка";g "[ 00 ] выход";p;read ch;case "$ch" in 01|1)bm;;02|2)cs;;03|3)un;;00|0)h;g "re minor shutdown.";exit 0;;esac;done
