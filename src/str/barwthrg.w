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

Диалог идентификации талона

Автор: Гридчина Полина Дмитриевна
Дата создания: 08/22/07
Author: Polina Gridchina
Creation date: 08/22/07

Разбирает штрих-код и добавляет талон в документ

*/

define input parameter p-doc-code as character no-undo.
define input parameter p-w-p-code as int no-undo.
define input parameter p-out-w-p-code as int no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог идентификации талона".
{ cmp/vssrevis.i }
{ str/wthparts.i def }
 define buffer buf_wth-doc    for ub.wth-doc.
 define buffer buf_wth-line   for ub.wth-line.
 define buffer buf_wth-dtl    for ub.wth-dtl.
 define buffer buf_wth-par    for ub.wth-par.
 define buffer buf_wth-parts  for ub.wth-parts.
 define temp-table tt-wth-line  no-undo like ub.wth-line .
 DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
       { str/ttpardt0.i }.

/*------------------------------------------------------------------------


  Created:
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS bar-strFrom bar-strTo B-exit B-quit b-help
&Scoped-Define DISPLAYED-OBJECTS bar-strFrom bar-strTo

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit
     LABEL "&Ввод"
     SIZE 9.5 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 4.5 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 9 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE bar-strFrom AS CHARACTER FORMAT "X(256)":U
     LABEL "Первый штрих-код партии"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE bar-strTo AS CHARACTER FORMAT "X(256)":U
     LABEL "Последний штрих-код партии"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     bar-strFrom AT ROW 1.5 COL 4.5 WIDGET-ID 2
     bar-strTo AT ROW 2.75 COL 27.5 COLON-ALIGNED WIDGET-ID 4
     B-exit AT ROW 4.5 COL 2
     B-quit AT ROW 4.5 COL 11.5
     b-help AT ROW 4.5 COL 28
     SPACE(20.74) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Коды талонов партии"
         CANCEL-BUTTON B-quit WIDGET-ID 100.


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
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN bar-strFrom IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Коды талонов партии */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  assign frame  {&FRAME-NAME} bar-strFrom bar-strTo.
  output to "wthscan.txt" append.
  put unformatted substitute("&1 &2 &3-&4 Документ:&5",string(today,"99/99/9999"),string(time,"HH:MM:SS"), bar-strFrom, bar-strTo , p-doc-code)  skip.
  OUTPUT CLOSE.
  run proc-save (input bar-strFrom
                ,INPUT bar-strTo) no-error.
  if error-status:error then do:
    message return-value error-status:get-message(1) view-as alert-box.
  end.
  else do:
    bar-strFrom:screen-value = '':U.
    bar-strTo:screen-value = '':U.
  end.
  apply 'entry':U to bar-strFrom.
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


&Scoped-define SELF-NAME bar-strFrom
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bar-strFrom Dialog-Frame
ON LEAVE OF bar-strFrom IN FRAME Dialog-Frame /* Первый штрих-код партии */
DO:
  bar-strFrom = SELF:SCREEN-VALUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bar-strFrom Dialog-Frame
ON RETURN OF bar-strFrom IN FRAME Dialog-Frame /* Первый штрих-код партии */
DO:
  APPLY 'tab' TO SELF.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bar-strTo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bar-strTo Dialog-Frame
ON RETURN OF bar-strTo IN FRAME Dialog-Frame /* Последний штрих-код партии */
DO:
  APPLY 'choose':U TO b-exit.
  RETURN NO-APPLY.
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
  RUN enable_UI.
  find first buf_wth-doc no-lock where
            buf_wth-doc.doc-code = p-doc-code no-error.
  if not available buf_wth-doc then do:
    message substitute('Не найден документ с номерм &1',p-doc-code) view-as alert-box error.
    return.
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
  DISPLAY bar-strFrom bar-strTo
      WITH FRAME Dialog-Frame.
  ENABLE bar-strFrom bar-strTo B-exit B-quit b-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-barFrom AS CHAR NO-UNDO.
