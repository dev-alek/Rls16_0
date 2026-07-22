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
' kol-obj количество объектов
' header-rows количество строчек шапки
Dim Header_Rows, kol_obj  As Integer
Dim kol_objv, Header_rowsv as Variant
Dim ii, iEndRow As Integer
Dim sRowNum As String
DIm ObjectRange, FirstRange as Range
' ii текущая строка


  iEndRow = ActiveSheet.Cells.SpecialCells(xlCellTypeLastCell).Row

  For ii = 1 To iEndRow
      sRowNum = "A" + Trim(Str(ii))
      If Trim(Range(sRowNum).Value) = "Итого накладных" Then Exit For
  Next ii
     ii = ii - 1
' Выделить все границы
     Set ObjectRange =  Range(Cells(6,1), Cells(ii,6))
    ObjectRange.Borders(xlDiagonalDown).LineStyle = xlNone
    ObjectRange.Borders(xlDiagonalUp).LineStyle = xlNone
    With ObjectRange.Borders(xlEdgeLeft)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With
    With ObjectRange.Borders(xlEdgeTop)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With
    With ObjectRange.Borders(xlEdgeBottom)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With
    With ObjectRange.Borders(xlEdgeRight)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With
    With ObjectRange.Borders(xlInsideVertical)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With
    With ObjectRange.Borders(xlInsideHorizontal)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .TintAndShade = 0
        .Weight = xlThin
    End With


' Выравнивание тела отчета по значению
    With ObjectRange.Selection
        .HorizontalAlignment = xlGeneral
        .VerticalAlignment = xlJustify
        .Orientation = 0
        .AddIndent = False
        .IndentLevel = 0
        .ShrinkToFit = False
        .ReadingOrder = xlContext
        .MergeCells = False
      End With
End Sub
