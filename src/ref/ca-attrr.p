block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ca-attrr.p $
$Archive: ref/ca-attrr.p $

Запуск интерфейса редактирования атрибутов клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/04/05
Author: Bakhtadze Natalya
Creation date: 04/04/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode   as character no-undo .
define input parameter p-obj-type  like ub.clients.obj-type  no-undo .
define input parameter p-obj-code  like ub.clients.obj-code  no-undo .
define input parameter p-update-on-exit as logical no-undo .
define output parameter p-modified as logical no-undo .
define output parameter p-is-error as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ca-attrr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/ca-attrr.p $":U .
define variable vss-description as character no-undo init "Запуск интерфейса редактирования атрибутов клиентов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/clntattr.i }
define variable v-update-attr as logical no-undo .

define variable v-attr-type as character no-undo . /*тип атрибута*/
define variable v-attr-format as character no-undo .  /* формат атрибута*/
define variable v-attr-label as character no-undo .         /*лабел атрибута */
define variable v-attr-user-can-edit as logical no-undo .  /*пользователь может изменять в броусе*/
define variable v-attr-output-display as logical no-undo .  /*виден в броусе*/
define variable v-attr-other as char no-undo .              /*еще чего - нибудь*/
define variable v-return-value  as character no-undo .


define temp-table tt0-clients-attr no-undo like ub.clients-attr.
define buffer buf_clients-attr for ub.clients-attr.
define buffer locked_clients-attr for ub.clients-attr.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  for each tt0-clients-attr:
    delete tt0-clients-attr.
  end.

  if p-mode = {&update} then do:
    do on error undo, return error :
      FOR EACH buf_clients-attr no-lock  where
              buf_clients-attr.obj-type = p-obj-type
          AND buf_clients-attr.obj-code = p-obj-code
      on error undo, return error :
        v-attr-user-can-edit = no.
        run clntattr-code in this-procedure (
                                                input  buf_clients-attr.attr-code
                                                ,output v-attr-type
                                                ,output v-attr-format
                                                ,output v-attr-label
                                                ,output v-attr-user-can-edit
                                                ,output v-attr-output-display
                                                ,output v-attr-other
                                             ) no-error .
        if v-attr-user-can-edit then do:
          find first locked_clients-attr exclusive-lock where
              locked_clients-attr.obj-type = p-obj-type
          AND locked_clients-attr.obj-code = p-obj-code
          AND locked_clients-attr.attr-code = buf_clients-attr.attr-code no-error.
          if available locked_clients-attr then do:
            CREATE tt0-clients-attr.
            BUFFER-COPY locked_clients-attr TO tt0-clients-attr.
          end.
        end.
        else do:
          CREATE tt0-clients-attr.
          BUFFER-COPY buf_clients-attr TO tt0-clients-attr.
        end.
      END.
      run ref/cli-atti.w (
                      input parparentproc
                    , input p-mode
                    , input p-obj-type
                    , input p-obj-code
                    , input p-update-on-exit /*update on exit from form*/
                    , output p-modified
                    , input-output table tt0-clients-attr
                          ) no-error.
      if error-status:error then do:
        assign
        v-return-value = substitute("&1&2&3", error-status:get-message(1), {&new-line}, return-value)
        p-is-error = yes.
      end.
      for each tt0-clients-attr:
        delete tt0-clients-attr.
      end.
    end.
  end.
  else do:
    FOR EACH buf_clients-attr no-lock where
         buf_clients-attr.obj-type = p-obj-type
     AND buf_clients-attr.obj-code = p-obj-code
    :
        CREATE tt0-clients-attr.
        BUFFER-COPY buf_clients-attr TO tt0-clients-attr.
    END.
    run ref/cli-atti.w (
                    input parparentproc
                  , input p-mode
                  , input p-obj-type
                  , input p-obj-code
                  , input p-update-on-exit /*update on exit from form*/
                  , output p-modified
                  , input-output table tt0-clients-attr
                        ) no-error.
    if error-status:error then do:
      assign
      v-return-value = substitute("&1&2&3", error-status:get-message(1), {&new-line}, return-value)
      p-is-error = yes.
    end.
    for each tt0-clients-attr:
      delete tt0-clients-attr.
    end.
  end.
  if p-is-error then do:
    return v-return-value .
  end.
end. /*doe*/