+++
title = "An Introduction to Cloud Computing"
tags = [
    "azure",
    "cloud-computing"
]
date = "2024-02-21"
toc = true
+++

In the last few years, cloud computing has become a popular choice for many organizations. It offers a wide range of benefits, including cost savings, scalability, and flexibility. In the next series of articles, we'll learn more about cloud computing and take a deep dive into the different services offered by cloud providers, focusing primarily on Microsoft Azure. 

 In this article, we'll define what cloud computing is and discuss the different types of cloud services available. We'll also explore the benefits of cloud computing and the different deployment models.

 # Table of Contents
- [What is Cloud Computing?](#what-is-cloud-computing)
- [Benefits of Cloud Computing](#benefits-of-cloud-computing)
- [Deployment Models](#cloud-models)
- [Types of Cloud Services](#types-of-cloud-services)

 ## What is Cloud Computing?
 **Cloud computing** is a way to deliver computing services over the internet. Cloud computing allows organizations to access computing resources such as servers, storage, databases, networking, software, and analytics over the internet. These resources are hosted in data centers that are managed by cloud providers. A cloud provider is a company that offers cloud services to businesses and individuals. Some of the popular cloud providers include Microsoft Azure, Amazon Web Services (AWS), and Google Cloud Platform (GCP). Simply put, cloud computing is a way to rent computing resources from someone else's data center. When you are done utilizing the resources, you give them back. Customers use cloud computing resources on a **pay-as-you-go** basis. This means that customers only pay for the resources they use.

 Building and hosting our applications on the cloud comes with a lot of benefits. Some of these benefits are listed below

 ## Benefits of Cloud Computing
 ### <u>Cost Savings</u>
When organizations think of their IT infrastructure models, they usually consider two types of expenditures:
- **Capital Expenditure (CapEx)**: This is the upfront cost to purchase resources such as servers, storage, and networking. CapEx forces the organization to make future estimations of their infrastructure needs at the beginning. 
    - If the organization overestimates, they end up with unused resources, which is a waste of money.
    - If the organization underestimates, they end up with insufficient resources, which can lead to poor performance and unhappy customers.
- **Operational Expenditure (OpEx)**: This is the ongoing cost to run and maintain the infrastructure. 

Since cloud computing allows customers to use resources on a pay-as-you-go basis, it eliminates the need for CapEx. This means that organizations can avoid the upfront cost of purchasing hardware and software. Instead, they can pay for what they use and scale up or down as needed. This results in cost savings for the organization. Organizations also don't have to pay for the physical instruction, the electricity, and the cooling required to run the infrastructure.

 ### <u>Uptime (Availability)</u>
 Availability refers to organizations' services and products being available to customers they they need them.

Cloud providers offer **Service Level Agreements (SLAs)** that guarantee a certain level of uptime. This means that the cloud provider guarantees that the services will be available for a certain percentage of time. For example, a cloud provider might offer an SLA that guarantees 99.9% uptime. This means that the services will be available 99.9% of the time. This is a huge benefit for organizations that need their services to be available 24/7. Azure is a highly available cloud platform with availability guarantees for most of its services.

 ### <u>Scalability</u>
Scalability refers to the ability to adjust computing resources to meet demand. When the demand is high, the organization can add more computing power or more resources to meet demand, and when the demand is low, the organization can scale down to save costs. Cloud computing allows organizations to scale both vertically and horizontally.
- **Vertical Scaling**: This refers to adding more resources to a single server. For example, adding more RAM, CPU, or storage to a single server (**Scaling up**), or removing excess resources from a single server (**Scaling down**).
- **Horizontal Scaling**: This refers to adding more servers to the infrastructure (**Scaling out**), or removing unutilised servers from the infrastructure (**Scaling in**).

 ### <u>Reliability</u>
Reliability refers to the ability of the cloud provider to deliver the services as promised. Cloud providers have multiple data centers in different geographical locations. This means that if one data center goes down, the services can be moved to another data center. This ensures that the services are always available. Organizations have the confidence that their services can recover from failures and continue being available to their customers

Organizations have the choice of setting up their infrastructure using different cloud models. These models can be chosen based on the organization's business needs. The main cloud models are listed below.

# Cloud Models
| <div style="width:200px">Deployment Model</div> | Functionality |
|------------------|----------------|
| Private Cloud | A private cloud is a cloud that is used by a single organization.<br/><br/> Private clouds can either be hosted in the organization's data center, an offsite data center, or via a 3rd party cloud provider|
| Public Cloud | A public cloud is built, controlled, and maintained by a 3rd party cloud provider. The cloud provider can offer resources such as servers, storage, and networking to multiple organizations.|
| Hybrid Cloud| A hybrid cloud is a computing environment that uses both public and private clouds. <br/><br/>A hybrid cloud can be used to supplement a private cloud with public cloud resources when demand increases. It can also be used to add a security layer over a private cloud.|
| Multi-Cloud | A multi-cloud is a cloud environment that uses multiple cloud providers. You can have a computing environment in which you use AWS resources and Azure resources. <br/><br/>This can be used to avoid vendor lock-in and to take advantage of the best features of different cloud providers.|

When organizations are setting up their services on the cloud, they can also choose the type of cloud resources they want to use. The main cloud resources are listed below.

# Types of Cloud Services
| <div style="width:200px">Cloud Service</div> | Functionality |
|------------------|----------------|
| Infrastructure as a Service (IaaS) | IaaS provides virtualized computing resources over the internet. Organizations can rent out a wide range of services such as virtual machines, storage, and networking|
| Platform as a Service (PaaS) | PaaS provides a platform that allows customers to develop, run, and manage applications without the complexity of building and maintaining the infrastructure.|
| Software as a Service (SaaS) | SaaS provides software applications over the internet. Customers can access the software applications via a web browser or an app|

As organizations continue to move their services to the cloud, it is crucial to understand the **shared responsibility model**. The shared responsibility model dictates that the cloud service provider is responsible for monitoring and responding to security threats to the cloud infrastructure, while the customer is responsible for securing the data and applications that they host on the cloud. This means that the customer is responsible for securing their data and applications, while the cloud provider is responsible for securing the infrastructure that the data and applications are hosted on.

The cloud service provider is responsible for the physical power, cooling, and network connectivity of the data center. The customer does not have physical access to the data center, so it would not make sense to have the customer responsible for that. 

The customer is always responsible for the data and information that is stored in the cloud. The customer is also responsible for the accounts and identities of the people, services, and devices that have access to the data.

In the next article, we'll dive deeper into Azure reliability and learn about the different Azure regions and how to leverage availability zones to make our services highly available.
