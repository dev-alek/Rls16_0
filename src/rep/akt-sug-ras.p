/*

$Revision: 34480d5fe7d9, 3332, rls $
$Author: SSlivenko $
$Date: 2023/05/19 13:37:09 $
$Workfile: akt-sug.p $
$Archive: rep/akt-sug.p $

Акт приема СУГ

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

using ibs.th.str.*.
block-level on error undo, throw.

define variable vss-revision    as character no-undo init "$Revision: 34480d5fe7d9, 3332, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/19 13:37:09 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: akt-sug.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/akt-sug.p $":U .
define variable vss-description as character no-undo init "Акт приема СУГ".
{ cmp/vssrevis.i }

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
&global-define month-list-for-date 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря':U
/* Для вызова функции конвертации даты к виду: "01 Января 2014г" */
&scop f-l MonthNameRusCase

{ gbl/std-func.i {&f-l} }
define stream out-stream.

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ rep/w-rep.i    }
{ rep/fmtcli.i   }
{ rep/torgconf.i }
{ str/getctxtp.i def }
{ gbl/paramls.i  }
{ ref/gds-attr.i }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }
{ str/is-sug.i }
{ str/placelib.i }
{ rep/spr-sug.i  }
{ rep/c-temp-place.i }
{ rep/c-place-attr.i }
    
define variable is-petrolium         as logical   no-undo.
define variable is-pieces            as logical   no-undo.
define variable v-doc-code           like ub.trn-doc.doc-code no-undo .
define variable v-gds-code           like ub.goods.gds-code no-undo .
define variable v-fio                as character no-undo .
define variable v-InfoSectionsTotal  as class     InfoSectionsTotal no-undo .
define variable v-InfoSection        as class     InfoSection       no-undo .
define variable iNum                 as integer   no-undo .
define variable jj                   as integer   no-undo .
define variable v-producer           as character no-undo .
define variable v-obj-name           as character no-undo .
define variable v-driver             as character no-undo .       
define variable v-car-num            as character no-undo .          
define VARIABLE v-gds-name           as character no-undo .        
define VARIABLE v-num-prob           as character no-undo .
DEFINE VARIABLE v-norm-doc           as character no-undo .
define VARIABLE v-kol-prob           as decimal   no-undo .
define VARIABLE v-tank-vol           as decimal   no-undo .
DEFINE VARIABLE v-tank-density       as DECIMAL   no-undo .
define VARIABLE v-tank-weight        as decimal   no-undo .
define variable v-tank-temp          as decimal   no-undo .
define variable v-date-prob          as date      no-undo .
define variable v-ship-date          as date      no-undo .
define variable v-hour-prob          as integer   no-undo .
define variable v-min-prob           as integer   no-undo .
define VARIABLE v-obj-adress         as character no-undo .
define VARIABLE v-carrier            as character no-undo .
define variable v-date-prob-propis   as character no-undo .
define VARIABLE v-meneger            as character no-undo .
define VARIABLE v-manager-position   as character no-undo .
define VARIABLE v-fio-position       as character no-undo .
define VARIABLE v-num-print-prob     as character no-undo .
define VARIABLE v-time-income        as character no-undo .
define VARIABLE v-hour-income        as character no-undo .
define VARIABLE v-min-income         as integer   no-undo .
define variable v-DD-Month-YYYY      as character no-undo .
define variable v-DD-Month-YYYY-cert as character no-undo.
define variable v-condition          as character no-undo .
define variable v-inspection-cert    as character no-undo .
define variable v-seals              as character no-undo .
define variable v-seals-condition    as character no-undo .
define variable v-seals-condition-2  as character no-undo .
define variable v-date-cert          as character no-undo .
define variable v-nakl               as character no-undo .
define variable v-date               as character no-undo .
define variable v-car-vol            as integer   no-undo .
define variable v-mouth              as integer   no-undo .
define variable v-doc-not            as character no-undo .
define variable v-spisok-doc         as character no-undo .         
define variable v-attr-type          as character no-undo .
define variable v-num-ac             as character no-undo .
define variable v-komis              as logical   no-undo .    
define variable v-time-start         as integer   no-undo .
define variable v-time-end           as integer   no-undo .
define variable v-min-start          as integer   no-undo .
define variable v-min-end            as integer   no-undo .
define variable v-fact-qnty-before   as decimal   no-undo .
define variable v-fact-qnty-after    as decimal   no-undo .
define variable v-date-pasport       as date      no-undo .
define variable v-num-pasport        as character no-undo .
define variable v-dids               as date      no-undo .
define variable v-nids               as character no-undo .
define variable v-number-car         as character no-undo .
define variable v-date-income        as character no-undo .
define variable v-date-incomeD       as date      no-undo .
define variable ii                   as integer   no-undo .
define variable reason-code          as logical   no-undo .
define variable gate-valve           as logical   no-undo .
define variable NunHoses             as integer   no-undo .

define variable v-volue-AC           as decimal   no-undo .
define variable v-value              as character no-undo.
define variable v-ok                 as logical   no-undo.
define variable v-com-tanks          as character no-undo .
define variable v-main-tanks         as character no-undo .
define variable v-num-com-tanks      as integer   no-undo .

define variable vBlowdown            as decimal   no-undo .
define variable vFittings            as decimal   no-undo .
define variable vEmptying            as decimal   no-undo .
define variable vRefund              as decimal   no-undo .
define variable vCtrlvalve           as decimal   no-undo .
define variable pol14                as decimal   no-undo .
define variable vneftbaza            as character no-undo .
define variable vautopred            as character no-undo .    
define variable v-neftbaza           as character no-undo .
define variable v-autopred           as character no-undo .  
define stream Out-Stream.
define stream OutStr-html.

