# jail-update
FreeNAS jail update script -- Upgrades pkgs, ports, locked packages from ports

This is a FreeNas upgrader script intended to perform an unattended upgrade of all the intalled packages and ports

This script became useful because of the use of Nextcloud within a FreeBSD Jail ran on FreeNAS
- In order to have a grade A openssh security (SSL Labs server test - https://www.ssllabs.com/ssltest/) it was necessary to install nginx, openssl, pecl-redis installed via portmaster which created packages from the port tree
- This necessitated these ports after installation be locked so that they were not automatically overwritten by the pkg manager when new upgrades to these particular packages
- This script first updates and upgrades all the packages installed via the pkg utility
- The port tree is then updated
- It then cross-references any updated ports with the ports currently locked
- If an upgrade for one of the locked ports/packages is present, the port/package will be unlocked, upgraded via portmaster using the ports tree, and then relocked
- Upgrades are intended to performed non-interactively
