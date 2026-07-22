DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_fbr-prn FOR ub.fbr-prn.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER fbr_clients FOR ub.clients.
DEFINE BUFFER loc_fbr-prn-gds FOR ub.fbr-prn-gds.
DEFINE TEMP-TABLE tt-fbr-prn-gds NO-UNDO LIKE ub.fbr-prn-gds.
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode as character no-undo.
define input parameter par-call-mode as character no-undo.
define input parameter p-db-num like ub.fbr-prn-gds.db-num no-undo.
define input parameter p-prn-num like ub.fbr-prn-gds.prn-num no-undo.
define input parameter p-obj-type like ub.fbr-prn-gds.obj-type no-undo.
define input parameter p-obj-code like ub.fbr-prn-gds.obj-code no-undo.
define input parameter p-gds-code like ub.fbr-prn-gds.gds-code no-undo.
define input-output parameter p-rec as recid no-undo.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Группа товаров на  принтере кухни-создание, редактирование".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
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
define variable v-db-num like ub.db.db-num no-undo.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-gds
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 2"
     SIZE 3 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-printer
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 2"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-shop
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 2"
     SIZE 3 BY 1.
DEFINE VARIABLE f-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 45.75 BY .67 NO-UNDO.
DEFINE VARIABLE f-prn-name AS CHARACTER FORMAT "X(40)":U
      VIEW-AS TEXT
     SIZE 35.88 BY .67 NO-UNDO.
DEFINE VARIABLE fbr-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 42.38 BY .67 NO-UNDO.
DEFINE VARIABLE gds-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 59.5 BY .67 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-fbr-prn-gds SCROLLING.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     b-gds AT ROW 4.17 COL 62.38
     B-shop AT ROW 6.67 COL 19.25
     B-printer AT ROW 10.08 COL 47.13
     gds-name AT ROW 4.25 COL 1.88 NO-LABEL
     tt-fbr-prn-gds.obj-type AT ROW 6.71 COL 2 NO-LABEL
           VIEW-AS TEXT
          SIZE 7 BY .67
     tt-fbr-prn-gds.obj-code AT ROW 6.75 COL 8.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 7.13 BY .67
     f-obj-name AT ROW 7.83 COL 2.25 NO-LABEL
     tt-fbr-prn-gds.prn-num AT ROW 10.25 COL 2.25 NO-LABEL
           VIEW-AS TEXT
          SIZE 5.5 BY .67
     f-prn-name AT ROW 10.29 COL 7.88 COLON-ALIGNED NO-LABEL
     fbr-obj-name AT ROW 11.67 COL 22.75 NO-LABEL
     "Установлен:" VIEW-AS TEXT
          SIZE 18.63 BY .67 AT ROW 11.58 COL 2.25
          FGCOLOR 4
     "Принтер" VIEW-AS TEXT
          SIZE 18.63 BY .67 AT ROW 9.17 COL 2.25
          FGCOLOR 4
     "Объект" VIEW-AS TEXT
          SIZE 17.88 BY .67 AT ROW 5.42 COL 2.13
          FGCOLOR 4
     "Товар" VIEW-AS TEXT
          SIZE 17.88 BY .67 AT ROW 2.83 COL 2.38
          FGCOLOR 4
     SPACE(45.61) SKIP(9.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Принтер для товара"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-gds IN FRAME Dialog-Frame
DO:
define variable rec-list as character no-undo.
  run ref/gds-ref.p (parparentproc
                 ,"b-sel":U
                 ,?
                 ,?
                 ,?
                 ,?
                 ,?
                 ,?
                 ,?
                 ,p-obj-type
                 ,p-obj-code
                 ,?
                 , output rec-list).
 if rec-list = "" then do:
     return no-apply.
  end.
   find buf_goods where recid (buf_goods) = integer (rec-list) no-lock no-error.
  if not avail buf_goods then do:
    return no-apply.
  end.
  assign
  tt-fbr-prn-gds.gds-code = buf_goods.gds-code
  .
display buf_goods.gds-name @ gds-name
with frame Dialog-Frame.
END.
ON CHOOSE OF B-printer IN FRAME Dialog-Frame
DO:
define variable v-recid as recid no-undo.
run ref/fbr-prns.w (
                        input parparentproc
                       ,input "db":U
                       ,input v-db-num
                       ,input "b-sel":U
                       ,input-output v-recid
) no-error.
if error-status:error then return no-apply.
find first buf_fbr-prn where
            recid(buf_fbr-prn) = v-recid no-error.
if error-status:error or buf_fbr-prn.db-num <> v-db-num then return no-apply.
find first fbr_clients no-lock where
            fbr_clients.obj-type = buf_fbr-prn.fbr-obj-type
       AND fbr_clients.obj-code = buf_fbr-prn.fbr-obj-code no-error.
assign
tt-fbr-prn-gds.prn-num = buf_fbr-prn.prn-num
f-prn-name = buf_fbr-prn.prn-name
fbr-obj-name = (if available fbr_clients
                         then fbr_clients.obj-name
                         else (buf_fbr-prn.fbr-obj-type + string(buf_fbr-prn.fbr-obj-code)))
.
display
f-obj-name
f-prn-name
tt-fbr-prn-gds.prn-num
with frame Dialog-Frame.
END.
ON CHOOSE OF B-shop IN FRAME Dialog-Frame
DO:
  define variable v-host-code   as integer   no-undo .
  define variable v-user-select as logical   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output v-user-select
  ,output v-obj-type
  ,output v-obj-code
  )  .
  if v-user-select = true
  then do:
    find first buf_clients no-lock
      where buf_clients.obj-type = v-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients then return no-apply.
    if buf_clients.db-num <> v-db-num
    then do:
      message
        "Можно выбать только объект текущей БД" skip
        view-as alert-box error.
      return no-apply.
    end.
    assign
    f-obj-name:screen-value = buf_clients.obj-name
    tt-fbr-prn-gds.obj-code = buf_clients.obj-code
    tt-fbr-prn-gds.obj-type = buf_clients.obj-type
    .
    display
    tt-fbr-prn-gds.obj-code
    tt-fbr-prn-gds.obj-type
    f-obj-name
    with frame Dialog-Frame.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   if par-mode <> 'ИЗМЕНЕНИЕ':U and par-mode <> 'ДОБАВЛЕНИЕ':U then do:
    message
    vss-workfile vss-revision vss-description skip
     "Неверный параметр вызова par-mode" par-mode
    view-as alert-box ERROR.
    return error.
  end.
  if par-mode = 'ДОБАВЛЕНИЕ':U
  AND  (par-call-mode <> "goods":U
        and par-call-mode <> "printer":U )
  then do:
      message
        vss-workfile vss-revision vss-description skip
         "Неверный параметр вызова par-call-mode" par-call-mode
        view-as alert-box ERROR.
        return error.
  end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
  run fill-tables in this-procedure.
  RUN Myenable in this-procedure.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-fbr-prn-gds SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY gds-name f-obj-name f-prn-name fbr-obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fbr-prn-gds THEN
    DISPLAY tt-fbr-prn-gds.obj-type tt-fbr-prn-gds.obj-code tt-fbr-prn-gds.prn-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-Help b-gds B-shop B-printer gds-name
         tt-fbr-prn-gds.obj-type tt-fbr-prn-gds.obj-code f-obj-name
         tt-fbr-prn-gds.prn-num f-prn-name fbr-obj-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE Fill-tables :
