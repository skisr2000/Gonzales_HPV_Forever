view: patient_hpv {
  sql_table_name: mhm.PatientHPV ;;

  dimension: todays_date_vs_next_appt{
    type: number
    sql:  DATEDIFF( day, getdate(), ${data.next_appointment_date}) ;;
  }

# *****************This is where the new HPV dimensions and measures begin - not deployed as of 6-27-19*************

  filter: timeframe_filter {
    type: date
  }

  filter: age_filter {
    type: number
  }

  dimension:  visit_time_frame {
    type: yesno
    sql: {% condition timeframe_filter %} ${dos_detail.visit_date} {% endcondition %}   ;;
  }

  dimension:  completion_time_frame {
    type: yesno
    sql: {% condition timeframe_filter %} ${HPV_vaccination_complete_date_date} {% endcondition %}   ;;
  }

  dimension: is_patient_hpv_age_eligible_in_timeframe {
    type: yesno
    sql: ({% condition age_filter %} ${dos_detail.age_at_visit} {% endcondition %}
      ;;
  }

#     >= 9  and
#     {% condition age_filter %} ${dos_detail.age_at_visit} {% endcondition %} <= 26 and ${data.sex}='F') or
#     ({% condition age_filter %} ${dos_detail.age_at_visit} {% endcondition %} >= 9  and
#     {% condition age_filter %} ${dos_detail.age_at_visit} {% endcondition %} <= 21 and ${data.sex}='M')




  dimension:  previous_time_frame {
    type: date
    sql: DATEADD(day, -1, ${dos_detail.visit_date})  ;;
  }

  dimension:  was_eligible_for_dose1_in_time_frame {
#   dimension:  eligible_in_time_frame {
  type: yesno
  sql: ${date_first_shot_date} > ${previous_time_frame} or ${had_first_shot}=0

                  ;;
}

measure: count_of_eligible_for_dose1_in_timeframe {
  type: count
  filters: {
    field: was_eligible_for_dose1_in_time_frame
    value: "yes"
  }
  filters: {
    field: is_hpv_patient
    value: "yes"
  }

#     filters: {
#       field: visit_time_frame
#       value: "yes"
#     }
  drill_fields: [hpvdetail_distinct*]
}

measure: count_of_eligible_for_dose2_in_timeframe {
  type: count
  filters: {
    field: is_patient_eligible_for_2nd_HPV_dose
    value: "yes"
  }
  filters: {
    field: is_hpv_patient
    value: "yes"
  }

#     filters: {
#       field: visit_time_frame
#       value: "yes"
#     }
  drill_fields: [hpvdetail_distinct*]
}


dimension:  was_eligible_for_dose2_in_time_frame {
#   dimension:  eligible_in_time_frame {
type: yesno
sql: ${date_second_shot_date} > ${previous_time_frame} and ${had_first_shot}=1 or ${had_second_shot}=0

                    ;;
}

dimension:  first_dose_prior_to_2019{
  type: yesno
  sql: ${date_first_shot_year} < 2019

                        ;;
}

# measure: count_initiations_before_2019 {
#   type: count
#   filters: {
#     field: first_dose_prior_to_2019
#     value: "yes"
#   }
#   filters: {
#     field: data.is_current_patient
#     value: "yes"
#   }
#   drill_fields: [hpvdetail_distinct*]
# }

# measure: count_initiations_before_2019_9_to_14 {
#   type: count
#   filters: {
#     field: first_dose_prior_to_2019
#     value: "yes"
#   }
#   filters: {
#     field: data.is_current_patient
#     value: "yes"
#   }
#   filters: {
#     field: data.is_between_9_and_14_this_year
#     value: "yes"
#   }
#   drill_fields: [hpvdetail_distinct*]
# }

# measure: count_initiations_but_not_complete_before_2019_9_to_14 {
#   type: count
#   filters: {
#     field: first_dose_prior_to_2019
#     value: "yes"
#   }
#   filters: {
#     field: data.is_current_patient
#     value: "yes"
#   }
#   filters: {
#     field: data.is_between_9_and_14_this_year
#     value: "yes"
#   }
#   filters: {
#     field: is_hpv_series_complete_before_2019
#     value: "no"
#   }
#   drill_fields: [hpvdetail_distinct*]
# }

# measure: count_initiations_before_2019_15_to_26 {
#   type: count
#   filters: {
#     field: first_dose_prior_to_2019
#     value: "yes"
#   }
#   filters: {
#     field: data.is_current_patient
#     value: "yes"
#   }
#   filters: {
#     field: data.is_between_15_and_26_this_year
#     value: "yes"
#   }
#   drill_fields: [hpvdetail_distinct*]
# }

# measure: count_initiations_but_not_complete_before_2019_15_to_26 {
#   type: count
#   filters: {
#     field: first_dose_prior_to_2019
#     value: "yes"
#   }
#   filters: {
#     field: data.is_current_patient
#     value: "yes"
#   }
#   filters: {
#     field: data.is_between_15_and_26_this_year
#     value: "yes"
#   }
#   filters: {
#     field: is_hpv_series_complete_before_2019
#     value: "no"
#   }
#   drill_fields: [hpvdetail_distinct*]
# }


# measure: count_of_completions_before_2019 {
#   type: count
#   filters: {
#     field: is_hpv_series_complete_before_2019
#     value: "yes"
#   }
#   filters: {
#     field: data.is_current_patient
#     value: "yes"
#   }
#   drill_fields: [hpvdetail_distinct*]
# }

# measure: count_of_completions_before_2019_9_to_14 {
#   type: count
#   filters: {
#     field: is_hpv_series_complete_before_2019
#     value: "yes"
#   }
#   filters: {
#     field: data.is_current_patient
#     value: "yes"
#   }
#   filters: {
#     field: data.is_between_9_and_14_this_year
#     value: "yes"
#   }
#   drill_fields: [hpvdetail_distinct*]
# }

# measure: count_of_completions_before_2019_15_to_26 {
#   type: count
#   filters: {
#     field: is_hpv_series_complete_before_2019
#     value: "yes"
#   }
#   filters: {
#     field: data.is_current_patient
#     value: "yes"
#   }
#   filters: {
#     field: data.is_between_15_and_26_this_year
#     value: "yes"
#   }
#   drill_fields: [hpvdetail_distinct*]
# }




dimension:  eligible_for_shot1_in_time_frame {
  type: yesno
  sql: ${date_first_shot_date} > ${previous_time_frame} or ${had_first_shot}=0
    ;;
}

dimension:  eligible_for_shot2_in_time_frame {
  type: yesno
#     sql: ${had_first_shot} = 1 and ${recommended__2nd_shot_date_start} <= ${previous_time_frame} and ${date_second_shot_date}>=${dos_detail.visit_date}
  sql: (${had_first_shot} = 1 and (${date_second_shot_date} > ${dos_detail.visit_date} or ${had_second_shot} = 0) and (${recommended__2nd_shot_date_start} <= ${dos_detail.visit_date})) or ${dose2_date_diff}= 0
    ;;
}

dimension:  eligible_for_shot3_in_time_frame {
  type: yesno
  sql: (${had_first_shot} = 1 and ${had_second_shot} = 1 and (${date_third_shot_date} > ${dos_detail.visit_date} or ${had_third_shot} = 0) and
    (${recommended__3rd_shot_date_start} <= ${dos_detail.visit_date}))or ${dose3_date_diff}= 0
    ;;
#      ${had_first_shot} = 1 and ${had_second_shot} = 1 and ${had_third_shot} = 0 and (${recommended__3rd_shot_date_start} < ${previous_time_frame})

  }


  dimension:  was_dose1_in_time_frame {
    type: yesno
    sql: {% condition timeframe_filter %} ${date_first_shot_date} {% endcondition %} ;;
  }

  dimension:  was_dose2_in_time_frame {
    type: yesno
    sql: {% condition timeframe_filter %} ${date_second_shot_date} {% endcondition %} ;;
  }

  dimension:  was_dose3_in_time_frame {
    type: yesno
    sql: {% condition timeframe_filter %} ${date_third_shot_date} {% endcondition %} ;;
  }

  dimension:  was_dose4_in_time_frame {
    type: yesno
    sql: {% condition timeframe_filter %} ${date_fourth_shot_date} {% endcondition %} ;;
  }

  dimension:  was_completed_vaccination_in_time_frame {
    type: yesno
    sql: {% condition timeframe_filter %} ${patient_completion_date} {% endcondition %} ;;
  }

  dimension: was_dose_in_timeframe {
    type: yesno
    sql:
      {% condition timeframe_filter %} ${date_first_shot_date} {% endcondition %} OR
      {% condition timeframe_filter %} ${date_second_shot_date} {% endcondition %} OR
      {% condition timeframe_filter %} ${date_third_shot_date} {% endcondition %} OR
      {% condition timeframe_filter %} ${date_fourth_shot_date} {% endcondition %};;
  }

  measure: count_of_doses_in_timeframe {
    type: count
    filters: {
      field: was_dose_in_timeframe
      value: "yes"
    }
    html:
    <div align="center"> {{rendered_value}} </div>
    ;;
#         filters: {
#           field: visit_time_frame
#           value: "yes"
#         }

      drill_fields: [hpvdetail_distinct*, last_dose]
    }

    measure: count_of_1st_dose_in_timeframe {
      type: count
      filters: {
        field: was_dose1_in_time_frame
        value: "yes"
      }
      html:
          <div align="center"> {{rendered_value}} </div>
          ;;
      #         filters: {
      #           field: visit_time_frame
      #           value: "yes"
      #         }

        drill_fields: [hpvdetail_distinct*, last_dose]
      }

      measure: count_of_completions_in_timeframe {
        type: count
        filters: {
          field: was_completed_vaccination_in_time_frame
          value: "yes"
        }
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
        #         filters: {
        #           field: visit_time_frame
        #           value: "yes"
        #         }

          drill_fields: [hpvdetail_distinct*, last_dose]
        }


        dimension: dose1_date_diff {
          type: number
          sql: CAST(DATEDIFF(day,${dos_detail.visit_date},${date_first_shot_date}) AS INTEGER);;
        }

        dimension: dose2_date_diff {
          type: number
          sql: CAST(DATEDIFF(day,${dos_detail.visit_raw},${date_second_shot_raw}) AS INTEGER) ;;
        }
        dimension: dose3_date_diff {
          type: number
          sql: CAST(DATEDIFF(day,${dos_detail.visit_raw},${date_third_shot_raw}) AS INTEGER) ;;
        }

        dimension: patient_had_a_dose_during_timeframe {
          type: string
          sql: CASE
                      WHEN ${dose1_date_diff}= 0 THEN 'Yes'
                      WHEN ${dose2_date_diff}= 0  THEN 'Yes'
                      WHEN ${dose3_date_diff}= 0  THEN 'Yes'
                      ELSE
                      'No'
                      END
                ;;
        }

        dimension: patient_had_a_dose_during_timeframe_1_0 {
          type: number
          sql: CASE
                      WHEN ${dose1_date_diff}= 0 THEN 1
                      WHEN ${dose2_date_diff}= 0  THEN 1
                      WHEN ${dose3_date_diff}= 0  THEN 1
                      ELSE
                      0
                      END
                ;;
        }




        dimension:  dose1_eligible_not_given_in_time_frame {
          type: yesno
#     sql:  {% condition timeframe_filter %} ${date_first_shot_date} {% endcondition %}
          sql:  ${had_first_shot} = 0
            ;;
        }

        dimension:  dose2_eligible_not_given_in_time_frame {
          type: yesno
#     sql:  {% condition timeframe_filter %} ${date_first_shot_date} {% endcondition %}
          sql:  ${had_first_shot} = 1 and ${had_second_shot} = 0 and (${recommended__2nd_shot_date_start} <= ${dos_detail.visit_raw})
            ;;
        }

        dimension:  dose3_eligible_not_given_in_time_frame {
          type: yesno
#     sql:  {% condition timeframe_filter %} ${date_first_shot_date} {% endcondition %}
          sql:  ${had_first_shot} = 1 and ${had_second_shot} = 1 and ${had_third_shot} = 0 and (${recommended__3rd_shot_date_start} <= ${dos_detail.visit_raw})
            ;;
        }

        dimension: is_patient_eligible_for_1st_HPV_dose_in_timeframe {
          type:  string
          sql: CASE
                      WHEN  ${is_hpv_patient} = 'Yes' and ${was_eligible_for_dose1_in_time_frame} = 'Yes'
                      THEN 'Yes'
                      ELSE
                      'No'
                      END;;
          html:
              <div align="left"> {{rendered_value}} </div>
              ;;
        }



        measure: sum_of_doses_in_timeframe {
          type: sum
          sql:  ${patient_had_a_dose_during_timeframe_1_0} ;;
          drill_fields: [hpvdetail*]
        }

        measure: count_of_hpv_patients_in_timeframe {
          type: count
          filters: {
#       field: was_eligible_for_dose1_in_time_frame
          field:  is_hpv_patient
          value: "yes"
        }
        filters: {
          field: visit_time_frame
          value: "yes"
        }
        drill_fields: [hpvdetail*]
      }

      measure: count_of_yes_dose1_in_timeframe {
        type: count
        filters: {
          field: was_dose1_in_time_frame
          value: "yes"
        }
        drill_fields: [hpvdetail_distinct*, last_dose]
      }

      measure: count_of_yes_dose2_in_timeframe {
        type: count
        filters: {
          field: was_dose2_in_time_frame
          value: "yes"
        }
        drill_fields: [hpvdetail_distinct*, last_dose]
      }

      measure: count_of_yes_dose3_in_timeframe {
        type: count
        filters: {
          field: was_dose3_in_time_frame
          value: "yes"
        }
        drill_fields: [hpvdetail_distinct*, last_dose]
      }

      measure: count_of_yes_dose4_in_timeframe {
        type: count
        filters: {
          field: was_dose4_in_time_frame
          value: "yes"
        }
        drill_fields: [hpvdetail_distinct*, last_dose]
      }


      dimension: did_patient_have_a_dose_date_diff{
        type:  number
        sql: datediff(day, ${last_dose},${dos_detail.visit_date})
          ;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      dimension: did_patient_have_a_dose_at_last_vist{
        type:  string
        sql: CASE
          WHEN  ${is_hpv_patient} = 'Yes' and
          datediff(day, ${last_dose},${dos_detail.visit_date}) <= 0 THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      dimension: did_patient_have_a_dose_in_timeframe{
        type:  string
        sql: CASE
          WHEN  datediff(day, ${last_dose},${visit_time_frame}) <= 0 THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      measure: count_doses_in_timeframe {
        type: count
        filters: {
          field: did_patient_have_a_dose_in_timeframe
          value: "Yes"
        }
        drill_fields: [hpvdetail_distinct*]
      }



      measure: count_of_no_dose1_in_timeframe {
        type: count
        filters: {
          field: was_dose1_in_time_frame
          value: "no"
        }

        drill_fields: [hpvdetail*]
      }

# *****************This is where the new HPV dimensions and measures END - not deployed as of 6-27-19*************

      dimension_group: date_eighth_shot {
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
        sql: ${TABLE}.Date_Eighth_shot ;;
      }

      dimension: mhm_start_date {
        type: date
        sql: 2019-05-01 ;;
      }

      measure: mhm_start_value {
        type: sum
        sql: 40 ;;
      }

      dimension: eighth_shot {
        type:  date
        sql: ${date_eighth_shot_date} ;;
        html:
            <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
            ;;
      }

      dimension: had_eighth_shot {
        type: number
        sql: CASE
          WHEN ${date_eighth_shot_date} IS NULL THEN 0
          ELSE
          1
          END;;
      }

      dimension_group: date_fifth_shot {
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
        sql: ${TABLE}.Date_Fifth_shot ;;
      }
      dimension: fifth_shot {
        type:  date
        sql: ${date_fifth_shot_date} ;;
        html:
            <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
            ;;
      }

      dimension: had_fifth_shot {
        type: number
        sql: CASE
          WHEN ${date_fifth_shot_date} IS NULL THEN 0
          ELSE
          1
          END;;
      }

      dimension_group: date_first_shot {
        type: time
        timeframes:
        [raw, time, date, day_of_week, day_of_week_index, week,  week_of_year, month, month_name, month_num, quarter, year]
        sql: ${TABLE}.Date_First_shot ;;
      }

      dimension:first_shot_string{
        type: string
        sql:  CASE
          WHEN ${date_first_shot_date} IS NULL THEN NULL
          ELSE
          CONVERT(varchar, date_first_shot, 110)
          END
          ;;

        html:
          <div align="center"> {{rendered_value}} </div>
          ;;
      }

#   dimension: is_hpv_patient {
#     type:  string
#     sql: CASE
#           WHEN  ((${data.age} >= 9 and ${data.age} <= 21) and ${data.sex} = 'M' ) or
#           ((${data.age} >= 9 and ${data.age} <= 26 ) and ${data.sex} = 'F') or
#           (${had_first_shot}=1 and ${HPV_vaccination_complete} = 'No') THEN 'Yes'
#           ELSE
#           'No'
#           END;;
#     html:
#     <div align="left"> {{rendered_value}} </div>
#     ;;
#   }

#   dimension: is_hpv_patient {
#     type:  string
#     sql: CASE
#           WHEN  ((${data.age} >= 9 and ${data.age} <= 21) and ${data.sex} = 'M' ) or
#           ((${data.age} >= 9 and ${data.age} <= 26 ) and ${data.sex} = 'F') or
#           (${had_first_shot}=1 ) THEN 'Yes'
#           ELSE
#           'No'
#           END;;
#     html:
#     <div align="left"> {{rendered_value}} </div>
#     ;;
#   }

      dimension: is_hpv_patient {
        type:  string
        sql: CASE
          WHEN (${data.age} >= 9 and ${data.age} <= 26 ) or ${had_first_shot}=1  THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }


#   dimension: is_hpv_patient_at_visit_timeframe {
#     type:  string
#     sql: CASE
#           WHEN  ((${dos_detail.age_at_visit} >= 9 and ${dos_detail.age_at_visit} <= 21) and ${data.sex} = 'M')  or
#                 ((${dos_detail.age_at_visit} >= 9 and ${dos_detail.age_at_visit} <= 26) and ${data.sex} = 'F')  or
#                 (${had_first_shot}=1 and ${HPV_vaccination_complete} = 'No')  THEN 'Yes'
#           ELSE
#           'No'
#           END;;
#     html:
#     <div align="left"> {{rendered_value}} </div>
#     ;;
#   }

#   dimension: is_hpv_patient_at_visit_timeframe {
#     type:  string
#     sql: CASE
#           WHEN  ((${dos_detail.age_at_visit} >= 9 and ${dos_detail.age_at_visit} <= 21) and ${data.sex} = 'M')  or
#                 ((${dos_detail.age_at_visit} >= 9 and ${dos_detail.age_at_visit} <= 26) and ${data.sex} = 'F')  or
#                 (${had_first_shot}=1)  THEN 'Yes'
#           ELSE
#           'No'
#           END;;
#     html:
#     <div align="left"> {{rendered_value}} </div>
#     ;;
#   }

      dimension: is_hpv_patient_at_visit_timeframe {
        type:  string
        sql: CASE
          WHEN  (${dos_detail.age_at_visit} >= 9 and ${dos_detail.age_at_visit} <= 26)  or (${had_first_shot}=1)  THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }



      dimension: is_hpv_patient_number {
        type:  number
        sql: CASE
          WHEN (${data.age} >= 9 and ${data.age} <= 26 )  or
          (${had_first_shot}=1 and ${HPV_vaccination_complete} = 'No') THEN 1
          ELSE
          0
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      # dimension: is_hpv_patient_2019_rules {
      #   type:  string
      #   sql: CASE
      #     WHEN  ${data.age} >= 9 and ${data.age} <= 26 THEN 'Yes'
      #     WHEN  ${had_first_shot}=1 and ${HPV_vaccination_complete} = 'No' THEN 'Yes'
      #     ELSE
      #     'No'
      #     END;;
      #   html:
      #       <div align="left"> {{rendered_value}} </div>
      #       ;;
      # }


#   dimension: is_hpv_eligible_age {
#     type:  string
#     sql: CASE
#           WHEN  ((${data.age} >= 9 and ${data.age} <= 21) and ${data.sex} = 'M' ) or
#           ((${data.age} >= 9 and ${data.age} <= 26 ) and ${data.sex} = 'F')
#           THEN 'Yes'
#           ELSE
#           'No'
#           END;;
#     html:
#     <div align="left"> {{rendered_value}} </div>
#     ;;
#   }

      dimension: is_hpv_eligible_age {
        type:  string
        sql: CASE
          WHEN  ${data.age} >= 9 and ${data.age} <= 26 THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }


      dimension: is_hpv_patient_female {
        type:  string
        sql: CASE
          WHEN  ((${data.age} >= 9 and ${data.age} <= 26 ) and ${data.sex} = 'F') or
          (${data.age} >= 27 and ${had_first_shot}=1 and ${data.sex} = 'F') THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      dimension: is_hpv_age_female {
        type:  string
        sql: CASE
          WHEN  ((${data.age} >= 9 and ${data.age} <= 26 ) and ${data.sex} = 'F') THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

#   dimension: is_hpv_patient_male {
#     type:  string
#     sql: CASE
#           WHEN  ((${data.age} >= 9 and ${data.age} <= 21 ) and ${data.sex} = 'M') or
#           (${data.age} >= 22 and ${had_first_shot}=1 and ${data.sex} = 'M')  THEN 'Yes'
#           ELSE
#           'No'
#           END;;
#     html:
#     <div align="left"> {{rendered_value}} </div>
#     ;;
#   }

      dimension: is_hpv_patient_male {
        type:  string
        sql: CASE
          WHEN  ((${data.age} >= 9 and ${data.age} <= 26 ) and ${data.sex} = 'M') or
          (${data.age} >= 22 and ${had_first_shot}=1 and ${data.sex} = 'M')  THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

#   dimension: is_hpv_age_male {
#     type:  string
#     sql: CASE
#           WHEN  ((${data.age} >= 9 and ${data.age} <= 21 ) and ${data.sex} = 'M') THEN 'Yes'
#           ELSE
#           'No'
#           END;;
#     html:
#     <div align="left"> {{rendered_value}} </div>
#     ;;
#   }

      dimension: is_hpv_age_male {
        type:  string
        sql: CASE
          WHEN  ((${data.age} >= 9 and ${data.age} <= 26 ) and ${data.sex} = 'M') THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      measure: count_hpv_patients {
        description: "Patient has been seen within the last 2 years and is not deceased"
        type: count
        filters: {
          field: is_hpv_patient
          value: "Yes"
        }
        filters: {
          field: data.is_current_patient
          value: "Yes"
        }
        filters: {
          field: HPV_vaccination_complete
          value: "No"
        }
        drill_fields: [hpvdetail*]
      }

      # measure: count_hpv_patients_with_unknown_pcp {
      #   description: "Patient has been seen within the last 2 years and is not deceased and has no named PCP"
      #   type: count
      #   filters: {
      #     field: is_hpv_patient
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: data.is_current_patient
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: HPV_vaccination_complete
      #     value: "No"
      #   }
      #   filters: {
      #     field: pcp.is_pcp_known
      #     value: "No"
      #   }
      #   drill_fields: [hpvdetail*]
      # }

      # measure: count_hpv_patients_2019_rules {
      #   description: "Patient has been seen within the last 2 years and is not deceased and all ages go to 26"
      #   type: count
      #   filters: {
      #     field: is_hpv_patient_2019_rules
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: data.is_current_patient
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: HPV_vaccination_complete
      #     value: "No"
      #   }
      #   drill_fields: [hpvdetail*]
      # }



      measure: count_hpv_patients_female {
        description: "Patient has been seen within the last 2 years and is not deceased"
        type: count
        filters: {
          field: is_hpv_patient
          value: "Yes"
        }
        filters: {
          field: data.sex
          value: "F"
        }
        filters: {
          field: data.is_current_patient
          value: "Yes"
        }
#     filters: {
#       field: HPV_vaccination_complete
#       value: "No"
#     }
#     filters: {
#       field: data.is_patient_seen_in_last_year
#       value: "Yes"
#     }
        drill_fields: [hpvdetail*]
      }

      measure: count_hpv_patients_male {
        description: "Patient has been seen within the last 2 years and is not deceased"
        type: count
        filters: {
          field: is_hpv_patient
          value: "Yes"
        }
        filters: {
          field: data.sex
          value: "M"
        }
#     filters: {
#       field: is_hpv_age_male
#       value: "Yes"
#     }
        filters: {
          field: data.is_current_patient
          value: "Yes"
        }
#     filters: {
#       field: HPV_vaccination_complete
#       value: "No"
#     }
#     filters: {
#       field: data.is_patient_seen_in_last_year
#       value: "Yes"
#     }
        drill_fields: [hpvdetail*]
      }

#   dimension: recommended_number_of_shots {
#     type:  number
#     sql: CASE
#           WHEN ((${age_at_1st_shot} >=22 and ${data.sex}= 'M') or (${age_at_1st_shot} >=27 and ${data.sex}= 'F')) and ${had_third_shot} = 1
#           and (${date_third_shot_date} < DATEADD (month, 5, ${first_shot})) THEN 4
#           WHEN ((${age_at_1st_shot} >=22 and ${data.sex}= 'M') or (${age_at_1st_shot} >=27 and ${data.sex}= 'F')) and ${had_second_shot} = 1
#           and (${date_second_shot_date} < DATEADD (month, 5, ${first_shot})) THEN 3
#           WHEN ((${age_at_1st_shot} >=22 and ${data.sex}= 'M') or (${age_at_1st_shot} >=27 and ${data.sex}= 'F')) and ${had_first_shot} = 1 THEN 3
#           WHEN ${age_at_1st_shot} < 15 and ${had_third_shot} = 1 and ((${date_third_shot_date} < DATEADD (month, 5, ${first_shot})) or
#           (${date_third_shot_date} <  DATEADD(week, 12, ${date_second_shot_date})) ) THEN 4
#           WHEN ${age_at_1st_shot} < 15 and ${had_second_shot} = 1 and (${date_second_shot_date} < DATEADD (month, 5, ${first_shot})) THEN 3
#           WHEN (${data.age} >= 9 and ${data.age} < 15) and ${had_second_shot} = 1 and (${date_second_shot_date} < DATEADD (month, 5, ${first_shot})) THEN 3
#           WHEN (${data.age} >= 9 and ${data.age} < 15) and ${had_third_shot} = 1 and ((${date_third_shot_date} < DATEADD (month, 5, ${first_shot})) or
#           (${date_third_shot_date} <  DATEADD(week, 12, ${date_second_shot_date})) ) THEN 4
#           WHEN ${age_at_1st_shot} < 15 THEN 2
#           WHEN ${data.age} >= 9 and ${data.age} < 15 THEN 2
#           WHEN (${age_at_1st_shot} >= 15 and ${age_at_1st_shot} <= 21) and ${had_third_shot} = 1 and (${date_third_shot_date} < DATEADD (month, 5, ${first_shot})) THEN 4
#           WHEN (${age_at_1st_shot} >= 15 and ${age_at_1st_shot} <= 21) and ${had_second_shot} = 1 and (${date_third_shot_date} < DATEADD (week, 12, ${second_shot})) THEN 4
#           WHEN ${age_at_1st_shot} >=15 and ${age_at_1st_shot} <=21 THEN 3
#           WHEN ${data.age} >= 15 and ${data.age} <= 21 THEN 3
#           WHEN ${age_at_1st_shot} <= 26 and ${data.sex}= 'F' and ${had_third_shot} = 1 and (${date_third_shot_date} < DATEADD (month, 5, ${first_shot})) THEN 4
#           WHEN ${age_at_1st_shot} <= 26 and ${data.sex}= 'F' and ${had_second_shot} = 1 and (${date_third_shot_date} < DATEADD (week, 12, ${second_shot})) THEN 4
#           WHEN ${age_at_1st_shot} >=15 and ${age_at_1st_shot} <=26 and ${data.sex}= 'F' THEN 3
#           WHEN ${data.age} >= 15 and ${data.age} <= 26 and ${data.sex}= 'F' THEN 3
#           ELSE
#           0
#           END;;
#     html:
#     <div align="left"> {{rendered_value}} </div>
#     ;;
#   }


#   dimension: initial_status {
#     type:  string
#     sql: CASE
#           WHEN  ${had_first_shot} = 0 and ((${data.age} >= 22 and ${data.sex}= 'M') or(${data.age} >=27 and ${data.sex}= 'F') ) THEN 'Patient has had no doses and is older than recommended age. If HPV regimen is initiated, the doses may not be covered by insurance. '
#           WHEN  ${had_first_shot} = 1 and ((${data.age} >= 22 and ${data.sex}= 'M') or(${data.age} >=27 and ${data.sex}= 'F') ) THEN 'Patient has received 1 dose and can receive 2nd dose, but is older than HPV guidelines and may not be covered by insurance. '
#           WHEN  ${had_second_shot} = 1 and ${recommended_number_of_shots} = 0 and ((${data.age} >= 22 and ${data.sex}= 'M') or(${data.age} >=27 and ${data.sex}= 'F') ) THEN 'Patient has had two doses, but is older than HPV guidelines and may not be covered by insurance. '
#           ELSE
#           ''
#           END;;
#     html:
#     <div align="left"> {{rendered_value}} </div>
#     ;;
#   }


      dimension: recommended_number_of_shots {
        type:  number
        sql: CASE
          WHEN ${age_at_1st_shot} >=27 and ${had_third_shot} = 1 and ${date_third_shot_date} < DATEADD (month, 5, ${first_shot}) THEN 4
          WHEN ${age_at_1st_shot} >=27 and ${had_second_shot} = 1 and ${date_second_shot_date} < DATEADD (month, 5, ${first_shot}) THEN 3
          WHEN ${age_at_1st_shot} >=27 and ${had_first_shot} = 1 THEN 3
          WHEN (${age_at_1st_shot} < 15 and ${had_third_shot} = 1 and  ${date_third_shot_date} < DATEADD (month, 5, ${first_shot})) or
          (${date_third_shot_date} <  DATEADD(week, 12, ${date_second_shot_date})) THEN 4
          WHEN ${age_at_1st_shot} < 15 and ${had_second_shot} = 1 and ${date_second_shot_date} < DATEADD (month, 5, ${first_shot}) THEN 3
          WHEN (${data.age} >= 9 and ${data.age} < 15) and ${had_second_shot} = 1 and ${date_second_shot_date} < DATEADD (month, 5, ${first_shot}) THEN 3
          WHEN ((${data.age} >= 9 and ${data.age} < 15) and ${had_third_shot} = 1 and  ${date_third_shot_date} < DATEADD (month, 5, ${first_shot})) or
          (${date_third_shot_date} <  DATEADD(week, 12, ${date_second_shot_date})) THEN 4
          WHEN ${age_at_1st_shot} < 15 THEN 2
          WHEN ${data.age} >= 9 and ${data.age} < 15 THEN 2
          WHEN (${age_at_1st_shot} >= 15 and ${age_at_1st_shot} <= 26) and ${had_third_shot} = 1 and ${date_third_shot_date} < DATEADD (month, 5, ${first_shot}) THEN 4
          WHEN (${age_at_1st_shot} >= 15 and ${age_at_1st_shot} <= 26) and ${had_second_shot} = 1 and ${date_third_shot_date} < DATEADD (week, 12, ${second_shot}) THEN 4
          WHEN ${age_at_1st_shot} >=15 and ${age_at_1st_shot} <=26 THEN 3
          WHEN ${data.age} >= 15 and ${data.age} <= 26 THEN 3
          ELSE
          0
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      dimension: initial_status {
        type:  string
        sql: CASE
          WHEN  ${had_first_shot} = 0 and ${data.age} >=27  THEN 'Patient has had no doses and is older than recommended age. If HPV regimen is initiated, the doses may not be covered by insurance. '
          WHEN  ${had_first_shot} = 1 and ${data.age} >=27  THEN 'Patient has received 1 dose and can receive 2nd dose, but is older than HPV guidelines and may not be covered by insurance. '
          WHEN  ${had_second_shot} = 1 and ${recommended_number_of_shots} = 0 and ${data.age} >=27  THEN 'Patient has had two doses, but is older than HPV guidelines and may not be covered by insurance. '
          ELSE
          ''
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      dimension: 1st_shot_status {
        type:  string
        sql: CASE
          WHEN  ${had_first_shot} = 0 and (${data.age} >= 9 and ${data.age} <=26) and DATEDIFF( day, getdate(), ${data.next_appointment_date}) = 0  THEN 'Patient is missing first HPV Dose, 1st dose is recommended at today''s appt. '
          WHEN  ${had_first_shot} = 0 and (${data.age} >= 9 and ${data.age} <=26) and getdate() <=  ${data.next_appointment_date}  THEN 'Patient is missing first HPV Dose, 1st dose is recommended at scheduled appt on ' + CONVERT(varchar, ${data.next_appointment_date}) + '. '
          WHEN  ${had_first_shot} = 0 and (${data.age} >= 9 and ${data.age} <=26)  THEN 'Patient is missing first HPV Dose and there is no record of a future appointment scheduled. '
          WHEN  ${had_first_shot} = 1  and ${had_second_shot} = 1 THEN ''
          WHEN  ${had_first_shot} = 1 THEN '1st dose administered. '
          ELSE
          ''
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

# , recommendatation is to schedule an appt to administer 1st dose.

      dimension: 2nd_shot_status {
        type:  string
        sql: CASE
          WHEN ${had_second_shot} = 0 and ${recommended_number_of_shots} = 2 and ${had_first_shot} = 1 and ${data.next_appointment_date}< DATEADD(month, 5, ${first_shot}) THEN 'Scheduled appt on ' + CONVERT(varchar, ${data.next_appointment_date}) +
          ' is TOO EARLY FOR 2ND DOSE. Recommendation is to schedule 2nd dose after '+ ${recommended__2nd_shot_date_string}+'. '
          WHEN ${had_second_shot} = 0 and ${recommended_number_of_shots} = 2 and ${had_first_shot} = 1 and ${data.next_appointment_date}>= DATEADD(month, 5, ${first_shot}) THEN '2nd dose is recommended at scheduled appt on ' + CONVERT(varchar, ${data.next_appointment_date}) + '. '
          WHEN ${had_second_shot} = 0 and ${recommended_number_of_shots} = 2 and ${had_first_shot} = 1 and getdate() < DATEADD(month, 5, ${first_shot}) THEN 'Recommendatation is to schedule an appt after '+ CONVERT(varchar, ${recommended__2nd_shot_date_string}) + ' to administer 2nd dose. '
          WHEN ${had_second_shot} = 0 and ${recommended_number_of_shots} = 2 and ${had_first_shot} = 1 and getdate() >= DATEADD(month, 5, ${first_shot}) THEN 'Recommendatation is to schedule an appt to administer 2nd dose. '
          WHEN ${had_second_shot} = 1 and ${recommended_number_of_shots} = 2 and ${date_second_shot_date} >= ${recommended__2nd_shot_date_start} THEN '2nd dose administered-vaccination complete. '
          WHEN ${had_second_shot} = 0 and ${recommended_number_of_shots} = 3 and ${had_first_shot} = 1 and ${data.next_appointment_date}< DATEADD(month, 1, ${first_shot}) THEN 'Scheduled appt on ' + CONVERT(varchar, ${data.next_appointment_date}) +
          ' is TOO EARLY FOR 2ND DOSE. Recommendation is to schedule 2nd dose after '+ ${recommended__2nd_shot_date_string}+'. '
          WHEN ${had_second_shot} = 0 and ${recommended_number_of_shots} = 3 and ${had_first_shot} = 1 and ${data.next_appointment_date} >= DATEADD(month, 1, ${first_shot}) THEN '2nd dose is recommended at scheduled appt on ' + CONVERT(varchar, ${data.next_appointment_date}) + '. '
          WHEN ${had_second_shot} = 0 and ${recommended_number_of_shots} = 3 and ${had_first_shot} = 1 and getdate() < DATEADD(month, 1, ${first_shot}) THEN 'Recommendatation is to schedule an appt after '+ CONVERT(varchar, ${recommended__2nd_shot_date_string}) + ' to administer 2nd dose. '
          WHEN ${had_second_shot} = 0 and ${recommended_number_of_shots} = 3 and ${had_first_shot} = 1 and getdate() >= DATEADD(month, 1, ${first_shot}) THEN 'Recommendatation is to schedule an appt to administer 2nd dose. '
          WHEN ${had_first_shot} = 1  and ${had_second_shot} = 1 and ${had_third_shot} = 1 THEN ''
          WHEN ${had_second_shot} = 1 and ${recommended_number_of_shots} = 3 and ${date_second_shot_date} >= ${recommended__2nd_shot_date_start} THEN '2nd dose administered. '
          WHEN ${had_second_shot} = 1 and ${recommended_number_of_shots} = 3 and ${date_second_shot_date} < ${recommended__2nd_shot_date_start} THEN '2nd dose received TOO EARLY - must adminsister 3rd dose at least 12 weeks after 2nd dose. '
          ELSE
          ''
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }


      dimension: 3rd_shot_status {
        type:  string
        sql: CASE
          WHEN ${had_third_shot} = 0 and ${recommended_number_of_shots} = 3 and ${had_second_shot} = 1 and ${data.next_appointment_date}< ${recommended__3rd_shot_date_start} THEN 'Scheduled appt on ' + CONVERT(varchar, ${data.next_appointment_date}) +  ' is TOO EARLY FOR 3RD DOSE. '
          WHEN ${had_third_shot} = 0 and ${recommended_number_of_shots} = 3 and ${had_second_shot} = 1 and ${recommended__3rd_shot_date_start} <= ${data.next_appointment_date} THEN '3rd dose is recommended at scheduled appt on ' + CONVERT(varchar, ${data.next_appointment_date}) + '. '
          WHEN ${had_third_shot} = 0 and ${recommended_number_of_shots} = 3 and ${had_second_shot} = 1 and getdate() < ${recommended__3rd_shot_date_start} THEN 'Recommendation is to schedule an appt after '+ CONVERT(varchar, ${recommended_3rd_shot_string}) + ' to administer 3rd dose. '
          WHEN ${had_third_shot} = 0 and ${recommended_number_of_shots} = 3 and ${had_second_shot} = 1 and getdate() >= ${recommended__3rd_shot_date_start} THEN 'Recommendation is to schedule an appt to administer 3rd dose. '
          WHEN ${had_first_shot} = 1  and ${had_second_shot} = 1 and ${had_third_shot} = 1 and ${had_fourth_shot} = 1 THEN ''
          WHEN ${had_third_shot} = 1 and ${recommended_number_of_shots} = 3 and ${date_third_shot_date} >= ${recommended__3rd_shot_date_start} THEN '3rd dose administered-vaccination complete. '
          ELSE
          ''
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

#   WHEN ${had_third_shot} = 1 and ${recommended_number_of_shots} = 3 and ${date_third_shot_date} >= ${recommended__3rd_shot_date_start} THEN '3rd dose administered-vaccination complete. '
#           WHEN ${had_third_shot} = 1 and ${recommended_number_of_shots} = 4 and ${date_third_shot_date} < ${recommended__3rd_shot_date_start} THEN '3rd dose received TOO EARLY - must adminsister 4th dose at least 12 weeks after 3rd dose. '


      dimension: 4th_shot_status {
        type:  string
        sql: CASE
          WHEN ${had_fourth_shot} = 0 and ${recommended_number_of_shots} = 4 and ${had_third_shot} = 1 and ${data.next_appointment_date} < ${recommended__4th_shot_date_start}
          THEN '3rd dose received TOO EARLY, it was administered on '+ CONVERT(varchar, ${date_third_shot_date}) +
          ' and the recommended date was  '+ CONVERT(varchar, ${recommended_3rd_shot_string}) +'. Scheduled appt on ' + CONVERT(varchar, ${data.next_appointment_date}) +  ' is TOO EARLY FOR REQUIRED 4TH DOSE. Recommendation is to schedule an appt after '+
          CONVERT(varchar, ${recommended_4th_shot_string}) + ' to administer required 4th dose. '


          WHEN ${had_fourth_shot} = 0 and ${recommended_number_of_shots} = 4 and ${had_third_shot} = 1 and ${recommended__4th_shot_date_start} <= ${data.next_appointment_date}
          THEN '3rd dose received TOO EARLY, it was administered on '+ CONVERT(varchar, ${date_third_shot_date}) +
          ' and the recommended date was  '+ CONVERT(varchar, ${recommended_3rd_shot_string}) + '. 4th dose is recommended at scheduled appt on ' + CONVERT(varchar, ${data.next_appointment_date}) + '. '


          WHEN ${had_fourth_shot} = 0 and ${recommended_number_of_shots} = 4 and ${had_third_shot} = 1 and  getdate() >= ${recommended__4th_shot_date_start}
          THEN '3rd dose received TOO EARLY, it was administered on '+ CONVERT(varchar, ${date_third_shot_date}) +
          ' and the recommended date was  '+ CONVERT(varchar, ${recommended_3rd_shot_string}) +'. Recommendation is to schedule an appt after '+
          CONVERT(varchar, ${recommended_4th_shot_string}) + ' to administer required 4th dose. '

          WHEN ${had_fourth_shot} = 1 and ${recommended_number_of_shots} = 4 and ${date_fourth_shot_date} >= ${recommended__4th_shot_date_start} THEN '4th dose was required and was administered-vaccination complete. '
          ELSE
          ''
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      dimension: hpv_status {
        type: string
        sql: CASE
          WHEN ${recommended_number_of_shots} = 0 THEN ${initial_status}+' '+${patient_hpv_refusal.refusal_shot_status}
          ELSE ${1st_shot_status} + ${2nd_shot_status} + ${3rd_shot_status} +${4th_shot_status}+' '+${patient_hpv_refusal.refusal_shot_status}
          END;;
        link: {
          label: "CDC HVP Info"
          url: "https://www.cdc.gov/hpv/hcp/schedules-recommendations.html"
        }

      }


      dimension: HPV_vaccination_complete {
        type:  string
        sql: CASE
          WHEN ${recommended_number_of_shots} = 4 and ${had_fourth_shot} = 1 and  (${date_fourth_shot_date} >= ${recommended__4th_shot_date_start}) THEN 'Yes'
          WHEN ${recommended_number_of_shots} = 3 and ${had_third_shot} = 1 and  (${date_third_shot_date} >= ${recommended__3rd_shot_date_start}) THEN 'Yes'
          WHEN ${recommended_number_of_shots} = 2 and ${had_second_shot} = 1 and  (${date_second_shot_date} >= ${recommended__2nd_shot_date_start}) THEN 'Yes'
          WHEN ${recommended_number_of_shots} = 4 and ${had_fourth_shot} = 1  THEN 'Yes'
          WHEN ${recommended_number_of_shots} = 3 and ${had_first_shot} = 1 and ${had_second_shot} = 1 and ${had_third_shot} = 1 THEN 'Yes'
          ELSE
         'No'
          END;;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }


      dimension_group: HPV_vaccination_complete_date {
        type: time
        timeframes: [
          raw,
          time,
          date,
          week,
          day_of_week_index,
          week_of_year,
          month,
          quarter,
          year
        ]
        sql: CASE
          WHEN ${recommended_number_of_shots} = 4 and ${had_fourth_shot} = 1 and  (${date_fourth_shot_date} >= ${recommended__4th_shot_date_start}) THEN ${date_fourth_shot_date}
          WHEN ${recommended_number_of_shots} = 3 and ${had_third_shot} = 1 and  (${date_third_shot_date} >= ${recommended__3rd_shot_date_start}) THEN ${date_third_shot_date}
          WHEN ${recommended_number_of_shots} = 2 and ${had_second_shot} = 1 and  (${date_second_shot_date} >= ${recommended__2nd_shot_date_start}) THEN ${date_second_shot_date}
          WHEN ${recommended_number_of_shots} = 4 and ${had_fourth_shot} = 1  THEN ${date_fourth_shot_date}
          WHEN ${recommended_number_of_shots} = 3 and ${had_first_shot} = 1 and ${had_second_shot} = 1 and ${had_third_shot} = 1 THEN ${date_third_shot_date}
          ELSE
         NULL
          END;;
        html:
            <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
            ;;
      }

      dimension: MHM_week_indicator {
        type: number
        sql: CASE
          WHEN ${date_first_shot_day_of_week_index}=4 THEN ${date_first_shot_week_of_year}+1
          WHEN ${date_first_shot_day_of_week_index}=5 THEN ${date_first_shot_week_of_year}+1
          WHEN ${date_first_shot_day_of_week_index}=6 THEN ${date_first_shot_week_of_year}+1
          WHEN ${date_first_shot_day_of_week_index}=0 THEN ${date_first_shot_week_of_year}
          WHEN ${date_first_shot_day_of_week_index}=1 THEN ${date_first_shot_week_of_year}
          WHEN ${date_first_shot_day_of_week_index}=2 THEN ${date_first_shot_week_of_year}
          WHEN ${date_first_shot_day_of_week_index}=3 THEN ${date_first_shot_week_of_year}
          END;;
      }



      dimension: MHM_day_indicator {
        type: number
        sql: CASE
          WHEN ${date_first_shot_day_of_week_index}=4 THEN 1
          WHEN ${date_first_shot_day_of_week_index}=5 THEN 2
          WHEN ${date_first_shot_day_of_week_index}=6 THEN 3
          WHEN ${date_first_shot_day_of_week_index}=0 THEN 4
          WHEN ${date_first_shot_day_of_week_index}=1 THEN 5
          WHEN ${date_first_shot_day_of_week_index}=2 THEN 6
          WHEN ${date_first_shot_day_of_week_index}=3 THEN 7
          END;;
      }


      dimension: MHM_week_indicator_session_complete {
        type: number
        sql: CASE
          WHEN ${HPV_vaccination_complete_date_day_of_week_index}=4 THEN ${HPV_vaccination_complete_date_week_of_year}+1
          WHEN ${HPV_vaccination_complete_date_day_of_week_index}=5 THEN ${HPV_vaccination_complete_date_week_of_year}+1
          WHEN ${HPV_vaccination_complete_date_day_of_week_index}=6 THEN ${HPV_vaccination_complete_date_week_of_year}+1
          WHEN ${HPV_vaccination_complete_date_day_of_week_index}=0 THEN ${HPV_vaccination_complete_date_week_of_year}
          WHEN ${HPV_vaccination_complete_date_day_of_week_index}=1 THEN ${HPV_vaccination_complete_date_week_of_year}
          WHEN ${HPV_vaccination_complete_date_day_of_week_index}=2 THEN ${HPV_vaccination_complete_date_week_of_year}
          WHEN ${HPV_vaccination_complete_date_day_of_week_index}=3 THEN ${HPV_vaccination_complete_date_week_of_year}
          END;;
      }



      dimension: MHM_day_indicator_session_complete {
        type: number
        sql: CASE
          WHEN ${HPV_vaccination_complete_date_day_of_week_index}=4 THEN 1
          WHEN ${HPV_vaccination_complete_date_day_of_week_index}=5 THEN 2
          WHEN ${HPV_vaccination_complete_date_day_of_week_index}=6 THEN 3
          WHEN ${HPV_vaccination_complete_date_day_of_week_index}=0 THEN 4
          WHEN ${HPV_vaccination_complete_date_day_of_week_index}=1 THEN 5
          WHEN ${HPV_vaccination_complete_date_day_of_week_index}=2 THEN 6
          WHEN ${HPV_vaccination_complete_date_day_of_week_index}=3 THEN 7
          END;;
      }


#   dimension: is_patient_eligible_for_next_HPV_dose {
#     type:  string
#     sql: CASE
#           WHEN  ${is_hpv_patient} = 'Yes' and ${date_first_shot_date} IS NULL THEN 'Yes'
#           WHEN  ${is_hpv_patient} = 'Yes' and ${date_first_shot_date} IS NOT NULL and ${date_second_shot_date} IS NULL
#           and datediff(day, ${patient_hpv.recommended__2nd_shot_date_start},getdate()) >= 0 THEN 'Yes'
#           WHEN  ${is_hpv_patient} = 'Yes' and ${date_first_shot_date} IS NOT NULL and ${date_second_shot_date} IS NOT NULL
#           and ${date_third_shot_date} IS NULL and datediff(day, ${patient_hpv.recommended__3rd_shot_date_start},getdate()) >= 0 THEN 'Yes'
#           WHEN  ${is_hpv_patient} = 'Yes' and ${date_first_shot_date} IS NOT NULL and ${date_second_shot_date} IS NOT NULL
#           and ${date_third_shot_date} IS NOT NULL and ${date_fourth_shot_date} IS NULL
#           and datediff(day, ${recommended__4th_shot_date_start},getdate()) >= 0 THEN 'Yes'
#           ELSE
#           'No'
#           END;;
#
#     html:
#     <div align="center"> {{rendered_value}} </div>
#     ;;
#
#   }
#

      dimension: is_patient_eligible_for_next_HPV_dose {
        type:  string
        sql: CASE
          WHEN  ${is_hpv_patient} = 'Yes' and ${date_first_shot_date} IS NULL THEN 'Yes'
          WHEN  ${is_hpv_patient} = 'Yes' and ${date_first_shot_date} IS NOT NULL and ${date_second_shot_date} IS NULL
          and datediff(day, ${patient_hpv.recommended__2nd_shot_date_start},${dos_detail.visit_date}) >= 0 THEN 'Yes'
          WHEN  ${is_hpv_patient} = 'Yes' and ${date_first_shot_date} IS NOT NULL and ${date_second_shot_date} IS NOT NULL
          and ${date_third_shot_date} IS NULL and datediff(day, ${patient_hpv.recommended__3rd_shot_date_start},${dos_detail.visit_date}) >= 0 THEN 'Yes'
          WHEN  ${is_hpv_patient} = 'Yes' and ${date_first_shot_date} IS NOT NULL and ${date_second_shot_date} IS NOT NULL
          and ${date_third_shot_date} IS NOT NULL and ${date_fourth_shot_date} IS NULL
          and datediff(day, ${recommended__4th_shot_date_start},${dos_detail.visit_date}) >= 0 THEN 'Yes'
          ELSE
          'No'
          END;;

        html:
          <div align="center"> {{rendered_value}} </div>
          ;;

      }

      measure: count_eligible_for_next_HPV_dose_now{
        type:  count
        filters: {
          field: is_patient_eligible_for_next_HPV_dose
          value: "Yes"
        }
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;

        drill_fields: [hpvdetail_distinct*]

      }

#   sql: CASE
#   WHEN (datediff(day, ${patient_hpv.date_first_shot_date},${visit_date}) <= 0 or ${patient_hpv.date_first_shot_date} IS NULL)
#   or (${patient_hpv.date_first_shot_date} IS NOT NULL and ${patient_hpv.date_second_shot_date} IS NULL
#   and datediff(day, ${patient_hpv.recommended__2nd_shot_date_start},${visit_date}) >= 0)
#   or (datediff(day, ${patient_hpv.date_second_shot_date},${visit_date}) <= 0)
#   or (${patient_hpv.date_first_shot_date} IS NOT NULL and ${patient_hpv.date_second_shot_date} IS NOT NULL
#   and ${patient_hpv.date_third_shot_date} IS NULL and datediff(day, ${patient_hpv.recommended__3rd_shot_date_start},${visit_date}) >= 0)
#   or (datediff(day, ${patient_hpv.date_third_shot_date},${visit_date}) <= 0)
#   THEN ${patientid}
#   ELSE
#   NULL
#   END;;



      dimension: is_patient_eligible_for_1st_HPV_dose {
        type:  string
        sql: CASE
          WHEN  ${is_hpv_patient_at_visit_timeframe} = 'Yes' and ${date_first_shot_date} IS NULL THEN 'Yes'
          WHEN  ${was_dose1_in_time_frame} = 'Yes' THEN 'Yes'

          ELSE
          'No'
          END;;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }


      dimension: is_patient_eligible_for_1st_HPV_dose_counter {
        hidden:  yes
        type:  number
        sql: CASE
          WHEN  ${is_hpv_patient} = 'Yes' and ${date_first_shot_date} IS NULL
          THEN 1
          ELSE
          0
          END;;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      measure: count_eligible_for_1st_dose_now{
        type:  count
        filters: {
          field: is_patient_eligible_for_1st_HPV_dose
          value: "Yes"
        }
#     filters: {
#       field: is_hpv_patient
#       value: "Yes"
#     }
#     filters: {
#       field: missing_first_shot
#       value: "Yes"
#     }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      dimension: was_patient_eligible_for_1st_HPV_dose_at_last_vist{
        type:  string
        sql: CASE
          WHEN  ${is_hpv_patient} = 'Yes' and
          datediff(day, ${date_first_shot_date},${dos_detail.visit_date}) <= 0 THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }


      dimension: was_patient_eligible_for_1st_HPV_dose_at_last_visit_yesno{
        type:  yesno
        sql:  ${is_hpv_patient} = 'Yes' and (datediff(day, ${date_first_shot_date},${dos_detail.visit_date}) <= 0 or ${date_first_shot_date} IS NULL) ;;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      measure: count_eligible_for_dose_1{
        type:  count_distinct
        sql: dos_detail.patientid ;;
        filters: {
          field: was_patient_eligible_for_1st_HPV_dose_at_last_visit_yesno
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      measure: count_eligible_no_dose_1{
        type:  count_distinct
        sql: dos_detail.patientid ;;
        filters: {
          field: was_patient_eligible_for_1st_HPV_dose_at_last_visit_yesno
          value: "Yes"
        }
        filters: {
          field: was_patient_eligible_for_1st_HPV_dose_at_last_vist
          value: "No"
        }
        filters: {
          field: was_refusal_after_dose_1
          value: "No"
        }
        filters: {
          field: patient_hpv_refusal.did_patient_refuse_HPV_at_last_vist
          value: "No"
        }

        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      dimension: dose_1_day_diff{
        type:  number
        sql:  datediff(day, ${date_first_shot_raw},${dos_detail.visit_raw}) <= 0;;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      dimension: dose_1_last_refusal_compare{
        type:  number
        sql:  CASE
                  WHEN datediff(day, ${date_first_shot_date},${patient_hpv_refusal.last_refusal})<= 100095 THEN datediff(day, ${date_first_shot_date},${patient_hpv_refusal.last_refusal})
                  ELSE NULL
                  END;;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      dimension: was_refusal_after_dose_1{
        type:  string
        sql:  CASE
                  WHEN ${dose_1_last_refusal_compare} >0 THEN 'Yes'
                  ELSE
                  'No'
                  END;;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      measure: count_eligible_and_received_1st_dose_timeframe{
        type:  count
        filters: {
          field: was_patient_eligible_for_1st_HPV_dose_at_last_vist
          value: "Yes"
        }
        filters: {
          field: is_hpv_patient
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }


      dimension: is_patient_eligible_for_2nd_HPV_dose {
        type:  string
        sql: CASE
          WHEN  ${is_hpv_patient} = 'Yes' and ${date_first_shot_date} IS NOT NULL and ${date_second_shot_date} IS NULL
          and datediff(day, ${patient_hpv.recommended__2nd_shot_date_start},getdate()) >= 0 THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      dimension: was_patient_eligible_for_2nd_HPV_dose_at_last_vist{
        type:  string
        sql: CASE
          WHEN  ${is_hpv_patient} = 'Yes' and
          datediff(day, ${date_second_shot_raw},${dos_detail.visit_raw}) <= 0 THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      dimension: is_patient_eligible_for_3rd_HPV_dose {
        type:  string
        sql: CASE
          WHEN  ${is_hpv_patient} = 'Yes' and ${date_first_shot_date} IS NOT NULL and ${date_second_shot_date} IS NOT NULL
          and ${date_third_shot_date} IS NULL and datediff(day, ${patient_hpv.recommended__3rd_shot_date_start},getdate()) >= 0 THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      dimension: was_patient_eligible_for_3rd_HPV_dose_at_last_vist{
        type:  string
        sql: CASE
          WHEN  ${is_hpv_patient} = 'Yes' and
          datediff(day, ${date_third_shot_raw},${dos_detail.visit_raw}) <= 0 THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      dimension: is_patient_eligible_for_4th_HPV_dose {
        type:  string
        sql: CASE
          WHEN  ${is_hpv_patient} = 'Yes' and ${date_first_shot_date} IS NOT NULL and ${date_second_shot_date} IS NOT NULL
          and ${date_third_shot_date} IS NOT NULL and ${date_fourth_shot_date} IS NULL
          and datediff(day, ${recommended__4th_shot_date_start},getdate()) >= 0 THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      dimension: was_patient_eligible_for_4th_HPV_dose_at_last_vist{
        type:  string
        sql: CASE
          WHEN  ${is_hpv_patient} = 'Yes' and
          datediff(day, ${date_fourth_shot_raw},${dos_detail.visit_raw}) <= 0 THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }
#
#   parameter: timeframe_picker {
#     label: "Date Granularity"
#     type: string
#     allowed_value: { value: "Future Appt Date" }
#     allowed_value: { value: "Actual Visit Date" }
#     allowed_value: { value: "Today" }
#     default_value: "Date"
#   }
#
#
#   dimension: dynamic_timeframe {
#     type: string
#     sql:
#     CASE
#     WHEN {% parameter timeframe_picker %} = 'Future Appt Date' THEN ${future_appointments.appt_date}
#     WHEN {% parameter timeframe_picker %} = 'Actual Visit Date' THEN ${dos_detail.visit_date}
#     WHEN{% parameter timeframe_picker %} = 'Today' THEN ${dos_detail.visit_date}
#     END ;;
#   }

      dimension: is_patient_eligible_for_next_dose{
        type:  string
        sql: CASE
          WHEN ${HPV_vaccination_complete} = 'Yes' and ${was_recommended_dose_given_at_visit_date} = 'Yes' THEN 'Yes'
          WHEN ${HPV_vaccination_complete} = 'No' and ${was_recommended_dose_given_at_visit_date} = 'Yes' THEN 'Yes'
          WHEN ${HPV_vaccination_complete} = 'No' and datediff(day, ${patient_hpv.recommended__3rd_shot_date_start},${dos_detail.visit_date}) >=0 THEN 'Yes'
          WHEN ${HPV_vaccination_complete} = 'No' and datediff(day, ${patient_hpv.recommended__2nd_shot_date_start},${dos_detail.visit_date}) >=0 THEN 'Yes'
          ELSE
          'No'
          END;;

        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

#   WHEN ${HPV_vaccination_complete} = 'No' and (datediff(day, ${patient_hpv.recommended__2nd_shot_date_start},${dos_detail.visit_date}) >=0 or
#           datediff(week, ${patient_hpv.date_second_shot_date},${dos_detail.visit_date}) =0) and
#           datediff(day, ${patient_hpv.recommended__3rd_shot_date_start},${dos_detail.visit_date}) IS NULL THEN 'Yes'

      dimension: was_recommended_dose_given_at_visit_date{
        type:  string
        sql: CASE
          WHEN datediff(week, ${patient_hpv.date_second_shot_date},${dos_detail.visit_date}) =0 THEN 'Yes'
          WHEN datediff(week, ${patient_hpv.date_third_shot_date},${dos_detail.visit_date}) =0 THEN 'Yes'
          ELSE
          'No'
          END
          ;;
      }

      measure: count_eligible_for_next_dose_last_wk{
        type:  count
        filters: {
          field: is_patient_eligible_for_next_dose
          value: "Yes"
        }
        filters: {
          field: dos_detail.visit_date
          value: "Last Week"
        }
        filters: {
          field: is_hpv_patient
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      measure: count_eligible_for_next_dose{
        type:  count
        filters: {
          field: is_patient_eligible_for_next_dose
          value: "Yes"
        }
        filters: {
          field: is_hpv_patient
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      measure: was_visit_last_wk_a_completion_opp{
        type:  number
        sql: CASE
          WHEN ${HPV_vaccination_complete}='Yes' and ${is_patient_eligible_for_next_dose}= 'Yes' and ${was_recommended_dose_given_at_visit_date}='Yes' THEN 1
          ELSE
          0
          END
          ;;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      dimension: did_patient_complete_session_at_last_vist{
        type:  string
        sql: CASE
          WHEN  ${is_hpv_patient} = 'Yes' and
          datediff(day, ${HPV_vaccination_complete_date_raw},${dos_detail.visit_raw}) <= 0 THEN 'Yes'
          ELSE
          'No'
          END;;
        html:
            <div align="left"> {{rendered_value}} </div>
            ;;
      }

      measure: count_completed_HPV_vaccinations {
        type:  count
        filters: {
          field: HPV_vaccination_complete
          value: "Yes"
        }
#     filters: {
#       field: data.is_current_patient_mhm
#       value: "Yes"
#     }
        drill_fields: [hpvdetail_distinct*]

        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      measure: count_completed_HPV_vaccinations_timeline {
        type:  count
        filters: {
          field: did_patient_complete_session_at_last_vist
          value: "Yes"
        }
        drill_fields: [hpvdetail_distinct*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      measure: count_completed_next_vaccinations_timeline {
        type:  count
        filters: {
          field: was_recommended_dose_given_at_visit_date
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }


      measure: count_completed_HPV_vaccinations_last_wk {
        type:  count
        filters: {
          field: HPV_vaccination_complete
          value: "Yes"
        }
        filters: {
          field: HPV_vaccination_complete_date_date
          value: "Last Week"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }


      measure: count_completed_HPV_vaccinations_female {
        type:  count
        filters: {
          field: HPV_vaccination_complete
          value: "Yes"
        }
        filters: {
          field: is_hpv_patient_female
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }
      measure: count_completed_HPV_vaccinations_male {
        type:  count
        filters: {
          field: HPV_vaccination_complete
          value: "Yes"
        }
        filters: {
          field: is_hpv_patient_male
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      # measure: count_seen_in_last_yr_completed_HPV_vaccinations {
      #   type:  count
      #   filters: {
      #     field: data.is_patient_seen_in_last_year
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: HPV_vaccination_complete
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: is_hpv_patient
      #     value: "Yes"
      #   }
      #   drill_fields: [hpvdetail*]
      #   html:
      #       <div align="center"> {{rendered_value}} </div>
      #       ;;
      # }
      # measure: count_seen_in_last_yr_completed_HPV_vaccinations_female {
      #   type:  count
      #   filters: {
      #     field: data.is_patient_seen_in_last_year
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: HPV_vaccination_complete
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: is_hpv_patient_female
      #     value: "Yes"
      #   }
      #   drill_fields: [hpvdetail*]
      #   html:
      #       <div align="center"> {{rendered_value}} </div>
      #       ;;
      # }

      measure: count_active_female_completed_HPV_vaccinations {
        description: "Patient has been seen in last 2 years"
        type:  count
        filters: {
          field: data.is_current_patient
          value: "Yes"
        }
        filters: {
          field: HPV_vaccination_complete
          value: "Yes"
        }
        filters: {
          field: is_hpv_age_female
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }
      # measure: count_seen_in_last_yr_completed_HPV_vaccinations_male {
      #   type:  count
      #   filters: {
      #     field: data.is_patient_seen_in_last_year
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: HPV_vaccination_complete
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: is_hpv_patient_male
      #     value: "Yes"
      #   }
      #   drill_fields: [hpvdetail*]
      #   html:
      #       <div align="center"> {{rendered_value}} </div>
      #       ;;
      # }

      measure: count_active_male_completed_HPV_vaccinations {
        description: "Patient has been seen in last 2 years"
        type:  count
        filters: {
          field: data.is_current_patient
          value: "Yes"
        }
        filters: {
          field: HPV_vaccination_complete
          value: "Yes"
        }
        filters: {
          field: is_hpv_age_male
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      # measure: count_seen_in_last_yr_initiated_not_complete {
      #   type:  count
      #   filters: {
      #     field: data.is_patient_seen_in_last_year
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: missing_first_shot
      #     value: "No"
      #   }
      #   filters: {
      #     field: HPV_vaccination_complete
      #     value: "No"
      #   }
      #   filters: {
      #     field: is_hpv_patient
      #     value: "Yes"
      #   }
      #   drill_fields: [hpvdetail*]

      #   html:
      #       <div align="center"> {{rendered_value}} </div>
      #       ;;
      # }

      measure: count_not_complete_female {
        type:  count
        filters: {
          field: data.is_current_patient
          value: "Yes"
        }
        filters: {
          field: missing_first_shot
          value: "No"
        }
        filters: {
          field: HPV_vaccination_complete
          value: "No"
        }
        filters: {
          field: is_hpv_patient
          value: "Yes"
        }
        # filters: {
        #   field: data.patient_is_female
        #   value: "Yes"
        # }
        filters: {
          field: is_hpv_age_female
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      measure: count_not_complete_male {
        type:  count
        filters: {
          field: data.is_current_patient
          value: "Yes"
        }
        filters: {
          field: missing_first_shot
          value: "No"
        }
        filters: {
          field: HPV_vaccination_complete
          value: "No"
        }
        filters: {
          field: is_hpv_patient
          value: "Yes"
        }
        # filters: {
        #   field: data.patient_is_male
        #   value: "Yes"
        # }
        filters: {
          field: is_hpv_age_male
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      # measure: count_seen_in_last_yr_initiated_not_complete_female {
      #   type:  count
      #   filters: {
      #     field: data.is_patient_seen_in_last_year
      #     value: "Yes"
      #   }

      #   filters: {
      #     field: missing_first_shot
      #     value: "No"
      #   }
      #   filters: {
      #     field: HPV_vaccination_complete
      #     value: "No"
      #   }
      #   filters: {
      #     field: is_hpv_patient
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: data.patient_is_female
      #     value: "Yes"
      #   }
#     filters: {
#       field: is_hpv_patient_female
#       value: "Yes"
#     }
      #   drill_fields: [hpvdetail*]
      #   html:
      #       <div align="center"> {{rendered_value}} </div>
      #       ;;
      # }

      # measure: count_seen_in_last_yr_initiated_not_complete_male {
      #   type:  count
      #   filters: {
      #     field: data.is_patient_seen_in_last_year
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: missing_first_shot
      #     value: "No"
      #   }
      #   filters: {
      #     field: HPV_vaccination_complete
      #     value: "No"
      #   }
      #   filters: {
      #     field: is_hpv_patient
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: data.patient_is_male
      #     value: "Yes"
      #   }
#     filters: {
#       field: is_hpv_patient_male
#       value: "Yes"
#     }
      #   drill_fields: [hpvdetail*]
      #   html:
      #       <div align="center"> {{rendered_value}} </div>
      #       ;;
      # }

      measure: count_initiated {
        description: "patients initated and have been seen in last 2 years"
        type:  count
        filters: {
          field: missing_first_shot
          value: "No"
        }
#     filters: {
#       field: data.is_current_patient_mhm
#       value: "Yes"
#     }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      measure: count_not_initiated {
        description: "patients initated and have been seen in last 2 years"
        type:  count
        filters: {
          field: missing_first_shot
          value: "Yes"
        }
        filters: {
          field: data.is_current_patient
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }


      measure: count_initiated_female {
        type:  count
        filters: {
          field: data.is_current_patient
          value: "Yes"
        }
        filters: {
          field: missing_first_shot
          value: "No"
        }
        filters: {
          field: is_hpv_patient
          value: "Yes"
        }
        # filters: {
        #   field: data.patient_is_female
        #   value: "Yes"
        # }
        filters: {
          field: is_hpv_age_female
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      measure: count_initiated_male {
        type:  count
        filters: {
          field: data.is_current_patient
          value: "Yes"
        }
        filters: {
          field: missing_first_shot
          value: "No"
        }
        filters: {
          field: is_hpv_patient
          value: "Yes"
        }
        # filters: {
        #   field: data.patient_is_male
        #   value: "Yes"
        # }
        filters: {
          field: is_hpv_age_male
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }


      # measure: count_seen_in_last_yr_initiated {
      #   type:  count
      #   filters: {
      #     field: data.is_patient_seen_in_last_year
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: missing_first_shot
      #     value: "No"
      #   }
      #   filters: {
      #     field: is_hpv_patient
      #     value: "Yes"
      #   }
      #   drill_fields: [hpvdetail*]
      #   html:
      #       <div align="center"> {{rendered_value}} </div>
      #       ;;
      # }

      # measure: count_seen_in_last_yr_initiated_female {
      #   type:  count
      #   filters: {
      #     field: data.is_patient_seen_in_last_year
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: missing_first_shot
      #     value: "No"
      #   }
      #   filters: {
      #     field: is_hpv_patient
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: data.patient_is_female
      #     value: "Yes"
      #   }
#     filters: {
#       field: is_hpv_patient_female
#       value: "Yes"
# #     }
#         drill_fields: [hpvdetail*]
#         html:
#             <div align="center"> {{rendered_value}} </div>
#             ;;
#       }
#       measure: count_seen_in_last_yr_initiated_male {
#         type:  count
#         filters: {
#           field: data.is_patient_seen_in_last_year
#           value: "Yes"
#         }
#         filters: {
#           field: missing_first_shot
#           value: "No"
#         }
#         filters: {
#           field: is_hpv_patient
#           value: "Yes"
#         }
#         filters: {
#           field: data.patient_is_male
#           value: "Yes"
#         }
# #     filters: {
# #       field: is_hpv_patient_male
# #       value: "Yes"
# #     }
#         drill_fields: [hpvdetail*]
#         html:
#             <div align="center"> {{rendered_value}} </div>
#             ;;
#       }



#   dimension: recommended__2nd_shot_date_start {
#     type:  date
#     sql: CASE
#           WHEN (${recommended_number_of_shots} >= 2 and ${recommended_number_of_shots} < 3) and ${had_first_shot} = 1 THEN DATEADD(month, 5, ${first_shot})
#           WHEN ${recommended_number_of_shots} = 3 and ${had_first_shot} = 1 THEN DATEADD(month, 1, ${first_shot})
#           ELSE
#           NULL
#           END;;
#     html:
#     <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
#     ;;
#   }

      dimension: recommended__2nd_shot_date_start {
        type:  date
        sql: CASE
          WHEN ${age_at_1st_shot} < 15  THEN DATEADD(month, 5, ${first_shot})
          WHEN ${age_at_1st_shot} > = 15  THEN DATEADD(month, 1, ${first_shot})
          ELSE
          NULL
          END;;
        html:
            <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
            ;;
      }


      dimension: recommended__2nd_shot_date_string {
        type:  string
        sql: CONVERT(varchar, ${recommended__2nd_shot_date_start}, 110) ;;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      dimension: recommended__3rd_shot_date_start {
        type:  date
        sql: CASE
          WHEN ${recommended_number_of_shots}<=2 THEN NULL
          WHEN ${had_first_shot} = 1  and ${second_shot} < ${recommended__2nd_shot_date_start} and (DATEADD(month, 5, ${first_shot}) >=  DATEADD(week, 12, ${second_shot})) THEN DATEADD(month, 5, ${first_shot})
          WHEN ${had_first_shot} = 1  and ${second_shot} < ${recommended__2nd_shot_date_start} and (DATEADD(month, 5, ${first_shot}) <  DATEADD(week, 12, ${second_shot})) THEN DATEADD(week, 12, ${second_shot})
          WHEN ${had_first_shot} = 1  and ${second_shot} >= ${recommended__2nd_shot_date_start} and (DATEADD(month, 5, ${first_shot}) >=  DATEADD(week, 12, ${second_shot})) THEN DATEADD(month, 5, ${first_shot})
          WHEN ${had_first_shot} = 1  and ${second_shot} >= ${recommended__2nd_shot_date_start} and (DATEADD(month, 5, ${first_shot}) <  DATEADD(week, 12, ${second_shot})) THEN DATEADD(week, 12, ${second_shot})
          ELSE
          NULL
          END;;
        html:
            <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
            ;;
      }


#   dimension: recommended__3rd_shot_date_start {
#     type:  date
#     sql: CASE
#           WHEN ${recommended_number_of_shots} = 3 and ${had_first_shot} = 1 and ${had_second_shot} = 1 and (DATEADD(month, 5, ${first_shot}) >=  DATEADD(week, 12, ${second_shot})) THEN DATEADD(month, 5, ${first_shot})
#           WHEN ${recommended_number_of_shots} = 3 and ${had_first_shot} = 1 and ${had_second_shot} = 1 and (DATEADD(month, 5, ${first_shot}) <   DATEADD(week, 12, ${second_shot})) THEN DATEADD(week, 12, ${second_shot})
#           ELSE
#           NULL
#           END;;
#     html:
#     <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
#     ;;
#   }

      dimension: recommended_3rd_shot_string {
        type:  string
        sql: CONVERT(varchar, ${recommended__3rd_shot_date_start}, 110)
          ;;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

#   dimension: recommended__4th_shot_date_start {
#     type:  date
#     sql: CASE
#           WHEN ${recommended_number_of_shots} = 4 and ${had_first_shot} = 1 and ${had_second_shot} = 1 and ${had_third_shot} = 1 and (DATEADD(month, 5, ${first_shot}) >=  DATEADD(week, 12, ${third_shot})) THEN DATEADD(month, 5, ${first_shot})
#           WHEN ${recommended_number_of_shots} = 4 and ${had_first_shot} = 1 and ${had_second_shot} = 1 and ${had_third_shot} = 1 and (DATEADD(month, 5, ${first_shot}) <   DATEADD(week, 12, ${third_shot})) THEN DATEADD(week, 12, ${third_shot})
#           ELSE
#           NULL
#           END;;
#     html:
#     <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
#     ;;
#   }

      dimension: recommended__4th_shot_date_start {
        type:  date
        sql: CASE
          WHEN ${recommended_number_of_shots}<=3 THEN NULL
          WHEN ${had_first_shot} = 1  and ${had_second_shot} = 1 and ${third_shot} < ${recommended__3rd_shot_date_start} and (DATEADD(month, 5, ${first_shot}) >=  DATEADD(week, 12, ${third_shot})) THEN DATEADD(month, 5, ${first_shot})
          WHEN ${had_first_shot} = 1  and ${had_second_shot} = 1 and ${third_shot} < ${recommended__3rd_shot_date_start} and (DATEADD(month, 5, ${first_shot}) <  DATEADD(week, 12, ${third_shot})) THEN DATEADD(week, 12, ${third_shot})
          WHEN ${had_first_shot} = 1  and ${had_second_shot} = 1 and ${third_shot} >= ${recommended__3rd_shot_date_start} and (DATEADD(month, 5, ${first_shot}) >=  DATEADD(week, 12, ${third_shot})) THEN DATEADD(month, 5, ${first_shot})
          WHEN ${had_first_shot} = 1  and ${had_second_shot} = 1 and ${third_shot} >= ${recommended__3rd_shot_date_start} and (DATEADD(month, 5, ${first_shot}) <  DATEADD(week, 12, ${third_shot})) THEN DATEADD(week, 12, ${third_shot})
          ELSE
          NULL
          END;;
        html:
            <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
            ;;
      }


      dimension: recommended_4th_shot_string {
        type:  string
        sql: CONVERT(varchar, ${recommended__4th_shot_date_start}, 110)
          ;;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

#   dimension: recommended_3rd_shot_string {
#     type:  string
#     sql: CASE
#           WHEN ${recommended_number_of_shots} = 2.1 and  ${recommended_number_of_shots} <= 3) and ${had_first_shot} = 1 and ${had_second_shot} = 1
#           and (DATEADD(month, 5, ${first_shot}) >=  DATEADD(week, 12, ${second_shot})) THEN CONVERT(varchar, DATEADD(month, 5, ${first_shot}), 110)
#           WHEN (${recommended_number_of_shots} >= 2.1 and  ${recommended_number_of_shots} <= 3) and ${had_first_shot} = 1 and ${had_second_shot} = 1
#           and (DATEADD(month, 5, ${first_shot}) <  DATEADD(week, 12, ${second_shot})) THEN CONVERT(varchar, DATEADD(week, 12, ${second_shot}), 110)
#           ELSE
#           NULL
#           END;;
#     html:
#     <div align="center"> {{rendered_value}} </div>
#     ;;
#   }


#   dimension: latest_date_to_start_shot_3 {
#     type: date
#     sql:  CASE
#             WHEN DATEADD(month, 5, ${first_shot}) >=  DATEADD(week, 12, ${second_shot}) THEN DATEADD(month, 5, ${first_shot})
#             WHEN DATEADD(month, 5, ${first_shot}) <   DATEADD(week, 12, ${second_shot}) THEN DATEADD(week, 12, ${second_shot})
#             ELSE
#             NULL
#             END
#             ;;
#
# }
#
#   dimension: recommended__3rd_shot_date_end {
#     type:  date
#     sql: CASE
#           WHEN ${recommended_number_of_shots} = 3 and ${had_first_shot} = 1 and ${had_second_shot} = 1 THEN DATEADD(month, 1, ${recommended__3rd_shot_date_start})
#           ELSE
#           NULL
#           END;;
#     html:
#     <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
#     ;;
#   }


      dimension: days_since_shot_1 {
        type:  number
        sql: CAST(DATEDIFF(day,${first_shot},getdate())AS INTEGER);;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

#
#   dimension: age_at_1st_shot{
#     type: number
#     # sql: CAST(DATEDIFF(year,${dob_date},getdate()-365) AS INTEGER) ;;
#     sql: CAST(DATEDIFF(day,${data.dob_date},${date_first_shot_date})/365.25 AS INTEGER) ;;
#
#     html:
#     <div align="center"> {{rendered_value}} </div>
#     ;;
#   }

      dimension: age_at_1st_shot  {
        type:  number
        sql:  CASE
            WHEN (MONTH(${date_first_shot_date})*100)+DAY(${date_first_shot_date}) >= (MONTH(${data.dob_date})*100)+DAY(${data.dob_date}) THEN
            DATEDIFF(Year,${data.dob_date},${date_first_shot_date})
            ELSE DATEDIFF(Year,${data.dob_date},${date_first_shot_date})-1
            END
            ;;
        html:
             <div align="center"> {{rendered_value}} </div>
            ;;
      }

      dimension: first_shot {
        type:  date
        sql: ${date_first_shot_date} ;;
        html:
            <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
            ;;
      }

      dimension: had_first_shot {
        type: number
        sql: CASE
          WHEN ${date_first_shot_date} IS NULL THEN 0
          ELSE
          1
          END;;
      }

      dimension: had_first_shot_yesno {
        type: yesno
        sql: ${date_first_shot_date} IS NOT NULL;;
      }

      dimension: was_first_shot_last_wk{
        type: string
        sql: CASE
                WHEN ${had_first_shot}=1 and (${date_first_shot_date} > = DATEADD(WEEK,-2,getdate())) THEN 'Yes'
                ELSE
                'No'
                END;;
      }


      dimension: missing_first_shot {
        type: string
        sql:  CASE
            WHEN ${date_first_shot_date} IS NULL THEN 'Yes'
            ELSE
            'No'
            END;;
      }

      dimension: status_first_shot {
        type:  string
        sql: CASE
          WHEN ${TABLE}.Status_First_Shot IS NULL THEN ''
          ELSE
          ${TABLE}.Status_First_Shot
          END;;
      }

      dimension: comment_first_shot {
        type:  string
        sql:  CASE
          WHEN ${TABLE}.Comment_First_shot IS NULL THEN ''
          ELSE
          ${TABLE}.Comment_First_shot
          END;;
      }

      dimension: reason_first_shot {
        type:  string
        sql:  CASE
          WHEN ${TABLE}.Reason_First_shot IS NULL THEN ''
          ELSE
          ${TABLE}.Reason_First_shot
          END;;
      }

      dimension: status_second_shot {
        type:  string
        sql: CASE
              WHEN ${TABLE}.Status_Second_Shot IS NULL THEN ''
              ELSE
              ${TABLE}.Status_Second_Shot
              END;;
      }

      dimension: comment_second_shot {
        type:  string
        sql: CASE
              WHEN ${TABLE}.Comment_Second_Shot IS NULL THEN ''
              ELSE
              ${TABLE}.Comment_Second_Shot
              END;;
      }

      dimension: reason_second_shot {
        type:  string
        sql: CASE
              WHEN ${TABLE}.Reason_Second_Shot IS NULL THEN ''
              ELSE
              ${TABLE}.Reason_Second_Shot
              END;;
      }

      dimension: status_third_shot {
        type:  string
        sql: CASE
          WHEN ${TABLE}.Status_THIRD_Shot IS NULL THEN ''
          ELSE
          ${TABLE}.Status_Third_Shot
          END;;
      }

      dimension_group: date_fourth_shot {
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
        sql: ${TABLE}.Date_Fourth_shot ;;
      }

      dimension: fourth_shot {
        type:  date
        sql: ${date_fourth_shot_date} ;;
        html:
            <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
            ;;
      }

      dimension: had_fourth_shot {
        type: number
        sql: CASE
          WHEN ${date_fourth_shot_date} IS NULL THEN 0
          ELSE
          1
          END;;
      }

      dimension: days_since_shot_2 {
        type:  number
        sql: CAST(DATEDIFF(day,${second_shot},getdate())AS INTEGER);;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      dimension_group: date_second_shot {
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
        sql: ${TABLE}.Date_Second_shot ;;
      }

      dimension: second_shot {
        type:  date
        sql: ${date_second_shot_date} ;;
        html:
            <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
            ;;
      }

      dimension: had_second_shot {
        type: number
        sql: CASE
          WHEN ${date_second_shot_date} IS NULL THEN 0
          ELSE
          1
          END;;
      }

      dimension_group: date_seventh_shot {
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
        sql: ${TABLE}.Date_Seventh_shot ;;
      }

      dimension: seventh_shot {
        type:  date
        sql: ${date_seventh_shot_date} ;;
        html:
            <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
            ;;
      }

      dimension: had_seventh_shot {
        type: number
        sql: CASE
          WHEN ${date_seventh_shot_date} IS NULL THEN 0
          ELSE
          1
          END;;
      }

      dimension_group: date_sixth_shot {
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
        sql: ${TABLE}.Date_Sixth_shot ;;
      }

      dimension: sixth_shot {
        type:  date
        sql: ${date_sixth_shot_date} ;;
        html:
            <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
            ;;
      }

      dimension: had_sixth_shot {
        type: number
        sql: CASE
          WHEN ${date_sixth_shot_date} IS NULL THEN 0
          ELSE
          1
          END;;
      }

      dimension_group: date_third_shot {
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
        sql: ${TABLE}.Date_Third_shot ;;
      }

      dimension: third_shot {
        type:  date
        sql: ${date_third_shot_date} ;;
        html:
            <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
            ;;
      }

      dimension: had_third_shot {
        type: number
        sql: CASE
          WHEN ${date_third_shot_date} IS NULL THEN 0
          ELSE
          1
          END;;
      }

      dimension: patientid {
        primary_key: yes
        type: number
        sql: ${TABLE}.PatientID ;;
        value_format_name: id
      }

      dimension: practice_id {
        type: number
        sql: ${TABLE}.PracticeID ;;
        value_format_name: id
      }

      dimension: type {
        type: string
        sql: ${TABLE}.Type ;;
      }

      measure: patients_with_1_shot {
        type: sum
        sql: ${had_first_shot};;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
        drill_fields: [hpvdetail*]
      }
#
#   measure: patients_with_no_shots {
#     type: count
#     sql: ${TABLE}.Date_First_shot IS NULL;;
#     html:
#     <div align="center"> {{rendered_value}} </div>
#     ;;
#     drill_fields: [hpvdetail*]
#   }

      measure: count_patients_with_no_shots {
        description: "Patients with no HPV Shots"
        type: count
        filters: {
          field: missing_first_shot
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
      }

      # measure: count_patients_seen_in_last_yr_with_no_shots {
      #   group_label: "no doses - in last year"
      #   description: "Patients seen within a year with no HPV Shots"
      #   type: count
      #   filters: {
      #     field: data.is_patient_seen_in_last_year
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: missing_first_shot
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: is_hpv_patient
      #     value: "Yes"
      #   }
      #   drill_fields: [hpvdetail*]
      # }

      measure: count_patients_current_patients_with_no_shots {
        description: "Current Patients in correct age with no HPV Shots"
        type: count
        filters: {
          field: data.is_current_patient
          value: "Yes"
        }
        filters: {
          field: missing_first_shot
          value: "Yes"
        }
        filters: {
          field: is_hpv_eligible_age
          value: "Yes"
        }
        drill_fields: [hpvdetail*]
      }


      # measure: count_patients_seen_in_last_yr_with_no_shots_female {
      #   group_label: "no doses - in last year"
      #   description: "Patients seen within a year with no HPV Shots"
      #   type: count
      #   filters: {
      #     field: data.is_patient_seen_in_last_year
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: missing_first_shot
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: is_hpv_patient
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: data.patient_is_female
      #     value: "Yes"
      #   }
#     filters: {
#       field: is_hpv_patient_female
#       value: "Yes"
# #     }
#         drill_fields: [hpvdetail*]
#       }

      measure: count_current_female_patients_seen_in_last_3_yrs_with_no_shots {
        group_label: "no doses - in last 2 years"
        description: "Patients seen in last 2 years with no HPV Shots"
        type: count
        filters: {
          field: data.is_current_patient
          value: "Yes"
        }
        filters: {
          field: missing_first_shot
          value: "Yes"
        }
        filters: {
          field: is_hpv_patient
          value: "Yes"
        }
        filters: {
          field: is_hpv_patient_female
          value: "Yes"

        }
#     filters: {
#       field: is_hpv_age_female
#       value: "Yes"
#     }

        drill_fields: [hpvdetail*]
      }

      # measure: count_patients_seen_in_last_yr_with_no_shots_male {
      #   group_label: "no doses - in last year"
      #   description: "Patients seen within a year with no HPV Shots"
      #   type: count
      #   filters: {
      #     field: data.is_patient_seen_in_last_year
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: missing_first_shot
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: is_hpv_patient
      #     value: "Yes"
      #   }
      #   filters: {
      #     field: data.patient_is_male
      #     value: "Yes"
      #   }
#     filters: {
#       field: is_hpv_patient_male
#       value: "Yes"
# #     }
#         drill_fields: [hpvdetail*]
#       }

      measure: count_current_male_patients_seen_in_last_3_yrs_with_no_shots {
        group_label: "no doses - in last 2 years"
        description: "Patients seen in last 2 years with no HPV Shots"
        type: count
        filters: {
          field: data.is_current_patient
          value: "Yes"
        }
        filters: {
          field: missing_first_shot
          value: "Yes"
        }
        filters: {
          field: is_hpv_patient
          value: "Yes"
        }
        filters: {
          field: is_hpv_patient_male
          value: "Yes"
        }
#     filters: {
#       field: is_hpv_age_male
#       value: "Yes"
#     }
        drill_fields: [hpvdetail*]
      }

      measure: patients_with_2_shots {
        type: sum
        sql: ${had_second_shot};;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
        drill_fields: [hpvdetail*]
      }

      measure: patients_with_3_shots {
        type: sum
        sql: ${had_third_shot};;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
        drill_fields: [hpvdetail*]
      }


      measure: patients_with_4_shots_or_more {
        type: sum
        sql: ${had_fourth_shot}+${had_fifth_shot}+${had_sixth_shot}+${had_seventh_shot}+${had_eighth_shot};;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
        drill_fields: [hpvdetail*]
      }


      measure: total_shots{
        type: sum
        sql: ${had_first_shot}+${had_second_shot}+${had_third_shot}+${had_fourth_shot}+${had_fifth_shot}+${had_sixth_shot}+${had_seventh_shot}+${had_eighth_shot} ;;
        drill_fields: [hpvdetail*]
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      measure: count_patients_not_initiated{
        type: number
        sql: ${count_current_patients}-${patients_with_1_shot};;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
        drill_fields: [hpvdetail*]
      }

      dimension: last_dose {
        type: date
        sql:  CASE
                WHEN ${date_fifth_shot_date} IS NOT NULL THEN ${date_fifth_shot_date}
                WHEN ${date_fourth_shot_date} IS NOT NULL THEN ${date_fourth_shot_date}
                WHEN ${date_third_shot_date} IS NOT NULL THEN ${date_third_shot_date}
                WHEN ${date_second_shot_date} IS NOT NULL THEN ${date_second_shot_date}
                WHEN ${date_first_shot_date} IS NOT NULL THEN ${date_first_shot_date}
                ELSE
                NULL
                END
                ;;
        html:
            <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
            ;;
      }

      dimension:  last_dose_in_timeframe {
        type: yesno
        sql: {% condition patient_hpv.timeframe_filter %} ${last_dose} {% endcondition %};;
        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      dimension:  last_dose_is_null {
        type: yesno
        sql:  ${last_dose} IS NULL ;;

        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }




      measure: count_of_last_dose_in_timeframe {
        type: count
        filters: {
          field: last_dose_in_timeframe
          value: "yes"
        }
        drill_fields: [patient_hpv.hpvdetail_distinct*]

        html:
            <div align="center"> {{rendered_value}} </div>
            ;;
      }

      dimension: last_dose_follow_up {
        description: "Last HPV dose that is not the first dose or initiation"
        type: date
        sql:  CASE
                WHEN ${date_fifth_shot_date} IS NOT NULL THEN ${date_fifth_shot_date}
                WHEN ${date_fourth_shot_date} IS NOT NULL THEN ${date_fourth_shot_date}
                WHEN ${date_third_shot_date} IS NOT NULL THEN ${date_third_shot_date}
                WHEN ${date_second_shot_date} IS NOT NULL THEN ${date_second_shot_date}
                ELSE
                NULL
                END
                ;;
        html:
            <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
            ;;
      }

      measure: count_HPV_vaccinations_last_wk {
        type:  count
        filters: {
          field: last_dose
          value: "Last Week"
        }
        drill_fields: [hpvdetail*]
#     drill_fields: [patientid, data.patient_name, data.patient_mrn, data.age, data.sex, visit_date, payerid, payers.payer_name, patient_hpv.date_first_shot_date]
      }


#   measure: count_HPV_vaccinations {
#     type:  count_distinct
#     sql:   CASE
#             WHEN ${last_dose} is NOT NULL THEN ${dos_detail.patientid}
#             ELSE
#             NULL
#             END ;;
#     drill_fields: [hpvdetail*]
# #     drill_fields: [patientid, data.patient_name, data.patient_mrn, data.age, data.sex, visit_date, payerid, payers.payer_name, patient_hpv.date_first_shot_date]
#   }

      measure: count_HPV_vaccinations {
        type:  count
        filters: {
#       field: did_patient_have_a_dose_at_last_vist
        field: last_dose_in_timeframe
        value: "Yes"
      }
#     filters: {
#       field: data.is_current_patient_mhm
#       value: "Yes"
#     }
      drill_fields: [hpvdetail*]
      html:
          <div align="center"> {{rendered_value}} </div>
          ;;
    }

    measure: count_HPV_vaccinations_last_visit{
      type:  count
      filters: {
        field: did_patient_have_a_dose_at_last_vist
#     field: last_dose_in_timeframe
        value: "Yes"
      }
#     filters: {
#       field: data.is_current_patient_mhm
#       value: "Yes"
#     }
      drill_fields: [hpvdetail*]
      html:
          <div align="center"> {{rendered_value}} </div>
          ;;
    }

#   measure: count_HPV_vaccinations {
#     type:  count
#     sql:   CASE
#             WHEN ${last_dose} is NOT NULL THEN ${dos_detail.patientid}
#             ELSE
#             NULL
#             END ;;
#     drill_fields: [hpvdetail*]
#     drill_fields: [patientid, data.patient_name, data.patient_mrn, data.age, data.sex, visit_date, payerid, payers.payer_name, patient_hpv.date_first_shot_date]
#   }


    measure: count_HPV_vaccinations_follow_up {
      type:  count_distinct
      sql:   CASE
            WHEN ${last_dose_follow_up} is NOT NULL THEN ${dos_detail.patientid}
            ELSE
            NULL
            END ;;
      drill_fields: [hpvdetail*]
#     drill_fields: [patientid, data.patient_name, data.patient_mrn, data.age, data.sex, visit_date, payerid, payers.payer_name, patient_hpv.date_first_shot_date]
    }

#   measure: count_patients_initiated_not_complete{
#     type: number
#     sql: ${patients_with_1_shot}-${count_completed_HPV_vaccinations};;
#     html:
#     <div align="center"> {{rendered_value}} </div>
#     ;;
#     drill_fields: [hpvdetail*]
    # }


    measure: count_patients_initiated_not_complete {
      description: "Current Patients in initiated, but not complete"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: missing_first_shot
        value: "No"
      }
      filters: {
        field: HPV_vaccination_complete
        value: "No"
      }
      drill_fields: [hpvdetail*]
    }

    dimension: patient_completion_date {
      type:  date
      sql:  CASE
          WHEN ${had_second_shot} = 1 and ${recommended_number_of_shots} = 2 and ${date_second_shot_date} >= ${recommended__2nd_shot_date_start} THEN ${date_second_shot_date}
          WHEN ${had_third_shot} = 1 and ${recommended_number_of_shots} = 3 and ${date_third_shot_date} >= ${recommended__3rd_shot_date_start} THEN ${date_third_shot_date}
          WHEN ${had_fourth_shot} = 1 and ${recommended_number_of_shots} = 4 and ${date_fourth_shot_date} >= ${recommended__4th_shot_date_start} THEN ${date_fourth_shot_date}
          ELSE
          NULL
          END
          ;;
      html:
          <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div>
          ;;
    }

    dimension: is_hpv_series_complete {
      type:  string
      sql:  CASE
          WHEN ${had_second_shot} = 1 and ${recommended_number_of_shots} = 2 and ${date_second_shot_date} >= ${recommended__2nd_shot_date_start} THEN 'Yes'
          WHEN ${had_third_shot} = 1 and ${recommended_number_of_shots} = 3 and ${date_third_shot_date} >= ${recommended__3rd_shot_date_start} THEN 'Yes'
          WHEN ${had_fourth_shot} = 1 and ${recommended_number_of_shots} = 4 and ${date_fourth_shot_date} >= ${recommended__4th_shot_date_start} THEN 'Yes'
          ELSE
          'No'
          END
          ;;
      html:
          <div align="center"> {{rendered_value}} </div>
          ;;
    }

    dimension: is_hpv_series_complete_before_2019 {
      type:  string
      sql:  CASE
          WHEN ${had_second_shot} = 1 and ${recommended_number_of_shots} = 2 and ${date_second_shot_date} >= ${recommended__2nd_shot_date_start} and ${patient_completion_date}< '2019-01-01' THEN 'Yes'
          WHEN ${had_third_shot} = 1 and ${recommended_number_of_shots} = 3 and ${date_third_shot_date} >= ${recommended__3rd_shot_date_start} and ${patient_completion_date}< '2019-01-01' THEN 'Yes'
          WHEN ${had_fourth_shot} = 1 and ${recommended_number_of_shots} = 4 and ${date_fourth_shot_date} >= ${recommended__4th_shot_date_start} and ${patient_completion_date}< '2019-01-01' THEN 'Yes'
          ELSE
          'No'
          END
          ;;
    }

#   measure: count_patients_complete{
#     type: number
#     filters: {
#       field: is_hpv_series_complete
#       value: "Yes"
#     }
#     drill_fields: [hpvdetail*]
#   }


    # measure: count_patients_seen_within_1_yr{
    #   group_label: "patients - in last year"
    #   description: "Patient has been seen within 1 year and is not deceased"
    #   type: count
    #   filters: {
    #     field: data.is_patient_seen_in_last_year
    #     value: "Yes"
    #   }
    #   drill_fields: [hpvdetail*]
    # }

    # measure: count_current_patients_hpv_age {
    #   group_label: "patients - in last year"
    #   description: "Patient has been seen within the last year and is not deceased and is correct HPV age"
    #   type: count
    #   filters: {
    #     field: is_hpv_patient
    #     value: "Yes"
    #   }
    #   filters: {
    #     field: data.is_patient_seen_in_last_year
    #     value: "Yes"
    #   }
    #   drill_fields: [hpvdetail*]
    # }

    measure: count_current_patients {
      description: "Patient has been seen within the last 2 years and is not deceased"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      drill_fields: [hpvdetail*]
    }


    measure: count_current_patients_not_initiated {
      description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      filters: {
        field:missing_first_shot
        value: "Yes"
      }
      drill_fields: [hpvdetail*]
    }

    measure: count_current_patients_not_initiated_last_wk {
      description: "Patient seen last week who are HPV eligible but not initiated"
      type: count
      filters: {
        field: dos_detail.visit_date
        value: "Last Week"
      }
#       filters: {
#         field: is_hpv_patient
#         value: "Yes"
#       }
#       filters: {
#         field: missing_first_shot
#         value: "Yes"
#       }
      drill_fields: [hpvdetail*]
    }

    measure: count_current_patients_initiated_last_week{
      description: "Patient seen last week and received first shot"
      type: count
      filters: {
        field: date_first_shot_date
        value: "Last Week"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      filters: {
        field: missing_first_shot
        value: "No"
      }
      drill_fields: [hpvdetail*]
    }


    measure: count_current_patients_initiated{
      description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      filters: {
        field: missing_first_shot
        value: "No"
      }
      drill_fields: [hpvdetail*,recommended__2nd_shot_date_start]
    }

    measure: count_current_patients_not_complete {
      description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      filters: {
        field: missing_first_shot
        value: "No"
      }
      filters: {
        field: is_hpv_series_complete
        value: "No"
      }
      drill_fields: [hpvdetail*]
    }

    measure: count_current_patients_complete {
      description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_series_complete
        value: "Yes"
      }
      drill_fields: [hpvdetail*]
    }


    measure: count_current_patients_female {
      description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient_female
        value: "Yes"
      }
      drill_fields: [hpvdetail*]
    }

    measure: count_current_patients_not_initiated_female {
      description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient_female
        value: "Yes"
      }
      filters: {
        field: missing_first_shot
        value: "Yes"
      }
      drill_fields: [hpvdetail*]
    }


    measure: count_current_patients_initiated_female {
      description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient_female
        value: "Yes"
      }
      filters: {
        field: missing_first_shot
        value: "No"
      }
      drill_fields: [hpvdetail*]
    }

    measure: count_current_patients_not_complete_female {
      description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient_female
        value: "Yes"
      }
      filters: {
        field: missing_first_shot
        value: "No"
      }
      filters: {
        field: is_hpv_series_complete
        value: "No"
      }
      drill_fields: [hpvdetail*]
    }

    measure: count_current_patients_complete_female {
      description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      # filters: {
      #   field: data.sex
      #   value: "F"
      # }
      filters: {
        field: is_hpv_patient_female
        value: "Yes"
      }
      filters: {
        field: is_hpv_series_complete
        value: "Yes"
      }
      drill_fields: [hpvdetail*]
    }


    measure: count_current_patients_male {
      description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
#       filters: {
#         field: data.sex
#         value: "M"
#       }
      filters: {
        field: is_hpv_patient_male
        value: "Yes"
      }
      drill_fields: [hpvdetail*]
    }

    measure: count_current_patients_not_initiated_male {
      description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      # filters: {
      #   field: data.sex
      #   value: "M"
      # }
      filters: {
        field: is_hpv_patient_male
        value: "Yes"
      }
      filters: {
        field: missing_first_shot
        value: "Yes"
      }
      drill_fields: [hpvdetail*]
    }

    measure: count_current_patients_initiated_male {
      description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      # filters: {
      #   field: data.sex
      #   value: "M"
      # }
      filters: {
        field: is_hpv_patient_male
        value: "Yes"
      }
      filters: {
        field: missing_first_shot
        value: "No"
      }
      drill_fields: [hpvdetail*]
    }

    measure: count_current_patients_not_complete_male {
      description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      # filters: {
      #   field: data.sex
      #   value: "M"
      # }
      filters: {
        field: is_hpv_patient_male
        value: "Yes"
      }
      filters: {
        field: missing_first_shot
        value: "No"
      }
      filters: {
        field: is_hpv_series_complete
        value: "No"
      }
      drill_fields: [hpvdetail*]
    }

    measure: count_current_patients_complete_male {
      description: "Patient has been seen within the last 2 years and is not deceased - includes older patients"
      type: count
      filters: {
        field: data.is_current_patient
        value: "Yes"
      }
      filters: {
        field: is_hpv_patient
        value: "Yes"
      }
      # filters: {
      #   field: data.sex
      #   value: "M"
      # }
      filters: {
        field: is_hpv_patient_male
        value: "Yes"
      }
      filters: {
        field: is_hpv_series_complete
        value: "Yes"
      }
      drill_fields: [hpvdetail*]
    }

    measure: count {
      type: count
      html:
          <div align="center"> {{rendered_value}} </div>
          ;;
      drill_fields: [hpvdetail*]
    }

    set: hpvdetail {
      fields: [data.patient_mrn,
        data.patient_name,
        data.sex,
        data.age,
        data.dob_format,
        data.last_Appt,
        data.Next_Appt,
        pcp.pcp_name,
        provider.provider_name,
        first_shot,
        second_shot,
        third_shot,
        patient_hpv_refusal.last_refusal,
        hpv_status,
        HPV_vaccination_complete_date_date,
        HPV_vaccination_complete,
        total_shots]
    }
    set: hpvdetail_distinct {
      fields: [data.patient_mrn,
        data.patient_name,
        data.sex,
        data.dob_format,
        pcp.pcp_name,
        first_shot,
        second_shot,
        third_shot,
        patient_hpv_refusal.last_refusal,
        hpv_status,
        HPV_vaccination_complete_date_date,
        HPV_vaccination_complete,
        total_shots]
    }
  }
