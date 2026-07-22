block-level on error undo, throw.
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: delobjck.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/delobjck.p $":U .
define variable vss-description as character no-undo init "Процедура проверки того, что объект можно удалять".
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
define buffer buf_scales-gds for ub.scales-gds.
define buffer buf_gds-obj    for ub.gds-obj .
define buffer buf_trn-doc    for ub.trn-doc .
define buffer buf_price-doc  for ub.price-doc .
define buffer buf_clients    for ub.clients .
define buffer buf_dis-card   for ub.dis-card .
define buffer buf_parts      for ub.parts .
define variable v-host-code as integer   no-undo .
do
on error undo, return error return-value
:
  find first buf_scales-gds no-lock
    where buf_scales-gds.obj-type = p-obj-type
      AND buf_scales-gds.obj-code = p-obj-code no-error .
  if available buf_scales-gds
  then do:
    return error "Существуют товары объекта на весах".
  end.
  find first buf_gds-obj no-lock
    where buf_gds-obj.obj-type = p-obj-type
      and buf_gds-obj.obj-code = p-obj-code
      and (buf_gds-obj.fact-qnty <> 0
          or buf_gds-obj.avrg-qnty <> 0
          )
    no-error .
  if available buf_gds-obj
  then do:
    return error substitute("Существует ненулевые остатки. Товар &1 &2 &3"
      ,buf_gds-obj.artic
      ,buf_gds-obj.prod-type
      ,buf_gds-obj.prod-code
      ) .
  end.
  find first buf_trn-doc no-lock
    where buf_trn-doc.obj-type = p-obj-type
      and buf_trn-doc.obj-code = p-obj-code
      and buf_trn-doc.status_  <> 'факт':U
      and buf_trn-doc.status_  <> 'запрос':U
    no-error .
  if available buf_trn-doc
  then do:
    return error substitute("Существует незакрытый документ. Документ &1"
      ,buf_trn-doc.doc-code
      ) .
  end.
  find first buf_trn-doc no-lock
    where buf_trn-doc.cli-type = p-obj-type
      and buf_trn-doc.cli-code = p-obj-code
      and buf_trn-doc.status_ <> 'факт':U
      and buf_trn-doc.status_ <> 'запрос':U
    no-error .
  if available buf_trn-doc
  then do:
    return error substitute("Существует незакрытый документ. Документ &1"
      ,buf_trn-doc.doc-code
      ) .
  end.
  find first buf_price-doc no-lock
    where buf_price-doc.obj-type = p-obj-type
      and buf_price-doc.obj-code = p-obj-code
      and buf_price-doc.status_  <> 'акт':U
    no-error.
  if available price-doc
  then do:
    return error substitute("Существует незакрытая переоценка. Документ &1"
      ,buf_price-doc.doc-num
      ) .
  end.
  if p-obj-type = 'маг':U
  then do:
    find first buf_clients no-lock where
            buf_clients.obj-type = p-obj-type
        AND buf_clients.obj-code = p-obj-code .
    for each buf_dis-card no-lock where
            buf_dis-card.emitent-host-code = 0
        or buf_dis-card.emitent-host-code = buf_clients.host-code:
      if buf_dis-card.issue-code = p-obj-code
      then do:
        return error substitute("Существует ДК выданная на объекте. ДК &1"
          ,buf_dis-card.d-card
          ) .
      end.
    end.
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
  for each buf_clients no-lock
    where buf_clients.host-code = v-host-code
  on error undo, return error return-value
  :
    if  buf_clients.obj-type = p-obj-type
    and buf_clients.obj-code = p-obj-code
    then do:
    end.
    else do:
      find first buf_parts no-lock
        where buf_parts.host-code = v-host-code
          and buf_parts.supp-type = p-obj-type
          and buf_parts.supp-code = p-obj-code
          and buf_parts.status_   = yes
          and buf_parts.obj-type  = buf_clients.obj-type
          and buf_parts.obj-code  = buf_clients.obj-code
        no-error .
      if available buf_parts
      then do:
        return error substitute("Существует партия порожденная текущим объектом на объекте &2 &3. Код партии &1"
          ,recid(buf_parts)
          ,buf_clients.obj-type
          ,buf_clients.obj-code
          ) .
      end.
    end.
  end.
end.
