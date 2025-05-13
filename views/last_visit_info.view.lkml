view: last_visit_info {
  derived_table: {
    # datagroup_trigger: mhm_default_datagroup
    # indexes: ["patientid"]
    sql: select x.YearNbr, x.Practice_id, x.visitid, x.PatientID, x.VisitDate, x.ProviderID, p.Provider_Name, x.PayerID, i.Payer_Name, x.FINID, x.LocationID, l.location
          from

      (
      select *,ROW_NUMBER()over(Partition by Patientid order by VisitDate desc) Rno
      from mhm.Dos_Detail where YearNbr >=2018

      )x

      JOIN mhm.Provider AS p
      ON (x.ProviderID = p.ProviderID)

      JOIN mhm.Location AS l
      ON (x.LocationID = l.LocationID)

      JOIN mhm.Payers AS i
      ON (x.payerID = i.payerID)

      where Rno =1 ;;
  }


  dimension: year_nbr {
    type: number
    sql: ${TABLE}.YearNbr ;;
  }

  dimension: practice_id {
    type: number
    sql: ${TABLE}.Practice_id ;;
    value_format_name: id
  }

  dimension: patientid {
    primary_key: yes
    type: number
    sql: ${TABLE}.PatientID ;;
    value_format_name: id
  }

  dimension: visit_id {
    type: number
    sql: ${TABLE}.visitID ;;
    value_format_name: id
  }

  dimension: provider_id {
    type: number
    sql: ${TABLE}.ProviderID ;;
    value_format_name: id
  }

  dimension: last_provider {
    description: "Patient's last seen provider"
    type: string
    sql: ${TABLE}.Provider_Name ;;
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}.LocationID ;;
  }

  dimension: finid {
    type: number
    sql: ${TABLE}.FINID ;;
  }


  dimension: PayerID {
    type: number
    sql: ${TABLE}.PayerID ;;
    value_format_name: id
  }

  dimension: payer_name {
    type: string
    sql: CASE
          WHEN ${TABLE}.Payer_Name IS NULL THEN 'No Payer'
          ELSE
          ${TABLE}.Payer_Name
          END;;
    html:
    {% if payer_name._value == "No Payer" %}
    <div style="background-color: #ffffcc", align="left"> {{rendered_value}} </div>
    {% elsif payer_name._value == "Self Pay" %}
    <div style="background-color: #ffffcc", align="left"> {{rendered_value}} </div>
    {% else %}
    <align="left"> {{rendered_value}} </div>
    {% endif %}
    ;;
  }

  dimension: chcsct_payer_name_no_insurance {
    type: string
    sql: CASE
         WHEN ${PayerID} = '336' or
              ${PayerID} = '399' or
              ${PayerID} = '400' or
              ${PayerID} = '401' or
              ${PayerID} = '402' or
              ${PayerID} = '403' or
              ${PayerID} = '436' or
              ${PayerID} = '437' or
              ${PayerID} = '439' or
              ${PayerID} = '446' or
              ${PayerID} = '455' or
              ${PayerID} = '457' or
              ${PayerID} = '493' or
              ${PayerID} = '497' or
              ${PayerID} = '509' or
              ${PayerID} = '581' or
              ${PayerID} = '588' or
              ${PayerID} = '615' or
              ${PayerID} = '628' or
              ${PayerID} = '664' or
              ${PayerID} = '741' or
              ${PayerID} = '787' or
              ${PayerID} = '788' or
              ${PayerID} = '833' or
              ${PayerID} = '940' or
              ${PayerID} = '986' or
              ${PayerID} = '987' or
              ${PayerID} = '988' or
              ${PayerID} = '1147' or
              ${PayerID} = '1264' or
              ${PayerID} = '1304' or
              ${PayerID} = '2068' or
              ${PayerID} = '2111' or
              ${PayerID} = '2112' or
              ${PayerID} = '2113' or
              ${PayerID} = '2114' or
              ${PayerID} = '2124' or
              ${PayerID} is NULL or
              ${payers.payer_name} = 'No Payer' or
              ${PayerID} = '2109'  or  ${PayerID} = '2110' THEN 'No Insurance / Self Pay'
               ELSE
              ${payers.payer_name}
               END;;
  }

  # dimension: last_payer {
  #   description: "Patient's last payer"
  #   type: string
  #   sql: ${TABLE}.payer_name ;;
  # }

  # dimension: was_visit_in_2024 {
  #   type: yesno
  #   sql: ${last_visit_year} = '2024' ;;
  # }

  dimension: was_visit_in_2025 {
    type: yesno
    sql: Year(${last_date_of_service}) = 2025 ;;
  }

  dimension: was_visit_in_2024 {
    type: yesno
    sql: Year(${last_date_of_service}) = 2024 ;;
  }

  dimension: was_visit_in_2023 {
    type: yesno
    sql: ${last_visit_year} = '2023' ;;
  }

  measure: count_patients_2023 {
    type: count_distinct
    sql: ${patientid} ;;
    filters: {
      field: was_visit_in_2023
      value: "Yes"
    }
    drill_fields: [derived_patient_data.detail*]
  }

  measure: count_patients_2024 {
    type: count_distinct
    sql: ${patientid} ;;
    filters: {
      field: was_visit_in_2024
      value: "Yes"
    }
    drill_fields: [derived_patient_data.detail*]
  }

  measure: count_patients_2025 {
    type: count_distinct
    sql: ${patientid} ;;
    filters: {
      field: was_visit_in_2025
      value: "Yes"
    }
    drill_fields: [derived_patient_data.detail*]
  }

  dimension: last_location {
    description: "Patient's last visit location"
    type: string
    sql: ${TABLE}.Location ;;
  }

  dimension_group: last_visit {
    type: time
    hidden: yes
    timeframes: [
      raw,
      time,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.VisitDate ;;

  }

  # dimension: last_date_of_service {
  #   description: "Formatted last Visit Date (mm/dd/yyyy)"
  #   group_label: "Visit Date"
  #   type: date
  #   sql: ${last_visit_date} ;;
  #   html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  # }


  dimension: last_date_of_service {
    description: "Formatted Visit Date (mm/dd/yyyy)"
    group_label: "Visit Date"
    type: date
    sql: ${last_visit_date};;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  # dimension: last_date_of_service_checked {
  #   description: "Conversion to be sure we have no strings"
  #   type: date
  #   sql: CONVERT(DATE, ${last_date_of_service}, 101) ;;
  # }

  dimension: timeframe_since_last_visit {
    group_label: "Appointment Info"
    case: {
      when: {
        sql: ${days_since_last_visit} <= 90;;
        label: "Seen within the last 3 Months"
      }
      when: {
        sql: ${days_since_last_visit} <= 180;;
        label: "Not Seen between 3 Months and 6 Months"
      }
      when: {
        sql: ${days_since_last_visit} <= 365;;
        label: "Not Seen between 6 Months and 12 Months"
      }
      when: {
        sql: ${days_since_last_visit} <= 730;;
        label: "Not Seen between 1 Year and 2 Years"
      }
      when: {
        sql: ${days_since_last_visit} > 730;;
        label: "Not Seen in Over 2 Years"
      }
      # else: "Patient does not have an illness."
    }
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: last_date_of_service_checked {
    type: date
    sql: TRY_CONVERT(DATE, ${last_date_of_service}) ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: days_since_last_visit {
    type: number
    sql: DATEDIFF(day, ${last_date_of_service}, CAST(GETDATE() AS DATE));;
    value_format_name: id
  }

  dimension: patient_seen_within_2_years {
    description: "Patient has been seen within 2 years, is not a test patient and is not deceased"
    type: yesno
    sql: ${days_since_last_visit} <= 731 and NOT(${data.is_expired}) and (${data.is_real_patient}) ;;
  }


  # Defined outside the dimension group to allow formatting
  dimension: last_visit_date {
    hidden: yes
    type: date
    sql: ${last_visit_raw} ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }


  set: detail {
    fields: [
      derived_patient_data.sm_detail*,
      last_visit_date,
      last_location
    ]
  }
}
