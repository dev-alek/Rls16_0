&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

типы алкогол

Автор: Белоусов Илья Александрович
Дата создания: 03/10/07
Author: Ilia Belousov
Creation date: 03/10/07

Input:

Output:

*/


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc  as widget-handle no-undo .
define input  parameter bttns          as character     no-undo .
define input-output parameter rid-list       as character     no-undo . /* список recid'ов выбранных аписей */
define output parameter p-ok       as logical     no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "типы алкоголя".
define buffer br_alc-type for ub.alc-type.
define buffer br_alc-type-attr for ub.alc-type-attr.


define temp-table tt-alc-type no-undo like ub.alc-type
field alc-type            like ub.alc-type-attr.attr-value 
field rec                 as recid
.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define variable v-brws-mark      as character no-undo COLUMN-LABEL "*"        FORMAT "X(1)":U  .
define variable v-status         as character no-undo COLUMN-LABEL "Статус"   FORMAT "X(5)":U  .
define variable v-sort-column-name as character no-undo .
define variable v-ok    as logical      no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-alc-type

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 (IF ( INDEX (rid-list, string( tt-alc-type.rec ) ) > 0 ) THEN ("*") ELSE (" ")) @ v-brws-mark tt-alc-type.alc-type-code tt-alc-type.alc-type-name tt-alc-type.alc-type (IF (tt-alc-type.alc-type-status = 0) then ("") else ("помечен на удаление")) @ v-status
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define OPEN-QUERY-BROWSE-2 /* OPEN QUERY {&SELF-NAME} FOR EACH br_alc-type. */ run refresh-query in this-procedure.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 tt-alc-type
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 tt-alc-type


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-mark b-sel b-hist b-help rs-sort ~
b-add b-cng b-del b-load b-goods BROWSE-2
&Scoped-Define DISPLAYED-OBJECTS rs-sort

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-cng
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-goods
     LABEL "&Товары"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-load
     LABEL "&Загрузить"
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "&Выбрать"
     SIZE 10 BY 1.

DEFINE VARIABLE rs-sort AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&названию", 1,
"&коду", 2
     SIZE 17.5 BY .79 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      tt-alc-type
      SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _FREEFORM
  QUERY BROWSE-2 DISPLAY 
      (IF ( INDEX (rid-list, string( tt-alc-type.rec ) ) > 0 ) THEN ("*") ELSE (" ")) @ v-brws-mark
     tt-alc-type.alc-type-code
     tt-alc-type.alc-type-name FORMAT "x(80)"
     tt-alc-type.alc-type FORMAT "x(20)"
    (IF (tt-alc-type.alc-type-status = 0) then ("") else ("помечен на удаление")) @ v-status
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 80 BY 13.88 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11 WIDGET-ID 20
     b-sel AT ROW 1 COL 14 WIDGET-ID 22
     b-hist AT ROW 1 COL 61 WIDGET-ID 10
     b-help AT ROW 1 COL 71
     rs-sort AT ROW 2.17 COL 18 NO-LABEL WIDGET-ID 14
     b-add AT ROW 3 COL 1 WIDGET-ID 2
     b-cng AT ROW 3 COL 11 WIDGET-ID 4
     b-del AT ROW 3 COL 21 WIDGET-ID 6
     b-load AT ROW 3 COL 31 WIDGET-ID 8
     b-goods AT ROW 3 COL 41 WIDGET-ID 12
     BROWSE-2 AT ROW 4.21 COL 1 WIDGET-ID 200
     "Сортировать по:" VIEW-AS TEXT
          SIZE 15 BY .79 AT ROW 2.08 COL 3 WIDGET-ID 18
     SPACE(63.19) SKIP(15.29)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Виды алкогольной продукции"
         DEFAULT-BUTTON b-exit WIDGET-ID 100.


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
/* BROWSE-TAB BROWSE-2 b-goods Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BROWSE-2:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH br_alc-type. */
run refresh-query in this-procedure.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Типы алкогольных товаров */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable v-rr as recid no-undo.
    run ref/alctypei.w ( input parparentproc
                       , input {&add-def}
                       , input-output v-rr
                       ) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании вида алкоголя" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return no-apply .
    end.
  run refresh-query in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cng
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cng Dialog-Frame
ON CHOOSE OF b-cng IN FRAME Dialog-Frame /* Изменить */
DO:
   define variable v-rr as recid no-undo.
   if available tt-alc-type then do:
      assign
      v-rr = tt-alc-type.rec
      .
      run ref/alctypei.w ( input parparentproc
                         , input {&update}
                         , input-output v-rr
                         ) no-error.
      IF ERROR-STATUS:ERROR THEN DO:
         message
         vss-workfile vss-revision vss-description skip
         "Ошибка при редактировании вида алкоголя" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
         return no-apply .
      end.
   end.
   else do:
      run ref/alctypei.w ( input parparentproc
                         , input {&add-def}
                         , input-output v-rr
                         ) no-error.
      IF ERROR-STATUS:ERROR THEN DO:
         message
         vss-workfile vss-revision vss-description skip
         "Ошибка при создании вида алкоголя" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
         return no-apply .
      end.
   end.
   run refresh-query in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
   define buffer buf_alc-type-gds for ub.alc-type-gds.
   if available tt-alc-type then do:
      if can-find ( first buf_alc-type-gds
                    where buf_alc-type-gds.alc-type-inner-code = tt-alc-type.alc-type-inner-code
                    no-lock
                    ) then do:
         message "Удалить вид алкоголя невозможно," skip
                 " к нему прикреплены товары."
         view-as alert-box question
         .
         return no-apply.
      end.

      message "Удалить вид алкоголя?" skip
      tt-alc-type.alc-type-name
      view-as alert-box question
      buttons ok-cancel
      update v-ok as logical
      .
      if v-ok then do:
        run delete-alc-type in this-procedure.
        run refresh-query in this-procedure.
      end.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  p-ok = FALSE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods Dialog-Frame
