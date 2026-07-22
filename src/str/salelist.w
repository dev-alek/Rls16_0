&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_host FOR ub.clients.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER ink-doc FOR ub.inkas.
DEFINE BUFFER X_trn-doc FOR ub.trn-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/23/05
Author: Bakhtadze Natalya
Creation date: 10/23/05


Author: Черных В.
Created: 23/06/98

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
{g___new}
"doc-type":U
 object-all
*/
define input parameter par-mode as character no-undo .
/*кнопки для нажатия*/
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
/*типы документов в выборке*/
define input-output param p-rid-list    as  char no-undo . /* список recid'ов выбранных inkas */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список продаж".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i new }
{ gbl/flt-def.i }
{ cmp/breakstr.i }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
/*нужно для закрытия продажи через saleclos.p*/
{ str/lib-def.i }
{ str/trdcalib.i }
{ str/dtlrestm.i "NEW SHARED" }
{ str/tpsidoc.i "NEW SHARED" proc }
{ gbl/prn-lib.i }
{ str/shftnmef.i ink-doc shift-name }
{ gbl/getcntxt.i def }
{ gbl/thbj-def.i }
{ cmp/mrk-strf.i }

{ gbl/fltopend.i defproc }

define variable filter-label as character no-undo init "Продажи " .
define variable filter-label0 as character no-undo init "Продажи " .
define variable filter-point0 as character no-undo init "salelist" .
define variable filter-point as character no-undo init "salelist".
define variable sort-column-name as character no-undo .
DEFINE VARIABLE varhost-code like ub.sysconf.host-code no-undo .
DEFINE VARIABLE varhost-name like ub.clients.obj-name no-undo .
define variable cas-shft as logical no-undo init no.
define variable print-type as char init "" no-undo.
define variable ptwounit as logical no-undo init yes .
define variable export-option as character no-undo.
define variable v-doc-rec as recid no-undo .
DEFINE NEW SHARED VARIABLE br-handle as handle no-undo.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-curr-r-b AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-is-fbr-obj AS LOGICAL NO-UNDO INIT ?.
DEFINE VARIABLE v-is-tpsi-obj AS LOGICAL NO-UNDO INIT ?.
DEFINE VARIABLE hist-option as character no-undo.
define variable next-prev  as character no-undo .
define variable add-option as character no-undo .
define variable tpsi-mode as integer no-undo .
define variable l-shift-on as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-vid-action      as integer   no-undo .
define variable v-vid-param       as longchar  no-undo .
define variable varobj-shift-date as date      no-undo.
define variable varobj-shift-num  as integer   no-undo.
define variable varobj-shift-name as character no-undo.
define variable v-mess            as character no-undo.
define buffer bf_clients for ub.clients.
define buffer buf_trn-doc for ub.trn-doc.
{ str/initiator.i }

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
&Scoped-define INTERNAL-TABLES ink-doc

/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs mark-string( recid(ink-doc), v-rid-list ) ink-doc.inkas-code ink-doc.doc-date ink-doc.fact-date ink-doc.shift-date shift-name-no-err(BUFFER ink-doc) ink-doc.netto ink-doc.tot-doc ink-doc.discnt ink-doc.sub-discnt ink-doc.qnty (ink-doc.discnt / ink-doc.tot-doc * 100) ink-doc.num-chk ink-doc.num-chk-nf ink-doc.status_ ink-doc.flag_ ink-doc.is-auto-born ink-doc.is-auto-get ink-doc.is-auto-rsrv ink-doc.is-auto-close ink-doc.auto-comp ink-doc.AUTO-fbr ink-doc.rest-dish ink-doc.rest-ingr ink-doc.auto-tpsi ink-doc.rest-tpsi
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs
&Scoped-define SELF-NAME BR-docs
&Scoped-define OPEN-QUERY-BR-docs /* OPEN QUERY {&SELF-NAME} FOR EACH ink-doc NO-LOCK INDEXED-REPOSITION. */ RUN reopen-query IN THIS-PROCEDURE.
&Scoped-define TABLES-IN-QUERY-BR-docs ink-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs ink-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-export B-chk B-print ~
B-sch B-hist B-Help B-add b-lkp B-chg B-del B-close B-Open BR-docs ED-notes ~
sch-code sch-date sch-fact mark-num qnty shop-name num-chk
&Scoped-Define DISPLAYED-OBJECTS ED-notes sch-code sch-date sch-fact ~
mark-num qnty shop-name num-chk

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU m-print
       MENU-ITEM m-list         LABEL "Список продаж"
       MENU-ITEM m-one          LABEL "Продажа"       .

DEFINE MENU MENU-B-add
       MENU-ITEM m_sale         LABEL "Продажа"
       MENU-ITEM m_inquiry      LABEL "Продажа-запрос".

DEFINE MENU MENU-B-export
       MENU-ITEM m_gen-3        LABEL "Проводки (внеш.)".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добав."
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Измен."
     SIZE 10 BY 1.

DEFINE BUTTON B-chk
     LABEL "Ч&еки"
     SIZE 10 BY 1.

DEFINE BUTTON B-close
     LABEL "&Закрыть"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-export
     LABEL "Генерац&."
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

DEFINE BUTTON B-Open
     LABEL "&Открыть"
     SIZE 10 BY 1.

DEFINE BUTTON B-print
     LABEL "Выполнить/Пе&чать"
     SIZE 20 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.75
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE num-chk AS INTEGER FORMAT "->>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 16.13 BY .67 NO-UNDO.

DEFINE VARIABLE qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
      VIEW-AS TEXT
     SIZE 16.13 BY .67 NO-UNDO.

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

DEFINE VARIABLE shop-name AS CHARACTER FORMAT "X(25)":U
      VIEW-AS TEXT
     SIZE 27 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-docs FOR ink-doc SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs NO-LOCK DISPLAY
      mark-string( recid(ink-doc), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
      ink-doc.inkas-code FORMAT "X(14)":U
      ink-doc.doc-date FORMAT "99/99/9999":U
      ink-doc.fact-date FORMAT "99/99/9999":U
      ink-doc.shift-date COLUMN-LABEL "Дата смены!(учета)" FORMAT "99/99/9999":U
      shift-name-no-err(BUFFER ink-doc) COLUMN-LABEL "N см." FORMAT "X(6)":U
      ink-doc.netto COLUMN-LABEL "Нетто" FORMAT "->>>,>>>,>>>,>>9.99":U
      ink-doc.tot-doc COLUMN-LABEL "Сумма товарная" FORMAT "->>>,>>>,>>>,>>9.99":U
      ink-doc.discnt FORMAT "->,>>>,>>>,>>9.99":U
      ink-doc.sub-discnt COLUMN-LABEL "Списания" FORMAT "->>>,>>>,>>9.99":U
      ink-doc.qnty COLUMN-LABEL "Кол-во товаров" FORMAT "->>,>>>,>>9.<<<":U
      (ink-doc.discnt / ink-doc.tot-doc * 100) COLUMN-LABEL "%" FORMAT "->>>>>9.9":U
      ink-doc.num-chk FORMAT ">>>,>>9":U COLUMN-LABEL "Чеков"
      ink-doc.num-chk-nf FORMAT ">>>,>>9":U COLUMN-LABEL "Чеков!нд"
      ink-doc.status_ FORMAT "X(8)":U
      ink-doc.flag_ COLUMN-LABEL "ОК" FORMAT "+/":U
      ink-doc.is-auto-born COLUMN-LABEL "Авто!созд" FORMAT "+/":U
      ink-doc.is-auto-get COLUMN-LABEL "Авто!чеки" FORMAT "+/":U
      ink-doc.is-auto-rsrv COLUMN-LABEL "Авто!резерв" FORMAT "+/":U
      ink-doc.is-auto-close COLUMN-LABEL "Авто!закр" FORMAT "+/":U
      ink-doc.auto-comp COLUMN-LABEL "Ком!пенс" FORMAT "+/":U
      ink-doc.AUTO-fbr  COLUMN-LABEL "Авто!пр-во" FORMAT "+/":U
      ink-doc.rest-dish COLUMN-LABEL "Ост-ки!блюд" FORMAT "+/":U
      ink-doc.rest-ingr COLUMN-LABEL "Ост-ки!ингр" FORMAT "+/":U
      ink-doc.auto-tpsi COLUMN-LABEL "ТПСИ" FORMAT "+/":U
      ink-doc.rest-tpsi COLUMN-LABEL "Ост-ки!ТПСИ" FORMAT "+/":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.63 BY 15.42.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-export AT ROW 1 COL 31
     B-chk AT ROW 1 COL 41
     B-print AT ROW 1 COL 51
     B-sch AT ROW 1 COL 89
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-add AT ROW 2 COL 21
     b-lkp AT ROW 2 COL 31
     B-chg AT ROW 2 COL 41
     B-del AT ROW 2 COL 51
     B-close AT ROW 2 COL 61
     B-Open AT ROW 2 COL 71
     BR-docs AT ROW 3 COL 1
     ED-notes AT ROW 18.58 COL 1 NO-LABEL
     sch-code AT ROW 22.58 COL 17.63 COLON-ALIGNED
     sch-date AT ROW 22.58 COL 40.75 COLON-ALIGNED
     sch-fact AT ROW 22.58 COL 65.63 COLON-ALIGNED
     mark-num AT ROW 1 COL 14 NO-LABEL
     qnty AT ROW 21.5 COL 52.63 COLON-ALIGNED NO-LABEL
     shop-name AT ROW 21.5 COL 69.88 COLON-ALIGNED NO-LABEL
     num-chk AT ROW 21.58 COL 15.63 COLON-ALIGNED NO-LABEL
     "количество товара" VIEW-AS TEXT
          SIZE 19.5 BY .88 AT ROW 21.46 COL 34.5
     "число чеков" VIEW-AS TEXT
          SIZE 16 BY .88 AT ROW 21.46 COL 1.38
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 9.25 BY 1 AT ROW 22.58 COL 1.5
          FGCOLOR 4
     SPACE(88.25) SKIP(0.02)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Продажи"
         DEFAULT-BUTTON b-lkp CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_host B "?" ? ub clients
      TABLE: buf_obj B "?" ? ub clients
      TABLE: ink-doc B "?" ? ub inkas
      TABLE: X_trn-doc B "?" ? ub trn-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-docs B-Open Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.

ASSIGN
       B-export:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-export:HANDLE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-print:HANDLE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docs
/* Query rebuild information for BROWSE BR-docs
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH ink-doc NO-LOCK INDEXED-REPOSITION. */
RUN reopen-query IN THIS-PROCEDURE.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-docs FOR ink-doc SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-docs */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* Продажи */
OR ENDKEY OF FRAME {&frame-name} DO:
  run gbl/markqwa.p (
                input b-mark:sensitive
               ,input v-rid-list
                ) no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Продажи */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Продажи */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добав. */
or Right-Mouse-CLICK OF b-add IN FRAME {&frame-name}
DO:
 IF tpsi-mode = 2
 and add-option = '':U THEN DO:
     run gbl/pop-up.p ( INPUT SELF:HANDLE, INPUT NO) NO-ERROR.
     IF add-option = '':U THEN RETURN NO-APPLY.
  END.
  run proc-b-add IN THIS-PROCEDURE ( INPUT (if tpsi-mode = 2 then add-option else {&cash-desk})) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Измен. */
DO:
  define variable v-inkas-code as character no-undo .
  IF NOT AVAILABLE ink-doc THEN RETURN NO-APPLY.
  assign
  v-doc-rec = recid(ink-doc).
  v-inkas-code = ink-doc.inkas-code.
  run str/cre-sale.p ( INPUT parparentproc
                      ,INPUT parobj-type
                      ,INPUT parobj-code
                      ,INPUT {&update}
                      ,input '':U /*p-silent*/
                      ,input '':U /*p-shift-date*/
                      ,INPUT-output v-inkas-code
                      ,INPUT '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    message
    substitute("Ошибка при редактировании продажи:&1&2 &3", {&new-line}, error-status:get-message(1) , return-value )
    view-as alert-box ERROR .
    return no-apply.
  end.
RUn openbr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
reposition br-docs to recid v-doc-rec no-error.
APPLY "VALUE-CHANGED" to BR-docs.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chk Dialog-Frame
ON CHOOSE OF B-chk IN FRAME Dialog-Frame /* Чеки */
DO:
DEFINE VARIABLE rid-list as character no-undo .
define variable loc#log as logical no-undo.
def buffer t-clients for ub.clients.
if available ink-doc THEN  do:
    { str/snd-chkp.i ink-doc.obj-code ink-doc.obj-type t-clients ub.db.db-num db  loc#log YES}
    if NOT loc#log then return no-apply.
    run str/chk-docs.w (
                     input parparentproc
                    ,input '':U
                    ,input {&sale}
                    ,input ?
                    ,input ink-doc.obj-type
                    ,input ink-doc.obj-code
                    ,input ink-doc.inkas-code
                    ,input '':U
                    ,input 0 /*p-pay-desk*/
                    ,input  ?
                    ,input  ?
                    ,input 0
                    ,output rid-list) no-error.
end.
apply "entry" to br-docs.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-close Dialog-Frame
ON CHOOSE OF B-close IN FRAME Dialog-Frame /* Закрыть */
DO:
 IF NOT AVAILABLE ink-doc THEN RETURN NO-APPLY.
 define variable v-close-type as integer no-undo .
 define variable v-status_ like ub.inkas.status_ no-undo .
 define variable v-flag_ like ub.trn-doc.flag_ no-undo .
 define variable v-ask-message as character no-undo .
 define buffer buf_trn-doc for ub.trn-doc.

 find first buf_trn-doc where
           buf_trn-doc.doc-code = ink-doc.inkas-code.
 run str/salegraf.p (
                input ink-doc.inkas-code
               ,input {&close-doc}
               ,input buf_trn-doc.status_
               ,input buf_trn-doc.flag_
               ,output v-status_
               ,output v-flag_
               ,output v-ask-message) no-error .
  if error-status:error then do:
    message
    error-status:get-message(1)  skip
    return-value
    view-as alert-box error .
    return no-apply.
  end.
  run gbl/d-askw.w
    (input "Вопрос"
    ,input substitute("Закрыть ОТЧЕТ О ПРОДАЖЕ &1&2" +
                      "Дата учета &3&2" +
                      "Ожидаемая факт дата &4"
                     , ink-doc.inkas-code
                     , {&NEW-LINE}
                     , string(ink-doc.shift-date, '99/99/9999':u)
                     , string(ink-doc.fact-date, '99/99/9999':u)
                     )
    ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                /* второй символ - разделитель атрибутов в описании кнопок */
    ,input (if v-status_ = {&fact}
            then ("Факт" + '|':u + "Отмена" )
            else (v-status_ + string(v-flag_, "+/") + '|':u
          + "Факт" + '|':u
          + "Отмена" )
            )
    ,input (if v-status_ = {&fact}
            then ("Окончательное закрытие без последующего редактирования|"
                  + "Отмена действия")
            else (
                 v-ask-message + "|" /* список описаний кнопок */
                  + "Окончательное закрытие без последующего редактирования|"
                  + "Отмена действия")
           )
    ,input 1 /* значение возвращаемое при нажатии enter */
    ,input (if v-status_ = {&fact}
            then 2
            else 3)
             /* значение возвращаемое при нажатии escape */
    ,output v-close-type /* выбор пользователя */
    ).

 if (v-status_ = {&fact}
 and v-close-type = 2)
 or v-close-type = 3 then do:
   return no-apply.
 end.
 run proc-close IN THIS-PROCEDURE ( input yes, input (if v-status_ = {&fact} then 2 else v-close-type), input v-status_, input v-flag_) NO-ERROR.
 IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
or Right-Mouse-CLICK OF b-del IN FRAME {&frame-name}
DO:
  define variable v-ok as logical   no-undo .
  define variable v-parameter as character no-undo .
  define variable ri as recid no-undo .
  define variable v-normal-call as logical no-undo .
  define variable v-inkas-code as character no-undo .
  
  if not available ink-doc then return no-apply.
  if par-mode = {&g___new} then .
  else do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_sale_del-sale-fact':U
      {&cntxt-object}
      ink-doc.host-code
      ink-doc.obj-type
      ink-doc.obj-code
      0
      0
      0
      true
      v-ok
    }
    if not v-ok then return no-apply .
  end .
  
  assign
    v-inkas-code  = ink-doc.inkas-code
    v-normal-call = can-do("CHOOSE,ENTER":U, last-event:label)
    v-ok = false
  .
  message
  "Удалить продажу №" v-inkas-code skip(0)
  (if par-mode = {&g___NEW} and not v-normal-call then "С одновременным форсированным снятием резервов" else '':U) skip(0)
  "Продолжить?" skip(0)
  view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true then do:
    return no-apply .
  end.
  ri = recid(ink-doc).
  IF par-mode = {&g___new} THEN DO:
    assign
    v-parameter = string(1)                 + {&delim-par} + /*p-auto*/
                  ink-doc.obj-type          + {&delim-par} +
                  string(ink-doc.obj-code)  + {&delim-par} +
                  string(not v-normal-call) + {&delim-par} +  /*forced*/
                  v-inkas-code.
    run str/diallog.w (
          input parParentProc
        , input this-procedure
        , input ("str/del-sale.p":U + {&delim-par} +
                "1":U  + {&delim-par} +  /*error-message-option*/
                "1":U + {&delim-par} +  /*auto-go-option*/
                "1":U)                  /*return-value-option*/
        , input v-parameter
        , input no /*p-auto-go*/
        , input "":U
        , input substitute("Удаление продажи &1 &2&3", Ink-doc.inkas-code, ink-doc.obj-type, ink-doc.obj-code)
    ) no-error.
    if error-status:error
    and return-value <> "error"
    and return-value <> ""
    then do:
      message
      substitute("&1 &2"
                , error-status:get-message(1)
                , return-value )
      view-as alert-box error .
      return no-apply .
    end.
    if return-value = "error":U then do:
      return no-apply .
    end.
    else do:
      run Openbr in this-procedure ( input yes, input no, input '':U).
      reposition br-docs to recid ri no-error.
    end.
  END.
  ELSE DO:
    v-parameter = ink-doc.inkas-code.
      
      
      find first buf_trn-doc no-lock where
        buf_trn-doc.doc-code = ink-doc.inkas-code no-error.
      
      if available (buf_trn-doc)
      then do:
        find first bf_clients no-lock where bf_clients.obj-type = {&prs} and  bf_clients.obj-code = buf_trn-doc.boss no-error.
        { gbl/curshift.i
        inkas.obj-type
        inkas.obj-code
        varobj-shift-date
        varobj-shift-num
        varobj-shift-name
        no-error
        }
        
        v-vid-param = "Initiator=" + "User" + {&delim-par} +
                      "ResponsiblePerson=" + (if available (bf_clients) then bf_clients.obj-name else "") + {&delim-par} +
                      "SHOP_NUM=" + string(ink-doc.obj-code) + {&delim-par} +
                      "Contractor=" + buf_trn-doc.cli-name + {&delim-par} +
                      "DocNum=" + string(ink-doc.inkas-code) + {&delim-par} +
                      "FactDate=" + (if string(ink-doc.fact-date) = ? then '' else string(ink-doc.fact-date)) + {&delim-par} +
                      "DocType=" + "Продажа" + {&delim-par} +
                      "SHIFT_NUM_DOC=" + (if string(ink-doc.shift-num) = ? then '' else string(ink-doc.shift-num)) + (if string(ink-doc.shift-date) = ? then '' else string(ink-doc.shift-date, "99999999")) + {&delim-par} +
                      "SHIFT_NUM=" + (if string(varobj-shift-num) = ? then '' else string(varobj-shift-num)) + (if string(varobj-shift-date) = ? then '' else string(varobj-shift-date, "99999999")) + {&delim-par} +
                      "Status=" + string(ink-doc.status_) no-error.
    end.
    
    run str/diallog.w (
          input parParentProc
        , input this-procedure
        , input ("str/delfsale.p":U + {&delim-par} +
                "1":U  + {&delim-par} +  /*error-message-option*/
                "1":U + {&delim-par} +  /*auto-go-option*/
                "1":U)                  /*return-value-option*/
        , input v-parameter
        , input no /*p-auto-go*/
        , input "":U
        , input substitute("Удаление продажи &1 &2&3, закрытой до статуса факт", Ink-doc.inkas-code, ink-doc.obj-type, ink-doc.obj-code)
    ) no-error.
    if error-status:error
    and return-value <> "error"
    and return-value <> ""
    then do:
      
      v-mess = substitute("&1 &2"
                , error-status:get-message(1)
                , return-value ).
      if v-vid-param <> "" or v-vid-param <> ? 
      then do:
        
        
        v-vid-param = v-vid-param + {&delim-par}+ "RESULT=" + string( 1 ) + {&delim-par} + "Description=" + v-mess.
      
        v-vid-action = 59 .
        run trg/userlog.p (
              input {&nwsdochs_action_delete_err}
            , input {&table_inkas}
            , input ( buffer ink-doc:handle )
            , input v-vid-action
            , input v-vid-param
        ) no-error.
      
      end.
      message
        v-mess
      view-as alert-box error .
      return no-apply .
    end.
    if return-value = "error":U then do:
      
      v-mess = substitute("&1 &2"
                , error-status:get-message(1)
                , return-value ).
      if v-vid-param <> "" or v-vid-param <> ? 
      then do:
        
        
        v-vid-param = v-vid-param + {&delim-par}+ "RESULT=" + string( 1 ) + {&delim-par} + "Description=" + v-mess.
      
        v-vid-action = 59 .
        run trg/userlog.p (
              input {&nwsdochs_action_delete_err}
            , input {&table_inkas}
            , input ( buffer ink-doc:handle )
            , input v-vid-action
            , input v-vid-param
        ) no-error.
      
      end.
      
      return no-apply .
    end.
    else do:
      
      if v-vid-param <> "" or v-vid-param <> ? 
      then do:
        
        find last ub.c-inkas no-lock where ub.c-inkas.inkas-code = v-parameter and ub.c-inkas.corr-user-db-num = v-cntxt-db-num no-error.
        
        v-vid-param = v-vid-param + {&delim-par}+ "RESULT=" + string( 0 ) + {&delim-par} + "Description=".
      
        v-vid-action = 59 .
        run trg/userlog.p (
              input {&nwsdochs_action_delete}
            , input {&table_c-inkas}
            , input ( buffer ub.c-inkas:handle )
            , input v-vid-action
            , input v-vid-param
        ) no-error.
      
      end.
      
      run Openbr in this-procedure ( input yes, input no, input '':U).
      reposition br-docs to recid ri no-error.
    end.
  END.
  APPLY "VALUE-CHANGED" to BR-docs.
  apply "ENTRY" to br-docs.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-export Dialog-Frame
ON CHOOSE OF B-export IN FRAME Dialog-Frame /* Генерац. */
DO:
if not avail ink-doc then return no-apply.
  if export-option = '':U then do:
        run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if export-option = '':U then return no-apply.
  run proc-b-export in this-procedure ( input export-option) no-error.
  if error-status:error then do:
    export-option = '':U.
    return no-apply.
  end.
  APPLY "ENTRY" to br-docs.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
 if not available ink-doc then return no-apply.
  run proc-b-hist in this-procedure no-error.
  if error-status:error then do:
    hist-option = '':U.
    return no-apply.
  end.
  APPLY "ENTRY" to br-docs.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable glog as logical no-undo .
define variable v-handle as handle no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_sale_lookup':U
    {&cntxt-object}
    ink-doc.host-code
    ink-doc.obj-type
    ink-doc.obj-code
    0
    0
    0
    true
    glog
  }
 if NOT glog then  return no-apply.
   assign
   next-prev = '':U.
   v-handle = this-procedure :handle.

  DO WHILE next-prev = '':U:
    if NOT available ink-doc then do:
        message "Неправильный выбор кассового отчета."
                        view-as alert-box WARNING .
        return no-apply.
    end.
    run str/sale.w ( input parparentproc
                    , input {&lookup}
                    , input-output v-doc-rec
                    , input-output v-handle
                    , input-output next-prev
                    , buffer ink-doc
                    ).
  end.
  
  apply "entry" to br-docs in frame {&frame-name}.
  apply "iteration-changed" to br-docs in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable glog as logical no-undo .
  if available ink-doc then do:
    { gbl/markstrn.i ink-doc v-rid-list }
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


&Scoped-define SELF-NAME B-Open
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Open Dialog-Frame
ON CHOOSE OF B-Open IN FRAME Dialog-Frame /* Открыть */
DO:
 IF NOT AVAILABLE ink-doc THEN RETURN NO-APPLY.
 define variable v-close-type as integer no-undo .
 define variable v-status_ like ub.inkas.status_ no-undo .
 define variable v-flag_ like ub.trn-doc.flag_ no-undo .
 define variable v-ask-message as character no-undo .
 define buffer buf_trn-doc for ub.trn-doc.

 find first buf_trn-doc where
           buf_trn-doc.doc-code = ink-doc.inkas-code.
 run str/salegraf.p (
                input ink-doc.inkas-code
               ,input {&open-doc}
               ,input buf_trn-doc.status_
               ,input buf_trn-doc.flag_
               ,output v-status_
               ,output v-flag_
               ,output v-ask-message) no-error .
  if error-status:error then do:
    message
    error-status:get-message(1)  skip
    return-value
    view-as alert-box error .
    return no-apply.
  end.
  run gbl/d-askw.w
    (input "Вопрос"
    ,input substitute("Открыть ОТЧЕТ О ПРОДАЖЕ &1&2" +
                      "Дата учета &3&2" +
                      "Ожидаемая факт дата &4"
                     , ink-doc.inkas-code
                     , {&NEW-LINE}
                     , string(ink-doc.shift-date, '99/99/9999':u)
                     , string(ink-doc.fact-date, '99/99/9999':u)
                     )
    ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                /* второй символ - разделитель атрибутов в описании кнопок */
    ,input (v-status_ + string(v-flag_, "+/-") + '|':u
          + "Отмена" )
    ,input v-ask-message + "|" /* список описаний кнопок */
        + "Отмена действия"
    ,input 1 /* значение возвращаемое при нажатии enter */
    ,input 2 /* значение возвращаемое при нажатии escape */
    ,output v-close-type /* выбор пользователя */
    ).
 if v-close-type = 2 then return no-apply.
 run proc-close IN THIS-PROCEDURE ( input no, input v-close-type, input v-status_, input v-flag_) NO-ERROR.
 IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Выполнить/Печать */
DO:
  if not avail ink-doc then return no-apply.
  if print-type = '':U then do:
    run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if print-type = '':U then return no-apply.
  run proc-b-print in this-procedure ( input print-type) no-error.
  if error-status:error then do:
    print-type = '':U.
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

   if ( available ink-doc ) AND ( v-rid-list = ""
   or
   b-mark:sensitive = no

   ) then
    v-rid-list = string( recid( ink-doc ) ) .

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
define buffer buf_clients for ub.clients.
  if available ink-doc then do:
    assign
    num-chk = ink-doc.num-chk
    qnty = ink-doc.qnty
    ed-notes = replace(ink-doc.PS, {&delim-par}, {&space-char}).
    FIND FIRST buf_clients where
                          buf_clients.obj-type = ink-doc.obj-type AND
                 buf_clients.obj-code = ink-doc.obj-code NO-LOCK NO-ERROR.
    IF avail buf_clients then assign
    shop-name = buf_clients.obj-name.
    else shop-name = string(ink-doc.obj-code).
    display
    ed-notes
    num-chk
    qnty
    shop-name when (par-mode <> {&g___object} and par-mode <> {&g___new})
    with frame {&frame-name} .
   end.
   else do:
      ed-notes:screen-value = '':U.
      display
      '':U @ num-chk
      '':U @ qnty
      '':U shop-name
      with frame {&frame-name} .
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ED-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ED-notes Dialog-Frame
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
/*
    define buffer ps_inkas for inkas.
   DO on stop undo, return no-apply:
        FIND PS_inkas where recid (ps_inkas) = recid(ink-doc) exclusive.
        if ps_inkas.PS <> input frame {&frame-name} ed-notes then
        ps_inkas.PS = input frame {&frame-name} ed-notes.
    END.
  */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-list Dialog-Frame
ON CHOOSE OF MENU-ITEM m-list /* Список продаж */
DO:
  assign
  print-type = 'LIST':U.
  APPLY "CHOOSE" to b-print in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-one Dialog-Frame
ON CHOOSE OF MENU-ITEM m-one /* Продажа */
DO:
   assign
  print-type = 'ONE':U.
  APPLY "CHOOSE" to b-print in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gen-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gen-3 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gen-3 /* Проводки (внеш.) */
DO:
export-option = "m_gen-3".
run proc-b-export in this-procedure ( input export-option) no-error.
if error-status:error then do:
  export-option = '':U.
  return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_inquiry
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_inquiry Dialog-Frame
ON CHOOSE OF MENU-ITEM m_inquiry /* Продажа-запрос */
DO:
    ASSIGN
  add-option = {&inquiry}.
  run proc-b-add IN THIS-PROCEDURE ( INPUT add-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_sale Dialog-Frame
ON CHOOSE OF MENU-ITEM m_sale /* Продажа */
DO:
    ASSIGN
  add-option = {&cash-desk}.
  run proc-b-add IN THIS-PROCEDURE ( INPUT add-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

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
{ gbl/ed_date.i sch-date }
{ gbl/ed_date.i sch-fact }

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel  }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add  }
{ gbl/hot-key.i b-chg  }
{ gbl/hot-key.i b-del  }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }


{ str/sjbysal1.i }
{ gbl/setfltnm.i }
{ gbl/brwrepos.i
&line-num=5
}

{ gbl/brwrefre.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  { gbl/curr-r-b.i
    v-curr-r-b
  }
  v-rid-list = p-rid-list.
  FIND FIRST ub.sys-ctrl NO-LOCK.
  if avail sys-ctrl then do:
    FIND FIRST db no-LOCK where
              db.db-num = sys-ctrl.db-num NO-ERROR.
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
    WHEN {&company} or
    when 'bge-run' then dO:
        FIND FIRST ub.sysconf No-LOCK WHERE
                          ub.sysconf.host-code = parhost-code No-ERROR.
        if not avail ub.sysconf then do:
            message vss-workfile vss-revision vss-description skip
                       "Неверное значение параметра вызова parhost-code" parhost-code
            view-as alert-box ERROR.
            return.
        end.
        find first buf_host no-lock where
                   buf_host.obj-type = {&cmp}
               AND buf_host.obj-code = parhost-code.
        assign varhost-name = buf_host.obj-name.
    END.
    WHEN {&g___object} or
    WHEN {&g___new} OR
    when 'bge-run'  or
    when "object-all" OR
    when {&INQUIRY}
    then dO:
        FIND FIRST buf_obj No-LOCK WHERE
                        buf_obj.obj-type = parobj-type and
                        buf_obj.obj-code = parobj-code No-ERROR.
        if not avail buf_obj then do:
            message vss-workfile vss-revision vss-description skip
            view-as alert-box ERROR.
            return.
        end.
    end.
    otherwise do:
        message vss-workfile vss-revision vss-description skip
        "Неверный вызов - par-mode=" par-mode
        view-as alert-box ERROR.
        return.
    end.
  end CASE.
  if par-mode = {&g___object} or
  par-mode = 'bge-run' or
  par-mode = {&g___new}   or
  par-mode = {&inquiry}
  then dO:
    run get-params in this-procedure ( input parobj-type, input parobj-code) .
  end.
  if v-rid-list <> "":U then do:
    assign
    v-doc-rec = integer(entry(1, v-rid-list))
    .
  end.

  run MyEnable IN THIS-PROCEDURE .
  RUn openbr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
Hide mark-num in frame {&frame-name} .
/*
{ gbl/mv-clmn.i
&browse-name = "br-docs"
&frame-name = "{&frame-name}"
&ext-col = 26
&start-column = 6
&prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26'"
&prev-order-column-condition_1 = " par-mode = 'object-all' "
&prev-order-column_2 = "'1,2,3,4,5,6,7,15,16,8,9,10,11,12,13,14,17,18,19,20,21,22,23,24,25,26'"
&prev-order-column-condition_2 = " par-mode <> 'object-all' "

}
*/
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

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
  DISPLAY ED-notes sch-code sch-date sch-fact mark-num qnty shop-name num-chk
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-export B-chk B-print B-sch B-hist B-Help B-add
         b-lkp B-chg B-del B-close B-Open BR-docs ED-notes sch-code sch-date
         sch-fact mark-num qnty shop-name num-chk
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Get-params Dialog-Frame
PROCEDURE Get-params :
define input parameter locparobj-type like ub.clients.obj-type no-undo.
define input parameter locparobj-code like ub.clients.obj-code no-undo.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .


find first ub.shop No-LOCK WHERE
ub.shop.obj-code = locparobj-code No-ERROR.
if not available ub.shop then return.

/*найдем параметр - использовать смены на кассе или нет*/
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
run adm/shattri.p (
    input "get":U
    ,input  locparobj-type
    ,input  locparobj-code
    ,input  {&attr-get-chk}
    ,input  {&attr-get-chk_cas-shft} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF error-status:error then do:
  message
  substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
            , locparobj-type
            , locparobj-code
            , {&new-line}
            , error-status:get-message(1)
            , return-value )
  view-as alert-box error .
  return error.
end.
cas-shft = v-value-logical.
ASSIGN
v-is-fbr-obj = ub.shop.is-catering.
run gbl/tpsi-obj.p (
              input locparobj-type
            , input locparobj-code
            , output v-is-tpsi-obj) no-error .
{ gbl/objat.i
  locparobj-type
  locparobj-code
  "'shift-on=request'"
  l-shift-on
}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable main-tpsi as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .

br-docs:num-locked-columns in frame {&frame-name} = 7.
ASSIGN
v-tab-order = "b-quit,b-mark,b-sel,b-export,b-chk,b-sch,b-print,b-hist,b-help," +
              "b-add,b-lkp,b-chg,b-del,b-close,b-open,br-docs,sch-code,sch-date,sch-fact".
ASSIGN
b-print:MENU-MOUSE in frame {&frame-name} = 1
b-export:MENU-MOUSE = 1
b-hist:MENU-MOUSE in frame {&frame-name} = 1
.
IF v-is-tpsi-obj
AND par-mode = {&g___new}
and lookup("b-add":U, bttns) > 0  THEN DO:
   /*проверим моду ТПСИ*/
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  assign
  v-tth = buffer thbjattr_thbj-attr:table-handle .
  run adm/shattri.p (
      input "get":U
      ,input  parobj-type
      ,input  parobj-code
      ,input  {&attr-autosale}
      ,input  "":U /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF error-status:error then do:
    message
    substitute("Ошибка при получении опций продажи НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , parobj-type
              , parobj-code
              , {&new-line}
              , error-status:get-message(1)
              , return-value )
    view-as alert-box error .
    return error.
  end.
  for each  thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = parobj-type
        and thbjattr_thbj-attr.obj-code = parobj-code
        and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
  case thbjattr_thbj-attr.prop-code:
    when {&attr-autosale_tpsi-mode} then do:
      assign
      tpsi-mode = thbjattr_thbj-attr.property-value-integer.
    end.
    when {&attr-autosale_main-tpsi} then do:
      assign
      main-tpsi = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
  end.
  if tpsi-mode = 2 then do:
   ASSIGN
   b-add:MENU-MOUSE = 1.
  end.
  assign
  menu-item m_inquiry:sensitive in menu menu-b-add = main-tpsi
  .
END.
ELSE DO:
   add-option = {&cash-desk}.
   b-add:popup-menu = ?.
END.
DISPLAY
ED-notes
sch-code
sch-date
sch-fact
qnty
shop-name when (par-mode <> {&g___object} and par-mode <> {&g___new})
num-chk
WITH FRAME Dialog-Frame.
IF par-mode = 'bge-run' THEN b-export :LABEL = "&Экспорт".
ENABLE
b-quit
B-mark when lookup("b-mark":U, bttns) > 0
B-sel when lookup("b-sel":U, bttns) > 0
b-add WHEN (par-mode = {&g___new} and lookup("b-add":U, bttns) > 0 )
b-chg WHEN (par-mode = {&g___new} and lookup("b-add":U, bttns) > 0 )
b-close WHEN (par-mode = {&g___new} and lookup("b-add":U, bttns) > 0 )
b-open WHEN (par-mode = {&g___new} and lookup("b-add":U, bttns) > 0 )
b-lkp
b-del when ((par-mode = {&g___new} and lookup("b-add":U, bttns) > 0 )
            or
            (par-mode <> {&g___new} and ub.db.db-num = buf_obj.db-num)
            )
B-export when lookup("b-export":U, bttns) > 0 or lookup("prov":U, bttns) > 0
B-chk
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
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
IF par-mode = {&g___new} THEN DO:
    DISABLE
    b-export
   with FRAME {&frame-name}.
END.
IF NOT v-is-fbr-obj = YES THEN DO:
    ASSIGN
    ink-doc.AUTO-fbr:VISIBLE IN BROWSE br-docs = NO
    ink-doc.rest-dish:VISIBLE IN BROWSE br-docs = NO
    ink-doc.rest-ingr:VISIBLE IN BROWSE br-docs = NO
    .
END.
IF NOT v-is-tpsi-obj = YES THEN DO:
    ASSIGN
    ink-doc.AUTO-tpsi:VISIBLE IN BROWSE br-docs = NO
    ink-doc.rest-tpsi:VISIBLE IN BROWSE br-docs = NO
    .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Продажи".
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


&scop flt-open-open-query OPEN QUERY br-docs FOR EACH ink-doc

&scop flt-open-dyn_open-query FOR EACH ink-doc

&scop flt-open-query-handle QUERY br-docs:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name ink-doc

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name ink-doc


&scop flt-open-waitfram yes


define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + par-mode.

CASE par-mode :
WHEN {&all}        THEN DO:
  assign
  filter-label = substitute("&1", filter-label0)
  .
  { gbl/fltopend.i
    &where-cond = " ink-doc.status_ = {&fact} "
    &where-cond = " substitute('ink-doc.status_ = &1&2&1', ~{&double-quote~}, {&fact} )"
    &use-ind    = " USE-INDEX host-date "
    &by         = "  " }
END.
WHEN {&company}    THEN DO:
  if p-open-query then do:
    ASSIGN
    frame {&frame-name}:TITLE = title0 + substitute(" Фирма: &1", varhost-name)
    .
  end.
  filter-label = substitute("&1 Одна фирма", filter-label0)
  .
  { gbl/fltopend.i
    &where-cond = " ink-doc.host-code = parhost-code AND ~
                                        ink-doc.status_ = {&fact} ~
                                    "
    &dyn_where-cond = " substitute('ink-doc.host-code = &1 AND ~
                                        ink-doc.status_ = &2&3&2 ', parhost-code, {&double-quote}, {&fact}) "

    &use-ind    = " USE-INDEX host-date "
    &by         = "  " }
END.
WHEN {&g___object} THEN DO:
  if p-open-query then do:
    ASSIGN
    frame {&frame-name}:TITLE = title0 + substitute(" Закрытые - Объект: &1&2", parobj-type, parobj-code).
   end.
    filter-label = substitute("&1 Один объект, закрытые", filter-label0)
    .
  { gbl/fltopend.i
    &where-cond = " ~
      ink-doc.obj-type  = parobj-type  AND ~
      ink-doc.obj-code  = parobj-code  AND ~
      ink-doc.status_   = {&fact} ~
                        "
    &dyn_where-cond = " substitute('ink-doc.obj-type  = &1&2&1  AND ~
      ink-doc.obj-code  = &3 AND ~
      ink-doc.status_   = &1&4&1 ', ~{&double-quote~}, parobj-type, parobj-code , {&fact})  "

    &use-ind    = " USE-INDEX obj-stat "
    &by         = "  " }
END.
WHEN {&g___new} THEN DO:
  if p-open-query then do:
    ASSIGN
    frame {&frame-name}:TITLE = title0 + substitute(" Незакрытые - Объект: &1&2", parobj-type, parobj-code).
  end.
    filter-label = substitute("&1 Один объект, незакрытые", filter-label0)
    .
  { gbl/fltopend.i
    &where-cond = " ~
      ((ink-doc.obj-type  = parobj-type  AND ~
      ink-doc.obj-code  = parobj-code  AND ~
      ink-doc.status_   = {&g___new}) or ~
      (ink-doc.obj-type  = parobj-type  AND ~
      ink-doc.obj-code  = parobj-code  AND ~
      ink-doc.status_   = {&doc-froze})) ~
                        "
    &dyn_where-cond = " substitute('((ink-doc.obj-type  = &1&2&1  AND ~
      ink-doc.obj-code  = &3 AND ~
      ink-doc.status_   = &1&4&1) or ~
      (ink-doc.obj-type  = &1&2&1 AND ~
      ink-doc.obj-code  = &3 AND ~
      ink-doc.status_   = &1&5&1)) ', ~{&double-quote~}, parobj-type, parobj-code , {&g___new}, {&doc-froze}) "

    &use-ind    = " USE-INDEX obj-stat "
    &by         = "  " }
