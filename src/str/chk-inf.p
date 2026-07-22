block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chk-inf.p $
$Archive: str/chk-inf.p $

Информация по чекам и продажам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/16/06
Author: Bakhtadze Natalya
Creation date: 01/16/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .


define input parameter interface as logical no-undo.
define input parameter from-ink as logical no-undo.
define input parameter p-doc-rec as recid no-undo .
define output parameter v-notes as character no-undo .
/*есть неучтенные чеки*/
define output parameter not-all-saled-chk as logical init no.
/*есть ошибочные чеки*/
define output parameter not-all-normal-chk as logical init no.
/*есть незакрытые продажи*/
define output parameter not-all-inkas-closed as logical no-undo init no.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-inf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chk-inf.p $":U .
define variable vss-description as character no-undo init "Информация по чекам и продажам".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ str/shftnmef.i inkas shift-name }
{ gbl/getcntxt.i def }

define variable not-saled as char no-undo.
define variable not-saled-err as char no-undo.
define variable inkas-ch as char no-undo.
define variable current-store-type like ub.inkas.obj-type no-undo.
define variable current-store-code like ub.inkas.obj-code no-undo.
/*использовать смены на кассе для данного объекта*/
define variable cas-shft as logical no-undo init no.
/*использовать смены для данного объекта*/
define variable l-shift-on as logical no-undo init no.
define variable conf-attr as char no-undo.                  /* для чтения параметра конфигурации */
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.
define variable chk-inf as logical no-undo init yes.
define variable v-shift-str as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .

{ gbl/waitfram.i }

{ gbl/getcntxt.i get }

if v-cntxt-db-num-obj <> v-cntxt-db-num then do:
  message
  substitute("Нельзя получить информацию по чекам в чужой БД&1" +
              "№ БД объекта &2, № текущей БД &3"
              , {&new-line}
              , v-cntxt-db-num-obj
              , v-cntxt-db-num)
  view-as alert-box error .
  return.
end.


run adm/shattri.p (
    input "get":U
    ,input  p-curr-obj-type
    ,input  p-curr-obj-code
    ,input  {&attr-chk-view}
    ,input  {&attr-chk-view_chk-inf} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error then
assign
chk-inf = v-value-logical.
delete object v-tth.
if not chk-inf and not interface and not from-ink then return.

run waitfram-show in this-procedure ( input "Поиск ошибочных и неучтенных чеков. ЖДИТЕ...").
v-notes = "".
if from-ink then do: /*из продажи*/
    FIND FIRST ub.inkas No-LOCK WHERE recid(ub.inkas) = p-doc-rec No-ERROR.
    if not avail ub.inkas then do:
      message vss-workfile vss-revision vss-description skip
      "Не найдена запись inkas"
      view-as alert-box error .
      return error.
    end.
    assign
    current-store-type = ub.inkas.obj-type
    current-store-code = ub.inkas.obj-code
    .
    FIND FIRST ub.shop NO-LOCK WHERE
               ub.shop.obj-code = ub.inkas.obj-code NO-ERROR.

  /*найдем параметр - использовать смены на кассе или нет*/
  { gbl/cas-shft.i ub.inkas.obj-type ub.inkas.obj-code cas-shft }
  { gbl/objat.i
  ub.inkas.obj-type
  ub.inkas.obj-code
  "'shift-on=request'"
  l-shift-on
  }
end.
/*нам все равно какие смены - по объекту или по кассе */
cas-shft = cas-shft OR l-shift-on.


if from-ink then do:
  assign
  v-shift-str = substitute("&1 &2"
                          ,string(inkas.shift-date, "99/99/9999")
                          ,(if cas-shft
                            then (" СМЕНА " + shift-name-no-err(buffer inkas))
                            else "")).


  assign
  not-saled = substitute("НЕУЧТЕННЫХ ЧЕКОВ ЗА &1 НЕТ&2"
                         , v-shift-str
                         , {&new-line})
  not-saled-err = substitute("ОШИБОЧНЫX чеков ЗА &1 НЕТ&2"
                              ,v-shift-str
                              ,{&new-line})
  inkas-ch = "Нет НЕЗАКРЫТЫХ продаж" + CHr(10)
  .
  if chk-inf then do:
&scop date-str string (chk-doc.shift-date, "99/99/9999")
    For each  ub.chk-doc where
              ub.chk-doc.obj-type = current-store-type and
              ub.chk-doc.obj-code = current-store-code and
              ub.chk-doc.out-code = ?
    by ub.chk-doc.chk-date descending
    by ub.chk-doc.chk-time descending:
    if ((NOT cas-shft)  AND ub.shop.day-only AND ub.chk-doc.shift-date = ub.inkas.shift-date) OR
      (( cas-shft and ub.shop.day-only) AND
        ub.chk-doc.shift-date = ub.inkas.shift-date AND
        ub.chk-doc.shift-num = ub.inkas.shift-num) OR
      (NOT ub.shop.day-only AND NOT cas-shft)
    then do:
      assign
      not-saled =  substitute("Есть НЕУЧТЕННЫЙ чек за &1&2"
                                    ,{&date-str}
                                    ,{&new-line})
      not-all-saled-chk = yes.
    end.
    if NOT ub.chk-doc.correct then do:
      assign
      not-saled-err =   substitute("Есть ОШИБОЧНЫЙ чек за &1&2"
                                  ,{&date-str}
                                  ,{&new-line})
      not-all-normal-chk = yes
      .
    end.
    not-saled = substitute("Есть НЕУЧТЕННЫЙ чек за &1&2&2"
                          ,{&date-str}
                          ,{&new-line})
    .
    end.
  end. /*if chk-inf*/
end. /*from-ink - из продажи*/
else do:
  /*найдем параметр - использовать смены на кассе или нет*/
  { gbl/cas-shft.i p-curr-obj-type p-curr-obj-code cas-shft no-error }
  IF not error-status:error then
  assign
  cas-shft = (conf-par = "yes").

  { gbl/objat.i
    p-curr-obj-type
    p-curr-obj-code
    "'shift-on=request'"
    l-shift-on
  }

/*нам все равно какие смены - по объекту или по кассе */
cas-shft = cas-shft OR l-shift-on.


  find first ub.inkas no-lock where
          ub.inkas.obj-type = p-curr-obj-type AND
          ub.inkas.obj-code = p-curr-obj-code AND
          ub.inkas.status_ = {&g___new} use-index obj-stat no-error.
  if available ub.inkas then do:
        not-all-inkas-closed = yes.
      end.
  assign
  not-saled = "НЕУЧТЕННЫХ ЧЕКОВ НЕТ" + chr(10)
  not-saled-err =   "ОШИБОЧНЫX чеков НЕТ " + chr (10)
  inkas-ch = "Нет НЕЗАКРЫТЫХ продаж" + CHr(10)
  .
  FIND FIRST ub.shop NO-LOCK WHERE
             ub.shop.obj-code = p-curr-obj-code NO-ERROR.
  For each  ub.chk-doc no-lock  where
            ub.chk-doc.obj-type = p-curr-obj-type AND
            ub.chk-doc.obj-code = p-curr-obj-code AND
            ub.chk-doc.out-code = ?
      by ub.chk-doc.chk-date
      by ub.chk-doc.chk-time :
    if NOT not-all-saled-chk  AND
      (
        /*нет незакрытых продаж по товару - ищем среди всех чеков*/
        NOT not-all-inkas-closed OR
        /*несменная работа */
        (NOT cas-shft AND
              /*если есть незакрытая продажа по товарам и в магазине в продажу должны попадать чеки одного дня а
              данный чек как раз за этот день*/
          (  (not-all-inkas-closed AND shop.day-only AND chk-doc.shift-date = inkas.shift-date) OR
              /*есть незакрытая продажа но не чеки одного дня*/
              (not-all-inkas-closed AND (NOT shop.day-only)  )
          )
        )  OR
        /*сменная работа */
        (cas-shft AND (not-all-inkas-closed AND inkas.shift-date = chk-doc.shift-date)
        )
      ) then do:
      assign
      not-all-saled-chk = yes
      not-saled = substitute("Самый старый НЕУЧТЕННЫЙ чек за : &1&2"
                                ,{&date-str}
                                ,{&new-line})
      .
    end.
    if NOT not-all-normal-chk
    AND chk-doc.correct <> yes then do:
      assign
      not-all-normal-chk = yes
      not-saled-err = substitute("Самый старый ОШИБОЧНЫЙ чек за : &1&2&2"
                                ,{&date-str}
                                ,{&new-line})
     .
    end.
    not-saled = substitute("Самый старый НЕУЧТЕННЫЙ чек за : &1&2&2"
                          ,{&date-str}
                          ,{&new-line})
    .
  end.
end. /*не из продажи*/

for each inkas No-LOCK WHERE
         inkas.obj-type = p-curr-obj-type AND
         inkas.obj-code = p-curr-obj-code AND
         inkas.status_ = {&fact}
by inkas.doc-date descending:
/*index obj-stat
                     + obj-type
                     + obj-code
                     + status_
                     - doc-date*/
  if inkas.status_ = {&fact} then do:
    inkas-ch = substitute("Дата последней закрытой продажи : &1&2&2"
                            ,string (inkas.fact-date, "99/99/9999")
                           , {&new-line}).
    leave.
  end.
end.

v-notes = v-notes + not-saled +
        (if not-all-normal-chk then not-saled-err else "") +
        (if not-all-saled-chk then not-saled else "") + inkas-ch.
run waitfram-hide in this-procedure .

if interface then
run gbl/showtext.p (
                 input "Неучтенные и ошибочные чеки, последние закрытые продажи"
                ,input 60
                ,input 15
                ,input v-notes
                ).