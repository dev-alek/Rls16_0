block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка команды two-commit

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/08/05
Author: Dmitry Ukhanov
Creation date: 09/08/05

*/

define input parameter p-source-db    as integer   no-undo .
define input parameter p-full-command as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обработка команды two-commit".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ nws/db-rec.i   }
{ adm/auto-def.i }

do
on error undo, return error
:
  define variable v-action            as character no-undo .
  define variable v-operation         as character no-undo .
  define variable v-uniq-key-rec      as character no-undo .
  define variable v-curr-db           as integer   no-undo .
  define variable v-db-init           as integer   no-undo .
  define variable v-parameters        as character no-undo .
  define variable v-answer-code       as integer   no-undo .
  define variable v-answer-msg        as character no-undo .
  define variable v-send-db-list      as character no-undo .
  define variable v-all-db-list       as character no-undo .
  define variable v-need-send-inquiry as logical   no-undo .
  define variable v-send-news         as logical   no-undo .
  define variable v-global-recover    as logical   no-undo .

  define variable v-main-prog-name      as character no-undo .
  define variable v-list-db-proc-name   as character no-undo .
  define variable v-commit-proc-name    as character no-undo .
  define variable v-execution-proc-name as character no-undo .
  define variable v-recover-proc-name   as character no-undo .
  define variable v-after-proc-name     as character no-undo .

  define variable v-db-num       as integer   no-undo .
  define variable v-ind          as integer   no-undo .
  define variable v-num-entries  as integer   no-undo .
  define variable v-change-oper  as logical   no-undo .
  define variable v-new-oper     as character no-undo .

  define variable v-after-command as character no-undo .

  define variable v-message       as character no-undo .
  define variable v-err-stts      as character no-undo .

  define buffer buf_sys-ctrl        for ub.sys-ctrl .
  define buffer buf_db              for ub.db .
  define buffer buf_db-rec-attr     for ub.db-rec-attr .
  define buffer buf-all_db-rec-attr for ub.db-rec-attr .

  find first buf_sys-ctrl no-lock .

  assign
    v-curr-db      = buf_sys-ctrl.db-num
    v-action       = entry(3, p-full-command, {&delim-nws})
    v-operation    = entry(4, p-full-command, {&delim-nws})
    v-uniq-key-rec = entry(5, p-full-command, {&delim-nws})
    v-db-init      = integer( entry(6, p-full-command, {&delim-nws}) )
    v-parameters   = entry(7, p-full-command, {&delim-nws})
    v-answer-code  = integer( entry(8, p-full-command, {&delim-nws}) )
    v-answer-msg   = entry(9, p-full-command, {&delim-nws})
  .
  run progs-name( input v-action
                 ,output v-main-prog-name
                 ,output v-list-db-proc-name
                 ,output v-commit-proc-name
                 ,output v-execution-proc-name
                 ,output v-recover-proc-name
                 ,output v-after-proc-name
                ) no-error .
  if error-status :error then do:
    return error substitute( "&1. Ошибка при определении имен процедур. &2", vss-workfile, return-value ).
  end.

  run value( v-list-db-proc-name )
    ( input v-action
     ,input v-uniq-key-rec
     ,output v-all-db-list
    ) no-error .
  if error-status :error then do:
    return error substitute( "&1. Ошибка при определении списка БД. &2", vss-workfile, return-value ).
  end.
  assign
    v-send-db-list = get-send-db-list( v-curr-db, v-all-db-list )
  .

  assign
    v-global-recover = TRUE
  .

/*run gbl/inidebug.p.*/
  if v-answer-code >= 0
    and ( v-curr-db = 0
          or v-curr-db = v-db-init
        )
  then do:
  /* это ответ после выполнения операции */
    find first buf_db-rec-attr exclusive-lock
      where buf_db-rec-attr.db-num             = p-source-db
        and buf_db-rec-attr.uniq-key-rec       = v-uniq-key-rec
        and buf_db-rec-attr.attr-code          = v-action
        and buf_db-rec-attr.attr-value-decimal = v-db-init
    no-error.
    if not avail buf_db-rec-attr then
    do:
      run write-to-log( substitute( 'Для БД &1 не найдена запись об операции "&2(&3)" над записью &4'
                                    ,p-source-db
                                    ,v-action
                                    ,v-operation
                                    ,v-uniq-key-rec
                                  )
                      ).
      return.
    end.
    if v-answer-code = 0 then do:
      run write-to-log( substitute( 'Получен ответ из БД &1 об успешном выполнении шага "&2" операции "&3" над записью &4'
                                    ,p-source-db
                                    ,v-operation
                                    ,v-action
                                    ,v-uniq-key-rec
                                  )
                      ).
      if buf_db-rec-attr.attr-type = v-operation then do:
        assign
  /*        buf_db-rec-attr.attr-type          = v-operation*/
          buf_db-rec-attr.attr-value-logical = TRUE
          v-change-oper = TRUE
        .
        assign
          v-num-entries = num-entries( v-send-db-list, {&comma-char} )
        .
        ALL_DB_REC:    
        do v-ind = 1 to v-num-entries
        on error undo, return error
        :
          assign
            v-db-num = integer( entry( v-ind, v-send-db-list, {&comma-char} ) )
          .
          if v-curr-db = 0 then do:
            if v-db-num = v-db-init
              and v-db-num <> 0
            then do:
              next.
            end.
            find first buf_db no-lock
              where buf_db.db-num = v-db-num
              no-error
            .
            if not available buf_db
              or buf_db.db-key = "":U
            then do:
              next.
            end.
          end.

          find first buf-all_db-rec-attr no-lock
            where buf-all_db-rec-attr.db-num             = v-db-num
              and buf-all_db-rec-attr.uniq-key-rec       = v-uniq-key-rec
              and buf-all_db-rec-attr.attr-code          = v-action
              and buf-all_db-rec-attr.attr-value-decimal = v-db-init
            no-error
          .
          if not available buf-all_db-rec-attr then do:
