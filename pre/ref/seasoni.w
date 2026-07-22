define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-def          as character no-undo.
define input-output parameter  rr      as recid no-undo.
define shared variable g#db-num as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Корректировка сезона" .
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
define buffer buf_season for ub.season .
define buffer season-1 for ub.season .
define buffer buf_season-attr for ub.season-attr .
define variable loc-month-1 as integer no-undo.
define variable loc-month-2 as integer no-undo.
define variable v-user-select as logical no-undo .
define variable v-sel-obj-type like ub.clients.obj-type no-undo .
define variable v-sel-obj-code like ub.clients.obj-code no-undo .
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
PROCEDURE chk-gdssea :
define input  parameter p-gds-code as integer no-undo.
define input  parameter p-seaobj as character no-undo.
define input  parameter p-i-date1 as integer no-undo.
define input  parameter p-i-date2 as integer no-undo.
define input  parameter p-rowid as rowid no-undo.
define output parameter p-sea-code as integer no-undo.
define output parameter p-db-num as integer no-undo.
define output parameter p-ok as logical no-undo init yes.
define buffer buf_season for ub.season.
define buffer buf1_season for ub.season.
define buffer buf1_gds-season for ub.gds-season.
define buffer buf_season-attr for ub.season-attr.
define buffer buf1_season-attr for ub.season-attr.
  for each buf1_season no-lock where ((buf1_season.sea-month-1 <= p-i-date1 and buf1_season.sea-month-2 >= p-i-date1)
    or (buf1_season.sea-month-1 <= p-i-date2 and buf1_season.sea-month-2 >= p-i-date2)
    or (buf1_season.sea-month-1 <= p-i-date1 and buf1_season.sea-month-2 >= p-i-date1))
    and (rowid (buf1_season) <> p-rowid or p-rowid = ?):
      if can-find (first buf1_season-attr where buf1_season-attr.sea-code = buf1_season.sea-code
                                            and buf1_season-attr.db-num = buf1_season.db-num
                                            and buf1_season-attr.attr-code = 'sea-obj':U
                                            and buf1_season-attr.attr-value = p-seaobj
                                            )
        or
        (not can-find (first buf1_season-attr where buf1_season-attr.sea-code = buf1_season.sea-code
                                              and buf1_season-attr.db-num = buf1_season.db-num
                                              and buf1_season-attr.attr-code = 'sea-obj':U
                                              )
        and p-seaobj = "")
      then do:
        if can-find (first buf1_gds-season where  buf1_gds-season.sea-code = buf1_season.sea-code
                                              and buf1_gds-season.db-num = buf1_gds-season.db-num
                                              and buf1_gds-season.gds-code = p-gds-code)
        then do:
        assign
          p-ok = false
          p-sea-code = buf1_season.sea-code
          p-db-num = buf1_season.db-num.
          leave.
        end.
      end.
  end.
END PROCEDURE.
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE loc-month-1-date AS date FORMAT "99/99/99":U
     LABEL "c"
     view-as fill-in
     SIZE 9.00 BY 1 NO-UNDO.
DEFINE VARIABLE loc-month-2-date AS date FORMAT "99/99/99":U
     LABEL "по"
     view-as fill-in
     SIZE 9.00 BY 1 NO-UNDO.
DEFINE VARIABLE loc-code AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "Код"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE loc-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 47.13 BY 1 NO-UNDO.
DEFINE VARIABLE rs-area AS CHARACTER INIT 'sea-global':U
     LABEL "Сезон"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "глобальный", 'sea-global':U,
          "локальный", 'sea-local':U
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE obj-name AS character
     LABEL "Объект"
     VIEW-AS TEXT
     SIZE 7.50 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Объект"
     SIZE 3 BY 1.
DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 21
     rs-area AT ROW 2.25 COL 6.25
     loc-name AT ROW 4.5 COL 11.25 COLON-ALIGNED
     loc-month-1-date AT ROW 6 COL 11 COLON-ALIGNED
     loc-month-2-date AT ROW 6 COL 25 COLON-ALIGNED
     loc-code AT ROW 3.5 COL 11.25 COLON-ALIGNED
     obj-name AT ROW 7.5 COL 5.0
     b-obj AT ROW 7.35 COL 20.25
     SPACE(40.00) SKIP(1.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Сезон"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-OK IN FRAME Dialog-Frame
DO:
  define variable v-ok as logical no-undo.
  define variable v-sea-code as integer no-undo.
  define variable v-db-num as integer no-undo.
  define variable v-longchar as longchar no-undo .
  define buffer buf_goods for ub.goods.
  define buffer buf_gds-season for ub.gds-season.
  Assign frame Dialog-Frame
    loc-code loc-month-1-date loc-month-2-date loc-name.
  assign
    loc-month-1 = integer(loc-month-1-date)
    loc-month-2 = integer(loc-month-2-date)
    .
  if loc-month-1 > loc-month-2 Then
  do:
    message "В интервале дат первая должна быть меньше второй ! " view-as  alert-box  error.
    apply "entry"  to loc-month-1-date .
      return no-apply.
     end.
  if loc-month-1 = ? or loc-month-2 = ? Then
  do:
    message "Значение дат не может быть пустым " view-as  alert-box  error.
    apply "entry"  to loc-month-1-date .
      return no-apply.
      end.
  if loc-name = "" then
  do:
    message "Введите название сезона ! " view-as  alert-box  error.
    apply "entry"  to loc-name .
      return no-apply.
      end.
  if obj-name = "" and rs-area = 'sea-local':U then
  do:
    message "Укажите объект локального сезона ! " view-as  alert-box  error.
    apply "entry"  to loc-name .
    return no-apply.
  end.
  for each buf_gds-season no-lock where buf_gds-season.sea-code = buf_season.sea-code
    and buf_gds-season.db-num = buf_season.db-num:
    run chk-gdssea in this-procedure
      ( input buf_gds-season.gds-code,
        input obj-name,
        input buf_season.sea-month-1,
        input buf_season.sea-month-2,
        input rowid (buf_season),
        output v-sea-code,
        output v-db-num,
        output v-ok) no-error.
    if not v-ok then do:
      find first buf_goods no-lock where buf_goods.gds-code = buf_gds-season.gds-code no-error.
      assign
        v-longchar = v-longchar +
          substitute ("Товар &1 &2 пересекается с сезоном &3 &4.&5", buf_goods.gds-code, buf_goods.gds-name, v-sea-code, buf_season.sea-name, chr(10))
        .
      run gbl/d-longchar.w (
              ?,
              'Editor_row=2\':u
            + 'title=Проверка товарного наполнения сезона: при изменении сезона возникли пересечения\':u
            + 'Editor_col=1\':u
            + 'Editor_width=96\':u
            + 'Editor_height=21\':u
            + 'readonly=yes\':u
          ,input-output v-longchar
          ,output v-ok ) no-error .
          if error-status :error then message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "4"
            view-as alert-box error
          .
      assign
        v-longchar = "".
      return no-apply.
      end.
    end.
  if p-def = 'ДОБАВЛЕНИЕ':U then
  do:
    create buf_season.
    Assign
      buf_season.sea-code = loc-code
      buf_season.db-num   = v-cntxt-db-num
      .
      end.
  find first buf_season-attr exclusive-lock where buf_season-attr.sea-code = buf_season.sea-code and buf_season-attr.attr-code = 'sea-obj':U no-error.
  if rs-area = 'sea-global':U then do:
    if available buf_season-attr then do:
      delete buf_season-attr.
    end.
  end.
  else do:
    if not available buf_season-attr then do:
      create buf_season-attr.
      assign
        buf_season-attr.db-num = v-cntxt-db-num
      .
    end.
       Assign
      buf_season-attr.sea-code = buf_season.sea-code
      buf_season-attr.attr-code = 'sea-obj':U
      buf_season-attr.attr-value = obj-name
         .
    end.
  if p-def = 'ДОБАВЛЕНИЕ':U OR p-def = 'ИЗМЕНЕНИЕ':U  then do:
       Assign
      buf_season.sea-name    = loc-name
      buf_season.sea-month-1 = integer(loc-month-1-date)
      buf_season.sea-month-2 = integer(loc-month-2-date)
      rr                 = recid(buf_season)
        .
  end.
    else rr = ? .
END.
ON CHOOSE OF B-obj IN FRAME Dialog-Frame
DO:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-sel-obj-type
  ,output v-sel-obj-code
  )  .
  obj-name:screen-value in frame Dialog-Frame = if v-sel-obj-code <> 0 then string (v-sel-obj-type) + string (v-sel-obj-code) else "".
  assign
    obj-name.
END.
ON VALUE-CHANGED OF rs-area IN FRAME Dialog-Frame
DO:
  assign rs-area.
  if rs-area = 'sea-global':U then do:
    DISABLE
      B-obj with frame Dialog-Frame.
    obj-name = "".
    DISPLAY obj-name with frame Dialog-Frame.
  end.
  else do:
    ENABLE
      B-obj with frame Dialog-Frame.
    obj-name = "".
    DISPLAY obj-name with frame Dialog-Frame.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
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
assign frame Dialog-Frame:title = "Сезон - " + p-def.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run enable_UI in this-procedure .
  run local-init in this-procedure  no-error .
      if error-status :error then return error.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY loc-name loc-month-1-date loc-month-2-date loc-code b-obj obj-name rs-area
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-Help loc-name loc-month-1-date loc-month-2-date loc-code b-obj obj-name rs-area
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE local-init :
if Lookup(p-def, 'ДОБАВЛЕНИЕ':U + "," + 'ПРОСМОТР':U + "," +  'ИЗМЕНЕНИЕ':U)  = 0 then return error.
  if p-def = 'ИЗМЕНЕНИЕ':U then
  do:
    find first buf_season where recid(buf_season) = rr  exclusive-lock  no-error .
      if error-status :error then return error.
    find first buf_season-attr exclusive-lock where buf_season-attr.sea-code = buf_season.sea-code and buf_season-attr.attr-code = 'sea-obj':U no-error.
    DISABLE
      B-obj obj-name rs-area with frame Dialog-Frame.
    if available buf_season-attr then do:
      rs-area = 'sea-local':U.
      obj-name:screen-value in frame Dialog-Frame = buf_season-attr.attr-value.
      assign
        obj-name.
  end.
    else do:
      rs-area = 'sea-global':U.
      if g#db-num <> 0 then disable b-ok with frame Dialog-Frame.
    end.
  end.
  if p-def = 'ПРОСМОТР':U then
  do:
    find first buf_season where recid(buf_season) = rr  no-lock  no-error .
      if error-status :error then return error.
  end.
  if available buf_season then
  do:
        assign
      loc-code         = buf_season.sea-code
      loc-name         = buf_season.sea-name
      loc-month-1      = buf_season.sea-month-1
      loc-month-2      = buf_season.sea-month-2
      loc-month-1-date = date (buf_season.sea-month-1)
      loc-month-2-date = date (buf_season.sea-month-2)
          .
    end.
  else
  do:
    if p-def = 'ДОБАВЛЕНИЕ':U then
    do:
      assign
        loc-code = next-value ( s-casm , ub )
        loc-code:screen-value in frame Dialog-Frame = string(loc-code)
      .
      disable b-obj with frame Dialog-Frame.
      if g#db-num <> 0 then do:
        rs-area = 'sea-local':U.
        display rs-area with frame Dialog-Frame.
        disable rs-area with frame Dialog-Frame.
        enable b-obj with frame Dialog-Frame.
      end.
        end.
    end.
  DISPLAY loc-name loc-month-1-date loc-month-2-date loc-code rs-area
      WITH FRAME Dialog-Frame.
END PROCEDURE.
