# Comparing options for mutating k8s resources

## Shell-Operator

Option for mutating as Mutating Admission Controller using [Shell-Operator](https://github.com/flant/shell-operator) tool.

Pros:
- easy to write extensions
- its a shall script or python
- fast to start, easy to test

Cons:
- Mutating Admission Controller needs certs for service, however there is an issue with picking up new cert after renewal - [487](https://github.com/flant/shell-operator/issues/487)
- Its a tool operating by someone else, when there is a problem we need to take ownership of it

## Python file manipulation

IN PROGRESS

A way of manipulating YAML file using Pyton libs. This step needs to be executed before resource is applied to Kubernetes, and it gives the most flexibility without having to work with cluster operators.

## Using existing framework

IN PROGRESS

- [Operator Framework](https://operatorframework.io/)
- [Kubebuilder](https://book.kubebuilder.io/cronjob-tutorial/webhook-implementation.html)