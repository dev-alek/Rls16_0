block-level on error undo, throw.
/*

$Revision: dbdad9a0f884, 2613, rls $
$Author: EShklyar $
$Date: Пн окт 19 09:22:02 2020 +0300 $
$Workfile: r-chk_anul.p $
$Archive: rep/r-chk_anul.p $

Отчет по аннуляции строки/отмене товара

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

define variable vss-revision as character no-undo init "$Revision: dbdad9a0f884, 2613, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пн окт 19 09:22:02 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-chk_anul.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-chk_anul.p $":U .
define variable vss-description as character no-undo init "Отчет по аннуляции строки/отмене товара".
{ cmp/vssrevis.i }


define input parameter parparentproc           as handle           no-undo .
define input parameter p-casier                as logical          no-undo .

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i      }
{ cmp/r-pril.i   }
{ ref/cp-attr.i }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }        

FUNCTION GdsName RETURNS CHARACTER
  ( input p-gds-code as integer)  FORWARD.

FUNCTION CashName RETURNS CHARACTER
  ( input p-cash-code as integer)  FORWARD.
    
define temp-table tt-check no-undo
    field obj-code    as integer
    field chk-date    like ub.chk-doc.chk-date
    field obj-type    as character
    field obj-name    as character
    field shift-corr  as character
    field shift-num   as character
    field shift-date  as character
    field shift-close as character
    field cash-num    as integer
    field chk-num     as character
    field num-z       as integer 
    field time-chk    as character
    field chk-type    as integer
    field chk-sum     as character
    field chk-qnty    as character
    field pay-type    as character
    field sum-paytype as decimal
    field gds-code    as integer
    field gds-name    as character
    field cashier     as character
    INDEX pi obj-code obj-type chk-num pay-type
    .

define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define VARIABLE v-attr-value        as character no-undo .
define variable v-obj-type          as character no-undo .
define variable v-obj-code          as integer   no-undo .
define variable v-obj-name          as character no-undo .
define variable v-period            as character no-undo .
define variable v-list-obj          as character no-undo .
define variable v-print-date        as character no-undo .
define variable v-osnov-corr        as character no-undo .
define variable v-date-corr         as character no-undo .
define variable v-num-corr          as character no-undo .
define variable v-create-shift-num  as integer   no-undo .
define variable v-create-shift-date as date      no-undo .
define variable v-shift-status      as character no-undo .
define variable ii                  as integer   no-undo .
define buffer buf_chk-doc      for ub.chk-doc .
define buffer bf_chk-doc       for ub.chk-doc .
define buffer buf_chk-doc-attr for ub.chk-doc-attr .
define buffer buf_shift-obj    for ub.shift-obj .
define buffer buf_chk-pay      for ub.chk-pay . 
define buffer buf_tt-check     for tt-check .
define buffer buf_clients      for ub.clients .
define buffer buf_chk-gds      for ub.chk-gds .
define variable v-check-type      as character no-undo .
define variable v-osnov-corr_name as character no-undo .
define variable v-date-corr_name  as character no-undo .
define variable v-num-corr_name   as character no-undo .
define variable v-shift           as character no-undo .
define variable v-change          as character no-undo .
define variable v-create-time     as character no-undo .
define variable v-create-date     as character no-undo .
define variable v-cashier         as character no-undo .

define stream Out-Stream.
define stream OutStr-html.

do
    on error undo, return error return-value
    :

    find first obj-list no-error .
    if not available obj-list then 
    do:
        message
            "Не указан объект для формирования отчета!"
            view-as alert-box error.
        undo, return error.
    end.
  
    DEFINE VARIABLE v-dop   AS character NO-UNDO .
    DEFINE VARIABLE v-value AS character NO-UNDO.
    DEFINE VARIABLE v-type  AS character NO-UNDO.

    /*Данные для шапки*/
    /*Период*/
    if x-TOG-Shift then 
    do:
        v-period = "Смены с " + string (x-Shift-Start) + " по " + string (x-Shift-End) + " За период с " + string (x-Date-Start,"99.99.9999") + " по " + string (x-Date-End,"99.99.9999") .
    end.
    else 
    do:
        v-period = "За период с " + string (x-Date-Start,"99.99.9999") + " по " + string (x-Date-End,"99.99.9999") .
    end.      
    /*Название объекта*/
    run clients-write(INPUT v-cntxt-host-code-obj, INPUT {&cmp}, OUTPUT v-obj-name) no-error .    
    /*Дата и время печати*/
    DEFINE VARIABLE v-today as date    no-undo .
    DEFINE VARIABLE v-time  as integer no-undo .
    run cur-time in this-procedure (
        output v-today
        , output v-time
        ).
    v-print-date = "Дата печати: " + string (v-today,"99.99.9999") + ", время: " + string(truncate (v-time / 3600, 0)) + ":" + string((v-time modulo 3600) / 60,"99")  + ":" + string((v-time modulo 3600) / 360,"99").     
 
    /*  if p-check-type <> "" then v-check-type = "Тип чека: " + ChkType(integer(p-check-type)) .                  */
    /*  else v-check-type = "По всем типам чеков" .                                                                */
    /*  if p-osnov-corr <> "0" then v-osnov-corr_name = "Документ основания: " + OsnovCorr(integer(p-osnov-corr)) .*/
    /*  if p-date-corr <> ? then v-date-corr_name = "Дата документа основания: " + string(p-date-corr) .           */
    /*  if p-num-corr <> "" then v-num-corr_name = "Номер документа основания: " + p-num-corr .                    */

    /*  if p-check-type = "" then p-check-type = {&receipt-codes-combo} .*/
  
    /*  case p-shift:                       */
    /*    when 0 then                       */
    /*      v-shift = "По всем сменам" .    */
    /*    when 1 then                       */
    /*      v-shift = "По закрытым сменам" .*/
    /*    when 2 then                       */
    /*      v-shift = "По открытым сменам" .*/
    /*  end case.                           */

    for each obj-list no-lock:
        if v-list-obj = "" then v-list-obj = string(obj-list.obj-code).
        else v-list-obj = v-list-obj + ", " + string(obj-list.obj-code).

        if x-TOG-Shift then 
        do:
            for each buf_chk-doc no-lock 
                where buf_chk-doc.obj-code = obj-list.obj-code 
                and buf_chk-doc.obj-type = obj-list.obj-type
                and buf_chk-doc.shift-date >= x-Date-Start 
                and buf_chk-doc.shift-date <= x-Date-End
                and (buf_chk-doc.chk-type = integer({&rcpt-sale}) 
                or buf_chk-doc.chk-type = integer({&rcpt-return})
                or buf_chk-doc.chk-type = integer({&rcpt-return-write-off}))
/*                and buf_chk-doc.out-code <> ?*/
                    :
                if (buf_chk-doc.shift-date = X-date-Start)
                    and (buf_chk-doc.shift-num < x-Shift-Start) then next. 
                if (buf_chk-doc.shift-date = X-date-End)
                    and (buf_chk-doc.shift-num > x-Shift-End) then next.
                          
                run report .
            end.
        end.
        else 
        do:
            for each buf_chk-doc no-lock 
                where buf_chk-doc.obj-code = obj-list.obj-code 
                and buf_chk-doc.obj-type = obj-list.obj-type
                and buf_chk-doc.chk-date >= x-Date-Start 
                and buf_chk-doc.chk-date <= x-Date-End
                and (buf_chk-doc.chk-type = integer({&rcpt-sale}) 
                or buf_chk-doc.chk-type = integer({&rcpt-return})
                or buf_chk-doc.chk-type = integer({&rcpt-return-write-off}))
/*                and buf_chk-doc.out-code <> ?*/
                :
                run report .
            end.  
        end.  
    
  end.


    /*печать*/

    run get-report-num (output p-report-id).
    
    v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
    ii = 0 .                  
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
        '<td style="width: 100px;"></td>' skip
        '<td style="width: 100px;"></td>' skip
        '<td style="width: 100px;"></td>' skip
        '<td style="width: 100px;"></td>' skip
        '<td style="width: 100px;"></td>' skip
        '<td style="width: 150px;"></td>' skip
        '<td style="width: 200px;"></td>' skip
        '<td style="width: 200px;"></td>' skip
        '<td style="width: 100px;"></td>' skip
        '</tr>' skip
        .
                        
 
    put stream OutStr-html unformatted
        '<TR><TD colspan="9"></TD></TR>' skip
        '<TR>' skip
        '<TD colspan="9" style="font-weight: bold;">Отчет по аннуляции строки/отмене товара</TD>' skip
        '</TR>'skip
                                
        '<TR>' skip
        '<TD colspan="9">' + v-period + '</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="9">' + v-obj-name + '</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="9">Выбор объекта:</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="9">' + "АЗК №" + v-list-obj + " маг" + '</TD>' skip
        '</TR>'skip

        '<TR>' skip
        '<TD colspan="9">' + v-print-date + '</TD>' skip
        '</TR>'skip
        .

    put stream OutStr-html unformatted
        '</thead>' skip
        '<tbody>' skip
        .
    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true" style="text-align: center;">№ смены</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">Дата смены</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">№ кассы</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">№ чека</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">Код товара</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">Наименование товара</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">Кол-во отмененных/аннулированных позиций в чеке</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">Сумма отмененных/аннулированных позиций в чеке</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">Кассир</TD>' skip
        '</TR>'skip       
                    
        .
    if p-casier then do:
    for each buf_tt-check by buf_tt-check.cashier by buf_tt-check.shift-date :
        if v-cashier <> buf_tt-check.cashier then do:
        put stream OutStr-html unformatted
            '<TR>' skip
            '<TD text_wrap="true" colspan = "9" style="text-align: left;">' + string(buf_tt-check.cashier) + '</TD>' skip
            '</TR>'skip     
            .
        end.  
        v-cashier = buf_tt-check.cashier .
        put stream OutStr-html unformatted
            '<TR>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.shift-num) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.shift-date) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.cash-num) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.chk-num) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.gds-code) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.gds-name) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.chk-qnty) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(buf_tt-check.chk-sum),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(buf_tt-check.chk-sum),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.cashier) + '</TD>' skip
            '</TR>'skip     
            .
    end.
    end.
    else do:    
    for each buf_tt-check by buf_tt-check.shift-date:

        put stream OutStr-html unformatted
            '<TR>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.shift-num) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.shift-date) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.cash-num) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.chk-num) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.gds-code) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.gds-name) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.chk-qnty) + '</TD>' skip
            '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(decimal(buf_tt-check.chk-sum),"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(decimal(buf_tt-check.chk-sum),"->>>>>>>>>>>9.99",2) + '</TD>' skip
            '<TD text_wrap="true" style="text-align: center;">' + string(buf_tt-check.cashier) + '</TD>' skip
            '</TR>'skip     
            .
    end.
    end.

        put stream OutStr-html unformatted

            '</table>' skip
            '</body>' skip
            '</html>' skip
            .
                            
        output stream OutStr-html close.     
                                                                                                                
        run prn-lib-reportviewer-report-name in this-procedure (
            input THIS-PROCEDURE
            ,input v-file-name-rep-htm
            ).
            
end .

function GDSName returns character 
        (input p-gds-code as integer):
/*------------------------------------------------------------------------------
        Purpose: Возвращает logical, топливный товар или нет
        Notes:
------------------------------------------------------------------------------*/    

define variable result as character no-undo.

find first ub.goods no-lock where ub.goods.gds-code = p-gds-code no-error .

if available (ub.goods) then result = ub.goods.gds-name .
else result = "" .
return result.

end function.

function CashName returns character 
        (input p-cash-code as integer):
/*------------------------------------------------------------------------------
        Purpose: Возвращает logical, топливный товар или нет
        Notes:
------------------------------------------------------------------------------*/    

define variable result as character no-undo.
define buffer buf_clients for ub.clients .
define buffer buf_staff for ub.staff .

find first buf_staff no-lock where buf_staff.staff-code = p-cash-code
                               and buf_staff.role = {&role-cashier} no-error .
if AVAILABLE (buf_staff) then do:
    find first buf_clients no-lock where buf_clients.obj-code = buf_staff.psn-code
                                     and buf_clients.obj-type = {&prs} no-error .
    result = buf_clients.obj-name .                                     
end.                                    
return result.

end function.

PROCEDURE get-report-num :

    define output parameter p-report-num as integer no-undo .
    do
        on error undo, return error return-value
        :
        run gbl/getrpnum.p (output p-report-num).
    end.

END PROCEDURE.

/*Общие данные*/
procedure report:

    for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code:
        if buf_chk-doc.chk-type <> integer({&rcpt-sale}) and buf_chk-gds.doc-qnty > 0 then do: 
            create tt-check .
        assign
            tt-check.obj-code    = buf_chk-doc.obj-code
            tt-check.chk-date    = buf_chk-doc.chk-date
            tt-check.chk-type    = buf_chk-doc.chk-type
            tt-check.shift-num   = string(buf_chk-doc.shift-num)
            tt-check.shift-date  = string(buf_chk-doc.shift-date)
            tt-check.cash-num    = buf_chk-doc.pay-desk
            tt-check.chk-num     = string(buf_chk-doc.doc-code)
            tt-check.num-z       = buf_chk-doc.z-number
            tt-check.time-chk    = string(buf_chk-doc.chk-date,"99.99.9999") + " " + string(buf_chk-doc.chk-time,"HH:MM:SS")
            tt-check.gds-code    = buf_chk-gds.b-code
            .
            tt-check.gds-name    = GDSName(tt-check.gds-code) . 
            .
            tt-check.cashier    = CashName(buf_chk-doc.cashier) .
            tt-check.chk-sum     = "-" + string(buf_chk-gds.sum-base) .
            tt-check.chk-qnty    = "-" + string(buf_chk-gds.doc-qnty) .
        end.
        if buf_chk-doc.chk-type = integer({&rcpt-sale}) and buf_chk-gds.doc-qnty < 0 then do:             
        create tt-check .
        assign
            tt-check.obj-code    = buf_chk-doc.obj-code
            tt-check.chk-date    = buf_chk-doc.chk-date
            tt-check.chk-type    = buf_chk-doc.chk-type
            tt-check.shift-num   = string(buf_chk-doc.shift-num)
            tt-check.shift-date  = string(buf_chk-doc.shift-date)
            tt-check.cash-num    = buf_chk-doc.pay-desk
            tt-check.chk-num     = string(buf_chk-doc.doc-code)
            tt-check.num-z       = buf_chk-doc.z-number
            tt-check.time-chk    = string(buf_chk-doc.chk-date,"99.99.9999") + " " + string(buf_chk-doc.chk-time,"HH:MM:SS")
            tt-check.gds-code    = buf_chk-gds.b-code
            .
            tt-check.gds-name    = GDSName(tt-check.gds-code) . 
            .
            tt-check.cashier    = CashName(buf_chk-doc.cashier) .
            tt-check.chk-sum     = string(abs(buf_chk-gds.sum-base)) .
            tt-check.chk-qnty    = string(abs(buf_chk-gds.doc-qnty)) .
        end.     
    end.
end procedure .

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

