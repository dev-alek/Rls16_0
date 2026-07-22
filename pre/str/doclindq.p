block-level on error undo, throw.
define input  parameter parparentproc as widget-handle no-undo.
define parameter buffer t-doc for ub.trn-doc .
define parameter buffer buf_doc-line for ub.doc-line .
define input  parameter p-doc-qnty   as decimal   no-undo .
define output parameter p-edit-ok     as logical   no-undo .
define output parameter p-err-message as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doclindq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/doclindq.p $":U .
define variable vss-description as character no-undo init "Редактирование документарного количества в расходной накладной".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable is-petrolium as logical no-undo .
define variable is-pieces    as logical no-undo .
define variable line-rec     as recid   no-undo .
define variable v-hold-doc as logical   no-undo .
define buffer buf_gds-dtl for ub.gds-dtl  .
define buffer buf_goods for ub.goods  .
do
on error undo, return error return-value
:
  update_block:
  do transaction
  on error undo update_block, return error
  :
    if not available t-doc
    then do:
      undo, return error "Не задан документ" .
    end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  t-doc.doc-code
  ,output v-hold-doc
  )  .
    if not available buf_doc-line
    then do:
      undo, return error "Не задана строка документа" .
    end.
    define variable v-gds-code as integer   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output v-gds-code
  )  .
    find first buf_goods no-lock where
               buf_goods.gds-code  = v-gds-code .
      find first buf_gds-dtl no-lock where
                 buf_gds-dtl.artic     = buf_doc-line.artic          and
                 buf_gds-dtl.prod-type = buf_doc-line.prod-type  and
                 buf_gds-dtl.prod-code = buf_doc-line.prod-code  and
                 buf_gds-dtl.doc-code  = buf_doc-line.doc-code   no-error .
    if not available buf_gds-dtl then do:
      undo update_block, return error substitute("Нет строки признака &2 для документа &1" , buf_doc-line.doc-code, buf_goods.gds-name ) .
    end.
    if p-doc-qnty <> buf_doc-line.doc-qnty
    then do:
      if  p-doc-qnty = ?
      and t-doc.flag_ = true
      then do:
        assign
          p-edit-ok     = false
          p-err-message = "Не указано количество"
        .
        undo update_block, return .
      end.
     if p-doc-qnty = 0 then do:
        run str/out-add.p
          ( parparentproc,
            recid(t-doc),
            recid(buf_doc-line),
            recid(buf_gds-dtl),
            recid(buf_goods),
            "delete",
            ? )  no-error.
          if error-status :error
          then do:
            undo update_block, return error substitute("Ошибка >> &1 &2", return-value , error-status :get-message(1)  ).
          end.
     end.
     else do:
      define variable v-goods-serial as logical   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  v-gds-code
  ,input  'serial=request':u
  ,output v-goods-serial
  ) no-error .
      if error-status :error
      then do:
        undo update_block, return error "Ошибка при определении свойства товара 'serial=request':u" .
      end.
      if v-goods-serial = true
      then do:
      end.
    run str/out-add.p
      ( parparentproc,
        recid(t-doc),
        recid(buf_doc-line),
        recid(buf_gds-dtl),
        recid(buf_goods),
        "ch-doc-qnty",
        p-doc-qnty )  no-error.
      if error-status :error
      then do:
        undo update_block, return error substitute("Ошибка >> &1 &2", return-value , error-status :get-message(1)  ).
      end.
      .
    end.
  end.
  end.
  assign
    p-edit-ok     = true
    p-err-message = ''
  .
end.