CASE par-mode:
  when 'ДОБАВЛЕНИЕ':U then do:
    CASE par-call-mode:
      when "goods":U then do:
        create tt-fbr-prn-gds .
        assign
        tt-fbr-prn-gds.gds-code = p-gds-code
        .
      end.
      when "printer":U then do:
        create tt-fbr-prn-gds.
        assign
        tt-fbr-prn-gds.prn-num = p-prn-num.
      end.
    END CASE.
  end.
  when 'ИЗМЕНЕНИЕ':U then do:
    find first loc_fbr-prn-gds exclusive-lock where
                recid(loc_fbr-prn-gds ) = p-rec no-error.
    if not available loc_fbr-prn-gds then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-rec" p-rec
      view-as alert-box error.
      return error.
    end.
    find first buf_goods no-lock where
               buf_goods.gds-code = p-gds-code no-error .
    if not available buf_goods then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-gds-code" p-rec
      view-as alert-box error.
      return error.
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = loc_fbr-prn-gds.obj-type
          AND buf_clients.obj-code = loc_fbr-prn-gds.obj-code no-error.
    if buf_clients.db-num <> v-db-num then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя редактировать запись, принадлежащую другой БД"
      "номер узла групп товаров" loc_fbr-prn-gds.gds-code skip
      "объект" loc_fbr-prn-gds.obj-type loc_fbr-prn-gds.obj-code skip
      "принтер" loc_fbr-prn-gds.prn-num
      view-as alert-box error.
      return error.
    end.
    create tt-fbr-prn-gds.
    buffer-copy loc_fbr-prn-gds to tt-fbr-prn-gds.
  end.
END CASE.
END PROCEDURE.
PROCEDURE MyEnable :
assign
frame Dialog-Frame:title = frame Dialog-Frame:title + chr(32) + par-mode
.
CASE par-mode:
  when 'ДОБАВЛЕНИЕ':U then do:
    CASE par-call-mode:
      when "goods":U then do:
      end.
      when "printer":U then do:
        find first buf_fbr-prn where
                    buf_fbr-prn.prn-num = tt-fbr-prn-gds.prn-num
                AND buf_fbr-prn.db-num = v-db-num .
        assign
        f-prn-name = buf_fbr-prn.prn-name
        .
        find first fbr_clients no-lock where
                  fbr_clients.obj-type = buf_fbr-prn.fbr-obj-type
              AND fbr_clients.obj-code = buf_fbr-prn.fbr-obj-code.
        assign
        fbr-obj-name = fbr_clients.obj-name
        .
      end.
    END CASE.
  end.
  when 'ИЗМЕНЕНИЕ':U then do:
    find first buf_fbr-prn where
              buf_fbr-prn.prn-num = tt-fbr-prn-gds.prn-num
          AND buf_fbr-prn.db-num = v-db-num.
    assign
    f-prn-name = buf_fbr-prn.prn-name
    .
    find first fbr_clients no-lock where
              fbr_clients.obj-type = buf_fbr-prn.fbr-obj-type
          AND fbr_clients.obj-code = buf_fbr-prn.fbr-obj-code.
    assign
    fbr-obj-name = fbr_clients.obj-name
    .
    assign
    frame Dialog-Frame:title = frame Dialog-Frame:title + chr(32) + buf_goods.gds-name
    .
  end.
END CASE.
  DISPLAY
  buf_goods.gds-name @ gds-name
  f-obj-name
  f-prn-name
  fbr-obj-name
  WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fbr-prn-gds THEN
  DISPLAY
  tt-fbr-prn-gds.obj-type
  tt-fbr-prn-gds.obj-code
  tt-fbr-prn-gds.prn-num
  WITH FRAME Dialog-Frame.
  ENABLE
  b-quit
  B-exit
  B-Help
  b-gds when par-mode = 'ДОБАВЛЕНИЕ':U and par-call-mode = "printer":U
  B-shop when par-mode = 'ДОБАВЛЕНИЕ':U
  B-printer when par-call-mode = "goods"
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
run ref/fprngrp1.p (
                    input-output p-rec
                    ,input par-mode
                    ,input tt-fbr-prn-gds.db-num
                    ,input tt-fbr-prn-gds.prn-num
                    ,input tt-fbr-prn-gds.obj-type
                    ,input tt-fbr-prn-gds.obj-code
                    ,input tt-fbr-prn-gds.gds-code
                    ) no-error.
if error-status:error then do:
    CASE return-value:
        when "gds-code":U then do:
            APPLY "ENTRY" to b-gds in frame Dialog-Frame.
        end.
        when "obj-type":U or when "obj-code":U then do:
           APPLY "ENTRY" to b-shop.
        end.
        when "prn-num" then do:
             APPLY "ENTRY" to b-printer.
        end.
    END CASE.
    return error.
end.
END PROCEDURE.
