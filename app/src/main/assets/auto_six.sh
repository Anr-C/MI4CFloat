#!/system/bin/sh
# Copyright (c) 2012-2013, The Linux Foundation. All rights reserved.
#

target=`getprop ro.board.platform`

# ensure at most one A57 is online when thermal hotplug is disabled
echo 0 > /sys/devices/system/cpu/cpu5/online
# in case CPU4 is online, limit its frequency
echo 960000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
# Limit A57 max freq from msm_perf module in case CPU 4 is offline
echo "4:960000 5:960000" > /sys/module/msm_performance/parameters/cpu_max_freq
# disable thermal bcl hotplug to switch governor
echo 0 > /sys/module/msm_thermal/core_control/enabled
for mode in /sys/devices/soc.0/qcom,bcl.*/mode
do
	echo -n disable > $mode
done
for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
do
	bcl_hotplug_mask=`cat $hotplug_mask`
	echo 0 > $hotplug_mask
done
for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
do
	bcl_soc_hotplug_mask=`cat $hotplug_soc_mask`
	echo 0 > $hotplug_soc_mask
done
for mode in /sys/devices/soc.0/qcom,bcl.*/mode
do
	echo -n enable > $mode
done

# Disable CPU retention
echo 0 > /sys/module/lpm_levels/system/a53/cpu0/retention/idle_enabled
echo 0 > /sys/module/lpm_levels/system/a53/cpu1/retention/idle_enabled
echo 0 > /sys/module/lpm_levels/system/a53/cpu2/retention/idle_enabled
echo 0 > /sys/module/lpm_levels/system/a53/cpu3/retention/idle_enabled
echo 0 > /sys/module/lpm_levels/system/a57/cpu4/retention/idle_enabled
echo 0 > /sys/module/lpm_levels/system/a57/cpu5/retention/idle_enabled

# Disable L2 retention
echo 0 > /sys/module/lpm_levels/system/a53/a53-l2-retention/idle_enabled
echo 0 > /sys/module/lpm_levels/system/a57/a57-l2-retention/idle_enabled

# online CPU4
echo 1 > /sys/devices/system/cpu/cpu4/online
# restore A57's max
cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
# insert core_ctl module and use conservative paremeters
insmod /system/lib/modules/core_ctl.ko
# re-enable thermal and BCL hotplug
echo 1 > /sys/module/msm_thermal/core_control/enabled
for mode in /sys/devices/soc.0/qcom,bcl.*/mode
do
	echo -n disable > $mode
done
for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
do
	echo $bcl_hotplug_mask > $hotplug_mask
done
for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
do
	echo $bcl_soc_hotplug_mask > $hotplug_soc_mask
done
for mode in /sys/devices/soc.0/qcom,bcl.*/mode
do
	echo -n enable > $mode
done
# plugin remaining A57s
echo 1 > /sys/devices/system/cpu/cpu5/online
echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled
# Restore CPU 4 max freq from msm_performance
echo "4:4294967295 5:4294967295" > /sys/module/msm_performance/parameters/cpu_max_freq


# 以下是添加的代码

#Little 核心调度
echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
echo 30000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
echo 70 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
echo 50000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
echo 800000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
echo "65 960000:80 1248000:85" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads        
echo 30000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
echo "0" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration

# Little 核心最高频率 1440MHZ
echo "1440000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq

# Little 核心动态开关
echo 4 > /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
echo 1 > /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
echo 0 20 20 20 > /sys/devices/system/cpu/cpu0/core_ctl/busy_up_thres
echo 0 10 10 10 > /sys/devices/system/cpu/cpu0/core_ctl/busy_down_thres
echo 60000 > /sys/devices/system/cpu/cpu0/core_ctl/offline_delay_ms

# Big 核心调度
echo "interactive" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
echo "50000 1440000:20000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
echo 90 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
        echo 50000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
        echo 633600 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
        echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
        echo 75 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
		echo "0" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration
        echo 50000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
        echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis

# Big 核心动态开关
echo 0 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
echo 90 > /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
echo 70 > /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
echo 100 > /sys/devices/system/cpu/cpu0/core_ctl/offline_delay_ms
echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster
echo 4 > /sys/devices/system/cpu/cpu4/core_ctl/task_thres

# 0ms input boost
echo 0 > /sys/module/cpu_boost/parameters/input_boost_freq
echo 0 > /sys/module/cpu_boost/parameters/input_boost_ms		

echo 600000000 > /sys/class/kgsl/kgsl-3d0/devfreq/max_freq
echo 5 > /sys/class/kgsl/kgsl-3d0/min_pwrlevel
echo 0 > /sys/class/kgsl/kgsl-3d0/max_pwrlevel
echo 5 > /sys/class/kgsl/kgsl-3d0/default_pwrlevel

