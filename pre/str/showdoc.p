block-level on error undo, throw.
define input  parameter parparentproc as handle    no-undo .
define input  parameter p-doc-code    as character no-undo .
define input  parameter p-artic       as character no-undo .
define input  parameter p-prod-type   as character no-undo .
define input  parameter p-prod-code   as integer   no-undo .
define input  parameter p-doc-type    as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: showdoc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/showdoc.p $":U .
define variable vss-description as character no-undo init "Показать складской документ или документ переоценки".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable v-line-rec as integer   no-undo .
do
on error undo, return error return-value
:
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  define variable old-type     as character no-undo .
  define variable old-stat     as character no-undo .
  define variable old-flag     as logical   no-undo .
  define variable old-internal as logical   no-undo .
  define variable l-document-exist as logical no-undo .
  assign
    l-document-exist = false
  .
  case p-doc-type :
    when ?
    then do:
      run show-trn-doc
        (output l-document-exist
        ).
      if l-document-exist = false
      then do:
        run show-price-doc
          (output l-document-exist
          ).
      end.
      if not l-document-exist
      then do:
        message
          "Документ" p-doc-code "не найден"
          view-as alert-box .
      end.
    end.
    when true
    then do:
      run show-trn-doc in this-procedure
        (output l-document-exist
        ).
      if not l-document-exist
      then do:
        message
          "Складской документ" p-doc-code "не найден"
          view-as alert-box .
      end.
    end.
    when false
    then do:
      run show-price-doc in this-procedure
        (output l-document-exist
        ).
      if not l-document-exist
      then do:
        message
          "Акт переоценки" p-doc-code "не найден"
          view-as alert-box .
      end.
    end.
  end.
end.
procedure show-trn-doc :
  define output parameter p-document-exist as logical no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .
  do
  on error undo, return error return-value
  :
    assign
      p-document-exist = false
    .
    find buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error.
    if available buf_trn-doc
    then do:
      assign
        p-document-exist = true
      .
      define variable v-ok as logical   no-undo .
      case buf_trn-doc.doc-type
      :
        when 'при':U
        then do:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_lookup':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
        end.
        when 'рас':U
        then do:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_lookup':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
        end.
        when 'спи':U
        then do:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_lookup':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
        end.
        when 'инв':U
        then do:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_lookup':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
        end.
        when 'возврат':U
        then do:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_lookup':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип документа" skip
            "Тип документа" trn-doc.doc-type skip
            "Код документа" trn-doc.doc-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
      if v-ok <> true
      then do:
        return .
      end.
      if buf_trn-doc.ext-doc-type = 'es':U
      or buf_trn-doc.ext-doc-type = 'rs':U
      then do:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_sale_lookup':U
    ,input  'object':U
    ,input  buf_trn-doc.host-code
    ,input  buf_trn-doc.obj-type
    ,input  buf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
        if v-ok <> true
        then do:
          return .
        end.
      end.
      assign
        v-line-rec = ?
      .
      if p-artic > ''
      then do:
        find buf_doc-line no-lock
          where buf_doc-line.doc-code  = buf_trn-doc.doc-code
            and buf_doc-line.artic     = p-artic
            and buf_doc-line.prod-type = p-prod-type
            and buf_doc-line.prod-code = p-prod-code
          no-error .
        if available buf_doc-line
        then do:
          assign
            v-line-rec = recid (buf_doc-line)
          .
        end.
        else do:
          message
            "В документе" p-doc-code skip
            "не найден товар" p-artic p-prod-type p-prod-code skip
            view-as alert-box .
        end.
      end.
      run str/trn-lkp.p
        (input parparentproc
        ,input recid(buf_trn-doc)
        ,input recid(buf_doc-line)
        ).
    end.
  end.
end procedure.
procedure show-price-doc :
  define output parameter p-document-exist as logical no-undo .
  define buffer buf_price-doc for ub.price-doc .
  define buffer buf_price-list for ub.price-list .
  do
  on error undo, return error return-value
  :
    assign
      p-document-exist = false
    .
    find buf_price-doc
      where buf_price-doc.doc-num = p-doc-code
      no-error.
    if available buf_price-doc
    then do:
      assign
        p-document-exist = true
      .
      define variable v-ok as logical   no-undo .
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_lookup':U
    ,input  'object':U
    ,input  buf_price-doc.host-code
    ,input  buf_price-doc.obj-type
    ,input  buf_price-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
      if v-ok <> true
      then do:
        return .
      end.
      assign
        v-line-rec = ?
      .
      if p-artic > ''
      then do:
        find first buf_price-list no-lock
          where buf_price-list.doc-num   = buf_price-doc.doc-num
            and buf_price-list.artic     = p-artic
            and buf_price-list.prod-type = p-prod-type
            and buf_price-list.prod-code = p-prod-code
          no-error .
        if available buf_price-list
        then do:
          assign
            v-line-rec = recid(buf_price-list)
          .
        end.
        else do:
          message
            "В акте переоценки" p-doc-code skip
            "не найден товар" p-artic p-prod-type p-prod-code skip
            view-as alert-box .
        end.
      end.
      run str/pr-lkp.p
        (input parparentproc
        ,input recid(buf_price-doc)
        ).
    end.
  end.
end procedure.
