/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/09/05
Author: Bakhtadze Natalya
Creation date: 02/09/05

Определение и заполнение списка разнообразнейших кодов

Параметры:

  {1} - имя таблицы.

  {2} - def      - если необходимо определение таблицы
                   с индексами: art  (artic, prod-type, prod-code)
                                code (gds-code)
        assign   - поиск и присвоение полей таблицы

  {3} - необязательный параметр
        параметры определения.
        если {2} def то это new shared или shared или ""
        если {2} assign то это буффер для bar-code


  {4} - имя таблицы содержащей goods.gds-code

  для def
  {4} - параметр отмены таблицы истории заполнения списка


  {5} - имя таблицы содержащей bar-code.b-code
  {6} - "":U для бар-кодов или b-str для ДопБК


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if "{2}" = "def" &then
def {3} temp-table {1} no-undo like ub.goods
  field b-code as integer
  field b-str  as character
  field f-name like ub.gds-prt.f-name
  field bc-cli-base-rate like ub.bar-code.cli-base-rate
  field bc-cr-db-num     like ub.bar-code.cr-db-num
  field in-code       like ub.bar-code.in-code
  field node-code     like ub.bar-code.node-code
  field part-code     like ub.bar-code.part-code
  field stts_         like ub.bar-code.stts_
  field bc-unit-cli      like ub.bar-code.unit-cli
  field bc-on-type    like ub.prod-bc.bc-on-type
  field bc-on         like ub.prod-bc.bc-on
  field pbc-cr-db-num     like ub.prod-bc.cr-db-num
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field loc-ean as logical
  index pi  is primary unique b-code b-str
  index art artic prod-type prod-code
  index code gds-code
  index oi order-num
  index ibc-on-type bc-on-type
  index iprt
  gds-code
  node-code
  part-code
  in-code
  unit-cli
  b-str
  index iprt2
  gds-code
  node-code
  unit-cli
  part-code
  in-code
  b-str
  .
  /* история заполнения списка */
  &if "{4}" <> "no-hist" &then
    &if "{3}" <> ' ' &then
    { cmp/listhist.i {1} "{3}" {4} }
    &else
    { cmp/listhist.i {1} {4} }
    &endif
  &endif

&else
find first {1}
  where {1}.gds-code = {4}.gds-code
    and {1}.b-code   = {4}.b-code
    and {1}.b-str    = {6}
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
  buffer-copy {3} to {1}
  assign
    {1}.to-del = no
    {1}.order-num = v-last{&vssseq} + 1
    {1}.b-code = {4}.b-code
    {1}.bc-cli-base-rate = {4}.cli-base-rate
    {1}.bc-cr-db-num     = {4}.cr-db-num
    {1}.in-code       = {4}.in-code
    {1}.node-code     = {4}.node-code
    {1}.part-code     = {4}.part-code
    {1}.stts_         = {4}.stts_
    {1}.bc-unit-cli   = {4}.unit-cli
    {1}.b-str         = {6}
    {1}.f-name        = {7}
    {1}.loc-ean       = {8}
    .
    if available {5}
    then
    assign
    {1}.bc-on-type    = {5}.bc-on-type
    {1}.bc-on         = {5}.bc-on
    {1}.pbc-cr-db-num = {5}.cr-db-num
    .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid ({1})
  .
end.
&endif

/* $Workfile$ e n d */