END.
WHEN {&inquiry} THEN DO:
  if p-open-query then do:
    ASSIGN
    frame {&frame-name}:TITLE = title0 + substitute(" Закрытые запросы по продаже - Объект: &1&2", parobj-type, parobj-code).
  end.
    filter-label = substitute("&1 Один объект, закрытые запросы", filter-label0)
    .
  { gbl/fltopend.i
    &where-cond = " ~
      ink-doc.obj-type  = parobj-type  AND ~
      ink-doc.obj-code  = parobj-code  AND ~
      ink-doc.status_   = {&inquiry} ~
                        "
    &dyn_where-cond = " substitute('ink-doc.obj-type  = &1&2&1  AND ~
      ink-doc.obj-code  = &3  AND ~
      ink-doc.status_   = &1&4&1 ', ~{&double-quote~}, parobj-type, parobj-code, {&inquiry}) "

    &use-ind    = " USE-INDEX obj-stat "
    &by         = "  " }
END.
WHEN "object-all" THEN DO:
if p-open-query then do:
  ASSIGN
  frame {&frame-name}:TITLE = title0 + substitute(" Объект - все: &1&2", parobj-type, parobj-code).
end.
filter-label = substitute("&1 Один объект", filter-label0)
.
  { gbl/fltopend.i
    &where-cond = " ~
      ink-doc.obj-type  = parobj-type  AND ~
      ink-doc.obj-code  = parobj-code ~
                        "
    &dyn_where-cond = " substitute(' ink-doc.obj-type  = &1&2&1  AND ~
      ink-doc.obj-code  = &3 ', ~{&double-quote~}, parobj-type, parobj-code)  "

    &use-ind    = " USE-INDEX obj-stat "
    &by         = "  " }

