# Integration Basics with Ballerina

## Training Objective

Cover basic concepts related to integration. Following sessions will cover different topics deeply.

## Areas Covered

- Installing and Managing distributions
- Writing a simple RESTful service
- Accessing database
- Data transformation with data mapper
- Code to Cloud
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

## Task 2 - Implement forum post related resources

### Post creation resource

- Path: `api/users/{id}/posts`
  
- Method: `POST`
  
- Request body:
  
  ```json
  {
    "title": "This is a sample title",
    "description": "This is a sample description",
    "timestamp": "2023-12-03T10:15:30.00Z"
  }
  ```

- Success response - `201 CREATED`:

  ```json
  {
    "message": "Post created successfully"
  }
  ```

- Failure response - `404 NOT FOUND`:

  ```json
  {
    "error_message": "User not found"
  }
  ```

### Post like resource

- Path: `api/posts/{id}/like`

- Method: `POST`

- Request body:

  ```json
  {
    "userId": "01ee82c7-1526-1530-b3d7-89902934ab7a"
  }
  ```

- Success response - `200 OK`:

  ```json
  {
    "message": "Post liked successfully"
  }
  ```

- Failure response - `404 NOT FOUND`:

  ```json
  {
    "error_message": "Post not found"
  }
  ```

- Failure response - `409 CONFLICT`:

  ```json
  {
    "error_message": "User already liked the post"
  }
  ```

### Post comment resource

- Path: `api/posts/{id}/comments`

- Method: `POST`

- Request body:

  ```json
  {
    "userId": "01ee82c7-1526-1530-b3d7-89902934ab7a",
    "comment": "This is a sample comment",
    "postedAt": "2023-12-03T10:15:30.00Z"
  }
  ```

- Success response - `200 OK`:

  ```json
  {
    "message": "Comment added successfully"
  }
  ```

- Failure response - `404 NOT FOUND`:

  ```json
  {
    "error_message": "Post not found"
  }
  ```

### Specific post retrieval resource

- Path: `api/posts/{id}`

- Method: `GET`

- Success Response - `200 OK`:

  ```json
  {
    "title": "This is a sample title",
    "description": "This is a sample description",
    "userId": "01ee82c7-1526-1530-b3d7-89902934ab7a",
    "id": "01ee82c7-1526-1530-b3d7-89902934ab7a",
    "likes": [
      "01ee82c7-1526-1530-b3d7-89902934ab7a"
    ],
    "comments": [
      {
        "id": "01ee82c7-1526-1530-b3d7-89902934ab7a",
        "userId": "01ee82c7-1526-1530-b3d7-89902934ab7a",
        "comment": "This is a sample comment",
        "postedAt": {
          "year": 2023,
          "month": 12,
          "day": 3,
          "hour": 10,
          "minute": 15
        }
      }
    ],
    "postedAt": {
      "year": 2023,
      "month": 12,
      "day": 3,
      "hour": 8,
      "minute": 10
    }
  }
  ```

- Failure response - `404 NOT FOUND`:

  ```json
  {
    "error_message": "Post not found"
  }
  ```

### Posts retrieval resource

- Path: `api/posts`

- Method: `GET`

- Success Response - `200 OK`:

  ```json
  [
    {
      "title": "This is a sample title",
      "description": "This is a sample description",
      "userId": "01ee82c7-1526-1530-b3d7-89902934ab7a",
      "id": "01ee82c7-1526-1530-b3d7-89902934ab7a",
      "likes": [
        "01ee82c7-1526-1530-b3d7-89902934ab7a"
      ],
      "comments": [
        {
          "id": "01ee82c7-1526-1530-b3d7-89902934ab7a",
          "userId": "01ee82c7-1526-1530-b3d7-89902934ab7a",
          "comment": "This is a sample comment",
          "postedAt": {
            "year": 2023,
            "month": 12,
            "day": 3,
            "hour": 10,
            "minute": 15
          }
        }
      ],
      "postedAt": {
        "year": 2023,
        "month": 12,
        "day": 3,
        "hour": 8,
        "minute": 10
      }
    }
  ]
  ```
