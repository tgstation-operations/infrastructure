# /tg/station Infrastructure
[![Run Colmena](https://github.com/tgstation-operations/infrastructure/actions/workflows/colmena.yml/badge.svg)](https://github.com/tgstation-operations/infrastructure/actions/workflows/colmena.yml)

This repository holds the IaC Config for the /tg/station Space Station 13 Server. This is built primarily using nix with [Colmena](https://github.com/zhaofengli/colmena)

This place is not a place of honor... no highly esteemed deed is commemorated here... nothing valued is here.
# Single points of failure

oranges - out of band access to lime/ domain owner

mothblocks - out of band access to blockmoths and eu relays

scriptis/lorwp - cloudflare dns

# Server owners
* lime - oranges (ovh us vm, forum/wiki host and relay)
* tgsatan - scriptis (dedicated)
* chicago, dallas, atlanta (scriptis, vultr relays)
* warsaw - scriptis (nobody knows??)
* wiggle - riggle (magic??)
* blockmoths - mothblocks (hetzner dedi)
* knipp,daschund,bratwurst - mothblocks (hetzner vm relays)

# Repository structure
```
<blorbo_name> = placeholder for the name of a blorbo
[/root/some/path] = this folder follows the same structure as /root/some/path 

root/
|-  modules/
|   |-  <single_file_module_name>.nix
|   |-  <module_name>/
|   |   |-  <file_name>
|   |   |-  default.nix
|-  secrets/
|   |-  secrets.nix
|   |-  <secret_name>.age
|-  systems/
|   |-  <system_name>/
|   |   |-  default.nix
|   |   |-  modules/ [root/modules]
|   |   |-  secrets/ [root/secrets]
|   |-  <system_group_name>/
|   |   |-  modules/ [root/modules]
|   |   |-  secrets/ [root/secrets]  
|   |   |-  systems/ [root/systems]  
``` 

# Flow of byond packets through infrastructure
```mermaid
architecture-beta
    %% The groups
    group frontend [FRONTEND]
    group backend [BACKEND]
    group usrelay(cloud)[US Relays] in frontend
    group eurelay(cloud)[EU Relays] in frontend
    group usdc(cloud)[US Server] in backend
    group eudc(cloud)[EU Server] in backend
    %% Allows for routing of lines
    junction usjunction1 in usrelay
    junction usjunction2 in usrelay
    junction usjunction3 in usrelay
    junction eujunction1 in eurelay
    junction eujunction2 in eurelay
    junction eujunction3 in eurelay
    
    %% Connects backends and frontends
    junction connecttop in frontend
    junction connectbottom in backend

    %% Allows for routing of us servers
    junction usserverjunction1 in usdc
    junction usserverjunction2 in usdc
    junction usserverjunction3 in usdc
    usserverjunction1:L -- R:usserverjunction2
    usserverjunction2:L -- R:usserverjunction3
    
    %%US frontend
    service relay1(server)[HaProxy Frontend] in usrelay
    relay1:B -- T:usjunction1
    service relay2(server)[HaProxy Frontend] in usrelay
    relay2:B -- T:usjunction2
    service relay3(server)[HaProxy Frontend] in usrelay
    relay3:B -- T:usjunction3
    usjunction1:L -- R:usjunction2
    usjunction2:L -- R:usjunction3
    usjunction3:L -- R:connecttop

    %%EU Frontend
    service relay4(server)[HaProxy Frontend] in eurelay
    relay4:B -- T:eujunction1
    service relay5(server)[HaProxy Frontend] in eurelay
    relay5:B -- T:eujunction2
    service relay6(server)[HaProxy Frontend] in eurelay
    relay6:B -- T:eujunction3
    eujunction1:R -- L:eujunction2
    eujunction2:R -- L:eujunction3
    eujunction3:R -- L:connecttop

    %% Connect backends and frontends
    connecttop:B -- T:connectbottom

    %% Backend haproxy and servers
    service backend1(server)[HaProxy Backend] in usdc
    service backend2(server)[HaProxy Backend] in eudc
    service manuel(server)[Manuel] in usdc
    service sybil(server)[Sybil] in usdc
    service tgmc(server)[TGMC] in usdc
    service terry(server)[Terry] in eudc

    %%Backend layout
    usserverjunction1:B -- T:manuel
    usserverjunction2:B -- T:sybil
    usserverjunction3:B -- T:tgmc
    usserverjunction2:T -- B:backend1
    
    backend2:B -- T:terry
    backend1:R <-- L:connectbottom
    backend2:L <-- R:connectbottom
```
# Explanation of how the transparent proxying works with HAproxy
```mermaid
sequenceDiagram
   Relay->>Backend: Client Traffic, ProxyProtocolV2
   Backend->>Loopback: HaProxy unwraps the ProxyProtocolV2<br/>forges a packet to have the original client IP<br/>then sends to byond via 10.248.1.1/24 on loopback
   Loopback->>Byond(10.248.1.1/24):Unwrapped client packet<br/>Byond sees this as normal traffic.
   Byond(10.248.1.1/24)->>Loopback:Packet from 10.248.1.1/24 to client in range 0.0.0.0/0,<br/>intercepted by custom routing rule and sent to loopback adapter
   Loopback->>Backend: HAproxy picks the packet up from loopback<br/>Sets correct destination and rewraps
   Backend->>Relay: Packet is sent to appropriate relay server for final delivery
```
