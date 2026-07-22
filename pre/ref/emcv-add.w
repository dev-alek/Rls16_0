DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-mode as character no-undo.
define input-output parameter p-rid as recid init ? no-undo.
define buffer b3-code for code .
define input parameter p-parent as character no-undo.
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Карточка Код ОКЕИ код ККТ".
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
procedure sel-date :
  define input  parameter p-date-handle as handle    no-undo .
  define input  parameter p-description as character no-undo .
  do
  on error undo, return error return-value
  :
    if (can-query (p-date-handle, "sensitive")
      and
      p-date-handle :sensitive = true
      )
    or (can-query (p-date-handle, "read-only")
      and
      p-date-handle :read-only = false
      )
    then do:
      if p-date-handle :handle <> focus :handle
      then do:
        apply "entry":u to p-date-handle .
      end.
      define variable v-ok            as logical no-undo .
      define variable v-curr-sv-date as date no-undo .
      assign
        v-curr-sv-date = date(p-date-handle :screen-value) no-error
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
          ,input p-description
          ,input ""
          ,input-output v-curr-sv-date
          ,output v-ok
          ).
        if v-ok = true
        then do:
          assign
            p-date-handle :screen-value = string(v-curr-sv-date) .
          .
        end.
      end.
    end.
  end.
end procedure.
define variable v-db-num like ub.db.db-num no-undo .
define variable v-name   as character no-undo .
define variable vDateIsoOld as character no-undo.
DEFINE BUTTON B-Help
   LABEL "Помо&щь"
   SIZE 10 BY 1
   BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
   LABEL "&Отмена"
   SIZE 10 BY 1
   BGCOLOR 8 .
DEFINE BUTTON B-save AUTO-GO
   LABEL "&Ввод"
   SIZE 10 BY 1
   BGCOLOR 8 .
DEFINE VARIABLE mDATA   AS DATE      FORMAT "99/99/9999":U INITIAL ?
   LABEL "Дата н.а."
   VIEW-AS FILL-IN
   SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE mZNACH  AS decimal   FORMAT ">>>>>>>9.99":U INITIAL 0
   LABEL "Значение"
   VIEW-AS FILL-IN
   SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE mDoc    AS CHARACTER FORMAT "X(256)":U
   LABEL "Номер документа"
   VIEW-AS FILL-IN
   SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE fStatus AS integer   init '0':U
   LABEL "Статус"
   VIEW-AS COMBO-BOX INNER-LINES 2
   LIST-ITEM-PAIRS "Активный",'0':U,
   "Деактивирован",'1':U
   DROP-DOWN-LIST
   SIZE 20 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
   B-save AT ROW 1 COL 1
   b-quit AT ROW 1 COL 11
   B-Help AT ROW 1 COL 36
   mDATA AT ROW 2.5 COL 18 COLON-ALIGNED WIDGET-ID 8
   mZNACH AT ROW 4 COL 18 COLON-ALIGNED WIDGET-ID 12
   fStatus AT ROW 5.5 COL 18 COLON-ALIGNED WIDGET-ID 14
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
   SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
   TITLE "Редактирование ЕМЦ"
   DEFAULT-BUTTON B-save CANCEL-BUTTON b-quit.
ASSIGN
   FRAME Dialog-Frame:SCROLLABLE = FALSE
   FRAME Dialog-Frame:HIDDEN     = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
   DO:
      APPLY "END-ERROR":U TO SELF.
   END.
ON CHOOSE OF B-save IN FRAME Dialog-Frame
   DO:
      run proc-save in this-procedure no-error.
      if error-status:error then return no-apply.
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   if p-mode <> 'ДОБАВЛЕНИЕ':U and
      p-mode <> 'ИЗМЕНЕНИЕ':U
      then
   do:
      message
         vss-workfile vss-revision vss-description skip
         "Неверное значение параметров вызова p-mode"  p-mode
         view-as alert-box ERROR.
      undo, return error.
   end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of mDATA in frame Dialog-Frame
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
on delete-character of mDATA in frame Dialog-Frame
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
on ctrl-d of mDATA in frame Dialog-Frame
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
on ctrl-b of mDATA in frame Dialog-Frame
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
on ctrl-e of mDATA in frame Dialog-Frame
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
on ctrl-f of mDATA in frame Dialog-Frame
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
  define MENU m-ed-date5
    MENU-ITEM m-ed-date5-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date5-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date5-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date5-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if mDATA :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      mDATA :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date5 :HANDLE
      mDATA :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle5 as handle no-undo .
  assign
    v-label-handle5 = mDATA :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle5)
  then do:
    if v-label-handle5 :tooltip = ""
    or v-label-handle5 :tooltip = ?
    then do:
      assign
        v-label-handle5 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date5-1 in menu m-ed-date5 DO:
    apply "ctrl-b":U to mDATA in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date5-2 in menu m-ed-date5 DO:
    apply "ctrl-d":U to mDATA in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date5-3 in menu m-ed-date5 DO:
    apply "ctrl-e":U to mDATA in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date5-4 in menu m-ed-date5 DO:
    apply "ctrl-f":U to mDATA in frame Dialog-Frame .
  END.
   if v-db-num <> 0 then
   do:
      message
         vss-workfile vss-revision vss-description skip
         "Неверное значение параметров вызова p-mode - нельзя изменять/добавлять записи <Тип ЕМЦ Код> в УБД"
         view-as alert-box ERROR.
      undo, return error.
   end.
   find first b3-code where
      b3-code.parent  = entry(1,p-parent,chr(4))
      and b3-code.code    = entry(2,p-parent,chr(4)) no-lock no-error.
   if available b3-code
      then
   do:
      FRAME Dialog-Frame:TITLE = "Редактирование ЕМЦ " + b3-code.codename.
      v-name = b3-code.CodeName .
   end.
   if p-mode = 'ИЗМЕНЕНИЕ':U then
   do:
      find first b3-code where
         recid(b3-code) = p-rid exclusive-lock no-wait no-error.
      if not available b3-code then
      do:
         message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись <Тип ЕМЦ - Код>"
            view-as alert-box error .
         undo, return error.
      end.
      assign
         mDATA   = date(b3-code.misc1)
         mZNACH  = dec(b3-code.CodeValue)
         mDoc    = b3-code.misc2
         Fstatus = b3-code.status_
         .
      vDateIsoOld = iso-date(mDATA).
   end.
   run enable_UI in this-procedure .
   if p-mode = 'ДОБАВЛЕНИЕ':U then
   do:
      ENABLE mDATA WITH FRAME Dialog-Frame.
      apply "entry" to mDATA in FRAME Dialog-Frame.
   end.
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
session:data-entry-return = no .
RUN disable_UI.
PROCEDURE disable_UI :
   HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
   DISPLAY mDATA mZNACH fStatus
      WITH FRAME Dialog-Frame.
   ENABLE B-save b-quit B-Help mDATA mZNACH fStatus
      WITH FRAME Dialog-Frame.
   VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
   define buffer b3-code for code.
   define buffer b2-code for code.
   assign frame Dialog-Frame
      mDATA
      mZNACH
      fStatus
      .
   define variable vDateIsoNew   as character no-undo.
   define variable vDateIsoToday as character no-undo.
   vDateIsoNew = iso-date(mDATA).
   do on error undo, return error
      on stop undo, return error:
      if mdata eq ?
      then do:
         message "Дата не сожет быть пустой"
         view-as alert-box.
         return error.
      end.
      find first b3-code where
         b3-code.parent = p-parent
         and b3-code.code   = vDateIsoNew
         and if p-rid eq ? then yes else recid(b3-code) ne p-rid
         no-lock no-error.
      if avail b3-code then
      do:
         message
            "Уже есть такая запись Тип ЕМЦ Дата :" string(mDATA,"99/99/9999")
            view-as alert-box error .
         return error.
      end.
      if fStatus <> 0 then
      do:
         find first b2-code where b2-code.parent = p-parent and
            b2-code.status_ = 0 and recid(b2-code) <> p-rid and b2-code.codevalue <> "0" no-error .
         if not available (b2-code) then
         do:
            message "Для типа ЕМЦ - " + string(v-name) + " отсутствуют другие значения." skip
               "При деактивации значения прослеживаемость данного типа ЕМЦ для всех товаров будет отключена"
               view-as alert-box question buttons yes-no update choice as logical .
            case choice:
               when yes then
                  do:
                     for each ub.gds-grp-obj-attr exclusive-lock where ub.gds-grp-obj-attr.attr-code = 'emrc-type':U
                        and ub.gds-grp-obj-attr.attr-value = string(entry(2,p-parent,chr(4))):
                        delete ub.gds-grp-obj-attr .
                     end.
                     for each ub.goods-attr exclusive-lock where ub.goods-attr.attr-code = 'emrc-type':U and
                     ub.goods-attr.attr-value = string(entry(2,p-parent,chr(4))):
                        delete ub.goods-attr .
                     end.
                     fStatus = 1 .
                  end.
                  otherwise do:
                     fStatus = 0 .
                  end.
            end case.
         end.
      end.
      find first b3-code where
         b3-code.parent = p-parent
         and b3-code.code   = vDateIsoOld
         exclusive-lock no-error.
      if not avail b3-code then
      do:
         create b3-code.
      end.
      assign
         b3-code.parent    = p-parent
         b3-code.code      = vDateIsoNew
         b3-code.misc1     = string(mDATA,"99/99/9999")
         b3-code.codevalue = string(mZNACH)
         b3-code.misc2     = mDoc
         b3-code.status_   = fStatus
         b3-code.nwsgbd    = yes
         .
      p-rid = recid(b3-code).
      if mDATA > today
         then
      do:
         find b3-code where
            b3-code.parent = p-parent
            and b3-code.code   < vDateIsoNew
            and b3-code.status_  = 0
            no-lock no-error.
         if not avail b3-code
            then
         do:
            if not AMBIGUOUS b3-code
            then do:
               vDateIsoToday = iso-date(today).
               find first b3-code where
                  b3-code.parent = p-parent
                  and b3-code.code   = vDateIsotoday
                  exclusive-lock no-error.
               if not avail b3-code
                  then
               do:
                  create b3-code.
                  assign
                     b3-code.parent    = p-parent
                     b3-code.code      = vDateIsoToday
                     b3-code.misc1     = string(today,"99/99/9999")
                     b3-code.codevalue = "0"
                     b3-code.status_   = fStatus
                     b3-code.nwsgbd    = yes
                  .
               end.
               b3-code.status_   = fStatus.
            end.
         end.
         else do:
            if b3-code.codevalue = "0"
            then do:
               find current b3-code exclusive-lock.
               b3-code.status_   = fStatus.
            end.
         end.
      end.
   end.
END PROCEDURE.
