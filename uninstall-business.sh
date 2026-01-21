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

echo "Uninstalling API Gateway Service..."
helm uninstall hw6-api -n zsvv-main 2>/dev/null || echo "API Gateway not found or already uninstalled"
echo "Auth Service uninstalled. Waiting 3 seconds..."

echo "Uninstallation completed!"