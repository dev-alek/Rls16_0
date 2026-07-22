block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: srtgdprt.p $
$Archive: utl/srtgdprt.p $

Сортировка признаков заданного уровня шкалы

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 02/04/03

p-node-code - код корневого признака шкалы
p-sort-level - уровень сортировки
               0 - соответствует корневому признаку - его задавать нельз
               1 - первый уровень признаков
               2 - второй уровень признаков
p-start-from-max - задает номер с которого будет сортироватьс
                   каждый подуровень
                     true  - с максимального номера шкалы + 1
                     false - с уровня 1

*/

define input  parameter p-node-code      like ub.gds-prt.node-code no-undo .
define input  parameter p-sort-level     as integer   no-undo .
define input  parameter p-start-from-max as logical   no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: srtgdprt.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/srtgdprt.p $":U .
define variable vss-description as character no-undo initial "Сортировка признаков заданного уровня шкалы".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-node-code,p-sort-level)" }
{ cmp/trg-def.i  }

&scop define-temp-node define temp-table temp-node no-undo ~
  field level-num as integer ~
  field name      as character ~
  index xpk is primary unique level-num name ~
  .
{&define-temp-node}

&scop define-temp-node-list define temp-table temp-node-list no-undo ~
  field node-code as integer ~
  field upper-code as integer ~
  field level-num as integer ~
  field order     as integer ~
  field sort-order as integer ~
  field node-name  as character ~
  index xpk is primary level-num upper-code node-name ~
  index xie1 upper-code node-name ~
  index xie2 node-code ~
  index xie3 sort-order ~
  .
{&define-temp-node-list}



do
on error undo, return error return-value
:
  run validate-parameter in this-procedure
    (input p-node-code
    ,input p-sort-level
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  define buffer lock_gds-prt for ub.gds-prt .
  do transaction
  on error undo, return error return-value
  :
    find first lock_gds-prt exclusive-lock
      where lock_gds-prt.node-code = p-node-code
      .
  end.

  run fill-root-level in this-procedure
    (input p-node-code
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке целостности шкалы" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* считываем из базы необходимые уровни */
  run fill-levels in this-procedure
    (input p-node-code
    ,input 1
    ,input p-sort-level
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке целостности шкалы" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  run renumber-level-sort in this-procedure
    (input p-sort-level
    ,input p-start-from-max
    ) .

  run store-level-sort in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при сохранении порядка сортировки" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
end.


procedure validate-parameter :

  define input  parameter p-node-code like ub.gds-prt.node-code no-undo .
  define input  parameter p-level     as integer   no-undo .

  define buffer buf_gds-prt for ub.gds-prt .
  define buffer buf_db for ub.db .

  do
  on error undo, return error return-value
  :
    find first buf_gds-prt share-lock
      where buf_gds-prt.node-code = p-node-code
      no-error .
    if not available buf_gds-prt then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена шкала" skip
        "Номер шкалы" p-node-code skip
        view-as alert-box error .
      undo, return error .
    end.

    if buf_gds-prt.root <> true then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Указан номер не корневого признака" skip
        "Номер шкалы" p-node-code skip
        view-as alert-box error .
      undo, return error .
    end.

    define variable v-prt-level as integer   no-undo .
    { gbl/prtlevel.i
      p-node-code
      v-prt-level
    }

    /* 1 пустая шкала */
    /* 2 одноуровневая шкала */
    /* 3 двухуровневая шкала */

    if p-level < 1
    or p-level >= v-prt-level
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неправильный номер уровня" skip
        "Номер шкалы" p-node-code skip
        "Размер шкалы" v-prt-level skip
        "Задана сортировка уровня" p-level skip
        view-as alert-box error .
      undo, return error .
    end.

    define variable v-office as logical   no-undo .
    { gbl/currdbat.i
      'office=request':u
      v-office
    }
    if v-office = false
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Процедура сортировки шкалы может запускаться только в ГБД"
        view-as alert-box error .
      undo, return error .
    end.

  end.

end procedure. /* validate-parameter */

procedure fill-root-level :

  define input  parameter p-node-code like ub.gds-prt.node-code no-undo .

  define buffer buf_gds-prt for ub.gds-prt .
  define buffer buf_temp-node for temp-node .
  define buffer buf_temp-node-list for temp-node-list .

  do
  on error undo, return error return-value
  :
    find first buf_gds-prt share-lock
      where buf_gds-prt.node-code = p-node-code
      .
    create buf_temp-node .
    assign
      buf_temp-node.level-num = 0
      buf_temp-node.name      = buf_gds-prt.node-name
    .

    create buf_temp-node-list .
    assign
      buf_temp-node-list.node-code  = buf_gds-prt.node-code
      buf_temp-node-list.upper-code = buf_gds-prt.upper-code
      buf_temp-node-list.level-num  = 0
      buf_temp-node-list.order      = buf_gds-prt.prt-num
      buf_temp-node-list.node-name  = buf_gds-prt.node-name
    .
  end.

end procedure. /* fill-root-level */


procedure fill-levels :

  define input  parameter p-node-code like ub.gds-prt.node-code no-undo .
  define input  parameter p-level     as integer   no-undo .
  define input  parameter p-prt-level as integer   no-undo .

  define buffer buf_gds-prt for ub.gds-prt .
  define buffer buf_temp-node for temp-node .
  define buffer buf_temp-node-list for temp-node-list .

  do
  on error undo, return error return-value
  :
    find first buf_temp-node
      where buf_temp-node.level-num = p-level
      no-error .
    if not available buf_temp-node
    then do:
      for each buf_gds-prt share-lock
        where buf_gds-prt.upper-code = p-node-code
      on error undo, return error return-value
      :
        create buf_temp-node .
        assign
          buf_temp-node.level-num = p-level
          buf_temp-node.name      = buf_gds-prt.node-name
        .
      end.
    end.

    for each buf_gds-prt share-lock
      where buf_gds-prt.upper-code = p-node-code
    on error undo, return error return-value
    :
      create buf_temp-node-list .
      assign
        buf_temp-node-list.node-code  = buf_gds-prt.node-code
        buf_temp-node-list.upper-code = buf_gds-prt.upper-code
        buf_temp-node-list.level-num  = p-level
        buf_temp-node-list.order      = buf_gds-prt.prt-num
        buf_temp-node-list.sort-order = 0
        buf_temp-node-list.node-name  = buf_gds-prt.node-name
      .
      if p-level < p-prt-level then do:
        run fill-levels in this-procedure
          (input buf_gds-prt.node-code
          ,input p-level + 1
          ,input p-prt-level
          ) .
      end.
    end.
  end.
end procedure. /* fill-levels */


procedure renumber-level-sort :

  define input  parameter p-level          as integer   no-undo .
  define input  parameter p-start-from-max as logical   no-undo .

  define variable v-parent-level as integer   no-undo .

  define buffer parent_temp-node-list for temp-node-list .
  define buffer buf_temp-node-list for temp-node-list .

  do
  on error undo, return error return-value
  :
    assign
      v-parent-level = p-level - 1
    .

    for each parent_temp-node-list
      where parent_temp-node-list.level = v-parent-level
    on error undo, return error return-value
    :
      define variable v-sort-ind as integer   no-undo .
      assign
        v-sort-ind = 1
      .
      if p-start-from-max = true
      then do:
        define variable v-node-num  as integer   no-undo .
        define variable v-need-sort as logical   no-undo .
        define variable v-last-num  as integer   no-undo .
        assign
          v-node-num  = 1
          v-need-sort = false
          v-last-num  = 0
        .
        for each buf_temp-node-list
          where buf_temp-node-list.upper-code = parent_temp-node-list.node-code
        by buf_temp-node-list.node-name
        on error undo, return error return-value
        :

          if v-sort-ind < buf_temp-node-list.order
          then do:
            assign
              v-sort-ind = buf_temp-node-list.order
            .
          end.
          assign
            v-node-num = v-node-num + 1
          .
          if buf_temp-node-list.order < v-last-num
          or buf_temp-node-list.order < 1
          then do:
            assign
              v-need-sort = true
            .
          end.
          assign
            v-last-num = buf_temp-node-list.order
          .
        end.
        assign
          v-sort-ind = v-sort-ind + 1
        .
        if v-sort-ind < v-node-num
        then do:
          assign
            v-sort-ind = v-node-num
          .
        end.
      end.
      else do:
        assign
          v-need-sort = true
        .
      end.

      if v-need-sort = true then do:
        for each buf_temp-node-list
          where buf_temp-node-list.upper-code = parent_temp-node-list.node-code
        by buf_temp-node-list.node-name
        on error undo, return error return-value
        :
          assign
            buf_temp-node-list.sort-order = v-sort-ind
          .
          assign
            v-sort-ind = v-sort-ind + 1
          .
        end.
      end.
    end.
  end.

end procedure. /* renumber-level-sort */


procedure store-level-sort :

  define buffer buf_temp-node-list for temp-node-list .
  define buffer buf_gds-prt for ub.gds-prt .

  do
  on error undo, return error return-value
  :
    define variable v-ind          as integer   no-undo .
    define variable v-current-time as character no-undo .
    define variable v-start-time   as int64     no-undo .

    def frame a
      v-ind          format ">>>>>>>9"  label "Обработано признаков" skip
      v-current-time format "x(8)"      label "Время" skip
      with view-as dialog-box side-labels three-d
      title "Сохранение порядка сортировки"
      .
    assign
      v-start-time = etime
    .
    view frame a .

    for each buf_temp-node-list
      where buf_temp-node-list.sort-order > 0
    by buf_temp-node-list.upper-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        assign
          v-current-time = string( integer(truncate((etime - v-start-time) / 1000, 0)), 'HH:MM:SS':u)
        .
        display
          v-ind
          v-current-time
          with frame a .
      end.
      /* сохраняем новый порядок сортировки */
      do transaction
      on error undo, return error
      :
        find first buf_gds-prt exclusive-lock
          where buf_gds-prt.node-code = buf_temp-node-list.node-code
          .
        assign
          buf_gds-prt.prt-num = buf_temp-node-list.sort-order
        .
      end.
    end.
    hide frame a.
    pause 0 .
  end.

end procedure. /* store-level-sort */