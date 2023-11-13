import ballerina/time;

type NewUser record {|
    string name;
    string email;
    string password;
|};

type User record {|
    string name;
    string email;
    string id;
    string[] subscribtions;
|};

type UserDb record {|
    string name;
    string email;
    string id;
    string subscribtions;
|};

type NewPost record {|
    string title;
    string description;
    string timestamp;
|};

type Post record {|
    string title;
    string description;
    string username;
    string id;
    string[] likes;
    Comment[] comments;
    time:Civil postedAt;
|};

type PostDb record {|
    string title;
    string username;
    string description;
    string id;
    string likes;
    string comments;
    time:Civil postedAt;
|};

type UserLogin record {|
    string name;
    string password;
|};

type Like record {|
    string userId;
|};

type NewComment record {|
    string username;
    string comment;
    string timestamp;
|};

type Comment record {|
    string id;
    string username;
    string comment;
    time:Civil postedAt;
|};
