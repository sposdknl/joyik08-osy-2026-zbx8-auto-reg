# OSY: Automatická registrace Debianu 13 do Zabbixu

Tato varianta zadání nasazuje virtuální server s **Debianem 13** (Trixie) a moderním agentem **Zabbix Agent 2 (verze 8.0 LTS)** instalovaným z oficiálního repozitáře Zabbix. Vagrant po spuštění automaticky provede instalaci i konfiguraci agenta. Agent se připojuje k serveru `enceladus.pfsense.cz` a pro automatickou registraci odesílá `HostMetadata=SPOS`.

## Spuštění

```sh
vagrant validate
vagrant up
```

Po úpravě skriptů lze konfiguraci i instalaci znovu aplikovat příkazem `vagrant provision`. Jedinečný název hosta se ukládá uvnitř VM (např. do `/etc/zabbix/spos-hostname` *(uprav podle cesty ve tvém skriptu)*), takže zůstává stejný i po restartu virtuálního stroje nebo opakovaném spuštění provisioningu. Nová VM vytvořená po `vagrant destroy` získá nový název.

Instalační skript nejprve stáhne a nainstaluje balíček oficiálního repozitáře Zabbix 8.0 pro Debian 13 (`zabbix-release`), aktualizuje seznam balíčků (`apt-get update`) a nainstaluje `zabbix-agent2`. Následný konfigurační skript upraví parametry v `/etc/zabbix/zabbix_agent2.conf` (`Server`, `ServerActive`, `HostMetadata` a `Hostname`), povolí službu po startu systému a restartuje ji.

Pokud by bylo potřeba spustit samotnou konfiguraci ručně uvnitř VM jako `root`:

```sh
bash /vagrant/zabzab-agent-conf.sh
systemctl status zabbix-agent2
```

## Ověření

Po spuštění VM lze stav agenta a síťové spojení ověřit přímo přes `vagrant ssh`:

```sh
vagrant ssh
zabbix_agent2 -V
systemctl status zabbix-agent2
grep -E '^(Hostname|Server|ServerActive|HostMetadata)=' /etc/zabbix/zabbix_agent2.conf
getent hosts enceladus.pfsense.cz
nc -zv -w 5 enceladus.pfsense.cz 10051
ss -tlpn | grep 10050
```

V Zabbixu se automaticky zaregistroval host `vorisek_matyas-f3076748` do příslušné skupiny a přiřadila se mu šablona pro monitoring Linuxu přes Zabbix Agent 2:

![Host Debian 13 v Zabbixu se skupinou a šablonou](Images/zbx8_vorisek_host.png)

Přehled naměřených dat (Latest data / grafy) téhož hosta potvrzuje aktivní příjem metrik ze systému (vytížení CPU, paměť, diskový prostor apod.):

![Naměřené hodnoty hosta Debian 13 v Zabbixu](Images/zbx8_vorisek_monitoring.png)

## Soubory

- `Vagrantfile`: definice virtuálního stroje s Debianem 13 a automatické spuštění provisioning skriptů.
- `zabzab-agent-install.sh`: přidání oficiálního repozitáře Zabbix 8.0 LTS pro Debian 13 a instalace balíčku `zabbix-agent2`.
- `zabzab-agent-conf.sh`: zajištění stálého jedinečného názvu hosta, konfigurace `/etc/zabbix/zabbix_agent2.conf` a restart služby `zabbix-agent2`.
- `Images/zbx8_vorisek_host.png`: snímek zaregistrovaného hosta z webového rozhraní Zabbixu.
- `Images/zbx8_vorisek_monitoring.png`: snímek z webového rozhraní Zabbixu dokazující příjem monitorovacích dat.

## Zdroje

- [Zabbix 8.0: instalace z oficiálních balíčků](https://zabbix.com)
- [Zabbix 8.0: parametry konfigurace agenta 2](https://zabbix.com)
- [Zabbix 8.0: automatická registrace aktivního agenta](https://zabbix.com)
