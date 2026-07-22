/*

$Revision: 608731145d92, 3401, rls $
$Author: DRuban $
$Date: 2023/06/07 13:19:22 $
$Workfile: promo_trg.cls $
$Archive: ibs/th/ref/promo/promo_trg.cls $

Экранные триггеры промо-акций

Автор: Молотков Сергей
Дата создания: 21/06/18
Author: Molotkov Sergey
Creation date: 21/06/18

Состав:
1 вызовы из списка акций:
1.1 получить таблицу акций для отображения в data-grid -> m-storage:getItems()
1.2а вызвать форму ввода и создать одну акцию       -> m-storage:getItem(), insert, update
1.2б вызвать форму ввода и редактировать одну акцию -> m-storage:getItem(), insert, update
1.2в вызвать форму просмотра акции                  -> m-storage:getItem()
2 вызовы из формы добавления/редактирования
    
*/ 
using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.ref.promo.*.
using ibs.th.gbl.sys.objsrv.
block-level on error undo, throw.
&glob promoTrackingChanges no and
class ibs.th.ref.promo.promo_trg :
  { cmp/str-glbl.i class } 
  { gbl/getcntxt.i def }
  { cmp/library.i class}
  { bge/ds-promo.i} 

define temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
    
  //{gbl/userobjs.i}
  define temp-table tt-query
      field NameQuery as character 
      field hQuery    as handle
  index NameQuery NameQuery.    
  /* --- для cmp/vssrevis.i --- */
    define variable vss-revision       as character no-undo init "$Revision: 608731145d92, 3401, rls $":U .
    define variable vss-author         as character no-undo init "$Author: DRuban $":U .
    define variable vss-date           as character no-undo init "$Date: 2023/06/07 13:19:22 $":U .
    define variable vss-workfile       as character no-undo init "$Workfile: promo_trg.cls $":U .
    define variable vss-archive        as character no-undo init "$Archive: ibs/th/ref/promo/promo_trg.cls $":U .
    define variable vss-description    as character no-undo init "Экранные триггеры промо-акций". 
  /* --- end_of для cmp/vssrevis.i --- */
  define variable v-host-code as integer no-undo .
  define variable v-obj-date  as date    no-undo .
  define property parparentproc as handle no-undo
  private get.
  set(input iH as handle):
    parparentproc = iH.
    { gbl/getcntxt.i get }
    { gbl/hostcode.i v-cntxt-obj-type v-cntxt-obj-code v-host-code }
    { gbl/objdtget.i v-cntxt-obj-type v-cntxt-obj-code v-obj-date no-error }
  if error-status:error then
    message substitute( "Ошибка чтения текущей даты на объекте &1&2" ,
                                     v-cntxt-obj-type, v-cntxt-obj-code) view-as alert-box.
    
  end.
    
  define property ModeView as logical no-undo
  get.
  private set.
  define property typeCond as integer no-undo
  get.
  private set.
  define property ModeChangeStatus as logical no-undo
  get.
  private set.
  define property ModeEarlyTermination as logical no-undo
  get.
  private set.
  define property ModeCopy             as logical no-undo
  get.
  private set.
   
  define private variable m-storage as class promoactionstorage no-undo .
  define private variable m-goodsStorage as class promogoodsstorage no-undo . 
  define variable dialog1 as class ibs.th.ref.promo.dPromoActions no-undo .
  define variable CritgoodsFl as logical no-undo .
  define private variable m-local-sec as int64 no-undo init -1.
  
  define temp-table tt-obj no-undo
  field obj-type as character
  field obj-code as integer

  index xpk is primary unique obj-type obj-code
  .

  define private stream OutStr-html.
  
  constructor public promo_trg (  ):
    m-storage = new promoactionstorage () .
  end constructor.

  destructor public promo_trg ( ):
    if valid-object (m-storage) then delete object m-storage no-error.
  end destructor.

/* --- 1 вызовы из списка --- */
/* 1.1 получить таблицу акций для отображения в data-grid */
define variable mDate   as date     no-undo.
define variable mStatus as integer  no-undo.
    method private void getListTable ( 
       //input-output table tt-promoaction bind
    ) :
        getListTable(mDate,mStatus).
    end.
    method public void getListTable (input idate as date, input istatus as integer 
       //input-output table tt-promoaction bind
    ) : 
        assign 
            mDate   = idate
            mStatus = istatus
        .
        define variable v-subs    as class promoActionSubs no-undo .
        define variable v-sub     as class promoactionsub no-undo .
        define variable v-length  as integer no-undo .
        define variable v-i       as integer no-undo .
        define variable v-size    as integer no-undo .
  
        empty temp-table tt-promoaction.
        
        v-subs    =  
        m-storage:getpromoactionsubs(idate,istatus) . // получаем коллекцию из data-storage
        
        // перекладываем коллекцию во временную таблицу
        v-length  = v-subs:iCounter .
        v-subs:IsDelChildObj = no.
        do v-i = 1 to v-length :
            v-size = v-subs:GetItem(v-i) . // переключает SubjectObjCurr на N[v-i] и возвращает количество элементов в коллекции 
            v-sub = v-subs:promoActionObjCurr .
            create tt-promoaction .
            assign
                tt-promoaction.id           = v-sub:ID
                tt-PromoAction.db-num      = v-sub:db-num
                tt-PromoAction.changeDate  = v-sub:changeDate    
                tt-PromoAction.comment     = v-sub:comment
                tt-PromoAction.description = v-sub:description    
                tt-PromoAction.ext-code    = v-sub:ext-code 
                tt-PromoAction.paymenttype = v-sub:paymenttype 
                tt-PromoAction.priority    = v-sub:priority 
                tt-PromoAction.status_     = v-sub:status_
                tt-PromoAction.status_lbl  = v-sub:status_lbl       
                tt-promoaction.beg-date    = v-sub:beg-date
                tt-promoaction.end-date    = v-sub:end-date
                tt-promoaction.methodCalc  = v-sub:methodCalc
                tt-promoaction.mode        = v-sub:Mode
                tt-promoaction.nameAction  = v-sub:nameAction
                tt-promoaction.typecond    = v-sub:typecond
                tt-promoaction.TypeDiscont = v-sub:TypeDiscont
        
                tt-promoaction.sub         = v-subs:SubjectObjCurr
            .
        end.
    // удаляем коллекцию без удаления её элементов:
    //   data-storage использовал конструктор с флагом false на входе для создания коллекции
        delete object v-subs .
    // Все элементы коллекции доступны по ссылке из экранной таблицы
           
    
    end method . // end_of getListTable
  
  method public class promoActionSubs ReturnSubsPromoAction():
      define variable vSubs  as class promoActionSubs  no-undo .
      define variable vSub   as class promoActionSub   no-undo .
      vSubs = new promoActionSubs().
      for each tt-promoaction where tt-promoaction.Chang:
          vsub = cast(tt-promoaction.sub, ibs.th.ref.promo.PromoActionSub) .
          m-storage:refreshObj(vsub).
          vSubs:AddItem(tt-promoaction.sub).
      end.
      return vSubs.
   end.  
   
   method public void changeRow(input iAll as logical):
       define variable vFlag as logical no-undo.
       vFlag = if     available tt-promoaction
                  and tt-promoaction.Chang
               then no
               else yes.
       if iAll 
       then
           for each   tt-promoaction:
               tt-promoaction.Chang = vFlag.
           end.
       else
            if avail tt-promoaction
            then
                tt-promoaction.Chang = vFlag.
               
   end.          

   method public void changeRowAll(input iAll as logical):
       define variable vFlag as logical no-undo.
       vFlag = if     available tt-PromoGoodsAppl
                  and tt-PromoGoodsAppl.Chang
               then no
               else yes.
       if iAll 
       then
           for each   tt-PromoGoodsAppl:
               tt-PromoGoodsAppl.Chang = vFlag.
           end.
       else
            if avail tt-PromoGoodsAppl
            then
                tt-PromoGoodsAppl.Chang = vFlag.
               
   end.     
   
/*  method public class promoGoodsSubs ReturnSubsPromoGoods():                  */
/*      define variable vSubs  as class promoGoodsSubs  no-undo .               */
/*      define variable vSub   as class PromoGoodsSub   no-undo .               */
/*      vSubs = new promoGoodsSubs().                                           */
/*      for each tt-PromoGoodsAppl where tt-PromoGoodsAppl.Chang:               */
/*          vsub = cast(tt-PromoGoodsAppl.sub, ibs.th.ref.promo.PromoGoodsSub) .*/
/*          m-goodsStorage:refreshObj(vsub).                                    */
/*          vSubs:AddItem(tt-PromoGoodsAppl.sub).                               */
/*      end.                                                                    */
/*      return vSubs.                                                           */
/*   end.                                                                       */
   
   method public void ChangBarCode(input iAll as logical):
       define variable vFlag as logical no-undo.
       vFlag = if     available tt-PromoBc
                  and tt-PromoBc.Chang
               then no
               else yes.
       if iAll 
       then
           for each   tt-PromoBc:
               tt-PromoBc.Chang = vFlag.
           end.
       else
            if avail tt-PromoBc
            then
                tt-PromoBc.Chang = vFlag.
               
   end. 
  method public void printPromoActionList () :
  define variable v-report-name       as character no-undo .
  define variable v-file-name-rep-htm as character no-undo .
  define variable v-filt-1            as character no-undo . // фильтр по mDate
  define variable v-filt-2            as character no-undo . // фильтр по mStatus
  define variable v-date-start        as date no-undo . // для имени листа в Excel
  define variable v-page-name         as character no-undo . // имя листа в Excel
  
  // по каждой акции:
  define variable v-PromoActionSub    as class ibs.th.ref.promo.PromoActionSub no-undo .
  define variable v-wdaylist          as character no-undo . // перечень дней недели (пн=1)
  define variable v-wdaysubs          as class promoschedwsubs no-undo . // перечень дней недели (объектами)
  define variable v-sub               as promoschedwsub no-undo . // каждый день недели (объект)
  define variable v-timelist          as character extent 7 no-undo . // перечень времени на каждый день недели
  define variable v-sdaynum           as character no-undo . // номер дня недели (пн=1)
  define variable v-idaynum           as integer no-undo . // номер дня недели (пн=1)

  define variable vi                  as integer no-undo .
  define variable vj                  as integer no-undo .  
  define buffer buf_tt-promoaction for tt-promoaction .


    assign
      v-filt-1 = if mDate   = ? then "" else substitute("с датой окончания от &1", mDate) 
      v-filt-2 = if mStatus = ? then "" else substitute("со статусом &1",          mStatus)
      v-date-start = today
      v-page-name  = substitute(  "exp&1g",  string(day(v-date-start), "99")  )
    .
  
    // 03/VIII-2018 функции для печати временно берём из ibs.th.gbl.gbl-inipar
    v-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name() .
    assign
      v-file-name-rep-htm = v-report-name + ".html"
    .
    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .

do: /* заголовок html-файла и заголовок таблицы */
  put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    '<html>' skip
    '<head>' skip
    '  <meta charset="utf-8">' skip
    '  <style type="text/css">' skip
    '      table ~{border-collapse: collapse~;~}' skip
    '      tbody td, th ~{border: 1px solid black~; height: 14px~;~}' skip
    '      tbody td ~{text-align: center~; padding-left: 4px~;~}' skip
    '  </style>' skip
    '</head>' skip
    '<body>' skip
    substitute('<TABLE name="&1" fit_to_page="true" orientation="portrait" repeat_rows="1:4" outline_below="false">', v-page-name) skip
    '<thead>' skip
    
    /* Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px */
    /* row 1 */
    '  <tr class="set_columns">' skip
    '    <td style="width: 98px;"></td>' skip /* № промо-акции */
    '    <td style="width: 300px;"></td>' skip /* Наименование промо-акции */
    '    <td style="width: 80px;"></td>' skip /* Дата начала */
    '    <td style="width: 80px;"></td>' skip /* Дата окончания */
    '    <td style="width: 50px;"></td>' skip /* пн */
    '    <td style="width: 50px;"></td>' skip /* вт */
    '    <td style="width: 50px;"></td>' skip /* ср */
    '    <td style="width: 50px;"></td>' skip /* чт */
    '    <td style="width: 50px;"></td>' skip /* пт */
    '    <td style="width: 50px;"></td>' skip /* сб */
    '    <td style="width: 50px;"></td>' skip /* вс */
    '  </tr>' skip


    /* Теперь шапка таблицы */
    /* @FUTU добавить вывод текущей даты - дата печети документа - в стандартный колонтитул: дата, место, магазин, время печати */
    /* row 2 */
    '  <tr>' skip
    '    <td colspan="11"></td>' skip
    '  </tr>' skip
    /* row 3 */
    '  <tr>' skip
    '    <td colspan="11">' + v-filt-1 + '<br />' + v-filt-2 + '</td>' skip
    '  </tr>' skip
    '</thead>' skip
    
    /* Здесь начинается таблица отчета */
    '<tbody>' skip
    
    /* Первые строки – шапка табоицы с тэгами th */
    /* row 4 */
    '  <tr>' skip
    '    <th>№ промо-акции</th>' skip
    '    <th>Наименование промо-акции</th>' skip
    '    <th>Дата начала</th>' skip
    '    <th>Дата окончания</th>' skip
    '    <th>пн</th>' skip
    '    <th>вт</th>' skip
    '    <th>ср</th>' skip
    '    <th>чт</th>' skip
    '    <th>пт</th>' skip
    '    <th>сб</th>' skip
    '    <th>вс</th>' skip
    '  </tr>' skip    
  .
end. /* end_of заголовок html-файла и заголовок таблицы */

do : /* перечень акций, равный отображаемому сейчас на экране */
    for each buf_tt-promoaction :
      
      v-wdaylist = "" .
      do vj = 1 to 7 : v-timelist[vj] = "" . end .

      v-PromoActionSub = cast(buf_tt-promoaction.sub, ibs.th.ref.promo.PromoActionSub) .
      // m-storage:refreshObj(v-PromoActionSub).
      v-PromoActionSub:refreshChildObj().   
      v-wdaysubs = v-PromoActionSub:ScheduleWeek .
      
      if valid-object (v-wdaysubs) then do :
        if v-wdaysubs:GetItem(vI) = 1 and v-wdaysubs:promoSchedwObjCurr:wdaylist = "0" then do:
        /* 09/VIII-2018 Расписания может не быть. В этом случае акция действует постоянно.
                        И одновременно мы считаем, что акция, дейтсвующая постоянно - это акция без расписания.
        */
        v-wdaylist = "1,2,3,4,5,6,7" .
        do vj = 1 to 7 :
           v-timelist[vj] ="00:00 - 23:59" .
        end .          
        end.
        else do:
        do vi = 1 to v-wdaysubs:GetItem(vI):
          v-sub = v-wdaysubs:promoSchedwObjCurr .
          // v-sub:wdaylist содержит или один день, или перечень дней через запятую
          v-wdaylist = v-wdaylist + substitute(",&1", v-sub:wdaylist) .
          do vj = 1 to num-entries(v-sub:wdaylist) :
            v-sdaynum = entry(vj, v-sub:wdaylist) .
            v-idaynum = integer(v-sdaynum) no-error .
            if v-idaynum > 0 then assign
              v-timelist[v-idaynum] = v-timelist[v-idaynum] +
                substitute(  ",<br />&1 - &2",  string(v-sub:timebeg, "hh:mm"),  string(v-sub:timeend, "hh:mm")  )
            .
          end .
        end .
        v-wdaylist = substring(v-wdaylist, 2) .
        do vj = 1 to 7 :
           v-timelist[vj] = substring(v-timelist[vj], 8) .
        end .
      end . // end_of_wdaysubs
      end .
      
      put stream OutStr-html unformatted
        '  <tr>'
        '<td rowspan="2">' buf_tt-promoaction.ext-code '</td>'
        '<td rowspan="2">' buf_tt-promoaction.nameAction '</td>'
        '<td rowspan="2">' string(buf_tt-promoaction.beg-date, "99.99.99") '</td>'
        '<td rowspan="2">' string(buf_tt-promoaction.end-date, "99.99.99") '</td>'
        
        '<td>' (if can-do(v-wdaylist, "1") then '+' else '-') '</td>'
        '<td>' (if can-do(v-wdaylist, "2") then '+' else '-') '</td>'
        '<td>' (if can-do(v-wdaylist, "3") then '+' else '-') '</td>'
        '<td>' (if can-do(v-wdaylist, "4") then '+' else '-') '</td>'
        '<td>' (if can-do(v-wdaylist, "5") then '+' else '-') '</td>'
        '<td>' (if can-do(v-wdaylist, "6") then '+' else '-') '</td>'
        '<td>' (if can-do(v-wdaylist, "7") then '+' else '-') '</td>'
        '  </tr><tr>' skip
        '<td>' v-timelist[1] '</td>'
        '<td>' v-timelist[2] '</td>'
        '<td>' v-timelist[3] '</td>'
        '<td>' v-timelist[4] '</td>'
        '<td>' v-timelist[5] '</td>'
        '<td>' v-timelist[6] '</td>'
        '<td>' v-timelist[7] '</td>'
        '  </tr>' skip
      .
    end . // end_of for_each_buf_tt-promoaction
end . /* end_of перечень акций */

do : /* низ таблицы и html-файла */ 
  put stream OutStr-html unformatted
    '</tbody>' skip
    '<tfoot>' skip
  .
  put stream OutStr-html unformatted
    '</tfoot>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
  .
  output stream OutStr-html close.     
end . /* end_of низ таблицы и html-файла */

  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(v-file-name-rep-htm,"") .
  end method .
  method public logical getChangeBL ():
    return tt-promoaction-one.changeBL .
  end.
/* 1.2 запустить браузер с перечнем акций */
    method public handle getQuery (input iNameQuery as character ) :
        return getQuery(iNameQuery,no).
    end.
    method public handle getQuery (input iNameQuery as character,input iNewQuery as logical ) :
        define variable hQuery   as handle  no-undo .
        define variable vfirst   as logical no-undo .
        define variable vTblName as character no-undo .
        define variable vOpenStr as character no-undo .
        define variable vSchedId as integer no-undo .
/* 26/VII-2018 - не используется        
        if iNameQuery eq "promo-schedule" 
        then
            hQuery = dataset ds-promoaction-one:get-buffer-handle ( "tt-promo-schedule" ).
        /*else if iNameQuery eq "promoActionOne" //так как нам надо две разные ссылки на запрос мы не можем использовать буфер
        then
            hQuery = buffer tt-promoaction-one:handle.*/
        else do:
*/  
  
            find first tt-Query where tt-Query.NameQuery eq iNameQuery
            no-error.
            if     available tt-Query
               and iNewQuery
            then do:
               delete object tt-Query.hQuery.
               delete tt-Query.
            end.      
            if not available tt-Query
            then 
            do: 
                create query hQuery.    
                case iNameQuery:
                    when "promoActionStatus"
                    then do:
                        hQuery:set-buffers(buffer tt-promoaction:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-promoaction where tt-promoaction.status_ = 1").
                    end.
                    when "promoActionAll"
                    then do:
                        hQuery:set-buffers(buffer tt-promoaction:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-promoaction").
                    end.
                    when "promoActionOne"
                    or
                    when "promoActionOne2" 
                    or 
                    when "promoActionOne3"
                    or 
                    when "promoActionOne4"
                    then do:
                        
                        hQuery:set-buffers(buffer tt-promoaction-one:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-promoaction-one").
                        vfirst = yes.
                    end.
                    when "PromoGoodsAppl" 
                    then do:
                        hQuery:set-buffers(buffer tt-PromoGoodsAppl:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-PromoGoodsAppl " + if not available tt-promoaction-one then "" else (
                                                 "where tt-PromoGoodsAppl.idaction eq " + string(tt-promoaction-one.id)  +
                                                 "  and tt-PromoGoodsAppl.mode ne {&h-delete}"
                                             )).
                    end.
                    when "PromoGoodsApplFix" 
                    then do:
                        hQuery:set-buffers(buffer tt-PromoGoodsAppl:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-PromoGoodsAppl " + if not available tt-promoaction-one then "" else (
                                                 "where tt-PromoGoodsAppl.idaction eq " + string(tt-promoaction-one.id)  +
                                                 "  and tt-PromoGoodsAppl.mode ne {&h-delete}"
                                             )).
                    end.                    
                    when "PromoGoodsFix" 
                    then do:
                        hQuery:set-buffers(buffer tt-PromoGoodsAppl:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-PromoGoodsAppl " + if not available tt-promoaction-one then "" else (
                                                 "where tt-PromoGoodsAppl.idaction eq " + string(tt-promoaction-one.id)  +
                                                 "  and tt-PromoGoodsAppl.mode ne {&h-delete}"
                                             )).
                    end.     
                    when "PromoCardsBin" 
                    then do:
                        hQuery:set-buffers(buffer tt-PromoCardsBin:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-PromoCardsBin " + if not available tt-promoaction-one then "" else (
                                                 "where tt-PromoCardsBin.idaction eq " + string(tt-promoaction-one.id)  +
                                                 "  and tt-PromoCardsBin.mode ne {&h-delete}"
                                             )). 
                    end.
                    when "PromoBarCode" 
                    then do:
                        hQuery:set-buffers(buffer tt-PromoBc:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-PromoBC " + if not available tt-promoaction-one then "" else (
                                                 "where tt-PromoBC.idaction eq " + string(tt-promoaction-one.id)  +
                                                 "  and tt-PromoBC.mode ne {&h-delete}"
                                             )). 
                    end.                    
                    when "PromoGoodsCrit" 
                    then do:
                        hQuery:set-buffers(buffer tt-PromoGoodsCrite:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-PromoGoodsCrite " + if not available tt-promoaction-one then "" else ( 
                                                 "where tt-PromoGoodsCrite.idaction eq " + string(tt-promoaction-one.id)  +
                                                 "  and tt-PromoGoodsCrite.mode     ne {&h-delete}")).
                    end.
                    when "PromoSet" 
                    then do:
                        hQuery:set-buffers(buffer tt-PromoSet:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-PromoSet "  +  if not available tt-promoaction-one then "" else (
                                                 "where tt-PromoSet.idaction eq " + string(tt-promoaction-one.id) + 
                                                 "  and tt-PromoSet.mode     ne {&h-delete}" 
                                             )).
                    end.
                    when "PromoSetGoods" 
                    then do:
                        hQuery:set-buffers(buffer tt-PromoSetGoods:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-PromoSetGoods " + if not available tt-PromoSet then "" else ( 
                                                 "where tt-PromoSetGoods.idaction eq " + string(tt-PromoSet.idAction) +
                                                 "  and tt-PromoSetGoods.idset    eq " + string(tt-PromoSet.id) +
                                                 "  and tt-PromoSetGoods.mode     ne {&h-delete}"
                                            )).
                    end.
                    when "PromoCriterion" 
                    then do:
                        hQuery:set-buffers(buffer tt-PromoCriterion:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-PromoCriterion " + if not available tt-promoaction-one then "" else (
                                                 "where tt-PromoCriterion.idaction eq " + string(tt-promoaction-one.id) +
                                                 "  and tt-PromoCriterion.mode     ne {&h-delete}")).
                    end.
                    when "PromoObject" 
                    then do:
                        hQuery:set-buffers(buffer tt-PromoObject:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-PromoObject " + if not available tt-promoaction-one then "" else (
                                                 "where tt-PromoObject.idaction eq " + string(tt-promoaction-one.id) +
                                                 "  and tt-PromoObject.mode     ne {&h-delete}")).
                    end.
                    when "PromoPay" 
                    then do:
                        hQuery:set-buffers(buffer tt-CashPay:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-CashPay ").
                    end.
                    when "PromoCriterionOne" 
                    then do:
                        
                        for each tt-PromoCriterion where tt-PromoCriterion.mode eq {&h-update} :
                            if vFirst 
                            then
                              . // tt-PromoCriterion.mode = {&h-delete}.
                            else
                                vFirst = yes.
                        end.
                        for each tt-PromoCriterion where tt-PromoCriterion.mode eq {&h-create} :
                            if vFirst 
                            then
                       .  //       delete tt-PromoCriterion.  удалять нельзя мешает копированию
                            else
                                vFirst = yes.
                        end.
                        if not vFirst
                        then do:
                            create tt-PromoCriterion.
                            assign
                                vFirst                     = yes
                                tt-PromoCriterion.mode     = {&h-create}
                                tt-PromoCriterion.idAction = tt-promoaction-one.id
                                tt-PromoCriterion.id       = m-local-sec
                                m-local-sec                = m-local-sec - 1
                            .
                                  
                        end.
                        /*message tt-PromoCriterion.idAction "tt-PromoCriterion.idAction"
                           view-as alert-box.*/        
                        hQuery:set-buffers(buffer tt-PromoCriterion:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-PromoCriterion " + if not available tt-promoaction-one then "" else (
                                                 "where tt-PromoCriterion.idaction eq " + string(tt-promoaction-one.id) +
                                                 "  and tt-PromoCriterion.mode     ne {&h-delete}")).
                        
                    end.
                    when "PromoGiftForAction" 
                    then do: 
                        hQuery:set-buffers(buffer tt-PromoGift:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-PromoGift " + (if not available tt-promoaction-one then "where true " else (
                                                 "where tt-PromoGift.idaction eq " + string(tt-promoaction-one.id) )) +
                                                 "  and tt-PromoGift.idCrit   eq 0 "  +
                                                 "  and tt-PromoGift.GDS-CODE NE 0" +
                                                 "  and tt-PromoGift.mode     ne {&h-delete}"
                                            ).
                    end.
                    when "PromoMes" 
                    then do: 
                        vFirst = yes.
                        if     available tt-PromoCriterion 
                           and not can-find( first tt-PromoGift  where tt-PromoGift.idaction eq tt-PromoCriterion.idaction 
                                                   and tt-PromoGift.idCrit   eq tt-PromoCriterion.id   
                                                   and tt-PromoGift.mode     ne {&h-delete})
                        then do:
                            create tt-PromoGift.
                            assign 
                            tt-PromoGift.idCrit   = tt-PromoCriterion.id
                            tt-PromoGift.idaction = tt-PromoCriterion.idaction
                            tt-PromoGift.mode     = {&h-create}
                            tt-PromoGift.id       = m-local-sec
                            m-local-sec           = m-local-sec - 1.
                            
                        end.  
                        hQuery:set-buffers(buffer tt-PromoGift:HANDLE). 
                        hQuery:query-prepare("FOR each tt-PromoGift " + if not available tt-promoaction-one then "" else (
                                                 "where tt-PromoGift.idaction eq " + string(tt-PromoCriterion.idaction) +
                                                 "  and tt-PromoGift.idCrit   eq " + string(tt-PromoCriterion.id)       +
                                                 "  and tt-PromoGift.mode     ne {&h-delete}"
                                            )).
                    end.
                    when "PromoMes1" 
                    then do: 
                        vFirst = yes.
                        if     available tt-PromoCriterion 
                           and not can-find( first tt-PromoGift  where tt-PromoGift.idaction eq tt-PromoCriterion.idaction 
                                                   and tt-PromoGift.idCrit   eq tt-PromoCriterion.id   
                                                   and tt-PromoGift.mode     ne {&h-delete})
                        then do:
                            create tt-PromoGift.
                            assign 
                            tt-PromoGift.idCrit   = tt-PromoCriterion.id
                            tt-PromoGift.idaction = tt-PromoCriterion.idaction
                            tt-PromoGift.mode     = {&h-create}
                            tt-PromoGift.id       = m-local-sec
                            m-local-sec           = m-local-sec - 1.
                            
                        end.  
                        hQuery:set-buffers(buffer tt-PromoGift:HANDLE). 
                        hQuery:query-prepare("FOR each tt-PromoGift " + if not available tt-promoaction-one then "" else (
                                                 "where tt-PromoGift.idaction eq " + string(tt-PromoCriterion.idaction) +
                                                 "  and tt-PromoGift.idCrit   eq " + string(tt-PromoCriterion.id)       +
                                                 "  and tt-PromoGift.mode     ne {&h-delete}"
                                            )).
                    end.
                    when "PromoGiftForCrit" 
                    then do: 
                        hQuery:set-buffers(buffer tt-PromoGift:HANDLE). 
                        hQuery:query-prepare("FOR EACH tt-PromoGift " + (if not available tt-PromoCriterion then "where true" else (
                                                 "where tt-PromoGift.idaction eq " + string(tt-PromoCriterion.idAction) +
                                                 "  and tt-PromoGift.idCrit   eq " + string(tt-PromoCriterion.id) )) +
                                                 "  and tt-PromoGift.idCrit   ne 0 "  +
                                                 "  and tt-PromoGift.GDS-CODE NE 0" +
                                                 "  and tt-PromoGift.mode     ne {&h-delete}"
                                            ).
                    end.
                    when "promoSchedWeek" 
                    then do:
                        vTblName = "tt-promo-schedule-week" .
                        hQuery:set-buffers(buffer tt-promo-schedule-week:HANDLE).
                        // 26/VII-2018 - tt-promoaction-one должен быть всегда available
                        // 27/VII-2018 - если на available tt-promoaction-one - то хотябы available tt-promoaction
                        case true:
                          when available tt-promoaction-one then vSchedId = tt-promoaction-one.promosched-id .
                          when available tt-promoaction     then vSchedId = tt-promoaction.promosched-id .
                                                       otherwise vSchedId = 0 .
                        end case .
                        vOpenStr = substitute (
                          "PRESELECT EACH &1 where &1.promosched-id = &2 and &1.mode ne '&3'"
                          , vTblName, vSchedId, {&h-delete}
                        ) .
                        hQuery:query-prepare(vOpenStr).
                        vfirst = yes.
                    end.
                    when "promoSchedWeek2" 
                    then do:
                        vTblName = "tt-promo-schedule-week2" .
                        hQuery:set-buffers(buffer tt-promo-schedule-week2:HANDLE).
                        case true:
                          when available tt-promoaction-one then vSchedId = tt-promoaction-one.promosched-id .
                          when available tt-promoaction     then vSchedId = tt-promoaction.promosched-id .
                                                       otherwise vSchedId = 0 .
                        end case .
                        vOpenStr = substitute (
                          "PRESELECT EACH &1 where &1.promosched-id = &2 and &1.mode ne '&3'"
                          , vTblName, vSchedId, {&h-delete}
                        ) .
                        hQuery:query-prepare(vOpenStr).
                        vfirst = yes.
                    end.
                    when "promoSchedWeek3" then do :
                        case true:
                          when available tt-promoaction-one then vSchedId = tt-promoaction-one.promosched-id .
                          when available tt-promoaction     then vSchedId = tt-promoaction.promosched-id .
                                                       otherwise vSchedId = 0 .
                        end case .
                        if not can-find (first tt-promo-schedule-week3) then do :
                          create tt-promo-schedule-week3 .
                          assign
                            tt-promo-schedule-week3.promosched-id = vSchedId
                          .
                        end .
                        vTblName = "tt-promo-schedule-week3" .
                        hQuery:set-buffers(buffer tt-promo-schedule-week3:HANDLE).
                        vOpenStr = substitute (
                          "PRESELECT EACH &1 where &1.promosched-id = &2 and &1.mode ne '&3'"
                          , vTblName, vSchedId, {&h-delete}
                        ) .
                        hQuery:query-prepare(vOpenStr).
                        vfirst = yes.
                    end .
                    
                end case.
                if available (tt-promoaction) then typeCond = tt-promoaction.typecond .
    
                hQuery:query-open.

                if vFirst 
                then
                    hQuery:get-first () no-error .
                create tt-Query.
                assign
                    tt-Query.NameQuery = iNameQuery
                    tt-Query.hQuery    = hQuery
                .         
            end.
            else
               hQuery = tt-Query.hQuery.
               
            
