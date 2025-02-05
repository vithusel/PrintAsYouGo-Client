# PrintAsYouGo-Client (PAYG)

## What is it? 

A python application designed to allow end users to submit files to print at a remote location including setting the standard print options and setting a delay. This allows them to submit something to print and not have to worry about taking their laptop / PC with them. 

## System Requirments
- Windows
- MacOS
- 
## Installation
The application when compiled is just run as a exe. There is no installer packaged with this and is designed to be installed via RMM
   
## Updating

Updates to PAYG is automatic and will alert user on launch. No admin priviledge is required to perform the update as the application itself does not perform any administrator functions. 

## Roadmap
Short Term Goals - 
1. Add support for office documents and not just PDF's
2. Allow users to view/ revoke their submitted prints with some form of ACL
3. Add a HASH check on update function to ensure security
4. Update the packager to automate creation of a installer rather then a direct executable. 

Long Term Goals - 
1. Allow installation options so deployments can be automated
2. Auto populate data based on running user information (submitter details)
3. Setup a controlled release system so users can opt to choose to release a file earlier.
4. Automate purge of printed files
5. On error notifications. Provide the user with options in the sent email to allow them to perform some recovery actions.

## Notice to users
Until otherwise mentioned on this repo. This software is in beta. 

## License

* Copyright (C) Vithusel Services - All Rights Reserved
* Unauthorized use, modification or distribution of this Software / Scripts, via any medium is strictly prohibited. 
* All content within this repository are proprietary and confidential. 
* All requests to be sent to Vithurshan Selvarajah <vit@vithuselservices.co.uk>


## Disclaimer

Several components of this software / script call home to update and provide metrics.

For support, email support@vithuselservices.co.uk
