$Global:DSCModuleName      = 'xFSRM'
$Global:DSCResourceName    = 'MSFT_xFSRMClassificationProperty'

#region HEADER (V2)
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git')
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Integration 
#endregion

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($Global:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($Global:DSCResourceName)_Integration" {
        #region DEFAULT TESTS
        It 'Should compile without throwing' {
            {
                Invoke-Expression -Command "$($Global:DSCResourceName)_Config -OutputPath `$TestEnvironment.WorkingFolder"
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and all the parameters should match' {
            # Get the Classification Property details
            $classificationPropertyNew = Get-FSRMClassificationPropertyDefinition -Name $classificationProperty.Name
            $classificationProperty.Name          | Should Be $classificationPropertyNew.Name
            $classificationProperty.DisplayName   | Should Be $classificationPropertyNew.DisplayName
            $classificationProperty.Type          | Should Be $classificationPropertyNew.Type
            $classificationProperty.Description   | Should Be $classificationPropertyNew.Description
            (Compare-Object `
                -ReferenceObject $classificationProperty.PossibleValue `
                -DifferenceObject $classificationPropertyNew.PossibleValue.Name).Count | Should Be 0
            (Compare-Object `
                -ReferenceObject $classificationProperty.Parameters `
                -DifferenceObject $classificationPropertyNew.Parameters).Count | Should Be 0
        }
        
        # Clean up
        Remove-FSRMClassificationPropertyDefinition `
            -Name $classificationProperty.Name `
            -Confirm:$false
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
