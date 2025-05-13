# The name of this view in Looker is "Practice Payers"
view: practice_payers {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: mhm.Practice_Payers ;;

  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

    # Here's what a typical dimension looks like in LookML.
    # A dimension is a groupable field that can be used to filter query results.
    # This dimension will be called "Insclass" in Explore.

  dimension: insclass {
    type: string
    sql: ${TABLE}.insclass ;;
  }

  dimension: payer_id {
    type: number
    sql: ${TABLE}.PayerID ;;
  }

  dimension: payer_name {
    type: string
    sql: ${TABLE}.Payer_Name ;;
  }

  dimension: practiceid {
    type: number
    value_format_name: id
    sql: ${TABLE}.Practiceid ;;
  }
  measure: count {
    type: count
    drill_fields: [payer_name]
  }
}
