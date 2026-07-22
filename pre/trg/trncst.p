block-level on error undo, throw.
define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Простановка кода ГТД во все партии приходной накладной".
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
define variable v-is-hold       as logical   no-undo .
define variable v-orig-is-hold  as logical   no-undo .
define variable v-process-parts as logical   no-undo .
define variable v-cst-code      as character no-undo .
define variable v-in-code       as character no-undo .
define variable v-part-code     as character no-undo .
define buffer buf_trn-doc    for ub.trn-doc .
define buffer buf_parts      for ub.parts .
define buffer buf_parts-attr for ub.parts-attr .
define buffer buf_parts-supp for ub.parts-supp .
main-block:
do
on error undo main-block, return error return-value
:
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" p-doc-code skip
      view-as alert-box error .
    undo main-block, return error return-value .
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении типа документа" skip
      "Документ" buf_trn-doc.doc-code skip
      "Расширенный тип документа" buf_trn-doc.ext-doc-type skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  for each buf_parts no-lock
    where buf_parts.out-code = p-doc-code
  on error undo main-block, return error return-value
  :
    assign
      v-process-parts = false
    .
    if v-is-hold = false
    then do:
      assign
        v-process-parts = true
        v-cst-code      = buf_trn-doc.cst-code
      .
    end.
    else do:
      assign
        v-in-code   = buf_parts.in-code
        v-part-code = buf_parts.part-code
      .
      scan_cycle:
      do while true
      :
        find first buf_parts-supp share-lock
          where buf_parts-supp.in-code   = v-in-code
            and buf_parts-supp.artic     = buf_parts.artic
            and buf_parts-supp.prod-type = buf_parts.prod-type
            and buf_parts-supp.prod-code = buf_parts.prod-code
            and buf_parts-supp.part-code = v-part-code
          no-error .
        if available buf_parts-supp
        then do:
          assign
            v-in-code   = buf_parts-supp.orig-in-code
            v-part-code = buf_parts-supp.orig-part-code
          .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  v-in-code
  ,output v-orig-is-hold
  ) no-error .
          if v-orig-is-hold = true
          then do:
            next scan_cycle .
          end.
          else do:
            define variable v-gds-code as integer   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-gds-code
  )  .
            find first buf_parts-attr no-lock
              where buf_parts-attr.in-code   = v-in-code
                and buf_parts-attr.gds-code  = v-gds-code
                and buf_parts-attr.part-code = v-part-code
              no-error .
            if available buf_parts-attr
            then do:
              assign
                v-process-parts = true
                v-cst-code      = buf_parts-attr.cst-code
              .
              leave scan_cycle .
            end.
          end.
        end.
        else do:
          leave scan_cycle .
        end.
      end.
    end.
    if v-process-parts = true
    then do:
      run trg/partcst.p
        (input v-cst-code
        ,input buf_parts.in-code
        ,input buf_parts.artic
        ,input buf_parts.prod-type
        ,input buf_parts.prod-code
        ,input buf_parts.part-code
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры partcst.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end.
