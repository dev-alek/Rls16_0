block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: invprice.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/invprice.p $":U .
define variable vss-description as character no-undo init "Инициализация цены в документах".
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
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-install     as logical no-undo init no .
define variable p-doc-code as character no-undo .
define variable v-r-b as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-r-b
  )  .
  run gbl/d-prompt.w
    ( 'title=Введите Номер документа\'
    + 'format=x(15)\'
    + 'type=char\'
    ,input-output p-doc-code
    ).
  if return-value = 'false':u
  then do:
    return .
  end.
find first ub.trn-doc exclusive-lock where
           ub.trn-doc.doc-code = p-doc-code no-error .
if ub.trn-doc.status_ = 'факт':U then do:
   message "Только для открытых документов!"  view-as alert-box error .
   return .
end.
for each ub.gds-dtl exclusive-lock where
         ub.gds-dtl.doc-code = ub.trn-doc.doc-code and
        ( gds-dtl.price-rubl   = 0  or
          gds-dtl.price-base   = 0  or
          gds-dtl.price-rubl   = ?  or
          gds-dtl.price-base   = ?  )
         :
    find first ub.gds-obj no-lock where
               ub.gds-obj.obj-type  = ub.trn-doc.obj-type and
               ub.gds-obj.obj-code  = ub.trn-doc.obj-code and
               ub.gds-obj.artic     = ub.gds-dtl.artic      and
               ub.gds-obj.prod-type = ub.gds-dtl.prod-type and
               ub.gds-obj.prod-code = ub.gds-dtl.prod-code no-error .
   if not available  ub.gds-obj then do:
      message "На объекте нет такого товара (признака)! "
                ub.trn-doc.obj-type  skip
                ub.trn-doc.obj-code  skip
                ub.gds-dtl.artic     skip
                ub.gds-dtl.prod-type skip
                ub.gds-dtl.prod-code
                view-as alert-box error .
      next .
   end.
   if v-r-b = 'rubl':U then do:
   assign
      gds-dtl.price-rubl   = ub.gds-obj.price-sale
      gds-dtl.price-base   = ub.gds-obj.price-sale / ub.trn-doc.base-rate * ub.trn-doc.base-scale
   .
   end.
   else do:
   assign
      gds-dtl.price-base   = ub.gds-obj.price-sale
      gds-dtl.price-rubl   = ub.gds-obj.price-sale * ub.trn-doc.base-rate / ub.trn-doc.base-scale
   .
   end.
end.
message 'все' .