/*            create buf-all_db-rec-attr.                              */
/*            assign                                                   */
/*              buf-all_db-rec-attr.db-num             = v-db-num      */
/*              buf-all_db-rec-attr.uniq-key-rec       = v-uniq-key-rec*/
/*              buf-all_db-rec-attr.attr-code          = v-action      */
/*              buf-all_db-rec-attr.attr-value-decimal = v-db-init     */
/*              buf-all_db-rec-attr.attr-type          = v-operation   */
/*            .                                                        */
/*            run write-to-log                                                                                 */
/*              ( substitute( 'Для "&4" отсутствует запись о проведении операции "&1" над записью &2 для БД &3'*/
/*                            ,v-action                                                                        */
/*                            ,v-uniq-key-rec                                                                  */
/*                            ,v-db-num                                                                        */
/*                            ,v-operation                                                                     */
/*                          )                                                                                  */
/*              ).                                                                                             */
             next ALL_DB_REC.
          end.
          if buf-all_db-rec-attr.attr-type <> v-operation
            or ( buf-all_db-rec-attr.attr-type = v-operation
                and buf-all_db-rec-attr.attr-value-logical = FALSE
              )
          then do:
            assign
              v-change-oper = FALSE
            .
          end.
        end.
        if v-change-oper = TRUE then do:
          if buf_db-rec-attr.attr-type = "commit":U then do:
            assign
              v-new-oper = "execution":U
            .
          end.
          else do:
            assign
              v-new-oper = "":U
            .
          end.
        end.
      end.
      else do:
        run write-to-log( substitute( 'Для БД &1 уже начато выполнение шага "&2" операции "&3" над записью &4'
                                      ,p-source-db
                                      ,buf_db-rec-attr.attr-type
                                      ,v-action
                                      ,v-uniq-key-rec
                                    )
                        ).
        assign
          v-change-oper = FALSE
        .
      end.
    end.
    else do:
    /* была ошибка, производим полный откат операций */
      assign
        v-message = substitute( 'БД &1, шаг "&2", оп. "&3", запись &4.&5Ошибка: &6.&5Операция откатывается.'
                                ,p-source-db
                                ,v-operation
                                ,v-action
                                ,v-uniq-key-rec
                                ,{&new-line}
                                ,v-answer-msg
                              )
      .
      run write-to-log( v-message ).
      run create_msg_route in this-procedure
        ( input v-send-db-list
         ,input v-message
        ) no-error .
      if error-status :error then do:
        return error substitute( "&1. Ошибка при отправке сообщения по СПН. &2", vss-workfile, return-value ).
      end.

      if buf_db-rec-attr.attr-type = v-operation then do:
        if v-curr-db <> 0
          and v-curr-db = v-db-init
          and v-answer-code = 10
        then do:
          assign
            v-global-recover = FALSE
          .
        end.
        else do:
          assign
            v-global-recover = TRUE
            v-answer-code    = 1
          .
        end.
        assign
          v-change-oper = TRUE
          v-new-oper = "recover":U
        .
      end.
      else do:
        assign
          v-change-oper = FALSE
        .
      end.
    end.

    if v-change-oper = TRUE then do:
      if v-new-oper = "":U then do:
        for each buf_db-rec-attr
          where buf_db-rec-attr.uniq-key-rec       = v-uniq-key-rec
            and buf_db-rec-attr.attr-code          = v-action
            and buf_db-rec-attr.attr-value-decimal = v-db-init
        on error undo, return error
        :
          delete buf_db-rec-attr.
        end.
        if v-operation = "execution":U then do:
          assign
            v-message = substitute( 'Операция "&1" над записью &2 успешно завершена.'
                                    ,v-action
                                    ,v-uniq-key-rec
                                  )
          .
          run write-to-log( v-message ).
          run create_msg_route in this-procedure
            ( input v-send-db-list
            ,input v-message
            ) no-error .
          if error-status :error then do:
            return error substitute( "&1. Ошибка при отправке сообщения по СПН. &2", vss-workfile, return-value ).
          end.
        end.
        else do:
          assign
            v-message = substitute( 'Откат операции "&1" над записью &2 завершен.'
                                    ,v-action
                                    ,v-uniq-key-rec
                                  )
          .
          run write-to-log( v-message ).
          run create_msg_route in this-procedure
            ( input v-send-db-list
            ,input v-message
            ) no-error .
          if error-status :error then do:
            return error substitute( "&1. Ошибка при отправке сообщения по СПН. &2", vss-workfile, return-value ).
          end.
        end.
        if v-curr-db = v-db-init then do:
          assign
            v-after-command = "command":U + {&delim-nws}
                              + "after-two-commit":U + {&delim-nws}
                              + v-action + {&delim-nws}
                              + v-uniq-key-rec + {&delim-nws}
                              + string( v-db-init ) + {&delim-nws}
                              + v-parameters
          .
          run nws/dbrecaft.p
            ( input ? /* p-db-source */
             ,input v-after-command
            ) no-error .
          if error-status :error then do:
            return error substitute( "&1. Ошибка при выполнении команды (after) по СПН. &2", vss-workfile, return-value ).
          end.
        end.
      end.
      if v-curr-db = v-db-init then do:
        if v-new-oper <> "":U then do:
          if v-new-oper = "recover":U
            and v-global-recover = FALSE
          then do:
            for each buf_db-rec-attr
              where buf_db-rec-attr.uniq-key-rec       = v-uniq-key-rec
                and buf_db-rec-attr.attr-code          = v-action
                and buf_db-rec-attr.attr-value-decimal = v-db-init
            on error undo, return error
            :
              if buf_db-rec-attr.db-num = v-curr-db then do:
                assign
                  buf_db-rec-attr.attr-type          = v-new-oper
                  buf_db-rec-attr.attr-value-logical = FALSE
                .
              end.
              else do:
                delete buf_db-rec-attr .
              end.
            end.
          end.
          else do:
            for each buf_db-rec-attr
              where buf_db-rec-attr.uniq-key-rec       = v-uniq-key-rec
                and buf_db-rec-attr.attr-code          = v-action
                and buf_db-rec-attr.attr-value-decimal = v-db-init
            on error undo, return error
            :
              assign
                buf_db-rec-attr.attr-type          = v-new-oper
                buf_db-rec-attr.attr-value-logical = FALSE
              .
            end.
          end.
          assign
            v-operation   = v-new-oper
            v-answer-code = -1
            v-answer-msg  = "":U
          .
        end.
      end.
      else do:
/*        if v-curr-db = 0 then do:*/
/*        теперь инициатором может быть только ГБД, поэтому сюда мы никогда не попадем*/
/*        /* пересылаем в БД инициализатор информацию о готовности всех остальных БД */*/
/*          run create_db-rec_route in this-procedure*/
/*            ( input v-uniq-key-rec*/
/*             ,input v-action*/
/*             ,input v-operation*/
/*             ,input v-db-init      /* v-send-db-list */*/
/*             ,input v-db-init*/
/*             ,input v-parameters*/
/*             ,input v-answer-code*/
/*             ,input v-answer-msg*/
/*            ) no-error .*/
/*          if error-status :error then do:*/
/*            return error substitute( "&1. Ошибка при отправке команды по СПН. &2", vss-workfile, return-value ).*/
/*          end.*/
/*        end.*/
      end.
    end.
  end.

  if v-answer-code < 0 then do:
    if lookup( string( v-curr-db ), v-send-db-list, {&comma-char} ) <> 0 then do:
    /* если текущая БД есть в списке, то выполним для нее операцию */
      find first buf_db-rec-attr
        where buf_db-rec-attr.db-num       = v-curr-db
          and buf_db-rec-attr.uniq-key-rec = v-uniq-key-rec
          and buf_db-rec-attr.attr-code    = v-action
        no-error.
      if available buf_db-rec-attr
        and buf_db-rec-attr.attr-value-decimal <> v-db-init
      then do:
        assign
          v-answer-msg = substitute( "Операцию &1 над записью &2 уже производит БД &3"
                                     , v-action, v-uniq-key-rec, buf_db-rec-attr.attr-value-decimal
                                   )
          v-answer-code = 10
        .
      end.
      else do:
/*        EXPSD-8175 убрана проверка. если 1-го запроса commit не было. ну и ладно. выполняем без него */ 
/*        if not available buf_db-rec-attr                                                                                          */
/*          and v-operation = "execution":U                                                                                         */
/*        then do:                                                                                                                  */
/*          return error substitute( '&1. Нельзя выполнить шаг "&2" не выполнив шага "&3"', vss-workfile, v-operation, "commit":U ).*/
/*        end.                                                                                                                      */

        if available buf_db-rec-attr
          and buf_db-rec-attr.attr-type = v-operation
          and buf_db-rec-attr.attr-value-logical = TRUE
        then do:
          assign
            v-answer-msg = "":U
          .
        end.
        else do:
          assign
            v-message = substitute( 'Начинается выполнение шага "&1" операции "&2" над записью &3'
                                    ,v-operation
                                    ,v-action
                                    ,v-uniq-key-rec
                                   )
          .
          run write-to-log( v-message ).
          if not available buf_db-rec-attr then do:
            create buf_db-rec-attr.
            assign
              buf_db-rec-attr.db-num             = v-curr-db
              buf_db-rec-attr.uniq-key-rec       = v-uniq-key-rec
              buf_db-rec-attr.attr-code          = v-action
            .
          end.
          assign
            buf_db-rec-attr.attr-type          = v-operation
            buf_db-rec-attr.attr-value         = v-parameters
            buf_db-rec-attr.attr-value-decimal = v-db-init
            buf_db-rec-attr.attr-value-date    = TODAY
            buf_db-rec-attr.attr-value-logical = FALSE
            v-err-stts = "":U
          .
          run nws/db-rec.p
            ( input substitute( "&1&2not-begin":U, v-action, {&delim-nws} )
             ,input v-uniq-key-rec
             ,input v-parameters
            ) no-error .
          if error-status :error then do:
            assign
              v-err-stts = return-value
            .
          end.
          assign
            v-message = substitute( 'Завершилось выполнение шага "&1" операции "&2" над записью &3'
                                    ,v-operation
                                    ,v-action
                                    ,v-uniq-key-rec
                                  )
          .
          run write-to-log( v-message ).
          if v-err-stts <> "":U then do:
            return error v-err-stts.
          end.

          assign
            v-answer-msg = return-value
          .

          if v-answer-msg = "":U
            and ( v-operation = "execution":U
                  or v-operation = "recover":U
                )
            and v-curr-db <> 0
            and ( v-curr-db <> v-db-init /* чистим в удаленках неинициализаторах */
                  or
                  ( v-operation = "recover":U and v-global-recover = FALSE ) /* или в инициализаторе при неглобальном откате */
                )
          then do:
            for each buf_db-rec-attr
              where buf_db-rec-attr.uniq-key-rec = v-uniq-key-rec
                and buf_db-rec-attr.attr-code    = v-action
            on error undo, return error
            :
              delete buf_db-rec-attr.
            end.
          end.
        end.
      end.
    end.

    assign
      v-send-news = TRUE
    .

    if v-curr-db = v-db-init then do:
      if v-operation = "recover":U
        and v-global-recover = FALSE
      then do:
        assign
          v-need-send-inquiry = FALSE
          v-send-news         = FALSE
        .
      end.
      else do:
        assign
          v-need-send-inquiry = TRUE
        .
      end.
    end.
    else do:
      assign
        v-need-send-inquiry = FALSE
      .
      if v-curr-db = 0 then do: /* and v-curr-db <> v-db-init */
        assign
          v-num-entries = num-entries( v-send-db-list, {&comma-char} )
        .
        do v-ind = 1 to v-num-entries
        :
          assign
            v-db-num = integer( entry( v-ind, v-send-db-list, {&comma-char} ) )
          .
          if v-db-num = 0
            or v-db-num = v-db-init
          then do:
            next.
          end.
          assign
            v-need-send-inquiry = TRUE
          .
        end.
      end.
    end.

    if v-send-news = TRUE then do:
      if v-answer-msg = "":U
        and v-need-send-inquiry = TRUE
      then do:
      /* пересылаем команду на выполнение операции дальше */
        assign
          v-answer-code = -1
        .
        if v-curr-db = 0
