#!/bin/bash

# Uninstall script for removing services from Kubernetes
echo "Starting uninstallation..."

# Функция для ожидания
wait_seconds() {
    local seconds=$1
    echo "Waiting $seconds seconds..."
    sleep $seconds
}

echo "Uninstalling Users Service..."
helm uninstall hw6 -n zsvv-main 2>/dev/null || echo "Users Service not found or already uninstalled"
echo "Users Service uninstalled. Waiting 20 seconds..."
wait_seconds 20

echo "Uninstalling Notification Service..."
helm uninstall hw7-notif -n zsvv-main 2>/dev/null || echo "Notification Service not found or already uninstalled"
echo "Notification Service uninstalled. Waiting 20 seconds..."
wait_seconds 20

echo "Uninstalling Order Service..."
helm uninstall hw7-order -n zsvv-main 2>/dev/null || echo "Order Service not found or already uninstalled"
echo "Order Service uninstalled. Waiting 20 seconds..."
wait_seconds 20

echo "Uninstalling Billing Service..."
# Предполагаем, что billing service установлен как отдельный release
helm uninstall hw7-bill -n zsvv-main 2>/dev/null || echo "Billing Service not found or already uninstalled"
echo "Billing Service uninstalled. Waiting 20 seconds..."
wait_seconds 20

# # Опционально: удаление секретов для чистоты
# echo "Removing related secrets..."
# kubectl delete secret -l app=users -n zsvv-main 2>/dev/null || true
# kubectl delete secret -l app=notification -n zsvv-main 2>/dev/null || true
# kubectl delete secret -l app=order -n zsvv-main 2>/dev/null || true
# kubectl delete secret -l app=billing -n zsvv-main 2>/dev/null || true

echo "Uninstallation completed!"