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
    Dim vFirstItem As String, vBookName As String, w_LastItem As String
    Dim vTotalRows As String, vTotalCols As String, vGreenRows As String, vGreenList As String, vColList As String
    Dim jTotalRows As Integer, jTotalCols As Integer, jGreenRows As Integer

    vFirstItem = w_entry(vParam, 1, vDelimiter)
    If vFirstItem = null Then
        MsgBox "Не указан тип вызова (null)."
        Exit Sub
    End If
'    If vFirstItem <> "Gas" And vFirstItem <> "Petrol" And vFirstItem <> "Info" Then
'        MsgBox "Неизвестный тип вызова: '" & vFirstItem & "' ."
'        Exit Sub
'    End If
    vTotalRows = w_entry(vParam, 2, vDelimiter)
    If vTotalRows = null Then
        MsgBox "Не указано количество строк."
        Exit Sub
    End If
    If vFirstItem <> "Info" Then
        jTotalRows = CInt(vTotalRows) + 6
    Else
        jTotalRows = CInt(vTotalRows)
    End If
    On Error GoTo Err_Row
    If jTotalRows <= 0 Then
        GoTo Err_Row
    End If
    vTotalCols = w_entry(vParam, 3, vDelimiter)
    If vTotalCols = null Then
        MsgBox "Не указано количество столбцов."
        Exit Sub
    End If
    jTotalCols = CInt(vTotalCols)
    On Error GoTo Err_Col
    If jTotalCols <= 0 And vFirstItem = "Petrol" Then
        GoTo Err_Col
    End If
    If vFirstItem = "Petrol" Then
        jTotalCols = jTotalCols * 3 + 4
    End If
    vColList = w_entry(vParam, 4, vDelimiter)
    If vFirstItem = "Info" Then
        If vGreenRows = null Then
            MsgBox "Не указан список столбцов."
            Exit Sub
        End If
        w_LastItem = w_entry(vColList, jTotalCols, ",")
        If w_LastItem = null Then
            MsgBox "Ошибка в списке столбцов: " & jTotalCols & " '" & vColList & "' ."
            Exit Sub
        End If
    End If
    vGreenRows = w_entry(vParam, 5, vDelimiter)
    If vGreenRows = null Then
        MsgBox "Не указано количество строк итогов."
        Exit Sub
    End If
    jGreenRows = CInt(vGreenRows)
    On Error GoTo Err_Tot
    If jGreenRows <= 0 Then
        GoTo Err_Tot
    End If
    vGreenList = w_entry(vParam, 6, vDelimiter)
    If vGreenRows = null Then
        MsgBox "Не указаны строки итогов."
        Exit Sub
    End If
    vBookName = w_entry(vParam, 7, vDelimiter)
    If vBookName = null Then
        MsgBox "Не указана книга (null)."
        Exit Sub
    End If
    If vFirstItem = "Gas" Then
        Call Gas_Macros(jTotalRows, jTotalCols, jGreenRows, vGreenList, vBookName)
        On Error GoTo Err_Run
        Exit Sub
    ElseIf vFirstItem = "Petrol" Then
        Call Petrol_Macros(jTotalRows, jTotalCols, jGreenRows, vGreenList, vBookName)
        On Error GoTo Err_Run
        Exit Sub
    ElseIf vFirstItem = "Info" Then
        Call Info_Macros(jTotalRows, jTotalCols, vColList, jGreenRows, vGreenList, vBookName)
        On Error GoTo Err_Run
        Exit Sub
    Else
        MsgBox "Неизвестный тип вызова: " & vFirstItem & " ."
        Exit Sub
    End If
Err_Row:
    MsgBox "Неверно указано количество строк."
    Exit Sub
Err_Col:
    MsgBox "Неверно указано количество столбцов."
    Exit Sub
Err_Tot:
    MsgBox "Неверно указано количество строк итогов."
    Exit Sub
Err_Run:
    MsgBox "Ошибка выполнения макроса " & vFirstItem & "_Macros ."
    Exit Sub
End Sub

Sub Petrol_Macros(jTotalRows As Integer, MaxColNum As Integer, jGreenRows As Integer, vGreenList As String, vBook As String)
    Dim jCurrRow As Integer, jCount As Integer, jStart As Integer

    On Error GoTo Err_Handle
    With Workbooks(vBook).Worksheets(1)
        With .Range(.Cells(1, 1), .Cells(1, MaxColNum))
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            With .Font
                .Bold = True
                .Size = 14
                .ColorIndex = 3
            End With
        End With
        With .Range(.Cells(2, 1), .Cells(2, MaxColNum))
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            With .Font
                .Bold = True
                .Size = 14
                .ColorIndex = 3
            End With
        End With
        With .Range(.Cells(4, 1), .Cells(4, MaxColNum))
            .HorizontalAlignment = xlRight
            .VerticalAlignment = xlCenter
            .Font.Size = 10
        End With
        .Range(.Cells(5, 1), .Cells(6, MaxColNum)).Interior.ColorIndex = xlNone
        With .Range("A5:D6")
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            .WrapText = True
        End With
        With .Range("A5:A6")
            With .Interior
                .ColorIndex = 40
                .Pattern = xlSolid
            End With
        End With
        With .Range(.Cells(4, 1), .Cells(4, MaxColNum))
            .HorizontalAlignment = xlRight
            .VerticalAlignment = xlCenter
            .Font.Size = 10
        End With
        jStart = 7
        For jCount = 1 To jGreenRows
            jCurrRow = CInt(w_entry(vGreenList, jCount, ","))
            If jCount = jGreenRows Then
                With .Range(.Cells(jStart, 1), .Cells(jCurrRow, MaxColNum))
                    .Font.Bold = True
                    With .Interior
                        .ColorIndex = 34
                        .Pattern = xlSolid
                    End With
                    With .Borders(xlEdgeLeft)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                        .ColorIndex = xlAutomatic
                    End With
                    With .Borders(xlEdgeRight)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                        .ColorIndex = xlAutomatic
                    End With
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
                    With .Borders(xlInsideVertical)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                        .ColorIndex = xlAutomatic
                    End With
                    With .Borders(xlInsideHorizontal)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                        .ColorIndex = xlAutomatic
                    End With
                End With
            End If
            With .Range(.Cells(jCurrRow, 2), .Cells(jCurrRow, MaxColNum))
                .Font.Bold = True
                With .Interior
                    .ColorIndex = 4
                    .Pattern = xlSolid
                End With
                With .Borders(xlEdgeTop)
                    .LineStyle = xlContinuous
                    .Weight = xlThin
                End With
                With .Borders(xlEdgeBottom)
                    .LineStyle = xlContinuous
                    .Weight = xlThin
                End With
                With .Borders(xlEdgeLeft)
                    .LineStyle = xlContinuous
                    .Weight = xlThin
                End With
                With .Borders(xlEdgeRight)
                    .LineStyle = xlContinuous
                    .Weight = xlThin
                End With
                With .Borders(xlInsideVertical)
                    .LineStyle = xlContinuous
                    .Weight = xlThin
                End With
            End With
            With .Range(.Cells(jStart, 1), .Cells(jCurrRow, 1))
                .HorizontalAlignment = xlCenter
                .VerticalAlignment = xlCenter
                .WrapText = True
                .MergeCells = True
            End With
            jStart = jCurrRow + 1
        Next jCount
        jStart = 0
    End With
    With ActiveWindow
        .SplitColumn = 1
        .SplitRow = 6
        .FreezePanes = True
    End With
    Exit Sub
Err_Handle:
    MsgBox "Ошибка выполнения макроса Petrol_Macros: " & Err.Number & "  '" & Err.Description & "' . "
    Exit Sub
End Sub

Sub Gas_Macros(jTotalRows As Integer, MaxColNum As Integer, jGreenRows As Integer, vGreenList As String, vBook As String)
    Dim jCurrRow As Integer, jCount As Integer, jStart As Integer

    On Error GoTo Error_Handle
    MaxColNum = 8
    With Workbooks(vBook).Worksheets(1)
        With .Range(.Cells(1, 1), .Cells(1, MaxColNum))
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            With .Font
                .Bold = True
                .Size = 14
                .ColorIndex = 3
            End With
            .ShrinkToFit = True
        End With
        With .Range(.Cells(2, 1), .Cells(2, MaxColNum))
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            With .Font
                .Bold = True
                .Size = 14
                .ColorIndex = 3
            End With
        End With
        With .Range(.Cells(4, 1), .Cells(4, MaxColNum))
            .HorizontalAlignment = xlRight
            .VerticalAlignment = xlCenter
            .Font.Size = 10
        End With
        .Range(.Cells(5, 1), .Cells(6, MaxColNum)).Interior.ColorIndex = xlNone
        With .Range("A5:G6")
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            .WrapText = True
        End With
        With .Range("A5:C6")
            With .Interior
                .ColorIndex = 36
                .Pattern = xlSolid
            End With
        End With
        With .Range("E5:G6")
            With .Interior
                .ColorIndex = 34
                .Pattern = xlSolid
            End With
        End With
        With .Range(.Cells(4, 1), .Cells(4, MaxColNum))
            .HorizontalAlignment = xlRight
            .VerticalAlignment = xlCenter
            .Font.Size = 10
        End With
        jStart = 7
        For jCount = 1 To jGreenRows
            jCurrRow = CInt(w_entry(vGreenList, jCount, ","))
            If jCount = jGreenRows Then
                With .Range(.Cells(jStart, 1), .Cells(jCurrRow, MaxColNum))
                    .Font.Bold = True
                    With .Interior
                        .ColorIndex = 34
                        .Pattern = xlSolid
                    End With
                    With .Borders(xlEdgeLeft)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                        .ColorIndex = xlAutomatic
                    End With
                    With .Borders(xlEdgeRight)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                        .ColorIndex = xlAutomatic
                    End With
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
                    With .Borders(xlInsideVertical)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                        .ColorIndex = xlAutomatic
                    End With
                    With .Borders(xlInsideHorizontal)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                        .ColorIndex = xlAutomatic
                    End With
                End With
                With .Range(.Cells(jCurrRow, 2), .Cells(jCurrRow, MaxColNum))
                    .Font.Bold = True
                    With .Interior
                        .ColorIndex = 4
                        .Pattern = xlSolid
                    End With
                    With .Borders(xlEdgeTop)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                    End With
                    With .Borders(xlEdgeBottom)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                    End With
                    With .Borders(xlEdgeLeft)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                    End With
                    With .Borders(xlEdgeRight)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                    End With
                    With .Borders(xlInsideVertical)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                    End With
                End With
            Else
                With .Range(.Cells(jCurrRow, 2), .Cells(jCurrRow, MaxColNum))
                    .Font.Bold = True
                    With .Interior
                        .ColorIndex = 35
                        .Pattern = xlSolid
                    End With
                    With .Borders(xlEdgeTop)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                    End With
                    With .Borders(xlEdgeBottom)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                    End With
                    With .Borders(xlEdgeLeft)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                    End With
                    With .Borders(xlEdgeRight)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                    End With
                    With .Borders(xlInsideVertical)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                    End With
                End With
            End If
            With .Range(.Cells(jStart, 1), .Cells(jCurrRow, 1))
                .HorizontalAlignment = xlCenter
                .VerticalAlignment = xlCenter
                .WrapText = True
                .MergeCells = True
            End With
            jStart = jCurrRow + 1
        Next jCount
        jStart = jStart - 1
        With .Range(.Cells(5, 4), .Cells(jStart, 4))
            .Interior.ColorIndex = xlNone
            .Borders(xlDiagonalDown).LineStyle = xlNone
            .Borders(xlDiagonalUp).LineStyle = xlNone
            .Borders(xlEdgeTop).LineStyle = xlNone
            .Borders(xlEdgeBottom).LineStyle = xlNone
            .Borders(xlInsideVertical).LineStyle = xlNone
            .Borders(xlInsideHorizontal).LineStyle = xlNone
            With .Borders(xlEdgeLeft)
                .LineStyle = xlContinuous
                .Weight = xlThin
                .ColorIndex = xlAutomatic
            End With
            With .Borders(xlEdgeRight)
                .LineStyle = xlContinuous
                .Weight = xlThin
                .ColorIndex = xlAutomatic
            End With
        End With
        With .Range(.Cells(5, 8), .Cells(jStart, 8))
            .Interior.ColorIndex = xlNone
            .Interior.ColorIndex = xlNone
            .Borders(xlDiagonalDown).LineStyle = xlNone
            .Borders(xlDiagonalUp).LineStyle = xlNone
            .Borders(xlEdgeTop).LineStyle = xlNone
            .Borders(xlEdgeBottom).LineStyle = xlNone
            .Borders(xlEdgeRight).LineStyle = xlNone
            .Borders(xlInsideVertical).LineStyle = xlNone
            .Borders(xlInsideHorizontal).LineStyle = xlNone
            With .Borders(xlEdgeLeft)
                .LineStyle = xlContinuous
                .Weight = xlThin
                .ColorIndex = xlAutomatic
            End With
        End With
        jStart = 0
    End With
    With ActiveWindow
        .SplitColumn = 4
        .SplitRow = 6
        .FreezePanes = True
    End With
    Exit Sub
Error_Handle:
    MsgBox "Ошибка выполнения макроса Gas_Macros: " & Err.Number & "  '" & Err.Description & "' . "
    Exit Sub
End Sub

Sub Info_Macros(jGoods As Integer, jObjNum As Integer, vColList As String, jGreenRows As Integer, vGreenList As String, vBook As String)
    Dim MaxColNum As Integer, jCurrRow As Integer, jCount As Integer
    Dim jLastCol As Integer, jCurrCol As Integer, jCount1 As Integer

    On Error GoTo Err_Handling
    MaxColNum = CInt(w_entry(vColList, jObjNum, ","))
    With Workbooks(vBook).Worksheets(1)
        With .Range(.Cells(1, 1), .Cells(1, MaxColNum))
            .HorizontalAlignment = xlLeft
            .VerticalAlignment = xlCenter
            With .Font
                .Bold = True
                .Size = 14
            End With
            .ShrinkToFit = True
        End With
        With .Range(.Cells(2, 1), .Cells(2, MaxColNum))
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            With .Font
                .Bold = True
                .Size = 14
            End With
        End With
        .Range(.Cells(5, 1), .Cells(8, MaxColNum)).Interior.ColorIndex = xlNone
        With .Range("A5:A8")
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            .WrapText = True
        End With
        With .Range("B5:B8")
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            .WrapText = True
        End With
        jCurrCol = 3
        For jCount = 1 To jObjNum
            jLastCol = CInt(w_entry(vColList, jCount, ","))
            With .Range(.Cells(5, jCurrCol), .Cells(5, jLastCol))
                .HorizontalAlignment = xlCenter
                .VerticalAlignment = xlCenter
            End With
            With .Range(.Cells(6, jCurrCol), .Cells(6, jCurrCol))
                .HorizontalAlignment = xlCenter
                .VerticalAlignment = xlCenter
            End With
            With .Range(.Cells(6, jCurrCol + 1), .Cells(6, jLastCol))
                .HorizontalAlignment = xlCenter
                .VerticalAlignment = xlCenter
            End With
            With .Range(.Cells(7, jCurrCol + 1), .Cells(7, jCurrCol + 1))
                .HorizontalAlignment = xlCenter
                .VerticalAlignment = xlCenter
            End With
            With .Range(.Cells(7, jCurrCol + 2), .Cells(7, jLastCol))
                .HorizontalAlignment = xlCenter
                .VerticalAlignment = xlCenter
            End With
            jCurrCol = jCurrCol + 2
            For jCount1 = jCurrCol To jLastCol
                With .Range(.Cells(7, jCurrCol), .Cells(7, jCurrCol))
                    .HorizontalAlignment = xlCenter
                    .VerticalAlignment = xlCenter
                End With
            Next jCount1
            jCurrCol = jLastCol + 1
        Next jCount
        For jCount = 1 To jGreenRows
            jCurrRow = CInt(w_entry(vGreenList, jCount, ","))
            With .Range(.Cells(jCurrRow, 1), .Cells(jCurrRow + jGoods - 1, 1))
                .HorizontalAlignment = xlCenter
                .VerticalAlignment = xlCenter
                .WrapText = True
                .MergeCells = True
                .Font.Bold = True
            End With
            With .Range(.Cells(jCurrRow, 2), .Cells(jCurrRow + jGoods - 1, 2))
                .HorizontalAlignment = xlCenter
                .VerticalAlignment = xlCenter
                .Font.Bold = True
            End With
            With .Range(.Cells(jCurrRow + jGoods - 1, 1), .Cells(jCurrRow + jGoods - 1, MaxColNum))
                With .Borders(xlEdgeBottom)
                    .LineStyle = xlContinuous
                    .Weight = xlThin
                    .ColorIndex = xlAutomatic
                End With
            End With
            jCurrCol = 3
            For jCount1 = 1 To jObjNum
                jLastCol = CInt(w_entry(vColList, jCount1, ","))
                With .Range(.Cells(jCurrRow, jCurrCol), .Cells(jCurrRow + jGoods - 1, jLastCol))
                    With .Borders(xlEdgeLeft)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                        .ColorIndex = xlAutomatic
                    End With
                End With
                With .Range(.Cells(jCurrRow, jCurrCol), .Cells(jCurrRow + jGoods - 1, jLastCol))
                    With .Borders(xlEdgeRight)
                        .LineStyle = xlContinuous
                        .Weight = xlThin
                        .ColorIndex = xlAutomatic
                    End With
                End With
                jCurrCol = jLastCol + 1
            Next jCount1
        Next jCount
    End With
    Exit Sub
Err_Handling:
    MsgBox "Ошибка выполнения макроса Info_Macros: " & Err.Number & "  '" & Err.Description & "' . "
    Exit Sub
End Sub


