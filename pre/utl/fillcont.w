define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "утилита  Привязка партий и складских документов к договору поставщика" .
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
define new global shared variable g#libtfarh as handle no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define input parameter ParParentProc as handle           no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable contr-list  as CHAR  no-undo .
define variable v-str  as CHAR  no-undo .
define variable par-type  as CHAR  no-undo .
define variable doc-list  as CHAR  no-undo .
define variable ii as integer   no-undo .
define variable v-contract-purch-code as integer   no-undo .
define variable list_num as character no-undo .
define variable db-list  as character no-undo .
define variable doc-rec  as recid no-undo .
define variable list-mode as character no-undo .
define variable to-arm  as character no-undo .
define buffer buf_contract for contract .
define buffer buf_clients for clients .
define buffer buf_trn-doc for trn-doc .
define buffer buf_parts for parts.
define buffer buf_parts-attr for parts-attr.
DEFINE temp-table temp-doc no-undo
  field id         as   character
  field fact-order like ub.trn-doc.fact-order
  INDEX pi IS PRIMARY id
  index fact-order fact-order
.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Отмена":L
     size 10 by 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод ":L
     size 10 by 1.
DEFINE BUTTON BUTTON-contr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE VARIABLE contr-code AS CHARACTER FORMAT "X(16)":U
     VIEW-AS FILL-IN
     SIZE 18.5 BY 1 NO-UNDO.
DEFINE VARIABLE snum AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 35 BY 1 NO-UNDO.
DEFINE VARIABLE trn-doc-code AS CHARACTER FORMAT "X(15)":U
     LABEL "№"
     VIEW-AS FILL-IN
     SIZE 17.63 BY 1 NO-UNDO.
DEFINE VARIABLE RADIO-contr AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Вн. №", 1,
"Номер", 2
     SIZE 10.5 BY 1.75 NO-UNDO.
DEFINE VARIABLE RADIO-doc AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Одна", 1,
"Список", 2
     SIZE 11 BY 3.92 NO-UNDO.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 38.5 BY 4.75.
DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 38.5 BY 7.5.
DEFINE VARIABLE SELECT-1 AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 19 BY 4.25 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-OK at row 1 col 1
     b-exit at row 1 col 11
     B-Help AT ROW 1 COL 30.63
     RADIO-contr AT ROW 3.5 COL 3.5 NO-LABEL
     contr-code AT ROW 3.83 COL 13.5 COLON-ALIGNED NO-LABEL
     BUTTON-contr AT ROW 3.83 COL 35
     snum AT ROW 5.75 COL 1.5 COLON-ALIGNED NO-LABEL
     RADIO-doc AT ROW 8.71 COL 3.5 NO-LABEL
     trn-doc-code AT ROW 9 COL 16.38 COLON-ALIGNED
     SELECT-1 AT ROW 10.5 COL 17.13 NO-LABEL
     "Договор:" VIEW-AS TEXT
          SIZE 10 BY 1 AT ROW 2.5 COL 3
          FGCOLOR 4
     "Приходная накладная:" VIEW-AS TEXT
          SIZE 25 BY 1 AT ROW 7.75 COL 2.5
          FGCOLOR 4
     RECT-7 AT ROW 2.25 COL 2
     RECT-8 AT ROW 7.5 COL 2
     SPACE(9.50) SKIP(0.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Привязка партий и складских документов к договору".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       snum:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-OK IN FRAME Dialog-Frame
DO:
  if list_num = "" then do:
    message  "Не выбраны документы!"  view-as alert-box.
    return no-apply .
  end.
  run proc-OK .
  message
    "Работа утилиты завершена"
    view-as alert-box.
END.
ON CHOOSE OF BUTTON-contr IN FRAME Dialog-Frame
DO:
  DISABLE RADIO-doc WITH FRAME Dialog-Frame.
  run str/cont-all.w (input ParParentProc, input v-cntxt-host-code-obj, input "b-sel", input 'фирма':U, input ?,
                  input ?, input ?, input ?, input "current":u, input 'при':U, input-output contr-list).
  if contr-list <> "" then do:
    find first buf_contract no-lock where RECID(buf_contract) = int (contr-list) no-error .
    if available buf_contract then do:
      assign snum    = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")  .
      if RADIO-contr = 1 then assign contr-code = string(buf_contract.contract-code) .
      else                    assign contr-code = buf_contract.contract-prn-code .
      ENABLE RADIO-doc WITH FRAME Dialog-Frame.
      find first buf_clients no-lock where buf_clients.obj-code = buf_contract.cli-code and buf_clients.obj-type = buf_contract.cli-type no-error .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cntpurch in g#library
  (input  buf_contract.contract-type
  ,output v-contract-purch-code
  )  .
      apply "VALUE-CHANGED" to RADIO-doc in frame Dialog-Frame.
    end.
    else assign  contr-code = ""   snum = "" .
  end.
  display contr-code snum with frame Dialog-Frame.
END.
ON LEAVE OF contr-code IN FRAME Dialog-Frame
DO:
  assign contr-code RADIO-contr .
  run  FindRec in this-procedure  .
END.
ON RETURN OF contr-code IN FRAME Dialog-Frame
DO:
  assign contr-code RADIO-contr .
  run FindRec in this-procedure .
END.
ON VALUE-CHANGED OF RADIO-contr IN FRAME Dialog-Frame
DO:
  if trn-doc-code <> "" then apply "RETURN" to trn-doc-code in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF RADIO-doc IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame radio-doc <> radio-doc then do:
    ASSIGN frame dialog-frame RADIO-doc .
    IF RADIO-doc = 1 THEN DO:
      ENABLE trn-doc-code WITH FRAME Dialog-Frame.
      DISABLE SELECT-1 WITH FRAME Dialog-Frame.
      apply "entry" to trn-doc-code in frame Dialog-Frame.
      return no-apply.
    END.
    ELSE DO:
      DISABLE trn-doc-code WITH FRAME Dialog-Frame.
      ENABLE SELECT-1 WITH FRAME Dialog-Frame.
      find first buf_clients no-lock where
            buf_clients.obj-code = buf_contract.cli-code and
            buf_clients.obj-type = buf_contract.cli-type no-error .
      assign
        doc-rec = recid(buf_clients)
        list-mode = "client-income":u
        list_num  = ""
        doc-list = ""
      .
      SELECT-1:LIST-ITEMS = list_num.
      run str/all-docs.w (
      input ParParentProc,
      input v-cntxt-host-code-obj,
      input ?,
      input ?,
      input "client-income":u,
      input ?,
      input ?,
      input ?,
      input ?,
      input "b-sel,b-mark",
      input 'ie':U,
      input no,
      input  doc-rec ,
      output doc-list).
      if doc-list <> "" then do:
        do ii = 1 to num-entries(doc-list):
          find first buf_trn-doc no-lock where RECID(buf_trn-doc) = integer(entry(ii, doc-list)) no-error.
          run CheckDoc no-error  .
          if error-status:error then return no-apply.
          if ii = 1 then assign list_num = buf_trn-doc.doc-code .
          else           assign list_num = list_num + "," + buf_trn-doc.doc-code .
        end.
        message "Проверка данных завершена, можно запустить утилиту." view-as alert-box.
      end.
      SELECT-1:LIST-ITEMS = list_num .
      return no-apply.
    END.
  end.
END.
ON LEAVE OF trn-doc-code IN FRAME Dialog-Frame
DO:
  assign trn-doc-code.
  if trn-doc-code <> "" then run  FindDoc in this-procedure .
END.
ON RETURN OF trn-doc-code IN FRAME Dialog-Frame
DO:
  assign trn-doc-code.
  if trn-doc-code <> "" then run FindDoc in this-procedure .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
  define variable num-db as integer   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output num-db
  )  .
  if num-db <> 0 then do:
    message  "Данная утилита предназначена для работы только в главной БД"  view-as alert-box.
    return no-apply .
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE CheckDoc :
define variable p-status       as integer   no-undo .
define variable p-cut-date     as date      no-undo .
define variable p-cut-fin-date as date      no-undo .
do on error undo, return error return-value :
    if buf_contract.cli-code <> buf_trn-doc.cli-code or buf_contract.cli-type <> buf_trn-doc.cli-type then do:
      message "Поставщик в накладной " buf_trn-doc.doc-code " не совпал с поставщиком в договоре!" view-as alert-box.
      return error.
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cutd-obj in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output p-status
  ,output p-cut-date
  ,output p-cut-fin-date
  )  .
    if p-cut-date <> ? then do:
      message "Документ " buf_trn-doc.doc-code " по объекту " buf_trn-doc.obj-type " " buf_trn-doc.obj-code " . На объекте было обрезание документов. Перепривязка партий и пересчет архивов невозможен." view-as alert-box.
      return error.
    end.
    if buf_contract.curr-code <> buf_trn-doc.exch-code then do:
      message "Валюта в накладной " buf_trn-doc.doc-code " не совпала с валютой договора!" view-as alert-box.
      return error.
    end.
    run CheckParts (input buf_trn-doc.doc-code) no-error .
    if error-status:error then return error.
  end.
end procedure.
PROCEDURE CheckParts :
define input  parameter num as character no-undo .
  do on error undo, return error return-value :
    for each buf_parts-attr no-lock where buf_parts-attr.in-code = num :
      if v-contract-purch-code <> buf_parts-attr.purch-code then do:
        message
          "Не совпали тип приобретения у партии (in-code=" num " gds-code=" buf_parts-attr.gds-code "
          part-code=" buf_parts-attr.part-code "тип=" string(buf_parts-attr.purch-code) ") и у договора (тип=" v-contract-purch-code ")"
        view-as alert-box.
        return error .
      end.
    end.
    for each buf_parts no-lock where buf_parts.out-code = num :
      if v-contract-purch-code <> buf_parts.purch-code then do:
        message
          "Не совпали тип приобретения у партии (
            in-code=" num
          " artic=" buf_parts.artic
          " prod-code=" buf_parts.prod-code
          " prod-type=" buf_parts.prod-type
          " part-code=" buf_parts.part-code "тип=" string(buf_parts.purch-code) ") и у договора (тип=" v-contract-purch-code ")"
        view-as alert-box.
        return error .
      end.
    end.
  end.
end procedure.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY RADIO-contr contr-code snum RADIO-doc trn-doc-code SELECT-1
      WITH FRAME Dialog-Frame.
  ENABLE b-OK b-exit B-Help RECT-7 RECT-8 RADIO-contr contr-code BUTTON-contr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE FindDoc :
do on error undo, return error return-value :
    assign list_num = "" .
    find first buf_parts-attr no-lock where buf_parts-attr.in-code = trn-doc-code no-error .
    find first buf_parts no-lock where buf_parts.out-code = trn-doc-code no-error .
    if not available buf_parts-attr and  not available buf_parts then do:
      message
       "Следов документа " trn-doc-code "не найдено!"
      view-as alert-box.
      assign RADIO-doc = 2 .
      display RADIO-doc with frame Dialog-Frame.
      apply "VALUE-CHANGED" to RADIO-doc in frame Dialog-Frame.
      return no-apply .
    end.
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = trn-doc-code no-error .
    if available buf_trn-doc then do:
      run CheckDoc no-error .
      if error-status:error then return no-apply.
    end.
    else do:
      run CheckParts (input trn-doc-code) no-error .
      if error-status:error then return no-apply.
    end.
    assign list_num = trn-doc-code .
    message
      "Проверка данных завершена, можно запустить утилиту."
      view-as alert-box.
  end.
end procedure.
PROCEDURE FindRec :
do on error undo, return error return-value :
    DISABLE RADIO-doc WITH FRAME Dialog-Frame.
    if RADIO-contr = 1 then find first buf_contract no-lock where buf_contract.contract-code = int(contr-code) and buf_contract.host-code = v-cntxt-host-code-obj no-error .
    else                    find first buf_contract no-lock where buf_contract.contract-prn-code = contr-code  and buf_contract.host-code = v-cntxt-host-code-obj no-error .
    if available buf_contract then do:
      assign  snum = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")  .
      find first buf_clients no-lock where buf_clients.obj-code = buf_contract.cli-code and buf_clients.obj-type = buf_contract.cli-type no-error .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cntpurch in g#library
  (input  buf_contract.contract-type
  ,output v-contract-purch-code
  )  .
      ENABLE RADIO-doc WITH FRAME Dialog-Frame.
      apply "VALUE-CHANGED" to RADIO-doc in frame Dialog-Frame.
    end.
    else assign  contr-code = ""    snum = "" .
    display contr-code snum with frame Dialog-Frame.
  end.
end procedure.
PROCEDURE AddDoc :
  define input  parameter p-num as character no-undo .
  do on error undo, return error return-value :
    find first temp-doc where temp-doc.id = p-num no-error .
    if not available temp-doc then do:
      create temp-doc .
      assign temp-doc.id = p-num .
      find first trn-doc no-lock where trn-doc.doc-code = p-num no-error  .
      if available trn-doc then do:
        run clntattr-value in this-procedure  (input trn-doc.obj-type,input trn-doc.obj-code,
                input  'arh-trn-doc-contract':U, output v-str, output par-type) no-error .
        if error-status:error or logical(v-str) = no then do:
          run clntattr-write in this-procedure ( input trn-doc.obj-type,input trn-doc.obj-code, input 'arh-trn-doc-contract':U, input "yes":u).
        end.
      end.
    end.
  end.
end procedure.
PROCEDURE CalcArh :
  do on error undo, return error return-value :
    for each temp-doc use-index fact-order :
      find first trn-doc no-lock where trn-doc.doc-code = temp-doc.id no-error  .
      if available trn-doc then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libtfarh) <> true) then do:   run str/libtfarh.p persistent no-error .   if error-status :error or (valid-handle(g#libtfarh) <> true) then do:     message       "Error starting libtfarh.p" skip       g#libtfarh skip       g#libtfarh :type skip       g#libtfarh :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libtfarh_st-fo in g#libtfarh
(input  temp-doc.id
) no-error.
        if error-status:error then message return-value error-status:get-message(1) view-as alert-box.
      end.
    end.
  end.
end procedure.
procedure proc-OK :
  do
  on error undo, return error return-value
  :
  define variable Counter1 as integer   no-undo .
  on write of ub.trn-doc override do:  end.
  define variable num as character no-undo .
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .
DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.
DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.
DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame InfoFrame:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.
END.
assign v-account = ( if integer( 5 ) = 0 then 100 else integer( 5 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
  do transaction :
    assign db-list = "" .
    for each db exclusive-lock where db.db-num <> 0 :
      if db-list = "" then assign db-list = string(db.db-num) .
      else                 assign db-list = db-list + chr(1) + string(db.db-num) .
    end.
    do ii = 1 to num-entries(list_num):
      num = entry(ii, list_num) .
      run AddDoc (num) .
      find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = num no-error .
      if available buf_trn-doc then do:
        assign buf_trn-doc.contract-code = buf_contract.contract-code .
      end.
      for each buf_parts-attr exclusive-lock where buf_parts-attr.in-code = num :
        assign buf_parts-attr.contract-code = buf_contract.contract-code .
        assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
      end.
      for each buf_parts exclusive-lock where buf_parts.out-code = num :
        assign buf_parts.contract-code = buf_contract.contract-code .
        for each gds-obj exclusive-lock
          where gds-obj.artic     =  buf_parts.artic
            and gds-obj.prod-type =  buf_parts.prod-type
            and gds-obj.prod-code =  buf_parts.prod-code
         , each parts exclusive-lock
          where parts.obj-type  =  gds-obj.obj-type
            and parts.obj-code  =  gds-obj.obj-code
            and parts.artic     =  buf_parts.artic
            and parts.prod-type =  buf_parts.prod-type
            and parts.prod-code =  buf_parts.prod-code
            and parts.in-code   =  buf_parts.in-code
            and parts.part-code =  buf_parts.part-code
          :
          run AddDoc (parts.out-code) .
          assign parts.contract-code = buf_contract.contract-code .
          assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
        end.
      end.
    end.
    run CalcArh in this-procedure .
  end.
  run nws/cr-route.p ( input 'send-cmd':U
                  ,input "command":U + chr(1) + "fill-contract":U + chr(1) + string(buf_contract.contract-code) + chr(1) + list_num
                  ,input ?
                  ,input db-list
                 ).
  end.
end procedure.
