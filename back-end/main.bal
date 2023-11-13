import ballerina/http;
import ballerina/sql;
import ballerina/uuid;

configurable int PORT = 4000;
listener http:Listener serverEP = new (PORT);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service /api on serverEP {
    resource function post users(NewUser newUser) returns http:Created|http:Conflict|error {
        User|error user = forumDbClient->queryRow(`
            SELECT id, name, email FROM users WHERE name = ${newUser.name}
        `);
        if user is User {
            return <http:Conflict>{
                body: {
                    error_message: "User already exists"
                }
            };
        }
        string id = uuid:createType1AsString();
        _ = check forumDbClient->execute(`
            INSERT INTO users VALUES (${id}, ${newUser.name}, ${newUser.email}, ${newUser.password}, "[]")
        `);
        return <http:Created>{
            body: {
                message: "Account created successfully!"
            }
        };
    }

    resource function get users/[string id]() returns http:Ok|http:NotFound|error {
        UserDb|error userDb = forumDbClient->queryRow(`
            SELECT name, email, id, subscribtions FROM users WHERE id = ${id}
        `);
        if userDb is UserDb {
            User user = check transformUserFromDatabase(userDb);
            return <http:Ok>{
                body: {
                    user: user
                }
            };
        }
        return <http:NotFound>{
            body: {
                error_message: "User not found"
            }
        };
    }

    resource function post login(UserLogin userLogin) returns http:Ok|http:Unauthorized {
        User|error user = forumDbClient->queryRow(`
            SELECT id, name, email FROM users WHERE name = ${userLogin.name} && password = ${userLogin.password}
        `);
        if user is User {
            return <http:Ok>{
                body: {
                    message: "Login successfully",
                    user: user
                }
            };
        }
        return <http:Unauthorized>{
            body: {
                error_message: "Invalid credentials"
            }
        };
    }

    resource function post users/[string id]/posts(NewPost newPost) returns http:Created|error {
        UserDb userDb = check forumDbClient->queryRow(`
            SELECT name, email, id, subscribtions FROM users WHERE id = ${id}
        `);
        User user = check transformUserFromDatabase(userDb);
        Post post = check createPostFromNewPost(newPost, user.name);
        _ = check forumDbClient->execute(`
            INSERT INTO posts VALUES (${post.id}, ${post.title}, ${post.description}, ${post.username}, ${post.likes.toJsonString()}, ${post.comments.toJsonString()}, ${post.postedAt})
        `);
        if user.subscribtions.indexOf(post.id) is () {
            user.subscribtions.push(post.id);
            _ = check forumDbClient->execute(`
            UPDATE users SET subscribtions = ${user.subscribtions.toJsonString()} WHERE id = ${id}
        `);
        }
        return <http:Created>{
            body: {
                message: "Post created successfully!"
            }
        };
    }

    resource function get posts() returns http:Ok|error {
        stream<PostDb, sql:Error?> postStream = forumDbClient->query(`SELECT * FROM posts`);
        Post[] posts = check from var post in postStream
            select check transformPostFromDatabase(post);
        return {
            body: {
                posts: posts
            }
        };
    }

    resource function get users/[string id]/posts() returns http:Ok|error {
        string username = check forumDbClient->queryRow(`
            SELECT name FROM users WHERE id = ${id}
        `);
        stream<PostDb, sql:Error?> postStream = forumDbClient->query(`
            SELECT * FROM posts WHERE username = ${username}
        `);
        Post[] posts = check from var post in postStream
            select check transformPostFromDatabase(post);
        return {
            body: {
                posts: posts
            }
        };
    }

    resource function post posts/[string id]/like(Like like) returns http:Ok|http:NotFound|http:Conflict|error {
        PostDb|error postDb = forumDbClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if postDb is PostDb {
            Post post = check transformPostFromDatabase(postDb);
            if post.likes.indexOf(like.userId) is int {
                return <http:Conflict>{
                    body: {
                        error_message: "You have already liked this post"
                    }
                };
            }
            post.likes.push(like.userId);
            _ = check forumDbClient->execute(`
                UPDATE posts SET likes = ${post.likes.toJsonString()} WHERE id = ${id}
            `);
            return <http:Ok>{
                body: {
                    message: "Post liked successfully!"
                }
            };
        }
        return <http:NotFound>{
            body: {
                error_message: "Post not found"
            }
        };
    }

    resource function get posts/[string id]() returns http:Ok|http:NotFound|error {
        PostDb|error postDb = forumDbClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if postDb is PostDb {
            Post post = check transformPostFromDatabase(postDb);
            return <http:Ok>{
                body: {
                    post: post
                }
            };
        }
        return <http:NotFound>{
            body: {
                error_message: "Post not found"
            }
        };
    }

    resource function post posts/[string id]/comments(NewComment newComment) returns http:Created|http:NotFound|error {
        PostDb|error postDb = forumDbClient->queryRow(`SELECT * FROM posts WHERE id = ${id}`);
        if postDb is PostDb {
            Post post = check transformPostFromDatabase(postDb);
            Comment comment = check createCommentFromNewComment(newComment);
            post.comments.push(comment);
            _ = check forumDbClient->execute(`
                UPDATE posts SET comments = ${post.comments.toJsonString()} WHERE id = ${id}
            `);
            if post.username != newComment.username {
                _ = check natsClient->publishMessage({subject: id, content: "New comment from " + newComment.username + " on " + post.title + " post"});
            }
            return <http:Created>{
                body: {
                    message: "Comment added successfully!"
                }
            };
        }
        return <http:NotFound>{
            body: {
                error_message: "Post not found"
            }
        };
    }
}
