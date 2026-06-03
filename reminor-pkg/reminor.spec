Name:           reminor
Version:        1.0
Release:        1%{?dist}
Summary:        re minor VPN auto-configurator
License:        MIT
URL:            https://reminor.local
Source0:        reminor
BuildArch:      noarch
Requires:       bash, curl, wget, jq, qrencode, openssl, util-linux, net-tools, bc, iproute

%description
One-click deployment of VLESS+Reality, Trojan, Hysteria2
and AmneziaWG via sing-box. Includes Telegram bot monitor.

%prep

%build

%install
install -Dm755 %{SOURCE0} %{buildroot}%{_bindir}/reminor

%files
%{_bindir}/reminor

%changelog
* Mon Jun 03 2026 re minor <dev@reminor.local> - 1.0-1
- Initial release
