&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Универсальный диалог для задания вопроса и выбора действия при закрытии смены.

Автор: Шкляр Елена
Дата создания: 05/24/00
Author: Shklyar Elena
Creation date: 05/24/00

Возвращается значение:
  p-number  номер выбранной пользователем кнопки

При нажании Enter  возвращается p-default-button
При нажатии Escape возвращается p-cancel-button

Если в диалоге задана всего одна кнопка, то
p-default-button может совпадать p-cancel-button

Если текст описания не задан, то пустой editor описания не показывается на экране,
а размер кнопки в этом случае автоматически меняется для того,
чтобы был виден весь текст кнопки .
Но при этом размер кнопки ограничен размерами диалога .

После текста кнопки можно указать атрибут для того, чтобы кнопка была недоступна

В данный момент доступны следующие атрибуты
  disable - Показать кнопку, но сделать ее недоступной для выбора
  confirm - При выборе кнопки пользователь должен подтвердить свой выбор

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc         as widget-handle no-undo .
define input  parameter p-title               as character no-undo .
define input  parameter p-text                as character no-undo .
define input  parameter p-delimiter           as character no-undo .
define input  parameter p-buttons-visible     as character no-undo .
define input  parameter p-buttons             as character no-undo .
define input  parameter p-buttons-description as character no-undo .
define input  parameter p-default-button      as integer   no-undo .
define input  parameter p-cancel-button       as integer   no-undo .
define input  parameter p-text-button         as character no-undo .
define input  parameter p-curr-obj-type       as character no-undo .
define input  parameter p-curr-obj-code       as integer no-undo .
define input  parameter p-shift-date          as date no-undo .
define input  parameter p-shift-num           as integer no-undo .
define input  parameter p-shift-name          as character no-undo .
define output parameter p-number              as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Универсальный диалог для задания вопроса и выбора действия".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-buttons,p-text)" }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ rep/html-conv.i }
{ gbl/prn-lib.i   }
{ str/temp_suspChk.i }

/*{ cmp/showinf.i  }*/
define variable mCodeMes as char no-undo.
if num-entries(p-title,"|") > 1
    then
    assign
        mCodeMes = entry(2,p-title,"|")
        p-title  = entry(1,p-title,"|")
        .
define variable v-buttons          as integer   no-undo.
define variable v-need-confirm     as logical   no-undo extent 5 .

define variable v-first-delimiter  as character no-undo init "|" .
define variable v-second-delimiter as character no-undo init "^" .
define stream Out-Stream .
define stream OutStr-html.
/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

function Str-chk-type returns character
    (input p-chk-type as character) forward .
    
&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS EDITOR-1 
&Scoped-Define DISPLAYED-OBJECTS EDITOR-1 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_1 
     LABEL "&1" 
     SIZE 15 BY 1.21
     BGCOLOR 8 .

DEFINE BUTTON Btn_2 AUTO-GO 
     LABEL "&2" 
     SIZE 15 BY 1.21
     BGCOLOR 8 .

DEFINE BUTTON Btn_3 AUTO-GO 
     LABEL "&3" 
     SIZE 15 BY 1.21
     BGCOLOR 8 .

DEFINE BUTTON Btn_cancel AUTO-GO 
     LABEL "Отмена" 
     SIZE 15 BY 1.21
     BGCOLOR 8 .

DEFINE BUTTON Btn_close AUTO-GO 
     LABEL "Закрыть смену с расхождениями" 
     SIZE 41 BY 1.21
     BGCOLOR 8 .

DEFINE BUTTON Btn_print 
     LABEL "&Печать" 
     SIZE 15 BY 1.21
     BGCOLOR 8 .

DEFINE VARIABLE description-1 AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 41 BY 2 NO-UNDO.

DEFINE VARIABLE description-2 AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 41 BY 2 NO-UNDO.

DEFINE VARIABLE description-3 AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 41 BY 2 NO-UNDO.

DEFINE VARIABLE EDITOR-1 AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 41 BY 2
     FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_1 AT ROW 4.21 COL 45
     Btn_2 AT ROW 6.29 COL 45
     Btn_3 AT ROW 8.38 COL 45
     Btn_close AT ROW 10.25 COL 3
     Btn_cancel AT ROW 10.25 COL 45
     EDITOR-1 AT ROW 1.67 COL 3 NO-LABEL
     description-1 AT ROW 3.79 COL 3 NO-LABEL
     description-2 AT ROW 5.88 COL 3 NO-LABEL
     description-3 AT ROW 8 COL 3 NO-LABEL
     Btn_print AT ROW 2.17 COL 45 WIDGET-ID 2
     SPACE(1.74) SKIP(8.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Вопрос".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME Custom                                                    */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON Btn_1 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       Btn_1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON Btn_2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       Btn_2:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON Btn_3 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       Btn_3:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON Btn_cancel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       Btn_cancel:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON Btn_close IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       Btn_close:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON Btn_print IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       Btn_print:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR EDITOR description-1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       description-1:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR description-2 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       description-2:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR description-3 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       description-3:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-3:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN 
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Вопрос */
DO:
        /* запрещаем закрывать окно */
        /* пользователь должен нажать Excape */
        RETURN NO-APPLY .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_1 Dialog-Frame
ON CHOOSE OF Btn_1 IN FRAME Dialog-Frame /* 1 */
DO:
        if v-need-confirm [1] then 
        do:
            define variable lok as logical no-undo .
            assign
                lok = false
                .
            message
                self :label skip
                "" (if description-1 :visible
                then description-1 :screen-value
                else ""
                ) skip
                "Продолжить?"
                view-as alert-box question buttons yes-no update lok .
            if lok <> true then 
            do:
                return no-apply .
            end.
        end.
        assign
            p-number = entry(1,p-text-button,v-first-delimiter)
            .
        if p-number <> "cancel" and p-number <> "closeWith" then 
        do:
            run diff-number no-error.
        end.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_2 Dialog-Frame
ON CHOOSE OF Btn_2 IN FRAME Dialog-Frame /* 2 */
DO:
        if v-need-confirm [2] then 
        do:
            define variable lok as logical no-undo .
            assign
                lok = false
                .
            message
                self :label skip
                "" (if description-2 :visible
                then description-2 :screen-value
                else ""
                ) skip
                "Продолжить?"
                view-as alert-box question buttons yes-no update lok .
            if lok <> true then 
            do:
                return no-apply .
            end.
        end.

        assign
            p-number = entry(2,p-text-button,v-first-delimiter)
            .
        if p-number <> "cancel" and p-number <> "closeWith" then 
        do:
            run diff-number no-error.
            Btn_2:auto-go in frame Dialog-Frame = false.
        end.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_3 Dialog-Frame
ON CHOOSE OF Btn_3 IN FRAME Dialog-Frame /* 3 */
DO:
        if v-need-confirm [3] then 
        do:
            define variable lok as logical no-undo .
            assign
                lok = false
                .
            message
                self :label skip
                "" (if description-3 :visible
                then description-3 :screen-value
                else ""
                ) skip
                "Продолжить?"
                view-as alert-box question buttons yes-no update lok .
            if lok <> true then 
            do:
                return no-apply .
            end.
        end.

        assign
            p-number = entry(3,p-text-button,v-first-delimiter)
            .
        if p-number <> "cancel" and p-number <> "closeWith" then 
        do:
            run diff-number no-error.
            Btn_3:auto-go in frame Dialog-Frame = false.
        end.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_cancel Dialog-Frame
ON CHOOSE OF Btn_cancel IN FRAME Dialog-Frame /* Отмена */
DO:
        assign
            p-number = "cancel"
            .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_close Dialog-Frame
ON CHOOSE OF Btn_close IN FRAME Dialog-Frame /* Закрыть смену с расхождениями */
DO:

        assign
            p-number = "closeWith"
            .

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_print Dialog-Frame
ON CHOOSE OF Btn_print IN FRAME Dialog-Frame /* Печать */
DO:
        run proc-b-print in this-procedure no-error.
        if error-status:error then return no-apply.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

do with frame {&frame-name}:

    assign
        frame {&frame-name} :title = p-title
        .

    if length (p-delimiter) >= 1 then 
    do:
        assign
            v-first-delimiter = substring(p-delimiter, 1, 1)
            .
    end.

    if length (p-delimiter) >= 2 then 
    do:
        assign
            v-second-delimiter = substring(p-delimiter, 2, 1)
            .
    end.


    assign
        v-buttons = num-entries(p-buttons, v-first-delimiter)
        editor-1  = p-text
        .

    if v-buttons > 5 then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Количество кнопок больше четырех" skip
            "p-buttons" p-buttons skip
            view-as alert-box .
        undo, return error .
    end.

    if v-buttons <> num-entries(p-buttons-description, v-first-delimiter) then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания входных параметров" skip
            "Количество описаний кнопок не совпадает с количество кнопок" skip
            "Кнопок" v-buttons skip
            "Описаний кнопок" num-entries(p-buttons-description) skip
            view-as alert-box error .
        undo, return error .
    end.

    define variable ii                as integer   no-undo .
    define variable v-but             as integer   no-undo .
    define variable v-but-text        as character no-undo .
    define variable v-desc-text       as character no-undo .
    define variable v-visible-buttons as logical   no-undo .
    do ii = 1 to v-buttons
        :
        v-visible-buttons  = logical(entry(ii,p-buttons-visible, v-first-delimiter)) .
        if v-visible-buttons then 
        do:
            if v-but = 0 then 
            do:
                assign
                    v-but-text  = entry(ii, p-buttons, v-first-delimiter)
                    v-desc-text = entry(ii, p-buttons-description, v-first-delimiter)
                    v-but       = v-but + 1 .
                .
            end.
            else 
            do: 
                assign
                    v-but-text  = v-but-text + v-first-delimiter + entry(ii, p-buttons, v-first-delimiter)
                    v-desc-text = v-desc-text + v-first-delimiter + entry(ii, p-buttons-description, v-first-delimiter)
                    v-but       = v-but + 1 
                    .
            end.
    
        end.
    end.

    v-buttons = v-but .
    p-buttons-description = v-desc-text .
    p-buttons = v-but-text .
    p-cancel-button = v-buttons .
    p-default-button = p-cancel-button - 1 .

    define variable v-button-handle             as handle no-undo extent 5 .
    define variable v-button-description-handle as handle no-undo extent 5 .
    assign
        v-button-handle[1]             = Btn_1         :handle
        v-button-handle[2]             = Btn_2         :handle
        v-button-handle[3]             = Btn_3         :handle
        v-button-handle[4]             = Btn_close         :handle
        v-button-handle[5]             = Btn_cancel         :handle
        v-button-description-handle[1] = description-1 :handle
        v-button-description-handle[2] = description-2 :handle
        v-button-description-handle[3] = description-3 :handle
        /*        v-button-description-handle[4] = description-4 :handle*/
        /*        v-button-description-handle[5] = description-5 :handle*/
        .

    define variable v-handle             as handle no-undo .
    define variable v-handle-description as handle no-undo .

    if  p-default-button > 0
        and p-default-button <= v-buttons
        then 
    do:
        assign
            v-handle = v-button-handle[p-default-button]
            .
        assign
            v-handle :default                   = true
            frame {&frame-name} :default-button = v-handle
            .
    end.
    else 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Не задана кнопка по умолчанию" skip
            "p-default-button" p-default-button skip
            view-as alert-box .
        undo, return error .
    end.

    if  p-cancel-button > 0
        and p-cancel-button <= v-buttons
        then 
    do:
        assign
            v-handle = v-button-handle[p-cancel-button]
            .
        assign
            frame {&frame-name} :cancel-button = v-handle
            .
    end.
    else 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Не задана кнопка выбираемая при нажатии Escape" skip
            "p-cancel-button" p-cancel-button skip
            view-as alert-box .
        undo, return error .
    end.

    if  v-buttons > 1
        and p-cancel-button = p-default-button then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Номер кнопки по умолчанию совпадает с номером кнопки выбираемой при нажатии Escape" skip
            "p-default-button" p-default-button skip
            "p-cancel-button"  p-cancel-button  skip
            view-as alert-box .
    end.



    define variable ind as integer no-undo .
    do ind = 1 to v-buttons
        :
        assign
            v-handle             = v-button-handle[ind]
            v-handle-description = v-button-description-handle[ind]
            .

        define variable v-button-text      as character no-undo .
        define variable v-description-text as character no-undo .
        define variable l-sensitive        as logical   no-undo .
        define variable l-confirm          as logical   no-undo .
        define variable v-btn-text-ind     as integer   no-undo .
    
        assign
            v-button-text      = entry(ind, p-buttons, v-first-delimiter)
            v-description-text = entry(ind, p-buttons-description, v-first-delimiter)
            v-visible-buttons  = logical(entry(ind,p-buttons-visible, v-first-delimiter))
            l-sensitive        = true
            l-confirm          = false
            .
    
        define variable v-button-attribute as character no-undo .

        do v-btn-text-ind = 2 to num-entries(v-button-text, v-second-delimiter )
            :
            assign
                v-button-attribute = entry(v-btn-text-ind, v-button-text, v-second-delimiter)
                .

            case v-button-attribute :
                when 'disable' then 
                    do:
                        assign
                            l-sensitive = false
                            .
                    end.
                when 'confirm' then 
                    do:
                        assign
                            l-confirm = true
                            .
                    end.
                otherwise 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Неизвестный атрибут кнопки" skip
                        "Атрибут" v-button-attribute skip
                        "Описание кнопки" ind skip
                        v-button-text skip
                        view-as alert-box error .
                end.
            end case .
        end.

        if num-entries (v-button-text, v-second-delimiter ) >= 1 then 
        do:
            assign
                v-button-text = entry(1, v-button-text, v-second-delimiter)
                .
        end.

        assign
            v-need-confirm [ind] = l-confirm
            .

        assign
            v-handle :label     = v-button-text
            v-handle :visible   = true
            v-handle :sensitive = l-sensitive
            .

        if v-description-text = "" then 
        do:
            assign
                v-handle :width = min(max(v-handle :width
                                 ,length(v-button-text) + 2
                                 )
                             ,frame {&frame-name} :width - v-handle :column - 1
                             )
                .
        end.

        if v-description-text <> "" then 
        do:
            assign
                v-handle-description :visible      = true
                v-handle-description :sensitive    = true
                v-handle-description :read-only    = true
                v-handle-description :screen-value = v-description-text
                .
        end.
        
    end.

end.

on cursor-left anywhere 
    do:
        apply "back-tab":u to focus .
    end.

on cursor-right anywhere 
    do:
        apply "tab":u to focus .
    end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    def var mAnswer as char no-undo.   
    publish "ResponseToQuestion" (output mAnswer ).
    p-number = (mAnswer) no-error.
    if error-status:error
        then 
    do:
        define variable mbeg as integer no-undo.

        mbeg = index("," + mAnswer   , "," + mcodemes + "=") .
        mAnswer = substring (mAnswer, mbeg + length(mcodemes) + 1).
        mAnswer = entry(1,mAnswer).  
        p-number = (mAnswer) no-error.
        if error-status:error
            then 
        block-num:
        do mbeg = 1 to num-entries (mAnswer):
            p-number = entry(mbeg, mAnswer) no-error.
            if not error-status:error
                then 
                leave block-num.
        end.         
        
     
    end.
    if   p-number eq "" 
        then 
    do:
        RUN enable_UI.

        if  p-default-button > 0
            and p-default-button <= v-buttons
            then 
        do:
            assign
                v-handle = v-button-handle[p-default-button]
                .
            apply 'entry':u to v-handle .
        end.

        WAIT-FOR GO OF FRAME {&FRAME-NAME}.
    end.
END.
RUN disable_UI.

RETURN.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
    /*------------------------------------------------------------------------------
      Purpose:     ENABLE the User Interface
      Parameters:  <none>
      Notes:       Here we display/view/enable the widgets in the
                   user-interface.  In addition, OPEN all queries
                   associated with each FRAME and BROWSE.
                   These statements here are based on the "Other 
                   Settings" section of the widget Property Sheets.
    ------------------------------------------------------------------------------*/
    DISPLAY EDITOR-1 Btn_print Btn_close Btn_cancel
        WITH FRAME Dialog-Frame.
    ENABLE EDITOR-1 Btn_print Btn_cancel Btn_close
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

procedure diff-number:
    define variable v-ok as logical no-undo .
    case p-number:
        when "errorMass" then 
            do:
                run str/diffShiftClose.w (
                    input parparentproc,
                    input {&lookup},
                    input p-curr-obj-type,
                    input p-curr-obj-code,
                    input p-shift-date,
                    input p-shift-num,
                    input p-shift-name,
                    input "diff-mass",
                    output v-ok)  .
            end.
        when "errorTRK" then 
            do:
                run str/diffShiftClose.w (
                    input parparentproc,
                    input {&lookup},
                    input p-curr-obj-type,
                    input p-curr-obj-code,
                    input p-shift-date,
                    input p-shift-num,
                    input p-shift-name,
                    input "diff-TRK",
                    output v-ok) no-error .
            end.
        when "errorCheck" then 
            do:
                run str/susp-chk.w (
                    input parparentproc,
                    input {&lookup},
                    input p-curr-obj-type,
                    input p-curr-obj-code,
                    input p-shift-date,
                    input p-shift-num,
                    input p-shift-name,
                    output table tt-susp-chk,
                    output v-ok) no-error .
            end .
    end.
end.

PROCEDURE proc-b-print :

    define VARIABLE p-report-id         as character no-undo .
    define variable v-file-name-rep-htm as character no-undo .
    define variable dev-paid-trans      as decimal   no-undo .
    define variable prc-dev-mass        as decimal   no-undo .
    
    define buffer buf_shiftParam for ub.shift-param .
    define buffer buf_goods      for ub.goods .
    define buffer buf_susp-chk   for ub.susp-chk .
    define buffer bf_shift-obj   for ub.shift-obj .
    
    /*печать*/
    run get-report-num (output p-report-id).
    
    v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   

    find first bf_shift-obj no-lock where bf_shift-obj.obj-code = p-curr-obj-code and
        bf_shift-obj.obj-type = p-curr-obj-type and
        bf_shift-obj.shift-date = p-shift-date and 
        bf_shift-obj.Shift-num = p-shift-num no-error .
    if not available (bf_shift-obj) then return error.
    
    find first buf_shiftParam no-lock where buf_shiftParam.obj-code = bf_shift-obj.obj-code and
        buf_shiftParam.obj-type = bf_shift-obj.obj-type and
        buf_shiftParam.shift-date = bf_shift-obj.shift-date and
        buf_shiftParam.shift-num = bf_shift-obj.shift-num and 
        buf_shiftParam.gds-code = 0 and
        buf_shiftParam.pl-code = 0 no-error .
    if not available (buf_shiftParam) then 
    do:
        find first buf_shiftparam no-lock where buf_shiftparam.obj-code = 0 and
            buf_shiftparam.obj-type = "" and
            buf_shiftparam.shift-date = 01/01/1900 no-error .
        if not available (buf_shiftparam) then 
        do:
            /* первый запуск */
            assign
                prc-dev-mass   = 0.65
                dev-paid-trans = 1
                .
        end.
        else 
        do:
            assign
                prc-dev-mass   = buf_shiftparam.prc-dev-mass
                dev-paid-trans = buf_shiftparam.dev-paid-trans
                .        
        end.
    end.
    else
        assign
            dev-paid-trans = buf_shiftParam.dev-paid-trans
            prc-dev-mass   = buf_shiftParam.prc-dev-mass
            .
            
    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
    put stream OutStr-html unformatted
        "<!DOCTYPE HTML>" skip
        ' <html>' skip
        '  <head>' skip
        '   <meta charset="utf-8">' skip
        '    <style type="text/css">' skip
        '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
        '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
        '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
        '   </style>' skip
        '  </head>' skip
        .
        
    put stream OutStr-html unformatted
        '<body>' skip
        '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        .
    put stream OutStr-html unformatted
        '<tr class="set_columns">' skip
        '<td style="width: 100px;"></td>' skip
        '<td style="width: 200px;"></td>' skip
        '<td style="width: 100px;"></td>' skip
        '<td style="width: 150px;"></td>' skip
        '<td style="width: 150px;"></td>' skip
        '<td style="width: 150px;"></td>' skip
        '<td style="width: 150px;"></td>' skip
        '<td style="width: 150px;"></td>' skip
        '<td style="width: 350px;"></td>' skip
        '</tr>' skip
        .
    put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="9" style="text-align: left;">АЗК №' + string(bf_shift-obj.obj-code) + ' </td>' skip
        '</tr>' skip  
        .
            
    put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="9" style="text-align: center; font-weight: bold;">Выявленные ошибки при закрыии смены</td>' skip 
        '</tr>' skip
        .
    put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="9" style="text-align: left;">Смена: ' + string(p-shift-num) + ' от ' + string(p-shift-date,"99.99.9999") + '</td>' skip
        '</tr>' skip
        .
      
    put stream OutStr-html unformatted
        '<tr style="height:25px;">' skip
        '<td colspan="9" style="text-align: left;"></td>' skip
        '</tr>' skip  
        .
    put stream OutStr-html unformatted
        '</thead>' skip 
        '<tbody>' skip.
        
    v-visible-buttons = false .
    v-visible-buttons  = logical(entry(1,p-buttons-visible, v-first-delimiter)) .    
    if v-visible-buttons then do:                     
    put stream OutStr-html unformatted
        '<TR style="height:55px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: center; font-weight:bold;">Проверка отклонений по 1 части сменного отчета. Отклонение между расчетной и фактической массой топлива на конец смены.</TD>' skip
        '</tr>' skip
        '<tr>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Код топлива</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ резервуара</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Расч. остаток на конец смены, кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Факт. остаток на конец смены, кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Допустимое отклонение, кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Факт. отклонение по остаткам, кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Превышение допустимого отклонения на, кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Причина расхождения/номер заявки в ЦДС</TD>' skip
        '</TR>'skip
        .
              

    for each buf_shiftParam no-lock 
        where buf_shiftParam.obj-code = p-curr-obj-code
        and buf_shiftParam.obj-type = p-curr-obj-type
        and buf_shiftParam.shift-date = p-shift-date
        and buf_shiftParam.shift-num = p-shift-num
        and buf_shiftParam.error-mass:       
        find first buf_goods no-lock where buf_goods.gds-code = buf_shiftParam.gds-code no-error .
        if not available (buf_goods) then next .
       
        put stream OutStr-html unformatted
            '<TR>' skip
            '<TD text_wrap="true">' + string(buf_goods.gds-code) + '</TD>' skip
            '<TD text_wrap="true">' + buf_goods.gds-name + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_shiftParam.loc1) + '</TD>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.system-cli-qnty,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.system-cli-qnty <> ? then fnc-convert-dot-to-colon(buf_shiftParam.system-cli-qnty,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.fact-stock-end,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.fact-stock-end <> ? then fnc-convert-dot-to-colon(buf_shiftParam.fact-stock-end,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.dev-mass,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.dev-mass <> ? then fnc-convert-dot-to-colon(buf_shiftParam.dev-mass,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.diff-stock-end,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.diff-stock-end <> ? then fnc-convert-dot-to-colon(buf_shiftParam.diff-stock-end,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(absolute(buf_shiftParam.dev-mass - buf_shiftParam.diff-stock-end),">>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if absolute(buf_shiftParam.dev-mass - buf_shiftParam.diff-stock-end) <> ? then fnc-convert-dot-to-colon(absolute(buf_shiftParam.dev-mass - buf_shiftParam.diff-stock-end),">>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
            '<TD text_wrap="true" style="width: 350px;">' + string(buf_shiftParam.disc-diffMass) + '</TD>' skip
            '</tr>' skip
            .
    end.        
    put stream OutStr-html unformatted
        '<thead>' skip
        '<TR  style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;">* Процент допустимого отклонения массы топлива = ' + string(prc-dev-mass,"9.99") + '%</TD>' skip
        '</tr>' skip
        '<TR  style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;"></TD>' skip
        '</tr>' skip         
        '<TR  style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;"></TD>' skip
        '</tr>' skip     
        .
            
    put stream OutStr-html unformatted
        '<TR  style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;"></TD>' skip
        '</tr>' skip     
        '</thead>' skip
        .
    end.
    v-visible-buttons = false .
    v-visible-buttons  = logical(entry(2,p-buttons-visible, v-first-delimiter)) .    
    if v-visible-buttons then do:   
            
    put stream OutStr-html unformatted
        '<TR style="height:55px;">' skip
        '<TD text_wrap="true" height:25px; colspan="9" style="text-align: center; font-weight:bold;">Проверка отклонений по 9 части сменного отчета. Отклонения между объемом продаж топлива на кассе и объемом по счетчикам ТРК.</TD>' skip
        '</tr>' skip
        '<tr>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Код топлива</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ резервуара</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Объем продаж на кассе, л</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Объем продаж по счетчикам ТРК, л</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Техпролив, л</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Разница по кассе и ТРК, л</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Превышение допустимого отклонения на, л</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Причина расхождения/номер заявки в ЦДС</TD>' skip
        '</TR>'skip
        .
              
    for each buf_shiftParam no-lock 
        where buf_shiftParam.obj-code = p-curr-obj-code
        and buf_shiftParam.obj-type = p-curr-obj-type
        and buf_shiftParam.shift-date = p-shift-date
        and buf_shiftParam.shift-num = p-shift-num
        and buf_shiftParam.error-paid-trans:      
        find first buf_goods no-lock where buf_goods.gds-code = buf_shiftParam.gds-code no-error .
        if not available (buf_goods) then next .
        
        put stream OutStr-html unformatted
            '<TR>' skip
            '<TD text_wrap="true">' + string(buf_goods.gds-code) + '</TD>' skip
            '<TD text_wrap="true">' + buf_goods.gds-name + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_shiftParam.loc1) + '</TD>' skip
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.cash-qnty,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.cash-qnty <> ? then fnc-convert-dot-to-colon(buf_shiftParam.cash-qnty,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.meas-qnty,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.meas-qnty <> ? then fnc-convert-dot-to-colon(buf_shiftParam.meas-qnty,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.tech-refuell,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.tech-refuell <> ? then fnc-convert-dot-to-colon(buf_shiftParam.tech-refuell,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.diff-cash-trk,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.diff-cash-trk <> ? then fnc-convert-dot-to-colon(buf_shiftParam.diff-cash-trk,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(absolute(buf_shiftParam.dev-paid-trans - buf_shiftParam.diff-cash-trk),">>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if absolute(buf_shiftParam.dev-paid-trans - buf_shiftParam.diff-cash-trk) <> ? then fnc-convert-dot-to-colon(absolute(buf_shiftParam.dev-paid-trans - buf_shiftParam.diff-cash-trk),">>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
            '<TD text_wrap="true" style="width: 350px;">' + string(buf_shiftParam.disc-diffTRK) + '</TD>' skip
            '</tr>' skip
            .
    end.

    put stream OutStr-html unformatted
        '<thead>' skip
        '<TR style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;">*Допустимое отклонение между объемом продаж топлива на кассе и объемом по счетчикам ТРК = ' + string(dev-paid-trans,"9.99") + 'л</TD>' skip
        '</tr>' skip
        '<TR style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;"></TD>' skip
        '</tr>' skip         
        '<TR style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;"></TD>' skip
        '</tr>' skip  
        .    

    put stream OutStr-html unformatted
        '<TR style="height:25px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: left;"></TD>' skip
        '</tr>' skip  
        '</thead>' skip  
        .

end.
    v-visible-buttons = false .
    v-visible-buttons  = logical(entry(3,p-buttons-visible, v-first-delimiter)) .    
    if v-visible-buttons then do:   
        
    put stream OutStr-html unformatted
        '<TR style="height:55px;">' skip
        '<TD text_wrap="true" colspan="9" style="text-align: center; font-weight:bold;">"Подозрительные" чеки.</TD>' skip
        '</tr>' skip
        '<tr>' skip
        '<TD text_wrap="true" colspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Признак</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ чека в ТН</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Тип чека</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ чека на кассе</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ кассы</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Дата/время</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Причина возникновения чека</TD>' skip
        '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Ссылка на "корректный" чек</TD>' skip
        '</TR>' skip
        .
              

    for each buf_susp-chk no-lock 
        where buf_susp-chk.obj-code = p-curr-obj-code
        and buf_susp-chk.obj-type = p-curr-obj-type
        and buf_susp-chk.shift-date = p-shift-date
        and buf_susp-chk.shift-num = p-shift-num:       

        put stream OutStr-html unformatted
            '<TR>' skip
            '<TD text_wrap="true" colspan="2" style="text-align: center;">' + buf_susp-chk.office + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.doc-code) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + Str-chk-type(string(buf_susp-chk.chk-type)) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.chk-num) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.pay-desk) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.chk-date,"99.99.9999") + '/' + string(buf_susp-chk.chk-time,"hh:mm") + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.reason-name) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.link-chk) + '</TD>' skip
            '</tr>' skip
            .
    end.
    end.        
    put stream OutStr-html unformatted
        '</tbody>' skip .
  
  
     
    put stream OutStr-html unformatted
  
        '</table>' skip
        '</body>' skip
        '</html>' skip
        .
  
    output stream OutStr-html close.
        
    run prn-lib-reportviewer-report-name in this-procedure (
        input parparentproc
        ,input v-file-name-rep-htm
        ) .
    if error-status:error then
    do:
        message return-value view-as alert-box.
        return .
    end.

END PROCEDURE.

PROCEDURE get-report-num :

    define output parameter p-report-num as integer no-undo .

    do
        on error undo, return error return-value
        :
        run gbl/getrpnum.p (output p-report-num).
    end.

END PROCEDURE.

function Str-chk-type returns character
    (input p-chk-type as character):
    define variable v-num-element   as integer   no-undo.
    define variable p-name-chk-type as character no-undo .
    /* Код_вида_расходов. Получение номера элемента в списке кодов */
    v-num-element = lookup(p-chk-type, {&receipt-codes}).

    /* Получение наименования код_вида_расходов по полученному элементу из списка наименований */
    p-name-chk-type = entry(v-num-element, {&receipt-codes-full}).
    if p-chk-type <> "" and v-num-element = 0 then
    do:
        message "Ошибка 115." view-as alert-box.
    end.
    else return p-name-chk-type .

end function.   
