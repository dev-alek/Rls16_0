block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sdxgrp-h.p $
$Archive: rep/sdxgrp-h.p $

Почасовой отчет по величинам сумм продаж вывод в EXCEL опция по чекам

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
define input parameter WHEnd as integer no-undo .
define input parameter RETS as logical no-undo.
/*обработка возвратов*/
define input parameter TREE as logical no-undo.
define input parameter t-dis-card as logical no-undo .
define input parameter rs-dis-card as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sdxgrp-h.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/sdxgrp-h.p $":U .
define variable vss-description as character no-undo init "Почасовой отчет по величинам сумм продаж вывод в  EXCEL  опция по чекам ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ cmp/obj-list.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ rep/e-svhrdf.i "SHARED" }
{ rep/fulgrpdf.i " " obj-code }

define SHARED temp-table temp-dis-card-type no-undo like ub.dis-card-type.

define variable full-name as char.
define buffer for-grp for ub.gds-grp.
define variable LL AS INTEGER.
define variable tot-nc as integer no-undo.
define variable ii as integer     no-undo .
define variable kk as integer     no-undo .
define variable cycle as integer no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-obj-name like ub.clients.obj-name no-undo .
define variable accum-num-chk as integer extent 24 no-undo .
define variable accum-tot-nc as integer no-undo .
define variable accum-obj-list as integer no-undo .

define buffer cli-obj for ub.clients .
for each obj-list no-lock:
  assign
  accum-obj-list = accum-obj-list + 1.
  if accum-obj-list > 1 then LEAVE.
end.

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT stream PrnLibStream
    "Почасовая статистика розничных продаж" format "x(80)" SKIP(0)
    ("( ПО ВЕЛИЧИНЕ СУММ ПРОДАЖ - ЧЕКИ) ЗА ПЕРИОД c" +
    string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) + ".")      format "x(80)" SKIP(0)
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

PUT stream PrnLibStream UNFORMATTED SelectObject  skip(0)
(if byobject then "С разбивкой по объектам" else '':U) skip(1)
.
PUT stream PrnLibStream UNFORMATTED
SKIP
cur-time-print() format "x(35)" SKIP.

PUT stream PrnLibStream  UNFORMATTED
"Сумма_чека"  p-XL-delim
"0.00-0.59" p-XL-delim
"1.00-1.59" p-XL-delim
"2.00-2.59" p-XL-delim
"3.00-3.59" p-XL-delim
"4.00-4.59" p-XL-delim
"5.00-5.59" p-XL-delim
"6.00-6.59" p-XL-delim
"7.00-7.59" p-XL-delim
"8.00-8.59" p-XL-delim
"9.00-9.59" p-XL-delim
"0.00-10.59" p-XL-delim
"11.00-11.59" p-XL-delim
"12.00-12.59" p-XL-delim
"13.00-13.59" p-XL-delim
"14.00-14.59" p-XL-delim
"15.00-15.59" p-XL-delim
"16.00-16.59" p-XL-delim
"17.00-17.59" p-XL-delim
"18.00-18.59" p-XL-delim
"19.00-19.59" p-XL-delim
"20.00-20.59" p-XL-delim
"21.00-21.59" p-XL-delim
"22.00-22.59" p-XL-delim
"23.00-23.59" p-XL-delim
"Итого_по_строке" p-XL-delim skip.
_cycle:
do cycle = 1 to 0 by -1:
  if byobject and cycle = 0 and accum-obj-list = 1 then LEAVE _cycle.
  _obj-list:
  for each obj-list no-lock:
    if not byobject and cycle = 1 then LEAVE _obj-list.
    if cycle = 1 then v-obj-code = obj-list.obj-code.
    if cycle = 0 then v-obj-code = 0.
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
    .
    if cycle = 1 then do:
      FIND FIRST ub.clients NO-LOCK WHERE
                ub.clients.obj-code = v-obj-code AND
                ub.clients.obj-type = {&shop} NO-ERROR.
      if available ub.clients then do:
        v-obj-name = replace(ub.clients.obj-name, {&space-char} , "_").
      end.
      else v-obj-name = string(v-obj-code).
    end.
    if byobject and cycle = 0 then do:
      v-obj-name = "ПО_ВСЕМ_ОБЪЕКТАМ".
    end.
    PUT stream PrnLibStream UNFORMATTED
    v-obj-name p-XL-delim
    SKIP.
    _sum-vals:
    for each sum-vals:
       find first grp-h WHERE
                 grp-h.obj-code = v-obj-code
            AND  grp-h.sum = sum-vals.sum1 no-error .
      if not available grp-h and v-obj-code > 0 and accum-obj-list > 1 then next.
      if available grp-h then do:
        tot-nc =  grp-h.num-chk[1] + grp-h.num-chk[2] + grp-h.num-chk[3] +
                      grp-h.num-chk[4] + grp-h.num-chk[5] + grp-h.num-chk[6] + grp-h.num-chk[7] +
                      grp-h.num-chk[8] + grp-h.num-chk[9] + grp-h.num-chk[10] + grp-h.num-chk[11] +
                      grp-h.num-chk[12] + grp-h.num-chk[13] + grp-h.num-chk[14] + grp-h.num-chk[15] +
                      grp-h.num-chk[16] + grp-h.num-chk[17] + grp-h.num-chk[18] + grp-h.num-chk[19] +
                      grp-h.num-chk[20] + grp-h.num-chk[21] + grp-h.num-chk[22] + grp-h.num-chk[23] +
                      grp-h.num-chk[24].
        PUT STREAM PrnLibStream UNFORMATTED
        (string(sum-vals.sum1) + "_" + string(sum-vals.sum2) ) p-XL-delim
        grp-h.num-chk[1] p-XL-delim
        grp-h.num-chk[2] p-XL-delim
        grp-h.num-chk[3] p-XL-delim
        grp-h.num-chk[4] p-XL-delim
        grp-h.num-chk[5] p-XL-delim
        grp-h.num-chk[6] p-XL-delim
        grp-h.num-chk[7] p-XL-delim
        grp-h.num-chk[8] p-XL-delim
        grp-h.num-chk[9] p-XL-delim
        grp-h.num-chk[10] p-XL-delim
        grp-h.num-chk[11] p-XL-delim
        grp-h.num-chk[12] p-XL-delim
        grp-h.num-chk[13] p-XL-delim
        grp-h.num-chk[14] p-XL-delim
        grp-h.num-chk[15] p-XL-delim
        grp-h.num-chk[16] p-XL-delim
        grp-h.num-chk[17] p-XL-delim
        grp-h.num-chk[18] p-XL-delim
        grp-h.num-chk[19] p-XL-delim
        grp-h.num-chk[20] p-XL-delim
        grp-h.num-chk[21] p-XL-delim
        grp-h.num-chk[22] p-XL-delim
        grp-h.num-chk[23] p-XL-delim
        grp-h.num-chk[24] p-XL-delim
        tot-nc
        skip.
        ASSIGN
        /*Итого  */
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
      end.
      else do:
         /* ао этим суммам нули - но напечатаем так как у нас должна быть полная картина по sum-vals*/
        PUT STREAM PrnLibStream UNFORMATTED
        (string(sum-vals.sum1) + "_" + string(sum-vals.sum2) ) p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0 p-XL-delim
        0
        skip.

      end.
    end. /*for each  sum-vals*/
    PUT stream PrnLibStream UNFORMATTED
    substitute("Итого_&1", v-obj-name) p-XL-delim
    accum-num-chk[1]  p-XL-delim
    accum-num-chk[2]  p-XL-delim
    accum-num-chk[3]  p-XL-delim
    accum-num-chk[4]  p-XL-delim
    accum-num-chk[5]  p-XL-delim
    accum-num-chk[6]  p-XL-delim
    accum-num-chk[7]  p-XL-delim
    accum-num-chk[8]  p-XL-delim
    accum-num-chk[9]  p-XL-delim
    accum-num-chk[10] p-XL-delim
    accum-num-chk[11] p-XL-delim
    accum-num-chk[12] p-XL-delim
    accum-num-chk[13] p-XL-delim
    accum-num-chk[14] p-XL-delim
    accum-num-chk[15] p-XL-delim
    accum-num-chk[16] p-XL-delim
    accum-num-chk[17] p-XL-delim
    accum-num-chk[18] p-XL-delim
    accum-num-chk[19] p-XL-delim
    accum-num-chk[20] p-XL-delim
    accum-num-chk[21] p-XL-delim
    accum-num-chk[22] p-XL-delim
    accum-num-chk[23] p-XL-delim
    accum-num-chk[24] p-XL-delim
    accum-tot-nc
    skip
    .
    if byobject and cycle = 0 then LEAVE _obj-list.
  end. /*for each obj-list*/
END . /*do cycle*/
output stream PrnLibStream CLOSE .