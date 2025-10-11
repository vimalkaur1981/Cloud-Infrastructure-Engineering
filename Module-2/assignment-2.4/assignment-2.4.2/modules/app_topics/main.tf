
resource "aws_sns_topic" "alert_topic" {
 name = "${var.name_prefix}-alert-sns-topic"
}


resource "aws_s3_bucket" "alert_bucket" {
 bucket = "${var.name_prefix}-20082025-alert-bucket"
 force_destroy = true
}


resource "aws_sns_topic" "cart_topic" {
 count = var.cart_count
 name  = "${var.name_prefix}-cart-${count.index}-sns-topic"
}

