&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-utd
using ibs.th.gbl.sys.objsrv.
using ibs.th.str.marking.sts.*.
using ibs.th.str.marking.handlers.*.
using ibs.th.str.utd.sts.*.
using ibs.th.bge.is_motp.*.
/* Temp-Table and Buffer definitions                                    */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS d-utd 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка кодов маркировки

Автор: Шкляр Елена
Дата создания: 20/04/95
Author: Shklyar Elena
Creation date: 20/04/95

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-doc-id as integer no-undo .
define input parameter p-db-num as integer   no-undo .
define input parameter p-type   as integer  no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-connect as com-handle no-undo .
define variable p-host-code     as integer   no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка кодов маркировки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/userobjs.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/mrk-strf.i }
{ gbl/color.i }
{ str/temp_upd.i }
{ gbl/key-rec.i  }
{ str/edo.i }
{ cmp/trg-def.i}

/* Local Variable Definitions ---                                       */

define variable log-res-statch as log       no-undo.
define variable rr             as recid     no-undo.
define variable v_type         as char      no-undo.
define variable v-is-deploy    as logical   no-undo .
define variable v-rid-list     as character no-undo .
define variable v-db-list      as character no-undo .
define variable v-comment      as character no-undo .
define variable gds-rec        as integer   no-undo .
define variable recid_utd      as integer   no-undo . 
define variable v-GTIN         as character no-undo .
define variable m-gds-code     as character no-undo label "Товар" view-as fill-in.
define variable type_mark      as integer   no-undo .
define variable iLang          as integer   no-undo .
define variable p-value-logical as logical no-undo.
define variable p-value-character  as character no-undo.
define variable p-value-date       as date no-undo.
define variable p-value-decimal    as decimal no-undo.
define variable p-value-integer    as integer no-undo.
define variable p-param-type       as character no-undo.
define variable v-tth as handle no-undo .
define variable log-edi-doc_update as logical no-undo .

define variable Tree           as class     tree no-undo .

define variable ungroup        as logical   no-undo .

define variable line-num-error as integer   no-undo .
define variable v-pred-status  as integer   no-undo .
define variable v-obj-active   as logical   no-undo .

define variable mRecKey-line   as character no-undo.
define buffer buf_clients           for ub.clients .
define buffer X_utd-lines           for tt-utd-lines .
define buffer buf_utd               for ub.utd .
define buffer buf_utd-attr          for ub.utd-attr .
define buffer buf_utd-lines         for ub.utd-lines .
define buffer bf_utd-lines          for ub.utd-lines .
define buffer buf_contract          for ub.contract .
define buffer buf_utd-marking-lines for ub.utd-marking-lines .
define buffer bf_utd-marking-lines  for ub.utd-marking-lines .
define buffer buf_goods             for ub.goods .
define buffer buf_marking           for ub.marking .
define buffer buf_utd-err           for ub.utd-err .

define variable v-scan-str  as character no-undo .
define variable v-manual    as logical   no-undo .
define variable v-barcode   as logical   no-undo .
DEFINE VARIABLE v-timedelay as integer   no-undo .
define variable mflagscan   as logical   no-undo.
define variable mMarkUtdLine as logical   no-undo.
define variable mOrderItem  as character   no-undo.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-utd 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 14/02/20 - 10:57 am

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */



&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-utd
&Scoped-define BROWSE-NAME br-utd

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_utd-lines

/* Definitions for BROWSE br-utd                                        */
&Scoped-define FIELDS-IN-QUERY-br-utd X_utd-lines.LineId ~
X_utd-lines.gds-code X_utd-lines.GdsName X_utd-lines.UnitCode ~
X_utd-lines.Quantity X_utd-lines.Article X_utd-lines.sts 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-utd 

&Scoped-define QUERY-STRING-br-utd FOR EACH X_utd-lines NO-LOCK where if r-error = 2 then X_utd-lines.stts = "Ожидает проверку" or X_utd-lines.stts begins "Ошибка" else X_utd-lines.sts = 0 INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-utd if r-error = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен" INDEXED-REPOSITION. else ~
if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка" INDEXED-REPOSITION.  else ~
OPEN QUERY br-utd FOR EACH X_utd-lines no-lock INDEXED-REPOSITION.

&Scoped-define TABLES-IN-QUERY-br-utd X_utd-lines
&Scoped-define FIRST-TABLE-IN-QUERY-br-utd X_utd-lines


/* Definitions for DIALOG-BOX d-utd                                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-utd ~
    ~{&OPEN-QUERY-br-utd}
    
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-save b_servis b_error ~
B_mark B_mark-utd RECT-1 R-TH f-num f-date c-type ~
f-obj-type-TH f-obj-code-TH r-obj-TH f-obj-name-TH FILL-IN-1 f-supp-type-TH ~
f-supp-code-TH r-supp-TH f-supp-name-TH FILL-IN-2 FILL-IN-3 f-contr-TH ~
r-contr-TH f-contr-name-TH f-contr-name f-status c-status-edi c-status ~
f-comment r-wrkr r-agnt f-info r-boss v-mark v-bar-code a-n-c b_error_line br-utd ~
b_prov-finish b_recheck b_correct b_back-check ~
b_finish b_write-cancel b_deliv-cancel wrkr-name agnt-name boss-name f-wrkr f-agnt f-boss 
&Scoped-Define DISPLAYED-OBJECTS f-num f-date c-type f-obj-type-TH ~
f-obj-code-TH f-obj-name-TH f-obj-name-2 FILL-IN-1 f-supp-type-TH ~
f-supp-code-TH f-supp-name-TH FILL-IN-2 FILL-IN-3 f-contr-TH ~
f-contr-name-TH f-contr-name f-status c-status-edi c-status f-comment ~
f-info v-mark v-bar-code a-n-c a-n-c-name F-text wrkr-name agnt-name boss-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD CliName d-utd 
FUNCTION CliName RETURNS CHARACTER
   (input p-cli-code as integer, input p-cli-type as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD ContName d-utd 
FUNCTION ContName RETURNS CHARACTER
   ( input p-contract-code as integer, input p-host-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD GdsName d-utd 
FUNCTION GdsName RETURNS CHARACTER
   ( input p-gds-code as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD GdsName d-utd 
FUNCTION GdsUnit RETURNS CHARACTER
   ( input p-gds-code as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD StatusName d-utd 
FUNCTION StatusName RETURNS CHARACTER
   ( input p-doc-id as integer,
   input p-db-num as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD ChkAnotherUtd d-utd 
FUNCTION ChkAnotherUtd RETURNS LOGICAL
   ( input p-doc-id as integer,
     input p-db-num as integer,
     input p-mark as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-utd
&Scoped-define BROWSE-NAME br-utd

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_utd-lines

/* Definitions for BROWSE br-utd                                        */
&Scoped-define FIELDS-IN-QUERY-br-utd X_utd-lines.LineNum ~
X_utd-lines.gds-code X_utd-lines.ProductCode X_utd-lines.GdsName ~
X_utd-lines.Quantity X_utd-lines.Price X_utd-lines.Total ~
X_utd-lines.TaxRate X_utd-lines.UnitCode 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-utd X_utd-lines.qnty-scan
&Scoped-define QUERY-STRING-br-utd if v-gds-code eq ? ~
then ~
   FOR EACH X_utd-lines where X_utd-lines.gds-code eq m-gds-code  NO-LOCK indexed-reposition.~
else ~
   FOR EACH tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code, First X_utd-lines where X_utd-lines.db-num = tt-utd-lines-filtr.db-num and X_utd-lines where X_utd-lines.doc-id = tt-utd-lines-filtr.doc-id and X_utd-lines where X_utd-lines.LineNum = tt-utd-lines-filtr.linenum  NO-LOCK indexed-reposition.
&Scoped-define OPEN-QUERY-br-utd if m-gds-code ne ? and m-gds-code ne "" ~
then do: ~
   if r-error = 2 then   OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else ~
   if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. else ~
                         OPEN QUERY br-utd FOR EACH X_utd-lines                                     , first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code and tt-utd-lines-filtr.db-num = X_utd-lines.db-num and tt-utd-lines-filtr.doc-id = X_utd-lines.doc-id and tt-utd-lines-filtr.LineNum = X_utd-lines.linenum  NO-LOCK INDEXED-REPOSITION. ~
end. ~
else do: ~
if r-error = 2 then    OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен", first tt-utd-lines-filtr  INDEXED-REPOSITION. else ~
 if r-error-2 = 2 then OPEN QUERY br-utd FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка"   , first tt-utd-lines-filtr  INDEXED-REPOSITION. else ~
                       OPEN QUERY br-utd FOR EACH X_utd-lines NO-LOCK                                     , first tt-utd-lines-filtr  INDEXED-REPOSITION.      ~
end. 
&Scoped-define TABLES-IN-QUERY-br-utd X_utd-lines
&Scoped-define FIRST-TABLE-IN-QUERY-br-utd X_utd-lines

/* Definitions for BROWSE br-utd-nomark                                 */
&Scoped-define FIELDS-IN-QUERY-br-utd-nomark X_utd-lines.LineNum ~
X_utd-lines.gds-code X_utd-lines.ProductCode X_utd-lines.GdsName ~
X_utd-lines.Quantity X_utd-lines.Price X_utd-lines.Total ~
X_utd-lines.TaxRate_ X_utd-lines.fact-qnty X_utd-lines.qnty-scan ~
X_utd-lines.stts X_utd-lines.UnitCliQnty 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-utd-nomark X_utd-lines.qnty-scan 
&Scoped-define ENABLED-TABLES-IN-QUERY-br-utd-nomark X_utd-lines
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-utd-nomark X_utd-lines
&Scoped-define QUERY-STRING-br-utd-nomark FOR EACH X_utd-lines where if v-gds-code eq ? or v-gds-code eq 0 then true else X_utd-lines.gds-code eq v-gds-code  NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-utd-nomark if r-error = 2 then OPEN QUERY br-utd-nomark FOR EACH X_utd-lines no-lock where X_utd-lines.stts <> "Проверен" and if v-gds-code eq ? or v-gds-code eq 0 then true else X_utd-lines.gds-code eq v-gds-code INDEXED-REPOSITION. else ~
if r-error-2 = 2 then OPEN QUERY br-utd-nomark FOR EACH X_utd-lines no-lock where X_utd-lines.stts begins "Ошибка" and if v-gds-code eq ? or v-gds-code eq 0 then true else X_utd-lines.gds-code eq v-gds-code INDEXED-REPOSITION.  else ~
OPEN QUERY br-utd-nomark FOR EACH X_utd-lines where if v-gds-code eq ? or v-gds-code eq 0 then true else X_utd-lines.gds-code eq v-gds-code NO-LOCK INDEXED-REPOSITION....
&Scoped-define TABLES-IN-QUERY-br-utd-nomark X_utd-lines
&Scoped-define FIRST-TABLE-IN-QUERY-br-utd-nomark X_utd-lines


/* Definitions for DIALOG-BOX d-utd                                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-utd ~
    ~{&OPEN-QUERY-br-utd}~
    ~{&OPEN-QUERY-br-utd-nomark}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-cancel b-exit b-save b-servis b_error ~
 B_mark RECT-1 R-TH c-type f-num-name f-num f-date-name f-date ~
f-num-name-2 f-num-2 f-date-name-2 f-date-2 f-obj-name f-obj-type-TH ~
f-obj-code-TH r-obj-TH f-obj-name-TH f-gruz FILL-IN-1 f-supp-type-TH ~
f-supp-code-TH r-supp-TH f-supp-name-TH f-total FILL-IN-2 FILL-IN-3 ~
f-contr-TH r-contr-TH f-contr-name-TH f-contr-name f-vat f-status-TH ~
c-status f-status-EDI c-status-edi f-comment f-wrkr-name f-wrkr r-wrkr ~
f-comment-name f-agnt-name f-agnt r-agnt f-info f-info-name f-boss-name ~
f-boss r-boss v-bar-code v-mark a-n-c R-error R-error-2 b_prov-finish ~
b_recheck b_correct b_anul b_back-check b_finish b_write-cancel ~
b_deliv-cancel wrkr-name agnt-name boss-name 
&Scoped-Define DISPLAYED-OBJECTS c-type f-num-name f-num f-date-name f-date ~
f-num-name-2 f-num-2 f-date-name-2 f-date-2 f-obj-name f-obj-type-TH ~
f-obj-code-TH f-obj-name-TH f-gruz f-obj-name-2 FILL-IN-1 f-supp-type-TH ~
f-supp-code-TH f-supp-name-TH f-total FILL-IN-2 FILL-IN-3 f-contr-TH ~
f-contr-name-TH f-contr-name f-vat f-status-TH c-status f-status-EDI ~
c-status-edi f-comment f-wrkr-name f-wrkr f-comment-name f-agnt-name f-agnt ~
f-info f-info-name f-boss-name f-boss f-bar-code f-mark v-bar-code v-mark ~
a-n-c a-n-c-name R-error R-error-2 F-text wrkr-name agnt-name boss-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
/*DEFINE MENU m_BarCode                                      */
/*   MENU-ITEM m_BarCode-utd  LABEL "Штрих-коды по документу"*/
/*   MENU-ITEM m_BarCode-lines LABEL "Штрих-коды по строке". */

DEFINE MENU m_error 
   MENU-ITEM m_error-utd    LABEL "Ошибки по документу"
   MENU-ITEM m_error-lines  LABEL "Ошибки по строке".

DEFINE MENU m_marks 
   MENU-ITEM m_marks-utd    LABEL "Марки по документу"
   MENU-ITEM m_marks-lines  LABEL "Марки по строке".

DEFINE MENU POPUP-MENU-b-servis 
   MENU-ITEM m_choose-status LABEL "Сменить статус документа"
   MENU-ITEM m_check-akt    LABEL "Проверить по Акту приема-передачи"
   MENU-ITEM m_reset_row_data LABEL "Сбросить данные по строке"
   .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY 
   LABEL "&Отмена":L 
   SIZE 15 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
   LABEL "&Выход ":L 
   SIZE 15 BY 1.

DEFINE BUTTON b-save AUTO-GO 
   LABEL "&Ввод ":L 
   SIZE 15 BY 1.

DEFINE BUTTON b-order 
   LABEL "Заказ" 
   SIZE 20 BY 1.

DEFINE BUTTON b-servis 
   LABEL "Сервис" 
   SIZE 15 BY 1.

DEFINE BUTTON b_anul 
   LABEL "Аннулировать" 
   SIZE 36 BY 1.25.

DEFINE BUTTON b_back-check 
   LABEL "Продолжить проверку" 
   SIZE 36 BY 1.25.

DEFINE BUTTON b_correct 
   LABEL "Запрос на изменение" 
   SIZE 36 BY 1.25.

DEFINE BUTTON b_deliv-cancel 
   LABEL "Отказать в поставке" 
   SIZE 36 BY 1.25.

DEFINE BUTTON b_error 
   LABEL "Ошибки/проблемы" 
   SIZE 16 BY 1.

DEFINE BUTTON b_finish 
   LABEL "Ввод в оборот" 
   SIZE 36 BY 1.25.

DEFINE BUTTON B_mark 
   LABEL "Марки/Штрих-коды" 
   SIZE 17 BY 1.

DEFINE BUTTON b_prov-finish 
   LABEL "Проверка завершена" 
   SIZE 36 BY 1.25.

DEFINE BUTTON b_recheck 
   LABEL "Повторно проверить" 
   SIZE 36 BY 1.25.

DEFINE BUTTON b_write-cancel 
   LABEL "Отказать в подписи" 
   SIZE 36 BY 1.25.

DEFINE BUTTON b_cleaggds 
   LABEL "Сброс фильтра" 
   SIZE 15 BY 1.

DEFINE BUTTON r-agnt 
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "r-acc" 
   SIZE 3 BY 1.

DEFINE BUTTON r-boss 
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "r-acc" 
   SIZE 3 BY 1.

DEFINE BUTTON r-contr-TH 
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "" 
   SIZE 3 BY 1.

DEFINE BUTTON r-obj-TH 
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "" 
   SIZE 3 BY 1.

DEFINE BUTTON r-supp-TH 
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "" 
   SIZE 3 BY 1.

DEFINE BUTTON r-wrkr 
   IMAGE-UP FILE "btn-down-arrow":U
   IMAGE-DOWN FILE "btn-down-arrow":U
   IMAGE-INSENSITIVE FILE "btn-down-arrow":U
   LABEL "r-acc" 
   SIZE 3 BY 1.

DEFINE VARIABLE c-status        AS INTEGER   FORMAT "-999":U INITIAL 0 
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "Все",0,
   "Получен от поставщика",2,
   "Требует корректировки",3,
   "Ожидает поставки",4,
   "Требует подписания",5
   DROP-DOWN-LIST
   SIZE 55.5 BY 1 NO-UNDO.

DEFINE VARIABLE c-status-edi    AS INTEGER   FORMAT "-999":U INITIAL 352 
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "Все",0,
   "Получен от поставщика",2,
   "Требует корректировки",3,
   "Ожидает поставки",4,
   "Требует подписания",5
   DROP-DOWN-LIST
   SIZE 58.5 BY 1 NO-UNDO.

DEFINE VARIABLE c-type          AS INTEGER   FORMAT "-999":U INITIAL 0 
   LABEL "Тип" 
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "Все",0,
   "Получен от поставщика",2,
   "Требует корректировки",3,
   "Ожидает поставки",4,
   "Требует подписания",5
   DROP-DOWN-LIST
   SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE f-comment       AS CHARACTER 
   VIEW-AS EDITOR SCROLLBAR-VERTICAL
   SIZE 100 BY 1.46 NO-UNDO.

DEFINE VARIABLE f-info          AS CHARACTER 
   VIEW-AS EDITOR SCROLLBAR-VERTICAL
   SIZE 100 BY 1.96 NO-UNDO.

DEFINE VARIABLE f-obj-name-2    AS CHARACTER 
   VIEW-AS EDITOR SCROLLBAR-VERTICAL
   SIZE 70.5 BY 2.17 NO-UNDO.

DEFINE VARIABLE a-n-c-name      AS CHARACTER FORMAT "X(256)":U 
   VIEW-AS FILL-IN 
   SIZE 45 BY 1
   FGCOLOR 12 NO-UNDO.

DEFINE VARIABLE agnt-name       AS CHARACTER FORMAT "x(256)":U 
   VIEW-AS TEXT 
   SIZE 11 BY 1
   BGCOLOR 15 NO-UNDO.

DEFINE VARIABLE boss-name       AS CHARACTER FORMAT "x(256)":U 
   VIEW-AS TEXT 
   SIZE 11 BY 1
   BGCOLOR 15 NO-UNDO.

DEFINE VARIABLE f-agnt          AS INTEGER   FORMAT ">>>>>>>>>>>9":U INITIAL 0 
   VIEW-AS FILL-IN 
   SIZE 11.25 BY 1
   BGCOLOR 15 NO-UNDO.

DEFINE VARIABLE f-agnt-name     AS CHARACTER FORMAT "X(256)":U INITIAL "Исп:" 
   VIEW-AS FILL-IN 
   SIZE 4.88 BY 1 NO-UNDO.

/*DEFINE VARIABLE f-bar-code      AS CHARACTER FORMAT "X(256)":U INITIAL "Штрих-код:"*/
/*   VIEW-AS FILL-IN                                                                 */
/*   SIZE 11.25 BY 1 NO-UNDO.                                                        */

DEFINE VARIABLE f-boss          AS INTEGER   FORMAT ">>>>>>>>>>>9":U INITIAL 0 
   VIEW-AS FILL-IN 
   SIZE 11.25 BY 1
   BGCOLOR 15 NO-UNDO.

DEFINE VARIABLE f-boss-name     AS CHARACTER FORMAT "X(256)":U INITIAL "М-р:" 
   VIEW-AS FILL-IN 
   SIZE 4.88 BY 1 NO-UNDO.

DEFINE VARIABLE f-comment-name  AS CHARACTER FORMAT "X(256)":U INITIAL "Комментарий:" 
   VIEW-AS FILL-IN 
   SIZE 12.88 BY 1 NO-UNDO.

DEFINE VARIABLE f-contr-name    AS CHARACTER FORMAT "X(150)" 
   VIEW-AS FILL-IN 
   SIZE 35.25 BY 1.

DEFINE VARIABLE f-contr-name-TH AS CHARACTER FORMAT "X(100)" 
   VIEW-AS FILL-IN 
   SIZE 48.5 BY 1.

DEFINE VARIABLE f-contr-TH      AS INTEGER   FORMAT ">>>>>>>>>>>>>>>>>>>>>>9" INITIAL 0 
   VIEW-AS FILL-IN 
   SIZE 19.5 BY 1.

DEFINE VARIABLE f-date          AS DATE      FORMAT "99/99/9999":U 
   VIEW-AS FILL-IN 
   SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-2        AS DATE      FORMAT "99/99/9999":U 
   VIEW-AS FILL-IN 
   SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-name     AS CHARACTER FORMAT "X(256)":U INITIAL "Дата:" 
   VIEW-AS FILL-IN 
   SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-name-2   AS CHARACTER FORMAT "X(256)":U INITIAL "Дата:" 
   VIEW-AS FILL-IN 
   SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE f-gruz          AS CHARACTER FORMAT "X(256)":U INITIAL "Грузополучатель:" 
   VIEW-AS FILL-IN 
   SIZE 17.38 BY .92 NO-UNDO.

DEFINE VARIABLE f-info-name     AS CHARACTER FORMAT "X(256)":U INITIAL "Доп.инфо:" 
   VIEW-AS FILL-IN 
   SIZE 9.88 BY 1 NO-UNDO.

DEFINE VARIABLE f-mark          AS CHARACTER FORMAT "X(256)":U INITIAL "Марка:" 
   VIEW-AS FILL-IN 
   SIZE 6.75 BY 1 NO-UNDO.

DEFINE VARIABLE f-num           AS CHARACTER FORMAT "X(256)":U 
   VIEW-AS FILL-IN 
   SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-2         AS CHARACTER FORMAT "X(256)":U 
   LABEL "№" 
   VIEW-AS FILL-IN 
   SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-name      AS CHARACTER FORMAT "X(256)":U INITIAL "№ документа:" 
   VIEW-AS FILL-IN 
   SIZE 12.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-name-2    AS CHARACTER FORMAT "X(256)":U INITIAL "№:" 
   VIEW-AS FILL-IN 
   SIZE 3.25 BY 1 NO-UNDO.

DEFINE VARIABLE f-obj-code-TH   AS INTEGER   FORMAT ">>>>>>>>>>9" INITIAL 0 
   VIEW-AS FILL-IN 
   SIZE 14.75 BY 1.

DEFINE VARIABLE f-obj-name      AS CHARACTER FORMAT "X(256)":U INITIAL "Объект:" 
   VIEW-AS FILL-IN 
   SIZE 14 BY .75 NO-UNDO.

DEFINE VARIABLE f-obj-name-TH   AS CHARACTER FORMAT "X(100)" 
   VIEW-AS FILL-IN 
   SIZE 48.5 BY 1.

DEFINE VARIABLE f-obj-type-TH   AS CHARACTER FORMAT "X(3)" 
   VIEW-AS FILL-IN 
   SIZE 4.13 BY 1.

DEFINE VARIABLE f-status-EDI    AS CHARACTER FORMAT "X(256)":U INITIAL "Статус EDI:" 
   VIEW-AS FILL-IN 
   SIZE 11.75 BY 1 NO-UNDO.

DEFINE VARIABLE f-status-TH     AS CHARACTER FORMAT "X(256)":U INITIAL "Статус ТН:" 
   VIEW-AS FILL-IN 
   SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE f-supp-code-TH  AS INTEGER   FORMAT ">>>>>>>>>>9" INITIAL 0 
   VIEW-AS FILL-IN 
   SIZE 14.75 BY 1.

DEFINE VARIABLE f-supp-name-TH  AS CHARACTER FORMAT "X(100)" 
   VIEW-AS FILL-IN 
   SIZE 48.5 BY 1.

DEFINE VARIABLE f-supp-type-TH  AS CHARACTER FORMAT "X(3)" 
   VIEW-AS FILL-IN 
   SIZE 4.13 BY 1.

DEFINE VARIABLE F-text          AS CHARACTER FORMAT "X(256)":U 
   VIEW-AS FILL-IN 
   SIZE 148 BY 1.25
   FGCOLOR 12 NO-UNDO.

DEFINE VARIABLE f-total         AS DECIMAL   FORMAT "->>,>>>,>>>,>>9.99":U INITIAL 0 
   LABEL "Общая сумма" 
   VIEW-AS FILL-IN 
   SIZE 16.75 BY 1 NO-UNDO.

DEFINE VARIABLE f-vat           AS DECIMAL   FORMAT "->>,>>9.99":U INITIAL 0 
   LABEL "Сумма НДС" 
   VIEW-AS FILL-IN 
   SIZE 16.75 BY 1 NO-UNDO.

DEFINE VARIABLE f-wrkr          AS INTEGER   FORMAT ">>>>>>>>>>>9":U INITIAL 0 
   VIEW-AS FILL-IN 
   SIZE 11.25 BY 1
   BGCOLOR 15 NO-UNDO.

DEFINE VARIABLE f-wrkr-name     AS CHARACTER FORMAT "X(256)":U INITIAL "Кл-к:" 
   VIEW-AS FILL-IN 
   SIZE 5.88 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-1       AS CHARACTER FORMAT "X(256)":U INITIAL "Поставщик:" 
   VIEW-AS FILL-IN 
   SIZE 14 BY .75 NO-UNDO.

DEFINE VARIABLE FILL-IN-2       AS CHARACTER FORMAT "X(256)":U INITIAL "Договор:" 
   VIEW-AS FILL-IN 
   SIZE 14 BY .75 NO-UNDO.

DEFINE VARIABLE FILL-IN-3       AS CHARACTER FORMAT "X(256)":U INITIAL "Договор:" 
   VIEW-AS FILL-IN 
   SIZE 14 BY .75 NO-UNDO.

/*DEFINE VARIABLE v-bar-code      AS CHARACTER FORMAT "X(255)"*/
/*   VIEW-AS FILL-IN                                          */
/*   SIZE 100 BY 1.                                           */

DEFINE VARIABLE v-mark          AS CHARACTER FORMAT "X(255)" 
   VIEW-AS FILL-IN 
   SIZE 100 BY 1.

DEFINE VARIABLE wrkr-name       AS CHARACTER FORMAT "x(256)":U 
   VIEW-AS TEXT 
   SIZE 11 BY 1
   BGCOLOR 15 NO-UNDO.

DEFINE VARIABLE a-n-c           AS CHARACTER 
   VIEW-AS RADIO-SET HORIZONTAL
   RADIO-BUTTONS 
   "Код", "code",
   "Нач.назв", "name",
   "Нач.слова", "context"
   SIZE 37.63 BY 1 NO-UNDO.

DEFINE VARIABLE R-error         AS INTEGER 
   VIEW-AS RADIO-SET HORIZONTAL
   RADIO-BUTTONS 
   "Все", 1,
   "Не проверено", 2
   SIZE 25.38 BY 1 NO-UNDO.

DEFINE VARIABLE R-error-2       AS INTEGER 
   VIEW-AS RADIO-SET HORIZONTAL
   RADIO-BUTTONS 
   "Все", 1,
   "Ошибки", 2
   SIZE 25.38 BY 1 NO-UNDO.

DEFINE RECTANGLE R-TH
   EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
   SIZE 73.5 BY 6.75 TOOLTIP "Данные ТН".

DEFINE RECTANGLE RECT-1
   EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
   SIZE 147.5 BY 3.25.

define variable mgdsUnit as character no-undo.

define variable much as character no-undo.
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-utd FOR 
   X_utd-lines, tt-utd-lines-filtr SCROLLING.

DEFINE QUERY br-utd-nomark FOR 
   X_utd-lines SCROLLING.
&ANALYZE-RESUME
def var Marking as class mark no-undo .
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD StatusTHName d-utd
FUNCTION StatusTHName RETURNS CHARACTER
   (input p-stsTH as integer)  .
   Return Marking:GetLabel(p-stsTH) .
END FUNCTION .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD EdoTypeName d-utd 
FUNCTION EdoTypeName RETURNS CHARACTER
   (input p-stsTH as integer)  .
   Return ObjSrv:Env:Utd:EDocType:GetLabel(p-stsTH) .
END FUNCTION .  
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



/* Browse definitions                                                   */
DEFINE BROWSE br-utd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-utd d-utd _STRUCTURED
   QUERY br-utd NO-LOCK DISPLAY
   X_utd-lines.LineNum COLUMN-LABEL "№ п/п" FORMAT ">>>9":U
   X_utd-lines.gds-code COLUMN-LABEL "Код товара" FORMAT ">>>>999999":U
   X_utd-lines.ProductCode COLUMN-LABEL "Наименование!УПД" FORMAT "x(40)":U width 25
   X_utd-lines.gds-name COLUMN-LABEL "Наименование ТН" FORMAT "x(112)":U width 25
   X_utd-lines.Quantity COLUMN-LABEL "Кол-во в ед.!изм TH по!УПД" FORMAT "->>,>>9.999":U
   X_utd-lines.qnty-scan COLUMN-LABEL "Факт!кол-во" FORMAT "->>>>>>>>>9.999":U
   gdsunit (X_utd-lines.gds-code) @ mgdsunit COLUMN-LABEL "Ед.изм!TH" FORMAT "x(6)":U
   if X_utd-lines.IsMarking and X_utd-lines.isWeight
   then "вп"
   else if X_utd-lines.IsArtic and X_utd-lines.isWeight
   then "во" 
   else if X_utd-lines.IsMarking
   then "п"
   else if X_utd-lines.IsArtic
   then "о"
   else "-" @
    much COLUMN-LABEL "У" FORMAT "X(2)":U
   X_utd-lines.stts COLUMN-LABEL "Статус" FORMAT "x(20)":U WIDTH 18.13
   X_utd-lines.Price COLUMN-LABEL "Цена!(без НДC)" FORMAT "->>>>>>>>>>99.99":U width 10
   X_utd-lines.Total COLUMN-LABEL "Сумма!(с НДС)" FORMAT "->>>>>>>>>>>>>>99.99":U width 10
   X_utd-lines.TaxRate_ COLUMN-LABEL "Ставка!НДС" FORMAT "X(7)":U
/*   X_utd-lines.fact-qnty COLUMN-LABEL "Остаток" FORMAT "->>>>>>>>>>>>>>9.99":U width 10*/
/*   X_utd-lines.qnty-mark COLUMN-LABEL "Кол-во!марок" FORMAT "->>>9":U*/
   X_utd-lines.UnitCliQnty COLUMN-LABEL "Кол-во в!ед.изм постав-ка" FORMAT "->>>>>9":U
X_utd-lines.UnitCode COLUMN-LABEL "Ед.изм!постав-ка" FORMAT "x(5)":U
   X_utd-lines.PieceTTH COLUMN-LABEL "Штуки ТТН" FORMAT "x(10)":U
   X_utd-lines.PieceFact COLUMN-LABEL "Штуки факт" FORMAT "x(10)":U
   
ENABLE
      X_utd-lines.qnty-scan
/*      X_utd-lines.Quantity*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 147.5 BY 10.88 FIT-LAST-COLUMN.
/*
/* Browse definitions                                                   */
DEFINE BROWSE br-utd-nomark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-utd-nomark d-utd _STRUCTURED
   QUERY br-utd-nomark NO-LOCK DISPLAY
   X_utd-lines.LineNum COLUMN-LABEL "№ п/п" FORMAT ">>>>9":U
   X_utd-lines.gds-code COLUMN-LABEL "Код товара" FORMAT "999999999":U
   X_utd-lines.ProductCode COLUMN-LABEL "Наименование" FORMAT "x(40)":U width 25
   X_utd-lines.gds-name COLUMN-LABEL "Наименование ТН" FORMAT "x(112)":U width 20
   X_utd-lines.Quantity COLUMN-LABEL "Кол-во!в ед.изм ТН" FORMAT "->>,>>9.999":U
   X_utd-lines.Price COLUMN-LABEL "Цена!(без НДС)" FORMAT "->>,>>99.99":U width 10
   X_utd-lines.Total COLUMN-LABEL "Сумма!(с НДС)" FORMAT "->>,>>99.99":U width 10
   X_utd-lines.TaxRate_ COLUMN-LABEL "НДС" format "X(5)"
   X_utd-lines.fact-qnty COLUMN-LABEL "Остаток" FORMAT "->>>>>>>>>>>>>>9.99":U width 10
   X_utd-lines.qnty-mark COLUMN-LABEL "Кол-во!штрих-кодов" FORMAT "->>>9":U
   X_utd-lines.qnty-scan COLUMN-LABEL "Факт.!кол-во" FORMAT "->>>9.999":U
   X_utd-lines.stts COLUMN-LABEL "Статус" FORMAT "X(20)":U WIDTH 18.13
   X_utd-lines.UnitCliQnty COLUMN-LABEL "Кол-во в!ед.изм !постав-ка" FORMAT "->>>>>9":U
   X_utd-lines.UnitCode COLUMN-LABEL "Ед.изм!постав-ка" FORMAT "x(5)":U 
  ENABLE
      X_utd-lines.qnty-scan
      X_utd-lines.Quantity
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 147.5 BY 10.88 FIT-LAST-COLUMN.
    */
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-utd
   b-cancel AT ROW 1 COL 2
   b-exit AT ROW 1 COL 2
   b-save AT ROW 1 COL 17
   b-order AT ROW 1 COL 79.88 WIDGET-ID 288
   b-servis AT ROW 1 COL 99.88 WIDGET-ID 288
   b_error AT ROW 1 COL 114.88 WIDGET-ID 282
