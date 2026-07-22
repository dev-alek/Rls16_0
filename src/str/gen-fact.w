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

Генерация счетов-фактур

Автор: Чернова Светлана Александровна
Дата создания: 10/14/05
Author: Svetlana Chernova
Creation date: 10/14/05

*/
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Генерация счетов-фактур".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ gbl/getcntxt.i def }

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter ParParentProc  as widget-handle no-undo.
define input parameter par-host-code  like ub.clients.obj-code no-undo.

/* Local Variable Definitions ---                                       */
define temp-table tt-trn no-undo like ub.trn-doc.
define temp-table c-tt-trn no-undo like ub.c-trn-doc.
define variable v-type-trn-doc as character no-undo .

/* Список объектов фирмы */
define temp-table temp-obj-firm no-undo
  field obj-code      as integer
  field obj-type      as char
index pi is primary unique
obj-code
obj-type
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-exec i-exit B-help is-nakl-pri ~
date-end is-nakl-smena-type is-fin-ob is-fin-doc res is-nakl-add-doc
&Scoped-Define DISPLAYED-OBJECTS is-nakl-pri date-end is-nakl-smena-type ~
is-fin-ob is-fin-doc RADIO-SET-1 res FILL-IN-10 FILL-IN-11 is-nakl-add-doc

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exec
     LABEL "В&ыполнить"
     SIZE 14.5 BY 1.

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1.

DEFINE BUTTON B-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON i-exit
     IMAGE-UP FILE "cmp/i-run.bmp":U
     IMAGE-DOWN FILE "cmp/i-run.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
     LABEL ""
     SIZE 2.5 BY .75.

DEFINE VARIABLE res AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 70.38 BY 9.5 NO-UNDO.

DEFINE VARIABLE date-end AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11.38 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-10 AS CHARACTER FORMAT "X(256)":U INITIAL "Обработать документы по :"
      VIEW-AS TEXT
     SIZE 26.25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-11 AS CHARACTER FORMAT "X(256)":U INITIAL "Генерация по:"
      VIEW-AS TEXT
     SIZE 15.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-13 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата Счета-фактуры:"
      VIEW-AS TEXT
     SIZE 20.5 BY 1 TOOLTIP "Дата док. для ФО"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Сегодня", 1,
"Дата по", 2
     SIZE 23 BY 1.21 TOOLTIP "Дата док. для ФО" NO-UNDO.

DEFINE VARIABLE is-fin-doc AS LOGICAL INITIAL no
     LABEL "Платежам"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.

DEFINE VARIABLE is-fin-ob AS LOGICAL INITIAL no
     LABEL "Финансовым обязательствам"
     VIEW-AS TOGGLE-BOX
     SIZE 28.13 BY .83 NO-UNDO.

DEFINE VARIABLE is-nakl-add-doc AS LOGICAL INITIAL no
     LABEL "Документ ДопРасх"
     VIEW-AS TOGGLE-BOX
     SIZE 37 BY .83 NO-UNDO.

DEFINE VARIABLE is-nakl-pri AS LOGICAL INITIAL no
     LABEL "Приходным накладным"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.

