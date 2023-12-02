import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/http;
import ballerinax/nats;

type DBConfig record {|
    string host;
    string user;
    string password;
    string database;
    int port;
|};

configurable DBConfig dbConfig = ?;

final mysql:Client forumDBClient = check new (...dbConfig);

type SentimentEPConfig record {|
    string url;
    string refreshUrl;
    string clientId;
    string clientSecret;
    string refreshToken;
|};

configurable SentimentEPConfig sentimentEPConfig = ?;

final http:Client sentimentAPI = check new (sentimentEPConfig.url,
    secureSocket = {
        cert: "resources/server_public.crt",
        'key: {
            certFile: "resources/client_public.crt",
            keyFile: "resources/client_private.key"
        }
    },
    auth = {
        refreshUrl: sentimentEPConfig.refreshUrl,
        clientId: sentimentEPConfig.clientId,
        clientSecret: sentimentEPConfig.clientSecret,
        refreshToken: sentimentEPConfig.refreshToken,
        clientConfig: {
            secureSocket: {
                cert: "resources/sts_server_public.crt"
            }
        }
    },
    retryConfig = {
        interval: 1,
        count: 3,
        statusCodes: [503]
    }
);

final nats:Client natsClient = check new (nats:DEFAULT_URL);
