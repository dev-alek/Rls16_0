Sub Main_Macros(vParam As String, vDelimiter As String)
Dim vTotalRows As String
Dim jTotalRows As Integer
Dim ii, iEndRow As Integer
Dim sRowNum As String

Dim i As Integer
'vParam As String, vDelimiter As String
'ƒобавл€ем строку 1-2-3-4-5
    Rows("7:7").Select
    Selection.Insert Shift:=xlDown
    Range("A7").Select
    ActiveCell.FormulaR1C1 = "1"
    With ActiveCell.Characters(Start:=1, Length:=1).Font
        .Name = "Arial Cyr"
        .FontStyle = "полужирный"
        .Size = 10
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .ColorIndex = xlAutomatic
    End With
    Range("B7").Select
    ActiveCell.FormulaR1C1 = "2"
    With ActiveCell.Characters(Start:=1, Length:=1).Font
        .Name = "Arial Cyr"
        .FontStyle = "полужирный"
        .Size = 10
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .ColorIndex = xlAutomatic
    End With
    Range("C7").Select
    ActiveCell.FormulaR1C1 = "3"
    With ActiveCell.Characters(Start:=1, Length:=1).Font
        .Name = "Arial Cyr"
        .FontStyle = "полужирный"
        .Size = 10
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .ColorIndex = xlAutomatic
    End With
    Range("D7").Select
    ActiveCell.FormulaR1C1 = "4"
    With ActiveCell.Characters(Start:=1, Length:=1).Font
        .Name = "Arial Cyr"
        .FontStyle = "полужирный"
        .Size = 10
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .ColorIndex = xlAutomatic
    End With
    Range("E7").Select
    ActiveCell.FormulaR1C1 = "5"
    With ActiveCell.Characters(Start:=1, Length:=1).Font
        .Name = "Arial Cyr"
        .FontStyle = "полужирный"
        .Size = 10
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .ColorIndex = xlAutomatic
    End With
    Range("F7").Select
    ActiveCell.FormulaR1C1 = "6"
    With ActiveCell.Characters(Start:=1, Length:=1).Font
        .Name = "Arial Cyr"
        .FontStyle = "полужирный"
        .Size = 10
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .ColorIndex = xlAutomatic
    End With
    Range("G7").Select
    ActiveCell.FormulaR1C1 = "7"
    With ActiveCell.Characters(Start:=1, Length:=1).Font
        .Name = "Arial Cyr"
        .FontStyle = "полужирный"
        .Size = 10
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .ColorIndex = xlAutomatic
    End With
    Range("H7").Select
    ActiveCell.FormulaR1C1 = "8"
    With ActiveCell.Characters(Start:=1, Length:=1).Font
        .Name = "Arial Cyr"
        .FontStyle = "полужирный"
        .Size = 10
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .ColorIndex = xlAutomatic
    End With

    Range("A5:H7").Select
    Selection.Interior.ColorIndex = xlNone

'–исуем границы дл€ строки таблицы
    Range(Cells(5, 1), Cells(8, 8)).Select
    Selection.HorizontalAlignment = xlCenter
    Selection.Borders(xlDiagonalDown).LineStyle = xlNone
    Selection.Borders(xlDiagonalUp).LineStyle = xlNone
    With Selection.Borders(xlEdgeLeft)
        .LineStyle = xlContinuous
        .Weight = xlThin
        .ColorIndex = xlAutomatic
    End With
    With Selection.Borders(xlEdgeTop)
        .LineStyle = xlContinuous
        .Weight = xlThin
        .ColorIndex = xlAutomatic
    End With
    With Selection.Borders(xlEdgeBottom)
        .LineStyle = xlContinuous
        .Weight = xlThin
        .ColorIndex = xlAutomatic
    End With
    With Selection.Borders(xlEdgeRight)
        .LineStyle = xlContinuous
        .Weight = xlThin
        .ColorIndex = xlAutomatic
    End With
    With Selection.Borders(xlInsideVertical)
        .LineStyle = xlContinuous
        .Weight = xlThin
        .ColorIndex = xlAutomatic
    End With
    With Selection.Borders(xlInsideHorizontal)
        .LineStyle = xlContinuous
        .Weight = xlThin
        .ColorIndex = xlAutomatic
    End With

    Range("C10").Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range("C13").Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range("C16").Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range("C19").Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range("C22").Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range("C25").Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range("B28").Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range("B30").Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range("B32").Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range("B34").Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range("B36").Select
    Selection.Font.Underline = xlUnderlineStyleSingle

    Range("F28").Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range("F30").Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range("F32").Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range("F34").Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range("F36").Select
    Selection.Font.Underline = xlUnderlineStyleSingle

    Range(Cells(22, 1), Cells(22, 8)).Select
    Selection.Font.Bold = False


 ActiveSheet.PageSetup.PrintArea = ""
    With ActiveSheet.PageSetup
        .RightMargin = Application.InchesToPoints(0.2)
	.LeftMargin = Application.InchesToPoints(0.2)
        .TopMargin = Application.InchesToPoints(0.79)
        .BottomMargin = Application.InchesToPoints(0.44)
        .Orientation = xlLandscape
   End With


iEndRow = ActiveSheet.Cells.SpecialCells(xlCellTypeLastCell).Row
'≈сли находим строку "Ќовый лист", то копируем шапку и вставл€ем после найденной строки
  For ii = 2 To ( iEndRow + iEndRow )
    sRowNum = "A" + Trim(Str(ii))
    If Trim(Range(sRowNum).Value) = "Ќовый лист" Then

    Range(Cells(ii, 1), Cells(ii, 8)).Select
    Selection.Delete Shift:=xlToLeft

    Rows("4:7").Select
    Selection.Copy
    Range(Cells(ii + 1, 1), Cells(ii + 1, 8)).Select
    Selection.Insert Shift:=xlDown

    Range(Cells(ii + 2, 1), Cells(ii + 5, 8)).Select
    Selection.HorizontalAlignment = xlCenter
    Selection.Borders(xlDiagonalDown).LineStyle = xlNone
    Selection.Borders(xlDiagonalUp).LineStyle = xlNone
    With Selection.Borders(xlEdgeLeft)
        .LineStyle = xlContinuous
        .Weight = xlThin
        .ColorIndex = xlAutomatic
    End With
    With Selection.Borders(xlEdgeTop)
        .LineStyle = xlContinuous
        .Weight = xlThin
        .ColorIndex = xlAutomatic
    End With
    With Selection.Borders(xlEdgeBottom)
        .LineStyle = xlContinuous
        .Weight = xlThin
        .ColorIndex = xlAutomatic
    End With
    With Selection.Borders(xlEdgeRight)
        .LineStyle = xlContinuous
        .Weight = xlThin
        .ColorIndex = xlAutomatic
    End With
    With Selection.Borders(xlInsideVertical)
        .LineStyle = xlContinuous
        .Weight = xlThin
        .ColorIndex = xlAutomatic
    End With
    With Selection.Borders(xlInsideHorizontal)
        .LineStyle = xlContinuous
        .Weight = xlThin
        .ColorIndex = xlAutomatic
    End With

    Range(Cells(ii + 10, 1), Cells(ii + 20, 8)).Select
    Selection.Font.Bold = False

    Range(Cells(ii + 7, 3), Cells(ii + 7, 3)).Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range(Cells(ii + 10, 3), Cells(ii + 10, 3)).Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range(Cells(ii + 13, 3), Cells(ii + 13, 3)).Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range(Cells(ii + 16, 3), Cells(ii + 16, 3)).Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range(Cells(ii + 19, 3), Cells(ii + 19, 3)).Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range(Cells(ii + 22, 3), Cells(ii + 22, 3)).Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range(Cells(ii + 25, 2), Cells(ii + 25, 2)).Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range(Cells(ii + 25, 6), Cells(ii + 25, 6)).Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range(Cells(ii + 27, 2), Cells(ii + 27, 6)).Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range(Cells(ii + 29, 2), Cells(ii + 29, 6)).Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range(Cells(ii + 31, 2), Cells(ii + 31, 6)).Select
    Selection.Font.Underline = xlUnderlineStyleSingle
    Range(Cells(ii + 33, 2), Cells(ii + 33, 6)).Select
    Selection.Font.Underline = xlUnderlineStyleSingle
      ii = ii + 3
      End If
  Next ii

end sub
