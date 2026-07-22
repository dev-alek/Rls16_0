block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-sert.p $
$Archive: rep/r-sert.p $

Печатная форма Список сертификатов для накладной

Автор: Демин Алексей Сергеевич
Дата создания: 09/15/05
Author: Alexey Demin
Creation date: 09/15/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid              as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-sert.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-sert.p $":U .
define variable vss-description as character no-undo init "Печатная форма Список сертификатов для накладной".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ rep/fmtcli.i   }
{ gbl/clntattr.i }
{ str/trdcalib.i }
{ rep/torgconf.i }

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
def buffer  buf_parts         for parts.

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
def var v-sert-date           as char                     no-undo.

def var v-bar-code            like bar-code.b-code        no-undo. /* бар-код товара */

def var sym1  as char init "|" no-undo.
def var sym2  as char init ":" no-undo.
def var sym3  as char init ":" no-undo.
def var sym4  as char init ":" no-undo.
def var sym5  as char init ":" no-undo.
def var sym6  as char init ":" no-undo.
def var sym7  as char init ":" no-undo.
def var sym8  as char init "|" no-undo.

def var v-single-line       as char               no-undo.
def var v-underline         as char               no-undo.
def var t-addres            as char               no-undo.
def var t-phone             as char               no-undo.
def var t-inn               as char               no-undo.
def var t-okpo              as char               no-undo.
def var v-need-page-break   as logical init no    no-undo.
def var v-host-code         as integer            no-undo.
def var v-curr-code         as integer            no-undo.

    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.


/*---S----- Таблицы --------------------------------*/
&scop P-S 5
&scop P-X 193        /*длина линии*/
&scop P-X0 191       /*длина внутренней линии = длина линии - 2*/
&scop P-C2-S    {&P-S} + 7
&scop P-C3-S    {&P-S} + 24
&scop P-C4-S    {&P-S} + 63
&scop P-C5-S    {&P-S} + 103
&scop P-C6-S    {&P-S} + 143
&scop P-C7-S    {&P-S} + 179
&scop P-E       {&P-S} + 193

/*---E----- Таблицы --------------------------------*/

run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first buf_trn-doc no-lock
     where recid(buf_trn-doc) = p-recid
.
if not available buf_trn-doc
then do:
    return.
end.

define frame f-doc
        space({&P-S})
        sym1  format "X(1)" space(0)   v-line-counter       format ">>>>9" space(0)
        sym2  format "X(1)" space(0)   v-artic              format "X(16)" space(0)
        sym3  format "X(1)" space(0)   v-goods-name         format "X(38)" space(0)
        sym4  format "X(1)" space(0)   v-prod-name          format "X(39)" space(0)
        sym5  format "X(1)" space(0)   v-sert-org           format "X(39)" space(0)
        sym6  format "X(1)" space(0)   v-sert-num           format "X(35)" space(0)
        sym7  format "X(1)" space(1)   v-sert-date          format "X(12)" space(0)
        sym8  format "X(1)" space(0)
with width {&DOS_CW} down stream-io no-labels.

{ gbl/hostcode.i
    buf_trn-doc.obj-type
    buf_trn-doc.obj-code
    v-host-code
}
run torgconf-read in this-procedure (
      input "r-sert"
    , input v-host-code
    , input buf_trn-doc.obj-type
    , input buf_trn-doc.obj-code
) no-error.
if error-status :error
then do:
    message
    vss-workfile vss-revision vss-description
    skip "Ошибка чтения параметров печати формы."
    skip "Форма будет напечатана с параметрами по умолчанию."
    skip return-value
    skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
    view-as alert-box error.
end.

/*---S------ Находим фирму - хозяина документа -------------*/
find first buf_clients no-lock
     where buf_clients.obj-type = {&cmp}
       and buf_clients.obj-code = v-host-code
no-error.
find first buf_firm no-lock
     where buf_firm.firm-code = buf_clients.obj-code
no-error.
/*---E------ Находим фирму - хозяина документа -------------*/

assign
    v-line-counter  = 0
    v-single-line       = fill("-", 230)
    v-underline         = fill("_", 230)
    v-doc-code          = buf_trn-doc.doc-code
    v-doc-date          = (if buf_trn-doc.status_ = {&fact} then buf_trn-doc.fact-date else buf_trn-doc.doc-date)
    v-org-name          = buf_clients.obj-name
                           + if buf_firm.addres1 = "" or buf_firm.addres1 = ? then "" else ", " + buf_firm.addres1
                           + if buf_firm.addres2 = "" or buf_firm.addres2 = ? then "" else " "  + buf_firm.addres2
                           + if buf_firm.phone   = "" or buf_firm.phone   = ? then "" else ", " + buf_firm.phone
    v-contact-name      = (if buf_firm.contact-psn = "" or buf_firm.contact-psn = ? then "" else ", " + buf_firm.contact-psn)
.

{ gbl/working.i }
/*if session:set-wait-state("compiler") then.*/
{ cmp/open-out.i stream Out-Stream " " {&LS_PS_A4} }

/*---S----- Шапка документа ----------*/
put stream Out-Stream
  skip space({&P-S})
    "Страница 1" at right-field( {&P-E}, 10)
  skip space({&P-S})
    "ТОВАРНО-СОПРОВОДИТЕЛЬНЫЙ ДОКУМЕНТ К НАКЛАДНОЙ N " + string(v-doc-code)
                                              + " ОТ " + string(v-doc-date)
                                              + " ("   + string(buf_trn-doc.status_) + ")"
                   format "X({&P-X0})"
.

form with frame f-doc.
down stream Out-Stream 1 with frame f-doc no-labels.

put stream Out-Stream
    skip space({&P-S})
      v-single-line  format "X({&P-X})"
.

run write-header ( input v-single-line
                          ,input no
                 ).
/*---E----- Шапка документа ----------*/

form header
    v-single-line format "X({&P-X})" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame BottomFrame width {&DOS_CW} page-bottom no-labels no-box .
view stream Out-Stream frame BottomFrame .
for each buf_doc-line no-lock
   where buf_doc-line.doc-code = buf_trn-doc.doc-code
   ,each buf_goods no-lock
   where buf_goods.artic     = buf_doc-line.artic
     and buf_goods.prod-type = buf_doc-line.prod-type
     and buf_goods.prod-code = buf_doc-line.prod-code
:
    { gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code no-error}.
    if error-status:error then
    do:
        message
          vss-workfile + ". Не найден бар-код товара " + buf_goods.artic
        view-as alert-box error.
            undo, leave .
    end.

    for  each buf_parts no-lock
        where buf_parts.prod-type  = buf_doc-line.prod-type
          and buf_parts.prod-code  = buf_doc-line.prod-code
          and buf_parts.artic      = buf_doc-line.artic
          and buf_parts.out-code   = buf_doc-line.doc-code
        ,each buf_sert-join no-lock
        where buf_sert-join.cli-type   = buf_parts.supp-type
          and buf_sert-join.cli-code   = buf_parts.supp-code
          and buf_sert-join.b-code     = v-bar-code
        ,each buf_sert no-lock
        where buf_sert.cli-type  = buf_sert-join.cli-type
          and buf_sert.cli-code  = buf_sert-join.cli-code
          and buf_sert.sert-code = buf_sert-join.sert-code
    :
        if    v-doc-date <= buf_sert.last-date
          and v-doc-date >= buf_sert.first-date
        then do:
            find first buf_clients_sert
                  where buf_clients_sert.obj-type = buf_parts.supp-type
                    and buf_clients_sert.obj-code = buf_parts.supp-code
            .
            assign
                v-line-counter = v-line-counter + 1
                v-artic        = buf_goods.artic
                v-goods-name   = buf_goods.gds-name
                v-prod-name    = buf_clients_sert.obj-name
                v-sert-num     = buf_sert.sert-code
                v-sert-org     = buf_sert.PS
                v-sert-date    = "до" + fill(" ",1) + string(buf_sert.last-date)
            .
            run write-line.
        end.

    end.
end.

if line-counter( Out-Stream ) + 6 > page-size( Out-Stream )
then do:
    page stream out-stream.
end.

hide stream out-stream frame BottomFrame .

put stream Out-Stream
    skip space({&P-S})
      v-single-line                                         format "X({&P-X})"
    skip(2) space({&P-S})
      "Оригиналы сертификатов или их заверенная копия находятся у:" + fill(" ", 2) + v-org-name
                                                            format "X({&P-X0})"
    skip(2) space({&P-S})
    "Уполномоченный представитель" + fill(" ", 1) + buf_clients.obj-name
                + v-contact-name
                + fill(" ", 1) + string(v-underline, "X(20)") + fill(" ", 1) + "М.П."
                                                            format "X({&P-X0})"