END.
WHEN 'bge-run' THEN DO:
if p-open-query then do:
  ASSIGN frame {&frame-name}:TITLE = substitute("Продажи без проводок Объект: &1&2", parobj-type, parobj-code).
end.
  { gbl/fltopend.i
    &where-cond = " ~
      ink-doc.obj-type  = parobj-type  AND ~
      ink-doc.obj-code  = parobj-code  AND ~
      ink-doc.status_ = {&fact} AND ~
      ink-doc.bge-date = ? ~
                  "
    &dyn_where-cond = " substitute('ink-doc.obj-type  = &1&2&1 AND ~
      ink-doc.obj-code  = &3  AND ~
      ink-doc.status_ = &1&4&1 AND ~
      ink-doc.bge-date = ? ', ~{&double-quote~}, parobj-type , parobj-code, {&fact}) "

    &use-ind    = " USE-INDEX bge-obj "
    &by         = "  " }
END.
WHEN 'bge-run-host'    THEN DO:
  if p-open-query then do:
    ASSIGN frame {&frame-name}:TITLE = substitute("Продажи без проводок Фирма: &1", varhost-name).
  end.
  { gbl/fltopend.i
      &where-cond = " ink-doc.host-code = parhost-code AND ~
                      ink-doc.status_ = {&fact} AND ~
                      ink-doc.bge-date = ? ~
                                    "
      &dyn_where-cond = " substitute('ink-doc.host-code = &1 AND ~
                      ink-doc.status_ = &1&3&1 AND ~
                      ink-doc.bge-date = ? ', parhost-code, ~{&double-quote~}, {&fact}) "

    &use-ind    = " USE-INDEX bge-host  "
    &by         = "  " }
END.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-docs to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-docs in frame {&frame-name}.
APPLY "ENTRY" TO br-docs.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define variable v-normal-call as logical no-undo .
define variable v-inkas-code as character no-undo .
CASE p-mode:
  WHEN {&cash-desk} THEN DO:
    v-normal-call = can-do("CHOOSE,ENTER":U, last-event:label) .
    if not v-normal-call
    and not l-shift-on then return no-apply.
    run str/cre-sale.p (
                      INPUT parparentproc
                    , INPUT parobj-type
                    , INPUT parobj-code
                    , INPUT {&add-def}
                    , input '':U /*silent*/
                    , input (if not v-normal-call and l-shift-on
                             then  {&select}
                             else '':U) /*p-shift-mode*/
                    , INPUT-output v-inkas-code
                    , INPUT {&cash-desk} ) no-error .
    if error-status:error then do:
      if return-value <> "cancell":U then do:
        message
        substitute("Ошибка при создании продажи:&1&2 &3", {&new-line}, error-status:get-message(1) , return-value )
        view-as alert-box .
        return no-apply.
      end.
    end.
  END.
  WHEN {&inquiry}  THEN DO:
     add-option = ''.
     run str/cre-sale.p (
                      INPUT parparentproc
                    , INPUT parobj-type
                    , INPUT parobj-code
                    , INPUT {&add-def}
                    , input '':U /*p-silent*/
                    , input '':U /*p-shift-date*/
                    , INPUT-output v-inkas-code
                    , INPUT {&inquiry} ) no-error .
     if error-status:error then do:
       if return-value <> "cancell":U then do:
        message
        substitute("Ошибка при создании запроса продажи:&1&2 &3", {&new-line}, error-status:get-message(1) , return-value )
        view-as alert-box .
        return no-apply.
       end.
     end.
  END.
