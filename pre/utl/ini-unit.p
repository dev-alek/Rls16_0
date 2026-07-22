block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ini-unit.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-unit.p $":U .
define variable vss-description as character no-undo init "Изменение базовой ед. изм. по списку товаров".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable new-unit as char no-undo.
define variable old-type as char no-undo.
define variable new-type as char no-undo.
define variable glog as logical no-undo .
def buffer old-units for ub.units.
define buffer buf_bar-code for ub.bar-code.
def frame a
new-unit label "Новая единица" format "x(3)"
with side-labels view-as dialog-box.
define variable v-ind as integer no-undo.
define variable num-rec as integer no-undo.
def frame b
v-ind label "Обработано товаров"
ub.goods.gds-name label "Название"
with side-labels view-as dialog-box.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code) .
find first ub.db No-LOCK WHERE
           ub.db.db-num <> 0 no-error .
if available ub.db then do:
  message "Утилита может быть запущена только в системе без УБД.".
  return.
end.
glog = yes.
message "Изменить базовую единицу измерения по всем товарам списка ?  Вы уверены ?"
                view-as alert-box question buttons OK-Cancel update glog.
if not glog then return.
update new-unit with frame a.
find ub.units where ub.units.unit-name = new-unit no-lock no-error.
if not available ub.units then do:
  message "Нет такой единицы !".
  return.
end.
find ub.gds-prt where ub.gds-prt.node-name = '_Пустая шкала':U no-lock.
view frame b.
v-ind = 0.
ON WRITE OF ub.bar-code OVERRIDE DO:
END.
ON WRITE OF ub.goods OVERRIDE DO:
END.
_gds-list:
for each gds-list:
  num-rec = num-rec + 1.
  find ub.goods where
       ub.goods.artic = gds-list.artic
   and ub.goods.prod-type = gds-list.prod-type
   and ub.goods.prod-code = gds-list.prod-code.
  disp ub.goods.gds-name with frame b.
  run check-unit-chg No-ERROR.
  if error-status:error then NEXT _gds-list.
  for each ub.bar-code where
           ub.bar-code.gds-code = ub.goods.gds-code AND
           ub.bar-code.unit-cli = ub.goods.unit-base:
    find first buf_bar-code No-LOCK WHERE
               buf_bar-code.gds-code = ub.goods.gds-code AND
               buf_bar-code.node-code = ub.bar-code.node-code AND
               buf_bar-code.part-code = ub.bar-code.part-code AND
               buf_bar-code.in-code = ub.bar-code.in-code AND
               buf_bar-code.unit-cli = ub.units.unit-name no-error .
    if available buf_bar-code then do:
      message
      "Не смогу изменить единицу измерения на" ub.units.unit-name skip
      "уже имеются бар-коды с такой единицей измерения" skip
      "товар" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
      "бар-код" buf_bar-code.b-code skip
      view-as alert-box error .
      NEXT _gds-list.
    end.
  end.
  chg-unit:
  do on stop undo chg-unit, return on error undo chg-unit, return:
    if LOOKUP('сер':U, units.type) > 0 or
       LOOKUP('сте':U, units.type) > 0 then do:
      if ub.goods.prt-root <> ub.gds-prt.upper-code then next.
      ub.goods.unit-cli = units.unit-name.
      ub.goods.cli-base-rate = 1.
    end.
    for each ub.bar-code
      where ub.bar-code.gds-code = ub.goods.gds-code
        and ub.bar-code.unit-cli = ub.goods.unit-base
         on stop undo chg-unit, return on error undo chg-unit, return:
      ub.bar-code.unit-cli = ub.units.unit-name.
      if ub.bar-code.unit-cli = ub.goods.unit-base then do:
        assign
          ub.bar-code.cli-base-rate = 1
        .
      end.
    end.
    ub.goods.unit-base = ub.units.unit-name.
    disp v-ind with frame b.
    v-ind = v-ind + 1.
    process events.
  end.
end.
ON WRITE OF ub.bar-code REVERT.
ON WRITE OF ub.goods REVERT.
if v-ind < num-rec then
message "Из выбранных " num-rec "товаров удалось отредактировать " v-ind.
else
message "Изменение проведено успешно.".
PROCEDURE check-unit-chg:
main-block:
do
on error undo main-block, return error
:
  FIND FIRST old-units No-LOCK WHERE old-units.unit-name = ub.goods.unit-base No-ERROR.
  if diff-list(old-units.type , ub.units.type, chr(44)) = "" then return.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  assign
    old-type  = (if lookup ('шту':U, old-units.type)     = 0 then "0" else "1")
              + (if lookup ('дро':U, old-units.type) = 0 then "0" else "1")
              + (if lookup ('сер':U, old-units.type)     = 0 then "0" else "1")
              + (if lookup ('вес':U, old-units.type)     = 0 then "0" else "1")
              + (if lookup ('топ':U, old-units.type)  = 0 then "0" else "1")
              + (if lookup ('2ед':U, old-units.type)    = 0 then "0" else "1")
              + (if lookup ('доп':U, old-units.type)    = 0 then "0" else "1")
              + (if lookup ('сте':U, old-units.type)     = 0 then "0" else "1")
    new-type  = (if lookup ('шту':U, ub.units.type)     = 0 then "0" else "1")
              + (if lookup ('дро':U, ub.units.type) = 0 then "0" else "1")
              + (if lookup ('сер':U, ub.units.type)     = 0 then "0" else "1")
              + (if lookup ('вес':U, ub.units.type)     = 0 then "0" else "1")
              + (if lookup ('топ':U, ub.units.type)  = 0 then "0" else "1")
              + (if lookup ('2ед':U, ub.units.type)    = 0 then "0" else "1")
              + (if lookup ('доп':U, ub.units.type)    = 0 then "0" else "1")
              + (if lookup ('сте':U, ub.units.type)     = 0 then "0" else "1")
  .
  if lookup (new-type, "10000000,01000000,00100000,00010000,10001000,01001000,01000100,10000010,10000001") = 0 then do:
    if g#esys then do:
              undo, return error substitute( "&2&1Недопустимый тип единицы измерения&1
                                              Единица измерения &3&1
                                              Тип единицы измерения &4&1
                                              Характеристика типа &5&1 
                                              &6&1&7"
                             , chr(10)
                             , vss-workfile
                             , ub.units.unit-name
                             , ub.units.type
                             , new-type
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    else do:
    message
      vss-workfile vss-revision vss-description skip
      "Недопустимый тип единицы измерения" skip
      "Единица измерения" ub.units.unit-name skip
      "Тип единицы измерения" ub.units.type skip
      "Характеристика типа" new-type skip
      view-as alert-box error .
    undo main-block, return error .
    end.
  end.
  if old-type <> new-type then do:
    if lookup ((old-type + "-" + new-type),
      "10000000-01000000,10001000-01001000,00001000-10001000,00001000-01001000,10000000-10000010,10000010-10000000") = 0 and
      old-type <> "00000000" then do:
        if g#esys then do:
                        undo, return error substitute( "&2&1Недопустимая замена типа единицы измерения&1
                                              Единица измерения &3&1
                                              Тип единицы измерения &4&1
                                              Характеристика типа &5&1 
                                              &6&1&7"
                             , chr(10)
                             , vss-workfile
                             , ub.units.unit-name
                             , ub.units.type
                             , new-type
                             , return-value
                             , error-status :get-message ( 1 ) ).
        end.
        else do:
      message
        vss-workfile vss-revision vss-description skip
        "Недопустимая замена типа единицы измерения" skip
        "Единица измерения" ub.units.unit-name skip
        "Изменение типа:" old-units.type "->" ub.units.type skip
        "Изменение характеристики типа:" old-type "->" new-type skip
        view-as alert-box error .
      undo main-block, return error .
      end.
    end.
  end.
END.
END PROCEDURE.
