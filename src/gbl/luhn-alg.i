/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/02/05
Author: Bakhtadze Natalya
Creation date: 02/02/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

 /*
'Copyright www.webbedwonder.com
Public Function CheckLuhn(ByVal lngCardNumber As String) As Boolean
'apply the Luhn algorithm
    Dim strCardNumber
    Dim I As Integer
    Dim intSumStep1Digits As Integer
    Dim intUnnafectedDigits As Integer
    Dim str1 As String
    Dim str2 As String
    Dim intChr As Integer
    Dim CardNumber As String
    Dim IntI As Integer
    Dim strChr As String
    Dim strOut As String
    Dim strTotal As String
    Dim Msg As String
On Local Error GoTo CheckLuhn_Err

    CheckLuhn = False

    If IsNull(lngCardNumber) Then Exit Function
    CardNumber = CStr(lngCardNumber) 'convert to string
    If Len(CardNumber) = 0 Then Exit Function
    CardNumber = Trim(CardNumber)

    strOut = RemoveWhiteSpace(lngCardNumber) 'fill a temp string to work on

    'step1
    intChr = 1
    For I = 1 To Len(strCardNumber) Step 2
        str1 = str1 & CStr(CInt(Mid(strCardNumber, intChr, 1) * 2))
     '   Debug.Print CStr(CInt(Mid(strCardNumber, intChr, 1) * 2))
        intChr = intChr + 2
    Next
    'Debug.Print str1

    intSumStep1Digits = 0
    intChr = 1
    For I = 1 To Len(str1)
        intSumStep1Digits = intSumStep1Digits + CInt(Mid(str1, intChr, 1))
     '   Debug.Print CInt(Mid(str1, intChr, 1))
        intChr = intChr + 1
    Next
    'Debug.Print intSumStep1Digits

    'step2
    intChr = 2
    For I = 2 To Len(strCardNumber) Step 2
        str2 = str2 & CStr(CInt(Mid(strCardNumber, intChr, 1)))
     '   Debug.Print CStr(CInt(Mid(strCardNumber, intChr, 1) * 2))
        intChr = intChr + 2
    Next
    'Debug.Print str2

    intUnnafectedDigits = 0
    intChr = 1
    For I = 1 To Len(str2)
        intUnnafectedDigits = intUnnafectedDigits + CInt(Mid(str2, intChr, 1))
     '   Debug.Print CInt(Mid(STR2, intChr, 1))
        intChr = intChr + 1
    Next
    'Debug.Print intUnnafectedDigits


    strTotal = CStr((intSumStep1Digits + intUnnafectedDigits))
    If Right(strTotal, 1) <> "0" Then
        CheckLuhn = False
    Else
        CheckLuhn = True
    End If

CheckLuhn_End:
   Exit Function

CheckLuhn_Err:
   Msg = "Error #: " & Format$(Err.Number) & vbCrLf
   Msg = Msg & Err.Description
   MsgBox Msg, vbInformation, "CheckLuhn"
   Resume CheckLuhn_End

End Function
*/

FUNCTION Luhn-algo returns integer(input p-str as character):
define variable v-length as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo . /*номер "двойки" чисел"*/
define variable v-c as character no-undo extent 10.  /*двойка чисел*/
define variable v-c-int-dop as integer no-undo extent 10.   /*интегер от второго числа в двойке умноженный на 2 */
define variable v-c-int-dop2 as integer no-undo extent 10. /*сумма разрядов v-c-int-dop */
define variable v-c-int as integer no-undo extent 10. /*сумма по двойке*/
define variable v-all as integer no-undo . /*общая сумма*/
define variable v-all-trunc-up as integer no-undo . /*ближайщее большее к v-all кратное 10*/
assign
v-length = length(p-str).
if v-length modulo 2 <> 0 then do:
  assign
  p-str = "0" + p-str
  .
end.
do v-ii = 0 to v-length by 2:
  assign
  v-jj = integer(v-ii / 2) + 1
  v-c[v-jj] = substring(p-str, v-ii + 1, 2)
  v-c-int-dop[v-jj] = integer(substring(v-c[v-jj], 2, 1)) * 2
  v-c-int-dop2[v-jj] = TRUNCATE(v-c-int-dop[v-jj] / 10, 0)  +  v-c-int-dop[v-jj] modulo 10
  v-c-int[v-jj] = integer(substring(v-c[v-jj], 1, 1)) + v-c-int-dop2[v-jj]
  v-all = v-all +  v-c-int[v-jj]
  .
end.
assign
v-all-trunc-up =  if v-all modulo 10 <> 0
                  then (TRUNCATE(v-all / 10, 0) * 10 + 10)
                  else v-all
.
return (v-all-trunc-up - v-all).
END FUNCTION.



/* $Workfile$ e n d */