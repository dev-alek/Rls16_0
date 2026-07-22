/*

$Revision: 0bff6b34250a, 11, test $
$Author: EShklyar $
$Date: Wed Mar 05 12:40:36 2014 +0300 $
$Workfile: r-wofrosneft.p $
$Archive: rep/r-wofrosneft.p $

Документ расхода, возврата и списания  короткий

Автор: Соломко Дмитрий Владимирович
Дата создания: 14/01/14
Author: Solomko Dmitry 
Creation date: 14/01/14

*/

using Progress.Lang.*.
using Ibs.Th.Gbl.Rep-Out.
block-level on error undo, throw.
define input parameter parParentProc        AS WIDGET-HANDLE NO-UNDO.
define input parameter rec_id               as recid        no-undo.
define input  parameter is-chek             as logical   no-undo .
define input parameter p-mode               as character        no-undo.

define stream out-stream.


define variable vss-revision    as character no-undo initial "$Revision: 0bff6b34250a, 11, test $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Wed Mar 05 12:40:36 2014 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-wofrosneft.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-wofrosneft.p $":U .
define variable vss-description as character no-undo initial "Служебная записка, Html - отчет, Роснефть":U .


define variable g#report-num    as integer      no-undo.


define buffer t-doc        for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_goods    for ub.goods.
define buffer OurObject    for ub.clients.
define buffer buf_gds-dtl  for ub.gds-dtl.
  

define variable v-doc-code           as character            no-undo.
define variable v-fact-date-string   as character            no-undo.
define variable v-doc-date-string    as character            no-undo.
define variable v-boss-name         like ub.clients.obj-name no-undo.
define variable v-obj-name          like ub.clients.obj-name no-undo.
define variable v-wrkr-name         like ub.clients.obj-name    no-undo.
define variable v-oper-name          as character            no-undo.
define variable v-agnt-name         like ub.clients.obj-name    no-undo.
define variable v-lines-counter      as integer               no-undo.
define variable v-all-qnty           as decimal               no-undo.
define variable v-all-stoim          as decimal             no-undo.
define variable s1                  as character            no-undo.
define variable s2                  as character            no-undo.


define temp-table tt-line no-undo
    /*  уникальный код товара*/
    field gds-code as integer
    /*Колонка № п/п номер по порядку*/
    field lines-counter as integer
    /*Колонка Артикул - артикул товара.*/
    field artic as character 
    /*Колонка Наименование - наименование товара.*/
    field gds-name as character
    /*Колонка Количество (штук) - фактическое количество по строке документа.*/
    field qnty as decimal
    /*Колонка Розничная Цена (руб.)  - цена документа по товару*/
    field price as  decimal
    /*Колонка  Сумма (руб.) - сумма в ценах документа по строке.*/
    field stoim as  decimal
    /*Колонка Основание для списания*/ 
    field reason as character
    
    index pi as primary gds-code
.

  
/* для проверок при вызове процедуры */
&glob check-no-error no-error. if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).
&glob check-error if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).

{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ str/trdcalib.i  }
{ cmp/library.i   }
{ cmp/r-pril.i    }
{ str/clcprtsl.i }

