Add-Type -Path "C:\Program Files\System.Data.SQLite\2015\bin\System.Data.SQLite.dll";
$db = "C:\Temp\HelloID_Target.db";

try {
    If (Test-Path $db) {
        $conn = New-Object -TypeName System.Data.SQLite.SQLiteConnection
			
        $conn.ConnectionString = "Data Source=$db"
        $conn.Open()
	
        $cmd = $conn.CreateCommand() 
        $cmd.CommandText = "SELECT group_id,group_name FROM groups"
			
        $dataAdapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $cmd
        $data = New-Object System.Data.DataSet
  
        $dataAdapter.Fill($data) | Out-Null
        $table = $data.Tables[0]
  
        $memberships = @(); 
        ForEach ($item in $table) {
            $group = @{
                DisplayName    = $item.group_name;
                Identification = @{
                    Id = $item.group_id;
                }
            }
            $memberships += $group
        }        		
        $cmd.Dispose()
        $conn.Close()
    
        write-output $memberships | ConvertTo-Json -Depth 10;
    }
}
catch {
    $ex = $_.Exception
}