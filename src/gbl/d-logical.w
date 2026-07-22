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

Универсальный диалог для ввода данных LOGICAL

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/04/07
Author: Bakhtadze Natalya
Creation date: 02/04/07

Можно ввести одно поле типа LOGICAL.
Диалог настраивается через строку, в которой перечислены

Ниже указан пример вывода в полным списком параметром.
Лишние параметры необходимо удалить.

Есть специальная программа fldfrmt.p для получения формата поля базы данных.
Не следует жестко прописывать формат поля, так как при изменении формата
базы данных придется править его во всех местах вызова .

В случае, если необходимо показать в диалоге показать информацию, котора
может содержать специальные символы, например знак равенства и
символ обратной косой строки, то необходимо вызывать функцию экранировани
специальных символов из файла strcodec.i .
Это правило касается только первого параметра.
Во втором параметре ничего не надо перекодировать.

Например, если в диалоге, необходимо показать номер документа:
  'text1=':u + str-encode("Документ " + ub.trn-doc.doc-code, '', '=\':u) + '\':u

  define variable v-field-format as character no-undo .

  run gbl/fldfrmt.p
    (input  'trn-doc':u
    ,input  'cst-code':u
    ,output v-field-format
    ) .

  define variable passwd as character no-undo.

  run gbl/d-prompt.w (
      'title=':u + "Password Prompter" + '\':u
    + 'text1=':u + "Enter Superuser" + '\':u
    + 'text2=':u + "Password" + '\':u
    + 'format=' + v-field-format + '\':u
    + 'password=yes\':u
    + 'boxprog=getfile.p\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=2\':u
    + 'fillin_height=4\':u
    + 'max-chars=70\':u     - максимальное количество символов для редактора
    + 'readonly=yes\':u     - если истина - то данные только выводятся для просмотра
    + 'create_text1=3;1;':u + "New Label:" + '\':u
    ,input-output passwd
    ).
  if return-value = 'false':u
  then do:
    return .
  end.

  display passwd.

    */

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input        parameter h-callback    as handle    no-undo .
DEFINE INPUT        PARAMETER pParameters  AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER pValue       AS logical   NO-UNDO.
define output       parameter p-ok         as logical   no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Универсальный диалог для ввода данных".
{ cmp/vssrevis.i }
{ gbl/color.i    }
{ cmp/str-glbl.i }
{ cmp/strcodec.i }
{ cmp/showinf.i  }

define variable sFormat          AS CHARACTER     NO-UNDO .
define variable sBoxProg         AS CHARACTER     NO-UNDO .
define variable lBlank           AS LOGICAL       NO-UNDO .
define variable v-password       as logical   no-undo .
define variable hFillIn          AS WIDGET-HANDLE NO-UNDO .
define variable sFillIn_Row      AS CHARACTER     NO-UNDO INIT ? .
define variable sFillIn_Col      AS CHARACTER     NO-UNDO INIT ? .
define variable sFillIn_Width    AS CHARACTER     NO-UNDO INIT ? .
define variable sFillIn_Height   AS CHARACTER     NO-UNDO INIT ? .
define variable sEditor_MaxChars AS CHARACTER     NO-UNDO INIT ? .
define variable sCreate_Text1    AS CHARACTER     NO-UNDO INIT ? .
define variable v-read-only      AS LOGICAL       NO-UNDO INIT False .

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel b-help

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn-Choose
     LABEL "V"
     SIZE 2.5 BY 1.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE FILL-IN-Text-1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 41.3 BY .57
     FONT 4 NO-UNDO.

DEFINE VARIABLE FILL-IN-Text-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 41.3 BY .57
     FONT 4 NO-UNDO.

DEFINE VARIABLE TOGGLE-1 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4.6 BY .97 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 43
     Btn-Choose AT ROW 2.97 COL 43.5
     TOGGLE-1 AT ROW 4.57 COL 40.9
     FILL-IN-Text-1 AT ROW 2.13 COL 2.5 NO-LABEL
     FILL-IN-Text-2 AT ROW 3 COL 2.5 NO-LABEL
     SPACE(2.57) SKIP(2.50)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ввод логического значения"
         CANCEL-BUTTON Btn_Cancel.


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

/* SETTINGS FOR BUTTON Btn-Choose IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       Btn-Choose:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-Text-1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       FILL-IN-Text-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-Text-2 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       FILL-IN-Text-2:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX TOGGLE-1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       TOGGLE-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Ввод логического значения */
DO:
  IF NOT v-read-only
  THEN DO:
    ASSIGN
    TOGGLE-1
    .
    if  h-callback <> ?
    and valid-handle(h-callback)
    then do:
      if h-callback :get-signature("cb-d-logical-validate") <> ""
      then do:
        define variable v-ok as logical no-undo .
        define variable v-message as character no-undo .
        run cb-d-logical-validate in h-callback
          (input  toggle-1
          ,output v-ok
          ,output v-message
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры проверки допустимости logical" skip
            "Вызывающая программа" h-callback :file-name skip
            "Внутренняя процедура" "cb-d-logical-validate" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return no-apply .
        end.
        if v-ok <> true
        then do:
          message
            v-message
            view-as alert-box information .
          return no-apply . /* --->>>--- */
        end.
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip
          "Программе был передан указатель на процедуру для проверки logical" skip
          "В вызывающей программе отсутствует внутренняя процедура" "cb-d-logical-validate" skip
          "Вызывающая программа" h-callback :file-name skip
          view-as alert-box error .
        return no-apply .
      end.
    end.
    assign
    pvalue = toggle-1.
  END.
  ASSIGN
  p-ok = True
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Ввод логического значения */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn-Choose
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn-Choose Dialog-Frame
ON CHOOSE OF Btn-Choose IN FRAME Dialog-Frame /* V */
DO:
  define variable var_id   as char no-undo.
  define variable var_name as char no-undo.

  { gbl/working.i }
  do with frame {&frame-name}
  :
    assign
      var_id = hfillin :screen-value
    .
    run value(sboxprog) (input-output var_id, input-output var_name).
    if var_id <> hfillin :screen-value
    then do:
      assign
        hfillin :screen-value = var_id
      .
    end.
  end.
  { gbl/stopwork.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

define variable ind AS INTEGER NO-UNDO.
define variable sElement AS CHARACTER NO-UNDO.
define variable sValue AS CHARACTER NO-UNDO.

DO ind = 1 TO NUM-ENTRIES(pParameters, '\'):
  sElement = ENTRY(ind, pParameters, '\').
  IF NUM-ENTRIES(sElement, '=') = 2
  THEN DO:
    sValue   = ENTRY(2, sElement, '=').
    CASE ENTRY(1, sElement, '='):
      WHEN 'text1'         THEN do: assign FILL-IN-Text-1   = str-decode(sValue, "").             end.
      WHEN 'text2'         THEN do: assign FILL-IN-Text-2   = str-decode(sValue, "").             end.
      WHEN 'format'        THEN do: assign sFormat          = sValue.                             end.
      WHEN 'blank'         THEN do: assign lBlank           = lookup(sValue, 'true,yes':U) > 0.   end.
      WHEN 'password'      THEN do: assign v-password       = lookup(sValue, 'true,yes':U) > 0.   end.
      WHEN 'title'         THEN do: assign FRAME {&FRAME-NAME}:TITLE = sValue.                    end.
      WHEN 'boxprog'       THEN do: assign sBoxProg         = sValue.                             end.
      WHEN 'FillIn_Row'    THEN do: assign sFillIn_Row      = sValue.                             end.
      WHEN 'FillIn_Col'    THEN do: assign sFillIn_Col      = sValue.                             end.
      WHEN 'FillIn_Height' THEN do: assign sFillIn_Height   = sValue.                             end.
      WHEN 'FillIn_Width'  THEN do: assign sFillIn_Width    = sValue.                             end.
      WHEN 'max-chars'     THEN do: assign sEditor_MaxChars = sValue.                             end.
      WHEN 'Create_Text1'  THEN do: assign sCreate_Text1    = sValue.                             end.
      WHEN 'readonly'      THEN do: assign v-read-only      = lookup(sValue, 'yes,true':U) > 0 .  end.
    END CASE.
  END.
END.

define variable hFrameHandle AS WIDGET-HANDLE NO-UNDO.
hFrameHandle = FRAME {&FRAME-NAME}:HANDLE.

define variable hText AS WIDGET-HANDLE NO-UNDO.

DO WITH FRAME {&FRAME-NAME}
:
  IF FILL-IN-Text-1 <> ''
  THEN DO:
    DISPLAY FILL-IN-Text-1.
  END.

  IF FILL-IN-Text-2 <> ''
  THEN DO:
    DISPLAY FILL-IN-Text-2.
  END.
END.

define variable sText1Label AS CHARACTER NO-UNDO.

IF sCreate_Text1 <> ?
AND NUM-ENTRIES(sCreate_Text1, ';') = 3
THEN DO:
  sText1Label = ENTRY(3, sCreate_Text1, ';').
  CREATE TEXT hText
  ASSIGN
    ROW          = INTEGER(ENTRY(1, sCreate_Text1, ';'))
    COLUMN       = INTEGER(ENTRY(2, sCreate_Text1, ';'))
    FORMAT       = 'X(' + STRING(LENGTH(sText1Label)) + ')'
    SCREEN-VALUE = sText1Label
    FRAME        = hFrameHandle
    SENSITIVE    = FALSE
    VISIBLE      = TRUE
  .
END.

IF num-entries(sFormat, {&slash-char}) <> 2
then DO:
  if Sformat <> '':u then do:
    MESSAGE
      vss-workfile vss-revision vss-description skip
      'Указан неправильный формат данный' SKIP
      'sFormat' sFormat 'для логического типа данных' SKIP
      'Формат данных принимается за yes/no' SKIP
      'Позвоните разработчикам системы' skip
      VIEW-AS ALERT-BOX WARNING.
  end.
  assign
    sFormat = 'yes/no'
  .

END.

RUN setup-toggle.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  run setup-box-button .

  run setup-cancel-button .

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
  ENABLE Btn_OK Btn_Cancel b-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setup-box-button Dialog-Frame
PROCEDURE setup-box-button :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  DO WITH FRAME {&FRAME-NAME}
  :
    IF sBoxProg <> ''
    THEN DO:
      ASSIGN
        Btn-Choose:VISIBLE      = True AND NOT v-read-only
        Btn-Choose:SENSITIVE    = True AND NOT v-read-only
      .
    END.

    if v-read-only
    then do:
      assign
        Btn_OK :LABEL = "&Выход"
      .
    end.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setup-cancel-button Dialog-Frame
PROCEDURE setup-cancel-button :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do with frame {&frame-name}
  :
    if v-read-only = false
    then do:
      assign
        Btn_Cancel :visible   = true
        Btn_Cancel :sensitive = true
      .
    end.
    else do:
      assign
        Btn_Cancel :sensitive = false
        Btn_Cancel :visible   = false
      .
    end.
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setup-toggle Dialog-Frame
PROCEDURE setup-toggle :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  /* Customise dialog with EDITOR */
  do with frame {&frame-name}
  :
  ASSIGN
    TOGGLE-1:VISIBLE      = True
    TOGGLE-1:SENSITIVE    = True AND NOT v-read-only
    TOGGLE-1:ROW          = 3
    TOGGLE-1:COL          = 2
    hFillIn = TOGGLE-1:HANDLE
  .
  IF FILL-IN-Text-2 = ''
  AND sFillIn_Row = ?
  THEN DO:
    sFillIn_Row = '2'.
    IF FILL-IN-Text-1 = ''
    THEN DO:
      sFillIn_Row = '1.1'.
    END.
  END.
  IF CAN-SET(hFillIn, 'SCREEN-VALUE')
  THEN DO:
      ASSIGN
        hfillin:screen-value = string(pValue, "yes/no")
      .
  END.

  IF sFillIn_Height = ? THEN
    sFillIn_Height = '10'.
  IF sFillIn_Width = ? THEN
    sFillIn_Width = '50'.
  TOGGLE-1:format = sFormat.
 end. /* do with frame */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
