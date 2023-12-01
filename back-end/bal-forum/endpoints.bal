import ballerina/http;
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

type SentimentEPConfig record {|
    string url;
|};

configurable SentimentEPConfig sentimentEPConfig = ?;

final http:Client sentimentAPI = check new (sentimentEPConfig.url,
    secureSocket = {
        cert: "resources/server_public.crt"
    }
);
