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

утилита  Привязка партий и складских документов к договору поставщика

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "утилита  Привязка партий и складских документов к договору поставщика" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ str/libtfarh.i }
{ cmp/showinf.i  }
{ gbl/clntattr.i }

/* Parameters Definitions ---                                           */
define input parameter ParParentProc as handle           no-undo.

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

/* Local Variable Definitions ---                                       */
define variable contr-list  as CHAR  no-undo .
define variable v-str  as CHAR  no-undo .
define variable par-type  as CHAR  no-undo .
define variable doc-list  as CHAR  no-undo .
define variable ii as integer   no-undo .
define variable v-contract-purch-code as integer   no-undo .
define variable list_num as character no-undo .
define variable db-list  as character no-undo .
define variable doc-rec  as recid no-undo .
define variable list-mode as character no-undo .
define variable to-arm  as character no-undo .

define buffer buf_contract for contract .
define buffer buf_clients for clients .
define buffer buf_trn-doc for trn-doc .
define buffer buf_parts for parts.
define buffer buf_parts-attr for parts-attr.

DEFINE temp-table temp-doc no-undo
  field id         as   character
  field fact-order like ub.trn-doc.fact-order
  INDEX pi IS PRIMARY id
  index fact-order fact-order
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-OK b-exit B-Help RECT-7 RECT-8 RADIO-contr ~
contr-code BUTTON-contr RADIO-doc trn-doc-code
&Scoped-Define DISPLAYED-OBJECTS RADIO-contr contr-code snum RADIO-doc ~
trn-doc-code SELECT-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Отмена":L
     size 10 by 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод ":L
     size 10 by 1.

DEFINE BUTTON BUTTON-contr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.

DEFINE VARIABLE contr-code AS CHARACTER FORMAT "X(16)":U
     VIEW-AS FILL-IN
     SIZE 18.5 BY 1 NO-UNDO.

DEFINE VARIABLE snum AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 35 BY 1 NO-UNDO.

DEFINE VARIABLE trn-doc-code AS CHARACTER FORMAT "X(15)":U
     LABEL "№"
     VIEW-AS FILL-IN
     SIZE 17.63 BY 1 NO-UNDO.

DEFINE VARIABLE RADIO-contr AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Вн. №", 1,
"Номер", 2
     SIZE 10.5 BY 1.75 NO-UNDO.

DEFINE VARIABLE RADIO-doc AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Одна", 1,
"Список", 2
     SIZE 11 BY 3.92 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 38.5 BY 4.75.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 38.5 BY 7.5.

DEFINE VARIABLE SELECT-1 AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 19 BY 4.25 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-OK at row 1 col 1
     b-exit at row 1 col 11
     B-Help AT ROW 1 COL 30.63
     RADIO-contr AT ROW 3.5 COL 3.5 NO-LABEL
     contr-code AT ROW 3.83 COL 13.5 COLON-ALIGNED NO-LABEL
     BUTTON-contr AT ROW 3.83 COL 35
     snum AT ROW 5.75 COL 1.5 COLON-ALIGNED NO-LABEL
     RADIO-doc AT ROW 8.71 COL 3.5 NO-LABEL
     trn-doc-code AT ROW 9 COL 16.38 COLON-ALIGNED
     SELECT-1 AT ROW 10.5 COL 17.13 NO-LABEL
     "Договор:" VIEW-AS TEXT
          SIZE 10 BY 1 AT ROW 2.5 COL 3
          FGCOLOR 4
     "Приходная накладная:" VIEW-AS TEXT
          SIZE 25 BY 1 AT ROW 7.75 COL 2.5
          FGCOLOR 4
     RECT-7 AT ROW 2.25 COL 2
     RECT-8 AT ROW 7.5 COL 2
     SPACE(9.50) SKIP(0.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Привязка партий и складских документов к договору".


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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR SELECTION-LIST SELECT-1 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN snum IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       snum:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Привязка партий и складских документов к договору */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-OK Dialog-Frame
ON CHOOSE OF b-OK IN FRAME Dialog-Frame /* Ввод  */
DO:

  if list_num = "" then do:
    message  "Не выбраны документы!"  view-as alert-box.
    return no-apply .
  end.

  run proc-OK .

  message
    "Работа утилиты завершена"
    view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-contr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-contr Dialog-Frame
ON CHOOSE OF BUTTON-contr IN FRAME Dialog-Frame /* 2 */
DO:
  DISABLE RADIO-doc WITH FRAME Dialog-Frame.
  run str/cont-all.w (input ParParentProc, input v-cntxt-host-code-obj, input "b-sel", input {&company}, input ?,
                  input ?, input ?, input ?, input "current":u, input {&income}, input-output contr-list).
  if contr-list <> "" then do:
    find first buf_contract no-lock where RECID(buf_contract) = int (contr-list) no-error .
    if available buf_contract then do:
      assign snum    = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")  .
      if RADIO-contr = 1 then assign contr-code = string(buf_contract.contract-code) .
      else                    assign contr-code = buf_contract.contract-prn-code .
      ENABLE RADIO-doc WITH FRAME Dialog-Frame.
      find first buf_clients no-lock where buf_clients.obj-code = buf_contract.cli-code and buf_clients.obj-type = buf_contract.cli-type no-error .
      { gbl/cntpurch.i buf_contract.contract-type  v-contract-purch-code }
      apply "VALUE-CHANGED" to RADIO-doc in frame {&frame-name}.
    end.
    else assign  contr-code = ""   snum = "" .
  end.
  display contr-code snum with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME contr-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL contr-code Dialog-Frame
ON LEAVE OF contr-code IN FRAME Dialog-Frame
DO:
  assign contr-code RADIO-contr .
  run  FindRec in this-procedure  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL contr-code Dialog-Frame
ON RETURN OF contr-code IN FRAME Dialog-Frame
DO:
  assign contr-code RADIO-contr .
  run FindRec in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-contr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-contr Dialog-Frame
ON VALUE-CHANGED OF RADIO-contr IN FRAME Dialog-Frame
DO:
  if trn-doc-code <> "" then apply "RETURN" to trn-doc-code in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-doc Dialog-Frame
ON VALUE-CHANGED OF RADIO-doc IN FRAME Dialog-Frame
DO:
  if input frame {&frame-name} radio-doc <> radio-doc then do:
    ASSIGN frame dialog-frame RADIO-doc .
    IF RADIO-doc = 1 THEN DO:
      ENABLE trn-doc-code WITH FRAME Dialog-Frame.
      DISABLE SELECT-1 WITH FRAME Dialog-Frame.
      apply "entry" to trn-doc-code in frame {&frame-name}.
      return no-apply.
    END.
    ELSE DO:
      DISABLE trn-doc-code WITH FRAME Dialog-Frame.
      ENABLE SELECT-1 WITH FRAME Dialog-Frame.
      find first buf_clients no-lock where
            buf_clients.obj-code = buf_contract.cli-code and
            buf_clients.obj-type = buf_contract.cli-type no-error .
      assign
        doc-rec = recid(buf_clients)
        list-mode = "client-income":u
        list_num  = ""
        doc-list = ""
      .
      SELECT-1:LIST-ITEMS = list_num.

      run str/all-docs.w (
      input ParParentProc,
      input v-cntxt-host-code-obj,
      input ?,
      input ?,
      input "client-income":u,
      input ?,
      input ?,
      input ?,
      input ?,
      input "b-sel,b-mark",
      input {&TDEDT_Pri_Vnesh},
      input no,
      input  doc-rec ,
      output doc-list).
      if doc-list <> "" then do:
        do ii = 1 to num-entries(doc-list):
          find first buf_trn-doc no-lock where RECID(buf_trn-doc) = integer(entry(ii, doc-list)) no-error.
          run CheckDoc no-error  .
          if error-status:error then return no-apply.
          if ii = 1 then assign list_num = buf_trn-doc.doc-code .
          else           assign list_num = list_num + "," + buf_trn-doc.doc-code .
        end.
        message "Проверка данных завершена, можно запустить утилиту." view-as alert-box.
      end.
      SELECT-1:LIST-ITEMS = list_num .
      return no-apply.
    END.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME trn-doc-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL trn-doc-code Dialog-Frame
ON LEAVE OF trn-doc-code IN FRAME Dialog-Frame /* № */
DO:
  assign trn-doc-code.
  if trn-doc-code <> "" then run  FindDoc in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL trn-doc-code Dialog-Frame
ON RETURN OF trn-doc-code IN FRAME Dialog-Frame /* № */
DO:
  assign trn-doc-code.
  if trn-doc-code <> "" then run FindDoc in this-procedure .
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

  define variable num-db as integer   no-undo .
  { gbl/curdbnum.i num-db }
  if num-db <> 0 then do:
    message  "Данная утилита предназначена для работы только в главной БД"  view-as alert-box.
    return no-apply .
  end.

  RUN enable_UI.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CheckDoc Dialog-Frame
PROCEDURE CheckDoc :
define variable p-status       as integer   no-undo .
define variable p-cut-date     as date      no-undo .
define variable p-cut-fin-date as date      no-undo .
do on error undo, return error return-value :
    if buf_contract.cli-code <> buf_trn-doc.cli-code or buf_contract.cli-type <> buf_trn-doc.cli-type then do:
      message "Поставщик в накладной " buf_trn-doc.doc-code " не совпал с поставщиком в договоре!" view-as alert-box.
      return error.
    end.
    { gbl/cutd-obj.i buf_trn-doc.obj-type buf_trn-doc.obj-code p-status p-cut-date p-cut-fin-date }
    if p-cut-date <> ? then do:
      message "Документ " buf_trn-doc.doc-code " по объекту " buf_trn-doc.obj-type " " buf_trn-doc.obj-code " . На объекте было обрезание документов. Перепривязка партий и пересчет архивов невозможен." view-as alert-box.
      return error.
    end.

    if buf_contract.curr-code <> buf_trn-doc.exch-code then do:
      message "Валюта в накладной " buf_trn-doc.doc-code " не совпала с валютой договора!" view-as alert-box.
      return error.
    end.
    run CheckParts (input buf_trn-doc.doc-code) no-error .
    if error-status:error then return error.
  end.
end procedure. /* CheckDoc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CheckParts Dialog-Frame
PROCEDURE CheckParts :
define input  parameter num as character no-undo .
  do on error undo, return error return-value :
    for each buf_parts-attr no-lock where buf_parts-attr.in-code = num :
      if v-contract-purch-code <> buf_parts-attr.purch-code then do:
        message
          "Не совпали тип приобретения у партии (in-code=" num " gds-code=" buf_parts-attr.gds-code "
          part-code=" buf_parts-attr.part-code "тип=" string(buf_parts-attr.purch-code) ") и у договора (тип=" v-contract-purch-code ")"
        view-as alert-box.
        return error .
      end.
    end.
    for each buf_parts no-lock where buf_parts.out-code = num :
      if v-contract-purch-code <> buf_parts.purch-code then do:
        message
          "Не совпали тип приобретения у партии (
            in-code=" num
          " artic=" buf_parts.artic
          " prod-code=" buf_parts.prod-code
          " prod-type=" buf_parts.prod-type
          " part-code=" buf_parts.part-code "тип=" string(buf_parts.purch-code) ") и у договора (тип=" v-contract-purch-code ")"
        view-as alert-box.
        return error .
      end.
    end.
  end.
end procedure. /* CheckParts */

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
  DISPLAY RADIO-contr contr-code snum RADIO-doc trn-doc-code SELECT-1
      WITH FRAME Dialog-Frame.
  ENABLE b-OK b-exit B-Help RECT-7 RECT-8 RADIO-contr contr-code BUTTON-contr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FindDoc Dialog-Frame
PROCEDURE FindDoc :
do on error undo, return error return-value :
    assign list_num = "" .
    find first buf_parts-attr no-lock where buf_parts-attr.in-code = trn-doc-code no-error .
    find first buf_parts no-lock where buf_parts.out-code = trn-doc-code no-error .
    if not available buf_parts-attr and  not available buf_parts then do:
      message
       "Следов документа " trn-doc-code "не найдено!"
      view-as alert-box.
      assign RADIO-doc = 2 .
      display RADIO-doc with frame {&frame-name}.
      apply "VALUE-CHANGED" to RADIO-doc in frame {&frame-name}.
      return no-apply .
    end.
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = trn-doc-code no-error .
    if available buf_trn-doc then do:
      run CheckDoc no-error .
      if error-status:error then return no-apply.
    end.
    else do:
      run CheckParts (input trn-doc-code) no-error .
      if error-status:error then return no-apply.
    end.
    assign list_num = trn-doc-code .
    message
      "Проверка данных завершена, можно запустить утилиту."
      view-as alert-box.
  end.
end procedure. /* CheckDoc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE FindRec Dialog-Frame
PROCEDURE FindRec :
do on error undo, return error return-value :
    DISABLE RADIO-doc WITH FRAME Dialog-Frame.
    if RADIO-contr = 1 then find first buf_contract no-lock where buf_contract.contract-code = int(contr-code) and buf_contract.host-code = v-cntxt-host-code-obj no-error .
    else                    find first buf_contract no-lock where buf_contract.contract-prn-code = contr-code  and buf_contract.host-code = v-cntxt-host-code-obj no-error .
    if available buf_contract then do:
      assign  snum = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")  .
      find first buf_clients no-lock where buf_clients.obj-code = buf_contract.cli-code and buf_clients.obj-type = buf_contract.cli-type no-error .
      { gbl/cntpurch.i buf_contract.contract-type  v-contract-purch-code }
      ENABLE RADIO-doc WITH FRAME Dialog-Frame.
      apply "VALUE-CHANGED" to RADIO-doc in frame {&frame-name}.
    end.
    else assign  contr-code = ""    snum = "" .
    display contr-code snum with frame {&frame-name}.
  end.
end procedure. /* FindRec */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AddDoc Dialog-Frame
PROCEDURE AddDoc :
  define input  parameter p-num as character no-undo .
  do on error undo, return error return-value :
    find first temp-doc where temp-doc.id = p-num no-error .
    if not available temp-doc then do:
      create temp-doc .
      assign temp-doc.id = p-num .
      find first trn-doc no-lock where trn-doc.doc-code = p-num no-error  .
      if available trn-doc then do:
        run clntattr-value in this-procedure  (input trn-doc.obj-type,input trn-doc.obj-code,
                input  {&attr-arh-trn-doc-contract}, output v-str, output par-type) no-error .
        if error-status:error or logical(v-str) = no then do:
          run clntattr-write in this-procedure ( input trn-doc.obj-type,input trn-doc.obj-code, input {&attr-arh-trn-doc-contract}, input "yes":u).
        end.
/*        { str/datrncnt.i p-num no-error }*/
/*        if error-status:error then message return-value error-status:get-message(1) view-as alert-box.*/
      end.
    end.
  end.
end procedure. /* AddDoc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CalcArh Dialog-Frame
PROCEDURE CalcArh :
  do on error undo, return error return-value :
    for each temp-doc use-index fact-order :
      find first trn-doc no-lock where trn-doc.doc-code = temp-doc.id no-error  .
      if available trn-doc then do:
/*        { str/latrncnt.i temp-doc.id no-error }*/
/*        if error-status:error then message return-value error-status:get-message(1) view-as alert-box.*/
/*        { str/catrncnt.i temp-doc.id no-error }*/
/*        if error-status:error then message return-value error-status:get-message(1) view-as alert-box.*/
        { str/st-fo.i temp-doc.id no-error }
        if error-status:error then message return-value error-status:get-message(1) view-as alert-box.
      end.
    end.
  end.
end procedure. /* CalcArh */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-OK Dialog-Frame
procedure proc-OK :
  do
  on error undo, return error return-value
  :
  define variable Counter1 as integer   no-undo .

  on write of ub.trn-doc override do:  end.
  define variable num as character no-undo .

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 5 } /* Показать окно информации о текущем процессе */
  do transaction :
    assign db-list = "" .
    for each db exclusive-lock where db.db-num <> 0 :
      if db-list = "" then assign db-list = string(db.db-num) .
      else                 assign db-list = db-list + {&delim-nws} + string(db.db-num) .
    end.
    do ii = 1 to num-entries(list_num):
      num = entry(ii, list_num) .
      run AddDoc (num) .
      find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = num no-error .
      if available buf_trn-doc then do:
        assign buf_trn-doc.contract-code = buf_contract.contract-code .
      end.
      for each buf_parts-attr exclusive-lock where buf_parts-attr.in-code = num :
        assign buf_parts-attr.contract-code = buf_contract.contract-code .
        assign Counter1 = Counter1 + 1.
        { rep/repfrm.i disp Counter1 }
      end.
      for each buf_parts exclusive-lock where buf_parts.out-code = num :
        assign buf_parts.contract-code = buf_contract.contract-code .
        for each gds-obj exclusive-lock
          where gds-obj.artic     =  buf_parts.artic
            and gds-obj.prod-type =  buf_parts.prod-type
            and gds-obj.prod-code =  buf_parts.prod-code
         , each parts exclusive-lock
          where parts.obj-type  =  gds-obj.obj-type
            and parts.obj-code  =  gds-obj.obj-code
            and parts.artic     =  buf_parts.artic
            and parts.prod-type =  buf_parts.prod-type
            and parts.prod-code =  buf_parts.prod-code
            and parts.in-code   =  buf_parts.in-code
            and parts.part-code =  buf_parts.part-code
          :
          run AddDoc (parts.out-code) .
          assign parts.contract-code = buf_contract.contract-code .
          assign Counter1 = Counter1 + 1.
          { rep/repfrm.i disp Counter1 }
        end.
      end.
    end.
    run CalcArh in this-procedure .
  end.
  /* вызвать новости */
  run nws/cr-route.p ( input {&send-cmd}
                  ,input "command":U + {&delim-nws} + "fill-contract":U + {&delim-nws} + string(buf_contract.contract-code) + {&delim-nws} + list_num
                  ,input ?
                  ,input db-list
                 ).
  end.
end procedure. /* proc-OK */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME