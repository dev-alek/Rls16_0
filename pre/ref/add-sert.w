DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter i-mode as char no-undo.
define input-output parameter i-rec as recid no-undo.
define input parameter i-type like ub.clients.obj-type no-undo.
define input parameter i-code like ub.clients.obj-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка сертификата".
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
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
def buffer b-sert for ub.sert.
DEFINE BUTTON b-cli
     LABEL ""
     SIZE 2.5 BY .96.
DEFINE BUTTON b-gds
     LABEL "Товар(ы)"
     SIZE 10 BY 1 TOOLTIP "Выбор одного или нескольких товаров".
DEFINE BUTTON b-help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-hist
     LABEL "История"
     SIZE 10 BY 1 TOOLTIP "История сертификата".
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1 TOOLTIP "Вод сертификата"
     BGCOLOR 8 .
DEFINE VARIABLE v-c-name AS CHARACTER FORMAT "X(30)":U
     VIEW-AS FILL-IN
     SIZE 41.13 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-gds AT ROW 1 COL 31
     b-hist AT ROW 1 COL 41
     b-help AT ROW 1 COL 51
     ub.sert.cli-code AT ROW 4.04 COL 1 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     ub.sert.cli-type AT ROW 4.04 COL 12.88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6.5 BY 1
     v-c-name AT ROW 4.04 COL 22 COLON-ALIGNED NO-LABEL
     b-cli AT ROW 4.08 COL 21.5
     ub.sert.sert-code AT ROW 5.58 COL 12.5 COLON-ALIGNED FORMAT "X(35)"
          VIEW-AS FILL-IN
          SIZE 37 BY 1 TOOLTIP "Код сертификата"
     ub.sert.first-date AT ROW 6.92 COL 12.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 11 BY 1 TOOLTIP "Дата начала действия сертификата"
     ub.sert.last-date AT ROW 6.92 COL 47.25 COLON-ALIGNED
          LABEL "Дата окончания"
          VIEW-AS FILL-IN
          SIZE 11 BY 1 TOOLTIP "Дата окончания сертификата"
     ub.sert.sert-org AT ROW 8.17 COL 26 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN
          SIZE 37 BY 1
     ub.sert.blank-num AT ROW 9.5 COL 13 COLON-ALIGNED WIDGET-ID 4
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.sert.PS AT ROW 10.79 COL 13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 50.13 BY 1
     "Поставщик/Производитель:" VIEW-AS TEXT
          SIZE 28.75 BY .92 AT ROW 3.17 COL 1
     SPACE(35.37) SKIP(8.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Добавление/изменение сертификата"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-cli:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-gds IN FRAME Dialog-Frame
DO:
  def var g-l as log init no no-undo.
  define variable v-host-code like ub.sysconf.host-code no-undo .
  message "Вы хотите задать этот сертификат для товара(ов)?"
    view-as alert-box question buttons Yes-No update g-l.
  if g-l then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
   run str/gds-list.w (
                 input parparentproc
                ,input v-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code).
  end.
END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE ub.sert THEN RETURN.
  run ref/c-serts.w (
                INPut parParentProc
               ,INPUT '':U
               ,INPUT 'onet'
               ,INPUT sert.cli-type
               ,INPUT sert.cli-code
               ,INPUT sert.sert-code
               ,INPUT 0
               ,INPUT '':U
               ,INPUT-OUTPUT v-rid-list) NO-ERROR.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
define variable v-ii as integer no-undo .
define variable v-ok  as integer no-undo .
define variable v-err as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
def var p-l as log init no no-undo.
  if can-find(first b-sert where
                    b-sert.cli-type = ub.sert.cli-type and
                    b-sert.cli-code =  ub.sert.cli-code and
                    b-sert.sert-code = input ub.sert.sert-code and
                    recid(b-sert) <> recid(ub.sert) ) then do:
    message "По данному клиенту уже есть сертификат с кодом " input sert.sert-code
            sert.cli-type  sert.cli-code       view-as alert-box error.
    return no-apply.
  end.
  assign
  sert.last-date
  sert.first-date
  sert.ps
  sert.blank-num
  sert.sert-org
  ub.sert.sert-code.
  if sert.last-date = ? then do:
    message "Введите дату окончания сертификата" view-as alert-box error.
    return no-apply.
  end.
  if sert.first-date = ? then do:
    message "Введите дату начала действия сертификата" view-as alert-box error.
    return no-apply.
  end.
  if sert.sert-code = ?
  or sert.sert-code = ''
  then do:
    message "Введите номер сертификата" view-as alert-box error.
    return no-apply.
  end.
  if can-find(first gds-list) or
     can-find (first ub.sert-join where
                     ub.sert-join.cli-type = i-type and
                     ub.sert-join.cli-code = i-code AND
                     ub.sert-join.SERT-code = input ub.sert.sert-code
                     ) then.
  else do:
    if i-mode = 'ДОБАВЛЕНИЕ':U then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
      run str/gds-list.w (
                    input parparentproc
                    ,input v-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code).
    end.
    IF NOT CAN-FIND(FIRST GDS-LIST) THEN DO:
      message "Нет ни одного товара для данного сертификата. Будете задавать товар?"
          view-as alert-box question buttons Yes-No update g-log as log.
          if g-log then do:
              enable b-gds with frame Dialog-Frame.
              disp b-gds   with frame Dialog-Frame.
              return no-apply.
          end.
          else p-l = yes.
    end.
  end.
  if not p-l then run cre-s-j(output v-ii, output v-ok, output v-err).
  message
  substitute("Обработано &1 товаров, создано &2 привязок к сертификату, ошибок &3", v-ii, v-ok, v-err)
  view-as alert-box .
  i-rec = recid(sert).
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of ub.sert.first-date in frame Dialog-Frame
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
on delete-character of ub.sert.first-date in frame Dialog-Frame
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
on ctrl-d of ub.sert.first-date in frame Dialog-Frame
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
on ctrl-b of ub.sert.first-date in frame Dialog-Frame
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
on ctrl-e of ub.sert.first-date in frame Dialog-Frame
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
on ctrl-f of ub.sert.first-date in frame Dialog-Frame
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
  define MENU m-ed-date7
    MENU-ITEM m-ed-date7-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date7-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date7-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date7-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if ub.sert.first-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      ub.sert.first-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date7 :HANDLE
      ub.sert.first-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle7 as handle no-undo .
  assign
    v-label-handle7 = ub.sert.first-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle7)
  then do:
    if v-label-handle7 :tooltip = ""
    or v-label-handle7 :tooltip = ?
    then do:
      assign
        v-label-handle7 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date7-1 in menu m-ed-date7 DO:
    apply "ctrl-b":U to ub.sert.first-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-2 in menu m-ed-date7 DO:
    apply "ctrl-d":U to ub.sert.first-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-3 in menu m-ed-date7 DO:
    apply "ctrl-e":U to ub.sert.first-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-4 in menu m-ed-date7 DO:
    apply "ctrl-f":U to ub.sert.first-date in frame Dialog-Frame .
  END.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of ub.sert.last-date in frame Dialog-Frame
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
on delete-character of ub.sert.last-date in frame Dialog-Frame
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
on ctrl-d of ub.sert.last-date in frame Dialog-Frame
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
on ctrl-b of ub.sert.last-date in frame Dialog-Frame
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
on ctrl-e of ub.sert.last-date in frame Dialog-Frame
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
on ctrl-f of ub.sert.last-date in frame Dialog-Frame
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
  define MENU m-ed-date9
    MENU-ITEM m-ed-date9-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date9-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date9-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date9-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if ub.sert.last-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      ub.sert.last-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date9 :HANDLE
      ub.sert.last-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle9 as handle no-undo .
  assign
    v-label-handle9 = ub.sert.last-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle9)
  then do:
    if v-label-handle9 :tooltip = ""
    or v-label-handle9 :tooltip = ?
    then do:
      assign
        v-label-handle9 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date9-1 in menu m-ed-date9 DO:
    apply "ctrl-b":U to ub.sert.last-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-2 in menu m-ed-date9 DO:
    apply "ctrl-d":U to ub.sert.last-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-3 in menu m-ed-date9 DO:
    apply "ctrl-e":U to ub.sert.last-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-4 in menu m-ed-date9 DO:
    apply "ctrl-f":U to ub.sert.last-date in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   find ub.clients where ub.clients.obj-type = i-type and
                                ub.clients.obj-code = i-code no-lock.
   if i-mode = 'ДОБАВЛЕНИЕ':U then do:
        disable b-gds with frame Dialog-Frame.
        create ub.sert.
        assign
            ub.sert.cli-type = i-type
            ub.sert.cli-code = i-code.
   end.
   else do:
      find ub.sert where recid(ub.sert) = i-rec.
      enable b-gds with frame Dialog-Frame.
   end.
   v-c-name = ub.clients.obj-name.
  RUN Myenable.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE cre-s-j :
define buffer gl-goods for ub.goods.
define output parameter v-ii as integer no-undo .
define output parameter v-ok  as integer no-undo .
define output parameter v-err as integer no-undo .
define variable v-b-code like ub.bar-code.b-code no-undo .
  _gds-list:
  for each gds-list :
    assign
    v-ii = v-ii + 1
    .
    find first gl-goods where
              gl-goods.artic     = gds-list.artic     and
              gl-goods.prod-type = gds-list.prod-type and
              gl-goods.prod-code = gds-list.prod-code no-lock.
    FIND ub.gds-prt WHERE
         ub.gds-prt.upper-code = gds-list.prt-root NO-LOCK .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gl-goods.gds-code
  ,input  ?
  ,output v-b-code
  )  .
    find first ub.sert-join where
              ub.sert-join.cli-type = i-type and
              ub.sert-join.cli-code = i-code and
              ub.sert-join.sert-code = ub.sert.sert-code and
              ub.sert-join.b-code = v-b-code no-error.
    if not available ub.sert-join then do:
        create ub.sert-join.
        assign
        ub.sert-join.cli-type = i-type
        ub.sert-join.cli-code = i-code
        ub.sert-join.sert-code = ub.sert.sert-code
        ub.sert-join.b-code = v-b-code .
        release ub.sert-join no-error .
    end.
    if error-status:error then do:
      assign
      v-err = v-err + 1
      .
    end.
    else do:
      assign
      v-ok = v-ok + 1
      .
    end.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-c-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.sert THEN
    DISPLAY ub.sert.cli-code ub.sert.cli-type ub.sert.sert-code ub.sert.first-date
          ub.sert.last-date ub.sert.sert-org ub.sert.blank-num ub.sert.PS
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel b-gds b-hist b-help ub.sert.sert-code
         ub.sert.first-date ub.sert.last-date ub.sert.sert-org
         ub.sert.blank-num ub.sert.PS
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
DISPLAY
v-c-name
WITH FRAME Dialog-Frame.
IF AVAILABLE ub.sert THEN
 DISPLAY
 ub.sert.cli-code
 ub.sert.cli-type
 ub.sert.sert-code
 ub.sert.first-date
 ub.sert.blank-num
 ub.sert.sert-org
 ub.sert.last-date
 ub.sert.PS
 WITH FRAME Dialog-Frame.
  ENABLE
  ub.sert.sert-code when i-mode = 'ДОБАВЛЕНИЕ':U
  ub.sert.first-date
  ub.sert.last-date
  ub.sert.blank-num
  ub.sert.sert-org
  ub.sert.PS
  Btn_OK
  Btn_Cancel
  b-gds
  b-help
  b-hist WHEN i-mode <> 'ДОБАВЛЕНИЕ':U
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
