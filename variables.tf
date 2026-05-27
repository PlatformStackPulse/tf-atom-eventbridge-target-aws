variable "rule_name" {
  description = "Name of the EventBridge rule"
  type        = string
  validation {
    condition     = length(var.rule_name) > 0
    error_message = "rule_name must not be empty."
  }
}

variable "event_bus_name" {
  description = "Name of the event bus"
  type        = string
  default     = "default"
}

variable "target_arn" {
  description = "ARN of the target (Lambda, SQS, SNS, etc.)"
  type        = string
  validation {
    condition     = length(var.target_arn) > 0
    error_message = "target_arn must not be empty."
  }
}

variable "role_arn" {
  description = "IAM role ARN for the target invocation"
  type        = string
  default     = null
}

variable "input" {
  description = "JSON input to pass to the target"
  type        = string
  default     = null
}

variable "input_path" {
  description = "JSONPath to extract input from the event"
  type        = string
  default     = null
}

variable "dead_letter_arn" {
  description = "ARN of the DLQ for failed invocations"
  type        = string
  default     = null
}

variable "maximum_retry_attempts" {
  description = "Maximum number of retry attempts"
  type        = number
  default     = null
}

variable "maximum_event_age_in_seconds" {
  description = "Maximum age of an event before discarding"
  type        = number
  default     = 86400
}
