block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ddcrattr.p $
$Archive: ref/ddcrattr.p $

Запуск интерфейса редактирования скидок ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/24/04
Author: Bakhtadze Natalya
Creation date: 11/24/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode   as character no-undo .
define input parameter p-d-card like ub.dis-card.d-card no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type  no-undo .
define input parameter p-obj-code  like ub.clients.obj-code  no-undo .
define input parameter p-update-on-exit as logical no-undo .
define output parameter p-modified as logical no-undo .
define output parameter p-is-error as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ddcrattr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/ddcrattr.p $":U .
define variable vss-description as character no-undo init "Запуск интерфейса редактирования скидок ДК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-update-attr as logical no-undo .
define variable dflt-cd as character no-undo .
define temp-table tt0-dis-dc-rule no-undo like ub.dis-dc-rule.
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
define buffer locked_dis-dc-rule for ub.dis-dc-rule.

do
on stop undo, return error
:

  for each tt0-dis-dc-rule:
    delete tt0-dis-dc-rule.
  end.
  if g#db-num > 0 then do:
    if p-obj-type = {&shop} then do:
      { gbl/dflt-cd.i p-obj-type p-obj-code dflt-cd }
    end.
    else do:
       dflt-cd = {&cd-type-no-cd}.
    end.
  end.

  if p-mode = {&update} then do:
    do on error undo, return error return-value :
      Find first locked_dis-dc-rule exclusive-lock  where
              locked_dis-dc-rule.d-card = p-d-card
          AND locked_dis-dc-rule.host-code = (if g#db-num = 0 then 0 else p-host-code)
          AND locked_dis-dc-rule.obj-type = (if g#db-num = 0 then '':U else p-obj-type)
          AND locked_dis-dc-rule.obj-code = (if g#db-num = 0 then 0 else p-obj-code)
          and locked_dis-dc-rule.discnt-role = '':U
          and locked_dis-dc-rule.pos-type = '':U
          and locked_dis-dc-rule.nonunique = '':U
          no-error no-wait.
      if not available locked_dis-dc-rule
      and not locked locked_dis-dc-rule then do:
        create locked_dis-dc-rule.
        assign
        locked_dis-dc-rule.host-code = (if g#db-num = 0 then 0 else p-host-code)
        locked_dis-dc-rule.obj-type =  (if g#db-num = 0 then '':U else p-obj-type)
        locked_dis-dc-rule.obj-code = (if g#db-num = 0 then 0 else p-obj-code)
        locked_dis-dc-rule.d-card = p-d-card
        locked_dis-dc-rule.discnt-role = '':U
        locked_dis-dc-rule.nonunique = '':U
        locked_dis-dc-rule.pos-type = '':U
        .
      end.
      if locked locked_dis-dc-rule then do:
      Find first locked_dis-dc-rule exclusive-lock  where
              locked_dis-dc-rule.d-card = p-d-card
          AND locked_dis-dc-rule.host-code = (if g#db-num = 0 then 0 else p-host-code)
          AND locked_dis-dc-rule.obj-type =  (if g#db-num = 0 then '':U else p-obj-type)
          AND locked_dis-dc-rule.obj-code = (if g#db-num = 0 then 0 else p-obj-code)
          and locked_dis-dc-rule.discnt-role = '':U
          and locked_dis-dc-rule.nonunique = '':U
          and locked_dis-dc-rule.pos-type = '':U
          no-error .
      end.
    end.
    FOR EACH buf_dis-dc-rule no-lock  where
    buf_dis-dc-rule.d-card = p-d-card
    on error undo, return error :
      if buf_dis-dc-rule.nonunique = '':U
      and buf_dis-dc-rule.pos-type = '':U
      and buf_dis-dc-rule.discnt-role = '':U
      then next.
      CREATE tt0-dis-dc-rule.
      BUFFER-COPY buf_dis-dc-rule TO tt0-dis-dc-rule.
    END.
    run ref/dis-dcri.w (
                    input parparentproc
                  , input p-mode
                  , input p-d-card
                  , input p-host-code
                  , input p-obj-type
                  , input p-obj-code
                  , input dflt-cd  /*p-pos-type*/
                  , input p-update-on-exit /*update on exit from form*/
                  , output p-modified
                  , input-output table tt0-dis-dc-rule
                        ) no-error.
    if error-status:error then do:
      assign
      p-is-error = yes.
    end.
    for each tt0-dis-dc-rule:
      delete tt0-dis-dc-rule.
    end.
  end.
  else do:
    FOR EACH buf_dis-dc-rule no-lock where
         buf_dis-dc-rule.d-card = p-d-card
    on error undo, return error :

      if buf_dis-dc-rule.pos-type = '':U
      and buf_dis-dc-rule.discnt-role = '':U
      and buf_dis-dc-rule.nonunique = '':U
      then next.
      CREATE tt0-dis-dc-rule.
      BUFFER-COPY buf_dis-dc-rule TO tt0-dis-dc-rule.
    END.
    run ref/dis-dcri.w (
                    input parparentproc
                  , input p-mode
                  , input p-d-card
                  , input p-host-code
                  , input p-obj-type
                  , input p-obj-code
                  , input dflt-cd /*p-pos-type*/
                  , input p-update-on-exit /*update on exit from form*/
                  , output p-modified
                  , input-output table tt0-dis-dc-rule
                        ) no-error.
    if error-status:error then do:
      assign
      p-is-error = yes.
    end.
    for each tt0-dis-dc-rule:
      delete tt0-dis-dc-rule.
    end.
  end.
end. /*doe*/