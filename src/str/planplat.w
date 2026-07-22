&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Планирование платежей

Автор: Кочетков Михаил Юрьевич
Дата создания: 09/29/05
Author: Michael Kochetkov
Creation date: 09/29/05

*/

/*------------------------------------------------------------------------*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-type     as character no-undo . /* {&income} {&expense} */

define variable p-status       as character no-undo . /* "all", "current" "deleted" */
define variable p-host-code    as integer   no-undo . /* надо передавать фирму */
define variable p-doc-type     as character no-undo . /* {&income} {&expense} */
define variable p-fo-type     as character no-undo . /* {&income} {&expense} */


/* Local Variable Definitions ---                                       */

def var vss-revision    as character no-undo init "$Revision$":u .

def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Планирование платежей" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ cmp/library.i  }
{ gbl/usr-flt.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/fltopend.i defproc }

assign
  p-host-code = v-cntxt-host-code-obj
.

if p-type = "inc"
then do:
  assign
    p-doc-type = {&income}
    p-fo-type = {&expense}
  .
end.
else do:
  assign
    p-doc-type = {&expense}
    p-fo-type = {&income}
  .
end.

  define buffer buf_fin-doc   for fin-doc .
  define buffer buf_fin-ob    for fin-ob .
  define buffer buf_contract  for contract.
  define buffer buf1_contract for contract.

  find first sysconf no-lock where sysconf.host-code = p-host-code .

  define variable cli-list        as character no-undo .
  define variable cont-list        as character no-undo .
  define variable g-log            as logical   no-undo .
  define variable curr-code        as integer   no-undo .
  define variable v-doc-rec        as recid no-undo .
  define variable v-doc-rec1       as recid no-undo .
  define variable sort-column-name as character no-undo .
  define variable sort-column-name1 as character no-undo .

  define variable p-gen  as character no-undo .
  define variable l-curr  as character no-undo .
  define variable p-contr as character no-undo .
  define variable p-sum   as decimal   no-undo .
  define variable filter-point as character no-undo init "Планирование платежей" .

  define variable num-fin-ob as integer initial 0 no-undo .
  define variable num-fin-doc as integer initial 0 no-undo .
  define variable ind1 as integer initial 0 no-undo .
  define variable ind2 as integer initial 0 no-undo .

  define variable v-conn-avt  as character no-undo .
  define variable v-par-type  as character     no-undo.

  define variable v-list as character no-undo .
  define variable v-end as logical   no-undo .
  define variable sel-date as logical initial no no-undo .

  define variable v-order-col  as character no-undo .
  define variable v-order-col1 as character no-undo .
  define variable v-size-col1 as decimal   no-undo .
  define variable v-size-col2 as decimal   no-undo .
  define variable v-size-col3 as decimal   no-undo .
  define variable v-size-col4 as decimal   no-undo .
  define variable v-size-col5 as decimal   no-undo .
  DEFINE VARIABLE v-payer-code as integer  no-undo .    
  DEFINE VARIABLE v-payer-type as character  no-undo .    

  run uf-get in this-procedure(
     input  {&uf-planplat}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
  )  no-error.
  if error-status :error then message  vss-workfile vss-revision vss-description skip  error-status :get-message(1) skip  return-value skip  ""  view-as alert-box error .

  if not error-status:error then do:
    v-order-col  = entry ( 1, v-uf-List_ ,{&delim-par} ) no-error.
    v-order-col1 = entry ( 2, v-uf-List_ ,{&delim-par} ) no-error.
    v-size-col1  = decimal (entry(3, v-uf-List_ ,{&delim-par})) no-error.
    v-size-col2  = decimal (entry(4, v-uf-List_ ,{&delim-par})) no-error.
    v-size-col3  = decimal (entry(5, v-uf-List_ ,{&delim-par})) no-error.
    v-size-col4  = decimal (entry(6, v-uf-List_ ,{&delim-par})) no-error.
    v-size-col5  = decimal (entry(7, v-uf-List_ ,{&delim-par})) no-error.
    if v-size-col1 = 0 or v-size-col1 = ? then v-size-col1 = 15.
    if v-size-col2 = 0 or v-size-col2 = ? then v-size-col2 = 15.
    if v-size-col3 = 0 or v-size-col3 = ? then v-size-col3 = 10.
    if v-size-col4 = 0 or v-size-col4 = ? then v-size-col4 = 15.
    if v-size-col5 = 0 or v-size-col5 = ? then v-size-col5 = 15.

    if v-order-col = ""  or v-order-col = ?  then v-order-col = "2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19".
    if v-order-col1 = "" or v-order-col1 = ? then v-order-col1 = "2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21".
 end.



  DEFINE temp-table temp-fin-ob no-undo
    field   ri             as  recid
    field   ind            as integer
    field   del            as logical
    INDEX pi  IS PRIMARY   ind
    INDEX pi1  ri
    INDEX pi2  del
  .

  DEFINE temp-table temp-fin-doc no-undo
    field   ri             as  recid
    field   ind            as integer
    field   del            as logical
    INDEX pi  IS PRIMARY   ind
    INDEX pi1  ri
    INDEX pi2  del
  .

  DEFINE temp-table tp-contr no-undo
    field   id             as integer
    INDEX pi  IS PRIMARY   id
  .
  define buffer temp-contr   for tp-contr.
  define buffer temp-contr1  for tp-contr.

/*фин. обязательства*/

&scop col-l0   '*'
&scop col-l1  'Т'
/*&scop col-l2  'Статус'*/
&scop col-l3  '№ док-та'
&scop col-l4  'Платеж'
&scop col-l11 'Сумма в вал. док-та'
&scop col-l16 'Сумма связи (в.д.)'
&scop col-l18 'Своб. остаток (в.д.)'
&scop col-l5  'Закрыт'
&scop col-l6  'Договор'
&scop col-l7  'Код получ.'
&scop col-l71 'Получатель'
&scop col-l8  'Код плател.'
&scop col-l81 'Плательщик'
&scop col-l9  'Создан'
&scop col-l10 'Вал'
&scop col-l14 'Сумма в выбр.вал.'
&scop col-l12 'Объект'
&scop col-l13 'Вн.N'
&scop col-l17 'Условие генерации'

&scop head-col ~
 {&col-l0} + '#' + ~
 {&col-l1} + '#' + ~
 {&col-l3} + '#' + ~
 {&col-l4} + '#' + ~
 {&col-l11} + '#' + ~
 {&col-l16} + '#' + ~
 {&col-l18} + '#' + ~
 {&col-l5} + '#' + ~
 {&col-l6} + '#' + ~
 {&col-l7} + '#' + ~
 {&col-l71} + '#' + ~
 {&col-l8} + '#' + ~
 {&col-l81} + '#' + ~
 {&col-l9} + '#' + ~
 {&col-l10} + '#' + ~
 {&col-l14} + '#' + ~
 {&col-l12} + '#' + ~
 {&col-l13} + '#' + ~
 {&col-l17}


&scop cop-l0  mark-string(recid(ub.buf_fin-ob), 0)
&scop cop-l1  buf_fin-ob.doc-type
/*&scop cop-l2  buf_fin-ob.status_*/
&scop cop-l3  buf_fin-ob.prn-doc-code
&scop cop-l4  buf_fin-ob.pay-date
&scop cop-l14 get-curr-sum(s-curr-code, buf_fin-ob.curr-code, buf_fin-ob.contract-curr, buf_fin-ob.sum-contract, buf_fin-ob.sum-rubl, buf_fin-ob.sum-base, buf_fin-ob.sum-doc )
&scop dyn_cop-l14 substitute('dynamic-function(&1get-curr-sum&1,&2,&3,&4,&5,&6,&7,&8)', ~{&double-quote~}, s-curr-code, buf_fin-ob.curr-code, buf_fin-ob.contract-curr, buf_fin-ob.sum-contract, buf_fin-ob.sum-rubl, buf_fin-ob.sum-base, buf_fin-ob.sum-doc)
&scop cop-l16 buf_fin-ob.con-sum-contr
/*&scop cop-l18 (buf_fin-ob.sum-contr - buf_fin-ob.con-sum-contr)*/
&scop cop-l18 get-ostat(buf_fin-ob.sum-contr, buf_fin-ob.con-sum-contr)
&scop dyn_cop-l18 substitute('dynamic-function(&1get-ostat&1,&2,&3)', ~{&double-quote~}, buf_fin-ob.sum-contr, buf_fin-ob.con-sum-contr)
&scop cop-l5  buf_fin-ob.fact-date
&scop cop-l6  (contract-id( buf_fin-ob.contract-code ))
&scop dyn_cop-l6 substitute('dynamic-function(&1contract-id&1,&2)', ~{&double-quote~}, buf_fin-ob.contract-code)
&scop cop-l7  (buf_fin-ob.receiver-type + ' ' + string(buf_fin-ob.receiver-code))
&scop cop-l71 buf_fin-ob.receiver-name
&scop cop-l8  (buf_fin-ob.payer-type + ' ' + string(buf_fin-ob.payer-code))
&scop cop-l81 buf_fin-ob.payer-name
&scop cop-l9  buf_fin-ob.doc-date
&scop cop-l10 (get-currency(buf_fin-ob.curr-code))
&scop dyn_cop-l10 substitute('dynamic-function(&1get-currency&1,&2)', ~{&double-quote~}, buf_fin-ob.curr-code)
&scop cop-l11 buf_fin-ob.sum-doc
&scop cop-l12 (if buf_fin-ob.obj-code = 0 then '' else (buf_fin-ob.obj-type + ' ' + string(buf_fin-ob.obj-code)))
&scop cop-l13 buf_fin-ob.doc-code
&scop cop-l17 (contract-gen( buf_fin-ob.contract-code))
&scop dyn_cop-l17 substitute('dynamic-function(&1contract-gen&1,&2)', ~{&double-quote~}, buf_fin-ob.contract-code)

/*платежи*/

&scop col-p0   '*'
&scop col-p1  'Тип'
&scop col-p2  'Статус'
&scop col-p3  '№ док-та'
&scop col-p4  'Создан'
&scop col-p12 'Сумма в валюте док-та'
&scop col-p16 'Сумма связи (в.д.)'
&scop col-p18 'Своб. остаток (в.д.)'
&scop col-p5  'Договор'
&scop col-p6  'Код получ.'
&scop col-p61 'Получатель'
&scop col-p7  'Код плател.'
&scop col-p71 'Плательщик'
&scop col-p8  'Разр.'
&scop col-p9  'Платеж'
&scop col-p10 'Закрыт'
&scop col-p11 'Вал'
&scop col-p15 'Сумма в выбр.вал.'
&scop col-p13 'Расш.тип'
&scop col-p14 'Вн.N'
&scop col-p17 'Объект'

&scop head-col1 ~
 {&col-p0} + '#' + ~
 {&col-p1} + '#' + ~
 {&col-p2} + '#' + ~
 {&col-p3} + '#' + ~
 {&col-p4} + '#' + ~
 {&col-p12} + '#' + ~
 {&col-p16} + '#' + ~
 {&col-p18} + '#' + ~
 {&col-p5} + '#' + ~
 {&col-p6} + '#' + ~
 {&col-p61} + '#' + ~
 {&col-p7} + '#' + ~
 {&col-p71} + '#' + ~
 {&col-p8} + '#' + ~
 {&col-p9} + '#' + ~
 {&col-p10} + '#' + ~
 {&col-p11} + '#' + ~
 {&col-p15} + '#' + ~
 {&col-p13} + '#' + ~
 {&col-p14} + '#' + ~
 {&col-p17}

&scop cop-p0  mark-string(recid(ub.buf_fin-doc), 1)
&scop cop-p1  buf_fin-doc.fin-doc-type
&scop cop-p2  buf_fin-doc.status_
&scop cop-p3  buf_fin-doc.prn-doc-code
&scop cop-p4  buf_fin-doc.doc-date
&scop cop-p15 get-curr-sum(s-curr-code, buf_fin-doc.curr-code, buf_fin-doc.contract-curr, buf_fin-doc.sum-contr, buf_fin-doc.sum-rubl, buf_fin-doc.sum-base, buf_fin-doc.sum-doc )
&scop dyn_cop-p15 substitute('dynamic-function(&1get-curr-sum&1,&2,&3,&4,&5,&6,&7,&8)', ~{&double-quote~}, s-curr-code, buf_fin-doc.curr-code, buf_fin-doc.contract-curr, buf_fin-doc.sum-contr, buf_fin-doc.sum-rubl, buf_fin-doc.sum-base, buf_fin-doc.sum-doc)
&scop cop-p16 buf_fin-doc.con-sum-contr
/*&scop cop-p18 (buf_fin-doc.sum-contr - buf_fin-doc.con-sum-contr)*/
&scop cop-p18 get-ostat(buf_fin-doc.sum-contr, buf_fin-doc.con-sum-contr)
&scop dyn_cop-p18 substitute('dynamic-function(&1get-ostat&1,&2,&3)', ~{&double-quote~}, buf_fin-doc.sum-contr, buf_fin-doc.con-sum-contr)
&scop cop-p5  (contract-id( buf_fin-doc.contract-code))
&scop dyn_cop-p5 substitute('dynamic-function(&1contract-id&1,&2)', ~{&double-quote~}, buf_fin-doc.contract-code)
&scop cop-p6  (buf_fin-doc.receiver-type + ' ' + string(buf_fin-doc.receiver-code))
&scop cop-p61 buf_fin-doc.receiver-name
&scop cop-p7  (buf_fin-doc.payer-type + ' ' + string(buf_fin-doc.payer-code))
&scop cop-p71 buf_fin-doc.payer-name
&scop cop-p8  buf_fin-doc.perm-date
&scop cop-p9  buf_fin-doc.pay-date
&scop cop-p10 buf_fin-doc.fact-date
&scop cop-p11 (get-currency(buf_fin-doc.curr-code))
&scop dyn_cop-p11 substitute('dynamic-function(&1get-currency&1,&2)', ~{&double-quote~}, buf_fin-doc.curr-code)
&scop cop-p12 buf_fin-doc.sum-doc
&scop cop-p13 buf_fin-doc.fin-ext-doc-type
&scop cop-p14 buf_fin-doc.fin-doc-code
&scop cop-p17 (if buf_fin-doc.obj-code = 0 then '' else (buf_fin-doc.obj-type + ' ' + string(buf_fin-doc.obj-code)))

DEFINE TEMP-TABLE temp_fin-ob NO-UNDO LIKE fin-ob
       field no-con-sum as decimal
       field ri as recid .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME Fin-Doc-List

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_fin-doc temp-contr1 buf_fin-ob ~
temp-contr

/* Definitions for BROWSE Fin-Doc-List                                  */
&Scoped-define FIELDS-IN-QUERY-Fin-Doc-List {&cop-p0} {&cop-p1} {&cop-p3} {&cop-p4} {&cop-p15} @ p-sum {&cop-p7} {&cop-p71} {&cop-p5} @ p-contr {&cop-p16} {&cop-p18} {&cop-p11} @ l-curr {&cop-p12} {&cop-p6} {&cop-p61} {&cop-p8} {&cop-p9} {&cop-p10} {&cop-p2} {&cop-p11} @ l-curr {&cop-p12} {&cop-p13} {&cop-p14} {&cop-p17}   
&Scoped-define ENABLED-FIELDS-IN-QUERY-Fin-Doc-List {&cop-p1}   
&Scoped-define SELF-NAME Fin-Doc-List
&Scoped-define QUERY-STRING-Fin-Doc-List FOR EACH buf_fin-doc NO-LOCK, ~
       first temp-contr1
&Scoped-define OPEN-QUERY-Fin-Doc-List OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-doc NO-LOCK, ~
       first temp-contr1.
&Scoped-define TABLES-IN-QUERY-Fin-Doc-List buf_fin-doc temp-contr1
&Scoped-define FIRST-TABLE-IN-QUERY-Fin-Doc-List buf_fin-doc
&Scoped-define SECOND-TABLE-IN-QUERY-Fin-Doc-List temp-contr1


/* Definitions for BROWSE Fin-Ob-List                                   */
&Scoped-define FIELDS-IN-QUERY-Fin-Ob-List {&cop-l0} {&cop-l9} {&cop-l14} @ p-sum {&cop-l8} {&cop-l81} {&cop-l6} @ p-contr {&cop-l3} {&cop-l1} {&cop-l4} {&cop-l16} {&cop-l18} {&cop-l5} {&cop-l7} {&cop-l71} {&cop-l10} @ l-curr {&cop-l11} {&cop-l12} {&cop-l13} {&cop-l17} @ p-gen   
&Scoped-define ENABLED-FIELDS-IN-QUERY-Fin-Ob-List {&cop-l1}   
&Scoped-define SELF-NAME Fin-Ob-List
&Scoped-define QUERY-STRING-Fin-Ob-List FOR EACH buf_fin-ob where buf_fin-ob.payer-code = v-payer-code and buf_fin-ob.status_ =  {&fact} and buf_fin-ob.con-stat <> 2 NO-LOCK, ~
       first temp-contr
&Scoped-define OPEN-QUERY-Fin-Ob-List OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-ob where buf_fin-ob.payer-code = v-payer-code and buf_fin-ob.status_ =  {&fact} and buf_fin-ob.con-stat <> 2 NO-LOCK, ~
       first temp-contr.
