&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Глобальные настройки для работы с МЦ

Автор: Белоусов Илья Александрович
Дата создания: 05/13/08
Author: Ilia Belousov
Creation date: 05/13/08

Input:

Output:

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE       NO-UNDO.
DEFINE INPUT PARAMETER p-mode        AS CHARACTER           NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type  LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code  LIKE ub.shop.obj-code    NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Глобальные настройки для работы с МЦ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
{ gbl/getcntxt.i def }

define buffer buf_thbj-attr   for ub.thbj-attr.

define temp-table temp-thbj-attr          no-undo like ub.thbj-attr.
define temp-table thbjattr_thbj-attr-fin  no-undo like ub.thbj-attr.

define variable v-cli-grp-recid-list as character no-undo .
define variable v-cli-grp-code-list  as character no-undo .

define variable v-tth-wthrep as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-abc as logical no-undo.
define variable str-attr as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help b-cli-grp ed-grp-obj ~
tg-docdstnws 
&Scoped-Define DISPLAYED-OBJECTS ed-grp-obj tg-docdstnws 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cli-grp 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "gr" 
     SIZE 3 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ed-grp-obj AS CHARACTER 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 79.5 BY 8
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tg-docdstnws AS LOGICAL INITIAL no 
     LABEL " Не передавать в УБД по СПН документы уничтожения и перемещения зоны погашения ." 
     VIEW-AS TOGGLE-BOX
     SIZE 80.5 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 55
     b-cli-grp AT ROW 3 COL 40 WIDGET-ID 2
     ed-grp-obj AT ROW 4 COL 3 NO-LABEL WIDGET-ID 20
     tg-docdstnws AT ROW 13.25 COL 3.5 WIDGET-ID 22
     "Группы клиентов для сводных отчетов:" VIEW-AS TEXT
          SIZE 36 BY .67 AT ROW 3.25 COL 2.5 WIDGET-ID 4
          FGCOLOR 4 
     SPACE(45.99) SKIP(11.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Глобальные настройки для работы с МЦ"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.


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
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       ed-grp-obj:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Глобальные настройки для работы с МЦ */
DO:
   IF p-mode = {&LOOKUP} THEN RETURN.
   run save-proc in this-procedure no-error.
   if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Глобальные настройки для работы с МЦ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cli-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cli-grp Dialog-Frame
ON CHOOSE OF b-cli-grp IN FRAME Dialog-Frame /* gr */
DO:
   run grp-list in THIS-PROCEDURE .
   display ed-grp-obj WITH frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  MESSAGE "Help for File: {&FILE-NAME}" VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

&scop b-quit ~{&b-exit~}
   { gbl/hot-key.i b-quit }
   { gbl/app_help.i }
   { gbl/getcntxt.i get }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:


   assign
      v-tth-wthrep = buffer thbjattr_thbj-attr-fin:table-handle
   .


   if p-mode =  {&update} then do:
      if v-cntxt-db-num = 0 then p-mode = {&update}.
         else p-mode = {&lookup} .
   end.


   RUN enable_UI.
   run load-attr in this-procedure .

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
  DISPLAY ed-grp-obj tg-docdstnws 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help b-cli-grp ed-grp-obj tg-docdstnws 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
   define variable v-value-date as date no-undo .
   define variable v-value-decimal as decimal no-undo .
   define variable v-value-integer as INTEGER no-undo .
   define variable v-value-logical AS LOGICAL no-undo .
   define variable v-param-type as character no-undo .
   define variable v-i    as integer      no-undo.

   define buffer buf_cli-grp     for ub.cli-grp .
do
on error undo, return error
:
   for each thbjattr_thbj-attr-fin:
      delete thbjattr_thbj-attr-fin.
   end.
   for each temp-thbj-attr:
      delete temp-thbj-attr.
   end.
   run adm/shattri.p (
      input "init":U
   , input ""
   , input 0
   , input {&attr-wthrep}
   , input "":U
   , output v-value-character
   , output v-value-date
   , output v-value-decimal
   , output v-value-integer
   , output v-value-logical
   , output v-param-type
   , input-output TABLE-HANDLE v-tth-wthrep
   ) no-error .
   if error-status:error
   and not available buf_thbj-attr
   then do:
      message
         "Не удалось получить начальные значения настроек" skip
         error-status:get-message(1) return-value
      view-as alert-box error .
      undo, return error .
   end.


   FOR EACH thbjattr_thbj-attr-fin:

      IF thbjattr_thbj-attr-fin.prop-code = {&attr-wthrep_cligrplist} THEN DO:
         v-cli-grp-code-list = thbjattr_thbj-attr-fin.property-value-character.
         /*
         display v-cli-grp-code-list with frame {&frame-name} .
         */
      END.
      IF thbjattr_thbj-attr-fin.prop-code = {&attr-wthrep_docdstnws} THEN DO:
              tg-docdstnws = thbjattr_thbj-attr-fin.property-value-logical.
      END.

      create temp-thbj-attr.
      buffer-copy thbjattr_thbj-attr-fin to temp-thbj-attr.
   END.

   do v-i = 1 to num-entries(v-cli-grp-code-list)
   :
      find first buf_cli-grp no-lock
      where buf_cli-grp.node-code = integer( entry( v-i, v-cli-grp-code-list, {&comma-char} ) )
      no-error .
      if available buf_cli-grp
      then do:
         assign
            ed-grp-obj = ed-grp-obj + buf_cli-grp.node-name + {&new-line}
         .
      end.
   end.

end. /* do on error */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE grp-list Dialog-Frame 
PROCEDURE grp-list :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_cli-grp     for ub.cli-grp .

define variable v-count    as integer      no-undo.

do
on error undo, return error
:

   run ref/cli-grps.w   ( INPUT parparentproc
                        , INPUT "b-sel,b-mark"
                        , INPUT-OUTPUT v-cli-grp-recid-list
                        ) .
   IF v-cli-grp-recid-list = "":U
   THEN DO:
      RETURN NO-APPLY.
   END.

   assign
      v-cli-grp-code-list = "":U
      ed-grp-obj  = "":U
   .
   DO v-count = 1 TO NUM-ENTRIES(v-cli-grp-recid-list)
   on error undo, next
   :
      find first buf_cli-grp
           where RECID(buf_cli-grp) = INTEGER(ENTRY(v-count, v-cli-grp-recid-list, {&comma-char}))
           no-lock
           no-error
           .
      IF AVAILABLE buf_cli-grp
      THEN DO:
         assign
            v-cli-grp-code-list = IF v-cli-grp-code-list = "":U THEN STRING(buf_cli-grp.node-code)
                                                                ELSE v-cli-grp-code-list + {&comma-char} + STRING(buf_cli-grp.node-code)
            ed-grp-obj = ed-grp-obj + buf_cli-grp.node-name + {&new-line}
         .
      END.
   END. /* объекты по списку групп */
end.  /* do on error */
END PROCEDURE. /* grp-list */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load-attr Dialog-Frame 
PROCEDURE load-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-ok as logical   no-undo .

do
on error undo, return error
:
   if p-mode = {&update} then do:
      /* Проверка прав */
      { gbl/chk-actg.i
         v-cntxt-db-num
         v-cntxt-userid
         {&action-head-code-main}
         'actn_wealth_work':U
         {&cntxt-global}
         0
         '':U
         0
         0
         0
         0
         true
         v-ok
      }
      if v-ok <> yes
      then do:
         return error.
      end.

      find  first buf_thbj-attr
            where buf_thbj-attr.obj-type        = "":u
            and   buf_thbj-attr.obj-code        = 0
            and   buf_thbj-attr.upper-prop-code = {&attr-wthrep}
            and   buf_thbj-attr.prop-code       = '':u
            exclusive-lock
            no-wait
            no-error
            .
      if locked buf_thbj-attr then do:
         message
                    vss-workfile vss-revision vss-description
               skip {&attr-wthrep}
               skip "Запись Глобальных ПАРАМЕТРОВ для взаиморасчетов занята"
               view-as alert-box error .
         undo, return error.
      end.
   end.
   else do:
      find  first buf_thbj-attr
            where buf_thbj-attr.obj-type        = "":u
            and   buf_thbj-attr.obj-code        = 0
            and   buf_thbj-attr.upper-prop-code = {&attr-wthrep}
            and   buf_thbj-attr.prop-code       = '':u
            no-lock
            no-error
            .
      DISABLE b-quit WITH FRAME {&frame-name}.
      b-exit:LABEL = "Вы&ход"  .
      HIDE b-quit IN FRAME {&frame-name} .
   end.
   if not available buf_thbj-attr
   then do:
      assign
         v-to-create  = true
      .
      message
         substitute ("Внимание!!!&1Параметра НЕТ в БД!&1 Список пустой."
                    , {&new-line}
                    )
      view-as alert-box warning.
   end.

   run fill-widgets in this-procedure no-error.
   if error-status:error
   then DO:
      undo, return error.
   END.

   apply "value-changed":u to b-cli-grp in frame {&frame-name}.
   IF p-mode <> {&update}
   THEN DO:
      DISABLE b-cli-grp WITH frame {&frame-name}.
   END.
   display ed-grp-obj tg-docdstnws WITH frame {&frame-name}.

end.  /* do on error */
END PROCEDURE. /* load-attr */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame 
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-trf-type like ub.clients.obj-type no-undo .
define variable v-trf-code like ub.clients.obj-code no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .

do
on error undo, return error
:
   assign frame {&frame-name}  tg-docdstnws.
   FOR EACH thbjattr_thbj-attr-fin:
      IF thbjattr_thbj-attr-fin.prop-code = {&attr-wthrep_cligrplist} THEN DO:
         assign
            thbjattr_thbj-attr-fin.property-value-character = v-cli-grp-code-list
         .
      END.
      IF thbjattr_thbj-attr-fin.prop-code = {&attr-wthrep_docdstnws} THEN DO:
         assign
            thbjattr_thbj-attr-fin.property-value-logical = tg-docdstnws
         .
      END.

   END.


   /*
   do while valid-handle(wh):
      if wh:private-data begins "recid=" then do:
         find first thbjattr_thbj-attr-fin where
                  recid(thbjattr_thbj-attr-fin) = integer(entry(2, wh:private-data, '=')).

         assign
            buffer thbjattr_thbj-attr-fin.property-value-character = v-cli-grp-code-list
         .
      end.
      wh = wh:next-sibling.
   end.
   v-same = yes.
   for each thbjattr_thbj-attr-fin
      ,
      first temp-thbj-attr
      where temp-thbj-attr.obj-type = thbjattr_thbj-attr-fin.obj-type
        and temp-thbj-attr.obj-code = thbjattr_thbj-attr-fin.obj-code
        and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr-fin.upper-prop-code
        and temp-thbj-attr.prop-code = thbjattr_thbj-attr-fin.prop-code
        :

      buffer-compare thbjattr_thbj-attr-fin to temp-thbj-attr save result in v-same.
      if not v-same then leave.
   end.
   */

   do TRANSACTION
   on error undo, return error return-value
   :
      run thbjattr_set-section in this-procedure (
             input ""
            ,input 0
            ,input {&attr-wthrep}
            ,input table thbjattr_thbj-attr-fin
      ) no-error.
      if error-status:error then do:
         message error-status:get-message(1)  skip
         return-value
         view-as alert-box.
         undo, return error.
      end.
   end.

end. /* do on error */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

