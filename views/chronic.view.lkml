# The name of this view in Looker is "Chronic"
view: chronic {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: mhm.Chronic ;;

  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

    # Here's what a typical dimension looks like in LookML.
    # A dimension is a groupable field that can be used to filter query results.
    # This dimension will be called "Asthma" in Explore.

  dimension: asthma {
    type: number
    sql: ${TABLE}.Asthma ;;
  }
  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: asthma_diag {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.Asthma_Diag_date ;;
  }

  dimension: cad {
    type: number
    sql: ${TABLE}.CAD ;;
  }

  dimension_group: cad_diag {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.CAD_Diag_date ;;
  }

  dimension: chf {
    type: number
    sql: ${TABLE}.CHF ;;
  }

  dimension_group: chf_diag {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.CHF_Diag_date ;;
  }

  dimension: copd {
    type: number
    sql: ${TABLE}.COPD ;;
  }

  dimension_group: copd_diag {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.COPD_Diag_date ;;
  }

  dimension: depression {
    type: number
    sql: ${TABLE}.Depression ;;
  }

  dimension_group: depression_diag {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.Depression_Diag_date ;;
  }

  dimension: diabetes {
    type: number
    sql: ${TABLE}.Diabetes ;;
  }

  dimension_group: diabetes_diag_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.Diabetes_Diag_date ;;
  }

  dimension: hypertension {
    type: number
    sql: ${TABLE}.Hypertension ;;
  }

  dimension_group: hypertension_diag {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.Hypertension_Diag_date ;;
  }

  dimension: ivd {
    type: number
    sql: ${TABLE}.IVD ;;
  }

  dimension_group: ivd_diag {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.IVD_Diag_date ;;
  }

  dimension: liver_cancer {
    type: number
    sql: ${TABLE}.Liver_Cancer ;;
  }

  dimension_group: liver_cancer {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Liver_Cancer_date ;;
  }

  dimension: obesity {
    type: number
    sql: ${TABLE}.Obesity ;;
  }

  dimension: oldid_ind {
    type: string
    sql: ${TABLE}.oldid_ind ;;
  }

  dimension: patientid {
    type: number
    sql: ${TABLE}.PatientID ;;
  }

  dimension: practice_id {
    type: number
    sql: ${TABLE}.PracticeID ;;
  }

  dimension: pre_diabetes {
    type: number
    sql: ${TABLE}.Pre_Diabetes ;;
  }

  dimension_group: pre_diabetes_diag {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.Pre_Diabetes_Diag_date ;;
  }
  measure: count {
    type: count
  }
}
