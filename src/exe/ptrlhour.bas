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
    Dim vBookName As String, vColumnList As String
    Dim vTotalRows As String, vTotalCols As String, vGreenRows As String, vGreenList As String
    Dim jTotalRows As Integer, jTotalCols As Integer, jGreenRows As Integer
    Dim jCurrRow As Integer, jCount As Integer

    vTotalRows = w_entry(vParam, 1, vDelimiter)
    If vTotalRows = null Then
        MsgBox "Не указано количество строк."
        Exit Sub
    End If
    jTotalRows = CInt(vTotalRows) + 7
    On Error GoTo Err_Row
    If jTotalRows <= 0 Then
        GoTo Err_Row
    End If
    vTotalCols = w_entry(vParam, 2, vDelimiter)
    If vTotalCols = null Then
        MsgBox "Не указано количество столбцов."
        Exit Sub
    End If
    jTotalCols = CInt(vTotalCols)
    On Error GoTo Err_Col
    If jTotalCols <= 0 Then
        GoTo Err_Col
    End If
    vGreenList = w_entry(vParam, 3, vDelimiter)
    If vGreenList = null Then
        MsgBox "Не указаны итоговые строки."
        Exit Sub
    End If
    vGreenRows = w_entry(vGreenList, 1, "#")
    If vGreenRows = null Then
        MsgBox "Не указано количество строк итогов."
        Exit Sub
    End If
    jGreenRows = CInt(vGreenRows)
    On Error GoTo Err_TotalRows
    vGreenList = w_entry(vGreenList, 2, "#")
    If vGreenList = null Then
        MsgBox "Неверный список строк итогов."
        Exit Sub
    End If
    vColumnList = w_entry(vParam, 4, vDelimiter)
    If vGreenList = null Then
        MsgBox "Неверный список колонок."
        Exit Sub
    End If
    vBookName = w_entry(vParam, 5, vDelimiter)
    If vBookName = null Then
        MsgBox "Не указана книга (null)."
        Exit Sub
    End If
    On Error GoTo Err_Handle
    With Workbooks(vBookName).Worksheets(1)
        With .Range(.Cells(1, 1), .Cells(1, jTotalCols))
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            With .Font
                .Bold = True
                .Size = 14
            End With
        End With
        With .Range(.Cells(2, 1), .Cells(2, jTotalCols))
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            With .Font
                .Bold = True
                .Size = 14
            End With
        End With
        With .Range(.Cells(6, 1), .Cells(6, jTotalCols))
            .HorizontalAlignment = xlRight
            .VerticalAlignment = xlCenter
            .Font.Size = 10
        End With
        With .Range(.Cells(7, 1), .Cells(7, jTotalCols))
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            .Interior.ColorIndex = xlNone
        End With
        For jCount = 1 To jGreenRows
            jCurrRow = CInt(w_entry(vGreenList, jCount, ","))
            With .Range(.Cells(jCurrRow + 7, 1), .Cells(jCurrRow + 7, jTotalCols))
                .Font.Bold = True
                With .Borders(xlEdgeTop)
                    .LineStyle = xlContinuous
                    .Weight = xlThin
                    .ColorIndex = xlAutomatic
                End With
                With .Borders(xlEdgeBottom)
                    .LineStyle = xlContinuous
                    .Weight = xlThin
                    .ColorIndex = xlAutomatic
                End With
            End With
        Next jCount
'        For jCount = 1 To jTotalCols
'           .Range(.Cells(8, jCount), .Cells(jTotalRows, jCount)).NumberFormat = w_entry(vColumnList, jCount, ";")
'        Next jCount
    End With
    Exit Sub
Err_Row:
    MsgBox "Неверно указано количество строк."
    Exit Sub
Err_Col:
    MsgBox "Неверно указано количество столбцов."
    Exit Sub
Err_TotalRows:
    MsgBox "Неверно указано количество строк итогов."
    Exit Sub
Err_Handle:
    MsgBox "Ошибка выполнения макроса: " & Err.Number & "  '" & Err.Description & "' . "
    Exit Sub
End Sub


