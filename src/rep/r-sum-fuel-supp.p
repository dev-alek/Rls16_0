/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Сводный отчёт по поставкам НП

Автор: Рукавишников Вадим
Дата создания: 24/05/21
Author: Rukavishnikov Vadim
Creation date: 24/05/21

*/

using ibs.th.str.*.
block-level on error undo, throw.

define input parameter iCntxtHostCodeObj as integer   no-undo.
define input parameter iACType           as integer   no-undo.
define input parameter iTrkErr           as integer   no-undo.
define input parameter iGdsCodeList      as character no-undo.
define input parameter iSuppsList        as character no-undo.
define input parameter iOilBaseList      as character no-undo.
define input parameter iTranTimeMax      as integer   no-undo.
define input parameter iDelta-tank-ac    as logical   no-undo.
define input parameter iDelta-tank-fact  as logical   no-undo.
define input parameter i-Itog            as logical   no-undo.
define input parameter i-NoAzkItog       as logical   no-undo.

define variable vss-revision    as character     no-undo init "$ $":U .
define variable vss-author      as character     no-undo init "$ $":U .
define variable vss-date        as character     no-undo init "$ $":U .
define variable vss-workfile    as character     no-undo init "$ $":U .
define variable vss-archive     as character     no-undo init "$ $":U .
define variable vss-description as character     no-undo init "Сводный отчёт по поставкам НП".
define variable parparentproc   as widget-handle no-undo.
define variable mParamStr       as character     no-undo extent 10.
define variable mProdBcStrList  as character     no-undo.
define variable mSuppStrList    as character     no-undo.
define variable mPrim1          as character     no-undo extent 10.
define variable mPrim2          as character     no-undo extent 10.
define variable mPrim3          as character     no-undo extent 10.

{cmp/str-glbl.i}
{cmp/vssrevis.i}
{cmp/r-page1.i}
{cmp/trg-def.i}
{str/lib-trn.i}
{gbl/gbclcode.i}
{str/trdcalib.i}
{ref/gds-attr.i}
{gbl/prn-lib.i "new shared"}
{str/is-gas.i}
{str/is-sug.i}
{str/placelib.i}
{gbl/usrfulnf.i}

define temp-table tt-rep no-undo
  field col1  as character  /* АЗК/АЗС */
  field obj-type as character
  field obj-code as integer
  field col2  as character  /* Дата и номер смены */
  field shift-date as date
  field shift-num as integer
  field col3  as character  /* Внутренний номер документа приема */
  field col4  as character  /* Номер документа поставщика */
  field col5  as character  /* Дата/время начала приема НП  */
  field col6  as character  /* Дата/время окончания приема НП  */
  field col7  as character  /* Длительность приемки  */
  field min-pour as integer
  field col8  as character  /* Поставщик  */
  field col9  as character  /* Перевозчик  */
  field col10  as character  /* Нефтебаза  */
  field col11 as character  /* АЦ */
  field col12 as character  /* Тип АЦ */
  field col13 as character  /* Водитель */
  field col14 as character  /* Приёмщик */
  field col15 as character  /* № секции */
  field col16 as character  /* Марка НП */
  field gds-code as integer
  field col17 as character  /* № резервуара  */
  field col18 as character  /* Способ разблокировки API-адаптера */
  field col19 as character  /* Номер ключа/код доступа */
  /* Параметры топлива по ТТН */
  field col20 as decimal    /* Объем, л */
  field col20str as character
  field col21 as decimal    /* Масса, кг */
  field col21str as character
  field col22 as decimal    /* Плотн., г/см3 */
  field col22str as character
  field col23 as decimal    /* Темп., °С */
  field col23str as character
  /* Параметры топлива по измерениям в АЦ  */
  field col24 as decimal    /* Объем, л */
  field col24str as character
  field col25 as decimal    /* Масса, кг */
  field col25str as character
  field col26 as decimal    /* Масса ЕУ, кг */
  field col26str as character
  field col27 as decimal    /* Плотн., г/см3 */
  field col27str as character
  field col28 as decimal    /* Темп., °С */
  field col28str as character
  /* Параметры топлива по измерениям в резервуаре до слива */
  field col29 as decimal    /* Объем, л */
  field col29str as character
  field col30 as decimal    /* Масса, кг */
  field col30str as character
  field col31 as decimal    /* Плотн., г/см3 */
  field col31str as character
  field col32 as decimal    /* Темп., °С */
  field col32str as character
  /* Реализация при сливе НП */
  field col33 as decimal    /* Объем, л */
  field col34 as decimal    /* Масса, кг */
  field col35 as character  /* Ошибка данных с ТРК */
  /* Параметры топлива по измерениям в резервуаре после слива */
  field col36 as decimal    /* Объем, л */
  field col36str as character
  field col37 as decimal    /* Масса, кг */
  field col37str as character
  field col38 as decimal    /* Плотн., г/см3 */
  field col38str as character
  field col39 as decimal    /* Темп., °С */
  field col39str as character
  /* Принято к учету */
  field col40 as decimal    /* Объем, л */
  field col41 as decimal    /* Масса, кг */
  /* Отклонение АЦ к ТТН */
  field col42 as decimal decimals 1    /* Масса, кг (1.22 - 1.18) */
  field col43 as decimal decimals 2    /* % (1.36/1.18*100) */
  /* Отклонение резервуара к АЦ */
  field col44 as decimal decimals 1    /* Масса, кг (1.31- 1.27 - 1.22) */
  field col45 as decimal decimals 2    /* % (1.38/1.22*100) */
  /* Отклонение между резервуаром и  принятым к учету топливом */
  field col46 as decimal decimals 1    /* Масса, кг (1.31 - 1.27 - 1.35) */
  field col47 as decimal decimals 2    /* % (1.40/1.35*100) */
  
  field col48 as decimal decimals 1    /* Сверхнормативные расхождения между резервуаром и АЦ, кг  */
  field col49 as decimal decimals 1    /* Сверхнормативные расхождения между резервуаром и принятым к учету топливом, кг */
  
  field col50 as character    /* АЦ слита с комиссией */
  field col51 as character    /* Способ ввода данных в сверке (АВД/РВД) */
  
  field delta-mass-qnty-ac as decimal
  field delta-mass-qnty-before as decimal
  field delta-mass-qnty-after as decimal
  
  field no-itog         as logical
  
  field ac-measured     as logical
  
  index pi as primary
    obj-code
    shift-date shift-num
    gds-code
    col3
    col17
.

define temp-table tt-itog no-undo
  field col1  as character  /* АЗК/АЗС */
  field obj-type as character
  field obj-code as integer
  /* Параметры топлива по ТТН */
  field col20 as decimal    /* Объем, л */
  field col21 as decimal    /* Масса, кг */
  /* Параметры топлива по измерениям в АЦ  */
  field col24 as decimal    /* Объем, л */
  field col25 as decimal    /* Масса, кг */
  field col26 as decimal    /* Масса ЕУ, кг */
  /* Параметры топлива по измерениям в резервуаре до слива */
  field col29 as decimal    /* Объем, л */
  field col30 as decimal    /* Масса, кг */
  /* Реализация при сливе НП */
  field col33 as decimal    /* Объем, л */
  field col34 as decimal    /* Масса, кг */
  /* Параметры топлива по измерениям в резервуаре после слива */
  field col36 as decimal    /* Объем, л */
  field col37 as decimal    /* Масса, кг */
  /* Принято к учету */
  field col40 as decimal    /* Объем, л */
  field col41 as decimal    /* Масса, кг */
  /* Отклонение АЦ к ТТН */
  field col42 as decimal    /* Масса, кг (1.21 - 1.17) */
  field col43 as decimal    /* % (1.37/1.17*100) */
  field col43red as logical
  /* Отклонение резервуара к АЦ */
  field col44 as decimal    /* Масса, кг (1.30- 1.26 - 1.21) */
  field col45 as decimal    /* % (1.41/1.21*100) */
  field col45red as logical
  /* Отклонение между резервуаром и  принятым к учету топливом */
  field col46 as decimal    /* Масса, кг (1.30 - 1.26 - 1.34) */
  field col47 as decimal    /* % (1.43/1.34*100) */
  field col47red as logical
  
  field col48 as decimal    /* Сверхнормативные расхождения между резервуаром и АЦ, кг  */
  field col49 as decimal    /* Сверхнормативные расхождения между резервуаром и принятым к учету топливом, кг */
  index pi as primary
    obj-code
.

define temp-table tt-all-itog no-undo
  field col1  as character  /* АЗК/АЗС */
  field obj-type as character
  field obj-code as integer
  /* Параметры топлива по ТТН */
  field col20 as decimal    /* Объем, л */
  field col21 as decimal    /* Масса, кг */
  /* Параметры топлива по измерениям в АЦ  */
  field col24 as decimal    /* Объем, л */
  field col25 as decimal    /* Масса, кг */
  field col26 as decimal    /* Масса ЕУ, кг */
  /* Параметры топлива по измерениям в резервуаре до слива */
  field col29 as decimal    /* Объем, л */
  field col30 as decimal    /* Масса, кг */
  /* Реализация при сливе НП */
  field col33 as decimal    /* Объем, л */
  field col34 as decimal    /* Масса, кг */
  /* Параметры топлива по измерениям в резервуаре после слива */
  field col36 as decimal    /* Объем, л */
  field col37 as decimal    /* Масса, кг */
  /* Принято к учету */
  field col40 as decimal    /* Объем, л */
  field col41 as decimal    /* Масса, кг */
  /* Отклонение АЦ к ТТН */
  field col42 as decimal    /* Масса, кг (1.21 - 1.17) */
  field col43 as decimal    /* % (1.37/1.17*100) */
  field col43red as logical
  /* Отклонение резервуара к АЦ */
  field col44 as decimal    /* Масса, кг (1.30- 1.26 - 1.21) */
  field col45 as decimal    /* % (1.41/1.21*100) */
  field col45red as logical
  /* Отклонение между резервуаром и  принятым к учету топливом */
  field col46 as decimal    /* Масса, кг (1.30 - 1.26 - 1.34) */
  field col47 as decimal    /* % (1.43/1.34*100) */
  field col47red as logical
  
  field col48 as decimal    /* Сверхнормативные расхождения между резервуаром и АЦ, кг  */
  field col49 as decimal    /* Сверхнормативные расхождения между резервуаром и принятым к учету топливом, кг */
  index pi as primary
    obj-code
.

define temp-table tt-rvs-line-pump-delta no-undo like ub.rvs-line-pump
  field deltaVol as decimal
  field is-err as logical
  field find-pair as logical
.

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
run BeforeCalc .

run initTT .

run calc-itog .

run PrintTT .

