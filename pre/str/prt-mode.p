block-level on error undo, throw.
define input  parameter p-doc-code           as character no-undo .
define input  parameter p-gds-code           as integer   no-undo .
define input  parameter p-update-doc         as logical   no-undo .
define output parameter p-sort-mode          as integer   no-undo .
define output parameter p-filter-mode        as integer   no-undo .
define output parameter p-can-create-gds-dtl as logical   no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: prt-mode.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/prt-mode.p $":U .
define variable vss-description as character no-undo initial "Значение сортировки по умолчанию для интерфейса редактирования признаков".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3':u,p-doc-code,p-gds-code,p-update-doc)
    .
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
define variable v-root-node    as integer   no-undo .
define variable v-empty-scale  as logical   no-undo .
define variable v-to-doc-prt   as logical   no-undo .
define variable v-from-doc-prt as logical   no-undo .
define buffer buf_trn-doc for ub.trn-doc .
do
on error undo, return error return-value
:
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if p-update-doc = true
  then do:
    assign
      p-can-create-gds-dtl = true
    .
  end.
  else do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsrtnod in g#library
  (input  p-gds-code
  ,output v-root-node
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении корневого признака товара" skip
        "Код товара" p-gds-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request':u
  ,output v-empty-scale
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута признака" skip
        "Код товара" p-gds-code skip
        "Признак" v-root-node skip
        "Запрашивался атрибут" "empty-scale=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-empty-scale <> true
    then do:
      if  buf_trn-doc.ext-doc-type = 'iv':U
      or  buf_trn-doc.ext-doc-type = 'rv':U
      or  ( ( buf_trn-doc.ext-doc-type = 'ie':U
              or
              buf_trn-doc.ext-doc-type = 're':U
            )
            and
            ( ( buf_trn-doc.hold-doc-code-child  <> '':u
                and
                buf_trn-doc.hold-doc-code-child  <> 'no-hold':u
              )
              or
              ( buf_trn-doc.hold-doc-code-parent <> '':u
                and
                buf_trn-doc.hold-doc-code-parent <> 'no-hold':u
              )
            )
          )
      then do:
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,input  'doc-prt=request':u
  ,output v-to-doc-prt
  ) no-error .
        if error-status:error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута объекта" skip
            "Документ" buf_trn-doc.doc-code skip
            "Объект на который производится перемещения" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
            "Атрибут" 'doc-prt=request':u skip
            error-status:get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_trn-doc.cli-type
  ,input  buf_trn-doc.cli-code
  ,input  'doc-prt=request':u
  ,output v-from-doc-prt
  ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута объекта" skip
            "Документ" buf_trn-doc.doc-code skip
            "Объект с которого производится перемещение" buf_trn-doc.cli-type buf_trn-doc.cli-code skip
            "Атрибут" 'doc-prt=request':u skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        if  v-to-doc-prt   = true
        and v-from-doc-prt <> true
        then do:
          assign
            p-can-create-gds-dtl = true
          .
        end.
        else do:
          assign
            p-can-create-gds-dtl = false
          .
        end.
      end.
      else do:
        assign
          p-can-create-gds-dtl = false
        .
      end.
    end.
    else do:
      assign
        p-can-create-gds-dtl = false
      .
    end.
  end.
  if p-can-create-gds-dtl = true
  then do:
    assign
      p-sort-mode   = 2
      p-filter-mode = 3
    .
  end.
  else do:
    assign
      p-sort-mode   = 2
      p-filter-mode = 4
    .
  end.
end.
