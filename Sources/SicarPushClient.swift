//
//  File.swift
//  SocketTest
//
//  Created by Alex on 7/12/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import Foundation
import Dispatch

@objc(SicarPushClient)
public class SicarPushClient:NSObject {
    
    var port: Int32;
    var ip: String;
    var token: String;
    var socket: Socket!;
    var base = [String]();
    var queue: DispatchQueue;
    var continueListener: Bool;
    var thread: Bool;
    var group: DispatchGroup;
    var callback: (PushNotification) -> Void;
    var reconect: Bool;
    var runBackground: Bool;
    
    public override init() {
        NSLog("llamando init() !")
        self.port = 6161;
        self.ip = "127.0.0.1";
        self.socket = nil;
        self.token = "";
        
        base.append("A")
        base.append("B")
        base.append("C")
        base.append("D")
        base.append("E")
        base.append("F")
        base.append("G")
        base.append("H")
        base.append("I")
        base.append("J")
        base.append("K")
        base.append("L")
        base.append("M")
        base.append("N")
        base.append("O")
        base.append("P")
        base.append("Q")
        base.append("R")
        base.append("S")
        base.append("T")
        base.append("U")
        base.append("V")
        base.append("W")
        base.append("X")
        base.append("Y")
        base.append("Z")
        
        base.append("1")
        base.append("2")
        base.append("3")
        base.append("4")
        base.append("5")
        base.append("6")
        base.append("7")
        base.append("8")
        base.append("9")
        base.append("0")
        
        base.append("a")
        base.append("b")
        base.append("c")
        base.append("d")
        base.append("e")
        base.append("f")
        base.append("g")
        base.append("h")
        base.append("i")
        base.append("j")
        base.append("k")
        base.append("l")
        base.append("m")
        base.append("n")
        base.append("o")
        base.append("p")
        base.append("q")
        base.append("r")
        base.append("s")
        base.append("t")
        base.append("u")
        base.append("v")
        base.append("w")
        base.append("x")
        base.append("y")
        base.append("z")
        
        base.append("+")
        base.append("/")
        
        self.queue = DispatchQueue.global(qos: .utility);
        self.thread = false;
        self.continueListener = false;
        self.group = DispatchGroup()
        self.reconect = false;
        self.runBackground = false;
        self.callback = {(push) -> Void in
            
        };
        super.init()
        self.token = generateToken();
        do{
            try self.socket = Socket.create(family: .inet)
        }catch{
            guard error is Socket.Error else {
                print("Fuck...")
                return
            }
        }
        print("Token: "+token)
        
    }
    
    /**
     *
     * Este es la funcion que se usa para asignar el Callback
     * ejemplo en Swift: cliente.setCallback(push: self.show);
     *
     **/
    public func setCallback(push:@escaping (PushNotification) -> Void){
        self.callback = push;
    }
    
    /**
     *
     * Pseudo CSRF Token Base64
     *
     **/
    func generateToken() -> String{
        NSLog("llamando funcion generateToken() !")
        var gen: String = "";
        
        for _ in 1...15{
            let v = Int(arc4random_uniform(UInt32(base.count)))
            gen.append(base[v])
        }
        
        return gen;
    }
    
    
    public func getToken() -> String {
        return self.token;
    }
    
    public func connect(ip: String) -> Bool {
        NSLog("llamando funcion connect() !")
        do{
            print("Conectando a: "+ip)
            
            try self.socket = Socket.create(family: .inet)
            
            try socket.connect(to: ip, port: self.port)
            //try socket.setBlocking(mode: false)
            
            self.ip = ip;
            self.reconect = false;
            
            startQueue()
            
            return true;
        }catch{
            guard error is Socket.Error else{
                return false;
            }
        }
        return false;
    }
    
    
    public func close(){
        continueListener = false;
        thread = false;
        socket.close();
    }
    
    private func send(value: String) -> Bool{
        if(socket != nil && socket.isConnected){
            do{
                
                print("Enviando: "+value)
                try socket.write(from: value);
                
                return true;
            }catch{
                guard error is Socket.Error else{
                    print("Error al enviar mensaje");
                    return false;
                }
            }
        }
        return false;
    }
    
    /**
     *
     * Envia un objeto de PushNotification al cliente.
     *
     **/
    public func send(noti: PushNotification) -> Bool{
        return send(value: noti.getNotification())
    }
    
    public func setOnBackground(run:Bool){
        self.runBackground = run;
    }
    
    public func isOnBackground() -> Bool{
        return self.runBackground;
    }
    
    /**
     *
     * Equivalente de Thread (Java), deberia iniciar solamente una vez, y deberia asignarse runBackground = true
     * cuando la aplicacion esta minimizada o en segundo plano, para evitar cambios inecesarios al UI.
     *
     **/
    private func startQueue(){
        
        if(thread){
            return;
        }
        
        if(!thread){
            
            thread = true;
            
            queue.async {
                self.group.enter();
                
                (DispatchQueue.global(qos: .userInitiated)).async(group: self.group, qos: .userInitiated, flags: .assignCurrentContext, execute: {
                    while(true && self.thread){
                        do{
                            if(self.socket.isConnected && !self.reconect){
                                let result:String? =  try self.readFromServer(self.socket)!
                                
                                if(result == "ZERO_BYTES" || result == "ERROR"){//Para que no tire nil
                                    continue;
                                }
                                
                                print("Server:"+result!)
                                
                                if(result != nil){
                                    let list = PushNotification.getPushNotifications(data: result!)
                                    
                                    for noti in list{
                                        
                                        if(noti.getKey() == "SEND_NUDES"){
                                            let tok:PushNotification = PushNotification(key: "TOKEN", data: self.token)
                                            let result = self.send(noti: tok)
                                            print("Token enviado?: \(result)")
                                        }else{
                                            
                                            print("Enviando al callback "+noti.getNotification())
                                            
                                            if(!self.runBackground){//No hacer las cosas si esta la aplicacion en background
                                                self.callback(noti)
                                            }
                                            
                                        }
                                    }
                                }
                            }else if (self.reconect) {
                                print("Servidor desconectado!")
                                
                                Thread.sleep(forTimeInterval: 5.0)
                                
                                if(self.connect(ip: self.ip)){
                                    print("Conectado")
                                }else{
                                    print("No se pudo conectar")
                                }
                            }
                        }catch{
                            guard error is Socket.Error else{
                                print("Error al leer mensaje");
                                return;
                            }
                        }
                        Thread.sleep(forTimeInterval: 3.0)
                    }
                })
            }
        }
    }
    
    
    /**
     * No regresar nil, por que luego se va todo a la shet.
     *
     **/
    func readFromServer(_ chatSocket : Socket) throws -> String? {
        var readData = Data(capacity: chatSocket.readBufferSize)
        let bytesRead = try chatSocket.read(into: &readData)
        guard bytesRead > 0 else {
            self.reconect = true;
            print("Zero bytes read.")
            return "ZERO_BYTES";
        }
        guard let response = String(data: readData, encoding: .utf8) else {
            print("Error decoding response ...")
            return "ERROR";
        }
        
        return response;
    }
    
}
