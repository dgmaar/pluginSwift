var client, pushClient, pushCallback;
var pushService = mx.sicar.pushservice.PushService;
module.exports = {
    conectar:function(host)
    {
        pushClient = mx.sicar.pushservice.PushClient;
        pushCallback = mx.sicar.pushservice.PushCallback;
        console.log("asignado: "+pushService.isClientAssigned());
        if(!pushService.isClientAssigned())
        {
            client = pushClient.connect(host);
            console.log("cliente connectado: "+client);
            pushService.setClient(new pushCallback({
                push:function (notification){
                        client.send(notification);
                    }
                }));
        }
        else
        {
            if(client == null)
            {
                console.log("cliente null");
                client = pushClient.connect(host);
                console.log("cliente connectado: "+client);
                pushService.setClient(new pushCallback({
                    push:function (notification){
                            client.send(notification);
                        }
                    }));
            }
        }
        return client;
    },
    submitAction:function (key, callback)
    {
        pushService.submitAction(key, new mx.sicar.pushservice.APIAction({
            action:callback
        }));
    },
    desconectar:function()
    {
        client.close()
        client = null;
    }
};