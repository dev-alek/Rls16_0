&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Список смен по кассам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/26/00
Author: Bakhtadze Natalya
Creation date: 07/26/00

*/

/*
имеет семь точек входа
в зависимости от p-list-mode = {&all}
                              {&cash-desk}
                              {&shop} +

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER mode as char no-undo.
define input parameter p-list-mode as character no-undo .
DEFINE INPUT PARAMETER rc as recid no-undo.
DEFINE INPUT PARAMETER sale-date as date no-undo.
DEFINE INPUT PARAMETER shop-code like ub.shop.obj-code no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Список смен по кассам" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/color.i    }
{ gbl/cur-time.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }

define variable filter-label0 as character no-undo init "Кассовые_смены" .
define variable filter-label as character no-undo init "Кассовые_смены" .
define variable filter-point0 as character no-undo init "shftcshs" .
define variable filter-point as character no-undo init "shftcshs" .

define variable sort-column-name as character no-undo .
define variable v-rec as recid no-undo .
define buffer sb-shift-cash for ub.shift-cash.
define variable cashnum like ub.cash-desk.cash-num no-undo.
define variable old-sale-date like ub.shift-cash.sale-date no-undo.
DEFINE VARIABLE l-shift-on AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-shft AS INTEGER NO-UNDO.
DEFINE VARIABLE cas-shft AS logical NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES sb-shift-cash

/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs sb-shift-cash.cash-num sb-shift-cash.obj-code sb-shift-cash.sale-date sb-shift-cash.src-shift-name sb-shift-cash.shift-name sb-shift-cash.shift-num sb-shift-cash.shift-date string(sb-shift-cash.shift-open-time, "HH:MM:SS") sb-shift-cash.status_ sb-shift-cash.opened sb-shift-cash.shift-close-date string(sb-shift-cash.shift-close-time, "HH:MM:SS") sb-shift-cash.closed sb-shift-cash.z-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs sb-shift-cash.sale-date
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-docs sb-shift-cash
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-docs sb-shift-cash
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH sb-shift-cash NO-LOCK
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH sb-shift-cash NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-docs sb-shift-cash
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs sb-shift-cash


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-docs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-chg B-sch B-close B-Help BR-docs

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-close
     LABEL "Закрыть смену"
     SIZE 15 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1.







/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-docs FOR
                sb-shift-cash SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs DISPLAY
      sb-shift-cash.cash-num COLUMN-LABEL "Касса" FORMAT "9999"
      sb-shift-cash.obj-code COLUMN-LABEL "Магазин"
      sb-shift-cash.sale-date
      sb-shift-cash.src-shift-name COLUMN-LABEL "№!(первонач.)"
      sb-shift-cash.shift-name COLUMN-LABEL "№!(окончат.)"
      sb-shift-cash.shift-num COLUMN-LABEL "Пор."
      sb-shift-cash.shift-date COLUMN-LABEL "Дата смены" FORMAT "99/99/9999"
      string(sb-shift-cash.shift-open-time, "HH:MM:SS") COLUMN-LABEL "Время!начала" FORMAT "X(8)"
      sb-shift-cash.status_
      sb-shift-cash.opened FORMAT "X(15)"
      sb-shift-cash.shift-close-date COLUMN-LABEL "Дата закрытия" FORMAT "99/99/9999"
      string(sb-shift-cash.shift-close-time, "HH:MM:SS") COLUMN-LABEL "Время!закрытия" FORMAT "X(8)"
      sb-shift-cash.closed FORMAT "X(15)"
      sb-shift-cash.z-num
      ENABLE
      sb-shift-cash.sale-date
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.5 BY 10.37.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.1
     B-chg AT ROW 1 COL 11
     B-sch AT ROW 1 COL 21
     B-close AT ROW 1 COL 21
     B-Help AT ROW 1 COL 95
     BR-docs AT ROW 3.43 COL 1
     SPACE(0.00) SKIP(0.44)
     /*было SPACE(78.30) SKIP(12.14)*/
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Кассовые смены"
         DEFAULT-BUTTON B-exit.


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
/* BROWSE-TAB BR-docs B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docs
/* Query rebuild information for BROWSE BR-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH sb-shift-cash NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-docs FOR
                sb-shift-cash SCROLLING.
     _END_FREEFORM_DEFINE
     _Query            is OPENED
*/  /* BROWSE BR-docs */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Кассовые смены */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
    IF NOT l-shift-on AND v-shft > 0 THEN DO:
      assign
      sb-shift-cash.sale-date:read-only in browse {&BROWSE-NAME} = NOT
              sb-shift-cash.sale-date:read-only in browse {&BROWSE-NAME} .
      APPLY "ENTRY" to browse {&BROWSE-NAME}.
      IF   sb-shift-cash.sale-date:read-only in browse {&BROWSE-NAME} = FALSE THEN do:

          APPLY "ENTRY" to sb-shift-cash.sale-date in browse {&BROWSE-NAME}.
      end.
      else do:
          .
      end.
  END.
  run proc-b-chg IN THIS-PROCEDURE ( INPUT sb-shift-cash.obj-code
                                  ,INPUT sb-shift-cash.cash-num
                                  ,INPUT sb-shift-cash.shift-date
                                  ,INPUT sb-shift-cash.shift-num
                                  ,INPUT sb-shift-cash.src-shift-name
                                  ,input recid(sb-shift-cash)
                                     ) NO-ERROR.

  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  br-docs:refresh().

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-close Dialog-Frame
ON CHOOSE OF B-close IN FRAME Dialog-Frame /* Закрыть смену */
DO:
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  define variable glog as logical no-undo .
  define variable is-super as logical no-undo .
  DEFINE BUFFER t-shift-cash for ub.shift-cash.
  message
  "Вы действительно хотите закрыть эту смену на кассе?"
  view-as alert-box question buttons YES-NO update glog.
  if not glog then return no-apply.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_shift_super':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    glog
  }
  if glog then do:
    is-super = yes.
  end.
  else do:
    /* обычный пользователь */
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_shift_regular':U
      {&cntxt-object}
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      true
      glog
    }
    if not glog
    then do:
      return no-apply.
    end.
  end.
  FIND FIRST t-shift-cash where recid(t-shift-cash) = recid(sb-shift-cash).
  if t-shift-cash.status_ <> {&sht-closed}  then do:
    run cur-time in this-procedure ( output v-today, output v-time).
    assign
    t-shift-cash.status_ =  {&sht-closed}
    t-shift-cash.closed = {&super}
    t-shift-cash.shift-close-date = v-today
    t-shift-cash.shift-close-time = v-time
    .
  end.
  else do:
    message
    "Эта смена уже закрыта"
    view-as alert-box .
