#!/bin/sh

/usr/bin/intelmas show -a -smart -intelssd 0 | grep Action > /var/log/lotus/ssd/ssd_$(date +%Y%m%d).log
