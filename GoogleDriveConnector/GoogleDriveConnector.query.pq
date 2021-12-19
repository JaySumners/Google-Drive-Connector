// Use this file to write queries to test your data connector
let
    // This is not a legifimate id. Put in an id to which you have access.
    doc_id = "1JdlZDYy49CKsuKjXbcW3Jvz5-QOOLrS8274Y",
    test_connector = GoogleDrive.Contents(doc_id)
in
    test_connector