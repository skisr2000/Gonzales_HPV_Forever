view: provider {
  sql_table_name:mhm.Provider ;;

  dimension: npi {
    type: string
    sql: ${TABLE}.npi ;;
  }

  dimension: provider_id {
    primary_key: yes
    hidden: no
    type: number
    sql: ${TABLE}.ProviderID ;;
    value_format_name: id
  }

  dimension: provider_alias {
    type: string
    sql: ${TABLE}.provider_alias ;;
  }

  dimension: provider_first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: provider_last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: provider_middle_name {
    type: string
    sql: ${TABLE}.middle_name ;;
  }

  dimension: provider_name_last_name_first {
    type: string
    # middle name most likely will say No Provider Given
    sql: CASE
           WHEN ${provider_last_name} = '' and ${provider_first_name} =''
            THEN ${provider_middle_name}
           WHEN ${provider_last_name} IS NOT NULL
            THEN concat(${provider_last_name},', ',${provider_first_name})
          ELSE
            'Unknown'
          END;;
  }

  dimension: provider_name {
    type: string
    sql: {% if _user_attributes['demo'] == 1 %}
          ${TABLE}.provider_alias
        {% elsif _user_attributes['mhmid'] == 1 %}
         ${TABLE}.provider_name
        {% else %}
         Concat('Provider ID - ',${TABLE}.providerid)
        {% endif %} ;;
  }

}
