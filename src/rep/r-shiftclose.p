block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Чек-лист по закрытию смены в ТН

Автор: Шкляр Елена
Дата создания: 04/29/10
Author: Elena Shklyar
Creation date: 04/29/10

*/
/*define input parameter parparentproc            as widget-handle           no-undo .*/
define input parameter pHostCode                as integer no-undo .
define input parameter custom-par               as character     no-undo . 
define input parameter pBorder                  as logical no-undo .
define input parameter pRas                     as logical no-undo .
define input parameter pPrint                   as logical no-undo .
define output parameter v-file-name-rep-htm     as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Чек-лист по закрытию смены в ТН".

define variable parparentproc        as widget-handle no-undo .

parparentproc = this-procedure .

/*{ cmp/vssrevis.i }*/
{ cmp/str-glbl.i     }
{ cmp/r-page0.i  new }
/*{ cmp/vssrevis.i     }*/
{ cmp/library.i }
/*{ cmp/r-page1.i  }*/
{ rep/html-conv.i }
{ gbl/prn-lib.i     }
/*{ ref/chk-type-desc.i }                                            */
/*{ gbl/usrfulnf.i }*/
/*{ gbl/getcntxt.i def }*/
/*{ gbl/getcntxt.i get }*/
{ cmp/breakstr.i }

define buffer buf_shiftParam    for ub.shift-param .

define buffer buf_shop          for ub.shop .
define buffer buf_clients       for ub.clients .
define buffer bf_shift-obj     for ub.shift-obj .
define buffer buf_goods         for ub.goods .
define buffer buf_usser-account for ub.user-account .
define buffer buf_rvs-line      for ub.rvs-line .
define buffer buf_rvs-doc       for ub.rvs-doc .
define buffer buf_susp-chk      for ub.susp-chk .

define variable p-report-id          as character no-undo .
define variable v-nn3                as integer   no-undo .
define variable Jv                   as integer   no-undo .
define variable userName             as character no-undo .


define variable rep-shift-for-mng    as character no-undo format "X(30)":U .
define variable rep-shift-for-mng1   as character no-undo format "X(30)":U .
define variable rep-shift-for-mng2   as character no-undo format "X(30)":U .
define variable rep-shift-for-opers  as character no-undo.
define variable rep-shift-for-opers1 as character no-undo format "X(44)":U .
define variable rep-shift-for-opers2 as character no-undo format "X(44)":U .

define variable v-nameHost           as character no-undo .
define variable dev-paid-trans       as decimal   no-undo .
define variable prc-dev-mass         as decimal   no-undo .
define variable X-OBJ-CODE as integer no-undo .
define variable X-OBJ-TYPE as character no-undo .

define stream Out-Stream.
define stream OutStr-html.


FUNCTION get-pay RETURNS CHARACTER
    ( input parpay-code as integer,  input parcurr-code as integer, output parcurr-name as character)  FORWARD.

function pr-objname returns character 
    (input p-obj-code as integer ) forward.

function Str-chk-type returns character
    (input p-chk-type as character) forward .

v-nn3 = NUM-ENTRIES(custom-par).
REPEAT Jv = 1 to v-nn3:
    if CAPS(trim(Entry(Jv,custom-par))) begins "X-DATE-START"      then  X-DATE-START  = date(Entry(2,Entry(Jv,custom-par ),"="))  .
    if CAPS(trim(Entry(Jv,custom-par))) begins "X-OBJ-CODE"        then  X-OBJ-CODE    = int(Entry(2,Entry(Jv,custom-par ),"=")) .
    if CAPS(trim(Entry(Jv,custom-par))) begins "X-SHIFT-START"     then  X-Shift-Start = int(Entry(2,Entry(Jv,custom-par ),"=")) .
    if CAPS(trim(Entry(Jv,custom-par))) begins "X-OBJ-TYPE"        then  X-OBJ-TYPE    = (Entry(2,Entry(Jv,custom-par ),"=")) .
End.
X-OBJ-TYPE = trim (X-OBJ-TYPE," ") .
 
define variable ii                  as integer   no-undo .

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

/*    { rep/htmlhead.i }*/
.

/*Наименование объекта*/
find first ub.clients no-lock where ub.clients.obj-code = pHostCode and ub.clients.obj-type = {&cmp} no-error .
if available (ub.clients) then v-nameHost = ub.clients.obj-name .

put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 200px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 150px;"></td>' skip
    '<td style="width: 350px;"></td>' skip
    '</tr>' skip
    .

find first bf_shift-obj no-lock where bf_shift-obj.obj-code = X-OBJ-CODE and
bf_shift-obj.obj-type = X-OBJ-TYPE and
bf_shift-obj.shift-date = date(X-Date-Start) and 
bf_shift-obj.Shift-num = X-Shift-Start no-error .
if not available (bf_shift-obj) then return error.
    
find first buf_usser-account no-lock where buf_usser-account.user-id = bf_shift-obj.close-id no-error .
if available (buf_usser-account) then 
do:
    userName = "АЗК №" + string(bf_shift-obj.obj-code) + {&new-line} + "Документ подписан ID - " + entry(2,buf_usser-account.user-id,"-") + {&new-line} + {&new-line} + 
        buf_usser-account.last-name + {&new-line} + buf_usser-account.first-name + {&new-line} + buf_usser-account.second-name .
end.
     
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="8" style="text-align: left;">АЗК №' + string(bf_shift-obj.obj-code) + ' </td>' skip
    '</tr>' skip  
    .

put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: center; font-weight: bold;">Чек-лист по закрытию смены Trade House</td>' skip 
    .
if pBorder then 
    put stream OutStr-html unformatted     
        '<td style="text-align: center; color:#7030a0; border-top: thick double #7030a0; border-left: thick double #7030a0; border-right: thick double #7030a0;">АЗК №' + string(bf_shift-obj.obj-code) + '</td>' skip
        '</tr>' skip  
        .
else 
    put stream OutStr-html unformatted     
        '<td>АЗК №' + string(bf_shift-obj.obj-code) + '</td>' skip
        '</tr>' skip  
        .
if pRas then do:
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: center; font-weight: bold;">смена закрыта с расхождениями</td>' skip
    .    
end.
else do:
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: center; font-weight: bold;">смена закрыта без расхождений</td>' skip
    .   
end.    
if pBorder then 
    put stream OutStr-html unformatted   
        '<td style="text-align: center; color:#7030a0; border-left: thick double #7030a0; border-right: thick double #7030a0;">Документ подписан ID - ' + entry(2,buf_usser-account.user-id,"-") + '</td>' skip
        '</tr>' skip  
        .
else 
    put stream OutStr-html unformatted     
        '<td>Документ подписан ID - ' + entry(2,buf_usser-account.user-id,"-") + '</td>' skip
        '</tr>' skip  
        .
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: left;">Смена: ' + string(bf_shift-obj.shift-num) + ' от ' + string(bf_shift-obj.open-date,"99.99.9999") + " " + string(bf_shift-obj.open-time,"hh:mm") + '</td>' skip
    .
if pBorder then 
    put stream OutStr-html unformatted   
        '<td style="text-align: center; color:#7030a0; border-left: thick double #7030a0; border-right: thick double #7030a0;"></td>'
        '</tr>' skip  
        .
else 
    put stream OutStr-html unformatted     
        '<td></td>' skip
        '</tr>' skip  
        .
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: left;">Закрыта: ' + string(bf_shift-obj.close-date,"99.99.9999") + " " + string(bf_shift-obj.close-time,"hh:mm") + '</td>' skip
    .
if pBorder then 
    put stream OutStr-html unformatted   
        '<td style="text-align: center; border-right: thick double #7030a0; border-left: thick double #7030a0; color:#7030a0;">' + buf_usser-account.last-name + '</td>'
        '</tr>' skip  
        .
else 
    put stream OutStr-html unformatted     
        '<td>' + buf_usser-account.last-name + '</td>' skip
        '</tr>' skip  
        .
                
FOR EACH ub.shift-staff No-LOCK WHERE
    ub.shift-staff.obj-type = bf_shift-obj.obj-type AND
    ub.shift-staff.obj-code = bf_shift-obj.obj-code AND
    ub.shift-staff.shift-date = bf_shift-obj.shift-date AND
    ub.shift-staff.shift-num  = bf_shift-obj.shift-num AND
    ub.shift-staff.next-shift = no AND
    ub.shift-staff.staff-role = yes and
    ub.shift-staff.psn-num    >= 0 :
    if lookup( {&space-char} + ub.shift-staff.name, rep-shift-for-mng ) = 0 then 
    do:
        assign
            rep-shift-for-mng = rep-shift-for-mng + (if rep-shift-for-mng > '' then {&comma-char} else "")  + ub.shift-staff.name
            .
    end.
