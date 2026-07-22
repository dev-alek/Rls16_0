block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: barcode1.p $
$Archive: ref/barcode1.p $

Создание бар-кода

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/22/09
Author: Bakhtadze Natalya
Creation date: 02/22/09

*/

define input  parameter p-mode as character no-undo .
define input  parameter p-silent as logical   no-undo .
define input  parameter p-b-code as integer   no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-node-code as integer   no-undo .
define input  parameter p-part-code as character no-undo .
define input  parameter p-in-code as character no-undo .
define input  parameter p-unit-cli as character no-undo .
define input  parameter p-cli-base-rate as decimal no-undo .
define output parameter p-rid as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: barcode1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/barcode1.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/bc-f-art.i }
{ trg/new-bcod.i }

define buffer buf_units for ub.units.
define buffer base_units for ub.units.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_gds-prt for ub.gds-prt.

define variable v-err-mess as character no-undo .
define variable v-is-new as logical no-undo .
define variable v-import as logical   no-undo .
define variable glog as logical   no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if num-entries(p-mode) > 1 then do:
    assign
    v-import = (entry(2, p-mode) = {&add-import}).
    p-mode = entry(1, p-mode).
  end.
  if not ( p-mode = {&add-def} or p-mode = {&update}) then do:
    message vss-workfile vss-revision vss-description skip
            "Неверный параметр p-mode - " p-mode
    view-as alert-box error .
    return error '':u.
  end.
  find first buf_goods no-lock where
            buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods then do:
    v-err-mess = substitute("Не найден товар с кодом &1", p-gds-code).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  if p-unit-cli = ""
  then do:
    v-err-mess = "Не задана единица измерения.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  find first buf_gds-prt no-lock where
            buf_gds-prt.node-code = p-node-code no-error.
  if not available buf_gds-prt then do:
    v-err-mess = substitute("Неверный код признака &1.", p-node-code).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'node-code').
  end.
  find buf_units where
      buf_units.unit-name = p-unit-cli no-lock no-error.
  find base_units where base_units.unit-name = buf_goods.unit-base no-lock.
  if not available buf_units
  then do:
    v-err-mess = substitute("Единица измерения &1 отсутствует в справочнике.", p-unit-cli).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  if  lookup( {&bottle}, base_units.type ) > 0
  and buf_goods.unit-base <> buf_units.unit-name
  then do:
    v-err-mess =  substitute("Нельзя создать код для неосновной единицы измерения&1"  +
                            "к товару, у которого основная единица измерения типа &2"
                            , {&new-line}
                            , {&bottle}).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  if  lookup ({&petrolium}, base_units.type) > 0
  and lookup ({&divisional}, base_units.type) > 0
  and buf_goods.gds-type = {&gds-goods}
  then do:
    /* дробный (разливной) бензин:
      - запрещено добавлять собственные коды
      - запрещено добавлять доп. бар-коды
      - можно добавлять доп. топливный (2 разрядный, разновидность весового, только добавляется вручную)
      - доп. топливный можно добавлять только один
    */
    /* такая проверка должна сработать еще в списке кодов. Но лучше поздно, чем никогда. */
    v-err-mess =  "Товар топливный: добавление собственных кодов запрещено.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else '').
  end.
  if  lookup ({&petrolium}, buf_units.type) > 0
  and lookup ({&divisional}, buf_units.type) > 0
  then do:
    v-err-mess =  "Топливная единица измерения не может быть указана в бар-коде.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  if lookup ({&weight}, buf_units.type) > 0
  then do:
    v-err-mess = "Весовая единица измерения не может быть указана в бар-коде.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  if lookup ({&serial}, buf_units.type) > 0
  then do:
    v-err-mess = "Серийная единица измерения не может быть указана в бар-коде.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  if  p-unit-cli <> buf_goods.unit-base
  and lookup ({&serial}, base_units.type) > 0
  then do:
    v-err-mess = "Товар серийный: Единица измерения должна совпадать с базовой.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'unit-cli').
  end.
  if  lookup ({&pieces}, base_units.type) > 0
  and p-cli-base-rate <>  truncate (p-cli-base-rate, 0)
  then do:
    v-err-mess = "Товар штучный: коэффициент должен быть целым числом.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'cli-base-rate').
  end.
  if p-cli-base-rate <= 0
  or p-cli-base-rate = ?
  then do:
    v-err-mess =  "Коэффициент должен быть больше 0.".
    run err-mess in this-procedure ( input-output v-err-mess).
    undo, return error (if p-silent then v-err-mess else 'cli-base-rate').
  end.
  if  p-unit-cli <> buf_goods.unit-base
  and p-cli-base-rate = 1
  and not p-silent
  then do:
    message
    "Единица измерения не совпадает с основной - а коэффициент 1. Это странно. Вы не ошиблись?"
      view-as alert-box question.
  end.
  b-c:
  do transaction
  on error undo, return error return-value
  :
    if p-mode = {&add-def}
    then do:
      /* добавление собственного бар-кода */
        if can-find (ub.bar-code where
                    ub.bar-code.gds-code  = buf_goods.gds-code
                and ub.bar-code.in-code   = p-in-code
                and ub.bar-code.part-code = p-part-code
                and ub.bar-code.node-code = p-node-code
                and ub.bar-code.unit-cli  = p-unit-cli)
        then do:
          v-err-mess = substitute( "Бар-код для единицы измерения &1 уже существует."
                                  ,p-unit-cli ).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo, return error (if p-silent then v-err-mess else 'cli-base-rate').
        end.
      if v-import = yes then do:
        glog = no.
        run  chk-b-code in THIS-PROCEDURE (
                                             input p-silent
                                            ,input p-b-code
                                            ,output glog
                                          ) no-error.
        if error-status:error then do:
          v-err-mess = return-value .
          run err-mess in this-procedure ( input-output v-err-mess).
          undo, return error (if p-silent then v-err-mess else '').
        end.
        create buf_bar-code.
        assign
        buf_bar-code.gds-code  = p-gds-code
        buf_bar-code.b-code    = p-b-code
        buf_bar-code.node-code = p-node-code
        buf_bar-code.part-code = p-part-code
        buf_bar-code.in-code   = p-in-code
        buf_bar-code.unit-cli  = p-unit-cli
        buf_bar-code.cli-base-rate  = p-cli-base-rate
        p-rid = recid(buf_bar-code)
        .
      end.
    end. /* добавление */
    if v-import = no then do:
      { gbl/barcodcr.i
        buf_goods.gds-code
        p-node-code
        p-part-code
        p-in-code
        p-unit-cli
        p-cli-base-rate
        v-is-new
        buf_bar-code
        no-error
      }
      if error-status :error
      then do:
        v-err-mess = substitute("Ошибка: &1&2&3", error-status:get-message(1) , {&new-line}, return-value ).
        run err-mess in this-procedure ( input-output v-err-mess).
        undo, return error (if p-silent then v-err-mess else 'cli-base-rate').
      end.
      p-rid = recid(buf_bar-code).
    end.
    if p-mode = {&update}
    then do:
      if v-import = yes then do:
        find first buf_bar-code exclusive-lock where
                  buf_bar-code.b-code = p-b-code .
        if buf_bar-code.gds-code <> p-gds-code then do:
          v-err-mess = substitute("Изменяемый бар-код существует, но относится к другому товару ( с кодом &1)", buf_bar-code.gds-code).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo, return error (if p-silent then v-err-mess else '').
        end.
        if buf_bar-code.node-code <> p-node-code then do:
          v-err-mess = substitute("Изменяемый бар-код существует, но относится к другому признаку ( с кодом &1)", buf_bar-code.node-code).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo, return error (if p-silent then v-err-mess else '').
        end.
        if buf_bar-code.part-code <> p-part-code then do:
          v-err-mess = substitute("Изменяемый бар-код существует, но относится к другому коду партии (&1)", buf_bar-code.part-code).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo, return error (if p-silent then v-err-mess else '').
        end.
        if buf_bar-code.in-code <> p-in-code then do:
          v-err-mess = substitute("Изменяемый бар-код существует, но относится к другой ПН (&1)", buf_bar-code.in-code).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo, return error (if p-silent then v-err-mess else '').
        end.
        if buf_bar-code.unit-cli <> p-unit-cli then do:
          v-err-mess = substitute("Изменяемый бар-код существует, но относится к другой ед.изм. (&1)", buf_bar-code.unit-cli).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo, return error (if p-silent then v-err-mess else '').
        end.
        if buf_bar-code.stts_ = integer({&hn-switch-off}) then do:
          buf_bar-code.stts_ = 0.
        end.
      end.
      if v-import = no then do:
        buf_bar-code.cli-base-rate = p-cli-base-rate.
      end.
    end.
  end.
end.

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Создание бар-кода &2 для товара с кодом &1:&3&4"
                         , p-gds-code
                         , p-b-code
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.