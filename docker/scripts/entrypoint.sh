#!/bin/bash

TEXT_BANNER=SEAWIND

# Display text banner
figlet $TEXT_BANNER

# Start virtual X server in the background
# - DISPLAY default is :99, set in dockerfile
# - Users can override with `-e DISPLAY=` in `docker run` command to avoid
#   running Xvfb and attach their screen
if [[ -x "$(command -v Xvfb)" && "$DISPLAY" == ":99" ]]; then
	echo "Starting Xvfb"
	Xvfb :99 -screen 0 1600x1200x24+32 &
fi

# Check if the ROS_DISTRO is passed and use it
# to source the ROS environment
if [ -n "${ROS_DISTRO}" ]; then
	source "/opt/ros/$ROS_DISTRO/setup.bash"
fi

# Set start directory to home
echo "cd /home/$USERNAME" >> /home/$USERNAME/.bashrc

# Add sourcing to shell startup script
echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/$USERNAME/.bashrc

# Install dependencies 
# setup/rosdep.sh /home/$USERNAME/$WS_NAME # TODO: this is done every time the container is run, but it really only needs to be done once for setup

# Switch to non-root user
su $USERNAME

# TODO: can't use '$HOME' as it is '/root' even though the user was changed, 'cd' also doesn't work
# cd /home/$USERNAME/$WS_NAME 

# Prevent the container from exiting
/bin/bash "$@"