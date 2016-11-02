Import-Module -Name (Join-Path `
    -Path (Split-Path -Path $PSScriptRoot -Parent) `
    -ChildPath 'CommonResourceHelper.psm1')
$LocalizedData = Get-LocalizedData -ResourceName 'MSFT_FSRMFileScreenTemplate'

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingFileScreenTemplateMessage) `
            -f $Name
        ) -join '' )

    # Lookup the existing template
    $fileScreenTemplate = Get-FileScreenTemplate -Name $Name

    $returnValue = @{
        Name = $Name
    }
    if ($fileScreenTemplate)
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.FileScreenTemplateExistsMessage) `
                -f $Name
            ) -join '' )

        $returnValue += @{
            Ensure = 'Present'
            Description = $fileScreenTemplate.Description
            Active = $fileScreenTemplate.Active
            IncludeGroup = @($fileScreenTemplate.IncludeGroup)
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.FileScreenTemplateDoesNotExistMessage) `
                -f $Name
            ) -join '' )

        $returnValue += @{
            Ensure = 'Absent'
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

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $Active,

        [Parameter()]
        [System.String[]]
        $IncludeGroup
    )

    # Remove any parameters that can't be splatted.
    $null = $PSBoundParameters.Remove('Ensure')

    # Lookup the existing FileScreen Template
    $fileScreenTemplate = Get-FileScreenTemplate -Name $Name

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureFileScreenTemplateExistsMessage) `
                -f $Name
            ) -join '' )

        if ($fileScreenTemplate)
        {
            # The File Screen template exists
            Set-FSRMFileScreenTemplate @PSBoundParameters `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.FileScreenTemplateUpdatedMessage) `
                    -f $Name
                ) -join '' )
        }
        else
        {
            # Create the FileScreen Template
            New-FSRMFileScreenTemplate @PSBoundParameters `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.FileScreenTemplateCreatedMessage) `
                    -f $Name
                ) -join '' )
        }
    }
    else
    {
        Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($LocalizedData.EnsureFileScreenTemplateDoesNotExistMessage) `
                -f $Name
            ) -join '' )

        if ($fileScreenTemplate)
        {
            # The FileScreen Template shouldn't exist - remove it
            Remove-FSRMFileScreenTemplate `
                -Name $Name `
                -ErrorAction Stop

            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($LocalizedData.FileScreenTemplateRemovedMessage) `
                    -f $Name
                ) -join '' )
        } # if
    } # if
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

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $Active,

        [Parameter()]
        [System.String[]]
        $IncludeGroup
    )
    # Flag to signal whether settings are correct
    [Boolean] $desiredConfigurationMatch = $true

    Write-Verbose -Message ( @(
        "$($MyInvocation.MyCommand): "
        $($LocalizedData.TestingFileScreenTemplateMessage) `
            -f $Name
        ) -join '' )

    # Lookup the existing FileScreen Template
    $fileScreenTemplate = Get-FileScreenTemplate -Name $Name

    if ($Ensure -eq 'Present')
    {
        # The FileScreen Template should exist
        if ($fileScreenTemplate)
        {
            # The FileScreen Template exists already - check the parameters
            if (($PSBoundParameters.ContainsKey('Description')) `
                -and ($fileScreenTemplate.Description -ne $Description))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileScreenTemplatePropertyNeedsUpdateMessage) `
                        -f $Name,'Description'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('Active')) `
                -and ($fileScreenTemplate.Active -ne $Active))
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileScreenTemplatePropertyNeedsUpdateMessage) `
                        -f $Name,'Active'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }

            if (($PSBoundParameters.ContainsKey('IncludeGroup')) `
                -and (Compare-Object `
                -ReferenceObject $IncludeGroup `
                -DifferenceObject $fileScreenTemplate.IncludeGroup).Count -ne 0)
            {
                Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($LocalizedData.FileScreenTemplatePropertyNeedsUpdateMessage) `
                        -f $Name,'IncludeGroup'
                    ) -join '' )
                $desiredConfigurationMatch = $false
            }
        }
        else
        {
            # Ths File Screen Template doesn't exist but should
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.FileScreenTemplateDoesNotExistButShouldMessage) `
                    -f  $Name
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
    }
    else
    {
        # The File Screen Template should not exist
        if ($fileScreenTemplate)
        {
            # The File Screen Template exists but should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.FileScreenTemplateExistsButShouldNotMessage) `
                    -f  $Name
                ) -join '' )
            $desiredConfigurationMatch = $false
        }
        else
        {
            # The File Screen Template does not exist and should not
            Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                 $($LocalizedData.FileScreenTemplateDoesNotExistAndShouldNotMessage) `
                    -f  $Name
                ) -join '' )
        }
    } # if
    return $desiredConfigurationMatch
} # Test-TargetResource

# Helper Functions

Function Get-FileScreenTemplate {
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )
    try
    {
        $fileScreenTemplate = Get-FSRMFileScreenTemplate `
            -Name $Name `
            -ErrorAction Stop
    }
    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException]
    {
        $fileScreenTemplate = $null
    }
    catch
    {
        Throw $_
    }
    Return $fileScreenTemplate
}

Export-ModuleMember -Function *-TargetResource