/*   B_BarCode AT ROW 1 COL 148.88 RIGHT-ALIGNED WIDGET-ID 354*/
   B_mark AT ROW 1 COL 146.88 RIGHT-ALIGNED WIDGET-ID 80
   c-type AT ROW 2.25 COL 5.13 COLON-ALIGNED WIDGET-ID 240
   f-num-name AT ROW 2.25 COL 53.75 NO-LABEL WIDGET-ID 328
   f-num AT ROW 2.25 COL 64.5 COLON-ALIGNED NO-LABEL WIDGET-ID 284
   f-date-name AT ROW 2.25 COL 81.13 NO-LABEL WIDGET-ID 330
   f-date AT ROW 2.25 COL 85.25 COLON-ALIGNED NO-LABEL WIDGET-ID 286
   f-num-name-2 AT ROW 2.25 COL 110.5 NO-LABEL WIDGET-ID 334
   f-num-2 AT ROW 2.25 COL 112 COLON-ALIGNED NO-LABEL WIDGET-ID 314
   f-date-name-2 AT ROW 2.25 COL 128.63 NO-LABEL WIDGET-ID 332
   f-date-2 AT ROW 2.25 COL 132.75 COLON-ALIGNED NO-LABEL WIDGET-ID 312
   f-obj-name AT ROW 4.38 COL 2.5 NO-LABEL WIDGET-ID 326
   f-obj-type-TH AT ROW 5.21 COL 5.88 RIGHT-ALIGNED NO-LABEL WIDGET-ID 102
   f-obj-code-TH AT ROW 5.21 COL 21.25 RIGHT-ALIGNED NO-LABEL WIDGET-ID 98
   r-obj-TH AT ROW 5.21 COL 22.5 WIDGET-ID 104
   f-obj-name-TH AT ROW 5.21 COL 73.25 RIGHT-ALIGNED NO-LABEL WIDGET-ID 100
   f-gruz AT ROW 5.25 COL 77.13 NO-LABEL WIDGET-ID 310
   f-obj-name-2 AT ROW 6.17 COL 77.25 NO-LABEL WIDGET-ID 270
   FILL-IN-1 AT ROW 6.5 COL 2.5 NO-LABEL WIDGET-ID 242
   f-supp-type-TH AT ROW 7.29 COL 5.88 RIGHT-ALIGNED NO-LABEL WIDGET-ID 96
   f-supp-code-TH AT ROW 7.29 COL 21.25 RIGHT-ALIGNED NO-LABEL WIDGET-ID 86
   r-supp-TH AT ROW 7.29 COL 22.5 WIDGET-ID 92
   f-supp-name-TH AT ROW 7.29 COL 73.25 RIGHT-ALIGNED NO-LABEL WIDGET-ID 88
   f-total AT ROW 8.42 COL 129 COLON-ALIGNED WIDGET-ID 320
   FILL-IN-2 AT ROW 8.5 COL 2.5 NO-LABEL WIDGET-ID 244
   FILL-IN-3 AT ROW 8.5 COL 77.13 NO-LABEL WIDGET-ID 248
   f-contr-TH AT ROW 9.29 COL 21.25 RIGHT-ALIGNED NO-LABEL WIDGET-ID 106
   r-contr-TH AT ROW 9.29 COL 22.5 WIDGET-ID 110
   f-contr-name-TH AT ROW 9.29 COL 73.25 RIGHT-ALIGNED NO-LABEL WIDGET-ID 212
   f-contr-name AT ROW 9.29 COL 77.25 NO-LABEL WIDGET-ID 214
   f-vat AT ROW 9.5 COL 129 COLON-ALIGNED WIDGET-ID 322
   f-status-TH AT ROW 11.17 COL 5.88 NO-LABEL WIDGET-ID 336
   c-status AT ROW 11.17 COL 15 COLON-ALIGNED NO-LABEL WIDGET-ID 238
   f-status-EDI AT ROW 11.17 COL 77.63 NO-LABEL WIDGET-ID 338
   c-status-edi AT ROW 11.17 COL 87.5 COLON-ALIGNED NO-LABEL WIDGET-ID 234
   f-comment AT ROW 12.25 COL 17 NO-LABEL WIDGET-ID 266
   f-wrkr-name AT ROW 12.25 COL 117.25 NO-LABEL WIDGET-ID 346
   f-wrkr AT ROW 12.25 COL 121.25 COLON-ALIGNED NO-LABEL WIDGET-ID 304
   r-wrkr AT ROW 12.25 COL 145.5 WIDGET-ID 302
   f-comment-name AT ROW 12.42 COL 4 NO-LABEL WIDGET-ID 340
   f-agnt-name AT ROW 13.46 COL 118.25 NO-LABEL WIDGET-ID 348
   f-agnt AT ROW 13.46 COL 121.25 COLON-ALIGNED NO-LABEL WIDGET-ID 290
   r-agnt AT ROW 13.46 COL 145.5 WIDGET-ID 298
   f-info AT ROW 13.71 COL 17 NO-LABEL WIDGET-ID 268
   f-info-name AT ROW 14.04 COL 7 NO-LABEL WIDGET-ID 342
   f-boss-name AT ROW 14.67 COL 118.25 NO-LABEL WIDGET-ID 350
   f-boss AT ROW 14.67 COL 121.25 COLON-ALIGNED NO-LABEL WIDGET-ID 294
   r-boss AT ROW 14.67 COL 145.5 WIDGET-ID 300
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
   SIDE-LABELS THREE-D  SCROLLABLE .

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME d-utd
/*   f-bar-code AT ROW 15.67 COL 5.5 NO-LABEL WIDGET-ID 352*/
   f-mark AT ROW 15.67 COL 10 NO-LABEL WIDGET-ID 344
/*   v-bar-code AT ROW 15.67 COL 15 COLON-ALIGNED NO-LABEL WIDGET-ID 34*/
   v-mark AT ROW 15.67 COL 15 COLON-ALIGNED NO-LABEL WIDGET-ID 34
   a-n-c AT ROW 16.71 COL 2.38 NO-LABEL WIDGET-ID 272
   a-n-c-name AT ROW 16.75 COL 39.5 COLON-ALIGNED NO-LABEL WIDGET-ID 278
   R-error AT ROW 16.79 COL 124.63 NO-LABEL WIDGET-ID 316
   R-error-2 AT ROW 16.79 COL 124.63 NO-LABEL WIDGET-ID 316
/*   br-utd-nomark AT ROW 17.75 COL 2.5*/
   br-utd AT ROW 17.83 COL 2.5 WIDGET-ID 100
   F-text AT ROW 28.75 COL 2.5 NO-LABEL WIDGET-ID 224
   b_prov-finish AT ROW 30.5 COL 2.75 WIDGET-ID 70
   b_recheck AT ROW 30.5 COL 39.5 WIDGET-ID 228
   b_correct AT ROW 30.5 COL 76.13 WIDGET-ID 230
   b_anul AT ROW 30.5 COL 112.75 WIDGET-ID 324
   b_back-check AT ROW 31.88 COL 2.75 WIDGET-ID 236
   b_finish AT ROW 31.88 COL 39.5 WIDGET-ID 252
   b_write-cancel AT ROW 31.88 COL 76.13 WIDGET-ID 232
   b_deliv-cancel AT ROW 31.88 COL 112.75 WIDGET-ID 230
   wrkr-name AT ROW 12.25 COL 132.88 COLON-ALIGNED NO-LABEL WIDGET-ID 306
   agnt-name AT ROW 13.46 COL 132.88 COLON-ALIGNED NO-LABEL WIDGET-ID 292
   boss-name AT ROW 14.67 COL 132.88 COLON-ALIGNED NO-LABEL WIDGET-ID 296
   "Доп.инфо:" VIEW-AS TEXT
   SIZE 9.5 BY .67 AT ROW 14.17 COL 7 WIDGET-ID 264
   m-gds-code  AT ROW 16.7 COL 87 
   b_cleaggds AT ROW 16.7 COL 105 
   "Объект:" VIEW-AS TEXT
   SIZE 8 BY .67 AT ROW 4.42 COL 3 WIDGET-ID 182
   "Данные ТН:" VIEW-AS TEXT
   SIZE 11 BY .67 AT ROW 3.75 COL 32.63 WIDGET-ID 180
   RECT-1 AT ROW 30.25 COL 2 WIDGET-ID 64
   R-TH AT ROW 4 COL 2 WIDGET-ID 112
   SPACE(74.51) SKIP(23.07)
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
   SIDE-LABELS THREE-D  SCROLLABLE 
   TITLE "Проверка кодов маркировки":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_utd-lines B "NEW SHARED" ? ub utd-lines
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-utd
   FRAME-NAME UNDERLINE                                                 */
/* BROWSE-TAB br-utd-nomark R-error-2 d-utd */
/* BROWSE-TAB br-utd br-utd-nomark d-utd */
ASSIGN 
   FRAME d-utd:SCROLLABLE = FALSE
   {&browse-name}:num-locked-columns in frame {&frame-name} = 3
   .

/* SETTINGS FOR FILL-IN a-n-c-name IN FRAME d-utd
   NO-ENABLE                                                            */
ASSIGN 
   b-servis:POPUP-MENU IN FRAME d-utd = MENU POPUP-MENU-b-servis:HANDLE.
ASSIGN 
   b-servis:MENU-MOUSE = 1.
ASSIGN 
   br-utd:COLUMN-RESIZABLE IN FRAME d-utd = TRUE.

/*ASSIGN                                                  */
/*   br-utd-nomark:COLUMN-RESIZABLE IN FRAME d-utd = TRUE.*/

/*ASSIGN                                                                   */
/*   X_utd-lines.qnty-scan:COLUMN-READ-ONLY IN BROWSE br-utd-nomark = TRUE.*/
/*   X_utd-lines.Quantity:COLUMN-READ-ONLY IN BROWSE br-utd-nomark = TRUE. */

/* SETTINGS FOR BUTTON B_BarCode IN FRAME d-utd
   ALIGN-R                                                              */
/*ASSIGN                                                         */
/*   B_BarCode:POPUP-MENU IN FRAME d-utd = MENU m_BarCode:HANDLE.*/
/*ASSIGN                                                         */
/*   b_BarCode:MENU-MOUSE = 1.                                   */

ASSIGN 
   b_error:POPUP-MENU IN FRAME d-utd = MENU m_error:HANDLE.
ASSIGN 
   b_error:MENU-MOUSE = 1.
/* SETTINGS FOR BUTTON B_mark IN FRAME d-utd
   ALIGN-R                                                              */
ASSIGN 
   B_mark:POPUP-MENU IN FRAME d-utd = MENU m_marks:HANDLE.
ASSIGN 
   b_mark:MENU-MOUSE = 1.

/* SETTINGS FOR FILL-IN f-agnt-name IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-bar-code IN FRAME d-utd
   NO-ENABLE ALIGN-L                                                    */
/*ASSIGN                                     */
/*   f-bar-code:HIDDEN IN FRAME d-utd = TRUE.*/

/* SETTINGS FOR FILL-IN f-boss-name IN FRAME d-utd
   ALIGN-L                                                              */
ASSIGN 
   f-comment:READ-ONLY IN FRAME d-utd = TRUE.

/* SETTINGS FOR FILL-IN f-comment-name IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-contr-name IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-contr-name-TH IN FRAME d-utd
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-contr-TH IN FRAME d-utd
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-date-name IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-date-name-2 IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-gruz IN FRAME d-utd
   ALIGN-L                                                              */
ASSIGN 
   f-info:READ-ONLY IN FRAME d-utd = TRUE.

/* SETTINGS FOR FILL-IN f-info-name IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-mark IN FRAME d-utd
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
   f-mark:HIDDEN IN FRAME d-utd = TRUE.

/* SETTINGS FOR FILL-IN f-num-name IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-num-name-2 IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-obj-code-TH IN FRAME d-utd
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-obj-name IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR EDITOR f-obj-name-2 IN FRAME d-utd
   NO-ENABLE                                                            */
ASSIGN 
   f-obj-name-2:READ-ONLY IN FRAME d-utd = TRUE.

/* SETTINGS FOR FILL-IN f-obj-name-TH IN FRAME d-utd
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-obj-type-TH IN FRAME d-utd
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-status-EDI IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-status-TH IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-supp-code-TH IN FRAME d-utd
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-supp-name-TH IN FRAME d-utd
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN f-supp-type-TH IN FRAME d-utd
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN F-text IN FRAME d-utd
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-wrkr-name IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME d-utd
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-3 IN FRAME d-utd
   ALIGN-L                                                              */
/*ASSIGN                                     */
/*   v-bar-code:HIDDEN IN FRAME d-utd = TRUE.*/

ASSIGN 
   v-mark:HIDDEN IN FRAME d-utd = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-utd
/* Query rebuild information for BROWSE br-utd
     _TblList          = "Temp-Tables.X_utd-lines"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = Temp-Tables.X_utd-lines.LineNum
     _FldNameList[2]   = Temp-Tables.X_utd-lines.gds-code
     _FldNameList[3]   = Temp-Tables.X_utd-lines.ProductCode
     _FldNameList[4]   = Temp-Tables.X_utd-lines.GdsName
     _FldNameList[5]   = Temp-Tables.X_utd-lines.Quantity
     _FldNameList[6]   = Temp-Tables.X_utd-lines.Price
     _FldNameList[7]   = Temp-Tables.X_utd-lines.Total
     _FldNameList[8]   = Temp-Tables.X_utd-lines.TaxRate
     _FldNameList[9]   = Temp-Tables.X_utd-lines.UnitCode
     _Query            is OPENED
*/  /* BROWSE br-utd */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-utd-nomark
/* Query rebuild information for BROWSE br-utd-nomark
     _TblList          = "X_utd-lines"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.X_utd-lines.LineNum
"LineNum" "№ п/п" ">>>>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.X_utd-lines.gds-code
"gds-code" "Код товара" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.X_utd-lines.ProductCode
"ProductCode" "Наименование" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > Temp-Tables.X_utd-lines.GdsName
"GdsName" "Наименование ТН" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > Temp-Tables.X_utd-lines.Quantity
"Quantity" "Кол-во!прод-ции" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > Temp-Tables.X_utd-lines.Price
"Price" "Цена!(без НДС)" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > Temp-Tables.X_utd-lines.Total
"Total" "Сумма!(с НДС)" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > Temp-Tables.X_utd-lines.TaxRate_
"TaxRate_" "НДС" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > Temp-Tables.X_utd-lines.fact-qnty
"fact-qnty" "Остаток" "->>>>>>>>>>>>>>9.99" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > Temp-Tables.X_utd-lines.qnty-scan
"qnty-scan" "Кол-во" "->>>9.999" "decimal" ? ? ? ? ? ? yes ? no no ? yes no yes "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[11]   > Temp-Tables.X_utd-lines.stts
"stts" "Статус" "X(20)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[12]   > Temp-Tables.X_utd-lines.UnitCliQnty
"UnitCliQnty" "Кол-во в!ед.изм постав-ка" "->>>>>9" "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-utd-nomark */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME a-n-c
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL a-n-c d-utd
ON VALUE-CHANGED OF a-n-c IN FRAME d-utd
   DO:
      assign a-n-c .
      apply "TAB":U to self .
      return no-apply .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME a-n-c-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL a-n-c-name d-utd
ON leave, return OF a-n-c-name IN FRAME d-utd
   DO:
      assign a-n-c-name .
      assign a-n-c .
      case a-n-c:
         when "code" then 
            do:
               find first X_utd-lines where X_utd-lines.gds-code = integer(a-n-c-name) no-error .
               if available (X_utd-lines) then 
               do:
                  recid_utd = recid (X_utd-lines) .
                  br-utd :refresh() no-error.
                  reposition br-utd to recid recid_utd no-error .
               end.   
            end.
         when "name" then 
            do:
               find first X_utd-lines where (X_utd-lines.ProductCode begins a-n-c-name or X_utd-lines.gds-name begins a-n-c-name) no-error .
                
               if available (X_utd-lines) then 
               do:
                  recid_utd = recid (X_utd-lines) .
                  br-utd :refresh() no-error.
                  reposition br-utd to recid recid_utd no-error .
               end.                  
            end.
         when "context" then 
            do:
               find first X_utd-lines where (X_utd-lines.ProductCode MATCHES "*" + a-n-c-name + "*" or X_utd-lines.gds-name MATCHES "*" + a-n-c-name + "*") no-error .
               if available (X_utd-lines) then 
               do:
                  recid_utd = recid (X_utd-lines) .
                  br-utd :refresh() no-error.
                  reposition br-utd to recid recid_utd no-error .
               end.  
            end.         
      end case.
        
      apply "TAB":U to self .
      return no-apply .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-order d-utd
ON CHOOSE OF b-order IN FRAME d-utd /* Просмотр */
DO:
    define buffer buf_order-doc for ub.order-doc. 
    
    find first buf_order-doc where
               buf_order-doc.order-item = mOrderItem
         no-lock no-error.
    if available (buf_order-doc) then 
    do:
       run str/order-doc.w (input parparentproc,
                            input buf_order-doc.doc-code,
                            input {&lookup}
                           )  .
    end.
    else 
    do: 
        message "Заказ не найден."
            view-as alert-box.  
        return no-apply .
    end.
END.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel d-utd
ON choose OF b-cancel IN FRAME d-utd /* Отмена */
   DO:
      if p-mode = {&add-def} and available (buf_utd) then 
      do:
         delete buf_utd .
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-utd
ON choose OF b-exit IN FRAME d-utd /* Выход  */
   DO:

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save d-utd
ON choose OF b-save IN FRAME d-utd /* Ввод  */
   DO:
      define variable v-ok as logical no-undo .
      if p-mode <> {&lookup} and type_mark = 1 then 
      do:                   
         run save_mol. 
      end .  
      if p-mode <> {&lookup} then 
      do:
         /*Сохранение данных*/
         if f-obj-type-th = "" then 
         do:
            message "Не выбран объект"
               view-as alert-box.
            return no-apply .
         end.
         if c-type = 0 then 
         do:
            message "Не выбран тип документа"
               view-as alert-box.
            return no-apply .
         end.  
         if available (buf_utd) then 
         do:
            assign
               buf_utd.obj-code = f-obj-code-TH
               buf_utd.obj-type = f-obj-type-TH
               .
         end.
         if f-contr-TH <> 0 and f-contr-TH <> ? then 
         do:
            assign
               buf_utd.contract-code = f-contr-TH
               .  
         end.
         else 
         do:
            if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB 
/*            or c-type = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
            then 
            do: 
               message "Не заполнен номер договора"
                  view-as alert-box.
               return no-apply .
            end.
         end.  
         if f-obj-code-TH <> 0 and f-obj-code-TH <> ? then 
         do:
            assign
               buf_utd.obj-code = f-obj-code-TH
               buf_utd.obj-type = f-obj-type-TH
               .
         end.  
         else 
         do:
            if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB 
/*            or c-type = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
            then 
            do:
               message "Не заполнен объект"
                  view-as alert-box.
               return no-apply .
            end.
         end.        
         if f-supp-code-TH <> 0 and f-supp-code-TH <> ? then 
         do:
            assign
               buf_utd.cli-code = f-supp-code-TH
               buf_utd.cli-type = f-supp-type-TH
               .
         end.
         else 
         do:
            if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB 
/*            or c-type = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
            then 
            do:
               message "Не заполнен поставщик"
                  view-as alert-box.
               return no-apply .
            end .
         end.  
         if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB 
/*         or c-type = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
         then 
         do:
            if f-num = "" then 
            do:
               message "Заполните номер документа"
                  view-as alert-box.
               return no-apply .
            end.   
  
            assign
               buf_utd.DocumentNumber = f-num
               buf_utd.DocumentDate   = f-date
               buf_utd.sts-edi        = ObjSrv:Env:Utd:Sts:EDI:RecipientResponseStatusNotAccep:KeyIntDB  
               .  
            for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.doc-id = buf_utd.doc-id
               and buf_utd-marking-lines.db-num = buf_utd.db-num,
               first buf_marking EXCLUSIVE-LOCK where buf_marking.mark begins buf_utd-marking-lines.mark:
               buf_marking.sts = Marking:PendingVerification:KeyIntDB .                                                       
            end.                                                        
         end.  
         if c-type = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB and p-mode = {&add-def} then 
         do:
            if buf_utd.DocumentNumber = "" then buf_utd.DocumentNumber = string(buf_utd.doc-id) .
            assign
               buf_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:RecipientResponseStatusNotAccep:KeyIntDB
               .  
         end.   

      end.
    
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-utd
&Scoped-define SELF-NAME br-utd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-utd d-utd
ON ROW-DISPLAY OF br-utd IN FRAME d-utd
   DO:
      define variable vColor as integer no-undo.
      if     buf_utd.Direction   ne 'inbound'
          or buf_utd.EDocType    eq objSrv:Env:Utd:EDocType:returns:KeyIntDB 
      then 
         .
      else if X_utd-lines.stts eq "Проверен" then
      do:
         if type_mark = 1 then 
         do:
            vColor = CYAN_COLOR.
         end.
      end.
      else if X_utd-lines.stts begins  "Ошибка" then 
      do:
         vColor = red_COLOR.
      end.
      if X_utd-lines.DelivCodeMis then 
      do:
         vColor = LIGHT_RED_COLOR.
      end.
      X_utd-lines.LineNum     :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.gds-code    :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.ProductCode :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.Gds-Name    :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.UnitCode    :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.UnitCliQnty :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.Quantity    :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.price       :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.total       :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.TaxRate_    :fgCOLOR in browse br-utd = vColor.
      X_utd-lines.qnty-scan   :fGCOLOR in browse br-utd = vColor.
/*                  X_utd-lines.fact-qnty:fGCOLOR in browse br-utd = vColor.*/
      much                    :fGCOLOR in browse br-utd = vColor.
      mgdsunit                :fGCOLOR in browse br-utd = vColor.
      X_utd-lines.stts        :fGCOLOR in browse br-utd = vColor.
         
   END .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*&Scoped-define BROWSE-NAME br-utd                                                                          */
/*&Scoped-define SELF-NAME br-utd                                                                            */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-utd-nomark d-utd                                              */
/*ON ROW-DISPLAY OF br-utd-nomark IN FRAME d-utd                                                             */
/*   DO:                                                                                                     */
/*      case X_utd-lines.stts:                                                                               */
/*         when "Проверен" then                                                                              */
/*            do:                                                                                            */
/*               if type_mark = 1 then                                                                       */
/*               do:                                                                                         */
/*                  X_utd-lines.LineNum:fGCOLOR in browse br-utd-nomark = CYAN_COLOR.                        */
/*                  X_utd-lines.gds-code:fGCOLOR in browse br-utd-nomark = CYAN_COLOR.                       */
/*                  X_utd-lines.ProductCode:fGCOLOR in browse br-utd-nomark = CYAN_COLOR.                    */
/*                  X_utd-lines.gds-name:fGCOLOR in browse br-utd-nomark = CYAN_COLOR.                       */
/*                  /*                  X_utd-lines.UnitCode:fGCOLOR in browse br-utd-nomark = CYAN_COLOR.*/ */
/*                  X_utd-lines.UnitCliQnty:fGCOLOR in browse br-utd-nomark = CYAN_COLOR.                    */
/*                  X_utd-lines.Quantity:fGCOLOR in browse br-utd-nomark = CYAN_COLOR.                       */
/*                  X_utd-lines.price:fGCOLOR in browse br-utd-nomark = CYAN_COLOR.                          */
/*                  X_utd-lines.total:fGCOLOR in browse br-utd-nomark = CYAN_COLOR.                          */
/*                  X_utd-lines.TaxRate_:fgCOLOR in browse br-utd-nomark = CYAN_COLOR.                       */
/*                  X_utd-lines.qnty-scan:fGCOLOR in browse br-utd-nomark = CYAN_COLOR.                      */
/*                  X_utd-lines.fact-qnty:fGCOLOR in browse br-utd-nomark = CYAN_COLOR.                      */
/*                  /*                  X_utd-lines.qnty-mark:fGCOLOR in browse br-utd-nomark = CYAN_COLOR.*/*/
/*                  X_utd-lines.stts:fGCOLOR in browse br-utd-nomark = CYAN_COLOR.                           */
/*               end.                                                                                        */
/*            end.                                                                                           */
/*         when "Ошибка" then                                                                                */
/*            do:                                                                                            */
/*               X_utd-lines.LineNum:fGCOLOR in browse br-utd-nomark = red_COLOR.                            */
/*               X_utd-lines.gds-code:fGCOLOR in browse br-utd-nomark = red_COLOR.                           */
/*               X_utd-lines.ProductCode:fGCOLOR in browse br-utd-nomark = red_COLOR.                        */
/*               X_utd-lines.gds-name:fGCOLOR in browse br-utd-nomark = red_COLOR.                           */
/*               /*               X_utd-lines.UnitCode:fGCOLOR in browse br-utd-nomark = red_COLOR.*/        */
/*               X_utd-lines.UnitCliQnty:fGCOLOR in browse br-utd-nomark = red_COLOR.                        */
/*               X_utd-lines.Quantity:fGCOLOR in browse br-utd-nomark = red_COLOR.                           */
/*               X_utd-lines.price:fGCOLOR in browse br-utd-nomark = red_COLOR.                              */
/*               X_utd-lines.total:fGCOLOR in browse br-utd-nomark = red_COLOR.                              */
/*               X_utd-lines.TaxRate_:fGCOLOR in browse br-utd-nomark = red_COLOR.                           */
/*               X_utd-lines.qnty-scan:fGCOLOR in browse br-utd-nomark = red_COLOR.                          */
/*               X_utd-lines.fact-qnty:fGCOLOR in browse br-utd-nomark = red_COLOR.                          */
/*               /*               X_utd-lines.qnty-mark:fGCOLOR in browse br-utd-nomark = red_COLOR.*/       */
/*               X_utd-lines.stts:fGCOLOR in browse br-utd-nomark = red_COLOR.                               */
/*            end.                                                                                           */
/*      end case.                                                                                            */
/*   END .                                                                                                   */
/*                                                                                                           */
/*/* _UIB-CODE-BLOCK-END */                                                                                  */
/*&ANALYZE-RESUME                                                                                            */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-utd d-utd
ON VALUE-CHANGED OF br-utd IN FRAME d-utd
   DO:  
      f-info = "" .
      define variable vRecKey          as character no-undo.
      define variable vRecKey-line     as character no-undo.
      define variable vRecKey-markLine as character no-undo.
      if available (X_utd-lines) and available (buf_utd) then 
      do:
         br-utd :refresh() no-error .
         run gen-key-rec ("utd", 
            input  buffer buf_utd:handle, 
            output vRecKey).

         run gen-key-rec ("utd-lines", 
            input  buffer X_utd-lines:handle, 
            output vRecKey-line).
         mRecKey-line = vRecKey-line.
         vRecKey-markLine = replace(vRecKey-line,"utd-lines","utd-marking-lines") + {&delim-key}.
         menu-item m_error-lines:sensitive in menu m_error = yes.
         for each buf_utd-err no-lock where buf_utd-err.doc-id = X_utd-lines.doc-id
            and buf_utd-err.db-num = X_utd-lines.db-num
            and (buf_utd-err.reckey = vRecKey-line
            or buf_utd-err.reckey begins vRecKey-markLine or buf_utd-err.reckey = vRecKey):

            /*        menu-item m_error-lines:sensitive in menu m_error = yes.*/
            if f-info = "" then f-info = GetTextError(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj) + {&new-line} no-error.
            else 
            do:
               if length (f-info) >= 2000 then leave .
               f-info = f-info + GetTextError(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj) + {&new-line} no-error.
            end.

         end.
         line-num-error = X_utd-lines.LineNum .
         if    ((    (not v-BarCode or X_utd-lines.isSelect)
                 and not X_utd-lines.isArtic)
            or can-find (first tt-utd-lines-filtr where tt-utd-lines-filtr.db-num   eq X_utd-lines.db-num
                                                    and tt-utd-lines-filtr.doc-id   eq X_utd-lines.doc-id
                                                    and tt-utd-lines-filtr.linenum  eq X_utd-lines.LineNum
                                                    and tt-utd-lines-filtr.bar-code eq m-gds-code))
            and f-info eq ""
            and p-mode <> {&lookup}
            and mflagscan
            and not X_utd-lines.isMarking
            and not X_utd-lines.isVarWeight
            /*   and X_utd-lines.stts ne "Ошибка"  */
         then 
         do:
            X_utd-lines.qnty-scan:COLUMN-READ-ONLY IN BROWSE br-utd = FALSE.
         end.
         else 
         do:
            X_utd-lines.qnty-scan:COLUMN-READ-ONLY IN BROWSE br-utd = TRUE.
         end.
      end.  
      display f-info with frame {&frame-name} .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-utd d-utd
ON row-leave OF br-utd IN FRAME d-utd
   DO:
      define variable kk as decimal no-undo .
      if available (X_utd-lines) then 
      do:
         /*      if X_utd-lines.marking utd-mark
            then return.*/
         
         if X_utd-lines.isMarking then do:
/*            kk = X_utd-lines.Quantity .                                                                    */
/*            assign                                                                                         */
/*               browse br-utd X_utd-lines.Quantity                                                          */
/*               .                                                                                           */
/*                                                                                                           */
/*            find first ub.utd-lines-attr exclusive-lock where ub.utd-lines-attr.db-num = X_utd-lines.db-num*/
/*               and ub.utd-lines-attr.doc-id = X_utd-lines.doc-id                                           */
/*               and ub.utd-lines-attr.LineNum = X_utd-lines.lineNum                                         */
/*               and ub.utd-lines-attr.attr-code = "QuantityBarCode"                                         */
/*               no-error .                                                                                  */
/*            if not available (ub.utd-lines-attr) then                                                      */
/*            do:                                                                                            */
/*               create ub.utd-lines-attr .                                                                  */
/*               assign                                                                                      */
/*                  ub.utd-lines-attr.db-num    = X_utd-lines.db-num                                         */
/*                  ub.utd-lines-attr.doc-id    = X_utd-lines.doc-id                                         */
/*                  ub.utd-lines-attr.LineNum   = X_utd-lines.lineNum                                        */
/*                  ub.utd-lines-attr.attr-code = "QuantityBarCode"                                          */
/*                  .                                                                                        */
/*            end.                                                                                           */
/*            ub.utd-lines-attr.attr-value = string(X_utd-lines.Quantity) .                                  */
         end.
         else do:
            kk = X_utd-lines.qnty-scan .
            assign
               browse br-utd X_utd-lines.qnty-scan
               .         
            if X_utd-lines.stts begins "Ошибка" and kk <> X_utd-lines.qnty-scan then 
            do:
               message "Приемка товара не возможна"
                  view-as alert-box.
               X_utd-lines.qnty-scan = kk.
               assign
                  browse br-utd X_utd-lines.qnty-scan
                  .
               if X_utd-lines.Quantity = X_utd-lines.qnty-scan then X_utd-lines.stts = "Проверен" .
               else X_utd-lines.stts = "Ожидает проверку" .
         
               recid_utd = recid (X_utd-lines) .
               run mark-temp (?).               
               {&OPEN-QUERY-br-utd}             
               br-utd :refresh() no-error.
               reposition br-utd to recid recid_utd no-error .                  
               apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.  
               return .
               /*                                                      */
               /*         recid_utd = recid (X_utd-lines) .            */
               /*         kk = X_utd-lines.qnty-scan .                 */
               /*         assign                                       */
               /*            browse br-utd-nomark X_utd-lines.qnty-scan*/
               .
            end.
            else if X_utd-lines.stts begins "Ошибка" then 
               do:
                  return .
               end.  
            if (not X_utd-lines.isWeight) and ROUND(X_utd-lines.qnty-scan,0) <> X_utd-lines.qnty-scan
            then do:
                message "Данный товар не может иметь дробное количество"
                view-as alert-box.
                /*X_utd-lines.qnty-scan = kk.
                assign
                  browse br-utd X_utd-lines.qnty-scan
                  .
                recid_utd = recid (X_utd-lines) .               
                {&OPEN-QUERY-br-utd}             
                br-utd :refresh() no-error.
                reposition br-utd-nomark to recid recid_utd no-error .                  
                apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
                return .*/
                return no-apply.
            end.     
            if kk > X_utd-lines.qnty-scan and kk = X_utd-lines.Quantity then 
            do:
               message
           "Вы точно хотите уменьшить количество по строке?"
           view-as alert-box question buttons yes-no update choice as logical  .
             if choice = false
             then do:
                X_utd-lines.qnty-scan = kk.
               assign
                  browse br-utd X_utd-lines.qnty-scan
                  .
               if X_utd-lines.Quantity = X_utd-lines.qnty-scan then X_utd-lines.stts = "Проверен" .
               else X_utd-lines.stts = "Ожидает проверку" .
         
                  recid_utd = recid (X_utd-lines) .
                  run mark-temp (?).
                  {&OPEN-QUERY-br-utd}             
                  br-utd :refresh() no-error.
                  reposition br-utd to recid recid_utd no-error .
                  apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
                  return .
               end.
            end.
            if kk < X_utd-lines.qnty-scan and kk = X_utd-lines.Quantity then 
            do:
               message "По строке введено максимальное значение. Изменить его в большую сторону невозможно."
                  view-as alert-box.
               X_utd-lines.qnty-scan = kk.
               /* assign
                  browse br-utd-nomark X_utd-lines.qnty-scan
                  . */
               if X_utd-lines.Quantity = X_utd-lines.qnty-scan then X_utd-lines.stts = "Проверен" .
               else X_utd-lines.stts = "Ожидает проверку" .
         
               recid_utd = recid (X_utd-lines) .
               run mark-temp (?).
               {&OPEN-QUERY-br-utd}             
               br-utd :refresh() no-error.
               reposition br-utd to recid recid_utd no-error .
               apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
               return .         
            end.
            if X_utd-lines.sts = Marking:Checked_:KeyIntDB then 
            do:
               message "Товар проверен"
                  view-as alert-box.
               X_utd-lines.qnty-scan = kk.
               assign
                  browse br-utd X_utd-lines.qnty-scan
                  .
               if X_utd-lines.Quantity = X_utd-lines.qnty-scan then X_utd-lines.stts = "Проверен" .
               else X_utd-lines.stts = "Ожидает проверку" .
                                                                            
               recid_utd = recid (X_utd-lines) .
               run mark-temp (?).
               {&OPEN-QUERY-br-utd}             
               br-utd :refresh() no-error.
               reposition br-utd-nomark to recid recid_utd no-error .                  
               apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
               return .
            end.   
            if X_utd-lines.qnty-scan > X_utd-lines.Quantity then 
            do:
               message "Введённое количество не может быть больше количества по строке. Количество уменьшено."
                  view-as alert-box.
               X_utd-lines.qnty-scan = X_utd-lines.Quantity.
               if X_utd-lines.Quantity = X_utd-lines.qnty-scan then X_utd-lines.stts = "Проверен" .
               else X_utd-lines.stts = "Ожидает проверку" .
         
               recid_utd = recid (X_utd-lines) .
               br-utd :refresh() no-error.
               reposition br-utd to recid recid_utd no-error .                  
               apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
            end.

            find first buf_utd-marking-lines where buf_utd-marking-lines.doc-id = p-doc-id and
               buf_utd-marking-lines.db-num = p-db-num and
               buf_utd-marking-lines.lineNum = X_utd-lines.lineNum no-error .
            if available (buf_utd-marking-lines) then 
            do:
               if X_utd-lines.qnty-scan = X_utd-lines.Quantity then 
               do:
                  buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB .
               end.
            end.
            if X_utd-lines.Quantity = X_utd-lines.qnty-scan then X_utd-lines.stts = "Проверен" .
            else X_utd-lines.stts = "Ожидает проверку" .
            find first ub.utd-lines-attr exclusive-lock where ub.utd-lines-attr.db-num = p-db-num
               and ub.utd-lines-attr.doc-id = p-doc-id 
               and ub.utd-lines-attr.LineNum = X_utd-lines.lineNum
               and ub.utd-lines-attr.attr-code = "QuantityBarCode" 
               no-error .
            if not available (ub.utd-lines-attr) then 
            do:
               create ub.utd-lines-attr .
               assign
                  ub.utd-lines-attr.db-num    = p-db-num
                  ub.utd-lines-attr.doc-id    = p-doc-id
                  ub.utd-lines-attr.LineNum   = X_utd-lines.lineNum 
                  ub.utd-lines-attr.attr-code = "QuantityBarCode"
                  .
            end.   
            if dec(ub.utd-lines-attr.attr-value) ne X_utd-lines.qnty-scan
            then do:
               ub.utd-lines-attr.attr-value = string(X_utd-lines.qnty-scan) .
               if length(m-gds-code) eq 14
               then  
                  setattrUtdlines(p-db-num, p-doc-id,X_utd-lines.lineNum, "ScanGtin",m-gds-code ).
               recid_utd = recid (X_utd-lines).     
               run mark-temp (?).
               {&OPEN-QUERY-br-utd}
               br-utd :refresh() no-error.
               reposition br-utd to recid recid_utd no-error .
               apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
            end.
         end.
         
      /*
       if not v-BarCode then 
       do:
          X_utd-lines.qnty-scan:COLUMN-READ-ONLY IN BROWSE br-utd-nomark = FALSE.
       end.
       else 
       do:
          X_utd-lines.qnty-scan:COLUMN-READ-ONLY IN BROWSE br-utd-nomark = TRUE.
       end.  
        */
      end.  

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME b_cleaggds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_cleaggds d-utd
ON CHOOSE OF b_cleaggds IN FRAME d-utd /* сброс */
   DO:
      b_cleaggds:visible = no.
      m-gds-code:visible = no.
      m-gds-code = ?.
      {&OPEN-QUERY-br-utd}
      apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
           
   end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&Scoped-define SELF-NAME b_back-check
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_back-check d-utd
ON CHOOSE OF b_back-check IN FRAME d-utd /* Продолжить проверку */
   DO:
      if c-status = ObjSrv:Env:Utd:Sts:TH:LoadError:KeyIntDB then 
      do:
         
         c-status = if CheckMarkUtd (p-db-num,p-doc-id)
            then ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB 
            else objSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB .
      end.  
      else if c-status = ObjSrv:Env:Utd:Sts:TH:LackOfMarkingCodesInCirculation:KeyIntDB then 
         do:
            c-status = ObjSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB .
         end.  
         else 
         do:
            c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB .
         end. 
      buf_utd.sts = integer(c-status).
      buf_utd.comment = "" .
      f-comment:screen-value = "" .
      ReCheckload(p-db-num,p-doc-id,no).
   
      c-status = buf_utd.sts.
      display c-status with frame {&frame-name} .
     
      display f-info c-status c-status-edi f-comment with frame {&frame-name} .
      run enable_UI in this-procedure .
      run mark-temp (?).
      {&OPEN-QUERY-br-utd}
      disable          
         b_recheck
         b_anul
         b_write-cancel
         b_finish
         b_prov-finish
         b_back-check
         b_deliv-cancel
         with frame {&frame-name} .  
      run enable_BUTTON in this-procedure .   
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b_correct
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_correct d-utd
ON CHOOSE OF b_correct IN FRAME d-utd /* Запрос на изменение */
   DO:
      define variable v-ok            as logical no-undo . 
      define variable v-write-correct as logical no-undo init false.
      define buffer cancel_utd-marking-lines for ub.utd-marking-lines .
      define buffer cancel_utd-lines         for x_utd-lines .
      define buffer cancel_marking           for ub.marking .
      
      block_utd-line:
      for each cancel_utd-lines where cancel_utd-lines.db-num eq p-db-num
         and cancel_utd-lines.doc-id eq p-doc-id
      no-lock:
         if not cancel_utd-lines.isMarking
         then do:
            define variable vqnty as decimal no-undo.
            vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
            if vqnty > 0
               then 
            do:
               v-write-correct = true .
               leave block_utd-line.
            end.
         end.
         else do:
            for each cancel_utd-marking-lines no-lock where cancel_utd-marking-lines.doc-id = p-doc-id 
                                                        and cancel_utd-marking-lines.db-num = p-db-num 
                                                        and cancel_utd-marking-lines.sts <> Marking:MarkError:KeyIntDB
                                                        and cancel_utd-marking-lines.sts <> Marking:GrayZone:KeyIntDB: 
               v-write-correct = true .
               leave block_utd-line.
         end.
         end.
      end.
      
      if not v-write-correct then 
      do:
            
         message "Все марки УПД не прошли проверку в ГИС МТ, принять товары в соответствии с данным УПД невозможно." skip
                 " И " skip
                 "По всем штрих-кодам УПД не введено колличество принятого товара." skip
            "Нажмите Отказать в поставке"
            view-as alert-box.
            
      end.   
      else 
      do:
         run ref/dialog-upd.w (input buf_utd.comment, input buf_utd.db-num, input buf_utd.doc-id, output v-comment, output v-ok) no-error.
         if  error-status:error then 
         do: 
            return return-value .
         end.
         if v-ok then 
         do:
            buf_utd.comment = replace ( buf_utd.comment,{&delim-cmd}, ", "). 
            if buf_utd.comment <> "" then buf_utd.comment = buf_utd.comment + ", " + v-comment .
            else  buf_utd.comment = v-comment .
            f-comment = buf_utd.comment .
            display f-comment with frame {&frame-name} . 
  
            if available (buf_utd) then 
            do:
               if p-connect <> ? then 
               do:
          
                  run Sendansver( buf_utd.db-num, buf_utd.doc-id, "CorrectionRequest", v-comment) no-error.    
                  if  error-status:error then 
                  do: 
                     message return-value
                          view-as alert-box.
                     return return-value .
                  end.
               end.
               else  
                  assign
                     buf_utd.sts     = ObjSrv:Env:Utd:Sts:TH:CorrectionRequested:KeyIntDB 
                     buf_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:SignatureAdjustment:KeyIntDB 
                     .
               c-status = buf_utd.sts.
               c-status-edi = buf_utd.sts-edi.
            end.
            display c-status c-status-edi with frame {&frame-name} .
            run enable_UI in this-procedure .
            disable          
               b_anul
               b_recheck
               b_write-cancel
               b_prov-finish
               b_finish
               b_prov-finish
               b_back-check
               b_deliv-cancel
               with frame {&frame-name} .
         end.   
         
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b_anul
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_anul d-utd
ON CHOOSE OF b_anul IN FRAME d-utd /* Аннулировать */
   DO:
      c-status = ObjSrv:Env:Utd:Sts:TH:Canceled:KeyIntDB .
      buf_utd.sts = integer(c-status).
     
            display f-info c-status c-status-edi f-comment with frame {&frame-name} .
            run enable_UI in this-procedure .
            run mark-temp (?).
/*            if upd_mark*/
/*               then    */
/*            do:        */
               {&OPEN-QUERY-br-utd}
/*            end.                          */
/*            else                          */
/*            do:                           */
/*               {&OPEN-QUERY-br-utd-nomark}*/
/*            end.                          */
      disable          
         b_recheck
         b_anul
         b_write-cancel
         b_prov-finish
         b_finish
         b_back-check
         b_deliv-cancel
         with frame {&frame-name} .  
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_error-utd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_error-utd m_error
ON CHOOSE OF MENU-ITEM m_error-utd /* Ошибки */
   DO:
      define variable v-ok as logical no-undo . 
    
      run ref/dialog-error.w (input buf_utd.db-num, input buf_utd.doc-id, input "" , input 0) .
      if  error-status:error then 
      do: 
         return return-value .
      end.
      run enable_UI in this-procedure .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_error-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_error-lines m_error
ON CHOOSE OF MENU-ITEM m_error-lines /* Ошибки товара */
   DO:
      define variable v-ok as logical no-undo . 
   
      run ref/dialog-error.w (input buf_utd.db-num, input buf_utd.doc-id, input mRecKey-line, input line-num-error ) .
      if  error-status:error then 
      do: 
         return return-value .
      end.
      run enable_UI in this-procedure .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b_finish
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_finish d-utd
ON CHOOSE OF b_finish IN FRAME d-utd /* Ввод в оборот */
   DO:
      define variable Log-Res  as logical no-undo.
      define variable quest-ok as logical no-undo .
      /*Проверка прав */
      { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_mark_befree':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  true
  log-res
}
 
      if available (buf_utd) and log-res then 
      do:
         message "Уверены, что продажи по продукции закрыты?"
               view-as alert-box question buttons yes-no update quest-ok.            
         if quest-ok then 
         do:
            run utl/utd-mark-introduce.p (input buf_utd.db-num, input buf_utd.doc-id) no-error.
            if  error-status:error then 
            do: 
               return return-value .
            end.
            assign
               c-status     = buf_utd.sts
               c-status-edi = buf_utd.sts-edi 
               .

         end.
      end.
      run enable_UI in this-procedure .
      disable          
         b_recheck
         b_anul
         b_write-cancel
         b_prov-finish
         b_finish
         b_prov-finish
         b_back-check
         b_deliv-cancel
         with frame {&frame-name} .  
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_marks-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_marks-lines m_marks
ON CHOOSE OF menu-item m_marks-lines  /* Марки */
   DO:
      apply "entry" to br-utd in frame {&frame-name}.
      if available (X_utd-lines) then 
      do:
         recid_utd = recid(X_utd-lines) .
         run temp-mark (input 1) .  
         if available (tt-marking-lines) then 
         do:
            run str/mark_browse.w (input parparentproc,
               input-output table tt-marking-lines by-reference,
               input p-mode,
               input "Марки по: " + EdoTypeName(buf_utd.EDocType) + " " + buf_utd.DocumentNumber + " по товару " + string(X_utd-lines.gds-code) + " " + GdsName(X_utd-lines.gds-code),
               input type_mark,
               input "" /*тип продукции*/
               ) no-error .
            { gbl/brwrepos.i
              &line-num= 5
            }
            empty temp-table tt-marking-lines .
            run mark-temp (?).
            {&OPEN-QUERY-br-utd}
            run enable_BUTTON .
            if c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then 
            do:
               find first X_utd-lines no-lock where X_utd-lines.stts <> "Проверен" no-error .
               if available (X_utd-lines) then 
               do:
                  F-text = "                      Просканируйте марку/штрих-код" .
                  f-text:screen-value = "" .
                  display F-text with frame {&frame-name} .
               end.
               else 
               do:
                  F-text = "" .
                  f-text:screen-value = "" .
                  display F-text with frame {&frame-name} .
               end.  
            end.
         end.
         else 
         do:
            message "Нет марок"
               view-as alert-box.
         end.    
         br-utd :refresh() no-error .
         apply "VALUE-CHANGED" to br-utd in frame {&frame-name}.
         apply "entry" to br-utd in frame {&frame-name}.
       
         reposition br-utd to recid recid_utd no-error .

      end.
      else message "Нет марок"
            view-as alert-box.  
      return no-apply .

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_marks-utd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_marks-utd m_marks
ON CHOOSE OF menu-item m_marks-utd /* Марки по документу */
   DO:
      apply "entry" to br-utd in frame {&frame-name}.
      recid_utd = recid (X_utd-lines) .
      run temp-mark (input 2) .
      if available (tt-marking-lines) then 
      do:
         run str/mark_browse.w (input parparentproc,
            input-output table tt-marking-lines by-reference,
            input p-mode,
            input "Марки по документу: " + EdoTypeName(buf_utd.EDocType) + " " + buf_utd.DocumentNumber,
            input type_mark,
            input "" /*тип продукции*/
            ) no-error .
         empty temp-table tt-marking-lines .
         run mark-temp (?).
         run enable_BUTTON .
         if c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then 
         do:
            find first X_utd-lines no-lock where X_utd-lines.stts <> "Проверен" no-error .
            if available (X_utd-lines) then 
            do:
               F-text = "                    Просканируйте марку/штрих-код" .
               f-text:screen-value = "" .
               display F-text with frame {&frame-name} .
            end.
            else 
            do:
               F-text = "" .
               f-text:screen-value = "" .
               display F-text with frame {&frame-name} .
            end.  
         end.
         br-utd :refresh () no-error.
         apply "VALUE-CHANGED" to br-utd in frame {&frame-name}.
         apply "entry" to br-utd in frame {&frame-name}.
       
         reposition br-utd to recid recid_utd no-error .
      end.
      else 
      do:
         message "Нет марок по документу УПД"
            view-as alert-box.
      end.    
      run enable_UI in this-procedure .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b_prov-finish
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_prov-finish d-utd
ON CHOOSE OF b_prov-finish IN FRAME d-utd /* Проверка завершена */
   DO:
      define variable v-ok        as logical no-undo .
      define variable v-check     as logical no-undo .
      define variable v-qnty-mark as integer no-undo .
      define variable v-fact-qnty as integer no-undo .
      define buffer bf_utd-marking-lines for ub.utd-marking-lines .
      define buffer bf_utd-lines-attr    for ub.utd-lines-attr .
      define buffer bf_utd-lines         for X_utd-lines .
      define buffer bf_marking           for ub.marking .
      define variable v-not-mark as integer no-undo .
      define variable vPawd as character no-undo.
      run adm\ask-pswd.w ("Введите пароль пользователя, осуществляющего обработку электронного документа, с целью подтверждения соответствия фактически полученного от поставщика количества товара и количества указанного в системе.",output vPawd).
      if  vPawd eq ?
      then
         return no-apply.
     
      If vPawd ne encode(g#passwd)
         then 
      do:
         message "Введен неправильный пароль"
            view-as alert-box.
         return no-apply.
      end.
      
      if c-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or c-type = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB then 
      do: 
         define variable vFlagErrorMarkCheck as logical no-undo.
         find first buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd.db-num and 
            buf_utd-marking-lines.doc-id = buf_utd.doc-id and buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB no-error .
         if not available (buf_utd-marking-lines) then 
         do:
            vFlagErrorMarkCheck = yes.
         end.   
         define variable vFlagErrorBarCheck as logical no-undo.
            
         find first X_utd-lines no-lock where X_utd-lines.db-num = buf_utd.db-num and X_utd-lines.doc-id = buf_utd.doc-id and
            X_utd-lines.qnty-scan ne 0 no-error .
         if not available (X_utd-lines) then 
         do:
            vFlagErrorBarCheck = yes.
         end.
         if      vFlagErrorMarkCheck
            and  vFlagErrorBarCheck
         then do:
            message "Ни одна марка не просканирована и ни один штрих-код не просканирован. Просканируйте штрих-коды/марки или откажите в поставке."
                  view-as alert-box.
               return no-apply .
         end.

      end.
      if c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then 
      do:
         /*Проверка МОЛ проверяется только в статусе Ожидает проверку*/
         run check_mol (output v-check).
         if not v-check then return no-apply .
         run save_mol.
      end.
      for first X_utd-lines no-lock where 
                                           X_utd-lines.db-num     eq buf_utd.db-num 
                                      and  X_utd-lines.doc-id     eq buf_utd.doc-id
                                      and  X_utd-lines.Quantity   ne X_utd-lines.qnty-scan
      :
         v-ok = yes .
      end.
      for each buf_utd-err where buf_utd-err.CodeErr = "NotMarkForLine" and
         buf_utd-err.db-num = p-db-num and
         buf_utd-err.doc-id = p-doc-id:
         v-ok = yes . 
      end.
      if v-ok and (c-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or c-type = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB) then 
      do:  
         run ref/dialog-ok.w (output v-comment
            ) no-error .
         if v-comment = "" then return NO-APPLY .  
      end .  
      /*Если тип УПД*/
    
      if c-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or c-type = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB then 
      do:
         /*Если не допоставка статус - Несоответствие кодов маркировки при поставке */
         if v-ok then c-status = ObjSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB . 
         /*Если все хорошо - Требует подписания*/
         else c-status = ObjSrv:Env:Utd:Sts:TH:SignatureRequired:KeyIntDB .
         for each bf_utd-lines where bf_utd-lines.db-num eq buf_utd.db-num
                                 and bf_utd-lines.doc-id eq buf_utd.doc-id
                                 
         no-lock:
            if bf_utd-lines.isMarking
            then do:
               /*Перевод статуса марок*/
               for each bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num  = bf_utd-lines.db-num 
                                                       and bf_utd-marking-lines.doc-id  = bf_utd-lines.doc-id
                                                       and bf_utd-marking-lines.LineNum = bf_utd-lines.LineNum,
               first buf_marking exclusive-lock where buf_marking.mark = bf_utd-marking-lines.mark:
                  case bf_utd-marking-lines.sts:
                     when Marking:Checked_:KeyIntDB then 
                        do: /*todo*/
                           if buf_marking.sts <> Marking:MarkError:KeyIntDB and buf_marking.sts <> Marking:Ungrouped:KeyIntDB and
                              not (can-do(Marking:Sale_Return_Wait,string(buf_marking.sts)) or
                                   can-do(Marking:Doc_Status,string(buf_marking.sts))) 
                           then
                              buf_marking.sts = Marking:Checked_:KeyIntDB .
                        end.
                     when Marking:MarkError:KeyIntDB or 
                     when Marking:SaleLock:KeyIntDB or 
                     when Marking:SaleWaitLock:KeyIntDB or 
                     when Marking:ReturnLock:KeyIntDB or 
                     when Marking:ReturnWaitLock:KeyIntDB or
                     when Marking:Ungrouped:KeyIntDB then 
                        do:
                        end.    
                     otherwise 
                     do:
                        if buf_marking.sts <> Marking:MarkError:KeyIntDB then  
                           buf_marking.sts = Marking:NotAvailable:KeyIntDB .
                     end.  
                  end.  
               end.
            end.
            else do:
               if bf_utd-lines.Quantity <> bf_utd-lines.qnty-scan then 
               do:
                  setattrUtdlines(p-db-num,p-doc-id,bf_utd-lines.LineNum,"NoQuantityBarCode",string(bf_utd-lines.Quantity - bf_utd-lines.qnty-scan)).
               end.   
               
            end.
         end.
          
      end.
      else 
      do:  
         /*Если тип АКТ*/
         if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB 
/*         or c-type = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
         then 
         do:
            /*Статус - подтвержден*/
            c-status = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB .
         end.
         /*Если тип - первоначальный ввод*/
         if c-type =  objSrv:Env:Utd:EDocType:Introduce:KeyIntDB then 
         do: 
            /*Поменять статус*/
            /*Статус - Ожидает подтверждения МОТП*/
            c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingConfirmation:KeyIntDB .
            /*Сохраняем кол-во не маркированной продукции*/
            for each bf_utd-lines no-lock where bf_utd-lines.doc-id = buf_utd.doc-id and
               bf_utd-lines.db-num = buf_utd.db-num:
               v-qnty-mark = 0 .
               v-fact-qnty = 0 .
               for each bf_utd-marking-lines no-lock where bf_utd-marking-lines.doc-id = bf_utd-lines.doc-id and
                  bf_utd-marking-lines.db-num = bf_utd-lines.db-num and
                  bf_utd-marking-lines.gds-code = bf_utd-lines.gds-code and
                  bf_utd-marking-lines.LineNum = bf_utd-lines.LineNum and
                  bf_utd-marking-lines.doc-level = 1,
                  first bf_marking no-lock where bf_marking.mark = bf_utd-marking-lines.mark:
                  /*Кол-во марок по товару*/
                  v-qnty-mark = v-qnty-mark + bf_marking.box-qnty .
               end.  
               for first bf_utd-lines-attr exclusive-lock where bf_utd-lines-attr.db-num = bf_utd-lines.db-num and
                  bf_utd-lines-attr.doc-id = bf_utd-lines.doc-id and
                  bf_utd-lines-attr.LineNum = bf_utd-lines.LineNum and
                  bf_utd-lines-attr.attr-code = "utd-fact-qnty":
                  /*Кол-во всего товара*/
                  v-fact-qnty = integer(bf_utd-lines-attr.attr-value) . 
               end.
               /*Кол-во не маркированного товара*/
               v-not-mark = v-fact-qnty - v-qnty-mark .
               setattrUtdlines(bf_utd-lines.db-num,bf_utd-lines.doc-id,bf_utd-lines.LineNum,"NoMarking",string(v-not-mark)).      
                                                                            
            end.   
         
         end.
      end.
      buf_utd.sts = integer(c-status).
/*      if not upd_mark then
скорее всего накладные надо создать здесь*/
      do:
         define variable v-check-db-num  as integer   no-undo .
         define variable v-check-user-id as character no-undo . 
         { gbl/getcurus.i
             v-check-db-num
             v-check-user-id
             no-error
           }
         run ibs\th\str\utd\adaputd.p
            (buf_utd.db-num, /*DocumentID*/
            buf_utd.doc-id, /* OrganizationId*/
            v-check-user-id /*User-Id*/
            ) no-error .
         def var v-msg as char no-undo.
         if not error-status:error
            then 
         do:
            v-msg = "".
            if return-value matches "*ошибка*"
               then v-msg = substitute ('Документ № &1 от &2. Сформирована ПН: &3. &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate) , buf_utd.doc-code, return-value).
            else do:
               if     buf_utd.sts ne objSrv:Env:Utd:Sts:TH:Confirmed           :KeyIntDB
               then    v-msg = substitute ('Получен УПД. Документ № &1 от &2. Сформирована ПН: &3. &5 &6 &4', 
                                           buf_utd.DocumentNumber, 
                                           string (buf_utd.DocumentDate) , 
                                           buf_utd.doc-code, 
                                           return-value, 
                                           if ChecknotMarkUtd(buf_utd.db-num,buf_utd.doc-id) then "Немаркированные товары можно продавать на кассе. " else "",
                                           if CheckMarkUtd(buf_utd.db-num,buf_utd.doc-id) then "Продажа маркированных товаров из данной поставки запрещена до получения дополнительного уведомления. " else "").
               else if     buf_utd.sts eq objSrv:Env:Utd:Sts:TH:Confirmed           :KeyIntDB
                       and CheckMarkUtd(buf_utd.db-num,buf_utd.doc-id) 
               then    v-msg = substitute ('Получен УПД. Документ № &1 от &2. Сформирована ПН: &3. &5 &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate) , buf_utd.doc-code, return-value, "Маркированные товары данной поставки можно продавать на кассе").
            end.
         end.
         else v-msg = substitute ('Документ: &1 от &2. Ошибка при формировании ПН. &3. &4', buf_utd.DocumentNumber, string (buf_utd.DocumentDate), trim(return-value, ".")).
         if v-msg ne ""
         then
            message v-msg 
               view-as alert-box.
         
      end. 
      run enable_UI in this-procedure .
      buf_utd.comment = v-comment .
      f-comment = v-comment .
    
      display f-comment c-status with frame {&frame-name}.
      apply "choose" to b-save in frame {&frame-name}. 
    
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b_recheck
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_recheck d-utd
ON CHOOSE OF b_recheck IN FRAME d-utd /* Повторно проверить */
   DO:
      define variable Log-Res as logical no-undo.
    
      if available (buf_utd)
         then 
      do:
         /*Проверка прав */
         { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_edi-doc_recheck':U
        {&cntxt-firm}
        v-cntxt-host-code-obj
        '':U
        0
        0
        0
        0
        true
        log-res
      }  

         if log-res 
            then 
         do:
            Recheck(buf_utd.db-num, buf_utd.doc-id).
            assign
               c-status     = buf_utd.sts
               c-status-edi = buf_utd.sts-edi
               f-comment    = buf_utd.comment
               .  
            display f-info c-status c-status-edi f-comment with frame {&frame-name} .
            run enable_UI in this-procedure .
            run mark-temp (?).
/*            if upd_mark*/
/*               then    */
/*            do:        */
               {&OPEN-QUERY-br-utd}
/*            end.                          */
/*            else                          */
/*            do:                           */
/*               {&OPEN-QUERY-br-utd-nomark}*/
/*            end.                          */
            run enable_BUTTON in this-procedure .
         end.
      end.
   end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b_write-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_write-cancel d-utd
ON CHOOSE OF b_write-cancel IN FRAME d-utd /* Отказать в подписи */
   DO:
      define variable v-ok as logical no-undo .
      if available (buf_utd) then 
      do:
         run ref/dialog-upd.w (input buf_utd.comment, input buf_utd.db-num, input buf_utd.doc-id, output v-comment, output v-ok) no-error.
         if  error-status:error then 
         do: 
            return return-value .
         end.
         if v-ok then 
         do:
            buf_utd.comment = replace ( buf_utd.comment,{&delim-cmd}, ", "). 
            if buf_utd.comment <> "" then buf_utd.comment = buf_utd.comment + ", " + v-comment .
            else  buf_utd.comment = v-comment .
            f-comment = buf_utd.comment .
            display f-comment with frame {&frame-name} .
            if p-connect <> ? then 
            do: 
               run SendResponse( buf_utd.db-num, buf_utd.doc-id, no, no) no-error.    
               if  error-status:error then 
               do: 
                  message return-value
                        view-as alert-box.
                  return return-value .
               end.
            end.
            else 
            do: 
               buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:RejectionUtd:KeyIntDB.
               buf_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:AutoRejected:KeyIntDB.
        
            end.
         
         end.
         assign
            c-status     = buf_utd.sts
            c-status-edi = buf_utd.sts-edi 
            .
         display c-status c-status-edi with frame {&frame-name} .     
         /*    run enable_BUTTON .*/
         disable          
            b_recheck
            b_anul
            b_write-cancel
            b_prov-finish
            b_finish
            b_back-check
            b_deliv-cancel
            with frame {&frame-name} .
      end.
      
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b_deliv-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b_deliv-cancel d-utd
ON CHOOSE OF b_deliv-cancel IN FRAME d-utd /* Отказать в подписи */
   DO:
      define variable v-ok as logical no-undo .
      if available (buf_utd) then 
      do:
         run ref/dialog-upd.w (input buf_utd.comment, input buf_utd.db-num, input buf_utd.doc-id, output v-comment, output v-ok) no-error.
         if  error-status:error then 
         do: 
            return return-value .
         end.
         if v-ok then 
         do:
            if buf_utd.comment <> "" and buf_utd.comment <> ? then buf_utd.comment = buf_utd.comment + {&delim-cmd} + v-comment .
            else buf_utd.comment = v-comment .
            f-comment = buf_utd.comment .
            display f-comment with frame {&frame-name} . 
      
            if p-connect <> ? then 
            do: 
               run SendAnsver(buf_utd.db-num, buf_utd.doc-id,"AcceptDocumentNotAccepted", "") no-error.
               if  error-status:error then 
               do: 
                  message return-value
                     view-as alert-box.
                  return return-value .
               end.
            end.
            else 
            do: 
               buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:RejectionUtd:KeyIntDB.
               buf_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:SignatureNotAccepted:KeyIntDB.
    
            end.
            validate buf_utd no-error.
            assign
               c-status     = buf_utd.sts
               c-status-edi = buf_utd.sts-edi 
               .
         end.
      end.
      display c-status c-status-edi with frame {&frame-name} .     
      disable          
         b_recheck
         b_anul
         b_write-cancel
         b_prov-finish
         b_finish
         b_back-check
         b_deliv-cancel
         with frame {&frame-name} .  
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-status d-utd
ON VALUE-CHANGED OF c-status IN FRAME d-utd /* Статус ТН */
   DO:
      assign c-status .
      if c-type = 0 then 
      do:
         message "Укажите тип документа"
            view-as alert-box.
      end.  
    
      buf_utd.sts = integer(c-status).
      validate buf_utd no-error.
      c-status = buf_utd.sts.
      c-status-edi = buf_utd.sts-edi.
      display c-status c-status-edi with frame {&frame-name} .
      run enable_BUTTON .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-status-edi
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-status-edi d-utd
ON VALUE-CHANGED OF c-status-edi IN FRAME d-utd /* Статус EDI */
   DO:
      assign c-status-edi .
      if c-type = 0 then 
      do:
         message "Укажите тип документа"
            view-as alert-box.
      end.  
    
      buf_utd.sts-edi = integer(c-status-edi).
      validate buf_utd no-error.
      c-status = buf_utd.sts.
      c-status-edi = buf_utd.sts-edi.
      display c-status c-status-edi with frame {&frame-name} .
      run enable_BUTTON .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-type d-utd
ON VALUE-CHANGED OF c-type IN FRAME d-utd /* Тип */
   DO:
      assign c-type .
      if available (buf_utd) then buf_utd.EDocType = c-type .
      F-text = "                            Просканируйте марку/штрих-код" . 
      display f-text with frame {&frame-name} .
      run enable_UI .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-agnt d-utd
ON leave OF f-agnt IN FRAME d-utd /* Исп */
   DO:
      define buffer buf_clients for ub.clients .
      assign f-agnt .
      find first buf_clients no-lock where buf_clients.obj-code = f-agnt and buf_clients.obj-type = {&prs} no-error . 
      IF NOT AVAILABLE buf_clients THEN 
      do:
         f-agnt = ? .
      end.  
      else 
      do:
         ASSIGN
            f-agnt    = buf_clients.obj-code
            agnt-name = buf_clients.obj-name
            .
      end. 
      display f-agnt agnt-name  with frame {&frame-name}.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-boss d-utd
ON leave OF f-boss IN FRAME d-utd /* М-р */
   DO:
      define buffer buf_clients for ub.clients .
      assign f-boss .
      find first buf_clients no-lock where buf_clients.obj-code = f-boss and buf_clients.obj-type = {&prs} no-error . 
      IF NOT AVAILABLE buf_clients THEN 
      do:
         f-boss = ? .
      end.  
      else 
      do:
         ASSIGN
            f-boss    = buf_clients.obj-code
            boss-name = buf_clients.obj-name
            .
      end.   
      display f-boss boss-name  with frame {&frame-name}.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-wrkr d-utd
ON leave OF f-wrkr IN FRAME d-utd /* Кл-к */
   DO:
      define buffer buf_clients for ub.clients .
      assign f-wrkr .
      find first buf_clients no-lock where buf_clients.obj-code = f-wrkr and buf_clients.obj-type = {&prs} no-error . 
      IF NOT AVAILABLE buf_clients THEN 
      do:
         f-wrkr = ? .
      end.  
      else 
      do:
         ASSIGN
            f-wrkr    = buf_clients.obj-code
            wrkr-name = buf_clients.obj-name
            .
      end. 
      display f-wrkr wrkr-name  with frame {&frame-name}.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_choose-status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_choose-status d-utd
ON CHOOSE OF MENU-ITEM m_choose-status /* Сменить статус документа */
   DO:
      enable c-status with frame {&frame-name} . 
      if c-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or c-type = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB then enable c-status-edi with frame {&frame-name} . 
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_reset_row_data
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_reset_row_data d-utd
ON CHOOSE OF MENU-ITEM m_reset_row_data /* Сбросить данные по строке */
   DO:
      define buffer cancel_utd-marking-lines for ub.utd-marking-lines .
      define buffer cancel_marking           for ub.marking .
      define buffer buf_utd-lines-attr       for ub.utd-lines-attr .
      define buffer buf_marking-attr         for ub.marking-attr .
      define buffer cancel_marking-attr         for ub.marking-attr .
      define buffer cancel_marking-lines-attr for ub.utd-marking-lines-attr.
      define variable v-gds-code as integer no-undo.
    
      /*    if available (X_utd-lines) and X_utd-lines.stts <> "Проверен"  then*/
      /*    do:                                                                */      
      if available (X_utd-lines) then 
      do:
         for each cancel_utd-marking-lines exclusive-lock where cancel_utd-marking-lines.doc-id  = x_utd-lines.doc-id
              and cancel_utd-marking-lines.db-num  = x_utd-lines.db-num
              and cancel_utd-marking-lines.lineNum = x_utd-lines.lineNum
              and cancel_utd-marking-lines.doc-level = 1
              and cancel_utd-marking-lines.sts = Marking:Checked_:KeyIntDB,                   
            first cancel_marking exclusive-lock where 
                  cancel_marking.mark = cancel_utd-marking-lines.mark
         :            
            if cancel_marking.sts = Marking:ungrouped:KeyIntDB then
            do:
              if not isSaleMarkInUpak(cancel_utd-marking-lines.mark) then
                setStatusUpak (
                  cancel_utd-marking-lines.db-num,
                  cancel_utd-marking-lines.doc-id,
                  cancel_utd-marking-lines.lineNum,
                  cancel_utd-marking-lines.mark,
                  Marking:DeliveryControl:KeyIntDB
                ).  
            end.
            else do:
              setStatusUpak (
                cancel_utd-marking-lines.db-num,
                cancel_utd-marking-lines.doc-id,
                cancel_utd-marking-lines.lineNum,
                cancel_utd-marking-lines.mark,
                Marking:DeliveryControl:KeyIntDB
              ).  
            end.
         end.
         /* для товара с переменным весом удаляем строки с марками */
         if x_utd-lines.isArtic and x_utd-lines.isWeight 
         then do:
             for each cancel_utd-marking-lines exclusive-lock where 
                      cancel_utd-marking-lines.doc-id  = x_utd-lines.doc-id
                  and cancel_utd-marking-lines.db-num  = x_utd-lines.db-num
                  and cancel_utd-marking-lines.lineNum = x_utd-lines.lineNum,                   
             first cancel_marking no-lock where 
                   cancel_marking.mark = cancel_utd-marking-lines.mark:
                 /* проверяем, что нет привязки к друмого документу */
                if not ChkAnotherUtd(x_utd-lines.doc-id, x_utd-lines.db-num, cancel_marking.mark) then do:                                                                    
                    /* убираем вес марки */   
                    find first cancel_marking-attr exclusive-lock where                                 
                               cancel_marking-attr.mark = cancel_utd-marking-lines.mark
                           and cancel_marking-attr.attr-code = "weight"
                           no-wait no-error.
                    if avail cancel_marking-attr then                                   
                       delete cancel_marking-attr.
                end.                                       
                /*if available buf_utd then UnLockUTDMarkbuf(buffer buf_utd,yes).*/    
                delete cancel_utd-marking-lines.
             end.                                           
         end.  

         X_utd-lines.qnty-scan = 0 .     
         setattrUtdlines(X_utd-lines.db-num, X_utd-lines.doc-id, X_utd-lines.LineNum, "QuantityBarCode", string(X_utd-lines.qnty-scan)).

         if not x_utd-lines.isMarking then 
         do:               
            /* Для типа учета ВО */
            if x_utd-lines.isArtic and x_utd-lines.isWeight then 
            do:
               X_utd-lines.PieceFact = "" .  
               setattrUtdlines(X_utd-lines.db-num, X_utd-lines.doc-id, X_utd-lines.LineNum, "QuantityPiece", X_utd-lines.PieceFact).                                
            end.    
         end.
         run mark-temp in this-procedure (X_utd-lines.LineNum).
      end.      
      {&OPEN-QUERY-br-utd}      
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME m_check-akt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_check-akt d-utd
ON CHOOSE OF MENU-ITEM m_check-akt /* Проверить по Акту приема-передачи */
   DO:
      define buffer bf_utd for ub.utd .
      define variable v-rec-list as character  no-undo .
      define variable not-mark   as logical    no-undo . /*Нет марок*/
      define variable mark-qnty  as integer    no-undo . /*Кол-во марок*/
      define variable bar-qnty   as integer    no-undo . /*Кол-во марок*/
      
      define variable LineNum    as integer    no-undo .
      define variable vconnect   as com-handle no-undo.
      define variable vmark      as character  no-undo.
      define buffer buf_utd-marking-lines for ub.utd-marking-lines . /*АКТ*/
      define buffer bf_utd-marking-lines  for ub.utd-marking-lines . /*УПД*/
      define buffer bf_marking            for ub.marking .
      define buffer bf_utd-lines-attr     for ub.utd-lines-attr .

      define variable mark-qnty-gray      as integer   no-undo .
      define variable mark-qnty-check     as integer   no-undo .
      define variable bar-qnty-gray       as integer   no-undo .
      define variable bar-qnty-check      as integer   no-undo .

      do:    
         find first bf_utd exclusive-lock where bf_utd.DocumentNumber = buf_utd.DocumentNumber and 
            bf_utd.DocumentDate = buf_utd.DocumentDate and bf_utd.edoctype = objSrv:Env:Utd:EDocType:AKT:KeyIntDB no-error .
/*            objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
         if not available (bf_utd) then 
         do:
            run str/UPD.w ( parparentproc, {&select}, objSrv:Env:Utd:EDocType:AKT:KeyIntDB, "", input-output vconnect, output v-rec-list)  no-error .
/* objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
            find first bf_utd exclusive-lock where recid(bf_utd) = integer(v-rec-list) no-error .
         end.  
         if available (bf_utd) then 
         do:

            mark-qnty-gray  = 0 . /*Кол-во не проверенных марок*/
            mark-qnty-check = 0 . /*Кол-во проверенных марок*/
            bar-qnty-gray   = 0 . /*Кол-во не проверенных марок*/
            bar-qnty-check  = 0 . /*Кол-во проверенных марок*/
            
            mark-qnty = 0 .
            bar-qnty = 0 .
            
            /*Ищем, все ли марки есть в УПД по линиям*/
            NEXT_:
            for each buf_utd-lines no-lock where buf_utd-lines.db-num = buf_utd.db-num and
               buf_utd-lines.doc-id = buf_utd.doc-id:
               LineNum = 0 .
               if logical(getAttrUtdLinesEx (buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,"MarkUtdLine","yes"))
               then do:
                  for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num 
                     and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
                     and buf_utd-marking-lines.gds-code = buf_utd-lines.gds-code
                     and buf_utd-marking-lines.linenum = buf_utd-lines.linenum
                     and buf_utd-marking-lines.doc-level = 1:
   
                     vmark = getcodeident(buf_utd-marking-lines.mark).
                     find first bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num = bf_utd.db-num 
                        and bf_utd-marking-lines.doc-id = bf_utd.doc-id
                        and bf_utd-marking-lines.gds-code = buf_utd-marking-lines.gds-code
                        and bf_utd-marking-lines.mark begins vmark no-error .
                     if not available (bf_utd-marking-lines) then 
                     do:
                        not-mark = true .
                        next next_ .
                     end.
                     find first buf_marking exclusive-lock where buf_marking.mark = buf_utd-marking-lines.mark 
                        and (buf_marking.sts = Marking:GrayZone:KeyIntDB
                        or buf_marking.sts = Marking:MarkError:KeyIntDB) no-error .
                     if available (buf_marking) then 
                     do:
                        not-mark = true .
                        next next_ .
                     end.   
                  end. 
   
                  /*Проставляем статус проверен*/
                  for each buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num 
                     and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
                     and buf_utd-marking-lines.gds-code = buf_utd-lines.gds-code
                     and buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum, 
                     first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.db-num = bf_utd.db-num 
                     and bf_utd-marking-lines.doc-id = bf_utd.doc-id
                     and bf_utd-marking-lines.gds-code = buf_utd-marking-lines.gds-code
                     and bf_utd-marking-lines.mark begins buf_utd-marking-lines.mark
                     and bf_utd-marking-lines.doc-level = 1:
                     if length (buf_utd-marking-lines.mark) > length(bf_utd-marking-lines.mark)
                        then 
                     do:
                        find first bf_marking where bf_marking.mark eq buf_utd-marking-lines.mark
                           exclusive-lock no-error.
                        if available bf_marking
                           then 
                        do:
                           find first bf_marking where bf_marking.mark eq bf_utd-marking-lines.mark
                              exclusive-lock no-error.
                           if available bf_marking
                              then 
                           do:
                              g#auto = yes.
                              delete bf_marking.
                              g#auto = no.
                           end.
                        end.
                        bf_utd-marking-lines.mark = buf_utd-marking-lines.mark.
                     end.
   
                     if tree:LevelDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then 
                     do:
                        tree:StatusDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num, Marking:Checked_:KeyIntDB) .
                     end.
   
                     for first buf_marking exclusive-lock where buf_marking.mark = buf_utd-marking-lines.mark:
                     
                        mark-qnty-check = mark-qnty-check + buf_marking.box-qnty .
                        buf_marking.sts = Marking:Checked_:KeyIntDB.
                        buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB.
                     end.  
                  end.
               end.
               else do:
                  for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num 
                     and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
                     and buf_utd-marking-lines.gds-code = buf_utd-lines.gds-code
                     and buf_utd-marking-lines.linenum = buf_utd-lines.linenum
                     and buf_utd-marking-lines.doc-level = 1:
                  
                     vmark = getcodeident(buf_utd-marking-lines.mark).
                     find first bf_utd-marking-lines no-lock where bf_utd-marking-lines.db-num = bf_utd.db-num 
                        and bf_utd-marking-lines.doc-id = bf_utd.doc-id
                        and bf_utd-marking-lines.gds-code = buf_utd-marking-lines.gds-code
                        and bf_utd-marking-lines.mark = vmark no-error .
                     if not available (bf_utd-marking-lines) then 
                     do:
                        not-mark = true .
                        next next_ .
                     end.
                  end. 

                  /*Проставляем статус проверен*/
                  for each buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num 
                     and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
                     and buf_utd-marking-lines.gds-code = buf_utd-lines.gds-code
                     and buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum, 
                     first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.db-num = bf_utd.db-num 
                     and bf_utd-marking-lines.doc-id = bf_utd.doc-id
                     and bf_utd-marking-lines.gds-code = buf_utd-marking-lines.gds-code
                     and bf_utd-marking-lines.mark = buf_utd-marking-lines.mark
                     and bf_utd-marking-lines.doc-level = 1:
   
                     for first bf_utd-lines-attr no-lock where bf_utd-lines-attr.attr-code = "QuantityBarCode" and 
                        bf_utd-lines-attr.db-num = bf_utd-marking-lines.db-num and
                        bf_utd-lines-attr.doc-id = bf_utd-marking-lines.doc-id and
                        bf_utd-lines-attr.LineNum = bf_utd-lines-attr.LineNum:
                        bar-qnty-check = bar-qnty-check + integer(bf_utd-lines-attr.attr-value) .                                          
                        if integer(bf_utd-lines-attr.attr-value) = bf_utd-lines.Quantity then 
                        do:
                           bf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB.
                        end.                                                                
                     end.           
                                                       
                  end.
                  
               end.
            end.   

            /*Если ни по одной линии нет всех марок*/
            if not-mark and mark-qnty-check + bar-qnty-check  = 0 then 
            do:

               message "В документе неполный состав марок/штрих-кодов. Просканируйте марки/штрих-кодов вручную." 
                  view-as alert-box.
   
            end.  
            /*Если хотя бы по одной линии есть все марки*/
            if not-mark and mark-qnty-check + bar-qnty-check <> 0 then 
            do:
               for each buf_utd-lines no-lock where buf_utd-lines.db-num = buf_utd.db-num and
                                                    buf_utd-lines.doc-id = buf_utd.doc-id:
                  if logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","yes"))
                  then do:
                     for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num  = buf_utd-lines.db-num and 
                                                                  buf_utd-marking-lines.doc-id  = buf_utd-lines.doc-id and
                                                                  buf_utd-marking-lines.lineNum = buf_utd-lines.lineNum and
                                                                  buf_utd-marking-lines.doc-level = 1,
                     first buf_marking where buf_marking.mark = buf_utd-marking-lines.mark
                     no-lock:
                        /*Кол-во марок в УПД*/
                        mark-qnty = mark-qnty + buf_marking.box-qnty .
                     end. 
                  end.
                  else do:
                     for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num  = buf_utd-lines.db-num and 
                                                                  buf_utd-marking-lines.doc-id  = buf_utd-lines.doc-id and
                                                                  buf_utd-marking-lines.lineNum = buf_utd-lines.lineNum and
                                                                  buf_utd-marking-lines.doc-level = 1:
                        for first bf_utd-lines-attr no-lock where bf_utd-lines-attr.attr-code = "QuantityBarCode" and 
                           bf_utd-lines-attr.db-num = buf_utd-marking-lines.db-num and
                           bf_utd-lines-attr.doc-id = buf_utd-marking-lines.doc-id and
                           bf_utd-lines-attr.LineNum = buf_utd-marking-lines.LineNum:
                           bar-qnty = bar-qnty + integer(bf_utd-lines-attr.attr-value) .                                          
                           if integer(bf_utd-lines-attr.attr-value) = bf_utd-lines.Quantity then 
                           do:
                              buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB.
                           end.                                                                
                        end.
                     end.
                  end.
               end. 
               
               /*Кол-во не проверенных марок*/    
               mark-qnty-gray = mark-qnty - mark-qnty-check .
               bar-qnty-gray = bar-qnty - bar-qnty-check .
               
               if mark-qnty-check + bar-qnty-check <> 0 then
                  /*Запишем номер УПД в акт*/
                  bf_utd.doc-code = buf_utd.DocumentNumber .
       
               message "Проверка завершена" skip
                  "Успешно проверено марок - " + string (mark-qnty-check) skip
                  "Не проверено марок - " + string (mark-qnty-gray) skip
                  "Успешно проверено марок - " + string (bar-qnty-check) skip
                  "Не проверено марок - " + string (bar-qnty-gray) skip
                  
                  view-as alert-box.

            end .    
            if mark-qnty-gray + bar-qnty-gray <> 0 then 
            do:
               F-text = "                     Просканируйте марку/штрих-кодов" .
               display F-text with frame {&frame-name} .
            end.
         end.
      end.
      run mark-temp (?).
      {&OPEN-QUERY-br-utd}

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME r-agnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-agnt d-utd
ON CHOOSE OF r-agnt IN FRAME d-utd /* r-acc */
   DO:
      run ref/cli-all.w (
         input parparentproc
         ,input "b-sel"
         ,input {&prs}
         ,input {&all}
         ,input {&current}
         ,input ?
         ,input ",,,,,,NO,,"
         ,input ""
         ,output v-rid-list ) NO-ERROR.
      IF v-rid-list = '':U THEN RETURN NO-APPLY.
      FIND FIRST buf_clients NO-LOCK WHERE
         recid(buf_clients) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_clients THEN RETURN NO-APPLY.
      ASSIGN
         f-agnt    = buf_clients.obj-code
         agnt-name = buf_clients.obj-name
         .
      display f-agnt agnt-name  with frame {&frame-name}.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-boss d-utd
ON CHOOSE OF r-boss IN FRAME d-utd /* r-acc */
   DO:
      run ref/cli-all.w (
         input parparentproc
         ,input "b-sel"
         ,input {&prs}
         ,input {&all}
         ,input {&current}
         ,input ?
         ,input ",,,,,,NO,,"
         ,input ""
         ,output v-rid-list ) NO-ERROR.
      IF v-rid-list = '':U THEN RETURN NO-APPLY.
      FIND FIRST buf_clients NO-LOCK WHERE
         recid(buf_clients) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_clients THEN RETURN NO-APPLY.
      ASSIGN
         f-boss    = buf_clients.obj-code
         boss-name = buf_clients.obj-name
         .
      display f-boss boss-name  with frame {&frame-name}.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-contr-TH
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-contr-TH d-utd
ON CHOOSE OF r-contr-TH IN FRAME d-utd
   DO:
      define buffer buf_contract for contract.
      define variable agnt-list as character no-undo .
      if f-supp-code-TH <> 0 then 
      do:
         /*Если есть поставщик*/
         run str/cont-all.w ( input  parParentProc, input v-cntxt-host-code-obj, input "b-sel":U, input {&company}, input f-supp-type-TH, input f-supp-code-TH, input  ?, input  ?, input  "current", input {&income} , input-output agnt-list   ) no-error .
         find first buf_contract no-lock where RECID(buf_contract) = int (agnt-list) no-error.
         if not available buf_contract then 
         do:
            assign
               f-contr-TH      = 0
               /*      v-contr-host = 0*/
               f-contr-name-TH = ""
               .
            display f-contr-TH f-contr-name-TH  with frame {&frame-name}.
            return.
         end.
         /*Если АКТ*/
         if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
/*          or c-type = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
         then 
         do:
            define variable v-tth             as handle    no-undo .
            define variable v-value-character as character no-undo.
            define variable v-value-date      as date      no-undo.
            define variable v-value-decimal   as decimal   no-undo.
            define variable v-value-integer   as integer   no-undo.
            define variable v-param-type      as character no-undo.
            define variable v-FlagEdo         as logical   no-undo.
            run adm/shattri.p (
               input "get":U
               ,input  buf_utd.obj-type /*p-obj-type*/
               ,input  buf_utd.obj-code /*p-obj-code*/
               ,input  {&attr-marking}
               ,input  {&attr-marking_marking-EDO} /*p-param-code*/
               ,output v-value-character
               ,output v-value-date
               ,output v-value-decimal
               ,output v-value-integer
               ,output v-FlagEdo
               ,output v-param-type
               ,input-output table-handle v-tth
               ) no-error .
            /*Если есть параметр*/
            if v-FlagEdo then 
            do:
               if buf_contract.whole-send-news > 0 then 
               do:
                  assign
                     f-contr-TH      = buf_contract.contract-code
                     /*    v-contr-host   = buf_contract.host-code*/
                     f-contr-name-TH = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")
                     .
               end.
               else 
               do:
                  message "У договора " + buf_contract.contract-prn-code + " нет признака - 'Поставки через ЭДО'"
                     view-as alert-box.
                  return no-apply .
               end.    
      
            end.  
            else 
            do:
               assign
                  f-contr-TH      = buf_contract.contract-code
                  /*    v-contr-host   = buf_contract.host-code*/
                  f-contr-name-TH = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")
                  .
            end.
         end.    
         /*Если нет параметра*/  
         else 
         do:  
            assign
               f-contr-TH      = buf_contract.contract-code
               /*    v-contr-host   = buf_contract.host-code*/
               f-contr-name-TH = buf_contract.contract-prn-code + " от " + string(buf_contract.contract-date,"99/99/9999")
               .
         end.
         display f-contr-TH f-contr-name-TH  with frame {&frame-name}.
         if c-type <> objSrv:Env:Utd:EDocType:AKT:KeyIntDB 
/*         and c-type <> objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
         then
            disable r-contr-TH with frame {&frame-name} .
         run enable_BUTTON .                
      end.
      /*Нет поставщика*/
      else message "Поставщик договора не известен"
            view-as alert-box.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-obj-TH
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-obj-TH d-utd
ON CHOOSE OF r-obj-TH IN FRAME d-utd
   DO:
      define variable v-tth             as handle    no-undo .
      define variable v-value-character as character no-undo.
      define variable v-value-date      as date      no-undo.
      define variable v-value-decimal   as decimal   no-undo.
      define variable v-value-integer   as integer   no-undo.
      define variable v-param-type      as character no-undo.
      define variable v-FlagEdo         as logical   no-undo.       
      run ref/cli-all.w (
         input parparentproc
         ,input "b-sel"
         ,input {&shop}
         ,input {&all}
         ,input {&current}
         ,input ?
         ,input ",,,,,,NO,,"
         ,input ""
         ,output v-rid-list ) NO-ERROR.
      IF v-rid-list = '':U THEN RETURN NO-APPLY.
      FIND FIRST buf_clients NO-LOCK WHERE
         recid(buf_clients) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_clients THEN RETURN NO-APPLY.

      run adm/shattri.p (
         input "get":U
         ,input  buf_clients.obj-type /*p-obj-type*/
         ,input  buf_clients.obj-code /*p-obj-code*/
         ,input  {&attr-marking}
         ,input  {&attr-marking_marking-EDO} /*p-param-code*/
         ,output v-value-character
         ,output v-value-date
         ,output v-value-decimal
         ,output v-value-integer
         ,output v-FlagEdo
         ,output v-param-type
         ,input-output table-handle v-tth
         ) no-error .
      if not v-FlagEdo then 
      do:
         message "Сформировать УПД для данного объекта невозможно." skip
            "Для объекта не включен электронный документооборот"
            view-as alert-box.
         return no-apply .
      end.   
      ASSIGN
         f-obj-type-TH = buf_clients.obj-type
         f-obj-code-TH = buf_clients.obj-code
         f-obj-name-TH = buf_clients.obj-name
         .
      display f-obj-code-TH f-obj-type-TH f-obj-name-TH  with frame {&frame-name}.
      disable r-obj-TH with frame {&frame-name} .
      run enable_BUTTON .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-supp-TH
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-supp-TH d-utd
ON CHOOSE OF r-supp-TH IN FRAME d-utd
   DO:
      run ref/cli-all.w (
         input parparentproc
         ,input "b-sel"
         ,input {&cmp}
         ,input {&all}
         ,input {&current}
         ,input ?
         ,input ",,,,,,NO,,"
         ,input ""
         ,output v-rid-list ) NO-ERROR.
      IF v-rid-list = '':U THEN RETURN NO-APPLY.
      FIND FIRST buf_clients NO-LOCK WHERE
         recid(buf_clients) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_clients THEN RETURN NO-APPLY.
      ASSIGN
         f-supp-type-TH = buf_clients.obj-type
         f-supp-code-TH = buf_clients.obj-code
         f-supp-name-TH = buf_clients.obj-name
         .
      display f-supp-type-TH f-supp-code-TH f-supp-name-TH with frame {&frame-name} .
      if c-type <> objSrv:Env:Utd:EDocType:AKT:KeyIntDB 
/*      and c-type <> objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
      then 
         disable r-supp-TH with frame {&frame-name} .
      run enable_BUTTON .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME R-error
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-error d-utd
ON value-changed OF R-error IN FRAME d-utd
   DO:
      assign R-error .
/*      if upd_mark*/
/*         then    */
/*      do:        */
         {&OPEN-QUERY-br-utd}
/*      end.                          */
/*      else                          */
/*      do:                           */
/*         {&OPEN-QUERY-br-utd-nomark}*/
/*      end.                          */
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME R-error-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-error-2 d-utd
ON value-changed OF R-error-2 IN FRAME d-utd
   DO:
      assign R-error-2 .
/*      if upd_mark*/
/*         then    */
/*      do:        */
         {&OPEN-QUERY-br-utd}
/*      end.                          */
/*      else                          */
/*      do:                           */
/*         {&OPEN-QUERY-br-utd-nomark}*/
/*      end.                          */
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME f-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-num d-utd
ON value-changed OF f-num IN FRAME d-utd
   DO:
      assign f-num .
      display f-num with frame {&frame-name} .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME F-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date d-utd
ON RETURN OF F-date IN FRAME d-utd
   DO:
      apply "TAB":U to self .
      return no-apply .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date d-utd
ON TAB OF F-date IN FRAME d-utd
   DO:
      assign f-date .
      display f-date with frame {&frame-name} .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-num d-utd
ON leave OF F-num IN FRAME d-utd
   DO:
      assign f-num .
      if f-date:SCREEN-VALUE <> "" and f-num:SCREEN-VALUE <> "" then 
      do:
         find first ub.utd no-lock where ub.utd.DocumentNumber = f-num
            and ub.utd.DocumentDate = f-date 
            and (   ub.utd.EDocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
                 or ub.utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB 
/*                 or ub.utd.EDocType = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
                 )no-error .
         if AVAILABLE (ub.utd) then 
         do:
            MESSAGE "Документ с № " + ub.utd.DocumentNumber + " от даты: " + string(ub.utd.DocumentDate) + " уже заведен в системе." skip
               VIEW-AS ALERT-BOX.
            return NO-APPLY .
         end.    
      end.      
      display f-num with frame {&frame-name} .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME 

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-date d-utd
ON leave OF F-date IN FRAME d-utd
   DO:
      assign f-date .
      if f-num:SCREEN-VALUE <> "" and f-num:SCREEN-VALUE <> ? then 
      do:
         find first ub.utd no-lock where ub.utd.DocumentNumber = f-num
            and ub.utd.DocumentDate = f-date 
            and (   ub.utd.EDocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
                 or ub.utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB 
/*                 or ub.utd.EDocType = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
                 )no-error .
         if AVAILABLE (ub.utd) then 
         do:
            MESSAGE "Документ с № " + ub.utd.DocumentNumber + " от даты: " + string(ub.utd.DocumentDate) + " уже заведен в системе." skip
               VIEW-AS ALERT-BOX.
            return NO-APPLY .
         end.    
      end.      
      display f-date with frame {&frame-name} .
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME r-wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-wrkr d-utd
ON CHOOSE OF r-wrkr IN FRAME d-utd /* r-acc */
   DO:
      run ref/cli-all.w (
         input parparentproc
         ,input "b-sel"
         ,input {&prs}
         ,input {&all}
         ,input {&current}
         ,input ?
         ,input ",,,,,,NO,,"
         ,input ""
         ,output v-rid-list ) NO-ERROR.
      IF v-rid-list = '':U THEN RETURN NO-APPLY.
      FIND FIRST buf_clients NO-LOCK WHERE
         recid(buf_clients) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_clients THEN RETURN NO-APPLY.
      ASSIGN
         f-wrkr    = buf_clients.obj-code
         wrkr-name = buf_clients.obj-name
         .
      display f-wrkr wrkr-name  with frame {&frame-name}.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark d-utd
ON ENTRY OF v-mark IN FRAME d-utd /* Марка */
   DO:
      run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
      run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type /*p-obj-type*/
               ,input  v-cntxt-obj-code /*p-obj-code*/
               ,input  {&attr-marking}
               ,input  {&attr-marking_rus-key} /*p-param-code*/
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error . 
      IF p-value-logical = yes THEN  iLang = 68748313.

      run ActivateKeyboardLayout (input iLang, input 0).
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*&Scoped-define SELF-NAME v-bar-code                                     */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-bar-code d-utd              */
/*ON ENTRY OF v-bar-code IN FRAME d-utd /* Штрих-код */                   */
/*   DO:                                                                  */
/*      run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).*/
/*      run ActivateKeyboardLayout (input iLang, input 0).                */
/*   END.                                                                 */
/*                                                                        */
/*/* _UIB-CODE-BLOCK-END */                                               */
/*&ANALYZE-RESUME                                                         */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark d-utd
ON leave OF v-mark IN FRAME d-utd /* Марка */
   DO:
      v-mark = "" .
      if f-text <> "                       Просканируйте марку/штрих-код" then 
      do:
         F-text = "" .
         f-text:screen-value = "" .
      end.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-bar-code d-utd                   */
/*ON leave OF v-bar-code IN FRAME d-utd /* Марка */                            */
/*   DO:                                                                       */
/*      v-bar-code = "" .                                                      */
/*      if f-text <> "                            Просканируйте штрих-код" then*/
/*      do:                                                                    */
/*         F-text = "" .                                                       */
/*         f-text:screen-value = "" .                                          */
/*      end.                                                                   */
/*   END.                                                                      */
/*                                                                             */
/*/* _UIB-CODE-BLOCK-END */                                                    */
/*&ANALYZE-RESUME                                                              */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark d-utd
ON return OF v-mark IN FRAME d-utd /* Марка */
   DO:
      if  log-manager:logfile-name ne ?
      then do:
         def var speed as int64 no-undo.
         speed = etime.
      
         log-manager:write-message(substitute('Последовательность символов "&1" была просканирована за &2 мс',v-scan-str, speed), "ScanSpeed"). 
      end.
      if p-mode = {&lookup} then 
      do:
         v-mark:screen-value in frame {&frame-name} = "" .
         v-mark = "" .
      end .
      if v-mark:screen-value in frame {&frame-name} = ""
         then 
      do:
         v-mark:screen-value in frame {&frame-name} = v-scan-str.
      end.
   
      v-scan-str = "". 
      assign 
         v-mark = v-mark:screen-value in frame {&frame-name}.
      
      if isMark(v-mark)
      then do:
         run save_mark .
      end.
      else do:
          run save_bar-code .
         
      end.
      IF  b_cleaggds:visible = yes
         THEN 
      DO:          
         apply "ENTRY" to br-utd IN FRAME d-utd.
         REturn no-apply.
      end.
      
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-bar-code d-utd*/
/*ON return OF v-bar-code IN FRAME d-utd /* Штрих-код */    */
/*   DO:                                                    */
/*                                                          */
/*   END.                                                   */
/*                                                          */
/*/* _UIB-CODE-BLOCK-END */                                 */
/*&ANALYZE-RESUME                                           */

&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark d-utd
ON any-printable OF v-mark IN FRAME d-utd /*              */
   do:
      run proc-any-key.
   end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*&Scoped-define SELF-NAME v-bar-code                             */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-bar-code d-utd      */
/*ON any-printable OF v-bar-code IN FRAME d-utd /*              */*/
/*   do:                                                          */
/*      run proc-any-key.                                         */
/*   end.                                                         */
/*                                                                */
/*/* _UIB-CODE-BLOCK-END */                                       */
/*&ANALYZE-RESUME                                                 */

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-utd 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
   THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} 
   do:
      APPLY "CLOSE":U TO THIS-PROCEDURE.
      if p-mode = {&add-def} and available (buf_utd) then 
      do:
         delete buf_utd .
      end.
  
   end.
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/brwrepos.i
    &browse-name = br-utd
  &line-num= 5
}
   { gbl/getcntxt.i get }
   mDiadocConnection = p-connect . 
   Tree = ObjSrv:Lib:MarkingTree .
   Marking = ObjSrv:Env:Marking:Sts:Mark.
   
   run LoadKeyboardLayoutA (input v-scan-str, input 0, output iLang).
      run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type /*p-obj-type*/
               ,input  v-cntxt-obj-code /*p-obj-code*/
               ,input  {&attr-marking}
               ,input  {&attr-marking_rus-key} /*p-param-code*/
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error . 
      IF p-value-logical = yes THEN  iLang = 68748313.

   run ActivateKeyboardLayout (input iLang, input 0).  
  
   /*Проверка прав */
   { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_edi-doc_statchange':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  false
  log-res-statch
}
   { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_edi-doc_update':U
  {&cntxt-firm}
  v-cntxt-host-code-obj
  '':U
  0
  0
  0
  0
  false
  log-edi-doc_update
}
   { gbl/objat.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      "'active=request'"
      v-obj-active
}

