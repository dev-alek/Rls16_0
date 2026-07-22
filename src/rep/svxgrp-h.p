block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: svxgrp-h.p $
$Archive: rep/svxgrp-h.p $

Почасовой отчет по величинам сумм продаж вывод в EXCEL опция по строкам чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-xl-delim as character no-undo .
define input parameter startdate as date no-undo .
define input parameter enddate as date no-undo .
define input parameter SelectObject as char no-undo .
define input parameter byobject as logical no-undo .
define input parameter WHStart as integer no-undo .
define input parameter WHEnd as integer no-undo.
define input parameter RETS as logical no-undo.
/*обработка возвратов*/
define input parameter TREE as logical no-undo.
define input parameter method as character no-undo .
define input parameter t-dis-card as logical no-undo .
define input parameter rs-dis-card as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: svxgrp-h.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/svxgrp-h.p $":U .
define variable vss-description as character no-undo init "Почасовой отчет по величинам сумм продаж вывод в EXCEL опция по строкам чеков ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ cmp/obj-list.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ rep/e-svhrdf.i "SHARED" }
{ rep/fulgrpdf.i }
{ ref/grplibfn.i }
{ gbl/waitfram.i }


DEFINE VARIABLE accum-count as integer no-undo .
define SHARED temp-table temp-dis-card-type no-undo like ub.dis-card-type.
define   shared variable Use-column   as logical extent 256 no-undo .

define buffer for-grp for ub.gds-grp.
define variable LL AS INTEGER.
define variable tot-nc as integer no-undo.
define variable ii as integer no-undo .
define variable kk as integer no-undo .
define variable cycle as integer no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-obj-name like ub.clients.obj-name no-undo .
define variable accum-sum as decimal extent 24 no-undo .
define variable accum-num-chk as integer extent 24 no-undo .
define variable accum-sum-grp as decimal extent 24 no-undo .
define variable accum-num-chk-grp as integer extent 24 no-undo .

define variable accum-tot-nc as integer no-undo .
define variable accum-tot-nc-grp as integer no-undo format ">>>>>9".
define variable v-title as character no-undo .
define variable accum-obj-list as integer no-undo.
define variable cycle1 as integer no-undo.

define buffer cli-obj for ub.clients .

{ rep/sv-grp-h.i }

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

run waitfram-show in this-procedure ("Ждите" ).
PUT stream PrnLibStream UNFORMATTED
    "Почасовая статистика розничных продаж" format "x(80)" SKIP(0)
    ("( ПО ВЕЛИЧИНЕ СУММ ПРОДАЖ - СТРОКИ ЧЕКОВ) ЗА ПЕРИОД c" +
    string( startdate, "99/99/9999" ) + "по" + string( enddate, "99/99/9999" ) + ".")      format "x(80)" SKIP(0)
        IF RETS then "ВОЗВРАТЫ УЧТЕНЫ" ELSE "" format "x(80)" SKIP(0).
if t-dis-card then do:
  PUT stream PrnLibStream UNFORMATTED
  "Только покупки по дисконтным картам" skip.
  if rs-dis-card = 1 then do:
    for each temp-dis-card-type No-LOCK:
      PUT stream PrnLibStream UNFORMATTED
      temp-dis-card-type.type
      skip.
    END.
  end.
end.

PUT stream PrnLibStream UNFORMATTED SelectObject  SKIP(0)
(if byobject then "С разбивкой по объектам" else '':U) skip(1)
.
PUT stream PrnLibStream UNFORMATTED
SKIP
cur-time-print() format "x(35)" SKIP.
PUT stream PrnLibStream  UNFORMATTED
(if method = "pay":U then "Сумма_оплаты" else "Сумма_строки_чека") p-XL-delim.
if use-column[4] then
  PUT stream PrnLibStream  UNFORMATTED
  "0.00-0.59" p-XL-delim.
if use-column[5] then
  PUT stream PrnLibStream  UNFORMATTED
  "1.00-1.59" p-XL-delim.
if use-column[6] then
  PUT stream PrnLibStream  UNFORMATTED
  "2.00-2.59" p-XL-delim.
