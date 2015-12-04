# Cargo-ios

![Build Status](https://travis-ci.org/fifty-five/Cargo-ios.svg?branch=master)


## Mission
Cargo is a tool developed by [fifty-five](http://fifty-five.com).
It allows to integrate third party SDK in Google Tag Manager.

#### Current supported SDK
- Facebook
- Tune - Attribution Analytics
- AT Internet

#### Google Tag Manager
Google Tag Manager enables developers to change configuration values in their mobile applications using the Google Tag Manager interface without having to rebuild and resubmit application binaries to app marketplaces.



## Install Cargo in your iOS app

##### 1) add to your app Cargo and Google Tag Manager.
It is very easy if you are using Cocoapods.
Simply add this pod :
```
pod 'Cargo', :git => 'https://github.com/fifty-five/Cargo-ios.git'
```

By default it will add all supported handlers to your application.
To install only Facebook for instance,
```
pod 'Cargo/Facebook', :git => 'https://github.com/fifty-five/Cargo-ios.git'
```

##### 2) GTM set up
You can follow GTM set up [there](https://developers.google.com/tag-manager/ios/v3/

##### 3) Cargo set up
Once GTM is installed, Cargo set up is one line.
```
[[Cargo sharedHelper] initTagHandlerWithManager:self.tagManager
                                                  container:self.container];
[[Cargo sharedHelper] setLaunchOptions:launchOptions];
[[Cargo sharedHelper] registerHandlers];
```


## Universal DataLayer

Cargo used an universal DataLayer that fits all tools. Do worry about refactor your tracking again.
Here are a list of dataLayer constants used

#### Tracker DataLayer

| Name            | Definittion   |
|----------       |:-------------|
| **Tracker DataLayer** |
| enableDebug     |  Enable debug mode for your tracker |
| enableOptOut    |  Opt-out tracking for a specific customer |
| disableTracking |  Disable all tracking |
| dispatchPeriod   |  Define an interval of time to dispatch hits |
| **Screen DataLayer** |
| screenName     |  Name of the screen |
| **Event DataLayer** |
| eventName     |  Name of the event |
| **User DataLayer** |
| userGoogleId     |  Google Id of the user |
| userFacebookId     |  Facebook Id of the user |
| userId     |  CRM Id of the user |
| **Transaction DataLayer** |
| transactionId       |  A unique Id of the transaction |
| transactionTotal    |  Total amount of the transaction |
| transactionProducts |  An array of products in the transaction |
| **Product DataLayer** |
| name                |  Name of the product |
| sku                 | Sku of the product |
| price               |  Price of the product |
| category            |  Category of the product |
| quantity            |  Quantity of the product |
