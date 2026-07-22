&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE TEMP-TABLE tt-sum-grp NO-UNDO LIKE ub.sum-grp
       field code-2 as integer
       field gtype as integer.
DEFINE TEMP-TABLE tt-tax-rate-code NO-UNDO LIKE ub.tax-rate
       field bo-tax-code like ub.tax-rate.tax-code
       index pi is unique primary rate-code.
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина (thbj-attr) "cd-type-ibm-xml"

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/16/04
Author: Bakhtadze Natalya
Creation date: 09/16/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.shop.obj-code NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'cd-type-ibm-xml'".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ str/runanlst.i }
{ ref/gds-attr.i }
{ ref/gdshattr.i }
{ cmp/gds-list.i gds-list def "new shared" }


DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
DEFINE VARIABLE v-host-code LIKE ub.shop.host-code NO-UNDO.
DEFINE VARIABLE v-base-code LIKE ub.sysconf.base-code NO-UNDO.
DEFINE VARIABLE specgrp-option AS INTEGER NO-UNDO.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-specgrp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-sum-grp tt-tax-rate-code

/* Definitions for BROWSE BR-specgrp                                    */
&Scoped-define FIELDS-IN-QUERY-BR-specgrp tt-sum-grp.grp-code ~
tt-sum-grp.grp-name code-2 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-specgrp 
&Scoped-define QUERY-STRING-BR-specgrp FOR EACH tt-sum-grp NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-specgrp OPEN QUERY BR-specgrp FOR EACH tt-sum-grp NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-specgrp tt-sum-grp
&Scoped-define FIRST-TABLE-IN-QUERY-BR-specgrp tt-sum-grp


/* Definitions for BROWSE BR-tax-rate-code                              */
&Scoped-define FIELDS-IN-QUERY-BR-tax-rate-code tt-tax-rate-code.rate-code ~
bo-tax-code tt-tax-rate-code.rate-name tt-tax-rate-code.tax-code 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tax-rate-code ~
tt-tax-rate-code.tax-code 
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-tax-rate-code tt-tax-rate-code
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-tax-rate-code tt-tax-rate-code
&Scoped-define QUERY-STRING-BR-tax-rate-code FOR EACH tt-tax-rate-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-tax-rate-code OPEN QUERY BR-tax-rate-code FOR EACH tt-tax-rate-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-tax-rate-code tt-tax-rate-code
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tax-rate-code tt-tax-rate-code


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-ibmrubc f-ibmnalc ~
b-curr f-ibm-ccm RS-cd-vat T-multicurr BR-tax-rate-code t-ibmgroup ~
BR-specgrp for-curr-name l-cd-vat 
&Scoped-Define DISPLAYED-OBJECTS f-ibmrubc f-ibmnalc f-ibm-ccm RS-cd-vat ~
T-multicurr t-ibmgroup for-curr-name l-cd-vat 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-add-2 
       MENU-ITEM m_50           LABEL "Услуги"        
       MENU-ITEM m_24           LABEL "Перечисление в систему лояльности".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add  NO-FOCUS
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-add-2  NO-FOCUS
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-curr 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON B-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-del-2 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-ibm-ccm AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Код платежа при оплате НАЛИЧНЫМИ CCM" 
     VIEW-AS FILL-IN 
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE f-ibmnalc AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1)" 
     VIEW-AS FILL-IN 
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE f-ibmrubc AS INTEGER FORMAT ">>9":U INITIAL 0 
     LABEL "Код национальной валюты (abbr_rub_allshift) НА КАССЕ" 
     VIEW-AS FILL-IN 
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE for-curr-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6.8 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-cd-vat AS CHARACTER FORMAT "X(256)":U INITIAL "Выделение ставок НДС в чеке:" 
      VIEW-AS TEXT 
     SIZE 29 BY .67 NO-UNDO.

DEFINE VARIABLE RS-cd-vat AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Не выделять", 0,
"Выделять", 1
     SIZE 32 BY 1 NO-UNDO.

DEFINE VARIABLE t-ibmgroup AS LOGICAL INITIAL no 
     LABEL "прием чеков с продажами по группам" 
     VIEW-AS TOGGLE-BOX
     SIZE 38.6 BY 1 NO-UNDO.

