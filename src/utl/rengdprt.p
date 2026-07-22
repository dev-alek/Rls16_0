block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rengdprt.p $
$Archive: utl/rengdprt.p $

Переименование признака шкалы

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 06/20/03

*/

define input  parameter p-node-code as integer   no-undo .
define input  parameter p-level-num as integer   no-undo .
define input  parameter p-orig-name as character no-undo .
define input  parameter p-new-name  as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: rengdprt.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/rengdprt.p $":U .
define variable vss-description as character no-undo initial "Переименование признака шкалы".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u,p-node-code,p-level-num,p-orig-name,p-new-name)" }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }

&scop def-temp-gds-prt define temp-table temp-gds-prt no-undo ~
  field node-code  as integer ~
  field upper-code as integer ~
  field level-num  as integer ~
  field node-name  as character format 'x(16)' ~
  field f-name     as character format 'x(40)' ~
  field update-node-name as logical label 'upd-node' ~
  field update-f-name as logical label 'upd-full' ~
  field is-process as logical ~
  index xpk is primary unique node-code ~
  index ie1 f-name ~
  index ie2 level-num node-name ~
  index ie3 update-f-name is-process ~
  index ie4 is-process ~
  index ie5 upper-code ~
.

{&def-temp-gds-prt}

do
on error undo, return error return-value
:

  define buffer buf_sys-ctrl for ub.sys-ctrl .
  find first buf_sys-ctrl no-lock .
  if buf_sys-ctrl.db-num <> 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Процедура переименования признака шкалы может запускаться только в ГБД"
      view-as alert-box error .
    undo, return error .
  end.

  define buffer buf_gds-prt for gds-prt .
  find buf_gds-prt
    where buf_gds-prt.node-code = p-node-code
    .
  if buf_gds-prt.node-name = {&empty-scale}
  then do:
    message
      "Изменение пустой шкалы невозможно."
      view-as alert-box error.
    undo, return error return-value .
  end.

  define variable v-ok as logical   no-undo .
  assign
    v-ok = false
  .
  message
    "Шкала" buf_gds-prt.node-name skip
    "Уровень" p-level-num skip
    "Исходное имя" p-orig-name skip
    "Новое имя"  p-new-name  skip
    "Продолжить?"
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return .
  end.

  run waitfram-show in this-procedure
    (input "Считывание признаков шкалы"
    ) .

  run fill-temp-prt in this-procedure
    (input p-node-code
    ,input p-level-num
    ) .

  run waitfram-show in this-procedure
    (input "Переименование признаков шкалы"
    ) .

  run update-f-name in this-procedure
    (input p-node-code
    ,input p-level-num
    ,input p-orig-name
    ,input p-new-name
    ) .

  _main-block:
  do transaction
  on error undo, return error return-value
  :

    /* производим коррекцию признаков шкалы в единой транзакции */
    run update-gds-prt in this-procedure .

  end.

  run waitfram-hide in this-procedure .

  message
    "Процедура переименования признака успешно закончилась" skip
    "Шкала" buf_gds-prt.node-name skip
    "Уровень" p-level-num skip
    "Исходное имя" p-orig-name skip
    "Новое имя"  p-new-name  skip
    view-as alert-box information .

end.

procedure update-gds-prt :

  define buffer buf_temp-gds-prt for temp-gds-prt .
  define buffer buf_gds-prt for gds-prt .

  do
  on error undo, return error return-value
  :
    for each buf_temp-gds-prt
      where buf_temp-gds-prt.update-f-name = true
    on error undo, return error return-value
    :
      run waitfram-show in this-procedure
        (input substitute("Переименование признака &1", buf_temp-gds-prt.f-name)
        ) .

      find first buf_gds-prt exclusive-lock
        where buf_gds-prt.node-code = buf_temp-gds-prt.node-code
        .
      if buf_temp-gds-prt.update-f-name = true
      then do:
        assign
          buf_gds-prt.f-name = buf_temp-gds-prt.f-name
        .
      end.
      if buf_temp-gds-prt.update-node-name = true
      then do:
        assign
          buf_gds-prt.node-name = buf_temp-gds-prt.node-name
        .
      end.
    end.
  end.

end procedure. /* update-gds-prt */

procedure fill-temp-prt :

  define input  parameter p-node-code      as integer   no-undo .
  define input  parameter p-level-num      as integer   no-undo .

  define buffer buf_temp-gds-prt for temp-gds-prt .
  define buffer buf_gds-prt      for ub.gds-prt .

  do
  on error undo, return error return-value
  :

    /* заполняем признаки первого уровня */
    for each buf_gds-prt share-lock
      where buf_gds-prt.upper-code = p-node-code
    on error undo, return error return-value
    :
      create buf_temp-gds-prt .
      assign
        buf_temp-gds-prt.node-code        = buf_gds-prt.node-code
        buf_temp-gds-prt.upper-code       = buf_gds-prt.upper-code
        buf_temp-gds-prt.level-num        = 0
        buf_temp-gds-prt.node-name        = buf_gds-prt.node-name
        buf_temp-gds-prt.f-name           = buf_gds-prt.f-name
        buf_temp-gds-prt.is-process       = false
        buf_temp-gds-prt.update-node-name = false
        buf_temp-gds-prt.update-f-name    = false
      .
    end.

    /* заполняем все признаки более высоких уровней */
    _scan-prt:
    do while true
    :
      find first buf_temp-gds-prt
        where buf_temp-gds-prt.is-process = false
        no-error .
      if not available buf_temp-gds-prt
      then do:
        leave _scan-prt .
      end.

      assign
        buf_temp-gds-prt.is-process = true
      .

      define variable v-parent-node-code as integer   no-undo .
      define variable v-parent-level     as integer   no-undo .

      assign
        v-parent-node-code = buf_temp-gds-prt.node-code
        v-parent-level     = buf_temp-gds-prt.level-num
      .

      for each buf_gds-prt share-lock
        where buf_gds-prt.upper-code = v-parent-node-code
      on error undo, return error return-value
      :
        create buf_temp-gds-prt .
        assign
          buf_temp-gds-prt.node-code        = buf_gds-prt.node-code
          buf_temp-gds-prt.upper-code       = buf_gds-prt.upper-code
          buf_temp-gds-prt.level-num        = v-parent-level + 1
          buf_temp-gds-prt.node-name        = buf_gds-prt.node-name
          buf_temp-gds-prt.f-name           = buf_gds-prt.f-name
          buf_temp-gds-prt.is-process       = false
          buf_temp-gds-prt.update-node-name = false
          buf_temp-gds-prt.update-f-name    = false
        .
      end.
    end.
  end.

end procedure. /* fill-temp-prt */


procedure update-f-name :

  define input  parameter p-node-code as integer   no-undo .
  define input  parameter p-level-num as integer   no-undo .
  define input  parameter p-orig-name as character no-undo .
  define input  parameter p-new-name  as character no-undo .

  define buffer buf_temp-gds-prt for temp-gds-prt .
  define buffer child_buf_temp-gds-prt for temp-gds-prt .
  define buffer parent_buf_temp-gds-prt for temp-gds-prt .

  do
  on error undo, return error return-value
  :
    for each buf_temp-gds-prt
    on error undo, return error return-value
    :
      assign
        buf_temp-gds-prt.is-process = false
      .
    end.

    for each buf_temp-gds-prt
      where buf_temp-gds-prt.level-num = p-level-num
        and buf_temp-gds-prt.node-name = p-orig-name
    on error undo, return error return-value
    :
      assign
        buf_temp-gds-prt.update-f-name    = true
        buf_temp-gds-prt.node-name        = p-new-name
        buf_temp-gds-prt.update-node-name = true
      .
    end.

    _scan-prt:
    do while true
    :

      find first buf_temp-gds-prt
        where buf_temp-gds-prt.update-f-name = true
          and buf_temp-gds-prt.is-process    = false
        no-error .
      if not available buf_temp-gds-prt
      then do:
        leave _scan-prt .
      end.

      assign
        buf_temp-gds-prt.is-process = true
      .
      if buf_temp-gds-prt.level-num = 0
      then do:
        assign
          buf_temp-gds-prt.f-name = buf_temp-gds-prt.node-name
        .
      end.
      else do:
        find first parent_buf_temp-gds-prt
          where parent_buf_temp-gds-prt.node-code = buf_temp-gds-prt.upper-code
          .
        assign
          buf_temp-gds-prt.f-name = parent_buf_temp-gds-prt.f-name
                                  + '/':u
                                  + buf_temp-gds-prt.node-name
        .
      end.


      for each child_buf_temp-gds-prt
        where child_buf_temp-gds-prt.upper-code = buf_temp-gds-prt.node-code
      on error undo, return error return-value
      :
        assign
          child_buf_temp-gds-prt.update-f-name = true
        .
      end.
    end.
  end.

end procedure. /* update-f-name */