&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER cli_prod FOR ub.clients.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Смена производителя по списку товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/04/03
Author: Bakhtadze Natalya
Creation date: 06/04/03

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Смена производителя по списку товаров".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/key-rec.i  }
{ nws/db-rec.i   }

define variable v-log-file as character no-undo init "pren-art.log".
define variable v-not-two-commit as logical no-undo .

define buffer buf_db for ub.db .

define stream LOgStream.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES cli_prod

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH cli_prod SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH cli_prod SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame cli_prod
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame cli_prod


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.clients.obj-type ub.clients.obj-code ~
ub.clients.obj-name
&Scoped-define ENABLED-TABLES ub.clients
&Scoped-define FIRST-ENABLED-TABLE ub.clients
&Scoped-Define ENABLED-OBJECTS b-quit B-replace B-list B-Help button-prod ~
T-mes
&Scoped-Define DISPLAYED-FIELDS ub.clients.obj-type ub.clients.obj-code ~
ub.clients.obj-name
&Scoped-define DISPLAYED-TABLES ub.clients
&Scoped-define FIRST-DISPLAYED-TABLE ub.clients
&Scoped-Define DISPLAYED-OBJECTS T-mes f-log-file

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-list
     LABEL "&Список"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-replace
     LABEL "&Заменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON button-prod
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "button-prod"
     SIZE 3 BY .87.

DEFINE VARIABLE f-log-file AS CHARACTER FORMAT "X(256)":U
     LABEL "Log-файл"
     VIEW-AS FILL-IN
     SIZE 68.4 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE T-mes AS LOGICAL INITIAL no
     LABEL "Выводить сообщения на экран"
     VIEW-AS TOGGLE-BOX
     SIZE 44.8 BY .8 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      cli_prod SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-replace AT ROW 1 COL 11
     B-list AT ROW 1 COL 31
     B-Help AT ROW 1 COL 71
     ub.clients.obj-type AT ROW 2.87 COL 22.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6.9 BY 1
     ub.clients.obj-code AT ROW 2.93 COL 30.4 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 14.6 BY 1
     button-prod AT ROW 3 COL 51.6
     T-mes AT ROW 5.67 COL 2.8
     f-log-file AT ROW 6.97 COL 2.4
     ub.clients.obj-name AT ROW 4.47 COL 2.5 NO-LABEL
           VIEW-AS TEXT
          SIZE 52.4 BY .67
     "Выбор производителя" VIEW-AS TEXT
          SIZE 20.3 BY .87 AT ROW 3.03 COL 2.6
          FGCOLOR 4
     SPACE(59.84) SKIP(4.34)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Смена производителя по списку товаров"
         DEFAULT-BUTTON B-replace CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: cli_prod B "?" ? ub clients
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

/* SETTINGS FOR FILL-IN f-log-file IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN ub.clients.obj-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.cli_prod"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Смена производителя по списку товаров */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-list Dialog-Frame
ON CHOOSE OF B-list IN FRAME Dialog-Frame /* Список */
DO:
   run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-replace
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-replace Dialog-Frame
ON CHOOSE OF B-replace IN FRAME Dialog-Frame /* Заменить */
DO:
  run proc-exit in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME button-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL button-prod Dialog-Frame
ON CHOOSE OF button-prod IN FRAME Dialog-Frame /* button-prod */
DO:
define variable cli-list as character no-undo.
    assign
    cli-list = ""
    .
    run ref/cli-all.w ( input parparentproc
                  , "b-sel"
                  , {&pro}
                  , {&all}
                  ,  {&current}
                  , ?
                  , ",,,,,,NO,,"
                  , ?
                  , output cli-list ) .
    if cli-list <> ""
    then do:
        FIND FIRST ub.clients no-lock WHERE recid( ub.clients ) = int( cli-list )  .
        display
        ub.clients.obj-name
        ub.clients.obj-type
        ub.clients.obj-code
        with frame {&frame-name}
        .
    end.
    else do:
        assign
        ub.clients.obj-name:screen-value = ""
        ub.clients.obj-type:screen-value = "":U
        ub.clients.obj-code:screen-value = "":U
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ub.clients.obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.clients.obj-code Dialog-Frame
ON LEAVE OF ub.clients.obj-code IN FRAME Dialog-Frame /* Объект */
DO:
      FIND ub.clients WHERE ub.clients.obj-type = input frame {&frame-name} clients.obj-type
                                and ub.clients.obj-code = input frame {&frame-name} clients.obj-code
                                no-lock no-error.
    if available ub.clients then
        DISPLAY ub.clients.obj-name with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ub.clients.obj-code Dialog-Frame
ON RETURN OF ub.clients.obj-code IN FRAME Dialog-Frame /* Объект */
DO:
define variable cli-list as character no-undo.
    FIND ub.clients WHERE ub.clients.obj-type = input frame {&frame-name} clients.obj-type
                                and ub.clients.obj-code = input frame {&frame-name} clients.obj-code
                                no-lock no-error.
    if available ub.clients then   do:
            DISPLAY ub.clients.obj-name with frame {&frame-name}.
            return no-apply.
        end.
    else   do:
            assign
             cli-list = ""
             .
            run ref/cli-all.w (input parparentproc
                          , "b-sel"
                          , {&pro}
                          , {&all}
                          , {&current}
                          , ?
                          , ",,,,,,NO,,"
                          , ?
                          , output cli-list) .
            if cli-list = "" then   do:
                    apply "entry" to ub.clients.obj-code in frame {&frame-name}.
                    return no-apply.
                end.
            FIND ub.clients WHERE recid (ub.clients) = integer(cli-list) NO-LOCK .
            DISPLAY ub.clients.obj-type ub.clients.obj-code ub.clients.obj-name with frame {&frame-name}.
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  RUN MYenable.

  find first buf_db no-lock
    where buf_db.db-num > 0
    no-error .
  if available buf_db then do:
    assign
      v-not-two-commit = false
    .
  end.
  else do:
    assign
      v-not-two-commit = true
    .
  end.

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY T-mes f-log-file
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.clients THEN
    DISPLAY ub.clients.obj-type ub.clients.obj-code ub.clients.obj-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-replace B-list B-Help ub.clients.obj-type ub.clients.obj-code
         button-prod T-mes ub.clients.obj-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE err-msg Dialog-Frame
PROCEDURE err-msg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-msg      as character no-undo .
define input parameter p-silence  as logical no-undo .
define input parameter p-err-flag as logical   no-undo .


  do
  on error undo, return error
  :

    if p-silence = false then do:
      if p-err-flag = true then do:
        message
          p-msg
          view-as alert-box error .
      end.
      else do:
        message
          p-msg
          view-as alert-box information .
      end.
    end.
    if v-log-file <> "":U then do:
      output stream Logstream to value(v-log-file) append.
      put stream LogStream unformatted
      p-msg skip.
      output stream Logstream close.
    end.

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    DISPLAY
    {&cmp} @ ub.clients.obj-type
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-replace B-list B-Help button-prod ub.clients.obj-type
         ub.clients.obj-code ub.clients.obj-name T-mes
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-exit Dialog-Frame
PROCEDURE proc-exit :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable loc#log as logical no-undo.
define variable v-ok as integer no-undo.
define variable v-ii as integer .
define variable v-err as integer .
define variable v-msg as character no-undo.
define variable v-err-mes as character no-undo.

define buffer buf_goods for ub.goods .
define variable v-key-rec as character no-undo .
define variable v-param   as character no-undo .

assign
frame {&frame-name}
T-mes.
if not can-find(first gds-list) then do:
    message
    "Вы не выбрали ни одного товара"
    view-as alert-box.
    return error.
end.
find first ub.clients no-lock where
ub.clients.obj-type = input frame {&frame-name} clients.obj-type
AND ub.clients.obj-code = input frame {&frame-name} clients.obj-code no-error.
if not available ub.clients then do:
    message
    "Вы не выбрали производителя"
    view-as alert-box.
    return error.
end.
if ub.clients.obj-type = {&shop} or ub.clients.obj-type = {&stock} then do:
    message
    "Склад/магазин не может быть производителем !"
    view-as alert-box.
    return error.
 end.
message
"Для всех товаров выбранного Вами списка будет проведена замена производителя на" skip
ub.clients.obj-type ub.clients.obj-code ub.clients.obj-name skip
"для больших списков это процедура может занять много времени" skip
"Продолжить?"
view-as alert-box QUESTION buttons YES-NO update loc#log.
if not loc#log then return error.

run waitfram-show in this-procedure ("Ждите").
run set-file-title in this-procedure (v-log-file) .
for each gds-list
on error undo, next
on stop undo, next
:
    assign
    v-ii = v-ii + 1
    .
    if gds-list.prod-type = clients.obj-type and
    gds-list.prod-code = clients.obj-code  then do:
      assign
      v-msg = "Товар" + {&space-char} + string(gds-list.gds-code) + {&space-char} +
      "артикул" + {&space-char} + gds-list.artic + {&space-char} +
      gds-list.prod-type + string(gds-list.prod-code) + {&space-char} + "не требует замены производителя на" + {&space-char} +
      clients.obj-type + string(clients.obj-code) + {&new-line} + "уже имеет производителя" + {&space-char} +
      clients.obj-type + string(clients.obj-code)
      .
      run err-msg in this-procedure (input (v-msg), input not t-mes, input false).
      next.
    end.
    assign
    v-err-mes = "":U.

    if v-not-two-commit = false then do:
      find first buf_goods no-lock
        where buf_goods.artic     = gds-list.artic
          and buf_goods.prod-type = gds-list.prod-type
          and buf_goods.prod-code = gds-list.prod-code
      .
      run gen-key-rec( input {&table_goods}
                      ,input (buffer buf_goods:handle )
                      ,output v-key-rec
                    ) no-error.
      if error-status :error then do:
        assign
        v-msg = "Ошибка при генерации уникального ключа для товара" + {&space-char} + string(gds-list.gds-code)
        + {&space-char} + "артикул" + {&space-char} + gds-list.artic + {&space-char} +
        gds-list.prod-type + string(gds-list.prod-code) + {&space-char}
        .
        run err-msg in this-procedure (input (v-msg), input not t-mes, input true).
        next.
      end.

      assign
        v-param = substitute( "&1&2&3&2&4&2&5&2&6&2&7&2&8"
                              ,gds-list.gds-code
                              ,{&delim-par}
                              ,gds-list.artic
                              ,gds-list.prod-type
                              ,gds-list.prod-code
                              ,gds-list.artic
                              ,clients.obj-type
                              ,clients.obj-code
                            ).
      run nws/db-rec.p ( input {&ren-art}
                    ,input v-key-rec
                    ,input v-param
                  ) no-error .
      if error-status:error or return-value = "false":U then do:
        assign
        v-err = v-err + 1.
        assign
        v-msg = "Товар" + {&space-char} + string(gds-list.gds-code) + {&space-char} +
        "артикул" + {&space-char} + gds-list.artic + {&space-char} +
        gds-list.prod-type + string(gds-list.prod-code) + {&space-char} + "ОШИБКА замены производителя на" + {&space-char} +
        clients.obj-type + string(clients.obj-code) + {&new-line} + (if not return-value = "false":U then return-value else v-err-mes)
        .
        run err-msg in this-procedure (input (v-msg), input not t-mes, input true).
      end.
      else do:
        if v-err-mes = "":U then
          assign
          v-ok = v-Ok + 1
          .
        assign
        v-msg = "Товар" + {&space-char} + string(gds-list.gds-code) + {&space-char} +
        "артикул" + {&space-char} + gds-list.artic + {&space-char} +
        gds-list.prod-type + string(gds-list.prod-code) + {&space-char} + "замена  производителя на" + {&space-char} +
        clients.obj-type + string(clients.obj-code) + {&new-line} + v-err-mes
        .
        if v-err-mes = "":U then do:
          assign
            v-msg = v-msg + {&new-line} + "Замена производителя начата. Направлен запрос во все БД. После получения положительного ответа производитель будет заменен"
          .

        end.
        run err-msg in this-procedure (input (v-msg), input not t-mes, input false).
      end.
    end.
    else do:
      run utl/ren-art.p ( input gds-list.gds-code
                    ,input gds-list.artic
                    ,input gds-list.prod-type
                    ,input gds-list.prod-code
                    ,input gds-list.artic
                    ,input clients.obj-type
                    ,input clients.obj-code
                   ) no-error.
      if error-status:error or return-value = "false":U then do:
        assign
        v-err = v-err + 1.
        assign
        v-msg = "Товар" + {&space-char} + string(gds-list.gds-code) + {&space-char} +
        "артикул" + {&space-char} + gds-list.artic + {&space-char} +
        gds-list.prod-type + string(gds-list.prod-code) + {&space-char} + "ОШИБКА замены производителя на" + {&space-char} +
        clients.obj-type + string(clients.obj-code) + {&new-line} + (if not return-value = "false":U then return-value else v-err-mes)
        .
        run err-msg in this-procedure (input (v-msg), input not t-mes, input true).
      end.
      else do:
        if v-err-mes = "":U then
        assign
        v-ok = v-Ok + 1
        .
        assign
        v-msg = "Товар" + {&space-char} + string(gds-list.gds-code) + {&space-char} +
        "артикул" + {&space-char} + gds-list.artic + {&space-char} +
        gds-list.prod-type + string(gds-list.prod-code) + {&space-char} + "замена  производителя на" + {&space-char} +
        clients.obj-type + string(clients.obj-code) + {&new-line} + v-err-mes
        .
        run err-msg in this-procedure (input (v-msg), input not t-mes, input false).
      end.
    end.

    if v-ii modulo 10 = 0 then do:
        run waitfram-show in this-procedure("Обработано" + {&space-char} + string(v-ii)).
    end.
    delete gds-list.
end.
for each gds-list:
    delete gds-list.
end.
run waitfram-hide in this-procedure.
message
"Утилита завершила работу" skip
"Из выбранных Вами" v-ii "товаров"
"удалось заменить производителя для" v-ok "товаров" skip
"ошибок - " v-err skip
view-as alert-box information.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-file-title Dialog-Frame
PROCEDURE set-file-title :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-filename as character no-undo.

define variable v-today as date no-undo.
define variable v-time as integer no-undo.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .

output stream Logstream to value(p-filename) append.
run cur-time in this-procedure(output v-today, output v-time).
Put stream LogStream unformatted
"**************************************************" skip
"USER:":U v-cntxt-userid skip
string(v-today, "99/99/9999") {&space-char} string(v-time, "HH:MM:SS")
skip.
output stream LogStream close.
run gbl/filename.p (
                         input p-filename
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ).
display
v-full-path @ f-log-file
with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
