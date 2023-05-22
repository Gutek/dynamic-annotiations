docker build -t gutek/mutating:shell-operator .

docker push gutek/mutating:shell-operator

helm delete --namespace=annotiation-mutating annotiation-mutating
kubectl delete mutatingwebhookconfiguration/annotiation-mutating-hooks
kubectl delete ns annotiation-mutating

helm upgrade --install --namespace annotiation-mutating --create-namespace annotiation-mutating .