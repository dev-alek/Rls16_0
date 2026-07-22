define input parameter parparentproc  as widget-handle no-undo .
define input parameter p-mode as character no-undo.
define input-output parameter p-rr      as  recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование лицензий на продажу алкоголя".
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
define variable RowID-list   as character no-undo .
define variable rid-list-sale as character no-undo .
define buffer buf_alc-sale-lic for ub.alc-sale-lic .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-types
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "типы"
     SIZE 3 BY .87 TOOLTIP "типы алкоголя, разрешенные к продаже по этой лицензии".
DEFINE VARIABLE f-client AS CHARACTER FORMAT "X(40)":U
      VIEW-AS TEXT
     SIZE 41.3 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-from AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Дествует с"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-get AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Дата выдачи"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-to AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE f-number AS CHARACTER FORMAT "X(16)":U
     LABEL "номер"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-seria AS CHARACTER FORMAT "X(16)":U
     LABEL "Серия"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-types AS CHARACTER FORMAT "X(10)":U INITIAL "не выбраны"
      VIEW-AS TEXT
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE f-who-are-got AS CHARACTER FORMAT "X(30)":U
     LABEL "Кем выдана"
     VIEW-AS FILL-IN
     SIZE 30 BY 1 NO-UNDO.
DEFINE VARIABLE t-all AS LOGICAL INITIAL no
     LABEL "все типы алкоголя"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 42
     f-seria AT ROW 3.13 COL 5 WIDGET-ID 2
     f-number AT ROW 3.13 COL 34.5 COLON-ALIGNED WIDGET-ID 8
     f-date-get AT ROW 4.2 COL 12 COLON-ALIGNED WIDGET-ID 10
     f-who-are-got AT ROW 5.27 COL 12 COLON-ALIGNED WIDGET-ID 12
     f-date-from AT ROW 6.33 COL 12 COLON-ALIGNED WIDGET-ID 14
     f-date-to AT ROW 6.33 COL 30.5 COLON-ALIGNED WIDGET-ID 16
     b-types AT ROW 7.4 COL 22.5 WIDGET-ID 20
     t-all AT ROW 7.5 COL 2 WIDGET-ID 18
     f-client AT ROW 2 COL 10 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     f-types AT ROW 7.4 COL 32 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     SPACE(9.30) SKIP(0.10)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Лицензия поставщика алкоголя"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
   assign
      f-seria
      f-number
      f-date-get
      f-who-are-got
      f-date-from
      f-date-to
      t-all
   .
  if f-seria = "" then do:
     message "Введите серию лицензии"
     view-as alert-box error.
     apply "entry"  to f-seria.
     return no-apply.
  end.
  if f-number = "" then do:
     message "Введите номер лицензии"
     view-as alert-box error.
     apply "entry"  to f-number.
     return no-apply.
  end.
  if f-date-get = ? then do:
     message "Введите дату выдачи лицензии"
     view-as alert-box error.
     apply "entry"  to f-date-get.
     return no-apply.
  end.
  if f-date-from = ? then do:
     message "Введите дату начала действия лицензии"
     view-as alert-box error.
     apply "entry"  to f-date-from.
     return no-apply.
  end.
  if f-date-to = ? then do:
     message "Введите дату окончания действия лицензии"
     view-as alert-box error.
     apply "entry"  to f-date-to.
     return no-apply.
  end.
  if f-who-are-got = "" then do:
     message "Введите кем выдана лицензия"
     view-as alert-box error.
     apply "entry"  to f-who-are-got.
     return no-apply.
  end.
  if not t-all
  and RowID-list = "" then do:
     message "Введите типы алкоголя, разрешенные к поставке по этой лицензии"
     view-as alert-box error.
     apply "entry"  to b-types.
     return no-apply.
  end.
  do
  transaction:
   if p-rr = ? then do:
      run create-lic in this-procedure.
   end.
   else do:
      run update-lic in this-procedure.
   end.
   run update-alc-type in this-procedure.
  end.
END.
ON CHOOSE OF b-types IN FRAME Dialog-Frame
DO:
  define buffer buf_alc-sale-lic-type for ub.alc-sale-lic-type .
  define buffer buf_alc-type     for ub.alc-type .
  define variable v-ok as logical no-undo .
  define variable v-count as integer no-undo .
  if t-all then do:
     message 'Выставлен признак "все типы алкоголя" ' SKIP
             'Снять признак и продолжить выбор типов алкоголя?'
     view-as alert-box question
     buttons ok-cancel
     update v-ok
     .
      if not v-ok then do:
         return no-apply.
      end.
      else do:
         assign
         t-all = false
         .
      end.
  end.
  run ref/alc-type.w
    ( input Parparentproc
    , input "b-sel,b-mark"
    , input-OUTPUT RowID-list
    , output v-ok
      ).
  if RowID-list = ""
  and not t-all
  then do:
    assign
     f-types = "не выбраны"
    .
  end.
  else do:
    assign
     f-types = "выбраны"
     .
  end.
   assign
      f-seria
      f-number
      f-date-get
      f-who-are-got
      f-date-from
      f-date-to
      t-all
   .
  RUN enable_UI.
END.
ON VALUE-CHANGED OF t-all IN FRAME Dialog-Frame
DO:
   assign
      f-seria
      f-number
      f-date-get
      f-who-are-got
      f-date-from
      f-date-to
         t-all
   .
   IF t-all
   THEN DO:
      ASSIGN
         RowID-list = ""
         f-types = "выбраны"
      .
   END.
   ELSE DO:
      assign
         f-types = "не выбраны"
      .
   END.
   RUN enable_UI.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of f-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of f-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of f-date-from in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of f-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of f-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of f-date-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date4
    MENU-ITEM m-ed-date4-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date4-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date4-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date4-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if f-date-from :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      f-date-from :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date4 :HANDLE
      f-date-from :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle4 as handle no-undo .
  assign
    v-label-handle4 = f-date-from :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle4)
  then do:
    if v-label-handle4 :tooltip = ""
    or v-label-handle4 :tooltip = ?
    then do:
      assign
        v-label-handle4 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date4-1 in menu m-ed-date4 DO:
    apply "ctrl-b":U to f-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-2 in menu m-ed-date4 DO:
    apply "ctrl-d":U to f-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-3 in menu m-ed-date4 DO:
    apply "ctrl-e":U to f-date-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-4 in menu m-ed-date4 DO:
    apply "ctrl-f":U to f-date-from in frame Dialog-Frame .
  END.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of f-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of f-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of f-date-to in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of f-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of f-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of f-date-to in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date6
    MENU-ITEM m-ed-date6-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date6-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date6-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date6-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if f-date-to :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      f-date-to :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date6 :HANDLE
      f-date-to :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle6 as handle no-undo .
  assign
    v-label-handle6 = f-date-to :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle6)
  then do:
    if v-label-handle6 :tooltip = ""
    or v-label-handle6 :tooltip = ?
    then do:
      assign
        v-label-handle6 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date6-1 in menu m-ed-date6 DO:
    apply "ctrl-b":U to f-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-2 in menu m-ed-date6 DO:
    apply "ctrl-d":U to f-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-3 in menu m-ed-date6 DO:
    apply "ctrl-e":U to f-date-to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date6-4 in menu m-ed-date6 DO:
    apply "ctrl-f":U to f-date-to in frame Dialog-Frame .
  END.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of f-date-get in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of f-date-get in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of f-date-get in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of f-date-get in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of f-date-get in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of f-date-get in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date8
    MENU-ITEM m-ed-date8-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date8-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date8-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date8-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if f-date-get :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      f-date-get :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date8 :HANDLE
      f-date-get :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle8 as handle no-undo .
  assign
    v-label-handle8 = f-date-get :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle8)
  then do:
    if v-label-handle8 :tooltip = ""
    or v-label-handle8 :tooltip = ?
    then do:
      assign
        v-label-handle8 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date8-1 in menu m-ed-date8 DO:
    apply "ctrl-b":U to f-date-get in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-2 in menu m-ed-date8 DO:
    apply "ctrl-d":U to f-date-get in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-3 in menu m-ed-date8 DO:
    apply "ctrl-e":U to f-date-get in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date8-4 in menu m-ed-date8 DO:
    apply "ctrl-f":U to f-date-get in frame Dialog-Frame .
  END.
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define buffer bf_clients for ub.clients.
  define buffer bf_alc-type for ub.alc-type.
  define buffer bf_alc-sale-lic-type for ub.alc-sale-lic-type.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do
  transaction:
     if p-rr = ? then do:
        return error "ссылка на лицензию не передана".
     end.
     find first buf_alc-sale-lic
          where recid(buf_alc-sale-lic) = p-rr
          exclusive-lock
          no-error
          .
     if not available buf_alc-sale-lic then do:
        return error "неправильная ссылка на лицензию".
     end.
     assign
       f-seria       = buf_alc-sale-lic.seria
       f-number      = buf_alc-sale-lic.number
       f-date-get    = buf_alc-sale-lic.date-get
       f-who-are-got = buf_alc-sale-lic.who-are-got
       f-date-from   = buf_alc-sale-lic.date-from
       f-date-to     = buf_alc-sale-lic.date-to
       t-all         = if buf_alc-sale-lic.all-type >= 1 then true else false
     .
     find first bf_clients
          where bf_clients.obj-type = buf_alc-sale-lic.cli-type
            and bf_clients.obj-code = buf_alc-sale-lic.cli-code
          no-lock
          no-error
          .
     if not available bf_clients then do:
        return error substitute ("Фирма &1&2 не найдена.", buf_alc-sale-lic.cli-code, buf_alc-sale-lic.cli-type).
     end.
     assign
        f-client = substitute( "&1&2, &3", bf_clients.obj-code, bf_clients.obj-type, bf_clients.obj-name )
     .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid11 as character no-undo .
