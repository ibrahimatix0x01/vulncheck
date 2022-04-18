#!/usr/bin/env bash
# Ibrahim Auwal
echo "***********************************************************"
echo "*      _    __      __      ________              __      *"
echo "*     | |  / /_  __/ /___  / ____/ /_  ___  _____/ /__    *"
echo "*     | | / / / / / / __ \/ /   / __ \/ _ \/ ___/ //_/    *"
echo "*     | |/ / /_/ / / / / / /___/ / / /  __/ /__/ ,<       *"
echo "*     |___/\__,_/_/_/ /_/\____/_/ /_/\___/\___/_/|_|      *"
echo "*                                   by @ibrahimatix0x01   *"
echo "***********************************************************" 
TARGET=$1
if ! [ $TARGET ]; then
  echo "[!] No target provided."
  echo ">> $0 <example.com>"
  exit 1
fi

OUT_DIR=$(pwd)
TOOLS_DIR=$(pwd)/tools
mkdir $TARGET

echo [*] Executing HowToFindBugs against: ${TARGET}


# Modify the individual commands as needed, add API keys and other resources to
# get the best results. Happy Hunting!

cd $TOOLS_DIR/subscraper
echo "[*] Launching SubScraper"
python3 subscraper.py $TARGET -o $OUT_DIR/$TARGET/subscraper.txt &> /dev/null &

cd $TOOLS_DIR/Sublist3r
echo "[*] Launching Sublist3r"
python3 sublist3r.py -d $TARGET -o $OUT_DIR/$TARGET/sublist3r.txt &> /dev/null &

cd $TOOLS_DIR/assetfinder
echo "[*] Launching assetfinder"
./assetfinder --subs-only $TARGET > $OUT_DIR/$TARGET/assetfinder.txt &

echo "[*] Waiting until all scripts complete..."
wait

cd $OUT_DIR
cd $TARGET
(cat subscraper.txt sublist3r.txt assetfinder.txt | sort -u) > howtofindbugs.txt
rm subscraper.txt sublist3r.txt assetfinder.txt

RES=$(cat howtofindbugs.txt | wc -l)
echo -e "\n[+] HowToFindBugs complete with ${RES} results"
echo "[+] Output saved to: $OUT_DIR/$TARGET/howtofindbugs.txt"

cat $OUT_DIR/$TARGET/howtofindbugs.txt | httprobe > $OUT_DIR/$TARGET/probed.txt
echo "[+] Live subdomains are saved to: $OUT_DIR/$TARGET/probed.txt"

nuclei -list $OUT_DIR/$TARGET/probed.txt -t /root/nuclei-templates/vulnerabilities -o $OUT_DIR/$TARGET/vuln.txt
nuclei -list $OUT_DIR/$TARGET/probed.txt -t /root/nuclei-templates/cves -o $OUT_DIR/$TARGET/cves.txt
echo "[+] Final results are saved to: $OUT_DIR/$TARGET/"
exit 0
