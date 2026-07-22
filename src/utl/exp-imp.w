&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Экспорт-импорт локальных таблиц УБД - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/24/05
Author: Bakhtadze Natalya
Creation date: 09/24/05


*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---
         */
define input parameter parparentproc as widget-handle no-undo .
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Экспорт-импорт локальных таблиц УБД - запуск" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }

define variable v_os-dir   AS CHAR NO-UNDO INIT "".
define variable v_os-dir-type   AS CHAR NO-UNDO INIT "".
define variable v_can-write as logical no-undo.

{ gbl/waitfram.i }
{ cmp/operfile.i }
{ utl/imp-expd.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-groups B-exit B-export B-import B-Help ~
B-dir T-rht T-gen T-flt T-pbc T-glb T-scl T-usr dir-name F-rht F-gen F-flt ~
F-pbc F-scl F-usr
&Scoped-Define DISPLAYED-OBJECTS T-rht T-gen T-flt T-pbc T-glb T-scl T-usr ~
dir-name F-rht F-gen F-flt F-pbc F-scl F-usr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-dir
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-export
     LABEL "&Экспорт"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-import
     LABEL "&Импорт"
     SIZE 10 BY 1.

DEFINE VARIABLE dir-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 49.6 BY 1 NO-UNDO.

DEFINE VARIABLE F-flt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-gen AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-pbc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-rht AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-scl AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-seq AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-usr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE RECTANGLE RECT-groups
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 86.7 BY 13.2.

DEFINE VARIABLE T-flt AS LOGICAL INITIAL yes
     LABEL "Фильтры"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-gen AS LOGICAL INITIAL yes
     LABEL "Параметры"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-glb AS LOGICAL INITIAL no
     LABEL "Глобальные коды"
     VIEW-AS TOGGLE-BOX
     SIZE 26.5 BY 1.07 NO-UNDO.

DEFINE VARIABLE T-pbc AS LOGICAL INITIAL yes
     LABEL "Вес и взвеш коды"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-rht AS LOGICAL INITIAL yes
     LABEL "Права"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-scl AS LOGICAL INITIAL yes
     LABEL "Весы"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-seq AS LOGICAL INITIAL yes
     LABEL "Счетчики"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-usr AS LOGICAL INITIAL yes
     LABEL "Пользователи"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.1
     B-export AT ROW 1 COL 21
     B-import AT ROW 1 COL 31
     B-Help AT ROW 1 COL 82
     B-dir AT ROW 2.43 COL 81.3
     T-rht AT ROW 5.77 COL 3
     T-gen AT ROW 7 COL 3
     T-flt AT ROW 8.27 COL 3
     T-pbc AT ROW 9.5 COL 3
     T-glb AT ROW 9.5 COL 61 WIDGET-ID 2
     T-scl AT ROW 10.77 COL 3
     T-usr AT ROW 12 COL 3
     T-seq AT ROW 13.27 COL 3
     dir-name AT ROW 2.43 COL 28.6 COLON-ALIGNED NO-LABEL
     F-rht AT ROW 5.77 COL 27 COLON-ALIGNED NO-LABEL
     F-gen AT ROW 7 COL 27 COLON-ALIGNED NO-LABEL
     F-flt AT ROW 8.27 COL 27 COLON-ALIGNED NO-LABEL
     F-pbc AT ROW 9.5 COL 27 COLON-ALIGNED NO-LABEL
     F-scl AT ROW 10.77 COL 27 COLON-ALIGNED NO-LABEL
     F-usr AT ROW 12 COL 27 COLON-ALIGNED NO-LABEL
     F-seq AT ROW 13.27 COL 27 COLON-ALIGNED NO-LABEL
     "Название файла экспорта-импорта" VIEW-AS TEXT
          SIZE 33.5 BY .8 AT ROW 4.43 COL 29.6
          FGCOLOR 4
     "Группы данных" VIEW-AS TEXT
          SIZE 20.1 BY .8 AT ROW 4.43 COL 3.4
          FGCOLOR 4
     "Директория экспорта/импорта" VIEW-AS TEXT
          SIZE 27.9 BY 1 AT ROW 2.37 COL 2
          FGCOLOR 4
     RECT-groups AT ROW 3.87 COL 1.8
     SPACE(0.49) SKIP(0.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экспорт-импорт локальных таблиц УБД"
         DEFAULT-BUTTON B-exit.


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

/* SETTINGS FOR FILL-IN F-seq IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       F-seq:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-seq IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-seq:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Экспорт-импорт локальных таблиц УБД */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dir Dialog-Frame
ON CHOOSE OF B-dir IN FRAME Dialog-Frame
DO:

    run gbl/dir-sel.p (output v_os-dir,
                output v_os-dir-type,
                output v_can-write) no-error.
    if error-status:error then return no-apply.
    dir-name = v_os-dir.
    display
    dir-name
    with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-export Dialog-Frame
ON CHOOSE OF B-export IN FRAME Dialog-Frame /* Экспорт */
DO:
  if NOT v_can-write then do:
    message "Данная директория доступна только для чтения"
    view-as alert-box ERROR.
    return no-apply.
  end.
  run waitfram-show in this-procedure ( input "Ждите..." ).
  run proc-b-ie in this-procedure ( input "export":U).
  run waitfram-hide in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-import Dialog-Frame
ON CHOOSE OF B-import IN FRAME Dialog-Frame /* Импорт */
DO:
 run waitfram-show in this-procedure ( input "Ждите..." ).
 run proc-b-ie in this-procedure ( input "import":U).
 run waitfram-hide in this-procedure .
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
    file-info:file-name = ".".
    assign
    dir-name = file-info:full-pathname
    v_os-dir-type = file-info :file-type
    v_can-write = (index(v_os-dir-type, "W") > 0)
   .
  FIND FIRST ub.sys-ctrl No-LOCK.
  FIND FIRST ub.db no-LOCK where
             ub.db.db-num = sys-ctrl.db-num.
    assign
    f-rht = corr-file-name(db.db-key) + ".":U +   "rht"
    F-flt = corr-file-name(db.db-key) + ".":U +   "flt"
    F-pbc = corr-file-name(db.db-key) + ".":U +   "pbc"
    F-scl = corr-file-name(db.db-key) + ".":U +   "scl"
    F-usr = corr-file-name(db.db-key) + ".":U +   "usr"
    F-gen = corr-file-name(db.db-key) + ".":U +   "gen"
    F-seq = corr-file-name(db.db-key) + ".":U +   "seq"
    .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-iefile Dialog-Frame
PROCEDURE check-iefile :
/*------------------------------------------------------------------------------
  Purpose:  проверка наличия файлов в выбранной директории
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-dir-name as character no-undo.
DEFINE INPUT PARAMETER p-file-extension as character no-undo.
DEFINE INPUT PARAMETER p-mode as character no-undo.
define output parameter p-ok as logical no-undo.
define variable full_name as character no-undo.
FIND FIRST ub.sys-ctrl No-LOCK.
FIND FIRST ub.db no-LOCK where
            ub.db.db-num = ub.sys-ctrl.db-num.
if not avail ub.db then do:
    message "Отсутствует информация в таблице db"
    view-as alert-box ERROR.
    return error.
end.
full_name = dir-name + "\":U + corr-file-name(ub.db.db-key) + "." + p-file-extension.
if p-mode = "import":U then do:
    if search(full_name) = ? then do:
    message "Не найден файл данных" full_name  skip
                        "для импорта"
        view-as alert-box ERROR.
        p-ok = no.
        return.
    end.
    p-ok = yes.
    return.
end.
if p-mode = "export":U then do:
    if search(full_name) <> ? then do:
    message "Уже имеется в выбранной директории файл с именем" full_name  skip
            "совпадающим с именем одного из файлов экспорта" skip
            "Перезаписывать?"
    view-as alert-box QUESTION buttons YES-NO update p-ok.
    return.
  end.
  p-ok = yes.
  return.
end.





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
  DISPLAY T-rht T-gen T-flt T-pbc T-glb T-scl T-usr dir-name F-rht F-gen F-flt
          F-pbc F-scl F-usr
      WITH FRAME Dialog-Frame.
  ENABLE RECT-groups B-exit B-export B-import B-Help B-dir T-rht T-gen T-flt
         T-pbc T-glb T-scl T-usr dir-name F-rht F-gen F-flt F-pbc F-scl F-usr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-ie Dialog-Frame
PROCEDURE proc-b-ie :
/*------------------------------------------------------------------------------
  Purpose:     проверка наличия файлов в выбранной директории и запуск процедур имп-эксп
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-mode as character no-undo.
 /*надо проверить наличие файлов в данной директории*/
 define variable ii as integer no-undo.
 define variable loc#log as logical no-undo.
 define variable file-extensions as char format "X(3)" no-undo init {&ie-data-groups}.
 define variable t-vals as logical no-undo extent 11.
 define variable v-proc-name as character no-undo .
 define variable v-proc-title as character no-undo .
 define variable v-param as character no-undo .
 define variable v-choice as integer no-undo .
 assign
 dir-name
 T-gen frame {&frame-name}
 T-flt
 T-rht
 T-pbc
 T-scl
 T-usr
 T-seq = no
 t-glb
 .
 assign
 t-vals[{&ie-gen}] = t-gen
 t-vals[{&ie-flt}] = t-flt
 t-vals[{&ie-rht}] = t-rht
 t-vals[{&ie-pbc}] = t-pbc
 t-vals[{&ie-scl}] = t-scl
 t-vals[{&ie-usr}] = t-usr
 t-vals[{&ie-seq}] = t-seq
 .

 if dir-name = "" then do:
    message "Не задана директория для файлов экспорта/импорат"
    view-as alert-box ERROR.
    return error.
 end.
 DO ii = 1 to num-entries(file-extensions):
    if t-vals[ii] then do:
        run check-iefile in this-procedure (
                                           input dir-name
                                           ,input entry(ii, file-extensions)
                                           ,input p-mode
                                           ,output loc#log).
        if not loc#log then  return no-apply.
    end.
  end.
  assign
  v-param = string(T-vals[{&ie-rht}])  + {&delim-par} +
            string(T-vals[{&ie-gen}])  + {&delim-par} +
            string(T-vals[{&ie-flt}])  + {&delim-par} +
            string(T-vals[{&ie-pbc}])  + {&delim-par} +
            string(T-vals[{&ie-scl}])  + {&delim-par} +
            string(T-vals[{&ie-usr}])  + {&delim-par} +
            string(T-vals[{&ie-seq}])  + {&delim-par} +
            corr-file-name(ub.db.db-key) + {&delim-par} +
            dir-name + {&delim-par} +
            string(T-glb)
            .
  if p-mode = "export":U then do:
    assign
    v-proc-name = "utl/imp-expe.p"
    v-proc-title = "Экспорт локальных таблиц БД"
    .
  end.
  else do:
    run gbl/d-askw.w ( input "Версия файлов импорта"
                ,input "Для корректного импорта данных необходимо знать, в какой версии IBS TH они были экспортированы"
                ,input "|"
                ,input ("12.3|" +
                       "14.1|" +
                       "15.0|" +
                       "Отказ")
                ,input "|||"
                ,input 3
                ,input 4
                ,output v-choice).
    if v-choice = 4 then do:
      undo, return error .
    end.
    assign
    v-param = v-param + {&delim-par} + (if v-choice = 1
                                        then "12.3"
                                        else (if v-choice = 2
                                              then "14.1"
                                              else "15.0"
                                             )
                                       )
    v-proc-name = "utl/imp-expi.p"
    v-proc-title = "Импорт локальных таблиц БД"
    .
  end.
  run str/diallog.w (
          input parparentproc
        , input this-procedure
        , input v-proc-name
        , input v-param
        , input no /*p-auto-go*/
        , input "":U
        , input v-proc-title
    ) no-error.
  if error-status:error then do:
    message
    error-status:get-message(1) skip
    return-value
    view-as alert-box error.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME