terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.4.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

//spin up environments (1 per every 10 users) 

resource "confluent_environment" "ksql_workshop_env" {
  count = ceil(length(var.user_account_logins)/10)
  display_name = "ksql_workshop_env.${count.index}"
}

//spin up clusters (1 per enviornment) 

resource "confluent_kafka_cluster" "basic" {
  count = length(confluent_environment.ksql_workshop_env)
  display_name = "ksql_workshop_cluster.${count.index}"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-east-2"
  basic {}

  environment {
    id = confluent_environment.ksql_workshop_env[count.index]
  }

  lifecycle {
    prevent_destroy = false
  }
}

//grant kafka cluster admin access to each user 
//first need to pull in all users by email 

data "confluent_user" "workshop_user" {
  count = length(var.user_account_logins)
  email = var.user_account_logins[count.index]
}

//then make each workshop user a cluster admin for the kafka cluster they are assigned to 
  

resource "confluent_role_binding" "test-role-binding" {
  count=length(var.user_account_logins)
  principal   = "User:${data.confluent_user.workshop_user[count.index].id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic[floor(count.index/10)].rbac_crn 
}


//spin up ksql clusters (1 per user) 

resource "confluent_service_account" "app-ksql" {
  count=length(var.user_names)
  display_name = "app-ksql-${var.user_names[count.index]}"
  description  = "Service account to manage workshop ksqlDB cluster"
}

resource "confluent_role_binding" "app-ksql-kafka-cluster-admin" {
  count=length(var.user_names)
  principal   = "User:${confluent_service_account.app-ksql[count.index].id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic[floor(count.index/10)].rbac_crn
}

resource "confluent_ksql_cluster" "workshop_ksql_cluster" {
  count=length(var.user_names)
  display_name = "ksql.${var.user_names[count.index]}"
  csu          = 1
  kafka_cluster {
    id = confluent_kafka_cluster.basic[floor(count.index/10)].id
  }
  credential_identity {
    id = confluent_service_account.app-ksql[count.index].id
  }
  environment {
    id = confluent_environment.ksql_workshop_env[floor(count.index/10)].id
  }
  depends_on = [
    confluent_role_binding.app-ksql-kafka-cluster-admin
  ]
}

//set up the permissions to create topics on the clusters
resource "confluent_service_account" "topic-manager" {
  display_name = "topic-manager"
  description  = "Service account to manage Kafka cluster"
}

resource "confluent_role_binding" "topic-manager-kafka-cluster-admin" {
  count = length(confluent_kafka_cluster.basic)
  principal   = "User:${confluent_service_account.topic-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic[count.index].rbac_crn
}

resource "confluent_api_key" "topic-manager-kafka-api-key" {
  count = length(confluent_kafka_cluster.basic)
  display_name = "topic-manager-kafka-api-key-${count.index}"
  description  = "Kafka API Key that is owned by 'topic-manager' service account"
  owner {
    id          = confluent_service_account.topic-manager.id
    api_version = confluent_service_account.topic-manager.api_version
    kind        = confluent_service_account.topic-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.basic[count.index].id
    api_version = confluent_kafka_cluster.basic[count.index].api_version
    kind        = confluent_kafka_cluster.basic[count.index].kind

    environment {
      id = confluent_environment.ksql_workshop_env[count.index].id
    }
  }

  depends_on = [
    confluent_role_binding.topic-manager-kafka-cluster-admin
  ]
}

//set up the topics 
  
  
resource "confluent_kafka_topic" "ratings" {
  count = length(confluent_kafka_cluster.basic)
  kafka_cluster {
    id = confluent_kafka_cluster.basic[count.index].id
  }
  topic_name    = "ratings"
  rest_endpoint = confluent_kafka_cluster.basic[count.index].rest_endpoint
  credentials {
    key    = confluent_api_key.topic-manager-kafka-api-key[count.index].id
    secret = confluent_api_key.topic-manager-kafka-api-key[count.index].secret
  }
}

  
resource "confluent_kafka_topic" "users" {
  count = length(confluent_kafka_cluster.basic)
  kafka_cluster {
    id = confluent_kafka_cluster.basic[count.index].id
  }
  topic_name    = "users"
  rest_endpoint = confluent_kafka_cluster.basic[count.index].rest_endpoint
  credentials {
    key    = confluent_api_key.topic-manager-kafka-api-key[count.index].id
    secret = confluent_api_key.topic-manager-kafka-api-key[count.index].secret
  }
}
  
//set up connector access permissions 


    
resource "confluent_service_account" "connect-manager" {
  display_name = "connect-manager"
  description  = "Service account to manage Kafka cluster"
}
  

resource "confluent_role_binding" "connect-manager-kafka-cluster-admin" {
  count = length(confluent_kafka_cluster.basic)
  principal   = "User:${confluent_service_account.connect-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic[count.index].rbac_crn
}

resource "confluent_api_key" "connect-manager-kafka-api-key" {
  count = length(confluent_kafka_cluster.basic)
  display_name = "connect-manager-kafka-api-key-${count.index}"
  description  = "Kafka API Key that is owned by 'connect-manager' service account"
  owner {
    id          = confluent_service_account.connect-manager.id
    api_version = confluent_service_account.connect-manager.api_version
    kind        = confluent_service_account.connect-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.basic[count.index].id
    api_version = confluent_kafka_cluster.basic[count.index].api_version
    kind        = confluent_kafka_cluster.basic[count.index].kind

    environment {
      id = confluent_environment.ksql_workshop_env[count.index].id
    }
  }

  depends_on = [
    confluent_role_binding.connect-manager-kafka-cluster-admin
  ]
}
  