define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define VARIABLE v-attr-value        as character no-undo .
define variable v-obj-type          as character no-undo .
define variable v-obj-code          as integer   no-undo .
define variable v-mark-sug          as character no-undo .
define variable varvalue            as character no-undo .
define variable vartype             as character no-undo .
define buffer buf_trn-doc       for ub.trn-doc.
define buffer buf_doc-line      for ub.doc-line.
define buffer buf_doc-line-attr for ub.doc-line-attr.
define buffer buf_doc-attr      for ub.doc-attr.
define buffer buf_goods         for ub.goods.
define buffer buf_rvs-line      for ub.rvs-line.
define buffer buf_rvs-doc       for ub.rvs-doc.
define buffer buf_clients       for ub.clients.
define buffer buf_firm          for ub.firm.
define buffer buf_shop          for ub.shop.
define buffer buf_doc-pl        for ub.doc-pl.
define buffer buf_auto-tank     for ub.auto-tank .
define buffer buf_place         for ub.place .

    
define TEMP-TABLE tt-petrol no-undo
    field date-TH                 as character
    field num-TH                  as character
    field type-AC                 as character
    field num-AC                  as character
    field name-AC                 as character
    field btutto-qnty-AC          as decimal
    field name-gds                as character
    field vol-TH                  as Decimal
    field density-TH              as decimal
    field temp-TH                 as decimal
    field weight-TH               as decimal
    field urov-AC                 as character
    field vol-AC                  as decimal
    field density-AC              as decimal
    field temp-AC                 as decimal
    field weight-AC               as decimal
    field passport                as character
    field passport-date           as date
    field limit                   as decimal
    field deficit                 as decimal
    field ACCPomi                 as decimal
    field excess                  as decimal
    field weight-pri              as decimal
    field weight-est              as decimal
    field num-pl                  as character
    field num-section             as integer
    field komis-priem             as logical
    field before-measure-cli-qnty as decimal
    field after-measure-cli-qnty  as decimal
    field masDol                  as decimal
    field after-temp              as decimal
    field pol8                    as decimal
    field pol9                    as decimal
    field pol10                   as decimal
    field pol11                   as decimal
    index num-TH num-section passport type-AC num-AC .
        
define buffer buf_tt-petrol for tt-petrol .   

do
    on error undo, return error return-value
    :

    find first buf_trn-doc no-lock
        where recid( buf_trn-doc ) = rec_id.
    /*Общие данные*/
    
    /*Название объекта*/
    run clients-write(INPUT buf_trn-doc.obj-code,INPUT buf_trn-doc.obj-type,OUTPUT v-obj-name) no-error .    
    /*Адрес*/
    find first buf_shop no-lock where buf_shop.obj-code = buf_trn-doc.obj-code no-error .
    if AVAILABLE buf_shop then 
    do:
        v-obj-adress = buf_shop.addres1 .        
    end.    
        
    
    /*Название поставщика*/
    /*  run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-ptbobj},OUTPUT v-attr-value) no-error .
      if v-attr-value <> "" then 
      do: 
        assign
          v-obj-code = integer (entry (2, v-attr-value, ";"))
          v-obj-type = entry (1, v-attr-value, ";")
          .
        run clients-write(INPUT v-obj-code,INPUT v-obj-type,OUTPUT v-producer) no-error .
      end.
      else 
      do: */
    assign
        v-obj-code = buf_trn-doc.cli-code
        v-obj-type = buf_trn-doc.cli-type
        .
    run clients-write(INPUT v-obj-code,INPUT v-obj-type,OUTPUT v-producer) no-error .
    /* end. */   
    /*Водитель-экспедитор*/
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-fio-driver},OUTPUT v-driver) no-error .
    /* Грузоотправитель */
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-ptbobj},OUTPUT v-neftbaza) no-error .
    run clients-write(INPUT integer(entry(2,v-neftbaza,';')), INPUT (entry(1,v-neftbaza,';')), OUTPUT vneftbaza) .
    /* Перевозчик */
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-autoent},OUTPUT v-autopred) no-error .
    run clients-write(INPUT integer(entry(2,v-autopred,';')), INPUT (entry(1,v-autopred,';')), OUTPUT vautopred) no-error .
    /* Государственный номер АЦ */
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-car-num},OUTPUT v-number-car) no-error .  
    /*Дата прибытия*/   
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-date-income},OUTPUT v-date-incomeD) no-error .
    if v-date-incomeD <> ? then v-date-income = string(v-date-incomeD,"99.99.99") . 
    else v-date-income = "" .
    /*Время прибытия*/                                        
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-time-income},OUTPUT v-time-income) no-error .
    v-hour-income = v-time-income no-error.
    /*Время начала слива*/
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-time-start},OUTPUT v-time-income) no-error .
    v-time-start = integer(substring(v-time-income, 1, 2)) no-error.
    v-min-start = integer(substring(v-time-income, 4, 2)) no-error. 
    /*Время окнчания слива*/
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-time-end},OUTPUT v-time-income) no-error .
    v-time-end = integer(substring(v-time-income, 1, 2)) no-error.
    v-min-end = integer(substring(v-time-income, 4, 2)) no-error. 

    /*Техническое состояние*/
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-condition},OUTPUT v-condition) no-error .
    /*Пломбы от, дата свидетельства о поверке*/
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-date-cert},OUTPUT v-date-cert) no-error .
    if v-date-cert <> ? and v-date-cert <> "" then 
    do:
        run get-DD-month-YYYY(input v-date-cert, output v-DD-Month-YYYY-cert).
    end.
    else v-DD-Month-YYYY-cert = "".
    /*Паспорт качества № и дата*/
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-date-pasport},OUTPUT v-date-pasport) no-error .
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-num-pasport},OUTPUT v-num-pasport) no-error .
    /* ТТН № и дата составления */
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-dids},OUTPUT v-dids) no-error .
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-nids},OUTPUT v-nids) no-error .  
    /*с №№№ свидетельство о поверке и их состояние*/
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-inspection-cert},OUTPUT v-inspection-cert) no-error .
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-seals-condition},OUTPUT v-seals) no-error .
    if v-seals <> "" then 
    do:
        assign
            v-seals-condition = entry (1, v-seals, {&delim-par}) .
        v-seals-condition-2 = entry (2, v-seals, {&delim-par}) no-error . 
    end.              
    /*Менеджер*/
    run person-write(INPUT buf_trn-doc.boss, OUTPUT v-meneger, output v-manager-position) no-error .
    /*Оператор*/
    run person-write(INPUT buf_trn-doc.creid, OUTPUT v-fio, output v-fio-position) no-error .
    if v-fio = "?" then v-fio = "" .
    /*Автопредприятие*/
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-autoent},OUTPUT v-attr-value) no-error .
    if v-attr-value <> "" then 
    do:
        assign
            v-obj-code = integer (entry (2, v-attr-value, ";"))
            v-obj-type = entry (1, v-attr-value, ";")
            .
        run clients-write(INPUT v-obj-code,INPUT v-obj-type,OUTPUT v-carrier) no-error .
    end.
    /* Объем АЦ */
    find first buf_doc-attr no-lock where buf_doc-attr.attr-code = {&trdcattr-car-num}
        and buf_doc-attr.doc-code = buf_trn-doc.doc-code no-error .
    if available (buf_doc-attr) then 
    do:
        find first buf_auto-tank no-lock where 
            buf_auto-tank.auto-num = buf_doc-attr.attr-value no-error .
        if available (buf_auto-tank) then v-volue-AC = buf_auto-tank.brutto-qnty .
    end.
    /*Дата прописью*/
    run get-DD-month-YYYY(input buf_trn-doc.doc-date, output v-DD-Month-YYYY).
    /*Документы НЕ предоставленные*/    
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-spisok-not-doc},OUTPUT v-attr-value) no-error .
    if v-attr-value = "" then v-doc-not = "ПРЕДОСТАВЛЕНЫ" .
    else 
    do:
        assign 
            v-doc-not    = "НЕ ПРЕДОСТАВЛЕНЫ" 
            v-spisok-doc = v-attr-value .
    end. 
    assign
        v-fact-qnty-before = 0
        v-fact-qnty-after  = 0 
        .
    for first buf_rvs-doc no-lock where buf_rvs-doc.out-code = buf_trn-doc.doc-code and buf_rvs-doc.rvs-type = {&rvs-before-doc},
        each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code:
        v-fact-qnty-before = v-fact-qnty-before + buf_rvs-line.state-measure-cli-qnty .
    end.    
    for first buf_rvs-doc no-lock where buf_rvs-doc.out-code = buf_trn-doc.doc-code and buf_rvs-doc.rvs-type = {&rvs-after-doc},
        each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code:
        v-fact-qnty-after = v-fact-qnty-after + buf_rvs-line.state-measure-cli-qnty .
    end.    
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code:
        for first ub.goods no-lock where ub.goods.artic = buf_doc-line.artic and
            ub.goods.prod-code = buf_doc-line.prod-code and
            ub.goods.prod-type = buf_doc-line.prod-type:
            v-mark-sug = v-mark-sug + ", " + ub.goods.gds-name .
        end.
    end.  
    v-mark-sug = trim(v-mark-sug,",") .       
    v-InfoSectionsTotal = new InfoSectionsTotal().
    v-InfoSection = new InfoSection().
        
         
    /*печать*/
    run get-report-num (output p-report-id).
    
    v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
                        
    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
    put stream OutStr-html unformatted
        "<!DOCTYPE HTML>" skip
        ' <html>' skip
        '  <head>' skip
        '   <meta charset="utf-8">' skip
        '    <style type="text/css">' skip
                        
        '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
        '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
        '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
        '   </style>' skip
        '  </head>' skip
        .
                        
                        
    put stream OutStr-html unformatted
        '<body>' skip
        /*Первая таблица*/
        '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        .
    put stream OutStr-html unformatted
        '<tr class="set_columns">' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '<td style="width: 80px;"></td>' skip
        '</tr>' skip
        .
      
    put stream OutStr-html unformatted
        '<TR><TD colspan="14"></TD></TR>' skip
                            
        '<TR>' skip
        '<TD colspan="4" style="height: 14px; text-align: center;">' + v-obj-name + '</TD>' skip
        '<TD colspan="4"></TD>' skip
        '<TD colspan="6" style="text-align: right;"></TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="4" style="border-top: 1px solid black; text-align: center;">АГЗС</TD>' skip
        '<TD colspan="4"></TD>' skip
        '<TD colspan="6" style="text-align: right;"></TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style=""></TD>' skip
        '<TD colspan="4"></TD>' skip
        '<TD colspan="5" style="text-align: center;">УТВЕРЖДАЮ</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style="height: 14px;"></TD>' skip
        '<TD colspan="4"></TD>' skip
        '<TD colspan="5" style="text-align: center;"></TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style=""></TD>' skip
        '<TD colspan="4"></TD>' skip
        '<TD colspan="5" style="text-align: center; border-top: 1px solid black;">должность, Ф.И.О. руководителя АГЗС</TD>' skip
        '</TR>'skip

        /*  '<TR>' skip
          '<TD colspan="5" style=""></TD>' skip
          '<TD colspan="4"></TD>' skip
          '<TD colspan="5" style="text-align: center;">' + string(v-DD-Month-YYYY) + '</TD>' skip
          '</TR>'skip
      */
        '<TR><TD colspan="14" style="height: 14px;"></TD></TR>' skip
                            
        '<TR><TD colspan="14" style="font-weight: bold; text-align: center;">АКТ</TD></TR>' skip
                            
        '<TR><TD colspan="14" style="font-weight: bold; text-align: center;">приема СУГ</TD></TR>' skip
                            
        '<TR><TD colspan="14" style="font-weight: bold; text-align: center;">' + string(v-DD-Month-YYYY) + '</TD></TR>' skip
                    
        '<TR><TD colspan="14" style="height: 14px;"></TD></TR>' skip
                            
        '<TR>' skip
        '<TD colspan="5" style="">Составлен о том, что</TD>' skip
        '<TD colspan="9" style="height: 14px; text-align: center;">' + v-fio-position + "   " + v-fio + '</TD></TR>' skip
                    
        '<TR>' skip
        '<TD colspan="5" style=""></TD>' skip
        '<TD colspan="9" style="height: 14px; border-top: 1px solid black; text-align: center;">должность, Ф.И.О.(полностью), работника АГЗС (членов комиссии)</TD></TR>' skip
                    
        '<TR><TD colspan="14" style="height: 14px;"></TD></TR>' skip
                    
        '<TR>' skip
        '<TD colspan="5" style="">В присутствии водителя АЦ</TD>' skip
        '<TD colspan="9" style="text-align: center;">' + v-driver + '</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style=""></TD>' skip
        '<TD colspan="9" style="border-top: 1px solid black; text-align: center;">Ф.И.О.</TD>' skip
        '</TR>'skip
                    
        '<TR><TD colspan="14" style="">составили настоящий акт о нижеследующем:</TD></TR>' skip
                    
        '<TR><TD colspan="14" style="height: 14px;"></TD></TR>' skip
                    
        '<TR>' skip
        '<TD colspan="5" style="">1. Наименование поставщика:</TD>' skip
        '<TD colspan="9" style="text-align: center;">' + v-producer + '</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style="height: 14px;"></TD>' skip
        '<TD colspan="9" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style="">1.1. Наименование грузоотправителя:</TD>' skip
        '<TD colspan="9" style="text-align: center;">' + vneftbaza + '</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style="height: 14px;"></TD>' skip
        '<TD colspan="9" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '</TR>'skip
    
        '<TR>' skip
        '<TD colspan="5" style="">1.2. Наименование перевозчика:</TD>' skip
        '<TD colspan="9" style="text-align: center;">' + vautopred + '</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style="height: 14px;"></TD>' skip
        '<TD colspan="9" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '</TR>'skip
    
        '<TR>' skip
        '<TD colspan="5" style="">2. Марка СУГ:</TD>' skip
        '<TD colspan="9" style="text-align: center;">' + v-mark-sug + '</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style="height: 14px;"></TD>' skip
        '<TD colspan="9" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style="">3. Паспорт кач. №, дата:</TD>' skip
        '<TD colspan="9" style="text-align: center;">' + v-num-pasport + " от " + if v-date-pasport <> ? then string (v-date-pasport,"99.99.99") else "" + '</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style="height: 14px;"></TD>' skip
        '<TD colspan="9" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style="">4. ТТН №, дата составления:</TD>' skip
        '<TD colspan="9" style="text-align: center;">' + v-nids + " от " + string (v-dids,"99.99.99") + '</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style="height: 14px;"></TD>' skip
        '<TD colspan="9" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style="">5. Гос. регистр. знаки АЦ:</TD>' skip
        '<TD colspan="9" style="text-align: center;">' + v-number-car + '</TD>' skip
        '</TR>'skip
    
        '<TR>' skip
        '<TD colspan="5" style="height: 14px;"></TD>' skip
        '<TD colspan="9" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '</TR>'skip
                                
        '<TR>' skip
        '<TD colspan="5" style="">6. Дата и время прибытия АЦ</TD>' skip .
    if v-hour-income <> '' and v-date-income <> '' then 
    do:
        put stream OutStr-html unformatted
            '<TD colspan="9" style="text-align: center;">' + string (v-date-income) + ", " + string(v-hour-income) + '</TD>' skip .
    end.
    else 
    do:
        put stream OutStr-html unformatted
            '<TD colspan="9" style="text-align: center;">' + string (v-date-income) + " " + string(v-hour-income) + '</TD>' skip .
    end.
    put stream OutStr-html unformatted
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style="height: 14px;"></TD>' skip
        '<TD colspan="9" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style="">7. Объем АЦ, (геометр, л)</TD>' skip
        '<TD colspan="9" style="text-align: center;">' + string(v-volue-AC) + '</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style="height: 14px;"></TD>' skip
        '<TD colspan="9" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '</TR>'skip
                        
        '<TR>' skip
        '<TD colspan="5" style="">8. Техническое состояние АЦ</TD>' skip
        '<TD colspan="9" style="text-align: center;">' + v-condition + '</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="5" style=""></TD>' skip
        '<TD colspan="9" style="border-top: 1px solid black; text-align: center;">исправное, неисправное (с указанием конкретных замечаний)</TD>' skip
        '</TR>'skip
                    
        '<TR><TD colspan="14" style="height: 14px;"></TD></TR>' skip
                    
        '<TR>' skip
        '<TD colspan="4">9. Пломбы от ' + v-DD-Month-YYYY-cert + '</TD>' skip
        '<TD style="text-align: right;">c № </TD>' skip
        '<TD colspan="3" style="text-align: center;">' + string(v-seals-condition) + '</TD>' skip
        '<TD></TD>' skip
        '<TD colspan="5" style="text-align: center;">' + string(v-seals-condition-2) + '</TD>' skip
        '</TR>'skip
        '<TR>' skip
        '<TD colspan="4"></TD>' skip
        '<TD></TD>' skip
        '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '<TD></TD>' skip
        '<TD colspan="5" style="border-top: 1px solid black; text-align: center;">нарушены (не нарушены)</TD>' skip
        '</TR>'skip
        
        '<TR>' skip
        '<TD colspan="10" style="height: 14px;"></TD>' skip
        '</TR>'skip
                    
        '<TR>' skip
        '<TD colspan="14" style="height: 14px;">10. Наличие документов: ' + v-doc-not + ' в полном комплекте и с соответствующими отметками.</TD>' skip
        '</TR>'skip                    
        .
    if v-doc-not = "НЕ ПРЕДОСТАВЛЕНЫ" then 
    do:
        put stream OutStr-html unformatted
            '<TR>' skip
            '<TD colspan="10" style="height: 14px;">Не предоставлены: ' + v-spisok-doc + '</TD>' skip
            '</TR>'skip                    
            .
    end.
                     
    put stream OutStr-html unformatted                         


        '<TR><TD colspan="18" style="height: 14px;"></TD></TR>' skip
        '</thead>' skip
        '<tbody>' skip
        .



  /*Сбор данных*/

  /*По накладной*/
  /*Номер ТТН (ТН)*/
    { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-nids} v-attr-value v-attr-type }
    if v-attr-value > "" then 
    do :
        assign 
            v-nakl = v-attr-value .
    end .
    else 
    do :
        assign 
            v-nakl = buf_trn-doc.doc-code .
    end.                    
  /*Дата ТТН (ТН)*/
    { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-dids} v-attr-value v-attr-type }
    if v-attr-value > "" then v-date = v-attr-value.
    else 
    do :
        if integer(substring(string(date(buf_trn-doc.doc-date), "99/99/9999") , 1, 2)) > 12
            then v-date = string(date(buf_trn-doc.doc-date), "99/99/9999").
        else v-date = substring(string(date(buf_trn-doc.doc-date), "99/99/9999") , 4, 3)
                + substring(string(date(buf_trn-doc.doc-date), "99/99/9999") , 1, 3)
                + substring(string(date(buf_trn-doc.doc-date), "99/99/9999") , 7, 4).
    end.
    /*Тип АЦ - не известно*/
    
    /*Номер АЦ*/
    run doc-attr-write(INPUT buf_trn-doc.doc-code,INPUT {&trdcattr-car-num},OUTPUT v-car-num) no-error .
        
    for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code :  

        find first buf_goods where buf_goods.artic = buf_doc-line.artic
            and buf_goods.prod-code = buf_doc-line.prod-code
            and buf_goods.prod-type = buf_doc-line.prod-type no-lock no-error.
        if AVAILABLE buf_goods and is-sug(buf_goods.gds-code) then 
        do:
            assign
                v-doc-code = buf_trn-doc.doc-code
                .
            if buf_goods.engl-name = "" or buf_goods.engl-name = ? then v-gds-name = buf_goods.gds-name . 
            else v-gds-name = buf_goods.engl-name .
                         
                               
                                      
            v-InfoSectionsTotal:Initialization(v-doc-code, buf_goods.gds-code).
            v-InfoSectionsTotal:GetDBAllAttr().

            do iNum = 1 to v-InfoSectionsTotal:SectionNum:
                assign
                    v-num-prob       = v-InfoSectionsTotal:GetInfoSectionProp(iNum):Tests
                    v-norm-doc       = v-InfoSectionsTotal:GetInfoSectionProp(iNum):NormDoc
                    v-kol-prob       = v-InfoSectionsTotal:GetInfoSectionProp(iNum):KolProb
                    v-tank-vol       = v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankVol
                    v-tank-density   = v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankDensity 
                    v-tank-weight    = v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankWeight / 1000 
                    v-tank-temp      = v-InfoSectionsTotal:GetInfoSectionProp(iNum):DensTemp
                    v-date-prob      = v-InfoSectionsTotal:GetInfoSectionProp(iNum):DateProb
                    v-hour-prob      = v-InfoSectionsTotal:GetInfoSectionProp(iNum):HourProb
                    v-min-prob       = v-InfoSectionsTotal:GetInfoSectionProp(iNum):MinProb
                    v-num-print-prob = v-InfoSectionsTotal:GetInfoSectionProp(iNum):NumPrintProb
                    v-car-vol        = v-InfoSectionsTotal:GetInfoSectionProp(iNum):CarVol
                    v-mouth          = v-InfoSectionsTotal:GetInfoSectionProp(iNum):Mouth
                    .

                create tt-petrol .
                assign
                    tt-petrol.num-TH      = v-nakl
                    tt-petrol.date-TH     = string(buf_trn-doc.doc-date,"99/99/9999")
                    tt-petrol.num-AC      = v-car-num
                    tt-petrol.num-section = v-InfoSectionsTotal:SectionNum
                    tt-petrol.weight-TH   = buf_doc-line.cli-qnty .
          
                assign
                    tt-petrol.weight-AC = v-fact-qnty-after - v-fact-qnty-before .
                .  

                find first buf_rvs-doc no-lock where buf_rvs-doc.out-code = buf_trn-doc.doc-code and
                    buf_rvs-doc.rvs-type = {&rvs-before-doc} no-error .
                if available (buf_rvs-doc) then 
                do:
                    for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code and
                        buf_rvs-line.gds-code = buf_goods.gds-code:
                        
                        /*            if get-input-type(recid(buf_rvs-doc)) <> 'а' then tt-petrol.before-measure-cli-qnty = tt-petrol.before-measure-cli-qnty + buf_rvs-line.state-measure-cli-qnty .*/
                        /*            else                                                                                                                                                           */
                        tt-petrol.before-measure-cli-qnty = tt-petrol.before-measure-cli-qnty + buf_rvs-line.state-measure-cli-qnty .

                    end.
                end. 
                find first buf_rvs-doc no-lock where buf_rvs-doc.out-code = buf_trn-doc.doc-code and
                    buf_rvs-doc.rvs-type = {&rvs-after-doc} no-error .
                if available (buf_rvs-doc) then 
                do:
                    for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code and
                        buf_rvs-line.gds-code = buf_goods.gds-code :
                        ii = ii + 1 .

                        /*            if get-input-type(recid(buf_rvs-doc)) <> 'а' then do:                                                      */
                        /*            tt-petrol.after-measure-cli-qnty = tt-petrol.after-measure-cli-qnty + buf_rvs-line.state-measure-cli-qnty .*/
                        /*            tt-petrol.after-temp = tt-petrol.after-temp + buf_rvs-line.state-temperature .                             */
                        /*            end.                                                                                                       */
                        /*            else do:                                                                                                   */
                        tt-petrol.after-measure-cli-qnty = tt-petrol.after-measure-cli-qnty + buf_rvs-line.state-measure-cli-qnty .
                        tt-petrol.after-temp = tt-petrol.after-temp + buf_rvs-line.state-temperature .
                    /*            end.*/
                    end.
                    tt-petrol.after-temp = tt-petrol.after-temp / ii .
                    tt-petrol.vol-TH = tt-petrol.after-measure-cli-qnty - tt-petrol.before-measure-cli-qnty .
                    for first buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
                        and buf_doc-line-attr.gds-code = buf_goods.gds-code
                        and buf_doc-line-attr.attr-code = "propan-perc":
                        tt-petrol.masDol = decimal (buf_doc-line-attr.attr-value) .                                    
                    end.
                    NunHoses = getNunHoses(buf_trn-doc.doc-code) .
                    run doc-line-value(buf_trn-doc.doc-code, "blowdown", ub.goods.gds-code, output vBlowdown) .
                    run doc-line-value(buf_trn-doc.doc-code, "fittings", ub.goods.gds-code, output vFittings) .
                    run doc-line-value(buf_trn-doc.doc-code, "emptying", ub.goods.gds-code, output vEmptying) .
                    run doc-line-value(buf_trn-doc.doc-code, "refund", ub.goods.gds-code, output vRefund) .
                    run doc-line-value(buf_trn-doc.doc-code, "ctrlvalve", ub.goods.gds-code, output vCtrlvalve) .
          
                    define variable massa-sug as character no-undo .
                    define variable teh-loss  as character no-undo .
                    define variable err-allow as character no-undo .
          
                    { str/tdat-val.i
     buf_trn-doc.doc-code
     {&sugtpattr-teh-loss}
     teh-loss
     vartype
     no-error
  }
                    { str/tdat-val.i
     buf_trn-doc.doc-code
     {&sugtpattr-err-allow}
     err-allow
     vartype
     no-error
  }
                    { str/tdat-val.i
     buf_trn-doc.doc-code
     {&sugtpattr-massa-sug}
     massa-sug
     vartype
     no-error
  }  

                    if buf_trn-doc.reason-code = 99 and (teh-loss <> "" or err-allow <> "" or massa-sug <> "") then reason-code = true .
                    tt-petrol.pol8 = decimal (teh-loss) + vBlowdown + vFittings + vEmptying + vRefund + vCtrlvalve .
                    if buf_trn-doc.reason-code = 99 then tt-petrol.pol9 = tt-petrol.weight-TH - tt-petrol.vol-TH - decimal(massa-sug).
            

                    tt-petrol.pol10 = (sqrt(exp((tt-petrol.after-measure-cli-qnty * 0.65), 2) + exp((tt-petrol.before-measure-cli-qnty * 0.65), 2)) / 100) +  decimal (err-allow).
                    tt-petrol.pol11 = tt-petrol.pol9 - tt-petrol.pol8 - tt-petrol.pol10 .
                    pol14 = sqrt(exp((tt-petrol.after-measure-cli-qnty * 0.65), 2) + exp((tt-petrol.before-measure-cli-qnty * 0.65), 2)) / 100 .
                    if tt-petrol.pol11 < 0 then tt-petrol.pol11 = 0 .
              
                end.      
            end.   
            if tt-petrol.num-AC <> "" then 
            do:
                for first ub.auto-tank no-lock where ub.auto-tank.auto-num = tt-petrol.num-AC and
                    ub.auto-tank.status_ = {&current-status}:
                    assign
                        tt-petrol.name-AC        = ub.auto-tank.name
                        tt-petrol.btutto-qnty-AC = ub.auto-tank.brutto-qnty
                        .
                end.  
                if tt-petrol.name-AC <> "" then v-num-ac = tt-petrol.name-AC + "," .
                v-num-ac = v-num-ac + tt-petrol.num-AC .
                if tt-petrol.btutto-qnty-AC <> ? then v-num-ac = v-num-ac + "," + string(tt-petrol.btutto-qnty-AC) .
            end. 

            for first buf_doc-pl no-lock where buf_doc-pl.out-code = buf_doc-line.doc-code
                and buf_doc-pl.gds-code = buf_goods.gds-code:
                for first ub.place no-lock where ub.place.pl-code = buf_doc-pl.pl-code:

                    gate-valve = get_com-vessel(buf_trn-doc.obj-code,
                        buf_trn-doc.obj-type,
                        {&place-gate-valve},
                        ub.place.pl-code, 
                        buf_trn-doc.doc-date, 
                        buf_trn-doc.fact-date, 
                        0, 
                        buf_trn-doc.fact-time) . 

                    run placelib_get-attr  ( input {&place-twice-code}
                        ,input ub.place.obj-code
                        ,input ub.place.obj-type
                        ,input ub.place.pl-code
                        ,output v-value
                        ,output v-ok      ) no-error.
                    if v-value <> "" then  tt-petrol.num-pl = string(ub.place.loc1) + "," + v-value .
                    else tt-petrol.num-pl = string(ub.place.loc1) .
          
                    run placelib_get-attr  ( input {&place-com-tanks}
                        ,input ub.place.obj-code
                        ,input ub.place.obj-type
                        ,input ub.place.pl-code
                        ,output v-value
                        ,output v-ok      ) no-error.
                    if v-ok
                        and v-value > ""
                        then 
                    do :
                        tt-petrol.num-pl = tt-petrol.num-pl + "," + v-value .
                    end .
                end.
            end.  


        end.
    end.    /*      if is-petrolium        */
