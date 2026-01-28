#!/bin/bash -e

# Configuration
warning_days=10                    # Number of days to warn about soon-to-expire certs
certs_to_check='google.com:443'

echo "starting check"

# Check each certificate
for CERT in $certs_to_check; do
  # Extract expiration date from certificate
  output=$(curl -Iv --stderr - "https://${CERT}" | grep "expire date" | cut -d":" -f 2-)

  # Calculate days until expiration
  end_epoch=$(date +%s -d "$output")
  epoch_now=$(date +%s)

  seconds_to_expire=$((end_epoch - epoch_now))
  days_to_expire=$((seconds_to_expire / 86400))

  # Log the expiration status
  echo "${CERT} is about to expire in ${days_to_expire} days"
  site_name=$(echo "${CERT}" | cut -f1 -d":")

  # Alert if certificate is expiring soon
  if [[ $days_to_expire -lt $warning_days ]]; then
    echo "ERROR: ${CERT} is about to expire!!"
  fi

  # Verify the certificate is valid by making a curl request
  curl --silent "https://${CERT}" > /dev/null \
    || curl --silent "https://${CERT}" > /dev/null \
    || curl --silent "https://${CERT}" > /dev/null \
    || { echo "!!!! ${CERT} FAILED !!!"; exit 1; }
done

exit 0