/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение и заполнение списка товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/31/05
Author: Bakhtadze Natalya
Creation date: 10/31/05


Параметры:

  {1} - имя таблицы.

  {2} - def      - если необходимо определение таблицы
                   с индексами: art  (artic, prod-type, prod-code)
                                code (gds-code)
        assign   - поиск и присвоение полей таблицы

  {3} - необязательный параметр
        параметры определения.
  {4} - buffer goods

  {5} - параметр отмены таблицы истории заполнения списка
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if "{4}" = "" &then
  &scop buffer-goods goods
&else
  &scop buffer-goods {4}
&endif


&if "{2}" = "def" &then

&if defined(gds-list_i_def) = 0 &then

&glob gds-list_i_def


define {3} temp-table {1} no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .

 /* история заполнения списка */
  &if "{5}" <> "no-hist" &then
    &if "{3}" <> ' ' &then
    { cmp/listhist.i {1} "{3}" {5} }
    &else
    { cmp/listhist.i {1} {5} }
    &endif
  &endif

&endif

&elseif  "{2}" = "method"
&then
{ cmp/listhist.i {1} {2} }
method public void empty-{1} ():
   for each {1} :
      delete {1}.
   end.
end.
method public void get-glob-{1} ():
end.
method public void set-glob-{1} ():
end.
method public void get-{1} (output table {1}):
end.
method public void set-{1} (input table {1}):
   define variable ddd as integer no-undo.
   ddd = 1.
end.
method public int get-{1}-count ():
   define variable vcount as integer no-undo.
   for each {1} :
      vcount = vcount + 1 .
   end.
   return vcount. 
end.

method public character  get-{1}-one ():
   define variable vcount as integer no-undo.
   define buffer Buf_{1} for {1}.
   find first {1} no-error.
   for each Buf_{1} where recid(Buf_{1}) ne recid({1}) :
      delete Buf_{1}.
   end.
   return if available {1} then {1}.gds-name else ? . 
end.
method public character  create-{1} (iri-list as character ):
   define buffer buf_goods for goods.
   for each gds-list :
      delete gds-list.
   end.
   if iri-list <> "" 
   then do:
      find first buf_goods where recid(buf_goods) = integer (iri-list) no-lock.
      buffer-copy buf_goods to gds-list no-error.
   end.
end.
&else
find {1}
  where {1}.prod-type = {&buffer-goods}.prod-type
    and {1}.prod-code = {&buffer-goods}.prod-code
    and {1}.artic     = {&buffer-goods}.artic
  no-error .
if available {1} then do:
  assign
    {1}.to-del = no /* ставим отметку, что запись нужна */
  .
end.
else do:
  define variable v-last{&vssseq} as integer no-undo .
  find last {1} use-index oi no-error.
  if available {1} then do:
    v-last{&vssseq} = {1}.order-num .
  end.
  else do:
    v-last{&vssseq} = 0 .
  end.
  create {1} .
  buffer-copy {&buffer-goods} to {1}
  assign
    {1}.to-del = no
    {1}.order-num = v-last{&vssseq} + 1
  .
  &if "{1}" = "gds-list" or "{1}" = "scn-list" or "{1}" = "gds-list-flt" &then
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid ({1})
  .
  &endif
end.

/*endif else*/
&endif

/* $Workfile$ e n d */