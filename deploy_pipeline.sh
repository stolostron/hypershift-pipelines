NAMESPACE=hypershift-devel
while getopts "n:" arg; do
  case $arg in
    n) NAMESPACE=$OPTARG;;
  esac
done
echo "Deploying pipeline in namespace $NAMESPACE"

echo "---Deploying tasks---"
oc apply -f ./tasks/ -n $NAMESPACE

echo "---Deploying pipeline(s)---"
oc apply -f ./pipelines/ -n $NAMESPACE

echo "---Deploying trigger related resources---"
oc apply -f ./trigger/ -n $NAMESPACE

echo "---Ensuring existence of persistent volume claim---"
oc apply ./resources/persistentvolumeclaim.yaml

echo "---Exposing event-listener route---"
oc expose svc el-hs-ci-github-listener

echo "URL: $(oc  get route el-hs-ci-github-listener --template='http://{{.spec.host}}')"
