block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gcd-shd.p $
$Archive: str/gcd-shd.p $

Прием информации с касс по расписанию

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/21/05
Author: Bakhtadze Natalya
Creation date: 01/21/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-cre-db-num  as integer   no-undo .
define input parameter p-task-type   as character no-undo .
define input parameter p-task-num    as integer   no-undo .
define input parameter p-db-num      as integer      no-undo . /* список БД по объктам которой необходимо принять информацию */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gcd-shd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/gcd-shd.p $":U .
define variable vss-description as character no-undo init "Прием информации с касс по расписанию".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ adm/auto-def.i    }
{ ref/shd-attr.i    }
{ gbl/temphost.i    }
{ bge/bge-xml.i }
{ str/auto2dia.i }

do
on error undo, return error
:
    define variable v-ind                       as integer      no-undo.
    define variable v-param-list                as character    no-undo.
    define variable v-temp-obj-list             as character    no-undo.
    define variable v-obj-list                  as character    no-undo.
    define variable v-param-type                as character    no-undo.
    define variable v-obj-counter               as integer      no-undo.
    define variable v-range                     as integer      no-undo.
    define variable v-host-code                 as integer      no-undo.
    define variable v-remote                    as integer      no-undo .
    define variable v-parameter                 as character    no-undo .

    define buffer buf_clients   for ub.clients .
    define buffer buf_temp-obj  for temp-obj.
    assign
    log-file-name = "extgetcd.log".


    run gbl/set-gbl.p
      (input  true
      ,input  g#auto-user-id
      ,input  g#auto-user-password
      ) no-error .
    if error-status :error
    then do:
        run write-to-log( vss-workfile + {&space-char}
                        + "Ошибка при инициализации переменных g#..." + {&new-line}
                        + error-status:get-message(error-status:num-messages)
                        + return-value
                        ) .
        return error.
    end.
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , output v-param-list
        , output v-param-type
    ).
    if v-param-list = '' then do:
       assign
       v-range = 1
       v-remote = 0
       .
    end.
    else do:
    assign
        v-range = integer( entry( 1,  v-param-list ) )
        v-remote = (if num-entries(v-param-list) > 2 then integer(entry(3, v-param-list)) else 0)
    .
    end.
    if v-range = 2
    then do:
        if num-entries( v-param-list ) > 2
        then do:
            assign
                v-host-code = integer( entry( 2,  v-param-list ) )
            .
        end.
        else do:
            assign
                v-host-code = -1
            .
            run write-to-log in this-procedure (
                input vss-workfile + {&space-char} + " Не удалось определить код фирмы для приема информации с касс объектов фирмы."
            ).
        end.
    end.
    if v-range = 2
    and v-host-code = -1
    then do:        /* Выбрана прием информации по всем объектам фирмы в БД, но код фирмы получить не удалось */
        assign
            v-range = 1
        .
    end.
    if v-range <> 3 then run init-temphost.

    case v-range
    :
        when 1
        then do:        /* Принимается со всех объектов  списка БД */
            for each temp-obj
            :
                if temp-obj.db-num = p-db-num
                then do:
                    assign
                        v-obj-list = v-obj-list
                                        + ( if v-obj-list = "" then "" else "," )
                                        + temp-obj.obj-type
                                        + "," + string( temp-obj.obj-code )
                    .
                end.
            end.
        end.        /* when 1 */
        when 2
        then do:
            for each temp-obj
            :
                if temp-obj.db-num = p-db-num
                and temp-obj.host-code = v-host-code
                then do:
                    assign
                        v-obj-list = v-obj-list
                                        + ( if v-obj-list = "" then "" else "," )
                                        + temp-obj.obj-type
                                        + "," + string( temp-obj.obj-code )
                    .
                end.
            end.
        end.        /* when 2 */
        when 3      /* Выбрать только те объекты, которые принадлежат списку БД. */
        then do:
            run schedule-attr-value in this-procedure (
                  input p-cre-db-num
                , input p-task-type
                , input p-task-num
                , input {&attr-schedule-obj-list-h}
                , output v-temp-obj-list
                , output v-param-type
            ).
            do v-obj-counter = 1 to num-entries ( v-temp-obj-list ) / 2
            :
                find first buf_clients no-lock
                      where buf_clients.obj-type  = entry( v-obj-counter * 2 - 1, v-temp-obj-list )
                        and buf_clients.obj-code = integer( entry( v-obj-counter * 2, v-temp-obj-list ) )
                no-error.
                if not available buf_clients
                then do:
                    run write-to-log( vss-workfile + {&space-char}
                                    + substitute( " Ошибка приема информации с касс по расписанию: Не найден заданный объект &1 &2" + {&new-line}
                                                    , buf_clients.obj-type
                                                    , buf_clients.obj-code
                                                )
                                    ) .
                    undo, return error .
                end.
                else do:
                    if buf_clients.db-num = p-db-num
                    then do:
                        assign
                            v-obj-list = v-obj-list
                                            + ( if v-obj-list = "" then "" else "," )
                                            + buf_clients.obj-type
                                            + "," + string( buf_clients.obj-code )
                        .
                        create buf_temp-obj .
                        assign
                          buf_temp-obj.obj-type  = buf_clients.obj-type
                          buf_temp-obj.obj-code  = buf_clients.obj-code
                          buf_temp-obj.host-code = buf_clients.host-code
                          buf_temp-obj.db-num    = buf_clients.db-num
                        .

                    end.
                end.
            end.
        end.        /* when 3 */
    end case.
    if v-obj-list = ""
    then do:
        run write-to-log( vss-workfile + {&space-char}
                        + substitute( " Нет объектов для приема информации с касс."
                                        + {&new-line} + "    Номер базы данных:                   &1"
                                        + {&new-line} + "    Задан список объектов:               &2"
                                        + {&new-line} + "    Тип выгрузки         :               &3"
                                        , p-db-num
                                        , v-obj-list
                                        , v-range
                                    )
                        ) .
        undo, return error .
    end.
    for each temp-obj no-lock where
             temp-obj.obj-type = {&shop}
        and temp-obj.db-num = g#db-num
             :
       if v-range = 2 and temp-obj.host-code <> v-host-code then next.
      /*запустим прием чеков*/
/*
p-parameter включает
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-remote as integer no-undo .
define input parameter p-auto as integer no-undo. 0 - запуск вручную 1 по расписанию
которые далее определены как переменные с префиксом p-

*/
      assign
      v-parameter =
                     temp-obj.obj-type         + {&delim-par} +
                     string(temp-obj.obj-code) + {&delim-par} +
                     string(v-remote)          + {&delim-par} +
                     string(1).
      run str/get-chkf.p (
                     input this-procedure /*parparentproc a*/
                    ,input this-procedure /*p-parent-handle*/
                    ,input this-procedure /*p-log-handle*/
                    ,input v-parameter /*p-parameter*/) no-error .
      if error-status:error then do:
      run write-to-log in this-procedure (
            input substitute( "!!!Ошибка при приеме информации с касс &1&2&3" +
                               "&4 &5"
                             , temp-obj.obj-type
                             , temp-obj.obj-code
                             , {&new-line}
                             , error-status:get-message(1)
                             , return-value
                             )            ).

      end.
      process events.
      run write-to-log in this-procedure (
            input substitute( "Обработка спул-файлов по &1&2 завершена"
                             , temp-obj.obj-type
                             , temp-obj.obj-code
                             )
                                        ).
    end.
end. /**/