# 设置CPU使用
echo "0-5" > /dev/cpuset/foreground/cpus
echo "4-5" > /dev/cpuset/foreground/boost/cpus
echo "0-3" > /dev/cpuset/background/cpus
echo "0-3" > /dev/cpuset/system-background/cpus


# Setting b.L scheduler parameters
echo 1 > /proc/sys/kernel/sched_migration_fixup
echo 15 > /proc/sys/kernel/sched_small_task
echo 20 > /proc/sys/kernel/sched_mostly_idle_load
echo 3 > /proc/sys/kernel/sched_mostly_idle_nr_run
echo 95 > /proc/sys/kernel/sched_upmigrate
echo 55 > /proc/sys/kernel/sched_downmigrate
echo 7500000 > /proc/sys/kernel/sched_cpu_high_irqload
echo 60 > /proc/sys/kernel/sched_heavy_task
echo 65 > /proc/sys/kernel/sched_init_task_load
echo 200000000 > /proc/sys/kernel/sched_min_runtime
echo 400000 > /proc/sys/kernel/sched_freq_inc_notify
echo 400000 > /proc/sys/kernel/sched_freq_dec_notify
#relax access permission for display power consumption
#enable rps static configuration
echo 8 >  /sys/class/net/rmnet_ipa0/queues/rx-0/rps_cpus
for devfreq_gov in /sys/class/devfreq/qcom,cpubw*/governor
do
	echo "bw_hwmon" > $devfreq_gov
done
for devfreq_gov in /sys/class/devfreq/qcom,mincpubw*/governor
do
	echo "cpufreq" > $devfreq_gov
done
# Disable sched_boost
echo 0 > /proc/sys/kernel/sched_boost

chown -h system /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
chown -h system /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
chown -h system /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy

emmc_boot=`getprop ro.boot.emmc`
case "$emmc_boot"
    in "true")
        chown -h system /sys/devices/platform/rs300000a7.65536/force_sync
        chown -h system /sys/devices/platform/rs300000a7.65536/sync_sts
        chown -h system /sys/devices/platform/rs300100a7.65536/force_sync
        chown -h system /sys/devices/platform/rs300100a7.65536/sync_sts
    ;;
esac

# Post-setup services
rm /data/system/perfd/default_values
setprop ro.min_freq_0 384000
setprop ro.min_freq_4 384000
start perfd


# Install AdrenoTest.apk if not already installed
if [ -f /data/prebuilt/AdrenoTest.apk ]; then
    if [ ! -d /data/data/com.qualcomm.adrenotest ]; then
        pm install /data/prebuilt/AdrenoTest.apk
    fi
fi

# Install SWE_Browser.apk if not already installed
if [ -f /data/prebuilt/SWE_AndroidBrowser.apk ]; then
    if [ ! -d /data/data/com.android.swe.browser ]; then
        pm install /data/prebuilt/SWE_AndroidBrowser.apk
    fi
fi


# Let kernel know our image version/variant/crm_version
image_version="10:"
image_version+=`getprop ro.build.id`
image_version+=":"
image_version+=`getprop ro.build.version.incremental`
image_variant=`getprop ro.product.name`
image_variant+="-"
image_variant+=`getprop ro.build.type`
oem_version=`getprop ro.build.version.codename`
echo 10 > /sys/devices/soc0/select_image
echo $image_version > /sys/devices/soc0/image_version
echo $image_variant > /sys/devices/soc0/image_variant
echo $oem_version > /sys/devices/soc0/image_crm_version

# Enable QDSS agent if QDSS feature is enabled
# on a non-commercial build.  This allows QDSS
# debug tracing.
if [ -c /dev/coresight-stm ]; then
    build_variant=`getprop ro.build.type`
    if [ "$build_variant" != "user" ]; then
        # Test: Is agent present?
        if [ -f /data/qdss/qdss.agent.sh ]; then
            # Then tell agent we just booted
           /system/bin/sh /data/qdss/qdss.agent.sh on.boot &
        fi
    fi
fi

# Start RIDL/LogKit II client
su -c /system/vendor/bin/startRIDL.sh &

# 禁用Big核心
#echo 48 > /sys/module/msm_thermal/core_control/cpus_offlined


# IO 优化，改为Read Over Write，缓存2048kb
echo 2048 > /sys/block/mmcblk0/queue/read_ahead_kb
echo row > /sys/block/mmcblk0/queue/scheduler

# ZRAM 384MB
#echo 1 > /sys/block/zram0/reset
#echo 402653184 > /sys/block/zram0/disksize
mkswap /dev/block/zram0 &> /dev/null
swapon /dev/block/zram0 &> /dev/null

echo "SET OK"