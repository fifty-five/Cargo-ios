# Cargo-ios - Change Log
---
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [v0.1.2] - 2016-04-06
### Added
* changelog.md : Init the changelog file of the project
* FEATURE - Tune Handler : Adding 2 methods (identify and tagEvent) which were not implemented in Tune.m file

### Changed
* FEATURE - update FacebookSDK : updating the version of the Facebook SDK from "4.9.0" to "4.10.1"
* FEATURE - update MAT to Tune : we have simply changed the name of SDK from "MobileAppTracking" to "Tune" as updating the version number from "3.13.0" to "4.1.0"

### Removed
* FIX removing Accengage code and dependancies
* FIX removing Accengage tests

### Fixed
* FIX - the logger was designed to work with FIFTagHandler, not Cargo

## [v0.1.1] - 2016-03-29
### Added
* Accengage Handler : Try to init the accengage handler based on Accengage SDK v4.X
