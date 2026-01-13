#!/bin/bash
PSQL="psql -U freecodecamp -d salon --quiet --no-align --tuples-only -c"
MENU_RESULT=''
while IFS=" | " read -r id name; do
  MENU_RESULT+="$id) $name\n"
done < <($PSQL "SELECT service_id, name FROM services;")
echo -e "~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you?\n\n$MENU_RESULT"
#prompt for service id, phone, name, time
while true; do
  echo -e "\nPlease enter your desired service:"
  read SERVICE_ID_SELECTED
  if [[ $MENU_RESULT == *"$SERVICE_ID_SELECTED)"* ]]; then
  SERVICE_RESULT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    break  # Valid service ID entered, exit the loop
  else
    echo -e "We don't have that service, please try again.\n\n$MENU_RESULT"
  fi
done
while true; do
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE
  PHONE_EXISTS=$($PSQL "SELECT COUNT(*) FROM customers WHERE phone = '$CUSTOMER_PHONE';" --no-align --tuples-only)
  if [ "$PHONE_EXISTS" -gt 0 ]; then
    break  # Phone number exists, exit the loop
  else
    echo -e "\nI don't have a record for you. May I please have your name?"
    read CUSTOMER_NAME
    while true; do
      NAME_PATTERN="^[A-Z][a-zA-Z' -]+( [A-Z][a-zA-Z' -]+)?$"
      if [[ $CUSTOMER_NAME =~ $NAME_PATTERN ]]; then
        break #valid name, exit loop
      else
        echo "Invalid customer name. Please enter Firstname Lastname:"
        read CUSTOMER_NAME
      fi
    done
    $PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
    break
  fi
done
CUSTOMER_NAME_RESULT=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
CUSTOMER_ID_RESULT=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'"  --tuples-only --no-align)
echo -e "Please enter your desired service time:"
read SERVICE_TIME
while true; do
  TIME_PATTERN="^[0-9]{1,2}:[0-9]{2} ?(am|pm|AM|PM)?$"
  if [[ $SERVICE_TIME =~ $TIME_PATTERN ]]; then
    break  # Valid time format, exit the loop
  else
    echo "Invalid time format. Please enter the time in the format hh:mm am/pm:"
    read SERVICE_TIME
  fi
done
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID_RESULT, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"
echo -e "I have put you down for a $SERVICE_RESULT at $SERVICE_TIME, $CUSTOMER_NAME_RESULT."


