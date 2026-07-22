Function w_entry(sList As Variant, iItem As Variant, sDelimiter As Variant) As Variant
' ¬ход: sList - исходна€ строка (список строк, разделенных sDelimiter),
'       iItem - номер строки из списка s
' ¬ыход: возвращает строку номер iItem из списка sList
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


Sub Main_Macros(vParameters as String, vDelimiter as String)
' kol-obj количество объектов
' header-rows количество строчек шапки
' v_ci - цвет
Dim Header_Rows, kol_obj, v_ci As Integer
Dim kol_objv, Header_rowsv as Variant
Dim ii, week_shift, itog_col As Integer
DIm ObjectRange, TotalsRange as Range
' ii текуща€ строка
' week_shift - смещение по неделе - дл€ раскрашивани
' itog_col - счет итоговых колонок в которых необходимо сли€ние
' i-entry - текущий entry дл€ разбора строки параметров
kol_objv = w_entry(vParameters,  1, vDelimiter)
Header_rowsv = w_entry(vParameters, 2, vDelimiter)
if kol_objv = Null or Header_rowsv = Null then
  msgbox "null"
  exit Sub
end if
if kol_objv = 0 or Header_rowsv = 0 then
  msgbox "0"
  exit Sub
end if
kol_obj = cint(kol_objv)
Header_rows = cint(Header_rowsv)
ii = Header_ROws
Do While ii < ActiveSheet.Cells.SpecialCells(xlLastCell).Row
  week_shift = 0
  Do While week_shift < 28
     If ii + week_shift + 7 > ActiveSheet.Cells.SpecialCells(xlLastCell).Row Then Exit Do
     Set ObjectRange =  Range(Cells(ii + week_shift, 1), Cells(ii + week_shift + 6, 3 + kol_obj * 3 + 4 - 1))
      ObjectRange.Borders(xlDiagonalDown).LineStyle = xlNone
      ObjectRange.Borders(xlDiagonalUp).LineStyle = xlNone
      ObjectRange.Borders(xlEdgeLeft).LineStyle = xlNone
      With ObjectRange.Borders(xlEdgeTop)
          .LineStyle = xlContinuous
          .Weight = xlThin
          .ColorIndex = xlAutomatic
      End With
      ObjectRange.Borders(xlEdgeBottom).LineStyle = xlNone
      ObjectRange.Borders(xlEdgeRight).LineStyle = xlNone
      With ObjectRange.Borders(xlInsideVertical)
          .LineStyle = xlContinuous
          .Weight = xlThin
          .ColorIndex = xlAutomatic
      End With
      With ObjectRange.Borders(xlInsideHorizontal)
          .LineStyle = xlContinuous
          .Weight = xlThin
          .ColorIndex = xlAutomatic
      End With
      Select Case week_shift
        Case 0
            v_ci = 37
        Case 7
            v_ci = 34
        Case 14
            v_ci = 35
        Case 21
            v_ci = 36
        End Select
      With ObjectRange.Interior
          .ColorIndex = v_ci
          .Pattern = xlSolid
          .PatternColorIndex = xlAutomatic
      End With
      ' сли€ние €чеек дл€ итогов по неделе
      itog_col = 0
      Do While itog_col < 2
         Set TotalsRange =  Range(Cells(ii + week_shift, 3 + kol_obj * 3 + 2 + itog_col), Cells(ii + week_shift + 6, 3 + kol_obj * 3 + 2 + itog_col))
         With TotalsRange
              .HorizontalAlignment = xlCenter
              .VerticalAlignment = xlCenter
              .WrapText = False
              .Orientation = 0
              .AddIndent = False
              .ShrinkToFit = False
              .MergeCells = True
          End With
          itog_col = itog_col + 1
    Loop
    week_shift = week_shift + 7
  Loop
  ii = ii + 28
Loop
End Sub
