#!/system/bin/sh

# online CPU
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online
echo 1 > /sys/devices/system/cpu/cpu4/online
echo 1 > /sys/devices/system/cpu/cpu5/online

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

# configure governor settings for little cluster
echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 30000 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/sampling_rate
echo 90 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/io_is_busy
echo 2 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/sampling_down_factor
echo 10 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/down_differential
echo 70 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold_multi_core
echo 3 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/down_differential_multi_core
echo 960000 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/optimal_freq
echo 600000 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/sync_freq
echo 75 > /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold_any_cpu_load
echo 384000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1440000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq

# configure governor settings for big cluster
echo "ondemand" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
echo 50000 > /sys/devices/system/cpu/cpu4/cpufreq/ondemand/sampling_rate
echo 90 > /sys/devices/system/cpu/cpu4/cpufreq/ondemand/up_threshold
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/ondemand/io_is_busy
echo 2 > /sys/devices/system/cpu/cpu4/cpufreq/ondemand/sampling_down_factor
echo 15 > /sys/devices/system/cpu/cpu4/cpufreq/ondemand/down_differential
echo 75 > /sys/devices/system/cpu/cpu4/cpufreq/ondemand/up_threshold_multi_core
echo 5 > /sys/devices/system/cpu/cpu4/cpufreq/ondemand/down_differential_multi_core
echo 640000 > /sys/devices/system/cpu/cpu4/cpufreq/ondemand/optimal_freq
echo 384000 > /sys/devices/system/cpu/cpu4/cpufreq/ondemand/sync_freq
echo 85 > /sys/devices/system/cpu/cpu4/cpufreq/ondemand/up_threshold_any_cpu_load
echo 384000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
echo 960000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
echo 960000 > /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq

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

# input boost configuration
echo 0:0 > /sys/module/cpu_boost/parameters/input_boost_freq
echo 0 > /sys/module/cpu_boost/parameters/input_boost_ms

# core_ctl module
echo 4 > /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
echo 60 > /sys/devices/system/cpu/cpu0/core_ctl/busy_up_thres
echo 30 > /sys/devices/system/cpu/cpu0/core_ctl/busy_down_thres
echo 100 > /sys/devices/system/cpu/cpu0/core_ctl/offline_delay_ms
echo 2 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
echo 60 > /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
echo 30 > /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
echo 100 > /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster
echo 2 > /sys/devices/system/cpu/cpu4/core_ctl/task_thres

# Setting b.L scheduler parameters
echo 1 > /proc/sys/kernel/sched_migration_fixup
echo 30 > /proc/sys/kernel/sched_small_task
echo 20 > /proc/sys/kernel/sched_mostly_idle_load
echo 3 > /proc/sys/kernel/sched_mostly_idle_nr_run
echo 99 > /proc/sys/kernel/sched_upmigrate
echo 85 > /proc/sys/kernel/sched_downmigrate
echo 7500000 > /proc/sys/kernel/sched_cpu_high_irqload
echo 60 > /proc/sys/kernel/sched_heavy_task
echo 65 > /proc/sys/kernel/sched_init_task_load
echo 200000000 > /proc/sys/kernel/sched_min_runtime
echo 400000 > /proc/sys/kernel/sched_freq_inc_notify
echo 400000 > /proc/sys/kernel/sched_freq_dec_notify

#relax access permission for display power consumption
chown -h system /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
chown -h system /sys/devices/system/cpu/cpu4/core_ctl/max_cpus

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

# 禁用核心
echo 0 > /sys/module/msm_thermal/core_control/cpus_offlined

# Set GPU
echo "msm-adreno-tz" > /sys/class/kgsl/kgsl-3d0/devfreq/governor
echo 5 > /sys/class/kgsl/kgsl-3d0/min_pwrlevel
echo 0 > /sys/class/kgsl/kgsl-3d0/max_pwrlevel
echo 4 > /sys/class/kgsl/kgsl-3d0/default_pwrlevel

# Set I/O
echo 256 > /sys/block/mmcblk0/queue/read_ahead_kb
echo noop > /sys/block/mmcblk0/queue/scheduler

echo "SET OK"