ON CHOOSE OF b-goods IN FRAME Dialog-Frame /* Товары */
DO:
  if available tt-alc-type then do:
    run ref/alc-gds.w
      ( input parparentproc
      , input tt-alc-type.alc-type-inner-code
      , input tt-alc-type.create-user-db-num
      , input tt-alc-type.alc-type-name
      ) no-error.
    IF ERROR-STATUS :ERROR THEN DO:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при товаров, прикрепленных к виду алкоголя" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return no-apply .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
  if not available tt-alc-type then return .

  run ref/alctypeh.w ( input parparentproc
                     , input tt-alc-type.alc-type-inner-code
                     , input tt-alc-type.create-user-db-num
                     ) no-error .
   IF ERROR-STATUS:ERROR THEN DO:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка при просмотре истории видов алкоголя" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      return no-apply .
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-load
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-load Dialog-Frame
ON CHOOSE OF b-load IN FRAME Dialog-Frame /* Загрузить */
DO:
  run utl/i-alcref.p (input parparentproc ) no-error.
    IF ERROR-STATUS :ERROR THEN DO:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при загрузке видов алкоголя из файла" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return no-apply .
    end.
  run refresh-query in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
   define variable v-ok as logical no-undo .

   if not available tt-alc-type then do:
      return no-apply.
   end.
  
   { gbl/markstrn.i tt-alc-type rid-list tt-alc-type.rec }

   v-ok = {&browse-name}:select-next-row ().
   v-ok = {&browse-name}:refresh( )  in frame {&frame-name}.
   /*
   run refresh-query in this-procedure.
   */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбрать */
DO:
   IF  available tt-alc-type
   AND rid-list = ""
   then DO:
      assign
         rid-list = string( tt-alc-type.rec )
      .
   end.
   p-ok = true.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BROWSE-2 IN FRAME Dialog-Frame
DO:
    if ((lookup  ( "b-add" , bttns) > 0 ) AND ( v-cntxt-db-num = 0 )) then do: /* Проверка, чтобы нельзя было редактировать при отключенной кнопке */
        
     define variable v-rr as recid no-undo.
   if available tt-alc-type then do:
      assign
      v-rr = tt-alc-type.rec
      .
      run ref/alctypei.w ( input parparentproc
                         , input {&update}
                         , input-output v-rr
                         ) no-error.
      IF ERROR-STATUS:ERROR THEN DO:
         message
         vss-workfile vss-revision vss-description skip
         "Ошибка при редактировании вида алкоголя" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
         return no-apply .
      end.
   end.
   else do:
      run ref/alctypei.w ( input parparentproc
                         , input {&add-def}
                         , input-output v-rr
                         ) no-error.
      IF ERROR-STATUS:ERROR THEN DO:
         message
         vss-workfile vss-revision vss-description skip
         "Ошибка при создании вида алкоголя" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
         return no-apply .
      end.
   end.
   run refresh-query in this-procedure.
   end. /* if */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-sort Dialog-Frame
ON VALUE-CHANGED OF rs-sort IN FRAME Dialog-Frame
DO:
  assign
    rs-sort
  .
  run refresh-query in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/getcntxt.i get }

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_alc-type-lookup':U"
      {&cntxt-object}
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      TRUE
      v-ok
    }
    IF NOT v-ok then do:
       return.
    end.

{ gbl/app_help.i }

{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&FIRST-TABLE-IN-QUERY-BROWSE-2}"
  &sort-clmn_1    = "v-brws-mark"
  &sort-clmn_2    = "tt-alc-type.alc-type-code"
  &sort-clmn_3    = "tt-alc-type.alc-type-name"
  &sort-clmn_4    = "v-status"
  &sort-clmn_5    = "tt-alc-type.alc-type"
  &open-query =           "run refresh-query in this-procedure."
  &open-query-otherwise = "run refresh-query in this-procedure."
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   assign
      rs-sort = 1
  .
  assign
    tt-alc-type.alc-type-code  :resizable in browse {&browse-name} = true
    tt-alc-type.alc-type-name  :resizable in browse {&browse-name} = true
    v-status                   :resizable in browse {&browse-name} = true
    tt-alc-type.alc-type       :resizable in browse {&browse-name} = true 
  .

  RUN enable_UI in this-procedure.
  run post-enable-UI in this-procedure.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-alc-type Dialog-Frame
