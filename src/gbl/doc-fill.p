block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: doc-fill.p $
$Archive: gbl/doc-fill.p $

Фильтр в списке документов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/06/06
Author: Bakhtadze Natalya
Creation date: 01/06/06

*/

define input parameter pis-trn-doc as integer no-undo .
/* 0 переоценка*/
/* 1 накладная */
/* 2 продажа */
define input parameter rs-list-method as character no-undo .
define input parameter par-run-name as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-table-name as character no-undo .
define input parameter p-filter-var as character no-undo .
define output parameter lns-cnt as integer no-undo .
define output parameter line-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doc-fill.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/doc-fill.p $":U .
define variable vss-description as character no-undo init "Фильтр в списке документов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/doc-list.i doc-list def " shared " }

define variable dsp-rs as character format "x(50)" no-undo.
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
define query trn-doc-fill for ub.trn-doc.
define query price-doc-fill for ub.price-doc.
define query inkas-fill for ub.inkas.
define query fbr-doc-fill for ub.fbr-doc.

define frame abc
dsp-rs no-label
with view-as dialog-box SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
TITLE par-run-name.
view frame abc.
display dsp-rs
with frame abc.

case p-table-name:
  when {&table_trn-doc} then do:
    v-prepare-string = substitute('for each trn-doc no-lock where trn-doc.host-code = &1 ' +
                                   p-filter-var
                                  , p-curr-host-code
                                  ).
    glog = query trn-doc-fill:handle:query-prepare(v-prepare-string) no-error.
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

    glog = query trn-doc-fill:handle:query-open() no-error.
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
       query trn-doc-fill:handle:GET-NEXT().
       IF query trn-doc-fill:handle:QUERY-OFF-END THEN LEAVE.
       process events.
       run ex-doc in this-procedure ( input 1, input rs-list-method, input rs-status, input line-mode) .
    end.
    glog = query trn-doc-fill:handle:query-close() no-error.
  end.
  when {&table_price-doc} then do:
    v-prepare-string = substitute('for each price-doc no-lock where price-doc.host-code = &1 ' +
                                   p-filter-var
                                  , p-curr-host-code
                                  ).
    glog = query price-doc-fill:handle:query-prepare(v-prepare-string) no-error.
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

    glog = query price-doc-fill:handle:query-open() no-error.
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
      query price-doc-fill:handle:GET-NEXT().
      IF query price-doc-fill:handle:QUERY-OFF-END THEN LEAVE.
      process events.
      run ex-doc in this-procedure ( input 0, input rs-list-method, input rs-status, input line-mode) .
    end.
    glog = query price-doc-fill:handle:query-close() no-error.
  end.
  when {&table_inkas} then do:
    v-prepare-string = substitute('for each inkas no-lock where inkas.host-code = &1 ' +
                                   p-filter-var
                                  , p-curr-host-code
                                  ).
    glog = query inkas-fill:handle:query-prepare(v-prepare-string) no-error.
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

    glog = query inkas-fill:handle:query-open() no-error.
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
      query inkas-fill:handle:GET-NEXT().
      IF query inkas-fill:handle:QUERY-OFF-END THEN LEAVE.
      process events.
      run ex-doc in this-procedure ( input 2, input rs-list-method, input rs-status, input line-mode) .
    end.
    glog = query inkas-fill:handle:query-close() no-error.
  end.
  when {&table_fbr-doc} then do:
    v-prepare-string = substitute('for each fbr-doc no-lock where fbr-doc.host-code = &1 ' +
                                   p-filter-var
                                  , p-curr-host-code
                                  ).
    glog = query fbr-doc-fill:handle:query-prepare(v-prepare-string) no-error.
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
    glog = query fbr-doc-fill:handle:query-open() no-error.
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
      query fbr-doc-fill:handle:GET-NEXT().
      IF query fbr-doc-fill:handle:QUERY-OFF-END THEN LEAVE.
      process events.
      run ex-doc in this-procedure ( input 3, input rs-list-method, input rs-status, input line-mode) .
    end.
    glog = query fbr-doc-fill:handle:query-close() no-error.
  end.

end case.

hide frame abc.
{ cmp/ex-trn.i doc-list abc }