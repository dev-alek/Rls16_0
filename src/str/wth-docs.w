&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER X_wth-doc FOR ub.wth-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Документы движения материальных ценностей

Автор: Гридчина Полина Дмитриевна
Дата создания:  09/09/05
Author: Polina Gridchina
Creation date: 09/09/05

Автор1: Бахтадзе Наталья Викторовна

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
/*par-mode бывает
 {&all}
 {&company}
{&g___object}
"doc-type":U
 {&client-cmp}
 "auto":U
 "auto-nfact":U
*/
define input parameter par-mode as character no-undo .
/*кнопки для нажатия*/
define input parameter parhost-code  like ub.sysconf.host-code no-undo.
define input parameter parobj-type   like ub.clients.obj-type no-undo.
define input parameter parobj-code   like ub.clients.obj-code no-undo.
define input parameter parcli-type   like ub.clients.obj-type no-undo.
define input parameter parcli-code   like ub.clients.obj-code no-undo.
define input parameter parext-type   like ub.wth-doc.ext-doc-type no-undo.
define input parameter parstatus     like ub.wth-doc.status_ no-undo.
define input parameter par-type      like ub.wth-doc.doc-type no-undo. /*типы документов в выборке*/
define input-output param p-rid-list    as  char no-undo . /* список recid'ов выбранных payment */

/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Документы движения материальных ценностей":U.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ str/shftnmef.i wth-doc shift-name }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }
{ str/attrlist.i }
{ str/wthcalib.i }


define variable filter-label0 as character no-undo init "Движение матценностей" .
define variable filter-label as character no-undo init "Движение матценностей" .
define variable filter-point as character no-undo init "wth-docs" .
define variable filter-point0 as character no-undo init "wth-docs" .

define variable sort-column-name as character no-undo .
define variable v-rid-list as character no-undo .
define variable vcli-name like ub.clients.obj-name no-undo.
define variable vhost-name like ub.clients.obj-name no-undo.
define variable print-option as character no-undo.
define variable add-option as character no-undo.
define variable glog as logical no-undo .
define variable v-r-b-abbr like ub.currency.curr-abbr no-undo .
define variable v-doc-rec as recid no-undo .
define variable parext-doc-name as character no-undo.

define buffer buf_cli for ub.clients.
define buffer buf_obj for ub.clients .
define new shared buffer wth-doc for ub.wth-doc.

&scop ExtTypeAddNO "{&bef-WDEDT_Inc_Int_Put},{&bef-WDEDT_Ret_Int_Put},{&bef-WDEDT_Ret_Int},~
{&bef-WDEDT_Put_Cash},{&bef-WDEDT_Inc_Int_Free},{&bef-WDEDT_Ret_Int_Free},{&bef-WDEDT_Inc_Obj_Free},{&bef-WDEDT_Inc_Obj_Put},~
{&bef-WDEDT_Inc_Int},{&bef-WDEDT_Ret_Int},{&bef-WDEDT_Cas_Inc},{&bef-WDEDT_Cas_Exp},{&bef-WDEDT_dec}"
&scop ExtTypeChgNO "{&bef-wdedt_cas_inc},{&bef-wdedt_cas_exp},{&bef-WDEDT_Ret_Int},{&bef-WDEDT_Put_Cash},{&bef-WDEDT_Ret_Free}"
&scop ExtTypeRsAuto "{&bef-WDEDT_Inc_Ext},{&bef-WDEDT_Exp_Ext},{&bef-WDEDT_Inc_Obj},{&bef-WDEDT_Exp_Obj},{&bef-WDEDT_Inv},{&bef-WDEDT_Dec}"
&scope ExtType-psnattr "{&bef-WDEDT_Inc_Ext},{&bef-WDEDT_Exp_Ext},{&bef-WDEDT_Put_Cli},{&bef-WDEDT_exch}"
&scope ExtType-sfattr "{&bef-WDEDT_Inc_Ext},{&bef-WDEDT_Exp_Ext},{&bef-WDEDT_Put_Cli}"

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
&Scoped-define INTERNAL-TABLES X_wth-doc

/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs mark-string( recid(X_wth-doc), v-rid-list ) X_wth-doc.doc-type X_wth-doc.status_ X_wth-doc.doc-code X_wth-doc.fact-date X_wth-doc.doc-date /* (substring ((string (X_wth-doc.doc-date)), 1, 5)) */ shift-name-no-err(buffer X_wth-doc) (substring ((string (X_wth-doc.shift-date)), 1, 5)) X_wth-doc.inter_ X_wth-doc.exter_ X_wth-doc.auto-fill X_wth-doc.cli-name X_wth-doc.fact-sum X_wth-doc.doc-sum X_wth-doc.sum-gds-base (trim (X_wth-doc.obj-type) + " " + string (X_wth-doc.obj-code, ">>>>9")) X_wth-doc.source-type + {&space-char} + X_wth-doc.source-ref X_wth-doc.bge-date
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs X_wth-doc.bge-date
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-docs X_wth-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-docs X_wth-doc
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH X_wth-doc NO-LOCK USE-INDEX host-date INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH X_wth-doc NO-LOCK USE-INDEX host-date INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-docs X_wth-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs X_wth-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add b-lkp B-chg B-del ~
B-close B-open B-sch B-print B-hist B-Help rs-auto BR-docs ED-notes ~
sch-code sch-date sch-fact mark-num v_operator v_deliver v_receiver v_creid
&Scoped-Define DISPLAYED-OBJECTS rs-auto ED-notes sch-code sch-date ~
sch-fact mark-num v_operator v_deliver v_receiver v_creid

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-print
       MENU-ITEM m_one          LABEL "Документ"
       MENU-ITEM m_list         LABEL "Список"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-attr
     LABEL "Атрибуты"
     SIZE 10 BY 1.

