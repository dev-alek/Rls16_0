' $Revision$
' $Author$
' $Date$
' $Workfile$
' $Archive$
'
' Макрос к отчету контроль ассортиментной матрицы
'
' Автор: Сливенко Сергей Андреевич
' Дата создания: 28/09/11
' Author: Sergey Slivenko
' Creation date: 28/09/11
Option Explicit

Function w_num_entries(sList As String, sDelimiter As String) As Integer
  Dim sArray() As String, iCount As Integer

  If IsNull(sList) Then
      w_num_entries = 0
      Exit Function
  End If

  sArray = Split(sList, sDelimiter)
  If IsNull(sArray) Then
      w_num_entries = 0
      Exit Function
  End If
  w_num_entries = UBound(sArray) + 1
End Function

Function w_entry(sList As Variant, iItem As Variant, sDelimiter As Variant) As Variant
    Dim iPos As Integer, iLen As Integer, i As Integer

    If IsNull(sList) Then
        w_entry = Null
        Exit Function
    End If
    If iItem <= 0 Then
        w_entry = Null
        Exit Function
    End If
    iPos = InStr(1, sList, sDelimiter, vbBinaryCompare)
    If iPos = 0 Then
        w_entry = IIf(iItem = 1, sList, Null)
        Exit Function
    End If
    If iItem = 1 Then
        iLen = iPos - 1
        w_entry = Mid(sList, 1, iLen)
        Exit Function
    End If
    For i = 1 To iItem - 2
        iPos = InStr(iPos + 1, sList, sDelimiter)
        If iPos = 0 Then
            w_entry = Null
            Exit Function
        End If
    Next i
    iLen = InStr(iPos + 1, sList, sDelimiter)
    If iLen = 0 Then
        iLen = Len(sList) - iPos
    Else
        iLen = iLen - iPos - 1
    End If
    w_entry = Mid(sList, iPos + 1, iLen)
End Function

Sub Main_Macros(vParam As String, vDelimiter As String)
  Dim iNumEntries As Integer , iNumEntry As Integer , iEntry As String , iEntryCheck as Integer
  Dim iFirstRow As Integer, iRow As Integer , iEndRow As Integer, sRowNum As String
  Dim iStartGroup As Integer , iEndGroup As Integer
  Dim sStartGroup As String , sEndGroup As String

  iNumEntries = w_num_entries(vParam,vDelimiter)

    With ActiveSheet.Outline
        .AutomaticStyles = False
        .SummaryRow = xlAbove
        .SummaryColumn = xlRight
    End With


  If iNumEntries = 2 Then
    iEntryCheck = w_num_entries(vParam,chr(1))
    If iEntryCheck = 1 Then Exit Sub
  End If

  iEndRow = ActiveSheet.Cells.SpecialCells(xlCellTypeLastCell).Row

  For iRow = 1 To iEndRow
      sRowNum = "A" + Trim(Str(iRow))
      If Trim(Range(sRowNum).Value) = "№ АЗС и кафе" Then Exit For
  Next iRow
  iFirstRow = iRow + 1
  iNumEntries = iNumEntries - 1

  For iNumEntry = 1 To iNumEntries
    iEntry = w_entry(vParam, iNumEntry, vDelimiter)
    iEntryCheck = w_num_entries(iEntry,chr(1))
    If iEntryCheck = 2 Then
      sStartGroup = w_entry(iEntry, 1, chr(1))
      sEndGroup = w_entry(iEntry, 2, chr(1))
      iStartGroup = CInt(w_entry(iEntry, 1, chr(1))) + iFirstRow
      iEndGroup = CInt(w_entry(iEntry, 2, chr(1))) + iFirstRow
      Rows(Trim(Str(iStartGroup)) + ":" + Trim(Str(iEndGroup))).Select
      Selection.Rows.Group
    End If
  Next iNumEntry

  ActiveSheet.Outline.ShowLevels RowLevels:=2
  ActiveSheet.Outline.ShowLevels RowLevels:=1

  Columns("B:I").Select
  Selection.NumberFormat = "#,##0.00"


End Sub
