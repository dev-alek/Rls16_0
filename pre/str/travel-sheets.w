def input param parParentProc as Widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список Путевых листов. Документы->Путевые листы".
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
procedure create-travel-sheet-line:
    def input param p-travel-sheet-recid as recid no-undo.
    def input param p-vol as decimal no-undo.
    def input param p-doc-code as char no-undo.
    def input param p-rfn as char no-undo.
    def input param p-stat as logical no-undo.
    def output param p-rec-id as recid no-undo.
    def buffer buf_chk-doc for ub.chk-doc.
    def buffer buf_cd-doc for ub.cd-doc.
    def buffer buf_cd-doc-line for ub.cd-doc-line.
    def var line-num as int no-undo init 0.
    def var head-fact as dec no-undo init 0.
    def var head-blocked as dec no-undo init 0.
    def var for-del as logical no-undo init false.
    p-rec-id = 0.
    if p-vol = 0 then
        return error "Объем не может быть равным 0".
    if p-doc-code = "" and p-stat then
        return error "Чек не указан".
    find first buf_cd-doc
        where recid(buf_cd-doc) = p-travel-sheet-recid
        no-error.
    if not avail buf_cd-doc then
        return error "Не удалось найти cd-doc по recid = " + string(p-travel-sheet-recid).
    if buf_cd-doc.Key#_One = 1 then
        return error "Путевой лист закрыт".
    if p-rfn = ? then p-rfn = "".
    for each buf_cd-doc-line
        where buf_cd-doc-line.obj-code = buf_cd-doc.obj-code
        and buf_cd-doc-line.obj-type = buf_cd-doc.obj-type
        and buf_cd-doc-line.doc-code = buf_cd-doc.doc-code
        and buf_cd-doc-line.doc-type = 'путевой-лист':U:
            for-del = false.
            if p-rfn <> "" and buf_cd-doc-line.CharKey_Two = p-rfn and buf_cd-doc-line.Key#_One = 0 then
                for-del = true.
            else if buf_cd-doc-line.Key#_One = 0 then
                for-del = true.
            if for-del then
                delete buf_cd-doc-line.
            else do:
                if buf_cd-doc-line.DecKey_One = 0 then
                    head-blocked = head-blocked + buf_cd-doc-line.DecKey_One.
                else
                    head-fact = head-fact + buf_cd-doc-line.DecKey_One.
                line-num = buf_cd-doc-line.line-num.
            end.
    end.
    line-num = line-num + 1.
    if p-stat then
        head-fact = head-fact + p-vol.
    else
        head-blocked = head-blocked + p-vol.
    buf_cd-doc.DecKey_Two = head-fact.
    buf_cd-doc.DecKey_Three = head-blocked.
    if head-fact >= buf_cd-doc.DecKey_One then
        buf_cd-doc.Key#_One = 1.
    create buf_cd-doc-line.
    assign
        buf_cd-doc-line.doc-type = 'путевой-лист':U
        buf_cd-doc-line.doc-code = buf_cd-doc.doc-code
        buf_cd-doc-line.obj-code = buf_cd-doc.obj-code
        buf_cd-doc-line.obj-type = buf_cd-doc.obj-type
        buf_cd-doc-line.pos-type = ""
        buf_cd-doc-line.line-num = line-num
        buf_cd-doc-line.DecKey_One = p-vol.
        buf_cd-doc-line.CharKey_Two = p-rfn.
        buf_cd-doc-line.CharKey_Three = p-doc-code.
        buf_cd-doc-line.Key#_One = integer(p-stat).
    .
    p-rec-id = recid(buf_cd-doc-line).
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION get-car-mark RETURNS CHARACTER
  ( )  FORWARD.
FUNCTION get-car-num RETURNS CHARACTER
  ( )  FORWARD.
FUNCTION get-refill-str-stat RETURNS CHARACTER
  (  )  FORWARD.
