# The name of this view in Looker is "Dos Detail"
view: dos_detail {
   derived_table: {
    sql:
      SELECT CASE WHEN (dost.age_at_visit >= 9 AND dost.age_at_visit <= 26)
                       AND (hpv.date_first_shot IS NULL OR dost.visitdate <= hpv.date_first_shot)
                  THEN 1
                  ELSE 0
             END AS eligible_for_hpv_dose1_on_visit_date,
             -- is someone hpv patient on visits after their completion date? as of rn, yes.
             CASE WHEN dost.age_at_visit >= 9 AND dost.age_at_visit <= 26
                  THEN 1
                  WHEN dost.visitdate >= hpv.date_first_shot
                  THEN 1
                  ELSE 0
             END AS is_hpv_patient,
             dost.*
      FROM (
        SELECT dos.dos_detail_id,
               dos.patientid,
               dos.practice_id,
               CASE WHEN dos.locationid IS NULL
                    THEN 315
                    ELSE dos.locationid
               END AS locationid,
               CASE WHEN dos.providerid IS NULL
                    THEN 1072
                    ELSE dos.providerid
               END AS providerid,
               dos.finid,
               dos.payerid,
               dos.Visit_status,
               dos.visitid,
               dos.visitdate,
               CASE WHEN (MONTH(dos.visitdate) * 100 + DAY(dos.visitdate)) >= (MONTH(d.dob) * 100 + DAY(d.dob))
                    THEN DATEDIFF(year, d.dob, dos.visitdate)
                    ELSE DATEDIFF(year, d.dob, dos.visitdate) - 1
               END AS age_at_visit,
               dos.value,
               dos.value_txt,
               CASE WHEN dos.visitdate = hpv.date_first_shot
                    THEN 1
                    ELSE 0
               END AS did_patient_have_hpv_dose1_during_visit,
               CASE WHEN dos.visitdate = hpv.date_second_shot
                    THEN 1
                    ELSE 0
               END AS did_patient_have_hpv_dose2_during_visit,
               CASE WHEN dos.visitdate = hpv.date_third_shot
                    THEN 1
                    ELSE 0
               END AS did_patient_have_hpv_dose3_during_visit,
               CASE WHEN dos.visitdate = hpv.date_fourth_shot
                    THEN 1
                    ELSE 0
               END AS did_patient_have_hpv_dose4_during_visit,
               CASE WHEN hpv.had_first_shot = 'true' AND dos.visitdate >= hpv.recommended_2nd_shot_date_start
                         AND (hpv.date_second_shot IS NULL OR dos.visitdate <= hpv.date_second_shot)
                    THEN 1
                    -- What does this cover?
                    WHEN dos.visitdate = hpv.date_second_shot AND hpv.recommended_2nd_shot_date_start IS NOT NULL
                    THEN 1
                    ELSE 0
               END AS eligible_for_hpv_dose2_on_visit_date,
               CASE WHEN hpv.had_second_shot = 'true' AND dos.visitdate >= hpv.recommended_3rd_shot_date_start
                         AND (hpv.date_third_shot IS NULL OR dos.visitdate <= hpv.date_third_shot)
                         -- can a patient only complete on the third/fourth dose?
                         AND (dos.visitdate <= hpv.hpv_vaccination_complete_date OR hpv.hpv_vaccination_complete_date IS NULL)
                    THEN 1
                    -- Again, what does this logic cover?
                    WHEN dos.visitdate = hpv.date_second_shot AND hpv.recommended_3rd_shot_date_start IS NOT NULL
                    THEN 1
                    ELSE 0
               END AS eligible_for_hpv_dose3_on_visit_date,
               CASE WHEN hpv.had_third_shot = 'true' AND dos.visitdate >= hpv.recommended_4th_shot_date_start
                         AND (hpv.date_fourth_shot IS NULL OR dos.visitdate <= hpv.date_fourth_shot)
                         AND (dos.visitdate <= hpv.hpv_vaccination_complete_date OR hpv.hpv_vaccination_complete_date IS NULL)
                    THEN 1
                    WHEN dos.visitdate = hpv.date_third_shot AND hpv.recommended_4th_shot_date_start IS NOT NULL
                    THEN 1
                    ELSE 0
               END AS eligible_for_hpv_dose4_on_visit_date,
               CASE WHEN dos.visitdate = ref.date_first_shot_refusal
                         OR dos.visitdate = ref.date_second_shot_refusal
                         OR dos.visitdate = ref.date_third_shot_refusal
                         OR dos.visitdate = ref.date_fourth_shot_refusal
                    THEN 1
                    ELSE 0
               END AS did_patient_refuse_an_hpv_dose_during_visit,
               CASE WHEN dos.visitdate = ref.date_first_shot_refusal
                    THEN 1
                    ELSE 0
               END AS did_patient_refuse_first_hpv_dose_during_visit,
               CASE WHEN dos.type IN ('HPV', 'HPV Single', 'HPV Series')
                    THEN 1
                    WHEN dos.visitdate = hpv.date_first_shot
                         OR dos.visitdate = hpv.date_second_shot
                         OR dos.visitdate = hpv.date_third_shot
                         OR dos.visitdate = hpv.date_fourth_shot
                         OR dos.visitdate = hpv.date_fifth_shot
                         OR dos.visitdate = hpv.date_sixth_shot
                    THEN 1
                    ELSE 0
               END AS hpv_dose_given_during_visit,
               CASE WHEN dos.visitdate = hpv.hpv_vaccination_complete_date
                    THEN 1
                    ELSE 0
               END AS was_hpv_completed_at_visit,
               CASE WHEN dos.visitdate >= hpv.hpv_vaccination_complete_date
                    THEN 1
                    ELSE 0
               END AS was_hpv_completed_at_or_before_visit,
               CASE WHEN dos.visitdate >= hpv.date_first_shot
                    THEN 1
                    ELSE 0
               END AS did_patient_initiate_at_or_before_visit
        FROM mhm.dos_detail dos
        LEFT JOIN mhm.data d
          ON dos.patientid = d.patientid
        LEFT JOIN ${patient_hpv_final.SQL_TABLE_NAME} hpv
          ON dos.patientid = hpv.patientid
        LEFT JOIN ${patient_hpv_refusal.SQL_TABLE_NAME} ref
          ON dos.patientid = ref.patientid
      ) dost
      LEFT JOIN ${patient_hpv_final.SQL_TABLE_NAME} hpv
        ON dost.patientid = hpv.patientid ;;
  }

  dimension: id {
    label: "Date of Service ID"
    type: number
    primary_key: yes
    hidden: no
    #sql: CONCAT (${patientid} , ${visit_date}, ${provider_id}, ${location_id} , ${finid}, ${type}, ${value}, ${Value_txt})
    sql:  ${TABLE}.DOS_Detail_ID
      ;;
  }

  dimension: visitid {
    type: string
    sql: ${TABLE}.VisitID ;;
    value_format_name: id
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;

  }

  filter: visit_or_dose_in_timeframe_filter {
    description: "filter to show hpv shots and refusals in a given timeframe"
    type: date
  }

  filter: test_in_timeframe_filter {
    description: "filter to show tests provided in a given timeframe"
    type: date
  }

  filter: hpv_dose_in_timeframe_filter {
    description: "filter to show hpv shots and refusals in a given timeframe"
    type: date
  }

  filter: hpv_eligible_in_timeframe_filter {
    description: "filter to show patients eligible for an hpv shotin a given timeframe"
    type: date
  }

  dimension:  is_hpv_dose_or_refusal_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all hpv shots and refusals in a given timeframe"
    type: yesno
    sql: {% condition hpv_dose_in_timeframe_filter %} ${visit_date} {% endcondition %} and (${type} = 'HPV' or ${type}= 'HPV Single' or ${type}='HPV Series' ) ;;
  }

  dimension:  is_phq_in_time_frame {
    description: "shows all phqs given timeframe"
    type: yesno
#     sql: {% condition test_in_timeframe_filter %} ${visit_date} {% endcondition %} and (${test_type} = 'PHQ9' or ${test_type}= 'PHQ2' ) ;;
    sql: {% condition test_in_timeframe_filter %} ${visit_date} {% endcondition %} ;;
  }

  dimension:  is_encounter_in_time_frame {
    description: "shows all encounters given timeframe"
    type: yesno
#     sql: {% condition test_in_timeframe_filter %} ${visit_date} {% endcondition %} and (${test_type} = 'PHQ9' or ${test_type}= 'PHQ2' ) ;;
    sql: {% condition test_in_timeframe_filter %} ${patient_problem_list.encounter_date} {% endcondition %} ;;
  }

  dimension:  did_patient_have_an_hpv_dose_during_visit {
    group_label: "HPV Dimensions"
    description: "shows if patient had an HPV dose during a visit"
    type: string
    sql: CASE
          WHEN ${visit_date}=${patient_hpv.date_first_shot_date} THEN 'Yes'
          WHEN ${visit_date}=${patient_hpv.date_second_shot_date} THEN 'Yes'
          WHEN ${visit_date}=${patient_hpv.date_third_shot_date} THEN 'Yes'
          WHEN ${visit_date}=${patient_hpv.date_fourth_shot_date} THEN 'Yes'
          WHEN ${visit_date}=${patient_hpv.date_fifth_shot_date} THEN 'Yes'
          ELSE
          'No'
          END
          ;;
  }

  #RRH added date back into this dimension group
  dimension_group: visit {
    group_label: "Visit Date"
    type: time
    timeframes: [
      raw,
      date,
      time,
      month,
      month_name,
      month_num,
      quarter,
      quarter_of_year,
      year
    ]
    sql: ${TABLE}.visitdate ;;
  }

  # Defined separately to retain HTML formatting for date - RRH Note: modified to date_of_service because time visuals
  #were incorrect due to formatting. Moved 'date' to visit dimension group
  dimension: original_date_of_service {
    description: "Formatted Visit Date (mm/dd/yyyy)"
    group_label: "Visit Date"
    type: date
    sql: ${visit_date} ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: date_of_service {
    description: "Formatted Visit Date (mm/dd/yyyy)"
    group_label: "Visit Date test"
    type: date
    sql: ${visit_date};;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  measure: count_patients_with_HPV_Dose_During_Visit{
    description: "counts distinct patients"
    group_label: "HPV Measures"
    type: count_distinct
    sql:  ${patientid} ;;
    filters: {
      field: did_patient_have_an_hpv_dose_during_visit
      value: "yes"
    }
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

  dimension: eligible_for_hpv_dose_on_visit_date {
    label: "Eligible for HPV Dose on Visit Date"
    group_label: "HPV Dimensions"
    type: yesno
    sql: ${eligible_for_hpv_dose1_on_visit_date} OR ${eligible_for_hpv_dose2_on_visit_date} OR
      ${eligible_for_hpv_dose3_on_visit_date} OR ${eligible_for_hpv_dose4_on_visit_date} ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: eligible_for_hpv_dose1_on_visit_date {
    label: "Eligible for HPV Dose 1 on Visit Date"
    group_label: "HPV Dimensions"
    description: "shows patients eligible for Dose 1 of hpv shots"
    type: yesno
    sql: ${TABLE}.eligible_for_hpv_dose1_on_visit_date = 1 ;;
  }

  dimension: eligible_for_hpv_dose2_on_visit_date {
    label: "Eligible for HPV Dose 2 on Visit Date"
    group_label: "HPV Dimensions"
    description: "shows patients eligible for Dose 2 of hpv shots"
    type: yesno
    sql: ${TABLE}.eligible_for_hpv_dose2_on_visit_date = 1 ;;
  }

  dimension: eligible_for_hpv_dose3_on_visit_date {
    label: "Eligible for HPV Dose 3 on Visit Date"
    group_label: "HPV Dimensions"
    description: "shows patients eligible for Dose 3 of hpv shots in a given timeframe"
    type: yesno
    sql: ${TABLE}.eligible_for_hpv_dose3_on_visit_date = 1 ;;
  }

  dimension: eligible_for_hpv_dose4_on_visit_date {
    label: "Eligible for HPV Dose 4 on Visit Date"
    group_label: "HPV Dimensions"
    description: "shows patients eligible for Dose 4 of hpv shots in a given timeframe"
    type: yesno
    sql: ${TABLE}.eligible_for_hpv_dose3_on_visit_date = 1 ;;
  }

  measure: count_patients_eligible_for_hpv_dose_at_visit {
    label: "Count Patients Eligible for HPV Dose at Visit"
    group_label: "HPV Measures"
    type: count_distinct
    filters: [patient_hpv_final.was_patient_eligible_for_next_hpv_dose_at_visit: "Yes"]
    sql: ${visitid} ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
    drill_fields: [hpvdetail*]
  }

  measure: count_patients_eligible_for_hpv_dose1 {
    label: "Count Patients Eligible for HPV Dose 1"
    group_label: "HPV Measures"
    type: count_distinct
    filters: [eligible_for_hpv_dose1_on_visit_date: "Yes"]
    sql: ${patientid} ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
    drill_fields: [patient_hpv_final.hpvdetail_distinct*]
  }

  measure: count_patients_eligible_for_hpv_dose2 {
    label: "Count Patients Eligible for HPV Dose 2"
    group_label: "HPV Measures"
    type: count_distinct
    filters: [eligible_for_hpv_dose2_on_visit_date: "Yes"]
    sql: ${patientid} ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
    drill_fields: [patient_hpv_final.hpvdetail_distinct*]
  }

  measure: count_patients_eligible_for_hpv_dose3 {
    label: "Count Patients Eligible for HPV Dose 3"
    group_label: "HPV Measures"
    type: count_distinct
    filters: [eligible_for_hpv_dose3_on_visit_date: "Yes"]
    sql: ${patientid} ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
    drill_fields: [patient_hpv_final.hpvdetail_distinct*]
  }

  measure: count_patients_eligible_for_hpv_dose4 {
    label: "Count Patients Eligible for HPV Dose 4"
    group_label: "HPV Measures"
    type: count_distinct
    filters: [eligible_for_hpv_dose4_on_visit_date: "Yes"]
    sql: ${patientid} ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
    drill_fields: [patient_hpv_final.hpvdetail_distinct*]
  }

  measure: count_all_patients_with_HPV_Dose_During_Visit{
    description: "counts all patients - if it's a big timeframe, a patient can get more than 1 dose and be counted"
    group_label: "HPV Measures"
    type: count
#     sql:  ${patientid} ;;
    filters: {
      field: did_patient_have_an_hpv_dose_during_visit
      value: "yes"
    }
    filters: {
      field: is_hpv_dose_in_time_frame
      value: "yes"
    }
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

  dimension:  did_patient_have_hpv_dose1_during_visit {
    group_label: "HPV Dimensions"
    description: "shows if patient had an their first HPV dose during a visit"
    type: yesno
    sql:  ${visit_date}=${patient_hpv.date_first_shot_date}
      ;;
  }

  measure: count_patients_with_HPV_Dose1_During_Visit{
    group_label: "HPV Measures"
    type: count_distinct
    sql:  ${patientid} ;;
    filters: {
      field: did_patient_have_hpv_dose1_during_visit
      value: "yes"
    }
    html:
          <div align="center"> {{rendered_value}} </div>
          ;;
  }

  dimension:  did_patient_refuse_hpv_dose1_during_visit {
    group_label: "HPV Dimensions"
    description: "shows if patient had an HPV dose during a visit"
    type: string
    sql: CASE
          WHEN ${visit_date}=${patient_hpv_refusal.date_first_refusal_date} and (${visit_date}< ${patient_hpv.date_first_shot_date} or ${patient_hpv.date_first_shot_date} is NULL) THEN 'Yes'
          WHEN ${visit_date}=${patient_hpv_refusal.date_second_refusal_date} and (${visit_date}< ${patient_hpv.date_first_shot_date} or ${patient_hpv.date_first_shot_date} is NULL) THEN 'Yes'
          WHEN ${visit_date}=${patient_hpv_refusal.date_third_refusal_date} and (${visit_date}< ${patient_hpv.date_first_shot_date} or ${patient_hpv.date_first_shot_date} is NULL) THEN 'Yes'
          WHEN ${visit_date}=${patient_hpv_refusal.date_fourth_refusal_date} and (${visit_date}< ${patient_hpv.date_first_shot_date} or ${patient_hpv.date_first_shot_date} is NULL) THEN 'Yes'
          ELSE
          'No'
          END
          ;;
  }

  measure: count_patients_with_HPV_Dose1_Refusal_During_Visit{
    group_label: "HPV Measures"
    type: count_distinct
    sql:  ${patientid} ;;
    filters: {
      field: did_patient_refuse_hpv_dose1_during_visit
      value: "yes"
    }
    html:
          <div align="center"> {{rendered_value}} </div>
          ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }


  dimension:  did_patient_refuse_an_hpv_dose_during_visit {
    group_label: "HPV Dimensions"
    description: "shows if patient had an HPV dose during a visit"
    type: string
    sql: CASE
          WHEN ${visit_date}=${patient_hpv_refusal.date_first_refusal_date} THEN 'Yes'
          WHEN ${visit_date}=${patient_hpv_refusal.date_second_refusal_date} THEN 'Yes'
          WHEN ${visit_date}=${patient_hpv_refusal.date_third_refusal_date} THEN 'Yes'
          WHEN ${visit_date}=${patient_hpv_refusal.date_fourth_refusal_date} THEN 'Yes'
          ELSE
          'No'
          END
          ;;
  }

  measure: count_patients_with_HPV_Refusal_During_Visit{
    group_label: "HPV Measures"
    type: count_distinct
    sql:  ${patientid} ;;
    filters: {
      field: did_patient_refuse_an_hpv_dose_during_visit
      value: "yes"
    }
    html:
            <div align="center"> {{rendered_value}} </div>
            ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

  dimension:  did_patient_present_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all patients who present in a given timeframe"
    type: yesno
    sql: {% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %} ;;
  }

  measure: hpv_timeframe_last_visit_date {
    group_label: "HPV Measures"
    sql: max(${visit_raw})  ;;

  }

  measure: hpv_timeframe_first_visit_date {
    group_label: "HPV Measures"
    sql: min(${visit_raw})  ;;

  }

  dimension: patient_initiated_in_or_before_timeframe{
    group_label: "HPV Dimensions"
    description: "shows all patients who have had a least 1 hpv shots during or before timeframe"
    type: yesno
    sql:  {% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %} and ${patient_hpv.date_first_shot_date} IS NOT NULL
      ;;
    html:
              <div align="center"> {{rendered_value}} </div>
              ;;
  }

  measure: count_patients_initiated_in_or_before_timeframe {
    group_label: "HPV Measures"
    type: count_distinct
    sql:  ${patientid} ;;
    filters: {
      field: patient_initiated_in_or_before_timeframe
      value: "yes"
    }
    html:
              <div align="center"> {{rendered_value}} </div>
              ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }



  dimension:  is_hpv_dose_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all hpv shots and refusals in a given timeframe"
    type: yesno
    sql: {% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %} and (${type} = 'HPV' or ${type}= 'HPV Single' or ${type}='HPV Series' ) and
                 ({% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_first_shot_date} {% endcondition %} or
                  {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_second_shot_date} {% endcondition %} or
                  {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_third_shot_date} {% endcondition %} or
                  {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_fourth_shot_date} {% endcondition %} or
                  {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_fifth_shot_date} {% endcondition %} or
                  {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_sixth_shot_date} {% endcondition %} )
                  ;;
  }

  measure: count_doses_for_hpv_in_timeframe {
    group_label: "HPV Measures"
    type: count_distinct
    sql:  ${patientid} ;;
    filters: {
      field: is_hpv_dose_in_time_frame
      value: "yes"
    }
    html:
                <div align="center"> {{rendered_value}} </div>
                ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }


  dimension:  was_dose1_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all Dose 1 of hpv shots in a given timeframe"
    type: yesno
    sql: {% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %} and (${type} = 'HPV' or ${type}= 'HPV Single' or ${type}='HPV Series' ) and
      {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_first_shot_date} {% endcondition %} ;;
  }

  measure: count_was_dose1_in_time_frame {
    type: count_distinct
    sql:  ${patientid} ;;
    group_label: "HPV Measures"
    filters: {
      field: was_dose1_in_time_frame
      value: "yes"
    }
    filters: {
      field: did_patient_present_in_time_frame
      value: "yes"
    }
    html:
                  <div align="center"> {{rendered_value}} </div>
                  ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

  dimension:  was_dose2_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all Dose 2 of hpv shots in a given timeframe"
    type: yesno
    sql:  {% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %} and (${type} = 'HPV' or ${type}= 'HPV Single' or ${type}='HPV Series' ) and
      {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_second_shot_date} {% endcondition %} ;;
  }

#   sql: {% condition hpv_dose_in_timeframe_filter %} ${visit_date} {% endcondition %} and (${type} = 'HPV' or ${type}= 'HPV Single' or ${type}='HPV Series' ) and


  measure: count_was_dose2in_time_frame {
    type: count_distinct
    sql:  ${patientid} ;;
    group_label: "HPV Measures"
    filters: {
      field: was_dose2_in_time_frame
      value: "yes"
    }
    html:
            <div align="center"> {{rendered_value}} </div>
            ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

  dimension:  was_dose3_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all Dose 1 of hpv shots in a given timeframe"
    type: yesno
    sql: {% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %} and (${type} = 'HPV' or ${type}= 'HPV Single' or ${type}='HPV Series' ) and
      {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_third_shot_date} {% endcondition %} ;;
  }

  measure: count_was_dose3_in_time_frame {
    type: count_distinct
    sql:  ${patientid} ;;
    group_label: "HPV Measures"
    filters: {
      field: was_dose3_in_time_frame
      value: "yes"
    }
    filters: {
      field: did_patient_present_in_time_frame
      value: "yes"
    }
    html:
              <div align="center"> {{rendered_value}} </div>
              ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

  dimension:  was_dose4_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all Dose 1 of hpv shots in a given timeframe"
    type: yesno
    sql: {% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %} and (${type} = 'HPV' or ${type}= 'HPV Single' or ${type}='HPV Series' ) and
      {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_fourth_shot_date} {% endcondition %} ;;
  }

  measure: count_was_dose4_in_time_frame {
    type: count_distinct
    sql:  ${patientid} ;;
    group_label: "HPV Measures"
    filters: {
      field: was_dose4_in_time_frame
      value: "yes"
    }
    filters: {
      field: did_patient_present_in_time_frame
      value: "yes"
    }
    html:
                <div align="center"> {{rendered_value}} </div>
                ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

  dimension:  was_other_dose_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all Dose 1 of hpv shots in a given timeframe"
    type: yesno
    sql: {% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %} and (${type} = 'HPV' or ${type}= 'HPV Single' or ${type}='HPV Series' ) and
                     ( {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_second_shot_date} {% endcondition %} or
                       {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_third_shot_date} {% endcondition %} or
                       {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_fourth_shot_date} {% endcondition %} or
                       {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_fifth_shot_date} {% endcondition %} or
                       {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_sixth_shot_date} {% endcondition %} )
                    ;;
  }


  dimension:  eligible_for_dose1_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows patients eligible for Dose 1 of hpv shots in a given timeframe"
    type: yesno
    sql:   ({% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %}) and (${age_at_visit} >= 9 and ${age_at_visit} <= 26 ) and ${patient_hpv.had_first_shot}=0
                    or
                    ({% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_first_shot_date} {% endcondition %})

      ;;
  }

  measure: count_eligible_for_dose1_in_time_frame {
    type: count_distinct
    sql:  ${patientid} ;;
    group_label: "HPV Measures"
    filters: {
      field: eligible_for_dose1_in_time_frame
      value: "yes"
    }
    filters: {
      field: did_patient_present_in_time_frame
      value: "yes"
    }
    html:
        <div align="center"> {{rendered_value}} </div>
        ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

  dimension:  eligible_for_dose2_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows patients eligible for Dose 2 of hpv shots in a given timeframe"
    type: yesno
    sql: (
                      ({% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %}) and

      (${patient_hpv.had_first_shot}=1 and ${patient_hpv.had_second_shot}=0) and (${visit_date} >=  ${patient_hpv.recommended__2nd_shot_date_start})
      )
      or
      (
      ({% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_second_shot_date} {% endcondition %}) and
      ${patient_hpv.recommended__2nd_shot_date_start} IS NOT NULL
      )
      ;;
  }

  measure: count_eligible_for_dose2_in_time_frame {
    type: count_distinct
    sql:  ${patientid} ;;
    group_label: "HPV Measures"
    filters: {
      field: eligible_for_dose2_in_time_frame
      value: "yes"
    }
    filters: {
      field: did_patient_present_in_time_frame
      value: "yes"
    }
    html:
          <div align="center"> {{rendered_value}} </div>
          ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }



  dimension:  eligible_for_dose3_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows patients eligible for Dose 3 of hpv shots in a given timeframe"
    type: yesno
    sql: (
                        ({% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %}) and
                        (${patient_hpv.had_second_shot}=1 and ${patient_hpv.had_third_shot}=0) and
                        (${visit_date} >=  ${patient_hpv.recommended__3rd_shot_date_start}) and
                        (${visit_date} <=  ${patient_hpv.patient_completion_date} or ${patient_hpv.patient_completion_date} IS NULL)
                   )
                  or
                        (
                        ({% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_third_shot_date} {% endcondition %}) and
                        ${patient_hpv.recommended__3rd_shot_date_start} IS NOT NULL
                        )
                    ;;
  }

  measure: count_eligible_for_dose3_in_time_frame {
    type: count_distinct
    sql:  ${patientid} ;;
    group_label: "HPV Measures"
    filters: {
      field: eligible_for_dose3_in_time_frame
      value: "yes"
    }
    filters: {
      field: did_patient_present_in_time_frame
      value: "yes"
    }
    html:
            <div align="center"> {{rendered_value}} </div>
            ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]

  }

  dimension:  eligible_for_dose4_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows patients eligible for Dose 4 of hpv shots in a given timeframe"
    type: yesno
    sql: (
                          ({% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %}) and
                          (${patient_hpv.had_third_shot}=1 and ${patient_hpv.had_fourth_shot}=0) and
                          (${visit_date} >=  ${patient_hpv.recommended__4th_shot_date_start}) and
                          (${visit_date} <=  ${patient_hpv.patient_completion_date} or ${patient_hpv.patient_completion_date} IS NULL)
                     )
                    or
                        (
                          ({% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_fourth_shot_date} {% endcondition %})and
                          ${patient_hpv.recommended__4th_shot_date_start} IS NOT NULL
                        )
                      ;;
  }

  measure: count_eligible_for_dose4_in_time_frame {
    type: count_distinct
    sql:  ${patientid} ;;
    group_label: "HPV Measures"
    filters: {
      field: eligible_for_dose4_in_time_frame
      value: "yes"
    }
    filters: {
      field: did_patient_present_in_time_frame
      value: "yes"
    }
    html:
                    <div align="center"> {{rendered_value}} </div>
                    ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }


  dimension:  eligible_for_a_dose_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows patients eligible for Dose 4 of hpv shots in a given timeframe"
    type: yesno
    sql: (
            (
              (
                  ({% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %}) and
                        (
                          (${age_at_visit} >= 9 and ${age_at_visit} <= 26 )
                        )
                    and ${patient_hpv.had_first_shot}=0  or ${visit_date} <=  ${patient_hpv.date_first_shot_date}

      )  or
      ({% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_first_shot_date} {% endcondition %})
      )

      or

      (
      ({% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %})

      and

      (
      (
      ${patient_hpv.had_first_shot}=1 and ${patient_hpv.had_second_shot}=0 and
      (${visit_date} >=  ${patient_hpv.recommended__2nd_shot_date_start})
      or
      (
      ({% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_second_shot_date} {% endcondition %}) and
      ${patient_hpv.recommended__2nd_shot_date_start} IS NOT NULL
      )
      )
      or
      (
      ${patient_hpv.had_second_shot}=1 and ${patient_hpv.had_third_shot}=0 and
      (${visit_date} >=  ${patient_hpv.recommended__3rd_shot_date_start})
      or
      ({% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_third_shot_date} {% endcondition %}) and
      ${patient_hpv.recommended__3rd_shot_date_start} IS NOT NULL
      )
      or
      (
      ${patient_hpv.had_third_shot}=1 and ${patient_hpv.had_fourth_shot}=0 and
      (${visit_date} >=  ${patient_hpv.recommended__4th_shot_date_start})
      or
      ({% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_fourth_shot_date} {% endcondition %}) and
      ${patient_hpv.recommended__4th_shot_date_start} IS NOT NULL
      )
      )


      )


      )

      ;;
  }




  measure: count_eligible_for_a_dose_in_time_frame {
    type: count_distinct
    sql:  ${patientid} ;;
    group_label: "HPV Measures"
    filters: {
      field: eligible_for_a_dose_in_time_frame
      value: "yes"
    }
    filters: {
      field: did_patient_present_in_time_frame
      value: "yes"
    }
    html:
              <div align="center"> {{rendered_value}} </div>
              ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

  dimension:  is_patient_an_hpv_patient_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all patients who are complete, initiated, or not t started for an hpv shot in a given timeframe"
    type: string
    sql: CASE
                  WHEN ({% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %}) and
                     (${age_at_visit} >= 9 and ${age_at_visit} <= 26) THEN 'Yes'

      WHEN ({% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %}) and
      (${patient_hpv.had_first_shot}=1) THEN 'Yes'
      ELSE
      'No'
      END
      ;;
  }

  measure: count_all_eligible_for_a_dose_in_time_frame {
    description: "Counts all times any patient is eligible in any timeframe"
    type: count
    group_label: "HPV Measures"
    filters: {
      field: eligible_for_a_dose_in_time_frame
      value: "yes"
    }
    filters: {
      field: did_patient_present_in_time_frame
      value: "yes"
    }
    html:
      <div align="center"> {{rendered_value}} </div>
      ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }


  measure: count_hpv_patient_in_time_frame {
    type: count_distinct
    sql:  ${patientid} ;;
    group_label: "HPV Measures"
    filters: {
      field: is_patient_an_hpv_patient_in_time_frame
      value: "yes"
    }
    filters: {
      field: did_patient_present_in_time_frame
      value: "yes"
    }
    html:
                <div align="center"> {{rendered_value}} </div>
                ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }


  dimension:  is_patient_an_eligible_hpv_patient_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all patients who are complete, initiated, or not t started for an hpv shot in a given timeframe"
    type: string
    sql: CASE
                WHEN ${visit_date} >  ${patient_hpv.patient_completion_date} THEN 'No'
                WHEN (${visit_date} >=  ${patient_hpv.recommended__4th_shot_date_start}) and (${patient_hpv.date_fourth_shot_date} >=${visit_date}or ${patient_hpv.date_fourth_shot_date} is NULL) THEN 'Yes'
                WHEN (${visit_date} >=  ${patient_hpv.recommended__3rd_shot_date_start}) and (${patient_hpv.date_third_shot_date} >=${visit_date} or ${patient_hpv.date_third_shot_date} is NULL) THEN 'Yes'
                WHEN (${visit_date} >=  ${patient_hpv.recommended__2nd_shot_date_start}) and (${patient_hpv.date_second_shot_date} >=${visit_date} or ${patient_hpv.date_second_shot_date} is NULL) THEN 'Yes'
                WHEN ${visit_date} = ${patient_hpv.date_first_shot_date} THEN 'Yes'
                WHEN (${age_at_visit} >= 9 and ${age_at_visit} <= 26)
                and ${visit_date} <= ${patient_hpv.date_first_shot_date} THEN 'Yes'
                WHEN (${age_at_visit} >= 9 and ${age_at_visit} <= 26)
                and ${patient_hpv.date_first_shot_date} is NULL THEN 'Yes'
                ELSE
                'No'
                END
                      ;;
  }



  measure: count_patient_an_eligible_HPV_patient_in_time_frame {
    type: count_distinct
    sql:  ${patientid} ;;
    group_label: "HPV Measures"
    filters: {
      field: is_patient_an_eligible_hpv_patient_in_time_frame
      value: "yes"
    }
    html:
              <div align="center"> {{rendered_value}} </div>
              ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

  dimension:  is_patient_eligible_for_hpv_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all patients eligible for an hpv shot in a given timeframe"
    type: string
    sql: CASE
                  WHEN (({% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %}) and (${age_at_visit} >= 9 and ${age_at_visit} <= 26)
                    and ${patient_hpv.had_first_shot}=0 )  or
                      ({% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_first_shot_date} {% endcondition %}) THEN 'Yes'
                  WHEN (({% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %}) and
                    (${patient_hpv.had_first_shot}=1 and ${patient_hpv.had_second_shot}=0) and (${visit_date} >=  ${patient_hpv.recommended__2nd_shot_date_start}))
                    or ({% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_second_shot_date} {% endcondition %}) THEN 'Yes'
                  WHEN  ( ({% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %}) and
                      (${patient_hpv.had_second_shot}=1 and ${patient_hpv.had_third_shot}=0) and
                      (${visit_date} >=  ${patient_hpv.recommended__3rd_shot_date_start}) and
                      (${visit_date} <=  ${patient_hpv.patient_completion_date} or ${patient_hpv.patient_completion_date} IS NULL)) or
                      ({% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_third_shot_date} {% endcondition %}) THEN 'Yes'
                  WHEN  ( ({% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %}) and
                      (${patient_hpv.had_third_shot}=1 and ${patient_hpv.had_fourth_shot}=0) and
                      (${visit_date} >=  ${patient_hpv.recommended__4th_shot_date_start}) and
                      (${visit_date} <=  ${patient_hpv.patient_completion_date} or ${patient_hpv.patient_completion_date} IS NULL)) or
                      ({% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.date_fourth_shot_date} {% endcondition %}) THEN 'Yes'
                  ELSE
                  'No'
                  END


      ;;
  }

  measure: count_eligible_for_hpv_in_timeframe {
    group_label: "HPV Measures"
    type: count_distinct
    sql:  ${patientid} ;;
    filters: {
      field: is_patient_eligible_for_hpv_in_time_frame
      value: "yes"
    }
    filters: {
      field: did_patient_present_in_time_frame
      value: "yes"
    }
    html:
          <div align="center"> {{rendered_value}} </div>
          ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }


  dimension:  is_patient_seen_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all patients eligible for an hpv shot in a given timeframe"
    type: yesno
    sql: {% condition hpv_eligible_in_timeframe_filter %} ${dos_detail.visit_date} {% endcondition %} ;;
  }

  dimension:  is_patient_completed_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all patients who completed the HPV regimen in a given timeframe"
    type: yesno
    sql: {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv.HPV_vaccination_complete_date_date} {% endcondition %} ;;
  }

  measure: count_is_patient_completed_in_time_frame {
    group_label: "HPV Measures"
    type: count_distinct
    sql:  ${patientid} ;;
    filters: {
      field: is_patient_completed_in_time_frame
      value: "yes"
    }
#     filters: {
#       field: did_patient_present_in_time_frame
#       value: "yes"
#     }
    html:
            <div align="center"> {{rendered_value}} </div>
            ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

  dimension:  is_patient_completed_during_or_before_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all patients who completed the HPV regimen in before or during a given timeframe"
    type: yesno
    sql: {% condition hpv_eligible_in_timeframe_filter %} ${visit_date} {% endcondition %} and ${patient_hpv.HPV_vaccination_complete_date_date} IS NOT NULL ;;
    html:
              <div align="center"> {{rendered_value}} </div>
              ;;
  }


  measure: count_patients_completed_in_or_before_timeframe {
    group_label: "HPV Measures"
    type: count_distinct
    sql:  ${patientid} ;;
    filters: {
      field: is_patient_completed_during_or_before_time_frame
      value: "yes"
    }
    html:
              <div align="center"> {{rendered_value}} </div>
              ;;

    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }


  dimension:  did_patient_refuse_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all patients who refused an HPV dose in a given timeframe"
    type: yesno
    sql: {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv_refusal.date_first_refusal_date} {% endcondition %} or
                       {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv_refusal.date_second_refusal_date} {% endcondition %} or
                       {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv_refusal.date_third_refusal_date} {% endcondition %} or
                       {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv_refusal.date_fourth_refusal_date} {% endcondition %}
                  ;;
  }

  dimension:  did_patient_refuse_dose_1_in_time_frame {
    group_label: "HPV Dimensions"
    description: "shows all patients who refused an the first HPV dose in a given timeframe"
    type: yesno
    sql: ({% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv_refusal.date_first_refusal_date} {% endcondition %} or
                       {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv_refusal.date_second_refusal_date} {% endcondition %} or
                       {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv_refusal.date_third_refusal_date} {% endcondition %} or
                       {% condition hpv_eligible_in_timeframe_filter %} ${patient_hpv_refusal.date_fourth_refusal_date} {% endcondition %}) and
                       (${patient_hpv.had_first_shot}= 0 )
                  ;;
  }


  dimension: patientid {
    primary_key: no
    type: number
    sql: ${TABLE}.PatientID ;;
    value_format_name: id
  }

  dimension_group: create {
    type: time
    # hidden:  yes
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year,
      week_of_year
    ]
    sql: ${TABLE}.Create_Date ;;
  }

  dimension:  HPV_visit_in_time_frame {
    type: yesno
    sql: {% condition patient_hpv.timeframe_filter %} ${visit_date} {% endcondition %}   ;;
  }

  measure: count_of_hpv_visits_in_timeframe {
    type: count
    filters: {
      field: HPV_visit_in_time_frame
      value: "yes"
    }
    filters: {
      field: does_type_include_hpv
      value: "yes"
    }
    drill_fields: [patient_hpv.hpvdetail_distinct*]

    link: {
      label: "All Patients Details"
      url: "/looks/824?toggle=det"
    }


  }

  measure: count_of_non_HPV_visits_in_timeframe {
    type: count
    filters: {
      field: HPV_visit_in_time_frame
      value: "yes"
    }
    filters: {
      field: does_type_include_hpv
      value: "no"
    }
    filters: {
      field: patient_hpv.is_hpv_patient
      value: "yes"
    }
    drill_fields: [patient_hpv.hpvdetail_distinct*]

    link: {
      label: "All Patients Details"
      url: "/looks/824?toggle=det"
    }


  }


  measure: create_date_updated {
    type: date
    sql: MAX(${create_raw}) ;;
    convert_tz: no
    html:
          <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
          ;;
  }

  measure: first_visit_date {
    type: date
    sql:  MIN(${create_raw});;
    convert_tz: no
    html:
          <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
          ;;
  }

  measure: first_visit_quarter {
    type: date_quarter
    sql:  MIN(${create_raw});;
    convert_tz: no
    html:
          <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
          ;;
  }

  measure: first_visit_year {
    type: date_year
    sql:  MIN(${create_raw});;
    convert_tz: no
    html:
          <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
          ;;
  }

  measure: last_visit_date {
    type: date
    sql: MAX(${create_raw}) ;;
    convert_tz: no
    html:
          <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
          ;;
  }

  dimension: finid {
    type: number
    value_format_name: id
    sql: ${TABLE}.FINID ;;
  }

  dimension: payerid {
    type: number
    value_format_name: id
    sql: ${TABLE}.payerid ;;
  }

  dimension: is_visit_this_year{
    group_label: "Visit Timeframe"
    type: yesno
    sql: ${visit_year} = YEAR(GETDATE()) ;;
    html:
        <div align="center"> {{rendered_value}} </div>
        ;;

  }

  dimension: is_visit_in_2019{
    group_label: "Visit Timeframe"
    type: yesno
    sql: ${visit_year} = '2019' ;;
    html:
          <div align="center"> {{rendered_value}} </div>
          ;;

  }

  dimension: is_visit_in_2020{
    group_label: "Visit Timeframe"
    type: yesno
    sql: ${visit_year} = '2020' ;;
    html:
          <div align="center"> {{rendered_value}} </div>
          ;;

  }



