[![Build status](https://ci.appveyor.com/api/projects/status/7n1yr63x7ptneyc5/branch/master?svg=true)](https://ci.appveyor.com/project/PlagueHO/cfsrm/branch/master)

# cFSRM

The **cFSRM** module contains DSC resources for configuring Windows File Server Resource Manager.

Note: This module contains DSC resources that used to exist in the following modules:
- cFSRMQuotas
- cFSRMClassifications
- cFSRMFileScreens

The above modules will no longer be maintained. Any configurations using the above modules should be converted to use this resource. The resource names/parameters have not changed so to convert a config change the module name in the Import-DSCResource.

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).


## Resources

* **cFSRMSettings** configures FSRM settings.
* **cFSRMClassification** configures FSRM Classification settings.
* **cFSRMClassificationProperty** configures FSRM Classification Property Definitions.
* **cFSRMClassificationPropertyValue** configures FSRM Classification Property Definition Values. This resource only needs to be used if the Description of a Classification Property Definition Value must be set.
* **cFSRMClassificationRule** configures FSRM Classification Rules.
* **cFSRMFileScreen** configures FSRM File Screen.
* **cFSRMFileScreenAction** configures FSRM File Screen Actions for File Screens.
* **cFSRMFileScreenTemplate** configures FSRM File Screen Templates.
* **cFSRMFileScreenTemplateAction** configures FSRM File Screen Template Actions for File Screen Templates.
* **cFSRMFileScreenExclusion** configures FSRM File Screen Exclusions.
* **cFSRMFileGroup** configures FSRM File Groups.
* **cFSRMQuota** configures FSRM Quotas.
* **cFSRMQuotaAction** configures FSRM Quota Actions for Quotas.
* **cFSRMQuotaTemplate** configures FSRM Quota Templates.
* **cFSRMQuotaTemplateAction** configures FSRM Quota Template Actions for Quota Templates.
* **cFSRMAutoQuota** configures FSRM Auto Quotas.

### cFSRMSettings

* **[String]Id**: This is a unique identifier for this resource. Required.
* **[String]SmtpServer**: Specifies the fully qualified domain name (FQDN) or IP address of the SMTP server that FSRM uses to send email. Optional.
* **[String]AdminEmailAddress**: Specifies a semicolon-separated list of email addresses for the recipients of any email that the server sends to the administrator. Optional.
* **[String]FromEmailAddress**: Specifies the default email address from which FSRM sends email messages. Optional.
* **[Uint32]CommandNotificationLimit**: Specifies the minimum number of seconds between individual running events of a command-type notification. Optional.
* **[Uint32]EmailNotificationLimit**: Specifies the minimum number of seconds between individual running events of an email-type notification. Optional.
* **[Uint32]EventNotificationLimit**: Specifies the minimum number of seconds between individual running events of an event-type notification. Optional.

### cFSRMClassification

* **Id**: This is a unique resource identifier. It can be set to any unique string. It does not matter what this parameter is set to, as long as it is set. The parameter is only included because a key propert is always required. Required.
* **Continuous**: Enable FSRM Classification continuous mode for new files. Optional.
* **ContinuousLog**: Enable FSRM Classification continuous mode logging. Optional.
* **ContinuousLogSize**: The maximum number of KB that can be used for the continuous mode log file. Optional.
* **ExcludeNamespace**: An array of Namespaces that will be excluded from FSRM Classification. Optional.
* **ScheduleMonthly**: An array of days of the month the FSRM Classification should run on. Optional. 
* **ScheduleWeekly**: An array of named days of the week the FSRM Classification should run on. Optional.
* **ScheduleRunDuration**: The maximum number of hours the FSRM Classification can run for. Setting this to -1 will disable this. Optional.
* **ScheduleTime**: A string containing the time of day the FSRM Classification should run at. Optional.

### cFSRMClassificationProperty

* **Name**: The name of the FSRM Classification Property. Required.
* **Type**: The type of the FSRM Classification Property. Values: { OrderedList | MultiChoice | SingleChoice | String | MultiString | Integer | YesNo | DateTime }. Required.
* **DisplayName**: The display name for the FSRM Classification Property. If not specified the DisplayName will default to the same value as Name. Optional.
* **Description**: The description for the FSRM Classification Property. Optional.
* **Ensure**: Specifies whether the FSRM Classification Property should exist. Values: { Absent | Present }. Default: Present
* **PossibleValue**: An array of possible values that this FSRM Classification Property can take on. These can also be configured via the cFSRMClassificationPropertValue resource. Optional.
* **Parameters**: An array of parameters in the format <name>=<value> that can be used by the File Classification Infrastructure. Optional.

### cFSRMClassificationPropertyValue

* **Name**: The FSRM Classification Property value Name. Required.
* **PropertyName**: The name of the FSRM Classification Property the value applies to. Required.
* **Ensure**: Specifies whether the FSRM Classification Property Value should exist. Values: { Absent | Present }. Default: Present
* **Description**: The description for the FSRM Classification Property Value. Optional.

### cFSRMClassificationRule

* **Name**: The name of the FSRM Classification Rule. Required.
* **Description**: The description for the FSRM Classification Rule. Optional.
* **Ensure**: Specifies whether the FSRM Classification Rule should exist. Values: { Absent | Present }. Default: Present
* **Property**: Specifies the name of a classification property definition to set. Optional.
* **PropertyValue**: Specifies the property value that the rule will assign. Optional.
* **ClassificationMechanism**: Specifies the name of a valid classification mechanism available on the server for assigning the property value. Optional.
* **ContentRegularExpression**: An array of regular expressions for pattern matching. Optional.
* **ContentString**: An array of strings for the content classifier to search for. Optional.
* **ContentStringCaseSensitive**: An array of case sensitive strings for the content classifier to search for. Optional.
* **Disabled**: Indicates that the classification rule is disabled. Optional.
* **Flags**: An array of flags that defines the possible states of the rule. Values: { ClearAutomaticallyClassifiedProperty | ClearManuallyClassifiedProperty }. Optional.
* **Parameters**: An array of parameters in the format <name>=<value> that can be used by the File Classification Infrastructure. Optional.
* **Namespace**: An array of namespaces where the rule is applied. Optional.
* **ReevaluateProperty**: Specifies the evaluation policy of the rule. Values: { Never | Overwrite | Aggregate }. Optional.

### cFSRMFileScreen
* **Path**: The path the File Screen is applied to. Required.
* **Description**: The optional description of the File Screen. Optional.
* **Ensure**: Should this File Screen exist. Optional. Values: { Absent | Present }. Default: Present.
* **Active**: Boolean setting that controls if server should fail any I/O operations if the File Screen is violated. Default: True.
* **IncludeGroup**: Contains an array of File Groups to include in this File Screen. Optional.
* **Template**: The name of the File Screen Template that should be used to create this File Screen. Optional.
* **MatchesTemplate**: This parameter causes the resource to ignore the Active and IncludeGroup parameters and maintain the File Screen only using the Template. It should be enabled whenever possible as it simplifies the behaviour of the resource and will ensure the quota always matches the specified template. Optional.

### cFSRMFileScreenAction
* **Path**: The path the File Screen is applied to for the action. Required.
* **Type**: The type of action. Required. Values: { Email | Event | Command | Report }.
* **Ensure**: Should this File Screen action exist. Optional. Values: { Absent | Present }. Default: Present
* **Subject**: The subject of the e-mail sent. Required when Type is Email.
* **Body**: The body text of the e-mail or event. Required when Type is Email or Event. 
* **MailBCC**: The mail BCC of the e-mail sent. Required when Type is Email.
* **MailCC**: The mail CC of the e-mail sent. Required when Type is Email.
* **MailTo**: The mail to of the e-mail sent. Required when Type is Email.
* **Command**: The Command to execute. Required when Type is Command.
* **CommandParameters**: The Command Parameters. Required when Type is Command.
* **KillTimeOut**: Int containing kill timeout of the command. Required when Type is Command.
* **RunLimitInterval**: Int containing the run limit interval of the command. Required when Type is Command.
* **SecurityLevel**: The security level the command runs under. Required when Type is Command. Values: { None | LocalService | NetworkService | LocalSystem }.
* **ShouldLogError**: Boolean specifying if command errors should be logged . Required when Type is Command.
* **WorkingDirectory**: The working directory of the command. Required when Type is Command.
* **EventType**: The type of event created. Required when Type is Event. Values: { None | Information | Warning | Error }.
* **ReportTypes**: Array of Reports to create. Required when Type is Report.

### cFSRMFileScreenTemplate
* **Name**: The name of the File Screen template. Required.
* **Description**: The optional description of the File Screen template. Optional.
* **Ensure**: Should this File Screen template exist. Optional. Values: { Absent | Present }. Default: Present
* **Active**: Boolean setting that controls if server should fail any I/O operations if the File Screen is violated. Default: True.
* **IncludeGroup**: Contains an array of File Groups to include in this File Screen template. Optional.

### cFSRMFileScreenTemplateAction
* **Name**: The name of the File Screen template for the action. Required.
* **Type**: The type of action. Required. Values: { Email | Event | Command | Report }.
* **Ensure**: Should this File Screen template action exist. Optional. Values: { Absent | Present }. Default: Present
* **Subject**: The subject of the e-mail sent. Required when Type is Email.
* **Body**: The body text of the e-mail or event. Required when Type is Email or Event. 
* **MailBCC**: The mail BCC of the e-mail sent. Required when Type is Email.
* **MailCC**: The mail CC of the e-mail sent. Required when Type is Email.
* **MailTo**: The mail to of the e-mail sent. Required when Type is Email.
* **Command**: The Command to execute. Required when Type is Command.
* **CommandParameters**: The Command Parameters. Required when Type is Command.
* **KillTimeOut**: Int containing kill timeout of the command. Required when Type is Command.
* **RunLimitInterval**: Int containing the run limit interval of the command. Required when Type is Command.
* **SecurityLevel**: The security level the command runs under. Required when Type is Command. Values: { None | LocalService | NetworkService | LocalSystem }.
* **ShouldLogError**: Boolean specifying if command errors should be logged . Required when Type is Command.
* **WorkingDirectory**: The working directory of the command. Required when Type is Command.
* **EventType**: The type of event created. Required when Type is Event. Values: { None | Information | Warning | Error }.
* **ReportTypes**: Array of Reports to create. Required when Type is Report.

### cFSRMFileScreenExclusion
* **Path**: The path the File Screen Exclusion is applied to. Required.
* **Description**: The optional description of the File Screen. Optional.
* **Ensure**: Should this File Screen exist. Optional. Values: { Absent | Present }. Default: Present.
* **IncludeGroup**: Contains an array of File Groups to include in this File Screen Exclusion. Optional.

### cFSRMFileGroup

* **Name**: The name of the FSRM File Groups. Required.
* **Description**: The optional description of the FSRM File Group. Optional.
* **Ensure**: Should this FSRM Group exist. Optional. Values: { Absent | Present }. Default: Present
* **IncludePattern**: An array of file patterns to include in this FSRM File Group. Optional.
* **ExcludePattern**: An array of file patterns to exclude in this FSRM File Group. Optional.

### cFSRMQuota
* **Path**: The path the quota is applied to. Required.
* **Description**: The optional description of the quota. Optional.
* **Ensure**: Should this quota exist. Optional. Values: { Absent | Present }. Default: Present
* **Size**: Size of quota limit. Required.
* **SoftLimit**: Specify if the limit is hard or soft. Optional. Detault: $Ture
* **ThresholdPercentages**: An array of Threshold Percentages. Notifications can be assigned to each Threshold Percentage. Optional.
* **Disabled**: Allows the quota to be disabled. Optional.
* **Template**: The name of the Quota Template that should be used to create this quota. Optional.
* **MatchesTemplate**: This parameter causes the resource to ignore the Size, Softlimit and ThresholdPercentages parameters and maintain the quota only using the Template. It should be enabled whenever possible as it simplifies the behaviour of the resource and will ensure the quota always matches the specified template. Optional.

### cFSRMQuotaAction
* **Path**: The path the quota is applied to for the action. Required.
* **Percentage**: The threshold percentage that this action is assigned to. Required.
* **Type**: The type of action. Required. Values: { Email | Event | Command | Report }.
* **Ensure**: Should this quota/quota template action exist. Optional. Values: { Absent | Present }. Default: Present
* **Subject**: The subject of the e-mail sent. Required when Type is Email.
* **Body**: The body text of the e-mail or event. Required when Type is Email or Event. 
* **MailBCC**: The mail BCC of the e-mail sent. Required when Type is Email.
* **MailCC**: The mail CC of the e-mail sent. Required when Type is Email.
* **MailTo**: The mail to of the e-mail sent. Required when Type is Email.
* **Command**: The Command to execute. Required when Type is Command.
* **CommandParameters**: The Command Parameters. Required when Type is Command.
* **KillTimeOut**: Int containing kill timeout of the command. Required when Type is Command.
* **RunLimitInterval**: Int containing the run limit interval of the command. Required when Type is Command.
* **SecurityLevel**: The security level the command runs under. Required when Type is Command. Values: { None | LocalService | NetworkService | LocalSystem }.
* **ShouldLogError**: Boolean specifying if command errors should be logged . Required when Type is Command.
* **WorkingDirectory**: The working directory of the command. Required when Type is Command.
* **EventType**: The type of event created. Required when Type is Event. Values: { None | Information | Warning | Error }.
* **ReportTypes**: Array of Reports to create. Required when Type is Report.

### cFSRMQuotaTemplate
* **Name**: The name of the quota template. Required.
* **Description**: The optional description of the quota template. Optional.
* **Ensure**: Should this quota template exist. Optional. Values: { Absent | Present }. Default: Present
* **Size**: Size of quota limit. Required.
* **SoftLimit**: Specify if the limit is hard or soft. Optional. Detault: $Ture
* **ThresholdPercentages**: An array of Threshold Percentages. Notifications can be assigned to each Threshold Percentage. Optional.

### cFSRMQuotaTemplateAction
* **Name**: The name of the quota template for the action. Required.
* **Percentage**: The threshold percentage that this action is assigned to. Required.
* **Type**: The type of action. Required. Values: { Email | Event | Command | Report }.
* **Ensure**: Should this quota template action exist. Optional. Values: { Absent | Present }. Default: Present
* **Subject**: The subject of the e-mail sent. Required when Type is Email.
* **Body**: The body text of the e-mail or event. Required when Type is Email or Event. 
* **MailBCC**: The mail BCC of the e-mail sent. Required when Type is Email.
* **MailCC**: The mail CC of the e-mail sent. Required when Type is Email.
* **MailTo**: The mail to of the e-mail sent. Required when Type is Email.
* **Command**: The Command to execute. Required when Type is Command.
* **CommandParameters**: The Command Parameters. Required when Type is Command.
* **KillTimeOut**: Int containing kill timeout of the command. Required when Type is Command.
* **RunLimitInterval**: Int containing the run limit interval of the command. Required when Type is Command.
* **SecurityLevel**: The security level the command runs under. Required when Type is Command. Values: { None | LocalService | NetworkService | LocalSystem }.
* **ShouldLogError**: Boolean specifying if command errors should be logged . Required when Type is Command.
* **WorkingDirectory**: The working directory of the command. Required when Type is Command.
* **EventType**: The type of event created. Required when Type is Event. Values: { None | Information | Warning | Error }.
* **ReportTypes**: Array of Reports to create. Required when Type is Report.

### cFSRMAutoQuota
* **Path**: The path the auto quota is applied to. Required.
* **Ensure**: Should this auto quota exist. Optional. Values: { Absent | Present }. Default: Present
* **Disabled**: Allows the auto quota to be disabled. Optional.
* **Template**: The name of the Quota Template that should be used to create this auto quota. Optional.

## Versions

### 2.0.0.0
* Combined all FSRM Resources into this module

### 1.0.0.0

* Initial release

## Examples

### Configure a FSRM Server Settings

This configuration will configure the FSRM Settings on a server.

```powershell
configuration Sample_cFSRMSettings
{
    Import-DscResource -Module cFSRMSettings

    Node $NodeName
    {
        cFSRMSettings FSRMSettings
        {
            Id = 'Default'
            SmtpServer = 'smtp.contoso.com'
            AdminEmailAddress = 'fsadmin@contoso.com'
            FromEmailAddress = 'fsuser@contoso.com'
            CommandNotificationLimit = 90
            EmailNotificationLimit = 90
            EventNotificationLimit = 90
        } # End of cFSRMSettings Resource
    } # End of Node
} # End of Configuration
```

### Configure the FSRM Classification Settings

This will configure the FSRM Classification settings on this server. It enables Continous Mode, Logging and sets the maximum Log size to 2 MB. The Classification schedule is also set to Monday through Wednesday at 11:30pm and will run a maximum of 4 hours. 

```powershell
configuration Sample_cFSRMClassification
{
    Import-DscResource -Module cFSRMClassifications

    Node $NodeName
    {
        cFSRMClassification FSRMClassificationSettings
        {
            Id = 'Default'
            Continuous = $True
            ContinuousLog = $True
            ContinuousLogSize = 2048
            ScheduleWeekly = 'Monday','Tuesday','Wednesday'
            ScheduleRunDuration = 4
            ScheduleTime = '23:30'
        } # End of cFSRMClassification Resource
    } # End of Node
} # End of Configuration
```

### Configure a FSRM Yes/No Classification Property

This configuration will create a FSRM Yes/No Classification Property called Confidential.

```powershell
configuration Sample_cFSRMClassificationProperty_YesNo
{
    Import-DscResource -Module cFSRMClassifications

    Node $NodeName
    {
        cFSRMClassificationProperty ConfidentialFiles
        {
            Name = 'Confidential'
            Type = 'YesNo'
            Description = 'Is this file a confidential file'
            Ensure = 'Present'
        } # End of cFSRMClassificationProperty Resource
    } # End of Node
} # End of Configuration
```

### Configure a FSRM Single Choice Classification Property

This configuration will create a FSRM Single Choice Classification Property called Privacy.

```powershell
configuration Sample_cFSRMClassificationProperty_SingleChoice
{
    Import-DscResource -Module cFSRMClassifications

    Node $NodeName
    {
        cFSRMClassificationProperty PrivacyClasificationProperty
        {
            Name = 'Privacy'
            Type = 'SingleChoice'
            DisplayName = 'File Privacy'
            Description = 'File Privacy Property'
            Ensure = 'Present'
            PossibleValue = 'Top Secret','Secret','Confidential'
        } # End of cFSRMClassificationProperty Resource
    } # End of Node
} # End of Configuration
```

### Configure a FSRM Classification Property Value

This configuration will create a FSRM Classification Property Value called 'Public' assigned to the Classification Property called 'Privacy'.

```powershell
configuration Sample_cFSRMClassificationPropertyValue
{
    Import-DscResource -Module cFSRMClassifications

    Node $NodeName
    {
        cFSRMClassificationPropertyValue PublicClasificationPropertyValue
        {
            Name = 'Public'
            PropertyName = 'Privacy'
            Description = 'Publically accessible files.'
            Ensure = 'Present'
        } # End of cFSRMClassificationPropertyValue Resource
    } # End of Node
} # End of Configuration
```

### Configure a FSRM Classification Rule

This configuration will create a FSRM Classification Rule called 'Confidential' that will assign a Privacy value of Confidential to any files containing the text Confidential in the folder d:\users or any folder categorized as 'User Files'.

```powershell
configuration Sample_cFSRMClassificationRule
{
    Import-DscResource -Module cFSRMClassifications

    Node $NodeName
    {
        cFSRMClassificationRule ConfidentialPrivacyClasificationRule
        {
            Name = 'Confidential'
            Description = 'Set Confidential'
            Ensure = 'Present'
            Property = 'Privacy'
            PropertyValue = 'Confidential'
            ClassificationMechanism = ''
            ContentString = 'Confidential'
            Namespace = '[FolderUsage_MS=User Files]','d:\Users'
            ReevaluateProperty = 'Overwrite'                
        } # End of cFSRMClassificationRule Resource
    } # End of Node
} # End of Configuration
```

### Assign an FSRM File Screen using a template

This configuration will assign the 'Block Some Files' file screen template to the path 'D:\Users'. It will also force the File Screen assigned to this path to exactly match the 'Block Some Files' template. Any changes to the actions, include groups or active setting on the File Screen assigned to this path will cause the File Screen to be removed and reapplied.

```powershell
configuration Sample_cFSRMFileScreen_UsingTemplate
{
    Import-DscResource -Module cFSRMFileScreens

    Node $NodeName
    {
        cFSRMFileScreen DUsersFileScreens
        {
            Path = 'd:\users'
            Description = 'File Screen for Blocking Some Files'
            Ensure = 'Present'
            Template = 'Block Some Files'
            MatchesTemplate = $true 
        } # End of cFSRMFileScreen Resource
    } # End of Node
} # End of Configuration
```

### Assign a custom FSRM File Screen

This configuration will assign an Active FSRM File Screen to the path 'D:\Users' with three include groups. An e-mail and event action is bound to the File Screen.

```powershell
configuration Sample_cFSRMFileScreen
{
    Import-DscResource -Module cFSRMFileScreens

    Node $NodeName
    {
        cFSRMFileScreen DUsersFileScreen
        {
            Path = 'd:\users'
            Description = 'File Screen for Blocking Some Files'
            Ensure = 'Present'
            Active = $true
            IncludeGroup = 'Audio and Video Files','Executable Files','Backup Files' 
        } # End of cFSRMFileScreen Resource

        cFSRMFileScreenAction DUsersFileScreenSomeFilesEmail
        {
            Path = 'd:\users'
            Ensure = 'Present'
            Type = 'Email'
            Subject = 'Unauthorized file matching [Violated File Group] file group detected'
            Body = 'The system detected that user [Source Io Owner] attempted to save [Source File Path] on [File Screen Path] on server [Server]. This file matches the [Violated File Group] file group which is not permitted on the system.'
            MailBCC = ''
            MailCC = 'fileserveradmins@contoso.com'
            MailTo = '[Source Io Owner Email]'           
            DependsOn = "[cFSRMFileScreen]DUsersFileScreen" 
        } # End of cFSRMFileScreenAction Resource

        cFSRMFileScreenAction DUsersFileScreenSomeFilesEvent
        {
            Path = 'd:\users'
            Ensure = 'Present'
            Type = 'Event'
            Body = 'The system detected that user [Source Io Owner] attempted to save [Source File Path] on [File Screen Path] on server [Server]. This file matches the [Violated File Group] file group which is not permitted on the system.'
            EventType = 'Warning'
            DependsOn = "[cFSRMFileScreen]DUsersFileScreen" 
        } # End of cFSRMFileScreenAction Resource
    } # End of Node
} # End of Configuration
```

### Configure an FSRM File Screen Template

This configuration will create an Active FSRM File Screen Template called 'Block Some Files', with three include groups. An e-mail and event action is bound to the File Screen Template.

```powershell
configuration Sample_cFSRMFileScreenTemplate
{
    Import-DscResource -Module cFSRMFileScreens

    Node $NodeName
    {
        cFSRMFileScreenTemplate FileScreenSomeFiles
        {
            Name = 'Block Some Files'
            Description = 'File Screen for Blocking Some Files'
            Ensure = 'Present'
            Active = $true
            IncludeGroup = 'Audio and Video Files','Executable Files','Backup Files' 
        } # End of cFSRMFileScreenTemplate Resource

        cFSRMFileScreenTemplateAction FileScreenSomeFilesEmail
        {
            Name = 'Block Some Files'
            Ensure = 'Present'
            Type = 'Email'
            Subject = 'Unauthorized file matching [Violated File Group] file group detected'
            Body = 'The system detected that user [Source Io Owner] attempted to save [Source File Path] on [File Screen Path] on server [Server]. This file matches the [Violated File Group] file group which is not permitted on the system.'
            MailBCC = ''
            MailCC = 'fileserveradmins@contoso.com'
            MailTo = '[Source Io Owner Email]'           
            DependsOn = "[cFSRMFileScreenTemplate]FileScreenSomeFiles" 
        } # End of cFSRMFileScreenTemplateAction Resource

        cFSRMFileScreenTemplateAction FileScreenSomeFilesEvent
        {
            Name = 'Block Some Files'
            Ensure = 'Present'
            Type = 'Event'
            Body = 'The system detected that user [Source Io Owner] attempted to save [Source File Path] on [File Screen Path] on server [Server]. This file matches the [Violated File Group] file group which is not permitted on the system.'
            EventType = 'Warning'
            DependsOn = "[cFSRMFileScreenTemplate]FileScreenSomeFiles" 
        } # End of cFSRMFileScreenTemplateAction Resource
    } # End of Node
} # End of Configuration
```

### Configure a FSRM File Screen Exception

This configuration add a File Screen Exception that Includes 'E-mail Files' to the path 'D:\Users'.

```powershell
configuration Sample_cFSRMFileScreenException
{
    Import-DscResource -Module cFSRMFileScreens

    Node $NodeName
    {
        cFSRMFileScreenException DUsersFileScreenException
        {
            Path = 'd:\users'
            Description = 'File Screen for Blocking Some Files'
            Ensure = 'Present'
            IncludeGroup = 'E-mail Files'
        } # End of cFSRMFileScreenException Resource
    } # End of Node
} # End of Configuration
```

### Configure a FSRM File Group

This configuration will create a FSRM File Group called 'Archives'.

```powershell
configuration Sample_cFSRMFileGroup
{
    Import-DscResource -Module cFSRMFileScreens

    Node $NodeName
    {
        cFSRMFileGroup FSRMFileGroupPortableFiles
        {
            Name = 'Portable Document Files'
            Description = 'Files containing portable document formats'
            Ensure = 'Present'
            IncludePattern = '*.eps','*.pdf','*.xps'
        } # End of cFSRMFileGroup Resource
    } # End of Node
} # End of Configuration
```

### Assign an FSRM Quota using a template

This configuration will assign the '100 MB Limit' template to the path 'D:\Users'. It will also force the quota assigned to this path to exactly match the '100 MB Limit' template. Any changes to the thresholds or actions on the quota assigned to this path will cause the template to be removed and reapplied.

```powershell
configuration Sample_cFSRMQuota_UsingTemplate
{
    Import-DscResource -Module cFSRMQuotas

    Node $NodeName
    {
        cFSRMQuota DUsers
        {
            Path = 'd:\Users'
            Description = '100 MB Limit'
            Ensure = 'Present'
            Template = '100 MB Limit'
            MatchesTemplate = $true
        } # End of cFSRMQuota Resource
    } # End of Node
} # End of Configuration
```

### Assign a custom FSRM Quota

This configuration will assign an FSRM Quota to the path 'D:\Users', with a Hard Limit of 5GB and threshold percentages of 85 and 100. An e-mail action is bound to each threshold. An event action is also bound to the 85 percent threshold.

```powershell
configuration Sample_cFSRMQuota
{
    Import-DscResource -Module cFSRMQuotas

    Node $NodeName
    {
        cFSRMQuota DUsers
        {
            Path = 'd:\Users'
            Description = '5 GB Hard Limit'
            Ensure = 'Present'
            Size = 5GB
            SoftLimit = $False
            ThresholdPercentages = @( 85, 100 )
        } # End of cFSRMQuota Resource

        cFSRMQuotaAction DUsersEmail85
        {
            Path = 'd:\Users'
            Percentage = 85
            Ensure = 'Present'
            Type = 'Email'
            Subject = '[Quota Threshold]% quota threshold exceeded'
            Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            MailBCC = ''
            MailCC = 'fileserveradmins@contoso.com'
            MailTo = '[Source Io Owner Email]'           
            DependsOn = "[cFSRMQuota]DUsers" 
        } # End of cFSRMQuotaAction Resource

        cFSRMQuotaAction DUsersEvent85
        {
            Path = 'd:\Users'
            Percentage = 85
            Ensure = 'Present'
            Type = 'Event'
            Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            EventType = 'Warning'
            DependsOn = "[cFSRMQuotaTemplate]DUsers" 
        } # End of cFSRMQuotaAction Resource

        cFSRMQuotaAction DUsersEmail100
        {
            Path = 'd:\Users'
            Percentage = 100
            Ensure = 'Present'
            Type = 'Email'
            Subject = '[Quota Threshold]% quota threshold exceeded'
            Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            MailBCC = ''
            MailCC = 'fileserveradmins@contoso.com'
            MailTo = '[Source Io Owner Email]'
            DependsOn = "[cFSRMQuotaTemplate]DUsers" 
        } # End of cFSRMQuotaAction Resource
    } # End of Node
} # End of Configuration
```

### Configure an FSRM Quota Template

This configuration will create a FSRM Quota Template called '5 GB Hard Limit', with a Hard Limit of 5GB and threshold percentages of 85 and 100. An e-mail action is bound to each threshold. An event action is also bound to the 85 percent threshold.

```powershell
configuration Sample_cFSRMQuotaTemplate
{
    Import-DscResource -Module cFSRMQuotas

    Node $NodeName
    {
        cFSRMQuotaTemplate HardLimit5GB
        {
            Name = '5 GB Limit'
            Description = '5 GB Hard Limit'
            Ensure = 'Present'
            Size = 5GB
            SoftLimit = $False
            ThresholdPercentages = @( 85, 100 )
        } # End of cFSRMQuotaTemplate Resource

        cFSRMQuotaTemplateAction HardLimit5GBEmail85
        {
            Name = '5 GB Limit'
            Percentage = 85
            Ensure = 'Present'
            Type = 'Email'
            Subject = '[Quota Threshold]% quota threshold exceeded'
            Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            MailBCC = ''
            MailCC = 'fileserveradmins@contoso.com'
            MailTo = '[Source Io Owner Email]'           
			DependsOn = "[cFSRMQuotaTemplate]HardLimit5GB" 
        } # End of cFSRMQuotaTemplateAction Resource

        cFSRMQuotaTemplateAction HardLimit5GBEvent85
        {
            Name = '5 GB Limit'
            Percentage = 85
            Ensure = 'Present'
            Type = 'Event'
            Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
			EventType = 'Warning'
			DependsOn = "[cFSRMQuotaTemplate]HardLimit5GB" 
        } # End of cFSRMQuotaTemplateAction Resource

        cFSRMQuotaTemplateAction HardLimit5GBEmail100
        {
            Name = '5 GB Limit'
            Percentage = 100
            Ensure = 'Present'
            Type = 'Email'
            Subject = '[Quota Threshold]% quota threshold exceeded'
            Body = 'User [Source Io Owner] has exceed the [Quota Threshold]% quota threshold for quota on [Quota Path] on server [Server]. The quota limit is [Quota Limit MB] MB and the current usage is [Quota Used MB] MB ([Quota Used Percent]% of limit).'
            MailBCC = ''
            MailCC = 'fileserveradmins@contoso.com'
            MailTo = '[Source Io Owner Email]'
			DependsOn = "[cFSRMQuotaTemplate]HardLimit5GB" 
        } # End of cFSRMQuotaTemplateAction Resource
    } # End of Node
} # End of Configuration
```

### Configure an FSRM Auto Quota

This configuration will assign an FSRM Auto Quota to the path 'd:\users' using the template '5 GB Limit'.

```powershell
configuration Sample_cFSRMAutoQuota
{
    Import-DscResource -Module cFSRMQuotas

    Node $NodeName
    {
        cFSRMAutoQuota DUsers
        {
            Path = 'd:\Users'
            Ensure = 'Present'
            Disabled = $false
            Template = '5 GB Limit'
        } # End of cFSRMAutoQuota Resource
    } # End of Node
} # End of Configuration
```

## Links
* **[GitHub Repo](https://github.com/PlagueHO/cFSRM)**: Raise any issues, requests or PRs here.
* **[My Blog](https://dscottraynsford.wordpress.com)**: See my PowerShell and Programming Blog.

