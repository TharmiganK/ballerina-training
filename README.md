# Integration Basics with Ballerina

## Training Objective

Cover basic concepts related to integration. Following sessions will cover different topics deeply.

## Areas Covered

- Installing and Managing distributions
- Writing a simple RESTful service
- Accessing database
- Data transformation with data mapper
- HTTP client
- Resiliency
- Service/Client security with SSL/MTLS
- Security - OAuth2
- Code to Cloud

## Prerequisites

- Install the latest version of Ballerina
- Set up VS code by installing the Ballerina extension
- Install Docker

## Scenario

The scenario is based on a simple API written for a forum site, which has users, associated posts and comments. Following depicts the high level component diagram:

![Component Diagram](images/bal-forum.png)

The forum REST service exposes the following resources:

| Resource | Description |
| -------- | ----------- |
| `POST api/users` | Create a new user |
| `POST api/login` | Login as with user credentials |
| `POST api/users/{id}/posts` | Create a new forum post |
| `GET api/posts` | Get all the forum posts |
| `GET api/posts/{id}` | Get the forum post specified by the id |
| `POST api/posts/{id}/like` | Like a forum post |
| `POST api/posts/{id}/comments` | Comment on a post |

Following is the entity relationship diagram:

![Entity Relationship Diagram](images/bal-forum-erd.png)

## Task 4 - Make the sentiment analysis client resilient

The sentiment analysis service is not reliable. It can be down at times. We need to make the client resilient to handle such failures.

The Ballerina HTTP client supports the following resiliency features:

- [Retry](https://ballerina.io/learn/by-example/http-retry/)
- [Circuit Breaker](https://ballerina.io/learn/by-example/http-circuit-breaker/)
- [Load Balancer](https://ballerina.io/learn/by-example/http-load-balancer/)
- [Failover](https://ballerina.io/learn/by-example/http-failover/)

Make the sentiment analysis client resilient by retrying the request for 3 times with a delay of 1 second between each retry.
