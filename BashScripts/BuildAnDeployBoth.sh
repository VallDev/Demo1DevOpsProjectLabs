#!/bin/bash

echo "----------------VM1 SCRIPT----------------------------------------"
cd frontOne/
bash BuildAndDeployF1.sh
cd ..
echo "--------------------------VM2 SCRIPT--------------------------------"
cd frontTwo/
bash BuildAndDeployF2.sh
