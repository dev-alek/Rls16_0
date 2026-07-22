&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME f-c-p


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf-code FOR Code.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS f-c-p 
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 1 февр. 2023 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 1 февр. 2023 г.

*/


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

{ref/codepar.i}

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Параметры группы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ ref/code-func.i }
if imode eq {&lookup}
then
   imode = {&update}.
/* Local Variable Definitions ---                                       */

define variable log-res  as log   no-undo.
define variable ri       as recid no-undo.
define variable v-rid    as recid no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define buffer b2-code for code .

find first b2-code where b2-code.parent eq iparent
                     and b2-code.code eq icode 
no-lock no-error.
&Scoped-define CODE_PARENT b2-code.parent + {&delim-par} + b2-code.code
&Scoped-define EditWhere and v-db-num = 0
&Scoped-define SearchTable  buf-code  
&Scoped-define SearchWhere  ~{&SearchTable~}.parent = ~{&CODE_PARENT~}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-c-p
&Scoped-define BROWSE-NAME BROWSE-Code

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf-code

/* Definitions for BROWSE BROWSE-Code                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-Code buf-code.misc1 buf-code.CodeValue 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-Code 
&Scoped-define QUERY-STRING-BROWSE-Code FOR EACH {&SearchTable} ~
      where {&SearchWhere}  ~
no-lock by buf-code.status_ by buf-code.code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-Code OPEN QUERY BROWSE-Code FOR EACH {&SearchTable} ~
      where {&SearchWhere}  ~
 NO-LOCK by buf-code.status_ by buf-code.code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-Code buf-code
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-Code buf-code


/* Definitions for DIALOG-BOX f-c-p                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-c-p ~
    ~{&OPEN-QUERY-BROWSE-Code}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-chiled b-upd b-add b-del b-print ~
b-hist b-help BROWSE-Code 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-name-doc Dialog-Frame
FUNCTION getKeyName RETURNS CHARACTER
   ( iCode as char   )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
   LABEL "&Выход ":L 
   SIZE 10 BY 1.

DEFINE BUTTON b-chiled  
   LABEL "&Открыть":L 
   SIZE 10 BY 1.
DEFINE BUTTON b-help 
     LABEL "Помо&щь":L 
     SIZE 3 BY 1.
define variable mSearch   as character       format "x(60)":U 
   label "Поиск" 
   view-as fill-in 
   size 60 by 1 no-undo.
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-Code FOR 
   buf-code SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-Code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-Code f-c-p _STRUCTURED
   QUERY BROWSE-Code NO-LOCK DISPLAY
   buf-code.code  FORMAT "x(20)":U WIDTH 32 
   getKeyName (buf-code.code) COLUMN-LABEL "Наименование" format "x(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 100.6 BY 20 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-c-p
   b-exit AT ROW 1 COL 1
   b-chiled AT ROW 1 COL 13.6
   b-help AT ROW 1 COL 71
   mSearch AT ROW 2.5 COL 1.2
   BROWSE-Code AT ROW 4 COL 1 WIDGET-ID 200
   SPACE(0.00) SKIP(0.04)
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
   SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
   TITLE "Функции":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: buf-code B "?" ? ub Code
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX f-c-p
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-Code b-help f-c-p */
ASSIGN 
   FRAME f-c-p:SCROLLABLE = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-Code
/* Query rebuild information for BROWSE BROWSE-Code
     _TblList          = "buf-code"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "buf-code.parent eq b2-code.parent + {&delim-par} + b2-code.code


"
     _FldNameList[1]   > Temp-Tables.buf-code.code
"buf-code.code" "Код" "x(20)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.buf-code.CodeValue
"buf-code.CodeValue" ? ? "character" ? ? ? ? ? ? no ? no no "58" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-Code */
&ANALYZE-RESUME



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME f-c-p
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-c-p f-c-p
ON GO OF FRAME f-c-p /* Значение ЕМЦ */
DO:
/*      p-rid = v-rid.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME





&Scoped-define SELF-NAME b-chiled
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chiled f-c-p
ON CHOOSE OF b-chiled IN FRAME f-c-p /* Выбор  */
   DO:
      define buffer b-code for code.
      if not avail buf-code then return.
      find first b-code of buf-code no-lock no-error.
      if avail b-code then do:
         v-rid = recid(b-code).
         define variable vProcNextLevel as character no-undo init "ref/cashparam.w".
         
/*         vProcNextLevel = getproceditEx(buffer b-code:handle,vProcNextLevel).*/
         define variable vListRecId as character no-undo.
         run value(vProcNextLevel) (
                                  input parparentproc
                                , input iMode
                                , input b-code.parent
                                , input b-code.code
                                , input ?
                                ).
         if ri <> ? then  do:
      
                  {&OPEN-QUERY-codebrow}
                  reposition {&browse-name} to recid ri.
                  apply "ENTRY" to {&browse-name}.
      
         end.
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-Code f-c-p
on mouse-select-dblclick of BROWSE-Code in frame f-c-p
or return of {&SELF-NAME} in frame {&FRAME-NAME}
do:
  apply "choose" to b-chiled in frame {&frame-name}.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME mSearch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mSearch f-c-p
on ENTER of mSearch in frame {&frame-name}
do:
   &Scoped-define SearchTable buf-code-search
   define buffer {&SearchTable} for ub.code.
   assign
     msearch
   .
   define variable vRec as recid no-undo init ?.
   block-code:
   for each {&SearchTable} where {&SearchWhere}  
   no-lock:
      if               {&SearchTable}.code  begins msearch 
         or getKeyName({&SearchTable}.code) begins msearch
      then do:
         vRec = recid({&SearchTable}).
         leave block-code.
      end.
   end.
   &Scoped-define SearchTable  {&INTERNAL-TABLES} 
   if vRec eq ?
   then do:
      message "Запись не найдена"
      view-as alert-box.
   end.
   else do:
      {&OPEN-QUERY-BROWSE-Code}
      reposition BROWSE-Code to recid vRec no-error .
      apply "ENTRY" to BROWSE-Code.
   end. 
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&Scoped-define BROWSE-NAME BROWSE-Code
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK f-c-p 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
   THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME}
   APPLY "END-ERROR":U TO SELF.
{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   run enable_UI in this-procedure .
   
   apply "ENTRY" to BROWSE-Code.
   WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI f-c-p  _DEFAULT-DISABLE
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
   HIDE FRAME f-c-p.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI f-c-p 
PROCEDURE enable_UI :
   /* --------------------------------------------------------------------
           Purpose:     ENABLE the User Interface
           Parameters:  <none>
           Notes:       Here we display/view/enable the widgets in the
                        user-interface.  In addition, OPEN all queries
                        associated with each FRAME and BROWSE.
                        These statements here are based on the "Other
                        Settings" section of the widget Property Sheets.
            -------------------------------------------------------------------- */
   ENABLE
      mSearch
      BROWSE-Code
      b-exit
      b-chiled
      WITH FRAME {&frame-name}.
    

   {&OPEN-BROWSERS-IN-QUERY-f-c-p}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getStatus f-c-p 
FUNCTION getKeyName RETURNS CHARACTER
   ( iCode as char):
   define buffer code for ub.code.
   find first code where code.parent eq "CashFunKey"
                     and code.code   eq iCode
   no-lock no-error.
   return if available code then code.codename else "".
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