&Scoped-define TABLES-IN-QUERY-Fin-Ob-List buf_fin-ob temp-contr
&Scoped-define FIRST-TABLE-IN-QUERY-Fin-Ob-List buf_fin-ob
&Scoped-define SECOND-TABLE-IN-QUERY-Fin-Ob-List temp-contr


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-conn-add B-conn-view B-oplat-list ~
B-Help RECT-status RECT-1 B-conn-doc B-view-doc B-del-doc B-conn-fo ~
B-view-fo Fin-Ob-List Fin-Doc-List B-mark-2 B-unmark-2 B-allmark-2 ~
sum-fin-doc B-mark B-unmark B-allmark B-oplat sum-fin-ob BUTTON-cli ~
sch-code RADIO-find-cli cli-code cli-type RADIO-find-doc BUTTON-curr ~
s-curr-code sch-date cli-name Curr-Types Sel-Client Sel-Contr date-1 ~
Sel-Status B-date date-2 mark-num-2 mark-num 
&Scoped-Define DISPLAYED-OBJECTS sum-fin-doc sum-fin-ob sch-code ~
RADIO-find-cli cli-code cli-type RADIO-find-doc s-curr-code sch-date ~
cli-name Curr-Types Sel-Client Sel-Contr date-1 Sel-Status date-2 ~
mark-num-2 mark-num curr-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD contract-gen Dialog-Frame 
FUNCTION contract-gen RETURNS CHARACTER
  ( input p-contract-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD contract-id Dialog-Frame 
FUNCTION contract-id RETURNS CHARACTER
  ( input p-contract-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-curr-sum Dialog-Frame 
FUNCTION get-curr-sum RETURNS decimal
  ( input p-cur as integer, input p-doc-curr as integer, input p-cur-contr as integer, input p-sum-contract as decimal, input p-sum-rubl as decimal, input p-sum-base as decimal, input p-sum-doc as decimal )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-currency Dialog-Frame 
FUNCTION get-currency RETURNS CHARACTER
  ( input curr-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-free-sum Dialog-Frame 
FUNCTION get-free-sum RETURNS decimal
  ( BUFFER loc-fin-ob FOR fin-ob )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-free-sum1 Dialog-Frame 
FUNCTION get-free-sum1 RETURNS decimal
  ( BUFFER loc-fin-doc FOR fin-doc )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-ostat Dialog-Frame 
FUNCTION get-ostat RETURNS decimal
  ( input p-sum1 as decimal, input p-sum2 as decimal )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame 
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input typ as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-allmark 
     LABEL "Вд.*" 
     SIZE 5 BY 1.

DEFINE BUTTON B-allmark-2 
     LABEL "Вд.*" 
     SIZE 5 BY 1.

DEFINE BUTTON B-conn-add 
     LABEL "Соз&д.св." 
     SIZE 10 BY 1.

DEFINE BUTTON B-conn-doc 
     LABEL "Связи пл." 
     SIZE 10 BY 1.

DEFINE BUTTON B-conn-fo 
     LABEL "Связи ф-о" 
     SIZE 10 BY 1.

DEFINE BUTTON B-conn-view 
     LABEL "Свя&зи все" 
     SIZE 10 BY 1.

DEFINE BUTTON B-date 
     LABEL "Применить" 
     SIZE 10 BY 1.04
     FGCOLOR 4 .

DEFINE BUTTON B-del-doc 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON B-mark-2 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON B-oplat 
     LABEL "О&платить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-oplat-list 
     LABEL "Cписок" 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-unmark 
     LABEL "Сн.*" 
     SIZE 5 BY 1.

DEFINE BUTTON B-unmark-2 
     LABEL "Сн.*" 
     SIZE 5 BY 1.

DEFINE BUTTON B-view-doc 
     LABEL "Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON B-view-fo 
     LABEL "Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON BUTTON-cli 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2" 
     SIZE 2.88 BY 1.

DEFINE BUTTON BUTTON-curr 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "1" 
     SIZE 2.75 BY 1.

DEFINE VARIABLE cli-code AS INTEGER FORMAT "99999" INITIAL 0 
     LABEL "код" 
     VIEW-AS FILL-IN 
     SIZE 6 BY .93.

DEFINE VARIABLE cli-name AS CHARACTER FORMAT "X(14)" 
     LABEL "Наим." 
     VIEW-AS FILL-IN 
     SIZE 14.5 BY .93 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE cli-type AS CHARACTER FORMAT "X(3)" 
     VIEW-AS FILL-IN 
     SIZE 4.38 BY .93.

DEFINE VARIABLE curr-name AS CHARACTER FORMAT "X(5)":U 
      VIEW-AS TEXT 
     SIZE 4.13 BY 1 NO-UNDO.

DEFINE VARIABLE date-1 AS DATE FORMAT "99/99/9999" 
     LABEL "с" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .93 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE date-2 AS DATE FORMAT "99/99/9999" 
     LABEL "по" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .93 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num-2 AS INTEGER FORMAT ">>>>9":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE s-curr-code AS INTEGER FORMAT ">>9" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(14)" 
     LABEL "&Нач. номера" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .93 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999" 
     LABEL "Д&ата" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .93 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sum-fin-doc AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0 
     LABEL "Сумма" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE sum-fin-ob AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 18.25 BY 1 NO-UNDO.

DEFINE VARIABLE Curr-Types AS CHARACTER INITIAL "all" 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", "all",
"Выбор", "sel"
     SIZE 8 BY 1.82 NO-UNDO.

DEFINE VARIABLE RADIO-find-cli AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Плательщик", 1,
"Получатель", 2
     SIZE 13.38 BY 2.07 NO-UNDO.

DEFINE VARIABLE RADIO-find-doc AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Фин.обяз.", 1,
"Платежи", 2
     SIZE 12 BY 1.89 NO-UNDO.

DEFINE VARIABLE Sel-Client AS CHARACTER INITIAL "all" 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", "all",
"Выбор", "sel"
     SIZE 8 BY 1.82 NO-UNDO.

DEFINE VARIABLE Sel-Contr AS CHARACTER INITIAL "all" 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", "all",
"Выбор", "sel"
     SIZE 8 BY 1.82 NO-UNDO.

DEFINE VARIABLE Sel-Status AS CHARACTER INITIAL "new" 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", "all",
"Не факт", "new",
"Факт", "fact"
     SIZE 10 BY 1.74 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 132.75 BY 2.33.

DEFINE RECTANGLE RECT-status
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 133 BY 2.22.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Fin-Doc-List FOR 
      buf_fin-doc, 
      temp-contr1 SCROLLING.

DEFINE QUERY Fin-Ob-List FOR 
      buf_fin-ob, 
      temp-contr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE Fin-Doc-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS Fin-Doc-List Dialog-Frame _FREEFORM
  QUERY Fin-Doc-List DISPLAY
     {&cop-p0}    COLUMN-LABEL {&col-p0}  FORMAT "x(1)"
     {&cop-p1}    COLUMN-LABEL {&col-p1}  Format "x(3)"
     {&cop-p3}    COLUMN-LABEL {&col-p3}  Format "x(9)"
     {&cop-p4}    COLUMN-LABEL {&col-p4}  format "99/99/99"
     {&cop-p12}   COLUMN-LABEL {&col-p12}     
     {&cop-p7}    COLUMN-LABEL {&col-p7}  Format "x(16)"
     {&cop-p71}   COLUMN-LABEL {&col-p71} Format "x(50)"
     {&cop-p5}  @ p-contr COLUMN-LABEL {&col-p5} Format "x(16)"
     {&cop-p16}   COLUMN-LABEL {&col-p16}  Format "->>>,>>>,>>>,>>>.99"
     {&cop-p18}   COLUMN-LABEL {&col-p18}  Format "->>>,>>>,>>>,>>>.99"
     {&cop-p11} @ l-curr  COLUMN-LABEL {&col-p11} Format "x(3)"
     {&cop-p12}   COLUMN-LABEL {&col-p12}
     {&cop-p6}    COLUMN-LABEL {&col-p6}  Format "x(10)"
     {&cop-p61}   COLUMN-LABEL {&col-p61} Format "x(50)"
     {&cop-p8}    COLUMN-LABEL {&col-p8}  format "99/99/99"
     {&cop-p9}    COLUMN-LABEL {&col-p9}  format "99/99/99"
     {&cop-p10}   COLUMN-LABEL {&col-p10} format "99/99/99"
     {&cop-p2}    COLUMN-LABEL {&col-p2}  Format "x(6)"
     {&cop-p11} @ l-curr  COLUMN-LABEL {&col-p11} Format "x(3)"
     {&cop-p15} @ p-sum   COLUMN-LABEL {&col-p15}  Format "->>>,>>>,>>>,>>>.99"
     {&cop-p13}   COLUMN-LABEL {&col-p13} Format "x(3)"
     {&cop-p14}   COLUMN-LABEL {&col-p14}
     {&cop-p17}   COLUMN-LABEL {&col-p17}
     enable {&cop-p1}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 74 BY 16.07 ROW-HEIGHT-CHARS .78.

DEFINE BROWSE Fin-Ob-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS Fin-Ob-List Dialog-Frame _FREEFORM
  QUERY Fin-Ob-List DISPLAY
      {&cop-l0}    COLUMN-LABEL {&col-l0}  FORMAT "x(1)"
     {&cop-l9}    COLUMN-LABEL {&col-l9}  format "99/99/99"
/*     {&cop-l2}    COLUMN-LABEL {&col-l2}  FORMAT "x(1)"*/
     {&cop-l11}   COLUMN-LABEL {&col-l11}
     {&cop-l8}    COLUMN-LABEL {&col-l8}  Format "x(16)"
     {&cop-l81}   COLUMN-LABEL {&col-l81}  Format "x(50)"
     {&cop-l6} @ p-contr   COLUMN-LABEL {&col-l6} Format "x(16)"
     {&cop-l3}    COLUMN-LABEL {&col-l3}  Format "x(9)"
     {&cop-l1}    COLUMN-LABEL {&col-l1}  Format "x(1)"
     {&cop-l4}    COLUMN-LABEL {&col-l4}  format "99/99/99"
     {&cop-l16}   COLUMN-LABEL {&col-l16}  Format "->>>,>>>,>>>,>>>.99"
     {&cop-l18}   COLUMN-LABEL {&col-l18}  Format "->>>,>>>,>>>,>>>.99"
     {&cop-l5}    COLUMN-LABEL {&col-l5}  format "99/99/99"
     {&cop-l7}    COLUMN-LABEL {&col-l7}  Format "x(10)"
     {&cop-l71}   COLUMN-LABEL {&col-l71}  Format "x(50)"
     {&cop-l10}  @ l-curr COLUMN-LABEL {&col-l10} Format "x(3)"
     {&cop-l14} @ p-sum  COLUMN-LABEL {&col-l14} Format "->>>,>>>,>>>,>>>.99"     
     {&cop-l12}   COLUMN-LABEL {&col-l12} Format "x(14)"
     {&cop-l13}   COLUMN-LABEL {&col-l13} Format "x(10)"
     {&cop-l17}  @ p-gen  COLUMN-LABEL {&col-l17} Format "x(50)"
     enable {&cop-l1}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 74 BY 16.07 ROW-HEIGHT-CHARS .78.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-conn-add AT ROW 1 COL 11
     B-conn-view AT ROW 1 COL 21
     B-oplat-list AT ROW 1 COL 31
     B-Help AT ROW 1 COL 121
     B-conn-doc AT ROW 2.04 COL 11
     B-view-doc AT ROW 2.04 COL 21
     B-del-doc AT ROW 2.04 COL 31
     B-conn-fo AT ROW 2.04 COL 111
     B-view-fo AT ROW 2.04 COL 121
     Fin-Ob-List AT ROW 3.07 COL 76
     Fin-Doc-List AT ROW 3.11 COL 1.5
     B-mark-2 AT ROW 19.41 COL 1.5
     B-unmark-2 AT ROW 19.41 COL 9.5
     B-allmark-2 AT ROW 19.41 COL 15
     sum-fin-doc AT ROW 19.41 COL 31.5 COLON-ALIGNED
     B-mark AT ROW 19.41 COL 77
     B-unmark AT ROW 19.41 COL 85
     B-allmark AT ROW 19.41 COL 90
     B-oplat AT ROW 19.41 COL 95
     sum-fin-ob AT ROW 19.41 COL 105 COLON-ALIGNED NO-LABEL
     BUTTON-cli AT ROW 20.85 COL 97.88
     sch-code AT ROW 20.93 COL 35.5 COLON-ALIGNED
     RADIO-find-cli AT ROW 20.93 COL 64.5 NO-LABEL
     cli-code AT ROW 20.93 COL 84.5 COLON-ALIGNED
     cli-type AT ROW 20.93 COL 91 COLON-ALIGNED NO-LABEL
     RADIO-find-doc AT ROW 20.96 COL 10.38 NO-LABEL
     BUTTON-curr AT ROW 21.89 COL 120.88
     s-curr-code AT ROW 21.93 COL 110 COLON-ALIGNED NO-LABEL
     sch-date AT ROW 21.96 COL 35.5 COLON-ALIGNED
     cli-name AT ROW 21.96 COL 84.5 COLON-ALIGNED
     Curr-Types AT ROW 23.41 COL 11 NO-LABEL
     Sel-Client AT ROW 23.41 COL 39.5 NO-LABEL
     Sel-Contr AT ROW 23.41 COL 63 NO-LABEL
     date-1 AT ROW 23.41 COL 94.25 COLON-ALIGNED
     Sel-Status AT ROW 23.41 COL 121 NO-LABEL
     B-date AT ROW 24.22 COL 81.5
     date-2 AT ROW 24.3 COL 94.38 COLON-ALIGNED
     mark-num-2 AT ROW 19.41 COL 4.5 NO-LABEL
     mark-num AT ROW 19.41 COL 80 NO-LABEL
     curr-name AT ROW 21.85 COL 115.63 NO-LABEL
     "Договоры:" VIEW-AS TEXT
          SIZE 9.5 BY 1 AT ROW 23.37 COL 51.5
          FGCOLOR 4 
     "Валюта:" VIEW-AS TEXT
          SIZE 7.5 BY .93 AT ROW 23.41 COL 1.5
          FGCOLOR 4 
     "Платежи:" VIEW-AS TEXT
          SIZE 8.88 BY .93 AT ROW 2.04 COL 2
          FGCOLOR 4 
     "Показ в валюте:" VIEW-AS TEXT
          SIZE 16.5 BY .67 AT ROW 20.96 COL 108.5
          FGCOLOR 4 
     "Платеж:" VIEW-AS TEXT
          SIZE 8.13 BY .93 AT ROW 23.33 COL 81.88
          FGCOLOR 4 
     "Контрагенты:" VIEW-AS TEXT
          SIZE 11 BY 1 AT ROW 23.41 COL 27
          FGCOLOR 4 
     "Стат.пл.:" VIEW-AS TEXT
          SIZE 9 BY 1 AT ROW 23.37 COL 110.5
          FGCOLOR 4 
     "Фин. обязательства:" VIEW-AS TEXT
          SIZE 22 BY .93 AT ROW 2.04 COL 76.5
          FGCOLOR 4 
     "Поиск:" VIEW-AS TEXT
          SIZE 7.38 BY .93 AT ROW 21 COL 1.88
          FGCOLOR 4 
     RECT-status AT ROW 23.26 COL 1.25
     RECT-1 AT ROW 20.82 COL 1.38 WIDGET-ID 2
     SPACE(15.87) SKIP(2.77)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Планирование платежей"
         DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit.


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
/* BROWSE-TAB Fin-Ob-List B-view-fo Dialog-Frame */
/* BROWSE-TAB Fin-Doc-List Fin-Ob-List Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN curr-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN mark-num-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE Fin-Doc-List
/* Query rebuild information for BROWSE Fin-Doc-List
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-doc NO-LOCK, first temp-contr1
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE Fin-Doc-List */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE Fin-Ob-List
/* Query rebuild information for BROWSE Fin-Ob-List
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-ob where buf_fin-ob.payer-code = v-payer-code NO-LOCK, first temp-contr
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE Fin-Ob-List */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Планирование платежей */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-allmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-allmark Dialog-Frame
ON CHOOSE OF B-allmark IN FRAME Dialog-Frame /* Вд.* */
DO:
  if num-fin-doc > 1 then do:
    message "У вас выбрано более одного платежа, в этом случае можно выбрать только 1 фин. обязательство!" view-as alert-box ERROR.
    return no-apply.
  end.
  for each temp-fin-ob: delete temp-fin-ob . end.
  assign
    sum-fin-ob = 0
    num-fin-ob = 0
    ind1 = 0
  .
  GET FIRST Fin-Ob-List NO-LOCK .

  DO WHILE AVAILABLE(buf_fin-ob):
    create temp-fin-ob .
    assign
      temp-fin-ob.ri = recid( buf_fin-ob )
      temp-fin-ob.ind = ind1
      ind1 = ind1 + 1
      num-fin-ob = num-fin-ob + 1
      temp-fin-ob.del = no
    .
    assign  sum-fin-ob = sum-fin-ob + get-free-sum(buffer buf_fin-ob) .
    GET next Fin-Ob-List NO-LOCK .
  end.

  if num-fin-ob = 0 then hide mark-num in frame {&frame-name}.
  else                   display num-fin-ob @ mark-num  with frame {&frame-name}.
  display sum-fin-ob  with frame {&frame-name}.
  RUN OpenBr(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-allmark-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-allmark-2 Dialog-Frame
ON CHOOSE OF B-allmark-2 IN FRAME Dialog-Frame /* Вд.* */
DO:
  if num-fin-ob > 1 then do:
    message "У вас выбрано более одного фин. обязательства, в этом случае можно выбрать только 1 платеж!" view-as alert-box ERROR.
    return no-apply.
  end.
  for each temp-fin-doc: delete temp-fin-doc . end.
  assign
    sum-fin-doc = 0
    num-fin-doc = 0
    ind1 = 0
  .
  GET FIRST Fin-Doc-List NO-LOCK .

  DO WHILE AVAILABLE(buf_fin-doc):
    create temp-fin-doc .
    assign
      temp-fin-doc.ri = recid( buf_fin-doc )
      temp-fin-doc.ind = ind1
      ind1 = ind1 + 1
      num-fin-doc = num-fin-doc + 1
      temp-fin-doc.del = no
    .
    assign  sum-fin-doc = sum-fin-doc + get-free-sum1(buffer buf_fin-doc) .
    GET next Fin-Doc-List NO-LOCK .
  end.

  if num-fin-doc = 0 then hide mark-num-2 in frame {&frame-name}.
  else                   display num-fin-doc @ mark-num-2  with frame {&frame-name}.
  display sum-fin-doc  with frame {&frame-name}.
  RUN OpenBr1(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-conn-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-conn-add Dialog-Frame
ON CHOOSE OF B-conn-add IN FRAME Dialog-Frame /* Созд.св. */
DO:
/*  define variable is-con as logical   no-undo .*/
/*  message*/
/*    "Вы действительно хотите связать выбранные фин. обязательства и платежи?"*/
/*  view-as alert-box QUESTION BUTTONS YES-NO UPDATE is-con .*/
/*  if is-con = no then return no-apply.*/
  if num-fin-ob > 0 and num-fin-doc > 0 then do:
    run proc-check-contract no-error  .
    if error-status:error then return no-apply.
    assign v-list = "" .
    if num-fin-ob = 1 and num-fin-doc > 1 then do: /* 1 обяз. и несколько платежей */
      find first temp-fin-ob .
      for each temp-fin-doc :
        if v-list = "" then  assign v-list = string(temp-fin-doc.ri) .
        else  assign v-list = v-list + "," + string(temp-fin-doc.ri) .
      end.
      run str/fin-con2.w ( parParentProc, v-cntxt-host-code-obj, temp-fin-ob.ri, v-list, output v-end) .
      if v-end then do:
        for each temp-fin-doc :
          find first fin-doc no-lock where recid (fin-doc) = temp-fin-doc.ri .
          if fin-doc.con-stat = 2 then delete temp-fin-doc .
        end.
        RUN OpenBr(yes, no, '':U) .
        RUN OpenBr1(yes, no, '':U) .
      end.
    end.
    else do:   /* несколько обяз. и 1 платеж */
      find first temp-fin-doc .
      for each temp-fin-ob :
        if v-list = "" then  assign v-list = string(temp-fin-ob.ri) .
        else  assign v-list = v-list + "," + string(temp-fin-ob.ri) .
      end.
      run str/fin-con1.w ( parParentProc, v-cntxt-host-code-obj, temp-fin-doc.ri, v-list, output v-end) .
      if v-end then do:
        for each temp-fin-ob :
          find first fin-ob no-lock where recid (fin-ob) = temp-fin-ob.ri .
          if fin-ob.con-stat = 2 then delete temp-fin-ob .
        end.
        RUN OpenBr(yes, no, '':U) .
        RUN OpenBr1(yes, no, '':U) .
      end.
    end.
  end.
  else do:
    message "Нет выбранных фин. обязательств или платежей!" view-as alert-box error .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-conn-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-conn-doc Dialog-Frame
ON CHOOSE OF B-conn-doc IN FRAME Dialog-Frame /* Связи пл. */
DO:
  if available buf_fin-doc then do:
    run str/finconn.w ( input parParentProc, input v-cntxt-host-code-obj, input p-doc-type, input "fin-doc", input string(buf_fin-doc.fin-doc-code)) .
    RUN OpenBr(yes, no, '':U) .
    RUN OpenBr1(yes, no, '':U) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-conn-fo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-conn-fo Dialog-Frame
ON CHOOSE OF B-conn-fo IN FRAME Dialog-Frame /* Связи ф-о */
DO:
  if available buf_fin-ob then do:
    run str/finconn.w ( input parParentProc, input v-cntxt-host-code-obj, input p-doc-type, input "fin-ob", input buf_fin-ob.doc-code) .
    RUN OpenBr(yes, no, '':U) .
    RUN OpenBr1(yes, no, '':U) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-conn-view
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-conn-view Dialog-Frame
ON CHOOSE OF B-conn-view IN FRAME Dialog-Frame /* Связи все */
DO:
  define variable rr as integer initial 0  no-undo .
/*  if Sel-Contr = "sel" then assign rr = int (cont-list) .*/
  run str/finconn.w ( input parParentProc, input v-cntxt-host-code-obj, input p-doc-type, input "all", input "" ) .
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-date Dialog-Frame
ON CHOOSE OF B-date IN FRAME Dialog-Frame /* Применить */
DO:
  assign date-1 date-2 .
  if date-1 = ? and date-2 = ? then do:
    assign sel-date = no .
  end.
  else do:
    assign sel-date = yes .
    if date-1 = ? then assign date-1 = 1/1/1900 .
    if date-2 = ? then assign date-2 = 1/1/3000 .
  end.

  RUN OpenBr(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-doc Dialog-Frame
ON CHOOSE OF B-del-doc IN FRAME Dialog-Frame /* Удалить */
DO:
  if not available buf_fin-doc then return.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-doc_deletion':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then return.

  find first fin-doc exclusive-lock where recid(fin-doc) = recid(buf_fin-doc) NO-ERROR.
  if not avail fin-doc then return no-apply.
  IF fin-doc.status_ <> {&fin-new}  THEN DO:
    MESSAGE "Платеж закрыт - удалять нельзя!"  VIEW-AS ALERT-BOX ERROR.
    RETURN .
  END.
  g-log = no.
  MESSAGE
    "Вы уверены, что хотите удалить платеж N " fin-doc.prn-doc-code " от " string(fin-doc.doc-date,"99/99/9999") "?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE g-log.
  IF g-log <> YES THEN RETURN .

  do on error undo, return on stop undo, return no-apply :
    run trg/findocdl.p ( input parParentProc
                         ,input fin-doc.host-code
                         ,input fin-doc.fin-doc-code
                         ,input no
                         ,input no) no-error.
  end.
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  if available buf_fin-ob then   do:
    find first temp-fin-ob where temp-fin-ob.ri = recid( buf_fin-ob ) no-error  .
    if available temp-fin-ob then do:
      delete temp-fin-ob .
      assign
        sum-fin-ob = sum-fin-ob - get-free-sum(buffer buf_fin-ob)
        num-fin-ob = num-fin-ob - 1
      .
    end.
    else do:
      if num-fin-doc > 1 and num-fin-ob > 0 then do:
        message "У вас выбрано более одного платежа, в этом случае можно выбрать только 1 фин. обязательство!" view-as alert-box ERROR.
        return no-apply.
      end.
      create temp-fin-ob .
      assign
        temp-fin-ob.ri = recid( buf_fin-ob )
        temp-fin-ob.ind = ind1
        ind1 = ind1 + 1
        num-fin-ob = num-fin-ob + 1
      .
      assign  sum-fin-ob = sum-fin-ob + get-free-sum(buffer buf_fin-ob) .
    end.
    g-log = Fin-Ob-List:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
      g-log = Fin-Ob-List:select-next-row ().
      apply "value-changed" to Fin-Ob-List in frame {&frame-name}.
    end.
    if num-fin-ob = 0 then hide mark-num in frame {&frame-name}.
    else                   display num-fin-ob @ mark-num  with frame {&frame-name}.
    display sum-fin-ob  with frame {&frame-name}.
  end.
  apply "entry" to Fin-Ob-List .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark-2 Dialog-Frame
ON CHOOSE OF B-mark-2 IN FRAME Dialog-Frame /* * */
DO:
  if available buf_fin-doc then   do:
    find first temp-fin-doc where temp-fin-doc.ri = recid( buf_fin-doc ) no-error  .
    if available temp-fin-doc then do:
      delete temp-fin-doc .
      assign
        sum-fin-doc = sum-fin-doc - get-free-sum1(buffer buf_fin-doc)
        num-fin-doc = num-fin-doc - 1
      .
    end.
    else do:
      if num-fin-ob > 1 and num-fin-doc > 0 then do:
        message "У вас выбрано более одного фин. обязательства, в этом случае можно выбрать только 1 платеж!" view-as alert-box ERROR.
        return no-apply.
      end.
      create temp-fin-doc .
      assign
        temp-fin-doc.ri = recid( buf_fin-doc )
        temp-fin-doc.ind = ind2
        ind2 = ind2 + 1
        num-fin-doc = num-fin-doc + 1
      .
      assign  sum-fin-doc = sum-fin-doc + get-free-sum1(buffer buf_fin-doc) .
    end.
    g-log = Fin-Doc-List:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
      g-log = Fin-Doc-List:select-next-row ().
      apply "value-changed" to Fin-Doc-List in frame {&frame-name}.
    end.
    if num-fin-doc = 0 then hide mark-num-2 in frame {&frame-name}.
    else                   display num-fin-doc @ mark-num-2  with frame {&frame-name}.
    display sum-fin-doc  with frame {&frame-name}.
  end.
  apply "entry" to Fin-Doc-List .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-oplat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-oplat Dialog-Frame
ON CHOOSE OF B-oplat IN FRAME Dialog-Frame /* Оплатить */
DO:
  if num-fin-ob < 1 then do:
    message "Нет выбранных фин. обязательств!" view-as alert-box error .
    return no-apply .
  end.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-doc_add-def':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then return no-apply.
/*  message*/
/*    "Вы действительно хотите оплатить выбранные фин. обязательства?"*/
/*  view-as alert-box QUESTION BUTTONS YES-NO UPDATE g-log .*/
/*  if g-log = no then return no-apply.*/

  define variable v-ri as recid initial ? no-undo .
  run str/payfinob.w ( input parParentProc, input v-cntxt-host-code-obj, input table temp-fin-ob, output v-ri) no-error  .
  if error-status:error then return no-apply.
  assign v-list = "" .
  if v-ri <> ? then do:
    for each temp-fin-ob :
      if v-list = "" then assign v-list = string(temp-fin-ob.ri) .
      else assign v-list = v-list + "," + string(temp-fin-ob.ri) .
    end.

    assign v-conn-avt = "no" .

    run gbl/conf-rd.p ( input "fincnavt"
                        ,input v-cntxt-host-code-obj
                        ,input ""
                        ,input 0
                        ,input ""
                        ,input ""
                        ,input ""
                        ,input no
                        ,output v-conn-avt
                        ,output v-par-type) no-error.

    if v-conn-avt = "no" then do:
      run str/fin-con1.w ( parParentProc, v-cntxt-host-code-obj, v-ri, v-list, output v-end) .
    end.
    else do:
      assign v-end = yes .
      run conn-avt ( v-ri, v-list ) .
    end.

    if v-end then do:
      for each temp-fin-ob :
        find first fin-ob no-lock where recid (fin-ob) = temp-fin-ob.ri .
        if fin-ob.con-stat = 2 then delete temp-fin-ob .
      end.
    end.

    RUN OpenBr(yes, no, '':U) .
    RUN OpenBr1(yes, no, '':U) .
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-oplat-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-oplat-list Dialog-Frame
ON CHOOSE OF B-oplat-list IN FRAME Dialog-Frame /* Cписок */
DO:
  run str/paypvavt.p (v-cntxt-host-code-obj) no-error  .
  if error-status:error then return no-apply.
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  define variable cur-clmn-loc as integer   no-undo .
  define variable column-handle as handle no-undo .
  define variable v-list as character no-undo .
  define variable v-i as integer   no-undo .
  define variable v-pos as integer   no-undo .
  define variable v-list-new as character no-undo .
  define variable v-elem as character no-undo .
  define variable v-list-str as character no-undo .
  define variable v-list-str1 as character no-undo .

  assign
    cur-clmn-loc  = 1
    column-handle = Fin-Ob-List:first-column
    v-list        = column-handle:label + "#"
    v-list-new = ""
  .

  do while valid-handle(column-handle) :
    if cur-clmn-loc = Fin-Ob-List:num-columns then leave .
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      v-list        = v-list + column-handle:label + "#"
    .
  end.
  v-list = trim(v-list, "#") .

  repeat v-i = 1 to Fin-Ob-List:num-columns :
    v-elem = entry( v-i, v-list , "#") .
    v-pos = lookup( v-elem, {&head-col} , "#") .
/*    v-list-new = v-list-new + string(v-pos) + "," .*/
  end.

  v-list-str = "" .
  repeat v-i = 1 to num-entries(v-list-new) :
    v-elem = entry(v-i , v-list-new ) .
    if int(v-elem) > 1 then  v-list-str  = v-list-str + v-elem + "," .
  end.

  assign
    cur-clmn-loc  = 1
    column-handle = Fin-Doc-List:first-column
    v-list        = column-handle:label + "#"
    v-list-new = ""
  .

  do while valid-handle(column-handle) :
    if cur-clmn-loc = Fin-Doc-List:num-columns then leave .
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      v-list        = v-list + column-handle:label + "#"
    .
  end.
  v-list = trim(v-list, "#") .

  repeat v-i = 1 to Fin-Doc-List:num-columns :
    v-elem = entry( v-i, v-list , "#") .
    v-pos = lookup( v-elem, {&head-col1} , "#") .
    v-list-new = v-list-new + string(v-pos) + "," .
  end.

  v-list-str1 = "" .
  repeat v-i = 1 to num-entries(v-list-new) :
    v-elem = entry(v-i , v-list-new ) .
    if int(v-elem) > 1 then  v-list-str1  = v-list-str1 + v-elem + "," .
  end.

    v-list-new = "".
/*  v-list-new = trim(v-list-str ,",")  +  {&delim-par}  + trim(v-list-str1 ,",")  +  {&delim-par}           */
/*              + string(decimal( buf_fin-ob.receiver-name:width  in browse Fin-Ob-List)) +  {&delim-par}    */
/*              + string(decimal( buf_fin-ob.payer-name:width     in browse Fin-Ob-List)) +  {&delim-par}    */
/*              + string(decimal( p-gen:width                     in browse Fin-Ob-List)) +  {&delim-par}    */
/*              + string(decimal( buf_fin-doc.receiver-name:width in browse Fin-Doc-List)) +  {&delim-par}   */
/*              + string(decimal( buf_fin-doc.payer-name:width    in browse Fin-Doc-List)) +  {&delim-par}  .*/

  run uf-set in this-procedure(
    input  {&uf-planplat}
    ,input v-cntxt-userid
    ,input v-list-new
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
  ) no-error    .
  if error-status :error then  message vss-workfile vss-revision vss-description skip error-status :get-message(1) skip return-value skip "uf-set" view-as alert-box error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-unmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-unmark Dialog-Frame
ON CHOOSE OF B-unmark IN FRAME Dialog-Frame /* Сн.* */
DO:
  GET FIRST Fin-Ob-List NO-LOCK .
  if not available buf_fin-ob then return.

  for each temp-fin-ob: delete temp-fin-ob . end.
  assign
    sum-fin-ob = 0
    num-fin-ob = 0
  .
  g-log = Fin-Ob-List:refresh() .

  if num-fin-ob = 0 then hide mark-num in frame {&frame-name}.
  else                   display num-fin-ob @ mark-num  with frame {&frame-name}.
  display sum-fin-ob  with frame {&frame-name}.
/*  RUN OpenBr(yes, no, '':U) .*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-unmark-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-unmark-2 Dialog-Frame
ON CHOOSE OF B-unmark-2 IN FRAME Dialog-Frame /* Сн.* */
DO:
  GET FIRST Fin-Doc-List NO-LOCK .
  if not available buf_fin-doc then return.

  for each temp-fin-doc: delete temp-fin-doc . end.
  assign
    sum-fin-doc = 0
    num-fin-doc = 0
  .
  g-log = Fin-Doc-List:refresh() .

  if num-fin-doc = 0 then hide mark-num-2 in frame {&frame-name}.
  else                 display num-fin-doc @ mark-num-2  with frame {&frame-name}.
  display sum-fin-doc  with frame {&frame-name}.
/*  RUN OpenBr(yes, no, '':U) .*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-view-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-view-doc Dialog-Frame
ON CHOOSE OF B-view-doc IN FRAME Dialog-Frame /* Просмотр */
DO:
  if not available buf_fin-doc then return.

  run ref/showfind.p (
                       input parParentProc
                      ,input v-cntxt-host-code-obj /*текущая фирма*/
                      ,input buf_fin-doc.host-code
                      ,input buf_fin-doc.fin-doc-code
                      ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-view-fo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-view-fo Dialog-Frame
ON CHOOSE OF B-view-fo IN FRAME Dialog-Frame /* Просмотр */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-liability_lookup':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return .
  define variable rr as recid no-undo .
  if not available buf_fin-ob then return.
  run str/sh-finob.p ( input parParentProc, input v-cntxt-host-code-obj, input recid(buf_fin-ob)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-cli Dialog-Frame
ON CHOOSE OF BUTTON-cli IN FRAME Dialog-Frame /* 2 */
DO:
  define variable agnt-list as character no-undo .
  run ref/cli-all.w (parParentProc, "b-sel", {&all}, {&all}, {&current}, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
  if agnt-list <> "" then do:
    find first clients no-lock where RECID(clients) = int (agnt-list) no-error.
    if clients.obj-type <> {&prs} and clients.obj-type <> {&cmp} then do:
      message "Контрагент может быть только " {&cmp} " или " {&prs} view-as alert-box ERROR .
      return no-apply.
    end.
    assign cli-name  = clients.obj-name  cli-code = clients.obj-code  cli-type = clients.obj-type.
  end.
  else assign cli-name = ""   cli-code = ?  cli-type  = ? .
  display cli-name    cli-code     cli-type   with frame {&frame-name}.

  run proc-find-cli in this-procedure(no, input cli-code, input cli-type ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-curr Dialog-Frame
ON CHOOSE OF BUTTON-curr IN FRAME Dialog-Frame /* 1 */
DO:
  define variable ri as recid init ? no-undo .
  run ref/currency.w ( input parparentproc
                      ,input "b-sel"
                      ,input-output ri ).
  if ri = ? then return no-apply.
  find currency where recid ( currency ) = ri no-lock.
  assign
    s-curr-code = currency.curr-code
    curr-name = currency.curr-abbr
  .
  display curr-name s-curr-code with frame {&frame-name}.
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code Dialog-Frame
ON CTRL-J OF cli-code IN FRAME Dialog-Frame /* код */
DO:
  run proc-find-cli  in this-procedure(yes, input cli-code, input cli-type ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code Dialog-Frame
ON RETURN OF cli-code IN FRAME Dialog-Frame /* код */
DO:
/*  if cli-code = int ( cli-code:screen-value ) then return.*/
  assign cli-code.
  run find-cli in this-procedure (input cli-type, input cli-code)  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-name Dialog-Frame
ON CTRL-J OF cli-name IN FRAME Dialog-Frame /* Наим. */
DO:
  assign cli-name .
  run proc-find-cli-name in this-procedure(yes, input frame {&frame-name} cli-name ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-name Dialog-Frame
ON RETURN OF cli-name IN FRAME Dialog-Frame /* Наим. */
DO:
  assign cli-name .
  run proc-find-cli-name  in this-procedure(no, input frame {&frame-name} cli-name ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-type Dialog-Frame
ON LEAVE OF cli-type IN FRAME Dialog-Frame
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-type.
  run find-cli in this-procedure (input cli-type, input cli-code)  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-type Dialog-Frame
ON RETURN OF cli-type IN FRAME Dialog-Frame
DO:
  assign cli-type.
  run find-cli in this-procedure (input cli-type, input cli-code)  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Curr-Types
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Curr-Types Dialog-Frame
ON VALUE-CHANGED OF Curr-Types IN FRAME Dialog-Frame
DO:
  assign Curr-Types .
  define variable ref-rec as recid init ? no-undo .
  if Curr-Types = "sel" then do:
    run ref/currency.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output ref-rec ).
    if ref-rec = ? then do:
      assign Curr-Types = "all" .
      display Curr-Types with frame {&frame-name}.
    end.
    else do:
      find first  currency where recid ( currency ) = ref-rec no-lock.
      assign curr-code = currency.curr-code .
    end.
  end.
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME Fin-Doc-List
&Scoped-define SELF-NAME Fin-Doc-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Fin-Doc-List Dialog-Frame
ON RETURN OF Fin-Doc-List IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF Fin-Doc-List IN FRAME Dialog-Frame
DO:
    if b-mark-2:sensitive then apply "choose" to b-mark-2 in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Fin-Doc-List Dialog-Frame
ON VALUE-CHANGED OF Fin-Doc-List IN FRAME Dialog-Frame
DO:
  v-payer-code = buf_fin-doc.payer-code.
  v-payer-type = buf_fin-doc.payer-type.
  {&OPEN-QUERY-Fin-Ob-List}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME Fin-Ob-List
&Scoped-define SELF-NAME Fin-Ob-List
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Fin-Ob-List Dialog-Frame
ON RETURN OF Fin-Ob-List IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF Fin-Ob-List IN FRAME Dialog-Frame
DO:
    if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-find-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-find-cli Dialog-Frame
ON VALUE-CHANGED OF RADIO-find-cli IN FRAME Dialog-Frame
DO:
  assign RADIO-find-cli .
  if cli-code <> ? and cli-code <> 0 then apply "return" to cli-code in frame {&frame-name}.
  else if cli-name <> "" then apply "return" to cli-name in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-find-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-find-doc Dialog-Frame
ON VALUE-CHANGED OF RADIO-find-doc IN FRAME Dialog-Frame
DO:
  assign RADIO-find-doc .
  if sch-code <> "" then apply "return" to sch-code in frame {&frame-name}.
  else do:
    if sch-date <> ? and sch-date <> ? and sch-date:screen-value <> "  /  /" then apply "return" to sch-date in frame {&frame-name}.
    else do:
      if cli-code <> ? and cli-code <> 0 then apply "return" to cli-code in frame {&frame-name}.
      else if cli-name <> "" then apply "return" to cli-name in frame {&frame-name}.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME s-curr-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL s-curr-code Dialog-Frame
ON LEAVE OF s-curr-code IN FRAME Dialog-Frame
DO:
  assign s-curr-code .
  define variable ri as recid init ? no-undo .
  find first currency where currency.curr-code = s-curr-code no-error.
  if not available currency then do:
    run ref/currency.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output ri ).
    if ri = ? then return no-apply.
    find currency where recid ( currency ) = ri .
  end.
  assign
    curr-name = currency.curr-abbr
    s-curr-code = currency.curr-code
  .
  display s-curr-code curr-name with frame {&frame-name}.
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL s-curr-code Dialog-Frame
ON RETURN OF s-curr-code IN FRAME Dialog-Frame
DO:
  assign s-curr-code .
  define variable ri as recid init ? no-undo .
  find first currency where currency.curr-code = s-curr-code no-error.
  if not available currency then do:
    run ref/currency.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output ri ).
    if ri = ? then return no-apply.
    find currency where recid ( currency ) = ri .
  end.
  assign
    curr-name = currency.curr-abbr
    s-curr-code = currency.curr-code
  .
  display s-curr-code curr-name with frame {&frame-name}.
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* Нач. номера */
DO:
  run proc-find-code  in this-procedure(yes, input frame {&frame-name} sch-code ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* Нач. номера */
DO:
  run proc-find-code  in this-procedure(no, input frame {&frame-name} sch-code ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON CTRL-J OF sch-date IN FRAME Dialog-Frame /* Дата */
DO:
  run proc-find-date in this-procedure(yes, input frame {&frame-name} sch-date) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON RETURN OF sch-date IN FRAME Dialog-Frame /* Дата */
DO:
  assign sch-date .
  run proc-find-date in this-procedure(no, input sch-date) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Sel-Client
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Sel-Client Dialog-Frame
ON VALUE-CHANGED OF Sel-Client IN FRAME Dialog-Frame
DO:
  assign Sel-Client .

  assign cli-list = "" .
  if Sel-Client = "sel" then do:
    run ref/cli-all.w (parParentProc, "b-sel,b-mark", {&all}, {&all}, {&current}, ?, ",,,,,,NO,,":u, "without-obj":U, output cli-list ) .
    if cli-list = "" then do:
      assign Sel-Client = "all" .
      disp Sel-Client with frame {&frame-name}.
    end.
    else do:
      assign Sel-Contr = "all" .
      disp Sel-Contr with frame {&frame-name}.
      for each temp-contr  where temp-contr.id <> -1 : delete temp-contr . end.
      for each temp-contr1 where temp-contr1.id <> -1 : delete temp-contr1 . end.
      define variable ii as integer   no-undo .
      do ii = 1 to num-entries (cli-list):
        find first clients no-lock where recid(clients) = integer (entry (ii, cli-list)) .
        for each contract no-lock
          where contract.host-code = v-cntxt-host-code-obj
            and contract.cli-type = clients.obj-type
            and contract.cli-code = clients.obj-code
        :
          create temp-contr .
          assign temp-contr.id = contract.contract-code .
          create temp-contr1 .
          assign temp-contr1.id = contract.contract-code .
        end.
      end.
    end.
  end .
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Sel-Contr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Sel-Contr Dialog-Frame
ON VALUE-CHANGED OF Sel-Contr IN FRAME Dialog-Frame
DO:
  assign Sel-Contr .
  if Sel-Client = "all" then do:
    for each temp-contr where temp-contr.id <> -1 : delete temp-contr . end.
    for each temp-contr1 where temp-contr1.id <> -1 : delete temp-contr1 . end.
  end.
  assign cont-list = "" .
  if Sel-Contr = "sel" then do:
    if Sel-Client = "sel" then do:
      find first clients no-lock where recid(clients) = integer (cli-list) .
      run str/cont-all.w ( parParentProc, v-cntxt-host-code-obj, "b-add,b-mark,b-sel", {&company}, clients.obj-type, clients.obj-code, ?, ?, "current":U, p-doc-type, input-output cont-list ) .
    end.
    else do:
      run str/cont-all.w ( parParentProc, v-cntxt-host-code-obj, "b-add,b-mark,b-sel", {&company}, ?, ?, ?, ?, "current":U, p-doc-type, input-output cont-list ) .
    end.

    if cont-list = "" then do:
      assign Sel-Contr = "all" .
      disp Sel-Contr with frame {&frame-name}.
    end.
    else do:
      for each temp-contr where temp-contr.id <> -1 : delete temp-contr . end.
      for each temp-contr1 where temp-contr1.id <> -1 : delete temp-contr1 . end.
      define variable ii as integer   no-undo .
      do ii = 1 to num-entries (cont-list):
        find first contract no-lock where recid(contract) = integer (entry (ii, cont-list)) .
        create temp-contr .
        assign temp-contr.id = contract.contract-code .
        create temp-contr1 .
        assign temp-contr1.id = contract.contract-code .
      end.
    end.
  end .
  else do:
    if Sel-Client = "sel" then do:
        find first clients no-lock where recid(clients) = integer (cli-list) .
        for each contract no-lock
          where contract.host-code = p-host-code
            and contract.cli-type = clients.obj-type
            and contract.cli-code = clients.obj-code
        :
          create temp-contr .
          assign temp-contr.id = contract.contract-code .
          create temp-contr1 .
          assign temp-contr1.id = contract.contract-code .
        end.
    end.
  end.
  RUN OpenBr(yes, no, '':U) .
  RUN OpenBr1(yes, no, '':U) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Sel-Status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Sel-Status Dialog-Frame
ON VALUE-CHANGED OF Sel-Status IN FRAME Dialog-Frame
DO:
  assign Sel-Status .
  if Sel-Status = "new" then assign p-status = {&g___new} .
  else                       assign p-status = {&fact} .
/*  RUN OpenBr(yes, no, '':U) .*/
  RUN OpenBr1(yes, no, '':U) .
  apply "entry" to Fin-Doc-List .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME Fin-Doc-List
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize=true }
{ gbl/brwrepos.i &line-num=15 }

{ gbl/diasize.i  &browse-name="fin-ob-list" }

run diasize_add_browse in this-procedure
  (input  'height':u
  ,input  browse fin-doc-list :handle
  ) .
run diasize_init in this-procedure .

b-quit:SELECTED = no .

/*  &label-clmn_2         = "{&col-l2}"*/
/*  &sort-clmn_2          = "{&cop-l2}"*/

/* сорт  колонок*/
{ gbl/srt-clmd.i
  &table-name     = "buf_fin-ob"
  &browse-name = "Fin-Ob-List"
  &frame-name = "{&frame-name}"
  &ext-col = 19
  &open-query     = "run OpenBr(yes, no, '':U)."
  &open-query-otherwise = "run OpenBr(yes, no, '':U)."
  &sort-column-name = "sort-column-name"
  &start-column         = "2"
  &label-clmn_13        = "{&col-l9}"
  &sort-clmn_13         = "{&cop-l9}"
  &label-clmn_4         = "{&col-l14}"
  &sort-clmn_4          = "{&cop-l14}"
  &dyn_sort-clmn_4          = "{&dyn_cop-l14}"
  &label-clmn_11        = "{&col-l8}"
  &sort-clmn_11         = "{&cop-l8}"
  &label-clmn_12        = "{&col-l81}"
  &sort-clmn_12         = "{&cop-l81}"
  &label-clmn_8         = "{&col-l6}"
  &sort-clmn_8          = "{&cop-l6}"
  &dyn_sort-clmn_8          = "{&dyn_cop-l6}"
  &label-clmn_2         = "{&col-l3}"
  &sort-clmn_2          = "{&cop-l3}"
  &label-clmn_1         = "{&col-l1}"
  &sort-clmn_1          = "{&cop-l1}"
  &label-clmn_3         = "{&col-l4}"
  &sort-clmn_3          = "{&cop-l4}"
  &label-clmn_5         = "{&col-l16}"
  &sort-clmn_5          = "{&cop-l16}"
  &label-clmn_6         = "{&col-l18}"
  &sort-clmn_6          = "{&cop-l18}"
  &dyn_sort-clmn_6          = "{&dyn_cop-l18}"
  &label-clmn_7         = "{&col-l5}"
  &sort-clmn_7          = "{&cop-l5}"
  &label-clmn_9         = "{&col-l7}"
  &sort-clmn_9          = "{&cop-l7}"
  &label-clmn_10        = "{&col-l71}"
  &sort-clmn_10         = "{&cop-l71}"
  &label-clmn_14        = "{&col-l10}"
  &sort-clmn_14         = "{&cop-l10}"
  &dyn_sort-clmn_14         = "{&dyn_cop-l10}"
  &label-clmn_15        = "{&col-l11}"
  &sort-clmn_15         = "{&cop-l11}"
  &label-clmn_16        = "{&col-l12}"
  &sort-clmn_16         = "{&cop-l12}"
  &label-clmn_17        = "{&col-l13}"
  &sort-clmn_17         = "{&cop-l13}"
  &label-clmn_18        = "{&col-l17}"
  &sort-clmn_18         = "{&cop-l17}"
  &dyn_sort-clmn_18         = "{&dyn_cop-l17}"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
 }
{ gbl/srt-clmd.i
  &table-name     = "buf_fin-doc"
  &browse-name = "Fin-Doc-List"
  &frame-name = "{&frame-name}"
  &ext-col = 21
  &open-query     = "run OpenBr1(yes, no, '':U)."
  &open-query-otherwise = "run OpenBr1(yes, no, '':U)."
  &sort-column-name = "sort-column-name1"
  &start-column         = "2"
  &label-clmn_1         = "{&col-p1}"
  &sort-clmn_1          = "{&cop-p1}"
  &label-clmn_3         = "{&col-p3}"
  &sort-clmn_3          = "{&cop-p3}"
  &label-clmn_4         = "{&col-p4}"
  &sort-clmn_4          = "{&cop-p4}"
  &label-clmn_5         = "{&col-p15}"
  &sort-clmn_5          = "{&cop-p15}"
  &dyn_sort-clmn_5          = "{&dyn_cop-p15}"
  &label-clmn_11        = "{&col-p7}"
  &sort-clmn_11         = "{&cop-p7}"
  &label-clmn_12        = "{&col-p71}"
  &sort-clmn_12         = "{&cop-p71}"
  &label-clmn_8         = "{&col-p5}"
  &sort-clmn_8          = "{&cop-p5}"
  &dyn_sort-clmn_8          = "{&dyn_cop-p5}"
  &label-clmn_6         = "{&col-p16}"
  &sort-clmn_6          = "{&cop-p16}"
  &label-clmn_7         = "{&col-p18}"
  &sort-clmn_7          = "{&cop-p18}"
  &dyn_sort-clmn_7          = "{&dyn_cop-p18}"
  &label-clmn_2         = "{&col-p2}"
  &sort-clmn_2          = "{&cop-p2}"
  &label-clmn_16        = "{&col-p11}"
  &sort-clmn_16         = "{&cop-p11}"
  &dyn_sort-clmn_16         = "{&dyn_cop-p11}"
  &label-clmn_17        = "{&col-p12}"
  &sort-clmn_17         = "{&cop-p12}"
  &label-clmn_9         = "{&col-p6}"
  &sort-clmn_9          = "{&cop-p6}"
  &label-clmn_10        = "{&col-p61}"
  &sort-clmn_10         = "{&cop-p61}"
  &label-clmn_13        = "{&col-p8}"
  &sort-clmn_13         = "{&cop-p8}"
  &label-clmn_14        = "{&col-p9}"
  &sort-clmn_14         = "{&cop-p9}"
  &label-clmn_15        = "{&col-p10}"
  &sort-clmn_15         = "{&cop-p10}"
  &label-clmn_18        = "{&col-p13}"
  &sort-clmn_18         = "{&cop-p13}"
  &label-clmn_19        = "{&col-p14}"
  &sort-clmn_19         = "{&cop-p14}"
  &label-clmn_20        = "{&col-p17}"
  &sort-clmn_20         = "{&cop-p17}"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
 }
  { gbl/ed_date.i date-1 }
  { gbl/ed_date.i date-2 }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

define variable v-right-supp as logical   no-undo init true .
define variable v-right-buyer as logical   no-undo init true  .
if p-type = "inc" then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-supp':U
    {&cntxt-firm}
    p-host-code
    ''
    0
    0
    0
    0
    true
    v-right-supp
  }
  if v-right-supp = false then return .
end.
else do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-buyer':U
    {&cntxt-firm}
    p-host-code
    ''
    0
    0
    0
    0
    true
    v-right-buyer
  }
  if v-right-buyer = false then return .

end.
  assign
    Fin-Ob-List:MAX-DATA-GUESS IN FRAME {&FRAME-NAME}     = 200
    Fin-Ob-List:num-locked-columns = 1
    Fin-Doc-List:MAX-DATA-GUESS IN FRAME {&FRAME-NAME}   = 200
    Fin-Doc-List:num-locked-columns = 1
    {&cop-l1}:read-only in browse Fin-Ob-List = yes
    {&cop-p1}:read-only in browse Fin-Doc-List = yes
    sum-fin-ob:read-only = yes
    sum-fin-doc:read-only = yes
  .
  create temp-contr .
  assign temp-contr.id = -1 .
  create temp-contr1 .
  assign temp-contr1.id = -1 .

  find first clients no-lock where clients.obj-type = {&cmp} and clients.obj-code = v-cntxt-host-code-obj .

 { gbl/ed_date.i sch-date }
/* { gbl/setfltnm.i }*/

  RUN enable_UI.

/*  DISABLE  b-add   when (NOT can-do( bttns, "b-add" ) or p-doc-type = "all") WITH FRAME {&frame-name}.*/
  if mark-num = 0   then hide mark-num   in frame {&frame-name}.
  if mark-num-2 = 0 then hide mark-num-2 in frame {&frame-name}.
  assign
    RADIO-find-doc
    RADIO-find-cli
  .
  find first currency where currency.curr-code = 0 no-error.
  assign
    curr-name = currency.curr-abbr
    s-curr-code = currency.curr-code
  .
  display s-curr-code curr-name with frame {&frame-name}.

  buf_fin-ob.receiver-name:resizable in browse Fin-Ob-List   = true .
  buf_fin-ob.payer-name:resizable    in browse Fin-Ob-List   = true .
  p-gen:resizable                    in browse Fin-Ob-List   = true .
  buf_fin-ob.receiver-name:width     in browse Fin-Ob-List  = v-size-col1 .
  buf_fin-ob.payer-name:width        in browse Fin-Ob-List  = v-size-col2 .
  p-gen:width                        in browse Fin-Ob-List  = v-size-col3 .
  buf_fin-doc.receiver-name:resizable in browse Fin-Doc-List   = true .
  buf_fin-doc.payer-name:resizable    in browse Fin-Doc-List   = true .
  buf_fin-doc.receiver-name:width     in browse Fin-Doc-List  = v-size-col4 .
  buf_fin-doc.payer-name:width        in browse Fin-Doc-List  = v-size-col5 .

  REPOSITION Fin-Ob-List to row 1 No-ERROR.
  REPOSITION Fin-Doc-List to row 1 No-ERROR.

  Run OpenBR(yes, no, '':U) .
  Run OpenBR1(yes, no, '':U) .

  { gbl/mv-clmn.i   &browse-name = "Fin-Ob-List"    &frame-name = "{&frame-name}"    &ext-col = 19    &start-column = "2"  &prev-order-column_1 = v-order-col   &prev-order-column-condition_1 = " true = true  " }
  { gbl/mv-clmn.i   &browse-name = "Fin-Doc-List"   &frame-name = "{&frame-name}"    &ext-col = 21    &start-column = "2"  &prev-order-column_1 = v-order-col1  &prev-order-column-condition_1 = " true = true  " }

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE conn-avt Dialog-Frame 
PROCEDURE conn-avt :
do on error undo, return error return-value :

  define input  parameter p-ri as recid     no-undo .
  define input  parameter p-list         as  character no-undo . /* список recid обязат.*/

  define variable csum as decimal   no-undo .
  define variable is-plus as logical   no-undo .
  define variable ii as integer   no-undo .
  define variable p-sys-time  as character no-undo .

  find first fin-doc no-lock where recid(fin-doc) = p-ri .
  assign csum = fin-doc.sum-contr - fin-doc.con-sum-contr .
  for each temp_fin-ob : delete temp_fin-ob . end.
  if p-doc-type = {&income} then do:
    if   fin-doc.fin-doc-type = {&expense-cashless}
      or fin-doc.fin-doc-type = {&expense-cash}
      or fin-doc.fin-doc-type = {&expense-payoff} then assign is-plus = yes .
    else
      assign
        is-plus = no
        csum = - csum
      .
  end.
  else do:
    if   fin-doc.fin-doc-type = {&income-cashless}
      or fin-doc.fin-doc-type = {&income-cash}
      or fin-doc.fin-doc-type = {&income-payoff} then assign is-plus = yes .
    else
      assign
        is-plus = no
        csum = - csum
      .
  end.

  define variable p-new as character no-undo .
  DO ii = 1 TO NUM-ENTRIES(p-list) :
    find first fin-ob NO-LOCK WHERE RECID( fin-ob ) = INT ( ENTRY( ii, p-list) ) .
    if is-plus = yes and fin-ob.sum-contr > 0 or is-plus = no and fin-ob.sum-contr < 0  then do:
      if p-new = "" then  assign p-new = ENTRY( ii, p-list).
      else  assign p-new = p-new + "," + ENTRY( ii, p-list) .
    end.
    else do:
      CREATE temp_fin-ob .
      BUFFER-COPY fin-ob TO temp_fin-ob .
      assign temp_fin-ob.ri = RECID( fin-ob ) .
      assign
        temp_fin-ob.no-con-sum = temp_fin-ob.sum-contr - temp_fin-ob.con-sum-contr
        csum = csum - temp_fin-ob.no-con-sum
/*        current-sum = current-sum + temp_fin-ob.no-con-sum*/
      .
    end.
  end.
  assign p-list = p-new .

  DO ii = 1 TO NUM-ENTRIES(p-list) :
    find first fin-ob NO-LOCK WHERE RECID( fin-ob ) = INT ( ENTRY( ii, p-list) ) .
    CREATE temp_fin-ob .
    BUFFER-COPY fin-ob TO temp_fin-ob .
    assign temp_fin-ob.ri = RECID( fin-ob ) .
    if csum > 0 then do:
      if csum > temp_fin-ob.sum-contr - temp_fin-ob.con-sum-contr then do:
        assign
          temp_fin-ob.no-con-sum = temp_fin-ob.sum-contr - temp_fin-ob.con-sum-contr
          csum = csum - temp_fin-ob.no-con-sum
        .
      end.
      else do:
        assign
          temp_fin-ob.no-con-sum = csum
          csum = 0
        .
      end.
    END.
    else if csum < 0 then do:
      if csum < temp_fin-ob.sum-contr - temp_fin-ob.con-sum-contr then do:
        assign
          temp_fin-ob.no-con-sum = temp_fin-ob.sum-contr - temp_fin-ob.con-sum-contr
          csum = csum - temp_fin-ob.no-con-sum
        .
      end.
      else do:
        assign
          temp_fin-ob.no-con-sum = csum
          csum = 0
        .
      end.
    END.
  END.
  define variable all-sum-contr as decimal   no-undo .
  define variable all-sum-base as decimal   no-undo .
  define variable all-sum-rubl as decimal   no-undo .
  define variable all-sum-doc as decimal   no-undo .

  for each temp_fin-ob :
    if temp_fin-ob.no-con-sum = 0 then next.
    create fin-connect .
    assign
      fin-connect.connect-code   = next-value( s-fin-connect, {&db-name_schema}  )
      fin-connect.host-code      = v-cntxt-host-code-obj
      fin-connect.fin-doc-code   = fin-doc.fin-doc-code
      fin-connect.fin-ob-code    = temp_fin-ob.doc-code
      fin-connect.contract-code  = temp_fin-ob.contract-code
      fin-connect.curr-code      = temp_fin-ob.curr-code
      fin-connect.base-rate      = temp_fin-ob.base-rate
      fin-connect.base-scale     = temp_fin-ob.base-scale
      fin-connect.contract-curr  = temp_fin-ob.contract-curr
      fin-connect.contract-rate  = temp_fin-ob.contract-rate
      fin-connect.contract-scale = temp_fin-ob.contract-scale
      fin-connect.exch-rate      = temp_fin-ob.exch-rate
      fin-connect.exch-scale     = temp_fin-ob.exch-scale
      fin-connect.status_        = {&current-status}
      fin-connect.sum-contr      = temp_fin-ob.no-con-sum
      fin-connect.sum-rubl       = round(fin-connect.sum-contr * fin-connect.contract-rate / fin-connect.contract-scale,2)
      fin-connect.sum-base       = fin-connect.sum-rubl * fin-connect.base-scale / fin-connect.base-rate
      fin-connect.sum-doc        = fin-connect.sum-rubl * fin-connect.exch-scale / fin-connect.exch-rate
      fin-connect.sum-contr-ob   = fin-connect.sum-contr
      fin-connect.sum-rubl-ob    = fin-connect.sum-rubl
      fin-connect.sum-base-ob    = fin-connect.sum-base
    .
    { gbl/curdburt.i  fin-connect.user-db-num  fin-connect.user-name  fin-connect.fact-date  p-sys-time  fin-connect.fact-time }
    find first fin-ob exclusive-lock where fin-ob.host-code = v-cntxt-host-code-obj and fin-ob.doc-code = temp_fin-ob.doc-code .
    assign
      fin-ob.con-sum-contr = fin-ob.con-sum-contr + fin-connect.sum-contr
      fin-ob.con-sum-base  = fin-ob.con-sum-base  + fin-connect.sum-base
      fin-ob.con-sum-rubl  = fin-ob.con-sum-rubl  + fin-connect.sum-rubl
      fin-ob.con-sum-doc   = fin-ob.con-sum-doc   + fin-connect.sum-doc
      all-sum-contr        = all-sum-contr + fin-connect.sum-contr
      all-sum-base         = all-sum-base  + fin-connect.sum-base
      all-sum-rubl         = all-sum-rubl  + fin-connect.sum-rubl
      all-sum-doc          = all-sum-doc   + fin-connect.sum-doc
    .
    if fin-ob.sum-contr > 0 then do:
      if fin-ob.sum-contr > fin-ob.con-sum-contr then assign fin-ob.con-stat = 1 .
      else                                            assign fin-ob.con-stat = 2 .
    end.
    else do:
      if fin-ob.sum-contr < fin-ob.con-sum-contr then assign fin-ob.con-stat = 1 .
      else                                            assign fin-ob.con-stat = 2 .
    end.
  end.
  if all-sum-contr <> 0 then do:
    find current fin-doc exclusive-lock .
    if is-plus then do:
      assign
        fin-doc.con-sum-contr = fin-doc.con-sum-contr + all-sum-contr
        fin-doc.con-sum-base  = fin-doc.con-sum-base  + all-sum-base
        fin-doc.con-sum-rubl  = fin-doc.con-sum-rubl  + all-sum-rubl
        fin-doc.con-sum-doc   = fin-doc.con-sum-doc   + all-sum-doc
      .
      if fin-doc.sum-contr > fin-doc.con-sum-contr then assign fin-doc.con-stat = 1 .
      else                                              assign fin-doc.con-stat = 2 .
    end.
    else do:
      assign
        fin-doc.con-sum-contr = fin-doc.con-sum-contr - all-sum-contr
        fin-doc.con-sum-base  = fin-doc.con-sum-base  - all-sum-base
        fin-doc.con-sum-rubl  = fin-doc.con-sum-rubl  - all-sum-rubl
        fin-doc.con-sum-doc   = fin-doc.con-sum-doc   - all-sum-doc
      .
      if fin-doc.sum-contr > fin-doc.con-sum-contr then assign fin-doc.con-stat = 1 .
      else                                              assign fin-doc.con-stat = 2 .
    end.
  end.

  end.
end procedure. /* conn-avt */

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
  DISPLAY sum-fin-doc sum-fin-ob sch-code RADIO-find-cli cli-code cli-type 
          RADIO-find-doc s-curr-code sch-date cli-name Curr-Types Sel-Client 
          Sel-Contr date-1 Sel-Status date-2 mark-num-2 mark-num curr-name 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-conn-add B-conn-view B-oplat-list B-Help RECT-status RECT-1 
         B-conn-doc B-view-doc B-del-doc B-conn-fo B-view-fo Fin-Ob-List 
         Fin-Doc-List B-mark-2 B-unmark-2 B-allmark-2 sum-fin-doc B-mark 
         B-unmark B-allmark B-oplat sum-fin-ob BUTTON-cli sch-code 
         RADIO-find-cli cli-code cli-type RADIO-find-doc BUTTON-curr 
         s-curr-code sch-date cli-name Curr-Types Sel-Client Sel-Contr date-1 
         Sel-Status B-date date-2 mark-num-2 mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-cli Dialog-Frame 
PROCEDURE find-cli :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_clients for clients .

  if p-obj-type <> {&cmp} and p-obj-type <> {&prs} then do:
    find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = p-obj-code no-error.
    if not available buf_clients then do:
      find first buf_clients no-lock where buf_clients.obj-type = {&prs} and buf_clients.obj-code = p-obj-code no-error.
    end.
  end.
  else find first buf_clients no-lock where buf_clients.obj-type = p-obj-type and buf_clients.obj-code = p-obj-code no-error.

  if not available buf_clients then do:
    if p-obj-code = 0 then assign p-obj-code = ? .
    if p-obj-code = ? then do:
      assign  cli-name = ""  cli-code = ?  cli-type  = "" .
      display cli-name       cli-code      cli-type   with frame {&frame-name}.
    end.
    else do:
        apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
    end.
    return.
  end.
  assign cli-name  = buf_clients.obj-name  cli-code  = p-obj-code  cli-type  = buf_clients.obj-type.
  display cli-name    cli-code     cli-type   with frame {&frame-name}.

  run proc-find-cli in this-procedure(no, input cli-code, input cli-type ) no-error.
  if error-status:error then return no-apply.
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

  if available buf_fin-ob then assign v-doc-rec = recid (buf_fin-ob) .

  assign frame {&frame-name}:title = "Планирование платежей.  Фирма: (" + string(v-cntxt-host-code-obj) + ")":U + {&space-char} + clients.obj-name  .

  if Sel-Contr = "all" and Sel-Client = "all"  then RUN OpenBrAllContr( p-open-query, p-find-next, p-find-condition) .
  else                                              RUN OpenBrSelContr( p-open-query, p-find-next, p-find-condition) .

  run proc-mark in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr1 Dialog-Frame 
PROCEDURE OpenBr1 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  if available buf_fin-doc then assign v-doc-rec1 = recid (buf_fin-doc) .

  assign frame {&frame-name}:title = "Планирование платежей.  Фирма: (" + string(v-cntxt-host-code-obj) + ")":U + {&space-char} + clients.obj-name  .

  if Sel-Contr = "all" and Sel-Client = "all"  then RUN OpenBr1AllContr( p-open-query, p-find-next, p-find-condition) .
  else                                              RUN OpenBr1SelContr( p-open-query, p-find-next, p-find-condition) .

  run proc-mark1 in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr1AllContr Dialog-Frame 
PROCEDURE OpenBr1AllContr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable l-query-was-opened as logical no-undo .
  define variable sort-column-phrase as character no-undo .

  case sort-column-name1 :
    when "" then assign  sort-column-phrase = ""  .
    otherwise    assign  sort-column-phrase = "by " + sort-column-name1 .
  end case.

  /* определяем здесь общие параметры для процедуры открытия query fltopend.i */
  &scop flt-open-open-query OPEN QUERY Fin-Doc-List FOR EACH buf_fin-doc
  &scop flt-open-dyn_open-query  FOR EACH buf_fin-doc
  &scop flt-open-query-handle query Fin-Doc-List:handle
  &scop flt-open-open-query-tail ,first temp-contr1
  &scop flt-open-dyn_open-query-tail  substitute(', first temp-contr1')
  &scop flt-open-waitfram true
  &scop flt-open-query-was-opened  l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point filter-point
  &scop flt-open-set-filter-name
  &scop flt-open-query p-open-query
  &scop flt-open-table-name buf_fin-doc
  &scop flt-open-search-option no-lock
  &scop flt-open-find-next p-find-next
  &scop flt-open-find-recid v-doc-rec1
  &scop flt-open-find-condition p-find-condition
  &scop flt-open-find-buffer-name buf_fin-doc

  for each temp-fin-doc : assign temp-fin-doc.del = yes . end.

  if Curr-types = "all" then do:
    case Sel-Status :
      when "all"  then do:
        { gbl/fltopend.i
          &where-cond = " buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0  "
          &DYN_where-cond = " substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 ', p-host-code)"
          &use-ind    = "  "
          &by   = " by buf_fin-doc.doc-date descending "
        }
      end.
      when "new"  then do:
        { gbl/fltopend.i
          &where-cond = " buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> {&fin-fact} "
          &DYN_where-cond = " substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> &3&2&3 ', p-host-code, {&fin-fact}, ~{&double-quote~})"
          &use-ind = "  "
          &by = " by buf_fin-doc.doc-date descending "
        }
      end.
      when "fact" then do:
        { gbl/fltopend.i
          &where-cond = " buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ =  {&fin-fact} "
          &DYN_where-cond = " substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ = &3&2&3 ', p-host-code, {&fin-fact}, ~{&double-quote~})"
          &use-ind = "  "
          &by = " by buf_fin-doc.doc-date descending "
        }
      end.
    end.
  end.
  else do:
    case Sel-Status :
      when "all"  then do:
        { gbl/fltopend.i
          &where-cond = " buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.curr-code = curr-code "
          &DYN_where-cond = " substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.curr-code = &3 ', p-host-code, curr-code )"
          &use-ind = "  "
          &by = " by buf_fin-doc.doc-date descending "
        }
      end.
      when "new"  then do:
        { gbl/fltopend.i
          &where-cond = " buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> {&fin-fact} and buf_fin-doc.curr-code = curr-code "
          &DYN_where-cond = " substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ <> &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, {&fin-fact}, curr-code , ~{&double-quote~})"
          &use-ind = "  "
          &by = " by buf_fin-doc.doc-date descending "
        }
      end.
      when "fact" then do:
        { gbl/fltopend.i
          &where-cond = " buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ =  {&fin-fact} and buf_fin-doc.curr-code = curr-code "
          &DYN_where-cond = " substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.contract-code > 0 and buf_fin-doc.status_ = &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, {&fin-fact}, curr-code , ~{&double-quote~})"
          &use-ind = "  "
          &by = " by buf_fin-doc.doc-date descending "
        }
      end.
    end.
  end.

  REPOSITION Fin-Doc-List to recid v-doc-rec1 No-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr1SelContr Dialog-Frame 
PROCEDURE OpenBr1SelContr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable l-query-was-opened as logical no-undo .
  define variable sort-column-phrase as character no-undo .

  case sort-column-name1 :
    when "" then assign  sort-column-phrase = ""  .
    otherwise    assign  sort-column-phrase = "by " + sort-column-name1 .
  end case.

  /* определяем здесь общие параметры для процедуры открытия query fltopend.i */
  &scop flt-open-open-query OPEN QUERY Fin-Doc-List FOR EACH buf_fin-doc
  &scop flt-open-dyn_open-query  FOR EACH buf_fin-doc
  &scop flt-open-query-handle query Fin-Doc-List:handle
  &scop flt-open-open-query-tail ,first temp-contr1 where temp-contr1.id = buf_fin-doc.contract-code
  &scop flt-open-dyn_open-query-tail  substitute(', first temp-contr1 where temp-contr1.id = &1 ',buf_fin-doc.contract-code)
  &scop flt-open-waitfram true
  &scop flt-open-query-was-opened  l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point filter-point
  &scop flt-open-set-filter-name
  &scop flt-open-query p-open-query
  &scop flt-open-table-name buf_fin-doc
  &scop flt-open-search-option no-lock
  &scop flt-open-find-next p-find-next
  &scop flt-open-find-recid v-doc-rec1
  &scop flt-open-find-condition p-find-condition
  &scop flt-open-find-buffer-name buf_fin-doc

  for each temp-fin-doc : assign temp-fin-doc.del = yes . end.

  if Curr-types = "all" then do:
    case Sel-Status :
      when "all"  then do:
        { gbl/fltopend.i
          &where-cond = " buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 "
          &DYN_where-cond = " substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 ', p-host-code )"
          &use-ind = "  "
          &by = " by buf_fin-doc.doc-date descending "
        }
      end.
      when "new"  then do:
        { gbl/fltopend.i
          &where-cond = " buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ <> {&fin-fact} "
          &DYN_where-cond = " substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ <> &3&2&3 ', p-host-code, {&fin-fact}, ~{&double-quote~})"
          &use-ind = "  "
          &by = " by buf_fin-doc.doc-date descending "
        }
      end.
      when "fact" then do:
        { gbl/fltopend.i
          &where-cond = " buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ =  {&fin-fact} "
          &DYN_where-cond = " substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ = &3&2&3 ', p-host-code, {&fin-fact}, ~{&double-quote~})"
          &use-ind = "  "
          &by = " by buf_fin-doc.doc-date descending "
        }
      end.
    end.
  end.
  else do:
    case Sel-Status :
      when "all"  then do:
        { gbl/fltopend.i
          &where-cond = " buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.curr-code = curr-code "
          &DYN_where-cond = " substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.curr-code = &3 ', p-host-code, curr-code )"
          &use-ind = "  "
          &by = " by buf_fin-doc.doc-date descending "
        }
      end.
      when "new"  then do:
        { gbl/fltopend.i
          &where-cond = " buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_   <> {&fin-fact} and buf_fin-doc.curr-code = curr-code "
          &DYN_where-cond = " substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ <> &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, {&fin-fact}, curr-code , ~{&double-quote~})"
          &use-ind = "  "
          &by = " by buf_fin-doc.doc-date descending "
        }
      end.
      when "fact" then do:
        { gbl/fltopend.i
          &where-cond = " buf_fin-doc.host-code = p-host-code and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_   =  {&fin-fact} and buf_fin-doc.curr-code = curr-code "
          &DYN_where-cond = " substitute(' buf_fin-doc.host-code = &1 and buf_fin-doc.con-stat <> 2 and buf_fin-doc.status_ = &4&2&4 and buf_fin-doc.curr-code = &3 ', p-host-code, {&fin-fact}, curr-code , ~{&double-quote~})"
          &use-ind = "  "
          &by = " by buf_fin-doc.doc-date descending "
        }
      end.
    end.
  end.

  REPOSITION Fin-Doc-List to recid v-doc-rec1 No-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBrAllContr Dialog-Frame 
PROCEDURE OpenBrAllContr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable l-query-was-opened as logical no-undo .
  define variable sort-column-phrase as character no-undo .

  case sort-column-name :
    when "" then assign  sort-column-phrase = ""  .
    otherwise    assign  sort-column-phrase = "by " + sort-column-name .
  end case.

  /* определяем здесь общие параметры для процедуры открытия query fltopend.i */
  &scop flt-open-open-query OPEN QUERY Fin-Ob-List FOR EACH buf_fin-ob
  &scop flt-open-dyn_open-query  FOR EACH buf_fin-ob
  &scop flt-open-query-handle query Fin-Ob-List:handle
  &scop flt-open-open-query-tail ,first temp-contr
  &scop flt-open-dyn_open-query-tail  substitute(', first temp-contr')
  &scop flt-open-waitfram true
  &scop flt-open-query-was-opened  l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point filter-point
  &scop flt-open-set-filter-name
  &scop flt-open-query p-open-query
  &scop flt-open-table-name buf_fin-ob
  &scop flt-open-search-option no-lock
  &scop flt-open-find-next p-find-next
  &scop flt-open-find-recid v-doc-rec
  &scop flt-open-find-condition p-find-condition
  &scop flt-open-find-buffer-name buf_fin-ob

  for each temp-fin-ob : assign temp-fin-ob.del = yes . end.

  if sel-date then do: /* есть даты платежа */
    if Curr-types = "all" then do:
      { gbl/fltopend.i
        &where-cond = " buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  {&fact} and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2 "
        &DYN_where-cond = " substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.pay-date >= &5 and buf_fin-ob.pay-date <= &6 ', p-host-code, p-fo-type, {&fin-fact}, ~{&double-quote~}, date-1, date-2)"
        &use-ind = "  "
        &by = " by buf_fin-ob.pay-date descending "
      }
    end.
    else do:
      { gbl/fltopend.i
        &where-cond = " buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  {&fact} and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = curr-code and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2  "
        &DYN_where-cond = " substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = &4 and buf_fin-ob.pay-date >= &6 and buf_fin-ob.pay-date <= &7 ', p-host-code, p-fo-type, {&fin-fact}, curr-code , ~{&double-quote~}, date-1, date-2)"
        &use-ind = "  "
        &by = " by buf_fin-ob.pay-date descending "
      }
    end.
  end.
  else do:
    if Curr-types = "all" then do:
      { gbl/fltopend.i
        &where-cond = " buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  {&fact} and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 "
        &DYN_where-cond = " substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 ', p-host-code, p-fo-type, {&fin-fact}, ~{&double-quote~})"
        &use-ind = "  "
        &by = " by buf_fin-ob.pay-date descending "
      }
    end.
    else do:
      { gbl/fltopend.i
        &where-cond = " buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  {&fact} and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = curr-code "
        &DYN_where-cond = " substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.contract-code > 0 and buf_fin-ob.curr-code = &4 ', p-host-code, p-fo-type, {&fin-fact}, curr-code , ~{&double-quote~})"
        &use-ind = "  "
        &by = " by buf_fin-ob.pay-date descending "
      }
    end.
  end.
  REPOSITION Fin-Ob-List to recid v-doc-rec No-ERROR.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBrSelContr Dialog-Frame 
PROCEDURE OpenBrSelContr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable l-query-was-opened as logical no-undo .
  define variable sort-column-phrase as character no-undo .

  case sort-column-name :
    when "" then assign  sort-column-phrase = ""  .
    otherwise    assign  sort-column-phrase = "by " + sort-column-name .
  end case.

  /* определяем здесь общие параметры для процедуры открытия query fltopend.i */
  &scop flt-open-open-query OPEN QUERY Fin-Ob-List FOR EACH buf_fin-ob
  &scop flt-open-dyn_open-query  FOR EACH buf_fin-ob
  &scop flt-open-query-handle query Fin-Ob-List:handle
  &scop flt-open-open-query-tail ,first temp-contr where temp-contr.id = buf_fin-ob.contract-code
  &scop flt-open-dyn_open-query-tail  substitute(', first temp-contr where temp-contr.id = &1 ',buf_fin-ob.contract-code)
  &scop flt-open-waitfram true
  &scop flt-open-query-was-opened  l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point filter-point
  &scop flt-open-set-filter-name
  &scop flt-open-query p-open-query
  &scop flt-open-table-name buf_fin-ob
  &scop flt-open-search-option no-lock
  &scop flt-open-find-next p-find-next
  &scop flt-open-find-recid v-doc-rec
  &scop flt-open-find-condition p-find-condition
  &scop flt-open-find-buffer-name buf_fin-ob

  for each temp-fin-ob : assign temp-fin-ob.del = yes . end.

  if sel-date then do: /* есть даты платежа */
    if Curr-types = "all" then do:
      { gbl/fltopend.i
        &where-cond = " buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  {&fact} and buf_fin-ob.con-stat <> 2 and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2   "
        &DYN_where-cond = " substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.pay-date >= &5 and buf_fin-ob.pay-date <= &6 ', p-host-code, p-fo-type, {&fin-fact}, ~{&double-quote~}, date-1, date-2)"
        &use-ind = "  "
        &by = " by buf_fin-ob.pay-date descending "
      }
    end.
    else do:
      { gbl/fltopend.i
        &where-cond = " buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ = {&fact}  and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = curr-code and buf_fin-ob.pay-date >= date-1 and buf_fin-ob.pay-date <= date-2  "
        &DYN_where-cond = " substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = &4 and buf_fin-ob.pay-date >= &6 and buf_fin-ob.pay-date <= &7 ', p-host-code, p-fo-type, {&fin-fact}, curr-code , ~{&double-quote~}, date-1, date-2)"
        &use-ind = "  "
        &by = " by buf_fin-ob.pay-date descending "
      }
    end.
  end.
  else do:
    if Curr-types = "all" then do:
      { gbl/fltopend.i
        &where-cond = " buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ =  {&fact} and buf_fin-ob.con-stat <> 2  "
        &DYN_where-cond = " substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &4&2&4 and buf_fin-ob.status_ = &4&3&4 and buf_fin-ob.con-stat <> 2 ', p-host-code, p-fo-type, {&fin-fact}, ~{&double-quote~})"
        &use-ind = "  "
        &by = " by buf_fin-ob.pay-date descending "
      }
    end.
    else do:
      { gbl/fltopend.i
        &where-cond = " buf_fin-ob.host-code = p-host-code and buf_fin-ob.doc-type = p-fo-type and buf_fin-ob.status_ = {&fact}  and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = curr-code  "
        &DYN_where-cond = " substitute(' buf_fin-ob.host-code = &1 and buf_fin-ob.doc-type = &5&2&5 and buf_fin-ob.status_ = &5&3&5 and buf_fin-ob.con-stat <> 2 and buf_fin-ob.curr-code = &4 ', p-host-code, p-fo-type, {&fin-fact}, curr-code , ~{&double-quote~})"
        &use-ind = "  "
        &by = " by buf_fin-ob.pay-date descending "
      }
    end.
  end.
  REPOSITION Fin-Ob-List to recid v-doc-rec No-ERROR.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-check-contract Dialog-Frame 
PROCEDURE proc-check-contract :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer b_fin-ob for fin-ob .
  define buffer b_fin-doc for fin-doc .
  define variable num-cont as integer   no-undo .
  define variable is-del as logical   no-undo .
  define variable obj-type as character no-undo .
  define variable obj-code as integer no-undo .
  assign num-cont = - 1 .
  for each temp-fin-ob :
    find first b_fin-ob no-lock where recid(b_fin-ob) = temp-fin-ob.ri .
    if num-cont = - 1 then
      assign
        num-cont = b_fin-ob.contract-code
        obj-type = b_fin-ob.obj-type
        obj-code = b_fin-ob.obj-code
      .
    else do:
      if obj-code <> 0 then do:
        if obj-type <> b_fin-ob.obj-type or obj-code <> b_fin-ob.obj-code then assign obj-code = 0 .
      end.
      if num-cont <> b_fin-ob.contract-code then do:
        message
          "Фин. обязательство № " b_fin-ob.prn-doc-code " (дата платежа " b_fin-ob.pay-date ") относится к другому договору, чем предыдущие док-ты!"
        view-as alert-box.
        return error .
      end.
    end.
    if b_fin-ob.con-stat = 2 then do:
      message
        "Фин. обязательство № " b_fin-ob.prn-doc-code " (дата платежа " b_fin-ob.pay-date ") уже полностью связано с платежем! Если хотите связать заново, то удалите сначала старую связь"
      view-as alert-box.
      return error .
    end.
  end.
  for each temp-fin-doc :
    find first b_fin-doc no-lock where recid(b_fin-doc) = temp-fin-doc.ri .
    if num-cont = - 1 then
      assign
        num-cont = b_fin-doc.contract-code
      .
    else do:
      if obj-code <> 0 then do:
        if obj-type <> b_fin-doc.obj-type or obj-code <> b_fin-doc.obj-code then assign obj-code = 0 .
      end.
      if num-cont <> b_fin-doc.contract-code then do:
        message
          "Платеж № " b_fin-doc.prn-doc-code " от " b_fin-doc.doc-date " относится к другому договору, чем предыдущие док-ты!"
        view-as alert-box.
        return error .
      end.
    end.
    if b_fin-ob.con-stat = 2  then do:
      message
        "Платеж № " b_fin-doc.prn-doc-code " от " b_fin-doc.doc-date " уже полностью связан с фин. обяз.! Если хотите связать заново, то удалите сначала старую связь"
      view-as alert-box.
      return error .
    end.
  end.
  if sysconf.fin-calc = {&fin-calc-obj} and obj-code = 0 then do:
    message
      substitute ("По фирме &1 ведется раздельный учет по объектам с поставщиками. Нельзя связать платежи и ФО с разных объектов.",sysconf.host-code)
    view-as alert-box.
    return error .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-cli Dialog-Frame 
PROCEDURE proc-find-cli :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-next as logical no-undo.
  define input parameter p-code as integer   no-undo .
  define input parameter p-type as character no-undo .

  display "  /  /":U @ sch-date "":U @ sch-code  with frame {&frame-name}.
  assign p-type = {&double-quote} + p-type + {&double-quote}.
  if RADIO-find-doc = 1 then do:
    if RADIO-find-cli = 1 then run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-ob.payer-code = &1 and buf_fin-ob.payer-type = &2 ", p-code, p-type)) .
    else                       run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-ob.receiver-code = &1 and buf_fin-ob.receiver-type = &2 ", p-code, p-type)) .
  end.
  else do:
    if RADIO-find-cli = 1 then run OpenBr1 in this-procedure (input false, input p-next, input substitute("and buf_fin-doc.payer-code = &1 and buf_fin-doc.payer-type = &2 ", p-code, p-type)) .
    else                       run OpenBr1 in this-procedure (input false, input p-next, input substitute("and buf_fin-doc.receiver-code = &1 and buf_fin-doc.receiver-type = &2 ", p-code, p-type)) .
  end.
  apply "entry":u to cli-code in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-cli-name Dialog-Frame 
PROCEDURE proc-find-cli-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-next as logical no-undo.
  define input parameter p-code as character no-undo .

  display "  /  /":U @ sch-date "":U @ sch-code 0 @ cli-code "":U @ cli-type with frame {&frame-name}.
  assign p-code = replace(p-code, {&single-quote}, {&single-quote} + {&single-quote}) .

  if RADIO-find-doc = 1 then do:
    if RADIO-find-cli = 1 then run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-ob.payer-name begins '&1' ", p-code)) .
    else                       run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-ob.receiver-name begins '&1' ", p-code)) .
  end.
  else do:
    if RADIO-find-cli = 1 then run OpenBr1 in this-procedure (input false, input p-next, input substitute("and buf_fin-doc.payer-name begins '&1' ", p-code)) .
    else                       run OpenBr1 in this-procedure (input false, input p-next, input substitute("and buf_fin-doc.receiver-name begins '&1' ", p-code)) .
  end.
  apply "entry":u to cli-name in frame {&frame-name} .
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
  define input parameter p-next as logical no-undo.
  define input parameter p-code as character no-undo .

  display "  /  /":U @ sch-date 0 @ cli-code "":U @ cli-type "":U @ cli-name with frame {&frame-name}.
/*  assign p-code = {&double-quote} + p-code + {&double-quote}.*/
  assign p-code = replace(p-code, {&single-quote}, {&single-quote} + {&single-quote}) .

  if RADIO-find-doc = 1 then do:
    if p-code = '""' then run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-ob.prn-doc-code = '' " )).
    else                  run OpenBr in this-procedure (input false, input p-next, input substitute("and buf_fin-ob.prn-doc-code begins '&1' ", p-code)).
  end.
  else do:
    if p-code = '""' then run OpenBr1 in this-procedure (input false, input p-next, input substitute("and buf_fin-doc.prn-doc-code = '' " )).
    else                  run OpenBr1 in this-procedure (input false, input p-next, input substitute("and buf_fin-doc.prn-doc-code begins '&1' ", p-code)).
  end.
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
  define input parameter p-next as logical no-undo.
  define input parameter par-date as date    no-undo .

  display "":U @ sch-code 0 @ cli-code "":U @ cli-type "":U @ cli-name  with frame {&frame-name}.
  define variable var-datechr as character no-undo .
  assign var-datechr = string(day(par-date)) + {&slash-char} + string(month(par-date)) + {&slash-char} + string(year(par-date)) .
  if RADIO-find-doc = 1 then run OpenBr  in this-procedure (input false, input p-next,input substitute("and buf_fin-ob.pay-date = &1 ", var-datechr)) .
  else                       run OpenBr1 in this-procedure (input false, input p-next,input substitute("and buf_fin-doc.doc-date = &1 ", var-datechr)) .
  apply "entry":u to sch-date in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-mark Dialog-Frame 
PROCEDURE proc-mark :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign
    sum-fin-ob = 0
    num-fin-ob = 0
  .
  GET FIRST Fin-Ob-List NO-LOCK .

  DO WHILE AVAILABLE(buf_fin-ob):
    find first temp-fin-ob where temp-fin-ob.ri = recid( buf_fin-ob ) no-error .
    if available temp-fin-ob then do:
      assign
        num-fin-ob = num-fin-ob + 1
        temp-fin-ob.del = no
      .
      assign
        sum-fin-ob = sum-fin-ob + get-free-sum(buffer buf_fin-ob)
      .
    end.
    GET next Fin-Ob-List NO-LOCK .
  end.
  for each temp-fin-ob where temp-fin-ob.del = yes : delete temp-fin-ob . end.

  if num-fin-ob = 0 then hide mark-num in frame {&frame-name}.
  else                   display num-fin-ob @ mark-num  with frame {&frame-name}.
  display sum-fin-ob  with frame {&frame-name}.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-mark1 Dialog-Frame 
PROCEDURE proc-mark1 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign
    sum-fin-doc = 0
    num-fin-doc = 0
  .
  GET FIRST Fin-Doc-List NO-LOCK .

  DO WHILE AVAILABLE(buf_fin-doc):
    find first temp-fin-doc where temp-fin-doc.ri = recid( buf_fin-doc ) no-error .
    if available temp-fin-doc then do:
      assign
        num-fin-doc = num-fin-doc + 1
        temp-fin-doc.del = no
      .
      assign
        sum-fin-doc = sum-fin-doc + get-free-sum1(buffer buf_fin-doc)
      .
    end.
    GET next Fin-Doc-List NO-LOCK .
  end.
  for each temp-fin-doc where temp-fin-doc.del = yes : delete temp-fin-doc . end.

  if num-fin-doc = 0 then hide mark-num-2 in frame {&frame-name}.
  else                   display num-fin-doc @ mark-num-2  with frame {&frame-name}.
  display sum-fin-doc  with frame {&frame-name}.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION contract-gen Dialog-Frame 
FUNCTION contract-gen RETURNS CHARACTER
  ( input p-contract-code as integer ) :
  define variable rr as character no-undo .
  define buffer buf_contract for contract.
  find first buf_contract no-lock where  buf_contract.host-code      = p-host-code  and buf_contract.contract-code  = p-contract-code no-error.
  if available buf_contract then   rr = buf_contract.usl-opl .
  else rr = "".
  RETURN rr.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION contract-id Dialog-Frame 
FUNCTION contract-id RETURNS CHARACTER
  ( input p-contract-code as integer ) :
  define variable rr as character no-undo .
  define buffer buf_contract for contract.
  find first buf_contract no-lock where  buf_contract.host-code      = p-host-code and buf_contract.contract-code  = p-contract-code  no-error.
  if available buf_contract then   rr = buf_contract.contract-prn-code.
  else rr = "".
  RETURN rr.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-curr-sum Dialog-Frame 
FUNCTION get-curr-sum RETURNS decimal
  ( input p-cur as integer, input p-doc-curr as integer, input p-cur-contr as integer, input p-sum-contract as decimal, input p-sum-rubl as decimal, input p-sum-base as decimal, input p-sum-doc as decimal ) :
  define variable sum as decimal   no-undo .
  if p-cur = p-cur-contr then assign sum = p-sum-contract .
  else do:
    if p-cur = 1 then assign sum = p-sum-base .
    else do:
      if p-cur = p-doc-curr then assign sum = p-sum-doc .
      else do:
        if p-cur = 0 then assign sum = p-sum-rubl .
        else assign sum = ? .
      end.
    end.
  end.
  RETURN sum .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-currency Dialog-Frame 
FUNCTION get-currency RETURNS CHARACTER
  ( input curr-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable var-curr-name as character no-undo.
define buffer buf_currency for currency.
  find first buf_currency no-lock where buf_currency.curr-code = curr-code no-error .
  if available buf_currency then assign var-curr-name = buf_currency.curr-abbr .
RETURN var-curr-name.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-free-sum Dialog-Frame 
FUNCTION get-free-sum RETURNS decimal
  ( BUFFER loc-fin-ob FOR fin-ob ) :
  define variable sum as decimal   no-undo .
  if s-curr-code = loc-fin-ob.contract-curr then assign sum = loc-fin-ob.sum-contract - loc-fin-ob.con-sum-contr .
  else do:
    if s-curr-code = 1 then assign sum = loc-fin-ob.sum-base - loc-fin-ob.con-sum-base .
    else do:
      if s-curr-code = loc-fin-ob.curr-code then assign sum = loc-fin-ob.sum-doc - loc-fin-ob.con-sum-doc .
      else do:
        if s-curr-code = 0 then assign sum = loc-fin-ob.sum-rubl - loc-fin-ob.con-sum-rubl .
        else assign sum = ? .
      end.
    end.
  end.
  RETURN sum .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-free-sum1 Dialog-Frame 
FUNCTION get-free-sum1 RETURNS decimal
  ( BUFFER loc-fin-doc FOR fin-doc ) :
  define variable sum as decimal   no-undo .
  if s-curr-code = 0 then assign sum = loc-fin-doc.sum-rubl - loc-fin-doc.con-sum-rubl .
  else do:
    if s-curr-code = 1 then assign sum = loc-fin-doc.sum-base - loc-fin-doc.con-sum-base .
    else do:
      if s-curr-code = loc-fin-doc.curr-code then assign sum = loc-fin-doc.sum-doc - loc-fin-doc.con-sum-doc .
      else do:
        if s-curr-code = loc-fin-doc.contract-curr then assign sum = loc-fin-doc.sum-contr - loc-fin-doc.con-sum-contr .
        else assign sum = ? .
      end.
    end.
  end.
  if p-doc-type = {&income} then do:
    if loc-fin-doc.fin-ext-doc-type = {&FDEDT_Income_Payoff} or
       loc-fin-doc.fin-ext-doc-type = {&FDEDT_Income_Cash} or
       loc-fin-doc.fin-ext-doc-type = {&FDEDT_Income_CashLess} then assign sum = - sum .
  end.
  else do:
    if loc-fin-doc.fin-ext-doc-type = {&FDEDT_Expense_Payoff} or
       loc-fin-doc.fin-ext-doc-type = {&FDEDT_Expense_Cash} or
       loc-fin-doc.fin-ext-doc-type = {&FDEDT_Expense_CashLess} then assign sum = - sum .
  end.
  RETURN sum .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-ostat Dialog-Frame 
FUNCTION get-ostat RETURNS decimal
  ( input p-sum1 as decimal, input p-sum2 as decimal ) :
  RETURN p-sum1 - p-sum2 .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame 
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input typ as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable ret as character no-undo .
  assign ret = "" .
  define buffer b_fin-ob for fin-ob.
  define buffer b_fin-doc for fin-doc.

  if typ = 0 then do:
    find first temp-fin-ob where temp-fin-ob.ri = par-recid no-error .
    if available temp-fin-ob then
      assign
        ret = "*"
        temp-fin-ob.del = no
      .
  end.
  else do:
    find first temp-fin-doc where temp-fin-doc.ri = par-recid no-error .
    if available temp-fin-doc then
      assign
        ret = "*"
        temp-fin-doc.del = no
      .
  end.
  RETURN ret .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