/*   /*проверка на признак маркированности УПД*/                                                                                                          */
/*   find first ub.utd-attr no-lock where ub.utd-attr.doc-id = p-doc-id and ub.utd-attr.db-num = p-db-num and ub.utd-attr.attr-code = "MarkUtd" no-error .*/
/*   if available (ub.utd-attr) then upd_mark = logical(ub.utd-attr.attr-value) .                                                                         */
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code).
      
   if EDOParSec:IsBarCode
      then v-barcode = yes . 
   else v-barcode = no .    
   run init-temp in this-procedure .
   if available (buf_utd) then 
   do:
      assign
         frame {&frame-name}:title = EdoTypeName(buf_utd.EDocType) + "_____№ " + string (buf_utd.DocumentNumber) + "_____" + p-mode.
/*      if buf_utd.EDocType = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB then upd_mark = false .*/
   end.
   {  gbl/diasize.i }
   run diasize_init in this-procedure .
   if EDOParSec:IsManual
   then v-manual = yes . 
   else v-manual = no .

   run enable_UI in this-procedure .
   run enable_BUTTON in this-procedure .
/*   if not upd_mark then apply "entry" to v-bar-code in FRAME {&FRAME-NAME}.*/
/*   else                                                                    */
   apply "entry" to v-mark in FRAME {&FRAME-NAME}.
   on F9 of frame {&frame-name} anywhere 
      do:
         if not available X_utd-lines then  return no-apply.
         find first goods no-lock where goods.gds-code = X_utd-lines.gds-code .
         gds-rec = recid(goods) .
         run ref/gds-form.w
            (input  parParentProc
            ,input  {&lookup}
            ,input  v-cntxt-obj-type
            ,input  v-cntxt-obj-code
            ,input ? /*p-call-handle*/
            ,input-output gds-rec
            ).

         apply "entry" to br-utd in frame {&frame-name}.
         return no-apply.
      end.
   b_cleaggds:visible in frame {&frame-name} = no.
   m-gds-code:visible in frame {&frame-name} = no.
   apply "VALUE-CHANGED" to br-utd IN frame {&frame-name}.
   /*   if not upd_mark then wait-for go of frame {&frame-name} focus v-bar-code.*/
/*   else
{ gbl/mv-clmn.i
    &ext-col = 16
    &start-column = 4
    &frame-name = {&frame-name}
    &browse-name = {&browse-name}
   }                                                                     */
   wait-for go of frame {&frame-name} focus v-mark.
/*    WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.*/
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-utd  _DEFAULT-DISABLE
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
   HIDE FRAME d-utd.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_BUTTON d-utd 
PROCEDURE enable_BUTTON :
   /* --------------------------------------------------------------------
                               Purpose:     ENABLE the User Interface
                               Parameters:  <none>
                               Notes:       Here we display/view/enable the widgets in the
                                            user-interface.  In addition, OPEN all queries
                                            associated with each FRAME and BROWSE.
                                            These statements here are based on the "Other
                                            Settings" section of the widget Property Sheets.
                                -------------------------------------------------------------------- */
   define buffer cancel_utd-marking-lines for ub.utd-marking-lines .
   define buffer cancel_utd-lines         for ub.utd-lines .
   define buffer x_utd-lines         for x_utd-lines .
   define buffer cancel_marking           for ub.marking .
   define variable v-write-cancel  as logical no-undo .
   define variable v-write-correct as logical no-undo .
   v-write-cancel = false .
   v-write-correct = false . 
   
   for each x_utd-lines no-lock where x_utd-lines.doc-id = p-doc-id 
                                               and x_utd-lines.db-num = p-db-num, 
       each cancel_utd-marking-lines no-lock where cancel_utd-marking-lines.doc-id  = x_utd-lines.doc-id 
                                               and cancel_utd-marking-lines.db-num  = x_utd-lines.db-num
                                               and cancel_utd-marking-lines.lineNum = x_utd-lines.lineNum, 
      first cancel_marking no-lock where cancel_marking.mark = cancel_utd-marking-lines.mark 
                                     and (    cancel_marking.sts = Marking:PendingVerification:KeyIntDB 
                                           or cancel_marking.sts = Marking:DeliveryControl:KeyIntDB): 
      v-write-cancel = true .
      leave .
   end.
   
   for each x_utd-lines no-lock where x_utd-lines.doc-id = p-doc-id 
                                               and x_utd-lines.db-num = p-db-num, 
       each cancel_utd-marking-lines no-lock where cancel_utd-marking-lines.doc-id  = x_utd-lines.doc-id 
                                               and cancel_utd-marking-lines.db-num  = x_utd-lines.db-num
                                               and cancel_utd-marking-lines.lineNum = x_utd-lines.lineNum, 
      first cancel_marking no-lock where cancel_marking.mark = cancel_utd-marking-lines.mark and cancel_marking.sts <> Marking:MarkError:KeyIntDB
      and cancel_marking.sts <> Marking:GrayZone:KeyIntDB: 
      v-write-correct = true .
      leave .
   end.
   for each cancel_utd-lines where cancel_utd-lines.db-num eq p-db-num
      and cancel_utd-lines.doc-id eq p-doc-id
      no-lock:
      define variable vqnty as decimal no-undo.
      vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
      if vqnty > 0
         then 
      do:
         v-write-correct = true .
         leave.
      end.
   end.
   if p-mode <> {&lookup} then 
   do:
      if (c-status < ObjSrv:Env:Utd:Sts:TH:SignatureRequired:KeyIntDB or 
         c-status = ObjSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:LoadError:KeyIntDB ) 
         and
         (c-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or
         c-type = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB)
         then 
      do:
         enable
            b_deliv-cancel
            with frame {&frame-name} .
      end.  
      if c-status = ObjSrv:Env:Utd:Sts:TH:LoadError:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:LackOfMarkingCodesInCirculation:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB or
         c-status = ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB then
      do:
         if f-contr-TH <> 0 and f-obj-code-TH <> 0 and f-supp-code-TH <> 0 then 
         do:
            find first ub.utd-err-attr no-lock where ub.utd-err.db-num = p-db-num and ub.utd-err.doc-id = p-doc-id
               and (ub.utd-err.CodeErr = "NoSuppForId" 
               or ub.utd-err.CodeErr = "NoFirmForId"
               or ub.utd-err.CodeErr = "NoContForFirmId" 
               or ub.utd-err.CodeErr = "NoShopForKpp"
               or ub.utd-err.CodeErr = "NoEdoDoc" 
               or ub.utd-err.CodeErr = "SpecifErr"
               or ub.utd-err.CodeErr = "ContrDate") no-error .
            if not available (ub.utd-err) then 
            do:
               enable
                  b_back-check
                  with frame {&frame-name} .
            end.
            else 
            do:
               disable
                  b_back-check
                  with frame {&frame-name} .                      
            end.                            
         end.
         else 
         do:
            disable
               b_back-check
               with frame {&frame-name} .                        
         end. 
         
      end.     
      case c-status:
         when ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then /*Новый*/
            do:
               enable
                  b_prov-finish
                  with frame {&frame-name} .
            end.  
         when ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then /*Ожидает поставку*/
            do:
               enable
                  b_correct
                  b_write-cancel
                  b_prov-finish
                  with frame {&frame-name} .
               if v-write-cancel then 
               do:
                  DISABLE
                     b_correct
                     /*                            b_write-cancel*/
                     with frame {&frame-name} .
               end.    
            end. 
         when ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB or /*Несоответствие договору поставки*/
         when ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB or /*Несоответствие договору поставки*/
         when ObjSrv:Env:Utd:Sts:TH:LoadError:KeyIntDB then /*Ошибка загрузки*/
            do:
               enable
                  b_correct
                  b_write-cancel
                  b_recheck
                  with frame {&frame-name} .
               if v-write-cancel then 
               do:
                  DISABLE
                     /*                            b_write-cancel*/
                     b_correct
                     with frame {&frame-name} .
               end.   
            end.
         when ObjSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB or /*Пройдена проверка МОТП*/
         when ObjSrv:Env:Utd:Sts:TH:RequiresAdjustment:KeyIntDB or /*Требуется корректировка*/
         when ObjSrv:Env:Utd:Sts:TH:LackOfMarkingCodesInCirculation:KeyIntDB or /*Отсутствие КМ в обороте*/
         when ObjSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB then /*Несоответствие кодов маркировки при поставке*/
            do:
               enable
                  b_correct
                  b_write-cancel
                  /*            b_back-check*/
                  with frame {&frame-name} .
               if c-status = ObjSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB
               then
                  enable
                  b_recheck
                  with frame {&frame-name} .
               
               if v-write-cancel then 
               do:
                  DISABLE
                     /*                            b_write-cancel*/
                     b_correct
                     with frame {&frame-name} .
               end.   
            end. 
         /*      when ObjSrv:Env:Utd:Sts:TH:Rejection:KeyIntDB then /*Отказ*/*/
         /*        do:                                                       */
         /*          enable                                                  */
         /*            b_back-check                                          */
         /*            with frame {&frame-name} .                            */
         /*        end.                                                      */
         when ObjSrv:Env:Utd:Sts:TH:SignatureRequired:KeyIntDB then /*Требует подписания*/
            do:
               disable
                  b_write-cancel
                  with frame {&frame-name} .
            end.  
         otherwise 
         do:
            display
               b_correct
               b_recheck
               b_write-cancel
               b_prov-finish
               with frame {&frame-name} .
         end.  
      end case .
      

      if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB 
/*      or c-type = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
      then 
      do:
         disable
            b_correct
            b_recheck
            b_write-cancel
            with frame {&frame-name} .
      end.  
      if c-type <> objSrv:Env:Utd:EDocType:Introduce:KeyIntDB then 
      do:
         disable
            b_finish
            with frame {&frame-name} .
      end.  
      if c-type = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB then 
      do:
         disable
            b_correct
            b_write-cancel        
            with frame {&frame-name} .
         if c-status <> ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then 
         do:
            enable
               b_finish
               with frame {&frame-name} .         
         end.
      end.  
      if p-connect = ? then 
      do:
         display
            b_correct
            b_recheck
            with frame {&frame-name} .
      end.
      if not v-write-correct then 
      do:
         disable
            b_correct
            with frame {&frame-name} .
         enable
            b_deliv-cancel
         with frame {&frame-name} .
      end.   
   end.
   if v-cntxt-db-num <> 0 then 
   do:
      disable
         b_write-cancel
         b_back-check
         b_correct
         with frame {&frame-name} .
   end. 
   if not v-obj-active then 
   do:
      disable
         /*      b_back-check */
         b_prov-finish
         with frame {&frame-name} .
   end.     
/*   if not upd_mark then                                             */
/*   menu-item m_check-akt:sensitive in menu POPUP-MENU-b-servis = no.*/
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-utd 
PROCEDURE enable_UI :
   /* --------------------------------------------------------------------
                               Purpose:     ENABLE the User Interface
                               Parameters:  <none>
                               Notes:       Here we display/view/enable the widgets in the
                                            user-interface.  In addition, OPEN all queries
                                            associated with each FRAME and BROWSE.
                                            These statements here are based on the "Other
                                            Settings" section of the widget Property Sheets.
                                -------------------------------------------------------------------- */
   p-type = c-type .
   display
      br-utd
