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
h(){ clear;echo -e "${K}                \`         '";
echo -e "${K};,,,             \`       '             ,,,;";
echo -e "${K}\`YES8888bo.       :     :       .od8888YES'";
echo -e "${K}  888IO8DO88b.     :   :     .d8888I8DO88";
echo -e "${P}  8LOVEY'  \`Y8b.   \`   '   .d8Y'  \`YLOVE8";
echo -e "${P} jTHEE!  .db.  Yb. '   ' .dY  .db.  8THEE!";
echo -e "${P}   \`888  Y88Y    \`b ( ) d'    Y88Y  888'";
echo -e "${P}    8MYb  '""        ,',        "'"  dMY8";
echo -e "${C}   j8prECIOUSgf"'   ':'   \`"?g8prECIOUSk";
echo -e "${C}     'Y'   .8'     d' 'b     '8.   'Y'";
echo -e "${C}      !   .8' db  d'; ;\`b  db '8.   !";
echo -e "${C}         d88  \`'  8 ; ; 8  \`'  88b";
echo -e "${M}        d88Ib   .g8 ',' 8g.   dI88b";
echo -e "${M}       :888LOVE88Y'     'Y88LOVE888:";
echo -e "${M}       '! THEE888'       \`888THEE !'";
echo -e "${M}          '8Y  \`Y         Y'  Y8'";
echo -e "${R}           Y                   Y";
echo -e "${R}           !                   !";
echo -e "${R} --------------------------------------------------------"; }
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