DEFINE VARIABLE is-nakl-smena-type AS LOGICAL INITIAL no
     LABEL "Накладным смены типа приобретения"
     VIEW-AS TOGGLE-BOX
     SIZE 37 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-exec AT ROW 1 COL 11
     i-exit AT ROW 1.13 COL 11.13 WIDGET-ID 2
     B-help AT ROW 1 COL 61.63
     is-nakl-pri AT ROW 3.33 COL 33.38
     date-end AT ROW 3.42 COL 3.5 COLON-ALIGNED NO-LABEL
     is-nakl-smena-type AT ROW 4.08 COL 33.38
     is-fin-ob AT ROW 5.63 COL 33.38
     is-fin-doc AT ROW 6.33 COL 33.38
     RADIO-SET-1 AT ROW 9.75 COL 38 NO-LABEL
     res AT ROW 7.25 COL 1.13 NO-LABEL
     FILL-IN-10 AT ROW 2.29 COL 2 NO-LABEL
     FILL-IN-11 AT ROW 2.29 COL 32.38 NO-LABEL
     FILL-IN-13 AT ROW 7.75 COL 37.5 NO-LABEL
     is-nakl-add-doc AT ROW 4.83 COL 33.38 WIDGET-ID 4
     SPACE(1.25) SKIP(11.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Генерация счетов-фактур"
         CANCEL-BUTTON b-exit.


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
   FRAME-NAME Custom                                                    */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-10 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-11 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-13 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       FILL-IN-13:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR RADIO-SET RADIO-SET-1 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       RADIO-SET-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Генерация счетов-фактур */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exec Dialog-Frame
ON CHOOSE OF b-exec IN FRAME Dialog-Frame /* Выполнить */
DO:
  assign date-end is-nakl-pri is-nakl-smena-type is-fin-ob is-fin-doc  is-nakl-add-doc .

  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_add-doc for ub.add-doc .
  define buffer buf_fin-doc for ub.fin-doc .
  define buffer buf_fin-ob  for ub.fin-ob .
  define variable v-calc as integer no-undo .
  define variable v-fact-order-end     as decimal   no-undo .
  define variable v-list as character no-undo .

  run day-begin-fact-order in this-procedure ( input ( date-end + 1 ),   output v-fact-order-end ). /*Поиск посл fact-order*/

  assign
    res = ""
    v-calc = 0
  .

  define buffer buf_sysconf for ub.sysconf .
  find first buf_sysconf no-lock where buf_sysconf.host-code = v-cntxt-host-code-obj .
  if buf_sysconf.gen-s-f-office then do:
    if v-cntxt-db-num <> 0 then do:
       message  "Генерация счетов-фактур на текущей фирме разрешена только в офисе!" view-as alert-box.
       return no-apply .
    end.
  end.
/*  else do:*/
/*    if v-cntxt-db-num <> buf_clients.db-num then*/
/*      return error substitute( "&1. Ошибка генерации. &2", vss-workfile, "Нельзя генерить счета-фактуры по документам не текущей БД!" ).*/
/*  end.*/


  if is-nakl-pri or is-nakl-smena-type or is-nakl-add-doc then run make-temp-obj-firm.

  if is-nakl-pri then do:
    assign res = res + "Генерация по приходным накладным " + {&new-line} .
    display res  with frame {&frame-name} .

    for each temp-obj-firm :
      find first ub.clients no-lock
        where ub.clients.obj-type = temp-obj-firm.obj-type
          and ub.clients.obj-code = temp-obj-firm.obj-code
      no-error .
      if buf_sysconf.gen-s-f-office = no and v-cntxt-db-num <> ub.clients.db-num then next .

      for each buf_trn-doc no-lock where
        buf_trn-doc.obj-type     = temp-obj-firm.obj-type and
        buf_trn-doc.obj-code     = temp-obj-firm.obj-code and
        buf_trn-doc.status_      = {&fact}                and
        buf_trn-doc.fact-date   <= date-end               and
        buf_trn-doc.host-code    = par-host-code          and
        buf_trn-doc.need-factur  = 1                      and
        buf_trn-doc.cr-factur    = false                  and
        buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
      :
        assign v-calc = v-calc + 1 .
        assign res = res + string(v-calc) + ". накладная " + buf_trn-doc.doc-code + {&new-line} .
        display res  with frame {&frame-name} .
        run str/gen-scf.p ( input parParentProc, input recid (buf_trn-doc), "trn-doc", output v-list) no-error .
        if error-status:error then do:
          assign res = res + "Ошибка создания счета-фактуры по накладной " + buf_trn-doc.doc-code + {&new-line} .
          display res  with frame {&frame-name} .
        end.
        else do:
          assign res = res + v-list .
          display res  with frame {&frame-name} .
        end.
      end. /* trn-doc */
    end. /* по приходу  */
    assign res = res + "Всего обработано " + string(v-calc) + " накладных" + {&new-line} .
    display res  with frame {&frame-name} .
  end.
  assign v-calc = 0 .
  if is-nakl-add-doc then do:
    assign res = res + "Генерация по документам ДопРасх " + {&new-line} .
    display res  with frame {&frame-name} .

    for each temp-obj-firm :
      find first ub.clients no-lock
        where ub.clients.obj-type = temp-obj-firm.obj-type
          and ub.clients.obj-code = temp-obj-firm.obj-code
      no-error .
      if buf_sysconf.gen-s-f-office = no and v-cntxt-db-num <> ub.clients.db-num then next .
      for each buf_add-doc no-lock where
        buf_add-doc.obj-type     = temp-obj-firm.obj-type and
        buf_add-doc.obj-code     = temp-obj-firm.obj-code and
        buf_add-doc.status_      = {&fact}                and
        buf_add-doc.fact-date   <= date-end               and
        buf_add-doc.host-code    = par-host-code          and
        buf_add-doc.need-factur  = 1                      and
        buf_add-doc.cr-factur    = false
      :
        assign v-calc = v-calc + 1 .
        assign res = res + string(v-calc) + ". ДопРасх " + buf_add-doc.doc-code + {&new-line} .
        display res  with frame {&frame-name} .
        run str/gen-scf.p ( input parParentProc, input recid (buf_add-doc), "add-doc", output v-list) no-error .
        if error-status:error then do:
          assign res = res + "Ошибка создания счета-фактуры по ДопРасх " + buf_add-doc.doc-code + " " + return-value + {&new-line} .
          display res  with frame {&frame-name} .
        end.
        else do:
          assign res = res + v-list .
          display res  with frame {&frame-name} .
        end.
      end.
    end.
    assign res = res + "Всего обработано " + string(v-calc) + " ДопРасх." + {&new-line} .
    display res  with frame {&frame-name} .
  end.

  assign v-calc = 0 .
  if is-nakl-smena-type then do:
    assign res = res + "Генерация по накладным смены типа приобретения" + {&new-line} .
    display res  with frame {&frame-name} .

    for each temp-obj-firm :
      find first ub.clients no-lock
        where ub.clients.obj-type = temp-obj-firm.obj-type
          and ub.clients.obj-code = temp-obj-firm.obj-code
      no-error .
      if buf_sysconf.gen-s-f-office = no and v-cntxt-db-num <> ub.clients.db-num then next .

      for each buf_trn-doc no-lock where
        buf_trn-doc.obj-type     = temp-obj-firm.obj-type and
        buf_trn-doc.obj-code     = temp-obj-firm.obj-code and
        buf_trn-doc.status_      = {&fact}                and
        buf_trn-doc.fact-date   <= date-end               and
        buf_trn-doc.host-code    = par-host-code          and
        buf_trn-doc.need-factur  = 1                      and
        buf_trn-doc.cr-factur    = false                  and
        buf_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code}
      :
        assign v-calc = v-calc + 1 .
        assign res = res + string(v-calc) + ". накладная " + buf_trn-doc.doc-code + {&new-line} .
        display res  with frame {&frame-name} .
        run str/gen-scf.p ( input parParentProc, input recid (buf_trn-doc), "trn-doc", output v-list) no-error .
        if error-status:error then do:
          assign res = res + "Ошибка создания счета-фактуры по накладной " + buf_trn-doc.doc-code + " " + return-value +  {&new-line} .
          display res  with frame {&frame-name} .
        end.
        else do:
          assign res = res + v-list .
          display res  with frame {&frame-name} .
        end.
      end. /* trn-doc */
    end.
    assign res = res + "Всего обработано " + string(v-calc) + " накладных" + {&new-line} .
    display res  with frame {&frame-name} .
  end.

  assign v-calc = 0 .
  if is-fin-ob and v-cntxt-db-num = 0 then do:
    assign res = res + "Генерация по фин. обязательствам" + {&new-line} .
    display res  with frame {&frame-name} .

    for each buf_fin-ob no-lock where
        buf_fin-ob.host-code    = par-host-code          and
        buf_fin-ob.status_      = {&fact}                and
        buf_fin-ob.fact-order   < v-fact-order-end       and
        buf_fin-ob.need-factur  = 1                      and
        buf_fin-ob.cr-factur    = false
    :
      assign v-calc = v-calc + 1 .
      assign res = res + string(v-calc) + ".  фин. обязательство " + string(buf_fin-ob.doc-code) + {&new-line} .
      display res  with frame {&frame-name} .
      run str/gen-scf.p ( input parParentProc, input recid (buf_fin-ob), "fin-ob", output v-list) no-error .
      if error-status:error then do:
        assign res = res + "Ошибка создания счета-фактуры по фин. обязательству " + string(buf_fin-ob.doc-code) + " " + return-value +  {&new-line} .
        display res  with frame {&frame-name} .
      end.
      else do:
        assign res = res + v-list .
        display res  with frame {&frame-name} .
      end.
    end.
    assign res = res + "Всего обработано " + string(v-calc) + " фин. обязательств" + {&new-line} .
    display res  with frame {&frame-name} .
  end.

  if is-fin-doc and v-cntxt-db-num = 0  then do:
    assign res = res + "Генерация по платежам" + {&new-line} .
    display res  with frame {&frame-name} .

    for each buf_fin-doc no-lock where
        buf_fin-doc.host-code    = par-host-code          and
        buf_fin-doc.status_      = {&fin-fact}            and
        buf_fin-doc.fact-order   < v-fact-order-end       and
        buf_fin-doc.need-factur  = 1                      and
        buf_fin-doc.cr-factur    = false
    :
      assign v-calc = v-calc + 1 .
      assign res = res + string(v-calc) + ". Платеж " + string(buf_fin-doc.fin-doc-code) + {&new-line} .
      display res  with frame {&frame-name} .
      run str/gen-scf.p ( input parParentProc, input recid (buf_fin-doc), "fin-doc", output v-list) no-error .
      if error-status:error then do:
        assign res = res + "Ошибка создания счета-фактуры по фин. платежу " + string(buf_fin-doc.fin-doc-code)  + " " + return-value + {&new-line} .
        display res  with frame {&frame-name} .
      end.
      else do:
        assign res = res + v-list .
        display res  with frame {&frame-name} .
      end.
    end.
    assign res = res + "Всего обработано " + string(v-calc) + " платежей" + {&new-line} .
    display res  with frame {&frame-name} .
  end.
  assign res = res + "Генерация завершена " + string(today,"99/99/9999") + " за период " + string(date-end,"99/99/9999") + {&new-line} .
  display res  with frame {&frame-name} .
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
{ gbl/ed_date.i date-end}
{ gbl/getcntxt.i get }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  date-end = date(cur-time-date()) .

  RUN enable_UI.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus date-end .
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
  DISPLAY is-nakl-pri date-end is-nakl-smena-type is-fin-ob is-fin-doc
          RADIO-SET-1 res FILL-IN-10 FILL-IN-11 is-nakl-add-doc
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-exec i-exit B-help is-nakl-pri date-end is-nakl-smena-type
         is-fin-ob is-fin-doc res is-nakl-add-doc
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-temp-obj-firm Dialog-Frame
PROCEDURE make-temp-obj-firm :
do on error undo, return error return-value :
    define buffer buf_shop for ub.shop .
    define buffer buf_store for ub.store .

    for each temp-obj-firm : delete temp-obj-firm. end.

    for each buf_shop no-lock where buf_shop.host-code = par-host-code  on error undo, return error :
      create temp-obj-firm.
      assign
        temp-obj-firm.obj-code = buf_shop.obj-code
        temp-obj-firm.obj-type = {&shop}
      .
    end.
    for each buf_store no-lock where buf_store.host-code = par-host-code  on error undo, return error :
      create temp-obj-firm.
      assign
        temp-obj-firm.obj-code = buf_store.obj-code
        temp-obj-firm.obj-type = {&stock}
      .
    end.
  end. /* do */
end procedure. /* make-temp-obj-firm */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME