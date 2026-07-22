&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------


$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Настройка параметров производства

Автор: Белоусов Илья Александрович
Дата создания: 11/01/08
Author: Ilia Belousov
Creation date: 11/01/08

Input:

Output:


------------------------------------------------------------------------*/
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
define variable vss-description as character no-undo init "Настройка параметров производства".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/color.i    }

DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.

{ gbl/clntattr.i }
{ gbl/thbjattr.i }

define temp-table temp-thbj-attr no-undo like ub.thbj-attr.

define variable v-tth           as handle   no-undo .
define variable v-to-create    as logical      no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help tb-fbr-frcp tb-fbr-ioff ~
tb-fbr-qntc tb-fbrrcpgb v-fbrhstlv v-fbr-mrgn-min v-fbr-mrgn-max
&Scoped-Define DISPLAYED-OBJECTS tb-fbr-frcp tb-fbr-ioff tb-fbr-qntc ~
tb-fbrrcpgb v-fbrhstlv v-fbr-mrgn-min v-fbr-mrgn-max

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

DEFINE VARIABLE v-fbr-mrgn-max AS DECIMAL FORMAT ">9.9":U INITIAL 0
     LABEL "и макс."
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-fbr-mrgn-min AS DECIMAL FORMAT ">9.9":U INITIAL 0
     LABEL "Мин"
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-fbrhstlv AS INTEGER FORMAT "9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2 BY 1 TOOLTIP "0 - запись в историю не производится. 9 - максимальная детализация" NO-UNDO.

DEFINE VARIABLE tb-fbr-frcp AS LOGICAL INITIAL no
     LABEL "Первый подходящий рецепт при рекурсивном производстве"
     VIEW-AS TOGGLE-BOX
     SIZE 56 BY .83 TOOLTIP "при нескольких рецептах брать первый подходящий, иначе только однозначный выбор" NO-UNDO.

DEFINE VARIABLE tb-fbr-ioff AS LOGICAL INITIAL no
     LABEL "Ручное заполнение альтернативного производства"
     VIEW-AS TOGGLE-BOX
     SIZE 55.5 BY .83 TOOLTIP "Отключение распределения количеств ингредиентов для альтернативных рецептов" NO-UNDO.

DEFINE VARIABLE tb-fbr-qntc AS LOGICAL INITIAL no
     LABEL "При раскрутке рецептов прибавлять требуемое количество к уже произведенному"
     VIEW-AS TOGGLE-BOX
     SIZE 78 BY .83 TOOLTIP "При рекурсивном производстве если требуемый товар уже есть в рецепте" NO-UNDO.

