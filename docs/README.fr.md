# NanoPi NEO3 Plus · FriendlyWrt + Fibocom FM350-GL

[English](../README.md) · [Português (Brasil)](README.pt-BR.md) · [Español](README.es.md) · [简体中文](README.zh-CN.md)

Images FriendlyWrt reproductibles et prêtes à flasher pour le NanoPi NEO3 Plus avec modem 5G Fibocom FM350-GL. Le profil mobile utilise l’APN brésilien `surf.br` et chaque source est verrouillée par commit dans `source-lock.json`.

## Préconfiguration

- Modes USB FM350-GL `0e8d:7126` et `0e8d:7127`, avec détection automatique du port AT.
- `xmm-modem` et `luci-proto-xmm` de [modemfeed](https://github.com/koshev-msk/modemfeed).
- Connexion cellulaire IPv4 via `surf.br`, métrique 10 et route prioritaire.
- L’interface cellulaire FM350 comme WAN Internet, avec masquerading IPv4.
- L’unique RJ45 comme LAN DHCP pour le routeur connecté, passerelle `192.168.77.1/24`.
- LuCI, SSH, DNS et transfert cellulaire disponibles sur le même RJ45.
- Tableau multilingue **Réseau → FM350 Manager** avec état, configuration APN/SIM, SMS, analyse radio et commandes.
- `sys_led` en battement système ; `user_led` pour le lien et le trafic RX/TX du FM350.
- Accès administrateur root complet via LuCI et SSH sur l’interface de maintenance.

## Télécharger et flasher

1. Téléchargez le dernier `.img.gz` et `SHA256SUMS` depuis [Releases](https://github.com/msaulohenrique/nanopi-fm350-manager/releases).
2. Vérifiez la somme SHA-256.
3. Flashez directement l’image compressée avec [Raspberry Pi Imager](https://www.raspberrypi.com/software/) ou balenaEtcher.
4. Insérez la microSD, connectez le FM350-GL et démarrez le NanoPi. Le premier démarrage peut prendre plusieurs minutes.

La carte SIM doit être active et ne pas demander de code PIN. Sinon, configurez-le dans LuCI avant d’activer l’interface cellulaire.

## Connecter le routeur

| Connexion | Configuration du client | Adresse NanoPi | Résultat |
| --- | --- | --- | --- |
| Port WAN du routeur | DHCP/automatique | `192.168.77.1` | Reçoit `192.168.77.100–149`, DNS et Internet cellulaire |
| Ordinateur de maintenance direct | DHCP/automatique, ou `192.168.77.2/24` statique | `192.168.77.1` | LuCI, SSH et Internet cellulaire sur le même câble |

Ouvrez `https://192.168.77.1/`. Le certificat local peut provoquer un avertissement initial du navigateur.

Connectez le RJ45 du NanoPi au port **WAN/Internet** du routeur et laissez ce port en DHCP. Le LAN du routeur doit utiliser un autre sous-réseau, par exemple `192.168.1.0/24`. Le bouton GPIO utilisateur (`BTN_1`) redémarre le système lorsqu’il est relâché ; le bouton **MASK** conserve sa fonction de récupération.

Sans `ROOT_PASSWORD_HASH`, l’image conserve les identifiants FriendlyWrt initiaux : utilisateur `root`, mot de passe `password`. Ils donnent l’administration complète via LuCI et SSH depuis le client de maintenance. Modifiez immédiatement cette valeur publique pour une installation permanente. `AUTHORIZED_KEYS` peut ajouter une clé SSH de secours.

## Tableau du modem et LED

Après connexion, ouvrez **Réseau → FM350 Manager**. Le tableau affiche la SIM, l'opérateur, la technologie, le RAT, le signal, le réseau et l'IP. Les analyses fournissent des graphiques de signal/trafic, les bandes/canaux/PCI/largeurs utilisés et toutes les bandes 3G/4G/5G prises en charge. Le formulaire gère APN, PDP, CID, PIN SIM et identifiants PAP/CHAP sans renvoyer les secrets enregistrés au navigateur. La zone SMS lit les mémoires ME/SM, décode UCS-2, envoie des textes standard de 160 octets maximum et les supprime.

L'interface garde visibles les actions courantes, l'APN, le signal, les graphiques et les SMS ; les bandes, le CID et les identifiants sont regroupés dans des volets avancés. Les commandes s'activent dynamiquement selon l'état.

| LED | Configuration | Signification |
| --- | --- | --- |
| `sys_led` | `heartbeat` | Le système fonctionne. |
| `user_led` | `netdev` sur `eth1`, modes `link tx rx` | Lien cellulaire et clignotement lors du trafic modem. |

GitHub Actions vérifie les mises à jour chaque jour et lors des changements de recette sur `main`. Chaque release fournit `.img.gz`, `SHA256SUMS` et `source-lock.json`. Consultez [BUILD.md](BUILD.md).

N’exposez pas le réseau de maintenance à un segment Ethernet non fiable. Consultez [SECURITY.md](../SECURITY.md). Ce projet communautaire n’est affilié ni à FriendlyELEC, ni à FriendlyARM, ni à Fibocom, ni à l’opérateur mobile.
