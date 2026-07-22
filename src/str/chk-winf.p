block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chk-winf.p $
$Archive: str/chk-winf.p $

информация по чекам МЦ и автодокументам

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
define input parameter from-doc as logical no-undo.
define input parameter par-rid as recid no-undo.
define output parameter v-notes  as character no-undo .
/*есть неучтенные чеки */
define output parameter not-all-doced as logical init no.
/*есть ошибочные чеки*/
define output parameter not-all-normal as logical init no.
/*есть незакрытые документы */
define output parameter not-all-closed as logical no-undo init no.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-winf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chk-winf.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ str/shftnmef.i wth-doc shift-name }
{ gbl/getcntxt.i def }

DEFINE VARIABLE doc as logical init no.
DEFINE VARIABLE not-doced-ch as char no-undo.
DEFINE VARIABLE not-doced-err-ch as char no-undo.
DEFINE VARIABLE doc-ch as char no-undo.

/*использовать смены на кассе для данного объекта*/
DEFINE VARIABLE cas-shft as logical no-undo init no.
/*использовать смены для данного объекта*/
DEFINE VARIABLE l-shift-on as logical no-undo init no.
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
  substitute("Нельзя получить информацию по чекам МЦ в чужой БД&1" +
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
if not chk-inf and not interface and not from-doc then return.


run waitfram-show in this-procedure ("Поиск ошибочных и неучтенных чеков. ЖДИТЕ...").
v-notes = "".
if from-doc then do: /*из продажи*/
  FIND FIRST ub.wth-doc No-LOCK WHERE recid(ub.wth-doc) = par-rid.

  /*найдем параметр - использовать смены на кассе или нет*/
  { gbl/cas-shft.i p-curr-obj-type p-curr-obj-code  cas-shft }
  { gbl/objat.i
  p-curr-obj-type
  p-curr-obj-code
  "'shift-on=request'"
  l-shift-on
  }
end.
/*нам все равно какие смены - по объекту или по кассе */
cas-shft = cas-shft OR l-shift-on.


if from-doc then do:
  assign
  v-shift-str = substitute("&1 &2"
                          , string(ub.wth-doc.doc-date, "99/99/9999")
                          , (if cas-shft
                             then (" СМЕНА № " + shift-name-no-err(buffer wth-doc))
                             else  "") ).
  assign
  not-doced-ch = substitute("НЕУЧТЕННЫХ ЧЕКОВ МЦ ЗА &1 НЕТ&2"
                            ,v-shift-str
                            ,{&new-line})
  not-doced-err-ch = substitute("ОШИБОЧНЫX чеков МЦ ЗА &1 НЕТ&2"
                               ,v-shift-str
                               ,{&new-line})
  doc-ch = "Нет НЕЗАКРЫТЫХ автодокументов МЦ " + {&new-line}
  .

  if chk-inf then do:
&scop date-str string(chk-doc.shift-date, "99/99/9999")

    For each  ub.chk-doc where
              ub.chk-doc.obj-type = p-curr-obj-type and
              ub.chk-doc.obj-code = p-curr-obj-code and
              ub.chk-doc.out-code = '':U
    by ub.chk-doc.shift-date descending
    by ub.chk-doc.chk-time descending
    :
      if lookup(string(chk-doc.chk-type), {&wth-receipt-codes}) = 0 then next.
      if ((NOT cas-shft)  AND chk-doc.shift-date = wth-doc.doc-date) OR
          ( cas-shft AND
            chk-doc.shift-date = wth-doc.shift-date AND
            chk-doc.shift-num = wth-doc.shift-num)
      then do:
        assign
        not-doced-ch = substitute("Есть НЕУЧТЕННЫЙ чек МЦ за : &1&2"
                                   ,{&date-str}
                                   ,{&new-line}).
        not-all-doced = yes.
      end.
      if NOT chk-doc.correct then do:
        assign
        not-doced-err-ch = substitute("Есть ОШИБОЧНЫЙ чек МЦ за : &1&2&2"
                                      ,{&date-str}
                                      ,{&new-line}).
        not-all-normal = yes.
      end.
    end.
  end. /*if chk-inf*/
end. /*from-doc - из продажи*/
else do:
  /*найдем параметр - использовать смены на кассе или нет*/
  { gbl/cas-shft.i p-curr-obj-type p-curr-obj-code cas-shft }
  { gbl/objat.i
    p-curr-obj-type
    p-curr-obj-code
    "'shift-on=request'"
    l-shift-on
  }

 /*нам все равно какие смены - по объекту или по кассе */
 cas-shft = cas-shft OR l-shift-on.
 define variable v-status-list as character no-undo .
 define variable v-ii as integer no-undo .
  v-status-list = {&wayb} + {&delim-par} + {&permitted}.
  _do:
  do v-ii = 1 to num-entries(v-status-list, {&delim-par}):
    _for:
    for each ub.wth-doc No-LOCK WHERE
            ub.wth-doc.host-code = p-curr-host-code
        and ub.wth-doc.obj-type = p-curr-obj-type
        AND ub.wth-doc.obj-code = p-curr-obj-code
        AND ub.wth-doc.status_ = entry(v-ii, v-status-list, {&delim-par} )
        AND ub.wth-doc.auto-fill = yes
    by ub.wth-doc.host-code
    by ub.wth-doc.obj-type
    by ub.wth-doc.obj-code
    by ub.wth-doc.status_
    by ub.wth-doc.fact-order descending:
      if not not-all-closed then do:
    not-all-closed = yes.
        leave _for.
      end.
  END.
    if not-all-closed then leave _do.
  end.
  assign
  not-doced-ch = "НЕУЧТЕННЫХ ЧЕКОВ МЦ НЕТ" + {&new-line}
  not-doced-err-ch =   "ОШИБОЧНЫX чеков НЕТ " + {&new-line}
  doc-ch = "Нет НЕЗАКРЫТЫХ автодокументов МЦ" + {&new-line}
  .
  For each  ub.chk-doc no-lock  where
            ub.chk-doc.obj-type = p-curr-obj-type AND
            ub.chk-doc.obj-code = p-curr-obj-code AND
            ub.chk-doc.out-code = '':U
  by ub.chk-doc.chk-date
  by ub.chk-doc.chk-time
  :
    if lookup(string(ub.chk-doc.chk-type), {&wth-receipt-codes}) = 0 then next.
    if NOT not-all-doced  AND
      (
        /*нет незакрытых продаж по товару - ищем среди всех чеков*/
        NOT not-all-closed OR
        /*несменная работа */
        (NOT cas-shft AND
              /*если есть незакрытая продажа по товарам и в магазине в продажу должны попадать чеки одного дня а
              данный чек как раз за этот день*/
          (  (not-all-closed AND ub.chk-doc.shift-date = ub.wth-doc.doc-date) OR
              /*есть незакрытая продажа но не чеки одного дня*/
              not-all-closed
          )
        )  OR
        /*сменная работа */
        (cas-shft AND (not-all-closed AND wth-doc.shift-date = chk-doc.shift-date)
        )
      ) then do:
      assign
      not-all-doced = yes
      not-doced-ch =  substitute("Самый старый НЕУЧТЕННЫЙ чек МЦ за : &1&2"
                                 ,{&date-str}
                                 ,{&new-line}).
    end.
    if NOT not-all-normal AND chk-doc.correct = no then do:
      assign
      not-all-normal = yes
      not-doced-err-ch = substitute("Самый старый ОШИБОЧНЫЙ чек МЦ за : &1&2&2"
                                    ,{&date-str}
                                    ,{&new-line}).
    end.

  end.
end. /*не из продажи*/

for each wth-doc No-LOCK WHERE
         wth-doc.obj-type = p-curr-obj-type AND
         wth-doc.obj-code = p-curr-obj-code AND
         wth-doc.auto-fill = yes AND
         wth-doc.status_ = {&fact}
by wth-doc.doc-date descending:
  doc = yes.
  doc-ch = substitute("Дата последнего закрытого автодокумента МЦ : &1&2&2"
                      ,string (wth-doc.fact-date, "99/99/9999")
                      ,{&new-line}).
  LEAVE.
end.

v-notes = v-notes + not-doced-ch +
        (if not-all-normal then not-doced-err-ch else "") +
        doc-ch.

run waitfram-hide in this-procedure .


if interface then
run gbl/showtext.p (
                 input "Неучтенные и ошибочные чеки МЦ, последние закрытые автодокументы МЦ"
                ,input 60
                ,input 15
                ,input v-notes
                ).