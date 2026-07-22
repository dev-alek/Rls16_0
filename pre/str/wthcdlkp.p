block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter  p-rid as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wthcdlkp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wthcdlkp.p $":U .
define variable vss-description as character no-undo init "Просмотр одного УДАЛЕННОГО документа МЦ".
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
define variable glog as logical no-undo .
define variable next-prev as character no-undo .
define variable v-doc-rec as recid no-undo .
define buffer buf_c-wth-doc for ub.c-wth-doc.
find first buf_c-wth-doc no-lock where recid(buf_c-wth-doc) = p-rid no-error.
if NOT available buf_c-wth-doc then  do:
  message
  "Неправильный выбор удаленного документа МЦ."
  view-as alert-box WARNING .
  return no-apply.
end.
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
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_wth-doc_lookup':U
    ,input  'object':U
    ,input  buf_c-wth-doc.host-code
    ,input  buf_c-wth-doc.obj-type
    ,input  buf_c-wth-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if NOT glog then return .
assign
v-doc-rec = recid(buf_c-WTH-DOC)
.
CASE buf_c-wth-doc.doc-type :
WHEN 'при':U OR
WHEN 'рас':U OR
WHEN 'спи':U THEN DO:
    run str/wth-inc.w (  INPUT parparentproc
                    ,INPUT 'ПРОСМОТР':U
                    ,INPUT buf_c-wth-doc.host-code
                    ,INPUT buf_c-wth-doc.obj-type
                    ,INPUT buf_c-wth-doc.obj-code
                    ,INPUT buf_c-wth-doc.cli-type
                    ,INPUT buf_c-wth-doc.cli-code
                    ,INPUT buf_c-wth-doc.ext-doc-type
                    ,INPUT buf_c-wth-doc.doc-type
                    ,INPUT buf_c-wth-doc.auto-filL
                    ,INPUT-OUTPUT v-doc-rec
                    ,input ?
                    ,input-output next-prev
                    ) no-error .
END.
WHEN 'инв':U THEN DO:
    run str/wth-inv.w (  INPUT parparentproc
                    ,INPUT 'ПРОСМОТР':U
                    ,INPUT buf_c-wth-doc.host-code
                    ,INPUT buf_c-wth-doc.obj-type
                    ,INPUT buf_c-wth-doc.obj-code
                    ,INPUT buf_c-wth-doc.cli-type
                    ,INPUT buf_c-wth-doc.cli-code
                    ,input buf_c-wth-doc.ext-doc-type
                    ,INPUT buf_c-wth-doc.auto-fill
                    ,INPUT-OUTPUT v-doc-rec
                    ,input ?
                    ,input-output next-prev
                    ) no-error .
END.
END CASE.
