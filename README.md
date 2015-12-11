# HangOutTinder
Playing around with Objective-C, understanding Obj-C syntax and semantics by making a simple user interacting app.

ps. iOS Programming class project. 

## Purpose 
By using this app, users are allowed to find other app users around you in 1 kilometer. Users will then decide if they want to do anything with new friends, by filling out simple form in the app, users will be able to reach each other.

## Motivation
Sometimes a flash through our mind make us want to do something. At that immediate moment,  we might need some random people around and we can hang out! This app is here for those kind of moments. 

## API Reference & Frameworks
1. Apple: MapKit Framework, CoreLocation Framework, Security Framework, SystemConfiguration Framework, CFNetwork Framework.
	Reference: https://developer.apple.com/library/ios/navigation/
2. Firebase: https://github.com/firebase , https://www.firebase.com
3. GeoFire: https://github.com/firebase/geofire-objc

## Installation & iOS SDK
I am using XCode 7.1 and iOS 8.4 for this project. You can find XCode in App Store and direct download SDKs through XCode

## Guarantee
Users will be creating temporary account through the form in the app, you will be ask to allow location and your location will be temporarily stored into Firebase database. After leaving current page, all your data will be wiped out from Firebase.