if use-column[7] then
  PUT stream PrnLibStream  UNFORMATTED
  "3.00-3.59" p-XL-delim.
if use-column[8] then
  PUT stream PrnLibStream  UNFORMATTED
  "4.00-4.59" p-XL-delim.
if use-column[9] then
  PUT stream PrnLibStream  UNFORMATTED
  "5.00-5.59" p-XL-delim.
if use-column[10] then
  PUT stream PrnLibStream  UNFORMATTED
  "6.00-6.59" p-XL-delim.
if use-column[11] then
  PUT stream PrnLibStream  UNFORMATTED
  "7.00-7.59" p-XL-delim.
if use-column[12] then
  PUT stream PrnLibStream  UNFORMATTED
  "8.00-8.59" p-XL-delim.
if use-column[13] then
  PUT stream PrnLibStream  UNFORMATTED
  "9.00-9.59" p-XL-delim.
if use-column[14] then
  PUT stream PrnLibStream  UNFORMATTED
  "10.00-10.59" p-XL-delim.
if use-column[15] then
  PUT stream PrnLibStream  UNFORMATTED
  "11.00-11.59" p-XL-delim.
if use-column[16] then
  PUT stream PrnLibStream  UNFORMATTED
  "12.00-12.59" p-XL-delim.
if use-column[17] then
  PUT stream PrnLibStream  UNFORMATTED
  "13.00-13.59" p-XL-delim.
if use-column[18] then
  PUT stream PrnLibStream  UNFORMATTED
  "14.00-14.59" p-XL-delim.
if use-column[19] then
  PUT stream PrnLibStream  UNFORMATTED
  "15.00-15.59" p-XL-delim.
if use-column[20] then
  PUT stream PrnLibStream  UNFORMATTED
  "16.00-16.59" p-XL-delim.
if use-column[21] then
  PUT stream PrnLibStream  UNFORMATTED
  "17.00-17.59" p-XL-delim.
if use-column[22] then
  PUT stream PrnLibStream  UNFORMATTED
  "18.00-18.59" p-XL-delim.
if use-column[23] then
  PUT stream PrnLibStream  UNFORMATTED
  "19.00-19.59" p-XL-delim.
if use-column[24] then
  PUT stream PrnLibStream  UNFORMATTED
  "20.00-20.59" p-XL-delim.
if use-column[25] then
  PUT stream PrnLibStream  UNFORMATTED
  "21.00-21.59" p-XL-delim.
if use-column[26] then
  PUT stream PrnLibStream  UNFORMATTED
  "22.00-22.59" p-XL-delim.
if use-column[27] then
  PUT stream PrnLibStream  UNFORMATTED
  "23.00-23.59" p-XL-delim.
PUT stream PrnLibStream  UNFORMATTED
"Итого_по_строке" p-XL-delim skip.
_cycle:
do cycle = 1 to 0 by -1:
  if byobject and cycle = 0 and accum-obj-list = 1 then LEAVE _cycle.
  _obj-list:
  for each obj-list no-lock:
    if not byobject and cycle = 1 then LEAVE _obj-list.
    if cycle = 1 then v-obj-code = obj-list.obj-code.
    if cycle = 0 then v-obj-code = 0.
    if cycle = 1 then do:
      FIND FIRST ub.clients NO-LOCK WHERE
                ub.clients.obj-code = v-obj-code AND
                ub.clients.obj-type = {&shop} NO-ERROR.
      if available clients then do:
        v-obj-name = replace(ub.clients.obj-name, {&space-char}, "_").
      end.
      else v-obj-name = string(v-obj-code).
    end.
    if byobject and cycle = 0 then do:
      v-obj-name = "ПО_ВСЕМ_ОБЪЕКТАМ".
    end.
    PUT stream PrnLibStream UNFORMATTED
    v-obj-name skip.
    assign
    tot-nc = 0
    accum-num-chk[1] =  0
    accum-num-chk[2] =  0
    accum-num-chk[3] =  0
    accum-num-chk[4] =  0
    accum-num-chk[5] =  0
    accum-num-chk[6] =  0
    accum-num-chk[7] =  0
    accum-num-chk[8] =  0
    accum-num-chk[9] =  0
    accum-num-chk[10] = 0
    accum-num-chk[11] = 0
    accum-num-chk[12] = 0
    accum-num-chk[13] = 0
    accum-num-chk[14] = 0
    accum-num-chk[15] = 0
    accum-num-chk[16] = 0
    accum-num-chk[17] = 0
    accum-num-chk[18] = 0
    accum-num-chk[19] = 0
    accum-num-chk[20] = 0
    accum-num-chk[21] = 0
    accum-num-chk[22] = 0
    accum-num-chk[23] = 0
    accum-num-chk[24] = 0
    accum-tot-nc = 0
    accum-count = 0
    .
    assign
    accum-num-chk-grp[1] =  0
    accum-num-chk-grp[2] =  0
    accum-num-chk-grp[3] =  0
    accum-num-chk-grp[4] =  0
    accum-num-chk-grp[5] =  0
    accum-num-chk-grp[6] =  0
    accum-num-chk-grp[7] =  0
    accum-num-chk-grp[8] =  0
    accum-num-chk-grp[9] =  0
    accum-num-chk-grp[10] = 0
    accum-num-chk-grp[11] = 0
    accum-num-chk-grp[12] = 0
    accum-num-chk-grp[13] = 0
    accum-num-chk-grp[14] = 0
    accum-num-chk-grp[15] = 0
    accum-num-chk-grp[16] = 0
    accum-num-chk-grp[17] = 0
    accum-num-chk-grp[18] = 0
    accum-num-chk-grp[19] = 0
    accum-num-chk-grp[20] = 0
    accum-num-chk-grp[21] = 0
    accum-num-chk-grp[22] = 0
    accum-num-chk-grp[23] = 0
    accum-num-chk-grp[24] = 0
    accum-tot-nc-grp = 0
    .
    if byobject then do:
      for each sum-vals:
        ASSIGN
        sum-vals.num-chk[1] = 0
        sum-vals.num-chk[2] = 0
        sum-vals.num-chk[3] = 0
        sum-vals.num-chk[4] = 0
        sum-vals.num-chk[5] = 0
        sum-vals.num-chk[6] = 0
        sum-vals.num-chk[7] = 0
        sum-vals.num-chk[8] = 0
        sum-vals.num-chk[9] = 0
        sum-vals.num-chk[10] = 0
        sum-vals.num-chk[11] = 0
        sum-vals.num-chk[12] = 0
        sum-vals.num-chk[13] = 0
        sum-vals.num-chk[14] = 0
        sum-vals.num-chk[15] = 0
        sum-vals.num-chk[16] = 0
        sum-vals.num-chk[17] = 0
        sum-vals.num-chk[18] = 0
        sum-vals.num-chk[19] = 0
        sum-vals.num-chk[20] = 0
        sum-vals.num-chk[21] = 0
        sum-vals.num-chk[22] = 0
        sum-vals.num-chk[23] = 0
        sum-vals.num-chk[24] = 0
        sum-vals.tot         = 0
        .
      end.
    end.
    FOR EACH full-grp No-LOCK,
        EACH grp-h WHERE
             grp-h.obj-code = v-obj-code
         AND grp-h.grp-code = full-grp.grp-code
         AND grp-h.other-code = full-grp.other-code
    BREAK
    BY full-grp.full-name
    BY grp-h.obj-code
    BY grp-h.grp-code
    BY grp-h.other-code
    BY grp-h.sum1:
      if (method = "pay":U and first-of(grp-h.other-code)) OR
        (method <> "pay":U and first-of( grp-h.grp-code )) then do:
        assign
        accum-num-chk-grp[1] =  0
        accum-num-chk-grp[2] =  0
        accum-num-chk-grp[3] =  0
        accum-num-chk-grp[4] =  0
        accum-num-chk-grp[5] =  0
        accum-num-chk-grp[6] =  0
        accum-num-chk-grp[7] =  0
        accum-num-chk-grp[8] =  0
        accum-num-chk-grp[9] =  0
        accum-num-chk-grp[10] = 0
        accum-num-chk-grp[11] = 0
        accum-num-chk-grp[12] = 0
        accum-num-chk-grp[13] = 0
        accum-num-chk-grp[14] = 0
        accum-num-chk-grp[15] = 0
        accum-num-chk-grp[16] = 0
        accum-num-chk-grp[17] = 0
        accum-num-chk-grp[18] = 0
        accum-num-chk-grp[19] = 0
        accum-num-chk-grp[20] = 0
        accum-num-chk-grp[21] = 0
        accum-num-chk-grp[22] = 0
        accum-num-chk-grp[23] = 0
        accum-num-chk-grp[24] = 0
        accum-tot-nc-grp = 0
        accum-count = accum-count + 1
        .
        PUT stream PrnLibStream UNFORMATTED
        full-grp.full-name SKIP    .
      end. /*if first-of grp-code*/
      FIND FIRST sum-vals where
                 sum-vals.sum1 = grp-h.sum1 .
      assign
        tot-nc = 0
      .
      do cycle1 = 1 to 24.
        if use-column[cycle1 + 3] then tot-nc = grp-h.num-chk[cycle1] + tot-nc .
      end.
        PUT stream PrnLibStream UNFORMATTED
        (string(sum-vals.sum1) + "_" + string(sum-vals.sum2) ) p-XL-delim.
        do cycle1 = 1 to 24.
          if use-column[cycle1 + 3] then
            PUT stream PrnLibStream UNFORMATTED
            grp-h.num-ch[cycle1]     p-XL-delim.
        end.
        PUT stream PrnLibStream UNFORMATTED
        tot-nc SKIP
        .
        ASSIGN
        /*по всему объекту  */
        accum-num-chk[1] = accum-num-chk[1] + grp-h.num-chk[1]
        accum-num-chk[2] = accum-num-chk[2] + grp-h.num-chk[2]
        accum-num-chk[3] = accum-num-chk[3] + grp-h.num-chk[3]
        accum-num-chk[4] = accum-num-chk[4] + grp-h.num-chk[4]
        accum-num-chk[5] = accum-num-chk[5] + grp-h.num-chk[5]
        accum-num-chk[6] = accum-num-chk[6] + grp-h.num-chk[6]
        accum-num-chk[7] = accum-num-chk[7] + grp-h.num-chk[7]
        accum-num-chk[8] = accum-num-chk[8] + grp-h.num-chk[8]
        accum-num-chk[9] = accum-num-chk[9] + grp-h.num-chk[9]
        accum-num-chk[10] = accum-num-chk[10] + grp-h.num-chk[10]
        accum-num-chk[11] = accum-num-chk[11] + grp-h.num-chk[11]
        accum-num-chk[12] = accum-num-chk[12] + grp-h.num-chk[12]
        accum-num-chk[13] = accum-num-chk[13] + grp-h.num-chk[13]
        accum-num-chk[14] = accum-num-chk[14] + grp-h.num-chk[14]
        accum-num-chk[15] = accum-num-chk[15] + grp-h.num-chk[15]
        accum-num-chk[16] = accum-num-chk[16] + grp-h.num-chk[16]
        accum-num-chk[17] = accum-num-chk[17] + grp-h.num-chk[17]
        accum-num-chk[18] = accum-num-chk[18] + grp-h.num-chk[18]
        accum-num-chk[19] = accum-num-chk[19] + grp-h.num-chk[19]
        accum-num-chk[20] = accum-num-chk[20] + grp-h.num-chk[20]
        accum-num-chk[21] = accum-num-chk[21] + grp-h.num-chk[21]
        accum-num-chk[22] = accum-num-chk[22] + grp-h.num-chk[22]
        accum-num-chk[23] = accum-num-chk[23] + grp-h.num-chk[23]
        accum-num-chk[24] = accum-num-chk[24] + grp-h.num-chk[24]
        accum-tot-nc = accum-tot-nc + tot-nc
        .
        /*подитоги по группе */
        assign
        accum-num-chk-grp[1] = accum-num-chk-grp[1] + grp-h.num-chk[1]
        accum-num-chk-grp[2] = accum-num-chk-grp[2] + grp-h.num-chk[2]
        accum-num-chk-grp[3] = accum-num-chk-grp[3] + grp-h.num-chk[3]
        accum-num-chk-grp[4] = accum-num-chk-grp[4] + grp-h.num-chk[4]
        accum-num-chk-grp[5] = accum-num-chk-grp[5] + grp-h.num-chk[5]
        accum-num-chk-grp[6] = accum-num-chk-grp[6] + grp-h.num-chk[6]
        accum-num-chk-grp[7] = accum-num-chk-grp[7] + grp-h.num-chk[7]
        accum-num-chk-grp[8] = accum-num-chk-grp[8] + grp-h.num-chk[8]
        accum-num-chk-grp[9] = accum-num-chk-grp[9] + grp-h.num-chk[9]
        accum-num-chk-grp[10] = accum-num-chk-grp[10] + grp-h.num-chk[10]
        accum-num-chk-grp[11] = accum-num-chk-grp[11] + grp-h.num-chk[11]
        accum-num-chk-grp[12] = accum-num-chk-grp[12] + grp-h.num-chk[12]
        accum-num-chk-grp[13] = accum-num-chk-grp[13] + grp-h.num-chk[13]
        accum-num-chk-grp[14] = accum-num-chk-grp[14] + grp-h.num-chk[14]
        accum-num-chk-grp[15] = accum-num-chk-grp[15] + grp-h.num-chk[15]
        accum-num-chk-grp[16] = accum-num-chk-grp[16] + grp-h.num-chk[16]
        accum-num-chk-grp[17] = accum-num-chk-grp[17] + grp-h.num-chk[17]
        accum-num-chk-grp[18] = accum-num-chk-grp[18] + grp-h.num-chk[18]
        accum-num-chk-grp[19] = accum-num-chk-grp[19] + grp-h.num-chk[19]
        accum-num-chk-grp[20] = accum-num-chk-grp[20] + grp-h.num-chk[20]
        accum-num-chk-grp[21] = accum-num-chk-grp[21] + grp-h.num-chk[21]
        accum-num-chk-grp[22] = accum-num-chk-grp[22] + grp-h.num-chk[22]
        accum-num-chk-grp[23] = accum-num-chk-grp[23] + grp-h.num-chk[23]
        accum-num-chk-grp[24] = accum-num-chk-grp[24] + grp-h.num-chk[24]
        accum-tot-nc-grp = accum-tot-nc-grp + tot-nc
        .
        ASSIGN
        sum-vals.num-chk[1] = sum-vals.num-chk[1] + grp-h.num-chk[1]
        sum-vals.num-chk[2] = sum-vals.num-chk[2] + grp-h.num-chk[2]
        sum-vals.num-chk[3] = sum-vals.num-chk[3] + grp-h.num-chk[3]
        sum-vals.num-chk[4] = sum-vals.num-chk[4] + grp-h.num-chk[4]
        sum-vals.num-chk[5] = sum-vals.num-chk[5] + grp-h.num-chk[5]
        sum-vals.num-chk[6] = sum-vals.num-chk[6] + grp-h.num-chk[6]
        sum-vals.num-chk[7] = sum-vals.num-chk[7] + grp-h.num-chk[7]
        sum-vals.num-chk[8] = sum-vals.num-chk[8] + grp-h.num-chk[8]
        sum-vals.num-chk[9] = sum-vals.num-chk[9] + grp-h.num-chk[9]
        sum-vals.num-chk[10] = sum-vals.num-chk[10] + grp-h.num-chk[10]
        sum-vals.num-chk[11] = sum-vals.num-chk[11] + grp-h.num-chk[11]
        sum-vals.num-chk[12] = sum-vals.num-chk[12] + grp-h.num-chk[12]
        sum-vals.num-chk[13] = sum-vals.num-chk[13] + grp-h.num-chk[13]
        sum-vals.num-chk[14] = sum-vals.num-chk[14] + grp-h.num-chk[14]
        sum-vals.num-chk[15] = sum-vals.num-chk[15] + grp-h.num-chk[15]
        sum-vals.num-chk[16] = sum-vals.num-chk[16] + grp-h.num-chk[16]
        sum-vals.num-chk[17] = sum-vals.num-chk[17] + grp-h.num-chk[17]
        sum-vals.num-chk[18] = sum-vals.num-chk[18] + grp-h.num-chk[18]
        sum-vals.num-chk[19] = sum-vals.num-chk[19] + grp-h.num-chk[19]
        sum-vals.num-chk[20] = sum-vals.num-chk[20] + grp-h.num-chk[20]
        sum-vals.num-chk[21] = sum-vals.num-chk[21] + grp-h.num-chk[21]
        sum-vals.num-chk[22] = sum-vals.num-chk[22] + grp-h.num-chk[22]
        sum-vals.num-chk[23] = sum-vals.num-chk[23] + grp-h.num-chk[23]
        sum-vals.num-chk[24] = sum-vals.num-chk[24] + grp-h.num-chk[24]
        sum-vals.tot = sum-vals.tot + tot-nc
        .
        IF (method = "pay":U and LAST-OF(grp-h.other-code))
        or (method <> "PAY":U and LAST-OF(grp-h.grp-code))  then do:
          if method = "pay" then do:
            v-title = substitute('&1_по_виду платежа', v-obj-name).
          end.
          if method = "LINE" then do:
            v-title = substitute('&1_по_группе', v-obj-name).
          end.
          PUT stream PrnLibStream UNFORMATTED
          v-title              p-XL-delim.
          do cycle1 = 1 to 24.
            if use-column[cycle1 + 3] then
              PUT stream PrnLibStream UNFORMATTED
              accum-num-chk-grp[cycle1]     p-XL-delim.
          end.
          PUT stream PrnLibStream UNFORMATTED
          accum-tot-nc-grp SKIP  .
        end.
        /*
        IF (method = "pay":U and LAST-OF(grp-h.other-code))
        or (method <> "PAY":U and LAST-OF(grp-h.grp-code))  then do:
        */
        IF (method = "pay":U and LAST(grp-h.other-code)) OR
          (method <> "PAY":U and LAST(grp-h.grp-code)) then do:
          IF (ACCUM-count)  > 1 then do:
            PUT stream PrnLibStream UNFORMATTED
            (if method = "pay":U
            then  substitute("&1_по_ВСЕМ_ВИДАМ ПЛАТЕЖЕЙ", v-obj-name)
            else  substitute("&1_по_ВСЕМ_ГРУППАМ", v-obj-name)
            ) SKIP.
            FOR EACH sum-vals NO-LOCK where :
              if v-obj-code > 0 and accum-obj-list > 1 and sum-vals.tot = 0 then next.
              PUT stream PrnLibStream UNFORMATTED
              (string(sum-vals.sum1) + "_" + string(sum-vals.sum2) ) p-XL-delim.
              do cycle1 = 1 to 24.
                if use-column[cycle1 + 3] then
                  PUT stream PrnLibStream UNFORMATTED
                  sum-vals.num-chk[cycle1]     p-XL-delim.
              end.
              PUT stream PrnLibStream UNFORMATTED
              sum-vals.tot SKIP.
            END.
        end. /*IF  (ACCUM COUNT grp-h.grp-code)  > 1*/
      end.  /*IF LAST(grp-h.grp-code)  */
    END . /*for each full-grp*/
    PUT stream PrnLibStream UNFORMATTED
    substitute("Итого_&1", v-obj-name)
    p-XL-delim.
    do cycle1 = 1 to 24.
      if use-column[cycle1 + 3] then
        PUT stream PrnLibStream UNFORMATTED
        accum-num-chk[cycle1]     p-XL-delim.
    end.
    PUT stream PrnLibStream UNFORMATTED
    ACCUM-tot-nc SKIP.
    if byobject and cycle = 0 then LEAVE _obj-list.
  end. /*for each obj-list*/
END. /*do cycle*/
output stream PrnLibStream CLOSE .
run waitfram-hide in this-procedure .