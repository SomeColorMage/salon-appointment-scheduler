#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  # get services
  echo "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED

  # get service
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # if no service
  if [[ -z $SERVICE_NAME ]]
  then
    # reset menu
    MENU "I could not find that service. What would you like today?"
  else
    # format
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ |/"/')

    # get customer details
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if no customer
    if [[ -z $CUSTOMER_ID ]]
    then
      # create customer
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

      # get customer id again (we already have name)
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    else
      # get customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
    fi

    # get time
    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # make appointment
    APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MENU "Welcome to My Salon, how can I help you?"