procedure BeforeCalc:
   define variable vI       as integer   no-undo.
   define variable vJ       as integer   no-undo.
   define variable vStr     as character no-undo.
   define variable vChkCode as character no-undo.   
   
   if x-tog-shift then do:
     vI = vI + 1.
     mParamStr[vI] = "По сменам: c " + string(X-shift-start) + " по " + string(X-shift-end).
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
   if iSuppsList = "*" then do:
     mParamStr[vI] = "Все поставщики".
     mSuppStrList = "*".
   end.
   else do:
     mParamStr[vI] = "Поставщики: ".
     vStr = "".

     for each clients where can-do(iSuppsList, string(clients.obj-code))
                        and clients.obj-type = "орг"
     no-lock:
       vStr = vStr + ", Орг" + string(clients.obj-code) + " " + clients.obj-name + "".
     end.
     vStr = trim(vStr, ", ").
     mParamStr[vI] = mParamStr[vI] + vStr.
   end.
   
   if iTranTimeMax > 0
   then do:
     vI = vI + 1.
     mParamStr[vI] = "Только со временем слива секции НП более " + string(iTranTimeMax) + " минут".
   end.
   
   if iDelta-tank-ac
   and iDelta-tank-fact
   then do :
     vI = vI + 1.
     mParamStr[vI] = "Только со сверхнормативным расхождением между резервуаром и АЦ, либо между резервуаром и принятым НП".
   end.
   else
   if iDelta-tank-ac
   then do :
     vI = vI + 1.
     mParamStr[vI] = "Только со сверхнормативным расхождением между резервуаром и АЦ".
   end.
   else
   if iDelta-tank-fact
   then do :
     vI = vI + 1.
     mParamStr[vI] = "Только со сверхнормативным расхождением между резервуаром и принятым НП".
   end.
   
   vI = vI + 1.
   if i-Itog
   then do :
     mParamStr[vI] = "Только итоги".
   end .
   else do :
     mParamStr[vI] = "В т.ч. итоги".
   end .
   
   vI = vI + 1.
   
   
   mPrim1[1] = "Объем в ИТОГО: отображается в виде справочной информации." .
   mPrim1[2] = "<u>Расчет отклонения АЦ к ТТН</u> " + fill("&nbsp;" , 11) + " <u>Расчет отклонения резервуара к АЦ</u>" .
   mPrim1[3] = "Масса = (1.25-1.21)      " + fill("&nbsp;" , 28) + "Масса = ((1.37+1.34)-1.30)-1.25" .
   mPrim1[4] = "% = (1.42/1.21*100)      " + fill("&nbsp;" , 28) + "% = (1.44/1.25*100)" .
   mPrim1[5] = "<u>Расчет отклонения между резервуаром и принятым к учету топливом</u>" .
   mPrim1[6] = "Масса = ((1.37+1.34)-1.30)-1.41" .
   mPrim1[7] = "% = (1.46/1.41*100)" .
   
   mPrim2[1] = "Расчет сверхнормативного расхождения между резервуаром и АЦ" .
   mPrim2[2] = "Если 1.44 < 0 1.44+Корень((1.37*Пр)^2+(1.30*Пр)^2+(1.34*Птрк)^2+(1.25*Пац)^2)/100" .
   mPrim2[3] = "Если 1.44 > 0 1.44-Корень((1.37*Пр)^2+(1.30*Пр)^2+(1.34*Птрк)^2+(1.25*Пац)^2)/100" .
   mPrim2[4] = "Пр - относительная погрешность измерения массы нефтепродукта в резервуаре (в сверках)" .
   mPrim2[5] = "Пац - погрешность измерения массы в АЦ" .
   mPrim2[6] = "Результат расчета округляется до десятых." .
   mPrim2[7] = "Птрк - погрешность ТРК, равная 0,5%" .
   
   mPrim3[1] = "Расчет сверхнормативного расхождения между резервуаром и принятым к учету топливом" .
   mPrim3[2] = "Если 1.46 < 0 1.46+Корень((1.37*Пр)^2+(1.34*Птрк)^2+(1.30*Пр)^2)/100" .
   mPrim3[3] = "Если 1.46 > 0 1.46-Корень((1.37*Пр)^2+(1.34*Птрк)^2+(1.30*Пр)^2)/100" .
   mPrim3[4] = "Пр - относительная погрешность измерения массы нефтепродукта в резервуаре (в сверках)" .
   mPrim3[5] = "Результат расчета округляется до десятых." .
   mPrim3[6] = "Птрк - погрешность ТРК, равная 0,5%" .
   
end procedure.

procedure initTT :
  define buffer buf_trn-doc       for ub.trn-doc .
  
  for each obj-list :
    if x-TOG-Shift
    then do :
      for each buf_trn-doc no-lock where buf_trn-doc.obj-type     = obj-list.obj-type
                                     and buf_trn-doc.obj-code     = obj-list.obj-code
                                     and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                                     and buf_trn-doc.status_      = {&fact}
                                     and can-do(iSuppsList, string(buf_trn-doc.cli-code))
                                     and (buf_trn-doc.shift-date > X-date-Start or (buf_trn-doc.shift-date = X-date-Start and buf_trn-doc.shift-num >= x-Shift-Start))
                                     and (buf_trn-doc.shift-date < X-date-End or (buf_trn-doc.shift-date = X-date-End and buf_trn-doc.shift-num <= x-Shift-End))
      :
        run processTrn(input buf_trn-doc.doc-code) .
      end .
    end .
    else do :
      for each buf_trn-doc no-lock where buf_trn-doc.obj-type     = obj-list.obj-type
                                     and buf_trn-doc.obj-code     = obj-list.obj-code
                                     and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                                     and buf_trn-doc.status_      = {&fact}
                                     and can-do(iSuppsList, string(buf_trn-doc.cli-code))
                                     and buf_trn-doc.fact-date >= X-date-Start
                                     and buf_trn-doc.fact-date <= X-date-End
      :
        run processTrn(input buf_trn-doc.doc-code) .
      end .
    end .
  end .
  
end procedure .

procedure processTrn :
  define input parameter p-doc-code as character no-undo .
  
  define buffer buf_tt-rep for tt-rep .
  
  define buffer buf_trn-doc       for ub.trn-doc .
  define buffer buf_goods         for ub.goods .
  define buffer buf_doc-line      for ub.doc-line .
  define buffer buf_rvs-doc       for ub.rvs-doc .
  define buffer buf_rvs-line      for ub.rvs-line .
  define buffer buf_rvs-line-attr for ub.rvs-line-attr .
  define buffer buf_clients       for ub.clients .
  define buffer buf_place         for ub.place .
  define buffer buf_doc-pl        for ub.doc-pl .
  define buffer sep_auto-tank-attr  for ub.auto-tank-attr .
  define buffer buf_rvs-line-pump for ub.rvs-line-pump .
  define buffer buf_c-place-attr  for ub.c-place-attr .
  define buffer buf2_c-place-attr for ub.c-place-attr .
  define buffer buf_pl-gds-pump   for ub.pl-gds-pump .
  define buffer buf_c-pl-gds-pump for ub.c-pl-gds-pump .
  define buffer buf2_c-pl-gds-pump for ub.c-pl-gds-pump .
  
  define variable v-ok                  as logical   no-undo.
  define variable is-petrolium          as logical   no-undo.
  define variable is-pieces             as logical   no-undo.
  define variable v-isKPrvs             as logical   no-undo.
  define variable v-InfoSectionsTotal   as class     InfoSectionsTotal no-undo .
  define variable v-InfoSection         as class     InfoSection no-undo .
  define variable iNum                  as integer   no-undo .
  define variable varvalue              as character no-undo .
  define variable vartype               as character no-undo .
  define variable is-ptrl-trn           as logical   no-undo .
  define variable is-sug-trn            as logical   no-undo .
  define variable is-com-tanks          as logical   no-undo .
  define variable v-num-com-tanks       as integer   no-undo .
  define variable v-is-sug-gds          as logical   no-undo .
  define variable v-nids                as character no-undo .
  define variable v-cli-name            as character no-undo .
  define variable v-auto-cli-name       as character no-undo .
  define variable v-nb-cli-name         as character no-undo .
  define variable v-user-name           as character no-undo .
  define variable v-car-num             as character no-undo .
  define variable v-driver-name         as character no-undo .
/*  define variable v-sep                 as character no-undo init "АЦ без СЭП" .*/
  define variable v-sep                 as character no-undo init "" .
  define variable v-place-num           as character no-undo .
  define variable v-hour-pour           as integer   no-undo .
  define variable v-min-pour            as integer   no-undo .
  define variable v-hour-start          as integer   no-undo .
  define variable v-min-start           as integer   no-undo .
  define variable v-hour-end            as integer   no-undo .
  define variable v-min-end             as integer   no-undo .
  define variable v-date-start          as date      no-undo .
  define variable v-date-end            as date      no-undo .
  define variable v-time-start          as integer   no-undo .
  define variable v-time-end            as integer   no-undo .
  define variable v-SectionName         as character no-undo .
  define variable v-delta-ac            as decimal   no-undo .
  define variable v-delta-fact          as decimal   no-undo .
  define variable v-delta-mass-qnty-ac  as decimal   no-undo .
  define variable v-avrg-dens           as decimal   no-undo .
  define variable v-tmp-time            as integer   no-undo .
/*  define variable v-pl-sum-col24        as decimal   no-undo .*/
/*  define variable v-pl-sum-col25        as decimal   no-undo .*/
/*  define variable v-pl-sum-col41        as decimal   no-undo .*/
  define variable v-pl-gds-pump-status_ as character no-undo .
  
  is-ptrl-trn = no .
  is-sug-trn = no .
  varvalue = "" .
  { str/tdat-val.i
    p-doc-code
    {&trdcattr-is-fuel}
    varvalue
    vartype
    no-error
  }
  if varvalue = "yes"
  then do:
    is-ptrl-trn = yes .
  end.
  if not is-ptrl-trn
  then do :
    varvalue = "" .
    { str/tdat-val.i
      p-doc-code
      {&trdcattr-is-lgas}
      varvalue
      vartype
      no-error
    }
    if varvalue = "yes"
    then do:
      is-sug-trn = yes .
      is-ptrl-trn = yes .
    end.
  end .
  if not is-ptrl-trn
  then do :
    varvalue = "" .
    { str/tdat-val.i
      p-doc-code
      {&trdcattr-is-lgas-corr}
      varvalue
      vartype
      no-error
    }
    if varvalue = "yes"
    then do:
      is-sug-trn = yes .
      is-ptrl-trn = yes .
    end.
  end .
  
  if not is-ptrl-trn
  then do :
    return .
  end .
  
  find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code .
  
  { str/tdat-val.i
    p-doc-code
    {&trdcattr-nids}
    v-nids
    vartype
    no-error
  }
  
  for first buf_clients no-lock where buf_clients.obj-type = buf_trn-doc.cli-type
                                  and buf_clients.obj-code = buf_trn-doc.cli-code
  :
    v-cli-name = buf_clients.obj-name .
  end .
  
  v-user-name = usrfulnf(buf_trn-doc.creid) .
  
  varvalue = "" .
  { str/tdat-val.i
    p-doc-code
    {&trdcattr-autoent}
    varvalue
    vartype
    no-error
  }
  if varvalue > ""
  and num-entries(varvalue, ";") >= 2
  then do :
    for first buf_clients no-lock where buf_clients.obj-type = entry (1, varvalue, ";")
                                    and buf_clients.obj-code = integer (entry (2, varvalue, ";"))
    :
      v-auto-cli-name = buf_clients.obj-name .
    end .
  end .
  
  varvalue = "" .
  { str/tdat-val.i
    p-doc-code
    {&trdcattr-ptbobj}
    varvalue
    vartype
    no-error
  }
  if varvalue > ""
  and num-entries(varvalue, ";") >= 2
  then do :
    for first buf_clients no-lock where buf_clients.obj-type = entry (1, varvalue, ";")
                                    and buf_clients.obj-code = integer (entry (2, varvalue, ";"))
    :
      if not can-do(iOilBaseList, string(buf_clients.obj-code))
      then do :
        return .
      end .
      v-nb-cli-name = buf_clients.obj-name .
    end .
  end .
  
  { str/tdat-val.i
    p-doc-code
    {&trdcattr-car-num}
    v-car-num
    vartype
    no-error
  }
  
/*  find first sep_auto-tank-attr no-lock where sep_auto-tank-attr.auto-num = v-car-num  */
/*                                          and sep_auto-tank-attr.attr-code = "auto-sep"*/
/*                                          no-error.                                    */
/*  if available sep_auto-tank-attr                                                      */
/*  and logical(sep_auto-tank-attr.attr-value)                                           */
/*  then do :                                                                            */
/*    if iACType = 3                                                                     */
/*    then do :                                                                          */
/*      return .                                                                         */
/*    end .                                                                              */
/*    v-sep = "АЦ с СЭП" .                                                               */
/*  end .                                                                                */
/*  else do :                                                                            */
/*    if iACType = 2                                                                     */
/*    then do :                                                                          */
/*      return .                                                                         */
/*    end .                                                                              */
/*    v-sep = "АЦ без СЭП" .                                                             */
/*  end .                                                                                */
  
  { str/tdat-val.i
    p-doc-code
    {&trdcattr-fio-driver}
    v-driver-name
    vartype
    no-error
  }
  
  if is-sug-trn
  then do :
    varvalue = "" .
    { str/tdat-val.i
      p-doc-code
      {&trdcattr-time-start}
      varvalue
      vartype
      no-error
    }
    if varvalue > ""
    then do :
      assign
        v-hour-start = integer (entry (1, varvalue, ":"))
        v-min-start  = integer (entry (2, varvalue, ":"))
      no-error .
    end .
    
    varvalue = "" .
    { str/tdat-val.i
      p-doc-code
      {&trdcattr-time-end}
      varvalue
      vartype
      no-error
    }
    if varvalue > ""
    then do :
      assign
        v-hour-end = integer (entry (1, varvalue, ":"))
        v-min-end  = integer (entry (2, varvalue, ":"))
      no-error .
    end .
    
    varvalue = "" .
    { str/tdat-val.i
      p-doc-code
      {&trdcattr-date-start}
      varvalue
      vartype
      no-error
    }
    if varvalue > ""
    then do :
      v-date-start = date(varvalue) no-error .
    end .
    
    varvalue = "" .
    { str/tdat-val.i
      p-doc-code
      {&trdcattr-date-end}
      varvalue
      vartype
      no-error
    }
    if varvalue > ""
    then do :
      v-date-end = date(varvalue) no-error .
    end .
    
    v-hour-pour = v-hour-end - v-hour-start .
    v-min-pour = v-min-end - v-min-start .
    if v-min-pour < 0
    then do :
      v-hour-pour = v-hour-pour - 1 .
      v-min-pour = v-min-pour + 60 .
    end .
    v-hour-pour = v-hour-pour + (24 * (v-date-end - v-date-start)) .
    
  end .
  
  doc-line_ :
  for each buf_doc-line no-lock where buf_doc-line.doc-code = p-doc-code,
     first buf_goods no-lock where buf_goods.artic      = buf_doc-line.artic
                               and buf_goods.prod-type  = buf_doc-line.prod-type
                               and buf_goods.prod-code  = buf_doc-line.prod-code
                               and can-do(iGdsCodeList, string(buf_goods.gds-code))
  :
    { str/is-petrl.i
    buf_doc-line.artic
    buf_doc-line.prod-type
    buf_doc-line.prod-code
    is-petrolium
    is-pieces
    no-error
    }
    if not is-petrolium
    then do :
      next doc-line_ .
    end .
    
    if is-gas(buf_goods.gds-code)
    then do :
      next doc-line_ .
    end .
    
    v-is-sug-gds = no .
    if is-sug(buf_goods.gds-code)
    then do :
      v-is-sug-gds = yes .
    end .
    
    v-InfoSectionsTotal = new InfoSectionsTotal(p-doc-code, buf_goods.gds-code, "").
    
    if not v-is-sug-gds
    then do :
      do iNum = 1 to v-InfoSectionsTotal:SectionNum :
        v-InfoSection = v-InfoSectionsTotal:GetInfoSectionProp(iNum) .
        v-SectionName = v-InfoSection:SectionName .
        if v-InfoSection:IsKP
        then do :
          v-infoSectionsTotal:IsKP = yes .
          find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = {&rvs-before-doc}
                                           and buf_rvs-doc.out-code = p-doc-code
                                           and num-entries(buf_rvs-doc.rvs-code, "-") = 3
                                           and entry(2, buf_rvs-doc.rvs-code, "-") = v-SectionName
                                           no-error .
          if available buf_rvs-doc
          then do :
            v-infoSectionsTotal:IsKPrvs = yes .
          end .
        end .
        
        if v-sep = ""
        then do :
          if v-InfoSection:TankDensity > 0
          then do :
            if not v-InfoSection:IsKP
            then do :
              v-sep = "АЦ без СЭП" .
            end .
            else do :
              if trim(v-InfoSection:AukKey) > ""
              or v-InfoSection:alarm-SGDKK
              then do :
                v-sep = "АЦ с СЭП" .
              end .
              else do :
                v-sep = "АЦ без СЭП" .
              end .
            end .
          end .
          else do :
            if v-InfoSection:KPnoMeas
            then do :
              v-sep = "АЦ без СЭП" .
            end .
            else do :
              v-sep = "АЦ с СЭП" .
            end .
          end .
          if v-sep = "АЦ с СЭП" 
          and iACType = 3
          then
            return .
          if v-sep = "АЦ без СЭП" 
          and iACType = 2
          then
            return .
        end .
        
      end .
    end .
    
    do iNum = 1 to v-InfoSectionsTotal:SectionNum :
      
      v-InfoSection = v-InfoSectionsTotal:GetInfoSectionProp(iNum) .
      v-SectionName = if v-is-sug-gds then "1" else v-InfoSection:SectionName .
      is-com-tanks  = no .
      
      if v-is-sug-gds
      then do :
        for first buf_doc-pl no-lock where buf_doc-pl.obj-type = buf_doc-line.obj-type
                                       and buf_doc-pl.obj-code = buf_doc-line.obj-code
                                       and buf_doc-pl.out-code = buf_doc-line.doc-code
                                       and buf_doc-pl.gds-code = buf_goods.gds-code,
            first buf_place no-lock where buf_place.pl-code = buf_doc-pl.pl-code
        :
          
          find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = buf_place.obj-type
                                               and buf_c-place-attr.obj-code  = buf_place.obj-code
                                               and buf_c-place-attr.pl-code   = buf_place.pl-code
                                               and buf_c-place-attr.attr-code = {&place-twice-code}
                                               and (buf_c-place-attr.corr-date < buf_trn-doc.fact-date
                                                 or buf_c-place-attr.corr-date = buf_trn-doc.fact-date and buf_c-place-attr.corr-time < buf_trn-doc.fact-time)
                                               no-error .
          if available buf_c-place-attr
          then do :
            find first buf2_c-place-attr no-lock where buf2_c-place-attr.obj-type = buf_c-place-attr.obj-type
                                                   and buf2_c-place-attr.obj-code = buf_c-place-attr.obj-code
                                                   and buf2_c-place-attr.pl-code  = buf_c-place-attr.pl-code
                                                   and buf2_c-place-attr.attr-code = buf_c-place-attr.attr-code
                                                   and buf2_c-place-attr.chip-num > buf_c-place-attr.chip-num
                                                   no-error .
            if available buf2_c-place-attr
            then do :
              if buf2_c-place-attr.attr-value > ""
              then do :
                assign v-place-num  = buf_place.loc1 + "," + buf2_c-place-attr.attr-value .
              end .
              else do :
                assign v-place-num  = buf_place.loc1 .
              end .
            end .
            else do :
              run placelib_get-attr  ( input {&place-twice-code}
                ,input buf_place.obj-code
                ,input buf_place.obj-type
                ,input buf_place.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
              if varvalue <> "" then  v-place-num  = buf_place.loc1 + "," + varvalue .
              else v-place-num  = buf_place.loc1 .
            end .
          end .                                     
          else do :
            run placelib_get-attr  ( input {&place-twice-code}
              ,input buf_place.obj-code
              ,input buf_place.obj-type
              ,input buf_place.pl-code
              ,output varvalue
              ,output v-ok      ) no-error.
            if varvalue <> "" then  v-place-num  = buf_place.loc1 + "," + varvalue .
            else v-place-num  = buf_place.loc1 .
          end .
          
          
          find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = buf_place.obj-type
                                               and buf_c-place-attr.obj-code  = buf_place.obj-code
                                               and buf_c-place-attr.pl-code   = buf_place.pl-code
                                               and buf_c-place-attr.attr-code = {&place-com-tanks}
                                               and (buf_c-place-attr.corr-date < buf_trn-doc.fact-date
                                                 or buf_c-place-attr.corr-date = buf_trn-doc.fact-date and buf_c-place-attr.corr-time < buf_trn-doc.fact-time)
                                               no-error .
          if available buf_c-place-attr
          then do :
            find first buf2_c-place-attr no-lock where buf2_c-place-attr.obj-type = buf_c-place-attr.obj-type
                                                   and buf2_c-place-attr.obj-code = buf_c-place-attr.obj-code
                                                   and buf2_c-place-attr.pl-code  = buf_c-place-attr.pl-code
                                                   and buf2_c-place-attr.attr-code = buf_c-place-attr.attr-code
                                                   and buf2_c-place-attr.chip-num > buf_c-place-attr.chip-num
                                                   no-error .
            if available buf2_c-place-attr
            then do :
              if buf2_c-place-attr.attr-value > ""
              then do :
                assign
                  is-com-tanks = yes .
                  v-num-com-tanks = 1 + num-entries(buf2_c-place-attr.attr-value) .
                  v-place-num  = buf_place.loc1 + "," + buf2_c-place-attr.attr-value
                .
              end .
            end .
            else do :
              run placelib_get-attr  ( input {&place-com-tanks}
                ,input buf_place.obj-code
                ,input buf_place.obj-type
                ,input buf_place.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
              if v-ok
              and varvalue > ""
              then do :
                assign
                  is-com-tanks = yes .
                  v-num-com-tanks = 1 + num-entries(varvalue) .
                  v-place-num  = buf_place.loc1 + "," + varvalue
                .
              end .
            end .
          end .
          else do :
            run placelib_get-attr  ( input {&place-com-tanks}
              ,input buf_place.obj-code
              ,input buf_place.obj-type
              ,input buf_place.pl-code
              ,output varvalue
              ,output v-ok      ) no-error.
            if v-ok
            and varvalue > ""
            then do :
              assign
                is-com-tanks = yes .
                v-num-com-tanks = 1 + num-entries(varvalue) .
                v-place-num  = buf_place.loc1 + "," + varvalue
              .
            end .
          end .
          
        end .                           
      end .
      else do :
        v-place-num = v-InfoSection:ListTank .
        
        pl_ :
        for each buf_place no-lock where buf_place.obj-type = buf_doc-line.obj-type
                                     and buf_place.obj-code = buf_doc-line.obj-code
                                     and buf_place.loc1     = v-place-num :
          find first buf_doc-pl no-lock where buf_doc-pl.obj-type = buf_doc-line.obj-type
                                          and buf_doc-pl.obj-code = buf_doc-line.obj-code
                                          and buf_doc-pl.out-code = buf_doc-line.doc-code
                                          and buf_doc-pl.gds-code = buf_goods.gds-code
                                          and buf_doc-pl.pl-code  = buf_place.pl-code
                                          no-error .
          if available buf_doc-pl
          then do :
            leave pl_ .
          end .
        end .
        
        find last buf_c-place-attr no-lock where buf_c-place-attr.obj-type  = buf_place.obj-type
                                             and buf_c-place-attr.obj-code  = buf_place.obj-code
                                             and buf_c-place-attr.pl-code   = buf_place.pl-code
                                             and buf_c-place-attr.attr-code = {&place-com-tanks}
                                             and (buf_c-place-attr.corr-date < buf_trn-doc.fact-date
                                               or buf_c-place-attr.corr-date = buf_trn-doc.fact-date and buf_c-place-attr.corr-time < buf_trn-doc.fact-time)
                                             no-error .
        if available buf_c-place-attr
        then do :
          find first buf2_c-place-attr no-lock where buf2_c-place-attr.obj-type = buf_c-place-attr.obj-type
                                                 and buf2_c-place-attr.obj-code = buf_c-place-attr.obj-code
                                                 and buf2_c-place-attr.pl-code  = buf_c-place-attr.pl-code
                                                 and buf2_c-place-attr.attr-code = buf_c-place-attr.attr-code
                                                 and buf2_c-place-attr.chip-num > buf_c-place-attr.chip-num
                                                 no-error .
          if available buf2_c-place-attr
          then do :
            if buf2_c-place-attr.attr-value > ""
            then do :
              assign
                is-com-tanks = yes .
                v-num-com-tanks = 1 + num-entries(buf2_c-place-attr.attr-value) .
                v-place-num  = buf_place.loc1 + "," + buf2_c-place-attr.attr-value
              .
            end .
          end .
          else do :
            run placelib_get-attr  ( input {&place-com-tanks}
              ,input buf_place.obj-code
              ,input buf_place.obj-type
              ,input buf_place.pl-code
              ,output varvalue
              ,output v-ok      ) no-error.
            if v-ok
            and varvalue > ""
            then do :
              assign
                is-com-tanks = yes .
                v-num-com-tanks = 1 + num-entries(varvalue) .
                v-place-num  = buf_place.loc1 + "," + varvalue
              .
            end .
          end .
        end .
        else do :
          run placelib_get-attr  ( input {&place-com-tanks}
            ,input buf_place.obj-code
            ,input buf_place.obj-type
            ,input buf_place.pl-code
            ,output varvalue
            ,output v-ok      ) no-error.
          if v-ok
          and varvalue > ""
          then do :
            assign
              is-com-tanks = yes .
              v-num-com-tanks = 1 + num-entries(varvalue) .
              v-place-num  = buf_place.loc1 + "," + varvalue
            .
          end .
        end .
        
        v-date-start  = v-InfoSection:DateStart .
        v-date-end    = v-InfoSection:DateEnd .
        
        v-hour-start = integer( truncate( v-InfoSection:TimeStart / 3600 , 0 ) ) .
        v-min-start  = integer( truncate(( v-InfoSection:TimeStart - v-hour-start * 3600 ) / 60 , 0 )).
        
        v-hour-end   = integer( truncate( v-InfoSection:TimeEnd / 3600 , 0 ) ).
        v-min-end    = integer( truncate(( v-InfoSection:TimeEnd - v-hour-end * 3600 ) / 60 , 0 )).
        
        v-hour-pour = v-hour-end - v-hour-start .
        v-min-pour = v-min-end - v-min-start .
        if v-min-pour < 0
        then do :
          v-hour-pour = v-hour-pour - 1 .
          v-min-pour = v-min-pour + 60 .
        end .
        v-hour-pour = v-hour-pour + (24 * (v-date-end - v-date-start)) .
        
      end .
      
      if v-infoSectionsTotal:IsKPrvs
      then do :
        find first tt-rep where tt-rep.obj-type   = obj-list.obj-type
                            and tt-rep.obj-code   = obj-list.obj-code
                            and tt-rep.gds-code   = buf_goods.gds-code 
                            and tt-rep.col3       = buf_trn-doc.doc-code
                            and tt-rep.col15      = v-SectionName
                            and tt-rep.col17      = v-place-num
                            no-error .
      end .
      else do :
        find first tt-rep where tt-rep.obj-type   = obj-list.obj-type
                            and tt-rep.obj-code   = obj-list.obj-code
                            and tt-rep.gds-code   = buf_goods.gds-code 
                            and tt-rep.col3       = buf_trn-doc.doc-code
                            and tt-rep.col17      = v-place-num
                            no-error .
      end .
      if not available tt-rep
      then do : 
        create tt-rep .
        assign
          tt-rep.obj-type   = obj-list.obj-type
          tt-rep.obj-code   = obj-list.obj-code
          tt-rep.gds-code   = buf_goods.gds-code
          tt-rep.shift-date = buf_trn-doc.shift-date
          tt-rep.shift-num  = buf_trn-doc.shift-num
          tt-rep.min-pour   = (v-hour-pour * 60) + v-min-pour
          tt-rep.col1       = obj-list.obj-name
          tt-rep.col2       = string(tt-rep.shift-num) + " от " + string(tt-rep.shift-date)
          tt-rep.col3       = buf_trn-doc.doc-code
          tt-rep.col4       = v-nids
          tt-rep.col5       = string(v-date-start) + "<br>" + {&new-line} + string(v-hour-start, "99") + ":" + string(v-min-start, "99") + ":00"
          tt-rep.col6       = string(v-date-end) + "<br>" + {&new-line} + string(v-hour-end, "99") + ":" + string(v-min-end, "99") + ":00"
          tt-rep.col7       = string(v-hour-pour) + ":" + string(v-min-pour, "99") + ":00"
          tt-rep.col8       = v-cli-name
          tt-rep.col9       = v-auto-cli-name
          tt-rep.col10      = v-nb-cli-name
          tt-rep.col11      = v-car-num
          tt-rep.col12      = v-sep
          tt-rep.col13      = v-driver-name
          tt-rep.col14      = v-user-name
          tt-rep.col15      = v-SectionName
          tt-rep.col16      = buf_goods.gds-name
          tt-rep.col17      = v-place-num 
          tt-rep.col18      = (if v-sep = "АЦ без СЭП" then "" else if v-InfoSection:alarm-SGDKK then "ВУ" else "НУ")
          tt-rep.col19      = v-InfoSection:AukKey
          tt-rep.col35      = "Нет"
          tt-rep.col50      = "Нет"
          tt-rep.col51      = "АВД"
        .
        
        if v-InfoSection:isKP
        then do :
          if v-InfoSection:AccMeth = 1
          then do :
            tt-rep.col50 = "Да (резервуар)" .
          end . 
          else do :
            tt-rep.col50 = "Да (АЦ)" .
          end .
        end .
        
        if v-InfoSection:TankWeight > 0
        then
          tt-rep.ac-measured = yes
        .
        else
          tt-rep.ac-measured = no
        .
        
        if v-is-sug-gds
        then do :
          assign
            tt-rep.col20  = buf_doc-line.doc-qnty
            tt-rep.col21  = buf_doc-line.cli-qnty
            tt-rep.col22  = buf_doc-line.doc-density
            tt-rep.col23  = buf_doc-line.temperature
          .
          assign
            tt-rep.col24  = ?
            tt-rep.col25  = ?
            tt-rep.col26  = ?
            tt-rep.col27  = ?
            tt-rep.col28  = ?
          .
        end .
        else do :
          assign
            tt-rep.col20  = if v-InfoSection:DocVolume > 0 then v-InfoSection:DocVolume else v-InfoSection:DocQnty
            tt-rep.col21  = v-InfoSection:CliQnty
            tt-rep.col22  = v-InfoSection:DocDensity
            tt-rep.col23  = v-InfoSection:TTNTemp
          .
          assign
            tt-rep.col24  = if v-InfoSection:TankVolPomi > 0 then v-InfoSection:TankVolPomi else v-InfoSection:TankVol
            tt-rep.col25  = v-InfoSection:TankWeight
            tt-rep.col26  = v-InfoSection:NaturalLoss
            tt-rep.col27  = if v-InfoSection:TankDensityPomi > 0 then v-InfoSection:TankDensityPomi else v-InfoSection:TankDensity
            tt-rep.col28  = v-InfoSection:TankTemp
          .
        end .
        
        assign
          tt-rep.col20str =  fDec2Str(tt-rep.col20, "->>>>>>>>>>>9"  )
          tt-rep.col21str =  fDec2Str(tt-rep.col21, "->>>>>>>>>>>9.9")
          tt-rep.col22str =  fDec2Str(tt-rep.col22, "->>>>>>>>9.9999")
          tt-rep.col23str =  fDec2Str(tt-rep.col23, "->>>>>>>>>>>9.9")
                             
          tt-rep.col24str =  fDec2Str(tt-rep.col24, "->>>>>>>>>>>9"  )
          tt-rep.col25str =  fDec2Str(tt-rep.col25, "->>>>>>>>>>>9.9")
          tt-rep.col26str =  fDec2Str(tt-rep.col26, "->>>>>>>>>>9.99")
          tt-rep.col27str =  fDec2Str(tt-rep.col27, "->>>>>>>>9.9999")
          tt-rep.col28str =  fDec2Str(tt-rep.col28, "->>>>>>>>>>>9.9")
        .
        
        assign
          tt-rep.delta-mass-qnty-before = 0.65
          tt-rep.delta-mass-qnty-after = 0.65
          tt-rep.delta-mass-qnty-ac = 0.65
        .
        
        v-delta-mass-qnty-ac = v-InfoSection:AccPomi .
        if v-delta-mass-qnty-ac = 0 
        or v-delta-mass-qnty-ac = ?
        then do :
          v-delta-mass-qnty-ac = v-InfoSectionsTotal:PercAcc .
        end .
        if v-delta-mass-qnty-ac = 0 
        or v-delta-mass-qnty-ac = ?
        then do :
          v-delta-mass-qnty-ac = 0.65 .
        end .
        
        if v-delta-mass-qnty-ac > 0.65 then v-delta-mass-qnty-ac = 0.65 .
        
        assign
          tt-rep.delta-mass-qnty-ac = v-delta-mass-qnty-ac
        .
        
        for each buf_place no-lock where buf_place.obj-type = buf_doc-line.obj-type
                                     and buf_place.obj-code = buf_doc-line.obj-code
                                     and buf_place.loc1     = tt-rep.col17
        :
          empty temp-table tt-rvs-line-pump-delta .
          
          find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = {&rvs-before-doc}
                                           and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                           and num-entries(buf_rvs-doc.rvs-code, "-") = 3
                                           and entry(2, buf_rvs-doc.rvs-code, "-") = tt-rep.col15
                                           no-error .
          if not available buf_rvs-doc
          then do :
            find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = {&rvs-before-doc}
                                             and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                             no-error .
          end .
          if available buf_rvs-doc
          then do :
            for first buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                             and buf_rvs-line.gds-code = buf_goods.gds-code
                                             and buf_rvs-line.pl-code  = buf_place.pl-code
            :
              assign
                tt-rep.col29  = buf_rvs-line.state-measure-qnty
                tt-rep.col30  = buf_rvs-line.state-measure-cli-qnty
                tt-rep.col31  = buf_rvs-line.state-density
                tt-rep.col32  = buf_rvs-line.state-temperature
              .
              assign
                tt-rep.col29str = fDec2Str(buf_rvs-line.state-measure-qnty, "->>>>>>>>>>>9")
                tt-rep.col30str = fDec2Str(buf_rvs-line.state-measure-cli-qnty, "->>>>>>>>>>>9.9")
                tt-rep.col31str = fDec2Str(buf_rvs-line.state-density, "->>>>>>>>9.9999")
                tt-rep.col32str = fDec2Str(buf_rvs-line.state-temperature, "->>>>>>>>>>>9.9")
              .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code = "temp-izm-vol"
              :
                assign
                  tt-rep.col32 = decimal(buf_rvs-line-attr.attr-value)
                  tt-rep.col32str = fDec2Str(decimal(buf_rvs-line-attr.attr-value), "->>>>>>>>>>>9.9")
                .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code = "delta-mass-qnty"
              :
                tt-rep.delta-mass-qnty-before = decimal(buf_rvs-line-attr.attr-value) .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code begins "input-type"
                                                    and buf_rvs-line-attr.attr-value <> 'а'
              :
                tt-rep.col51 = "РВД" .
              end .
              
              for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                   and buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                   and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                   and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                   and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
              :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < buf_trn-doc.fact-date
                                                        or buf_c-pl-gds-pump.corr-date = buf_trn-doc.fact-date and buf_c-pl-gds-pump.corr-time < buf_trn-doc.fact-time)
                                                      no-error .
                if available buf_c-pl-gds-pump
                then do :
                  find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                          and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                          and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                          and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                          and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                          and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                          no-error .
                  if available buf2_c-pl-gds-pump
                  then do :
                    v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                  end .
                  else do :
                    for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                        and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                        and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                        and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                        and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                    :
                      v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                    end .
                  end .
                end .
                else do :
                  for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                  :
                    v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                  end .
                end .
                
                if v-pl-gds-pump-status_ = {&current-status}
                then do :
                  create tt-rvs-line-pump-delta .
                  buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                  assign
                    tt-rvs-line-pump-delta.rvs-code = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                  .
                  if tt-rvs-line-pump-delta.state-el-cnt = ?
                  or tt-rvs-line-pump-delta.state-el-cnt <= 0
                  then do :
                    tt-rvs-line-pump-delta.is-err = yes .
                  end .
                end .
              end. /* for each bf_rvs-line-pump */
            end .
          end .
          find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = {&rvs-after-doc}
                                           and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                           and num-entries(buf_rvs-doc.rvs-code, "-") = 3
                                           and entry(2, buf_rvs-doc.rvs-code, "-") = tt-rep.col15
                                           no-error .
          if not available buf_rvs-doc
          then do :
            find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = {&rvs-after-doc}
                                             and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                             no-error .
          end .
          if available buf_rvs-doc
          then do :
            for first buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                             and buf_rvs-line.gds-code = buf_goods.gds-code
                                             and buf_rvs-line.pl-code  = buf_place.pl-code
            :
              assign
                tt-rep.col36  = buf_rvs-line.state-measure-qnty
                tt-rep.col37  = buf_rvs-line.state-measure-cli-qnty
                tt-rep.col38  = buf_rvs-line.state-density
                tt-rep.col39  = buf_rvs-line.state-temperature
              .
              assign
                tt-rep.col36str = fDec2Str(buf_rvs-line.state-measure-qnty, "->>>>>>>>>>>9")
                tt-rep.col37str = fDec2Str(buf_rvs-line.state-measure-cli-qnty, "->>>>>>>>>>>9.9")
                tt-rep.col38str = fDec2Str(buf_rvs-line.state-density, "->>>>>>>>9.9999")
                tt-rep.col39str = fDec2Str(buf_rvs-line.state-temperature, "->>>>>>>>>>>9.9")
              .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code = "temp-izm-vol"
              :
                assign
                  tt-rep.col39 = decimal(buf_rvs-line-attr.attr-value)
                  tt-rep.col39str = fDec2Str(decimal(buf_rvs-line-attr.attr-value), "->>>>>>>>>>>9.9")
                .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code = "delta-mass-qnty"
              :
                tt-rep.delta-mass-qnty-after = decimal(buf_rvs-line-attr.attr-value) .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code begins "input-type"
                                                    and buf_rvs-line-attr.attr-value <> 'а'
              :
                tt-rep.col51 = "РВД" .
              end .
              
              for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                   and buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                   and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                   and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                   and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
              :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < buf_trn-doc.fact-date
                                                        or buf_c-pl-gds-pump.corr-date = buf_trn-doc.fact-date and buf_c-pl-gds-pump.corr-time < buf_trn-doc.fact-time)
                                                      no-error .
                if available buf_c-pl-gds-pump
                then do :
                  find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                          and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                          and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                          and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                          and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                          and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                          no-error .
                  if available buf2_c-pl-gds-pump
                  then do :
                    v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                  end .
                  else do :
                    for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                        and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                        and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                        and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                        and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                    :
                      v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                    end .
                  end .
                end .
                else do :
                  for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                  :
                    v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                  end .
                end .
                
                if v-pl-gds-pump-status_ = {&current-status}
                then do :
                  find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.rvs-code    = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                                                      and tt-rvs-line-pump-delta.obj-type    = buf_rvs-line-pump.obj-type
                                                      and tt-rvs-line-pump-delta.obj-code    = buf_rvs-line-pump.obj-code
                                                      and tt-rvs-line-pump-delta.pl-code     = buf_rvs-line-pump.pl-code
                                                      and tt-rvs-line-pump-delta.gds-code    = buf_rvs-line-pump.gds-code
                                                      and tt-rvs-line-pump-delta.pump-code   = buf_rvs-line-pump.pump-code
                                                      and tt-rvs-line-pump-delta.nozzle-code = buf_rvs-line-pump.nozzle-code
                                                      no-error .
                  if not available tt-rvs-line-pump-delta
                  then do :
                    create tt-rvs-line-pump-delta .
                    buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                    assign
                      tt-rvs-line-pump-delta.rvs-code = "after-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                      tt-rvs-line-pump-delta.is-err = yes
                    .
                  end .
                  else do :
                    tt-rvs-line-pump-delta.find-pair = yes .
                    if tt-rvs-line-pump-delta.state-el-cnt > buf_rvs-line-pump.state-el-cnt
                    then do :
                      tt-rvs-line-pump-delta.is-err = yes .
                    end .
                    else do :
                      tt-rvs-line-pump-delta.deltaVol = buf_rvs-line-pump.state-el-cnt - tt-rvs-line-pump-delta.state-el-cnt .
                    end .
                  end .
                end .
              end . /* for each buf_rvs-line-pump */
            end .
          end .
          
          for each tt-rvs-line-pump-delta :
            if not tt-rvs-line-pump-delta.find-pair
            then do :
              tt-rvs-line-pump-delta.is-err = yes .
            end .
            if tt-rvs-line-pump-delta.is-err = yes
            then do :
              tt-rvs-line-pump-delta.deltaVol = 0 .
              tt-rep.col35 = "Есть" .
            end .
            tt-rep.col33 = tt-rep.col33 + tt-rvs-line-pump-delta.deltaVol .
          end .
          
          v-avrg-dens = (tt-rep.col31 + tt-rep.col38) / 2 .
          
          tt-rep.col34 = tt-rep.col33 * v-avrg-dens .
        end .
        
        if is-com-tanks
        and not available buf_place
        then do :
          empty temp-table tt-rvs-line-pump-delta .
          find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = {&rvs-before-doc}
                                           and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                           and num-entries(buf_rvs-doc.rvs-code, "-") = 3
                                           and entry(2, buf_rvs-doc.rvs-code, "-") = tt-rep.col15
                                           no-error .
          if not available buf_rvs-doc
          then do :
            find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = {&rvs-before-doc}
                                             and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                             no-error .
          end .
          if available buf_rvs-doc
          then do :
            for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                            and buf_rvs-line.gds-code = buf_goods.gds-code,
              first buf_place no-lock where buf_place.obj-type = buf_rvs-line.obj-type
                                        and buf_place.obj-code = buf_rvs-line.obj-code
                                        and buf_place.pl-code  = buf_rvs-line.pl-code
            :
              if not can-do(v-place-num, buf_place.loc1) then next .
              assign
                tt-rep.col29  = tt-rep.col29 + buf_rvs-line.state-measure-qnty
                tt-rep.col30  = tt-rep.col30 + buf_rvs-line.state-measure-cli-qnty
              .
              assign
                tt-rep.col29str = tt-rep.col29str + fDec2Str(buf_rvs-line.state-measure-qnty, "->>>>>>>>>>>9") + "<br>" + {&new-line}
                tt-rep.col30str = tt-rep.col30str + fDec2Str(buf_rvs-line.state-measure-cli-qnty, "->>>>>>>>>>>9.9") + "<br>" + {&new-line}
                tt-rep.col31str = tt-rep.col31str + fDec2Str(buf_rvs-line.state-density, "->>>>>>>>9.9999") + "<br>" + {&new-line}
              .
              run placelib_get-attr  ( input {&place-is-main}
                ,input buf_rvs-line.obj-code
                ,input buf_rvs-line.obj-type
                ,input buf_rvs-line.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
              if v-ok
              and varvalue > ""
              and logical(varvalue)
              then do :
                assign v-avrg-dens = buf_rvs-line.state-density .
              end .
              find first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                     and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                     and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                     and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                     and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                     and buf_rvs-line-attr.attr-code = "temp-izm-vol"
                                                     no-error .
              if available buf_rvs-line-attr
              and buf_rvs-line-attr.attr-value > ""
              then do :
                assign
                  tt-rep.col32 = tt-rep.col32 + decimal(buf_rvs-line-attr.attr-value)
                  
                  tt-rep.col32str = tt-rep.col32str + fDec2Str(decimal(buf_rvs-line-attr.attr-value), "->>>>>>>>>>>9.9") + "<br>" + {&new-line}
                .
              end .
              else do :
                assign
                  tt-rep.col32  = tt-rep.col32 + buf_rvs-line.state-temperature
                  
                  tt-rep.col32str = tt-rep.col32str + fDec2Str(buf_rvs-line.state-temperature, "->>>>>>>>>>>9.9") + "<br>" + {&new-line}
                .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code = "delta-mass-qnty"
              :
                tt-rep.delta-mass-qnty-before = decimal(buf_rvs-line-attr.attr-value) .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code begins "input-type"
                                                    and buf_rvs-line-attr.attr-value <> 'а'
              :
                tt-rep.col51 = "РВД" .
              end .
              
              for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                   and buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                   and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                   and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                   and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
              :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < buf_trn-doc.fact-date
                                                        or buf_c-pl-gds-pump.corr-date = buf_trn-doc.fact-date and buf_c-pl-gds-pump.corr-time < buf_trn-doc.fact-time)
                                                      no-error .
                if available buf_c-pl-gds-pump
                then do :
                  find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                          and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                          and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                          and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                          and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                          and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                          no-error .
                  if available buf2_c-pl-gds-pump
                  then do :
                    v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                  end .
                  else do :
                    for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                        and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                        and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                        and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                        and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                    :
                      v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                    end .
                  end .
                end .
                else do :
                  for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                  :
                    v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                  end .
                end .
                
                if v-pl-gds-pump-status_ = {&current-status}
                then do :
                  create tt-rvs-line-pump-delta .
                  buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                  assign
                    tt-rvs-line-pump-delta.rvs-code = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                  .
                  if tt-rvs-line-pump-delta.state-el-cnt = ?
                  or tt-rvs-line-pump-delta.state-el-cnt <= 0
                  then do :
                    tt-rvs-line-pump-delta.is-err = yes .
                  end .
                end .
              end. /* for each bf_rvs-line-pump */
            end .
            assign
              tt-rep.col31 = tt-rep.col30 / tt-rep.col29
              tt-rep.col32 = tt-rep.col32 / v-num-com-tanks
            .
          end .
          find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = {&rvs-after-doc}
                                           and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                           and num-entries(buf_rvs-doc.rvs-code, "-") = 3
                                           and entry(2, buf_rvs-doc.rvs-code, "-") = tt-rep.col15
                                           no-error .
          if not available buf_rvs-doc
          then do :
            find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = {&rvs-after-doc}
                                             and buf_rvs-doc.out-code = buf_doc-line.doc-code
                                             no-error .
          end .
          if available buf_rvs-doc
          then do :
            for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                            and buf_rvs-line.gds-code = buf_goods.gds-code,
              first buf_place no-lock where buf_place.obj-type = buf_rvs-line.obj-type
                                        and buf_place.obj-code = buf_rvs-line.obj-code
                                        and buf_place.pl-code  = buf_rvs-line.pl-code
            :
              if not can-do(v-place-num, buf_place.loc1) then next .
              assign
                tt-rep.col36  = tt-rep.col36 + buf_rvs-line.state-measure-qnty
                tt-rep.col37  = tt-rep.col37 + buf_rvs-line.state-measure-cli-qnty
              .
              assign
                tt-rep.col36str = tt-rep.col36str + fDec2Str(buf_rvs-line.state-measure-qnty, "->>>>>>>>>>>9") + "<br>" + {&new-line}
                tt-rep.col37str = tt-rep.col37str + fDec2Str(buf_rvs-line.state-measure-cli-qnty, "->>>>>>>>>>>9.9") + "<br>" + {&new-line}
                tt-rep.col38str = tt-rep.col38str + fDec2Str(buf_rvs-line.state-density, "->>>>>>>>9.9999") + "<br>" + {&new-line}
              .
              run placelib_get-attr  ( input {&place-is-main}
                ,input buf_rvs-line.obj-code
                ,input buf_rvs-line.obj-type
                ,input buf_rvs-line.pl-code
                ,output varvalue
                ,output v-ok      ) no-error.
              if v-ok
              and varvalue > ""
              and logical(varvalue)
              then do :
                assign v-avrg-dens = (v-avrg-dens + buf_rvs-line.state-density) / 2 .
              end .
              find first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                     and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                     and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                     and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                     and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                     and buf_rvs-line-attr.attr-code = "temp-izm-vol"
                                                     no-error .
              if available buf_rvs-line-attr
              and buf_rvs-line-attr.attr-value > ""
              then do :
                assign
                  tt-rep.col39 = tt-rep.col39 + decimal(buf_rvs-line-attr.attr-value)
                  
                  tt-rep.col39str = tt-rep.col39str + fDec2Str(decimal(buf_rvs-line-attr.attr-value), "->>>>>>>>>>>9.9") + "<br>" + {&new-line}
                .
              end .
              else do :
                assign
                  tt-rep.col39  = tt-rep.col39 + buf_rvs-line.state-temperature
                  
                  tt-rep.col39str = tt-rep.col39str + fDec2Str(buf_rvs-line.state-temperature, "->>>>>>>>>>>9.9") + "<br>" + {&new-line}
                .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code = "delta-mass-qnty"
              :
                tt-rep.delta-mass-qnty-after = decimal(buf_rvs-line-attr.attr-value) .
              end .
              for first buf_rvs-line-attr no-lock where buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                                    and buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                                    and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                                    and buf_rvs-line-attr.pl-code  = buf_rvs-line.pl-code
                                                    and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                                    and buf_rvs-line-attr.attr-code begins "input-type"
                                                    and buf_rvs-line-attr.attr-value <> 'а'
              :
                tt-rep.col51 = "РВД" .
              end .
              
              for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                                   and buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                                   and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                                   and buf_rvs-line-pump.pl-code  = buf_rvs-line.pl-code
                                                   and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code
              :
                find last buf_c-pl-gds-pump no-lock where buf_c-pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_c-pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_c-pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                                                      and buf_c-pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_c-pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and (buf_c-pl-gds-pump.corr-date < buf_trn-doc.fact-date
                                                        or buf_c-pl-gds-pump.corr-date = buf_trn-doc.fact-date and buf_c-pl-gds-pump.corr-time < buf_trn-doc.fact-time)
                                                      no-error .
                if available buf_c-pl-gds-pump
                then do :
                  find first buf2_c-pl-gds-pump no-lock where buf2_c-pl-gds-pump.obj-type = buf_c-pl-gds-pump.obj-type
                                                          and buf2_c-pl-gds-pump.obj-code = buf_c-pl-gds-pump.obj-code
                                                          and buf2_c-pl-gds-pump.pl-code  = buf_c-pl-gds-pump.pl-code
                                                          and buf2_c-pl-gds-pump.gds-code = buf_c-pl-gds-pump.gds-code
                                                          and buf2_c-pl-gds-pump.pump-code = buf_c-pl-gds-pump.pump-code
                                                          and buf2_c-pl-gds-pump.chip-num > buf_c-pl-gds-pump.chip-num
                                                          no-error .
                  if available buf2_c-pl-gds-pump
                  then do :
                    v-pl-gds-pump-status_ = buf2_c-pl-gds-pump.status_ .
                  end .
                  else do :
                    for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                        and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                        and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                        and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                        and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                    :
                      v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                    end .
                  end .
                end .
                else do :
                  for first buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = buf_rvs-line-pump.obj-type
                                                      and buf_pl-gds-pump.obj-code = buf_rvs-line-pump.obj-code
                                                      and buf_pl-gds-pump.gds-code = buf_rvs-line-pump.gds-code
                                                      and buf_pl-gds-pump.pump-code = buf_rvs-line-pump.pump-code
                                                      and buf_pl-gds-pump.pl-code  = buf_rvs-line-pump.pl-code
                  :
                    v-pl-gds-pump-status_ = buf_pl-gds-pump.status_ .
                  end .
                end .
                
                if v-pl-gds-pump-status_ = {&current-status}
                then do :
                  find first tt-rvs-line-pump-delta where tt-rvs-line-pump-delta.rvs-code    = "before-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                                                      and tt-rvs-line-pump-delta.obj-type    = buf_rvs-line-pump.obj-type
                                                      and tt-rvs-line-pump-delta.obj-code    = buf_rvs-line-pump.obj-code
                                                      and tt-rvs-line-pump-delta.pl-code     = buf_rvs-line-pump.pl-code
                                                      and tt-rvs-line-pump-delta.gds-code    = buf_rvs-line-pump.gds-code
                                                      and tt-rvs-line-pump-delta.pump-code   = buf_rvs-line-pump.pump-code
                                                      and tt-rvs-line-pump-delta.nozzle-code = buf_rvs-line-pump.nozzle-code
                                                      no-error .
                  if not available tt-rvs-line-pump-delta
                  then do :
                    create tt-rvs-line-pump-delta .
                    buffer-copy buf_rvs-line-pump to tt-rvs-line-pump-delta
                    assign
                      tt-rvs-line-pump-delta.rvs-code = "after-doc" + entry(2, buf_rvs-line-pump.rvs-code, "-")
                      tt-rvs-line-pump-delta.is-err = yes
                    .
                  end .
                  else do :
                    tt-rvs-line-pump-delta.find-pair = yes .
                    if tt-rvs-line-pump-delta.state-el-cnt > buf_rvs-line-pump.state-el-cnt
                    then do :
                      tt-rvs-line-pump-delta.is-err = yes .
                    end .
                    else do :
                      tt-rvs-line-pump-delta.deltaVol = buf_rvs-line-pump.state-el-cnt - tt-rvs-line-pump-delta.state-el-cnt .
                    end .
                  end .
                end .
              end . /* for each buf_rvs-line-pump */
            end .
            assign
              tt-rep.col38 = tt-rep.col37 / tt-rep.col36
              tt-rep.col39 = tt-rep.col39 / v-num-com-tanks
            .
          end .
          for each tt-rvs-line-pump-delta :
            if not tt-rvs-line-pump-delta.find-pair
            then do :
              tt-rvs-line-pump-delta.is-err = yes .
            end .
            if tt-rvs-line-pump-delta.is-err = yes
            then do :
              tt-rvs-line-pump-delta.deltaVol = 0 .
              tt-rep.col35 = "Есть" .
            end .
            tt-rep.col33 = tt-rep.col33 + tt-rvs-line-pump-delta.deltaVol .
          end .
          assign tt-rep.col34 = tt-rep.col33 * v-avrg-dens .
          assign
            tt-rep.col29str = trim(tt-rep.col29str, "<br>" + {&new-line})
            tt-rep.col30str = trim(tt-rep.col30str, "<br>" + {&new-line})
            tt-rep.col31str = trim(tt-rep.col31str, "<br>" + {&new-line})
            tt-rep.col32str = trim(tt-rep.col32str, "<br>" + {&new-line})
            
            tt-rep.col36str = trim(tt-rep.col36str, "<br>" + {&new-line})
            tt-rep.col37str = trim(tt-rep.col37str, "<br>" + {&new-line})
            tt-rep.col38str = trim(tt-rep.col38str, "<br>" + {&new-line})
            tt-rep.col39str = trim(tt-rep.col39str, "<br>" + {&new-line})
          .
        end .
        
        if tt-rep.col34 = ? then tt-rep.col34 = 0 .
        
        assign
          tt-rep.col40  = v-InfoSection:FactQnty
          tt-rep.col41  = v-InfoSection:FactKgQnty
        .
        
        if v-InfoSection:TankWeight > 0
        then do :
          assign
            tt-rep.col42  = tt-rep.col25 - tt-rep.col21
            tt-rep.col43  = tt-rep.col42 / tt-rep.col21 * 100
          .
        
          assign
            tt-rep.col44  = tt-rep.col37 + tt-rep.col34 - tt-rep.col30 - tt-rep.col25
            tt-rep.col45  = tt-rep.col44 / tt-rep.col25 * 100
          .
        end .
        
        assign
          tt-rep.col46  = tt-rep.col37 + tt-rep.col34 - tt-rep.col30 - tt-rep.col41
          tt-rep.col47  = tt-rep.col46 / tt-rep.col41 * 100
        .
        
        v-delta-ac = sqrt(exp((tt-rep.col37 * tt-rep.delta-mass-qnty-after), 2) + exp((tt-rep.col30 * tt-rep.delta-mass-qnty-before), 2) + exp((tt-rep.col34 * 0.5), 2) + exp((tt-rep.col25 * tt-rep.delta-mass-qnty-ac), 2)) / 100 .
        v-delta-fact = sqrt(exp((tt-rep.col37 * tt-rep.delta-mass-qnty-after), 2) + exp((tt-rep.col34 * 0.5), 2) + exp((tt-rep.col30 * tt-rep.delta-mass-qnty-before), 2)) / 100 .
        
        if v-delta-ac > abs(tt-rep.col44)
        then do :
          tt-rep.col48 = 0 .
        end .
        else do :
          tt-rep.col48 = abs(tt-rep.col44) - v-delta-ac .
          if tt-rep.col44 < 0
          then 
            tt-rep.col48 = tt-rep.col48 * -1
          .
        end .
        
        if v-is-sug-gds
        then do :
          tt-rep.col48 = 0 .
        end .
        
        if v-delta-fact > abs(tt-rep.col46)
        then do :
          tt-rep.col49 = 0 .
        end .
        else do :
          tt-rep.col49 = abs(tt-rep.col46) - v-delta-fact .
          if tt-rep.col46 < 0
          then 
            tt-rep.col49 = tt-rep.col49 * -1
          .
        end .
      end . /* if not available tt-rep */
      else do :
        if v-InfoSection:isKP
        then do :
          if v-InfoSection:AccMeth = 1
          then do :
            tt-rep.col50 = "Да (резервуар)" .
          end . 
          else do :
            tt-rep.col50 = "Да (АЦ)" .
          end .
        end .
        
        if v-InfoSection:TankWeight > 0
        and tt-rep.ac-measured = yes
        then
          tt-rep.ac-measured = yes
        .
        else
          tt-rep.ac-measured = no
        .
        
        assign
          tt-rep.col15 = tt-rep.col15 + "," + v-SectionName
          tt-rep.col18 = tt-rep.col18 + "<br>" + {&new-line} + (if v-sep = "АЦ без СЭП" then "" else if v-InfoSection:alarm-SGDKK then "ВУ" else "НУ")
          tt-rep.col19 = tt-rep.col19 + "<br>" + {&new-line} + v-InfoSection:AukKey
        .
        
        
        v-delta-mass-qnty-ac = v-InfoSection:AccPomi .
        if v-delta-mass-qnty-ac = 0 
        or v-delta-mass-qnty-ac = ?
        then do :
          v-delta-mass-qnty-ac = v-InfoSectionsTotal:PercAcc .
        end .
        if v-delta-mass-qnty-ac = 0 
        or v-delta-mass-qnty-ac = ?
        then do :
          v-delta-mass-qnty-ac = 0.65 .
        end .
        
        if v-delta-mass-qnty-ac > 0.65 then v-delta-mass-qnty-ac = 0.65 .
        
        assign
          tt-rep.delta-mass-qnty-ac = tt-rep.delta-mass-qnty-ac + v-delta-mass-qnty-ac
        .
        
        assign
          tt-rep.col20  = tt-rep.col20 + if v-InfoSection:DocVolume > 0 then v-InfoSection:DocVolume else v-InfoSection:DocQnty
          tt-rep.col21  = tt-rep.col21 + v-InfoSection:CliQnty
          tt-rep.col22  = tt-rep.col22 + v-InfoSection:DocDensity
          tt-rep.col23  = tt-rep.col23 + v-InfoSection:TTNTemp
        .
        assign
          tt-rep.col24  = tt-rep.col24 + (if v-InfoSection:TankVolPomi > 0 then v-InfoSection:TankVolPomi else v-InfoSection:TankVol)
          tt-rep.col25  = tt-rep.col25 + v-InfoSection:TankWeight
          tt-rep.col26  = tt-rep.col26 + v-InfoSection:NaturalLoss
          tt-rep.col27  = tt-rep.col27 + (if v-InfoSection:TankDensityPomi > 0 then v-InfoSection:TankDensityPomi else v-InfoSection:TankDensity)
          tt-rep.col28  = tt-rep.col28 + v-InfoSection:TankTemp
        .
        
        assign
          tt-rep.col20str = tt-rep.col20str + "<br>" + {&new-line} + fDec2Str((if v-InfoSection:DocVolume > 0 then v-InfoSection:DocVolume else v-InfoSection:DocQnty), "->>>>>>>>>>>9"  )
          tt-rep.col21str = tt-rep.col21str + "<br>" + {&new-line} + fDec2Str(v-InfoSection:CliQnty, "->>>>>>>>>>>9.9")
          tt-rep.col22str = tt-rep.col22str + "<br>" + {&new-line} + fDec2Str(v-InfoSection:DocDensity, "->>>>>>>>9.9999")
          tt-rep.col23str = tt-rep.col23str + "<br>" + {&new-line} + fDec2Str(v-InfoSection:TTNTemp, "->>>>>>>>>>>9.9")
                                             
          tt-rep.col24str = tt-rep.col24str + "<br>" + {&new-line} + fDec2Str((if v-InfoSection:TankVolPomi > 0 then v-InfoSection:TankVolPomi else v-InfoSection:TankVol), "->>>>>>>>>>>9"  )
          tt-rep.col25str = tt-rep.col25str + "<br>" + {&new-line} + fDec2Str(v-InfoSection:TankWeight, "->>>>>>>>>>>9.9")
          tt-rep.col26str = tt-rep.col26str + "<br>" + {&new-line} + fDec2Str(v-InfoSection:NaturalLoss, "->>>>>>>>>>9.99")
          tt-rep.col27str = tt-rep.col27str + "<br>" + {&new-line} + fDec2Str((if v-InfoSection:TankDensityPomi > 0 then v-InfoSection:TankDensityPomi else v-InfoSection:TankDensity), "->>>>>>>>9.9999")
          tt-rep.col28str = tt-rep.col28str + "<br>" + {&new-line} + fDec2Str(v-InfoSection:TankTemp, "->>>>>>>>>>>9.9")
        .
        
        assign
          tt-rep.col40  = tt-rep.col40 + v-InfoSection:FactQnty
          tt-rep.col41  = tt-rep.col41 + v-InfoSection:FactKgQnty
        .
        
        if tt-rep.ac-measured
        then do :
          assign
            tt-rep.col42  = tt-rep.col25 - tt-rep.col21
            tt-rep.col43  = tt-rep.col42 / tt-rep.col21 * 100
          .
        
          assign
            tt-rep.col44  = tt-rep.col37 + tt-rep.col34 - tt-rep.col30 - tt-rep.col25
            tt-rep.col45  = tt-rep.col44 / tt-rep.col25 * 100
          .
        end .
        else do :
          assign
            tt-rep.col42  = 0
            tt-rep.col43  = 0
            tt-rep.col44  = 0
            tt-rep.col45  = 0
          .
        end .
        
        assign
          tt-rep.col46  = tt-rep.col37 + tt-rep.col34 - tt-rep.col30 - tt-rep.col41
          tt-rep.col47  = tt-rep.col46 / tt-rep.col41 * 100
        .
        
      end .
      
    end .
    
    delete object v-InfoSectionsTotal no-error .
    
    for each tt-rep where tt-rep.obj-type   = obj-list.obj-type
                      and tt-rep.obj-code   = obj-list.obj-code
                      and tt-rep.gds-code   = buf_goods.gds-code 
                      and tt-rep.col3       = buf_trn-doc.doc-code
                      and num-entries(tt-rep.col15) > 1
    :
      assign
        tt-rep.col22  = tt-rep.col22 / num-entries(tt-rep.col15)
        tt-rep.col23  = tt-rep.col23 / num-entries(tt-rep.col15)
        
        tt-rep.col27  = tt-rep.col27 / num-entries(tt-rep.col15)
        tt-rep.col28  = tt-rep.col28 / num-entries(tt-rep.col15)
      .
      
      assign
        tt-rep.delta-mass-qnty-ac = tt-rep.delta-mass-qnty-ac / num-entries(tt-rep.col15)
      .
      
      v-delta-ac = sqrt(exp((tt-rep.col37 * tt-rep.delta-mass-qnty-after), 2) + exp((tt-rep.col30 * tt-rep.delta-mass-qnty-before), 2) + exp((tt-rep.col34 * 0.5), 2) + exp((tt-rep.col25 * tt-rep.delta-mass-qnty-ac), 2)) / 100 .
      v-delta-fact = sqrt(exp((tt-rep.col37 * tt-rep.delta-mass-qnty-after), 2) + exp((tt-rep.col34 * 0.5), 2) + exp((tt-rep.col30 * tt-rep.delta-mass-qnty-before), 2)) / 100 .
      
      if v-delta-ac > abs(tt-rep.col44)
      then do :
        tt-rep.col48 = 0 .
      end .
      else do :
        tt-rep.col48 = abs(tt-rep.col44) - v-delta-ac .
        if tt-rep.col44 < 0
        then 
          tt-rep.col48 = tt-rep.col48 * -1
        .
      end .
      
      if v-is-sug-gds
      then do :
        tt-rep.col48 = 0 .
      end .
      
      if v-delta-fact > abs(tt-rep.col46)
      then do :
        tt-rep.col49 = 0 .
      end .
      else do :
        tt-rep.col49 = abs(tt-rep.col46) - v-delta-fact .
        if tt-rep.col46 < 0
        then 
          tt-rep.col49 = tt-rep.col49 * -1
        .
      end .
    end .
    
  end .
        
