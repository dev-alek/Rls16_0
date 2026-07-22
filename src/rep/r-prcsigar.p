/*

$Revision: 2ba76cb327bb, 87, rls $
$Author: EShklyar $
$Date: Thu Oct 30 18:55:08 2014 +0300 $
$Workfile: r-prcsigar.p $
$Archive: rep/r-prcsigar.p $

Отчет Прайс лист на табачные изделия

Автор: Гридчина Полина Дмитриевна
Дата создания: 14/07/22
Author: Gridchina Polina
Creation date: 14/07/22


*/

using Progress.Lang.*.
using Ibs.Th.Gbl.Rep-Out.
block-level on error undo, throw.
def var vss-revision    as character no-undo init "$Revision: 2ba76cb327bb, 87, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: Thu Oct 30 18:55:08 2014 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-prcsigar.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-prcsigar.p $":U .
def var vss-description as character no-undo init "Печать Прайс-листа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ rep/r-sym.i    }
{ cmp/r-page1.i  }
{ rep/r-gl.i     }
{ gbl/paramls.i  }
{ gbl/waitfram.i }
{ rep/f-fdec.i   }
{ rep/rep-bt.i   }
/*===================================================================================================================*/

define input parameter  chek_type    as  int      no-undo.
define input parameter  name_Type    as  int      no-undo.

define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .

&glob check-no-error no-error. if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).
&glob check-error if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).



def  var OnlyPrices    as      logical  no-undo.
def var Log-Res      as      log     no-undo.
def buffer buf_goods for ub.goods.
define stream out-stream.
define temp-table tt-price no-undo
    field price like ub.gds-obj.price-sale
    field name like ub.goods.gds-name.



{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_price-list_print':U
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
if not Log-Res then
    return "NO".



/*
if session:set-wait-state("COMPILER") then.

if i = 0 OR P_Type = 0 then
    return.
if session:set-wait-state("COMPILER") then.
*/

empty temp-table tt-price.

FOR EACH gds-list, first buf_goods where buf_goods.gds-code = gds-list.gds-code no-lock, first gds-obj no-lock where gds-obj.gds-code = buf_goods.gds-code
and gds-obj.obj-type =  v-cntxt-obj-type
and   gds-obj.obj-code =  v-cntxt-obj-code:
    if chek_type = 1 and gds-obj.price-sale > 0 and gds-obj.fact-qnty > 0 then.
    else if chek_type = 2 and gds-obj.price-sale > 0 then.
    else next.
    create tt-price.
    tt-price.name = if name_type = 1 then buf_goods.gds-name else buf_goods.label-name.
    tt-price.price = gds-obj.price-sale.
    
     /*
    ACCUMULATE gds-list.artic (COUNT) .
    if ( ( ( ACCUM COUNT gds-list.artic )  modulo 50 ) = 0 ) AND
               ( ( ACCUM COUNT gds-list.artic ) >= 50 ) then
        RUN waitfram-show( /"Обработано наименований : " +
                                    string( ACCUM COUNT gds-list.artic ) ) .
                                    */
END.
   run main no-error. 
if error-status:error then
    message return-value
    view-as alert-box.
    
 
    
procedure main:
  
    define variable v-file-name as character no-undo.
    
    run create-rep(output v-file-name) {&check-no-error}  /* создаем отчет */
    

    
    if v-file-name = ? then
        return error "файл созданного отчета не найден".
    else
        run open-ie(v-file-name) {&check-no-error}
        
   { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

    put stream out-stream unformatted
          {&new-line}
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + {&new-line}
    .
    output stream out-stream close.  
    

end.


procedure create-rep:
    define output parameter p-filename as character no-undo.
        
    define variable v-rls-file as character no-undo.
    define variable v-data-file as character no-undo.
    define variable v-xsl-file as character no-undo.
    define variable v-tmp-file as character no-undo.
    define variable hw as handle no-undo.
    define variable rep-out as class Rep-Out no-undo.
    
    assign
        v-xsl-file = search("exe/prcsigar.xsl.html")
        v-data-file = session:temp-directory + string(time) + ".xml"
        v-tmp-file = session:temp-directory + string(time) + ".html".
    .
   
    create sax-writer hw.
    hw:formatted = true.
    hw:set-output-destination ("file", v-data-file).
    
    run write-data(hw) {&check-no-error}
    
    rep-out = new rep-out ().
    v-rls-file = rep-out:xsl-transform(v-data-file, v-xsl-file).    
    message v-rls-file view-as alert-box.
    os-delete value(v-tmp-file).
    os-copy value(v-rls-file) value(v-tmp-file).  
    os-delete value(v-rls-file).
    delete object rep-out.
  
    p-filename = v-tmp-file.
    
end.


procedure write-data:
    define input parameter hw as handle no-undo.
       
    hw:start-document ().
    hw:start-element ("rep").

    for each tt-price no-lock by name:
        hw:start-element ("line"). 

            hw:insert-attribute ("gds-name", if tt-price.name = ? then "" else tt-price.name).
            /*Колонка Количество (штук) - фактическое количество по строке документа.*/
    
            hw:insert-attribute ("reason", if tt-price.price = ? then "" else string(tt-price.price,"->,>>>,>>>,>>>,>>9.99")).
            /*Колонка  Сумма (руб.) - сумма в ценах документа по строке.*/
            
        hw:end-element ("line").
    end.  
        
    
           
    hw:end-element ("rep").
    hw:end-document ().

end.

procedure open-ie:
    define input parameter p-filename as character no-undo.
    
    define variable o-IE as com-handle no-undo.

    create "InternetExplorer.Application" o-IE.
    /* o-IE:menubar = false. */
    o-IE:addressbar = false.
    o-IE:Navigate(p-filename).
    o-IE:visible = true.
    release object o-IE.


end.




