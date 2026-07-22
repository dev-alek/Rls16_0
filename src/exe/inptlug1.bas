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
    Dim vFirstItem As String, vBookName As String
    Dim vTotalRows As String, vTotalCols As String
    Dim jTotalRows As Integer, jTotalCols As Integer

    vFirstItem = w_entry(vParam, 1, vDelimiter)
    If vFirstItem = null Then
        MsgBox "Не указан тип вызова (null)."
        Exit Sub
    End If
    If vFirstItem <> "Gas" And vFirstItem <> "Petrol" Then
        MsgBox "Неизвестный тип вызова: " & vFirstItem & " ."
        Exit Sub
    End If
    vTotalRows = w_entry(vParam, 2, vDelimiter)
    If vTotalRows = null Then
        MsgBox "Не указано количество строк."
        Exit Sub
    End If
    jTotalRows = CInt(vTotalRows) + 7
    On Error GoTo Err_Row
    If jTotalRows <= 0 Then
        GoTo Err_Row
    End If
    vTotalCols = w_entry(vParam, 3, vDelimiter)
    If vTotalCols = null Then
        MsgBox "Не указано количество столбцов."
        Exit Sub
    End If
    jTotalCols = CInt(vTotalCols) * 3 + 6
    On Error GoTo Err_Col
    If jTotalCols <= 0 And vFirstItem = "Petrol" Then
        GoTo Err_Col
    End If
    vBookName = w_entry(vParam, 4, vDelimiter)
    If vBookName = null Then
        MsgBox "Не указана книга (null)."
        Exit Sub
    End If
    If vFirstItem = "Gas" Then
        Call Gas_Macros(jTotalRows, vBookName)
        On Error GoTo Err_Call
        Exit Sub
    Else
        Call Petrol_Macros(jTotalRows, jTotalCols, vBookName)
        On Error GoTo Err_Call
        Exit Sub
    End If
Err_Row:
    MsgBox "Неверно указано количество строк."
    Exit Sub
Err_Col:
    MsgBox "Неверно указано количество столбцов."
    Exit Sub
Err_Call:
    MsgBox "Ошибка выполнения макроса " & vFirstItem & "_Macros ."
    Exit Sub
End Sub

Sub Gas_Macros(jTotalRows As Integer, vBook As String)
    With Workbooks(vBook).Worksheets(1)
        With .Range("A1:F1")
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            With .Font
                .Bold = True
                .Size = 14
                .ColorIndex = 3
            End With
        End With
        With .Range("A4:F4").Font
            .Bold = True
            .Size = 12
        End With
        .Range("A5:F6").Interior.ColorIndex = xlNone
        With .Range("A5:C6")
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            .WrapText = True
        End With
        With .Range(.Cells(jTotalRows, 1), .Cells(jTotalRows, 6))
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
        End With
    End With
End Sub

Sub Petrol_Macros(jTotalRows As Integer, MaxColNum As Integer, vBook As String)
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
        With .Range(.Cells(3, 1), .Cells(3, MaxColNum))
            .HorizontalAlignment = xlRight
            .VerticalAlignment = xlCenter
            With .Font
                .Italic = True
                .Size = 10
            End With
        End With
        With .Range(.Cells(4, 1), .Cells(4, MaxColNum)).Font
            .Bold = True
            .Size = 12
        End With
        .Range(.Cells(5, 1), .Cells(6, MaxColNum)).Interior.ColorIndex = xlNone
        With .Range("A5:C6")
            .HorizontalAlignment = xlCenter
            .VerticalAlignment = xlCenter
            .WrapText = True
        End With
        With .Range(.Cells(jTotalRows, 1), .Cells(jTotalRows, MaxColNum))
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
        End With
    End With
End Sub


