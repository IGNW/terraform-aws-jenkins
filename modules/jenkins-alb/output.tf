output "jira_lb_dns_name" {
  value = "${aws_lb.jiraconf-lb.dns_name}"
}

output "jiraconf-lb-listener-arn" {
  value = "${aws_lb_listener.jiraconf-lb-listener.arn}"
}
