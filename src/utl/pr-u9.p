block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pr-u9.p $
$Archive: utl/pr-u9.p $

Создание переоценок по справочнику товарову которых есть цена но нет переоценок после обрезани

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 12/02/04
*/

{ cmp/str-glbl.i }
{ cmp/library.i  }
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-u9.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/pr-u9.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
define variable g#log as logical   no-undo .
define variable g#ok as integer   no-undo .
define variable v-exist as logical no-undo init false .
define variable bbb as integer   no-undo .
define variable rr as recid     no-undo .
define variable str as character no-undo .
g#log =  session:SET-WAIT-STATE("GENERAL") .
define buffer buf_price-doc for price-doc.
define buffer buf1_price-list for price-list.

on WRITE of price-list override do: end.


for each gds-obj no-lock where gds-obj.price-sale  <> 0
    break by gds-obj.obj-type by gds-obj.obj-code :

    if first-of (gds-obj.obj-code) then do:
        g#ok = 0.
       find first buf_price-doc no-lock where buf_price-doc.doc-num = "2-"+ gds-obj.obj-type + string(gds-obj.obj-code) no-error .
       if error-status :error then find first buf_price-doc no-lock where buf_price-doc.obj-type =  gds-obj.obj-type and buf_price-doc.obj-code = gds-obj.obj-code no-error .

       create price-doc.
       BUFFER-COPY buf_price-doc TO price-doc
       assign
         price-doc.doc-num = "3-"+ gds-obj.obj-type + string(gds-obj.obj-code)
         price-doc.status_  = {&g___new}
         price-doc.fact-num = 0
         price-doc.fact-order = 0
         price-doc.fact-date  = ?
         price-doc.creid  = "TradeHouse"
         price-doc.cr-db-num  =  0
         price-doc.ps  =  "Дополнение к обрезанию"

       .

    end.

    { gbl/gdsbcode.i gds-obj.gds-code ? bbb no-error }

    find first buf1_price-list exclusive-lock  where
               buf1_price-list.obj-type  = gds-obj.obj-type and
               buf1_price-list.obj-code  = gds-obj.obj-code and
               buf1_price-list.b-code    =  bbb and
               buf1_price-list.price-type =  "" and
               buf1_price-list.fact-order > 1  and
               buf1_price-list.artic     = gds-obj.artic    and
               buf1_price-list.prod-type = gds-obj.prod-type and
               buf1_price-list.prod-code = gds-obj.prod-code no-error .
    if not available buf1_price-list then do:
        g#ok = g#ok + 1.
        find first price-doc no-lock where price-doc.doc-num = "3-"+ gds-obj.obj-type + string(gds-obj.obj-code) no-error .
        if error-status :error then message error-status :get-message(1) 123 view-as alert-box .
        create price-list.
        assign
          price-list.doc-num       =  price-doc.doc-num
          price-list.b-code        =  bbb
          price-list.calc-method   =  ""
          price-list.artic         =  gds-obj.artic
          price-list.prod-code     =  gds-obj.prod-code
          price-list.prod-type     =  gds-obj.prod-type
          price-list.d-pcnt        =  0
          price-list.doc-qnty      =  0
          price-list.excise        =  0
          price-list.fact-order    =  0
          price-list.line-num      =  g#ok
          price-list.main-price    =  true
          price-list.obj-code      =  gds-obj.obj-code
          price-list.obj-type      =  gds-obj.obj-type
          price-list.price-calc    =  0
          price-list.price-prev    =  0
          price-list.price-sale    =  gds-obj.price-sale
          price-list.price-type    =  ""
          price-list.road-tax      =  0
          no-error .
          /* НДС */
{ gbl/pftxvalg.i    gds-obj.gds-code
                {&vat-tax-code}
                ?
                price-doc.host-code
                price-doc.obj-type
                price-doc.obj-code
                price-list.vat-pc
                no-error }
                if error-status :error
                then do:
                 message error-status :get-message(1) 33
                 view-as alert-box .
                end.
/* slt */
{ gbl/pftxvalg.i    gds-obj.gds-code
                {&slt-tax-code}
                ?
                price-doc.host-code
                price-doc.obj-type
                price-doc.obj-code
                price-list.slt-pc
                no-error }
                if error-status :error
                then do:
                 message error-status :get-message(1) 444
                 view-as alert-box .

                end.


    end.


    if last-of (gds-obj.obj-code) then do:
       if g#ok = 0 then do:
       /*
          find first price-doc exclusive-lock where price-doc.doc-num = "3-" + gds-obj.obj-type + string(gds-obj.obj-code) no-error .
          delete price-doc.
         */
       end.
       else str = str + price-doc.doc-num  + " " .
       g#ok = 0 .

    end.


g#log =  session:SET-WAIT-STATE("") .
end.

message "ВСЕ готово" str view-as alert-box .