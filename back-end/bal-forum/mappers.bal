import ballerina/time;
import ballerina/uuid;

function getForumPostInDB(string userId, NewForumPost newForumPost) returns ForumPostInDB|error => {
    id: uuid:createType1AsString(),
    userId,
    title: newForumPost.title,
    description: newForumPost.description,
    postedAt: check time:civilFromString(newForumPost.timestamp)
};

function getPostComment(string postId, NewPostComment newComment) returns PostComment|error => {
    id: uuid:createType1AsString(),
    userId: newComment.userId,
    postId,
    comment: newComment.comment,
    postedAt: check time:civilFromString(newComment.timestamp)
};


function getForumPost(ForumPostInDB forumPostInDB) returns ForumPost|error {
    stream<PostComment, error?> commentStream = forumDbClient->query(`SELECT * FROM comments WHERE post_id = ${forumPostInDB.id} ORDER BY posted_at ASC`);
    PostComment[] comments = check from PostComment comment in commentStream
        select comment;

    ForumPost forumPost = {
        id: forumPostInDB.id,
        userId: forumPostInDB.userId,
        title: forumPostInDB.title,
        description: forumPostInDB.description,
        likes: check forumPostInDB.likes.fromJsonStringWithType(),
        comments: comments,
        postedAt:forumPostInDB.postedAt
    };

    return forumPost;
}