PROCEDURE delete-alc-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer del_alc-type for ub.alc-type.

  find first del_alc-type
       where recid(del_alc-type) = tt-alc-type.rec
       exclusive-lock
       no-error.
  if not available del_alc-type then DO:
     return error.
  end.
  delete del_alc-type.
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
  DISPLAY rs-sort
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-mark b-sel b-hist b-help rs-sort b-add b-cng b-del b-load
         b-goods BROWSE-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post-enable-UI Dialog-Frame
PROCEDURE post-enable-UI :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    disable
        b-add
        b-sel
        b-mark
        b-cng
        b-del
        b-load
    WITH FRAME  {&frame-name}.

    ENABLE
        b-add  WHEN  ((lookup  ( "b-add" , bttns) > 0 ) AND ( v-cntxt-db-num = 0 ))
        b-sel  WHEN  ( lookup  ( "b-sel" , bttns) > 0 )
        b-mark when  ( lookup  ( "b-mark", bttns) > 0 )
        b-cng  WHEN  ((lookup  ( "b-add" , bttns) > 0 ) AND ( v-cntxt-db-num = 0 ))
        b-del  WHEN  ((lookup  ( "b-add" , bttns) > 0 ) AND ( v-cntxt-db-num = 0 ))
        b-load WHEN  ((lookup  ( "b-add" , bttns) > 0 ) AND ( v-cntxt-db-num = 0 ))
    WITH FRAME  {&frame-name}.
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_alc-type-update':U"
      {&cntxt-object}
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      false
      v-ok
    }
    IF NOT v-ok then do:
      disable
         b-add
         b-cng
         b-del
         b-load
      WITH FRAME  {&frame-name}.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-query Dialog-Frame
PROCEDURE refresh-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 define variable v-alc as integer no-undo initial 0 .
  for each br_alc-type:
      find first tt-alc-type where tt-alc-type.alc-type-inner-code = br_alc-type.alc-type-inner-code no-lock no-error .
      if not available tt-alc-type then do:
      create tt-alc-type .
      BUFFER-COPY br_alc-type to tt-alc-type 
      assign
      tt-alc-type.rec = recid(br_alc-type).
      end.
      find br_alc-type-attr where br_alc-type-attr.alc-type-inner-code = br_alc-type.alc-type-inner-code
                              and br_alc-type-attr.attr-code = "alc-type" no-lock no-error .
      if available br_alc-type-attr then do:
        if br_alc-type-attr.attr-value = "1" then tt-alc-type.alc-type = "Алког. продукция" .
        else tt-alc-type.alc-type = "Пивная продукция" . 
      end.
      
  end.  

      if (lookup  ( "alc" , bttns) > 0 ) then do: 
        v-alc = 1 .
      end.
      if (lookup  ( "alc-p" , bttns) > 0 ) then do:
        v-alc = 2 .
      end.    
      
      case v-alc:
        when 0 then do:
            case rs-sort :
              when 1 then do:
                OPEN QUERY {&browse-name} FOR EACH tt-alc-type
                           by tt-alc-type.alc-type-name
                           indexed-reposition .
              end.
              OTHERWISE do:
                OPEN QUERY {&browse-name} FOR EACH tt-alc-type
                           by tt-alc-type.alc-type-code
                           indexed-reposition .
              end.
            end case.
        end.
        when 1 then do:
            case rs-sort :
              when 1 then do:
                OPEN QUERY {&browse-name} FOR EACH tt-alc-type where tt-alc-type.alc-type <> "Пивная продукция"
                           by tt-alc-type.alc-type-name
                           indexed-reposition .
              end.
              OTHERWISE do:
                OPEN QUERY {&browse-name} FOR EACH tt-alc-type where tt-alc-type.alc-type <> "Пивная продукция"
                           by tt-alc-type.alc-type-code
                           indexed-reposition .
              end.
            end case.
        end.
        when 2 then do:
            case rs-sort :
              when 1 then do:
                OPEN QUERY {&browse-name} FOR EACH tt-alc-type where tt-alc-type.alc-type = "Пивная продукция"
                           by tt-alc-type.alc-type-name
                           indexed-reposition .
              end.
              OTHERWISE do:
                OPEN QUERY {&browse-name} FOR EACH tt-alc-type where tt-alc-type.alc-type = "Пивная продукция"
                           by tt-alc-type.alc-type-code
                           indexed-reposition .
              end.
            end case.
        end.      
      end case.  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME