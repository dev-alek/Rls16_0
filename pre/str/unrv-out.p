block-level on error undo, throw.
define input parameter parparentproc as   handle no-undo.
define input parameter trn-code      like trn-doc.doc-code no-undo.
define variable vss-revision    as character no-undo init "$Revision: 5baf537283c9, 2487, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пт июн 26 16:47:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: unrv-out.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/unrv-out.p $":U .
define variable vss-description as character no-undo init "Cнятие резервов по РН, ВН, НС - внешним, РН - внутренней".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable  old-flag like trn-doc.flag_ no-undo.
define variable  chg-qnty like gds-dtl.doc-qnty no-undo.
define variable  varwas-ov as logical no-undo.
define variable  varlog as logical no-undo.
define variable  is-hold as logical   no-undo .
if v-cntxt-db-num <> v-cntxt-db-num-obj and ( v-cntxt-db-num-obj <> 0 ) then do:
  message "На пассивной стороне снять резервы невозможно.".
  return error.
end.
find trn-doc where trn-doc.doc-code = trn-code.
if not (can-do ('рас,спи,возврат':U, trn-doc.doc-type) and not trn-doc.internal or trn-doc.doc-type = 'рас':U) then do:
  message "Документ №" trn-doc.doc-code skip
          "По документу данного типа снять резервы невозможно.".
  return error.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  trn-doc.doc-code
  ,output is-hold
  )  .
if is-hold and not trn-doc.internal then do:
  message "Документ №" trn-doc.doc-code skip
          "По межфирменному перемещению снять резервы невозможно.".
  return error.
end.
if trn-doc.status_ <> 'накл':U then do:
  message "Документ №" trn-doc.doc-code skip
          "По документу с данным статусом снять резервы невозможно.".
  return error.
end.
unrv:
do on stop undo unrv, return error on error undo unrv, return error:
  assign
    old-flag = trn-doc.flag_
    trn-doc.flag_ = no.
    if trn-doc.ext-doc-type = 'ep':U and
     can-find(first gds-dtl where gds-dtl.doc-code = trn-doc.doc-code and
                                  gds-dtl.ov       = yes                  )
     then assign varwas-ov = yes.
     else assign varwas-ov = no.
  for each gds-dtl where gds-dtl.doc-code = trn-doc.doc-code,
       each doc-line of gds-dtl
       on stop undo unrv, return error on error undo unrv, return error:
    chg-qnty = - gds-dtl.doc-qnty.
    run trg/rsrv-dtl.p ( parparentproc,
                     'reserv':U, buffer gds-dtl, input-output chg-qnty,
                           input-output doc-line.price-base, input-output doc-line.price-rubl, -1, "").
    if chg-qnty <> - gds-dtl.doc-qnty then undo unrv, return error.
    if old-flag then gds-dtl.ov = yes.
  end.
  if trn-doc.ext-doc-type = 'ep':U and
  varwas-ov = yes then do:
    assign varlog = no.
    message "Будем разфиксировать цены?" view-as alert-box question buttons yes-no update varlog .
    if varlog then do:
       for each gds-dtl where gds-dtl.doc-code = trn-doc.doc-code
       on stop undo unrv, return error on error undo unrv, return error:
         assign gds-dtl.ov = no.
       end.
    end.
  end.
  assign
    trn-doc.status_ = 'запрос':U
    trn-doc.flag_   = yes.
end.
