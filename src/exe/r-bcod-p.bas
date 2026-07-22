Attribute VB_Name = "МодульTH"
Option Explicit

Dim g_sTemplateName As String
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

Dim g_sHideColList As String
Dim g_sRegularExpressions As Long
Dim g_sValutCode As String
Dim g_sColumnList As String
Dim g_sColumnType As String
Dim g_iColumnAmount As Long
Dim g_sSubtotalList As String
Dim g_sSubtotalType As String
Dim g_iSubtotalAmount As Long
Dim g_sSubtotalPropisList As String
Dim g_iSubtotalPropisAmount As Long

Dim g_sTempLabelColumnList           As String
Dim g_sTempLabelColumnType           As String
Dim g_sTempLabelSubtotalMark         As String
Dim g_sTempLabelSubtotalPropisMark   As String
Dim g_sTempLabelSubtotalList         As String
Dim g_sTempLabelSubtotalType         As String
Dim g_sTempLabelSubtotalPropisList   As String
Dim g_sTempLabelTempRow              As String
Dim g_sTempLabelTempSubTotals        As String
Dim g_sTempLabelTempStringSubTotals  As String

Dim g_sLabelPageHeader          As String
Dim g_sLabelHeader              As String
Dim g_sLabelDataAlone           As String
Dim g_sLabelDataFirst           As String
Dim g_sLabelData                As String
Dim g_sLabelDataLast            As String
Dim g_sLabelPageSubTotal        As String
Dim g_sLabelPageSubTotalLast    As String
Dim g_sLabelTotal               As String
Dim g_sLabelFooter              As String

Dim g_daPrefix  As String
Dim g_dfPrefix As String
Dim g_dPrefix As String
Dim g_dlPrefix As String
Dim g_itPrefix As String
Dim g_itpPrefix As String
Dim g_itpsPrefix As String

Dim g_iRowDelimiter As Long

Dim g_dCurrentPageDataHeight  As Double

Function IsWorkSheetExist(sSName As String) As Boolean
Dim c As Object

On Error GoTo errНandle:
Set c = Sheets(sSName)
' Альтернативный вариант :
Worksheets(sSName).Cells(1, 1) = Worksheets(sSName).Cells(1, 1)
IsWorkSheetExist = True
Exit Function
errНandle:
IsWorkSheetExist = False
End Function


Sub startFormFromTemplate( _
      p_sHeaderFileName As String _
    , p_sDataFileName As String _
)
    Dim sBuffer As String
    Dim sLabel As String
    Dim sValue0 As String
    Dim sValue As String
    Dim sValuecopyfrom As String
    Dim sTemplate() As String
    Dim sTemplateCopyFrom() As String
    Dim iCounter As Long
    Dim iSheetsAmount As Long

On Error GoTo errStartFromTemplate

'    p_sHeaderFileName = "d:\tmp\p_xc.txt"
'    p_sDataFileName = "d:\tmp\p_xd.txt"


    Application.Interactive = False
    Application.DisplayAlerts = False
    Application.ScreenUpdating = False

    sValue = ""
    Open p_sHeaderFileName For Input As #1
    Do While Not EOF(1)
        Line Input #1, sBuffer
        sLabel = Trim(Mid(sBuffer, 1, InStr(sBuffer, Chr(9)) - 1))
        sValue0 = Trim(Mid(sBuffer, InStr(sBuffer, Chr(9)) + 1))
        If sLabel = "sheetListcopyfrom" _
        Then
            sValuecopyfrom = sValue0
        End If
        If sLabel = "sheetList" _
        Then
            sValue = sValue0
            Exit Do
        End If
    Loop
    Close #1
    If sValue = "" _
    Then
        MsgBox "Не задан список шаблонов"
        Exit Sub
    End If
    sTemplate = Split(sValue, ",")
    If sValuecopyfrom = "" Then
      sValuecopyfrom = String(UBound(sTemplate) + 1, ",")
    End If
    sTemplateCopyFrom = Split(sValuecopyfrom, ",")
    For iCounter = 0 To UBound(sTemplate)
        Call startFormFromTemplateCurrent( _
              p_sHeaderFileName _
            , p_sDataFileName _
            , sTemplate(iCounter) _
            , sTemplateCopyFrom(iCounter) _
            , iSheetsAmount _
        )
        ActiveWorkbook.Worksheets(g_sTemplateName).Delete
        If iSheetsAmount = 1 Or sTemplateCopyFrom(iCounter) <> "" _
        Then
          ActiveWorkbook.Worksheets(sTemplate(iCounter) & "1").Name = sTemplate(iCounter)
        End If
    Next iCounter
    'debug.assert 0
    For iCounter = 0 To UBound(sTemplateCopyFrom)
      If sTemplateCopyFrom(iCounter) <> "" Then
        On Error GoTo hasdeleted
          If IsWorkSheetExist(sTemplateCopyFrom(iCounter)) Then
            ActiveWorkbook.Worksheets(sTemplateCopyFrom(iCounter)).Delete
          End If
hasdeleted:
         End If
    Next iCounter
    ActiveWorkbook.Worksheets(1).Activate
    If p_sHeaderFileName <> "" _
    And Dir(p_sHeaderFileName) <> "" _
    Then
        Kill p_sHeaderFileName
    End If
    If p_sDataFileName <> "" _
    And Dir(p_sDataFileName) <> "" _
    Then
        Kill p_sDataFileName
    End If
    Call makeGroups
    Application.Interactive = True
Exit Sub
errStartFromTemplate:
    MsgBox Err.Description & ". Ошибка основного модуля. Файл Excel: " & ActiveWorkbook.Name
    MsgBox Err.Source
End Sub

Sub makeGroups()
    Dim i As Integer
    Dim ws As Object
    Dim range1 As Object
    Dim grp As String
	
    Set ws = Application.ActiveWorkbook.Worksheets.Item(1)
    i = 10
        
    Do While true
        i = i + 1
		if ws.Cells(i, 34).Value = "Итого:" then exit do
        If ws.Cells(i, 1).Value = "-1" Then
            grp = ws.Cells(i, 34).Value
			if grp = "" then exit do
            set range1 = ws.Range("A" & CStr(i) & ":CU" & CStr(i))
            range1.Merge
			range1.Interior.Color = rgb(204,255,255)
			range1.font.bold = true
            range1.Value = grp
        End If
    Loop
End Sub

Sub startFormFromTemplateCurrent( _
      p_sHeaderFileName As String _
    , p_sDataFileName As String _
    , p_sTemplateName As String _
    , p_sTemplateNameCopyFrom As String _
    , ByRef p_SheetsAmount _
)
Dim sBuffer As String
Dim iCounter As Long
Dim NewSheet As Object
Dim templateExist As Boolean
Dim lastRow As Long
Dim iStartColumn As Long
Dim bNeedNewSheet As Boolean
Dim iSheetNumber As Long
Dim bPrintHeader As Boolean
Dim bLabelExists As Boolean
Dim sNoTempLabelList As String
Dim aname As Name
Dim s_dop As String
'
' Макрос1 Макрос
' Макрос записан 01.12.2004 (VGuntner)
'
On Error GoTo errStartFromTemplateCurrent
    '
    '    Workbooks.Add Template:= _
            "C:\Program Files\Microsoft Office\Шаблоны\t12_97.xlt"
    'ActiveWorkbook.Worksheets(g_sTemplateName).Copy After:=ActiveWorkbook.Worksheets(g_sTemplateName)
    'ActiveWorkbook.Worksheets(ActiveWorkbook.Worksheets.Count).Name = "1"

    'MsgBox ActiveWorkbook.Sheets(g_sTemplateName).HPageBreaks.Count
    g_sTemplateName = p_sTemplateName
    templateExist = False
    If p_sTemplateNameCopyFrom = "" Then
      For Each NewSheet In ActiveWorkbook.Worksheets
          Select Case NewSheet.Name
            Case g_sTemplateName
                templateExist = True
          End Select
      Next NewSheet
    Else
       On Error GoTo errFoundTemplate
        'рождение нового листа
        ActiveWorkbook.Sheets(p_sTemplateNameCopyFrom).Select
        ActiveWorkbook.Sheets(p_sTemplateNameCopyFrom).Copy After:=Sheets(ActiveWorkbook.Sheets.Count)
        ActiveWorkbook.Sheets(ActiveWorkbook.Sheets.Count).Name = g_sTemplateName
        ' надо переименовать все области!!!
        For Each aname In ActiveWorkbook.Names
          If Mid(aname.RefersTo, 1, 5) <> "=#REF" Then
            If aname.RefersToRange.Worksheet.Name = g_sTemplateName Then
              If Len(aname.Name) - Len(ActiveWorkbook.Sheets(p_sTemplateNameCopyFrom).Name) - Len(g_sTemplateName) - 2 > 0 Then
                s_dop = Right(aname.Name, Len(aname.Name) - Len(ActiveWorkbook.Sheets(p_sTemplateNameCopyFrom).Name) - Len(g_sTemplateName) - 2)
                aname.Name = ActiveWorkbook.Sheets(g_sTemplateName).Name & "_" & s_dop
              End If
            End If
          End If
        Next aname
      templateExist = True
    End If
errFoundTemplate:
    If templateExist = False Then
      MsgBox "Не определен шаблон " & g_sTemplateName
      Exit Sub
    End If

    g_iRowDelimiter = 6

    g_sTempLabelColumnList = g_sTemplateName & "_columnList"
    g_sTempLabelColumnType = g_sTemplateName & "_columnType"
    g_sTempLabelSubtotalMark = g_sTemplateName & "_subtotalMark"
    g_sTempLabelSubtotalPropisMark = g_sTemplateName & "_subtotalPropisMark"
    g_sTempLabelSubtotalList = g_sTemplateName & "_subtotalList"
    g_sTempLabelSubtotalType = g_sTemplateName & "_subtotalType"
    g_sTempLabelSubtotalPropisList = g_sTemplateName & "_subtotalPropisList"
    g_sTempLabelTempRow = g_sTemplateName & "_tempRow"
    g_sTempLabelTempSubTotals = g_sTemplateName & "_tempSubTotals"
    g_sTempLabelTempStringSubTotals = g_sTemplateName & "_tempStringSubTotals"

    g_sLabelHeader = g_sTemplateName & "_header"
    g_sLabelPageHeader = g_sTemplateName & "_pageHeader"
    g_sLabelDataAlone = g_sTemplateName & "_dataAlone"
    g_sLabelDataFirst = g_sTemplateName & "_dataFirst"
    g_sLabelData = g_sTemplateName & "_data"
    g_sLabelDataLast = g_sTemplateName & "_dataLast"
    g_sLabelPageSubTotal = g_sTemplateName & "_pageSubTotal"
    g_sLabelPageSubTotalLast = g_sTemplateName & "_pageSubTotalLast"
    g_sLabelTotal = g_sTemplateName & "_total"
    g_sLabelFooter = g_sTemplateName & "_footer"

    g_daPrefix = g_sTemplateName & "_da_"
    g_dfPrefix = g_sTemplateName & "_df_"
    g_dPrefix = g_sTemplateName & "_d_"
    g_dlPrefix = g_sTemplateName & "_dl_"
    g_itpPrefix = g_sTemplateName & "_itp_"
    g_itpsPrefix = g_sTemplateName & "_itp_s_"
    g_itPrefix = g_sTemplateName & "_it_"

    Call CheckLabel( _
          ByVal g_sLabelHeader _
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

    Call fillTemplateHeader(p_sHeaderFileName)

    bNeedNewSheet = True
    iSheetNumber = 1
    If p_sDataFileName = "" Then      ' В печатной форме нет табличной части
        bNeedNewSheet = False
        Set NewSheet = ActiveWorkbook.Worksheets.Add
        NewSheet.Name = g_sTemplateName & Format(iSheetNumber)
        NewSheet.StandardWidth = ActiveWorkbook.Worksheets(g_sTemplateName).StandardWidth
        For iCounter = 1 To ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelHeader).SpecialCells(xlLastCell).Column
            NewSheet.Range("A1").Columns(iCounter).ColumnWidth = ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelHeader).Columns(iCounter).ColumnWidth
        Next iCounter
        With ActiveWorkbook.Worksheets(g_sTemplateName).PageSetup
            NewSheet.PageSetup.Zoom = .Zoom
            NewSheet.PageSetup.Orientation = .Orientation
            NewSheet.PageSetup.LeftHeader = .LeftHeader
            NewSheet.PageSetup.CenterHeader = .CenterHeader
            NewSheet.PageSetup.RightHeader = .RightHeader
            NewSheet.PageSetup.LeftFooter = .LeftFooter
            NewSheet.PageSetup.CenterFooter = .CenterFooter
            NewSheet.PageSetup.RightFooter = .RightFooter
            NewSheet.PageSetup.FirstPageNumber = .FirstPageNumber
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
            ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value = 0#
        Next iCounter
        Call getPageHeight(NewSheet.Name, g_dPageHeight)
        Call getTemplateHeights( _
              g_sTemplateName _
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
              ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelHeader) _
            , ActiveWorkbook.Sheets(NewSheet.Name).Range("A1") _
            , True _
        )
        lastRow = lastRow + ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelHeader).Rows.Count
        If g_dPageHeight > 0 _
        And g_dHeaderHeight + g_dPageHeaderHeight >= g_dPageHeight Then
            If g_dPageHeaderHeight > 0 Then
                ActiveWorkbook.Sheets(NewSheet.Name).Rows(lastRow + 1).PageBreak = xlPageBreakManual
            End If
            g_dCurrentPageDataHeight = 0
        Else
            g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + g_dHeaderHeight
        End If
    Else        ' Обработка табличной части печатной формы
        Open p_sDataFileName For Input As #1

        While bNeedNewSheet = True
            bNeedNewSheet = False
            Set NewSheet = ActiveWorkbook.Worksheets.Add(Null, Worksheets(Worksheets.Count))
            NewSheet.Name = g_sTemplateName & Format(iSheetNumber)
            NewSheet.StandardWidth = ActiveWorkbook.Worksheets(g_sTemplateName).StandardWidth
            For iCounter = 1 To ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelHeader).SpecialCells(xlLastCell).Column
                NewSheet.Range("A1").Columns(iCounter).ColumnWidth = ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelHeader).Columns(iCounter).ColumnWidth
            Next iCounter
            With ActiveWorkbook.Worksheets(g_sTemplateName).PageSetup
                NewSheet.PageSetup.Zoom = .Zoom
                NewSheet.PageSetup.Orientation = .Orientation
                NewSheet.PageSetup.LeftHeader = .LeftHeader
                NewSheet.PageSetup.CenterHeader = .CenterHeader
                NewSheet.PageSetup.RightHeader = .RightHeader
                NewSheet.PageSetup.LeftFooter = .LeftFooter
                NewSheet.PageSetup.CenterFooter = .CenterFooter
                NewSheet.PageSetup.RightFooter = .RightFooter
                NewSheet.PageSetup.FirstPageNumber = .FirstPageNumber
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
                    ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value = 0#
                Next iCounter
'MsgBox "The name of the active printer is " & Application.ActivePrinter
                Call getPageHeight(NewSheet.Name, g_dPageHeight)
                Call getTemplateHeights( _
                      g_sTemplateName _
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
    Call hideColumns( _
          NewSheet.Name _
    )
    p_SheetsAmount = iSheetNumber - 1
    Exit Sub
errStartFromTemplateCurrent:
    MsgBox Err.Description & ". Ошибка модуля листа. Лист: " & _
    g_sTemplateName & Format(iSheetNumber) & ". Файл: " & ActiveWorkbook.Name
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
            If g_dPageHeaderHeight > 0 Then
                ActiveWorkbook.Sheets(p_sSheetName).Rows(p_iLastRow).PageBreak = xlPageBreakManual
            End If
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
        Call copyTemplateRange(ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelTotal), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
        p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelTotal).Rows.Count
    End If
    Call CheckLabel( _
          ByVal g_sLabelFooter _
        , bLabelExists _
    )
    If bLabelExists = True Then
        Call copyTemplateRange(ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelFooter), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
        p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelFooter).Rows.Count
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
Dim iCounter As Long

    bNeedNewPage = True
    p_iLastRow = 1
    iDataRowsForFooter = 1
    g_dCurrentPageDataHeight = 0
    If p_bPrintHeader = True Then
        Call copyTemplateRange( _
              ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelHeader) _
            , ActiveWorkbook.Sheets(p_sSheetName).Range("A1") _
            , True _
        )
        p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelHeader).Rows.Count
        If g_dPageHeight > 0 _
        And g_dHeaderHeight + g_dPageHeaderHeight >= g_dPageHeight Then
            If g_dPageHeaderHeight > 0 Then
                ActiveWorkbook.Sheets(p_sSheetName).Rows(p_iLastRow + 1).PageBreak = xlPageBreakManual
            End If
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
                ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value = 0#
            Next iCounter
        End If
    Wend
End Sub



Sub copyTemplateRange(copyFrom As Range, copyTo As Range, needColumns As Boolean)

Dim sArray
Dim iArrayFieldAmount As Long
Dim iFieldCounter As Long
Dim iRowCounter As Long

    copyFrom.Copy copyTo

    For iFieldCounter = 1 To copyFrom.Columns.Count
        sArray = Split(copyFrom.Cells(1, iFieldCounter).Value, Chr(g_iRowDelimiter))
        iArrayFieldAmount = UBound(sArray) + 1
        If iArrayFieldAmount > 2 Then
          For iRowCounter = 1 To iArrayFieldAmount
              copyTo.Cells(iRowCounter, iFieldCounter).Value = sArray(iRowCounter - 1)
          Next iRowCounter
        End If
    Next iFieldCounter
'    Call fitMergedHorizontal( _
'          copyTo.Worksheet.UsedRange _
'        , copyTo.Worksheet.UsedRange.Columns.Count + 1 _
'    )
End Sub



Sub copyTemplateRangeFormat(copyFrom As Range, copyTo As Range)

Dim aData()
Dim iFieldCounter As Long
Dim iColAmount As Long
Dim r1 As Range
Dim r2 As Range

Set r1 = Range("C11:H11")
Set r2 = Range("C9:H9")

    iColAmount = copyTo.Worksheet.UsedRange.Columns.Count
    ReDim Preserve aData(iColAmount)
    For iFieldCounter = 1 To iColAmount
        aData(iFieldCounter) = copyTo.Cells(1, iFieldCounter).Value
    Next iFieldCounter
    copyFrom.Copy copyTo
    copyTo.EntireRow.RowHeight = copyFrom.EntireRow.RowHeight
    For iFieldCounter = 1 To iColAmount
        copyTo.Cells(1, iFieldCounter).Value = aData(iFieldCounter)
    Next iFieldCounter

End Sub



Sub impString(lineCounter As Long, nameList As String, valueList As String)
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

Sub printPageOfSheet( _
      ByVal p_sSheetName As String _
    , ByRef p_iLastRow As Long _
    , ByRef p_bNeedNewPage As Boolean _
    , ByRef p_bNeedNewSheet As Boolean _
)
Dim iCounter As Long
Dim iRowCounter As Long
Dim bIsFirst As Boolean
Dim sLabel As String
Dim sValue As String
Dim dValue As Double
Dim sBuffer As String
Dim sPrefix As String
Dim dMaxDataHeight As Double
Dim dLastDataRowHeight As Double
Dim dLastDataRowCount As Long
Dim bLabelExists As Boolean
Dim sFormatLabel As String

Dim nmname As Name

On Error GoTo ErrorHandler

    Call printPageHeader( _
          p_sSheetName _
        , p_iLastRow _
        , g_dCurrentPageDataHeight _
    )
With ActiveWorkbook.Worksheets(g_sTemplateName)
'    For Each nmName In ActiveWorkbook.Names
'        If nmName.RefersToRange.Worksheet.Name = g_sTemplateName _
'        and nmName.name = sLabel And sValue <> "" Then
'            .Range(nmName.Value) = sValue
'        End If
'   Next nmName
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
        Do While Not EOF(1)
            iCounter = 0
            iRowCounter = iRowCounter + 1
            Line Input #1, sBuffer
            .Range(.Range(g_sTempLabelTempRow).Cells(1, 1), .Range(g_sTempLabelTempRow).Cells(1, 100)).Clear
            .Range(g_sTempLabelTempRow) = sBuffer
            .Range(g_sTempLabelTempRow).TextToColumns DataType:=xlDelimited, _
                ConsecutiveDelimiter:=False, Tab:=True, Comma:=False, Semicolon:=False, _
                Other:=False, Space:=False, _
                FieldInfo:=Array(Array(1, 2), Array(2, 2), Array(3, 2), Array(4, 2), Array(5, 2) _
                , Array(6, 2), Array(7, 2), Array(8, 2), Array(9, 2), Array(10, 2) _
                , Array(11, 2), Array(12, 2), Array(13, 2), Array(14, 2), Array(15, 2) _
                , Array(16, 2), Array(17, 2), Array(18, 2), Array(19, 2), Array(20, 2) _
                , Array(21, 2), Array(22, 2), Array(23, 2), Array(24, 2), Array(25, 2) _
                , Array(26, 2), Array(27, 2), Array(28, 2), Array(29, 2), Array(30, 2) _
                , Array(31, 2), Array(32, 2), Array(33, 2), Array(34, 2), Array(35, 2))

'Open "D:\tmp\222.txt" For Append As #2
'Write #2, .Range(g_sTempLabelTempRow).Cells(1, iCounter + 2).Value
'Close #2

            If CStr(.Range(g_sTempLabelTempRow).Cells(1, iCounter + 1).Value) <> g_sTemplateName _
            Then
                ' Данные для другого листа
            Else
                If CStr(.Range(g_sTempLabelTempRow).Cells(1, iCounter + 2).Value) = "FMT" Then
'debug.assert 0
                    ' Обработка строки с форматом для текущей строки
                    sFormatLabel = g_sTemplateName _
                        & "_" _
                        & "FMT" _
                        & "_" _
                        & CStr(.Range(g_sTempLabelTempRow).Cells(1, iCounter + 3).Value)
                    Call CheckLabel( _
                          ByVal sFormatLabel _
                        , bLabelExists _
                    )
                    If bLabelExists = True Then
                        p_iLastRow = p_iLastRow - dLastDataRowCount
                        g_dCurrentPageDataHeight = g_dCurrentPageDataHeight - dLastDataRowHeight
                        Call copyTemplateRangeFormat(ActiveWorkbook.Sheets(g_sTemplateName).Range(sFormatLabel), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1))

                        Select Case sPrefix
                            Case g_daPrefix
                                p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataAlone).Rows.Count
                                g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataAlone).Height
                            Case g_dfPrefix
                                p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataFirst).Rows.Count
                                g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataFirst).Height
                            Case g_dPrefix
                                p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelData).Rows.Count
                                g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelData).Height
                            Case g_dlPrefix
                                p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataLast).Rows.Count
                                g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataLast).Height
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
                            If g_dPageHeaderHeight > 0 Then
                                ActiveWorkbook.Sheets(p_sSheetName).Rows(p_iLastRow).PageBreak = xlPageBreakManual
                            End If
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
                    End If
                Else
                    If bIsFirst = True Then
                        If EOF(1) Then
                            sPrefix = g_daPrefix
                        Else
                            sPrefix = g_dfPrefix
                        End If
                        bIsFirst = False
                    Else
                        If EOF(1) Then
                            sPrefix = g_dlPrefix
                        Else
                            sPrefix = g_dPrefix
                        End If
                    End If
                    For iCounter = 1 To g_iColumnAmount
                        sValue = CStr(.Range(g_sTempLabelTempRow).Cells(1, iCounter + 2).Value)
                        If sValue = "" Then
                            .Range(sPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value = ""
                        Else
                            If .Range(g_sTempLabelColumnType).Cells(1, iCounter).Value = "D" _
                            Or .Range(g_sTempLabelColumnType).Cells(1, iCounter).Value = "C" _
                            Then
                                If sValue = "?" Then
                                    .Range(sPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value = "?"
                                    .Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value = "?"
                                Else
'                                  debug.assert 0
                                    Call getDecimalFromString(sValue, dValue)
                                    .Range(sPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value = dValue
                                    If (Not IsNull(.Range(g_sTempLabelSubtotalMark).Cells(1, iCounter).Value) _
                                        And .Range(g_sTempLabelSubtotalMark).Cells(1, iCounter).Value <> "") _
                                    Or .Range(g_sTempLabelSubtotalPropisMark).Cells(1, iCounter).Value = "X" _
                                    And .Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value <> "?" _
                                    Then
                                        Select Case .Range(g_sTempLabelSubtotalMark).Cells(1, iCounter).Value
                                            Case "L"
                                                .Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value = dValue
    '                                               .Range(g_itPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value = .Range(g_sTemplateName & "_it_" & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value + dValue
                                            Case "C"
                                                .Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value = .Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value + 1
    '                                               .Range("g_itPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value = .Range(g_sTemplateName & "_it_" & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value + dValue
                                            Case "S"
                                                .Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value = .Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value + dValue
    '                                               .Range(g_itPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value = .Range(g_sTemplateName & "_it_" & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value + dValue
                                        End Select
                                    End If
                                End If
                            Else
                                ' .Range(sPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).NumberFormat = "Text"
                                .Range(sPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value = sValue
                                If (Not IsNull(.Range(g_sTempLabelSubtotalMark).Cells(1, iCounter).Value) _
                                    And .Range(g_sTempLabelSubtotalMark).Cells(1, iCounter).Value <> "") _
                                Or .Range(g_sTempLabelSubtotalPropisMark).Cells(1, iCounter).Value = "X" _
                                Then
                                    Select Case .Range(g_sTempLabelSubtotalMark).Cells(1, iCounter).Value
                                        Case "L"
                                            .Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value = CDbl(.Range(g_sTempLabelTempRow).Cells(1, iCounter + 1).Value)
    '                                           .Range(g_sTemplateName & "_it_" & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value = .Range(g_itPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value + CDbl(.Range(g_sTempLabelTempRow).Cells(1, iCounter + 1).Value)
                                        Case "C"
                                            .Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value = .Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value + 1
    '                                           .Range(g_itPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value = .Range(g_itPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value + CDbl(.Range(g_sTempLabelTempRow).Cells(1, iCounter + 1).Value)
                                        Case "S"
                                            .Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value = .Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value + CDbl(.Range(g_sTempLabelTempRow).Cells(1, iCounter + 1).Value)
    '                                           .Range(g_itPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value = .Range(g_itPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))).Value + CDbl(.Range(g_sTempLabelTempRow).Cells(1, iCounter + 1).Value)
                                    End Select
                                End If
                            End If
                        End If
                    Next iCounter
                    Select Case sPrefix
                        Case g_daPrefix
                            Call copyTemplateRange(ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataAlone), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
                            dLastDataRowCount = ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataAlone).Rows.Count
                            p_iLastRow = p_iLastRow + dLastDataRowCount
                            dLastDataRowHeight = ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataAlone).Height
                            g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + dLastDataRowHeight
                        Case g_dfPrefix
                            Call copyTemplateRange(ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataFirst), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
                            dLastDataRowCount = ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataFirst).Rows.Count
                            p_iLastRow = p_iLastRow + dLastDataRowCount
                            dLastDataRowHeight = ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataFirst).Height
                            g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + dLastDataRowHeight
                        Case g_dPrefix
                            Call copyTemplateRange(ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelData), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
                            dLastDataRowCount = ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelData).Rows.Count
                            p_iLastRow = p_iLastRow + dLastDataRowCount
                            dLastDataRowHeight = ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelData).Height
                            g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + dLastDataRowHeight
                        Case g_dlPrefix
                            Call copyTemplateRange(ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataLast), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
                            dLastDataRowCount = ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataLast).Rows.Count
                            p_iLastRow = p_iLastRow + dLastDataRowCount
                            dLastDataRowHeight = ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelDataLast).Height
                            g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + dLastDataRowHeight
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
                        If g_dPageHeaderHeight > 0 Then
                            ActiveWorkbook.Sheets(p_sSheetName).Rows(p_iLastRow).PageBreak = xlPageBreakManual
                        End If
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
                End If
            End If
        Loop
    End With
    Exit Sub
ErrorHandler:
    MsgBox Err.Description & ". Ошибка вывода строки на странице. Строка вывода: " & _
    CStr(iRowCounter) & ". Столбец: " & CStr(iCounter)
    Resume Next
End Sub

Sub printPageHeader( _
      ByVal p_sSheetName As String _
    , ByRef p_iLastRow As Long _
    , ByRef g_dCurrentPageDataHeight _
)
    If g_dPageHeaderHeight > 0 Then
        Call copyTemplateRange( _
              ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelPageHeader) _
            , ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1) _
            , True _
        )
        p_iLastRow = p_iLastRow + ActiveWorkbook.Sheets(g_sTemplateName).Range(g_sLabelPageHeader).Rows.Count
        g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + g_dPageHeaderHeight
    End If
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
    Dim iCounter As Long
    With ActiveWorkbook.Sheets(g_sTemplateName)
        For iCounter = 1 To g_iColumnAmount
            If Not IsNull(.Range(g_sTempLabelSubtotalMark).Cells(1, iCounter).Value) _
            And Not IsEmpty(.Range(g_sTempLabelSubtotalMark).Cells(1, iCounter).Value) _
            And .Range(g_sTempLabelSubtotalMark).Cells(1, iCounter).Value <> "" _
            Then
                sLabel = g_itpPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))
                Call CheckLabel( _
                      ByVal sLabel _
                    , bLabelExists _
                )
                If bLabelExists = True Then
                    .Range(sLabel).Value = .Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value
                End If
            End If
            If .Range(g_sTempLabelSubtotalPropisMark).Cells(1, iCounter).Value = "X" Then
                sLabel = g_itpsPrefix & Format(.Range(g_sTempLabelColumnList).Cells(1, iCounter))
                Call CheckLabel( _
                      ByVal sLabel _
                    , bLabelExists _
                )
                If bLabelExists = True Then
                    Select Case .Range(g_sTempLabelColumnType).Cells(1, iCounter).Value
                        Case "I"
                            .Range(sLabel).Value = LongToWords(CLng(.Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value), True)
                        Case "D"
                            .Range(sLabel).Value = DecimalToWords(CDbl(.Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value))
                        Case "C"
                            .Range(sLabel).Value = NumberToWordsRubl(CDbl(.Range(g_sTempLabelTempSubTotals).Cells(1, iCounter).Value))
                    End Select
                End If
            End If
        Next iCounter
        If p_bLastPage = False Then
            Call copyTemplateRange(.Range(g_sLabelPageSubTotal), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
            p_iLastRow = p_iLastRow + .Range(g_sLabelPageSubTotal).Rows.Count
            g_dCurrentPageDataHeight = g_dCurrentPageDataHeight + g_dPageSubTotalHeight
        Else
            Call copyTemplateRange(.Range(g_sLabelPageSubTotalLast), ActiveWorkbook.Sheets(p_sSheetName).Cells(p_iLastRow, 1), True)
            p_iLastRow = p_iLastRow + .Range(g_sLabelPageSubTotalLast).Rows.Count
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
Dim nmname As Name

    p_bExists = False
    For Each nmname In ActiveWorkbook.Names
        If Mid(nmname.RefersTo, 1, 5) <> "=#REF" _
        Then
            If nmname.RefersToRange.Worksheet.Name = g_sTemplateName _
            And (nmname.Name = p_sLabel Or (nmname.Name = g_sTemplateName & "!" & p_sLabel)) _
            Then
                p_bExists = True
                Exit For
            End If
        End If
    Next nmname
End Sub

Sub getPageHeight(ByVal p_sSheetName, ByRef p_dPageHeight As Double)
Dim i As Long
'Dim iPageCount As Long
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

Dim nmname As Name

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
    For Each nmname In ActiveWorkbook.Names
    If Mid(nmname.RefersTo, 1, 5) <> "=#REF" _
    Then
        If nmname.RefersToRange.Worksheet.Name = g_sTemplateName _
        Then
            Select Case UCase(nmname.Name)
                Case UCase(g_sLabelHeader)
                    g_dHeaderHeight = .Range(g_sLabelHeader).Height
                Case UCase(g_sLabelPageHeader)
                    g_dPageHeaderHeight = .Range(g_sLabelPageHeader).Height
                Case UCase(g_sLabelDataAlone)
                    g_dDataAloneHeight = .Range(g_sLabelDataAlone).Height
                Case UCase(g_sLabelDataFirst)
                    g_dDataFirstHeight = .Range(g_sLabelDataFirst).Height
                Case UCase(g_sLabelData)
                    g_dDataHeight = .Range(g_sLabelData).Height
                Case UCase(g_sLabelDataLast)
                    g_dDataLastHeight = .Range(g_sLabelDataLast).Height
                Case UCase(g_sLabelPageSubTotal)
                    g_dPageSubTotalHeight = .Range(g_sLabelPageSubTotal).Height
                Case UCase(g_sLabelPageSubTotalLast)
                    g_dPageSubTotalLastHeight = .Range(g_sLabelPageSubTotalLast).Height
                Case UCase(g_sLabelTotal)
                    g_dPageTotalHeight = .Range(g_sLabelTotal).Height
                Case UCase(g_sLabelFooter)
                    g_dFooterHeight = .Range(g_sLabelFooter).Height
            End Select
        End If
    End If
    Next nmname
End With

End Sub

Sub fillTemplateHeader(ByVal sFileName As String)
Dim iCounter As Long
Dim iSubtotalCounter As Long
Dim nmname As Name
Dim sLabel As String
Dim sValue As String
Dim sBuffer As String

On Error GoTo errorFillTemplateHeader

    g_sRegularExpressions = 0
    g_sHideColList = ""
    Open sFileName For Input As #1
    iCounter = 0
    g_sRegularExpressions = 0
    g_sHideColList = ""
    g_sValutCode = ""
    g_sColumnList = ""
    g_iColumnAmount = 0
    g_sColumnType = ""
    g_sSubtotalList = ""
    g_iSubtotalAmount = 0
    g_sSubtotalType = ""
    g_sSubtotalPropisList = ""
    g_iSubtotalPropisAmount = 0
    With ActiveWorkbook.Worksheets(g_sTemplateName)
        While Not EOF(1)
            iCounter = iCounter + 1
            Line Input #1, sBuffer
            sLabel = Mid(sBuffer, 1, InStr(sBuffer, Chr(9)) - 1)
            sValue = Mid(sBuffer, InStr(sBuffer, Chr(9)) + 1)
            Select Case sLabel
                Case "sheetList"
                    ' Ничего не делать, этот параметр уже обработан
                Case "sheetListcopyfrom"
                    ' Ничего не делать, этот параметр уже обработан
                Case g_sTemplateName & "_regularExpressions"
                    g_sRegularExpressions = CInt(sValue)
                Case g_sTemplateName & "_hideColList"
                    g_sHideColList = sValue
                Case g_sTemplateName & "_valutCode"
                    g_sValutCode = sValue
                Case g_sTempLabelColumnList
                    g_sColumnList = sValue
                    g_iColumnAmount = numEntries(sValue)
                Case g_sTempLabelColumnType
                    g_sColumnType = sValue
                Case g_sTempLabelSubtotalList
                    g_sSubtotalList = sValue
                    g_iSubtotalAmount = numEntries(sValue)
                Case g_sTempLabelSubtotalType
                    g_sSubtotalType = sValue
                Case g_sTempLabelSubtotalPropisList
                    g_sSubtotalPropisList = sValue
                    g_iSubtotalPropisAmount = numEntries(sValue)
                Case Else
                    If InStr(sLabel, "_regularExpressions") <> 0 _
                    Or InStr(sLabel, "_valutCode") <> 0 _
                    Or InStr(sLabel, "_columnList") <> 0 _
                    Or InStr(sLabel, "_columnType") <> 0 _
                    Or InStr(sLabel, "_subtotalList") <> 0 _
                    Or InStr(sLabel, "_subtotalType") <> 0 _
                    Or InStr(sLabel, "_subtotalPropisList") <> 0 _
                    Then
                        ' Служебная метка с другого листа: ничего не делать
                    Else

                        For Each nmname In ActiveWorkbook.Names
                        If Mid(nmname.RefersTo, 1, 5) <> "=#REF" _
                        Then
                            If nmname.RefersToRange.Worksheet.Name = g_sTemplateName _
                            And (nmname.Name = sLabel Or nmname.Name = g_sTemplateName & "!" & sLabel) _
                            And sValue <> "" _
                            Then
                                If g_sRegularExpressions = 1 Then
                                    sValue = Replace(sValue, "\n", Chr(10))
                                End If
                                .Range(sLabel).Cells(1, 1).Value = sValue
                            End If
                        End If
                        Next nmname
                    End If
            End Select
        Wend
        Close #1
        If g_sValutCode = "" Then
            MsgBox "Не задан код валюты"
            End
        End If
        If Not IsNumeric(g_sValutCode) Then
            MsgBox "Неверно задан код валюты:" & g_sValutCode
            End
        End If
        .Range(g_sTempLabelColumnList) = g_sColumnList
        If g_sColumnList <> "" Then
            .Range(g_sTempLabelColumnList).TextToColumns DataType:=xlDelimited, _
                ConsecutiveDelimiter:=False, Tab:=False, Comma:=True
        End If
        .Range(g_sTempLabelColumnType) = g_sColumnType
        If g_sColumnType <> "" Then
            .Range(g_sTempLabelColumnType).TextToColumns DataType:=xlDelimited, _
                ConsecutiveDelimiter:=False, Tab:=False, Comma:=True
        End If
        .Range(g_sTempLabelSubtotalList) = g_sSubtotalList
        If g_sSubtotalList <> "" Then
            .Range(g_sTempLabelSubtotalList).TextToColumns DataType:=xlDelimited, _
                ConsecutiveDelimiter:=False, Tab:=False, Comma:=True
        End If
        .Range(g_sTempLabelSubtotalType) = g_sSubtotalType
        If g_sSubtotalType <> "" Then
            .Range(g_sTempLabelSubtotalType).TextToColumns DataType:=xlDelimited, _
                ConsecutiveDelimiter:=False, Tab:=False, Comma:=True
        End If
        If g_sSubtotalPropisList <> "" Then
            .Range(g_sTempLabelSubtotalPropisList) = g_sSubtotalPropisList
            .Range(g_sTempLabelSubtotalPropisList).TextToColumns DataType:=xlDelimited, _
                ConsecutiveDelimiter:=False, Tab:=False, Comma:=True
        End If
        For iCounter = 1 To g_iColumnAmount
            For iSubtotalCounter = 1 To g_iSubtotalAmount
                If .Range(g_sTempLabelSubtotalList).Cells(1, iSubtotalCounter).Value = .Range(g_sTempLabelColumnList).Cells(1, iCounter).Value Then
                    .Range(g_sTempLabelSubtotalMark).Cells(1, iCounter).Value = .Range(g_sTempLabelSubtotalType).Cells(1, iSubtotalCounter).Value
                End If
            Next iSubtotalCounter
            If g_sSubtotalPropisList <> "" Then
                For iSubtotalCounter = 1 To g_iSubtotalPropisAmount
                    If .Range(g_sTempLabelSubtotalPropisList).Cells(1, iSubtotalCounter).Value = .Range(g_sTempLabelColumnList).Cells(1, iCounter).Value Then
                        .Range(g_sTempLabelSubtotalPropisMark).Cells(1, iCounter).Value = "X"
                    End If
                Next iSubtotalCounter
            End If
        Next iCounter
    End With
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
Dim iDelimPos As Long
Dim iMantissLength As Long
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

    sIntPartTrans = Trim(LongToWords(iIntPart, True))
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

Function LongToWords( _
      ByVal nNum As Long _
    , ByVal p_bMale _
) As String
Dim sStr As String
Dim s1 As String
Dim s2 As String
Dim ss As String
Dim sFin As String
Dim sThrees As String

Dim i As Long, n As Long, nLen As Long
Dim bMale As Boolean
    If nNum = 0 Then
        LongToWords = "Ноль "
        Exit Function
    End If
    sStr = Format(nNum, "###0")
    nLen = Len(sStr)
    If nLen > 12 Then
        GoTo errLongToWords
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
                GoTo errLongToWords
        End Select
        sFin = Get3ToWords(sThrees, 3, bMale) & " " & ss & " " & sFin
    Next i
ExFun:
    LongToWords = UCase(Mid(sFin, 1, 1)) & Mid(sFin, 2)

    Exit Function
errLongToWords:
    LongToWords = ""
    Exit Function
End Function

Sub getValutRubKop( _
      ByVal p_case As String _
    , ByRef p_sRub As String _
    , ByRef p_sKop As String _
)
Dim asRub(1 To 3, 0 To 2) As String
Dim asKop(1 To 3, 0 To 2) As String
Dim iRow As Long
Dim iCol As Long

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
Dim i As Long, n As Long, nLen As Long
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
    , ByVal nStart As Long _
    , ByVal bMale As Boolean _
) As String
Dim nLen As Long
Dim i, n As Long
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

