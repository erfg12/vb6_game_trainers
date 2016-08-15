VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3465
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4950
   LinkTopic       =   "Form1"
   ScaleHeight     =   3465
   ScaleWidth      =   4950
   StartUpPosition =   3  'Windows Default
   Begin VB.Timer Timer1 
      Interval        =   1000
      Left            =   4440
      Top             =   2880
   End
   Begin VB.TextBox Text1 
      Height          =   285
      Left            =   600
      TabIndex        =   0
      Top             =   240
      Width           =   495
   End
   Begin VB.Label Label1 
      Caption         =   "Time:"
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   240
      Width           =   495
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim mm As New MemoryManager

Private Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
Private Declare Function GetWindowThreadProcessId Lib "user32" (ByVal hwnd As Long, ByRef lpdwProcessId As Long) As Long

Public test As String

Private Sub Form_Load()
    test = "80DF4ED4" 'chips challenge non-static. Will change on re-boot
    mm.pid = mm.GetProcessIdByName("chips") 'open pid for read/write
End Sub

Private Sub Timer1_Timer()
    mm.writeInteger CLng("&H" + test), 99
    someByteValue = mm.readInteger(CLng("&H" + test))
    Text1.Text = someByteValue
End Sub
