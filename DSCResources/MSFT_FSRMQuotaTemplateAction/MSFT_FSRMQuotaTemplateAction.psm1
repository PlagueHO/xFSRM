Import-Module -Name (Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath 'CommonResourceHelper.psm1')
$LocalizedData = Get-LocalizedData -ResourceName 'MSFT_FSRMQuotaTemplateAction'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateRange(0,100)]
        [System.Uint32]
        $Percentage,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingActionMessage) `
            -f $Name,$Percentage,$Type
        ) -join '' )


    $result = Get-Action `
        -Name $Name `
        -Percentage $Percentage `
        -Type $Type

    $returnValue = @{
        Name = $Name
        Percentage = $Percentage
        Type = $Type
    }
    if ($null -eq $result.ActionIndex)
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
        $action = $result.SourceObjects[$result.SourceIndex].Action[$result.ActionIndex]
        $returnValue += @{
            Ensure = 'Present'
            Subject = $action.Subject
            Body = $action.Body
            MailBCC = $action.MailBCC
            MailCC = $action.MailCC
            MailTo = $action.MailTo
            Command = $action.Command
            CommandParameters = $action.CommandParameters
            KillTimeOut = [System.Int32] $action.KillTimeOut
            RunLimitInterval = [System.Int32] $action.RunLimitInterval
            SecurityLevel = $action.SecurityLevel
            ShouldLogError = $action.ShouldLogError
            WorkingDirectory = $action.WorkingDirectory
            EventType = $action.EventType
            ReportTypes = [System.String[]] $action.ReportTypes
        }
    }

    $returnValue
} # Get-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateRange(0,100)]
        [System.Uint32]
        $Percentage,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $Subject,

        [Parameter()]
        [System.String]
        $Body,

        [Parameter()]
        [System.String]
        $MailTo,

        [Parameter()]
        [System.String]
        $MailCC,

        [Parameter()]
        [System.String]
        $MailBCC,

        [Parameter()]
        [ValidateSet('None','Information','Warning','Error')]
        [System.String]
        $EventType,

        [Parameter()]
        [System.String]
        $Command,

        [Parameter()]
        [System.String]
        $CommandParameters,

        [Parameter()]
        [System.Int32]
        $KillTimeOut,

        [Parameter()]
        [System.Int32]
        $RunLimitInterval,

        [Parameter()]
        [ValidateSet('None','LocalService','NetworkService','LocalSystem')]
        [System.String]
        $SecurityLevel,

        [Parameter()]
        [System.Boolean]
        $ShouldLogError,

        [Parameter()]
        [System.String]
        $WorkingDirectory,

        [Parameter()]
        [System.String[]]
        $ReportTypes
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
    $result = Get-Action `
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

        $newAction = New-FSRMAction @PSBoundParameters -ErrorAction Stop

        if ($null -eq $result.ActionIndex)
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
            $result.SourceObjects[$result.SourceIndex].Action.RemoveAt($result.ActionIndex)

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.ActionUpdatedMessage) `
                    -f $Name,$Percentage,$Type
                ) -join '' )
        }

        $result.SourceObjects[$result.SourceIndex].Action.Add($newAction)
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureActionDoesNotExistMessage) `
                -f $Name,$Percentage,$Type
            ) -join '' )

        if ($null -eq $result.ActionIndex)
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
            $result.SourceObjects[$result.SourceIndex].Action.RemoveAt($result.ActionIndex)

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
        -ResultObject $result

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
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateRange(0,100)]
        [System.Uint32]
        $Percentage,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $Subject,

        [Parameter()]
        [System.String]
        $Body,

        [Parameter()]
        [System.String]
        $MailTo,

        [Parameter()]
        [System.String]
        $MailCC,

        [Parameter()]
        [System.String]
        $MailBCC,

        [Parameter()]
        [ValidateSet('None','Information','Warning','Error')]
        [System.String]
        $EventType,

        [Parameter()]
        [System.String]
        $Command,

        [Parameter()]
        [System.String]
        $CommandParameters,

        [Parameter()]
        [System.Int32]
        $KillTimeOut,

        [Parameter()]
        [System.Int32]
        $RunLimitInterval,

        [Parameter()]
        [ValidateSet('None','LocalService','NetworkService','LocalSystem')]
        [System.String]
        $SecurityLevel,

        [Parameter()]
        [System.Boolean]
        $ShouldLogError,

        [Parameter()]
        [System.String]
        $WorkingDirectory,

        [Parameter()]
        [System.String[]]
        $ReportTypes
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.SettingActionMessage) `
            -f $Name,$Percentage,$Type
        ) -join '' )

    # Lookup the existing action and related objects
    $result = Get-Action `
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

        if ($null -eq $result.ActionIndex)
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
            $action = $result.SourceObjects[$result.SourceIndex].Action[$result.ActionIndex]

            #region Parameter Checks
            if (($PSBoundParameters.ContainsKey('Subject')) `
                -and ($action.Subject -ne $Subject))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'Subject'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Body')) `
                -and ($action.Body -ne $Body))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'Body'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailBCC')) `
                -and ($action.MailBCC -ne $MailBCC))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'MailBCC'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailCC')) `
                -and ($action.MailCC -ne $MailCC))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'MailCC'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('MailTo')) `
                -and ($action.MailTo -ne $MailTo))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'MailTo'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Command')) `
                -and ($action.Command -ne $Command))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'Command'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('CommandParameters')) `
                -and ($action.CommandParameters -ne $CommandParameters))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'CommandParameters'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('KillTimeOut')) `
                -and ($action.KillTimeOut -ne $KillTimeOut))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'KillTimeOut'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('RunLimitInterval')) `
                -and ($action.RunLimitInterval -ne $RunLimitInterval))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'RunLimitInterval'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('SecurityLevel')) `
                -and ($action.SecurityLevel -ne $SecurityLevel))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'SecurityLevel'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('ShouldLogError')) `
                -and ($action.ShouldLogError -ne $ShouldLogError))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'ShouldLogError'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('WorkingDirectory')) `
                -and ($action.WorkingDirectory -ne $WorkingDirectory))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'WorkingDirectory'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('EventType')) `
                -and ($action.EventType -ne $EventType))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.ActionPropertyNeedsUpdateMessage) `
                        -f $Name,$Percentage,$Type,'EventType'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('ReportTypes')) `
                -and ($action.ReportTypes -ne $ReportTypes))
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
        if ($null -eq $result.ActionIndex)
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
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateRange(0,100)]
        [System.Int32]
        $Percentage,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Email','Event','Command','Report')]
        [System.String]
        $Type
    )
    $resultObject = [PSObject] @{
        SourceObjects = [System.Collections.ArrayList]@()
        SourceIndex = $null
        ActionIndex = $null
    }
    # Lookup the Quota Template
    try
    {
        $quotaTemplate = Get-FSRMQuotaTemplate -Name $Name -ErrorAction Stop
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
    for ($threshold = 0; $threshold -ilt $quotaTemplate.Threshold.Count; $threshold++)
    {
        $newActions = New-Object -TypeName 'System.Collections.ArrayList'
        if ($quotaTemplate.Threshold[$threshold].Percentage -eq $Percentage)
        {
            $ResultObject.SourceIndex = $threshold
        }
        for ($action = 0; $action -ilt $quotaTemplate.Threshold[$threshold].Action.Count; $action++)
        {
            $newActions.Add($quotaTemplate.Threshold[$threshold].Action[$action])
            if (($quotaTemplate.Threshold[$threshold].Action[$action].Type -eq $Type) `
                -and ($resultObject.SourceIndex -eq $threshold))
            {
                $resultObject.ActionIndex = $action
            }
        }
        $properties = @{'Percentage' = $quotaTemplate.Threshold[$threshold].Percentage;
            'Action' = $newActions;}
        $newSourceObject = New-Object -TypeName 'PSObject' -Property $properties
        $resultObject.SourceObjects += @($newSourceObject)
    }
    if ($null -eq $resultObject.SourceIndex)
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
    Return $resultObject
}

<#
.Synopsis
    This function converts the result object that was created by Get-Action back
    Into a form that can be saved into the Quota Template.
#>
Function Set-Action {
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        $ResultObject
    )
    $threshold = @()
    foreach ($object in $ResultObject.SourceObjects)
    {
        $threshold += New-CimInstance `
            -ClassName 'MSFT_FSRMQuotaThreshold' `
            -Namespace Root/Microsoft/Windows/FSRM `
            -ClientOnly `
            -Property @{
                Percentage = $object.Percentage
                Action = [Microsoft.Management.Infrastructure.CimInstance[]]($object.Action)
            }
    }
    Set-FSRMQuotaTemplate `
        -Name $Name `
        -Threshold $threshold `
        -ErrorAction Stop
}

Export-ModuleMember -Function *-TargetResource
