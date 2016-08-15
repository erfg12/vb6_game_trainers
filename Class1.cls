VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MemoryManager"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'some of this code comes from RANCID at zonehacks forums

Option Explicit

Private Declare Function OpenProcess Lib "kernel32" (ByVal dwDesiredAccess As Long, ByVal bInheritHandle As Long, ByVal dwProcessId As Long) As Long
Private Declare Function GetWindowThreadProcessId Lib "user32" (ByVal hwnd As Long, lpdwProcessId As Long) As Long

Private Declare Function ReadProcessMemory Lib "kernel32" (ByVal hProcess As Long, lpBaseAddress As Any, lpBuffer As Any, ByVal nSize As Long, lpNumberOfBytesWritten As Long) As Long
Private Declare Function WriteProcessMemory Lib "kernel32" (ByVal hProcess As Long, lpBaseAddress As Any, lpBuffer As Any, ByVal nSize As Long, lpNumberOfBytesWritten As Long) As Long

Private Declare Function CreateToolhelp32Snapshot Lib "kernel32" (ByVal dwFlags As Long, ByVal th32ProcessID As Long) As Long
Private Declare Function Process32First Lib "kernel32" (ByVal hSnapshot As Long, lppe As PROCESSENTRY32) As Boolean
Private Declare Function Process32Next Lib "kernel32" (ByVal hSnapshot As Long, lppe As PROCESSENTRY32) As Boolean

Private Declare Function CloseHandle Lib "kernel32" (ByVal hObject As Long) As Long

Private Type PROCESSENTRY32
    dwSize As Long
    cntUsage As Long
    th32ProcessID As Long
    th32DefaultHeapID As Long
    th32ModuleID As Long
    cntThreads As Long
    th32ParentProcessID As Long
    pcPriClassBase As Long
    dwFlags As Long
    szExeFile As String * 260
End Type

Private hPid As Long
Private hProcess As Long

Public Property Let pid(dwPid As Long)
    hPid = dwPid
    hProcess = OpenProcess(&H1F0FFF, False, hPid)
End Property

Public Property Get pid() As Long
    pid = hPid
End Property

Public Function GetProcessIdByName(ByVal szProcessName As String) As Long
    Dim pe32 As PROCESSENTRY32
    Dim hSnapshot As Long
    Dim bFoundProc As Boolean
    Dim dwProcId As Long
    
    dwProcId = 0
    pe32.dwSize = Len(pe32)
    hSnapshot = CreateToolhelp32Snapshot(2&, 0&)
    bFoundProc = Process32First(hSnapshot, pe32)
    
    Do While bFoundProc
        If InStr(LCase(pe32.szExeFile), LCase(szProcessName)) > 0 Then
            dwProcId = pe32.th32ProcessID
            Exit Do
        End If
        bFoundProc = Process32Next(hSnapshot, pe32)
    Loop
    
    Call CloseHandle(hSnapshot)
    GetProcessIdByName = dwProcId
End Function

Public Sub writeByte(lngAddress As Long, bVal As Byte)
    WritePtr lngAddress, VarPtr(bVal), 1
End Sub

Public Sub writeInteger(lngAddress As Long, intValue As Integer)
    WritePtr lngAddress, VarPtr(intValue), 2
End Sub

Public Sub writeSingle(lngAddress As Long, sngValue As Single)
    WritePtr lngAddress, VarPtr(sngValue), 4
End Sub

Public Sub writeLong(lngAddress As Long, lngValue As Long)
    WritePtr lngAddress, VarPtr(lngValue), 4
End Sub

Public Sub WriteString(lngAddress As Long, strValue As String)
    Dim lngBytesWritten As Long
    WriteProcessMemory hProcess, ByVal lngAddress, ByVal strValue, Len(strValue), lngBytesWritten
End Sub

Public Function WritePtr(lngAddress As Long, destPtr As Long, length As Long) As Long
    Dim lngBytesWritten As Long
    WriteProcessMemory hProcess, ByVal lngAddress, ByVal destPtr, length, lngBytesWritten
    WritePtr = lngBytesWritten
End Function

Public Function copyToType(destPtr As Long, length As Long, lngAddr As Long) As Boolean
    copyToType = (ReadProcessMemory(hProcess, ByVal lngAddr, ByVal destPtr, length, &H0) <> 0)
End Function

Public Function readLong(lngAddr As Long) As Long
    copyToType VarPtr(readLong), 4, lngAddr
End Function

Public Function readInteger(lngAddr As Long) As Integer
    copyToType VarPtr(readInteger), 2, lngAddr
End Function

Public Function readSingle(lngAddr As Long) As Single
    copyToType VarPtr(readSingle), 4, lngAddr
End Function

Public Function readByte(lngAddr As Long) As Byte
    copyToType VarPtr(readByte), 1, lngAddr
End Function

'//strings ends at null characters
Public Function readString(length As Long, lngAddr As Long) As String
    Dim strTmp As String, i As Long
     
    strTmp = String(length, 0)

    If (ReadProcessMemory(hProcess, ByVal lngAddr, ByVal strTmp, length, &H0) <> 0) Then
        i = InStr(strTmp, Chr(0))
         
        If i > 0 Then strTmp = Left(strTmp, i - 1)
         
        readString = strTmp
         
        lngBaseAddr = lngBaseAddr + length
    End If
End Function

'//string contains null characters
Public Function readStringN(length As Long, lngAddr As Long) As String
    Dim strTmp As String, i As Long
     
    strTmp = String(length, 0)

    If (ReadProcessMemory(hProcess, ByVal lngAddr, ByVal strTmp, length, &H0) <> 0) Then
        readStringN = strTmp
    End If
End Function
