resource "aws_config_configuration_recorder" "recorder" {
  name     = "lite-recorder"
  role_arn = var.config_role_arn

  recording_group {
    all_supported = false

    resource_types = [
      "AWS::EC2::Instance",
      "AWS::S3::Bucket"
    ]
  }
}

resource "aws_config_delivery_channel" "channel" {
  name           = "lite-channel"
  s3_bucket_name = var.bucket_name
}

resource "aws_config_configuration_recorder_status" "status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
}