&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
{ str/temp_suspChk.i NEW }

DEFINE BUFFER c-doc FOR susp-chk.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision: 6557e99634e7, 3192, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:28 $
$Workfile: susp-chk.w $
$Archive: str/susp-chk.w $

Список подозрительных чеков

Автор: Шкляр Елена
Дата создания: 09/08/05
Author: Shklyar Elena
Creation date: 09/08/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode  as char   no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parshift-date as date no-undo .
define input parameter parshift-num as integer no-undo .
define input parameter parshift-name as character no-undo .
define output parameter table for c-doc.
define output parameter p-ok as logical no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: 6557e99634e7, 3192, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: EShklyar $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: 2022/12/27 12:54:28 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: susp-chk.w $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: str/susp-chk.w $":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список подозрительных чеков":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ rep/html-conv.i }
{ gbl/prn-lib.i   }

define stream Out-Stream .
define stream OutStr-html.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

function Str-chk-type returns character
    (input p-chk-type as character) forward .

function datetime_ returns character
    (input p-chk-date as date,
    input p-chk-time as integer) forward .
        
&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES c-doc

/* Definitions for BROWSE br-docs                                       */
&Scoped-define FIELDS-IN-QUERY-br-docs c-doc.office c-doc.doc-code ~
{&receipt-name} c-doc.chk-num c-doc.pay-desk c-doc.chk-date ~
c-doc.desc_ 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-docs 
&Scoped-define QUERY-STRING-br-docs FOR EACH c-doc where c-doc.obj-code = parobj-code and c-doc.obj-type = parobj-type and ~
c-doc.shift-date = parshift-date and c-doc.shift-num = parshift-num and c-doc.shift-name = parshift-name NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-docs OPEN QUERY br-docs FOR EACH c-doc where c-doc.obj-code = parobj-code and c-doc.obj-type = parobj-type and ~
c-doc.shift-date = parshift-date and c-doc.shift-num = parshift-num and c-doc.shift-name = parshift-name NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-docs c-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-docs c-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-docs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-lookup B-chg B-print br-docs 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-chg 
    LABEL "&Указать причину" 
    SIZE 20 BY 1 TOOLTIP "Указать причину".

DEFINE BUTTON B-lookup 
    LABEL "&Просмотр" 
    SIZE 10 BY 1 TOOLTIP "Просмотр чека".

DEFINE BUTTON B-print 
    LABEL "Пе&чать" 
    SIZE 3 BY 1 TOOLTIP "Печать списка чеков, списка строк по всем чекам, списка оплат ...".

DEFINE BUTTON b-quit AUTO-go 
    LABEL "&Выход" 
    SIZE 10 BY 1
    BGCOLOR 8 .

DEFINE BUTTON b-help 
    LABEL "Помощь":L 
    SIZE 7 BY 1.
     
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-docs FOR 
    c-doc SCROLLING.
&ANALYZE-RESUME
&scop receipt-code string(c-doc.chk-type)
/* Browse definitions                                                   */
DEFINE BROWSE br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-docs Dialog-Frame _STRUCTURED
    QUERY br-docs NO-LOCK DISPLAY
    c-doc.office COLUMN-LABEL "Признак" FORMAT "X(256)":U
    WIDTH 20
    c-doc.doc-code COLUMN-LABEL "№ чека в ТН" FORMAT "X(20)":U
    {&receipt-name} COLUMN-LABEL "Тип чека" FORMAT "X(20)":U WIDTH 15
    c-doc.chk-num COLUMN-LABEL "№ чека!на кассе" FORMAT ">>>>>>>>>>9":U
    WIDTH 12
    c-doc.pay-desk COLUMN-LABEL "№ кассы" FORMAT ">>>9":U WIDTH 10
    datetime_(c-doc.chk-date, c-doc.chk-time) COLUMN-LABEL "Дата/время" FORMAT "X(20)":U WIDTH 20
    c-doc.reason-name COLUMN-LABEL "Причина возникновения чека" FORMAT "x(250)":U WIDTH 40
    c-doc.link-chk COLUMN-LABEL 'Ссылка на "корректный" чек' FORMAT "x(250)":U WIDTH 40
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 16.5 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
    b-quit AT ROW 1 COL 1
    B-lookup AT ROW 1 COL 11
    B-chg AT ROW 1 COL 21
    B-print AT ROW 1 COL 95.5
    br-docs AT ROW 2 COL 1 WIDGET-ID 100
    b-help AT ROW 1 COL 92.5
    SPACE(0.50) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
    TITLE "Подозрительные чеки"
    CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_dis-card B "?" ? ub dis-card
      TABLE: buf_icnt-doc B "?" ? ub icnt-doc
      TABLE: buf_inkas B "?" ? ub inkas
      TABLE: buf_obj B "?" ? ub clients
      TABLE: buf_shop B "?" ? ub shop
      TABLE: buf_trn-doc B "?" ? ub trn-doc
      TABLE: buf_wth-doc B "?" ? ub wth-doc
      TABLE: c-doc B "?" ? ub chk-doc
      TABLE: dis-obj B "?" ? ub dis-obj
      TABLE: find_chk-doc B "?" ? ub chk-doc
      TABLE: find_inkas B "?" ? ub inkas
      TABLE: find_trn-doc B "?" ? ub trn-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-docs B-print Dialog-Frame */
ASSIGN 
    FRAME Dialog-Frame:SCROLLABLE = FALSE
    FRAME Dialog-Frame:HIDDEN     = TRUE.


ASSIGN 
    br-docs:COLUMN-RESIZABLE IN FRAME Dialog-Frame = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-docs
/* Query rebuild information for BROWSE br-docs
     _TblList          = "ub.c-doc"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > ub.c-doc.office
"office" "Тип ошибки" "X(256)" "character" ? ? ? ? ? ? no ? no no "15" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > ub.c-doc.doc-code
"doc-code" "Номер чека" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > ub.c-doc.chk-type
"chk-type" ? ? "integer" ? ? ? ? ? ? no ? no no "15" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > ub.c-doc.chk-num
"chk-num" "№ на кассе" ? "integer" ? ? ? ? ? ? no ? no no "10" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   = ub.c-doc.pay-desk
     _FldNameList[6]   = ub.c-doc.chk-date
     _FldNameList[7]   > ub.c-doc.desc_
"desc_" "Причина" ? "character" ? ? ? ? ? ? no ? no no "16.63" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-docs */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Подозрительные чеки */
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
    DO:
        run proc-b-print in this-procedure no-error.
        if error-status:error then return no-apply.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
    DO:
        define variable v-close as logical no-undo .
        if par-mode <> {&lookup} then 
        do:
            find first c-doc where c-doc.reason-name = "" no-error .
            if available (c-doc) then 
            do:
                message "Причина указана не для всех найденных чеков." skip
                    "Отменить закрытие смены?"
                    view-as alert-box question buttons yes-no update v-close.
                if not v-close then return no-apply .
                else 
                do:
                    empty temp-table tt-susp-chk .
                    for each ub.susp-chk no-lock where ub.susp-chk.obj-code = parobj-code and
                        ub.susp-chk.obj-type = parobj-type and
                        ub.susp-chk.shift-date = parshift-date and
                        ub.susp-chk.shift-num = parshift-num and
                        ub.susp-chk.shift-name = parshift-name:
                        create tt-susp-chk .
                        buffer-copy ub.susp-chk to tt-susp-chk .
                    end.                    
                end.
            end.
            else p-ok = true .
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
    DO:
        define variable next-prev as character no-undo .
        define variable v-doc-rec as recid     no-undo .
        define buffer buf_chk-doc for ub.chk-doc .
        define variable reason-name as character no-undo .
        define variable link-chk as character no-undo .
        
            if NOT available c-doc then 
            do:
                message "Неправильно выбран чек." view-as alert-box ERROR.
                return no-apply.
            end.
            if available (c-doc) then 
            do:    
                v-doc-rec = recid(c-doc).
                run str/diffSuspChk.w
                    (input parparentproc
                    ,input-output v-doc-rec
                    ,output reason-name
                    ,output link-chk
                    )
                    .
                    
                    find first ub.susp-chk exclusive-lock where recid(ub.susp-chk) = v-doc-rec no-error .
                    if available (ub.susp-chk) then do:
                        ub.susp-chk.reason-name = reason-name .
                        ub.susp-chk.link-chk = link-chk .
                    end.
            end.
            else 
            do:
                message "Неправильно выбран чек." view-as alert-box ERROR.
                return no-apply.
            end.
/*        END .*/
        br-docs:refresh () .

    /*        apply "entry" to br-docs in frame {&frame-name}.        */
    /*        apply "value-changed" to br-docs in frame {&frame-name}.*/
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
    DO:
        define variable next-prev as character no-undo .
        define variable v-doc-rec as recid     no-undo .
        define buffer buf_chk-doc for ub.chk-doc .
        assign
            next-prev = '':U
            .
        DO WHILE next-prev = '':U:
            if NOT available c-doc then 
            do:
                message "Неправильно выбран чек." view-as alert-box ERROR.
                return no-apply.
            end.
            find first buf_chk-doc no-lock where buf_chk-doc.doc-code = c-doc.doc-code no-error .
            if available (buf_chk-doc) then 
            do:    
                v-doc-rec = recid(buf_chk-doc).
                run str/superchk.w
                    (input parparentproc
                    ,input {&lookup}
                    ,input buf_chk-doc.obj-type
                    ,input buf_chk-doc.obj-code
                    ,input-output v-doc-rec
                    ,input this-procedure:handle
                    ,input-output next-prev
                    )
                    .
            end.
            else 
            do:
                message "Неправильно выбран чек." view-as alert-box ERROR.
                return no-apply.
            end.
        END .

        apply "entry" to br-docs in frame {&frame-name}.
        apply "value-changed" to br-docs in frame {&frame-name}.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-docs
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/brwrepos.i
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    /*                    { gbl/getcntxt.i get }*/
    { gbl/app_help.i }

    run enable_UI .
    if par-mode = {&lookup} then 
    do:
        p-ok = true .
        disable B-chg with frame {&frame-name} .
    end.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

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
    ENABLE b-quit B-lookup B-chg B-print br-docs 
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc Dialog-Frame 
PROCEDURE PrintProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame 
PROCEDURE proc-b-chg :
/*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-chk-doc Dialog-Frame 
PROCEDURE reposition-chk-doc :
    define input  parameter p-direction   as character no-undo .
    define output parameter p-chk-doc-recid as recid no-undo .
    define buffer buf_chk-doc for ub.chk-doc .
    /* перемещение на первую, последнюю, предыдущую, следующую */
    case p-direction :
        when "first":U
        then 
            do:
                get first br-docs.
            end.
        when "last":U
        then 
            do:
                get last br-docs.
            end.
        when "prev":U
        then 
            do:
                get prev br-docs.
                if not available c-doc then 
                do:
                    message
                        "Это первый чек списка"
                        view-as alert-box.
                end.
            end.
        when "next":U
        then 
            do:
                get next br-docs.
                if not available c-doc then 
                do:
                    message
                        "Это последний чек списка"
                        view-as alert-box.
                end.
            end.
    end case . /* p-direction */
    find first buf_chk-doc no-lock where buf_chk-doc.doc-code = c-doc.doc-code no-error .
    if available (buf_chk-doc) then 
    do:    
        assign
            p-chk-doc-recid = recid(buf_chk-doc)
            .
        run reposition-query in this-procedure
            (input p-chk-doc-recid
            ).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame 
PROCEDURE reposition-query :
    define input parameter p-recid as recid no-undo .
    define variable p-rec as recid no-undo .
    define buffer buf_chk-doc for ub.chk-doc .
    if p-recid <> ?
        then 
    do:
        find first buf_chk-doc no-lock where recid (buf_chk-doc) = p-recid .
        find first c-doc no-lock where c-doc.doc-code = buf_chk-doc.doc-code .
        p-rec = recid (c-doc) .
        reposition br-docs to recid p-rec no-error.
    end.

    do with frame {&frame-name}:
        apply "entry":u to browse {&browse-name} .
        apply "VALUE-CHANGED":u to browse {&browse-name} .
    end. /* do with frame */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


PROCEDURE proc-b-print :

    define VARIABLE p-report-id         as character no-undo .
    define variable v-file-name-rep-htm as character no-undo .
    define buffer buf_shiftParam for ub.shift-param .
    define buffer buf_goods      for ub.goods .
    define buffer buf_susp-chk   for ub.susp-chk .
    define buffer bf_shift-obj   for ub.shift-obj .
    /*печать*/
    run get-report-num (output p-report-id).
    
    v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   

    find first bf_shift-obj no-lock where bf_shift-obj.obj-code = parobj-code and
        bf_shift-obj.obj-type = parobj-type and
        bf_shift-obj.shift-date = parshift-date and 
        bf_shift-obj.Shift-num = parshift-num no-error .
    if not available (bf_shift-obj) then return error.
    
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
        where buf_susp-chk.obj-code = parobj-code
        and buf_susp-chk.obj-type = parobj-type
        and buf_susp-chk.shift-date = parshift-date
        and buf_susp-chk.shift-num = parshift-num:       

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

function datetime_ returns character
    (input p-chk-date as date, input p-chk-time as integer):
    define variable p-datetime as character no-undo .

    p-datetime = string(p-chk-date,"99.99.9999") + " " + string(p-chk-time,"HH:MM") .
    return p-datetime .

end function. 