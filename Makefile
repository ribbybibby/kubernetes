NEW_NAMESPACE_CLUSTER := "minikube"
NEW_NAMESPACE := ""

new-namespace:
	@./scripts/new-namespace.sh $(NEW_NAMESPACE_CLUSTER) $(NEW_NAMESPACE) 