DEFINE BUTTON b-auto
     LABEL "По чекам"
     SIZE 10 BY 1 TOOLTIP "Добавить документ по чекам МЦ".

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-close
     LABEL "&Закрыть"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-open
     LABEL "&Открыть"
     SIZE 10 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 8 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(14)":U
     LABEL "номеру"
     VIEW-AS FILL-IN
     SIZE 12.5 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999":U
     LABEL "дате"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-fact AS DATE FORMAT "99/99/9999":U
     LABEL "дате факт"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE v_creid AS CHARACTER FORMAT "X(256)":U
     LABEL "Опер"
      VIEW-AS TEXT
     SIZE 14 BY .71
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v_deliver AS CHARACTER FORMAT "X(256)":U
     LABEL "Передал"
      VIEW-AS TEXT
     SIZE 14 BY .71
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v_operator AS CHARACTER FORMAT "X(256)":U
     LABEL "Исп"
      VIEW-AS TEXT
     SIZE 14 BY .71
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v_receiver AS CHARACTER FORMAT "X(256)":U
     LABEL "Получил"
      VIEW-AS TEXT
     SIZE 14 BY .79
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-auto AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"По чекам", 2,
"Созд. вручную", 3
     SIZE 40.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE NEW SHARED QUERY BR-docs FOR
                X_wth-doc SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs NO-LOCK DISPLAY
      mark-string( recid(X_wth-doc), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
X_wth-doc.doc-type COLUMN-LABEL "Т" FORMAT "X(1)":U
X_wth-doc.status_  COLUMN-LABEL "Стат" FORMAT "X(4)":U
X_wth-doc.doc-code  FORMAT "X(12)":U  COLUMN-LABEL "№ документа"
X_wth-doc.fact-date FORMAT "99/99/99":U
X_wth-doc.doc-date  FORMAT "99/99/99":U
/* (substring ((string (X_wth-doc.doc-date)), 1, 5)) COLUMN-LABEL "Дата" FORMAT "X(5)":U */
shift-name-no-err(buffer X_wth-doc) COLUMN-LABEL "№" FORMAT "X(3)":U
(substring ((string (X_wth-doc.shift-date)), 1, 5)) COLUMN-LABEL "Смена" FORMAT "X(5)":U
X_wth-doc.inter_ COLUMN-LABEL "В" FORMAT "+/":U
X_wth-doc.exter_ COLUMN-LABEL "Ш" FORMAT "+/":U
X_wth-doc.auto-fill COLUMN-LABEL "А" FORMAT "+/":U
X_wth-doc.cli-name FORMAT "X(20)":U
X_wth-doc.fact-sum FORMAT "->>,>>>,>>9.99":U COLUMN-LABEL "Кол-во "WIDTH 11
X_wth-doc.sum-gds-rubl COLUMN-LABEL "Сумма (тов)" FORMAT "->>>,>>>,>>9.99":U WIDTH 12
X_wth-doc.doc-sum  COLUMN-LABEL "Кол-во(док)" FORMAT "->>,>>>,>>9.99":U
X_wth-doc.sum-gds-base FORMAT "->>>,>>>,>>9.99":U COLUMN-LABEL "Сумма по тов. (баз. вал.)"
(trim (X_wth-doc.obj-type) + " " + string (X_wth-doc.obj-code, ">>>>9")) COLUMN-LABEL "Объект" FORMAT "X(9)":U
X_wth-doc.source-type + {&space-char} + X_wth-doc.source-ref COLUMN-LABEL "На документ" FORMAT "X(20)":U
X_wth-doc.bge-date COLUMN-LABEL "Внеш.пров." FORMAT "99/99/99":U
ENABLE
X_wth-doc.bge-date
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 14.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1.13
     B-mark AT ROW 1 COL 9
     B-sel AT ROW 1 COL 16
     B-add AT ROW 1 COL 26
     b-lkp AT ROW 1 COL 36
     B-chg AT ROW 1 COL 46
     B-del AT ROW 1 COL 56
     B-close AT ROW 1 COL 66
     B-open AT ROW 1 COL 76
     B-sch AT ROW 1 COL 86
     B-print AT ROW 1 COL 89
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     b-auto AT ROW 2 COL 26 WIDGET-ID 2
     b-attr AT ROW 2 COL 36 WIDGET-ID 10
     rs-auto AT ROW 3.25 COL 1 NO-LABEL WIDGET-ID 4
     BR-docs AT ROW 4.25 COL 1.13
     ED-notes AT ROW 19.75 COL 1 NO-LABEL
     sch-code AT ROW 22 COL 19 COLON-ALIGNED
     sch-date AT ROW 22 COL 46 COLON-ALIGNED
     sch-fact AT ROW 22 COL 77.5 COLON-ALIGNED
     mark-num AT ROW 1 COL 10 COLON-ALIGNED NO-LABEL
     v_operator AT ROW 18.75 COL 5 COLON-ALIGNED
     v_deliver AT ROW 18.75 COL 30 COLON-ALIGNED
     v_receiver AT ROW 18.75 COL 55 COLON-ALIGNED
     v_creid AT ROW 18.75 COL 80 COLON-ALIGNED
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 9.25 BY 1 AT ROW 22 COL 1.5
          FGCOLOR 4
     SPACE(88.54) SKIP(0.19)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Движение материальных ценностей"
         DEFAULT-BUTTON b-lkp.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_wth-doc B "NEW SHARED" ? ub wth-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-docs rs-auto Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-attr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-auto IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docs
/* Query rebuild information for BROWSE BR-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_wth-doc NO-LOCK USE-INDEX host-date INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE NEW SHARED QUERY BR-docs FOR
                X_wth-doc SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-docs */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Движение материальных ценностей */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Движение материальных ценностей */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable v-doc-rec as recid no-undo .
define variable next-prev as character no-undo .
  if lookup(parext-type,{&ExtTypeAddNO}) > 0 or parext-type = '':U then do:
    message 'Добавить документ в данном режиме невозможно' view-as alert-box.
    return no-apply.
  end.
/*   if add-option = '':U then do:                               */
/*     run gbl/pop-up.p ( input self:handle, input no) no-error. */
/*   end.                                                        */
/*   if add-option = '':U then return no-apply. */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_wth-doc_add-def':U
    {&cntxt-object}
    parhost-code
    parobj-type
    parobj-code
    0
    0
    0
    true
    glog
  }

  IF glog <> YES THEN DO:
    add-option = "":U.
    RETURN NO-APPLY.
  END.
  ASSIGN
  v-doc-rec = RECID( X_wth-doc )
  .
    CASE par-type :
    WHEN {&income} OR
    WHEN {&expense} OR
    WHEN {&write-off} OR
    WHEN {&exchange} OR
    when {&declaration} thEN DO:
        run str/wth-inc.w (
                         INPUT parparentproc
                        ,INPUT {&add-def}
                        ,INPUT parhost-code
                        ,INPUT parobj-type
                        ,INPUT parobj-code
                        ,INPUT parcli-type
                        ,INPUT parcli-code
                        ,INPUT parext-type
                        ,INPUT par-type
                        ,INPUT (add-option = "auto":U )
                        ,INPUT-OUTPUT v-doc-rec
                        ,input ? /*this-procedure:handle*/
                        ,input-output next-prev

                        ).
    END.
    WHEN {&inventory} THEN DO:
        run str/wth-inv.w (
                        INPUT parparentproc
                        ,INPUT {&add-def}
                        ,INPUT parhost-code
                        ,INPUT parobj-type
                        ,INPUT parobj-code
                        ,INPUT parcli-type
                        ,INPUT parcli-code
                        ,INPUT parext-type
                        ,INPUT (add-option = "auto":U )
                        ,INPUT-OUTPUT v-doc-rec
                        ,input ? /*this-procedure:handle*/
                        ,input-output next-prev
                      ).
    END.
  END CASE.
  add-option = "":U.
  if v-doc-rec <> ? then do:
    RUN OpenBr in this-procedure ( input yes
                                 , input no
                                 , input '':U).
    reposition br-docs to recid v-doc-rec no-error.
  end.
  APPLY "Value-CHanged" to br-docs.
  APPLY "ENTRY" to br-docs.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-attr Dialog-Frame
ON CHOOSE OF b-attr IN FRAME Dialog-Frame /* Атрибуты */
DO:
  if not avail X_wth-doc then return no-apply.

  run init-attr-general in this-procedure no-error .
  if error-status:error then do:
    message return-value skip
    error-status:get-message(1)
    view-as alert-box.
  end.


  IF not (lookup('b-add':U, bttns) > 0 and (par-mode = 'ext-doc-type':U) and ub.sys-ctrl.db-num = buf_obj.db-num /* and lookup(parext-type,{&ExtTypeAddNO}) = 0 */ ) THEN DO:
    run str/wthdattr.w (input parparentproc,
                        input "b-lkp",
                        input X_wth-doc.doc-code,
                        input table tt-upd-attr) no-error.
  END.
  else if X_wth-doc.STATUS_ = {&fact} then do:
     run str/wthdattr.w (input parparentproc,
                         input "b-lkp,b-chg,b-add,b-del",
                         input X_wth-doc.doc-code,
                         input table tt-upd-attr) no-error.
  end.
  else do:
     run str/wthdattr.w (input parparentproc,
                         input "b-lkp,b-chg,b-add,b-del,no-news",
                         input X_wth-doc.doc-code,
                         input table tt-upd-attr) no-error.
  end.
  if error-status:error then do:
    message return-value skip
    error-status:get-message(1)
    view-as alert-box.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-auto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-auto Dialog-Frame
ON CHOOSE OF b-auto IN FRAME Dialog-Frame /* По чекам */
DO:
  assign
  add-option = 'auto':U.
  APPLY "CHOOSE" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable v-doc-rec as recid no-undo .
define variable next-prev as character no-undo .
 define buffer check_wth-doc for ub.wth-doc .
   if not avail X_wth-doc then return no-apply.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_wth-doc_update':U
    {&cntxt-object}
    parhost-code
    parobj-type
    parobj-code
    0
    0
    0
    true
    glog
  }
  IF glog <> YES THEN DO:
    RETURN NO-APPLY.
  END.
  do on stop undo, return no-apply:
    FIND FIRST check_wth-doc where
              recid(check_wth-doc) = RECID(X_wth-doc) No-ERROR.
    if not avail check_WTH-DOC THEN DO:
        RETURN NO-APPLY.
    END.
    IF CHECK_WTH-DOC.STATUS_ = {&FACT} THEN Do:
        message "Документ движения МЦ с N " check_wth-doc.doc-code  " имеет статус " check_wth-doc.status_ SKIP
                "Изменения не допускаются"
        view-as alert-box error.
        return no-apply.
    end.
    if  check_wth-doc.doc-type = {&return} then do:
        message  substitute("Изменение документов с типом &1 не допускается!",{&return})
        view-as alert-box error.
        return no-apply.
    end.
    if  parobj-type <> check_wth-doc.obj-type
    or parobj-code <> check_wth-doc.obj-code then do:
            message  "Документ может быть изменен только на активной стороне!"
                view-as alert-box ERROR.
                return no-apply.
    end.

    ASSIGN
    v-doc-rec = RECID( X_wth-doc )
    .
    CASE X_wth-doc.doc-type :
      WHEN {&income} OR
      WHEN {&expense} OR
      when {&return}  OR
      WHEN {&exchange} OR
      WHEN {&write-off} THEN DO:
          run str/wth-inc.w (
                          INPUT parparentproc
                          ,INPUT {&update}
                          ,INPUT parhost-code
                          ,INPUT parobj-type
                          ,INPUT parobj-code
                          ,INPUT X_wth-doc.cli-type
                          ,INPUT X_wth-doc.cli-code
                          ,INPUT X_wth-doc.ext-doc-type
                          ,INPUT X_wth-doc.doc-type
                          ,INPUT X_wth-doc.auto-fill
                          ,INPUT-OUTPUT v-doc-rec
                          ,input ? /*this-procedure:handle*/
                          ,INPUT-OUTPUT next-prev
                            ) no-error .
      END.
      WHEN {&inventory} THEN DO:
                run str/wth-inv.w (
                          INPUT parparentproc
                          ,INPUT {&update}
                          ,INPUT parhost-code
                          ,INPUT parobj-type
                          ,INPUT parobj-code
                          ,INPUT X_wth-doc.cli-type
                          ,INPUT X_wth-doc.cli-code
                          ,INPUT X_wth-doc.ext-doc-type
                          ,INPUT X_wth-doc.auto-fill
                          ,INPUT-OUTPUT v-doc-rec
                          ,input ? /*this-procedure:handle*/
                          ,INPUT-OUTPUT next-prev
                        ) no-error .
                        if error-status:error then message return-value.
      END.
    END CASE.
  end.
  ASSIGN glog = br-docs:REFRESH( ).
  reposition br-docs to recid v-doc-rec No-ERROR.
  APPLY "Value-CHanged" to br-docs.
  APPLY "ENTRY" to br-docs.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-close Dialog-Frame
