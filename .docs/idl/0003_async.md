# API IDL: Решение 0003 — Полностью асинхронная архитектура (Kafka)

## Общее описание
Архитектура, основанная на асинхронном взаимодействии между микросервисами через Kafka. Все коммуникации осуществляются через события, что обеспечивает слабую связность, масштабируемость и отказоустойчивость.

## Каналы (Channels) и события

### Канал: `orders.requests`
**Описание:** Запрос на создание заказа  
**Publisher:** API Gateway  
**Subscriber:** Order Service  
**Структура сообщения:**
```json
{
  "requestId": "string",
  "username": "string",
  "items": [
    {
      "productId": "string",
      "quantity": "integer",
      "price": "number",
      "name": "string"
    }
  ],
  "deliveryAddress": "string",
  "paymentMethod": "string",
  "createdAt": "long"
}
```

### Канал: `orders.created`
**Описание:** Событие о создании заказа  
**Publisher:** Order Service  
**Subscriber:** Billing Service  
**Структура сообщения:**
```json
{
  "requestId": "string",
  "username": "string",
  "orderId": "long",
  "items": [
    {
      "productId": "string",
      "quantity": "integer",
      "price": "number",
      "name": "string"
    }
  ],
  "totalCost": "double",
  "createdAt": "long"
}
```

### Канал: `billing.payments`
**Описание:** Результат обработки платежа  
**Publisher:** Billing Service  
**Subscriber:** Order Service  
**Структура сообщения:**
```json
{
  "requestId": "string",
  "orderId": "long",
  "username": "string",
  "amount": "double",
  "success": "boolean",
  "failureReason": "string",
  "processedAt": "long"
}
```

### Канал: `orders.status`
**Описание:** Обновление статуса заказа  
**Publisher:** Order Service  
**Subscriber:** API Gateway, Notification Service  
**Структура сообщения:**
```json
{
  "requestId": "string",
  "orderId": "long",
  "username": "string",
  "status": "string",
  "previousStatus": "string",
  "updatedAt": "long",
  "metadata": "object"
}
```

### Канал: `notifications.requested`
**Описание:** Запрос на отправку уведомления  
**Publisher:** Notification Service  
**Subscriber:** Notification Delivery Service  
**Структура сообщения:**
```json
{
  "notificationId": "string",
  "requestId": "string",
  "username": "string",
  "type": "string",
  "subject": "string",
  "content": "string",
  "metadata": "object",
  "scheduledAt": "long"
}
```

### Канал: `notifications.sent`
**Описание:** Уведомление отправлено  
**Publisher:** Notification Delivery Service  
**Subscriber:** — (мониторинг, логирование)  
**Структура сообщения:**
```json
{
  "notificationId": "string",
  "requestId": "string",
  "username": "string",
  "success": "boolean",
  "sentAt": "long",
  "errorMessage": "string"
}
```

### Канал: `users.registered`
**Описание:** Регистрация нового пользователя  
**Publisher:** Auth Service  
**Subscriber:** User Service, Billing Service  
**Структура сообщения:**
```json
{
  "username": "string",
  "email": "string",
  "registeredAt": "long",
  "source": "string"
}
```

### Канал: `users.profile`
**Описание:** Запрос профиля пользователя  
**Publisher:** Notification Service  
**Subscriber:** User Service  
**Структура сообщения:**
```json
{
  "requestId": "string",
  "username": "string",
  "requestedAt": "long"
}
```

### Канал: `users.profile.response`
**Описание:** Ответ с профилем пользователя  
**Publisher:** User Service  
**Subscriber:** Notification Service  
**Структура сообщения:**
```json
{
  "requestId": "string",
  "username": "string",
  "email": "string",
  "phone": "string",
  "firstName": "string",
  "lastName": "string",
  "respondedAt": "long"
}
```

## Компоненты (Schemas)

### OrderItem
```json
{
  "productId": "string",
  "quantity": "integer",
  "price": "double",
  "name": "string"
}
```