/*    HIDE
    b-close IN FRAME {&FRAME-NAME}.
    return no-apply.*/
  end.
  br-docs:refresh().
/*  HIDE
  b-close
  IN FRAME {&FRAME-NAME}.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
  tbl = 'shift-cash'
  join-tbl = 'sb-shift-cash'
  fld = '':U
  lab = '':U
  spr = '':U
  dim = '0':U
  .
  run fltfield-add in this-procedure('obj-code', 'N магазина', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cash-num', 'N кассы', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sale-date', 'Дата продажи', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('shift-date', 'Дата смены', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('shift-num', 'Пор. смены', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('src-shift-name', 'Первонач. № смены', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('shift-name', 'Оконч. № смены', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('z-num', 'N z-отчета', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('shift-open-time', 'Время начала', 'time',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('shift-close-date', 'Дата закрытия', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('shift-close-time', 'Время закрытия', 'time',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  DO on stop undo, leave:
    run gbl/filter.w ( input parparentproc
                      ,input (filter-point + {&delim-par} + filter-label)
                      ,input tbl
                      ,input join-tbl
                      ,input fld
                      ,input lab
                      ,input spr
                      ,input dim).
    RUN OpenBr  ( input yes, input no, input '':U).
  END .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-docs
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-exit }
{ gbl/hot-key.i b-CLOSE }
{ gbl/brwrepos.i
&browse-name = "br-docs"
&line-num=5
}

{ gbl/brwrefre.i "assign v-rec = recid(sb-shift-cash). run openbr in this-procedure  ( input yes, input no, input '':U). reposition br-docs to recid v-rec no-error. ~
              APPLY 'ENTRY' to br-docs. APPLY 'VALUE-CHANGED' to br-docs. " }




ON ENTRY OF sb-shift-cash.sale-date in browse br-docs DO:
    assign old-sale-date = sb-shift-cash.sale-date.
END.

ON LEAVE OF sb-shift-cash.sale-date in browse br-docs DO:
define variable glog as logical no-undo .
  if old-sale-date <> date(sb-shift-cash.sale-date:screen-value in browse br-docs) then do:
    glog = no.
    message
    "Поменять дату смены на всех невключенных в продажу чеках по этой кассе?"
    view-as alert-box QUESTION buttons Yes-No update glog.
    IF  glog THEN DO:
      run waitfram-show in this-procedure ("Ждите...").
      run proc-b-chg IN THIS-PROCEDURE ( INPUT sb-shift-cash.obj-code
                                        ,INPUT sb-shift-cash.cash-num
                                        ,INPUT date(sb-shift-cash.sale-date:screen-value in browse br-docs)
                                        ,INPUT ?
                                        ,INPUT ?
                                        ,input recid(sb-shift-cash)
                                        ) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN do:
        run waitfram-hide in this-procedure .
        RETURN NO-APPLY.
      end.
      run waitfram-hide in this-procedure .
    END.
  end.
END.

on f6 anywhere do:
 /*
  DEFINE VARIABLE v-value AS CHARACTER no-undo.
  DEFINE VARIABLE v-password AS CHARACTER no-undo.
  DEFINE VARIABLE v-shift-date LIKE ub.shift-cash.shift-date no-undo.
  DEFINE VARIABLE v-shift-num LIKE ub.shift-cash.shift-num no-undo.
  IF NOT AVAILABLE sb-shift-cash THEN RETURN NO-APPLY.
  IF sb-shift-cash.STATUS_ = {&sht-closed} THEN RETURN NO-APPLY.
  RUN curshift IN THIS-PROCEDURE ( INPUT sb-shift-cash.obj-code
                                   ,OUTPUT v-shift-date
                                   ,OUTPUT v-shift-num) NO-ERROR.
  IF ERROR-STATUS:ERROR /*OR
  v-shift-date <> sb-shift-cash.shift-date*/ THEN RETURN NO-APPLY.
  ASSIGN
  v-password = string(sb-shift-cash.cash-num *
                      (if weekday(sb-shift-cash.shift-date) = 1
                      then 7
                      else (weekday(sb-shift-cash.shift-date) - 1))
                      * (if sb-shift-cash.shift-num = ? then 15 else sb-shift-cash.shift-num) * 15).
      run gbl/d-prompt.w
        ( 'title=':u + "ЗАКРЫТЬ СМЕНУ НА КАССЕ" + '\':u
          + 'text1=' + substitute("Пароль (КАССА &1 ДАТА СМЕНЫ &2 ПОР. СМЕНЫ &3)"
                      , sb-shift-cash.cash-num
                      , sb-shift-cash.shift-date
                      , v-shift-num) + '\':u
          + 'format=' + ">>>>>>>>9" + '\':u
          + 'type=' + {&type-int} + '\':u
          + 'fillin_row=2\':u
          + 'fillin_col=4\':u
          + 'fillin_width=30\':u
          + 'fillin_height=1\':u
          + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
          + 'readonly=no\':u
        , input-output v-value
        ).
  if return-value = 'false':u
  then do:
    return no-apply.
  end.
  /*message v-password "v-password" skip v-value "v-value" view-as alert-box .*/
  IF v-value <> v-password THEN DO:
      MESSAGE
     "Неверный пароль!"
     VIEW-AS ALERT-BOX.
     RETURN NO-APPLY.
  END.
  DISPLAY
  b-close
  WITH FRAME {&FRAME-NAME}.
  */