/* 26/VII-2018 не используется       end.*/
     
        return hQuery.
    end.
    method public handle CleanQuery (input iNoCleanNameQuery as character ) :
        for each tt-Query where not can-do(iNoCleanNameQuery,tt-Query.nameQuery):
            tt-Query.hQuery:query-close ().
            delete object tt-Query.hQuery.
            delete tt-Query.
        end.  
    end.
    
    method Public VOID PublicEventForForm (input iEvent as character, input iEventParam as character   ):
        dialog1:PublicEvent(iEvent, iEventParam).
    end.     
    
    method public void viewpage6 (input iFlag as logical) :
        dialog1:viewpage6(iFlag).
    end.        
  method public void BrwPromoAction () :
      
    define variable v-listact-brw as class ibs.th.ref.promo.wListActions no-undo .
  v-listact-brw = new ibs.th.ref.promo.wListActions (input this-object
  //, input table tt-promoaction by-reference 
  ). 
      /* v-listact-brw:SetPromoBind(input table tt-promoaction by-reference
       )
       .*/.
 //  v-listact-brw:SetPromoTrg(this-object ).
  /* Display and wait for this non-modal form to close. */
  wait-for System.Windows.Forms.Application:Run ( v-listact-brw ) .
  
  /*define variable v-err-msg as character no-undo .  
  catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
      v-err-msg = exAppErrors:GetMessage(1) . 
      if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
    end .
    message "AppError" skip(1) v-err-msg skip exAppErrors:CallStack view-as alert-box.
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) . 
    if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
    message "ProError" skip(1) v-err-msg skip exProErrors:CallStack view-as alert-box.
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
    message "LangError" skip(1) v-err-msg skip exAnyErrors:CallStack view-as alert-box.
  end catch .*/
  finally: 
    if valid-object(v-listact-brw) then delete object v-listact-brw no-error .
  end finally.  
    
  end method .
   
/* 1.3а вызвать форму ввода и создать одну акцию */
/* 1.3б вызвать форму ввода и редактировать одну акцию */
/* 1.3в вызвать форму просмотра акции */
  method public void copyOnePromo () :
    /* буффер tt-promoaction спозиционирован на текущей записи,
       буффер buf_tt-promoaction неспозиционирован */
    this-object:ModeCopy = yes.   
    formOnePromo ({&add-def}) .
    getListTable().
  end method .
  method public void addOnePromo () :
    /* буффер tt-promoaction спозиционирован на текущей записи,
       буффер buf_tt-promoaction неспозиционирован */
    formOnePromo ({&add-def}) .
    getListTable().
  end method .
  method public void viewOnePromo () :
    ModeView = yes.
    formOnePromo ({&lookup}) .
  end method .
  method public void editOnePromo () :
    define variable vFlag as logical no-undo.
    
    { gbl/chk-actg.i
    ibs.th.gbl.gbl-var:g#db-num
    ibs.th.gbl.gbl-var:g#userid
    {&action-head-code-main}
    'actn_action-edit_firm':U
    {&cntxt-firm}
    v-host-code
    '':U
    0
    0
    0
    0
    true
    vFlag
  }
  if     vFlag
     and available tt-promoaction 
  then do:
    if refPromoMark() then        message "Правила акции нарушают закон о маркировке продукции. Редактирование не возможно." 
       view-as alert-box.
    else do: 
    refOnePromo().
    if  v-obj-date > tt-promoaction.end-date
    then
       message "Акция завершена. Редактирование не возможно" 
    
       view-as alert-box.
    else if     tt-promoaction.status_ eq 2
    then
       message "Редактирование не возможно" 
    
       view-as alert-box.
    else do:
      if tt-promoaction.status_ eq 1
      then do:     
    
        if     v-obj-date ne ?
           and v-obj-date >= tt-promoaction.beg-date
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_action-edit_firm':U
            {&cntxt-firm}
            v-host-code
            '':U
            0
            0
            0
            0
            true
            vFlag
          }
          if vFlag 
          then do:
             assign
               this-object:ModeView = yes
               this-object:ModeEarlyTermination = yes
             .
             formOnePromo ({&update}) .
           end.
         end.
         else 
           message "Редактирование не возможно" 
              view-as alert-box.  
      end.
      else      
         formOnePromo ({&update}) .
    end.
    end.
  end.  
  end method .
  method public void editOnePromoStatus () :
    define variable vFlag as logical no-undo.
    
    { gbl/chk-actg.i
    ibs.th.gbl.gbl-var:g#db-num
    ibs.th.gbl.gbl-var:g#userid
    {&action-head-code-main}
    'actn_action-end_firm':U
    {&cntxt-firm}
    v-host-code
    '':U
    0
    0
    0
    0
    true
    vFlag
    }
    if vFlag 
    then do:
       this-object:ModeView = yes.
       this-object:ModeChangeStatus = yes.
       formOnePromo ({&update}) .
    end.  
  end method .
   method public void DelOnePromo () :
    define variable vFlag as logical no-undo.
    define variable v-sub   as class promoActionsub no-undo .
    
    
    { gbl/chk-actg.i
    ibs.th.gbl.gbl-var:g#db-num
    ibs.th.gbl.gbl-var:g#userid
    {&action-head-code-main}
    'actn_action-edit_firm':U
    {&cntxt-firm}
    v-host-code
    '':U
    0
    0
    0
    0
    true
    vFlag
  }
  if     vFlag 
     and available tt-PromoAction
  then do:
    refOnePromo().
    if tt-PromoAction.status_ ne 0
    then
       message "Удалять акции можно только в статусе настройка" 
       view-as alert-box.
    else do:   
      v-sub = cast(tt-PromoAction.sub, promoActionSub) .
      
      message
         "Вы точно точно хотите удалить акцию "  v-sub:NameAction "?"
      view-as alert-box question buttons OK-Cancel update vFlag.
      if vFlag 
      then do:
         v-sub:Mode = {&h-delete}.
         m-storage:deleteDB(v-sub) .
         getListTable().
      end.   
    end.
  end.  
  end method .
  method private void refOnePromo ():
    define variable v-sub   as class promoActionsub no-undo .
    v-sub = cast(tt-promoaction.sub, ibs.th.ref.promo.PromoActionSub) .
    m-storage:refreshObj(v-sub).
    assign
       tt-promoaction.id          = v-sub:ID
       tt-PromoAction.db-num      = v-sub:db-num
       tt-PromoAction.changeDate  = v-sub:changeDate    
       tt-PromoAction.comment     = v-sub:comment
       tt-PromoAction.description = v-sub:description    
       tt-PromoAction.ext-code    = v-sub:ext-code 
       tt-PromoAction.paymenttype = v-sub:paymenttype 
       tt-PromoAction.priority    = v-sub:priority 
       tt-PromoAction.status_     = v-sub:status_
       tt-PromoAction.status_lbl  = v-sub:status_lbl       
       tt-promoaction.beg-date    = v-sub:beg-date
       tt-promoaction.end-date    = v-sub:end-date
       tt-promoaction.methodCalc  = v-sub:methodCalc
       tt-promoaction.mode        = v-sub:Mode
       tt-promoaction.nameAction  = v-sub:nameAction
       tt-promoaction.typecond    = v-sub:typecond
       tt-promoaction.TypeDiscont = v-sub:TypeDiscont
        
     .
  end.  
  method public void formOnePromo (input  p-mode as character) :  
  
  define variable v-sub   as class promoActionsub no-undo .
      dataset ds-promoaction-one:empty-dataset ( ) .   

      if (  p-mode eq {&add-def}
         or p-mode eq {&update} )
         and  chek1CERP ()
      then
         undo, throw new Progress.Lang.AppError("Создание/изменение акций невозможно при интеграции с 1С-ERP") .
     if p-mode = {&update} and refPromoMark() then
        undo, throw new Progress.Lang.AppError("Создание/изменение акции невозможно. Правила акции нарушают закон о маркировке продукции.") .
      // вызвать в storage создание экземпляра класса sub и его заполнение или инициализацию
      if p-mode eq {&add-def} and not modecopy then do:
         v-sub = new promoActionsub().
         v-sub:refreshChildObj(). 
         end.
      else do:
        if available tt-promoaction then do:
          if p-mode eq {&update} and tt-promoaction.ext-code ne "" then
            undo, throw new Progress.Lang.AppError("Акция заведена во внешней системе. Редактирование запрещено.") .
          refOnePromo().
           
          v-sub = cast(tt-promoaction.sub, ibs.th.ref.promo.PromoActionSub) .
          
           if modecopy
              then 
           do:
              v-sub = this-object:m-storage:CopyObject(v-sub).
              if refPromoMark() then
                 undo, throw new Progress.Lang.AppError("Создание/изменение акции невозможно. Правила акции нарушают закон о маркировке продукции.") .
           end.   
          else 
             v-sub:refreshChildObj().    
        end .
        else do:
          undo, throw new Progress.Lang.AppError("отсутствует промоакция для отображения в форме ввода") .
        end .
      end .
      
          
      // перелить этот класс в таблицы редактируемого dataset
      createDsForAction(p-mode, v-sub).
      find first tt-promoaction-one no-error.
      if not available tt-promoaction-one then
        undo, throw new Progress.Lang.AppError("отсутствует набор данных для формы ввода") .
      
      
      //if ModeView then p-mode = {&lookup}. 
      do trans:
         dialog1 = new ibs.th.ref.promo.dPromoActions(p-mode, this-object).
         dialog1:viewpage6(tt-promoaction-one.methodCalc ne 7 and not tt-PromoAction-one.TypeDiscontvisa).
         dialog1:prepareobj(). //input-output dataset ds-promoaction-one by-reference) .
      
      // для просмотра убрать кнопку "Ок", написать гашение полей, сравнить активность полей для создания и для редактирования
         dialog1:ShowModalDialog().
         if dialog1:DialogResult = System.Windows.Forms.DialogResult:Ok then do:
        // изменённый dataset с описанием акции из v-dialog1 хранится тут;  
        // перенести значение из таблиц DataSet'а в классы описания акции
           if p-mode ne {&lookup}
           then
              updateObjForAction(). // - обновляет класс в tt-PromoAction-one.sub
        // и передать класс(ы) в storage на insert-row, и затем на update-row
              v-sub = cast(tt-PromoAction-one.sub, promoActionSub) .
        
        /*if v-sub:Changed then*/ do:
            if v-sub:ID > 0 then m-storage:updateDB(v-sub) .
                            else m-storage:insertDB(v-sub) .
         end .
         if p-mode ne {&add-def}
         then
            refOnePromo().
      end .
      if p-mode eq {&add-def}
      then
         delete object v-sub.
   end.
  return.   
  define variable v-err-msg as character no-undo .  
  catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
      v-err-msg = exAppErrors:GetMessage(1) .
      if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
    end .
    message v-err-msg view-as alert-box.
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) . 
    if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
    message "ProError" skip(1) v-err-msg skip exProErrors:CallStack view-as alert-box.
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
    message "LangError" skip(1) v-err-msg skip exAnyErrors:CallStack view-as alert-box.
  end catch .
  finally:
      // оставлять диалог пока не получается: при повторном запуске указатель валидный, но сам объект disposed
      this-object:ModeView         = no.
      this-object:ModeChangeStatus = no.
      this-object:ModeEarlyTermination = no.
      this-object:modecopy             = no.
      CleanQuery("promoActionAll,promoActionStatus").
      if valid-object(dialog1) then delete object dialog1 .
      
    end finally .
  end method. // end_of getOnePromo
  
  method public void histOnePromo () :
  define variable v-rid-list as character no-undo.
  
    if available tt-promoaction then do:
      run ref/cpromo.w (
                    input '':U /*bttns*/
                   ,input 'one':U /*p-mode*/
                   ,input /* X_wth-place.obj-type */ ''
                   ,input /* X_wth-place.obj-code */ 0
                   ,INPUT tt-promoaction.id
                   ,INPUT-OUTPUT v-rid-list) .
    end .
    else
      undo, throw new Progress.Lang.AppError("отсутствует промоакция для отображения истории") .
      
  end method . // end_of_histOnePromo
    
    
/* --- 2 вызовы из формы добавления/редактирования --- */

/* 2.1 перенести объект m-sub в temp-table */
  method public void CreateDsForAction
  ( input  p-mode as character
  , input  p-sub  as class promoactionsub
  ) :
    define variable v-sched-sub as class promoSchedSub no-undo .
    define variable vi          as integer  no-undo.
    define variable vSurr       as character no-undo.
    define buffer buf_cashpay for cash-pay.
    m-local-sec          = m-local-sec - 1.
    // для режима добавления включить tracking-changes на время инициализации полей
    // для режима редактирования - включить после инициализации   
    //if p-mode = {&add-def} then temp-table tt-promoaction-one:tracking-changes = true .
    create tt-promoaction-one.
    assign 
       tt-PromoAction-one.id             = p-sub:ID
       tt-PromoAction-one.db-num         = p-sub:db-num
       tt-PromoAction-one.changeDate     = p-sub:changeDate
       tt-PromoAction-one.ChangDateFl    = tt-PromoAction-one.changeDate ne ?
       tt-PromoAction-one.comment        = p-sub:comment
       tt-PromoAction-one.description    = p-sub:description    
       tt-PromoAction-one.ext-code       = p-sub:ext-code 
       tt-PromoAction-one.paymenttype    = p-sub:paymenttype 
       tt-PromoAction-one.priority       = p-sub:priority 
       tt-PromoAction-one.beg-date       = p-sub:beg-date
       tt-PromoAction-one.end-date       = p-sub:end-date
       tt-PromoAction-one.methodCalclbl  = p-sub:methodCalclbl
       tt-PromoAction-one.methodCalc     = p-sub:methodCalc // для отовбражения закладки подарков
       /* 1. при чтении из БД поле p-sub:Mode пустое: оно зависит от режима запуска формы ввода
          2. форма ввода запускается в режимах &add-def, &lookup и &update;
             экземпляр класса различает режимы &h-create, &h-update, &h-delete
          3. ещё круче: режим запуска формы работает только для формы;
             режим сохранения записи по умолчанию = &h-update, а остальные режимы
             прописываются принудительно при добавлении или удалении сущности. 
       */ 
       // tt-PromoAction-one.mode           = modeForm2Fun (p-mode)
       
       tt-PromoAction-one.nameAction     = p-sub:NameAction
       tt-PromoAction-one.promosched-id  = p-sub:promosched-id
       tt-PromoAction-one.typecondlbl    = p-sub:typecondLbl
       tt-PromoAction-one.status_lbl     = p-sub:status_lbl
       tt-PromoAction-one.TypeDiscontSolo = if p-sub:TypeDiscont eq 1 then true else false
       tt-PromoAction-one.TypeDiscontCombo = if p-sub:TypeDiscont eq 2 then true else false
       tt-PromoAction-one.TypeDiscontvisa = if p-sub:TypeDiscont eq 3 then true else false
       
       
       tt-PromoAction-one.sub            = cast(p-sub,Progress.Lang.Object)
    no-error.

      define buffer buf_PromoAttr for ub.PromoAttr .
    find first buf_promoAttr where
      buf_promoAttr.attr-code = "charge-BL" and
      buf_promoAttr.tablename = "PromoPay" and
      tt-promoaction-one.id = int64(entry(1,buf_PromoAttr.p-key,{&delim-key})) and 
      tt-promoaction-one.db-num = integer(entry(2,buf_PromoAttr.p-key,{&delim-key})) 
      no-error.     
      if available (buf_PromoAttr) then tt-promoaction-one.changeBL = logical (buf_PromoAttr.attr-value) . 
      else tt-promoaction-one.changeBL = false .


    if p-mode = {&add-def} then tt-PromoAction-one.mode = {&h-create}.
    v-sched-sub = p-sub:Schedule .
    if valid-object(v-sched-sub) then do:
      assign
       tt-PromoAction-one.scheduleName   = v-sched-sub:dispname
       tt-PromoAction-one.extCodeSched   = v-sched-sub:extCodeSched
      no-error.
      if p-mode = {&add-def} 
        then do:
          v-sched-sub:id = m-local-sec.
          v-sched-sub:mode          = {&h-create}.
          
        end.
    end .
    else do:
       v-sched-sub = new promoSchedSub ().
       assign
         v-sched-sub:schedType = 0
         v-sched-sub:Mode      = {&h-create}
       .
       p-sub:Schedule = v-sched-sub .
    end .
    assign
      tt-PromoAction-one.scheduleType   = (v-sched-sub:schedType > 0)
    .
    if v-sched-sub:schedType = 0 then CreateTableForSchedw0 (p-mode, p-sub:ScheduleWeek).
                                 else CreateTableForSchedw1 (p-mode, p-sub:ScheduleWeek).
     //if p-mode = {&update} then temp-table tt-promoaction-one:tracking-changes = true .
     CritgoodsFl = p-sub:CritgoodsFl .
     CreateTableForGoodsCrits(p-mode, p-sub:GoodsCrits).
     CreateTableForGoodsAppl (p-mode, p-sub:GoodsAppl ).
     CreateTableForCardsBin  (p-mode, p-sub:CardsBin ).
     CreateTableForBarCode   (p-mode, p-sub:GoodsAppl ).
     CreateTableForPromoSet  (p-mode, p-sub:PromoSet ).
     CreateTableForCrite     (p-mode, p-sub:Criterion ).
     CreateTableForGift      (p-mode, p-sub:Gifts     ).
     CreateTableForObject    (p-mode, p-sub:Objects     ).
     //find first tt-PromoGoodsCrite no-error.
     tt-PromoAction-one.CritgoodsFl = p-sub:CritgoodsFl.   //available tt-PromoGoodsCrite.
     find first tt-PromoGift where tt-PromoGift.gds-code ne 0 and tt-PromoGift.idCrit ne 0 no-error.
     tt-PromoAction-one.simpGiftFl = not available tt-PromoGift.
      do vi = 1 to num-entries(tt-PromoAction-one.paymenttype,{&delim-par}):
         vSurr = entry(vi,tt-PromoAction-one.paymenttype,{&delim-par}).
         find first Buf_cashpay where Buf_cashpay.cdpay-code = integer (entry(1,vSurr,{&delim-key}))
                                  and Buf_cashpay.curr-code  = integer (entry(2,vSurr,{&delim-key}))
         no-lock no-error.
         if available Buf_cashpay
         then do:
             find first tt-cashpay where tt-cashpay.cdpay-code = Buf_cashpay.cdpay-code 
                                     and tt-cashpay.curr-code  = Buf_cashpay.curr-code  
             no-lock no-error.
             if not available tt-cashpay
             then do:
                 create tt-cashpay.
                 buffer-copy Buf_cashpay to tt-cashpay.
             end.
         end.
     end.
     m-local-sec          = m-local-sec - 1.
  end method. // end_of_CreateDsForAction
  
  method public void CreateTableForGoodsCrits
  ( input  p-mode as character
  , input  p-subs  as class promogoodssubs
  ) :
    define variable vI as int no-undo.
    define variable p-sub as class promogoodssub no-undo.
    //if p-mode = {&add-def} then temp-table tt-PromoGoodsCrite:tracking-changes = true . 
    do vi = 1 to p-subs:GetItem(vI):
        p-sub = p-subs:promoGoodsObjCurr.  
        create tt-PromoGoodsCrite.
        assign
           tt-PromoGoodsCrite.id             = p-sub:ID
           tt-PromoGoodsCrite.idAction       = p-sub:idAction
           tt-PromoGoodsCrite.gds-code       = p-sub:GdsCode
           tt-PromoGoodsCrite.gdsname        = p-sub:Gdsname
           tt-PromoGoodsCrite.type           = p-sub:type
           tt-PromoGoodsCrite.sub            = p-subs:SubjectObjCurr
           tt-PromoGoodsCrite.mode           = p-sub:Mode
           tt-PromoGoodsCrite.db-num         = p-sub:db-num
           tt-PromoGoodsCrite.idSet          = p-sub:idSet
           tt-PromoGoodsCrite.price          = p-sub:price
           tt-PromoGoodsCrite.qnty           = p-sub:qnty
           tt-PromoGoodsCrite.NameSet        = p-sub:NameSet
         .
         if p-mode = {&add-def} 
         then do:
         tt-PromoGoodsCrite.mode = {&h-create}.
         tt-PromoGoodsCrite.idAction = tt-PromoAction-one.id.
         end.
     end.    
     //if p-mode = {&update} then temp-table tt-PromoGoodsCrite:tracking-changes = true .
  end method. // end_of_CreateTableForGoodsCrite
   method public void CreateCrits():
       define buffer tt-PromoCriterion     for tt-PromoCriterion.
       define buffer tt-PromoCriterionnext for tt-PromoCriterion.
       for each tt-PromoCriterion
           by tt-PromoCriterion.mincrit:
           block-next:  
           for each tt-PromoCriterionnext where tt-PromoCriterionnext.mincrit > tt-PromoCriterion.mincrit
                                            and tt-PromoCriterionnext.mode    <> {&h-delete}  
           by tt-PromoCriterionnext.mincrit:
              leave block-next.
           end.  

           if tt-PromoCriterion.maxcrit <> 0 then do:
           if CritgoodsFl then 
           assign
           tt-PromoCriterion.span = "От " +   trim(string (0,">>>>>>>9.99")) 
           tt-PromoCriterion.spanBef = "До " +   trim(string (tt-PromoCriterion.maxcrit,">>>>>>>9.99")) .
           else 
           assign
           tt-PromoCriterion.span = "От " +   trim(string (tt-PromoCriterion.mincrit,">>>>>>>9.99")) .
           tt-PromoCriterion.spanBef = "До " +   trim(string (tt-PromoCriterion.maxcrit,">>>>>>>9.99")) .
           .
           end.
           else do:
           tt-PromoCriterion.span = "От " +   trim(string (tt-PromoCriterion.mincrit,">>>>>>>9.99")) .
           if available tt-PromoCriterionnext  then tt-PromoCriterion.spanBef = "До " +   trim(string (tt-PromoCriterionnext.mincrit - 0.01 ,">>>>>>>9.99")) .
           else "".
           end.

