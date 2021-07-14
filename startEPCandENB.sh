#!/bin/bash

# MODE is either IQ_EMULATION, or PL_EMULATION, or TESTBED
#MODE=IQ_EMULATION
MODE=$1
UE_IP_ADDR=192.168.151.66
CHEM_IP_ADDR=192.168.151.192
PORT_ARGS="tx_port=tcp://*:5101,rx_port=tcp://${UE_IP_ADDR}:5001"
PORT_ARGS_IQ="tx_port=tcp://*:5101,rx_port=tcp://${CHEM_IP_ADDR}:5001"
#PORT_ARGS="tx_port=tcp://192.168.151.68:5101,rx_port=tcp://localhost:5001"
ZMQ_ARGS="--rf.device_name=zmq --rf.device_args=\"${PORT_ARGS},id=enb,base_srate=23.04e6\""
ZMQ_ARGS_IQ="--rf.device_name=zmq --rf.device_args=\"${PORT_ARGS_IQ},id=enb,base_srate=23.04e6\""
TX_GAIN=70
RX_GAIN=40
EARFCN=2900
N_PRB=100


if [ $MODE == "TESTBED" ]
  then
	
  mkdir /dev/net
  mknod /dev/net/tun c 10 200
  ip tuntap add mode tun srs_spgw_sgi
  ifconfig srs_spgw_sgi 172.16.0.1/24
  screen -S EPC -dm bash -c "srsepc | ts '[%Y-%m-%d %H:%M:%.S]' > srsEPC.log" 
  screen -S eNB -dm bash -c "srsenb --rf.tx_gain=$TX_GAIN --rf.rx_gain=$RX_GAIN --rf.dl_earfcn=$EARFCN --enb.n_prb=$N_PRB | ts '[%Y-%m-%d %H:%M:%.S]' > srsENB.log" 
  
elif [ $MODE == "IQ_EMULATION" ]
then
  mkdir /dev/net
  mknod /dev/net/tun c 10 200
  ip tuntap add mode tun srs_spgw_sgi
  ifconfig srs_spgw_sgi 172.16.0.1/24
  screen -S EPC -dm bash -c "srsepc | ts '[%Y-%m-%d %H:%M:%.S]' > srsEPC.log"
  screen -S eNB -dm bash -c "srsenb ${ZMQ_ARGS_IQ} | ts '[%Y-%m-%d %H:%M:%.S]' > srsEPC.log"
 
elif [ $MODE == "IQ_DIRECT" ]
then
  mkdir /dev/net
  mknod /dev/net/tun c 10 200
  ip tuntap add mode tun srs_spgw_sgi
  ifconfig srs_spgw_sgi 172.16.0.1/24

  screen -S EPC -dm bash -c "srsepc | ts '[%Y-%m-%d %H:%M:%.S]' > srsEPC.log"
  screen -S Enb -dm bash -c "srsenb ${ZMQ_ARGS_IQ} | ts '[%Y-%m-%d %H:%M:%.S]' > srsEPC.log"
 
elif [ $MODE == "PL_EMULATION" ]
then
  screen -S zmqtun -dm bash -c "python3 zmq_tun.py -c -i ${CHEM_IP_ADDR} -p 5001 -t 172.16.0.1 -n tun "
 sleep 60
 screen -S ping -dm bash -c "ping -w 60 192.168.200.2 | ts '[%Y-%m-%d %H:%M:%.S]' > ping.log"
 
elif [ $MODE == "PL_DIRECT" ]
then
  screen -S zmqtun -dm bach -c "python3 zmq_tun.py -s -p 5002 -t 172.16.0.1 -n tun"

else
  echo "No mode specified"


fi



