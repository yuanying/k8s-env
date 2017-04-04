#!/usr/bin/env ruby -wKU

actual_data = <<-EOD
# HELP smartmon_smartctl_version SMART metric smartctl_version
# TYPE smartmon_smartctl_version gauge
smartmon_smartctl_version{version="6.2"} 1
# HELP smartmon_airflow_temperature_cel_raw_value SMART metric airflow_temperature_cel_raw_value
# TYPE smartmon_airflow_temperature_cel_raw_value gauge
smartmon_airflow_temperature_cel_raw_value{disk="/dev/sda",type="sat",smart_id="190"} 39
# HELP smartmon_airflow_temperature_cel_threshold SMART metric airflow_temperature_cel_threshold
# TYPE smartmon_airflow_temperature_cel_threshold gauge
smartmon_airflow_temperature_cel_threshold{disk="/dev/sda",type="sat",smart_id="190"} 40
# HELP smartmon_airflow_temperature_cel_value SMART metric airflow_temperature_cel_value
# TYPE smartmon_airflow_temperature_cel_value gauge
smartmon_airflow_temperature_cel_value{disk="/dev/sda",type="sat",smart_id="190"} 61
# HELP smartmon_airflow_temperature_cel_worst SMART metric airflow_temperature_cel_worst
# TYPE smartmon_airflow_temperature_cel_worst gauge
smartmon_airflow_temperature_cel_worst{disk="/dev/sda",type="sat",smart_id="190"} 57
# HELP smartmon_command_timeout_raw_value SMART metric command_timeout_raw_value
# TYPE smartmon_command_timeout_raw_value gauge
smartmon_command_timeout_raw_value{disk="/dev/sda",type="sat",smart_id="188"} 0
# HELP smartmon_command_timeout_threshold SMART metric command_timeout_threshold
# TYPE smartmon_command_timeout_threshold gauge
smartmon_command_timeout_threshold{disk="/dev/sda",type="sat",smart_id="188"} 0
# HELP smartmon_command_timeout_value SMART metric command_timeout_value
# TYPE smartmon_command_timeout_value gauge
smartmon_command_timeout_value{disk="/dev/sda",type="sat",smart_id="188"} 100
# HELP smartmon_command_timeout_worst SMART metric command_timeout_worst
# TYPE smartmon_command_timeout_worst gauge
smartmon_command_timeout_worst{disk="/dev/sda",type="sat",smart_id="188"} 100
# HELP smartmon_current_pending_sector_raw_value SMART metric current_pending_sector_raw_value
# TYPE smartmon_current_pending_sector_raw_value gauge
smartmon_current_pending_sector_raw_value{disk="/dev/sda",type="sat",smart_id="197"} 0
# HELP smartmon_current_pending_sector_threshold SMART metric current_pending_sector_threshold
# TYPE smartmon_current_pending_sector_threshold gauge
smartmon_current_pending_sector_threshold{disk="/dev/sda",type="sat",smart_id="197"} 0
# HELP smartmon_current_pending_sector_value SMART metric current_pending_sector_value
# TYPE smartmon_current_pending_sector_value gauge
smartmon_current_pending_sector_value{disk="/dev/sda",type="sat",smart_id="197"} 200
# HELP smartmon_current_pending_sector_worst SMART metric current_pending_sector_worst
# TYPE smartmon_current_pending_sector_worst gauge
smartmon_current_pending_sector_worst{disk="/dev/sda",type="sat",smart_id="197"} 200
# HELP smartmon_device_info SMART metric device_info
# TYPE smartmon_device_info gauge
smartmon_device_info{disk="/dev/sda",type="sat",model_family="Western Digital Caviar Blue (SATA 6Gb/s)",device_model="WDC WD5000AAKX-60U6AA0",serial_number="WD-WCC2E7ASAAX8",firmware_version="18.01H18"} 1
# HELP smartmon_device_smart_available SMART metric device_smart_available
# TYPE smartmon_device_smart_available gauge
smartmon_device_smart_available{disk="/dev/sda",type="sat"} 1
# HELP smartmon_device_smart_enabled SMART metric device_smart_enabled
# TYPE smartmon_device_smart_enabled gauge
smartmon_device_smart_enabled{disk="/dev/sda",type="sat"} 1
# HELP smartmon_end_to_end_error_raw_value SMART metric end_to_end_error_raw_value
# TYPE smartmon_end_to_end_error_raw_value gauge
smartmon_end_to_end_error_raw_value{disk="/dev/sda",type="sat",smart_id="184"} 0
# HELP smartmon_end_to_end_error_threshold SMART metric end_to_end_error_threshold
# TYPE smartmon_end_to_end_error_threshold gauge
smartmon_end_to_end_error_threshold{disk="/dev/sda",type="sat",smart_id="184"} 97
# HELP smartmon_end_to_end_error_value SMART metric end_to_end_error_value
# TYPE smartmon_end_to_end_error_value gauge
smartmon_end_to_end_error_value{disk="/dev/sda",type="sat",smart_id="184"} 100
# HELP smartmon_end_to_end_error_worst SMART metric end_to_end_error_worst
# TYPE smartmon_end_to_end_error_worst gauge
smartmon_end_to_end_error_worst{disk="/dev/sda",type="sat",smart_id="184"} 100
# HELP smartmon_load_cycle_count_raw_value SMART metric load_cycle_count_raw_value
# TYPE smartmon_load_cycle_count_raw_value gauge
smartmon_load_cycle_count_raw_value{disk="/dev/sda",type="sat",smart_id="193"} 58
# HELP smartmon_load_cycle_count_threshold SMART metric load_cycle_count_threshold
# TYPE smartmon_load_cycle_count_threshold gauge
smartmon_load_cycle_count_threshold{disk="/dev/sda",type="sat",smart_id="193"} 0
# HELP smartmon_load_cycle_count_value SMART metric load_cycle_count_value
# TYPE smartmon_load_cycle_count_value gauge
smartmon_load_cycle_count_value{disk="/dev/sda",type="sat",smart_id="193"} 200
# HELP smartmon_load_cycle_count_worst SMART metric load_cycle_count_worst
# TYPE smartmon_load_cycle_count_worst gauge
smartmon_load_cycle_count_worst{disk="/dev/sda",type="sat",smart_id="193"} 200
# HELP smartmon_offline_uncorrectable_raw_value SMART metric offline_uncorrectable_raw_value
# TYPE smartmon_offline_uncorrectable_raw_value gauge
smartmon_offline_uncorrectable_raw_value{disk="/dev/sda",type="sat",smart_id="198"} 0
# HELP smartmon_offline_uncorrectable_threshold SMART metric offline_uncorrectable_threshold
# TYPE smartmon_offline_uncorrectable_threshold gauge
smartmon_offline_uncorrectable_threshold{disk="/dev/sda",type="sat",smart_id="198"} 0
# HELP smartmon_offline_uncorrectable_value SMART metric offline_uncorrectable_value
# TYPE smartmon_offline_uncorrectable_value gauge
smartmon_offline_uncorrectable_value{disk="/dev/sda",type="sat",smart_id="198"} 200
# HELP smartmon_offline_uncorrectable_worst SMART metric offline_uncorrectable_worst
# TYPE smartmon_offline_uncorrectable_worst gauge
smartmon_offline_uncorrectable_worst{disk="/dev/sda",type="sat",smart_id="198"} 200
# HELP smartmon_power_cycle_count_raw_value SMART metric power_cycle_count_raw_value
# TYPE smartmon_power_cycle_count_raw_value gauge
smartmon_power_cycle_count_raw_value{disk="/dev/sda",type="sat",smart_id="12"} 37
# HELP smartmon_power_cycle_count_threshold SMART metric power_cycle_count_threshold
# TYPE smartmon_power_cycle_count_threshold gauge
smartmon_power_cycle_count_threshold{disk="/dev/sda",type="sat",smart_id="12"} 0
# HELP smartmon_power_cycle_count_value SMART metric power_cycle_count_value
# TYPE smartmon_power_cycle_count_value gauge
smartmon_power_cycle_count_value{disk="/dev/sda",type="sat",smart_id="12"} 100
# HELP smartmon_power_cycle_count_worst SMART metric power_cycle_count_worst
# TYPE smartmon_power_cycle_count_worst gauge
smartmon_power_cycle_count_worst{disk="/dev/sda",type="sat",smart_id="12"} 100
# HELP smartmon_power_on_hours_raw_value SMART metric power_on_hours_raw_value
# TYPE smartmon_power_on_hours_raw_value gauge
smartmon_power_on_hours_raw_value{disk="/dev/sda",type="sat",smart_id="9"} 10203
# HELP smartmon_power_on_hours_threshold SMART metric power_on_hours_threshold
# TYPE smartmon_power_on_hours_threshold gauge
smartmon_power_on_hours_threshold{disk="/dev/sda",type="sat",smart_id="9"} 0
# HELP smartmon_power_on_hours_value SMART metric power_on_hours_value
# TYPE smartmon_power_on_hours_value gauge
smartmon_power_on_hours_value{disk="/dev/sda",type="sat",smart_id="9"} 87
# HELP smartmon_power_on_hours_worst SMART metric power_on_hours_worst
# TYPE smartmon_power_on_hours_worst gauge
smartmon_power_on_hours_worst{disk="/dev/sda",type="sat",smart_id="9"} 87
# HELP smartmon_raw_read_error_rate_raw_value SMART metric raw_read_error_rate_raw_value
# TYPE smartmon_raw_read_error_rate_raw_value gauge
smartmon_raw_read_error_rate_raw_value{disk="/dev/sda",type="sat",smart_id="1"} 0
# HELP smartmon_raw_read_error_rate_threshold SMART metric raw_read_error_rate_threshold
# TYPE smartmon_raw_read_error_rate_threshold gauge
smartmon_raw_read_error_rate_threshold{disk="/dev/sda",type="sat",smart_id="1"} 51
# HELP smartmon_raw_read_error_rate_value SMART metric raw_read_error_rate_value
# TYPE smartmon_raw_read_error_rate_value gauge
smartmon_raw_read_error_rate_value{disk="/dev/sda",type="sat",smart_id="1"} 200
# HELP smartmon_raw_read_error_rate_worst SMART metric raw_read_error_rate_worst
# TYPE smartmon_raw_read_error_rate_worst gauge
smartmon_raw_read_error_rate_worst{disk="/dev/sda",type="sat",smart_id="1"} 200
# HELP smartmon_reallocated_sector_ct_raw_value SMART metric reallocated_sector_ct_raw_value
# TYPE smartmon_reallocated_sector_ct_raw_value gauge
smartmon_reallocated_sector_ct_raw_value{disk="/dev/sda",type="sat",smart_id="5"} 0
# HELP smartmon_reallocated_sector_ct_threshold SMART metric reallocated_sector_ct_threshold
# TYPE smartmon_reallocated_sector_ct_threshold gauge
smartmon_reallocated_sector_ct_threshold{disk="/dev/sda",type="sat",smart_id="5"} 140
# HELP smartmon_reallocated_sector_ct_value SMART metric reallocated_sector_ct_value
# TYPE smartmon_reallocated_sector_ct_value gauge
smartmon_reallocated_sector_ct_value{disk="/dev/sda",type="sat",smart_id="5"} 200
# HELP smartmon_reallocated_sector_ct_worst SMART metric reallocated_sector_ct_worst
# TYPE smartmon_reallocated_sector_ct_worst gauge
smartmon_reallocated_sector_ct_worst{disk="/dev/sda",type="sat",smart_id="5"} 200
# HELP smartmon_reported_uncorrect_raw_value SMART metric reported_uncorrect_raw_value
# TYPE smartmon_reported_uncorrect_raw_value gauge
smartmon_reported_uncorrect_raw_value{disk="/dev/sda",type="sat",smart_id="187"} 0
# HELP smartmon_reported_uncorrect_threshold SMART metric reported_uncorrect_threshold
# TYPE smartmon_reported_uncorrect_threshold gauge
smartmon_reported_uncorrect_threshold{disk="/dev/sda",type="sat",smart_id="187"} 0
# HELP smartmon_reported_uncorrect_value SMART metric reported_uncorrect_value
# TYPE smartmon_reported_uncorrect_value gauge
smartmon_reported_uncorrect_value{disk="/dev/sda",type="sat",smart_id="187"} 100
# HELP smartmon_reported_uncorrect_worst SMART metric reported_uncorrect_worst
# TYPE smartmon_reported_uncorrect_worst gauge
smartmon_reported_uncorrect_worst{disk="/dev/sda",type="sat",smart_id="187"} 100
# HELP smartmon_smartctl_run SMART metric smartctl_run
# TYPE smartmon_smartctl_run gauge
smartmon_smartctl_run{disk="/dev/sda",type="sat"} 1490668568
# HELP smartmon_spin_retry_count_raw_value SMART metric spin_retry_count_raw_value
# TYPE smartmon_spin_retry_count_raw_value gauge
smartmon_spin_retry_count_raw_value{disk="/dev/sda",type="sat",smart_id="10"} 0
# HELP smartmon_spin_retry_count_threshold SMART metric spin_retry_count_threshold
# TYPE smartmon_spin_retry_count_threshold gauge
smartmon_spin_retry_count_threshold{disk="/dev/sda",type="sat",smart_id="10"} 51
# HELP smartmon_spin_retry_count_value SMART metric spin_retry_count_value
# TYPE smartmon_spin_retry_count_value gauge
smartmon_spin_retry_count_value{disk="/dev/sda",type="sat",smart_id="10"} 100
# HELP smartmon_spin_retry_count_worst SMART metric spin_retry_count_worst
# TYPE smartmon_spin_retry_count_worst gauge
smartmon_spin_retry_count_worst{disk="/dev/sda",type="sat",smart_id="10"} 253
# HELP smartmon_spin_up_time_raw_value SMART metric spin_up_time_raw_value
# TYPE smartmon_spin_up_time_raw_value gauge
smartmon_spin_up_time_raw_value{disk="/dev/sda",type="sat",smart_id="3"} 4025
# HELP smartmon_spin_up_time_threshold SMART metric spin_up_time_threshold
# TYPE smartmon_spin_up_time_threshold gauge
smartmon_spin_up_time_threshold{disk="/dev/sda",type="sat",smart_id="3"} 21
# HELP smartmon_spin_up_time_value SMART metric spin_up_time_value
# TYPE smartmon_spin_up_time_value gauge
smartmon_spin_up_time_value{disk="/dev/sda",type="sat",smart_id="3"} 139
# HELP smartmon_spin_up_time_worst SMART metric spin_up_time_worst
# TYPE smartmon_spin_up_time_worst gauge
smartmon_spin_up_time_worst{disk="/dev/sda",type="sat",smart_id="3"} 138
# HELP smartmon_start_stop_count_raw_value SMART metric start_stop_count_raw_value
# TYPE smartmon_start_stop_count_raw_value gauge
smartmon_start_stop_count_raw_value{disk="/dev/sda",type="sat",smart_id="4"} 37
# HELP smartmon_start_stop_count_threshold SMART metric start_stop_count_threshold
# TYPE smartmon_start_stop_count_threshold gauge
smartmon_start_stop_count_threshold{disk="/dev/sda",type="sat",smart_id="4"} 0
# HELP smartmon_start_stop_count_value SMART metric start_stop_count_value
# TYPE smartmon_start_stop_count_value gauge
smartmon_start_stop_count_value{disk="/dev/sda",type="sat",smart_id="4"} 100
# HELP smartmon_start_stop_count_worst SMART metric start_stop_count_worst
# TYPE smartmon_start_stop_count_worst gauge
smartmon_start_stop_count_worst{disk="/dev/sda",type="sat",smart_id="4"} 100
# HELP smartmon_udma_crc_error_count_raw_value SMART metric udma_crc_error_count_raw_value
# TYPE smartmon_udma_crc_error_count_raw_value gauge
smartmon_udma_crc_error_count_raw_value{disk="/dev/sda",type="sat",smart_id="199"} 0
# HELP smartmon_udma_crc_error_count_threshold SMART metric udma_crc_error_count_threshold
# TYPE smartmon_udma_crc_error_count_threshold gauge
smartmon_udma_crc_error_count_threshold{disk="/dev/sda",type="sat",smart_id="199"} 0
# HELP smartmon_udma_crc_error_count_value SMART metric udma_crc_error_count_value
# TYPE smartmon_udma_crc_error_count_value gauge
smartmon_udma_crc_error_count_value{disk="/dev/sda",type="sat",smart_id="199"} 200
# HELP smartmon_udma_crc_error_count_worst SMART metric udma_crc_error_count_worst
# TYPE smartmon_udma_crc_error_count_worst gauge
smartmon_udma_crc_error_count_worst{disk="/dev/sda",type="sat",smart_id="199"} 200
EOD

values = actual_data.split("\n")
                    .select{|e| /^(\w.*)_raw_value/ =~ e }
                    .map{|e| /^(\w.*)_raw_value/ =~ e; $1 }

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
