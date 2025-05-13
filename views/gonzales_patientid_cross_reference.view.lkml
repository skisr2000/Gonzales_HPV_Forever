
view: gonzales_patientid_cross_reference {
  derived_table: {
    sql: SELECT * FROM dbo.vw_CHCST_Patients ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: practice_id {
    type: number
    sql: ${TABLE}.PracticeID ;;
    value_format_name: "id"
  }

  # dimension: patientid {
  #   type: string
  #   sql: ${TABLE}.patientid ;;
  #   # value_format_name: "id"
  # }

  # dimension: ecw_patient_id {
  #   type: string
  #   sql: ${TABLE}.Ecw_patientID ;;
  #   # value_format_name: "id"
  # }

  dimension: practice_patientid {
    type: string
    sql: ${TABLE}.patientid ;;
    # value_format_name: "id"
  }

  dimension: other_patient_id {
    type: string
    sql: ${TABLE}.Ecw_patientID ;;
    # value_format_name: "id"
  }

  dimension: combined_patient_id {
    type: string
    sql: CASE
          WHEN ${practice_id}=1003 THEN
          concat (${practice_patientid},${other_patient_id})
          ELSE
          concat (${other_patient_id},${practice_patientid})
          END
          ;;
    # value_format_name: "id"
    }

    set: detail {
      fields: [
        practice_id,
        practice_patientid,
        other_patient_id
      ]
    }
  }
