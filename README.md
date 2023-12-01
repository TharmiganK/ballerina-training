# Integration Basics with Ballerina

## Training Objective

Cover basic concepts related to integration. Following sessions will cover different topics deeply.

## Areas Covered

- Installing and Managing distributions
- Writing a simple RESTful service
- Accessing database
- Code to Cloud
- Data transformation with data mapper
- HTTP client
- Resiliency
- Service/Client security with SSL/MTLS
- Security - OAuth2

## Prerequisites

- Install the latest version of Ballerina
- Set up VS code by installing the Ballerina extension
- Install Docker

## Scenario

The scenario is based on a simple API written for a forum site, which has users, associated posts and comments. Following depicts the high level component diagram:

![Component Diagram](resources/bal-forum.png)

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

![Entity Relationship Diagram](resources/bal-forum-erd.png)

## Task 1 - Implement registration and login resources

### Registration resource

- Path: `api/users`
  
- Method: `POST`
  
- Request body:
  
  ```json
  {
    "name": "david",
    "email": "david@gmail.com",
    "password": "*******"
  }
  ```

- Success response - `201 CREATED`:

  ```json
  {
    "message": "User created successfully"
  }
  ```

- Failure response - `409 CONFLICT`:

  ```json
  {
    "error_message": "User already exists"
  }
  ```

### Login resource

- Path: `api/login`

- Method: `POST`

- Request body:

   ```json
   {
     "name": "string",
     "password": "string"
   }
   ```

- Success Response - `200 OK`:

   ```json
   {
     "message": "Login successful",
     "id": "01ee82c7-1526-1530-b3d7-89902934ab7a"
   }
   ```

- Failure Response - `401 UNAUTHORIZED`:

   ```json
   {
     "error_message": "Invalid credentials"
   }
   ```