DEFINE VARIABLE tb-fbrrcpgb AS LOGICAL INITIAL no
     LABEL "Возможность изменения локальных рецептов на глобальные"
     VIEW-AS TOGGLE-BOX
     SIZE 59 BY .83 TOOLTIP "При включенном параметре, локальный рецепт можно сделать глобальным." NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 55
     tb-fbr-frcp AT ROW 3 COL 6 WIDGET-ID 2
     tb-fbr-ioff AT ROW 4 COL 6 WIDGET-ID 4
     tb-fbr-qntc AT ROW 5 COL 6 WIDGET-ID 6
     tb-fbrrcpgb AT ROW 6 COL 6 WIDGET-ID 8
     v-fbrhstlv AT ROW 7.5 COL 4 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     v-fbr-mrgn-min AT ROW 9 COL 9 COLON-ALIGNED WIDGET-ID 14
     v-fbr-mrgn-max AT ROW 9 COL 25 COLON-ALIGNED WIDGET-ID 16
     "%" VIEW-AS TEXT
          SIZE 1.5 BY .67 AT ROW 9.21 COL 16 WIDGET-ID 18
     "Детализация записи в историю" VIEW-AS TEXT
          SIZE 74 BY .67 TOOLTIP "0 - запись в историю не производится. 9 - максимальная детализация" AT ROW 7.71 COL 9 WIDGET-ID 12
     "% наценки производства" VIEW-AS TEXT
          SIZE 23.5 BY .67 TOOLTIP "Вычисляется для каждого производимого товара по каждому рецепту" AT ROW 9.21 COL 32.5 WIDGET-ID 20
     SPACE(32.62) SKIP(2.40)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры производства"
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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры производства */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
   if p-mode = {&update} then do:
      run save-attr in this-procedure .
   END.
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


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/app_help.i }

   CASE p-obj-type:
      WHEN ""
      THEN DO:
         ASSIGN
            FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + " глобально"
         .
      END.
      WHEN {&cmp}
      THEN DO:
         ASSIGN
            FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + SUBSTITUTE(" по фирме &1", p-obj-code)
         .
      END.
      WHEN {&shop} OR
      WHEN {&stock}
      THEN DO:
         ASSIGN
            FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + SUBSTITUTE(" по объекту &1 &2", p-obj-type, p-obj-code)
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.

  if  p-mode <> {&lookup} and
      p-mode <> {&update}
  then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-mode" p-mode
      view-as alert-box error.
      undo, return error.
  end.

  RUN load-attr IN THIS-PROCEDURE .

  RUN enable_UI.
  RUN post_enable_UI IN THIS-PROCEDURE.
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
  DISPLAY tb-fbr-frcp tb-fbr-ioff tb-fbr-qntc tb-fbrrcpgb v-fbrhstlv
          v-fbr-mrgn-min v-fbr-mrgn-max
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help tb-fbr-frcp tb-fbr-ioff tb-fbr-qntc tb-fbrrcpgb
         v-fbrhstlv v-fbr-mrgn-min v-fbr-mrgn-max
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load-attr Dialog-Frame
PROCEDURE load-attr :
define variable v-value-character as character      no-undo .
define variable v-value-date      as date           no-undo .
define variable v-value-decimal   as decimal        no-undo .
define variable v-value-integer   as integer        no-undo .
define variable v-value-logical   as logical        no-undo .
define variable v-param-type      as character      no-undo .
define variable v-entry           as character  no-undo .
do
on error undo, return error
:
   if p-mode = {&update} then
   do
   transaction
   :
      find first locked_thbj-attr
            where locked_thbj-attr.upper-prop-code = {&attr-fbrattr}
            exclusive-lock
            no-wait
            no-error
            .
      if locked locked_thbj-attr then do:
         message
            vss-workfile vss-revision vss-description skip
               "Запись !!!"
            view-as alert-box error .
         undo, return error.
      end.

   end.
   else do:
      find first locked_thbj-attr
            where locked_thbj-attr.upper-prop-code = {&attr-fbrattr}
            no-lock
            no-error
            .
   end.
   if not available locked_thbj-attr then do:
      assign
         v-to-create  = yes
      .
      message
         substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                     {&new-line}
                     )
      view-as alert-box WARNING.
   end.

   assign
      v-tth = buffer thbjattr_thbj-attr:table-handle
   .
   empty temp-table thbjattr_thbj-attr.
   empty temp-table temp-thbj-attr.

   /*
   p-obj-type = {&db} .
   */

  run adm/shattri.p (
                input "init":U
              , input p-obj-type
              , input p-obj-code
              , input {&attr-fbrattr}
              , input "":U
              , output v-value-character
              , output v-value-date
              , output v-value-decimal
              , output v-value-integer
              , output v-value-logical
              , output v-param-type
              , INPUT-OUTPUT table-handle v-tth
              ) no-error .
  if error-status:error
  and not available locked_thbj-attr then do:
    message
    "Не удалось получить начальные значения настроек" skip
    error-status:get-message(1) return-value
    view-as alert-box error .
    undo, return error .
  end.

  for each thbjattr_thbj-attr:
    assign
      v-entry = thbjattr_thbj-attr.prop-code
    .
    case v-entry:
      when {&attr-fbrattr_fbr-frcp} then do:
        assign
          tb-fbr-frcp = thbjattr_thbj-attr.property-value-logical
          tb-fbr-frcp :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-fbrattr_fbr-ioff} then do:
        assign
          tb-fbr-ioff = thbjattr_thbj-attr.property-value-logical
          tb-fbr-ioff :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-fbrattr_fbr-qntc} then do:
        assign
          tb-fbr-qntc = thbjattr_thbj-attr.property-value-logical
          tb-fbr-qntc :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-fbrattr_fbrrcpgb} then do:
        assign
          tb-fbrrcpgb = thbjattr_thbj-attr.property-value-logical
          tb-fbrrcpgb :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-fbrattr_fbrhstlv} then do:
        assign
          v-fbrhstlv = thbjattr_thbj-attr.property-value-integer
          v-fbrhstlv :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-fbrattr_fbr-mrgn-min} then do:
        assign
          v-fbr-mrgn-min = thbjattr_thbj-attr.property-value-decimal
          v-fbr-mrgn-min :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-fbrattr_fbr-mrgn-max} then do:
        assign
          v-fbr-mrgn-max = thbjattr_thbj-attr.property-value-decimal
          v-fbr-mrgn-max :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
    end case.

    create temp-thbj-attr.
    buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
  end.
end. /* do on error */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post_enable_UI Dialog-Frame
PROCEDURE post_enable_UI :
do
on error undo, return error
:
   if  p-mode = {&lookup}
   then do:
    assign
      v-fbr-mrgn-min :fgcolor in frame {&frame-name} = BROWN_COLOR
      v-fbr-mrgn-max :fgcolor in frame {&frame-name} = BROWN_COLOR
      v-fbrhstlv     :fgcolor in frame {&frame-name} = BROWN_COLOR
      b-exit :hidden  = yes
      b-quit :label   = "&Выход":U
    .
    disable
      tb-fbr-frcp
      tb-fbr-ioff
      tb-fbr-qntc
      tb-fbrrcpgb
      v-fbrhstlv
      v-fbr-mrgn-min
      v-fbr-mrgn-max
    with frame {&frame-name}.
    view frame {&frame-name}.
   END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-attr Dialog-Frame
PROCEDURE save-attr :
define variable v-value-character as character      no-undo .
define variable v-value-date      as date           no-undo .
define variable v-value-decimal   as decimal        no-undo .
define variable v-value-integer   as integer        no-undo .
define variable v-value-logical   as logical        no-undo .
define variable v-param-type      as character      no-undo .
define variable wh                as widget-handle  no-undo .
define variable fh                as widget-handle  no-undo .
define variable v-same            as logical        no-undo .
do
on error undo, return error
:
   assign
   frame {&frame-name}
        tb-fbr-frcp
        tb-fbr-ioff
        tb-fbr-qntc
        tb-fbrrcpgb
        v-fbrhstlv
        v-fbr-mrgn-min
        v-fbr-mrgn-max
      fh = frame {&frame-name}:first-child
      wh = fh:first-child
   .

   do while valid-handle(wh):
      if wh:private-data begins "recid="
      then do:
         find first thbjattr_thbj-attr
         where recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '='))
         .
         assign
         buffer
         thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value
         .
      end.
      wh = wh:next-sibling.
   end.

   assign
      v-same = yes
   .

   for each thbjattr_thbj-attr,
         first temp-thbj-attr
         where temp-thbj-attr.obj-type          = thbjattr_thbj-attr.obj-type
            and temp-thbj-attr.obj-code         = thbjattr_thbj-attr.obj-code
            and temp-thbj-attr.upper-prop-code  = thbjattr_thbj-attr.upper-prop-code
            and temp-thbj-attr.prop-code        = thbjattr_thbj-attr.prop-code
   :
      buffer-compare thbjattr_thbj-attr to temp-thbj-attr save result in v-same.
      if not v-same then leave.
   end.

   if v-same  and not v-to-create then return.

   /*проверим корректность*/
   run adm/shattri.p ( input "check":U
                     , input p-obj-type
                     , input p-obj-code
                     , input {&attr-fbrattr}
                     , INPUT '':U
                     , output v-value-character
                     , output v-value-date
                     , output v-value-decimal
                     , output v-value-integer
                     , output v-value-logical
                     , output v-param-type
                     , input-output table-handle v-tth
                     ) no-error .

   if error-status :error then do:
      message
         "Некорректное значение ПАРАМЕТРОВ"  skip
         error-status:get-message(1)         skip
         return-value
      view-as alert-box error .
      undo, return error .
   end.


   do transaction
   on error undo, return error return-value
   :
      run thbjattr_set-section in this-procedure ( input p-obj-type
                                                , input p-obj-code
                                                , input {&attr-fbrattr}
                                                , input table thbjattr_thbj-attr
                                                ) no-error.
      if error-status:error then do:
         message
         error-status:get-message(1)  skip
         return-value
         view-as alert-box.
         undo, return error.
      end.
   end.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME