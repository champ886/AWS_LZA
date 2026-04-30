# -----------------------------------------------
# ANALYZER ID
# -----------------------------------------------
output "analyzer_id" {
  description = "ID of the IAM Access Analyzer"
  value       = aws_accessanalyzer_analyzer.main.id
}

output "analyzer_name" {
  description = "Name of the IAM Access Analyzer"
  value       = aws_accessanalyzer_analyzer.main.analyzer_name
}