ON CHOOSE OF B-close IN FRAME Dialog-Frame /* Закрыть */
DO:
  if not avail X_wth-doc then return no-apply.
  run proc-b-close in this-procedure  ( input self:name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable glog as logical no-undo .
  define variable v-chip-num as integer no-undo .
  define buffer buf_wth-doc for ub.wth-doc.
  define buffer buf_out_wth-doc for ub.wth-doc.
  define variable v-user-action    as character no-undo.
  define variable v-printed        as logical   no-undo.
  define variable v-proc-name-err    as character    no-undo.
  define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.
  find first buf_wth-doc exclusive-lock where
  recid(buf_wth-doc) = recid(X_wth-doc) NO-ERROR.
  if not avail buf_wth-doc then return no-apply.
  IF buf_wth-doc.status_ <> {&fact}
    and buf_wth-doc.status_ <> {&wayb} THEN DO:
     message
     substitute("Документы перемещения МЦ можно удалять только в статусах &1 и &2"
                , {&wayb}
                , {&fact})
    view-as alert-box error .
    return no-apply.
  end.

  if not (buf_wth-doc.obj-type = parobj-type and
          buf_wth-doc.obj-code = parobj-code)  then do:
      message "Документ можно удалять только на объекте создания!"
      view-as alert-box error.
      return no-apply.
  end.
/*session:Temporary-Directory */
v-proc-name-err = string(session:TEMP-DIRECTORY) + '/delWdoc.err':U .
if search (v-proc-name-err) <> ? then do:
  os-delete value(v-proc-name-err).
end.

  IF buf_wth-doc.status_ = {&fact}
  THEN DO:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_wth-doc_del-fact':U
      {&cntxt-object}
      parhost-code
      parobj-type
      parobj-code
      0
      0
      0
      true
      glog
    }
    IF glog <> YES
    THEN DO:
      RETURN NO-APPLY.
    END.
    if buf_wth-doc.borned = yes then do:
       message
       substitute("Данный документ МЦ &1 порожден другим документом &2&3" +
                  "для удаления связки документов выберите для удаления документ МЦ &2"
                  , buf_wth-doc.doc-code
                  , buf_wth-doc.source-ref
                  , {&new-line}
                  )
       view-as alert-box error .
       RETURN NO-APPLY.
    end.
    if buf_wth-doc.ext-doc-type = {&wdedt_cas_inc}
    or buf_wth-doc.ext-doc-type = {&wdedt_cas_exp} then do:
       message
       substitute("Документы МЦ с типом &1 и типом &2 удаляются при удалении создавшего их отчета о продаже"
                  ,{&wdedt_cas_exp-full}
                  ,{&wdedt_cas_inc-full} )
       view-as alert-box error .
       RETURN NO-APPLY.
    end.
    MESSAGE
    "Документ перемещения МЦ закрыт на факт" skip
    "Вы действительно хотите его удалить?"
    VIEW-AS ALERT-BOX QUESTION buttons YES-NO update glog.
    if not glog then    RETURN NO-APPLY.
       run waitfram-show in this-procedure ( input "Ждите..." ).
       run trg/wthdocdl.p ( input buf_wth-doc.doc-code
                          ,input  ?
                          ,input v-proc-name-err
                          ,output v-chip-num) no-error.
       if error-status:error then do:
        run waitfram-hide in this-procedure .
        message vss-workfile vss-revision vss-description skip
        "Ошибка удаления документа МЦ" skip
        error-status:get-message(1) skip
        return-value skip
        view-as alert-box error title 'Ошибка удаления'.
        if search (v-proc-name-err) <> ? then do:
         run gbl/prnfilen.w
           (input  "Ошибки при закрытии документа"
           ,input  0
           ,input  v-proc-name-err
           ,input  7
           ,output v-user-action
           ,output v-printed
           ).
        end.
        return no-apply.
       end.
  END.
  else if buf_wth-doc.status_ = {&wayb}
  then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_wth-doc_deletion':U
      {&cntxt-object}
      parhost-code
      parobj-type
      parobj-code
      0
      0
      0
      true
      glog
    }
    IF glog <> YES
    THEN DO:
      RETURN NO-APPLY.
    END.
    MESSAGE "Вы уверены, что хотите удалить документ?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
    IF glog <> YES THEN DO:
      RETURN NO-APPLY.
    END.
    if buf_wth-doc.borned = yes then do:
       message
       substitute("Данный документ МЦ &1 порожден другим документом &2&3" +
                  "для удаления связки документов выберите для удаления документ МЦ &2"
                  , buf_wth-doc.doc-code
                  , buf_wth-doc.source-ref
                  , {&new-line}
                  )
       view-as alert-box error .
       RETURN NO-APPLY.
    end.
    for each ub.chk-doc EXCLUSIVE-LOCK WHERE
            ub.chk-doc.out-code = buf_wth-doc.doc-code
            and  lookup(string(ub.chk-doc.chk-type),{&wth-receipt-codes} )  > 0 
    ON ERROR UNDO, return no-apply
    ON STOP UNDO, return no-apply
            :
      FOR each ub.chk-pay exclusive-lock where
            ub.chk-pay.doc-code = ub.chk-doc.doc-code:
        ub.chk-pay.out-code = ?.
      END.
      ub.chk-doc.out-code = ?.
    END.
    for each buf_inkas-pay-wth exclusive-lock where
            buf_inkas-pay-wth.inkas-code = buf_wth-doc.doc-code
    ON ERROR UNDO, return no-apply
    ON STOP UNDO, return no-apply
    :
       delete buf_inkas-pay-wth.
    end.
    DELETE buf_wth-doc no-error.
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      message return-value skip error-status:get-message(1)
      view-as alert-box error.
      return no-apply.
    end.

  end.
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
  reposition br-docs to row 1 No-ERROR.
  APPLY "Value-CHanged" to br-docs.
  APPLY "ENTRY" to br-docs.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