end procedure .

procedure calc-itog :
  
  for each tt-rep :
    tt-rep.no-itog = no .
    if iDelta-tank-ac
    and iDelta-tank-fact
    then do :
      if tt-rep.col48 = 0
      and tt-rep.col49 = 0
      then tt-rep.no-itog = yes .
    end .
    else
    if iDelta-tank-ac
    then do :
      if tt-rep.col48 = 0 then tt-rep.no-itog = yes .
    end .
    else
    if iDelta-tank-fact
    then do :
      if tt-rep.col49 = 0 then tt-rep.no-itog = yes .
    end .
    
    if iTranTimeMax > 0
    then do :
      if tt-rep.min-pour <= iTranTimeMax then tt-rep.no-itog = yes .
    end .
    
    if (iTrkErr = 2 and tt-rep.col35 = "Нет")
    or (iTrkErr = 3 and tt-rep.col35 = "Есть")
    then do :
      tt-rep.no-itog = yes .
    end .
  end .
  
  for each tt-rep where not tt-rep.no-itog :
    if not i-NoAzkItog
    then do :
      find first tt-itog where tt-itog.obj-type = tt-rep.obj-type
                           and tt-itog.obj-code = tt-rep.obj-code
                           no-error .
      if not available tt-itog
      then do :
        create tt-itog .
        assign
          tt-itog.obj-type = tt-rep.obj-type
          tt-itog.obj-code = tt-rep.obj-code
          tt-itog.col1     = tt-rep.col1
          tt-itog.col43red = no
          tt-itog.col45red = no
          tt-itog.col47red = no
        .
      end .
      assign
        tt-itog.col20 = tt-itog.col20 + tt-rep.col20
        tt-itog.col21 = tt-itog.col21 + tt-rep.col21
        tt-itog.col24 = tt-itog.col24 + (if tt-rep.col24 = ? then 0 else tt-rep.col24)
        tt-itog.col25 = tt-itog.col25 + (if tt-rep.col25 = ? then 0 else tt-rep.col25)
        tt-itog.col26 = tt-itog.col26 + (if tt-rep.col26 = ? then 0 else tt-rep.col26)
        tt-itog.col29 = tt-itog.col29 + (if tt-rep.col29 = ? then 0 else tt-rep.col29)
        tt-itog.col30 = tt-itog.col30 + (if tt-rep.col30 = ? then 0 else tt-rep.col30)
        tt-itog.col33 = tt-itog.col33 + (if tt-rep.col33 = ? then 0 else tt-rep.col33)
        tt-itog.col34 = tt-itog.col34 + (if tt-rep.col34 = ? then 0 else tt-rep.col34)
        tt-itog.col36 = tt-itog.col36 + (if tt-rep.col36 = ? then 0 else tt-rep.col36)
        tt-itog.col37 = tt-itog.col37 + (if tt-rep.col37 = ? then 0 else tt-rep.col37)
        tt-itog.col40 = tt-itog.col40 + tt-rep.col40
        tt-itog.col41 = tt-itog.col41 + tt-rep.col41
        tt-itog.col42 = tt-itog.col42 + (if tt-rep.col42 = ? then 0 else tt-rep.col42)
        tt-itog.col43 = tt-itog.col42 / tt-itog.col21 * 100
        tt-itog.col44 = tt-itog.col44 + (if tt-rep.col44 = ? then 0 else tt-rep.col44)
        tt-itog.col45 = tt-itog.col44 / tt-itog.col25 * 100
        tt-itog.col46 = tt-itog.col46 + (if tt-rep.col46 = ? then 0 else tt-rep.col46)
        tt-itog.col47 = tt-itog.col46 / tt-itog.col41 * 100
        tt-itog.col48 = tt-itog.col48 + (if tt-rep.col48 = ? then 0 else tt-rep.col48)
        tt-itog.col49 = tt-itog.col49 + (if tt-rep.col49 = ? then 0 else tt-rep.col49)
      .
    end .
        
    find first tt-all-itog no-error .
    if not available tt-all-itog
    then do :
      create tt-all-itog .
      assign
        tt-all-itog.col43red = no
        tt-all-itog.col45red = no
        tt-all-itog.col47red = no
      .
    end .
    assign
      tt-all-itog.col20 = tt-all-itog.col20 + tt-rep.col20
      tt-all-itog.col21 = tt-all-itog.col21 + tt-rep.col21
      tt-all-itog.col24 = tt-all-itog.col24 + (if tt-rep.col24 = ? then 0 else tt-rep.col24)
      tt-all-itog.col25 = tt-all-itog.col25 + (if tt-rep.col25 = ? then 0 else tt-rep.col25)
      tt-all-itog.col26 = tt-all-itog.col26 + (if tt-rep.col26 = ? then 0 else tt-rep.col26)
      tt-all-itog.col29 = tt-all-itog.col29 + (if tt-rep.col29 = ? then 0 else tt-rep.col29)
      tt-all-itog.col30 = tt-all-itog.col30 + (if tt-rep.col30 = ? then 0 else tt-rep.col30)
      tt-all-itog.col33 = tt-all-itog.col33 + (if tt-rep.col33 = ? then 0 else tt-rep.col33)
      tt-all-itog.col34 = tt-all-itog.col34 + (if tt-rep.col34 = ? then 0 else tt-rep.col34)
      tt-all-itog.col36 = tt-all-itog.col36 + (if tt-rep.col36 = ? then 0 else tt-rep.col36)
      tt-all-itog.col37 = tt-all-itog.col37 + (if tt-rep.col37 = ? then 0 else tt-rep.col37)
      tt-all-itog.col40 = tt-all-itog.col40 + tt-rep.col40
      tt-all-itog.col41 = tt-all-itog.col41 + tt-rep.col41
      tt-all-itog.col42 = tt-all-itog.col42 + (if tt-rep.col42 = ? then 0 else tt-rep.col42)
      tt-all-itog.col43 = tt-all-itog.col42 / tt-all-itog.col21 * 100
      tt-all-itog.col44 = tt-all-itog.col44 + (if tt-rep.col44 = ? then 0 else tt-rep.col44)
      tt-all-itog.col45 = tt-all-itog.col44 / tt-all-itog.col25 * 100
      tt-all-itog.col46 = tt-all-itog.col46 + (if tt-rep.col46 = ? then 0 else tt-rep.col46)
      tt-all-itog.col47 = tt-all-itog.col46 / tt-all-itog.col41 * 100
      tt-all-itog.col48 = tt-all-itog.col48 + (if tt-rep.col48 = ? then 0 else tt-rep.col48)
      tt-all-itog.col49 = tt-all-itog.col49 + (if tt-rep.col49 = ? then 0 else tt-rep.col49)
    .
    
    if abs(tt-rep.col43) > tt-rep.delta-mass-qnty-ac
    then do :
      assign
        tt-itog.col43red = yes when available tt-itog
        tt-all-itog.col43red = yes
      .
    end .
    if abs(tt-rep.col45) > 0.65
    then do :
      assign
        tt-itog.col45red = yes when available tt-itog
        tt-all-itog.col45red = yes
      .
    end .
    if abs(tt-rep.col47) > 0.65
    then do :
      assign
        tt-itog.col47red = yes when available tt-itog
        tt-all-itog.col47red = yes
      .
    end .
    
  end .
  
