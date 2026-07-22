block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dgrattir.p $
$Archive: ref/dgrattir.p $

Запуск интерфейса редактирования скидок товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/06
Author: Bakhtadze Natalya
Creation date: 12/10/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode      as character no-undo .
define input parameter p-mode-obj  as character no-undo .
define input parameter p-gds-code  like ub.goods.gds-code no-undo .
define input parameter p-obj-type  like ub.dis-gds-rule.obj-type  no-undo .
define input parameter p-obj-code  like ub.dis-gds-rule.obj-code  no-undo .
define input parameter p-update-on-exit as logical no-undo .
define output parameter p-modified as logical no-undo .
define output parameter p-is-error as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dgrattir.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dgrattir.p $":U .
define variable vss-description as character no-undo init "Запуск интерфейса редактирования скидок товара, действующих на объекте".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-update-attr as logical no-undo .
define variable dflt-cd as character no-undo .

define temp-table tt0-dis-gds-rule no-undo like ub.dis-gds-rule.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer locked_dis-gds-rule for ub.dis-gds-rule.

do
on stop undo, return error return-value
:

  for each tt0-dis-gds-rule:
    delete tt0-dis-gds-rule.
  end.
  CASE p-mode:
    when {&update} then do:
      do on error undo, return error :
        Find first locked_dis-gds-rule exclusive-lock  where
                locked_dis-gds-rule.gds-code = p-gds-code
            AND locked_dis-gds-rule.obj-type = (if g#db-num = 0 then '':U else p-obj-type)
            AND locked_dis-gds-rule.obj-code = (if g#db-num = 0 then 0 else p-obj-code)
            AND locked_dis-gds-rule.pos-type = '':U
            and locked_dis-gds-rule.discnt-role = '':U
            and locked_dis-gds-rule.nonunique = '':U
            no-error no-wait.
        if not available locked_dis-gds-rule
        and not locked locked_dis-gds-rule then do:
          create locked_dis-gds-rule.
          assign
          locked_dis-gds-rule.obj-type =  (if g#db-num = 0 then '':U else p-obj-type)
          locked_dis-gds-rule.obj-code = (if g#db-num = 0 then 0 else p-obj-code)
          locked_dis-gds-rule.gds-code = p-gds-code
          locked_dis-gds-rule.pos-type = '':U
          locked_dis-gds-rule.discnt-role = '':U
          locked_dis-gds-rule.nonunique = '':U
          .
        end.
        if locked locked_dis-gds-rule then do:
          Find first locked_dis-gds-rule exclusive-lock  where
                locked_dis-gds-rule.gds-code = p-gds-code
            AND locked_dis-gds-rule.obj-type = (if g#db-num = 0 then '':U else p-obj-type)
            AND locked_dis-gds-rule.obj-code = (if g#db-num = 0 then 0 else p-obj-code)
            AND locked_dis-gds-rule.pos-type = '':U
            and locked_dis-gds-rule.discnt-role = '':U
            and locked_dis-gds-rule.nonunique = '':U
            no-error .
        end.
      end.
      FOR EACH buf_dis-gds-rule no-lock  where
              buf_dis-gds-rule.gds-code = p-gds-code
      on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo , return error substitute( "&1. stop", vss-workfile )
      on endkey undo , return error substitute( "&1. endkey", vss-workfile )
      :
        if buf_dis-gds-rule.pos-type = '':U
        and buf_dis-gds-rule.discnt-role = '':U
        and buf_dis-gds-rule.nonunique = '':U  then next.
        CREATE tt0-dis-gds-rule.
        BUFFER-COPY buf_dis-gds-rule TO tt0-dis-gds-rule.
      END.
      run ref/dis-gdsi.w (
                      input parparentproc
                    , input p-mode
                    , input p-mode-obj
                    , input p-gds-code
                    , input p-obj-type
                    , input p-obj-code
                    , input (if p-mode-obj = {&g___object} then dflt-cd else '':U)
                    , input p-update-on-exit /*update on exit from form*/
                    , output p-modified
                    , input-output table tt0-dis-gds-rule
                          ) no-error.
      if error-status:error then do:
        assign
        p-is-error = yes
        .
      end.
      for each tt0-dis-gds-rule:
        delete tt0-dis-gds-rule.
      end.
      if p-is-error then do:
        return error substitute("&1 &2", error-status:get-message(1) , return-value ).
      end.
    end. /*update*/
    when {&lookup} then do:
      FOR EACH buf_dis-gds-rule no-lock where
              buf_dis-gds-rule.gds-code = p-gds-code:
        if buf_dis-gds-rule.pos-type = '':U
        and buf_dis-gds-rule.discnt-role = '':U
        and buf_dis-gds-rule.nonunique = '':U  then next.
        CREATE tt0-dis-gds-rule.
        BUFFER-COPY buf_dis-gds-rule TO tt0-dis-gds-rule.
      END.
      run ref/dis-gdsi.w (
                      input parparentproc
                    , input p-mode
                    , input p-mode-obj
                    , input p-gds-code
                    , input p-obj-type
                    , input p-obj-code
                    , input (if p-mode-obj = {&g___object} then dflt-cd else '':U)
                    , input p-update-on-exit /*update on exit from form*/
                    , output p-modified
                    , input-output table tt0-dis-gds-rule
                          ) no-error.
      if error-status:error then do:
        assign
        p-is-error = yes.

      end.
      for each tt0-dis-gds-rule:
        delete tt0-dis-gds-rule.
      end.
      if p-is-error then do:
        return error substitute("&1 &2", error-status:get-message(1) , return-value ).
      end.
    end. /*lookup*/
  end CASE.
end. /*doe*/