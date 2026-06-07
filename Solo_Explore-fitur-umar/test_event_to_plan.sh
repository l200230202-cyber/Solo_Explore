#!/bin/bash

# Login first to get token
echo "=== Login ==="
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"aditya@example.com","password":"password123"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo "Token: $TOKEN"

# Get trip plans
echo -e "\n=== Get Trip Plans ==="
curl -s -X GET http://localhost:8000/api/trip-plans \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | head -n 20

# Get events
echo -e "\n\n=== Get Events ==="
curl -s -X GET http://localhost:8000/api/events | head -n 30

# Add event to trip plan (plan ID 1, event ID 1)
echo -e "\n\n=== Add Event to Trip Plan ==="
curl -s -X POST http://localhost:8000/api/trip-plans/1/items \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "plannable_type": "event",
    "plannable_id": 1,
    "day_number": 1,
    "time": "10:00",
    "notes": "Test event from script"
  }'

echo -e "\n\nDone!"
