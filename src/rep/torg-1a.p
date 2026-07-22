/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: torg-1a.p $
$Archive: rep/torg-1a.p $

Акт о приемке товаров - spar html

Автор: Харитонов Владимир Александрович
Дата создания: 08/10/13
Author: KHaritonov vladimir
Creation date: 08/10/13

*/

using Progress.Lang.*.
using Ibs.Th.Gbl.Rep-Out.
block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter Invers               as logical          no-undo.

define stream out-stream.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: torg-1a.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/torg-1a.p $":U .
define variable vss-description as character no-undo init "Документ Технологическая - 3 ".

{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ str/trdcalib.i  }
{ cmp/library.i   }
{ cmp/r-pril.i    }

define variable g#report-num    as integer      no-undo.

/* переменные для шапки, 1 стр */
define variable v-org-name              as character no-undo. /* название фирмы */
define variable v-obj-name              as character no-undo. /* название объекта */
define variable v-reason-num            as character no-undo. /* номер основания для составления акта */
define variable v-reason-date           as date      no-undo. /* дата основания для составления акта */
define variable v-reason-num2           as character no-undo. /* конкатенация номер основания + дата основания*/ 
define variable v-doc-code              as character no-undo. /* код документа */
define variable v-fact-date             as date      no-undo. /* факт дата закрытия */
define variable v-consignee             as character no-undo. /* место приемки */
define variable v-schet-factura-num     as character no-undo. /* сопроводительные документы - номер */
define variable v-schet-factura-date    as character no-undo. /* сопроводительные документы - дата */
define variable v-schet-factura-num-date as character no-undo. /* конкатенация сопроводительные документы -номер + сопроводительные документы -дата */
define variable v-shipper               as character no-undo. /* грузоотправитель */
define variable v-supplier              as character no-undo. /* поставщик */
define variable v-contract              as character no-undo. /* договор */

/* линии 2 и 3 страницы */
define temp-table tt-line no-undo
    field gds-name as character /* название товара */
    field gds-code as integer /* код товара */
    field unit-name as character /* единицы измерения */
    field unit-okei as character /* ед изм по окей */
    field price-no-vat as decimal format "->>,>>9.99" /* цена без налога */
    field qnty-supp as decimal /* по док поставщика, кол, мест штук */
    field sum-supp as decimal /* стоимость, баз. валюта */
    
    /* вторая часть таблички */
    field qnty-fact as decimal /* факт количество, мест, штук 13 */
    field sum-fact as decimal /* сумма в без валюте по факту 16 столбец*/
    field sum-fact-vat as decimal /* сумма в баз валюте по факту с ндс 17 столбец */
    field vat as decimal /* % ндс 18 столбец */
    field vat-sum as decimal /* сумма ндс 19 столбец */
    field qnty-delta as decimal /* разница количеств */
    field sum-delta as decimal /* разница сумм */
    field sertif as character /* сертификат */
    
    index pi as primary unique gds-code
.

/* Переменные для второй-третьей страницы*/
define variable v-price         as decimal      no-undo.
define variable v-qnty-supp     as decimal      no-undo.
define variable v-qnty-fact     as decimal      no-undo.

/* Переменные для подсчета Итого*/
define variable v-sum-PlaceAmountSupp   as decimal      no-undo.
define variable v-sum-SumSupp           as decimal      no-undo.
define variable v-sum-PlaceAmountFact   as decimal      no-undo.
define variable v-sum-SumFact           as decimal      no-undo.
define variable v-sum-sum               as decimal      no-undo.
define variable v-sum-VATsum            as decimal      no-undo.
define variable v-sum-PlaceAmountDelt   as decimal      no-undo.
define variable v-sum-SumDelt           as decimal      no-undo.


/* Переменные для Сертификата*/
define variable v-sert                  as character    no-undo.
define variable v-bar-code              as integer      no-undo.



/* Переменные для подвала*/
define variable v-attorney-num          as character no-undo. /* доверенность номер  */
define variable v-attorney-date         as character no-undo. /* доверенность дата */
define variable v-attorney-who          as character no-undo. /* доверенность кем и кому выдана */
define variable v-position              as character no-undo. /* Должность и ФИО сдающего */
define variable v-position1             as character no-undo. /* Должность сдающего */
define variable v-position2             as character no-undo. /* ФИО сдающего */
define variable v-storekeeper           as character no-undo. /* Зав. складом - кладовщик документа */



/*Определяем буферы*/
define buffer buf_doc-line      for doc-line.
define buffer buf_parts         for parts.
define buffer buf_goods         for goods.
define buffer buf_units         for units.
define buffer buf_sert-join     for sert-join.
define buffer buf_sert          for sert.

/* для проверок при вызове процедуры */
&glob check-no-error no-error. if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).
&glob check-error if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).

run main no-error. 
if error-status:error then
    message return-value
    view-as alert-box.
   
procedure main:
    /* найдем документ */
    find first ub.trn-doc no-lock where recid(ub.trn-doc) = rec_id.
    
    /* только накладные магазинные */
    if ub.trn-doc.obj-type <> {&shop} then
    return error subst("Объект &1 не является магазином", ub.trn-doc.obj-code).
    
    
    define variable v-file-name as character no-undo.
    
    run prepare-header {&check-no-error} /*заполняем шапку */
    run prepare-lines {&check-no-error}  /*заполняем таблицу */
    run prepare-footer {&check-no-error} /*заполняем подвал */
    
    run create-rep(output v-file-name) {&check-no-error} /* создаем отчет */
    
    if v-file-name = ? then
        return error "файл созданного от чета не найден".
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

