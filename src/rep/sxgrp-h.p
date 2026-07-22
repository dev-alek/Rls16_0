block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sxgrp-h.p $
$Archive: rep/sxgrp-h.p $

Почасовая статистика розничных продаж по СУММАМ ПРОДАЖ вывод в EXCEL

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter startdate as date no-undo .
define input parameter enddate as date no-undo .
define input parameter X-SelectObject as char no-undo .
define input parameter SelectObject as char no-undo .
define input parameter method as char no-undo .
/*
"Только итоги", "TOTALS":U,
"По группам", "GROUPS":U,
"Потоварно", "GOODS":U,
"По оплатам", "PAYS":U,
"По кассам", "pay-desk":U
*/
define input parameter ByObject as logical no-undo .
define input parameter Whstart as integer no-undo .
define input parameter WHEnd as integer no-undo .
define input parameter TREE as logical no-undo.
define input parameter t-dis-card as logical no-undo .
define input parameter rs-dis-card as integer no-undo .
define input parameter checked-time-intervals as char no-undo.

define variable  vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable  vss-author      as character no-undo init "$Author: expertek $":U .
define variable  vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable  vss-workfile    as character no-undo init "$Workfile: sxgrp-h.p $":U .
define variable  vss-archive     as character no-undo init "$Archive: rep/sxgrp-h.p $":U .
define variable  vss-description as character no-undo init "Почасовая статистика розничных продаж по СУММАМ ПРОДАЖ вывод в    EXCEL".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ cmp/obj-list.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }



define variable  With-Goods as logical no-undo.
{ rep/e-sumhdf.i "SHARED" }
{ rep/fulgrpdf.i  " " obj-code }
{ ref/grplibfn.i }
define variable p-XL-delim as character no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
{ gbl/getsect.i def }
{ gbl/getsect.i run {&cmp}  p-curr-host-code {&attr-report-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.

define SHARED temp-table temp-dis-card-type no-undo like ub.dis-card-type.
define   shared variable Use-column   as logical extent 256 no-undo .
define buffer b-grp-h for grp-h .
define buffer b-gds-h for gds-h .
define buffer for-grp for ub.gds-grp.
define variable tot-by-grp as decimal no-undo .
define variable tot-nc-by-grp as decimal no-undo format ">>>>>9".
define variable ii as integer no-undo .
define variable kk as integer no-undo .
define variable cycle as integer no-undo .
define variable cycle1 as integer no-undo .
define variable hours as character no-undo.
define variable sums as decimal no-undo.
define variable v-accum-sum as decimal no-undo .
define variable v-accum-sum_disc as decimal no-undo .
define variable v-accum-num-chk as integer no-undo .
define variable accum-sum as decimal extent 24 no-undo .
define variable accum-num-chk as integer extent 24 no-undo .
define variable accum-tot-by-grp as decimal no-undo .
define variable accum-tot-nc-by-grp as decimal no-undo format ">>>>>9".
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-obj-name as character no-undo .
define variable accum-obj-list as integer no-undo .

define variable  for-title as char no-undo.
define buffer cli-obj for ub.clients .
CASE method:
  when "pay-desk":U then for-title = "Кассы".
  when "pays":U then for-title = "Виды кассовых платежей".
  otherwise for-title = "Группа товаров ( по классификатору )".
END CASE.
{ rep/s-grp-h.i }

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT stream PrnLibStream UNFORMATTED
"Почасовая статистика розничных продаж ( по СУММЕ ПРОДАЖ ) ЗА ПЕРИОД c" +
string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) + "."      format "x(110)" SKIP(1).
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
PUT stream PrnLibStream UNFORMATTED
SPACE(10) SelectObject SKIP(0)
(if byobject then "С разбивкой по объектам" else '')  SKIP(1).
PUT stream PrnLibStream UNFORMATTED
SKIP
cur-time-print() format "x(35)" SKIP.
IF METHOD = "TOTALS" THEN DO:
  PUT stream PrnLibStream UNformatted
  "_" p-XL-delim
  "Сумма_брутто" p-XL-delim
  "Сумма_скидок" p-XL-delim
  "Сумма_нетто"  p-XL-delim
  "Количество_чеков" p-XL-delim
  skip.
  _cycle:
  do  cycle = 1 to 0 by -1:
    if byobject and cycle = 0 and accum-obj-list = 1 then LEAVE _cycle.
    _obj-list:
    for each obj-list no-lock:
      if not byobject and cycle = 1 then LEAVE _obj-list.
      if cycle = 1 then v-obj-code = obj-list.obj-code.
      if cycle = 0 then v-obj-code = 0.
      ASSIGN
      v-accum-SUM = 0
      v-accum-SUM_DISC = 0
      v-accum-NUM-CHK = 0
      .
      if cycle = 1 then do:
        FIND FIRST ub.clients NO-LOCK WHERE
                  ub.clients.obj-code = v-obj-code AND
                  ub.clients.obj-type = {&shop} NO-ERROR.
        if available ub.clients then do:
          v-obj-name = replace(ub.clients.obj-name, {&space-char}, "_").
        end.
        else v-obj-name = string(v-obj-code).
      end.
      if byobject and cycle = 0 then do:
        v-obj-name = "ПО_ВСЕМ_ОБЪЕКТАМ".
      end.
      put stream PrnLibstream Unformatted
      v-obj-name
      skip.
      FOR EACH grp-h No-LOCK where
              grp-h.obj-code = v-obj-code
      by grp-h.obj-code :
        DO ii = 0 TO 23 :
            /* если не помечен временой интервал галкой, то пропускаем */
            if entry(ii + 1, checked-time-intervals) = "no" then next.
            
            HOURS = string(ii, "99") + ".00-" + string(ii, "99") + ".59".
            PUT stream PrnLibStream UNFORMATTED
            HOURS p-XL-delim
            grp-h.sum[ii + 1] p-XL-delim
            grp-h.sum_disc[ii + 1] p-XL-delim
            grp-h.sum[ii + 1] - grp-h.sum_disc[ii + 1] p-XL-delim
            grp-h.num-chk[ii + 1] p-XL-delim
            skip
            .
            assign
            V-ACCUM-sum = v-accum-sum + grp-h.sum[ii + 1]
            V-ACCUM-sum_disc = v-accum-sum_disc + grp-h.sum_disc[ii + 1]
            V-ACCUM-num-chk = v-accum-num-chk + grp-h.num-chk[ii + 1]
            .
            IF ii = 23 then do:
              PUT stream PrnLibStream UNFORMATTED
              (if cycle = 1
              then substitute("Итого_&1", grp-h.obj-code)
              else "ИТОГО") p-XL-delim
              v-ACCUM-sum p-XL-delim
              v-ACCUM-sum_disc p-XL-delim
              v-ACCUM-sum - v-accum-sum_disc p-XL-delim
              v-aCCUM-num-chk p-XL-delim
            SKIP.
            end.
          END. /*ii */
        END. /*FOR EACH grp-h No-LOCK*/
        if cycle = 0 then LEAVE _obj-list.
     end. /*for each obj-list*/
   end. /*do cycle*/
END. /*IF METHOD = "TOTALS" THEN DO:*/
ELSE DO:
  CASE method:
    when "GROUPS":U then do:
      PUT stream PrnLibStream  UNFORMATTED
      "Группа_товара"
      p-XL-delim.
    end.
    when "GOODS":U then do:
      PUT stream PrnLibStream  UNFORMATTED
      ("Группа_товара/Артикул" + p-XL-delim + "Назв.товара")
      p-XL-delim.
    end.
    when "pay-desk":U then do :
      PUT stream PrnLibStream  UNFORMATTED
      "Касса"
      p-XL-delim.
    end.
    when "pays":U then do :
      PUT stream PrnLibStream  UNFORMATTED
      "Вид_кассового_платежа"
      p-XL-delim.
    end.
  END CASE.
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
  "Итого_по_строке" p-XL-delim .
  IF method = "pay-desk":U
  OR method = "pays":U then do:
    PUT stream PrnLibStream UNFORMATTED
    (if method = "pay-desk"
    then "Пробито_чеков"
    else "Кол-во_платежей") p-XL-delim.
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
  end.
  else do:
    PUT stream PrnLibStream unformatted skip.
  end.
  _cycle2:
  DO cycle = 1 to 0 by -1:
     if byobject and cycle = 0 and accum-obj-list = 1 then LEAVE _cycle2.
    _obj-list2:
    for each obj-list no-lock:
      if not byobject and cycle = 1 then LEAVE _obj-list2.
      if cycle = 1 then v-obj-code = obj-list.obj-code.
      if cycle = 0 then v-obj-code = 0.
      if cycle = 1 then do:
        FIND FIRST ub.clients NO-LOCK WHERE
                  ub.clients.obj-code = v-obj-code AND
                  ub.clients.obj-type = {&shop} NO-ERROR.
        if available ub.clients then do:
          v-obj-name = ub.clients.obj-name.
        end.
        else v-obj-name = string(v-obj-code).
      end.
      if byobject and cycle = 0 then do:
        v-obj-name = "ПО_ВСЕМ_ ОБЪЕКТАМ".
      end.
      if  byobject and not (cycle = 0 and method = "pay-desk")  then
      PUT stream PrnLibStream unformatted
      v-obj-name
      skip.
      assign
      tot-nc-by-grp  = 0
      tot-by-grp     = 0
      accum-sum[1]   = 0
      accum-sum[2]   = 0
      accum-sum[3]   = 0
      accum-sum[4]   = 0
      accum-sum[5]   = 0
      accum-sum[6]   = 0
      accum-sum[7]   = 0
      accum-sum[8]   = 0
      accum-sum[9]   = 0
      accum-sum[10]  = 0
      accum-sum[11]  = 0
      accum-sum[12]  = 0
      accum-sum[13]  = 0
      accum-sum[14]  = 0
      accum-sum[15]  = 0
      accum-sum[16]  = 0
      accum-sum[17]  = 0
      accum-sum[18]  = 0
      accum-sum[19]  = 0
      accum-sum[20]  = 0
      accum-sum[21]  = 0
      accum-sum[22]  = 0
      accum-sum[23]  = 0
      accum-sum[24]  = 0
      accum-tot-by-grp = 0
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
      accum-tot-nc-by-grp = 0
      .
      FOR EACH full-grp NO-LOCK,
          EACH grp-h WHERE
               grp-h.obj-code = v-obj-code
           AND grp-h.grp-code = full-grp.grp-code
      BREAK
      BY full-grp.full-name
      BY grp-h.obj-code
      BY grp-h.grp-code
      BY grp-h.other-code :
        if cycle = 1 and method = "pay-desk" and full-grp.other-code <> v-obj-code then next.
        if (method = "pays":U and first-of( grp-h.other-code )) or
           (method <> "pays":U and first-of(grp-h.grp-code)) then do:
         assign
            tot-nc-by-grp = 0
            tot-by-grp = 0
          .
          if method = "pay-desk":U or method = "pays":U then do:
            do cycle1 = 1 to 24.
              if use-column[cycle1 + 3] then tot-nc-by-grp = grp-h.num-chk[cycle1] + tot-nc-by-grp .
            end.
          end. /*if method = "pay-desk"*/
          do cycle1 = 1 to 24.
            if use-column[cycle1 + 3] then tot-by-grp = grp-h.sum[cycle1] + tot-by-grp .
          end.
          if method = "pay-desk":U  or method = "pays":U then do:
            if method = "pay-desk" and cycle = 0 then.
            else do:
              PUT stream PrnLibStream UNFORMATTED
              full-grp.FULL-NAME p-XL-delim.
              do cycle1 = 1 to 24.
                if use-column[cycle1 + 3] then
                  PUT stream PrnLibStream UNFORMATTED
                  grp-h.sum[cycle1]     p-XL-delim.
              end.
              PUT stream PrnLibStream UNFORMATTED
              tot-by-grp p-XL-delim
              .
              PUT stream PrnLibStream UNFORMATTED
              (if method = "pays":U
              then "число_платежей"
              else "пробито_чеков")      p-XL-delim.
              do cycle1 = 1 to 24.
                if use-column[cycle1 + 3] then
                  PUT stream PrnLibStream UNFORMATTED
                  grp-h.num-chk[cycle1]     p-XL-delim.
              end.
              PUT stream PrnLibStream UNFORMATTED
              tot-nc-by-grp p-XL-delim
              SKIP .
            end.
            assign
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
            accum-tot-nc-by-grp = accum-tot-nc-by-grp + tot-nc-by-grp
            .
          end.
          else do:
            PUT stream PrnLibStream UNFORMATTED
            full-grp.full-name p-XL-delim
            (if With-Goods then p-XL-delim else "").
            do cycle1 = 1 to 24.
              if use-column[cycle1 + 3] then
                PUT stream PrnLibStream UNFORMATTED
                grp-h.sum[cycle1]     p-XL-delim.
            end.
            PUT stream PrnLibStream UNFORMATTED
            tot-by-grp
            SKIP .
          end.
          if With-Goods then do:
            FOR EACH gds-h WHERE
                    gds-h.obj-code = grp-h.obj-code
                AND gds-h.grp-code = grp-h.grp-code
                    use-index uu BREAK BY gds-h.uniq :
              if first-of( gds-h.uniq ) then do:
                PUT stream PrnLibStream UNFORMATTED
                string( gds-h.artic, "x(16)" )  p-XL-delim
                replace(gds-h.gds-name, " " , "_" ) p-XL-delim.
                do cycle1 = 1 to 24.
                  if use-column[cycle1 + 3] then
                    PUT stream PrnLibStream UNFORMATTED
                    gds-h.sum[cycle1]     p-XL-delim.
                end.
                PUT stream PrnLibStream UNFORMATTED
                SKIP.
              end.
            END .   /* FOR EACH gds-h ... */
          end.    /* if With-Goods then ... */
          ASSIGN
          accum-sum[1] = accum-sum[1] + grp-h.sum[1]
          accum-sum[2] = accum-sum[2] + grp-h.sum[2]
          accum-sum[3] = accum-sum[3] + grp-h.sum[3]
          accum-sum[4] = accum-sum[4] + grp-h.sum[4]
          accum-sum[5] = accum-sum[5] + grp-h.sum[5]
          accum-sum[6] = accum-sum[6] + grp-h.sum[6]
          accum-sum[7] = accum-sum[7] + grp-h.sum[7]
          accum-sum[8] = accum-sum[8] + grp-h.sum[8]
          accum-sum[9] = accum-sum[9] + grp-h.sum[9]
          accum-sum[10] = accum-sum[10] + grp-h.sum[10]
          accum-sum[11] = accum-sum[11] + grp-h.sum[11]
          accum-sum[12] = accum-sum[12] + grp-h.sum[12]
          accum-sum[13] = accum-sum[13] + grp-h.sum[13]
          accum-sum[14] = accum-sum[14] + grp-h.sum[14]
          accum-sum[15] = accum-sum[15] + grp-h.sum[15]
          accum-sum[16] = accum-sum[16] + grp-h.sum[16]
          accum-sum[17] = accum-sum[17] + grp-h.sum[17]
          accum-sum[18] = accum-sum[18] + grp-h.sum[18]
          accum-sum[19] = accum-sum[19] + grp-h.sum[19]
          accum-sum[20] = accum-sum[20] + grp-h.sum[20]
          accum-sum[21] = accum-sum[21] + grp-h.sum[21]
          accum-sum[22] = accum-sum[22] + grp-h.sum[22]
          accum-sum[23] = accum-sum[23] + grp-h.sum[23]
          accum-sum[24] = accum-sum[24] + grp-h.sum[24]
          accum-tot-by-grp = accum-tot-by-grp + tot-by-grp
          .
        end.
      END . /*for each full-grp*/
    CASE method:
      when "pay-desk":U then do:
        PUT stream PrnLibStream UNFORMATTED
        substitute("ИТОГО_&1_по_всем_кассам", v-obj-name)
        p-XL-delim
        .
      end.
      when "GROUPS":U then do:
        PUT stream PrnLibStream UNFORMATTED
        substitute("ИТОГО_&1_по_всем_группам", v-obj-name)
        p-XL-delim
        .
      end.
      when "pays":U then do:
        PUT stream PrnLibStream UNFORMATTED
        substitute("ИТОГО_&1_по_всем_платежам", v-obj-name)
        p-XL-delim
        .
      end.
      otherwise do:
        PUT stream PrnLibStream UNFORMATTED
        substitute("ИТОГО_&1_по_всем_платежам", v-obj-name) p-xl-delim
        p-XL-delim
        .
      end.
    END.
    do cycle1 = 1 to 24.
      if use-column[cycle1 + 3] then
        PUT stream PrnLibStream UNFORMATTED
        ACCUM-sum[cycle1]     p-XL-delim.
    end.
    PUT stream PrnLibStream UNFORMATTED
      ACCUM-tot-by-grp            .
      IF method = "pay-desk":U or method = "pays":U then do:
        PUT stream PrnLibStream  UNFORMATTED p-XL-delim.
      end.
      else do:
        PUT stream PrnLibStream  UNFORMATTED SKIP .
      end.
      IF method = "pay-desk":U
      or method = "pays" then do:
        PUT stream PrnLibStream UNFORMATTED
        (if method = "pay-desk":U
        then "пробито_чеков"
        else "количество_платежей")      p-XL-delim.
        do cycle1 = 1 to 24.
          if use-column[cycle1 + 3] then
            PUT stream PrnLibStream UNFORMATTED
            ACCUM-num-chk[cycle1]     p-XL-delim.
        end.
        PUT stream PrnLibStream UNFORMATTED
        ACCUM-tot-nc-by-grp format ">>>>>9" p-XL-delim
        SKIP .
      end.
      if cycle = 0 then LEAVE _obj-list2.
    end. /*for each obj-list*/
  end. /*do cycle*/
END. /*METHOD <> "TOTALS"*/
output stream PrnLibStream CLOSE .