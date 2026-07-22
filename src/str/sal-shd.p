block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка документов продаж по расписанию

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/22/05
Author: Bakhtadze Natalya
Creation date: 03/22/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-cre-db-num  as character    no-undo.
define input parameter p-task-type   as character    no-undo.
define input parameter p-task-num    as integer      no-undo.
define input parameter p-db-num      as integer      no-undo . /* список БД по объктам которой необходимо принять информацию */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обработка документов продаж по расписанию".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ adm/auto-def.i    }
{ ref/shd-attr.i    }
{ gbl/temphost.i    }
{ str/auto2dia.i }
/*нужно для закрытия продажи через saleclos.p*/
{ str/lib-def.i }
{ str/trdcalib.i }
{ str/tpsidoc.i "NEW SHARED"  proc }
{ str/dtlrestm.i "NEW SHARED" }
{ gbl/thbj-def.i }
{ gbl/getcntxt.i def }

define new shared temp-table temp-inkas no-undo like ub.inkas.
define variable v-curr-r-b as character no-undo init {&r-b-rubl}.

{ str/sal-shd.i }

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
    define variable v-start-state               as integer      no-undo .
    define variable v-end-state                 as integer      no-undo .
    define variable v-finalize-100              as logical      no-undo .
    define variable v-finalize-200              as logical      no-undo .
    define variable v-process-only-new          as logical      no-undo .
    /*v-start-state и v-end-state могут быть
    0 - создавать продажи по шаблонам
   100 закачивать чеки в них
   200 резервировать
   300 закрывать на факт
   400 удалять пустые - без чеков продажи
    */
    define variable v-parameter                 as character    no-undo .

    define buffer buf_clients   for ub.clients .
    define buffer buf_temp-obj  for temp-obj.

