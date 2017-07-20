var client, pushClient, pushCallback;
var pushService;
module.exports = {
    newClient:function(host)
    {
        if(client == null)
        {
            client = new SicarPushClient();
            console.log("Cliente: "+client);
        }
        return client;
    },
    submitAction:function (callback)
    {
        
    },
    desconectar:function()
    {
        
    }
};