end.    /*        for each buf_doc-line     */

run print-table1 no-error .
                                        
       
put stream OutStr-html unformatted    
    '</tbody>' skip
    '<tfoot>' skip
                    
                   
    '<TR><TD colspan="14" style="height: 14px;"></TD></TR>' skip
                    
    '<TR><TD text_wrap="true" colspan="14" style="">11. Прилагаемые к акту документы ________________________________________________________________________</TD></TR>' skip
                    
    '<TR><TD text_wrap="true" colspan="14" style="">12. Время: начала ' + string((v-time-start),"99") + ':' + string ((v-min-start),"99") + '  окончания ' + string ((v-time-end),"99") + ':' + string ((v-min-end),"99") + ' слива.</TD></TR>' skip

    '<TR>' skip
    '<TD text_wrap="true" colspan="9" style="">13. Суммарные расчётные нормативные технологические потери при текущем сливе СУГ:</TD>' skip
    '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(vBlowdown + vEmptying + vFittings + vCtrlvalve + vRefund,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
    '<TD colspan="2" style="text-align: right;">из них:</TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="9" style="height: 14px;"></TD>' skip
    '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
    '<TD colspan="2" style="text-align: right;"></TD>' skip
    '</TR>'skip .             
if not logical (gate-valve) or gate-valve = ? then 
do:  
    put stream OutStr-html unformatted      
        '<TR>' skip
        '<TD></TD>' skip
        '<TD text_wrap="true" colspan="8" style="">13.1. при продувке резинотканевых рукавов для удаления воздуха:</TD>' skip
        '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(vBlowdown,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
        '<TD colspan="2" style="text-align: right;"></TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD></TD>' skip
        '<TD colspan="8" style="height: 14px;"></TD>' skip
        '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '<TD colspan="2" style="text-align: right;"></TD>' skip
        '</TR>'skip      

        '<TR>' skip
        '<TD></TD>' skip
        '<TD text_wrap="true" colspan="8" style="">13.2. при продувке СУГ участка арматуры между запорными устройствами резинотканевых рукавов и АЦ для удаления воздуха:</TD>' skip
        '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(vFittings,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
        '<TD colspan="2" style="text-align: right;"></TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD></TD>' skip
        '<TD colspan="8" style="height: 14px;"></TD>' skip
        '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '<TD colspan="2" style="text-align: right;"></TD>' skip
        '</TR>'skip   
    
        '<TR>' skip
        '<TD></TD>' skip
        '<TD text_wrap="true" colspan="8" style="">13.3. при опорожнении резинотканевых рукавов по окончании налива (слива) АЦ:</TD>' skip
        '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(vEmptying,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
        '<TD colspan="2" style="text-align: right;"></TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD></TD>' skip
        '<TD colspan="8" style="height: 14px;"></TD>' skip
        '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '<TD colspan="2" style="text-align: right;"></TD>' skip
        '</TR>'skip   
    
        '<TR>' skip
        '<TD></TD>' skip
        '<TD text_wrap="true" colspan="8" style="">13.4. при возврате АЦ:</TD>' skip
        '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(vRefund,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
        '<TD colspan="2" style="text-align: right;"></TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD></TD>' skip
        '<TD colspan="8" style="height: 14px;"></TD>' skip
        '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '<TD colspan="2" style="text-align: right;"></TD>' skip
        '</TR>'skip   
    
        '<TR>' skip
        '<TD></TD>' skip
        '<TD text_wrap="true" colspan="8" style="">13.5. при проверке уровня наполнения с помощью контрольного вентиля АЦ:</TD>' skip
        '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(vCtrlvalve,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
        '<TD colspan="2" style="text-align: right;"></TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD></TD>' skip
        '<TD colspan="8" style="height: 14px;"></TD>' skip
        '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
        '<TD colspan="2" style="text-align: right;"></TD>' skip
        '</TR>'skip .    
end.
else 
do:
    if gate-valve and NunHoses > 0 then 
    do:
        put stream OutStr-html unformatted        
            '<TR>' skip
            '<TD></TD>' skip
            '<TD text_wrap="true" colspan="8" style="">13.1. при продувке резинотканевых рукавов для удаления воздуха:</TD>' skip
            '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(vBlowdown,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip

            '<TR>' skip
            '<TD></TD>' skip
            '<TD colspan="8" style="height: 14px;"></TD>' skip
            '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip      

            '<TR>' skip
            '<TD></TD>' skip
            '<TD text_wrap="true" colspan="8" style="">13.2. при продувке СУГ участка арматуры между запорными устройствами резинотканевых рукавов и АЦ для удаления воздуха:</TD>' skip
            '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(vFittings,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip

            '<TR>' skip
            '<TD></TD>' skip
            '<TD colspan="8" style="height: 14px;"></TD>' skip
            '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip   
    
            '<TR>' skip
            '<TD></TD>' skip
            '<TD text_wrap="true" colspan="8" style="">13.3. при опорожнении резинотканевых рукавов по окончании налива (слива) АЦ:</TD>' skip
            '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(vEmptying,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip

            '<TR>' skip
            '<TD></TD>' skip
            '<TD colspan="8" style="height: 14px;"></TD>' skip
            '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip   
    
            '<TR>' skip
            '<TD></TD>' skip
            '<TD text_wrap="true" colspan="8" style="">13.4. при возврате АЦ:</TD>' skip
            '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(vRefund,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip

            '<TR>' skip
            '<TD></TD>' skip
            '<TD colspan="8" style="height: 14px;"></TD>' skip
            '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip   
    
            '<TR>' skip
            '<TD></TD>' skip
            '<TD text_wrap="true" colspan="8" style="">13.5. при проверке уровня наполнения с помощью контрольного вентиля АЦ:</TD>' skip
            '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(vCtrlvalve,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip

            '<TR>' skip
            '<TD></TD>' skip
            '<TD colspan="8" style="height: 14px;"></TD>' skip
            '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip .          
    end.
    else 
    do:
        put stream OutStr-html unformatted        
            '<TR>' skip
            '<TD></TD>' skip
            '<TD text_wrap="true" colspan="8" style="">13.1. при продувке резинотканевых рукавов для удаления воздуха:</TD>' skip
            '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(0,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip

            '<TR>' skip
            '<TD></TD>' skip
            '<TD colspan="8" style="height: 14px;"></TD>' skip
            '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip      

            '<TR>' skip
            '<TD></TD>' skip
            '<TD text_wrap="true" colspan="8" style="">13.2. при продувке СУГ участка арматуры между запорными устройствами резинотканевых рукавов и АЦ для удаления воздуха:</TD>' skip
            '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(0,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip

            '<TR>' skip
            '<TD></TD>' skip
            '<TD colspan="8" style="height: 14px;"></TD>' skip
            '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip   
    
            '<TR>' skip
            '<TD></TD>' skip
            '<TD text_wrap="true" colspan="8" style="">13.3. при опорожнении резинотканевых рукавов по окончании налива (слива) АЦ:</TD>' skip
            '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(0,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip

            '<TR>' skip
            '<TD></TD>' skip
            '<TD colspan="8" style="height: 14px;"></TD>' skip
            '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip   
    
            '<TR>' skip
            '<TD></TD>' skip
            '<TD text_wrap="true" colspan="8" style="">13.4. при возврате АЦ:</TD>' skip
            '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(vRefund,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip

            '<TR>' skip
            '<TD></TD>' skip
            '<TD colspan="8" style="height: 14px;"></TD>' skip
            '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip   
    
            '<TR>' skip
            '<TD></TD>' skip
            '<TD text_wrap="true" colspan="8" style="">13.5. при проверке уровня наполнения с помощью контрольного вентиля АЦ:</TD>' skip
            '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(vCtrlvalve,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip

            '<TR>' skip
            '<TD></TD>' skip
            '<TD colspan="8" style="height: 14px;"></TD>' skip
            '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
            '<TD colspan="2" style="text-align: right;"></TD>' skip
            '</TR>'skip .          
    end.
end.  
put stream OutStr-html unformatted    
    '<TR>' skip
    '<TD text_wrap="true" colspan="9" style="">14. Допустимая погрешность измерения на АГЗС:</TD>' skip
    '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(pol14,"->>>>>>>>>>>>>>>>>9.999") + '</TD>' skip
    '<TD colspan="2" style="text-align: right;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="9" style="height: 14px;"></TD>' skip
    '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
    '<TD colspan="2" style="text-align: right;"></TD>' skip
    '</TR>'skip  
    
    '<TR>' skip
    '<TD text_wrap="true" colspan="9" style="">15. Количество подключений/переподключений рукавов АЦ, осуществленный в ходе приема СУГ в резервуар АГЗС:</TD>' skip
    '<TD text_wrap="true" colspan="3" style="text-align: center;">' + string(NunHoses) + '</TD>' skip
    '<TD colspan="2" style="text-align: right;"></TD>' skip
    '</TR>'skip

    '<TR>' skip
    '<TD colspan="9" style="height: 14px;"></TD>' skip
    '<TD colspan="3" style="border-top: 1px solid black; text-align: center;"></TD>' skip
    '<TD colspan="2" style="text-align: right;"></TD>' skip
    '</TR>'skip  
                
    '<TR><TD colspan="14" style="height: 14px;"></TD></TR>' skip
                    
    '<TR>' skip
    '<TD colspan="3"></TD>'
    '<TD colspan="2" style="">Подпись (и)</TD>' skip
    '<TD text_wrap="true" colspan="7" style="text-align: center;">' + v-fio-position + " " + v-fio + '</TD>'
    '<TD colspan="2"></TD>'
    '</TR>'skip
                    
    '<TR>' skip
    '<TD colspan="3"></TD>'
    '<TD colspan="2" style=""></TD>' skip
    '<TD text_wrap="true" colspan="7" style="border-top: 1px solid black; text-align: center;">должность, Ф.И.О. работника АЗС/АЗК (членов комиссии)</TD>'
    '<TD colspan="2"></TD>'
    '</TR>'skip
                    
    '<TR>' skip
    '<TD colspan="3"></TD>'
    '<TD colspan="2" style="height: 14px;"></TD>' skip
    '<TD text_wrap="true" colspan="7" style="text-align: center;">' + v-driver + '</TD>'
    '<TD colspan="2"></TD>'
    '</TR>'skip
                    
    '<TR>' skip
    '<TD colspan="3"></TD>'
    '<TD colspan="2" style=""></TD>' skip
    '<TD text_wrap="true" colspan="7" style="border-top: 1px solid black; text-align: center;">Ф.И.О. водителя АЦ, подпись</TD>'
    '<TD colspan="2"></TD>'
    '</TR>'skip
    .
         
put stream OutStr-html unformatted
    '</tfoot>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
                            
output stream OutStr-html close.     
                                                                                                                
run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-htm
    ).


/* **********************  Internal Procedures  *********************** */
procedure doc-attr-write:
    
    DEFINE input PARAMETER   p-doc-code      as character    no-undo .
    DEFINE INPUT PARAMETER   p-attr-code     as character    no-undo .
    DEFINE OUTPUT PARAMETER  p-attr-value    as character    no-undo .
        
    find first buf_doc-attr no-lock where buf_doc-attr.doc-code = p-doc-code
        and buf_doc-attr.attr-code = p-attr-code no-error .
    if AVAILABLE buf_doc-attr then 
    do:
        p-attr-value = buf_doc-attr.attr-value .
    end.       
                                          
end.    

procedure person-write:
    
    DEFINE input PARAMETER   p-obj-code      as character    no-undo .
    DEFINE OUTPUT PARAMETER  p-obj-name      as character    no-undo .
    define OUTPUT PARAMETER  p-position      as CHARACTER    NO-UNDO .
    define variable v-name as character no-undo . 
    define buffer buf_user-account for ub.user-account .    
  
    /*run rep/get-psn.p(input p-obj-code, output p-obj-name ).*/
    find first buf_user-account no-lock where buf_user-account.user-id = p-obj-code no-error .
    if available (buf_user-account) then 
    do: 
        p-position = buf_user-account.position .
        p-obj-name = buf_user-account.last-name + " " + buf_user-account.first-name + " " + buf_user-account.second-name .
    end.  
                                          
end. 


procedure clients-write:
    
    DEFINE input PARAMETER   p-obj-code      as integer      no-undo .
    DEFINE INPUT PARAMETER   p-obj-type      as character    no-undo .
    DEFINE OUTPUT PARAMETER  p-obj-name      as character    no-undo .
        
    find first buf_clients no-lock where buf_clients.obj-code = p-obj-code
        and buf_clients.obj-type = p-obj-type no-error .
    if AVAILABLE buf_clients then 
    do:
        p-obj-name = buf_clients.obj-name .
    end.     
                                            
end. 


PROCEDURE get-report-num :

    define output parameter p-report-num as integer no-undo .

    do
        on error undo, return error return-value
        :
        run gbl/getrpnum.p (output p-report-num).
    end.

END PROCEDURE.

procedure get-DD-Month-YYYY:
    
    /* Получение даты в формате "01 Января 2014г." */
    define input parameter p-dat-date as date no-undo.
    define output parameter p-str-date as character no-undo.

    define variable v-str-date  as character no-undo.
    define variable v-str-day   as character no-undo.
    define variable v-num-month as character no-undo.
    define variable v-str-month as character no-undo.
    define variable v-str-year  as character no-undo.

    v-str-date = string(p-dat-date).

    do: /* Получаем день в формате цифры, вида NN. */
        v-str-day = string(entry(1, v-str-date, "/")).
    end. /* Получаем день в формате цифры, вида NN. */

    do: /* Получаем прописью месяц */
        v-num-month = entry(2, v-str-date, "/").
        v-str-month = MonthNameRusCase(integer(v-num-month), 2).

    end. /* Получаем прописью месяц */

    do: /* Получаем год в формате цифры, вида "NNNN" */
        /*        v-str-year = entry(3, v-str-date, "/").*/
        v-str-year = string(year(p-dat-date)).
    end. /* Получаем год в формате цифры, вида "NNNN" */

    /* Получаем цифро-буквенную дату в одной строке */
    p-str-date = '" ' + v-str-day + ' "' + " " + v-str-month + " " + v-str-year + " г.".

end procedure.


procedure print-table1:
    
    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true" colspan="2" style="text-align: center;">Масса СУГ по ТТН, кг</TD>' skip
        '<TD text_wrap="true" colspan="2" style="text-align: center;">Масса СУГ в резервуарах до слива, кг</TD>' skip
        '<TD text_wrap="true" colspan="2" style="text-align: center;">Масса СУГ в резервуарах после слива, кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">Количество СУГ, слитого в резервуары, кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">Температура слива СУГ, °С</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">Массовая доля пропана в смеси, %</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">№ резервуара, в который сливается СУГ</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">Допустимые технологические потери (суммарные, на поставку), кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">Разница между данными ТТН и результатами измерений (суммарная, на поставку), кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">Допустимая погрешность (суммарная, на поставку), кг</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">Недовоз СУГ (за поставку), кг</TD>' skip
        '</TR>'skip       
                    
        '<TR>' skip
        '<TD colspan="2" style="text-align: center;">1</TD>' skip
        '<TD colspan="2" style="text-align: center;">2</TD>' skip
        '<TD colspan="2" style="text-align: center;">3</TD>' skip
        '<TD style="text-align: center;">4</TD>' skip
        '<TD style="text-align: center;">5</TD>' skip
        '<TD style="text-align: center;">6</TD>' skip
        '<TD style="text-align: center;">7</TD>' skip
        '<TD style="text-align: center;">8</TD>' skip
        '<TD style="text-align: center;">9</TD>' skip
        '<TD style="text-align: center;">10</TD>' skip
        '<TD style="text-align: center;">11</TD>' skip
        '</TR>'skip     
        .
    for each tt-petrol:
        put stream OutStr-html unformatted
            '<TR>' skip
            '<TD colspan="2" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.weight-TH,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.weight-TH,"->>>>>>>>>>>9.999",3) + '</TD>' skip
            '<TD colspan="2" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.before-measure-cli-qnty,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.before-measure-cli-qnty,"->>>>>>>>>>>9.999",3) + '</TD>' skip
            '<TD colspan="2" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.after-measure-cli-qnty,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.after-measure-cli-qnty,"->>>>>>>>>>>9.999",3) + '</TD>' skip
            '<TD text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.vol-TH,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.vol-TH,"->>>>>>>>>>>9.999",3) + '</TD>' skip
            '<TD text_wrap="true" num="0" val="' + fnc-convert-dot-to-colon(tt-petrol.after-temp,"->>>>>>>>>>>9",0) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.after-temp,"->>>>>>>>>>>9",0) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-petrol.masDol,"->>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.masDol,"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(tt-petrol.num-pl) + '</TD>' skip .
        if reason-code then 
        do:
            put stream OutStr-html unformatted
                '<TD text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.pol8,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.pol8,"->>>>>>>>>>>9.999",3) + '</TD>' skip
                '<TD text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.pol9,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.pol9,"->>>>>>>>>>>9.999",3) + '</TD>' skip
                '<TD text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.pol10,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.pol10,"->>>>>>>>>>>9.999",3) + '</TD>' skip
                '<TD text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.pol11,"->>>>>>>>>>>9.999",3) + '" style="text-align: center;">' + fnc-convert-dot-to-colon(tt-petrol.pol11,"->>>>>>>>>>>9.999",3) + '</TD>' skip
                '</TR>'skip     
                .
        end.
        else 
        do:
            put stream OutStr-html unformatted
                '<TD></TD>' skip
                '<TD></TD>' skip
                '<TD></TD>' skip
                '<TD></TD>' skip
                '</TR>'skip     
                .
        end.
    end.
end procedure .


