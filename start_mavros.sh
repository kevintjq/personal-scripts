#!/bin/bash
# start_mavros.sh
# 描述：启动 MAVROS 并连接 PX4 飞控和 QGroundControl
#roslaunch mavros px4.launch fcu_url:=/dev/ttyUSB0:921600 gcs_url:=udp://@192.168.1.100

# ========== 用户可修改部分 ==========

# 笔记本（QGroundControl）IP
PC_IP="10.220.24.106"

# 飞控串口与波特率
FCU_URL="/dev/ttyTHS0:921600"

echo "启动 MAVROS..."
echo "飞控串口: $FCU_URL"
echo "QGroundControl 地址: $PC_IP"

# 一行命令启动 MAVROS
roslaunch mavros px4.launch fcu_url:=$FCU_URL gcs_url:=udp://@$PC_IP & sleep 5;    
#提高imu频率
rosrun mavros mavcmd long 511 105 5000 0 0 0 0 0 & sleep 1;  #间隔5000ms 提高频率为200hz
rosrun mavros mavcmd long 511 31 5000 0 0 0 0 0 & sleep 1;  
