define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-shift-date like ub.shift-obj.shift-date no-undo .
define input parameter p-shift-num like ub.shift-obj.shift-num no-undo .
define input parameter p-shift-name like ub.shift-obj.shift-name no-undo .
define buffer buf_reportShift for ub.reportShift .
define buffer buf_report      for ub.reportShift .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
DEFINE BUTTON b-quit AUTO-END-KEY
    LABEL "&Выход"
    SIZE 10 BY 1 TOOLTIP "Выход"
    BGCOLOR 8 .
DEFINE VARIABLE Dev-paid-trans AS DECIMAL   FORMAT "->9.99":U INITIAL 1
    VIEW-AS FILL-IN
    SIZE 8.5 BY 1
    NO-UNDO.
DEFINE VARIABLE f-shift        AS CHARACTER FORMAT "X(256)":U INITIAL "Смена: 19/08/2024 Номер: 1 Порядок: 1"
    VIEW-AS FILL-IN
    SIZE 39.5 BY 1 NO-UNDO.
DEFINE VARIABLE id-check       AS INTEGER   FORMAT "999999999":U INITIAL 1
    VIEW-AS FILL-IN
    SIZE 11.5 BY 1
    NO-UNDO.
DEFINE VARIABLE id-shift       AS INTEGER   FORMAT "999999999":U INITIAL 1
    VIEW-AS FILL-IN
    SIZE 11.5 BY 1
    NO-UNDO.
DEFINE VARIABLE Prc-dev-mass   AS DECIMAL   FORMAT "->9.99":U INITIAL .65
    VIEW-AS FILL-IN
    SIZE 8.5 BY 1
    NO-UNDO.
DEFINE RECTANGLE RECT-1
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
    SIZE 62 BY 7.75.
DEFINE FRAME Dialog-Frame
    b-quit AT ROW 1 COL 1 WIDGET-ID 24
    f-shift AT ROW 1 COL 12 COLON-ALIGNED NO-LABEL WIDGET-ID 4
    Prc-dev-mass AT ROW 3 COL 58 RIGHT-ALIGNED NO-LABEL WIDGET-ID 6
    Dev-paid-trans AT ROW 5.04 COL 58 RIGHT-ALIGNED NO-LABEL WIDGET-ID 8
    id-check AT ROW 7.33 COL 61 RIGHT-ALIGNED NO-LABEL WIDGET-ID 32
    id-shift AT ROW 8.79 COL 61 RIGHT-ALIGNED NO-LABEL WIDGET-ID 34
    "топлива на кассе и объемом по счетчик" VIEW-AS TEXT
    SIZE 45 BY .58 AT ROW 6.04 COL 2.5 WIDGET-ID 22
    "Идентификатор сменного отчета" VIEW-AS TEXT
    SIZE 45 BY 1 AT ROW 8.79 COL 2.5 WIDGET-ID 30
    "Идентификатор чек-листа" VIEW-AS TEXT
    SIZE 45 BY 1 AT ROW 7.33 COL 2.5 WIDGET-ID 28
    "л." VIEW-AS TEXT
    SIZE 2.5 BY 1 AT ROW 5.04 COL 60 WIDGET-ID 10
    "%" VIEW-AS TEXT
    SIZE 2.5 BY 1 AT ROW 3 COL 60 WIDGET-ID 12
    "Процент допустимого отклонения массы топлива" VIEW-AS TEXT
    SIZE 45 BY 1 AT ROW 3 COL 2.5 WIDGET-ID 14
    "на конец смены" VIEW-AS TEXT
    SIZE 45 BY .58 AT ROW 4 COL 2.5 WIDGET-ID 16
    "Допустимое отклонение между объемом продаж" VIEW-AS TEXT
    SIZE 45 BY 1 AT ROW 5.04 COL 2.5 WIDGET-ID 20
    RECT-1 AT ROW 2.5 COL 1.5 WIDGET-ID 26
    SPACE(1.62) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
    TITLE "Параметры по смене" WIDGET-ID 100.
ASSIGN
    FRAME Dialog-Frame:SCROLLABLE = FALSE
    FRAME Dialog-Frame:HIDDEN     = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
    THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    f-shift = "Смена: " + string(p-shift-date,"99/99/9999") + " Номер: " + string(p-shift-num) + " Порядок: " + string(p-shift-name) .
    find first ub.shift-obj no-lock where ub.shift-obj.obj-code = p-obj-code and
        ub.shift-obj.obj-type = p-obj-type and
        ub.shift-obj.shift-date = p-shift-date and
        ub.shift-obj.shift-num = p-shift-num and
        ub.shift-obj.shift-name = p-shift-name no-error .
    if ub.shift-obj.status_ = 'зкр':U then
    do:
        find first ub.shift-param no-lock where ub.shift-param.obj-code = p-obj-code and
            ub.shift-param.obj-type = p-obj-type and
            ub.shift-param.shift-date = p-shift-date and
            ub.shift-param.shift-name = p-shift-name and
            ub.shift-param.shift-num = p-shift-num and
            ub.shift-param.gds-code = 0 and
            ub.shift-param.pl-code = 0 no-error .
        if available (ub.shift-param) then
        do:
            assign
                dev-paid-trans = ub.shift-param.dev-paid-trans
                prc-dev-mass   = ub.shift-param.prc-dev-mass
                .
            find first buf_reportShift exclusive-lock where buf_reportShift.shift-date = p-shift-date and
                buf_reportShift.shift-num = p-shift-num and buf_reportShift.obj-code = p-obj-code and
                buf_reportShift.obj-type = p-obj-type and buf_reportShift.report-type = 1 no-error .
            if available (buf_reportShift) then
            do:
                id-shift = buf_reportShift.id .
            end.
            else id-shift = 0 .
            find first buf_reportShift exclusive-lock where buf_reportShift.shift-date = p-shift-date and
                buf_reportShift.shift-num = p-shift-num and buf_reportShift.obj-code = p-obj-code and
                buf_reportShift.obj-type = p-obj-type and buf_reportShift.report-type = 0 no-error .
            if available (buf_reportShift) then
            do:
                id-check = buf_reportShift.id .
            end.
            else id-check = 0 .
        end.
        else
        do:
            return .
        end.
    end.
    else
    do:
        find first ub.shift-param no-lock where ub.shift-param.obj-code = p-obj-code and
            ub.shift-param.obj-type = p-obj-type and
            ub.shift-param.shift-date = p-shift-date and
            ub.shift-param.shift-name = p-shift-name and
            ub.shift-param.shift-num = p-shift-num and
            ub.shift-param.gds-code = 0 and
            ub.shift-param.pl-code = 0 no-error .
        if not available (ub.shift-param) then do:
        find first ub.shift-param no-lock where ub.shift-param.obj-code = 0 and
            ub.shift-param.obj-type = "" and
            ub.shift-param.shift-date = 01.01.1900  no-error .
        if available (ub.shift-param) then
        do:
            assign
                dev-paid-trans = ub.shift-param.dev-paid-trans
                prc-dev-mass   = ub.shift-param.prc-dev-mass
                .
        end.
        else return .
        end.
        else do:
            assign
                dev-paid-trans = ub.shift-param.dev-paid-trans
                prc-dev-mass   = ub.shift-param.prc-dev-mass
                .
        end.
    end.
    RUN enable_UI.
    if ub.shift-obj.status_ <> 'зкр':U then do:
        hide id-check id-shift in frame Dialog-Frame .
    end.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
    HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
    DISPLAY f-shift Prc-dev-mass Dev-paid-trans id-check id-shift
        WITH FRAME Dialog-Frame.
    ENABLE b-quit RECT-1
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
END PROCEDURE.
