Attribute VB_Name = "Модуль11"
Option Explicit

Dim g_iSheetHeight As Double
Dim g_dPageHeight As Double

Dim g_dHeaderHeight As Double
Dim g_dPageHeaderHeight As Double
Dim g_dDataAloneHeight As Double
Dim g_dDataFirstHeight As Double
Dim g_dDataHeight As Double
Dim g_dDataLastHeight As Double
Dim g_dPageSubTotalHeight As Double
Dim g_dPageSubTotalLastHeight As Double
Dim g_dPageTotalHeight As Double
Dim g_dFooterHeight As Double

Dim g_sRegularExpressions As Integer
Dim g_sValutCode As String
Dim g_sColumnList As String
Dim g_sColumnType As String
Dim g_iColumnAmount As Integer
Dim g_sSubtotalList As String
Dim g_sSubtotalType As String
Dim g_iSubtotalAmount As Integer
Dim g_sSubtotalPropisList As String
Dim g_iSubtotalPropisAmount As Integer

Dim g_dCurrentPageDataHeight  As Double


Sub startFormFromTemplate( _
      sHeaderFileName As String _
    , sDataFileName As String _
)
Dim sBuffer As String
Dim iCounter As Integer
Dim NewSheet As Object
Dim templateExist As Boolean
Dim lastRow As Long
Dim iStartColumn As Integer
Dim bNeedNewSheet As Boolean
Dim iSheetNumber As Integer
Dim bPrintHeader As Boolean
Dim bLabelExists As Boolean
Dim sNoTempLabelList As String
'
' Макрос1 Макрос
' Макрос записан 01.12.2004 (VGuntner)
'
On Error GoTo errStartFromTemplate
    '
    '    Workbooks.Add Template:= _
            "C:\Program Files\Microsoft Office\Шаблоны\t12_97.xlt"
    'ActiveWorkbook.Worksheets("Template").Copy After:=ActiveWorkbook.Worksheets("Template")
    'ActiveWorkbook.Worksheets(ActiveWorkbook.Worksheets.Count).Name = "1"

    'MsgBox ActiveWorkbook.Sheets("Template").HPageBreaks.Count

    Application.Interactive = False
    Application.DisplayAlerts = False
    Application.ScreenUpdating = False

    templateExist = False
    For Each NewSheet In ActiveWorkbook.Worksheets
         Select Case NewSheet.Name
            Case "Template"
                templateExist = True
            Case Else
                NewSheet.Delete
        End Select
    Next NewSheet
    If templateExist = False Then
        MsgBox "Не определен шаблон для печати формы"
        Exit Sub
    End If
    Call CheckLabel( _
          ByVal "header" _
        , bLabelExists _
    )
    If bLabelExists = False Then
        MsgBox "В шаблоне нет метки 'header'. Шаблон использовать невозможно."
        Exit Sub
    End If
    Call checkAllTempLabels( _
          bLabelExists _
        , sNoTempLabelList _
    )
    If bLabelExists = False Then
        MsgBox "В шаблоне нет служебных меток: " & sNoTempLabelList & ". Шаблон использовать невозможно."
        Exit Sub
    End If

    Call fillTemplateHeader(sHeaderFileName)

    bNeedNewSheet = True
    iSheetNumber = 1

    If sDataFileName = "" Then      ' В печатной форме нет табличной части
        bNeedNewSheet = False
        Set NewSheet = ActiveWorkbook.Worksheets.Add
        NewSheet.Name = Format(iSheetNumber)
        NewSheet.StandardWidth = ActiveWorkbook.Worksheets("Template").StandardWidth
        For iCounter = 1 To ActiveWorkbook.Sheets("Template").Range("header").SpecialCells(xlLastCell).Column
            NewSheet.Range("A1").Columns(iCounter).ColumnWidth = ActiveWorkbook.Sheets("Template").Range("header").Columns(iCounter).ColumnWidth
        Next iCounter
        With ActiveWorkbook.Worksheets("Template").PageSetup
            NewSheet.PageSetup.Zoom = .Zoom
            NewSheet.PageSetup.Orientation = .Orientation
            NewSheet.PageSetup.LeftHeader = .LeftHeader
            NewSheet.PageSetup.CenterHeader = .CenterHeader
            NewSheet.PageSetup.RightHeader = .RightHeader
            NewSheet.PageSetup.LeftFooter = .LeftFooter
            NewSheet.PageSetup.CenterFooter = .CenterFooter
            NewSheet.PageSetup.RightFooter = .RightFooter
            NewSheet.PageSetup.FirstPageNumber =  .FirstPageNumber
            NewSheet.PageSetup.LeftMargin = .LeftMargin
            NewSheet.PageSetup.RightMargin = .RightMargin
            NewSheet.PageSetup.TopMargin = .TopMargin
            NewSheet.PageSetup.BottomMargin = .BottomMargin
            NewSheet.PageSetup.HeaderMargin = .HeaderMargin
            NewSheet.PageSetup.FooterMargin = .FooterMargin
            NewSheet.PageSetup.PrintGridlines = .PrintGridlines
            NewSheet.PageSetup.PrintComments = .PrintComments
            NewSheet.PageSetup.PaperSize = .PaperSize
'            NewSheet.PageSetup.PrintQuality = .PrintQuality
        End With
        Call clearGlobalVariables
        bPrintHeader = True
        g_iSheetHeight = 30000
        g_dPageHeight = 0#
        For iCounter = 1 To g_iColumnAmount
            ActiveWorkbook.Sheets("Template").Range("tempSubTotals").Cells(1, iCounter).Value = 0#
        Next iCounter
        Call getPageHeight(NewSheet.Name, g_dPageHeight)
        Call getTemplateHeights( _
              "Template" _
            , g_dHeaderHeight _
            , g_dPageHeaderHeight _
            , g_dDataAloneHeight _
            , g_dDataFirstHeight _
            , g_dDataHeight _
            , g_dDataLastHeight _
            , g_dPageSubTotalHeight _
            , g_dPageSubTotalLastHeight _
            , g_dPageTotalHeight _
            , g_dFooterHeight _
        )
        Call copyTemplateRange( _
              ActiveWorkbook.Sheets("Template").Range("header") _
            , ActiveWorkbook.Sheets(NewSheet.Name).Range("A1") _
            , True _
        )
        lastRow = lastRow + ActiveWorkbook.Sheets("Template").Range("header").Rows.Count
        If g_dPageHeight > 0 _
        And g_dHeaderHeight + g_dPageHeaderHeight >= g_dPageHeight Then
            ActiveWorkbook.Sheets(NewSheet.Name).Rows(lastRow + 1).PageBreak = xlPageBreakManual
            g_dCurrentPageDataHeight = 0
        Else
            g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + g_dHeaderHeight
        End If
    Else        ' Обработка табличной части печатной формы
        Open sDataFileName For Input As #1

        While bNeedNewSheet = True
            bNeedNewSheet = False
            Set NewSheet = ActiveWorkbook.Worksheets.Add
            NewSheet.Name = Format(iSheetNumber)
            NewSheet.StandardWidth = ActiveWorkbook.Worksheets("Template").StandardWidth
            For iCounter = 1 To ActiveWorkbook.Sheets("Template").Range("header").SpecialCells(xlLastCell).Column
                NewSheet.Range("A1").Columns(iCounter).ColumnWidth = ActiveWorkbook.Sheets("Template").Range("header").Columns(iCounter).ColumnWidth
            Next iCounter
            With ActiveWorkbook.Worksheets("Template").PageSetup
                NewSheet.PageSetup.Zoom = .Zoom
                NewSheet.PageSetup.Orientation = .Orientation
                NewSheet.PageSetup.LeftHeader = .LeftHeader
                NewSheet.PageSetup.CenterHeader = .CenterHeader
                NewSheet.PageSetup.RightHeader = .RightHeader
                NewSheet.PageSetup.LeftFooter = .LeftFooter
                NewSheet.PageSetup.CenterFooter = .CenterFooter
                NewSheet.PageSetup.RightFooter = .RightFooter
                NewSheet.PageSetup.FirstPageNumber =  .FirstPageNumber
                NewSheet.PageSetup.LeftMargin = .LeftMargin
                NewSheet.PageSetup.RightMargin = .RightMargin
                NewSheet.PageSetup.TopMargin = .TopMargin
                NewSheet.PageSetup.BottomMargin = .BottomMargin
                NewSheet.PageSetup.HeaderMargin = .HeaderMargin
                NewSheet.PageSetup.FooterMargin = .FooterMargin
                NewSheet.PageSetup.PrintGridlines = .PrintGridlines
                NewSheet.PageSetup.PrintComments = .PrintComments
                NewSheet.PageSetup.PaperSize = .PaperSize
'                NewSheet.PageSetup.PrintQuality = .PrintQuality
            End With
            If iSheetNumber = 1 Then
                Call clearGlobalVariables
                bPrintHeader = True
                g_iSheetHeight = 30000
                g_dPageHeight = 0#
                For iCounter = 1 To g_iColumnAmount
                    ActiveWorkbook.Sheets("Template").Range("tempSubTotals").Cells(1, iCounter).Value = 0#
                Next iCounter
    'MsgBox "The name of the active printer is " & Application.ActivePrinter
                Call getPageHeight(NewSheet.Name, g_dPageHeight)
                Call getTemplateHeights( _
                      "Template" _
                    , g_dHeaderHeight _
                    , g_dPageHeaderHeight _
                    , g_dDataAloneHeight _
                    , g_dDataFirstHeight _
                    , g_dDataHeight _
                    , g_dDataLastHeight _
                    , g_dPageSubTotalHeight _
                    , g_dPageSubTotalLastHeight _
                    , g_dPageTotalHeight _
                    , g_dFooterHeight _
                )
            End If
            Call printSheet( _
                  NewSheet.Name _
                , bPrintHeader _
                , lastRow _
                , bNeedNewSheet _
            )
            iSheetNumber = iSheetNumber + 1
        Wend
        Close #1
    End If
    Call printTotalAndFooter( _
          NewSheet.Name _
        , lastRow _
    )
    ActiveWorkbook.Worksheets("Template").Delete
    If sHeaderFileName <> "" _
    And Dir(sHeaderFileName) <> "" _
    Then
        Kill sHeaderFileName
    End If
    If sDataFileName <> "" _
    And Dir(sDataFileName) <> "" _
    Then
        Kill sDataFileName
    End If
    Application.Interactive = True
    Exit Sub
errStartFromTemplate:
    MsgBox Err.Description & ". Ошибка основного модуля. Лист: " & _
    NewSheet.Name & ". Книга: " & ActiveWorkbook.Name
End Sub

Sub printTotalAndFooter( _
      p_sSheetName As String _
    , p_iLastRow As Long _
)
On Error GoTo errPrintTotalAndFooter

Dim dPageSubTotalLastHeightExist As Boolean
Dim bLabelExists As Boolean

    If g_dPageSubTotalLastHeight = 0 Then
        g_dPageSubTotalLastHeight = g_dPageSubTotalHeight
        dPageSubTotalLastHeightExist = False
    Else
        dPageSubTotalLastHeightExist = True
    End If

    If g_dCurrentPageDataHeight + g_dPageTotalHeight + g_dPageSubTotalLastHeight + g_dFooterHeight > g_dPageHeight Then
        If g_iColumnAmount <> 0 _
        Or g_iSubtotalAmount <> 0 _
        Or g_iSubtotalPropisAmount <> 0 _
        Then
            Call printPageSubTotal( _
                  p_sSheetName _
                , False _
                , p_iLastRow _
                , g_dCurrentPageDataHeight _
            )
            ActiveWorkbook.Sheets(p_sSheetName).Rows(p_iLastRow).PageBreak = xlPageBreakManual
            Call printPageHeader( _
                  p_sSheetName _
                , p_iLastRow _
                , g_dCurrentPageDataHeight _
            )
        End If
    Else
        Call printPageSubTotal( _
              p_sSheetName _
            , dPageSubTotalLastHeightExist _
            , p_iLastRow _
            , g_dCurrentPageDataHeight _
        )
    End If
    If g_dPageTotalHeight <> 0 Then
        Call copyTemplateRange(ActiveWorkbook.Sheets("Template").Range("total"), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
        p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets("Template").Range("total").Rows.Count
    End If
    Call CheckLabel( _
          ByVal "footer" _
        , bLabelExists _
    )
    If bLabelExists = True Then
        Call copyTemplateRange(ActiveWorkbook.Sheets("Template").Range("footer"), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
        p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets("Template").Range("footer").Rows.Count
    End If
    Exit Sub
errPrintTotalAndFooter:
    MsgBox Err.Description & ". Ошибка модуля печати подвала. Лист: " & _
    p_sSheetName & ". Строка: " & p_iLastRow
    Resume Next
End Sub

Sub printSheet( _
      ByVal p_sSheetName As String _
    , ByVal p_bPrintHeader As Boolean _
    , ByRef p_iLastRow As Long _
    , ByRef p_bNeedNewSheet As Boolean _
)
Dim bNeedNewPage As Boolean
Dim iDataRowsForFooter As Long
Dim iCounter As Integer

    bNeedNewPage = True
    p_iLastRow = 1
    iDataRowsForFooter = 1
    g_dCurrentPageDataHeight = 0
    If p_bPrintHeader = True Then
        Call copyTemplateRange( _
              ActiveWorkbook.Sheets("Template").Range("header") _
            , ActiveWorkbook.Sheets(p_sSheetName).Range("A1") _
            , True _
        )
        p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets("Template").Range("header").Rows.Count
        If g_dPageHeight > 0 _
        And g_dHeaderHeight + g_dPageHeaderHeight >= g_dPageHeight Then
            ActiveWorkbook.Sheets(p_sSheetName).Rows(p_iLastRow + 1).PageBreak = xlPageBreakManual
            g_dCurrentPageDataHeight = 0
        Else
            g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + g_dHeaderHeight
        End If
        p_bPrintHeader = False
    End If
    While bNeedNewPage = True
        Call printPageOfSheet( _
              p_sSheetName _
            , p_iLastRow _
            , bNeedNewPage _
            , p_bNeedNewSheet _
        )
        If p_bNeedNewSheet = True Or p_iLastRow > 30000 Then
             p_bNeedNewSheet = True
             Exit Sub
        End If
        If bNeedNewPage = True Then
            g_dCurrentPageDataHeight = 0
            For iCounter = 1 To g_iColumnAmount
                ActiveWorkbook.Sheets("Template").Range("tempSubTotals").Cells(1, iCounter).Value = 0#
            Next iCounter
        End If
    Wend
End Sub

Sub copyTemplateRange(copyFrom As Range, copyTo As Range, needColumns As Boolean)

Dim iCounter As Integer

    copyFrom.Copy copyTo

End Sub

Sub impString(lineCounter As Integer, nameList As String, valueList As String)
Attribute impString.VB_Description = "Макрос записан 02.12.2004 (VGuntner)"
Attribute impString.VB_ProcData.VB_Invoke_Func = " \n14"
'
' Макрос2 Макрос
' Макрос записан 02.12.2004 (VGuntner)
'
'
    ActiveWorkbook.ActiveSheet.Cells(lineCounter, 1).Value = nameList
    ActiveWorkbook.ActiveSheet.Cells(lineCounter, 2).Value = valueList

End Sub

Sub prints()

    Range("A58").Select
    ActiveWindow.SelectedSheets.HPageBreaks.Add Before:=ActiveCell

End Sub

Sub printPageOfSheet( _
      ByVal p_sSheetName As String _
    , ByRef p_iLastRow As Long _
    , ByRef p_bNeedNewPage As Boolean _
    , ByRef p_bNeedNewSheet As Boolean _
)
Dim iCounter As Integer
Dim iRowCounter As Integer
Dim bIsFirst As Boolean
Dim sLabel As String
Dim sValue As String
Dim dValue As Double
Dim sBuffer As String
Dim sPrefix As String
Dim dMaxDataHeight As Double

Dim nmName As Name

On Error GoTo ErrorHandler

    Call printPageHeader( _
          p_sSheetName _
        , p_iLastRow _
        , g_dCurrentPageDataHeight _
    )
With ActiveWorkbook.Worksheets("Template")
'    For Each nmName In ActiveWorkbook.Names
'        If nmName.name = sLabel And sValue <> "" Then
'            .Range(nmName.Value) = sValue
'        End If
'   Next nmName

    Rows("34:34").RowHeight = 73.5
    Rows("35:35").RowHeight = 15.75
    Rows("36:36").RowHeight = 36
    Rows("37:42").RowHeight = 25
    Range("E35:L42").Select
    With Selection
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Orientation = 0
        .AddIndent = False
        .IndentLevel = 0
        .ShrinkToFit = False
        .ReadingOrder = xlContext
    End With

    Range("A58").Select
    ActiveWindow.SelectedSheets.HPageBreaks.Add Before:=ActiveCell

    dMaxDataHeight = 0
    If dMaxDataHeight < g_dDataAloneHeight Then
        dMaxDataHeight = g_dDataAloneHeight
    End If
    If dMaxDataHeight < g_dDataFirstHeight Then
        dMaxDataHeight = g_dDataFirstHeight
    End If
    If dMaxDataHeight < g_dDataHeight Then
        dMaxDataHeight = g_dDataHeight
    End If
    If dMaxDataHeight < g_dDataLastHeight Then
        dMaxDataHeight = g_dDataLastHeight
    End If

    If g_dPageHeight > 0 _
    And g_dCurrentPageDataHeight + dMaxDataHeight > g_dPageHeight _
    Then
        p_bNeedNewPage = True
        Exit Sub
    End If
    bIsFirst = True
    p_bNeedNewPage = False
    iRowCounter = 0
        While Not EOF(1)
            iCounter = 0
            iRowCounter = iRowCounter + 1
            Line Input #1, sBuffer
            .Range(.Range("tempRow").Cells(1, 1), .Range("tempRow").Cells(1, 100)).Clear
            .Range("tempRow") = sBuffer
            .Range("tempRow").TextToColumns DataType:=xlDelimited, _
                ConsecutiveDelimiter:=False, Tab:=True, Comma:=False, Semicolon:=False, _
                Other:=False, Space:=False, _
                FieldInfo:=Array(Array(1, 2), Array(2, 2), Array(3, 2), Array(4, 2), Array(5, 2) _
                , Array(6, 2), Array(7, 2), Array(8, 2), Array(9, 2), Array(10, 2) _
                , Array(11, 2), Array(12, 2), Array(13, 2), Array(14, 2), Array(15, 2) _
                , Array(16, 2), Array(17, 2), Array(18, 2), Array(19, 2), Array(20, 2) _
                , Array(21, 2), Array(22, 2), Array(23, 2), Array(24, 2), Array(25, 2) _
                , Array(26, 2), Array(27, 2), Array(28, 2), Array(29, 2), Array(30, 2) _
                , Array(31, 2), Array(32, 2), Array(33, 2), Array(34, 2), Array(35, 2))
            If bIsFirst = True Then
                If EOF(1) Then
                    sPrefix = "da_"
                Else
                    sPrefix = "df_"
                End If
                bIsFirst = False
            Else
                If EOF(1) Then
                    sPrefix = "dl_"
                Else
                    sPrefix = "d_"
                End If
            End If
            For iCounter = 1 To g_iColumnAmount
                sValue = CStr(.Range("tempRow").Cells(1, iCounter + 1).Value)
                If sValue = "" Then
                    .Range(sPrefix & Format(.Range("columnList").Cells(1, iCounter))).Value = ""
                Else
                    If .Range("columnType").Cells(1, iCounter).Value = "D" _
                    Or .Range("columnType").Cells(1, iCounter).Value = "C" _
                    Then
                        If sValue = "?" Then
                            .Range(sPrefix & Format(.Range("columnList").Cells(1, iCounter))).Value = "?"
                            .Range("tempSubTotals").Cells(1, iCounter).Value = "?"
                        Else
                            Call getDecimalFromString(sValue, dValue)
                            .Range(sPrefix & Format(.Range("columnList").Cells(1, iCounter))).Value = dValue
                            If (Not IsNull(.Range("subtotalMark").Cells(1, iCounter).Value) _
                                 And .Range("subtotalMark").Cells(1, iCounter).Value <> "") _
                            Or .Range("subtotalPropisMark").Cells(1, iCounter).Value = "X" _
                            And .Range("tempSubTotals").Cells(1, iCounter).Value <> "?" _
                            Then
                                Select Case .Range("subtotalMark").Cells(1, iCounter).Value
                                    Case "L"
                                        .Range("tempSubTotals").Cells(1, iCounter).Value = dValue
'                                       .Range("it_" & Format(.Range("columnList").Cells(1, iCounter))).Value = .Range("it_" & Format(.Range("columnList").Cells(1, iCounter))).Value + dValue
                                    Case "C"
                                        .Range("tempSubTotals").Cells(1, iCounter).Value = .Range("tempSubTotals").Cells(1, iCounter).Value + 1
'                                       .Range("it_" & Format(.Range("columnList").Cells(1, iCounter))).Value = .Range("it_" & Format(.Range("columnList").Cells(1, iCounter))).Value + dValue
                                    Case "S"
                                        .Range("tempSubTotals").Cells(1, iCounter).Value = .Range("tempSubTotals").Cells(1, iCounter).Value + dValue
'                                       .Range("it_" & Format(.Range("columnList").Cells(1, iCounter))).Value = .Range("it_" & Format(.Range("columnList").Cells(1, iCounter))).Value + dValue
                                End Select
                            End If
                        End If
                    Else
                        ' .Range(sPrefix & Format(.Range("columnList").Cells(1, iCounter))).NumberFormat = "Text"
                        .Range(sPrefix & Format(.Range("columnList").Cells(1, iCounter))).Value = sValue
                        If (Not IsNull(.Range("subtotalMark").Cells(1, iCounter).Value) _
                            And .Range("subtotalMark").Cells(1, iCounter).Value <> "") _
                        Or .Range("subtotalPropisMark").Cells(1, iCounter).Value = "X" _
                        Then
                            Select Case .Range("subtotalMark").Cells(1, iCounter).Value
                                Case "L"
                                    .Range("tempSubTotals").Cells(1, iCounter).Value = CDbl(.Range("tempRow").Cells(1, iCounter + 1).Value)
'                                   .Range("it_" & Format(.Range("columnList").Cells(1, iCounter))).Value = .Range("it_" & Format(.Range("columnList").Cells(1, iCounter))).Value + CDbl(.Range("tempRow").Cells(1, iCounter + 1).Value)
                                Case "C"
                                    .Range("tempSubTotals").Cells(1, iCounter).Value = .Range("tempSubTotals").Cells(1, iCounter).Value + 1
'                                   .Range("it_" & Format(.Range("columnList").Cells(1, iCounter))).Value = .Range("it_" & Format(.Range("columnList").Cells(1, iCounter))).Value + CDbl(.Range("tempRow").Cells(1, iCounter + 1).Value)
                                Case "S"
                                    .Range("tempSubTotals").Cells(1, iCounter).Value = .Range("tempSubTotals").Cells(1, iCounter).Value + CDbl(.Range("tempRow").Cells(1, iCounter + 1).Value)
'                                   .Range("it_" & Format(.Range("columnList").Cells(1, iCounter))).Value = .Range("it_" & Format(.Range("columnList").Cells(1, iCounter))).Value + CDbl(.Range("tempRow").Cells(1, iCounter + 1).Value)
                            End Select
                        End If
                    End If
                End If
            Next iCounter
            Select Case sPrefix
                Case "da_"
                    Call copyTemplateRange(ActiveWorkbook.Sheets("Template").Range("dataAlone"), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
                    p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets("Template").Range("dataAlone").Rows.Count
                    g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + ActiveWorkbook.Sheets("Template").Range("dataAlone").Height
                Case "df_"
                    Call copyTemplateRange(ActiveWorkbook.Sheets("Template").Range("dataFirst"), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
                    p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets("Template").Range("dataFirst").Rows.Count
                    g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + ActiveWorkbook.Sheets("Template").Range("dataFirst").Height
                Case "d_"
                    Call copyTemplateRange(ActiveWorkbook.Sheets("Template").Range("data"), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
                    p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets("Template").Range("data").Rows.Count
                    g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + ActiveWorkbook.Sheets("Template").Range("data").Height
                Case "dl_"
                    Call copyTemplateRange(ActiveWorkbook.Sheets("Template").Range("dataLast"), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
                    p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets("Template").Range("dataLast").Rows.Count
                    g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + ActiveWorkbook.Sheets("Template").Range("dataLast").Height
            End Select
            If g_dPageHeight > 0 _
            And g_dCurrentPageDataHeight + g_dPageSubTotalHeight + dMaxDataHeight + dMaxDataHeight > g_dPageHeight _
            Then
                Call printPageSubTotal( _
                      p_sSheetName _
                    , False _
                    , p_iLastRow _
                    , g_dCurrentPageDataHeight _
                )
                 ActiveWorkbook.Sheets(p_sSheetName).Rows(p_iLastRow).PageBreak = xlPageBreakManual
'                ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow + 1, 1) = "  "
'                While ActiveWorkbook.Sheets(p_sSheetName).Rows(p_iLastRow).PageBreak = xlNone
'                    p_iLastRow = p_iLastRow + 1
'                    ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1) = "  "
'                Wend
                p_bNeedNewPage = True
                Exit Sub
            Else
                p_bNeedNewPage = False
            End If
        Wend
    End With
    Exit Sub
ErrorHandler:
'    MsgBox Err.Description & ". Ошибка вывода строки на странице. Строка вывода: " & _
'    CStr(iRowCounter) & ". Столбец: " & CStr(iCounter)
    Resume Next
End Sub

Sub printPageHeader( _
      ByVal p_sSheetName As String _
    , ByRef p_iLastRow As Long _
    , ByRef g_dCurrentPageDataHeight _
)
    Call copyTemplateRange( _
          ActiveWorkbook.Sheets("Template").Range("pageHeader") _
        , ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1) _
        , True _
    )
    p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets("Template").Range("pageHeader").Rows.Count
    g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + g_dPageHeaderHeight
End Sub

Sub printPageSubTotal( _
      ByVal p_sSheetName As String _
    , ByVal p_bLastPage As Boolean _
    , ByRef p_iLastRow As Long _
    , ByRef g_dCurrentPageDataHeight _
)
Dim sLabel As String
Dim bLabelExists As Boolean
On Error GoTo errPrintPageSubTotal
    If g_iColumnAmount = 0 _
    Or g_iSubtotalAmount = 0 Then
        Exit Sub
    End If
    Dim iCounter As Integer
    With ActiveWorkbook.Sheets("Template")
        For iCounter = 1 To g_iColumnAmount
            If Not IsNull(.Range("subtotalMark").Cells(1, iCounter).Value) _
            Or .Range("subtotalMark").Cells(1, iCounter).Value <> "" _
            Then
                sLabel = "itp_" & Format(.Range("columnList").Cells(1, iCounter))
                Call CheckLabel( _
                      ByVal sLabel _
                    , bLabelExists _
                )
                If bLabelExists = True Then
                    .Range(sLabel).Value = .Range("tempSubTotals").Cells(1, iCounter).Value
                End If
            End If
            If .Range("subtotalPropisMark").Cells(1, iCounter).Value = "X" Then
                sLabel = "itp_s_" & Format(.Range("columnList").Cells(1, iCounter))
                Call CheckLabel( _
                      ByVal sLabel _
                    , bLabelExists _
                )
                If bLabelExists = True Then
                    Select Case .Range("columnType").Cells(1, iCounter).Value
                        Case "I"
                            .Range(sLabel).Value = IntegerToWords(CLng(.Range("tempSubTotals").Cells(1, iCounter).Value), True)
                        Case "D"
                            .Range(sLabel).Value = DecimalToWords(CDbl(.Range("tempSubTotals").Cells(1, iCounter).Value))
                        Case "C"
                            .Range(sLabel).Value = NumberToWordsRubl(CDbl(.Range("tempSubTotals").Cells(1, iCounter).Value))
                    End Select
                End If
            End If
        Next iCounter
        If p_bLastPage = False Then
            Call copyTemplateRange(.Range("pageSubTotal"), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
            p_iLastRow = p_iLastRow + .Range("pageSubTotal").Rows.Count
            g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + g_dPageSubTotalHeight
        Else
            Call copyTemplateRange(.Range("pageSubTotalLast"), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
            p_iLastRow = p_iLastRow + .Range("pageSubTotalLast").Rows.Count
            g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + g_dPageSubTotalLastHeight
        End If
    End With
    Exit Sub
errPrintPageSubTotal:
    MsgBox Err.Description & ". Ошибка вывода подитогов на странице. Колонка: " & _
    CStr(iCounter)
    Resume Next
End Sub

Sub CheckLabel( _
      ByVal p_sLabel _
    , ByRef p_bExists _
)
Dim nmName As Name

    p_bExists = False
    For Each nmName In ActiveWorkbook.Names
        If nmName.Name = p_sLabel Then
            p_bExists = True
            Exit For
        End If
    Next nmName
End Sub

Sub getPageHeight(ByVal p_sSheetName, ByRef p_dPageHeight As Double)
Dim i As Integer
'Dim iPageCount As Integer
'Dim hpbrk As Object

On Error GoTo errorGetPageHight

With ActiveWorkbook.Worksheets(p_sSheetName)
    .Cells(250, 1) = "Mark for PageBreak"
'    .Rows(800).PageBreak = xlPageBreakManual
'    For i = 1 To 799
'        .Cells(i, 1) = "Mark for PageBreak"
'        .Cells(i, 2) = "Mark for PageBreak"
'        .Cells(i, 3) = "Mark for PageBreak"
'    Next i
' .ResetAllPageBreaks
' .DisplayPageBreaks = True
    p_dPageHeight = 0
    For i = 1 To 250 ' .UsedRange.Rows.Count
        If .Rows(i).PageBreak = xlManual Then
'            MsgBox "There is a manual page break above row " & i
        ElseIf .Rows(i).PageBreak = xlAutomatic Then
'            MsgBox "There is an automatic page break above row " & i
            p_dPageHeight = p_dPageHeight + .Rows(i).Height
            Exit For
        End If
        p_dPageHeight = p_dPageHeight + .Rows(i).Height
    Next
    .Rows("1:260").Delete
End With
'iPageCount = .HPageBreaks.Count
'MsgBox "Страниц H " & iPageCount
'    If iPageCount > 0 Then
'        For i = 1 To iPageCount
'            MsgBox "Тип разрыва страницы: " & .HPageBreaks(i).Type
'            MsgBox "Тип страницы: " & .HPageBreaks(i).Location.Row
'        Next i
'        For Each hpbrk In .HPageBreaks
'            MsgBox "Разрыв страницы: " & hpbrk.Location.Row
'            If hpbrk.Type = xlPageBreakAutomatic Then
'                For i = 1 To hpbrk.Location.Row
'                    p_dPageHeight = p_dPageHeight + .Rows(i).Height
'                Next i
'                Exit For
'            End If
'        Next hpbrk
'    Else
'        p_dPageHeight = 0
'    End If

'MsgBox "Высота страницы " & p_dPageHeight


'    i = 1
'    While ActiveWorkbook.Sheets("2").Rows(i).PageBreak = xlNone
'        ActiveWorkbook.Sheets("2").Cells(1, 1) = 1
'        i = i + 1
'        dHeight = dHeight + ActiveWorkbook.Sheets("2").Rows(i).Height
'        ' ActiveWorkbook.Sheets("2").Cells(i, 1) = ""
'    Wend
'    i = ActiveWorkbook.Sheets("1").HPageBreaks(1).Location.Row
'    MsgBox i
' MsgBox ActiveWorkbook.Sheets("1").PageSetup.PaperSize
' MsgBox ActiveWorkbook.Sheets("1").Range("A1").Rows(1).Height
' MsgBox ActiveWorkbook.Sheets("1").HPageBreaks(1).Location.Rows(1).Height
Exit Sub
errorGetPageHight:
    MsgBox Err.Description & ". Ошибка вычисления высоты страницы. "
    Resume Next
End Sub

Sub getTemplateHeights( _
                          ByVal p_sSheetName _
                        , ByRef g_dHeaderHeight As Double _
                        , ByRef g_dPageHeaderHeight As Double _
                        , ByRef g_dDataAloneHeight As Double _
                        , ByRef g_dDataFirstHeight As Double _
                        , ByRef g_dDataHeight As Double _
                        , ByRef g_dDataLastHeight As Double _
                        , ByRef g_dPageSubTotalHeight As Double _
                        , ByRef g_dPageSubTotalLastHeight As Double _
                        , ByRef g_dPageTotalHeight As Double _
                        , ByRef g_dFooterHeight As Double _
                        )

Dim nmName As Name

With ActiveWorkbook.Sheets(p_sSheetName)

    g_dHeaderHeight = 0#
    g_dPageHeaderHeight = 0#
    g_dDataAloneHeight = 0#
    g_dDataFirstHeight = 0#
    g_dDataHeight = 0#
    g_dDataLastHeight = 0#
    g_dPageSubTotalHeight = 0#
    g_dPageSubTotalLastHeight = 0#
    g_dPageTotalHeight = 0#
    g_dFooterHeight = 0#
    For Each nmName In ActiveWorkbook.Names
        Select Case UCase(nmName.Name)
            Case "HEADER"
                g_dHeaderHeight = .Range("header").Height
            Case "PAGEHEADER"
                g_dPageHeaderHeight = .Range("pageHeader").Height
            Case "DATAALONE"
                g_dDataAloneHeight = .Range("dataAlone").Height
            Case "DATAFIRST"
                g_dDataFirstHeight = .Range("dataFirst").Height
            Case "DATA"
                g_dDataHeight = .Range("data").Height
            Case "DATALAST"
                g_dDataLastHeight = .Range("dataLast").Height
            Case "PAGESUBTOTAL"
                g_dPageSubTotalHeight = .Range("pageSubTotal").Height
            Case "PAGESUBTOTALLAST"
                g_dPageSubTotalLastHeight = .Range("pageSubTotalLast").Height
            Case "TOTAL"
                g_dPageTotalHeight = .Range("total").Height
            Case "FOOTER"
                g_dFooterHeight = .Range("footer").Height
        End Select
    Next nmName
End With

End Sub

Sub fillTemplateHeader(ByVal sFileName As String)
Dim iCounter As Integer
Dim iSubtotalCounter As Integer
Dim nmName As Name
Dim sLabel As String
Dim sValue As String
Dim sBuffer As String

On Error GoTo errorFillTemplateHeader

    g_sRegularExpressions = 0
    Open sFileName For Input As #1
    iCounter = 0
    With ActiveWorkbook.Worksheets("Template")
        While Not EOF(1)
            iCounter = iCounter + 1
            Line Input #1, sBuffer
            sLabel = Mid(sBuffer, 1, InStr(sBuffer, Chr(9)) - 1)
            sValue = Mid(sBuffer, InStr(sBuffer, Chr(9)) + 1)
            Select Case sLabel
                Case "regularExpressions"
                    g_sRegularExpressions = CInt(sValue)
                Case "valutCode"
                    g_sValutCode = sValue
                Case "columnList"
                    g_sColumnList = sValue
                Case "columnType"
                    g_sColumnType = sValue
                Case "columnAmount"
                    g_iColumnAmount = CInt(sValue)
                Case "subtotalList"
                    g_sSubtotalList = sValue
                Case "subtotalType"
                    g_sSubtotalType = sValue
                Case "subtotalAmount"
                    g_iSubtotalAmount = CInt(sValue)
                Case "subtotalPropisList"
                    g_sSubtotalPropisList = sValue
                Case "subtotalPropisAmount"
                    g_iSubtotalPropisAmount = CInt(sValue)
                Case Else
                    For Each nmName In ActiveWorkbook.Names
                        If nmName.Name = sLabel And sValue <> "" Then
                            If g_sRegularExpressions = 1 Then
                                sValue = Replace(sValue, "\n", Chr(10))
                            End If
                            .Range(sLabel) = sValue
                        End If
                    Next nmName
            End Select
        Wend
        If g_sValutCode = "" Then
            MsgBox "Не задан код валюты"
            End
        End If
        If Not IsNumeric(g_sValutCode) Then
            MsgBox "Неверно задан код валюты:" & g_sValutCode
            End
        End If
        .Range("columnlist") = g_sColumnList
        If g_sColumnList <> "" Then
            .Range("columnlist").TextToColumns DataType:=xlDelimited, _
                ConsecutiveDelimiter:=False, Tab:=False, Comma:=True
        End If
        .Range("columnType") = g_sColumnType
        If g_sColumnType <> "" Then
            .Range("columnType").TextToColumns DataType:=xlDelimited, _
                ConsecutiveDelimiter:=False, Tab:=False, Comma:=True
        End If
        .Range("subtotalList") = g_sSubtotalList
        If g_sSubtotalList <> "" Then
            .Range("subtotalList").TextToColumns DataType:=xlDelimited, _
                ConsecutiveDelimiter:=False, Tab:=False, Comma:=True
        End If
        .Range("subtotalType") = g_sSubtotalType
        If g_sSubtotalType <> "" Then
            .Range("subtotalType").TextToColumns DataType:=xlDelimited, _
                ConsecutiveDelimiter:=False, Tab:=False, Comma:=True
        End If
        If g_sSubtotalPropisList <> "" Then
            .Range("subtotalPropisList") = g_sSubtotalPropisList
            .Range("subtotalPropisList").TextToColumns DataType:=xlDelimited, _
                ConsecutiveDelimiter:=False, Tab:=False, Comma:=True
        End If
        For iCounter = 1 To g_iColumnAmount
            For iSubtotalCounter = 1 To g_iSubtotalAmount
                If .Range("subtotalList").Cells(1, iSubtotalCounter).Value = .Range("columnlist").Cells(1, iCounter).Value Then
                    .Range("subtotalMark").Cells(1, iCounter).Value = .Range("subtotalType").Cells(1, iSubtotalCounter).Value
                End If
            Next iSubtotalCounter
            If g_sSubtotalPropisList <> "" Then
                For iSubtotalCounter = 1 To g_iSubtotalPropisAmount
                    If .Range("subtotalPropisList").Cells(1, iSubtotalCounter).Value = .Range("columnList").Cells(1, iCounter).Value Then
                        .Range("subtotalPropisMark").Cells(1, iCounter).Value = "X"
                    End If
                Next iSubtotalCounter
            End If
        Next iCounter
    End With
    Close #1
    Exit Sub
errorFillTemplateHeader:
    MsgBox Err.Description & ". Ошибка заполнения шапки шаблона."

End Sub

Sub clearGlobalVariables()
    g_dHeaderHeight = 0#
    g_dPageHeaderHeight = 0#
    g_dDataAloneHeight = 0#
    g_dDataFirstHeight = 0#
    g_dDataHeight = 0#
    g_dDataLastHeight = 0#
    g_dPageSubTotalHeight = 0#
    g_dPageSubTotalLastHeight = 0#
    g_dPageTotalHeight = 0#
    g_dFooterHeight = 0#
    g_dPageHeight = 0#
    g_dCurrentPageDataHeight = 0#
    g_iSheetHeight = 0
End Sub

Sub getDecimalFromString( _
      ByVal p_sDecimalString _
    , ByRef p_dDecimal _
)
Dim iDelimPos As Integer
Dim iMantissLength As Integer
Dim bIsNegative As Boolean

        If IsNull(p_sDecimalString) Then
            p_dDecimal = 0
            Exit Sub
        End If
        p_sDecimalString = Trim(p_sDecimalString)
        If p_sDecimalString = "" Then
            p_dDecimal = 0
            Exit Sub
        End If
        If Mid(p_sDecimalString, 1, 1) = "-" Then
            bIsNegative = True
            p_sDecimalString = Mid(p_sDecimalString, 2)
        Else
            bIsNegative = False
        End If
        iDelimPos = InStr(p_sDecimalString, ".")
        If iDelimPos = 0 Then
            p_dDecimal = CDbl(p_sDecimalString)
        Else
            iMantissLength = Len(p_sDecimalString) - iDelimPos
            If iDelimPos = 1 Then
                p_dDecimal = 0#
            Else
                p_dDecimal = CDbl(Mid(p_sDecimalString, 1, iDelimPos - 1))
            End If
            If iMantissLength > 0 Then
                If iMantissLength > 10 Then
                    iMantissLength = 10
                End If
                p_dDecimal = p_dDecimal + (CDbl(Mid(p_sDecimalString, iDelimPos + 1, iMantissLength)) * 10 ^ ((-1) * iMantissLength))
            End If
        End If
        If bIsNegative = True Then
            p_dDecimal = -1 * p_dDecimal
        End If
End Sub


Function DecimalToWords(ByVal nNum As Double) As String
Dim sStr As String
Dim iIntPart As Long
Dim iDecPart As Long
Dim sIntPart As String
Dim sDecPart As String
Dim sIntPartTrans As String
Dim sDecPartTrans As String
Dim sIntPostf As String
Dim sDecPostf As String
Dim s1 As String
Dim s2 As String

    sStr = Format(nNum, "###0.00")

    iIntPart = Int(sStr)
    iDecPart = Int(Right(sStr, 2))
    sIntPart = Format(iIntPart)
    sDecPart = Format(iDecPart)

    sIntPartTrans = Trim(IntegerToWords(iIntPart, True))
    If iDecPart <> 0 Then
        s1 = Mid(sIntPart, Len(sIntPart), 1)
        If Len(sIntPart) > 1 Then
            s2 = Mid(sIntPart, Len(sIntPart) - 1, 1)
        Else
            s2 = ""
        End If
        sIntPostf = IIf(s2 = "1", "целых", _
        IIf(s1 = "1", "целая", _
        IIf(s1 = "2" Or s1 = "3" Or s1 = "4", "целые", _
        "целых")))
        sDecPartTrans = Format(iDecPart)
        s1 = Mid(sDecPart, Len(sDecPart), 1)
        If Len(sDecPart) > 1 Then
            s2 = Mid(sDecPart, Len(sDecPart) - 1, 1)
        Else
            s2 = ""
        End If
        sDecPostf = IIf(s2 = "1", "сотых", _
        IIf(s1 = "1", "сотая", _
        IIf(s1 = "2" Or s1 = "3" Or s1 = "4", "сотые", _
        "сотых")))
    End If
    DecimalToWords = sIntPartTrans & " " & sIntPostf & " " & sDecPartTrans & " " & sDecPostf
End Function

Function IntegerToWords( _
      ByVal nNum As Long _
    , ByVal p_bMale _
) As String
Dim sStr As String
Dim s1 As String
Dim s2 As String
Dim ss As String
Dim sFin As String
Dim sThrees As String

Dim i As Integer, n As Integer, nLen As Integer
Dim bMale As Boolean
    If nNum = 0 Then
        IntegerToWords = "Ноль "
        Exit Function
    End If
    sStr = Format(nNum, "###0")
    nLen = Len(sStr)
    If nLen > 12 Then
        GoTo errIntegerToWords
    End If

    n = Int(nLen / 3)
    If n * 3 <> nLen Then
        n = n + 1
    End If
    For i = 1 To n
        sThrees = Right(sStr, 3)
        If i < n Then
            sStr = Mid(sStr, 1, Len(sStr) - 3)
        End If
        s1 = Mid(sThrees, Len(sThrees), 1)
        If Len(sThrees) > 1 Then
            s2 = Mid(sThrees, Len(sThrees) - 1, 1)
        Else
            s2 = ""
        End If
        Select Case i
            Case 1
                ss = ""
                bMale = p_bMale
            Case 2
                ss = IIf(s2 = "1", "тысяч", _
                IIf(s1 = "1", "тысяча", IIf(s1 = "2" Or s1 = "3" Or s1 = "4", "тысячи", "тысяч")))
                bMale = False
            Case 3
                ss = IIf(s2 = "1", "миллионов", _
                IIf(s1 = "1", "миллион", IIf(s1 = "2" Or s1 = "3" Or s1 = "4", "миллиона", "миллионов")))
                bMale = True
            Case 4
                ss = IIf(s2 = "1", "миллиардов", _
                IIf(s1 = "1", "миллиард", IIf(s1 = "2" Or s1 = "3" Or s1 = "4", "миллиарда", "миллиардов")))
                bMale = True
            Case Else
                GoTo errIntegerToWords
        End Select
        sFin = Get3ToWords(sThrees, 3, bMale) & " " & ss & " " & sFin
    Next i
ExFun:
    IntegerToWords = UCase(Mid(sFin, 1, 1)) & Mid(sFin, 2)

    Exit Function
errIntegerToWords:
    IntegerToWords = ""
    Exit Function
End Function

Sub getValutRubKop( _
      ByVal p_case As String _
    , ByRef p_sRub As String _
    , ByRef p_sKop As String _
)
Dim asRub(1 To 3, 0 To 2) As String
Dim asKop(1 To 3, 0 To 2) As String
Dim iRow As Integer
Dim iCol As Integer

    asRub(1, 0) = "единица"
    asRub(2, 0) = "единицы"
    asRub(3, 0) = "единиц"
    asRub(1, 1) = "рубль"
    asRub(2, 1) = "рубля"
    asRub(3, 1) = "рублей"
    asRub(1, 2) = "доллар"
    asRub(2, 2) = "доллара"
    asRub(3, 2) = "долларов"

    asKop(1, 0) = "сотая"
    asKop(2, 0) = "сотые"
    asKop(3, 0) = "сотых"
    asKop(1, 1) = "копейка"
    asKop(2, 1) = "копейки"
    asKop(3, 1) = "копеек"
    asKop(1, 2) = "цент"
    asKop(2, 2) = "цента"
    asKop(3, 2) = "центов"

    iCol = CInt(g_sValutCode) + 1
    If iCol <> 1 _
    And iCol <> 2 _
    Then
        iCol = 0
    End If
    Select Case p_case
        Case "nominative"
            iRow = 1
        Case "genitive"
            iRow = 2
        Case "multiple"
            iRow = 3
    End Select
    p_sRub = asRub(iRow, iCol)
    p_sKop = asKop(iRow, iCol)

End Sub


Function NumberToWordsRubl(ByVal nNum As Double) As String
Dim sStr As String, s1 As String, s2 As String, ss As String, sFin As String
Dim sRub As String
Dim sKop As String
Dim i As Integer, n As Integer, nLen As Integer
Dim bMale As Boolean

On Error GoTo errNumberToWordsRubl

If nNum = 0 Then
    Call getValutRubKop( _
          ByVal "multiple" _
        , sRub _
        , sKop _
    )
    NumberToWordsRubl = "Ноль " & sRub & " 00 " & sKop
    Exit Function
End If
sStr = Format(nNum, "###0.00")
nLen = Len(sStr)
If nLen > 15 Then
    GoTo errNumberToWordsRubl
End If
s1 = Mid(sStr, nLen, 1)
s2 = Mid(sStr, nLen - 1, 1)
If s1 = "0" _
And s2 = "0" _
Then
    Call getValutRubKop( _
          ByVal "multiple" _
        , sRub _
        , sKop _
    )
    sFin = "00 " & sKop
    GoTo Rubles
End If
If s2 = 1 Then
    Call getValutRubKop( _
          ByVal "multiple" _
        , sRub _
        , sKop _
    )
    sFin = s2 & s1 & " " & sKop
Else
    Select Case s1
        Case "1"
            Call getValutRubKop( _
                  ByVal "nominative" _
                , sRub _
                , sKop _
            )
        Case "2", "3", "4"
            Call getValutRubKop( _
                  ByVal "genitive" _
                , sRub _
                , sKop _
            )
        Case Else
            Call getValutRubKop( _
                  ByVal "multiple" _
                , sRub _
                , sKop _
            )
    End Select
    sFin = s2 & s1 & " " & sKop
    ' IIf(s1 = 1, "копейка", IIf(s1 = 2 Or s1 = 3 Or s1 = 4, "копейки", "копеек"))
End If
Rubles:
If Left(sStr, nLen - 3) = "0" Then
    Call getValutRubKop( _
          ByVal "multiple" _
        , sRub _
        , sKop _
    )
    sFin = "Ноль " & sRub & " " & sFin
    GoTo ExFun
End If
n = Int((nLen - 3) / 3)
If n * 3 <> nLen - 3 Then n = n + 1
For i = 1 To n
nLen = nLen - 3
sStr = Left(sStr, nLen)
s1 = Mid(sStr, nLen, 1)
If nLen < 2 Then
s2 = "0"
Else
s2 = Mid(sStr, nLen - 1, 1)
End If
If i = 1 Then
    If s2 = "1" Then
        Call getValutRubKop( _
              ByVal "multiple" _
            , ss _
            , sKop _
        )
    Else
        Select Case s1
            Case "1"
                Call getValutRubKop( _
                      ByVal "nominative" _
                    , ss _
                    , sKop _
                )
            Case "2", "3", "4"
                Call getValutRubKop( _
                      ByVal "genitive" _
                    , ss _
                    , sKop _
                )
            Case Else
                Call getValutRubKop( _
                      ByVal "multiple" _
                    , ss _
                    , sKop _
                )
        End Select
    End If
    bMale = True
ElseIf i = 2 Then
ss = IIf(s2 = "1", "тысяч", _
IIf(s1 = "1", "тысяча", IIf(s1 = "2" Or s1 = "3" Or s1 = "4", "тысячи", "тысяч")))
bMale = False
ElseIf i = 3 Then
ss = IIf(s2 = "1", "миллионов", _
IIf(s1 = "1", "миллион", IIf(s1 = "2" Or s1 = "3" Or s1 = "4", "миллиона", "миллионов")))
bMale = True
ElseIf i = 4 Then
ss = IIf(s2 = "1", "миллиардов", _
IIf(s1 = "1", "миллиард", IIf(s1 = "2" Or s1 = "3" Or s1 = "4", "миллиарда", "миллиардов")))
bMale = True
End If
sFin = Get3ToWords(sStr, 3, bMale) & " " & ss & " " & sFin
Next i
ExFun:
NumberToWordsRubl = UCase(Mid(sFin, 1, 1)) & Mid(sFin, 2)
    Exit Function
errNumberToWordsRubl:
    NumberToWordsRubl = ""
    Exit Function
End Function

Function Get3ToWords( _
      ByVal sStr As String _
    , ByVal nStart As Integer _
    , ByVal bMale As Boolean _
) As String
Dim nLen As Integer
Dim i, n As Integer
Dim sFin, ss, s() As String
Start:
nLen = Len(sStr)
nStart = nLen - nStart + 1
If nStart < 1 Then
If nStart > -2 Then
sStr = Mid(sStr, 1, nStart + 2)
nStart = 1
nLen = Len(sStr)
Else
Get3ToWords = ""
Exit Function
End If
End If
If sStr = "" Then
Get3ToWords = ""
Exit Function
End If
sStr = Mid(sStr, nStart)
nLen = Len(sStr)
n = InStr(sStr, ".")
If n = 0 Then
n = nLen + 1
sStr = sStr & "."
End If
If n = 1 Then
Get3ToWords = ""
Exit Function
ElseIf n <= 3 Then
ss = Mid(sStr, 1, n - 1)
nLen = n - 1
Else
ss = Mid(sStr, 1, 3)
nLen = 3
End If
On Error GoTo ErrDigit
n = CInt(ss)
ss = CStr(n)
nLen = Len(ss)
On Error GoTo 0
ReDim s(nLen)
For i = 1 To nLen
s(nLen - i + 1) = Mid(ss, i, 1)
Next i
If nLen >= 2 Then
If s(2) = 1 Then
sFin = GetStrFromDigit(s(1), 3)
If nLen = 2 Then GoTo Final
Else
GoTo Label2
End If
Else
Label2:
If (bMale) Then
sFin = GetStrFromDigit(s(1), 1)
Else
sFin = GetStrFromDigit(s(1), 2)
End If
If nLen = 1 Then
GoTo Final
Else
sFin = GetStrFromDigit(s(2), 4) & " " & sFin
If nLen = 2 Then GoTo Final
End If
End If
sFin = GetStrFromDigit(s(3), 5) & " " & sFin
Final:
Get3ToWords = sFin
Exit Function
ErrDigit:
    sFin = ""
    Exit Function
End Function

Function GetStrFromDigit(ByVal aDigit As String, ByVal nMode As Integer) As String

Dim asDigits(0 To 9, 1 To 5) As String

asDigits(0, 1) = ""
asDigits(1, 1) = "один"
asDigits(2, 1) = "два"
asDigits(3, 1) = "три"
asDigits(4, 1) = "четыре"
asDigits(5, 1) = "пять"
asDigits(6, 1) = "шесть"
asDigits(7, 1) = "семь"
asDigits(8, 1) = "восемь"
asDigits(9, 1) = "девять"
asDigits(0, 2) = ""
asDigits(1, 2) = "одна"
asDigits(2, 2) = "две"
asDigits(3, 2) = "три"
asDigits(4, 2) = "четыре"
asDigits(5, 2) = "пять"
asDigits(6, 2) = "шесть"
asDigits(7, 2) = "семь"
asDigits(8, 2) = "восемь"
asDigits(9, 2) = "девять"
asDigits(0, 3) = "десять"
asDigits(1, 3) = "одиннадцать"
asDigits(2, 3) = "двенадцать"
asDigits(3, 3) = "тринадцать"
asDigits(4, 3) = "четырнадцать"
asDigits(5, 3) = "пятнадцать"
asDigits(6, 3) = "шестнадцать"
asDigits(7, 3) = "семнадцать"
asDigits(8, 3) = "восемнадцать"
asDigits(9, 3) = "девятнадцать"
asDigits(0, 4) = ""
asDigits(1, 4) = "десять"
asDigits(2, 4) = "двадцать"
asDigits(3, 4) = "тридцать"
asDigits(4, 4) = "сорок"
asDigits(5, 4) = "пятьдесят"
asDigits(6, 4) = "шестьдесят"
asDigits(7, 4) = "семьдесят"
asDigits(8, 4) = "восемьдесят"
asDigits(9, 4) = "девяносто"
asDigits(0, 5) = ""
asDigits(1, 5) = "сто"
asDigits(2, 5) = "двести"
asDigits(3, 5) = "триста"
asDigits(4, 5) = "четыреста"
asDigits(5, 5) = "пятьсот"
asDigits(6, 5) = "шестьсот"
asDigits(7, 5) = "семьсот"
asDigits(8, 5) = "восемьсот"
asDigits(9, 5) = "девятьсот"

GetStrFromDigit = asDigits(Int(aDigit), nMode)

End Function


Sub checkAllTempLabels( _
      ByRef p_bExists As Boolean _
    , ByRef p_sNoLabelList As String _
)
Dim bLabelExists As Boolean
Dim sNoLabelsList As String

    p_bExists = True
    Call CheckLabel( _
          ByVal "columnList" _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = "columnList"
    End If
    Call CheckLabel( _
          ByVal "columnType" _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & "columnType"
    End If
    Call CheckLabel( _
          ByVal "subtotalMark" _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & "subtotalMark"
    End If
    Call CheckLabel( _
          ByVal "subtotalPropisMark" _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & "subtotalPropisMark"
    End If
    Call CheckLabel( _
          ByVal "subtotalList" _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & "subtotalList"
    End If
    Call CheckLabel( _
          ByVal "subtotalType" _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & "subtotalType"
    End If
    Call CheckLabel( _
          ByVal "subtotalPropisList" _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & "subtotalPropisList"
    End If
    Call CheckLabel( _
          ByVal "tempRow" _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & "tempRow"
    End If
    Call CheckLabel( _
          ByVal "tempSubTotals" _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & "tempSubTotals"
    End If
    Call CheckLabel( _
          ByVal "tempStringSubTotals" _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & "tempStringSubTotals"
    End If
End Sub