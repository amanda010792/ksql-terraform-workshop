# ksqlDB Workshop 

## Introduction 

ksqlDB is the streaming SQL engine for Apache Kafka. This workshop will step through some practical examples of how to use ksqlDB to build powerful stream-processing applications:    
-Filtering streams of data   
-Joining live streams of events with reference data (e.g. from a database)     
-Continuous, stateful aggregations     

## Pre-reqs / testing the setup

First things first, let’s get connected to the lab environment and make sure we have access to everything we need.     

### Open the Confluent Cloud Dashboard 

Prior to the workshop you should have recieved an email to login to Confluent Cloud. To ensure you have the necessary access, navigate to the [Confluent Cloud Dashboard](https://confluent.cloud/) and confirm the following:     
- You have access to an environment.     
- Ensure there is a cluster with your username (should be the username of the email you registered with).      
- Open the cluster and ensure you have the appropriate Connectors (2 datagen connectors) and topics (2 topics) set up.    
- Click on ksqlDB and ensure you have a cluster provisioned.     

### Syntax Reference

You will find it helpful to keep a copy of the KSQL syntax guide open in another browser tab: [Syntax Reference](https://docs.ksqldb.io/en/0.17.0-ksqldb/reference/)     

## ksqlDB