#   dimension: location_id {
#     type: number
#     sql: ${TABLE}.LocationID ;;
#   }

  dimension: location_id {
    type: number
    sql:  CASE
                    WHEN ${TABLE}.LocationID IS NULL THEN 315
                    ELSE ${TABLE}.LocationID

      END
      ;;
    value_format_name: id

  }


  dimension: practice_id {
    type: number
    sql: ${TABLE}.Practiceid ;;
    value_format_name: id
  }

#   dimension: provider_id {
#     type: number
#     sql: ${TABLE}.ProviderID ;;
#   }

  dimension: provider_id {
    type: number
    sql:  CASE
                    WHEN ${TABLE}.ProviderID IS NULL THEN 1072
                    ELSE ${TABLE}.ProviderID

      END
      ;;
    value_format_name: id

  }


  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
    suggestions: ["BMI", "Cervical Cytology", "Colon Tests", "Colonoscopy", "HbA1c", "HPV Tests", "Influenza", "Mammogram", "MCV", "PNEUMO", "TDAP"]
    drill_fields: [visit_date, practice_id, data.patient_name, type]

  }

  dimension: does_type_include_hpv {
    type: yesno
    sql: ${type} like '%hpv%' ;;

    html:
    <div align="center"> {{rendered_value}} </div>
    ;;

    drill_fields: [visit_date, practice_id, data.patient_name, type]

  }

  dimension: test_type {
    type: string
    sql: CASE
              WHEN ${TABLE}.type = 'PHQ2_Score' THEN 'PHQ2'
              WHEN ${TABLE}.type = 'PHQ9_Score' THEN 'PHQ9'
              WHEN ${TABLE}.type = 'Follow_up_plan' THEN 'Follow-up Plan'
              ELSE
              ${TABLE}.type
              END
              ;;

    drill_fields: [visit_date, practice_id, data.patient_name, type]

  }


  dimension: is_type_phq {
    type: yesno
    sql: ${TABLE}.type = 'PHQ9_Score' or ${TABLE}.type = 'PHQ2_Score' ;;

    drill_fields: [visit_date, practice_id, data.patient_name, type]

  }

  dimension: was_PHQ_performed_at_encounter{
    type: yesno
    sql: (${TABLE}.type = 'PHQ9_Score' or ${TABLE}.type = 'PHQ2_Score') and ${visitid} = ${patient_problem_list.visitid} ;;

    drill_fields: [visit_date, practice_id, data.patient_name, type]

  }

  measure: count_patients_with_PHQ_test{
    type: count_distinct
    sql: ${patientid} ;;
    filters: {
      field:  was_PHQ_performed_at_encounter
      value: "yes"
    }
    drill_fields: [patientid, data.patient_name, data.patient_mrn, chronic.has_depression, patient_problem_list.encounter_date, patient_problem_list.visitid, type, value, location.location ]
  }

  measure: count_patients_with_NO_PHQ_test{
    type: count_distinct
    sql: ${patientid} ;;
    filters: {
      field:  was_PHQ_performed_at_encounter
      value: "no"
    }
    drill_fields: [patientid, data.patient_name, data.patient_mrn, chronic.has_depression, patient_problem_list.encounter_date, patient_problem_list.visitid, location.location ]
  }

  measure: count_patients_with_encounter_in_timeframe{
    type: count_distinct
    sql: ${patient_problem_list.patientid} ;;
    filters: {
      field: is_encounter_in_time_frame
      value: "yes"
    }
    drill_fields: [patientid, data.patient_name, data.patient_mrn, chronic.has_depression, type, value, visit_format]
  }

  measure: count_patients_with_encounter_in_timeframe_with_phq{
    type: count_distinct
    sql: ${patient_problem_list.patientid} ;;
    filters: {
      field: is_encounter_in_time_frame
      value: "yes"
    }
    filters: {
      field: is_type_phq
      value: "yes"
    }
    drill_fields: [patientid, data.patient_name, data.patient_mrn, chronic.has_depression, type, value, visit_format]
  }


  dimension: test_value {
    type: string
    sql: CASE
                WHEN ${TABLE}.type = 'Mammogram' THEN SUBSTRING(${Value_txt}, 6, 2) + '-' + RIGHT(${Value_txt}, 2) + '-' + LEFT(${Value_txt}, 4)
                WHEN ${TABLE}.type = 'Follow_up_plan' THEN SUBSTRING(${Value_txt}, 6, 2) + '-' + RIGHT(${Value_txt}, 2) + '-' + LEFT(${Value_txt}, 4)
                WHEN ${TABLE}.type = 'Colonoscopy' THEN SUBSTRING(${Value_txt}, 6, 2) + '-' + RIGHT(${Value_txt}, 2) + '-' + LEFT(${Value_txt}, 4)
                END;;
      #   html:
      #   <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
      #   ;;

      drill_fields: [visit_date, practice_id, data.patient_name, type]

    }



    dimension: Value_txt {
      type: string
      sql: ${TABLE}.Value_txt ;;
    }

    dimension: type_date {
      type: date
      sql: CONVERT(varchar, ${Value_txt}, 101) ;;

      html:
      <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
      ;;
    }

    measure: last_type {
      sql: max(${type_date}) ;;
    }

    dimension: value {
      type: number
      sql: CASE
          WHEN ${id}= '89363180' THEN 135
          WHEN ${id}= '90201444' THEN 63
          WHEN ${id}= '90201443' THEN 63
          WHEN ${id}= '91243466' THEN 31.2
          WHEN ${id}= '89432237' THEN 173.2
          WHEN ${id}= '91975913' THEN 257
          WHEN ${id}= '91860191' THEN 42.8
          ELSE
          ${TABLE}.value
          END;;
      html:
          <div align="center"> {{rendered_value}} </div>
          ;;
    }

    dimension: visit_format {
      sql: ${visit_date} ;;
      html:
          <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
          ;;
    }

    dimension: conv_visit_date {
      sql: ${visit_date} ;;
      html:
          <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
          ;;
    }

    dimension: year_nbr {
      type: number
      sql: ${TABLE}.YearNbr ;;
    }

