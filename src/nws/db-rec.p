block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: db-rec.p $
$Archive: nws/db-rec.p $

Выполнение (удаленное) операций над записями

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/08/05
Author: Dmitry Ukhanov
Creation date: 09/08/05

*/

define input parameter p-action       as character no-undo .
define input parameter p-uniq-key-rec as character no-undo .
define input parameter p-parameters   as character no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: db-rec.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/db-rec.p $":U .
def var vss-description as character no-undo init "Выполнение (удаленное) операций над записями".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/trg-def.i  }
{ nws/db-rec.i   }

do
on error  undo, return error substitute("&1. error &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo, return error substitute("&1. endkey")
on stop   undo, return error substitute("&1. stop")
:
  define variable v-main-prog-name      as character no-undo .
  define variable v-list-db-proc-name   as character no-undo .
  define variable v-commit-proc-name    as character no-undo .
  define variable v-execution-proc-name as character no-undo .
  define variable v-recover-proc-name   as character no-undo .
  define variable v-after-proc-name     as character no-undo .
  define variable v-ext-prg-handle      as handle    no-undo .

  define variable v-err-msg      as character no-undo .
  define variable v-ind          as integer   no-undo .
  define variable v-num-entries  as integer   no-undo .
  define variable v-send-db-list as character no-undo .
  define variable v-all-db-list  as character no-undo .
  define variable v-curr-db      as integer   no-undo .
  define variable v-db-init      as integer   no-undo .
  define variable v-operation    as character no-undo .
  define variable v-answer-code  as integer   no-undo .
  define variable v-answer-msg   as character no-undo .

  define variable v-is-begin     as logical   no-undo .
  define variable v-run-proc     as logical   no-undo .
  define variable v-command      as character no-undo .

  define buffer buf_sys-ctrl    for ub.sys-ctrl .
  define buffer buf_db          for ub.db .
  define buffer buf_db-rec-attr for ub.db-rec-attr .

  if num-entries( p-action, {&delim-nws} ) = 2 then do:
    if entry( 2, p-action, {&delim-nws} ) = "not-begin":U then do:
      assign
        p-action   = entry( 1, p-action, {&delim-nws} )
        v-is-begin = false
      .
    end.
    else do:
      undo, return error substitute( "Недопустимый тип операции &1 над записью &2", p-action, p-uniq-key-rec ).
    end.
  end.
  else do:
    assign
      v-is-begin = true
    .
  end.

  find first buf_sys-ctrl no-lock .
  assign
    v-curr-db  = buf_sys-ctrl.db-num
    v-run-proc = true
  .

  run progs-name( input p-action
                 ,output v-main-prog-name
                 ,output v-list-db-proc-name
                 ,output v-commit-proc-name
                 ,output v-execution-proc-name
                 ,output v-recover-proc-name
                 ,output v-after-proc-name
                ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при определении имен процедур. &2", vss-workfile, return-value ).
  end.

  run value( v-list-db-proc-name )
    ( input p-action
     ,input p-uniq-key-rec
     ,output v-all-db-list
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при определении списка БД. &2", vss-workfile, return-value ).
  end.

  assign
    v-send-db-list = get-send-db-list( v-curr-db, v-all-db-list )
  .

  find first buf_db-rec-attr exclusive-lock
    where buf_db-rec-attr.db-num       = v-curr-db
      and buf_db-rec-attr.uniq-key-rec = p-uniq-key-rec
      and buf_db-rec-attr.attr-code    = p-action
    no-wait no-error.

  if available buf_db-rec-attr
    or ( not available buf_db-rec-attr
         and locked buf_db-rec-attr
       )
  then do:
    if v-is-begin = true then do:
      if g#news = true then do:
        return substitute( "Операция &1 над записью &2 уже производится"
                            , p-action, p-uniq-key-rec
                          ).
      end.
      else do:
        undo, return error substitute( "Операция &1 над записью &2 уже производится", p-action, p-uniq-key-rec ).
      end.
    end.
  end.
  else do:
    if v-is-begin = false then do:
      undo, return error substitute( "Недопустимо начинать выполнять операцию &1 над записью &2 без ее инициализации", p-action, p-uniq-key-rec ).
    end.
    find first buf_db-rec-attr exclusive-lock
      where buf_db-rec-attr.uniq-key-rec = p-uniq-key-rec
        and buf_db-rec-attr.attr-code    = p-action
      no-wait no-error.

    if available buf_db-rec-attr
      or ( not available buf_db-rec-attr
          and locked buf_db-rec-attr
        )
    then do:
      undo, return error substitute( "&1. Уже есть запрос с кодом &2 для записи &3.", vss-workfile, p-action, p-uniq-key-rec ).
    end.

    assign
      v-db-init     = 0
      v-num-entries = num-entries( v-send-db-list, {&comma-char} )
    .
    if not ( ( v-num-entries = 1
                and v-send-db-list <> "0":U
              )
              or v-num-entries >= 2
            )
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Данная процедура предназначена только для работы с" skip
        "несколькими БД, а запускается для работы с одной!!!" skip
        "Список БД:" v-send-db-list
        view-as alert-box error.
      undo, return error.
    end.
    if v-curr-db <> 0 then do: /* and v-is-begin = true */
      assign
        v-run-proc = false
        v-command = "command":U + {&delim-nws}
                    + "inquiry-two-commit":U + {&delim-nws}
                    + p-action + {&delim-nws}
                    + p-uniq-key-rec + {&delim-nws}
                    + p-parameters
      .
      run nws/cr-route.p ( input {&send-cmd}
                      ,input v-command
                      ,input ?
                      ,input "0":U
                    ) no-error .
      if error-status :error then do:
        undo, return error substitute( "&1. Ошибка при отправке команды на выполнение операции над записью &2.&3&4&5&6"
                                       , vss-workfile
                                       , p-uniq-key-rec
                                       , {&new-line}
                                       , return-value
                                       , {&new-line}
                                       , error-status :get-message(1)
                                     ).
      end.
    end.
    else do:
      do v-ind = 1 to v-num-entries
      :
        create buf_db-rec-attr.
        assign
          buf_db-rec-attr.db-num             = integer( entry( v-ind, v-send-db-list, {&comma-char} ) )
          buf_db-rec-attr.uniq-key-rec       = p-uniq-key-rec
          buf_db-rec-attr.attr-code          = p-action
          buf_db-rec-attr.attr-type          = "commit":U
          buf_db-rec-attr.attr-value         = p-parameters
          buf_db-rec-attr.attr-value-decimal = v-db-init
          buf_db-rec-attr.attr-value-date    = TODAY
          buf_db-rec-attr.attr-value-logical = FALSE
        .
        release buf_db-rec-attr.
      end.

      run create_msg_route in this-procedure
        ( input v-send-db-list
         ,input substitute( "Начинается выполнение операции &1 над записью &2"
                            ,p-action
                            ,p-uniq-key-rec
                          )
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "&1. Ошибка при отправке сообщения по СПН. &2", vss-workfile, return-value ).
      end.
    end.
  end.

  if v-run-proc = true then do:
    find first buf_db-rec-attr exclusive-lock
      where buf_db-rec-attr.db-num       = v-curr-db
        and buf_db-rec-attr.uniq-key-rec = p-uniq-key-rec
        and buf_db-rec-attr.attr-code    = p-action
    .
    assign
      v-db-init   = buf_db-rec-attr.attr-value-decimal
      v-operation = buf_db-rec-attr.attr-type
    .

    run value( v-main-prog-name ) persistent
        set v-ext-prg-handle .

    case buf_db-rec-attr.attr-type :
      when "commit":U then do:
        if v-run-proc = true then do:
          run value( v-commit-proc-name ) in v-ext-prg-handle
            ( input buf_db-rec-attr.db-num
            , input buf_db-rec-attr.uniq-key-rec
            , input buf_db-rec-attr.attr-code
            , input buf_db-rec-attr.attr-value
            , output v-err-msg
            ) no-error .
          if error-status :error then do:
            undo, return error substitute( "&1. Ошибка при блокировке записи &2.&3&4&5&6"
                                           , vss-workfile
                                           , buf_db-rec-attr.uniq-key-rec
                                           , {&new-line}
                                           , return-value
                                           , {&new-line}
                                           , error-status :get-message(1)
                                         ).
          end.
        end.
        if v-is-begin = true then do:
          if v-err-msg = "":U then do:
            run create_db-rec_route in this-procedure
              ( input p-uniq-key-rec
              , input p-action
              , input "commit":U
              , input v-send-db-list
              , input v-db-init
              , input p-parameters
              , input -1
              , input ""
              ) no-error .
            if error-status :error then do:
              undo, return error substitute( "&1. Ошибка при отправке команды по СПН. &2", vss-workfile, return-value ).
            end.
          end.
          else do:
            for each buf_db-rec-attr
              where buf_db-rec-attr.uniq-key-rec = p-uniq-key-rec
                and buf_db-rec-attr.attr-code    = p-action
            on error  undo, return error substitute("&1. error buf_db-rec-attr &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
            on endkey undo, return error substitute("&1. endkey buf_db-rec-attr")
            on stop   undo, return error substitute("&1. stop buf_db-rec-attr")
            :
              delete buf_db-rec-attr.
            end.
          end.
        end.
      end.
      when "execution":U then do:
        run value( v-execution-proc-name ) in v-ext-prg-handle
          ( input buf_db-rec-attr.db-num
          , input buf_db-rec-attr.uniq-key-rec
          , input buf_db-rec-attr.attr-code
          , input buf_db-rec-attr.attr-value
          , output v-err-msg
          ) no-error .
        if error-status :error then do:
          undo, return error substitute( "&1. Ошибка при выполнении операции над записью &2.&3&4&5&6"
                                         , vss-workfile
                                         , buf_db-rec-attr.uniq-key-rec
                                         , {&new-line}
                                         , return-value
                                         , {&new-line}
                                         , error-status :get-message(1)
                                       ).
        end.
      end.
      when "recover":U then do:
        run value( v-recover-proc-name ) in v-ext-prg-handle
          ( input buf_db-rec-attr.db-num
          , input buf_db-rec-attr.uniq-key-rec
          , input buf_db-rec-attr.attr-code
          , input buf_db-rec-attr.attr-value
          , output v-err-msg
          ) no-error .
        if error-status :error then do:
          undo, return error substitute( "&1. Ошибка при выполнении отката операции над записью &2.&3&4&5&6"
                                         , vss-workfile
                                         , buf_db-rec-attr.uniq-key-rec
                                         , {&new-line}
                                         , return-value
                                         , {&new-line}
                                         , error-status :get-message(1)
                                       ).
        end.
      end.
    end case.

    delete procedure v-ext-prg-handle .

    if v-err-msg <> "":U then do:
      return v-err-msg .
    end.
    else do:
      assign
        buf_db-rec-attr.attr-value-date    = TODAY
        buf_db-rec-attr.attr-value-logical = TRUE
      .
    end.
  end.

  return.

end.

/* $Workfile: db-rec.p $ end */