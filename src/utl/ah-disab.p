block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ah-disab.p $
$Archive: utl/ah-disab.p $

Запретить или разрешить расчёт архивов

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 11/18/05

*/

define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter p-install      as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ah-disab.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ah-disab.p $":U .
define variable vss-description as character no-undo init "Запретить или разрешить расчёт архивов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define buffer buf_sys-ctrl for ub.sys-ctrl .
define buffer buf_db for ub.db .
define buffer buf_clients  for ub.clients .

define variable v-num                        as integer   no-undo .
define variable v-action-disable             as logical   no-undo .
define variable v-action-label               as character no-undo .
define variable v-db-list                    as character no-undo .
define variable v-db-label-list              as character no-undo .
define variable v-archive-type               as character no-undo .
define variable v-entity-type                as character no-undo .
define variable v-ind                        as integer   no-undo .
define variable v-num-entries-select-db-list as integer   no-undo .
define variable v-select-db-list             as character no-undo .
define variable v-all-object                 as logical   no-undo .
define variable v-ok                         as logical   no-undo .

do
on error undo, return error
:
  { gbl/getcntxt.i get }

  run gbl/d-askw.w
    (input "Вопрос 1 из 4"
    ,input "Выберите действие" + {&new-line}
    ,input "|^"
    ,input "Запретить расчет архивов|Разрешить расчет архивов|Отмена"
    ,input "|"
        + "|"
        + ""
    ,input 1
    ,input 3
    ,output v-num
    ).

  case v-num :
    when 1
    then do:
      assign
        v-action-disable = true
        v-action-label   = "Запретить расчет складского архива"
      .
    end.
    when 2
    then do:
      assign
        v-action-disable = false
        v-action-label   = "Разрешить расчет складского архива"
      .
    end.
    when 3
    then do:
      /* пользователь отказался */
      return . /* --->>>--- */
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестное значение ответа на вопрос 1" skip
        "" v-num skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .

  run gbl/d-askw.w
    (input "Вопрос 2 из 4"
    ,input v-action-label /* Общее сообщение */
    ,input "|^"
    ,input "Складской архив по товарам" + '|':u
      + "Складской архив по поставщикам" + '|':u
      + "Складской архив по типам приобретения" + '|':u
      + "Отказ"
    ,input '|':u /* список описаний кнопок */
      + '|':u
      + '|':u
      + ''
    ,input 1 /* значение возвращаемое при нажатии enter */
    ,input 4 /* значение возвращаемое при нажатии escape */
    ,output v-num /* выбор пользователя */
    ).

  case v-num :
    when 1
    then do:
      assign
        v-archive-type = {&btpr-type-arh}
        v-action-label = v-action-label + " по товарам"
      .
    end.
    when 2
    then do:
      assign
        v-archive-type = {&btpr-type-ahsp}
        v-action-label = v-action-label + " по поставщикам"
      .
    end.
    when 3
    then do:
      assign
        v-archive-type = {&btpr-type-aht}
        v-action-label = v-action-label + " по типам приобретения"
      .
    end.
    when 4
    then do:
      return . /* --->>>--- */
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестное значение ответа на вопрос 2" skip
        "" v-num skip
        view-as alert-box error .
      undo, return error .
    end.
  end case .

  run gbl/d-askw.w
    (input "Вопрос 3 из 4"
    ,input v-action-label + {&new-line}
           + "Выберите способ разрешения/запрещения"
    ,input "|^"
    ,input "Для базы данных|Для объектов|Отмена"
    ,input "|"
        + "|"
        + ""
    ,input 1
    ,input 3
    ,output v-num
    ).

  case v-num :
    when 1
    then do:
      assign
        v-entity-type  = 'db':u
      .
    end.
    when 2
    then do:
      assign
        v-entity-type  = 'object':u
      .
    end.
    when 3
    then do:
      return . /* --->>>--- */
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестное значение ответа на вопрос 3" skip
        "" v-num skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

  find first buf_sys-ctrl .

  case v-entity-type
  :
    when 'db':u
    then do:
      run gbl/d-askw.w
        (input "Вопрос 4 из 4"
        ,input v-action-label + {&new-line}
        ,input "|^"
        ,input "Все базы данных^confirm|Выбрать базу данных|Отмена"
        ,input "|"
            + "|"
            + ""
        ,input 1
        ,input 3
        ,output v-num
        ).
      assign
        v-db-list       = ''
        v-db-label-list = ''
      .

      for each buf_db no-lock
        where (buf_sys-ctrl.db-num = 0
              or
              buf_db.db-num = buf_sys-ctrl.db-num
              )
        by buf_db.db-num
      :
        assign
          v-db-list       = v-db-list
                          + (if v-db-list <> '':u then {&comma-char} else '':u )
                          + string(buf_db.db-num)
          v-db-label-list = v-db-label-list
                          + (if v-db-label-list <> '':u then {&comma-char} else '':u )
                          + buf_db.db-name
        .
      end.

      case v-num :
        when 1
        then do:
          assign
            v-select-db-list = v-db-list
            v-action-label   = v-action-label
                             + " по всем базам данных"
          .
        end.
        when 2
        then do:
          run gbl/d-list.w
            (input  "b-sel,b-mark":u
            ,input  "Выберите базы данных"
            ,input  v-db-list
            ,input  v-db-label-list
            ,input  {&comma-char}
            ,input  "":u
            ,output v-select-db-list
            ).
          if v-select-db-list = '':u
          then do:
            message
              "База данных не выбрана" skip
              view-as alert-box information .
            return . /* --->>>--- */
          end.

          assign
            v-action-label   = v-action-label
                             + " по списку баз данных "
                             + v-select-db-list
          .
        end.
        otherwise do:
          return . /* --->>>--- */
        end.
      end.

      message
        "Внимание!" skip
        "Это последний вопрос перед выполнением операции над архивами" skip
        "" skip
        "" v-action-label skip
        "" skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        return . /* --->>>--- */
      end.

      assign
        v-num-entries-select-db-list = num-entries(v-select-db-list, {&comma-char})
      .

      do v-ind = 1 to v-num-entries-select-db-list
      :
        run waitfram-show in this-procedure
          (input substitute("Обработка базы данных &1"
                           ,integer(entry(v-ind, v-select-db-list, {&comma-char}))
                           )
          ) .
        run trg/ahdbdis.p
          (input v-archive-type
          ,input integer(entry(v-ind, v-select-db-list, {&comma-char}))
          ,input v-action-disable
          ) .
      end.
    end.
    when 'object':u
    then do:
      run gbl/d-askw.w
        (input "Вопрос 4 из 4"
        ,input v-action-label + {&new-line}
        ,input "|^"
        ,input "Все объекты^confirm|Выбрать объекты|Отмена"
        ,input "|"
            + "|"
            + ""
        ,input 1
        ,input 3
        ,output v-num
        ).

      case v-num :
        when 1
        then do:
          assign
            v-all-object   = true
            v-action-label = v-action-label
                           + " по всем объектам"
          .
        end.
        when 2
        then do:
          define variable v-user-select as logical   no-undo .
          { gbl/uobjsman.i
            parparentproc
            v-cntxt-db-num
            v-cntxt-userid
            v-cntxt-host-code-obj
            v-cntxt-obj-type
            v-cntxt-obj-code
            v-user-select
          }
          if v-user-select <> true
          then do:
            message
              "Объект не выбран"
              view-as alert-box information .
            return .
          end.

          assign
            v-all-object   = false
            v-action-label = v-action-label
                           + " по списку объектов"
          .
        end.
        otherwise do:
          return . /* --->>>--- */
        end.
      end.

      message
        "Внимание!" skip
        "Это последний вопрос перед выполнением операции над архивами" skip
        "" skip
        "" v-action-label skip
        "" skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        return . /* --->>>--- */
      end.

      if v-all-object = true
      then do:
        for each buf_db
          where (buf_sys-ctrl.db-num = 0
                or
                buf_db.db-num = buf_sys-ctrl.db-num
                )
        ,each buf_clients no-lock
          where buf_clients.db-num = buf_db.db-num
        on error undo, return error
        :
          run waitfram-show in this-procedure
            (input substitute("Обработка объекта &1 &2"
                              ,buf_clients.obj-type
                              ,buf_clients.obj-code
                              )
            ) .
          run trg/ahobjdis.p
            (input  v-archive-type
            ,input  buf_clients.obj-type
            ,input  buf_clients.obj-code
            ,input  v-action-disable
            ) .
        end.
      end.
      else do:
        define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

        for each buf_userobjs_temp-user-obj
        on error undo, return error return-value
        :
          find first buf_clients no-lock
            where buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type
              and buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code
            .
          if buf_sys-ctrl.db-num = 0
          or buf_clients.db-num = buf_sys-ctrl.db-num
          then do:
            run waitfram-show in this-procedure
              (input substitute("Обработка объекта &1 &2"
                                ,buf_clients.obj-type
                                ,buf_clients.obj-code
                                )
              ) .
            run trg/ahobjdis.p
              (input  v-archive-type
              ,input  buf_clients.obj-type
              ,input  buf_clients.obj-code
              ,input  v-action-disable
              ) .
          end.
        end.
      end.
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Неизвестное значение переменной v-entity-type" skip
        "" v-entity-type skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .

  run waitfram-hide in this-procedure .

  message
    "Утилита успешно завершила работу" skip
    view-as alert-box information .

end.