#   dimension: BMI_Pretest {
#     type: number
#    # sql: ${TABLE}.YearNbr ;;
#     sql: WITH BMI_Pretest_query AS (select YearNbr, Practice_id, PatientID, VisitDate, ProviderID, LocationID, FINID, Create_Date, Type, Value, DOS_Detail_ID
# from
# (
# select *,ROW_NUMBER()over(Partition by Patientid order by Create_date) Rno
#
# from ${TABLE} where Type = 'BMI' and create_date >= '20160101'
# )x where Rno =1
# )
# SELECT
# TOP 1000
#   ${TABLE}.YearNbr AS "BMI_Pretest_query.year_nbr",
#   ${TABLE}.Practice_id AS "BMI_Pretest_query.practice_id",
#   ${TABLE}.PatientID AS "BMI_Pretest_query.patientid",
#   CONVERT(VARCHAR(19), CAST(BMI_Pretest_query.VisitDate AS DATETIME), 120) AS "BMI_Pretest_query.visit_date_time",
#   ${TABLE}.ProviderID AS "BMI_Pretest_query.provider_id",
#   ${TABLE}.LocationID AS "BMI_Pretest_query.location_id",
#   ${TABLE}.FINID AS "BMI_Pretest_query.finid",
#   CONVERT(VARCHAR(19), CAST(BMI_Pretest_query.Create_Date AS DATETIME), 120) AS "BMI_Pretest_query.create_date_time",
#   ${TABLE}y.Type AS "BMI_Pretest_query.type",
#   ${TABLE}.Value AS "BMI_Pretest_query.value",
#   ${TABLE}.DOS_Detail_ID AS "BMI_Pretest_queryy.dos_detail_id"
# FROM BMI_Pretest_query
#
# GROUP BY BMI_Pretest_query.YearNbr,BMI_Pretest_query.Practice_id,BMI_Pretest_query.PatientID,CONVERT(VARCHAR(19), CAST(BMI_Pretest_query.VisitDate AS DATETIME), 120),BMI_Pretest_query.ProviderID,BMI_Pretest_query.LocationID,BMI_Pretest_queryy.FINID,CONVERT(VARCHAR(19), CAST(BMI_Pretest_query.Create_Date AS DATETIME), 120),BMI_Pretest_query.Type,BMI_Pretest_query.Value,BMI_Pretest_query.DOS_Detail_ID
# ORDER BY 3 DESC
#
# ;;
#  }

# dimension: colonoscopy {
#   type: string
#   sql:  SELECT where type like 'colonoscopy' ;;
# }

    dimension: colonoscopy {
      type: string
      sql:  CASE

                                          WHEN ${type} like 'Colonoscopy' THEN ${TABLE}.value_txt
                                          WHEN ${TABLE}.type like 'mammogram' THEN ${TABLE}.value_txt
                                          WHEN ${TABLE}.type like 'bmi' THEN CAST(${TABLE}.value as VARCHAR)
                                          WHEN ${TABLE}.type like 'hba1c' THEN CAST(${TABLE}.value as VARCHAR)

        END
        ;;

    }

    dimension: Had_Test {
      label: "Other Tests"
      type: string
      sql:
            CASE WHEN ${type} like '%Cervical%' THEN 'Cervical Cytology ' ELSE '' END +
            CASE WHEN ${type} like '%Colonoscopy%' THEN 'Colonoscopy ' ELSE '' END +
            CASE WHEN ${type} like '%Mammogram%' THEN 'Mammogram ' ELSE '' END +
            CASE WHEN ${type} like '%HPV Tests%' THEN 'HPV Screening ' ELSE '' END +
            CASE WHEN ${type} like '%tdap%' THEN 'TDAP ' ELSE '' END +
            CASE WHEN ${type} like '%Influenza%' THEN 'Influenza Shot '
            ELSE ''
              END;;
    }


    dimension: VFC {
      type: string
      sql:
            CASE WHEN ${type} like '%V00%' THEN 'V00-Unknown' ELSE '' END +
            CASE WHEN ${type} like '%V01%' THEN 'V01-Not VFC Eligible' ELSE '' END +
            CASE WHEN ${type} like '%V02%' THEN 'V02-Medicaid' ELSE '' END +
            CASE WHEN ${type} like '%V03%' THEN 'V03-Uninsured' ELSE '' END +
            CASE WHEN ${type} like '%V04%' THEN 'V04-American Indian' ELSE '' END +
            CASE WHEN ${type} like '%V05%' THEN 'V05-Underinsured' ELSE '' END +
            CASE WHEN ${type} like '%V06%' THEN 'V06-Chip'
            ELSE ''
              END;;
    }

    dimension: HPV_Screening_date_2019_UDS {
      type: string
      sql: CASE
                  WHEN ${type} like '%HPV Tests%' and ${visit_date} >= '20150101' and ${visit_date} < '20191231' THEN 'Yes'
                  ELSE
                  'No'
                  END
             ;;
      html:
        <div align="center"> {{rendered_value}} </div>
        ;;
    }

    dimension: HPV_Screening_measure_2019_UDS {
      type: string
      sql: CASE
                  WHEN ${HPV_Screening_2019_UDS} IS NOT NULL and ${visit_year} = '2019' THEN 'Yes'
                  ELSE
                  'No'
                  END
             ;;
      html:
        <div align="center"> {{rendered_value}} </div>
        ;;
    }


    dimension: HPV_Screening_date {
      type: date
      sql: CASE
                WHEN ${type} like '%HPV Tests%' THEN ${visit_date}
                ELSE
                NULL
                END
            ;;
      html:
        <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
        ;;
    }

    dimension: HPV_Screening_2019_UDS {
      type: date
      sql: CASE
                WHEN ${type} like '%HPV Tests%' and ${visit_date} >= '20150101' and ${visit_date} < '20191231' THEN ${visit_date}
                  ELSE
                NULL
                END
            ;;
      html:
        <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
        ;;
    }


    dimension: VFC_age_tier {
      case: {
        when: {
          sql: ${age_at_visit} < 1;;
          label: "less than 1 year"
        }
        when: {
          sql:  ${age_at_visit} >= 1 AND ${age_at_visit} < 3;;
          label: "1 - 2 years old"
        }
        when: {
          sql:  ${age_at_visit} >= 3 AND ${age_at_visit} < 7;;
          label: "3 - 6 years old"
        }
        when: {
          sql: ${age_at_visit} >= 7 AND ${age_at_visit} < 19;;
          label: "7 - 18 years old"
        }
      }
      drill_fields: [data.mhmdetail*, VFC, visit_format, age_at_visit]
    }


    dimension: age_at_visit  {
      type:  number
      sql:  CASE
                    WHEN (MONTH(${visit_date})*100)+DAY(${visit_date}) >= (MONTH(${data.dob_date})*100)+DAY(${data.dob_date}) THEN
                    DATEDIFF(Year,${data.dob_date},${visit_date})
                    ELSE DATEDIFF(Year,${data.dob_date},${visit_date})-1
                    END
                    ;;
      html:
           <div align="center"> {{rendered_value}} </div>
          ;;
    }

    dimension: was_patient_18_or_over_at_time_of_visit{
      type: yesno
      sql:  ${age_at_visit}>=18 ;;
      html:
          <div align="center"> {{rendered_value}} </div>
          ;;
    }

    dimension: acs_report1_end_date {
      type: date
      sql:  '2019-12-31' ;;
    }

    dimension: acs_report2_end_date {
      type: date
      sql:  '2020-05-31' ;;
    }

    dimension: acs_report3_end_date {
      type: date
      sql:  '2020-08-31' ;;
    }

    dimension: acs_report4_end_date {
      type: date
      sql:  '2020-12-31' ;;
    }

    dimension: acs_report5_end_date {
      type: date
      sql:  '2021-03-31' ;;
    }

