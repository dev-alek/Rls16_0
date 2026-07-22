block-level on error undo, throw.

/*

$Revision: e0fc85c3ab59, 1564, rls $
$Author: PGridchina $
$Date: Tue Nov 06 04:41:34 2018 +0300 $
$Workfile: s-deploy.p $
$Archive: utl/s-deploy.p $

Раскрутка системы

Автор: Белоусов Илья Александрович
Дата создания: 03/26/08
Author: Ilia Belousov
Creation date: 03/26/08

*/
define variable vss-revision    as character no-undo init "$Revision: e0fc85c3ab59, 1564, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Tue Nov 06 04:41:34 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: s-deploy.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/s-deploy.p $":U .
define variable vss-description as character no-undo init "Раскрутка системы" .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }


define input parameter parparentproc as widget-handle no-undo .

DEFINE VARIABLE ri-list    as character no-undo .
define variable v-step     as integer   no-undo .
define variable v-all-step as integer   no-undo .
define variable v-ok       as logical      no-undo.
define variable v-rec      as recid        no-undo.
define variable v-host-code    as integer      no-undo.

{ gbl/getcntxt.i get }

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
                  , input {&update}
                  , output v-rec).
  end.

  message
    substitute( "Шаг 2 из &1", v-all-step ) skip (2)
    "Добавить валюты и курсы (если нужны валюты кроме {&abbr_rublya})"
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
                        , input {&all}
                        , input {&all}
                        , input {&all}
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
    run adm/config.w ( input parparentproc /*parparentproc*/
                     , input 0 /*host-code*/
                     , input {&add-def} /*p-mode*/
                     , input yes /*p-is-deploy*/
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
       WHERE buf_clients.obj-type = {&shop}
          OR buf_clients.obj-type = {&stock}
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
                        , input {&all}
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
    run adm/config.w ( input parparentproc /*parparentproc*/
                     , input v-host-code /*p-host-code*/
                     , input {&update} /*p-mode*/
                     , input no /*p-is-deploy*/
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

end procedure. /* s-deploy */