END CASE.
RUn openbr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
APPLY "VALUE-CHANGED" to BR-docs IN FRAME {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-export Dialog-Frame
PROCEDURE proc-b-export :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter loc-option as character no-undo.
define variable glog as logical no-undo .
if loc-option = "":U then return error.
CASE loc-option :
    when "m_gen-3":u
    then do:
      ASSIGN
      glog = ERROR-STATUS :ERROR.
      APPLY "ENTRY":U TO br-docs IN FRAME {&FRAME-NAME}.
      IF glog = yes THEN DO:
        RETURN NO-APPLY.
      END.
      IF LOOKUP( par-mode, 'bge-run' + {&comma-char} + 'bge-run-host' ) > 0 THEN DO:
        RUn openbr in this-procedure ( input yes, input no, input '':U ).
      end.
    end.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-hist Dialog-Frame
PROCEDURE proc-b-hist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable varrid-list as character no-undo .
if not  available ink-doc THEN return error.
    run str/salclist.w (
                    input parparentproc
                   ,input '':U /*bttns  */
                   ,input 'one':U
                   ,input ink-doc.inkas-code
                   ,input ink-doc.host-code
                   ,input ink-doc.obj-type
                   ,input ink-doc.obj-code
                   ,input-output varrid-list    ) no-error .
apply "entry" to br-docs in frame {&frame-name}.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
DEFINE INPUT PARAMETER loc-option as character no-undo.

DEFINE VARIABLE v-frame-width as integer no-undo .
if loc-option = '':U then return error.
CASE loc-option:
when 'ONE':U then do:
    print-type = "".
    run rep/sale-prn.p (  input parparentproc
                    ,input recid(ink-doc)
                    ,input ?).
    print-type = "".
end.
when 'LIST':U then do:
  print-type = "".
      /**/
  define variable v-curr-r-b as character no-undo .
  define variable v-base-type like ub.currency.curr-abbr no-undo .
  define variable v-base-code like ub.currency.curr-code no-undo .
  define buffer buf_currency for ub.currency.
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  if v-curr-r-b = {&r-b-base} then do:
    if par-mode = {&all} then do:
    end.
    else do:
      { gbl/basecode.i parhost-code v-base-code }
      find first buf_currency where
              buf_currency.curr-code = v-base-code.
      assign
      v-base-type = buf_currency.curr-abbr.
    end.
  end.
  v-doc-rec = recid( ink-doc ).
  DO WHILE available ink-doc :
    GET prev br-docs.
  END.

  run PrintListProc in this-procedure ( input v-curr-r-b, input v-base-type) no-error.
  reposition br-docs to recid v-doc-rec no-error.
  apply "entry" to br-docs in frame {&frame-name}.
end.
end case.
loc-option = ''.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
define variable l-shift-on as logical no-undo .
define variable cas-shft as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .

assign
tbl = 'inkas'
join-tbl = 'ink-doc'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('inkas-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
CASE par-mode:
  WHEN  {&all}
  or
  when {&company}
  THEN DO:
    run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code{&delim-flt}shift-date{&delim-flt}shift-num'
                                      , 'Объект/Дата смены/№ смены'
                                      , ('sht' + {&delim-par} +
                                         '':U + {&delim-par} +
                                         string(0) + {&delim-par} +
                                         'no'),
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  end.
  otherwise do:
    /*проверим на сменность*/
      { gbl/objat.i
        {&shop}
        parobj-code
        "'shift-on=request'"
        l-shift-on
      }
    if not l-shift-on then do:
       /*провреим на касс смены*/
      for each thbjattr_thbj-attr:
        delete thbjattr_thbj-attr.
      end.
      assign
      v-tth = buffer thbjattr_thbj-attr:table-handle .
      run adm/shattri.p (
           input "get":U
          ,input  parobj-type
          ,input  parobj-code
          ,input  {&attr-get-chk}
          ,input  {&attr-get-chk_cas-shft} /*p-param-code*/
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-param-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
      IF error-status:error then do:
        message
        substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
                  , parobj-type
                  , parobj-code
                  , {&new-line}
                  , error-status:get-message(1)
                  , return-value )
        view-as alert-box error .
        return error.
      end.
      assign
    /*найдем параметр - использовать смены на кассе или нет*/
      cas-shft = v-value-logical.
    end.
    if l-shift-on
    or cas-shft then do:
      run fltfield-add in this-procedure('shift-date{&delim-flt}shift-num'
                                        , 'Дата смены/№ смены'
                                        , ('sht' + {&delim-par} +
                                          parobj-type + {&delim-par} +
                                          string(parobj-code) + {&delim-par} +
                                          (if l-shift-on then 'yes' else 'no')),
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    end.
  END.
END CASE.
run fltfield-add in this-procedure('shift-date', '', 'Дата смены(учета)',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок Смен', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ Смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sub-discnt', 'Списания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('acc-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('num-chk', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('qnty', 'Кол-во', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', 'Услуги(для <старых> продаж)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('netto', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name', 'Посл.изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.




Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
  ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
  ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
run gbl/filter.w (
                 INPUT parparentproc
               , INPUT (filter-point + {&delim-par} +
                        filter-label + {&delim-par}  + string(yes))
               , INPUT tbl
               , INPUT join-tbl
               , INPUT fld
               , INPUT lab
               , INPUT spr
               , INPUT dim ).
run OpenBr  in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-close Dialog-Frame
PROCEDURE proc-close :
define input parameter p-direction as logical no-undo . /*yes закрыть no открыть*/
define input parameter p-close-type as integer no-undo . /*1 авто 2 на факт*/
define input parameter p-status_ like ub.inkas.status_ no-undo .
define input parameter p-flag_   like ub.trn-doc.flag_ no-undo .
DEFINE VARIABLE compensed AS LOGICAL NO-UNDO.
DEFINE VARIABLE auto-comp AS LOGICAL NO-UNDO.
DEFINE VARIABLE autofbr AS LOGICAL NO-UNDO.
DEFINE VARIABLE one-curs AS LOGICAL NO-UNDO.
DEFINE VARIABLE restdish AS LOGICAL NO-UNDO.
DEFINE VARIABLE restingr AS LOGICAL NO-UNDO.
DEFINE VARIABLE resttpsi AS LOGICAL NO-UNDO.
/*уводить чужой весовой товар в отриц остатки*/
define variable neg-tpsi-weight as logical no-undo .
/*уводить чужой товар в отриц остатки по отметке оператора*/
define variable neg-tpsi-oper as logical no-undo .
/*уводить чужой товар в отриц остатки если недостает меньше чем*/
define variable neg-tpsi-qnty as decimal no-undo .
/*закрывать приход по техпроливу*/
define variable close-in-rfsl as integer no-undo .
/*список алгоритмов для размазывания chk-gds-pay*/
define variable pay-gds-algo as character no-undo .
DEFINE VARIABLE v-is-tpsi-obj AS LOGICAL NO-UNDO.
define variable v-loc-rec as recid no-undo .
define variable v-parameter as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
DEFINE BUFFER buf_shop FOR ub.shop.
v-loc-rec = recid(ink-doc).

CASE p-close-type:
  when 1 then do:
    run str/salestat.p (
                        input parparentproc
                      , input ink-doc.inkas-code
                      , input (if p-direction then {&close-doc} else {&open-doc})
                      , input p-status_ /*тот что будет*/
                      , input p-flag_
                      , input no /*p-silent */ ) no-error .
    if error-status:error then do:
      message
      substitute("Ошибка при переводе статуса продажи &1:&2&3 &4"
                 , ink-doc.inkas-code
                 , {&new-line}
                 , error-status:get-message(1)
                 , return-value )
      view-as alert-box error .
      undo, return error .
    end.
    run Openbr in this-procedure ( input yes, input no, input '':U).
  end.
  when 2 then do:
    FIND FIRST buf_shop NO-LOCK WHERE
              buf_shop.obj-code = ink-doc.obj-code .
    run gbl/tpsi-obj.p ( input ink-doc.obj-type, input ink-doc.obj-code, output v-is-tpsi-obj) no-error .
    v-tth = buffer thbjattr_thbj-attr:table-handle .
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
        input "get":U
        ,input  ink-doc.obj-type
        ,input  ink-doc.obj-code
        ,input  {&attr-autosale}
        ,input  "":U /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF error-status:error then do:
      message
      substitute("Ошибка при получении опций продажи НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , ink-doc.obj-type
              , ink-doc.obj-code
              , {&new-line}
              , error-status:get-message(1)
              , return-value )
      view-as alert-box error .
      undo, return error .
    end.
    for each  thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = ink-doc.obj-type
          and thbjattr_thbj-attr.obj-code = ink-doc.obj-code
          and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      case thbjattr_thbj-attr.prop-code:
        when {&attr-autosale_autocomp} then do:
          auto-comp = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_autofbr} then do:
          autofbr = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_one-curs} then do:
          one-curs = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_restdish} then do:
          restdish = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_restingr} then do:
          restingr = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_resttpsi} then do:
          resttpsi = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_neg-tpsi-weight} then do:
          neg-tpsi-weight = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_neg-tpsi-oper} then do:
          neg-tpsi-oper = thbjattr_thbj-attr.property-value-logical.
        end.
        when {&attr-autosale_neg-tpsi-qnty} then do:
          neg-tpsi-qnty = thbjattr_thbj-attr.property-value-decimal.
        end.
        when {&attr-autosale_close-in-rfsl} then do:
          close-in-rfsl = thbjattr_thbj-attr.property-value-integer.
        end.
        when {&attr-autosale_pay-gds-algo} then do:
          pay-gds-algo = thbjattr_thbj-attr.property-value-character.
        end.
      end case.
      assign
      restdish = restdish and autofbr
      restingr = restingr and autofbr
      resttpsi = resttpsi and v-is-tpsi-obj
      .
    end.
    assign
    v-parameter =     v-curr-r-b                      + {&delim-par} +
                      ink-doc.inkas-code              + {&delim-par} +
                    string(1) /*p-auto*/             + {&delim-par} +
                    string(YES) /*auto-close*/       + {&delim-par} +
                    string(no) /*b-mail-pressed*/    + {&delim-par} +
                    string(auto-comp)                + {&delim-par} +
                    string(autofbr)                  + {&delim-par} +
                    string(one-curs)                 + {&delim-par} +
                    string(buf_shop.is-catering)     + {&delim-par} +
                    string(v-is-tpsi-obj)            + {&delim-par} +
                    string(restdish)                 + {&delim-par} +
                    string(restingr)                 + {&delim-par} +
                    string(resttpsi)                 + {&delim-par} +
                    string(neg-tpsi-weight)          + {&delim-par} +
                    string(neg-tpsi-qnty)            + {&delim-par} +
                    string(neg-tpsi-oper)            + {&delim-par} +
                    string(close-in-rfsl)            + {&delim-par} +
                    pay-gds-algo

    .
    run str/diallog.w (
          input parParentProc
        , input this-procedure
        , input ("str/saleclos.p":U + {&delim-par} +
                "1":U  + {&delim-par} +  /*error-message-option*/
                "1":U + {&delim-par} +  /*auto-go-option*/
                "1":U)                  /*return-value-option*/
        , input v-parameter
        , input no /*p-auto-go*/
        , input "":U
        , input substitute("Закрытие продажи &1 &2&3", Ink-doc.inkas-code, ink-doc.obj-type, ink-doc.obj-code)
    ) no-error.
    if error-status:error
    and return-value <> "error"
    then do:
      message
      substitute("&1 &2"
                , error-status:get-message(1)
                , return-value )
      view-as alert-box error .
      return error .
    end.
    if return-value = "error":U then do:
      return error .
    end.
    else do:
      run Openbr in this-procedure ( input yes, input no, input '':U).
    end.
  end. /*when на факт*/
