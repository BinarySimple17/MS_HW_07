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
kubectl apply -f ./install/k8s/manifests/users-secret.yaml -n zsvv-main
kubectl apply -f ./install/k8s/manifests/gateway-secrets.yaml -n zsvv-main

kubectl create namespace zsvv-authority
kubectl apply -f ./install/k8s/manifests/auth-secrets.yaml -n zsvv-authority 

kubectl create namespace zsvv-kafka
kubectl apply -f ./install/k8s/manifests/kafka-secrets.yaml -n zsvv-kafka
kubectl apply -f ./install/k8s/manifests/kafka-secrets.yaml -n zsvv-main
kubectl apply -f ./install/k8s/manifests/notif-secrets.yaml -n zsvv-main 
kubectl apply -f ./install/k8s/manifests/order-secrets.yaml -n zsvv-main 
kubectl apply -f ./install/k8s/manifests/bill-secrets.yaml -n zsvv-main

# echo "Secrets applied. Waiting 20 seconds..."
# wait_seconds 20

# Добавление helm репозиториев
echo "Step 2: Adding Helm repositories..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kafka-ui https://provectus.github.io/kafka-ui-charts
helm repo update

# Сборка локальных helm чартов
echo "Step 3: Building local Helm charts..."
helm package ./install/auth-service/ --destination ./install/auth-service/
helm package ./install/gateway-service/ --destination ./install/gateway-service/
helm package ./install/kafka/ --destination ./install/kafka/
helm package ./install/kafka-ui/ --destination ./install/kafka-ui/
# helm package ./install/monitoring/ --destination ./install/monitoring/
helm package ./install/users-service/ --destination ./install/users-service/
helm package ./install/billing-service/ --destination ./install/billing-service/
helm package ./install/notif-service/ --destination ./install/notif-service/
helm package ./install/order-service/ --destination ./install/order-service/

echo "Helm charts built. Waiting 20 seconds..."
wait_seconds 20

# Установка мониторинга
echo "Step 4: Installing monitoring stack..."
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -f install/monitoring/prometheus.yaml \
  -f install/monitoring/grafana.yaml \
  --namespace zsvv-monitoring \
  --create-namespace

echo "Monitoring stack installed. Waiting 60 seconds..."
wait_seconds 60

# Установка ingress контроллера
echo "Step 5: Installing NGINX Ingress Controller..."
helm upgrade --install nginx ingress-nginx/ingress-nginx \
  -f install/k8s/manifests/nginx-ingress.yaml \
  --namespace zsvv-ng \
  --create-namespace \
  --set controller.admissionWebhooks.patch.enabled=true

echo "NGINX Ingress Controller installed. Waiting 20 seconds..."
wait_seconds 20

# Установка пользовательского сервиса
echo "Step 6: Installing users service..."
helm upgrade --install hw6 ./install/users-service/ \
  -n zsvv-main \
  --set ingress.enabled=false \
  --set endpoints.kafka.space=zsvv-kafka

echo "Users service installed. Waiting 20 seconds..."
wait_seconds 20

# Установка сервиса авторизации
echo "Step 7: Installing auth service..."
helm upgrade --install hw6 ./install/auth-service/ \
  -n zsvv-authority \
  --create-namespace \
  --set endpoints.usersServiceSpace=zsvv-main \
  --set endpoints.apiGatewaySpace=zsvv-main

echo "Auth service installed. Waiting 20 seconds..."
wait_seconds 20

# Установка API gateway
echo "Step 8: Installing API gateway..."
helm upgrade --install hw6-api ./install/gateway-service/ \
  -n zsvv-main \
  --set endpoints.users.space=zsvv-main \
  --set endpoints.order.space=zsvv-main \
  --set endpoints.auth.space=zsvv-authority \
  --set endpoints.notif.space=zsvv-main \
  --set endpoints.bill.space=zsvv-main

echo "API gateway installed. Waiting 20 seconds..."
wait_seconds 20

# Установка Kafka
echo "Step 9: Installing Kafka..."
helm upgrade --install hw7 ./install/kafka/ \
  -n zsvv-kafka \
  --create-namespace

echo "Kafka installed. Waiting 40 seconds..."
wait_seconds 40

# Установка Kafka UI
echo "Step 10: Installing Kafka UI..."
helm upgrade --install hw7-ui ./install/kafka-ui/ \
  -n zsvv-kafka \
  --create-namespace

echo "Kafka UI installed. Waiting 20 seconds..."
wait_seconds 20

# Установка Notification Service
echo "Step 11: Installing Notification Service..."
helm upgrade --install hw7-notif ./install/notif-service/ \
  -n zsvv-main \
  --set endpoints.usersServiceSpace=zsvv-main \
  --set endpoints.authServiceSpace=zsvv-authority \
  --set endpoints.kafkaSpace=zsvv-kafka

echo "Notification Service installed. Waiting 20 seconds..."
wait_seconds 20

# Установка Order Service
echo "Step 12: Installing Order Service..."
helm upgrade --install hw7-order ./install/order-service/ \
  -n zsvv-main \
  --set endpoints.users.space=zsvv-main \
  --set endpoints.auth.space=zsvv-authority \
  --set endpoints.kafka.space=zsvv-kafka \
  --set endpoints.bill.space=zsvv-main

echo "Order Service installed. Waiting 20 seconds..."
wait_seconds 20

# Установка Billing Service
echo "Step 13: Installing Billing Service..."
helm upgrade --install hw7-bill ./install/billing-service/ \
  -n zsvv-main \
  --set endpoints.kafka.space=zsvv-kafka

echo "Billing Service installed. Waiting 20 seconds..."
wait_seconds 20

echo "========================================="
echo "Installation completed successfully!"
echo "All services have been deployed."
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
echo "1. Created namespaces: zsvv-main, zsvv-authority, zsvv-kafka"
echo "2. Applied all required secrets"
echo "3. Installed Monitoring stack in zsvv-monitoring"
echo "4. Installed NGINX Ingress in zsvv-ng"
echo "5. Installed Core services:"
echo "   - Users Service (hw6)"
echo "   - Auth Service (hw6)"
echo "   - API Gateway (hw6-api)"
echo "6. Installed Kafka infrastructure:"
echo "   - Kafka (hw7)"
echo "   - Kafka UI (hw7-ui)"
echo "7. Installed Business services:"
echo "   - Notification Service (hw7-notif)"
echo "   - Order Service (hw7-order)"
echo "   - Billing Service (hw7-bill)"
echo "========================================="

# Ожидание ввода пользователя
echo ""
read -p "Press Enter to continue..."
echo "Script execution completed. You may close this window."