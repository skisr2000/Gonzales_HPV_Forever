
########################################################################################################
#
#  Purpose: One row per patient. Precalculate frequently accessed patient qualities such as
#           ages, gender, etc.
#
#  Author:  Data Clymer (www.dataclymer.com | hello@dataclymer.com )
#
########################################################################################################

  view: data {
    derived_table: {
      sql:
      SELECT CONCAT('hidden - ', d.patient_alias) AS patient_detail_hidden,
             CASE WHEN d.locationid = 112 THEN 1877
                  WHEN d.locationid = 142 THEN 1877
                  WHEN d.locationid = 156 THEN 1877
                  WHEN d.locationid = 152 THEN 1878
                  WHEN d.locationid = 229 THEN 1878
                  WHEN d.locationid = 230 THEN 1878
                  WHEN d.locationid = 237 THEN 1878
                  WHEN d.locationid = 369 THEN 1878
                  ELSE d.pcpid
             END AS pcp_id,
             CASE WHEN d.sex = 'F' THEN 'F'
                  WHEN d.sex = 'M' THEN 'M'
                  ELSE 'U'
             END AS sex_with_undefined,
             -- Calculate age by comparing DOB with current date
             CASE WHEN (MONTH(getdate()) * 100) + DAY(getdate()) >= (MONTH(d.dob) * 100) + DAY(d.dob)
                  THEN DATEDIFF(year, d.dob, getdate())
                  ELSE DATEDIFF(year, d.dob, getdate()) - 1
             END AS age,
             LEFT(d.zip_code, 5) AS zipcode_5,
             DATEDIFF(day, d.last_visit_date, GETDATE()) AS days_since_last_visit,
             DATEDIFF(year, d.dob,d.last_visit_date) AS age_at_last_encounter,
            -- CASE WHEN c.pre_diabetes = 1 AND d.hba1c_current > 0 AND d.hba1c_pre_test > 0 AND (d.hba1c_current - d.hba1c_pre_test < 0) THEN 1
                  --ELSE 0
             --END AS hba1c_went_down,
             d.*
      FROM mhm.data d
      LEFT JOIN mhm.chronic c
        ON d.patientid = c.patientid ;;
    }

    dimension: patient_id {
      primary_key: yes
      view_label: "Commonly Used Fields"
      type: number
      sql: ${TABLE}.patientid ;;
      value_format_name: id
    }

    dimension: practice_id_as_text {
      type: string
      sql: LEFT(${TABLE}.patientid,4) ;;
    }

    dimension: patient_alias {
      type: string
      sql: CASE
         WHEN datalength(${TABLE}.patient_alias) > 0 THEN ${TABLE}.patient_alias
         WHEN datalength(${TABLE}.patient_alias) = 0 and ${sex} = 'F' THEN 'Sarah Smith'
         WHEN datalength(${TABLE}.patient_alias) = 0 and ${sex} = 'M' THEN 'Jack Nicholson'
        ELSE
         'Roger Rabbit'
         END;;
    }

    dimension: age {
      group_label: "Demographics"
      type: number
      sql: ${TABLE}.age ;;
      html: <div align="center"> {{rendered_value}} </div> ;;
    }

    dimension: age_at_last_encounter {
      group_label: "Appointment Info"
      type: number
      sql: ${TABLE}.age_at_last_encounter ;;
      html: <div align="center"> {{rendered_value}} </div> ;;
    }

    dimension: age_tier {
      group_label: "Patient Information - Age Tiers"
      type: tier
      style: integer
      tiers: [10,20,30,40,50,60,70,80,90]
      sql: ${age} ;;
    }

    dimension: rmoms_age_tier {
      group_label: "Patient Information - Age Tiers"
      type: tier
      style: integer
      tiers: [3,12,30,40,50,60]
      sql: ${age} ;;
    }

    dimension: age_tier_alternate {
      group_label: "Patient Information - Age Tiers"
      type: tier
      style: integer
      tiers: [40,45,50,55,60,65]
      sql: ${age} ;;
    }

    dimension: chcsct_hpv_age_tier {
      group_label: "Patient Information - Age Tiers"
      type: tier
      style: integer
      tiers: [18,27,30,66]
      sql: ${age} ;;
    }

    dimension: annual_income {
      group_label: "Demographics"
      type: number
      sql: ${TABLE}.annual_income ;;
      value_format_name: usd_0
    }

    dimension: annual_income_tier {
      group_label: "Demographics"
      type: tier
      style: integer
      tiers: [10000,20000,30000,40000,50000,60000, 70000, 80000, 90000, 100000]
      sql: ${annual_income} ;;
      value_format_name: usd_0
    }

    ###########################################
    ####CHCSCT Gonzales Risk Stratification####
    ###########################################

    # dimension: CHCSCT_risk_strat {
    #   group_label: "CHCSCT Risk Strat"
    #   type: string
    #   sql: CASE
    #     WHEN (${chronic.hypertension_numeric} =1 and (${last_patient_tests.systolic} >= 140 OR ${last_patient_tests.diastolic} >= 90)) or (${chronic.diabetes_numeric} =1  and ${last_patient_tests.CHCSCT_last_hba1c_result} >= 8) THEN 'High Risk'
    #     WHEN (${chronic.hypertension_numeric} =1 and ${last_patient_tests.systolic} < 140 AND ${last_patient_tests.diastolic} < 90) or (${chronic.diabetes_numeric} =1  and ${last_patient_tests.CHCSCT_last_hba1c_result} < 8) THEN 'Medium Risk'
    #     WHEN ${chronic.prediabetes_numeric} =1 or ${last_patient_tests.last_bmi_result} >25 or ${is_smoker} THEN 'Low Risk'
    #     ELSE
    #     'No Rules Match'
    #     END;;
    # }

    # dimension: CHCSCT_risk_order {
    #   type: number
    #   sql:  CASE
    #           WHEN ${CHCSCT_risk_strat} = 'Low Risk' THEN 1
    #           WHEN ${CHCSCT_risk_strat} = 'Medium Risk' THEN 2
    #           WHEN ${CHCSCT_risk_strat} = 'High Risk' THEN 3
    #           ELSE 4
    #           END;;
    # }

    dimension: city {
      group_label: "Demographics"
      type: string
      sql: ${TABLE}.city ;;
    }

    dimension: country {
      group_label: "Demographics"
      type: string
      sql: ${TABLE}.country ;;
    }

    dimension: days_since_last_visit {
      group_label: "Appointment Info"
      type: number
      sql: ${TABLE}.days_since_last_visit ;;
      html: <div align="center"> {{rendered_value}} </div> ;;
    }

    # dimension: days_since_last_visit_calc {
    #   group_label: "Appointment Info"
    #   type: number
    #   sql: ${derived_day_of_service.days_since_last_visit} ;;
    #   html: <div align="center"> {{rendered_value}} </div> ;;
    # }

    # measure: days_since_last_visit {
    #   group_label: "Appointment Info"
    #   type: max
    #   sql: ${days_since_last_visit_calc};;
    #   html: <div align="center"> {{rendered_value}} </div> ;;
    # }


    dimension: delivery_date {
      group_label: "RMOMS"
      type: date
      sql: ${TABLE}.deliverdate ;;
      html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
    }

    # Looker errors on load of week and quarter
    dimension_group: dob {
      group_label: "Demographics"
      label: "Birth"
      type: time
      timeframes: [
        raw,
        month,
        year
      ]
      sql: ${TABLE}.dob ;;
    }

    dimension: combo_name_dob_date {
      group_label: "Demographics"
      label: "Combo Name_Birth Date"
      type: string
      sql: concat(${patient_name},'_', ${dob_date}) ;;
    }

    # Defined outside the dimension group to allow formatting
    dimension: dob_date {
      group_label: "Demographics"
      label: "Birth Date"
      type: date
      sql: ${TABLE}.dob ;;
      html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
    }

    dimension: days_to_turn_65{
      type: number
      sql:  DATEDIFF(day,(DATEADD(year, 65, ${TABLE}.dob)), getdate());;
    }


    dimension: edd {
      label: "Estimated Date of Delivery"
      group_label: "RMOMS"
      type: string
      sql: CASE
          WHEN ${TABLE}.edd IS NULL THEN '99/99/9999'
          ELSE
          CONVERT(varchar, ${TABLE}.edd, 101)
          END;;
    # html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
      }

      dimension: family_member_number {
        group_label: "Demographics"
        type: number
        sql: ${TABLE}.family_member_nbr ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: gravida {
        group_label: "RMOMS"
        type: number
        sql: ${TABLE}.gravida ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      # Boolean field; left as type: number to retain NULL values
      dimension: hispaniclatino {
        label: "Hispanic / Latino (Numeric)"
        group_label: "Demographics"
        hidden: yes
        type: number
        sql: ${TABLE}.hispanic_latino ;;
      }

      dimension: is_18_or_over {
        group_label: "Patient Information - Age Tiers"
        type: yesno
        sql: ${age} >= 18 ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: is_65_or_over {
        group_label: "Patient Information - Age Tiers"
        type: yesno
        sql: ${age} >= 65 ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      # dimension: is_baby_boomer {
      #   group_label: "Patient Information"
      #   description: "Patient born from 1946 through 1964"
      #   type: yesno
      #   sql: ${dob_year} >= 1946 AND ${dob_year} < 1965 ;;
      #   html: <div align="center"> {{rendered_value}} </div> ;;
      # }

      dimension: is_baby_boomer {
        group_label: "Patient Information"
        description: "Patient born from 1945 through 1965-Gonzales"
        type: yesno
        sql: ${dob_year} >= 1945 AND ${dob_year} < 1966 ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      # dimension: is_current_patient {
      #   description: "Patient has been seen within 3 years, is not a test patient and is not deceased"
      #   type: yesno
      #   sql: ${days_since_last_visit} <= 1095 and NOT(${is_expired}) and (${is_real_patient}) ;;
      # }

      dimension: is_current_patient {
        description: "Patient has been seen within 3 years, is not a test patient and is not deceased"
        type: yesno
        sql: ${last_visit_info.days_since_last_visit} <= 1095 and NOT(${is_expired}) and (${is_real_patient}) ;;
      }

      dimension: is_current_patient_1_year{
        label: "Patient Seen within Last 1 year"
        group_label: "Appointment Info"
        hidden: no
        description: "Patient has been seen within 1 year and is not deceased"
        type: yesno
        sql: DATEADD (year, 1, ${last_appointment_date}) >= getdate() AND NOT(${is_expired}) and (${is_real_patient}) ;;
      }

      dimension: is_current_patient_2_years{
        label: "Patient Seen within Last 2 years"
        group_label: "Appointment Info"
        hidden: no
        description: "Patient has been seen within 2 years and is not deceased"
        type: yesno
        sql: DATEADD (year, 2, ${last_appointment_date}) >= getdate() AND NOT(${is_expired}) and (${is_real_patient}) ;;
      }

      dimension: is_expired {
        group_label: "Demographics"
        label:  "Patient is Deceased"
        type: yesno
        sql: CAST(
            CASE WHEN ${TABLE}.expired_ind IS NULL OR ${TABLE}.expired_ind = 0
                 THEN 0
                 ELSE 1
            END AS bit
         ) = 'true' ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: is_hispanic {
        group_label: "Demographics"
        type: yesno
        sql: CAST(${hispaniclatino} AS bit) = 'true' ;;
      }

      dimension: is_hispanic_UDS {
        group_label: "UDS Patient Information"
        type: string
        sql: CASE WHEN CAST(${hispaniclatino} AS bit) = 'true'
              THEN 'Hispanic or Latino'
              ELSE 'Non-Hispanic or Latino'
              END
    ;;
      }

      dimension: is_race_documented {
        group_label: "Demographics"
        type: yesno
        sql: ${race} IS NOT NULL ;;
        html:
              {% if is_race_documented._value == 'Yes' %}
                <div style="color:black", align="center"> {{rendered_value}} </div>
              {% else %}
                <div style="color:red", align="center"> {{rendered_value}} </div>
              {% endif %} ;;
      }

      dimension: is_real_patient {
        view_label: "Commonly Used Fields"
        description: "Identify Test Patients from Real Patients"
        type: yesno
        sql: cast(decryptbypassphrase('P@tN@me',${TABLE}.patient_name) as varchar(150)) NOT LIKE '%test%'
          ;;
      }

      dimension: is_smoker {
        group_label: "Demographics"
        type: yesno
        sql: CAST(${TABLE}.smoker AS bit) = 'true' ;;
        html:
              {% if is_smoker._value == 'Yes' %}
                <div style="color:red", align="center"> {{rendered_value}} </div>
              {% elsif is_smoker._value == 'No'  %}
                <div style="color:black", align="center"> {{rendered_value}} </div>
              {% endif %} ;;
      }

      dimension: is_uninsured {
        group_label: "Demographics"
        type: yesno
        sql: CAST(${TABLE}.uninsured_flag AS bit) = 'true' ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension_group: last_appointment {
        group_label: "Appointment Info"
        hidden: yes
        type: time
        timeframes: [
          raw,
          week,
          month,
          quarter,
          year
        ]
        sql: ${TABLE}.last_visit_date ;;
      }

      # Defined outside the dimension group to allow formatting
      dimension: last_appointment_date {
        group_label: "Appointment Info"
        hidden: no
        type: date
        sql: ${last_appointment_raw} ;;
        html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
      }

      dimension: last_insurance {
        group_label: "Demographics"
        type: string
        sql: ${TABLE}.last_visit_payer ;;
      }

      dimension: language_other_than_english{
        group_label: "UDS Patient Information"
        type: string
        sql: CASE WHEN ${primary_language} <> 'English'
              THEN '12. Patients Best Served in a Language Other than English'
         END ;;
      }

      dimension: lmp {
        group_label: "RMOMS"
        type: date
        sql: ${TABLE}.lmp ;;
        html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
      }

      dimension: location_id {
        group_label: "Demographics"
        type: number
        sql: ${TABLE}.locationid ;;
      }

      dimension: preterm {
        group_label: "RMOMS"
        label: " RMOMS number of previous pre-term deliveries"
        type: number
        sql: ${TABLE}.preterm ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }


      dimension_group: next_appointment {
        group_label: "Appointment Info"
        hidden: yes
        type: time
        timeframes: [
          raw,
          week,
          month,
          quarter,
          year
        ]
        sql: ${TABLE}.next_appointment ;;
      }

      # Defined outside the dimension group to allow formatting
      dimension: next_appointment_date {
        group_label: "Appointment Info"
        hidden: no
        type: date
        sql: CASE
          WHEN ${next_appointment_raw} < GETDATE() THEN NULL
          ELSE ${next_appointment_raw}
          END;;
        html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
      }


      dimension: next_appointment_date_formatted {
        group_label: "Appointment Info"
        label: "Next Appt Date formatted"
        description: "EX: 03-03-2022"
        type: string
        sql: CASE
          WHEN ${next_appointment_raw} IS NULL THEN 'No Appt Sched'
          WHEN ${next_appointment_raw} < GETDATE() THEN 'No Appt Sched'
          ELSE
          CONVERT(varchar, ${TABLE}.next_appointment, 110)
          END;;
      }

#   dimension: patient_cellphone {
#     view_label: "Commonly Used Fields"
#     type: string
#     sql:
#       {% if _user_attributes['demo'] == 1 %}
#         ${patient_detail_hidden}
#       {% elsif _user_attributes['show_phi'] == 1 %}
#         SUBSTRING (cast(decryptbypassphrase('P@tN@me',${TABLE}.mobile_num) as varchar(10)),1,3)+'-'+
#         SUBSTRING (cast(decryptbypassphrase('P@tN@me',${TABLE}.mobile_num) as varchar(10)),4,3)+'-'+
#         SUBSTRING (cast(decryptbypassphrase('P@tN@me',${TABLE}.mobile_num) as varchar(10)),7,4)
#       {% else %}
#         ${patient_detail_hidden}
#       {% endif %} ;;

# }


      dimension: patient_cellphone_check {
        view_label: "Commonly Used Fields"
        type: string
        hidden: yes
        sql:
              {% if _user_attributes['demo'] == 1 %}
                ${patient_detail_hidden}
              {% elsif _user_attributes['show_phi'] == 1 %}
                cast(decryptbypassphrase('P@tN@me',${TABLE}.mobile_num) as varchar(12))
              {% else %}
                ${patient_detail_hidden}
              {% endif %} ;;
      }

      dimension: patient_cellphone {
        view_label: "Commonly Used Fields"
        type: string
        sql: CASE
                WHEN ${practice_id}=1017
                  THEN ${patient_cellphone_check}
                ELSE
                  SUBSTRING (${patient_cellphone_check},1,3)+'-'+
                  SUBSTRING (${patient_cellphone_check},4,3)+'-'+
                  SUBSTRING (${patient_cellphone_check},7,4)
                END;;
      }


      dimension: patient_homephone_check {
        view_label: "Commonly Used Fields"
        type: string
        hidden: yes
        sql:
              {% if _user_attributes['demo'] == 1 %}
                ${patient_detail_hidden}
              {% elsif _user_attributes['show_phi'] == 1 %}
                  cast(decryptbypassphrase('P@tN@me',${TABLE}.home_phone) as varchar(12))
              {% else %}
                ${patient_detail_hidden}
              {% endif %}  ;;
      }

      dimension: patient_homephone {
        view_label: "Commonly Used Fields"
        type: string
        sql: CASE
                WHEN ${practice_id}=1017
                  THEN ${patient_homephone_check}
                ELSE
                  SUBSTRING (${patient_homephone_check},1,3)+'-'+
                  SUBSTRING (${patient_homephone_check},4,3)+'-'+
                  SUBSTRING (${patient_homephone_check},7,4)
                END;;
      }

      dimension: patient_detail_hidden {
        hidden: yes
        type: string
        sql: ${TABLE}.patient_detail_hidden ;;
      }

      dimension: patient_email {
        view_label: "Commonly Used Fields"
        type: string
        sql:
              {% if _user_attributes['demo'] == 1 %}
                ${patient_detail_hidden}
              {% elsif _user_attributes['show_phi'] == 1 %}
                cast(decryptbypassphrase('P@tN@me',${TABLE}.email) as varchar(150))
              {% else %}
                ${patient_detail_hidden}
              {% endif %} ;;
      }

      dimension: original_first_name {
        type: string
        sql:  ${TABLE}.first_name);;
      }

      dimension: patient_first_name {
        type: string
        view_label:  "Commonly Used Fields"
        sql:
              {% if _user_attributes['demo'] == 1 %}
                --LEFT(${TABLE}.patient_alias, CHARINDEX( ' ', ${TABLE}.patient_alias) - 1)
                LEFT(${patient_alias}, CHARINDEX( ' ', ${patient_alias}) - 1)
              {% elsif _user_attributes['show_phi'] == 1 %}
                cast(decryptbypassphrase('P@tN@me',${TABLE}.first_name) as varchar(150))
              {% else %}
                --LEFT(${TABLE}.patient_alias, CHARINDEX( ' ', ${TABLE}.patient_alias) - 1)
                LEFT(${patient_alias}, CHARINDEX( ' ', ${patient_alias}) - 1)
              {% endif %} ;;
      }

      dimension: patient_last_name {
        type: string
        view_label:  "Commonly Used Fields"
        sql: -- checks to see if user can see PHI, otherwise uses alias
                {% if _user_attributes['demo'] == 1 %}
                  LEFT(${TABLE}.patient_alias, CHARINDEX( ' ', ${TABLE}.patient_alias) - 1)
                {% elsif _user_attributes['show_phi'] == 1 %}
                  cast(decryptbypassphrase('P@tN@me',${TABLE}.last_name) as varchar(150))
                {% else %}
                  LEFT(${TABLE}.patient_alias, CHARINDEX( ' ', ${TABLE}.patient_alias) - 1)
                {% endif %} ;;
        link: {
          label: "Patient Details"
          url: "/dashboards-next/6?Patient={{ derived_patient_data.patient_id._value}}"
        }
      }

      dimension: paient_last_name_first_name {
        label: "Patient last name, first name"
        type: string
        sql: ${patient_last_name}+', '+${patient_first_name} ;;
      }

      dimension: patient_mrn {
        label: "Patient MRN"
        view_label: "Commonly Used Fields"
        type: string
        sql:
              {% if _user_attributes['demo'] == 1 %}
                ${TABLE}.patientid
              {% elsif _user_attributes['show_phi'] == 0 %}
                'MRN Unavailable'
              {% else %}
                ${TABLE}.pat_mrn
              {% endif %};;
      }

      dimension: pat_old_mrn {
        label: "Old MRN from previous EMR"
        type: string
        sql: ${TABLE}.oldid ;;
      }

      # https://affinitihealth.looker.com/dashboards/6?Patient=&Medical+Record+Number=49339%2C138722

      dimension: patient_mrn_all {
        label: "Includes all MRNs"
        type: string
        sql: CASE
          WHEN ${TABLE}.oldid IS NULL THEN ${patient_mrn}
          ELSE
          concat(${patient_mrn},'%2C', ${pat_old_mrn})
          END;;
      }

      dimension: patient_name {
        view_label: "Commonly Used Fields"
        type: string
        sql:
              -- checks to see if user can see PHI, otherwise uses alias
              {% if _user_attributes['demo'] == 1 %}
                ${patient_alias}
              {% elsif _user_attributes['show_phi'] == 1 %}
                cast(decryptbypassphrase('P@tN@me',${TABLE}.patient_name) as varchar(150))
              {% else %}
                ${patient_alias}
              {% endif %} ;;
        link: {
          label: "Patient Details"
          url: "/dashboards-next/6?Patient={{ derived_patient_data.patient_id._value}}"
        }
        # link: {
        #   label: "Patient MRN"
        #   url: "/dashboards-next/6?mrn={{ derived_patient_data.patient_mrn.value}}"
        # }
        # link: {
        #   label: "Patient Details All MRNs"
        #   # url: "/dashboards-next/6?Patient=&Medical_Record_Number=&{{ derived_patient_data.includes_all_mrns._value}}"
        #   url: "/dashboards/6?Includes_all_MRNs=&{{ derived_patient_data.pat_old_mrn._value}}"
        #   # https://affinitihealth.looker.com/dashboards/6?Patient=&Medical+Record+Number=&Includes+all+MRNs=57704%2C1762.1
        # }
        link: {
          label: "View Childhood Immunizatons"
          url: "/dashboards-next/188?Patient={{ derived_patient_data.patient_id._value}}"
        }
      }



      # url: "/looks/1494?Patient={{ derived_patient_data.patient_mrn._value}}"

      ## !! DO NOT ALTER !! ##
      dimension: patient_outreach_phone {
        view_label: "Commonly Used Fields"
        description: "Phone number used for texting application - gives preference to cell phone field over home phone field."
        hidden: yes
        type: string
        sql: -- checks to see if user can see PHI, otherwise uses alias
                {% if _user_attributes['demo'] == 1 %}
                  ${patient_detail_hidden}
                {% elsif _user_attributes['show_phi'] == 1 %}
                  CASE
                    WHEN ${TABLE}.mobile_num IS NOT NULL
                      THEN CAST(decryptbypassphrase('P@tN@me',${TABLE}.mobile_num) AS VARCHAR(10))
                    WHEN ${TABLE}.home_phone IS NOT NULL
                      THEN CAST(decryptbypassphrase('P@tN@me',${TABLE}.home_phone) AS VARCHAR(10))
                    ELSE NULL
                  END
                {% else %}
                  ${patient_detail_hidden}
                {% endif %}  ;;
      }

      # dimension: patient_outreach_phone_for_joins {
      #   type: string
      #   sql:     CASE
      #                 WHEN ${patient_id}= 1002146066 THEN '5083530002'
      #                 WHEN ${patient_id}= 1002386643 THEN '8503393748'
      #                 ELSE
      #                 '5553211212'
      #             END;;
      # }

      # dimension: random_phone_for_test {
      #   type: string
      #   sql:    CEILING((RAND()*6), '5083530002', '5087896983', '8503393748', '7742050373', '7749942835', '6105749217');;
      # }

      dimension: phone_for_texting_test {
        type: number
        value_format_name: id
        sql: CASE
          WHEN RIGHT(${patient_id}, 1) <=1 THEN '5083530002'
          WHEN RIGHT(${patient_id}, 1) <=3 THEN '8303399719'
          WHEN RIGHT(${patient_id}, 1) <=5 THEN '8503393748'
          WHEN RIGHT(${patient_id}, 1) <=7 THEN '9193456274'
          WHEN RIGHT(${patient_id}, 1) =8 THEN '5083530002'
          WHEN RIGHT(${patient_id}, 1) =9 THEN '8503393748'
          END;;
      }

      # WHEN RIGHT(${patient_id}, 1) <=3 THEN '3129754333'. (amy's phonenumber)

      # dimension: phone_for_texting_test_encrypted {
      #   type: string
      #   sql: CASE
      #         WHEN RIGHT(${patient_id}, 1) <=1 THEN encryptbypassphrase('P@tN@me','5083530002')
      #         WHEN RIGHT(${patient_id}, 1) <=3 THEN encryptbypassphrase('P@tN@me','5087896983')
      #         WHEN RIGHT(${patient_id}, 1) <=5 THEN encryptbypassphrase('P@tN@me','8503393748')
      #         WHEN RIGHT(${patient_id}, 1) <=7 THEN encryptbypassphrase('P@tN@me','6105749217')
      #         WHEN RIGHT(${patient_id}, 1) =8 THEN encryptbypassphrase('P@tN@me','5083530002')
      #         WHEN RIGHT(${patient_id}, 1) =9 THEN encryptbypassphrase('P@tN@me','8503393748')
      #         END;;
      # }



      dimension: patient_outreach_phone_for_joins {
        type: string
        sql:    ${patient_outreach_phone};;
      }

      dimension: patient_street {
        view_label: "Commonly Used Fields"
        type: string
        sql:
              -- checks to see if user can see PHI, otherwise uses alias
              {% if _user_attributes['demo'] == 1 %}
                ${patient_detail_hidden}
              {% elsif _user_attributes['show_phi'] == 1 %}
                cast(decryptbypassphrase('P@tN@me',${TABLE}.addressline) as varchar(150))
              {% else %}
                ${patient_detail_hidden}
              {% endif %} ;;
      }

      dimension: patient_outreach_AWV {
        type: string
        sql: concat(${centers.center},': ',${patient_first_name},' our records show you are due for your annual wellness visit. ',
              'This examination will help your doctor identify any health risks you may have, and allow us to work with you to develop a plan to address your health care needs. ',
              'If you would like us to contact you to set up an appointment, please indicate by entering a 1. You can also contact the clinic at 830-774-5534 to schedule an appointment.');;


        # Our records show you are due for your annual wellness visit. If you would like us to contact you to set up an appointment, please indicate by entering a 1. You can also contact the clinic at 830-774-5534 to schedule an appointment.';;
      }


      dimension: pcp_id {
        label: "PCP ID"
        group_label: "Patient Information"
        type: number
        value_format_name: id
        sql: ${TABLE}.pcp_id ;;
      }

      dimension: practice_id {
        view_label: "Commonly Used Fields"
        type: number
        sql: ${TABLE}.practiceid ;;
        value_format_name: id
      }

      dimension: primary_language {
        group_label: "Patient Information"
        type: string
        sql: ${TABLE}.primary_language ;;
      }

      dimension: race {
        group_label: "Demographics"
        type: string
        sql: CASE
          WHEN ${TABLE}.race IS NOT NULL THEN ${TABLE}.race
          ELSE
          'Unreported/Refused To Report'
          END
    ;;
      }

      dimension: rmoms_ethnicity {
        label: "Ethnicity"
        group_label: "RMOMS"
        type: string
        sql: CASE WHEN ${hispaniclatino} = 1 THEN '1'
              WHEN ${hispaniclatino} = 0 THEN '2'
              ELSE '99'
         END ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: rmoms_lives_in_mexico {
        label: "Lives in Mexico"
        group_label: "RMOMS"
        type: yesno
        sql: ${country} = 'MX' ;;
      }

      dimension: rmoms_number_of_deliveries {
        group_label: "RMOMS"
        label: " RMOMS number of previous deliveries"
        type: number
        sql: CASE
          WHEN ${term} + ${preterm} > 0 THEN 1
          WHEN ${term} + ${preterm} = 0 THEN 0
          ELSE
          99
          END;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: RMOMS_payer_plan{
        group_label: "RMOMS"
        label: "Private or Medicaid Insurance"
        type: number
        sql: CASE
                   WHEN ${last_insurance} like '%medicaid%' or
                        ${last_insurance} like '%star%' or
                        ${last_insurance} like '%chip%' THEN 2
                   WHEN ${last_insurance} like '%va%' or ${last_insurance} like '%tricare%' or ${last_insurance} like '%military%'
                        or ${last_insurance} like '%us marshall%'THEN 3
                   WHEN ${last_insurance} like '%indian%' THEN 4
                   WHEN ${last_insurance} like '%uninsured%' or ${last_insurance} like '%no insur%' THEN 5
                   WHEN ${last_insurance} IS NULL THEN 99
                   ELSE
                   1
                   END;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: RMOMS_primary_language{
        label: "RMOMS Primary Languarge"
        group_label: "RMOMS"
        type: number
        sql: CASE WHEN ${primary_language} = 'English' THEN '1'
              WHEN ${primary_language} = 'Spanish' THEN '2'
              WHEN ${primary_language} IS NULL THEN '99'
              ELSE '3'
         END ;;

        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: rmoms_race {
        label: "Race"
        group_label: "RMOMS"
        type: string
        sql: CASE WHEN ${race} = 'White' THEN '5'
              WHEN ${race} = 'Black/African American' or ${race} like '%Black%' THEN '3'
              WHEN ${race} = 'Asian' THEN '2'
              WHEN ${race} = 'American Indian/Alaska Native' THEN '1'
              WHEN ${race} = 'Native Hawaiian' or ${race} = 'Other Pacific Islander' THEN '4'
              ELSE '6'
         END ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: rmoms_URN{
        description: "RMOMS Linking Identifier"
        group_label: "RMOMS"
        label: "Linking ID"
        type: string
        # sql: ${TABLE}.dob ;;
        sql: lower(SUBSTRING(${patient_first_name}, 1, 1)+SUBSTRING(${patient_first_name}, 3, 1)+SUBSTRING(${patient_last_name}, 1, 1)+SUBSTRING(${patient_last_name}, 3, 1))+SUBSTRING(${dob_date}, 6, 2) + SUBSTRING(${dob_date}, 9, 2) + SUBSTRING(${dob_date}, 1, 4);;
        # html: <div align="center"> {{rendered_value | date: "%m-%d-%Y" }} </div> ;;
      }

      dimension: sex {
        label: "Gender"
        group_label: "Demographics"
        type: string
        sql: ${TABLE}.sex_with_undefined ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: state {
        group_label: "Demographics"
        type: string
        sql: ${TABLE}.state ;;
      }

      dimension: term {
        group_label: "RMOMS"
        label: " RMOMS number of previous full term deliveries"
        type: number
        sql: ${TABLE}.term ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }


      # dimension: timeframe_since_last_visit_with_illness {
      #   group_label: "Appointment Info"
      #   case: {
      #     when: {
      #       sql: ${days_since_last_visit} <= 90 and ${uds_measures_data.patient_has_chronic_problem} ;;
      #       label: "Seen within the last 3 Months"
      #     }
      #     when: {
      #       sql: ${days_since_last_visit} <= 180 and ${uds_measures_data.patient_has_chronic_problem} ;;
      #       label: "Not Seen between 3 Months and 6 Months"
      #     }
      #     when: {
      #       sql: ${days_since_last_visit} <= 365 and ${uds_measures_data.patient_has_chronic_problem} ;;
      #       label: "Not Seen between 6 Months and 12 Months"
      #     }
      #     when: {
      #       sql: ${days_since_last_visit} <= 730 and ${uds_measures_data.patient_has_chronic_problem} ;;
      #       label: "Not Seen between 1 Year and 2 Years"
      #     }
      #     when: {
      #       sql: ${days_since_last_visit} > 730 and ${uds_measures_data.patient_has_chronic_problem} ;;
      #       label: "Not Seen in Over 2 Years"
      #     }
      #     else: "Patient does not have an illness."
      #   }
      #   html: <div align="center"> {{rendered_value}} </div> ;;
      # }

      # dimension: timeframe_since_last_visit_with_illness {
      #   group_label: "Appointment Info"
      #   case: {
      #     when: {
      #       sql: ${days_since_last_visit} <= 90;;
      #       label: "Seen within the last 3 Months"
      #     }
      #     when: {
      #       sql: ${days_since_last_visit} <= 180;;
      #       label: "Not Seen between 3 Months and 6 Months"
      #     }
      #     when: {
      #       sql: ${days_since_last_visit} <= 365;;
      #       label: "Not Seen between 6 Months and 12 Months"
      #     }
      #     when: {
      #       sql: ${days_since_last_visit} <= 730;;
      #       label: "Not Seen between 1 Year and 2 Years"
      #     }
      #     when: {
      #       sql: ${days_since_last_visit} > 730;;
      #       label: "Not Seen in Over 2 Years"
      #     }
      #     else: "Patient does not have an illness."
      #   }
      #   html: <div align="center"> {{rendered_value}} </div> ;;
      # }



      dimension: title_x_client_number {
        label: "Client Number"
        group_label: "Title X"
        type: number
        sql:  FLOOR(${patient_mrn});;
        value_format: "0"
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: title_x_dob {
        label: "Date of Birth"
        group_label: "Title X"
        description: "yymmdd"
        sql: CONVERT(varchar, ${dob_raw}, 112);;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: title_x_ethnicity {
        label: "Ethnicity"
        group_label: "Title X"
        type: number
        sql: CASE WHEN ${hispaniclatino} = 1 THEN 1
              WHEN ${hispaniclatino} = 0 THEN 2
              ELSE 3
         END ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: title_x_limited_english_proficiency{
        label: "Limited English Proficiency"
        group_label: "Title X"
        type: number
        sql: CASE WHEN ${primary_language} <> 'English' THEN '1'
              ELSE '2'
         END ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: title_x_race {
        label: "Race"
        group_label: "Title X"
        type: string
        sql: CASE WHEN ${race} = 'White' THEN '1'
              WHEN ${race} = 'Black/African American' THEN '2'
              WHEN ${race} = 'Asian' THEN '3'
              WHEN ${race} = 'American Indian/Alaska Native' THEN '4'
              WHEN ${race} = 'Unreported/Refused To Report' or ${race} IS NULL THEN '6'
              WHEN ${race} = 'Native Hawaiian' or ${race} = 'Other Pacific Islander' THEN '7'
              WHEN ${race} = 'More Than One Race' THEN '8'
              ELSE '6'
         END ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: title_x_sex {
        label: "Sex"
        group_label: "Title X"
        type: string
        sql: CASE WHEN ${sex} = 'F' THEN '1'
              WHEN ${sex}  = 'M' THEN '2'
              ELSE '-'
         END ;;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      # dimension: uds_age_tier {
      #   label: "UDS Age Tier"
      #   group_label: "UDS Patient Information"
      #   description: "Age on 6/30"
      #   type: tier
      #   style: integer
      #   tiers: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,30,35,40,45,50,55,60,65,70,75,80,85]
      #   sql: ${uds_age_calculation} ;;
      # }

      # dimension: uds_age_date {
      #   label: "date for UDS age change"
      #   group_label: "UDS Patient Information"
      #   description: "typically 6/30 of the reporting year"
      #   type: date
      #   sql: '2020/06/30' ;;
      # }

      # parameter: UDS_Reporting_Year {
      #   type: string
      #   allowed_value: {
      #     value: "2023"
      #     # label: "UDS Year 2023"
      #   }
      #   allowed_value: {
      #     value: "2022"
      #     # label: "UDS Year 2022"
      #   }allowed_value: {
      #     value: "2021"
      #     # label: "UDS Year 2021"
      #   }
      #   allowed_value: {
      #     value: "2020"
      #     # label: "UDS Year 2020"
      #   }
      #   allowed_value: {
      #     value: "2019"
      #     # label: "UDS Year 2019"
      #   }
      #   allowed_value: {
      #     value: "2018"
      #     # label: "UDS Year 2018"
      #   }
      # }

      # dimension: uds_age_calculation {
      #   type: number
      #   label_from_parameter: UDS_Reporting_Year
      #   sql:
      #       CASE
      #         WHEN {% parameter UDS_Reporting_Year %} = '2023' and (MONTH(2023/06/30) * 100) + DAY(2023/06/30) >= (MONTH(${derived_patient_data.dob_raw}) * 100) + DAY(${derived_patient_data.dob_raw}) THEN DATEDIFF(Year, ${dob_raw}, '20230630')
      #         WHEN {% parameter UDS_Reporting_Year %} = '2023' and (MONTH(2023/06/30) * 100) + DAY(2023/06/30) < (MONTH(${derived_patient_data.dob_raw}) * 100) + DAY(${derived_patient_data.dob_raw}) THEN DATEDIFF(Year, ${dob_raw}, '20230630')-1
      #         WHEN {% parameter UDS_Reporting_Year %} = '2022' and (MONTH(2022/06/30) * 100) + DAY(2022/06/30) >= (MONTH(${derived_patient_data.dob_raw}) * 100) + DAY(${derived_patient_data.dob_raw}) THEN DATEDIFF(Year, ${dob_raw}, '20220630')
      #         WHEN {% parameter UDS_Reporting_Year %} = '2022' and (MONTH(2022/06/30) * 100) + DAY(2022/06/30) < (MONTH(${derived_patient_data.dob_raw}) * 100) + DAY(${derived_patient_data.dob_raw}) THEN DATEDIFF(Year, ${dob_raw}, '20220630')-1
      #         WHEN {% parameter UDS_Reporting_Year %} = '2021' and (MONTH(2021/06/30) * 100) + DAY(2021/06/30) >= (MONTH(${derived_patient_data.dob_raw}) * 100) + DAY(${derived_patient_data.dob_raw}) THEN DATEDIFF(Year, ${dob_raw}, '20210630')
      #         WHEN {% parameter UDS_Reporting_Year %} = '2021' and (MONTH(2021/06/30) * 100) + DAY(2021/06/30) < (MONTH(${derived_patient_data.dob_raw}) * 100) + DAY(${derived_patient_data.dob_raw}) THEN DATEDIFF(Year, ${dob_raw}, '20210630')-1
      #         WHEN {% parameter UDS_Reporting_Year %} = '2020' and (MONTH(2020/06/30) * 100) + DAY(2020/06/30) >= (MONTH(${derived_patient_data.dob_raw}) * 100) + DAY(${derived_patient_data.dob_raw}) THEN DATEDIFF(Year, ${dob_raw}, '20200630')
      #         WHEN {% parameter UDS_Reporting_Year %} = '2020' and (MONTH(2020/06/30) * 100) + DAY(2020/06/30) < (MONTH(${derived_patient_data.dob_raw}) * 100) + DAY(${derived_patient_data.dob_raw}) THEN DATEDIFF(Year, ${dob_raw}, '20200630')-1
      #         WHEN {% parameter UDS_Reporting_Year %} = '2019' and (MONTH(2019/06/30) * 100) + DAY(2019/06/30) >= (MONTH(${derived_patient_data.dob_raw}) * 100) + DAY(${derived_patient_data.dob_raw}) THEN DATEDIFF(Year, ${dob_raw}, '20190630')
      #         WHEN {% parameter UDS_Reporting_Year %} = '2019' and (MONTH(2019/06/30) * 100) + DAY(2019/06/30) < (MONTH(${derived_patient_data.dob_raw}) * 100) + DAY(${derived_patient_data.dob_raw}) THEN DATEDIFF(Year, ${dob_raw}, '20190630')-1
      #         WHEN {% parameter UDS_Reporting_Year %} = '2018' and (MONTH(2018/06/30) * 100) + DAY(2018/06/30) >= (MONTH(${derived_patient_data.dob_raw}) * 100) + DAY(${derived_patient_data.dob_raw}) THEN DATEDIFF(Year, ${dob_raw}, '20180630')
      #         WHEN {% parameter UDS_Reporting_Year %} = '2018' and (MONTH(2018/06/30) * 100) + DAY(2018/06/30) < (MONTH(${derived_patient_data.dob_raw}) * 100) + DAY(${derived_patient_data.dob_raw}) THEN DATEDIFF(Year, ${dob_raw}, '20180630')-1
      #         ELSE NULL
      #       END ;;
      # }

      dimension: uds_is_between_3_and_17_2023 {
        label: "2023 - Is Between 3 and 17"
        group_label: "UDS Patient Information"
        hidden: no
        type: yesno
        sql: ${dob_raw} >= '2006-01-02'  and ${dob_raw} <= '2019-12-31';;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: uds_is_between_3_and_17_2022 {
        label: "2022 - Is Between 3 and 17"
        group_label: "UDS Patient Information"
        hidden: no
        type: yesno
        sql: ${dob_raw} >= '2005-01-02'  and ${dob_raw} <= '2018-12-31';;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: uds_is_between_3_and_17_2021 {
        label: "2021 - Is Between 3 and 17"
        group_label: "UDS Patient Information"
        hidden: no
        type: yesno
        sql: ${dob_raw} >= '2004-01-02'  and ${dob_raw} <= '2017-12-31';;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }


      dimension: uds_is_between_3_and_17_2020 {
        label: "2020 - Is Between 3 and 17"
        group_label: "UDS Patient Information"
        hidden: no
        type: yesno
        sql: ${dob_raw} >= '2003-01-02'  and ${dob_raw} <= '2016-12-31';;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: uds_is_female_between_23_and_64_2019 {
        label: "2019 - Is Female Between 23 and 64"
        group_label: "UDS Patient Information"
        hidden: yes
        type: yesno
        sql: ${dob_raw} >= '1955-01-01' AND ${dob_raw} <= '1995-12-31' AND ${sex}='F';;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: uds_is_female_between_23_and_64_2020 {
        label: "2020 - Is Female Between 23 and 64"
        group_label: "UDS Patient Information"
        hidden: no
        type: yesno
        sql: ${dob_raw} >= '1955-01-02' AND ${dob_raw} <= '1997-12-31' AND ${sex}='F';;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: uds_is_female_between_23_and_64_2021 {
        label: "2021 - Is Female Between 23 and 64"
        group_label: "UDS Patient Information"
        hidden: no
        type: yesno
        sql: ${dob_raw} >= '1956-01-01' AND ${dob_raw} <= '1998-12-31' AND ${sex}='F';;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: uds_is_patient_between_50_and_74_2020 {
        # Percentage of women 50–74 years of age who had a mammogram to screen for breast cancer
        # in the 27 months prior to the end of the measurement period
        # Denominator:  Women 51* through 73 years of age with a medical visit during the measurement period

        label: "UDS 2020 - Is Patient Between 50 and 74"
        description: "Include women with birthdate on or after January 2, 1946, and birthdate on or before January 1, 1969."
        group_label: "UDS Patient Information"
        hidden: no
        type: yesno
        sql: ${dob_raw} >= '1946-01-02' AND ${dob_raw} <= '1969-01-01';;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: uds_is_patient_between_50_and_74_2021 {
        # Percentage of women 50–74 years of age who had a mammogram to screen for breast cancer
        # Patients who are checked for colon test who are between 50 and 74
        # in the 27 months prior to the end of the measurement period
        # Denominator:  Women 51* through 73 years of age with a medical visit during the measurement period

        label: "UDS 2021 - Is Patient Between 50 and 74"
        description: "Include patients with birthdate on or after January 2, 1946, and birthdate on or before January 1, 1971."
        group_label: "UDS Patient Information"
        hidden: no
        type: yesno
        sql: ${dob_raw} >= '1946-01-02' AND ${dob_raw} <= '1971-01-01';;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }

      dimension: uds_is_patient_between_50_and_74_2022 {
        # Percentage of women 50–74 years of age who had a mammogram to screen for breast cancer
        # Patients who are checked for colon test who are between 50 and 74
        # in the 27 months prior to the end of the measurement period
        # Denominator:  Women 51* through 73 years of age with a medical visit during the measurement period

        label: "UDS 2022 - Is Patient Between 50 and 74"
        description: "Include patients with birthdate on or after January 2, 1947, and birthdate on or before January 1, 1972."
        group_label: "UDS Patient Information"
        hidden: no
        type: yesno
        sql: ${dob_raw} >= '1947-01-02' AND ${dob_raw} <= '1972-01-01';;
        html: <div align="center"> {{rendered_value}} </div> ;;
      }



      dimension: uds_race {
        label: "Race"
        group_label: "UDS Patient Information"
        type: string
        sql: CASE WHEN ${race} = 'White' THEN '5. White'
              WHEN ${race} = 'Asian' THEN '1. Asian'
              WHEN ${race} = 'Native Hawaiian' THEN '2a. Native Hawaiian'
              WHEN ${race} = 'Other Pacific Islander' THEN '2b. Other Pacific Islander'
              WHEN ${race} = 'Black/African American' THEN '3. Black/African American'
              WHEN ${race} = 'American Indian/Alaska Native' THEN '4. American Indian/Alaska Native'
              WHEN ${race} = 'More Than One Race' THEN '6. More than one race'
              WHEN ${race} = 'Unreported/Refused To Report' or
                   ${race} IS NULL THEN '7. Unreported/Refused to report race'
              ELSE '7. Unreported/Refused to report race'
         END ;;
      }

      # dimension: uds_total_asian_race_2023 {
      #   label: "2023 asian Race"
      #   group_label: "UDS Patient Information"
      #   type: string
      #   sql: CASE
      #         WHEN ${race} = 'Asian Indian'  or ${race} = 'Other Asian'  or ${race}= 'Chinese' or ${race}= 'Filipino' or ${race}= 'Japanese' or ${race}= 'Korean' or ${race}= 'Vietnamese'
      #         THEN '1. Total Asian'
      #       ELSE NULL
      #       END ;;
      # }

      dimension: uds_race_2023 {
        label: "2023 Race"
        group_label: "UDS Patient Information"
        type: string
        sql: CASE WHEN ${race} = 'White' THEN '5. White'
              WHEN ${race} = 'Asian Indian' THEN '1a. Asian Indian'
              WHEN ${race} = 'Chinese' THEN '1b. Chinese'
              WHEN ${race} = 'Filipino' THEN '1c. Filipino'
              WHEN ${race} = 'Japanese' THEN '1d. Japanese'
              WHEN ${race} = 'Korean' THEN '1e. Korean'
              WHEN ${race} = 'Vietnamese' THEN '1f. Vietnamese'
              WHEN ${race} = 'Asian' or ${race} = 'Other Asian' THEN '1g. Other Asian'
              WHEN ${race} = 'Native Hawaiian' THEN '2a. Native Hawaiian'
              WHEN ${race} = 'Other Pacific Islander' THEN '2b. Other Pacific Islander'
              WHEN ${race} = 'Guamanian or Chamorro' THEN '2c. Guamanian or Chamorro'
              WHEN ${race} = 'Samoan' THEN '2d. Samoan'
              WHEN ${race} = 'Black/African American' THEN '3. Black/African American'
              WHEN ${race} = 'American Indian/Alaska Native' THEN '4. American Indian/Alaska Native'
              WHEN ${race} = 'More Than One Race' THEN '6. More than one race'
              WHEN ${race} like '%Unreport%' or ${race} like '%Refused%' or
                   ${race} IS NULL THEN '7. Unreported/Chose not to disclose race'
              ELSE ${race}
         END ;;
      }

      dimension: uds_age_tier_6b {
        label: "UDS Age Tier for table 6B"
        group_label: "UDS Patient Information"
        description: "Age during measurement year"
        type: tier
        style: integer
        tiers: [15,20,25,45]
        sql: ${age} ;;
      }

      dimension: zipcode {
        group_label: "Demographics"
        type: zipcode
        sql: ${TABLE}.zipcode_5 ;;
      }

      dimension: zipcode_hidden {
        group_label: "Demographics"
        type: string
        sql: concat ('xx', Right(${TABLE}.zipcode_5,3)) ;;
      }

      measure: appt_timeframe_first_appt_date {
        group_label: "Appointment Info"
        type: date
        sql: MIN(${next_appointment_raw}) ;;
      }

      measure: appt_timeframe_last_appt_date {
        group_label: "Appointment Info"
        type: date
        sql: MAX(${next_appointment_raw}) ;;
      }

      measure: count_current_patients {
        group_label: "Patient Count"
        description: "Patient has been seen within 3 years and is not deceased"
        type: count
        filters: {
          field: is_current_patient
          value: "Yes"
        }
        filters: {
          field: is_real_patient
          value: "Yes"
        }
        drill_fields: [detail*, race, primary_language]
        link: {
          label: "See up to 5,000 Results"
          url: "{{ link }}&limit=5000"
        }
      }

      measure: count_chcsct_current_patients {
        group_label: "Patient Count"
        description: "Patient has been seen within 3 years and is not deceased"
        type: count
        filters: {
          field: is_current_patient
          value: "Yes"
        }
        filters: {
          field: is_real_patient
          value: "Yes"
        }
        drill_fields: [chcsct_detail*]
        link: {
          label: "See up to 5,000 Results"
          url: "{{ link }}&limit=5000"
        }

      }

      measure: count_number_deliveries {
        group_label: "RMOMS"
        type: sum
        sql: ${preterm}+${term} ;;
        drill_fields: [detail*, gravida, term, preterm]
      }

      measure: count_patients {
        group_label: "Patient Count"
        type: count_distinct
        sql: ${patient_id} ;;
        drill_fields: [detail*, race, primary_language]
      }

      measure: count_chcsct_patients {
        group_label: "Patient Count"
        type: count_distinct
        sql: ${gonzales_patientid_cross_reference.combined_patient_id} ;;
        drill_fields: [patient_name,
          gonzales_patientid_cross_reference.combined_patient_id,
          age,
          dob_date,
          sex,
          city,
          zipcode,race, primary_language]
      }

      measure: count_patients_with_appt_in_time_frame {
        description: "Count of patients with an appointment in timeframe. Filter on visit date to determine count."
        group_label: "Appointment Info"
        type: count_distinct
        sql: ${patient_id} ;;
        filters: {
          field: next_appointment_date
          value: "-NULL"
        }
        filters: {
          field: is_current_patient
          value: "Yes"
        }
        drill_fields: [detail*]
      }

      measure: count_patients_with_no_appt_in_time_frame {
        description: "Count of patients without an appointment in timeframe. Filter on visit date to determine count."
        group_label: "Appointment Info"
        type: count_distinct
        sql: ${patient_id} ;;
        filters: {
          field: next_appointment_date
          value: "NULL"
        }
        filters: {
          field: is_current_patient
          value: "Yes"
        }
        drill_fields: [sm_phone*]
      }

      measure: count_patients_with_no_race_documented {
        group_label: "Patient Count"
        description: "Patient does not have their race documented"
        type: count
        filters: {
          field: is_race_documented
          value: "No"
        }
        filters: {
          field: is_real_patient
          value: "Yes"
        }
        drill_fields: [
          patient_mrn,
          # patient_name,
          age,
          dob_date,
          sex,
          next_appointment_date,
          last_insurance,
          annual_income,
          # family_member_nbr,
          primary_language,
          race,
          derived_day_of_service.days_since_last_visit
        ]
        html:
              {% if count_patients_with_no_race_documented._value ==0 %}
              <div style="color: #285195", align="center"> {{rendered_value}} </div>
              {% else %}
              <div style="color:red", align="center"> {{rendered_value}} </div>
              {% endif %}
              ;;
      }

      # ----- Sets of fields for drilling ------
      set: detail {
        fields: [
          patient_name,
          patient_mrn,
          age,
          dob_date,
          sex,
          city,
          zipcode,
          next_appointment_date,
          last_patient_tests.last_date_of_service,
          uds_measures_data.uds_problem_list,
          last_patient_tests.gap_list_text_combined,
          pcp.pcp_name
        ]
      }

      set: chcsct_detail {
        fields: [
          patient_mrn,
          patient_name,
          last_visit_date_status_not_open.age_at_visit,
          sex,
          patient_cellphone,
          patient_homephone,
          dob_date,
          race,
          primary_language,
          is_hispanic,
          last_visit_date_status_not_open.visit_date_date,
          last_visit_date_status_not_open.location,
          last_visit_date_status_not_open.provider_name,
          chronic.prediabetes_yesno,
          chronic.diabetes_yesno,
          last_patient_tests.last_hba1c_date_format,
          last_patient_tests.last_hba1c_result,
          last_patient_tests.CHCSCT_controlled_vs_uncontrolled,
          chronic.hypertension_yesno,
          last_patient_tests.last_blood_pressure,
          last_patient_tests.last_bmi_date_formated,
          last_patient_tests.last_bmi_result,
          is_smoker,
          last_visit_date_status_not_open.visit_status
        ]
      }

      set: sm_detail {
        fields: [
          patient_name,
          patient_mrn,
          age,
          dob_date,
          sex,
          city,
          zipcode,
          next_appointment_date
        ]
      }

      set: hyperdetail {
        fields: [
          patient_name,
          age,
          sex,
          is_smoker,
          next_appointment_date,
          last_visit_info.days_since_last_visit,
          last_patient_tests.last_blood_pressure,
          last_patient_tests.bp_status,
          last_patient_tests.last_bmi_result,
          uds_measures_data.uds_problem_list,
          pcp.pcp_name
        ]
      }

      set: less_detail {
        fields: [
          patient_name,
          patient_mrn,
          age,
          dob_date,
          sex,
          is_smoker,
          next_appointment_date,
          last_visit_info.days_since_last_visit,
          last_patient_tests.last_blood_pressure,
          last_patient_tests.last_bmi_result,
          pcp.pcp_name,
          uds_measures_data.uds_problem_list,
          last_patient_tests.gap_list_text_combined
        ]
      }


      set: sm_phone {
        fields: [
          patient_name,
          patient_mrn,
          patient_cellphone,
          patient_homephone,
          patient_street,
          city,
          state,
          zipcode,
          age,
          dob_date,
          sex,
          is_smoker,
          race,
          primary_language,
          next_appointment_date,
          uds_measures_data.uds_problem_list,
          pcp.pcp_name
        ]
      }
    }
