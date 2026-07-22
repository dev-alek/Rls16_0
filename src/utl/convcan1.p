block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: convcan1.p $
$Archive: utl/convcan1.p $

NVB -ЭТО НЕ МОЙ ФАЙЛ И ЧТО ОН ДЕЛАЕТ Я НЕ ЗНАЮ!!!

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/


/* Конвертор данных




*/
define variable v-ind as integer no-undo .
define variable v-option as character no-undo .


define variable file-in as character no-undo .
define variable file-err as character no-undo .
define variable file-temp as character no-undo .
define variable file-out as character no-undo .

def stream txt-in.
def stream txt-err.
def stream txt-temp.

define variable text-string as character no-undo .
define variable i as int no-undo .

DEFINE var i-artic as char no-undo.
DEFINE var i-scale as char no-undo.
DEFINE var i-unit-name as char no-undo.
DEFINE var i-VAT-code AS integer NO-UNDO.
DEFINE var i-NP-code AS integer NO-UNDO.
DEFINE var i-prod-bc as char no-undo.
DEFINE var i-qnty AS dec NO-UNDO.
DEFINE var i-price AS dec NO-UNDO.



do
on error undo, leave
on stop undo, leave
on end-key undo, leave
:

  if num-entries(session :parameter) < 4 then do:
    message
      "Ошибка задания входных параметров" skip
      view-as alert-box .
    undo, leave .
  end.


  assign
     file-in = entry(1, session :parameter)
    file-err = entry(2, session :parameter)
    file-temp = entry(3, session :parameter)
    file-out = entry(4, session :parameter)
    i = 0
  .

   input stream txt-in from value (file-in).

   repeat:
        IMPORT stream txt-in UNFORMATTED text-string NO-ERROR.
        if trim(text-string) = "" then leave.

        if num-entries (text-string, ";") <> 11 then do:
            OUTPUT stream txt-Err TO value (file-err) append.
            put stream txt-Err "Неправильное число параметров в строке, должно быть 10, в конце строки должен стоять знак ;" skip.
            export stream  txt-Err text-string .
            output stream txt-Err close.
            next.
        end.  /*  if num-entries (text-string, ";") <> 11   */


     assign
            i-artic       = ENTRY( 1, text-string, ";")
            i-unit-name = ENTRY( 3, text-string, ";")
            i-vat-code    = integer(ENTRY(5, text-string, ";"))
            i-NP-code      = integer(ENTRY(6, text-string, ";"))
            i-prod-bc       = ENTRY(8, text-string, ";")
            i-qnty        = dec(ENTRY( 9, text-string, ";"))
            i-price       = dec(ENTRY( 10, text-string, ";"))
        .
        if  trim(i-artic) = "" then do:
            OUTPUT stream txt-Err TO value (file-err) append.
            put stream txt-Err "Не задан артикул" skip.
            export stream  txt-Err text-string .
            output stream txt-Err close.
            next.
        end.

        i-scale  = "/".
        overlay ( i-artic, r-index(i-artic, "-"), 1) = i-scale.
        i-scale = substring( i-artic, r-index(i-artic, "-") + 1 ).
        i-artic = substring( i-artic, 1, r-index(i-artic, "-") - 1 ).

        if  trim(i-scale) = "" then do:
            OUTPUT stream txt-Err TO value (file-err) append.
            put stream txt-Err "Не задана шкала" skip.
            export stream  txt-Err text-string .
            output stream txt-Err close.
            next.
        end.

        if i-unit-name = "th" then i-unit-name = "шт".
        else do:
            OUTPUT stream txt-Err TO value (file-err) append.
            put stream txt-Err "Неправильная единица измерения, должна бвть th" skip.
            export stream  txt-Err text-string .
            output stream txt-Err close.
            next.
        end.

        if  length(i-prod-bc) <> 13 then do:
            OUTPUT stream txt-Err TO value (file-err) append.
            put stream txt-Err "Доп-БК должен быть EAN13" skip.
            export stream  txt-Err text-string .
            output stream txt-Err close.
            next.
        end.

        if  i-qnty <= 0 or i-qnty =? then do:
            OUTPUT stream txt-Err TO value (file-err) append.
            put stream txt-Err "Не заданно количество" skip.
            export stream  txt-Err text-string .
            output stream txt-Err close.
            next.
        end.

        if  i-price <= 0 or i-price =? then do:
            OUTPUT stream txt-Err TO value (file-err) append.
            put stream txt-Err "Не заданно количество" skip.
            export stream  txt-Err text-string .
            output stream txt-Err close.
            next.
        end.
        if  i-vat-code =? then do:
            OUTPUT stream txt-Err TO value (file-err) append.
            put stream txt-Err "Не задан НДС" skip.
            export stream  txt-Err text-string .
            output stream txt-Err close.
            next.
        end.

        if  i-NP-code =? then do:
            OUTPUT stream txt-Err TO value (file-err) append.
            put stream txt-Err "Не задан НП" skip.
            export stream  txt-Err text-string .
            output stream txt-Err close.
            next.
        end.

       /*SCALE:31.001-AB;;101/0038;;5900142172632;3319;20;шт;1;;20;5;yes;ГТД*/
       OUTPUT stream txt-temp TO value (file-temp) append.
        put stream txt-temp  unformatted
                  "SCALE:" +
                  trim(i-artic) + ";;" +
                  trim(i-scale) + ";;" +
                  trim(i-prod-bc) + ";" +
                  trim(string(i-price)) + ";" +
                  trim(string(i-qnty)) + ";" +
                  trim(i-unit-name) + ";1;;" +
                  trim(string(i-vat-code)) + ";" +
                  trim(string(i-NP-code)) + ";yes;ГТД"
        skip.
        output stream txt-temp close.
        i = i + 1.

   end. /* repeat: */
   output stream txt-in  close.
   if i > 0 then do:
              os-copy value(file-temp) value(file-out).
   end.
end.

quit .