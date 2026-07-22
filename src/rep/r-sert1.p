block-level on error undo, throw.
/*

$Revision: 51db29575c5c, 1011, rls $
$Author: EShklyar $
$Date: Fri Jul 21 16:12:20 2017 +0300 $
$Workfile: r-sert1.p $
$Archive: rep/r-sert1.p $

Печатная форма Список сертификатов для накладной расширенна

Автор: Демин Алексей Сергеевич
Дата создания: 11/19/07
Author: Alexey Demin
Creation date: 11/19/07

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid              as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision: 51db29575c5c, 1011, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jul 21 16:12:20 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-sert1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-sert1.p $":U .
define variable vss-description as character no-undo init "Печатная форма Список сертификатов для накладной расширенна".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ rep/fmtcli.i   }
{ gbl/clntattr.i }
{ str/trdcalib.i }
{ rep/torgconf.i }

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
run get-report-num in p-mainmenu-handle ( output g#report-num ).
run get-quest-print in p-mainmenu-handle ( output g#quest-print ).
{ gbl/paramls.i  }
{ rep/r-sertxl.i }

do
on error undo, return error
:

def stream out-stream .

def buffer  buf_trn-doc       for trn-doc.
def buffer  buf_doc-line      for doc-line.
def buffer  buf_clients       for clients.
def buffer  buf_firm          for firm.
def buffer  buf_clients_sert  for clients.
def buffer  buf_sert          for sert.
def buffer  buf_sert-join     for sert-join.
def buffer  buf_goods         for goods.
def buffer  buf_condition-keeping   for ub.condition-keeping .

def var v-line-counter    as integer    init 0        no-undo.

def var v-org-name            as char                     no-undo.
def var v-contact-name        as char                     no-undo.

def var v-doc-code            as char                     no-undo.
def var v-doc-date            as date                     no-undo.

def var v-artic               as char                     no-undo.
def var v-goods-name          as char                     no-undo.
def var v-prod-name           as char                     no-undo.
def var v-sert-num            as char                     no-undo.
def var v-sert-org            as char                     no-undo.
def var v-sert-date1          as char                     no-undo.
def var v-sert-date2          as char                     no-undo.
def var v-srok                as char                     no-undo.
def var v-date-start          as char                     no-undo.
def var v-tech-usl            as char                     no-undo.
  
define variable v-blank-num as character no-undo .

def var v-bar-code            like bar-code.b-code        no-undo. /* бар-код товара */

def var sym1  as char init "|" no-undo.
def var sym2  as char init ":" no-undo.
def var sym3  as char init ":" no-undo.
def var sym4  as char init ":" no-undo.
def var sym5  as char init ":" no-undo.
def var sym6  as char init ":" no-undo.
def var sym7  as char init ":" no-undo.
def var sym8  as char init ":" no-undo.
def var sym9  as char init ":" no-undo.
def var sym10  as char init ":" no-undo.
def var sym11  as char init ":" no-undo.
def var sym12  as char init "|" no-undo.

def var v-single-line       as char               no-undo.
def var v-underline         as char               no-undo.
def var t-addres            as char               no-undo.
def var t-phone             as char               no-undo.
def var t-inn               as char               no-undo.
def var t-okpo              as char               no-undo.
def var v-need-page-break   as logical init no    no-undo.
def var v-host-code         as integer            no-undo.
define variable v-file-name as character no-undo .

find first buf_trn-doc no-lock  where recid(buf_trn-doc) = p-recid .
if not available buf_trn-doc then return.

    define frame f-doc
        sym1 column-label    ":"  format "X(1)" space(0)   v-line-counter   COLUMN-LABEL "N"                              format ">>>>9" space(0)
        sym2 column-label    ":"  format "X(1)" space(0)   v-artic          COLUMN-LABEL "Артикул"                        format "X(16)" space(0)
        sym3 column-label    ":"  format "X(1)" space(0)   v-goods-name     COLUMN-LABEL "Наименование продуции"          format "X(25)" space(0)
        sym4 column-label    ":"  format "X(1)" space(0)   v-blank-num      COLUMN-LABEL "№ Бланка"                       format "X(14)" space(0)
        sym5 column-label    ":"  format "X(1)" space(0)   v-sert-num       COLUMN-LABEL "Регистрационный номер"          format "X(30)" space(0)
        sym6 column-label    ":"  format "X(1)" space(1)   v-sert-date1     COLUMN-LABEL "Дата выдачи"                    format "X(12)" space(0)
        sym7 column-label    ":"  format "X(1)" space(1)   v-sert-date2     COLUMN-LABEL "Срок действия"                  format "X(12)" space(0)
        sym8 column-label    ":"  format "X(1)" space(0)   v-sert-org       COLUMN-LABEL "Орган выдавший сертификат"      format "X(30)" space(0)
        sym9 column-label    ":"  format "X(1)" space(0)   v-srok           COLUMN-LABEL "Срок годности"                  format "X(14)" space(0)
        sym10 column-label   ":"  format "X(1)" space(0)   v-date-start     COLUMN-LABEL "Дата выработки"                 format "X(12)" space(0)
        sym11 column-label   ":"  format "X(1)" space(0)   v-tech-usl       COLUMN-LABEL "Технические условия"            format "X(25)" space(0)
        sym12 column-label   ":"  format "X(1)" space(0)
    HEADER
        string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) at 5 format "X(35)"
        v-doc-code AT 70 format "X(10)" " от " v-doc-date format "99/99/99"
        "Страница " AT 120 PAGE-NUMBER( Out-Stream ) AT 130 FORMAT ">>9" SKIP
        v-single-line format "X(212)" AT 1
with width {&DOS_CW} down stream-io .

{ gbl/hostcode.i  buf_trn-doc.obj-type  buf_trn-doc.obj-code  v-host-code }

run torgconf-read in this-procedure ( input "r-sert", input v-host-code, input buf_trn-doc.obj-type, input buf_trn-doc.obj-code) no-error.
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров печати формы."   skip "Форма будет напечатана с параметрами по умолчанию."   skip return-value
    skip trim(error-status :get-message(1))   trim(error-status :get-message(2))   trim(error-status :get-message(3))
  view-as alert-box error.
end.

/*---S------ Находим фирму - хозяина документа -------------*/
find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = v-host-code no-error.
find first buf_firm no-lock  where buf_firm.firm-code = buf_clients.obj-code no-error.
/*---E------ Находим фирму - хозяина документа -------------*/

assign
    v-line-counter  = 0
    v-single-line       = fill("-", 230)
    v-underline         = fill("_", 230)
    v-doc-code          = buf_trn-doc.doc-code
    v-doc-date          = (if buf_trn-doc.status_ = {&fact} then buf_trn-doc.fact-date else buf_trn-doc.doc-date)
    v-org-name          = buf_clients.obj-name + buf_firm.post-addr2
/*                           + if buf_firm.addres1 = "" or buf_firm.addres1 = ? then "" else ", " + buf_firm.addres1*/
/*                           + if buf_firm.addres2 = "" or buf_firm.addres2 = ? then "" else " "  + buf_firm.addres2*/
/*                           + if buf_firm.phone   = "" or buf_firm.phone   = ? then "" else ", " + buf_firm.phone  */
/*    v-contact-name      = (if buf_firm.contact-psn = "" or buf_firm.contact-psn = ? then "" else ", " + buf_firm.contact-psn)*/
    .
find first ub.clients no-lock where ub.clients.obj-code = buf_firm.tobj-code and ub.clients.obj-type = {&prs} no-error .
if AVAILABLE ub.clients then do:
    v-contact-name      = ub.clients.obj-name .
end.    

{ gbl/working.i }
{ cmp/open-out.i stream Out-Stream " " {&LS_PS_A4} }
 run r-sertxl-init in this-procedure .

  assign
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
/*---S----- Шапка документа ----------*/
put stream Out-Stream skip space(10)
  "ТОВАРНО-СОПРОВОДИТЕЛЬНЫЙ ДОКУМЕНТ К НАКЛАДНОЙ N " + string(v-doc-code) + " ОТ " + string(v-doc-date) + " ("   + string(buf_trn-doc.status_) + ")"
  format "X(150)"
.
form with frame f-doc.
run r-sertxl-write-cell-data in this-procedure (
    input {&r-sertxl-h_docNum}
  , input substitute( "к накладной N &1 от &2 (&3)", v-doc-code, v-doc-date, buf_trn-doc.status_)
).
    /*---E----- Шапка документа ----------*/

    form header
        v-single-line format "X(212)" skip 
        "Продолжение - на следующей странице" at 30 skip
        with frame BottomFrame width {&DOS_CW} page-bottom no-box .
    view stream Out-Stream frame BottomFrame .

    for each buf_doc-line no-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        ,each buf_goods no-lock
        where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
        :
        { gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code no-error }.
        if error-status:error then 
        do:
            message  vss-workfile + ". Не найден бар-код товара " + buf_goods.artic  view-as alert-box error.
            undo, leave .
        end.
        assign
            v-artic      = buf_goods.artic
            v-goods-name = buf_goods.gds-name
            v-tech-usl   = buf_goods.sert
            v-date-start = string(buf_trn-doc.fact-date,"99.99.9999")
            .
        for each buf_sert-join no-lock  where buf_sert-join.b-code = v-bar-code
            ,each buf_sert no-lock
            where buf_sert.cli-type  = buf_sert-join.cli-type
            and buf_sert.cli-code  = buf_sert-join.cli-code
            and buf_sert.sert-code = buf_sert-join.sert-code
            and buf_sert.last-date > today
            :
            assign
                v-line-counter = v-line-counter + 1
                v-sert-num     = buf_sert.sert-code
                v-sert-org     = buf_sert.sert-org
                v-blank-num    = buf_sert.blank-num
                v-sert-date1   = string(buf_sert.first-date)
                v-sert-date2   = string(buf_sert.last-date)
                .
            find first buf_condition-keeping no-lock where buf_condition-keeping.cond-keep-code = buf_goods.cond-keep-code no-error .
            if AVAILABLE buf_condition-keeping then v-srok = buf_condition-keeping.cond-keep-name .
      
            if line-counter( Out-Stream ) > page-size( Out-Stream ) then  page stream out-stream.
            display stream out-stream
                sym1 v-line-counter
                sym2 v-artic
                sym3 v-goods-name
                sym4 v-blank-num
                sym5 v-sert-num
                sym6 v-sert-date1
                sym7 v-sert-date2
                sym8 v-sert-org
                sym9 v-srok
                sym10 v-date-start
                sym11 v-tech-usl
                sym12
                with frame f-doc.
            down stream out-stream 1 with frame f-doc .
            run r-sertxl-write-line-data in this-procedure (
                input v-line-counter
                , input v-artic
                , input v-goods-name
                , input v-blank-num
                , input v-sert-num
                , input v-sert-date1
                , input v-sert-date2
                , input v-sert-org
                , input v-srok
                , input v-date-start
                , input v-tech-usl
                ).
        end.
    end.

if line-counter( Out-Stream ) + 6 > page-size( Out-Stream ) then do:
  page stream out-stream.
end.

hide stream out-stream frame BottomFrame .

put stream Out-Stream
    skip    v-single-line                   format "X(212)"
    skip(2) space(5)  "Оригиналы сертификатов или их заверенная копия находятся у: " + v-org-name  format "X(150)"
    skip(2) space(5)  "Уполномоченный представитель " + v-contact-name + " " + string(v-underline, "X(20)") + " М.П."  format "X(150)"
.
run r-sertxl-write-cell-data in this-procedure ( input {&r-sertxl-f_OrgName}, input string("Оригиналы сертификатов или их заверенная копия находятся у: " + v-org-name)).
run r-sertxl-write-cell-data in this-procedure ( input {&r-sertxl-f_contact}, input string("Уполномоченный представитель " + v-contact-name + "                                           М.П.")).

output stream Out-Stream close.
run r-sertxl-close in this-procedure .

{ gbl/stopwork.i }

{ rep/q-print.i 8 }

end.