block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chk-fill.p $
$Archive: gbl/chk-fill.p $

Фильтр в списке чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/03/04
Author: Bakhtadze Natalya
Creation date: 03/03/04

*/

define input parameter p-is-wth as integer no-undo .
/* 1 чек*/
/* 2 чек МЦ */
define input parameter rs-list-method as character no-undo .
define input parameter par-run-name as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter v-start-date as date no-undo.
define input parameter v-end-date as date no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-table-name as character no-undo .
define input parameter p-filter-var as character no-undo .
define input parameter p-dop-filter as character no-undo .
define input-output parameter lns-cnt as integer no-undo .
define output parameter line-rec as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-fill.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/chk-fill.p $":U .
define variable vss-description as character no-undo init "Фильтр в списке документов".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }


{ cmp/chk-list.i chk-list def " shared " }
define variable dsp-rs as character format "x(50)" no-undo.
define variable lns-ignore as integer no-undo .
define variable kk as integer no-undo .
define variable v-doc-code like ub.chk-doc.doc-code no-undo .
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
define query chk-doc-fill for ub.chk-doc.
define query chk-gds-fill for ub.chk-doc, ub.chk-gds.
define query chk-pay-fill for ub.chk-doc, ub.chk-pay.
define query chk-doc-autotank-fill for ub.chk-doc, ub.chk-pay, ub.chk-pay-attr .


define frame abc
dsp-rs no-label
with view-as dialog-box SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
TITLE par-run-name.
view frame abc.
disp dsp-rs with frame abc.
case p-table-name:
  when {&table_chk-doc} then do:
     v-prepare-string = substitute('for each chk-doc no-lock where chk-doc.obj-type = "&1" ' +
                                   'and chk-doc.obj-code = &2 and ' +
                                    p-dop-filter + {&space-char} + p-filter-var
                                    , p-obj-type
                                    , p-obj-code
                                    ).
      glog = query chk-doc-fill:handle:query-prepare(v-prepare-string) no-error.
      if not glog
      or error-status:error then do:
        message
        substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                  , {&new-line}
                  , error-status:get-message(1)
                  , p-filter-var)
        view-as alert-box error .
        undo, return error .
      end.

      glog = query chk-doc-fill:handle:query-open() no-error.
      if not glog
      or error-status:error then do:
        message
        substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                  , {&new-line}
                  , error-status:get-message(1)
                  , p-filter-var)
        view-as alert-box error .
        undo, return error .
      end.

      REPEAT WITH FRAME abc:
        query chk-doc-fill:handle:GET-NEXT().
        IF query chk-doc-fill:handle:QUERY-OFF-END THEN LEAVE.
        process events.
        run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
     end.
     glog = query chk-doc-fill:handle:query-close() no-error.
  end.
  when {&table_chk-gds} then do:
    v-prepare-string = substitute('for each chk-doc no-lock where chk-doc.obj-type = "&1" and chk-doc.obj-code = &2 and ' +
                                  p-dop-filter + ", each chk-gds no-lock where chk-gds.doc-code = chk-doc.doc-code " + p-filter-var
                                  , p-obj-type
                                  , p-obj-code)
                                  .
    glog = query chk-gds-fill:handle:query-prepare(v-prepare-string) no-error.
    if not glog
    or error-status:error then do:
      message
      substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                , {&new-line}
                , error-status:get-message(1)
                , p-filter-var)
      view-as alert-box error .
      undo, return error .
    end.

    glog = query chk-gds-fill:handle:query-open() no-error.
    if not glog
    or error-status:error then do:
      message
      substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                , {&new-line}
                , error-status:get-message(1)
                , p-filter-var)
      view-as alert-box error .
      undo, return error .
    end.
    REPEAT WITH FRAME abc:
      query chk-gds-fill:handle:GET-NEXT().
      IF query chk-gds-fill:handle:QUERY-OFF-END THEN LEAVE.
      process events.
      run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
      assign
      v-doc-code = chk-doc.doc-code.
    end.
    glog = query chk-gds-fill:handle:query-close() no-error.
  end.
  when {&table_chk-pay} then do:
    v-prepare-string = substitute('for each chk-doc no-lock where chk-doc.obj-type = "&1" and chk-doc.obj-code = &2 and ' +
                                   p-dop-filter + ", each chk-pay no-lock where chk-pay.doc-code = chk-doc.doc-code " + p-filter-var
                                   , p-obj-type
                                   , p-obj-code)
                                   .
    glog = query chk-pay-fill:handle:query-prepare(v-prepare-string) no-error.
    if not glog
    or error-status:error then do:
      message
      substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                , {&new-line}
                , error-status:get-message(1)
                , p-filter-var)
      view-as alert-box error .
      undo, return error .
    end.

    glog = query chk-pay-fill:handle:query-open() no-error.
    if not glog
    or error-status:error then do:
      message
      substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                , {&new-line}
                , error-status:get-message(1)
                , p-filter-var)
      view-as alert-box error .
      undo, return error .
    end.
    REPEAT WITH FRAME abc:
      query chk-pay-fill:handle:GET-NEXT().
      IF query chk-pay-fill:handle:QUERY-OFF-END THEN LEAVE.
      process events.
      run ex-chk in this-procedure ( input rs-list-method, input rs-status, input line-mode).
      assign
      v-doc-code = chk-doc.doc-code.
    end.
    glog = query chk-pay-fill:handle:query-close() no-error.
  end.
  when {&table_chk-pay-attr} then do:
     v-prepare-string = substitute('for each chk-doc no-lock where chk-doc.obj-type = "&1" ' +
                                   'and chk-doc.obj-code = &2 and ' +
                                    p-dop-filter + {&space-char} + p-filter-var +
                                    ", each chk-pay no-lock where chk-pay.doc-code = chk-doc.doc-code " +
                                    ", each chk-pay-attr no-lock where chk-pay-attr.doc-code = chk-pay.doc-code " +
                                    "        and chk-pay-attr.line-num = chk-pay.line-num " +
                                    "        and chk-pay-attr.attr-code = 'autotank-sum-return'"
                                    , p-obj-type
                                    , p-obj-code
                                    ).
      glog = query chk-doc-autotank-fill:handle:query-prepare(v-prepare-string) no-error.
      if not glog
      or error-status:error then do:
        message
        substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                  , {&new-line}
                  , error-status:get-message(1)
                  , p-filter-var)
        view-as alert-box error .
        undo, return error .
      end.

      glog = query chk-doc-autotank-fill:handle:query-open() no-error.
      if not glog
      or error-status:error then do:
        message
        substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                  , {&new-line}
                  , error-status:get-message(1)
                  , p-filter-var)
        view-as alert-box error .
        undo, return error .
      end.

      REPEAT WITH FRAME abc:
        query chk-doc-autotank-fill:handle:GET-NEXT().
        IF query chk-doc-autotank-fill:handle:QUERY-OFF-END THEN LEAVE.
        process events.
        run ex-chk in this-procedure ( input 1, input rs-list-method, input rs-status, input line-mode).
     end.
     glog = query chk-doc-autotank-fill:handle:query-close() no-error.
  end.

end case.
hide frame abc.
{ cmp/ex-chk.i chk-list abc }