/*           if tt-PromoCriterion.maxcrit = 0 then tt-PromoCriterion.spanBef = " " .                          */
/*           else tt-PromoCriterion.spanBef = "До " +   trim(string (tt-PromoCriterion.maxcrit,">>>>>>>9.99"))*/
                                  .                                   
       end. 
   end.
  method public void CreateTableForGoodsAppl
  ( input  p-mode as character
  , input  p-subs  as class promogoodssubs
  ) :
    define variable vI as int no-undo.
    define variable p-sub as class promogoodssub no-undo.

    //if p-mode = {&add-def} then temp-table tt-PromoGoodsAppl:tracking-changes = true . 
    do vi = 1 to p-subs:GetItem(vI):  
        p-sub = p-subs:promoGoodsObjCurr.
        create tt-PromoGoodsAppl.
        assign
           tt-PromoGoodsAppl.id             = p-sub:ID
           tt-PromoGoodsAppl.idAction       = p-sub:idAction
           tt-PromoGoodsAppl.gds-code       = p-sub:GdsCode
           tt-PromoGoodsAppl.gdsname        = p-sub:GdsName
           tt-PromoGoodsAppl.type           = p-sub:type
           tt-PromoGoodsAppl.sub            = p-subs:SubjectObjCurr
           tt-PromoGoodsAppl.mode           = p-sub:Mode
           tt-PromoGoodsAppl.db-num         = p-sub:db-num
           tt-PromoGoodsAppl.idSet          = p-sub:idSet
           tt-PromoGoodsAppl.price          = p-sub:price
           tt-PromoGoodsAppl.qnty           = p-sub:qnty
           tt-PromoGoodsAppl.NameSet        = p-sub:NameSet
         . 
         if p-mode = {&add-def} 
         then do:
         tt-PromoGoodsAppl.mode = {&h-create}.
         tt-PromoGoodsAppl.idAction = tt-PromoAction-one.id.
         end.
     end.
     //if p-mode = {&update} then temp-table tt-PromoGoodsAppl:tracking-changes = true .
  end method. // end_of_CreateTableForGoodsAppl
  
   method public void CreateTableForPromoSet
  ( input  p-mode as character
  , input  p-subs  as class promogoodssubs
  ) :
    define variable vI as int no-undo.
    define variable p-sub as class promogoodssub no-undo.
    
    if {&promoTrackingChanges} p-mode = {&add-def} then temp-table tt-PromoSet:tracking-changes = true . 
    do vi = 1 to p-subs:GetItem(vI):  
        p-sub = p-subs:promoGoodsObjCurr.
        
        create tt-PromoSet.
        assign
           tt-PromoSet.id             = p-sub:ID
           tt-PromoSet.idAction       = p-sub:idAction
           tt-PromoSet.gds-code       = p-sub:GdsCode
           tt-PromoSet.type           = p-sub:type
           tt-PromoSet.sub            = p-subs:SubjectObjCurr
           tt-PromoSet.mode           = p-sub:Mode
           tt-PromoSet.db-num         = p-sub:db-num
           tt-PromoSet.idSet          = p-sub:idSet
           tt-PromoSet.price          = p-sub:price
           tt-PromoSet.qnty           = p-sub:qnty
           tt-PromoSet.NameSet        = p-sub:NameSet
         .
         
         p-sub:refreshChildObj().
         if p-mode = {&add-def} 
         then do:
         tt-PromoSet.mode = {&h-create}.
         tt-PromoSet.idAction = tt-PromoAction-one.id.
         end.
         CreateTableForPromoSetGoods(p-mode, p-sub:PromoSetGoods).  
     end.
     if {&promoTrackingChanges} p-mode = {&update} then temp-table tt-PromoSet:tracking-changes = true .
  end method. // end_of_CreateTableForPromoSet
  
   method public void CreateTableForCardsbin
  ( input  p-mode as character
  , input  p-subs  as class promogoodssubs
  ) :
    define variable vI as int no-undo.
    define variable p-sub as class promogoodssub no-undo.
   
    if {&promoTrackingChanges} p-mode = {&add-def} then temp-table tt-PromoCardsbin:tracking-changes = true . 
    do vi = 1 to p-subs:GetItem(vI):  
        p-sub = p-subs:promoGoodsObjCurr.
        
        create tt-PromoCardsbin.
        assign
           tt-PromoCardsbin.id             = p-sub:ID
           tt-PromoCardsbin.idAction    = p-sub:idAction
           tt-PromoCardsbin.gds-code       = p-sub:GdsCode
           tt-PromoCardsbin.type           = p-sub:type
           tt-PromoCardsbin.sub            = p-subs:SubjectObjCurr
           tt-PromoCardsbin.mode           = p-sub:Mode
           tt-PromoCardsbin.db-num         = p-sub:db-num
           tt-PromoCardsbin.idSet          = p-sub:idSet
           tt-PromoCardsbin.price          = p-sub:price
           tt-PromoCardsbin.qnty           = p-sub:qnty
           tt-PromoCardsbin.NameSet        = p-sub:NameSet
         .
         
         if p-mode = {&add-def} 
         then do:
         tt-PromoCardsbin.mode = {&h-create}.
         tt-PromoCardsbin.idAction = tt-PromoAction-one.id.
         end.
          
     end.
     if {&promoTrackingChanges} p-mode = {&update} then temp-table tt-PromoCardsbin:tracking-changes = true .
  end method. // end_of_CreateTableForCardsbin

   method public void CreateTableForBarCode
  ( input  p-mode as character
  , input  p-subs  as class promogoodssubs
  ) :
    define variable vI as int no-undo.
    define variable p-sub as class promogoodssub no-undo.
   
    if {&promoTrackingChanges} p-mode = {&add-def} then temp-table tt-PromoBc:tracking-changes = true . 
    do vi = 1 to p-subs:GetItem(vI):  
        p-sub = p-subs:promoGoodsObjCurr.
        
        create tt-PromoBC.
        assign
           tt-PromoBC.id             = p-sub:ID
           tt-PromoBC.idAction       = p-sub:idAction
           tt-PromoBC.gds-code       = p-sub:GdsCode
           tt-PromoBC.type           = p-sub:type
           tt-PromoBC.sub            = p-subs:SubjectObjCurr
           tt-PromoBC.mode           = p-sub:Mode
           tt-PromoBC.db-num         = p-sub:db-num
           tt-PromoBC.idSet          = p-sub:idSet
           tt-PromoBC.price          = p-sub:price
           tt-PromoBC.qnty           = p-sub:qnty
           tt-PromoBC.NameSet        = p-sub:NameSet
           tt-PromoBc.gdsName        = p-sub:GdsName
           tt-PromoBc.bc-code        = p-sub:promo-code
         .
         
         if p-mode = {&add-def} 
         then do:
         tt-PromoBC.mode = {&h-create}.
         tt-PromoBC.idAction = tt-PromoAction-one.id.
         end.
          
     end.
     if {&promoTrackingChanges} p-mode = {&update} then temp-table tt-PromoBC:tracking-changes = true .
  end method. // end_of_CreateTableForBarCode

  
  method public void CreateTableForPromoSetGoods
  ( input  p-mode as character
  , input  p-subs  as class promogoodssubs
  ) :
    define variable vI as int no-undo.
    define variable p-sub as class promogoodssub no-undo.
    
    //if p-mode = {&add-def} then temp-table tt-PromoGoodsAppl:tracking-changes = true . 
    do vi = 1 to p-subs:GetItem(vI):  
        p-sub = p-subs:promoGoodsObjCurr.
        
        create tt-PromoSetGoods.
        assign
           tt-PromoSetGoods.id             = p-sub:ID
           tt-PromoSetGoods.idAction       = p-sub:idAction
           tt-PromoSetGoods.gds-code       = p-sub:GdsCode
           tt-PromoSetGoods.gdsName        = p-sub:GdsName 
           tt-PromoSetGoods.type           = p-sub:type
           tt-PromoSetGoods.sub            = p-subs:SubjectObjCurr
           tt-PromoSetGoods.mode           = p-sub:Mode
           tt-PromoSetGoods.db-num         = p-sub:db-num
           tt-PromoSetGoods.idSet          = p-sub:idSet
           tt-PromoSetGoods.price          = p-sub:price
           tt-PromoSetGoods.qnty           = p-sub:qnty
           tt-PromoSetGoods.NameSet        = p-sub:NameSet
         .
         if p-mode = {&add-def} 
         then do:
         tt-PromoSetGoods.mode = {&h-create}.
         tt-PromoSetGoods.idAction = tt-PromoAction-one.id.
         end.
         
     end.
     //if p-mode = {&update} then temp-table tt-PromoGoodsAppl:tracking-changes = true .
  end method. // end_of_CreateTableForPromoSetGoods
  
  method public void CreateTableForCrite
  ( input  p-mode as character
  , input  p-subs  as class promoCriterionSubs
  ) :
    define variable vI as int no-undo.
    define variable p-sub as class promoCriterionSub no-undo.
    // if p-mode = {&add-def} then temp-table tt-PromoCriterion:tracking-changes = true . 
    do vi = 1 to p-subs:GetItem(vI):  
        p-sub = p-subs:promoCriterionObjCurr.
        create tt-PromoCriterion.
         
        assign
           tt-PromoCriterion.id             = p-sub:ID
           tt-PromoCriterion.idAction       = p-sub:idAction
           tt-PromoCriterion.discont        = p-sub:discont
           tt-PromoCriterion.mincrit        = p-sub:mincrit
           tt-PromoCriterion.maxcrit        = p-sub:maxcrit
           tt-PromoCriterion.sub            = p-subs:SubjectObjCurr
           tt-PromoCriterion.mode           = p-sub:Mode
           tt-PromoCriterion.db-num         = p-sub:db-num
         .
         
         p-sub:refreshChildObj().
         if p-mode = {&add-def} 
         then do:
         tt-PromoCriterion.mode = {&h-create}.
         tt-PromoCriterion.idAction = tt-PromoAction-one.id.
         end.
         CreateTableForGift(p-mode, p-sub:Gifts).
         
     end.
     CreateCrits().
     // if p-mode = {&update} then temp-table tt-PromoCriterion:tracking-changes = true .
  end method. // end_of_CreateTableForCrite
  method public void CreateTableForGift
  ( input  p-mode as character
  , input  p-subs  as class promoGiftSubs
  ) :
    define variable vI as int no-undo.
    define variable p-sub as class promoGiftSub no-undo.
    // if p-mode = {&add-def} then temp-table tt-PromoGift:tracking-changes = true . 
    do vi = 1 to p-subs:GetItem(vI): 
        p-sub = p-subs:promoGiftObjCurr.
        create tt-PromoGift.
        assign
           tt-PromoGift.id             = p-sub:ID
           tt-PromoGift.idaction       = p-sub:idAction
           tt-PromoGift.idCrit         = p-sub:idCrit
           tt-PromoGift.gds-code       = p-sub:GdsCode
           tt-PromoGift.gdsName        = p-sub:GdsName
           tt-PromoGift.mess           = p-sub:mess
           tt-PromoGift.qnty           = p-sub:qnty
           tt-PromoGift.sub            = p-subs:SubjectObjCurr
           tt-PromoGift.mode           = p-sub:Mode
           tt-PromoGift.db-num         = p-sub:db-num
           tt-PromoGift.mess-gks       = p-sub:mess-gks
         . 
         if p-mode = {&add-def} 
         then do:
         tt-PromoGift.mode = {&h-create}.
         tt-PromoGift.idAction = tt-PromoAction-one.id.
         end.
     end.
     // if p-mode = {&update} then temp-table tt-PromoGift:tracking-changes = true .
  end method. // end_of_CreateTableForGift
  
  method public void CreateTableForObject
  ( input  p-mode as character
  , input  p-subs  as class promoObjectSubs
  ) :
    define variable vI as int no-undo.
    define variable p-sub as class promoObjectSub no-undo.
    // if p-mode = {&add-def} then temp-table tt-PromoGift:tracking-changes = true . 
    do vi = 1 to p-subs:GetItem(vI):
        p-sub = p-subs:promoObjectObjCurr.
        create tt-PromoObject.
        assign
           tt-PromoObject.id             = p-sub:ID
           tt-PromoObject.idaction       = p-sub:idAction
           tt-PromoObject.sub            = p-subs:SubjectObjCurr
           tt-PromoObject.mode           = p-sub:Mode
           tt-PromoObject.db-num         = p-sub:db-num
           tt-PromoObject.obj-code       = p-sub:obj-code
           tt-PromoObject.obj-type       = p-sub:obj-type
           tt-PromoObject.FirmCode       = p-sub:FirmCode
           tt-PromoObject.FirmName       = p-sub:FirmName
           tt-PromoObject.objName        = p-sub:objName
           tt-PromoObject.objDbNum       = p-sub:objDbNum
           tt-PromoObject.end-date       = p-sub:end-date
           
         . 
         if p-mode = {&add-def} 
         then do:
         tt-PromoObject.mode = {&h-create}.
         tt-PromoObject.idAction = tt-PromoAction-one.id.
         end.
     end.
     // if p-mode = {&update} then temp-table tt-PromoGift:tracking-changes = true .
  end method. // end_of_CreateTableForGift


  // отрезает секунды и милисекунды от value из dateTimePicker
  method private void roundDtime (
    input  p-wdaynum   as integer 
  , input  p-dtimebeg1 as datetime
  , input  p-dtimeend1 as datetime
  , output p-temp-id   as integer
  , output p-itimebeg2 as integer
  , output p-itimeend2 as integer
  , output p-dtimebeg2 as datetime
  , output p-dtimeend2 as datetime
  ) :
    assign
      p-itimebeg2 = integer( truncate(  mtime(p-dtimebeg1) / 1000 / 60,  0  ) ) 
      p-itimeend2 = integer( truncate(  mtime(p-dtimeend1) / 1000 / 60,  0  ) )
    .
    // в id время кладётся минутами, иначе не хватит разрядности
    p-temp-id = (-1) *
    (
          100000000 * p-wdaynum
            + 10000 * p-itimebeg2 
                    + p-itimeend2
    ) no-error.
    assign
      p-itimebeg2 = p-itimebeg2 * 60
      p-itimeend2 = p-itimeend2 * 60
      p-dtimebeg2 = datetime (today, p-itimebeg2 * 1000)
      p-dtimeend2 = datetime (today, p-itimeend2 * 1000)
    .
  end method . // end_of roundDtime
  method public void CreateTableForSchedw0
  ( input  p-mode as character
  , input  p-subs as class promoschedwsubs
  ) :
    define variable vI as int no-undo.
    define variable v-i-counter as integer no-undo .
    define variable v-sub as promoschedwsub no-undo .
    // if p-mode = {&add-def} then temp-table tt-PromoGift:tracking-changes = true . 
    create tt-promo-schedule-week.
    
  if valid-object(p-subs) then do:
    v-i-counter = p-subs:iCounter .
    if v-i-counter > 0 then do :
    do vi = 1 to p-subs:GetItem(vI):
        v-sub = p-subs:promoSchedwObjCurr .
        assign
          tt-promo-schedule-week.db-num = v-sub:db-num
          tt-promo-schedule-week.promosched-id = v-sub:schedId
          // время начала и окончания приходит из БД округлённое, без секунд
          tt-promo-schedule-week.timebeg   = v-sub:timebeg
          tt-promo-schedule-week.timeend   = v-sub:timeend
          tt-promo-schedule-week.dtime-beg = datetime (today, tt-promo-schedule-week.timebeg * 1000)
          tt-promo-schedule-week.dtime-end = datetime (today, tt-promo-schedule-week.timeend * 1000)
          tt-promo-schedule-week.sub    = v-sub when (v-sub:Id = v-sub:schedId)  
        .
        if p-mode = {&add-def} 
        then do:
          tt-promo-schedule-week.promosched-id = m-local-sec.
          tt-promo-schedule-week.mode          = {&h-create}.
          
        end.   
        tt-promo-schedule-week.wdaylist = tt-promo-schedule-week.wdaylist + substitute(",&1", v-sub:wdaylist) .
    end.
    assign
      tt-promo-schedule-week.wdaylist = substring(tt-promo-schedule-week.wdaylist, 2)
    .
    end .
  end. // end_of valid-object(subs)
  else v-i-counter = 0 .
  
  /* 09/VIII-2018 если расписания нет - акция действует постоянно.
                  Частный случай: если расписания нет - оно рассматривается как ПРОСТОЕ, и мы приходим сюда. */
  if v-i-counter = 0 then do :
    assign
      /* остались незаполненными:
          tt-promo-schedule-week.db-num        = p-subs:promoSchedwObjCurr:db-num
          tt-promo-schedule-week.promosched-id = p-subs:promoSchedwObjCurr:schedId
          tt-promo-schedule-week.sub           = p-subs:promoSchedwObjCurr when (v-sub:Id = v-sub:schedId)  
      */
      tt-promo-schedule-week.dtime-beg = datetime (today, 0)
      tt-promo-schedule-week.dtime-end = datetime (today, 86340 * 1000) // 86340 = 23:59
      tt-promo-schedule-week.wdaylist = "0"
    .
  end .
  
    assign
      tt-promo-schedule-week.id        = tt-promo-schedule-week.promosched-id
      tt-promo-schedule-week.isday_mon = can-do(tt-promo-schedule-week.wdaylist, "1") or can-do(tt-promo-schedule-week.wdaylist, "0")
      tt-promo-schedule-week.isday_tue = can-do(tt-promo-schedule-week.wdaylist, "2") or can-do(tt-promo-schedule-week.wdaylist, "0")
      tt-promo-schedule-week.isday_wed = can-do(tt-promo-schedule-week.wdaylist, "3") or can-do(tt-promo-schedule-week.wdaylist, "0")
      tt-promo-schedule-week.isday_thu = can-do(tt-promo-schedule-week.wdaylist, "4") or can-do(tt-promo-schedule-week.wdaylist, "0")
      tt-promo-schedule-week.isday_fri = can-do(tt-promo-schedule-week.wdaylist, "5") or can-do(tt-promo-schedule-week.wdaylist, "0")
      tt-promo-schedule-week.isday_sat = can-do(tt-promo-schedule-week.wdaylist, "6") or can-do(tt-promo-schedule-week.wdaylist, "0")
      tt-promo-schedule-week.isday_sun = can-do(tt-promo-schedule-week.wdaylist, "7") or can-do(tt-promo-schedule-week.wdaylist, "0")
    .
    // if p-mode = {&update} then temp-table tt-PromoGift:tracking-changes = true .
  end method. // end_of_CreateTableForSchedw0
//  define private variable g-week-days as character no-undo initial
//    "понедельник,вторник,среда,четверг,пятница,суббота,воскресенье" .
  method public void CreateTableForSchedw1
  ( input  p-mode as character
  , input  p-subs as class promoschedwsubs
  ) :
    define variable vI     as int no-undo.
    define variable v-sub  as promoschedwsub no-undo .
    define variable v-wdaylist as character no-undo .
    define variable i-num  as integer no-undo .
    define variable i-size as integer no-undo .
    define variable s-wday as character no-undo .
    define variable i-wday as integer no-undo .
    define variable v-isFirst as logical no-undo .
    define variable v-temp-id  as integer no-undo .
    define variable v-itimebeg as integer no-undo .
    define variable v-itimeend as integer no-undo .
    define variable v-dtimebeg as datetime no-undo .
    define variable v-dtimeend as datetime no-undo .
    define variable v-dtimebeg2 as datetime no-undo .
    define variable v-dtimeend2 as datetime no-undo .
    
    if valid-object(p-subs) then do:
    // if p-mode = {&add-def} then temp-table tt-PromoGift:tracking-changes = true . 
    do vi = 1 to p-subs:GetItem(vI):
        v-sub = p-subs:promoSchedwObjCurr .
        
        v-itimebeg = v-sub:timebeg .
        v-itimeend = v-sub:timeend .
        v-dtimebeg = datetime (today, v-itimebeg * 1000) .
        v-dtimeend = datetime (today, v-itimeend * 1000) .
        
        v-wdaylist = v-sub:wdaylist .
        i-size = num-entries (v-wdaylist) .
        v-isFirst = true .
        do i-num = 1 to i-size :
          s-wday = entry(i-num, v-wdaylist) .
          i-wday = integer(s-wday) no-error .
          if i-wday > 0 then do :
            roundDtime (i-wday, v-dtimebeg, v-dtimeend,
              output v-temp-id,
              output v-itimebeg, output v-itimeend,
              output v-dtimebeg2, output v-dtimeend2) .

            create tt-promo-schedule-week2 .
            if v-isFirst then assign
              tt-promo-schedule-week2.sub = v-sub 
              tt-promo-schedule-week2.id  = v-sub:ID
              v-isFirst = false
            .
            else assign
              tt-promo-schedule-week2.id  = v-temp-id
            .
            assign
              tt-promo-schedule-week2.db-num        = v-sub:db-num
              tt-promo-schedule-week2.promosched-id = v-sub:schedId
              tt-promo-schedule-week2.dtime-beg = v-dtimebeg
              tt-promo-schedule-week2.dtime-end = v-dtimeend
//            tt-promo-schedule-week2.wdaylabel = entry(i-wday, g-week-days)
              tt-promo-schedule-week2.wdaynum  = i-wday
              tt-promo-schedule-week2.wdaylist = s-wday
            .
            if p-mode = {&add-def} 
            then do:
              tt-promo-schedule-week2.promosched-id = m-local-sec.
              tt-promo-schedule-week2.mode          = {&h-create}.
            end.
          end . // end_of i-wday>0
        end . // end_of do on wdaylist   
    end.
    // if p-mode = {&update} then temp-table tt-PromoGift:tracking-changes = true .
    end. // end_of valid-object(subs)
  end method. // end_of_CreateTableForSchedw1

