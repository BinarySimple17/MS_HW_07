#!/bin/bash

# Установочный скрипт для развертывания приложения в Kubernetes
echo "Starting installation..."

# Функция для ожидания
wait_seconds() {
    local seconds=$1
    echo "Waiting $seconds seconds..."
    sleep $seconds
}

# Создание namespace и применение секретов
echo "Step 1: Creating namespaces and applying secrets..."

kubectl create namespace zsvv-main
kubectl create namespace zsvv-kafka

kubectl apply -f ./install/k8s/manifests/gateway-secrets.yaml -n zsvv-main
kubectl apply -f ./install/k8s/manifests/kafka-secrets.yaml -n zsvv-kafka
kubectl apply -f ./install/k8s/manifests/kafka-secrets.yaml -n zsvv-main

# Добавление helm репозиториев
echo "Step 2: Adding Helm repositories..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kafka-ui https://provectus.github.io/kafka-ui-charts
helm repo update


# Установка мониторинга
echo "Step 3: Installing monitoring stack..."
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -f install/monitoring/prometheus.yaml \
  -f install/monitoring/grafana.yaml \
  --namespace zsvv-monitoring \
  --create-namespace

echo "Monitoring stack installed. Waiting 20 seconds..."
wait_seconds 40

# Установка ingress контроллера
echo "Step 4: Installing NGINX Ingress Controller..."
helm upgrade --install nginx ingress-nginx/ingress-nginx \
  -f install/k8s/manifests/nginx-ingress.yaml \
  --namespace zsvv-ng \
  --create-namespace \
  --set controller.admissionWebhooks.patch.enabled=true


echo "NGINX Ingress Controller installed. Waiting 5 seconds..."
wait_seconds 30

# Установка API gateway
echo "Step 5: Installing API gateway..."
helm upgrade --install hw6-api ./install/gateway-service/ \
  -n zsvv-main \
  --set endpoints.users.space=zsvv-main \
  --set endpoints.order.space=zsvv-main \
  --set endpoints.auth.space=zsvv-authority \
  --set endpoints.notif.space=zsvv-main \
  --set endpoints.bill.space=zsvv-main

echo "API gateway installed. Waiting 4 seconds..."
wait_seconds 5

# Установка Kafka
echo "Step 6: Installing Kafka..."
helm dependency build ./install/kafka/
helm upgrade --install hw7 ./install/kafka/ \
  -n zsvv-kafka \
  --create-namespace

echo "Kafka installed. Waiting 10 seconds..."
wait_seconds 10

# Установка Kafka UI
echo "Step 7: Installing Kafka UI..."
helm dependency build ./install/kafka-ui/
helm upgrade --install hw7-ui ./install/kafka-ui/ \
  -n zsvv-kafka \
  --create-namespace

echo "Kafka UI installed. Waiting 10 seconds..."
wait_seconds 10


echo "========================================="
echo "Installation completed successfully!"
echo "========================================="

# Показать статус установленных сервисов
echo "Checking deployment status..."
echo ""
echo "Namespaces:"
kubectl get namespaces | grep zsvv
echo ""
echo "Helm releases:"
helm list -A | grep -E "zsvv|monitoring|nginx"
echo ""
echo "All pods (may take a moment to start):"
kubectl get pods --all-namespaces | grep -E "zsvv|monitoring|ingress"

echo ""
echo "========================================="
echo "Installation summary:"
echo "========================================="
echo "1. Created namespaces: zsvv-main, zsvv-authority, zsvv-kafka, zsvv-ng"
echo "2. Applied all required secrets"
echo "3. Installed Monitoring stack in zsvv-monitoring"
echo "4. Installed NGINX Ingress in zsvv-ng"
echo "5. Installed Core services:"
echo "   - API Gateway (hw6-api)"
echo "6. Installed Kafka infrastructure:"
echo "   - Kafka (hw7)"
echo "   - Kafka UI (hw7-ui)"
echo "========================================="

# Ожидание ввода пользователя
echo "Script execution completed. You may close this window."
read -p "Press Enter to continue..."