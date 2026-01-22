#!/bin/bash

# 存储进程组ID
declare -A PGROUPS

# 启动命令并检查
start_command_and_check() {
    local cmd="$1"

    # 不写日志，直接在终端打印
    setsid bash -c "$cmd" &
    local sid=$!

    sleep 3

    if kill -0 $sid >/dev/null 2>&1; then
        echo "Command started successfully: $cmd"
        PGROUPS["$cmd"]=$sid
    else
        echo "Failed to start command: $cmd"
        exit 1
    fi
}

# 清理函数
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

# 注册退出处理
trap cleanup EXIT INT TERM

# 命令列表（你的命令）
COMMANDS=(
    "cd ~/Fast-Drone-250 && source devel/setup.bash && roslaunch ego_planner single_run_in_exp.launch"
    "cd ~/Fast-Drone-250 && source devel/setup.bash && roslaunch ego_planner rviz.launch"
)

# 启动所有命令
for CMD in "${COMMANDS[@]}"; do
    start_command_and_check "$CMD"
done

# 等待所有命令结束
while true; do
    sleep 60
done
