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

Генерация финансовых обязательств и платежей по покупателям

Автор: Чернова Светлана Александровна
Дата создания: 08/17/06
Author: Svetlana Chernova
Creation date: 08/17/06

*/
define input parameter ParParentProc  as widget-handle no-undo.
define input parameter par-host-code  like ub.clients.obj-code no-undo.
define input parameter par-list-trn   as character no-undo .
define input parameter p-mode         as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Генерация финансовых обязательств и платежей".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/operlist.i }
{ cmp/cli-list.i cli-list def "new shared" }
{ rep/gn-extp.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
/*
message par-host-code skip
        par-list-trn  skip
        p-mode        skip
        .
  */
/* Local Variable Definitions ---                                       */
define temp-table tt-trn no-undo like ub.trn-doc.
define temp-table tt-ord no-undo like ub.ord-doc.
define temp-table tt-rcv no-undo like ub.ord-doc-rcv.
define temp-table c-tt-trn no-undo like ub.c-trn-doc.
define variable v-type-trn-doc as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-exec B-help date-end R-trn R-cons ~
R-nalog RADIO-SET-1 res FILL-IN-13
&Scoped-Define DISPLAYED-OBJECTS date-end R-trn R-cons R-nalog RADIO-SET-1 ~
res FILL-IN-10 FILL-IN-11 FILL-IN-12 FILL-IN-14 FILL-IN-13 v-info

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exec
     LABEL "В&ыполнить"
     SIZE 12 BY 1.

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 12 BY 1.

DEFINE BUTTON B-help DEFAULT
     LABEL "Помо&щь"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE res AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 80.38 BY 7.46 NO-UNDO.

DEFINE VARIABLE date-end AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11.38 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-10 AS CHARACTER FORMAT "X(256)":U INITIAL "Обработать документы по :"
      VIEW-AS TEXT
     SIZE 26 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-11 AS CHARACTER FORMAT "X(256)":U INITIAL "Формировать:"
      VIEW-AS TEXT
     SIZE 12.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-12 AS CHARACTER FORMAT "X(256)":U INITIAL "Обсчитывать документы:"
      VIEW-AS TEXT
     SIZE 29.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-13 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата ФО:"
      VIEW-AS TEXT
     SIZE 8.5 BY 1 TOOLTIP "Дата док. для ФО" NO-UNDO.

DEFINE VARIABLE FILL-IN-14 AS CHARACTER FORMAT "X(256)":U INITIAL "Расчет налогов по ставкам:"
      VIEW-AS TEXT
     SIZE 26 BY 1 NO-UNDO.

DEFINE VARIABLE v-info AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 80 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE R-cons AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Совокупно", 1,
"Раздельно", 2
     SIZE 32 BY 1 TOOLTIP "раздельно - по каждой накладной отдельное ФО" NO-UNDO.

DEFINE VARIABLE R-nalog AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Совокупно", 1,
"Раздельно", 2
     SIZE 32 BY 1 TOOLTIP "раздельно - по каждой ставке налога отдельное ФО" NO-UNDO.

DEFINE VARIABLE R-trn AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Предоплата", 1,
"По факту поставки", 2,
"По всем", 3
     SIZE 25.5 BY 3.5 TOOLTIP "Генерация по типу" NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Сегодня", 1,
"Дата по", 2
     SIZE 32 BY 1 TOOLTIP "Дата док. для ФО" NO-UNDO.

DEFINE VARIABLE T-adm AS LOGICAL INITIAL no
     LABEL "Не учитывать флаги генерации"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-exec AT ROW 1 COL 13
     B-help AT ROW 1 COL 69.5
     date-end AT ROW 2.25 COL 26 COLON-ALIGNED NO-LABEL
     T-adm AT ROW 2.25 COL 41
     R-trn AT ROW 3.5 COL 14 NO-LABEL
     R-cons AT ROW 8.96 COL 31 NO-LABEL
     R-nalog AT ROW 9.96 COL 31 NO-LABEL
     RADIO-SET-1 AT ROW 11 COL 31 NO-LABEL
     res AT ROW 13.21 COL 1 NO-LABEL
     FILL-IN-10 AT ROW 2.21 COL 1 NO-LABEL
     FILL-IN-11 AT ROW 3.25 COL 1 NO-LABEL
     FILL-IN-12 AT ROW 8.96 COL 1 NO-LABEL
     FILL-IN-14 AT ROW 9.96 COL 1 NO-LABEL
     FILL-IN-13 AT ROW 11 COL 1 NO-LABEL
     v-info AT ROW 12.21 COL 1 NO-LABEL
     SPACE(0.50) SKIP(7.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Генерация финансовых обязательств по покупателям"
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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-10 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-11 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-12 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-13 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-14 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR TOGGLE-BOX T-adm IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-adm:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN v-info IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ALT-CTRL-A OF FRAME Dialog-Frame /* Генерация финансовых обязательств по покупателям */
ANYWHERE DO:
  if t-adm :visible = false then do:
      view t-adm in frame {&frame-name}.
      t-adm = yes.
      enable t-adm with frame {&frame-name}.
      display t-adm with frame {&frame-name}.
  end.
  else do:
      t-adm = no.
      display t-adm with frame {&frame-name}.
      hide t-adm in frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Генерация финансовых обязательств по покупателям */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exec Dialog-Frame
ON CHOOSE OF b-exec IN FRAME Dialog-Frame /* Выполнить */
DO:
  assign
    date-end R-cons  radio-set-1 r-nalog  t-adm
    no-error.

  define variable v-calc as integer no-undo .
  define buffer buf_trn-doc     for ub.trn-doc.
  define buffer buf_ord-doc     for ub.ord-doc.
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
  define buffer buf_c-trn-doc   for ub.c-trn-doc.
  define buffer buf_contract    for ub.contract.

  for each tt-rcv : delete tt-rcv. end. /* for each */
  for each tt-ord : delete tt-ord. end. /* for each */
  for each tt-trn : delete tt-trn. end. /* for each */
  for each c-tt-trn : delete c-tt-trn. end. /* for each */

define variable v-1 as integer   no-undo .
v-1 = num-entries(par-list-trn) .
  /* По списку накдадных */
  if par-list-trn <> ? then do:
     r-trn = ? .
    repeat v-calc = 1 to v-1 :
          if p-mode = "" then do:
            find first buf_trn-doc no-lock where recid(buf_trn-doc) = integer (entry(v-calc,par-list-trn)) no-error .
            if available buf_trn-doc then do:
              create tt-trn.
              BUFFER-COPY buf_trn-doc to tt-trn.
            end.
          end.
          if p-mode = "del" then do:  /* удаленные */
            find first buf_c-trn-doc no-lock where recid(buf_c-trn-doc) = integer (entry(v-calc,par-list-trn)) no-error .
            if available buf_c-trn-doc then do:
              create c-tt-trn.
              BUFFER-COPY buf_c-trn-doc to c-tt-trn.
            end.
          end.
          if p-mode = "order" then do:  /* заказы */
            find first buf_ord-doc no-lock where recid(buf_ord-doc) = integer(entry(v-calc,par-list-trn)) no-error .
            if available buf_ord-doc then do:
              create tt-ord.
              BUFFER-COPY buf_ord-doc to tt-ord.
            end.
          end.
          if p-mode = "rcv" then do:  /* поставки */
            find first buf_ord-doc-rcv no-lock where recid(buf_ord-doc-rcv) = integer(entry(v-calc,par-list-trn)) no-error .
            if available buf_ord-doc-rcv then do:
              create tt-rcv.
              BUFFER-COPY buf_ord-doc-rcv to tt-rcv.
            end.
          end.

    end.
  end.

  run update-res no-error .
  if error-status :error then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "123"
    view-as alert-box error
  .

/* из списка заказов   */
if p-mode = "order" then do:
  run str/gen-flo.p (
    INPUT parParentProc ,
    input par-host-code ,
    input date-end   ,
    input ?  ,              /* условие оплаты */
    input R-cons     ,    /* типы оплаты    */
    INPUT r-nalog ,
    input table tt-ord ,
    input-output res,
    input radio-set-1,
    INPUT  t-adm ,
    INPUT  {&income}
    ) no-error .
end.

/* Из списка ФО по живым накл*/
if p-mode = "" then do:
  IF r-trn = 3 or r-trn = 0 or r-trn = ?  THEN DO: /* по всем типам */
     /* по накладным  и заказам */
      run str/genbfotr.p (
          input parParentProc ,
          input par-host-code ,
          input date-end   ,
          input r-trn ,              /* условие оплаты */
          input r-cons     ,    /* типы оплаты    */
          input r-nalog ,
          input table tt-trn ,
          input-output res ,
          input radio-set-1,
          input t-adm
          ) no-error .

  run str/gen-flo.p (
    input parParentProc ,
    input par-host-code ,
    input date-end   ,
    input 1  ,              /* условие оплаты */
    input R-cons     ,    /* типы оплаты    */
    input r-nalog ,
    input table tt-ord ,
    input-output res,
    input radio-set-1,
    input t-adm ,
    input {&income}
    ) no-error .

  END.
  IF r-trn = 1 THEN DO:  /* по предоплате */
      run str/genbfotr.p (
          input parParentProc ,
          input par-host-code ,
          input date-end   ,
          input r-trn ,              /* условие оплаты */
          input r-cons     ,    /* типы оплаты    */
          input r-nalog ,
          input table tt-trn ,
          input-output res ,
          input radio-set-1,
          input t-adm
          ) no-error .

      run str/gen-flo.p (
        INPUT parParentProc ,
        input par-host-code ,
        input date-end   ,
        input r-trn         ,              /* условие оплаты */
        input R-cons     ,    /* типы оплаты    */
        INPUT r-nalog ,
        input table tt-ord ,
        input-output res,
        input radio-set-1,
        INPUT  t-adm ,
        INPUT  {&income}
        ) no-error .
  END.
  IF r-trn = 2 THEN DO:
      run str/genbfotr.p (
          INPUT parParentProc ,
          input par-host-code ,
          input date-end   ,
          input r-trn  ,        /* условие оплаты */
          input R-cons     ,    /* типы оплаты    */
          INPUT r-nalog ,
          input table tt-trn ,
          input-output res ,
          input radio-set-1,
          INPUT  t-adm
          ) no-error .
  END.
  if error-status :error then res = res + {&new-line} + error-status :get-message(1) .
end.
display res with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date-end Dialog-Frame
ON ENTRY OF date-end IN FRAME Dialog-Frame
DO:

  RADIO-SET-1:RADIO-BUTTONS = "Сегодня,1," +( INPUT date-end ) + ",2 ".
DISPLAY RADIO-SET-1 WITH FRAME {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date-end Dialog-Frame
ON LEAVE OF date-end IN FRAME Dialog-Frame
DO:
  ASSIGN date-end.
  RADIO-SET-1:RADIO-BUTTONS = "Сегодня,1," + STRING(date-end,"99/99/9999") + ",2 ".
  DISPLAY RADIO-SET-1 WITH FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date-end Dialog-Frame
ON return OF date-end IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-cons
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-cons Dialog-Frame
ON return OF R-cons IN FRAME Dialog-Frame
DO:
     run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-nalog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-nalog Dialog-Frame
ON return OF R-nalog IN FRAME Dialog-Frame
DO:
     run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-trn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-trn Dialog-Frame
ON return OF R-trn IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 Dialog-Frame
ON return OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
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
{ gbl/app_help.i }
{ gbl/ed_date.i date-end}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable v-right-buyer as logical no-undo .
  v-right-buyer = true .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-buyer':U
    {&cntxt-firm}
    par-host-code
    ''
    0
    0
    0
    0
    true
    v-right-buyer
  }
if v-right-buyer = false then return .

  date-end = date(cur-time-date()) .

  v-type-trn-doc  =  "{&bef-TDEDT_Ras_Vnesh},{&bef-TDEDT_Ras_Vnesh_Kass},{&bef-TDEDT_Vozvrat_Vnesh},{&bef-TDEDT_Vozvrat_Vnesh_Kass}".
  if par-list-trn = ? then
     run enable_ui in this-procedure .
  else
     run enable_my in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus date-end .
END.
RUN disable_UI in this-procedure .

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_my Dialog-Frame
PROCEDURE enable_my :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
  v-info = "Выбрано " + string( num-entries( par-list-trn)  ) + " документов " .

  DISPLAY r-nalog  R-cons res FILL-IN-10 FILL-IN-11 FILL-IN-12 FILL-IN-14 v-info
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-exec B-help R-cons res r-nalog
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

  end.  /* do */
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
  DISPLAY date-end R-trn R-cons R-nalog RADIO-SET-1 res FILL-IN-10 FILL-IN-11
          FILL-IN-12 FILL-IN-14 FILL-IN-13 v-info
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-exec B-help date-end R-trn R-cons R-nalog RADIO-SET-1 res
         FILL-IN-13
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE next-focus Dialog-Frame
PROCEDURE next-focus :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

  define input parameter p-widget-handle as handle no-undo .
  define variable l-apply-entry as logical no-undo .

  assign
    l-apply-entry = /* false */  true
  .

  do with frame {&frame-name} :
    if  date-end:handle   = p-widget-handle then do:  if r-trn:sensitive then do:  apply "entry":u to r-trn .   return . end. end.
    if  r-trn:handle  = p-widget-handle then do:              if r-cons:sensitive then do:     apply "entry":u to r-cons .      return . end. end.
    if  r-cons:handle     = p-widget-handle then do:  if r-nalog:sensitive then do:     apply "entry":u to r-nalog .     return . end. end.
    if  r-nalog:handle     = p-widget-handle then do:  if radio-set-1:sensitive then do:     apply "entry":u to radio-set-1 .     return . end. end.
    if  radio-set-1:handle     = p-widget-handle then do:  if b-exec:sensitive then do:     apply "entry":u to b-exec .      return . end. end.
  end. /* do with frame */

 end.  /* do */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-res Dialog-Frame
PROCEDURE update-res :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
 define variable v-count as integer no-undo .
 define variable v-rad as character no-undo .
 assign frame {&frame-name}
  date-end
  R-cons
  r-nalog
  /* r-trn */
   no-error .
if not  error-status :error  then do:
  if r-trn:visible = true then do:
     assign frame {&frame-name} r-trn
     no-error .
  end.
v-rad = radio-label( string(r-trn) , r-trn:radio-buttons) no-error .
 if v-rad = ? then v-rad = "Указан в договоре заказа".
    res =  "" .
    res = "ВЫБРАНО : " + {&new-line} .
    res = res +  substitute("Условие оплаты по договору :   &1 &2" , {&new-line} , v-rad ) .
end.
else message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка присвоения"
  view-as alert-box error
.

for each tt-trn :
   if lookup( tt-trn.ext-doc-type , v-type-trn-doc) = 0 then do:
      res = res + "неверный тип " + func-get-name-from-ext-type(tt-trn.ext-doc-type,no) + " -   накладную " + tt-trn.doc-code + " пропускаем "  + {&new-line} .
   end.
end. /* for each */

    display res with frame {&frame-name} .

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME