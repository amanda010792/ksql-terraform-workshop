#terraform variable file for Confluent instructor setup 
  
#required provider -- confluent 

# spin up environment called "ksql_workshop_env"

# spin up kafka cluster called "basic" in ksql_workshop_env (created above)

# create a service account for ksqldb 

# create a rolebinding for ksqldb service account (created above) to give it cluster admin access for basic cluster (created above)

# create ksql cluster in env and cluster (created above) depending on the service account created above

# create a service account called topic manager 

# create a role binding for topic manager service account (created above) that has cloud cluster admin access to basic cluster (created above)

# create an api key for the topic manager service account (created above) 

# create a topic called ratings using the api key (created above)

# create a kafka topic called users using the api key (created above)

# create a service account called "connect-manager"

# create a role binding to the connect-manager service account (created above) to give it cluster admin access for basic cluster (created above)

# create an api key for the connect-manager service account (created above)

# create a service account called "application-connector"

# create an api key tied to the application-connector service account (created above)

# created an ACL called "application-connector-describe-on-cluster" that grants the application-connector service account describe permission on the basic cluster (created above)

# created an ACL called "application-connector-write-on-ratings" that grants the application-connector service account write permission on the ratings topic (created above)

# created an ACL called "application-connector-write-on-users" that grants the application-connector service account write permission on the users topic (created above)

# created an ACL called "application-connector-create-on-data-preview-topics" that grants the application-connector service account create permission on the preview topics 

# created an ACL called "application-connector-write-on-data-preview-topics" that grants the application-connector service account write permission on the preview topics 

# create a connector called "ratings_source" that creates a datagen connector called "DatagenSourceConnector_ratings" using the ratings quickstart of datagen and writes to the ratings topic (depends on acls above)

# create a connector called "users_source" that creates a datagen connector called "DatagenSourceConnector_users" using the users quickstart of datagen and writes to the users topic (depends on acls above)



