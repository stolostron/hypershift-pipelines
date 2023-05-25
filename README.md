# HyperShift Pipelines

## About

This repo is a contains a set of Pipelines and their associated Tasks to deploy ACM, enable HyperShift, and deploy a Hosted Cluster.
Their are 2 main Pipelines contained in this repo, one which functions in the Upstream (todo), and another in the Downstream.

## Prereqs

The following prereqs are required: 

1. A ClusterPool in the same namespace of the Pipelines. See [clusterpool.yaml](./prereqs/clusterpool.yaml) for an example. It is recommended to have a size of at least 2. The recommended OCP version is 4.12.14+
2. The following secrets must be defined in the same namespace of the Pipelines. See [secrets_template.yaml](./prereqs/secrets_template.yaml)
3. An OCP Cluster (4.8+ recommended) with the following Operators Installed - 
    * OpenShift Pipelines
    * Advanced Cluster Management (2.4+ recommended)


## How to deploy

Make sure you're logged into the cluster that hosts the clusterpool.

Clone and move into the `hypershift-pipelines` directory
```
git clone git@github.com:stolostron/hypershift-pipelines.git
cd hypershift-pipelines
```

Make sure you have [oc](https://docs.openshift.com/container-platform/4.12/cli_reference/openshift_cli/getting-started-cli.html) installed. Then to deploy the Pipelines run - 

```
./deploy_pipelines.sh -n <NAMESPACE>
```

If you want to send notifications to slack, populate the [slack webhook secret](resources/slack_webhook.yaml) with your webhook and apply it with -
```
oc apply -f ./resources/slack_webhook.yaml -n <NAMESPACE>
```

## How to trigger a pipeline run

## Disappearing Logs
Generally logs can be viewed in the Logs tab under a pipeline run. However for some reason some logs disappear, regardless of taskrun success/failure. The most recent logs are also saved in the same pvc used by tasks under `./task_logs/<task-name>` To view the logs in case they disappear from the UI, deploy the pod defined [here](https://github.com/stolostron/hypershift-pipelines/blob/main/resources/task-log-pod.yaml). Once it's running, run:
```
$ kubectl exec -it task-log-pod -- /bin/sh
/ # cd data/task_logs
```
Once you're done viewing the logs, make sure to delete the pod or subsequent pipeline runs may hang.
```
/ # exit
$ kubectl delete pods task-log-pod
```

## Cleanup

todo


### Handy Repositories

| Repo | Description |
| ------ | --------- |
| [OpenShift Pipelines Tutorials](https://github.com/openshift/pipelines-tutorial) | Openshift Pipelines community tutorials |
| [Tekton Pipelines](https://github.com/tektoncd/pipeline) | Tekton Pipelines is the upstream of OpenShift Pipelines |
| [Tekton Operator](https://github.com/tektoncd/operator) | Tekton Operator is the Operator deployment of Tekton. Also contains code samples |
| [Tekton Catalog](https://github.com/tektoncd/catalog) | Tekton Catalog of Reusable Tasks |
| [TektonHub](https://hub.tekton.dev/) | Online repository of Tekton tasks |
