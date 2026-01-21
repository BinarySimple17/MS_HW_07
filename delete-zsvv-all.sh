#!/bin/bash

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