DEFINE INPUT PARAMETER p-barTo AS CHAR NO-UNDO.
define variable v-ser-code-from  as integer      no-undo.
define variable v-db-num-from    as integer      no-undo.
define variable v-stts-from      as integer      no-undo.
define variable v-wth-code-from  as integer      no-undo.
define variable v-gds-code-from  as integer      no-undo.
define variable v-par-code-from  as integer      no-undo.
define variable v-zone-from      as character    no-undo.
define variable v-fromDate-from  as date         no-undo.
define variable v-ToDate-from    as date         no-undo.
define variable v-rangeNum-from  as integer      no-undo.
define variable v-ser-code-to  as integer      no-undo.
define variable v-db-num-to    as integer      no-undo.
define variable v-stts-to      as integer      no-undo.
define variable v-wth-code-to  as integer      no-undo.
define variable v-gds-code-to  as integer      no-undo.
define variable v-par-code-to  as integer      no-undo.
define variable v-zone-to      as character    no-undo.
define variable v-fromDate-to  as date         no-undo.
define variable v-ToDate-to    as date         no-undo.
define variable v-rangeNum-to  as integer      no-undo.
define variable parline-rec      as recid        no-undo.
define variable parparts-rec    as recid        no-undo.

empty temp-table tt-par-dtl.
empty temp-table tt-wth-line.
parline-rec = ?.
parparts-rec = ?.
do transaction on error undo, return error return-value
               on stop  undo, return
               on quit  undo, return:

run str/wthidnt.p ( input bar-strFrom /*"КОД ТАЛОНА"*/
          ,output v-ser-code-from
          ,output v-db-num-from
          ,output v-stts-from
          ,output v-wth-code-from
          ,output v-gds-code-from
          ,output v-par-code-from
          ,output v-zone-from
          ,output v-FromDate-from
          ,output v-ToDate-from
          ,output v-rangeNum-from
          ) no-error.
if error-status:error then do:
  output to "wthscan.txt" append.
  put unformatted  string(today,"99/99/9999") ' ' string(time,"HH:MM:SS") error-status:get-message(1) + {&space-char} + return-value skip.
  OUTPUT CLOSE.
   message error-status:get-message(1) + {&space-char} + return-value.
   undo, return .
end.
output to "wthscan.txt" append.
put unformatted substitute("&5 &6 Идентифицирован талон МЦ &1 код номинала &2 НОМЕР &3 Зона &4. Документ &7 ",v-wth-code-from,v-par-code-from,v-rangeNum-from, v-zone-from, string(today,"99/99/9999"), string(time,"HH:MM:SS"),buf_wth-doc.doc-code ) skip.
OUTPUT CLOSE.
run str/wthidnt.p ( input bar-strTo /*"КОД ТАЛОНА"*/
          ,output v-ser-code-To
          ,output v-db-num-To
          ,output v-stts-To
          ,output v-wth-code-To
          ,output v-gds-code-To
          ,output v-par-code-To
          ,output v-zone-To
          ,output v-FromDate-To
          ,output v-ToDate-To
          ,output v-rangeNum-To
          ) no-error.
if error-status:error then do:
  output to "wthscan.txt" append.
  put unformatted  string(today,"99/99/9999") ' ' string(time,"HH:MM:SS") error-status:get-message(1) + {&space-char} + return-value skip.
  OUTPUT CLOSE.
   message error-status:get-message(1) + {&space-char} + return-value.
   undo, return .
end.
output to "wthscan.txt" append.
put unformatted substitute("&5 &6 Идентифицирован талон МЦ &1 код номинала &2 НОМЕР &3 Зона &4.  Документ &7 ",v-wth-code-to,v-par-code-to,v-rangeNum-to, v-zone-to, string(today,"99/99/9999"), string(time,"HH:MM:SS"),buf_wth-doc.doc-code) skip.
OUTPUT CLOSE.

