import ballerina/http;
import ballerina/uuid;

configurable int port = 4000;

type Order record {
    string columnName;
    string sortOrder;
};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service /api on new http:Listener(port) {
    resource function post users(UserRegistration newUser) returns UserCreated|UserConflict|error {
        User|error user = forumDbClient->queryRow(`
            SELECT id, name, email FROM users WHERE name = ${newUser.name}
        `);
        if user is User {
            return {
                body: {
                    error_message: "User already exists"
                }
            };
        }

        string id = uuid:createType1AsString();
        _ = check forumDbClient->execute(`
            INSERT INTO users VALUES (${id}, ${newUser.name}, ${newUser.email}, ${newUser.password})
        `);

        return {
            body: {
                message: "User created successfully!"
            }
        };
    }

    resource function post login(UserCredentials userCredentials) returns LoginOk|UnauthorizedUser {
        User|error user = forumDbClient->queryRow(`
            SELECT id, name, email FROM users WHERE name = ${userCredentials.name} && password = ${userCredentials.password}
        `);
        if user is User {
            return {
                body: {
                    message: "Login successfully",
                    id: user.id
                }
            };
        }

        return {
            body: {
                error_message: "Invalid credentials"
            }
        };
    }

    resource function post users/[string id]/posts(NewForumPost newPost) returns PostCreated|UserNotFound|error {
        User|error user = forumDbClient->queryRow(`
            SELECT id, name, email FROM users WHERE id = ${id}
        `);
        if user is error {
            return {
                body: {
                    error_message: "User not found"
                }
            };
        }

        ForumPostInDB forumPost = check getForumPostInDB(id, newPost);
        _ = check forumDbClient->execute(`
            INSERT INTO posts VALUES (${forumPost.id}, ${forumPost.title}, ${forumPost.description}, ${forumPost.userId}, ${forumPost.likes}, ${forumPost.postedAt})
        `);

        return {
            body: {
                message: "Post created successfully"
            }
        };
    }

    resource function post posts/[string id]/like(PostLike like) returns PostLiked|PostNotFound|AlreadyLiked|error {
        ForumPostInDB|error forumPost = check forumDbClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if forumPost is error {
            PostNotFound postNotFound = {
                body: {
                    error_message: "Post not found"
                }
            };
            return postNotFound;
        }

        string[] likes = check forumPost.likes.fromJsonStringWithType();
        if likes.indexOf(like.userId) != () {
            AlreadyLiked alreadyLiked = {
                body: {
                    error_message: "Already liked"
                }
            };
            return alreadyLiked;
        }

        likes.push(like.userId);
        _ = check forumDbClient->execute(`UPDATE posts SET likes = ${likes.toJsonString()} WHERE id = ${id}`);

        return {
            body: {
                message: "Post liked successfully"
            }
        };
    }

    resource function post posts/[string id]/comments(NewPostComment newComment) returns CommentCreated|PostNotFound|error {
        ForumPostInDB|error forumPost = check forumDbClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if forumPost is error {
            PostNotFound postNotFound = {
                body: {
                    error_message: "Post not found"
                }
            };
            return postNotFound;
        }

        PostComment comment = check getPostComment(id, newComment);
        _ = check forumDbClient->execute(`
            INSERT INTO comments VALUES (${comment.id}, ${comment.postId}, ${comment.userId}, ${comment.comment}, ${comment.postedAt})
        `);

        return {
            body: {
                message: "Comment created successfully"
            }
        };
    }

    resource function get posts/[string id]() returns ForumPost|PostNotFound|error {
        ForumPostInDB|error forumPost = check forumDbClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
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
        stream<ForumPostInDB, error?> forumPostStream = forumDbClient->query(`SELECT * FROM posts ORDER BY posted_at ASC`);
        ForumPost[] forumPosts = check from ForumPostInDB forumPost in forumPostStream
            select check getForumPost(forumPost);

        return forumPosts;
    }
}
