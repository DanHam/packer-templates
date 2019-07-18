#!/usr/bin/env bash
#
# Remove extraneous packages installed by Anaconda
set -o errexit

# Set verbose/quiet output based on env var configured in Packer template
[[ "${DEBUG}" = true ]] && redirect="/dev/stdout" || redirect="/dev/null"

# Logging for Packer
echo "Removing extraneous packages installed by Anaconda..."

# The following packages are installed by Anaconda regardless of any
# attempts to exclude them in the %packages section. In short Anaconda
# seems to ignore options and settings in the %packages section and does
# its own thing regardless...
package_list=(
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
    libss
    libthai
    libtiff
    libxcb
    libxshmfence
    linux-firmware
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
remove_list=()
for package in ${package_list[@]}
do
    if rpm -q ${package} &>/dev/null; then
        remove_list+=(${package})
    fi
done

# Remove packages if required
if [ "x${remove_list}" != "x" ]; then
    yum -C -y remove --setopt="clean_requirements_on_remove=1" \
        ${remove_list[@]} > ${redirect}
fi

exit 0
