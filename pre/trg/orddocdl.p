block-level on error undo, throw.
define input  parameter p-doc-code like ub.ord-doc.doc-code no-undo .
define input  parameter parphchip-num      as   integer                      no-undo.
define output parameter parchip-num        as   integer                      no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Удаление документа матценностей".
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
    assign
      p-vss-parameters = substitute('&1':u,p-doc-code)
    .
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
do
on error undo, return error return-value
:
  define buffer buf_ord-doc for ub.ord-doc .
  define variable l-shift-on      as logical   no-undo .
  define variable varobj-date     as date                      no-undo.
  define variable varshift-date   like ub.shift-obj.shift-date no-undo.
  define variable varshift-num    like ub.shift-obj.shift-num  no-undo.
  find first buf_ord-doc exclusive-lock
    where buf_ord-doc.doc-code = p-doc-code
    no-error .
  if not available buf_ord-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "ЗАКАЗ" p-doc-code skip
      view-as alert-box error .
    undo, return error .
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  buf_ord-doc.cli-type
  ,input  buf_ord-doc.cli-code
  ,output varobj-date
  ) no-error .
  if error-status :error
  or varobj-date = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Нет текущей даты на объекте"  skip
      view-as alert-box error .
    undo, return error .
  end.
  if not g#news then do:
    run hstc-ord-doc in this-procedure
      (input recid(buf_ord-doc)
      ,input varobj-date
      ,input g#userid
      ,input parphchip-num
      ,output parchip-num
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при копировании в историю удаляемых заказов" skip
        view-as alert-box error .
      undo, return error.
    end.
  end.
  define variable v-obj-type   as character no-undo .
  define variable v-obj-code   as integer   no-undo .
  define variable v-fact-order as decimal   no-undo .
  assign
    v-obj-type   = buf_ord-doc.cli-type
    v-obj-code   = buf_ord-doc.cli-code
    v-fact-order = buf_ord-doc.fact-order
  .
  delete buf_ord-doc .
end.
procedure hstc-ord-doc :
  define input parameter parrec-ord-doc as   recid                 no-undo.
  define input parameter parobj-date    as   date                    no-undo.
  define input parameter paruserid      as   character               no-undo.
  define input  parameter parphchip-num      as   integer                      no-undo.
  define output parameter parchip-num        as   integer                      no-undo.
  define buffer hstc_ord-doc          for ub.ord-doc.
  define buffer hstc_ord-line         for ub.ord-line.
  define buffer hstc_ord-dtl          for ub.ord-dtl.
  define buffer hstc_c-ord-doc        for ub.c-ord-doc.
  define buffer hstc_c-ord-line       for ub.c-ord-line.
  do
  on error undo, return error return-value
  :
    find first hstc_ord-doc
      where recid (hstc_ord-doc) = parrec-ord-doc
      .
    create hstc_c-ord-doc .
    buffer-copy hstc_ord-doc to hstc_c-ord-doc .
    assign
      hstc_c-ord-doc.chip-num        = (if parphchip-num <> ?
                                       then parphchip-num
                                       else next-value(s-corr-chip, ub))
      hstc_c-ord-doc.corr-date       = parobj-date
      hstc_c-ord-doc.corr-user-name       = paruserid
    .
    for each hstc_ord-line
      where hstc_ord-line.doc-code = hstc_ord-doc.doc-code
    on error undo, return error
    :
      create hstc_c-ord-line.
      buffer-copy hstc_ord-line to hstc_c-ord-line.
      assign
        hstc_c-ord-line.chip-num = hstc_c-ord-doc.chip-num
      .
    end.
    assign
    parchip-num = hstc_c-ord-doc.chip-num
    .
  end.
end procedure.
