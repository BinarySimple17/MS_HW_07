#!/bin/bash


echo "Uninstall"

echo "Uninstalling monitoring Service..."
helm uninstall monitoring -n zsvv-monitoring 2>/dev/null || echo "monitoring Service not found or already uninstalled"
echo "monitoring Service uninstalled. Waiting 3 seconds..."
wait_seconds 3

echo "Uninstalling kafka Service..."
helm uninstall hw7 -n zsvv-kafka 2>/dev/null || echo "kafka Service not found or already uninstalled"
helm uninstall hw7-ui -n zsvv-kafka 2>/dev/null || echo "kafka-ui Service not found or already uninstalled"
echo "kafka Service uninstalled. Waiting 3 seconds..."
wait_seconds 3

echo "Uninstalling nginx Service..."
helm uninstall nginx -n zsvv-ng 2>/dev/null || echo "nginx Service not found or already uninstalled"
echo "nginx Service uninstalled. Waiting 3 seconds..."
wait_seconds 3


echo "Uninstalling Users Service..."
helm uninstall hw6 -n zsvv-main 2>/dev/null || echo "Users Service not found or already uninstalled"
echo "Users Service uninstalled. Waiting 3 seconds..."
wait_seconds 3

echo "Uninstalling Notification Service..."
helm uninstall hw7-notif -n zsvv-main 2>/dev/null || echo "Notification Service not found or already uninstalled"
echo "Notification Service uninstalled. Waiting 3 seconds..."
wait_seconds 3

echo "Uninstalling Order Service..."
helm uninstall hw7-order -n zsvv-main 2>/dev/null || echo "Order Service not found or already uninstalled"
echo "Order Service uninstalled. Waiting 230 seconds..."
wait_seconds 3

echo "Uninstalling Billing Service..."
# Предполагаем, что billing service установлен как отдельный release
helm uninstall hw7-bill -n zsvv-main 2>/dev/null || echo "Billing Service not found or already uninstalled"
echo "Billing Service uninstalled. Waiting 3 seconds..."
wait_seconds 3

echo "Uninstalling Auth Service Service..."
helm uninstall hw6 -n zsvv-authority 2>/dev/null || echo "Auth Service not found or already uninstalled"
echo "Auth Service uninstalled. Waiting 3 seconds..."

echo "Uninstalling API GAteway Service..."
helm uninstall hw6-api -n zsvv-main 2>/dev/null || echo "API Gateway Service not found or already uninstalled"
echo "API Gateway Service uninstalled. Waiting 3 seconds..."
wait_seconds 3

echo "Deleting all namespaces starting with 'zsvv-'..."

# Получаем список всех неймспейсов
namespaces=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')

# Фильтруем те, что начинаются с zsvv-
for ns in $namespaces; do
    if [[ $ns == zsvv-* ]]; then
        echo "Deleting namespace: $ns"
        kubectl delete namespace "$ns"
    fi
done

echo "Done!"