end procedure .

procedure PrintTT:
   define variable vReportId     as character no-undo.
   define variable vFileNameRep  as character no-undo.
   define variable vStr          as character no-undo.
   define variable vI            as integer   no-undo.

   do on error undo, return error return-value:
      run get-report-num(output vReportId).
      vFileNameRep = session:temp-directory + string(vReportId) + ".html".

      output stream sOutStr-html to value(vFileNameRep) convert target 'UTF-8'.
      put stream sOutStr-html unformatted
 { rep/htmlhead.i }
      .

      put stream sOutStr-html unformatted
           '<body>' skip
           '<TABLE name="1" outline_below="true" fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">' skip
           '<thead>' skip
           '<TR class="set_columns">' skip
               '<TD style="width: 100px;"></TD>' skip            /*  1    */
               '<TD style="width:  60px;"></TD>' skip            /*  2    */
               '<TD style="width:  80px;"></TD>' skip            /*  3    */
               '<TD style="width:  80px;"></TD>' skip            /*  4    */
               '<TD style="width:  70px;"></TD>' skip            /*  5    */
               '<TD style="width:  70px;"></TD>' skip            /*  6    */
               '<TD style="width:  70px;"></TD>' skip            /*  7    */
               '<TD style="width:  70px;"></TD>' skip            /*  8    */
               '<TD style="width:  70px;"></TD>' skip            /*  9    */
               '<TD style="width:  70px;"></TD>' skip            /*  10   */
               '<TD style="width:  70px;"></TD>' skip            /*  11   */
               '<TD style="width:  70px;"></TD>' skip            /*  12   */
               '<TD style="width:  70px;"></TD>' skip            /*  13   */
               '<TD style="width:  70px;"></TD>' skip            /*  14   */
               '<TD style="width:  50px;"></TD>' skip            /*  15   */
               '<TD style="width:  70px;"></TD>' skip            /*  16   */
               '<TD style="width:  50px;"></TD>' skip            /*  17   */
               '<TD style="width:  70px;"></TD>' skip            /*  18   */
               '<TD style="width:  70px;"></TD>' skip            /*  19   */
               '<TD style="width:  79px;"></TD>' skip            /*  20   */
               '<TD style="width:  82px;"></TD>' skip            /*  21   */
               '<TD style="width:  97px;"></TD>' skip            /*  22   */
               '<TD style="width:  60px;"></TD>' skip            /*  23   */
               '<TD style="width:  70px;"></TD>' skip            /*  24   */
               '<TD style="width:  70px;"></TD>' skip            /*  25   */
               '<TD style="width:  70px;"></TD>' skip            /*  26   */
               '<TD style="width:  70px;"></TD>' skip            /*  27   */
               '<TD style="width:  60px;"></TD>' skip            /*  28   */
               '<TD style="width:  70px;"></TD>' skip            /*  29   */
               '<TD style="width:  70px;"></TD>' skip            /*  30   */
               '<TD style="width:  70px;"></TD>' skip            /*  21   */
               '<TD style="width:  70px;"></TD>' skip            /*  32   */
               '<TD style="width:  70px;"></TD>' skip            /*  33   */
               '<TD style="width:  70px;"></TD>' skip            /*  34   */
               '<TD style="width:  70px;"></TD>' skip            /*  35   */
               '<TD style="width:  70px;"></TD>' skip            /*  36   */
               '<TD style="width:  70px;"></TD>' skip            /*  37   */
               '<TD style="width:  70px;"></TD>' skip            /*  38   */
               '<TD style="width:  70px;"></TD>' skip            /*  39   */
               '<TD style="width:  70px;"></TD>' skip            /*  40   */
               '<TD style="width:  70px;"></TD>' skip            /*  41   */
               '<TD style="width:  70px;"></TD>' skip            /*  42   */
               '<TD style="width:  90px;"></TD>' skip            /*  43   */
               '<TD style="width:  70px;"></TD>' skip            /*  44   */
               '<TD style="width:  90px;"></TD>' skip            /*  45   */
               '<TD style="width:  70px;"></TD>' skip            /*  46   */
               '<TD style="width:  90px;"></TD>' skip            /*  47   */
               '<TD style="width:  70px;"></TD>' skip            /*  48   */
               '<TD style="width:  90px;"></TD>' skip            /*  49   */
               '<TD style="width:  70px;"></TD>' skip            /*  50   */
               '<TD style="width:  90px;"></TD>' skip            /*  51   */
           '</TR>' skip
           '<TR>' skip
               '<TD colspan="12" STYLE="font-size: 14px;">' + 'Сводный отчёт по поставкам топлива' + '</TD>'skip
               '<TD colspan="9" STYLE="font-size: 14px; font-weight:bold; ">' + 'Примечание к отчету:' + '</TD>'skip
           '</TR>' skip
           .

      do vI = 1 to extent(mParamStr):
         if mParamStr[vI] = ""
         and mPrim1[vI] = "" 
         then leave .
         put stream sOutStr-html unformatted
              '<TR>' skip
                  '<TD colspan="12" STYLE="font-size: 14px;">' + mParamStr[vI] + '</TD>' skip
                  '<TD colspan="9" STYLE="font-size: 14px; font-style: italic; ">' + mPrim1[vI] + '</TD>' skip
                  '<TD colspan="14" STYLE="font-size: 14px; font-style: italic; ">' + mPrim2[vI] + '</TD>' skip
                  '<TD colspan="14" STYLE="font-size: 14px; font-style: italic; ">' + mPrim3[vI] + '</TD>' skip
              '</TR>' skip
            .
      end.
      
      put stream sOutStr-html unformatted
           '<TR>' skip
               '<TD colspan="14" STYLE="font-size: 14px;">Дата печати: ' + string(today, "99.99.9999") + ' ' + string(time, "HH:MM") + '</TD>' skip
           '</TR>' skip
           '</thead>' skip
         .

      put stream sOutStr-html unformatted
        '<tbody>'
        '<TR >'skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">АЗК/АЗС</TH>'                                                   skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Дата и номер смены</TH>'                                        skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Внутренний номер документа приема</TH>'                         skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Номер документа поставщика</TH>'                                skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Дата/время начала слива</TH>'                                   skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Дата/время окончания слива</TH>'                                skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Длительность приемки</TH>'                                             skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Поставщик</TH>'                                                 skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Перевозчик</TH>'                                                skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Нефтебаза</TH>'                                                 skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">АЦ</TH>'                                                        skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Тип АЦ</TH>'                                                    skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Водитель</TH>'                                                  skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Приёмщик</TH>'                                                  skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">№ секции</TH>'                                                  skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Марка НП</TH>'                                                  skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">№ резервуара</TH>'                                              skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Способ разблокировки API-адаптера</TH>'                         skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Номер ключа/код доступа</TH>'                                   skip
        '<TH text_wrap="true" rowspan="4" colspan="4" style="text-align: center; font-weight:bold; ">Параметры топлива по ТТН</TH>'                                  skip
        '<TH text_wrap="true" rowspan="4" colspan="5" style="text-align: center; font-weight:bold; ">Параметры топлива по измерениям в АЦ</TH>'                      skip
        '<TH text_wrap="true" rowspan="4" colspan="4" style="text-align: center; font-weight:bold; ">Параметры топлива по измерениям в резервуаре до слива</TH>'     skip
        '<TH text_wrap="true" rowspan="4" colspan="3" style="text-align: center; font-weight:bold; ">Реализация при сливе НП</TH>'                                   skip
        '<TH text_wrap="true" rowspan="4" colspan="4" style="text-align: center; font-weight:bold; ">Параметры топлива по измерениям в резервуаре после слива</TH>'  skip
        '<TH text_wrap="true" rowspan="4" colspan="2" style="text-align: center; font-weight:bold; ">Принято к учету</TH>'                                           skip
        '<TH text_wrap="true" rowspan="4" colspan="2" style="text-align: center; font-weight:bold; ">Отклонение АЦ к ТТН</TH>'                                       skip
        '<TH text_wrap="true" rowspan="4" colspan="2" style="text-align: center; font-weight:bold; ">Отклонение резервуара к АЦ</TH>'                                skip
        '<TH text_wrap="true" rowspan="4" colspan="2" style="text-align: center; font-weight:bold; ">Отклонение между резервуаром и  принятым к учету топливом</TH>' skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Сверхнормативные расхождения между резервуаром и АЦ, кг</TH>'   skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Сверхнормативные расхождения между резервуаром и принятым к учету топливом, кг</TH>' skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">АЦ слита с комиссией</TH>'   skip
        '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight:bold; ">Способ ввода данных в сверке (АВД/РВД)</TH>' skip
        '</TR>'skip
        
        '<TR >'skip
        '</TR>'skip
        
        '<TR >'skip
        '</TR>'skip
        
        '<TR >'skip
        '</TR>'skip
        
        '<TR >'skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Объем, л</TH>'                        skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Плотн., г/см3</TH>'                   skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Темп., °С</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Объем, л</TH>'                        skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса ЕУ, кг</TH>'                    skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Плотн., г/см3</TH>'                   skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Темп., °С</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Объем, л</TH>'                        skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Плотн., г/см3</TH>'                   skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Темп., °С</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Объем, л</TH>'                        skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Ошибка данных с ТРК</TH>'             skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Объем, л</TH>'                        skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Плотн., г/см3</TH>'                   skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Темп., °С</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Объем, л</TH>'                        skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">%</TH>'                               skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">%</TH>'                               skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">Масса, кг</TH>'                       skip
        '<TH text_wrap="true" style="text-align: center; font-weight:bold; ">%</TH>'                               skip
        '</TR>'skip
        
        '<TR >'skip
        '<TH style="text-align: center; font-weight:bold; ">1.1</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.2</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.3</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.4</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.5</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.6</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.7</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.8</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.9</TH>'   skip
        '<TH style="text-align: center; font-weight:bold; ">1.10</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.11</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.12</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.13</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.14</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.15</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.16</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.17</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.18</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.19</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.20</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.21</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.22</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.23</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.24</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.25</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.26</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.27</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.28</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.29</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.30</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.31</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.32</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.33</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.34</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.35</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.36</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.37</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.38</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.39</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.40</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.41</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.42</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.43</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.44</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.45</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.46</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.47</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.48</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.49</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.50</TH>'  skip
        '<TH style="text-align: center; font-weight:bold; ">1.51</TH>'  skip
        '</TR>'skip
      .

      for each tt-rep where not tt-rep.no-itog
      break
        by tt-rep.obj-code
        by tt-rep.shift-date
        by tt-rep.shift-num
        by tt-rep.col3
        by tt-rep.gds-code
        by tt-rep.col15
      :
        if not i-Itog
        then do :
          
          put stream sOutStr-html unformatted
            '<TR >'skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col1, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col2, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col3, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col4, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col5, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col6, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col7, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col8, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col9, "") '</TH>'   skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col10, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col11, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col12, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col13, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col14, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col15, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col16, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col17, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col18, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col19, "") '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col20str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col21str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col22str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col23str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col24str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col25str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col26str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col27str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col28str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col29str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col30str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col31str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col32str + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col33, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:normal; ">' + fDec2Str(tt-rep.col33, "->>>>>>>>>>>9"  ) + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col34, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:normal; ">' + fDec2Str(tt-rep.col34, "->>>>>>>>>>>9.9") + '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; color: ' + (if tt-rep.col35 = "Есть" then "red" else "black") + '; ">' fStrNvl(tt-rep.col35, "") '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col36str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col37str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col38str + '</TH>'  skip
            '<TH num="#,##0.00" style="text-align: center; font-weight:normal; ">' + tt-rep.col39str + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col40, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:normal; ">' + fDec2Str(tt-rep.col40, "->>>>>>>>>>>9"  ) + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col41, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:normal; ">' + fDec2Str(tt-rep.col41, "->>>>>>>>>>>9.9") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col42, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:normal; color: ' + (if (abs(tt-rep.col43) > tt-rep.delta-mass-qnty-ac or not tt-rep.ac-measured) then "red" else "black") + '; ">' + fDec2Str(tt-rep.col42, "->>>>>>>>>>>9.9") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col43, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:normal; color: ' + (if (abs(tt-rep.col43) > tt-rep.delta-mass-qnty-ac or not tt-rep.ac-measured) then "red" else "black") + '; ">' + fDec2Str(tt-rep.col43, "->>>>>>>>>>9.99") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col44, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:normal; color: ' + (if (abs(tt-rep.col45) > 0.65 or not tt-rep.ac-measured) then "red" else "black") + '; ">' + fDec2Str(tt-rep.col44, "->>>>>>>>>>>9.9") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col45, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:normal; color: ' + (if (abs(tt-rep.col45) > 0.65 or not tt-rep.ac-measured) then "red" else "black") + '; ">' + fDec2Str(tt-rep.col45, "->>>>>>>>>>9.99") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col46, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:normal; color: ' + (if abs(tt-rep.col47) > 0.65 then "red" else "black") + '; ">' + fDec2Str(tt-rep.col46, "->>>>>>>>>>>9.9") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col47, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:normal; color: ' + (if abs(tt-rep.col47) > 0.65 then "red" else "black") + '; ">' + fDec2Str(tt-rep.col47, "->>>>>>>>>>9.99") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col48, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:normal; color: ' + (if (tt-rep.col48 <> 0 or not tt-rep.ac-measured) then "red" else "black") + '; ">' + fDec2Str(tt-rep.col48, "->>>>>>>>>>>9.9") + '</TH>'  skip
            '<TH num="#,##0.00" val="' + fDec2Str(tt-rep.col49, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:normal; color: ' + (if tt-rep.col49 <> 0 then "red" else "black") + '; ">' + fDec2Str(tt-rep.col49, "->>>>>>>>>>>9.9") + '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; color: ' + (if tt-rep.col50 <> "Нет" then "red" else "black") + '; ">' fStrNvl(tt-rep.col50, "") '</TH>'  skip
            '<TH style="text-align: center; font-weight:normal; ">' fStrNvl(tt-rep.col51, "") '</TH>'  skip
            '</TR>'skip
          .
        end .
             
        if last-of(tt-rep.obj-code) then do:
          for first tt-itog where tt-itog.obj-type = tt-rep.obj-type
                              and tt-itog.obj-code = tt-rep.obj-code
          :
            put stream sOutStr-html unformatted
              '<TR >'skip
              '<TH style="text-align: center; font-weight:bold; ">Итого по:</TH>'  skip
              '<TH style="text-align: center; font-weight:bold; ">' fStrNvl(tt-itog.col1, "") '</TH>'   skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col20, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col20, "->>>>>>>>>>>9"  ) + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col21, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col21, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col24, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col24, "->>>>>>>>>>>9"  ) + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col25, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col25, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col26, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col26, "->>>>>>>>>>9.99") + '</TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col29, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col29, "->>>>>>>>>>>9"  ) + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col30, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col30, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col33, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col33, "->>>>>>>>>>>9"  ) + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col34, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col34, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col36, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col36, "->>>>>>>>>>>9"  ) + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col37, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col37, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col40, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col40, "->>>>>>>>>>>9"  ) + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col41, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-itog.col41, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col42, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col43red then "red" else "black") + '; ">' + fDec2Str(tt-itog.col42, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col43, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col43red then "red" else "black") + '; ">' + fDec2Str(tt-itog.col43, "->>>>>>>>>>9.99") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col44, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col45red then "red" else "black") + '; ">' + fDec2Str(tt-itog.col44, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col45, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col45red then "red" else "black") + '; ">' + fDec2Str(tt-itog.col45, "->>>>>>>>>>9.99") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col46, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col47red then "red" else "black") + '; ">' + fDec2Str(tt-itog.col46, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col47, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col47red then "red" else "black") + '; ">' + fDec2Str(tt-itog.col47, "->>>>>>>>>>9.99") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col48, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col48 <> 0 then "red" else "black") + '; ">' + fDec2Str(tt-itog.col48, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH num="#,##0.00" val="' + fDec2Str(tt-itog.col49, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-itog.col49 <> 0 then "red" else "black") + '; ">' + fDec2Str(tt-itog.col49, "->>>>>>>>>>>9.9") + '</TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
              '</TR>'skip
            .
          end .
        end .
      end .
      
      for first tt-all-itog:
        put stream sOutStr-html unformatted
          '<TR >'skip
          '<TH style="text-align: center; font-weight:bold; ">Итого по:</TH>'  skip
          '<TH style="text-align: center; font-weight:bold; ">Всем выбранным объектам</TH>'   skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col20, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col20, "->>>>>>>>>>>9"  ) + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col21, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col21, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col24, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col24, "->>>>>>>>>>>9"  ) + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col25, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col25, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col26, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col26, "->>>>>>>>>>9.99") + '</TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col29, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col29, "->>>>>>>>>>>9"  ) + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col30, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col30, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col33, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col33, "->>>>>>>>>>>9"  ) + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col34, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col34, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col36, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col36, "->>>>>>>>>>>9"  ) + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col37, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col37, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col40, "->>>>>>>>>>>9"  ) + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col40, "->>>>>>>>>>>9"  ) + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col41, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; ">' + fDec2Str(tt-all-itog.col41, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col42, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col43red then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col42, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col43, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col43red then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col43, "->>>>>>>>>>9.99") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col44, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col45red then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col44, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col45, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col45red then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col45, "->>>>>>>>>>9.99") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col46, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col47red then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col46, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col47, "->>>>>>>>>>9.99") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col47red then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col47, "->>>>>>>>>>9.99") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col48, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col48 <> 0 then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col48, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH num="#,##0.00" val="' + fDec2Str(tt-all-itog.col49, "->>>>>>>>>>>9.9") + '" style="text-align: center; font-weight:bold; color: ' + (if tt-all-itog.col49 <> 0 then "red" else "black") + '; ">' + fDec2Str(tt-all-itog.col49, "->>>>>>>>>>>9.9") + '</TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '<TH style="text-align: center; font-weight:bold; "></TH>'  skip
          '</TR>'skip
        .
      end.
      
         
      put stream sOutStr-html unformatted
         '</tbody>' skip
         '</table>' skip
         '</body>' skip
         '</html>' skip
         .
         
      output stream sOutStr-html close.

      run prn-lib-reportviewer in this-procedure (
          input parparentproc
          ,input vFileNameRep
          ,input ""
          ) no-error.
      if error-status:error then
      do:
          message return-value view-as alert-box.
          return .
      end.
            
   end.

end procedure.

PROCEDURE get-report-num :

  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.
