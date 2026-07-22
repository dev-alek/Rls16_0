/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: frmlib.i $
$Archive: rep/frmlib.i $

Функция разбивает строку по пробелам на num-line НЕРАВНЫХ частей, которые задаются списком чисел с разделителем {&comma-char}

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/20/03
Author: Bakhtadze Natalya
Creation date: 11/20/03

возвращает тоже список строк с разделителем {&delim-par}

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: frmlib.i $ $Revision: aea5316774be, 0, rls $".

FUNCTION Break-n-line RETURNS CHARACTER
  ( INPUT p-ost as char,
    INPUT p-lengths  as character,
    OUTPUT output-num-lines as integer
    ) :
define variable ii as integer no-undo.
define variable jj as integer no-undo.
define variable linei as character no-undo extent 10.
define variable line-length as integer no-undo extent 10.
define variable num-line as integer no-undo .
define variable v-line as character no-undo .
do ii = 1 to MIN(num-entries(p-lengths), 10):
  assign
  line-length[ii] = integer(entry(ii, p-lengths))
  num-line = ii
  .
end.
do jj = 1 to num-line:
  if Length ( p-ost ) <= line-length[jj] then do:
    assign
    output-num-lines = jj
    v-line = v-line + (if jj = 1 then "":U else {&delim-par}) + p-ost
    .
    return v-line.
  end.
  assign
  ii = 1
  .
  if length( entry( ii, p-ost , {&space-char}) ) > line-length[jj]
  then do:
    assign
    linei[jj] = substr( p-ost , 1 , line-length[jj] )
    p-ost = trim( substr( p-ost , line-length[jj] + 1 ) )
    .
  end.
  else do:
    DO WHILE length( linei[jj] + entry( ii, p-ost , {&space-char}) ) < ( line-length[jj] + 1 ) :
      assign
      linei[jj] = linei[jj] + entry( ii, p-ost , {&space-char}) + {&space-char}
      ii = ii + 1
      .
      if length( entry( ii, p-ost, {&space-char} ) ) > line-length[jj] then
      assign
      linei[jj] = linei[jj] + substr( p-ost , length( linei[jj] ) , line-length[jj] - length( linei[jj] ) + 1 )
      .
    END.
    assign
    p-ost = trim( substr( p-ost , length(linei[jj]) + 1  ))
    .
  end.
  assign
  v-line = v-line + (if jj = 1 then "":U else {&delim-par}) + linei[jj]
  .
  if p-ost = "":U then LEAVE.
end.
assign
output-num-lines = jj.

RETURN v-line.   /* Function return value. */

END FUNCTION.


/*центрирует поле обрезая его сначала до v-format символов*/
FUNCTION Center-Field RETURNS CHARACTER
  ( INPUT p-str as char,
    INPUT p-format as integer,
    INPUT p-Length as integer,
    INPUT p-fill as character
    ) :
define variable v-str as character no-undo .
define variable v-left as integer no-undo .
define variable v-dop as integer no-undo .
assign
p-str = trim(p-str)
.
if p-str = "":U then return fill(p-fill, p-length).
if length(p-str) >= p-format then
p-str = substr(p-str, 1, p-format).
else do:
  p-format = length(p-str).
end.

if p-format < p-length then do:
  assign
  v-left = (p-length - p-format )
  v-dop = (if v-left modulo 2 = 1
           then 1
           else 0)
  v-left = (if (v-left modulo 2 = 1)
           then (v-left - 1 ) / 2
           else v-left / 2)
  v-str =  fill(p-fill, v-left) +
           string(p-str, "X(":U + string(p-format) + ")":U) +
           fill(p-fill, v-left) + fill(p-fill, v-dop)

  .
  return v-str.
end.
else do:
  return string(p-str, "X(":U + string(p-length) + ")":U).

end.
END FUNCTION.

/*выравнивает поле слева обрезая его до v-format символов*/
FUNCTION Left-Field RETURNS CHARACTER
  ( INPUT p-str as char,
    INPUT p-format as integer,
    INPUT p-Length as integer,
    INPUT p-fill as character
    ) :
define variable v-str as character no-undo .
define variable v-left as integer no-undo .
define variable v-dop as integer no-undo .
assign
p-str = trim(p-str)
.
if p-str = "":U then return fill(p-fill, p-length).
if length(p-str) >= p-format then
p-str = substr(p-str, 1, p-format).
else do:
  p-format = length(p-str).
