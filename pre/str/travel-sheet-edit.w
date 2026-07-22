def input param parparentproc as Widget-handle no-undo .
def input param p-mode as char no-undo.
def output param p-result as logical no-undo.
def input-output param p-recid as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование Путевого листа. Документы->Путевые листы".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
procedure update-or-create-travel-sheet:
    def input-output param p-rec-id      as recid    no-undo.
    def input param p-ts-num      as char     no-undo.
    def input param p-ts-date     as date     no-undo.
    def input param p-pf          as decimal  no-undo.
    def input param p-fuel-code   as int      no-undo.
    def input param p-card-code   as char     no-undo.
    def input param p-stat        as logical  no-undo.
    def buffer buf_cd-doc   for ub.cd-doc.
    def buffer buf_goods    for ub.goods.
    def buffer buf_dis-card for ub.dis-card.
    if p-fuel-code = 0 then
        return error "Топлево не указано".
    if trim(p-card-code) = "" then
        return error "Дисконтная карта не указана".
    if p-pf = 0 then
        return error "Разрешенный налив должен быть больше 0".
    if trim(p-ts-num) = "" then
        return error "Номер ПЛ не должен быть пустым".
    for each buf_cd-doc no-lock
        where buf_cd-doc.CharKey_One = p-ts-num
        and buf_cd-doc.doc-type = 'путевой-лист':U
        and buf_cd-doc.obj-code = v-cntxt-obj-code
        and buf_cd-doc.obj-type = v-cntxt-obj-type
        and recid(buf_cd-doc) <> p-rec-id:
            return error "уже есть ПЛ с номером " + p-ts-num.
    end.
    find first buf_goods no-lock
        where buf_goods.gds-code = p-fuel-code
        no-error.
    if not avail buf_goods then
        return error "не удалось найти топливо по gds коду = " + string(p-fuel-code).
    find first buf_dis-card no-lock
        where buf_dis-card.d-card = p-card-code
        no-error.
    if not avail buf_dis-card then
        return error "не удалось найти дисконтную карту".
    if p-rec-id = 0 then do:
        create buf_cd-doc.
        assign
            buf_cd-doc.Key#_One = 0
        .
    end.
    else do:
        find first buf_cd-doc
            where recid(buf_cd-doc) = p-rec-id
            no-error.
        if not avail buf_cd-doc then
            return error "Не найдена запись с recid = " + string(p-rec-id).
        if buf_cd-doc.doc-type <> 'путевой-лист':U then
            return error "Запись с recid = " + string(p-rec-id) + " не является ПЛ".
        if buf_cd-doc.Key#_One = 1 then
            return error "Документ с recid = " + string(p-rec-id) + " переведен в статус Закрыт, изменение не возможно".
    end.
    assign
        buf_cd-doc.obj-type     = v-cntxt-obj-type      when p-rec-id = 0
        buf_cd-doc.obj-code     = v-cntxt-obj-code      when p-rec-id = 0
        buf_cd-doc.pos-type     = ""                    when p-rec-id = 0
        buf_cd-doc.doc-type     = 'путевой-лист':U       when p-rec-id = 0
        buf_cd-doc.doc-code     = string(next-value(s-file-num-2)) when p-rec-id = 0
        buf_cd-doc.datekey_one  = p-ts-date       when p-ts-date <> ?
        buf_cd-doc.CharKey_One  = p-ts-num        when p-ts-num <> ?
        buf_cd-doc.CharKey_Two  = p-card-code     when p-card-code <> ?
        buf_cd-doc.Key#_Two     = p-fuel-code     when p-fuel-code <> ?
        buf_cd-doc.DecKey_One   = p-pf            when p-pf <> ?
        buf_cd-doc.Key#_One     = integer(p-stat) when p-stat <> ?
    .
    p-rec-id = recid(buf_cd-doc).
end.
procedure delete-travel-sheet:
    def input param p-rid as recid no-undo.
    def buffer buf_cd-doc for       ub.cd-doc.
    def buffer buf_cd-doc-line for  ub.cd-doc-line.
    find first buf_cd-doc share-lock
        where recid(buf_cd-doc) = p-rid
        no-error.
    if not avail buf_cd-doc then
        return error "Запись для удаления не найдена, recid = " + string(p-rid).
    for each buf_cd-doc-line no-lock
        where buf_cd-doc-line.doc-type = 'путевой-лист':U
        and buf_cd-doc-line.doc-code = buf_cd-doc.doc-code
        and buf_cd-doc-line.obj-code = buf_cd-doc.obj-code
        and buf_cd-doc-line.obj-type = buf_cd-doc.obj-type
        :
            return error "Нельзя удалять путевые листы, для которых есть данные о заправках".
    end.
    delete buf_cd-doc.
end.
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
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON BUTTON-sel-car
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON BUTTON-sel-fuel
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE card-code-str AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер карты"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE fuel-code-str AS CHARACTER FORMAT "X(256)":U
     LABEL "Топливо"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE num AS CHARACTER FORMAT "X(20)"
     LABEL "Номер ПЛ"
     VIEW-AS FILL-IN
     SIZE 27 BY 1 NO-UNDO.
DEFINE VARIABLE permitted-filling AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Разрешенный налив"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE ts-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      cd-doc SCROLLING.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 2
     Btn_Cancel AT ROW 1 COL 12
     num AT ROW 2.91 COL 12 COLON-ALIGNED WIDGET-ID 2
     ts-date AT ROW 4.33 COL 12 COLON-ALIGNED WIDGET-ID 8
     permitted-filling AT ROW 4.33 COL 51 COLON-ALIGNED WIDGET-ID 10
     fuel-code-str AT ROW 7.67 COL 12 COLON-ALIGNED WIDGET-ID 16
     BUTTON-sel-fuel AT ROW 7.67 COL 30 WIDGET-ID 18
     card-code-str AT ROW 7.67 COL 49 COLON-ALIGNED WIDGET-ID 4
     BUTTON-sel-car AT ROW 7.67 COL 72 WIDGET-ID 6
     SPACE(2.19) SKIP(0.89)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       card-code-str:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fuel-code-str:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
    assign frame Dialog-Frame
        num
        ts-date
        fuel-code-str
        card-code-str
        permitted-filling
    .
    if ts-date = ? then do:
        message "Дата не указана" view-as alert-box.
        return no-apply.
    end.
    run update-or-create-travel-sheet(
          input-output p-recid
        , num
        , ts-date
        , permitted-filling
        , integer(fuel-code-str)
        , card-code-str
        , ?
    ) no-error.
    if error-status:ERROR then do:
        message return-value view-as alert-box.
        return no-apply.
    end.
    else do:
        p-result = true.
    end.
END.
ON CHOOSE OF BUTTON-sel-car IN FRAME Dialog-Frame
DO:
    def var rid-list as char no-undo.
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
    run ref/discards.w (
                 input parparentproc
                ,input "b-sel":U
                ,input 'все':U
                ,input v-cntxt-host-code-obj
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input '':U
                ,input ?
                ,output rid-list ) no-error.
    if num-entries(rid-list) <> 1 then return.
    find first ub.dis-card no-lock
        where recid(ub.dis-card) = integer(rid-list).
    card-code-str = string(ub.dis-card.d-card).
    disp card-code-str
        with frame Dialog-Frame.
END.
ON CHOOSE OF BUTTON-sel-fuel IN FRAME Dialog-Frame
DO:
  def var rid-list as char no-undo.
  run ref/petrlref.p ( parParentProc, "b-sel", output rid-list) no-error.
  if num-entries(rid-list) <> 1 then return.
  find first ub.goods no-lock
    where recid(ub.goods) = integer(rid-list).
  fuel-code-str = string(ub.goods.gds-code).
  disp fuel-code-str
    with frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of ts-date in frame Dialog-Frame
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
on delete-character of ts-date in frame Dialog-Frame
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
on ctrl-d of ts-date in frame Dialog-Frame
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
on ctrl-b of ts-date in frame Dialog-Frame
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
on ctrl-e of ts-date in frame Dialog-Frame
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
on ctrl-f of ts-date in frame Dialog-Frame
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
  if ts-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      ts-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date4 :HANDLE
      ts-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle4 as handle no-undo .
  assign
    v-label-handle4 = ts-date :side-label-handle in frame Dialog-Frame
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
    apply "ctrl-b":U to ts-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-2 in menu m-ed-date4 DO:
    apply "ctrl-d":U to ts-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-3 in menu m-ed-date4 DO:
    apply "ctrl-e":U to ts-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-4 in menu m-ed-date4 DO:
    apply "ctrl-f":U to ts-date in frame Dialog-Frame .
  END.
  run my-init no-error.
  if error-status:ERROR then do:
      message return-value view-as alert-box.
      p-result = false.
  end.
  else do:
      RUN enable_UI.
      WAIT-FOR GO OF FRAME Dialog-Frame FOCUS num.
  end.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH cd-doc SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY num ts-date permitted-filling fuel-code-str card-code-str
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel num ts-date permitted-filling fuel-code-str
         BUTTON-sel-fuel card-code-str BUTTON-sel-car
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE my-init :
frame Dialog-Frame:TITLE = (if p-mode = 'ДОБАВЛЕНИЕ':U then "Добавить" else "Изменить") + " ПЛ".
    if p-mode <> 'ДОБАВЛЕНИЕ':U and p-mode <> 'ИЗМЕНЕНИЕ':U then
        return error "Параметр p-mode может быть только одним из &add-def или &update".
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
        find first ub.cd-doc no-lock
            where recid(ub.cd-doc) = p-recid no-error.
        if not avail ub.cd-doc then
            return error "Запись с recid = " + string(p-recid) + " не найдена".
        if ub.cd-doc.doc-type <> 'путевой-лист':U then
            return error "Запись с recid = " + string(p-recid) + " ; № ПЛ = " + ub.cd-doc.CharKey_One + " не является путевым листом".
        if ub.cd-doc.Key#_One = 1 then
            return error "Нельзя редактировать закрытый документ".
        assign
            num                 = ub.cd-doc.CharKey_One
            ts-date             = ub.cd-doc.datekey_one
            permitted-filling   = ub.cd-doc.DecKey_One
            fuel-code-str       = string(ub.cd-doc.Key#_Two)
            card-code-str       = ub.cd-doc.CharKey_Two
        .
        disp
            num
            ts-date
            permitted-filling
            fuel-code-str
            card-code-str
            with frame Dialog-Frame.
    end.
    num:SENSITIVE = true.
END PROCEDURE.
