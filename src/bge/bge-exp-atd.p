block-level on error undo, throw.
/*
$Revision: 899f5f3721f3, 1951, rls $
$Author: ASMorozov $
$Date: Fri Jul 26 11:39:33 2019 +0300 $
$Workfile: bge-exp-ATD.p $
$Archive: bge/bge-exp-ATD.p $

Выгрузка в систему Анализа Трека Данных

Автор: Сливенко Сергей 
Author: Slivenko Sergey
Creation date: 11/08/2016

*/

define variable vss-revision    as character no-undo init "$Revision: 899f5f3721f3, 1951, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jul 26 11:39:33 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-exp-ATD.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-exp-ATD.p $":U .
define variable vss-description as character no-undo init "Выгрузка в систему Анализа Трека Данных".

/* ********************  Preprocessor Definitions  ******************** */



/* ***************************  Includes  ************************** */
{cmp/vssrevis.i}
{cmp/str-glbl.i}
{str/lib-trn.i}
{cmp/library.i}
{gbl/clntattr.i}
{cmp/trg-def.i}
{ref/gds-attr.i}
{str/findtank.i}
{ str/trdcalib.i }

/* ***************************  Definitions  ************************** */

/* Input parameters */


define temp-table tt_obj no-undo
    field obj-type as character
    field obj-code as integer
.

define variable v-shift-on        as logical   no-undo.

define variable v-user-action     as character no-undo .
define variable v-printed         as logical   no-undo .


define variable v-curr-grp-name   as character no-undo.

define input parameter table for tt_obj. /* Список объектов */
define input parameter p_path as character no-undo. /* Папка для выгрузки */
define input parameter p_log-handle as handle no-undo.
define input parameter p-d_sht-start as date      no-undo.
define input parameter p-i_sht-start as integer   no-undo.
define input parameter p-d_sht-end   as date      no-undo.
define input parameter p-i_sht-end   as integer   no-undo.
define input parameter p-region      as character no-undo.
define input parameter p-mode as character no-undo.

define stream f1.

define buffer buf_shift-obj   for ub.shift-obj.
define buffer buf_clients     for ub.clients.
define buffer buf_goods       for ub.goods.
define buffer buf_bar-code    for ub.bar-code.
define buffer buf_prod-bc     for ub.prod-bc.

define variable is-petrolium           as logical   no-undo. /* для типа товара */
define variable is-pieces              as logical   no-undo. /* для типа товара */
define variable v-prod-bc              as character no-undo.


define variable v-date-file-name as character no-undo.
DEFINE VARIABLE file_name        AS CHARACTER NO-UNDO.
define variable v-time           as integer   no-undo.
define variable v-time-file      as char      no-undo.
DEFINE VARIABLE log-file-name    AS CHARACTER NO-UNDO.
define variable v-date           as date      no-undo. 
define variable v-date-end       as character no-undo.
define variable v-sdate-end      as character no-undo. /* для сохранения последней выгруженной смены */
       
define variable v-arc   as character no-undo .
define variable v-cmd   as character no-undo .  

assign
  v-arc = search( "exe/7z.exe":U )
.
if v-arc = ? then do:
  return error "Не найдена программа 7z.exe, невозможно упаковать выгрузку в zip" .
end.          


/* Для лога */
&scop display-message run write-log-and-file in p_log-handle ~
    (input 1, input log-file-name, input 1, input ~{&my-message~})
      

assign
  log-file-name    = substitute("&1exp-ATD.log", ibs.th.gbl.gbl-inipar:logDir)
  v-time = time
  v-date = today
  v-time-file      = replace(  string(v-time, "HH:MM:SS"), ":", ""  )
  v-date-file-name = STRING(YEAR(v-date), "9999") + STRING(DAY(v-date), "99") + STRING(MONTH(v-date), "99")
  file_name        = substitute("&1HDB_&2_&3_&4.csv", p_path, trim(p-region), v-date-file-name, v-time-file) 
.


function format_datetime returns character(
    input v-date as date,
    input v-time as integer
    ):
    /*------------------------------------------------------------------------------
            Purpose: Возвращает дату и время в необходимом формате
            Notes:
    ------------------------------------------------------------------------------*/    
    return substitute("&1.&2.&3 &4",
        string(day(v-date),"99"),
        string(month(v-date),"99"),
        string(year(v-date),"9999"),
        string(v-time, "HH:MM:SS:000")
        ).
end function.


