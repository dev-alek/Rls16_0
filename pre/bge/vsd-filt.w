DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision$":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author$":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date$":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile$":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive$":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "".
DEFINE VARIABLE v-bge-dper-host-code    AS INTEGER      NO-UNDO.
DEFINE VARIABLE v-bge-dper-store-type   AS CHARACTER    NO-UNDO.
DEFINE VARIABLE v-bge-dper-store-code   AS INTEGER      NO-UNDO.
DEFINE TEMP-TABLE t-obj-list NO-UNDO
    FIELD obj-type  AS CHARACTER
    FIELD obj-code  AS INTEGER
    FIELD host-code AS INTEGER
    INDEX pi IS UNIQUE PRIMARY obj-type  obj-code
    INDEX firm                 host-code.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table tt-gds-list no-undo like ub.goods
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
define    temp-table tt-gds-list-hist no-undo
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
DEFINE TEMP-TABLE tt-vsd-filt NO-UNDO
FIELD date-end AS DATE
FIELD date-start AS DATE
FIELD fTime  AS INTEGER
FIELD FalExting AS LOGICAL
FIELD FalVerif  AS LOGICAL
FIELD Rep       AS LOGICAL
FIELD ReqVerif  AS LOGICAL
FIELD ToExtin   AS LOGICAL
FIELD Sent      AS LOGICAL
FIELD doc-code  AS CHARACTER
.
DEFINE DATASET ds-vsd-set
FOR tt-vsd-filt, t-obj-list,  tt-gds-list .
DEFINE TEMP-TABLE ttvsd NO-UNDO LIKE ub.vsd
        FIELD dateTTH     AS DATE
        FIELD NomTTH      AS CHAR
        FIELD NomTTHpost  AS CHAR
        FIELD NomAZS      AS CHAR
        FIELD Post        AS CHAR
        FIELD artic       AS CHAR
        FIELD gdsname     AS CHAR
        FIELD prod-code   AS CHAR
        FIELD COLobj      AS DEC
        FIELD unit-cli    AS CHAR
        FIELD unit-base   AS CHAR
        FIELD statusvsd   AS CHAR
        FIELD ojd         AS DEC
        FIELD gdsmercguid AS CHAR
        FIELD vsdtypelbl  AS CHAR
        FIELD vsdsubs     AS CLASS Progress.Lang.Object.
DEFINE VARIABLE v-host-name         AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER parparentproc        AS HANDLE               NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER DATASET FOR ds-vsd-set.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE BUTTON b-obj DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 8 BY 1.08.
DEFINE BUTTON b-spisok
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Товары"
     SIZE 8 BY 1.92 TOOLTIP "Выбор товаров".
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отменить"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON btn_cler
     LABEL "Сброс"
     SIZE 12 BY 1.
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Применить"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE v-gds-list AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL LARGE
     SIZE 58 BY 3.67 NO-UNDO.
DEFINE VARIABLE v-obj-list AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL LARGE
     SIZE 58 BY 3.79 NO-UNDO.
DEFINE VARIABLE v-date-end AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-date-start AS DATE FORMAT "99/99/9999":U
     LABEL "C"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE vdoc-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Ном. Накл."
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE vTime AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Время гашения"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE SelObj AS CHARACTER INITIAL "Глобально"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Глобально", "Глобально",
"По фирме", "По фирме",
"Выборочно", "Выборочно"
     SIZE 17 BY 2.21 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 92 BY 4.5.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 92 BY 4.5.
DEFINE VARIABLE vFalExting AS LOGICAL INITIAL yes
     LABEL "Ошибка гашения"
     VIEW-AS TOGGLE-BOX
     SIZE 21 BY 1 NO-UNDO.
DEFINE VARIABLE vFalRegis AS LOGICAL INITIAL no
     LABEL "Ошибка регистрации"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY 1 NO-UNDO.
DEFINE VARIABLE vFalVerif AS LOGICAL INITIAL yes
     LABEL "Ошибка проверки ВСД"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY 1 NO-UNDO.
DEFINE VARIABLE vRegis AS LOGICAL INITIAL no
     LABEL "Зарегистрирован"
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY 1 NO-UNDO.
DEFINE VARIABLE vRep AS LOGICAL INITIAL yes
     LABEL "Погашен"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE vReqVerif AS LOGICAL INITIAL yes
     LABEL "Требует проверки"
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY 1 NO-UNDO.
DEFINE VARIABLE vSent AS LOGICAL INITIAL yes
     LABEL "Отправлен"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.
DEFINE VARIABLE vToExtin AS LOGICAL INITIAL yes
     LABEL "К гашению"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE vToRegi AS LOGICAL INITIAL no
     LABEL "К регистрации"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.5 COL 7
     Btn_Cancel AT ROW 1.5 COL 22.5
     btn_cler AT ROW 1.5 COL 35 WIDGET-ID 44
     vTime AT ROW 3.88 COL 16 COLON-ALIGNED WIDGET-ID 22
     v-date-start AT ROW 3.88 COL 34 COLON-ALIGNED WIDGET-ID 36
     v-date-end AT ROW 3.88 COL 53 COLON-ALIGNED WIDGET-ID 38
     vdoc-code AT ROW 3.88 COL 81 COLON-ALIGNED WIDGET-ID 40
     vReqVerif AT ROW 5.5 COL 6 WIDGET-ID 2
     vToExtin AT ROW 5.5 COL 38 WIDGET-ID 6
     vRep AT ROW 5.5 COL 62 WIDGET-ID 10
     vFalVerif AT ROW 6.71 COL 6 WIDGET-ID 4
     vFalExting AT ROW 6.71 COL 38 WIDGET-ID 8
     vSent AT ROW 6.71 COL 62 WIDGET-ID 42
     v-obj-list AT ROW 9.08 COL 34 NO-LABEL
     SelObj AT ROW 10.04 COL 6 NO-LABEL
     b-obj AT ROW 11.25 COL 23
     v-gds-list AT ROW 13.88 COL 34 NO-LABEL
     b-spisok AT ROW 15.71 COL 19 WIDGET-ID 26
     vToRegi AT ROW 18.13 COL 7 WIDGET-ID 12
     vFalRegis AT ROW 18.13 COL 27 WIDGET-ID 14
     vRegis AT ROW 18.13 COL 54 WIDGET-ID 16
     "Выбор товаров" VIEW-AS TEXT
          SIZE 17 BY 1.67 TOOLTIP "Выбор товаров" AT ROW 13.88 COL 14 WIDGET-ID 30
     RECT-1 AT ROW 8.88 COL 3 WIDGET-ID 32
     RECT-2 AT ROW 13.38 COL 3 WIDGET-ID 34
     SPACE(3.59) SKIP(2.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Фильтр ВСД"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       vFalRegis:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       vRegis:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       vToRegi:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-obj IN FRAME Dialog-Frame
DO:
  define variable v-user-select as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
  if v-user-select = true
  then do:
    for each t-obj-list
    on error undo, return no-apply
    :
      delete t-obj-list .
    end.
    assign
      v-obj-list    = "":U
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return no-apply
    :
      create t-obj-list .
      assign
        t-obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
        t-obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
        v-obj-list = v-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U NO-ERROR.
      .
    end.
    display
      v-obj-list
      with frame Dialog-Frame
    .
  end.
END.
ON CHOOSE OF b-spisok IN FRAME Dialog-Frame
DO:
    RUN sel-goods IN THIS-PROCEDURE .
  END.
ON CHOOSE OF btn_cler IN FRAME Dialog-Frame
DO:
   DEFINE VARIABLE v-object-available AS LOGICAL   NO-UNDO .
   ASSIGN
        v-date-end   = TODAY
        v-date-start = TODAY
        vFalExting   = YES
        vFalVerif    = YES
        vRep         = YES
        vReqVerif    = YES
        vToExtin     = YES
        vTime        = 0
        tt-vsd-filt.doc-code = ?
        SelObj       = "Глобально"
        v-obj-list   = ""
        .
      FOR EACH t-obj-list:
         delete t-obj-list.
      end.
      FOR EACH t-obj-list:
         delete tt-gds-list.
      end.
      FOR EACH db NO-LOCK
        ON ERROR UNDO, RETURN NO-APPLY
        :
        FOR EACH clients NO-LOCK
            WHERE clients.db-num = db.db-num
            ON ERROR UNDO, RETURN NO-APPLY
            :
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  clients.obj-type
  ,input  clients.obj-code
  ,output v-object-available
  ) no-error .
            IF ERROR-STATUS :ERROR
                THEN
            DO:
                MESSAGE
                    vss-workfile vss-revision vss-description SKIP
                    "Ошибка при вызове процедуры gbl/usobjava.i" SKIP
                    ERROR-STATUS :GET-MESSAGE(1) SKIP
                    RETURN-VALUE SKIP
                    VIEW-AS ALERT-BOX ERROR .
                UNDO, RETURN NO-APPLY .
            END.
            IF v-object-available = TRUE
                THEN
            DO:
                CREATE t-obj-list .
                ASSIGN
                    t-obj-list.obj-type = clients.obj-type
                    t-obj-list.obj-code = clients.obj-code
                    v-obj-list = v-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U
                    no-error.
            END.
        END.
    END.
     DISPLAY vTime v-date-start v-date-end vReqVerif vFalVerif vToExtin vFalExting
          vRep vSent SelObj v-obj-list
      WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
    FOR EACH tt-gds-list:
        DELETE tt-gds-list.
    END.
    FOR EACH gds-list:
        CREATE tt-gds-list.
        BUFFER-COPY gds-list TO tt-gds-list.
    END.
    FIND FIRST tt-vsd-filt.
    ASSIGN
        v-date-end
        v-date-start
        vtime
        vFalExting
        vFalVerif
        vRep
        vReqVerif
        vToExtin
        vdoc-code
        vSent.
    Assign
        tt-vsd-filt.date-end    = v-date-end
        tt-vsd-filt.date-start  = v-date-start
        tt-vsd-filt.fTime       = vtime
        tt-vsd-filt.FalExting   = vFalExting
        tt-vsd-filt.FalVerif    = vFalVerif
        tt-vsd-filt.Rep         = vRep
        tt-vsd-filt.ReqVerif    = vReqVerif
        tt-vsd-filt.ToExtin     = vToExtin
        tt-vsd-filt.Sent        = vSent
        tt-vsd-filt.doc-code    = vdoc-code
    .
END.
ON VALUE-CHANGED OF SelObj IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER buf_db      FOR ub.db  .
  DEFINE BUFFER buf_clients FOR ub.clients .
  DEFINE VARIABLE v-object-available AS LOGICAL   NO-UNDO .
  ASSIGN
    SelObj
  .
  FOR EACH t-obj-list
  ON ERROR UNDO, RETURN NO-APPLY
  :
    DELETE t-obj-list .
  END.
  ASSIGN
    v-obj-list = "":U
  .
  CASE SelObj :
    WHEN "Выборочно" THEN DO:
      ENABLE b-obj WITH FRAME Dialog-Frame .
    END.
    WHEN "По фирме" THEN DO:
      DISABLE b-obj WITH FRAME Dialog-Frame .
      FOR EACH buf_clients NO-LOCK
        WHERE buf_clients.host-code = v-cntxt-host-code-obj
      ON ERROR UNDO, RETURN NO-APPLY
      :
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-object-available
  ) no-error .
        IF ERROR-STATUS :ERROR
        THEN DO:
          MESSAGE
            vss-workfile vss-revision vss-description SKIP
            "Ошибка при вызове процедуры gbl/usobjava.i" SKIP
            ERROR-STATUS :GET-MESSAGE(1) SKIP
            RETURN-VALUE SKIP
            VIEW-AS ALERT-BOX ERROR .
          UNDO, RETURN NO-APPLY .
        END.
        IF v-object-available = TRUE
        THEN DO:
          CREATE t-obj-list .
          ASSIGN
            t-obj-list.obj-type = buf_clients.obj-type
            t-obj-list.obj-code = buf_clients.obj-code
            v-obj-list = v-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U
          NO-ERROR .
        END.
      END.
    END.
    WHEN "Глобально" THEN DO:
      DISABLE b-obj WITH FRAME Dialog-Frame .
      FOR EACH buf_db NO-LOCK
      ON ERROR UNDO, RETURN NO-APPLY
      :
        FOR EACH buf_clients NO-LOCK
          WHERE buf_clients.db-num = buf_db.db-num
        ON ERROR UNDO, RETURN NO-APPLY
        :
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-object-available
  ) no-error .
          IF ERROR-STATUS :ERROR
          THEN DO:
            MESSAGE
              vss-workfile vss-revision vss-description SKIP
              "Ошибка при вызове процедуры gbl/usobjava.i" SKIP
              ERROR-STATUS :GET-MESSAGE(1) SKIP
              RETURN-VALUE SKIP
              VIEW-AS ALERT-BOX ERROR .
            UNDO, RETURN NO-APPLY .
          END.
          IF v-object-available = TRUE
          THEN DO:
            CREATE t-obj-list .
            ASSIGN
              t-obj-list.obj-type = buf_clients.obj-type
              t-obj-list.obj-code = buf_clients.obj-code
              v-obj-list = v-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U
            .
          END.
        END.
      END.
    END.
  END CASE.
  DISPLAY
    v-obj-list
    WITH FRAME Dialog-Frame
  .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT EQ ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    FOR EACH tt-gds-list:
        CREATE gds-list.
        BUFFER-COPY tt-gds-list TO gds-list.
        v-gds-list = v-gds-list + "," + string(gds-list.gds-code) NO-ERROR.
    END.
    v-gds-list = TRIM (SUBSTRING(v-gds-list,2))  .
    FOR EACH t-obj-list:
        v-obj-list = v-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U.
    END.
    IF TRIM (v-obj-list) NE ""
    THEN
        SelObj = "выборочно".
    IF TRIM (v-obj-list) NE ""
    THEN
        ENABLE b-obj WITH FRAME Dialog-Frame .
    ELSE
        DISABLE b-obj WITH FRAME Dialog-Frame .
    FIND FIRST tt-vsd-filt NO-ERROR .
    IF AVAIL tt-vsd-filt
    THEN ASSIGN
        v-date-end   = tt-vsd-filt.date-end
        v-date-start = tt-vsd-filt.date-start
        vtime        = tt-vsd-filt.fTime
        vFalExting   = tt-vsd-filt.FalExting
        vFalVerif    = tt-vsd-filt.FalVerif
        vRep         = tt-vsd-filt.Rep
        vReqVerif    = tt-vsd-filt.ReqVerif
        vToExtin     = tt-vsd-filt.ToExtin
        vdoc-code    = tt-vsd-filt.doc-code
        vSent        = tt-vsd-filt.Sent
        .
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
    .
  RUN enable_UI.
  IF TRIM (v-obj-list) EQ  ""
  THEN
    APPLY "value-changed" TO SelObj IN FRAME Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY vTime v-date-start v-date-end vdoc-code vReqVerif vToExtin vRep
          vFalVerif vFalExting vSent v-obj-list SelObj v-gds-list
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-2 Btn_OK Btn_Cancel btn_cler vTime v-date-start v-date-end
         vdoc-code vReqVerif vToExtin vRep vFalVerif vFalExting vSent SelObj
         b-obj b-spisok
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE sel-goods :
DEFINE VARIABLE v-list AS CHARACTER NO-UNDO.
    v-list = "" .
    RUN str/gds-list.w (
        INPUT parparentproc
      , INPUT v-cntxt-host-code-obj
      , INPUT v-cntxt-obj-type
      , INPUT v-cntxt-obj-code) NO-ERROR.
    FOR EACH gds-list NO-LOCK:
        v-list = v-list + "," + string(gds-list.gds-code) NO-ERROR.
    END.
    v-gds-list = TRIM (SUBSTRING(v-list,2))  .
    DISPLAY v-gds-list WITH FRAME Dialog-Frame .
END PROCEDURE.
