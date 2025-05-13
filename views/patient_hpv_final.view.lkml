view: patient_hpv_final {

  derived_table: {
    sql: SELECT *,
             CASE WHEN recommended_number_of_shots = 4 AND had_fourth_shot = 'true' AND (date_fourth_shot >= recommended_4th_shot_date_start)
                  THEN date_fourth_shot
                  WHEN recommended_number_of_shots = 3 AND had_third_shot = 'true' AND (date_third_shot >= recommended_3rd_shot_date_start)
                  THEN date_third_shot
                  WHEN recommended_number_of_shots = 2 AND had_second_shot = 'true' AND (date_second_shot >= recommended_2nd_shot_date_start)
                  THEN date_second_shot
                  WHEN recommended_number_of_shots = 4 AND had_fourth_shot = 'true'
                  THEN date_fourth_shot
                  WHEN recommended_number_of_shots = 3 AND had_first_shot = 'true' AND had_second_shot = 'true' AND had_third_shot = 'true'
                  THEN date_third_shot
                  ELSE NULL
             END AS hpv_vaccination_complete_date
      FROM (
        SELECT *,
               CASE WHEN recommended_number_of_shots <= 3 THEN NULL
                    WHEN had_first_shot = 'true' AND had_second_shot = 'true' AND date_third_shot < recommended_3rd_shot_date_start
                         AND DATEADD(month, 5, date_first_shot) >= DATEADD(week, 12, date_third_shot) THEN DATEADD(month, 5, date_first_shot)
                    WHEN had_first_shot = 'true' AND had_second_shot = 'true' AND date_third_shot < recommended_3rd_shot_date_start
                         AND DATEADD(month, 5, date_first_shot) < DATEADD(week, 12, date_third_shot) THEN DATEADD(week, 12, date_third_shot)
                    WHEN had_first_shot = 'true' AND had_second_shot = 'true' AND date_third_shot >= recommended_3rd_shot_date_start
                         AND DATEADD(month, 5, date_first_shot) >= DATEADD(week, 12, date_third_shot) THEN DATEADD(month, 5, date_first_shot)
                    WHEN had_first_shot = 'true' AND had_second_shot = 'true' AND date_third_shot >= recommended_3rd_shot_date_start
                         AND DATEADD(month, 5, date_first_shot) < DATEADD(week, 12, date_third_shot) THEN DATEADD(week, 12, date_third_shot)
                    ELSE NULL
                END AS recommended_4th_shot_date_start
        FROM (
          SELECT *,
                 CASE WHEN recommended_number_of_shots <= 2 THEN NULL
                      WHEN had_first_shot = 'true' AND date_second_shot < recommended_2nd_shot_date_start
                        AND (DATEADD(month, 5, date_first_shot) >= DATEADD(week, 12, date_second_shot))
                      THEN DATEADD(month, 5, date_first_shot)
                      WHEN had_first_shot = 'true' AND date_second_shot < recommended_2nd_shot_date_start
                        AND (DATEADD(month, 5, date_first_shot) < DATEADD(week, 12, date_second_shot))
                      THEN DATEADD(week, 12, date_second_shot)
                      WHEN had_first_shot = 'true' AND date_second_shot >= recommended_2nd_shot_date_start
                        AND (DATEADD(month, 5, date_first_shot) >= DATEADD(week, 12, date_second_shot))
                      THEN DATEADD(month, 5, date_first_shot)
                      WHEN had_first_shot = 'true' AND date_second_shot >= recommended_2nd_shot_date_start
                        AND (DATEADD(month, 5, date_first_shot) < DATEADD(week, 12, date_second_shot))
                      THEN DATEADD(week, 12, date_second_shot)
                      ELSE NULL
                  END AS recommended_3rd_shot_date_start
          FROM (
            SELECT p.*,
                   CASE WHEN p.age_at_1st_shot >= 27 AND p.had_third_shot = 'true' AND p.date_third_shot < DATEADD(month, 5, p.date_first_shot) THEN 4
                        WHEN p.age_at_1st_shot >= 27 AND p.had_second_shot = 'true' AND p.date_second_shot < DATEADD(month, 5, p.date_first_shot) THEN 3
                        WHEN p.age_at_1st_shot >= 27 AND p.had_first_shot = 'true' THEN 3
                        WHEN (p.age_at_1st_shot >= 9 AND p.age_at_1st_shot < 15) AND p.had_second_shot = 'true' AND p.date_second_shot >= DATEADD(month, 5, p.date_first_shot) THEN 2
                        WHEN (p.age_at_1st_shot >= 9 AND p.age_at_1st_shot < 15) AND ((p.had_third_shot = 'true' AND  p.date_third_shot < DATEADD(month, 5, p.date_first_shot))
                          OR (p.date_third_shot <  DATEADD(week, 12, p.date_second_shot))) THEN 4
                        WHEN (p.age_at_1st_shot >= 9 AND p.age_at_1st_shot < 15) AND p.had_second_shot = 'true' AND p.date_second_shot < DATEADD(month, 5, p.date_first_shot) THEN 3
                        WHEN p.age_at_1st_shot >= 9 AND p.age_at_1st_shot < 15 AND p.had_second_shot = 'false' THEN 2
                        WHEN (p.age_at_1st_shot >= 15 AND p.age_at_1st_shot <= 26) AND p.had_third_shot = 'true' AND p.date_third_shot < DATEADD(month, 5, p.date_first_shot) THEN 4
                        WHEN (p.age_at_1st_shot >= 15 AND p.age_at_1st_shot <= 26) AND p.had_second_shot = 'true' AND p.date_third_shot < DATEADD (week, 12, p.date_second_shot) THEN 4
                        WHEN p.age_at_1st_shot >=15 AND p.age_at_1st_shot <=26 THEN 3
                        WHEN p.age_at_4th_shot < 9 THEN 6
                        WHEN p.age_at_3rd_shot < 9 THEN 5
                        WHEN p.age_at_2nd_shot < 9 THEN 4
                        WHEN p.age_at_1st_shot < 9 AND p.age_at_2nd_shot >= 9 AND p.age_at_2nd_shot < 15 THEN 3
                        WHEN p.age_at_1st_shot < 9 AND p.age_at_2nd_shot >= 15 THEN 4
                        WHEN p.age_at_1st_shot < 9 AND p.age_at_4th_shot >= 9 THEN 5
                        --WHEN p.age_at_1st_shot < 9 AND p.age_at_2nd_shot >= 15 THEN 4
                        WHEN p.age_at_1st_shot < 9 AND p.had_second_shot = 'False' THEN 3
                        ELSE 99
                   END AS recommended_number_of_shots,
                   CASE WHEN age_at_1st_shot < 15 THEN DATEADD(month, 5, date_first_shot)
                        WHEN age_at_1st_shot >= 15 THEN DATEADD(month, 1, date_first_shot)
                        ELSE NULL
                   END AS recommended_2nd_shot_date_start
            FROM (
              SELECT hpv.*,
                     CAST(IIF(hpv.date_first_shot IS NOT NULL, 1, 0) AS bit) AS had_first_shot,
                     CAST(IIF(hpv.date_second_shot IS NOT NULL, 1, 0) AS bit) AS had_second_shot,
                     CAST(IIF(hpv.date_third_shot IS NOT NULL, 1, 0) AS bit) AS had_third_shot,
                     CAST(IIF(hpv.date_fourth_shot IS NOT NULL, 1, 0) AS bit) AS had_fourth_shot,
                     CAST(IIF(hpv.date_fifth_shot IS NOT NULL, 1, 0) AS bit) AS had_fifth_shot,
                     CAST(IIF(hpv.date_sixth_shot IS NOT NULL, 1, 0) AS bit) AS had_sixth_shot,
                     CAST(IIF(hpv.date_seventh_shot IS NOT NULL, 1, 0) AS bit) AS had_seventh_shot,
                     CAST(IIF(hpv.date_eighth_shot IS NOT NULL, 1, 0) AS bit) AS had_eighth_shot,
                     CASE WHEN (MONTH(getdate()) * 100) + DAY(getdate()) >= (MONTH(data.dob) * 100) + DAY(data.dob)
                      THEN DATEDIFF(year, data.dob, getdate())
                      ELSE DATEDIFF(year, data.dob, getdate()) - 1
                      END AS age,
                     CASE WHEN (MONTH(hpv.date_first_shot) * 100) + DAY(hpv.date_first_shot) >= (MONTH(data.dob) * 100) + DAY(data.dob)
                          THEN DATEDIFF(year, data.dob, hpv.date_first_shot)
                          ELSE DATEDIFF(year, data.dob, hpv.date_first_shot) - 1
                     END AS age_at_1st_shot,
                     CASE WHEN (MONTH(hpv.date_second_shot) * 100) + DAY(hpv.date_second_shot) >= (MONTH(data.dob) * 100) + DAY(data.dob)
                          THEN DATEDIFF(year, data.dob, hpv.date_second_shot)
                          ELSE DATEDIFF(year, data.dob, hpv.date_second_shot) - 1
                     END AS age_at_2nd_shot,
                       CASE WHEN (MONTH(hpv.date_third_shot) * 100) + DAY(hpv.date_third_shot) >= (MONTH(data.dob) * 100) + DAY(data.dob)
                          THEN DATEDIFF(year, data.dob, hpv.date_third_shot)
                          ELSE DATEDIFF(year, data.dob, hpv.date_third_shot) - 1
                     END AS age_at_3rd_shot,
                     CASE WHEN (MONTH(hpv.date_fourth_shot) * 100) + DAY(hpv.date_fourth_shot) >= (MONTH(data.dob) * 100) + DAY(data.dob)
                          THEN DATEDIFF(year, data.dob, hpv.date_fourth_shot)
                          ELSE DATEDIFF(year, data.dob, hpv.date_fourth_shot) - 1
                     END AS age_at_4th_shot,
                     COALESCE(hpv.date_eighth_shot, hpv.date_seventh_shot, hpv.date_sixth_shot, hpv.date_fifth_shot,
                              hpv.date_fourth_shot, hpv.date_third_shot, hpv.date_second_shot, hpv.date_first_shot) AS last_dose_date,
                    COALESCE(r.date_sixth_shot_refusal, r.date_fifth_shot_refusal, r.date_fourth_shot_refusal, r.date_third_shot_refusal, r.date_second_shot_refusal, r.date_first_shot_refusal) AS last_refusal

      --ELSE NULL
      --END AS dose_1_last_refusal_compare
      FROM mhm.patienthpv AS hpv
      LEFT JOIN mhm.data AS data
      ON hpv.patientid = data.patientid
      LEFT JOIN mhm.PatientHPV_refusal AS r
      ON hpv.patientid = r.patientid
      ) AS p
      LEFT JOIN data.patientid AS d
      ON p.patientid = d.patientid
      ) AS table_3
      ) AS table_4
      ) AS table_final ;;
  }

  filter: timeframe_filter {
    type: date
  }

  dimension: patientid {
    primary_key: yes
    hidden: yes
    type: number
    value_format_name: id
    sql: ${TABLE}.PatientID ;;
  }

  dimension: 1st_shot_status {
    type: string
    # Must hardcode table reference to had_first_shot to get accurate results when patientid NOT IN mhm.patienthpv
    sql: CASE WHEN (${TABLE}.had_first_shot = 'false' OR ${TABLE}.had_first_shot IS NULL) AND (${data.age} >= 9 AND ${data.age} <= 26) AND DATEDIFF(day, GETDATE(), ${future_appointments.appt_date}) = 0
              THEN 'Patient is missing first HPV Dose, 1st dose is recommended at today''s appt. '
               WHEN (${TABLE}.had_first_shot = 'false' OR ${TABLE}.had_first_shot IS NULL) AND (${data.age} >= 9 AND ${data.age} <= 26) AND GETDATE() <= ${future_appointments.appt_date}
              THEN 'Patient is missing first HPV Dose, 1st dose is recommended at scheduled appt on ' + ${future_appointments.appt_date} + '. '
              WHEN (${TABLE}.had_first_shot = 'false' OR ${TABLE}.had_first_shot IS NULL) AND (${data.age} >= 9 AND ${data.age} <= 26)
              THEN 'Patient is missing first HPV Dose and there is no record of a future appointment scheduled. '
              WHEN ${had_first_shot} AND ${had_second_shot}
              THEN ''
              WHEN ${TABLE}.had_first_shot = 'true' and ${age_at_1st_shot} < 9
              THEN '1st dose documented when patient was '+ CONVERT(varchar, ${age_at_1st_shot})+' years old. Documentation may be incorrect or dose was delivered too early. '
              WHEN ${TABLE}.had_first_shot = 'true'
              THEN '1st dose administered on '+ ${first_shot_date_formatted} + '. '
              ELSE ''
          END ;;
    html: <div align="left"> {{rendered_value}} </div> ;;
  }

  dimension: 2nd_shot_status {
    type: string
    # Must hardcode table reference to had_second_shot to get accurate results when patientid NOT IN mhm.patienthpv
    sql: CASE WHEN ${age_at_1st_shot} < 9 THEN 'Next dose should be provided following 9th birthday.  '
              WHEN (${TABLE}.had_second_shot = 'false' OR ${TABLE}.had_second_shot IS NULL) AND ${recommended_number_of_shots} = 2 AND ${had_first_shot} AND ${data.next_appointment_date} < DATEADD(month, 5, ${first_shot_date})
              THEN 'Scheduled appt on ' + ${data.next_appointment_date_formatted} + ' is TOO EARLY FOR 2ND DOSE. Recommendation is to schedule 2nd dose after ' + ${recommended__2nd_shot_date_start_formatted} + '. '
              WHEN (${TABLE}.had_second_shot = 'false' OR ${TABLE}.had_second_shot IS NULL) AND ${recommended_number_of_shots} = 2 AND ${had_first_shot}
                   AND ${data.next_appointment_date} >= DATEADD(month, 5, ${first_shot_date})
              THEN '2nd dose is recommended at scheduled appt on ' + ${data.next_appointment_date_formatted} + '. '
              WHEN (${TABLE}.had_second_shot = 'false' OR ${TABLE}.had_second_shot IS NULL) AND ${recommended_number_of_shots} = 2 AND ${had_first_shot}
                   AND GETDATE() < DATEADD(month, 5, ${first_shot_date})
              THEN 'Recommendatation is to schedule an appt after ' + ${recommended__2nd_shot_date_start_formatted} + ' to administer 2nd dose. '
              WHEN (${TABLE}.had_second_shot = 'false' OR ${TABLE}.had_second_shot IS NULL) AND ${recommended_number_of_shots} = 2 AND ${had_first_shot}
                   AND GETDATE() >= DATEADD(month, 5, ${first_shot_date})
              THEN 'Recommendatation is to schedule an appt to administer 2nd dose. '
              WHEN ${TABLE}.had_second_shot = 'true' AND ${recommended_number_of_shots} = 2 AND ${second_shot_date} >= ${recommended__2nd_shot_date_start}
              THEN '2nd dose administered on '+${second_shot_date_formatted}+' Vaccination complete. '
              WHEN (${TABLE}.had_second_shot = 'false' OR ${TABLE}.had_second_shot IS NULL) AND ${recommended_number_of_shots} = 3 AND ${had_first_shot}
                   AND ${data.next_appointment_date} < DATEADD(month, 1, ${first_shot_date})
              THEN 'Scheduled appt on ' + ${data.next_appointment_date_formatted} + ' is TOO EARLY FOR 2ND DOSE. Recommendation is to schedule 2nd dose after ' + ${recommended__2nd_shot_date_start_formatted} + '. '
              WHEN (${TABLE}.had_second_shot = 'false' OR ${TABLE}.had_second_shot IS NULL) AND ${recommended_number_of_shots} = 3 AND ${had_first_shot} AND ${data.next_appointment_date} >= DATEADD(month, 1, ${first_shot_date})
              THEN '2nd dose is recommended at scheduled appt on ' + ${data.next_appointment_date_formatted} + '. '
              WHEN (${TABLE}.had_second_shot = 'false' OR ${TABLE}.had_second_shot IS NULL) AND ${recommended_number_of_shots} = 3 AND ${had_first_shot} AND GETDATE() < DATEADD(month, 1, ${first_shot_date})
              THEN 'Recommendatation is to schedule an appt after ' + ${recommended__2nd_shot_date_start_formatted} + ' to administer 2nd dose. '
              WHEN (${TABLE}.had_second_shot = 'false' OR ${TABLE}.had_second_shot IS NULL) AND ${recommended_number_of_shots} = 3 AND ${had_first_shot} AND GETDATE() >= DATEADD(month, 1, ${first_shot_date})
              THEN 'Recommendatation is to schedule an appt to administer 2nd dose. '
              WHEN ${had_first_shot} AND ${TABLE}.had_second_shot = 'true' AND ${had_third_shot}
              THEN ''
              WHEN ${TABLE}.had_second_shot = 'true' AND ${recommended_number_of_shots} = 3 AND ${second_shot_date} >= ${recommended__2nd_shot_date_start}
              THEN '2nd dose administered on '+${second_shot_date_formatted}+'. '
              WHEN ${TABLE}.had_second_shot = 'true' AND ${recommended_number_of_shots} = 3 AND ${second_shot_date} < ${recommended__2nd_shot_date_start}
              THEN '2nd dose received TOO EARLY - must adminsister 3rd dose at least 12 weeks after 2nd dose. '
              WHEN ${TABLE}.had_second_shot = 'true' AND ${age_at_2nd_shot} < 9
              THEN 'Data shows patient has received at least 2 doses prior to 9th birthday. This could be true or there may be an issue with the data.  This should be investigated. '
              WHEN ${TABLE}.had_second_shot = 'true' AND ${age_at_2nd_shot} > 9 and ${recommended_number_of_shots} = 4
              THEN 'Patient received a dose prior to age 9 and has received a second dose at '+ CONVERT(varchar, ${age_at_2nd_shot})+' years old. This could be true or there may be an issue with the data.  The EMR data should be checked. '
               WHEN ${TABLE}.had_second_shot = 'true' AND ${age_at_2nd_shot} > 9 and ${recommended_number_of_shots} = 3
              THEN 'Patient received a dose prior to age 9 and has received a second dose at '+ CONVERT(varchar, ${age_at_2nd_shot})+' years old. This could be true or there may be an issue with the data.  The EMR data should be checked. '
              ELSE ''
         END ;;
    html: <div align="left"> {{rendered_value}} </div> ;;
  }

  dimension: 3rd_shot_status {
    type: string
    # Must hardcode table reference to had_third_shot to get accurate results when patientid NOT IN mhm.patienthpv
    sql: CASE WHEN (${TABLE}.had_third_shot = 'false' OR ${TABLE}.had_third_shot IS NULL) AND ${recommended_number_of_shots} = 3 AND ${had_second_shot}
                   AND ${data.next_appointment_date} < ${recommended__3rd_shot_date_start}
              THEN 'Scheduled appt on ' + ${data.next_appointment_date_formatted} +  ' is TOO EARLY FOR 3RD DOSE. '
              WHEN (${TABLE}.had_third_shot = 'false' OR ${TABLE}.had_third_shot IS NULL) AND ${recommended_number_of_shots} = 3 AND ${had_second_shot}
                   AND ${recommended__3rd_shot_date_start} <= ${data.next_appointment_date}
              THEN '3rd dose is recommended at scheduled appt on ' + ${data.next_appointment_date_formatted} + '. '
              WHEN (${TABLE}.had_third_shot = 'false' OR ${TABLE}.had_third_shot IS NULL) AND ${recommended_number_of_shots} = 3 AND ${had_second_shot}
                   AND GETDATE() < ${recommended__3rd_shot_date_start}
              THEN 'Recommendation is to schedule an appt after ' + ${recommended__3rd_shot_date_start_formatted} + ' to administer 3rd dose. '
              WHEN (${TABLE}.had_third_shot = 'false' OR ${TABLE}.had_third_shot IS NULL) AND ${recommended_number_of_shots} = 3 AND ${had_second_shot}
                   AND GETDATE() >= ${recommended__3rd_shot_date_start}
              THEN 'Recommendation is to schedule an appt to administer 3rd dose. '
              WHEN ${had_first_shot} AND ${had_second_shot} AND ${TABLE}.had_third_shot = 'true' AND ${had_fourth_shot}
              THEN ''
              WHEN ${TABLE}.had_third_shot = 'true' AND ${recommended_number_of_shots} = 3 AND ${third_shot_date} >= ${recommended__3rd_shot_date_start}
              THEN '3rd dose administered on '+${third_shot_date_formatted}+'. Vaccination complete. '
              WHEN ${TABLE}.had_third_shot = 'true' AND ${age_at_3rd_shot} < 9
              THEN 'Data shows patient has received at least 3 doses prior to 9th birthday. This could be true or there may be an issue with the data.  This should be investigated. '
              ELSE ''
         END ;;
    html: <div align="left"> {{rendered_value}} </div> ;;
  }

  dimension: 4th_shot_status {
    type: string
    # Must hardcode table reference to had_fourth_shot to get accurate results when patientid NOT IN mhm.patienthpv
    sql: CASE WHEN (${TABLE}.had_fourth_shot = 'false' OR ${TABLE}.had_fourth_shot IS NULL) AND ${recommended_number_of_shots} = 4 AND ${had_third_shot}
                   AND ${data.next_appointment_date} < ${recommended__4th_shot_date_start}
              THEN '3rd dose received TOO EARLY, it was administered on ' + ${third_shot_date_formatted} + ' and the recommended date was  ' +
                   ${recommended__3rd_shot_date_start_formatted} + '. Scheduled appt on ' + ${data.next_appointment_date_formatted} +
                   ' is TOO EARLY FOR REQUIRED 4TH DOSE. Recommendation is to schedule an appt after ' + ${recommended__4th_shot_date_start_formatted} + ' to administer required 4th dose. '
              WHEN (${TABLE}.had_fourth_shot = 'false' OR ${TABLE}.had_fourth_shot IS NULL) AND ${recommended_number_of_shots} = 4 AND ${had_third_shot}
                   AND ${recommended__4th_shot_date_start} <= ${data.next_appointment_date}
              THEN '3rd dose received TOO EARLY, it was administered on ' + ${third_shot_date_formatted} + ' and the recommended date was  ' +
                   ${recommended__3rd_shot_date_start_formatted} + '. 4th dose is recommended at scheduled appt on ' + ${data.next_appointment_date_formatted} + '. '
              WHEN (${TABLE}.had_fourth_shot = 'false' OR ${TABLE}.had_fourth_shot IS NULL) AND ${recommended_number_of_shots} = 4 AND ${had_third_shot}
                   AND GETDATE() >= ${recommended__4th_shot_date_start}
              THEN '3rd dose received TOO EARLY, it was administered on ' + ${third_shot_date_formatted} + ' and the recommended date was  ' +
                   ${recommended__3rd_shot_date_start_formatted} + '. Recommendation is to schedule an appt after ' +  ${recommended__4th_shot_date_start_formatted} + ' to administer required 4th dose. '
              WHEN ${TABLE}.had_fourth_shot = 'true' AND ${recommended_number_of_shots} = 4 AND ${fourth_shot_date} >= ${recommended__4th_shot_date_start}
              THEN '4th dose was required and was administered on '+${fourth_shot_date_formatted}+'. Vaccination complete. '
              ELSE ''
         END ;;
    html: <div align="left"> {{rendered_value}} </div> ;;
  }

  # dimension: age {
  #   hidden: yes
  #   type: number
  #   sql: ${TABLE}.age ;;
  # }

  dimension: age_at_1st_shot {
    label: "1st Shot Age"
    type: number
    sql: ${TABLE}.age_at_1st_shot ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: initiated_between_age_9_and_13 {
    group_label: "HPV age Ranges"
    type: yesno
    sql: ${age_at_1st_shot} >=9 and ${age_at_1st_shot} <=13;;
  }

  dimension: initiated_between_age_14_and_17 {
    group_label: "HPV age Ranges"
    type: yesno
    sql: ${age_at_1st_shot} >=14 and ${age_at_1st_shot} <=17;;
  }

  measure: count_initiated_between_age_9_and_13 {
    group_label: "HPV age Ranges"
    type:  count
    filters: {
      field: initiated_between_age_9_and_13
      value: "Yes"
    }
    drill_fields: [hvp_shot_age_distinct*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_initiated_between_age_14_and_17 {
    group_label: "HPV age Ranges"
    type:  count
    filters: {
      field: initiated_between_age_14_and_17
      value: "Yes"
    }
    drill_fields: [hvp_shot_age_distinct*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }



  dimension: age_at_2nd_shot {
    label: "2nd Shot Age"
    type: number
    sql: ${TABLE}.age_at_2nd_shot ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: 2nd_shot_between_age_9_and_13 {
    group_label: "HPV age Ranges"
    type: yesno
    sql: ${age_at_2nd_shot} >=9 and ${age_at_2nd_shot} <=13;;
  }

  dimension: 2nd_shot_between_age_14_and_17 {
    group_label: "HPV age Ranges"
    type: yesno
    sql: ${age_at_2nd_shot} >=14 and ${age_at_2nd_shot} <=17;;
  }

  measure: count_shot_2_between_age_9_and_13 {
    group_label: "HPV age Ranges"
    type:  count
    filters: {
      field: 2nd_shot_between_age_9_and_13
      value: "Yes"
    }
    drill_fields: [hvp_shot_age_distinct*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_shot_2_between_age_14_and_17 {
    group_label: "HPV age Ranges"
    type:  count
    filters: {
      field: 2nd_shot_between_age_14_and_17
      value: "Yes"
    }
    drill_fields: [hvp_shot_age_distinct*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: age_at_completion {
    label: "Completion Age"
    type: number
    sql: CASE
          WHEN (MONTH(${hpv_vaccination_complete_date}) *100) + DAY(${hpv_vaccination_complete_date}) >= (MONTH(${data.dob_date}) * 100) + DAY(${data.dob_date})
          THEN DATEDIFF(year, ${data.dob_date}, ${hpv_vaccination_complete_date})
          ELSE
          DATEDIFF(year, ${data.dob_date}, ${hpv_vaccination_complete_date}) - 1
          END;;
  }


  # WHEN (MONTH(hpv.date_first_shot) * 100) + DAY(hpv.date_first_shot) >= (MONTH(data.dob) * 100) + DAY(data.dob)
  #                         THEN DATEDIFF(year, data.dob, hpv.date_first_shot)
  #                         ELSE DATEDIFF(year, data.dob, hpv.date_first_shot) - 1

  dimension: completed_between_age_9_and_13 {
    group_label: "HPV age Ranges"
    type: yesno
    sql: ${age_at_2nd_shot} >=9 and ${age_at_2nd_shot} <=13;;
  }

  dimension: completed_between_age_14_and_17 {
    group_label: "HPV age Ranges"
    type: yesno
    sql: ${age_at_2nd_shot} >=14 and ${age_at_2nd_shot} <=17;;
  }

  measure: count_completed_between_age_9_and_13 {
    group_label: "HPV age Ranges"
    type:  count
    filters: {
      field: completed_between_age_9_and_13
      value: "Yes"
    }
    drill_fields: [hvp_shot_age_distinct*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_completed_between_age_14_and_17 {
    group_label: "HPV age Ranges"
    type:  count
    filters: {
      field: completed_between_age_14_and_17
      value: "Yes"
    }
    drill_fields: [hvp_shot_age_distinct*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: age_at_3rd_shot {
    label: "3rd Shot Age"
    type: number
    sql: ${TABLE}.age_at_3rd_shot ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }


  dimension: comment_first_shot {
    label: "1st Shot Comment"
    type: string
    sql: CASE WHEN ${TABLE}.Comment_First_shot IS NULL
              THEN ''
              ELSE ${TABLE}.Comment_First_shot
         END ;;
  }

  dimension: comment_second_shot {
    label: "2nd Shot Comment"
    type: string
    sql: CASE WHEN ${TABLE}.Comment_Second_Shot IS NULL
              THEN ''
              ELSE ${TABLE}.Comment_Second_Shot
         END ;;
  }

  dimension: completion_time_frame {
    type: yesno
    sql: {% condition timeframe_filter %} ${hpv_vaccination_complete_date} {% endcondition %} ;;
  }

  dimension: did_patient_complete_session_at_last_vist {
    type: yesno
    sql: CAST(IIF(${is_hpv_patient} AND DATEDIFF(day, ${hpv_vaccination_complete_date}, ${dos_detail.visit_raw}) <= 0, 1, 0) AS bit) = 'true' ;;
    html: <div align="left"> {{rendered_value}} </div> ;;
  }

  dimension: dose_1_last_refusal_compare{
    type: number
    sql: ${TABLE}.dose_1_last_refusal_compare ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: last_refusal_date{
    type: date
    sql: ${TABLE}last_refusal;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: eighth_shot_date {
    label: "8th Shot Date"
    type: date
    sql: ${TABLE}.Date_Eighth_shot ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: fifth_shot_date {
    label: "5th Shot Date"
    type: date
    sql: ${TABLE}.Date_Fifth_shot ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: fifth_shot_date_formatted {
    label: "5th Shot Date formatted"
    description: "EX: 03-03-2022"
    sql: CONVERT(varchar, ${TABLE}.Date_fifth_shot, 110);;
  }


  dimension: first_shot_date {
    # group_label: "First Shot Date"
    label: "1st Shot Date"
    type: date
    sql: ${TABLE}.Date_First_shot ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: first_shot_date_formatted {
    label: "1st Shot Date formatted"
    description: "EX: 03-03-2022"
    sql: CONVERT(varchar, ${TABLE}.Date_First_shot, 110);;
  }

  # Other timeframes defined separately to retain HTML formatting for date
  dimension_group: first_shot {
    group_label: "First Shot Date"
    type: time
    timeframes: [
      raw,
      week,
      month,
      quarter
    ]
    sql: ${TABLE}.Date_First_shot ;;
  }

  dimension: fourth_shot_date {
    label: "4th Shot Date"
    type: date
    sql: ${TABLE}.Date_Fourth_shot ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: fourth_shot_date_formatted {
    label: "4th Shot Date formatted"
    description: "EX: 03-03-2022"
    sql: CONVERT(varchar, ${TABLE}.Date_Fourth_shot, 110);;
  }

  dimension: had_eighth_shot {
    label: "8th Shot Given"
    type: yesno
    sql: ${TABLE}.had_eighth_shot = 'true' ;;
  }

  dimension: had_first_shot {
    label: "1st Shot Given"
    type: yesno
    sql: ${TABLE}.had_first_shot = 'true' ;;
  }

  dimension: had_fifth_shot {
    label: "5th Shot Given"
    type: yesno
    sql: ${TABLE}.had_fifth_shot = 'true' ;;
  }

  dimension: had_fourth_shot {
    label: "4th Shot Given"
    type: yesno
    sql: ${TABLE}.had_fourth_shot = 'true' ;;
  }

  dimension: had_second_shot {
    label: "2nd Shot Given"
    type: yesno
    sql: ${TABLE}.had_second_shot = 'true' ;;
  }

  dimension: had_seventh_shot {
    label: "7th Shot Given"
    type: yesno
    sql: ${TABLE}.had_seventh_shot = 'true' ;;
  }

  dimension: had_sixth_shot {
    label: "6th Shot Given"
    type: yesno
    sql: ${TABLE}.had_sixth_shot = 'true' ;;
  }

  dimension: had_third_shot {
    label: "3rd Shot Given"
    type: yesno
    sql: ${TABLE}.had_third_shot = 'true';;
  }

  dimension: hpv_status {
    label: "HPV Status"
    type: string
    sql: CASE WHEN ${recommended_number_of_shots} = 0
              THEN ${initial_status} + ' ' + ${patient_hpv_refusal.refusal_shot_status}
              WHEN ${recommended_number_of_shots} = 99
              THEN ${initial_status}
              WHEN ${recommended_number_of_shots} >=3 and ${age_at_1st_shot}>=27
              THEN ${initial_status} + ' ' + ${1st_shot_status} + ${2nd_shot_status} + ${3rd_shot_status} + ${4th_shot_status} + ' '
              ELSE ${1st_shot_status} + ${2nd_shot_status} + ${3rd_shot_status} + ${4th_shot_status} + ' ' + ${patient_hpv_refusal.refusal_shot_status}
        END ;;
    link: {
      label: "CDC HVP Info"
      url: "https://www.cdc.gov/hpv/hcp/schedules-recommendations.html"
    }
  }

  dimension: hpv_history {
    label: "HPV History"
    type: string
    sql: CASE

                        WHEN ${TABLE}.had_fifth_shot = 'true' THEN
                            '1st dose - '+${first_shot_date_formatted}+', 2nd dose - '+${second_shot_date_formatted}+', 3rd dose - '+${third_shot_date_formatted}+', 4th dose - '+${fourth_shot_date_formatted}+', and  5th dose - '+${fifth_shot_date_formatted}
                        WHEN ${TABLE}.had_fourth_shot = 'true' THEN
                            '1st dose - '+${first_shot_date_formatted}+', 2nd dose - '+${second_shot_date_formatted}+', 3rd dose - '+${third_shot_date_formatted}+', and  4th dose - '+${fourth_shot_date_formatted}
                        WHEN ${TABLE}.had_third_shot = 'true' THEN
                            '1st dose - '+${first_shot_date_formatted}+', 2nd dose - '+${second_shot_date_formatted}+', and 3rd dose - '+${third_shot_date_formatted}
                        WHEN ${TABLE}.had_second_shot = 'true'  THEN
                            '1st dose - '+${first_shot_date_formatted}+', and 2nd dose - '+${second_shot_date_formatted}
                        WHEN ${TABLE}.had_first_shot = 'true' THEN
                            '1st dose - '+${first_shot_date_formatted}
                            ELSE ''
                        END;;
  }

  dimension: hpv_vaccination_complete {
    label: "HPV Vaccination Complete"
    type: yesno
    sql: CAST(CASE WHEN ${recommended_number_of_shots} = 4 AND ${had_fourth_shot} AND (${fourth_shot_date} >= ${recommended__4th_shot_date_start})
                   THEN 1
                   WHEN ${recommended_number_of_shots} = 3 AND ${had_third_shot} AND  (${third_shot_date} >= ${recommended__3rd_shot_date_start})
                   THEN 1
                   WHEN ${recommended_number_of_shots} = 2 AND ${had_second_shot} AND  (${second_shot_date} >= ${recommended__2nd_shot_date_start})
                   THEN 1
                   WHEN ${recommended_number_of_shots} = 4 AND ${had_fourth_shot}
                   THEN 1
                   WHEN ${recommended_number_of_shots} = 3 AND ${had_first_shot} AND ${had_second_shot} AND ${had_third_shot}
                   THEN 1
                   ELSE 0
              END AS bit) = 'true' ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension_group: hpv_vaccination_complete {
    label: "HPV Vaccination Complete"
    group_label: "HPV Vaccination Complete"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.hpv_vaccination_complete_date ;;
    # html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  # Defined separately to retain HTML formatting for date - RRH Note: modified to date_of_service because time visuals
  #were incorrect due to formatting. Moved 'date' to visit dimension group
  dimension: completion_date {
    description: "Formatted Completion Date (mm/dd/yyyy)"
    group_label: "HPV Vaccination Complete"
    type: date
    sql: ${hpv_vaccination_complete_date} ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: initial_status {
    type: string
    # Must hardcode table reference to had_first_shot to get accurate results when patientid NOT IN mhm.patienthpv
    sql: CASE WHEN ${age_at_1st_shot}>=27 AND ${recommended_number_of_shots} >= 3
              THEN 'Patient received the first dose at age '+ CONVERT(varchar, ${age_at_1st_shot})+ ' and is older than HPV guidelines and dose may not be covered by insurance. '
              WHEN ${recommended_number_of_shots} = 99
              THEN 'Patient has received a dose or doses under the age of 9 or there are other potential database or EMR issues that need to be investigated. '

      ELSE ''
      END ;;
    html: <div align="left"> {{rendered_value}} </div> ;;
  }

  dimension: is_hpv_eligible_age {
    label: "Is HPV Eligible Age"
    type: yesno
    sql: CAST(IIF((${data.age} >= 9 AND ${data.age} <= 26), 1, 0) AS bit) = 'true';;
    html: <div align="left"> {{rendered_value}} </div> ;;
  }

  dimension: recommended_1st_shot_date{
    label: "recommended 1st shot date"
    type: date
    sql: DATEADD(year,9,${data.dob_date});;
    # html: <div align="left"> {{rendered_value}} </div> ;;
  }

  dimension: is_hpv_patient {
    label: "Is HPV Patient"
    type: yesno
    sql: CAST(IIF((${data.age} >= 9 and ${data.age} <= 26 ) OR ${TABLE}.had_first_shot = 'true', 1, 0) AS bit) = 'true' ;;
    html: <div align="left"> {{rendered_value}} </div> ;;
  }

  dimension: is_hpv_patient_at_visit_timeframe {
    label: "Is HPV Patient At Visit Timeframe"
    type: yesno
    sql: CAST(CASE WHEN (${dos_detail.age_at_visit} >= 9 and ${dos_detail.age_at_visit} <= 26)  OR ${had_first_shot}
              THEN 1
              ELSE 0
         END AS bit) = 'true' ;;
    html: <div align="left"> {{rendered_value}} </div> ;;
  }

  dimension: is_patient_eligible_for_next_hpv_dose {
    label: "Is Patient Eligible for Next HPV Dose"
    type: yesno
    sql: CAST(CASE WHEN ${is_hpv_patient} AND ${first_shot_date} IS NULL
                   THEN 1
                   WHEN ${is_hpv_patient} AND ${first_shot_date} IS NOT NULL AND ${second_shot_date} IS NULL
                        AND DATEDIFF(day, ${recommended__2nd_shot_date_start}, ${dos_detail.visit_date}) >= 0
                   THEN 1
                   WHEN ${is_hpv_patient} AND ${first_shot_date} IS NOT NULL AND ${second_shot_date} IS NOT NULL
                        AND ${third_shot_date} IS NULL AND DATEDIFF(day, ${recommended__3rd_shot_date_start}, ${dos_detail.visit_date}) >= 0
                   THEN 1
                   WHEN ${is_hpv_patient} AND ${first_shot_date} IS NOT NULL AND ${second_shot_date} IS NOT NULL
                        AND ${third_shot_date} IS NOT NULL AND ${fourth_shot_date} IS NULL
                        AND DATEDIFF(day, ${recommended__4th_shot_date_start}, ${dos_detail.visit_date}) >= 0
                   THEN 1
                   ELSE 0
              END AS bit) = 'true' ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: was_patient_eligible_for_next_hpv_dose_at_visit {
    label: "Was Patient Eligible for Next HPV Dose at current visit"
    type: yesno
    sql: CAST(CASE
                  WHEN ${dos_detail.visit_date} = ${hpv_vaccination_complete_date} THEN 1
                  WHEN ${dos_detail.visit_date} > ${hpv_vaccination_complete_date} THEN 0
                  WHEN ${is_hpv_patient} AND ${first_shot_date} IS NULL
                   THEN 1
                   WHEN ${is_hpv_patient} AND  (DATEDIFF(day, ${dos_detail.visit_date}, ${first_shot_date})>=0 OR DATEDIFF(day, ${dos_detail.visit_date}, ${recommended_1st_shot_date}) >= 0)
                   THEN 1
                   WHEN ${is_hpv_patient} AND  (DATEDIFF(day, ${dos_detail.visit_date}, ${second_shot_date})>=0 OR DATEDIFF(day, ${dos_detail.visit_date}, ${recommended__2nd_shot_date_start}) <= 0)
                   THEN 1
                   WHEN ${is_hpv_patient} AND  (DATEDIFF(day, ${dos_detail.visit_date}, ${third_shot_date})>=0 OR DATEDIFF(day, ${dos_detail.visit_date}, ${recommended__3rd_shot_date_start}) <= 0)
                   THEN 1
                   WHEN ${is_hpv_patient} AND  (DATEDIFF(day, ${dos_detail.visit_date}, ${fourth_shot_date})>=0 OR DATEDIFF(day, ${dos_detail.visit_date}, ${recommended__4th_shot_date_start}) <= 0)
                   THEN 1
                   ELSE 0
              END AS bit) = 'true' ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: last_dose {
    type: date
    sql: ${TABLE}.last_dose_date ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: last_dose_in_timeframe {
    type: yesno
    sql: {% condition timeframe_filter %} ${last_dose} {% endcondition %};;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: last_dose_is_null {
    type: yesno
    sql: ${last_dose} IS NULL ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: missing_first_shot {
    type: yesno
    sql: CAST(IIF(${first_shot_date} IS NULL, 1, 0) AS bit) = 'true' ;;
  }

  dimension: practice_id {
    hidden: yes
    type: number
    value_format_name: id
    sql: ${TABLE}.PracticeID ;;
  }

  dimension: reason_first_shot {
    type: string
    sql: CASE WHEN ${TABLE}.Reason_First_shot IS NULL
              THEN ''
              ELSE ${TABLE}.Reason_First_shot
         END ;;
  }

  dimension: reason_second_shot {
    type: string
    sql: CASE WHEN ${TABLE}.Reason_Second_shot IS NULL
              THEN ''
              ELSE ${TABLE}.Reason_Second_shot
              END ;;
  }

  dimension: recommended__2nd_shot_date_start {
    type: date
    sql: ${TABLE}.recommended_2nd_shot_date_start ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: recommended__2nd_shot_date_start_formatted {
    description: "EX: 03-03-2022"
    sql: CONVERT(varchar, ${TABLE}.recommended_2nd_shot_date_start, 110);;
  }

  dimension: recommended__3rd_shot_date_start {
    type: date
    sql: ${TABLE}.recommended_3rd_shot_date_start ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: recommended__3rd_shot_date_start_formatted {
    description: "EX: 03-03-2022"
    sql: CONVERT(varchar, ${TABLE}.recommended_3rd_shot_date_start, 110);;
  }

  dimension: recommended__4th_shot_date_start {
    type: date
    sql: ${TABLE}.recommended_4th_shot_date_start ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: recommended__4th_shot_date_start_formatted {
    description: "EX: 03-03-2022"
    sql: CONVERT(varchar, ${TABLE}.recommended_4th_shot_date_start, 110);;
  }

  dimension: recommended_number_of_shots {
    type: number
    sql: ${TABLE}.recommended_number_of_shots ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: second_shot_date {
    label: "2nd Shot Date"
    type: date
    sql: ${TABLE}.Date_Second_shot ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: second_shot_date_formatted {
    label: "2nd Shot Date formatted"
    description: "EX: 03-03-2022"
    sql: CONVERT(varchar, ${TABLE}.Date_Second_shot, 110);;
  }

  dimension: sixth_shot_date {
    label: "6th Shot Date"
    type: date
    sql: ${TABLE}.Date_Sixth_shot ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: seventh_shot_date {
    label: "7th Shot Date"
    type: date
    sql: ${TABLE}.Date_Seventh_shot ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: status_first_shot {
    type: string
    sql: CASE WHEN ${TABLE}.Status_First_Shot IS NULL
              THEN ''
              ELSE ${TABLE}.Status_First_Shot
         END ;;
  }

  dimension: status_second_shot {
    type: string
    sql: CASE WHEN ${TABLE}.Status_Second_shot IS NULL
              THEN ''
              ELSE ${TABLE}.Status_Second_shot
         END ;;
  }

  dimension: status_third_shot {
    type: string
    sql: CASE WHEN ${TABLE}.Status_Third_shot IS NULL
              THEN ''
              ELSE ${TABLE}.Status_Third_shot
              END ;;
  }

  dimension: third_shot_date {
    label: "3rd Shot Date"
    type: date
    sql: ${TABLE}.Date_Third_shot ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: third_shot_date_formatted {
    label: "3rd Shot Date formatted"
    description: "EX: 03-03-2022"
    sql: CONVERT(varchar, ${TABLE}.Date_Third_shot, 110);;
  }

  dimension: was_completed_vaccination_in_time_frame {
    type: yesno
    sql: {% condition timeframe_filter %} ${hpv_vaccination_complete_date} {% endcondition %} ;;
  }

  dimension: was_dose1_in_time_frame {
    type: yesno
    sql: {% condition timeframe_filter %} ${first_shot_date} {% endcondition %} ;;
  }

  dimension: was_dose2_in_time_frame {
    type: yesno
    sql: {% condition timeframe_filter %} ${second_shot_date} {% endcondition %} ;;
  }

  dimension: was_dose3_in_time_frame {
    type: yesno
    sql: {% condition timeframe_filter %} ${third_shot_date} {% endcondition %} ;;
  }

  dimension: was_dose4_in_time_frame {
    type: yesno
    sql: {% condition timeframe_filter %} ${fourth_shot_date} {% endcondition %} ;;
  }

  # Keep this one, remove was_patient_eligible_for_1st_HPV_dose_at_last_vist
  dimension: was_patient_eligible_for_1st_HPV_dose_at_last_visit {
    type: yesno
    sql: ${is_hpv_patient} AND (DATEDIFF(day, ${first_shot_date}, ${dos_detail.visit_date}) <= 0 OR ${first_shot_date} IS NULL) ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: was_refusal_after_dose_1 {
    type: yesno
    sql: CAST(CASE WHEN dose_1_last_refusal_compare > 0
                   THEN 1
                   ELSE 0
              END AS bit)  = 'true' ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count {
    type: count
    html: <div align="center"> {{rendered_value}} </div> ;;
    drill_fields: [hpvdetail*]
  }

  # measure: count_patients_eligible_for_hpv_dose {
  #   label: "Count Patients Eligible for HPV Dose"
  #   type: count
  #   filters: [was_patient_eligible_for_next_hpv_dose_at_visit: "Yes"]
  #   sql: ${dos_detail.visit_id} ;;
  #   html: <div align="center"> {{rendered_value}} </div> ;;
  #   # drill_fields: [hpvdetail_distinct_count*]
  # }

  measure: count_patients_eligible_for_hpv_dose_at_visit {
    label: "Count Patients Eligible for HPV Dose at visit"
    type:  count
    filters: {
      field: was_patient_eligible_for_next_hpv_dose_at_visit
      value: "Yes"
    }
    drill_fields: [hpvdetail*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_completed_hpv_vaccinations {
    label: "Count Completed HPV Vaccinations"
    type:  count
    filters: {
      field: hpv_vaccination_complete
      value: "Yes"
    }
    drill_fields: [hpvdetail_distinct*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_completed_hpv_vaccinations_timeline {
    label: "Count Completed HPV Vaccinations Timeline"
    type:  count
    filters: {
      field: did_patient_complete_session_at_last_vist
      value: "Yes"
    }
    drill_fields: [hpvdetail_distinct*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_current_female_patients_seen_in_last_3_yrs_with_no_shots {
    label: "Count Current Female Patients Seen in the Last 2 years with no shots"
    group_label: "no doses - in last 2 years"
    description: "Patients seen in last 2 years with no HPV Shots"
    type: count
    # filters: {
    #   field: data.is_current_patient_2_years
    #   value: "Yes"
    # }
    filters: {
      field: missing_first_shot
      value: "Yes"
    }
    filters: {
      field: is_hpv_patient
      value: "Yes"
    }
    filters: {
      field: data.sex
      value: "F"
    }
    drill_fields: [hpvdetail*]
  }

  measure: count_current_male_patients_seen_in_last_3_yrs_with_no_shots {
    label: "Count Current Male Patients Seen in the Last 2 years with no shots"
    group_label: "no doses - in last 2 years"
    description: "Patients seen in last 2 years with no HPV Shots"
    type: count
    # filters: {
    #   field: derived_patient_data.is_current_patient_2_years
    #   value: "Yes"
    # }
    filters: {
      field: had_first_shot
      value: "No"
    }
    # filters: {
    #   field: is_hpv_patient
    #   value: "Yes"
    # }
    filters: {
      field: data.sex
      value: "M"
    }
    drill_fields: [hpvdetail*]
  }

  measure: count_current_patients_complete {
    description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
    type: count
    filters: {
      field: data.is_current_patient_2_years
      value: "Yes"
    }
    filters: {
      field: is_hpv_patient
      value: "Yes"
    }
    filters: {
      field: hpv_vaccination_complete
      value: "Yes"
    }
    drill_fields: [hpvdetail*]
  }

  measure: count_current_patients_complete_female {
    description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
    type: count
    filters: {
      field: data.is_current_patient_2_years
      value: "Yes"
    }
    filters: {
      field: is_hpv_patient
      value: "Yes"
    }
    filters: {
      field: data.sex
      value: "F"
    }
    filters: {
      field: hpv_vaccination_complete
      value: "Yes"
    }
    drill_fields: [hpvdetail*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_current_patients_complete_male {
    description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
    type: count
    filters: {
      field: data.is_current_patient_2_years
      value: "Yes"
    }
    filters: {
      field: is_hpv_patient
      value: "Yes"
    }
    filters: {
      field: data.sex
      value: "M"
    }
    filters: {
      field: hpv_vaccination_complete
      value: "Yes"
    }
    drill_fields: [hpvdetail*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_current_patients_female {
    description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
    type: count
    filters: {
      field: data.is_current_patient_2_years
      value: "Yes"
    }
    filters: {
      field: is_hpv_patient
      value: "Yes"
    }
    filters: {
      field: data.sex
      value: "F"
    }
    drill_fields: [hpvdetail*]
  }

  measure: count_current_patients_male {
    description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
    type: count
    filters: {
      field: data.is_current_patient_2_years
      value: "Yes"
    }
    filters: {
      field: is_hpv_patient
      value: "Yes"
    }
    filters: {
      field: data.sex
      value: "M"
    }
    drill_fields: [hpvdetail*]
  }

  measure: count_current_patients_initiated_female {
    description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
    type: count
    filters: {
      field: data.is_current_patient_2_years
      value: "Yes"
    }
    filters: {
      field: is_hpv_patient
      value: "Yes"
    }
    filters: {
      field: data.sex
      value: "F"
    }
    filters: {
      field: missing_first_shot
      value: "No"
    }
    drill_fields: [hpvdetail*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_current_patients_initiated_male {
    description: "Patient has been seen within the last 2 years, has 1 shot, and is not deceased - includes older patients"
    type: count
    filters: {
      field: data.is_current_patient_2_years
      value: "Yes"
    }
    filters: {
      field: is_hpv_patient
      value: "Yes"
    }
    filters: {
      field: data.sex
      value: "M"
    }
    filters: {
      field: missing_first_shot
      value: "No"
    }
    drill_fields: [hpvdetail*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_current_patients_not_complete_female {
    description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
    type: count
    filters: {
      field: data.is_current_patient_2_years
      value: "Yes"
    }
    filters: {
      field: is_hpv_patient
      value: "Yes"
    }
    filters: {
      field: data.sex
      value: "F"
    }
    filters: {
      field: missing_first_shot
      value: "No"
    }
    filters: {
      field: hpv_vaccination_complete
      value: "No"
    }
    drill_fields: [hpvdetail*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_current_patients_not_complete_male {
    description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
    type: count
    filters: {
      field: data.is_current_patient_2_years
      value: "Yes"
    }
    filters: {
      field: is_hpv_patient
      value: "Yes"
    }
    filters: {
      field: data.sex
      value: "M"
    }
    filters: {
      field: missing_first_shot
      value: "No"
    }
    filters: {
      field: hpv_vaccination_complete
      value: "No"
    }
    drill_fields: [hpvdetail*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_current_patients_not_initiated_female {
    description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
    type: count
    filters: {
      field: data.is_current_patient_2_years
      value: "Yes"
    }
    filters: {
      field: is_hpv_patient
      value: "Yes"
    }
    filters: {
      field: data.sex
      value: "F"
    }
    filters: {
      field: missing_first_shot
      value: "Yes"
    }
    drill_fields: [hpvdetail*]
  }

  measure: count_current_patients_not_initiated_male {
    description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
    type: count
    filters: {
      field: data.is_current_patient_2_years
      value: "Yes"
    }
    filters: {
      field: is_hpv_patient
      value: "Yes"
    }
    filters: {
      field: data.sex
      value: "M"
    }
    filters: {
      field: missing_first_shot
      value: "Yes"
    }
    drill_fields: [hpvdetail*]
  }

  measure: count_eligible_and_received_1st_dose_timeframe {
    type:  count
    filters: {
      field: was_patient_eligible_for_1st_HPV_dose_at_last_visit
      value: "Yes"
    }
    filters: {
      field: is_hpv_patient
      value: "Yes"
    }
    drill_fields: [hpvdetail*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_eligible_for_dose_1 {
    type:  count_distinct
    sql: ${dos_detail.patientid} ;;
    filters: {
      field: was_patient_eligible_for_1st_HPV_dose_at_last_visit
      value: "Yes"
    }
    drill_fields: [hpvdetail*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_eligible_no_dose_1 {
    type:  count_distinct
    sql: ${dos_detail.patientid} ;;
    filters: {
      field: was_patient_eligible_for_1st_HPV_dose_at_last_visit
      value: "Yes"
    }
    filters: {
      field: was_refusal_after_dose_1
      value: "No"
    }
    filters: {
      field: patient_hpv_refusal.did_patient_refuse_HPV_at_last_vist
      value: "No"
    }
    drill_fields: [hpvdetail*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_hpv_patients {
    label: "Count HPV Patients Not Complete"
    description: "Patient has been seen within the last 2 years and is not deceased"
    type: count
    filters: {
      field: is_hpv_patient
      value: "Yes"
    }
    filters: {
      field: data.is_current_patient_2_years
      value: "Yes"
    }
    filters: {
      field: hpv_vaccination_complete
      value: "No"
    }
    drill_fields: [hpvdetail*]
  }

  # measure: count_hpv_patients_with_unknown_pcp {
  #   label: "Count HPV Patients with Unknown PCP"
  #   description: "Patient has been seen within the last 2 years and is not deceased and has no named PCP"
  #   type: count
  #   filters: {
  #     field: is_hpv_patient
  #     value: "Yes"
  #   }
  #   filters: {
  #     field: data.is_current_patient_2_years
  #     value: "Yes"
  #   }
  #   filters: {
  #     field: hpv_vaccination_complete
  #     value: "No"
  #   }
  #   filters: {
  #     field: pcp.is_pcp_known
  #     value: "No"
  #   }
  #   drill_fields: [hpvdetail*]
  # }

  measure: count_of_completions_in_timeframe {
    type: count
    filters: {
      field: was_completed_vaccination_in_time_frame
      value: "Yes"
    }
    html: <div align="center"> {{rendered_value}} </div> ;;
    drill_fields: [hpvdetail_distinct*, last_dose]
  }

  measure: count_of_yes_dose1_in_timeframe {
    type: count
    filters: {
      field: was_dose1_in_time_frame
      value: "Yes"
    }
    drill_fields: [hpvdetail_distinct*, last_dose]
  }

  measure: count_of_yes_dose2_in_timeframe {
    type: count
    filters: {
      field: was_dose2_in_time_frame
      value: "Yes"
    }
    drill_fields: [hpvdetail_distinct*, last_dose]
  }

  measure: count_of_yes_dose3_in_timeframe {
    type: count
    filters: {
      field: was_dose3_in_time_frame
      value: "Yes"
    }
    drill_fields: [hpvdetail_distinct*, last_dose]
  }

  measure: count_of_yes_dose4_in_timeframe {
    type: count
    filters: {
      field: was_dose4_in_time_frame
      value: "Yes"
    }
    drill_fields: [hpvdetail_distinct*, last_dose]
  }

  measure: count_initiated {
    description: "patients initated and have been seen in last 2 years"
    type:  count
    filters: {
      field: missing_first_shot
      value: "No"
    }
    drill_fields: [hpvdetail_distinct*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  measure: count_patients_current_patients_with_no_shots {
    description: "Current Patients in correct age with no HPV Shots"
    type: count
    filters: {
      field: data.is_current_patient_2_years
      value: "Yes"
    }
    filters: {
      field: missing_first_shot
      value: "Yes"
    }
    filters: {
      field: is_hpv_eligible_age
      value: "Yes"
    }
    drill_fields: [hpvdetail_no_shots*]
    link: {
      label: "See up to 5,000 Results"
      url: "{{ link }}&limit=5000"
    }
    link: {
      label: "Patient Details"
      url: "/looks/1157?toggle=det,pik"
    }
  }

  measure: count_patients_initiated_not_complete {
    description: "Current Patients in initiated, but not complete"
    type: count
    filters: {
      field: data.is_current_patient_2_years
      value: "Yes"
    }
    filters: {
      field: missing_first_shot
      value: "No"
    }
    filters: {
      field: hpv_vaccination_complete
      value: "No"
    }
    drill_fields: [hpvdetail_distinct_age_shot_1*]
  }

  measure: total_shots {
    type: sum
    sql: CASE WHEN ${had_eighth_shot} THEN 8
              WHEN ${had_seventh_shot} THEN 7
              WHEN ${had_sixth_shot} THEN 6
              WHEN ${had_fifth_shot} THEN 5
              WHEN ${had_fourth_shot} THEN 4
              WHEN ${had_third_shot} THEN 3
              WHEN ${had_second_shot} THEN 2
              WHEN ${had_first_shot} THEN 1
              ELSE 0
         END ;;
    drill_fields: [hpvdetail*]
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  set: hpvdetail {
    fields: [data.patient_id, data.patient_mrn,
      data.patient_name,
      data.sex,
      data.age,
      data.dob_date,
      was_patient_eligible_for_next_hpv_dose_at_visit,
      last_visit_info.last_visit_date,
      last_visit_info.last_provider,
      future_appointments.next_appt,
      pcp.pcp_name,
      first_shot_date_formatted,
      second_shot_date_formatted,
      third_shot_date_formatted,
      patient_hpv_refusal.last_refusal,
      hpv_status,
      hpv_vaccination_complete_date,
      hpv_vaccination_complete,
      total_shots]
  }

  set: hpvdetail_no_shots {
    fields: [data.patient_id, data.patient_mrn,
      data.patient_name,
      data.sex,
      data.age,
      data.dob_date,
      last_visit_info.last_visit_date,
      last_visit_info.last_provider,
      last_visit_info.last_location,
      first_shot_date_formatted,
      patient_hpv_refusal.last_refusal,
      hpv_status,
      hpv_vaccination_complete]
  }

  set: hpvdetail_distinct {
    fields: [data.patient_id, data.patient_mrn,
      data.patient_name,
      data.sex,
      dos_detail.age_at_visit,
      data.dob_date,
      dos_detail.date_of_service,
      pcp.pcp_name,
      provider.provider_name,
      location.location,
      dos_detail.payer_id,
      payers.payer_name,
      first_shot_date_formatted,
      second_shot_date_formatted,
      third_shot_date_formatted,
      patient_hpv_refusal.last_refusal,
      hpv_status,
      hpv_vaccination_complete_date,
      hpv_vaccination_complete,
      total_shots]
  }

  set: hvp_shot_age_distinct {
    fields: [data.patient_id, data.patient_mrn,
      data.patient_name,
      data.sex,
      data.dob_date,
      pcp.pcp_name,
      first_shot_date_formatted,
      age_at_1st_shot,
      second_shot_date_formatted,
      age_at_2nd_shot,
      third_shot_date_formatted,
      hpv_vaccination_complete_date,
      age_at_completion,
      hpv_status,

      hpv_vaccination_complete,
      total_shots]
  }

  set: hpvdetail_distinct_age_shot_1 {
    fields: [data.patient_id, data.patient_mrn,
      data.patient_name,
      data.sex,
      data.dob_date,
      pcp.pcp_name,
      age_at_1st_shot,
      first_shot_date_formatted,
      second_shot_date_formatted,
      third_shot_date_formatted,
      patient_hpv_refusal.last_refusal,
      hpv_status,
      hpv_vaccination_complete_date,
      hpv_vaccination_complete,
      total_shots]
  }
}