define variable c-value as char no-undo.
define variable  c-type as char no-undo.
define variable v-st-shift-date as date no-undo .
define variable v-st-shift-num  as integer no-undo . 
define variable v-prev-shift-date as date no-undo .
define variable v-prev-shift-num  as integer no-undo . 

/*run gbl/inidebug.p.*/

output to value(file_name) .

/* Store (Справочник АЗК) */
for each tt_obj no-lock:
    find first buf_clients no-lock where buf_clients.obj-type = tt_obj.obj-type
                                     and buf_clients.obj-code = tt_obj.obj-code no-error .
  if available buf_clients then                                     
    put unformatted "Store," string(buf_clients.obj-code) "," p-region ",1," buf_clients.obj-name skip .
end.

/* ItemInfo (Справочник товаров) */
goods_:
for each buf_goods no-lock where buf_goods.stts = 0 :
    { str/is-petrl.i
        buf_goods.artic
        buf_goods.prod-type
        buf_goods.prod-code
        is-petrolium
        is-pieces
    }
    if not is-petrolium
    then next .
    
    v-prod-bc = ? .
    bar-code_ :
    for each buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code :
        find first buf_prod-bc no-lock where buf_prod-bc.b-code = buf_bar-code.b-code no-error .
        if available buf_prod-bc
        then do :
            v-prod-bc = buf_prod-bc.b-str .
            leave bar-code_ .
        end.
        else do :
            v-prod-bc = ? .
        end.
    end.
    if v-prod-bc = ?
    then next goods_ .
    
    put unformatted "ItemInfo," p-region "," string(buf_goods.gds-code) "," v-prod-bc ",1,Активный," buf_goods.artic "," buf_goods.gds-name "," string(buf_goods.grp-code) skip .
end.

for each tt_obj no-lock:
    
       &scop my-message substitute("Объект: &1   &2", tt_obj.obj-type, tt_obj.obj-code )
{&display-message} .

    { gbl/objat.i
        tt_obj.obj-type
        tt_obj.obj-code
        "'shift-on=request'"
        v-shift-on
        no-error
        }
    if v-shift-on then . else next . 
        
    if p-mode = "shd"
    then do:
        run clntattr-value in this-procedure (input tt_obj.obj-type,
            input tt_obj.obj-code,
            input {&attr-bge-exp-last-atd},
            output c-value,
            output c-type) NO-ERROR.
        if error-status:error then
        do:
            &scop my-message substitute("Ошибка в атрибуте объекта. Объект &1&2",tt_obj.obj-type,tt_obj.obj-code)
            {&display-message}.
            next.
        end.
            &scop my-message substitute("Последняя выгруженная смена объекта &1&2 (дата, номер): &3 (атрибут объекта &4)", tt_obj.obj-type, tt_obj.obj-code, c-value, {&attr-bge-exp-last-atd})
            {&display-message}.

        /* Если атрибут отсутствует */
        if c-value = "" then c-value = "1/1/1900,1". /* Начальный атрибут. чтобы было от чего искать смены */
        
        assign
          v-prev-shift-date = date(entry(1,c-value,","))
          v-prev-shift-num  = integer(entry(2,c-value,","))
          p-d_sht-start = ? /* в автоматическом режиме дата выгружаемой смены своя для каждого магазина */
        .
      /* для автоматического режима найти следующую смену, после выгруженной */
      for each buf_shift-obj no-lock
         where buf_shift-obj.obj-type = tt_obj.obj-type
           and buf_shift-obj.obj-code = tt_obj.obj-code
           and buf_shift-obj.shift-date >= v-prev-shift-date
           and buf_shift-obj.status_  = {&sht-closed}
             by buf_shift-obj.shift-date
             by buf_shift-obj.shift-num:
        if (buf_shift-obj.shift-date = v-prev-shift-date) and
           (buf_shift-obj.shift-num <= v-prev-shift-num) then next.
        assign
          p-d_sht-start = buf_shift-obj.shift-date
          p-i_sht-start = buf_shift-obj.shift-num
        .
        leave.
      end.
      if (p-d_sht-start = ?) then do:
            &scop my-message substitute("Отсутствуют смены для выгрузки после &1 смена &2. Объект &3&4", v-prev-shift-date, v-prev-shift-num, tt_obj.obj-type, tt_obj.obj-code )
            {&display-message}.
            next. /* next for each tt_obj */
      end.
    end.
    else do:
      /* для ручного режима - найти предыдущую выгруженную смену */
      v-prev-shift-date = ?.
      for each buf_shift-obj no-lock
         where buf_shift-obj.obj-type = tt_obj.obj-type
           and buf_shift-obj.obj-code = tt_obj.obj-code
           and buf_shift-obj.shift-date <= p-d_sht-start
           and buf_shift-obj.status_  = {&sht-closed}
             by buf_shift-obj.shift-date descending
             by buf_shift-obj.shift-num descending:
        if (buf_shift-obj.shift-date = p-d_sht-start) and
           (buf_shift-obj.shift-num >= p-i_sht-start) then next.
        assign
          v-prev-shift-date = buf_shift-obj.shift-date
          v-prev-shift-num  = buf_shift-obj.shift-num
        .
        leave.
      end.
      if (v-prev-shift-date = ?) then do:
        c-value = "1/1/1900,1". /* Начальный атрибут. чтобы было от чего искать смены */
        assign
          v-prev-shift-date = date(entry(1,c-value,","))
          v-prev-shift-num  = integer(entry(2,c-value,","))
        .
      end.
    end.
    /* для первой выгрузки будет не определена последняя выгруженная смена;
       в этом случае в выгрузку не попадут FuelTankReading и FuelPumpReading */
       
   
    &scop my-message substitute("Дата начала выгрузки: &1   &2", p-d_sht-start, p-i_sht-start )
{&display-message} .

      /* FuelShifts (Информация по топливным сменам АЗК) */
      assign
        v-sdate-end = ""
      .
      /* 1. за shift-date = p-d_sht-start */            
      for each buf_shift-obj no-lock
         where buf_shift-obj.obj-type = tt_obj.obj-type
           and buf_shift-obj.obj-code = tt_obj.obj-code
           and buf_shift-obj.shift-date = p-d_sht-start
           and buf_shift-obj.status_  = {&sht-closed}
             by buf_shift-obj.shift-num:
        if buf_shift-obj.shift-num < p-i_sht-start then next .
        do
        on error undo, return error return-value
        :
          run shift-output in this-procedure (
            input v-prev-shift-date, input v-prev-shift-num, 
            buffer buf_shift-obj) .
        end.
        assign
          v-prev-shift-date = buf_shift-obj.shift-date
          v-prev-shift-num  = buf_shift-obj.shift-num 
          v-sdate-end = substitute("&1,&2", buf_shift-obj.shift-date , buf_shift-obj.shift-num)            
          v-date-end = substitute("&1   &2", buf_shift-obj.shift-date , buf_shift-obj.shift-num)
        .
      end. /* end_of for each buf_shift-obj */
      
      /* 2. за shift-date > p-d_sht-start */            
      for each buf_shift-obj no-lock
         where buf_shift-obj.obj-type = tt_obj.obj-type
           and buf_shift-obj.obj-code = tt_obj.obj-code
           and buf_shift-obj.shift-date > p-d_sht-start
           and buf_shift-obj.shift-date <= p-d_sht-end
           and buf_shift-obj.status_  = {&sht-closed}
             by buf_shift-obj.shift-date
             by buf_shift-obj.shift-num:
        if buf_shift-obj.shift-date = p-d_sht-end then do:
          if buf_shift-obj.shift-num > p-i_sht-end then leave.
        end.
        do
        on error undo, return error return-value
        :
          run shift-output in this-procedure (
            input v-prev-shift-date, input v-prev-shift-num, 
            buffer buf_shift-obj) .
        end.
        assign
          v-prev-shift-date = buf_shift-obj.shift-date
          v-prev-shift-num  = buf_shift-obj.shift-num 
          v-sdate-end = substitute("&1,&2", buf_shift-obj.shift-date , buf_shift-obj.shift-num)            
          v-date-end = substitute("&1   &2", buf_shift-obj.shift-date , buf_shift-obj.shift-num)
        .
      end. /* end_of for each buf_shift-obj */

      if v-sdate-end > "" then
            run clntattr-write in this-procedure (input tt_obj.obj-type,
                input tt_obj.obj-code,
                input {&attr-bge-exp-last-atd},
                input v-sdate-end)
            no-error.
        
        &scop my-message substitute("Дата конца выгрузки: &1 ", v-date-end)
            {&display-message} . 
    
end.

output close .     

v-cmd = v-arc + " a -tzip -ssw -mx7 " + '"' + substring(file_name, 1, length(file_name) - 3) + 'zip" '  + '"' +  file_name  + '"'  .  

