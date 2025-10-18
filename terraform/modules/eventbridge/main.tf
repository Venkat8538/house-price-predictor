# EventBridge Module for Scheduled Triggers
resource "aws_cloudwatch_event_rule" "sagemaker_pipeline_trigger" {
  name                = "${var.project_name}-pipeline-trigger"
  description         = "Trigger SageMaker pipeline weekly"
  schedule_expression = "rate(7 days)"
  state               = "ENABLED"
}