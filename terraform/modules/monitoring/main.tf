locals {
  name_prefix = "${var.project_name}-${var.environment}"

  load_balancer_dimension = element(
    split("loadbalancer/", var.load_balancer_arn),
    1
  )

  target_group_dimension = element(
    split("targetgroup/", var.target_group_arn),
    1
  )
}