end.

if p-format < p-length then do:
  assign
  v-dop =  p-length - p-format
  v-str =  string(p-str, "X(":U + string(p-format) + ")":U) +
           fill(p-fill, v-dop)

  .
  return v-str.
end.
else do:
  return string(p-str, "X(":U + string(p-length) + ")":U).

end.
END FUNCTION.



/*возвращает строчку суммы в р_у_блях и к_о_пейка типа ________ {&abbr_rub}. __________ {&abbr_kop}.*/
FUNCTION Sum-Rub-Kop-Digit RETURNS CHARACTER
  ( INPUT p-sum as decimal,
    INPUT p-rub-length as integer, /*количество символов для р_у_блей не считая надписи р_у_б и пробела*/
    INPUT p-kop-length as integer, /*количество символов для к_о_п не считая надписи р_у_б и пробела*/
    INPUT p-fill as character, /*заполнитель _ или space-char или "0":U*/
    INPUT p-razr-delim as character, /*разделитель разрядов*/
    INPUT p-rub-str  as character,
    INPUT p-kop-str  as character
    ) :
define variable v-str as character no-undo .
define variable v-format as character no-undo .
define variable v-dopi as integer no-undo .
define variable v-dopi2 as integer no-undo .
assign
v-dopi = length(string(truncate(ABS(p-sum), 0)))
v-dopi2 = truncate(v-dopi / 3, 0) - (if v-dopi modulo  3 = 0 then 1 else 0)
.
if v-dopi > p-rub-length or p-kop-length < 2 then return "?".

assign
v-format = (if p-sum < 0 then "-":U else "":U) + fill((">>>":U + p-razr-delim), v-dopi2) + ">>9":U
v-dopi = length(trim(string(truncate(p-sum, 0), v-format)))
.
assign
v-str = fill(p-fill, p-rub-length - v-dopi) +
        string(truncate(p-sum, 0), v-format) +
        p-rub-str +
        fill(p-fill, p-kop-length - 2) +
        string(truncate((ABS(p-sum) - ABS(truncate(p-sum, 0))), 2) * 100, "99":U) + p-kop-str
.

return v-str.
END FUNCTION.


/*возвращает строчку суммы в валюте типа (доллары США) xxxxx.xx.*/
FUNCTION Sum-Invalut-Digit RETURNS CHARACTER
  ( INPUT p-sum as decimal,
    INPUT p-sum-length as integer, /*количество символов для надписи всего*/
    INPUT p-curr-code as integer, /*код валюты*/
    INPUT p-fill as character, /*заполнитель _ или space-char или "0":U*/
    INPUT p-razr-delim as character /*разделитель разрядов*/
    ) :
define variable v-str as character no-undo .
define variable v-format as character no-undo .
define variable v-dopi as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-curr-name as character no-undo .
define buffer buf_currency for ub.currency.
find first buf_currency no-lock where
          buf_currency.curr-code = p-curr-code no-error .
if not avail buf_currency
then v-curr-name = "неизвестная валюта".
else
assign
v-curr-name = buf_currency.curr-name
.
assign
v-dopi = length(string(truncate(ABS(p-sum), 0)))
v-dopi2 = truncate(v-dopi / 3, 0) - (if v-dopi modulo  3 = 0 then 1 else 0)
.
if v-dopi > p-sum-length then return "?".

assign
v-format = (if p-sum < 0 then "-":U else "":U) + fill((">>>":U + p-razr-delim), v-dopi2) + ">>9.99":U
v-dopi = length(trim(string(p-sum, v-format)))
.
assign
v-str = "(":U + {&space-char} + v-curr-name +  {&space-char} + ")":U +
        fill(p-fill, p-sum-length - v-dopi - length(v-curr-name) - 4)  +
        trim(string(p-sum, v-format))
.

return v-str.
END FUNCTION.



/*положительная сумма прописью без десятичной части*/
FUNCTION Sum-in-Words-Without-Dec RETURNS CHARACTER
(input v-sum as decimal
):

define variable v-str as character no-undo .
run gbl/num-rus.p ( input absolute( v-sum ) , output v-str).
v-str = trim( caps( substring( v-str, 1, 1 ) ) ) + substring( v-str, 2 ).
return v-str.
END FUNCTION.

/*положительная сумма прописью c десятичной частью и названием валюты типа сто двадцать долларов США 85 центови*/
FUNCTION Sum-in-Words-Invalut RETURNS CHARACTER
(input p-sum as decimal
 ,input p-curr-code as integer
):

define variable v-str as character no-undo .
define variable Copeck as character no-undo.
define variable Rouble as character no-undo.

define variable v-Word as character no-undo.
define variable ii as integer init 18 no-undo.
define variable v-str-rubl as character no-undo .
define variable v-kop as integer no-undo .

define buffer buf_currency for ub.currency.
assign
v-Word = string( absolute( p-sum ) , "999999999999999.99" ).
find first buf_currency no-lock where
          buf_currency.curr-code = p-curr-code no-error .
if not available buf_currency then return {&question-mark}.
if decimal( substring(v-Word,1,ii - 3) ) <> 0 then do:
  CASE substring(v-Word, ii - 3,1):
    WHEN "1" THEN DO:
      if substring(v-Word, ii - 4,1) = "1" then
          Rouble = buf_currency.curr-name-five .
      else
          Rouble = buf_currency.curr-name-one .
    END.
    WHEN "2" OR WHEN "3" OR WHEN "4" THEN  DO:
      if substring(v-Word, ii - 4,1) = "1" then
         Rouble = buf_currency.curr-name-five .
         else
         Rouble = buf_currency.curr-name-three .
      END.
    WHEN "0" OR WHEN "5" OR WHEN "6" OR WHEN "7" OR WHEN "8" OR WHEN "9" THEN  DO:
       Rouble = buf_currency.curr-name-five .
    END.
  END CASE.
end.
CASE substring(v-Word, ii, 1):
  WHEN "1" THEN DO:
    if substring(v-Word, ii - 1, 1) = "1" then
        Copeck = buf_currency.part-name-five .
    else
        Copeck = buf_currency.part-name-one .
  END.
  WHEN "2" OR WHEN "3" OR WHEN "4" THEN DO:
    if substring(v-Word, ii - 1, 1) = "1" then
        Copeck = buf_currency.part-name-five .
    else
        Copeck = buf_currency.part-name-three .
  END.
  WHEN "0" OR WHEN "5" OR WHEN "6" OR WHEN "7" OR WHEN "8" OR WHEN "9" THEN DO:
    Copeck = buf_currency.part-name-five .
  END.
END CASE.
run gbl/num-rus.p ( input absolute( p-sum )
             , output v-str-rubl).
assign
v-kop = (absolute( p-sum ) - truncate(absolute(p-sum), 0)
        ) * 100
.

v-str = ( if p-Sum < 0 then "- " else "" ) +
            caps(substring(v-str-rubl, 1, 1)) +  substring(v-str-rubl, 2) + {&space-char} + Rouble + {&space-char} +
            string(v-kop, "99":U) + {&space-char} + Copeck .
return v-str.
END FUNCTION.



FUNCTION Sum-delim-with-defis RETURNS CHARACTER
(input v-sum as decimal,
input v-razr as integer
):

define variable v-str as character no-undo .
define variable v-dec-separ as character no-undo .
case SESSION:NUMERIC-FORMAT:
  when "American":U then do:
    assign
    v-dec-separ = ".":U
    .
  end.
  when "European":U then do:
    assign
    v-dec-separ = ",":U
    .
  end.
END CASE.

assign
v-str = replace(string(v-sum, fill(">":U, v-razr - 1) + "9.99"), v-dec-separ, "-":U)
.

return v-str.
END FUNCTION.

FUNCTION MonthNameRusGen RETURNS CHARACTER ( INPUT i-month AS INTEGER ) :
  DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.

  RUN get-month-name-gen IN THIS-PROCEDURE ( INPUT i-month, OUTPUT v-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-name ).
END FUNCTION. /* MonthNameRusGen */

PROCEDURE get-month-name-gen :
  DEFINE  INPUT PARAMETER p-month AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name  AS CHARACTER NO-UNDO.

  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO INITIAL "Января,Февраля,Марта,Апреля,Мая,Июня,Июля,Августа,Сентября,Октября,Ноября,Декабря".

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-name = ( IF p-month >= 1 AND p-month <= 12 THEN ENTRY( p-month, v-list ) ELSE ? ).
  END. /* ON ERROR */
END PROCEDURE. /* get-month-name-gen */



/* $Workfile: frmlib.i $ e n d */