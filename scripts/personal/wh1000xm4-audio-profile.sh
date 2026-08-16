#!/bin/bash

# Device alias to match against
DEVICE_ALIAS="WH-1000XM4"

# Fetch the card name for the device
CARD_NAME=$(pactl list cards | awk '/Name:/ {name=$2} /device.alias = "WH-1000XM4"/ {print name}')

# If the card name is empty, exit
if [ -z "$CARD_NAME" ]; then
    echo "Unable to find the card for device $DEVICE_ALIAS"
    exit 1
fi

# Retrieve all supported profiles for the card
SUPPORTED_PROFILES=$(pactl list cards | awk -v card="$CARD_NAME" '/Name: / {if ($2 == card) {f=1} else {f=0}} f && /Profiles:/, /Active Profile:/ {if (!/Profiles:/ && !/Active Profile:/) print $1}')

# Declare an associative array for profiles
declare -A PROFILES
PROFILES["a2dp-sink"]="High Quality Audio Only"
PROFILES["headset-head-unit-cvsd"]="Mono audio / mic"

# Create an array of profiles that we're interested in and are supported by the device
FILTERED_PROFILES=()
for profile in "${!PROFILES[@]}"; do
    if echo "$SUPPORTED_PROFILES" | grep -q "^${profile}:"; then
        FILTERED_PROFILES+=("$profile (${PROFILES[$profile]})")
    fi
done

if [ ${#FILTERED_PROFILES[@]} -eq 0 ]; then
    echo "None of the desired profiles are supported by device $DEVICE_ALIAS"
    exit 1
fi

# Display the profiles and prompt the user to choose
echo "Available profiles for $DEVICE_ALIAS:"
select opt in "${FILTERED_PROFILES[@]}"; do
    for profile in "${!PROFILES[@]}"; do
        if [[ $opt == "$profile (${PROFILES[$profile]})" ]]; then
            pactl set-card-profile "$CARD_NAME" "$profile"
            echo "Switched to profile: $opt"
            exit 0
        fi
    done
    echo "Invalid option."
done
