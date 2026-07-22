block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: go-attir.p $
$Archive: ref/go-attir.p $

Запуск интерфейса редактирования атрибутов товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/24/04
Author: Bakhtadze Natalya
Creation date: 11/24/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode      as character no-undo .
define input parameter p-mode-obj  as character no-undo .
define input parameter p-gds-code  like ub.goods.gds-code no-undo .
define input parameter p-obj-type  like ub.gds-obj-attr.obj-type  no-undo .
define input parameter p-obj-code  like ub.gds-obj-attr.obj-code  no-undo .
define input parameter p-update-on-exit as logical no-undo .
define output parameter p-modified as logical no-undo .
define output parameter p-is-error as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: go-attir.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/go-attir.p $":U .
define variable vss-description as character no-undo init "Запуск интерфейса редактирования атрибутов товара на объекте".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ ref/gdsoattr.i }

define variable v-update-attr as logical no-undo .

define temp-table tt0-gds-obj-attr no-undo like ub.gds-obj-attr.
define buffer buf_gds-obj-attr for ub.gds-obj-attr.
define buffer locked_gds-obj-attr for ub.gds-obj-attr.

do
on stop undo, return error return-value
:

  for each tt0-gds-obj-attr:
    delete tt0-gds-obj-attr.
  end.
  CASE p-mode:
    when {&update} then do:
      do on error undo, return error :
        Find first locked_gds-obj-attr exclusive-lock  where
                locked_gds-obj-attr.gds-code = p-gds-code
            AND locked_gds-obj-attr.obj-type = p-obj-type
            AND locked_gds-obj-attr.obj-code = p-obj-code
            and locked_gds-obj-attr.attr-code = {&attr-gds-obj-attr-lock-o}
            no-error no-wait.
        if not available locked_gds-obj-attr
        and not locked locked_gds-obj-attr then do:
          create locked_gds-obj-attr.
          assign
          locked_gds-obj-attr.obj-type =  p-obj-type
          locked_gds-obj-attr.obj-code = p-obj-code
          locked_gds-obj-attr.gds-code = p-gds-code
          locked_gds-obj-attr.attr-code = {&attr-gds-obj-attr-lock-o}
          .
        end.
        if locked locked_gds-obj-attr then do:
          Find first locked_gds-obj-attr exclusive-lock  where
                locked_gds-obj-attr.gds-code = p-gds-code
            AND locked_gds-obj-attr.obj-type = p-obj-type
            AND locked_gds-obj-attr.obj-code = p-obj-code
            and locked_gds-obj-attr.attr-code = {&attr-gds-obj-attr-lock-o}
            no-error .
        end.
      end.
      FOR EACH buf_gds-obj-attr no-lock  where
              buf_gds-obj-attr.gds-code = p-gds-code
      :

        if buf_gds-obj-attr.attr-code = {&attr-gds-obj-attr-lock-o} then next.
        CREATE tt0-gds-obj-attr.
        BUFFER-COPY buf_gds-obj-attr TO tt0-gds-obj-attr.
      END.
      run ref/gdsoatti.w (
                      input parparentproc
                    , input p-mode
                    , input p-mode-obj
                    , input p-gds-code
                    , input p-obj-type
                    , input p-obj-code
                    , input p-update-on-exit /*update on exit from form*/
                    , output p-modified
                    , input-output table tt0-gds-obj-attr
                          ) no-error.
      if error-status:error then do:
        assign
        p-is-error = yes
        .
      end.
      for each tt0-gds-obj-attr:
        delete tt0-gds-obj-attr.
      end.
      if p-is-error then do:
        return error substitute("&1 &2", error-status:get-message(1) , return-value ).
      end.
    end. /*update*/
    when {&lookup} then do:
      FOR EACH buf_gds-obj-attr no-lock where
              buf_gds-obj-attr.gds-code = p-gds-code:
        if buf_gds-obj-attr.attr-code = {&attr-gds-obj-attr-lock-o} then next.
        CREATE tt0-gds-obj-attr.
        BUFFER-COPY buf_gds-obj-attr TO tt0-gds-obj-attr.
      END.
      run ref/gdsoatti.w (
                      input parparentproc
                    , input p-mode
                    , input p-mode-obj
                    , input p-gds-code
                    , input p-obj-type
                    , input p-obj-code
                    , input p-update-on-exit /*update on exit from form*/
                    , output p-modified
                    , input-output table tt0-gds-obj-attr
                          ) no-error.
      if error-status:error then do:
        assign
        p-is-error = yes.

      end.
      for each tt0-gds-obj-attr:
        delete tt0-gds-obj-attr.
      end.
      if p-is-error then do:
        return error substitute("&1 &2", error-status:get-message(1) , return-value ).
      end.
    end. /*lookup*/
  end CASE.
end. /*doe*/