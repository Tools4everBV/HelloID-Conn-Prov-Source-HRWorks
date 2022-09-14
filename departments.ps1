$c = $configuration | ConvertFrom-Json;
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
$AuthParams = @{
    accessKey=$c.clientid;
    secretAccessKey=$c.clientsecret;
};
$header = [ordered]@{
    Accept = "application/json";
    'Content-Type' = "application/json";
}
$response = Invoke-RestMethod -Method Post -Uri "$($c.apiurl)/authentication" -Body ($AuthParams | ConvertTo-Json) -Headers $header
$accessToken = $response.token

$authorization = [ordered]@{
    Authorization = "Bearer $accesstoken";
    'Content-Type' = "application/json";
    Accept = "application/json";
}
$response = Invoke-RestMethod -Method GET -Uri "$($c.apiurl)/persons/master-data" -Headers $authorization

$departments  = [System.Collections.ArrayList]@();
foreach ($employee in $response.persons)
{
    $department  = @{};
    $department['ExternalId'] = $employee.organizationUnit.number
    $department['Name'] = $employee.organizationUnit.name
    $department['DisplayName'] = $employee.organizationUnit.name
    if ([string]::IsNullOrEmpty($department['ExternalId']) -eq $true)
    {
        $department['ExternalId'] = $department['Name']
    }
    if ($departments.Contains($department['ExternalId']) -eq $false)
    {
        Write-Output ($department | ConvertTo-Json -Depth 20);
        $departments += $department['ExternalId'];
    }
}

Write-Verbose -Verbose "Department import completed";