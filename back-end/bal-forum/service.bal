import ballerina/http;
import ballerina/task;
import ballerina/time;
import ballerina/uuid;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service /api on new http:Listener(4000) {
    resource function post users(UserRegistration newUser) returns UserCreated|UserAlreadyExist|error {
        string|error id = forumDBClient->queryRow(`SELECT id FROM users WHERE name = ${newUser.name}`);

        if id is string {
            return {
                body: {
                    error_message: "User already exists"
                }
            };
        }

        string userId = uuid:createType1AsString();
        _ = check forumDBClient->execute(`INSERT INTO users VALUES (${userId}, ${newUser.name}, ${newUser.email}, ${newUser.password})`);

        _ = start sendNatsMessage(newUser.name, newUser.email);

        return {
            body: {
                message: "User created successfully"
            }
        };
    }

    resource function post login(UserCredentials credentials) returns LoginSuccess|LoginFailure {
        string|error id = forumDBClient->queryRow(`SELECT id FROM users WHERE name = ${credentials.name} AND password = ${credentials.password}`);

        if id is string {
            return {
                body: {
                    id: id,
                    message: "Login successful"
                }
            };
        }

        return {
            body: {
                error_message: "Invalid credentials"
            }
        };
    }

    resource function post users/[string id]/posts(NewForumPost newPost, string? schedule = ()) returns PostCreated|UserNotFound|PostRejected|BadPostSchedule|error {
        string|error userId = forumDBClient->queryRow(`SELECT id FROM users WHERE id = ${id}`);

        if userId is error {
            return <UserNotFound>{
                body: {
                    error_message: "User not found"
                }
            };
        }

        Text text = {
            text: newPost.title + " " + newPost.description
        };

        Sentiment sentiment = check sentimentAPI->/api/sentiment.post(text);
        if sentiment.label != "pos" {
            return <PostRejected>{
                body: {
                    error_message: "Post rejected due to negative sentiment"
                }
            };
        }

        if schedule is () {
            check createForumPost(id, newPost);

            return {
                body: {
                    message: "Post created successfully"
                }
            };
        }

        do {
            time:Civil scheduledTime = check time:civilFromString(schedule);
            _ = check task:scheduleOneTimeJob(new CreatPostJob(id, newPost), scheduledTime);
        } on fail {
            return <BadPostSchedule>{
                body: {
                    error_message: "Invalid schedule time"
                }
            };
        }

        return {
            body: {
                message: "Post scheduled successfully"
            }
        };
    }

    resource function post posts/[string id]/likes(LikeRequest likeRequest) returns PostLiked|PostNotFound|PostAlreadyLiked|error {
        ForumPostInDB|error forumPost = check forumDBClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if forumPost is error {
            PostNotFound postNotFound = {
                body: {
                    error_message: "Post not found"
                }
            };
            return postNotFound;
        }

        string[] likes = check forumPost.likes.fromJsonStringWithType();
        if likes.indexOf(likeRequest.userId) != () {
            PostAlreadyLiked alreadyLiked = {
                body: {
                    error_message: "Already liked"
                }
            };
            return alreadyLiked;
        }

        likes.push(likeRequest.userId);
        _ = check forumDBClient->execute(`UPDATE posts SET likes = ${likes.toJsonString()} WHERE id = ${id}`);

        return {
            body: {
                message: "Post liked successfully"
            }
        };
    }

    resource function post posts/[string id]/comments(NewPostComment newComment) returns CommentAdded|PostNotFound|error {
        ForumPostInDB|error forumPost = check forumDBClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if forumPost is error {
            PostNotFound postNotFound = {
                body: {
                    error_message: "Post not found"
                }
            };
            return postNotFound;
        }

        PostCommentInDB comment = check creatPostCommentInDB(id, newComment);
        _ = check forumDBClient->execute(`
            INSERT INTO comments VALUES (${comment.id}, ${comment.postId}, ${comment.userId}, ${comment.comment}, ${comment.postedAt})
        `);

        return {
            body: {
                message: "Comment created successfully"
            }
        };
    }

    resource function get posts/[string id]() returns ForumPost|PostNotFound|error {
        ForumPostInDB|error forumPost = check forumDBClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if forumPost is error {
            PostNotFound postNotFound = {
                body: {
                    error_message: "Post not found"
                }
            };
            return postNotFound;
        }

        return getForumPost(forumPost);
    }

    resource function get posts() returns ForumPost[]|error {
        stream<ForumPostInDB, error?> forumPostStream = forumDBClient->query(`SELECT * FROM posts ORDER BY posted_at ASC`);
        ForumPost[] forumPosts = check from ForumPostInDB forumPost in forumPostStream
            select check getForumPost(forumPost);

        return forumPosts;
    }
}

type CommentAdded record {|
    *http:Ok;
    SuccessResponse body;
|};

type PostAlreadyLiked record {|
    *http:Conflict;
    FailureResponse body;
|};

type PostNotFound record {|
    *http:NotFound;
    FailureResponse body;
|};

type PostLiked record {|
    *http:Ok;
    SuccessResponse body;
|};

type BadPostSchedule record {|
    *http:BadRequest;
    FailureResponse body;
|};

type PostRejected record {|
    *http:Forbidden;
    FailureResponse body;
|};

type UserNotFound record {|
    *http:NotFound;
    FailureResponse body;
|};

type PostCreated record {|
    *http:Created;
    SuccessResponse body;
|};

type LoginFailure record {|
    *http:Unauthorized;
    FailureResponse body;
|};

type LoginSuccess record {|
    *http:Ok;
    UserLogin body;
|};

type UserAlreadyExist record {|
    *http:Conflict;
    FailureResponse body;
|};

type UserCreated record {|
    *http:Created;
    SuccessResponse body;
|};
