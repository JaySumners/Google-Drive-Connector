[Version = "0.0.1"]
section GoogleDrive;

////
// Versioning
////
/*
The first number is the 'major' version, which will indicate breaking changes. 
This number should be incremented whenever users will be required to potentially 
rebuild reports due to massive connector rearchitecture or removal of features.

The second number is the 'minor' version, which indicates addition of functionality. 
These will generally not be breaking but might cause peripheral side effects. 
This number should be incremented whenever functionality is added to the connector.

The final number is the 'patch' version, which indicates minor tweaks and fixes to connectors. 
This is the version that will change the most often, and should be incremented whenever 
you realize small tweaks of a connector to the public.

The addition of 9000 number indicate a development version between updates.
*/

////
// Imported Functions
////

// Load common library functions
Extension.LoadFunction = (name as text) =>
    let
        binary = Extension.Contents(name),
        asText = Text.FromBinary(binary)
    in
        Expression.Evaluate(asText, #shared);

// OAuth Flow
Flow = Extension.LoadFunction("Library.OAuth.Flow.pqm");

// Forking Functions
File.MimeType = Extension.LoadFunction("File.MimeType.pqm");

// Content Files
Sheet.Contents = Extension.LoadFunction("Sheet.Contents.pqm");
Flat.Contents = Extension.LoadFunction("Flat.Contents.pqm");

// Google Sheet Parsing
Sheet.ToNavigationTable = Extension.LoadFunction("Sheet.ToNavigationTable.pqm");

////
// Exported functions
////

[DataSource.Kind="GoogleDrive", Publish="GoogleDrive.Contents.Publish"]
shared GoogleDrive.Contents = Value.ReplaceType(Gdrive.Contents, Type_Main);

// Documentation
Type_Main = type function(
    fileId as (type text meta [
        Documentation.FieldCaption = "File ID",
        Documentation.FieldDescription = "File ID or GUID from Google Drive. This can be obtained from a share link.",
        Documentation.SampleValues = {"1z_U64oydfrBmYOewcfHnXRJevtOljplh", "15b12Qt3_-vCvS0WxMcyDv5IKezrpSD1Ten_EFDjG-Ro"}
    ]))
    as table meta [
        Documentation.Name = "Google Drive File",
        Documentation.LongDescription = "Load a comma-delimited file, Excel file, or Google Sheet from Google Drive. Other delimiters not yet supported.",
        Documentation.Examples = {[
            Description = "Getting the File ID (fileId) from a share link. Google Drive Desktop: Share with Google Drive -> Copy Link",
            Code = "Share link: ""https://drive.google.com/file/d/1z_U64oydfrBmYOewcfHnXRJevtOljplh/view?usp=sharing""",
            Result = "1z_U64oydfrBmYOewcfHnXRJevtOljplh"
        ],[
            Description = "Getting the File ID (fileId) from a copy link. This will vary a bit between file types. Google Drive Desktop: Copy Link to Clipboard",
            Code = "Copy link: ""https://drive.google.com/open?id=1z_U64oydfrBmYOewcfHnXRJevtOljplh&authuser={some user}&usp=drive_fs""",
            Result = "1z_U64oydfrBmYOewcfHnXRJevtOljplh"     
        ],[
            Description = "Using the File ID in a function",
            Code = "GoogleDrive.Contents(""1z_U64oydfrBmYOewcfHnXRJevtOljplh"")",
            Result = "#table()" 
        ]}
    ];

// Data Source Kind description
// Create a Data Source Kind definition that declares it supports OAuth.
GoogleDrive = [
    TestConnection = (dataSourcePath) => 
        let
            json = Json.Document(dataSourcePath),
            fileId = json[fileId]
        in
            {"GoogleDrive.Contents", fileId},
    Authentication = [
        OAuth = [
            StartLogin = Flow[StartLogin],
            FinishLogin = Flow[FinishLogin],
            Refresh = Flow[Refresh]
        ]
    ],
    Label = Extension.LoadString("AuthenticationLabel")
];

// Data Source UI publishing description
GoogleDrive.Contents.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "Google Drive File", "Imports a comma-separated (csv) file, Excel file, or Google Sheets from Google Drive. GoogleDrive.Contents()" },
    SourceImage = GoogleDrive.Icons,
    SourceTypeImage = GoogleDrive.Icons
];

GoogleDrive.Icons = [
    Icon16 = { Extension.Contents("GoogleDrive16.png"), Extension.Contents("GoogleDrive20.png"), Extension.Contents("GoogleDrive24.png"), Extension.Contents("GoogleDrive32.png") },
    Icon32 = { Extension.Contents("GoogleDrive32.png"), Extension.Contents("GoogleDrive40.png"), Extension.Contents("GoogleDrive48.png"), Extension.Contents("GoogleDrive64.png") }
];


////
// Internal Functions
////

Gdrive.Contents = (fileId as text) =>
    let
        fileType = File.MimeType(fileId),
        Source =
            if fileType = "text/csv" then Gdrive.Csv.Document(fileId)
            else if fileType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" then Gdrive.Excel.Workbook(fileId)
            else if fileType = "application/vnd.google-apps.spreadsheet" then Gdrive.Sheets.Workbook(fileId)
            else error [ 
                Reason = "FileTypeNotFound", 
                Message = "'File Type' must be selected", 
                Detail = "'File Type'" 
            ],
        Test = Gdrive.Test(fileId),
        CredTest = Extension.CurrentCredential()
    in
        Source;

Gdrive.Csv.Document = (fileId as text) =>
    let
        // Provide the media content url
        //media_url = "https://www.googleapis.com/drive/v3/files/" & fileId & "?alt=media",
        // byte_array is equivalent to File.Contents() in M.
        byte_array = Flat.Contents(fileId),
        csv = Csv.Document(byte_array)
    in
        csv;

Gdrive.Excel.Workbook = (fileId as text) =>
    let
        // Provide the media content url
        //media_url = "https://www.googleapis.com/drive/v3/files/" & fileId & "?alt=media",
        // byte_array is equivalent to File.Contents() in M.
        byte_array = Flat.Contents(fileId),
        workbook = Excel.Workbook(byte_array, null, true)
    in
        workbook;

Gdrive.Sheets.Workbook = (fileId as text) =>
    let
        sheets = Sheet.Contents(fileId),
        navTable = Sheet.ToNavigationTable(sheets)
    in
        navTable;

Gdrive.Test = (filedId as text) =>
    let
        sheets = Sheet.Contents(filedId),
        sheet = sheets{0},
        columnCount = sheet[properties][gridProperties][columnCount],
        data = sheet[data]{0},
        rows = data[rowData],
        row = rows{130},
        cells = row[values],
        cell = cells{0},
        cell_data =  if Record.HasFields(cell, "effectiveValue")
                        then Record.FieldValues(cell[effectiveValue]){0}
                        else null
    in
        columnCount;