/*      br-utd-nomark*/
      with frame {&frame-name} .
/*   if not upd_mark then            */
/*   do:                             */
/*      hide                         */
/*         br-utd                    */
/*         b_mark                    */
/*         in frame {&frame-name} .  */
/*      enable                       */
/*         b_BarCode                 */
/*         br-utd-nomark             */
/*         with frame {&frame-name} .*/
/*   end.                            */
/*   else                            */
/*   do:*/
      enable
         b_mark
         br-utd
         with frame {&frame-name} .
/*      hide                       */
/*         br-utd-nomark           */
/*         b_BarCode               */
/*         in frame {&frame-name} .*/
/*   end.*/
   enable
      f-comment
      f-info
      a-n-c-name
      a-n-c
      b_error
      with frame {&frame-name} .
   display
      f-comment-name
      f-info-name
      f-status-TH
      f-num-name
      f-date-name
      f-wrkr-name
      f-agnt-name
      f-boss-name
      with frame {&frame-name} . 
   if  p-type eq objSrv:Env:Utd:EDocType:returns:KeyIntDB
   then do: 
      X_utd-lines.stts         :visible IN BROWSE br-utd = false.
      X_utd-lines.UnitCliQnty  :visible IN BROWSE br-utd = false.
   end.   

   if mOrderItem <> "" then
   do:
     b-order:label = substitute("Заказ № &1", mOrderItem).
     enable
       b-order
       with frame {&frame-name} .
   end.
   else 
     hide
       b-order
       in frame {&frame-name} .
   
   
   case p-mode:
      when {&update} then 
         do:
            if p-type <> objSrv:Env:Utd:EDocType:UTD:KeyIntDB and p-type <> objSrv:Env:Utd:EDocType:UCD:KeyIntDB and p-type <> objSrv:Env:Utd:EDocType:EDoc:KeyIntDB then 
            do:
/*               if not upd_mark then                           */
/*               do:                                            */
/*                  enable v-bar-code with frame {&frame-name}. */
/*                  display f-bar-code with frame {&frame-name}.*/
/*                  v-mark:hidden in frame {&frame-name} .      */
/*                  f-mark:hidden in frame {&frame-name} .      */
/*               end.                                           */
/*               else                                           */
/*               do:                                            */
                  enable v-mark with frame {&frame-name}.
                  display f-mark with frame {&frame-name} .
/*                  v-bar-code:hidden in frame {&frame-name} .*/
/*                  f-bar-code:hidden in frame {&frame-name} .*/
/*               end.                                         */
               ENABLE
                  b-save
                  b-cancel
                  b-servis
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  R-TH
                  WITH FRAME {&frame-name}.
               display 
                  f-obj-name
                  with frame {&frame-name} .  
               hide 
                  f-contr-TH
                  b-exit
                  f-contr-name
                  f-contr-name-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  c-status-edi
                  r-contr-TH
                  r-supp-TH
                  RECT-1
                  in frame {&frame-name} .
               display
                  c-type
                  with frame {&frame-name} .
               if f-obj-type-TH <> "" then display r-obj-TH with frame {&frame-name} .
               else enable r-obj-TH with frame {&frame-name} .
            end.
            if p-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or p-type = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB or p-type = objSrv:Env:UTD:EDocType:UCD:KeyIntDB then 
            do:
               ENABLE
                  b-exit
                  b-save
                  b-servis
                  f-contr-TH
                  f-contr-name-TH
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  R-TH
                  WITH FRAME {&frame-name}.
               hide 
                  b-cancel
                  in frame {&frame-name} .
               display
                  FILL-IN-1
                  c-type                 
                  FILL-IN-2
                  FILL-IN-3
                  c-status-edi
                  f-status-EDI
                  b_finish
                  with frame {&frame-name} .

               if f-obj-type-TH <> "" then display r-obj-TH with frame {&frame-name} .
               else enable r-obj-TH with frame {&frame-name} .
               if f-supp-type-TH <> "" then display r-supp-TH with frame {&frame-name} .
               else enable r-supp-TH with frame {&frame-name} .
               if f-contr-TH <> ? and f-contr-TH <> 0 then display r-contr-TH with frame {&frame-name} .
               else enable r-contr-TH with frame {&frame-name} .
               if c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then 
               do:
                  for first X_utd-lines no-lock where X_utd-lines.stts <> "Проверен" :
/*                     if not upd_mark then                                                */
/*                        F-text = "                             Просканируйте штрих-код" .*/
/*                     else                                                                */
                     F-text = "                        Просканируйте марку/штрих-код" .
                     f-text:screen-value = "" .
                     display F-text with frame {&frame-name} .
                  end.
               end.
            end.
            if p-type = objSrv:Env:Utd:EDocType:returns:KeyIntDB then 
            do:
               enable 
                  b_anul
                  with frame {&frame-name} .
            end.  
            if p-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB 
/*            or p-type = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
            then 
            do:
               ENABLE
                  b-save
                  b-cancel
                  b-servis
                  b_prov-finish
                  WITH FRAME {&frame-name}.
               hide 
                  b-exit
                  RECT-1
                  c-status-edi
                  f-status-edi
                  in frame {&frame-name} .
               display
                  FILL-IN-1
                  FILL-IN-2
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  R-TH
                  c-type
                  f-contr-TH
                  f-contr-name-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  r-contr-TH
                  f-num
                  f-num-name
                  f-date
                  f-date-name
                  r-supp-TH
                  with frame {&frame-name} .
               disable
                  b_finish
                  b_correct
                  b_recheck
                  b_write-cancel
                  with frame {&frame-name} .
            end.  
            if p-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB 
/*            or p-type = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
            then
               menu-item m_check-akt:sensitive in menu POPUP-MENU-b-servis = no.
         end.
      when {&lookup} then 
         do:
            if p-type <> objSrv:Env:Utd:EDocType:UTD:KeyIntDB and  p-type <> objSrv:Env:Utd:EDocType:UCD:KeyIntDB and p-type <> objSrv:Env:Utd:EDocType:EDoc:KeyIntDB then 
            do:
               ENABLE
                  b-cancel
                  WITH FRAME {&frame-name}.
/*               if not upd_mark then                           */
/*               do:                                            */
/*                  enable v-bar-code with frame {&frame-name}. */
/*                  display f-bar-code with frame {&frame-name}.*/
/*                  v-mark:hidden in frame {&frame-name} .      */
/*                  f-mark:hidden in frame {&frame-name} .      */
/*               end.                                           */
/*               else                                           */
/*               do:                                            */
                  enable v-mark with frame {&frame-name}.
                  display f-mark with frame {&frame-name} .
/*                  v-bar-code:hidden in frame {&frame-name} .*/
/*                  f-bar-code:hidden in frame {&frame-name} .*/
/*               end.                                         */
               display
                  b_prov-finish
                  f-mark
                  b_correct
                  b_recheck
                  b_write-cancel
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  r-obj-TH
                  R-TH
                  b_finish
                  c-type
                  c-status
                  f-status-TH
                  b-servis
                  with frame {&frame-name} .  
               hide 
                  f-contr-TH
                  b-exit
                  f-contr-name
                  f-contr-name-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  r-contr-TH
                  b-save
                  r-supp-TH
                  c-status-edi
                  f-status-EDI
                  RECT-1
                  in frame {&frame-name} .
            end.
            if p-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or p-type = objSrv:Env:Utd:EDocType:UCD:KeyIntDB or p-type = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB then 
            do:
               enable
                  b-exit
                  with frame {&frame-name} .
/*               if not upd_mark then                           */
/*               do:                                            */
/*                  enable v-bar-code with frame {&frame-name}. */
/*                  display f-bar-code with frame {&frame-name}.*/
/*                  v-mark:hidden in frame {&frame-name} .      */
/*                  f-mark:hidden in frame {&frame-name} .      */
/*               end.                                           */
/*               else                                           */
/*               do:                                            */
                  enable v-mark with frame {&frame-name}.
                  display f-mark with frame {&frame-name} .
/*                  v-bar-code:hidden in frame {&frame-name} .*/
/*                  f-bar-code:hidden in frame {&frame-name} .*/
/*               end.                                         */
               display
                  b_prov-finish
                  b_correct
                  b_recheck
                  b_write-cancel
                  f-contr-TH
                  f-contr-name-TH
                  f-obj-code-TH
                  f-obj-name-TH
                  b_finish
                  f-obj-type-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  b-save
                  f-supp-type-TH
                  c-status-edi
                  f-status-edi
                  r-contr-TH
                  r-obj-TH
                  r-supp-TH
                  R-TH
                  c-type
                  WITH FRAME {&frame-name}.
               hide 
                  b-save
                  b-cancel
                  in frame {&frame-name} .
               display
                  FILL-IN-1
                  FILL-IN-2
                  FILL-IN-3
                  with frame {&frame-name} .
            end.
            if p-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB 
/*            or p-type = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
            then 
            do:
               ENABLE
                  b-save
                  b-cancel
                  b-servis
                  WITH FRAME {&frame-name}.
               hide 
                  b-exit
                  RECT-1
                  c-status-edi
                  f-status-edi
                  in frame {&frame-name} .
               display
                  FILL-IN-1
                  FILL-IN-2
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  R-TH
                  c-type
                  f-contr-TH
                  f-contr-name-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  r-contr-TH
                  f-num
                  f-num-name
                  f-date
                  f-date-name
                  r-supp-TH
                  with frame {&frame-name} .
               disable
                  b_finish
                  b_correct
                  b_recheck
                  b_write-cancel
                  b_prov-finish
                  with frame {&frame-name} . 
            end.  
         end.  
      when {&add-def} then 
         do:
            if p-type = 0 then 
            do:
               ENABLE
                  b-save
                  b-cancel
                  b-servis
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  R-TH
                  c-type
                  WITH FRAME {&frame-name}.
               hide 
                  f-contr-TH
                  b-exit
                  f-contr-name
                  f-contr-name-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  r-contr-TH
                  r-supp-TH
                  v-mark
                  f-mark
/*                  v-bar-code*/
/*                  f-bar-code*/
                  RECT-1
                  c-status-edi
                  f-status-edi
                  in frame {&frame-name} .
               if f-obj-type-TH <> "" then display r-obj-TH with frame {&frame-name} .
               else enable r-obj-TH with frame {&frame-name} .
            end.        
            if p-type = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB then 
            do:
/*               if not upd_mark then                           */
/*               do:                                            */
/*                  enable v-bar-code with frame {&frame-name}. */
/*                  display f-bar-code with frame {&frame-name}.*/
/*                  v-mark:hidden in frame {&frame-name} .      */
/*                  f-mark:hidden in frame {&frame-name} .      */
/*               end.                                           */
/*               else                                           */
/*               do:                                            */
                  enable v-mark with frame {&frame-name}.
                  display f-mark with frame {&frame-name} .
/*                  v-bar-code:hidden in frame {&frame-name} .*/
/*                  f-bar-code:hidden in frame {&frame-name} .*/
/*               end.                                         */
               ENABLE
                  b-save
                  b-cancel
                  b-servis
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  R-TH
                  c-type
                  WITH FRAME {&frame-name}.
               hide 
                  f-contr-TH
                  b-exit
                  f-contr-name
                  f-contr-name-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  r-contr-TH
                  r-supp-TH
                  RECT-1
                  c-status-edi
                  f-status-edi
                  in frame {&frame-name} .
               display f-mark with frame {&frame-name} .
               if f-obj-type-TH <> "" then display r-obj-TH with frame {&frame-name} .
               else enable r-obj-TH with frame {&frame-name} .
            end.
            if p-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB 
/*            or p-type = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB*/
            then 
            do:
/*               if not upd_mark then                           */
/*               do:                                            */
/*                  enable v-bar-code with frame {&frame-name}. */
/*                  display f-bar-code with frame {&frame-name}.*/
/*                  v-mark:hidden in frame {&frame-name} .      */
/*                  f-mark:hidden in frame {&frame-name} .      */
/*               end.                                           */
/*               else                                           */
/*               do:                                            */
                  enable v-mark with frame {&frame-name}.
                  display f-mark with frame {&frame-name} .
/*                  v-bar-code:hidden in frame {&frame-name} .*/
/*                  f-bar-code:hidden in frame {&frame-name} .*/
/*               end.                                         */
               ENABLE
                  b-save
                  b-cancel
                  b-servis
                  f-obj-code-TH
                  f-obj-name-TH
                  f-obj-type-TH
                  R-TH
                  c-type
                  f-contr-TH
                  f-contr-name-TH
                  f-supp-code-TH
                  f-supp-name-TH
                  f-supp-type-TH
                  r-contr-TH
                  b_prov-finish
                  f-num
                  f-date
                  r-supp-TH
                  WITH FRAME {&frame-name}.
               hide 
                  b-exit
                  RECT-1
                  c-status-edi
                  f-status-edi
                  in frame {&frame-name} .
               display
                  f-num-name
                  f-date-name
                  FILL-IN-1
                  FILL-IN-2
                  with frame {&frame-name} .
               disable
                  b_finish
                  b_correct
                  b_recheck
                  b_write-cancel
                  with frame {&frame-name} . 
               if f-obj-type-TH <> "" then display r-obj-TH with frame {&frame-name} .
               else enable r-obj-TH with frame {&frame-name} .
            end.        
         end.
   end case .  
   if type_mark <> 1 then 
   do:
      enable R-error-2 with frame {&frame-name} .
      hide R-error in frame {&frame-name} .
/*      if not upd_mark then                                                 */
/*      do:                                                                  */
/*         browse br-utd-nomark:GET-BROWSE-COLUMN(11):VISIBLE = yes no-error.*/
/*      end.                                                                 */
/*      else                                                                 */
/*      do:                                                                  */
/*         browse br-utd:GET-BROWSE-COLUMN(11):VISIBLE = no no-error.        */
/*         browse br-utd:GET-BROWSE-COLUMN(12):VISIBLE = no no-error.        */
/*      end.                                                                 */
      if p-type <> objSrv:Env:Utd:EDocType:UTD:KeyIntDB then 
      do:
/*         if not upd_mark then                                               */
/*         do:                                                                */
/*            browse br-utd-nomark:GET-BROWSE-COLUMN(6):VISIBLE = no no-error.*/
/*         end.                                                               */
/*         else                                                               */
         do:   
            X_utd-lines.qnty-scan:visible IN BROWSE br-utd = false.
         end.
      end.
      hide
         v-mark
/*         v-bar-code*/
         in frame {&frame-name} .
      if p-mode <> {&lookup} and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB and c-type <> 0 then 
      do:
/*         if not upd_mark then                           */
/*         do:                                            */
/*            enable v-bar-code with frame {&frame-name}. */
/*            display f-bar-code with frame {&frame-name}.*/
/*            v-mark:hidden in frame {&frame-name} .      */
/*            f-mark:hidden in frame {&frame-name} .      */
/*         end.                                           */
/*         else                                           */
/*         do:                                            */
            enable v-mark with frame {&frame-name}.
            display f-mark with frame {&frame-name} .
/*            v-bar-code:hidden in frame {&frame-name} .*/
/*            f-bar-code:hidden in frame {&frame-name} .*/
/*         end.                                         */
      end.  
      else 
      do:
         hide
            v-mark
            f-mark
/*            v-bar-code*/
/*            f-bar-code*/
            in frame {&frame-name} .
      end.  
   end.
   else 
   do:
      enable R-error with frame {&frame-name} .
      hide R-error-2 in frame {&frame-name} .
      if p-mode = {&update} then 
      do:
/*         if not upd_mark then                           */
/*         do:                                            */
/*            enable v-bar-code with frame {&frame-name}. */
/*            display f-bar-code with frame {&frame-name}.*/
/*            v-mark:hidden in frame {&frame-name} .      */
/*            f-mark:hidden in frame {&frame-name} .      */
/*         end.                                           */
/*         else                                           */
/*         do:                                            */
            enable v-mark with frame {&frame-name}.
            display f-mark with frame {&frame-name} .
/*            v-bar-code:hidden in frame {&frame-name} .*/
/*            f-bar-code:hidden in frame {&frame-name} .*/
/*         end.                                         */
         enable 
            r-wrkr
            r-agnt
            r-boss
            f-wrkr
            f-agnt
            f-boss
            with frame {&frame-name} .
         display
            f-wrkr-name
            f-agnt-name
            f-boss-name
            with frame {&frame-name} .  
      end.  
   end.  
/*   if c-type <> objSrv:Env:Utd:EDocType:Introduce:KeyIntDB then                                 */
/*   do:                                                                                          */
/*/*      if not upd_mark then browse br-utd-nomark:GET-BROWSE-COLUMN(10):VISIBLE = no no-error.*/*/
/*/*      else                                                                                  */*/
/*      browse br-utd:GET-BROWSE-COLUMN(10):VISIBLE = no no-error.                                */
/*   end.                                                                                         */
/*   if c-type = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB then                                  */
/*   do:                                                                                          */
/*/*      if not upd_mark then browse br-utd-nomark:GET-BROWSE-COLUMN(11):VISIBLE = no no-error.*/*/
/*/*      else                                                                                  */*/
/*      browse br-utd:GET-BROWSE-COLUMN(11):VISIBLE = no no-error.                                */
/*   end.                                                                                         */
   
   /* Для вывода из оборота изменим браузер со строками */
   if p-type = objSrv:Env:Utd:EDocType:LK_RECEIPT:KeyIntDB
   then do :
      define variable brii as integer no-undo .
      do brii = 6 to 14 :
         browse br-utd:GET-BROWSE-COLUMN(brii):VISIBLE = no no-error. 
      end .
      browse br-utd:GET-BROWSE-COLUMN(3):label = "GTIN" no-error .
      browse br-utd:GET-BROWSE-COLUMN(5):label = "Количество" no-error .
   end .
     
   if f-num-2 = "" then 
   do:
      hide 
         f-num-2
         f-num-name-2
         f-date-2
         f-date-name-2
         in frame {&frame-name} .
   end.  
   else 
   do:
      display 
         f-num-name-2
         f-date-name-2
         with frame {&frame-name} .      
   end.      
   if f-total = 0 then 
   do:
      hide 
         f-total
         f-vat
         in frame {&frame-name} .
   end.  
   if log-res-statch then 
   do:
      menu-item m_choose-status:sensitive in menu POPUP-MENU-b-servis = yes.
   end.  
   else 
   do:
      menu-item m_choose-status:sensitive in menu POPUP-MENU-b-servis = no.
   end.  
   if log-edi-doc_update and c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB and g#db-num <> 0 then 
   do:
      menu-item m_reset_row_data:sensitive in menu POPUP-MENU-b-servis = yes.
   end.  
   else 
   do:
      menu-item m_reset_row_data:sensitive in menu POPUP-MENU-b-servis = no.
   end.  
   if not v-manual then 
   do:
      v-mark:READ-ONLY IN FRAME d-utd        = TRUE .
/*      v-bar-code:read-only in frame d-utd = true .*/
   end.
   else do:
      v-mark:READ-ONLY IN FRAME d-utd        = false .
/*      v-bar-code:read-only in frame d-utd = false .*/
   end.   
/*   if not upd_mark                                                    */
/*   then apply "VALUE-CHANGED" to br-utd-nomark in frame {&frame-name}.*/
/*   else                                                               */
   apply "VALUE-CHANGED" to br-utd in frame {&frame-name}.      
/*    WAIT-FOR GO OF FRAME {&FRAME-NAME} focus v-mark.*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-temp d-utd 
PROCEDURE init-temp :
   /* --------------------------------------------------------------------
                             Purpose:     ENABLE the User Interface
                             Parameters:  <none>
                             Notes:       Here we display/view/enable the widgets in the
                                          user-interface.  In addition, OPEN all queries
                                          associated with each FRAME and BROWSE.
                                          These statements here are based on the "Other
                                          Settings" section of the widget Property Sheets.
                              -------------------------------------------------------------------- */
  
   define variable ii           as integer   no-undo .
   define variable Status_      as character no-undo .
   define variable StatusTH     as class     ibs.th.str.utd.sts.th   no-undo .
   define variable Status_EDI   as character no-undo .
   define variable StatusEDI    as class     ibs.th.str.utd.sts.edi  no-undo .
   define variable Type_        as character no-undo .
   define variable TypeTH       as class     ibs.th.str.utd.edoctype no-undo .
   define variable v-StatusName as character no-undo .

   Status_ = " " + {&comma-char} + '-1':U .

   StatusTH = ObjSrv:Env:Utd:Sts:TH.

   do ii = 1 to StatusTH:mapType:GetItemByLab(ii):
      Status_ = Status_ + {&comma-char} + StatusTH:CurrProp:Label_ + {&comma-char} + string(StatusTH:CurrProp:KeyIntDB) .
   end.

   ASSIGN
      c-status:LIST-ITEM-PAIRS  in frame {&frame-name} = Status_ .

   Status_EDI = " " + {&comma-char} + '-1':U .

   StatusEDI = ObjSrv:Env:Utd:Sts:EDI.

   do ii = 1 to StatusEDI:mapType:GetItemByLab(ii):
      if StatusEDI:CurrProp:KeyIntDB = ObjSrv:Env:Utd:Sts:EDI:WithRecipientSignature:KeyIntDB then 
      do:
         if available (buf_utd) then 
         do:
            v-StatusName = StatusName(buf_utd.doc-id, buf_utd.db-num) . 
            Status_EDI = Status_EDI + {&comma-char} + StatusEDI:CurrProp:Label_ + " " + v-StatusName + {&comma-char} + string(StatusEDI:CurrProp:KeyIntDB) .
         end.
         else 
         do:
            Status_EDI = Status_EDI + {&comma-char} + StatusEDI:CurrProp:Label_ + {&comma-char} + string(StatusEDI:CurrProp:KeyIntDB) .
         end.
      end.
      else 
      do:
         Status_EDI = Status_EDI + {&comma-char} + StatusEDI:CurrProp:Label_ + {&comma-char} + string(StatusEDI:CurrProp:KeyIntDB) .
      end.
   end.

   ASSIGN
      c-status-edi:LIST-ITEM-PAIRS  in frame {&frame-name} = Status_EDI .

   Type_ = " " + {&comma-char} + '0':U .
  
   TypeTH = objSrv:Env:Utd:EDocType .
  
   do ii = 1 to TypeTH:mapType:GetItemByLab(ii):
      if p-mode = {&add-def} then 
      do:
/*         if ii = 2 or ii = 6 or ii = 7 then*/
         if TypeTH:CurrProp:KeyIntDB =  TypeTH:Introduce:KeyIntDB or TypeTH:CurrProp:KeyIntDB =  TypeTH:AKT:KeyIntDB then
         do:
            Type_ = Type_ + {&comma-char} + TypeTH:CurrProp:Label_ + {&comma-char} + string(TypeTH:CurrProp:KeyIntDB) .
         end.
      end.
      else 
      do:
         Type_ = Type_ + {&comma-char} + TypeTH:CurrProp:Label_ + {&comma-char} + string(TypeTH:CurrProp:KeyIntDB) .
      end.  
   end.  
  
   ASSIGN
      c-type:LIST-ITEM-PAIRS  in frame {&frame-name} = Type_ .
   if p-mode = {&add-def} then 
   do:
      if not available (buf_utd) then 
      do:
         create buf_utd .
         assign
            buf_utd.DocumentDate = today
            buf_utd.sts          = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
            buf_utd.obj-code     = v-cntxt-obj-code
            buf_utd.obj-type     = v-cntxt-obj-type
            buf_utd.host-code    = v-cntxt-host-code-obj
            .
         validate buf_utd .
      end.      
   end.
   else 
   do:
      if p-mode = {&lookup} then find first buf_utd no-lock where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num no-error .
      if p-mode = {&update} then find first buf_utd exclusive-lock where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num no-wait no-error .
      if  error-status:error then 
      do: 
         message "Документ занят другим пользователем"
            view-as alert-box.
         p-mode = {&lookup} .
         find first buf_utd no-lock where buf_utd.doc-id = p-doc-id and buf_utd.db-num = p-db-num no-error .
      end.
   end.
   if available (buf_utd) then 
   do:
      assign
         f-num           = buf_utd.DocumentNumber
         f-date          = buf_utd.DocumentDate
         f-contr-name    = buf_utd.BaseDocumentNumber
         f-contr-TH      = buf_utd.contract-code
         f-contr-name-TH = ContName(buf_utd.contract-code, buf_utd.host-code)
         c-status        = buf_utd.sts
         mflagscan       = yes 
/*         when buf_utd.doc-code eq ""*/
         .
      /*      f-status        = ObjSrv:Env:Utd:Sts:TH:GetLabel(buf_utd.sts)*/
      c-status-edi = buf_utd.sts-edi .
      /*      if buf_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:WithRecipientSignature:KeyIntDB then do: */
      /*        c-status-edi = buf_utd.sts-edi + " " + StatusName(buf_utd.doc-id, buf_utd.db-num) .*/
      /*      end.                                                                                 */
      /*      else c-status-edi    = buf_utd.sts-edi .                                             */
      assign
         f-obj-code-TH  = buf_utd.obj-code
         f-obj-type-TH  = buf_utd.obj-type
         f-obj-name-TH  = CliName(buf_utd.obj-code, buf_utd.obj-type)
         f-supp-code-TH = buf_utd.cli-code
         f-supp-type-TH = buf_utd.cli-type
         f-supp-name-TH = CliName(buf_utd.cli-code, buf_utd.cli-type)
         f-obj-name-2   = buf_utd.obj-info
         /*      f-supp-name     = buf_utd.cli-FnsParticipantId*/
         /*      f-supp-name-2   = buf_utd.cli-info*/
         /*      f-info          = buf_utd.AdditInfo*/
         c-type         = buf_utd.EDocType
         f-total        = buf_utd.total
         f-vat          = buf_utd.vat
         v-pred-status  = buf_utd.sts
         /*        f-contr-name = entry(1,buf_utd.,"@")*/
         f-comment      = buf_utd.comment
         .

      for first ub.utd no-lock where ub.utd.DocumentExt = buf_utd.parentDocumentExt and 
         ub.utd.OrganizationExt = buf_utd.parentOrganizationExt and 
         buf_utd.DocumentExt <> "" and buf_utd.parentDocumentExt <> "":
         if ub.utd.DocumentNumber <> buf_utd.documentNumber then 
         do:
            f-num-2           = ub.utd.DocumentNumber .
            f-date-2          = ub.utd.DocumentDate .
            display 
               f-num-2
               f-date-2
               with frame {&frame-name} .
         end.  
         else 
         do:
            hide 
               f-num-2
               f-date-2
               in frame {&frame-name} .

         end.  
      end.         
      for each buf_utd-attr no-lock where buf_utd-attr.db-num = buf_utd.db-num and buf_utd-attr.doc-id = buf_utd.doc-id:
         case buf_utd-attr.attr-code:
            when "wrkr" then 
               do:
                  f-wrkr = integer(buf_utd-attr.attr-value) .
                  wrkr-name = CliName(integer(buf_utd-attr.attr-value), {&prs}) .
               end.  
            when "agnt" then 
               do:
                  f-agnt = integer(buf_utd-attr.attr-value) .
                  agnt-name = CliName(integer(buf_utd-attr.attr-value), {&prs}) .
               end.  
            when "boss" then 
               do:
                  f-boss = integer(buf_utd-attr.attr-value) .
                  boss-name = CliName(integer(buf_utd-attr.attr-value), {&prs}) .
               end.  
            when "order-item" then 
               do:
                  mOrderItem = buf_utd-attr.attr-value .
               end.  

         end case .  
      end.         
      /*надпись взависимости от статуса*/
      if buf_utd.sts-edi <> 0 then 
      do:
      /*    F-text = "                 Просканируйте Data Matrix блока из поставки" .*/
      end.
      if buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB and (buf_utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or buf_utd.EdocType = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB) then type_mark = 1 . 
      else 
      do:
         if c-status = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then type_mark = 5 . 
         else type_mark = 0 .  
      end.  
   end.
   if type_mark = 1 then 
   do:
      R-error = 2 .
      display R-error with frame {&frame-name} .
   end.

   display 
      F-text
      f-num
      f-date
      f-contr-TH
      f-total
      f-vat
      f-contr-name-TH
      f-contr-name
      f-wrkr
      f-agnt
      f-boss
      wrkr-name
      agnt-name
      boss-name
      f-info
      c-type
      f-obj-name-2
      f-gruz
      c-status-edi
      c-status
      f-obj-code-TH
      f-obj-type-TH
      f-obj-name-TH
      f-supp-code-TH
      f-supp-type-TH
      f-supp-name-TH
      f-comment
      with frame {&frame-name}.

   run mark-temp (?).

/*   if not upd_mark then {&OPEN-QUERY-br-utd-nomark}*/
/*   else                                            */
   {&OPEN-QUERY-br-utd}
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-filter d-utd 
PROCEDURE add-filter :
   define input  parameter idb-num   as integer no-undo.
   define input  parameter idoc-id   as integer no-undo.
   define input  parameter ilinenum  as integer no-undo.
   define input  parameter igds-code as character  no-undo.
   find first tt-utd-lines-filtr where tt-utd-lines-filtr.db-num   = idb-num
                                   and tt-utd-lines-filtr.doc-id   = idoc-id
                                   and tt-utd-lines-filtr.linenum  = ilinenum
                                   and tt-utd-lines-filtr.bar-code = igds-code
    no-lock no-error.
    if not available tt-utd-lines-filtr
    then do:
       create tt-utd-lines-filtr.
       assign 
          tt-utd-lines-filtr.db-num   = idb-num
          tt-utd-lines-filtr.doc-id   = idoc-id
          tt-utd-lines-filtr.linenum  = ilinenum
          tt-utd-lines-filtr.bar-code = igds-code
       .
   end.
