block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: e0fc85c3ab59, 1564, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Tue Nov 06 04:41:34 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: s-deploy.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/s-deploy.p $":U .
define variable vss-description as character no-undo init "Раскрутка системы" .
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define input parameter parparentproc as widget-handle no-undo .
DEFINE VARIABLE ri-list    as character no-undo .
define variable v-step     as integer   no-undo .
define variable v-all-step as integer   no-undo .
define variable v-ok       as logical      no-undo.
define variable v-rec      as recid        no-undo.
define variable v-host-code    as integer      no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
assign
  v-step     = 0
  v-all-step = 2
.
if v-cntxt-db-num = 0 then do:
  assign
    v-all-step = 13
  .
  message
    substitute( "Шаг 1 из &1", v-all-step ) skip (2)
    "Включить возможность добавления клиентов и товаров"
    view-as alert-box question buttons YES-NO-Cancel update v-ok.
  if v-ok = ? then do:
    return.
  end.
  if v-ok = true then do:
    run adm/dbs.w ( input parparentproc
                  , input 'ИЗМЕНЕНИЕ':U
                  , output v-rec).
  end.
  message
    substitute( "Шаг 2 из &1", v-all-step ) skip (2)
    "Добавить валюты и курсы (если нужны валюты кроме рубля)"
    view-as alert-box question buttons YES-NO-Cancel update v-ok.
  if v-ok = ? then do:
    return.
  end.
  if v-ok = true then do:
    assign
       v-rec = ?
    .
    run ref/currency.w ( input parparentproc
                       , input 'b-add,b-add-acc,b-add-bank'
                       , input-output v-rec
                       ) .
  end.
  message
    substitute( "Шаг 3 из &1", v-all-step ) skip (2)
    "Добавить группу клиентов для своих фирм, объектов"
    view-as alert-box question buttons YES-NO-Cancel update v-ok.
  if v-ok = ? then do:
    return.
  end.
  assign
   ri-list = "":U
  .
  if v-ok = true then do:
    run ref/cli-grps.w  ( input parparentproc
                        , input '':U
                        , input-output ri-list
                        ) .
  end.
  message
    substitute( "Шаг 4 из &1", v-all-step ) skip (2)
    "Добавить фирму (одну из своих организаций)," skip
    "добавить организацию 'Реализация в магазине', записав ее код."
    view-as alert-box question buttons YES-NO-Cancel update v-ok.
  if v-ok = ? then do:
    return.
  end.
  if v-ok = true then do:
    run ref/cli-all.w   ( input parparentproc
                        , input 'b-add'
                        , input 'все':U
                        , input 'все':U
                        , input 'все':U
                        , input ?
                        , input ",,,,,,NO,,"
                        , input "s-deploy":U
                        , output ri-list
                        ) .
  end.
  message
    substitute( "Шаг 5 из &1", v-all-step ) skip (2)
    "Создать фирму из организации"
    view-as alert-box question buttons YES-NO-Cancel update v-ok.
  if v-ok = ? then do:
    return.
  end.
  if v-ok = true then do:
    run adm/config.w ( input parparentproc
                     , input 0
                     , input 'ДОБАВЛЕНИЕ':U
                     , input yes
                     ) .
  end.
  assign
    v-step = 5
  .
end.
find first sysconf no-lock no-error.
if not available sysconf then do:
  message
    "Не найдена фирма."
    view-as alert-box error.
end.
assign
  v-host-code = sysconf.host-code