os-command silent value ( v-cmd ) . 

os-delete value ( file_name ) .


/* выгружает: FuelShifts, FuelTankReading, FuelPumpReading, FuelTransaction;
     FuelTankReading и FuelPumpReading - на конец предыдущей смены,
     FuelShifts и FuelTransaction - за текущую
*/
procedure shift-output private:
define input parameter p-prev-shift-date as date no-undo .
define input parameter p-prev-shift-num  as integer no-undo . 
define parameter buffer p-buf_shift-obj for ub.shift-obj .   
define variable is-petrolium           as logical   no-undo. /* для типа товара */
define variable is-pieces              as logical   no-undo. /* для типа товара */
define variable v-shift-head           as character no-undo . /* одинаковое начало выгрузки смены */
define variable v-trn-stype            as character no-undo . /* тип транзакции выгружаемой накладной */
define variable v-doc-qnty   as decimal decimals 10 no-undo . /* для умножения возврата на (-1) */
define variable v-pl-code              as integer   no-undo . /* для поиска TankId через pl-code */
define variable v-loc1                 as character no-undo . /* TankId если available */
define buffer buf_rvs-doc     for ub.rvs-doc.
define buffer buf_rvs-line    for ub.rvs-line.
define buffer buf_rvs-line-pump for ub.rvs-line-pump.
define buffer buf_place       for ub.place.
define buffer buf_chk-doc     for ub.chk-doc.
define buffer buf_chk-gds     for ub.chk-gds.
define buffer buf_bar-code    for ub.bar-code.
define buffer buf_goods       for ub.goods.
define buffer buf_clients     for ub.clients.
define buffer buf_trn-doc     for ub.trn-doc.
define buffer buf_doc-line    for ub.doc-line.
define buffer buf_doc-pl      for ub.doc-pl .
define buffer buf_sale-doc    for ub.sale-doc .

  v-shift-head = substitute (  "&1,&2,&3,&4",
                               p-region,  p-buf_shift-obj.obj-code,
                               string(p-buf_shift-obj.shift-date, "99.99.9999"),  p-buf_shift-obj.shift-num  ) .
  put unformatted "FuelShifts,"
    v-shift-head ","
    format_datetime(p-buf_shift-obj.open-date, p-buf_shift-obj.open-time) ","
    format_datetime(p-buf_shift-obj.close-date, p-buf_shift-obj.close-time) skip
  .    

  
  /* остатки на ВчераВечер = остатки на СегодняУтро */
  find first buf_rvs-doc no-lock where buf_rvs-doc.obj-type       = p-buf_shift-obj.obj-type
                                   and buf_rvs-doc.obj-code       = p-buf_shift-obj.obj-code
                                   and buf_rvs-doc.shift-date     = p-prev-shift-date
                                   and buf_rvs-doc.shift-num      = p-prev-shift-num   
                                   and buf_rvs-doc.status_        = {&fact}   
                                   and buf_rvs-doc.rvs-type       = {&rvs-shift}
                                       no-error .
  if available buf_rvs-doc
  then                              
    for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                                    and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                                    and buf_rvs-line.obj-code = buf_rvs-doc.obj-code :
      find first buf_place no-lock where buf_place.pl-code = buf_rvs-line.pl-code no-error .
      put unformatted "FuelTankReading,"
        v-shift-head ","
        (if available buf_place then buf_place.loc1 else "0") ","
        string(buf_rvs-line.gds-code) ","
        trim(string(buf_rvs-line.state-measure-qnty, ">>>>>>>>9.99")) skip
      .
      for each buf_rvs-line-pump no-lock where buf_rvs-line-pump.rvs-code     = buf_rvs-line.rvs-code
                                           and buf_rvs-line-pump.obj-type     = buf_rvs-line.obj-type
                                           and buf_rvs-line-pump.obj-code     = buf_rvs-line.obj-code 
                                           and buf_rvs-line-pump.pl-code      = buf_rvs-line.pl-code
                                           and buf_rvs-line-pump.gds-code     = buf_rvs-line.gds-code :
        put unformatted "FuelPumpReading,"
          v-shift-head ","
          string(buf_rvs-line-pump.pump-code) ","
          string(buf_rvs-line.gds-code) ","
          trim(string(buf_rvs-line.state-measure-qnty, ">>>>>>>>9.99")) ","
          string(buf_rvs-line-pump.nozzle-code) ","
          trim(string(buf_rvs-line-pump.state-el-cnt, ">>>>>>>>9.99")) ","
          string(buf_rvs-doc.shift-date, "99.99.9999") skip
        .                                     
      end.            
    end. /* end_of for_each buf_rvs-line */
  
  /* чеки - только продажа, возврат, тех.пролив;
            тип транзакции для продажи и техпролива = 1, для возврата = 2 */
  chk-doc_ :
  for each buf_chk-doc no-lock where buf_chk-doc.obj-type = p-buf_shift-obj.obj-type 
                                 and buf_chk-doc.obj-code = p-buf_shift-obj.obj-code
                                 and buf_chk-doc.shift-date = p-buf_shift-obj.shift-date
                                 and buf_chk-doc.shift-num  = p-buf_shift-obj.shift-num
                                 and (
                                   (buf_chk-doc.chk-type = {&bef-rcpt-sale}) or
                                   (buf_chk-doc.chk-type = {&bef-rcpt-return}) or
                                   (buf_chk-doc.chk-type = {&bef-rcpt-tech-refuell})
                                     ) :
    v-trn-stype = if buf_chk-doc.chk-type = {&bef-rcpt-return} then "2" else "1" .
    chk-gds_ :                               
    for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code :
      find first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code no-error.
      if available buf_bar-code then do:
        /*найдем товар по коду*/
        find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
        if available buf_goods then do:
          /*это топливо?*/
          { str/is-petrl.i
              buf_goods.artic
              buf_goods.prod-type
              buf_goods.prod-code
              is-petrolium
              is-pieces
          }
          if not is-petrolium
          then next chk-gds_.
        end.
        else next chk-gds_.
      end.
      else next chk-gds_.
      
      v-doc-qnty = if buf_chk-doc.chk-type = {&bef-rcpt-return} then ( (-1) * buf_chk-gds.doc-qnty ) else buf_chk-gds.doc-qnty .

      if buf_chk-gds.loc1 > ""  then v-loc1 = buf_chk-gds.loc1.
      else do:
             if buf_chk-gds.src-pl-code > 0 then v-pl-code = buf_chk-gds.src-pl-code.
        else if buf_chk-gds.pl-code     > 0 then v-pl-code = buf_chk-gds.pl-code.
        else do:
          /* если нет резервуара в чеке, найти в топологии текущую связку ТРК+Пистолет,
             определить по ней резервуар и выгрузить полученный код резервура */
          run findtank in this-procedure
            (input buf_chk-doc.obj-type,
             input buf_chk-doc.obj-code,
             input buf_chk-gds.pump,
             input buf_chk-gds.nozzle-code,
             input buf_chk-gds.pl-code,
             input buf_bar-code.gds-code,
             output v-pl-code) no-error.
        end.
        if v-pl-code > 0 then do:
          find first buf_place no-lock where buf_place.pl-code = v-pl-code no-error .
          v-loc1 = if available buf_place then buf_place.loc1 else "0" .
        end.
        else v-loc1 = "0" .
      end. /* end_of if buf_chk-gds.loc1 empty */

      put unformatted "FuelTransaction,"
        v-shift-head ","
        format_datetime(buf_chk-doc.chk-date, buf_chk-doc.chk-time) ","
        v-trn-stype ","
        string(buf_goods.gds-code) ","
        trim(string(v-doc-qnty, "->>>>>>9.99")) ","
        string(buf_chk-gds.pump) ","
        v-loc1 skip /* TankId [int] NOT NULL */
      .
    end. /* end_of for_each buf_chk-gds */
  end. /* end_of for_each buf_chk-doc */


  /* накладные - все, кроме накладных по чекам продажы и по чекам возврата;
     из оставшихся - кроме списания по тех.проливу;
     тип транзакции 1 для уменьшающих остаток, 2 - для увеличивающих;
     инвентаризация не выгружается;
     когда инвентаризация выгружалась - она шла двумя строками: 1 - недостачи, 2 - излишки */
  trn-doc_ :
  for each buf_trn-doc no-lock
     where buf_trn-doc.obj-type     = p-buf_shift-obj.obj-type
       and buf_trn-doc.obj-code     = p-buf_shift-obj.obj-code
       and buf_trn-doc.shift-date   = p-buf_shift-obj.shift-date
       and buf_trn-doc.shift-num    = p-buf_shift-obj.shift-num  
       and buf_trn-doc.status_      = {&fact}
/*       and can-do ("{&bef-TDEDT_Ras_Vnesh_Kass},{&bef-TDEDT_Vozvrat_Vnesh_Kass}":U, buf_trn-doc.ext-doc-type) = false : */
       and can-do ("{&bef-TDEDT_Ras_Vnesh_Kass},{&bef-TDEDT_Vozvrat_Vnesh_Kass},{&bef-TDEDT_Inv}":U,
                   buf_trn-doc.ext-doc-type) = false :
    
    def var v-value as character no-undo.
    def var v-type  as character no-undo.
    def var v-tech-pass as logical no-undo.
    { str/tdat-val.i                                    
      buf_trn-doc.doc-code
      {&trdcattr-techpass}
      v-value 
      v-type 
      no-error
    }
    assign
      v-tech-pass = yes when v-value = "yes".
          
    /* исключаем списание по техпроливу */
    if buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}
       and
       (v-tech-pass or 
       (can-find (first buf_clients where buf_clients.obj-type = buf_trn-doc.cli-type
                                     and buf_clients.obj-code = buf_trn-doc.cli-code) and
       can-find (first buf_sale-doc where buf_sale-doc.doc-code = buf_trn-doc.doc-code
                                      and buf_sale-doc.doc-kind = {&sale-add-tech-refuell})))
    then next trn-doc_ .
    
    v-trn-stype = if can-do("{&bef-income},{&bef-return}":U, buf_trn-doc.doc-type) then "2" else "1" .
    /* для инвентаризации будет отдельно перевыставлено по товарам */
     
    doc-line_ :
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
      { str/is-petrl.i
          buf_doc-line.artic
          buf_doc-line.prod-type
          buf_doc-line.prod-code
          is-petrolium
          is-pieces
      }
      if not is-petrolium then next doc-line_.
      find first buf_goods no-lock where buf_goods.artic      = buf_doc-line.artic
                                     and buf_goods.prod-type  = buf_doc-line.prod-type
                                     and buf_goods.prod-code  = buf_doc-line.prod-code
                                         no-error .
      if not available buf_goods then next doc-line_.
          
      find first buf_doc-pl no-lock where buf_doc-pl.out-code = buf_trn-doc.doc-code
                                      and buf_doc-pl.gds-code = buf_goods.gds-code
                                      and buf_doc-pl.obj-type = buf_trn-doc.obj-type
                                      and buf_doc-pl.obj-code = buf_trn-doc.obj-code
                                          no-error.
      if available buf_doc-pl then do:
        find first buf_place no-lock where buf_place.pl-code = buf_doc-pl.pl-code no-error .
        v-loc1 = if available buf_place then buf_place.loc1 else "0" . /* TankId [int] NOT NULL */
      end.
      else v-loc1 = "0".
        
      /* 24-aug-2017 - от инвентаризации отказались.
      if buf_trn-doc.ext-doc-type = {&TDEDT_Inv} then do:
        -- недостачи --
        if buf_doc-line.fact-qnty < 0 then put unformatted "FuelTransaction,"
          v-shift-head ","
          format_datetime(buf_trn-doc.sys-date, buf_trn-doc.sys-time-int) ",1,"
          string(buf_goods.gds-code) ","
          trim(string( (-1) * buf_doc-line.fact-qnty, "->>>>>>9.99")) ","
          "0," /* для накладных не определена ТРК (PumpId [int] NOT NULL) */ 
          v-loc1 skip
        .
        -- излишки --
        if buf_doc-line.fact-qnty > 0 then put unformatted "FuelTransaction,"
          v-shift-head ","
          format_datetime(buf_trn-doc.sys-date, buf_trn-doc.sys-time-int) ",2,"
          string(buf_goods.gds-code) ","
          trim(string(buf_doc-line.fact-qnty, "->>>>>>9.99")) ","
          "0," /* для накладных не определена ТРК (PumpId [int] NOT NULL) */ 
          v-loc1 skip
        .
      end.
      else do:
      */         
        put unformatted "FuelTransaction,"
          v-shift-head ","
          format_datetime(buf_trn-doc.sys-date, buf_trn-doc.sys-time-int) ","
          v-trn-stype ","
          string(buf_goods.gds-code) ","
          trim(string(buf_doc-line.fact-qnty, "->>>>>>9.99")) ","
          "0," /* для накладных не определена ТРК (PumpId [int] NOT NULL) */ 
          v-loc1 skip
        .
    end. /* end_of for_each buf_doc-line */
  end. /* end_of for_each buf_trn-doc */

            
end procedure . /* end_of shift-output */
