output "primary_cluster_endpoint" {
  description = "The writer endpoint for the primary Aurora cluster."
  value       = aws_rds_cluster.primary.endpoint
}

output "primary_cluster_reader_endpoint" {
  description = "The reader endpoint for the primary Aurora cluster."
  value       = aws_rds_cluster.primary.reader_endpoint
}

output "primary_cluster_id" {
  description = "The identifier of the primary Aurora cluster."
  value       = aws_rds_cluster.primary.cluster_identifier
}

output "secondary_cluster_id" {
  description = "The identifier of the secondary Aurora cluster."
  value       = aws_rds_cluster.secondary.cluster_identifier
}