end.



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  IF (p-list-mode = {&cash-desk}
  OR p-list-mode = {&shop} + {&sale}) THEN DO:
    /*найдем параметр - использовать виртуальные смены*/
    { gbl/cas-shft.i {&shop} shop-code  cas-shft }
    if cas-shft then do:
      { gbl/v-shft.i {&shop} shop-code  v-shft }
    end.
    { gbl/objat.i
    {&shop}
    shop-code
    "'shift-on=request'"
    l-shift-on
     }
  END.
  assign
  sb-shift-cash.sale-date:read-only in browse {&BROWSE-NAME} = true.
  run MyENable in this-procedure .
  run OpenBr in this-procedure  ( input yes, input no, input '':U).
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE curshift Dialog-Frame
PROCEDURE curshift :
DEFINE INPUT PARAMETER p-obj-code like ub.cash-desk.obj-code no-undo.
DEFINE output PARAMETER p-shift-date like ub.shift-cash.shift-date no-undo.
DEFINE output PARAMETER p-shift-num like ub.shift-cash.shift-num no-undo.
define variable v-shift-name as character no-undo .
{ gbl/curshift.i {&shop} p-obj-code p-shift-date p-shift-num v-shift-name NO-ERROR }
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
  ENABLE B-exit B-chg B-sch B-close B-Help BR-docs
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-obj-db-num like ub.db.db-num no-undo .
{ gbl/objdbnum.i {&shop} shop-code v-obj-db-num }
ENABLE
B-exit
B-chg when mode = {&update}
B-close when mode = {&update} /*or v-obj-db-num = v-cntxt-db-num)*/ 
B-sch
B-Help

BR-docs
WITH FRAME {&frame-name}.
/*HIDE
b-close in frame {&frame-name}.*/
VIEW FRAME {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ( input "Ждите...").
define variable sort-column-phrase as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-debug-file

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH sb-shift-cash

&scop flt-open-dyn_open-query FOR EACH sb-shift-cash

&scop flt-open-query-handle QUERY br-docs:handle

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-waitfram yes

CASE p-list-mode:
    when {&all} then do:
        ASSIGN
        frame {&frame-name}:TITLE = "ВСЕ СМЕНЫ ПО ВСЕМ КАССАМ "
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when {&shop} + {&sale} then do:
        FIND first ub.shop No-LOCK WHERE ub.shop.obj-code = shop-code No-ERROR.
        ASSIGN
        frame {&frame-name}:TITLE = "СМЕНЫ по магазину N " +
                                            string(shop-code, ">>>>9") +
                                           " за " +
                                           string(sale-date, "99/99/9999")
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1 Один магазин, одна дата", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " sb-shift-cash.obj-type = {&shop} ~
             AND sb-shift-cash.obj-code = shop-code ~
             AND sb-shift-cash.sale-date = sale-date "
            &dyn_where-cond = " substitute('sb-shift-cash.obj-type = &1&2&1 ~
             AND sb-shift-cash.obj-code = &3 ~
             AND sb-shift-cash.sale-date = &4 ', ~{&double-quote~}, {&shop}, shop-code, sale-date)"

            &use-ind = "  "
            &by = " BY sb-shift-cash.shift-date Descending By sb-shift-cash.shift-num descending By sb-shift-cash.cash-num  "
          }

    end.
    when {&cash-desk} then do:
        find first ub.cash-desk WHERE recid(ub.cash-desk) = rc No-LOCK No-ERROR.
        cashnum = ub.cash-desk.cash-num.
        find first ub.shop No-LOCK WHERE ub.shop.obj-code = shop-code No-ERROR.

        ASSIGN
        frame {&frame-name}:TITLE = "СМЕНЫ ПО КАССЕ N " +
                                            string(ub.cash-desk.cash-num, "9999") +
                                            " магазина N " +
                                            string(shop-code, ">>>>9")
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1 Один магазин, одна касса", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = "sb-shift-cash.obj-type = {&shop} ~
             AND sb-shift-cash.obj-code = shop-code ~
             AND sb-shift-cash.cash-num = cashnum "
            &dyn_where-cond = " substitute('sb-shift-cash.obj-type = &1&2&1 ~
             AND sb-shift-cash.obj-code = &3 ~
             AND sb-shift-cash.cash-num = &4 ', ~{&double-quote~}, {&shop}, shop-code, cashnum)"

            &use-ind = "  "
            &by = " BY sb-shift-cash.shift-date Descending By sb-shift-cash.shift-num descending "
          }
    end.
