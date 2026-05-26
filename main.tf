resource "aws_cloudwatch_event_target" "this" {
  count = module.this.enabled ? 1 : 0

  rule           = var.rule_name
  event_bus_name = var.event_bus_name
  target_id      = module.this.id
  arn            = var.target_arn
  role_arn       = var.role_arn
  input          = var.input
  input_path     = var.input_path

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_arn != null ? [1] : []
    content {
      arn = var.dead_letter_arn
    }
  }

  dynamic "retry_policy" {
    for_each = var.maximum_retry_attempts != null ? [1] : []
    content {
      maximum_retry_attempts       = var.maximum_retry_attempts
      maximum_event_age_in_seconds = var.maximum_event_age_in_seconds
    }
  }
}