#   dimension: acs_start_year {
#         type: date_year
#         sql: ${acs_report2_start_date} ;;
#   }
#
#   dimension: acs_start_age {
#     type: date_year
#     sql: ${acs_report2_start_date} ;;
#   }

    dimension: acs_age_for_report1  {
      type:  number
      sql:  CASE
                    WHEN (MONTH(${acs_report1_end_date})*100)+DAY(${acs_report1_end_date}) >= (MONTH(${data.dob_date})*100)+DAY(${data.dob_date}) THEN
                    DATEDIFF(Year,${data.dob_date},${acs_report1_end_date})
                    ELSE DATEDIFF(Year,${data.dob_date},${acs_report1_end_date})-1
                    END
                    ;;
      html:
           <div align="center"> {{rendered_value}} </div>
          ;;
    }

    dimension: acs_age_for_report2  {
      type:  number
      sql:  CASE
                    WHEN (MONTH(${acs_report2_end_date})*100)+DAY(${acs_report2_end_date}) >= (MONTH(${data.dob_date})*100)+DAY(${data.dob_date}) THEN
                    DATEDIFF(Year,${data.dob_date},${acs_report2_end_date})
                    ELSE DATEDIFF(Year,${data.dob_date},${acs_report2_end_date})-1
                    END
                    ;;
      html:
           <div align="center"> {{rendered_value}} </div>
          ;;
    }

    dimension: acs_age_for_report3  {
      type:  number
      sql:  CASE
                    WHEN (MONTH(${acs_report3_end_date})*100)+DAY(${acs_report3_end_date}) >= (MONTH(${data.dob_date})*100)+DAY(${data.dob_date}) THEN
                    DATEDIFF(Year,${data.dob_date},${acs_report3_end_date})
                    ELSE DATEDIFF(Year,${data.dob_date},${acs_report3_end_date})-1
                    END
                    ;;
      html:
           <div align="center"> {{rendered_value}} </div>
          ;;
    }

    dimension: acs_age_for_report4  {
      type:  number
      sql:  CASE
                    WHEN (MONTH(${acs_report4_end_date})*100)+DAY(${acs_report4_end_date}) >= (MONTH(${data.dob_date})*100)+DAY(${data.dob_date}) THEN
                    DATEDIFF(Year,${data.dob_date},${acs_report4_end_date})
                    ELSE DATEDIFF(Year,${data.dob_date},${acs_report4_end_date})-1
                    END
                    ;;
      html:
           <div align="center"> {{rendered_value}} </div>
          ;;
    }

    dimension: acs_age_for_report5  {
      type:  number
      sql:  CASE
                    WHEN (MONTH(${acs_report5_end_date})*100)+DAY(${acs_report5_end_date}) >= (MONTH(${data.dob_date})*100)+DAY(${data.dob_date}) THEN
                    DATEDIFF(Year,${data.dob_date},${acs_report5_end_date})
                    ELSE DATEDIFF(Year,${data.dob_date},${acs_report5_end_date})-1
                    END
                    ;;
      html:
           <div align="center"> {{rendered_value}} </div>
          ;;
    }

    dimension: HPV_Series{
      type: string
      sql:  CASE

                                                    WHEN ${type} like 'HPV Series' and ${TABLE}.value = 1 THEN 'Completed HPV Series'
                                                    Else 'Needs to complete HPV Series'

        END
        ;;

    }

    dimension: MCV{
      type: string
      group_label: "Immunizations"
      sql:  CASE

                                                      WHEN ${type} like 'MCV' and ${TABLE}.value = 1 THEN 'Completed MCV'
                                                      Else 'Needs to complete MPV'

        END
        ;;

    }

    dimension: MCV_date{
      type: date
      group_label: "Immunizations"
      sql:  CASE
                WHEN ${type} like 'MCV' and ${TABLE}.value = 1 THEN ${visit_date}
                  Else NULL
              END
                  ;;

    }

    measure: last_mcv_visit_quarter {
      type: date_quarter
      sql: CASE
              WHEN ${is_mcv_in_time_frame} = "Yes" THEN max(${visit_quarter})
              ELSE
              NULL
              END;;
    }

    dimension:  is_mcv_in_time_frame {
      group_label: "Immunizations"
      description: "shows MCV doses in a given timeframe"
      type: yesno
      sql: {% condition visit_or_dose_in_timeframe_filter %} ${visit_date} {% endcondition %} and ${type} like 'MCV' ;;
    }

    measure: count_of_yes_mcv_in_timeframe {
      type: count_distinct
      sql: ${patientid} ;;
      filters: {
        field: is_mcv_in_time_frame
        value: "yes"
      }
      drill_fields: [patientid, data.patient_name, data.patient_mrn, data.dob_year, data.sex, MCV_date]
    }

    dimension: TDAP{
      type: string
      group_label: "Immunizations"
      description: "shows TDAP Compltions"
      sql:  CASE

                                                        WHEN ${type} like 'TDAP' and ${TABLE}.value = 1 THEN 'Completed TDAP'
                                                        Else 'Needs to complete TDAP'

        END
        ;;

    }

    dimension: TDAP_date{
      type: date
      group_label: "Immunizations"
      description: "shows TDAP Date"
      sql:  CASE
                WHEN ${type} like 'TDAP' and ${TABLE}.value = 1 THEN ${visit_date}
                  Else NULL
              END
                  ;;

      html:
                <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
        ;;

    }

    dimension:  is_tdap_in_time_frame {
      group_label: "Immunizations"
      description: "shows TDAP in a given timeframe"
      type: yesno
      sql: {% condition visit_or_dose_in_timeframe_filter %} ${visit_date} {% endcondition %} and ${type} like 'TDAP' ;;
    }

    measure: count_of_yes_tdap_in_timeframe {
      type: count_distinct
      sql: ${patientid} ;;
      filters: {
        field: is_tdap_in_time_frame
        value: "yes"
      }
      drill_fields: [patientid, data.patient_name, data.patient_mrn, data.dob_year, data.sex, TDAP_date]
    }



    dimension: HCV_Test{
      group_label: "HCV Tests"
      type: string
      sql:  CASE
                          WHEN ${type} = 'HCV Test' THEN 'Yes'
                                        Else 'No'
                                    END  ;;
      html:
                <div align="center"> {{rendered_value}} </div>
                ;;

    }

    dimension: HCV_Test_value{
      group_label: "HCV Tests"
      type: number
      sql:  CASE
                            WHEN ${type} = 'HCV Test' THEN ${value}
                                          Else NULL
                                      END  ;;

      html:
                    <div align="center"> {{rendered_value}} </div>
                    ;;

    }

#     WHEN ${type} = 'HCV Test' and ${TABLE}.value = 1 THEN 'Yes'

    measure: count_HCV_Tests {
      group_label: "HCV Tests"
      type: count
      filters: {
        field: HCV_Test
        value: "Yes"
      }
      html:
                  <div align="center"> {{rendered_value}} </div>
                  ;;
      drill_fields: [visit_date, patientid, data.patient_name, data.patient_mrn, data.dob, data.sex, data.last_appt, type, provider.provider_name, location.location]
    }

    dimension: HCV_Ab_Test{
      group_label: "HCV Tests"
      type: string
      sql:  CASE
                            WHEN ${type} = 'HCV Ab Test' THEN 'Yes'
                                          Else 'No'
                                      END  ;;
      html:
                  <div align="center"> {{rendered_value}} </div>
                  ;;
    }

    dimension: HCV_Ab_value{
      group_label: "HCV Tests"
      type: number
      sql:  CASE
                            WHEN ${type} = 'HCV Ab Test' THEN ${value}
                                          Else NULL
                                      END  ;;
      html:
                  <div align="center"> {{rendered_value}} </div>
                  ;;

    }

#    WHEN ${type} = 'HCV Ab Test' and ${TABLE}.value = 1 THEN 'Yes'

    measure: count_HCV_Ab_Tests {
      group_label: "HCV Tests"
      type: count
      filters: {
        field: HCV_Ab_Test
        value: "Yes"
      }
      html:
          <div align="center"> {{rendered_value}} </div>
          ;;
      drill_fields: [visit_date, patientid, data.patient_name, data.patient_mrn, data.dob, data.sex, data.last_appt, type, provider.provider_name, location.location]
    }

    dimension: Alt_Test{
      group_label: "HCV Tests"
      type: string
      sql:  CASE
                    WHEN ${type} = 'ALT - code' THEN 'Yes'
                                  Else 'No'
                              END  ;;
      html:
          <div align="center"> {{rendered_value}} </div>
          ;;
    }

    dimension: Alt_value{
      group_label: "HCV Tests"
      type: number
      sql:  CASE
                    WHEN ${type} = 'ALT - code' THEN ${value}
                                  Else NULL
                              END  ;;
      html:
          <div align="center"> {{rendered_value}} </div>
          ;;

    }

#    WHEN ${type} = 'HCV Ab Test' and ${TABLE}.value = 1 THEN 'Yes'

    measure: count_Alt_Tests {
      group_label: "HCV Tests"
      type: count
      filters: {
        field: Alt_Test
        value: "Yes"
      }
      html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      drill_fields: [visit_date, patientid, data.patient_name, data.patient_mrn, data.dob, data.sex, data.last_appt, type, provider.provider_name, location.location]
    }

    dimension: HCV_RNA_Test{
      group_label: "HCV Tests"
      type: string
      sql:  CASE
                WHEN ${type} = 'HCV RNA Test' THEN 'Yes'
                              Else 'No'
                          END  ;;
      html:
      <div align="center"> {{rendered_value}} </div>
      ;;
    }

    dimension: HCV_RNA_value{
      group_label: "HCV Tests"
      type: number
      sql:  CASE
                WHEN ${type} = 'HCV RNA Test' THEN ${value}
                              Else NULL
                          END  ;;
      html:
      <div align="center"> {{rendered_value}} </div>
      ;;

    }

    dimension: HCV_RNA_note{
      group_label: "HCV Tests"
      type: string
      sql:  CASE
                  WHEN ${type} = 'HCV RNA Test' THEN ${Value_txt}
                                Else ''
                            END  ;;
      html:
        <div align="center"> {{rendered_value}} </div>
        ;;

    }

    measure: count_HCV_RNA_Tests {
      group_label: "HCV Tests"
      type: count
      filters: {
        field: HCV_RNA_Test
        value: "Yes"
      }
      html:
          <div align="center"> {{rendered_value}} </div>
          ;;
      drill_fields: [visit_date, patientid, data.patient_name, data.patient_mrn, data.dob, data.sex, data.last_appt, type,  provider.provider_name, location.location]
    }

    dimension: Hepatitis_B_Surface_Test{
      group_label: "HCV Tests"
      type: string
      sql:  CASE
                    WHEN ${type} = 'Hep B Surf Antigen' THEN 'Yes'
                                  Else ''
                              END  ;;
      html:
          <div align="center"> {{rendered_value}} </div>
          ;;
    }

    dimension: Hepatitis_B_Surface_Test_note{
      group_label: "HCV Tests"
      type: string
      sql:  CASE
                    WHEN ${type} = 'Hep B Surf Antigen' THEN ${Value_txt}
                                  Else ''
                              END  ;;
      html:
          <div align="center"> {{rendered_value}} </div>
          ;;

    }

    measure: count_Hepatitis_B_Surface_Test {
      group_label: "HCV Tests"
      type: count
      filters: {
        field: Hepatitis_B_Surface_Test
        value: "Yes"
      }
      drill_fields: [visit_date, patientid, data.patient_name, data.patient_mrn, data.dob, data.sex, data.last_appt, type, provider.provider_name, location.location]
    }

    dimension: Hep_B_Antibody_Test{
      group_label: "HCV Tests"
      type: string
      sql:  CASE
                      WHEN ${type} = 'Hep B Antibody' THEN 'Yes'
                                    Else ''
                                END  ;;
      html:
            <div align="center"> {{rendered_value}} </div>
            ;;
    }

    dimension: Hep_B_Antibody_Test_note{
      group_label: "HCV Tests"
      type: string
      sql:  CASE
                      WHEN ${type} = 'Hep B Antibody' THEN ${Value_txt}
                                    Else ''
                                END  ;;
      html:
            <div align="center"> {{rendered_value}} </div>
            ;;

    }

    measure: count_Hep_B_Antibody_Test {
      group_label: "HCV Tests"
      type: count
      filters: {
        field: Hep_B_Antibody_Test
        value: "Yes"
      }
      html:
                <div align="center"> {{rendered_value}} </div>
                ;;
      drill_fields: [visit_date, patientid, data.patient_name, data.patient_mrn, data.dob, data.sex, data.last_appt, type, provider.provider_name, location.location]
    }

    dimension: Hepatitis_C_Test{
      group_label: "HCV Tests"
      type: string
      sql:  CASE
                        WHEN ${type} = 'Hepatitis C' and ${TABLE}.value = 1 THEN 'Yes'
                                      Else 'No'
                                  END  ;;
      html:
              <div align="center"> {{rendered_value}} </div>
              ;;
    }

    measure: count_Hepatitis_C_Test {
      group_label: "HCV Tests"
      type: count
      filters: {
        field: Hepatitis_C_Test
        value: "Yes"
      }
      html:
              <div align="center"> {{rendered_value}} </div>
              ;;
      drill_fields: [visit_date, patientid, data.patient_name, data.patient_mrn, data.dob, data.sex, data.last_appt, type, provider.provider_name, location.location]
    }

    dimension: Liver_Cancer{
      group_label: "HCV Tests"
      type: string
      sql:  CASE
                        WHEN ${type} = 'Liver Cancer' and ${TABLE}.value = 1 THEN 'Yes'
                                      Else 'No'
                                  END  ;;
      html:
              <div align="center"> {{rendered_value}} </div>
              ;;
    }

    measure: count_Liver_Cancer {
      group_label: "HCV Tests"
      type: count
      filters: {
        field: Liver_Cancer
        value: "Yes"
      }
      html:
              <div align="center"> {{rendered_value}} </div>
              ;;
      drill_fields: [visit_date, patientid, data.patient_name, data.patient_mrn, data.dob, data.sex, data.last_appt, type, provider.provider_name, location.location]
    }

    measure: count_unique_patients_with_visits {
      type: count_distinct
      sql: ${patientid} ;;
    }

    dimension: was_visit_this_year {
      type:yesno
      sql: ${visit_year} = YEAR(GETDATE()) ;;
    }

    measure: unique_patients_with_visits_this_year {
      type: count_distinct
      sql: ${patientid} ;;
      filters: {
        field: was_visit_this_year
        value: "yes"
      }
      drill_fields: [visit_date, data.patient_name, data.patient_mrn, data.dob, data.sex, data.last_appt]
    }

    measure: unique_patients_with_visits_in_2019 {
      type: count_distinct
      sql: ${patientid} ;;
      filters: {
        field: is_visit_in_2019
        value: "yes"
      }
      drill_fields: [data.patient_name, data.patient_mrn, mhm_patient_list.mhm_patientid, data.dob, data.sex, data.last_appt]
    }



#*******************Pneumo Immunizations for Patient over 65 Quality Measure  *********************



    # dimension:patients_over_65_had_pneumo {
    #   type: string
    #   sql:  CASE

    #                                           WHEN ${test_type} like 'PNEUMO' and ${value} = 1 and ${data.age} >= 65 THEN 'yes'
    #                                           Else 'no'

    #     END;;

    # }

    # dimension:patients_who_had_pneumovax {
    #   type: yesno
    #   sql:  ${test_type} like 'PNEUMO' and ${value} = 1;;
    # }

    # dimension:patients_over_65{
    #   type: string
    #   sql:  CASE

    #                                                   WHEN ${data.age} >= 65 THEN 'yes'
    #                                                   Else 'no'

    #     END
    #     ;;

    # }

    # dimension:patients_over_65_with_visits_this_year{
    #   type: string
    #   sql:  CASE

    #                                               WHEN ${data.age} >= 65 and ${visit_year} = YEAR(GETDATE()) THEN 'yes'
    #                                               Else 'no'

    #     END
    #     ;;

    # }
    # dimension:patients_over_65_with_visits_this_year_and_with_pneumo{
    #   type: string
    #   sql:  CASE


    #                                                   WHEN ${patients_over_65_had_pneumo}='yes' and ${visit_year} = YEAR(GETDATE()) THEN 'yes'
    #                                                   Else 'no'

    #     END
    #     ;;

    # }

    # dimension:patients_over_65_with_visits_this_year_and_with_no_pneumo{
    #   type: string
    #   sql:  CASE

    #                                                             WHEN ${TABLE}.type LIKE 'PNEUMO' and ${TABLE}.value = 0 and ${data.age} >= 65 and ${visit_year} = YEAR(GETDATE()) THEN 'yes'
    #                                                             Else 'no'

    #     END
    #     ;;

    # }


    # measure: patients_over_65_with_visits {
    #   type:  count_distinct
    #   drill_fields: [patientid, data.patient_name, data.patient_mrn, data.sex,patients_over_65_with_visits_this_year, patients_over_65_had_pneumo ]
    #   sql:  ${patientid};;
    #   filters: {
    #     field: patients_over_65_with_visits_this_year
    #     value: "yes"
    #   }
    # }

    # measure: patients_over_65_with_pneumo{
    #   type:  count_distinct
    #   drill_fields: [patientid, data.patient_name, data.patient_mrn, data.sex, patients_over_65_with_visits_this_year, patients_over_65_had_pneumo]
    #   sql:  ${patientid};;
    #   filters: {
    #     field: patients_over_65_had_pneumo
    #     value: "yes"
    #   }
    # }

    # measure: patients_over_65_count {
    #   type: count_distinct
    #   sql:  ${patientid} ;;
    #   filters: {
    #     field: patients_over_65
    #     value: "yes"
    #   }

    # }

    # measure: patients_over_65_with_visit_with_pneumo {
    #   type: count_distinct
    #   drill_fields: [patientid, data.patient_name, data.patient_mrn, data.sex, patients_over_65_with_visits_this_year_and_with_pneumo]
    #   group_label: "Quality Measures"
    #   sql: ${patientid} ;;
    #   filters: {
    #     field: patients_over_65_with_visits_this_year_and_with_pneumo
    #     value: "yes"
    #   }
    # }


