import ballerina/time;
import ballerina/uuid;

function createForumPostInDB(string userId, NewForumPost newForumPost) returns ForumPostInDB|error => {
    title: newForumPost.title,
    description: newForumPost.description,
    postedAt: check time:civilFromString(newForumPost.timestamp),
    likes: "[]",
    id: uuid:createType1AsString(),
    userId: userId
};

function creatPostCommentInDB(string postId, NewPostComment newPostComment) returns PostCommentInDB|error => {
    id: uuid:createType1AsString(),
    comment: newPostComment.comment,
    postedAt: check time:civilFromString(newPostComment.postedAt),
    userId: newPostComment.userId,
    postId: postId
};

function getPostComment(PostCommentInDB postCommentInDB) returns PostComment => {
    id: postCommentInDB.id,
    comment: postCommentInDB.comment,
    postedAt: postCommentInDB.postedAt,
    username: postCommentInDB.name ?: postCommentInDB.userId
};
