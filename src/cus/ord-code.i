/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Генерация номера для заказов

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 09/07/05
*/

/*
Номер документа создается как
  уникальный номер внутри базы данных
  знак минус
Для удаленных баз данных
  номер объекта
  вторая буква типа объекта


1 - режим генерации номера:
  main - для исходного документа
  main-no-ver  - без проверкой кода в базе данных
  chip         - щепка

2 db-num
3 obj-type
4 obj-code

5 - номер целевого документа
6 - номер исходного документа  (для режима chip)

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}" <> "def" &then
run proc-ord-code in this-procedure
 (input   {1} ,  /* p-type              */
  input   {2} ,  /* v-cntxt-db-num      */
  input   {3} ,  /* v-cntxt-obj-type    */
  input   {4} ,  /* v-cntxt-obj-code    */
  input   {5} ,  /* p-i-doc           */
  output  {6}    /* p-ord-doc             */
 ) .
&endif

&if "{1}" = "def" &then
procedure proc-ord-code :

define input  parameter  p-type as character no-undo .
define input  parameter  v-cntxt-db-num   as integer   no-undo .
define input  parameter  v-cntxt-obj-type as character no-undo .
define input  parameter  v-cntxt-obj-code as integer   no-undo .
define input  parameter  p-i-doc    as character no-undo .
define output parameter  p-ord-doc  as character no-undo .

define variable          v-idop     as character no-undo .

&scop first-part trim (string (next-value (s-ord-doc, {&db-name_schema}), ">>>>>>>>>9")) + "-"
&scop second-part + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1)

  do
  on error undo, return error return-value
  :

case p-type :
    when "main-no-ver" then do:
      if  (v-cntxt-db-num <> 0) then
        p-ord-doc = {&first-part} {&second-part}.
      else
        p-ord-doc = {&first-part}.
    end.

    when "main" then do:
          do while true:
          if  (v-cntxt-db-num <> 0) then
            p-ord-doc = {&first-part} {&second-part}.
          else
            p-ord-doc = {&first-part}.
          if not can-find (ub.ord-doc where ub.ord-doc.doc-code = p-ord-doc no-lock) then leave.
          End.
    end.


    when "chip" then do:
      /* для генерации номера используем доп. переменную, чтобы не пересчитывался индекс */
      assign
        v-idop = p-i-doc .
      do while true :
        if index (v-idop , ".") = 0 then
          v-idop  = replace (v-idop , "-", "-1.").
        else
          v-idop  =
          /* начало номера включая - */
          substring (v-idop , 1, index (v-idop, "-")) +
          /* только порядковый номер "щепки" + 1 */
          string (integer (substring (v-idop, index (v-idop, "-") + 1, index (v-idop, ".") - index (v-idop, "-") - 1)) + 1) +
          /* конец номера включая . */
          substring (v-idop, index (v-idop, ".")).
        if not can-find (ub.ord-doc where ub.ord-doc.doc-code = v-idop no-lock) then leave.
      end.
      assign
        p-ord-doc = v-idop.
    end.


end case.
  end.

end procedure. /* proc-ord-code */
&endif
/* $Workfile$ e n d */