.
if v-cntxt-db-num = 0 then do:
  assign
    v-ok = yes
    ri-list = ""
  .
  message
    substitute( "Шаг 6 из &1", v-all-step ) skip (2)
    "Добавить объект" skip
    "Склад - YES" skip
    "Магазин - NO"
    view-as alert-box question buttons YES-NO-Cancel update v-ok.
  if v-ok = ? then do:
    return.
  end.
  if v-ok = true then do:
    run adm/stores.w ( INPUT parparentproc
                     , INPUT 'b-add'
                     , input-output ri-list
                     , INPUT YES
                     ) .
  end.
  else do:
    run adm/shops.w  ( INPUT parparentproc
                     , INPUT 'b-add'
                     , input-output ri-list
                     , INPUT YES
                     ) .
  end.
  define buffer buf_clients      for ub.clients .
  define buffer buf_user-obj     for ub.user-obj .
  FIND FIRST buf_clients
       WHERE buf_clients.obj-type = 'маг':U
          OR buf_clients.obj-type = 'скл':U
       NO-LOCK
       NO-ERROR
       .
  IF AVAILABLE buf_clients
  THEN DO:
   IF NOT CAN-FIND( FIRST buf_user-obj
                    WHERE buf_user-obj.db-num      = v-cntxt-db-num
                      AND buf_user-obj.user-id     = v-cntxt-userid
                      AND buf_user-obj.obj-type    = buf_clients.obj-type
                      AND buf_user-obj.obj-code    = buf_clients.obj-code
                    NO-LOCK
                  )
   THEN DO:
      create buf_user-obj.
      Assign
         buf_user-obj.db-num      = v-cntxt-db-num
         buf_user-obj.user-id     = v-cntxt-userid
         buf_user-obj.obj-type    = buf_clients.obj-type
         buf_user-obj.obj-code    = buf_clients.obj-code
         buf_user-obj.host-code   = buf_clients.host-code
      .
   END.
  END.
  assign
    v-step = 6
  .
end.
message
  substitute( "Шаг &1 из &2", v-step + 1, v-all-step ) skip (2)
  "Добавить группы прав"
  view-as alert-box question buttons YES-NO-Cancel update v-ok.
if v-ok = ? then do:
  return.
end.
if v-ok = true then do:
  define variable v-action-role-code as integer   no-undo .
  define variable v-context          as character no-undo .
    ASSIGN
      v-context = 'All':U
      ri-list = "":U
    .
    run str/actnrole.w ( input  parparentproc
                       , input  'b-add,rs-scope':U
                       , input-output v-context
                       , output v-action-role-code
                       , input-output ri-list
                       , input 0
                       ) .
end.
if v-cntxt-db-num = 0 then do:
  message
    substitute( "Шаг 11 из &1", v-all-step ) skip (2)
    "Добавить виды оплат, записать их коды"
  view-as alert-box question buttons YES-NO-Cancel update v-ok.
  if v-ok = ? then do:
    return.
  end.
  if v-ok = true then do:
    run ref/paytype.w ( input parparentproc
                      , input 'b-add,b-upd,b-del'
                      , output ri-list
                      ) .
  end.
  message
    substitute( "Шаг 12 из &1", v-all-step ) skip (2)
    "Добавить типы платежа, записать их коды"
  view-as alert-box question buttons YES-NO-Cancel update v-ok.
  if v-ok = ? then do:
    return.
  end.
  if v-ok = true then do:
    run ref/cashpays.w  ( input parparentproc
                        , input 'b-add,b-upd,b-del'
                        , input 'все':U
                        , input buf_clients.host-code
                        , input buf_clients.obj-type
                        , input buf_clients.obj-code
                        , output ri-list
                        ) .
  end.
  message
    substitute( "Шаг 13 из &1", v-all-step ) skip (2)
    "Прописать в фирме 'Код реализации' - код 'Реализации в магазине', НДС и код оплаты консигнации"
  view-as alert-box question buttons YES-NO-Cancel update v-ok.
  if v-ok = ? then do:
    return.
  end.
  if v-ok = true then do:
    run adm/config.w ( input parparentproc
                     , input v-host-code
                     , input 'ИЗМЕНЕНИЕ':U
                     , input no
                     ) .
  end.
end.
message
  "Раскрутка закончена!" skip (2)
  "Сейчас будет выход из этого режима." skip
  "Войти под новым паролем. Система готова к работе с новым паролем." skip (2)
  "Не забудьте:" skip
  "Записать коды оплат в объекты;" skip
  "Сформировать и отправить НОВОСТИ."
  view-as alert-box.
procedure s-deploy :
  do
  on error undo, return error
  :
  end.
end procedure.
