output "user_data_master" {
  value = "${data.template_file.user_data_master.rendered}"
}