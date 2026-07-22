block-level on error undo, throw.
/*

$Revision: a8e2cf75ddf6, 2506, rls $
$Author: EShklyar $
$Date: Ср июл 08 17:09:06 2020 +0300 $
$Workfile: formA-B.p $
$Archive: rep/formA-B.p $

Печать справки А-Б

Автор: Шаланин Сергей 
Дата создания: 09/15/05
Author: Shalanin Sergey
Creation date: 09/15/05

Input:

Output:

*/


define input parameter parparentproc as handle    no-undo.
define input parameter rec_id        as recid          no-undo.


def var vss-revision    as character no-undo init "$Revision: a8e2cf75ddf6, 2506, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: formA-B.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/formA-B.p $":U .  
def var vss-description as character no-undo init "Печать формы ТОРГ-13".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-pril.i new }
{ str/trdcalib.i }
{ gbl/attr-lib.i }
{ ref/gds-attr.i }
{ gbl/paramls.i  }
{ rep/fmtcli.i   }
{ gbl/clntattr.i }
{ cmp/library.i         }
{ gbl/thbjattr.i }
{ ref/extclass.i }
{ rep/torgconf.i }


def buffer t-doc       for trn-doc.
def buffer OurObject   for clients.
def buffer buf_clients for clients.
def buffer buf_units   for units. 
define variable i                         as integer.

define variable egais-name                as char.
define variable v-qnty                    as decimal.
define variable v-par-val                 as character no-undo.
define variable v-par-type                as character no-undo.
define variable v-alc-type-name           as character no-undo.
define variable v-alc-type-code           as character no-undo.
define variable v-cntxt-host-name-obj     as character no-undo .
define variable v-cntxt-host-code-obj     as integer.
define variable v-report-name             as character no-undo.         /* Наименование отчёта */
define variable v-period                  as character no-undo.              /* Период за который формируется отчёт */
define variable v-short-obj-list          as character no-undo.      /* Перечень выбранных объектов "в одну строку" */
define variable v-choice-gds              as character no-undo. /* Список выбранных товаров. Вывод - в шапке отчёта */
define variable v-choice-obj              as character no-undo. /* Выбранный пользователем параметр "Выбор объекта" (в окне параметров). Вывод в шапке отчёта */
define variable v-full-path-RepView       as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm       as character no-undo.   /* Полный путь к файлу отчёта */
define variable v-file-name               as character no-undo .
define variable g#report-num              as integer   no-undo.
define variable v-cntxt-host-code-obj-cli as integer   no-undo.
define variable v-kpp                     as char.
define var      v-inn                     as char.
define variable var-type                  as char.
define variable v-host-egrip-num          as char      no-undo.
/*define variable v-value-character         as character no-undo .*/
/*define variable v-value-decimal           as decimal   no-undo .*/
/*define variable v-value-integer           as integer   no-undo .*/
/*define variable v-value-logical           as logical   no-undo .*/
define variable v-value-type              as character no-undo .
/*define variable v-value-date              as date      no-undo .*/
define variable v-ext-sys                 as integer   no-undo .
define variable v-egais-inn               as character no-undo .

define temp-table tt-rep1
  field obj-code            as integer
  field obj-type            as character 
  field cnt-line            as integer                                               /* 1.  "№ п/п."                                         Поступления. */
  field alc-type-name       like ub.alc-type.alc-type-name                      /* 2.  " наименование продукции"                   Поступления. */ /* По Rлассификатору алк прод. */
  field alc-qnty            as decimal
  field alc-type-code       like ub.alc-type.alc-type-code                      /* 3.  "Код вида продукции"                             Поступления. */
  field cli-obj-name        like ub.clients.obj-name                             /* 4.  "Наименование организации" (Поставщика)          Поступления. */
  field inn                 like ub.firm.inn                                              /* 5.  "ИНН" (Поставщика)                               Поступления. */
  field adress-proiz        as character 
  field adress-kontr        as character 
  field date-rozl           as date                                                  /* 6.  "Дата" (Накл. Поставщика)                        Поступления. */ /* Из атрибутов прихода внешнего, если нет, то дата дата факт документа. Дата факт расхода внеш между фирм для межфирм перемещ. */
  field doc-line-code       like ub.doc-line.doc-code                           /* -   Служебное поле(не для вывода на экран) */
  field doc-line-fact-order like ub.doc-line.fact-order                   /* -   Служебное поле. */
  field doc-code            like ub.doc-line.doc-code                                /* 7.  "Номер" (Накл. Поставщика)                       Поступления. */ /* Из атрибутов прихода внешнего, если нет, то пусто. Номер расхода внеш между фирм для межфирм перемещ. */
  field volume-piece-litres like ub.goods.ms-base /* ">>,>>9,999" */      /* 8.  "Ёмкость тары(упаковки) (л)" (Накл. Поставщика)  Поступления. */ /* Определение: Объём одной минимальной(не делимой) штуки в литрах (ub.goods.ms-base). Т.е. это скажем, бутылка. */
  field fact-qnty           like doc-line.fact-qnty /* "->>,>>>,>>9,<<<" */         /* 9.  "Количество тары(упаковки)" (Накл. Поставщика)   Поступления. */ /* Определение: Кол-во минимальной тары(не делимой) по накладной. (doc-line.fact-qnty) Т.е. кол-во скажем, бутылок. */
  field inc-total-quontity  like doc-line.fact-qnty                        /* 10. "Итого поступило за отчётный период"             Поступления. */ /* Выводим литры тары: (doc-line.fact-qnty * goods.ms-base (т.е. факт_кол-во * объём_штуки)). Выводим штуки тары: факт_кол-во */
  field itog_ii             as integer
  field exp-time            as integer
  field exp-name            as char
  field adress-kontr-firm   as char
  field code_country        as character 
  field gds-code            as integer
  field name-pol            as char
  field date-otgr           as date
  field lic-number          as char
  field lic-date-to         as date 
  field name-obj            as char
  field obj-adress          as char
  field obj-kpp             as char
  field lic-org             as char
  field lic-supp-org        as char
  field supp-date-from      as date 
  field firm-egrip          as char
  field supp-lic-date-to    as date 
  field supp-lic-number     as char 
  field date-from           as date 
  field itog_volume         as integer
  field mark-code           as char
  field kpp                 as char
  field unit-base           as char
  field inn-firm            as char
  field kpp-firm            as char
  field kpp-kontr           as char
  field kontr-firm          as char
  field inn-kontr           as char
  field ii                  as integer
  field month-otgr          as char
  field month-rozl          as char
  field name-proiz          as char
  field name-firm           as char
  field adress-firm         as char
  field name-prod           as char
  field name-kontr          as char
  field ext-doc-type        like doc-line.ext-doc-type
  field number-otgr         as char /*дата отгрузки*/
  field exp-doc-type        like doc-line.ext-doc-type
  index pi is primary alc-type-code       doc-line-code volume-piece-litres
  index fact_order    doc-line-fact-order
  .
define variable v-month-text-otgr as char.
define variable v-month-text      as char.
define variable v-country-name    as character no-undo .
    
define stream Out-Stream.
define stream OutStr-html.
define stream MyWatch-strm.
def var tdoc-prt          as logical   no-undo.
def var tdoc-code         like trn-doc.doc-code no-undo.
def var v-doc-date-string as character no-undo.
define buffer buf_parts for parts.
define variable v-alc-mark-name as char.
define buffer buf_ext-classif for ub.ext-classif.
    
    
/* ************************  Function Prototypes ********************** */


FUNCTION get-country-name RETURNS CHARACTER
  ( BUFFER buf_parts FOR parts )  FORWARD.

function fnc-DD-MM-YYYY returns character 
  (input p-dat-date as date) forward.

function fnc-fmt-dec-tc-litres returns character 
  (input p-num as decimal) forward.

function fnc-fmt-dec-tc-qnty returns character 
  (input p-num as decimal) forward.
    
    
function fnc-fmt-dec-tc-litres returns character 
  (input p-number as decimal):

  define variable result as character no-undo.
  define variable v-str1 as character no-undo.

  v-str1 = trim(replace(string(p-number,'>>>>9.99<'), ".", ",")).

  return v-str1.
        
end function.

function fnc-fmt-dec-tc-qnty returns character
  (input p-number as decimal):

  define variable result as character no-undo.
  define variable v-str1 as character no-undo.

  v-str1 = trim(replace(string(p-number,'->>>>>>>9.99<<'), ".", ",")).

  return v-str1.

end function.
    
    
for each tt-rep1 no-lock:
  delete tt-rep1.
end.
/*                                                                                        */
/*        /* Поиск нач fact-order */                                                      */
/*        run day-begin-fact-order in this-procedure ( input X-Date-Start /*v-begin-date*/*/
/*            , output v-fact-order-start                                                 */
/*            ).                                                                          */
/*        /* Поиск посл fact-order */                                                     */
/*        run factord-end-day in this-procedure ( input X-Date-End /*v-end-date*/         */
/*            , output v-fact-order-end                                                   */
/*            ).                                                                          */
/*                                                                                        */
    
    
  
run get-full-path-RepViewer(output v-full-path-RepView).   
  
run get-report-num in parParentProc(output g#report-num).

run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).

run create-file(v-file-name-rep-htm). 

v-report-name = "ФОРМА А-Б".
    
    
find first t-doc no-lock
  where recid( t-doc ) = rec_id
  .
    
{ gbl/hostname.i t-doc.obj-type t-doc.obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }

  
define variable p-ii as integer.

find OurObject where OurObject.obj-type = t-doc.obj-type and
  OurObject.obj-code = t-doc.obj-code no-lock no-error.
case OurObject.obj-type :
  when {&shop}
  then 
    do:
      find shop where shop.obj-code = OurObject.obj-code no-lock no-error .
      tdoc-prt = shop.doc-prt.
    end.
  when {&stock}
  then 
    do:
      find store where store.obj-code = OurObject.obj-code no-lock no-error.
      tdoc-prt = store.doc-prt .
    end.
end case.
   
for each parts no-lock
  where t-doc.doc-code = parts.out-code
  and t-doc.obj-code = parts.obj-code and 
  t-doc.obj-type = parts.obj-type 
  ,first goods no-lock
  where goods.prod-type    = parts.prod-type
  and goods.prod-code    = parts.prod-code
  and goods.artic        = parts.artic :
  /*           \
                                                    */
  find first buf_clients no-lock
    where buf_clients.obj-type = t-doc.obj-type
    and buf_clients.obj-code = t-doc.obj-code
    no-error .


  run fmtcli-get-client in this-procedure (
    input t-doc.obj-type ,
    input t-doc.obj-code
    ).

  /*RUN clntattr-value IN THIS-PROCEDURE*/
  /*    (INPUT parts.prod-type ,        */
  /*    INPUT parts.prod-code,          */
  /*    input {&attr-kpp},              */
  /*    OUTPUT v-kpp,                   */
  /*    OUTPUT var-type).               */

  run proc-get-country-name in this-procedure
    ( input parts.in-code,
    input parts.part-code
    , input goods.gds-code
    ,output v-country-name
    ) .
        



  RUN clntattr-value IN THIS-PROCEDURE
    (INPUT t-doc.obj-type,
    INPUT t-doc.obj-code,
    input {&attr-kpp},
    OUTPUT v-kpp,
    OUTPUT var-type).
            

  run gds-attr-value(
    ub.goods.gds-code,
    {&attr-alcohol-prod},
    output v-par-val,
    output v-par-type
    ).

  if v-par-val <> "" and
    v-par-val <> "no" then
  do: /* 1 */
    v-alc-type-name = "".
    v-alc-type-code = "".
    p-ii = p-ii + 1.
        
    /*        RUN gds-attr-value (goods.gds-code ,                                                      */
    /*            {&attr-egais-name},                                                                   */
    /*            OUTPUT v-par-val,                                                                     */
    /*            OUTPUT v-par-type                                                                     */
    /*            ).                                                                                    */
    /*        egais-name =   (IF v-par-val = ? OR v-par-val = ""  THEN   goods.gds-name ELSE v-par-val).*/
        
    find first ex-mark no-lock
      where
      ex-mark.mark-code = parts.mark-code
      no-error.
    if available ex-mark then
      v-alc-mark-name = ex-mark.mark-name.
        
        
    run text-month (input (MONTH(t-doc.fact-date)) , output v-month-text-otgr).
    run text-month (input (MONTH(parts.alc-bottling-date)) , output v-month-text).
    /*       message  string(MONTH(t-doc.fact-date))  view-as alert-box.*/
    create tt-rep1.
    assign 
      tt-rep1.ext-doc-type        = t-doc.ext-doc-type
      /*            tt-rep1.exp-name            = egais-name*/
      tt-rep1.exp-name            = goods.gds-name 
      tt-rep1.volume-piece-litres = goods.ms-base  
      tt-rep1.fact-qnty           = parts.fact-qnty
      tt-rep1.alc-qnty            = parts.fact-qnty * goods.ms-base / 10 
      tt-rep1.date-rozl           = parts.alc-bottling-date
      tt-rep1.date-otgr           = t-doc.fact-date
      tt-rep1.number-otgr         = t-doc.doc-code 
      tt-rep1.code_country        = v-country-name
      tt-rep1.mark-code           = v-alc-mark-name 
      tt-rep1.name-kontr          = t-doc.cli-name
      tt-rep1.ii                  = p-ii
      tt-rep1.unit-base           = goods.unit-base 
      tt-rep1.month-otgr          = v-month-text-otgr
      tt-rep1.month-rozl          = v-month-text 
      tt-rep1.name-obj            = v-fmtcli-name
      tt-rep1.obj-adress          = v-fmtcli-full-addres
      tt-rep1.obj-kpp             = v-kpp
      .
    /*                                                              */
    /*run fmtcli-get-client in this-procedure (                     */
    /*            input parts.prod-type,                            */
    /*            input parts.prod-code                             */
    /*            ).                                                */
    /*assign                                                        */
    /*            tt-rep1.name-proiz          =  v-fmtcli-name      */
    /*            tt-rep1.adress-proiz        = v-fmtcli-full-addres*/
    /*             tt-rep1.inn         =  v-fmtcli-inn              */
    /*            tt-rep1.kpp                 = v-fmtcli-kpp   .    */
    run torgconf-get-warrant in this-procedure(
    input t-doc.doc-code
).
  tt-rep1.name-prod = p-torgconf-t_pass-position + " " + p-torgconf-t_pass-fname .
  tt-rep1.name-pol = p-torgconf-accept-position + " " + p-torgconf-accept-fname .
             
    define var v-prod as char.
        
    empty temp-table thbjattr_thbj-attr .

    run adm/shattri.p (
      input "get":U
      ,input t-doc.obj-type
      ,input t-doc.obj-code
      ,input {&attr-egais-host}
      ,input {&attr-egais-host_egais-inn}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
    assign 
      v-egais-inn = v-value-character .  
     
                  
    run adm/shattri.p (
      input "get":U
      ,input '':U
      ,input 0
      ,input {&attr-egais-host}
      ,input {&attr-egais-host_egais-exsys}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
    assign 
      v-ext-sys = v-value-integer .  
             
             
    find first buf_ext-classif no-lock where buf_ext-classif.classif-subject = {&table_goods} 
      and buf_ext-classif.classif-name = {&extclass_goods_esys} 
      and buf_ext-classif.db-num = 0  
      and buf_ext-classif.key#_one = goods.gds-code
      and buf_ext-classif.key#_two = v-ext-sys 
      no-error.     
    if available buf_ext-classif then 
    do:
      v-prod = entry (1, buf_ext-classif.CharKey_Two, chr(4)) no-error.
            
      assign
        tt-rep1.name-proiz   = entry(4, v-prod, chr(5)) + ','
        tt-rep1.adress-proiz = entry(6, v-prod, chr(5))
        tt-rep1.inn          = entry(2, v-prod, chr(5))
        tt-rep1.kpp          = entry(3, v-prod, chr(5))   
                /*                tt-rep1.code_country = entry(5, v-prod, chr(5))*/
                no-error
        .
    end.            
    else 
    do: 
      message "Товар не задан во внешнем классификаторе  " view-as alert-box error.
      return no-apply.
    end.

           



    find first firm where  firm.firm-code = v-cntxt-host-code-obj no-lock no-error.
    if available firm then 
    do: 
      assign
        /*                tt-rep1.name-prod   = firm.head-position + " " + firm.director*/
        tt-rep1.adress-firm = firm.addres1 + " " + firm.addres2 .
            
    end.
    
    run clntattr-value in this-procedure ( input {&cmp}, input v-cntxt-host-code-obj, input {&attr-egrip-num} , output v-host-egrip-num , output v-par-type).
    
    tt-rep1.firm-egrip =  v-host-egrip-num.
    if v-egais-inn = "" then 
    do:    
      run fmtcli-get-client in this-procedure (
        input {&cmp} ,
        input v-cntxt-host-code-obj
        ).
      /*             message  v-fmtcli-addres  v-fmtcli-index        v-fmtcli-index   view-as alert-box.*/
      tt-rep1.inn-firm = v-fmtcli-inn .
    end.
    else   tt-rep1.inn-firm = v-egais-inn .
    assign
      tt-rep1.name-firm = v-fmtcli-name
      /*            tt-rep1.inn-firm = v-fmtcli-inn*/
      tt-rep1.kpp-firm  = v-fmtcli-kpp .
            
            
    RUN clntattr-value IN THIS-PROCEDURE
      (INPUT t-doc.cli-type,
      INPUT t-doc.cli-code,
      input {&attr-kpp},
      OUTPUT v-kpp,
      OUTPUT var-type).

    if t-doc.cli-type = {&cmp}  then 
    do: 
    
      find first firm where  firm.firm-code = t-doc.cli-code no-lock no-error.
        
      if available firm then 
      do: 
        assign
          /*                    tt-rep1.inn-kontr = firm.inn*/
          /*                    tt-rep1.name-pol = firm.head-position + " " + firm.director.*/
          tt-rep1.adress-kontr = firm.addres1 + " " + firm.addres2.
      end.
        
        
        
      if v-egais-inn = "" then 
      do:
        run fmtcli-get-client in this-procedure (
          input t-doc.cli-type,
          input t-doc.cli-code
          ).
        tt-rep1.inn-kontr  = v-fmtcli-inn .
      end.
      else         tt-rep1.inn-kontr  = v-egais-inn .
      assign 
        /*                tt-rep1.kontr-firm = v-fmtcli-name*/
        /*            tt-rep1.adress-kontr = v-fmtcli-full-addres*/
        tt-rep1.kpp-kontr = v-fmtcli-kpp  .
        
    end.
    else 
    do: 
      if t-doc.cli-type = {&prs}  then 
      do: 
    
        find first person where t-doc.cli-code = person.psn-code no-lock no-error.
        if available person then 
        do: 
        
          assign 
            tt-rep1.kpp-kontr    = person.kpp 
            tt-rep1.adress-kontr = person.address
            tt-rep1.inn-kontr    = person.inn
            tt-rep1.kontr-firm   = person.firm-name.
        /*        run fmtcli-get-client in this-procedure (*/
        /*                    input {&cmp} ,               */
        /*                    input person.firm-code       */
        /*                    ).                           */
        /*                                                 */ 
        /*                { gbl/hostcode.i t-doc.cli-type t-doc.cli-code v-cntxt-host-code-obj-cli }*/
        /*                                                                                          */
        /*                find first firm where  firm.firm-code = person.firm-code no-lock no-error.*/
        /*                                                                                          */
        /*                if available firm then                                                    */
        /*                do:                                                                       */
        /*                    assign                                                                */
        /*                        tt-rep1.inn-kontr = firm.inn                                      */
        /*                        tt-rep1.name-pol  = firm.head-position + " " + firm.director.     */
        /*                    tt-rep1.adress-kontr-firm = firm.addres1 + " " + firm.addres2.        */
        /*                end.                                                                      */
        
        end.

      end.
      else 
      do: 

        find first shop where shop.obj-code = t-doc.cli-code no-lock no-error.
        if available shop then 
        do: 
          /*                    tt-rep1.name-pol =    shop.director.*/
          tt-rep1.adress-kontr = shop.addres1 + " " + shop.addres2.
        end.
        run fmtcli-get-client in this-procedure (
          input {&cmp} ,
          input t-doc.host-code
          ).
            

        { gbl/hostcode.i t-doc.cli-type t-doc.cli-code v-cntxt-host-code-obj-cli }

        find first firm where  firm.firm-code = v-cntxt-host-code-obj-cli no-lock no-error.
        
        if available firm then 
        do: 
          assign
            tt-rep1.inn-kontr         = firm.inn 
            /*                        tt-rep1.name-pol  = firm.head-position + " " + firm.director.*/
            tt-rep1.adress-kontr-firm = firm.addres1 + " " + firm.addres2.
        end.
        
        
        run fmtcli-get-client in this-procedure (
          input {&cmp},
          input v-cntxt-host-code-obj-cli
          ).
        tt-rep1.kontr-firm = v-fmtcli-name  .
        run fmtcli-get-client in this-procedure (
          input t-doc.cli-type,
          input t-doc.cli-code
          ). 
        assign 
        
          /*                tt-rep1.adress-kontr = v-fmtcli-full-addres*/
          tt-rep1.kpp-kontr = v-kpp .
      /*            tt-rep1.inn-kontr  = v-fmtcli-inn .*/
                
      end.
            
    end.
            
    find first alc-sale-lic
      WHERE alc-sale-lic.cli-type = {&cmp}
      AND alc-sale-lic.cli-code =    t-doc.host-code NO-LOCK no-error.
    if available alc-sale-lic then 
    do: 
      assign
        tt-rep1.lic-org     = alc-sale-lic.who-are-got
        tt-rep1.date-from   = alc-sale-lic.date-from
        tt-rep1.lic-date-to = alc-sale-lic.date-to
        tt-rep1.lic-number  = "Серия " + alc-sale-lic.seria + " №" +  alc-sale-lic.number.
            
    end.
    find first alc-supp-lic where alc-supp-lic.cli-code = t-doc.cli-code and 
      alc-supp-lic.cli-type = t-doc.cli-type no-lock no-error.
        
        
    if available alc-supp-lic then 
    do: 
      assign 
        tt-rep1.lic-supp-org     = alc-supp-lic.who-are-got
        tt-rep1.supp-date-from   = alc-supp-lic.date-from
        tt-rep1.supp-lic-date-to = alc-supp-lic.date-to
        tt-rep1.supp-lic-number  = "Серия " + alc-supp-lic.seria + " №" +  alc-supp-lic.number.
          
    end.
  end. 
        
end.
 


output stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
    
put stream OutStr-html unformatted
  "<!DOCTYPE HTML>" skip
  ' <html>' skip
  '  <head>' skip
  '   <meta charset="utf-8">' skip
  '    <style type="text/css">' skip
  '      table ' + chr(123) + ' border-collapse: collapse; font-size:9pt; font-family:Calibri; table-layout: fixed; width: 540px; hight: 100%; padding: 0px; margin: 0px;' + chr(125) skip
  '      td ' + chr(123) ' border: 1px black solid; word-wrap:break-word; ' + chr(125) skip
  '      htm'  skip
  '      .rotate ' + chr(123) skip
  '        -webkit-transform: rotate(-90deg);' skip
  '        -moz-transform: rotate(-90deg);' skip
  '        -ms-transform: rotate(-90deg);' skip
  '        -o-transform: rotate(-90deg);' skip
  '        transform: rotate(-90deg);' skip


  '        -webkit-transform-origin: 50% 50%;' skip
  '        -moz-transform-origin: 50% 50%;' skip
  '        -ms-transform-origin: 50% 50%;' skip
  '        -o-transform-origin: 50% 50%;' skip
  '        transform-origin: 50% 50%;' skip


  '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
  '          ' + chr(125) skip
  '            th' + ' ' + chr(123) skip
  '            border: 1px black solid;' skip
  '            word-wrap: break-word;' skip
  '          ' + chr(125) skip
  '   </style>' skip
  '  </head>' skip
  .
    
    
for each tt-rep1 : 
    
if tt-rep1.ext-doc-type = {&TDEDT_Ras_Vnesh} then do:    
  put stream OutStr-html unformatted
    ' <body>' skip
    '   <table name="СПРАВКА А' + string(tt-rep1.ii) + ' " fit_to_page="true" orientation="Portrait" outline_below="false">' skip
        
    '     <thead>' skip
    '       <tr class="set_columns">' skip                 
    '         <td style="width: 20px; border: none;"></td>' skip  
    '         <td style="width: 50px; border: none;"></td>' skip   
    '         <td style="width: 100px; border: none;"></td>' skip     
    '         <td style="width: 170px; border: none;"></td>' skip    
    '         <td style="width: 100px; border: none;"></td>' skip 
    '         <td style="width: 100px; border: none;"></td>' skip  
    '         <td style="width: 100px; border: none;"></td>' skip  
    '         <td style="width: 100px; border: none;"></td>' skip  
        
    '       </tr>' skip
    .       
  do:  
        
    put stream OutStr-html unformatted
          
          
      '       <tr>' skip
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none;"></td>' skip
      '         <td colspan = "2" style="border: none; text-align: center;">ФОРМА</td>' skip
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none;"></td>' skip

      '</tr>' skip
            
            
      
          
          
      '       <tr>' skip
      '         <td style="border: none;"></td>' skip         
      '         <td colspan = "6" style="border: none; text-align: center;">справки к товарно-транспортной накладной на этиловый спирт,</td>' skip
      '         <td style="border: none;"></td>' skip

      '</tr>' skip
        
        
      '       <tr>' skip
      '         <td style="border: none;"></td>' skip    
      '         <td colspan = "6" style="border: none; text-align: center;">алкогольную и спиртосодержащую продукцию</td>' skip
      '         <td style="border: none;"></td>' skip

      '</tr>' skip
        
        
         
      '       <tr>' skip
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none; text-align: right;">№</td>' skip      
      '         <td colspan = "4" style="border: none; border-bottom: 1px solid black; text-align: center;">' +  string(tt-rep1.number-otgr)  + '</td>' skip
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none;"></td>' skip

      '</tr>' skip
        
      '       <tr>' skip
      '         <td colspan = "2" style="border: none; border-bottom: 1px solid black; text-align: center;">Раздел "А"</td>' skip
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none;"></td>' skip      
      '         <td style="border: none;"></td>' skip 
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none;"></td>' skip
      '</tr>' skip
            
        
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">1.</td>' skip          
      '         <td colspan = "3" style="border: none;">Наименование продукции </td>' skip
      '         <td colspan = "4" style="border: none; text-align: left; border-bottom: 1px solid black;">' + tt-rep1.exp-name + '</td>' skip      
         
      '</tr>' skip
            
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">2.</td>' skip          
      '         <td colspan = "3" style="border: none;">Количество продукции (дал/шт. бут.) </td>' skip
      '         <td colspan = "4" style="border: none; text-align: left; border-bottom: 1px solid black;">' +   string(fnc-fmt-dec-tc-qnty(tt-rep1.alc-qnty)) + "  /  " +  string(tt-rep1.fact-qnty)  + '</td>'  skip
         
      '</tr>' skip
            
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">3.</td>' skip          
      '         <td colspan = "3" style="border: none;">Дата розлива продукции</td>' skip
      '         <td colspan = "4" style="border: none; text-align: left; border-bottom: 1px solid black;"> "' + if STRING(tt-rep1.date-rozl) = ? then "?"   else sTRING(DAY(tt-rep1.date-rozl), "99") '" '  '               ' + if STRING(tt-rep1.date-rozl) = ? then "" else   tt-rep1.month-rozl + '               '  + STRING(YEAR(tt-rep1.date-rozl), "9999") + 'г</td>'  skip 
           
      '</tr>' skip
       
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">4.</td>' skip          
      '         <td colspan = "7" style="border: none;">Сведения о документах, свидетельствующих о подтверждении соответствия продукции</td>' skip
         
      '</tr>' skip
            
            
      '       <tr>' skip
      '         <td colspan = "8" style="border: none;">установленным обязательным требованиям, реквизиты соответствующих документов, </td>' skip 
      '</tr>' skip
         
         
      '       <tr>' skip
      '         <td  colspan = "4" style="border: none;">наименование органа, выдавшего документ,</td>' skip          
      '         <td  colspan = "4" style="border: none; text-align: right; border-bottom: 1px solid black;">' '</td>'  skip   
      '</tr>' skip
            
         
      '       <tr style="height: 20px;">' skip
      '         <td colspan = "8" style="border: none; text-align: right; border-bottom: 1px solid black;">' '</td>'  skip       
      '</tr>' skip
         
         
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">5.</td>' skip          
      '         <td colspan = "3"  style="border: none;">Производитель продукции</td>' skip
      '         <td  text_wrap="true" colspan = "4"  style="border: none; text-align: left; border-bottom: 1px solid black;">' + tt-rep1.name-proiz + ','  '</td>'  skip
      '</tr>' skip
      /*                                                                                                                                                    */
      /*            '       <tr style="height: 20px";>' skip                                                                                                */
      /*            '         <td colspan = "8" style="border: none; text-align: right; border-bottom: 1px solid black; text-align: center;">' '</td>'  skip*/
      /*            '</tr>' skip                                                                                                                            */
      /*                                                                                                                                                    */
      /*            '       <tr style="height: 20px";>' skip                                                                                                */
      /*            '         <td colspan = "8" style="border: none; text-align: right; border-bottom: 1px solid black; text-align: center;">' '</td>'  skip*/
      /*            '</tr>' skip                                                                                                                            */
         
      .
    /*         define variable text-adress1 as char.                                                            */
    /*         define variable text-adress2 as char.                                                            */
    /*         if length(tt-rep1.adress-proiz) > 30 then  text-adress1 = substring(tt-rep1.adress-proiz, 1, 30).*/
    /*/*         if length(replace(tt-rep1.adress-proiz) ) > 30 then*/                                          */
    /*                                                                                                          */
    /*                                                                                                          */
    put stream OutStr-html unformatted
         
         
      '<tr style="height: 20px;">' skip
      '         <td colspan = "8" style="border: none; text-align: left; border-bottom: 1px solid black;">'  +   substring(tt-rep1.adress-proiz, 1, 100) + '</td>'  skip       
      '</tr>' skip


      '<tr style="height: 20px;">' skip
      '         <td colspan = "8" style="border: none; text-align: left; border-bottom: 1px solid black;">' + substring(tt-rep1.adress-proiz, 101, 100) + '</td>'  skip       
      '</tr>' skip
         
         
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">6.</td>' skip    
      '         <td colspan = "3" style="border: none;">Код страны</td>' skip
                  
      '         <td colspan = "4" style="border: none; text-align: left; border-bottom: 1px solid black;">' + tt-rep1.code_country   + '</td>' skip
         
      '</tr>' skip
         
         
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">7.</td>' skip    
      '         <td colspan = "3" style="border: none;">ИНН/КПП, или УНП, или РНН/(БИК/ИНН)</td>' skip 
      '         <td colspan = "4" style="border: none; text-align: left; border-bottom: 1px solid black;"> ИНН ' + string(tt-rep1.inn) + ' / КПП ' + string(tt-rep1.kpp) +  '</td>'  skip
      '</tr>' skip
         
         
      '       <tr>' skip 
      '         <td  style="border: none; text-align: left;">8.</td>' skip    
      '         <td colspan = "5" style="border: none;">Номер лицензии, срок действия лицензии, орган, ее выдавший, </td>' skip
      '         <td colspan = "2" style="border: none; text-align: left; border-bottom: 1px solid black;"> ' + string(tt-rep1.lic-number) +  '</td>'  skip
      '</tr>' skip
          
          
          
      '       <tr style="height: 20px;">' skip
      '         <td colspan = "8" style="border: none; text-align: center; border-bottom: 1px solid black;">'  '  срок действия лицензии с ' +  fnc-DD-MM-YYYY(date(string( tt-rep1.date-from ,"99.99.9999"))) + ' по ' + fnc-DD-MM-YYYY(date(string( tt-rep1.lic-date-to ,"99.99.9999")))   + ', </td>'  skip

      '</tr>' skip
         
      '       <tr style="height: 20px;">' skip
      '         <td colspan = "8" style="border: none; text-align: center; border-bottom: 1px solid black;">выдана ' + tt-rep1.lic-org + '</td>'  skip 
             
      '</tr>' skip
         
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">9.</td>' skip          
      '         <td colspan = "3" style="border: none;">Дата отгрузки</td>' skip
      '         <td colspan = "4" style="border: none; text-align: left; border-bottom: 1px solid black;">"' +  STRING(DAY(tt-rep1.date-otgr), "99") '" ' + '               ' +   tt-rep1.month-otgr + '               '  + STRING(YEAR(tt-rep1.date-otgr), "9999") +    '  г</td>'  skip       
      '</tr>' skip
         
          
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">10.</td>' skip          
      '         <td colspan = "3" style="border: none;">Номер товарно-транспортной накладной</td>' skip
      '         <td colspan = "4" style="border: none; text-align: left; border-bottom: 1px solid black;">' +   string(tt-rep1.number-otgr) + '</td>'  skip       
      '</tr>' skip
          
          
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">11.</td>' skip          
      '         <td colspan = "7" style="border: none;">Сведения о лицах, заключивших договор(контракт) поставки продукции:</td>' skip
      '</tr>' skip
          
          
          
      '       <tr>' skip
      '         <td colspan = "4" style="border: none;">номер и дата договора(контракта) поставки продукции</td>' skip
      '         <td colspan = "4" style="border: none; text-align: left; border-bottom: 1px solid black;">' '</td>'  skip
      '</tr>' skip
            
              
      '       <tr>' skip
      '         <td colspan = "3" style="border: none;">наименование лица</td>' skip
      '         <td colspan = "5" style="border: none; text-align: left; border-bottom: 1px solid black;">' +  tt-rep1.name-firm +  '</td>'  skip
      '</tr>' skip
            
      '       <tr>' skip
      '         <td colspan = "5" style="border: none;">ОГРН, ИНН/КПП, или УНП, или РНН/(БИК/ИНН)</td>' skip
      '         <td colspan = "3" style="border: none; text-align: left; border-bottom: 1px solid black;">ОГРН '+ tt-rep1.firm-egrip  +   ',</td>'  skip
      '</tr>' skip
            
      '       <tr style="height: 20px;">' skip
      '         <td colspan = "8" style="border: none; text-align: left; border-bottom: 1px solid black;"> ИНН ' + string(tt-rep1.inn-firm) + ' / КПП ' + string(tt-rep1.kpp-firm) + '</td>'  skip 
      '</tr>' skip
            
               
      '       <tr style="height: 20px;">' skip
      '         <td colspan = "2" style="border: none;">адрес</td>' skip      
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">'+  substring(tt-rep1.adress-firm, 1, 100) + '</td>'  skip 
      '</tr>' skip
            
      '<tr style="height: 20px;">' skip
      '         <td colspan = "8" style="border: none; text-align: left; border-bottom: 1px solid black;">'  +   substring(tt-rep1.adress-firm, 101, 100) + '</td>'  skip       
      '</tr>' skip
         
      '<tr style="height: 20px;">' skip
      '         <td colspan = "8" style="border: none; text-align: left; border-bottom: 1px solid black;">' + substring(tt-rep1.adress-firm, 201, 100) + '</td>'  skip       
      '</tr>' skip
            
            
      '       <tr style="height: 20px;">' skip
      '         <td  colspan = "2" style="border: none;">контрагент</td>' skip      
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' +  tt-rep1.name-kontr +   ' </td>'  skip 
      '</tr>' skip
          
      '       <tr style="height: 20px;">' skip
      '         <td  colspan = "2" style="border: none;">адрес</td>' skip      
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' +  tt-rep1.adress-kontr + ' </td>'  skip 
      '</tr>' skip
            
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">12.</td>' skip          
      '         <td colspan = "7" style="border: none;">Номер и дата подтверждения фиксации информации в единой государственной </td>' skip
      '</tr>' skip
       
       
        
      '       <tr>' skip
      '         <td colspan = "8" style="border: none;"> автоматизированной информационной системе учета объема производства и оборота этилового</td>' skip
      '</tr>' skip
       
       
      '       <tr>' skip
      '         <td colspan = "4" style="border: none;"> спирта, алкогольной и спиртосодержащей продукции</td>' skip
      '         <td colspan = "4" style="border: none; text-align: left; border-bottom: 1px solid black;"></td>'  skip 
            
      '</tr>' skip
            
            
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">13.</td>' skip          
      '         <td colspan = "7" style="border: none;">Сведения о маркировке федеральными специальными марками (для продукции, </td>' skip
      '</tr>' skip
       
       
       
      '       <tr>' skip
      '         <td colspan = "8" style="border: none;"> произведенной на территории Российской Федерации) или акцизными марками (для продукции,</td>' skip
      '</tr>' skip
            
      '       <tr>' skip
      '         <td colspan = "8" style="border: none;"> ввезенной на таможенную территорию Таможенного союза и приобретшей статус товара</td>' skip
      '</tr>' skip
            
            
      '       <tr>' skip
      '         <td colspan = "8" style="border: none;"> Таможенного союза в соответствии с таможенным заканодательством Таможенного союза)</td>' skip
      '</tr>' skip
            
            
      '       <tr>' skip
      '         <td colspan = "8" style="border: none; text-align: center; border-bottom: 1px solid black;">'   +  string(tt-rep1.mark-code) + ' </td>' skip
      '</tr>' skip
            
            
      '       <tr>' skip
      '         <td colspan = "8" style="font-size:7pt; text-align: center;border: none;"> (указываются серии (разряды) и диапазоны номеров федеральных специальных марок или акцизных марок) </td>' skip
      '</tr>' skip
          
               
      '       <tr style="height: 30px;">' skip
      '         <td colspan = "8" style=" text-align: center;border: none;">  </td>' skip
            
      '</tr>' skip
            
            
            
            
      '       <tr>' skip
      '         <td colspan = "4" style="border: none; text-align: center; border-bottom: 1px solid black;">' + tt-rep1.name-prod + '</td>' skip
      '         <td style=" text-align: center;border: none;">  </td>' skip     
      '         <td colspan = "3" style="border: none; text-align: center; border-bottom: 1px solid black;"></td>'  skip 
      '</tr>' skip
            
            
            
      '       <tr style="height: 28px;">' skip
      '         <td colspan = "4" text_wrap="true"  style="font-size:7pt; text-align: center;border: none;"> ( ф.и.о, должность уполномоченного лица производителя (отправителя) продукции) </td>' skip
      '         <td style=" text-align: center;border: none;">  </td>' skip     
      '         <td colspan = "3" text_wrap="true"  style="font-size:7pt; text-align: center;border: none;"> (подпись) </td>' skip
           
      '</tr>' skip
          
            
            
                
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">14.</td>' skip   
      '     <td colspan = "2" style="border: none; text-align: left;">Получатель продукции</td>' skip   
                   
      '         <td colspan = "5" style="border: none; text-align: left; border-bottom: 1px solid black;">' +  tt-rep1.name-kontr +  ' </td>' skip
      '</tr>' skip
       
       
      '<tr style="height: 20px;">' skip
      '         <td colspan = "8" style="border: none; text-align: left; border-bottom: 1px solid black;">'  +   substring(tt-rep1.adress-kontr, 1, 100) + '</td>'  skip       
      '</tr>' skip
         
      '<tr style="height: 20px;">' skip
      '         <td colspan = "8" style="border: none; text-align: left; border-bottom: 1px solid black;">' + substring(tt-rep1.adress-kontr, 101) + '</td>'  skip       
      '</tr>' skip
         
       
       
      /*                                                                                                                            */
      /*            '       <tr style="height: 20px;">' skip                                                                        */
      /*                                                                                                                            */
      /*            '         <td colspan = "8" style="text-align: center;border: none; border-bottom: 1px solid black;"></td>' skip*/
      /*            '</tr>' skip                                                                                                    */
      /*                                                                                                                            */
      /*                                                                                                                            */
      /*            '       <tr style="height: 20px;">' skip                                                                        */
      /*                                                                                                                            */
      /*            '         <td colspan = "8" style="text-align: center;border: none; border-bottom: 1px solid black;"></td>' skip*/
      /*            '</tr>' skip                                                                                                    */
      /*                                                                                                                            */
            
                
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">15.</td>' skip   
      '     <td colspan = "3" style="border: none; text-align: left;">ИНН/КПП, или УНП, или РНН/(БИК/ИНН)</td>' skip          
      '         <td colspan = "4" style="border: none; text-align: left; border-bottom: 1px solid black;"> ИНН ' + string(tt-rep1.inn-kontr) + ' / КПП ' + string(tt-rep1.kpp-kontr) +  '</td>'  skip
      '</tr>' skip
            
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">16.</td>' skip   
      '     <td colspan = "2" style="border: none; text-align: left;">Код страны</td>' skip          
      '         <td colspan = "5" style="border: none; text-align: left; border-bottom: 1px solid black;">' + tt-rep1.code_country  + '</td>' skip
      '</tr>' skip
            
            
      '       <tr>' skip
      '         <td  style="border: none; text-align: left;">17.</td>' skip    
      '         <td colspan = "5" style="border: none;">Номер лицензии, срок действия лицензии, орган, ее выдавший, </td>' skip
                  
      '         <td colspan = "2" style="border: none; text-align: left; border-bottom: 1px solid black;">' + string(tt-rep1.supp-lic-number) +  '</td>'  skip
         
      '</tr>' skip
          
          
          
      '       <tr style="height: 20px;">' skip
      '         <td colspan = "8" style="border: none; text-align: center; border-bottom: 1px solid black;">'  '  срок действия лицензии с ' +  fnc-DD-MM-YYYY(date(string( tt-rep1.supp-date-from ,"99.99.9999"))) + ' по ' + fnc-DD-MM-YYYY(date(string( tt-rep1.supp-lic-date-to ,"99.99.9999")))   + ', </td>'  skip

      '</tr>' skip
         
      '       <tr style="height: 20px;">' skip
      '         <td colspan = "8" style="border: none; text-align: center; border-bottom: 1px solid black;">выдана ' + tt-rep1.lic-supp-org + '</td>'  skip 
             
      '</tr>' skip
            
            
      '       <tr style="height: 30px;">' skip    
      '         <td colspan = "4" style="border: none; text-align: center; border-bottom: 1px solid black;">' +  tt-rep1.name-pol + ' </td>' skip
      '         <td style=" text-align: center;border: none;">  </td>' skip     
      '         <td colspan = "3" style="border: none; text-align: center; border-bottom: 1px solid black;"></td>'  skip 
      '</tr>' skip
            
            
            
      '       <tr>' skip
      '         <td colspan = "4" text_wrap="true"  style="font-size:7pt; text-align: center;border: none;"> ( ф.и.о, должность уполномоченного лица покупателя (получателя) продукции) </td>' skip
      '         <td style=" text-align: center;border: none;">  </td>' skip     
      '         <td colspan = "3" text_wrap="true"  style="font-size:7pt; text-align: center;border: none;"> (подпись) </td>' skip
           
      '</tr>' skip
            
      .
            
        
  end. 
        
  do: 
    put stream OutStr-html unformatted
      '</thead>' skip
      '   </table>' skip
      '  </body>' skip.
  end.
end.

else do: 
    
  if  (i modulo (2)) = 0 then 
  do:
                
    put stream OutStr-html unformatted
      ' <body>' skip
      '   <table name="СПРАВКА Б' + string(i) + '" fit_to_page="true" orientation="Portrait" outline_below="false">' skip
      .
      
    put stream OutStr-html unformatted
        
        
      '     <thead>' skip
      '       <tr class="set_columns">' skip                 
      '         <td style="width: 20px; border: none;"></td>' skip  
      '         <td style="width: 85px; border: none;"></td>' skip   
      '         <td style="width: 66px; border: none;"></td>' skip     
      '         <td style="width: 35px; border: none;"></td>' skip    
      '         <td style="width: 70px; border: none;"></td>' skip 
      '         <td style="width: 70px; border: none;"></td>' skip  
      '         <td style="width: 50px; border: none;"></td>' skip  
      '         <td style="width: 20px; border: none;"></td>' skip  
      '         <td style="width: 20px; border: none;"></td>' skip  
      '         <td style="width: 85px; border: none;"></td>' skip   
      '         <td style="width: 66px; border: none;"></td>' skip     
      '         <td style="width: 35px; border: none;"></td>' skip    
      '         <td style="width: 70px; border: none;"></td>' skip 
      '         <td style="width: 70px; border: none;"></td>' skip  
      '         <td style="width: 50px; border: none;"></td>' skip  
      '         <td style="width: 20px; border: none;"></td>' skip  
      '       </tr>' skip
      .
  end.
  do:
    put stream OutStr-html unformatted
          
          
      '       <tr>' skip
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none;"></td>' skip
      '         <td colspan = "10" style="border: none; text-align: center;">ФОРМА</td>' skip
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none;"></td>' skip

      '</tr>' skip

      '       <tr>' skip
      '         <td style="border: none;"></td>' skip         
      '         <td colspan = "14" style="border: none; text-align: center;">справки к товарно-транспортной накладной на этиловый спирт,</td>' skip
      '         <td style="border: none;"></td>' skip

      '</tr>' skip
        
        
      '       <tr>' skip
      '         <td style="border: none;"></td>' skip    
      '         <td colspan = "14" style="border: none; text-align: center;">алкогольную и спиртосодержащую продукцию</td>' skip
      '         <td style="border: none;"></td>' skip

      '</tr>' skip
        
        
         
      '       <tr>' skip
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none; text-align: right;">№</td>' skip      
      '         <td colspan = "12" style="border: none; border-bottom: 1px solid black; text-align: center;">' +  string(tt-rep1.number-otgr)  + '</td>' skip
      '         <td style="border: none;"></td>' skip
      '         <td style="border: none;"></td>' skip

      '</tr>' skip
          
            
      '       <tr style="height: 20px;">' skip
      '         <td colspan = "2" style="border: none; border-bottom: 1px solid black; text-align: center;">Раздел "Б"</td>' skip
      '         <td colspan = "14" style="border: none;"></td>' skip
      '</tr>' skip
              
             
      '       <tr style="height: 5px;">' skip
      /*            '         <td colspan = "2" style="border: none; border-bottom: 1px solid black; text-align: center;">Раздел "Б"</td>' skip*/
      '         <td colspan = "16" style="border: none;"></td>' skip
      '</tr>' skip
              
        
        
        
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black; border-top: 1px solid black;">1.</td>' skip          
      '         <td colspan = "6" style="border: none;border-top: 1px solid black;">Наименование продавца </td>' skip
      '         <td  style="border: none; text-align: left;border-top: 1px solid black;border-right: 1px solid black;"></td>' skip                        
      '         <td  style="border-left: 1px solid black; border: none; text-align: left;border-top: 1px solid black;">1.</td>' skip          
      '         <td colspan = "6" style="border: none;border-top: 1px solid black;">Наименование покупателя(получателя)</td>' skip
      '         <td  style="border: none; text-align: left;border-top: 1px solid black;border-right: 1px solid black;"></td>' skip          
      '</tr>' skip
        
        
        
        
              
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' + tt-rep1.name-obj ', ' +  tt-rep1.name-firm + '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' + tt-rep1.name-kontr + ',  ' + tt-rep1.kontr-firm +     '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
        
      '</tr>' skip
        
        
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      '         <td colspan = "6" style="border: none;text-align: left; border-bottom: 1px solid black;"></td>' skip
      '         <td  style="border: none; text-align: left; border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip                      
      '         <td colspan = "6" style="border: none;text-align: left; border-bottom: 1px solid black;"></td>' skip
      '         <td  style="border: none; text-align: left; border-right: 1px solid black;"></td>' skip          
      '</tr>' skip
        
        
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;">2.</td>' skip          
      '         <td colspan = "6" style="border: none;">Местонахождение</td>' skip
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left;border-left: 1px solid black;">2.</td>' skip          
      '         <td colspan = "6" style="border: none;">Местонахождение</td>' skip
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
                 
         
      '</tr>' skip
       

      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip              
      '         <td colspan = "6" style="border: none;text-align: left; border-bottom: 1px solid black;">' +   substring(tt-rep1.obj-adress, 1, 50) + '</td>' skip
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip              
      '         <td colspan = "6" style="border: none;text-align: left; border-bottom: 1px solid black;">' + substring(tt-rep1.adress-kontr, 1, 50) + '</td>' skip
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
                 
      '</tr>' skip
       
             
            
            
             
             
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
            
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' +  substring(tt-rep1.obj-adress, 51, 50) + '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' + substring(tt-rep1.adress-kontr, 51, 50) + '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
        
      '</tr>' skip
      /*                                                                                                                                                                                */
      /*          '       <tr style="height: 20px;">' skip                                                                                                                              */
      /*            '         <td colspan = "2" style="border: none;">адрес</td>' skip                                                                                                  */
      /*            '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;"> '+  substring(tt-rep1.adress-proiz, 1, 100) + '</td>'  skip    */
      /*            '</tr>' skip                                                                                                                                                        */
      /*                                                                                                                                                                                */
      /*                 '<tr style="height: 20px;">' skip                                                                                                                              */
      /*            '         <td colspan = "8" style="border: none; text-align: left; border-bottom: 1px solid black;">'  +   substring(tt-rep1.adress-proiz, 100, 220) + '</td>'  skip*/
      /*            '</tr>' skip                                                                                                                                                         */
      /*                                                                                                                                                                                */
      /*               '<tr style="height: 20px;">' skip                                                                                                                                */
      /*            '         <td colspan = "8" style="border: none; text-align: left; border-bottom: 1px solid black;">' + substring(tt-rep1.adress-proiz, 220) + '</td>'  skip        */
      /*            '</tr>' skip                                                                                                                                                        */
         
               
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
            
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' + substring(tt-rep1.obj-adress, 101, 70) +    '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' + substring(tt-rep1.adress-kontr, 101, 70) + '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
        
      '</tr>' skip
        
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
            
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' + substring(tt-rep1.adress-firm, 1, 50) + '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' + substring(tt-rep1.adress-kontr-firm, 1, 50) + '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
        
      '</tr>' skip
        
         
          
        
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
            
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' + substring(tt-rep1.adress-firm,  101, 48) + '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' + substring(tt-rep1.adress-kontr-firm, 101, 48) + '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
        
      '</tr>' skip
        
         
         
         
         
         
         
         
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left;  border-left: 1px solid black;">3.</td>' skip    
      '         <td colspan = "6" style="border: none;">Номер лицензии, срок действия лицензии, орган,</td>' skip
      '         <td  style="border: none; text-align: left;  border-right: 1px solid black;"></td>' skip    
      '         <td  style="border: none; text-align: left;  border-left: 1px solid black;">3.</td>' skip    
      '         <td colspan = "6" style="border: none;">Номер лицензии, срок действия лицензии, орган,</td>' skip
      '         <td  style="border: none; text-align: left;  border-right: 1px solid black;"></td>' skip    
      '</tr>' skip
          
          
          
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left;  border-left: 1px solid black;"></td>' skip    
            
      '         <td colspan = "2" style="border: none; text-align: left;">ее выдавший: </td>' skip             
      '         <td colspan = "4" style="border: none; text-align: left; border-bottom: 1px solid black;">' + string(tt-rep1.lic-number) +  ' </td>'  skip
      '         <td  style="border: none; text-align: left;  border-right: 1px solid black;"></td>' skip    
      '         <td  style="border: none; text-align: left;  border-left: 1px solid black;"></td>' skip    
            
      '         <td colspan = "2" style="border: none; text-align: left;">ее выдавший: </td>' skip                       
      '         <td colspan = "4" style="border: none; text-align: left; border-bottom: 1px solid black;">' + string(tt-rep1.supp-lic-number) +  ' </td>'  skip
      '         <td  style="border: none; text-align: left;  border-right: 1px solid black;"></td>' skip    
      '</tr>' skip
          
          
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip               
      '         <td colspan = "6" style="border: none; text-align: center; border-bottom: 1px solid black;">'  + '  срок действия лицензии с ' +  fnc-DD-MM-YYYY(date(string( tt-rep1.date-from ,"99.99.9999"))) + ' по ' + fnc-DD-MM-YYYY(date(string( tt-rep1.lic-date-to ,"99.99.9999"))) + ', </td>'  skip
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip           
      '         <td colspan = "6" style="border: none; text-align: center; border-bottom: 1px solid black;">' + '  срок действия лицензии с ' +   if string(tt-rep1.supp-date-from) <> ? then fnc-DD-MM-YYYY(date(string( tt-rep1.supp-date-from ,"99.99.9999"))) else "" + ' по ' + if string(tt-rep1.supp-lic-date-to) <> ? then fnc-DD-MM-YYYY(date(string( tt-rep1.supp-lic-date-to ,"99.99.9999"))) else "" + ', </td>'  skip
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip              
      '</tr>' skip
        
        
         
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
            
      '         <td colspan = "6" style="border: none; text-align: center; border-bottom: 1px solid black;">выдана ' + tt-rep1.lic-org + '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      
      '         <td colspan = "6" style="border: none; text-align: center; border-bottom: 1px solid black;">выдана ' + tt-rep1.lic-supp-org + '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
        
      '</tr>' skip
            
            
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;">4.</td>' skip    
      '         <td colspan = "3" style="border: none;">Код страны</td>' skip                 
      '         <td colspan = "3" style="border: none; text-align: left; border-bottom: 1px solid black;">' + tt-rep1.code_country   + '</td>' skip
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip       
      '         <td  style="border: none; text-align: left;border-left: 1px solid black;">4.</td>' skip    
      '         <td colspan = "3" style="border: none;">Код страны</td>' skip                 
      '         <td colspan = "3" style="border: none; text-align: left; border-bottom: 1px solid black;">' + tt-rep1.code_country   + '</td>' skip
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip              
     
      '</tr>' skip
            
            
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;">5.</td>' skip    
      '         <td colspan = "6" style="border: none;">ИНН/КПП, или УНП, или РНН/(БИК/ИНН)</td>' skip
                  
      /*        '         <td colspan = "3" style="border: none; text-align: left; border-bottom: 1px solid black;"> </td>'  skip*/
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip 
      '         <td  style="border: none; text-align: left;border-left: 1px solid black;">5.</td>' skip    
      '         <td colspan = "6" style="border: none;">ИНН/КПП, или УНП, или РНН/(БИК/ИНН)</td>' skip
                  
      /*        '         <td colspan = "3" style="border: none; text-align: left; border-bottom: 1px solid black;"></td>'  skip*/
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip 
      '</tr>' skip
      .
    put stream OutStr-html unformatted
          
          
                
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
            
      '         <td colspan = "6" style="border: none; text-align: center; border-bottom: 1px solid black;"> ИНН ' + string(tt-rep1.inn-firm) + ' / КПП ' + string(tt-rep1.obj-kpp) +   '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      
      '         <td colspan = "6" style="border: none; text-align: center; border-bottom: 1px solid black;"> ИНН ' + string(tt-rep1.inn-kontr) + ' / КПП ' + string(tt-rep1.kpp-kontr) +  '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
        
      '</tr>' skip
          
            
            
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;">6.</td>' skip          
      '         <td colspan = "6" style="border: none;">Наименование продукции </td>' skip
      /*            '         <td colspan = "3" style="border: none; text-align: left; border-bottom: 1px solid black;"></td>' skip*/
      '      <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip  
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;">6.</td>' skip          
      '         <td colspan = "6" style="border: none;">Наименование продукции </td>' skip
      /*            '         <td colspan = "3" style="border: none; text-align: left; border-bottom: 1px solid black;"></td>' skip*/
      '      <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip 
      '</tr>' skip
            
            
                        
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
            
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' + tt-rep1.exp-name + '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' + tt-rep1.exp-name + '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
        
      '</tr>' skip
            
            
            
            
            
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;">7.</td>' skip          
      '         <td colspan = "6" style="border: none;">Количество продукции (дал/шт. бут.) </td>' skip
      /*            '         <td colspan = "3" style="border: none; text-align: left; border-bottom: 1px solid black;">' +  if tt-rep1.alc-qnty = 0 and tt-rep1.alc-qnty = 0 then ""  else string(fnc-fmt-dec-tc-qnty(tt-rep1.alc-qnty))  + '</td>'  skip*/
      '      <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip 
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;">7.</td>' skip          
      '         <td colspan = "6" style="border: none;">Количество продукции (дал/шт. бут.) </td>' skip
      /*            '         <td colspan = "3" style="border: none; text-align: left; border-bottom: 1px solid black;">' +  if tt-rep1.alc-qnty = 0 and tt-rep1.alc-qnty = 0 then ""  else string(fnc-fmt-dec-tc-qnty(tt-rep1.alc-qnty))  + '</td>'  skip*/
      '      <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip 
      '</tr>' skip
                    
                    
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
            
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' +   string(fnc-fmt-dec-tc-qnty(tt-rep1.alc-qnty))  + "  /  " + string(tt-rep1.fact-qnty) +  '</td>'  skip
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' +   string(fnc-fmt-dec-tc-qnty(tt-rep1.alc-qnty))  + "  /  " + string(tt-rep1.fact-qnty) +  '</td>'  skip
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
        
      '</tr>' skip
                    
                    
                    
                    
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;">8.</td>' skip          
      '         <td colspan = "6" style="border: none;">Номер товарно-транспортной накладной</td>' skip
      /*            '         <td colspan = "3" style="border: none; text-align: left; border-bottom: 1px solid black;">' +   string(tt-rep1.number-otgr) + '</td>'  skip*/
      '      <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip 
      '         <td  style="border: none; text-align: left;  border-left: 1px solid black;">8.</td>' skip          
      '         <td colspan = "6" style="border: none;">Номер товарно-транспортной накладной</td>' skip
      /*            '         <td colspan = "3" style="border: none; text-align: left; border-bottom: 1px solid black;">' +   string(tt-rep1.number-otgr) + '</td>'  skip*/
      '      <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip 
      '</tr>' skip
            
            

      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
            
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' +   string(tt-rep1.number-otgr) + '</td>'  skip       
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      
      '         <td colspan = "6" style="border: none; text-align: left; border-bottom: 1px solid black;">' +   string(tt-rep1.number-otgr) + '</td>'  skip       
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
        
      '</tr>' skip

            
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;">9.</td>' skip          
      '         <td colspan = "3" style="border: none;">Дата отгрузки</td>' skip
      '         <td colspan = "3" style="border: none; text-align: left; border-bottom: 1px solid black;"> "'  + STRING(DAY(tt-rep1.date-otgr), "99") '" ' + '           ' +   tt-rep1.month-otgr + '           '  + STRING(YEAR(tt-rep1.date-otgr), "9999") +    '  г</td>'  skip                   
      '      <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip 
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;">9.</td>' skip          
      '         <td colspan = "3" style="border: none;">Дата отгрузки</td>' skip
      '         <td colspan = "3" style="border: none; text-align: left; border-bottom: 1px solid black;"> "'  + STRING(DAY(tt-rep1.date-otgr), "99") '" ' + '           ' +   tt-rep1.month-otgr + '           '  + STRING(YEAR(tt-rep1.date-otgr), "9999") +    '  г</td>'  skip                   
      '      <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip 
      '</tr>' skip
            
            
            
            
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;">10.</td>' skip          
      '         <td colspan = "6" style="border: none;">Фамилия, имя, отчество, должность уполномоченного</td>' skip
      '      <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip 
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;">10.</td>' skip          
      '         <td colspan = "6" style="border: none;">Фамилия, имя, отчество, должность уполномоченного</td>' skip
      '      <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip 
      '</tr>' skip
            
            
            
      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      '         <td colspan = "6" style="border: none;">лица продавца</td>' skip
      '      <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip 
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      '         <td colspan = "6" style="border: none;">лица покупателя (получателя) </td>' skip
      '      <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip 
      '</tr>' skip
            

      '       <tr style="height: 20px;">' skip
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
            
      '         <td colspan = "6" style="border: none; text-align: center; border-bottom: 1px solid black;">' + tt-rep1.name-prod   + '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      
      '         <td colspan = "6" style="border: none; text-align: center; border-bottom: 1px solid black;">' +  tt-rep1.name-pol   + '</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
        
      '</tr>' skip
        
        
      '       <tr style="height: 22px;">' skip
      '         <td  colspan = "4" style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
            
      '         <td colspan = "3" style="border: none; text-align: center; border-bottom: 1px solid black;"></td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  colspan = "4" style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      
      '         <td colspan = "3" style="border: none; text-align: center; border-bottom: 1px solid black;"></td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
        
      '</tr>' skip
        
        
      '       <tr style="height: 15px;">' skip
      '         <td  colspan = "4" style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
            
      '         <td colspan = "3" style="font-size:7pt;border: none; text-align: center;">(подпись)</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
      '         <td  colspan = "4" style="border: none; text-align: left; border-left: 1px solid black;"></td>' skip          
      
      '         <td colspan = "3" style="font-size:7pt; border: none; text-align: center;">(подпись)</td>'  skip 
      '         <td  style="border: none; text-align: left;border-right: 1px solid black;"></td>' skip          
        
      '</tr>' skip
        

      '       <tr style="height: 5px;">' skip

      '         <td colspan = "8" style="border: none; text-align: center; border-bottom: 1px solid black;border-right: 1px solid black;border-left: 1px solid black;"></td>'  skip
      '         <td colspan = "8" style="border: none; text-align: center; border-bottom: 1px solid black;border-right: 1px solid black;border-left: 1px solid black;"></td>'  skip

      '</tr>' skip
      .  
    i = i + 1.  
  end.    
  if  (i modulo (2)) = 0 then 
  do: 
    do:   
      put stream OutStr-html unformatted  
        '</thead>' skip
        '</table>' skip
        '</body>' skip
        .
    end.
  end.
  
end.     
end.        
do: 
  put stream OutStr-html unformatted  
    ' </html>' skip
    . /* Точка для закрытия Put */
  output stream OutStr-html close.
       
end.    
        
        

run search-full-path-Report(input v-file-name-rep-htm).

run Report-Viewer(input v-full-path-RepView, input v-file-name-rep-htm).
        
        
        
        
    
procedure get-full-path-RepViewer:  /* Получение полного пути к исполняемому файлу RV.exe (output Полный_путь_имя_файла_RV.exe) */
  /* Получение полного пути к exe-файлу просмотровщика отчётов */
  define output parameter p-fill-path-RepView as character no-undo.

  if search("exe\ReportViewer\reportviewer.exe") <> ? then
  do:
    p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
  end.
  else
  do:
    message "Не найдена программа просмотра отчёта!" view-as alert-box error.
  end.
end procedure.


procedure search-full-path-Report:  /* Только проверка, есть файл отчёта HTML или нет(тогда вывод сбщ-ош) */
  /* Поиск файла */
  define input parameter p-file-name as character no-undo.

  if search(p-file-name) = ? then
  do:
    message "Не найден файл отчёта: " p-file-name view-as alert-box error.
  end.
  else
  do:
    p-file-name = search(p-file-name).
  end.

end procedure.


procedure create-file:              /* СоздЛюбогоФайлаНаДиске(input полный_путь_с_именем) */
  /* Создание пустого файла (во входном параметре: полный путь и имя файла) */
  define input parameter p-file-name as character no-undo.
  output to value(string(p-file-name)).
  output close.

end procedure.


procedure define-full-path-Report:  /* Получение полного пути к отчёту html (input №Отчёта, output Полный_путь_имя_файла_отчHTML) */
  /* Получение полного пути к отчёту html */
  define input parameter p-rep-num as integer no-undo.
  define output parameter p-file-name-rep-htm as character no-undo.

  p-file-name-rep-htm = session:temp-directory  + string(p-rep-num) + ".html".

end procedure.


procedure Report-Viewer:            /* Запуск на выполнение RV (input Полный_путь_имя_файла_RV, input Полный_путь_имя_файла_отчHTML) */
  /* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
  define input parameter p-full-path-RepView as character no-undo.
  define input parameter p-file-name-rep-htm as character no-undo.

  os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).

end procedure.





procedure text-month:
  define input parameter month-number as integer.
  define output parameter p-month-text as char.
    
  if month-number = 1 then p-month-text = "января".
  if month-number = 2 then p-month-text = "февраля".
  if month-number = 3 then p-month-text = "марта".
  if month-number = 4 then p-month-text = "апреля".
  if month-number = 5 then p-month-text = "мая".
  if month-number = 6 then p-month-text = "июня".
  if month-number = 7 then p-month-text = "июля".
  if month-number = 8 then p-month-text = "августа".
  if month-number = 9 then p-month-text = "сентября".
  if month-number = 10 then p-month-text = "октября".
  if month-number = 11 then p-month-text = "ноября".
  if month-number = 12 then p-month-text = "декабря".
 
    
end.

PROCEDURE proc-get-country-name :
  /* -----------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  -------------------------------------------------------------*/
  define input parameter p-in-code as char.
  define input parameter p-part-code  as char.
  define input parameter p-gds-code like goods.gds-code.
  define output parameter p-country-name as character no-undo .

  define buffer buf_parts-attr for ub.parts-attr .
  define buffer buf_country    for ub.country .

   
  find first buf_parts-attr no-lock
    where buf_parts-attr.in-code   = p-in-code
    and buf_parts-attr.gds-code  = p-gds-code
    and buf_parts-attr.part-code = p-part-code
    no-error .
  if available buf_parts-attr
    then 
  do:
    find first buf_country no-lock
      where buf_country.num-code = buf_parts-attr.country-code
      no-error .
    if not available buf_country
      then 
    do:
      assign
        p-country-name = "XX Неизвестна"
        .
    end.
    else 
    do:
      assign
        p-country-name = buf_country.alpha1 
        .
    end.
  end.
END PROCEDURE.

function fnc-DD-MM-YYYY returns character 
  (input p-dat-date as date):
  /* Преобразование даты в формат: "01.01.2014" */

  define variable result     as character no-undo.
  define variable p-str-date as character no-undo.

  p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").

  return p-str-date.

end function.