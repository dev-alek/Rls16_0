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
' v_ci - цвет
Dim Header_Rows As Integer
Dim Header_rowsv as Variant
Dim ii  As Integer
' ii текущая строка
' i-entry - текущий entry для разбора строки параметров
Header_rowsv = w_entry(vParameters, 1, vDelimiter)
if Header_rowsv = 0 then
  msgbox "0"
  exit Sub
end if
Header_rows = cint(Header_rowsv)
ii = Header_ROws
Do While ii < ActiveSheet.Cells.SpecialCells(xlLastCell).Row
  if cells(ii, 18).value = "gds" then
    call ColorRow(ii)   ' gds-code
    gds_code = cells(ii, 3).value
    if cells(ii, 2).value = 0 then
      call ColorCell(ii, 2)   ' gds-code
    end if
    if cells(ii, 3).value = 0 then
      call ColorCell(ii, 3)   ' gds-code
    end if
    if cells(ii, 4).value <> cells(ii, 5).value then
      call ColorCell(ii, 5)  ' artic
    end if
    if cells(ii, 8).value <> cells(ii, 9).value then
      call ColorCell(ii, 9)  ' gds-name
    end if
    if cells(ii, 10).value <> cells(ii, 11).value then
      call ColorCell(ii, 11)  ' unit-base
    end if
    if cells(ii, 12).value <> cells(ii, 13).value then
      call ColorCell(ii, 13)  ' stts
    end if
    if cells(ii, 14).value <> cells(ii, 15).value then
      call ColorCell(ii, 15)  ' grp
    end if
    if cells(ii, 16).value <> cells(ii, 17).value then
      call ColorCell(ii, 17)  ' prod-name
    end if
  end if
  if cells(ii, 18).value = "pbc" then
    if cells(ii, 3).value <> gds_code then
      call ColorCell(ii, 3)   ' gds-code
    end if
  end if
  ii = ii + 1
Loop
End Sub

Sub ColorCell(ii as Integer, jj as integer)
 DIm ObjectRange as Range
   Set ObjectRange =  Range(Cells(ii, jj), Cells(ii,jj ))
   With ObjectRange.Interior
                   .ColorIndex = 3
   End With
end Sub

Sub ColorRow(ii as Integer)
 DIm ObjectRange as Range
   Set ObjectRange =  Range(Cells(ii, 1), Cells(ii,50 ))
   With ObjectRange.Interior
                   .ColorIndex = 37
   End With
end Sub

