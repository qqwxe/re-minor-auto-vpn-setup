# re minor

<img src="assets/butterfly.svg" width="500" alt="re minor butterfly">

> *One-click VPN deployment*

**One-click VPN deployment.** Строгий, пафосный, футуристичный CLI-инсталлятор для Linux. Сканирует систему, подбирает непопулярные порты и SNI, накатывает ядро sing-box, генерирует QR-коды и ссылки — всё автоматически.

## Features

- **4 протокола в одном демоне:** VLESS + Reality, Trojan + Reality, Hysteria 2, AmneziaWG
- **Анти-детект порты:** случайные порты 10000–60000, ротация при блокировке
- **42 непопулярных SNI:** европейские корпорации, дизайн-бюро, производители — не банят
- **Кросс-дистрибутив:** Ubuntu, Debian, RHEL, CentOS, AlmaLinux, Rocky, Fedora, Arch, Manjaro
- **Anti-Error:** ждёт освобождения apt/dnf/pacman, kill -9 при зависании
- **Telegram-бот:** мониторинг CPU, RAM, сети, VPN-сессий
- **QR в терминале:** qrencode ANSI UTF-8
- **Подписка:** единая ссылка для Hiddify / v2rayNG / Streisand / Amnezia

## Install (one-liner)

```bash
curl -sL https://github.com/qqwxe/re-minor-VPN-AUTO-INSTALL-/releases/latest/download/install.sh | bash
reminor
```

## Or install via package manager

### Debian / Ubuntu

```bash
sudo add-apt-repository ppa:yourname/reminor
sudo apt update
sudo apt install reminor
```

### RHEL / CentOS / AlmaLinux / Fedora

```bash
sudo dnf copr enable yourname/reminor
sudo dnf install reminor
```

### Arch / Manjaro

```bash
yay -S reminor
```

## Manual install

```bash
git clone https://github.com/qqwxe/re-minor-VPN-AUTO-INSTALL-.git
cd re-minor-VPN-AUTO-INSTALL-/reminor-pkg
sudo make install
reminor
```

## Usage

Запусти `reminor` и выбирай:

```
[ 01 ] автоматический блиц-режим (рекомендуется)
[ 02 ] кастомный сетап
[ 03 ] деинсталляция и полная очистка
[ 00 ] выход
```

**Блиц-режим** — всё сам: порты, SNI, ключи, сертификаты, QR, ссылки, Telegram-бот.

**Кастомный сетап** — выбор протоколов и клиентского приложения вручную.

## Architecture

```
reminor
├── re_minor.sh          # основной инсталлятор
└── reminor-pkg/
    ├── debian/            # .deb packaging
    ├── reminor.spec       # .rpm packaging
    ├── PKGBUILD           # Arch packaging
    ├── install.sh         # universal installer
    ├── build.sh           # local build all
    └── .github/workflows/ # CI/CD
```

## Telegram Bot

Если подключён, бот отвечает на `/status`:

```
🖥️ ЦП: [████░░░░░░] 42%
📟 ОЗУ: 3.2/8.0 ГБ
🌐 Сеть: ↓ 124 KB/s ↑ 56 KB/s
👥 VPN: 3 сессий
```

## Screenshots

```
       _      _
      / \    / \
     (   \  /   )
      \   \/   /       [ re minor ]
       \  /\  /        автоматическая конфигурация vpn
       /  /\  \
      (  /  \  )
       \_/    \_/
 --------------------------------------------------------
[ 01 ] автоматический блиц-режим (рекомендуется)
[ 02 ] кастомный сетап
[ 03 ] деинсталляция и полная очистка
[ 00 ] выход
re minor >
```

## License

MIT
