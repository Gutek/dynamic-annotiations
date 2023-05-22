
## Running Demo

### Generate certificates

An HTTP server behind the MutatingWebhookConfiguration requires a certificate issued by the CA. For simplicity, this process is automated with `gen-certs.sh` script. Just run it:

```
./gen-certs.sh
```

> Note: `gen-certs.sh` requires [cfssl utility](https://github.com/cloudflare/cfssl/releases/latest) and linux to work properrly.

To instal `cfssl` run
```
go install github.com/cloudflare/cfssl/cmd/cfssl@latest
go install github.com/cloudflare/cfssl/cmd/cfssljson@latest
```

if it does not work use apt:
```
sudo apt install golang-cfssl
```

### Build and install example

Build Docker image and use helm3 to install it:

```
docker build -t REPO_NAME/mutating:shell-operator .
docker push REPO_NAME/mutating:shell-operator
helm upgrade --install --namespace annotiation-mutating --create-namespace annotiation-mutating .
```

or use `cls.sh` to clean and install.

> Note:Update `templates/deployment.yaml` to image `REPO_NAME/mutating:shell-operator`

### See mutating hook in action

Play with `deploy-name....yaml` files. Whenever you apply one, check deployment yaml on k8s::

```
$ kubectl -n annotiation-mutating get deployment nginx-deployment -o yaml
```

### Cleanup

```
helm delete --namespace=annotiation-mutating annotiation-mutating
kubectl delete mutatingwebhookconfiguration/annotiation-mutating-hooks
kubectl delete ns annotiation-mutating
```

or use cls sh to build, clean, install:

```
./cls.sh
```