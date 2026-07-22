DEFINE BUFFER locked_delivery-type-subject FOR ub.delivery-type-subject.
DEFINE BUFFER locked_variant-delivery FOR ub.variant-delivery.
DEFINE TEMP-TABLE tt-delivery-type-subject NO-UNDO LIKE ub.delivery-type-subject.
DEFINE TEMP-TABLE tt-variant-delivery NO-UNDO LIKE ub.variant-delivery.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_delivery-subject FOR ub.delivery-subject.
DEFINE BUFFER X_delivery-type FOR ub.delivery-type.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter p-mode as character no-undo.
DEFINE INPUT PARAMETER p-deliv-type-code LIKE ub.variant-delivery.deliv-type-code NO-UNDO.
DEFINE INPUT PARAMETER p-deliv-subj-code LIKE ub.variant-delivery.deliv-subj-code NO-UNDO.
DEFINE INPUT PARAMETER p-deliv-obj-type  LIKE ub.variant-delivery.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-deliv-obj-code  LIKE ub.variant-delivery.obj-code NO-UNDO.
define input-output parameter p-doc-rec as recid no-undo.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Карточка редактирования ВАРИАНТА ДОСТАВКИ".
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
define variable v-tab-order as character no-undo.
define variable v-db-num LIKE ub.db.db-num no-undo.
DEFINE BUTTON b-deliv-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-deliv-type-subject
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Hist
     LABEL "Ис&тория"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-deliv-obj-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 42.5 BY 1 NO-UNDO.
DEFINE VARIABLE F-deliv-subj-name AS CHARACTER FORMAT "X(50)"
     LABEL "Название субъекта доставки"
     VIEW-AS FILL-IN
     SIZE 63 BY 1 NO-UNDO.
DEFINE VARIABLE F-deliv-type-name AS CHARACTER FORMAT "X(50)"
     LABEL "Название типа доставки"
     VIEW-AS FILL-IN
     SIZE 63 BY 1.
DEFINE QUERY Dialog-Frame FOR
      tt-variant-delivery,
      tt-delivery-type-subject SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 51
     B-Help AT ROW 1 COL 61
     tt-variant-delivery.deliv-type-code AT ROW 3 COL 27.5 COLON-ALIGNED
          LABEL "Внутр.код типа доставки"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-variant-delivery.deliv-subj-code AT ROW 3 COL 66.5 COLON-ALIGNED
          LABEL "Вн.код субъекта доставки"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     B-deliv-type-subject AT ROW 3 COL 80
     F-deliv-type-name AT ROW 4.25 COL 27.5 COLON-ALIGNED
     F-deliv-subj-name AT ROW 5.5 COL 27.5 COLON-ALIGNED
     tt-variant-delivery.obj-type AT ROW 6.75 COL 27.5 COLON-ALIGNED
          LABEL "Объект доставки"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-variant-delivery.obj-code AT ROW 6.75 COL 34 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     b-deliv-obj AT ROW 6.75 COL 46.5
     f-deliv-obj-name AT ROW 6.75 COL 48 COLON-ALIGNED NO-LABEL
     tt-variant-delivery.term-delivery AT ROW 8 COL 27.5 COLON-ALIGNED
          LABEL "Срок доставки(дни)"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-variant-delivery.des AT ROW 11.5 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.75
     "Описание" VIEW-AS TEXT
          SIZE 16 BY 1 AT ROW 10 COL 1.5
     SPACE(81.74) SKIP(4.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тип доставки от субъекта"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       F-deliv-subj-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       F-deliv-type-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-deliv-obj IN FRAME Dialog-Frame
DO:
  define variable v-user-select as logical   no-undo .
  define variable v-host-code   as integer   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      assign
      tt-variant-delivery.obj-type = "":U
      tt-variant-delivery.obj-code = 0
      f-deliv-obj-name = "":U
      .
  end.
  else do:
    find first x_clients no-lock
      where x_clients.obj-type = v-obj-type
        and x_clients.obj-code = v-obj-code
      .
    assign
      tt-variant-delivery.obj-type = v-obj-type
      tt-variant-delivery.obj-code = v-obj-code
      f-deliv-obj-name             = x_clients.obj-name
    .
  end.
  display
    tt-variant-delivery.obj-type = v-obj-type
    tt-variant-delivery.obj-code = v-obj-code
    f-deliv-obj-name             = X_clients.obj-name
    with frame Dialog-Frame .
END.
ON CHOOSE OF B-deliv-type-subject IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo.
  define variable v-sts as integer no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if available locked_delivery-type-subject then
assign
v-rid-list = string(recid(locked_delivery-type-subject))
v-sts = locked_delivery-type-subject.sts
.
run ref/dlvtysus.w (input parParentProc
              , p-curr-obj-type
              , p-curr-obj-code
              , "b-sel":U
              , 'все':U
              , 0
              , 0
              , input-output v-sts
              , input-output v-rid-list ) no-error .
if v-rid-list <> "":U then do:
    FIND FIRST LOCKED_delivery-type-subject WHERE
        recid( LOCKED_delivery-type-subject ) = integer(entry(1, v-rid-list)) NO-LOCK .
    if available LOCKED_delivery-type-subject then do:
      find first X_delivery-type no-lock where
                X_delivery-type.deliv-type-code = locked_delivery-type-subject.deliv-type-code no-error .
      find first X_delivery-subject no-lock where
                X_delivery-subject.deliv-subj-code = locked_delivery-type-subject.deliv-subj-code no-error .
      if available X_delivery-type
      and available X_delivery-subject
      then do:
        assign
        tt-variant-delivery.deliv-type-code = locked_delivery-type-subject.deliv-type-code
        tt-variant-delivery.deliv-subj-code = locked_delivery-type-subject.deliv-subj-code
        f-deliv-type-name = X_delivery-type.deliv-type-name
        f-deliv-subj-name = X_delivery-subject.deliv-subj-name
        .
     end.
     else do:
      assign
      tt-variant-delivery.deliv-type-code = ?
      tt-variant-delivery.deliv-subj-code = ?
      f-deliv-type-name = "":U
      f-deliv-subj-name = "":U
      .
     end.
   end.
   else do:
    assign
    tt-variant-delivery.deliv-type-code = ?
    tt-variant-delivery.deliv-subj-code = ?
    f-deliv-type-name = "":U
    f-deliv-subj-name = "":U
    .
   end.
  display
  tt-variant-delivery.deliv-type-code
  tt-variant-delivery.deliv-subj-code
  f-deliv-type-name
  f-deliv-subj-name
  with frame Dialog-Frame .
end.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
    run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-Hist IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo.
    run ref/varcdlvs.w
                (
                 input parParentProc
                ,INPUT p-curr-obj-type
                ,INPUT p-curr-obj-code
                ,input "":U
                ,input "one":U
                ,input locked_variant-delivery.deliv-type-code
                ,input locked_variant-delivery.deliv-subj-code
                ,input locked_variant-delivery.obj-type
                ,input locked_variant-delivery.obj-code
                ,input-output v-rid-list
                              )
 .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
IF v-db-num <> 0
AND (p-mode = 'ДОБАВЛЕНИЕ':U
     OR p-mode = 'ИЗМЕНЕНИЕ':U ) THEN DO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-mode" p-mode skip
    "Нельзя редактировать запись ВАРИАНТ ДОСТАВКИ в УБД"
    view-as alert-box ERROR.
    return error .
END.
  for each tt-delivery-type-subject:
    delete tt-delivery-type-subject.
  end.
  for each tt-variant-delivery:
    delete tt-variant-delivery.
  end.
IF p-deliv-type-code <> 0  OR p-mode <> 'ДОБАВЛЕНИЕ':U THEN DO:
    IF p-mode = 'ДОБАВЛЕНИЕ':U OR p-mode = 'ИЗМЕНЕНИЕ':U  THEN DO:
      FIND FIRST LOCKED_delivery-type-subject EXCLUSIVE-LOCK WHERE
                LOCKED_delivery-type-subject.deliv-type-code = p-deliv-type-code
            AND LOCKED_delivery-type-subject.deliv-subj-code = p-deliv-subj-code  NO-ERROR.
    END.
    IF p-mode = 'ПРОСМОТР':U THEN DO:
        FIND FIRST LOCKED_delivery-type-subject no-lock WHERE
                  LOCKED_delivery-type-subject.deliv-type-code = p-deliv-type-code
              AND LOCKED_delivery-type-subject.deliv-subj-code = p-deliv-subj-code  NO-ERROR.
   END.
   IF (p-mode = 'ДОБАВЛЕНИЕ':U
    OR p-mode = 'ИЗМЕНЕНИЕ':U )
    AND NOT AVAILABLE LOCKED_delivery-type-subject  THEN DO:
        IF LOCKED(LOCKED_delivery-type-subject) THEN DO:
            message
            vss-workfile vss-revision vss-description skip
             "Запись ТИП ДОСТАВКИ ОТ СУБЪЕКТА занята"
            view-as alert-box error .
            undo, return error.
        END.
   END.
    ELSE DO:
      IF NOT AVAILABLE LOCKED_delivery-type-subject THEN DO:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметра вызова p-deliv-type-code и/или p-deliv-subj-code" p-deliv-type-code p-deliv-subj-code skip
          view-as alert-box ERROR.
          return error .
        END.
    END.
    CREATE tt-delivery-type-subject.
    BUFFER-COPY LOCKED_delivery-type-subject TO tt-delivery-type-subject.
END.
IF p-deliv-obj-type <> "":U
or p-deliv-obj-code  <> 0
OR p-mode <> 'ДОБАВЛЕНИЕ':U THEN DO:
    FIND FIRST X_clients NO-LOCK WHERE
            X_clients.obj-type = p-deliv-obj-type
       AND  X_clients.obj-code = p-deliv-obj-code NO-ERROR.
    IF NOT AVAILABLE X_clients  THEN DO:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-deliv-obj-type и/или p-deliv-obj-code" p-deliv-obj-type p-deliv-obj-code skip
        view-as alert-box ERROR.
        return error .
    END.
END.
if p-mode = 'ИЗМЕНЕНИЕ':U
or p-mode = 'ПРОСМОТР':U
or p-deliv-type-code  <> 0 then do:
    find first X_delivery-type no-lock where
              X_delivery-type.deliv-type-code = p-deliv-type-code no-error .
    if not avail X_delivery-type then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-deliv-type-code" p-deliv-type-code skip
      view-as alert-box ERROR.
      return error .
    end.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U
or p-mode = 'ПРОСМОТР':U
or p-deliv-subj-code  <> 0 then do:
    find first X_delivery-subject no-lock where
              X_delivery-subject.deliv-subj-code = p-deliv-subj-code no-error .
    if not avail X_delivery-subject then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-deliv-subj-code" p-deliv-subj-code skip
      view-as alert-box ERROR.
      return error .
    end.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U
or p-mode = 'ПРОСМОТР':U  then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first locked_variant-delivery EXclusive-lock where
                   recid(locked_variant-delivery) = p-doc-rec no-wait no-error.
      if locked locked_variant-delivery then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ВАРИАНТ ДОСТАВКИ занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_variant-delivery no-lock where
                       recid(locked_variant-delivery) = p-doc-rec no-error .
      if not avail locked_variant-delivery then do:
        find first locked_variant-delivery no-lock where
                   locked_variant-delivery.deliv-type-code = p-deliv-type-code no-error .
      end.
    end.
    if not available locked_variant-delivery then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ВАРИАНТ ДОСТАВКИ ОТ СУБЪЕКТА"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-variant-delivery.
    buffer-copy locked_variant-delivery to tt-variant-delivery.
   end.
   else do:
     create tt-variant-delivery.
     assign
     tt-variant-delivery.deliv-type-code = (IF p-mode = 'ДОБАВЛЕНИЕ':U AND p-deliv-type-code <> 0
                                                 THEN p-deliv-type-code
                                                 ELSE tt-variant-delivery.deliv-type-code)
     tt-variant-delivery.deliv-subj-code = (IF p-mode = 'ДОБАВЛЕНИЕ':U AND p-deliv-subj-code <> 0
                                                 THEN p-deliv-subj-code
                                                 ELSE tt-variant-delivery.deliv-type-code)
     tt-variant-delivery.obj-type        = (IF p-mode = 'ДОБАВЛЕНИЕ':U AND p-deliv-obj-type <> "":U
                                                 THEN p-deliv-obj-type
                                                 ELSE tt-variant-delivery.obj-type)
     tt-variant-delivery.obj-code        = (IF p-mode = 'ДОБАВЛЕНИЕ':U AND p-deliv-obj-code <> 0
                                                 THEN p-deliv-obj-code
                                                 ELSE tt-variant-delivery.obj-code)
    .
   end.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-variant-delivery SHARE-LOCK,       EACH tt-delivery-type-subject WHERE TRUE  SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY F-deliv-type-name F-deliv-subj-name f-deliv-obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-variant-delivery THEN
    DISPLAY tt-variant-delivery.deliv-type-code
          tt-variant-delivery.deliv-subj-code tt-variant-delivery.obj-type
          tt-variant-delivery.obj-code tt-variant-delivery.term-delivery
          tt-variant-delivery.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Hist B-Help B-deliv-type-subject b-deliv-obj
         f-deliv-obj-name tt-variant-delivery.term-delivery
         tt-variant-delivery.des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyENable :
case p-mode:
  when 'ДОБАВЛЕНИЕ':U then do:
    display
    (IF tt-variant-delivery.deliv-type-code <> 0
     THEN tt-variant-delivery.deliv-type-code
     ELSE ?) @ tt-variant-delivery.deliv-type-code
    (IF tt-variant-delivery.deliv-subj-code <> 0
     THEN tt-variant-delivery.deliv-subj-code
     ELSE ?) @ tt-variant-delivery.deliv-subj-code
    (IF tt-variant-delivery.obj-type <> "":U
     THEN tt-variant-delivery.obj-type
     ELSE ?) @ tt-variant-delivery.obj-type
    (IF tt-variant-delivery.obj-code <> 0
     THEN tt-variant-delivery.obj-code
     ELSE ?) @ tt-variant-delivery.obj-code
    tt-variant-delivery.term-delivery
    (if available X_clients
    then X_clients.obj-name
    else "":U) @ f-deliv-obj-name
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    IF AVAILABLE tt-variant-delivery THEN
    DISPLAY
    tt-variant-delivery.deliv-type-code
    tt-variant-delivery.deliv-subj-code
    tt-variant-delivery.obj-type
    tt-variant-delivery.obj-code
    tt-variant-delivery.term-delivery
    X_delivery-type.deliv-type-name @ f-deliv-type-name
    X_delivery-subject.deliv-subj-name @ f-deliv-subj-name
    tt-variant-delivery.des
    WITH FRAME Dialog-Frame.
  end.
END CASE.
if p-mode = 'ПРОСМОТР':U then do:
assign
b-quit:label = "&Выход"
.
hide
b-exit in frame Dialog-Frame.
end.
ENABLE
B-exit when p-mode <> 'ПРОСМОТР':U
b-quit
B-Hist when p-mode <> 'ДОБАВЛЕНИЕ':U
B-Help
tt-variant-delivery.des when p-mode <> 'ПРОСМОТР':U
tt-variant-delivery.term-delivery when p-mode <> 'ПРОСМОТР':U
b-deliv-type-subject when (p-mode = 'ДОБАВЛЕНИЕ':U and p-deliv-type-code = 0)
b-deliv-obj when (p-mode = 'ДОБАВЛЕНИЕ':U and p-deliv-obj-code = 0)
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE Proc-save :
if p-mode = 'ПРОСМОТР':U then do:
    return error.
end.
if not available tt-variant-delivery then do:
    create tt-variant-delivery.
end.
assign
frame Dialog-Frame
tt-variant-delivery.deliv-type-code
tt-variant-delivery.deliv-subj-code
tt-variant-delivery.term-delivery
tt-variant-delivery.des = tt-variant-delivery.des:SCREEN-VALUE
.
 run ref/vardelv1.p (
input-output p-doc-rec
,input p-mode
,input tt-variant-delivery.deliv-type-code
,input tt-variant-delivery.deliv-subj-code
,input tt-variant-delivery.obj-type
,input tt-variant-delivery.obj-code
,input tt-variant-delivery.term-delivery
,input tt-variant-delivery.des
)
no-error.
if error-status:error then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
