module "app_topics_1" {
 source      = "./modules/app_topics"
 name_prefix = "vimal"
 cart_count = 3
}


module "app_topics_2" {
 source      = "./modules/app_topics"
 name_prefix = "vimal1"
 cart_count = 3
}
