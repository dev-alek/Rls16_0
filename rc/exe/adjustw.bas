Sub Main_Macros(vParameters As String, vDelimiter As String)
Dim numlines, numtall as integer
    if ActiveWorkBook.Sheets(1).Name =  vParameters Then
    numlines = ActiveWorkBook.Sheets(vParameters).Cells.SpecialCells(xlCellTypeLastCell).Row 
    numtall = CInt( numlines / 47) 
    If numtall * 47 - numlines < 24 Then
      numtall = numtall + 1
    Endif
    ActiveWorkBook.Sheets(vParameters).PageSetup.PrintArea = ""
    With ActiveWorkBook.Sheets(vParameters).PageSetup
        .PrintTitleRows = ""
        .PrintTitleColumns = ""
        .Orientation = xlLandscape
        .Zoom = false
        .FitToPagesWide = 1
        .FitToPagesTall = numtall
    End With
    End if
End Sub
'