define variable v-num-entry11 as integer   no-undo .
assign
  v-str-recid11 = trim( string( recid( bf_clients ) , "->>>>>>>>>>>9":U ) )
  v-num-entry11 = lookup( v-str-recid11 , rid-list-sale )
.
if v-num-entry11 > 0 then do:
  assign
    entry( v-num-entry11, rid-list-sale ) = "":U
    rid-list-sale = trim( replace( rid-list-sale , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list-sale = rid-list-sale + ( if rid-list-sale = "":U then "":U else chr(44) ) + v-str-recid11
  .
end.
     if t-all
      then do:
         assign
            f-types = "выбраны"
         .
      end.
      else do:
         for each  bf_alc-sale-lic-type
             where bf_alc-sale-lic-type.alc-sale-lic-code = buf_alc-sale-lic.alc-sale-lic-code
             no-lock,
             first bf_alc-type
             where bf_alc-type.alc-type-inner-code = bf_alc-sale-lic-type.alc-type-inner-code
             no-lock
             :
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid13 as character no-undo .
define variable v-num-entry13 as integer   no-undo .
assign
  v-str-recid13 = trim( string( recid( bf_alc-type ) , "->>>>>>>>>>>9":U ) )
  v-num-entry13 = lookup( v-str-recid13 , RowID-list )
.
if v-num-entry13 > 0 then do:
  assign
    entry( v-num-entry13, RowID-list ) = "":U
    RowID-list = trim( replace( RowID-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    RowID-list = RowID-list + ( if RowID-list = "":U then "":U else chr(44) ) + v-str-recid13
  .
end.
         end.
         if RowID-list = "" then DO:
            assign
               f-types = "не выбраны"
            .
         end.
         else do:
            assign
               f-types = "выбраны"
            .
         end.
      end.
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE create-lic :
    define buffer buf_clients for ub.clients .
    define variable v-code as integer no-undo .
     v-code = next-value(s-alc-sale-lic, ub).
     create buf_alc-sale-lic.
     assign
       buf_alc-sale-lic.alc-sale-lic-code = v-code
       buf_alc-sale-lic.seria       = f-seria
       buf_alc-sale-lic.number      = f-number
       buf_alc-sale-lic.date-get    = f-date-get
       buf_alc-sale-lic.who-are-got = f-who-are-got
       buf_alc-sale-lic.date-from   = f-date-from
       buf_alc-sale-lic.date-to     = f-date-to
       buf_alc-sale-lic.all-type    = if t-all  then 1 else 0
       buf_alc-sale-lic.cli-type    = 'орг':U
       buf_alc-sale-lic.cli-code    = v-cntxt-host-code-obj
       buf_alc-sale-lic.create-user-db-num = v-cntxt-db-num
       buf_alc-sale-lic.lic-status         = 0
       buf_alc-sale-lic.create-user        = v-cntxt-userid
       buf_alc-sale-lic.corr-user-name     = v-cntxt-userid
       buf_alc-sale-lic.create-date        = today
       buf_alc-sale-lic.corr-date          = today
       buf_alc-sale-lic.create-time        = time
       buf_alc-sale-lic.corr-time          = time
     .
      assign
         p-rr = recid (buf_alc-sale-lic)
      .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-seria f-number f-date-get f-who-are-got f-date-from f-date-to t-all
          f-client f-types
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help f-seria f-number f-date-get f-who-are-got
         f-date-from f-date-to b-types t-all f-client f-types
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE update-alc-type :
define buffer buf_alc-sale-lic-type for ub.alc-sale-lic-type .
define buffer buf_alc-type          for ub.alc-type     .
  define variable v-count as integer no-undo .
    for each  buf_alc-sale-lic-type
        where buf_alc-sale-lic-type.alc-sale-lic-code = buf_alc-sale-lic.alc-sale-lic-code
        exclusive-lock,
        first buf_alc-type
        where buf_alc-type.alc-type-inner-code = buf_alc-sale-lic-type.alc-type-inner-code
        no-lock
        :
        if index(RowID-list, trim( string( recid(buf_alc-type) , "->>>>>>>>>>>9":U ) )) = 0 THEN do:
           delete buf_alc-sale-lic-type.
        end.
    end.
    DO v-count = 1 TO NUM-ENTRIES(RowID-list)
    on error undo, next
    :
      find first buf_alc-type
         where recid( buf_alc-type ) = INTEGER(ENTRY(v-count, RowID-list))
         NO-LOCK
         no-error.
      IF AVAILABLE buf_alc-type
      and not can-find( first buf_alc-sale-lic-type
                        where buf_alc-sale-lic-type.alc-sale-lic-code   = buf_alc-sale-lic.alc-sale-lic-code
                          and buf_alc-sale-lic-type.alc-type-inner-code = buf_alc-type.alc-type-inner-code)
      THEN DO:
         CREATE buf_alc-sale-lic-type.
         ASSIGN
            buf_alc-sale-lic-type.alc-sale-lic-code   = buf_alc-sale-lic.alc-sale-lic-code
            buf_alc-sale-lic-type.alc-type-inner-code = buf_alc-type.alc-type-inner-code
            buf_alc-sale-lic-type.corr-date = today
            buf_alc-sale-lic-type.corr-time = time
            buf_alc-sale-lic-type.corr-user-name  = v-cntxt-userid
            buf_alc-sale-lic-type.create-alc-type-user-db-num = v-cntxt-db-num
            buf_alc-sale-lic-type.create-date = today
            buf_alc-sale-lic-type.create-time = time
            buf_alc-sale-lic-type.create-user = v-cntxt-userid
            buf_alc-sale-lic-type.create-user-db-num = v-cntxt-db-num
         .
      END.
     end.
    FOR EACH buf_alc-sale-lic-type
        EXCLUSIVE-LOCK
        :
        find first buf_alc-type
             where buf_alc-type.alc-type-inner-code = buf_alc-sale-lic-type.alc-type-inner-code
             NO-LOCK
             no-error
             .
         IF NOT AVAILABLE buf_alc-type
         OR INDEX( RowID-list, STRING(recid( buf_alc-type ))) = 0
         THEN DO:
            DELETE buf_alc-sale-lic-type.
         END.
    END.
END PROCEDURE.
PROCEDURE update-lic :
    define buffer buf_clients for ub.clients .
     find first buf_clients
          where recid(buf_clients) = INTEGER(ENTRY(1, rid-list-sale))
          no-lock
          no-error
          .
     assign
       buf_alc-sale-lic.seria       = f-seria
       buf_alc-sale-lic.number      = f-number
       buf_alc-sale-lic.date-get    = f-date-get
       buf_alc-sale-lic.who-are-got = f-who-are-got
       buf_alc-sale-lic.date-from   = f-date-from
       buf_alc-sale-lic.date-to     = f-date-to
       buf_alc-sale-lic.all-type    = if t-all  then 1 else 0
       buf_alc-sale-lic.cli-code    = buf_clients.obj-code
       buf_alc-sale-lic.cli-type    = buf_clients.obj-type
       buf_alc-sale-lic.corr-user-name     = v-cntxt-userid
       buf_alc-sale-lic.corr-date          = today
       buf_alc-sale-lic.corr-time          = time
     .
END PROCEDURE.
