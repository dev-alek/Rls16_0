block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: s-coeffr.p $
$Archive: ref/s-coeffr.p $

Запуск интерфейса редактирования сезонных коэффициентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/03/05
Author: Bakhtadze Natalya
Creation date: 04/03/05

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
define variable vss-workfile    as character no-undo init "$Workfile: s-coeffr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/s-coeffr.p $":U .
define variable vss-description as character no-undo init "Запуск интерфейса редактирования сезонных коэффициентов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

define variable v-update-attr as logical no-undo .

define temp-table tt0-s-coeff no-undo like ub.s-coeff.
define buffer buf_s-coeff for ub.s-coeff.

do
on error undo, return error return-value
on stop undo, return error return-value
:

  for each tt0-s-coeff:
    delete tt0-s-coeff.
  end.

  if p-mode = {&update} then do:
    do transaction on error undo, return error :
      FOR EACH buf_s-coeff exclusive-lock  where
               buf_s-coeff.gds-code = p-gds-code
      on error undo, return error :
          CREATE tt0-s-coeff.
          BUFFER-COPY buf_s-coeff TO tt0-s-coeff.
      END.
      run ref/scoeffs.w (
                      input parparentproc
                    , input p-mode
                    , input p-gds-code
                    , input p-obj-type
                    , input p-obj-code
                    , input p-update-on-exit /*update on exit from form*/
                    , output p-modified
                    , input-output table tt0-s-coeff
                          ) no-error.
      if error-status:error then do:
        assign
        p-is-error = yes.
      end.
      for each tt0-s-coeff:
        delete tt0-s-coeff.
      end.
      if p-is-error then do:
        return error substitute("&1 &2", error-status:get-message(1) , return-value ).
      end.
    end.
  end.
  else do:
    FOR EACH buf_s-coeff no-lock where
            buf_s-coeff.gds-code = p-gds-code :
        CREATE tt0-s-coeff.
        BUFFER-COPY buf_s-coeff TO tt0-s-coeff.
    END.
    run ref/scoeffs.w (
                    input parparentproc
                  , input p-mode
                  , input p-gds-code
                  , input p-obj-type
                  , input p-obj-code
                  , input p-update-on-exit /*update on exit from form*/
                  , output p-modified
                  , input-output table tt0-s-coeff
                        ) no-error.
    if error-status:error then do:
      assign
      p-is-error = yes.
    end.
    for each tt0-s-coeff:
      delete tt0-s-coeff.
    end.
    if p-is-error then do:
      return error substitute("&1 &2", error-status:get-message(1) , return-value ).
    end.
  end.
end. /*doe*/