/* @NOTE 16/VIII-2018 копирование экземпляра класса:
  https://knowledgebase.progress.com/articles/Article/000050150
  How to clone a class object in OOABL?
  (найдено через Google по строке "Clone method is undefined for the class. (13444) OpenEdge")  
*/
/* 2.2 перенести temp-table в объект m-sub */
  method public void UpdateObjForAction
  ( 
  ) :
    define variable p-sub as class promoActionSub.
    define variable v-sched-sub as class promoSchedSub no-undo .
    for first tt-PromoAction-one:
        
        assign
           p-sub                 = cast(tt-PromoAction-one.sub, promoActionSub)
           p-sub:ID              = tt-PromoAction-one.id             
           p-sub:db-num          = tt-PromoAction-one.db-num
           p-sub:changeDate      = if tt-PromoAction-one.ChangDateFl then tt-PromoAction-one.changeDate else ?
           p-sub:comment         = tt-PromoAction-one.comment
           p-sub:description     = tt-PromoAction-one.description
           p-sub:ext-code        = tt-PromoAction-one.ext-code
           p-sub:priority        = tt-PromoAction-one.priority
           p-sub:status_lbl      = tt-PromoAction-one.status_lbl
           p-sub:beg-date        = tt-PromoAction-one.beg-date        
           p-sub:end-date        = tt-PromoAction-one.end-date        
           p-sub:methodCalclbl   = tt-PromoAction-one.methodCalclbl      
           p-sub:Mode            = tt-PromoAction-one.mode           
           p-sub:NameAction      = tt-PromoAction-one.nameAction      
           p-sub:promosched-id   = tt-PromoAction-one.promosched-id   
           p-sub:typecondlbl     = tt-PromoAction-one.typecondlbl        
           p-sub:TypeDiscont     = if tt-PromoAction-one.TypeDiscontsolo then 1 else if tt-PromoAction-one.TypeDiscontcombo then 2 else 3
           p-sub:CritgoodsFl     = tt-PromoAction-one.CritgoodsFl     
           v-sched-sub           = p-sub:Schedule
           
         .
         // даже если в акции отсутствовало расписание - здесь p-sub:Schedule уже есть всегда
         assign
           v-sched-sub:dispname     = tt-PromoAction-one.scheduleName 
           v-sched-sub:schedType    = if tt-PromoAction-one.scheduleType then 1 else 0
           v-sched-sub:extCodeSched = tt-PromoAction-one.extCodeSched
         .
         case p-sub:status_enum :
           when ibs.th.ref.promo.enum-promo-status:ensetting then /* выполняется настройка */
             v-sched-sub:status_ = ibs.th.ref.promo.enum-sched-status:ensetting .
           otherwise /* enactive = активна, encompleted = завершена */ 
             v-sched-sub:status_ = ibs.th.ref.promo.enum-sched-status:enactive .
         end case .
         
         // ?? переделать все на input-output ??
         updateObjForGoodsCrits(p-sub:GoodsCrits).
         updateObjForGoodsAppl (p-sub:GoodsAppl ).
         updateObjForCrite     (p-sub:Criterion ).
         updateObjForGift      (p-sub:Gifts,0).
         updateObjForObject    (p-sub:Objects).
         updateObjForSET       (p-sub:PromoSet ).
         updateObjForCards     (p-sub:CardsBin ).
         updateObjForBC        (p-sub:BarCode ).
         // ... а вот p-sub:ScheduleWeek могло и не быть. Особенно, если в акции отсутствовало расписание.
         if v-sched-sub:schedType = 0 then UpdateObjForSchedw0 (p-sub:ScheduleWeek).
                                      else UpdateObjForSchedw1 (p-sub:ScheduleWeek).
         define variable vstr as character no-undo.
         for each tt-cashpay no-lock:
             vstr = vstr 
                  + {&delim-par} 
                  + string(tt-cashpay.cdpay-code) 
                  + {&delim-key} 
                  + string(tt-cashpay.curr-code).
         end.
         assign
            vstr                           = trim(vstr, {&delim-par} )
            tt-PromoAction-one.paymenttype = vstr
            p-sub:paymenttype              = tt-PromoAction-one.paymenttype
         .                                 
     end.
  end method. // end_of_updateObjForAction
  
  method public void updateObjForGoodsCrits
  ( input  p-subs  as class promogoodssubs
  ) :
      
    define variable v-sub as class PromoGoodsSub no-undo.
    for each tt-PromoGoodsCrite:
        if not valid-object(tt-PromoGoodsCrite.sub)
        then do:
           v-sub = new PromoGoodsSub(). 
           tt-PromoGoodsCrite.sub = cast(v-sub,Progress.Lang.Object).
           p-subs:AddItem(tt-PromoGoodsCrite.sub).
        end.
        else
           v-sub = cast(tt-PromoGoodsCrite.sub,promogoodssub).
               
        assign
           v-sub:ID       = tt-PromoGoodsCrite.id              
           v-sub:idAction = tt-PromoGoodsCrite.idAction        
           v-sub:GdsCode  = tt-PromoGoodsCrite.gds-code        
          /* v-sub:type     = {&criterion} 
           tt-PromoGoodsCrite.type = {&criterion}*/            
           v-sub:Mode     = tt-PromoGoodsCrite.mode            
        .
     end.    
  end method. // end_of_updateObjForGoodsCrite
  
  method public void updateObjForGoodsAppl
  ( input  p-subs  as class promogoodssubs
  ) :
    define variable v-sub as class PromoGoodsSub no-undo.
    for each tt-PromoGoodsAppl:
        if not valid-object(tt-PromoGoodsAppl.sub)
        then do:
           v-sub = new PromoGoodsSub(). 
           tt-PromoGoodsAppl.sub = cast(v-sub,Progress.Lang.Object).
           p-subs:AddItem(tt-PromoGoodsAppl.sub).
        end.
        else
           v-sub = cast(tt-PromoGoodsAppl.sub,promogoodssub).
               
        assign
           v-sub:ID       = tt-PromoGoodsAppl.id              
           v-sub:idAction = tt-PromoGoodsAppl.idAction        
           v-sub:GdsCode  = tt-PromoGoodsAppl.gds-code        
         /*  v-sub:type     = {&appl}
           tt-PromoGoodsAppl.type = {&appl}*/            
           v-sub:Mode     = tt-PromoGoodsAppl.mode            
        .
     end.    
  end method. // end_of_updateObjForGoodsAppl
  
  method public void updateObjForCrite
  ( input  p-subs  as class promoCriterionSubs
  ) :
    define variable v-sub as class promoCriterionSub no-undo.
    for each tt-PromoCriterion:
        if not valid-object(tt-PromoCriterion.sub)
        then do:
           v-sub = new promoCriterionSub().
           tt-PromoCriterion.sub = cast(v-sub,Progress.Lang.Object).
           p-subs:AddItem(tt-PromoCriterion.sub).
           v-sub:refreshChildObj(). // создаем потомков
           
        end.
        else do:
           v-sub = cast(tt-PromoCriterion.sub,promoCriterionSub).
        end.     
        assign
           v-sub:ID       = tt-PromoCriterion.id              
           v-sub:idAction = tt-PromoCriterion.idAction        
           v-sub:discont  = tt-PromoCriterion.discont         
           v-sub:mincrit  = tt-PromoCriterion.mincrit       
           v-sub:maxcrit  = tt-PromoCriterion.maxcrit  
           v-sub:Mode     = tt-PromoCriterion.mode            
           
           
         .
         updateObjForGift(v-sub:Gifts,v-sub:ID).
     end.
  end method. // end_of_updateObjForCrite
  
  method public void updateObjForGift
  ( input  p-subs    as class promoGiftSubs
  , input  p-IdCrit  as int64
  ) :
    define variable v-sub as class promoGiftSub no-undo.
    for each tt-PromoGift where tt-PromoGift.idCrit eq p-IdCrit:
        if not valid-object(tt-PromoGift.sub)
        then do:
           v-sub = new promoGiftSub(). 
           tt-PromoGift.sub = cast(v-sub,Progress.Lang.Object).
           p-subs:AddItem(tt-PromoGift.sub).
        end.
        else
           v-sub = cast(tt-PromoGift.sub,promoGiftSub).  
        assign
           v-sub:GdsCode  = tt-PromoGift.gds-code        
           v-sub:mess     = tt-PromoGift.mess        
           v-sub:qnty     = tt-PromoGift.qnty        
           v-sub:Mode     = tt-PromoGift.mode   
           v-sub:mess-gks = tt-PromoGift.mess-gks     
         . 
     end.
  end method. // end_of_updateObjForGift
  
   method public void updateObjForObject
  ( input  p-subs    as class promoObjectSubs
  
  ) :
    define variable v-sub as class promoObjectSub no-undo.
    for each tt-PromoObject :
        if not valid-object(tt-PromoObject.sub)
        then do:
           v-sub = new promoObjectSub(). 
           tt-PromoObject.sub = cast(v-sub,Progress.Lang.Object).
           p-subs:AddItem(tt-PromoObject.sub).
        end.
        else
           v-sub = cast(tt-PromoObject.sub,promoObjectSub).  
         assign
           v-sub:Mode     = tt-PromoObject.mode           
           v-sub:obj-code = tt-PromoObject.obj-code
           v-sub:obj-type = tt-PromoObject.obj-type
           v-sub:end-date = tt-PromoObject.end-date       
        .
     end.
  end method. // end_of_updateObjForGift
  
    method public void updateObjForSet
    ( input  p-subs  as class promogoodssubs
     ) :
      
    define variable v-sub as class PromoGoodsSub no-undo.
    for each tt-Promoset:
        if not valid-object(tt-PromoSet.sub)
        then do:
           v-sub = new PromoGoodsSub(). 
           tt-PromoSet.sub = cast(v-sub,Progress.Lang.Object).
           p-subs:AddItem(tt-PromoSet.sub).
           v-sub:refreshChildObj().
        end.
        else
           v-sub = cast(tt-PromoSet.sub,promogoodssub).
               
        assign
           v-sub:ID       = tt-PromoSet.id              
           v-sub:idAction = tt-PromoSet.idAction        
           v-sub:GdsCode  = tt-PromoSet.gds-code        
          /* v-sub:type     = {&promoSet} 
           tt-PromoSet.type = {&promoSet}*/            
           v-sub:Mode     = tt-PromoSet.mode 
           v-sub:qnty     = tt-PromoSet.qnty
           v-sub:NameSet  = tt-PromoSet.nameset          
        .
        updateObjForSetGoods(v-sub:promoSetGoods,v-sub:ID).
     end.    
  end method. // end_of_updateObjForSet
  
  method public void updateObjForCards
    ( input  p-subs  as class promogoodssubs
     ) :
      
    define variable v-sub as class PromoGoodsSub no-undo.
    for each tt-PromoCardsBin:
        if not valid-object(tt-PromoCardsBin.sub)
        then do:
           v-sub = new PromoGoodsSub(). 
           tt-PromoCardsBin.sub = cast(v-sub,Progress.Lang.Object).
           p-subs:AddItem(tt-PromoCardsBin.sub).
           v-sub:refreshChildObj().
        end.
        else
           v-sub = cast(tt-PromoCardsBin.sub,promogoodssub).
               
        assign
           v-sub:ID       = tt-PromoCardsBin.id              
           v-sub:idAction = tt-PromoCardsBin.idAction        
           v-sub:Mode     = tt-PromoCardsBin.mode 
          v-sub:NameSet  = tt-PromoCardsBin.nameset          
        .
        
     end.    
  end method. // end_of_updateObjForCards
  
  method public void updateObjForBC
    ( input  p-subs  as class promogoodssubs
     ) :
      
    define variable v-sub as class PromoGoodsSub no-undo.
    for each tt-PromoBC:
        if not valid-object(tt-PromoBC.sub)
        then do:
           v-sub = new PromoGoodsSub(). 
           tt-PromoBC.sub = cast(v-sub,Progress.Lang.Object).
           p-subs:AddItem(tt-PromoBC.sub).
           v-sub:refreshChildObj().
        end.
        else
           v-sub = cast(tt-PromoBC.sub,promogoodssub).
               
        assign
           v-sub:ID       = tt-PromoBC.id              
           v-sub:idAction = tt-PromoBC.idAction        
           v-sub:Mode     = tt-PromoBC.mode 
           v-sub:NameSet  = tt-PromoBC.nameset          
        .
        
     end.    
  end method. // end_of_updateObjForCards

  
  method public void updateObjForSetGoods
    ( input  p-subs  as class promogoodssubs,
      input  pIdset  as int64
     ) :
      
    define variable v-sub as class PromoGoodsSub no-undo.
    for each tt-PromoSetGoods where tt-PromoSetGoods.IdSet eq pIdset:
        if not valid-object(tt-PromoSetGoods.sub)
        then do:
           v-sub = new PromoGoodsSub(). 
           tt-PromoSetGoods.sub = cast(v-sub,Progress.Lang.Object).
           p-subs:AddItem(tt-PromoSetGoods.sub).
        end.
        else
           v-sub = cast(tt-PromoSetGoods.sub,promogoodssub).
               
        assign
           v-sub:ID       = tt-PromoSetGoods.id              
           v-sub:idAction = tt-PromoSetGoods.idAction        
           v-sub:GdsCode  = tt-PromoSetGoods.gds-code        
       /*    v-sub:type     = {&promoSetGoods} 
           tt-PromoSetGoods.type = {&promoSetgoods}*/            
           v-sub:Mode     = tt-PromoSetGoods.mode            
        .
     end.    
  end method. // end_of_updateObjForSet

  method public void UpdateObjForSchedw0
  ( input  p-subs    as class promoSchedwSubs
  ) :
    define variable v-sub   as class promoSchedwSub no-undo.
    define variable v-subd  as class promoSchedwSub no-undo.
    define variable vi      as integer no-undo .
    define variable v-days  as character no-undo .
    define variable v-itimebeg as integer no-undo .
    define variable v-itimeend as integer no-undo .
    define variable v-temp-id  as integer no-undo .
    define variable v-dtimebeg as datetime no-undo .
    define variable v-dtimeend as datetime no-undo .
    /* для простого расписания на одна запись в temp-table распределяется в коллекцию так:
       - первая строка в коллекции обновляется, согласно отображению на экране;
       - остальным строчкам коллекции проставляется delete
    */
