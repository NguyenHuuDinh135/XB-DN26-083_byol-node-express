terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# --- Lambda Execution Role ---
resource "aws_iam_role" "lambda_exec" {
  name = "byol-node-express-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --- Lambda Function ---
resource "aws_lambda_function" "express_app" {
  filename      = "${path.module}/lambda.zip"
  function_name = "byol-node-express"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "run.sh"
  runtime       = "nodejs22.x"
  architectures = ["arm64"]
  memory_size   = 512
  timeout       = 10

  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  layers = [
    "arn:aws:lambda:us-west-2:753240598075:layer:LambdaAdapterLayerArm64:25"
  ]

  environment {
    variables = {
      AWS_LAMBDA_EXEC_WRAPPER = "/opt/bootstrap"
      AWS_LWA_PORT            = "3000"
      PORT                    = "3000"
    }
  }
}

# --- CloudWatch Logs ---
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.express_app.function_name}"
  retention_in_days = 7
}

# --- HTTP API (Gateway v2) ---
resource "aws_apigatewayv2_api" "http_api" {
  name          = "byol-node-express-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"

  integration_uri    = aws_lambda_function.express_app.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "root_proxy" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "root" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# --- Lambda Permission for API Gateway ---
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.express_app.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# --- Outputs ---
output "api_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}
