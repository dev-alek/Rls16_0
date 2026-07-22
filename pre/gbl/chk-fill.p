block-level on error undo, throw.
define input parameter p-is-wth as integer no-undo .
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
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table chk-list no-undo
field doc-code   like ub.chk-doc.doc-code
field obj-type   like ub.chk-doc.obj-type
field obj-code   like ub.chk-doc.obj-code
field out-code   like ub.chk-doc.out-code
field chk-date   like ub.chk-doc.chk-date
field chk-time   like ub.chk-doc.chk-time
field shift-date like ub.chk-doc.shift-date
field shift-num  like ub.chk-doc.shift-num
field shift-name  like ub.chk-doc.shift-name
field src-shift-date like ub.chk-doc.src-shift-date
field chk-num    like ub.chk-doc.chk-num
field pay-desk   like ub.chk-doc.pay-desk
field cashier    like ub.chk-doc.cashier
field cashier-psn-code    like ub.chk-doc.cashier-psn-code
field chk-type   like ub.chk-doc.chk-type
field d-card     like ub.chk-doc.d-card
field netto      like ub.chk-doc.netto
field discnt     like ub.chk-doc.discnt
field tot-doc    like ub.chk-doc.tot-doc
field is-wth     as logical
field sel-order  as integer
field znak       as integer
field to-del     as logical
field doc-num    as character label "№ док-та" format "X(22)"
field doc-num2   as character label "№ заказа" format "X(22)"
index xpk is primary unique doc-code is-wth
index znak-order znak sel-order .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   shared   temp-table chk-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
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
  when 'chk-doc':U then do:
     v-prepare-string = substitute('for each chk-doc no-lock where chk-doc.obj-type = "&1" ' +
                                   'and chk-doc.obj-code = &2 and ' +
                                    p-dop-filter + chr(32) + p-filter-var
                                    , p-obj-type
                                    , p-obj-code
                                    ).
      glog = query chk-doc-fill:handle:query-prepare(v-prepare-string) no-error.
      if not glog
      or error-status:error then do:
        message
        substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                  , chr(10)
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
                  , chr(10)
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
  when 'chk-gds':U then do:
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
                , chr(10)
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
                , chr(10)
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
  when 'chk-pay':U then do:
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
                , chr(10)
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
                , chr(10)
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
  when 'chk-pay-attr':U then do:
     v-prepare-string = substitute('for each chk-doc no-lock where chk-doc.obj-type = "&1" ' +
                                   'and chk-doc.obj-code = &2 and ' +
                                    p-dop-filter + chr(32) + p-filter-var +
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
                  , chr(10)
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
                  , chr(10)
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE ex-chk :
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define variable v-process as logical no-undo .
define variable v-start-date as date no-undo .
define variable v-end-date as date no-undo .
  CASE entry(1, rs-status, chr(4)):
    when "chk-date":U then do:
      ASSIGN
      V-START-DATE = DATE(ENTRY(2, rs-status, chr(4)))
      V-END-DATE = DATE(ENTRY(3, rs-status, chr(4)))
      rs-status = entry(1, rs-status, chr(4))
      .
    end.
  END CASE.
  if line-mode = 'удаление':U or line-mode = 'ОСТАВИТЬ':U then do:
    find first chk-list where
              chk-list.doc-code = ub.chk-doc.doc-code
              no-error.
    if available chk-list then do:
      if rs-list-method = "single":U or           (rs-status = 'все':U            or            (chk-doc.out-code = ? and rs-status = "free":U)            or            (chk-doc.chk-date >= v-start-date and chk-doc.chk-date <= v-end-date and rs-status = "chk-date":U)           )
      then do:
        assign
        v-process = yes
        .
      end.
      if line-mode = 'удаление':U and v-process then do:
        if chk-list.doc-code <> v-doc-code then
        lns-cnt = lns-cnt + 1.
        delete chk-list.
      end.
      if line-mode = 'ОСТАВИТЬ':U and  v-process then do:
        if chk-list.to-del = ? then .
        else do:
          if chk-list.doc-code <> v-doc-code then
          lns-cnt = lns-cnt + 1.
          assign chk-list.to-del = ?.
        end.
      end.
      if not v-process
      and chk-list.doc-code <> v-doc-code
      then
      assign
      lns-ignore = lns-ignore + 1
      .
    end.
  end.
  else
    if line-mode = 'ДОБАВЛЕНИЕ':U then do:
      if rs-list-method = "single":U or           (rs-status = 'все':U            or            (chk-doc.out-code = ? and rs-status = "free":U)            or            (chk-doc.chk-date >= v-start-date and chk-doc.chk-date <= v-end-date and rs-status = "chk-date":U)           ) then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find chk-list
  where chk-list.doc-code = chk-doc.doc-code
  no-error .
if available chk-list then do:
  assign
    chk-list.to-del = no
  .
end.
else do:
  create chk-list .
  assign
  chk-list.doc-code   = chk-doc.doc-code
  chk-list.obj-type   = chk-doc.obj-type
  chk-list.obj-code   = chk-doc.obj-code
  chk-list.out-code   = chk-doc.out-code
  chk-list.chk-date  = chk-doc.chk-date
  chk-list.chk-time  = chk-doc.chk-time
  chk-list.shift-date = chk-doc.shift-date
  chk-list.shift-num  = chk-doc.shift-num
  chk-list.src-shift-date = chk-doc.src-shift-date
  chk-list.chk-num    = chk-doc.chk-num
  chk-list.pay-desk   = chk-doc.pay-desk
  chk-list.cashier    = chk-doc.cashier
  chk-list.cashier-psn-code   = chk-doc.cashier-psn-code
  chk-list.chk-type   = chk-doc.chk-type
  chk-list.d-card     = chk-doc.d-card
  chk-list.is-wth     = LOOKUP(string(chk-doc.chk-type), '2,3,4,5,7':U) > 0
  chk-list.doc-num    = chk-doc.doc-num
  chk-list.doc-num2   = chk-doc.doc-num2
  chk-list.to-del = no
  .
  if chk-list.is-wth = no then do:
    assign
    chk-list.netto      = buffer chk-doc:handle:buffer-field("netto"):buffer-value
    chk-list.tot-doc    = buffer chk-doc:handle:buffer-field("tot-doc"):buffer-value
    chk-list.discnt     = buffer chk-doc:handle:buffer-field("discnt"):buffer-value
    no-error
    .
  end.
  else do:
    assign
    chk-list.netto      = 0
    chk-list.tot-doc    = 0
    chk-list.discnt     = 0
    no-error
    .
  end.
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (chk-list)
  .
end.
      end.
      else assign
      lns-ignore = lns-ignore + 1
      .
    end.
  disp "Ждите..." + string (lns-cnt) @ dsp-rs with frame abc.
end PROCEDURE.
