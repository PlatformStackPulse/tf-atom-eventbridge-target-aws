# Unit Tests for tf-atom-eventbridge-target-aws
#
# These tests use a mock AWS provider — no real AWS calls are made.
# Run with:         terraform test -test-directory=tests/unit
# Run verbose:      terraform test -test-directory=tests/unit -verbose
# Run specific:     terraform test -test-directory=tests/unit -run "creates_when_enabled"
#
# Assertions target plan-KNOWN values only (the tf-label id string, resource
# count, and input pass-throughs). Computed attributes such as the resource
# `arn`/`id` are unknown under a mock provider and must not be asserted on.

mock_provider "aws" {}

variables {
  # tf-label identity
  namespace = "eg"
  stage     = "test"
  name      = "thing"

  # module-required inputs
  rule_name  = "orders-created"
  target_arn = "arn:aws:lambda:us-east-1:123456789012:function:process-orders"
}

# ---------------------------------------------------------------------------
# Test: module creates the event target when enabled (default)
# ---------------------------------------------------------------------------
run "creates_when_enabled" {
  command = plan

  assert {
    condition     = output.enabled == true
    error_message = "enabled output should be true when the module is enabled"
  }

  assert {
    condition     = length(aws_cloudwatch_event_target.this) == 1
    error_message = "exactly one aws_cloudwatch_event_target should be planned when enabled"
  }

  assert {
    condition     = aws_cloudwatch_event_target.this[0].target_id == "eg-test-thing"
    error_message = "target_id should equal the tf-label id 'eg-test-thing'"
  }

  assert {
    condition     = aws_cloudwatch_event_target.this[0].rule == "orders-created"
    error_message = "rule should pass through the rule_name input"
  }

  assert {
    condition     = aws_cloudwatch_event_target.this[0].arn == "arn:aws:lambda:us-east-1:123456789012:function:process-orders"
    error_message = "arn should pass through the target_arn input"
  }
}

# ---------------------------------------------------------------------------
# Test: retry_policy and dead_letter_config are configured when requested
# ---------------------------------------------------------------------------
run "configures_retry_and_dlq" {
  command = plan

  variables {
    dead_letter_arn        = "arn:aws:sqs:us-east-1:123456789012:eventbridge-dlq"
    maximum_retry_attempts = 3
  }

  assert {
    condition     = length(aws_cloudwatch_event_target.this[0].retry_policy) == 1
    error_message = "retry_policy block should be present when maximum_retry_attempts is set"
  }

  assert {
    condition     = aws_cloudwatch_event_target.this[0].retry_policy[0].maximum_retry_attempts == 3
    error_message = "maximum_retry_attempts should pass through to the retry_policy block"
  }

  assert {
    condition     = length(aws_cloudwatch_event_target.this[0].dead_letter_config) == 1
    error_message = "dead_letter_config block should be present when dead_letter_arn is set"
  }
}

# ---------------------------------------------------------------------------
# Test: module creates nothing when disabled
# ---------------------------------------------------------------------------
run "disabled_creates_nothing" {
  command = plan

  variables {
    enabled = false
  }

  assert {
    condition     = output.enabled == false
    error_message = "enabled output should be false when the module is disabled"
  }

  assert {
    condition     = length(aws_cloudwatch_event_target.this) == 0
    error_message = "no aws_cloudwatch_event_target should be planned when disabled"
  }
}
