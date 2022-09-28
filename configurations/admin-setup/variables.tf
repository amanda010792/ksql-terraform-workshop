variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

# variable "user_names" {
#   description = "Create ksqlDB Clusters with these Names"
#   type        = list(string)
# }

# variable "user_account_logins" {
#   description = "Grant Kafka Cluster Admin Access to these User Accounts"
#   type        = list(string)
# }
