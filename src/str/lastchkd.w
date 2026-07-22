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

Диалог редактирования и показа параметров последнего принятого чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/16/04
Author: Bakhtadze Natalya
Creation date: 09/16/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER p-title-label AS CHARACTER NO-UNDO.
/*список тайтлов и деблов для филлинов - разделитель delim-par в порядке фрейм-f-date-1-f-date-2-loc-hour-1-loc-hour-2*/
/*Все кроме тайтал могут быть не заданы*/

define input        parameter h-callback as handle    no-undo .
/*указатель на вызывающую процедуру для проверки даты-времени*/
/*Весли h-callback <> ? тогда  вызывающей процедуре должна присутствовать внутренняя процедура cb-d-time-validate
с параметрами
input p-date-1  as date
input p-date-2  as date
input p-time-1  as integer
input p-time-2  as integer
output p-ok     as logical
output p-mes    as character
*/


DEFINE INPUT PARAMETER p-mode AS INTEGER NO-UNDO.
/*режим 0 - два времени  с секундами две даты два номера смены два номер Z-отчета два номера чека*/
/*режим 1 -  время с секундами дата один номер смены одина номер Z-отчета один номер чека*/
/*режим 2 - два времени  без секунд две даты  два номера смены два номер Z-отчета два номера чека*/
/*режим 3 -  время без секунд дата один номер смены одина номер Z-отчета один номер чека */
define input parameter p-code as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-date-1 AS DATE NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-date-2 AS DATE NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-time-1 AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-time-2 AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-shift-num-1 AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-shift-num-2 AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-Z-count-1 AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-Z-count-2 AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-chk-num-1 AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-chk-num-2 AS integer NO-UNDO.

DEFINE OUTPUT PARAMETER p-ok AS LOGICAL NO-UNDO.



/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог редактирования и показа параметров последнего принятого чека".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help RECT-from RECT-to ~
f-date-1 l-loc-hour-1 l-loc-min-1 l-loc-sec-1 f-date-2 l-loc-hour-2 ~
l-loc-min-2 l-loc-sec-2 F-shift-num-1 F-shift-num-2 f-z-count-1 f-z-count-2 ~
F-chk-num-1 F-chk-num-2 F-delim-11 F-delim-12 F-delim-21 F-delim-22 
&Scoped-Define DISPLAYED-OBJECTS f-date-1 l-loc-hour-1 l-loc-min-1 ~
l-loc-sec-1 f-date-2 l-loc-hour-2 l-loc-min-2 l-loc-sec-2 F-shift-num-1 ~
F-shift-num-2 f-z-count-1 f-z-count-2 F-chk-num-1 F-chk-num-2 F-delim-11 ~
F-delim-12 F-delim-21 F-delim-22 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 l-loc-hour-1 l-loc-min-1 l-loc-sec-1 l-loc-hour-2 ~
l-loc-min-2 l-loc-sec-2 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE F-chk-num-1 LIKE chk-doc.chk-num
     LABEL "Номер чека" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE F-chk-num-2 LIKE chk-doc.chk-num
     LABEL "Номер чека" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-1 AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-2 AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE F-delim-11 AS CHARACTER FORMAT "X(256)":U INITIAL ":" 
      VIEW-AS TEXT 
     SIZE 1 BY .83 NO-UNDO.

DEFINE VARIABLE F-delim-12 AS CHARACTER FORMAT "X(256)":U INITIAL ":" 
      VIEW-AS TEXT 
     SIZE 1 BY .67 NO-UNDO.

DEFINE VARIABLE F-delim-21 AS CHARACTER FORMAT "X(256)":U INITIAL ":" 
      VIEW-AS TEXT 
     SIZE 1 BY .67 NO-UNDO.

DEFINE VARIABLE F-delim-22 AS CHARACTER FORMAT "X(256)":U INITIAL ":" 
      VIEW-AS TEXT 
     SIZE 1 BY .67 NO-UNDO.

DEFINE VARIABLE F-shift-num-1 LIKE chk-doc.shift-num
     LABEL "№ смены" 
     VIEW-AS FILL-IN 
     SIZE 4.5 BY 1 NO-UNDO.

DEFINE VARIABLE F-shift-num-2 LIKE chk-doc.shift-num
     LABEL "№ смены" 
     VIEW-AS FILL-IN 
     SIZE 4.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-z-count-1 AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "№ Z-отчета" 
     VIEW-AS FILL-IN 
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-z-count-2 AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "№ Z-отчета" 
     VIEW-AS FILL-IN 
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE l-loc-hour-1 AS INTEGER FORMAT "99":U INITIAL 0 
     LABEL "Время" 
     VIEW-AS FILL-IN 
     SIZE 3.25 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение часа" NO-UNDO.

DEFINE VARIABLE l-loc-hour-2 AS INTEGER FORMAT "99":U INITIAL 0 
     LABEL "Время" 
     VIEW-AS FILL-IN 
     SIZE 3.25 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение часа" NO-UNDO.

DEFINE VARIABLE l-loc-min-1 AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3.25 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение минут" NO-UNDO.

DEFINE VARIABLE l-loc-min-2 AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3.25 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение минут" NO-UNDO.

DEFINE VARIABLE l-loc-sec-1 AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3.25 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение секунд" NO-UNDO.

DEFINE VARIABLE l-loc-sec-2 AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3.25 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение секунд" NO-UNDO.

DEFINE RECTANGLE RECT-from
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 47 BY 7.

DEFINE RECTANGLE RECT-to
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 47 BY 7.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     f-date-1 AT ROW 3 COL 6 COLON-ALIGNED
     l-loc-hour-1 AT ROW 3 COL 30.5 COLON-ALIGNED
     l-loc-min-1 AT ROW 3 COL 35.5 COLON-ALIGNED NO-LABEL
     l-loc-sec-1 AT ROW 3 COL 40.5 COLON-ALIGNED NO-LABEL
     f-date-2 AT ROW 3 COL 54 COLON-ALIGNED
     l-loc-hour-2 AT ROW 3 COL 78.5 COLON-ALIGNED
     l-loc-min-2 AT ROW 3 COL 83.5 COLON-ALIGNED NO-LABEL
     l-loc-sec-2 AT ROW 3 COL 88.5 COLON-ALIGNED NO-LABEL
     F-shift-num-1 AT ROW 4.5 COL 14 COLON-ALIGNED HELP
          ""
          LABEL "№ смены"
     F-shift-num-2 AT ROW 4.5 COL 62 COLON-ALIGNED HELP
          ""
          LABEL "№ смены"
     f-z-count-1 AT ROW 6 COL 14 COLON-ALIGNED
     f-z-count-2 AT ROW 6 COL 62 COLON-ALIGNED
     F-chk-num-1 AT ROW 7.5 COL 14 COLON-ALIGNED HELP
          ""
          LABEL "Номер чека" FORMAT "->>>>>>>>>>9"
     F-chk-num-2 AT ROW 7.5 COL 62 COLON-ALIGNED HELP
          ""
          LABEL "Номер чека" FORMAT "->>>>>>>>>>9"
     F-delim-11 AT ROW 3.17 COL 34 COLON-ALIGNED NO-LABEL
     F-delim-12 AT ROW 3.17 COL 39 COLON-ALIGNED NO-LABEL
     F-delim-21 AT ROW 3.17 COL 82 COLON-ALIGNED NO-LABEL
     F-delim-22 AT ROW 3.17 COL 87 COLON-ALIGNED NO-LABEL
     RECT-from AT ROW 2.25 COL 1
     RECT-to AT ROW 2.25 COL 48.5
     SPACE(0.49) SKIP(0.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Параметры последнего чека"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


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
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN F-chk-num-1 IN FRAME Dialog-Frame
   LIKE = ub.chk-doc.chk-num EXP-LABEL EXP-FORMAT EXP-SIZE              */
/* SETTINGS FOR FILL-IN F-chk-num-2 IN FRAME Dialog-Frame
   LIKE = ub.chk-doc.chk-num EXP-LABEL EXP-FORMAT EXP-SIZE              */
/* SETTINGS FOR FILL-IN F-shift-num-1 IN FRAME Dialog-Frame
   LIKE = ub.chk-doc.shift-num EXP-LABEL EXP-SIZE                       */
/* SETTINGS FOR FILL-IN F-shift-num-2 IN FRAME Dialog-Frame
   LIKE = ub.chk-doc.shift-num EXP-LABEL EXP-SIZE                       */
/* SETTINGS FOR FILL-IN l-loc-hour-1 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-hour-2 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-min-1 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-min-2 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-sec-1 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-sec-2 IN FRAME Dialog-Frame
   1                                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры последнего чека */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-hour-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour-1 Dialog-Frame
ON CURSOR-DOWN OF l-loc-hour-1 IN FRAME Dialog-Frame /* Время */
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour-1 Dialog-Frame
ON CURSOR-UP OF l-loc-hour-1 IN FRAME Dialog-Frame /* Время */
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 24 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour-1 Dialog-Frame
ON LEAVE OF l-loc-hour-1 IN FRAME Dialog-Frame /* Время */
DO:
    assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if {&SELF-NAME} < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.

   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-hour-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour-2 Dialog-Frame
ON CURSOR-DOWN OF l-loc-hour-2 IN FRAME Dialog-Frame /* Время */
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour-2 Dialog-Frame
ON CURSOR-UP OF l-loc-hour-2 IN FRAME Dialog-Frame /* Время */
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 24 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour-2 Dialog-Frame
ON LEAVE OF l-loc-hour-2 IN FRAME Dialog-Frame /* Время */
DO:
    assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if {&SELF-NAME} < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.

   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-min-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min-1 Dialog-Frame
ON CURSOR-DOWN OF l-loc-min-1 IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min-1 Dialog-Frame
ON CURSOR-UP OF l-loc-min-1 IN FRAME Dialog-Frame
DO:
   assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 59 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min-1 Dialog-Frame
ON LEAVE OF l-loc-min-1 IN FRAME Dialog-Frame
DO:
   assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-min-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min-2 Dialog-Frame
ON CURSOR-DOWN OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min-2 Dialog-Frame
ON CURSOR-UP OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
   assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 59 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min-2 Dialog-Frame
ON LEAVE OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
   assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-sec-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-sec-1 Dialog-Frame
ON CURSOR-DOWN OF l-loc-sec-1 IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-sec-1 Dialog-Frame
ON CURSOR-UP OF l-loc-sec-1 IN FRAME Dialog-Frame
DO:
   assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 59 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-sec-1 Dialog-Frame
ON LEAVE OF l-loc-sec-1 IN FRAME Dialog-Frame
DO:
   assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-sec-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-sec-2 Dialog-Frame
ON CURSOR-DOWN OF l-loc-sec-2 IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-sec-2 Dialog-Frame
ON CURSOR-UP OF l-loc-sec-2 IN FRAME Dialog-Frame
DO:
   assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 59 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-sec-2 Dialog-Frame
ON LEAVE OF l-loc-sec-2 IN FRAME Dialog-Frame
DO:
   assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/ed_date.i f-date-1 }
{ gbl/ed_date.i f-date-2 }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN MYenable.
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
  DISPLAY f-date-1 l-loc-hour-1 l-loc-min-1 l-loc-sec-1 f-date-2 l-loc-hour-2 
          l-loc-min-2 l-loc-sec-2 F-shift-num-1 F-shift-num-2 f-z-count-1 
          f-z-count-2 F-chk-num-1 F-chk-num-2 F-delim-11 F-delim-12 F-delim-21 
          F-delim-22 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help RECT-from RECT-to f-date-1 l-loc-hour-1 
         l-loc-min-1 l-loc-sec-1 f-date-2 l-loc-hour-2 l-loc-min-2 l-loc-sec-2 
         F-shift-num-1 F-shift-num-2 f-z-count-1 f-z-count-2 F-chk-num-1 
         F-chk-num-2 F-delim-11 F-delim-12 F-delim-21 F-delim-22 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
ASSIGN
f-date-1 = p-date-1
f-date-2 = p-date-2
l-loc-hour-1  = integer(substring(string(p-time-1, "hh:mm:ss":U), 1, 2))
l-loc-min-1  = integer(substring(string(p-time-1, "hh:mm:ss":U), 4, 2))
l-loc-sec-1 = integer(substring(string(p-time-1, "hh:mm:ss":U), 7, 2))
l-loc-hour-2  = integer(substring(string(p-time-2, "hh:mm:ss":U), 1, 2))
l-loc-min-2  = integer(substring(string(p-time-2, "hh:mm:ss":U), 4, 2))
l-loc-sec-2 = integer(substring(string(p-time-2, "hh:mm:ss":U), 7, 2))
f-shift-num-1 = p-shift-num-1
f-shift-num-2 = p-shift-num-2
f-Z-count-1 = p-Z-count-1
f-Z-count-2 = p-Z-count-2
f-chk-num-1 = p-chk-num-1
f-chk-num-2 = p-chk-num-2
FRAME {&frame-name}:TITLE = ENTRY(1, p-title-label, {&delim-par})
f-date-1:LABEL IN FRAME {&frame-name} = (IF NUM-ENTRIES(p-title-label, {&delim-par}) > 1
                                         THEN ENTRY(2, p-title-label, {&delim-par})
                                         ELSE f-date-1:LABEL IN FRAME {&frame-name})
f-date-2:LABEL IN FRAME {&frame-name} = (IF NUM-ENTRIES(p-title-label, {&delim-par}) > 2
                                        THEN ENTRY(3, p-title-label, {&delim-par})
                                        ELSE f-date-2:LABEL IN FRAME {&frame-name})
l-loc-hour-1:LABEL IN FRAME {&frame-name} = (IF NUM-ENTRIES(p-title-label, {&delim-par}) > 3
                                            THEN ENTRY(4, p-title-label, {&delim-par})
                                            ELSE l-loc-hour-1:LABEL IN FRAME {&frame-name})
l-loc-hour-2:LABEL IN FRAME {&frame-name} = (IF NUM-ENTRIES(p-title-label, {&delim-par}) > 4
                                            THEN ENTRY(5, p-title-label, {&delim-par})
                                            ELSE l-loc-hour-2:LABEL IN FRAME {&frame-name})
f-shift-num-1:LABEL IN FRAME {&frame-name} = (IF NUM-ENTRIES(p-title-label, {&delim-par}) > 5
                                         THEN ENTRY(6, p-title-label, {&delim-par})
                                         ELSE f-shift-num-1:LABEL IN FRAME {&frame-name})
f-shift-num-2:LABEL IN FRAME {&frame-name} = (IF NUM-ENTRIES(p-title-label, {&delim-par}) > 6
                                        THEN ENTRY(7, p-title-label, {&delim-par})
                                        ELSE f-shift-num-2:LABEL IN FRAME {&frame-name})
f-Z-count-1:LABEL IN FRAME {&frame-name} = (IF NUM-ENTRIES(p-title-label, {&delim-par}) > 7
                                         THEN ENTRY(8, p-title-label, {&delim-par})
                                         ELSE f-z-count-1:LABEL IN FRAME {&frame-name})
f-Z-count-2:LABEL IN FRAME {&frame-name} = (IF NUM-ENTRIES(p-title-label, {&delim-par}) > 8
                                        THEN ENTRY(9, p-title-label, {&delim-par})
                                        ELSE f-z-count-2:LABEL IN FRAME {&frame-name})
f-chk-num-1:LABEL IN FRAME {&frame-name} = (IF NUM-ENTRIES(p-title-label, {&delim-par}) > 9
                                         THEN ENTRY(8, p-title-label, {&delim-par})
                                         ELSE f-chk-num-1:LABEL IN FRAME {&frame-name})
f-chk-num-2:LABEL IN FRAME {&frame-name} = (IF NUM-ENTRIES(p-title-label, {&delim-par}) > 10
                                        THEN ENTRY(9, p-title-label, {&delim-par})
                                        ELSE f-chk-num-2:LABEL IN FRAME {&frame-name})

.
DISPLAY
f-date-1
l-loc-hour-1
l-loc-min-1
f-delim-11
f-shift-num-1
f-z-count-1
f-chk-num-1
WITH FRAME {&frame-name}.
IF p-mode = 0 OR p-mode = 1 THEN DO:
    DISPLAY
    l-loc-sec-1
    f-delim-12
    WITH FRAME {&frame-name}.
END.
IF p-mode = 0 OR p-mode = 2 THEN DO:
    DISPLAY
    f-date-2
    l-loc-hour-2
    l-loc-min-2
    f-delim-21
    f-shift-num-2
    f-z-count-2
    f-chk-num-2
    WITH FRAME {&frame-name}.
END.
IF p-mode = 0 THEN DO:
    DISPLAY
    l-loc-sec-2
    f-delim-22
    WITH FRAME {&frame-name}.
END.
IF p-mode = 2 OR p-mode = 3 THEN DO:
    HIDE
    l-loc-sec-1
    f-delim-12
    IN FRAME {&FRAME-NAME}.
END.
IF p-mode = 1 OR p-mode = 3 THEN DO:
    HIDE
    f-date-2
    l-loc-hour-2
    l-loc-min-2
    f-delim-21
    f-shift-num-2
    f-z-count-2
    f-chk-num-2
    in FRAME {&frame-name}.
END.
IF p-mode = 3 THEN DO:
    HIDE
    l-loc-sec-2
    f-delim-22
    IN FRAME {&FRAME-NAME}.
END.


ENABLE
b-quit
B-exit
B-Help
f-date-1
l-loc-hour-1
l-loc-min-1
l-loc-sec-1 WHEN (p-mode = 0 OR p-mode = 1)
f-date-2 WHEN (p-mode = 0 OR p-mode = 2)
l-loc-hour-2 WHEN (p-mode = 0 OR p-mode = 2)
l-loc-min-2 WHEN (p-mode = 0 OR p-mode = 2)
l-loc-sec-2 WHEN p-mode = 0
/*
f-shift-num-1
f-z-count-1
f-chk-num-1
*/
f-shift-num-2 WHEN (p-mode = 0 OR p-mode = 2)
f-z-count-2 WHEN (p-mode = 0 OR p-mode = 2)
f-chk-num-2 WHEN (p-mode = 0 OR p-mode = 2)
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.

if p-code = "report" then do:
    f-z-count-1:hidden = true .
    f-z-count-2:hidden = true .
    f-chk-num-1:hidden = true .
    f-chk-num-2:hidden = true .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-ok as logical no-undo .
define variable v-mes as character no-undo .
  ASSIGN
  f-date-1 FRAME {&FRAME-NAME}
  l-loc-hour-1
  l-loc-min-1
  p-date-1 = f-date-1
  p-time-1 = l-loc-hour-1 * 3600 + l-loc-min-1 * 60 + l-loc-sec-1
  f-shift-num-1
  f-z-count-1
  f-chk-num-1
  p-z-count-1 = f-z-count-1
  p-shift-num-1 = f-shift-num-1
  p-chk-num-1 = f-chk-num-1
  .
  IF f-date-2:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
    ASSIGN
    f-date-2
    l-loc-hour-2
    l-loc-min-2
    p-date-2 = f-date-2
    p-time-2 = l-loc-hour-2 * 3600 + l-loc-min-2 * 60 + l-loc-sec-2
    f-shift-num-2
    f-z-count-2
    f-chk-num-2
    p-z-count-2 = f-z-count-2
    p-shift-num-2 = f-shift-num-2
    p-chk-num-2 = f-chk-num-2
    .
  END.
  if  h-callback <> ?
  and valid-handle(h-callback)
  then do:
    if h-callback :get-signature("cb-d-time-validate") <> ""
    then do:
      define variable lok as logical no-undo .
      run cb-d-time-validate in h-callback
        (
          input p-date-1
         ,input p-date-2
         ,input p-time-1
         ,input p-time-2
         ,output v-ok
         ,output v-mes
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры проверки допустимости даты и времени" skip
          "файл" h-callback :file-name skip
          "процедура" "cb-d-time-validate" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return no-apply .
      end.
      if v-ok <> true then do:
        return no-apply . /* --->>>--- */
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Программе был передан указатель на процедуру для проверки даты-времени" skip
        "В указанной процедуре отсутствует внутренняя процедура cb-d-time-validate " skip
        "файл" h-callback :file-name skip
        view-as alert-box error .
      return no-apply .
    end.
    if not v-ok then do:
      message
      v-mes
      view-as alert-box error .
      return no-apply.
    end.
    else do:
     p-ok = YES.
    end.
  end.
  p-ok = yes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

