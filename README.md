# RAGVersionNumber

[![CI Status](http://img.shields.io/travis/raginmari/RAGVersionNumber.svg?style=flat)](https://travis-ci.org/raginmari/RAGVersionNumber)
[![Coverage Status](https://coveralls.io/repos/github/raginmari/RAGVersionNumber/badge.svg)](https://coveralls.io/github/raginmari/RAGVersionNumber)
[![Version](https://img.shields.io/cocoapods/v/RAGVersionNumber.svg?style=flat)](http://cocoapods.org/pods/RAGVersionNumber)
[![License](https://img.shields.io/cocoapods/l/RAGVersionNumber.svg?style=flat)](http://cocoapods.org/pods/RAGVersionNumber)
[![Platform](https://img.shields.io/cocoapods/p/RAGVersionNumber.svg?style=flat)](http://cocoapods.org/pods/RAGVersionNumber)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Written in Swift 3. Requires iOS 9 (deployment target).

## Installation

RAGVersionNumber is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RAGVersionNumber'
```

## How to use

Install the pod and import the module `RAGVersionNumber`.

The **core feature** of the pod is the convenient representation of version numbers (consisting of major, minor and patch components) by the type `VersionNumber`. The type has a number of initializers which facilitate creation of version numbers from different sources:

- `init(major:minor:patch:)`

 Sets explicit component values. The parameters `minor` and `patch` default to 0.

- `init?(string:)`

 Parses the given version number string, e.g. "1.2.3" (resulting in version number 1.2.3).

- `init?(bundle:)`

 Fetches the string value of `CFBundleShortVersionString` from the given application bundle.

The type `VersionNumber` conforms to `Comparable`. Moreover, there are a couple of convenience methods which check if a given version number is a patch, minor or major successor of the receiver of the call:

- `isPatchSuccessor(of:)`
- `isMinorSuccessor(of:)`
- `isMajorSuccessor(of:)`

See the respective documentation for details.

#### App Store version number

An additional feature of the pod is the lookup of the version number of an app (identified by its bundle identifier) in the App Store. In order to do so, create an instance of the class `AppStoreVersionNumberLookup`. The default parameters of its single initializer should be used.

The class has a single public method `performLookup(withBundleIdentifier:appStoreCountryCode:completion:)` which performs an asynchronous App Store lookup using the iTunes lookup API and passes the result to the given completion. An internet connection is obviously required.

You have to provide the bundle identifier of the app to the first parameter. The App Store country code is optional (its default is "us" i.e. the US App Store). If the app is not available in the App Store in the given country, the method will fail.

The third parameter receives the result of the asynchronous call which is of type `AppStoreVersionNumberLookup.Result` and contains either the version number or an error. See the documentation for the kinds of error to expect.

## Author

raginmari, reimar.twelker@web.de

## License

RAGVersionNumber is available under the MIT license. See the LICENSE file for more info.