end.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mark-temp d-utd 
PROCEDURE mark-temp :
   /* --------------------------------------------------------------------
                               Purpose:     ENABLE the User Interface
                               Parameters:  <none>
                               Notes:       Here we display/view/enable the widgets in the
                                            user-interface.  In addition, OPEN all queries
                                            associated with each FRAME and BROWSE.
                                            These statements here are based on the "Other
                                            Settings" section of the widget Property Sheets.
                                -------------------------------------------------------------------- */
   /*  define input parameter p-id as integer no-undo .*/
   define input parameter iLine as integer no-undo.

   define buffer buf_marking           for ub.marking .
   define buffer buf_utd-marking-lines for ub.utd-marking-lines .
   define buffer buf_utd-lines-attr    for ub.utd-lines-attr .
   define buffer buf_goods             for ub.goods .
   define buffer buf_bar-code          for ub.bar-code .
   define buffer buf_marking-attr for ub.marking-attr.
   define variable v-db-num       as integer   no-undo .
   define variable v-doc-id       as integer   no-undo .
   define variable vType          as character no-undo .
   define variable vIsErrMark     as logical   no-undo .
   define variable vQntyScan      as decimal   no-undo .
  
   empty temp-table  tt-utd-lines-filtr.
   run add-filter(?  ,
                  ?  ,
                  ? ,
                  "нет товара").
   for each buf_utd-lines no-lock where 
            buf_utd-lines.doc-id = buf_utd.doc-id and 
            buf_utd-lines.db-num = buf_utd.db-num and
            (if iLine <> ? then buf_utd-lines.LineNum = iLine else true):        
      find first X_utd-lines EXCLUSIVE-LOCK where buf_utd-lines.doc-id = X_utd-lines.doc-id and buf_utd-lines.db-num = X_utd-lines.db-num and buf_utd-lines.LineNum = X_utd-lines.LineNum no-error . 
      buffer-copy buf_utd-lines to X_utd-lines .
      define variable vper as logical no-undo.
      getMarkUtdLine(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,
      output x_utd-lines.isMarking, output x_utd-lines.isArtic, output vper).      
      X_utd-lines.isWeight = WeighedProd(X_utd-lines.gds-code).
      X_utd-lines.isVarWeight = WghProdVariable(buf_utd.obj-type, buf_utd.obj-code, X_utd-lines.gds-code).
      X_utd-lines.isSelect = logical(getAttrUtdLinesEx (buf_utd-lines.db-num,
                                                        buf_utd-lines.doc-id,
                                                        buf_utd-lines.LineNum,
                                                        "manual-selection",
                                                        "no")).            
      if x_utd-lines.isMarking then
      do:
         &scop proc-name gds-attr-value
                {&run_proc_attr-lib}
                    ( buf_utd-lines.gds-code,
                      {&attr-mark-type},
                       output x_utd-lines.markType,
                       output vtype
                    ).
      end.
                                     
      if not x_utd-lines.isArtic and not x_utd-lines.isMarking
      then do:
         run add-filter(buf_utd-lines.db-num  ,
                        buf_utd-lines.doc-id  ,
                        buf_utd-lines.LineNum ,
                        x_utd-lines.gds-code).
      end.
      else if x_utd-lines.isArtic
      then do:
         /*if X_utd-lines.isWeight then X_utd-lines.qnty-scan = 0.*/
         for each buf_utd-marking-lines  where buf_utd-marking-lines.db-num = buf_utd-lines.db-num and
                                               buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id and 
                                               buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum
         no-lock:
            if  GetAttrUtdMarkingLinesEx  
                    (buf_utd-marking-lines.db-num,
                     buf_utd-marking-lines.doc-id,
                     buf_utd-marking-lines.LineNum,
                     buf_utd-marking-lines.mark, 
                     "AddMarkWeight",
                     "no") <> "yes" 
            then do:
               run add-filter(buf_utd-marking-lines.db-num  ,
                              buf_utd-marking-lines.doc-id  ,
                              buf_utd-marking-lines.LineNum ,
                              getGtinBydm(buf_utd-marking-lines.mark)).
               if X_utd-lines.isWeight then X_utd-lines.PieceTTH = String(getQntyUTDByCodId(buf_utd-marking-lines.mark)). /* кол-во из ОАД */               
            end.
            /*else if X_utd-lines.isWeight then 
               X_utd-lines.qnty-scan = X_utd-lines.qnty-scan + MarkWeight(buf_utd-marking-lines.mark).*/
         end.
      end.
      
            
      if buf_utd.EdocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB 
      or (buf_utd.EdocType = objSrv:Env:Utd:EDocType:AKT:KeyIntDB
          and not x_utd-lines.isMarking)  
      then 
      do: 
         for first buf_utd-lines-attr no-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
            buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
            buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
            buf_utd-lines-attr.attr-code = "utd-fact-qnty":
 
            X_utd-lines.fact-qnty = integer(buf_utd-lines-attr.attr-value) . 
         end.
      end.
      for first buf_utd-lines-attr no-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
         buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
         buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
         buf_utd-lines-attr.attr-code = "Quantity":
 
         X_utd-lines.UnitCliQnty = integer(buf_utd-lines-attr.attr-value) . 
      end.        
      if x_utd-lines.isMarking then do:
        for first buf_utd-lines-attr no-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
           buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
           buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
           buf_utd-lines-attr.attr-code = "QuantityBarCode":
           X_utd-lines.qnty-scan = decimal(buf_utd-lines-attr.attr-value) . 
        end.            
      end.
      else do:                       
        for first buf_utd-lines-attr no-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
           buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
           buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
           buf_utd-lines-attr.attr-code = "QuantityBarCode":                
           X_utd-lines.qnty-scan = decimal(buf_utd-lines-attr.attr-value) .                                
        end.
        if X_utd-lines.isWeight then
        for first buf_utd-lines-attr no-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
           buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
           buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
           buf_utd-lines-attr.attr-code = "QuantityPiece":                                    
           X_utd-lines.PieceFact = buf_utd-lines-attr.attr-value .           
        end.            
      end.
      /*   for first buf_goods no-lock where buf_goods.gds-code = buf_utd-lines.gds-code:*/
      /*      X_utd-lines.UnitCli = buf_goods.unit-cli .                                 */
      /*   end.                                                                          */
   
      for first buf_bar-code no-lock where buf_bar-code.gds-code = buf_utd-lines.gds-code and
         buf_bar-code.unit-cli = buf_utd-lines.UnitCode:
         X_utd-lines.Price = buf_utd-lines.Price / buf_bar-code.cli-base-rate .                                      
      end.                                            

      X_utd-lines.sts_err = CheckErrForLine(buffer X_utd-lines:handle).
      if not X_utd-lines.sts_err
      then do:
         X_utd-lines.DelivCodeMis = CheckErrForLineTypeCode (buffer X_utd-lines:handle,"CheckQnty","QntyMArk","warning",no).
         if not X_utd-lines.DelivCodeMis
         then do:
            block-war:
            for each buf_utd-marking-lines         where buf_utd-marking-lines.db-num = buf_utd-lines.db-num and
                                                         buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id and 
                                                         buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum
            no-lock:
               X_utd-lines.DelivCodeMis = CheckTypeForMarkLineType(buffer utd-marking-lines:handle,"*","*","warning").
               if X_utd-lines.DelivCodeMis
               then
                  leave block-war.
            end.
         end.
      end.
      if x_utd-lines.isMarking then 
      do:
         /*Определить какие должны быть ошибочные статусы*/
         find first buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num and
            buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id and 
            buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum and 
            buf_utd-marking-lines.sts = Marking:MarkError:KeyIntDB no-error .
         if available (buf_utd-marking-lines) 
            then X_utd-lines.stts = "Ошибка статус марки" .
         else 
         do:
            find first buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num and
               buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id and 
               buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum and 
               buf_utd-marking-lines.doc-level = 1 and 
               not can-do(Marking:EqualChecked,string(buf_utd-marking-lines.sts)) no-error .
            if available (buf_utd-marking-lines) then  X_utd-lines.stts = "Ожидает проверку" .
            else 
            do:
               find first buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num and
                  buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id and 
                  buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum and 
                  buf_utd-marking-lines.doc-level = 1 and 
                  can-do(Marking:EqualChecked,string(buf_utd-marking-lines.sts)) no-error .
               if available (buf_utd-marking-lines) then do:
                   X_utd-lines.stts = "Проверен" .
               end.     
            end.  
         end.

         assign
           X_utd-lines.qnty-mark = 0
           X_utd-lines.qnty-scan = 0 
         .
         for each buf_utd-marking-lines no-lock where 
                  buf_utd-marking-lines.db-num  = buf_utd-lines.db-num 
              and buf_utd-marking-lines.doc-id  = buf_utd-lines.doc-id 
              and buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum
              and buf_utd-marking-lines.doc-level = 1
         :  
           X_utd-lines.qnty-mark = X_utd-lines.qnty-mark + 1.

           if buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB then
           do: /* если лок.статус 1-го уровня Проверен, то кол-во берем из qnty-box */
               /* марка при этом может быть Разгруппирована при загрузке УПД*/
             find first buf_marking no-lock where 
                        buf_marking.mark begins buf_utd-marking-lines.mark 
             no-error.
             if available buf_marking then do:   
                 /* для весового товара берем не из box-qnty, а из веса марки */
                 if X_utd-lines.isWeight                          
                 then do:                            
                    X_utd-lines.qnty-scan = X_utd-lines.qnty-scan + MarkWeight(buf_marking.mark).
                 end.
                 else
                    X_utd-lines.qnty-scan = X_utd-lines.qnty-scan + buf_marking.box-qnty.
             end.
             /* такого теоретически не должно быть, что бы статус строки был в статусе "проверен", а марки нет */
             else X_utd-lines.stts = "Ошибка статус марки" .
           end.  
           else
           do:  /* иначе считаем кол-во принятых марок по UNIT */
              run calcQntyMarkByUnit in this-procedure(
                buf_utd-lines.db-num,
                buf_utd-lines.doc-id,
                buf_utd-lines.LineNum,
                buf_utd-marking-lines.mark, 
                X_utd-lines.isWeight, 
                output vQntyScan,
                output vIsErrMark). 
              X_utd-lines.qnty-scan = X_utd-lines.qnty-scan + vQntyScan. 
              if vIsErrMark then X_utd-lines.stts = "Ошибка статус марки" .        
           end.
         end.
         
         find first buf_utd-lines-attr where 
                    buf_utd-lines-attr.db-num = X_utd-lines.db-num and
                    buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
                    buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
                    buf_utd-lines-attr.attr-code = "QuantityBarCode"
              exclusive-lock no-error.
         if avail buf_utd-lines-attr then
         do:
            if X_utd-lines.qnty-scan <> 0 then
              buf_utd-lines-attr.attr-value = string(X_utd-lines.qnty-scan).
            else 
              delete buf_utd-lines-attr.
         end.
         else do:
            if X_utd-lines.qnty-scan <> 0 then
            do:  
               create buf_utd-lines-attr.
               assign
                  buf_utd-lines-attr.db-num     = X_utd-lines.db-num
                  buf_utd-lines-attr.doc-id     = X_utd-lines.doc-id
                  buf_utd-lines-attr.LineNum    = X_utd-lines.LineNum
                  buf_utd-lines-attr.attr-code  = "QuantityBarCode"
                  buf_utd-lines-attr.attr-value = string(X_utd-lines.qnty-scan) .
               .
            end.
         end. 
      end.    
      else 
      do:
         if  not x_utd-lines.isMarking 
         then do:
            if X_utd-lines.Quantity = X_utd-lines.qnty-scan 
            then X_utd-lines.stts = "Проверен" .
            else X_utd-lines.stts = "Ожидает проверку" .
         end.
      end.    
      X_utd-lines.gds-name = GdsName(X_utd-lines.gds-code) .            
      X_utd-lines.taxRate_ = string(X_utd-lines.TaxRate) + " %" .
      if X_utd-lines.TaxRate = -1 then X_utd-lines.taxRate_ = "Без НДС" .
      if X_utd-lines.sts_err then X_utd-lines.stts = "Ошибка по строке" .
   end.    
   for each X_utd-lines:
      if not CAN-FIND (ub.utd-lines where ub.utd-lines.db-num = X_utd-lines.db-num and ub.utd-lines.doc-id = X_utd-lines.doc-id and ub.utd-lines.LineNum = X_utd-lines.LineNum) then 
         delete X_utd-lines .
   end.    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-mark d-utd 
PROCEDURE calcQntyMarkByUnit :
   define input  parameter iDbNum     as integer no-undo.
   define input  parameter iDocId     as integer no-undo.
   define input  parameter iLineNum   as integer no-undo.
   define input  parameter iMark      as character no-undo.
   define input  parameter iIsWeight  as logical no-undo.
   define output parameter oQntyScan  as decimal no-undo.
   define output parameter oIsErrMark as logical no-undo init false.
   
   define variable vIsErrMark     as logical   no-undo .
   define variable vQntyScan      as decimal   no-undo .
   define buffer buf_marking           for ub.marking.
   define buffer buf_utd-marking-lines for ub.utd-marking-lines .
    
   for each buf_marking no-lock where
            buf_marking.mark-parent begins iMark,
       first buf_utd-marking-lines no-lock where 
             buf_utd-marking-lines.db-num  = iDbNum and
             buf_utd-marking-lines.doc-id  = iDocId and 
             buf_utd-marking-lines.LineNum = iLineNum and
             buf_utd-marking-lines.mark    = buf_marking.mark
   :
     if buf_marking.unit-ext = "UNIT" then
     do:
       if     can-do(Marking:EqualChecked,string(buf_utd-marking-lines.sts)) 
/*          /* для табака и стиков факт. кол-во считаем пока не достигли кол-ва по док-ту */*/
/*          /* непонятно откуда проверка. Катя сказала для всех одинаково считаем         */*/
/*          and X_utd-lines.qnty-scan < X_utd-lines.Quantity or                             */
/*             (X_utd-lines.markType <> "tabak" and X_utd-lines.markType <> "stiki"))       */
       then do:
         if iIsWeight
         then do:
            oQntyScan = oQntyScan + MarkWeight(buf_marking.mark).
         end.
         else oQntyScan = oQntyScan + buf_marking.box-qnty.
       end.
     end .
     
     run calcQntyMarkByUnit in this-procedure(
         iDbNum,
         iDocId,
         iLineNum,
         buf_marking.mark, 
         iIsWeight, 
         output vQntyScan,
         output vIsErrMark). 
     oQntyScan = oQntyScan + vQntyScan. 
     if vIsErrMark then oIsErrMark = vIsErrMark.        
   end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-mark d-utd 
PROCEDURE temp-mark :
   /* --------------------------------------------------------------------
                           Purpose:     ENABLE the User Interface
                           Parameters:  <none>
                           Notes:       Here we display/view/enable the widgets in the
                                        user-interface.  In addition, OPEN all queries
                                        associated with each FRAME and BROWSE.
                                        These statements here are based on the "Other
                                        Settings" section of the widget Property Sheets.
                            -------------------------------------------------------------------- */
   define input parameter p-id as integer no-undo .
   define buffer buf_marking for ub.marking .
   define buffer buf_marking-attr for ub.marking-attr.
   empty temp-table tt-marking-lines .
   define variable mQuery as handle    no-undo.
   define variable vqry   as character no-undo.
   create query mQuery.
   mQuery:set-buffers(buffer buf_utd-marking-lines:HANDLE).
   vqry = substitute("for each buf_utd-marking-lines no-lock where ~
                               buf_utd-marking-lines.db-num = &1 ~
                           and buf_utd-marking-lines.doc-id = &2 " 
                           ,  p-db-num, p-doc-id).
 
   if p-id = 1 
   then
      vqry = vqry + substitute (" and buf_utd-marking-lines.LineNum = &1",X_utd-lines.LineNum). 
    mQuery:query-prepare(vqry).
    mQuery:query-open ().
    mQuery:get-first ().
                                                                         
    do while not mQuery:query-off-end:
       create tt-marking-lines .
       assign
          tt-marking-lines.gds-name  = GdsName(buf_utd-marking-lines.gds-code)
          tt-marking-lines.stts-utd  = StatusTHName(buf_utd-marking-lines.sts)
          tt-marking-lines.mark      = buf_utd-marking-lines.mark
          tt-marking-lines.gds-code  = buf_utd-marking-lines.gds-code
          tt-marking-lines.sts-utd   = buf_utd-marking-lines.sts
          tt-marking-lines.LineNum   = buf_utd-marking-lines.LineNum
          tt-marking-lines.db-num    = buf_utd-marking-lines.db-num
          tt-marking-lines.doc-id    = buf_utd-marking-lines.doc-id
          tt-marking-lines.doc-level = buf_utd-marking-lines.doc-level
          tt-marking-lines.site      = buf_utd-marking-lines.site
       .
       tt-marking-lines.isMark    = IsMark(tt-marking-lines.mark).
       tt-marking-lines.isWeight = WeighedProd(tt-marking-lines.gds-code).
      
       find first utd-marking-lines-attr where utd-marking-lines-attr.doc-id    eq buf_utd-marking-lines.doc-id  
                                           and utd-marking-lines-attr.db-num    eq buf_utd-marking-lines.db-num
                                           and utd-marking-lines-attr.LineNum   eq buf_utd-marking-lines.LineNum
                                           and utd-marking-lines-attr.mark      eq buf_utd-marking-lines.mark
                                           and utd-marking-lines-attr.attr-code eq "box-qnty"
       no-lock no-error.
       if avail utd-marking-lines-attr
       then
          tt-marking-lines.box-qnty = dec(utd-marking-lines-attr.attr-value).
          
       if tt-marking-lines.isMark then 
       do:
            
          for first buf_marking  where buf_marking.mark begins buf_utd-marking-lines.mark :
             assign
                tt-marking-lines.sts         = buf_marking.sts
                tt-marking-lines.unit        = buf_marking.unit
                tt-marking-lines.unit-ext    = buf_marking.unit-ext
                tt-marking-lines.box-qnty    = buf_marking.box-qnty  when tt-marking-lines.box-qnty eq 0 or tt-marking-lines.box-qnty eq ?
                tt-marking-lines.mark-parent = buf_marking.mark-parent
             .
             tt-marking-lines.stts        = StatusTHName(buf_marking.sts).
             tt-marking-lines.weight = if tt-marking-lines.isWeight then string(MarkWeight(buf_marking.mark)) else "".              
          end.
       end.   
       else 
       do:
/*          if X_utd-lines.qnty-scan = X_utd-lines.Quantity then */
          tt-marking-lines.stts-utd = StatusTHName(Marking:Checked_:KeyIntDB) .
/*          tt-marking-lines.box-qnty = X_utd-lines.qnty-scan .*/
       end.       
      mQuery:get-next ().
   end.
   delete object mQuery.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check_mol d-utd 
PROCEDURE check_mol :
   /* --------------------------------------------------------------------
                           Purpose:     ENABLE the User Interface
                           Parameters:  <none>
                           Notes:       Here we display/view/enable the widgets in the
                                        user-interface.  In addition, OPEN all queries
                                        associated with each FRAME and BROWSE.
                                        These statements here are based on the "Other
                                        Settings" section of the widget Property Sheets.
                            -------------------------------------------------------------------- */
   define output parameter p-ok as logical no-undo .
   define variable varchk-prs      as character no-undo .
   define variable varchk-prs-type as character no-undo .

   { gbl/conf-rd.i
    "'chk-prs'"
    "''"
    "''"
    0
    "''"
    "''"
    "''"
    no
    varchk-prs
    varchk-prs-type
    no-error
  }
 
   if varchk-prs <> "no" then 
   do:
      if f-agnt = 0 or f-agnt = ? then 
      do:
         message "Не указан исполнитель " f-agnt view-as alert-box error.
         p-ok = false .
         return.
      end.
      if f-boss = 0 or f-boss = ? then 
      do:
         message "Не указан менеджер " f-boss view-as alert-box error.
         p-ok = false .
         return.
      end.
      if f-wrkr = 0 or f-wrkr = ? then 
      do:
         message "Не указан кладовщик " f-wrkr view-as alert-box error.
         p-ok = false .
         return.
      end.
      p-ok = true .
   end.
   else p-ok = true .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save_mark d-utd 
PROCEDURE save_mark :
   /* --------------------------------------------------------------------
                             Purpose:     ENABLE the User Interface
                             Parameters:  <none>
                             Notes:       Here we display/view/enable the widgets in the
                                          user-interface.  In addition, OPEN all queries
                                          associated with each FRAME and BROWSE.
                                          These statements here are based on the "Other
                                          Settings" section of the widget Property Sheets.
                              -------------------------------------------------------------------- */
   define variable v_list    as character no-undo .
   define variable ii        as integer   no-undo .
   define variable jj        as integer   no-undo .
   define variable v-marking as character no-undo .
   define buffer buf_parts                   for ub.parts .
   define buffer gray_marking                for ub.marking .
   define buffer bf_marking                  for ub.marking .
   define buffer gray_unit-marking           for ub.marking .
   define buffer gray_utd-marking-lines      for ub.utd-marking-lines .
   define buffer gray_unit_utd-marking-lines for ub.utd-marking-lines .
   define buffer buf_utd-lines-attr          for ub.utd-lines-attr .
   define buffer un_utd-marking-lines        for ub.utd-marking-lines .
   define buffer parent_marking              for ub.marking .
   define buffer parent_utd-marking-lines    for ub.utd-marking-lines .
   define buffer buf_goods-attr              for ub.goods-attr.
   define buffer buf_marking-attr            for ub.marking-attr.                  
   define VARIABLE v-qnty       as decimal   no-undo .
   define VARIABLE v-rowid      as rowid     no-undo .
   define VARIABLE v-tbl-name   as character no-undo .
   define variable v-ungroup_ok as logical   no-undo .
   define variable v-gds-code   as integer   no-undo.
   define variable vFlag        as logical   no-undo.
   define variable v-gds-fl-wt  as logical   no-undo.
   
   b_cleaggds:sensitive in frame {&frame-name} = no.
   b_cleaggds:visible   in frame {&frame-name} = no.
   m-gds-code:visible   in frame {&frame-name} = no.
   
   F-text = "" .
   f-text:screen-value in frame {&frame-name} = "" .
   v-GTIN = "" .
   m-gds-code = ? .
   ASSIGN 
      v_list = 'Ё,Й,Ц,У,К,Е,Н,Г,Ш,Щ,З,Х,Ъ,Ф,Ы,В,А,П,Р,О,Л,Д,Ж,Э,Я,Ч,С,М,И,Т,Ь,Б,Ю':U .
  
   /*проверка на русские буквы*/
   do ii = 1 to length (v-mark):
      if LOOKUP( SUBSTRING( v-mark, ii, 1 ), v_list )  > 1 then
      do:
         message "Не корректно считана акцизная марка, перед считыванием переключите клавиатуру на английскую раскладку."
            view-as alert-box.
         v-mark:screen-value in frame {&frame-name} = "" .
         v-mark = "" .    
         return no-apply.  
      end.
   end.
   mMRCCode  = no.
   v-marking = GetCodeIdent(v-mark) .
   
  /* BTS-2596 Доп. проверка при обрезании КМ, что найденная марка не LEVEL2, иначе код берем целиком */
  if v-mark <> v-marking then
  do: 
    find first bf_marking exclusive-lock where bf_marking.mark begins v-marking no-error .
    if avail bf_marking and 
       bf_marking.unit-ext = "LEVEL2" then
    do:
      v-marking = v-mark.
    end.
  end.
   
/*   mMRCCode = no.*/
   if v-marking = "" or v-marking = ? then 
   do:
      F-text = "Товар не найден. Если сканируете КМ транспортной или груп. упак., то просканировать КМ потребительской упак., или верните товар поставщику." .
      
      display F-text with frame {&frame-name}.
      v-mark:screen-value = "" .
      v-mark = "" .
      return no-apply.
   end.  

   /*УПД проверка марок*/
   if p-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB then 
   do:
      /*Проверка марки*/
      /*           f-text = check_:CheckMarkUTD(v-mark, buf_utd.doc-id, buf_utd.db-num) .                                                                      */
      /*      if F-text = "" then do:                                                                                                                          */
      /*        for first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark begins v-mark and buf_utd-marking-lines.db-num = buf_utd.doc-id*/
      /*        and buf_utd-marking-lines.doc-id = buf_utd.db-num, first X_utd-lines exclusive-lock where X_utd-lines.LineNum = buf_utd-marking-lines.LineNum: */
      /*          recid_utd = recid (X_utd-lines) .                                                                                                            */
      /*          X_utd-lines.qnty-scan     = X_utd-lines.qnty-scan + 1  .                                                                                     */
      /*                                                                                                                                                       */
      /*      f-text = check_:CheckMarkUTD(v-mark, buf_utd.doc-id, buf_utd.db-num) .*/
      /*      if F-text = "" then do:                                               */
      
                  
      find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark begins v-marking and buf_utd-marking-lines.db-num = p-db-num 
         and buf_utd-marking-lines.doc-id = buf_utd.doc-id no-error .
      if available (buf_utd-marking-lines) then
      do:
         run checkEMRC(v-mark, output vFlag).         
         if not vFlag
         then do:
            F-text = "МРЦ на упаковке меньше ЕМЦ. Приемка товара запрещена." .
            display F-text with frame {&frame-name}.
            v-mark:screen-value = "" .
            v-mark = "" .
            return no-apply.
         end.
         if CheckErrForMarkLine(buffer buf_utd-marking-lines:handle)
         then do:
            F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .
               display F-text with frame {&frame-name}.
               v-mark:screen-value = "" .
               v-mark = "" .
               return no-apply.
         end.
         for first buf_marking no-lock where 
                   buf_marking.mark = buf_utd-marking-lines.mark and buf_marking.sts = Marking:Ungrouped:KeyIntDB
         :
            if isSaleMarkInUpak(buf_marking.mark) then
              F-text = "Марка уже проверена, просканируйте другую.".
            else 
              F-text = substitute(
                "&1 упаковка разгруппирована, просканируйте марку &2 упаковки.",
                if buf_marking.unit-ext = "LEVEL1" then "Групповая" else "Транспортная",
                if buf_marking.unit-ext = "LEVEL1" then "потребительской" else "групповой").
            display F-text with frame {&frame-name}.
            v-mark:screen-value = "" .
            v-mark = "" .
            return no-apply.
         end.
         find first X_utd-lines exclusive-lock where X_utd-lines.LineNum = buf_utd-marking-lines.LineNum no-error .
         if available (X_utd-lines) then
         do:  
             
            if X_utd-lines.sts_err then 
            do:
               F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .
               display F-text with frame {&frame-name}.
               v-mark:screen-value = "" .
               v-mark = "" .
               return no-apply.  
            end.
               
            if can-do(Marking:EqualChecked,string(buf_utd-marking-lines.sts)) then
            do:
               F-text = "Марка уже проверена, просканируйте следующую" .
               display F-text with frame {&frame-name}.
               v-mark:screen-value = "" .
               v-mark = "" .
               return no-apply.
            end.
            else
            do:
               if can-find (buf_marking where buf_marking.mark = buf_utd-marking-lines.mark and buf_marking.sts = Marking:MarkError:KeyIntDB)
                  then 
               do:
                  F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .
                  display F-text with frame {&frame-name}.
                  v-mark:screen-value = "" .
                  v-mark = "" .
                  return no-apply.
               end.                  
                  
            
               if can-find (buf_marking where buf_marking.mark = buf_utd-marking-lines.mark and buf_marking.sts = Marking:GrayZone:KeyIntDB)
                  then 
               do:
                  /*            message "Упаковка с неполным составом марок, необходимо просканировать все индивидуальные упаковки"*/
                  /*            view-as alert-box.                                                                                 */
                  empty temp-table tt-marking-lines .
                  for first gray_utd-marking-lines no-lock where gray_utd-marking-lines.db-num = X_utd-lines.db-num and gray_utd-marking-lines.doc-id = X_utd-lines.doc-id
                     and gray_utd-marking-lines.LineNum = X_utd-lines.LineNum and gray_utd-marking-lines.mark = buf_utd-marking-lines.mark:
                     for first gray_marking no-lock where gray_marking.mark = buf_utd-marking-lines.mark :
                        create tt-marking-lines .
                        assign
                           tt-marking-lines.gds-name    = GdsName(gray_utd-marking-lines.gds-code)
                           tt-marking-lines.stts-utd    = StatusTHName(gray_utd-marking-lines.sts)
                           tt-marking-lines.stts        = StatusTHName(gray_marking.sts)
                           tt-marking-lines.mark        = gray_marking.mark
                           tt-marking-lines.mark-parent = gray_marking.mark-parent
                           tt-marking-lines.gds-code    = gray_utd-marking-lines.gds-code
                           tt-marking-lines.sts         = gray_marking.sts
                           tt-marking-lines.sts-utd     = gray_utd-marking-lines.sts
                           tt-marking-lines.unit        = gray_marking.unit
                           tt-marking-lines.box-qnty    = gray_marking.box-qnty
                           tt-marking-lines.LineNum     = gray_utd-marking-lines.LineNum
                           tt-marking-lines.db-num      = gray_utd-marking-lines.db-num
                           tt-marking-lines.doc-id      = gray_utd-marking-lines.doc-id
                           tt-marking-lines.doc-level   = gray_utd-marking-lines.doc-level
                           .
                     end.
                     for each gray_unit-marking no-lock where gray_unit-marking.mark-parent = gray_utd-marking-lines.mark:
                        for first gray_unit_utd-marking-lines no-lock where gray_unit_utd-marking-lines.db-num = X_utd-lines.db-num and gray_unit_utd-marking-lines.doc-id = X_utd-lines.doc-id
                           and gray_unit_utd-marking-lines.LineNum = X_utd-lines.LineNum and gray_unit_utd-marking-lines.mark = gray_unit-marking.mark:
                           create tt-marking-lines .
                           assign
                              tt-marking-lines.gds-name    = GdsName(gray_unit_utd-marking-lines.gds-code)
                              tt-marking-lines.stts-utd    = StatusTHName(gray_unit_utd-marking-lines.sts)
                              tt-marking-lines.stts        = StatusTHName(gray_unit-marking.sts)
                              tt-marking-lines.mark        = gray_unit-marking.mark
                              tt-marking-lines.mark-parent = gray_unit-marking.mark-parent
                              tt-marking-lines.gds-code    = gray_unit_utd-marking-lines.gds-code
                              tt-marking-lines.sts         = gray_unit-marking.sts
                              tt-marking-lines.sts-utd     = gray_unit_utd-marking-lines.sts
                              tt-marking-lines.unit        = gray_unit-marking.unit
                              tt-marking-lines.unit-ext    = gray_unit-marking.unit-ext
                              tt-marking-lines.box-qnty    = gray_unit-marking.box-qnty
                              tt-marking-lines.LineNum     = gray_unit_utd-marking-lines.LineNum
                              tt-marking-lines.db-num      = gray_unit_utd-marking-lines.db-num
                              tt-marking-lines.doc-id      = gray_unit_utd-marking-lines.doc-id
                              tt-marking-lines.doc-level   = gray_unit_utd-marking-lines.doc-level
                              .
                        end.
                     end.
                  end.
                  run str/mark_browse.w (input parparentproc,
                     input-output table tt-marking-lines by-reference,
                     input p-mode,
                     input "Марки по товару " + string(X_utd-lines.gds-code) + " " + GdsName(X_utd-lines.gds-code) + " со статусом: " + StatusTHName(Marking:GrayZone:KeyIntDB),
                     input 6,
                     input "" /*тип продукции*/
                     ) no-error .
                  { gbl/brwrepos.i
                    &line-num= 5
                  }
               end.
               else 
               do:
                  if buf_utd-marking-lines.doc-level > 1 then 
                  do:
/*                     if can-find (ub.marking where ub.marking.mark = buf_utd-marking-lines.mark and ub.marking.unit-ext <> "UNIT") then                    */
/*                     do:                                                                                                                                   */
/*/*                                    if tree:LevelUpUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then do:*/*/
/*                        message "Разгруппировать упаковки?"                                                                                                */
/*                           view-as alert-box question buttons yes-no update ungroup.                                                                       */
/*                        if ungroup then                                                                                                                    */
/*                        do:                                                                                                                                */
/*                           if tree:UnGroupUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then                 */
/*                           do:                                                                                                                             */
/*                              message "Упаковка с маркой " + buf_utd-marking-lines.mark + " разгруппирована."                                              */
/*                                 view-as alert-box.                                                                                                        */
/*                           end.                                                                                                                            */
/*                        end.                                                                                                                               */
/*                     end.                                                                                                                                  */
/*                     else                                                                                                                                  */
/*                     do:                                                                                                                                   */
                        /* проверим что упаковка уже не разгруппирована */
                        find first ub.marking where ub.marking.mark = buf_utd-marking-lines.mark no-lock no-error.
                        if avail ub.marking and ub.marking.mark-parent <> "" then
                          find first parent_marking no-lock where 
                                     parent_marking.mark = ub.marking.mark-parent no-error.
                        if not avail parent_marking or parent_marking.sts <> Marking:Ungrouped:KeyIntDB
                        then do:
                          F-text = "            Марка входит в состав упаковки, просканируйте марку упаковки" .
                          display F-text with frame {&frame-name}.
                          v-mark:screen-value = "" .
                          v-mark = "" .
                          return no-apply.
                        end.
/*                     end.*/
                  end.
/*                  else*/
/*                  do: */
                     if X_utd-lines.isMarking
                     then do:
                        define variable vCheck as logical no-undo init yes.
                        do:
                           for first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.mark = buf_utd-marking-lines.mark and bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num and
                              bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id:
                                 find first buf_marking where buf_marking.mark eq bf_utd-marking-lines.mark no-lock no-error.

                              if     available buf_marking
/*                                 and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB*/
                                 and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
/*                                 and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB */
                                 and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
                                 and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
                                 and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB
                              then do:  
                                 if X_utd-lines.isWeight                       
                                 then do:
                                       find first buf_marking-attr where buf_marking-attr.mark eq buf_utd-marking-lines.mark
                                                                     and buf_marking-attr.attr-code eq "weight"
                                       no-lock no-error.
                                       if avail buf_marking-attr
                                       then 
                                       MESSAGE "Масса товара равна "
                                          (if decimal(buf_marking-attr.attr-value) < 1  and decimal(buf_marking-attr.attr-value) >= 0
                                              then string(decimal(buf_marking-attr.attr-value),"9.999")
                                              else buf_marking-attr.attr-value)
                                          X_utd-lines.UnitCode "?"
                                          VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                                          TITLE "" UPDATE lChoice AS LOGICAL.
                                       if lChoice then do:
                                           bf_utd-marking-lines.sts   = Marking:Checked_:KeyIntDB .
                                           if tree:LevelDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then 
                                           do:
                                              vCheck = tree:StatusDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num, Marking:Checked_:KeyIntDB) .
                                           end.
                                       end.         
                                       else do:
                                           MESSAGE "Масса товара не совпадает с данными из ГИС МТ. Товар не подлежит приемке"
                                           VIEW-AS ALERT-BOX.                                           
                                       end.                           
                                 end.    
                                 else do:                                
                                     bf_utd-marking-lines.sts   = Marking:Checked_:KeyIntDB .
                                     if tree:LevelDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then 
                                     do:
                                        vCheck = tree:StatusDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num, Marking:Checked_:KeyIntDB) .
                                     end.
                                 end.
                                 /* Проверим, если все марки упаковки проверены,                   */
                                 /* то надо сменить статус упаковки и ее "родителей" на "Проверен" */
                                 tree:StatusUpUTD(
                                    buf_marking.mark-parent, 
                                    buf_utd-marking-lines.db-num, 
                                    buf_utd-marking-lines.doc-id,
                                    Marking:Checked_:KeyIntDB
                                 ).
                              end.
                              else do:
                                 empty temp-table tt-marking-lines .
                                 for first gray_utd-marking-lines no-lock where gray_utd-marking-lines.db-num = X_utd-lines.db-num and gray_utd-marking-lines.doc-id = X_utd-lines.doc-id
                                    and gray_utd-marking-lines.LineNum = X_utd-lines.LineNum and gray_utd-marking-lines.mark = buf_utd-marking-lines.mark:
                                    for first gray_marking no-lock where gray_marking.mark = buf_utd-marking-lines.mark :
                                       create tt-marking-lines .
                                       assign
                                          tt-marking-lines.gds-name    = GdsName(gray_utd-marking-lines.gds-code)
                                          tt-marking-lines.stts-utd    = StatusTHName(gray_utd-marking-lines.sts)
                                          tt-marking-lines.stts        = StatusTHName(gray_marking.sts)
                                          tt-marking-lines.mark        = gray_marking.mark
                                          tt-marking-lines.mark-parent = gray_marking.mark-parent
                                          tt-marking-lines.gds-code    = gray_utd-marking-lines.gds-code
                                          tt-marking-lines.sts         = gray_marking.sts
                                          tt-marking-lines.sts-utd     = gray_utd-marking-lines.sts
                                          tt-marking-lines.unit        = gray_marking.unit
                                          tt-marking-lines.box-qnty    = gray_marking.box-qnty
                                          tt-marking-lines.LineNum     = gray_utd-marking-lines.LineNum
                                          tt-marking-lines.db-num      = gray_utd-marking-lines.db-num
                                          tt-marking-lines.doc-id      = gray_utd-marking-lines.doc-id
                                          tt-marking-lines.doc-level   = gray_utd-marking-lines.doc-level
                                          .
                                    end.
                                    for each gray_unit-marking no-lock where gray_unit-marking.mark-parent = gray_utd-marking-lines.mark:
                                       for first gray_unit_utd-marking-lines no-lock where gray_unit_utd-marking-lines.db-num = X_utd-lines.db-num and gray_unit_utd-marking-lines.doc-id = X_utd-lines.doc-id
                                          and gray_unit_utd-marking-lines.LineNum = X_utd-lines.LineNum and gray_unit_utd-marking-lines.mark = gray_unit-marking.mark:
                                          create tt-marking-lines .
                                          assign
                                             tt-marking-lines.gds-name    = GdsName(gray_unit_utd-marking-lines.gds-code)
                                             tt-marking-lines.stts-utd    = StatusTHName(gray_unit_utd-marking-lines.sts)
                                             tt-marking-lines.stts        = StatusTHName(gray_unit-marking.sts)
                                             tt-marking-lines.mark        = gray_unit-marking.mark
                                             tt-marking-lines.mark-parent = gray_unit-marking.mark-parent
                                             tt-marking-lines.gds-code    = gray_unit_utd-marking-lines.gds-code
                                             tt-marking-lines.sts         = gray_unit-marking.sts
                                             tt-marking-lines.sts-utd     = gray_unit_utd-marking-lines.sts
                                             tt-marking-lines.unit        = gray_unit-marking.unit
                                             tt-marking-lines.unit-ext    = gray_unit-marking.unit-ext
                                             tt-marking-lines.box-qnty    = gray_unit-marking.box-qnty
                                             tt-marking-lines.LineNum     = gray_unit_utd-marking-lines.LineNum
                                             tt-marking-lines.db-num      = gray_unit_utd-marking-lines.db-num
                                             tt-marking-lines.doc-id      = gray_unit_utd-marking-lines.doc-id
                                             tt-marking-lines.doc-level   = gray_unit_utd-marking-lines.doc-level
                                             .
                                       end.
                                    end.
                                 end.
                                 run str/mark_browse.w (input parparentproc,
                                    input-output table tt-marking-lines by-reference,
                                    input p-mode,
                                    input "Марки по товару " + string(X_utd-lines.gds-code) + " " + GdsName(X_utd-lines.gds-code) + " имеют ошибки. " ,
                                    input 7,
                                    input "" /*тип продукции*/
                                    ) no-error .
                                 { gbl/brwrepos.i
                             &line-num= 5
                           }
                           end.
                                       
   /*                           find first buf_marking where buf_marking.mark eq bf_utd-marking-lines.mark no-lock no-error.*/
   /*                           X_utd-lines.qnty-scan     = X_utd-lines.qnty-scan + if available buf_marking then buf_marking.box-qnty else 1  .*/
                           end.
                        end.
                        define variable v-q as decimal no-undo.
                        v-q = ObjSrv:Lib:MarkingTree:GetQntyCheckMark(buf_utd-marking-lines.db-num, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.LineNum).
                        SetAttrUtdlines(buf_utd-marking-lines.db-num,buf_utd-marking-lines.doc-id,buf_utd-marking-lines.linenum,"QuantityBarCode",string(v-q)).
                     end.
                     else if X_utd-lines.isArtic
                     then do: 
                        b_cleaggds:sensitive = yes.
                        b_cleaggds:visible = yes.
                        m-gds-code:visible = yes.
                        F-text:screen-value = "               Введите количество или просканируйте другой штрих-код" .
                        m-gds-code = getGTINBydm(v-mark).
                        m-gds-code:screen-value = string(v-gds-code).
                                
                        {&OPEN-QUERY-br-utd}            
                        reposition br-utd to recid recid_utd no-error .
                        apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
                        v-mark:screen-value = "" .
                        v-mark = "" .
                     end.
/* Если марка то не ищем бакркод*/
                     else do:
                        b_cleaggds:sensitive = yes.
                        b_cleaggds:visible = yes.
                        m-gds-code:visible = yes.
                        F-text:screen-value = "               Введите количество или просканируйте другой штрих-код" .
                        m-gds-code = string(getgdscodeBydm(v-mark)).
                        m-gds-code:screen-value = string(v-gds-code).

                        {&OPEN-QUERY-br-utd}
                        reposition br-utd to recid recid_utd no-error .
                        apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
                        v-mark:screen-value = "" .
                        v-mark = "" .
                     end.
/*                  end.*/
               end.  
            /*            if available (gray_marking) then do:                                               */
            /*              gray_marking.box-qnty = gray_marking.box-qnty - 1 .                              */
            /*              bf_utd-marking-lines.doc-level = bf_utd-marking-lines.doc-level - 1 .            */
            /*              if gray_marking.box-qnty = 0 then do:                                            */
            /*                    buf_utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB.*/
            /*                    buf_utd-marking-lines.doc-level = 0 .                                      */
            /*              end.                                                                             */
            /*            end.                                                                               */
            end.
            /*          end.*/
            run mark-temp (?).

            find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark begins v-marking and buf_utd-marking-lines.db-num = p-db-num 
               and buf_utd-marking-lines.doc-id = buf_utd.doc-id 
               /*                    and buf_utd-marking-lines.sts <> Marking:Checked_:KeyIntDB*/
               no-error .
            if available (buf_utd-marking-lines) then
            do:
               find first X_utd-lines exclusive-lock where X_utd-lines.LineNum = buf_utd-marking-lines.LineNum no-error .
               if available (X_utd-lines) then
                  recid_utd = recid (X_utd-lines) .
            end.
            else 
            do:
               find first X_utd-lines exclusive-lock where X_utd-lines.LineNum = 1 no-error .
               if available (X_utd-lines) then
          
                  recid_utd = recid (X_utd-lines) .
            end.    

            br-utd :refresh() no-error.
            reposition br-utd to recid recid_utd no-error .
            v-mark:screen-value = "" .
            v-mark = "" .
         end.
      end.
      else 
      do:
         find first buf_utd-marking-lines no-lock where 
                buf_utd-marking-lines.mark   begins v-marking 
            and buf_utd-marking-lines.db-num = p-db-num
            and buf_utd-marking-lines.doc-id <> p-doc-id no-error .
         if available buf_utd-marking-lines
         then
            find first buf_marking where buf_marking.mark eq buf_utd-marking-lines.mark no-lock no-error.
            
         if available (buf_utd-marking-lines)
            and available buf_marking 
            and (    buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
                 or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB
                 or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB
                 or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:ReturnWaitLock:KeyIntDB 
                 or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB)
         then 
         do:
            F-text = "             Товар поставлен на АЗС ранее, верните его на склад" .
            display F-text with frame {&frame-name}.
            v-mark:screen-value = "" .
            v-mark = "" .    
            return no-apply.  
         end. 
         else 
         do:
            m-gds-code = getgtinBydm(v-mark).
            find first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code
            no-lock no-error.
/*            if not available tt-utd-lines-filtr                                            */
/*            then do:                                                                       */
/*               m-gds-code = string(getgdscodeBydm(v-mark)).                                */
/*               find first tt-utd-lines-filtr where tt-utd-lines-filtr.bar-code = m-gds-code*/
/*               no-lock no-error.                                                           */
/*            end.                                                                           */
            if available tt-utd-lines-filtr
            then do:
               /* если товар с переменным весом */ 
               if WghProdVariable(buf_utd.obj-type, buf_utd.obj-code, getGdsCodeByGtin(m-gds-code)) 
               then do:
                  run add-mark-weight (v-mark, 
                                       m-gds-code, 
                                       buf_utd.doc-id, 
                                       buf_utd.db-num,                                         
                                       output recid_utd, 
                                       output F-text) .
                  v-gds-code = ?.
                  m-gds-code = ?.   
                  if recid_utd = ? then do:                                        
                       display F-text with frame {&frame-name}.
                       v-mark:screen-value = "" .
                       v-mark = "" .    
                       return no-apply.
                  end.                       
               end.   
               else do: 
                   b_cleaggds:sensitive = yes.
                   b_cleaggds:visible = yes.
                   m-gds-code:visible = yes.
                   F-text:screen-value = "               Введите количество или просканируйте другой штрих-код" .
                   m-gds-code:screen-value = m-gds-code.
               end.
               {&OPEN-QUERY-br-utd}            
               reposition br-utd to recid recid_utd no-error .
               apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
               v-mark:screen-value = "" .
               v-mark = "" .
               return no-apply.
            end.
            else do:
               v-gds-code = ?.
               m-gds-code = ?.
               F-text = "Товар не найден. Если сканируете КМ транспортной или груп. упак., то просканировать КМ потребительской упак., или верните товар поставщику." .
               display F-text with frame {&frame-name}.
               v-mark:screen-value = "" .
               v-mark = "" .    
               return no-apply.
            end.
         end.         
      end. 
   end.
   /*АКТ-приема*/
   if 
/*   (*/
           p-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB 
