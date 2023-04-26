NAMESPACE=hypershift-devel
while getopts "n:" arg; do
  case $arg in
    n) NAMESPACE=$OPTARG;;
  esac
done
echo "Deploying pipeline in namespace $NAMESPACE"
oc apply -f ./tasks/ -n $NAMESPACE
oc apply -f ./pipelines/ -n $NAMESPACE
#oc apply -f .trigger/ -n $NAMESPACE