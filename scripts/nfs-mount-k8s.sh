#!/bin/bash

set -e  # Exit on any error

# Detect WiFi IP (wlp0s20f3) and update /etc/hosts
IP=$(ip -4 a show wlp0s20f3 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
HOSTNAME="myip.local"

if [[ -n "$IP" ]]; then
    echo "✅ Detected IP: $IP"

    # Backup /etc/hosts before modifying
    sudo cp /etc/hosts /etc/hosts.bak

    # Remove any existing entry for myip.local
    sudo sed -i "/$HOSTNAME/d" /etc/hosts

    # Append the new entry
    echo "$IP $HOSTNAME" | sudo tee -a /etc/hosts

    echo "✅ Updated /etc/hosts with: $IP $HOSTNAME"
else
    echo "❌ Error: Could not determine IP for wlp0s20f3."
    exit 1
fi

# -----------------------------------
# UPDATE /etc/hosts IN ALL VAGRANT NODES
# -----------------------------------
NODES=("controlplane" "node01" "node02") # "node03")
NFS_SERVER="$HOSTNAME"  # Use domain instead of raw IP
NFS_PATH="/nfs/kubedata"
MOUNT_POINT="/mnt"

update_hosts() {
    local node=$1
    echo "🔄 Updating /etc/hosts in $node..."
    vagrant ssh "$node" -c "
        sudo sed -i '/$HOSTNAME/d' /etc/hosts
        echo '$IP $HOSTNAME' | sudo tee -a /etc/hosts
    " && echo "✅ Updated /etc/hosts in $node!" || echo "❌ Failed to update /etc/hosts in $node"
}

# Apply /etc/hosts update in all nodes
for node in "${NODES[@]}"; do
    update_hosts "$node" &
done

# Wait for all background jobs to finish
wait
echo "🎉 /etc/hosts update completed on all nodes!"

# -----------------------------------
# NFS MOUNTING SCRIPT STARTS HERE
# -----------------------------------

# Function to mount NFS on a node
mount_nfs() {
    local node=$1
    echo "🚀 Mounting NFS on $node..."
    vagrant ssh "$node" -c "
        sudo apt-get update -y
        sudo apt-get install -y nfs-common
        sudo mkdir -p $MOUNT_POINT
        sudo mount -t nfs $NFS_SERVER:$NFS_PATH $MOUNT_POINT
        df -h | grep $MOUNT_POINT
    " && echo "✅ NFS mounted successfully on $node!" || echo "❌ Failed to mount NFS on $node"
}

# Mount NFS on all nodes in parallel
for node in "${NODES[@]}"; do
    mount_nfs "$node" &
done

# Wait for all background jobs to finish
wait

echo "🎉 NFS mount process completed!"
