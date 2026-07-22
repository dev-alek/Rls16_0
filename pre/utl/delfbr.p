block-level on error undo, throw.
do
on error undo, return error
:
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision: 5baf537283c9, 2487, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пт июн 26 16:47:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: delfbr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/delfbr.p $":U .
define variable vss-description as character no-undo init "Удаление складских документов производства, не привязанных к документам производства".
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
define variable unrv-qnty   like gds-dtl.doc-qnty no-undo.
define variable v-doc-code  like trn-doc.doc-code no-undo.
define buffer buf_trn-doc       for trn-doc.
define buffer buf_del_trn-doc   for trn-doc.
define buffer buf_fbr-doc       for fbr-doc.
define stream out-stream.
message
            "Утилита уничтожит все складские документы"
     skip   "со статусом 'прво', "
     skip   "для которых не удастся найти"
     skip   "соответствующий документ производства."
     skip (1) "Продолжать?"
view-as alert-box buttons ok-cancel
title "Утилита удаления несвязанных складских документов производства"
update v-1 as logical.
if v-1 = no then do: undo, return. end.
if session :set-wait-state( "compiler" ) then.
output stream out-stream to "delfbr.log".
each-trn-doc:
for each buf_trn-doc no-lock
   where buf_trn-doc.status_ = 'прво':U
:
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = substring( buf_trn-doc.doc-code,1,length( trim( buf_trn-doc.doc-code )  ) - 1 ) + "-"
    no-error.
    if available buf_fbr-doc
    then do:
        put stream out-stream
                skip buf_fbr-doc.doc-code " найден для " buf_trn-doc.doc-code
        .
        next each-trn-doc.
    end.
    open-doc:
    do on error undo open-doc, return error:
        find first buf_del_trn-doc exclusive-lock
             where buf_del_trn-doc.doc-code = buf_trn-doc.doc-code
        .
        assign
            v-doc-code              = buf_del_trn-doc.doc-code
            buf_del_trn-doc.status_ = 'накл':U
            buf_del_trn-doc.flag_   = no
        .
        for each gds-dtl
           where gds-dtl.doc-code = buf_del_trn-doc.doc-code
        on error undo open-doc, return error:
            unrv-qnty = - gds-dtl.doc-qnty.
            run trg/rsrv-dtl.p ( parparentproc,
                             'reserv':U, buffer gds-dtl, input-output unrv-qnty, input-output gds-dtl.price-base, input-output gds-dtl.price-rubl, -1, "").
            if unrv-qnty <> - gds-dtl.doc-qnty
            then do:
                message "Не удается снять резервы по артикулу:" gds-dtl.artic "признаку:" gds-dtl.prt-code skip
                        "Открытие документа невозможно.".
                undo open-doc, return no-apply.
            end.
        end.
        delete buf_del_trn-doc.
        put stream out-stream
            skip v-doc-code " удален"
        .
    end.
end.
output stream out-stream close.
if session :set-wait-state( "" ) then.
end.
