view: patient_problem_list {
  derived_table: {
    # datagroup_trigger: mhm_default_datagroup
    # indexes: ["patientid"]
    sql: select practiceid, patientid, code, code_description, code_type, dos_onset_date, dos_resolved_date, dx1, dx2, dx3, dx4, finid,  mhm.Patient_ProblemList.locationid, mhm.location.location, mhm.Patient_ProblemList.payerid, mhm.Payers.Payer_name, ProblemListID, providerid, visitid
      FROM mhm.Patient_ProblemList
      Left Join mhm.location on mhm.Patient_ProblemList.locationid = mhm.location.locationid
      Left Join mhm.Payers on mhm.Patient_ProblemList.payerid = mhm.Payers.PayerID;;

    # select practiceid, patientid, code, code_description, code_type, dos_onset_date, dos_resolved_date, dx1, dx2, dx3, dx4, finid,  mhm.Patient_ProblemList.locationid, mhm.location.location, payerid, ProblemListID, providerid, visitid
    # FROM mhm.Patient_ProblemList
    # Inner Join mhm.location on mhm.Patient_ProblemList.locationid = mhm.location.locationid;;
  }

  dimension_group: dos_resolved {
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
    sql: ${TABLE}.DOS_Resolved_Date ;;
  }

  dimension: patientid {
    type: number
    sql: ${TABLE}.PatientID ;;
    value_format_name: id
  }

  dimension: practice_id {
    type: number
    sql: ${TABLE}.PracticeID ;;
    value_format_name: id
  }

  dimension: financial_id {
    type: number
    sql: ${TABLE}.FinID ;;
    value_format_name: id
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}.locationID ;;
    value_format_name: id
  }

  dimension: locationid {
    type: string
    sql: CAST(${location_id} as VARCHAR(5) ;;
  }

  dimension: problem_list_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.ProblemListID ;;
    value_format_name: id
  }

  dimension: code {
    type: string
    sql: ${TABLE}.Code ;;

    html:
    <div align="center"> {{rendered_value}} </div>
    ;;

  }

  dimension: location {
    type: string
    sql: ${TABLE}.location ;;
  }

  dimension: HPV_Cancer_Screen{
    type: yesno
    sql:  ${code}='87624'or
            ${code}='87625'

      ;;
    html:
          <div align="center"> {{rendered_value}} </div>
          ;;
  }

  dimension: Pap_Test{
    type: yesno
    sql:  ${code}='88175'

                    ;;
    html:
          <div align="center"> {{rendered_value}} </div>
          ;;
  }

  dimension: code_description {
    type: string
    sql: ${TABLE}.Code_Description ;;
  }

  dimension: code_type {
    type: string
    sql: ${TABLE}.Code_Type ;;
  }

  dimension: payerid {
    type: number
    value_format_name: id
    sql: ${TABLE}.PayerID ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: dx1 {
    type: string
    sql: ${TABLE}.dx1 ;;
    html:
    <div align="left"> {{rendered_value}} </div>
    ;;
  }

  dimension: has_visit_icd_asthma {
    label: "Patient has a Asthma ICD10 code during visit"
    description: "J45.-"
    type:  yesno
    sql:    ${dx_codes} like '%j45%' ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: has_visit_icd_copd {
    label: "Patient has a COPD ICD10 code during visit"
    description: "J44.0, J44.1 or J44.9"
    type:  yesno
    sql:    ${dx_codes} like '%j44.0%' or
            ${dx_codes} like '%j44.1%' or
            ${dx_codes} like '%j44.9%' ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: has_visit_icd_diabetes {
    label: "Patient has a Diabetes ICD10 code during visit"
    description: "E08-, E09-, E11 through E13"
    type:  yesno
    sql:    ${dx_codes} like '%E08%' or
            ${dx_codes} like '%E09%' or
            ${dx_codes} like '%E11%' or
            ${dx_codes} like '%E12%' or
            ${dx_codes} like '%E13%' ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: has_visit_icd_hypertension {
    label: "Patient has a Hypertension ICD10 code during visit"
    description: "I10- through I16-, O10-, O11-"
    type:  yesno
    sql:    ${dx_codes} like '%I10%' or
            ${dx_codes} like '%I11%' or
            ${dx_codes} like '%I12%' or
            ${dx_codes} like '%I13%' or
            ${dx_codes} like '%I14%' or
            ${dx_codes} like '%I15%' or
            ${dx_codes} like '%I16%';;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: has_visit_icd_hypertension_chcsct {
    label: "Patient has a Hypertension ICD10 code"
    description: "I10- through I15"
    type:  yesno
    sql:    ${dx_codes} like '%I10%' or
            ${dx_codes} like '%I11%' or
            ${dx_codes} like '%I12%' or
            ${dx_codes} like '%I13%' or
            ${dx_codes} like '%I14%' or
            ${dx_codes} like '%I15%';;
    html:
          <div align="center"> {{rendered_value}} </div>
          ;;
  }

  measure: count_chcsct_hypertension_encounters {
    type: count
    filters: {
      field: has_visit_icd_hypertension_chcsct
      value: "Yes"
    }

    html:
          <div align="center"> {{rendered_value}} </div>
          ;;

  }

  dimension: has_visit_icd_hypertension_uds {
    label: "UDS - has a Hypertension ICD10 code during visit"
    description: "I10- through I16-, O10-, O11-"
    type:  yesno
    sql:    ${dx_codes} like 'I10%' or
            ${dx_codes} like 'I11%' or
            ${dx_codes} like 'I12%' or
            ${dx_codes} like 'I13%' or
            ${dx_codes} like 'I14%' or
            ${dx_codes} like 'I15%' or
            ${dx_codes} like 'I16%' or
            ${dx_codes} like 'O10%' or
            ${dx_codes} like 'O11%';;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: has_visit_icd_pap {
    label: "Patient has a Pap Smear ICD10 code during visit"
    description: "Z01.41, Z01.42, Z12.4, Z11.51"
    type:  yesno
    sql:    ${dx_codes} like '%Z01.41%' or
            ${dx_codes} like '%Z01.42%' or
            ${dx_codes} like '%Z01.4%' or
            ${dx_codes} like '%Z11.51%' ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: has_visit_cpt_pap {
    label: "Patient has a Pap Smear CPT code during visit"
    description: "88141-88153, 88155, 88164-88167, 88174-88175"
    type:  yesno
    sql:    ${code} = '88141' or
            ${code} = '88142' or
            ${code} = '88143' or
            ${code} = '88144' or
            ${code} = '88145' or
            ${code} = '88146' or
            ${code} = '88147' or
            ${code} = '88148' or
            ${code} = '88149' or
            ${code} = '88150' or
            ${code} = '88151' or
            ${code} = '88152' or
            ${code} = '88153' or
            ${code} = '88155' or
            ${code} = '88164' or
            ${code} = '88165' or
            ${code} = '88166' or
            ${code} = '88167' or
            ${code} = '88174' or
            ${code} = '88175' ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: has_visit_icd_colorectal {
    label: "Patient has a Colorectal Cancer Screen ICD10 code during visit"
    description: "Z12.11, Z12.12"
    type:  yesno
    sql:    ${dx_codes} = 'Z12.11' or
      ${dx_codes} = 'Z12.12' ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: has_visit_cpt_colerectal {
    label: "Patient has a Colorectal Cancer Screen during visit"
    description: "45378-45398, G0105, G0121, 81528"
    type:  yesno
    sql:    ${code} = '45378' or
            ${code} = '45379' or
            ${code} = '45390' or
            ${code} = '45391' or
            ${code} = '45392' or
            ${code} = '45393' or
            ${code} = '45394' or
            ${code} = '45395' or
            ${code} = '45396' or
            ${code} = '45397' or
            ${code} = '45398' or
            ${code} like '%4538%' or
            ${code} = 'G0105' or
            ${code} = 'G0121' or
            ${code} = '81528' ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: has_well_child_exam {
    label: "Patient has a Well Child ICD10 code during visit"
    description: "Z00.1-"
    type:  yesno
    sql:    ${dx_codes} like '%Z00.1%';;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }


  dimension: dx2 {
    type: string
    sql: ${TABLE}.dx2 ;;
    html:
    <div align="left"> {{rendered_value}} </div>
    ;;
  }



  dimension: dx3 {
    type: string
    sql: ${TABLE}.dx3 ;;
    html:
    <div align="left"> {{rendered_value}} </div>
    ;;
  }


  dimension: dx4 {
    type: string
    sql: ${TABLE}.dx4 ;;
    html:
    <div align="left"> {{rendered_value}} </div>
    ;;

  }

  dimension: dx_codes {
    type: string
    sql: CASE
          WHEN ${practice_id} = 1016 THEN ${code}
          WHEN ${dx2} IS NULL THEN ${dx1}
          WHEN ${dx3} IS NULL THEN ${dx1}+' and '+${dx2}
          WHEN ${dx4} IS NULL THEN ${dx1}+', '+${dx2}+' and '+${dx3}
          ELSE ${dx1}+', '+${dx2}+', '+${dx3}+' and '+${dx4}
         END
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

  dimension: providerid {
    type: number
    sql: ${TABLE}.ProviderID ;;
    value_format_name: id
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: provider {
    type: string
    sql: ${provider.provider_name} ;;
    html:
    <div align="left"> {{rendered_value}} </div>
    ;;
  }


  dimension_group: encounter {
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
    sql: ${TABLE}.DOS_Onset_Date ;;

    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: is_encounter_in_2019{
    type: yesno
    sql: ${encounter_year} = '2019' ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: is_encounter_in_2020{
    type: yesno
    sql: ${encounter_year} = '2020' ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: is_encounter_in_2021{
    type: yesno
    sql: ${encounter_year} = '2021' ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: is_encounter_in_2022{
    type: yesno
    sql: ${encounter_year} = '2022' ;;
    html:
          <div align="center"> {{rendered_value}} </div>
          ;;
  }

  dimension: is_encounter_in_2023{
    type: yesno
    sql: ${encounter_year} = '2023' ;;
    html:
          <div align="center"> {{rendered_value}} </div>
          ;;
  }


  dimension: has_EM_encounter_in_2020{
    type: yesno
    sql:  (${code}='99201'or
          ${code}='99202'or
          ${code}='99203'or
          ${code}='99204'or
          ${code}='99205'or
          ${code}='99211'or
          ${code}='99212'or
          ${code}='99213'or
          ${code}='99214'or
          ${code}='99215') and
          ${encounter_year} = '2020' ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: has_EM_encounter_in_2021{
    type: yesno
    sql:  (${code}='99201'or
          ${code}='99202'or
          ${code}='99203'or
          ${code}='99204'or
          ${code}='99205'or
          ${code}='99211'or
          ${code}='99212'or
          ${code}='99213'or
          ${code}='99214'or
          ${code}='99215') and
          ${encounter_year} = '2021' ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: has_history_of_awv{
    description: "Has patient had an AWV"
    type: yesno
    sql:  ${code}='G0438'or
          ${code}='G0439'
    ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }


  dimension: age_at_encounter  {
    type:  number
    sql:  CASE
            WHEN (MONTH(${encounter_date})*100)+DAY(${encounter_date}) >= (MONTH(${data.dob_date})*100)+DAY(${data.dob_date}) THEN
            DATEDIFF(Year,${data.dob_date},${encounter_date})
            ELSE DATEDIFF(Year,${data.dob_date},${encounter_date})-1
            END
            ;;
    html:
     <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: was_patient_18_or_over_at_time_of_encounter{
    type: yesno
    sql:  ${age_at_encounter}>=18 ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }


  measure: first_encounter_date {
    type: date
    sql:  MIN(${encounter_date}) ;;
    convert_tz: no
    html:
      <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
      ;;
  }

  measure: last_encounter_date {
    type: date
    sql:  MAX(${encounter_date}) ;;
    convert_tz: no
    html:
      <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
      ;;
  }

  dimension: encounter_format {
    sql: ${encounter_date} ;;
    html:
    <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
    ;;
  }

  filter: measurement_period {
    description: "Choose dates to see if patient presented in the measurement period"
    hidden: no
    type: date
  }

  dimension: group_measurement_yesno {
    hidden: no
    type: yesno
    sql: {% condition measurement_period %} ${encounter_date} {% endcondition %} ;;
  }

  # dimension: locationlist {
  #   type: string
  #   sql:  distinct(${locationid}) + ', ' FOR XML PATH('');;
  # }

  dimension: location_in_timeframe_yesno{
    type: string
    sql: CASE
        WHEN ${group_measurement_yesno} THEN ${location_id}
        ELSE ''
        END;;
  }

  dimension: locationlist {
    type: string
    sql:  lower(${location_in_timeframe_yesno});;
  }


  #     SELECT distinct(cast(locationid as varchar(5))) + ', ' AS 'data()'
# FROM mhm.Patient_ProblemList where patientid = 1003466385 and dos_onset_date >= cast('2023-07-20'as DATE)
# FOR XML PATH('')



  dimension: HPV_first_dose_in_timefame_yesno {
    hidden: no
    type: yesno
    sql: {% condition measurement_period %} ${patient_hpv.date_first_shot_date} {% endcondition %} ;;
  }

  dimension: HPV_second_dose_in_timefame_yesno {
    hidden: no
    type: yesno
    sql: {% condition measurement_period %} ${patient_hpv.date_second_shot_date} {% endcondition %} ;;
  }

  dimension: HPV_third_dose_in_timefame_yesno {
    hidden: no
    type: yesno
    sql: {% condition measurement_period %} ${patient_hpv.date_third_shot_date} {% endcondition %} ;;
  }

  dimension: HPV_fourth_dose_in_timefame_yesno {
    hidden: no
    type: yesno
    sql: {% condition measurement_period %} ${patient_hpv.date_fourth_shot_date} {% endcondition %} ;;
  }

  dimension: HPV_fifth_dose_in_timefame_yesno {
    hidden: no
    type: yesno
    sql: {% condition measurement_period %} ${patient_hpv.date_fifth_shot_date} {% endcondition %} ;;
  }

  dimension: last_dose_in_timeframe {
    type: yesno
    sql: {% condition measurement_period %} ${patient_hpv.last_dose} {% endcondition %};;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: hpv_dose_1_in_timeframe{
    type: string
    sql: CASE
        WHEN ${HPV_first_dose_in_timefame_yesno} THEN ${patient_hpv.first_shot}
        ELSE ''
        END;;
  }

  dimension: hpv_dose_2_in_timeframe{
    type: string
    sql: CASE
        WHEN ${HPV_second_dose_in_timefame_yesno} THEN ${patient_hpv.second_shot}
        ELSE ''
        END;;
  }

  dimension: hpv_dose_3_in_timeframe{
    type: string
    sql: CASE
        WHEN ${HPV_third_dose_in_timefame_yesno} THEN ${patient_hpv.third_shot}
        ELSE ''
        END;;
  }

  dimension: hpv_dose_4_in_timeframe{
    type: string
    sql: CASE
        WHEN ${HPV_fourth_dose_in_timefame_yesno} THEN ${patient_hpv.fourth_shot}
        ELSE ''
        END;;
  }

  dimension: hpv_dose_5_in_timeframe{
    type: string
    sql: CASE
        WHEN ${HPV_fifth_dose_in_timefame_yesno} THEN ${patient_hpv.fifth_shot}
        ELSE ''
        END;;
  }

  # dimension: hpv_doses_in_timeframe{
  #   type: string
  #   sql: CASE
  #     WHEN ${hpv_dose_1_in_timeframe} = '' and ${hpv_dose_2_in_timeframe} = '' and ${hpv_dose_3_in_timeframe} = '' and ${hpv_dose_4_in_timeframe} = '' and ${hpv_dose_5_in_timeframe} = ''THEN 'No Doses in Timeframe'
  #     ELSE 'Doses in Timeframe: '+${hpv_dose_1_in_timeframe}+' '+${hpv_dose_2_in_timeframe}+' '+${hpv_dose_3_in_timeframe}+' '+${hpv_dose_4_in_timeframe}+' '+${hpv_dose_5_in_timeframe}
  #     END;;
  # }


  dimension: hpv_doses_in_timeframe{
    type: string
    sql:  STUFF(
              ISNULL(',' + CASE WHEN ${hpv_dose_1_in_timeframe}= '' THEN NULL ELSE + ' 1st Dose: '+${hpv_dose_1_in_timeframe} END, '') +
              ISNULL(',' + CASE WHEN ${hpv_dose_2_in_timeframe}= '' THEN NULL ELSE + ' 2nd Dose: '+${hpv_dose_2_in_timeframe} END, '') +
              ISNULL(',' + CASE WHEN ${hpv_dose_3_in_timeframe}= '' THEN NULL ELSE + ' 3rd Dose: '+${hpv_dose_3_in_timeframe} END, '') +
              ISNULL(',' + CASE WHEN ${hpv_dose_4_in_timeframe}= '' THEN NULL ELSE + ' 4th Dose: '+${hpv_dose_4_in_timeframe} END, '') +
              ISNULL(',' + CASE WHEN ${hpv_dose_5_in_timeframe}= '' THEN NULL ELSE + ' 5th Dose: '+${hpv_dose_5_in_timeframe} END, ''),1,1,'')
      ;;

  }


# and ${HPV_fourth_dose_in_timefame_yesno} = 'no' and ${HPV_third_dose_in_timefame_yesno} = 'no' and ${HPV_second_dose_in_timefame_yesno} = 'no' and ${HPV_first_dose_in_timefame_yesno} = 'no'
# WHEN ${HPV_fifth_dose_in_timefame_yesno} = 'no' and ${HPV_fourth_dose_in_timefame_yesno} = 'no' and ${HPV_third_dose_in_timefame_yesno} = 'no' and ${HPV_second_dose_in_timefame_yesno} = 'no' and ${HPV_first_dose_in_timefame_yesno} = 'yes'
#               THEN '1st dose on '+${derived_patient_hpv_final.first_shot_date_formatted}

  ## filtered measurement period
  measure: count_measurement {
    type: count
    filters: [group_measurement_yesno: "yes"]
    drill_fields: [detail_hpv_hx*]
    # link: {
    #   label: "Patient Encounters in Timeline"
    #   url: "/looks/https://affinitihealth.looker.com/looks/1632?&f[commonly_used_fields.patientid]={{ _filters['commonly_used_fields.patientid'] | url_encode }}"
    # }
  }

  # measure: count_appointments {
  #   type: count
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

  measure: count_measurement_visits{
    description: "How many visits in measuring period"
    type: count_distinct
    sql: ${visitid} ;;
    filters: {
      field: group_measurement_yesno
      value: "Yes"
    }
    drill_fields: [detail_hpv_hx*]
  }


  dimension: E_M_or_Counseling_visit{
    type: yesno
    sql:  ${code}='99201'or
          ${code}='99202'or
          ${code}='99203'or
          ${code}='99204'or
          ${code}='99205'or
          ${code}='99212'or
          ${code}='99213'or
          ${code}='99214'or
          ${code}='99215'or
          ${code}='99443'or
          ${code}='96151'or
          ${code}='96152'or
          ${code}='96156'or
          ${code}='96158'or
          ${code}='96159'or
          ${code}='99384'or
          ${code}='99385'or
          ${code}='99386'or
          ${code}='99387'or
          ${code}='99394'or
          ${code}='99395'or
          ${code}='99396'or
          ${code}='99397'or
          ${code}='90791'or
          ${code}='90832'or
          ${code}='90834'or
          ${code}='90837'


      ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: E_M_visit{
    type: yesno
    sql:  ${code}='99201'or
          ${code}='99202'or
          ${code}='99203'or
          ${code}='99204'or
          ${code}='99205'or
          ${code}='99211'or
          ${code}='99212'or
          ${code}='99213'or
          ${code}='99214'or
          ${code}='99215'

      ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }


  measure: count_distinct_visits_2019 {
    type: count_distinct
    sql: ${encounter_date};;
    filters: {
      field: is_encounter_in_2019
      value: "Yes"
    }
    drill_fields: [patientid, data.patient_name, encounter_format, payerid, code, code_description]

    html:
    <div align="center"> {{rendered_value}} </div>
    ;;

  }

  measure: count_distinct_visits {
    type: count_distinct
    sql: ${patientid};;

    drill_fields: [patientid, data.patient_name, encounter_format, payerid, code, code_description]

    html:
    <div align="center"> {{rendered_value}} </div>
    ;;

  }

  measure: count_distinct_encounters {
    type: count_distinct
    sql: ${visitid};;

    drill_fields: [patientid, data.patient_name, encounter_format]

    html:
    <div align="center"> {{rendered_value}} </div>
    ;;

  }

  measure: count_distinct_encounters_2020 {
    type: count_distinct
    sql: ${patientid};;
    filters: {
      field: is_encounter_in_2020
      value: "Yes"
    }
    drill_fields: [patientid, data.patient_name, encounter_format, payers.payer_name, code, code_description]

    html:
    <div align="center"> {{rendered_value}} </div>
    ;;

  }

  measure: count_distinct_encounters_2021 {
    type: count_distinct
    sql: ${patientid};;
    filters: {
      field: is_encounter_in_2021
      value: "Yes"
    }
    drill_fields: [patientid, data.patient_name, encounter_format, payers.payer_name, code, code_description]

    html:
    <div align="center"> {{rendered_value}} </div>
    ;;

  }

  measure: count_distinct_encounters_2022 {
    type: count_distinct
    sql: ${patientid};;
    filters: {
      field: is_encounter_in_2022
      value: "Yes"
    }
    drill_fields: [patientid, data.patient_name, encounter_format, payers.payer_name, code, code_description]

    html:
          <div align="center"> {{rendered_value}} </div>
          ;;

  }

  measure: count_distinct_encounters_2023 {
    type: count_distinct
    sql: ${patientid};;
    filters: {
      field: is_encounter_in_2023
      value: "Yes"
    }
    drill_fields: [patientid, data.patient_name, encounter_format, payers.payer_name, code, code_description]

    html:
          <div align="center"> {{rendered_value}} </div>
          ;;

  }

  measure: count_distinct_patients_with_visits {
    type: count_distinct
    sql: ${patientid};;
    drill_fields: [patientid, data.patient_name, encounter_format, code, code_description]
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  dimension: was_PHQ_performed_at_encounter{
    type: yesno
    sql: (${dos_detail.type} = 'PHQ9_Score' or ${dos_detail.type} = 'PHQ2_Score') and ${visitid} = ${dos_detail.visitid} ;;
    drill_fields: [encounter_date, data.patient_name, dos_detail.type]
  }


  measure: count_patients_with_PHQ_test{
    type: count_distinct
    sql: ${patientid} ;;
    filters: {
      field:  was_PHQ_performed_at_encounter
      value: "yes"
    }
    drill_fields: [patientid, data.patient_name, data.patient_mrn, data.patient_age, encounter_date, visitid, dos_detail.type, dos_detail.value, location.location, provider.provider_name ]
  }

  measure: count_patients_with_NO_PHQ_test{
    type: count_distinct
    sql: ${patientid} ;;
    filters: {
      field:  was_PHQ_performed_at_encounter
      value: "no"
    }
    drill_fields: [patientid, data.patient_name, data.patient_mrn, data.patient_age, encounter_date, visitid, location.location, provider.provider_name]
  }


  dimension: PCMH_visit{
    type: yesno
    sql:
            (
            ${payers.payer_name} like 'PHC%' or
            ${payers.payer_name} like '%MHM%' or
            ${payers.payer_name} like '%Self%' or
            ${payers.payer_name} like '%Methodist Healthcare Ministries%' or
            ${payerid} IS NULL
          ) and
          ( ${location_id} = 264 or
            ${location_id} = 259 or
            ${location_id} = 253 or
            ${location_id} = 266 or
            ${location_id} = 254 or
            ${location_id} = 268 or
            ${location_id} = 372 or
            ${location_id} = 380
          ) and

      ${age_at_encounter}>=18

      ;;
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;

  }

  dimension: PCMH_location{
    sql: CASE
          WHEN ${location_id} = 253 THEN 'El Indio Clinic'
          WHEN ${location_id} = 254 THEN 'Eidson Rd Clinic'
          WHEN ${location_id} = 259 THEN 'United Medical Centers 4'
          WHEN ${location_id} = 264 THEN 'United Medical Centers 1'
          WHEN ${location_id} = 266 THEN 'San Felipe Health Center'
          WHEN ${location_id} = 268 THEN 'Bedell Ave Clinic'
          WHEN ${location_id} = 372 THEN 'East Academy Clinic'
          WHEN ${location_id} = 380 THEN 'United Medical Centers #2'
          ELSE
          ${location}
          END;;
  }

  measure: PCMH_patients_with_visits_denominator {
    description: "To get appropriate year, The year must be chosen in the Filters"
    type: count_distinct
    sql:  ${patientid};;

    filters: {
      field: PCMH_visit
      value: "Yes"
    }

    drill_fields: [patients_with_encounters*]
    link: {
      label: "See up to 5,000 Results"
      url: "{{ link }}&limit=5000"
    }

    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
  }

  # measure: PCMH_patients_with_visits_numerator {
  #   description: "To get appropriate year, The year must be chosen in the Filters"
  #   type: count_distinct
  #   sql:  ${patientid};;

  #   filters: {
  #     field: PCMH_visit
  #     value: "Yes"
  #   }
  #   filters: {
  #     field: chronic.has_2_of_4_depression_or_diabetes_or_prediabetes_or_hypertension
  #     value: "Yes"
  #   }
  #   html:
  #   <div align="center"> {{rendered_value}} </div>
  #   ;;
  # }

  # measure: PCMH_patients_with_visits_numerator_uncontrolled_patients {
  #   label: "PCMH numerator list with 2 of depression, uncontrolled diabetics or uncontrolled hypertension"
  #   description: "To get appropriate year, The year must be chosen in the Filters"
  #   type: count_distinct
  #   sql:  ${patientid};;

  #   filters: {
  #     field: PCMH_visit
  #     value: "Yes"
  #   }
  #   filters: {
  #     field: chronic.has_2_of_3_depression_or_uncontrolled_diabetes_or_uncontrolled_hypertension
  #     value: "Yes"
  #   }

  # drill_fields: [patients_with_encounters*]
  # link: {
  #   label: "See up to 5,000 Results"
  #   url: "{{ link }}&limit=5000"
  # }

  #   html:
  #   <div align="center"> {{rendered_value}} </div>
  #   ;;
  # }

  measure: count_distinct_patients_with_visits_UDS {
    type: count_distinct
    sql: ${patientid};;

    drill_fields: [patientid, data.patient_name, has_EM_encounter_in_2020, data.last_appointment, last_BMI.result]

    html:
    <div align="center"> {{rendered_value}} </div>
    ;;

  }

  # measure: count_distinct_patients_with_high_risk_pregnancy_medical{
  #   label: "High Risk Pregnancy Visits - Medical"
  #   type: count
  #   filters: {
  #     field: rmoms_high_risk_preg_medical
  #     value: "Yes"
  #   }
  #   drill_fields: [patientid, data.patient_name, encounter_date, dx_codes, rmoms_dx1_value]

  #   html:
  #   <div align="center"> {{rendered_value}} </div>
  #   ;;

  # }

  # measure: count_distinct_patients_with_high_risk_pregnancy_age{
  #   label: "High Risk Pregnancy Visits - Age"
  #   type: count
  #   filters: {
  #     field: rmoms_high_risk_preg_age
  #     value: "Yes"
  #   }
  #   drill_fields: [patientid, data.patient_name, encounter_date, dx_codes, rmoms_dx1_value]

  #   html:
  #   <div align="center"> {{rendered_value}} </div>
  #   ;;

  # }

  # measure: count_distinct_patients_with_first_tri_visit{
  #   label: "First Trimester Pregnancy Visits"
  #   type: count_distinct
  #   sql: ${visitid} ;;
  #   filters: {
  #     field: rmoms_first_tri_visit
  #     value: "Yes"
  #   }
  #   drill_fields: [patientid, data.patient_name, encounter_date, dx_codes, code, rmoms_dx1_value]

  #   html:
  #   <div align="center"> {{rendered_value}} </div>
  #   ;;

  # }

  # measure: count_distinct_patients_with_multiple_pregnancy{
  #   label: "Pregnancy with Twins"
  #   type: count
  #   filters: {
  #     field: rmoms_twin_preg
  #     value: "Yes"
  #   }

  #   drill_fields: [patientid, data.patient_name, encounter_date, dx_codes, rmoms_dx1_value]

  #   html:
  #   <div align="center"> {{rendered_value}} </div>
  #   ;;

  # }

  # measure: count_distinct_patients_with_pre_natal_visit{
  #   label: "Prenatal Visits"
  #   type: count
  #   filters: {
  #     field: rmoms_prenatal_flag
  #     value: "Yes"
  #   }
  #   drill_fields: [patientid, data.patient_name, encounter_date, dx_codes, rmoms_dx1_value]

  #   html:
  #   <div align="center"> {{rendered_value}} </div>
  #   ;;

  # }

  # measure: count_distinct_patients_with_postpartum_visit{
  #   label: "Postpartnum Visits"
  #   type: count_distinct
  #   sql: ${visitid} ;;
  #   filters: {
  #     field: rmoms_postpartum_flag
  #     value: "Yes"
  #   }
  #   drill_fields: [patientid, derived_patient_data.patient_name, E_M_visit, encounter_date, visitid, code, dx_codes, rmoms_dx1_value]

  #   html:
  #   <div align="center"> {{rendered_value}} </div>
  #   ;;

  # }

  measure: count_encounters {
    type: count_distinct
    sql: ${visitid} ;;
  }


  measure: count {
    type: count
    drill_fields: [patientid, data.patient_name, E_M_visit, encounter_date, visitid, code, dx_codes, payers.payer_name, financial_plans.fin_class ]
  }


  set: patients_with_encounters {
    fields: [patientid,
      data.patient_name,
      data.pat_mrn,
      data.patient_age,
      encounter_format,
      provider.provider_name,
      payers.payer_name,
      financial_plans.fin_class,
      code,
      code_description]
  }


  set: detail_hpv_hx {
    fields: [
      encounter_format,
      visitid,
      data.patient_name,
      provider.provider_name,
      payers.payer_name,
      location.location,
      age_at_encounter
    ]
  }
}
