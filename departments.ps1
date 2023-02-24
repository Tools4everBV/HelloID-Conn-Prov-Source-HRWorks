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
$response = Invoke-WebRequest -Method GET -Uri "$($c.apiurl)/persons/master-data" -Headers $authorization
$persons = ($response.content | ConvertFrom-Json).persons

foreach ($header in $response.Headers.Link.split(",")) {
    if ($header -match '<(.*)>; rel="last"') {
        $url = $matches[1] 
        $null = $url -match '.*page=(.*)'
        $pagecount = $matches[1]
        for ($i=2; $i -le $pagecount; $i++)
        {
            $response = Invoke-WebRequest -Method GET -Uri "$($c.apiurl)/persons/master-data/?page=$i" -Headers $authorization
            $persons += ($response.content | ConvertFrom-Json).persons
        }
    }
} 
$departments  = [System.Collections.ArrayList]@();
foreach ($employee in $persons)
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