block-level on error undo, throw.
/*

$Revision: 40e5534edb20, 59, rls $
$Author: AShutilov $
$Date: Thu Aug 28 16:27:53 2014 +0400 $
$Workfile: r-achmat.p $
$Archive: rep/r-achmat.p $

Отчет Акт на списание материалов ( для инвентаризации, факт )

Автор: Харитонов Владимир Александрович
Дата создания: 21/03/13
Author: Kharitonov Vladimir
Creation date: 21/03/13

#2789

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-rec-id      as recid. /* recid(trn-doc) */

define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_doc-line for ub.doc-line.
define buffer bf_inv-line for ub.inv-line.
define buffer bf_clients for ub.clients.
define buffer bf_goods for ub.goods.
define buffer bf_doc-line-sum for ub.doc-line-sum.
define buffer bf_trn-reason for ub.trn-reason.

define variable vss-revision    as character no-undo initial "$Revision: 40e5534edb20, 59, rls $":U .
define variable vss-author      as character no-undo initial "$Author: AShutilov $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Aug 28 16:27:53 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-achmat.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-achmat.p $":U .
define variable vss-description as character no-undo initial "Отчет Акт на списание материалов".

define variable g#gds-engl as logical   no-undo .
define variable g#log as logical   no-undo .
define variable g#quest-print as logical   no-undo .
define variable g#report-num as integer   no-undo .

define variable v-doc-qnty as decimal no-undo. /* кол-во всех товаров в накладной */
define variable v-doc-sum  as decimal no-undo. /* сумма по накладной */
define variable v-PropisSumall as character no-undo. /* Сумма прописью, формата: "Стро руб. 15 коп." */
define variable v-abbr as character no-undo.

define stream Out-Stream.

{ cmp/vssrevis.i     }
{ cmp/library.i         }
{ cmp/str-glbl.i     }
{ cmp/r-pril.i       }
{ str/trdcalib.i        }
{ str/in-vatp.i def     }
{ str/out-vatp.i def    }
{ rep/r-cliprp.i def    }
{ rep/fmtcli.i          }
{ gbl/clntattr.i        }
{ rep/torgconf.i        }
{ str/getctxtp.i def    }

/* для вывода в excel */
{ gbl/paramls.i }
{ rep/r-achmat-xl.i }

/* подготовка к созданию */
run prepare-rep.

/* пишем линии */
run write-lines.

/* пишем ячейки */
run write-cells.

/* формируем отчет */
run close-rep.

define shared variable no-vat  as logical no-undo.
define shared variable CostPrice as logical no-undo.

procedure prepare-rep:
    run get-gds-engl  in parParentProc ( output g#gds-engl ).
    run get-quest-print in parParentProc ( output g#quest-print ).
    run get-report-num  in parParentProc ( output g#report-num ).
    
    { cmp/open-out.i STREAM Out-Stream " " {&LS_PS_A4}  }
    run acmxl-init.
    
    put stream Out-Stream UNFORMATTED
        "Отчет доступен только в формате EXCEL"
    .
    
    find first bf_trn-doc
        where recid(bf_trn-doc) = p-rec-id
        no-lock.
end.

procedure close-rep:
    run acmxl-close.
    output stream Out-Stream CLOSE.
    { rep/q-print.i 8 }
end.

procedure write-cells:
    define variable v-host-code as integer no-undo.
/*    define variable v-qnty-str  as character no-undo.*/
    define variable v-sum-str as character no-undo.
    
    /* название объекта */
    find first bf_clients
        where bf_clients.obj-code = bf_trn-doc.obj-code
        and bf_clients.obj-type = bf_trn-doc.obj-type
        no-lock.    
    run acmxl-write-cell-data({&acmxl-obj_name}, bf_clients.obj-name).
    run acmxl-write-cell-data({&acmxl-obj_name_2}, bf_clients.obj-name).
    
    /* название фирмы */
    v-host-code = bf_clients.host-code.
    find first bf_clients
        where bf_clients.obj-code = v-host-code
        and bf_clients.obj-type = {&cmp}
        no-lock.
    run acmxl-write-cell-data({&acmxl-firm_name}, bf_clients.obj-name).
    
    /* код документа */    
    run acmxl-write-cell-data({&acmxl-doc_code}, /*"АКТ № " +*/ bf_trn-doc.doc-code).
    
    /* дата документа */
    run acmxl-write-cell-data({&acmxl-doc_date}, string(bf_trn-doc.doc-date, "99/99/99")).
    
    /* управляющий */
    if bf_trn-doc.wrkr <> ? then do:
        find first bf_clients
            where bf_clients.obj-code = bf_trn-doc.wrkr
            and bf_clients.obj-type = {&prs}
            no-lock.
        run acmxl-write-cell-data({&acmxl-mgr_name}, bf_clients.obj-name).
    end.
    
    /* администратор */
    if bf_trn-doc.agnt <> ? then do:
        find first bf_clients
            where bf_clients.obj-code = bf_trn-doc.agnt
            and bf_clients.obj-type = {&prs}
            no-lock.
        run acmxl-write-cell-data({&acmxl-performer_name}, bf_clients.obj-name).
    end.
    
    /* ст. оператор */
    if bf_trn-doc.boss <> ? then do:
        find first bf_clients
            where bf_clients.obj-code = bf_trn-doc.boss
            and bf_clients.obj-type = {&prs}
            no-lock.
        run acmxl-write-cell-data({&acmxl-stock_name}, bf_clients.obj-name).
    end.
    
    /* сумма Итого: */
    v-doc-sum = 0 - v-doc-sum. /* Инвертируем знак +/-. Специфика отображения при списании. */
    run acmxl-write-cell-data({&acmxl-sum_all}, v-doc-sum).

    /* Сумма прописью */
    run rep/wp-rub.p(input v-doc-sum, output v-PropisSumall, output v-abbr).
    run acmxl-write-cell-data({&acmxl-sum_str}, v-PropisSumall).

    /* Количество Итого: */
    v-doc-qnty = 0 - v-doc-qnty. /* Инвертируем знак +/-. Специфика отображения при списании. */
    run acmxl-write-cell-data({&acmxl-qnty_all}, v-doc-qnty).

/*    /* кол-во прописью */                                    */
/*    run gbl/num-rus.p(v-doc-qnty, output v-qnty-str).        */
/*    run acmxl-write-cell-data({&acmxl-qnty_str}, v-qnty-str).*/

end.

procedure write-lines:
    define variable v-line-num as integer no-undo.

    find first bf_trn-reason
        where bf_trn-reason.reason-code = bf_trn-doc.reason-code
        no-lock no-error.

    for each bf_doc-line
        where bf_doc-line.doc-code = bf_trn-doc.doc-code
        no-lock:
                
        find first bf_goods
            where bf_goods.artic = bf_doc-line.artic
            and bf_goods.prod-code = bf_doc-line.prod-code
            and bf_goods.prod-type = bf_doc-line.prod-type
            no-lock.
        
        find first bf_doc-line-sum
            where bf_doc-line-sum.doc-code = bf_trn-doc.doc-code
            and bf_doc-line-sum.gds-code = bf_goods.gds-code
            and bf_doc-line-sum.sum-type = {&sum-general-doc}
            no-lock.
            
        v-line-num = v-line-num + 1.
        
        /* Количество */
        v-doc-qnty = v-doc-qnty + bf_doc-line.fact-qnty.

        /*Сумма*/
        v-doc-sum = v-doc-sum + if no-vat then bf_doc-line-sum.cost-sum-rubl - bf_doc-line-sum.cost-VAT-rubl 
                                    else  if Costprice then bf_doc-line-sum.cost-sum-rubl
                                              else bf_doc-line-sum.crsa-sum-rubl.

        run acmxl-sheet1-write-line-data(
                v-line-num, /* номер строки */
                bf_goods.gds-name, /* название */
                bf_goods.artic, /* артикул */
                bf_trn-doc.fact-date, /* дата закрытия на факт */
                bf_goods.unit-base, /* ед. измерения */
/*                bf_goods.normal-wastage, /* норма (в доп. информацие по товару) */*/
                0 - bf_doc-line.fact-qnty, /* кол-во с инверсией знака. Такова логика отобр. знака при списании. */
                if bf_doc-line.fact-qnty = 0 then 0
                    else if no-vat then (bf_doc-line-sum.cost-sum-rubl - bf_doc-line-sum.cost-VAT-rubl) / bf_doc-line.fact-qnty
                             else if Costprice then bf_doc-line-sum.cost-sum-rubl / bf_doc-line.fact-qnty
                                      else bf_doc-line-sum.crsa-sum-rubl / bf_doc-line.fact-qnty , /* цена */
                if no-vat then 0 - (bf_doc-line-sum.cost-sum-rubl - bf_doc-line-sum.cost-VAT-rubl)
                    else if Costprice then 0 - (bf_doc-line-sum.cost-sum-rubl)
                             else 0 - (bf_doc-line-sum.crsa-sum-rubl), /* сумма ("0 - (сумма)" выдаёт инверсию знака. Такова логика отобр. знака при списании!)*/
                if avail bf_trn-reason then bf_trn-reason.reason-name else "" /* основание накладной */
            ).
    end. /* for each bf_doc-line */
end.
