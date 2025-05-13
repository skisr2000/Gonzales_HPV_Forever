view: patient_hpv_refusal {
  derived_table: {
    # datagroup_trigger: mhm_default_datagroup
    # indexes: ["patientid"]
    sql:
      SELECT *,
             COALESCE(date_fourth_shot_refusal, date_third_shot_refusal, date_second_shot_refusal, date_first_shot_refusal) AS last_refusal,
             (CASE WHEN date_first_shot_refusal IS NULL THEN 0 ELSE 1 END +
              CASE WHEN date_second_shot_refusal IS NULL THEN 0 ELSE 1 END +
              CASE WHEN date_third_shot_refusal IS NULL THEN 0 ELSE 1 END +
              CASE WHEN date_fourth_shot_refusal IS NULL THEN 0 ELSE 1 END) AS total_shots_refused
      FROM mhm.patienthpv_refusal ;;
  }

  dimension: patientid {
    type: number
    primary_key: yes
    sql: ${TABLE}.PatientID ;;
    value_format_name: id
  }

  dimension: comment_first_shot {
    type: string
    sql: CASE WHEN ${TABLE}.Comment_First_shot_refusal IS NULL THEN ''
              WHEN ${TABLE}.Comment_First_shot_refusal like '%SNOMED%' THEN 'No refusal reason provided.'
              ELSE ${TABLE}.Comment_First_shot_refusal
         END ;;
  }

  dimension: comment_second_shot {
    type: string
    sql: CASE WHEN ${TABLE}.Comment_Second_Shot_refusal IS NULL THEN ''
              ELSE ${TABLE}.Comment_Second_Shot_refusal
         END ;;
  }

  dimension_group: date_first_refusal {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.Date_First_shot_refusal ;;
  }

  dimension_group: date_second_refusal {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.Date_Second_shot_refusal ;;
  }

  dimension_group: date_third_refusal {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.Date_Third_shot_refusal ;;
  }

  dimension_group: date_fourth_refusal {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.Date_Fourth_shot_refusal ;;
  }

  dimension: did_patient_refuse_HPV_at_last_vist{
    type: string
    sql: CASE WHEN ${patient_hpv.is_hpv_patient} AND
                   datediff(day, ${last_refusal},${dos_detail.visit_date}) <= 0 THEN 'Yes'
              ELSE 'No'
         END ;;
    html: <div align="left"> {{rendered_value}} </div> ;;
  }

  dimension: last_refusal {
    type: date
    sql: ${TABLE}.last_refusal ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: practice_id {
    type: number
    sql: ${TABLE}.PracticeID ;;
    value_format_name: id
  }

  dimension: reason_first_shot {
    type: string
    sql: CASE WHEN ${TABLE}.Reason_First_shot_refusal IS NULL THEN ''
              ELSE ${TABLE}.Reason_First_shot_refusal
         END ;;
  }

  dimension: reason_second_shot {
    type: string
    sql: CASE WHEN ${TABLE}.Reason_Second_Shot_refusal IS NULL THEN ''
              ELSE ${TABLE}.Reason_Second_Shot_refusal
         END ;;
  }

  dimension: refusal_shot_status {
    type: string
    sql: CASE WHEN ${total_shots_refused} = 1 THEN 'First refusal was on ' +
                   CONVERT(varchar, ${date_first_refusal_date}) + '. '+ ${reason_first_shot} + ' - ' + ${comment_first_shot}
              WHEN ${total_shots_refused} = 2 THEN 'First refusal was on '+
                   CONVERT(varchar, ${date_first_refusal_date}) + '. ' + ${reason_first_shot} + ' - ' + ${comment_first_shot} + '. Second refusal was on ' +
                   CONVERT(varchar, ${date_second_refusal_date}) + '. ' + ${reason_second_shot} + ' - ' + ${comment_second_shot}
              WHEN ${total_shots_refused} = 3 THEN 'HPV Vaccination has been refused 3 times. The last refusal was on ' + CONVERT(varchar, ${date_third_refusal_date})
              WHEN ${total_shots_refused} >= 4 THEN 'HPV Vaccination has been refused at least 4 times'
              ELSE ''
         END ;;
  }

  dimension: total_shots_refused{
    type: number
    sql: CASE WHEN ${TABLE}.total_shots_refused IS NULL THEN 0 ELSE ${TABLE}.total_shots_refused END ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: refused_shots {
    type: count
    filters: {
      field: last_refusal
      value: "-NULL"
    }
    html: <div align="center"> {{rendered_value}} </div> ;;
    drill_fields: [patient_hpv.hpvdetail*]
  }

  measure: refused_shots_in_timeframe{
    type: count
    filters: {
      field: did_patient_refuse_HPV_at_last_vist
      value: "Yes"
    }
    html: <div align="center"> {{rendered_value}} </div> ;;
    drill_fields: [patient_hpv.hpvdetail*]
  }

  measure: refused_shot_1_in_timeframe{
    type: count
    filters: {
      field: patient_hpv.was_refusal_after_dose_1
      value: "No"
    }
    filters: {
      field: did_patient_refuse_HPV_at_last_vist
      value: "Yes"
    }
    html: <div align="center"> {{rendered_value}} </div> ;;
    drill_fields: [patient_hpv.hpvdetail*]
  }

  set: hpvdetail {
    fields: [data.patient_mrn,
      data.patient_name,
      data.sex,
      data.patient_age,
      data.dob,
      data.last_Appt,
      data.Next_Appt,
      pcp.pcp_name,
      patient_hpv.first_shot_date,
      patient_hpv.second_shot_date,
      patient_hpv.third_shot_date,
      last_refusal,
      patient_hpv.hpv_status,
      patient_hpv.hpv_vaccination_complete,
      patient_hpv.total_shots]
  }
}