/*    
define variable dsXmlFileName as character no-undo .
dsXmlFileName = substitute("&1.xml", "a1-promo-schedule-week").
temp-table tt-promo-schedule-week:WRITE-XML ( "FILE", dsXmlFileName, true, "UTF-8").
*/
    
    for first tt-promo-schedule-week:
      v-days = "".
      assign
        v-days = v-days + ",1" when tt-promo-schedule-week.isday_mon
        v-days = v-days + ",2" when tt-promo-schedule-week.isday_tue
        v-days = v-days + ",3" when tt-promo-schedule-week.isday_wed
        v-days = v-days + ",4" when tt-promo-schedule-week.isday_thu
        v-days = v-days + ",5" when tt-promo-schedule-week.isday_fri
        v-days = v-days + ",6" when tt-promo-schedule-week.isday_sat
        v-days = v-days + ",7" when tt-promo-schedule-week.isday_sun
      .
      v-days = substring(v-days, 2) .
      if v-days eq "1,2,3,4,5,6,7"
      then v-days = "0".
      
      roundDtime (0, tt-promo-schedule-week.dtime-beg, tt-promo-schedule-week.dtime-end,
           output v-temp-id,
           output v-itimebeg, output v-itimeend,
           output v-dtimebeg, output v-dtimeend) .
      if valid-object(p-subs) then do :
        vi = p-subs:GetItem(1) .
        if vi > 0 then do :
          v-sub = p-subs:promoSchedwObjCurr .
          do vi = 2 to p-subs:GetItem(vI):
            v-subd = p-subs:promoSchedwObjCurr .
            v-subd:Mode = {&h-delete} .
          end .
        end .
        else do:
          v-sub = new promoSchedwSub().
          p-subs:AddItem(v-sub).
          assign
            v-sub:Mode    = {&h-create}
          . 
        end.
        assign
          v-sub:timebeg  = v-itimebeg 
          v-sub:timeend  = v-itimeend
          v-sub:wdaylist = v-days
        .
      end .
      else do :
        // если расписания не было - то пишем его только если что-нибудь поменялось
       // if (v-days <> "0") or (v-itimebeg <> 0) or (v-itimeend <> 86340) then do :
          v-sub = new promoSchedwSub().
          assign
            v-sub:timebeg  = v-itimebeg 
            v-sub:timeend  = v-itimeend
            v-sub:wdaylist = v-days
            v-sub:Mode     = {&h-create}
          .
          p-subs = new promoSchedwSubs().
          p-subs:AddItem(v-sub).
       // end .
      end .
      
    end.
        
  end method. // end_of_UpdateObjForSchedw0

  method public void UpdateObjForSchedw1
  ( input  p-subs    as class promoSchedwSubs
  ) :
    define variable v-sub   as class promoSchedwSub no-undo.
    define variable v-suba  as class promoSchedwSub no-undo.
    define variable vi      as integer no-undo .
    define variable v-ancorValid as logical no-undo .
    define variable v-ancorOut   as logical no-undo .
    define variable v-temp-id    as integer no-undo .
    define variable v-dtimebeg   as datetime no-undo .
    define variable v-dtimeend   as datetime no-undo .
    define variable v-itimebeg   as integer no-undo .
    define variable v-itimeend   as integer no-undo .

    /* если до этого расписания в акции не было - сливаем его как есть из tt-promo-schedule-week2 */
    if not valid-object (p-subs) then p-subs = new promoSchedwSubs().
    
    // 1. из коллекции удалить все дни, кроме якорного (т.е. где id = promosched-id)
    v-ancorValid = false .
    do vi = 1 to p-subs:GetItem(vI):
      v-sub = p-subs:promoSchedwObjCurr .
      if v-sub:ID = v-sub:schedId then assign
        v-suba = v-sub
        v-ancorValid = true
      .
      else v-sub:Mode = {&h-delete} .
    end .

    // 2. якорную запись коллекции (если коллекцияя была непустая) обновить,
    //    остальные запись из tt-promo-schedule-week2 добавить
    if v-ancorValid then do :
      // если якорная запись присутствует в tt-promo-schedule-week2 - обновить её
      // иначе взять любую другую и обновить ею.
      v-ancorOut = false .
      for each tt-promo-schedule-week2:
        if tt-promo-schedule-week2.id = v-suba:Id then do :
          roundDtime (0, tt-promo-schedule-week2.dtime-beg, tt-promo-schedule-week2.dtime-end,
            output v-temp-id,
            output v-itimebeg, output v-itimeend,
            output v-dtimebeg, output v-dtimeend) .
          assign
            v-suba:timebeg  = v-itimebeg
            v-suba:timeend  = v-itimeend
            v-suba:wdaylist = substitute(  "&1",  tt-promo-schedule-week2.wdaynum  )
          .
          delete tt-promo-schedule-week2 .
          v-ancorOut = true .
          leave .
        end .
      end .
      if not v-ancorOut then for first tt-promo-schedule-week2:
          roundDtime (0, tt-promo-schedule-week2.dtime-beg, tt-promo-schedule-week2.dtime-end,
            output v-temp-id,
            output v-itimebeg, output v-itimeend,
            output v-dtimebeg, output v-dtimeend) .
          assign
            v-suba:timebeg  = v-itimebeg
            v-suba:timeend  = v-itimeend
            v-suba:wdaylist = substitute(  "&1",  tt-promo-schedule-week2.wdaynum  )
          .
          delete tt-promo-schedule-week2 .
      end .
    end . // end_of v-ancorValid
    
    for each tt-promo-schedule-week2:
      // записи добавленные в tt-promo-schedule-week2 из формы ввода имеют отрицательный id и округлённое время
      // записи, загруженные из БД, имеют положительный id и округлённое время
      v-sub = new promoSchedwSub().
      p-subs:AddItem(v-sub).
      roundDtime (0, tt-promo-schedule-week2.dtime-beg, tt-promo-schedule-week2.dtime-end,
           output v-temp-id,
           output v-itimebeg, output v-itimeend,
           output v-dtimebeg, output v-dtimeend) .
      assign
        v-sub:db-num  = tt-promo-schedule-week2.db-num
        v-sub:schedId = tt-promo-schedule-week2.promosched-id
        v-sub:Mode    = {&h-create}
        v-sub:timebeg  = v-itimebeg
        v-sub:timeend  = v-itimeend
  //      v-sub:wdaylist = substitute(  "&1",  lookup(tt-promo-schedule-week2.wdaylabel, g-week-days) )
        v-sub:wdaylist = substitute(  "&1",  tt-promo-schedule-week2.wdaynum  )
      .
    end .
    
  end method. // end_of_UpdateObjForSchedw1


/* 2.3 проверить введённые значение (лежат в temp-table после bindingSource:Assign) */
  method public void checkPromoAction () :
    // tt-promo-schedule-week available
  end method. // end_of_checkPromoAction 

  method private character modeForm2Fun (input p-mode-form as character) :
    define variable v-mode-fun as character no-undo .
    case p-mode-form :
      when {&update} then v-mode-fun = {&h-update} .
                otherwise v-mode-fun = {&h-create} . // <= &add-def, &lookup
      // nothing => &h-delete
    end case .
    return v-mode-fun .
  end method .

  /* Т.к. на момент ввода расписания оно уже известно, то его многократное переключение лишнее.
     Поэтому функционал переключения будет исключён при малейших проблемах.
     16/VIII-2018 автоматическое создание расписания при переключении с ПРОСТОГО на ДЕТАЛЬНОЕ
                  и с ДЕТАЛЬНОГО на ПРОСТОЕ отменено 
  */
  define private variable e-add-message as character no-undo .
  define private variable e-ign-message as character no-undo .
  define private variable e-has-inputs  as logical no-undo .
  define private variable e-has-errors  as logical no-undo .
  method public logical add2Detail(input p-bind-qname as character) :
    define variable v-has-errors as logical no-undo .
    define variable v-h-query  as handle no-undo .
    define variable v-is-ok    as logical no-undo .
      assign
        e-add-message = substitute("Добавлены дни недели:&1", {&new-line})
        e-ign-message = substitute("Дни недели:&1", {&new-line})
        e-has-inputs  = false
        e-has-errors  = false
      .
      // ...и снимать галочки на тот случай, если при добавлении будет ошибка и панель ввода останется на экране
      if tt-promo-schedule-week3.isday_mon then do :
        v-has-errors = createDetail2 ("1", buffer tt-promo-schedule-week3) .
        tt-promo-schedule-week3.isday_mon = v-has-errors .
        e-has-errors = (e-has-errors or v-has-errors) .
      end .
      if tt-promo-schedule-week3.isday_tue then do :
        v-has-errors = createDetail2 ("2", buffer tt-promo-schedule-week3) .
        tt-promo-schedule-week3.isday_tue = v-has-errors .
        e-has-errors = (e-has-errors or v-has-errors) .
      end .
      if tt-promo-schedule-week3.isday_wed then do :
        v-has-errors = createDetail2 ("3", buffer tt-promo-schedule-week3) .
        tt-promo-schedule-week3.isday_wed = v-has-errors .
        e-has-errors = (e-has-errors or v-has-errors) .
      end .
      if tt-promo-schedule-week3.isday_thu then do :
        v-has-errors = createDetail2 ("4", buffer tt-promo-schedule-week3) .
        tt-promo-schedule-week3.isday_thu = v-has-errors .
        e-has-errors = (e-has-errors or v-has-errors) .
      end .
      if tt-promo-schedule-week3.isday_fri then do :
        v-has-errors = createDetail2 ("5", buffer tt-promo-schedule-week3) .
        tt-promo-schedule-week3.isday_fri = v-has-errors .
        e-has-errors = (e-has-errors or v-has-errors) .
      end .
      if tt-promo-schedule-week3.isday_sat then do :
        v-has-errors = createDetail2 ("6", buffer tt-promo-schedule-week3) .
        tt-promo-schedule-week3.isday_sat = v-has-errors .
        e-has-errors = (e-has-errors or v-has-errors) .
      end .
      if tt-promo-schedule-week3.isday_sun then do :
        v-has-errors = createDetail2 ("7", buffer tt-promo-schedule-week3) .
        tt-promo-schedule-week3.isday_sun = v-has-errors .
        e-has-errors = (e-has-errors or v-has-errors) .
      end .
    v-h-query = getQuery(p-bind-qname, no).
    v-is-ok = v-h-query:QUERY-OPEN ( ).
    v-has-errors = e-has-errors .
    if v-has-errors then do :
      if e-has-inputs then
        e-add-message = e-add-message + {&new-line} + e-ign-message 
      .
      else e-add-message = e-ign-message .
      e-add-message = e-add-message + "содержат пересечение интервалов." .  
      message e-add-message view-as alert-box.
    end .
    return v-has-errors .
  end method .
  method public void delFromDetail(input p-bind-qname as character) :
    define variable v-h-query  as handle no-undo .
    define variable v-is-ok    as logical no-undo .
      if available tt-promo-schedule-week2 then
        delete tt-promo-schedule-week2 .
    v-h-query = getQuery(p-bind-qname, no).
    v-is-ok = v-h-query:QUERY-OPEN ( ).
  end method .
  define private variable a-week-days as character extent 7 no-undo initial
    ["понедельник","вторник","среда","четверг","пятница","суббота","воскресенье"] .
  method private logical createDetail2 (input p-wday     as character,
                                      buffer p-buf-week for tt-promo-schedule-week3) :
    define variable i-wday     as integer no-undo .
    define variable v-dtimebeg as datetime no-undo .
    define variable v-dtimeend as datetime no-undo .
    define variable v-temp-id  as integer no-undo .
    define variable v-itimebeg as integer no-undo .
    define variable v-itimeend as integer no-undo .
    define variable v-has-err  as logical no-undo .
    
    i-wday = integer (p-wday) no-error .
    if not error-status:error then do :
      roundDtime (i-wday, p-buf-week.dtime-beg, p-buf-week.dtime-end,
           output v-temp-id,
           output v-itimebeg, output v-itimeend,
           output v-dtimebeg, output v-dtimeend) .
      // пересечение и касание времени в пределах дня
      if can-find (first tt-promo-schedule-week2
                   where tt-promo-schedule-week2.wdaynum = i-wday
                     and tt-promo-schedule-week2.dtime-beg <= v-dtimeend
                     and tt-promo-schedule-week2.dtime-end >= v-dtimebeg 
                  ) then do :
        v-has-err = true .
        e-ign-message = e-ign-message + substitute("&1(&2-&3)&4"
        , a-week-days[i-wday]
        , string(v-itimebeg, "hh:mm")
        , string(v-itimeend, "hh:mm")
        , {&new-line}
        ).
        return v-has-err .                
      end .
      v-has-err = false .
      if not can-find (first tt-promo-schedule-week2
                       where tt-promo-schedule-week2.wdaynum = i-wday
                         and tt-promo-schedule-week2.dtime-beg = v-dtimebeg
                         and tt-promo-schedule-week2.dtime-end = v-dtimeend) then do :
        create tt-promo-schedule-week2 .
        tt-promo-schedule-week2.id = v-temp-id no-error.
        if error-status:error then delete tt-promo-schedule-week2 . else do :
          assign
        tt-promo-schedule-week2.promosched-id = p-buf-week.promosched-id
        tt-promo-schedule-week2.dtime-beg     = v-dtimebeg
        tt-promo-schedule-week2.dtime-end     = v-dtimeend
        tt-promo-schedule-week2.wdaylist      = p-wday
        tt-promo-schedule-week2.wdaynum       = i-wday
        tt-promo-schedule-week2.mode          = {&h-create}
          .
          e-has-inputs  = true .
          e-add-message = e-add-message + substitute("&1&2", a-week-days[i-wday], {&new-line}).
        end .
      end .
    end .
    else v-has-err = true .
    return v-has-err .
  end method .
  method public void delgds(input iName as character ):
    case iName:
       when "PromoGoodsAppl" 
       then do:
          if  tt-PromoGoodsAppl.mode eq {&h-create}
          then 
             delete tt-PromoGoodsAppl.
          else 
             tt-PromoGoodsAppl.mode = {&h-delete}.
       end. 
       when "PromoGoodsCrit"
       then do:
          if  tt-PromoGoodsCrite.mode eq {&h-create}
          then 
             delete tt-PromoGoodsCrite.
          else 
             tt-PromoGoodsCrite.mode = {&h-delete}.
       end.  
       when "PromoSet"
       then do:
          if  tt-PromoSet.mode eq {&h-create}
          then 
             delete tt-PromoSet.
          else 
             tt-PromoSet.mode = {&h-delete}.
       end.
       when "PromoCardsBin"
       then do:
          if  tt-PromoCardsBin.mode eq {&h-create}
          then 
             delete tt-PromoCardsBin.
          else 
             tt-PromoSet.mode = {&h-delete}.
       end.  
       when "PromoBarCode"
       then do:
          if  tt-PromoBC.mode eq {&h-create}
          then 
             delete tt-PromoBC.
          else 
             tt-PromoBC.mode = {&h-delete}.
       end.         
       when "PromoSetGoods"
       then do:
          if  tt-PromoSetGoods.mode eq {&h-create}
          then 
             delete tt-PromoSetGoods.
          else 
             tt-PromoSetGoods.mode = {&h-delete}.
       end. 
       when "PromoCriterion"
       then do:
          if  tt-PromoCriterion.mode eq {&h-create}
          then 
             delete tt-PromoCriterion.
          else 
             tt-PromoCriterion.mode = {&h-delete}.
       end. 
       when "PromoObject"
       then do:
          if  tt-PromoObject.mode eq {&h-create}
          then 
             delete tt-PromoObject.
          else 
             tt-PromoObject.mode = {&h-delete}.
       end. 
       when "PromoPay"
       then do:
          delete tt-CashPay.
       end. 
       when "PromoGift"
       then do:
         if  tt-PromoGift.mode eq {&h-create}
          then 
             delete tt-PromoGift.
          else 
             tt-PromoGift.mode = {&h-delete}.
          
       end.
       when "PromoCardsBin"
       then do:
         if  tt-PromoCardsBin.mode eq {&h-create}
          then 
             delete tt-PromoCardsBin.
          else 
             tt-PromoCardsBin.mode = {&h-delete}.
          
       end.
        
                    
    end case.
  end.         
