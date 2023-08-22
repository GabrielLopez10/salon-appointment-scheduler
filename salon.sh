#!/bin/bash

# Set up the PSQL command
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Display salon welcome message
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

# Function to display available services and get user's selection
GET_SERVICES_ID() {
  # Display a message if provided
  [[ $1 ]] && echo -e "\n$1"

  # Query and list available services
  $PSQL "SELECT * FROM services" | while read SERVICE_ID BAR SERVICE; do
    echo "$SERVICE_ID) $SERVICE"
  done

  # Read the user's service selection
  read SERVICE_ID_SELECTED

  # Check the selection and proceed accordingly
  case $SERVICE_ID_SELECTED in
  [1-5]) NEXT ;;
  *) GET_SERVICES_ID "I could not find that service. What would you like today?" ;;
  esac
}

# Function to get customer details and schedule appointments
NEXT() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Retrieve customer name by phone number
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed 's/ //g')

  # Insert customer if not found
  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    $PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')"
  fi

  # Retrieve service name and customer ID
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed 's/ //g')
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Get preferred appointment time and save
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # Insert appointment and provide feedback
  if [[ $($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')") == "INSERT 0 1" ]]; then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

# Start by getting the user's selected service
GET_SERVICES_ID
