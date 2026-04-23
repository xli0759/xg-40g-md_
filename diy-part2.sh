#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# =====================================================
# 0. 修改路由器默认后台 IP 为 10.1.1.1
# =====================================================
sed -i 's/192.168.1.1/10.1.1.1/g' package/base-files/files/bin/config_generate


# =====================================================
# 1. 安装 eBPF 编译依赖 (修复 daed 的 llvm-strip 报错)
# =====================================================
echo "正在安装 clang 和 llvm..."
sudo apt-get update
sudo apt-get install -y clang llvm

# =====================================================
# 2. 配置 ImmortalWrt 官方 daed 核心与内核选项
# =====================================================

# 禁用 DEBUG_INFO_REDUCED（官方 eBPF 强制要求为 n）
sed -i '/CONFIG_KERNEL_DEBUG_INFO_REDUCED/d' .config
echo "# CONFIG_KERNEL_DEBUG_INFO_REDUCED is not set" >> .config

cat >> .config <<EOF
# 内核 eBPF / BTF 刚需选项（daed 要求）
CONFIG_DEVEL=y
CONFIG_KERNEL_DEBUG_INFO=y
CONFIG_KERNEL_DEBUG_INFO_BTF=y
CONFIG_KERNEL_CGROUPS=y
CONFIG_KERNEL_CGROUP_BPF=y
CONFIG_KERNEL_BPF_EVENTS=y
CONFIG_BPF_TOOLCHAIN_HOST=y
CONFIG_KERNEL_XDP_SOCKETS=y

# 编译诊断模块
CONFIG_PACKAGE_kmod-xdp-sockets-diag=y

# 选中官方的 daed 以及对应的 LuCI 控制面板
CONFIG_PACKAGE_daed=y
CONFIG_PACKAGE_luci-app-daed=y
EOF

# =====================================================
# 3. 修复 CPU / SoC 状态 (温度、频率) 不显示的问题
# =====================================================

cat >> .config <<EOF
# 开启 lm-sensors 基础工具与内核 HWMON 支持
CONFIG_PACKAGE_lm-sensors=y
CONFIG_PACKAGE_kmod-hwmon-core=y

# 开启 Airoha 相关的 PWM/温度监控传感器
CONFIG_PACKAGE_kmod-hwmon-pwmfan=y
CONFIG_PACKAGE_kmod-hwmon-gpiofan=y

# 开启 CPU 状态与频率读取支持
CONFIG_PACKAGE_cpufreq=y
CONFIG_PACKAGE_cpusage=y
CONFIG_PACKAGE_luci-app-cpufreq=y
CONFIG_PACKAGE_luci-app-cpufreq_INCLUDE_cpufreq=y
CONFIG_PACKAGE_kmod-thermal=y
EOF

# =====================================================
# 4. 修复 Airoha NPU 状态及硬件加速(HNAT)监控
# =====================================================

cat >> .config <<EOF
# 确保 Airoha AN7581 NPU 固件被打包
CONFIG_PACKAGE_airoha-en7581-npu-firmware=y

# 开启硬件加速流卸载支持 (HW NAT 核心)
CONFIG_PACKAGE_kmod-nft-offload=y

# 引入 NPU 状态读取所依赖的底层网络工具
CONFIG_PACKAGE_tc-full=y
CONFIG_PACKAGE_ethtool-full=y
CONFIG_PACKAGE_ip-full=y

# 开启 Airoha 专属 NPU LuCI 监控面板
CONFIG_PACKAGE_luci-app-airoha-npu=y
EOF

echo "环境依赖、IP 修改、daed 配置、SoC 状态及 NPU 监控修复完成！"
