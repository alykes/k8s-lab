Copy minikube.service into ```/etc/systemd/system```  

Run the following commands:  
```sudo systemctl daemon-reload```  
```sudo systemctl enable minikube```  

Now minikube will start up automatically on a reboot.