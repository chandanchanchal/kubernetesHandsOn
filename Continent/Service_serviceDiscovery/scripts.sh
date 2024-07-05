##################################################Services##############################################################################

#Schedule a Kubernetes deployment using a container from Google samples
kubectl create deployment hello-world --image=gcr.io/google-samples/hello-app:1.0
#Scale up the replica set to 4
kubectl scale --replicas=4 deployment/hello-world

kubectl get pods -o wide

#Create a Kubernetes service to expose our service
#Declarative: Yaml
kubectl apply -f hello-world-nodeport.yaml
#Imperative
kubectl expose deployment hello-world --port=8080 --target-port=8080 --type=NodePort 

#Get all deployments in the current name space
kubectl get services -o wide

kubectl exec -it mytest-app-695d74547b-8wcn6 -- sh
    #Execute the service through its ClusterIP 
    curl http://10.96.20.36:8080
    #Execute the service through its DNS name:
    curl http://hello-world-nodeport.default.svc.cluster.local:8080
    exit

#Execute the service throug its NodePort:
curl http://10.0.0.135:30001


#Services without selector
kubectl apply -f hello-world-without-selector.yaml

kubectl get services -o wide

curl http://10.97.130.230:8080

####################################HR Service###################################
kubectl create deployment hr  --image=gcr.io/google-samples/hello-app:1.0 -n test
kubectl expose deployment hr  --port=8080 --target-port=8080 --type=NodePort -n test
kubectl get pods -o wide -n test 
kubectl get services -n test -o wide
curl http://10.0.0.135:30074

kubectl exec -it hr-c98f57d4b-r8bpb -n test -- sh
kubectl delete service hr -n test
kubectl delete deployment hr -n test


#Clean up
kubectl delete deployment hello-world
kubectl delete service hello-world
kubectl delete service hello-world-nodeport
kubectl delete service hello-world-no-selector
#####################################################################Check interfaces########################################################################

ip addr
#Show veth sets
ip link  show type veth
#Show IP-inIP
ip link show type ipip
#Get pods
kubectl get pods -o wide
#Get route to POD with IP: 172.16.94.5 (on Node1)
ip route get



######################################################Service Discovery#######################################################################################################
#Display CoreDNS PODs
kubectl get pods -n kube-system | grep coredns

#Show services in kube-system where CoreDNS resides
kubectl get services -n kube-system

#Check DNS record for our "hello-world-nodeport" service
nslookup hello-world-no-selector.default.svc.cluster.local  10.96.0.10

#Show services in the "test" name space
kubectl get services -n test

#Show DNS record for the "hr" service 
nslookup 10.105.76.144 10.96.0.10

kubectl exec -it mytest-app-695d74547b-8wcn6 -- sh
    
    #Execute the service through its DNS name:
    curl http://hello-world-nodeport.default.svc.cluster.local:8080
    

    #View DNS resolver on this POD
    cat /etc/resolv.conf


    curl http://hello-world-nodeport.default.svc:8080
    curl http://hello-world-nodeport.default:8080
    curl http://hello-world-nodeport:8080
    exit

kubectl exec hello-world-5457b44555-4qrbb -- cat /etc/resolv.conf

kubectl describe deployment coredns -n kube-system

kubectl get service -n kube-system -o wide
	kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   19h   k8s-app=kube-dns

kubectl get service kube-dns -n kube-system
	NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE   SELECTOR
        kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   19h   k8s-app=kube-dns

#10.100.58.104 is the ClusterIP 
nslookup 10.100.58.104 10.96.0.10
	 104.58.100.10.in-addr.arpa      name = hello-world.default.svc.cluster.local

nslookup hello-world.default.svc.cluster.local 10.96.0.10
    Server:         10.96.0.10
    Address:        10.96.0.10#53

    Name:   hello-world.default.svc.cluster.local
    Address: 10.100.58.104

#From inside POD:
curl http://hello-world.default.svc.cluster.local:8080
         Hello, world!
         Version: 1.0.0
         Hostname: hello-world-5457b44555-s5pl8

PODNAME=$(kubectl get pods -o jsonpath='{.items[].metadata.name}')
kubectl exec -it $PODNAME -- env | sort


#Clean up
kubectl delete deployment hello-world
kubectl delete service hello-world
kubectl delete service hello-world-nodeport
kubectl delete service hello-world-no-selector