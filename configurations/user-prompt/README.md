# ksqlDB Workshop 

## Introduction 

ksqlDB is the streaming SQL engine for Apache Kafka. This workshop will step through some practical examples of how to use ksqlDB to build powerful stream-processing applications:    
- Filtering streams of data   
- Joining live streams of events with reference data (e.g. from a database)     
- Continuous, stateful aggregations     

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

ksqlDB can be accessed via either the command line interface (CLI), a graphical UI built into the Confluent Cloud Dashboard, or the REST API.    

In this workshop we will mainly be using the Confluent Cloud Dashboard. To learn more about using the REST API and the CLI, please reference this [blog post](https://rmoff.net/2021/03/24/connecting-to-managed-ksqldb-in-confluent-cloud-with-rest-and-ksqldb-cli/).       

### Looking Around

You will find your ksqlDB cluster by navigating to the kafka cluster with your username and selecting "ksqlDB" on the left-hand menu. When we create streams and tables they will appear on the right side of the screen under "All available streams and tables". You'll also see the following tabs in the ksqlDB interface:     
- **Editor**    
- **Flow**     
- **Streams**    
- **Tables**    
- **Persistent Queries**     
- **Performance**    
- **Settings**     
- **CLI Instructions**     

### See available kafka topics and data 

Remember we discussed in the presentation that KSQL works with Streams and Tables, and these are just abstractions for working with data in topics ? So the first thing we will do is find what topics we have available to work with on our Kafka cluster - try entering:    
```
show topics;
```

The list of topics you see here is exactly the same as you would see in the 'Topics' section of Cloud Dashboard, except that here we are getting the list via a KSQL command instead of browsing graphically for it.     

We can also investigate some data from those topics before working with them:      
```
print 'xxxx' limit 3 
```
or
```
print 'xxxx' from beginning limit 3;
```

The topics we will use today are ratings and users.      

The event stream driving this example (the data in the ratings topic) is a simulated stream of events representing the ratings left by users on a mobile app or website, with fields including the device type that they used, the star rating (a score from 1 to 5), and an optional comment associated with the rating.     

Notice that we don’t need to know the format of the data when printing a topic; ksqlDB introspects the data and understands how to deserialize it.     
To stop the query, press the "stop" button.     

## Getting Started with DDL     

### Create the Ratings data stream 

Register the RATINGS data as a KSQL stream, sourced from the 'ratings' topic.   
```
create stream ratings with (kafka_topic='ratings', value_format='avro'); **this doesn't work - we need to set the schema explicitly for now until terraform can use schema registry. 
```

