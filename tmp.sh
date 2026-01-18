helm upgrade --install hw7-notif ./install/notif-service/ \
  -n zsvv-main \
  --set endpoints.usersServiceSpace=zsvv-main \
  --set endpoints.authServiceSpace=zsvv-authority \
  --set endpoints.kafkaSpace=zsvv-kafka