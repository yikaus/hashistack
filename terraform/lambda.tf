resource "aws_iam_role" "lamb_ddns_role" {
    name = "lamb_ddns_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lamb_ddns_policy" {
    name = "lamb_ddns_policy"
    path = "/"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "autoscaling:Describe*",
        "logs:*",
        "route53:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "apex-lamb-attach" {
    role = "${aws_iam_role.lamb_ddns_role.name}"
    policy_arn = "${aws_iam_policy.lamb_ddns_policy.arn}"
}

resource "aws_lambda_function" "ddns_lambda" {
    filename = "lambda_function_ddns.zip"
    function_name = "lambda_hashiserver_ddns"
    role = "${aws_iam_role.lamb_ddns_role.arn}"
    handler = "main.handle"
    source_code_hash = "${base64sha256(file("lambda_function_ddns.zip"))}"
}

resource "aws_sns_topic" "asg-ddns-topic" {
  name = "asg-ddns-topic"
}

resource "aws_autoscaling_notification" "ddns_notifications" {
  group_names = [
    "${aws_autoscaling_group.server-asg.name}",
  ]
  notifications  = [
    "autoscaling:EC2_INSTANCE_LAUNCH", 
    "autoscaling:EC2_INSTANCE_TERMINATE"
  ]
  topic_arn = "${aws_sns_topic.asg-ddns-topic.arn}"
}

resource "aws_sns_topic_subscription" "lambda" {
    topic_arn = "${aws_sns_topic.asg-ddns-topic.arn}"
    protocol  = "lambda"
    endpoint  = "${aws_lambda_function.ddns_lambda.arn}"
}

resource "aws_lambda_permission" "with_sns" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.ddns_lambda.arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${aws_sns_topic.asg-ddns-topic.arn}"
}