DEFINE VARIABLE T-multicurr AS LOGICAL INITIAL no 
     LABEL "Многовалютные НАЛИЧНЫЕ" 
     VIEW-AS TOGGLE-BOX
     SIZE 24.6 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-specgrp FOR 
      tt-sum-grp SCROLLING.

DEFINE QUERY BR-tax-rate-code FOR 
      tt-tax-rate-code SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-specgrp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-specgrp Dialog-Frame _STRUCTURED
  QUERY BR-specgrp NO-LOCK DISPLAY
      tt-sum-grp.grp-code COLUMN-LABEL "Код группы" FORMAT "99":U
      tt-sum-grp.grp-name COLUMN-LABEL "Описание" FORMAT "X(40)":U
      code-2 COLUMN-LABEL "Код товара" FORMAT "999999999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 79.6 BY 6
         TITLE "Спецгруппы в справочнике суммовых групп" FIT-LAST-COLUMN.

DEFINE BROWSE BR-tax-rate-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tax-rate-code Dialog-Frame _STRUCTURED
  QUERY BR-tax-rate-code NO-LOCK DISPLAY
      tt-tax-rate-code.rate-code COLUMN-LABEL "Код!ставки" FORMAT ">>9":U
      bo-tax-code COLUMN-LABEL "Код налога" FORMAT ">9":U WIDTH 16.8
      tt-tax-rate-code.rate-name COLUMN-LABEL "Название ставки" FORMAT "X(40)":U
      tt-tax-rate-code.tax-code COLUMN-LABEL "Катег.налога!на кассе" FORMAT "9":U
            WIDTH 13.5
  ENABLE
      tt-tax-rate-code.tax-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 80.6 BY 7.29
         TITLE "Соответствие ставок НДС категориям налога на кассе (кроме POS c ОС LINUX)" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-add-2 AT ROW 15 COL 51
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-add AT ROW 6.52 COL 1
     B-Help AT ROW 1 COL 55
     f-ibmrubc AT ROW 2.29 COL 67.6 COLON-ALIGNED
     f-ibmnalc AT ROW 3.52 COL 72.6 COLON-ALIGNED
     b-curr AT ROW 3.52 COL 77.6
     f-ibm-ccm AT ROW 4.52 COL 67.6 COLON-ALIGNED
     RS-cd-vat AT ROW 5.52 COL 34.6 NO-LABEL
     T-multicurr AT ROW 5.52 COL 69.6 WIDGET-ID 2
     B-del AT ROW 6.52 COL 11
     BR-tax-rate-code AT ROW 7.52 COL 1
     t-ibmgroup AT ROW 14.81 COL 1
     B-del-2 AT ROW 15 COL 61
     BR-specgrp AT ROW 16 COL 1
     for-curr-name AT ROW 3.67 COL 79.6 COLON-ALIGNED NO-LABEL
     l-cd-vat AT ROW 5.76 COL 3.6 NO-LABEL
     SPACE(66.69) SKIP(15.73)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Параметры POS IBM-XML"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: tt-sum-grp T "?" NO-UNDO ub sum-grp
      ADDITIONAL-FIELDS:
          field code-2 as integer
          field gtype as integer
      END-FIELDS.
      TABLE: tt-tax-rate-code T "?" NO-UNDO ub tax-rate
      ADDITIONAL-FIELDS:
          field bo-tax-code like ub.tax-rate.tax-code
          index pi is unique primary rate-code
      END-FIELDS.
      TABLE: X_shop B "?" ? ub shop
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-tax-rate-code B-del Dialog-Frame */
/* BROWSE-TAB BR-specgrp B-del-2 Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-add IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-add-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       B-add-2:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add-2:HANDLE.

/* SETTINGS FOR BUTTON B-del IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-del-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN l-cd-vat IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-specgrp
/* Query rebuild information for BROWSE BR-specgrp
     _TblList          = "Temp-Tables.tt-sum-grp"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.tt-sum-grp.grp-code
"tt-sum-grp.grp-code" "Код группы" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.tt-sum-grp.grp-name
"tt-sum-grp.grp-name" "Описание" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"code-2" "Код товара" "999999999" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE BR-specgrp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tax-rate-code
/* Query rebuild information for BROWSE BR-tax-rate-code
     _TblList          = "Temp-Tables.tt-tax-rate-code"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.tt-tax-rate-code.rate-code
"tt-tax-rate-code.rate-code" "Код!ставки" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"bo-tax-code" "Код налога" ">9" ? ? ? ? ? ? ? no ? no no "16.8" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.tt-tax-rate-code.rate-name
"tt-tax-rate-code.rate-name" "Название ставки" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.tt-tax-rate-code.tax-code
"tt-tax-rate-code.tax-code" "Катег.налога!на кассе" ? "integer" ? ? ? ? ? ? yes ? no no "13.6" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is NOT OPENED
*/  /* BROWSE BR-tax-rate-code */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры POS IBM-XML */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-log AS logical NO-UNDO.
  DEFINE VARIABLE v-tax-rid AS RECID NO-UNDO.
  DEFINE VARIABLE v-tax-rate-rid AS RECID NO-UNDO.
  DEFINE BUFFER buf_tax FOR ub.tax.
  DEFINE BUFFER buf_tax-rate FOR ub.tax-rate.
  FIND FIRST buf_tax NO-LOCK WHERE
            buf_tax.tax-code = INTEGER({&vat-tax-code}).
  run ref/tax-tree.w (
      input parparentproc
      ,INPUT "b-seltax-rate"
      ,INPUT "ALL-TAX-RATES" /* ref-mode */
      ,INPUT 0 /*parhost-code */
      ,INPUT p-obj-type
      ,INPUT p-obj-code
      ,INPUT RECID(buf_tax)
      ,INPUT-OUTPUT v-tax-rate-rid
      ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
IF v-tax-rate-rid <> ? THEN DO:
    FIND FIRST buf_tax-rate NO-LOCK WHERE
          recid(buf_tax-rate) = v-tax-rate-rid.
   FIND FIRST tt-tax-rate-code NO-LOCK WHERE
              tt-tax-rate-code.rate-code = buf_tax-rate.rate-code NO-ERROR.
    IF AVAILABLE tt-tax-rate-code THEN DO:
        MESSAGE
        "Вы уже выбрали ставку налога с кодом ставки" tt-tax-rate-code.rate-code
        VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
   END.
   IF buf_tax-rate.STATUS_ = {&deleted-status}  THEN DO:
        MESSAGE
        "Нельзя выбрать ставку налога в статусе УДАЛЕН"
        VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
   END.

   CREATE tt-tax-rate-code.
   BUFFER-COPY buf_tax-rate
   except tax-code
   TO tt-tax-rate-code
   ASSIGN
   tt-tax-rate-code.bo-tax-code = buf_tax-rate.tax-code
   tt-tax-rate-code.tax-code = 0
   v-tax-rate-rid = RECID(tt-tax-rate-code)
   .
   run openbr IN THIS-PROCEDURE.
   REPOSITION br-tax-rate-code TO RECID v-tax-rate-rid.
END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-2 Dialog-Frame
ON CHOOSE OF B-add-2 IN FRAME Dialog-Frame /* Добавить */
DO:
  IF specgrp-option = 0 THEN DO:
    run gbl/pop-up.p ( INPUT self:handle, INPUT no) NO-ERROR.
  END.
  IF specgrp-option = 0  THEN RETURN NO-APPLY.
  RUN proc-b-add-2 IN THIS-PROCEDURE ( INPUT specgrp-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      specgrp-option = 0.
       RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-curr Dialog-Frame
ON CHOOSE OF b-curr IN FRAME Dialog-Frame
DO:
    define variable rr as recid no-undo.
    DEFINE BUFFER buf_currency FOR ub.currency.
    rr = ? .
    run ref/currency.w (
                     input parparentproc
                   , input "b-sel"
                   , input-output rr ).
    if rr <> ? then do:
      FIND FIRST buf_currency WHERE
                recid( buf_currency ) = rr NO-LOCK .
      DISPLAY
      buf_currency.curr-code @ f-ibmnalc
      buf_currency.curr-abbr @ for-curr-name
      with frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE tt-tax-rate-code THEN RETURN NO-APPLY.
  DELETE tt-tax-rate-code.
  run openbr IN THIS-PROCEDURE.
  REPOSITION br-tax-rate-code TO ROW 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-2 Dialog-Frame
ON CHOOSE OF B-del-2 IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE tt-sum-grp THEN RETURN NO-APPLY.
  DELETE tt-sum-grp.
  {&OPEN-QUERY-br-specgrp}
  REPOSITION br-specgrp TO ROW 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-ibmnalc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-ibmnalc Dialog-Frame
ON LEAVE OF f-ibmnalc IN FRAME Dialog-Frame /* Код валюты по умолчанию при оплате НАЛИЧНЫМИ (код платежа = 1) */
DO:
    DEFINE BUFFER buf_currency FOR ub.currency.
    FIND FIRST buf_currency NO-LOCK WHERE
            buf_currency.curr-code = INPUT FRAME {&FRAME-NAME} f-ibmnalc NO-ERROR.
  IF AVAIL buf_currency THEN DO:
    DISPLAY
    buf_currency.curr-abbr @ for-curr-name
    WITH FRAME {&FRAME-NAME}.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_24
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_24 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_24 /* Перечисление в систему лояльности */
DO:
  ASSIGN
  specgrp-option = 24.
  RUN proc-b-add-2 IN THIS-PROCEDURE ( INPUT specgrp-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      specgrp-option = 0.
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_50
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_50 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_50 /* Услуги */
DO:
  ASSIGN
  specgrp-option = 50.
  RUN proc-b-add-2 IN THIS-PROCEDURE ( INPUT specgrp-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      specgrp-option = 0.
      RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-cd-vat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-cd-vat Dialog-Frame
ON VALUE-CHANGED OF RS-cd-vat IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-cd-vat.
  CASE rs-cd-vat:
      WHEN 0 THEN DO:
        for each tt-tax-rate-code:
          delete tt-tax-rate-code.
        end.
        ASSIGN
        tt-tax-rate-code.tax-code:read-only IN browse br-tax-rate-code  = yes .
        DISABLE
        b-add
        b-del WITH FRAME {&FRAME-NAME}.
      END.
      WHEN 1 THEN DO:
          IF p-mode = {&update} THEN DO:
              ASSIGN
              tt-tax-rate-code.tax-code:read-only IN browse br-tax-rate-code  = no .
              ENABLE
              b-add
              b-del WITH FRAME {&FRAME-NAME}.
        END.
    END.
  END CASE.
  run openbr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-ibmgroup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-ibmgroup Dialog-Frame
ON VALUE-CHANGED OF t-ibmgroup IN FRAME Dialog-Frame /* прием чеков с продажами по группам */
DO:
 ASSIGN
 t-ibmgroup.
  CASE t-ibmgroup:
    WHEN YES  THEN DO:
      if p-mode = {&update} then do:
         ENABLE
         b-add-2
         b-del-2
         WITH FRAME {&FRAME-NAME}.
      end.
    END.
    WHEN NO THEN DO:
      FOR EACH tt-sum-grp:
          DELETE tt-sum-grp.
      END.
      DISABLE
      b-add-2
      b-del-2
      WITH FRAME {&FRAME-NAME}.
      {&OPEN-QUERY-br-specgrp}
    END.
  END CASE.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-specgrp
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
{ gbl/getcntxt.i get }
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
  IF p-mode <> {&lookup}
  and p-mode <> {&update} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-obj-type <> {&shop}
  and p-obj-type <> {&cmp}
  and p-obj-type <> '':U
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  if p-obj-type = {&shop} then do:
    FIND FIRST X_shop NO-LOCK WHERE X_shop.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_shop THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/objdbnum.i ~{&shop~} p-obj-code v-db-num }
    IF v-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  end.
  if p-obj-type = {&cmp} then do:
    FIND FIRST X_sysconf NO-LOCK WHERE X_sysconf.host-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_sysconf THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять параметры ФИРМЫ в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
    v-host-code = p-obj-code.
  end.
  if p-obj-type = '':U then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-ibm-xml}
        AND   locked_thbj-attr.prop-code = '':U NO-WAIT NO-ERROR.
     if locked locked_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ПАРАМЕТРЫ(АТРИБУТЫ) МАГАЗИНА занята"
        view-as alert-box error .
        undo, return error.
      end.
  END.
  ELSE DO:
      FIND FIRST LOCKED_thbj-attr no-LOCK WHERE
          LOCKED_thbj-attr.obj-type = p-obj-type
    AND   LOCKED_thbj-attr.obj-code = p-obj-code
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-cd-type-ibm-xml}
    AND   locked_thbj-attr.prop-code = '':U NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.

  end.
  run FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.

  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

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
  DISPLAY f-ibmrubc f-ibmnalc f-ibm-ccm RS-cd-vat T-multicurr t-ibmgroup 
          for-curr-name l-cd-vat 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-ibmrubc f-ibmnalc b-curr f-ibm-ccm RS-cd-vat 
         T-multicurr BR-tax-rate-code t-ibmgroup BR-specgrp for-curr-name 
         l-cd-vat 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rate-code LIKE ub.tax-rate.rate-code NO-UNDO.
DEFINE VARIABLE v-cdtaxlst AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-specgrp AS CHARACTER NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
define variable v-grp-code as integer no-undo .
define variable v-gtype as integer no-undo .
DEFINE BUFFER buf_tax-rate FOR ub.tax-rate.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER buf_tt-sum-grp FOR tt-sum-grp.
FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
              input "init":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-cd-type-ibm-xml}
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT table-handle v-tth
            ) no-error .
