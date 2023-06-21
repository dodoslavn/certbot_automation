# certbot_automation
This is set of scripts to automate renewal of certbot ( lets encrypt ) certificates for your domains.
It supports only Apache2 web server. However it support multi instance ( if you have more apache2 servers/services/instances on one machine )
This script will list all your virtualhosts, and perform following sequence:
 - disable one virtualhost
 - takes the domain from it
 - creates a new simple virtualhost with the same domain, BUT with working RootDirectory
 - enable it (this new one)
 - runs the certbot tool to renew the certificate
 - after renewal it will remove the new virtual host and enable back the original one

# Why am i doing it like this?
You might not have a chance to renew the certificate via DNS.
If you want to renew the certificate via cert bot, you NEED to have working "RootDirectory", so when certbot will save the file into the root directory of the virtualhost, you need to be able to retrieve it from outside via HTTP client. Which you CANNOT if you are running some service with Java and your web server serves just as a reverse proxy.
You can run this script every week and it will just do all your virtualhosts.
