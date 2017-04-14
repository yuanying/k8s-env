#!/usr/bin/env ruby -wKU

values = %w(
airflow_temperature_cel
command_timeout
current_pending_sector
end_to_end_error
erase_fail_count
g_sense_error_rate
hardware_ecc_recovered
host_reads_mib
host_reads_32mib
host_writes_mib
host_writes_32mib
load_cycle_count
media_wearout_indicator
nand_writes_1gib
offline_uncorrectable
power_cycle_count
power_on_hours
program_fail_count
raw_read_error_rate
reallocated_sector_ct
reported_uncorrect
sata_downshift_count
spin_retry_count
spin_up_time
start_stop_count
temperature_celsius
total_lbas_read
total_lbas_written
udma_crc_error_count
unsafe_shutdown_count
workld_host_reads_perc
workld_media_wear_indic
workload_minutes
)


values.each do |small_char|
  large_char = small_char.upcase
  print <<-EOF
  ALERT #{large_char}_INVALID
    IF #{small_char}_threshold - #{small_char}_value > 0
    FOR 30s
    ANNOTATIONS {
      summary = "Abnormal state of #{small_char}_value",
      description = "Abnormal state on {{$labels.instance}} for disk {{$labels.name}} (current value: {{$value}})"
    }
  EOF
end
