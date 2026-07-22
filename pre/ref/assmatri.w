DEFINE BUFFER locked_assortment-matrix FOR ub.assortment-matrix.
DEFINE TEMP-TABLE tt-assortment-matrix NO-UNDO LIKE ub.assortment-matrix
       field obj-name as character
       field is-rel as logic
       field rel-id as character.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter p-mode as character no-undo.
DEFINE INPUT PARAMETER p-asmt-id LIKE ub.assortment-matrix.asmt-id NO-UNDO.
define input-output parameter p-doc-rec as recid no-undo.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Карточка редактирования заголовка ассортиментной матрицы ".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure assmatat-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-code in g#attr-lib
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
procedure assmatat-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-tooltip in g#attr-lib
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
procedure assmatat-value :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-value     like ub.assortment-matrix-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-value in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
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
procedure assmatat-write :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define input parameter p-value     like ub.assortment-matrix-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-write in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-exist :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-exist in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-delete :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code     like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-delete in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable v-rid-list  as character no-undo.
define variable v-tab-order as character no-undo.
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-last-code like ub.assortment-matrix.asmt-id no-undo.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 2.5 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Hist
     LABEL "Ис&тория"
     SIZE 6.5 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-assmatr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Выбор шаблона".
DEFINE BUTTON r-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE VARIABLE v-rel-id AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14 BY 1
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-shablon-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 44.5 BY 1
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE T-relation AS LOGICAL INITIAL no
     LABEL "Есть привязка к шаблону"
     VIEW-AS TOGGLE-BOX
     SIZE 26.5 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-assortment-matrix SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 89.5
     B-Help AT ROW 1 COL 96.5
     tt-assortment-matrix.asmt-id AT ROW 2 COL 34 COLON-ALIGNED
          LABEL "Внутр.код ассортиментной матрицы"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-assortment-matrix.asmt-type AT ROW 3 COL 36 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U,
