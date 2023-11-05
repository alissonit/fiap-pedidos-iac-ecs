resource "aws_apigatewayv2_vpc_link" "fiap_pedidos" {
  name               = "${var.app_name}-vpc-link"
  subnet_ids         = [data.aws_subnet.clustera.id, data.aws_subnet.clusterb.id, data.aws_subnet.clusterc.id]
  security_group_ids = []
  tags = {
    Name = "api-${var.app_name}"
  }
}

resource "aws_apigatewayv2_api" "fiap_pedidos" {
  name          = "${var.app_name}-api"
  description   = "API Gateway for fiap-pedidos"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "fiap_pedidos" {
  api_id     = aws_apigatewayv2_api.fiap_pedidos.id
  route_key  = "ANY /{proxy+}"
  target     = "integrations/${aws_apigatewayv2_integration.fiap_pedidos.id}"
  depends_on = [aws_apigatewayv2_integration.fiap_pedidos]
}

resource "aws_apigatewayv2_integration" "fiap_pedidos" {
  api_id           = aws_apigatewayv2_api.fiap_pedidos.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_lb_listener.fiap_pedidos.arn

  integration_method     = "ANY"
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.fiap_pedidos.id
  payload_format_version = "1.0"
  depends_on = [aws_apigatewayv2_vpc_link.fiap_pedidos,
    aws_apigatewayv2_api.fiap_pedidos,
  aws_lb_listener.fiap_pedidos]
}

resource "aws_apigatewayv2_stage" "fiap_pedidos" {
  api_id      = aws_apigatewayv2_api.fiap_pedidos.id
  name        = "$default"
  auto_deploy = true
  depends_on  = [aws_apigatewayv2_api.fiap_pedidos]
}

output "apigw_endpoint" {
  value       = aws_apigatewayv2_api.fiap_pedidos.api_endpoint
  description = "API Gateway Endpoint"
}
