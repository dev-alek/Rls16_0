block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo .
define input  parameter p-recid as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcvsttr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/rcvsttr.p $":U .
define variable vss-description as character no-undo init "Изменение статуса поставки при закрытии накладной на факт".
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
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer buf_ord-doc for ub.ord-doc.
define variable   to-day  as date  no-undo .
find first buf_trn-doc no-lock where recid(buf_trn-doc) =  p-recid no-error .
    if error-status :error then do:
        message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1)
            "ОШИБКА при поиске Накладной "
            view-as alert-box error .
            return .
    end.
find first  ub.ord-chain no-lock where
            ub.ord-chain.rel-doc-code = buf_trn-doc.doc-code  and
            ub.ord-chain.doc-type = 'rcv'                  and
            ub.ord-chain.rel-doc-type = 'trn' no-error .
    if error-status :error then do:
       return .
    end.
find first buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.rcv-code = ub.ord-chain.doc-code no-error .
    if error-status :error then do:
       return .
    end.
find first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code and
                                     buf_ord-doc.doc-type = 'ОР':U no-error .
if available buf_ord-doc then do:
    if buf_trn-doc.doc-type <> 'при':U then do:
       run cus/ordorcls.p ( parparentproc, input recid(buf_ord-doc) , input false ) no-error .
    end.
    else do:
       run cus/ordorcls.p ( parparentproc , input recid(buf_ord-doc) , input false ) no-error .
    end.
    if error-status :error  and return-value <> "" then do:
    message
      error-status :get-message(1) skip
      return-value skip
      "Заказ нельзя закрыть !"
      view-as alert-box error
    .
    return error .
    end.
end.
find first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code and
                                     buf_ord-doc.doc-type = 'ПО':U no-error .
if available buf_ord-doc then do:
   run cus/ordpocls.p ( parparentproc , input recid(buf_ord-doc) , input false ) no-error .
   if error-status :error  and return-value begins 'error'  then DO:
      return error substring(return-value , 7) .
   END.
end.
find first buf_ord-doc no-lock
     where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
     and (
          buf_ord-doc.doc-type = 'ОП':U
       or buf_ord-doc.doc-type = 'ФП':U
          )
       no-error .
if available buf_ord-doc then do:
   run cus/ordopcls.p ( parparentproc , input recid(buf_ord-doc) , input false ) no-error .
   if error-status :error  and return-value begins 'error'  then DO:
      return error substring(return-value , 7) .
   END.
end.