method public void printgds(input iName as character ):
  define buffer buf_PromoBc for tt-PromoBc .
  define buffer buf_PromoGoodsAppl for tt-PromoGoodsAppl .
    case iName:
       when "PromoBarCode" or when "PromoBarCodeFix" 
       then do:
         empty temp-table gds-list .
      if not tt-PromoBc.Chang then do:
               find first ub.goods no-lock where
                  ub.goods.gds-code = tt-PromoBc.gds-code no-error .
               create gds-list.
               buffer-copy goods to gds-list.
               assign
                  gds-list.promo-code = tt-PromoBc.bc-code
                  gds-list.ActionId   = tt-PromoBc.idAction
                  gds-list.db-num     = tt-PromoBc.db-num
                  .
        end.
        else do:
          for each buf_PromoBc where buf_PromoBc.Chang:
               find first ub.goods no-lock where
                  ub.goods.gds-code = buf_PromoBc.gds-code no-error .
               create gds-list.
               buffer-copy goods to gds-list.
               assign
                  gds-list.promo-code = buf_PromoBc.bc-code
                  gds-list.ActionId   = buf_PromoBc.idAction
                  gds-list.db-num     = buf_PromoBc.db-num
                  .           
          end.
        end.
        run ibs/th/rep/tick-lst.p (input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code, input table gds-list).
        for each tt-PromoBc where tt-PromoBc.Chang:
          tt-PromoBc.Chang = false .
        end.
         
       end. 
       when "PromoGoodsFix"
       then do:
         empty temp-table gds-list .
      if not tt-PromoGoodsAppl.Chang then do:
               find first ub.goods no-lock where
                  ub.goods.gds-code = tt-PromoGoodsAppl.gds-code no-error .
               create gds-list.
               buffer-copy goods to gds-list.
               assign
                  gds-list.ActionId   = tt-PromoGoodsAppl.idAction
                  gds-list.db-num     = tt-PromoGoodsAppl.db-num
                  .
        end.
        else do:
          for each buf_PromoGoodsAppl where buf_PromoGoodsAppl.Chang:
               find first ub.goods no-lock where
                  ub.goods.gds-code = buf_PromoGoodsAppl.gds-code no-error .
               create gds-list.
               buffer-copy goods to gds-list.
               assign
                  gds-list.ActionId   = buf_PromoGoodsAppl.idAction
                  gds-list.db-num     = buf_PromoGoodsAppl.db-num
                  .           
          end.
        end.
        run ibs/th/rep/tick-lst.p (input parparentproc, input v-cntxt-obj-type, input v-cntxt-obj-code, input table gds-list).
        for each tt-PromoGoodsAppl where tt-PromoGoodsAppl.Chang:
          tt-PromoGoodsAppl.Chang = false .
        end.
         
       end.        
    end case.
  end.     
  method public void addgds(input iname  as char):
    define variable rid-list as character no-undo.
    define variable vI as integer no-undo.
    /* when "PromoObject"
       when "PromoPay" */
    if    iname eq "promoset"
       
    then do:
       create tt-PromoSet.
       assign
          tt-PromoSet.idAction = tt-promoaction-one.id
          tt-PromoSet.id       = m-local-sec
          m-local-sec          = m-local-sec - 1
          tt-PromoSet.mode     = {&h-create}
        .
    end.
    else if  iname eq "PromoCardsBin"
    then do:
       create tt-PromoCardsBin.
       assign
          tt-PromoCardsBin.idAction = tt-promoaction-one.id
          tt-PromoCardsBin.id       = m-local-sec
          m-local-sec          = m-local-sec - 1
          tt-PromoCardsBin.mode     = {&h-create}
        .
    end.
    else if iname eq "PromoCriterion"
    then do:
       create tt-PromoCriterion.
       assign
          tt-PromoCriterion.idAction = tt-promoaction-one.id
          tt-PromoCriterion.id       = m-local-sec
          m-local-sec                = m-local-sec - 1
          tt-PromoCriterion.mode     = {&h-create}
        .
    end.  
    else if    iname  eq "promosetgoods" and not available tt-promoset
    then
       message "Сначала введите промо набор."
       view-as alert-box.
    else if    iname  eq "PromoGiftForCrit" and not available tt-PromoCriterion
    then
       message "Сначала введите критерии."
       view-as alert-box.
    else
    run ref/gds-ref.p (
                  input parparentproc
                  ,input "b-sel,b-mark"
                  ,input ?                /*p-stat */
                  ,input {&all}           /*p-list  */
                  ,input ?                /*p-cond  */
                  ,input ?                /*p-rec   */
                  ,input ?                /*p-grp   */
                  ,input ?                /*p-cli-type */
                  ,input ?                /*p-cli-code  */
                  ,input ?       /*p-obj-type  */
                  ,input ?       /*p-obj-code  */
                  ,input ?                /*p-other     */
                  ,output rid-list ).
      do vi = 1 to num-entries(rid-list):
         find first ub.goods where recid(ub.goods) eq int64(entry(vi,rid-list))
         no-lock no-error.
         if available ub.goods
         then do:
         if can-find (first ub.goods-attr no-lock where ub.goods-attr.gds-code = ub.goods.gds-code and 
            ub.goods-attr.attr-code = {&attr-mark-type} and ub.goods-attr.attr-value <> "not-type" and 
            ub.goods-attr.attr-value <> "") then 
         do:
            message "Правила акции нарушают закон о маркировке продукции. Добавление маркированных товаров запрещено."
            view-as alert-box.
         end.   
         else do:
         case iName:
             when "PromoGoodsAppl" 
             then do:
                find first tt-PromoGoodsappl where  tt-PromoGoodsAppl.gds-code = ub.goods.gds-code no-error.
                if not available tt-PromoGoodsAppl
                then do:
                    create tt-PromoGoodsappl.
                    assign
                       tt-PromoGoodsAppl.idAction = tt-promoaction-one.id
                       tt-PromoGoodsAppl.id       = m-local-sec
                       m-local-sec                = m-local-sec - 1
                       tt-PromoGoodsAppl.mode     = {&h-create}
                       tt-PromoGoodsAppl.gds-code = ub.goods.gds-code
                       tt-PromoGoodsAppl.gdsName  = ub.goods.gds-name
                    . 
                 end.   
             end. 
             when "PromoGoodsCrit"
             then do:
               find first tt-PromoGoodsCrite where  tt-PromoGoodsCrite.gds-code = ub.goods.gds-code no-error.
                if not available tt-PromoGoodsCrite
                then do:
                    create tt-PromoGoodsCrite.
                    assign
                       tt-PromoGoodsCrite.idAction = tt-promoaction-one.id
                       tt-PromoGoodsCrite.id       = m-local-sec
                       m-local-sec                 = m-local-sec - 1
                       tt-PromoGoodsCrite.mode     = {&h-create}
                       tt-PromoGoodsCrite.gds-code = ub.goods.gds-code
                       tt-PromoGoodsCrite.gdsName   = ub.goods.gds-name
                    .
                 end.     
             end.  
             when "PromoSetGoods"
             then do:
               find first tt-PromoSetGoods where  tt-PromoSetGoods.gds-code = ub.goods.gds-code no-error.
                if not available tt-PromoSetGoods
                then do:
                    create tt-PromoSetGoods.
                    assign
                       tt-PromoSetGoods.idAction = tt-promoaction-one.id
                       tt-PromoSetGoods.id       = m-local-sec
                       tt-PromoSetGoods.Idset    = tt-PromoSet.id
                       m-local-sec               = m-local-sec - 1
                       tt-PromoSetGoods.mode     = {&h-create}
                       tt-PromoSetGoods.gds-code = ub.goods.gds-code
                       tt-PromoSetGoods.gdsName = ub.goods.gds-name
                    . 
                 end.   
             end. 
             when "PromoBarCode"
             then do:
               find first tt-PromoBc where  tt-PromoBc.gds-code = ub.goods.gds-code no-error.
                if not available tt-PromoBc
                then do:
                    create tt-PromoBc.
                    assign
                       tt-PromoBc.idAction = tt-promoaction-one.id
                       tt-PromoBc.id       = m-local-sec
                       tt-PromoBc.Idset    = tt-PromoSet.id
                       m-local-sec               = m-local-sec - 1
                       tt-PromoBc.mode     = {&h-create}
                       tt-PromoBc.gds-code = ub.goods.gds-code
                       tt-PromoBc.gdsName  = ub.goods.gds-name
                    . 
                 end.   
             end. 
       
             when "PromoGiftForAction"
             then do:
               find first tt-PromoGift where  tt-PromoGift.gds-code = ub.goods.gds-code 
                                         and  tt-PromoGift.Idcrit   = 0 no-error.
                if not available tt-PromoGift
                then do:
                    create tt-PromoGift.
                    assign
                       tt-PromoGift.idAction = tt-promoaction-one.id
                       tt-PromoGift.id       = m-local-sec
                       m-local-sec               = m-local-sec - 1
                       tt-PromoGift.mode     = {&h-create}
                       tt-PromoGift.gds-code = ub.goods.gds-code
                       tt-PromoGift.gdsName = ub.goods.gds-name
                    .
                 end.    
              end.
              when "PromoGiftForCrit"
             then do:
               find first tt-PromoGift where  tt-PromoGift.gds-code = ub.goods.gds-code 
                                         and  tt-PromoGift.Idcrit   = tt-PromoCriterion.id no-error.
                if not available tt-PromoGift
                then do:
                    create tt-PromoGift.
                    assign
                       tt-PromoGift.idAction = tt-promoaction-one.id
                       tt-PromoGift.id       = m-local-sec
                       tt-PromoGift.Idcrit   = tt-PromoCriterion.id
                       m-local-sec               = m-local-sec - 1
                       tt-PromoGift.mode     = {&h-create}
                       tt-PromoGift.gds-code = ub.goods.gds-code
                       tt-PromoGift.gdsName = ub.goods.gds-name
                    .
                 end.     
             end. 
                    
    end case.
         end.   
         end.   
     end.             
  end  method.
  method public void GetCrit(output oMinCrit as character, output oDiscont as character ):
    if available tt-promocriterion
    then assign 
       oMinCrit = string(tt-promocriterion.mincrit)
       oDiscont = string(tt-promocriterion.Discont)
    .
    else assign
       oMinCrit = "?"
       oDiscont = "?".
       
  end method.
  method public logical setCrit(input iAdd as logical,input iMinCrit as decimal ,input iDiscont as decimal  ):
    define buffer buf_promocriterion for tt-promocriterion.
    find first buf_promocriterion where buf_promocriterion.mincrit eq iMinCrit and recid(buf_promocriterion) ne recid(tt-promocriterion)
    no-error.
    if available buf_promocriterion 
    then do:
      message "Уже есть запись с таким минимальным значением критерия " iMinCrit
      view-as alert-box.
      return false.
    end.
    if iAdd 
    then do:
       create  tt-promocriterion.
       assign
          tt-PromoCriterion.id       = m-local-sec
          m-local-sec                = m-local-sec - 1
       .
          
    end.
    assign
       tt-PromoCriterion.idAction = tt-promoaction-one.id
       tt-PromoCriterion.mode     = {&h-create}
       tt-promocriterion.mincrit  =  iMinCrit
       tt-promocriterion.discont  =  iDiscont
       
    .
    release tt-PromoCriterion.
    CreateCrits().
    return yes. 
  end method.
  
  method public logical addObject():
    define variable v-user-select as logical   no-undo .
    define variable v-sub as class PromoObjectSub no-undo.
  //define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
     run gbl/uobjsman.p (parparentproc,
                         v-cntxt-db-num,
                         v-cntxt-userid,
                         v-host-code,
                         v-cntxt-obj-type,
                         v-cntxt-obj-code,
                         output v-user-select ,
                         output table tt-obj ).
    if   v-user-select
    then do:                   
      v-sub =  new PromoObjectSub().                    
      for each tt-obj:
         find first tt-promoObject where tt-promoObject.obj-code eq tt-obj.obj-code
                                     and tt-promoObject.obj-type eq tt-obj.obj-type
         no-error.
         if not available tt-promoObject
         then do:
            v-sub:obj-code = tt-obj.obj-code.
            v-sub:obj-type = tt-obj.obj-type.
            create          tt-promoObject.
            assign
             tt-promoObject.id       = m-local-sec
             m-local-sec             = m-local-sec - 1
             tt-PromoObject.idaction       = tt-promoaction-one.id
             tt-PromoObject.mode           = {&h-create}
             tt-PromoObject.db-num         = v-sub:db-num
             tt-PromoObject.obj-code       = v-sub:obj-code
             tt-PromoObject.obj-type       = v-sub:obj-type
             tt-PromoObject.FirmCode       = v-sub:FirmCode
             tt-PromoObject.FirmName       = v-sub:FirmName
             tt-PromoObject.objName        = v-sub:objName
             tt-PromoObject.objDbNum       = v-sub:objDbNum
             
           .
         end.
         
      end.
      
    end.
    return v-user-select.
    finally:
      if valid-object(v-sub) then delete object v-sub.
    end finally.      
  
   end.
   method public logical addpay():
     define variable v-pay-type-list as character no-undo.
     define variable vi as integer no-undo. 
     define variable Vflag as logical no-undo. 
     define buffer Buf_cashpay for cash-pay.    
       run ref/cashpays.w (
            INPUT parparentproc
            ,INPUT "b-sel,b-mark":U
            ,input {&all}
            ,input v-host-code
            ,input v-cntxt-obj-type
            ,input v-cntxt-obj-code
            ,OUTPUT v-pay-type-list
            ).
       do vi = 1 to num-entries(v-pay-type-list):
         find first Buf_cashpay where recid(Buf_cashpay) eq integer (entry(vi,v-pay-type-list)) no-lock no-error.
         if available Buf_cashpay
         then do:        
            find first tt-cashpay where tt-cashpay.cdpay-code = Buf_cashpay.cdpay-code 
                                    and tt-cashpay.curr-code  = Buf_cashpay.curr-code  
            no-lock no-error.
            if not available tt-cashpay
            then do:
               create tt-cashpay.
               buffer-copy Buf_cashpay to tt-cashpay.
               Vflag = yes.
            end.
         end.
       end.  
       return Vflag.    
    end.
    
    method public void saveTypediscont(isolo  as logical,
                                        iCombo as logical,
                                        ivisa  as logical):
       if available tt-promoaction-one
       then assign
          tt-promoaction-one.TypeDiscontsolo  = isolo
          tt-promoaction-one.TypeDiscontcombo = icombo
          tt-promoaction-one.TypeDiscontvisa  = ivisa
       .
    end.
    
    method  public logical chek1CERP(): 
       define variable conf-par as character no-undo.
       define variable mode-erprn as logical no-undo.
       define variable par-type as character no-undo.
       { gbl/conf-rd.i
         "'is-erpRN'"
          0
          "''"
          0
          "''"
          "''"
          "''"
          NO
          conf-par
          par-type
          no-error
          }
       if not error-status:error and conf-par = "yes":U then mode-erprn = yes.
       else mode-erprn = no.
       
       return mode-erprn .
    end method.

   method private logical refPromoMark ():
      define variable v-sub as class promoActionsub no-undo .
      define buffer buf_PromoGift  for ub.PromoGift .
      define buffer buf_PromoGoods for ub.PromoGoods .
      define buffer buf_goods-attr for ub.goods-attr .
      define variable v-ban-recipes as logical no-undo .
      v-sub = cast(tt-promoaction.sub, ibs.th.ref.promo.PromoActionSub) .
      m-storage:refreshObj(v-sub).
      define variable ObjSrv as class ibs.th.gbl.sys.objsrv no-undo.
    
    run gbl/getobjsrvhndl.p (input-output ObjSrv).
   if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):IsBanRecipes then v-ban-recipes = true . 
   if v-ban-recipes then do:
/*      for each buf_PromoGoods no-lock where buf_PromoGoods.idAction = v-sub:ID and buf_PromoGoods.db-num = v-sub:db-num:*/
/*         if can-find (first buf_goods-attr no-lock where buf_goods-attr.gds-code = buf_PromoGoods.gds-code and          */
/*            buf_goods-attr.attr-code = {&attr-mark-type} and buf_goods-attr.attr-value <> "not-type" and                */
/*            buf_goods-attr.attr-value <> "") then                                                                       */
/*         do:                                                                                                            */
/*            return true.                                                                                                */
/*         end.                                                                                                           */
/*      end.                                                                                                              */
      for each buf_PromoGift no-lock where buf_PromoGift.idaction = v-sub:ID and buf_PromoGift.db-num = v-sub:db-num:
         if can-find (first buf_goods-attr no-lock where buf_goods-attr.gds-code = buf_PromoGift.gds-code and 
            buf_goods-attr.attr-code = {&attr-mark-type} and buf_goods-attr.attr-value <> "not-type" and 
            buf_goods-attr.attr-value <> "") then 
         do:
            return true.
         end.         
      end.  
   end.
   else return false .      
   end.
   
  
end class .
