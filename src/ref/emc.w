&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME f-okei2


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf-code FOR Code.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS f-okei2 
/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Код ОКЕИ код ККТ

Автор: Рукавишников Вадим
Дата создания: 21/04/21
Author: Rukavishnikov Vadim
Creation date: 21/04/21

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

{ ref/codepar.i}

define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Код ОКЕИ код ККТ".
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

&Scoped-define BEF_CODE_PARENT EMC
&Scoped-define CODE_PARENT "{&BEF_CODE_PARENT}"

/* Local Variable Definitions ---                                       */

define variable log-res     as log       no-undo.
define variable ri          as recid     no-undo.
define variable v-rid       as recid     no-undo .
define variable v-db-num like ub.db.db-num no-undo .


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-okei2
&Scoped-define BROWSE-NAME BROWSE-5

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Code

/* Definitions for BROWSE BROWSE-5                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-5 Code.code Code.CodeName 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-5 
&Scoped-define QUERY-STRING-BROWSE-5 FOR EACH Code ~
      WHERE Code.parent = "{&BEF_CODE_PARENT}" NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-5 OPEN QUERY BROWSE-5 FOR EACH Code ~
      WHERE Code.parent = "{&BEF_CODE_PARENT}" NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-5 Code
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-5 Code


/* Definitions for DIALOG-BOX f-okei2                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-okei2 ~
    ~{&OPEN-QUERY-BROWSE-5}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-add b-del b-upd b-print ~
b-hist b-help b-add2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-add2 
     LABEL "Значение ЕМЦ" 
     SIZE 15 BY 1.

DEFINE BUTTON b-del 
     LABEL "&Удалить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-hist 
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON b-print 
     LABEL "Пе&чать":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-upd 
     LABEL "&Изменить":L 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-5 FOR 
      Code SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-5 f-okei2 _STRUCTURED
  QUERY BROWSE-5 NO-LOCK DISPLAY
      Code.code FORMAT "x(8)":U
      Code.CodeName FORMAT "x(60)":U WIDTH 54.13
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 73 BY 11 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-okei2
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 14
     b-add AT ROW 1 COL 24
     b-del AT ROW 1 COL 34 WIDGET-ID 2
     b-upd AT ROW 1 COL 44.13
     b-print AT ROW 1 COL 65
     b-help AT ROW 1 COL 71
     b-add2 AT ROW 2.25 COL 14.13 WIDGET-ID 10
     BROWSE-5 AT ROW 4 COL 1 WIDGET-ID 300
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Тип ЕМЦ":L.


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
/* SETTINGS FOR DIALOG-BOX f-okei2
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-5 b-add2 f-okei2 */
ASSIGN 
       FRAME f-okei2:SCROLLABLE       = FALSE.

/* SETTINGS FOR BROWSE BROWSE-5 IN FRAME f-okei2
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-5
/* Query rebuild information for BROWSE BROWSE-5
     _TblList          = "ub.Code"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "Code.parent = ""{&BEF_CODE_PARENT}"""
     _FldNameList[1]   = ub.Code.code
     _FldNameList[2]   > ub.Code.CodeName
"CodeName" ? ? "character" ? ? ? ? ? ? no ? no no "54.13" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BROWSE-5 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME f-okei2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-okei2 f-okei2
ON go OF FRAME f-okei2 /* Тип ЕМЦ */
do:
/*    p-rid = v-rid.*/
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add f-okei2
ON choose OF b-add IN FRAME f-okei2 /* Добавить */
do:
   define buffer b1-code for code.
   define buffer btt-code for code.
   define variable vRec as recid no-undo.
   define variable v-ok as logical no-undo.

   run ref/emc-add.w (
                            input parparentproc
                          , input {&add-def}
                          , input-output ri).
   if ri <> ? then  do:
         {&OPEN-QUERY-BROWSE-5}
         reposition BROWSE-5 to recid ri.
         apply "ENTRY" to BROWSE-5.

   end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add2 f-okei2
ON choose OF b-add2 IN FRAME f-okei2 /* Значение ЕМЦ */
do:
   define buffer b1-code for code.
   define buffer btt-code for code.
   define variable vRec as recid no-undo.
   define variable v-ok as logical no-undo.
   if avail code
   then
   run ref/emc-value.w (
                            input parparentproc
                          , input iMode
                          , input code.parent
                          , input code.code
                          , input ?).
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del f-okei2
ON choose OF b-del IN FRAME f-okei2 /* Удалить */
do:
   define buffer b1-code for code.
   if not avail code then return.
   define variable v-ok as logical no-undo.

   message "Удалить запись Тип ЕМЦ - Код:" code.code "Тип ЕМЦ - Наименование:" code.codename "?"
      view-as alert-box question
      buttons yes-no
      title "Удаление"
      update v-ok .
   if not v-ok then return no-apply.
   do on error undo, return
   on stop undo, return:
      find first b1-code of code exclusive-lock no-wait no-error.
      if locked b1-code then do:
         message
            vss-workfile vss-revision vss-description skip
            "Запись <им ЕМЦ Код>> занята"
         view-as alert-box error .
         undo, return.
      end.
      if not available b1-code then do:
         message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись <Тим ЕМЦ Код>"
         view-as alert-box error .
         undo, return.
      end.
      delete b1-code.
/*      run FillTT.*/
      {&OPEN-QUERY-BROWSE-5}
      apply "ENTRY" to BROWSE-5.
   end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel f-okei2
ON choose OF b-sel IN FRAME f-okei2 /* Выбор  */
do:
   define buffer b1-code for code.
   if not avail buf-code then return.
   find first b1-code of buf-code no-lock no-error.
   if avail b1-code then
      v-rid = recid(b1-code).
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd f-okei2
ON choose OF b-upd IN FRAME f-okei2 /* Изменить */
do:
   define variable vRec as recid no-undo.
   
   if not avail code then return.
   define variable v-ok as logical no-undo.

   vRec = recid(code).
   run ref/emc-upd.w (
                            input parparentproc
                          , input {&update}
                          , input-output vRec).

         {&OPEN-QUERY-BROWSE-5}
         reposition BROWSE-5 to recid vRec.
         apply "ENTRY" to BROWSE-5.
      end.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-5
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK f-okei2 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
  then frame {&FRAME-NAME}:PARENT = active-window.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
on window-close of frame {&FRAME-NAME}
  apply "END-ERROR":U to self.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
  on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:

  { gbl/getcntxt.i get }
  { gbl/curdbnum.i v-db-num }

  run enable_UI in this-procedure .

  wait-for go of frame {&FRAME-NAME} focus {&browse-name}.
end.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI f-okei2  _DEFAULT-DISABLE
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
  HIDE FRAME f-okei2.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI f-okei2 
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
  enable
    BROWSE-5
    b-exit
    b-add2
    b-sel
    when imode eq {&select}
    b-add
    when imode eq {&update} and v-db-num = 0  
    
    b-del
    when imode eq {&update} and v-db-num = 0
    b-upd
    when imode eq {&update} and v-db-num = 0   
    b-help
    with frame {&frame-name}.

  {&OPEN-BROWSERS-IN-QUERY-f-okei2}

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

