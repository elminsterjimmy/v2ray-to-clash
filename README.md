# Introduction

This repo provides a shell script to convert v2ray subscription to clash proxies yaml file.

It only supports ss(shadowsocks) and vmess protocols.

# Prerequisites

The script depends on `curl`, `base64` and `jq`, you may install them via `apt`, `apt-get`, `yum` or `brew`. Using the proper lib management tool based on your OS.

# Usage

Using command `./v2ray_to_clash.sh <v2ray_subcription_url>`.
The command will generate a yaml file named `clash.yaml` and you can load it into your clash profile.

