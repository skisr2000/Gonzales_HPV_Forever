# Define the database connection to be used for this model.
connection: "mhm_azure_sql1"

# include all the views
include: "/views/**/*.view.lkml"

# Datagroups define a caching policy for an Explore. To learn more,
# use the Quick Help panel on the right to see documentation.

datagroup: Gonzales_HPV_Forever_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: Gonzales_HPV_Forever_default_datagroup

explore: data {
  view_name: data
  label: "Patients"
  view_label: "Patients"
  sql_always_where: ${data.practice_id} IN ({{ _user_attributes["default_practice_id"] }}) ;;


  join: location {
    type: left_outer
    sql_on: ${data.location_id} = ${location.location_id} ;;
    relationship: many_to_one
  }

  join: centers {
    type: left_outer
    sql_on: ${data.practice_id} = ${centers.practice_id} ;;
    relationship: many_to_one
  }

  join: last_visit_info {
    type: left_outer
    sql_on: ${data.patient_id} = ${last_visit_info.patientid} ;;
    relationship: one_to_one
  }

  join: gonzales_patientid_cross_reference {
    type: left_outer
    sql_on: ${data.patient_id} = ${gonzales_patientid_cross_reference.practice_patientid} or
            ${data.patient_id} = ${gonzales_patientid_cross_reference.other_patient_id}
      ;;
    relationship: many_to_one
  }

  join: pcp {
    type: left_outer
    sql_on: ${data.pcp_id} = ${pcp.pcpid} ;;
    relationship: many_to_one
  }

  join: payers {
    type: left_outer
    sql_on: ${patient_problem_list.payerid} = ${payers.payer_id} ;;
    relationship: many_to_one
  }

  join: provider {
    type: left_outer
    sql_on: ${patient_problem_list.providerid} = ${provider.provider_id} ;;
    relationship: many_to_one
  }

  join: last_hpv {
    type: left_outer
    sql_on: ${data.patient_id} = ${last_hpv.patientid} ;;
    relationship: one_to_one
  }

  join: patient_hpv {
    type: left_outer
    sql_on: ${data.patient_id} = ${patient_hpv.patientid} ;;
    relationship: one_to_many
  }

  join: patient_hpv_refusal {
    type: left_outer
    sql_on: ${data.patient_id} = ${patient_hpv_refusal.patientid} ;;
    relationship: one_to_many
  }

  join: patient_hpv_final {
    type: left_outer
    sql_on: ${data.patient_id} = ${patient_hpv_final.patientid} ;;
    relationship: one_to_one
  }

  join: dos_detail {
    type: left_outer
    sql_on: ${data.patient_id} = ${dos_detail.patientid} ;;
    relationship: one_to_many
  }


  join: patient_problem_list {
    type: left_outer
    sql_on: ${data.patient_id} = ${patient_problem_list.patientid} ;;
    relationship: one_to_many
  }

  join: future_appointments {
    type: left_outer
    sql_on: ${data.patient_id} = ${future_appointments.patientid} ;;
    relationship: one_to_many
  }
}


explore: dos_detail {
  label: "Visit Details"
  view_label: "Visit Details"
  sql_always_where: ${data.practice_id} IN ({{ _user_attributes["default_practice_id"] }}) ;;
#   access_filter: {
#     field: data.mhm_plan
#     user_attribute: grant_patient
#   }


  join: location {
    type: inner
    sql_on: ${dos_detail.location_id} = ${location.location_id} ;;
    relationship: many_to_one
  }

  join: gonzales_patientid_cross_reference {
    type: left_outer
    sql_on: ${dos_detail.patientid} = ${gonzales_patientid_cross_reference.practice_patientid} or
            ${dos_detail.patientid} = ${gonzales_patientid_cross_reference.other_patient_id}
      ;;
    relationship: many_to_one
  }

  join: payers {
    type: left_outer
    sql_on: ${dos_detail.payerid} = ${payers.payer_id} ;;
    relationship: many_to_one
  }

  join: data {
    type: inner
    sql_on: ${dos_detail.patientid} = ${data.patient_id} ;;
    relationship: many_to_one
  }

  join: last_visit_info {
    type: left_outer
    sql_on: ${dos_detail.patientid} = ${last_visit_info.patientid} ;;
    relationship: many_to_one
  }

  join: provider {
    type: inner
    sql_on: ${dos_detail.provider_id} = ${provider.provider_id} ;;
    relationship: many_to_one
  }

  join: pcp {
    type: left_outer
    sql_on: ${data.pcp_id} = ${pcp.pcpid} ;;
    relationship: many_to_one
  }

  join: future_appointments {
    type: left_outer
    sql_on: ${dos_detail.patientid} = ${future_appointments.patientid} ;;
    relationship: many_to_many
  }

  join: patient_problem_list {
    type: left_outer
    sql_on: ${dos_detail.patientid} = ${patient_problem_list.patientid} ;;
    relationship: many_to_many
  }

  join: last_hpv {
    type: left_outer
    sql_on: ${dos_detail.patientid} = ${last_hpv.patientid} ;;
    relationship: many_to_one
  }

  join: patient_hpv {
    type: left_outer
    sql_on: ${dos_detail.patientid} = ${patient_hpv.patientid} ;;
    relationship: many_to_one
  }

  join:  patient_hpv_refusal {
    type: left_outer
    sql_on: ${dos_detail.patientid} = ${patient_hpv_refusal.patientid} ;;
    relationship: many_to_one
  }

  join: patient_hpv_final {
    type: left_outer
    sql_on: ${dos_detail.patientid} = ${patient_hpv_final.patientid} ;;
    relationship: many_to_one
  }

  join: centers {
    type: left_outer
    sql_on: ${dos_detail.practice_id} = ${centers.practice_id}  ;;
    relationship:many_to_one
  }
}
