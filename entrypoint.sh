#!/bin/sh -l

warn () {
  text=$1
  echo -e "\e[1;33m $text \e[0m"
}

failt () {
  text=$1
  echo -e "\e[1;31m $text \e[0m"
  exit 1
}

success () {
  text=$1
  echo -e "\e[1;32m $text \e[0m"
}

info () {
  text=$1
  echo -e "\e[1;34m $text \e[0m"
}

debug () {
  text=$1
  echo -e "\e[1;44m $text \e[0m"
}

set_auth() {
  local s3cnf="$HOME/.s3cfg"

  if [ -e "$s3cnf" ]; then
    warn '.s3cfg file already exists in home directory and will be overwritten'
  fi

  echo '[default]' > "$s3cnf"
  echo "access_key=$AWS_ACCESS_KEY_ID" >> "$s3cnf"
  echo "secret_key=$AWS_SECRET_ACCESS_KEY" >> "$s3cnf"

  echo "Generated .s3cfg for key $AWS_ACCESS_KEY_ID"
}

main() {
  set_auth

  info 'Starting S3 Synchronisation'

  info 'Check s3cmd version'
  info $(s3cmd --version)

  if [ -z "$AWS_S3_BUCKET" ]; then
    fail 'AWS_S3_BUCKET is not set. Quitting.'
  fi

  if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    fail 'AWS_ACCESS_KEY_ID is not set. Quitting.'
  fi

  if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    fail 'AWS_SECRET_ACCESS_KEY is not set. Quitting.'
  fi

  # Default to us-east-1 if AWS_REGION not set.
  if [ -z "$AWS_REGION" ]; then
    export AWS_REGION="us-east-1"
  fi

  if [ -z "$S3CMD_CF_INVALIDATE" ]; then
    export S3CMD_CF_INVALIDATE="--cf-invalidate"
  fi

  if [ -z "$S3CMD_EXTRA_OPTS" ]; then
    export S3CMD_EXTRA_OPTS="--verbose"
  fi

  if [ -n "$S3CMD_DELETE_REMOVED" ]; then
      if [ "$S3CMD_DELETE_REMOVED" = "true" ]; then
          export S3CMD_DELETE_REMOVED="--delete-removed"
      else
          unset S3CMD_DELETE_REMOVED
      fi
  else
      export S3CMD_DELETE_REMOVED="--delete-removed"
  fi

  if [ -z "$S3CMD_EXCLUDE" ]; then
    export S3CMD_EXCLUDE="--exclude-from $S3CMD_EXCLUDE"
  fi

  if [ -n "$S3CMD_EXCLUDE_FROM"]; then
      if [ -e "$S3CMD_EXCLUDE_FROM" ]; then
          export S3CMD_EXCLUDE_FROM="--exclude-from $S3CMD_EXCLUDE_FROM"
      fi
  fi

  if [ -z "$S3CMD_CACHE_CONTROL_MAX_AGE"]; then
      export S3CMD_CACHE_CONTROL_MAX_AGE="--add-header=Cache-Control:max-age=$S3CMD_CACHE_CONTROL_MAX_AGE"
  fi

  set +e
  local SYNC="s3cmd sync $S3CMD_EXCLUDE_FROM $S3CMD_DELETE_REMOVED $S3CMD_CACHE_CONTROL_MAX_AGE $S3CMD_EXTRA_OPTS $S3CMD_CF_INVALIDATE ./$S3CMD_SOURCE_DIR/* s3://$AWS_S3_BUCKET"
  debug "$SYNC"
  local sync_output=$($SYNC)

  if [[ $? -ne 0 ]];then
      debug "$sync_output"
      fail 'Failed s3cmd command';
  else
      debug "$sync_output"
      success 'Finished S3 Synchronisation';
  fi
  set -e
}

main