procedure prepare-header:
    define variable v-character as character no-undo.
    define variable v-integer as integer no-undo.
    define variable v-type as character no-undo.
    
    /* название фирмы */
    { gbl/hostname.i
      ub.trn-doc.obj-type
      ub.trn-doc.obj-code
      v-integer
      v-org-name
    }
    
    /* название объекта */
    find first ub.clients no-lock
        where ub.clients.obj-type = ub.trn-doc.obj-type
        and ub.clients.obj-code = ub.trn-doc.obj-code.
    
    v-obj-name = ub.clients.obj-name.
    
    /* номер основания */
    { str/tdat-val.i
      ub.trn-doc.doc-code
      {&trdcattr-nids}
      v-reason-num
      v-type
    }
    
    /* дата основания */
    { str/tdat-val.i
      ub.trn-doc.doc-code
      {&trdcattr-dids}
      v-reason-date
      v-type
    }
    /* конкатенация номер основания + дата основания*/
    v-reason-num2 = string(v-reason-num) + string(v-reason-date).
    
    /* код документа */
    v-doc-code = ub.trn-doc.doc-code.
    
    /* дата закрытия */
    v-fact-date = ub.trn-doc.fact-date.
    
    /* место приемки */
    find first ub.clients no-lock
        where ub.clients.obj-type = ub.trn-doc.obj-type
        and ub.clients.obj-code = ub.trn-doc.obj-code.
        
    find first ub.shop no-lock
        where ub.shop.obj-code = ub.trn-doc.obj-code.
    
    v-consignee = trim(subst("&1, &2 &3", ub.clients.obj-name, ub.shop.addres1, ub.shop.addres2)).
    
    /* сопроводительные документы */
    /* номер */
    { str/tdat-val.i
      ub.trn-doc.doc-code
      {&trdcattr-nsf}
      v-schet-factura-num
      v-type
    }
    
    /* дата */
    { str/tdat-val.i
      ub.trn-doc.doc-code
      {&trdcattr-dsf}
      v-schet-factura-date
      v-type
    }
    

    
    if v-schet-factura-num = "" and v-schet-factura-date = "" then v-schet-factura-num-date = "".
         else v-schet-factura-num-date =" счёт-фактура № " + v-schet-factura-num + " от " + v-schet-factura-date.
    
    /* Грузоотправитель */
    { str/tdat-val.i
      ub.trn-doc.doc-code
      {&trdcattr-shipper}
      v-shipper
      v-type
    }
     /* Код грузоотправителя преобразуем в название */
     find first ub.clients no-lock where ub.clients.obj-type = substring(v-shipper, 1, 3)
                                        and
                                        ub.clients.obj-code = integer(substring(v-shipper, 4)) no-error.
     if available ub.clients then 
     do:
     v-shipper = ub.clients.obj-name.
     
     /* Юридический адрес грузоотправителя */
         if ub.clients.obj-type = {&prs} then 
            do:
            find first ub.person no-lock where ub.person.psn-code = ub.clients.obj-code no-error.
            if available ub.person then
                  v-shipper = v-shipper + " " + ub.person.address.
        end.
        else       
            do:
            find first ub.firm no-lock where ub.firm.firm-code = ub.clients.obj-code no-error.
            if available ub.firm then
            do: 
                 v-shipper =  v-shipper + " " + ub.firm.addres1 + ub.firm.addres2.
            end.
        end.
       end.
    
    
    
    
    /* Почтовый адрес, если грузоотправитель не задан*/
    if v-shipper = "" or v-shipper = ? then 
         do:
         find first ub.clients no-lock where ub.clients.obj-type = ub.trn-doc.cli-type
                                           and
                                           ub.clients.obj-code = ub.trn-doc.cli-code no-error.
         if available ub.clients then
                  v-shipper = ub.clients.obj-name.     



         if trn-doc.cli-type = {&prs} then 
            do:
            find first ub.person no-lock where ub.person.psn-code = ub.trn-doc.cli-code no-error.
            if available ub.person then
                  v-shipper = v-shipper /*+ " " + ub.person.address*/.
           end.
         else       
            do:
            find first ub.firm no-lock where ub.firm.firm-code = ub.trn-doc.cli-code no-error.
            if available ub.firm then
                 v-shipper =  v-shipper + " " + ub.firm.post-addr1 + ub.firm.post-addr2 .
            end.    
         end.    
                                   
            
       /* поставщик */  
       
       find first ub.clients no-lock where ub.clients.obj-type = ub.trn-doc.cli-type
                                           and
                                           ub.clients.obj-code = ub.trn-doc.cli-code no-error.
            if available ub.clients then
                  v-supplier = ub.clients.obj-name.     



    if trn-doc.cli-type = {&prs} then 
            do:
            find first ub.person no-lock where ub.person.psn-code = ub.trn-doc.cli-code no-error.
            if available ub.person then
                  v-supplier = v-supplier + " " + ub.person.address.
           end.
     else       
            do:
            find first ub.firm no-lock where ub.firm.firm-code = ub.trn-doc.cli-code no-error.
            if available ub.firm then
                 v-supplier =  v-supplier + " " + ub.firm.addres1 .
            end.
            
            
       /* договор */
       
            find first ub.contract no-lock where ub.contract.host-code = ub.trn-doc.host-code
                                           and   ub.contract.contract-code = ub.trn-doc.contract-code
             no-error.
            if available ub.contract then
            v-contract = string( ub.contract.contract-prn-code ) + " от " + string( ub.contract.contract-date, "99/99/9999" ).     
   
end.