if error-status:error
and not available locked_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr:
  ASSIGN
  v-entry = thbjattr_thbj-attr.prop-code.
  IF v-entry = {&attr-cd-type-ibm-xml_ibmrubc} THEN DO:
    ASSIGN
    f-ibmrubc = thbjattr_thbj-attr.property-value-integer
    f-ibmrubc:private-data in frame {&frame-name}  = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-ibm-xml_ibmnalc} THEN DO:
    ASSIGN
    f-ibmnalc = thbjattr_thbj-attr.property-value-integer
    f-ibmnalc:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-ibm-xml_ibm-ccm} THEN DO:
    ASSIGN
    f-ibm-ccm = thbjattr_thbj-attr.property-value-integer
    f-ibm-ccm:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-ibm-xml_ibmgroup} THEN DO:
    ASSIGN
    t-ibmgroup = thbjattr_thbj-attr.property-value-logical
    t-ibmgroup:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-ibm-xml_cd-vat} THEN DO:
    ASSIGN
    RS-cd-vat = thbjattr_thbj-attr.property-value-integer
    rs-cd-vat:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-cd-type-ibm-xml_cdtaxlst} THEN DO:
    ASSIGN
    v-cdtaxlst = thbjattr_thbj-attr.property-value-character
    .
  END.
  IF v-entry = {&attr-cd-type-ibm-xml_specgrp} THEN DO:
    ASSIGN
    v-specgrp = thbjattr_thbj-attr.property-value-character.
  END.
  IF v-entry = {&attr-cd-type-ibm-xml_multicurr} THEN DO:
    ASSIGN
    t-multicurr = thbjattr_thbj-attr.property-value-logical
    t-multicurr:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
if v-cdtaxlst <> "":U then do:
  _ii:
  DO ii = 1 TO NUM-ENTRIES(v-cdtaxlst, ";"):
    ASSIGN
    v-rate-code = INTEGER (ENTRY(1, ENTRY(ii, v-cdtaxlst, ";":U), "-":U))
    .
    FIND FIRST buf_tax-rate NO-LOCK WHERE
                  buf_tax-rate.rate-code = v-rate-code NO-ERROR.
    IF NOT AVAILABLE buf_tax-rate THEN NEXT _ii.

      CREATE tt-tax-rate-code.
      BUFFER-COPY buf_tax-rate TO tt-tax-rate-code
      ASSIGN
      tt-tax-rate-code.tax-code = integer(ENTRY(2, ENTRY(ii, v-cdtaxlst, ";":U), "-":U))
      .
  END.
end.
if v-specgrp <> "":U then do:
  _ii:
  DO ii = 1 TO NUM-ENTRIES(v-specgrp, ";"):
    ASSIGN
    v-grp-code = INTEGER (ENTRY(1, ENTRY(ii, v-specgrp, ";":U), "-":U))
    .
    if num-entries(ENTRY(ii, v-specgrp, ";":U), "-":U) > 2 then do:
      assign
      v-gtype = INTEGER (ENTRY(3, ENTRY(ii, v-specgrp, ";":U), "-":U)) no-error .
    end.
    FIND FIRST buf_tt-sum-grp NO-LOCK WHERE
                  buf_tt-sum-grp.grp-code = v-grp-code NO-ERROR.
    IF AVAILABLE buf_tt-sum-grp THEN NEXT _ii.
    FIND FIRST buf_goods NO-LOCK WHERE
                buf_goods.gds-code = integer(ENTRY(2, ENTRY(ii, v-specgrp, ";":U), "-":U)) NO-ERROR.

      CREATE buf_tt-sum-grp.
      ASSIGN
      buf_tt-sum-grp.grp-code = integer(ENTRY(1, ENTRY(ii, v-specgrp, ";":U), "-":U))
      buf_tt-sum-grp.code-2 = (IF AVAILABLE buf_goods
                               THEN buf_goods.gds-code
                               ELSE integer(ENTRY(2, ENTRY(ii, v-specgrp, ";":U), "-":U)))
      buf_tt-sum-grp.grp-name = (IF AVAILABLE buf_goods
                               THEN buf_goods.gds-name
                               ELSE "!!!Ошибка не такого товара")
      buf_tt-sum-grp.gtype    = v-gtype
      .
  END.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER buf_currency FOR ub.currency.
FIND FIRST buf_currency NO-LOCK WHERE
          buf_currency.curr-code = f-ibmnalc NO-ERROR.
IF AVAILABLE buf_currency THEN DO:
    ASSIGN
    for-curr-name = buf_currency.curr-abbr.
END.
ASSIGN
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code)
v-tab-order = "f-ibmrubc,f-ibmnalc,f-ibm-ccm,b-curr,RS-cd-vat,t-multicurr,b-add,b-del,br-tax-rate-code," +
              "t-ibmgroup,b-add-2,b-del-2,br-specgrp".

assign
f-ibmrubc :label = "Код национальной валюты ({&abbr_rub_allshift}) НА КАССЕ"
b-add-2:MENU-MOUSE = 1
.

if p-obj-code = 0 and p-obj-type = "" then  t-ibmgroup = no.

DISPLAY
f-ibmrubc
f-ibmnalc
f-ibm-ccm
for-curr-name
RS-cd-vat
l-cd-vat
t-ibmgroup
t-multicurr
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
br-tax-rate-code
br-specgrp
b-curr WHEN p-mode = {&UPDATE}
f-ibmrubc WHEN p-mode = {&UPDATE}
f-ibmnalc WHEN p-mode = {&UPDATE}
f-ibm-ccm WHEN p-mode = {&UPDATE}
t-ibmgroup WHEN p-mode = {&UPDATE} and p-obj-code <> 0
t-multicurr when p-mode = {&UPDATE}
rs-cd-vat WHEN p-mode = {&UPDATE}
b-add   WHEN p-mode = {&UPDATE} AND rs-cd-vat = 1
b-del   WHEN p-mode = {&UPDATE} AND rs-cd-vat = 1
b-add-2   WHEN p-mode = {&UPDATE} AND t-ibmgroup
b-del-2   WHEN p-mode = {&UPDATE} AND t-ibmgroup

WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
    HIDE
    b-exit
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:LABEL = "&Выход"
    tt-tax-rate-code.tax-code:read-only  in browse br-tax-rate-code = yes
    .
END.
APPLY "value-changed" TO rs-cd-vat.
APPLY "value-changed" TO t-ibmgroup.
{&open-query-br-specgrp}
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
OPEN QUERY br-tax-rate-code FOR EACH tt-tax-rate-code SHARE-LOCK.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add-2 Dialog-Frame 
PROCEDURE proc-b-add-2 :
DEFINE INPUT PARAMETER p-gtype AS INTEGER NO-UNDO.
DEFINE VARIABLE v-value-int AS integer NO-UNDO.
DEFINE VARIABLE v-sum-grp-rid AS recid NO-UNDO.
DEFINE VARIABLE ref-list AS character NO-UNDO.
define buffer buf_gds-list for gds-list.

  /*50 - сотовые операторы */
  /*24 - перечисление системе лояльности */
  define variable v-host-code as integer no-undo .
  define buffer buf_macro-list-hist for macro-list-hist.


  DEFINE BUFFER buf_tt-sum-grp FOR tt-sum-grp.
  DEFINE BUFFER buf_goods FOR ub.goods.


  DEFINE BUFFER buf_sum-grp FOR ub.sum-grp.
  run ref/sum-grps.w (
                 input parparentproc
               , INPUT "b-sel"
               , input-output ref-list).
  if ref-list = "":U then do:
    UNDO, RETURN ERROR.
  END.

    find first buf_sum-grp no-lock where
              recid(buf_sum-grp) = integer(entry(1, ref-list)) no-error .
    if not avail buf_sum-grp then return error.
    assign
    v-value-int = buf_sum-grp.grp-code
    .
  FIND FIRST buf_tt-sum-grp WHERE
            buf_tt-sum-grp.grp-code = v-value-int NO-ERROR.
  IF AVAILABLE buf_tt-sum-grp THEN DO:
      MESSAGE
      "Уже определена запись с таким кодом"
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN error.
  END.
  for each buf_macro-list-hist:
    delete buf_macro-list-hist.
  end.
  for each gds-list-hist:
    delete gds-list-hist.
  end.
  create buf_macro-list-hist.
  assign
  buf_macro-list-hist.list-table = '':U
  buf_macro-list-hist.id         = 1
  buf_macro-list-hist.line       = 0
  buf_macro-list-hist.hist-mode  = '+'
  buf_macro-list-hist.status_    = {&all}
  .
  CASE p-gtype:
      WHEN 50 THEN DO:
          ASSIGN
          buf_macro-list-hist.des        = "ВСЕ услуги-платежи в адрес ОСС"
                                                 /*ВСЕ товары с глобальным атрибутом товара Платеж ОСС = yes (текущие товары)*/
          buf_macro-list-hist.item_      = {&attr-office-type}
          buf_macro-list-hist.option_    = "goods-attr"
          .
      END.
      WHEN 24 THEN DO:
          ASSIGN
          buf_macro-list-hist.des        = "ВСЕ услуги-перечисления в системы лояльности"
                                                 /*ВСЕ товары с глобальным атрибутом перечисление в систему лояльности*/
          buf_macro-list-hist.item_      = {&attr-is-loyalty-payment}  + {&delim-key} + string(yes)
          buf_macro-list-hist.option_    = "goods-attr-val"
          .
    END.
  END CASE.
  release buf_macro-list-hist.

  { gbl/hostcode.i p-obj-type p-obj-code v-host-code no-error }
  for each gds-list:
    delete gds-list.
  end.

  run str/gdsqlist.w (
                   input parparentproc
                  ,input this-procedure:handle
                  ,input v-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input "b-sel"
                  ,input "ВСЕ услуги-платежи в адрес ОСС"
                  ,input yes
                  ).
  find first gds-list where
           gds-list.to-sel = yes no-error.
  if not available gds-list then return error.
  FIND FIRST buf_goods NO-LOCK WHERE
            buf_goods.gds-code = gds-list.gds-code NO-ERROR.
  IF NOT AVAILABLE buf_goods THEN RETURN error.
  for each buf_gds-list where buf_gds-list.to-sel = yes:
    buf_gds-list.to-sel = no.
  end.
  if buf_goods.gds-type <> {&gds-office} then do:
    message
    "Со спецгруппой можно связать только УСЛУГУ!"
    view-as alert-box error.
    undo, return error.
  end.
  if buf_goods.unit-base <> "{&abbr_rub}" then do:
    message
    substitute("Со спецгруппой можно связать только УСЛУГУ,&1" +
               "у которой единица измерения равна единице измерения НАЦИОНАЛЬНОЙ ВАЛЮТЫ (&2)"
               , {&new-line}
               , "{&abbr_rub}")
    view-as alert-box error.
    undo, return error.
  end.

  CREATE buf_tt-sum-grp.
  ASSIGN
  buf_tt-sum-grp.grp-code = v-value-int
  buf_tt-sum-grp.grp-name = gds-list.gds-name
  buf_tt-sum-grp.code-2   = gds-list.gds-code
  buf_tt-sum-grp.gtype    = p-gtype
  v-sum-grp-rid = RECID(buf_tt-sum-grp)
  .
  for each gds-list:
    delete gds-list.
  end.
  {&OPEN-QUERY-br-specgrp}
  REPOSITION br-specgrp TO RECID v-sum-grp-rid.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-cdtaxlst as character no-undo .
define variable v-specgrp as character no-undo .
define variable ii as integer no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .

DEFINE BUFFER buf_tt-tax-rate-code FOR tt-tax-rate-code.
DEFINE BUFFER buf_tt-sum-grp FOR tt-sum-grp.
IF p-mode = {&LOOKUP} THEN RETURN ERROR.
FIND FIRST buf_tt-tax-rate-code NO-LOCK WHERE
          buf_tt-tax-rate-code.tax-code = 0 NO-ERROR.
IF AVAILABLE buf_tt-tax-rate-code THEN DO:
    MESSAGE
    "Вы не ввели категорию налога НА КАССЕ для ставки с кодом " buf_tt-tax-rate-code.rate-code
    VIEW-AS ALERT-BOX ERROR.
    RETURN ERROR.
END.
ASSIGN
FRAME {&FRAME-NAME}
f-ibmrubc
f-ibmnalc
f-ibm-ccm
t-ibmgroup
t-multicurr
RS-cd-vat.

if rs-cd-vat = 1 then do:
  FOR EACH tt-tax-rate-code BY tt-tax-rate-code.rate-code:
    ASSIGN
    ii = ii + 1
    v-cdtaxlst = v-cdtaxlst + (if ii = 1 then "":U else ";":U) +
                  STRING(tt-tax-rate-code.rate-code) + "-":U + STRING(tt-tax-rate-code.tax-code)
    .
  END.
end.
if t-ibmgroup then do:
  ii = 0.
  FOR EACH buf_tt-sum-grp BY buf_tt-sum-grp.grp-code:
    ASSIGN
    ii = ii + 1
    v-specgrp = v-specgrp + (if ii = 1 then "":U else ";":U)  +
                  STRING(buf_tt-sum-grp.grp-code) + "-":U + STRING(buf_tt-sum-grp.code-2) +
                   '-' + STRING(buf_tt-sum-grp.gtype)
    .
  END.
end.
assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
  end.
  wh = wh:next-sibling.
end.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-ibm-xml_cdtaxlst}.
assign
thbjattr_thbj-attr.property-value-character = v-cdtaxlst
.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-cd-type-ibm-xml_specgrp}.
assign
thbjattr_thbj-attr.property-value-character = v-specgrp
.
v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code:
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
/*проверим корректность*/
run adm/shattri.p (
              input "check":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-cd-type-ibm-xml}
            , INPUT '':U
             , output v-value-character
             , output v-value-date
             , output v-value-decimal
             , output v-value-integer
             , output v-value-logical
             , output v-param-type
             , input-output table-handle v-tth
             ) no-error .

if error-status:error then do:
  message
  "Некорректное значение ПАРАМЕТРОВ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
do TRANSACTION
on error undo, return error return-value
:

  RUN thbjattr_set-section IN THIS-PROCEDURE (
       input p-obj-type
      ,input p-obj-code
      ,input {&attr-cd-type-ibm-xml}
      ,INPUT table thbjattr_thbj-attr
  ) NO-ERROR.
  IF ERROR-STATUS:error THEN do:
    MESSAGE ERROR-STATUS:get-message(1)  SKIP
    RETURN-VALUE
    VIEW-AS ALERT-BOX.
    UNDO, RETURN ERROR.
  END.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

