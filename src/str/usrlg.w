&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История пользователя - просмотр

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/04/08
Author: Victor Guntner
Creation date: 04/04/08

Input:

Output:

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define temp-table temp_userhist no-undo
    field ush-key  as integer
    field ushDate  as date
    field ushtime  as integer
    field ushTable as character
    field ushDesc  as character

    index pi is primary unique
    ush-key
    .
define temp-table temp_userhist-line no-undo
    field usl-key as integer
    field ush-key as integer
    field uslDesc as character

    index pi is primary unique
    usl-key
    .

define temp-table tt-field no-undo 
    field f-name  as character
    field f-table as character. 


define variable v-usrlg-ush-key as integer no-undo.
define variable v-usrlg-usl-key as integer no-undo.

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as handle           no-undo.
define input parameter p-userid         as character        no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История пользователя - просмотр".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/key-rec.i  }
{ cmp/showinf.i  }
{ cmp/tblfname.i }
{ gbl/prn-lib.i }
define variable v-c-table as character no-undo .
define variable v-table   as character no-undo .
  
define buffer buf_head_c-user-log for c-user-log.
define buffer buf_line_c-user-log for c-user-log.

define stream out-stream.
define stream OutStr-html.

define variable p-report-id             as integer   no-undo .
define variable v-report-name-html      as CHARACTER no-undo .
define variable v-report-name-html-list as CHARACTER no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-head

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_head_c-user-log

/* Definitions for BROWSE br-head                                       */
&Scoped-define FIELDS-IN-QUERY-br-head buf_head_c-user-log.corr-date string( buf_head_c-user-log.corr-time, "hh:mm:ss" ) buf_head_c-user-log.des buf_head_c-user-log.head-table get-unique-key( buf_head_c-user-log.head-table,buf_head_c-user-log.uniq-key-rec )   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-head   
&Scoped-define SELF-NAME br-head
&Scoped-define OPEN-QUERY-br-head run local-open-query-head in this-procedure. /* OPEN QUERY {&SELF-NAME} FOR EACH buf_head_c-user-log NO-LOCK INDEXED-REPOSITION. */.
&Scoped-define TABLES-IN-QUERY-br-head buf_head_c-user-log
&Scoped-define FIRST-TABLE-IN-QUERY-br-head buf_head_c-user-log


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-head}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel fi-date-to fi-date-for ~
cb-table bt-doc-hist b-print b-help br-head 
&Scoped-Define DISPLAYED-OBJECTS fi-date-to fi-date-for cb-table 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-unique-key Dialog-Frame 
FUNCTION get-unique-key RETURNS CHARACTER
    ( p-head-table as character,
      p-unique-key-rec as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY 
    LABEL "&Отмена" 
    SIZE 10 BY 1
    BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO 
    LABEL "В&ыход" 
    SIZE 10 BY 1
    BGCOLOR 8 .

DEFINE BUTTON b-help 
    LABEL "Помо&щь" 
    SIZE 3 BY 1
    BGCOLOR 8 .

DEFINE BUTTON b-print 
    LABEL "Печать" 
    SIZE 3 BY 1.

DEFINE BUTTON bt-doc-hist 
    LABEL "Просмотр" 
    SIZE 10 BY 1.

DEFINE VARIABLE cb-table    AS CHARACTER FORMAT "X(256)":U 
    LABEL "Объект" 
    VIEW-AS COMBO-BOX INNER-LINES 15
    DROP-DOWN-LIST
    SIZE 22.75 BY 1 NO-UNDO.

DEFINE VARIABLE fi-date-for AS DATE      FORMAT "99.99.9999":U 
    LABEL "по" 
    VIEW-AS FILL-IN 
    SIZE 12.63 BY 1 NO-UNDO.

DEFINE VARIABLE fi-date-to  AS DATE      FORMAT "99.99.9999":U 
    LABEL "Даты с" 
    VIEW-AS FILL-IN 
    SIZE 12.63 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-head FOR 
    buf_head_c-user-log SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-head
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-head Dialog-Frame _FREEFORM
    QUERY br-head NO-LOCK DISPLAY
    buf_head_c-user-log.corr-date FORMAT "99.99.9999":U
    string( buf_head_c-user-log.corr-time, "hh:mm:ss" ) FORMAT "X(9)":U column-label "Время"
    buf_head_c-user-log.des FORMAT "x(256)":U width 40
    buf_head_c-user-log.head-table FORMAT "x(15)":U      
    get-unique-key( buf_head_c-user-log.head-table, buf_head_c-user-log.uniq-key-rec ) FORMAT "x(40)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 104 BY 21 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
    b-exit AT ROW 1 COL 1
    b-cancel AT ROW 1 COL 11
    fi-date-to AT ROW 1 COL 27.5 COLON-ALIGNED WIDGET-ID 2
    fi-date-for AT ROW 1 COL 44.63 COLON-ALIGNED WIDGET-ID 10
    cb-table AT ROW 1 COL 65.75 COLON-ALIGNED WIDGET-ID 8
    bt-doc-hist AT ROW 1 COL 91 WIDGET-ID 4
    b-print AT ROW 1 COL 101.5 WIDGET-ID 62
    b-help AT ROW 1 COL 102.25 WIDGET-ID 64
    br-head AT ROW 2.25 COL 1 WIDGET-ID 200
    SPACE(0.74) SKIP(0.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
    TITLE "История действий пользователя"
    CANCEL-BUTTON b-cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-head b-help Dialog-Frame */
ASSIGN 
    FRAME Dialog-Frame:SCROLLABLE = FALSE
    FRAME Dialog-Frame:HIDDEN     = TRUE.

ASSIGN 
    br-head:COLUMN-RESIZABLE IN FRAME Dialog-Frame = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-head
/* Query rebuild information for BROWSE br-head
     _START_FREEFORM
run local-open-query-head in this-procedure. /* OPEN QUERY {&SELF-NAME} FOR EACH buf_head_c-user-log NO-LOCK INDEXED-REPOSITION. */
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-head */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История действий пользователя */
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
    DO:
        { gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
    DO:
        run get-report-num in parParentProc (
            output p-report-id
            ).

        v-report-name-html-list = session:temp-directory + {&DF_Name} + string(p-report-id) + ".html". /*формирование имя файла для часть1*/        
    
        run PROC-print-list in this-procedure.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-head
&Scoped-define SELF-NAME br-head
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-head Dialog-Frame
ON VALUE-CHANGED OF br-head IN FRAME Dialog-Frame
    DO:
        {&OPEN-QUERY-br-line}
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-doc-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-doc-hist Dialog-Frame
ON CHOOSE OF bt-doc-hist IN FRAME Dialog-Frame /* Просмотр */
    DO:
        if available buf_head_c-user-log
            then 
        do:
            run str/usrlgd.p (
                input parparentproc
                , input buf_head_c-user-log.head-table
                , input buf_head_c-user-log.head-table-key
                ) .
            if error-status :error
                then 
            do:
                message
                    vss-workfile vss-revision vss-description
                    skip(1)
                    skip 
                    "Ошибка вызова истории по документу"
                    skip return-value
                    skip trim( error-status :get-message( 1 ) )
                    trim( error-status :get-message( 2 ) )
                    trim( error-status :get-message( 3 ) )
                    view-as alert-box error.
                undo, return no-apply substitute( "Ошибка вызова истории по документу. &1. &2"
                    , return-value
                    , trim( error-status :get-message( 1 ) ) ).
            end.
        end.
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-table Dialog-Frame
ON VALUE-CHANGED OF cb-table IN FRAME Dialog-Frame /* Объект */
    DO:
        assign
            v-table   = ""
            v-c-table = ""
            .
        assign
            cb-table.
        if cb-table = "все" then v-table = "" .
        else 
        do:
            find first tt-field no-lock where tt-field.f-name = cb-table no-error .
            if AVAILABLE (tt-field) then 
            do:
                v-table = tt-field.f-table .
                v-c-table = "c-" + tt-field.f-table .
            end.    
        end.

        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-date-for
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-date-for Dialog-Frame
ON RETURN OF fi-date-for IN FRAME Dialog-Frame /* по */
    DO:
        assign
            fi-date-for
            .
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-date-to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-date-to Dialog-Frame
ON RETURN OF fi-date-to IN FRAME Dialog-Frame /* Даты с */
    DO:
        assign
            fi-date-to
            .
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */


{ gbl/ed_date.i fi-date-to }
{ gbl/ed_date.i fi-date-for }
{ gbl/app_help.i }
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run init-fields in this-procedure .
    RUN enable_UI.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
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
    DISPLAY fi-date-to fi-date-for cb-table 
        WITH FRAME Dialog-Frame.
    ENABLE b-exit b-cancel fi-date-to fi-date-for cb-table bt-doc-hist b-print 
        b-help br-head 
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-unique-key-proc Dialog-Frame 
PROCEDURE get-unique-key-proc :
    /*------------------------------------------------------------------------------
          Purpose:
          Parameters:  <none>
          Notes:
        ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER p-unique-key-rec    AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER p-unique-key-string AS CHARACTER   NO-UNDO.

    define variable v-field-list        as character    no-undo.
    define variable v-field-value-list  as character    no-undo.
do
on error undo, return error
:
    run gen-key-fv in this-procedure (
          input p-unique-key-rec
        , output v-field-list
        , output v-field-value-list
    ) no-error.
    if error-status:error
    then
       assign
          p-unique-key-rec = substring (p-unique-key-rec, index(p-unique-key-rec,{&delim-key}) + 1 )
          p-unique-key-string = replace( p-unique-key-rec, {&delim-key}, ",":U )
       .
    else
       assign
           p-unique-key-string = replace( v-field-value-list, {&delim-key}, ",":U )
       .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame 
PROCEDURE init-fields :
    /*------------------------------------------------------------------------------
          Purpose:
          Parameters:  <none>
          Notes:
        ------------------------------------------------------------------------------*/
    do
        with frame {&frame-name}
        on error undo, return error
        :
        define VARIABLE v-head-table as character no-undo .

        if fi-date-for = ? then fi-date-for = today .
        if fi-date-to = ? then fi-date-to = today - 30 .
  
        define BUFFER bf_c-user-log for ub.c-user-log .
        define variable v-user-table-name as character no-undo .
        define variable v-user-table      as character no-undo .
        define variable v-table           as character no-undo .
        
        for each bf_c-user-log no-lock where bf_c-user-log.corr-date > fi-date-to  and bf_c-user-log.corr-date <= fi-date-for and bf_c-user-log.corr-user-name = p-userid by bf_c-user-log.head-table :
            v-table = bf_c-user-log.head-table .
            if v-table begins "c-" and v-table <> {&table_c-usr-hist} and v-table <> {&table_c-plc-hist} then 
            do:
                v-user-table = replace(v-table,"c-","").
            end.
            else v-user-table = v-table .    
            find first tt-field where tt-field.f-table = v-user-table no-error .
            if not AVAILABLE (tt-field) then 
            do:
                { gbl/tblnmusr.i
                    v-user-table
                    v-user-table-name
                  }
                create tt-field .
                assign
                    tt-field.f-table = v-user-table 
                    tt-field.f-name  = v-user-table-name
                    .    
            end.  
        end.   

        cb-table:LIST-ITEMS = "ВСЕ" .

        for each tt-field NO-LOCK by tt-field.f-name:
            assign
                cb-table :list-items = substitute( "&2&1&3"
                                       , ","
                                       , cb-table :list-items
                                       , tt-field.f-name
                                                   
                                                   )
                .

 
        end.
    end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query-head Dialog-Frame 
PROCEDURE local-open-query-head :
    /*------------------------------------------------------------------------------
          Purpose:
          Parameters:  <none>
          Notes:
        ------------------------------------------------------------------------------*/
    do
        on error undo, return error
        :
if v-c-table eq "c-usr-hist"
then
    OPEN QUERY br-head
      FOR EACH buf_head_c-user-log NO-LOCK
         where buf_head_c-user-log.corr-user-name = p-userid
           and buf_head_c-user-log.corr-date     >= ( if fi-date-to  = ? then 12/31/2000 else fi-date-to )
           and buf_head_c-user-log.corr-date     <= ( if fi-date-for = ? then 12/31/3000 else fi-date-for )
/*           and buf_head_c-user-log.head-table-key = buf_head_c-user-log.uniq-key-rec*/
           and (buf_head_c-user-log.head-table = v-c-table or buf_head_c-user-log.head-table = v-table)
      by buf_head_c-user-log.corr-date descending
      by buf_head_c-user-log.corr-time descending
    INDEXED-REPOSITION.
 
else
        if v-table <> "" or v-c-table <> "" then 
        do:
            OPEN QUERY br-head
                FOR EACH buf_head_c-user-log NO-LOCK
                where buf_head_c-user-log.corr-user-name = p-userid
                and buf_head_c-user-log.corr-date     >= ( if fi-date-to = ? then today - 30 else fi-date-to )
                and buf_head_c-user-log.corr-date <= (if fi-date-for = ? then today else fi-date-for)
                and buf_head_c-user-log.head-table-key = buf_head_c-user-log.uniq-key-rec
                and (buf_head_c-user-log.head-table = v-c-table or buf_head_c-user-log.head-table = v-table)
                by buf_head_c-user-log.corr-date descending
                by buf_head_c-user-log.corr-time descending
                INDEXED-REPOSITION.
        end.
        else 
        do:
            OPEN QUERY br-head
                FOR EACH buf_head_c-user-log NO-LOCK
                where buf_head_c-user-log.corr-user-name = p-userid
                and buf_head_c-user-log.corr-date     >= ( if fi-date-to = ? then today - 30 else fi-date-to )
                and buf_head_c-user-log.corr-date <= (if fi-date-for = ? then today else fi-date-for)
                and buf_head_c-user-log.head-table-key = buf_head_c-user-log.uniq-key-rec
                by buf_head_c-user-log.corr-date descending
                by buf_head_c-user-log.corr-time descending
                INDEXED-REPOSITION.
        end.                
    end.
      

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-list Dialog-Frame 
PROCEDURE proc-print-list :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    define buffer buf_c-user-log for ub.c-user-log .
    do
        on error undo, return error
        :
            
        /*вызов процедуры печати шапки отчета*/      
        output stream OutStr-html to value(v-report-name-html-list) convert target 'UTF-8'.
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
            '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
            '<thead>' skip
            .
        put stream OutStr-html unformatted
            '<tr>' skip
            '<td style="width: 150px;"></td>' skip
            '<td style="width: 150px;"></td>' skip
            '<td style="width: 150px;"></td>' skip
            '<td style="width: 180px;"></td>' skip
            '<td style="width: 180px;"></td>' skip
            '</tr>' skip
            .
                        
 
        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="5" style="text-align: center;">История действий пользователя за период с ' + string(fi-date-to,"99.99.99") + ' по ' + string(fi-date-for,"99.99.99") + ' </td>' skip
            '</tr>' skip   
            '</thead>' skip .
    
        put stream OutStr-html unformatted
            '<tbody>' skip
            '<TR>' skip
            '<TD text_wrap="true" style="text-align: center;">Дата</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">Время</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">Описание</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">Объект</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">Информация</TD>' skip
            '</TR>'skip       
           
            .
    
        if v-table <> "" or v-c-table <> "" then 
        do:
            FOR EACH buf_c-user-log NO-LOCK
                where buf_c-user-log.corr-user-name = p-userid
                and buf_c-user-log.corr-date     >= ( if fi-date-to = ? then today - 30 else fi-date-to )
                and buf_c-user-log.corr-date <= (if fi-date-for = ? then today else fi-date-for)
                and buf_c-user-log.head-table-key = buf_c-user-log.uniq-key-rec
                and (buf_c-user-log.head-table = v-c-table or buf_c-user-log.head-table = v-table)
                by buf_c-user-log.corr-date descending
                by buf_c-user-log.corr-time descending:
                    
                put stream OutStr-html unformatted
                    '<TR>' skip
                    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-user-log.corr-date,"99.99.9999") + '</TD>' skip
                    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-user-log.corr-time,"hh:mm:ss") + '</TD>' skip
                    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-user-log.des) + '</TD>' skip
                    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-user-log.head-table) + '</TD>' skip
                    '<TD text_wrap="true" style="text-align: center;">' + STRING (buf_c-user-log.uniq-key-rec) + '</TD>' skip
                    '</TR>'skip                       
                    .  
            end.    

        end.
        else 
        do:
            FOR EACH buf_c-user-log NO-LOCK
                where buf_c-user-log.corr-user-name = p-userid
                and buf_c-user-log.corr-date     >= ( if fi-date-to = ? then today - 30 else fi-date-to )
                and buf_c-user-log.corr-date <= (if fi-date-for = ? then today else fi-date-for)
                and buf_c-user-log.head-table-key = buf_c-user-log.uniq-key-rec
                by buf_c-user-log.corr-date descending
                by buf_c-user-log.corr-time descending:
                put stream OutStr-html unformatted
                    '<TR>' skip
                    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-user-log.corr-date,"99.99.9999") + '</TD>' skip
                    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-user-log.corr-time,"hh:mm:ss") + '</TD>' skip
                    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-user-log.des) + '</TD>' skip
                    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-user-log.head-table) + '</TD>' skip
                    '<TD text_wrap="true" style="text-align: center;">' + STRING (buf_c-user-log.uniq-key-rec) + '</TD>' skip
                    '</TR>'skip                       
                    .  
            end.

        end.    
    

        output stream OutStr-html close.   
 


        /*вызов программы печати*/ 
        run prn-lib-reportviewer-report-name in this-procedure (
            input parParentProc
            ,input v-report-name-html-list
            ).


    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-unique-key Dialog-Frame 
FUNCTION get-unique-key RETURNS CHARACTER
    ( p-head-table as character,
      p-unique-key-rec as character ) :
    /*------------------------------------------------------------------------------
      Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    DEFINE variable v-unique-key-string AS CHARACTER NO-UNDO.
    if p-unique-key-rec begins 'report':U 
        or p-unique-key-rec begins 'utl':U  
        or p-head-table begins 'run-proc':U  
        or p-head-table begins 'run_proc':U
        or p-head-table begins 'sysadm-pwd':U
        or p-head-table begins 'one-pwd':U
        or p-head-table begins 'MEASURER_PAR':U
        or p-head-table begins 'atd-alarm-sched':U
        or p-unique-key-rec begins 'prtdoc:':U  then return p-unique-key-rec.
    run get-unique-key-proc in this-procedure (
        input p-unique-key-rec
        , output v-unique-key-string
        ).
    RETURN v-unique-key-string.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

