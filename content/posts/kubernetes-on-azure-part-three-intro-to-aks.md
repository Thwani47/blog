+++
title = "Kubernetes on Azure: Part 3 - An Introduction to AKS"
tags = [
 "kubernetes",
 "docker",
 "azure"
]
date = "2024-06-10"
toc = true
+++

In the [previous](https://thwanisithole.co.za/posts/kubernetes-on-azure-part-two-local-kubernetes-cluster/), we looked at how to set up a local Kubernetes cluster using Docker Desktop. In this post, we will look at how to set up a managed Kubernetes cluster on Azure using Azure Kubernetes Service (AKS) and deploy the [distributed-calculator](https://github.com/Thwani47/distributed-calculator) application.

# Table of Contents
- [What is AKS?](#what-is-aks)
- [Creating and configuring an AKS cluster](#creating-and-configuring-an-aks-cluster)
- [Deploy an application to the AKS cluster](#deploy-an-application-to-the-aks-cluster)
- [AKS Automatic](#aks-automatic)
- [Conclusion](#conclusion)
# What is AKS?
Azure Kubernetes Service (AKS) is a managed Kubernetes service provided by Microsoft Azure. AKS allows us to easily deploy and manage containerized applications. Since AKS is a managed service, it reduces the complexity of managing a Kubernetes cluster. Azure is responsible for managing the overhead that comes with managing a Kubernetes cluster. AKS is an ideal solution for applications that have high availability, scalability, and portability requirements. 

With AKS, the operational overhead of managing a K8s cluster lies with Azure. Azure is responsible for managing the cluster's control plane. Azure is also responsible for managing cluster operations such as health monitoring and maintenance. The AKS control plane is created automatically at no cost to the developer. The developer is only responsible for provisioning and managing the worker nodes where the application workloads run. 

![AKS Architecture](/images/aks_architecture.png)
Azure manages the control plane and exposes the Kubernetes API server so we can interact with the cluster and deploy the application workloads. Each AKS cluster has at least one node, an Azure Virtual Machine (VM) that runs the K8s node components (kube-proxy, kubelet, container-runtime). AKS allows us to group multiple nodes into node pools. Node pools allow us to segregate workloads based on resource requirements. For example, we can have a node pool for CPU-intensive workloads and another node pool for memory-intensive workloads.

# Creating and configuring an AKS cluster
To create an AKS cluster, we can use either the Azure portal, Azure CLI, or ARM templates. In this post, we will use the Azure CLI to create an AKS cluster. Before we can create an AKS cluster, we need to install the Azure CLI and authenticate with Azure. To install the Azure CLI, follow the instructions [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli). To authenticate with Azure, run the following command:

You will need to have an existing Azure subscription to create an AKS cluster. If you do not have an Azure subscription, you can create a free account [here](https://azure.microsoft.com/en-us/free/).

### Login and create a resource group to contain the AKS cluster:

```bash
az login
az group create --name aks-demo-rg --location eastus
```

### Create an AKS cluster:
We create an AKS cluster with three nodes
```bash
az aks create --resource-group aks-demo-rg --name aksDemoCluster --node-count 3 --generate-ssh-keys
```

### Connect to the AKS cluster:
We need to configure `kubectl` to connect to our AKS cluster
```bash
az aks get-credentials --resource-group aks-demo-rg --name aksDemoCluster
# Merged "aksDemoCluster" as current context in <poth-to-kubeconfig>
```

### Verify the connection to the AKS cluster:
We can verify the connection to the AKS cluster by running the following command:
```bash
kubectl get nodes
# NAME                                STATUS   ROLES   AGE   VERSION
# aks-nodepool1-32415939-vmss000000   Ready    agent   13m   v1.28.9
# aks-nodepool1-32415939-vmss000001   Ready    agent   13m   v1.28.9
# aks-nodepool1-32415939-vmss000002   Ready    agent   58s   v1.28.9
```

# Deploy an application to the AKS cluster:
We can deploy the distributed calculator application to the AKS cluster by running the following command:

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

We can run `kubectl get all` to view all the resources that have been created
```bash
kubectl get all
# NAME                                               READY   STATUS    RESTARTS      AGE
# pod/calculator-deployment-95956bf4c-rvjhj          1/1     Running   1 (37s ago)   7m7s
# pod/csharp-adder-deployment-79b878dc45-kbqns       1/1     Running   0             7m18s
# pod/flask-multiplier-deployment-67566f5985-dlrph   1/1     Running   0             7m13s
# pod/go-subtractor-deployment-7856c959f7-pz7kr      1/1     Running   0             7m27s
# pod/nestjs-divider-deployment-7b54767779-9hlq7     1/1     Running   0             8m7s

# NAME                         TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)          AGE
# service/calculator-service   LoadBalancer   10.0.153.154   48.216.153.102   3000:31252/TCP   7m8s
# service/csharp-adder         ClusterIP      10.0.131.41    <none>           8080/TCP         7m18s
# service/flask-multiplier     ClusterIP      10.0.246.199   <none>           5000/TCP         7m13s
# service/go-subtractor        ClusterIP      10.0.46.207    <none>           8000/TCP         7m28s
# service/nestjs-divider       ClusterIP      10.0.4.218     <none>           3000/TCP         8m8s

# NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
# deployment.apps/calculator-deployment         1/1     1            1           7m8s
# deployment.apps/csharp-adder-deployment       1/1     1            1           7m19s
# deployment.apps/flask-multiplier-deployment   1/1     1            1           7m14s
# deployment.apps/go-subtractor-deployment      1/1     1            1           7m28s
# deployment.apps/nestjs-divider-deployment     1/1     1            1           8m8s

# NAME                                                     DESIRED   CURRENT   READY   AGE
# replicaset.apps/calculator-deployment-95956bf4c          1         1         1       7m8s
# replicaset.apps/csharp-adder-deployment-79b878dc45       1         1         1       7m19s
# replicaset.apps/flask-multiplier-deployment-67566f5985   1         1         1       7m14s
# replicaset.apps/go-subtractor-deployment-7856c959f7      1         1         1       7m28s
# replicaset.apps/nestjs-divider-deployment-7b54767779     1         1         1       8m8s
```

We can open the browser to `<CALCULATOR-SERVICE-EXTERNAL-IP>:3000` to access our application. We should be able to see the calculator app and be able to interact with it.

Now that we have deployed the application, we can perform actions such as scaling our application, either by adding more instances of the application or adding more nodes to the cluster. We can increase the number of instances of the calculator UI by running the following command:

```bash
kubectl scale deployment calculator-deployment --replicas=3
# deployment.apps/calculator-deployment scaled
```

We can verify that the number of instances has been increased by running `kubectl get pods,deploy --selector app=calculator`:
```bash
kubectl get pods,deploy --selector app=calculator

# NAME                                        READY   STATUS    RESTARTS      AGE
# pod/calculator-deployment-95956bf4c-mqct7   1/1     Running   0             87s
# pod/calculator-deployment-95956bf4c-p2q8g   1/1     Running   0             87s
# pod/calculator-deployment-95956bf4c-rvjhj   1/1     Running   1 (15m ago)   21m

# NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
# deployment.apps/calculator-deployment   3/3     3            3           21m
```

We can add more nodes by running 
```bash
az aks scale --resource-group aks-demo-rg --name aksDemoCluster --node-count 5
kubectl get nodes
# NAME                                STATUS   ROLES   AGE   VERSION
# aks-nodepool1-32415939-vmss000000   Ready    agent   34m   v1.28.9
# aks-nodepool1-32415939-vmss000001   Ready    agent   34m   v1.28.9
# aks-nodepool1-32415939-vmss000002   Ready    agent   21m   v1.28.9
# aks-nodepool1-32415939-vmss000003   Ready    agent   28s   v1.28.9
# aks-nodepool1-32415939-vmss000004   Ready    agent   35s   v1.28.9
```

Delete the resource group to avoid incurring costs.
```bash
az group delete --name aks-demo-rg --yes
```

# AKS Automatic
In May this year, Microsoft introduced Azure Kubernetes Service (AKS) Automatic, which offers a more simplified Kubernetes experience for developers. With AKS Automatic, Azure takes care of the cluster setup, node management, scaling, and security, and offers preconfigured settings that follow the AKS well-architected best practices. AKS Automatic provides developers easy access to production-ready clusters, which allows them to focus on building their applications, and run them on Kubernetes with ease.

AKS Automatic comes with pre-configured features such as:
- a managed Prometheus service for metric collection
- a managed Grafana service for visualization
- a managed Container Insights service for collection
- automatic node management. AKS Automatic automatically scales the number of nodes based on the application's resource requirements.
- Azure RBAC for cluster access control,

and many more features. 

At the time of writing, AKS Automatic is currently in preview and is not generally available. 


# Conclusion
In this post, we looked at how to create an AKS cluster using the Azure CLI and deploy the application to our cluster. We also looked at how to scale the application and the cluster. We also looked at AKS Automatic, a new feature that simplifies the Kubernetes experience for developers. AKS Automatic provides a production-ready Kubernetes cluster with pre-configured settings that follow the AKS well-architected best practices. 