procedure prepare-lines:
    
    
for each buf_doc-line no-lock
where buf_doc-line.doc-code = trn-doc.doc-code
:
        find first buf_goods no-lock
             where buf_goods.artic      = buf_doc-line.artic
               and buf_goods.prod-type  = buf_doc-line.prod-type
               and buf_goods.prod-code  = buf_doc-line.prod-code
        .
        
        find first buf_units no-lock
              where buf_units.unit-name = buf_goods.unit-base
        .
        
        for each buf_parts no-lock
           where buf_parts.out-code   = trn-doc.doc-code
             and buf_parts.obj-type   = trn-doc.obj-type
             and buf_parts.obj-code   = trn-doc.obj-code
             and buf_parts.prod-type  = buf_doc-line.prod-type
             and buf_parts.prod-code  = buf_doc-line.prod-code
             and buf_parts.artic      = buf_doc-line.artic:
                 
         v-price = buf_parts.price-rubl. 
         v-qnty-supp = buf_parts.qnty.
         v-qnty-fact = buf_parts.fact-qnty.
         
    
         create tt-line.
         assign
            
            /* Первая часть таблички*/
            
            tt-line.gds-name =  buf_goods.gds-name   /* название товара */
            tt-line.gds-code =  buf_goods.gds-code   /* код товара      */
            tt-line.unit-name = buf_units.unit-name  /* единица измерения*/ 
            tt-line.unit-okei = string(buf_units.OKEI)/* Код по окей*/
            tt-line.price-no-vat = v-price - v-price * buf_parts.VAT-pc / ( 100 + buf_parts.VAT-pc ).
            tt-line.qnty-supp =  v-qnty-supp. 
            tt-line.sum-supp = tt-line.price-no-vat * tt-line.qnty-supp.
           
            /* Вторая часть таблички*/
            
            tt-line.qnty-fact =  v-qnty-fact.
            tt-line.sum-fact-vat = v-price * tt-line.qnty-fact.
            tt-line.vat = buf_parts.VAT-pc.
            tt-line.vat-sum = tt-line.vat / 100 * v-qnty-fact * tt-line.price-no-vat.  
            
            /*Подсчёт суммы Итого*/
            
            v-sum-PlaceAmountSupp = v-sum-PlaceAmountSupp + v-qnty-supp. 
            v-sum-SumSupp         = v-sum-SumSupp         + ( v-qnty-supp  *  tt-line.price-no-vat ).
            v-sum-PlaceAmountFact = v-sum-PlaceAmountFact + v-qnty-fact. 
            v-sum-SumFact         = v-sum-SumFact         + ( v-qnty-fact * tt-line.price-no-vat ).
            v-sum-sum             = v-sum-sum             + ( v-qnty-fact * v-price ).  
            v-sum-VATsum          = v-sum-VATsum          + ( buf_parts.VAT-pc / 100 * v-qnty-fact * tt-line.price-no-vat ) .         
            v-sum-PlaceAmountDelt = v-sum-PlaceAmountDelt + ( v-qnty-fact - v-qnty-supp ).
            v-sum-SumDelt         = v-sum-SumDelt         + ( ( v-qnty-fact - v-qnty-supp ) * tt-line.price-no-vat ).
            /*----- определяем строку с перечислением сертификатов ------*/
            assign
                v-sert = "":U
            .
            { gbl/gdsbcode.i
                buf_goods.gds-code
                ?
                v-bar-code
            no-error }.
            for each buf_sert-join no-lock
               where buf_sert-join.cli-type   = buf_goods.prod-type
                 and buf_sert-join.cli-code   = buf_goods.prod-code
                 and buf_sert-join.b-code     = v-bar-code
            :
                for each buf_sert no-lock
                   where buf_sert.sert-code = buf_sert-join.sert-code
                :
                    if  trn-doc.fact-date <= buf_sert.last-date
                    and trn-doc.fact-date >= buf_sert.first-date
                    then do:
                        assign
                            v-sert = v-sert
                                    + ( if trim( v-sert ) = "":U
                                        then "":U
                                        else ", ":U )
                                    + string( buf_sert-join.sert-code )
                        .
                    end.
                end.
            end.
            
            tt-line.sertif = v-sert.
       
       
       
        end.  /*end for each buf_parts */
        

end.        /*end for each buf_doc-line */
end.        /*end procedure prepare-lines*/

procedure prepare-footer:
    
    define variable v-type as character no-undo.
    
     /* доверенность номер */
    { str/tdat-val.i
      ub.trn-doc.doc-code
      {&trdcattr-ndov}
      v-attorney-num
      v-type
    }  
    /* доверенность дата */
    { str/tdat-val.i
      ub.trn-doc.doc-code
      {&trdcattr-ddov}
      v-attorney-date
      v-type
    }  
    
    /* доверенность кем выдана */
    { str/tdat-val.i
      ub.trn-doc.doc-code
      {&trdcattr-ndovwho}
      v-attorney-who
      v-type
    }  
    
    
     /* сдал ФИО */
    { str/tdat-val.i
      ub.trn-doc.doc-code
      {&trdcattr-t_pass-fname}
      v-position1 
      v-type
    }  
    
     /* сдал должность */
    { str/tdat-val.i
      ub.trn-doc.doc-code
      {&trdcattr-t_pass-position}
      v-position2 
      v-type
    }  
    /* Сдал должность и ФИО*/
    v-position = v-position2 /*+ v-position1*/. 
    

    
    /* Кладовщик */
    
    find first ub.clients no-lock
    where ub.clients.obj-code = ub.trn-doc.wrkr
    and ub.clients.obj-type = {&prs} no-error.
    if available ub.clients then v-storekeeper = ub.clients.obj-name.
    
    
 
     
    
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
        v-xsl-file = search("exe/torg1a.xsl.html")
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
    
    hw:start-document ().
    hw:start-element ("rep").
    hw:start-element ("card").
    
    hw:insert-attribute ("name", if v-org-name = ? then "" else v-org-name ).
    hw:insert-attribute ("obj_name", if v-obj-name = ? then "" else v-obj-name).
    hw:insert-attribute ("reason-num", if v-reason-num = ? then "" else v-reason-num).
    hw:insert-attribute ("reason-date1", if v-reason-date = ? then "" else string( day(v-reason-date))).
    hw:insert-attribute ("reason-date2", if v-reason-date = ? then "" else string( month(v-reason-date), "99")).
    hw:insert-attribute ("reason-date3", if v-reason-date = ? then "" else string( year(v-reason-date))).
    hw:insert-attribute ("doc-code", if v-doc-code = ? then "" else v-doc-code ).
    hw:insert-attribute ("fact-date", if v-fact-date = ? then "Не указана" else string(v-fact-date, "99/99/9999")).
    hw:insert-attribute ("consignee", if v-consignee = ? then "" else v-consignee).
    hw:insert-attribute ("schet-factura", if v-schet-factura-num-date = ? then "" else v-schet-factura-num-date).
    hw:insert-attribute ("shipper", if v-shipper = ? then "" else v-shipper ).
    hw:insert-attribute ("supplier", if v-supplier = ? then "" else v-supplier).
    hw:insert-attribute ("contract", if v-contract = ? then "" else v-contract).
    hw:insert-attribute ("attorney-num", if v-attorney-num = ? then "" else v-attorney-num).  
    hw:insert-attribute ("attorney-date", if v-attorney-date = ? then "" else v-attorney-date).
    hw:insert-attribute ("attorney-who", if v-attorney-who = ? then "" else v-attorney-who).
    hw:insert-attribute ("position", if v-position = ? then "" else v-position). 
    hw:insert-attribute ("storekeeper", if v-storekeeper = ? then "" else v-storekeeper).
    hw:insert-attribute ("v-sum-PlaceAmountSupp",if v-sum-PlaceAmountSupp = ? then string(0) else string(v-sum-PlaceAmountSupp,"->>,>>9.99") ).
    hw:insert-attribute ("v-sum-SumSupp",if v-sum-SumSupp = ? then string(0) else string(v-sum-SumSupp,"->>,>>9.99")  ). 
    hw:insert-attribute ("v-sum-PlaceAmountFact",if v-sum-PlaceAmountFact = ? then string(0) else string(v-sum-PlaceAmountFact,"->>,>>9.99") ).
    hw:insert-attribute ("v-sum-SumFact",if v-sum-SumFact = ? then string(0) else string(v-sum-SumFact,"->>,>>9.99")  ).
    hw:insert-attribute ("v-sum-sum",if v-sum-sum = ? then string(0) else string(v-sum-sum,"->>,>>9.99") ).
    hw:insert-attribute ("v-sum-VATsum",if v-sum-VATsum = ? then string(0) else string(v-sum-VATsum,"->>,>>9.99")  ).
    hw:insert-attribute ("v-sum-PlaceAmountDelt",if v-sum-PlaceAmountDelt = ? then string(0) else string(v-sum-PlaceAmountDelt,"->>,>>9.99")  ).
    hw:insert-attribute ("v-sum-SumDelt",if v-sum-SumDelt = ? then string(0) else string(v-sum-SumDelt,"->>,>>9.99")  ).
    
    

    for each tt-line no-lock:
        hw:start-element ("line").
        hw:insert-attribute ("gds-name", tt-line.gds-name). /*1 столбец*/
        hw:insert-attribute ("gds-code", string(tt-line.gds-code)). /*2 столбец*/
        hw:insert-attribute ("unit-name", tt-line.unit-name). /*4 столбец*/
        hw:insert-attribute ("unit-okei", tt-line.unit-okei). /*5 столбец*/
        hw:insert-attribute ("price-no-vat", string(tt-line.price-no-vat,"->>,>>9.99")). /*6 столбец*/
        hw:insert-attribute ("AmountInPlSupp", string(1.00,"->>,>>9.99") ). /*7 столбец*/
        hw:insert-attribute ("PlaceAmountSupp", string(tt-line.qnty-supp,"->>,>>9.99")). /*8 столбец*/
        hw:insert-attribute ("MassSupp", string(0.00,"->>,>>9.99") ). /*9 столбец*/
        hw:insert-attribute ("SumSupp", string(tt-line.sum-supp,"->>,>>9.99") ). /*11 столбец*/
        hw:insert-attribute ("AmountInPlFact", string(1.00,"->>,>>9.99") ). /*12 столбец*/
        hw:insert-attribute ("PlaceAmountFact", string(tt-line.qnty-fact,"->>,>>9.99")). /*13 столбец*/
        hw:insert-attribute ("MassFact", string(0.00,"->>,>>9.99") ). /*14 столбец*/
        hw:insert-attribute ("SumFact", string(tt-line.price-no-vat * tt-line.qnty-fact,"->>,>>9.99") ). /*16 столбец*/
        hw:insert-attribute ("Sum", string(tt-line.sum-fact-vat,"->>,>>9.99") ). /*17 столбец*/
        hw:insert-attribute ("VATpc", string(tt-line.vat,"->>,>>9.99") ). /*18 столбец*/
        hw:insert-attribute ("VATsum", string(tt-line.vat-sum,"->>,>>9.99") ). /*19 столбец*/       
        hw:insert-attribute ("AmountInPlDelt", string(1.00,"->>,>>9.99") ). /*20 столбец*/
        hw:insert-attribute ("PlaceAmountDelt", string(tt-line.qnty-fact - tt-line.qnty-supp,"->>,>>9.99") ). /*21 столбец*/
        hw:insert-attribute ("MassDelt", string(0.00,"->>,>>9.99") ). /*22 столбец*/
        hw:insert-attribute ("SumDelt", string((tt-line.qnty-fact - tt-line.qnty-supp) * tt-line.price-no-vat,"->>,>>9.99") ). /*24 столбец*/
        hw:insert-attribute ("sertif", if tt-line.sertif = ?  then "" else tt-line.sertif). 
        hw:end-element ("line").
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

