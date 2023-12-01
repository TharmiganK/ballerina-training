import ballerina/http;

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

type UserNotFound record {|
    *http:NotFound;
    ErrorResponse body;
|};

type UserConflict record {|
    *http:Conflict;
    ErrorResponse body;
|};
