define input parameter parparentproc as widget-handle no-undo.
define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
define input-output parameter p-attr-value as character no-undo.
define output parameter p-ok as logical no-undo.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Задание атрибута дополнительного документа".
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
DEFINE BUTTON btn-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY 1.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 8 BY .96
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Сохранить"
     SIZE 10 BY .96
     BGCOLOR 8 .
DEFINE VARIABLE cb-doc-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип документа"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 23 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-cli AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 12 BY .96 NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1 COL 1
     Btn_OK AT ROW 1 COL 11
     cb-doc-type AT ROW 2.17 COL 1.57 WIDGET-ID 4
     FILL-IN-cli AT ROW 3.39 COL 23 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     btn-cli AT ROW 3.39 COL 37 WIDGET-ID 10
     "Контрагент:" VIEW-AS TEXT
          SIZE 13 BY .96 AT ROW 3.39 COL 2 WIDGET-ID 6
     SPACE(27.79) SKIP(0.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Создание дополнительного документа"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       FILL-IN-cli:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
        APPLY "END-ERROR":U TO SELF.
    END.
ON CHOOSE OF btn-cli IN FRAME Dialog-Frame
DO:
        define variable v-ok       as logical   no-undo.
        define variable v-cli-type as character no-undo.
        define variable v-cli-code as integer   no-undo.
        run ref/selcli.p(
            parparentproc,
            ?,
            'орг':U,
            false,
            output v-ok,
            output v-cli-type,
            output v-cli-code
        ).
        if v-ok then
            FILL-IN-cli:screen-value = v-cli-type + " " + string(v-cli-code).
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
                RUN proc-save IN THIS-PROCEDURE NO-ERROR.
                IF ERROR-STATUS:ERROR THEN
                DO:
                    RETURN NO-APPLY.
                END.
            END.
        IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
            THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
        MAIN-BLOCK:
        DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
            ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
            RUN enable_UI.
            run proc-load.
            WAIT-FOR GO OF FRAME Dialog-Frame.
        END.
        RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY cb-doc-type FILL-IN-cli
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel Btn_OK cb-doc-type btn-cli
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-load :
define variable i      as integer   no-undo.
    define variable v-list as character no-undo.
    do with frame Dialog-Frame:
        do i = 1 to num-entries ('swo':U + ',' + 'trf':U + ',' + 'vir':U + ',none'):
            v-list = v-list + subst(",&1,&2", entry(i, 'Списание,ТехПролив,Перемещение в вирт.рез.,Не создавать'), i).
        end.
        cb-doc-type:list-item-pairs = trim(v-list, ",").
        if p-attr-value <> "" then
        do:
            FILL-IN-cli:screen-value = entry(2, p-attr-value) + " " + entry(3, p-attr-value).
            cb-doc-type:screen-value = string(lookup(entry(1, p-attr-value), 'swo':U + ',' + 'trf':U + ',' + 'vir':U + ',none')).
        end.
        else
        do:
            cb-doc-type:screen-value = string(lookup('swo':U, 'swo':U + ',' + 'trf':U + ',' + 'vir':U + ',none')).
        end.
    end.
end procedure.
PROCEDURE proc-save :
    define variable v-cli-type as character no-undo.
    define variable v-cli-code as integer no-undo.
    do with frame Dialog-Frame:
        v-cli-type = ''.
        v-cli-code = 0.
        assign
        v-cli-type = entry(1, FILL-IN-cli:screen-value, " ")
        v-cli-code = int(entry(2, FILL-IN-cli:screen-value, " ")) no-error.
        p-attr-value = entry(int(cb-doc-type:input-value), 'swo':U + ',' + 'trf':U + ',' + 'vir':U + ',none') +
                       ',' +
                       v-cli-type +
                       "," +
                       string(v-cli-code).
        p-ok = yes.
    end.
end procedure.
