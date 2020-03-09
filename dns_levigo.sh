#!/usr/bin/env sh

# levigo ACME-API
#
# LEVIGO_USER="<your-username>"
#
# LEVIGO_PASS="<your-password>"

LEVIGO_API="https://acme.levigo.net/v1"

########  Public functions #####################

#Usage: add  _acme-challenge.www.example.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
dns_levigo_add() {
  fulldomain=$1
  txtvalue=$2
  action="PUT"

  _info "Adding TXT record"
  if _levigo_rest "${action}" "${fulldomain}" "$txtvalue"; then
    _info "Added, sleeping 1 second"
    _sleep 1
    return 0
  fi
  _err "Adding TXT record error."
  return 1
}

dns_levigo_rm() {
  fulldomain=$1
  txtvalue=$2
  action="DELETE"

  _levigo_rest "${action}" "${fulldomain}" "$txtvalue"
}

####################  Private functions below ##################################
_levigo_rest() {
  action="$1"
  fulldomain="$2"
  txtvalue="$3"

  _debug action "$action"
  _debug fulldomain "$fulldomain"
  _debug txtvalue "$txtvalue"

  LEVIGO_USER="${LEVIGO_USER:-$(_readaccountconf_mutable LEVIGO_USER)}"
  LEVIGO_PASS="${LEVIGO_PASS:-$(_readaccountconf_mutable LEVIGO_PASS)}"
  if [ -z "$LEVIGO_USER" ] || [ -z "$LEVIGO_PASS" ]; then
    LEVIGO_USER=""
    LEVIGO_PASS=""
    _err "You haven't specified a levigo ACME-API username and password."
    _err "Please set your credentials and try again."
    return 1
  fi

  # save the username and password to the account.conf file.
  _saveaccountconf_mutable LEVIGO_USER "$LEVIGO_USER"
  _saveaccountconf_mutable LEVIGO_PASS "$LEVIGO_PASS"

  export _H1="Content-Type: application/json"

  json="{\"username\":\"${LEVIGO_USER}\",\"password\":\"${LEVIGO_PASS}\",\"recordtype\":\"TXT\",\"rrdatas\":\"${txtvalue}\"}"
  response="$(_post "${json}" "${LEVIGO_API}/zones/${fulldomain}/dns_records" "" "${action}")"

  if [ "$?" != "0" ]; then
    _err "error $action $fulldomain"
    return 1
  fi
  _debug response "$response"

  if _contains "$response" "Unauthorized"; then
    _err "The username and/or password given for the levigo ACME-API is not correct."
    return 1
  elif _contains "$response" "Forbidden"; then
    _err "Your levigo ACME-API account is not authorized to request a certificate for this hostname and/or domain."
    return 1
  elif _contains "$response" "Unprocessable Entity"; then
    _err "The submitted DNS-ressource-record is not correct."
    return 1
  elif _contains "$response" "Bad Request"; then
    _err "The submitted json is malformed."
    return 1
  elif _contains "$response" "Server Error"; then
    _err "The upstream nameserver reported an unknown error."
    return 1
  elif _contains "$response" "Zone update failed"; then
    _err "Zone update failed."
    return 1
  fi
  return 0
}
