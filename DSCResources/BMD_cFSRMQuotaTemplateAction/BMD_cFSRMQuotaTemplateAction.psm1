data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
GettingActionMessage=Getting FSRM Quota Template Action for {2} "{0}" threshold {1}.
ActionExistsMessage=FSRM Quota Template Action for {2} "{0}" threshold {1} exists.
ActionNotExistMessage=FSRM Quota Template Action for {2} "{0}" threshold {1} does not exist.
SettingActionMessage=Setting FSRM Quota Template Action for {2} "{0}" threshold {1}.
EnsureActionExistsMessage=Ensuring FSRM Quota Template Action for {2} "{0}" threshold {1} exists.
EnsureActionDoesNotExistMessage=Ensuring FSRM Quota Template Action for {2} "{0}" threshold {1} does not exist.
ActionCreatedMessage=FSRM Quota Template Action for {2} "{0}" threshold {1} has been created.
ActionUpdatedMessage=FSRM Quota Template Action for {2} "{0}" threshold {1} has been updated.
ActionRemovedMessage=FSRM Quota Template Action for {2} "{0}" threshold {1} has been removed.
ActionNoChangeMessage=FSRM Quota Template Action for {2} "{0}" threshold {1} required not changes.
ActionWrittenMessage=FSRM Quota Template Action for {2} "{0}" threshold {1} has been written.
TestingActionMessage=Testing FSRM Quota Template Action for {2} "{0}" threshold {1}.
ActionPropertyNeedsUpdateMessage=FSRM Quota Template Action for {2} "{0}" threshold {1} {3} is different. Change required.
ActionDoesNotExistButShouldMessage=FSRM Quota Template Action for {2} "{0}" threshold {1} does not exist but should. Change required.
ActionExistsAndShouldNotMessage=FSRM Quota Template Action for {2} "{0}" threshold {1} exists but should not. Change required.
ActionDoesNotExistAndShouldNotMessage=FSRM Quota Template Action for {2} "{0}" threshold {1} does not exist and should not. Change not required.
QuotaTemplateNotFoundError=FSRM Quota Template "{0}" not found.
QuotaTemplateThresholdNotFoundError=FSRM Quota Template "{0}" threshold {1} not found.
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [ValidateRange(0,100)]
        [System.Uint32]
        $Percentage,
        
        [parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type
    )
    
    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingActionMessage) `
            -f $Name,$Percentage,$Type
        ) -join '' )

    
    $Result = Get-Action `
        -Name $Name `
        -Percentage $Percentage `
        -Type $Type

    $returnValue = @{
        Name = $Name
        Percentage = $Percentage
        Type = $Type
    }
    if ($Result.ActionIndex -eq $null)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ActionDoesNotExistMessage) `
                -f $Name,$Percentage,$Type
            ) -join '' )

        $returnValue += @{
            Ensure = 'Absent'
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.ActionExistsMessage) `
                -f $Name,$Percentage,$Type
            ) -join '' )
        $Action = $Result.SourceObjects[$Result.SourceIndex].Action[$Result.ActionIndex]
        $returnValue += @{
            Ensure = 'Present'
            Subject = $Action.Subject
            Body = $Action.Body
            MailBCC = $Action.MailBCC
            MailCC = $Action.MailCC
            MailTo = $Action.MailTo
            Command = $Action.Command
            CommandParameters = $Action.CommandParameters
            KillTimeOut = $Action.KillTimeOut
            RunLimitInterval = $Action.RunLimitInterval
            SecurityLevel = $Action.SecurityLevel
            ShouldLogError = $Action.ShouldLogError
            WorkingDirectory = $Action.WorkingDirectory
            EventType = $Action.EventType
            ReportTypes = $Action.ReportTypes
        }
    }

    $returnValue
} # Get-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [ValidateRange(0,100)]
        [System.Uint32]
        $Percentage,
        
        [parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.String]$Subject,
        [System.String]$Body,
        [System.String]$MailTo,
        [System.String]$MailCC,
        [System.String]$MailBCC,
        [ValidateSet('None','Information','Warning','Error')]
        [System.String]$EventType,
        [System.String]$Command,
        [System.String]$CommandParameters,
        [System.Int32]$KillTimeOut,
        [System.Int32]$RunLimitInterval,
        [ValidateSet('None','LocalService','NetworkService','LocalSystem')]
        [System.String]$SecurityLevel,
        [System.Boolean]$ShouldLogError,
        [System.String]$WorkingDirectory,
        [System.String[]]$ReportTypes
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.SettingActionMessage) `
            -f $Name,$Percentage,$Type
        ) -join '' )

    # Remove any parameters that can't be splatted.
    $PSBoundParameters.Remove('Name')
    $PSBoundParameters.Remove('Percentage')
    $PSBoundParameters.Remove('Ensure')

    # Lookup the existing action and related objects
    $Result = Get-Action `
        -Name $Name `
        -Percentage $Percentage `
        -Type $Type

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureActionExistsMessage) `
                -f $Name,$Percentage,$Type
            ) -join '' )

        $NewAction = New-FSRMAction @PSBoundParameters -ErrorAction Stop

        if ($Result.ActionIndex -eq $null)
        {
            # Create the action
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionCreatedMessage) `
                    -f $Name,$Percentage,$Type
                ) -join '' )
        }
        else
        {
            # The action exists, remove it then update it
            $Result.SourceObjects[$Result.SourceIndex].Action.RemoveAt($Result.ActionIndex)

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionUpdatedMessage) `
                    -f $Name,$Percentage,$Type
                ) -join '' )
        }

        $Result.SourceObjects[$Result.SourceIndex].Action.Add($NewAction)
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureActionDoesNotExistMessage) `
                -f $Name,$Percentage,$Type
            ) -join '' )

        if ($Result.ActionIndex -eq $null)
        {
            # The action doesn't exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionNoChangeMessage) `
                    -f $Name,$Percentage,$Type
                ) -join '' )
            return
        }
        else
        {
            # The Action exists, but shouldn't remove it
            $Result.SourceObjects[$Result.SourceIndex].Action.RemoveAt($Result.ActionIndex)

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionRemovedMessage) `
                    -f $Name,$Percentage,$Type
                ) -join '' )
        } # if
    } # if
    # Now write the actual change to the appropriate place
    Set-Action `
        -Name $Name `
        -ResultObject $Result

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.ActionWrittenMessage) `
            -f $Name,$Percentage,$Type
        ) -join '' )
} # Set-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [ValidateRange(0,100)]
        [System.Uint32]
        $Percentage,
        
        [parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [System.String]$Subject,
        [System.String]$Body,
        [System.String]$MailTo,
        [System.String]$MailCC,
        [System.String]$MailBCC,
        [ValidateSet('None','Information','Warning','Error')]
        [System.String]$EventType,
        [System.String]$Command,
        [System.String]$CommandParameters,
        [System.Int32]$KillTimeOut,
        [System.Int32]$RunLimitInterval,
        [ValidateSet('None','LocalService','NetworkService','LocalSystem')]
        [System.String]$SecurityLevel,
        [System.Boolean]$ShouldLogError,
        [System.String]$WorkingDirectory,
        [System.String[]]$ReportTypes
    )
    # Could check report types here
    # @('DuplicateFiles','FilesByFileGroup','FilesByOwner','FilesByProperty','LargeFiles','LeastRecentlyAccessed','MostRecentlyAccessed','QuotaUsage')

    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.SettingActionMessage) `
            -f $Name,$Percentage,$Type
        ) -join '' )

    # Lookup the existing action and related objects
    $Result = Get-Action `
        -Name $Name `
        -Percentage $Percentage `
        -Type $Type

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureActionExistsMessage) `
                -f $Name,$Percentage,$Type
            ) -join '' )

        if ($Result.ActionIndex -eq $null)
        {
            # The action does not exist but should
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionDoesNotExistButShouldMessage) `
                    -f $Name,$Percentage,$Type
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
        else
        {
            # The action exists - check it
            $Action = $Result.SourceObjects[$Result.SourceIndex].Action[$Result.ActionIndex]

            #region Parameter Checks
            if (($PSBoundParameters.ContainsKey('Subject')) `
                -and ($Action.Subject -ne $Subject))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'Subject'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Body')) `
                -and ($Action.Body -ne $Body))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'Body'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailBCC')) `
                -and ($Action.MailBCC -ne $MailBCC))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'MailBCC'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailCC')) `
                -and ($Action.MailCC -ne $MailCC))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'MailCC'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailTo')) `
                -and ($Action.MailTo -ne $MailTo))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'MailTo'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Command')) `
                -and ($Action.Command -ne $Command))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'Command'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('CommandParameters')) `
                -and ($Action.CommandParameters -ne $CommandParameters))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'CommandParameters'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('KillTimeOut')) `
                -and ($Action.KillTimeOut -ne $KillTimeOut))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'KillTimeOut'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('RunLimitInterval')) `
                -and ($Action.RunLimitInterval -ne $RunLimitInterval))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'RunLimitInterval'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('SecurityLevel')) `
                -and ($Action.SecurityLevel -ne $SecurityLevel))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'SecurityLevel'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('ShouldLogError')) `
                -and ($Action.ShouldLogError -ne $ShouldLogError))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'ShouldLogError'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('WorkingDirectory')) `
                -and ($Action.WorkingDirectory -ne $WorkingDirectory))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'WorkingDirectory'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('EventType')) `
                -and ($Action.EventType -ne $EventType))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'EventType'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('ReportTypes')) `
                -and ($Action.ReportTypes -ne $ReportTypes))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'ReportTypes'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }
            #endregion
        }
    }
    else
    {
        if ($Result.ActionIndex -eq $null)
        {
            # The action doesn't exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionDoesNotExistAndShouldNotMessage) `
                    -f $Name,$Percentage,$Type
                ) -join '' )
        }
        else
        {
            # The Action exists, but it should be removed
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionExistsAndShouldNotMessage) `
                    -f $Name,$Percentage,$Type
                ) -join '' )
            $desiredConfigurationMatch = $false
        } # if
    } # if

    return $desiredConfigurationMatch
} # Test-TargetResource

# Helper Functions

<#
.Synopsis
    This function tries to find a matching Quota Template and threshold object
    If found, it assembles all threshold and action objects into modifiable arrays
    So that they can be worked with and then later saved back into the Quota Template
    Using Set-Action.
#>
Function Get-Action {
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [ValidateRange(0,100)]
        [System.Int32]
        $Percentage,
        
        [parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type
    )
    $ResultObject = [PSObject] @{
        SourceObjects = [System.Collections.ArrayList]@()
        SourceIndex = $null
        ActionIndex = $null
    }
    # Lookup the Quota Template
    try
    {
        $QuotaTemplate = Get-FSRMQuotaTemplate -Name $Name -ErrorAction Stop
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $errorId = 'QuotaTemplateNotFound'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.QuotaTemplateNotFoundError) `
            -f $Name,$Percentage,$Type
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    # Assemble the Result Object
    # This object is created from copies of the CIM classes returned in the threshold objects
    # but put into ArrayLists so that they can be manipulated.
    # DO NOT change this behavior unless you are sure you know what you're doing.
    for ($t=0; $t -ilt $QuotaTemplate.Threshold.Count; $t++)
    {
        $NewActions = New-Object 'System.Collections.ArrayList'
        if ($QuotaTemplate.Threshold[$t].Percentage -eq $Percentage)
        {
            $ResultObject.SourceIndex = $t
        }
        for ($a=0; $a -ilt $QuotaTemplate.Threshold[$t].Action.Count; $a++)
        {
            $NewActions.Add($QuotaTemplate.Threshold[$t].Action[$a])
            if (($QuotaTemplate.Threshold[$t].Action[$a].Type -eq $Type) `
                -and ($ResultObject.SourceIndex -eq $t))
            {
                $ResultObject.ActionIndex = $a
            }
        }
        $ResultObject.SourceObjects += [PSObject]@{
            Percentage = $QuotaTemplate.Threshold[$t].Percentage
            Action = $NewActions}
    }
    if ($ResultObject.SourceIndex -eq $null)
    {
        $errorId = 'QuotaTemplateThresholdNotFound'
        $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument
        $errorMessage = $($LocalizedData.QuotaTemplateThresholdNotFoundError) `
            -f $Name,$Percentage,$Type
        $exception = New-Object -TypeName System.InvalidOperationException `
            -ArgumentList $errorMessage
        $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
            -ArgumentList $exception, $errorId, $errorCategory, $null

        $PSCmdlet.ThrowTerminatingError($errorRecord)                
    }

    # Return the result
    Return $ResultObject
}

<#
.Synopsis
    This function converts the result object that was created by Get-Action back
    Into a form that can be saved into the Quota Template.
#>
Function Set-Action {
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        $ResultObject
    )
    $Threshold = @()
    foreach ($o in $ResultObject.SourceObjects)
    {
        $Threshold += New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = $o.Percentage
                Action = [Microsoft.Management.Infrastructure.CimInstance[]]($o.Action)
            }
    }
    Set-FSRMQuotaTemplate `
        -Name $Name `
        -Threshold $Threshold `
        -ErrorAction Stop
}

Export-ModuleMember -Function *-TargetResource