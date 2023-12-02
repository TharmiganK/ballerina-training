import ballerina/log;
import ballerina/task;

class CreatPostJob {
    *task:Job;
    string id;
    NewForumPost newPost;

    function init(string id, NewForumPost newPost) {
        self.id = id;
        self.newPost = newPost;
    }

    public function execute() {
        do {
            check createForumPost(self.id, self.newPost);
            log:printInfo("Post created successfully", id = self.id, title = self.newPost.title);
        } on fail error err {
            log:printError("Error occurred while creating the post", title = self.newPost.title, 'error = err);
        }
    }
}

function createForumPost(string id, NewForumPost newPost) returns error? {
    ForumPostInDB forumPost = check createForumPostInDB(id, newPost);
    _ = check forumDBClient->execute(`INSERT INTO posts VALUES (${forumPost.id}, ${forumPost.title}, ${forumPost.description}, ${forumPost.userId}, ${forumPost.likes}, ${forumPost.postedAt})`);
}

function getForumPost(ForumPostInDB forumPostInDB) returns ForumPost|error {
    stream<PostComment, error?> commentStream = forumDBClient->query(`SELECT * FROM comments WHERE post_id = ${forumPostInDB.id} ORDER BY posted_at ASC`);
    PostComment[] comments = check from PostComment comment in commentStream
        select comment;

    ForumPost forumPost = {
        id: forumPostInDB.id,
        userId: forumPostInDB.userId,
        title: forumPostInDB.title,
        description: forumPostInDB.description,
        likes: check forumPostInDB.likes.fromJsonStringWithType(),
        comments: comments,
        postedAt: forumPostInDB.postedAt
    };

    return forumPost;
}

function sendNatsMessage(string name, string email) {
    RegisterEvent event = {name, email};
    do {
        _ = check natsClient->publishMessage({subject: "ballerina.forum", content: event});
    } on fail error err {
        log:printError("Error occurred while sending nats message", event = event, 'error = err);
    }
}
