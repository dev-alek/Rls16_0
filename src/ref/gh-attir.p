block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gh-attir.p $
$Archive: ref/gh-attir.p $

Запуск интерфейса редактирования атрибутов товара на фирме

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/24/04
Author: Bakhtadze Natalya
Creation date: 11/24/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode      as character no-undo .
define input parameter p-gds-code  like ub.goods.gds-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code  no-undo .
define input parameter p-obj-type  like ub.clients.obj-type  no-undo .
define input parameter p-obj-code  like ub.clients.obj-code  no-undo .
define input parameter p-update-on-exit as logical no-undo .
define output parameter p-modified as logical no-undo .
define output parameter p-is-error as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gh-attir.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gh-attir.p $":U .
define variable vss-description as character no-undo init "Запуск интерфейса редактирования атрибутов товара на фирме".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

define variable v-update-attr as logical no-undo .

define temp-table tt0-gds-host-attr no-undo like ub.gds-host-attr.
define buffer buf_gds-host-attr for ub.gds-host-attr.

do TRANSACTION
on error undo, return error return-value
on stop undo, return error return-value
:

  for each tt0-gds-host-attr:
    delete tt0-gds-host-attr.
  end.

  if p-mode = {&update} then do:
    do on error undo, return error :
      FOR EACH buf_gds-host-attr exclusive-lock  where
               buf_gds-host-attr.gds-code = p-gds-code
           AND buf_gds-host-attr.host-code = p-host-code
      on error undo, return error :
          CREATE tt0-gds-host-attr.
          BUFFER-COPY buf_gds-host-attr TO tt0-gds-host-attr.
      END.
      run ref/gdshatti.w (
                      input parparentproc
                    , input p-mode
                    , input p-gds-code
                    , input p-obj-type
                    , input p-obj-code
                    , input p-update-on-exit /*update on exit from form*/
                    , output p-modified
                    , input-output table tt0-gds-host-attr
                          ) no-error.
      if error-status:error then do:
        assign
        p-is-error = yes.
      end.
      for each tt0-gds-host-attr:
        delete tt0-gds-host-attr.
      end.
      if p-is-error then do:
        return error substitute("&1 &2", error-status:get-message(1) , return-value ).
      end.
    end.
  end.
  else do:
    FOR EACH buf_gds-host-attr no-lock where
            buf_gds-host-attr.gds-code = p-gds-code
        AND buf_gds-host-attr.host-code = p-host-code :
        CREATE tt0-gds-host-attr.
        BUFFER-COPY buf_gds-host-attr TO tt0-gds-host-attr.
    END.
    run ref/gdshatti.w (
                    input parparentproc
                  , input p-mode
                  , input p-gds-code
                  , input p-obj-type
                  , input p-obj-code
                  , input p-update-on-exit /*update on exit from form*/
                  , output p-modified
                  , input-output table tt0-gds-host-attr
                        ) no-error.
    if error-status:error then do:
      assign
      p-is-error = yes.
    end.
    for each tt0-gds-host-attr:
      delete tt0-gds-host-attr.
    end.
    if p-is-error then do:
      return error substitute("&1 &2", error-status:get-message(1) , return-value ).
    end.
  end.
end. /*doe*/