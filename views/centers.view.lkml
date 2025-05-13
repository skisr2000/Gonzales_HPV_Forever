# The name of this view in Looker is "Centers"
view: centers {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: mhm.Centers ;;

  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

    # Here's what a typical dimension looks like in LookML.
    # A dimension is a groupable field that can be used to filter query results.
    # This dimension will be called "Center" in Explore.

  dimension: center {
    type: string
    sql: ${TABLE}.Center ;;
  }

  dimension: center_alias {
    type: string
    sql: ${TABLE}.Center_Alias ;;
  }

  dimension: center_nickname {
    type: string
    sql: ${TABLE}.Center_nickname ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.City ;;
  }

  dimension: city_alias {
    type: string
    sql: ${TABLE}.City_Alias ;;
  }

  dimension: fqhcid {
    type: string
    sql: ${TABLE}.FQHCID ;;
  }

  dimension: payer_id {
    type: number
    sql: ${TABLE}.PayerID ;;
  }

  dimension: practice_id {
    type: number
    sql: ${TABLE}.PracticeID ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.State ;;
  }

  dimension: state_alias {
    type: string
    sql: ${TABLE}.State_Alias ;;
  }

  dimension: street {
    type: string
    sql: ${TABLE}.Street ;;
  }

  dimension: street_alias {
    type: string
    sql: ${TABLE}.Street_Alias ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}.Zip ;;
  }

  dimension: zip_alias {
    type: string
    sql: ${TABLE}.Zip_Alias ;;
  }
  measure: count {
    type: count
    drill_fields: [center_nickname]
  }
}
