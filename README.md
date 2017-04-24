# auth0-ro-mfa-ios

- A project showing how to use MFA within a mobile application with the Auth0 Resource Owner Password flows


## Pre Requisites
- User signed up with Auth0 within a realm
- User registers for MFA - Either Guardian with Push, Guardian with SMS or Google Authenticator with TOTP via their Auth0 Account
 
 
- The required settings are created within Auth0.plist and need to be set
```
<dict>
	<key>audience</key>
	<string>API_AUDIENCE</string>
	<key>realm</key>
	<string>AUTH0_REALM_CONNECTION</string>
	<key>clientId</key>
	<string>CLIENT_ID</string>
	<key>domain</key>
	<string>AUTH0_DOMAIN</string>
</dict>
```

## How to use
- Download or clone the project
- Go to the project directory and run `pod install` - This will install all the required dependencies from the pod file
- Open the application in xcode by running `open Auth0Mfa.xcworkspace`
- Buld the application
- Run the application and login with a user that has one or more of Guardian with Push, Guardian with SMS or Google Authenticator with TOTP enabled for their account and follow the steps to see MFA working with RO endpoint. If the MFA Works you will be issued an id_token and access_token that you can see in the app


