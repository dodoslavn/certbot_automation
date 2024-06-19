# Automation of renewing certbot certificates
This is set of scripts to automate renewal of certbot ( Lets Encrypt ) certificates for your domains.  
It supports only Apache2 web server. However it support multi instance ( if you have more apache2 servers/services/instances on one machine )  
This script will list all your virtualhosts, and perform following sequence:  
 - disable one virtualhost
 - takes the domain from it
 - create a new simple virtualhost with the same domain, BUT with working DocuemntRoot
 - enable it (this new one)
 - runs the certbot tool to renew the certificate
 - after renewal it will remove the new temporar virtualhost and enable again the original one

## Why am i doing it like this?
You might not have a chance to renew the certificate via DNS.  
If you want to renew the certificate via certbot, you NEED to have working "DocumentRoot", so when certbot will save the file into the folder of the website, you need to be able to retrieve it from outside via HTTP client. Which you CANNOT if you are running some service with Java and your web server serves just as a reverse proxy.  
You can run this script every week and it will just do all your virtualhosts.

## Included scripts
- add_domain.sh
  - this script is completely unrelated
  - its only used when you want to add new domain and generate certificate for it
  - it creates new basic virtualhost with your domain and generate the certificate for it
- main.sh
  - script which does the work
- update_all.sh
  - calls main.sh in a loop

## How to integrate with Jenkins  
I like to run this script from Jenkins, so i can see if it failed and rerun comfortably.  
Download this Git repo to the "CONF_DIR" path you set below and set the settings as you need.  
### How to configure Jenkins job:  
Source Code Management  
-- Git  
-- -- Repository URL  
-- -- -- https://github.com/dodoslavn/certbot_automation.git  
-- -- Branch Specifier  
-- -- -- */main  
-- Build Triggers  
-- -- Build periodically  
-- -- -- @weekly  
-- Build steps  
-- -- Execute shells  
-- -- -- export CONF_DIR=/your/directory/   
-- -- -- scripts/update_all.sh  
