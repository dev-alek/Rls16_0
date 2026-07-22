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

Редактирование лицензий на поставку алкоголя.

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/


/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc  as widget-handle no-undo .
define input parameter p-mode as character no-undo.
define input-output parameter p-rr      as  recid no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование лицензий на поставку алкоголя".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ cmp/showinf.i  }

define variable RowID-list   as character no-undo .
define variable rid-list-supp as character no-undo .

define buffer buf_alc-supp-lic for ub.alc-supp-lic .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help b-supp f-seria f-number ~
f-date-get f-who-are-got f-date-from f-date-to b-types t-all f-client ~
f-types
&Scoped-Define DISPLAYED-OBJECTS f-seria f-number f-date-get f-who-are-got ~
f-date-from f-date-to t-all f-client f-types

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-supp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-obj"
     SIZE 3 BY .88.

DEFINE BUTTON b-types
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "типы"
     SIZE 3 BY .88 TOOLTIP "типы алкоголя, разрешенные к поставке по этой лицензии".

DEFINE VARIABLE f-client AS CHARACTER FORMAT "X(40)":U  INITIAL "Не выбран поставщик"
      VIEW-AS TEXT
     SIZE 41.3 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-from AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Дествует с"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-get AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Дата выдачи"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-to AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-number AS CHARACTER FORMAT "X(16)":U
     LABEL "номер"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-seria AS CHARACTER FORMAT "X(16)":U
     LABEL "Серия"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-types AS CHARACTER FORMAT "X(10)":U INITIAL "не выбраны"
      VIEW-AS TEXT
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-who-are-got AS CHARACTER FORMAT "X(30)":U
     LABEL "Кем выдана"
     VIEW-AS FILL-IN
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE t-all AS LOGICAL INITIAL no
     LABEL "все типы алкоголя"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 42
     b-supp AT ROW 2.08 COL 1 WIDGET-ID 4
     f-seria AT ROW 3.13 COL 5 WIDGET-ID 2
     f-number AT ROW 3.13 COL 34.5 COLON-ALIGNED WIDGET-ID 8
     f-date-get AT ROW 4.21 COL 12 COLON-ALIGNED WIDGET-ID 10
     f-who-are-got AT ROW 5.25 COL 12 COLON-ALIGNED WIDGET-ID 12
     f-date-from AT ROW 6.33 COL 12 COLON-ALIGNED WIDGET-ID 14
     f-date-to AT ROW 6.33 COL 30.5 COLON-ALIGNED WIDGET-ID 16
     b-types AT ROW 7.42 COL 22.5 WIDGET-ID 20
     t-all AT ROW 7.5 COL 2 WIDGET-ID 18
     f-client AT ROW 2 COL 10 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     f-types AT ROW 7.42 COL 32 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     SPACE(9.30) SKIP(0.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Лицензия поставщика алкоголя"
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

/* SETTINGS FOR FILL-IN f-seria IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Лицензия поставщика алкоголя */
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
      f-seria
      f-number
      f-date-get
      f-who-are-got
      f-date-from
      f-date-to
      t-all
   .

  IF rid-list-supp = "" then DO:
     message "Выберите поставщика"
     view-as alert-box error.
     apply "entry"  to b-supp.
     return no-apply.
  end.

  if f-seria = "" then do:
     message "Введите серию лицензии"
     view-as alert-box error.
     apply "entry"  to f-seria.
     return no-apply.
  end.
  if f-number = "" then do:
     message "Введите номер лицензии"
     view-as alert-box error.
     apply "entry"  to f-number.
     return no-apply.
  end.
  if f-date-get = ? then do:
     message "Введите дату выдачи лицензии"
     view-as alert-box error.
     apply "entry"  to f-date-get.
     return no-apply.
  end.
  if f-date-from = ? then do:
     message "Введите дату начала действия лицензии"
     view-as alert-box error.
     apply "entry"  to f-date-from.
     return no-apply.
  end.
  if f-date-to = ? then do:
     message "Введите дату окончания действия лицензии"
     view-as alert-box error.
     apply "entry"  to f-date-to.
     return no-apply.
  end.
  if f-who-are-got = "" then do:
     message "Введите кем выдана лицензия"
     view-as alert-box error.
     apply "entry"  to f-who-are-got.
     return no-apply.
  end.
  if not t-all
  and RowID-list = "" then do:
     message "Введите типы алкоголя, разрешенные к поставке по этой лицензии"
     view-as alert-box error.
     apply "entry"  to b-types.
     return no-apply.
  end.

  do
  transaction:
   if p-rr = ? then do:
      run create-lic in this-procedure.
   end.
   else do:
      run update-lic in this-procedure.
   end.


   run update-alc-type in this-procedure.
  end. /* v-ok */


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-supp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-supp Dialog-Frame
ON CHOOSE OF b-supp IN FRAME Dialog-Frame /* BUTTON-obj */
DO:
   define buffer buf_clients for ub.clients .
      run ref/cli-all.w ( input  parparentproc
                      , input  "b-sel"
                      , input  {&all}
                      , input  {&all}
                      , input  {&current}
                      , input  ?
                      , input  ",,,,,,NO,,"
                      , input  ""
                      , output rid-list-supp
                      ) .
      IF rid-list-supp <> "" then DO:
         find first buf_clients
              where recid(buf_clients) = INTEGER(ENTRY(1, rid-list-supp))
              no-lock
              no-error
              .
         if available buf_clients then DO:
            assign
                f-client = substitute( "&1&2, &3", buf_clients.obj-code, buf_clients.obj-type, buf_clients.obj-name )
            .
         end.
      END.
   assign
      f-seria
      f-number
      f-date-get
      f-who-are-got
      f-date-from
      f-date-to
      t-all
   .
  RUN enable_UI.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-types
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-types Dialog-Frame
ON CHOOSE OF b-types IN FRAME Dialog-Frame /* типы */
DO:

  define buffer buf_alc-supp-lic-type for ub.alc-supp-lic-type .
  define buffer buf_alc-type     for ub.alc-type .
  define variable v-ok as logical no-undo .
  define variable v-count as integer no-undo .

  if t-all then do:
     message 'Выставлен признак "все типы алкоголя" ' SKIP
             'Снять признак и продолжить выбор типов алкоголя?'
     view-as alert-box question
     buttons ok-cancel
     update v-ok
     .
     if not v-ok then do:
        return no-apply.
     end.
     else do:
         assign
            t-all = false
         .
     end.

  end.

  run ref/alc-type.w
    ( input Parparentproc
    , input "b-sel,b-mark"
    , input-OUTPUT RowID-list
    , output v-ok
      ).
  if RowID-list = ""
  and not t-all
  then do:
    assign
     f-types = "не выбраны"
    .
  end.
  else do:
    assign
     f-types = "выбраны"
     .
  end.
   assign
      f-seria
      f-number
      f-date-get
      f-who-are-got
      f-date-from
      f-date-to
      t-all
   .

  RUN enable_UI.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-all Dialog-Frame
ON VALUE-CHANGED OF t-all IN FRAME Dialog-Frame /* все типы алкоголя */
DO:
   assign
      f-seria
      f-number
      f-date-get
      f-who-are-got
      f-date-from
      f-date-to
      t-all
   .
   IF t-all
   THEN DO:
      ASSIGN
         RowID-list = ""
         f-types = "выбраны"
      .
   END.
   ELSE DO:

      assign
         f-types = "не выбраны"
      .
   END.
   RUN enable_UI.
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
{ gbl/ed_date.i f-date-from }
{ gbl/ed_date.i f-date-to }
{ gbl/ed_date.i f-date-get }
{ gbl/getcntxt.i get }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  define buffer bf_clients for ub.clients.
  define buffer bf_alc-type for ub.alc-type.
  define buffer bf_alc-supp-lic-type for ub.alc-supp-lic-type.

  if p-mode = {&update} then do
  transaction:
     if p-rr = ? then do:
        return error "ссылка на лицензию не передана".
     end.
     find first buf_alc-supp-lic
          where recid(buf_alc-supp-lic) = p-rr
          exclusive-lock
          no-error
          .
     if not available buf_alc-supp-lic then do:
        return error "неправильная ссылка на лицензию".
     end.
     assign
       f-seria       = buf_alc-supp-lic.seria
       f-number      = buf_alc-supp-lic.number
       f-date-get    = buf_alc-supp-lic.date-get
       f-who-are-got = buf_alc-supp-lic.who-are-got
       f-date-from   = buf_alc-supp-lic.date-from
       f-date-to     = buf_alc-supp-lic.date-to
       t-all         = if buf_alc-supp-lic.all-type >= 1 then true else false
     .
     find first bf_clients
          where bf_clients.obj-type = buf_alc-supp-lic.cli-type
            and bf_clients.obj-code = buf_alc-supp-lic.cli-code
          no-lock
          no-error
          .
     if not available bf_clients then do:
        return error substitute ("Поставщик &1&2 не найден.", buf_alc-supp-lic.cli-code, buf_alc-supp-lic.cli-type).
     end.
     assign
        f-client = substitute( "&1&2, &3", bf_clients.obj-code, bf_clients.obj-type, bf_clients.obj-name )
     .
      { gbl/markstrn.i bf_clients rid-list-supp }

     if t-all
      then do:
         assign
            f-types = "выбраны"
         .
      end.
      else do:
         for each  bf_alc-supp-lic-type
             where bf_alc-supp-lic-type.alc-supp-lic-code = buf_alc-supp-lic.alc-supp-lic-code
             no-lock,
             first bf_alc-type
             where bf_alc-type.alc-type-inner-code = bf_alc-supp-lic-type.alc-type-inner-code
             no-lock
             :
             { gbl/markstrn.i bf_alc-type RowID-list }
         end.
         if RowID-list = "" then DO:
            assign
               f-types = "не выбраны"
            .
         end.
         else do:
            assign
               f-types = "выбраны"
            .
         end.
      end.
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-lic Dialog-Frame
PROCEDURE create-lic :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_clients for ub.clients .
    define variable v-code as integer no-undo .

     find first buf_clients
          where recid(buf_clients) = INTEGER(ENTRY(1, rid-list-supp))
          no-lock
          no-error
          .
     v-code = next-value(s-alc-supp-lic, {&db-name_schema}).
     create buf_alc-supp-lic.
     assign
       buf_alc-supp-lic.alc-supp-lic-code = v-code
       buf_alc-supp-lic.seria       = f-seria
       buf_alc-supp-lic.number      = f-number
       buf_alc-supp-lic.date-get    = f-date-get
       buf_alc-supp-lic.who-are-got = f-who-are-got
       buf_alc-supp-lic.date-from   = f-date-from
       buf_alc-supp-lic.date-to     = f-date-to
       buf_alc-supp-lic.all-type    = if t-all  then 1 else 0
       buf_alc-supp-lic.cli-code    = buf_clients.obj-code
       buf_alc-supp-lic.cli-type    = buf_clients.obj-type
       buf_alc-supp-lic.create-user-db-num = v-cntxt-db-num
       buf_alc-supp-lic.lic-status         = 0
       buf_alc-supp-lic.create-user        = v-cntxt-userid
       buf_alc-supp-lic.corr-user-name     = v-cntxt-userid
       buf_alc-supp-lic.create-date        = today
       buf_alc-supp-lic.corr-date          = today
       buf_alc-supp-lic.create-time        = time
       buf_alc-supp-lic.corr-time          = time
     .
      assign
         p-rr = recid (buf_alc-supp-lic)
      .

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
  DISPLAY f-seria f-number f-date-get f-who-are-got f-date-from f-date-to t-all
          f-client f-types
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help b-supp f-seria f-number f-date-get f-who-are-got
         f-date-from f-date-to b-types t-all f-client f-types
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-alc-type Dialog-Frame
PROCEDURE update-alc-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_alc-supp-lic-type for ub.alc-supp-lic-type .
define buffer buf_alc-type     for ub.alc-type     .

  define variable v-count as integer no-undo .


    for each  buf_alc-supp-lic-type
        where buf_alc-supp-lic-type.alc-supp-lic-code = buf_alc-supp-lic.alc-supp-lic-code
        exclusive-lock,
        first buf_alc-type
        where buf_alc-type.alc-type-inner-code = buf_alc-supp-lic-type.alc-type-inner-code
        no-lock
        :
        if index(RowID-list, trim( string( recid(buf_alc-type) , "->>>>>>>>>>>9":U ) )) = 0 THEN do:
           delete buf_alc-supp-lic-type.
        end.
    end.

    DO v-count = 1 TO NUM-ENTRIES(RowID-list)
    on error undo, next
    :
      find first buf_alc-type
         where recid( buf_alc-type ) = INTEGER(ENTRY(v-count, RowID-list))
         NO-LOCK
         no-error.

      IF AVAILABLE buf_alc-type
      and not can-find( first buf_alc-supp-lic-type
                        where buf_alc-supp-lic-type.alc-supp-lic-code   = buf_alc-supp-lic.alc-supp-lic-code
                          and buf_alc-supp-lic-type.alc-type-inner-code = buf_alc-type.alc-type-inner-code)
      THEN DO:
         CREATE buf_alc-supp-lic-type.
         ASSIGN
            buf_alc-supp-lic-type.alc-supp-lic-code   = buf_alc-supp-lic.alc-supp-lic-code
            buf_alc-supp-lic-type.alc-type-inner-code = buf_alc-type.alc-type-inner-code
            buf_alc-supp-lic-type.corr-date = today
            buf_alc-supp-lic-type.corr-time = time
            buf_alc-supp-lic-type.corr-user-name  = v-cntxt-userid
            buf_alc-supp-lic-type.create-alc-type-user-db-num = v-cntxt-db-num
            buf_alc-supp-lic-type.create-date = today
            buf_alc-supp-lic-type.create-time = time
            buf_alc-supp-lic-type.create-user = v-cntxt-userid
            buf_alc-supp-lic-type.create-user-db-num = v-cntxt-db-num
         .
      END.
    end.

    FOR EACH buf_alc-supp-lic-type
        EXCLUSIVE-LOCK
        :
        find first buf_alc-type
             where buf_alc-type.alc-type-inner-code = buf_alc-supp-lic-type.alc-type-inner-code
             NO-LOCK
             no-error
             .

         IF NOT AVAILABLE buf_alc-type
         OR INDEX( RowID-list, STRING(recid( buf_alc-type ))) = 0
         THEN DO:
            DELETE buf_alc-supp-lic-type.
         END.
    END.

END PROCEDURE. /* update-alc-type */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-lic Dialog-Frame
PROCEDURE update-lic :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_clients for ub.clients .

     find first buf_clients
          where recid(buf_clients) = INTEGER(ENTRY(1, rid-list-supp))
          no-lock
          no-error
          .
     assign
       buf_alc-supp-lic.seria       = f-seria
       buf_alc-supp-lic.number      = f-number
       buf_alc-supp-lic.date-get    = f-date-get
       buf_alc-supp-lic.who-are-got = f-who-are-got
       buf_alc-supp-lic.date-from   = f-date-from
       buf_alc-supp-lic.date-to     = f-date-to
       buf_alc-supp-lic.all-type    = if t-all  then 1 else 0
       buf_alc-supp-lic.cli-code    = buf_clients.obj-code
       buf_alc-supp-lic.cli-type    = buf_clients.obj-type
       buf_alc-supp-lic.corr-user-name     = v-cntxt-userid
       buf_alc-supp-lic.corr-date          = today
       buf_alc-supp-lic.corr-time          = time
     .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
