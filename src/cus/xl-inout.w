&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r11 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME xl-inout
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS xl-inout
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет в Еxcel Отчет по расходу товара

Автор: Чернова Светлана Александровна
Дата создания: 09/12/05
Author: Svetlana Chernova
Creation date: 09/12/05

*/
/*

Author: Исаков
Creation date: 06/29/04 1:12

*/
/*------------------------------------------------------------------------

  File:

  Description:

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author:

  Created: 07/27/98 -  5:17 pm

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc  as widget-handle no-undo.
define input parameter type-docs like ub.trn-doc.doc-type no-undo.

/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-pril.i new }
{ gbl/waitfram.i   }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i  def }

define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable g#log as logical   no-undo .

define variable v-cntxt-host-name-obj as character no-undo .

define buffer buf_rep_currency for ub.currency.
{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
{ gbl/basecode.i v-cntxt-host-code-obj base-code }


find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .

run get-report-num  in parParentProc ( output g#report-num ).


define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
define variable p-XL-delim as character no-undo .

define variable var-report-r-b as character no-undo .
{ gbl/curr-r-b.i  var-report-r-b }

  { gbl/getsect.i run {&cmp} v-cntxt-host-code-obj {&attr-report-firm} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'actuate'  then tmp-var1 = thbjattr_thbj-attr.property-value-character .
  end.

IF tmp-var1 = ""  then p-XL-delim = ";" .
else p-XL-delim = tmp-var1 .

define variable CliName like ub.clients.obj-name init "" no-undo.
define variable GrpName like ub.goods.grp-name init "" no-undo.
define variable str-et as char init "" no-undo.
define variable str-doc as char init "" no-undo.
define variable str-txt as char init "" no-undo.
define variable str-ret-sup as char init "" no-undo.
define variable str-discnt as char init "" no-undo.
define variable str-with-discnt as char init "" no-undo.

define variable counter as int no-undo.
define variable str-ind as int no-undo.
define variable i as int no-undo.

def stream OutStream.



define temp-table var-tbl no-undo
       field fact-num  like ub.trn-doc.fact-num      /*  Номер документа  */
       field cli-type    like ub.trn-doc.cli-type        /*  Производитель   */
       field cli-code   like ub.trn-doc.cli-code
       field quant       as  dec   /*  Кол-во  штук  */
       field summa    as  dec   /*  На сумму  */

       index code is unique primary
           fact-num
           cli-type
           cli-code
       .


define temp-table doc-tbl no-undo
       field fact-date  as date                        /*  Дата получния  */
       field num-doc  like ub.trn-doc.doc-code   /*   Номер накладной  */
       field fact-num  like ub.trn-doc.fact-num    /*  Номер документа  */
       field type-doc  like ub.trn-doc.doc-type    /*  Тип документа  */
       field client       like ub.trn-doc.cli-name    /*  Поставщик - Покупатель  */

       index num  is unique primary
          fact-num
       index code
           type-doc
           client.



define temp-table cli-tbl no-undo
       field cli-type    like ub.trn-doc.cli-type  /*  Производитель   */
       field cli-code   like ub.trn-doc.cli-code
       field cli-name  like ub.trn-doc.cli-name
       field quant       as  dec   /*  Кол-во  штук  */
       field summa    as  dec   /*  На сумму  */
     index code is unique primary
           cli-type
           cli-code

     index name
           cli-name
       .


define variable  with-discnt          as dec no-undo.
define variable  sum-with-discnt  as dec no-undo.
define variable  discnt                 as dec no-undo.
define variable  sum-discnt         as dec no-undo.
define variable  amount               as dec no-undo.
define variable  sum                    as dec no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME xl-inout

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-print b-help date-beg date-end
&Scoped-Define DISPLAYED-OBJECTS date-beg date-end

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-print DEFAULT
     LABEL "Печать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE date-beg AS DATE FORMAT "99/99/9999":U
     LABEL "С"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE date-end AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME xl-inout
     b-quit AT ROW 1 COL 1
     b-print AT ROW 1 COL 11
     b-help AT ROW 1 COL 28.5
     date-beg AT ROW 3 COL 3.5 COLON-ALIGNED
     date-end AT ROW 3 COL 20.5 COLON-ALIGNED
     SPACE(5.24) SKIP(0.91)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Отчет по расходу товара"
         DEFAULT-BUTTON b-print CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX xl-inout
                                                                        */
ASSIGN
       FRAME xl-inout:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX xl-inout
/* Query rebuild information for DIALOG-BOX xl-inout
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX xl-inout */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print xl-inout
ON CHOOSE OF b-print IN FRAME xl-inout /* Печать */
DO:
def buffer b-price-list for ub.price-list.
define variable d-price as decimal no-undo.
define variable t-d as char no-undo.
define variable i as int no-undo.
define variable pr-price  as log no-undo.
define variable pr-t-doc  as log no-undo.

assign
    date-beg
    date-end
    .


{ cmp/open-exp.i stream OutStream}

if session:set-wait-state("COMPILER") then.

if type-docs = {&expense} then do:
    create doc-tbl.
    assign
        doc-tbl.fact-num  = - 99     /*  Уникальный номер документа */
        doc-tbl.client       = "Со скидкой"
        doc-tbl.type-doc  = "Со скидкой".
    create doc-tbl.
    assign
        doc-tbl.fact-num  = - 999     /*  Уникальный номер документа */
        doc-tbl.client       = {&discount}
        doc-tbl.type-doc  = {&discount}.
end.  /*  if type-docs = {&expense} then do:  */


assign counter  = 0.

FOR EACH ub.trn-doc WHERE ub.trn-doc.obj-type = v-cntxt-obj-type
                                            AND ub.trn-doc.obj-code = v-cntxt-obj-code
                                            AND ub.trn-doc.fact-num <> 0
/*                                            AND ub.trn-doc.doc-type = type-docs*/
                                            AND ub.trn-doc.discnt-type <> {&cash-desk}
                                            AND ub.trn-doc.fact-date >= date-beg
                                            AND ub.trn-doc.fact-date <= date-end NO-LOCK:
    if type-docs = {&income} and ub.trn-doc.doc-type = {&expense} then next.
    else if type-docs = {&expense} and ub.trn-doc.doc-type = {&income} then next.
    else if type-docs = {&expense} and ub.trn-doc.doc-type = {&return} then next.


    create doc-tbl.
    assign
        doc-tbl.fact-num  = ub.trn-doc.fact-num     /*  Уникальный номер документа */
        doc-tbl.fact-date  = ub.trn-doc.fact-date     /*  Дата получния                 */
        doc-tbl.num-doc  = ub.trn-doc.doc-code    /*   Номер накладной            */
        doc-tbl.client       = ub.trn-doc.cli-name     /*  Поставщик - покупатель  */
        doc-tbl.type-doc  = ub.trn-doc.doc-type     /*   Тип документа                 */
    .

    if ub.trn-doc.doc-type = {&inventory} then doc-tbl.client = "Инвентаризация".
    else if ub.trn-doc.doc-type = {&return} and type-docs = {&income} then doc-tbl.client = {&return}.
    else if ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} and type-docs = {&expense} then doc-tbl.client = "Возврат поставщику".


    FOR EACH ub.doc-line WHERE ub.doc-line.doc-code = ub.trn-doc.doc-code NO-LOCK,
            EACH ub.clients WHERE ub.clients.obj-type = ub.doc-line.prod-type
                                                AND ub.clients.obj-code = ub.doc-line.prod-code NO-LOCK:

           assign
               with-discnt          = 0
               sum-with-discnt  = 0
               discnt                  = 0
               sum-discnt          = 0
               amount                = 0
               sum                     = 0 .

            FOR EACH ub.gds-dtl WHERE
                              ub.gds-dtl.prod-type  = ub.doc-line.prod-type
                      AND ub.gds-dtl.prod-code = ub.doc-line.prod-code
                      AND ub.gds-dtl.artic          = ub.doc-line.artic
                      AND ub.gds-dtl.doc-code   = ub.doc-line.doc-code
                  NO-LOCK:

                  if ub.trn-doc.doc-type =  {&inventory}  THEN do:
                            if ( ( type-docs = {&expense} AND ub.gds-dtl.doc-qnty >= 0 )
                                 OR ( type-docs = {&income} AND ub.gds-dtl.doc-qnty <= 0 ) ) then
                                NEXT.
                            else
                               assign
                                  amount = amount + absolute( ub.gds-dtl.doc-qnty )
                                  sum      = sum      +
                                  ( if var-report-r-b = "rubl" then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base )
                                  * absolute( ub.gds-dtl.doc-qnty ) .
                  end.
                  else do:
                      if  type-docs = {&expense} then   do:
                          assign
                              amount = amount + ub.gds-dtl.fact-qnty
                              sum      = sum      + ( (
                               ( if var-report-r-b = "rubl" then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base )
                                -
                                ( if var-report-r-b = "rubl" then ub.gds-dtl.discnt-rubl else ub.gds-dtl.discnt-base )

                                ) * ub.gds-dtl.fact-qnty ).

                          if   ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}   then  /* Возврат поставщику   */
                            assign
                                doc-tbl.type-doc  = {&return}
                                amount = amount + ub.gds-dtl.fact-qnty
                                sum      = sum      + (
                                  ( if var-report-r-b = "rubl" then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base )
                                  -
                                  ( if var-report-r-b = "rubl" then ub.gds-dtl.discnt-rubl else ub.gds-dtl.discnt-base )
                                   ) * ub.gds-dtl.fact-qnty  .
                          else     /*  Просто расход   */
                             assign
                                 with-discnt          = with-discnt + ub.gds-dtl.fact-qnty
                                 sum-with-discnt  = sum-with-discnt + ( (
                                  ( if var-report-r-b = "rubl" then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base )
                                  -
                                  ( if var-report-r-b = "rubl" then ub.gds-dtl.discnt-rubl else ub.gds-dtl.discnt-base )

                                   ) * ub.gds-dtl.fact-qnty )
                                 discnt          = discnt + ub.gds-dtl.fact-qnty
                                 sum-discnt  = sum-discnt + (
                                   ( if var-report-r-b = "rubl" then ub.gds-dtl.discnt-rubl else ub.gds-dtl.discnt-base )
                                   * ub.gds-dtl.fact-qnty ) .
                     end.  /*  if type-docs = {&expense} then   do:  */
                     else
                          assign
                              amount = amount + ub.gds-dtl.fact-qnty
                              sum      = sum      + ( ub.gds-dtl.cur-base * ub.gds-dtl.fact-qnty ).

                  end.  /*  else do:  */
            end. /*  FOR EACH ub.gds-dtl WHERE   */




            /*  А встречался ли нам такой производитель  */
            find  cli-tbl where
                     cli-tbl.cli-type   = ub.doc-line.prod-type
              and cli-tbl.cli-code  = ub.doc-line.prod-code
            use-index code no-lock no-error.
            if not available cli-tbl then do:
                /* Производитель не встречался - теперь будет  */
                create cli-tbl.
                assign
                   cli-tbl.cli-type    = ub.doc-line.prod-type
                   cli-tbl.cli-code   = ub.doc-line.prod-code
                   cli-tbl.cli-name  = ub.clients.obj-name.
            end.  /* if not available cli-tbl then do:  */

            find  var-tbl where
                     var-tbl.fact-num = ub.trn-doc.fact-num
              and var-tbl.cli-type   = ub.doc-line.prod-type
              and var-tbl.cli-code  = ub.doc-line.prod-code
            use-index code no-lock no-error.
            if not available var-tbl then do:
               create var-tbl.
               assign
                  var-tbl.cli-type    = ub.doc-line.prod-type  /*  Производитель                */
                  var-tbl.cli-code   = ub.doc-line.prod-code
                  var-tbl.fact-num  = ub.trn-doc.fact-num      /*  Номер документа  */
                .

            end.  /*  if not available var-tbl then do:   */







             assign
                  var-tbl.quant    = var-tbl.quant + amount  /*  Кол-во  штук  */
                  var-tbl.summa = var-tbl.summa +  sum.      /*  На сумму  */

              if type-docs = {&expense} and ub.trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} then   do:

                  /*  Сохранение строк  "Со скидкой (итого)" и {&discount}   */

                  find  var-tbl where
                           var-tbl.fact-num = - 99
                    and var-tbl.cli-type   = ub.doc-line.prod-type
                    and var-tbl.cli-code  = ub.doc-line.prod-code
                  use-index code no-lock no-error.
                  if not available var-tbl then do:
                      create var-tbl.
                      assign
                          var-tbl.cli-type    = ub.doc-line.prod-type       /*  Производитель  */
                          var-tbl.cli-code   = ub.doc-line.prod-code
                          var-tbl.fact-num  = - 99.      /*  Номер документа  */
                        .
                  end.  /* if not available var-tbl then do:  */
                  assign
                      var-tbl.quant    = var-tbl.quant    + with-discnt               /*  Кол-во  штук  */
                      var-tbl.summa = var-tbl.summa + sum-with-discnt.      /*  На сумму  */

                  find  var-tbl where
                           var-tbl.fact-num = - 999
                    and var-tbl.cli-type   = ub.doc-line.prod-type
                    and var-tbl.cli-code  = ub.doc-line.prod-code
                  use-index code no-lock no-error.
                  if not available var-tbl then do:
                      create var-tbl.
                      assign
                          var-tbl.cli-type    = ub.doc-line.prod-type       /*  Производитель                */
                          var-tbl.cli-code   = ub.doc-line.prod-code
                          var-tbl.fact-num  = - 999          /*  Номер документа  */
                        .
                  end.  /* if not available cli-tbl then do:  */
                  assign
                      var-tbl.quant    = var-tbl.quant    + discnt       /*  Кол-во  штук  */
                      var-tbl.summa = var-tbl.summa + sum-discnt.      /*  На сумму  */

              end.   /*  if type-docs = {&expense} then   do:  */

    END.  /* FOR EACH ub.doc-line WHERE   */


    assign counter = counter + 1.
    if ( counter MODULO 10 ) = 0 then
        run waitfram-show ( string( "Обработано " + string( counter )  + " документов" ) ).
END.  /*   FOR EACH ub.trn-doc WHERE   */



assign counter = 0.
FOR EACH ub.price-doc WHERE ub.price-doc.obj-type = v-cntxt-obj-type
                                                AND ub.price-doc.obj-code = v-cntxt-obj-code
                                                AND ub.price-doc.fact-num <> 0
                                                AND ub.price-doc.fact-date >= date-beg
                                                AND ub.price-doc.fact-date <= date-end NO-LOCK:

    create doc-tbl.
    assign
        doc-tbl.fact-num  = ub.price-doc.fact-num     /*  Уникальный номер документа */
        doc-tbl.fact-date  = ub.price-doc.fact-date     /*  Дата получния                 */
        doc-tbl.num-doc  = ub.price-doc.doc-num     /*   Номер накладной            */
        doc-tbl.client       = {&overvalue}           /*  Поставщик - покупатель  */
        doc-tbl.type-doc  = "пер"                         /*   Тип документа                 */
        pr-price               = false
    .
    FOR EACH ub.price-list WHERE ub.price-list.doc-num = ub.price-doc.doc-num NO-LOCK,
            EACH ub.goods WHERE ub.goods.artic = ub.price-list.artic
                                               AND ub.goods.prod-type = ub.price-list.prod-type
                                               AND ub.goods.prod-code = ub.price-list.prod-code NO-LOCK,
            EACH ub.clients WHERE ub.clients.obj-type = ub.goods.prod-type
                                                AND ub.clients.obj-code = ub.goods.prod-code NO-LOCK:

              /*  Поиск  предыдущей  цены  */
        FIND LAST b-price-list WHERE b-price-list.obj-type = v-cntxt-obj-type
                                                           AND b-price-list.obj-code = v-cntxt-obj-code
                                                           AND b-price-list.b-code  = ub.price-list.b-code
                                                           AND b-price-list.fact-order < ub.price-list.fact-order
                                                           NO-LOCK NO-ERROR.
        if not available b-price-list  then do:
                FIND ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
                FIND LAST b-price-list WHERE b-price-list.obj-type = v-cntxt-obj-type
                                                                  AND b-price-list.obj-code = v-cntxt-obj-code
                                                                  AND b-price-list.b-code  = ub.gds-prt.node-code
                                                                  AND b-price-list.fact-order < ub.price-list.fact-order
                                                                  NO-LOCK NO-ERROR.
        end.   /*   if not available b-price-list  then do:  */

        if not available b-price-list  then
            d-price = ub.price-list.price-sale * ub.price-list.doc-qnty.
        else
            d-price = ( ub.price-list.price-sale - b-price-list.price-sale ) * ub.price-list.doc-qnty.

        if ub.price-list.doc-qnty = ? then   NEXT.
        if ( ( type-docs = {&expense} AND d-price >= 0 ) OR ( type-docs = {&income} AND d-price <= 0 ) ) then
            NEXT.

            /*  А встречался ли нам такой производитель  */
            find  cli-tbl where
                     cli-tbl.cli-type   = ub.price-list.prod-type
              and cli-tbl.cli-code  = ub.price-list.prod-code
            use-index code no-lock no-error.
            if not available cli-tbl then do:
                /* Производитель не встречался - теперь будет  */
                create cli-tbl.
                assign
                   cli-tbl.cli-type    = ub.price-list.prod-type
                   cli-tbl.cli-code   = ub.price-list.prod-code
                   cli-tbl.cli-name  = ub.clients.obj-name.
            end.  /* if not available cli-tbl then do:  */

            find  var-tbl where
                      var-tbl.fact-num = ub.price-doc.fact-num
               and var-tbl.cli-type   = ub.price-list.prod-type
               and var-tbl.cli-code  = ub.price-list.prod-code
            use-index code no-lock no-error.
            if not available var-tbl then do:
                create var-tbl.
                assign
                    var-tbl.cli-type    = ub.price-list.prod-type    /*  Производитель                */
                    var-tbl.cli-code   = ub.price-list.prod-code
                    var-tbl.fact-num  = ub.price-doc.fact-num
                 .
            end.  /*  if not available cli-tbl then do:  */
            assign
                var-tbl.quant    = var-tbl.quant    + ub.price-list.doc-qnty       /*  Кол-во  штук  */
                var-tbl.summa = var-tbl.summa + d-price.      /*  На сумму  */
                pr-price            = true
              .

    END.   /*  FOR EACH ub.price-list WHERE  */
    if pr-price = false then delete doc-tbl.

    assign counter = counter + 1.
    if ( counter MODULO 10 ) = 0 then
        run waitfram-show ( string( "Обработано " + string( counter )  + " актов переоценки" ) ).

END.  /*  FOR EACH ub.price-doc WHERE   */



 /* Вывод шапки отчета    */

if type-docs = {&income} then
    EXPORT stream OutStream
         "Отчет по приходу товара".
else
    EXPORT stream OutStream
        "Отчет по расходу товара".

find ub.clients where ub.clients.obj-type = v-cntxt-obj-type
                     AND ub.clients.obj-code = v-cntxt-obj-code NO-LOCK.
EXPORT stream OutStream
    "Магазин/Склад"  p-xl-delim ub.clients.obj-name .


EXPORT stream OutStream
    "Отчетный период" p-xl-delim
    string(date-beg,  "99/99/9999" ) p-xl-delim
    " - "  p-xl-delim
    string( date-end,  "99/99/9999" ) .

put stream OutStream unformatted " " skip.


str-doc =  "Дата" + p-xl-delim  + "N документа" + p-xl-delim.

if type-docs = {&income} then
        str-doc = str-doc + "Отправитель"  + p-xl-delim.
else
        str-doc = str-doc + "Получатель"  + p-xl-delim.

str-txt =  p-xl-delim +  p-xl-delim +  p-xl-delim.


for each cli-tbl no-lock
   use-index name:
   assign
        str-doc = str-doc + cli-tbl.cli-name + p-xl-delim + p-xl-delim
        str-txt   = str-txt   + "шт." + p-xl-delim + "Стоимость {&abbr_rub_allshift}" +  p-xl-delim.
end.

assign
     str-doc = str-doc + "ИТОГО" + p-xl-delim + p-xl-delim
     str-txt   = str-txt   + "шт." + p-xl-delim + "Стоимость {&abbr_rub_allshift}" +  p-xl-delim.

EXPORT stream OutStream str-doc .
EXPORT stream OutStream str-txt .




do i = 1 to 6 :
    if i = 1 then do:
         if type-docs = {&income}  then t-d =  {&income}.
         else t-d = {&expense}.
    end.
    else if i = 4 then t-d = {&return}.
    else if i = 2 then do:
         if type-docs = {&income}  then next.
         else t-d = "Со скидкой".
    end.
    else if i = 3 then do:
         if type-docs = {&income}  then next.
         else t-d = {&discount}.
    end.
    else if i = 5 then t-d =  "пер".
    else if i = 6 then t-d =  {&inventory}.

    pr-t-doc = false.

    for each doc-tbl  where
            doc-tbl.type-doc = t-d
        use-index code  no-lock :

        if i = 2  or i = 3  then
           str-doc = p-xl-delim + p-xl-delim.
        else
            str-doc =  string(doc-tbl.fact-date, "99/99/9999") + p-xl-delim +
                            string(doc-tbl.num-doc) + p-xl-delim .

        assign
            amount = 0
            sum      = 0
            pr-t-doc = true
            str-doc =  str-doc +
                            string(doc-tbl.client)      + p-xl-delim.

        for each cli-tbl no-lock
            use-index name:

            find first var-tbl  WHERE
                     var-tbl.fact-num = doc-tbl.fact-num
              and var-tbl.cli-type   = cli-tbl.cli-type
              and var-tbl.cli-code   = cli-tbl.cli-code
            use-index code  no-lock no-error.
            if not available var-tbl then
                str-doc = str-doc + " "  + p-xl-delim
                                           + " "  + p-xl-delim.
            else  do:
                if i = 2 or i = 3 then
                    str-doc = str-doc +  p-xl-delim
                                               +  string(var-tbl.summa)   + p-xl-delim.

                else do:
                    if var-tbl.quant <> 0 then
                        str-doc = str-doc +  string(var-tbl.quant   )   + p-xl-delim.
                    else
                        str-doc = str-doc +  " "  + p-xl-delim.

                    if var-tbl.summa <> 0 then
                        str-doc = str-doc +  string(var-tbl.summa)   + p-xl-delim.
                    else
                        str-doc = str-doc +  " "  + p-xl-delim.

                    assign
                        cli-tbl.quant = cli-tbl.quant + var-tbl.quant
                        cli-tbl.summa = cli-tbl.summa + var-tbl.summa.
                end.


                assign
                    amount = amount + var-tbl.quant
                    sum      = sum      + var-tbl.summa.
             end.  /* else  do:  */

        end.  /*   for each cli-tbl no-lock   */
        if i = 2 or i = 3 then
            str-doc = str-doc + p-xl-delim
                                       +  string(sum)   + p-xl-delim.
        else do:
            if amount <> 0 then
               str-doc = str-doc +  string(amount   )   + p-xl-delim.
            else
               str-doc = str-doc +  " "   + p-xl-delim.
            if sum <> 0 then
               str-doc = str-doc +  string(sum)   + p-xl-delim.
            else
               str-doc = str-doc +  " "   + p-xl-delim.

        end.

        EXPORT stream OutStream str-doc .

    end.  /*  for each doc-tbl no-lock where  */
    if pr-t-doc = false then do:
        str-txt =  p-xl-delim +  p-xl-delim .

        if i = 4  and type-docs = {&expense} then
             EXPORT stream OutStream  p-xl-delim
                    p-xl-delim "Возврат поставщику" .
        else if i = 4  and type-docs = {&income} then
             EXPORT stream OutStream  p-xl-delim
                    p-xl-delim {&return} .
        else if i = 2   and type-docs = {&expense}  then
                 EXPORT stream OutStream p-xl-delim
                        p-xl-delim  "Со скидкой" .
        else if i = 3  and type-docs = {&expense}  then
                 EXPORT stream OutStream
                        p-xl-delim   p-xl-delim   {&discount} .
        else if i = 5 then
             EXPORT stream OutStream
                    p-xl-delim  p-xl-delim
                    {&overvalue}  p-xl-delim .
        else if i = 6 then
             EXPORT stream OutStream
                    p-xl-delim  p-xl-delim
                    "Инвентаризация"  p-xl-delim .

    end.  /*   if pr-t-doc = false then do:   */

end.   /*  do i = 1 to 6 :  */

str-txt =  p-xl-delim +  p-xl-delim  + "ИТОГО" +  p-xl-delim.

assign
  amount = 0
  sum = 0.
for each cli-tbl no-lock
    use-index name:
    if cli-tbl.quant <> 0 then
        str-txt = str-txt + string(cli-tbl.quant)    +  p-xl-delim .
    else
        str-txt = str-txt +  " "   + p-xl-delim.
    if cli-tbl.summa <> 0 then
        str-txt = str-txt + string(cli-tbl.summa) +  p-xl-delim .
    else
        str-txt = str-txt +  " "   + p-xl-delim.

    assign
        amount = amount + cli-tbl.quant
        sum      = sum      + cli-tbl.summa.


end.   /*  for each cli-tbl no-lock    */
str-txt = str-txt +  string(amount   )   + p-xl-delim
                        +  string(sum)           + p-xl-delim.

EXPORT stream OutStream str-txt .




run waitfram-hide.

put stream OutStream unformatted " " skip.

EXPORT stream OutStream p-xl-delim
    "Директор Магазина/Склада" p-xl-delim
    "Дата составления отчета " p-xl-delim
     string(TODAY,  "99/99/9999")   .

EXPORT stream OutStream p-xl-delim
    "Управляющий салоном/Старший товаровед"   .

if session:set-wait-state("") then.
{ cmp/cls-exp.i stream OutStream}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date-beg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date-beg xl-inout
ON RETURN OF date-beg IN FRAME xl-inout /* С */
DO:
    APPLY "ENTRY" TO date-end IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date-end xl-inout
ON RETURN OF date-end IN FRAME xl-inout /* По */
DO:
    APPLY "CHOOSE" TO b-print IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK xl-inout


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  assign
      date-beg = date( month( TODAY ), 1, year( TODAY ) )
      date-end = TODAY
      .
  run enable_ui.

  if type-docs = {&income} then
      FRAME {&FRAME-NAME}:TITLE = "Отчет по приходу товара".
  else
      FRAME {&FRAME-NAME}:TITLE = "Отчет по расходу товара".

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI xl-inout  _DEFAULT-DISABLE
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
  HIDE FRAME xl-inout.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI xl-inout  _DEFAULT-ENABLE
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
  DISPLAY date-beg date-end
      WITH FRAME xl-inout.
  ENABLE b-quit b-print b-help date-beg date-end
      WITH FRAME xl-inout.
  {&OPEN-BROWSERS-IN-QUERY-xl-inout}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE xl-io-get xl-inout
PROCEDURE xl-io-get :
def input parameter d-t like ub.trn-doc.doc-type no-undo.

        if d-t = {&return} then
            run waitfram-show ( "Обработка возвратных накладных" ).
        if d-t = {&inventory} then
            run waitfram-show ( "Обработка инвентаризаций" ).
        assign
            counter = 0
            str-doc = str-et
            .
        FOR EACH ub.trn-doc WHERE ub.trn-doc.obj-type = v-cntxt-obj-type
                                                    AND ub.trn-doc.obj-code = v-cntxt-obj-code
                                                    AND ub.trn-doc.status_ = {&fact}
                                                    AND ub.trn-doc.doc-type = d-t
                                                    AND ub.trn-doc.discnt-type <> {&cash-desk}
                                                    AND ub.trn-doc.fact-date >= date-beg
                                                    AND ub.trn-doc.fact-date <= date-end NO-LOCK:
            FOR EACH ub.doc-line WHERE ub.doc-line.doc-code = ub.trn-doc.doc-code NO-LOCK,
                    EACH ub.clients WHERE ub.clients.obj-type = ub.doc-line.prod-type
                                                        AND ub.clients.obj-code = ub.doc-line.prod-code NO-LOCK,
                    EACH ub.gds-dtl WHERE ub.gds-dtl.prod-type = ub.doc-line.prod-type
                                                        AND ub.gds-dtl.prod-code = ub.doc-line.prod-code
                                                        AND ub.gds-dtl.artic = ub.doc-line.artic
                                                        AND ub.gds-dtl.doc-code = ub.doc-line.doc-code NO-LOCK:

                assign
                    str-ind = lookup( ub.clients.obj-name, CliName, p-xl-delim )
                    .
                CASE d-t :
                    WHEN {&inventory} THEN
                        do:
                            if ( ( type-docs = {&expense} AND ub.gds-dtl.doc-qnty >= 0 )
                                 OR ( type-docs = {&income} AND ub.gds-dtl.doc-qnty <= 0 ) ) then
                                NEXT.
                            assign
                                entry( str-ind, str-doc , p-xl-delim ) =
                                    string(absolute( ub.gds-dtl.doc-qnty ) + decimal( entry( str-ind, str-doc , p-xl-delim ) ) )
                                entry( str-ind + 1, str-doc , p-xl-delim ) =
                                    string(
                                       ( if var-report-r-b = "rubl" then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base )
                                      * absolute( ub.gds-dtl.doc-qnty ) + decimal( entry( str-ind + 1, str-doc , p-xl-delim ) ) )
                                .
                       end.
                    OTHERWISE
                        do:
                            assign
                                entry( str-ind, str-doc , p-xl-delim ) =
                                    string(ub.gds-dtl.fact-qnty + decimal( entry( str-ind, str-doc , p-xl-delim ) ) )
                                entry( str-ind + 1, str-doc , p-xl-delim ) =
                                    string( (
                                        ( if var-report-r-b = "rubl" then ub.gds-dtl.price-rubl else ub.gds-dtl.price-base )
                                        -
                                        ( if var-report-r-b = "rubl" then ub.gds-dtl.discnt-rubl else ub.gds-dtl.discnt-base )

                                      ) * ub.gds-dtl.fact-qnty + decimal( entry( str-ind + 1, str-doc , p-xl-delim ) ) )
                                .
                        end.
                END CASE.

            END.
            assign counter = counter + 1.
            if ( counter MODULO 50 ) = 0 then
                do:
                    if d-t = {&return} then
                        run waitfram-show ( string( "Обработано " + string( counter )  + " возвратных накладных" ) ).
                    if d-t = {&inventory} then
                        run waitfram-show ( string( "Обработано " + string( counter )  + " инвентаризаций" ) ).
                end.
        END.
        if d-t = {&return} then
            assign entry( 4, str-doc, p-xl-delim ) = {&return} .
        if d-t = {&inventory} then
            assign entry( 4, str-doc, p-xl-delim ) = "Инвентаризация" .
        EXPORT stream OutStream str-doc .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME