echo "#########################################"
echo "solhint"
echo "#########################################"
./smartbugs -t solhint -f ../data/contracts/sources/bsc/sol/*.sol --processes 9 --json --timeout 3600
./smartbugs -t solhint -f ../data/contracts/sources/eth/sol/*.sol --processes 9 --json --timeout 3600
echo "#########################################"
echo "slither"
echo "#########################################"
./smartbugs -t slither -f ../data/contracts/sources/bsc/sol/*.sol --processes 9 --json --timeout 3600
./smartbugs -t slither -f ../data/contracts/sources/eth/sol/*.sol --processes 9 --json --timeout 3600
echo "#########################################"
echo "confuzzius"
echo "#########################################"
./smartbugs -t confuzzius -f ../data/contracts/sources/bsc/sol/*.sol --processes 9 --json --timeout 3600
./smartbugs -t confuzzius -f ../data/contracts/sources/eth/sol/*.sol --processes 9 --json --timeout 3600
echo "#########################################"
echo "oyente"
echo "#########################################"
./smartbugs -t oyente -f ../data/contracts/bytecodes/eth/*.hex --processes 9 --json --timeout 3600 --runtime
./smartbugs -t oyente -f ../data/contracts/bytecodes/bsc/*.hex --processes 9 --json --timeout 3600 --runtime
./smartbugs -t oyente -f ../data/contracts/sources/eth/sol/*.sol --processes 9 --json --timeout 3600
./smartbugs -t oyente -f ../data/contracts/sources/bsc/sol/*.sol --processes 9 --json --timeout 3600
echo "#########################################"
echo "mythril"
echo "#########################################"
./smartbugs -t mythril -f ../data/contracts/bytecodes/eth/*.hex --processes 9 --json --timeout 3600 --runtime
./smartbugs -t mythril -f ../data/contracts/bytecodes/bsc/*.hex --processes 9 --json --timeout 3600 --runtime
./smartbugs -t mythril -f ../data/contracts/sources/eth/sol/*.sol --processes 9 --json --timeout 3600
./smartbugs -t mythril -f ../data/contracts/sources/bsc/sol/*.sol --processes 9 --json --timeout 3600