"Item 2", "2":U
          SIZE 34 BY 1 TOOLTIP "Тип ассортиментной матрицы"
     tt-assortment-matrix.obj-type AT ROW 4 COL 34 COLON-ALIGNED
          LABEL "Объект"
          VIEW-AS FILL-IN
          SIZE 4.5 BY 1
     tt-assortment-matrix.obj-code AT ROW 4 COL 39 COLON-ALIGNED NO-LABEL FORMAT ">>>>>>>>>"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     r-obj AT ROW 4 COL 50.5
     T-relation AT ROW 5.54 COL 9.25 WIDGET-ID 2
     r-assmatr AT ROW 5.54 COL 35.5 WIDGET-ID 12
     tt-assortment-matrix.asmt-name AT ROW 6.92 COL 34 COLON-ALIGNED
          LABEL "Название ассортиментной матрицы"
          VIEW-AS FILL-IN
          SIZE 32 BY 1
     tt-assortment-matrix.asmt-des AT ROW 9.33 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 6.5
     tt-assortment-matrix.obj-name AT ROW 4 COL 52 COLON-ALIGNED NO-LABEL FORMAT "x(20)"
           VIEW-AS TEXT
          SIZE 43.5 BY 1
     v-rel-id AT ROW 5.54 COL 36.88 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     v-shablon-name AT ROW 5.54 COL 51.5 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     "Описание:" VIEW-AS TEXT
          SIZE 10 BY 1 AT ROW 8 COL 3.25
     "Тип:" VIEW-AS TEXT
          SIZE 4.5 BY 1 AT ROW 3 COL 31
     SPACE(63.74) SKIP(12.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заголовок ассортиментной матрицы"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF tt-assortment-matrix.asmt-type IN FRAME Dialog-Frame
DO:
  ASSIGN tt-assortment-matrix.asmt-TYPE .
  RUN proc-rs-type.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
    run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-Hist IN FRAME Dialog-Frame
DO:
  define variable pp-rid-list as character no-undo .
 run str/cassmatr.w (
  input  parparentproc ,
  input  locked_assortment-matrix.asmt-id ,
  input  locked_assortment-matrix.db-num ,
  input-output pp-rid-list    ).
END.
ON CHOOSE OF r-assmatr IN FRAME Dialog-Frame
DO:
define buffer buf_assort-matrix for ub.assortment-matrix  .
  v-rid-list  = "".
  v-rel-id        = "" .
  v-shablon-name  = "" .
  display v-rel-id v-shablon-name  with frame Dialog-Frame .
    run ref/assmatr.w (
        input parParentProc   ,
        input "b-sel"         ,
        input p-curr-obj-type ,
        input p-curr-obj-code ,
        input 'Шаблон':U  ,
        input 0               ,
        input-output v-rid-list ) .
  if num-entries(v-rid-list) <> 1 then return no-apply.
  find first buf_assort-matrix no-lock where  recid(buf_assort-matrix) = int(v-rid-list) no-error .
  if error-status :error then return no-apply.
  v-rel-id        = substitute( "&1&3&2" , buf_assort-matrix.asmt-id , buf_assort-matrix.db-num , chr(4) ) .
  v-shablon-name  = buf_assort-matrix.asmt-name .
  display v-rel-id v-shablon-name  with frame Dialog-Frame .
END.
ON VALUE-CHANGED OF T-relation IN FRAME Dialog-Frame
DO:
  assign t-relation.
  run select-list-sh .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        APPLY 'CHOOSE' TO b-exit in frame Dialog-Frame.
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return no-apply.
        end.
        else do:
          APPLY "TAB" to hh.
          return no-apply.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
END.
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
  if v-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return.
        end.
        else do:
          assign
          ii = ii + 1
          v-next-widget-name = entry(ii, v-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-tab-order)
            .
          end.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
on choose of r-obj in frame dialog-frame
do:
   run proc-r-obj in this-procedure no-error .
   if error-status :error then
      return no-apply.
end.
on mouse-select-dblclick of tt-assortment-matrix.obj-code in frame Dialog-Frame
do:
  apply "CHOOSE" to r-obj in frame Dialog-Frame.
  return no-apply .
end.
on mouse-select-dblclick of tt-assortment-matrix.obj-type in frame Dialog-Frame
do:
  apply "CHOOSE" to r-obj in frame Dialog-Frame.
  return no-apply .
end.
procedure proc-r-obj :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 define variable v-recid as recid no-undo .
 define variable old-types as character no-undo .
 define variable v-host-code like ub.sysconf.host-code no-undo .
 define buffer obj#clients for ub.clients.
 define variable v-user-select as logical   no-undo .
 define variable v-obj-type    as character no-undo .
 define variable v-obj-code    as integer   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-host-code
  ,input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-user-select
  ,output v-obj-type
  ,output v-obj-code
  )  .
  if v-user-select <> true
  then do:
    return error return-value .
  end.
    find first obj#clients no-lock
      where obj#clients.obj-type = v-obj-type
        and obj#clients.obj-code = v-obj-code
         no-error.
    if avail obj#clients then
        assign
            tt-assortment-matrix.obj-type = obj#clients.obj-type
            tt-assortment-matrix.obj-code = obj#clients.obj-code
            tt-assortment-matrix.obj-name = obj#clients.obj-name
            .
    else
       assign
          tt-assortment-matrix.obj-type = ""
          tt-assortment-matrix.obj-name = ""
          tt-assortment-matrix.obj-code = ?
          .
    display
        tt-assortment-matrix.obj-type
        tt-assortment-matrix.obj-name
        tt-assortment-matrix.obj-code
        with frame Dialog-Frame .
end.
end procedure.
procedure leave-proc-obj :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  def buffer buf_clients for ub.clients.
  assign frame Dialog-Frame
     tt-assortment-matrix.obj-type
     tt-assortment-matrix.obj-code
      .
  if tt-assortment-matrix.obj-code <> ? and tt-assortment-matrix.obj-code <> 0 and
     tt-assortment-matrix.obj-type <> ? and tt-assortment-matrix.obj-type <> ""
      then do:
      find first buf_clients no-lock where
                buf_clients.obj-type =  tt-assortment-matrix.obj-type  and
                buf_clients.obj-code  = tt-assortment-matrix.obj-code no-error.
          if error-status :error or not available buf_clients then do:
              message "Неправильно задан "  tt-assortment-matrix.obj-code:label in frame Dialog-Frame.
                assign
                tt-assortment-matrix.obj-type = ""
                tt-assortment-matrix.obj-name = ""
                tt-assortment-matrix.obj-code = ?
                .
              display
              tt-assortment-matrix.obj-type
              tt-assortment-matrix.obj-name
              tt-assortment-matrix.obj-code
              with frame Dialog-Frame.
              apply "CHOOSE" to r-obj in frame Dialog-Frame .
          end.
          if available buf_clients then do:
                tt-assortment-matrix.obj-type  = buf_clients.obj-type .
                tt-assortment-matrix.obj-name  = buf_clients.obj-name .
                tt-assortment-matrix.obj-code  = buf_clients.obj-code .
          end.
 end.
 else do:
      assign
        tt-assortment-matrix.obj-type = ""
        tt-assortment-matrix.obj-name = ""
        tt-assortment-matrix.obj-code = ?
        .
  end.
 display
  tt-assortment-matrix.obj-type
  tt-assortment-matrix.obj-name
  tt-assortment-matrix.obj-code
  with frame Dialog-Frame.
 end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 if p-mode  <> 'ДОБАВЛЕНИЕ':U
 and p-mode <> 'ИЗМЕНЕНИЕ':U
 and p-mode <> 'ПРОСМОТР':U
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
   find first X_curr_clients no-lock where
            X_curr_clients.obj-type = p-curr-obj-type
       AND X_curr_clients.obj-code = p-curr-obj-code no-error.
  if not available X_curr_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-obj-type p-curr-obj-code"
    p-curr-obj-type p-curr-obj-code
    view-as alert-box ERROR.
    return error .
  end.
  for each tt-assortment-matrix:
    delete tt-assortment-matrix.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ПРОСМОТР':U then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first locked_assortment-matrix EXclusive-lock where
                   recid(locked_assortment-matrix) = p-doc-rec no-wait no-error.
      if locked locked_assortment-matrix then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись Ассортиментная матрица занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_assortment-matrix no-lock where
                       recid(locked_assortment-matrix) = p-doc-rec no-error .
      if not avail locked_assortment-matrix then do:
        find first locked_assortment-matrix no-lock where
                   locked_assortment-matrix.asmt-id = p-asmt-id no-error .
      end.
    end.
    if not available locked_assortment-matrix then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись Ассортиментной матрицы"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-assortment-matrix.
    buffer-copy locked_assortment-matrix to tt-assortment-matrix.
   end.
   else do:
          create tt-assortment-matrix.
          assign
          tt-assortment-matrix.asmt-id = v-last-code + 1
         .
   end.
   run init-attr.
  RUN Myenable.
  wait-for go of frame Dialog-Frame focus tt-assortment-matrix.asmt-name .
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-assortment-matrix SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY T-relation v-rel-id v-shablon-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-assortment-matrix THEN
    DISPLAY tt-assortment-matrix.asmt-id tt-assortment-matrix.asmt-type
          tt-assortment-matrix.obj-type tt-assortment-matrix.obj-code
          tt-assortment-matrix.asmt-name tt-assortment-matrix.asmt-des
          tt-assortment-matrix.obj-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Hist B-Help tt-assortment-matrix.asmt-id
         tt-assortment-matrix.asmt-type tt-assortment-matrix.obj-type
         tt-assortment-matrix.obj-code r-obj T-relation r-assmatr
         tt-assortment-matrix.asmt-name tt-assortment-matrix.asmt-des
         tt-assortment-matrix.obj-name v-rel-id v-shablon-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-attr :
define variable v-exist   as logical   no-undo .
define variable v-type    as character no-undo .
define variable v-value   as character no-undo .
define buffer bufsh_assortment-matrix for ub.assortment-matrix  .
v-shablon-name = "" .
  run assmatat-exist (
      input tt-assortment-matrix.asmt-id
      ,input tt-assortment-matrix.db-num
      ,input 'RootShablon':U
      ,output v-exist
      ) .
  if v-exist then do:
  run assmatat-value (
      input tt-assortment-matrix.asmt-id
      ,input tt-assortment-matrix.db-num
      ,input 'RootShablon':U
      ,output v-value
      ,output v-type
      ) .
     find first bufsh_assortment-matrix no-lock where
                bufsh_assortment-matrix.asmt-id = int(entry(1,v-value,chr(4))) and
                bufsh_assortment-matrix.db-num  = int(entry(2,v-value,chr(4))) no-error .
    if not available bufsh_assortment-matrix then do:
        assign
            tt-assortment-matrix.is-rel = false
            tt-assortment-matrix.rel-id = ""
        .
    end.
    else do:
     assign
        tt-assortment-matrix.is-rel = true
        tt-assortment-matrix.rel-id = v-value
        v-shablon-name = bufsh_assortment-matrix.asmt-name
     .
     end.
  end.
  else do:
     assign
        tt-assortment-matrix.is-rel = false
        tt-assortment-matrix.rel-id = ""
     .
   end.
   assign
      T-relation =    tt-assortment-matrix.is-rel
      v-rel-id   =    tt-assortment-matrix.rel-id
   .
END PROCEDURE.
PROCEDURE MyENable :
tt-assortment-matrix.asmt-type:RADIO-BUTTONS IN FRAME Dialog-Frame
                = 'Объект':U + chr(44) + 'Объект':U + chr(44) +
                'Шаблон':U + chr(44) + 'Шаблон':U .
  run select-list-sh .
  case p-mode:
  when 'ДОБАВЛЕНИЕ':U then do:
    tt-assortment-matrix.asmt-type  = 'Шаблон':U .
    display
    ? @ tt-assortment-matrix.asmt-id
    ? @ tt-assortment-matrix.obj-code
    ? @ tt-assortment-matrix.obj-type
    ? @ tt-assortment-matrix.obj-name
        tt-assortment-matrix.asmt-type
    WITH FRAME Dialog-Frame.
    RUN proc-rs-type.
  end.
  otherwise do:
    IF AVAILABLE tt-assortment-matrix THEN
    DISPLAY
    tt-assortment-matrix.asmt-id
    tt-assortment-matrix.asmt-name
    tt-assortment-matrix.asmt-des
    tt-assortment-matrix.asmt-type
    tt-assortment-matrix.obj-code
    tt-assortment-matrix.obj-type
    tt-assortment-matrix.obj-name
    WITH FRAME Dialog-Frame.
  end.
END CASE.
if p-mode = 'ПРОСМОТР':U then do:
assign
b-quit:label = "&Выход"
b-quit:col = 1
.
hide
b-exit in frame Dialog-Frame.
end.
ENABLE
B-exit when p-mode <> 'ПРОСМОТР':U
b-quit
B-Hist when p-mode <> 'ДОБАВЛЕНИЕ':U
B-Help
r-obj                           when p-mode = 'ДОБАВЛЕНИЕ':U  and  tt-assortment-matrix.asmt-type  <> 'Шаблон':U
tt-assortment-matrix.obj-code   when p-mode = 'ДОБАВЛЕНИЕ':U  and  tt-assortment-matrix.asmt-type  <> 'Шаблон':U
tt-assortment-matrix.obj-type   when p-mode = 'ДОБАВЛЕНИЕ':U  and  tt-assortment-matrix.asmt-type  <> 'Шаблон':U
tt-assortment-matrix.asmt-type  when p-mode = 'ДОБАВЛЕНИЕ':U
tt-assortment-matrix.asmt-name  when p-mode <> 'ПРОСМОТР':U
tt-assortment-matrix.asmt-des   when p-mode <> 'ПРОСМОТР':U
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-rs-type :
  IF  tt-assortment-matrix.asmt-TYPE = 'Объект':U THEN DO:
      DISPLAY tt-assortment-matrix.obj-type tt-assortment-matrix.obj-code r-obj T-relation r-assmatr v-rel-id v-shablon-name tt-assortment-matrix.obj-name WITH FRAME Dialog-Frame .
      ENABLE tt-assortment-matrix.obj-type tt-assortment-matrix.obj-code r-obj T-relation r-assmatr v-rel-id v-shablon-name WITH FRAME Dialog-Frame .
  END.
  ELSE DO:
     tt-assortment-matrix.obj-code = 0 .
     tt-assortment-matrix.obj-type = "" .
     tt-assortment-matrix.obj-name = "" .
     t-relation = false .
     v-rel-id = "".
     v-shablon-name = "".
     DISPLAY tt-assortment-matrix.obj-type tt-assortment-matrix.obj-code r-obj T-relation r-assmatr v-rel-id v-shablon-name tt-assortment-matrix.obj-name WITH FRAME Dialog-Frame .
     DISABLE tt-assortment-matrix.obj-type tt-assortment-matrix.obj-code r-obj T-relation r-assmatr v-rel-id v-shablon-name tt-assortment-matrix.obj-name WITH FRAME Dialog-Frame .
  END.
END PROCEDURE.
PROCEDURE Proc-save :
if p-mode = 'ПРОСМОТР':U then do:
    return error.
end.
if not available tt-assortment-matrix then do:
    create tt-assortment-matrix.
end.
assign
  frame Dialog-Frame
  tt-assortment-matrix.asmt-id
  tt-assortment-matrix.asmt-name
  tt-assortment-matrix.asmt-type
  tt-assortment-matrix.obj-type
  tt-assortment-matrix.obj-code
  T-relation
  v-rel-id
  .
assign
  tt-assortment-matrix.asmt-des = tt-assortment-matrix.asmt-des:SCREEN-VALUE.
IF tt-assortment-matrix.asmt-TYPE = 'Объект':U  THEN DO:
    IF tt-assortment-matrix.obj-type = "" AND tt-assortment-matrix.obj-code = 0 THEN DO:
        MESSAGE "Не заполнено значение Объекта !"
                 view-as alert-box ERROR.
        return error  .
    END.
    find first X_curr_clients no-lock where
               X_curr_clients.obj-type = tt-assortment-matrix.obj-type AND
               X_curr_clients.obj-code = tt-assortment-matrix.obj-code no-error.
if not available X_curr_clients then do:
 message
 vss-workfile vss-revision vss-description skip
 "Неверное значение для поиска Объекта"
     tt-assortment-matrix.obj-type
     tt-assortment-matrix.obj-code
     view-as alert-box ERROR.
 return error .
end.
 run leave-proc-obj no-error .
   if error-status :error then return error return-value .
end.
define buffer bufsh_assortment-matrix for ub.assortment-matrix  .
if T-relation then do:
     find first bufsh_assortment-matrix no-lock where
                bufsh_assortment-matrix.asmt-id = int(entry(1,v-rel-id,chr(4))) and
                bufsh_assortment-matrix.db-num  = int(entry(2,v-rel-id,chr(4))) no-error .
    if not available bufsh_assortment-matrix then do:
     message "Не верно задан ШАБЛОН МАТРИЦ !" view-as alert-box information .
     return error return-value .
    end.
    if bufsh_assortment-matrix.asmt-type <> 'Шаблон':U then do:
      message "Можно выбрать только  ШАБЛОН МАТРИЦ !" view-as alert-box information .
      return error return-value .
    end.
    if bufsh_assortment-matrix.asmt-status <> 0 then do:
      message "Статус ШАБЛОНА МАТРИЦ  должен быть текущим!" view-as alert-box information .
      return error return-value .
    end.
end.
run ref/assmatr1.p
(input-output p-doc-rec
,input p-mode
,input tt-assortment-matrix.asmt-id
,input tt-assortment-matrix.asmt-name
,input tt-assortment-matrix.asmt-des
,input tt-assortment-matrix.asmt-type
,input tt-assortment-matrix.obj-type
,input tt-assortment-matrix.obj-code
,input T-relation
,input v-rel-id
) no-error.
if error-status:error then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
   undo, return error.
end.
END PROCEDURE.
PROCEDURE select-list-sh :
  if tt-assortment-matrix.asmt-type = 'Шаблон':U then do:
    hide
      v-rel-id in frame Dialog-Frame
      v-shablon-name
      r-assmatr
      t-relation
      in frame Dialog-Frame .
  end.
  else do:
      if p-mode <> 'ПРОСМОТР':U then do:
          enable  t-relation with frame Dialog-Frame .
      end.
      display t-relation with frame Dialog-Frame .
      if t-relation then do:
         display v-rel-id v-shablon-name r-assmatr with frame  Dialog-Frame.
         if p-mode <> 'ПРОСМОТР':U then do:
            enable  r-assmatr with frame  Dialog-Frame.
         end.
      end.
      else do:
        disable v-rel-id v-shablon-name r-assmatr with frame Dialog-Frame.
        hide    v-rel-id v-shablon-name r-assmatr in frame Dialog-Frame.
      end.
  end.
END PROCEDURE.