end.

if rep-shift-for-mng > '' then
    assign
        rep-shift-for-mng1 = entry (1, rep-shift-for-mng, {&comma-char})
              no-error.
    
    
put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: left;">Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
    .
if pBorder then 
    put stream OutStr-html unformatted   
        '<td style="text-align: center; border-right: thick double #7030a0; border-left: thick double #7030a0; color:#7030a0;">' + buf_usser-account.first-name + '</td>'
        '</tr>' skip  
        .
else 
    put stream OutStr-html unformatted     
        '<td>' + buf_usser-account.first-name + '</td>' skip
        '</tr>' skip  
        .
                
FOR EACH ub.shift-staff No-LOCK WHERE
    ub.shift-staff.obj-type   = bf_shift-obj.obj-type AND
    ub.shift-staff.obj-code   = bf_shift-obj.obj-code AND
    ub.shift-staff.shift-date = bf_shift-obj.shift-date AND
    ub.shift-staff.shift-num  = bf_shift-obj.shift-num AND
    ub.shift-staff.next-shift = no AND
    ub.shift-staff.staff-role = no and
    ub.shift-staff.psn-num    >= 0 :
    if lookup( {&space-char} + ub.shift-staff.name, rep-shift-for-opers ) = 0 then 
    do:
        assign
            rep-shift-for-opers = rep-shift-for-opers + (if rep-shift-for-opers > '' then {&comma-char} else "")  + ub.shift-staff.name
            .
    end.
end.

if rep-shift-for-opers > '' then
    assign
        rep-shift-for-opers1 = entry (1, rep-shift-for-opers, {&comma-char})
              no-error.


if num-entries (rep-shift-for-opers, {&comma-char}) >= 2 then
    assign
        rep-shift-for-opers2 = entry (2, rep-shift-for-opers, {&comma-char})
              no-error.

rep-shift-for-opers =  breakstr(rep-shift-for-opers, 44, input-output rep-shift-for-opers1, input-output rep-shift-for-opers2).

put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: left;">Операторы: ' + rep-shift-for-opers + '</td>' skip
    .
if pBorder then 
    put stream OutStr-html unformatted   
        '<td style="text-align: center; border-bottom: thick double #7030a0; border-right: thick double #7030a0; border-left: thick double #7030a0; color:#7030a0;">' + buf_usser-account.second-name + '</td>'
        '</tr>' skip  
        .
else 
    put stream OutStr-html unformatted     
        '<td>' + buf_usser-account.second-name + '</td>' skip
        '</tr>' skip  
        .
        
put stream OutStr-html unformatted
    '<tr style="height:25px;">' skip
    '<td colspan="8" style="text-align: left;"></td>' skip
    '</tr>' skip  
    .
put stream OutStr-html unformatted
    '</thead>' skip .
  
put stream OutStr-html unformatted
    '<tbody>' skip
    '<TR style="height:55px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: center; font-weight:bold;">Проверка отклонений по 1 части сменного отчета. Отклонение между расчетной и фактической массой топлива на конец смены.</TD>' skip
    '</tr>' skip
    '<tr>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ резервуара</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Расч. остаток на конец смены, кг</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Факт. остаток на конец смены, кг</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Допустимое отклонение, кг</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Факт. отклонение по остаткам, кг</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Превышение допустимого отклонения на, кг</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Причина расхождения/номер заявки в ЦДС</TD>' skip
    '</TR>'skip
    .
              
define variable v-error as decimal no-undo .
for each buf_shiftParam no-lock 
    where buf_shiftParam.obj-code = bf_shift-obj.obj-code 
    and buf_shiftParam.obj-type = bf_shift-obj.obj-type
    and buf_shiftParam.shift-date = bf_shift-obj.shift-date
    and buf_shiftParam.shift-num = bf_shift-obj.shift-num:       
    find first buf_goods no-lock where buf_goods.gds-code = buf_shiftParam.gds-code no-error .
    if not available (buf_goods) then next .
    v-error = absolute(buf_shiftParam.dev-mass - buf_shiftParam.diff-stock-end).
    if buf_shiftParam.diff-stock-end <= v-error then v-error = 0 .
    
    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true">' + buf_goods.gds-name + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_shiftParam.loc1) + '</TD>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.system-cli-qnty,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.system-cli-qnty <> ? then fnc-convert-dot-to-colon(buf_shiftParam.system-cli-qnty,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.fact-stock-end,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.fact-stock-end <> ? then fnc-convert-dot-to-colon(buf_shiftParam.fact-stock-end,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.dev-mass,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.dev-mass <> ? then fnc-convert-dot-to-colon(buf_shiftParam.dev-mass,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.diff-stock-end,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.diff-stock-end <> ? then fnc-convert-dot-to-colon(buf_shiftParam.diff-stock-end,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-error,">>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if v-error <> ? then fnc-convert-dot-to-colon(v-error,">>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_shiftParam.disc-diffMass) + '</TD>' skip
        '</tr>' skip
        .
end.
v-error  = 0 .
find first buf_shiftParam no-lock where buf_shiftParam.obj-code = bf_shift-obj.obj-code and
    buf_shiftParam.obj-type = bf_shift-obj.obj-type and
    buf_shiftParam.shift-date = bf_shift-obj.shift-date and
    buf_shiftParam.shift-num = bf_shift-obj.shift-num and 
    buf_shiftParam.gds-code = 0 and
    buf_shiftParam.pl-code = 0 no-error .
if available (buf_shiftParam) then
    assign
        dev-paid-trans = buf_shiftParam.dev-paid-trans
        prc-dev-mass   = buf_shiftParam.prc-dev-mass
        .


put stream OutStr-html unformatted
    '<thead>' skip
    '<TR  style="height:25px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: left;">* Процент допустимого отклонения массы топлива = ' + string(prc-dev-mass,"9.99") + '%</TD>' skip
    '</tr>' skip
    '<TR  style="height:25px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: left;"></TD>' skip
    '</tr>' skip         
    '<TR  style="height:25px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: left;"></TD>' skip
    '</tr>' skip     
    '</thead>' skip
    .

put stream OutStr-html unformatted
    '<TR style="height:55px;">' skip
    '<TD text_wrap="true" height:25px; colspan="8" style="text-align: center; font-weight:bold;">Проверка отклонений по 9 части сменного отчета. Отклонения между объемом продаж топлива на кассе и объемом по счетчикам ТРК.</TD>' skip
    '</tr>' skip
    '<tr>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ резервуара</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Объем продаж на кассе, л</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Объем продаж по счетчикам ТРК, л</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Техпролив, л</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Разница по кассе и ТРК, л</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Превышение допустимого отклонения на, л</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Причина расхождения/номер заявки в ЦДС</TD>' skip
    '</TR>'skip
    .
              
for each buf_shiftParam no-lock 
    where buf_shiftParam.obj-code = bf_shift-obj.obj-code 
    and buf_shiftParam.obj-type = bf_shift-obj.obj-type
    and buf_shiftParam.shift-date = bf_shift-obj.shift-date
    and buf_shiftParam.shift-num = bf_shift-obj.shift-num
    :        
    find first buf_goods no-lock where buf_goods.gds-code = buf_shiftParam.gds-code no-error .
    if not available (buf_goods) then next .
    v-error = absolute(buf_shiftParam.dev-paid-trans - buf_shiftParam.diff-cash-trk) .
    if dev-paid-trans >= v-error then v-error = 0 .
    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true">' + buf_goods.gds-name + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_shiftParam.loc1) + '</TD>' skip
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.cash-qnty,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.cash-qnty <> ? then fnc-convert-dot-to-colon(buf_shiftParam.cash-qnty,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.meas-qnty,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.meas-qnty <> ? then fnc-convert-dot-to-colon(buf_shiftParam.meas-qnty,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.tech-refuell,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.tech-refuell <> ? then fnc-convert-dot-to-colon(buf_shiftParam.tech-refuell,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_shiftParam.diff-cash-trk,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if buf_shiftParam.diff-cash-trk <> ? then fnc-convert-dot-to-colon(buf_shiftParam.diff-cash-trk,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(v-error,">>>>>>>>>>>>>9.99",2) + '" style="text-align: center;">' + if v-error <> ? then fnc-convert-dot-to-colon(v-error,">>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip 
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_shiftParam.disc-diffTRK) + '</TD>' skip
        '</tr>' skip
        .
end.
       
put stream OutStr-html unformatted
    '<thead>' skip
    '<TR style="height:25px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: left;">*Допустимое отклонение между объемом продаж топлива на кассе и объемом по счетчикам ТРК = ' + string(dev-paid-trans,"9.99") + 'л</TD>' skip
    '</tr>' skip
    '<TR style="height:25px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: left;"></TD>' skip
    '</tr>' skip         
    '<TR style="height:25px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: left;"></TD>' skip
    '</tr>' skip  
    '</thead>' skip  
    .


put stream OutStr-html unformatted
    '<TR style="height:55px;">' skip
    '<TD text_wrap="true" colspan="8" style="text-align: center; font-weight:bold;">"Подозрительные" чеки.</TD>' skip
    '</tr>' skip
    '<tr>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Признак</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ чека в ТН</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Тип чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ чека на кассе</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">№ кассы</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Дата/время</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Причина возникновения чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Ссылка на "корректный" чек</TD>' skip
    '</TR>' skip
    .
        

for each buf_susp-chk no-lock 
    where buf_susp-chk.obj-code = bf_shift-obj.obj-code
    and buf_susp-chk.obj-type = bf_shift-obj.obj-type
    and buf_susp-chk.shift-date = bf_shift-obj.shift-date
    and buf_susp-chk.shift-num = bf_shift-obj.shift-num:       

    put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true" style="text-align: center;">' + buf_susp-chk.office + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.doc-code) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + Str-chk-type(string(buf_susp-chk.chk-type)) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.chk-num) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.pay-desk) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.chk-date,"99.99.9999") + '/' + string(buf_susp-chk.chk-time,"hh:mm") + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.reason-name) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(buf_susp-chk.link-chk) + '</TD>' skip
        '</tr>' skip
        .
end.
            


put stream OutStr-html unformatted
    '</tbody>' skip .
  
  
procedure pr-foot:        
    put stream OutStr-html unformatted
  
        '</table>' skip
        '</body>' skip
        '</html>' skip
        .
end.  
                            
output stream OutStr-html close.     
if pPrint then
do:
    run prn-lib-reportviewer in this-procedure (
        input this-procedure
        ,input v-file-name-rep-htm
        ,input "" 
        ) no-error.
    if error-status:error then
    do:
        message return-value view-as alert-box.
        return .
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

FUNCTION get-pay RETURNS CHARACTER
    ( input parpay-code as integer,  input parcurr-code as integer, output parcurr-name as character) :
    /*------------------------------------------------------------------------------
      Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define variable varpay-name like ub.cash-pay.obj-name no-undo.

    run get-pay-proc in this-procedure (
        input  parpay-code
        ,input  parcurr-code
        ,output parcurr-name
        ,output varpay-name ).
    return varpay-name.

END FUNCTION.
        
FUNCTION pr-objname RETURNS character
    ( INPUT p-obj-code AS integer) :

    define variable v-obj-name as character no-undo .

    find first ub.clients no-lock where ub.clients.obj-code = p-obj-code and ub.clients.obj-type = {&shop} no-error .
    if AVAILABLE (ub.clients) then v-obj-name = ub.clients.obj-name .
 
    RETURN v-obj-name.

END FUNCTION.
        
function Str-chk-type returns character
    (input p-chk-type as character):
    define variable v-num-element   as integer   no-undo.
    define variable p-name-chk-type as character no-undo .
    /* Код_вида_расходов. Получение номера элемента в списке кодов */
    v-num-element = lookup(p-chk-type, {&receipt-codes}).

    /* Получение наименования код_вида_расходов по полученному элементу из списка наименований */
    p-name-chk-type = entry(v-num-element, {&receipt-codes-full}).
    if p-chk-type <> "" and v-num-element = 0 then
    do:
        message "Ошибка 115." view-as alert-box.
    end.
    else return p-name-chk-type .

end function.        