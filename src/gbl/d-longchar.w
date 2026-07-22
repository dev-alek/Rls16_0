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

Универсальный диалог для ввода данных longchar

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/04/07
Author: Bakhtadze Natalya
Creation date: 02/04/07

Можно ввести одно поле типа character
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
    + 'editor_row=2\':u
    + 'editor_col=4\':u
    + 'editor_width=2\':u
    + 'editor_height=4\':u
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
DEFINE INPUT-OUTPUT PARAMETER pValue       AS longCHAR NO-UNDO.
DEFINE OUTPUT       PARAMETER p-ok         AS logical   NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Универсальный диалог для ввода данных longchar".
{ cmp/vssrevis.i }
{ gbl/color.i    }
{ cmp/str-glbl.i }
{ cmp/strcodec.i }
{ cmp/showinf.i  }

define variable lUserPressOK     AS LOGICAL       NO-UNDO INIT False .
define variable sFormat          AS CHARACTER     NO-UNDO .
define variable sBoxProg         AS CHARACTER     NO-UNDO .
define variable heditor          AS WIDGET-HANDLE NO-UNDO .
define variable seditor_Row      AS CHARACTER     NO-UNDO INIT ? .
define variable seditor_Col      AS CHARACTER     NO-UNDO INIT ? .
define variable seditor_Width    AS CHARACTER     NO-UNDO INIT ? .
define variable seditor_Height   AS CHARACTER     NO-UNDO INIT ? .
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
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel b-file b-help EDITOR-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-file
     LABEL "В файл"
     SIZE 10 BY 1.

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

DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL LARGE
     SIZE 96 BY 16.2
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-Text-1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 41.3 BY .57
     FONT 4 NO-UNDO.

DEFINE VARIABLE FILL-IN-Text-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 41.3 BY .57
     FONT 4 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-file AT ROW 1 COL 51 WIDGET-ID 6
     b-help AT ROW 1 COL 95
     Btn-Choose AT ROW 2.87 COL 81.5
     EDITOR-1 AT ROW 4 COL 1 NO-LABEL WIDGET-ID 4
     FILL-IN-Text-1 AT ROW 2.87 COL 2.5 NO-LABEL
     FILL-IN-Text-2 AT ROW 3.77 COL 2.5 NO-LABEL
     SPACE(55.59) SKIP(19.05)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ввод строкового значения"
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

/* SETTINGS FOR EDITOR EDITOR-1 IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
ASSIGN
       EDITOR-1:AUTO-RESIZE IN FRAME Dialog-Frame      = TRUE
       EDITOR-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-Text-1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       FILL-IN-Text-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-Text-2 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       FILL-IN-Text-2:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Ввод строкового значения */
DO:
  IF NOT v-read-only
  THEN DO:
    IF VALID-HANDLE(heditor)
    THEN DO:
      if  h-callback <> ?
      and valid-handle(h-callback)
      then do:
        if h-callback :get-signature("cb-d-longcharr-validate") <> ""
        then do:
          define variable v-ok as logical no-undo .
          define variable v-message as character no-undo .
          run cb-d-longchar-validate in h-callback
            (input  editor-1
            ,output v-ok
            ,output v-message
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры проверки допустимости longcharacter" skip
              "Вызывающая программа" h-callback :file-name skip
              "Внутренняя процедура" "cb-d-longchar-validate" skip
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
            "Программе был передан указатель на процедуру для проверки character" skip
            "В вызывающей программе отсутствует внутренняя процедура" "cb-d-longchar-validate" skip
            "Вызывающая программа" h-callback :file-name skip
            view-as alert-box error .
          return no-apply .
        end.
      end.
      ASSIGN
        pValue = heditor:SCREEN-VALUE
      .
    END.
  END.
  ASSIGN
  p-ok = True
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Ввод строкового значения */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-file Dialog-Frame
ON CHOOSE OF b-file IN FRAME Dialog-Frame /* В файл */
DO:
  run proc-save-file no-error.
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
      var_id = heditor :screen-value
    .
    run value(sboxprog) (input-output var_id, input-output var_name).
    if var_id <> heditor :screen-value
    then do:
      assign
        heditor :screen-value = var_id
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
      WHEN 'title'         THEN do: assign FRAME {&FRAME-NAME}:TITLE = sValue.                    end.
      WHEN 'boxprog'       THEN do: assign sBoxProg         = sValue.                             end.
      WHEN 'editor_Row'    THEN do: assign seditor_Row      = sValue.                             end.
      WHEN 'editor_Col'    THEN do: assign seditor_Col      = sValue.                             end.
      WHEN 'editor_Height' THEN do: assign seditor_Height   = sValue.                             end.
      WHEN 'editor_Width'  THEN do: assign seditor_Width    = sValue.                             end.
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


RUN setup-editor .


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  run setup-box-button .

  run setup-cancel-button .
  if not v-read-only then do:
    hide
    b-file in frame {&frame-name} .
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
  ENABLE Btn_OK Btn_Cancel b-file b-help EDITOR-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-file Dialog-Frame
PROCEDURE proc-save-file :
define variable v-file-name as character no-undo .
define variable glog as logical   no-undo .
assign
v-file-name = "report.txt"
.
system-dialog get-file v-file-name
ask-overwrite
save-as
create-test-file
use-filename
initial-dir '.'
update glog
default-extension "txt" .
if glog = true
then do:
  define variable v-err-status as integer   no-undo .

  copy-lob object pvalue
  to file v-file-name no-error .

  if error-status :error
  then do:
    message
    substitute("Не удалось вывести ТЕКСТ в файл &1&2"  +
                "&3"
              ,v-file-name
              ,{&new-line}
              ,error-status:get-message(1))
      view-as alert-box error .
  end.
  else do:
    message
    substitute("ТЕКСТ выведен в файл &1", v-file-name)
    view-as alert-box information .
  end.
end.

apply 'ENTRY':u to btn_cancel in frame {&frame-name}  .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setup-editor Dialog-Frame
PROCEDURE setup-editor :
/* Customise dialog with EDITOR */
  do with frame {&frame-name}
  :
        ASSIGN
        EDITOR-1:VISIBLE      = True
        editor-1:sensitive    = true
        editor-1:read-only    = v-read-only
        heditor = editor-1:HANDLE
        editor-1:screen-value = pvalue
        .
      IF FILL-IN-Text-2 = ''
      AND seditor_Row = ?
      THEN DO:
        seditor_Row = '2'.
        IF FILL-IN-Text-1 = ''
        THEN DO:
          seditor_Row = '2'.
        END.
      END.
      IF seditor_Height = ? THEN
        seditor_Height = '10'.
      IF seditor_Width = ? THEN
        seditor_Width = '98'.

      IF seditor_col = ?
      or seditor_col = ''
      THEN
        seditor_col = '1'.
      IF seditor_row = ?
      or seditor_row = ''
      THEN
        seditor_row = '2'.


      assign
      EDITOR-1:row    =  decimal(seditor_row)
      EDITOR-1:column =  decimal(seditor_col)
      EDITOR-1:Width  =  decimal(seditor_Width)
      EDITOR-1:height =  decimal(seditor_height)
      .

      IF  sEditor_MaxChars <> ?
      AND sEditor_MaxChars <> ''
      AND CAN-SET(EDITOR-1:HANDLE, 'MAX-CHARS')
      THEN DO:
        ASSIGN
          EDITOR-1:MAX-CHARS = INTEGER(sEditor_MaxChars)
        .
      END.

  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
