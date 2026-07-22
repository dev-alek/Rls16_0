&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

DEFINE TEMP-TABLE X_shift-param NO-UNDO LIKE ub.shift-param
    field gds-name as character.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список выявленных отклонений

Автор: Шкляр Елена
Дата создания: 20/04/95
Author: Shklyar Elena
Creation date: 20/04/95
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc         as widget-handle no-undo .
define input parameter p-mode           as character     no-undo.
define input parameter p-obj-type       as character     no-undo.
define input parameter p-obj-code       as integer       no-undo.
define input parameter p-shift-date     as date          no-undo.
define input parameter p-shift-num      as integer       no-undo.
define input parameter p-shift-name     as character     no-undo.
define input parameter p-type           as character     no-undo.
define output parameter p-ok            as logical       no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список выявленных отклонений".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ rep/html-conv.i }
{ gbl/prn-lib.i   }
/* Local Variable Definitions ---                                       */
define variable v-title as character no-undo .
define stream Out-Stream .
define stream OutStr-html.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    
&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_shift-param

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 X_shift-param.gds-code ~
X_shift-param.loc1 X_shift-param.gds-name X_shift-param.dev-mass ~
X_shift-param.diff-stock-end X_shift-param.dev-paid-trans ~
X_shift-param.diff-cash-trk X_shift-param.disc-diff
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH X_shift-param NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 open query BROWSE-2 for each X_shift-param no-lock by X_shift-param.gds-code descending indexed-reposition.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 X_shift-param
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 shift-param


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-update B-print BROWSE-2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

function dev returns decimal
    (input p-type as character) forward .

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */

DEFINE BUTTON b-cancel AUTO-GO
    LABEL "&Выход" 
    SIZE 15 BY 1.
     
DEFINE BUTTON B-print 
    LABEL "Печать" 
    SIZE 10 BY 1.

DEFINE BUTTON B-update 
    LABEL "Указать расхождение" 
    SIZE 23 BY 1.
    
DEFINE BUTTON b-help 
    LABEL "Помощь":L 
    SIZE 7 BY 1.
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR 
    X_shift-param SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
    QUERY BROWSE-2 NO-LOCK DISPLAY
    X_shift-param.gds-code column-label "Код топлива" FORMAT ">>>>>999999999":U width 15
    X_shift-param.gds-name column-label "Наименование" FORMAT "X(48)":U width 20
    X_shift-param.loc1 column-label "№ резерв." FORMAT "X(8)":U width 10
    X_shift-param.system-cli-qnty column-label "Расч. остаток!на конец смены, кг" FORMAT "->>>>>>>>>>9.99":U width 20
    X_shift-param.fact-stock-end column-label "Факт. остаток!на конец смены, кг" FORMAT "->>>>>>>>>>9.99":U width 20
    X_shift-param.cash-qnty column-label "Объем продаж!на кассе, л" FORMAT "->>>>>>>>>>9.99":U width 15
    X_shift-param.meas-qnty column-label "Объем продаж!по счетчикам ТРК, л" FORMAT "->>>>>>>>>>9.99":U width 20
    X_shift-param.tech-refuell column-label "Техпролив, л" FORMAT "->>>>>>>>9.99":U width 15
    X_shift-param.dev-mass column-label "Допустимое!отклонение в кг" FORMAT "->>>>9.99":U width 15
    X_shift-param.diff-stock-end column-label "Факт отклонение по!остаткам в кг" FORMAT "->>>>>>>>>>>>>>>>>>>>>>>>>>9.99":U  width 20
    /*    X_shift-param.dev-paid-trans column-label "Допустимое!отклонение" FORMAT "->9.99":U  width 15*/
    X_shift-param.diff-cash-trk column-label "Разница по!кассе и ТРК, л" FORMAT "->>>>>>>>>>>>>>>>>9.99":U  width 15
    dev(p-type) column-label "Превышение допустимого!отклонения на, кг" FORMAT "->>>>>>>>>>>>>>>>>9.99":U  width 25   
    X_shift-param.disc-diffMass column-label "Причина расхождения/!номер заявки в ЦДС" format "X(256)":U  width 30
    X_shift-param.disc-diffTRK column-label "Причина расхождения/!номер заявки в ЦДС" format "X(256)":U  width 30
enable 
    X_shift-param.disc-diffMass
    X_shift-param.disc-diffTRK
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 106.5 BY 13.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
    B-print AT ROW 1.25 COL 107.5 RIGHT-ALIGNED WIDGET-ID 6
    b-cancel AT ROW 1.25 COL 2 WIDGET-ID 8
    B-update AT ROW 1.25 COL 17 WIDGET-ID 4    
    b-help AT ROW 1 COL 92.5
    BROWSE-2 AT ROW 2.5 COL 2 WIDGET-ID 200
    SPACE(0.49) SKIP(0.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
    TITLE "<insert dialog title>" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 B-print Dialog-Frame */
ASSIGN 
    FRAME Dialog-Frame:SCROLLABLE = FALSE
    FRAME Dialog-Frame:HIDDEN     = TRUE.
assign 
    BROWSE-2:column-resizable in frame Dialog-Frame = true .
/* SETTINGS FOR BUTTON B-print IN FRAME Dialog-Frame
   ALIGN-R                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _TblList          = "ub.shift-param,ub.goods OF ub.shift-param"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = ub.shift-param.gds-code
     _FldNameList[2]   = ub.shift-param.pl-code
     _FldNameList[3]   = ub.goods.gds-name
     _FldNameList[4]   = ub.shift-param.dev-mass
     _FldNameList[5]   = ub.shift-param.diff-stock-end
     _FldNameList[6]   = ub.shift-param.dev-paid-trans
     _FldNameList[7]   = ub.shift-param.diff-cash-trk
     _FldNameList[8]   = ub.shift-param.desc-diff
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выявленные отклонения */
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
    DO:
        run proc-b-print (p-type) no-error.
        if error-status:error then return no-apply.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Выход */
    DO:
        define variable v-close as logical no-undo .
        if p-mode <> {&lookup} then 
        do:
            case p-type: 
                when "diff-mass" then 
                    do:
                        find first X_shift-param where X_shift-param.disc-diffMass = "" and
                            X_shift-param.error-mass no-error .
                        if available (X_shift-param) then 
                        do:
                            message "Причина расхождения указана не для всех найденных отклонений." skip
                                "Отменить закрытие смены?"
                                view-as alert-box question buttons yes-no update v-close.
                            if not v-close then return no-apply .
                        end.
                        else p-ok = true .
                    end.    
                when "diff-TRK" then 
                    do:
                        find first X_shift-param where X_shift-param.disc-diffTRK = "" and
                            X_shift-param.error-paid-trans no-error .
                        if available (X_shift-param) then 
                        do:
                            message "Причина расхождения указана не для всех найденных отклонений." skip
                                "Отменить закрытие смены?"
                                view-as alert-box question buttons yes-no update v-close.
                            if not v-close then return no-apply .
                        end.
                        else p-ok = true .
                    end. 
            end case .
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-update Dialog-Frame
ON CHOOSE OF B-update IN FRAME Dialog-Frame /* Указать расхождение */
    DO:
        define buffer buf_shift-param for ub.shift-param .
        define variable row_param as rowid no-undo .
        if not available (X_shift-param) then 
        do:
            message "Не выбрана строка!"
                view-as alert-box.
            return .
        end.
        if p-type = "diff-mass" then 
        do:
            row_param = rowid(X_shift-param) .
            find first X_shift-param where rowid(X_shift-param) = row_param .
            run str/diffShift_Name.w (input-output X_shift-param.disc-diffMass
                ) no-error .  

            for first buf_shift-param exclusive-lock where buf_shift-param.obj-code = X_shift-param.obj-code and 
                buf_shift-param.obj-type = X_shift-param.obj-type and
                buf_shift-param.shift-date = X_shift-param.shift-date and
                buf_shift-param.shift-num = X_shift-param.shift-num and
                buf_shift-param.shift-name = X_shift-param.shift-name and
                buf_shift-param.gds-code = X_shift-param.gds-code and
                buf_shift-param.pl-code = X_shift-param.pl-code:
                buf_shift-param.disc-diffMass = X_shift-param.disc-diffMass .
            end.   
        end.
        else 
        do: 
            row_param = rowid(X_shift-param) .   
            find first X_shift-param where rowid(X_shift-param) = row_param .
            run str/diffShift_Name.w (input-output X_shift-param.disc-diffTRK
                ) no-error .

            for first buf_shift-param exclusive-lock where buf_shift-param.obj-code = X_shift-param.obj-code and 
                buf_shift-param.obj-type = X_shift-param.obj-type and
                buf_shift-param.shift-date = X_shift-param.shift-date and
                buf_shift-param.shift-num = X_shift-param.shift-num and
                buf_shift-param.shift-name = X_shift-param.shift-name and
                buf_shift-param.gds-code = X_shift-param.gds-code and
                buf_shift-param.pl-code = X_shift-param.pl-code:
                buf_shift-param.disc-diffTRK = X_shift-param.disc-diffTRK .
            end.
        end.
        run init-temp .
        BROWSE-2:refresh () no-error .
        reposition BROWSE-2 to rowid row_param no-error .
    /*        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}*/
     
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
ON row-leave OF BROWSE-2 IN FRAME Dialog-Frame /* Browse 2 */
    DO:
        define buffer bf_shift-param for ub.shift-param .
        find current X_shift-param exclusive-lock .
        
        assign browse BROWSE-2 
            X_shift-param.disc-diffMass
            X_shift-param.disc-diffTRK 
            .
        find first bf_shift-param exclusive-lock where bf_shift-param.obj-code = X_shift-param.obj-code and
            bf_shift-param.obj-type = X_shift-param.obj-type and
            bf_shift-param.shift-date = X_shift-param.shift-date and
            bf_shift-param.shift-num = X_shift-param.shift-num and
            bf_shift-param.shift-name = X_shift-param.shift-name and
            bf_shift-param.gds-code = X_shift-param.gds-code and
            bf_shift-param.pl-code = X_shift-param.pl-code no-error .
        if available (bf_shift-param) then 
        do:
            assign
                bf_shift-param.disc-diffMass = X_shift-param.disc-diffMass
                bf_shift-param.disc-diffTRK  = X_shift-param.disc-diffTRK
                .
            
        end.
        BROWSE-2:refresh () .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/app_help.i }
    case p-type:
        when "diff-mass" then 
            do:
                frame {&frame-name}:title = "Выявлены отклонения в 1 части сменного отчета".
            end.
        when "diff-TRK" then 
            do:
                frame {&frame-name}:title = "Выявлены отклонения в 9 части сменного отчета".
            end.
        otherwise 
        do:
            frame {&frame-name}:title = "Выявлены отклонения".
        end.
    end case .
    run init-temp.
    RUN enable_UI.

    if p-mode = {&lookup} then 
    do:
        p-ok = true .
        X_shift-param.disc-diffMass:column-read-only in browse {&browse-name} = true .
        X_shift-param.disc-diffTRK:column-read-only in browse {&browse-name} = true .
        disable
            B-update
            with frame {&frame-name} .
    end.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}  .


END.
RUN disable_UI.

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
    ENABLE b-cancel B-update B-print BROWSE-2 
        WITH FRAME Dialog-Frame.
    hide b-help in frame {&frame-name} .    
    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-temp Dialog-Frame 
PROCEDURE init-temp :
    define buffer buf_X_shift-param for X_shift-param .
    define buffer buf_shift-param   for ub.shift-param .
    define buffer buf_goods         for ub.goods .

    for each X_shift-param:
        delete X_shift-param .
    end.
    if p-type = "diff-TRK" then 
    do:
        for each buf_shift-param no-lock where buf_shift-param.obj-code = p-obj-code and 
            buf_shift-param.obj-type = p-obj-type and
            buf_shift-param.shift-date = p-shift-date and
            buf_shift-param.shift-num = p-shift-num and
            buf_shift-param.shift-name = p-shift-name and
            buf_shift-param.error-paid-trans
            :
            find first buf_goods no-lock where buf_goods.gds-code = buf_shift-param.gds-code no-error . 
            if available (buf_goods) then 
            do:
                create X_shift-param .
                buffer-copy buf_shift-param to X_shift-param .
                X_shift-param.gds-name = buf_goods.gds-name .
            end.
        end.        
    end.
    if p-type = "diff-mass" then 
    do:
        for each buf_shift-param no-lock where buf_shift-param.obj-code = p-obj-code and 
            buf_shift-param.obj-type = p-obj-type and
            buf_shift-param.shift-date = p-shift-date and
            buf_shift-param.shift-num = p-shift-num and
            buf_shift-param.shift-name = p-shift-name and
            buf_shift-param.error-mass
            :
            find first buf_goods no-lock where buf_goods.gds-code = buf_shift-param.gds-code no-error . 
            if available (buf_goods) then 
            do:
                create X_shift-param .
                buffer-copy buf_shift-param to X_shift-param .
                X_shift-param.gds-name = buf_goods.gds-name .
            end.
        end.        
    end.    
    if p-type = "diff-mass" then 
    do:
        X_shift-param.disc-diffTRK:visible IN BROWSE BROWSE-2 = FALSE.
        X_shift-param.cash-qnty:visible IN BROWSE BROWSE-2 = FALSE.
        X_shift-param.meas-qnty:visible IN BROWSE BROWSE-2 = FALSE.
        X_shift-param.tech-refuell:visible IN BROWSE BROWSE-2 = FALSE.
        X_shift-param.diff-cash-trk:visible IN BROWSE BROWSE-2 = FALSE.
        
    end .
    else 
    do:
        X_shift-param.diff-stock-end:visible IN BROWSE BROWSE-2 = FALSE.
        X_shift-param.dev-mass:visible IN BROWSE BROWSE-2 = FALSE.
        X_shift-param.disc-diffMass:visible IN BROWSE BROWSE-2 = FALSE.
        X_shift-param.system-cli-qnty:visible IN BROWSE BROWSE-2 = FALSE.
        X_shift-param.fact-stock-end:visible IN BROWSE BROWSE-2 = FALSE.
        

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

PROCEDURE proc-b-print :
    define input parameter v-type as character no-undo .
    define variable dev-paid-trans      as decimal   no-undo .
    define variable prc-dev-mass        as decimal   no-undo .
    define VARIABLE p-report-id         as character no-undo .
    define variable v-file-name-rep-htm as character no-undo .
    define buffer buf_shiftParam for ub.shift-param .
    define buffer buf_goods      for ub.goods .
    define buffer buf_susp-chk   for ub.susp-chk .
    define buffer bf_shift-obj   for ub.shift-obj .
    
    /*печать*/
    run get-report-num (output p-report-id).
    
    v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
    
    find first bf_shift-obj no-lock where bf_shift-obj.obj-code = p-obj-code and
        bf_shift-obj.obj-type = p-obj-type and
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
        '</thead>' skip .
  
    if v-type = "diff-mass" then 
    do:                         
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
            where buf_shiftParam.obj-code = p-obj-code
            and buf_shiftParam.obj-type = p-obj-type
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
            '</thead>' skip
            .
          
    end .
    else 
    do:

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
            '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver; width: 350px;">Причина расхождения/номер заявки в ЦДС</TD>' skip
            '</TR>'skip
            .
              
        for each buf_shiftParam no-lock 
            where buf_shiftParam.obj-code = p-obj-code
            and buf_shiftParam.obj-type = p-obj-type
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
                '<TD text_wrap="true">' + string(buf_shiftParam.disc-diffTRK) + '</TD>' skip
                '</tr>' skip
                .
        end.
        put stream OutStr-html unformatted
            '<thead>' skip
            '<TR style="height:25px;">' skip
            '<TD text_wrap="true" colspan="8" style="text-align: left;">*Допустимое отклонение между объемом продаж топлива на кассе и объемом по счетчикам ТРК = ' + string(dev-paid-trans,"9.99") + 'л</TD>' skip
            '</tr>' skip
            '<TR style="height:25px;">' skip
            '<TD text_wrap="true" colspan="8" style="text-align: left;"></TD>' skip
            '</tr>' skip         
            '<TR style="height:25px;">' skip
            '<TD text_wrap="true" colspan="8" style="text-align: left;"></TD>' skip
            '</tr>' skip  
            '</thead>' skip  
            .
        

    end.
 
     
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

function dev returns decimal
    (input v-type as character):
    if v-type = "diff-mass" then return absolut(X_shift-param.dev-mass - X_shift-param.diff-stock-end) .   
    else return absolut(X_shift-param.dev-paid-trans - X_shift-param.diff-cash-trk) .

end function.   