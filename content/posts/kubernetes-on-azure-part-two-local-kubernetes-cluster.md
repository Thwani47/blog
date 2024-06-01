+++
title = "Kubernetes on Azure: Part 2 - Running a local Kubernetes cluster"
tags = [
 "kubernetes",
 "docker",
 "azure"
]
date = "2024-06-01"
toc = true
+++

In the [previous](https://thwanisithole.co.za/posts/kubernetes-on-azure-part-one-intro-to-kubernetes/) blog post, we went through the basics of Kubernetes and the Kubernetes architecture. In this blog post, we will explore how to run a local Kubernetes cluster on our machines.

# Table of Contents
- [Installing Kubernetes](#installing-kubernetes)
- [Deploying a Pod](#deploying-a-pod)
- [Replication Controllers and ReplicaSets](#replication-controllers-and-replicasets)
- [Creating a Deployment](#creating-a-deployment)
- [Creating a Service](#creating-a-service)
- [Conclusion](#conclusion)

## Installing Kubernetes
The easiest way to run a Kubernetes cluster is to install [Docker Desktop](https://docs.docker.com/desktop/) and enable Kubernetes. On Docker Desktop, we can enable Kubernetes by going to the Docker Desktop settings, clicking on the Kubernetes tab on the left side, and checking the box to enable Kubernetes. Click on the Apply & Restart button to apply the changes.

Another way to run a Kubernetes cluster is to use [Minikube](https://minikube.sigs.k8s.io/docs/start/). Minikube is a tool that allows you to run a single-node Kubernetes cluster on your local machine. Minikube can be installed on Windows, macOS, and Linux. To install Minikube, follow the instructions [here](https://minikube.sigs.k8s.io/docs/start/). In this blog post, we will be using Docker Desktop to run our Kubernetes cluster.

*On Windows and macOS, Docker Desktop comes with `kubectl`, a command-line tool we use to interact with the Kubernetes cluster. If you prefer installing `kubectl` on your own, tnstructions on how to do that can be found [here](https://kubernetes.io/docs/tasks/tools/).*

To verify that Kubernetes is running, we can run the following command:
```bash
kubectl cluster-info
```
This command will display the address of the Kubernetes control plane. The output should look something like this:
```bash
# Kubernetes control plane is running at https://kubernetes.docker.internal:6443
# CoreDNS is running at https://kubernetes.docker.internal:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

# To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```
When running Kubernetes locally, the cluster is run on a single node, which means the control (master) node and worker node are the same.

Let's see how we can deploy resources to our cluster. I have created a simple distributed calculator app that we will use to deploy resources to our Kubernetes cluster. The calculator app consists of the following components:
- **calculator** - A React application which is the front end of the app.
- **go-subtractor** - A Golang API that exposes an endpoint to subtract 2 numbers
- **csharp-adder** - A .NET API that exposes an endpoint to add 2 numbers
- **python-multiplier** - A Flask API that exposes an endpoint to multiply 2 numbers
- **nestjs-divider** - A NestJS API that exposes an endpoint to divide 2 numbers

The source code for the calculator app can be found [here](https://github.com/Thwani47/distributed-calculator).

## Deploying a Pod
In the previous post, we mentioned that Kubernetes **Pods** are the smallest unit of deployment. Kubernetes does not run containers directly, but groups one (or more) containers into a single atomic unit called a Pod. We can run a Pod in Kubernetes using the `kubectl run` command. The below command runs the `calculator` image in a Pod
```bash
kubectl run calculator --image=ghcr.io/thwani47/calculator:v1
# pod/calculator created
```
We can check that our Pod is running by using the `kubectl get` command as follows
```bash
kubectl get pods
# NAME         READY   STATUS             RESTARTS      AGE
# calculator   0/1     CrashLoopBackOff   3 (25s ago)   62s
```
*The status of the Pod is CrashLoopBack because the **calculator** container needs the other containers to be running for it to work correctly, so it will keep on crashing. We'll fix that a bit later*😀

We can also use `kubectl describe` to get more information about the Pod such as the image used, the status, and the events that have occurred
```bash
kubectl describe pod calculator
# Name:             calculator
# Namespace:        default
# Priority:         0
# Service Account:  default
# Node:             docker-desktop/192.168.65.3
# Start Time:       Sat, 01 Jun 2024 11:23:21 +0200
# Labels:           run=calculator
# Annotations:      <none>
# Status:           Running
# IP:               10.1.0.126
# ... other information
```

we can get the logs of the Pod using the `kubectl logs` command
```bash
kubectl logs calculator
# ... other logs
# 2024/05/31 20:06:44 [emerg] 1#1: host not found in upstream "csharp-adder" in /etc/nginx/conf.d/default.conf:10
# nginx: [emerg] host not found in upstream "csharp-adder" in /etc/nginx/conf.d/default.conf:10
```
We can delete our Pod using the `kubectl delete` command
```bash
kubectl delete pod calculator
# pod "calculator" deleted
```

We can also make use of **manifest** files, which are either JSON or YAML files, which allow us to use a declarative approach instead of the imperative approach we used above to deploy resources to our cluster. Below is an example of a manifest file that deploys the `calculator` Pod
```yaml
# calculator-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: calculator
  labels:
    app: calculator
spec:
  containers:
  - name: calculator
    image: ghcr.io/thwani47/calculator:v1
```

We can deploy the Pod using the `kubectl apply` command
```bash
kubectl apply -f calculator-pod.yaml
# pod/calculator created
```
We can use the commands we used above to check the status of the Pod, get the logs, and delete the Pod. 

In most cases, we will want to have multiple Pods running in our cluster, and we would like the assurance that the desired number of Pods are running at all times and if a Pod was to crash, it would be restarted. This is where **Replication Controllers** and **ReplicaSets** come in. 

## Replication Controllers and ReplicaSets
Controllers are the brains behind Kubernetes. They are responsible for ensuring that the desired state of the cluster matches the actual state. Controllers are responsible for creating, updating, and deleting resources in the cluster. The `Replication Controller` helps us run multiple Pods and ensures that the desired number of Pods are running at all times. The `Replication Controller` is an old technology which is being replaced by `ReplicaSets`. We can define a `ReplicationControler` for our calculator Pod as follows
```yaml
# calculator-replication-controller.yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: calculator-replication-controller
  labels:
    app: calculator
spec:
  replicas: 2 # the number of Pods we want to be always running
  template:
    metadata:
      labels:
        app: calculator
    spec:
      containers:
      - name: calculator
        image: ghcr.io/thwani47/calculator:v1
```
_We add the Pod definition in the `template` section of the Replication Controller. The `replicas` field specifies the number of Pods we want to be running at all times. In this case, we want 2 Pods of the calculator app running at all times._
We can deploy the `ReplicationController` using the `kubectl apply` command
```bash
kubectl apply -f calculator-replication-controller.yaml
# replicationcontroller/calculator-replication-controller created
```

We can check the status of the Replication Controller using the `kubectl get` command
```bash
kubectl get replicationcontroller
# NAME                                DESIRED   CURRENT   READY   AGE
# calculator-replication-controller   2         2         0       41s
```

We can also view the Pods that are running using the `kubectl get` command
```bash
kubectl get pods
# NAME                                      READY   STATUS             RESTARTS      AGE
# calculator-replication-controller-7n9fw   0/1     CrashLoopBackOff   4 (30s ago)   113s
# calculator-replication-controller-z4gbj   0/1     CrashLoopBackOff   4 (17s ago)   113s
```

The Pods controlled by a `ReplicationController` are named using the format: `<controller-name>-<random-string>`.

We can delete one Pod and a new Pod will be created to replace it
```bash
kubectl delete pod calculator-replication-controller-7n9fw
```

If we run the `kubectl get pods` command, we will see that a new Pod has been created to replace the one we deleted.
```bash
kubectl get pods
# NAME                                      READY   STATUS             RESTARTS      AGE
# calculator-replication-controller-76hpd   0/1     CrashLoopBackOff   2 (18s ago)   35s
# calculator-replication-controller-z4gbj   0/1     CrashLoopBackOff   5 (74s ago)   4m12s
```

We can also use `ReplicaSets` to manage Pods. `ReplicaSets` are the next generation of `ReplicationControllers`. `ReplicaSets` are more powerful and flexible than `ReplicationControllers`. We can define a `ReplicaSet` for our calculator Pod as follows
```yaml
# calculator-replicaset.yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: calculator-replicaset
  labels:
    app: calculator
spec:
    replicas: 2
    selector:
        matchLabels:
            app: calculator
    template:
        metadata:
            labels:
                app: calculator
        spec:
            containers:
            - name: calculator
              image: ghcr.io/thwani47/calculator:v1
```
The `selector` field helps the ReplicaSet identify the Pods that fall under it. It is a required field for the ReplicaSet but not for the Replication Controller. The ReplicaSet can also manage Pods that were created outside of it. 

We can deploy the `ReplicaSet` using the `kubectl apply` command
```bash
kubectl apply -f calculator-replicaset.yaml
# replicaset.apps/calculator-replicaset created
```
We can check the status of the ReplicaSet using the `kubectl get` command
```bash
kubectl get replicaset
# NAME                    DESIRED   CURRENT   READY   AGE
# calculator-replicaset   2         2         0       22s
```

We can also view the Pods that are running using the `kubectl get` command
```bash
kubectl get pods
# NAME                                          READY   STATUS             RESTARTS       AGE
# pod/calculator-replicaset-d4p57               0/1     CrashLoopBackOff   3 (20s ago)    61s
# pod/calculator-replicaset-x2wkb               0/1     CrashLoopBackOff   3 (20s ago)    61s
```

Kubernetes `Deployments` allow us to upgrade our application instances, roll back to a previous version, and scale our application instances. Deployments are the recommended way to manage Pods and ReplicaSets. In the next section, we will go through how to create a Deployment for our calculator.

## Creating a Deployment
A `Deployment` is a higher-level abstraction that manages ReplicaSets and Pods. Deployments allow us to define the desired state of our application and Kubernetes will ensure that the actual state matches the desired state. We can define a Deployment for our calculator Pod as follows
```yaml
# calculator-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: calculator-deployment
  labels:
    app: calculator
spec:
    replicas: 2
    selector:
        matchLabels:
          app: calculator
    template:
        metadata:
          labels:
            app: calculator
        spec:
          containers:
          - name: calculator
            image: ghcr.io/thwani47/calculator:v1
```
A Deployment automatically creates a ReplicaSet. It also creates a rollout history that allows us to roll back to a previous version of the application. We can deploy the Deployment using the `kubectl apply` command
```bash
kubectl apply -f calculator-deployment.yaml
# deployment.apps/calculator-deployment created
```

We can run `kubectl get all` to get all the resources that have been created
```bash
kubectl get all
# NAME                                         READY   STATUS   RESTARTS      AGE
# pod/calculator-deployment-6c6cbff8bb-tp4f6   0/1     Error    3 (28s ago)   44s
# pod/calculator-deployment-6c6cbff8bb-tqcfd   0/1     Error    3 (30s ago)   44s

# NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
# deployment.apps/calculator-deployment   0/2     2            0           44s

# NAME                                               DESIRED   CURRENT   READY   AGE
# replicaset.apps/calculator-deployment-6c6cbff8bb   2         2         0       44s
```
This created a Deployment, a ReplicaSet, and 2 Pods. We can check the status of the Deployment using the `kubectl get` command
```bash
kubectl get deployment calculator-deployment
```

We can also check the rollout history using the `kubectl rollout` command
```bash
kubectl rollout history deployment calculator-deployment
# REVISION  CHANGE-CAUSE
# 1         <none>
```

In Kubernetes, each Pod gets its own IP internal IP address. A Kubernetes cluster has its network with an address range, and the Pods are assigned IP addresses within this range. Pods can communicate with each other using these IP addresses. The only downside is that Pods are very volatile and can be created and destroyed at any time. This means that the IP address of a Pod can change at any time. To solve this problem, Kubernetes has a concept called `Services`. Services provide a stable IP address and DNS name for a set of Pods. In the next section, we will go through how to create a Service for our calculator app.

## Creating a Service
A `Service` is an abstraction that defines a logical set of Pods and a policy by which to access them. Services allow us to expose our application to the outside world. Kubernetes allows us to create 3 types of Services:
- **ClusterIP**: This is the default type of Service. It exposes the Service on a cluster-internal IP. This means that the Service is only accessible within the cluster. This Service spans across all the Pods assigned to it.
- **NodePort**: This type of Service exposes the Service on each Node's IP address at a static port. This means that the Service is accessible from outside the cluster using the Node's IP address and the NodePort. This Service spans across multiple nodes in the setting of a multi-node cluster.
- **LoadBalancer**: This type of Service exposes the Service externally using a cloud provider's load balancer. This Service creates a load balancer that can distribute traffic to the Pods assigned to it.

We can define a Service for our calculator app as follows
```yaml
# calculator-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: calculator-service
  labels:
    app: calculator
spec:
    selector:
        app: calculator
    ports:
    - protocol: TCP
      port: 3000 # the port the Service will be exposed on
      targetPort: 80 # the port the Service will forward traffic to on the Pods
    type: LoadBalancer
```
We create a `LoadBalancer` Service because we want to expose our calculator app to the outside world. The Service will be exposed on port `3000` and will forward traffic to port `80` of the Pods. We can deploy the Service using the `kubectl apply` command

```bash
kubectl apply -f calculator-service.yaml
# service/calculator-service created
```
We can check the status of the Service using the `kubectl get` command
```bash
kubectl get service
# NAME                         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
# service/calculator-service   LoadBalancer   10.107.255.80   localhost     3000:32092/TCP   4s
```
The Service has been created and is accessible on `localhost:3000`. We can access the calculator app by navigating to `localhost:3000` in our browser.

Now that we have covered the major Kubernetes objects we need to run our calculator app, let us run the whole thing to see it in action. In the [application source code](https://github.com/Thwani47/distributed-calculator), we have a `manifests` folder, which contains YAML files with the definitions of the Deployments and Services of the distributed calculator app. The manifest files define ClusterIP Services for the APIs and a LoadBalancer Service for the calculator app.

We can run the distributed calculator app using the following commands
```bash
kubectl apply -f https://raw.githubusercontent.com/Thwani47/distributed-calculator/master/src/manifests/nestjs-divider-deployment.yaml
# deployment.apps/nestjs-divider-deployment created
# service/nestjs-divider created

kubectl apply -f https://raw.githubusercontent.com/Thwani47/distributed-calculator/master/src/manifests/go-subtractor-deployment.yaml
# deployment.apps/go-subtractor-deployment created
# service/go-subtractor created

kubectl apply -f https://raw.githubusercontent.com/Thwani47/distributed-calculator/master/src/manifests/csharp-adder-deployment.yaml
# deployment.apps/csharp-adder-deployment created
# service/csharp-adder created

kubectl apply -f https://raw.githubusercontent.com/Thwani47/distributed-calculator/master/src/manifests/flask-multiplier-deployment.yaml
# deployment.apps/flask-multiplier-deployment created
# service/flask-multiplier created

kubectl apply -f https://raw.githubusercontent.com/Thwani47/distributed-calculator/master/src/manifests/calculator-deployment.yaml
# deployment.apps/calculator-deployment created
# service/calculator-service created
```
Now if we run `kubectl get all`, we will see all the resources that have been created.
```bash
kubectl get all
# NAME                                               READY   STATUS    RESTARTS   AGE
# pod/calculator-deployment-6dfddc9c56-rmsk4         1/1     Running   0          101s
# pod/csharp-adder-deployment-5945454df8-fhmf8       1/1     Running   0          2m25s
# pod/flask-multiplier-deployment-756d96c7fd-5b9sx   1/1     Running   0          2m4s
# pod/go-subtractor-deployment-5ff5d997db-cvvvt      1/1     Running   0          2m41s
# pod/nestjs-divider-deployment-c8dd85b56-bcqqc      1/1     Running   0          3m14s

# NAME                         TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
# services/calculator-service   LoadBalancer   10.109.13.40     localhost     3000:32277/TCP   101s
# services/csharp-adder         ClusterIP      10.99.71.195     <none>        8080/TCP         2m25s
# services/flask-multiplier     ClusterIP      10.111.134.130   <none>        5000/TCP         2m4s
# services/go-subtractor        ClusterIP      10.109.25.228    <none>        8000/TCP         2m41s
# services/nestjs-divider       ClusterIP      10.97.164.61     <none>        3000/TCP         3m14s

# NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
# deployment.apps/calculator-deployment         1/1     1            1           101s
# deployment.apps/csharp-adder-deployment       1/1     1            1           2m25s
# deployment.apps/flask-multiplier-deployment   1/1     1            1           2m4s
# deployment.apps/go-subtractor-deployment      1/1     1            1           2m41s
# deployment.apps/nestjs-divider-deployment     1/1     1            1           3m14s

# NAME                                                     DESIRED   CURRENT   READY   AGE
# replciaset.apps/calculator-deployment-6dfddc9c56         1         1         1       101s
# replciaset.apps/csharp-adder-deployment-5945454df8       1         1         1       2m25s
# replciaset.apps/flask-multiplier-deployment-756d96c7fd   1         1         1       2m4s
# replciaset.apps/go-subtractor-deployment-5ff5d997db      1         1         1       2m41s
# replciaset.apps/nestjs-divider-deployment-c8dd85b56      1         1         1       3m14s
``` 
We can see that our `calculator-service` is the only service that has an `EXTERNAL-IP`, which is `localhost` in this case. We can access the calculator app by navigating to `localhost:3000` in our browser and we should see the calculator app running:
![Calculator](/images/calculator-ui.png)

# Conclusion
In this blog post, we covered how to run a local Kubernetes cluster on our machines. We went through how to deploy Pods, Replication Controllers, ReplicaSets, Deployments, and Services. We also ran a distributed calculator app on our local Kubernetes cluster. In the next blog post, we will be going through how to deploy the calculator app on an Azure Kubernetes cluster using the Azure Kubernetes Service (AKS).