Function GetStrFromDigit(ByVal aDigit As String, ByVal nMode As Long) As String

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
          ByVal g_sTempLabelColumnList _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = g_sTempLabelColumnList
    End If
    Call CheckLabel( _
          ByVal g_sTempLabelColumnType _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & g_sTempLabelColumnType
    End If
    Call CheckLabel( _
          ByVal g_sTempLabelSubtotalMark _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & g_sTempLabelSubtotalMark
    End If
    Call CheckLabel( _
          ByVal g_sTempLabelSubtotalPropisMark _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & g_sTempLabelSubtotalPropisMark
    End If
    Call CheckLabel( _
          ByVal g_sTempLabelSubtotalList _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & g_sTempLabelSubtotalList
    End If
    Call CheckLabel( _
          ByVal g_sTempLabelSubtotalType _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & g_sTempLabelSubtotalType
    End If
    Call CheckLabel( _
          ByVal g_sTempLabelSubtotalPropisList _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & g_sTempLabelSubtotalPropisList
    End If
    Call CheckLabel( _
          ByVal g_sTempLabelTempRow _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & g_sTempLabelTempRow
    End If
    Call CheckLabel( _
          ByVal g_sTempLabelTempSubTotals _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & g_sTempLabelTempSubTotals
    End If
    Call CheckLabel( _
          ByVal g_sTemplateName & "_tempStringSubTotals" _
        , bLabelExists _
    )
    If bLabelExists = False Then
        p_bExists = False
        p_sNoLabelList = p_sNoLabelList & IIf(p_sNoLabelList = "", "", " ,") & g_sTemplateName & "_tempStringSubTotals"
    End If
End Sub

Function numEntries( _
    p_sList As String _
) As Long
If p_sList = "" _
Then
    numEntries = 0
Else
    Dim sTemp() As String

    sTemp = Split(p_sList, ",")
    numEntries = UBound(sTemp) + 1
End If
End Function

Sub prob()
    Call startFormFromTemplate( _
          "d:\tmp\p79055xc.txt" _
        , "d:\tmp\p79008xd.txt" _
    )
End Sub

Sub ppp()
Dim sArray
Dim iArrayFieldAmount As Long
Dim iFieldCounter As Long
Dim iRowCounter As Long
Dim r1 As Range
Dim r2 As Range

Set r1 = Range("A8:D8")
Set r2 = Range("A13:D13")

' sArray = Split(Range("B8").Value, ",")
' iArrayFieldAmount = UBound(sArray) + 1

'    MsgBox Str(iArrayFieldAmount) + "  " + sArray(0)

'    For iFieldCounter = 1 To iArrayFieldAmount
'        sValue = sArray(iFieldCounter)
'    Next iFieldCounter

    r1.Copy r2
    For iFieldCounter = 1 To r1.Columns.Count
        sArray = Split(r1.Cells(1, iFieldCounter).Value, ",")
        iArrayFieldAmount = UBound(sArray) + 1
        For iRowCounter = 1 To iArrayFieldAmount
            r2.Cells(iRowCounter, iFieldCounter).Value = sArray(iRowCounter - 1)
        Next iRowCounter
    Next iFieldCounter
End Sub

Sub fitMergedHorizontal( _
      p_usedRange As Range _
    , p_workingCol As Long _
)
Dim dOldWidth As Double
Dim iCounter As Long
Dim iColCounter As Long
Dim dColWidth As Double
Dim dMaxHeight As Double
Dim sValue As String
Dim rRow As Range
Dim iShift As Long

    dOldWidth = Columns(p_workingCol).ColumnWidth
    For Each rRow In p_usedRange.Rows
        For iCounter = 1 To p_usedRange.Columns.Count
            With rRow.Worksheet.Cells(rRow.Row, iCounter)
                If .MergeCells = True _
                And .MergeArea.Rows.Count = 1 _
                And .MergeArea.Columns.Count > 1 _
                Then
                    iShift = .MergeArea.Columns.Count
                    sValue = .Value
                    dColWidth = 0
                    For iColCounter = 1 To .MergeArea.Columns.Count
                        dColWidth = dColWidth + .MergeArea.Columns(iColCounter).ColumnWidth
                    Next iColCounter
                    Columns(p_workingCol).ColumnWidth = dColWidth
                    dMaxHeight = Columns(p_workingCol).Cells(.Row, 1).EntireRow.RowHeight
                    Columns(p_workingCol).Cells(.Row, 1).Value = sValue
                    Columns(p_workingCol).Cells(.Row, 1).WrapText = True
                    Columns(p_workingCol).Cells(.Row, 1).EntireRow.AutoFit
                    If dMaxHeight < .EntireRow.RowHeight Then
                        Columns(p_workingCol).Cells(.Row, 1).EntireRow.RowHeight = .EntireRow.RowHeight
                    Else
                        Columns(p_workingCol).Cells(.Row, 1).EntireRow.RowHeight = dMaxHeight
                    End If
                    Columns(p_workingCol).Clear
                    Columns(p_workingCol).ColumnWidth = dOldWidth
                    iCounter = iCounter + iShift - 1
                End If
            End With
        Next iCounter
    Next rRow
End Sub

Sub hideColumns( _
    ByVal p_sSheetName _
)
Dim iCounter As Long
Dim iColumn As Long
Dim sTemp() As String
Dim sLabel As String
Dim bLabelExists As Boolean

    Debug.Assert (1)
    sTemp = Split(g_sHideColList, ",")
    With ActiveWorkbook.Worksheets(g_sTemplateName)
    For iCounter = 0 To UBound(sTemp)
        sLabel = g_sTemplateName & "_d_" & sTemp(iCounter)
        Call CheckLabel( _
              ByVal sLabel _
            , bLabelExists _
        )
        If bLabelExists Then
            iColumn = .Range(sLabel).Column
            ActiveWorkbook.Worksheets(p_sSheetName).Columns(iColumn).Hidden = True
        End If
    Next iCounter
    End With
End Sub
