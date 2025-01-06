#!/bin/bash

# 配置部分
LOG_FILE="/etc/urlog/basicstation.log.2"      # 需要监控的日志文件路径
LOG_FILE_BAK="/etc/urlog/basicstation.log.bak"	# 
REMOTE_SHARE="//192.168.41.65/share"  # 远程 Windows 共享路径
MOUNT_POINT="/mnt/windows_share"       # 本地挂载点路径
USERNAME="wusy"                   # 访问共享文件夹的用户名
PASSWORD="123456"                   # 访问共享文件夹的密码

mkdir "$MOUNT_POINT"

# 挂载共享文件夹
if ! mount | grep "$MOUNT_POINT" > /dev/null; then
  sudo mount -t cifs "$REMOTE_SHARE" "$MOUNT_POINT" -o username="$USERNAME",password="$PASSWORD"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to mount $REMOTE_SHARE to $MOUNT_POINT."
    exit 1
  fi
fi

# 获取当前时间作为备份文件名的一部分
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 将文件复制到挂载的共享文件夹
cp "$LOG_FILE" "$MOUNT_POINT/logfile_$TIMESTAMP.log"

if [ $? -eq 0 ]; then
  echo "[$(date)] File successfully exported to $MOUNT_POINT"
else
  echo "[$(date)] Failed to export file to $MOUNT_POINT"
fi

# 获取文件初始的修改时间
LAST_MOD_TIME=$(stat -c %Y "$LOG_FILE")

# 做备份
cp "$LOG_FILE" "$LOG_FILE_BAK"

# 主循环，轮询文件修改
while true; do
  sleep 2  # 每 2 秒检查一次

  NEW_MOD_TIME=$(stat -c %Y "$LOG_FILE")
  if [ "$NEW_MOD_TIME" -ne "$LAST_MOD_TIME" ]; then
    LAST_MOD_TIME=$NEW_MOD_TIME

    # 获取当前时间作为备份文件名的一部分
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

    # 将文件复制到挂载的共享文件夹
    cp "$LOG_FILE" "$MOUNT_POINT/logfile_$TIMESTAMP.log"

    if [ $? -eq 0 ]; then
      echo "[$(date)] File successfully exported to $MOUNT_POINT"
	  cp "$LOG_FILE" "$LOG_FILE_BAK"
    else
      echo "[$(date)] Failed to export file to $MOUNT_POINT"
	  cp "$LOG_FILE" "/mnt/logfiles/logfile_$TIMESTAMP.log"
	  cp "$LOG_FILE" "$LOG_FILE_BAK"
    fi
  fi
done