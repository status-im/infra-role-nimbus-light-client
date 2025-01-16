#!/usr/bin/env bash
# Call this script to toggle whether Ansible should make changes.
# If named 'ansible_disabled.sh' all Ansible tasks are skipped.
set -e
SCRIPT_PATH=$(realpath -s "${0}")
if [[ "${SCRIPT_PATH}" =~ _enabled.sh$ ]]; then
    mv -f "${SCRIPT_PATH}" "${SCRIPT_PATH/enabled/disabled}"
    echo "Disabled automatic updates by Ansible!"
elif [[ "${SCRIPT_PATH}" =~ _disabled.sh$ ]]; then
    mv -f "${SCRIPT_PATH}" "${SCRIPT_PATH/disabled/enabled}"
    echo "Enabled automatic updates by Ansible!"
else
    echo "Expected script name to include 'disabled' or 'enabled'!" >&2
    exit 1
fi