#   measure: pneumo_percentage {
#     type:  average
#     group_label: "Quality Measures"
#     sql:  ${sum_over_65_with_visit_with_pneumo} / ${patients_over_65_with_visits};;
#     value_format_name: percent_2
#   }

    #*******************Pneumo Immunizations for Patient over 65 Quality Measure  - END  *********************



    dimension: pneumo{
      type: string
      sql:  CASE

                                                                          WHEN ${TABLE}.type like 'PNEUMO' and ${TABLE}.value = 1 THEN 'Completed PNEUMO'
                                                                          Else 'PNEUMO Not on File'

        END
        ;;

    }

    measure: sum_pneumo {
      type: sum
      sql: ${value} ;;
      filters: {
        field: type
        value: "PNEUMO"
      }

    }

    measure: count_pneumo {
      type: count_distinct
      sql: ${patientid} ;;
      filters: {
        field: type
        value: "PNEUMO"
      }

    }



    measure: count_patients_test {
      type: count_distinct
      drill_fields: [patientid, data.patient_name, data.patient_mrn, age_at_visit, data.sex, visit_format, type]
      sql: ${patientid} ;;
    }

    measure: count_visits {
      type: count_distinct
      drill_fields: [patientid, data.patient_name, data.patient_mrn, data.sex, visit_date, provider.provider_name]
      sql: ${create_raw} ;;
    }

    measure: count_patient_visits {
      type: count_distinct
      # drill_fields: [patientid, data.patient_name, data.patient_mrn, data.sex, visit_date, payerid, payers.payer_name]
      sql: ${visit_date} ;;
    }

    dimension: occult_test {
      type: string
      sql: CASE
                        WHEN ${type} = 'Colon Tests' THEN 'Complete'
                        ELSE
                        ''
                        END;;
      drill_fields: [patientid, data.patient_name, data.patient_mrn, visit_date, type, data.pcp_name]
    }

    dimension: UDS_occult_test_2019 {
      type: string
      sql: CASE
                        WHEN ${type} = 'Colon Tests' and ${visit_year}='2019' THEN 'Yes'
                        ELSE
                        'No'
                        END;;
      drill_fields: [patientid, data.patient_name, data.patient_mrn, visit_date, type, data.pcp_name]
    }


    measure: test_result {
      type: average
      sql: ${value} ;;
      drill_fields: [patientid, data.patient_name, data.patient_mrn, visit_date, type, data.pcp_name]
    }

    measure: procedure_result {
      type: date
      sql: ${Value_txt} ;;
      drill_fields: [patientid, data.patient_name, data.patient_mrn, visit_date, type, procedure_result, data.pcp_name]
    }

    measure: patient_visits {
      type:  count_distinct
      sql:  ${visit_date};;
      #   drill_fields: [patientid, data.patient_name, data.patient_mrn, data.sex, visit_date, type]
    }

    measure: hpv_eligible_patient_visits {
      type:  count_distinct
      sql:  ${visit_date};;
      #   drill_fields: [patientid, data.patient_name, data.patient_mrn, data.sex, visit_date, type]
    }

#   measure: MHM_patient_visits {
#     type:  count_distinct
#     sql:  ${visit_date};;
#     filters: {
#       field: patient_problem_list.E_M_or_Counseling_visit
#       value: "Yes"
#     }
#   }

#this is not correct as it's not the most recent value
    measure: avg_HDL {
      type: average
      sql: ${value} ;;
      filters: {
        field: type
        value: "ldl cholesterol"
      }
    }

#this is not correct as it's not the most recent value
    measure: avg_diastolic {
      type: average
      sql: ${value} ;;
      filters: {
        field: type
        value: "diastolic"
      }
    }

#this is not correct as it's not the most recent value
    measure: avg_systolic {
      type: average
      sql: ${value} ;;
      filters: {
        field: type
        value: "systolic"
      }
    }

#this is not correct as it's not the most recent value
    measure: avg_LDL {
      type: average
      sql: ${value} ;;
      filters: {
        field: type
        value: "hdl cholesterol"
      }
      value_format_name: decimal_0
    }

#this is not correct as it's not the most recent value
    measure: avg_trig {
      type: average
      sql: ${value} ;;
      filters: {
        field: type
        value: "Triglycerides"
      }
      value_format_name: decimal_0
    }

#this is not correct as it's not the most recent value
    measure: avg_chol {
      type: average
      sql: ${value} ;;
      filters: {
        field: type
        value: "Total Cholesterol"
      }
      value_format_name: decimal_0
    }


