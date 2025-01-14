#!/bin/bash

# place edge .deb in same directory as this script
# modify the below if you update the edge debian
edge_installer="microsoft-edge-stable_115.0.1901.188-1_amd64.deb"

# checks for the .deb in the same folder and installs it if it is found
install_microsoft_edge() {
    if [ -f "$edge_installer" ]; then 
        printf "Installing Microsoft Edge ... \n"
        sudo dpkg -i $edge_installer
    fi
}

install_azuread() {
    sudo apt install libpam-aad libnss-aad
    sudo pam-auth-update --enable mkhomedir
    printf "Libraries for Azure AD authentication & Intune installed. \n"
    printf "Please note: You must create an App Registration on Azure AD and: \n"
    printf "- Enable \"Allow public client flows\" under \"App Registrations -> <Name of your App> -> Authentication\" and,\n"
    printf "- Enable \"Granted admin consent for [Tenant Name]\" under \"API permissions\"\n"
    printf "- Modify /etc/aad.conf and add the tenant ID and App ID (uncommenting the lines)\n"
    printf "Once the above is complete, reboot and login with the AzureAD account\n"
}

# evaluate the OS and setup the proper repo accordingly
eval_OS() {
    sudo apt install curl -y
    if [ $2 == "20.04" ]; then
        printf "Installing Intune for Ubuntu 20.04 LTS \n"
        curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
        sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
        sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/20.04/prod focal main" > /etc/apt/sources.list.d/microsoft-ubuntu-focal-prod.list'
        sudo apt install intune-portal
    elif [ $2 == "22.04" ]; then
        printf "Installing Intune for Ubuntu 22.04 LTS \n"
        curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
        sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
        sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" > /etc/apt/sources.list.d/microsoft-ubuntu-jammy-prod.list'
        sudo apt install intune-portal
    elif [ $2 == "23.04" ]; then
        printf "Installing Intune and Azure AD libararies for Ubuntu 23.04 LTS\n"
        curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
        sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
        sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/23.04/prod lunar main" > /etc/apt/sources.list.d/microsoft-ubuntu-lunar-prod.list'
        sudo apt install intune-portal
        install_azuread
    fi
    sudo rm microsoft.gpg
    install_microsoft_edge
}

main() {
    ubuntu_version="$(lsb_release --release)"
    eval_OS $ubuntu_version
}

main "$@"