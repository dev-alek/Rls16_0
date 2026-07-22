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

Утилита обновления реквизитов клиентов в незакрытые платежи

Автор: Кочетков Михаил Юрьевич
Дата создания: 02/16/06
Author: Michael Kochetkov
Creation date: 02/16/06

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "обновление реквизитов клиентов в незакрытых платежах из договора".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ ref/fndocip.i }

/* Parameters Definitions ---                                           */
define input parameter ParParentProc as handle           no-undo.

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

/* Local Variable Definitions ---                                       */
define variable ii as integer   no-undo .
define variable is-edit as logical   no-undo .

define variable v-name as character no-undo .
define variable v-inn  as character no-undo .
define variable v-kpp  as character no-undo .

define buffer buf_contract for contract .
define buffer buf_fin-doc  for fin-doc .
define buffer buf_fin-ob  for fin-ob .

DEFINE TEMP-TABLE tt-fin-ob       NO-UNDO LIKE fin-ob .
DEFINE TEMP-TABLE tt-fin-doc      NO-UNDO LIKE fin-doc .
DEFINE TEMP-TABLE tt-fin-doc-attr NO-UNDO LIKE fin-doc-attr .
DEFINE TEMP-TABLE tt-fin-doc-tax  NO-UNDO LIKE fin-doc-tax .
define temp-table tt0-payment     no-undo like ub.payment.

define variable v-logfile as character no-undo .
assign v-logfile = 'updfind.log' .

  os-delete v-logfile .
  { str/writelog.i def v-logfile }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-OK RECT-7 b-exit B-Help TOG-name TOG-inn ~
TOG-kpp
&Scoped-Define DISPLAYED-OBJECTS TOG-name TOG-inn TOG-kpp

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Отмена":L
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.5 BY 5.

DEFINE VARIABLE TOG-inn AS LOGICAL INITIAL no
     LABEL "{&abbr_inn_allshift}"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-kpp AS LOGICAL INITIAL no
     LABEL "{&abbr_kpp_allshift}"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-name AS LOGICAL INITIAL no
     LABEL "Наименование"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-OK AT ROW 1 COL 1
     b-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 24.5
     TOG-name AT ROW 3.63 COL 4.63
     TOG-inn AT ROW 4.75 COL 4.63
     TOG-kpp AT ROW 5.83 COL 4.75
     "Обновить:" VIEW-AS TEXT
          SIZE 10 BY 1 AT ROW 2.5 COL 3
          FGCOLOR 4
     RECT-7 AT ROW 2.25 COL 2
     SPACE(0.74) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Обновление реквизитов клиентов в незакрытых платежах из договора".


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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Обновление реквизитов клиентов в незакрытых платежах из договора */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-OK Dialog-Frame
ON CHOOSE OF b-OK IN FRAME Dialog-Frame /* Ввод  */
DO:
  assign
    TOG-name
    TOG-inn
    TOG-kpp
  .

  run proc-OK .

/*  message*/
/*    "Работа утилиты завершена"*/
/*    view-as alert-box.*/
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
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_updfind_update':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    is-edit
  }
  if is-edit = false then return no-apply .

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
  DISPLAY TOG-name TOG-inn TOG-kpp
      WITH FRAME Dialog-Frame.
  ENABLE b-OK RECT-7 b-exit B-Help TOG-name TOG-inn TOG-kpp
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-OK Dialog-Frame
PROCEDURE proc-OK :
  do on error undo, return error return-value :

    define variable Counter1 as integer   no-undo .

    { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
    { rep/repfrm.i on 5 } /* Показать окно информации о текущем процессе */

    for each buf_fin-doc no-lock
      where  buf_fin-doc.host-code    = v-cntxt-host-code-obj
        and  buf_fin-doc.status_      = {&fin-new}
      :
      find first buf_contract no-lock
        where buf_contract.host-code     = buf_fin-doc.host-code
          and buf_contract.contract-code = buf_fin-doc.contract-code
      no-error .
      if not available buf_contract then next.

      { rep/repfrm.i disp Counter1 }
      run writelog ( v-logfile, 0, string(Counter1,">>>9") + " Проверка фин. документа вн. номер " + string(buf_fin-doc.fin-doc-code) + " по договору вн.номер "  + string(buf_fin-doc.contract-code)) .
      assign
        Counter1 = Counter1 + 1
        is-edit  = no
      .

      if available tt-fin-doc then delete tt-fin-doc .
      for each tt-fin-doc-tax :   delete tt-fin-doc-tax .  end.
      for each tt-fin-doc-attr :  delete tt-fin-doc-attr . end.

      buffer-copy buf_fin-doc to tt-fin-doc .

      if tt-fin-doc.payer-code =  buf_contract.host-code and tt-fin-doc.payer-type = {&cmp} then do:
        /* плательщик мы  */
        if TOG-name then do:
          if tt-fin-doc.payer-name <> buf_contract.own-name then do:
            run writelog ( v-logfile, 0, "    Изменение наименования плательщика. " + tt-fin-doc.payer-name + " -> " + buf_contract.own-name ) .
            assign is-edit = yes  tt-fin-doc.payer-name = buf_contract.own-name .
          end.
        end.
        if TOG-inn then do:
          if tt-fin-doc.payer-inn <> buf_contract.own-inn then do:
            run writelog ( v-logfile, 0, "    Изменение {&abbr_inn_allshift} плательщика. " + tt-fin-doc.payer-inn + " -> " + buf_contract.own-inn ) .
            assign is-edit = yes  tt-fin-doc.payer-inn = buf_contract.own-inn .
          end.
        end.
        if TOG-kpp then do:
          if tt-fin-doc.payer-kpp <> buf_contract.own-kpp then do:
            run writelog ( v-logfile, 0, "    Изменение {&abbr_kpp_allshift} плательщика. " + tt-fin-doc.payer-kpp + " -> " + buf_contract.own-kpp ) .
            assign is-edit = yes  tt-fin-doc.payer-kpp = buf_contract.own-kpp .
          end.
        end.
        /* проверяем контрагента */
        if tt-fin-doc.receiver-code =  buf_contract.cli-code and tt-fin-doc.receiver-type =  buf_contract.cli-type then do:
          assign  v-name = buf_contract.cli-name    v-inn  = buf_contract.cli-inn   v-kpp  = buf_contract.cli-kpp .
        end.
        else do:
          if tt-fin-doc.receiver-code =  buf_contract.posr-code and tt-fin-doc.receiver-type =  buf_contract.posr-type then do:
            assign  v-name = buf_contract.posr-name    v-inn  = buf_contract.posr-inn   v-kpp  = buf_contract.posr-kpp .
          end.
          else do:
            if tt-fin-doc.receiver-code =  buf_contract.agnt-code and tt-fin-doc.receiver-type =  buf_contract.agnt-type then do:
              assign  v-name = buf_contract.agnt-name    v-inn  = buf_contract.agnt-inn   v-kpp  = buf_contract.agnt-kpp .
            end.
          end.
        end.
        if TOG-name then do:
          if tt-fin-doc.receiver-name <> v-name then do:
            run writelog ( v-logfile, 0, "    Изменение наименования получателя. " + tt-fin-doc.receiver-name + " -> " + v-name ) .
            assign is-edit = yes   tt-fin-doc.receiver-name = v-name  .
          end.
        end.
        if TOG-inn then do:
          if tt-fin-doc.receiver-inn <> v-inn then do:
            run writelog ( v-logfile, 0, "    Изменение {&abbr_inn_allshift} получателя. " + tt-fin-doc.receiver-inn + " -> " + v-inn ) .
            assign is-edit = yes   tt-fin-doc.receiver-inn = v-inn .
          end.
        end.
        if TOG-kpp then do:
          if tt-fin-doc.receiver-kpp <> v-kpp then do:
            run writelog ( v-logfile, 0, "    Изменение {&abbr_kpp_allshift} получателя. " + tt-fin-doc.receiver-kpp + " -> " + v-kpp ) .
            assign is-edit = yes   tt-fin-doc.receiver-kpp = v-kpp .
          end.
        end.
      end.
      else do:
        /* получатель мы */
        if TOG-name then do:
          if tt-fin-doc.receiver-name <> buf_contract.own-name then do:
            run writelog ( v-logfile, 0, "    Изменение наименования получателя . " + tt-fin-doc.receiver-name + " -> " + buf_contract.own-name ) .
            assign is-edit = yes  tt-fin-doc.receiver-name = buf_contract.own-name .
          end.
        end.
        if TOG-inn then do:
          if tt-fin-doc.receiver-inn <> buf_contract.own-inn then do:
            run writelog ( v-logfile, 0, "    Изменение {&abbr_inn_allshift} получателя . " + tt-fin-doc.receiver-inn + " -> " + buf_contract.own-inn ) .
            assign is-edit = yes  tt-fin-doc.receiver-inn = buf_contract.own-inn .
          end.
        end.
        if TOG-kpp then do:
          if tt-fin-doc.receiver-kpp <> buf_contract.own-kpp then do:
            run writelog ( v-logfile, 0, "    Изменение {&abbr_kpp_allshift} получателя . " + tt-fin-doc.receiver-kpp + " -> " + buf_contract.own-kpp ) .
            assign is-edit = yes  tt-fin-doc.receiver-kpp = buf_contract.own-kpp .
          end.
        end.
        /* проверяем контрагента */
        if tt-fin-doc.payer-code =  buf_contract.cli-code and tt-fin-doc.payer-type =  buf_contract.cli-type then do:
          assign  v-name = buf_contract.cli-name    v-inn  = buf_contract.cli-inn   v-kpp  = buf_contract.cli-kpp .
        end.
        else do:
          if tt-fin-doc.payer-code =  buf_contract.posr-code and tt-fin-doc.payer-type =  buf_contract.posr-type then do:
            assign  v-name = buf_contract.posr-name    v-inn  = buf_contract.posr-inn   v-kpp  = buf_contract.posr-kpp .
          end.
          else do:
            if tt-fin-doc.payer-code =  buf_contract.agnt-code and tt-fin-doc.payer-type =  buf_contract.agnt-type then do:
              assign  v-name = buf_contract.agnt-name    v-inn  = buf_contract.agnt-inn   v-kpp  = buf_contract.agnt-kpp .
            end.
          end.
        end.
        if TOG-name then do:
          if tt-fin-doc.payer-name <> v-name then do:
            run writelog ( v-logfile, 0, "    Изменение наименования плательщика. " + tt-fin-doc.payer-name + " -> " + v-name ) .
            assign is-edit = yes   tt-fin-doc.payer-name = v-name  .
          end.
        end.
        if TOG-inn then do:
          if tt-fin-doc.payer-inn <> v-inn then do:
            run writelog ( v-logfile, 0, "    Изменение {&abbr_inn_allshift} плательщика. " + tt-fin-doc.payer-inn + " -> " + v-inn ) .
            assign is-edit = yes   tt-fin-doc.payer-inn = v-inn .
          end.
        end.
        if TOG-kpp then do:
          if tt-fin-doc.payer-kpp <> v-kpp then do:
            run writelog ( v-logfile, 0, "    Изменение {&abbr_kpp_allshift} плательщика. " + tt-fin-doc.payer-kpp + " -> " + v-kpp ) .
            assign is-edit = yes   tt-fin-doc.payer-kpp = v-kpp .
          end.
        end.
      end.

      if is-edit = yes then do:
        define variable p-doc-rec as recid no-undo.
        for each fin-doc-tax no-lock where fin-doc-tax.host-code = v-cntxt-host-code-obj and fin-doc-tax.fin-doc-code = buf_fin-doc.fin-doc-code :
          buffer-copy fin-doc-tax to tt-fin-doc-tax .
        end.
        for each fin-doc-attr no-lock where fin-doc-attr.host-code = v-cntxt-host-code-obj and fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code :
          buffer-copy fin-doc-attr to tt-fin-doc-attr .
        end.

        &scop prfx tt-fin-doc.

        assign p-doc-rec = recid (buf_fin-doc) .

        run writelog ( v-logfile, 0, "     " ) .
        tt-fin-doc.doc-author = "fin-ob".
        run ref/findoc0.p (
            input-output p-doc-rec
           ,input {&update}
           ,input yes /*p-silent*/
           {&all-fin-doc-params-doc-status-transfer}
           {&all-fin-doc-params-doc-status-transfer-2}
           ,input table tt-fin-doc-tax
           ,input table tt-fin-doc-attr
           ,input no /*p-save-payment*/
           ,input table tt0-payment
         ) no-error .
       if error-status:error then do:
         run writelog ( v-logfile, 0, substitute( "&1&2&3", return-value, {&new-line}, error-status :get-message (1)) ) .
       end.
      end.
    end.

    /* теперь ФО */
    if TOG-name then do:
      for each buf_fin-ob no-lock  where  buf_fin-ob.host-code = v-cntxt-host-code-obj
/*        and  buf_fin-ob.status_      = {&fin-new} )*/
/*         or (buf_fin-doc.host-code    = v-host-code*/
/*        and  buf_fin-doc.status_      = {&fin-permitted} )*/
        :
        find first buf_contract no-lock where buf_contract.host-code = buf_fin-ob.host-code and buf_contract.contract-code = buf_fin-ob.contract-code no-error .
        if not available buf_contract then next.

        { rep/repfrm.i disp Counter1 }
        run writelog ( v-logfile, 0, string(Counter1,">>>9") + " Проверка фин. обязательства вн. номер " + string(buf_fin-ob.doc-code) + " по договору вн.номер "  + string(buf_fin-ob.contract-code)) .
        assign
          Counter1 = Counter1 + 1
          is-edit  = no
        .
        buffer-copy buf_fin-ob to tt-fin-ob .
        if tt-fin-ob.payer-code =  buf_contract.host-code and tt-fin-ob.payer-type = {&cmp} then do:
          /* плательщик мы  */
          if TOG-name then do:
            if tt-fin-ob.payer-name <> buf_contract.own-name then do:
              run writelog ( v-logfile, 0, "    Изменение наименования плательщика. " + tt-fin-ob.payer-name + " -> " + buf_contract.own-name ) .
              assign is-edit = yes  tt-fin-ob.payer-name = buf_contract.own-name .
            end.
          end.
          /* проверяем контрагента */
          if tt-fin-ob.receiver-code =  buf_contract.cli-code and tt-fin-ob.receiver-type =  buf_contract.cli-type then assign  v-name = buf_contract.cli-name .
          else do:
            if tt-fin-ob.receiver-code =  buf_contract.posr-code and tt-fin-ob.receiver-type =  buf_contract.posr-type then assign  v-name = buf_contract.posr-name .
            else do:
              if tt-fin-ob.receiver-code =  buf_contract.agnt-code and tt-fin-ob.receiver-type =  buf_contract.agnt-type then assign  v-name = buf_contract.agnt-name .
            end.
          end.
          if TOG-name then do:
            if tt-fin-ob.receiver-name <> v-name then do:
              run writelog ( v-logfile, 0, "    Изменение наименования получателя. " + tt-fin-ob.receiver-name + " -> " + v-name ) .
              assign is-edit = yes   tt-fin-ob.receiver-name = v-name  .
            end.
          end.
        end.
        else do:
          /* получатель мы */
          if TOG-name then do:
            if tt-fin-ob.receiver-name <> buf_contract.own-name then do:
              run writelog ( v-logfile, 0, "    Изменение наименования получателя . " + tt-fin-ob.receiver-name + " -> " + buf_contract.own-name ) .
              assign is-edit = yes  tt-fin-ob.receiver-name = buf_contract.own-name .
            end.
          end.
          /* проверяем контрагента */
          if tt-fin-ob.payer-code =  buf_contract.cli-code and tt-fin-ob.payer-type =  buf_contract.cli-type then  assign  v-name = buf_contract.cli-name .
          else do:
            if tt-fin-ob.payer-code =  buf_contract.posr-code and tt-fin-ob.payer-type =  buf_contract.posr-type then  assign  v-name = buf_contract.posr-name .
            else do:
              if tt-fin-ob.payer-code =  buf_contract.agnt-code and tt-fin-ob.payer-type =  buf_contract.agnt-type then  assign  v-name = buf_contract.agnt-name .
            end.
          end.
          if TOG-name then do:
            if tt-fin-ob.payer-name <> v-name then do:
              run writelog ( v-logfile, 0, "    Изменение наименования плательщика. " + tt-fin-ob.payer-name + " -> " + v-name ) .
              assign is-edit = yes   tt-fin-ob.payer-name = v-name  .
            end.
          end.
        end.

        if is-edit = yes then do:
          find first fin-ob exclusive-lock where recid(fin-ob) = recid(buf_fin-ob) .
          assign
            fin-ob.payer-name    = tt-fin-ob.payer-name
            fin-ob.receiver-name = tt-fin-ob.receiver-name
          .
        end.
      end.
    end.

    { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
    define variable s-list as character no-undo .
    run gbl/prnfilen.w ( input  "Результат работы утилиты", input  0, input v-logfile, input  7, output s-list, output is-edit ).
  end.
end procedure. /* proc-OK */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME