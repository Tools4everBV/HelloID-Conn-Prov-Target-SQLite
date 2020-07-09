Add-Type -Path "C:\Program Files\System.Data.SQLite\2015\bin\System.Data.SQLite.dll";
$db = "C:\Temp\HelloID_Target.db";

Try {
    If (!(Test-Path $db)) {
    
        $conn = New-Object -TypeName System.Data.SQLite.SQLiteConnection
  
        $conn.ConnectionString = "Data Source=$db"
        $conn.Open()
  
        # TEXT as ISO8601 strings ('YYYY-MM-DD HH:MM:SS.SSS')
        $createTableQuery = "CREATE TABLE users (
                                    externalId CHAR(36) NOT NULL PRIMARY KEY,
                                    displayName        TEXT    NULL,
                                    firstName          TEXT    NULL,
                                    lastName           TEXT    NULL,
                                    userName           TEXT    NULL,
                                    title              TEXT    NULL,
                                    department         TEXT    NULL,
                                    startDate          TEXT    NULL,
                                    endDate            TEXT    NULL,
                                    manager            TEXT    NULL,
                                    enabled            TEXT    NULL
                                    );"  
  
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $createTableQuery
        $cmd.ExecuteNonQuery()
        ##$cmd.CommandText = $createUniqueIndex
        ##$cmd.ExecuteNonQuery()
  
        $cmd.Dispose()
        $conn.Close()
        Write-Output "Create database and table: Ok"
  
    } Else {
        Write-Output "DB Exists: Ok"
    }
  
} Catch {
    Write-Output "Could not create database: Error"
}