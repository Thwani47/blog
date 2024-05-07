+++
title = "Kubernetes on Azure: Part 1 - An Introduction to Kubernetes"
tags = [
    "kubernetes",
    "docker",
    "azure"
]
date = "2024-05-07"
toc = true
+++

In the next series of blog posts, we will be learning about Kubernetes. More specifically, we will be learning how to deploy and manage a Kubernetes cluster on Azure. In this first blog post, we will be going through the basics of Kubernetes, what it is, and why it is used.

# Table of Contents
- [What is Kubernetes?](#what-is-kubernetes)
- [Kubernetes Architecture](#kubernetes-architecture)
- [Conclusion](#conclusion) 

## What is Kubernetes?
Kubernetes, also referred to as K8s (There are 8 letters between K and s) is an open-source container orchestration platform that helps with the automation of deploying, scaling, and managing containerized applications. K8s was developed by Google but is now maintained by the Cloud Native Computing Foundation (CNCF). Kubernetes is used to manage the lifecycle of containerized applications, scaling them up or down, and managing the networking between containers.

Kubernetes offers a set of features that make it an ideal platform for deploying and managing containerized applications. Some of the features include (but are not limited to):
- **Automated rollouts and rollbacks**: K8s seamlessly rolls out and rolls back application updates and config changes, consistently monitoring the app's health to prevent downtime.
- **Self-healing**: Kubernetes automatically restarts containers that fail, replaces and reschedules containers when nodes die, and kills containers that don't respond to user-defined health checks. Kubernetes also prevents traffic from being routed to unhealthy containers.
- **Secret and config management**: Kubernetes allows you to store and manage sensitive information such as passwords, OAuth tokens, and SSH keys. Kubernetes also allows you to deploy and update secrets and application configurations without rebuilding your image.
- **Horizontal scaling**: Kubernetes can scale applications based on CPU usage or other custom metrics. Kubernetes can scale up or down the number of replicas of an application based on the load.

To understand how Kubernetes, we first need to understand the Kubernetes architecture. 

## Kubernetes Architecture
At a high level, a K8s cluster is a cluster of virtual or on-premise machines. Each machine in the cluster is referred to as a **node**. A K8s cluster has two types of nodes:
- One or more **master** or **control plane** nodes. The master node is responsible for managing the K8s cluster. 
- One or more **worker** nodes. Worker nodes are responsible for running the applications and workloads.

![Kubernetes Architecture](/images/k8s_architecture.png)
The control plane runs the components that are responsible for managing the cluster. These components are:
- **API Server (kube-apiserver)**: The API Server is the entry point for all REST commands used to interact with the cluster. The API Server intercepts RESTful calls from users, administrators, and other components, and then validates and processes the requests.
- **Scheduler (kube-scheduler)**: The Scheduler is responsible for distributing workloads across multiple nodes. The Scheduler selects the optimal node for the workload based on predetermined requirements.
- **Controller Manager**: The Controller Manager runs watch-loop processes that are continuously running and comparing the current state of the cluster with the desired state. If the current state does not match the desired state, the Controller Manager takes corrective action to make the current state match the desired state.
    - The **kube-controller-manager** runs controllers that are responsible for acting when nodes become unavailable, ensuring container pod counts are correct, creating endpoints, etc.
    - The **cloud-controller-manager** runs controllers that interact with the underlying cloud provider's API. For example, the cloud controller manager is responsible for creating and deleting load balancers in the cloud provider. 
- **etcd**: This is an open-source distributed key-value data store that is used to store cluster state. The API Server is the only control plane component that can communicate (read and write) with etcd. Any other component that's interested in the cluster state must go through the API Server.

The worker nodes provide a running environment for the applications. The worker nodes run the following components:
- **Kubelet**: The kubelet is an agent that runs on each node in the cluster. The kubelet is responsible for making sure that containers are running in a pod. Each node communicates with the control plane using the kubelet to inform the control plane about any changes in the node.
- **kube-proxy**: The kube-proxy is a network agent that runs on each node, responsible for dynamic updates and maintenance of all network rules on the node. It handles the routing of network traffic in a Kubernetes cluster.
- **Container Runtime**: K8s cannot directly run containers. It needs a container runtime to run the containers on the node where a pod is scheduled. K8s supports container runtimes such as Docker, containerd, CRI-O, etc.

A **pod** is the smallest deployable unit in Kubernetes. A pod is a group of one or more containers that share the same network and storage. Pods are the atomic unit on the Kubernetes platform. Pods are scheduled on worker nodes by the control plane.

## Conclusion

In this blog post, we went through the basics of Kubernetes and the Kubernetes architecture. In the next blog post, we will be going through how to run a local Kubernetes cluster on our machines.