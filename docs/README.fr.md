# NanoPi NEO3 Plus · FriendlyWrt + Fibocom FM350-GL

[English](../README.md) · [Português (Brasil)](README.pt-BR.md) · [Español](README.es.md) · [简体中文](README.zh-CN.md) · [Documentation index](README.md)

Firmware FriendlyWrt reproductible pour NanoPi NEO3 Plus avec modem 5G Fibocom FM350-GL. Le profil mobile par défaut utilise `surf.br` et chaque source du build est verrouillée sur un commit exact dans `source-lock.json`.

## Architecture

Le FM350 est le WAN cellulaire. L'unique RJ45 du NanoPi fournit un LAN de maintenance/downstream DHCP/NAT sur `192.168.77.1/24`. Le bonding SRTLA/RatoNet reste géré par l'encodeur ou le routeur downstream ; le NanoPi reste une passerelle cellulaire autonome.

## Premier démarrage sécurisé

Les images publiques n'embarquent ni mot de passe administrateur partagé ni clé SSH personnelle. Si un build privé ne fournit pas `ROOT_PASSWORD_HASH`, le mot de passe fournisseur hérité est supprimé et le premier accès suit le modèle OpenWrt.

1. Connectez l'appareil uniquement à un réseau de maintenance de confiance.
2. Ouvrez `https://192.168.77.1/`.
3. Connectez-vous en `root` avec un mot de passe vide uniquement lors du premier accès.
4. Définissez immédiatement un mot de passe fort et unique dans **System → Administration**.
5. L'authentification SSH par mot de passe reste désactivée par défaut ; `AUTHORIZED_KEYS` est recommandé.

Voir [SECURITY.md](../SECURITY.md).

## Télémétrie

Le système expose RSSI, RSRP, RSRQ et SINR NR lorsque le modem les fournit, ainsi que RAT, opérateur, TAC, Cell ID, bandes, IP et trafic.

API protégée par jeton :

```text
https://192.168.77.1/cgi-bin/fm350-telemetry
```

Le jeton unique est géré dans **Network → FM350 Manager → Telemetry API** :

```bash
curl -k -H 'X-API-Key: TOKEN' 'https://192.168.77.1/cgi-bin/fm350-telemetry'
```

La réponse distingue `physical_transport: ethernet` de `upstream_type: cellular`. RatoNet peut ainsi conserver l'interface Ethernet réelle pour SRTLA tout en ajoutant RSRP/RSRQ/SINR et les informations modem. Voir [RATONET.md](RATONET.md).

## Releases

- **Hardware-verified stable** : validée physiquement sur NanoPi NEO3 Plus pour boot, RJ45, FM350, Internet et redémarrage.
- **Candidate** : tag `candidate-*`, compilée et vérifiée structurellement par CI mais pas encore validée sur le matériel réel.

Les anciennes releases automatiques antérieures à cette politique et les tags hérités dupliqués sont archivés dans [RELEASE_HISTORY.md](RELEASE_HISTORY.md) au lieu de rester dans les listes actives Releases/Tags.

Le workflow automatique vérifie les sources, le SHA-256, gzip et la structure de l'image, publie une prerelease candidate puis retélécharge les assets pour revérifier les checksums. Un workflow manuel distinct ne promeut la release stable qu'après confirmation de tous les tests physiques et ajoute `HARDWARE_VALIDATION.md`.

Voir [HARDWARE_VALIDATION.md](HARDWARE_VALIDATION.md), [BUILD.md](BUILD.md) et l'[index de documentation](README.md).

## Installation

1. Téléchargez `.img.gz`, `SHA256SUMS` et `source-lock.json`.
2. Vérifiez SHA-256.
3. Flashez avec Raspberry Pi Imager ou balenaEtcher.
4. Alimentez correctement l'adaptateur FM350 et démarrez le NanoPi.

La RJ45 distribue DHCP `192.168.77.100–149`, DNS et Internet cellulaire. Le LAN du routeur downstream doit utiliser un autre sous-réseau.

Le saut NAT supplémentaire est volontaire afin de privilégier la stabilité du chemin FM350 T700/RNDIS/XMM.

Projet communautaire sans affiliation officielle avec FriendlyELEC, FriendlyARM, Fibocom, RatoNet ou un opérateur mobile.
