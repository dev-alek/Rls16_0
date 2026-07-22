define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define input parameter parParentProc as Widget-handle no-undo .
define input-output parameter p-doc-rec as recid no-undo .
define output parameter p-susp-chk as character no-undo .
define output parameter p-link-chk as character no-undo .
define buffer buf_reportShift for ub.reportShift .
define buffer buf_report      for ub.reportShift .
define variable v-susp as character no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
DEFINE BUTTON b-quit AUTO-END-KEY
    LABEL "&Выход"
    SIZE 10 BY 1 TOOLTIP "Выход"
    BGCOLOR 8 .
DEFINE BUTTON BUTTON-susp
    IMAGE-DOWN FILE "btn-down-arrow":U
    IMAGE-INSENSITIVE FILE "btn-down-arrow":U
    LABEL "..."
    SIZE 4.13 BY 1 TOOLTIP "Выбор причин".
DEFINE VARIABLE CsuspChk   AS CHARACTER FORMAT "X(150)":U INITIAL "-1"
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEM-PAIRS "Все",-1
    DROP-DOWN-LIST
    SIZE 87 BY 1 NO-UNDO.
DEFINE VARIABLE v-link-chk AS CHARACTER FORMAT "X(256)":U
    LABEL "Ссылка на ~"корректный~" чек"
    VIEW-AS FILL-IN
    SIZE 44.13 BY 1 NO-UNDO.
DEFINE VARIABLE v-susp-chk AS CHARACTER FORMAT "X(256)":U
    VIEW-AS FILL-IN
    SIZE 87 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-2
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
    SIZE 95.5 BY 5.25.
DEFINE FRAME Dialog-Frame
    b-quit AT ROW 1.25 COL 1.5 WIDGET-ID 24
    CsuspChk AT ROW 3.38 COL 2 COLON-ALIGNED NO-LABEL WIDGET-ID 92
    BUTTON-susp AT ROW 3.42 COL 91.88 WIDGET-ID 88
    v-susp-chk AT ROW 4.88 COL 2 COLON-ALIGNED NO-LABEL WIDGET-ID 42
    v-link-chk AT ROW 6.38 COL 90.01 RIGHT-ALIGNED WIDGET-ID 44
    "  Причина подозрительного чека" VIEW-AS TEXT
    SIZE 32 BY .67 AT ROW 2.29 COL 32.63 WIDGET-ID 38
    RECT-2 AT ROW 2.63 COL 2.5 WIDGET-ID 36
    SPACE(2.12) SKIP(0.61)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
    TITLE "Параметры по смене" WIDGET-ID 100.
ASSIGN
    FRAME Dialog-Frame:SCROLLABLE = FALSE
    FRAME Dialog-Frame:HIDDEN     = TRUE.
ASSIGN
    v-susp-chk:HIDDEN IN FRAME Dialog-Frame = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
    DO:
        define buffer buf_reason for ub.code .
        assign
            v-link-chk
            v-susp-chk
            CsuspChk
            .
        if v-susp = "" then
        do:
            find first buf_reason no-lock where buf_reason.parent = 'reasons-suspicious-check':U and
                buf_reason.code = CsuspChk no-error .
            if available (buf_reason) then
            do:
                v-susp = buf_reason.CodeName .
            end.
        end.
        if v-susp-chk = "" then p-susp-chk = v-susp .
        else p-susp-chk = v-susp + ": " + v-susp-chk .
        p-link-chk = v-link-chk .
        if CsuspChk = "0" and v-susp-chk = "" then
        do:
            message 'Заполните поле с описанием "иной причины" возникновения подозрительного чека'
                view-as alert-box.
            apply "entry" to v-susp-chk IN FRAME Dialog-Frame .
            return no-apply .
        end.
    END.
ON CHOOSE OF BUTTON-susp IN FRAME Dialog-Frame
    DO:
        define variable v-code as character no-undo .
        define buffer buf_reason for ub.code .
        do with frame Dialog-Frame:
            run ref/reasonSuspCheck.w(parparentproc,'ВЫБОР':U,output v-code).
            find first buf_reason no-lock where buf_reason.parent = 'reasons-suspicious-check':U and
                buf_reason.code = v-code no-error .
            if available (buf_reason) then
            do:
                if buf_reason.code = "0" then
                do:
                    v-susp = buf_reason.CodeName .
                    v-susp-chk = "" .
                    display v-susp-chk .
                    CsuspChk = string(buf_reason.code) .
                    display CsuspChk .
                    v-susp-chk:hidden in frame Dialog-Frame = false .
                    enable v-susp-chk with frame Dialog-Frame .
                    apply "entry" to v-susp-chk IN FRAME Dialog-Frame .
                end.
                else
                do:
                    v-susp = "".
                    v-susp-chk = buf_reason.CodeName .
                    v-susp-chk:hidden in frame Dialog-Frame = true .
                    CsuspChk = string(buf_reason.code) .
                    display CsuspChk .
                    assign
                        v-susp = v-susp-chk
                        .
                    apply "entry" to v-link-chk IN FRAME Dialog-Frame .
                end.
            end.
        end.
    END.
ON VALUE-CHANGED OF CsuspChk IN FRAME Dialog-Frame
    DO:
        assign CsuspChk .
        if CsuspChk = "0" then
        do:
            v-susp-chk:hidden in frame Dialog-Frame = false .
            enable v-susp-chk with frame Dialog-Frame .
            apply "entry" to v-susp-chk IN FRAME Dialog-Frame .
        end.
        else
        do:
            v-susp-chk:hidden in frame Dialog-Frame = true .
            v-susp-chk = "" .
            v-susp-chk:screen-value = "" .
            assign v-susp-chk .
            apply "entry" to v-link-chk IN FRAME Dialog-Frame .
        end.
    END.
ON LEAVE OF v-link-chk IN FRAME Dialog-Frame
    DO:
        assign
            v-link-chk.
    END.
ON LEAVE OF v-susp-chk IN FRAME Dialog-Frame
    DO:
        assign v-susp-chk .
    END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
    THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    define variable reason_Chk as character no-undo .
    define variable null_Code  as character no-undo .
    define buffer buf_Code for ub.Code .
    reason_Chk = " " + chr(4) + "-1":U .
    for each ub.Code no-lock where ub.Code.parent = 'reasons-suspicious-check':U and
        ub.Code.status_ = 0  BY ub.Code.Code desc:
        if ub.Code.code = "0" then null_Code = ub.Code.CodeName .
        reason_Chk = reason_Chk + chr(4) + ub.Code.CodeName + chr(4) + string(ub.Code.code) .
    end.
    ASSIGN
        CsuspChk:delimiter = chr(4) .
    CsuspChk:LIST-ITEM-PAIRS  in frame Dialog-Frame = reason_Chk .
    find first ub.susp-chk exclusive-lock where recid(ub.susp-chk) = p-doc-rec no-error .
    if not available (ub.susp-chk) then return no-apply .
    if ub.susp-chk.reason-name <> "" then
    do:
        if ub.susp-chk.reason-name begins null_Code then
        do:
            CsuspChk = "0" .
            v-susp-chk = replace(ub.susp-chk.reason-name, null_code, "") no-error .
            v-susp-chk = trim(v-susp-chk,": ").
            assign v-susp-chk .
            display v-susp-chk with frame Dialog-Frame .
            enable v-susp-chk with frame Dialog-Frame .
        end.
        else
        do:
            find first buf_Code no-lock where buf_Code.parent = 'reasons-suspicious-check':U and
                buf_Code.CodeName = ub.susp-chk.reason-name no-error .
            if available (buf_Code) then
            do:
                CsuspChk = buf_Code.code .
            end.
        end.
    end.
    if ub.susp-chk.link-chk <> "" then v-link-chk = ub.susp-chk.link-chk .
    RUN enable_UI.
    WAIT-FOR GO OF FRAME Dialog-Frame .
END.
RUN disable_UI.
PROCEDURE disable_UI :
    HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
    DISPLAY CsuspChk v-link-chk
        WITH FRAME Dialog-Frame.
    ENABLE RECT-2 b-quit CsuspChk BUTTON-susp v-link-chk
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
END PROCEDURE.
