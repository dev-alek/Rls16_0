&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Контекстная замена в названиях товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

Author: Андрей Исаков
Created: 07.03.97


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Контекстная замена в названиях товаров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
/*определение таблицы для формирования списка товаров*/
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }

define stream sout .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DIALOG-1

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-start b-help RECT-1 T-lst T-name ~
from-str T-engl-name to-str T-label-name T-chk-name T-instring
&Scoped-Define DISPLAYED-OBJECTS T-lst T-name from-str T-engl-name to-str ~
T-label-name T-chk-name T-instring

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON B-lst
     LABEL "Список"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход "
     SIZE 10 BY 1.

DEFINE BUTTON b-start
     LABEL "&Старт"
     SIZE 10 BY 1.

DEFINE VARIABLE from-str AS CHARACTER FORMAT "X(256)":U
     LABEL "&Искомая строка"
     VIEW-AS FILL-IN
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE to-str AS CHARACTER FORMAT "X(256)":U
     LABEL "&Заменить на"
     VIEW-AS FILL-IN
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 25.88 BY 5.5.

DEFINE VARIABLE T-chk-name AS LOGICAL INITIAL no
     LABEL "Чек"
     VIEW-AS TOGGLE-BOX
     SIZE 22.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE T-engl-name AS LOGICAL INITIAL no
     LABEL "Англ. название"
     VIEW-AS TOGGLE-BOX
     SIZE 22.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE T-instring AS LOGICAL INITIAL no
     LABEL "В середине слова"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-label-name AS LOGICAL INITIAL no
     LABEL "Этикетка"
     VIEW-AS TOGGLE-BOX
     SIZE 22.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE T-lst AS LOGICAL INITIAL no
     LABEL "По списку"
     VIEW-AS TOGGLE-BOX
     SIZE 13.63 BY 1 NO-UNDO.

DEFINE VARIABLE T-name AS LOGICAL INITIAL no
     LABEL "Название"
     VIEW-AS TOGGLE-BOX
     SIZE 22.5 BY 1
     FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     b-quit AT ROW 1 COL 1
     B-lst AT ROW 1 COL 11
     b-start AT ROW 1 COL 21
     b-help AT ROW 1 COL 31
     T-lst AT ROW 2.79 COL 23.5
     T-name AT ROW 3.5 COL 58.5
     from-str AT ROW 4.08 COL 21.5 COLON-ALIGNED
     T-engl-name AT ROW 4.5 COL 58.5
     to-str AT ROW 5.5 COL 21.5 COLON-ALIGNED
     T-label-name AT ROW 5.5 COL 58.5
     T-chk-name AT ROW 6.5 COL 58.5
     T-instring AT ROW 6.75 COL 23.5
     "Поля для поиска и замены" VIEW-AS TEXT
          SIZE 24 BY .67 AT ROW 2.75 COL 58
          BGCOLOR 3 FGCOLOR 15
     RECT-1 AT ROW 2.5 COL 57
     SPACE(4.99) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Контекстная замена в полях названий товаров".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
                                                                        */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON B-lst IN FRAME DIALOG-1
   NO-ENABLE                                                            */
ASSIGN
       B-lst:HIDDEN IN FRAME DIALOG-1           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX DIALOG-1
/* Query rebuild information for DIALOG-BOX DIALOG-1
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX DIALOG-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME B-lst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lst DIALOG-1
ON CHOOSE OF B-lst IN FRAME DIALOG-1 /* Список */
DO:
      run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-start DIALOG-1
