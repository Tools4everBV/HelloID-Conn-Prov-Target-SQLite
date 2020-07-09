Add-Type -Path "C:\Program Files\System.Data.SQLite\2015\bin\System.Data.SQLite.dll";
$db = "C:\Temp\HelloID_Target.db";

#Initialize default properties
$success = $False;
$auditMessage = "granted succesfully";

$p = $person | ConvertFrom-Json;
$aRef = $accountReference | ConvertFrom-Json;
$pRef = $permissionReference | ConvertFrom-json;

#Retrieve account information for notifications
#$account = [PSCustomObject]@{}
if (-Not($dryRun -eq $True)) {
    Try {
        If (Test-Path $db) {
 
            $conn = New-Object -TypeName System.Data.SQLite.SQLiteConnection
            $conn.ConnectionString = "Data Source=$db"
            $conn.Open()
            $cmd = $conn.CreateCommand()

            $sql = "INSERT OR REPLACE INTO memberships (user_id,group_id)"
            $sql += " VALUES ('" + $aRef + "','" + $pRef.id + "');"

            $cmd.CommandText = $sql
            $cmd.ExecuteNonQuery() | Out-Null
            $cmd.Dispose()
            
            $conn.Close()
            
            $success = $True;
            $auditMessage = " succesfully";
        }
    }
    catch {
        $auditMessage = " not granted succesfully: General error";
    }
}

#build up result
$result = [PSCustomObject]@{ 
    Success             = $success;
    AuditDetails        = $auditMessage;
    AccountReference    = $aRef;
    Account             = $account;
};

Write-Output $result | ConvertTo-Json -Depth 10;