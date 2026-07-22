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

Dim vPricename , vDostavka , vTel1 , vTel2  , vInfo , vLogo1 , vLogo2 , vOrderinfo , vAction  as String
Dim vSkidki , vHot as String
Dim vSkidki2 , vSkidki3 , vSkidki4 , vSkidki5 , vSkidki6 , vSkidki7 , vSkidki8 as String
Dim Header_Rows, kol_obj , vColsize As Integer
Dim kol_objv, Header_rowsv As Variant
Dim ii, iEndRow , itable As Integer
Dim sRowNum, sRowNumfn, picname, sCollNum1, sCollNum2 As String
Dim ObjectRange, FirstRange As Range
' ii текущая строка

' вытащить параметры из длинной строки
  vPricename  = w_entry(vParameters, 1, vDelimiter )
  vDostavka   = w_entry(vParameters, 2, vDelimiter )
  vTel1       = w_entry(vParameters, 3, vDelimiter )
  vTel2       = w_entry(vParameters, 4, vDelimiter )
  vInfo       = w_entry(vParameters, 5, vDelimiter )
  vOrderinfo  = w_entry(vParameters, 6, vDelimiter )
  vAction     = w_entry(vParameters, 7, vDelimiter )
  vSkidki     = w_entry(vParameters, 8, vDelimiter )
  vSkidki2     = w_entry(vParameters, 9, vDelimiter )
  vSkidki3     = w_entry(vParameters, 10, vDelimiter )
  vSkidki4     = w_entry(vParameters, 11, vDelimiter )
  vSkidki5     = w_entry(vParameters, 12, vDelimiter )
  vSkidki6     = w_entry(vParameters, 13, vDelimiter )
  vSkidki7     = w_entry(vParameters, 14, vDelimiter )
  vSkidki8     = w_entry(vParameters, 15, vDelimiter )
  vColsize    =  cint (w_entry(vParameters, 16, vDelimiter ))
  vHot        = w_entry(vParameters, 17, vDelimiter )
  vLogo1      = w_entry(vParameters, 18, vDelimiter )
  vLogo2      = w_entry(vParameters, 19, vDelimiter )


' Удаление стандартной шапки
    Range("A1:H4").Select
    With Selection
        .HorizontalAlignment = xlGeneral
        .VerticalAlignment = xlTop
        .WrapText = False
        .Orientation = 0
        .AddIndent = False
        .IndentLevel = 0
        .ShrinkToFit = False
        .ReadingOrder = xlContext
        .MergeCells = False
    End With

    Range("A1").Select
    Selection.EntireRow.Insert , CopyOrigin:=xlFormatFromLeftOrAbove
    Selection.EntireRow.Insert , CopyOrigin:=xlFormatFromLeftOrAbove
    Selection.EntireRow.Insert , CopyOrigin:=xlFormatFromLeftOrAbove
    Selection.EntireRow.Insert , CopyOrigin:=xlFormatFromLeftOrAbove
    Selection.EntireRow.Insert , CopyOrigin:=xlFormatFromLeftOrAbove
    Selection.EntireRow.Insert , CopyOrigin:=xlFormatFromLeftOrAbove
    Selection.EntireRow.Insert , CopyOrigin:=xlFormatFromLeftOrAbove
    Selection.EntireRow.Insert , CopyOrigin:=xlFormatFromLeftOrAbove
    Selection.EntireRow.Insert , CopyOrigin:=xlFormatFromLeftOrAbove
    Selection.EntireRow.Insert , CopyOrigin:=xlFormatFromLeftOrAbove
    Selection.EntireRow.Insert , CopyOrigin:=xlFormatFromLeftOrAbove
    Selection.EntireRow.Insert , CopyOrigin:=xlFormatFromLeftOrAbove
    Selection.EntireRow.Insert , CopyOrigin:=xlFormatFromLeftOrAbove
    Selection.EntireRow.Insert , CopyOrigin:=xlFormatFromLeftOrAbove

    Range("A1").Select
    ActiveCell.FormulaR1C1 = "ГРУППА КОМПАНИЙ ""БИЗНЕС - БУКЕТ"""
    With Selection.Font
        .Name = "Times New Roman"
        .Bold = True
        .Size = 11
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .Color = 5287936
    End With




    Range("A2").Select
    ActiveCell.FormulaR1C1 = "ПРАЙС ЛИСТ " + vPriceName
    Range("A2").Select
    With Selection.Font
        .Name = "Times New Roman"
        .Bold = True
        .Size = 11
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .Color = 255
    End With
    Rows("2:2").RowHeight = 22
    Rows("3:3").RowHeight = 22


    Range("A3").Select
    ActiveCell.FormulaR1C1 = "Ожидаемая дата поставки " + vDostavka

    Range("A4").Select
    ActiveCell.FormulaR1C1 = vOrderinfo
    Range("A4:E4").Select
    With Selection
        .HorizontalAlignment = xlJustify
        .VerticalAlignment = xlTop
        .WrapText = False
        .MergeCells = True
    End With
    With Selection.Font
        .Name = "Times New Roman"
        .Size = 11
        .Italic = True
    End With
    Rows("4:4").RowHeight = 45


    Range("A5").Select
    ActiveCell.FormulaR1C1 = "Оптовая цена действует при покупке " + vAction
    With Selection.Font
        .Name = "Times New Roman"
        .Size = 11
        .Bold = True
    End With


    Range("A3:A5").Select
    With Selection.Font
        .Name = "Times New Roman"
        .Size = 11
        .Bold = True
    End With

    Range("F8").Select
    ActiveCell.FormulaR1C1 = vTel1
    Range("F9").Select
    ActiveCell.FormulaR1C1 = vTel2
    Range("F8:F9").Select
    With Selection.Font
        .Name = "Times New Roman"
        .Size = 11
        .Bold = True
    End With


    Range("A7").Select
    ActiveCell.FormulaR1C1 = vSkidki
    Range("A8").Select
    ActiveCell.FormulaR1C1 = vSkidki2
    Range("A9").Select
    ActiveCell.FormulaR1C1 = vSkidki3
    Range("A10").Select
    ActiveCell.FormulaR1C1 = vSkidki4
    Range("A11").Select
    ActiveCell.FormulaR1C1 = vSkidki5
    Range("A12").Select
    ActiveCell.FormulaR1C1 = vSkidki6
    Range("A13").Select
    ActiveCell.FormulaR1C1 = vSkidki7
    Range("A14").Select
    ActiveCell.FormulaR1C1 = vSkidki8
    Range("A7:A14").Select
    With Selection.Font
        .Name = "Times New Roman"
        .Bold = True
        .Size = 10
        .Color = 12611584
    End With


    Range("A16").Select
    ActiveCell.FormulaR1C1 = vHot
    With Selection.Font
        .Name = "Times New Roman"
        .Bold = True
        .Size = 12
    End With


    Range("F16:G16").Select
    With Selection
        .HorizontalAlignment = xlRight
        .VerticalAlignment = xlTop
        .WrapText = False
        .MergeCells = True
        .RowHeight = 22
    End With
    With Selection.Font
        .Name = "Arial"
        .Bold = True
        .Italic = True
        .Size = 11
        .Color = 12611584
    End With
    ActiveCell.FormulaR1C1 = "www.bbcom.ru"


    Range("A17").Select
    ActiveCell.FormulaR1C1 = vInfo
    Range("A17").Select
    Range("A17:G17").Select
    Selection.RowHeight = 33
    Range("A17:G17").Select
    With Selection
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlJustify
        .WrapText = True
        .Orientation = 0
        .AddIndent = False
        .IndentLevel = 0
        .ShrinkToFit = False
        .ReadingOrder = xlContext
        .MergeCells = True
    End With
    With Selection.Font
        .Name = "Times New Roman"
        .Bold = True
        .Size = 11
        .Strikethrough = False
        .Superscript = False
        .Subscript = False
        .OutlineFont = False
        .Shadow = False
        .Underline = xlUnderlineStyleNone
        .Color = 0
    End With

' вставим два логотипа
        With ActiveSheet.Pictures.Insert(vLogo1)
            .Left = Range("G1").Left
            .Top  = Range("G1").Top
        End With

        With ActiveSheet.Pictures.Insert(vLogo2)
            .Left = Range("C7").Left
            .Top  = Range("C7").Top
        End With


' Последняя ячейка
  iEndRow = ActiveSheet.Cells.SpecialCells(xlCellTypeLastCell).Row
' Первоя строка таблицы
  itable = 20.
  For ii = itable To iEndRow
'     узнать имя картинки
      sRowNumfn = "F" + Trim(Str(ii))
      picname = Trim(Range(sRowNumfn).Value)

'     вставить картинку если не пусто
     if vColsize = 0 then
        vColsize = 50
     End if

      If picname <> "" Then
        With ActiveSheet.Pictures.Insert(Range(sRowNumfn).Value)
            .ShapeRange.Height = vColsize
            .Left = Range(sRowNumfn).Left
            .Top = Range(sRowNumfn).Top
        End With
        Rows(Str(ii)).RowHeight = vColsize
'       Cells(ii, 9).Value = picname
        Cells(ii, 6).Value = ""
       End If
      sRowNum = "A" + Trim(Str(ii))

'   выровнять текстовую часть отчета по значению и верхнему краю
    sCollNum1 = "A" + Trim(Str(ii))
    sCollNum2 = "A" + Trim(Str(ii))
    Range(sCollNum1 , sCollNum2).Select
    With Selection
        .NumberFormat = "0"
        .HorizontalAlignment = xlJustify
        .VerticalAlignment   = xlTop
    End With


    sCollNum1 = "B" + Trim(Str(ii))
    sCollNum2 = "E" + Trim(Str(ii))
    Range(sCollNum1 , sCollNum2).Select
    With Selection
        .HorizontalAlignment = xlJustify
        .VerticalAlignment   = xlTop
        .WrapText            = False
        .Orientation         = 0
        .AddIndent           = False
        .IndentLevel         = 0
        .ShrinkToFit         = False
        .ReadingOrder        = xlContext
        .MergeCells          = False
    End With
   Next ii

    Range(Cells(itable, 4), Cells(iEndRow, 4)).Select
    Selection.NumberFormat = "0.00"
    With Selection
        .HorizontalAlignment = xlRight
        .VerticalAlignment = xlTop
        .WrapText = False
        .Orientation = 0
        .AddIndent = False
        .IndentLevel = 0
        .ShrinkToFit = False
        .ReadingOrder = xlContext
        .MergeCells = False
    End With

    Range(Cells(itable, 5), Cells(iEndRow, 5)).Select
    With Selection
        .HorizontalAlignment = xlRight
        .VerticalAlignment = xlTop
        .WrapText = False
        .Orientation = 0
        .AddIndent = False
        .IndentLevel = 0
        .ShrinkToFit = False
        .ReadingOrder = xlContext
        .MergeCells = False
    End With


'    Выделить все границы
    Set ObjectRange = Range(Cells(itable, 1), Cells(iEndRow, 7))
    ObjectRange.Borders(xlDiagonalDown).LineStyle = xlNone
    ObjectRange.Borders(xlDiagonalUp).LineStyle = xlNone
    With ObjectRange.Borders(xlEdgeLeft)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .Weight = xlThin
    End With
    With ObjectRange.Borders(xlEdgeTop)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .Weight = xlThin
    End With
    With ObjectRange.Borders(xlEdgeBottom)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .Weight = xlThin
    End With
    With ObjectRange.Borders(xlEdgeRight)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .Weight = xlThin
    End With
    With ObjectRange.Borders(xlInsideVertical)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .Weight = xlThin
    End With
    With ObjectRange.Borders(xlInsideHorizontal)
        .LineStyle = xlContinuous
        .ColorIndex = 0
        .Weight = xlThin
    End With


    'With ObjectRange.Selection
    '    .HorizontalAlignment = xlGeneral
    '    .VerticalAlignment = xlJustify
    '    .Orientation = 0
    '    .AddIndent = False
    '    .IndentLevel = 0
    '    .ShrinkToFit = False
    '    .ReadingOrder = xlContext
    '    .MergeCells = False
    '  End With


    With ActiveSheet.PageSetup
        .PrintTitleRows = ""
        .PrintTitleColumns = ""
    End With
    ActiveSheet.PageSetup.PrintArea = ""
    With ActiveSheet.PageSetup
        .LeftHeader = ""
        .CenterHeader = ""
        .RightHeader = ""
        .LeftFooter = ""
        .CenterFooter = ""
        .RightFooter = ""
        .LeftMargin = Application.InchesToPoints(0.75)
        .RightMargin = Application.InchesToPoints(0.75)
        .TopMargin = Application.InchesToPoints(1)
        .BottomMargin = Application.InchesToPoints(1)
        .HeaderMargin = Application.InchesToPoints(0.5)
        .FooterMargin = Application.InchesToPoints(0.5)
        .PrintHeadings = False
        .PrintGridlines = False
        .PrintComments = xlPrintNoComments
'        .PrintQuality = 600
        .CenterHorizontally = False
        .CenterVertically = False
        .Orientation = xlPortrait
        .Draft = False
        .PaperSize = xlPaperA4
        .FirstPageNumber = xlAutomatic
        .Order = xlDownThenOver
        .BlackAndWhite = False
        .Zoom = 100
        .PrintErrors = xlPrintErrorsDisplayed
        .OddAndEvenPagesHeaderFooter = False
        .DifferentFirstPageHeaderFooter = False
        .ScaleWithDocHeaderFooter = True
        .AlignMarginsHeaderFooter = True
        .EvenPage.LeftHeader.Text = ""
        .EvenPage.CenterHeader.Text = ""
        .EvenPage.RightHeader.Text = ""
        .EvenPage.LeftFooter.Text = ""
        .EvenPage.CenterFooter.Text = ""
        .EvenPage.RightFooter.Text = ""
        .FirstPage.LeftHeader.Text = ""
        .FirstPage.CenterHeader.Text = ""
        .FirstPage.RightHeader.Text = ""
        .FirstPage.LeftFooter.Text = ""
        .FirstPage.CenterFooter.Text = ""
        .FirstPage.RightFooter.Text = ""
    End With
    With ActiveSheet.PageSetup
        .PrintTitleRows = ""
        .PrintTitleColumns = ""
    End With
    ActiveSheet.PageSetup.PrintArea = ""
    With ActiveSheet.PageSetup
        .LeftHeader = ""
        .CenterHeader = ""
        .RightHeader = ""
        .LeftFooter = ""
        .CenterFooter = ""
        .RightFooter = ""
        .LeftMargin = Application.InchesToPoints(0.236220472440945)
        .RightMargin = Application.InchesToPoints(0.236220472440945)
        .TopMargin = Application.InchesToPoints(0.748031496062992)
        .BottomMargin = Application.InchesToPoints(0.748031496062992)
        .HeaderMargin = Application.InchesToPoints(0.31496062992126)
        .FooterMargin = Application.InchesToPoints(0.31496062992126)
        .PrintHeadings = False
        .PrintGridlines = False
        .PrintComments = xlPrintNoComments
'        .PrintQuality = 600
        .CenterHorizontally = False
        .CenterVertically = False
        .Orientation = xlPortrait
        .Draft = False
        .PaperSize = xlPaperA4
        .FirstPageNumber = xlAutomatic
        .Order = xlDownThenOver
        .BlackAndWhite = False
        .Zoom = 100
        .PrintErrors = xlPrintErrorsDisplayed
        .OddAndEvenPagesHeaderFooter = False
        .DifferentFirstPageHeaderFooter = False
        .ScaleWithDocHeaderFooter = True
        .AlignMarginsHeaderFooter = True
        .EvenPage.LeftHeader.Text = ""
        .EvenPage.CenterHeader.Text = ""
        .EvenPage.RightHeader.Text = ""
        .EvenPage.LeftFooter.Text = ""
        .EvenPage.CenterFooter.Text = ""
        .EvenPage.RightFooter.Text = ""
        .FirstPage.LeftHeader.Text = ""
        .FirstPage.CenterHeader.Text = ""
        .FirstPage.RightHeader.Text = ""
        .FirstPage.LeftFooter.Text = ""
        .FirstPage.CenterFooter.Text = ""
        .FirstPage.RightFooter.Text = ""
    End With

	
End Sub