ON CHOOSE OF b-start IN FRAME DIALOG-1 /* Старт */
DO:

  define variable v-matches-string as character no-undo .
  define variable v-ind            as integer   no-undo .
  define variable v-change-ind     as integer   no-undo .
  define variable v-replace-string as logical   no-undo .
  define buffer buf_goods for ub.goods.

  find ub.db where ub.db.db-num = v-cntxt-db-num no-lock.

  if not ub.db.add-goods
  then do:
    message
      "Изменение и добавление товаров в данной БД запрещено !"
      view-as alert-box error .
    return no-apply.
  end.

  assign
    from-str
    to-str
    t-instring
    t-name
    t-engl-name
    t-label-name
    t-chk-name
  .
  if from-str = ""
  then do:
    message
      "Искомая строка не задана." skip
      view-as alert-box error .
    apply 'entry':u to from-str .
    return no-apply.
  end.
  if length(from-str) = 1
  then do:
    message
      "Замена одной буквы недопустима." skip
      "Это приведёт к изменению названий всех товаров!"
      view-as alert-box error .
    apply 'entry':u to from-str .
    return no-apply.
  end.

  if  t-name       = false
  and t-engl-name  = false
  and t-label-name = false
  and t-chk-name   = false
  then do:
    message
      "Необходимо выбрать" skip
      "Поля для поля для поиска и замены" skip
      view-as alert-box error .
    return no-apply.
  end.

  if t-lst
  then do:
    for each gds-list No-lock
    :
      find first buf_goods
        where buf_goods.artic     = gds-list.artic
          and buf_goods.prod-type = gds-list.prod-type
          and buf_goods.prod-code = gds-list.prod-code
        .

      if t-instring
      then do:
        assign
          v-matches-string = "*" + from-str + "*"
        .
      end.
      else do:
        assign
          v-matches-string = from-str + "*"
        .
      end.

      assign
        v-replace-string = false
      .

      if  t-name
      and buf_goods.gds-name matches v-matches-string
      then do:
        define variable v-new-gds-name as character no-undo .
        assign
          v-new-gds-name = replace(buf_goods.gds-name, from-str, to-str)
        .
        output stream sout to value('rplc-gds.txt') append .
        put stream sout unformatted
          cur-time-string-sec()
          " gds-code " buf_goods.gds-code
          " artic " buf_goods.artic
          " prod-type " buf_goods.prod-type
          " prod-code " buf_goods.prod-code
          " old-gds-name " buf_goods.gds-name
          " new-gds-name " v-new-gds-name
          {&new-line}
          .
        output stream sout close .
        assign
          v-replace-string  = true
          buf_goods.gds-name    = v-new-gds-name
          gds-list.gds-name = v-new-gds-name
        .
      end.
      if  t-engl-name
      and buf_goods.engl-name matches v-matches-string
      then do:
        define variable v-new-engl-name as character no-undo .
        assign
          v-new-engl-name = replace(buf_goods.engl-name, from-str, to-str)
        .
        output stream sout to value('rplc-gds.txt') append .
        put stream sout unformatted
          cur-time-string-sec()
          " gds-code " buf_goods.gds-code
          " artic " buf_goods.artic
          " prod-type " buf_goods.prod-type
          " prod-code " buf_goods.prod-code
          " old-engl-name " buf_goods.engl-name
          " new-engl-name " v-new-engl-name
          {&new-line}
          .
        output stream sout close .
        assign
          v-replace-string = true
          buf_goods.engl-name  = v-new-engl-name
          gds-list.engl-name = v-new-gds-name
        .
      end.
      if  t-label-name
      and buf_goods.label-name matches v-matches-string
      then do:
        define variable v-new-label-name as character no-undo .
        assign
          v-new-label-name = replace(buf_goods.label-name, from-str, to-str)
        .
        output stream sout to value('rplc-gds.txt') append .
        put stream sout unformatted
          cur-time-string-sec()
          " gds-code " buf_goods.gds-code
          " artic " buf_goods.artic
          " prod-type " buf_goods.prod-type
          " prod-code " buf_goods.prod-code
          " old-label-name " buf_goods.label-name
          " new-label-name " v-new-label-name
          {&new-line}
          .
        output stream sout close .
        assign
          v-replace-string    = true
          buf_goods.label-name    = v-new-label-name
          gds-list.label-name = v-new-gds-name
        .
      end.
      if  t-chk-name
      and buf_goods.chk-name matches v-matches-string
      then do:
        define variable v-new-chk-name as character no-undo .
        assign
          v-new-chk-name = replace(buf_goods.chk-name, from-str, to-str)
        .
        output stream sout to value('rplc-gds.txt') append .
        put stream sout unformatted
          cur-time-string-sec()
          " gds-code " buf_goods.gds-code
          " artic " buf_goods.artic
          " prod-type " buf_goods.prod-type
          " prod-code " buf_goods.prod-code
          " old-chk-name " buf_goods.chk-name
          " new-chk-name " v-new-chk-name
          {&new-line}
          .
        output stream sout close .
        assign
          v-replace-string  = true
          buf_goods.chk-name    = v-new-chk-name
          gds-list.chk-name = v-new-gds-name
        .
      end.

      if v-replace-string = true
      then do:
        assign
          v-change-ind = v-change-ind + 1
        .
      end.

      assign
        v-ind = v-ind + 1
      .

      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обработано &1. Произведено замен &2"
                          ,v-ind
                          ,v-change-ind
                          )
          ).
      end.
    end.
  end.
  else do:
    for each buf_goods
    :
      if t-instring
      then do:
        assign
          v-matches-string = "*" + from-str + "*"
        .
      end.
      else do:
        assign
          v-matches-string = from-str + "*"
        .
      end.

      assign
        v-replace-string = false
      .

      if  t-name
      and buf_goods.gds-name matches v-matches-string
      then do:
        assign
          v-new-gds-name = replace(buf_goods.gds-name, from-str, to-str)
        .
        output stream sout to value('rplc-gds.txt') append .
        put stream sout unformatted
          cur-time-string-sec()
          " gds-code " buf_goods.gds-code
          " artic " buf_goods.artic
          " prod-type " buf_goods.prod-type
          " prod-code " buf_goods.prod-code
          " old-gds-name " buf_goods.gds-name
          " new-gds-name " v-new-gds-name
          {&new-line}
          .
        output stream sout close .
        assign
          v-replace-string = true
          buf_goods.gds-name   = v-new-gds-name
        .
      end.
      if  t-engl-name
      and buf_goods.engl-name matches v-matches-string
      then do:
        assign
          v-new-engl-name = replace(buf_goods.engl-name, from-str, to-str)
        .
        output stream sout to value('rplc-gds.txt') append .
        put stream sout unformatted
          cur-time-string-sec()
          " gds-code " buf_goods.gds-code
          " artic " buf_goods.artic
          " prod-type " buf_goods.prod-type
          " prod-code " buf_goods.prod-code
          " old-engl-name " buf_goods.engl-name
          " new-engl-name " v-new-engl-name
          {&new-line}
          .
        output stream sout close .
        assign
          v-replace-string = true
          buf_goods.engl-name  = v-new-engl-name
        .
      end.
      if  t-label-name
      and buf_goods.label-name matches v-matches-string
      then do:
        assign
          v-new-label-name = replace(buf_goods.label-name, from-str, to-str)
        .
        output stream sout to value('rplc-gds.txt') append .
        put stream sout unformatted
          cur-time-string-sec()
          " gds-code " buf_goods.gds-code
          " artic " buf_goods.artic
          " prod-type " buf_goods.prod-type
          " prod-code " buf_goods.prod-code
          " old-label-name " buf_goods.label-name
          " new-label-name " v-new-label-name
          {&new-line}
          .
        output stream sout close .
        assign
          v-replace-string = true
          buf_goods.label-name = v-new-label-name
        .
      end.
      if  t-chk-name
      and buf_goods.chk-name matches v-matches-string
      then do:
        assign
          v-new-chk-name = replace(buf_goods.chk-name, from-str, to-str)
        .
        output stream sout to value('rplc-gds.txt') append .
        put stream sout unformatted
          cur-time-string-sec()
          " gds-code " buf_goods.gds-code
          " artic " buf_goods.artic
          " prod-type " buf_goods.prod-type
          " prod-code " buf_goods.prod-code
          " old-chk-name " buf_goods.chk-name
          " new-chk-name " v-new-chk-name
          {&new-line}
          .
        output stream sout close .
        assign
          v-replace-string = true
          buf_goods.chk-name   = v-new-chk-name
        .
      end.

      if v-replace-string = true
      then do:
        assign
          v-change-ind = v-change-ind + 1
        .
      end.

      assign
        v-ind = v-ind + 1
      .

      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обработано &1. Произведено замен &2"
                          ,v-ind
                          ,v-change-ind
                          )
          ).
      end.
    end.
  end.

  run waitfram-hide in this-procedure .

  message
    "Контекстная замена закончена" skip
    "Обработано товаров" v-ind skip
    "Товаров с изменёнными названиями" v-change-ind skip
    "Подробная информация о произведённых заменах в файле" "rplc-gds.txt" skip
    view-as alert-box information .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-lst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-lst DIALOG-1
ON VALUE-CHANGED OF T-lst IN FRAME DIALOG-1 /* По списку */
DO:
    assign T-lst.
    IF T-lst then do:
        ENABLE B-lst with frame {&frame-name}.
        DISPLAY B-lst with frame {&frame-name}.
    end.
    else do:
        HIDE B-lst in frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1  _DEFAULT-DISABLE
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
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1  _DEFAULT-ENABLE
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
  DISPLAY T-lst T-name from-str T-engl-name to-str T-label-name T-chk-name
          T-instring
      WITH FRAME DIALOG-1.
  ENABLE b-quit b-start b-help RECT-1 T-lst T-name from-str T-engl-name to-str
         T-label-name T-chk-name T-instring
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME