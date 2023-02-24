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
foreach ($employee in $persons)
{
    $person  = @{};
    $person['ExternalId'] = $employee.personnelNumber
    $person['firstName'] = $employee.firstName
    $person['lastName'] = $employee.lastName
    $person['DisplayName'] = $employee.lastName + ", " + $employee.firstName
    $person['nationality'] = $employee.nationality
    $person['countryCode'] = $employee.countryCode
    $person['companyMobilePhoneNumber'] = $employee.companyMobilePhoneNumber
    $person['officePhoneNumber'] = $employee.officePhoneNumber
    $person['employmentType'] = $employee.employmentType
    
    if ([string]::IsNullOrEmpty($employee.birthday)) 
    { 
	    $person['birthday'] = $null 
    } else { 
        $birthdate = [datetime]::ParseExact($employee.birthday, 'yyyy-MM-dd', $null)
	    $person['birthday'] = Get-date($birthdate) -format 'o'; 
    }
    $person['email'] = $employee.email
    $person['gender'] = $employee.gender
    $person['addressstreet'] = $employee.address.street + " " + $employee.address.streetNumber
    $person['addressstreetNumber'] = $employee.address.streetNumber
    switch ($employee.address.countryCode)
    {
        "Germany" { $person['addresscountryCode'] = "DE" }
    }    
    $person['addresszipCode'] = $employee.address.zipCode
    $person['addresscity'] = $employee.address.city
    
    $person['Contracts'] = [System.Collections.ArrayList]@();
    $contract = @{};
    $contract['SequenceNumber'] = "1";
    $contract['position'] = $employee.position
    $contract['organizationUnitID'] = $employee.organizationUnit.number
    $contract['organizationUnitName'] = $employee.organizationUnit.name
    $contract['title'] = $employee.title
    $contract['joinDate'] = $employee.joinDate
    $contract['costCenterID'] = $employee.costCenter.number
    $contract['costCenterName'] = $employee.costCenter.name
    if ([string]::IsNullOrEmpty($employee.joinDate)) 
    { 
	    $contract['StartDate'] = $null 
    } else { 
        $startdate = [datetime]::ParseExact($employee.joinDate, 'yyyy-MM-dd', $null)
	    $contract['StartDate'] = Get-date($startdate) -format 'o'; 
    }
    if ([string]::IsNullOrEmpty($employee.leaveDate)) 
    { 
	    $contract['EndDate'] = $null 
    } else { 
        $enddate = [datetime]::ParseExact($employee.leaveDate, 'yyyy-MM-dd', $null)
	    $contract['EndDate'] = Get-date($enddate) -format 'o'; 
    }
    $contract['ManagerID'] = $employee.superior.personnelNumber    
        
    [void]$person['Contracts'].Add($contract);
    Write-Output ($person | ConvertTo-Json -Depth 20);
}

Write-Verbose -Verbose "Person import completed";