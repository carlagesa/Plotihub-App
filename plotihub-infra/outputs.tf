output "vpc_id" { value = module.network_primary.vpc_id }
output "private_app_subnet_ids" { value = module.network_primary.private_app_subnet_ids }
output "private_db_subnet_ids" { value = module.network_primary.private_db_subnet_ids }
output "sg_lambda_id" { value = module.network_primary.sg_lambda_id }
output "sg_rds_proxy_id" { value = module.network_primary.sg_rds_proxy_id }
output "sg_aurora_id" { value = module.network_primary.sg_aurora_id }
output "vpce_security_group_id" { value = module.network_primary.vpce_sg_id }
output "vpc_endpoint_ids" { value = module.network_primary.vpc_endpoint_ids }
