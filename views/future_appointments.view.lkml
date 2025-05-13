# view: future_appointments {
#   sql_table_name: mhm.Future_appointments ;;


view: future_appointments {
  derived_table: {
    sql:select f.apptid, f.practiceid,f.patientid, f.Appt_Date, f.payerid, i.payer_name, f.ProviderID, p.provider_name, p.first_name, p.last_name, p.provider_alias, f.LocationID, l.location, l.location_alias, l.county, l.combined_location, f.counter, f.appt_reason
      FROM mhm.Future_appointments f
      inner Join mhm.location l on f.LocationID = l.locationid
      inner JOIN mhm.provider p ON p.providerid = f.providerid
      Left JOIN mhm.payers i ON i.payerid = f.payerid ;;
  }

  # select f.practiceid, f.patientid, f.Appt_Date, f.payerid, i.payer_name, f.ProviderID, p.provider_name, p.provider_alias, f.LocationID, l.location, l.location_alias, l.county, l.combined_location, f.counter, f.appt_reason
  #   FROM mhm.Future_appointments f
  #   inner Join mhm.location l on f.LocationID = l.locationid
  #   inner JOIN mhm.provider p ON p.providerid = f.providerid
  #   Left JOIN mhm.payers i ON i.payerid = f.payerid

  dimension: expected_payerid {
    type: number
    sql: ${TABLE}.payerid ;;
    value_format_name: id
  }

  dimension: expected_payer_name {
    type: string
    sql: ${TABLE}.payer_name ;;
  }

  measure: count {
    type: count
    drill_fields: [appt_detail*]
  }

  dimension: provider_name {
    type: string
    sql: {% if _user_attributes['demo'] == 1 %}
          --${TABLE}.provider_alias
          ${provider_alias}
        {% elsif _user_attributes['mhmid'] == 1 %}
         ${TABLE}.provider_name
        {% else %}
         Concat('Provider ID - ',${TABLE}.providerid)
        {% endif %} ;;
  }

  dimension: provider_alias {
    type: string
    sql: CASE
            WHEN ${TABLE}.provider_alias IS NOT NULL
            THEN ${TABLE}.provider_alias
            ELSE
            'Dr. Smith'
            END;;
  }

  dimension: provider_name_last_name_first {
    type: string
    sql: {% if _user_attributes['demo'] == 1 %}
          --${TABLE}.provider_alias
          ${provider_alias}
        {% elsif _user_attributes['mhmid'] == 1 %}
         concat(${provider_last_name},', ',${provider_first_name})
        {% else %}
         Concat('Provider ID - ',${TABLE}.providerid)
        {% endif %} ;;
  }


  dimension: texting_provider {
    type: string
    sql: CASE
            WHEN CONCAT(' with ', ${provider_name})
            ;;
  }



  dimension: location {
    type: string
    sql: {% if _user_attributes['mhmid'] == 0 %}
         ${TABLE}.location_alias
         {% elsif _user_attributes['showlocation'] == 1 %}
         ${TABLE}.location
         {% elsif _user_attributes['demo'] == 1 %}
         ${TABLE}.location_alias
         {% elsif _user_attributes['mhmid'] == 1 %}
         ${TABLE}.location
         {% elsif _user_attributes['demo'] == 0 %}
         ${TABLE}.location
         {% else %}
         ${TABLE}.location_alias
         {% endif %} ;;
  }

  dimension: location_alias {
    type: string
    sql: ${TABLE}.location_alias ;;
  }

  dimension: provider_first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: provider_last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: county {
    type: string
    sql: ${TABLE}.county ;;
  }

  dimension: combined_location {
    type: string
    sql: ${TABLE}.combined_location ;;
  }

  dimension: appt_id {
    hidden: no
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.apptid ;;
  }

  dimension_group: appt {
    group_label: "Appointment Date"
    type: time
    timeframes: [
      raw,
      time,
      time_of_day,
      date,
      day_of_week,
      day_of_week_index,
      week,
      month,
      quarter,
      year
    ]
    sql:
          ${TABLE}.appt_date;;
  }


  dimension_group: Appointment {
    description: "check Formatted Appt Date (mm/dd/yyyy)"
    group_label: "Appointment Date_calc"
    type: time
    timeframes: [
      raw,
      time,
      time_of_day,
      date,
      day_of_week,
      day_of_week_index,
      week,
      month,
      quarter,
      year
    ]
    sql: ${appt_date};;

    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: Appointment_Date_format_day {
    description: "Formatted Appt Date (Wednesday, March 4)"
    group_label: "Appointment Date"
    type: date
    sql: ${Appointment_date} ;;
    html: <div align="center"> {{rendered_value | date:' %A, %B %e' }} </div> ;;
  }

  # dimension: Appointment_Date_format_day {
  #   description: "Formatted Appt Date (Wednesday, March 4)"
  #   group_label: "Appointment Date"
  #   type: date
  #   sql: ${appt_date} ;;
  #   html: <div align="center"> {{rendered_value | date:' %A, %B %e' }} </div> ;;
  # }

  dimension: Appointment_Date_format_day_with_yr {
    description: "Formatted Appt Date (Wednesday, March 4,2023)"
    group_label: "Appointment Date"
    type: date
    sql: ${appt_date} ;;
    html: <div align="center"> {{rendered_value | date:' %A, %B %e %Y' }} </div> ;;
  }

  dimension: appt_datetime_formatted {
    label: "Date/Time Formatted"
    group_label: "Appt Date"
    description: "Shorthand string formated date and time of next appointment. EX: Mar 3 2022 3:30PM"
    # sql: CONVERT(VARCHAR(20), ${appt_raw}, 10o) ;;
    sql: (CONVERT(VARCHAR(20), ${appt_raw}, 107))+' at '+${appt_time_12hour} ;;
  }

  dimension: appt_time_formatted {
    label: "Time Formatted"
    group_label: "Appt Date"
    description: "Shorthand string formated time of next appointment. EX:  13:30"
    sql: CONVERT(VARCHAR(10), ${appt_raw}, 108) ;;
  }

  dimension: appt_date_mmddyyyy {
    label: "Date (MM-DD-YYYY)"
    group_label: "Appt Date"
    description: "MM-DD-YYYY formated date of next appointment. EX: 03-03-2022"
    sql: ${appt_date} ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>;;
  }

  # dimension: appt_detailed_info {
  #   sql: CONVERT(VARCHAR(20), ${Appointment_date}, 100) +' at '+${appt_time_formatted} +' with '+${provider_name_last_name_first} +' for ' + ${appt_reason} + ' at ' + ${location.location} ;;
  # }

  dimension: appt_detailed_info {
    sql: ${Appointment_date} +' at '+${appt_time_formatted} +' with '+${provider_name_last_name_first} +' for ' + ${appt_reason} + ' at ' + ${location.location} ;;
  }

  dimension: appt_reason {
    type: string
    sql: CASE
          WHEN ${TABLE}.appt_reason is NULL THEN 'No Appointment Info provided'
          WHEN ${TABLE}.appt_reason = '' THEN 'No Appointment Info provided'
          ELSE
          ${TABLE}.appt_reason
          END
          ;;
  }

  dimension: appt_time_12hour {
    label: "Time (12 hour)"
    group_label: "Appt Date"
    description: "HH:MI AM/PM formatted time of next appointment. EX: 3:30 PM"
    sql: FORMAT(${appt_raw}, 'hh:mm tt') ;;
  }

  # dimension: appt_date_formatted {
  #   label: "Date Test"
  #   group_label: "Appt Date"
  #   description: "EX: 03-03-2022"
  #   sql: CONVERT(varchar, ${appt_raw}, 101);;
  # }


  dimension: appt_date_formatted {
    label: "Date (MM-DD-YYYY)"
    group_label: "Appt Date"
    description: "MM-DD-YYYY formated date of next appointment. EX: 03-03-2022"
    sql: ${Appointment_Date_format_day} ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>;;
  }

  # dimension: appt_date_time_format {
  #   label: "appt date and time formatted "
  #   group_label: "Appt Date"
  #   description: "MM-DD-YYYY and tine formated date of next appointment. EX: 03-03-2022 at 2:30 PM"
  #   sql: ${appt_date_formatted}+' at '+${appt_time_12hour} ;;
  #   }

  dimension: appt_date_time_format {
    label: "appt date and time formatted "
    group_label: "Appt Date"
    description: "MM-DD-YYYY and tine formated date of next appointment. EX: 03-03-2022 at 2:30 PM"
    sql: ${appt_date_formatted}+' at '+${appt_time_12hour} ;;
  }



  # dimension: appt_reminder_count_down {
  #   description: "Used for weekend offset calculations. Appointment reminders will be queued when the value = 0.  If we send out 1 time each hour,
  #   then the filter for this is 0.  If there is an offset for the weekend, it will run the text script the hours amount picked."
  #   type: number
  #   sql: CASE WHEN ${appt_day_of_week_index} IN
  #             {% if appt_reminder_weekend_offset._parameter_value == "24" %}
  #             (0)
  #             {% elsif appt_reminder_weekend_offset._parameter_value == "48" %}
  #             (0, 1)
  #             {% elsif appt_reminder_weekend_offset._parameter_value == "72" %}
  #             (0, 1, 2)
  #             {% elsif appt_reminder_weekend_offset._parameter_value == "96" %}
  #             (0, 1, 2, 3)
  #             {% else %}
  #             (8)  -- Will never evaluate to true.
  #             {% endif %}
  #             THEN DATEDIFF(hour, CURRENT_TIMESTAMP, ${appt_raw}) - ({% parameter appt_reminder_weekend_offset %} + 48)  -- + 48 for saturday & sunday
  #             ELSE DATEDIFF(hour, CURRENT_TIMESTAMP, ${appt_raw}) - {% parameter appt_reminder_weekend_offset %}
  #       END ;;
  # }

  # dimension: appt_reminder_count_down {
  #   description: "Used for weekend offset calculations. Appointment reminders will be queued when the value = 0.  If we send out 1 time each hour,
  #   then the filter for this is 0.  If there is an offset for the weekend, it will run the text script the hours amount picked."
  #   type: number
  #   sql: CASE
  #           WHEN ${appt_day_of_week_index} = 0 and ${texting_campaigns.hours_in_adv} = 24 THEN ${time_from_appt_to_today}
  #           WHEN (${appt_day_of_week_index} = 0 or ${appt_day_of_week_index} = 1) and ${texting_campaigns.hours_in_adv} = 48 THEN ${time_from_appt_to_today} - 48
  #           WHEN (${appt_day_of_week_index} = 0 or ${appt_day_of_week_index} = 1 or ${appt_day_of_week_index} = 2)  and ${texting_campaigns.hours_in_adv} = 72 THEN ${time_from_appt_to_today}
  #           WHEN (${appt_day_of_week_index} = 0 or ${appt_day_of_week_index} = 1 or ${appt_day_of_week_index} = 2 or ${appt_day_of_week_index} = 3)  and ${texting_campaigns.hours_in_adv} = 96 THEN ${time_from_appt_to_today}
  #           ELSE ${time_from_appt_to_today}
  #       END ;;
  # }

  dimension: location_id {
    hidden: no
    type: number
    sql: ${TABLE}.locationid ;;
  }

  # Should a "future appointment" include today? This is defined as BETWEEN 1 instead of BETWEEN 0 to exclude today.
  # dimension: next_appt_within_60_days {
  #   type: yesno
  #   sql: CAST(
  #         CASE WHEN DATEDIFF(day, GETDATE(), ${appt_raw}) BETWEEN 1 AND 60
  #             THEN 1
  #             ELSE 0
  #         END AS bit
  #       ) = 'true' ;;
  # }

  dimension: next_appt_within_60_days {
    type: yesno
    sql: CAST(
          CASE WHEN DATEDIFF(day, GETDATE(), ${Appointment_raw}) BETWEEN 1 AND 60
               THEN 1
               ELSE 0
          END AS bit
         ) = 'true' ;;
  }

  # Should a "future appointment" include today? This is defined as BETWEEN 1 instead of BETWEEN 0 to exclude today.
  dimension: time_from_appt_to_today {
    type: number
    sql: DATEDIFF(HOUR, GETDATE(), ${appt_raw}) ;;
  }

  #     # Should a "future appointment" include today? This is defined as BETWEEN 1 instead of BETWEEN 0 to exclude today.
  # dimension: time_from_appt_to_today {
  #   type: number
  #   sql: DATEDIFF(CURRENT_TIMESTAMP, ${appt_raw}, HOUR) ;;
  # }

  dimension: next_appt_is_today {
    type: yesno
    sql: CAST(
          CASE WHEN DATEDIFF(day, GETDATE(), ${appt_raw}) = 0
               THEN 1
               ELSE 0
          END AS bit
         ) = 'true' ;;
  }

  dimension: patientid {
    hidden: yes
    type: number
    sql: ${TABLE}.patientid ;;
    value_format_name: id
  }

  dimension: practice_id {
    hidden: no
    type: number
    sql: ${TABLE}.practiceid ;;
    value_format_name: id
  }

  dimension: provider_id {
    hidden: no
    type: number
    sql: ${TABLE}.providerid ;;
    value_format_name: id
  }

  measure: first_appt {
    type: date
    sql: min(${appt_date}) ;;
  }

  measure: next_appt {
    type: date
    sql: min(${appt_date}) ;;
  }

  measure: count_appointments {
    description: "Distinct patient count for patient who have upcoming appointment(s)"
    type: count_distinct
    sql: ${patientid} ;;
    drill_fields: [appt_detail*]
    link: {
      label: "Today's Patient List"
      url: "/looks/443?toggle=det"
    }
    link: {
      label: "Appointment Details"
      url: "/dashboards-next/126?"
    }
  }

  # measure: patients_with_upcoming_appointments {
  #   description: "Distinct patient count for patient who have upcoming appointment(s)"
  #   type: count_distinct
  #   sql: ${patientid} ;;
  #   drill_fields: [appt_detail*]
  # }

  # measure: count_appointments {
  #   type: count_distinct
  #   sql: ${Appointment_Date_blah} ;;
  #   drill_fields: [appt_detail*]
  #   link: {
  #     label: "Today's Patient List"
  #     url: "/looks/443?toggle=det"
  #   }
  #   link: {
  #     label: "Appointment Details"
  #     url: "/dashboards-next/126?"
  #   }
  # }

  measure: count_appt_ids {
    type: count
    drill_fields: [appt_detail*]
    link: {
      label: "Today's Patient List"
      url: "/looks/443?toggle=det"
    }
    link: {
      label: "Appointment Details"
      url: "/dashboards-next/126?"
    }
  }

  # measure: count_appt_ids {
  #   description: "Distinct patient count for patient who have upcoming appointment(s)"
  #   type: count_distinct
  #   sql: ${appt_id} ;;
  #   drill_fields: [appt_detail*]
  #   link: {
  #     label: "Today's Patient List"
  #     url: "/looks/443?toggle=det"
  #   }
  #   link: {
  #     label: "Appointment Details"
  #     url: "/dashboards-next/126?"
  #   }
  # }

  dimension: intergy_patient {
    type: yesno
    sql:  ${practice_id} = 1003;;

  }

  dimension: ecw_patient {
    type: yesno
    sql:  ${practice_id} = 1017 ;;
  }

  measure: Intergy_Appts{
    type: count
    filters: {
      field: intergy_patient
      value: "Yes"
    }
    drill_fields: [appt_detail*]
  }

  measure: ecw_Appts {
    type: count
    filters: {
      field: ecw_patient
      value: "Yes"
    }
    drill_fields: [appt_detail*]
  }

  measure: count_hpv_appointments {
    label: "Scheduled Appts for HPV Eligible"
    type: count
    drill_fields: [hpvdetail_upcoming_appts*]

  }

  measure: patients_with_upcoming_appointments {
    description: "Distinct patient count for patient who have upcoming appointment(s)"
    type: count_distinct
    sql: ${patientid} ;;
    drill_fields: [appt_detail*]
  }

  # Review w/ Rick: Data patients or patients in this view?
  measure: count_patients_with_appt_in_next_60_days {
    type: count_distinct
    filters: {
      field: next_appt_within_60_days
      value: "Yes"
    }
    sql: ${data.patient_id} ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
    drill_fields: [appt_detail*]
  }

  # Review w/ Rick: Data patients or patients in this view?
  measure: count_patients_with_no_appt_in_next_60_days {
    type: count_distinct
    filters: {
      field: next_appt_within_60_days
      value: "No"
    }
    sql: ${data.patient_id} ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
    drill_fields: [appt_detail*]
  }

  measure: count_patients_with_appt_this_quarter {
    type: count_distinct
    filters: {
      field: appt_date
      value: "this quarter"
    }
    sql: ${data.patient_id} ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
    drill_fields: [appt_detail*]
  }

  parameter: appt_reminder_weekend_offset {
    type: number
    description: "If end user has enabled weekend offsets, this parameter is used to manipulate the countdown to appointment reminder send. "
    default_value: "48"
    allowed_value: {
      label: "24 hours"
      value: "24"
    }
    allowed_value: {
      label: "48 hours"
      value: "48"
    }
    allowed_value: {
      label: "72 hours"
      value: "72"
    }
    allowed_value: {
      label: "96 hours"
      value: "96"
    }
  }

  set: hpvdetail_upcoming_appts{
    fields: [derived_patient_data.patient_mrn,
      derived_patient_data.patient_name,
      appt_date_mmddyyyy,
      appt_time_12hour,
      appt_reason,
      provider_name,
      location.location,
      derived_patient_data.age,
      derived_patient_data.sex,
      derived_patient_data.dob_date,
      derived_patient_hpv_final.age_at_1st_shot,
      derived_patient_hpv_final.first_shot_date,
      derived_patient_hpv_final.second_shot_date,
      derived_patient_hpv_final.third_shot_date,
      patient_hpv_refusal.last_refusal,
      derived_patient_hpv_final.hpv_status,
      derived_patient_hpv_final.total_shots]
  }

  # set: use_in_scheduler {
  #   fields: [
  #     appt_id,
  #     appt_date,
  #     appt_datetime_formatted,
  #     appt_reason,
  #     appt_reminder_count_down,
  #     appt_reminder_weekend_offset,
  #     next_appt_within_60_days,
  #     patientid
  #   ]
  # }

  set: appt_detail {
    fields: [
      derived_patient_data.patient_name,
      derived_patient_data.patient_mrn,
      Appointment_date,
      provider_name_last_name_first,
      derived_patient_data.age,
      derived_patient_data.dob_date,
      derived_patient_data.sex,
      last_patient_tests.last_date_of_service,
      last_patient_tests.last_hba1c_result,
      uds_measures_data.uds_problem_list,
      last_patient_tests.gap_list_text,
      pcp.pcp_name
    ]
  }
}
