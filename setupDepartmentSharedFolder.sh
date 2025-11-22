#!/bin/bash
# This script creates department shared folders, groups, and permissions.

# 1.) Require argument
if [ -z "$1" ]; then
    echo "Usage: $0 <root-folder>"
    exit 1
fi

ROOTFOLDER="$1"

# 2.) Check for root access
if [ "$(whoami)" != "root" ]; then
    echo "This script must be run as root."
    exit 1
fi

# 3.) Ensure root folder exists
if [ ! -d "$ROOTFOLDER" ]; then
    echo "Root folder does not exist. Creating $ROOTFOLDER..."
    mkdir -p "$ROOTFOLDER"
fi

# 4.) Departments list
DEPARTMENTS=("Sales" "HumanResources" "TechnicalOperations" "Helpdesk" "Research")

# 5 & 6.) Create groups if missing
for DEPT in "${DEPARTMENTS[@]}"; do
    if getent group "$DEPT" > /dev/null; then
        echo "Group $DEPT already exists."
    else
        echo "Creating group: $DEPT"
        groupadd "$DEPT"
    fi
done

# 7 & 8.) Create department directories and set permissions
for DEPT in "${DEPARTMENTS[@]}"; do
    DIR="$ROOTFOLDER/$DEPT"

    if [ ! -d "$DIR" ]; then
        echo "Creating directory: $DIR"
        mkdir -p "$DIR"
    fi

    echo "Setting owner and group permissions on $DIR..."
    chown root:"$DEPT" "$DIR"
    chmod 770 "$DIR"

    echo "Granting Helpdesk group read-only access to $DIR..."
    setfacl -m g:Helpdesk:rx "$DIR"
done

echo "All operations completed successfully."