END CASE.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO BR-DOCS IN FRAME {&frame-name}.
APPLY "ENTRY" TO BR-DOCS.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
DEFINE INPUT PARAMETER p-obj-code like ub.cash-desk.obj-code NO-UNDO.
DEFINE INPUT PARAMETER p-cash-num like ub.cash-desk.cash-num NO-UNDO.
DEFINE INPUT PARAMETER p-shift-date like ub.chk-doc.shift-date NO-UNDO.
DEFINE INPUT PARAMETER p-shift-num  like ub.chk-doc.shift-num NO-UNDO.
DEFINE INPUT PARAMETER p-shift-name  AS character NO-UNDO.
define input parameter p-recid as recid no-undo .
define variable glog as logical no-undo .
DEFINE VARIABLE v-shift-date LIKE ub.chk-doc.shift-date NO-UNDO.
DEFINE variable v-shift-num  like ub.chk-doc.shift-num NO-UNDO.
DEFINE VARIABLE v-shift-name  AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-added AS logical NO-UNDO.
DEFINE VARIABLE v-added-num AS INTEGER NO-UNDO.
DEFINE VARIABLE v-added-num-wth AS INTEGER NO-UNDO.
DEFINE VARIABLE v-change-fields AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-temp-char AS CHARACTER NO-UNDO.
define variable v-doc-rec as recid no-undo.
define variable v-field-descr1 as character no-undo .
define variable v-field-descr2 as character no-undo .
define variable v-host-code as integer no-undo .
DEFINE BUFFER buf_chk-doc FOR ub.chk-doc.
define buffer buf_shift-cash for ub.shift-cash.
define buffer uniq_shift-cash for ub.shift-cash.
IF l-shift-on THEN DO:
  /*найдем текущую смену*/
 { gbl/curshift.i {&shop} shop-code v-shift-date v-shift-num v-shift-name no-error}
  if error-status:error or v-shift-num = 0 then do:
    message
    substitute("На объекте кассы &1&2 смена не открыта,&3" +
               "Изменение невозможно"
               ,{&shop}
               ,p-obj-code
               ,{&NEW-LINE})
    view-as alert-box.
    RETURN error.
  end. /*if error-status:error or p-shift-num > 0 then do:*/
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE
    ERROR-STATUS:GET-MESSAGE(1) SKIP
    RETURN-VALUE
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  IF v-shift-date = p-shift-date
  and v-shift-num = p-shift-num
  and v-shift-name = p-shift-name THEN DO:
     MESSAGE
     "Изменения НЕВОЗМОЖНЫ" SKIP
     "Данная смена на кассе УЖЕ СООТВЕТСТВУЕТ смене на объекте"
     VIEW-AS ALERT-BOX ERROR .
     RETURN.
  END.
  IF v-shift-date <> p-shift-date THEN DO:
    ASSIGN
    v-change-fields = v-change-fields + {&comma-char} + "shift-date".
  END.
  if v-shift-num <> p-shift-num THEN DO:
    ASSIGN
    v-change-fields = v-change-fields + {&comma-char} +  "shift-num".
  END.
  if v-shift-name <> p-shift-name THEN DO:
    ASSIGN
    v-change-fields = v-change-fields + {&comma-char} +  "shift-name".
  END.
  assign
  v-field-descr1 = substitute("Дата смены &1, № смены &2, пор. смены &3"
                              ,v-shift-date
                              ,v-shift-num
                              ,v-shift-name).
  assign
  v-field-descr2 = substitute("Дата смены &1, № смены &2, пор. смены &3"
                              ,p-shift-date
                              ,p-shift-num
                              ,p-shift-name).

   MESSAGE
   substitute("ЗАПИСЬ КАССОВОЙ СМЕНЫ БУДЕТ ИМЕТЬ:&1&2" +
              "Все ЧЕКИ и ЧЕКИ МЦ для данной СМЕНЫ НА КАССЕ будут иметь:&1&3"
              ,{&new-line}
              ,(if v-shift-date = p-shift-date
                THEN v-field-descr1
                else v-field-descr2)
              ,v-field-descr1
              )
   VIEW-AS ALERT-BOX
   QUESTION BUTTONS YES-NO
   TITLE "ПЕРЕНОС СМЕНЫ НА КАССЕ на ТЕКУЩУЮ СМЕНУ НА ОБЪЕКТЕ"
   UPDATE glog.
   IF NOT glog THEN RETURN .
   run waitfram-show in this-procedure ( input "Ждите...").
   do TRANSACTION on stop undo, return no-apply on error undo, return no-apply:
     find first buf_shift-cash exclusive-lock where
            recid(buf_shift-cash) = p-recid.
    assign
    buf_shift-cash.shift-date = v-shift-date
    buf_shift-cash.shift-num = v-shift-num
    buf_shift-cash.shift-name = v-shift-name
    glog = no
    .
    { gbl/hostcode.i {&shop} p-obj-code v-host-code }
    _chk-doc:
    for each buf_chk-doc where
          buf_chk-doc.out-code = ?
      and buf_chk-doc.obj-type = {&shop}
      AND buf_chk-doc.obj-code = p-obj-code
      AND buf_chk-doc.pay-desk = p-cash-num
      AND buf_chk-doc.shift-date = p-shift-date
      AND buf_chk-doc.src-shift-name = p-shift-name
    ON ERROR UNDO _chk-doc, NEXT _chk-doc:

      assign
      v-doc-rec = recid(buf_chk-doc)
      v-added = no
      .
       run str/chkshift.p (
                             input parparentproc
                            ,input l-shift-on
                            ,input v-doc-rec
                            ,input v-shift-date
                            ,input v-shift-num
                            ,input v-shift-name
                            ,input v-change-fields
                            ,input NO /*p-can-back-shift*/
                            ,output v-added
                              ) no-error.

      if error-status:error then do:
         next _chk-doc.
      end.
      if v-added then
      assign
      v-added-num = v-added-num + 1
      .
   end. /*for each chk-doc*/
  end. /*DO TRANSACTION*/
  run waitfram-hide in this-procedure .
END.
ELSE do:
  IF v-shft > 0 THEN DO:
    do TRANSACTION on stop undo, return error on error undo, return ERROR:
        for each buf_chk-doc where
                  buf_chk-doc.out-code = ?
              AND buf_chk-doc.obj-type = sb-shift-cash.obj-type
              AND buf_chk-doc.obj-code = sb-shift-cash.obj-code
              AND buf_chk-doc.pay-desk = sb-shift-cash.cash-num
              AND buf_chk-doc.shift-date = sb-shift-cash.sale-date
              AND buf_chk-doc.shift-num = sb-shift-cash.shift-num
        ON ERROR UNDO, RETURN ERROR:
          assign
          buf_chk-doc.shift-date = p-shift-date.
        end.
    end. /*DO TRANSACTION*/
  end.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME