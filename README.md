# HelloID-Conn-Prov-Source-HRWorks

| :information_source: Information |
|:---------------------------|
| This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.       |
<br />
<p align="center">
  <img src="https://www.tools4ever.nl/connector-logos/hrworks-logo.png">
</p>
<br />

HR System hrworks.de

## Introduction

This connector retrieves HR data from the HRWorks API.

# HRWorks API Documentation
https://developers.hrworks.de/2.0/general-information

## Getting started
To Start with the sync you need to get your API Credentials

### Configuration Settings
Use the configuration.json in the Source Connector on "Custom connector configuration". You can use the created credentials on the Configuration Tab to set the accessKey and secretAccessKey.

### Mappings
Use the personMapping_employment.json and contractMapping_employment.json Mappings as example and remove the Fields you don't want

# HelloID Docs
The official HelloID documentation can be found at: https://docs.helloid.com/