#   measure: distinct_visits{
#     type: count
#     sql:  ${count_visits}>0 ;;
#   }

    measure: sum_hpv_single {
      type: sum
      group_label: "Immunizations"
      sql: ${value} ;;
      filters: {
        field: type
        value: "HPV Single"
      }
      value_format_name: decimal_0
      drill_fields: [patientid, data.patient_name, data.patient_mrn, data.dob, data.sex, data.last_appt]
    }

    measure: sum_hpv_series {
      type: sum
      group_label: "Immunizations"
      sql: ${value} ;;
      filters: {
        field: type
        value: "HPV Series"
      }
      value_format_name: decimal_0
      drill_fields: [patientid, data.patient_name, data.patient_mrn, data.dob, data.sex, data.last_appt]
    }

    measure: sum_hpv {
      type: sum
      group_label: "Immunizations"
      sql: ${value} ;;
      filters: {
        field: type
        value: "HPV"
      }
      value_format_name: decimal_0
      drill_fields: [patientid, data.patient_name, data.patient_mrn, data.dob, data.sex, data.last_appt]
    }

    measure: sum_hpv_tests {
      type: sum
      group_label: "Other Tests"
      sql: ${value} ;;
      filters: {
        field: type
        value: "HPV Tests"
      }
      value_format_name: decimal_0
      drill_fields: [patientid, data.patient_name, data.patient_mrn, age_at_visit, data.dob, data.sex, HPV_Screening_date]
    }

    measure: count_hpv_screening {
      type: count_distinct
      sql: ${patientid} ;;
      group_label: "Other Tests"
      filters: {
        field: HPV_Screening_date_2019_UDS
        value: "Yes"
      }
      filters: {
        field: is_visit_in_2019
        value: "Yes"
      }

      value_format_name: decimal_0
      drill_fields: [patientid, data.patient_name, data.patient_mrn, age_at_visit, data.dob, data.sex, HPV_Screening_date]
    }


    measure: sum_mcv {
      type: sum
      group_label: "Immunizations"
      sql: ${value} ;;
      filters: {
        field: type
        value: "MCV"
      }
      value_format_name: decimal_0
    }

    measure: sum_tdap {
      type: sum
      group_label: "Immunizations"
      sql: ${value} ;;
      filters: {
        field: type
        value: "TDAP"
      }
      value_format_name: decimal_0
    }

    measure: count_V00 {
      type: count
      group_label: "VFC Immunizations"
      filters: {
        field: type
        value: "V00"
      }
      value_format_name: decimal_0
      drill_fields: [patientid, data.patient_name, data.patient_mrn, data.sex, visit_date, type]
    }

    measure: count_V01 {
      type: count
      group_label: "VFC Immunizations"
      filters: {
        field: type
        value: "V01"
      }
      value_format_name: decimal_0
    }

    measure: count_V02 {
      type: count
      group_label: "VFC Immunizations"
      filters: {
        field: type
        value: "V02"
      }
      value_format_name: decimal_0
    }

    measure: count_V03 {
      type: count
      group_label: "VFC Immunizations"
      filters: {
        field: type
        value: "V03"
      }
      value_format_name: decimal_0
    }

    measure: count_V04 {
      type: count
      group_label: "VFC Immunizations"
      filters: {
        field: type
        value: "V04"
      }
      value_format_name: decimal_0
    }

    measure: count_V05 {
      type: count
      group_label: "VFC Immunizations"
      filters: {
        field: type
        value: "V05"
      }
      value_format_name: decimal_0
    }

    measure: count_V06 {
      type: count
      group_label: "VFC Immunizations"
      filters: {
        field: type
        value: "V06"
      }
      value_format_name: decimal_0
    }

    measure: distinct_count_of_patients {
#     hidden: yes
    type: count_distinct
    sql: ${patientid} ;;
    drill_fields: [patientid, data.patient_name, data.patient_mrn, data.sex, visit_date, payerid, payers.payer_name, patient_hpv.date_first_shot_date]
  }

  #will need to have HPV Filters in dashboard
  measure: distinct_count_of_acs_patients_no_filter {
    description: "American Cancer Society report to drill into hpv, mcv and tdap activity"
    #     hidden: yes
    type: count_distinct
    sql: ${patientid} ;;
    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

  measure: distinct_count_of_hpv_patients_no_init {
    description: "need to be sure there's an HPV filter"
    group_label: "HPV Counts"
    type: count_distinct
    sql: CASE
                  WHEN ${patient_hpv.date_first_shot_date} IS NULL THEN ${patientid}
                  ELSE
                  NULL
                  END;;
    html:
              <div align="center"> {{rendered_value}} </div>
              ;;
    drill_fields: [patient_hpv.hpvdetail*]
  }

  measure: distinct_count_of_hpv_patients {
    group_label: "HPV Counts"
    type: count_distinct
    sql: ${patientid} ;;
    filters: {
      field: HPV_visit_in_time_frame
      value: "yes"
    }
    filters: {
      field: patient_hpv.is_hpv_patient_at_visit_timeframe
      value: "yes"
    }
    html:
              <div align="center"> {{rendered_value}} </div>
              ;;

    link: {
      label: "HPV Patients Detail by Visit and Provider"
      url: "/looks/852?toggle=det &f[patient_hpv.timeframe_filter]={{ _filters['patient_hpv.timeframe_filter'] | url_encode }}"
    }

    drill_fields: [patient_hpv.hpvdetail_distinct*, count_patient_visits]
  }

  measure: distinct_count_of_hpv_patients_eligible_dose_1 {
    description: "need to be sure there's an HPV filter"
    group_label: "HPV Counts"
    type: count_distinct
    sql: CASE
                    WHEN datediff(day, ${patient_hpv.date_first_shot_date},${visit_date}) <= 0 or
                    ${patient_hpv.date_first_shot_date} IS NULL THEN ${patientid}
                    ELSE
                    NULL
                    END;;
    html:
                <div align="center"> {{rendered_value}} </div>
                ;;
    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

  measure: distinct_count_of_hpv_patients_eligible_next_dose {
    description: "need to be sure there's an HPV filter"
    group_label: "HPV Counts"
    type: count_distinct
    sql: CASE
                    WHEN (${patient_hpv.date_first_shot_date} IS NOT NULL and ${patient_hpv.date_second_shot_date} IS NULL
                        and datediff(day, ${patient_hpv.recommended__2nd_shot_date_start},getdate()) >= 0)
                        or (datediff(day, ${patient_hpv.date_second_shot_raw},${visit_raw}) <= 0)
                        or (${patient_hpv.date_first_shot_date} IS NOT NULL and ${patient_hpv.date_second_shot_date} IS NOT NULL
                        and ${patient_hpv.date_third_shot_date} IS NULL and datediff(day, ${patient_hpv.recommended__3rd_shot_date_start},getdate()) >= 0)
                        or (datediff(day, ${patient_hpv.date_third_shot_raw},${visit_raw}) <= 0)
                        THEN ${patientid}
                    ELSE
                    NULL
                    END;;
    html:
                <div align="center"> {{rendered_value}} </div>
                ;;
    drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

  measure: distinct_count_of_hpv_patients_eligible_all_doses {
    description: "need to be sure there's an HPV filter"
    group_label: "HPV Counts"
    type: count_distinct
    sql: CASE
                    WHEN (datediff(day, ${patient_hpv.date_first_shot_date},${visit_date}) <= 0 or ${patient_hpv.date_first_shot_date} IS NULL)
                        or (${patient_hpv.date_first_shot_date} IS NOT NULL and ${patient_hpv.date_second_shot_date} IS NULL
                        and datediff(day, ${patient_hpv.recommended__2nd_shot_date_start},${visit_date}) >= 0)
                        or (datediff(day, ${patient_hpv.date_second_shot_date},${visit_date}) <= 0)
                        or (${patient_hpv.date_first_shot_date} IS NOT NULL and ${patient_hpv.date_second_shot_date} IS NOT NULL
                        and ${patient_hpv.date_third_shot_date} IS NULL and datediff(day, ${patient_hpv.recommended__3rd_shot_date_start},${visit_date}) >= 0)
                        or (datediff(day, ${patient_hpv.date_third_shot_date},${visit_date}) <= 0)
                        THEN ${patientid}
                    ELSE
                    NULL
                    END;;
    html:
                <div align="center"> {{rendered_value}} </div>
                ;;

    link: {
      label: "Patients Eligible for Dose"
      url: "/looks/829?toggle=det &f[patient_hpv.timeframe_filter]={{ _filters['patient_hpv.timeframe_filter'] | url_encode }}"

    }

#   measure: distinct_count_of_hpv_patients_eligible_all_doses {
#     description: "need to be sure there's an HPV filter"
#     group_label: "HPV Counts"
#     type: count_distinct
#     sql: CASE
#       WHEN (datediff(day, ${patient_hpv.date_first_shot_date},${visit_date}) <= 0 or ${patient_hpv.date_first_shot_date} IS NULL)
#           or (${patient_hpv.date_first_shot_date} IS NOT NULL and ${patient_hpv.date_second_shot_date} IS NULL
#           and datediff(day, ${patient_hpv.recommended__2nd_shot_date_start},getdate()) >= 0)
#           or (datediff(day, ${patient_hpv.date_second_shot_date},${visit_date}) <= 0)
#           or (${patient_hpv.date_first_shot_date} IS NOT NULL and ${patient_hpv.date_second_shot_date} IS NOT NULL
#           and ${patient_hpv.date_third_shot_date} IS NULL and datediff(day, ${patient_hpv.recommended__3rd_shot_date_start},getdate()) >= 0)
#           or (datediff(day, ${patient_hpv.date_third_shot_date},${visit_date}) <= 0)
#           THEN ${patientid}
#       ELSE
#       NULL
#       END;;
#     html:
#     <div align="center"> {{rendered_value}} </div>
#     ;;
#
#     link: {
#       label: "Patients Eligible for Dose"
#       url: "/looks/829?toggle=det &f[patient_hpv.timeframe_filter]={{ _filters['patient_hpv.timeframe_filter'] | url_encode }}"
#
#     }
#     drill_fields: [patient_hpv.hpvdetail_distinct*]
  }

#   dimension: is_patient_eligible_for_a_dose {
#     type: string
#     sql: CASE
#       WHEN (datediff(day, ${patient_hpv.date_first_shot_date},${visit_date}) <= 0 or ${patient_hpv.date_first_shot_date} IS NULL) THEN 'Yes'
#       WHEN (${patient_hpv.date_first_shot_date} IS NOT NULL and ${patient_hpv.date_second_shot_date} IS NULL
#           and datediff(day, ${patient_hpv.recommended__2nd_shot_date_start},getdate()) >= 0) THEN 'Yes'
#       WHEN (datediff(day, ${patient_hpv.date_second_shot_date},${visit_date}) <= 0) THEN 'Yes'
#       WHEN (${patient_hpv.date_first_shot_date} IS NOT NULL and ${patient_hpv.date_second_shot_date} IS NOT NULL
#           and ${patient_hpv.date_third_shot_date} IS NULL and datediff(day, ${patient_hpv.recommended__3rd_shot_date_start},getdate()) >= 0) THEN 'Yes'
#       WHEN (datediff(day, ${patient_hpv.date_third_shot_date},${visit_date}) <= 0) THEN 'Yes'
#       ELSE
#       'No'
#       END;;
#     html:
#     <div align="center"> {{rendered_value}} </div>
#     ;;
#   }

  dimension: is_patient_eligible_for_a_dose {
    type: string
    sql: CASE
                      WHEN (datediff(day, ${patient_hpv.date_first_shot_date},${visit_date}) <= 0 or ${patient_hpv.date_first_shot_date} IS NULL) THEN 'Yes'

      WHEN (${patient_hpv.date_first_shot_date} IS NOT NULL and ${patient_hpv.date_second_shot_date} IS NULL
      and datediff(day, ${patient_hpv.recommended__2nd_shot_date_start},${visit_date}) >= 0) THEN 'Yes'

      WHEN (datediff(day, ${patient_hpv.date_second_shot_date},${visit_date}) <= 0) THEN 'Yes'

      WHEN (${patient_hpv.date_first_shot_date} IS NOT NULL and ${patient_hpv.date_second_shot_date} IS NOT NULL
      and ${patient_hpv.date_third_shot_date} IS NULL and datediff(day, ${patient_hpv.recommended__3rd_shot_date_start},${visit_date}) >= 0) THEN 'Yes'

      WHEN (datediff(day, ${patient_hpv.date_third_shot_date},${visit_date}) <= 0) THEN 'Yes'

      ELSE
      'No'
      END;;
    html:
                  <div align="center"> {{rendered_value}} </div>
                  ;;
  }

  measure: count_of_distinct_patients_eligible_for_a_dose {
    group_label: "HPV Counts"
    type: count
#     sql: ${patientid} ;;
    filters: {
      field: is_patient_eligible_for_a_dose
      value: "Yes"
    }
    filters: {
      field: HPV_visit_in_time_frame
      value: "yes"
    }
#     filters: {
#       field: patient_hpv.is_hpv_patient
#       value: "yes"
#         }

    drill_fields: [patientid, data.patient_name, data.patient_mrn, data.sex, visit_date, payerid, payers.payer_name, patient_hpv.date_first_shot_date]
  }




  measure: distinct_count_of_patients_no_visit_info {
#     hidden: yes
  type: count_distinct
  sql: ${patientid} ;;
  drill_fields: [patientid, data.patient_name, data.patient_mrn, data.dob, data.sex, data.last_appt]
}

measure: VFC_Patients {
  group_label: "VFC Immunizations"
  type: count_distinct
  sql: ${patientid} ;;


  html:
                <div align="center"> {{rendered_value}} </div>

                            ;;

  drill_fields: [data.patient_name, data.patient_mrn, data.dob, data.sex, VFC ,visit_format, age_at_visit]
}



measure: distinct_count_of_patients_seen_last_wk {
#     hidden: yes
type: count
filters: {
  field: visit_date
  value: "Last Week"
}
#         filters: {
#           field: patient_hpv.is_hpv_patient
#           value: "yes"
#         }

drill_fields: [patientid, data.patient_name, data.patient_mrn, data.sex, visit_date, payerid, payers.payer_name, patient_hpv.date_first_shot_date]
}

measure: count_doses_provided_last_wk{
  type:count
  filters: {
    field: visit_date
    value: "last week"
  }
  filters: {
    field: type
    value: "%HPV%"
  }
  drill_fields: [patientid, data.patient_name, data.patient_mrn, data.sex, visit_date, payerid, payers.payer_name, patient_hpv.date_first_shot_date]
}

measure: count_doses_provided{
  type:count
  filters: {
    field: type
    value: "%HPV%"
  }
  filters: {
    field: is_type_hpv
    value: "yes"
  }
  drill_fields: [patientid, data.patient_name, data.patient_mrn, data.sex, visit_date, payerid, payers.payer_name, patient_hpv.date_first_shot_date]
}

dimension: is_type_hpv{
  type:  yesno
  sql:  ${type}='HPV' or ${type}='HPV Single' or ${type}='HPV Series';;
}

#   measure: MHM_patient_visits {
#     type:  count_distinct
#     sql:  ${visit_date};;
#     filters: {
#       field: payerid
#       value: "175"
#     }
#     drill_fields: [visit_date, practice_id, data.patient_name, payerid]
#
#
#
# }
#
#   measure: MHM_patient_visits {
#     type:  count_distinct
#     sql: CASE
#                    WHEN ${TABLE}.Practice_id = 1002 THEN ${MHM_Payer_1002}
#                    --WHEN ${TABLE}.status = 1 THEN 'Winter'
#                    --WHEN ${TABLE}.status = 2 THEN 'Spring'
#                    ELSE ${count_visits}
#             END ;;
#   }


#   measure: MHM_Payer_1002 {
#     group_label: "MHM Payer"
#     type: count
#     filters: {
#       field: payerid
#       value: "175"
#     }
#     drill_fields: [visit_date, practice_id, data.patient_name, payerid]
#   }
#
#   measure: MHM_Payer_1009 {
#     group_label: "MHM Payer"
#     type: count
#     filters: {
#       field: payerid
#       value: "780"
#     }
#     drill_fields: [visit_date, practice_id, data.patient_name, payerid]
#   }

# dimension: mhm_payer_list {
#   type: string
#   sql:  CASE
#     WHEN ${practice_id} = 1002 THEN CAST('AHC Methodist Healthcare - IHI' as VARCHAR)
#     WHEN ${practice_id} = 1009 THEN CAST('Methodist Healthcare Ministries Of South Texas, Inc' as VARCHAR)
#
#
#   END
#   ;;
#
# }

set: detail {
  fields: [
    date_of_service,
    visitid,
    data.patient_name,
    data.patient_mrn,
    data.dob_date,
    data.sex,
    data.is_smoker,
    data.Next_Appt,
    data.days_since_last_visit,
    last_patient_tests.last_blood_pressure,
    last_patient_tests.last_bmi_result,
    last_patient_tests.last_hba1c_result,
    last_patient_tests.last_phq_result,
    uds_measures_data.uds_problem_list,
    last_patient_tests.gap_list_text,
    pcp.pcp_name,
    provider.provider_name
  ]
}

set: hpvdetail {
  fields: [
    data.patientid,
    data.patient_mrn,
    data.patient_name,
    data.sex,
    data.dob_date,
    hpv_final.was_patient_eligible_for_next_hpv_dose_at_visit,
    date_of_service,
    visitid,
    provider.provider,
    hpv_final.first_shot_date_formatted,
    hpv_final.second_shot_date_formatted,
    hpv_final.third_shot_date_formatted,
    patient_hpv_refusal.last_refusal,
    hpv_final.hpv_vaccination_complete_date,
    hpv_final.hpv_vaccination_complete,
    hpv_final.total_shots]
}

set: hpvdetail_distinct {
  fields: [
    data.patient_mrn,
    data.patient_name,
    data.sex,
    age_at_visit,
    data.dob_date,
    date_of_service,
    pcp.pcp_name,
    provider_id,
    provider.provider_name,
    location.location,
    payerid,
    payers.payer_name,
    hpv_final.first_shot_date_formatted,
    hpv_final.second_shot_date_formatted,
    hpv_final.third_shot_date_formatted,
    patient_hpv_refusal.last_refusal,
    hpv_final.hpv_status,
    hpv_final.hpv_vaccination_complete_date,
    hpv_final.hpv_vaccination_complete,
    hpv_final.total_shots]
}
}
