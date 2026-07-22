block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dxchk-h2.p $
$Archive: rep/dxchk-h2.p $

Почасовой отчет по покупкам для вывода в EXCEL - с разбивкой по группам и объектам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-XL-delim as character no-undo .
define input parameter startdate as date no-undo .
define input parameter enddate as date no-undo .
define input parameter SelectObject as char no-undo .
define input parameter Rs-option as integer no-undo .
define input parameter by-object-str as character no-undo .
define input parameter WHStart as integer no-undo .
define input parameter WHEnd as integer no-undo .
define input parameter t-dis-card as logical no-undo .
define input parameter rs-dis-card as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dxchk-h2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/dxchk-h2.p $":U .
define variable vss-description as character no-undo init "Почасовой отчет по покупкам для вывода в EXCEL - с разбивкой по группам и объектам ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ cmp/obj-list.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }


{ rep/e-chkhdf.i SHARED }
{ rep/fulgrpdf.i }
{ ref/grplibfn.i }
define SHARED temp-table temp-dis-card-type no-undo like dis-card-type.
define   shared variable Use-column   as logical extent 256 no-undo .
define buffer b-chk-h for chk-h .
define buffer for-grp for ub.gds-grp.
define variable ii as int     no-undo .
define variable kk as int     no-undo .
define variable cycle as integer no-undo .
define variable cycle1 as integer no-undo .
define variable accum-hour as decimal no-undo extent 24.
define variable accum-qnty as decimal no-undo .
define variable byobject as logical no-undo .
define variable accum-obj-list as integer no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-obj-name like ub.clients.obj-name no-undo .
define variable obj-count as integer no-undo .
define variable v-title as character no-undo .

define buffer cli-obj for ub.clients .


{ rep/d-chk-h.i }
byobject = (if rs-option = 2 or rs-option = 3 then yes else no).
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT stream PrnLibStream UNFORMATTED
    "Почасовая статистика по количеству ПОКУПОК ЗА ПЕРИОД c " +
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

PUT stream PrnLibStream UNFORMATTED SelectObject  SKIP
by-object-str skip
.
PUT stream PrnLibStream UNFORMATTED
        SKIP
        cur-time-print() SKIP.
PUT stream PrnLibStream
"По_всем_группам_товаров" format "X(56)" p-XL-delim.
if use-column[2] then
  PUT stream PrnLibStream
  "0.00-0.59" p-XL-delim.
if use-column[3] then
  PUT stream PrnLibStream
  "1.00-1.59" p-XL-delim.
if use-column[4] then
  PUT stream PrnLibStream
  "2.00-2.59" p-XL-delim.
if use-column[5] then
  PUT stream PrnLibStream
  "3.00-3.59" p-XL-delim.
if use-column[6] then
  PUT stream PrnLibStream
  "4.00-4.59" p-XL-delim.
if use-column[7] then
  PUT stream PrnLibStream
  "5.00-5.59" p-XL-delim.
if use-column[8] then
  PUT stream PrnLibStream
  "6.00-6.59" p-XL-delim.
if use-column[9] then
  PUT stream PrnLibStream
  "7.00-7.59" p-XL-delim.
if use-column[10] then
  PUT stream PrnLibStream
  "8.00-8.59" p-XL-delim.
if use-column[11] then
  PUT stream PrnLibStream
  "9.00-9.59" p-XL-delim.
if use-column[12] then
  PUT stream PrnLibStream
  "10.00-10.59" p-XL-delim.
if use-column[13] then
  PUT stream PrnLibStream
  "11.00-11.59" p-XL-delim.
if use-column[14] then
  PUT stream PrnLibStream
  "12.00-12.59" p-XL-delim.
if use-column[15] then
  PUT stream PrnLibStream
  "13.00-13.59" p-XL-delim.
if use-column[16] then
  PUT stream PrnLibStream
  "14.00-14.59" p-XL-delim.
if use-column[17] then
  PUT stream PrnLibStream
  "15.00-15.59" p-XL-delim.
if use-column[18] then
  PUT stream PrnLibStream
  "16.00-16.59" p-XL-delim.
if use-column[19] then
  PUT stream PrnLibStream
  "17.00-17.59" p-XL-delim.
if use-column[20] then
  PUT stream PrnLibStream
  "18.00-18.59" p-XL-delim.
if use-column[21] then
  PUT stream PrnLibStream
  "19.00-19.59" p-XL-delim.
if use-column[22] then
  PUT stream PrnLibStream
  "20.00-20.59" p-XL-delim.
if use-column[23] then
  PUT stream PrnLibStream
  "21.00-21.59" p-XL-delim.
if use-column[24] then
  PUT stream PrnLibStream
  "22.00-22.59" p-XL-delim.
if use-column[25] then
  PUT stream PrnLibStream
  "23.00-23.59" p-XL-delim.
PUT stream PrnLibStream
"Итого_по_строке" p-XL-delim skip.
_cycle:
do cycle = 1 to 0 by -1:
  if byobject and cycle = 0 and accum-obj-list = 1 then LEAVE _cycle.
  _obj-list:
  for each obj-list no-lock:
    obj-count = obj-count + 1.
    if not byobject and cycle = 1 then LEAVE _obj-list.
    if cycle = 1 then v-obj-code = obj-list.obj-code.
    if cycle = 0 then v-obj-code = 0.
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
    if rs-option <> 3 and byobject then do:
      PUT STREAM PrnLibStream UNFORMATTED
      v-obj-name skip.
    end.
    assign
    accum-hour[1]  = 0
    accum-hour[2]  = 0
    accum-hour[3]  = 0
    accum-hour[4]  = 0
    accum-hour[5]  = 0
    accum-hour[6]  = 0
    accum-hour[7]  = 0
    accum-hour[8]  = 0
    accum-hour[9]  = 0
    accum-hour[10] = 0
    accum-hour[11] = 0
    accum-hour[12] = 0
    accum-hour[13] = 0
    accum-hour[14] = 0
    accum-hour[15] = 0
    accum-hour[16] = 0
    accum-hour[17] = 0
    accum-hour[18] = 0
    accum-hour[19] = 0
    accum-hour[20] = 0
    accum-hour[21] = 0
    accum-hour[22] = 0
    accum-hour[23] = 0
    accum-hour[24] = 0
    accum-qnty     = 0
    .
    FOR EACH full-grp No-LOCK,
    EACH chk-h NO-LOCK where
         chk-h.obj-code = v-obj-code
     AND chk-h.grp-code = full-grp.grp-code
    BREAK
    BY full-grp.full-name
    BY chk-h.grp-code:
      if cycle = 0 or rs-option = 2 then do:
        if first-of( chk-h.grp-code ) then do:
          if (chk-h.hour[1] <> 0) OR (chk-h.hour[2]<> 0) OR (chk-h.hour[3]<> 0) OR (chk-h.hour[4]<> 0) OR
              (chk-h.hour[5] <> 0) OR (chk-h.hour[6] <> 0) OR (chk-h.hour[7] <> 0) OR (chk-h.hour[8] <> 0) OR
              (chk-h.hour[9] <> 0) OR (chk-h.hour[10] <> 0) OR (chk-h.hour[11] <> 0) OR (chk-h.hour[12] <> 0) OR
              (chk-h.hour[13] <> 0) OR (chk-h.hour[14] <> 0) OR (chk-h.hour[15] <> 0) OR (chk-h.hour[16] <> 0) OR
              (chk-h.hour[17] <> 0) OR (chk-h.hour[18] <> 0) OR (chk-h.hour[19] <> 0) OR (chk-h.hour[20] <> 0) OR
              (chk-h.hour[21] <> 0) OR (chk-h.hour[22] <> 0) OR (chk-h.hour[23] <> 0) OR (chk-h.hour[24] <> 0) then do:
            PUT stream PrnLibStream UNFORMATTED
            FULL-NAME p-XL-delim.
            do cycle1 = 1 to 24.
              if use-column[cycle1 + 1] then
                PUT stream PrnLibStream UNFORMATTED
                chk-h.hour[cycle1]     p-XL-delim.
            end.
            PUT stream PrnLibStream UNFORMATTED
            chk-h.qnty
            skip.
          end.
        end. /*if first-of( chk-h.grp-code ) then do:*/
      end. /*if cycle = 0 or rs-option <> 3*/
      assign
      accum-hour[1] = accum-hour[1] + chk-h.hour[1]
      accum-hour[2] = accum-hour[2] + chk-h.hour[2]
      accum-hour[3] = accum-hour[3] + chk-h.hour[3]
      accum-hour[4] = accum-hour[4] + chk-h.hour[4]
      accum-hour[5] = accum-hour[5] + chk-h.hour[5]
      accum-hour[6] = accum-hour[6] + chk-h.hour[6]
      accum-hour[7] = accum-hour[7] + chk-h.hour[7]
      accum-hour[8] = accum-hour[8] + chk-h.hour[8]
      accum-hour[9] = accum-hour[9] + chk-h.hour[9]
      accum-hour[10] = accum-hour[10] + chk-h.hour[10]
      accum-hour[11] = accum-hour[11] + chk-h.hour[11]
      accum-hour[12] = accum-hour[12] + chk-h.hour[12]
      accum-hour[13] = accum-hour[13] + chk-h.hour[13]
      accum-hour[14] = accum-hour[14] + chk-h.hour[14]
      accum-hour[15] = accum-hour[15] + chk-h.hour[15]
      accum-hour[16] = accum-hour[16] + chk-h.hour[16]
      accum-hour[17] = accum-hour[17] + chk-h.hour[17]
      accum-hour[18] = accum-hour[18] + chk-h.hour[18]
      accum-hour[19] = accum-hour[19] + chk-h.hour[19]
      accum-hour[20] = accum-hour[20] + chk-h.hour[20]
      accum-hour[21] = accum-hour[21] + chk-h.hour[21]
      accum-hour[22] = accum-hour[22] + chk-h.hour[22]
      accum-hour[23] = accum-hour[23] + chk-h.hour[23]
      accum-hour[24] = accum-hour[24] + chk-h.hour[24]
      accum-qnty = accum-qnty + chk-h.qnty
      .
    end. /*for each full-grp*/
    if rs-option = 3 then do:
      v-title = v-obj-name.
    end.
    else do:
      v-title = substitute('ИТОГО_&1', v-obj-name).
    end.
    PUT stream PrnLibStream UNFORMATTED
    v-title           p-XL-delim.
    do cycle1 = 1 to 24.
      if use-column[cycle1 + 1] then
        PUT stream PrnLibStream UNFORMATTED
        accum-hour[cycle1]     p-XL-delim.
    end.
    PUT stream PrnLibStream UNFORMATTED
    accum-qnty           p-XL-delim
    skip.
    /*выведем кол-во чеков по часам*/
    find first num-h where num-h.obj-code = v-obj-code no-error .
     v-title = substitute('Пробито_чеков_&1', v-obj-name).
    if available num-h then do:
      PUT stream PrnLibStream UNFORMATTED
      v-title p-XL-delim.
      do cycle1 = 1 to 24.
        if use-column[cycle1 + 1] then
          PUT stream PrnLibStream UNFORMATTED
          num-h.hour[cycle1]     p-XL-delim.
      end.
      PUT stream PrnLibStream UNFORMATTED
      num-h.qnty           p-XL-delim
      skip.
    end. /*avail num-h*/
    if cycle = 0 then LEAVE _obj-list.
  end. /*for each obj-list*/
end. /*do cycle*/
output stream PrnLibStream CLOSE .