/*          and v-curr-db <> v-db-init */ /*это необходимо если инициатором является УБД */
        then do:
          assign
            v-num-entries = num-entries( v-send-db-list, {&comma-char} )
          .
          do v-ind = 1 to v-num-entries
          :
            assign
              v-db-num = integer( entry( v-ind, v-send-db-list, {&comma-char} ) )
            .
            if v-db-num = 0
/*              or v-db-num = v-db-init*/ /*это необходимо если инициатором является УБД */
            then do:
              next.
            end.
            find first buf_db-rec-attr
              where buf_db-rec-attr.db-num       = v-db-num
                and buf_db-rec-attr.uniq-key-rec = v-uniq-key-rec
                and buf_db-rec-attr.attr-code    = v-action
              no-error.
            if not available buf_db-rec-attr then do:
              create buf_db-rec-attr.
              assign
                buf_db-rec-attr.db-num             = v-db-num
                buf_db-rec-attr.uniq-key-rec       = v-uniq-key-rec
                buf_db-rec-attr.attr-code          = v-action
              .
            end.
            assign
              buf_db-rec-attr.attr-type          = v-operation
              buf_db-rec-attr.attr-value         = v-parameters
              buf_db-rec-attr.attr-value-decimal = v-db-init
              buf_db-rec-attr.attr-value-date    = TODAY
              buf_db-rec-attr.attr-value-logical = FALSE
            .
          end.
        end.
      end.
      else do:
      /* отправляем ответ о результатах выполнения операции */
        if v-answer-msg = "":U then do:
          assign
            v-answer-code = 0
          .
        end.
        else do:
          if v-answer-code <> 10 then do:
            assign
              v-answer-code = 1
            .
          end.
        end.
      end.
      run create_db-rec_route in this-procedure
        ( input v-uniq-key-rec
        ,input v-action
        ,input v-operation
        ,input v-send-db-list
        ,input v-db-init
        ,input v-parameters
        ,input v-answer-code
        ,input v-answer-msg
        ) no-error .
      if error-status :error then do:
        return error substitute( "&1. Ошибка при отправке команды по СПН. &2", vss-workfile, return-value ).
      end.
    end.
  end.

  return.
end.

/* $Workfile$ end */