# The name of this view in Looker is "Location"
view: location {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: mhm.Location ;;

  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

    # Here's what a typical dimension looks like in LookML.
    # A dimension is a groupable field that can be used to filter query results.
    # This dimension will be called "Combined Location" in Explore.

  dimension: combined_location {
    type: string
    sql: ${TABLE}.Combined_Location ;;
  }

  dimension: county {
    type: string
    sql: ${TABLE}.County ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}.Location ;;
  }

  dimension: location_alias {
    type: string
    sql: ${TABLE}.Location_Alias ;;
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}.LocationID ;;
  }
  measure: count {
    type: count
  }
}
