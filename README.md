# Power BI - Google Drive Connector

## Overview
In the absence of an official connector from Power BI to Google Drive, the custom connector in this repository serves the minimal purpose of reading Google Sheets, Excel files, and CSVs held on Google Drive. 

The custom connector in `GoogleDriveConnector` generates a `.mez` file that can be imported into Power BI. The WiX project in `GoogleDriveConnectorInstaller` can be used to generate an MSI installer for the `.mez` file. 

## Installation
In order to compile and use the `.mez` file you'll need at least:
+ Power BI
+ Google Drive API client id and client secret
+ Visual Studio (or msbuild)
+ Power Query SDK (https://marketplace.visualstudio.com/items?itemName=Dakahn.PowerQuerySDK)

To compile the WiX project into a MSI installer:
+ A `.mez` file
+ WiX extension for Visual Studio (https://wixtoolset.org/releases/)

Once you have the repo on your local machine, you'll need to create two (2) files in `GoogleDriveConnector/config`. These are `client_id` and `client_secret` that hold your Google Drive API client id and client secret respectively. 

IMPORTANT: These files are included in the .gitignore. If you name them differently, not only will the connector not work, but you risk exposing your credentials. Additionally, do not store `.mez` files on GitHub or installers for them as they may contain unencrypted credentials.

## Usage
In order to use the custom connector, you'll need to enable them in Power BI under Options.

The connector exports only a single function `GoogleDrive.Contents()` and documentation is available in the connector and the function. The only argument for this function is the `id` of the document on Google Drive. 

You can find this `id` in any share link or in the document's URL.

## Limitations
The connector uses a from-scratch funtion to parse Google Sheets, but uses `Csv.Document()` and `Excel.Workbook()` to read `.csv` and `.xlsx` files respectively. Since it served the purpose at the time, the exported function `GoogleDrive.Contents()` does not accept or pass along additional arguments that these functions may use.