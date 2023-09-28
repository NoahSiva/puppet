#!/bin/bash

# Prompt for Foreman server domain name
read -p "Enter Foreman Server Domain Name (e.g., your-foreman-server.com): " FOREMAN_DOMAIN
# Prompt for Foreman API username and password
read -p "Enter Foreman API Username: " USERNAME
read -sp "Enter Foreman API Password: " PASSWORD
echo  # Newline for spacing

# Prompt for the path to the file containing a list of host names or IDs
read -p "Enter the path to the file containing host names or IDs: " HOST_LIST_FILE

# Prompt for SSH username and password
read -p "Enter SSH Username for Puppet agent execution: " SSH_USERNAME
read -sp "Enter SSH Password for Puppet agent execution: " SSH_PASSWORD
echo  # Newline for spacing

# Prompt for the path to the log file
read -p "Enter the path to the log file for deletion logs (e.g., deletion_log.txt): " LOG_FILE

# Validate that required information is provided
if [ -z "$FOREMAN_DOMAIN" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$HOST_LIST_FILE" ] || [ -z "$SSH_USERNAME" ] || [ -z "$SSH_PASSWORD" ] || [ -z "$LOG_FILE" ]; then
  echo "Please provide all required information."
  exit 1
fi
FOREMAN_API_URL="https://${FOREMAN_DOMAIN}/api/hosts/"
# Initialize the log file
# Read the host names or IDs from the file and delete each one
while IFS= read -r HOST_NAME_OR_ID
do
  # Construct the URL for the host you want to delete
  DELETE_URL="${FOREMAN_API_URL}${HOST_NAME_OR_ID}"

  # Send a DELETE request to delete the host
  curl -X DELETE -s -k -u "${USERNAME}:${PASSWORD}" "${DELETE_URL}"

  echo "Deleted host: ${HOST_NAME_OR_ID}" >> "$LOG_FILE"

  sshpass -p "${SSH_PASSWORD}" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "${SSH_USERNAME}@${HOST_NAME_OR_ID}"  'sudo puppet agent -t'

     echo "Executed Puppet agent on host: ${HOST_NAME_OR_ID}" >> "$LOG_FILE"

done < "$HOST_LIST_FILE"

echo "Deletion log is saved in: $LOG_FILE"

