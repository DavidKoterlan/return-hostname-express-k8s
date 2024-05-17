# Return Hostname Express K8S Application

This project is the Kubernetes extension of the [Return Hostname Express Application](https://github.com/DavidKoterlan/return-hostname-express). The application is designed to create a cluster environment in AWS, deploy multiple instances of the application and expose them with a load balancer.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation and Usage](#installation-and-usage)

## Features
- Creates an EKS cluster.
- Creates a namespace for the application.
- Deploys the application with three replicas.
- Exposes the application instances using a LoadBalancer service.

## Prerequisites
- [eksctl](https://eksctl.io/installation/) installed and AWS configured with appropriate permissions.
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- Bash shell environment.

## Installation and Usage

1. Clone the repository to your local machine:
    ```bash
    git clone https://github.com/DavidKoterlan/return-hostname-express-k8s.git
    cd return-hostname-express-k8s
    ```

2. Create the EKS cluster:
    ```bash
    eksctl create cluster -f aws-cluster.yaml
    ```
    This command will create an EKS cluster named `return-hostname-cluster` in the `eu-central-1` region with a custom cidr range: `10.0.0.0/16`. The cluster will contain one nodegroup of `t2.medium EC2 instances`. The process can take up some minutes.

3. Deploy the application:
    ```bash
    kubectl apply -f return-hostname-app.yaml
    ```
    With this command kubectl will apply the return-hostname-app.yaml file. The manifest contains 3 resources:
    - A namespace
    - A deployment for the application which manages 3 replicas. The pods in the deployment use a [public image from Dockerhub](https://hub.docker.com/r/dkoterlan/return-hostname-express) to run their container.
    - A service to expose the applications with a load balancer. In the background AWS will create a load balancer and the applications will be reachable from one single DNS.

4. Test the application:
    The repository includes a simple bash script named test-load-balancer.bash. This script retrieves the DNS hostname of the load balancer service and uses the curl command to query it. The purpose of this test is to retrieve the hostname of a pod where the application is running

    Make the test script executeable with the following command:
    ```bash
    chmod +x test-load-balancer.bash
    ```

    Execute the test-load-balancer.bash file some times:
    ```bash
    ./test-load-balancer.bash
    ```

    Output example: 
    ```bash
    Hostname: return-hostname-deployment-7498235f9c-27pvm
    ```
    After some execution you should see the load balancer forwards the requests to different pods in the cluster. If any of the pods cease to exists the load balancer can handle the problem by forwarding the request to the other pods. (While the deployment starts a new pod in the place of the terminated pod)

5. Clean up the resources:
    ```bash
    eksctl scale nodegroup --cluster=return-hostname-cluster --name=ng-1 --nodes=0
    eksctl delete cluster --name=return-hostname-cluster
    ```
    NOTE: always clean up resources after testing because avoiding it can lead to additional costs.
