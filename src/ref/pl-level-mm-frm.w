&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Карточка поясной вместимости

Автор: Ростовцев Александр
Дата создания: 09/02/24
Author: Rostovtsev Aleksandr
Creation date: 09/02/24


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-obj-type  like ub.pl-level-mm.obj-type no-undo.
define input parameter p-obj-code  like ub.pl-level-mm.obj-code no-undo.
define input parameter p-pl-code   like ub.pl-level-mm.pl-code  no-undo.
define input parameter p-locl      like ub.place.loc1           no-undo.
define input parameter p-mode as character no-undo.
define input-output parameter p-rid as recid init ? no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Карточка поясной вместимости".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }

define buffer buf_pl-level-mm for ub.pl-level-mm.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-save b-quit B-Help f-zone f-min-level ~
f-max-level f-level f-capacity 
&Scoped-Define DISPLAYED-OBJECTS f-zone f-min-level f-max-level f-level ~
f-capacity 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-capacity AS DECIMAL FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Поясная вместимость, л" 
     VIEW-AS FILL-IN 
     SIZE 53 BY 1 NO-UNDO.

DEFINE VARIABLE f-level AS INTEGER FORMAT ">>>>>9":U INITIAL 0 
     LABEL "Уровень, мм" 
     VIEW-AS FILL-IN 
     SIZE 53 BY 1 NO-UNDO.

DEFINE VARIABLE f-max-level AS DECIMAL FORMAT ">>>>>9":U INITIAL 0 
     LABEL "Верхний уровень пояса, см" 
     VIEW-AS FILL-IN 
     SIZE 53 BY 1 NO-UNDO.

DEFINE VARIABLE f-min-level AS DECIMAL FORMAT ">>>>>9":U INITIAL 0 
     LABEL "Нижний уровень пояса, см" 
     VIEW-AS FILL-IN 
     SIZE 53 BY 1 NO-UNDO.

DEFINE VARIABLE f-zone AS INTEGER FORMAT ">>>>>9":U INITIAL 0 
     LABEL "Номер пояса" 
     VIEW-AS FILL-IN 
     SIZE 53 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-save AT ROW 1.14 COL 1.4
     b-quit AT ROW 1.14 COL 11.4
     B-Help AT ROW 1.14 COL 36.4
     f-zone AT ROW 2.43 COL 27 COLON-ALIGNED WIDGET-ID 4
     f-min-level AT ROW 3.62 COL 27 COLON-ALIGNED WIDGET-ID 10
     f-max-level AT ROW 4.81 COL 27 COLON-ALIGNED WIDGET-ID 26
     f-level AT ROW 6 COL 27 COLON-ALIGNED WIDGET-ID 28
     f-capacity AT ROW 7.19 COL 27 COLON-ALIGNED WIDGET-ID 30
     SPACE(3.19) SKIP(0.56)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE ""
         DEFAULT-BUTTON B-save CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Ввод */
DO:
  define buffer bf_pl-level-mm for ub.pl-level-mm.
  assign frame {&frame-name}
    f-zone     
    f-min-level
    f-max-level
    f-level    
    f-capacity 
  .
  
  find first bf_pl-level-mm where 
             bf_pl-level-mm.obj-type  = p-obj-type
         and bf_pl-level-mm.obj-code  = p-obj-code
         and bf_pl-level-mm.pl-code   = p-pl-code
         and (if p-rid <> ? then recid(bf_pl-level-mm) <> p-rid else true)
         and ((bf_pl-level-mm.min-level = f-min-level and
               bf_pl-level-mm.max-level = f-max-level and
               bf_pl-level-mm.level     = f-level) or
              (bf_pl-level-mm.min-level <= f-min-level and
               bf_pl-level-mm.max-level >= f-min-level and
               bf_pl-level-mm.zone <> f-zone) or
              (bf_pl-level-mm.min-level <= f-max-level and
               bf_pl-level-mm.max-level >= f-max-level and
               bf_pl-level-mm.zone <> f-zone) or
              (bf_pl-level-mm.zone = f-zone and
               bf_pl-level-mm.level = f-level))
       no-lock no-error.
  if avail bf_pl-level-mm then 
  do:
    message substitute("Найдено пересечение поясов № &1 и № &2 по уровню пояса &3.~nСохранение невозможно!",
                       bf_pl-level-mm.min-level, bf_pl-level-mm.max-level, bf_pl-level-mm.level)
            view-as alert-box message
            buttons ok
            title "Ошибка при сохранении".
    return no-apply.  
  end.  
    
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-level
&Scoped-define SELF-NAME f-zone
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


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
   if p-mode <> {&add-def} and
      p-mode <> {&update} and
      p-mode <> {&lookup}
   then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode"  p-mode
      view-as alert-box ERROR.
      undo, return error.
   end.
   frame {&frame-name}:title = substitute(
     "&1 строки поясной вместимости для резервуара &2 (&3) &4 &5",
     p-mode, p-pl-code, p-locl, p-obj-type, p-obj-code
   ).
   if p-mode = {&update} or p-mode = {&lookup} then do:
      if p-mode = {&lookup} then do:
        find first buf_pl-level-mm where
                   recid(buf_pl-level-mm) = p-rid no-lock no-error.
      end.
      else do:
        find first buf_pl-level-mm where
                   recid(buf_pl-level-mm) = p-rid exclusive-lock no-wait no-error.
        if locked buf_pl-level-mm then do:
           message
              vss-workfile vss-revision vss-description skip
              "Запись <Пояса> занята"
           view-as alert-box error .
           undo, return error.
        end.
      end.
      if not available buf_pl-level-mm then do:
         message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись <Пояса>"
         view-as alert-box error .
         undo, return error.
      end.
      assign
        f-zone      = buf_pl-level-mm.zone
        f-min-level = buf_pl-level-mm.min-level
        f-max-level = buf_pl-level-mm.max-level
        f-level     = buf_pl-level-mm.level
        f-capacity  = buf_pl-level-mm.capacity
      no-error.
   end.

   run enable_UI in this-procedure.
   if p-mode = {&lookup} then do:
     disable
       f-zone     
       f-min-level
       f-max-level
       f-level    
       f-capacity 
       b-save
     with frame {&frame-name}.  
   end.
   else do:
     apply "entry" to f-zone in FRAME Dialog-Frame.
   end.
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
session:data-entry-return = no .
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
  DISPLAY f-zone f-min-level f-max-level f-level f-capacity 
      WITH FRAME Dialog-Frame.
  ENABLE B-save b-quit B-Help f-zone f-min-level f-max-level f-level f-capacity 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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

   if f-zone = 0 or
      f-max-level = 0 or
      f-level     = 0 or
      f-capacity  = 0 then 
   do:
     message "Ошибка при сохранении.~n"
             "Необходимо заполнить все поля формы." view-as alert-box.
     apply "ENTRY" to f-zone in frame {&frame-name}.
     return error.
   end.
   do on error undo, return error
   on stop undo, return error:
      if p-mode = {&add-def} then do:
         create buf_pl-level-mm.
         assign
           buf_pl-level-mm.obj-type = p-obj-type
           buf_pl-level-mm.obj-code = p-obj-code
           buf_pl-level-mm.pl-code  = p-pl-code
           p-rid = recid(buf_pl-level-mm).
         .
      end.
      assign
        buf_pl-level-mm.zone      = f-zone     
        buf_pl-level-mm.min-level = f-min-level
        buf_pl-level-mm.max-level = f-max-level
        buf_pl-level-mm.level     = f-level    
        buf_pl-level-mm.capacity  = f-capacity 
      .
   end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

