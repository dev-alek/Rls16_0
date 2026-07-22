'$Revision: $
'$Author: $
'$Date: $
'$Workfile$
'$Archive$
'
'Макрос выгрузки из xls файла стоплиста
'
'Автор: Бахтадзе Наталья Викторовна
'Дата создания: 07/13/07
'Author: Bakhtadze Natalya
'Creation date: 07/13/07

Option Explicit

Attribute VB_Name = "Module1"

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

Sub Mainmacro(p_parameter As String)
Attribute StartApp.VB_ProcData.VB_Invoke_Func = " \n14"
Dim ii, jj, vNumLines, vNumColumns, closed, instoplist, clientcode, clientstoplist, ProductCode, vnumLines2 As Integer
Dim AccountType, DiscountClientCode, DiscountProductCode As Integer
Dim CreditDepth, Quota, DiscountValue As Double
Dim dcard, CarName, CarNumber, aa, FilenameShort As String
Dim filename, filename2 As Variant
Dim myWorkBook As Workbook
Dim ClientsSheet As Worksheet
Dim DiscountsSheet As Worksheet
Dim ccdiscount As Range
Dim firstAddress As String
Dim Shell As Object
Dim FolderItems, objFolderItem, fs As Object
Dim Savepath As String
Dim vDecimalSeparator,discountvaluechr as String


Set myWorkBook = Application.ActiveWorkbook
aa = Chr(34) & Chr(34)
ii = 1
Do While ii <= myWorkBook.Sheets.Count
   If myWorkBook.Sheets(ii).Name = "Clients" Then
      Set ClientsSheet = myWorkBook.Sheets(ii)

   End If
   If myWorkBook.Sheets(ii).Name = "Discounts" Then
      Set DiscountsSheet = myWorkBook.Sheets(ii)
   End If
   ii = ii + 1
Loop
If IsEmpty(ClientsSheet) Then
   MsgBox "Не найден лист " & "Clients"
   Exit Sub
End If
If IsEmpty(DiscountsSheet) Then
   MsgBox "Не найден лист " & "DIscounts"
   Exit Sub
End If

vNumColumns = DiscountsSheet.Range("A1").SpecialCells(xlLastCell).Column
If vNumColumns <> 5 Then
  MsgBox "Неверное количество колонок в листе " & DiscountsSheet.Name & CStr(vNumColumns) & " Ожидалось 5"
  Exit Sub
End If
If DiscountsSheet.Cells(1, 1) <> "ClientCode" Then
  MsgBox "Неверное название колонки 1 " & DiscountsSheet.Cells(1, 1).Value & "Ожидалось ClientCode"
  Exit Sub
End If
If DiscountsSheet.Cells(1, 3) <> "ProductCode" Then
  MsgBox "Неверное название колонки 3 " & DiscountsSheet.Cells(1, 3).Value & "Ожидалось ProductCode"
  Exit Sub
End If
If DiscountsSheet.Cells(1, 5) <> "Discount" Then
  MsgBox "Неверное название колонки 5 " & DiscountsSheet.Cells(1, 4).Value & "Ожидалось Discount"
  Exit Sub
End If
vNumColumns = ClientsSheet.Range("A1").SpecialCells(xlLastCell).Column
If vNumColumns <> 16 Then
  MsgBox "Неверное количество колонок в листе " & ClientsSheet.Name & CStr(vNumColumns) & " Ожидалось 16"
  Exit Sub
End If
If ClientsSheet.Cells(1, 1) <> "AccountNumber" Then
  MsgBox "Неверное название колонки 1 " & ClientsSheet.Cells(1, 1).Value & "Ожидалось Account"
  Exit Sub
End If
If ClientsSheet.Cells(1, 3) <> "AccountType" Then
  MsgBox "Неверное название колонки 3 " & ClientsSheet.Cells(1, 4).Value & "Ожидалось AccountType"
  Exit Sub
End If
If ClientsSheet.Cells(1, 5) <> "ProductCode" Then
  MsgBox "Неверное название колонки 5 " & ClientsSheet.Cells(1, 5).Value & "Ожидалось ProductCode"
  Exit Sub
End If
If ClientsSheet.Cells(1, 7) <> "AdditionQuantity" Then
  MsgBox "Неверное название колонки 7 " & ClientsSheet.Cells(1, 7).Value & "Ожидалось AdditionQuantity"
  Exit Sub
End If
If ClientsSheet.Cells(1, 8) <> "CarName" Then
  MsgBox "Неверное название колонки 8 " & ClientsSheet.Cells(1, 8).Value & "Ожидалось CarName"
  Exit Sub
End If
If ClientsSheet.Cells(1, 9) <> "CarNumber" Then
  MsgBox "Неверное название колонки 9 " & ClientsSheet.Cells(1, 9).Value & "Ожидалось CarNumber"
  Exit Sub
End If
If ClientsSheet.Cells(1, 10) <> "Closed" Then
  MsgBox "Неверное название колонки 10 " & ClientsSheet.Cells(1, 10).Value & "Ожидалось Closed"
  Exit Sub
End If
If ClientsSheet.Cells(1, 11) <> "InStopList" Then
  MsgBox "Неверное название колонки 11 " & ClientsSheet.Cells(1, 11).Value & "Ожидалось InStopList"
  Exit Sub
End If
If ClientsSheet.Cells(1, 12) <> "ClientCode" Then
  MsgBox "Неверное название колонки 12 " & ClientsSheet.Cells(1, 12).Value & "Ожидалось ClientCode"
  Exit Sub
End If
If ClientsSheet.Cells(1, 14) <> "CreditDepth" Then
  MsgBox "Неверное название колонки 14 " & ClientsSheet.Cells(1, 14).Value & "Ожидалось CreditDepth"
  Exit Sub
End If
If ClientsSheet.Cells(1, 16) <> "ClientInStopList" Then
  MsgBox "Неверное название колонки 16 " & ClientsSheet.Cells(1, 16).Value & "Ожидалось ClientInStopList"
  Exit Sub
End If
vNumLines = ClientsSheet.Range("A1").SpecialCells(xlLastCell).Row
vnumLines2 = DiscountsSheet.Range("A1").SpecialCells(xlLastCell).Row

filename = w_entry(P_Parameter,  1, ",")
filename2 = w_entry(P_Parameter,  2, ",")

vDecimalSeparator = Application.International(xlDecimalSeparator)

ii = 0
Do While jj < 2
    ii = 1
    If jj = 1 Then
      Open filename For Output As #1
    End If

    Do While ii <= vNumLines
      ii = ii + 1
      dcard = Chr(34) & String(9 - Len(ClientsSheet.Cells(ii, 1).Value), "0") & ClientsSheet.Cells(ii, 1).Value & Chr(34)
      Quota = ClientsSheet.Cells(ii, 7).Value
      CarName = Chr(34) & Replace(ClientsSheet.Cells(ii, 8).Value, Chr(34), aa) & Chr(34)
      CarNumber = Chr(34) & ClientsSheet.Cells(ii, 9).Value & Chr(34)
      On Error GoTo ErrorHandler
      ProductCode = CInt(ClientsSheet.Cells(ii, 5).Value)
      closed = CInt(ClientsSheet.Cells(ii, 10).Value)
      instoplist = CInt(ClientsSheet.Cells(ii, 11).Value)
      clientcode = CInt(ClientsSheet.Cells(ii, 12).Value)
      CreditDepth = CDbl(ClientsSheet.Cells(ii, 14).Value)
      clientstoplist = CInt(ClientsSheet.Cells(ii, 16).Value)
      AccountType = CInt(ClientsSheet.Cells(ii, 3).Value)

      If jj = 1 Then
        Print #1, dcard; Space(1); ProductCode; Space(1); Quota; Space(1); CarName; Space(1); CarNumber; Space(1); closed; Space(1); instoplist; Space(1); clientcode; Space(1); CreditDepth; Space(1); clientstoplist; Space(1); AccountType
      End If
    Loop
    jj = jj + 1
Loop
Close #1

ii = 0
jj = 0
Do While jj < 2
    ii = 1
    If jj = 1 Then
      Open filename2 For Output As #1
    End If

    Do While ii <= vnumLines2
      ii = ii + 1
      dcard = Chr(34) & String(9 - Len(ClientsSheet.Cells(ii, 1).Value), "0") & ClientsSheet.Cells(ii, 1).Value & Chr(34)
      Quota = ClientsSheet.Cells(ii, 7).Value
      CarName = Chr(34) & Replace(ClientsSheet.Cells(ii, 8).Value, Chr(34), aa) & Chr(34)
      CarNumber = Chr(34) & ClientsSheet.Cells(ii, 9).Value & Chr(34)
      On Error GoTo ErrorHandler
      DiscountClientCode = CInt(DiscountsSheet.Cells(ii, 1).Value)
      DiscountProductCode = CInt(DiscountsSheet.Cells(ii, 3).Value)
      DiscountValue = CDbl(DiscountsSheet.Cells(ii, 5).Value)
      if vDecimalSeparator = "." then
      discountvaluechr = cstr(discountvalue)
      else
      discountvaluechr = CStr(Fix(discountvalue)) & "." & Mid(CStr(discountvalue - Fix(discountvalue)), 3)
      Endif


      If jj = 1 Then
        Print #1, DiscountClientCode; Space(1); DiscountProductCode; Space(1); DiscountValuechr
      End If
    Loop
    jj = jj + 1
Loop
Close #1

'MsgBox "Сохранено в " & filename & " и " & filename2
Exit Sub
ErrorHandler:    ' Error-handling routine.
    Select Case Err.Number    ' Evaluate error number.
        Case 13
           MsgBox "Неверное значение в ячейке листа" & ClientsSheet.Name & ClientsSheet.Cells.Row & ";" & ClientsSheet.Cells.Column & " Экспорт прерван"
           Exit Sub
        Case Else
            ' Handle other situations here...
    End Select
    Resume    ' Resume execution at same line
                ' that caused the error.

End Sub