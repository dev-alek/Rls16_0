&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------


$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Копирование значений для средства измерения из одной ПН в другую

Автор: Шкляр Елена Львовна
Дата создания: 04/01/15
Author: Shklyar Elena
Creation date: 04/01/15
*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Копирование информации из одной ПН в другую".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
/*{ ref/sr-izm.i sr-izmerenia ds}*/
/*{ ref/sr-izm.i " " proc }      */
{ ref/gds-attr.i }
{ gbl/lineattr.i }

/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input        parameter parparentproc       as   handle                no-undo .
define input        parameter p-mode              as   character             no-undo .
define input        parameter p-gds-code          like ub.goods.gds-code     no-undo .
define output       parameter p-place-si          as   integer               no-undo .
define output       parameter p-num-plotn         as   character             no-undo .
define output       parameter p-passport-plotn    as   character             no-undo .
define output       parameter p-date-pov-plotn    like ub.rvs-line.real-date no-undo .
/* Local Variable Definitions ---                                       */
{str/valddnst.i def }
define VARIABLE v-artic        like ub.goods.artic no-undo .
define VARIABLE v-prod-code    like ub.goods.prod-code no-undo .
define VARIABLE v-prod-type    like ub.goods.prod-type no-undo .

define buffer buf_goods for ub.goods .
define buffer buf_doc-line-attr for ub.doc-line-attr .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_trn-doc for ub.trn-doc .
/*define buffer buf_clob-bind for ub.clob-bind.*/
define buffer buf_sr-izmerenia for ub.sr-izmerenia .

/* Временная таблица для вывода в интерфейс */
define temp-table tt-doc-iz no-undo like ub.trn-doc
  field code-doc                as character
  field gds-code                like ub.goods.gds-code
  field date-doc                like ub.trn-doc.doc-date
  field num-iz                  as integer
  field iz-name                 as character
  field num-iz-pov              as character
  field date-pov                as date
  field passport-pov            as character
index pi is unique primary code-doc
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-copy-iz

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-doc-iz

/* Definitions for BROWSE br-copy-iz                                    */
&Scoped-define FIELDS-IN-QUERY-br-copy-iz tt-doc-iz.code-doc tt-doc-iz.date-doc tt-doc-iz.num-iz tt-doc-iz.iz-name tt-doc-iz.num-iz-pov tt-doc-iz.date-pov tt-doc-iz.passport-pov   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-copy-iz   
&Scoped-define SELF-NAME br-copy-iz
&Scoped-define QUERY-STRING-br-copy-iz FOR EACH tt-doc-iz
&Scoped-define OPEN-QUERY-br-copy-iz OPEN QUERY {&SELF-NAME} FOR EACH tt-doc-iz.
&Scoped-define TABLES-IN-QUERY-br-copy-iz tt-doc-iz
&Scoped-define FIRST-TABLE-IN-QUERY-br-copy-iz tt-doc-iz


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-copy-iz}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b_save b_quit b_help br-copy-iz 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b_help 
     LABEL "&Помощь" 
     SIZE 15 BY 1.15
     BGCOLOR 8 .

DEFINE BUTTON b_quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 15 BY 1.15
     BGCOLOR 8 .

DEFINE BUTTON b_save AUTO-GO 
     LABEL "&Выбор" 
     SIZE 15 BY 1.15
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-copy-iz FOR 
      tt-doc-iz SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-copy-iz
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-copy-iz Dialog-Frame _FREEFORM
  QUERY br-copy-iz DISPLAY
      tt-doc-iz.code-doc      format "X(10)":U column-label 'Номер'
tt-doc-iz.date-doc      format "99/99/99":U column-label 'Дата'
tt-doc-iz.num-iz        format ">>>>>>":U column-label 'Ср.изм.'
tt-doc-iz.iz-name       format "x(16)":U column-label 'Название ср.изм.'
tt-doc-iz.num-iz-pov    format "X(16)":U column-label 'Номер ср.изм.'
tt-doc-iz.date-pov      format "99/99/99":U column-label 'Дата поверки'
tt-doc-iz.passport-pov  format "X(16)":U column-label 'Паспорт'
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 94 BY 9.33 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b_save AT ROW 1.11 COL 1.25
     b_quit AT ROW 1.11 COL 16.5
     b_help AT ROW 1.11 COL 79.88
     br-copy-iz AT ROW 2.37 COL 1 WIDGET-ID 200
     SPACE(0.37) SKIP(0.59)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Накладные с заполненной доп.инфо"
         DEFAULT-BUTTON b_save CANCEL-BUTTON b_quit WIDGET-ID 100.


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
/* BROWSE-TAB br-copy-iz b_help Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-copy-iz
/* Query rebuild information for BROWSE br-copy-iz
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-doc-iz.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-copy-iz */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Накладные с заполненной доп.инфо */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b_help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_help Dialog-Frame
ON CHOOSE OF b_help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  MESSAGE "Help for File: {&FILE-NAME}" VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b_save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_save Dialog-Frame
ON CHOOSE OF b_save IN FRAME Dialog-Frame /* Выбор */
DO:
  if AVAILABLE tt-doc-iz then do:
    assign
    p-place-si = tt-doc-iz.num-iz
    p-num-plotn = tt-doc-iz.num-iz-pov
    p-passport-plotn = tt-doc-iz.passport-pov
    p-date-pov-plotn = tt-doc-iz.date-pov.
  end.
  else
  MESSAGE "Нет данных для выбора"
  VIEW-AS ALERT-BOX.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-copy-iz
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
  Run fill-tables no-error.
  RUN enable_UI.
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
  ENABLE b_save b_quit b_help br-copy-iz 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame 
PROCEDURE fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define VARIABLE i as DECIMAL no-undo.
define VARIABLE v-value as character no-undo .
define VARIABLE v-type as character no-undo .
define VARIABLE v-format         as character no-undo .
define VARIABLE v-fillin_width   as integer   no-undo .
define VARIABLE v-fillin_height  as integer   no-undo .
define VARIABLE v-label          as character no-undo .
define VARIABLE v-user-can-edit  as logical   no-undo .
define VARIABLE v-output-display as logical   no-undo .
define VARIABLE v-other          as character no-undo .

/*Находим товар*/
find first buf_goods where buf_goods.gds-code = p-gds-code.
      assign
      v-artic = buf_goods.artic
      v-prod-type = buf_goods.prod-type
      v-prod-code = buf_goods.prod-code.


  /*Ищим накладные с таким товаром*/
  for each buf_doc-line where buf_doc-line.artic = v-artic 
    and buf_doc-line.prod-type = v-prod-type
    and buf_doc-line.prod-code = v-prod-code
    and buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
    by buf_doc-line.fact-order desc:
    if i < 10 then 
    do:   
      /*Найдем атрибуты товара*/
  
      /*     run  lineattr-value in this-procedure (input ub.doc-line.doc-code*/
      /*                                           ,input p-gds-code          */
      /*                                           ,input "place-si"          */
      /*                                           ,output v-value            */
      /*                                           ,output v-type )no-error.  */
      /*                                                                      */
      find first buf_doc-line-attr where buf_doc-line-attr.attr-code = "place-si" 
        and buf_doc-line-attr.gds-code = p-gds-code
        and buf_doc-line-attr.doc-code = buf_doc-line.doc-code no-error.

      if AVAILABLE buf_doc-line-attr then 
      do:
        p-place-si = integer(buf_doc-line-attr.attr-value).

        if p-place-si <> 0 then 
        do:
          i=i + 1.
          find first buf_trn-doc where buf_trn-doc.doc-code = buf_doc-line.doc-code no-error.

          /*данные по средству измерения резервуара для ПО МИ*/
          find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = p-place-si no-error.

          find first buf_doc-line-attr where buf_doc-line-attr.attr-code = "num-plotn" 
            and buf_doc-line-attr.gds-code = p-gds-code
            and buf_doc-line-attr.doc-code = buf_doc-line.doc-code no-error.
  
          p-num-plotn = buf_doc-line-attr.attr-value no-error.                                                     

          find first buf_doc-line-attr where buf_doc-line-attr.attr-code = "date-pov-plotn" 
            and buf_doc-line-attr.gds-code = p-gds-code
            and buf_doc-line-attr.doc-code = buf_doc-line.doc-code no-error.

          p-date-pov-plotn = date(buf_doc-line-attr.attr-value) no-error.

          if buf_sr-izmerenia.sr-type-id = 3 or buf_sr-izmerenia.sr-type-id = 4 then 
          do:

            find first buf_doc-line-attr where buf_doc-line-attr.attr-code = "passport-plotn" 
              and buf_doc-line-attr.gds-code = p-gds-code
              and buf_doc-line-attr.doc-code = buf_doc-line.doc-code no-error.

            p-passport-plotn = buf_doc-line-attr.attr-value no-error.          
          end. /*if sr-izmerenia.sr-type = "3" or sr-izmerenia.sr-type = "4" then*/
 
          else p-passport-plotn = "".    

          create tt-doc-iz. 
          assign 
            tt-doc-iz.code-doc     = buf_doc-line.doc-code
            tt-doc-iz.gds-code     = p-gds-code
            tt-doc-iz.date-doc     = buf_trn-doc.doc-date
            tt-doc-iz.num-iz       = p-place-si
            tt-doc-iz.iz-name      = buf_sr-izmerenia.sr-model
            tt-doc-iz.num-iz-pov   = p-num-plotn
            tt-doc-iz.date-pov     = p-date-pov-plotn
            tt-doc-iz.passport-pov = p-passport-plotn.    
        end. 
      end. /*       if AVAILABLE buf_doc-line-attr then*/                                   
    end. /*if i < 10 then do:*/
  end. /*for each buf_doc-line where buf_doc-line.artic = v-artic*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