FUNCTION get-ts-str-stat RETURNS CHARACTER
  ( )  FORWARD.
DEFINE BUTTON Btn_add
     LABEL "Добавить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_edit
     LABEL "Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_exit AUTO-GO
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_fact
     LABEL "Ввести факт"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_remove
     LABEL "Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE QUERY BROWSE-refills FOR
      cd-doc-line SCROLLING.
DEFINE QUERY BROWSE-tsheets FOR
      cd-doc SCROLLING.
DEFINE BROWSE BROWSE-refills
  QUERY BROWSE-refills NO-LOCK DISPLAY
      cd-doc-line.CharKey_Two COLUMN-LABEL "Номер RFN" FORMAT "X(12)":U
            WIDTH 30
      get-refill-str-stat() COLUMN-LABEL "Статус" WIDTH 30
      cd-doc-line.CharKey_Three COLUMN-LABEL "Номер чека" FORMAT "X(12)":U
            WIDTH 30
      cd-doc-line.DecKey_One COLUMN-LABEL "Объем" FORMAT "->>,>>9.99":U
            WIDTH 30
    WITH NO-ROW-MARKERS SEPARATORS SIZE 122 BY 11.43
         TITLE "Заправки" FIT-LAST-COLUMN.
DEFINE BROWSE BROWSE-tsheets
  QUERY BROWSE-tsheets NO-LOCK DISPLAY
      cd-doc.CharKey_One COLUMN-LABEL "Номер ПЛ" FORMAT "X(20)":U
      get-ts-str-stat() COLUMN-LABEL "Статус" WIDTH 10
      cd-doc.datekey_one COLUMN-LABEL "Дата" FORMAT "99/99/9999":U
      cd-doc.CharKey_Two COLUMN-LABEL "Код!машины" FORMAT "X(12)":U
      get-car-mark() COLUMN-LABEL "Марка!машины" WIDTH 11
      get-car-num() COLUMN-LABEL "Номер!машины" WIDTH 11
      cd-doc.DecKey_One COLUMN-LABEL "Разрешенный!объем" FORMAT "->>,>>9.99":U
            WIDTH 13
      cd-doc.DecKey_Two COLUMN-LABEL "Фактический!объем" FORMAT "->>,>>9.99":U
            WIDTH 13
      cd-doc.DecKey_Three COLUMN-LABEL "Заблокированный! к наливу объем" FORMAT "->>,>>9.99":U
            WIDTH 12.6
    WITH NO-ROW-MARKERS SEPARATORS SIZE 122 BY 11.19
         TITLE "Путевые листы" FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     Btn_exit AT ROW 1 COL 2
     BROWSE-tsheets AT ROW 2.19 COL 2 WIDGET-ID 200
     BROWSE-refills AT ROW 13.38 COL 2 WIDGET-ID 300
     Btn_add AT ROW 1 COL 13 WIDGET-ID 2
     Btn_edit AT ROW 1 COL 23 WIDGET-ID 4
     Btn_remove AT ROW 1 COL 33 WIDGET-ID 6
     Btn_fact AT ROW 1 COL 43 WIDGET-ID 8
     SPACE(69.79) SKIP(23.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Путевые листы"
         DEFAULT-BUTTON Btn_exit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF BROWSE-tsheets IN FRAME Dialog-Frame
DO:
  run open-cd-doc-line.
END.
ON CHOOSE OF Btn_add IN FRAME Dialog-Frame
DO:
    def var res as logical no-undo.
    def var rid as recid no-undo init 0.
    run str/travel-sheet-edit.w(parParentProc, 'ДОБАВЛЕНИЕ':U, output res, input-output rid).
    if res then
        run open-cd-doc.
END.
ON CHOOSE OF Btn_edit IN FRAME Dialog-Frame
DO:
      def var res as logical no-undo.
      def var rid as recid no-undo.
      if not avail ub.cd-doc then do:
          message "Не выбран путевой лист" view-as alert-box.
          return.
      end.
      rid = recid(ub.cd-doc).
      run str/travel-sheet-edit.w(parParentProc, 'ИЗМЕНЕНИЕ':U, output res, input-output rid).
      if res then
           run open-cd-doc.
END.
ON CHOOSE OF Btn_fact IN FRAME Dialog-Frame
DO:
    def var rid as recid no-undo.
    def var ret-stat as logical no-undo.
    if not avail ub.cd-doc then do:
        message "Не выбран путевой лист" view-as alert-box.
        return.
    end.
    if ub.cd-doc.Key#_One = 1 then do:
        message "Путевой лист закрыт" view-as alert-box.
        return.
    end.
    rid = recid(ub.cd-doc).
    run str/travel-sheet-line-add.w(parparentproc, rid, output ret-stat).
    if ret-stat then do:
        run open-cd-doc-line.
        browse-tsheets:REFRESH().
    end.
END.
ON CHOOSE OF Btn_remove IN FRAME Dialog-Frame
DO:
  def var ret-stat as logical no-undo.
  if not avail ub.cd-doc then do:
      message "Не выбран путевой лист" view-as alert-box.
      return.
  end.
  message "Удалить выбранный путевой лист?" view-as alert-box question buttons yes-no update confirm as logical.
  if not confirm then return.
  run delete-travel-sheet(recid(ub.cd-doc)) no-error.
  if error-status:ERROR then
    message return-value view-as alert-box.
  else
    run open-cd-doc.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  run my-init.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE Btn_exit BROWSE-tsheets BROWSE-refills Btn_add Btn_edit Btn_remove
         Btn_fact
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE my-init :
run open-cd-doc.
apply "VALUE-CHANGED" to BROWSE-tsheets in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE open-cd-doc :
open query BROWSE-tsheets
        for each ub.cd-doc
            where ub.cd-doc.doc-type = 'путевой-лист':U
            and ub.cd-doc.obj-type = v-cntxt-obj-type
            and ub.cd-doc.obj-code = v-cntxt-obj-code
            BY cd-doc.DecKey_One DESCENDING.
END PROCEDURE.
PROCEDURE open-cd-doc-line :
open query BROWSE-refills
        for each ub.cd-doc-line
            where ub.cd-doc-line.doc-type = 'путевой-лист':U
            and ub.cd-doc-line.doc-code = ub.cd-doc.doc-code
            and ub.cd-doc-line.obj-type = v-cntxt-obj-type
            and ub.cd-doc-line.obj-code = v-cntxt-obj-code.
END PROCEDURE.
FUNCTION get-car-mark RETURNS CHARACTER
  ( ) :
    find first ub.dis-card-property no-lock
        where ub.dis-card-property.d-card = ub.cd-doc.CharKey_Two
        and ub.dis-card-property.dtm-code = 33
        and ub.dis-card-property.node-code = 2
        no-error.
        return
            (if avail ub.dis-card-property then ub.dis-card-property.property-value-character else "").
END FUNCTION.
FUNCTION get-car-num RETURNS CHARACTER
  ( ) :
    find first ub.dis-card-property no-lock
        where ub.dis-card-property.d-card = ub.cd-doc.CharKey_Two
        and ub.dis-card-property.dtm-code = 33
        and ub.dis-card-property.node-code = 1
        no-error.
        return
            (if avail ub.dis-card-property then ub.dis-card-property.property-value-character else "").
END FUNCTION.
FUNCTION get-refill-str-stat RETURNS CHARACTER
  (  ) :
    return ( if ub.cd-doc-line.Key#_One > 0 then "Факт" else "Зарезерв" ).
END FUNCTION.
FUNCTION get-ts-str-stat RETURNS CHARACTER
  ( ) :
    return ( if ub.cd-doc.Key#_One > 0 then "Факт" else "Новый" ).
END FUNCTION.