.

output stream Out-Stream close.

{ gbl/stopwork.i }

{ rep/q-print.i 8}

end.

/*============================================================================*/
/*                    Шапка с цифрами для каждой новой страницы               */
/*============================================================================*/
procedure write-header :
do
on error undo, return error
:
def input parameter p-single-line as char    no-undo.
def input parameter p-need-line   as logical no-undo.

    if p-need-line = yes
    then put stream out-stream
        skip
          string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)" at right-field( {&P-E}, 13)
        skip space({&P-S})
          p-single-line format "X({&P-X})"
    .
    put stream out-stream
        skip space({&P-S})
          "|"
          "N"                                   at center-field({&P-S}, {&P-C2-S}, 1)
          ":"                                   at {&P-C2-S}
          "Артикул"                    at center-field({&P-C2-S}, {&P-C3-S}, 7)
          ":"                                   at {&P-C3-S}
          "Наименование товара"        at center-field({&P-C3-S}, {&P-C4-S}, 19)
          ":"                                   at {&P-C4-S}
          "Изготовитель-Поставщик"     at center-field({&P-C4-S}, {&P-C5-S}, 22)
          ":"                                   at {&P-C5-S}
          "Орган по сертификации"      at center-field({&P-C5-S}, {&P-C6-S}, 21)
          ":"                                   at {&P-C6-S}
          "Сертификат"                 at center-field({&P-C6-S}, {&P-C7-S}, 10)
          ":"                                   at {&P-C7-S}
          "Срок действия"              at center-field({&P-C7-S}, {&P-E}, 13)
          "|"                                   at {&P-E}
        skip space({&P-S})
          "|"
          p-single-line  format "X({&P-X0})"
          "|"                                   at {&P-E}
    .
end.
end procedure. /* write-header */

/*============================================================================*/
/*                    Линия таблицы документа, переход страницы               */
/*============================================================================*/
procedure write-line :
do
on error undo, return error
:
    if line-counter( Out-Stream ) > page-size( Out-Stream )
    then do:
        page stream out-stream.
        run write-header ( input v-single-line
                                  ,input yes
                          ).
    end.
    display stream out-stream
        sym1 v-line-counter
        sym2 v-artic
        sym3 v-goods-name
        sym4 v-prod-name
        sym5 v-sert-num
        sym6 v-sert-org
        sym7 v-sert-date
        sym8
    with frame f-doc.
    down stream out-stream 1 with frame f-doc .
end.
end procedure. /* write-line */



/*============================================================================*/
/*                    Итоги для каждой страницы и общие                       */
/*============================================================================*/
procedure write-itog :
do
on error undo, return error
:
    def input parameter p-type          as char no-undo.     /*"Итого" или "Всего"*/
    def input parameter p-in-mass       as decimal no-undo.
    def input parameter p-in-sum        as decimal no-undo.
    def input parameter p-out-norm-mass as decimal no-undo.
    def input parameter p-out-fact-mass as decimal no-undo.
    def input parameter p-out-fact-sum  as decimal no-undo.

    put stream Out-Stream
      skip space({&P-S})
        v-single-line format "X({&P-X})"
    .
/*    display stream out-stream*/
/*              p-type                              @ v-in-price*/
/*      sym7    p-in-mass       format ">>>9.99"    @ v-in-mass*/
/*      sym8    p-in-sum        format ">>>>>9.99"  @ v-in-sum*/
/*      sym13   p-out-norm-mass format ">>>9.99"    @ v-out-norm-mass*/
/*      sym14*/
/*      sym15   p-out-norm-mass format ">>>9.99"    @ v-out-sum-norm-mass*/
/*      sym16   p-out-norm-mass format ">>>9.99"    @ v-out-norm-mass*/
/*      sym17*/
/*      sym18   p-out-fact-mass format ">>>9.99"    @ v-out-fact-mass*/
/*      sym19   p-out-fact-sum  format ">>>>>9.99"  @ v-out-sum*/
/*      sym21*/
/*    with frame f-doc.*/

end.
end procedure. /* write-itog */