do
on error undo, return error
:  v-all-qnty = 0.
   v-all-stoim = 0.
   v-fact-date-string = "".
   
  find first t-doc no-lock  where recid( t-doc ) = rec_id  no-error.
  if not available t-doc  then do:
    message
        vss-workfile vss-revision vss-description    skip "Не найден документ для печати."
        skip return-value   skip trim(error-status :get-message(1))  trim(error-status :get-message(2))  trim(error-status :get-message(3))
    view-as alert-box error.
    undo, return error .
  end.
    /*Заполняем шапку*/ 
  
    /*МОЛ по документу – Менеджер*/
      run rep/get-psn.p
      (input t-doc.boss
      ,output v-boss-name
      ) .
    if v-boss-name = "?" then v-boss-name = " ".
    
    /* от оператора-продавца ФИО  -  поле Исп: МОЛ по документу - Исполнитель.*/
     run rep/get-psn.p
      (input t-doc.agnt
      ,output v-agnt-name
      ) .
    if v-agnt-name = "?" then v-agnt-name = " ".
    
    
    
    /*название объекта*/
    find first OurObject no-lock
     where OurObject.obj-type = t-doc.obj-type
       and OurObject.obj-code = t-doc.obj-code
    no-error.
    if available OurObject then 
    do:
    v-obj-name = OurObject.obj-name.
    end.  
                              
    /*порядковый номер документа в системе*/
    v-doc-code = t-doc.doc-code.
    
    /*дата trn-doc.fact-date*/
    v-fact-date-string = if t-doc.status_ = {&fact} then  " от " + string( t-doc.fact-date , "99/99/9999" ) else "" .

    /*дата trn-doc.doc-date*/
    v-doc-date-string = string( t-doc.doc-date, "99/99/9999" ). 
    
    /* Конец заполнения шапки */
     for each buf_doc-line no-lock
            where buf_doc-line.doc-code = t-doc.doc-code:
     find first buf_goods no-lock  where buf_goods.artic      = buf_doc-line.artic
                                      and buf_goods.prod-type  = buf_doc-line.prod-type
                                      and buf_goods.prod-code  = buf_doc-line.prod-code.
     if available buf_goods  then 
                             do:


                                 create tt-line.
                                 tt-line.gds-code = buf_goods.gds-code.
                                 /*Колонка Артикул - артикул товара.*/
                                 tt-line.artic = buf_goods.artic.
                                 /*Колонка Наименование - наименование товара.*/
                                 tt-line.gds-name = buf_goods.gds-name.
                                 /*Колонка Количество (штук) - фактическое количество по строке документа.*/
                                 tt-line.qnty = buf_doc-line.fact-qnty.
                                 v-all-qnty = v-all-qnty + tt-line.qnty.
                                 
                                 run clcprtsl_calc-line in this-procedure (input recid (buf_doc-line)).
                                 find first tt-allsum-line where tt-allsum-line.sum-type = {&sum-general} no-error .
                                 /*Колонка  Сумма (руб.) - сумма в ценах документа по строке.*/
                                 tt-line.stoim = tt-allsum-line.sum-dsc-rubl-doc.
                                 v-all-stoim = v-all-stoim + tt-line.stoim.
                                 /*Колонка Розничная Цена (руб.)  - цена документа по товару*/
                                 tt-line.price   = tt-line.stoim / tt-line.qnty no-error.
                                 find first ub.trn-reason no-lock 
                                         where ub.trn-reason.reason-code = t-doc.reason-code no-error.
                                 if  available ub.trn-reason then 
                                 do:
                                 /* Колонка Основание для списания*/
                                 tt-line.reason = ub.trn-reason.reason-name. 
                                 end.
                                 

                                         
                            end.        
      end. 
     v-all-stoim = round( v-all-stoim,2).

     run rep/wp-rub.p ( input v-all-stoim, output s1, output s2 ) .  
     s1 = RIGHT-TRIM(s1,".").



    /*Заполняем подвал*/
    /*Управляющий АЗК № - поле Кл-к: МОЛ по документу -  Кладовщик*/ 
      run rep/get-psn.p
      (input t-doc.wrkr
      ,output v-wrkr-name
      ) .
     if v-wrkr-name = "?" then v-wrkr-name = " " .
     /* Конец заполнения подвала*/

run main no-error. 
if error-status:error then
    message return-value
    view-as alert-box.
    
end.    
    
    
procedure main:
  
    define variable v-file-name as character no-undo.
    
    run create-rep(output v-file-name) {&check-no-error} /* создаем отчет */
    

    
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
        v-xsl-file = search("exe/writeofrosneft.xsl.html")
        v-data-file = session:temp-directory + string(time) + ".xml"
        v-tmp-file = session:temp-directory + string(time) + ".html".
    .
    
    create sax-writer hw.
    hw:formatted = true.
    hw:set-output-destination ("file", v-data-file).
    

    run write-data(hw) {&check-no-error}
    

 
    rep-out = new rep-out().
    v-rls-file = rep-out:xsl-transform(v-data-file, v-xsl-file).    
    os-delete value(v-tmp-file).
    os-copy value(v-rls-file) value(v-tmp-file).  
    os-delete value(v-rls-file).
    delete object rep-out.
  
    p-filename = v-tmp-file.
    
end.


procedure write-data:
    define input parameter hw as handle no-undo.
    v-lines-counter = 1.
    
    hw:start-document ().
    hw:start-element ("rep").
    hw:start-element ("card").
    /*МОЛ по документу – Менеджер*/
    hw:insert-attribute ("boss-name", if v-boss-name = ? then "" else v-boss-name ).
    /* от оператора-продавца ФИО  -  поле Исп: МОЛ по документу - Исполнитель.*/
    hw:insert-attribute ("agnt-name", if v-agnt-name = ? then "" else v-agnt-name ).
    
    /*название объекта*/
    hw:insert-attribute ("obj-name", if v-obj-name = ? then "" else v-obj-name ).
    /*порядковый номер документа в системе*/
    hw:insert-attribute ("doc-code", if v-doc-code = ? then "" else v-doc-code ).
    /*дата trn-doc.doc-date*/
    hw:insert-attribute ("fact-date-string", if v-fact-date-string = ? then "" else  v-fact-date-string  ).
    hw:insert-attribute ("doc-date-string", if v-doc-date-string = ? then "" else  v-doc-date-string  ).

    /*Управляющий АЗК № - поле Кл-к: МОЛ по документу -  Кладовщик*/
    hw:insert-attribute ("wrkr-name", if v-wrkr-name = ? then "" else v-wrkr-name ).
    hw:insert-attribute ("all-qnty", if v-all-qnty = ? then "" else string(v-all-qnty,"->>,>>>,>>9.<<") ).
    hw:insert-attribute ("all-stoim", if v-all-stoim = ? then "" else string(v-all-stoim,"->,>>>,>>>,>>>,>>9.99")  ).
    hw:insert-attribute ("s1", if s1 = ? then "" else s1  ).
    hw:insert-attribute ("s1rub", if v-all-stoim = ? then "" else string(trunc( v-all-stoim, 0 ),"->,>>>,>>>,>>>,>>9"))  .
    hw:insert-attribute ("s1kop", if v-all-stoim = ? then "" else string(trunc((v-all-stoim - trunc( v-all-stoim, 0 )) * 100, 0), "99"))  .    
    
    for each tt-line no-lock:
        tt-line.lines-counter = v-lines-counter.
        hw:start-element ("line"). 
        /*Колонка № п/п номер по порядку*/
        hw:insert-attribute ("lines-counter", string(tt-line.lines-counter)).
        /*Колонка Артикул - артикул товара.*/
        hw:insert-attribute ("artic", if tt-line.artic = ? then "" else tt-line.artic).
        /*Колонка Наименование - наименование товара.*/
        hw:insert-attribute ("gds-name", if tt-line.gds-name = ? then "" else tt-line.gds-name).
        /*Колонка Количество (штук) - фактическое количество по строке документа.*/
        hw:insert-attribute ("qnty", if tt-line.qnty = ? then "" else string(tt-line.qnty,"->>,>>>,>>9.<<")).
        /*Колонка Розничная Цена (руб.)  - цена документа по товару*/
        hw:insert-attribute ("price", if tt-line.price = ? then "" else string(tt-line.price,"->,>>>,>>>,>>>,>>9.99")).
        /*Колонка  Сумма (руб.) - сумма в ценах документа по строке.*/
        hw:insert-attribute ("stoim", if tt-line.stoim = ? then "" else string(tt-line.stoim,"->,>>>,>>>,>>>,>>9.99")).
        /* Колонка Основание для списания*/
        hw:insert-attribute ("reason", if tt-line.reason = ? then "" else tt-line.reason).
        hw:end-element ("line").
        v-lines-counter = v-lines-counter + 1.
    end.  
        
    
    


    
    
           
  
    hw:end-element ("card").
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


