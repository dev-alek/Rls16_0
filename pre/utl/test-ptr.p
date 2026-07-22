block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: test-ptr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/test-ptr.p $":U .
define variable vss-description as character no-undo init "test".
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
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-file-name as character no-undo .
  define variable v-sign      as decimal   no-undo .
  define variable v-after     as decimal   no-undo .
  define variable v-cli-qnty  as decimal   no-undo .
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_inv-line for ub.inv-line .
  define stream out-stream.
  find first buf_sys-ctrl no-lock.
  assign
    v-after = 0.0
    v-file-name = substitute( "doc-ln-&1.txt", buf_sys-ctrl.db-num)
  .
  output stream out-stream to value(v-file-name) append.
  put stream out-stream unformatted skip(5) "<<<<<<<<<< Дата:" space(1) string(today,"99/99/9999") space(1) "Время:" space(1) string(time, "HH:MM:SS") skip.
  output stream out-stream close.
  for each buf_doc-line no-lock
    where buf_doc-line.status_ = 'факт':U
    break by buf_doc-line.obj-type by buf_doc-line.obj-code by buf_doc-line.artic by buf_doc-line.fact-order
  on error undo, return error return-value
  :
    find first trn-doc no-lock
      where trn-doc.doc-code = buf_doc-line.doc-code
    .
    for each buf_inv-line no-lock
      where buf_inv-line.doc-code  = buf_doc-line.doc-code
        and buf_inv-line.artic     = buf_doc-line.artic
        and buf_inv-line.prod-type = buf_doc-line.prod-type
        and buf_inv-line.prod-code = buf_doc-line.prod-code
    on error undo, return error return-value
    :
      if first-of( buf_doc-line.artic ) then do:
        output stream out-stream to value(v-file-name) append.
        put stream out-stream unformatted
          skip(1)
          "Объект" space(1) buf_doc-line.obj-type space(1) buf_doc-line.obj-code skip
          "Товар" space(1) buf_doc-line.artic skip
          .
        put stream out-stream unformatted skip(1) skip.
        output stream out-stream close.
        assign
          v-after = 0.0
        .
      end.
      if lookup( buf_doc-line.ext-doc-type, 'ee,ep,es,we,ev,em,wm,eo':U ) > 0 then do:
        assign
          v-sign = -1.0
        .
      end.
      else do:
        assign
          v-sign = 1.0
        .
      end.
      if v-after <> buf_inv-line.before-cli-qnty then do:
        output stream out-stream to value(v-file-name) append.
        put stream out-stream unformatted "$$$ Между документами !!!!" skip .
        output stream out-stream close.
      end.
      if trn-doc.doc-type = 'инв':U then do:
        assign
          v-cli-qnty = buf_doc-line.cli-qnty
        .
      end.
      else do:
        assign
          v-cli-qnty = buf_inv-line.wast-cli-qnty
        .
      end.
      if buf_inv-line.before-cli-qnty + v-cli-qnty * v-sign <> buf_inv-line.after-cli-qnty then do:
        output stream out-stream to value(v-file-name) append.
        put stream out-stream unformatted "$$$ Сам документ !!!!" space(1) .
        output stream out-stream close.
      end.
      output stream out-stream to value(v-file-name) append.
      put stream out-stream unformatted
        buf_doc-line.doc-code space(1)
        "До:" space(1) buf_inv-line.before-cli-qnty space(1)
        "По документу:" space(1) v-cli-qnty * v-sign space(1)
        "После:" space(1) buf_inv-line.after-cli-qnty skip
      .
      output stream out-stream close.
      assign
        v-after = buf_inv-line.after-cli-qnty
      .
    end.
  end.
end.
