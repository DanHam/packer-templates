#!/usr/bin/env bash
#
# Remove extraneous packages installed by Anaconda
#
# Set verbose/quiet output based on env var configured in Packer template
[[ "$DEBUG" = true ]] && REDIRECT="/dev/stdout" || REDIRECT="/dev/null"

# Logging for Packer
echo "Removing extraneous packages installed by Anaconda..."

# The following packages are installed by Anaconda regardless of any
# attempts to exclude them in the %packages section. In short Anaconda
# seems to ignore options and settings in the %packages section and does
# its own thing regardless...
PACKAGE_LIST=(
    atk
    atkmm
    btrfs-progs
    cairo
    cairomm
    cups-libs
    e2fsprogs
    e2fsprogs-libs
    gdk-pixbuf2
    graphite2
    gtk2
    gtkmm24
    harfbuzz
    hicolor-icon-theme
    jasper-libs
    jbigkit-libs
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXft
    libXi
    libXinerama
    libXrandr
    libXrender
    libXtst
    libXxf86vm
    libdrm
    libjpeg-turbo
    libpng
    libss
    libthai
    libtiff
    libxcb
    libxshmfence
    mesa-libEGL
    mesa-libGL
    mesa-libgbm
    mesa-libglapi
    open-vm-tools
    open-vm-tools-desktop
    pango
    pangomm
    pixman
)

# Depending, some packages listed may not be on the system so build a list
# to avoid error messages
REMOVE_LIST=()
for PACKAGE in ${PACKAGE_LIST[@]}
do
    rpm -q ${PACKAGE} &>/dev/null
    [[ $? -eq 0 ]] && REMOVE_LIST+=(${PACKAGE})
done

# Remove packages
yum -C -y remove --setopt="clean_requirements_on_remove=1" \
    ${REMOVE_LIST[@]} > $REDIRECT

exit 0
