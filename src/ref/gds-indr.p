block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gds-indr.p $
$Archive: ref/gds-indr.p $

Запуск интерфейса редактирования атрибутов товара на объекте & фирме

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/03/05
Author: Bakhtadze Natalya
Creation date: 04/03/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-type      as character no-undo .
define input parameter p-mode      as character no-undo .
define input parameter p-gds-code  like ub.goods.gds-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo.
define input parameter p-obj-type  like ub.gds-obj-prop.obj-type  no-undo .
define input parameter p-obj-code  like ub.gds-obj-prop.obj-code  no-undo .
define input parameter p-update-on-exit as logical no-undo .
define output parameter p-modified as logical no-undo .
define output parameter p-is-error as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gds-indr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gds-indr.p $":U .
define variable vss-description as character no-undo init "Запуск интерфейса редактирования атрибутов товара на объекте".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

define variable v-update-attr as logical no-undo .

define temp-table tt0-gds-obj-prop no-undo like ub.gds-obj-prop.
define buffer buf_gds-obj-prop for ub.gds-obj-prop.
define temp-table tt0-gds-obj-prop-attr no-undo like ub.gds-obj-prop-attr.
define buffer buf_gds-obj-prop-attr for ub.gds-obj-prop-attr.

do
on error undo, return error return-value
on stop undo, return error return-value
:

  for each tt0-gds-obj-prop:
    delete tt0-gds-obj-prop.
  end.
  CASE p-mode:
    when {&update} then do:
      do transaction on error undo, return error :
        FOR EACH buf_gds-obj-prop exclusive-lock  where
                buf_gds-obj-prop.gds-code = p-gds-code
            AND buf_gds-obj-prop.obj-type = p-obj-type
            AND buf_gds-obj-prop.obj-code = p-obj-code
        on error undo, return error:
          CREATE tt0-gds-obj-prop.
          BUFFER-COPY buf_gds-obj-prop TO tt0-gds-obj-prop.
        END.
        if p-type = "orders":U
        then do:
          FOR EACH buf_gds-obj-prop-attr exclusive-lock  where
                  buf_gds-obj-prop-attr.gds-code = p-gds-code
              AND buf_gds-obj-prop-attr.obj-type = p-obj-type
              AND buf_gds-obj-prop-attr.obj-code = p-obj-code
          on error undo, return error:
            if lookup(buf_gds-obj-prop-attr.attr-code, {&gdspoatr-list-spec}) > 0 then next.
            CREATE tt0-gds-obj-prop-attr.
            BUFFER-COPY buf_gds-obj-prop-attr TO tt0-gds-obj-prop-attr.
          END.
      end.
      end.
      if p-type = "orders":U
      or p-type = "ordersf":U then do:
          run ref/ord-ind.w (
                      input parparentproc
                    , input p-mode
                    , input p-gds-code
                    , input p-host-code
                    , input p-obj-type
                    , input p-obj-code
                    , input p-update-on-exit /*update on exit from form*/
                    , output p-modified
                    , input-output table tt0-gds-obj-prop
                  , input-output table tt0-gds-obj-prop-attr
                          ) no-error.
     end.
     else do:
      run ref/gds-ind.w (
                      input parparentproc
                    , input p-mode
                    , input p-gds-code
                    , input p-host-code
                    , input p-obj-type
                    , input p-obj-code
                    , input p-update-on-exit /*update on exit from form*/
                    , output p-modified
                    , input-output table tt0-gds-obj-prop
                          ) no-error.
     end.
      if error-status:error then do:
        assign
        p-is-error = yes
        .
      end.
      for each tt0-gds-obj-prop:
        delete tt0-gds-obj-prop.
      end.
      for each tt0-gds-obj-prop-attr:
        delete tt0-gds-obj-prop-attr.
      end.
      if p-is-error then do:
        return error substitute("&1 &2", error-status:get-message(1) , return-value ).
      end.
    end. /*update*/
    when {&lookup} then do:
      FOR EACH buf_gds-obj-prop no-lock where
              buf_gds-obj-prop.gds-code = p-gds-code
          AND buf_gds-obj-prop.obj-type = p-obj-type
          AND buf_gds-obj-prop.obj-code = p-obj-code :
          CREATE tt0-gds-obj-prop.
          BUFFER-COPY buf_gds-obj-prop TO tt0-gds-obj-prop.
      END.
      if p-type = "orders":U
      then do:
        FOR EACH buf_gds-obj-prop-attr no-lock where
                buf_gds-obj-prop-attr.gds-code = p-gds-code
            AND buf_gds-obj-prop-attr.obj-type = p-obj-type
            AND buf_gds-obj-prop-attr.obj-code = p-obj-code :
          if lookup(buf_gds-obj-prop-attr.attr-code, {&gdspoatr-list-spec}) > 0 then next.
            CREATE tt0-gds-obj-prop-attr.
            BUFFER-COPY buf_gds-obj-prop-attr TO tt0-gds-obj-prop-attr.
        END.
      end.
      if p-type = "orders":U
      or p-type = "ordersf":U then do:
         run ref/ord-ind.w (
                      input parparentproc
                    , input p-mode
                    , input p-gds-code
                    , input p-host-code
                    , input p-obj-type
                    , input p-obj-code
                    , input p-update-on-exit /*update on exit from form*/
                    , output p-modified
                    , input-output table tt0-gds-obj-prop
                    , input-output table tt0-gds-obj-prop-attr
                          ) no-error.
      end.
      else do:
        run ref/gds-ind.w (
                      input parparentproc
                    , input p-mode
                    , input p-gds-code
                    , input p-host-code
                    , input p-obj-type
                    , input p-obj-code
                    , input p-update-on-exit /*update on exit from form*/
                    , output p-modified
                    , input-output table tt0-gds-obj-prop
                          ) no-error.
      end.
      if error-status:error then do:
        assign
        p-is-error = yes.

      end.
      for each tt0-gds-obj-prop:
        delete tt0-gds-obj-prop.
      end.
      for each tt0-gds-obj-prop-attr:
        delete tt0-gds-obj-prop-attr.
      end.
      if p-is-error then do:
        return error substitute("&1 &2", error-status:get-message(1) , return-value ).
      end.
    end. /*lookup*/
  end CASE.
end. /*doe*/