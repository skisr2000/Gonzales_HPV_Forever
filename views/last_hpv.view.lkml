view: last_hpv {
  derived_table: {
    sql: select YearNbr, Practice_id, PatientID, VisitDate, ProviderID, LocationID, FINID, Create_Date, Type, Value, DOS_Detail_ID
            from
            (
            select *,ROW_NUMBER()over(Partition by Patientid order by visitdate desc) Rno

      from mhm.Dos_Detail where Type like '%HPV%'
      )x where Rno =1
      ;;
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

  dimension_group: visit {
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
    sql: ${TABLE}.VisitDate ;;
  }

  dimension: last_hpv_date_format {
    sql: ${visit_date} ;;
    html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
  }

  dimension: days_since_last_hpv {
    type: number
    sql: CAST(DATEDIFF(day,${visit_date},getdate()) AS INTEGER) ;;
    html: <div align="center"> {{rendered_value}} </div> ;;
  }

  dimension: provider_id {
    type: number
    sql: ${TABLE}.ProviderID ;;
    value_format_name: id
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}.LocationID ;;
  }

  dimension: finid {
    type: number
    sql: ${TABLE}.FINID ;;
  }

  dimension_group: create {
    type: time
    hidden:  yes
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.Create_Date ;;

  }

  dimension: type {
    type: string
    sql: ${TABLE}.Type ;;
  }

  dimension: value {
    type: number
    sql: ${TABLE}.Value ;;
  }

  dimension: dos_detail_id {
    type: number
    sql: ${TABLE}.DOS_Detail_ID ;;
    value_format_name: id
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: count_doses_provided_last_wk{
    type:count
    filters: {
      field: visit_date
      value: "last week"
    }
    drill_fields: [detail*]
  }

  dimension: has_missing_hpv_test {
    label:  "Has Missing HPV Test"
    type: yesno
    sql: COALESCE(${value},0) = 0;;
  }

  measure: patients_who_had_HPV {
    type: count
    filters: {
      field: has_missing_hpv_test
      value: "no"
    }
    drill_fields: [detail*]
  }

  measure: hpv_gaps {
    type: count
    filters: {
      field: has_missing_hpv_test
      value: "yes"
    }
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      data.sm_detail*,
      data.blood_pressure,
      data.current_phq9_score,
      data.hba1c_current,
      visit_date,
      type,
      value
    ]
  }
}
