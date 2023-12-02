import ballerina/sql;
import ballerina/time;

type UserRegistration record {
    string name;
    string email;
    string password;
};

type SuccessResponse record {
    string message;
};

type FailureResponse record {
    string error_message;
};

type UserCredentials record {
    string name;
    string password;
};

type UserLogin record {
    string message;
    string id;
};

type NewForumPost record {
    string title;
    string description;
    string timestamp;
};

type LikeRequest record {
    string userId;
};

type NewPostComment record {
    string userId;
    string comment;
    string postedAt;
};

type PostComment record {|
    string id;
    string username;
    string comment;
    time:Civil postedAt;
|};

type PostCommentInDB record {
    string id;
    @sql:Column {
        name: "post_id"
    }
    string postId;
    @sql:Column {
        name: "user_id"
    }
    string userId;
    string name?;
    string comment;
    @sql:Column {
        name: "posted_at"
    }
    time:Civil postedAt;
};

type ForumPost record {
    string title;
    string description;
    string username;
    string id;
    string[] likes;
    PostComment[] comments;
    time:Civil postedAt;
};

type ForumPostInDB record {
    string title;
    string description;
    @sql:Column {
        name: "user_id"
    }
    string userId;
    string name?;
    string id;
    string likes;
    @sql:Column {
        name: "posted_at"
    }
    time:Civil postedAt;
};

type Sentiment record {
    string label;
};

type RegisterEvent record {
    string email;
};
