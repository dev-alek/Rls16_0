define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-def          as character no-undo.
define input-output parameter  p-rr    as recid no-undo.
define variable v-attr-value           as character no-undo .
define variable v-attr-status          as integer   no-undo .
define variable v-corr-date            as date      no-undo .
define variable v-corr-time            as integer   no-undo .
define variable v-corr-user-name       as character no-undo .
define variable v-create-date          as date      no-undo .
define variable v-create-time          as integer   no-undo .
define variable v-create-user          as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание и редактирование типов алкогол" .
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
procedure alc-type-attr-value :
  define input  parameter p-alc-type-inner-code as integer   no-undo .
  define input  parameter p-create-user-db-num  as integer   no-undo .
  define input  parameter p-code                as character no-undo .
  define output parameter p-value               as character no-undo .
  define output parameter p-status              as integer   no-undo .
  define output parameter p-corr-date           as date      no-undo .
  define output parameter p-corr-time           as integer   no-undo .
  define output parameter p-corr-user-name      as character no-undo .
  define output parameter p-create-date         as date      no-undo .
  define output parameter p-create-time         as integer   no-undo .
  define output parameter p-create-user         as character no-undo .
  define buffer buf_alc-type-attr for ub.alc-type-attr .
  do
  on error undo, return error
  :
       find first buf_alc-type-attr no-lock where
                  buf_alc-type-attr.alc-type-inner-code   = p-alc-type-inner-code
            and   buf_alc-type-attr.create-user-db-num    = p-create-user-db-num
            and   buf_alc-type-attr.attr-code             = p-code no-error .
      if not available buf_alc-type-attr then do:
        return error return-value
        .
      end.
      else do:
      assign
        p-value           = buf_alc-type-attr.attr-value
        p-status          = buf_alc-type-attr.attr-status
        p-corr-date       = buf_alc-type-attr.corr-date
        p-corr-time       = buf_alc-type-attr.corr-time
        p-corr-user-name  = buf_alc-type-attr.corr-user-name
        p-create-date     = buf_alc-type-attr.create-date
        p-create-time     = buf_alc-type-attr.create-time
        p-create-user     = buf_alc-type-attr.create-user
      .
      end.
  end.
end procedure.
procedure alc-type-attr-val :
  define input  parameter p-alc-type-inner-code as integer   no-undo .
  define input  parameter p-create-user-db-num  as integer   no-undo .
  define input  parameter p-code                as character no-undo .
  define output parameter p-value               as character no-undo .
  define buffer buf_alc-type-attr for ub.alc-type-attr .
  do
  on error undo, return error
  :
       find first buf_alc-type-attr no-lock where
                  buf_alc-type-attr.alc-type-inner-code   = p-alc-type-inner-code
            and   buf_alc-type-attr.create-user-db-num    = p-create-user-db-num
            and   buf_alc-type-attr.attr-code             = p-code no-error .
      if not available buf_alc-type-attr then do:
        return error return-value
        .
      end.
      else do:
      assign
        p-value           = buf_alc-type-attr.attr-value
      .
      end.
  end.
end procedure.
procedure alc-type-attr-write :
  define input  parameter p-alc-type-inner-code as integer   no-undo .
  define input  parameter p-create-user-db-num  as integer   no-undo .
  define input  parameter p-code                as character no-undo .
  define input parameter p-value                as character no-undo .
  define input parameter p-status               as integer   no-undo .
  define input parameter p-corr-date            as date      no-undo .
  define input parameter p-corr-time            as integer   no-undo .
  define input parameter p-corr-user-name       as character no-undo .
  define input parameter p-create-date          as date      no-undo .
  define input parameter p-create-time          as integer   no-undo .
  define input parameter p-create-user          as character no-undo .
  define buffer buf_alc-type-attr for ub.alc-type-attr .
  do
  on error undo, return error
  :
       find first buf_alc-type-attr no-lock where
                  buf_alc-type-attr.alc-type-inner-code   = p-alc-type-inner-code
            and   buf_alc-type-attr.create-user-db-num    = p-create-user-db-num
            and   buf_alc-type-attr.attr-code             = p-code no-error .
      if not available buf_alc-type-attr then do:
        create buf_alc-type-attr .
        assign
          buf_alc-type-attr.alc-type-inner-code = p-alc-type-inner-code
          buf_alc-type-attr.create-user-db-num  = p-create-user-db-num
          buf_alc-type-attr.attr-code           = p-code
          buf_alc-type-attr.attr-value          = p-value
          buf_alc-type-attr.attr-status         = p-status
          buf_alc-type-attr.corr-date           = p-corr-date
          buf_alc-type-attr.corr-time           = p-corr-time
          buf_alc-type-attr.corr-user-name      = p-corr-user-name
          buf_alc-type-attr.create-date         = p-create-date
          buf_alc-type-attr.create-time         = p-create-time
          buf_alc-type-attr.create-user         = p-create-user
        .
      end.
      else do:
      assign
          buf_alc-type-attr.attr-value          = p-value
          buf_alc-type-attr.attr-status         = p-status
          buf_alc-type-attr.corr-date           = p-corr-date
          buf_alc-type-attr.corr-time           = p-corr-time
          buf_alc-type-attr.corr-user-name      = p-corr-user-name
          buf_alc-type-attr.create-date         = p-create-date
          buf_alc-type-attr.create-time         = p-create-time
          buf_alc-type-attr.create-user         = p-create-user
      .
      end.
  end.
end procedure.
procedure alc-type-attr-delete :
  define input  parameter p-alc-type-inner-code as integer   no-undo .
  define input  parameter p-create-user-db-num  as integer   no-undo .
  define input  parameter p-code                as character no-undo .
  define buffer buf_alc-type-attr for ub.alc-type-attr .
  do
  on error undo, return error
  :
       find first buf_alc-type-attr exclusive-lock where
                  buf_alc-type-attr.alc-type-inner-code   = p-alc-type-inner-code
            and   buf_alc-type-attr.create-user-db-num    = p-create-user-db-num
            and   buf_alc-type-attr.attr-code             = p-code no-error .
      if not available buf_alc-type-attr then do:
        return error return-value
        .
      end.
      else do:
        delete buf_alc-type-attr .
      end.
  end.
end procedure.
define buffer buf_alc-type for ub.alc-type .
define buffer buf_alc-type-attr for ub.alc-type-attr .
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
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE v-code AS CHARACTER FORMAT "x(8)":U
     LABEL "Код"
     VIEW-AS FILL-IN
     SIZE 8.88 BY 1 NO-UNDO.
DEFINE VARIABLE v-inner-code AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Код внут."
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-min-price AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Мин.опт.цена"
     VIEW-AS FILL-IN
     SIZE 8.88 BY 1 NO-UNDO.
DEFINE VARIABLE v-name AS CHARACTER FORMAT "X(80)":U
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 80 BY 1 NO-UNDO.
DEFINE VARIABLE rs-alc-declar AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Алк. продукция.   Форма декларации: 11", 1,
"Пивная продукция. Форма декларации: 12", 2
     SIZE 44 BY 1.96 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 83.5
     v-name AT ROW 3.13 COL 11.5 COLON-ALIGNED
     v-code AT ROW 4.21 COL 11.5 COLON-ALIGNED
     v-min-price AT ROW 4.21 COL 35.13 COLON-ALIGNED WIDGET-ID 8
     rs-alc-declar AT ROW 4.25 COL 49.5 NO-LABEL WIDGET-ID 4
     v-inner-code AT ROW 2.33 COL 11.5 COLON-ALIGNED
     SPACE(66.49) SKIP(3.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE " видов алкоголя"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
   Assign
      v-inner-code
      v-code
      v-name
      v-min-price
      rs-alc-declar
   .
   if p-def = 'ДОБАВЛЕНИЕ':U then do:
      FIND FIRST buf_alc-type WHERE buf_alc-type.alc-type-code   = v-code
                                AND buf_alc-type.alc-type-status = 0
                              NO-LOCK
                              NO-ERROR
                              .
      IF AVAILABLE buf_alc-type
      THEN DO:
         MESSAGE "Введенный код вида алкоголя уже существует" buf_alc-type.alc-type-name " ! " VIEW-AS  ALERT-BOX  ERROR.
         APPLY "entry"  TO v-code .
         RETURN NO-APPLY.
      END.
   END.
   if p-def = 'ДОБАВЛЕНИЕ':U OR p-def = 'ИЗМЕНЕНИЕ':U  then DO:
      if v-name = "" then do:
         message "Введите название вида алкоголя! "
         view-as  alert-box  error.
         apply "entry"  to v-name .
         return no-apply.
      end.
      if v-code = "" then do:
         message "Введите код вида алкоголя! "
         view-as  alert-box  error.
         apply "entry"  to v-code .
         return no-apply.
      end.
      if p-def = 'ДОБАВЛЕНИЕ':U then do:
         v-inner-code = next-value ( s-alc-type , ub).
         create buf_alc-type.
         Assign
            buf_alc-type.alc-type-inner-code = v-inner-code
            buf_alc-type.create-user-db-num  = v-cntxt-db-num
            buf_alc-type.create-date         = TODAY
            buf_alc-type.create-time         = TIME
            buf_alc-type.create-user-db-num  = v-cntxt-db-num
            buf_alc-type.create-user         = v-cntxt-userid
            p-rr                             = recid(buf_alc-type)
         .
      end.
      Assign
         buf_alc-type.alc-type-name  = v-name
         buf_alc-type.alc-type-code  = v-code
         buf_alc-type.corr-date      = TODAY
         buf_alc-type.corr-time      = TIME
         buf_alc-type.corr-user-name = v-cntxt-userid
      .
        run alc-type-attr-val (  input   buf_alc-type.alc-type-inner-code,
                                 input   buf_alc-type.create-user-db-num,
                                 input   "alc-min-price",
                                 output  v-attr-value
                              )  no-error.
                  IF NOT ERROR-STATUS:ERROR THEN DO:
              run alc-type-attr-delete (  input   buf_alc-type.alc-type-inner-code,
                                          input   buf_alc-type.create-user-db-num,
                                          input   "alc-min-price"
                                       )  no-error.
                  end.
        run alc-type-attr-write (  input    buf_alc-type.alc-type-inner-code,
                                   input    buf_alc-type.create-user-db-num,
                                   input    "alc-min-price",
                                   input    string(v-min-price),
                                   input    0,
                                   input    TODAY,
                                   input    TIME,
                                   input    v-cntxt-userid,
                                   input    TODAY,
                                   input    TIME,
                                   input    v-cntxt-userid
                                )  no-error.
        run alc-type-attr-val (  input   buf_alc-type.alc-type-inner-code,
                                 input   buf_alc-type.create-user-db-num,
                                 input   "alc-type",
                                 output  v-attr-value
                              )  no-error.
                  IF NOT ERROR-STATUS:ERROR THEN DO:
              run alc-type-attr-delete (  input   buf_alc-type.alc-type-inner-code,
                                          input   buf_alc-type.create-user-db-num,
                                          input   "alc-type"
                                       )  no-error.
                  end.
      case rs-alc-declar:
        when 1 then do:
        run alc-type-attr-write (  input    buf_alc-type.alc-type-inner-code,
                                   input    buf_alc-type.create-user-db-num,
                                   input    "alc-type",
                                   input    "1",
                                   input    0,
                                   input    TODAY,
                                   input    TIME,
                                   input    v-cntxt-userid,
                                   input    TODAY,
                                   input    TIME,
                                   input    v-cntxt-userid
                                )  no-error.
        end.
        when 2 then do:
        run alc-type-attr-write (  input    buf_alc-type.alc-type-inner-code,
                                   input    buf_alc-type.create-user-db-num,
                                   input    "alc-type",
                                   input    "2",
                                   input    0,
                                   input    TODAY,
                                   input    TIME,
                                   input    v-cntxt-userid,
                                   input    TODAY,
                                   input    TIME,
                                   input    v-cntxt-userid
                                )  no-error.
        end.
      end case .
   END.
END.
ON VALUE-CHANGED OF rs-alc-declar IN FRAME Dialog-Frame
DO:
  assign rs-alc-declar .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign frame Dialog-Frame:title = p-def + " вида алкоголя  " .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run local-init in this-procedure.
  run enable_UI in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-name v-code v-min-price rs-alc-declar v-inner-code
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-Help v-name v-code v-min-price rs-alc-declar
         v-inner-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE local-init :
if Lookup(p-def, 'ДОБАВЛЕНИЕ':U + "," + 'ПРОСМОТР':U + "," +  'ИЗМЕНЕНИЕ':U)  = 0 then DO:
      return error.
   end.
   if p-def = 'ИЗМЕНЕНИЕ':U then do:
      find first buf_alc-type
            where recid(buf_alc-type) = p-rr
            exclusive-lock
            no-error .
      if not available buf_alc-type then do:
         return error.
      end.
   end.
   if p-def = 'ПРОСМОТР':U then do:
      find first buf_alc-type
            where recid(buf_alc-type) = p-rr
            no-lock
            no-error .
         if not available buf_alc-type then DO:
            return error.
         end.
   end.
   if available buf_alc-type then do:
      assign
         v-inner-code = buf_alc-type.alc-type-inner-code
         v-name       = buf_alc-type.alc-type-name
         v-code       = buf_alc-type.alc-type-code
         .
         run alc-type-attr-val (  input   buf_alc-type.alc-type-inner-code,
                                  input   v-cntxt-db-num,
                                  input   "alc-type",
                                  output  v-attr-value
                               )  no-error.
          IF ERROR-STATUS:ERROR THEN DO:
              rs-alc-declar = 1.
          end.
          else do:
              rs-alc-declar = integer (v-attr-value) .
          end.
         run alc-type-attr-val (  input   buf_alc-type.alc-type-inner-code,
                                  input   v-cntxt-db-num,
                                  input   "alc-min-price",
                                  output  v-attr-value
                               )  no-error.
          IF NOT ERROR-STATUS:ERROR THEN DO:
              v-min-price = decimal (v-attr-value) .
          end.
   end.
   else do:
      if p-def = 'ДОБАВЛЕНИЕ':U then do:
      end.
   end.
END PROCEDURE.
