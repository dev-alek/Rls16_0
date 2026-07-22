'
'$Revision$
'$Author$
'$Date$
'$Workfile$
'$Archive$
'
'Макрос постформатирования в Excel при выводе списка товаров
'
'Автор: Бахтадзе Наталья Викторовна
'Дата создания: 10/13/05
'Author: Bakhtadze Natalya
'Creation date: 10/13/05
'
'
' &scoped-define vssseq {&sequence}
' define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision: $".

Function w_entry(sList As Variant, iItem As Variant, sDelimiter As Variant) As Variant
' Вход: sList - исходная строка (список строк, разделенных sDelimiter),
'       iItem - номер строки из списка s
' Выход: возвращает строку номер iItem из списка sList
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

Sub Main_Macros(vParameters As String, vDelimiter As String)
Dim Num_Column, Ii, Header_rows As Integer
Dim num_column_chr, Header_rowsv As String
Header_rowsv = w_entry(vParameters, 1, vDelimiter)
Header_rows = CInt(Header_rowsv)
Ii = Ii + 1
Do While True
  Ii = Ii + 1
    num_column_chr = w_entry(vParameters, Ii, vDelimiter)
    On Error GoTo Exit_Do
    If num_column_chr = Null Then Exit Do
    Num_Column = CInt(num_column_chr)
    Range(Cells(Header_rows + 1, Num_Column), Cells(ActiveSheet.Cells.SpecialCells(xlLastCell).Row, Num_Column)).Select
    With Selection.Font
         .Name = "CourierARTCTT"
        .FontStyle = "Regular"
        .Size = 12
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .ColorIndex = xlAutomatic
    End With
Loop
Exit_Do:
Cells.Select
Selection.RowHeight = 30
End Sub


'$Workfile$ e n d