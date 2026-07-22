block-level on error undo, throw.
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-recid as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision: 387c9a6a2a52, 2235, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:24:00 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: findocpr2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/findocpr2.p $":U .
define variable vss-description as character no-undo init "".
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
define variable v-format as character no-undo .
define buffer buf_fin-doc for ub.fin-doc.
find first buf_fin-doc share-lock where
          recid(buf_fin-doc) = p-recid.
  find first ub.fin-doc-attr no-lock where ub.fin-doc-attr.attr-code = "pre-vedom"
    and ub.fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code and ub.fin-doc-attr.host-code = buf_fin-doc.host-code no-error .
    if not available (ub.fin-doc-attr) then do:
      message "” документа " + string(buf_fin-doc.prn-doc-code) + " нет препроводительной ведомости."
      view-as alert-box.
      return no-apply .
    end.
run rep/pre-vedom.p (
                  INPUT parParentProc
                ,input buf_fin-doc.host-code
                ,input buf_fin-doc.fin-doc-code
              ) no-error.
if error-status:error then do:
  return error.
end.
