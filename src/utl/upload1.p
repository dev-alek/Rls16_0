block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: upload1.p $
$Archive: utl/upload1.p $

Экспорт сгенеренный кодов Морозко

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: upload1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/upload1.p $":U .
define variable vss-description as character no-undo init "Экспорт сгенеренный кодов Морозко".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ str/bc-gnrt.i new bc}
{ gbl/getcntxt.i def }


define variable atr-txt as char format "x(50)"  no-undo.
define variable bk-txt as char format "x(50)"  no-undo.
define variable kf-txt as char format "x(50)"  no-undo.
define variable dbk-txt-txt as char format "x(50)"  no-undo.
define variable bar_code as char no-undo.
define variable b_c as char no-undo.
define variable v-vat-pc like ub.doc-line.vat-pc no-undo.
define variable v-slt-pc like ub.doc-line.slt-pc no-undo.
def stream txt.


message " Будем экспортировать в текстовый файл БарКоды ? "
view-as alert-box Warning buttons yes-no UPDATE choice AS LOGICAL.

if choice = false then return.

do transaction :
  { gbl/getcntxt.i get }
  run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code) .
end.


output stream txt to value("Bar-Code.txt") no-echo.

FOR EACH gds-list USE-INDEX art :

     display
        gds-list.artic
        with frame ff view-as dialog-box
     title ": Экспорт ".
     pause 0.

     atr-txt = trim(gds-list.artic).
     find goods where goods.artic     = gds-list.artic     and
                      goods.prod-type = gds-list.prod-type and
                      goods.prod-code = gds-list.prod-code no-lock no-error.
     find gds-prt where gds-prt.upper-code = goods.prt-root no-lock.

     find bar-code WHERE bar-code.gds-code  = goods.gds-code
                     and bar-code.node-code = gds-prt.node-code
                     and bar-code.part-code = ""
                     and bar-code.in-code   = ""
                     and bar-code.unit-cli  =  goods.unit-base
     no-lock.

     RUN gen-bc( input bar-code.b-code, output bar_code ).
     { gbl/pftxvalg.i goods.gds-code {&vat-tax-code} today v-cntxt-host-code-obj v-cntxt-obj-type v-cntxt-obj-code v-vat-pc  }
     { gbl/pftxvalg.i goods.gds-code {&slt-tax-code} today v-cntxt-host-code-obj v-cntxt-obj-type v-cntxt-obj-code v-slt-pc  }
     put stream txt unformatted  trim(atr-txt) ";"
                          trim(string(bar-code.b-code)) ";" trim(goods.gds-name)  ";" v-vat-pc  ";" v-slt-pc skip.

     put stream txt unformatted  trim(bar_code) skip.

     for each bar-code where bar-code.gds-code   = goods.gds-code
                         and bar-code.node-code  = gds-prt.node-code
                         and bar-code.part-code  = ""
                         and bar-code.in-code    = ""
                         no-lock :
       for each prod-bc where prod-bc.b-code = bar-code.b-code
                          and prod-bc.bc-on  = yes              no-lock :
           put stream txt unformatted  trim(prod-bc.b-str)  skip.
       end.  /*   for each prod-bc   */
     end.


     for each bar-code WHERE bar-code.gds-code   = goods.gds-code
                         and bar-code.node-code  = gds-prt.node-code
                         and bar-code.part-code  = ""
                         and bar-code.in-code    = ""
                         and bar-code.unit-cli  <>  goods.unit-base    NO-LOCK:
        put stream txt unformatted  trim(string(bar-code.b-code))  skip.
        RUN gen-bc( input bar-code.b-code, output b_c ).
        put stream txt unformatted  trim(b_c)  skip.

     end.  /*  for each bar-code  */

end.  /*  FOR EACH gds-list  */

output stream txt close.

message " Все, смотрите файл Bar-Code.txt в рабочей директории. "
view-as alert-box information buttons ok.