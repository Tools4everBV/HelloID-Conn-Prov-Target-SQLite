Add-Type -Path "C:\Program Files\System.Data.SQLite\2015\bin\System.Data.SQLite.dll";
$db = "C:\Temp\HelloID_Target.db";

#Initialize default properties
$p = $person | ConvertFrom-Json;
$success = $False;
$auditMessage = "Account for person " + $p.DisplayName + " not created succesfully";

#Change mapping here
$account = [PSCustomObject]@{
    displayName = $p.DisplayName;
    firstName   = $p.Name.NickName;
    lastName    = $p.Name.FamilyName;
    userName    = $p.UserName;
    externalId  = $p.ExternalId;
    title       = $p.PrimaryContract.Title.Name;
    department  = $p.PrimaryContract.Department.DisplayName;
    startDate   = $p.PrimaryContract.StartDate;
    endDate     = $p.PrimaryContract.EndDate;
    manager     = $p.PrimaryManager.DisplayName;
    enabled     = $False;
}

#correlation
$correlationField = 'externalId';
$correlationValue = $p.ExternalID;

Try {
    If (Test-Path $db) {
        #Do not execute when running preview
        if (-Not($dryRun -eq $True)) {  
            $create = $True;

            $conn = New-Object -TypeName System.Data.SQLite.SQLiteConnection
            $conn.ConnectionString = "Data Source=$db"
            $conn.Open()
            $cmd = $conn.CreateCommand()

            $cmd.CommandText = "SELECT $correlationField FROM users WHERE $correlationField = " + $correlationValue;
            $dataAdapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $cmd
            $data = New-Object System.Data.DataSet

            $rowCount = $dataAdapter.Fill($data)
            #Check correlation before create
            if ($rowCount -gt 0) {
                $create = $False;
                $accountReference = $data.Tables[0].$correlationField 
                $success = $True;
                $auditMessage = "with correlation for record $($correlationField + " = " + $accountReference)";
            }

            if ($create) {
                $sql = "INSERT OR REPLACE INTO users ($correlationField,displayName,firstName,lastName,userName,title,department,startDate,endDate,manager,enabled)"
                $sql += " VALUES ('" + $correlationValue + "','" + $p.DisplayName + "','" + $p.Name.NickName + "','" + $p.Name.FamilyName + "','" + $p.UserName + "','" + $p.PrimaryContract.Title.Name + "','" + $p.PrimaryContract.Department.DisplayName + "','" + $p.PrimaryContract.StartDate + "','" + $p.PrimaryContract.EndDate + "','" + $p.PrimaryManager.DisplayName + "','" + $False + "');"
                $accountReference = $p.ExternalId;   
                $cmd.CommandText = $sql
                $cmd.ExecuteNonQuery() | Out-Null
                $success = $True;
                $auditMessage = " succesfully";
            }
            $cmd.Dispose()
            $conn.Close()
        }
    }
}
catch {
    $auditMessage = " not created succesfully: General error";
}

#build up result
$result = [PSCustomObject]@{ 
    Success          = $success;
    AccountReference = $accountReference;
    AuditDetails     = $auditMessage;
    Account          = $account;

   	# Optionally return data for use in other systems
    ExportData = [PSCustomObject]@{
        displayName = $account.DisplayName;
        userName = $account.UserName;
		externalId = $accountReference;
		enabled = $account.enabled;
    };
};
Write-Output $result | ConvertTo-Json -Depth 10;