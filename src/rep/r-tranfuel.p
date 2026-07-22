block-level on error undo, throw.
/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Отчет по длительности транзакций

Автор: Рукавишников Вадим
Дата создания: 24/05/21
Author: Rukavishnikov Vadim
Creation date: 24/05/21

*/
define input parameter iCntxtHostCodeObj as integer   no-undo.
define input parameter iChkTypeCodeList  as character no-undo.
define input parameter iGdsCodeList      as character no-undo.
define input parameter iCashPayList      as character no-undo.
define input parameter iTRKList          as character no-undo.
define input parameter iTranTimeMax      as integer   no-undo.
define input parameter iGrpChk           as logical   no-undo.
define input parameter iGrpTran          as logical   no-undo.

define variable vss-revision    as character     no-undo init "$ $":U .
define variable vss-author      as character     no-undo init "$ $":U .
define variable vss-date        as character     no-undo init "$ $":U .
define variable vss-workfile    as character     no-undo init "$ $":U .
define variable vss-archive     as character     no-undo init "$ $":U .
define variable vss-description as character     no-undo init "Отчет по длительности транзакций".
define variable parparentproc   as widget-handle no-undo.
define variable mParamStr       as character     no-undo extent 10.
define variable mProdBcStrList  as character     no-undo.

{cmp/str-glbl.i}
{cmp/vssrevis.i}
{cmp/r-page1.i}
{ref/fd-attr.i}
{cmp/trg-def.i}
{gbl/gbclcode.i}
{gbl/prn-lib.i "new shared"}
{ref/chk-type-desc.i}
{rep/r-tranfuel.i}

define stream sOutStr-html.

function f_disp_time returns character
   (input iTime as integer):
   define variable vHour    as integer   no-undo.
   define variable vMinute  as integer   no-undo.
   define variable vSec     as integer   no-undo.
   define variable vTimeStr as character no-undo.
   
   if iTime < 0 then return "".
   
   vHour = truncate(iTime / 3600, 0).
   vMinute = truncate((iTime - vHour * 3600) / 60, 0).
   vSec = iTime - vHour * 3600 - vMinute * 60.
   vTimeStr = trim(string(vHour, ">>>99")) + ":" +
              string(vMinute, "99")  + ":" +
              string(vSec,    "99").
   return vTimeStr.
end function.

function fDate2Str returns character
   (input idate as date,
    input iformat as char):
   define variable vdatestr as character no-undo.
   if idate = ? then
      vdatestr = "".
   else
      vdatestr = trim(string(idate, iformat)).

   return vdatestr.
end function.

function fDec2Str returns character
   (input idec as decimal,
    input iformat as char):
   define variable vdecstr as character no-undo.
   if idec = ? then
      vdecstr = "".
   else
      vdecstr = trim(string(idec, iformat)).

   return vdecstr.
end function.

function fInt2Str returns character
   (input iInt as integer,
    input iformat as char):
   define variable vIntStr as character no-undo.
   if iInt = ? then
      vIntStr = "".
   else
      vIntStr = trim(string(iInt, iformat)).

   return vIntStr.
end function.

function fStrNvl returns character
   (input iStr     as character,
    input iDefault as character):
   return if iStr > "" then iStr else iDefault.
end function.

/* MAIN */
run BeforeCalc.
run initTT(x-tog-shift,
           X-date-start,
           X-date-end,
           X-Shift-Start,
           X-Shift-End,
           iChkTypeCodeList,
           iGdsCodeList,
           iTRKList).
run AfterCalc(x-tog-shift,
              X-date-end,
              iTRKList,
              iCashPayList,
              iTranTimeMax).
run PrintTT.

