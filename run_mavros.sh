#!/bin/bash

# 存储进程组ID
declare -A PGROUPS

start_command_and_check() {
    local cmd="$1"
    local logfile="/tmp/${cmd//[^a-zA-Z0-9]/_}.log"

    setsid bash -c "$cmd" >"$logfile" 2>&1 &
    local sid=$!

    sleep 5

    if kill -0 $sid >/dev/null 2>&1; then
        echo "Command started successfully: $cmd"
        PGROUPS["$cmd"]=$sid
    else
        echo "Failed to start command: $cmd"
        echo "Check log: $logfile"
        exit 1
    fi
}

cleanup() {
    echo "Stopping all commands..."
    for cmd in "${!PGROUPS[@]}"; do
        local sid=${PGROUPS["$cmd"]}
        echo "Stopping $cmd (PID $sid)..."
        kill -- -$sid 2>/dev/null
    done
    wait
    echo "All commands stopped"
    exit
}

trap cleanup EXIT INT TERM

# ==========================
# 用户参数
# ==========================

#PC_IP="10.220.24.106"
PC_IP="192.168.31.137"
#FCU_URL="/dev/ttyTHS0:921600"
FCU_URL="/dev/ttyACM0:921600"

echo "启动 MAVROS"
echo "飞控串口: $FCU_URL"
echo "QGroundControl 地址: $PC_IP"

# ==========================
# 1. 启动 MAVROS（后台）
# ==========================

COMMANDS=(
    "roslaunch mavros px4.launch fcu_url:=$FCU_URL gcs_url:=udp://@$PC_IP"
)

for CMD in "${COMMANDS[@]}"; do
    start_command_and_check "$CMD"
done

# ==========================
# 2. MAVROS 启动成功 → 发送 mavcmd
# ==========================

echo "MAVROS 已启动，发送参数设置命令..."

rosrun mavros mavcmd long 511 105 5000 0 0 0 0 0 & sleep 1
rosrun mavros mavcmd long 511 31 5000 0 0 0 0 0

echo "IMU 参数设置完成"

# ==========================
# 3. 进入循环保持脚本
# ==========================

while true; do
    sleep 60
done
