﻿Add-Type -Path "C:\Program Files\System.Data.SQLite\2015\bin\System.Data.SQLite.dll";
$db = "C:\Temp\HelloID_Target.db";

#Initialize default properties
$p = $person | ConvertFrom-Json;
$accountReference = $accountReference | ConvertFrom-Json;
$success = $False;
$auditMessage = "Account for person " + $p.DisplayName + " not disabled succesfully";

#Change mapping here
$account = [PSCustomObject]@{
    enabled = $False;
}

Try {
    If (Test-Path $db) {
		if(-Not($dryRun -eq $True)){
			$conn = New-Object -TypeName System.Data.SQLite.SQLiteConnection
			$conn.ConnectionString = "Data Source=$db"
			$conn.Open()
			$cmd = $conn.CreateCommand()
	
			$sql = "UPDATE users SET enabled = '" + $account.enabled + "'"
			$sql += " WHERE externalId = '$accountReference';"
			
			$cmd.CommandText = $sql
			$cmd.ExecuteNonQuery() | Out-Null
			$cmd.Dispose()
			$conn.Close()
		}
        $success = $True;
        $auditMessage = " succesfully";
    }
} catch{
		$auditMessage = " not disabled succesfully: General error";
}

#build up result
$result = [PSCustomObject]@{ 
	Success= $success;
	AccountReference= $accountReference;
	AuditDetails=$auditMessage;
	Account = $account;
	
	# Optionally return data for use in other systems
    ExportData = [PSCustomObject]@{
        displayName = $account.DisplayName;
        userName = $account.UserName;
		externalId = $accountReference;
		enabled = $account.enabled;
    };
};
Write-Output $result | ConvertTo-Json -Depth 10;