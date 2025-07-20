#!/bin/bash

# 环境变量设置
TIMESTAMP="2025-07-20 04:24:35"
CURRENT_USER="SekaiMoe"
BASE_URL="https://github.com/OnePlus-12-Development/android_kernel_oneplus_sm8650/raw/lineage-22.2"
LOG_DIR="./logs"
LOG_FILE="${LOG_DIR}/kernel_download_$(date +%Y%m%d_%H%M%S).log"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 日志函数
log_message() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
}

# 下载函数
download_file() {
    local url="$1"
    local destination="$2"
    local destination_dir=$(dirname "$destination")

    # 创建目标目录
    mkdir -p "$destination_dir"

    log_message "Downloading: $url"
    log_message "To: $destination"

    if command -v curl >/dev/null 2>&1; then
        if curl -sSL --create-dirs "$url" -o "$destination" 2>&1; then
            log_message "Successfully downloaded: $destination"
            return 0
        else
            log_message "Failed to download: $destination"
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q --show-progress "$url" -O "$destination" 2>&1; then
            log_message "Successfully downloaded: $destination"
            return 0
        else
            log_message "Failed to download: $destination"
            return 1
        fi
    else
        log_message "Error: Neither curl nor wget is available"
        exit 1
    fi
}

# 初始化计数器
successful=0
failed=0

# 记录会话开始
log_message "=== Download Session Started ==="
log_message "Current User: $CURRENT_USER"
log_message "Timestamp (UTC): $TIMESTAMP"
log_message "Base URL: $BASE_URL"

# 定义要下载的文件列表
declare -a FILES=(
	"android/abi_gki_aarch64.stg"
	"android/abi_gki_aarch64_qcom"
	"android/abi_gki_aarch64_zebra"
	"arch/arm64/configs/vendor/seraph_GKI.config"
	"drivers/android/vendor_hooks.c"
	"drivers/clk/qcom/clk-alpha-pll.c"
	"drivers/misc/rtimd-i2c/rtimd-i2c.c"
	"drivers/mmc/host/sdhci-msm.c"
	"drivers/pinctrl/qcom/pinctrl-msm.c"
	"drivers/remoteproc/qcom_q6v5_mss.c"
	"drivers/virt/gunyah/gh_main.c"
	"include/linux/gunyah/gh_vm.h"
	"include/trace/hooks/vmscan.h"
	"include/uapi/linux/userfaultfd.h"
	"seraph.bzl"
)

# 下载文件
for file in "${FILES[@]}"; do
    source_url="${BASE_URL}/${file}"
    
    # 创建本地目录结构
    mkdir -p "$(dirname "$file")"
    
    if download_file "$source_url" "$file"; then
        ((successful++))
        echo "✓ Successfully downloaded: $file"
    else
        ((failed++))
        echo "✗ Failed to download: $file"
    fi
done

# 记录会话结束和统计
log_message "=== Download Session Complete ==="
log_message "Successful downloads: $successful"
log_message "Failed downloads: $failed"
log_message "End Time (UTC): $(date -u '+%Y-%m-%d %H:%M:%S')"

# 打印总结
echo ""
echo "============================================"
echo "Download Summary:"
echo "Total files: ${#FILES[@]}"
echo "Successful: $successful"
echo "Failed: $failed"
echo "Log file: $LOG_FILE"
echo "============================================"

# 如果有任何下载失败，返回非零状态码
[ "$failed" -eq 0 ] || exit 1
