/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс ипорта данных shops (АЗК/АЗС) из 1С

Автор: Молотков Сергей
Дата создания: 03/10/17
Author: Molotkov Sergey
Creation date: 03/10/17

*/

using Progress.Lang.*.
using ibs.th.gbl.gbl-var.
using ibs.th.ref.typl-ad.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.

class ibs.th.bge.1crn.import.impshops implements ibs.th.bge.1crn.import.iimpsubject:
  
  { cmp/str-glbl.i class }
  { gbl/attr-lib.i class }  
  { gbl/thbj-def.i } // thbjattr_thbj-attr
  
  
  define property Msg as character no-undo
    get. 
    set.

DEFINE TEMP-TABLE TT_cassa NO-UNDO LIKE ub.price-list-type-cassa.
DEFINE TEMP-TABLE TT_grp   NO-UNDO LIKE ub.price-list-type-gds-grp.
DEFINE TEMP-TABLE TT_pay-type NO-UNDO LIKE ub.price-list-type-pay-type.
DEFINE TEMP-TABLE TT_cash-pay NO-UNDO LIKE ub.price-list-type-cash-pay.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable v-mode      as character no-undo. /* create/update */
    define variable v-rid1      as recid no-undo .
    define variable v-rid2      as recid no-undo .
    define variable v-obj-code  as integer no-undo . /* like ub.shop.obj-code */
    define variable v-db-num    as integer no-undo . /* like ub.db.db-num */
    define variable v-host-code as integer no-undo . /* like ub.shop.host-code */
    define variable v-grp-code  as integer no-undo . /* like ub.clients.grp-code */
    define variable v-addr1     as character no-undo . /* первые 80 символов для address1 */
    define variable v-addr2     as character no-undo . /* оставшиеся символы для address2 */
    define variable v-tel       as character no-undo .
    define variable v-retfl     as logical no-undo .
    define buffer buf_shop    for ub.shop .
    define buffer buf_clients for ub.clients .

    /* поля, которые не приходят из 1С: */
    define variable v-ps             as character no-undo . /* like ub.clients.PS */
    define variable v-all-prt        as logical no-undo . /* like ub.shop.all-prt */
    define variable v-buy-goods      as logical no-undo . /* like ub.shop.buy-goods */
    define variable v-cd-bc-alt      as logical no-undo . /* like ub.shop.cd-bc-alt */
    define variable v-cd-bc-base     as logical no-undo . /* like ub.shop.cd-bc-base */
    define variable v-cd-loc-alt     as logical no-undo . /* like ub.shop.cd-loc-alt */
    define variable v-cd-loc-base    as logical no-undo . /* like ub.shop.cd-loc-base */
    define variable v-cd-parts-all   as logical no-undo . /* like ub.shop.cd-parts-all */
    define variable v-cd-parts-not-blank as logical no-undo . /* like ub.shop.cd-parts-not-blank */
    define variable v-cd-parts-ser   as logical no-undo . /* like ub.shop.cd-parts-ser */
    define variable v-cd-pb-alt      as logical no-undo . /* like ub.shop.cd-pb-alt */
    define variable v-cd-pb-base     as logical no-undo . /* like ub.shop.cd-pb-base */
    define variable v-cd-sc-base     as logical no-undo . /* like ub.shop.cd-sc-base */
    define variable v-chk-pay        as integer no-undo . /* like ub.shop.chk-pay */
    define variable v-day-only       as logical no-undo . /* like ub.shop.day-only */
    define variable v-discaloc       as logical no-undo . /* like ub.shop.discaloc */
    define variable v-doc-prt        as logical no-undo . /* like ub.shop.doc-prt */
    define variable v-down-pay       as integer no-undo . /* like ub.shop.down-pay */
    define variable v-fax            as character no-undo . /* like ub.shop.fax */
    define variable v-goods-man      as character no-undo . /* like ub.shop.goods-man */
    define variable v-in-ov          as logical no-undo . /* like ub.shop.in-ov */
    define variable v-in-pay         as integer no-undo . /* like ub.shop.in-pay */
    define variable v-in-perm        as logical no-undo . /* like ub.shop.in-perm */
    define variable v-inout-price    as logical no-undo . /* like ub.shop.inout-price */
    define variable v-inv-pay        as integer no-undo . /* like ub.shop.inv-pay */
    define variable v-is-catering        as logical no-undo . /* like ub.shop.is-catering */
    define variable v-is-kitchen         as logical no-undo . /* like ub.shop.is-kitchen */
    define variable v-is-kitchen-store   as logical no-undo . /* like ub.shop.is-kitchen-store */
    define variable v-kitchen-store-code as integer no-undo . /* like ub.shop.kitchen-store-code */
    define variable v-kitchen-store-type as character no-undo . /* like ub.shop.kitchen-store-type */
    define variable v-no-eq          as logical no-undo . /* like ub.shop.no-eq */
    define variable v-out-line-discnt as logical no-undo . /* like ub.shop.out-line-discnt */
    define variable v-out-pay        as integer no-undo . /* like ub.shop.out-pay */
    define variable v-out-rate       as logical no-undo . /* like ub.shop.out-rate */
    define variable v-pr-cash        as logical no-undo . /* like ub.shop.pr-cash */
    define variable v-price-calc     as logical no-undo . /* like ub.shop.price-calc */
    define variable v-ret-pay        as integer no-undo . /* like ub.shop.ret-pay */
    define variable v-ret-sup-pay    as integer no-undo . /* like ub.shop.ret-sup-pay */
    define variable v-fbr-pay        as integer no-undo . /* like ub.shop.fbr-pay */
    define variable v-rsrv-time      as integer no-undo . /* like ub.shop.rsrv-time */
    define variable v-shift-on       as logical no-undo . /* like ub.shop.shift-on */
    define variable v-store-boss     as character no-undo . /* like ub.shop.store-boss */
    define variable v-store-man      as character no-undo . /* like ub.shop.store-man */
    define variable v-sub-store-on   as logical no-undo . /* like ub.shop.sub-store-on */
    define variable v-sub-store-code as integer no-undo . /* like ub.shop.sub-store-code */
    define variable v-sub-store-type as character no-undo . /* like ub.shop.sub-store-type */
    define variable v-unit-cli-perm  as logical no-undo . /* like ub.shop.unit-cli-perm */
    define variable v-with-serv      as logical no-undo . /* like ub.shop.with-serv */
    define variable v-work-hours     as character no-undo . /* like ub.shop.work-hours */
    define variable v-purch-code     as integer no-undo . /* like ub.shop.purch-code */
    define variable v-envd           as logical no-undo . /* {&attr-envd} */
    define variable v-envd-str       as character no-undo . /* для чтения v-envd */
    define variable v-par-type       as character no-undo . /* для чтения v-envd */
    define variable v-pharm          as logical no-undo . /* {&attr-pharm} */
    define variable v-pharm-str      as character no-undo . /* для чтения v-pharm */
    define variable v-KPP            as character no-undo . /* {&attr-kpp} */
    define variable v-clim-grp       as character no-undo . /* {&attr-cli-clim-grp} */
    define variable v-decommissioned as logical no-undo . /* {&attr-cli-decommissioned} */
    define variable v-decommiss-str  as character no-undo . /* для чтения v-decommissioned */
    define variable v-begin-summer   as character no-undo . /* {&attr-cli-clim-grp}[2] = begin-summer */
    define variable v-begin-winter   as character no-undo . /* {&attr-cli-clim-grp}[3] = begin-winter */
    define variable v-edi            as logical   no-undo .
    
    define variable objImp as class shops no-undo.
    
    objImp = cast (subjectObj, shops).

    if objImp:del-f > 0 then do:
      Msg = "физичесткое удаление АЗС/АЗК не предусмотрено" .
      v-retfl = false .
      return false. /* уходит в finally, где перевозвращает v-retfl вместо false */
    end .
    
    assign
      v-obj-code  = integer(objImp:code_)
    .
    if v-obj-code > 0 then . else undo, throw new Progress.Lang.AppError("Не задан код АЗК/АЗС") .

    /* 10/IX-2018 В интерфейс передачи из 1С:ERP в GC секции «azks» будут добавлены поля
                «clim-grp», «begin-summer», «begin-winter» и «decommissioned».
                Значения, которые могут быть назначены полю «clim-grp», соответствуют
                обозначению климатической группы (подгруппы) для применения норм технологических потерь нефтепродуктов,
                указанному в ЛНД компании заказчика. */
    if (objImp:clim-grp > "") and (not can-do("1 (1),1 (2),2 (1),2 (2),2 (3),3 (1),3 (2)", objImp:clim-grp)) then do :
      undo, throw new Progress.Lang.AppError(
        substitute("значение clim-grp = [&1] отсутствует в обозначении климатических групп", objImp:clim-grp)
      ) .
    end . 
    
    /* чтобы при изменении записи не перезатирать поля, которые не приходят из 1С, значениями по умолчанию -
       читаем их значения из исходной записи;
       чтобы при изменении записи не затирать пустыми значениями поля из необязательных тегов, которые пришли из 1С, -
       читаем их значения из исходной записи */
    find first buf_shop no-lock where buf_shop.obj-code = v-obj-code no-error .
    /* для "чистого создания" магазина запись clients не будет найдена,
       а для всех остальных стучаев её всё равно придётся искать;
       поиск выполняем здесь, валидность проверяем по месту использования */
    find first buf_clients no-lock
         where buf_clients.obj-type = {&shop}
           and buf_clients.obj-code = v-obj-code no-error .

    
    if objImp:del-l > 0  then do:
      /* реализовано только для таблицы клиентов (контрагенты);
         пользовательский интерфейс работы с магазинами использует эту реализацию */
      if available buf_clients and buf_clients.stts = 0 then do:
        run ref/clients2.p             
        (input ?    /* parparentproc; внутри не используется, передаётся процедурам машины правил rul/999999999.p */
        ,input recid(buf_clients)
        ,input {&bef-deleted-status-int} /* p-stts: {&current-status-int} - запись видна, {&deleted-status-int} - запись как бы удалена */
        ,input true /* p-silent */
        ,input yes  /* отсюда удаляем и {&shop} - магазины и склады */
        ,input '':U /*p-mode2*/
        ,input '':U /*p-source-type*/
        ,input '':U /*p-source-ref*/
        ) .
        /* после delete уйдёт в create или в update и пропишет изменения, если часть полей удаляемого магазина хотели изменить */
      end .
      else undo, throw new Progress.Lang.AppError(
        substitute("Не найдена запись КЛИЕНТ для записи МАГАЗИН с кодом [&1]", v-obj-code)
      ) .
    end .
    else if (available buf_shop) and (objImp:del-l = 0) then do:
      /* восстановление после удаления */
      if available buf_clients then do:
        if buf_clients.stts <> {&bef-current-status-int} then do:
          run ref/clients2.p             
          (input ?    /* parparentproc; внутри не используется, передаётся процедурам машины правил rul/999999999.p */
          ,input recid(buf_clients)
          ,input {&bef-current-status-int} /* p-stts: {&current-status-int} - запись видна, {&deleted-status-int} - запись как бы удалена */
          ,input true /* p-silent */
          ,input yes  /* отсюда удаляем и {&shop} - магазины и склады */
          ,input '':U /*p-mode2*/
          ,input '':U /*p-source-type*/
          ,input '':U /*p-source-ref*/
          ) .
        end.
      end .
      else undo, throw new Progress.Lang.AppError(
        substitute("Не найдена запись КЛИЕНТ для записи МАГАЗИН с кодом [&1]", v-obj-code)
      ) .
    end .
    
    
    /* По импорту АЗК указано, что надо генерить БД, Объект, Группу ценообразования и ГТПЛ.
       К БД и объекту даны настройки, с которыми требуется создавать запись. */
    assign
      Msg = ""
      v-host-code = integer(objImp:frm-code)
      /* АЗС импортируются всегда в ГБД. При создании АЗС создаётся db-num = АЗС.code_ */
      v-db-num    = v-obj-code
      /* Группу для АЗС ищем по коду фирмы.
         Т.к. при создании фирмы создаётся группа с кодом фирмы (согласовано с техносервом) - указываем
         код фирмы в качестве кода группы */
      v-grp-code  = v-host-code
    .
    
    if available buf_shop then do:
      if available buf_clients then do:
        assign
          v-rid2 = recid(buf_clients)
          v-ps   = buf_clients.PS
        .
      end .
      else undo, throw new Progress.Lang.AppError(
        substitute("Не найдена запись КЛИЕНТ для записи МАГАЗИН с кодом [&1]", v-obj-code)
      ) .
    
        &scop proc-name clntattr-value
        {&run_proc_attr-lib}
      (input {&shop}
      ,input  v-obj-code
      ,input  {&attr-envd}
      ,output v-envd-str
      ,output v-par-type
      ) .
      
        &scop proc-name clntattr-value
        {&run_proc_attr-lib}
      (input {&shop}
      ,input  v-obj-code
      ,input  {&attr-pharm}
      ,output v-pharm-str
      ,output v-par-type
      ) .

        &scop proc-name clntattr-value
        {&run_proc_attr-lib}
      (input {&shop}
      ,input  v-obj-code
      ,input  {&attr-kpp}
      ,output v-KPP
      ,output v-par-type
      ) .

        &scop proc-name clntattr-value
        {&run_proc_attr-lib}
      (input {&shop}
      ,input  v-obj-code
      ,input  {&attr-cli-clim-grp}
      ,output v-clim-grp
      ,output v-par-type
      ) .

        &scop proc-name clntattr-value
        {&run_proc_attr-lib}
      (input {&shop}
      ,input  v-obj-code
      ,input  {&attr-cli-decommissioned}
      ,output v-decommiss-str
      ,output v-par-type
      ) .

      sliceAddress
         ( input  objImp:address
         , input  buf_shop.addres1
         , input  buf_shop.addres2
         , output v-addr1
         , output v-addr2
         ) .

      assign
        v-tel = if objImp:tel >= "" then objImp:tel else buf_shop.phone
      .
         
      assign
        v-chk-pay        = buf_shop.chk-pay
        v-down-pay       = buf_shop.down-pay
        v-in-pay         = buf_shop.in-pay
        v-inv-pay        = buf_shop.inv-pay
        v-out-pay        = buf_shop.out-pay
        v-ret-pay        = buf_shop.ret-pay
        v-ret-sup-pay    = buf_shop.ret-sup-pay
        v-fbr-pay        = buf_shop.fbr-pay
      .
      
      assign
        v-mode = {&update}
        v-all-prt         = buf_shop.all-prt
        v-buy-goods       = buf_shop.buy-goods
        v-cd-bc-alt       = buf_shop.cd-bc-alt
        v-cd-bc-base      = buf_shop.cd-bc-base
        v-cd-loc-alt      = buf_shop.cd-loc-alt
        v-cd-loc-base     = buf_shop.cd-loc-base
        v-cd-parts-all    = buf_shop.cd-parts-all
        v-cd-parts-not-blank = buf_shop.cd-parts-not-blank
        v-cd-parts-ser    = buf_shop.cd-parts-ser
        v-cd-pb-alt       = buf_shop.cd-pb-alt
        v-cd-pb-base      = buf_shop.cd-pb-base
        v-cd-sc-base      = buf_shop.cd-sc-base
        v-day-only        = buf_shop.day-only
        v-discaloc        = buf_shop.discaloc
        v-doc-prt         = buf_shop.doc-prt
        v-fax             = buf_shop.fax
        v-goods-man       = buf_shop.goods-man
        v-in-ov           = buf_shop.in-ov
        v-in-perm         = buf_shop.in-perm
        v-inout-price     = buf_shop.inout-price
        v-is-catering        = buf_shop.is-catering
        v-is-kitchen         = buf_shop.is-kitchen
        v-is-kitchen-store   = buf_shop.is-kitchen-store
        v-kitchen-store-code = buf_shop.kitchen-store-code
        v-kitchen-store-type = buf_shop.kitchen-store-type
        v-no-eq           = buf_shop.no-eq
        v-out-line-discnt = buf_shop.out-line-discnt
        v-out-rate        = buf_shop.out-rate
        v-pr-cash         = buf_shop.pr-cash
        v-price-calc      = buf_shop.price-calc
        v-rsrv-time       = buf_shop.rsrv-time
        v-shift-on        = buf_shop.shift-on
        v-store-boss      = buf_shop.store-boss
        v-store-man       = buf_shop.store-man
        v-sub-store-on    = buf_shop.sub-store-on
        v-sub-store-code  = buf_shop.sub-store-code
        v-sub-store-type  = buf_shop.sub-store-type
        v-unit-cli-perm   = buf_shop.unit-cli-perm
        v-with-serv       = buf_shop.with-serv
        v-work-hours      = buf_shop.work-hours
        v-purch-code      = buf_shop.purch-code
        v-envd            = (v-envd-str = "yes":u)
        v-pharm           = (v-pharm-str = "yes":u)
        v-decommissioned  = (v-decommiss-str = "yes":u)
      .
      if num-entries(v-clim-grp) = 3 then assign
        v-begin-summer = entry(2, v-clim-grp)
        v-begin-winter = entry(3, v-clim-grp)
        v-clim-grp     = entry(1, v-clim-grp)
      .
      assign
        v-clim-grp       = objImp:clim-grp     when objImp:clim-grp > ""
        v-begin-summer   = objImp:begin-summer when objImp:begin-summer > ""
        v-begin-winter   = objImp:begin-winter when objImp:begin-winter > ""
        v-decommissioned = (objImp:decommissioned > 0) when (objImp:decommissioned <> ?)
        v-edi            = (objImp:edi > 0) when (objImp:edi <> ?)
        v-KPP            = objImp:kpp when objImp:kpp > ""
      .
    end .
    else do :
      assign
        v-mode = {&add-def}
        v-rid1 = ?
      . 
      /* db с номером АЗС.code_ должна была быть создана раньше магазина */
      /* sysconf с номером db. должна была быть создана раньше записи о БД */
      /* создаём в ГБД запись об УБД */
      run adm/db01.p 
      (input-output v-rid1
      ,input v-mode
      ,input v-db-num      /* p-db-num like ub.db.db-num */
      /* ub.db.db-key       "Ключ БД"   пустое значение */
      /* ub.db.db-key-enc   "Кодировка" пустое значение */
      ,input objImp:name_  /* p-db-name like ub.db.db-name */
      ,input true /* ub.db.add-clients  "Возможность добавления клиентов" true - согласно замечанию Обрезановой Екатерины от 24-ноя-2017 */
      /* ub.db.remote-stock "Отправка чужих остатков"        false - вводится только в УБД */
      ,input true /* ub.db.send-check   "Отправлять чеки из БД в ГБД"     true - согласно скрин-шоту Юрия Румянцева от 02-мар-2017; вводится только в УБД */
      ,input true /* ub.db.add-goods    "Возможность добавлять товары"    true - согласно замечанию Обрезановой Екатерины от 24-ноя-2017 */
      /* ub.db.on-line-rest "Мгновенные остатки"             false - вводится только в УБД */
      ,10 /* ub.db.save-packs (int) "Удалять файлы пакетов СПН из каталога heap через N дней" N=10 согласно скрин-шоту Юрия Румянцева от 02-мар-2017 (! init value в БД = 0 !) - вводится только в УБД */
      /* ub.db.max-p-size   "Максимальное кол-во записей в пакете"   10000 согласно скрин-шоту Юрия Румянцева от 02-мар-2017 (! init value в БД = 0 !) - вводится только в УБД */
      /* ub.db.max-p-queue  "Кол-во неподтвержденных пакетов больше"    10 согласно скрин-шоту Юрия Румянцева от 02-мар-2017 (! init value в БД = 0 !) - вводится только в УБД */
      /* ub.db.max-p-time   "Время ожидания подтверждения больше (мин)"  0 - вводится только в УБД */
      /* ub.db.unload-arch  "Выгружать складские архивы по товарам и по поставщикам" true - вводится только в УБД */
      /* ub.db.unload-aht   "Выгружать складской архив по типам приобретения"        true - вводится только в УБД */
      ) .
      /* in dbi.w Выгружать историю t-unload-history по умолчанию initial true работает в режиме выгрузки УБД when mode = "unld" */

      sliceAddress
         ( input  objImp:address
         , input  ""
         , input  ""
         , output v-addr1
         , output v-addr2
         ) .

      /* 22/XI-2017 все pay-type выставляем в 0, т.к. в начальной раскрутке их нет и в импорте они могут не придти */
      /* 22/X-2018  Настройки типов платежей в карточке объекта выставить согласно картинке в файл Настроки Объектов */
      assign
        v-in-pay         = 2 /* tt-shop.in-pay      AT ROW  8.19 COL 18.8 COLON-ALIGNED LABEL "Оплата п&рихода" */
        v-out-pay        = 2 /* tt-shop.out-pay     AT ROW  9.19 COL 18.8 COLON-ALIGNED LABEL "рас&хода" */
        v-ret-pay        = 2 /* tt-shop.ret-pay     AT ROW 10.19 COL 18.8 COLON-ALIGNED LABEL "во&зврата" */
        v-ret-sup-pay    = 3 /* tt-shop.ret-sup-pay AT ROW 11.19 COL 18.8 COLON-ALIGNED LABEL "возвра&та пост." */
        v-down-pay       = 2 /* tt-shop.down-pay    AT ROW 12.19 COL 18.8 COLON-ALIGNED LABEL "списани&я" */
        v-inv-pay        = 2 /* tt-shop.inv-pay     AT ROW 13.19 COL 18.8 COLON-ALIGNED LABEL "и&нвентаризации" */
        v-chk-pay        = 1 /* tt-shop.chk-pay     AT ROW 14.19 COL 18.8 COLON-ALIGNED LABEL "прода&жи" */
        v-fbr-pay        = 2 /* tt-shop.fbr-pay     AT ROW 15.19 COL 18.8 COLON-ALIGNED LABEL "производства" */
      .
      assign
        v-tel = if objImp:tel >= "" then objImp:tel else ""
        v-clim-grp       = objImp:clim-grp
        v-begin-summer   = objImp:begin-summer
        v-begin-winter   = objImp:begin-winter
        v-decommissioned = if objImp:decommissioned > 0 then true else ?
        v-edi            = if objImp:edi > 0 then true else ?
        v-KPP = if objImp:kpp >= "" then objImp:kpp else ""
      .
      
      assign
        v-rid2 = ?
        v-ps             = ""
        v-all-prt        = false
        v-buy-goods      = true
        v-cd-bc-alt      = false
        v-cd-bc-base     = true
        v-cd-loc-alt     = false
        v-cd-loc-base    = true
        v-cd-parts-all   = false
        v-cd-parts-not-blank = false
        v-cd-parts-ser   = false
        v-cd-pb-alt      = false
        v-cd-pb-base     = true
        v-cd-sc-base     = true
        v-day-only       = yes
        v-discaloc       = yes
        v-doc-prt        = no
        v-fax            = ""
        v-goods-man      = ""
        v-in-ov          = no
        v-in-perm        = no
        v-inout-price    = yes
        v-is-catering        = yes
        v-is-kitchen         = no
        v-is-kitchen-store   = no
        v-kitchen-store-code = 0
        v-kitchen-store-type = ""
        v-no-eq           = yes /* 18/XII-2018 устанавливать галочку «Запрещен приход при отсутствии цен» */
        v-out-line-discnt = no
        v-out-rate       = no
        v-pr-cash        = yes
        v-price-calc     = no
        v-rsrv-time      = 0
        v-shift-on       = yes
        v-store-boss     = ""
        v-store-man      = ""
        v-sub-store-on   = no
        v-sub-store-code = 0
        v-sub-store-type = ""
        v-unit-cli-perm  = yes
        v-with-serv      = yes
        v-work-hours     = ""
        v-purch-code     = ?
        v-envd           = no
        v-pharm          = no
      .
    end.
    run adm/shop01.p
    (input-output v-rid2 /* p-rid as recid, only for output */
    ,input v-mode        /* p-mode as character */
    ,input v-obj-code    /* p-obj-code like ub.shop.obj-code */
    ,input v-db-num      /* p-db-num like ub.clients.db-num */
    ,input v-host-code   /* p-host-code like ub.shop.host-code */
    ,input v-grp-code    /* p-grp-code like ub.clients.grp-code */
    ,input objImp:name_  /* p-obj-name like ub.clients.obj-name */
    ,input v-ps          /* p-PS like ub.clients.PS */
    ,input objImp:accr   /* p-acct like ub.shop.acct - бухгалтер */
    ,input v-addr1       /* p-addres1 like ub.shop.addres1 */
    ,input v-addr2       /* p-addres2 like ub.shop.addres2 */

    /* параметры отсылки товаров на кассу магазина */    
    ,input v-all-prt     /* p-all-prt like ub.shop.all-prt передача на кассу ВСЕХ признаков товаров */
    ,input v-buy-goods   /* p-buy-goods like ub.shop.buy-goods yes - приоритетная продажа выкупного товара, no - консигнационного */
    
    ,input v-cd-bc-alt    /* p-cd-bc-alt like ub.shop.cd-bc-alt пересылать на кассу Бар-код доп. ед. изм. */
    ,input v-cd-bc-base   /* p-cd-bc-base like ub.shop.cd-bc-base пересылать на кассу Бар-код осн. ед. изм. */
    ,input v-cd-loc-alt   /* p-cd-loc-alt like ub.shop.cd-loc-alt пересылать на кассу Лок. код доп. ед. изм. */
    ,input v-cd-loc-base  /* p-cd-loc-base like ub.shop.cd-loc-base пересылать на кассу Лок. код осн. ед. изм. */
    ,input v-cd-parts-all /* p-cd-parts-all like ub.shop.cd-parts-all пересылать на кассу Партии для всех товаров */
    ,input v-cd-parts-not-blank /* p-cd-parts-not-blank like ub.shop.cd-parts-not-blank пересылать на кассу Партии для товаров с непустыми номерами */
    ,input v-cd-parts-ser /* p-cd-parts-ser like ub.shop.cd-parts-ser пересылать на кассу Партии для серийных товаров */
    ,input v-cd-pb-alt    /* p-cd-pb-alt like ub.shop.cd-pb-alt пересылать на кассу Доп. БК доп. ед. изм. */
    ,input v-cd-pb-base   /* p-cd-pb-base like ub.shop.cd-pb-base пересылать на кассу Доп. БК осн. ед. изм. */
    ,input v-cd-sc-base   /* p-cd-sc-base like ub.shop.cd-sc-base пересылать на кассу Вес. код */
    
    ,input v-chk-pay     /* p-chk-pay like ub.shop.chk-pay = pay-type.obj-code Код оплаты продажи по умолчанию */
    ,input v-day-only    /* p-day-only like ub.shop.day-only yes (нач. значение) - в кассовом отчете присутствуют чеки только за один день (или часть дня), no - за произвольный (больший) период */
    ,input objImp:director /* p-director like ub.shop.director */
    ,input v-discaloc    /* p-discaloc like ub.shop.discaloc Размазывать скидку на итог */
    ,input v-doc-prt     /* p-doc-prt like ub.shop.doc-prt учёт по шкалам */
    ,input v-down-pay    /* p-down-pay like ub.shop.down-pay Код оплаты списания по умолчанию */
    ,input v-fax         /* p-fax like ub.shop.fax */
    ,input v-goods-man   /* p-goods-man like ub.shop.goods-man */
    ,input v-in-ov       /* p-in-ov like ub.shop.in-ov Переоценка после прихода */
    ,input v-in-pay      /* p-in-pay like ub.shop.in-pay Код оплаты прихода по умолчанию */
    ,input v-in-perm     /* p-in-perm like ub.shop.in-perm Перемещение по цене магазина */
    ,input v-inout-price /* p-inout-price like ub.shop.inout-price Изменение налогов поставщика в ПН */
    ,input v-inv-pay     /* p-inv-pay like ub.shop.inv-pay Код оплаты инвентаризации по умолчанию */
    
    /* Склад кухни - это сам магазин.
       Т.к. номер магазина совпадает с номером Склада кухни,
       то сначала надо создать обьект магазин, а потом уже присвоить номер Склад кухни. */
    ,input v-is-catering        /*  p-is-catering like ub.shop.is-catering Объект-РЕСТОРАН */
    ,input v-is-kitchen         /* *p-is-kitchen like ub.shop.is-kitchen Объект-кухня */
    ,input v-is-kitchen-store   /* *p-is-kitchen-store like ub.shop.is-kitchen-store Объект-склад для кухни */
    ,input v-kitchen-store-code /* *p-kitchen-store-code like ub.shop.kitchen-store-code Код объекта Склад Кухни */
    ,input v-kitchen-store-type /* *p-kitchen-store-type like ub.shop.kitchen-store-type Перечислимый тип объекта Склад Кухни */
    /* поле objImp:cafe_exist по смыслу отличается от комбинации полей is-kitchen; его пока не обрабатываем */

    ,input v-no-eq          /* p-no-eq like ub.shop.no-eq Если включено - нельзя закрыть приход при нулевых или отсутствующих продажных ценах */
    ,input v-out-line-discnt /* p-out-line-discnt like ub.shop.out-line-discnt Можно установить скидку по строке накладной */
    ,input v-out-pay        /* p-out-pay like ub.shop.out-pay Код оплаты расхода по умолчанию */
    ,input v-out-rate       /* p-out-rate like ub.shop.out-rate Можно менять курс расходной накладной */
    ,input v-tel            /* p-phone like ub.shop.phone */
    ,input v-pr-cash        /* p-pr-cash like ub.shop.pr-cash Разрешить переоценку без блокировки касс */
    ,input v-price-calc     /* p-price-calc like ub.shop.price-calc нельзя закрыть приход на объекте, если приходная цена не равна продажной */
    ,input v-ret-pay        /* p-ret-pay like ub.shop.ret-pay Код оплаты возврата по умолчанию */
    ,input v-ret-sup-pay    /* p-ret-sup-pay like ub.shop.ret-sup-pay Код типа оплаты для операции "возврат поставщику" */
    ,input v-fbr-pay        /* p-fbr-pay like ub.shop.fbr-pay Код оплаты производства по умолчанию */
    
    ,input v-rsrv-time      /* p-rsrv-time like ub.shop.rsrv-time период в днях, подставляемый по умолчанию для резерва при создании нового счета */
    ,input v-shift-on       /* p-shift-on like ub.shop.shift-on На объекте включены смены */
    ,input v-store-boss     /* p-store-boss like ub.shop.store-boss Зав. складом */
    ,input v-store-man      /* p-store-man like ub.shop.store-man Кладовщик */
    ,input v-sub-store-on   /* p-sub-store-on like ub.shop.sub-store-on Определять товародвижение по подсобке */
    ,input v-sub-store-code /* p-sub-store-code like ub.shop.sub-store-code Код объекта-подсобки */
    ,input v-sub-store-type /* p-sub-store-type like ub.shop.sub-store-type Тип объекта-подсобки */
    ,input v-unit-cli-perm  /* p-unit-cli-perm like ub.shop.unit-cli-perm Изменение ед. изм. поставщика */
    ,input v-with-serv      /* p-with-serv like ub.shop.with-serv yes - если маг-н реализует услуги */
    ,input v-work-hours     /* p-work-hours like ub.shop.work-hours Часы работы в формате "99.99,99.99" */
    ,input v-purch-code     /* p-purch-code like ub.shop.purch-code (int) Тип приобретерия */
    ,INPUT v-envd           /* p-envd доп.атрибуты по ЕНВД */ 
    ,INPUT v-pharm          /* p-pharm доп.атрибуты по Аптека */
    ,input v-KPP            /* p-KPP доп.атрибуты по КПП */
    ) .

    for first buf_shop exclusive-lock
        where buf_shop.obj-code = v-obj-code:
      assign
        buf_shop.is-kitchen         = yes
        buf_shop.kitchen-store-type = {&shop}
        buf_shop.kitchen-store-code = v-obj-code
      .
    end.
    If objimp:hist-code ne ?
    then do:
    &scop proc-name db-attr-write
    {&run_proc_attr-lib}  ( input v-db-num
                                        , input {&attr-hist-code}
                                        , input objimp:hist-code
                                        ) no-error .
    end.
    If objimp:hist-name ne ?
    then do:
    &scop proc-name db-attr-write
    {&run_proc_attr-lib}  ( input v-db-num
                                        , input {&attr-hist-name}
                                        , input objimp:hist-name
                                        ) no-error .
     end.
     &scop proc-name clntattr-write
        {&run_proc_attr-lib}
      (input {&shop}
      ,input v-obj-code
      ,input {&attr-cli-clim-grp}
      ,input substitute("&1,&2,&3", v-clim-grp, v-begin-summer, v-begin-winter)
      ) .

      if v-decommissioned <> ? then do :
        &scop proc-name clntattr-write
        {&run_proc_attr-lib}
      (input {&shop}
      ,input v-obj-code
      ,input {&attr-cli-decommissioned}
      ,input string(v-decommissioned)
      ) .
      end .

    /* 28/VIII-2018 Если номер БД для начальных настроек больше нуля,
                    то после создания нового объекта и новой БД копируем с заданной БД расписание и права. */
    define buffer buf_sysconf for ub.sysconf . 
    /* Права и расписания копировать не нужно. Расписания создаются в тиражной утилите.
    if v-mode = {&add-def} then do :
      /* 28/VIII-2018 При загрузке нового объекта смотрим его фирму, смотрим начальные настройки.
                      Название параметра «Номер БД для копирования прав и расписания при импорте из 1С».
                      Хранится в поле sysconf.xdn-grp-code */
      find first buf_sysconf no-lock where buf_sysconf.host-code = v-host-code no-error .
      if available buf_sysconf then do :
        if buf_sysconf.xdn-grp-code > 0 then do :
          
          /* 28/VIII-2018 Таблицы по правам для копирования:
Action-role
Action-role-attr
Action-role-item
Расписание: schedule, schedule-attr
          */
          define buffer buf_Action-role      for ub.action-role .
          define buffer buf_Action-role-attr for ub.action-role-attr .
          define buffer buf_Action-role-item for ub.action-role-item .
          define buffer buf_Action-role2      for ub.action-role .
          define buffer buf_Action-role-attr2 for ub.action-role-attr .
          define buffer buf_Action-role-item2 for ub.action-role-item .
          for each buf_Action-role-item2 exclusive-lock
             where buf_Action-role-item2.db-num = v-db-num :
            delete buf_Action-role-item2 .
          end .
          for each buf_Action-role-attr2 exclusive-lock
             where buf_Action-role-attr2.db-num = v-db-num :
            delete buf_Action-role-attr2 .
          end .
          for each buf_Action-role2 exclusive-lock
             where buf_Action-role2.db-num = v-db-num :
            delete buf_Action-role2 .
          end .
          for each buf_Action-role no-lock
             where buf_Action-role.db-num = buf_sysconf.xdn-grp-code :
            create buf_Action-role2 .
            buffer-copy buf_Action-role to buf_Action-role2
            assign
              buf_Action-role2.db-num = v-db-num
            .
          end .
          for each buf_Action-role-attr no-lock
             where buf_Action-role-attr.db-num = buf_sysconf.xdn-grp-code :
            create buf_Action-role-attr2 .
            buffer-copy buf_Action-role-attr to buf_Action-role-attr2
            assign
              buf_Action-role-attr2.db-num = v-db-num
            .
          end .
          for each buf_Action-role-item no-lock
             where buf_Action-role-item.db-num = buf_sysconf.xdn-grp-code :
            create buf_Action-role-item2 .
            buffer-copy buf_Action-role-item to buf_Action-role-item2
            assign
              buf_Action-role-item2.db-num = v-db-num
            .
          end .
          
          define buffer buf_schedule      for ub.schedule .
          define buffer buf_schedule-attr for ub.schedule-attr .
          define buffer buf_schedule2      for ub.schedule .
          define buffer buf_schedule-attr2 for ub.schedule-attr .
          for each buf_schedule-attr2 exclusive-lock
             where buf_schedule-attr2.cre-db-num = v-db-num :
            delete buf_schedule-attr2 .
          end .
          for each buf_schedule2 exclusive-lock
             where buf_schedule2.cre-db-num = v-db-num :
            delete buf_schedule2 .
          end .
          for each buf_schedule no-lock
             where buf_schedule.cre-db-num = buf_sysconf.xdn-grp-code :
            create buf_schedule2 .
            buffer-copy buf_schedule to buf_schedule2
            assign
              buf_schedule2.cre-db-num  = v-db-num
              buf_schedule2.db-num-char = string(v-db-num) // = string(v-obj-code) = string(v-db-num) 
            .
            if buf_schedule.task-type = "autonws" then buf_schedule2.db-num-char = "0" .
          end .
          for each buf_schedule-attr no-lock
             where buf_schedule-attr.cre-db-num = buf_sysconf.xdn-grp-code :
            create buf_schedule-attr2 .
            buffer-copy buf_schedule-attr to buf_schedule-attr2
            assign
              buf_schedule-attr2.cre-db-num = v-db-num
            .
            if buf_schedule-attr.task-type = "autogcd"
            then do :
              if buf_schedule-attr.attr-code = "schedule-obj-list"
              then buf_schedule-attr2.attr-value = replace(buf_schedule-attr.attr-value, string(buf_sysconf.xdn-grp-code), string(v-db-num)) .
            end.
          end .
          
        end . // end_of if buf_sysconf.xdn-grp-code
      end .
    end . // end_of копирование прав для v-mode = &add-def
    */
    /* 19/X-2018 При создании объекта выставлять следующие настройки: */
    define variable v-param-type as character no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date as date no-undo .
    define variable v-value-decimal as decimal no-undo .
    define variable v-value-integer as INTEGER no-undo .
    define variable v-value-logical AS LOGICAL no-undo .
    define variable v-tth as handle no-undo .
    
    v-tth = buffer thbjattr_thbj-attr:table-handle .
    empty temp-table thbjattr_thbj-attr .
    run adm/shattri.p (
            input "init":U
          , input {&shop}
          , input v-obj-code
          , input {&attr-marking}
          , input "":U
          , output v-value-character
          , output v-value-date
          , output v-value-decimal
          , output v-value-integer
          , output v-value-logical
          , output v-param-type
          , INPUT-OUTPUT table-handle v-tth
          ) no-error .
    if error-status:error then do:
      undo, throw new Progress.Lang.AppError(
        substitute(  "Ошибка чтения начальных значений настроек работы со справочниками товаров в контексте объекта [&1 &2]",
                     error-status:get-message(1), return-value  )
      ) .
    end .
    FOR EACH thbjattr_thbj-attr:
      case thbjattr_thbj-attr.prop-code :
        when {&attr-marking_marking-EDO} then do: // объект работает с EDI
          thbjattr_thbj-attr.property-value-logical = v-edi .
          define variable mImp2CdH as handle no-undo.
          run str/imp2cdgeth.p(output mImp2CdH).
          run fill-setting in mImp2CdH ({&TABLE_THBJ-ATTR},
                                     {&shop},
                                     v-obj-code, 
                                     thbjattr_thbj-attr.upper-prop-code,
                                     thbjattr_thbj-attr.prop-code).
        end.
      end case .
    END .
    thbjattr_set-section ({&shop}, v-obj-code, {&attr-marking}, input table thbjattr_thbj-attr) .
    
    
    if v-mode = {&add-def} then do :
      v-tth = buffer thbjattr_thbj-attr:table-handle .
      
      /* Опции работы со справочниками в контексте объекта:
         - Установить запрет на ввод доп. баркодов
      */
      empty temp-table thbjattr_thbj-attr .
      run adm/shattri.p (
              input "init":U
            , input {&shop}
            , input v-obj-code
            , input {&attr-gds-ref_obj}
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT table-handle v-tth
            ) no-error .
      if error-status:error then do:
        undo, throw new Progress.Lang.AppError(
          substitute(  "Ошибка чтения начальных значений настроек работы со справочниками товаров в контексте объекта [&1 &2]",
                       error-status:get-message(1), return-value  )
        ) .
      end .
      FOR EACH thbjattr_thbj-attr:
        case thbjattr_thbj-attr.prop-code :
          when {&attr-gds-ref_obj_chg-bcod} then // Запрещена работа с Доп-БК
            thbjattr_thbj-attr.property-value-logical = true .
        end case .
      END .
      thbjattr_set-section ({&shop}, v-obj-code, {&attr-gds-ref_obj}, input table thbjattr_thbj-attr) .
      
      
      empty temp-table thbjattr_thbj-attr .
    end . // end_of опции при создании объекта

    /* При создании объекта магазин в системе автоматически создавать группу ценообразования для него и ГТПЛ. */
    define variable proc-typl-ad as class typl-ad no-undo .
    define variable v-plt-id     as integer no-undo .
    define variable v-plt-recid  as recid no-undo .
    
    proc-typl-ad = new typl-ad () .
    if v-mode = {&add-def} then do :
      /* первичный ключ по типам прайс-листов
           ub.price-list-type.plt-id     = p-plt-id
       and ub.price-list-type.plt-db-num = p-db-num,
         где plt-db-num = v-db-num = v-obj-code = objImp:code_, т.к. тип прайс-листа создаётся для УБД 
      */
      v-plt-id = next-value (s-plt, {&db-name_schema})  .
      proc-typl-ad:type-price-list-ADD
      (input v-plt-id
      ,input v-db-num
      ,substitute("ГТПЛ по объекту &1&2", {&shop}, v-obj-code) /* p-name like ub.price-list-type.name not null */
      
      /* -- значения входных параметров копировались из вызова cmp/ththovr.p:type-price-list-ADD() -- */
      
      ,0 /* p-ban-discnt like ub.price-list-type.ban-discnt (int) Признак - запрещены еще какие-либо скидки (0 - не запрещены, 1 - запрещены) */
      
      ,{&pr-round-off} /* p-calc-round-method like ub.price-list-type.calc-round-method (chr) Метод округления по умолчанию */
      ,0.0             /* p-calc-round-base   like ub.price-list-type.calc-round-base (dec-2) база для округления / коэффициент */
      ,0.0             /* p-calc-increase-pc  like ub.price-list-type.calc-increase-pc (dec-10) Процент наценки по умолчанию */
      ,{&pr-calc-no}   /* p-calc-method       like ub.price-list-type.calc-method (chr) Исходная цена - метод формирования цены */
      
      ,1 /* p-create-price-doc like ub.price-list-type.create-price-doc (int) Формировать переоценки (0 - не формировать, 1 - формировать) */
      
      ,false /* p-fix-cource-crc-base like ub.price-list-type.fix-cource-crc-base Признак - фиксированный курс базовой валюты */
      ,false /* p-fix-cource-crc-doc  like ub.price-list-type.fix-cource-crc-doc  Признак - фиксированный курс валюты прайс-листа */

      /* для p-plt-main-id = 0 в поля .plt-main-db-num и .plt-main-id запишутся значения, соответвтвующие .plt-db-num и .plt-id */
      ,true     /* p-main            like ub.price-list-type.main                  Признак - главный прайс-лист */
      ,0        /* p-plt-main-id     like ub.price-list-type.plt-main-id     (int) Код главного типа прайс-листа */      
      ,v-db-num /* p-plt-main-db-num like ub.price-list-type.plt-main-db-num (int) Номер БД главного типа прайс-листа */
      ,0        /* p-priority        like ub.price-list-type.priority Приоритет (у главного прйс-листа - самый низкий приоритет 0) */
      ,1        /* p-only-gbd        like ub.price-list-type.only-gbd Признак - прайс-листы могут создаваться только в главной базе данных (0 - во всех базах, 1 - только в главной базе данных) */

      /* признак "главный"/"неглавный" должен совпадать у подчинённого прайс-листа и у его родительского прайс-листа */   
      ,0 /* p-under-type-list    like ub.price-list-type.under-type-list Признак - подчиненный прайс-лист (0 - не подчиненный, 1 - подчиненый) */
      ,? /* p-under-round-method like ub.price-list-type.under-round-method (chr) Метод округления подчиненного прйс-листа */
      ,? /* p-under-perc         like ub.price-list-type.under-perc (dec-2) Процент скидки-наценки подчиненного прайс-листа (минус - скидка, плюс - наценка) */
      ,1 /* p-under-hand-corr    like ub.price-list-type.under-hand-corr Подлежит ручной коррекции (0 - не подлежит, 1 - подлежит) */
      /* не заполняются under-round-base;decimal; ->>,>>9.99;база для округления / коэффициент;;0;база для округления / коэффициент для подчиненного ПЛ;560;2;0;;false;false;;;;;;;;;;;; */
      /* не заполняются under-rule;      character;X(8);     Правило подчиненного прайс-листа;;;Правило подчиненного прайс-листа;360;;0;;false;false;;;;;;;;;;1251;RUSSIAN_I; */

      ,1 /* p-send-cassa    like ub.price-list-type.send-cassa (int) Отправлять на кассы (0 - не отправлять, 1 - отправлять) */
      ,0 /* p-use-cassa     like ub.price-list-type.use-cassa Признак распространения по кассам (0 - все кассы, 1 - кассы выборочно) */
      ,0 /* p-use-gds-group like ub.price-list-type.use-gds-group Признак - имеется ограничение по группам товаров (0 - нет ограничения, 1 - есть ограничения) */
      ,0 /* p-work-date     like ub.price-list-type.work-date Признак работы по дате на объекте (0 - работаем по дате на объекте, 1 - сменной дате и номеру смены, 2 - дате и времени сервера) */
      ,0 /* p-curr-code     like ub.price-list-type.curr-code Код валюты; currency.curr-code = 0:рубли создана в начальной раскрутке */
      ,0 /* p-use-cash-pay  like ub.price-list-type.use-cash-pay Признак - имеется ограничение по типам касоового платежа (0 - нет ограничения, 1 - есть ограничения) */
      ,0 /* p-use-pay-type  like ub.price-list-type.use-pay-type Признак - имеется ограничение по типам платежа (0 - нет ограничения, 1 - есть ограничения) */

      ,0        /* p-have-rs-qnty-group  like ub.price-list-type.have-rs-qnty-group Имеет связь с количественной группой (0 - имеет, 1 - не имеет) */
      ,v-db-num /* p-qgr-db-num          like ub.price-list-type.qgr-db-num */
      ,0        /* p-qgr-id              like ub.price-list-type.qgr-id             Код количественной группы */

      ,false    /* p-have-rs-sum-group   like ub.price-list-type.have-rs-sum-group  Имеет связь с суммовой группой */
      ,v-db-num /* p-sgr-db-num          like ub.price-list-type.sgr-db-num */
      ,0        /* p-sgr-id              like ub.price-list-type.sgr-id             Код суммовой группы */

      ,0        /* p-rs-buyer            like ub.price-list-type.rs-buyer           Признак связи с покупателями (0 - все покупатели, 1 - группа покупателей, 2 - суммарный оборот по покупателю) */
      ,v-db-num /* p-bgr-db-num          like ub.price-list-type.bgr-db-num */
      ,0        /* p-bgr-id              like ub.price-list-type.bgr-id             Код группы покупателей */
      /* если p-tog-id = 0 и p-bgr-id = 0 то p-rs-buyer сбрасывается в 0 автоматически */
      
      ,?        /* p-obj-turnover        like ub.price-list-type.obj-turnover (log) Признак объектов для обсчета оборотов (0 - все объекты, 1 - группа объектов для расчета оборотов) */
      ,v-db-num /* p-tog-db-num          like ub.price-list-type.tog-db-num */
      ,0        /* p-tog-id              like ub.price-list-type.tog-id             Код группы оборотов */
      ,v-db-num /* p-ttg-summa           like ub.price-list-type.ttg-summa (dec)    Оборот в группе оборотов */
      /* значение параметра p-ttg-summa не понятно: за что купила - за то продаю */
      /* если p-tog-id = 0 или p-gop-id-for-calc-turnover = 0 то p-obj-turnover сбрасывается в false автоматически */

      ,0        /* p-have-rs-turn-group  like ub.price-list-type.have-rs-turn-group Имеет связь с группой по оборотам (0 - имеет, 1 - не имеет) */
      ,0        /* p-have-tog-db-num     like ub.price-list-type.have-tog-db-num */
      ,0        /* p-have-tog-id         like ub.price-list-type.have-tog-id        Код группы оборотов */

      ,v-db-num /* p-gop-db-num          like ub.price-list-type.gop-db-num */ 
      ,0        /* p-gop-id              like ub.price-list-type.gop-id             Код группы объектов для ценообразования */
      ,2        /* p-use-obj             like ub.price-list-type.use-obj            Признак распространения по объектам (0 - все объекты, 1 - группа объектов) */

      ,v-db-num /* p-gop-db-num-for-calc-turnover like ub.price-list-type.gop-db-num-for-calc-turnover Номер БД для группы объектов по обсчету оборотов */
      ,0        /* p-gop-id-for-calc-turnover     like ub.price-list-type.gop-id-for-calc-turnover     Код группы об. по обсчету оборотов */

      ,gbl-var:g#userid /* p-userid (chr) Кто последний изменял запись */
      ,0                /* p-db-num-usr   База данных, где произошло последнее изменение */
/* не заполяются:
stts;integer;>,>>>,>>9;Статус типа прайс листа;;0;Статус типа прайс листа;270;;0;;false;false;;;;;;;;;;;;
sys-date;date;99/99/99;Физическая дата последнего изменения;;;Физическая дата последнего изменения;490;;0;;false;false;;;;;;;;;;;;
sys-time;integer;->,>>>,>>9;Физическое время последнего изменения;;0;Физическое время последнего изменения;470;;0;;false;false;;;;;;;;;;;;
sys-time-chr;character;X(20);Физическое время последнего изменения(строка);;;Физическое время последнего изменения(строка);480;;0;;false;false;;;;;;;;;;1251;RUSSIAN_I;
*/
      
    ,output v-plt-recid
     ,input table TT_cassa
     ,input table TT_grp
     ,input table TT_pay-type
     ,input table TT_cash-pay
      ) .
    end .
    
    v-retfl = true.
    
    catch exAppErrors as class Progress.Lang.AppError :
      define variable v-is-delim as logical no-undo . /* есть true - то это ошибка из shop01.p в формате "fld{&d}txt" */
      v-is-delim = (num-entries(exAppErrors:ReturnValue, {&delim-par}) > 1) .
      Msg = if v-is-delim then entry(2, exAppErrors:ReturnValue, {&delim-par}) else exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        Msg = exAppErrors:GetMessage(1) .
        if Msg > "" then . else Msg = "AppError в АЗС АЗК" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) . 
      if Msg > "" then . else Msg = "ProError в АЗС АЗК" .
      v-retfl = false.
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в АЗС АЗК" .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      if valid-object(proc-typl-ad) then delete object proc-typl-ad .
      return v-retfl .
    end finally .
  end method. /* end_of Excute */

  /* распределение строки адреса по полям address1, address2 описано в
     пользовательском интерфейсе модуля adm/shopi.w:
       1 строка = address1 [1...]
       2 строка = address2 [1...]
     p.s. там адрес никак не разделяется: просто лежит в двух полях с форматом x(80).
          по факту в каждой строке отображается по 63 символа
  */     
  method private void sliceAddress (input p-address   as character,
                                    input p-curraddr1 as character,
                                    input p-curraddr2 as character, 
                                   output p-addr1     as character,
                                   output p-addr2     as character) :
    if p-address > "" then assign
      /* первые 63 символа для address1 */    
      p-addr1 = substring(p-address,  1, 63)
      /* символы с 64 для address2 */
      p-addr2 = substring(p-address, 64)
    .
    else if p-address = "" then assign
      p-addr1 = ""
      p-addr2 = ""
    .
    else assign
      p-addr1 = p-curraddr1
      p-addr2 = p-curraddr2
    .
  end method .

  method private void thbjattr_get-section (input p-obj-type   as character,
                                            input p-obj-code   as integer,
                                            input p-upper-code as character,
                                            output table-handle p-tth) :
    /* @FUTU перенести сюда вызов adm/shattri.p */                                          
  end method .
  
  method private void thbjattr_set-section (input p-obj-type   as character,
                                            input p-obj-code   as integer,
                                            input p-upper-code as character,
                                            input table-handle p-tth) :
  &scop proc-name thbjattr_set-section
  {&run_proc_attr-lib}
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) .
  end method .


end class.