run wth-parts-rezerv( no
                    ,v-rangeNum-From
                    ,v-rangeNum-To
                   /* ,v-rangeNum
                    ,v-rangeNum  */
                    ,?
                    ,?
                    ,v-ser-code-to
                    ,v-db-num-to
                    ,0
                    ,0
                    ,0
                    ,buf_wth-doc.host-code
                    ,buf_wth-doc.obj-type
                    ,buf_wth-doc.obj-code
                    ,p-w-p-code
                    ,v-wth-code-to
                    ,v-par-code-to
                    ,'':U
                    ,buf_wth-doc.doc-code
                    ,buf_wth-doc.cli-type
                    ,buf_wth-doc.cli-code
                    ,buf_wth-doc.ext-doc-type
                    ,v-gds-code-to
                    ,(if buf_wth-doc.ext-doc-type = {&WDEDT_Exch} then {&income} else buf_wth-doc.doc-type)
                    ,input-output parparts-rec
                   ) no-error.
  if error-status:error then do:
   message 'Ошибка резервирования партии' + error-status:get-message(1) + {&space-char} + return-value.
   undo, return .

  end.

/*Создаем линии во времен. таблицах. Если есть такие линии заполняем ими времен. таблицы.*/
create tt-wth-line.
assign tt-wth-line.wth-code = v-wth-code-To
        tt-wth-line.doc-code = buf_wth-doc.doc-code
        tt-wth-line.w-p-code = p-w-p-code
    .
find first buf_wth-line no-lock where
           buf_wth-line.doc-code = buf_wth-doc.doc-code
       and buf_wth-line.wth-code = v-wth-code-To no-error.
if  available buf_wth-line then do:
  buffer-copy buf_wth-line to tt-wth-line.
  parline-rec = recid(buf_wth-line).
end.
for each buf_wth-dtl no-lock where         /*заполняем по существующим номиналам времен. таблицу, для того чтобы передать ее при сохранении линии*/
         buf_wth-dtl.wth-code = v-wth-code-To
     and buf_wth-dtl.doc-code = buf_wth-doc.doc-code
     :
     create tt-par-dtl.
     buffer-copy buf_wth-dtl to tt-par-dtl.
end.
    find first tt-par-dtl where tt-par-dtl.par-code = v-par-code-To no-error.
    if not available tt-par-dtl
    then do:
      create tt-par-dtl.
      assign
      tt-par-dtl.par-code = v-par-code-to
      tt-par-dtl.wth-code = v-wth-code-to
      tt-par-dtl.w-p-code =  p-w-p-code
      tt-par-dtl.doc-code = buf_wth-doc.doc-code
      .
    end.
    find first buf_wth-par no-lock where
                buf_wth-par.par-code = tt-par-dtl.par-code
            and buf_wth-par.wth-code = tt-par-dtl.wth-code.
    assign
      tt-par-dtl.par-val  = buf_wth-par.par-val
      tt-par-dtl.par-unit = buf_wth-par.par-unit
      tt-par-dtl.par-feat = buf_wth-par.par-feat
      tt-par-dtl.par-rate = buf_wth-par.par-rate
      .

{ str/dtlsum.i tt-par-dtl buf_wth-parts }

{ str/wthlnsum.i tt-wth-line tt-par-dtl}

 run str/wth-lnc1.p (
                      input-output parline-rec
                      , (if parline-rec = ? then {&add-def} else {&update})
                      ,input no
                      ,input buf_wth-doc.doc-code
                      ,input tt-wth-line.wth-code
                      ,input p-W-P-CODE
                      ,input p-OUT-W-P-CODE
                      ,input tt-wth-line.doc-sum
                      ,input tt-wth-line.fact-sum
                      ,input table tt-par-dtl
                      ,input no /*par-log*/
                      ,input buf_wth-doc.ext-doc-type
                      ,input tt-wth-line.sum-gds-rubl
                      ,input tt-wth-line.sum-gds-base
                      ) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
      message return-value + error-status:get-message(1) view-as alert-box.
      undo, return.
    end.

end.  /*transaction*/
/*bar-str:screen-value in frame {&FRAME-NAME}  = ''.
apply 'entry':U to bar-str.     */
return no-apply.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME