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

echo [*] Executing VulnCheck against: ${TARGET}


# Modify the individual commands as needed, add API keys and other resources to
# get the best results. Happy Hunting!

cd $TOOLS_DIR/subscraper
echo "[+] Launching SubScraper"
python3 subscraper.py $TARGET -o $OUT_DIR/$TARGET/subscraper.txt &> /dev/null &

cd $TOOLS_DIR/Sublist3r
echo "[+] Launching Sublist3r"
python3 sublist3r.py -d $TARGET -o $OUT_DIR/$TARGET/sublist3r.txt &> /dev/null &

cd $TOOLS_DIR/assetfinder
echo "[+] Launching Assetfinder"
./assetfinder --subs-only $TARGET > $OUT_DIR/$TARGET/assetfinder.txt &

echo "[+] Waiting until all scripts complete..."
wait

cd $OUT_DIR
cd $TARGET
(cat subscraper.txt sublist3r.txt assetfinder.txt | sort -u) > vulncheck.txt
rm subscraper.txt sublist3r.txt assetfinder.txt

RES=$(cat vulncheck.txt | wc -l)
echo -e "\n[+] VulnCheck complete with ${RES} subdomains" | notify -silent
echo -e "\n[+] VulnCheck complete with ${RES} subdomains"
echo "[+] Output are saved to: $OUT_DIR/$TARGET/vulncheck.txt"

cat $OUT_DIR/$TARGET/vulncheck.txt | httprobe > $OUT_DIR/$TARGET/probed.txt
echo "[+] Live subdomains are saved to: $OUT_DIR/$TARGET/probed.txt"


nuclei -list $OUT_DIR/$TARGET/probed.txt -o $OUT_DIR/$TARGET/final.txt
echo "[+] Final results are saved to: $OUT_DIR/$TARGET/final.txt"

NUCRES=$(cat $OUT_DIR/$TARGET/final.txt | wc -l)

echo "[+] Final results are saved to: vuln.txt"
echo "[+] Nuclei found ${NUCRES} bugs"


echo "[+] Launching XSS scan"
cd $OUT_DIR/$TARGET
mkdir XSS
cd XSS
cat $OUT_DIR/$TARGET/vulncheck.txt | waybackurls | gf xss | httpx -silent | uro > waybackurls.txt
cat $OUT_DIR/$TARGET/vulncheck.txt | gau | gf xss | httpx -silent | uro > gau.txt
cat waybackurls.txt gau.txt | uro | qsreplace '"><img src=x onerror=alert(1);>' | freq | grep "31m" > freq.txt 

cat waybackurls.txt gau.txt | uro | qsreplace '"><svg onload=confirm(1)>' | airixss -payload "confirm(1)" | grep "31m" > airixss.txt
sudo rm waybackurls.txt
sudo rm gau.txt
FREQRES=$(cat freq.txt | wc -l)
echo "[+] FREQ found ${FREQRES} XSS vulnerabilities." | notify -silent
echo "[+] FREQ found ${FREQRES} XSS vulnerabilities."
AIRIXSSRES=$(cat freq.txt | wc -l)
echo "[+] AIRIXSS found ${AIRIXSSRES} XSS vulnerabilities." | notify -silent
echo "[+] AIRIXSS found ${AIRIXSSRES} XSS vulnerabilities."
exit 0
