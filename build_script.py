import os

script = r'''#!/bin/bash
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

g(){ echo -e "${M}$1${R}"; }
p(){ echo -e "${K}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"; }

gs(){ local i=$((RANDOM%${#SNI[@]}));echo "${SNI[$i]}"; }
rp(){ local pt;while true;do pt=$((RANDOM%55000+1024));if ! ss -tulpn 2>/dev/null|grep -q ":${pt}\b";then echo "$pt";break;fi;done; }

pp(){ h;g "Выбор портов";echo -e "${C}[ 1 ] Авто (случайные)";echo -e "${C}[ 2 ] Вручную";p;read pm;case "$pm" in 1)VLESS_PORT=$(rp);TROJAN_PORT=$(rp);HYSTERIA_PORT=$(rp);WG_PORT=$(rp);g "Порты: ${VLESS_PORT}, ${TROJAN_PORT}, ${HYSTERIA_PORT}, ${WG_PORT}";;2)echo -ne "${K}VLESS port: ${R}";read VLESS_PORT;echo -ne "${K}Trojan port: ${R}";read TROJAN_PORT;echo -ne "${K}Hysteria port: ${R}";read HYSTERIA_PORT;echo -ne "${K}AmneziaWG port: ${R}";read WG_PORT;;esac;sleep 1; }
sp(){ h;g "Выбор SNI";echo -e "${C}[ 1 ] Авто (случайный)";echo -e "${C}[ 2 ] Вручную";p;read sm;case "$sm" in 1)SNI_SELECTED=$(gs);g "SNI: ${SNI_SELECTED}";;2)echo -ne "${K}SNI домен: ${R}";read SNI_SELECTED;;esac;SNI_OVERRIDE="${SNI_SELECTED}";sleep 1; }

deps(){ h;g "Установка зависимостей...";sleep 1;local pkgs="curl wget jq qrencode openssl uuid-runtime net-tools bc iproute2";if command -v apt-get>/dev/null 2>&1;then apt-get update -qq&&apt-get install -y -qq $pkgs wireguard-tools;elif command -v dnf>/dev/null 2>&1;then dnf install -y -q $pkgs wireguard-tools;elif command -v pacman>/dev/null 2>&1;then pacman -Sy --noconfirm -q $pkgs wireguard-tools;fi; }
sb(){ h;g "Установка sing-box...";sleep 1;local v=$(curl -sL https://api.github.com/repos/SagerNet/sing-box/releases/latest|jq -r .tag_name);local a="sing-box-${v}-linux-amd64.tar.gz";curl -sL "https://github.com/SagerNet/sing-box/releases/download/${v}/${a}"|tar xz -C /tmp 2>/dev/null;cp /tmp/sing-box-*/sing-box /usr/local/bin/ 2>/dev/null||true;chmod +x /usr/local/bin/sing-box;mkdir -p /etc/sing-box/certs; }
ap(){ h;g "Генерация AmneziaWG...";sleep 1;AW_PRIVATE=$(wg genkey);AW_PUBLIC=$(echo "$AW_PRIVATE"|wg pubkey);AW_PSK=$(wg genpsk); }

eb(){ h;g "Сборка конфигурации...";sleep 1;UUID=$(cat /proc/sys/kernel/random/uuid);TROJAN_PASSWORD=$(openssl rand -hex 16);HYSTERIA_PASSWORD=$(openssl rand -hex 16);SNI_SELECTED=${SNI_SELECTED:-$(gs)};HYSTERIA_SNI=${SNI_SELECTED};local s="${SNI_SELECTED}";local kp=$(sing-box generate reality-keypair 2>/dev/null||echo "Private: none");REALITY_PRIVATE=$(echo "$kp"|grep "Private"|awk '{print $2}');REALITY_PUBLIC=$(echo "$kp"|grep "Public"|awk '{print $2}');REALITY_SID=$(openssl rand -hex 2);mkdir -p /etc/sing-box/certs;openssl req -x509 -newkey rsa:2048 -keyout /etc/sing-box/certs/key.pem -out /etc/sing-box/certs/cert.pem -days 365 -nodes -subj "/CN=${s}" 2>/dev/null||true;cat >/etc/sing-box/config.json <<EOFCFG
{
  "log": { "level": "info", "output": "/var/log/sing-box.log" },
  "inbounds": [
    { "type": "vless", "listen": "::", "listen_port": ${VLESS_PORT:-443}, "users": [{ "uuid": "${UUID}" }], "tls": { "enabled": true, "server_name": "${s}", "reality": { "enabled": true, "private_key": "${REALITY_PRIVATE}", "short_id": ["${REALITY_SID}"] }, "alpn": ["h2", "http/1.1"] }, "transport": { "type": "tcp" } },
    { "type": "trojan", "listen": "::", "listen_port": ${TROJAN_PORT:-443}, "users": [{ "password": "${TROJAN_PASSWORD}" }], "tls": { "enabled": true, "server_name": "${s}", "reality": { "enabled": true, "private_key": "${REALITY_PRIVATE}", "short_id": ["${REALITY_SID}"] }, "alpn": ["h2", "http/1.1"] }, "transport": { "type": "tcp" } },
    { "type": "hysteria2", "listen": "::", "listen_port": ${HYSTERIA_PORT:-443}, "users": [{ "password": "${HYSTERIA_PASSWORD}" }], "tls": { "enabled": true, "server_name": "${HYSTERIA_SNI}", "certificate_path": "/etc/sing-box/certs/cert.pem", "key_path": "/etc/sing-box/certs/key.pem" }, "masquerade": "https://${HYSTERIA_SNI}" },
    { "type": "wireguard", "listen": "::", "listen_port": ${WG_PORT:-51820}, "private_key": "${AW_PRIVATE}", "peers": [{ "public_key": "${AW_PUBLIC}", "allowed_ips": ["0.0.0.0/0", "::/0"], "persistent_keepalive_interval": 25, "pre_shared_key": "${AW_PSK}" }] }
  ],
  "outbounds": [{ "type": "direct" }]
}
EOFCFG
echo '{"uuid":"'${UUID}'","trojan_pass":"'${TROJAN_PASSWORD}'","hysteria_pass":"'${HYSTERIA_PASSWORD}'","sni":"'${s}'","reality_private":"'${REALITY_PRIVATE}'","reality_public":"'${REALITY_PUBLIC}'","reality_sid":"'${REALITY_SID}'","aw_private":"'${AW_PRIVATE}'","aw_public":"'${AW_PUBLIC}'","aw_psk":"'${AW_PSK}'"}' >/etc/sing-box/meta.json; }

sc(){ h;g "Применение конфигурации...";sleep 1;if systemctl is-active sing-box>/dev/null 2>&1;then systemctl restart sing-box;else cat >/etc/systemd/system/sing-box.service <<'EOFSVC'
[Unit]
Description=sing-box
After=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
Restart=always
[Install]
WantedBy=multi-user.target
EOFSVC
systemctl daemon-reload;systemctl enable sing-box;systemctl start sing-box;fi; }
st(){ systemctl restart sing-box; }

vl(){ echo "vless://${UUID}@${IP}:${VLESS_PORT:-443}?security=reality&sni=${SNI_SELECTED}&fp=chrome&pbk=${REALITY_PUBLIC}&sid=${REALITY_SID}&type=tcp&flow=xtls-rprx-vision#re-minor-vless"; }
tl(){ echo "trojan://${TROJAN_PASSWORD}@${IP}:${TROJAN_PORT:-443}?security=reality&sni=${SNI_SELECTED}&fp=chrome&alpn=http%2F1.1&type=tcp#re-minor-trojan"; }
hl(){ echo "hysteria2://${HYSTERIA_PASSWORD}@${IP}:${HYSTERIA_PORT:-443}?peer=${HYSTERIA_SNI}&insecure=0&sni=${HYSTERIA_SNI}#re-minor-hysteria"; }
aw(){ echo -e "${C}PrivateKey: ${R}${AW_PRIVATE}";echo -e "${C}PublicKey:  ${R}${AW_PUBLIC}";echo -e "${C}PresharedKey: ${R}${AW_PSK}";echo -e "${C}Address: ${R}10.0.0.2/24";echo -e "${C}DNS: ${R}1.1.1.1";echo -e "${C}Endpoint: ${R}${IP}:${WG_PORT:-51820}"; }

h(){ clear 2>/dev/null||true;echo -e "${K}                \`         '";echo -e "${K};,,,             \`       '             ,,,;";echo -e "${K}\`YES8888bo.       :     :       .od8888YES'";echo -e "${K}  888IO8DO88b.     :   :     .d8888I8DO88";echo -e "${P}  8LOVEY'  \`Y8b.   \`   '   .d8Y'  \`YLOVE8";echo -e "${P} jTHEE!  .db.  Yb. '   ' .dY  .db.  8THEE!";echo -e "${P}   \`888  Y88Y    \`b ( ) d'    Y88Y  888'";echo -e "${P}    8MYb  '\"        ,',        \"'  dMY8";echo -e "${C}   j8prECIOUSgf\"'   ':'   \`\"?g8prECIOUSk";echo -e "${C}     'Y'   .8'     d' 'b     '8.   'Y'";echo -e "${C}      !   .8' db  d'; ;\`b  db '8.   !";echo -e "${C}         d88  \`'  8 ; ; 8  \`'  88b";echo -e "${M}        d88Ib   .g8 ',' 8g.   dI88b";echo -e "${M}       :888LOVE88Y'     'Y88LOVE888:";echo -e "${M}       '! THEE888'       \`888THEE !'";echo -e "${M}          '8Y  \`Y         Y'  Y8'";echo -e "${R}           Y                   Y";echo -e "${R}           !                   !";echo -e "${R} --------------------------------------------------------"; }

sub(){ local c=$1;local v=$(vl) t=$(tl) y=$(hl);local l="${v}\n${t}\n${y}";mkdir -p /var/www/html;printf "%b" "$l">/var/www/html/re-minor-sub.txt;if [ "$c" = "hiddify" ];then local e=$(echo -e "$l"|base64 -w0);echo "$e">/var/www/html/re-minor-hiddify.txt;fi;echo "http://${IP}/re-minor-sub.txt"; }
qr(){ local l="$1" n="$2";echo -e "\n${C}${n}${R}";echo -e "${M}${l}${R}";echo "$l"|qrencode -t ansiutf8 -l L 2>/dev/null||echo -e "${K}[ qrencode не установлен ]${R}"; }

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

bm(){ h;g "Инициализация блиц-режима...";sleep 1;deps;sb;pp;sp;ap;eb;sc "vless trojan hysteria amneziawg";st;h;g "Развертывание завершено.";local v=$(vl) t=$(tl) y=$(hl);local s=$(sub hiddify);qr "$v" "VLESS + Reality";qr "$t" "Trojan + Reality";qr "$y" "Hysteria 2";echo -e "\n${P}AmneziaWG конфиг:${R}";aw;echo -e "\n${C}Подписка: ${R}${s}";echo -e "\n${M}Данные в /etc/sing-box/${R}";tb;if [ -f /usr/local/bin/re_minor_bot.sh ];then local b=$(grep 'T=' /usr/local/bin/re_minor_bot.sh|head -1|cut -d'"' -f2) c=$(grep 'C=' /usr/local/bin/re_minor_bot.sh|head -1|cut -d'"' -f2);if [ -n "$b" ]&&[ -n "$c" ];then curl -s -X POST "https://api.telegram.org/bot${b}/sendMessage" -d "chat_id=${c}" -d "text=VLESS: ${v}"$'\n'"Trojan: ${t}"$'\n'"Hysteria: ${y}"$'\n'"Подписка: ${s}" -d "parse_mode=Markdown">/dev/null 2>&1||true;fi;fi;echo -e "\n${K}Нажмите Enter...${R}";read; }

cs(){ h;local sp=();g "Выберите протоколы (через пробел):";echo -e "${C}[ 1 ] VLESS + Reality";echo -e "${C}[ 2 ] Trojan + Reality";echo -e "${C}[ 3 ] Hysteria 2";echo -e "${C}[ 4 ] AmneziaWG";p;read pc;for n in $pc;do case "$n" in 1)sp+=("vless");;2)sp+=("trojan");;3)sp+=("hysteria");;4)sp+=("amneziawg");;esac;done;if [ ${#sp[@]} -eq 0 ];then g "Не выбрано. Возврат.";sleep 2;return;fi;h;g "Выберите клиент:";echo -e "${C}[ 1 ] Hiddify Next";echo -e "${C}[ 2 ] v2rayNG / Nekobox";echo -e "${C}[ 3 ] FoXray / Streisand";echo -e "${C}[ 4 ] Amnezia VPN App";p;read cc;local cl="hiddify";case "$cc" in 1)cl="hiddify";;2)cl="v2rayng";;3)cl="foxray";;4)cl="amnezia";;esac;h;g "Настройка: ${sp[*]}...";deps;sb;pp;sp;ap;eb;sc "${sp[*]}";st;h;g "Генерация...";local s=$(sub "$cl");if [[ " ${sp[*]} " =~ " vless " ]];then qr "$(vl)" "VLESS + Reality";fi;if [[ " ${sp[*]} " =~ " trojan " ]];then qr "$(tl)" "Trojan + Reality";fi;if [[ " ${sp[*]} " =~ " hysteria " ]];then qr "$(hl)" "Hysteria 2";fi;if [[ " ${sp[*]} " =~ " amneziawg " ]];then echo -e "\n${P}AmneziaWG:${R}";aw;fi;echo -e "\n${C}Подписка: ${R}${s}";tb;if [ -f /usr/local/bin/re_minor_bot.sh ];then local b=$(grep 'T=' /usr/local/bin/re_minor_bot.sh|head -1|cut -d'"' -f2) c=$(grep 'C=' /usr/local/bin/re_minor_bot.sh|head -1|cut -d'"' -f2);if [ -n "$b" ]&&[ -n "$c" ];then local msg="";[[ " ${sp[*]} " =~ " vless " ]]&&msg+="VLESS: $(vl)"$'\n';[[ " ${sp[*]} " =~ " trojan " ]]&&msg+="Trojan: $(tl)"$'\n';[[ " ${sp[*]} " =~ " hysteria " ]]&&msg+="Hysteria: $(hl)"$'\n';msg+="Подписка: ${s}";curl -s -X POST "https://api.telegram.org/bot${b}/sendMessage" -d "chat_id=${c}" -d "text=${msg}" -d "parse_mode=Markdown">/dev/null 2>&1||true;fi;fi;echo -e "\n${K}Нажмите Enter...${R}";read; }

un(){ h;g "Деинсталляция и очистка...";systemctl stop sing-box 2>/dev/null||true;systemctl disable sing-box 2>/dev/null||true;systemctl stop re-minor-bot 2>/dev/null||true;systemctl disable re-minor-bot 2>/dev/null||true;rm -f /etc/systemd/system/sing-box.service /etc/systemd/system/re-minor-bot.service;systemctl daemon-reload;rm -rf /etc/sing-box /usr/local/bin/sing-box /usr/local/bin/re_minor_bot.sh /var/www/html/re-minor-*;if command -v apt-get>/dev/null 2>&1;then apt-get purge -y sing-box 2>/dev/null||true;fi;g "Очистка завершена.";sleep 2; }

while true;do h;g "[ 01 ] автоматический блиц-режим (рекомендуется)";g "[ 02 ] кастомный сетап";g "[ 03 ] деинсталляция и очистка";g "[ 00 ] выход";p;read ch;case "$ch" in 01|1)bm;;02|2)cs;;03|3)un;;00|0)h;g "re minor shutdown.";exit 0;;esac;done
'''

path = r'c:\Users\ultra\Downloads\протокоыл\re_minor.sh'
with open(path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(script)

print('done')
