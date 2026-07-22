block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.inkas .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи продажа".
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
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define buffer buf_sysconf  for ub.sysconf .
define buffer buf_cash-pay for ub.cash-pay.
main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    if  (ub.inkas.status_ = 'факт':U
        or
        ub.inkas.status_ = 'запрос':U )
        and ub.inkas.is-del = no
        then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Нельзя удалять продажу, закрытую до статуса" ub.inkas.status_ skip
            "Номер продажи" ub.inkas.inkas-code skip
            "Статус продажи" ub.inkas.status_ skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    find first ub.inkas-pay no-lock
        where ub.inkas-pay.inkas-code = ub.inkas.inkas-code
        no-error .
    if available ub.inkas-pay then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении документа продажи" skip
            "Найдена строка документа продажи" skip
            "Продажа" ub.inkas-pay.inkas-code skip
            "pay-code" ub.inkas-pay.pay-code skip
            "curr-code" ub.inkas-pay.curr-code skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    find first ub.inkas-pay-desk no-lock
        where ub.inkas-pay-desk.inkas-code = ub.inkas.inkas-code
        no-error .
    if available ub.inkas-pay-desk then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении документа продажи" skip
            "Найдена строка документа продажи - выручка по кассе" skip
            "Продажа" ub.inkas-pay-desk.inkas-code skip
            "pay-code" ub.inkas-pay-desk.pay-code skip
            "curr-code" ub.inkas-pay-desk.curr-code skip
            "pay-desk" ub.inkas-pay-desk.pay-desk skip
            "doc-type" ub.inkas-pay-desk.doc-type skip
            "cashier" ub.inkas-pay-desk.cashier skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    find first ub.inkas-pay-wth no-lock
        where ub.inkas-pay-wth.inkas-code = ub.inkas.inkas-code
        no-error .
    if available ub.inkas-pay-wth then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении документа продажи" skip
            "Найдена строка документа продажи - выручка по кассе с номиналами" skip
            "Продажа" ub.inkas-pay-wth.inkas-code skip
            "pay-code" ub.inkas-pay-wth.pay-code skip
            "curr-code" ub.inkas-pay-wth.curr-code skip
            "wth-code" ub.inkas-pay-wth.wth-code skip
            "par-code" ub.inkas-pay-wth.par-code skip
            "pay-desk" ub.inkas-pay-wth.pay-desk skip
            "chk-type" ub.inkas-pay-wth.chk-type skip
            "cashier" ub.inkas-pay-wth.cashier skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    if not g#news then
    do:
        find first ub.chk-doc no-lock
            where ub.chk-doc.out-code = ub.inkas.inkas-code
            no-error .
        if available ub.chk-doc then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении документа продажи" skip
                "Найдена чек привязанный к продаже" skip
                "Продажа" ub.inkas.inkas-code skip
                "Код чека" ub.chk-doc.doc-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.
        find first ub.chk-gds no-lock
            where ub.chk-gds.out-code = ub.inkas.inkas-code
            no-error .
        if available ub.chk-gds then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении документа продажи" skip
                "Найдена строка чека привязанная к продаже" skip
                "Продажа" ub.inkas.inkas-code skip
                "Код чека" ub.chk-gds.doc-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.
        find first ub.chk-pay no-lock
            where ub.chk-pay.out-code = ub.inkas.inkas-code
            no-error .
        if available ub.chk-pay then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении документа продажи" skip
                "Найдена строка оплаты, привязанная к продаже" skip
                "Продажа" ub.inkas.inkas-code skip
                "Код чека" ub.chk-pay.doc-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.
        find first ub.chk-discnt no-lock
            where ub.chk-discnt.out-code = ub.inkas.inkas-code
            no-error .
        if available ub.chk-discnt then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении документа продажи" skip
                "Найдена строка скидки привязанная к продаже" skip
                "Продажа" ub.inkas.inkas-code skip
                "Код чека" ub.chk-discnt.doc-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    if not g#news
        and (ub.inkas.status_ = 'факт':U
        or
        ub.inkas.status_ = 'запрос':U
        )
        then
    do:
        run nws/cmd-del.p
            ( input "inkas":U
            ,input (buffer ub.inkas:handle)
            ,input "":U
            ) no-error .
        if error-status :error then
        do:
            undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( error-status :num-messages ) ).
        end.
    end.
    if g#oxml = yes
        then
    do:
        run str/calloxml.p (
            input 'delete':U
            , input 'inkas':U
            , input ( buffer ub.inkas:handle )
            ) no-error.
        if error-status :error
            then
        do:
            undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_inkas':U
  ,input  buffer ub.inkas:handle
  ,input ''
  ,input ''
  ,input ''
  ) no-error .
    if error-status :error
        then
    do:
        return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
            , chr(10)
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
    end.
    run trg/userlog.p (
        input 'delete':U
        , input 'inkas':U
        , input ( buffer ub.inkas :handle )
        , input ?
        , input ""
        ) no-error.
    if error-status :error
        then
    do:
        undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
            , chr(10)
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
    end.
end.
