def input param         parparentproc   as Widget-handle no-undo .
def input param         p-cd-doc-recid    as recid    no-undo.
def output param        p-ret-stat        as logical  no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Добавление в Путевой лист факта заправки. Документы->Путевые листы".
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
p-ret-stat = false.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON BUTTON-sel-chk
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE chk AS CHARACTER FORMAT "X(256)":U
     LABEL "Чек"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE rfn AS CHARACTER FORMAT "X(256)":U
     LABEL "RFN"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE volume AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Объем"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 2
     Btn_Cancel AT ROW 1 COL 12
     volume AT ROW 2.91 COL 9 COLON-ALIGNED WIDGET-ID 2
     rfn AT ROW 4.33 COL 9 COLON-ALIGNED WIDGET-ID 8
     chk AT ROW 5.76 COL 9 COLON-ALIGNED WIDGET-ID 4
     BUTTON-sel-chk AT ROW 5.76 COL 32 WIDGET-ID 6
     SPACE(3.19) SKIP(0.94)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ввод заправки"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       chk:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
    def var rid as recid no-undo.
    assign frame Dialog-Frame
        volume
        rfn
        chk
    .
    run create-travel-sheet-line(
              p-cd-doc-recid
            , volume
            , chk
            , rfn
            , true
            , output rid
    ) no-error.
    if error-status:ERROR then do:
        message return-value view-as alert-box.
        return no-apply.
    end.
    else
        p-ret-stat = true.
END.
ON CHOOSE OF BUTTON-sel-chk IN FRAME Dialog-Frame
DO:
    def var rid-list as char no-undo.
    run str/chk-docs.w (
                 input parparentproc
                ,input "b-sel":U
                ,input 'объект':U
                ,input ?
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input ?
                ,input "":U
                ,input 0
                ,input ?
                ,input ?
                ,input 0
                ,output rid-list
                ).
    if num-entries(rid-list) = 0 then return.
    find first ub.chk-doc no-lock
        where recid(ub.chk-doc) = integer(rid-list).
    chk = ub.chk-doc.doc-code.
    disp chk with frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run my-init no-error.
  if error-status:ERROR then do:
      message return-value view-as alert-box.
      return.
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame FOCUS volume.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY volume rfn chk
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel volume rfn chk BUTTON-sel-chk
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE my-init :
find first ub.cd-doc no-lock
        where recid(ub.cd-doc) = p-cd-doc-recid
        no-error.
    if not avail ub.cd-doc then return error "Не удалось найти cd-doc с recid = " + string(p-cd-doc-recid).
END PROCEDURE.
