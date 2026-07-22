&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision: 10804996d925, 3000, rls $
$Author: SSlivenko $
$Date: Ср апр 06 16:23:44 2022 +0300 $
$Workfile: pl-lvl.w $
$Archive: ref/pl-lvl.w $

Редактирование записи в градуировочной таблице

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/28/09
Author: Dmitry Ukhanov
Creation date: 01/28/09

Автор1: Белоусов Илья Александрович
Дата создания1: 12/20/07
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc   as widget-handle  no-undo .
define input parameter p-obj-type      as character      no-undo.
define input parameter p-obj-code      as integer        no-undo.
define input parameter p-pl-code       as integer        no-undo.
/* !!! для созднания новой записи необходимо передать (p-pl-level = ?) */
define input-output parameter  p-pl-level as decimal          no-undo.
define output parameter p-ok      as logical          no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: 10804996d925, 3000, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:44 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pl-lvl.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/pl-lvl.w $":U .
define variable vss-description as character no-undo init "Редактирование записи в градуировочной таблице".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }

define variable v-pl-level-next    as integer      no-undo.
define variable v-pl-level-prev    as integer      no-undo.
define variable v-pl-qnty-next     as decimal      no-undo.
define variable v-pl-qnty-prev     as decimal      no-undo.
define variable v-new           as logical      no-undo.

define buffer buf_pl-level    for pl-level .
define buffer buf_pl-level-attr    for pl-level-attr .
define buffer buf_place    for place .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help v-pl-level v-pl-qnty ~
v-pl-tarir-delta v-pl-deltaV v-pl-level-prev-str v-pl-qnty-prev-str ~
v-pl-level-next-str v-pl-qnty-next-str 
&Scoped-Define DISPLAYED-OBJECTS v-pl-level v-pl-qnty v-pl-tarir-delta ~
v-pl-deltaV v-pl-level-prev-str v-pl-qnty-prev-str v-pl-level-next-str ~
v-pl-qnty-next-str 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
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

DEFINE VARIABLE v-pl-deltaV AS DECIMAL FORMAT "9.9999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 11.6 BY 1 NO-UNDO.

DEFINE VARIABLE v-pl-level AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "Уровень, см" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-pl-level-next-str AS CHARACTER FORMAT "X(3)":U INITIAL "-" 
     LABEL "Следующий уровнь" 
      VIEW-AS TEXT 
     SIZE 6.6 BY .67 NO-UNDO.

DEFINE VARIABLE v-pl-level-prev-str AS CHARACTER FORMAT "X(3)":U INITIAL "-" 
     LABEL "Предыдущий уровень" 
      VIEW-AS TEXT 
     SIZE 5 BY .67 NO-UNDO.

DEFINE VARIABLE v-pl-qnty AS DECIMAL FORMAT "->,>>>,>>9.999":U INITIAL 0 
     LABEL "Объем, литры" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-pl-qnty-next-str AS CHARACTER FORMAT "X(10)":U INITIAL "-" 
     LABEL "Следующий объем" 
      VIEW-AS TEXT 
     SIZE 12.6 BY .67 NO-UNDO.

DEFINE VARIABLE v-pl-qnty-prev-str AS CHARACTER FORMAT "X(10)":U INITIAL "-" 
     LABEL "Предыдущий объем" 
      VIEW-AS TEXT 
     SIZE 11 BY .67 NO-UNDO.

DEFINE VARIABLE v-pl-tarir-delta AS DECIMAL FORMAT "9.999":U INITIAL 0 
     LABEL "Погрешность составления, %" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 61
     v-pl-level AT ROW 3.52 COL 13.8 COLON-ALIGNED WIDGET-ID 2
     v-pl-qnty AT ROW 3.52 COL 42.8 COLON-ALIGNED WIDGET-ID 4
     v-pl-tarir-delta AT ROW 3.52 COL 85.8 COLON-ALIGNED WIDGET-ID 14
     v-pl-deltaV AT ROW 3.52 COL 116.8 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     v-pl-level-prev-str AT ROW 2.52 COL 22.2 COLON-ALIGNED WIDGET-ID 6
     v-pl-qnty-prev-str AT ROW 2.52 COL 53.6 COLON-ALIGNED WIDGET-ID 10
     v-pl-level-next-str AT ROW 4.81 COL 20.6 COLON-ALIGNED WIDGET-ID 8
     v-pl-qnty-next-str AT ROW 4.81 COL 38.6 WIDGET-ID 12
     "Вместимости, м3/мм:" VIEW-AS TEXT
          SIZE 20 BY .62 AT ROW 4.05 COL 98.8 WIDGET-ID 18
     "Коэффициент" VIEW-AS TEXT
          SIZE 12 BY .71 AT ROW 3.38 COL 98.8 WIDGET-ID 16
     SPACE(19.79) SKIP(2.33)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "<insert dialog title>"
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

/* SETTINGS FOR FILL-IN v-pl-qnty-next-str IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
   assign
      v-pl-level
      v-pl-qnty
      v-pl-tarir-delta
      v-pl-deltaV
   .
   IF v-pl-level < 0
   OR v-pl-level = ?
   THEN DO:
      message
         "Уровень должен быть не меньше ноля"
         skip
      view-as alert-box information.
      RETURN NO-APPLY.
   END.
   IF v-pl-qnty < 0
   OR v-pl-qnty = ?
   THEN DO:
      message
         "Объем должен быть не меньше ноля"
         skip
      view-as alert-box information.
      RETURN NO-APPLY.
   END.
   
   if v-pl-deltaV <= 0
   then do :
     message
         "Коэффициент вместимости должен быть больше ноля"
         skip
     view-as alert-box information.
     RETURN NO-APPLY.
   end .

   run check-pl-level in this-procedure NO-ERROR.
   IF ERROR-STATUS:ERROR then do:
      message
         error-status:get-message(1) skip
         return-value
      view-as alert-box error .

      return no-apply .
   end.

   run prev-next-show in this-procedure.

   run save-pl-level  in this-procedure no-error.
   IF ERROR-STATUS:ERROR then do:
      message
         error-status:get-message(1) skip
         return-value
      view-as alert-box error .

      return no-apply .
   end.
   assign
      p-ok = true
   .
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   /* редактируем */
   find  first buf_place
         where buf_place.obj-type = p-obj-type
            and buf_place.obj-code = p-obj-code
            and buf_place.pl-code  = p-pl-code
         no-lock
         no-error
         .
   IF p-pl-level <> ? THEN DO:
      find first buf_pl-level
           where buf_pl-level.obj-type = p-obj-type
             and buf_pl-level.obj-code = p-obj-code
             and buf_pl-level.pl-code  = p-pl-code
             and buf_pl-level.pl-level = p-pl-level
           share-lock
           no-wait
           no-error
           .
      IF NOT AVAILABLE buf_pl-level THEN DO:
         IF locked buf_pl-level THEN dO:
            return error "Эта запись градуировочной таблицы в данный момент редактируется".
         END.
         else do:
            return error "Не найдена запись в градуировочной таблице".
         end.
      END.
      
      find first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                                    and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                                    and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
                                                    and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                                    and buf_pl-level-attr.attr-code = "tarir-delta"
                                                    no-error .
      if not available buf_pl-level-attr
      then do :
        return error "Не найдена запись атрибута с погрешностью составления в градуировочной таблице".
      end .                                     

      assign
         v-pl-level = buf_pl-level.pl-level
         v-pl-qnty  = buf_pl-level.pl-qnty
         v-pl-tarir-delta = decimal(buf_pl-level-attr.attr-value)
         v-pl-deltaV = ?
         FRAME Dialog-Frame:TITLE = SUBSTITUTE  ( "Изменение строки градуировочной таблицы для резервуара &1 (&2) &3 &4"
                                                , p-pl-code
                                                , buf_place.loc1
                                                , p-obj-code
                                                , p-obj-type
                                                )
      .
      find first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                                    and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                                    and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
                                                    and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                                    and buf_pl-level-attr.attr-code = "deltaV"
                                                    no-error .
      if available buf_pl-level-attr
      then do :
        assign v-pl-deltaV = decimal(buf_pl-level-attr.attr-value) no-error .
      end .
   end.
   /* создаем */
   ELSE DO:
      assign
         v-new = TRUE
         v-pl-level = ?
         v-pl-qnty  = 0
         v-pl-deltaV = ?
         
         FRAME Dialog-Frame:TITLE = SUBSTITUTE  ( "Создание строки градуировочной таблицы для резервуара &1 (&2) &3 &4"
                                                , p-pl-code
                                                , buf_place.loc1
                                                , p-obj-code
                                                , p-obj-type
                                                )
      .
      find first ub.place-attr no-lock where ub.place-attr.obj-type = buf_place.obj-type
                                         and ub.place-attr.obj-code = buf_place.obj-code
                                         and ub.place-attr.pl-code = buf_place.pl-code
                                         and ub.place-attr.attr-code = "place-type"
                                         no-error .
      if not available ub.place-attr 
      or (available ub.place-attr and ub.place-attr.attr-value = "2")
      then do :
        v-pl-tarir-delta = 0.25 .
      end .
      else do :
        v-pl-tarir-delta = 0.2 .
      end .
   END.
   run check-pl-level in this-procedure NO-ERROR.
      IF ERROR-STATUS:ERROR then do:
         message
            error-status:get-message(1) skip
            return-value
         view-as alert-box error .
      end.
   run prev-next-show in this-procedure.

   RUN enable_UI.
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-pl-level Dialog-Frame 
PROCEDURE check-pl-level :
define buffer bf_pl-level    for pl-level .

do
on error undo, return error
:
   IF p-pl-level <> v-pl-level
   THEN DO:
      find first bf_pl-level
           where bf_pl-level.obj-type = p-obj-type
             and bf_pl-level.obj-code = p-obj-code
             and bf_pl-level.pl-code  = p-pl-code
             and bf_pl-level.pl-level = v-pl-level
         no-lock
         no-error
         .
       IF AVAILABLE bf_pl-level THEN DO:
          RETURN ERROR SUBSTITUTE("Уже есть запись в градуировочной таблице с уровнем &1", v-pl-level) .
       END.
   END.

   IF v-pl-level <> ?
   THEN DO:
      find first bf_pl-level
         where bf_pl-level.obj-type = p-obj-type
            and bf_pl-level.obj-code = p-obj-code
            and bf_pl-level.pl-code  = p-pl-code
            and bf_pl-level.pl-level > v-pl-level
         no-lock
         no-error
         .
      IF AVAILABLE bf_pl-level then do:
         IF bf_pl-level.pl-qnty < v-pl-qnty THEN DO:
            RETURN ERROR SUBSTITUTE ( "Объем (&1) для текущего уровня (&2) больше, чем объем (&3) для следующего уровня (&4)"
                                    , v-pl-qnty
                                    , v-pl-level
                                    , bf_pl-level.pl-qnty
                                    , bf_pl-level.pl-level
                                    ) .
         END.
         assign
            v-pl-level-next = bf_pl-level.pl-level
            v-pl-qnty-next  = bf_pl-level.pl-qnty
         .
      end.

      find last  bf_pl-level
         where bf_pl-level.obj-type = p-obj-type
            and bf_pl-level.obj-code = p-obj-code
            and bf_pl-level.pl-code  = p-pl-code
            and bf_pl-level.pl-level < v-pl-level
         no-lock
         no-error
         .
      IF AVAILABLE bf_pl-level then do:
         IF bf_pl-level.pl-qnty > v-pl-qnty THEN DO:
            RETURN ERROR SUBSTITUTE ( "Объем (&1) для текущего уровня (&2) меньше, чем объем (&3) для предыдущего уровня (&4)"
                                    , v-pl-qnty
                                    , v-pl-level
                                    , bf_pl-level.pl-qnty
                                    , bf_pl-level.pl-level
                                    ) .
         END.
         assign
            v-pl-level-prev = bf_pl-level.pl-level
            v-pl-qnty-prev  = bf_pl-level.pl-qnty
         .
      end.
   end. /* v-pl-level <> ? */
end. /* do on error */
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
  DISPLAY v-pl-level v-pl-qnty v-pl-tarir-delta v-pl-deltaV v-pl-level-prev-str 
          v-pl-qnty-prev-str v-pl-level-next-str v-pl-qnty-next-str 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help v-pl-level v-pl-qnty v-pl-tarir-delta v-pl-deltaV 
         v-pl-level-prev-str v-pl-qnty-prev-str v-pl-level-next-str 
         v-pl-qnty-next-str 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE prev-next-show Dialog-Frame 
PROCEDURE prev-next-show :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
   assign
      v-pl-level-next-str  = IF v-pl-level-next <> 0 THEN STRING(v-pl-level-next) ELSE "-"
      v-pl-level-prev-str  = IF v-pl-level-prev <> 0 THEN STRING(v-pl-level-prev) ELSE "-"
      v-pl-qnty-next-str   = IF v-pl-qnty-next  <> 0 THEN STRING(v-pl-qnty-next ) ELSE "-"
      v-pl-qnty-prev-str   = IF v-pl-qnty-prev  <> 0 THEN STRING(v-pl-qnty-prev ) ELSE "-"
   .
   display
      v-pl-level-next-str
      v-pl-level-prev-str
      v-pl-qnty-next-str
      v-pl-qnty-prev-str
   WITH FRAME Dialog-Frame.
end.  /* do on error */
END PROCEDURE. /* prev-next-show */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-pl-level Dialog-Frame 
PROCEDURE save-pl-level :
do
transaction
on error undo, return error
:
   IF v-new THEN DO:
      create buf_pl-level .
      assign
         buf_pl-level.obj-type = p-obj-type
         buf_pl-level.obj-code = p-obj-code
         buf_pl-level.pl-code  = p-pl-code
      .
      
   END.
   assign
      buf_pl-level.pl-level = v-pl-level
      buf_pl-level.pl-qnty  = v-pl-qnty
   .
   find first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                                 and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                                 and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code 
                                                 and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                                 and buf_pl-level-attr.attr-code = "tarir-delta" 
                                                 no-error .
   if not available buf_pl-level-attr
   then do :
     create buf_pl-level-attr .
     assign
       buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
       buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
       buf_pl-level-attr.pl-code   = buf_pl-level.pl-code 
       buf_pl-level-attr.attr-code = "tarir-delta" 
       buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
     .
   end .
   assign buf_pl-level-attr.attr-value = string(v-pl-tarir-delta) .
   if v-pl-deltaV > 0
   then do :
     find first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                                   and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                                   and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code 
                                                   and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                                   and buf_pl-level-attr.attr-code = "deltaV" 
                                                   no-error .
     if not available buf_pl-level-attr
     then do :
       create buf_pl-level-attr .
       assign
         buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
         buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
         buf_pl-level-attr.pl-code   = buf_pl-level.pl-code 
         buf_pl-level-attr.attr-code = "deltaV" 
         buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
       .
     end .
     assign buf_pl-level-attr.attr-value = string(v-pl-deltaV) .
   end .
end. /* do on error */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

