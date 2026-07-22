block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dc-propr.p $
$Archive: ref/dc-propr.p $

Запуск интерфейса редактирования атрибутов ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/24/04
Author: Bakhtadze Natalya
Creation date: 11/24/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode   as character no-undo .
define input parameter p-d-card like ub.dis-card.d-card no-undo .
define input parameter p-emitent-host-code like ub.dis-card.emitent-host-code no-undo .
define input parameter p-type like ub.dis-card.type no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type  no-undo .
define input parameter p-obj-code  like ub.clients.obj-code  no-undo .
define input parameter p-update-on-exit as logical no-undo .
define output parameter p-modified as logical no-undo .
define output parameter p-is-error as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dc-propr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dc-propr.p $":U .
define variable vss-description as character no-undo init "Запуск интерфейса редактирования атрибутов ДК".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ ref/temp-dcp.i lock-proc }
define variable v-update-attr as logical no-undo .

define temp-table tt0-dis-card-property no-undo like ub.dis-card-property.
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer locked_dis-card-property for ub.dis-card-property.

do
on stop undo, return error
:

  for each tt0-dis-card-property:
    delete tt0-dis-card-property.
  end.

  if p-mode = {&update} then do:
    do on error undo, return error return-value :
      run lock-dcp in this-procedure ( input p-d-card, buffer locked_dis-card-property).
    end.
    FOR EACH buf_dis-card-property no-lock  where
    buf_dis-card-property.d-card = p-d-card
    on error undo, return error :
      if buf_dis-card-property.dtm-code = 0 then next.
      CREATE tt0-dis-card-property.
      BUFFER-COPY buf_dis-card-property TO tt0-dis-card-property.
    END.
    run ref/discprpi.w (
                    input parparentproc
                  , input p-mode
                  , input p-d-card
                  , input p-emitent-host-code
                  , input p-type
                  , input p-host-code
                  , input p-obj-type
                  , input p-obj-code
                  , input p-update-on-exit /*update on exit from form*/
                  , output p-modified
                  , input-output table tt0-dis-card-property
                        ) no-error.
    if error-status:error then do:
      assign
      p-is-error = yes.
    end.
    for each tt0-dis-card-property:
      delete tt0-dis-card-property.
    end.
  end.
  else do:
    FOR EACH buf_dis-card-property no-lock where
         buf_dis-card-property.d-card = p-d-card
    :
      if buf_dis-card-property.dtm-code = 0 then next.
      CREATE tt0-dis-card-property.
      BUFFER-COPY buf_dis-card-property TO tt0-dis-card-property.
    END.
    run ref/discprpi.w (
                    input parparentproc
                  , input p-mode
                  , input p-d-card
                  , input p-emitent-host-code
                  , input p-type
                  , input p-host-code
                  , input p-obj-type
                  , input p-obj-code
                  , input p-update-on-exit /*update on exit from form*/
                  , output p-modified
                  , input-output table tt0-dis-card-property
                        ) no-error.
    if error-status:error then do:
      assign
      p-is-error = yes.
    end.
    for each tt0-dis-card-property:
      delete tt0-dis-card-property.
    end.
  end.
end. /*doe*/