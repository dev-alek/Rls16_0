block-level on error undo, throw.
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-host-code like ub.fin-doc.host-code no-undo .
define input parameter p-fin-doc-code like ub.fin-doc.fin-doc-code no-undo .
define input parameter p-append as logical no-undo .
define input parameter p-is-last as logical no-undo .
define input parameter p-from-forms as logical no-undo .
define input-output parameter p-format as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: findocp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/findocp.p $":U .
define variable vss-description as character no-undo init "Печать одного платежа с разбором в зависимости от типа".
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
define variable v-format as integer no-undo .
define buffer buf_fin-doc for ub.fin-doc.
do
on error undo, return error
:
  assign
  v-format = p-format
  .
  find first buf_fin-doc no-lock where
            buf_fin-doc.host-code = p-host-code
        AND buf_fin-doc.fin-doc-code = p-fin-doc-code .
  CASE buf_fin-doc.fin-doc-type:
    when 'пко':U then do:
      run rep/pko-1.p (
                      input parParentProc
                      ,buffer buf_fin-doc
                      ,input p-append
                      ,input p-is-last
                      ,input p-from-forms
                      ,input-output v-format
                      ) no-error .
    end.
    when 'рко':U then do:
      run rep/rko-2.p (
                      input parParentProc
                      ,buffer buf_fin-doc
                      ,input p-append
                      ,input p-is-last
                      ,input p-from-forms
                      ,input-output v-format
                      ) no-error .
    end.
    when 'ппп':U
    or
    when 'рпп':U
    then do:
      run rep/rpp-1.p (
                      input parParentProc
                      ,buffer buf_fin-doc
                      ,input p-append
                      ,input p-is-last
                      ,input p-from-forms
                      ,input-output v-format
                      ) no-error .
    end.
    when 'апп':U then do:
      run rep/apz-1.p (
                      input parParentProc
                      ,buffer buf_fin-doc
                      ,input p-append
                      ,input p-is-last
                      ,input p-from-forms
                      ,input-output v-format
                      ) no-error .
    end.
    when 'апр':U then do:
      run rep/apz-1.p (
                      input parParentProc
                      ,buffer buf_fin-doc
                      ,input p-append
                      ,input p-is-last
                      ,input p-from-forms
                      ,input-output v-format
                      ) no-error .
    end.
  END CASE.
  assign
  p-format = v-format
  .
end.
