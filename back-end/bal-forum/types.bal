import ballerina/http;
import ballerina/sql;
import ballerina/time;

type UserRegistration record {|
    string name;
    string email;
    string password;
|};

type User record {|
    string name;
    string email;
    string id;
|};

type UserCredentials record {|
    string name;
    string password;
|};

type ErrorResponse record {|
    string error_message;
|};

type SuccessResponse record {|
    string message;
|};

type SuccessLogin record {|
    *SuccessResponse;
    string id;
|};

type LoginOk record {|
    *http:Ok;
    SuccessLogin body;
|};

type UnauthorizedUser record {|
    *http:Unauthorized;
    ErrorResponse body;
|};

type UserCreated record {|
    *http:Created;
    SuccessResponse body;
|};

type PostCreated record {|
    *http:Created;
    SuccessResponse body;
|};

type PostLiked record {|
    *http:Ok;
    SuccessResponse body;
|};

type AlreadyLiked record {|
    *http:Conflict;
    ErrorResponse body;
|};

type CommentCreated record {|
    *http:Created;
    SuccessResponse body;
|};

type UserNotFound record {|
    *http:NotFound;
    ErrorResponse body;
|};

type PostNotFound record {|
    *http:NotFound;
    ErrorResponse body;
|};

type UserConflict record {|
    *http:Conflict;
    ErrorResponse body;
|};

type NewForumPost record {
    string title;
    string description;
    string timestamp;
};

type NewPostComment record {
    string userId;
    string comment;
    string timestamp;
};

type PostComment record {
    string id;
    @sql:Column {name: "user_id"}
    string userId;
    @sql:Column {name: "post_id"}
    string postId;
    string comment;
    @sql:Column {name: "posted_at"}
    time:Civil postedAt;
};

type ForumPost record {
    string title;
    string description;
    string userId;
    string id;
    string[] likes = [];
    PostComment[] comments = [];
    time:Civil postedAt;
};

type ForumPostInDB record {
    string title;
    string description;
    @sql:Column {name: "user_id"}
    string userId;
    string id;
    string likes = "[]";
    @sql:Column {name: "posted_at"}
    time:Civil postedAt;
};

type PostLike record {|
    string userId;
|};
