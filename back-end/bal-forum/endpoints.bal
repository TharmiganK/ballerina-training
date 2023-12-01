import ballerinax/mysql;
import ballerinax/mysql.driver as _;

type DatabaseConfig record {|
    string host;
    string user;
    string password;
    string database;
    int port;
|};

configurable DatabaseConfig dbConfig = ?;

final mysql:Client forumDbClient = check new (...dbConfig);
