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
}