/*       or c-type = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB)*/
       and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then 
   do:

      if f-obj-type-th = "" then 
      do:
         message "Не выбран объект"
            view-as alert-box.
         v-mark:screen-value = "" .
         v-mark = "" .    
         return no-apply .
      end.
      if c-type = 0 then 
      do:
         message "Не выбран тип документа"
            view-as alert-box.
         v-mark:screen-value = "" .
         v-mark = "" .    
         return no-apply .
      end. 
  
      if CAN-FIND (first buf_utd-marking-lines where buf_utd-marking-lines.mark begins v-marking and buf_utd-marking-lines.db-num = buf_utd.db-num
         and buf_utd-marking-lines.doc-id = buf_utd.doc-id ) then 
      do:
         F-text = "                        Марка уже просканирована в этом документе " .
         display F-text with frame {&frame-name}.
         v-mark:screen-value = "" .
         v-mark = "" .  
         return.
      end.    
      for first buf_marking no-lock where buf_marking.mark begins v-marking and buf_marking.sts > Marking:UnknowSts:KeyIntDB:
           
         if buf_marking.loc-key begins "utd" then 
         do:
            run gen-row-keyr in this-procedure (
               input buf_marking.loc-key /*uniq-key-rec смены*/
               ,input ? /*p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */
               ,input "ub"
               ,input ? /*p-tt-handle буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
               ,input no-lock
               ,output v-rowid
               ,output v-tbl-name ) .
            if v-rowid <> ? then 
            do:
               find first ub.utd no-lock where rowid(ub.utd) = v-rowid no-error .
               F-text = "               Найдено УПД " + string(ub.utd.DocumentNumber) + " на поставку данной марки. Марка не может быть принята по Акту" .
            end.  
            else  F-text = "               Марка не может быть принята по Акту. Заблокирована" + buf_marking.loc-key . 
            /*                F-text = "               Найдено УПД " + string(ub.utd.DocumentNumber) + " на поставку данной марки. Марка не может быть принята по Акту" .*/
            display F-text with frame {&frame-name}.
            v-mark:screen-value = "" .
            v-mark = "" .    
            return.              
         end.
         if buf_marking.loc-key <> "" 
            or buf_marking.sts = Marking:Reserved:KeyIntDB 
            or buf_marking.sts = Marking:FreeZone:KeyIntDB 
            or buf_marking.sts = Marking:Checked_:KeyIntDB
            or buf_marking.sts = Marking:Ungrouped:KeyIntDB then 
         do:
            F-text = "        Марка зарегистрирована в системе. Статус марки " +  StatusTHName(buf_marking.sts).
            display F-text with frame {&frame-name}.
            v-mark:screen-value = "" .
            v-mark = "" .    
            return.              
         end.          
 
      end.  
      /*Создание марок*/
      v-GTIN = getGtinByDM(v-marking) .
      if v-GTIN <> "" or c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then 
      do:
         v-gds-code = getGdsCodeByGtin(v-GTIN) .

         find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
          
         if available (buf_goods) or c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then 
         do:
              
            find first buf_utd-lines where buf_utd-lines.doc-id = buf_utd.doc-id and buf_utd-lines.db-num = buf_utd.db-num
               and buf_utd-lines.gds-code = int(v-gds-code) no-error .
            if not available (buf_utd-lines) then 
            do:           
               find last X_utd-lines no-lock no-error . 
               if not available (X_utd-lines) then jj = 0 .
               else jj = X_utd-lines.LineNum .
               create buf_utd-lines .
               assign
                  buf_utd-lines.GdsName  = GdsName(v-gds-code)
                  buf_utd-lines.db-num   = buf_utd.db-num
                  buf_utd-lines.doc-id   = buf_utd.doc-id
                  buf_utd-lines.LineNum  = jj + 1
                  buf_utd-lines.gds-code = v-gds-code
                  buf_utd-lines.sts      = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB .
               buf_utd-lines.UnitCode = if available (buf_goods) then buf_goods.unit-base else ""
                  .
               create  X_utd-lines .
               buffer-copy buf_utd-lines to X_utd-lines .
               assign
                  X_utd-lines.stts = StatusTHName(buf_utd-lines.sts).
               X_utd-lines.gds-name = GdsName(v-gds-code).
               X_utd-lines.isMarking = CheckMarkUtdline(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum).
               X_utd-lines.isArtic   = logical(getAttrUtdLinesEx (buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,"ArticUtdLine","yes")).
               for each buf_parts no-lock where  buf_parts.artic = buf_goods.artic and
                  buf_parts.prod-code = buf_goods.prod-code and
                  buf_parts.prod-type = buf_goods.prod-type and 
                  buf_parts.out-code = {&free-code} and
                  buf_parts.obj-code = buf_utd.obj-code and
                  buf_parts.obj-type = buf_utd.obj-type : 
                  X_utd-lines.fact-qnty = X_utd-lines.fact-qnty + buf_parts.fact-qnty .
               end.       
               find first buf_utd-lines-attr exclusive-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
                  buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
                  buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
                  buf_utd-lines-attr.attr-code = "utd-fact-qnty" no-error .
               if not available (buf_utd-lines-attr) then 
               do:
                  create buf_utd-lines-attr .
                  assign
                     buf_utd-lines-attr.db-num    = X_utd-lines.db-num
                     buf_utd-lines-attr.doc-id    = X_utd-lines.doc-id
                     buf_utd-lines-attr.LineNum   = X_utd-lines.LineNum
                     buf_utd-lines-attr.attr-code = "utd-fact-qnty"
                     .
               end.                                              
               buf_utd-lines-attr.attr-value = string(X_utd-lines.fact-qnty) .                                     
            end.  
            recid_utd = recid(X_utd-lines) .
            create buf_utd-marking-lines .
            assign
               buf_utd-marking-lines.db-num    = buf_utd.db-num
               buf_utd-marking-lines.doc-id    = buf_utd.doc-id
               buf_utd-marking-lines.gds-code  = buf_utd-lines.gds-code
               buf_utd-marking-lines.LineNum   = buf_utd-lines.LineNum
               buf_utd-marking-lines.mark      = v-marking
               buf_utd-marking-lines.sts       = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB
               buf_utd-marking-lines.doc-level = 1
               .
            find first buf_marking exclusive-lock where buf_marking.mark begins v-marking no-error .
            if not available (buf_marking) then 
            do:            
               create buf_marking .
               assign
                  buf_marking.gds-code   = buf_utd-marking-lines.gds-code
                  buf_marking.mark       = v-marking
                  buf_marking.sts        = Marking:UnknowSts:KeyIntDB
                  buf_marking.gds-ext-id = v-GTIN
                  buf_marking.obj-code   = buf_utd.obj-code
                  buf_marking.obj-type   = buf_utd.obj-type
                  .
               buf_marking.unit-ext  = getLevelMotpBycodid(v-marking) .
               buf_marking.box-qnty  = getQntyUTDBycodid(v-marking) .
               buf_marking.unit = getLevelUTDBycodid(v-marking) .
            end.
            else 
            do:
               buf_marking.sts      = Marking:UnknowSts:KeyIntDB .
            end.    
            if buf_marking.box-qnty = ? or buf_marking.box-qnty = 0 then 
            do:
               v-qnty = 0 .
               run gbl/d-prompt.w (
                  'title=':u + "Ввод количества" + '\':u
                  + 'text1=':u + "Введите количество:" + '\':u
                  + 'format=' + ">>>>>9.99" + '\':u
                  + 'type=' + {&type-dec} + '\':u
                  + 'fillin_row=3\':u
                  + 'fillin_col=6\':u
                  + 'fillin_width=17\':u
                  + 'fillin_height=1\':u
                  + 'max-chars=17\':u     /*- максимальное количество символов для редактора*/
                  + 'readonly=no\':u
                  , input-output v-qnty
                  ).
               buf_marking.box-qnty = v-qnty .
               buf_marking.unit  = if available (buf_goods) then buf_goods.unit-base else "".
               buf_marking.unit-ext = "UNIT" .

            end.
            find first X_utd-lines exclusive-lock where X_utd-lines.gds-code = buf_utd-lines.gds-code and X_utd-lines.lineNum = buf_utd-lines.LineNum
               and X_utd-lines.db-num = buf_utd-lines.db-num and X_utd-lines.doc-id = buf_utd-lines.doc-id no-error .
            buf_utd-lines.Quantity  = buf_utd-lines.Quantity  + buf_marking.box-qnty .
            X_utd-lines.qnty-scan = X_utd-lines.qnty-scan + buf_marking.box-qnty .
            X_utd-lines.Quantity  = X_utd-lines.Quantity  + buf_marking.box-qnty .
            X_utd-lines.qnty-mark = X_utd-lines.qnty-mark + 1 .
                
            br-utd:refresh () no-error .
            reposition br-utd to recid recid_utd no-error . 
            v-mark:screen-value = "" .
            v-mark = "" .           
         end.
         else 
         do:
            F-text = "                GTIN - " + v-GTIN + " не привязан к товару в базе".
            display F-text with frame {&frame-name}.
            v-mark:screen-value = "" .
            v-mark = "" .
            return.  
         end.    
      end.
      else 
      do:
         F-text = "                              Нет возможности получить GTIN " .
         display F-text with frame {&frame-name}.
         v-mark:screen-value = "" .
         v-mark = "" .
         return.  
      end.    
   end. /*АКТ-Приема*/

   if c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then 
   do:

      if f-obj-type-th = "" then 
      do:
         message "Не выбран объект"
            view-as alert-box.
         v-mark:screen-value = "" .
         v-mark = "" .    
         return no-apply .
      end.
      if c-type = 0 then 
      do:
         message "Не выбран тип документа"
            view-as alert-box.
         v-mark:screen-value = "" .
         v-mark = "" .    
         return no-apply .
      end. 
  

      /*Создание марок*/
      v-GTIN = getGtinByDM(v-marking) .
      if v-GTIN <> "" or c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then 
      do:
         v-gds-code = getGdsCodeByGtin(v-GTIN) .

         find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
          
         if available (buf_goods) or c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then 
         do:
              
            find first buf_utd-lines where buf_utd-lines.doc-id = buf_utd.doc-id and buf_utd-lines.db-num = buf_utd.db-num
               and buf_utd-lines.gds-code = v-gds-code no-error .
            if not available (buf_utd-lines) then 
            do:           
               find last X_utd-lines no-lock no-error . 
               if not available (X_utd-lines) then jj = 0 .
               else jj = X_utd-lines.LineNum .
               create buf_utd-lines .
               assign
                  buf_utd-lines.GdsName  = GdsName(v-gds-code)
                  buf_utd-lines.db-num   = buf_utd.db-num
                  buf_utd-lines.doc-id   = buf_utd.doc-id
                  buf_utd-lines.LineNum  = jj + 1
                  buf_utd-lines.gds-code = v-gds-code
                  buf_utd-lines.sts      = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB .
               buf_utd-lines.UnitCode = if available (buf_goods) then buf_goods.unit-base else ""
                  .
               create  X_utd-lines .
               buffer-copy buf_utd-lines to X_utd-lines .
               assign
                  X_utd-lines.stts = StatusTHName(buf_utd-lines.sts).
               X_utd-lines.gds-name = GdsName(v-gds-code)
                  .
               X_utd-lines.isMarking = CheckMarkUtdline(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum).
               X_utd-lines.isArtic = logical(getAttrUtdLinesEx (buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,"ArticUtdLine","yes")).                
               for each buf_parts no-lock where  buf_parts.artic = buf_goods.artic and
                  buf_parts.prod-code = buf_goods.prod-code and
                  buf_parts.prod-type = buf_goods.prod-type and 
                  buf_parts.out-code = {&free-code} and
                  buf_parts.obj-code = buf_utd.obj-code and
                  buf_parts.obj-type = buf_utd.obj-type : 
                  X_utd-lines.fact-qnty = X_utd-lines.fact-qnty + buf_parts.fact-qnty .
               end.       
               find first buf_utd-lines-attr exclusive-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
                  buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
                  buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
                  buf_utd-lines-attr.attr-code = "utd-fact-qnty" no-error .
               if not available (buf_utd-lines-attr) then 
               do:
                  create buf_utd-lines-attr .
                  assign
                     buf_utd-lines-attr.db-num    = X_utd-lines.db-num
                     buf_utd-lines-attr.doc-id    = X_utd-lines.doc-id
                     buf_utd-lines-attr.LineNum   = X_utd-lines.LineNum
                     buf_utd-lines-attr.attr-code = "utd-fact-qnty"
                     .
               end.                                              
               buf_utd-lines-attr.attr-value = string(X_utd-lines.fact-qnty) .                                     
            end.  
            recid_utd = recid(X_utd-lines) .

            find first X_utd-lines exclusive-lock where X_utd-lines.gds-code = buf_utd-lines.gds-code and X_utd-lines.lineNum = buf_utd-lines.LineNum
               and X_utd-lines.db-num = buf_utd-lines.db-num and X_utd-lines.doc-id = buf_utd-lines.doc-id no-error .
            buf_utd-lines.Quantity  = buf_utd-lines.Quantity  + buf_marking.box-qnty .
            X_utd-lines.qnty-scan = X_utd-lines.qnty-scan .
            X_utd-lines.Quantity  = X_utd-lines.Quantity .
            br-utd:refresh () no-error .
            reposition br-utd to recid recid_utd no-error . 
            v-mark:screen-value = "" .
            v-mark = "" .           
         end.
         else 
         do:
            F-text = "                GTIN - " + v-GTIN + " не привязан к товару в базе".
            display F-text with frame {&frame-name}.
            v-mark:screen-value = "" .
            v-mark = "" .
            return.  
         end.    
      end.
      else 
      do:
         F-text = "                              Нет возможности получить GTIN " .
         display F-text with frame {&frame-name}.
         v-mark:screen-value = "" .
         v-mark = "" .
         return.  
      end.    
   end. /*АКТ-Приема*/
           
   /*Первоначальный ввод*/
   if p-type = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then 
   do:
      mMRCCode  = no.
      v-marking = GetCodeIdent(v-mark) .
      if f-obj-type-th = "" then 
      do:
         message "Не выбран объект"
            view-as alert-box.
         v-mark:screen-value = "" .
         v-mark = "" .    
         return no-apply .
      end.
      if c-type = 0 then 
      do:
         message "Не выбран тип документа"
            view-as alert-box.
         v-mark:screen-value = "" .
         v-mark = "" .    
         return no-apply .
      end. 
  
      find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark begins v-marking and buf_utd-marking-lines.db-num = buf_utd.db-num
         and buf_utd-marking-lines.doc-id = buf_utd.doc-id no-error .
      if available (buf_utd-marking-lines) then 
      do:
         F-text = "                        Марка уже просканирована в этом документе " .
         display F-text with frame {&frame-name}.
         v-mark:screen-value = "" .
         v-mark = "" .  
         return.
      end.    
      find first buf_marking no-lock where buf_marking.mark begins v-marking and buf_marking.sts >= Marking:OutZone:KeyIntDB no-error .
      if available (buf_marking) then 
      do:
         if buf_marking.sts <> Marking:GrayZone:KeyIntDB then 
         do:
            F-text = "                      Марка находится в обороте , статус марки –" + StatusTHName(buf_marking.sts) .
            display F-text with frame {&frame-name}.
            v-mark:screen-value = "" .
            v-mark = "" .    
            return.
         end. 
      end.                                    
      else 
      do:
         find first buf_marking no-lock where buf_marking.mark begins v-marking no-error .
         if available (buf_marking) then 
         do: 
            if buf_marking.sts < Marking:Received:KeyIntDB and buf_marking.loc-key <> "" and c-type <> objSrv:Env:Utd:EDocType:AKT:KeyIntDB then 
            do:

               F-text = "                                      Марка занята" .
               display F-text with frame {&frame-name}.
               v-mark:screen-value = "" .
               v-mark = "" .
               return.
            end.
            if buf_marking.sts = Marking:MarkError:KeyIntDB and c-type <> objSrv:Env:Utd:EDocType:AKT:KeyIntDB then 
            do:
               def variable v-error-mark as character no-undo .
               v-error-mark = "Marking" + {&delim-key} + buf_marking.mark .
               find first ub.utd-err no-lock where ub.utd-err.reckey = v-error-mark and
                  ub.utd-err.CodeErr = "MotpMarkErr" no-error .
               if not available (ub.utd-err) then 
               do:                                  
                  F-text = "                      Марка находится в статусе –" + StatusTHName(buf_marking.sts) .
                  display F-text with frame {&frame-name}.
                  v-mark:screen-value = "" .
                  v-mark = "" .
                  return.
               end.  
            end.
            if buf_marking.sts = Marking:DeliveryControl:KeyIntDB and c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then 
            do:
               F-text = "               Найдено УПД на поставку данной марки. Марка не может быть принята по Акту" .
               display F-text with frame {&frame-name}.
               v-mark:screen-value = "" .
               v-mark = "" .    
               return.              
            end.
            if buf_marking.sts <> Marking:UnknowSts:KeyIntDB and c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then 
            do:
               F-text = "        Марка зарегистрирована в системе. Статус марки " +  StatusTHName(buf_marking.sts).
               display F-text with frame {&frame-name}.
               v-mark:screen-value = "" .
               v-mark = "" .    
               return.              
            end.          
         end.
      end.  

      v-GTIN = getGtinByDM(v-marking) .
      if v-GTIN <> "" or c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then 
      do:
         v-gds-code = getGdsCodeByGtin(v-GTIN) .

         find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
          
         if available (buf_goods) or c-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB then 
         do:
            find first buf_utd-lines where buf_utd-lines.doc-id = buf_utd.doc-id and buf_utd-lines.db-num = buf_utd.db-num
               and buf_utd-lines.gds-code = v-gds-code no-error .
            if not available (buf_utd-lines) then 
            do:           
               find last X_utd-lines no-lock no-error . 
               if not available (X_utd-lines) then jj = 0 .
               else jj = X_utd-lines.LineNum .
               create buf_utd-lines .
               assign
                  buf_utd-lines.GdsName  = GdsName(v-gds-code)
                  buf_utd-lines.db-num   = buf_utd.db-num
                  buf_utd-lines.doc-id   = buf_utd.doc-id
                  buf_utd-lines.LineNum  = jj + 1
                  buf_utd-lines.gds-code = v-gds-code
                  buf_utd-lines.sts      = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB .
               buf_utd-lines.UnitCode = if available (buf_goods) then buf_goods.unit-base else ""
                  .
               create  X_utd-lines .
               buffer-copy buf_utd-lines to X_utd-lines .
               assign
                  X_utd-lines.stts = StatusTHName(buf_utd-lines.sts).
               X_utd-lines.gds-name = GdsName(v-gds-code)
                  .
               X_utd-lines.isMarking = CheckMarkUtdline(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum).
               X_utd-lines.isArtic = logical(getAttrUtdLinesEx (buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,"ArticUtdLine","yes")).
               for each buf_parts no-lock where  buf_parts.artic = buf_goods.artic and
                  buf_parts.prod-code = buf_goods.prod-code and
                  buf_parts.prod-type = buf_goods.prod-type and 
                  buf_parts.out-code = {&free-code} and
                  buf_parts.obj-code = buf_utd.obj-code and
                  buf_parts.obj-type = buf_utd.obj-type : 
                  X_utd-lines.fact-qnty = X_utd-lines.fact-qnty + buf_parts.fact-qnty .
               end.       
               find first buf_utd-lines-attr exclusive-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
                  buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
                  buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
                  buf_utd-lines-attr.attr-code = "utd-fact-qnty" no-error .
               if not available (buf_utd-lines-attr) then 
               do:
                  create buf_utd-lines-attr .
                  assign
                     buf_utd-lines-attr.db-num    = X_utd-lines.db-num
                     buf_utd-lines-attr.doc-id    = X_utd-lines.doc-id
                     buf_utd-lines-attr.LineNum   = X_utd-lines.LineNum
                     buf_utd-lines-attr.attr-code = "utd-fact-qnty"
                     .
               end.                                              
               buf_utd-lines-attr.attr-value = string(X_utd-lines.fact-qnty) .                                     
            end.  
            recid_utd = recid(X_utd-lines) .
            create buf_utd-marking-lines .
            assign
               buf_utd-marking-lines.db-num    = buf_utd.db-num
               buf_utd-marking-lines.doc-id    = buf_utd.doc-id
               buf_utd-marking-lines.gds-code  = buf_utd-lines.gds-code
               buf_utd-marking-lines.LineNum   = buf_utd-lines.LineNum
               buf_utd-marking-lines.mark      = v-marking
               buf_utd-marking-lines.sts       = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB
               buf_utd-marking-lines.doc-level = 1
               .
            find first buf_marking exclusive-lock where buf_marking.mark begins v-marking no-error .
            if not available (buf_marking) then 
            do:            
               create buf_marking .
               assign
                  buf_marking.gds-code   = buf_utd-marking-lines.gds-code
                  buf_marking.mark       = v-marking
                  buf_marking.sts        = Marking:PendingVerification:KeyIntDB
                  buf_marking.gds-ext-id = v-GTIN
                  buf_marking.obj-code   = buf_utd.obj-code
                  buf_marking.obj-type   = buf_utd.obj-type
                  .
               buf_marking.unit-ext  = getLevelMotpBycodid(v-marking) .
               buf_marking.box-qnty  = getQntyUTDBycodid(v-marking) .
               buf_marking.unit = getLevelUTDBycodid(v-marking) .
            end.
            else 
            do:
               buf_marking.sts      = Marking:PendingVerification:KeyIntDB .
            end.    
            if buf_marking.box-qnty = ? or buf_marking.box-qnty = 0 then 
            do:
               v-qnty = 0 .   
               run gbl/d-prompt.w (
                  'title=':u + "Ввод количества" + '\':u
                  + 'text1=':u + "Введите количество:" + '\':u
                  + 'format=' + ">>>>>9.99" + '\':u
                  + 'type=' + {&type-dec} + '\':u
                  + 'fillin_row=3\':u
                  + 'fillin_col=6\':u
                  + 'fillin_width=17\':u
                  + 'fillin_height=1\':u
                  + 'max-chars=17\':u     /*- максимальное количество символов для редактора*/
                  + 'readonly=no\':u
                  , input-output v-qnty
                  ).
               buf_marking.box-qnty = v-qnty .
               buf_marking.unit  = if available (buf_goods) then buf_goods.unit-base else "".
               buf_marking.unit-ext = "UNIT" .

            end.
            find first X_utd-lines exclusive-lock where X_utd-lines.gds-code = buf_utd-lines.gds-code and X_utd-lines.lineNum = buf_utd-lines.LineNum
               and X_utd-lines.db-num = buf_utd-lines.db-num and X_utd-lines.doc-id = buf_utd-lines.doc-id no-error .
            buf_utd-lines.Quantity  = buf_utd-lines.Quantity  + buf_marking.box-qnty .
            X_utd-lines.qnty-scan = X_utd-lines.qnty-scan + buf_marking.box-qnty .
            X_utd-lines.Quantity  = X_utd-lines.Quantity  + buf_marking.box-qnty .
            X_utd-lines.qnty-mark = X_utd-lines.qnty-mark + 1 .
            br-utd:refresh () no-error .
            reposition br-utd to recid recid_utd no-error . 
            v-mark:screen-value = "" .
            v-mark = "" .           
         end.
         else 
         do:
            F-text = "                GTIN - " + v-GTIN + " не привязан к товару в базе".
            display F-text with frame {&frame-name}.
            v-mark:screen-value = "" .
            v-mark = "" .
            return.  
         end.    
      end.
      else 
      do:
         F-text = "                              Нет возможности получить GTIN " .
         display F-text with frame {&frame-name}.
         v-mark:screen-value = "" .
         v-mark = "" .
         return.  
      end.  

      for first buf_marking exclusive-lock where buf_marking.mark begins v-marking and buf_marking.sts = Marking:GrayZone:KeyIntDB:
         /*Добавление марки в серую зону из первоначального ввода*/
         empty temp-table tt-marking-lines .
         for first gray_utd-marking-lines no-lock where gray_utd-marking-lines.db-num = X_utd-lines.db-num and gray_utd-marking-lines.doc-id = X_utd-lines.doc-id
            and gray_utd-marking-lines.LineNum = X_utd-lines.LineNum and gray_utd-marking-lines.mark = buf_utd-marking-lines.mark:
            for first gray_marking no-lock where gray_marking.mark = buf_utd-marking-lines.mark :
               create tt-marking-lines .
               assign
                  tt-marking-lines.gds-name    = GdsName(gray_utd-marking-lines.gds-code)
                  tt-marking-lines.stts-utd    = StatusTHName(gray_utd-marking-lines.sts)
                  tt-marking-lines.stts        = StatusTHName(gray_marking.sts)
                  tt-marking-lines.mark        = gray_marking.mark
                  tt-marking-lines.mark-parent = gray_marking.mark-parent
                  tt-marking-lines.gds-code    = gray_utd-marking-lines.gds-code
                  tt-marking-lines.sts         = gray_marking.sts
                  tt-marking-lines.sts-utd     = gray_utd-marking-lines.sts
                  tt-marking-lines.unit        = gray_marking.unit
                  tt-marking-lines.box-qnty    = gray_marking.box-qnty
                  tt-marking-lines.LineNum     = gray_utd-marking-lines.LineNum
                  tt-marking-lines.db-num      = gray_utd-marking-lines.db-num
                  tt-marking-lines.doc-id      = gray_utd-marking-lines.doc-id
                  tt-marking-lines.doc-level   = gray_utd-marking-lines.doc-level
                  .
            end.
            for each gray_unit-marking no-lock where gray_unit-marking.mark-parent = gray_utd-marking-lines.mark:
               for first gray_unit_utd-marking-lines no-lock where gray_unit_utd-marking-lines.mark = gray_unit-marking.mark:
                  create tt-marking-lines .
                  assign
                     tt-marking-lines.gds-name    = GdsName(gray_unit_utd-marking-lines.gds-code)
                     tt-marking-lines.stts-utd    = StatusTHName(gray_unit_utd-marking-lines.sts)
                     tt-marking-lines.stts        = StatusTHName(gray_unit-marking.sts)
                     tt-marking-lines.mark        = gray_unit-marking.mark
                     tt-marking-lines.mark-parent = gray_unit-marking.mark-parent
                     tt-marking-lines.gds-code    = gray_unit_utd-marking-lines.gds-code
                     tt-marking-lines.sts         = gray_unit-marking.sts
                     tt-marking-lines.sts-utd     = gray_unit_utd-marking-lines.sts
                     tt-marking-lines.unit        = gray_unit-marking.unit
                     tt-marking-lines.unit-ext    = gray_unit-marking.unit-ext
                     tt-marking-lines.box-qnty    = gray_unit-marking.box-qnty
                     tt-marking-lines.LineNum     = gray_unit_utd-marking-lines.LineNum
                     tt-marking-lines.db-num      = gray_unit_utd-marking-lines.db-num
                     tt-marking-lines.doc-id      = gray_unit_utd-marking-lines.doc-id
                     tt-marking-lines.doc-level   = gray_unit_utd-marking-lines.doc-level
                     .
               end.
            end.
         end.
         run str/mark_browse.w (input parparentproc,
            input-output table tt-marking-lines by-reference,
            input p-mode,
            input "Марки по товару " + string(X_utd-lines.gds-code) + " " + GdsName(X_utd-lines.gds-code) + " со статусом: " + StatusTHName(Marking:GrayZone:KeyIntDB),
            input 6,
            input "" /*тип продукции*/
            ) no-error .
         { gbl/brwrepos.i
              &line-num= 5
            }
      end.
   end. /*Первоначальный ввод*/
   if c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then 
   do:
      find first X_utd-lines no-lock where X_utd-lines.stts <> "Проверен" no-error .
      if available (X_utd-lines) then 
      do:
         F-text = "                            Просканируйте марку" .
         f-text:screen-value = "" .
         display F-text with frame {&frame-name} .
      end.
      else 
      do:
         F-text = "" .
         f-text:screen-value = "" .
         display F-text with frame {&frame-name} .
      end.  
      find first X_utd-lines no-lock where recid (X_utd-lines) = recid_utd and X_utd-lines.stts = "Проверен" no-error .
      if available (X_utd-lines) then 
      do:
         {&OPEN-QUERY-br-utd}
      end.   
   end. 
   display F-text with frame {&frame-name}.
   v-mark:screen-value = "" .
   v-mark = "" .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save_bar-code d-utd 
PROCEDURE save_bar-code :
   /* --------------------------------------------------------------------
                             Purpose:     ENABLE the User Interface
                             Parameters:  <none>
                             Notes:       Here we display/view/enable the widgets in the
                                          user-interface.  In addition, OPEN all queries
                                          associated with each FRAME and BROWSE.
                                          These statements here are based on the "Other
                                          Settings" section of the widget Property Sheets.
                              -------------------------------------------------------------------- */
   define variable v_list    as character no-undo .
   define variable ii        as integer   no-undo .
   define variable jj        as integer   no-undo .
   define variable v-marking as character no-undo .
   define buffer buf_parts                   for ub.parts .
   define buffer gray_marking                for ub.marking .
   define buffer gray_unit-marking           for ub.marking .
   define buffer gray_utd-marking-lines      for ub.utd-marking-lines .
   define buffer gray_unit_utd-marking-lines for ub.utd-marking-lines .
   define buffer buf_utd-lines-attr          for ub.utd-lines-attr .
   define buffer un_utd-marking-lines        for ub.utd-marking-lines .
   define buffer buf_bar-code                for ub.bar-code .
   define buffer buf_prod-bc                 for ub.prod-bc .
   define VARIABLE v-qnty       as decimal   no-undo .
   define VARIABLE v-rowid      as rowid     no-undo .
   define VARIABLE v-tbl-name   as character no-undo .
   define variable v-ungroup_ok as logical   no-undo .
   define variable v-gds-code as integer no-undo.
   if p-mode = {&lookup} then 
   do:
      v-Mark:screen-value in frame {&frame-name} = "" .
      v-Mark = "" .
   end .
   if v-Mark:screen-value in frame {&frame-name} = ""
      then 
   do:
      v-Mark:screen-value in frame {&frame-name} = v-scan-str.
   end.

   v-scan-str = "". 
   assign 
      v-Mark = v-Mark:screen-value in frame {&frame-name}.

   F-text = "" .
   f-text:screen-value = "" .
   v-GTIN = "" .
   m-gds-code = ? .
   v-gds-code = ?.
   ASSIGN 
      v_list = 'Ё,Й,Ц,У,К,Е,Н,Г,Ш,Щ,З,Х,Ъ,Ф,Ы,В,А,П,Р,О,Л,Д,Ж,Э,Я,Ч,С,М,И,Т,Ь,Б,Ю':U .
  
   /*проверка на русские буквы*/
   do ii = 1 to length (v-Mark):
      if LOOKUP( SUBSTRING( v-Mark, ii, 1 ), v_list )  > 1 then
      do:
         message "Не корректно считан штрих-код, перед считыванием переключите клавиатуру на английскую раскладку."
            view-as alert-box.
         v-Mark:screen-value = "" .
         v-Mark = "" .    
         return no-apply.  
      end.
   end.
   if v-Mark = "" or v-Mark = ? then 
   do:
      F-text = "            Ошибка чтения штрих-кода" .
      display F-text with frame {&frame-name}.
      v-Mark:screen-value = "" .
      v-Mark = "" .
      return no-apply.
   end.     
   mMRCCode  = yes.

  /* v-marking = GetCodeIdent(v-Mark) .
   mMRCCode = no.
   if v-marking <> "" and v-marking <> ? then 
   do:
      v-GTIN = getGtinByDM(v-marking) .
      if v-GTIN <> ""  then m-gds-code = string(getGdsCodeByGtin(v-GTIN)) . 
   end.   
   else */
   do:
      for first buf_prod-bc no-lock where buf_prod-bc.b-str = v-Mark,
         first buf_bar-code no-lock where buf_bar-code.b-code = buf_prod-bc.b-code and
         buf_bar-code.stts_ = 0:
         define variable v-par-val  as character no-undo.
         define variable v-par-type as character no-undo.
         &scop proc-name gds-attr-value
                {&run_proc_attr-lib}
                    ( buf_bar-code.gds-code,
                      {&attr-mark-type},
                       output v-par-val,
                       output v-par-type
                    ).
         if (  EDOParSec:GetIsEDOForType(v-par-val) 
            or EDOParSec:GetIsArticForType(v-par-val))
          and IS-NeedMark(buf_prod-bc.b-code,buf_prod-bc.b-str)
         then do:
            F-text = "           Штрих-код подлежит обязательной маркировке. Просканируйте марку." .
            display F-text with frame {&frame-name}.
            v-Mark:screen-value = "" .
            v-Mark = "" .
            return no-apply.
         
         end.
         else
            v-gds-code = buf_bar-code.gds-code .
      end.
      if v-gds-code eq ?
      then do:
         F-text = "   Просканированный код не найден. Просканируйте Data Matrix или верните товар поставщику." .
         display F-text with frame {&frame-name}.
         v-Mark:screen-value = "" .
         v-Mark = "" .
         return no-apply.
      end.   
   end.   

   /*УПД проверка штрих-кода*/
   if p-type = objSrv:Env:Utd:EDocType:UTD:KeyIntDB then 
   do:
      /*      find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = v-bar-code and buf_utd-marking-lines.db-num = p-db-num*/
      /*         and buf_utd-marking-lines.doc-id = buf_utd.doc-id no-error .                                                                          */
      /*      if available (buf_utd-marking-lines) then                                                                                                */
      /*      do:                                                                                                                                      */
      block-u-l:
      for each X_utd-lines no-lock where X_utd-lines.gds-code = v-gds-code :
        /* if not X_utd-lines.isArtic
         then 
            leave block-u-l.
         else do:
            if length (v-Mark) eq 14
            then do:
               for each bf_utd-marking-lines where (bf_utd-marking-lines.db-num  eq X_utd-lines.db-num
                                                and bf_utd-marking-lines.doc-id  eq X_utd-lines.doc-id
                                                and bf_utd-marking-lines.LineNum eq X_utd-lines.LineNum
                                                and bf_utd-marking-lines.mark    begins "01" + v-Mark + "21" )
                                                or
                                                   (bf_utd-marking-lines.db-num  eq X_utd-lines.db-num
                                                and bf_utd-marking-lines.doc-id  eq X_utd-lines.doc-id
                                                and bf_utd-marking-lines.LineNum eq X_utd-lines.LineNum
                                                and bf_utd-marking-lines.mark    begins "02" + v-Mark + "37" )
                                                or 
                                                   (bf_utd-marking-lines.db-num  eq X_utd-lines.db-num
                                                and bf_utd-marking-lines.doc-id  eq X_utd-lines.doc-id
                                                and bf_utd-marking-lines.LineNum eq X_utd-lines.LineNum
                                                and bf_utd-marking-lines.mark    begins "02" + v-Mark + "21" )
               no-lock:
                  leave block-u-l.
               end.
            end.
         end.*/
         leave block-u-l.
      end.
      if available (X_utd-lines) then
      do:  
         if X_utd-lines.sts_err then 
         do:
            F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .
            display F-text with frame {&frame-name}.
            v-Mark:screen-value = "" .
            v-Mark = "" .
            return no-apply.  
         end.  
         /*            if buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB then              */
         /*            do:                                                                        */
         /*               F-text = "            Штрих-код уже проверен, просканируйте следующий" .*/
         /*               display F-text with frame {&frame-name}.                                */
         /*               v-Bar-Code:screen-value = "" .                                          */
         /*               v-Bar-Code = "" .                                                       */
         /*               return no-apply.                                                        */
         /*            end.                                                                       */
         /*            else                                                                       */
         /*            do:                                                                        */
         /*               if can-find (buf_marking where buf_marking.mark = buf_utd-marking-lines.mark and buf_marking.sts = Marking:MarkError:KeyIntDB)*/
         /*                  then                                                                                                                       */
         /*               do:                                                                                                                           */
         /*                  F-text = "Товар не подлежит приемке, т.к. не прошел проверку на корректность" .                                            */
         /*                  display F-text with frame {&frame-name}.                                                                                   */
         /*                  v-Bar-Code:screen-value = "" .                                                                                             */
         /*                  v-Bar-Code = "" .                                                                                                          */
         /*                  return no-apply.                                                                                                           */
         /*               end.                                                                                                                          */
         /*                                                                                                                                             */
         /*               buf_utd-marking-lines.sts = Marking:Checked_:KeyIntDB .                                                                       */

         X_utd-lines.qnty-scan:COLUMN-READ-ONLY IN BROWSE br-utd = FALSE.
/*         run mark-temp (?).*/

         /*               find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = v-bar-code and buf_utd-marking-lines.db-num = p-db-num*/
         /*                  and buf_utd-marking-lines.doc-id = buf_utd.doc-id                                                                                     */
         /*                  no-error .                                                                                                                            */
         /*               if available (buf_utd-marking-lines) then                                                                                                */
         /*               do:                                                                                                                                      */
         find first X_utd-lines exclusive-lock where X_utd-lines.gds-code = v-gds-code no-error .
         if available (X_utd-lines) then
            recid_utd = recid (X_utd-lines) .
         /*               end.                                                                             */
         /*               else                                                                             */
         /*               do:                                                                              */
         /*                  find first X_utd-lines exclusive-lock where X_utd-lines.LineNum = 1 no-error .*/
         /*                  if available (X_utd-lines) then                                               */
         /*                                                                                                */
         /*                     recid_utd = recid (X_utd-lines) .                                          */
         /*               end.                                                                             */

         /*               br-utd-nomark :refresh() no-error.*/
         m-gds-code = string(v-gds-code).
         b_cleaggds:sensitive = yes.
         b_cleaggds:visible = yes.
         m-gds-code:visible = yes.
         F-text:screen-value = "               Введите количество или просканируйте другой штрих-код" .
         m-gds-code:screen-value = m-gds-code.
                 
         {&OPEN-QUERY-br-utd}            
         reposition br-utd to recid recid_utd no-error .
         apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
         v-mark:screen-value = "" .
         v-mark = "" .
         return no-apply .
      /*            end.*/
      end.
      else 
      do :
         F-text = "Просканированный код не найден. Просканируйте Data Matrix или верните товар поставщику." .
         display F-text with frame {&frame-name}.
         v-Mark:screen-value = "" .
         v-Mark = "" .
         b_cleaggds:visible = no.
         m-gds-code:visible = no.
         m-gds-code = ?.
         {&OPEN-QUERY-br-utd}            
         apply "VALUE-CHANGED" to br-utd IN FRAME d-utd.
          return no-apply .
      end.
   end.
   
   
   
   /*АКТ-приема */ 
   if p-type = objSrv:Env:Utd:EDocType:AKT:KeyIntDB and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then 
   do:

      if f-obj-type-th = "" then 
      do:
         message "Не выбран объект"
            view-as alert-box.
         v-Mark:screen-value = "" .
         v-mark = "" .    
         return no-apply .
      end.
      if c-type = 0 then 
      do:
         message "Не выбран тип документа"
            view-as alert-box.
         v-Mark:screen-value = "" .
         v-Mark = "" .    
         return no-apply .
      end. 
  
      /*      if CAN-FIND (first buf_utd-marking-lines where buf_utd-marking-lines.mark = v-bar-code and buf_utd-marking-lines.db-num = buf_utd.db-num                             */
      /*         and buf_utd-marking-lines.doc-id = buf_utd.doc-id ) then                                                                                                          */
      /*      do:                                                                                                                                                                  */
      /*         F-text = "                        Штрих-код уже просканирована в этом документе " .                                                                               */
      /*         display F-text with frame {&frame-name}.                                                                                                                          */
      /*         v-bar-code:screen-value = "" .                                                                                                                                    */
      /*         v-bar-code = "" .                                                                                                                                                 */
      /*         return.                                                                                                                                                           */
      /*      end.                                                                                                                                                                 */
      /*      for first buf_marking no-lock where buf_marking.mark = v-bar-code and buf_marking.sts > Marking:UnknowSts:KeyIntDB:                                                  */
      /*                                                                                                                                                                           */
      /*         if buf_marking.loc-key begins "utd" then                                                                                                                          */
      /*         do:                                                                                                                                                               */
      /*            run gen-row-keyr in this-procedure (                                                                                                                           */
      /*               input buf_marking.loc-key /*uniq-key-rec смены*/                                                                                                            */
      /*               ,input ? /*p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */                                                                     */
      /*               ,input "ub"                                                                                                                                                 */
      /*               ,input ? /*p-tt-handle буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */                                                         */
      /*               ,input no-lock                                                                                                                                              */
      /*               ,output v-rowid                                                                                                                                             */
      /*               ,output v-tbl-name ) .                                                                                                                                      */
      /*            if v-rowid <> ? then                                                                                                                                           */
      /*            do:                                                                                                                                                            */
      /*               find first ub.utd no-lock where rowid(ub.utd) = v-rowid no-error .                                                                                          */
      /*               F-text = "               Найдено УПД " + string(ub.utd.DocumentNumber) + " на поставку данного штрих-кода. Штрих-код не может быть принят по Акту" .        */
      /*            end.                                                                                                                                                           */
      /*            else  F-text = "               Штрих-код не может быть принят по Акту. Заблокирован" + buf_marking.loc-key .                                                   */
      /*            /*                F-text = "               Найдено УПД " + string(ub.utd.DocumentNumber) + " на поставку данной марки. Марка не может быть принята по Акту" .*/*/
      /*            display F-text with frame {&frame-name}.                                                                                                                       */
      /*            v-bar-code:screen-value = "" .                                                                                                                                 */
      /*            v-bar-code = "" .                                                                                                                                              */
      /*            return.                                                                                                                                                        */
      /*         end.                                                                                                                                                              */
      /*         if buf_marking.loc-key <> ""                                                                                                                                      */
      /*            or buf_marking.sts = Marking:Reserved:KeyIntDB                                                                                                                 */
      /*            or buf_marking.sts = Marking:FreeZone:KeyIntDB                                                                                                                 */
      /*            or buf_marking.sts = Marking:Checked_:KeyIntDB                                                                                                                 */
      /*            or buf_marking.sts = Marking:Ungrouped:KeyIntDB then                                                                                                           */
      /*         do:                                                                                                                                                               */
      /*            F-text = "        Штрих-код зарегистрирован в системе. Статус штрих-кода " +  StatusTHName(buf_marking.sts).                                                   */
      /*            display F-text with frame {&frame-name}.                                                                                                                       */
      /*            v-bar-code:screen-value = "" .                                                                                                                                 */
      /*            v-bar-code = "" .                                                                                                                                              */
      /*            return.                                                                                                                                                        */
      /*         end.                                                                                                                                                              */
      /*                                                                                                                                                                           */
      /*      end.                                                                                                                                                                 */
      /*Создание штрих-кода*/

/*      if c-type = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB then*/
/*      do:*/
         /*         v-gds-code = getGdsCodeByGtin(v-bar-code) .*/

         find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
          
         if available (buf_goods) 
/*         and c-type = objSrv:Env:Utd:EDocType:AKTNoMark:KeyIntDB зачем это здесь выше такаяже проверка*/
         then 
         do:
              
            find first buf_utd-lines where buf_utd-lines.doc-id = buf_utd.doc-id and buf_utd-lines.db-num = buf_utd.db-num
               and buf_utd-lines.gds-code = v-gds-code no-error .
            if not available (buf_utd-lines) then 
            do:           
               find last X_utd-lines no-lock no-error . 
               if not available (X_utd-lines) then jj = 0 .
               else jj = X_utd-lines.LineNum .
               create buf_utd-lines .
               assign
                  buf_utd-lines.GdsName  = GdsName(v-gds-code)
                  buf_utd-lines.db-num   = buf_utd.db-num
                  buf_utd-lines.doc-id   = buf_utd.doc-id
                  buf_utd-lines.LineNum  = jj + 1
                  buf_utd-lines.gds-code = v-gds-code
                  buf_utd-lines.sts      = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB .
               buf_utd-lines.UnitCode = if available (buf_goods) then buf_goods.unit-base else ""
                  .
               create  X_utd-lines .
               buffer-copy buf_utd-lines to X_utd-lines .
               assign
                  X_utd-lines.stts = StatusTHName(buf_utd-lines.sts).
               X_utd-lines.gds-name = GdsName(v-gds-code)
                  .
               X_utd-lines.ismarking = CheckMarkUtdline(buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum).
               X_utd-lines.isArtic = logical(getAttrUtdLinesEx (buf_utd-lines.db-num,buf_utd-lines.doc-id,buf_utd-lines.LineNum,"ArticUtdLine","yes")).
               for each buf_parts no-lock where  buf_parts.artic = buf_goods.artic and
                  buf_parts.prod-code = buf_goods.prod-code and
                  buf_parts.prod-type = buf_goods.prod-type and 
                  buf_parts.out-code = {&free-code} and
                  buf_parts.obj-code = buf_utd.obj-code and
                  buf_parts.obj-type = buf_utd.obj-type : 
                  X_utd-lines.fact-qnty = X_utd-lines.fact-qnty + buf_parts.fact-qnty .
               end.       
               find first buf_utd-lines-attr exclusive-lock where buf_utd-lines-attr.db-num = X_utd-lines.db-num and
                  buf_utd-lines-attr.doc-id = X_utd-lines.doc-id and
                  buf_utd-lines-attr.LineNum = X_utd-lines.LineNum and
                  buf_utd-lines-attr.attr-code = "utd-fact-qnty" no-error .
               if not available (buf_utd-lines-attr) then 
               do:
                  create buf_utd-lines-attr .
                  assign
                     buf_utd-lines-attr.db-num    = X_utd-lines.db-num
                     buf_utd-lines-attr.doc-id    = X_utd-lines.doc-id
                     buf_utd-lines-attr.LineNum   = X_utd-lines.LineNum
                     buf_utd-lines-attr.attr-code = "utd-fact-qnty"
                     .
               end.                                              
               buf_utd-lines-attr.attr-value = string(X_utd-lines.fact-qnty) .                                     
            end.  
            recid_utd = recid(X_utd-lines) .
            create buf_utd-marking-lines .
            assign
               buf_utd-marking-lines.db-num    = buf_utd.db-num
               buf_utd-marking-lines.doc-id    = buf_utd.doc-id
               buf_utd-marking-lines.gds-code  = buf_utd-lines.gds-code
               buf_utd-marking-lines.LineNum   = buf_utd-lines.LineNum
               buf_utd-marking-lines.mark      = v-mark
               buf_utd-marking-lines.sts       = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB
               buf_utd-marking-lines.doc-level = 1
               .
            /*            find first buf_marking exclusive-lock where buf_marking.mark = v-bar-code no-error .*/
            /*            if not available (buf_marking) then                                                 */
            /*            do:                                                                                 */
            /*               create buf_marking .                                                             */
            /*               assign                                                                           */
            /*                  buf_marking.gds-code   = buf_utd-marking-lines.gds-code                       */
            /*                  buf_marking.mark       = v-bar-code                                           */
            /*                  buf_marking.sts        = Marking:UnknowSts:KeyIntDB                           */
            /*                  buf_marking.gds-ext-id = v-GTIN                                               */
            /*                  buf_marking.obj-code   = buf_utd.obj-code                                     */
            /*                  buf_marking.obj-type   = buf_utd.obj-type                                     */
            /*                  .                                                                             */
            /*               buf_marking.unit-ext  = getLevelMotpBycodid(v-bar-code) .                        */
            /*               buf_marking.unit = getLevelUTDBycodid(v-bar-code) .                              */
            /*            end.                                                                                */
            /*            else                                                                                */
            /*            do:                                                                                 */
            /*               buf_marking.sts      = Marking:UnknowSts:KeyIntDB .                              */
            /*            end.                                                                                */
            /*            if buf_marking.box-qnty = ? or buf_marking.box-qnty = 0 then                        */
            /*            do:                                                                                 */
            /*               apply "row-leave" to br-utd-nomark  in frame {&frame-name} .                     */
            /*               buf_marking.box-qnty = X_utd-lines.qnty-scan .                                   */
            /*               buf_marking.unit  = if available (buf_goods) then buf_goods.unit-base else "".   */
            /*               buf_marking.unit-ext = "UNIT" .                                                  */
            /*                                                                                                */
            /*            end.                                                                                */
            /*               find first X_utd-lines exclusive-lock where X_utd-lines.gds-code = buf_utd-lines.gds-code and X_utd-lines.lineNum = buf_utd-lines.LineNum*/
            /*                  and X_utd-lines.db-num = buf_utd-lines.db-num and X_utd-lines.doc-id = buf_utd-lines.doc-id no-error .                                */
            /*               buf_utd-lines.Quantity  = buf_utd-lines.Quantity  + buf_marking.box-qnty .                                                               */
            /*               X_utd-lines.qnty-scan = X_utd-lines.qnty-scan + buf_marking.box-qnty .                                                                   */
            /*               X_utd-lines.Quantity  = X_utd-lines.Quantity  + buf_marking.box-qnty .                                                                   */
            /*               X_utd-lines.qnty-mark = X_utd-lines.qnty-mark + 1 .                                                                                      */
                
            br-utd:refresh () no-error .
            reposition br-utd to recid recid_utd no-error . 
            v-mark:screen-value = "" .
            v-mark = "" .           
         end.
         else 
         do:
            F-text = "                Штрих-код - " + v-Mark + " не привязан к товару в базе".
            display F-text with frame {&frame-name}.
            v-mark:screen-value = "" .
            v-mark = "" .
            return.  
         end.    
/*      end.*/
   end. /*АКТ-Приема*/
        
   /*Первоначальный ввод*/
   if p-type = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB then 
   do:
      mMRCCode  = no.

      if f-obj-type-th = "" then 
      do:
         message "Не выбран объект"
            view-as alert-box.
         v-mark:screen-value = "" .
         v-mark = "" .    
         return no-apply .
      end.
      if c-type = 0 then 
      do:
         message "Не выбран тип документа"
            view-as alert-box.
         v-Mark:screen-value = "" .
         v-mark = "" .    
         return no-apply .
      end. 
  
      find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark = v-mark and buf_utd-marking-lines.db-num = buf_utd.db-num
         and buf_utd-marking-lines.doc-id = buf_utd.doc-id no-error .
      if available (buf_utd-marking-lines) then 
      do:
         F-text = "                        Штрих-код уже просканирован в этом документе " .
         display F-text with frame {&frame-name}.
         v-mark:screen-value = "" .
         v-mark = "" .  
         return.
      end.    
   end. /*Первоначальный ввод*/
        
   if c-status = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB then 
   do:
      find first X_utd-lines no-lock where X_utd-lines.stts <> "Проверен" no-error .
      if available (X_utd-lines) then 
      do:
         if v-gds-code ne ?
            then 
         do:
            assign
               F-text:screen-value = "               Введите количество или просканируйте другой штрих-код" 
               F-text.
         end.
         else 
         do:
            F-text = "                Приемка товара невозможна, передайте товар поставщику" .
            display F-text with frame {&frame-name} .
         end.
      end.
      else 
      do:
         F-text = "" .
         f-text:screen-value = "" .
         display F-text with frame {&frame-name} .
      end.  
      find first X_utd-lines no-lock where recid (X_utd-lines) = recid_utd and X_utd-lines.stts = "Проверен" no-error .
      if available (X_utd-lines) then 
      do:
         {&OPEN-QUERY-br-utd}
      end.   
   end. 
   display F-text with frame {&frame-name}.
   v-mark:screen-value = "" .
   v-mark = "" .
   
               

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save_mol d-utd 
PROCEDURE save_mol :
   /* --------------------------------------------------------------------
                             Purpose:     ENABLE the User Interface
                             Parameters:  <none>
                             Notes:       Here we display/view/enable the widgets in the
                                          user-interface.  In addition, OPEN all queries
                                          associated with each FRAME and BROWSE.
                                          These statements here are based on the "Other
                                          Settings" section of the widget Property Sheets.
                              -------------------------------------------------------------------- */
   find first buf_utd-attr exclusive-lock where buf_utd-attr.db-num = buf_utd.db-num and buf_utd-attr.doc-id = buf_utd.doc-id and buf_utd-attr.attr-code = "wrkr" no-error .
   if not available (buf_utd-attr) then 
   do:
      create buf_utd-attr .
      assign
         buf_utd-attr.db-num    = buf_utd.db-num
         buf_utd-attr.doc-id    = buf_utd.doc-id
         buf_utd-attr.attr-code = "wrkr"
         .
   end.  
   buf_utd-attr.attr-value = string(f-wrkr) .
   find first buf_utd-attr exclusive-lock where buf_utd-attr.db-num = buf_utd.db-num and buf_utd-attr.doc-id = buf_utd.doc-id and buf_utd-attr.attr-code = "agnt" no-error .
   if not available (buf_utd-attr) then 
   do:
      create buf_utd-attr .
      assign
         buf_utd-attr.db-num    = buf_utd.db-num
         buf_utd-attr.doc-id    = buf_utd.doc-id
         buf_utd-attr.attr-code = "agnt"
         .
   end.  
   buf_utd-attr.attr-value = string(f-agnt) .
   find first buf_utd-attr exclusive-lock where buf_utd-attr.db-num = buf_utd.db-num and buf_utd-attr.doc-id = buf_utd.doc-id and buf_utd-attr.attr-code = "boss" no-error .
   if not available (buf_utd-attr) then 
   do:
      create buf_utd-attr .
      assign
         buf_utd-attr.db-num    = buf_utd.db-num
         buf_utd-attr.doc-id    = buf_utd.doc-id
         buf_utd-attr.attr-code = "boss"
         .
   end.  
   buf_utd-attr.attr-value = string(f-boss) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LoadKeyboardLayoutA d-utd
procedure LoadKeyboardLayoutA external "user32" :
   define input  parameter P1 as char.
   define input  parameter P2 as LONG.
   define return parameter pret as LONG.
end procedure.
        
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME 
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ActivateKeyboardLayout d-utd 
procedure ActivateKeyboardLayout external "user32" :
   define input parameter P1 as LONG.
   define input parameter P2 as LONG.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-any-key Dialog-Frame 
PROCEDURE proc-any-key :
   if v-scan-str = ""
   then etime(yes).
      
      if  not v-manual and v-scan-str ne ""
      then do: 
         if etime > 2000
            then 
         do:
            if  log-manager:logfile-name ne ?
            then do:
 def var speed as int64 no-undo.
               speed = etime.
               log-manager:write-message(substitute('Последовательность символов "&1" была сброшена после &2 мс',v-scan-str, speed), "ScanSpeed"). 
            end.
            v-scan-str = "".
            etime(yes).
         end.
     end.
   v-scan-str = v-scan-str + last-event:label.
    
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* Процедура создания марки для товара с переменным весом */
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-mark-weight Dialog-Frame 
PROCEDURE add-mark-weight :
    define input  parameter iMark     as character no-undo.
    define input  parameter iGTIN     as character no-undo.
    define input  parameter iDocId    as integer   no-undo.
    define input  parameter iDbNum    as integer   no-undo.          
    
    define output parameter oRecUtd as recid     no-undo.  
    define output parameter oTxt    as character no-undo.
    
    define variable vWeight as decimal no-undo.
    define variable vFnd    as logical no-undo.
    define variable vChkWeight as logical no-undo.
    define variable vUnitCode  as character no-undo.
    define variable vMarkShort as character no-undo.
    define variable vGdsCode  as integer   no-undo.
    /*define variable vRecKey as character no-undo.*/
        
    define buffer bX_utd-lines for X_utd-lines.
    define buffer buf_utd-marking-lines for ub.utd-marking-lines.
    define buffer buf_utd-marking-lines-attr for ub.utd-marking-lines-attr.
    define buffer tt-utd-lines-filtr for tt-utd-lines-filtr.   
    define buffer buf_marking  for ub.marking .
    define buffer buf_marking-attr for ub.marking-attr.
    define buffer buf_utd-lines-attr for ub.utd-lines-attr.
    
    assign
        vChkWeight = no
        vMarkShort = GetCodeIdent(iMark)
        vGdsCode = getGdsCodeByGtin(m-gds-code)
        .
    
    /* проверяем если марка есть ее статус */
    find first buf_marking no-lock where buf_marking.mark begins vMarkShort no-error .
    if not avail buf_marking then .
    else if 
       (buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB
         or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
         or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
         or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:Freezone:KeyIntDB 
         or buf_marking.sts eq ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB)
    then .
    /* марка есть и она в некорректном статусе - не добавляем */
    else do:
       assign
          oRecUtd = ?    
          oTxt = "Товар не подлежит приемке, т. к. не прошел проверку на корректность"
          .
          return "".
    end.            
    
    /* проверяем, есть ли привязка к другому УПД */
    if ChkAnotherUtd(iDocId, iDbNum, vMarkShort) 
    then do:
       find first buf_marking-attr where buf_marking-attr.mark begins vMarkShort
                                     and buf_marking-attr.attr-code eq "weight"
          no-lock no-error.
       if avail buf_marking-attr
       then do:
          vWeight = decimal(buf_marking-attr.attr-value) no-error.
          if vWeight <> 0 and vWeight <> ? then do:
              vUnitCode = gdsunit (vGdsCode).
              MESSAGE "Масса товара равна "
                  (if vWeight < 1  and vWeight >= 0
                      then string(vWeight,"9.999")
                      else string(vWeight))
                  vUnitCode "?"
                  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                  TITLE "" UPDATE lChoice AS LOGICAL.
              /* марку привязываем и запоминаем, что вес на ней не меняем */
              if lChoice then do:
                  vChkWeight = yes.
              end.
              /* не подтвердили вес - не привязываем эту марку */
              else do:
                  assign
                     oRecUtd = ?    
                     oTxt = "Масса товара не совпадает с данными в системе. Товар не подлежит приемке." 
                     .
                  return .   
              end.    
          end.
          /* к другому УПД привязан, но вес нулевой или ошибочный на марке */
          else run str/add-weight.w (vGdsCode, output vWeight).    
       end.
       /* к другому УПД привязан, но вес не задан на марке */
       else run str/add-weight.w (vGdsCode, output vWeight).
    end.            
    else run str/add-weight.w (vGdsCode, output vWeight).
    if vWeight = 0 then do:
        MESSAGE "Вес товара обязательный"        
        VIEW-AS ALERT-BOX.
        return "".
    end. 
    assign
       oRecUtd = ?    
       vFnd = no
       .
       
    /*if avail buf_utd then   
    run gen-key-rec ("utd", 
                     input  buffer buf_utd:handle, 
                     output vRecKey).*/
                             
    utline:
    for each bX_utd-lines where 
             bX_utd-lines.doc-id = iDocId
         and bX_utd-lines.db-num = iDbNum
         and bX_utd-lines.gds-code = vGdsCode
         and bX_utd-lines.isArtic = yes   
         by bX_utd-lines.LineNum :                      
         vFnd = yes.      
         if bX_utd-lines.PieceFact < bX_utd-lines.PieceTTH
         and bX_utd-lines.qnty-scan + vWeight <= bX_utd-lines.Quantity 
         then do:                                       
            oRecUtd = recid(bX_utd-lines) .
            create buf_utd-marking-lines .
            assign
               buf_utd-marking-lines.db-num    = bX_utd-lines.db-num
               buf_utd-marking-lines.doc-id    = bX_utd-lines.doc-id
               buf_utd-marking-lines.gds-code  = bX_utd-lines.gds-code
               buf_utd-marking-lines.LineNum   = bX_utd-lines.LineNum
               buf_utd-marking-lines.mark      = vMarkShort
               buf_utd-marking-lines.sts       = Marking:Checked_:KeyIntDB .
               buf_utd-marking-lines.doc-level = 1
               .
            /* Помечаем запись, что мы ее создали при добавлении весовой марки */   
            setattrUtdMarkingLines(buf_utd-marking-lines.db-num,
                                   buf_utd-marking-lines.doc-id,
                                   buf_utd-marking-lines.LineNum,
                                   buf_utd-marking-lines.mark, 
                                   "AddMarkWeight", 
                                   "yes") .   
            find first buf_marking exclusive-lock where buf_marking.mark begins vMarkShort no-error .
            if not available (buf_marking) 
            and not locked buf_marking then                                                 
            do:                                                                                                  
                 create buf_marking .                                                             
                 assign                                                                           
                    buf_marking.gds-code   = buf_utd-marking-lines.gds-code                       
                    buf_marking.mark       = vMarkShort                                          
                    buf_marking.sts        = Marking:DeliveryControl:KeyIntDB                     
                    buf_marking.gds-ext-id = iGTIN                                               
                    buf_marking.obj-code   = buf_utd.obj-code                                     
                    buf_marking.obj-type   = buf_utd.obj-type                                                                                                                                  
                    buf_marking.box-qnty   = 1                                    
                    buf_marking.unit       = getLevelUTDByCodId(iMark)     
                    buf_marking.unit-ext   = "UNIT" 
                    /*buf_marking.loc-key    = vRecKey.*/
                    .                              
            end.         
            
            if not vChkWeight then do:             
                /* атрибут вес */
                find first buf_marking-attr where 
                           buf_marking-attr.attr-code eq "weight"
                       and buf_marking-attr.mark eq buf_marking.mark
                     exclusive-lock no-error.            
                if not available buf_marking-attr
                   and not locked buf_marking-attr 
                then
                do:
                  create buf_marking-attr.
                  assign
                    buf_marking-attr.mark = buf_marking.mark
                    buf_marking-attr.attr-code = "weight"
                  .
                end.
                 
                if available buf_marking-attr 
                then buf_marking-attr.attr-value = if vWeight < 1  
                                                      then string(vWeight,"9.999") 
                                                      else string(vWeight).
            end.                                                                                   
            
            assign                                                                                                                                                                                                           
                bX_utd-lines.qnty-scan = bX_utd-lines.qnty-scan + vWeight                                                                                                                                                        
                bX_utd-lines.qnty-mark = bX_utd-lines.qnty-mark + 1 
                bX_utd-lines.PieceFact = String(int(bX_utd-lines.PieceFact) + 1) no-error
                .
                                
            setattrUtdlines(bX_utd-lines.db-num,
                            bX_utd-lines.doc-id,
                            bX_utd-lines.LineNum,
                            "QuantityBarCode",
                            string(bX_utd-lines.qnty-scan)).
            setattrUtdlines(bX_utd-lines.db-num,
                            bX_utd-lines.doc-id,
                            bX_utd-lines.LineNum,
                            "QuantityPiece",
                            bX_utd-lines.PieceFact).      
            /*if bX_utd-lines.Quantity = bX_utd-lines.qnty-scan then bX_utd-lines.stts = "Проверен" .*/                                                                                            
            recid_utd = recid (bX_utd-lines) .
            run mark-temp (?).                                                                   
            leave utline.                                
         end.
    end.    
    /* нашли GTIN, но он не подошел */
    if vFnd and oRecUtd = ? then 
       oTxt = "Внимание! Масса/количество товара не может быть больше массы/количества, переданной в УПД." .
    /* не нашли строку с GTIN */    
    else if not vFnd then
       oTxt = "Товар не найден. Если сканируете КМ транспортной или груп. упак., то просканировать КМ потребительской упак., или верните товар поставщику." .        
        
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION CliName d-utd 
FUNCTION CliName RETURNS CHARACTER
   (input p-cli-code as integer, input p-cli-type as character) :
   /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  
   ------------------------------------------------------------------------------*/
   define variable v-cli-name as character no-undo .
   find first buf_clients no-lock where buf_clients.obj-code = p-cli-code
      and buf_clients.obj-type = p-cli-type no-error .
   if available (buf_clients) then v-cli-name = buf_clients.obj-name .
   RETURN v-cli-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION ContName d-utd 
FUNCTION ContName RETURNS CHARACTER
   ( input p-contract-code as integer, input p-host-code as integer ) :
   /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  
   ------------------------------------------------------------------------------*/
   define variable v-contract-name as character no-undo .
   find first buf_contract no-lock where buf_contract.contract-code = p-contract-code and buf_contract.host-code = p-host-code no-error .
   if available (buf_contract) then v-contract-name = buf_contract.contract-name .
   RETURN v-contract-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION GdsName d-utd 
FUNCTION GdsName RETURNS CHARACTER
   ( input p-gds-code as integer) :
   /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  
   ------------------------------------------------------------------------------*/
   define variable v-gds-name as character no-undo .
   define buffer buf_goods for ub.goods .
  
   find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
   if available (buf_goods) then v-gds-name = buf_goods.gds-name .
   RETURN v-gds-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION GdsUnit d-utd 
FUNCTION GdsUnit RETURNS CHARACTER
   ( input p-gds-code as integer) :
   /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  
   ------------------------------------------------------------------------------*/
   define variable v-gds-unit as character no-undo .
   define buffer buf_goods for ub.goods .
  
   find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
   if available (buf_goods) then v-gds-unit = buf_goods.unit-base .
   RETURN v-gds-unit.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION StatusName d-utd 
FUNCTION StatusName RETURNS CHARACTER
   ( input p-doc-id as integer,
   input p-db-num as integer) :
   /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  
   ------------------------------------------------------------------------------*/
   define variable v-status-name as character no-undo .
   define buffer buf_utd-attr for ub.utd-attr .
  
   find first buf_utd-attr no-lock where buf_utd-attr.doc-id = p-doc-id and
      buf_utd-attr.db-num = p-db-num and
      buf_utd-attr.attr-code = "sendcode"  no-error .
   if available (buf_utd-attr) then 
   do:
      case buf_utd-attr.attr-value:
         when "2" then 
            do:
               v-status-name = "(С расхождением)" .
            end.
         when "3" then 
            do:
               v-status-name = "(Не принято)" .
            end.
         otherwise 
         do:
            v-status-name = "" .
         end.       
      end case .   
   end.           
   else v-status-name = "" .                                
   RETURN v-status-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION ChkAnotherUtd d-utd 
FUNCTION ChkAnotherUtd RETURNS LOGICAL
   ( input p-doc-id as integer,
     input p-db-num as integer,
     input p-mark as character
     ) :
   /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  
   ------------------------------------------------------------------------------*/   
   define buffer buf_utd-marking-lines for ub.utd-marking-lines .
   define variable vAvail as logical no-undo.
   vAvail = no.
   uml:
   for each buf_utd-marking-lines no-lock where
            buf_utd-marking-lines.mark begins p-mark
        :
        if buf_utd-marking-lines.doc-id <> p-doc-id
           or buf_utd-marking-lines.db-num  <> p-db-num
        then do:
            vAvail = yes.
            leave uml.
        end.       
   end.          
                                                       
   RETURN vAvail.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