&scop display-message  run write-to-log in this-procedure (input ~{&my-message~})

    assign
    log-file-name = "ext-sale.log".


    run gbl/set-gbl.p
      (input  true
      ,input  g#auto-user-id
      ,input  g#auto-user-password
      ) no-error.
    if error-status :error
    then do:
        run write-to-log( vss-workfile + {&space-char}
                        + "!!!Ошибка при инициализации переменных g#..." + {&new-line}
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
    if v-param-list = "":U then do:
        run write-to-log( substitute("!!!Не заданы параметры обработки продаж в задаче &1&2"
                                     , p-task-num
                                     , {&new-line}
                                     )

                        ) .

    end.
    assign
        v-range = integer( entry( 1,  v-param-list ) )
        v-start-state = (if num-entries(v-param-list) > 2 then integer(entry(3, v-param-list)) else 0)
        v-end-state = (if num-entries(v-param-list) > 3 then integer(entry(4, v-param-list)) else 0)
        v-finalize-100  = (if num-entries(v-param-list) > 4 then logical(entry(5, v-param-list)) else no)
        v-finalize-200  = (if num-entries(v-param-list) > 4 then logical(entry(6, v-param-list)) else no)

    .
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
                input vss-workfile + {&space-char} + " Не удалось определить код фирмы для обработки документов продаж объектов фирмы."
            ).
        end.
    end.
    if v-range = 2
    and v-host-code = -1
    then do:        /* Выбрана обработка продаж по всем объектам фирмы в БД, но код фирмы получить не удалось */
        assign
            v-range = 1
        .
    end.
    if v-range <> 3 then run init-temphost.

    case v-range
    :
        when 1
        then do:        /* Работаем по всем объектам  списка БД */
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
            assign
                v-range     = 3
            .
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
            assign
                v-range     = 3
            .
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
                                    + substitute( " Ошибка обработки документов продаж по расписанию: Не найден заданный объект &1 &2" + {&new-line}
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
                        + substitute( " Нет объектов для обработки документов продаж."
                                        + {&new-line} + "    Номер базы данных:                   &1"
                                        + {&new-line} + "    Задан список объектов:               &2"
                                        + {&new-line} + "    Тип обработки        :               &3"
                                        , p-db-num
                                        , v-obj-list
                                        , v-range
                                    )
                        ) .
        undo, return error .
    end.
    { gbl/curr-r-b.i v-curr-r-b}
    _temp-obj:
    for each temp-obj no-lock where
             temp-obj.obj-type = {&shop}:
      if temp-obj.db-num <> g#db-num
      or index(v-obj-list,  temp-obj.obj-type + {&comma-char} + string( temp-obj.obj-code )) = 0 then do:
        next _temp-obj.
      end.

      /*
      define variable v-host-name like ub.clients.obj-name no-undo .
      define variable v-curr-abbr as character no-undo .
      define variable v-retail    as logical no-undo .
      */
      assign
        v-cntxt-obj-type      = temp-obj.obj-type
        v-cntxt-obj-code      = temp-obj.obj-code
        v-cntxt-host-code-obj = temp-obj.host-code
        v-cntxt-db-num-obj    = temp-obj.db-num
      .
      
      run write-to-log in this-procedure (
            input substitute( "            &1&2 Обработка документов продаж............."
                             , temp-obj.obj-type
                             , temp-obj.obj-code
                             )
                                        ).
      /*запустим обработку продаж*/
      if v-start-state = 0 then do:
        assign
        v-process-only-new = yes.
        /*надо создавать продажи*/
        assign
        v-parameter =
                      temp-obj.obj-type         + {&delim-par} +
                      string(temp-obj.obj-code) + {&delim-par} +
                      string(p-cre-db-num) + {&delim-par} +
                      string(p-task-type) + {&delim-par} +
                      string(p-task-num).
        run write-to-log in this-procedure (
              input substitute( "Создание документов продаж по шаблонам в &1&2..........."
                              , temp-obj.obj-type
                              , temp-obj.obj-code
                              )            ).
        run str/salemake.p (
                       input this-procedure  /*parparentproc*/
                      ,input this-procedure /*p-parent-handle*/
                      ,input this-procedure /*p-log-handle*/
                      ,input v-parameter /*p-parameter*/ ) no-error .
        if error-status:error then do:
          run write-to-log in this-procedure (
                input substitute( "!!!Ошибка при создании документов продаж по шаблонам в &1&2&3" +
                                  "&4 &5"
                                , temp-obj.obj-type
                                , temp-obj.obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )            ).
        end.
      end. /*if v-start-state = 0 then do:*/
      if v-start-state <= 100
      and v-end-state >= 100
      then do:
        /*значит надо закачивать чеки*/
        run write-to-log in this-procedure (
              input substitute( "Закачка чеков в документы продажи в &1&2..........."
                              , temp-obj.obj-type
                              , temp-obj.obj-code
                              )            ).

        run proc-step-100 in this-procedure(
                                            input temp-obj.obj-type
                                           ,input temp-obj.obj-code
                                           ,input v-process-only-new
                                           ,input v-finalize-100
                                           )  no-error .
        if error-status:error then do:
          run write-to-log in this-procedure (
                input substitute( "!!!Ошибка при закачке чеков в документы продаж в &1&2&3" +
                                  "&4 &5"
                                , temp-obj.obj-type
                                , temp-obj.obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )            ).
        end.
      end.
      process events.
      if v-start-state <= 200
      and v-end-state >= 200
      then do:
        /*значит надо резервировать*/
        run write-to-log in this-procedure (
              input substitute( "Резервирование в документах продаж в &1&2..........."
                              , temp-obj.obj-type
                              , temp-obj.obj-code
                              )            ).

        run proc-step-200 in this-procedure(
                                            input temp-obj.obj-type
                                           ,input temp-obj.obj-code
                                           ,input v-process-only-new
                                           ,input v-finalize-200)  no-error .
        if error-status:error then do:
          run write-to-log in this-procedure (
                input substitute( "!!!Ошибка при резервировании документов продаж в &1&2&3" +
                                  "&4 &5"
                                , temp-obj.obj-type
                                , temp-obj.obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )            ).
        end.
      end.
      process events.
      if v-start-state <= 300
      and v-end-state >= 300
      then do:
        /*значит надо закрывать на факт*/
        run write-to-log in this-procedure (
              input substitute( "Закрытие на факт документов продаж в &1&2..........."
                              , temp-obj.obj-type
                              , temp-obj.obj-code
                              )            ).

        run proc-step-300 in this-procedure(
                                            input temp-obj.obj-type
                                           ,input temp-obj.obj-code
                                           ,input v-process-only-new)  no-error .
        if error-status:error then do:
          run write-to-log in this-procedure (
                input substitute( "!!!Ошибка при закрытии на факт документов продаж в &1&2&3" +
                                  "&4 &5"
                                , temp-obj.obj-type
                                , temp-obj.obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )            ).
        end.
      end.
      if v-start-state <= 400
      and v-end-state >= 400
      then do:
        /*значит надо удалять пустые*/
        run write-to-log in this-procedure (
              input substitute( "Удаление пустых(без чеков) документов продаж в &1&2..........."
                              , temp-obj.obj-type
                              , temp-obj.obj-code
                              )            ).


        run proc-step-400 in this-procedure(
                                            input temp-obj.obj-type
                                           ,input temp-obj.obj-code
                                           ,input v-process-only-new)  no-error .
        if error-status:error then do:
          run write-to-log in this-procedure (
                input substitute( "!!!Ошибка при удалении пустых (без чеков) документов продаж в &1&2&3" +
                                  "&4 &5"
                                , temp-obj.obj-type
                                , temp-obj.obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )            ).
        end.
      end.
      process events.
      run write-to-log in this-procedure (
            input substitute( "Обработка документов продаж &1&2 завершена"
                             , temp-obj.obj-type
                             , temp-obj.obj-code
                             )
                                        ).
    end. /*for each temp-obj*/
end. /**/

procedure mainmenu_getcntxt :
define output parameter p-cntxt-db-num                as integer   no-undo . /* текущая БД            */
define output parameter p-cntxt-userid                as character no-undo . /* текущий пользователь  */
define output parameter p-cntxt-level                 as character no-undo . /* уровень контекста     */
define output parameter p-cntxt-host-code-obj         as integer   no-undo . /* текущая фирма         */
define output parameter p-cntxt-obj-type              as character no-undo . /* тип текущего объекта  */
define output parameter p-cntxt-obj-code              as integer   no-undo . /* код текущего объекта  */
define output parameter p-cntxt-db-num-obj            as integer   no-undo . /* база текущего объекта */
define output parameter p-cntxt-is-admin              as logical   no-undo . /* база текущего объекта */

  do
  on error undo, return error return-value
  :

  assign
    p-cntxt-db-num          =  g#db-num
    p-cntxt-userid          =  g#userid
    p-cntxt-level           =  v-cntxt-level
    p-cntxt-host-code-obj   =  v-cntxt-host-code-obj
    p-cntxt-obj-type        =  v-cntxt-obj-type
    p-cntxt-obj-code        =  v-cntxt-obj-code
    p-cntxt-is-admin        =  v-cntxt-is-admin
    p-cntxt-db-num-obj      =  v-cntxt-db-num-obj
  .

  end.
 end procedure. /* mainmenu_getcntxt */
