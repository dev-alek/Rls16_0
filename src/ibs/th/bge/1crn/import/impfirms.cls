/*

$Revision: 2f1124ce5189, 1642, rls $
$Author: SMMolotkov $
$Date: Mon Nov 19 15:15:35 2018 +0300 $
$Workfile: impfirms.cls $
$Archive: ibs/th/bge/1crn/import/impfirms.cls $

Класс ипорта данных firms (фирмы, на АЗС выгружается только своя организация) из 1С

Автор: Молотков Сергей
Дата создания: 02/10/17
Author: Molotkov Sergey
Creation date: 02/10/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.

class ibs.th.bge.1crn.import.impfirms implements ibs.th.bge.1crn.import.iimpsubject: 
  
  { cmp/str-glbl.i class }
  { gbl/attr-lib.i class }  
  
  
  define property Msg as character no-undo
    get. 
    set.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable v-mode       as character no-undo . /* create/update */
    define variable v-rid        as recid no-undo .
    define variable v-is-deploy  as logical no-undo .
    define variable v-host-code  as integer no-undo . /* like ub.sysconf.host-code */
    define variable v-retfl      as logical no-undo .
    define buffer buf_sysconf for ub.sysconf .
    define buffer buf_firm    for ub.firm .
    define buffer buf_clients for ub.clients .
    
    /* поля, которые не приходят из 1С: */
    define variable v-avrg-price    as logical no-undo . /* like ub.sysconf.avrg-price (log) */
    define variable v-artic-disable as logical no-undo . /* like ub.sysconf.artic-disable (log) */
    define variable v-base-code     as integer no-undo . /* like ub.sysconf.base-code */
    define variable v-branch        as character no-undo . /* like ub.sysconf.branch */
    define variable v-cash-pay      as integer no-undo . /* like ub.sysconf.cash-pay */
    define variable v-cashier       as character no-undo . /* like ub.sysconf.cashier */
    define variable v-cons-vat-pc   as decimal decimals 10 no-undo . /* like ub.sysconf.cons-vat-pc (dec-10) */
    define variable v-credit-pay    as integer no-undo . /* like ub.sysconf.credit-pay */
    define variable v-firm-db-num   as integer no-undo . /* like ub.sysconf.firm-db-num */
    define variable v-head-position as character no-undo . /* like ub.sysconf.head-position */
    define variable v-KOPF          as character no-undo . /* like ub.sysconf.KOPF */
    define variable v-negative-rest as logical no-undo . /* like ub.sysconf.negative-rest */
    define variable v-ord-prt       as logical no-undo . /* like ub.sysconf.ord-prt */
    define variable v-osn-base      as logical no-undo . /* like ub.sysconf.osn-base */
    define variable v-property      as character no-undo . /* like ub.sysconf.property */
    define variable v-purch-code    as integer no-undo . /* like ub.sysconf.purch-code */
    define variable v-ret-credit-pay as integer no-undo . /* like ub.sysconf.ret-credit-pay */
    define variable v-sale-type     as character no-undo . /* like ub.sysconf.sale-type */
    define variable v-sale-code     as integer no-undo . /* like ub.sysconf.sale-code */
    define variable v-snr-accnt     as character no-undo . /* like ub.sysconf.snr-accnt */
    define variable v-SOEI          as character no-undo . /* like ub.sysconf.SOEI */
    define variable v-transport-cli-type as character no-undo . /* like ub.sysconf.transport-cli-type */
    define variable v-transport-cli-code as integer no-undo . /* like ub.sysconf.transport-cli-code */
    define variable v-transport-host     as integer no-undo . /* like ub.sysconf.transport-host */
    define variable v-transport-contract as integer no-undo . /* like ub.sysconf.transport-contract */
    define variable v-transport-uslov    as integer no-undo . /* like ub.sysconf.transport-uslov  */
    define variable v-transport-value    as decimal decimals 2 no-undo . /* like ub.sysconf.transport-value (dec-2) */
    define variable v-main-obj-type      as character no-undo . /* like ub.firm.main-obj-type -> clients.obj-type */
    define variable v-main-obj-code      as integer no-undo . /* like ub.firm.main-obj-code -> clients.obj-code */
    define variable v-als-gds            as logical no-undo . /* Торговля чужим товаром clntattr({&cmp}, host-code, {&attr-als-gds}) */
    define variable varals-gds-str       as character no-undo . /* для чтения v-als-gds */
    define variable varals-gds-str-type  as character no-undo . /* для чтения v-als-gds */
    define variable v-egrip-date         as date no-undo . /* ЕГРИП Дата clntattr({&cmp}, host-code, {&attr-egrip-date}) */
    define variable v-egrip-date-str     as character no-undo . /* для чтения v-egrip-date */
    define variable var-type             as character no-undo . /* для чтения v-egrip-date */
    define variable v-egrip-num          as character no-undo . /* ЕГРИП Номер clntattr({&cmp}, host-code, {&attr-egrip-num}) */
    define variable v-gen-s-f-office     as logical no-undo . /* like ub.sysconf.gen-s-f-office */

    /* для создания группы клиентов: */
    define variable v-cli-grp-name       as character no-undo .
    define variable obj-cli-grp as class cli-grps no-undo .
    define variable imp-cli-grp as class ibs.th.bge.1crn.import.impcli-grps no-undo .
    
    /* для создания клиентов: */
    define variable obj-clients as class clients no-undo .
    define variable imp-clients as class ibs.th.bge.1crn.import.impclients no-undo .
    
    define variable objImp as class firms no-undo.
    
    objImp = cast (subjectObj, firms).
        
    if objImp:del-f > 0 then do:
      Msg = "физическое удаление фирм не предусмотрено".
      v-retfl = false .
      return false. /* уходит в finally, где перевозвращает v-retfl вместо false */
    end.
    
    assign
      v-host-code = integer(objImp:code_)
      Msg = ""
    .
    if v-host-code > 0 then . else undo, throw new Progress.Lang.AppError("Не задан код фирмы") .

    /* чтобы при изменении записи не перезатирать поля, которые не приходят из 1С, значениями по умолчанию -
       читаем их значения из исходной записи */
    find first buf_sysconf no-lock where buf_sysconf.host-code = v-host-code no-error .

      
    if objImp:del-l > 0 then do:
      /* реализовано только для таблицы клиентов (контрагенты);
         реализации для фирм (юр.лицо) не найдено */
      find first buf_clients no-lock
           where buf_clients.obj-type = {&cmp}
             and buf_clients.obj-code = v-host-code no-error .
      if not available buf_clients then undo, throw new Progress.Lang.AppError(
        substitute("Не найдена запись КЛИЕНТ для записи СВОЯ ФИРМА с кодом [&1]", v-host-code)
      ) .

      if buf_clients.stts = 0 then do:
	      run ref/clients2.p             
	   (input ?    /* parparentproc; внутри не используется, передаётся процедурам машины правил rul/999999999.p */
	   ,input recid(buf_clients)
	   ,input {&bef-deleted-status-int} /* p-stts: {&current-status-int} - запись видна, {&deleted-status-int} - запись как бы удалена */
	   ,input true /* p-silent */
	   ,input no   /* отсюда удаляем только {&cmp}, а магазины и склады - в импорте АЗС, не в импорте контрагентов или фирм */
	   ,input '':U /*p-mode2*/
	   ,input '':U /*p-source-type*/
	   ,input '':U /*p-source-ref*/
	   ) .
      end.

      /* v-retfl = true . */
      /* после delete уйдёт в update и пропишет изменения, если часть полей удаляемой фирмы хотели изменить */
    end. /* end_of objImp:del-l */
    else if (available buf_sysconf) and (objImp:del-l = 0) then do:
      find first buf_clients no-lock
           where buf_clients.obj-type = {&cmp}
             and buf_clients.obj-code = v-host-code no-error .
      if not available buf_clients then undo, throw new Progress.Lang.AppError(
        substitute("Не найдена запись КЛИЕНТ для записи СВОЯ ФИРМА с кодом [&1]", v-host-code)
      ) .
      
      if buf_clients.stts <> {&bef-current-status-int} then do:
        run ref/clients2.p             
        (input ?    /* parparentproc; внутри не используется, передаётся процедурам машины правил rul/999999999.p */
        ,input recid(buf_clients)
        ,input {&bef-current-status-int} /* p-stts: {&current-status-int} - запись видна, {&deleted-status-int} - запись как бы удалена */
        ,input true /* p-silent */
        ,input no   /* отсюда удаляем только {&cmp}, а магазины и склады - в импорте АЗС, не в импорте контрагентов или фирм */
        ,input '':U /*p-mode2*/
        ,input '':U /*p-source-type*/
        ,input '':U /*p-source-ref*/
        ) .
      end.
    end .

     
    /* create, update */
    if available buf_sysconf then do: /* update */
        find first buf_firm no-lock where buf_firm.firm-code = v-host-code no-error .
        if not available buf_firm then undo, throw new Progress.Lang.AppError(
          substitute("Не найдена запись ФИРМА для записи СВОЯ ФИРМА с кодом [&1]", v-host-code)
        ) .
        
        &scop proc-name clntattr-value
        {&run_proc_attr-lib}
        (input  {&cmp}
        ,input  v-host-code
        ,input  {&attr-als-gds}
        ,output varals-gds-str
        ,output varals-gds-str-type
        ) .

        &scop proc-name clntattr-value
        {&run_proc_attr-lib}
        (input  {&cmp}
        ,input  v-host-code
        ,input  {&attr-egrip-date}
        ,output v-egrip-date-str
        ,output var-type
        ) .
      
        &scop proc-name clntattr-value
        {&run_proc_attr-lib}
        (input  {&cmp}
        ,input  v-host-code
        ,input  {&attr-egrip-num}
        ,output v-egrip-num
        ,output var-type
        ) .
        
        assign
          v-mode      = {&update}
          v-is-deploy = false
          v-rid       = recid(buf_sysconf)
          v-avrg-price    = buf_sysconf.avrg-price
          v-artic-disable = buf_sysconf.artic-disable
          v-base-code     = buf_sysconf.base-code
          v-branch        = buf_sysconf.branch
          v-cash-pay      = buf_sysconf.cash-pay
          v-cashier       = buf_sysconf.cashier
          v-cons-vat-pc   = buf_sysconf.cons-vat-pc
          v-credit-pay    = buf_sysconf.credit-pay
          v-firm-db-num   = buf_sysconf.firm-db-num
          v-head-position = buf_sysconf.head-position
          v-KOPF          = buf_sysconf.KOPF
          v-negative-rest = buf_sysconf.negative-rest
          v-ord-prt       = buf_sysconf.ord-prt
          v-osn-base      = buf_sysconf.osn-base
          v-property      = buf_sysconf.property
          v-purch-code    = buf_sysconf.purch-code
          v-ret-credit-pay = buf_sysconf.ret-credit-pay
          v-sale-type     = buf_sysconf.sale-type
          v-sale-code     = buf_sysconf.sale-code
          v-snr-accnt     = buf_sysconf.snr-accnt
          v-SOEI          = buf_sysconf.SOEI
          v-transport-cli-type = buf_sysconf.transport-cli-type
          v-transport-cli-code = buf_sysconf.transport-cli-code
          v-transport-host     = buf_sysconf.transport-host
          v-transport-contract = buf_sysconf.transport-contract
          v-transport-uslov    = buf_sysconf.transport-uslov
          v-transport-value    = buf_sysconf.transport-value
          v-main-obj-type = buf_firm.main-obj-type
          v-main-obj-code = buf_firm.main-obj-code
          v-als-gds       = (varals-gds-str = "yes")
          v-egrip-date    = date( v-egrip-date-str )
          v-gen-s-f-office = buf_sysconf.gen-s-f-office
        .
    end. /* end_of update */
    else do: /* create */
        /* при создании фирмы создаем группу с кодом фирмы; согласовано с техносервом */
        /* 01/XI-2018  При приеме фирмы мы создаем группу клиентов с таким же названием.
                       Далее у нас система начинает проверки и ругается, что есть кавычки.
                       В группах их действительно не должно быть, а вот в название фирмы без кавычек никак.
           Изменить создание группы так, чтобы имя группы формировалось без кавычек.
           Название группы не может содержать символы /\:*?"<>|«»·
        */
        assign
          v-cli-grp-name = replace ( objImp:name_  , '/', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '\', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, ':', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '*', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '?', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '"', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '<', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '>', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '|', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '«', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '»', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '·', '' )
        .
        obj-cli-grp = new cli-grps ().
        obj-cli-grp:SetProp(obj-cli-grp:InitTag, "").
        obj-cli-grp:SetProp("code",       string(v-host-code)).
        obj-cli-grp:SetProp("upper-code", "2"). /* группа "2:Фирмы,Объекты"; согласована с техносервом */
        obj-cli-grp:SetProp("del-l",      "0").
        obj-cli-grp:SetProp("del-f",      "0").
        obj-cli-grp:SetProp("name",       v-cli-grp-name).
        obj-cli-grp:SetProp(obj-cli-grp:InitTag, "").
        imp-cli-grp = new ibs.th.bge.1crn.import.impcli-grps ().
        v-retfl = imp-cli-grp:Excute(obj-cli-grp).
        if not v-retfl then
          undo, throw new Progress.Lang.AppError(imp-cli-grp:Msg) .
          
        assign
          v-mode      = {&add-def}
          v-is-deploy = true
          v-rid       = ?
          v-avrg-price    = no
          v-artic-disable = no
          /* код базовой валюты - рубли; создан при первоначальной "раскрутке базы"; согласован с техносервом */
          v-base-code     = 0
          v-branch        = ""
          v-cash-pay      = 0
          v-cashier       = ""
          v-cons-vat-pc   = 0.0
          v-credit-pay    = 0
          v-firm-db-num   = 0
          v-head-position = ""
          v-KOPF          = ""
          v-negative-rest = no
          v-ord-prt       = no
          v-osn-base      = no
          v-property      = ""
          v-purch-code    = 1 /* выкуп */
          v-ret-credit-pay = 0
          /* контрагент РЕАЛИЗАЦИЯ - предопределён в раскрутке БД и согласован с техносервом */
          v-sale-type     = {&cmp}
          v-sale-code     = 800000001
          v-snr-accnt     = ""
          v-SOEI          = ""
          v-transport-cli-type = ""
          v-transport-cli-code = 0
          v-transport-host     = 0
          v-transport-contract = 0
          v-transport-uslov    = 0
          v-transport-value    = 0.0
          v-main-obj-type = ""
          v-main-obj-code = 0
          v-als-gds       = no
          v-egrip-date    = ?
          v-egrip-num     = ""
          v-gen-s-f-office = yes
        .
        /* и ещё поле contract-type
           character;X(8);Тип;Тип;;тип документа: прих., расх., внутр. Присваивается автоматически и никогда не меняется.`Typ`Tip;870;;0;;true;false;;;;;;;;;;1251;RUSSIAN_I;
           - обязательное; заполняется вероятно в триггере */
    end. /* end_of create */
      
      
      /* блок полей, который в протоколе скопировали с инпорта клиентов, сохраняем при помощи импорта клиентов */
      obj-clients = new clients ().
      obj-clients:SetProp(obj-clients:InitTag, "").
      obj-clients:SetProp("code",         objImp:code_).
      obj-clients:SetProp("del-l", string(objImp:del-l)).
      obj-clients:SetProp("del-f", string(objImp:del-f)).
      obj-clients:SetProp("name",         objImp:name_).
      obj-clients:SetProp("full-name",    objImp:name_).
      obj-clients:SetProp("city",      objImp:city).
      obj-clients:SetProp("ind",       objImp:ind).
      obj-clients:SetProp("inn",       objImp:inn).
      obj-clients:SetProp("kpp",       objImp:kpp).
      obj-clients:SetProp("agnt",      objImp:agnt).
      obj-clients:SetProp("post-adr",  objImp:post-adr).
      obj-clients:SetProp("e-mail",    objImp:e-mail).
      obj-clients:SetProp("leg-adr",   objImp:leg-adr).
      obj-clients:SetProp("okpo",      objImp:okpo).
      obj-clients:SetProp(obj-clients:InitTag, "").
      imp-clients = new ibs.th.bge.1crn.import.impclients ().
      v-retfl = imp-clients:Excute(obj-clients).
      if not v-retfl then undo, throw new Progress.Lang.AppError(imp-clients:Msg) .
         
          
      run adm/sysconf1.p
      (input-output v-rid  /* p-rid as recid, only for output */
      ,input v-mode        /* p-mode as character */
      ,input yes           /* p-silent: yes с выводом в return-value */
      ,input v-is-deploy   /* p-is-deploy: yes режим первоначальной раскрутки */
      /* Для режима первоначальной раскрути (p-is-deploy = yes) наличие записи в ub.clients.obj-code = p-host-code допустимо;
         для прочих режимов это вызывает ошибку "Уже есть КОНТРАГЕНТ-организация с кодом p-host-code".
         Для режима обновления (p-mode = {&update}) режим первоначальной раскрутки (p-is-deploy = yes) вызывает ошибку.
         Поэтому параметр p-is-deploy меняется совместно с p-mode:
           при p-mode = {&add-def} p-is-deploy = yes,
           при p-mode = {&update}  p-is-deploy = no.
         В результате мы можем обновлять поля clients средствами импорта для клиентов, реализованными с impclients.cls
      */          
       
      ,input v-host-code   /* p-host-code like ub.sysconf.host-code */
      ,input v-host-code   /* p-grp-code like ub.clients.grp-code */
      ,input objImp:name_  /* p-obj-name like ub.clients.obj-name */
      ,input v-avrg-price  /* p-avrg-price like ub.sysconf.avrg-price (log): yes Средние учётные цены Считать данную фирму посредником для отчетов; средние, последние учетные цены будут считаться по этой фирме; поле может быть истинно лишь в 1 фирме */
      ,input v-artic-disable /* p-artic-disable like ub.sysconf.artic-disable (log): Автомат. артикул; режим добавления новых товаров - автоматическое заполнение артикула */
   
      ,input v-base-code   /* p-base-code Код базовой валюты */
    
      ,input v-branch      /* p-branch like ub.sysconf.branch Отрасль (вид деятельности) */
      ,input v-cash-pay    /* p-cash-pay Код оплаты наличными, когда надо считать налог с продажи */
      ,input v-cashier     /* p-cashier like ub.sysconf.cashier Кассир */
      ,input v-cons-vat-pc /* p-cons-vat-pc like ub.sysconf.cons-vat-pc Консигнационный НДС >9.9<% */
      ,input v-credit-pay  /* p-credit-pay Код оплаты кредита, платежи с таким кодом допускаются только для авторизованных клиентов и не учитываются в платежах по карте */
      ,input v-firm-db-num /* p-firm-db-num like ub.sysconf.firm-db-num Номер главной БД для фирмы */
      ,input v-head-position /* p-head-position like ub.sysconf.head-position Должность рук-ля */
      ,input v-KOPF        /* p-KOPF like ub.sysconf.KOPF КОПФ */
      ,input v-negative-rest /* p-negative-rest like ub.sysconf.negative-rest Отрицательные остатки; начальное значение по фирме, которое используется при добавлении нового товара */
      ,input v-ord-prt     /* p-ord-prt like ub.sysconf.ord-prt Детальный заказ (по признакам) */
      ,input v-osn-base    /* p-osn-base like ub.sysconf.osn-base Учет ОС в баз. вал. (true) */
      ,input v-property    /* p-property like ub.sysconf.property Организационно-правовая форма */
      ,input v-purch-code  /* p-purch-code Тип приобретения */
      ,input v-ret-credit-pay /* p-ret-credit-pay Оплата задолженности по кредиту */

      ,input v-sale-type        /* p-sale-type */
      ,input v-sale-code        /* p-sale-code */
    
      ,input v-snr-accnt   /* p-snr-accnt like ub.sysconf.snr-accnt Главный бухгалтер */
      ,input v-SOEI        /* p-SOEI like ub.sysconf.SOEI СОЕИ */
      ,input v-transport-cli-type /* p-transport-cli-type like ub.sysconf.transport-cli-type Контрагент */
      ,input v-transport-cli-code /* p-transport-cli-code like ub.sysconf.transport-cli-code Код поставщика */
      ,input v-transport-host     /* p-transport-host like ub.sysconf.transport-host Фирма - Грузоперевозчик */
      ,input v-transport-contract /* p-transport-contract like ub.sysconf.transport-contract Договор оказания транспортных услуг */
      ,input v-transport-uslov    /* p-transport-uslov like ub.sysconf.transport-uslov Условия предоставления транспортных услуг */
      ,input v-transport-value    /* p-transport-value like ub.sysconf.transport-value Дополнения к условиям транспортировки (%, км, ...) */
      ,input v-main-obj-type      /* p-main-obj-type like ub.firm.main-obj-type -> clients.obj-type */
      ,input v-main-obj-code      /* p-main-obj-code like ub.firm.main-obj-code -> clients.obj-code */
      ,input v-als-gds     /* p-als-gds Торговля чужим товаром clntattr({&cmp}, host-code, {&attr-als-gds}) */
      ,input v-egrip-date  /* p-egrip-date ЕГРИП Дата clntattr({&cmp}, host-code, {&attr-egrip-date}) */
      ,input v-egrip-num   /* p-egrip-num ЕГРИП Номер clntattr({&cmp}, host-code, {&attr-egrip-num}) */
      ,input yes           /* p-gen-s-f-office like ub.sysconf.gen-s-f-office Генерация счет-фактур только в офисе */
      ) .
      v-retfl = true .
      
    /* end_of create, update */
    
      
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        Msg = exAppErrors:GetMessage(1) .
        if Msg > "" then . else Msg = "AppError в фирмах" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) . 
      if Msg > "" then . else Msg = "ProError в фирмах" .
      v-retfl = false .
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в фирмах" .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      if valid-object(imp-clients) then delete object imp-clients .
      if valid-object(obj-clients) then delete object obj-clients .
      if valid-object(imp-cli-grp) then delete object imp-cli-grp .
      if valid-object(obj-cli-grp) then delete object obj-cli-grp .
      return v-retfl .
    end finally .
  end method. /* end_of Excute */

end class.