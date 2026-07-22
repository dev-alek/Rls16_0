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


Sub Main_Macros(vParameters as String, vDelimiter as String)
' kol-obj количество секций
' header-rows количество строчек шапки
' v_ci - цвет
Dim HR, kol_sections, v_ci, lc As Integer
Dim kol_sectionsv, Header_rowsv as Variant
Dim ii As Integer
DIm ObjectRange, TotalsRange as Range
' ii текущая строка
' week_shift - смещение по неделе - для раскрашивани
' itog_col - счет итоговых колонок в которых необходимо слияние
' i-entry - текущий entry для разбора строки параметров
kol_sectionsv = w_entry(vParameters,  1, vDelimiter)
Header_rowsv = w_entry(vParameters, 2, vDelimiter)
if kol_sectionsv = Null  or Header_rowsv = Null  then
'  msgbox "null"
  exit Sub
end if
if kol_sectionsv = 0  or Header_rowsv = 0 then
'  msgbox "0"
  exit Sub
end if
kol_sections = cint(kol_sectionsv)
Hr = cint(Header_rowsv)
lc = ActiveSheet.Cells.SpecialCells(xlLastCell).Row
ii = 1
Do While ii <= kol_sections
     iimod = ii Mod 2
     Select Case iimod
        Case 0
            v_ci = 34
        Case 1
            v_ci = 19
        End Select

    Set ObjectRange =  Range(Cells(hr + 1, 3 + 3 * (ii - 1) + 1), Cells(lc, 3 + 3 * (ii - 1) + 3))
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
    With ObjectRange.Interior
          .ColorIndex = v_ci
          .Pattern = xlSolid
          .PatternColorIndex = xlAutomatic
    End With
  ii = ii + 1
Loop
End Sub
