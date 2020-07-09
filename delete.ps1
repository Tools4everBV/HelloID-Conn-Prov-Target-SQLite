Add-Type -Path "C:\Program Files\System.Data.SQLite\2015\bin\System.Data.SQLite.dll";
$db = "C:\Temp\HelloID_Target.db";

#Initialize default properties
$p = $person | ConvertFrom-Json;
$accountReference = $accountReference | ConvertFrom-Json;
$success = $False;
$auditMessage = " not removed succesfully";

#Change mapping here
$account = [PSCustomObject]@{
}

Try {
    If (Test-Path $db) {
		if(-Not($dryRun -eq $True)){  
			$conn = New-Object -TypeName System.Data.SQLite.SQLiteConnection
			$conn.ConnectionString = "Data Source=$db"
			$conn.Open()
			$cmd = $conn.CreateCommand()
	
			$sql = "DELETE FROM users"
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
		$auditMessage = " not removed succesfully: General error";
}

#build up result
$result = [PSCustomObject]@{ 
	Success= $success;
	AccountReference= $accountReference;
	AuditDetails=$auditMessage;
	Account = $account;
	
	# Optionally return data for use in other systems
    ExportData = [PSCustomObject]@{
    };
};
Write-Output $result | ConvertTo-Json -Depth 10;