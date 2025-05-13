# The name of this view in Looker is "Patient Hpv Not Administered"
view: patient_hpv_not_administered {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: mhm.PatientHPV_NotAdministered ;;

  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

    # Here's what a typical dimension looks like in LookML.
    # A dimension is a groupable field that can be used to filter query results.
    # This dimension will be called "Comment Eighth Shot Not Administered" in Explore.

  dimension: comment_eighth_shot_not_administered {
    type: string
    sql: ${TABLE}.Comment_Eighth_shot_NotAdministered ;;
  }

  dimension: comment_fifth_shot_not_administered {
    type: string
    sql: ${TABLE}.Comment_Fifth_shot_NotAdministered ;;
  }

  dimension: comment_first_shot_not_administered {
    type: string
    sql: ${TABLE}.Comment_First_shot_NotAdministered ;;
  }

  dimension: comment_fourth_shot_not_administered {
    type: string
    sql: ${TABLE}.Comment_fourth_shot_NotAdministered ;;
  }

  dimension: comment_second_shot_not_administered {
    type: string
    sql: ${TABLE}.Comment_Second_shot_NotAdministered ;;
  }

  dimension: comment_seventh_shot_not_administered {
    type: string
    sql: ${TABLE}.Comment_Seventh_shot_NotAdministered ;;
  }

  dimension: comment_sixth_shot_not_administered {
    type: string
    sql: ${TABLE}.Comment_Sixth_shot_NotAdministered ;;
  }

  dimension: comment_third_shot_not_administered {
    type: string
    sql: ${TABLE}.Comment_third_shot_NotAdministered ;;
  }
  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: date_eighth_shot_not_administered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.Date_Eighth_shot_NotAdministered ;;
  }

  dimension_group: date_fifth_shot_not_administered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.Date_Fifth_shot_NotAdministered ;;
  }

  dimension_group: date_first_shot_not_administered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.Date_First_shot_NotAdministered ;;
  }

  dimension_group: date_fourth_shot_not_administered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.Date_Fourth_shot_NotAdministered ;;
  }

  dimension_group: date_second_shot_not_administered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.Date_Second_shot_NotAdministered ;;
  }

  dimension_group: date_seventh_shot_not_administered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.Date_Seventh_shot_NotAdministered ;;
  }

  dimension_group: date_sixth_shot_not_administered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.Date_Sixth_shot_NotAdministered ;;
  }

  dimension_group: date_third_shot_not_administered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.Date_Third_shot_NotAdministered ;;
  }

  dimension: patient_id {
    type: number
    sql: ${TABLE}.PatientID ;;
  }

  dimension: practice_id {
    type: number
    sql: ${TABLE}.PracticeID ;;
  }

  dimension: reason_eighth_shot_not_administered {
    type: string
    sql: ${TABLE}.Reason_Eighth_shot_NotAdministered ;;
  }

  dimension: reason_fifth_shot_not_administered {
    type: string
    sql: ${TABLE}.Reason_Fifth_shot_NotAdministered ;;
  }

  dimension: reason_first_shot_not_administered {
    type: string
    sql: ${TABLE}.Reason_First_shot_NotAdministered ;;
  }

  dimension: reason_fourth_shot_not_administered {
    type: string
    sql: ${TABLE}.Reason_fourth_shot_NotAdministered ;;
  }

  dimension: reason_second_shot_not_administered {
    type: string
    sql: ${TABLE}.Reason_Second_shot_NotAdministered ;;
  }

  dimension: reason_seventh_shot_not_administered {
    type: string
    sql: ${TABLE}.Reason_Seventh_shot_NotAdministered ;;
  }

  dimension: reason_sixth_shot_not_administered {
    type: string
    sql: ${TABLE}.Reason_Sixth_shot_NotAdministered ;;
  }

  dimension: reason_third_shot_not_administered {
    type: string
    sql: ${TABLE}.Reason_Third_shot_NotAdministered ;;
  }

  dimension: status_eighth_shot_not_administered {
    type: string
    sql: ${TABLE}.Status_Eighth_shot_NotAdministered ;;
  }

  dimension: status_fifth_shot_not_administered {
    type: string
    sql: ${TABLE}.Status_Fifth_shot_NotAdministered ;;
  }

  dimension: status_first_shot_not_administered {
    type: string
    sql: ${TABLE}.Status_First_Shot_NotAdministered ;;
  }

  dimension: status_fourth_shot_not_administered {
    type: string
    sql: ${TABLE}.Status_Fourth_shot_NotAdministered ;;
  }

  dimension: status_second_shot_not_administered {
    type: string
    sql: ${TABLE}.Status_Second_shot_NotAdministered ;;
  }

  dimension: status_seventh_shot_not_administered {
    type: string
    sql: ${TABLE}.Status_Seventh_shot_NotAdministered ;;
  }

  dimension: status_sixth_shot_not_administered {
    type: string
    sql: ${TABLE}.Status_Sixth_shot_NotAdministered ;;
  }

  dimension: status_third_shot_not_administered {
    type: string
    sql: ${TABLE}.Status_Third_shot_NotAdministered ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.Type ;;
  }
  measure: count {
    type: count
  }
}