END CASE.
reposition br-docs to recid v-loc-rec no-error.
apply "entry" to br-docs in frame {&frame-name} .
Apply "value-changed" to br-docs in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Proc-find-code Dialog-Frame
PROCEDURE Proc-find-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter pardoc-code like ub.inkas.inkas-code no-undo.
display
"  /  /":U @ sch-date
"  /  /":U @ sch-fact
with frame {&frame-name}.

assign
pardoc-code = {&double-quote} + pardoc-code + {&double-quote}.
run OpenBr in this-procedure
  (input false /* p-open-query */
  ,input par-next  /* p-find-next  */
  ,input substitute("and ink-doc.inkas-code   begins &1 "
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
define input parameter par-date like ub.inkas.doc-date no-undo.
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
    ,input par-next  /* p-find-next  */
    ,input substitute("and ink-doc.doc-date = &1 "
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
      ,input par-next  /* p-find-next  */
      ,input substitute("and ink-doc.fact-date = &1 "
      , var-datechr)
      ).
    apply "entry":u to sch-fact in frame {&frame-name}.
  end.

END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-query Dialog-Frame
PROCEDURE reopen-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if available ink-doc then v-doc-rec = recid(ink-doc).
run OpenBr in this-procedure ( input  yes, input no, input '':U).
reposition br-docs to recid v-doc-rec no-error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-inkas Dialog-Frame
PROCEDURE reposition-inkas :
define input  parameter p-direction   as character no-undo .
define output parameter p-inkas-recid as recid no-undo .

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
      if not available ink-doc then do:
        message
        "Это первый документ списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-docs.
      if not available ink-doc then do:
        message
        "Это последний документ списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
  assign
  p-inkas-recid = recid(ink-doc)
  .
  run reposition-query in this-procedure
    (input p-inkas-recid
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