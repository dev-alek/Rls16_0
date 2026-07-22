&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_fin-code FOR ub.fin-code-cor-acc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Корректировка справочника в ФИНБлоке кор счетов

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 09/10/04 10:55

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter        ref-mode as character no-undo .
define input-output parameter ri       as recid no-undo.
define input parameter par-host-code as integer no-undo .
/* Local Variable Definitions ---                                       */
define variable tcode as character no-undo .
define variable p-fin-code as integer no-undo .
define variable fin-type-acc as WIDGET-handle no-undo .
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Корректировка справочника в ФИНБлоке кор счетов ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i  }
{ gbl/cur-time.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES fin-code-cor-acc buf_fin-code

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame fin-code-cor-acc.code-value ~
fin-code-cor-acc.descr fin-code-cor-acc.level-1 fin-code-cor-acc.level-2 ~
fin-code-cor-acc.level-3 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
fin-code-cor-acc.code-value fin-code-cor-acc.descr fin-code-cor-acc.level-1 ~
fin-code-cor-acc.level-2 fin-code-cor-acc.level-3 
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame fin-code-cor-acc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame fin-code-cor-acc
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH fin-code-cor-acc SHARE-LOCK, ~
      EACH buf_fin-code WHERE TRUE /* Join to fin-code-cor-acc incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH fin-code-cor-acc SHARE-LOCK, ~
      EACH buf_fin-code WHERE TRUE /* Join to fin-code-cor-acc incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame fin-code-cor-acc buf_fin-code
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame fin-code-cor-acc
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame buf_fin-code


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS fin-code-cor-acc.code-value ~
fin-code-cor-acc.descr fin-code-cor-acc.level-1 fin-code-cor-acc.level-2 ~
fin-code-cor-acc.level-3 
&Scoped-define ENABLED-TABLES fin-code-cor-acc
&Scoped-define FIRST-ENABLED-TABLE fin-code-cor-acc
&Scoped-Define ENABLED-OBJECTS b-exit RECT-1 b-quit b-help FILL-IN-1 
&Scoped-Define DISPLAYED-FIELDS fin-code-cor-acc.code-value ~
fin-code-cor-acc.descr fin-code-cor-acc.level-1 fin-code-cor-acc.level-2 ~
fin-code-cor-acc.level-3 
&Scoped-define DISPLAYED-TABLES fin-code-cor-acc
&Scoped-define FIRST-DISPLAYED-TABLE fin-code-cor-acc
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-1 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод " 
     SIZE 10 BY 1.

DEFINE BUTTON b-help AUTO-GO 
     LABEL "Помо&щь" 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Уровни для сбора аналитики" 
      VIEW-AS TEXT 
     SIZE 27.2 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 68.8 BY 2.52.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR 
      fin-code-cor-acc, 
      buf_fin-code SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11.2
     b-help AT ROW 1 COL 62.2
     fin-code-cor-acc.code-value AT ROW 2.38 COL 6.8 COLON-ALIGNED
          LABEL "Код"
          VIEW-AS FILL-IN 
          SIZE 13 BY 1 TOOLTIP "Код спрпавочника"
     fin-code-cor-acc.descr AT ROW 6.24 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 69.8 BY 1
     fin-code-cor-acc.level-1 AT ROW 8.43 COL 12.2 COLON-ALIGNED FORMAT ">>>9"
          VIEW-AS FILL-IN 
          SIZE 5.8 BY 1
     fin-code-cor-acc.level-2 AT ROW 8.43 COL 32.4 COLON-ALIGNED FORMAT ">>>9"
          VIEW-AS FILL-IN 
          SIZE 6.2 BY 1
     fin-code-cor-acc.level-3 AT ROW 8.43 COL 58.6 COLON-ALIGNED FORMAT ">>>9"
          VIEW-AS FILL-IN 
          SIZE 5.8 BY 1
     FILL-IN-1 AT ROW 7.43 COL 21.2 COLON-ALIGNED NO-LABEL
     "Наименование" VIEW-AS TEXT
          SIZE 16 BY .62 AT ROW 5.29 COL 1 WIDGET-ID 2
     RECT-1 AT ROW 7.48 COL 1
     SPACE(2.45) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Корректировка справочника"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_fin-code B "?" ? ub ub.fin-code-cor-acc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fin-code-cor-acc.code-value IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN fin-code-cor-acc.descr IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fin-code-cor-acc.level-1 IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN fin-code-cor-acc.level-2 IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN fin-code-cor-acc.level-3 IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.fin-code-cor-acc,Temp-Tables.buf_fin-code WHERE ub.fin-code-cor-acc ..."
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Корректировка справочника */
DO:
  def var rr as recid no-undo.
  if input ub.fin-code-cor-acc.code-value = "" then do:
      message "Код  не может быть не задан" view-as alert-box.
      apply "ENTRY":U to ub.fin-code-cor-acc.code-value.
      return no-apply.
  end.
  if  input ub.fin-code-cor-acc.descr = ""  then do:
      message "Введите наименование " view-as alert-box WARNING.
      apply "ENTRY":U to ub.fin-code-cor-acc.descr.
      return no-apply.
  end.
  rr = recid( ub.fin-code-cor-acc ).

  if ref-mode =  {&add-def} then do:
    if can-find(first ub.fin-code-cor-acc where ub.fin-code-cor-acc.code-value = input ub.fin-code-cor-acc.code-value
                                       AND recid( ub.fin-code-cor-acc ) <> rr
                                       and ub.fin-code-cor-acc.host-code = par-host-code
                                         ) then do:
        message "Запись с кодом" input ub.fin-code-cor-acc.code-value "уже существует!" skip
              "Если ее нет в списке, то она логически удалена."
              view-as alert-box warning.
        apply "ENTRY":U to ub.fin-code-cor-acc.code-value.
        return no-apply.
    end.
  end.
  /* Запишем с экрана */
  if ref-mode <> {&lookup} then do:
      assign ub.fin-code-cor-acc.code-value
             ub.fin-code-cor-acc.descr
             ub.fin-code-cor-acc.level-1
             ub.fin-code-cor-acc.level-2
             ub.fin-code-cor-acc.level-3
             ri = recid( ub.fin-code-cor-acc )
       .
              if lookup(fin-type-acc:screen-value,{&fin-acc-codes} ) > 0 then
                 ub.fin-code-cor-acc.acc-type = integer (fin-type-acc:screen-value ).
                else message 123 error-status :get-message(1) fin-type-acc:screen-value integer(fin-type-acc:screen-value)     .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Корректировка справочника */
DO:
  apply "CHOOSE" to b-quit IN FRAME {&frame-name} .
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  ri = ? .
  if ref-mode =  {&add-def} then do:
      find current ub.fin-code-cor-acc  exclusive-lock   no-error.
      if available ub.fin-code-cor-acc then do:
         delete ub.fin-code-cor-acc.
      end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


{ ref/crfincd.i  ub.fin-code-cor-acc }

/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   run cr-ob in this-procedure (input-output fin-type-acc, 30 , 1.67 ) .
    if ref-mode =  {&add-def}
        then  do:
            ri = ?.
            run fin-code in this-procedure (input par-host-code , output p-fin-code) .
            tcode = string(p-fin-code) .
            run create-ref-corr-acc in this-procedure (
                input no ,
                input par-host-code ,
                input p-fin-code    ,
                input tcode ,
                input ""    ,
                input 0 ,
                input 0 ,
                input 0 ,
                input 0 ,
                input 1
                ).
        end.
        else  do:
         find ub.fin-code-cor-acc where recid( ub.fin-code-cor-acc ) = ri no-error .
         if error-status :error then return  error .
         fin-type-acc:screen-value = string(ub.fin-code-cor-acc.acc-type)  .
         end.
frame {&frame-name}:title = frame {&frame-name}:title + "  - " + caps(ref-mode).
b-quit:label = (if  ref-mode = {&lookup} then "&Выход" else b-quit:label ).

    session:data-entry-return = yes .
     if ref-mode = {&lookup} then do:
        run myenable_UI in this-procedure.
        WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS b-quit.
     end.
     else do:
        run enable_UI in this-procedure.
        if ref-mode = {&add-def}
            then  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS ub.fin-code-cor-acc.code-value .
            else  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS ub.fin-code-cor-acc.descr .
   end.
END.
run disable_UI in this-procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cr-ob Dialog-Frame 
PROCEDURE cr-ob :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
define input-output parameter type-acc  AS WIDGET-HANDLE.
define input parameter p-x as integer no-undo . /* coordinats in frame */
define input parameter p-y as integer no-undo .
define var fin-type-acc-name as character no-undo .
define var fin-type-acc-val  as character no-undo .
define variable l-str as character no-undo .

assign
  fin-type-acc-name = {&fin-acc-codes-full}
  fin-type-acc-val  = {&fin-acc-codes}
  l-str        = {&fin-acc-codes-radio}
.


   create radio-set type-acc
   assign
    row    = p-y
    column = p-x
    frame  = frame {&frame-name}:handle
    horizontal    = false
    radio-buttons = l-str
 .


if valid-handle(type-acc) = false then do:
    message "Ошибка создания поля ТИПЫ СЧЕТОВ !!!" skip
    skip
    view-as alert-box information .
   return error .
 end.

  type-acc:sensitive = yes  .
  type-acc:visible   = yes  .




  end.  /* do */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY FILL-IN-1 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE fin-code-cor-acc THEN 
    DISPLAY fin-code-cor-acc.code-value fin-code-cor-acc.descr 
          fin-code-cor-acc.level-1 fin-code-cor-acc.level-2 
          fin-code-cor-acc.level-3 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit RECT-1 b-quit b-help fin-code-cor-acc.code-value 
         fin-code-cor-acc.descr fin-code-cor-acc.level-1 
         fin-code-cor-acc.level-2 fin-code-cor-acc.level-3 FILL-IN-1 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE myenable_UI Dialog-Frame 
PROCEDURE myenable_UI :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  IF AVAILABLE ub.fin-code-cor-acc THEN
    DISPLAY ub.fin-code-cor-acc.code-value ub.fin-code-cor-acc.descr FILL-IN-1
          ub.fin-code-cor-acc.level-1 ub.fin-code-cor-acc.level-2
          ub.fin-code-cor-acc.level-3
      WITH FRAME Dialog-Frame.
   enable  b-quit b-help
      WITH FRAME Dialog-Frame.
      fin-type-acc:screen-value = string(ub.fin-code-cor-acc.acc-type)  .
  fin-type-acc:sensitive = no  .
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

