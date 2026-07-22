&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
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

Экран работы со строкой сверки

Автор: SKiryxin
Дата создания: 15/01/13
Author: SKiryxin
Creation date: 15/01/13

*/

define  input parameter parparentproc   as handle    no-undo.
define  input parameter parrec-rvs-line as recid     no-undo.
define  input parameter parmode         as character no-undo.
define  input parameter partitle        as character no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Экран работы со строкой сверки":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

define variable v-return-val as character no-undo initial "":U.
define variable rec-rvs-line-attr as recid  no-undo.    /* Чтобы дважды не искать */

define buffer buf_rvs-line for ub.rvs-line.
define buffer buf_rvs-line-attr for ub.rvs-line-attr.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save RECT-M RECT-C b-cancel ~
fill-in-mag-count fill-in-mag-pres fill-in-mag-temper fill-in-cap-count ~
fill-in-cap-pres 
&Scoped-Define DISPLAYED-OBJECTS fill-in-mag-count fill-in-mag-pres ~
fill-in-mag-temper fill-in-cap-count fill-in-cap-pres 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 Dialog-Frame 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-save AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fill-in-cap-count AS DECIMAL FORMAT ">>,>>>,>>9.99":U INITIAL 0 
     LABEL "Показания счетчика" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .95 NO-UNDO.

DEFINE VARIABLE fill-in-cap-pres AS DECIMAL FORMAT ">>9.99":U INITIAL 0 
     LABEL "Остаточное давление" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .95 NO-UNDO.

DEFINE VARIABLE fill-in-mag-count AS DECIMAL FORMAT ">>,>>>,>>9.99":U INITIAL 0 
     LABEL "Показания счетчика" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .95 NO-UNDO.

DEFINE VARIABLE fill-in-mag-pres AS DECIMAL FORMAT ">>9.99":U INITIAL 0 
     LABEL "Входящее давление" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .95 NO-UNDO.

DEFINE VARIABLE fill-in-mag-temper AS DECIMAL FORMAT "99.99":U INITIAL 0 
     LABEL "Температура" 
     VIEW-AS FILL-IN 
     SIZE 15 BY .95 NO-UNDO.

DEFINE RECTANGLE RECT-C
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 57 BY 3.57.

DEFINE RECTANGLE RECT-M
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 57 BY 5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     fill-in-mag-count AT ROW 3.38 COL 35 COLON-ALIGNED WIDGET-ID 26
     fill-in-mag-pres AT ROW 4.81 COL 35 COLON-ALIGNED WIDGET-ID 28
     fill-in-mag-temper AT ROW 6.24 COL 35 COLON-ALIGNED WIDGET-ID 30
     fill-in-cap-count AT ROW 9.57 COL 34 COLON-ALIGNED WIDGET-ID 36
     fill-in-cap-pres AT ROW 11 COL 34 COLON-ALIGNED WIDGET-ID 38
     "Данные по накопительной емкости" VIEW-AS TEXT
          SIZE 38 BY .71 AT ROW 8.14 COL 24 WIDGET-ID 32
     "Данные о заборе газа из магистрали" VIEW-AS TEXT
          SIZE 40 BY .71 AT ROW 2.19 COL 22 WIDGET-ID 22
     RECT-M AT ROW 2.91 COL 12 WIDGET-ID 24
     RECT-C AT ROW 8.86 COL 12 WIDGET-ID 34
     SPACE(11.19) SKIP(0.61)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Документ сверки"
         CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-rvs-line T "?" NO-UNDO ub rvs-line
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME 1                                                         */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Документ сверки */
DO:
  v-return-val = "cancel".
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
  { gbl/stdbtn.i }
  v-return-val = "cancel".
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Сохранить */
DO:

find first buf_rvs-line where recid(buf_rvs-line) = parrec-rvs-line no-error.
find first buf_rvs-line-attr where recid(buf_rvs-line-attr) = rec-rvs-line-attr no-error.

assign frame {&frame-name} fill-in-cap-count
                           fill-in-cap-pres
                           fill-in-mag-count
                           fill-in-mag-pres
                           fill-in-mag-temper.

if not available buf_rvs-line-attr then do:
    create buf_rvs-line-attr. 
    
    assign
        buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
        buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
        buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
        buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
        buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
        buf_rvs-line-attr.attr-code = "mask"
        /* Значение атрибута - составное: показатель счетчика емкости ; остаточное давление ; температура */
        buf_rvs-line-attr.attr-value = substitute("&1;&2;&3",fill-in-mag-count,fill-in-mag-pres,fill-in-mag-temper)
        buf_rvs-line.state-level-petrol = fill-in-cap-count
        buf_rvs-line.state-level-total = fill-in-cap-pres.
        buf_rvs-line.state-density = 0.666.
        
end. /* if not available buf_rvs-line-attr */

else do:
    /* Значение атрибута - составное: показатель счетчика емкости ; остаточное давление ; температура */
    assign
        buf_rvs-line-attr.attr-value = substitute("&1;&2;&3",fill-in-mag-count,fill-in-mag-pres,fill-in-mag-temper)
        buf_rvs-line.state-level-petrol = fill-in-cap-count
        buf_rvs-line.state-level-total = fill-in-cap-pres.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
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

  run get-values in this-procedure. /* Получим данные */
  run enable_UI in this-procedure.
  assign frame {&frame-name} :title = frame {&frame-name} :title + " - " + parmode + " - " +  partitle.
  run ui-on in this-procedure.
  
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

RUN disable_UI.
return v-return-val.

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
  DISPLAY fill-in-mag-count fill-in-mag-pres fill-in-mag-temper 
          fill-in-cap-count fill-in-cap-pres 
      WITH FRAME Dialog-Frame.
  ENABLE b-save RECT-M RECT-C b-cancel fill-in-mag-count
         fill-in-mag-pres fill-in-mag-temper fill-in-cap-count fill-in-cap-pres
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-on Include
procedure ui-on:
	/*------------------------------------------------------------------------------
			Purpose: Включение интерфейса с нужными параметрами
			Notes:  																	  
	------------------------------------------------------------------------------*/
if parmode = {&lookup} then
    disable b-save fill-in-mag-count fill-in-mag-pres 
            fill-in-mag-temper fill-in-cap-count fill-in-cap-pres
            with frame Dialog-Frame.

end procedure.
	
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
	
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-values Include
procedure get-values:
	/*------------------------------------------------------------------------------
			Purpose: Получим знаения строки
			Notes: 
	------------------------------------------------------------------------------*/
find first buf_rvs-line no-lock where recid(buf_rvs-line) = parrec-rvs-line no-error.

find first buf_rvs-line-attr where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                       and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                       and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                       and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
                                       and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                       and buf_rvs-line-attr.attr-code = "mask" no-error.

rec-rvs-line-attr = recid(buf_rvs-line-attr) no-error.

if not available buf_rvs-line then do:
   message "Неверно переданы параметры."
           "Не найдена строка сверки с recid " parrec-rvs-line " ."
   view-as alert-box error.
   return error.
end.

assign 
    fill-in-cap-count = buf_rvs-line.state-level-petrol
    fill-in-cap-pres = buf_rvs-line.state-level-total
    /* Значение атрибута - составное: показатель счетчика емкости ; остаточное давление ; температура */
    fill-in-mag-count = integer(entry(1,buf_rvs-line-attr.attr-value, ";")) 
    fill-in-mag-pres = integer(entry(2,buf_rvs-line-attr.attr-value, ";"))
    fill-in-mag-temper = integer(entry(3,buf_rvs-line-attr.attr-value, ";")) no-error.

end procedure.
	
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
