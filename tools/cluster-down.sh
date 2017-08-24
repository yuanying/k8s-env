#!/usr/bin/env bash

bash tools/node-down.sh tools/envs/master01.sh
bash tools/node-down.sh tools/envs/master02.sh
bash tools/node-down.sh tools/envs/master03.sh

bash tools/node-down.sh tools/envs/worker01.sh
bash tools/node-down.sh tools/envs/worker02.sh
bash tools/node-down.sh tools/envs/worker03.sh
bash tools/node-down.sh tools/envs/worker04.sh
bash tools/node-down.sh tools/envs/worker05.sh
bash tools/node-down.sh tools/envs/worker06.sh