procedure BeforeCalc:
   define variable vI       as integer   no-undo.
   define variable vJ       as integer   no-undo.
   define variable vStr     as character no-undo.
   define variable vChkCode as character no-undo.   
   
   if x-tog-shift then do:
      vI = vI + 1.
      if X-shift-start = X-shift-end then
         mParamStr[vI] = "Смена: " + string(X-shift-start).
      else
         mParamStr[vI] = "Смены: c " + string(X-shift-start) + " по " + string(X-shift-end).
   end.
   
   vI = vI + 1.
   if X-date-start = X-date-end then
      mParamStr[vI] = "За дату : " + string(X-date-start, "99.99.9999").
   else
      mParamStr[vI] = "За период c " + string(X-date-start, "99.99.9999") + " по " + string(X-date-end, "99.99.9999").
   
   vI = vI + 1.
   mParamStr[vI] = "Выбор объекта: ".
   for each obj-list:
      mParamStr[vI] = mParamStr[vI] + obj-list.obj-name + "," .
   end.
   mParamStr[vI] = trim(mParamStr[vI], ",").
   
   vI = vI + 1.
   if iGdsCodeList = "*" then do:
      mParamStr[vI] = "Вся номенклатура".
      mProdBcStrList = "*".
   end.
   else do:
      mParamStr[vI] = "Номенклатура: ".
      vStr = "".

      for each goods where
               can-do(iGdsCodeList, string(goods.gds-code))
      no-lock:
         vStr = vStr + "," + string(goods.gds-code) + "(" + goods.gds-name + ")".
         for each prod-bc where
                  prod-bc.b-code = goods.gds-code
         no-lock:
            mProdBcStrList = mProdBcStrList + "," + prod-bc.b-str.
         end.
      end.
      vStr = trim(vStr, ",").
      mProdBcStrList = trim(mProdBcStrList, ",").
      mParamStr[vI] = mParamStr[vI] + vStr.
   end.

   vI = vI + 1.
   if iTRKList = "*" then
      mParamStr[vI] = "Все ТРК".
   else
      mParamStr[vI] = "ТРК: " + iTRKList.
   mParamStr[vI] = mParamStr[vI] + ", все пистолеты".
   
   vI = vI + 1.
   if iCashPayList = "*" then
      mParamStr[vI] = "Все типы оплаты".
   else do:
      mParamStr[vI] = "Типы оплаты: ".
      vStr = "".

      for each cash-pay where
               can-do(iCashPayList, string(cash-pay.cdpay-code))
      no-lock:
         vStr = vStr + "," + cash-pay.obj-name.
      end.
      vStr = trim(vStr, ",").
      mParamStr[vI] = mParamStr[vI] + vStr.
   end.

   vI = vI + 1.
   if iChkTypeCodeList = "*" then
      mParamStr[vI] = "Все типы чеков".
   else do:
      mParamStr[vI] = "Типы чеков: ".
      vStr = "".
      do vJ = 1 to num-entries({&CHK_CODE_LIST}):
         vChkCode = entry(vJ, {&CHK_CODE_LIST}).
         if can-do(iChkTypeCodeList, vChkCode) then
            vStr = vStr + "," + entry(vJ, {&CHK_NAME_LIST}).
      end.
      vStr = trim(vStr, ",").
      mParamStr[vI] = mParamStr[vI] + vStr.
   end.
   
   if iTranTimeMax > 0 then do:
      vI = vI + 1.
      mParamStr[vI] = "Только с жизненным циклом заказа НП более " + string(iTranTimeMax) + " минут".
   end.
   
   vI = vI + 1.
   if not iGrpChk and not iGrpTran then
      mParamStr[vI] = "Без группировки".
   else do:
      mParamStr[vI] = "С группировкой по ".
      if iGrpChk then
         mParamStr[vI] = mParamStr[vI] + "чекам".
      if iGrpTran then
         mParamStr[vI] = mParamStr[vI] + 
                        (if iGrpChk then " и " else "") +
                         "транзакциям".
   end.
end procedure.



procedure PrintTT:
   define variable vReportId     as character no-undo.
   define variable vFileNameRep  as character no-undo.
   define variable vLevel        as character no-undo.
   define variable vPrevUuidCheq as character no-undo.
   define variable vPrevUuid     as character no-undo.
   define variable vStr          as character no-undo.
   define variable vI            as integer   no-undo.

   do on error undo, return error return-value:
      run get-report-num(output vReportId).
      vFileNameRep = session:temp-directory + string(vReportId) + ".html".

      output stream sOutStr-html to value(vFileNameRep) convert target 'UTF-8'.
      put stream sOutStr-html unformatted
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

      put stream sOutStr-html unformatted
           '<body>' skip
           '<TABLE name="1" outline_below="true" fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">' skip
           '<thead>' skip
           '<TR class="set_columns">' skip
               '<TD style="width:  68px;"></TD>' skip            /*  1    */
               '<TD style="width: 111px;"></TD>' skip            /*  2    */
               '<TD style="width:  84px;"></TD>' skip            /*  3    */
               '<TD style="width:  78px;"></TD>' skip            /*  4    */
               '<TD style="width:  88px;"></TD>' skip            /*  5    */
               '<TD style="width:  80px;"></TD>' skip            /*  6    */
               '<TD style="width:  95px;"></TD>' skip            /*  7    */
               '<TD style="width:  84px;"></TD>' skip            /*  8    */
               '<TD style="width: 148px;"></TD>' skip            /*  9    */
               '<TD style="width:  64px;"></TD>' skip            /*  10   */
               '<TD style="width: 150px;"></TD>' skip            /*  11   */
               '<TD style="width:  65px;"></TD>' skip            /*  12   */
               '<TD style="width: 108px;"></TD>' skip            /*  13   */
               '<TD style="width:  72px;"></TD>' skip            /*  14   */
               '<TD style="width: 113px;"></TD>' skip            /*  15   */
               '<TD style="width:  79px;"></TD>' skip            /*  16   */
               '<TD style="width:  82px;"></TD>' skip            /*  17   */
               '<TD style="width:  97px;"></TD>' skip            /*  18   */
               '<TD style="width: 150px;"></TD>' skip            /*  19   */
               '<TD style="width: 157px;"></TD>' skip            /*  20   */
               '<TD style="width:  88px;"></TD>' skip            /*  21   */
               '<TD style="width:  81px;"></TD>' skip            /*  22   */
               '<TD style="width:  85px;"></TD>' skip            /*  23   */
               '<TD style="width: 100px;"></TD>' skip            /*  24   */
               '<TD style="width:  91px;"></TD>' skip            /*  25   */
               '<TD style="width:  91px;"></TD>' skip            /*  26   */
               '<TD style="width: 103px;"></TD>' skip            /*  27   */
           '</TR>' skip
           '<TR>' skip
               '<TD colspan="12" STYLE="font-size: 14px;">' + 'Отчет по продолжительности топливных транзакций' + '</TD>'skip
           '</TR>' skip
           .

      do vI = 1 to extent(mParamStr):
         if mParamStr[vI] = "" then leave.
         put stream sOutStr-html unformatted
              '<TR>' skip
                  '<TD colspan="12" STYLE="font-size: 14px;">' + mParamStr[vI] + '</TD>' skip
              '</TR>' skip
            .
      end.

      put stream sOutStr-html unformatted
           '<TR>' skip
               '<TD colspan="12" STYLE="font-size: 14px;">Дата печати: ' + string(today, "99.99.9999") + ' ' + string(time, "HH:MM") + '</TD>' skip
           '</TR>' skip
           '</thead>' skip
         .

      put stream sOutStr-html unformatted
         '<tbody>'
         '<TR >'skip
            '<TH style="text-align: center; font-weight:bold; ">Название АЗС/АЗК</TH>'                 skip
            '<TH style="text-align: center; font-weight:bold; ">Дата чека</TH>'                        skip
            '<TH style="text-align: center; font-weight:bold; ">Время чека</TH>'                       skip
            '<TH style="text-align: center; font-weight:bold; ">Дата смены</TH>'                       skip
            '<TH style="text-align: center; font-weight:bold; ">Номер смены</TH>'                      skip
            '<TH style="text-align: center; font-weight:bold; ">Номер чека</TH>'                       skip
            '<TH style="text-align: center; font-weight:bold; ">Номер Z-отчета</TH>'                   skip
            '<TH style="text-align: center; font-weight:bold; ">Номер топливной транзакции</TH>'       skip
            '<TH style="text-align: center; font-weight:bold; ">Тип чека</TH>'                         skip
            '<TH style="text-align: center; font-weight:bold; ">Номер кассы</TH>'                      skip
            '<TH style="text-align: center; font-weight:bold; ">ФИО кассира</TH>'                      skip
            '<TH style="text-align: center; font-weight:bold; ">Номер ТРК</TH>'                        skip
            '<TH style="text-align: center; font-weight:bold; ">Номер пистолета</TH>'                  skip
            '<TH style="text-align: center; font-weight:bold; ">Код топлива</TH>'                      skip
            '<TH style="text-align: center; font-weight:bold; ">Наименование топлива</TH>'             skip
            '<TH style="text-align: center; font-weight:bold; ">Объем топлива, л</TH>'                 skip
            '<TH style="text-align: center; font-weight:bold; ">Цена топлива, р</TH>'                  skip
            '<TH style="text-align: center; font-weight:bold; ">Сумма, р</TH>'                         skip
            '<TH style="text-align: center; font-weight:bold; ">Тип оплаты</TH>'                       skip
            '<TH style="text-align: center; font-weight:bold; ">Номер карты</TH>'                      skip
            '<TH style="text-align: center; font-weight:bold; ">Дата начала транзакции</TH>'           skip
            '<TH style="text-align: center; font-weight:bold; ">Время начала транзакции</TH>'          skip
            '<TH style="text-align: center; font-weight:bold; ">Дата окончания транзакции</TH>'        skip
            '<TH style="text-align: center; font-weight:bold; ">Время окончания транзакции</TH>'       skip
            '<TH style="text-align: center; font-weight:bold; ">Продолжительность транзакции (*)</TH>' skip
            '<TH style="text-align: center; font-weight:bold; ">Жизненный цикл заказа НП</TH>'         skip
            '<TH style="text-align: center; font-weight:bold; ">Продолжение налива</TH>'               skip
         '</TR>'skip
         .

      for each tt-rep
      break
         by tt-rep.obj-code
         by tt-rep.grp-num
         by tt-rep.sort-date
         by tt-rep.sort-time
         by tt-rep.datetime-beg
         by tt-rep.datetime-end:
            
         vLevel = "".
         if not first-of(tt-rep.grp-num) then do:
            if iGrpChk or iGrpTran then do:
               if iGrpChk and iGrpTran then
                  vLevel = 'level="2"'.
               else if iGrpChk and tt-rep.uuid-cheq = vPrevUuidCheq then
                  vLevel = 'level="2"'.
               else if iGrpTran and tt-rep.uuid = vPrevUuid then
                  vLevel = 'level="2"'.
            end.
         end.
         assign
            vPrevUuidCheq = tt-rep.uuid-cheq
            vPrevUuid     = tt-rep.uuid
            .
         put stream sOutStr-html unformatted
            '<TR ' vLevel '>' skip
                '<TD text_wrap="true" style="text-align: center">' fStrNvl(tt-rep.obj-name, "")                                '</TD>' skip
                '<TD style="text-align: center">'                  fdate2str(tt-rep.chk-date, "99.99.9999")                    '</TD>' skip
                '<TD style="text-align: center">'                  if tt-rep.chk-date = ? then "" else fStrNvl(string(tt-rep.chk-time, "HH:MM:SS"), "") '</TD>' skip
                '<TD style="text-align: center">'                  fdate2str(tt-rep.shift-date, "99.99.9999")                  '</TD>' skip
                '<TD style="text-align: center">'                  fStrNvl(tt-rep.shift-name, "")                              '</TD>' skip
                '<TD style="text-align: center">'                  fInt2Str(tt-rep.chk-num, ">>>>>>>>>>")                      '</TD>' skip
                '<TD style="text-align: center">'                  fInt2Str(tt-rep.z-number, ">>>>>>>>>>")                     '</TD>' skip
                '<TD style="text-align: center">'                  fInt2Str(tt-rep.tran-num, ">>>>>>>>>9")                     '</TD>' skip
                '<TD text_wrap="true" style="text-align: center">' fStrNvl(tt-rep.chk-type-desc, "")                           '</TD>' skip
                '<TD style="text-align: center">'                  fInt2Str(tt-rep.cash-num, ">>>>9")                          '</TD>' skip
                '<TD text_wrap="true" style="text-align: left">' fStrNvl(tt-rep.cashier, "")                                 '</TD>' skip
                '<TD style="text-align: center">'                  fInt2Str(tt-rep.trk-num, ">>9")                             '</TD>' skip
                '<TD style="text-align: center">'                  fInt2Str(tt-rep.nozzle-num, ">>9")                          '</TD>' skip
                '<TD style="text-align: center">'                  fInt2Str(tt-rep.fuel-code, ">>>>>>>>>9")                    '</TD>' skip
                '<TD text_wrap="true" style="text-align: center">' fStrNvl(tt-rep.gds-name, "")                                '</TD>' skip
                '<TD num="#,##0.00" val="' + fDec2Str(tt-rep.volume, "->>>>>>>>>>>9.99") + '" style="text-align: right">' + fDec2Str(tt-rep.volume, "->>>>>>>>>>>9.99") + '</TD>' skip
                '<TD num="#,##0.00" val="' + fDec2Str(tt-rep.price, "->>>>>>>>>>>9.99") + '" style="text-align: right">'  + fDec2Str(tt-rep.price, "->>>>>>>>>>>9.99") + '</TD>' skip
                '<TD num="#,##0.00" val="' + fDec2Str(tt-rep.money, "->>>>>>>>>>>9.99") + '" style="text-align: right">'  + fDec2Str(tt-rep.money, "->>>>>>>>>>>9.99") + '</TD>' skip
                '<TD text_wrap="true" style="text-align: center">' fStrNvl(tt-rep.cash-pay-name, "")                           '</TD>' skip
                '<TD style="text-align: center">'                  fStrNvl(tt-rep.pay-card, "")                                '</TD>' skip
                '<TD style="text-align: center">'                  fdate2str(tt-rep.date-beg, "99.99.9999")                    '</TD>' skip
                '<TD style="text-align: center">'                  fStrNvl(string(tt-rep.time-beg, "HH:MM:SS"), "")            '</TD>' skip
                '<TD style="text-align: center">'                  fdate2str(tt-rep.date-end, "99.99.9999")                    '</TD>' skip
                '<TD style="text-align: center">'                  fStrNvl(string(tt-rep.time-end, "HH:MM:SS"), "")            '</TD>' skip
                '<TD style="text-align: center">'                  fStrNvl(f_disp_time(tt-rep.time-length), "")                '</TD>' skip
                '<TD style="text-align: center">'                  fStrNvl(f_disp_time(tt-rep.all-time-length-2), "")          '</TD>' skip
                '<TD style="text-align: center">'                  string(tt-rep.resume-tran, "+/-")                           '</TD>' skip
            '</TR>' skip.
         if last-of(tt-rep.obj-code) then do:
            for first tt-total-rep where
                      tt-total-rep.obj-type = tt-rep.obj-type
                  and tt-total-rep.obj-code = tt-rep.obj-code
                  and tt-total-rep.obj-name = tt-rep.obj-name:
               put stream sOutStr-html unformatted
                  '<TR >' skip
                      '<TD style="text-align: left; font-weight:bold">'                   "Итого по:"                                                '</TD>' skip
                      '<TD style="text-align: left; font-weight:bold">'                   fStrNvl(tt-total-rep.obj-name, "")                         '</TD>' skip
                      '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Количество чеков"                                         '</TD>' skip
                      '<TD style="text-align: left; font-weight:bold">'                    fInt2Str(tt-total-rep.qty-chk, ">>>9")                    '</TD>' skip
                      '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Количество транзакций"                                    '</TD>' skip
                      '<TD style="text-align: left; font-weight:bold">'                    fInt2Str(tt-total-rep.qty-tran, ">>>9")                   '</TD>' skip
                      '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Количество  чеков с транзакциями"                         '</TD>' skip
                      '<TD style="text-align: left; font-weight:bold">'                    fInt2Str(tt-total-rep.qty-chk-fuel, ">>>9")               '</TD>' skip
                      '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Общая продолжительность"                                  '</TD>' skip
                      '<TD style="text-align: left; font-weight:bold">'                    fStrNvl(f_disp_time(tt-total-rep.full-time-tran), "")     '</TD>' skip
                      '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Средняя продолжительность"                                '</TD>' skip
                      '<TD style="text-align: left; font-weight:bold">'                    fStrNvl(f_disp_time(tt-total-rep.avg-time-tran), "")      '</TD>' skip
                      '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Средняя длительность жизненного цикла заказа НП"          '</TD>' skip
                      '<TD style="text-align: left; font-weight:bold">'                    fStrNvl(f_disp_time(tt-total-rep.avg-time-tran-fuel), "") '</TD>' skip
                      .
            end.
            do vI = 1 to 13:
               put stream sOutStr-html unformatted
                  '<TD style="text-align: right"> </TD>' skip
                  .
            end.
            put stream sOutStr-html unformatted
                  '</TR>' skip.
         end.
      end.
      
      for first tt-all-total-rep:
         put stream sOutStr-html unformatted
            '<TR >' skip
                '<TD style="text-align: left; font-weight:bold">'                   "Итого по:"                                                    '</TD>' skip
                '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Всем выбранным объектам"                                      '</TD>' skip
                '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Количество чеков"                                             '</TD>' skip
                '<TD style="text-align: left; font-weight:bold">'                    fInt2Str(tt-all-total-rep.qty-chk, ">>>9")                    '</TD>' skip
                '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Количество транзакций"                                        '</TD>' skip
                '<TD style="text-align: left; font-weight:bold">'                    fInt2Str(tt-all-total-rep.qty-tran, ">>>9")                   '</TD>' skip
                '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Количество  чеков с транзакциями"                             '</TD>' skip
                '<TD style="text-align: left; font-weight:bold">'                    fInt2Str(tt-all-total-rep.qty-chk-fuel, ">>>9")               '</TD>' skip
                '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Общая продолжительность"                                      '</TD>' skip
                '<TD style="text-align: left; font-weight:bold">'                    fStrNvl(f_disp_time(tt-all-total-rep.full-time-tran), "")     '</TD>' skip
                '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Средняя продолжительность"                                    '</TD>' skip
                '<TD style="text-align: left; font-weight:bold">'                    fStrNvl(f_disp_time(tt-all-total-rep.avg-time-tran), "")      '</TD>' skip
                '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Средняя длительность жизненного цикла заказа НП"              '</TD>' skip
                '<TD style="text-align: left; font-weight:bold">'                    fStrNvl(f_disp_time(tt-all-total-rep.avg-time-tran-fuel), "") '</TD>' skip
                .
         do vI = 1 to 13:
            put stream sOutStr-html unformatted
               '<TD style="text-align: right"> </TD>' skip
               .
         end.
         put stream sOutStr-html unformatted
               '</TR>' skip.
      end.
      
      vStr = "(*) В отчете для всех строк с транзакцией, связанной с несколькими чеками или строками чеков (при смешанной оплате), " +
             "отображается одинаковая продолжительность. Данное время не определяет длительность выполнения конкретной кассовой операции " + 
             "(например, возврат, сброс, аннуляция, смешанная оплата), относящейся к транзакции".
      put stream sOutStr-html unformatted
         '<TR>'  skip
            '<TD colspan="27" STYLE="font-size: 11px;">' + vStr + '</TD>' skip
         '</TR>' skip.
         
      put stream sOutStr-html unformatted
         '</tbody>' skip
         '</table>' skip
         '</body>' skip
         '</html>' skip
         .
         
      output stream sOutStr-html close.

      run prn-lib-reportviewer-report-name in this-procedure (
          input parparentproc
          ,input vFileNameRep
          ) no-error.
      if error-status:error then
      do:
          message "error-status:error = " error-status:error skip return-value view-as alert-box.
          return .
      end.
            
   end.

end procedure.

PROCEDURE get-report-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-report-num as integer no-undo .

  do
  on error undo, return error return-value
  :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.