resource "confluent_service_account" "application-connector" {
  display_name = "application-connector"
  description  = "Service account of Datagen Connectors"
}

resource "confluent_api_key" "application-connector-kafka-api-key" {
  count = length(confluent_kafka_cluster.basic)
  display_name = "application-connector-kafka-api-key-${count.index}"
  description  = "Kafka API Key that is owned by 'application-connector' service account"
  owner {
    id          = confluent_service_account.application-connector.id
    api_version = confluent_service_account.application-connector.api_version
    kind        = confluent_service_account.application-connector.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.basic[count.index].id
    api_version = confluent_kafka_cluster.basic[count.index].api_version
    kind        = confluent_kafka_cluster.basic[count.index].kind

    environment {
      id = confluent_environment.ksql_workshop_env[count.index].id
    }
  }
}

resource "confluent_kafka_acl" "application-connector-describe-on-cluster" {
  count = length(confluent_kafka_cluster.basic)
  kafka_cluster {
    id = confluent_kafka_cluster.basic[count.index].id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.application-connector.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.basic[count.index].rest_endpoint
  credentials {
    key    = confluent_api_key.connect-manager-kafka-api-key[count.index].id
    secret = confluent_api_key.connect-manager-kafka-api-key[count.index].secret
  }
}

resource "confluent_kafka_acl" "application-connector-write-on-ratings" {
  count = length(confluent_kafka_cluster.basic)
  kafka_cluster {
    id = confluent_kafka_cluster.basic[count.index].id
  }
  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.ratings[count.index].topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.application-connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.basic[count.index].rest_endpoint
  credentials {
    key    = confluent_api_key.connect-manager-kafka-api-key[count.index].id
    secret = confluent_api_key.connect-manager-kafka-api-key[count.index].secret
  }
}
  
resource "confluent_kafka_acl" "application-connector-write-on-users" {
  count = length(confluent_kafka_cluster.basic)
  kafka_cluster {
    id = confluent_kafka_cluster.basic[count.index].id
  }
  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.users[count.index].topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.application-connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.basic[count.index].rest_endpoint
  credentials {
    key    = confluent_api_key.connect-manager-kafka-api-key[count.index].id
    secret = confluent_api_key.connect-manager-kafka-api-key[count.index].secret
  }
}

resource "confluent_kafka_acl" "application-connector-create-on-data-preview-topics" {
  count = length(confluent_kafka_cluster.basic)
  kafka_cluster {
    id = confluent_kafka_cluster.basic[count.index].id
  }
  resource_type = "TOPIC"
  resource_name = "data-preview"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.application-connector.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.basic[count.index].rest_endpoint
  credentials {
    key    = confluent_api_key.connect-manager-kafka-api-key[count.index].id
    secret = confluent_api_key.connect-manager-kafka-api-key[count.index].secret
  }
}

resource "confluent_kafka_acl" "application-connector-write-on-data-preview-topics" {
  count = length(confluent_kafka_cluster.basic)
  kafka_cluster {
    id = confluent_kafka_cluster.basic[count.index].id
  }
  resource_type = "TOPIC"
  resource_name = "data-preview"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.application-connector.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.basic[count.index].rest_endpoint
  credentials {
    key    = confluent_api_key.connect-manager-kafka-api-key[count.index].id
    secret = confluent_api_key.connect-manager-kafka-api-key[count.index].secret
  }
}
  
//spin up connectors 
  
resource "confluent_connector" "ratings_source" {
  count = length(confluent_kafka_cluster.basic)
  environment {
    id = confluent_environment.ksql_workshop_env[count.index].id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic[count.index].id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_ratings"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.application-connector.id
    "kafka.topic"              = confluent_kafka_topic.ratings[count.index].topic_name
    "output.data.format"       = "JSON_SR"
    "quickstart"               = "RATINGS"
    "tasks.max"                = "1"
  }

  depends_on = [
    confluent_kafka_acl.application-connector-describe-on-cluster,
    confluent_kafka_acl.application-connector-write-on-target-topic,
    confluent_kafka_acl.application-connector-create-on-data-preview-topics,
    confluent_kafka_acl.application-connector-write-on-data-preview-topics,
  ]
}

resource "confluent_connector" "users_source" {
  count = length(confluent_kafka_cluster.basic)
  environment {
    id = confluent_environment.ksql_workshop_env[count.index].id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic[count.index].id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_users"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.application-connector.id
    "kafka.topic"              = confluent_kafka_topic.users[count.index].topic_name
    "output.data.format"       = "JSON_SR"
    "quickstart"               = "CLICKSTREAM_USERS"
    "tasks.max"                = "1"
  }

  depends_on = [
    confluent_kafka_acl.application-connector-describe-on-cluster,
    confluent_kafka_acl.application-connector-write-on-target-topic,
    confluent_kafka_acl.application-connector-create-on-data-preview-topics,
    confluent_kafka_acl.application-connector-write-on-data-preview-topics,
  ]
}
