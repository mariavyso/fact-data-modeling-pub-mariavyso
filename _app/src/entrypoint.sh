#!/bin/bash

set -e 

aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region us-west-2

values=$(aws secretsmanager get-secret-value --secret-id "${SECRET_NAME}" --query 'SecretString' --output text)
for val in $(echo "${values}" | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" ); do
    echo "$val" >> .env
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

echo "Executing SQL queries for changed files: $CHANGED_FILES..."

# Loop through the changed files and run tests/comment generation
for file in $CHANGED_FILES; do
  # Run tests/comment generation for each changed file
  if [[ $file == *.sql ]]; then
    echo "Processing SQL file: $file"
    RETURN_VALUE=$(exec python src/trino_tests.py $file)

    last_line=$(echo $RETURN_VALUE | tail -n 1)
    if [[ "$last_line" = 'All tests passed successfully' ]]; then
      echo "Tests for $file passed! Generating feedback..."
      exec python src/generate_comment.py $file
      echo "Done processing $file!"
    else
      echo "---------------------------------------------------------------------------------"
      echo "------------------------------- ❌ TESTS FAILED ❌ -------------------------------"
      echo "$RETURN_VALUE"
      echo "----------------------------------------------------------------------------------"
      echo "----------------------------------------------------------------------------------"
      echo "Please update your submission for $file and try again."
      exit 1
    fi
  else
    echo "Skipping non-SQL file: $file"
  fi
done
