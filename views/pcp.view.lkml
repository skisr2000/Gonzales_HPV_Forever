# The name of this view in Looker is "Pcp"
view: pcp {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: mhm.PCP ;;

  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

    # Here's what a typical dimension looks like in LookML.
    # A dimension is a groupable field that can be used to filter query results.
    # This dimension will be called "Pcp Alias" in Explore.

  dimension: pcp_alias {
    type: string
    sql: ${TABLE}.PCP_Alias ;;
  }

  dimension: pcp_name {
    type: string
    sql: ${TABLE}.PCP_Name ;;
  }

  dimension: pcpid {
    type: number
    value_format_name: id
    sql: ${TABLE}.PCPID ;;
  }
  measure: count {
    type: count
    drill_fields: [pcp_name]
  }
}