define variable v-rid-list as character no-undo .
  if not available X_wth-doc then return no-apply.
    run str/wthcdocs.w
      (
       input  parparentproc
      ,input  'b-add'
      ,input  'one':U /*p-mode*/
      ,input  X_wth-doc.host-code
      ,input  X_wth-doc.obj-type
      ,input  X_wth-doc.obj-code
      ,input  '':U
      ,input  0
      ,input '':U /*p-doc-type*/
      ,input  X_wth-doc.doc-code
      ,output v-rid-list
      ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable v-doc-rec as recid no-undo .
define variable next-prev as character no-undo .
  IF NOT AVAIL X_wth-doc THEN RETURN NO-apply.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_wth-doc_lookup':U
    {&cntxt-object}
    parhost-code
    parobj-type
    parobj-code
    0
    0
    0
    true
    glog
  }
  IF glog <> YES
  THEN DO:
    RETURN NO-APPLY.
  END.
  ASSIGN
  v-doc-rec = recid(X_wth-doc)
  next-prev = '':U
  .
  DO WHILE next-prev = "":U:
      if NOT available X_wth-doc then do:
        message "Неправильно выбран документ МЦ." view-as alert-box ERROR.
        return no-apply.
      end.
    CASE X_wth-doc.doc-type :
      /*WHEN {&income} OR
      WHEN {&expense} OR
      when {&return}  OR
      WHEN {&exchange} OR
      when {&declaration} or
      WHEN {&write-off} THEN DO:
          run str/wth-inc.w (
                           INPUT parparentproc
                          ,INPUT {&lookup}
                          ,INPUT X_wth-doc.host-code
                          ,INPUT X_wth-doc.obj-type
                          ,INPUT X_wth-doc.obj-code
                          ,INPUT X_wth-doc.cli-type
                          ,INPUT X_wth-doc.cli-code
                          ,INPUT X_wth-doc.ext-doc-type
                          ,INPUT X_wth-doc.doc-type
                          ,INPUT X_wth-doc.auto-fill
                          ,INPUT-OUTPUT v-doc-rec
                          ,input this-procedure:handle
                          ,input-output next-prev
                          ).
      END. */
      WHEN {&inventory} THEN DO:
          run str/wth-inv.w (  INPUT parparentproc
                          ,INPUT {&lookup}
                          ,INPUT X_wth-doc.host-code
                          ,INPUT X_wth-doc.obj-type
                          ,INPUT X_wth-doc.obj-code
                          ,INPUT X_wth-doc.cli-type
                          ,INPUT X_wth-doc.cli-code
                          ,INPUT X_wth-doc.ext-doc-type
                          ,INPUT X_wth-doc.auto-fill
                          ,INPUT-OUTPUT v-doc-rec
                          ,input this-procedure:handle
                          ,input-output next-prev
                          ).
      END.
      otherwise do:
                run str/wth-inc.w (
                           INPUT parparentproc
                          ,INPUT {&lookup}
                          ,INPUT X_wth-doc.host-code
                          ,INPUT X_wth-doc.obj-type
                          ,INPUT X_wth-doc.obj-code
                          ,INPUT X_wth-doc.cli-type
                          ,INPUT X_wth-doc.cli-code
                          ,INPUT X_wth-doc.ext-doc-type
                          ,INPUT X_wth-doc.doc-type
                          ,INPUT X_wth-doc.auto-fill
                          ,INPUT-OUTPUT v-doc-rec
                          ,input this-procedure:handle
                          ,input-output next-prev
                          ).

      end.
    END CASE.
 END.
 RUN OpenBr in this-procedure ( input yes, input no, input '':U).
 reposition br-docs to recid v-doc-rec no-error.
 APPLY "ENTRY":U  TO br-docs IN FRAME {&frame-name}.
 APPLY "VALUE-CHANGED":U TO br-docs IN FRAME {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  if available X_wth-doc then do:
    { gbl/markstrn.i X_wth-doc v-rid-list }
    glog = br-docs:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-docs:select-next-row ().
        apply "iteration-changed" to br-docs in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-docs in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-open
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-open Dialog-Frame
ON CHOOSE OF B-open IN FRAME Dialog-Frame /* Открыть */
DO:
  if not avail X_wth-doc then return no-apply.
  run proc-b-close in this-procedure ( input self:name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
    if not avail X_wth-doc then
    return no-apply.
    if print-option = '':U then do:
        run gbl/pop-up.p ( input self:handle, input no) no-error.
    end.
    if print-option = '':U then return no-apply.
    run proc-b-print in this-procedure (
          input X_wth-doc.doc-code
        , input print-option
    ) no-error.
    if error-status:error then do:
        print-option = '':U.
        return no-apply.
    end.
    APPLY "ENTRY" to br-docs.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
run proc-b-sch in this-procedure no-error.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
      if ( available X_wth-doc ) AND ( v-rid-list = ""  or
        b-mark:sensitive = no ) then
    v-rid-list = string( recid( X_wth-doc ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON ANY-PRINTABLE OF BR-docs IN FRAME Dialog-Frame
DO:
   sch-code:screen-value = sch-code:screen-value + last-event:label.
    apply "entry" to sch-code in frame {&frame-name}.
apply "end" to sch-code in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON DELETE-CHARACTER OF BR-docs IN FRAME Dialog-Frame
DO:
   if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON INSERT-MODE OF BR-docs IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
    else do:
      if b-sel:sensitive in frame {&frame-name} then
      APPLY "CHOOSE" to b-sel.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON RETURN OF BR-docs IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-docs IN FRAME {&frame-name} DO:
  apply "choose" to b-lkp in frame {&frame-name}.
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
    define buffer buf-oper for ub.clients.
    define buffer buf-deliver for ub.clients.
    define buffer buf-receiver for ub.clients.

      if available X_wth-doc then do:
        FIND buf-oper NO-LOCK WHERE
                buf-oper.obj-type = {&prs} AND
                buf-oper.obj-code = X_wth-doc.operator NO-ERROR.
        FIND buf-deliver NO-LOCK WHERE
                buf-deliver.obj-type = {&prs} AND
                buf-deliver.obj-code = X_wth-doc.deliver NO-ERROR.
        FIND buf-receiver NO-LOCK WHERE
                buf-receiver.obj-type = {&prs} AND
                buf-receiver.obj-code = X_wth-doc.receiver NO-ERROR.
        assign
        ed-notes = X_wth-doc.PS
        v_operator = ( IF AVAIL buf-oper THEN buf-oper.obj-name ELSE "":U ).
        v_deliver =  ( IF AVAIL buf-deliver THEN buf-deliver.obj-name ELSE "":U ).
        v_receiver = ( IF AVAIL buf-receiver THEN buf-receiver.obj-name ELSE "":U ).
      /*  v_creid = X_wth-doc.creid  */
        .
        { gbl/usrfulnm.i
        X_wth-doc.user-name
        v_creid }

        if X_wth-doc.status_ = {&fact} then do:
          disable
          b-open
          b-close
          b-chg
          with frame {&frame-name} .
        end.
        else do:
          enable
          b-open  when (lookup('b-add':U, bttns) >0 and ub.sys-ctrl.db-num = buf_obj.db-num)
          b-close when (lookup('b-add':U, bttns) >0 and ub.sys-ctrl.db-num = buf_obj.db-num)
          b-chg when lookup('b-add':U, bttns) > 0 and ub.sys-ctrl.db-num = buf_obj.db-num  and parstatus <> {&fact} and lookup(parext-type,{&ExtTypeChgNO}) = 0
          with frame {&frame-name} .
        end.
        enable
        b-lkp
        b-attr when lookup('b-add':U, bttns) >0 and (par-mode = 'ext-doc-type':U) and ub.sys-ctrl.db-num = buf_obj.db-num and lookup(parext-type,{&ExtTypeAddNO}) = 0
        B-del when lookup('b-add':U, bttns) >0 and ub.sys-ctrl.db-num = buf_obj.db-num  and ( not par-mode = 'ext-doc-type':U or lookup(parext-type,{&ExtTypeAddNO}) = 0)
        with frame {&frame-name} .
    end.

    else do:
        assign
        ed-notes = '':U
        v_operator = '':U
        v_deliver = '':U
        v_receiver = '':U
        v_creid = '':U
        .
        disable
          b-open
          b-close
          b-chg
          b-del
          b-attr
          b-lkp
        with frame {&frame-name} .
    end.
    display
    ed-notes
    v_creid
    v_deliver
    v_operator
    v_receiver
    with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list /* Список */
DO:
 assign
  print-option = 'LIST':U.
  APPLY "CHOOSE" to b-print in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one /* Документ */
DO:
 assign
  print-option = 'ONE':U.
  APPLY "CHOOSE" to b-print  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-auto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-auto Dialog-Frame
ON VALUE-CHANGED OF rs-auto IN FRAME Dialog-Frame
DO:
      RUN OpenBr in this-procedure ( input yes
                                 , input no
                                 , input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-code in this-procedure ( input yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-code in this-procedure ( input no, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON CTRL-J OF sch-date IN FRAME Dialog-Frame /* дате */
DO:
   run proc-find-date in this-procedure ( input yes, input frame {&frame-name} sch-date, "doc-date") no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON RETURN OF sch-date IN FRAME Dialog-Frame /* дате */
DO:
    run proc-find-date in this-procedure ( input no, input frame {&frame-name} sch-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-fact
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-fact Dialog-Frame
ON CTRL-J OF sch-fact IN FRAME Dialog-Frame /* дате факт */
DO:
   run proc-find-date in this-procedure ( input yes, input frame {&frame-name} sch-fact, "fact-date":U) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-fact Dialog-Frame
ON RETURN OF sch-fact IN FRAME Dialog-Frame /* дате факт */
DO:
  run proc-find-date in this-procedure ( input no, input frame {&frame-name} sch-fact, "fact-date":U) no-error.
  if error-status:error then return no-apply.


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

{ gbl/setfltnm.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }

{ gbl/brwrefre.i " v-doc-rec = recid(X_wth-doc).  RUn OpenBR in this-procedure ( input yes, input no, input '':U). ~
              REPOSITION br-docs to recid v-doc-rec No-ERROR. ~
              APPLY 'ENTRY' to br-docs. APPLY 'VALUE-CHANGED' to br-docS. " }

{ gbl/brwrepos.i
  &line-num=5
}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  /*осуществим проверку входных параметров*/
  /*найдем мы в БД объекта* находимся или нет*/
  FIND FIRST ub.sys-ctrl NO-LOCK.
  if avail sys-ctrl then do:
    FIND FIRST ub.db no-LOCK where
              ub.db.db-num = ub.sys-ctrl.db-num NO-ERROR.
    if not avail db then do:
      message "Отсутствует запись о БД (db)"
      view-as alert-box ERROR.
      return error.
    end.
  END.
  FIND FIRST buf_obj No-LOCK WHERE
                  buf_obj.obj-type = parobj-type and
                  buf_obj.obj-code = parobj-code No-ERROR.
  if not avail buf_obj then do:
      message vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова parobj-type и/или parobj-code"
      parobj-type parobj-code
      view-as alert-box ERROR.
      return.
  end.
  CASE par-mode:
    WHEN {&all}        THEN DO:
    END.
    WHEN {&company}    THEN DO:
        FIND FIRST buf_cli No-LOCK WHERE
                        buf_cli.obj-type = {&cmp} and
                        buf_cli.obj-code = parhost-code No-ERROR.
        if not avail buf_cli then do:
            message vss-workfile vss-revision vss-description skip
            view-as alert-box ERROR.
            return.
        end.

        FIND FIRST ub.sysconf No-LOCK WHERE
                          ub.sysconf.host-code = parhost-code No-ERROR.
        if not avail ub.sysconf then do:
            message vss-workfile vss-revision vss-description skip
            view-as alert-box ERROR.
            return.
        end.
        assign vhost-name = buf_cli.obj-name.
    END.
    WHEN {&g___object} then dO:
        FIND FIRST buf_cli No-LOCK WHERE
                        buf_cli.obj-type = parobj-type and
                        buf_cli.obj-code = parobj-code No-ERROR.
        if not avail buf_cli then do:
            message vss-workfile vss-revision vss-description skip
            view-as alert-box ERROR.
            return.
        end.
    end.
    WHEN "doc-type":U    THEN DO:
        FIND FIRST buf_cli No-LOCK WHERE
                        buf_cli.obj-type = {&cmp} and
                        buf_cli.obj-code = parhost-code No-ERROR.
        if not avail buf_cli then do:
            message vss-workfile vss-revision vss-description skip
            "Неверное значение параметров вызова parobj-type и/или parobj-code"
            parobj-type parobj-code
            view-as alert-box ERROR.
            return.
        end.
        if NOT (par-type = {&income} or par-type = {&expense} or par-type = {&inventory} or par-type = {&write-off}) then do:
            message vss-workfile vss-revision vss-description skip
            "Неверное значение параметра вызова par-type" par-type
            view-as alert-box ERROR.
            return.
        end.
    END.
    WHEN "ext-doc-type":U    THEN DO:
        FIND FIRST buf_cli No-LOCK WHERE
                        buf_cli.obj-type = {&cmp} and
                        buf_cli.obj-code = parhost-code No-ERROR.
        if not avail buf_cli then do:
            message vss-workfile vss-revision vss-description skip
            "Неверное значение параметров вызова parobj-type и/или parobj-code"
            parobj-type parobj-code
            view-as alert-box ERROR.
            return.
        end.
        if lookup(parext-type,{&WDEDT_List}) = 0 then do:
            message vss-workfile vss-revision vss-description skip
            "Неверное значение параметра вызова parext-type" parext-type
            view-as alert-box ERROR.
            return.
        end.
    END.
    WHEN {&client-cmp}    THEN DO:
        FIND FIRST buf_cli No-LOCK WHERE
                        buf_cli.obj-type = parobj-type and
                        buf_cli.obj-code = parobj-code No-ERROR.
        if not avail buf_cli then do:
            message vss-workfile vss-revision vss-description skip
            "Неверное значение параметров вызова parobj-type и/или parobj-code"
            parobj-type parobj-code
            view-as alert-box ERROR.
            return.
        end.
        FIND FIRST buf_cli No-LOCK WHERE
                        buf_cli.obj-type = parcli-type and
                        buf_cli.obj-code = parcli-code No-ERROR.
        if not avail buf_cli then do:
            message vss-workfile vss-revision vss-description skip
            "Неверное значение параметров вызова parcli-type и/или parcli-code"
            parcli-type parcli-code
            view-as alert-box ERROR.
            return.
        end.
        assign vcli-name = buf_cli.obj-name.
    END.
    otherwise do:
      if not (par-mode = 'auto':U or par-mode = 'auto-nfact':U )  then do:
        message vss-workfile vss-revision vss-description skip
        "Неверный вызов - par-mode=" par-mode
        view-as alert-box ERROR.
        return.
      end.
    end.
  end CASE.
  { gbl/r-b-abbr.i  buf_obj.host-code v-r-b-abbr }
  v-rid-list = p-rid-list.
  if v-rid-list <> '':U then do:
    v-doc-rec = integer(entry(1, v-rid-list)).
  end.

  RUN MyEnable in this-procedure  .
  { gbl/mv-clmn.i
  &ext-col = 18
  &frame-name = "{&frame-name}"
  &browse-name = "br-docs"
  &start-column = "1"
  &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18'"
  &prev-order-column-condition_1 = " par-mode = {&all} or par-mode = {&company} "
  &prev-order-column_2 = "'1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,17,18,13'"
  &prev-order-column-condition_2 = " par-mode = {&g___object} "
  &prev-order-column_3 = "'1,2,3,4,5,6,7,8,9,11,12,13,14,15,16,17,18,10'"
  &prev-order-column-condition_3 = " par-mode = 'auto' or par-mode = 'auto-nfact' "
  &prev-order-column_4 = "'1,3,4,5,6,7,8,9,10,11,12,4,15,16,17,18,13,2'"
  &prev-order-column-condition_4 = " par-mode = 'doc-type':U "
  &prev-order-column_5 = "'1,2,3,4,5,6,7,8,9,10,11,14,15,16,17,18,13,12'"
  &prev-order-column-condition_5 = " par-mode = {&client-cmp} "
   }
  HIDE mark-num in frame {&frame-name} .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cr-tt-upd-general Dialog-Frame
PROCEDURE cr-tt-upd-general :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do on error undo, return error return-value :
define variable v-other as character   no-undo.

for each tt-upd-attr : delete tt-upd-attr . end.

&scop create-record create tt-upd-attr. ~
 assign~
  tt-upd-attr.code =  ~{&~{&attr-code~}~}  . ~
                                        ~
~{ str/wthatcod.i                   ~
     tt-upd-attr.code           ~
     tt-upd-attr.type-attr      ~
     tt-upd-attr.format-attr    ~
     tt-upd-attr.fillin_width   ~
     tt-upd-attr.fillin_height  ~
     tt-upd-attr.label-attr     ~
     tt-upd-attr.user-can-edit  ~
     tt-upd-attr.output-display ~
     tt-upd-attr.other                    ~
     no-error                   ~
~}                              ~
 if error-status :error then do:    ~
   message "Ошибка при установке атрибутов документа." skip ~
           error-status :get-message(1) skip return-value ~
   view-as alert-box. ~
   return error.   ~
 end.
&scop attr-code wthcattr-reason      /*основание доступно для всех*/
{&create-record}
if lookup(X_wth-doc.ext-doc-type, {&ExtType-sfattr}) > 0
then do:
  &scop attr-code wthcattr-nsf
  {&create-record}
  &scop attr-code wthcattr-dsf
  {&create-record}
  &scop attr-code wthcattr-paydoc
  {&create-record}
  &scop attr-code wthcattr-consignee
  {&create-record}

end.
if lookup(X_wth-doc.ext-doc-type, {&ExtType-psnattr}) > 0
then do:
  &scop attr-code wthcattr-proxy
  {&create-record}
  &scop attr-code wthcattr-receiver
  {&create-record}
end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-attr Dialog-Frame
PROCEDURE create-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define  input parameter p-doc-code   like ub.wth-doc.doc-code    no-undo.
define  input parameter p-attr-code  like ub.wth-doc-attr.attr-code  no-undo.
define  input parameter p-attr-value like ub.wth-doc-attr.attr-value no-undo.
define output parameter p-exist      as   logical                no-undo.

  { str/wthatxst.i
      p-doc-code
      p-attr-code
      p-exist }

  if p-exist = no then do:
    { str/wthatwrt.i
        p-doc-code
        p-attr-code
        p-attr-value
        no-error     }
    if error-status :error then do:
      message error-status :error error-status :get-message( 1 ) '"' + p-attr-code + '"'
      view-as alert-box error.
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
  DISPLAY rs-auto ED-notes sch-code sch-date sch-fact mark-num v_operator
          v_deliver v_receiver v_creid
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add b-lkp B-chg B-del B-close B-open B-sch
         B-print B-hist B-Help rs-auto BR-docs ED-notes sch-code sch-date
         sch-fact mark-num v_operator v_deliver v_receiver v_creid
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-attr-general Dialog-Frame
PROCEDURE init-attr-general :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/* Атрибуты расходного документа */
if available X_wth-doc
then
do on error undo, return error return-value :
run cr-tt-upd-general .
define variable varexist                  as logical   no-undo.

&scop create-record run create-attr in this-procedure (   input X_wth-doc.doc-code ~
                                                        , input ~{&~{&attr-code~}~} ~
                                                        , input  ~{&attr-val~} ~
                                                        , output varexist ) no-error.
if lookup(X_wth-doc.ext-doc-type, {&ExtType-sfattr}) > 0
then do:
  &scop attr-val  ""
  &scop attr-code wthcattr-nsf
  {&create-record}
  &scop attr-val  ""
  &scop attr-code wthcattr-dsf
  {&create-record}
  &scop attr-val  ""
  &scop attr-code wthcattr-paydoc
  {&create-record}
  if X_wth-doc.doc-type <> {&income} then do:   /*грузополучатель задается только для расходных накладных*/
    &scop attr-code wthcattr-consignee
    {&create-record}
  end.

end.
if lookup(X_wth-doc.ext-doc-type, {&ExtType-psnattr}) > 0
then do:
  &scop attr-val  ""
  &scop attr-code wthcattr-proxy
  {&create-record}
  &scop attr-val  ""
  &scop attr-code wthcattr-receiver
  {&create-record}
END.
&scop attr-val  ""
&scop attr-code wthcattr-reason
{&create-record}

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN
  br-docs:NUM-LOCKED-COLUMNS IN FRAME  {&FRAME-NAME}  = 4
  X_wth-doc.bge-date:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES
  b-print:MENU-MOUSE = 1
.
if par-type = {&write-off} then
DISPLAY
ED-notes
sch-code
sch-date
sch-fact
mark-num
v_operator
v_deliver
v_receiver
v_creid
WITH FRAME Dialog-Frame.

ENABLE
b-quit
rs-auto
B-mark when lookup('b-mark':U, bttns) >0
B-sel  when lookup('b-sel':U, bttns) >0
B-add  when lookup('b-add':U, bttns) >0 and (par-mode = 'ext-doc-type':U) and ub.sys-ctrl.db-num = buf_obj.db-num and lookup(parext-type,{&ExtTypeAddNO}) = 0
b-attr /* when lookup('b-add':U, bttns) >0 and (par-mode = 'ext-doc-type':U) and sys-ctrl.db-num = buf_obj.db-num and lookup(parext-type,{&ExtTypeAddNO}) = 0  */
b-auto when lookup('b-add':U, bttns) >0 and (par-mode = 'ext-doc-type':U) and ub.sys-ctrl.db-num = buf_obj.db-num and lookup(parext-type,{&WDEDT_List-Ser}) = 0 and lookup(parext-type,{&ExtTypeAddNO}) = 0
b-lkp
B-chg when lookup('b-add':U, bttns) >0 and ub.sys-ctrl.db-num = buf_obj.db-num  and parstatus <> {&fact} and lookup(parext-type,{&ExtTypeChgNO}) = 0
B-del when lookup('b-add':U, bttns) >0 and ub.sys-ctrl.db-num = buf_obj.db-num  and ( not par-mode = 'ext-doc-type':U or lookup(parext-type,{&ExtTypeAddNO}) = 0)
B-close when (lookup('b-add':U, bttns) >0 and ub.sys-ctrl.db-num = buf_obj.db-num)
B-open  when (lookup('b-add':U, bttns) >0 and ub.sys-ctrl.db-num = buf_obj.db-num)
B-sch
B-print
B-hist
B-Help
BR-docs
ED-notes
sch-code
sch-date
sch-fact
mark-num
v_operator
v_deliver
v_receiver
v_creid
WITH FRAME Dialog-Frame.
if not ( (par-mode = 'ext-doc-type':U and lookup(parext-type,{&ExtTypeRsAuto}) > 0) or
          par-mode = {&g___object} or
          par-mode = 'doc-type':U or
          par-mode = {&company} or
          par-mode = {&all}
       )
then disable rs-auto
with frame {&frame-name}.
VIEW FRAME Dialog-Frame.
rs-auto:screen-value = '1'.
RUN openbr in this-procedure ( input yes, input no, input '':U).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
Purpose:
Parameters:  <none>
Notes:
------------------------------------------------------------------------------*/
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Движение материальных ценностей".
run waitfram-show in this-procedure ( input "Ждите...").
define variable sort-column-phrase as character no-undo .
assign frame {&frame-name} rs-auto.
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

&scop flt-open-query-handle query br-docs:handle
&scop flt-open-dyn_open-query FOR EACH X_wth-doc
&scop flt-open-open-query OPEN QUERY br-docs FOR EACH X_wth-doc
&scop flt-open-find-buffer-name X_wth-doc
&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_wth-doc

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-waitfram yes



define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + par-mode.
CASE par-mode :
WHEN {&all}        THEN DO:
  assign
  frame {&frame-name}:TITLE = title0
  filter-label = substitute("&1", filter-label0)
  .
  { gbl/fltopend.i
    &where-cond = " (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) ) "
    &dyn_where-cond = " substitute(' ( &1 = 1 or ( &1 = 2 and X_wth-doc.auto-fill ) or ( &1 = 3 and not X_wth-doc.auto-fill ) )', rs-auto ) "
    &use-ind    = " USE-INDEX host-date "
    &dyn_use-ind = "' USE-INDEX host-date '"
    &by         = "  "


  }
END.
WHEN {&company}    THEN DO:
  if p-open-query then do:
    ASSIGN
    frame {&frame-name}:TITLE = title0 + " Фирма: " + vhost-name .
  end.
    filter-label = substitute("&1 Одна фирма", filter-label0).
    .
  { gbl/fltopend.i
    &where-cond = " X_wth-doc.host-code = parhost-code and (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )"
    &use-ind    = " USE-INDEX host-date "
    &by         = "  "
    &dyn_where-cond = " substitute(' X_wth-doc.host-code = &1 and ( &2 = 1 or ( &2 = 2 and X_wth-doc.auto-fill ) or ( &2 = 3 and not X_wth-doc.auto-fill ) )' , parhost-code , rs-auto) "
    &dyn_use-ind    = "' USE-INDEX host-date '"
    }
END.
WHEN {&g___object} THEN DO:
  if p-open-query then do:
    ASSIGN
    frame {&frame-name}:TITLE = title0 + " Объект: " + parobj-type + string(parobj-code).
  end.
    filter-label = substitute("&1 Один объект", filter-label0).
    .
  { gbl/fltopend.i
    &where-cond = " ~
      X_wth-doc.host-code = parhost-code AND ~
      X_wth-doc.obj-type  = parobj-type  AND ~
      X_wth-doc.obj-code  = parobj-code  AND ~
      (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )   ~
                  "
    &use-ind    = " USE-INDEX obj-date "
    &by         = "  "
    &dyn_where-cond = " substitute( ' ~
      X_wth-doc.host-code  = &1 AND ~
      X_wth-doc.obj-type   = &5&2&5 AND ~
      X_wth-doc.obj-code   = &3 AND ~
      ( &4 = 1 or ( &4 = 2 and X_wth-doc.auto-fill ) or ( &4 = 3 and not X_wth-doc.auto-fill ) )  ~
      ' ~
      , parhost-code        ~
      , parobj-type         ~
      , parobj-code         ~
      , rs-auto             ~
      , ~{&double-quote~}   ~
      ) ~
      "
    &dyn_use-ind    = "' USE-INDEX obj-date '"

  }
END.
WHEN "doc-type":U    THEN DO:
  if p-open-query then do:  ASSIGN
    frame {&frame-name}:TITLE = title0 + " Объект: " + parobj-type + string(parobj-code) + {&space-char} + par-type.
  end.
    filter-label = substitute("&1 Один тип док-тов", filter-label0).
    .
  { gbl/fltopend.i
    &where-cond = " ~
      X_wth-doc.host-code = parhost-code  AND ~
      X_wth-doc.obj-type  = parobj-type  AND ~
      X_wth-doc.obj-code  = parobj-code  AND ~
      X_wth-doc.doc-type  = par-type AND  ~
      (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) ) ~
                  "
    &use-ind    = " USE-INDEX obj-type "
    &by         = "  "
    &dyn_where-cond = " substitute( ' ~
      X_wth-doc.host-code  = &1 AND ~
      X_wth-doc.obj-type   = &6&2&6 AND ~
      X_wth-doc.obj-code   = &3 AND ~
      X_wth-doc.doc-type   = &6&4&6 AND ~
      ( &5 = 1 or ( &5 = 2 and X_wth-doc.auto-fill ) or ( &5 = 3 and not X_wth-doc.auto-fill ) ) ~
      ' ~
      , parhost-code        ~
      , parobj-type         ~
      , parobj-code         ~
      , par-type            ~
      , rs-auto             ~
      , ~{&double-quote~}   ~
      ) ~
      "
    &dyn_use-ind    = "' USE-INDEX obj-type '"
  }
END.
WHEN {&client-cmp}    THEN DO:
  if p-open-query then do:
    ASSIGN
    frame {&frame-name}:TITLE = title0 + " Объект: " + parobj-type + string(parobj-code) + " Контрагент: " + vcli-name.
  end.
    filter-label = substitute("&1 Один объект, один контрагент", filter-label0).
    .
  { gbl/fltopend.i
    &where-cond = " ~
      X_wth-doc.obj-type  = parobj-type  AND ~
      X_wth-doc.obj-code  = parobj-code  AND ~
                X_wth-doc.cli-type = parcli-type AND ~
                X_wth-doc.cli-code = parcli-code ~
                  "
    &use-ind    = " USE-INDEX iobj "
    &by         = "  "
    &dyn_where-cond = " substitute( ' ~
      X_wth-doc.obj-type = &5&1&5 AND ~
      X_wth-doc.obj-code = &2 AND ~
      X_wth-doc.cli-type = &5&3&5 AND ~
      X_wth-doc.cli-code = &4     ~
      ' ~
      , parobj-type         ~
      , parobj-code         ~
      , parcli-type         ~
      , parcli-code         ~
      , ~{&double-quote~}   ~
      ) ~
      "
    &dyn_use-ind    = "' USE-INDEX iobj '"
  }
END.
WHEN "auto":U THEN DO:
  if p-open-query then do:
    ASSIGN
    frame {&frame-name}:TITLE = title0 + " Объект: " + parobj-type + string(parobj-code) + {&space-char} + "Автоматические документы".
  end.
    filter-label = substitute("&1 Автодокументы", filter-label0).
    .
  { gbl/fltopend.i
    &where-cond = " ~
      X_wth-doc.host-code = parhost-code AND ~
      X_wth-doc.obj-type  = parobj-type  AND ~
      X_wth-doc.obj-code  = parobj-code  AND ~
      X_wth-doc.auto-fill = yes  ~
                  "
    &use-ind    = " use-index auto-date "
    &by         = "  "
    &dyn_where-cond = " substitute( ' ~
      X_wth-doc.host-code = &1  AND ~
      X_wth-doc.obj-type  = &4&2&4  AND ~
      X_wth-doc.obj-code  = &3  AND ~
      X_wth-doc.auto-fill = yes     ~
      ' ~
      , parhost-code        ~
      , parobj-type         ~
      , parobj-code         ~
      , ~{&double-quote~}   ~
      ) ~
      "
    &dyn_use-ind    = "' use-index auto-date '"
  }
END.
WHEN "auto-nfact":U THEN DO:
  if p-open-query then do:
    ASSIGN
    frame {&frame-name}:TITLE = title0 + " Объект: " + parobj-type + string(parobj-code) + {&space-char} + "Незакрытые автоматические документы".
    end.
    filter-label = substitute("&1 Незакрытые автодокументы", filter-label0).
    .
  { gbl/fltopend.i
    &where-cond = " ~
      X_wth-doc.host-code = parhost-code AND ~
      X_wth-doc.obj-type  = parobj-type  AND ~
      X_wth-doc.obj-code  = parobj-code  AND ~
      X_wth-doc.status_  <> {&fact}  AND ~
      X_wth-doc.auto-fill = yes  ~
                  "
    &use-ind    = " use-index auto-date  "
    &by         = "  "
    &dyn_where-cond = " substitute( ' ~
      X_wth-doc.host-code =  &1 AND ~
      X_wth-doc.obj-type  =  &5&2&5 AND ~
      X_wth-doc.obj-code  =  &3 AND ~
      X_wth-doc.status_   <> &5&4&5 AND ~
      X_wth-doc.auto-fill = yes  ~
      ' ~
      , parhost-code        ~
      , parobj-type         ~
      , parobj-code         ~
      , {&fact}             ~
      , ~{&double-quote~}   ~
      ) ~
      "
    &dyn_use-ind    = "' use-index auto-date '"
  }
END.
WHEN "ext-doc-type":U THEN DO:
    parext-doc-name = ENTRY(LOOKUP(parext-type, {&WDEDT_List}), {&WDEDT_List-full}) no-error.
if p-open-query then     ASSIGN frame {&frame-name}:TITLE = title0 + " Объект: " + parobj-type + {&space-char} + string(parobj-code) + {&space-char} + parext-doc-name.
    filter-label = substitute("&1 Один расш. тип док-тов", filter-label0).
  { gbl/fltopend.i
    &where-cond = " ~
      X_wth-doc.host-code = parhost-code  AND ~
      X_wth-doc.obj-type  = parobj-type  AND ~
      X_wth-doc.obj-code  = parobj-code  AND ~
      X_wth-doc.ext-doc-type  = parext-type AND ~
      (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) ) AND  ~
     (if parstatus > '' and parstatus <> {&all} then (if parstatus = {&fact} then X_wth-doc.status_ = {&fact} else X_wth-doc.status_ <> {&fact} ) else true) ~
                  "
    &use-ind    = " USE-INDEX obj-date "
    &by         = "  "
    &dyn_where-cond = " substitute( ' ~
      X_wth-doc.host-code    = &1 AND ~
      X_wth-doc.obj-type     = &7&2&7 AND ~
      X_wth-doc.obj-code     = &3 AND ~
      X_wth-doc.ext-doc-type = &7&4&7 AND ~
      ( &5 = 1 or ( &5 = 2 and X_wth-doc.auto-fill ) or ( &5 = 3 and not X_wth-doc.auto-fill ) ) AND  ~
      ( if &7&6&7 > &7&7 and &7&6&7 <> &7&8&7 ~
        then (if &7&6&7 = &7&9&7 ~
                then X_wth-doc.status_ =  &7&9&7      ~
                else X_wth-doc.status_ <> &7&9&7      ~
             ) ~
        else true ~
      ) ~
      ' ~
      , parhost-code            ~
      , parobj-type             ~
      , parobj-code             ~
      , parext-type             ~
      , rs-auto                 ~
      , parstatus               ~
      , ~{&double-quote~}       ~
      , {&all}                  ~
      , {&fact}                 ~
      ) ~
      "
    &dyn_use-ind    = "' USE-INDEX obj-date '"
  }
END.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-docs to recid v-doc-rec No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-docs in frame {&frame-name}.
APPLY "ENTRY" TO br-docs.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-close Dialog-Frame
PROCEDURE proc-b-close :
/*------------------------------------------------------------------------------
Purpose:
Parameters:  <none>
Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER loc-mode as character no-undo.
define variable r_w-doc-recid AS RECID NO-UNDO.
DEF BUFFER b_wth-doc  FOR ub.wth-doc.
DEF BUFFER buf_wth-obj  FOR ub.wth-obj.
DEF BUFFER buf_wth-line FOR ub.wth-line.
define variable v-proc-name-err as char no-undo.
define variable v-user-action    as character no-undo.
define variable v-printed        as logical   no-undo.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_wth-doc_update':U
  {&cntxt-object}
  parhost-code
  parobj-type
  parobj-code
  0
  0
  0
  true
  glog
}
if not glog
then do:
  return error.
end.
ASSIGN v-doc-rec = RECID( X_wth-doc ).
ASSIGN r_w-doc-recid = v-doc-rec.
FIND FIRST b_wth-doc where
                recid(b_wth-doc) = v-doc-rec No-ERROR.
if not avail b_wth-doc then return error.
ASSIGN glog = NO.
CASE LOC-MODE:
WHEN "B-CLOSE":U THEN DO:
  IF b_wth-doc.status_ = {&fact} THEN DO:
    MESSAGE "Документ уже закрыт на ФАКТ!  " VIEW-AS ALERT-BOX ERROR.
    RETURN error.
  END.
  MESSAGE
    "Вы собираетесь закрыть документ со статуса ~"" + CAPS( b_wth-doc.status_ ) +
    "~" на статус ~"" + CAPS(
    ( IF b_wth-doc.status_ = {&wayb} AND  b_wth-doc.doc-type = {&inventory}
      THEN {&permitted}
      ELSE {&fact} ) ) + "~"." SKIP
    "Учтите, что закрытые документы открывать нельзя!" SKIP( 1 )
    "Вы уверены, что хотите закрыть документ?     "
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF glog <> YES THEN DO:
    RETURN error.
  END.
END.
WHEN "B-OPEN":U THEN DO:
  IF b_wth-doc.status_ = {&wayb} THEN DO:
    MESSAGE "Документ уже открыт!  " VIEW-AS ALERT-BOX ERROR.
    RETURN error.
  END.
  if b_wth-doc.status_ = {&fact} then do:
    message "Нельзя открыть документ, закрытый на факт"
    view-as alert-box error .
    return error.
  end.
  MESSAGE
    "Вы собираетесь открыть документ со статуса ~"" + CAPS( b_wth-doc.status_ ) +
    "~" на статус ~"" + CAPS(
    ( IF b_wth-doc.status_ = {&permitted} THEN {&wayb} ELSE '') ) + "~"." SKIP
    "Вы уверены, что хотите открыть документ?     "
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF glog <> YES THEN DO:
    RETURN error.
  END.

END.
  OTHERWISE RETURN ERROR.
end case.
/*При закрытии документов с серийными МЦ в процедуре закрытия партий осуществляется проверка на корректность указанных номеров.
Критические ошибки возвращают error. */
v-proc-name-err = string(session:TEMP-DIRECTORY) + '/clsWdoc.err':U .
if search (v-proc-name-err) <> ? then do:
  os-delete value(v-proc-name-err).
end.

run str/wth-stts.p (
                 input parparentproc
                ,BUFFER b_wth-doc
                ,INPUT (if loc-mode = "b-close":U then "+":U else "-":U)
                ,INPUT YES
                ,INPUT parobj-type
                ,INPUT PAROBJ-code
                ,input v-proc-name-err ) NO-ERROR.
IF ERROR-STATUS :ERROR THEN DO:
  case loc-mode:
    when "b-close":U then
    MESSAGE "Не удалось закрыть документ!  " VIEW-AS ALERT-BOX ERROR.
    when "b-open":U then
    MESSAGE "Не удалось открыть документ!  " VIEW-AS ALERT-BOX ERROR.
  end CASE.

  if search (v-proc-name-err) <> ? then do:
    run gbl/prnfilen.w
      (input  "Ошибки при закрытии документа"
      ,input  0
      ,input  v-proc-name-err
      ,input  7
      ,output v-user-action
      ,output v-printed
      ).
  end.
  RETURN error.
END.
else if return-value = 'warning':U  and search (v-proc-name-err) <> ? then do:
     message 'Документ закрыт успешно.' skip
             'Просмотрите дополнительную информацию в лог-файле.'
             view-as alert-box warning.
end.
ASSIGN glog = br-docs:REFRESH( ) in frame {&frame-name}.
RUN OpenBr in this-procedure ( input yes, input no, input '':U ).
IF v-doc-rec <> r_w-doc-recid THEN DO:
  ASSIGN v-doc-rec = r_w-doc-recid.
END.
Reposition br-docs to recid v-doc-rec No-ERROR.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
Purpose:
Parameters:  <none>
Notes:
------------------------------------------------------------------------------*/
define input parameter p-doc-code   as character        no-undo.
define input parameter loc-option   as character        no-undo.

if loc-option = '':U then return error.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_wth-doc_print':U
    {&cntxt-object}
    parhost-code
    parobj-type
    parobj-code
    0
    0
    0
    true
    glog
  }
