&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
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

Список сохраненных файлов в партиях алкогольной продукции

Автор: Хныкин Павел Андреевич
Дата создания: 03/01/06
Author: Pavel Khnykin
Creation date: 03/01/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-doc-recid as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список сохраненных файлов в партиях алкогольной продукции".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define variable v-cur-recid as recid no-undo.
define variable v-log       as logical no-undo.

define buffer bf_trn-doc   for ub.trn-doc.
define buffer bf_doc-line  for ub.doc-line.
define buffer bf_parts     for ub.parts.

define temp-table tt_alcdoc no-undo
  field selected  as logical
  field doc-type  as integer
  field doc-name  as character
  field file-name as character
  index ind1 is primary
    doc-type
    file-name
  .

define buffer bf_tt_alcdoc for tt_alcdoc.

define stream out-stream.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-alcdoc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_alcdoc

/* Definitions for BROWSE br-alcdoc                                     */
&Scoped-define FIELDS-IN-QUERY-br-alcdoc tt_alcdoc.selected tt_alcdoc.doc-name tt_alcdoc.file-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-alcdoc
&Scoped-define SELF-NAME br-alcdoc
&Scoped-define QUERY-STRING-br-alcdoc FOR EACH tt_alcdoc
&Scoped-define OPEN-QUERY-br-alcdoc OPEN QUERY {&SELF-NAME} FOR EACH tt_alcdoc.
&Scoped-define TABLES-IN-QUERY-br-alcdoc tt_alcdoc
&Scoped-define FIRST-TABLE-IN-QUERY-br-alcdoc tt_alcdoc


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-mark b-deselect b-print b-help ~
br-alcdoc
&Scoped-Define DISPLAYED-OBJECTS fi-default-printer

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-deselect
     LABEL "&Снять *"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-default-printer AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 82.5 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-alcdoc FOR
      tt_alcdoc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-alcdoc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-alcdoc Dialog-Frame _FREEFORM
  QUERY br-alcdoc DISPLAY
      tt_alcdoc.selected FORMAT "*/":U COLUMN-LABEL "*":U
      tt_alcdoc.doc-name FORMAT "x(30)":U COLUMN-LABEL "Тип документа"
      tt_alcdoc.file-name FORMAT "x(45)":U COLUMN-LABEL "Имя файла"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 83.5 BY 16 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1.5
     b-mark AT ROW 1 COL 11.5
     b-deselect AT ROW 1 COL 14.5
     b-print AT ROW 1 COL 34.5
     b-help AT ROW 1 COL 75
     br-alcdoc AT ROW 2.33 COL 1.5
     fi-default-printer AT ROW 18.6 COL 1.5 NO-LABEL
     SPACE(1.29) SKIP(0.19)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список сохраненных файлов для алкогольной продукции".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB br-alcdoc b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-default-printer IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-alcdoc
/* Query rebuild information for BROWSE br-alcdoc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt_alcdoc.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE br-alcdoc */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список сохраненных файлов для алкогольной продукции */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-deselect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-deselect Dialog-Frame
ON CHOOSE OF b-deselect IN FRAME Dialog-Frame /* Снять * */
DO:
  for each bf_tt_alcdoc :
    bf_tt_alcdoc.selected = no.
  end.
  v-log = br-alcdoc:refresh() .
  apply "entry" to br-alcdoc .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  if not available tt_alcdoc then
    return no-apply.

  assign
    tt_alcdoc.selected = not tt_alcdoc.selected
    .
  v-log = br-alcdoc:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
    v-log = br-alcdoc:select-next-row ().
    apply "value-changed" to br-alcdoc in frame {&frame-name}.
  end.
  apply "entry" to br-alcdoc .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  define variable lOK             as logical no-undo.
  define variable v-print-command as character no-undo.
  define variable v-full-filename as character no-undo.
  define variable v-exefile       as character no-undo.
  define variable v-inifile       as character no-undo.
  define variable v-batfile       as character no-undo.
  define variable v-printername   as character no-undo.
  define variable v-tempfile      as character no-undo.
  define variable v-list-codepage as character no-undo.

  find first bf_tt_alcdoc no-error.
  if not available bf_tt_alcdoc then
    return no-apply.

  find first bf_tt_alcdoc where bf_tt_alcdoc.selected = yes no-error.
  if not available bf_tt_alcdoc then do:
    message "Не выбраны документы для печати"
      view-as alert-box warning.
    apply "entry" to br-alcdoc.
    return no-apply.
  end.

  /* Проверяем, задана ли командная строка внешней программы печати в ini-файле */
  get-key-value section "AlcPrint":U key "ConStrPA":U value v-print-command .
  if v-print-command = ? then do:
    run gbl/getexini.p
      (output v-exefile
      ,output v-inifile
      ) no-error .

    message
      "Не задана командная строка для печати в *.ini файле" skip
      "*.ini файл " v-inifile skip
      "Секция: AlcPrint" skip
      "Ключ:   ConStrPA" skip
      view-as alert-box error.
    return no-apply.
  end.

  assign
    file-info:file-name = v-print-command
    v-batfile           = file-info:full-pathname
  .
  if v-batfile = ? then do:
    run gbl/getexini.p
      (output v-exefile
      ,output v-inifile
      ) no-error .

    message
      "Указанный командный файл для печати не найден" skip
      "*.ini файл " v-inifile skip
      "Секция: AlcPrint" skip
      "Ключ:   ConStrPA" skip
      "Строка:" v-print-command
      view-as alert-box error.
    return no-apply.
  end.

  /* Кодовая страница, в которой будет выводиться список файлов
     (по умолчанию IBM866 для правильной работы оператора for в bat-файле) */
  get-key-value section "AlcPrint":U key "ListCodePage":U value v-list-codepage.
  if v-list-codepage = ? then v-list-codepage = "IBM866":U.

  message "Распечатать выбранные сопроводительные документы ?"
    view-as alert-box question buttons yes-no
    update lOK.
  if not lOK then do:
    apply "entry" to br-alcdoc.
    return no-apply.
  end.

  /* Определяем имя текущего принтера */
  v-printername = string(session:printer-name).

  Print_Block:
  do on error undo, leave Print_Block :

    v-tempfile = "printpar.txt".
    output stream out-stream to value(v-tempfile)
           convert target v-list-codepage.

    /* Выводим во временный файл список файлов для печати */
    File_Loop:
    for each bf_tt_alcdoc where bf_tt_alcdoc.selected = yes
          break by bf_tt_alcdoc.doc-type
                by bf_tt_alcdoc.file-name
      :
      /* Проверяем, существует ли указанный графический файл.
         Заодно конвертируем прямой слэш в обратный */
      assign
        file-info:file-name = bf_tt_alcdoc.file-name
        v-full-filename     = file-info:full-pathname
      .
      if v-full-filename = ? then do:
        if last(bf_tt_alcdoc.file-name) then do:
          message "Файл '" + bf_tt_alcdoc.file-name +
                  "' не найден или недостаточно прав для его просмотра."
            view-as alert-box warning.
          leave File_Loop.
        end.
        else do:
          message "Файл '" + bf_tt_alcdoc.file-name +
                  "' не найден или недостаточно прав для его просмотра."
                  "Печатать остальные файлы ?"
            view-as alert-box warning buttons yes-no
            update lOK.
          if lOK then next File_Loop.
          else do:
            output stream out-stream close.
            leave Print_Block.
          end.
        end.
      end. /* if v-full-filename = ? */

      put stream out-stream unformatted
        v-full-filename skip.

    end. /* File_Loop */

    output stream out-stream close.

    /* Печатаем все выбранные документы через внешнюю программу печати,
       прописанную в ini-файле (она обрабатывает список файлов из v-tempfile) */
    os-command no-wait value (substitute ('start /MIN &1 &2 &3',
                                          v-batfile, v-tempfile, v-printername
                                         )
                             ).
  end. /* Print_Block */

  apply "entry" to br-alcdoc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-alcdoc
&Scoped-define SELF-NAME br-alcdoc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-alcdoc Dialog-Frame
ON RETURN OF br-alcdoc IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-alcdoc IN FRAME Dialog-Frame
DO:
  apply "choose" to b-mark in frame {&frame-name} .
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &browse-name="br-alcdoc" }
{ gbl/brwrepos.i &line-num=5 }

{ gbl/brwrefre.i
  "if available tt_alcdoc then~
     v-cur-recid = recid(tt_alcdoc).~
   run OpenBR in this-procedure.~
   reposition {&browse-name} to recid v-cur-recid no-error.~
   apply 'entry' to {&browse-name} in frame {&frame-name}."
}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  find bf_trn-doc no-lock where recid(bf_trn-doc) = p-doc-recid no-error.
  if not available bf_trn-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найдена запись документа (trn-doc)" skip
      view-as alert-box error .
    return error return-value .
  end.
  fi-default-printer = session :printer-name.

  run OpenBr.
  RUN enable_UI.
  apply "entry" to {&browse-name} in frame {&frame-name}.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-temp-table Dialog-Frame
PROCEDURE create-temp-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  for each tt_alcdoc :
    delete tt_alcdoc.
  end.

  for each bf_doc-line no-lock
        where bf_doc-line.doc-code = bf_trn-doc.doc-code
     ,each bf_parts
        where bf_parts.obj-type  = bf_trn-doc.obj-type   and
              bf_parts.obj-code  = bf_trn-doc.obj-code   and
              bf_parts.prod-type = bf_doc-line.prod-type and
              bf_parts.prod-code = bf_doc-line.prod-code and
              bf_parts.artic     = bf_doc-line.artic     and
              bf_parts.out-code  = bf_trn-doc.doc-code
    :
    /* Справки А,Б */
    if bf_parts.alc-ref-ab-path <> '' then do:
      find first tt_alcdoc
        where tt_alcdoc.doc-type  = 1
          and tt_alcdoc.file-name = bf_parts.alc-ref-ab-path
        no-error.
      if not available tt_alcdoc then do:
        create tt_alcdoc.
        assign
          tt_alcdoc.selected  = yes /* изначально все строки выделены */
          tt_alcdoc.doc-type  = 1
          tt_alcdoc.doc-name  = "Справки А,Б"
          tt_alcdoc.file-name = bf_parts.alc-ref-ab-path
        .
      end.
    end.

    /* Удостоверение качества */
    if bf_parts.alc-quality-certif-path <> '' then do:
      find first tt_alcdoc
        where tt_alcdoc.doc-type  = 2
          and tt_alcdoc.file-name = bf_parts.alc-quality-certif-path
        no-error.
      if not available tt_alcdoc then do:
        create tt_alcdoc.
        assign
          tt_alcdoc.selected  = yes /* изначально все строки выделены */
          tt_alcdoc.doc-type  = 2
          tt_alcdoc.doc-name  = "Удостоверение качества"
          tt_alcdoc.file-name = bf_parts.alc-quality-certif-path
        .
      end.
    end.

    /* Сертификат соответствия */
    if bf_parts.alc-certif-path <> '' then do:
      find first tt_alcdoc
        where tt_alcdoc.doc-type  = 3
          and tt_alcdoc.file-name = bf_parts.alc-certif-path
        no-error.
      if not available tt_alcdoc then do:
        create tt_alcdoc.
        assign
          tt_alcdoc.selected  = yes /* изначально все строки выделены */
          tt_alcdoc.doc-type  = 3
          tt_alcdoc.doc-name  = "Сертификат соответствия"
          tt_alcdoc.file-name = bf_parts.alc-certif-path
        .
      end.
    end.
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
  DISPLAY fi-default-printer
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-mark b-deselect b-print b-help br-alcdoc
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBR Dialog-Frame
PROCEDURE OpenBR :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  run create-temp-table.
  open query br-alcdoc for each tt_alcdoc.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME