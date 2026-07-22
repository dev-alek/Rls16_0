option Explicit

'On Error Resume Next

dim wbemServices
dim wbemObjectSet
dim wbemObject
dim colOperatingSystems
dim objOperatingSystem
dim objAutoUpdate
dim objSettings
dim strScheduledTime
dim objSysInfo
dim objSession
dim objSearcher
dim intHistoryCount
dim colHistory
dim objEntry
dim objIdentity

Set wbemServices = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.")

WScript.Echo "#########################################################################"
WScript.Echo "Конфигурация загрузки"
Set wbemObjectSet = wbemServices.InstancesOf("Win32_BootConfiguration")
For Each wbemObject In wbemObjectSet
    WScript.Echo  wbemObject.Caption
    Wscript.Echo "Директория загрузки:                       " & wbemObject.BootDirectory
    Wscript.Echo "Временная директория:                      " & wbemObject.TempDirectory
Next
WScript.Echo vbCrLf


WScript.Echo "#########################################################################"
Set wbemObjectSet = wbemServices.InstancesOf("Win32_LogicalMemoryConfiguration")
For Each wbemObject In wbemObjectSet
    WScript.Echo "Размер физической оперативной памяти (kb):     " & wbemObject.TotalPhysicalMemory
    Wscript.Echo "Размер файла подгрузки (kb):                   " & wbemObject.TotalPageFileSpace
    Wscript.Echo "Размер виртуальной оперативной памяти (kb):    " & wbemObject.TotalVirtualMemory
    Wscript.Echo "Свободная виртуальная оперативная память (kb): " & wbemObject.AvailableVirtualMemory
Next
WScript.Echo vbCrLf

WScript.Echo "#########################################################################"
WScript.Echo "Оперативная система"
Set colOperatingSystems = wbemServices.InstancesOf("Win32_OperatingSystem")
For Each objOperatingSystem In colOperatingSystems
    Wscript.Echo "Name:            " & objOperatingSystem.Name   & vbCrLf & _
        "Caption:         " & objOperatingSystem.Caption         & vbCrLf & _
        "CurrentTimeZone: " & objOperatingSystem.CurrentTimeZone & vbCrLf & _
        "LastBootUpTime:  " & objOperatingSystem.LastBootUpTime  & vbCrLf & _
        "LocalDateTime:   " & objOperatingSystem.LocalDateTime   & vbCrLf & _
        "Locale:          " & objOperatingSystem.Locale          & vbCrLf & _
        "Manufacturer:    " & objOperatingSystem.Manufacturer    & vbCrLf & _
        "OSType:          " & objOperatingSystem. OSType         & vbCrLf & _
        "Version:         " & objOperatingSystem.Version         & vbCrLf & _
        "Service Pack:    " & objOperatingSystem.ServicePackMajorVersion  & _
                "." & objOperatingSystem.ServicePackMinorVersion & vbCrLf & _
        "Windows Directory: " & objOperatingSystem.WindowsDirectory
Next

WScript.Echo "#########################################################################"
WScript.Echo "Службы" & vbCrLf
Set wbemObjectSet = wbemServices.InstancesOf("Win32_Service")
For Each wbemObject In wbemObjectSet
    WScript.Echo "AcceptPause              : " & wbemObject.AcceptPause               & vbCrLf & _
                 "AcceptStop               : " & wbemObject.AcceptStop                & vbCrLf & _
                 "Caption                  : " & wbemObject.Caption                   & vbCrLf & _
                 "CheckPoint               : " & wbemObject.CheckPoint                & vbCrLf & _
                 "CreationClassName        : " & wbemObject.CreationClassName         & vbCrLf & _
                 "Description              : " & wbemObject.Description               & vbCrLf & _
                 "DesktopInteract          : " & wbemObject.DesktopInteract           & vbCrLf & _
                 "DisplayName              : " & wbemObject.DisplayName               & vbCrLf & _
                 "ErrorControl             : " & wbemObject.ErrorControl              & vbCrLf & _
                 "ExitCode                 : " & wbemObject.ExitCode                  & vbCrLf & _
                 "InstallDate              : " & wbemObject.InstallDate               & vbCrLf & _
                 "Name                     : " & wbemObject.Name                      & vbCrLf & _
                 "PathName                 : " & wbemObject.PathName                  & vbCrLf & _
                 "ProcessId                : " & wbemObject.ProcessId                 & vbCrLf & _
                 "ServiceSpecificExitCode  : " & wbemObject.ServiceSpecificExitCode   & vbCrLf & _
                 "ServiceType              : " & wbemObject.ServiceType               & vbCrLf & _
                 "Started                  : " & wbemObject.Started                   & vbCrLf & _
                 "StartMode                : " & wbemObject.StartMode                 & vbCrLf & _
                 "StartName                : " & wbemObject.StartName                 & vbCrLf & _
                 "State                    : " & wbemObject.State                     & vbCrLf & _
                 "Status                   : " & wbemObject.Status                    & vbCrLf & _
                 "SystemCreationClassName  : " & wbemObject.SystemCreationClassName   & vbCrLf & _
                 "SystemName               : " & wbemObject.SystemName                & vbCrLf & _
                 "TagId                    : " & wbemObject.TagId                     & vbCrLf & _
                 "WaitHint                 : " & wbemObject.WaitHint                  & vbCrLf & _
                 vbCrLf
Next
WScript.Echo vbCrLf

'OSCreationClassName
'OSName

WScript.Echo "#########################################################################"
WScript.Echo "Процессы" & vbCrLf
Set wbemObjectSet = wbemServices.InstancesOf("Win32_Process")
For Each wbemObject In wbemObjectSet
    WScript.Echo "Caption                   : " & wbemObject.Caption                    & vbCrLf & _
                 "CreationClassName         : " & wbemObject.CreationClassName          & vbCrLf & _
                 "CreationDate              : " & wbemObject.CreationDate               & vbCrLf & _
                 "CSCreationClassName       : " & wbemObject.CSCreationClassName        & vbCrLf & _
                 "CSName                    : " & wbemObject.CSName                     & vbCrLf & _
                 "Description               : " & wbemObject.Description                & vbCrLf & _
                 "ExecutablePath            : " & wbemObject.ExecutablePath             & vbCrLf & _
                 "ExecutionState            : " & wbemObject.ExecutionState             & vbCrLf & _
                 "Handle                    : " & wbemObject.Handle                     & vbCrLf & _
                 "HandleCount               : " & wbemObject.HandleCount                & vbCrLf & _
                 "InstallDate               : " & wbemObject.InstallDate                & vbCrLf & _
                 "KernelModeTime            : " & wbemObject.KernelModeTime             & vbCrLf & _
                 "MaximumWorkingSetSize     : " & wbemObject.MaximumWorkingSetSize      & vbCrLf & _
                 "MinimumWorkingSetSize     : " & wbemObject.MinimumWorkingSetSize      & vbCrLf & _
                 "Name                      : " & wbemObject.Name                       & vbCrLf & _
                 "OtherOperationCount       : " & wbemObject.OtherOperationCount        & vbCrLf & _
                 "OtherTransferCount        : " & wbemObject.OtherTransferCount         & vbCrLf & _
                 "PageFaults                : " & wbemObject.PageFaults                 & vbCrLf & _
                 "PageFileUsage             : " & wbemObject.PageFileUsage              & vbCrLf & _
                 "ParentProcessId           : " & wbemObject.ParentProcessId            & vbCrLf & _
                 "PeakPageFileUsage         : " & wbemObject.PeakPageFileUsage          & vbCrLf & _
                 "PeakVirtualSize           : " & wbemObject.PeakVirtualSize            & vbCrLf & _
                 "PeakWorkingSetSize        : " & wbemObject.PeakWorkingSetSize         & vbCrLf & _
                 "Priority                  : " & wbemObject.Priority                   & vbCrLf & _
                 "PrivatePageCount          : " & wbemObject.PrivatePageCount           & vbCrLf & _
                 "ProcessId                 : " & wbemObject.ProcessId                  & vbCrLf & _
                 "QuotaNonPagedPoolUsage    : " & wbemObject.QuotaNonPagedPoolUsage     & vbCrLf & _
                 "QuotaPagedPoolUsage       : " & wbemObject.QuotaPagedPoolUsage        & vbCrLf & _
                 "QuotaPeakNonPagedPoolUsage: " & wbemObject.QuotaPeakNonPagedPoolUsage & vbCrLf & _
                 "QuotaPeakPagedPoolUsage   : " & wbemObject.QuotaPeakPagedPoolUsage    & vbCrLf & _
                 "ReadOperationCount        : " & wbemObject.ReadOperationCount         & vbCrLf & _
                 "ReadTransferCount         : " & wbemObject.ReadTransferCount          & vbCrLf & _
                 "SessionId                 : " & wbemObject.SessionId                  & vbCrLf & _
                 "Status                    : " & wbemObject.Status                     & vbCrLf & _
                 "TerminationDate           : " & wbemObject.TerminationDate            & vbCrLf & _
                 "ThreadCount               : " & wbemObject.ThreadCount                & vbCrLf & _
                 "UserModeTime              : " & wbemObject.UserModeTime               & vbCrLf & _
                 "VirtualSize               : " & wbemObject.VirtualSize                & vbCrLf & _
                 "WindowsVersion            : " & wbemObject.WindowsVersion             & vbCrLf & _
                 "WorkingSetSize            : " & wbemObject.WorkingSetSize             & vbCrLf & _
                 "WriteOperationCount       : " & wbemObject.WriteOperationCount        & vbCrLf & _
                 "WriteTransferCount        : " & wbemObject.WriteTransferCount         & vbCrLf & _
                 vbCrLf
Next
WScript.Echo vbCrLf

'WScript.Echo "#########################################################################"
'WScript.Echo "Нити" & vbCrLf
'Set wbemObjectSet = wbemServices.InstancesOf("Win32_Thread")
'For Each wbemObject In wbemObjectSet
'    WScript.Echo "Caption                 : " & wbemObject.Caption                  & vbCrLf & _
'                 "CreationClassName       : " & wbemObject.CreationClassName        & vbCrLf & _
'                 "CSCreationClassName     : " & wbemObject.CSCreationClassName      & vbCrLf & _
'                 "CSName                  : " & wbemObject.CSName                   & vbCrLf & _
'                 "Description             : " & wbemObject.Description              & vbCrLf & _
'                 "ElapsedTime             : " & wbemObject.ElapsedTime              & vbCrLf & _
'                 "ExecutionState          : " & wbemObject.ExecutionState           & vbCrLf & _
'                 "Handle                  : " & wbemObject.Handle                   & vbCrLf & _
'                 "InstallDate             : " & wbemObject.InstallDate              & vbCrLf & _
'                 "KernelModeTime          : " & wbemObject.KernelModeTime           & vbCrLf & _
'                 "Name                    : " & wbemObject.Name                     & vbCrLf & _
'                 "OSCreationClassName     : " & wbemObject.OSCreationClassName      & vbCrLf & _
'                 "OSName                  : " & wbemObject.OSName                   & vbCrLf & _
'                 "Priority                : " & wbemObject.Priority                 & vbCrLf & _
'                 "PriorityBase            : " & wbemObject.PriorityBase             & vbCrLf & _
'                 "ProcessCreationClassName: " & wbemObject.ProcessCreationClassName & vbCrLf & _
'                 "ProcessHandle           : " & wbemObject.ProcessHandle            & vbCrLf & _
'                 "StartAddress            : " & wbemObject.StartAddress             & vbCrLf & _
'                 "Status                  : " & wbemObject.Status                   & vbCrLf & _
'                 "ThreadState             : " & wbemObject.ThreadState              & vbCrLf & _
'                 "ThreadWaitReason        : " & wbemObject.ThreadWaitReason         & vbCrLf & _
'                 "UserModeTime            : " & wbemObject.UserModeTime             & vbCrLf & _
'                 vbCrLf
'Next
'WScript.Echo vbCrLf

WScript.Echo "#########################################################################"
WScript.Echo "Подключения" & vbCrLf
Set wbemObjectSet = wbemServices.InstancesOf("Win32_NetworkConnection")
For Each wbemObject In wbemObjectSet
    WScript.Echo "Caption:         " & wbemObject.Caption & vbCrLf & _
                 "Comment:         " & wbemObject.Comment & vbCrLf & _
                 "ConnectionState: " & wbemObject.ConnectionState & vbCrLf & _
                 "ConnectionType:  " & wbemObject.ConnectionType & vbCrLf & _
                 "Description:     " & wbemObject.Description  & vbCrLf & _
                 "DisplayType:     " & wbemObject.DisplayType  & vbCrLf & _
                 "LocalName:       " & wbemObject.LocalName    & vbCrLf & _
                 "Name:            " & wbemObject.Name         & vbCrLf & _
                 "Persistent:      " & wbemObject.Persistent   & vbCrLf & _
                 "ProviderName:    " & wbemObject.ProviderName & vbCrLf & _
                 "RemoteName:      " & wbemObject.RemoteName   & vbCrLf & _
                 "RemotePath:      " & wbemObject.RemotePath   & vbCrLf & _
                 "ResourceType:    " & wbemObject.ResourceType & vbCrLf & _
                 "Status:          " & wbemObject.Status       & vbCrLf & _
                 "UserName:        " & wbemObject.UserName     & vbCrLf & _
                 vbCrLf
Next
WScript.Echo vbCrLf

WScript.Echo "#########################################################################"
WScript.Echo "Сетевые устройства" & vbCrLf
'Set wbemObjectSet = wbemServices.InstancesOf("Win32_PnPEntity")
Set wbemObjectSet = wbemServices.ExecQuery("Select * from Win32_PnPEntity Where ClassGuid = '{4D36E972-E325-11CE-BFC1-08002BE10318}'")
For Each wbemObject In wbemObjectSet
    WScript.Echo "ClassGuid              : " & wbemObject.ClassGuid              & vbCrLf & _
                 "Description            : " & wbemObject.Description            & vbCrLf & _
                 "DeviceID               : " & wbemObject.DeviceID               & vbCrLf & _
                 "Manufacturer           : " & wbemObject.Manufacturer           & vbCrLf & _
                 "Name                   : " & wbemObject.Name                   & vbCrLf & _
                 "PNPDeviceID            : " & wbemObject.PNPDeviceID            & vbCrLf & _
                 "Service                : " & wbemObject.Service                & vbCrLf & _
                 "ConfigManagerErrorCode : " & wbemObject.ConfigManagerErrorCode & vbCrLf & _
                 vbCrLf
Next
WScript.Echo vbCrLf


WScript.Echo "#########################################################################"
WScript.Echo "Сетевые протоколы" & vbCrLf
Set wbemObjectSet = wbemServices.InstancesOf("Win32_NetworkProtocol")
For Each wbemObject In wbemObjectSet
    WScript.Echo "Caption                    : " & wbemObject.Caption                     & vbCrLf & _
                 "ConnectionlessService      : " & wbemObject.ConnectionlessService       & vbCrLf & _
                 "Description                : " & wbemObject.Description                 & vbCrLf & _
                 "GuaranteesDelivery         : " & wbemObject.GuaranteesDelivery          & vbCrLf & _
                 "GuaranteesSequencing       : " & wbemObject.GuaranteesSequencing        & vbCrLf & _
                 "InstallDate                : " & wbemObject.InstallDate                 & vbCrLf & _
                 "MaximumAddressSize         : " & wbemObject.MaximumAddressSize          & vbCrLf & _
                 "MaximumMessageSize         : " & wbemObject.MaximumMessageSize          & vbCrLf & _
                 "MessageOriented            : " & wbemObject.MessageOriented             & vbCrLf & _
                 "MinimumAddressSize         : " & wbemObject.MinimumAddressSize          & vbCrLf & _
                 "Name                       : " & wbemObject.Name                        & vbCrLf & _
                 "PseudoStreamOriented       : " & wbemObject.PseudoStreamOriented        & vbCrLf & _
                 "Status                     : " & wbemObject.Status                      & vbCrLf & _
                 "SupportsBroadcasting       : " & wbemObject.SupportsBroadcasting        & vbCrLf & _
                 "SupportsConnectData        : " & wbemObject.SupportsConnectData         & vbCrLf & _
                 "SupportsDisconnectData     : " & wbemObject.SupportsDisconnectData      & vbCrLf & _
                 "SupportsEncryption         : " & wbemObject.SupportsEncryption          & vbCrLf & _
                 "SupportsExpeditedData      : " & wbemObject.SupportsExpeditedData       & vbCrLf & _
                 "SupportsFragmentation      : " & wbemObject.SupportsFragmentation       & vbCrLf & _
                 "SupportsGracefulClosing    : " & wbemObject.SupportsGracefulClosing     & vbCrLf & _
                 "SupportsGuaranteedBandwidth: " & wbemObject.SupportsGuaranteedBandwidth & vbCrLf & _
                 "SupportsMulticasting       : " & wbemObject.SupportsMulticasting        & vbCrLf & _
                 "SupportsQualityofService   : " & wbemObject.SupportsQualityofService    & vbCrLf & _
                 vbCrLf
Next
WScript.Echo vbCrLf

WScript.Echo "#########################################################################"
WScript.Echo "Автообновление Windows" & vbCrLf
Set objAutoUpdate = CreateObject("Microsoft.Update.AutoUpdate")
Set objSettings = objAutoUpdate.Settings

Select Case objSettings.NotificationLevel
    Case 0
        Wscript.Echo "Notification level: Automatic Updates is not configured by the user " & _
            "or by a Group Policy administrator."
    Case 1
        Wscript.Echo "Notification level: Automatic Updates is disabled."
    Case 2
        Wscript.Echo "Notification level: Automatic Updates prompts users to approve updates " & _
            "before downloading or installing."
    Case 3
        Wscript.Echo "Notification level: Automatic Updates automatically downloads " & _
             "updates, but prompts users to approve them before installation."
    Case 4
        Wscript.Echo "Notification level: Automatic Updates automatically installs " & _
            "updates per the schedule specified by the user."
    Case Else
        Wscript.Echo "Notification level could not be determined."
End Select

Select Case objSettings.ScheduledInstallationDay
    Case 0
        Wscript.Echo "Scheduled installation day: Every day"
    Case 1
        Wscript.Echo "Scheduled installation day: Sunday"
    Case 2
        Wscript.Echo "Scheduled installation day: Monday"
    Case 3
        Wscript.Echo "Scheduled installation day: Tuesday"
    Case 4
        Wscript.Echo "Scheduled installation day: Wednesday"
    Case 5
        Wscript.Echo "Scheduled installation day: Thursday"
    Case 6
        Wscript.Echo "Scheduled installation day: Friday"
    Case 7
        Wscript.Echo "Scheduled installation day: Saturday"
    Case Else
        Wscript.Echo "The scheduled installation day is could not be determined."
End Select

WScript.Echo vbCrLf
WScript.Echo vbCrLf

If objSettings.ScheduledInstallationTime = 0 Then
    Wscript.Echo "Scheduled installation time: 12:00 AM"
ElseIf objSettings.ScheduledInstallationTime = 12 Then
    Wscript.Echo "Scheduled installation time: 12:00 PM"
Else
    If objSettings.ScheduledInstallationTime > 12 Then
        intScheduledTime = objSettings.ScheduledInstallationTime - 12
        strScheduledTime = intScheduledTime & ":00 PM"
    Else
        strScheduledTime = objSettings.ScheduledInstallationTime & ":00 AM"
    End If
    Wscript.Echo "Scheduled installation time: " & strScheduledTime
End If
WScript.Echo vbCrLf


WScript.Echo "#########################################################################"
WScript.Echo "Флаг перезагрузки компьютера" & vbCrLf
Set objSysInfo = CreateObject("Microsoft.Update.SystemInfo")

If objSysInfo.RebootRequired Then
    Wscript.Echo "This computer needs to be rebooted."
Else
    Wscript.Echo "This computer does not need to be rebooted."
End If
WScript.Echo vbCrLf


WScript.Echo "#########################################################################"
WScript.Echo "Установленные обновления" & vbCrLf

Set objSession = CreateObject("Microsoft.Update.Session")
Set objSearcher = objSession.CreateUpdateSearcher
intHistoryCount = objSearcher.GetTotalHistoryCount

Set colHistory = objSearcher.QueryHistory(0, intHistoryCount)

For Each objEntry in colHistory
    Wscript.Echo "Title: " & objEntry.Title
'    Wscript.Echo "Description: " & objEntry.Description
    Wscript.Echo "Update application date: " & objEntry.Date

    Select Case objEntry.Operation
        Case 1
            Wscript.Echo "Operation type: Installation"
        Case 2
            Wscript.Echo "Operation type: Uninstallation"
        Case Else
            Wscript.Echo "The operation type could not be determined."
    End Select

    Select Case objEntry.ResultCode
        Case 0
            Wscript.Echo "Operation result: The operation has not started."
        Case 1
            Wscript.Echo "Operation result: The operation is in progress."
        Case 2
            Wscript.Echo "Operation result: The operation completed successfully."
        Case 3
            Wscript.Echo "Operation result: The operation completed, but one or more errors occurred " & _
            "during the operation and the results are potentially incomplete."
        Case 4
            Wscript.Echo "Operation result: The operation failed to complete."
        Case 5
            Wscript.Echo "Operation result: The operation was aborted."
        Case Else
            Wscript.Echo "The operation result could not be determined."
    End Select

    Set objIdentity = objEntry.UpdateIdentity
    Wscript.Echo "Update ID: " & objIdentity.UpdateID
    Wscript.Echo
Next
WScript.Echo vbCrLf

WScript.Echo "#########################################################################"
WScript.Echo "Установленные приложения" & vbCrLf
Set wbemObjectSet = wbemServices.InstancesOf("Win32_Product")
For Each wbemObject In wbemObjectSet
    WScript.Echo "Name: " & wbemObject.Name & vbCrLf & _
                 "Version: " & wbemObject.Version & vbCrLf & _
                 "IdentifyingNumber: " & wbemObject.IdentifyingNumber & vbCrLf & _
                 vbCrLf
Next
WScript.Echo vbCrLf

WScript.Echo "#########################################################################"
WScript.Echo "Сообщения об ошибках из журнала NTLogEvent" & vbCrLf
Set wbemObjectSet = wbemServices.ExecQuery("SELECT * FROM Win32_NTLogEvent Where type = 'error'")

For Each wbemObject In wbemObjectSet
    WScript.Echo "Log File:        " & wbemObject.LogFile        & vbCrLf & _
                 "Record Number:   " & wbemObject.RecordNumber   & vbCrLf & _
                 "Type:            " & wbemObject.Type           & vbCrLf & _
                 "Time Generated:  " & wbemObject.TimeGenerated  & vbCrLf & _
                 "Source:          " & wbemObject.SourceName     & vbCrLf & _
                 "Category:        " & wbemObject.Category       & vbCrLf & _
                 "Category String: " & wbemObject.CategoryString & vbCrLf & _
                 "Event:           " & wbemObject.EventCode      & vbCrLf & _
                 "User:            " & wbemObject.User           & vbCrLf & _
                 "Computer:        " & wbemObject.ComputerName   & vbCrLf & _
                 "Message:         " & wbemObject.Message        & vbCrLf
Next
WScript.Echo vbCrLf


WScript.Echo "SCRIPT EOF"