### Changes from 2.6 pipeline to 2.7
#### Original clone from https://github.com/philipwu08/openshift-pipelines

##### Added/changed files
<details open>

```
pipelines/pipeline_downstream_27.yaml
pipelines/pipeline_upgrade_27_to_28.yaml
resources/multiclusterhub_27.yaml
resources/slack_webhook.yaml
tasks/task_createHostedCluster.yaml
tasks/task_destroyHostedCluster.yaml
tasks/task_notifyStatus_ds.yaml
tasks/task_notifyStatus_upgrade.yaml (branched from tasks/task_notifyStatus.yaml)
tasks/task_upgradeAcm.yaml
tasks/task_validateParams_27.yaml
tasks/task_verifyMigratedHostedCluster.yaml
trigger/binding-ds.yaml
trigger/eventlistener-ds.yaml
trigger/template-ds.yaml
deploy_pipeline.sh
```

</details>

##### Removed files
<details open>

```
addon-bundling/*
autoscale-hypershift/*
kcp-ns-cleanup/*
kcp-sgs-pipelines/*
ocm-utils/*
singapore-gateway-pipelines/*
.github/workflows/build_and_publish.yml
.github/workflows/update-osd-addon-config.yml
```

</details>

##### Changes
* Cleaned up directory structure
* [tasks/task_createHostedCluster.yaml](../tasks/task_createHostedCluster.yaml) used to both create and destroy hosted clusters. Decoupled creation/destruction. [tasks/task_createHostedCluster.yaml](../tasks/task_createHostedCluster.yaml) now creates, [tasks/task_destroyHostedCluster.yaml](../tasks/task_destroyHostedCluster.yaml) destroys
* Renamed some tasks to better represent what's happening, i.e. hypershiftDeployment -> Hosted Cluster
* [pipelines/pipeline_upgrade_27_to_28.yaml](../pipelines/pipeline_upgrade_27_to_28.yaml) runs both the downstream and upgrade tests. 
  * I figured it would be better to just have one pipeline (no point in running upgrade if downstream fails, no point in creating a new cluster for upgrade)
  * Changed a bunch of names of tasks, param, etc to better reflect what's happening
  * Added targetSnapshot input which is the downstream tag to upgrade to
  * Decided to destroy hostedcluster after upgrade, which is why I decoupled creation/upgrade
  * Reused create and destroy tasks post-upgrade
* Changed channel from "stable-2.1" to "stable-2.2" in [resources/multiclusterhub_27.yaml](../resources/multiclusterhub_27.yaml) to reflect mce channel for ACM 2.7.
* Created secret [resources/slack_webhook.yaml](../resources/slack_webhook.yaml) to use to post notifications to slack without exposing webhook to public
* Changed tasks/task_applyMch.yaml to [tasks/task_applyMch_27.yaml](../tasks/task_applyMch_27.yaml) and used [resources/multiclusterhub_27.yaml](../resources/multiclusterhub_27.yaml) instead of multiclusterhub.yaml
* Created secret hypershift-ci-dev11-creds on collective which hold AWS credentials to be used later
* Changed [tasks/task_checkoutCluster.yaml](../tasks/task_checkoutCluster.yaml) to copy hypershift-ci-dev11-creds from collective to the clusterclaim to be used later 
* Changes to [tasks/task_createHostedCluster.yaml](../tasks/task_createHostedCluster.yaml)
  * Removed destruction of hosted cluster (unless creation failed)
  * Changed region for hosted cluster creation to us-west-1
  * Changed domain to dev11.red-chesterfield.com
  * Created external DNS domain hs-pipeline.dev11.red-chesterfield.com and set EXT_DNS_DOMAIN to that
  * Created bucket hypershift-ci-bucket and set S3_BUCKET_NAME to that
  * Added region flag to `hypershift destroy`, which solved the issue of infra not being destroyed properly on failure
* Changes to [tasks/task_destroyHostedCluster.yaml](../tasks/task_destroyHostedCluster.yaml)
  * Copied over destroy logic from old [tasks/task_createHostedCluster.yaml](../tasks/task_createHostedCluster.yaml)
  * Needed to install hypershift binary again for some reason (wasn't able to find it installed from previous task)
  * Move into `hypershift-addon-operator/test/canary` to find all files used in [tasks/task_createHostedCluster.yaml](../tasks/task_createHostedCluster.yaml)
* Changes to [tasks/task_notifyStatus_ds.yaml](../tasks/task_notifyStatus_ds.yaml)
  * Changed status message to include pipeline run link, plus ACM and hub OCP build.
  * Use environment variable fetched from secret to use slack webhook
  * Use status of last downstream task instead of aggregate status to report success/failure
* Changes to [tasks/task_notifyStatus_upgrade.yaml](../tasks/task_notifyStatus_upgrade.yaml)
  * Similar to [tasks/task_notifyStatus_ds.yaml](../tasks/task_notifyStatus_ds.yaml), but use aggregate status for success/failure.
  * Slightly different status message than [tasks/task_notifyStatus_ds.yaml](../tasks/task_notifyStatus_ds.yaml)
* Changes to [tasks/task_upgradeAcm.yaml](../tasks/task_upgradeAcm.yaml)
  * Removed undefined variables which caused script not to work
  * Got the MCE version based on the ACM version instead of hardcoding it
    * Added github token secret `pipeline-gh-token` since fetching MCE version is from private repo
* Changed [tasks/task_validateParams_27.yaml](../tasks/task_validateParams_27.yaml) to only validate DOWNSTREAM tags
* Updated [tasks/task_verifyMigratedHostedCluster.yaml](../tasks/task_verifyMigratedHostedCluster.yaml) to use the correct namespace and hosted cluster name when verifying
* Added an extra binding to [trigger/binding-ds.yaml](../trigger/binding-ds.yaml) for upgrade downstream tag
* Added an extra field to [trigger/template-ds.yaml](../trigger/template-ds.yaml) for the upgrade tag
* Fixed a bug in [tasks/task_applyAcmSubscription.yaml](../tasks/task_applyAcmSubscription.yaml) with an incorrect null check, increased the time between checks
* Created [.github/workflows/fetch_and_push_tag.yaml](../.github/workflows/fetch_and_push_tag.yaml), which is a github action that fetches the required tags and pushes it to an event listener which triggers the pipeline. Runs with a scheduled cron job at 7am every weekday. Can also be triggered manually.
* Created [deploy_pipeline.sh](../deploy_pipeline.sh) to automatically deploy everything needed to make the pipeline work. Still need to add more things to it