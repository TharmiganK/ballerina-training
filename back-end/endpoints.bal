import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerinax/nats;

type DatabaseConfig record {|
    string host;
    string user;
    string password;
    string database;
    int port;
|};

configurable DatabaseConfig dbConfig = ?;

final mysql:Client forumDbClient = check new (...dbConfig);

final nats:Client natsClient = check new (url = nats:DEFAULT_URL);

