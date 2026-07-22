/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы списка чеков и чеков МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/20/05
Author: Bakhtadze Natalya
Creation date: 12/20/05

*/
/*

Параметры:

  {1} - имя таблицы.

  {2} -

        def      - если необходимо определение таблицы
        assign-trn   - поиск и присвоение полей таблицы - документы
        assign-price-doc   - поиск и присвоение полей таблицы - переоценки

  {3} - необязательный параметр если второй параметр- def
        параметры определения.
        если второй параметр assign... тогда
        имя таблицы источника

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" = "def" &then

define {3} temp-table {1} no-undo
field doc-code   like ub.chk-doc.doc-code
field obj-type   like ub.chk-doc.obj-type
field obj-code   like ub.chk-doc.obj-code
field out-code   like ub.chk-doc.out-code
field chk-date   like ub.chk-doc.chk-date
field chk-time   like ub.chk-doc.chk-time
field shift-date like ub.chk-doc.shift-date
field shift-num  like ub.chk-doc.shift-num
field shift-name  like ub.chk-doc.shift-name
field src-shift-date like ub.chk-doc.src-shift-date
field chk-num    like ub.chk-doc.chk-num
field pay-desk   like ub.chk-doc.pay-desk
field cashier    like ub.chk-doc.cashier
field cashier-psn-code    like ub.chk-doc.cashier-psn-code
field chk-type   like ub.chk-doc.chk-type
field d-card     like ub.chk-doc.d-card
field netto      like ub.chk-doc.netto
field discnt     like ub.chk-doc.discnt
field tot-doc    like ub.chk-doc.tot-doc
field is-wth     as logical
field sel-order  as integer
field znak       as integer
field to-del     as logical
field doc-num    as character label "№ док-та" format "X(22)"
field doc-num2   as character label "№ заказа" format "X(22)"
index xpk is primary unique doc-code is-wth
index znak-order znak sel-order .

/* история заполнения списка */
&if "{5}" <> "no-hist" &then
  &if "{3}" <> ' ' &then
  { cmp/listhist.i {1} "{3}" {5} }
  &else
  { cmp/listhist.i {1} {5} }
  &endif
&endif



&endif

&if "{2}" = "assign-chk" &then

find {1}
  where {1}.doc-code = {3}.doc-code
  no-error .
if available {1} then do:
  assign
    {1}.to-del = no /* ставим отметку, что запись нужна */
  .
end.
else do:
  create {1} .
  assign
  {1}.doc-code   = {3}.doc-code
  {1}.obj-type   = {3}.obj-type
  {1}.obj-code   = {3}.obj-code
  {1}.out-code   = {3}.out-code
  {1}.chk-date  = {3}.chk-date
  {1}.chk-time  = {3}.chk-time
  {1}.shift-date = {3}.shift-date
  {1}.shift-num  = {3}.shift-num
  {1}.src-shift-date = {3}.src-shift-date
  {1}.chk-num    = {3}.chk-num
  {1}.pay-desk   = {3}.pay-desk
  {1}.cashier    = {3}.cashier
  {1}.cashier-psn-code   = {3}.cashier-psn-code
  {1}.chk-type   = {3}.chk-type
  {1}.d-card     = {3}.d-card
  {1}.is-wth     = LOOKUP(string({3}.chk-type), {&wth-receipt-codes}) > 0
  {1}.doc-num    = {3}.doc-num
&if "{4}" <> "" &then
  {1}.sel-order  = {4}
&endif
&if "{3}" = "chk-doc" &then
  {1}.doc-num2   = {3}.doc-num2
&endif
  {1}.to-del = no
  .
  if {1}.is-wth = no then do:
    assign
    {1}.netto      = buffer {3}:handle:buffer-field("netto"):buffer-value
    {1}.tot-doc    = buffer {3}:handle:buffer-field("tot-doc"):buffer-value
    {1}.discnt     = buffer {3}:handle:buffer-field("discnt"):buffer-value
    no-error
    .
  end.
  else do:
    assign
    {1}.netto      = 0
    {1}.tot-doc    = 0
    {1}.discnt     = 0
    no-error
    .
  end.

  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid ({1})
  .
end.

&endif

/* $Workfile$ */