var client, pushClient, pushCallback;
var pushService;
module.exports = {
    conectar:function(host)
    {
        if(client != null)
           client.connectWithIp(host);
        return client;
    },
    submitAction:function (key, callback)
    {
        if(client == null)
        {
            client = new Client();
            console.log("Client iOS: "+client);
            client.submitActionWithKey(key, callback);
        }
    },
    desconectar:function()
    {
        client.close();
        client = null;
    }
};