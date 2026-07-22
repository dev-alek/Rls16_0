block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: clb-shd.p $
$Archive: bge/clb-shd.p $

Экспорт/импорт платежей из системы КЛИЕНТ-БАНК ПО РАСПИСАНИЮ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/25/05
Author: Bakhtadze Natalya
Creation date: 07/25/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-cre-db-num  as integer   no-undo .
define input parameter p-task-type   as character no-undo .
define input parameter p-task-num    as integer   no-undo .
define input parameter p-db-num      as integer      no-undo . /* список БД по объктам которой необходимо принять информацию */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clb-shd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/clb-shd.p $":U .
define variable vss-description as character no-undo init "Экспорт/импорт платежей из системы КЛИЕНТ-БАНК ПО РАСПИСАНИЮ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ adm/auto-def.i    }
{ ref/shd-attr.i    }
{ bge/clbnkd.i "NEW SHARED" }
{ str/auto2dia.i }

do
on error undo, return error
:
    define variable v-counter                   as integer      no-undo.
    define variable v-param-list                as character    no-undo.
    define variable v-host-list                 as character    no-undo.
    define variable v-param-type                as character    no-undo.
    define variable v-range                     as integer      no-undo.
    define variable v-host-code                 as integer      no-undo.
    define variable v-parameter                 as character    no-undo .
    define variable v-hfin-schet                as character    no-undo .
    define variable v-cfin-schet                as character    no-undo .
    define variable v-date-list                 as character    no-undo .
    define variable v-rs-action                 as character    no-undo .
    define variable v-doc-type-list             as character    no-undo .

&scop display-message  run write-to-log in this-procedure (input ~{&my-message~})

    assign
    log-file-name = "ext-cbnk.log".


    run gbl/set-gbl.p
      (input  true
      ,input  g#auto-user-id
      ,input  g#auto-user-password
      ) no-error.
    if error-status:error
    then do:
        run write-to-log( vss-workfile + {&space-char}
                        + "!!!Ошибка при инициализации переменных g#..." + {&new-line}
                        + error-status:get-message(error-status:num-messages)
                        + return-value
                        ) .
        return error.
    end. /*if error-status:error*/
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , output v-param-list
        , output v-param-type
    ).
    if v-param-list = "":U then do:
        run write-to-log( substitute("!!!Не заданы параметры экспорта/импорта платежей из системы КЛИЕНТ-БАНК в задаче &1&2"
                                     , p-task-num
                                     , {&new-line}
                                     )

                        ) .

    end.
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-obj-list-h}
        , output v-host-list
        , output v-param-type
    ) .

   run init-host-list in this-procedure (input v-host-list).

   run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-filter-h}
        , output v-hfin-schet
        , output v-param-type
    ) .

    run fill-hfin-schet in this-procedure (input v-hfin-schet).

    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-filter-2-h}
        , output v-cfin-schet
        , output v-param-type
    ) .

   run fill-cfin-schet in this-procedure (input v-cfin-schet).

    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-date-list-h}
        , output v-date-list
        , output v-param-type
    ) .

      run schedule-attr-value in this-procedure (
            input p-cre-db-num
          , input p-task-type
          , input p-task-num
          , input {&attr-schedule-doc-type-list-h}
          , output v-doc-type-list
          , output v-param-type
      ) .


    assign
    v-rs-action =  entry( 5, v-param-list )
    .
    case v-rs-action:
      when 'exp' then do:
        run bge/clbnke.p (
                       input this-procedure  /*parparentproc*/
                      ,input this-procedure /*p-parent-handle*/
                      ,input this-procedure /*p-log-handle*/
                      ,input ('1' + {&delim-par} + v-param-list + {&delim-par} + v-date-list + {&delim-par} + v-doc-type-list) /*p-parameter*/ ) no-error .
        if error-status:error then do:
          run write-to-log in this-procedure (
                input substitute( "!!!Ошибка при экспорте платежей в систему КЛИЕНТ-БАНК&1" +
                                  "&2 &3"
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )            ).
        end.
      end.
      when 'imp' then do:
        run bge/clbnki.p (
                       input this-procedure  /*parparentproc*/
                      ,input this-procedure /*p-parent-handle*/
                      ,input this-procedure /*p-log-handle*/
                      ,input ('1' + {&delim-par} + v-param-list + {&delim-par} + v-date-list + {&delim-par} + v-doc-type-list) /*p-parameter*/ ) no-error .
        if error-status:error then do:
          run write-to-log in this-procedure (
                input substitute( "!!!Ошибка при импорте платежей из системы КЛИЕНТ-БАНК&1" +
                                  "&2 &3"
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )            ).
        end.
      end.
    END CASE.
    run write-to-log in this-procedure (
          input substitute( "Сеанс импорта/экспорта с системой КЛИЕНТ-БАНК завершен"
                            )
                                      ).




end. /**/