IF glog <> YES
THEN DO:
  RETURN ERROR.
END.

CASE loc-option:
when 'ONE':U
then do:
    run rep/wth-prn.p (
          input parparentproc
        , input p-doc-code
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка печати документа материальных ценностей."
            skip(1)
            skip "Номер документа:" p-doc-code
            skip(1)
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                 trim( error-status :get-message( 2 ) )
                 trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return error.
    end.
end.
when 'LIST':U then do:
    run proc-print-list in this-procedure no-error.
end.
end case.
loc-option = ''.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
Purpose:
Parameters:  <none>
Notes:
------------------------------------------------------------------------------*/
assign
tbl = 'wth-doc'
join-tbl = 'X_wth-doc'
fld = ""
lab = ""
spr = ""
dim = '0'
.

run fltfield-add in this-procedure('doc-code', 'Номер', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', 'Дата', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-type', 'Тип', 'trn-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ext-doc-type', 'Расш. тип', 'wth-ext-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', 'trn-stat',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('inter_', 'Внутр', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('exter_', 'Внеш', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code', 'Контрагент', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-name', 'Имя контраг', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-sum', 'Сумма', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-sum', 'Сумма факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Дата смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('bge-date', 'Дата внеш.пров.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('scf-date', 'Дата сч-факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('source-ref', 'Ссылка на док-т', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('borned', 'Порожден', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('operator', 'Исполнитель', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('deliver', 'Доставил', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver', 'Получил', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', 'Комментарий', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('creid', 'Опер-р', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('credate', 'Дата создания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
  ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
  ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
run gbl/filter.w ( INPUT parparentproc
                  , INPUT (filter-point + {&delim-par} +
                            filter-label + {&delim-par} +
                            string(yes))
                  , INPUT tbl
                  , INPUT join-tbl
                  , INPUT fld
                  , INPUT lab
                  , INPUT spr
                  , INPUT dim ).
RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame
PROCEDURE proc-find-code :
/*------------------------------------------------------------------------------
Purpose:
Parameters:  <none>
Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter pardoc-code like ub.wth-doc.doc-code no-undo.
display
"  /  /":U @ sch-date
"  /  /":U @ sch-fact
with frame {&frame-name}.

assign
pardoc-code = {&double-quote} + pardoc-code + {&double-quote}.
run OpenBr in this-procedure
  (input false /* p-open-query */
  ,input par-next  /* p-find-next  */
  ,input substitute("and X_wth-doc.doc-code   begins &1 "
    , pardoc-code)
  ).
apply "entry":u to sch-code in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-date Dialog-Frame
PROCEDURE proc-find-date :
/*------------------------------------------------------------------------------
Purpose:
Parameters:  <none>
Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter par-date like ub.wth-doc.doc-date no-undo.
define input parameter parwhat-date as character no-undo.

define variable var-datechr as character no-undo.
display
'':U @ sch-code
with frame {&frame-name}.

assign
var-datechr = string(day(par-date)) + {&slash-char} +
              string(month(par-date)) + {&slash-char} +
              string(year(par-date)).

case parwhat-date:
  when "doc-date":U then do:
    display
    "  /  /":U @ sch-fact
    with frame {&frame-name}.
    run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input true  /* p-find-next  */
    ,input substitute("and X_wth-doc.doc-date = &1 "
      , var-datechr)
    ).
    apply "entry":u to sch-date in frame {&frame-name}.
  end.
  when "fact-date":U then do:
    display
    "  /  /":U @ sch-date
    with frame {&frame-name}.
    run OpenBr in this-procedure
      (input false /* p-open-query */
      ,input true  /* p-find-next  */
      ,input substitute("and X_wth-doc.fact-date = &1 "
      , var-datechr)
      ).
    apply "entry":u to sch-fact in frame {&frame-name}.
  end.

END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-list Dialog-Frame
PROCEDURE proc-print-list :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE vardoc-rec as recid no-undo.
DEFINE VARIABLE for-doc-date as character no-undo.
DEFINE VARIABLE for-shift-date as character no-undo.
DEFINE VARIABLE for-obj as character no-undo.
define variable accum-count as integer.
define variable accum-doc-sum as decimal.
define variable accum-fact-sum as decimal.
define variable date_string     as      char    no-undo.
define variable loc-v_operator  as   char    no-undo.
define variable loc-v_deliver as      char    no-undo.
define variable loc-v_receiver as      char    no-undo.
define variable v-shift-name-num as character no-undo.
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
if v-curr-r-b = {&r-b-base} then do:
  assign
  v-header-base-curr = string( "( Б.Вал. - " + caps( v-r-b-abbr ) + " )" )
  .
end.


define variable Line                as      char    no-undo.
define buffer buf-oper for ub.clients.
define buffer buf-deliver for ub.clients.
define buffer buf-receiver for ub.clients.


DEFINE FRAME wth-list
X_wth-doc.doc-type COLUMN-LABEL "Т" FORMAT "X(1)"
X_wth-doc.status_ COLUMN-LABEL "Стат" FORMAT "X(4)"
X_wth-doc.doc-code
for-doc-date  COLUMN-LABEL "Дата" FORMAT "X(5)"
X_wth-doc.fact-date
v-shift-name-num COLUMN-LABEL "N см." FORMAT "X(6)"
for-shift-date  COLUMN-LABEL "Смена" FORMAT "X(5)"
X_wth-doc.inter_ COLUMN-LABEL "В"
X_wth-doc.exter_ COLUMN-LABEL "Ш"
X_wth-doc.cli-name FORMAT "X(26)"
for-obj COLUMN-LABEL "Объект" FORMAT "X(9)"
X_wth-doc.doc-sum COLUMN-LABEL "Сумма по док-ту"
X_wth-doc.fact-sum
X_wth-doc.source-ref COLUMN-LABEL "На документ"
X_wth-doc.bge-date COLUMN-LABEL "Внеш.пров."
loc-v_operator COLUMN-LABEL "Исп" FORMAT "X(8)"
loc-v_deliver  COLUMN-LABEL "Передал" FORMAT "X(8)"
loc-v_receiver  COLUMN-LABEL "Получил" FORMAT "X(8)"
X_wth-doc.creid  COLUMN-LABEL "Опер" FORMAT "X(8)"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)" AT 42
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X({&A4_LS})" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

if b-sch:tooltip in frame {&frame-name} <> '' then do:
    message "В списке не установлен фильтр" SKIP
                  "Печать списка может занять длительное время" SKIP
                  "Продолжать?"
    view-as alert-box QUESTION buttons YES-NO update glog.
    if not glog then return.
end.
Line = fill("-", {&A4_LS}).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X({&A4_LS})" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME wth-list  .
run waitfram-show in this-procedure ( input "Ждите..." ).
vardoc-rec = recid(X_wth-doc).
DO WHILE available X_wth-doc :
  GET prev br-docs.
END.
GET next br-docs.
 DO WHILE available X_wth-doc :
        FIND buf-oper NO-LOCK WHERE
                buf-oper.obj-type = {&prs} AND
                buf-oper.obj-code = X_wth-doc.operator NO-ERROR.
        FIND buf-deliver NO-LOCK WHERE
                buf-deliver.obj-type = {&prs} AND
                buf-deliver.obj-code = X_wth-doc.deliver NO-ERROR.
        FIND buf-receiver NO-LOCK WHERE
                buf-receiver.obj-type = {&prs} AND
                buf-receiver.obj-code = X_wth-doc.receiver NO-ERROR.
        assign
        loc-v_operator = ( IF AVAIL buf-oper THEN buf-oper.obj-name ELSE "":U ).
        loc-v_deliver = ( IF AVAIL buf-deliver THEN buf-deliver.obj-name ELSE "":U ).
        loc-v_receiver = ( IF AVAIL buf-receiver THEN buf-receiver.obj-name ELSE "":U )
        /*loc-v_creid = X_wth-doc.creid*/
        .
  Display STREAM PrnLibStream
    X_wth-doc.doc-type
    X_wth-doc.status_
    X_wth-doc.doc-code
    (substring ((string (X_wth-doc.doc-date)), 1, 5)) @ for-doc-date
    X_wth-doc.fact-date
    shift-name-no-err(buffer X_wth-doc) @ v-shift-name-num
    (substring ((string (X_wth-doc.shift-date)), 1, 5)) @ for-shift-date
    X_wth-doc.inter_
    X_wth-doc.exter_
    X_wth-doc.cli-name
    (trim (X_wth-doc.obj-type) + " " + string (X_wth-doc.obj-code, ">>>>9")) @ for-obj
    X_wth-doc.doc-sum
    X_wth-doc.fact-sum
    X_wth-doc.source-ref
    X_wth-doc.bge-date
    loc-v_operator
     loc-v_deliver
    loc-v_receiver
    X_wth-doc.creid
  with FRAME wth-list .
  DOWN STREAM PrnLibStream 1
  with FRAME wth-list  .
  assign
  accum-count = accum-count + 1
  accum-doc-sum = accum-doc-sum + X_wth-doc.doc-sum
    accum-fact-sum = accum-fact-sum + X_wth-doc.fact-sum
    .
  GET next br-docs.
  END.
  UNDERLINE  STREAM PrnLibStream
    X_wth-doc.doc-type
    X_wth-doc.status_
    X_wth-doc.doc-code
    for-doc-date
    X_wth-doc.fact-date
    v-shift-name-num
    for-shift-date
    X_wth-doc.inter_
    X_wth-doc.exter_
    X_wth-doc.cli-name
    for-obj
    X_wth-doc.doc-sum
    X_wth-doc.fact-sum
    X_wth-doc.source-ref
    X_wth-doc.bge-date
    loc-v_operator
    loc-v_deliver
    loc-v_receiver
    X_wth-doc.creid
  with FRAME wth-list .
  DISPLAY STREAM PrnLibStream
  ("ИТОГО" + {&space-char} + string(accum-count))  @ X_wth-doc.doc-code
 accum-doc-sum @ X_wth-doc.doc-sum
  accum-fact-sum @ X_wth-doc.fact-sum
  with frame wth-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME wth-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-docs to recid vardoc-rec no-error.
APPLY "entry" to br-docs.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .

  if p-recid <> ?
  then do:
    reposition br-docs to recid p-recid no-error.
  end.

  do with frame {&frame-name}:
    apply "entry":u to browse {&browse-name} .
    apply "VALUE-CHANGED":u to browse {&browse-name} .
  end. /* do with frame */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-wth-doc Dialog-Frame
PROCEDURE reposition-wth-doc :
define input  parameter p-direction   as character no-undo .
define output parameter p-wth-doc-recid as recid no-undo .

  /* перемещение на первую, последнюю, предыдущую, следующую */
  case p-direction :
    when "first":U
    then do:
      get first br-docs.
    end.
    when "last":U
    then do:
      get last br-docs.
    end.
    when "prev":U
    then do:
      get prev br-docs.
      if not available X_wth-doc then do:
        message
        "Это первый документ списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-docs.
      if not available X_wth-doc then do:
        message
        "Это последний документ списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
  assign
  p-wth-doc-recid = recid(X_wth-doc)
  .
  run reposition-query in this-procedure
    (input p-wth-doc-recid
    ).



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
