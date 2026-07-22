block-level on error undo, throw.
/*

$Revision: ac2de8611dbf, 1057, rls $
$Author: EShklyar $
$Date: Fri Oct 06 18:33:18 2017 +0300 $
$Workfile: r-shift.p $
$Archive: rep/r-shift.p $

сменный отчет

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/06/07
Author: Dmitry Ukhanov
Creation date: 08/06/07

Автор1: Булгаков Андрей Николаевич
Дата создания1: 05/06/01

*/

define input parameter parparentproc            as   widget-handle         no-undo .
define input parameter p-parent-handle          as handle                  no-undo .
define input parameter p-log-handle             as handle                  no-undo .
define input parameter p-cont-handle            as handle                  no-undo .
define input parameter p-call-handle            as handle                  no-undo .
define input parameter p-rebh                   as handle                  no-undo . /*для ошибок*/
define input parameter p-rdbh                   as handle                  no-undo . /*destination*/
define input parameter p-report-id              as character               no-undo .
define input parameter p-xsd-file               as character               no-undo .
define input parameter p-log-file-name          as character               no-undo .
define input parameter p-batch                  as integer                 no-undo .
define input parameter p-codex-id               as integer no-undo .
define input parameter p-ruleset-id             as integer no-undo .
define input parameter p-obj-code               like ub.clients.obj-code   no-undo .
define input parameter p-obj-type               like ub.clients.obj-type   no-undo .
define input parameter p-curr-abbr              like ub.currency.curr-abbr no-undo .
define input parameter p-base-code              like ub.currency.curr-code no-undo .
define input parameter p-line-of-page           as   integer               no-undo .
define input parameter p-weight                 as   logical               no-undo .
define input parameter xClassify                as   character             no-undo .
define input parameter xSortType                as   character             no-undo .
define input parameter xtog-level               as   logical               no-undo .
define input parameter xvar-level               as   integer               no-undo .
define input parameter tog-1                    as   logical               no-undo .
define input parameter tog-2                    as   logical               no-undo .
define input parameter tog-3                    as   logical               no-undo .
define input parameter tog-4                    as   logical               no-undo .
define input parameter tog-5                    as   logical               no-undo .
define input parameter tog-6                    as   logical               no-undo .
define input parameter tog-7                    as   logical               no-undo .
define input parameter tog-8                    as   logical               no-undo .
define input parameter tog-9                    as   logical               no-undo .
define input parameter tog-10                   as   logical               no-undo .
define input parameter tog-1-pump-one           as   logical               no-undo .
define input parameter tog-1-whole-gds          as   logical               no-undo .
define input parameter tog-1-out-pump-with-icnt as   logical               no-undo .
define input parameter tog-2-cp-grp             as   logical               no-undo .
define input parameter p-plain-txt              as   logical               no-undo .
define input parameter p-xls                    as   logical               no-undo .
define input parameter p-dir-name               as   character             no-undo .
define input-output parameter p-dataseth        as   handle                no-undo .
{ rul/tempcxml.i }
define input parameter table      for temp-xml-tables .


define variable vss-revision    as character no-undo initial "$Revision: ac2de8611dbf, 1057, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Fri Oct 06 18:33:18 2017 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-shift.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-shift.p $":U .
define variable vss-description as character no-undo initial "сменный отчет":U .

/* Parameters Definitions ---                                           */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i "new shared" }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ cmp/breakstr.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/getsect.i  def }
/*данные по реализации*/
{ rep/real-2df.i "NEW SHARED" treal-2 }
{ rep/real-3df.i "NEW SHARED" treal-3 }
{ rep/real-4df.i "NEW SHARED" treal-4 }
{ rep/real-8df.i "NEW SHARED" treal-8 }
/*таблица нужных групп для листа 3*/
{ rep/icm-3df.i  "NEW SHARED"}
{ gbl/waitfram.i }
{ rep/rshiftd1.i t "new shared"}
{ gbl/gate-clb.i }
{ rep/fmtcli.i     }
{ rep/reprumpr.i print-plain-text,print-printer,print-xls }


define variable line as character no-undo .
define variable store-name as character no-undo.
define variable for-mng as character no-undo format "X(30)":U .
define variable for-mng-next as character no-undo format "X(30)":U .
define variable for-opers as character no-undo.
define variable for-opers1 as character no-undo format "X(44)":U .
define variable for-opers2 as character no-undo format "X(44)":U .
define variable first-oper as logical no-undo initial yes.
define variable first-mngr as logical no-undo initial yes.
define variable sheets  as integer no-undo.
define variable v-previous-shift-date as date no-undo .
define variable v-current-shift-date as date no-undo .
define variable v-archive-ok as logical no-undo .
define variable v-comment as character no-undo .
define variable v-can-print as logical no-undo .
define variable v-run-2-3-4 as logical no-undo initial yes.
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-host-name like ub.clients.obj-name no-undo .
define variable p-z-number-list   as character no-undo.
define variable p-z-number-item   as character no-undo.
define variable v-param_prt-z-no  as character no-undo.
define variable v-param_shft-qty  as character no-undo.
define variable v-param_data-type as character no-undo.
define variable v-open-date   like ub.shift-obj.open-date no-undo.
define variable v-open-time   like ub.shift-obj.open-time no-undo.
define variable v-close-date  like ub.shift-obj.close-date no-undo.
define variable v-close-time  like ub.shift-obj.close-time no-undo.
define variable v-count as integer initial 0  no-undo .
define variable v-ii as integer no-undo .
define variable v-str2 as character no-undo .
define variable v-write-xml-error as logical no-undo .
define variable v-obj-address as character no-undo .
define variable v-obj-phone as character no-undo .
define variable pol2 as character no-undo .
define variable pol16 as character no-undo .


define buffer next-shift-obj for ub.shift-obj.
define buffer previous-shift-obj for ub.shift-obj.
define buffer buf_goods for ub.goods.
define buffer buf_shift for shiftt.

if p-batch > 0 then do:
  run get-userid in parparentproc ( output v-cntxt-userid).
  run get-db-num in parparentproc ( output v-cntxt-db-num).
end.
else do:
  { gbl/getcntxt.i get }
end.

&scop display-message ~
   if p-batch > 0 then do: ~
     run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input p-log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~). ~
   end. ~
   else do: ~
      run write-to-log in p-log-handle ( input ~{&my-message~}). ~
   end

FIND FIRST ub.clients No-LOCK
  WHERE ub.clients.obj-type = p-obj-type
    AND ub.clients.obj-code = p-obj-code
  No-ERROR.
assign
store-name = if available ub.clients
             then ub.clients.obj-name
             else (p-obj-type + string(p-obj-code))
.
{ gbl/hostname.i p-obj-type p-obj-code v-host-code v-host-name}

{ gbl/getsect.i run p-obj-type p-obj-code {&attr-report-obj} }
for each thbjattr_thbj-attr :
  if thbjattr_thbj-attr.prop-code = 'shft-qty'  then v-param_shft-qty = thbjattr_thbj-attr.property-value-character .
  if thbjattr_thbj-attr.prop-code = 'prt-z-no'  then v-param_prt-z-no = string(thbjattr_thbj-attr.property-value-logical) .
end.
if lookup( v-param_shft-qty, "system,state,state-all-per":U ) = 0 then do:
  assign
    v-param_shft-qty = "system":U
  .
end.
if lookup( v-param_prt-z-no, "yes,no,true,false":U ) = 0 then do:
  assign
    v-param_prt-z-no = "yes":U
  .
end.
define temp-table temp-shift-obj no-undo like ub.shift-obj
  FIELD num as integer
  INDEX ii IS UNIQUE num
.
if valid-handle(p-parent-handle)
and lookup("cb_write-report-error", p-parent-handle:internal-entries) > 0
and valid-handle(p-rebh) then do:
  v-write-xml-error = yes.
end.

RUN fmtcli-get-client IN THIS-PROCEDURE ( INPUT  p-obj-type
                                        , INPUT  p-obj-code
                                        ) .
assign
  v-obj-address = ( if v-fmtcli-index <> '':U then ( v-fmtcli-index ) else '':U )
                            + ( if v-fmtcli-full-addres <> '':U then ( v-fmtcli-full-addres ) else '':U )
  v-obj-phone   = ( if v-fmtcli-phone <> '':U then v-fmtcli-phone else '':U )
.

for each ub.shift-obj  no-lock
  where ub.shift-obj.obj-code   =  p-obj-code
    and ub.shift-obj.obj-type   =  p-obj-type
    and ub.shift-obj.shift-date >= X-date-Start
    and ub.shift-obj.shift-date <= X-date-End
:
  if ub.shift-obj.shift-date = X-date-Start and ub.shift-obj.shift-num < X-Shift-Start then next .
  if ub.shift-obj.shift-date = X-date-End   and ub.shift-obj.shift-num > X-Shift-End then next .

  if ub.shift-obj.status_ <> {&sht-closed} then do:
    &scop my-message  substitute("На объекте &1 смена &2 с датой начала &3&4"  + ~
                                "еще не закрыта!&4Сменный отчет сделать нельзя!"  ~
                              , store-name ~
                              ,ub.shift-obj.shift-num ~
                              ,string(ub.shift-obj.shift-date,"99/99/9999") ~
                              , ~{&new-line~})
    {&display-message}.
    if v-write-xml-error then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input {&severity-high}
                                                    ,input {&my-message}).
    end.
    RETURN.
  end.
  create temp-shift-obj .
  assign v-count = v-count + 1 .
  assign temp-shift-obj.num = v-count .
  buffer-copy ub.shift-obj to temp-shift-obj .
    if p-batch > 0
    and p-report-id  = "53/2040"
    then do:
    find first buf_shift where
            buf_shift.obj-type = p-obj-type
        and buf_shift.obj-code = p-obj-code
        and buf_shift.shift-date = x-date-end
        and buf_shift.shift-num = x-shift-end no-error.
    if not available buf_shift then do:
      create buf_shift.
      assign
      buf_shift.obj-type = p-obj-type
      buf_shift.obj-code = p-obj-code
      buf_shift.shift-date = ub.shift-obj.shift-date
      buf_shift.shift-num = ub.shift-obj.shift-num
      buf_shift.db-num = ub.clients.db-num
      buf_shift.obj-name = ub.clients.obj-name
      buf_shift.obj-address = v-obj-address
      buf_shift.obj-phone = v-obj-phone
      buf_shift.db-num = ub.clients.db-num
      buf_shift.shift-name = ub.shift-obj.shift-name
      buf_shift.base-code = p-base-code
      buf_shift.curr-abbr = p-curr-abbr
      .
      release buf_shift.
    end.
    &scop my-message substitute("&1&2 cмена &3 П.&4", p-obj-type, p-obj-code, string(x-date-end, "99/99/9999"), x-shift-end)
    {&display-message}.
  end.
  /* персонал */
  FOR EACH ub.shift-staff No-LOCK WHERE
          ub.shift-staff.obj-type   = p-obj-type AND
          ub.shift-staff.obj-code   = p-obj-code AND
          ub.shift-staff.shift-date = ub.shift-obj.shift-date AND
          ub.shift-staff.shift-num  = ub.shift-obj.shift-num AND
          ub.shift-staff.next-shift = no AND
          ub.shift-staff.staff-role = no and
          ub.shift-staff.psn-num    >= 0 :
    if lookup( {&space-char} + ub.shift-staff.name, for-opers ) = 0 then do:
      assign
        for-opers = for-opers + (if NOT first-oper then {&comma-char} else "") + {&space-char} + ub.shift-staff.name
        first-oper = if first-oper then no else first-oper .
      .
    end.
  END.
  FOR EACH ub.shift-staff No-LOCK WHERE
          ub.shift-staff.obj-type = p-obj-type AND
          ub.shift-staff.obj-code = p-obj-code AND
          ub.shift-staff.shift-date = temp-shift-obj.shift-date AND
          ub.shift-staff.shift-num  = temp-shift-obj.shift-num AND
          ub.shift-staff.next-shift = no AND
          ub.shift-staff.staff-role = yes and
          ub.shift-staff.psn-num    >= 0 :
    if lookup( {&space-char} + ub.shift-staff.name, for-mng ) = 0 then do:
      assign
        for-mng = for-mng + (if NOT first-mngr then {&comma-char} else "") + {&space-char} + ub.shift-staff.name
        first-mngr = if first-mngr then no else first-mngr
      .
    end.
  end.
end.
for-opers =  breakstr(for-opers, 44, input-output for-opers1, input-output for-opers2).

/* корректируем первую смену  */
find first temp-shift-obj where temp-shift-obj.num = 1 no-error .
if not available temp-shift-obj Then DO:
  &scop my-message substitute("На объекте &1 нет смены &2 с датой начала &3&4" + ~
                              "Исправьте запрашиваемые данные!" ~
                              , store-name ~
                              , X-shift-start ~
                              ,string(X-date-start,"99/99/9999") ~
                              , ~{&new-line~} )
  {&display-message}.
  if v-write-xml-error then do:
    run cb_write-report-error in p-parent-handle ( input p-rebh
                                                  ,input p-report-id
                                                  ,input ?
                                                  ,input {&severity-high}
                                                  ,input {&my-message}).
  end.
  RETURN.
End.
assign
  x-date-Start  = temp-shift-obj.shift-date
  X-Shift-Start = temp-shift-obj.shift-num
  v-open-date   = temp-shift-obj.open-date
  v-open-time   = temp-shift-obj.open-time
.
/* корректируем последнюю смену  */
find first temp-shift-obj  where temp-shift-obj.num = v-count no-error .
if available temp-shift-obj then do:
  assign
    x-date-End   = temp-shift-obj.shift-date
    X-Shift-End  = temp-shift-obj.shift-num
    v-close-date = temp-shift-obj.close-date
    v-close-time = temp-shift-obj.close-time
  .
end.
/* ищем следующюю смену и ее персонал */
FIND first next-shift-obj NO-LOCK
  WHERE next-shift-obj.obj-type   = temp-shift-obj.obj-type
    and next-shift-obj.obj-code   = temp-shift-obj.obj-code
    and next-shift-obj.shift-date = temp-shift-obj.shift-date
    and next-shift-obj.shift-num  = temp-shift-obj.shift-num
no-error .
FIND NEXT  next-shift-obj SHARE-LOCK WHERE next-shift-obj.obj-type = p-obj-type AND next-shift-obj.obj-code = p-obj-code use-index pi NO-ERROR.
FIND FIRST ub.shift-staff No-LOCK WHERE
          ub.shift-staff.obj-type   = p-obj-type AND
          ub.shift-staff.obj-code   = p-obj-code AND
          ub.shift-staff.shift-date = (if available next-shift-obj then next-shift-obj.shift-date else temp-shift-obj.shift-date) AND
          ub.shift-staff.shift-num  = (if available next-shift-obj then next-shift-obj.shift-num  else temp-shift-obj.shift-num) AND
          ub.shift-staff.next-shift = (if available next-shift-obj then no else yes) AND
          ub.shift-staff.staff-role = yes and
          ub.shift-staff.psn-num    >= 0 No-ERROR.
assign for-mng-next = if available ub.shift-staff then string(ub.shift-staff.name, "X(30)") else "".

run waitfram-show in this-procedure ({&MyWaitMess} ).

Line = fill("-", 230) .

assign
  p-z-number-list = "":U
.
if v-param_prt-z-no = "yes":U then do:
  for each temp-shift-obj
  :
    for each ub.chk-doc no-lock
      where ub.chk-doc.obj-type    = temp-shift-obj.obj-type
        and ub.chk-doc.obj-code    = temp-shift-obj.obj-code
        and ub.chk-doc.shift-date  = temp-shift-obj.shift-date
        and ub.chk-doc.shift-num   = temp-shift-obj.shift-num
        and ub.chk-doc.out-code   <> ?
      use-index shift
    :
      assign
        p-z-number-item = trim( string( ub.chk-doc.z-number, "->>>>>>>>>9":U ) )
      .
      if lookup( p-z-number-item,  p-z-number-list, " ":U ) = 0
        and ub.chk-doc.z-number <> 0
      then do:
          assign
            p-z-number-list = p-z-number-list + ( if p-z-number-list = "":U then "":U else " ":U ) + p-z-number-item
          .
      end.
    end. /* for each ub.chk-doc */
  end.
  if trim( p-z-number-list ) <> "":U then do:
    assign
      p-z-number-list = "Номера Z-отчетов: " + trim( p-z-number-list ) + "."
    .
  end.
end. /* if v-param_prt-z-no = "yes":U */

run prn-lib-open-stream  in this-procedure
  ( input parParentProc
  , input p-line-of-page
  , input yes /*p-is-stream*/
  , input no /*p-append*/
  ).
FORM HEADER
    Line format "x(198)":U                at  1
    skip substitute( "стр. &1", PAGE-NUMBER(PrnLibstream) ) AT 5 "Продолжение - на следующей странице" AT 35
    SKIP
    with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW STREAM PrnLibstream FRAME BottomFrame .

FORM HEADER
    skip
    "СМЕНУ СДАЛ : "   AT 15 for-mng      AT 29 format "X(39)"  '________________________' at 69
    "СМЕНУ ПРИНЯЛ : " AT 100 for-mng-next AT 116 format "X(39)"  '________________________' at 156
    skip
    with FRAME Bottom2Frame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW STREAM PrnLibstream FRAME Bottom2Frame .

for each sheetf
  where sheetf.sheet-num > 1
:
  delete sheetf.
end.
find first sheetf
  where sheetf.sheet-num = 1
  no-error.
assign
  sheetf.sizes = ""
.

run xl-shift-str in this-procedure ( output str1 ).

&scop l-kg (if p-weight = true then "кг" else "л")

if tog-1 = true then do:
  page stream PrnLibstream .
  run first-line in this-procedure ( input 1 ) no-error.
  assign
    Sheetf.MergeCellsH = "4:7,8:19,20:21"
    Sheetf.MergeCellsV = "1=1:2/2=1:2/3=1:2"
    Sheetf.Sizes       = "25,8,8,5,10,10,8,9,8,8,8,8,8,8,8,8,7,7,8,8,8"
  .
  assign
    pol2 = substitute( "&1 &2"
                       , (if v-param_shft-qty = "system"
                           then "РАСЧЕТНО-книжный ОСТАТОК на начало смены"
                           else "ФАКТИЧЕСКИЙ ОСТАТОК на начало смены"
                         )
                       , {&l-kg}
                      )
    pol16 = substitute( "&1 &2"
                        , ( if v-param_shft-qty = "system"
                              or v-param_shft-qty = "state-all-per"
                            then "РАСЧЕТНО-книжный"
                            else "РАСЧЕТНЫЙ" )
                        , {&l-kg}
                      )
    Sheetf.Excel-Column-Lable = "НАИМЕНОВАНИЕ ПРОДУКТА"                          + {&comma-char} +
                                pol2                                             + {&comma-char} +
                                substitute( "ПОСТУПИЛ за смену &1", {&l-kg} )    + {&comma-char} +
                                "ПОКАЗАТЕЛИ СЧЕТНЫХ МЕХАНИЗМОВ"                  + {&comma-char} +
                                                                                   {&comma-char} +
                                                                                   {&comma-char} +
                                                                                   {&comma-char} +
                                                                                   {&comma-char} +
                                                                                   {&comma-char} +
                                "ОСТАТОК НА КОНЕЦ СМЕНЫ"                         + {&comma-char} +
                                                                                   {&comma-char} +
                                                                                   {&comma-char} +
                                                                                   {&comma-char} +
                                                                                   {&comma-char} +
                                                                                   {&comma-char} +
                                                                                   {&comma-char} +
                                                                                   {&comma-char} +
                                                                                   {&comma-char} +
                                                                                   {&comma-char} +
                                "РЕЗУЛЬТАТЫ"                                     + {&comma-char} +
                                {&new-line}   +
                                                                                   {&comma-char} +
                                                                                   {&comma-char} +
                                                                                   {&comma-char} +
                                "N ТРК"                                          + {&comma-char} +
                                "На конец смены л"                               + {&comma-char} +
                                "На начало смены л"                              + {&comma-char} +
                                "РАСХОД л"                                       + {&comma-char} +
                                "N РЕЗ"                                          + {&comma-char} +
                                "ОБЩИЙ уровень включая воду см"                  + {&comma-char} +
                                "ВОДЫ уровень см"                                + {&comma-char} +
                                "ОБЩИЙ объем включая воду л"                     + {&comma-char} +
                                "ВОДЫ объем л"                                   + {&comma-char} +
                                "ФАКТ ОБЪЕМ в трубопроводе л"                    + {&comma-char} +
                                "ФАКТ ОБЪЕМ в резервуаре л"                      + {&comma-char} +
                                "ФАКТ ОБЪЕМ всего л"                             + {&comma-char} +
                                "ФАКТ ОБЪЕМ всего кг"                            + {&comma-char} +
                                "ФАКТ ПЛ-ТЬ  кг/л"                               + {&comma-char} +
                                "ФАКТ ТЕМП.  С"                                  + {&comma-char} +
                                pol16                                            + {&comma-char} +
                                substitute( "ИЗЛИШКИ &1", {&l-kg} )              + {&comma-char} +
                                substitute( "НЕДОСТАЧА &1", {&l-kg} )            +
                  {&new-line} +
                                '="1.1"'                                         + {&comma-char} +
                                '="1.2"'                                         + {&comma-char} +
                                '="1.3"'                                         + {&comma-char} +
                                '="1.4"'                                         + {&comma-char} +
                                '="1.5"'                                         + {&comma-char} +
                                '="1.6"'                                         + {&comma-char} +
                                '="1.7"'                                         + {&comma-char} +
                                '="1.8"'                                         + {&comma-char} +
                                '="1.9"'                                         + {&comma-char} +
                                '="1.10"'                                        + {&comma-char} +
                                '="1.11"'                                        + {&comma-char} +
                                '="1.12"'                                        + {&comma-char} +
                                '="1.13"'                                        + {&comma-char} +
                                '="1.14"'                                        + {&comma-char} +
                                '="1.15"'                                        + {&comma-char} +
                                '="1.15.1"'                                      + {&comma-char} +
                                '="1.15.2"'                                      + {&comma-char} +
                                '="1.15.3"'                                      + {&comma-char} +
                                '="1.16"'                                        + {&comma-char} +
                                '="1.17"'                                        + {&comma-char} +
                                '="1.18"'
    .


  run rep/extitle.p
    ( input 1
    ) no-error.
  run rep/r-shift1.p
    ( input parparentproc
     , input p-parent-handle
     , input p-log-handle
     , input p-cont-handle
     , input p-rebh
     , input p-report-id
     , input p-xsd-file
     , input p-log-file-name
     , input p-batch
     , input p-codex-id
     , input p-ruleset-id
     , input p-weight
     , input v-param_shft-qty
     , input p-obj-type
     , input p-obj-code
     , input p-z-number-list
     , input tog-1-pump-one
     , input tog-1-whole-gds
     , input tog-1-out-pump-with-icnt
    ) no-error.
end.

/*если нужна хоть какая разброска платежей по чекам то сделаем*/
if tog-2 or tog-3 or tog-4 or tog-8 then do:
  assign
  sheets = if tog-2 then 1000 else 0
  sheets = sheets + if tog-3 then 100 else 0
  sheets = sheets + if tog-4 then 10 else 0
  .
  if tog-3 then do:
    /*группы хотелось бы знать заранее*/
    run rep/r-shftgr.p
      ( input p-obj-type
       ,input p-obj-code
       ,input X-date-Start
       ,input X-Shift-Start
       ,input xClassify
       ,input xSortType
       ,input xtog-level
       ,input xvar-level
      ) no-error.

  end.
  run rep/r-shftc2.p (
                  INPUT p-obj-type
                 ,INPUT p-obj-code
                 ,INPUT X-date-start
                 ,INPUT X-Shift-Start
                 ,INPUT X-date-end
                 ,INPUT X-Shift-end
                 ,INPUT SHEETS
                 ,INPUT tog-2
                 ,INPUT tog-3
                 ,INPUT tog-4
                 ,INPUT tog-8
                 ,INPUT (Xclassify = "totals":U)
                 ,INPUT (x-selectgood = {&g-grp})
                 ,INPUT p-batch
                 ,input no )
  no-error.
  /*после этого появляются записи в таблицах treal-2 treal-3 treal-4 */

  FIND LAST  previous-shift-obj SHARE-LOCK WHERE
              previous-shift-obj.obj-type = p-obj-type AND
              previous-shift-obj.obj-code = p-obj-code AND
              ((previous-shift-obj.shift-date = X-date-start AND
              previous-shift-obj.shift-num < X-shift-start) OR
              previous-shift-obj.shift-date < X-date-start)
              use-index pi NO-ERROR.
  if available previous-shift-obj then do:
    assign
    v-previous-shift-date = previous-shift-obj.shift-date
    v-current-shift-date = X-date-start
    .
    run rep/chk-ahz.p (
                  input        p-obj-type
                  ,input        p-obj-code
                  ,input        yes            /* p-verify-detail     */
                  ,input        yes            /* p-verify-arh        */
                  ,input        no             /* p-verify-ahsp       */
                  ,input        no             /* p-verify-aht        */
                  ,input        (p-batch = integer({&repcalc-type-operator}))            /* p-check-act         */
                  ,input        v-cntxt-db-num /* p-check-act-db-num  */
                  ,input        v-cntxt-userid /* p-check-act-user-id */
                  ,input-output v-previous-shift-date
                  ,input-output v-current-shift-date
                  ,output       v-archive-ok
                  ,output       v-comment
                  ,output       v-can-print
                ) no-error .
    if error-status:error then do:
      &scop my-message substitute("&1 &2 &3&4Ошибка при вызове программы chk-ahz.p&4&5&4&6"  ~
                                  ,vss-workfile  ~
                                  ,vss-revision  ~
                                  ,vss-description  ~
                                  ,~{&new-line~} ~
                                  ,error-status :get-message(1)  ~
                                  ,return-value )
      {&display-message}.
      if v-write-xml-error then do:
        run cb_write-report-error in p-parent-handle ( input p-rebh
                                                      ,input p-report-id
                                                      ,input ?
                                                      ,input {&severity-high}
                                                      ,input {&my-message}).
      end.
      return error .
    end. /*if error-status:error then do:*/
    if X-date-start < v-previous-shift-date
    or X-date-start > v-current-shift-date  then do:
      &scop my-message substitute("Объект &1&2 Печать 2, 3 и 4 листа сменного отчета за выбранную дату невозможна&3"  + ~
                                  "Отсутствуют подробные складские архивы&3"  + ~
                                  "Возможные даты отчета: &4-&5&3&6&3" ~
                                  ,p-obj-type  ~
                                  ,p-obj-code  ~
                                  , ~{&new-line~} ~
                                  ,string(v-previous-shift-date, '99/99/9999':u) ~
                                  ,string(v-current-shift-date, '99/99/9999':u)  ~
                                  ,v-comment)
      {&display-message}.
      if v-write-xml-error then do:
        run cb_write-report-error in p-parent-handle ( input p-rebh
                                                      ,input p-report-id
                                                      ,input ?
                                                      ,input {&severity-high}
                                                      ,input {&my-message}).
      end.
      assign
      v-run-2-3-4 = no
      .
    end. /*if X-date-start < v-previous-shift-date*/
  end. /* if available previous-shift-obj */
end. /* if tog-2 = yes or tog-3 = yes or tog-4 = yes */

    {&pageExcel}
 if tog-2 = yes and v-run-2-3-4 = yes then do:
    page stream PrnLibStream .
    run first-line in this-procedure ( input 2 ) no-error.
    FInd first Sheetf where Sheetf.sheet-num = 2 No-ERROR.
    if not available sheetf then do:
      create sheetf.
      assign  Sheetf.Sheet-num = 2.
    end.
    assign
    Sheetf.MergeCellsH = "1:5,6:12,13:16,17:18/4:5,6:7,9:11"
    Sheetf.MergeCellsV = "1=2:3/2=2:3/3=2:3/8=2:3/12=2:3/13=2:3/14=2:3/15=2:3/16=2:3/17=2:3/18=2:3"
    Sheetf.Excel-Column-Lable = "ИНФОРМАЦИЯ О ПРОДУКТЕ" + {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} + /**/
                         "РАСШИФРОВКА ПОСТУПЛЕНИЯ" + {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} + /**/
                         "РАСШИФРОВКА РЕАЛИЗАЦИИ" + {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} + /**/
                         "ОСТАТОК НА КОНЕЦ" + {&comma-char} +
                          {&new-line} +
                         "НАИМЕНОВАНИЕ продукта" + {&comma-char} +
                         "КОД товара" + {&comma-char} +
                         "ЦЕНА розничная на конец смены" + {&comma-char} +
                         "ОСТАТОК НА НАЧАЛО" + {&comma-char} +
                         {&comma-char} + /**/
                         "ПОСТАВЩИК" +  {&comma-char} +
                         {&comma-char} + /**/
                         "НОМЕР документа прихода (ТТН)" + {&comma-char} +
                         "КОЛИЧЕСТВО" + {&comma-char} +
                         {&comma-char} +
                         {&comma-char} + /**/
                         "ТЕМПЕРАТУРА в цистерне в гр. С" + {&comma-char} +
                         "ТИП РАСХОДА (тип платежа)" + {&comma-char} +
                         "КОЛ-ВО в литрах" + {&comma-char} +
                         "КОЛ-ВО в килогр кг" + {&comma-char} +
                         "СУММА" + {&comma-char} +
                         "КОЛ-ВО в литрах л" + {&comma-char} +
                         "КОЛ-ВО в килогр кг" +
                         {&new-line} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         "ОБЪЕМ л" + {&comma-char} +
                         "МАССА кг " + {&comma-char} +
                         "Наименование" + {&comma-char} +
                         "Код" + {&comma-char} +
                         {&comma-char} +
                         "ОБЪЕМ л" + {&comma-char} +
                         "ПЛОТНОСТЬ кг/м3" + {&comma-char} +
                         "МАССА кг" + {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&new-line} +
                         '="2.1"' + {&comma-char} +
                         '="2.2"' + {&comma-char} +
                         '="2.3"' + {&comma-char} +
                         '="2.4"' + {&comma-char} +
                         '="2.5"' + {&comma-char} +
                         '="2.6"' + {&comma-char} +
                         '="2.7"' + {&comma-char} +
                         '="2.8"' + {&comma-char} +
                         '="2.9"' + {&comma-char} +
                         '="2.10"' + {&comma-char} +
                         '="2.11"' + {&comma-char} +
                         '="2.12"' + {&comma-char} +
                         '="2.13"' + {&comma-char} +
                         '="2.14"' + {&comma-char} +
                         '="2.15"' + {&comma-char} +
                         '="2.16"' + {&comma-char} +
                         '="2.17"' + {&comma-char} +
                         '="2.18"'
    Sheetf.Sizes = "12,9,8,9,9,18,9,14,8,5,8,5,19,9,9,12,9,9"
    .

  { rep/r-shfth.i r-shift2 }
  PUT STREAM PrnLibstream UNFORMATTED
    {&Header-Text2}
  .

  run rep/extitle.p
    ( input 2
    ) no-error.

  run rep/r-shift2.p
    ( input parparentproc
     ,input p-parent-handle
     ,input p-log-handle
     ,input p-cont-handle
     ,input p-rebh
     ,input p-report-id
     ,input p-xsd-file
     ,input p-log-file-name
     ,input p-batch
     ,input p-codex-id
     ,input p-ruleset-id
     ,input p-obj-type
     ,input p-obj-code
     ,input p-z-number-list
     ,input v-previous-shift-date
     ,input tog-2-cp-grp
    ) no-error.
  if error-status:error then do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
    {&display-message}.
  end.
End.

{&pageExcel}
if tog-3 = yes and v-run-2-3-4 = yes then do:
  page stream PrnLibstream .
  RUN first-line in this-procedure ( input 3) no-error.

  { rep/r-shfth.i r-shift3 }
  PUT STREAM PrnLibstream UNFORMATTED
    {&Header-Text3}
  .

  FInd first Sheetf where  Sheetf.sheet-num = 3 No-ERROR.
  if not available sheetf then do:
    create sheetf.
    assign Sheetf.Sheet-num = 3.
  end.

  assign
  Sheetf.MergeCellsH = "1:3,4:8,9:11,12:13/2:3,4:5,7:8"
  Sheetf.MergeCellsV = "1=2:3/6=2:3/9=2:3/10=2:3/11=2:3/12=2:3/13=2:3"
  Sheetf.Excel-Column-lable =
                         "ИНФОРМАЦИЯ О ТОВАРЕ" + {&comma-char} +
                         {&comma-char} +
                         {&comma-char} + /**/
                         "РАСШИФРОВКА ПОСТУПЛЕНИЯ" + {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} + /**/
                         "РАСШИФРОВКА РЕАЛИЗАЦИИ" + {&comma-char} +
                         {&comma-char} +
                         {&comma-char} + /**/
                         "ОСТАТОК НА КОНЕЦ" + {&comma-char} +
                         {&new-line} + /**/
                         "НАИМЕНОВАНИЕ группы товаров" + {&comma-char} +
                         "ОСТАТОК НА НАЧАЛО" + {&comma-char} +
                         {&comma-char} + /**/
                         "ПОСТАВЩИК" + {&comma-char} +
                         {&comma-char} + /**/
                         "НОМЕР документа прихода (ТТН)" + {&comma-char} +
                         "ПОСТУПИЛО" + {&comma-char} +
                         {&comma-char} +
                         "ТИП РАСХОДА (тип платежа)" + {&comma-char} +
                         "КОЛ-ВО" + {&comma-char} +
                         "СУММА (цены док-та)" + {&comma-char} +
                         "КОЛ-ВО" + {&comma-char} +
                         "СУММА (прод. цены)" + {&new-line} + /**/
                         {&comma-char} +
                         "КОЛ-ВО" + {&comma-char} +
                         "СУММА (прод.цены)" +  {&comma-char} +
                         "Наименование" +  {&comma-char} +
                         "Код" +  {&comma-char} +
                         {&comma-char} +
                         "КОЛ-ВО" + {&comma-char} +
                         "СУММА (учет. цены)" +  {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&comma-char} +
                         {&new-line} + /**/
                         '="3.1"' + {&comma-char} +
                         '="3.2"' + {&comma-char} +
                         '="3.3"' + {&comma-char} +
                         '="3.4"' + {&comma-char} +
                         '="3.5"' + {&comma-char} +
                         '="3.6"' + {&comma-char} +
                         '="3.7"' + {&comma-char} +
                         '="3.8"' + {&comma-char} +
                         '="3.9"' + {&comma-char} +
                         '="3.10"' + {&comma-char} +
                         '="3.11"' + {&comma-char} +
                         '="3.12"' + {&comma-char} +
                         '="3.13"'
  Sheetf.SIzes = "32,9,12,20,9,16,8,11,20,9,12,9,12"
  .
  run rep/extitle.p
    ( input 3
    ) no-error.
  run rep/r-shift3.p (
                  input parparentproc
                 ,input p-parent-handle
                 ,input p-log-handle
                 ,input p-cont-handle
                 ,input p-rebh
                 ,input p-report-id
                 ,input p-xsd-file
                 ,input p-log-file-name
                 ,input p-batch
                 ,input p-codex-id
                 ,input p-ruleset-id
                 ,input p-obj-type
                 ,input p-obj-code
                 ,input p-z-number-list
                 ,input xClassify
                 ,input xSortType
                 ,input xtog-level
                 ,input xvar-level
                 ,input v-previous-shift-date
                  ) no-error.
  if error-status:error then do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
    {&display-message}.
  end.
End.

  {&pageExcel}
if tog-4 = yes and v-run-2-3-4 = yes then do:
  page stream PrnLibstream .
  run first-line in this-procedure ( input 4 ) no-error.

  { rep/r-shfth.i r-shift4 }
  PUT STREAM PrnLibstream UNFORMATTED
    {&Header-Text4}
  .

  FInd first Sheetf where Sheetf.sheet-num = 4 No-ERROR.
  if not available sheetf then do:
    create Sheetf.
    assign Sheetf.Sheet-num = 4.
  end.

   assign
     Sheetf.MergeCellsH        = "1:3,4:6":U
     Sheetf.MergeCellsV        = "":U
     Sheetf.EXCEl-COLUMn-LABLE =
                      "ИНФОРМАЦИЯ ОБ УСЛУГЕ" + {&comma-char} +
                      {&comma-char} +
                      {&comma-char} + /**/
                      "РАСШИРОВКА РЕАЛИЗАЦИИ УСЛУГ" + {&comma-char} +
                      {&comma-char} +
                      {&new-line} + /**/
                      "НАИМЕНОВАНИЕ услуги" + {&comma-char} +
                      "КОД услуги  " + {&comma-char} +
                      "ЦЕНА рознич. на конец смены" + {&comma-char} +
                      "ТИП РАСХОДА (тип платежа)" + {&comma-char} +
                      "КОЛ-ВО" + {&comma-char} +
                      "СУММА" +
                      {&new-line} +
                      '="4.1"' + {&comma-char} +
                      '="4.2"' + {&comma-char} +
                      '="4.3"' + {&comma-char} +
                      '="4.4"' + {&comma-char} +
                      '="4.5"' + {&comma-char} +
                      '="4.6"'
    Sheetf.SIzes = "32,9,8,19,9,15"
  .
  run rep/extitle.p
    ( input 4
    ) no-error.
  run rep/r-shift4.p (
                  input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input p-cont-handle
                  ,input p-rebh
                  ,input p-report-id
                  ,input p-xsd-file
                  ,input p-log-file-name
                  ,input p-batch
                  ,input p-codex-id
                  ,input p-ruleset-id
                 ,input p-obj-type
                 ,input p-obj-code
                 ,input p-z-number-list
                 ,input v-previous-shift-date) no-error.
  if error-status:error then do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
    {&display-message}.
  end.
End.

  {&pageExcel}
  if tog-5 = yes then do:
    page stream PrnLibstream .
    run first-line in this-procedure ( input 5 ) no-error.

    { rep/r-shfth.i r-shift5 }
    PUT STREAM PrnLibstream UNFORMATTED
      {&Header-Text5}
    .

    FInd first Sheetf where  Sheetf.sheet-num = 5 No-ERROR.
    if not available Sheetf then do:
      create sheetf.
      assign Sheetf.Sheet-num = 5.
    end.

 assign
 Sheetf.MergeCellsH = "1:7/3:4,5:6"
 Sheetf.MergeCellsV = "1=2:3/2=2:3/7=2:3"
 Sheetf.EXCEl-COLUMn-LABLE =
                      "ДВИЖЕНИЕ МАТЕРИАЛЬНЫХ ЦЕННОСТЕЙ" + {&comma-char} +
                      {&comma-char} +
                      {&comma-char} +
                      {&comma-char} +
                      {&comma-char} +
                      {&comma-char} +
                      {&new-line} + /**/
                      "НАИМЕНОВАНИЕ материальных ценностей" + {&comma-char} +
                      "ОСТАТОК НА НАЧАЛО СМЕНЫ" + {&comma-char} +
                      "ПОЛУЧЕНО" + {&comma-char} +
                      {&comma-char} + /**/
                      "ИНКАССИРОВАНО" + {&comma-char} +
                      {&comma-char} +
                      "ОСТАТОК НА КОНЕЦ СМЕНЫ" +
                      {&new-line} +
                      {&comma-char} +
                      {&comma-char} +
                      "Выручка за смену" + {&comma-char} +
                      "Прочие источники" + {&comma-char} +
                      "в банк " + {&comma-char} +
                      "Прочие контрагенты" + {&comma-char} +
                      {&new-line} +
                      '="5.1"' + {&comma-char} +
                      '="5.2"' + {&comma-char} +
                      '="5.3"' + {&comma-char} +
                      '="5.4"' + {&comma-char} +
                      '="5.5"' + {&comma-char} +
                      '="5.6"' + {&comma-char} +
                      '="5.7"'
 Sheetf.SIzes = "32,15,14,14,14,14,15"
 .
  run rep/extitle.p
    ( input 5
    ) no-error.
 run rep/r-shift5.p (
                  input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input p-cont-handle
                  ,input p-rebh
                  ,input p-report-id
                  ,input p-xsd-file
                  ,input p-log-file-name
                  ,input p-batch
                  ,input p-codex-id
                  ,input p-ruleset-id
                 ,input p-obj-type
                 ,input p-obj-code
                 ) no-error.
  if error-status:error then do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
    {&display-message}.
  end.

End.

  {&pageExcel}
if tog-6 = yes then DO:
  page stream PrnLibstream .
  run first-line in this-procedure ( input 6 ) no-error.
  FInd first Sheetf where Sheetf.sheet-num = 6 No-ERROR.
  if not available sheetf then do:
    create sheetf.
    assign Sheetf.Sheet-num = 6.
  end.

  assign
   Sheetf.EXCEl-COLUMn-LABLE = "Простои АЗК, "
   Sheetf.SIzes = "100,5"
 .
  run rep/extitle.p
    ( input 6
    ) no-error.

 put stream PrnLibstream  skip
    Line format "x(198)":U skip
    "П Р О С Т О И     А З К" format "x(40)":U at 90 skip
    Line format "x(198)":U skip( 3 )
  .

   define buffer buf_rvs-doc for ub.rvs-doc .

   define variable sstr  as character no-undo  .
   define variable sstr1 as character no-undo  .
   define variable sstr2 as character no-undo  .

   for each temp-shift-obj :
     for each  buf_rvs-doc no-lock
       where buf_rvs-doc.obj-type   = p-obj-type
         and buf_rvs-doc.obj-code   = p-obj-code
         and buf_rvs-doc.shift-date = temp-shift-obj.shift-date
         and buf_rvs-doc.shift-num  = temp-shift-obj.shift-num
         and buf_rvs-doc.status_    = {&fact}
     :
       if buf_rvs-doc.PS <> '@' then do:
         if v-count = 1 then  assign sstr2 = buf_rvs-doc.PS .
         else   assign sstr2 = "СМЕНА:" + string (temp-shift-obj.shift-name) + " ОТ " + String( temp-shift-obj.open-date , "99/99/9999") + ' ' + String ( temp-shift-obj.open-time,"hh:mm") + ' ' + buf_rvs-doc.PS .

         do while sstr2 <> "" :
           assign sstr = sstr2.
           sstr1 = breakstr(  sstr, 198, input-output sstr1, input-output sstr2 ).
           put stream PrnLibstream sstr1 format "X(198)" skip .
         end. /* do while ... */
         {&putExcel} sstr2 {&new-line} .
       end.
     end.
   end.
End.

  {&pageExcel}
if tog-7 = yes then DO:
    page stream PrnLibStream .
    RUN first-line in this-procedure ( input 7 ) no-error.

    { rep/r-shfth.i r-shift7 }
    PUT STREAM PrnLibStream UNFORMATTED
      {&Header-Text7}
    .

    FInd first Sheetf where  Sheetf.sheet-num = 7 No-ERROR.
    if not available sheetf then do:
      create sheetf.
      assign Sheetf.Sheet-num = 7.
    end.

    assign
      Sheetf.MergeCellsH = "1:5/4:5"
      Sheetf.MergeCellsV = "1=2:4/2=2:4/3=2:4/4=2:3"
      Sheetf.EXCEl-COLUMn-LABLE =
                      "ПОГРЕШНОСТИ ОБЪЕМОМЕРОВ ТРК" +
                      {&comma-char} +
                      {&comma-char} +
                      {&comma-char} +
                      {&comma-char} +
                      {&new-line} + /**/
                      "№ ТРК" + {&comma-char} +
                      "№ ПИСТОЛЕТА" + {&comma-char} +
                      "НАИМЕНОВАНИЕ топлива" + {&comma-char} +
                      'ВЕЛИЧИНА погрешности ТРК "+" недолив "-" перелив' +
                      {&new-line} +
                      {&comma-char} +
                      {&comma-char} +
                      {&comma-char} +
                      {&new-line} +
                      {&comma-char} +
                      {&comma-char} +
                      {&comma-char} +
                      "мл" + {&comma-char} +
                      "%"
    Sheetf.SIzes = "15,15,30,14,14"
  .
  run rep/extitle.p
    ( input 7
    ) no-error.
  run rep/r-shift7.p
    ( input parparentproc
     ,input p-parent-handle
     ,input p-log-handle
     ,input p-cont-handle
     ,input p-rebh
     ,input p-report-id
     ,input p-xsd-file
     ,input p-log-file-name
     ,input p-batch
     ,input p-codex-id
     ,input p-ruleset-id
     ,input p-obj-type
     ,input p-obj-code
     ,input v-previous-shift-date
    ) no-error.
  if error-status:error then do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
    {&display-message}.
  end.
End.


{&pageExcel}
if tog-8 then DO:
    page stream PrnLibstream .
    RUN first-line(8) no-error.

    { rep/r-shfth.i r-shift8 }
    PUT STREAM PrnLibstream UNFORMATTED
      {&Header-Text8}
    .

    FInd first Sheetf where  Sheetf.sheet-num = 8 No-ERROR.
    if not available sheetf then do:
      create sheetf.
      assign Sheetf.Sheet-num = 8.
    end.
    assign
      Sheetf.MergeCellsH = ""
      Sheetf.MergeCellsV = "1=1:2"
      Sheetf.EXCEl-COLUMn-LABLE = "Тип оплаты" + {&comma-char}
      Sheetf.SIzes = "15"
    .
    for each treal-8 no-lock where
            treal-8.gds-code > 0
        and treal-8.cpay-code = 0
        and treal-8.curr-code = 0
        and treal-8.cli-type = '':U
        and treal-8.cli-code = 0
        ,
       first buf_goods no-lock where
                  buf_goods.gds-code = treal-8.gds-code:
      v-ii = v-ii + 1.
      assign
      Sheetf.MergeCellsH = SHeetf.mergeCellsh + substitute("&1&2:&3"
                                                           ,(if v-ii = 1
                                                           then '':U
                                                           else ",")
                                                           ,v-ii * 2
                                                           ,v-ii * 2 + 1)
      Sheetf.EXCEl-COLUMn-LABLE = Sheetf.EXCEl-COLUMn-LABLE + buf_goods.chk-name + {&comma-char} + {&comma-char}
      v-str2 = v-str2 + "Литры" + {&comma-char} + "{&abbr_rubli}" + {&comma-char}
      Sheetf.SIzes = Sheetf.SIzes +  {&comma-char} + "7,7":U
      .
    end.
    assign
    sheetf.MergeCellsH = SHeetf.mergeCellsh + (if SHeetf.mergeCellsh = '':U
                                               then '':U
                                               else  {&comma-char}) +
                                              substitute( "&1:&2"
                                              ,(v-ii + 1) * 2
                                              ,(v-ii + 1) * 2 + 1)
    Sheetf.EXCEl-COLUMn-LABLE = Sheetf.EXCEl-COLUMn-LABLE +  "ИТОГО" + {&comma-char} +
                                {&new-line} +
                                {&comma-char} + v-str2 + "Литры" + {&comma-char} + "{&abbr_rubli}"
    Sheetf.SIzes = Sheetf.SIzes +  {&comma-char} + "7,7":U
  .
  run rep/extitle.p
    ( input 8
    ) no-error.
  run rep/r-shift8.p (
                     input parparentproc
                    ,input p-parent-handle
                    ,input p-log-handle
                    ,input p-cont-handle
                    ,input p-rebh
                    ,input p-report-id
                    ,input p-xsd-file
                    ,input p-log-file-name
                    ,input p-batch
                    ,input p-codex-id
                    ,input p-ruleset-id
                    ,input p-z-number-list
                    ,input v-previous-shift-date ) no-error.
  if error-status:error then do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
    {&display-message}.
  end.
End.


{&pageExcel}
if tog-9 then DO:
   page stream PrnLibstream .
   RUN first-line(9) no-error.
   { rep/r-shfth.i r-shift9 }

   PUT STREAM PrnLibstream UNFORMATTED {&Header-Text9}.

   find first Sheetf
        where  Sheetf.sheet-num = 9
        no-error
        .
   if not available sheetf
   then do:
      create sheetf.
      assign
         Sheetf.Sheet-num = 9
      .
   end.
   assign
      Sheetf.EXCEl-COLUMN-LABLE =
                     "НАИМЕНОВАНИЕ топлива" + {&comma-char} +
                     "№ ТРК"                + {&comma-char} +
                     "№ ПИСТОЛЕТА"          + {&comma-char} +
                     "Счетчик на начало"    + {&comma-char} +
                     "Счетчик на конец"     + {&comma-char} +

                     "Оборот"               + {&comma-char} +
                     "Касса"                + {&comma-char} +
                     "Техпролив"            + {&comma-char} +
                     "Разница"              + {&comma-char} +
                     "Сброс (не пролито)"   + {&comma-char} +
                     "Сброс (пролито)"      + {&comma-char} +
                     "Перелив"              + {&comma-char} +
                     "Перевод  транзакции"  + {&comma-char} +
                     {&new-line} +
                     '="9.1"'  + {&comma-char} +
                     '="9.2"'  + {&comma-char} +
                     '="9.3"'  + {&comma-char} +
                     '="9.4"'  + {&comma-char} +
                     '="9.5"'  + {&comma-char} +
                     '="9.6"'  + {&comma-char} +
                     '="9.7"'  + {&comma-char} +
                     '="9.8"'  + {&comma-char} +
                     '="9.9"'  + {&comma-char} +
                     '="9.10"' + {&comma-char} +
                     '="9.11"' + {&comma-char} +
                     '="9.12"' + {&comma-char} +
                     '="9.13"'
      Sheetf.SIzes = "30,5,5,15,15,15,15,15,15,15,15,15,15"
   .
   run rep/extitle.p ( INPUT 9) no-error.
   run rep/r-shift9.p   (
                         input parparentproc
                        ,input p-parent-handle
                        ,input p-log-handle
                        ,input p-cont-handle
                        ,input p-rebh
                        ,input p-report-id
                        ,input p-xsd-file
                        ,input p-log-file-name
                        ,input p-batch
                        ,input p-codex-id
                        ,input p-ruleset-id
                        ,INPUT p-obj-type
                        , INPUT p-obj-code
                        , INPUT x-date-Start
                        , INPUT x-Shift-Start
                        , INPUT x-date-End
                        , INPUT x-Shift-End
                        , input tog-1-out-pump-with-icnt
                  ) no-error .
  if error-status:error then do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
    {&display-message}.
  end.
    run last-line-XL in this-procedure .
End. /* tog-9 */

{&pageExcel}
if tog-10 then DO:
   page stream PrnLibstream .
   RUN first-line(10) no-error.
   { rep/r-shfth.i r-shift10 }

   PUT STREAM PrnLibstream UNFORMATTED {&Header-Text10}.

   find first Sheetf
        where  Sheetf.sheet-num = 10
        no-error
        .
   if not available sheetf
   then do:
      create sheetf.
      assign
         Sheetf.Sheet-num = 10
      .
   end.
   assign
      Sheetf.EXCEl-COLUMN-LABLE =
                     "Топливо"              + {&comma-char} +
                     "Код"                  + {&comma-char} +
                     "Тип оплаты"           + {&comma-char} +
                     "тип скидки"           + {&comma-char} +
                     "Кол-во(лт)"           + {&comma-char} +
                     "Сумма брутто"         + {&comma-char} +
                     "Скидка"               + {&comma-char} +
                     "Сумма нетто"          + {&comma-char} +
                     {&new-line} +
                     '="10.1"'  + {&comma-char} +
                     '="10.2"'  + {&comma-char} +
                     '="10.3"'  + {&comma-char} +
                     '="10.4"'  + {&comma-char} +
                     '="10.5"'  + {&comma-char} +
                     '="10.6"'  + {&comma-char} +
                     '="10.7"'  + {&comma-char} +
                     '="10.8"'
      Sheetf.SIzes = "30,15,15,15,15,15,15,15"
   .
   run rep/extitle.p ( INPUT 10) no-error.
   run rep/r-shift10.p   (
                         input parparentproc
                        ,input p-parent-handle
                        ,input p-log-handle
                        ,input p-cont-handle
                        ,input p-rebh
                        ,input p-report-id
                        ,input p-xsd-file
                        ,input p-log-file-name
                        ,input p-batch
                        ,input p-codex-id
                        ,input p-ruleset-id
                        ,INPUT p-obj-type
                        ,INPUT p-obj-code
                        ,INPUT x-date-Start
                        ,INPUT x-Shift-Start
                        ,INPUT x-date-End
                        ,INPUT x-Shift-End
                  ) no-error .
  if error-status:error then do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
    {&display-message}.
  end.
End. /* tog-10 */


{&closeExcel}
HIDE STREAM PrnLibstream FRAME BottomFrame .

Output stream PrnLibstream close.
run waitfram-hide in this-procedure .
if p-batch = integer({&repcalc-type-operator}) then do:
  run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
end.
else do:
  if p-report-id  <> "53/2040" then do:
    /*сразу печатаем на принтер проверка на q-print внутри*/
    run reprumpr_print-printer in this-procedure ( input 7 /*font*/
                                                  ,input 2 /*flags*/
                                                  ) no-error.
    if error-status:error then do:
      &scop my-message "Печать на принтер завершилась ошибкой..."
      {&display-message}.
    end.
  end.
  if p-plain-txt then do:
    run reprumpr_print-plain-text in this-procedure (
                                                      input p-dir-name
                                                     ,input '' /*у нас по расписанию нет печати в текст*/
                                                     ,input substitute("shift-report_&1&2_&3&4&5_&6.txt"
                                                                        , p-obj-type
                                                                        , p-obj-code
                                                                        , string(year(X-date-end), "9999")
                                                                        , string(month(X-date-end), "99")
                                                                        , string(day(X-date-end), "99")
                                                                        , X-shift-end
                                                                        )
                                                      ,input 8 /*p-disabled-options*/
                                                      ,input 7  /*p-fontnumber*/
                                                   ) no-error.
    if error-status:error then do:
      &scop my-message return-value
      {&display-message}.
    end.
  end.
  if p-xls then do:
    run reprumpr_print-xls in this-procedure (
                                               input p-dir-name
                                               ,input '' /* у нас по расписаю нет печати в xls*/
                                               ,input substitute("shift-report_&1&2_&3&4&5_&6.xls"
                                                  , p-obj-type
                                                  , p-obj-code
                                                  , string(year(X-date-end), "9999")
                                                  , string(month(X-date-end), "99")
                                                  , string(day(X-date-end), "99")
                                                  , X-shift-end
                                                  )
                                                ,input 8 /*p-disabled-options*/
                                                ,input 7  /*p-fontnumber*/
                                                ) no-error.
    if error-status:error then do:
      &scop my-message return-value
      {&display-message}.
  end.
end.
end.
if p-report-id  = "53/2040" then do:
  run print-to-dataset in this-procedure .
end . /*if p-batch*/


procedure first-line :
  define input parameter  vartog as integer no-undo .

  PUT STREAM PrnLibstream UNFORMATTED
    string(v-host-name,"x(60)")      at 1                                      "СТАРШИЙ СМЕНЫ: " at 134 for-mng    at 150
    string(store-name,"x(60)") at 1  "С М Е Н Н Ы Й  О Т Ч Е Т"    at 87       "ОПЕРАТОРЫ: "     at 138 for-opers1 at 150
                    "Ч А С Т Ь  № " + string( vartog )         at 94                                for-opers2 at 150
  .
  find first temp-shift-obj  where temp-shift-obj.num = 1 .
  if v-count = 1 then do:
    PUT STREAM PrnLibstream UNFORMATTED
      "СМЕНА:" + string (temp-shift-obj.shift-name) + " ОТ " + String( v-open-date , "99/99/9999") + ' ' + String ( v-open-time,"hh:mm")  at 85
      "СМЕНА ЗАКРЫТА: " + string( v-close-date,"99/99/9999") + " " +  string(v-close-time,"hh:mm")        at 84 skip
    .
  end.
  else do:
    PUT STREAM PrnLibstream UNFORMATTED
      "СМЕНЫ С: " + string (temp-shift-obj.shift-name) + " ОТ " + String( temp-shift-obj.open-date , "99/99/9999") + ' ' + String ( temp-shift-obj.open-time,"hh:mm")  at 85  skip
    .
    find first temp-shift-obj where temp-shift-obj.num = v-count .
    PUT STREAM PrnLibstream UNFORMATTED
      "ПО: " + string (temp-shift-obj.shift-name) + " ОТ " + String( temp-shift-obj.open-date , "99/99/9999") + ' ' + String ( temp-shift-obj.open-time,"hh:mm") +
      " ЗАКРЫТА " + string( temp-shift-obj.close-date,"99/99/9999") + " " +  string(temp-shift-obj.close-time,"hh:mm")     at 90      skip
    .
  end.
End procedure.


/*procedure first-line-XL :*/
/*define input parameter  vartog as integer no-undo .*/
/*{&putexcel}*/
/*  string(v-host-name,"x(60)") {&tabulation}   fill({&tabulation}, 11)  "СТАРШИЙ СМЕНЫ: "  {&tabulation}  for-mng  skip*/
/*  string(store-name, "x(60)")       fill({&tabulation}, 6)  "С М Е Н Н Ы Й  О Т Ч Е Т"          fill({&tabulation}, 5)  "ОПЕРАТОРЫ: " skip*/
/*  fill({&tabulation}, 13)  for-opers1 skip*/
/*  fill({&tabulation}, 7)  ("Ч А С Т Ь  № " + string( vartog ))   fill({&tabulation}, 6)  for-opers2  skip .*/
/*  find first temp-shift-obj  where temp-shift-obj.num = 1  .*/
/*  if v-count = 1 then do:*/
/*{&putexcel}*/
/*    fill({&tabulation}, 7)   ("СМЕНА:" + string (temp-shift-obj.shift-name)) {&tabulation}*/
/*    ("ОТ " + String(v-open-date, "99/99/9999"))  {&tabulation}  (String(v-open-time, "hh:mm")) skip*/
/*    fill({&tabulation}, 7)  "СМЕНА ЗАКРЫТА: " {&tabulation}  string(v-close-date, "99/99/9999")  {&tabulation}  string(v-close-time, "hh:mm") skip .*/
/*  end.*/
/*  else do:*/
/*{&putexcel}*/
/*    fill({&tabulation}, 7)   ("СМЕНЫ С:" + string (temp-shift-obj.shift-name)) {&tabulation} ("ОТ " + String(temp-shift-obj.open-date, "99/99/9999"))  {&tabulation}  (String(temp-shift-obj.open-time, "hh:mm")) skip .*/
/*    find first temp-shift-obj  where temp-shift-obj.num = v-count  .*/
/*{&putexcel}*/
/*    fill({&tabulation}, 7)   ("ПО:" + string (temp-shift-obj.shift-name)) {&tabulation} ("ОТ " + String(temp-shift-obj.open-date, "99/99/9999"))  {&tabulation}  (String(temp-shift-obj.open-time, "hh:mm") +*/
/*      " ЗАКРЫТА " + string( temp-shift-obj.close-date,"99/99/9999") + " " +  string(temp-shift-obj.close-time,"hh:mm"))  skip*/
/*    .*/
/*  end.*/
/*End procedure.*/


procedure last-line-XL :
   {&putexcel}
      skip(2)
      "Смену сдал" {&tabulation}   fill("_":U, 21) {&tabulation} {&tabulation} "Смену принял"  {&tabulation}  fill("_":U, 21)  skip
      .

End procedure.


procedure xl-shift-str :

define output parameter p-str as character no-undo .

do
on error undo, return error return-value
:
  find first temp-shift-obj
    where temp-shift-obj.num = 1
    .
  if v-count = 1 then do:
    assign
      p-str = substitute( "Смена: &1 от &2 &3. Смена закрыта: &4 &5"
                          ,string( temp-shift-obj.shift-name )
                          ,string( temp-shift-obj.open-date , "99/99/9999" )
                          ,string( temp-shift-obj.open-time , "HH:MM" )
                          ,string( temp-shift-obj.close-date , "99/99/9999" )
                          ,string( temp-shift-obj.close-time , "HH:MM" )
                        )
    .
  end.
  else do:
    assign
      p-str = substitute( "Смены с &1 от &2 &3 закрытой &4 &5"
                          ,string( temp-shift-obj.shift-name )
                          ,string( temp-shift-obj.open-date , "99/99/9999" )
                          ,string( temp-shift-obj.open-time , "HH:MM" )
                          ,string( temp-shift-obj.close-date , "99/99/9999" )
                          ,string( temp-shift-obj.close-time , "HH:MM" )
                        )
    .
    find first temp-shift-obj
      where temp-shift-obj.num = v-count
      .
    assign
      p-str = substitute( "&1 по &2 от &3 &4 закрытой &5 &6"
                          ,p-str
                          ,string( temp-shift-obj.shift-name )
                          ,string( temp-shift-obj.open-date , "99/99/9999" )
                          ,string( temp-shift-obj.open-time , "HH:MM" )
                          ,string( temp-shift-obj.close-date , "99/99/9999" )
                          ,string( temp-shift-obj.close-time , "HH:MM" )
                        )
    .
  end.
end.

end procedure. /* xl-shift-str */


procedure print-to-dataset :
define variable glog as logical no-undo .
define buffer buf_temp-xml-tables for temp-xml-tables.
if p-report-id  = "53/2040" then do:
_xml-tables:
for each buf_temp-xml-tables:
  case buf_temp-xml-tables.tbl-name:
    when "shift" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                      buffer shiftt:handle
                                                    , yes /*append-mode*/
                                                    , no /*replace-mode*/
                                                    , yes /*loose-mode*/
                                                    ) no-error.
    end.
    when "shift-pgds" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                      buffer shift-pgdst:handle
                                                    , yes /*append-mode*/
                                                    , no /*replace-mode*/
                                                    , yes /*loose-mode*/
                                                    ) no-error.
    end.
    when "shift-pgds-in" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                      buffer shift-pgds-int:handle
                                                    , yes /*append-mode*/
                                                    , no /*replace-mode*/
                                                    , yes /*loose-mode*/
                                                    ) no-error.
    end.
    when "shift-pgds-out" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                      buffer shift-pgds-outt:handle
                                                    , yes /*append-mode*/
                                                    , no /*replace-mode*/
                                                    , yes /*loose-mode*/
                                                    ) no-error.
    end.
    when "shift-grp" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                      buffer shift-grpt:handle
                                                    , yes /*append-mode*/
                                                    , no /*replace-mode*/
                                                    , yes /*loose-mode*/
                                                    ) no-error.
    end.
    when "shift-grp-in" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                      buffer shift-grp-int:handle
                                                    , yes /*append-mode*/
                                                    , no /*replace-mode*/
                                                    , yes /*loose-mode*/
                                                    ) no-error.
    end.
    when "shift-grp-out" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                      buffer shift-grp-outt:handle
                                                    , yes /*append-mode*/
                                                    , no /*replace-mode*/
                                                    , yes /*loose-mode*/
                                                    ) no-error.
    end.
    otherwise do:
      next _xml-tables.
    end.
  end case.
  if error-status:error
  or not glog
  then do:
    if v-write-xml-error then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input {&severity-high}
                                                    ,input substitute("Ошибка при сохранении в отчет данных по &1&2 смена от &3 П.&4 - таблица &8&5&6&5&7&5"
                                                                     , p-obj-type
                                                                     , p-obj-code
                                                                     , X-date-end
                                                                     , X-shift-end
                                                                     , {&new-line}
                                                                     , error-status:get-message(1)
                                                                     , return-value
                                                                     , buf_temp-xml-tables.tbl-name
                                                                     )).
    end.
  end.
end.
end. /*if p-report-id  = "53/2040" then do:*/
end procedure. /* print-to-dataset */
