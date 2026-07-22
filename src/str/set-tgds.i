/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

создание записи во временной таблице  при закачке / создании чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


if buf_chk-gds.grp-code = 0 then /* else - cуммовая строка */  do:
  if cr > 0 then
  find first t-gds WHERE
              t-gds.b-code = buf_chk-gds.b-code and
              t-gds.drc = recid(buf_chk-doc)
              NO-ERROR.
  if not avail t-gds or cr = 0 OR (t-gds.grc <> ? AND t-gds.grc <> recid(buf_chk-gds)) then  do:
    FIND FIRST t-gds where t-gds.crf = cr + 1 use-index crfi No-ERROR.
    if not avail t-gds then
    create t-gds.
    assign
    t-gds.crf = cr + 1
    cr = cr + 1
    t-gds.b-code = buf_chk-gds.b-code
    t-gds.unit-base = if v-b-c <> ? then buf_goods.unit-base else ""
    t-gds.doc-qnty = 0
    t-gds.drc = recid(buf_chk-doc)
    t-gds.price-sum = 0
    t-gds.discnt-sum = 0
    t-gds.grc = if v-b-c <> ?
                then (if LOOKUP({&twounit}, buf_units.type) > 0 then recid(t-gds) else ?)
                else ?
    t-gds.type = if v-b-c <> ? then buf_units.type else ""
    t-gds.num-lines = 0
    t-gds.was-return = no
    t-gds.was-write-off = no
    t-gds.is-modificATOR = no
    t-gds.is-null-price = no
    t-gds.first-line-num = 0
    t-gds.corr-discnt-rank = 0
    .
  end.
  ELSE DO:
    ASSIGN
    t-gds.is-modificATOR = no
    t-gds.is-null-price = no
    .
  END.
  assign
  t-gds.doc-qnty = t-gds.doc-qnty + buf_chk-gds.doc-qnty
  t-gds.num-lines = t-gds.num-lines + 1
  t-gds.price-sum = t-gds.price-sum +
                    (buf_chk-gds.price-base + buf_chk-gds.price-service ) * buf_chk-gds.doc-qnty
  t-gds.discnt-sum  = t-gds.discnt-sum +
                      buf_chk-gds.discnt * buf_chk-gds.doc-qnty
  t-gds.was-return = if t-gds.was-return
                      then t-gds.was-return
                      else (buf_chk-gds.line-sign = no)
  t-gds.was-write-off = if t-gds.was-write-off
                      then t-gds.was-write-off
                      else (buf_chk-gds.write-off-code <> ? and buf_chk-gds.write-off-code <> 0)
&scop wro-code STRING(if buf_chk-gds.write-off-code <> ? then buf_chk-gds.write-off-code else 0)
  t-gds.is-modificator =  if (t-gds.was-write-off
                          and {&wro-is-modificator}
                          )
                          or t-gds.is-modificator
                          then yes
                          else t-gds.is-modificator
  t-gds.is-null-price =  no /*потом заполним из справочника*/
t-gds.last-included-in-sale = (if (t-gds.price-sum - t-gds.discnt-sum) = 0
                                then 0
                                else (if buf_chk-gds.line-sign
                                      then buf_chk-gds.line-num
                                      else t-gds.last-included-in-sale)
                                )
  .
end.


/* $Workfile$ e n d */