/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт сообщения с чеком в 1С ERPRN check

Автор: Молотков Сергей Михайлович
Дата создания: 03/11/17
Author: Molotkov Sergey
Creation date: 03/11/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.enum-chk-type.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
/*block-level on error undo, throw.*/

class ibs.th.bge.1crn.subjects.check implements iexpsubject:

  { cmp/str-glbl.i class }
  { str/lib-trn.i  class }
  { cmp/library.i  class }
  { gbl/objsrv.i def }
  { utl/gtin.i class }
  { ref/extclass.i }
  { ref/chk-type-desc.i }
  { rep/r-tranfuel.i class private}

define private temp-table ttTranFuel no-undo
   field line-num     as integer
   field trn-num      as integer
   field db-num       as integer
   field uuid         as character
   field uuid-cheq    as character
   field chk-type     as integer
   field chk-date     as date
   field chk-time     as integer
   field trk-num      as integer
   field trn-start    as datetime
   field trn-end      as datetime
   field trn-prnt     as integer
   field trn-prnt-trk as integer
   field trn-chld     as integer
   field trn-chld-trk as integer
index pi db-num uuid uuid-cheq
index si trn-start trn-end chk-date chk-time
.

define private temp-table tt-recid-TranFuel no-undo
   field rec-id as recid
.

  define property Msg as character no-undo
    get:
      return trim (Msg, {&new-line}).
    end.
    private set (inArg as char):
      Msg = Msg + {&new-line} + inArg.
    end.

  /* 16/VIII-2018 надо вокруг чеков сделать еще одну секцию с номером смены.
     Связано это с тем, что если в пакет попадает несколько раз одна и таже смена,
     1С уже не понимает какой набор чеков был последний, т.к. они все валятся в один раздел.
  */
  &scop tag-interface 'sales-p-shifts':U
  define property InitSecTag as character no-undo init {&tag-interface}
    get.

  define public property sendTableName  as character  no-undo
    get.
    private set.
   
  define public property sendOldRowid as rowid  no-undo
    get.
    set.

  define public property sendNewRowid as rowid  no-undo
    get.
    set.

  define property BufHandle as handle no-undo
    get.
    set.

  define private variable libFindtank as class ibs.th.str.findtank no-undo . /* обёртка для findtank.i */
  
  define private variable mRepShiftNum  as integer no-undo.
  define private variable mRepShiftDate as date    no-undo.
  
        
  &scop tag-shift     'shift':U
  &scop tag-checks    'checks':U

  &scop tag-message   'check':U
  &scop tag-section1  'chk-gds':U
  &scop tag-item1     'chk-gd':U
  &scop tag-section1-a 'chk-trns':U
  &scop tag-item1-a    'chk-trn':U
  &scop tag-section2  'chk-pays':U
  &scop tag-item2     'chk-pay':U
  &scop tag-section3  'chk-discnts':U
  &scop tag-item3     'chk-discnt':U
  &scop tag-section4  'chk-bonus-ps':U
  &scop tag-item4     'chk-bonus-p':U
  &scop tag-section5  'chk-bonus-ms':U
  &scop tag-item5     'chk-bonus-m':U
  &scop tag-section6  'chk-pays-r':U
  &scop tag-item6     'chk-pay-r':U
  &scop tag-section7  'chk-promos':U
  &scop tag-item7     'chk-promo':U
  constructor public check ():
     super().
     libFindtank = new ibs.th.str.findtank ().
  end constructor.
  
  /*------------------------------------------------------------------------------
   Purpose: выгружает несколько чеков со всеми потрохами в контекст контейнера SAX-writer
   Notes:   обязательный метод
   Param:   insw = create sax-writer
  ------------------------------------------------------------------------------*/
  method public void CrContentToSW (insw as handle):
     { gbl/objsrv.i get}
  
    define variable v-fld-host-code  as handle no-undo .
    define variable v-fld-obj-type   as handle no-undo .
    define variable v-fld-obj-code   as handle no-undo .
    define variable v-fld-shift-date as handle no-undo .
    define variable v-fld-shift-num  as handle no-undo .
    define variable v-host-code      as integer no-undo .
    define variable v-obj-type       as character no-undo .
    define variable v-obj-code       as integer no-undo .
    define variable v-shift-date     as date no-undo .
    define variable v-shift-num      as integer no-undo .
    define variable v-user-name      as character no-undo .
    define variable v-inkas-dtime    as datetime no-undo .
    define variable v-en-chktype     as enum-chk-type no-undo .
    define buffer chk-doc-attr for ub.chk-doc-attr.
    /* 16/VIII-2018 - добавлена секция <shift>
Поля из inkas :
    define variable v-fld-inkas-date as handle no-undo .
    define variable v-fld-inkas-time as handle no-undo .
    define variable v-inkas-date     as date no-undo .
    define variable v-inkas-time     as integer no-undo .
      v-fld-inkas-date = BufHandle:buffer-field( "fact-date":U   )
      v-fld-inkas-time = BufHandle:buffer-field( "sys-time-int":U   )
      v-inkas-date     = v-fld-inkas-date:buffer-value
      v-inkas-time     = v-fld-inkas-time:buffer-value

    define variable v-fld-inkas-code as handle no-undo .
    define variable v-inkas-code     as character no-undo .
      v-fld-inkas-code = BufHandle:buffer-field( "inkas-code":U )
      v-inkas-code     = v-fld-inkas-code:buffer-value

    define variable v-fld-inkas-oper as handle no-undo .
    define variable v-inkas-operator as character no-undo .
      v-fld-inkas-oper = BufHandle:buffer-field( "user-name":U  )
      v-inkas-operator = v-fld-inkas-oper:buffer-value
    */
    define buffer buf_inkas          for ub.inkas .
    define buffer over_buf_chk-doc   for ub.chk-doc .

    Msg = "" .
    if not valid-handle(BufHandle) then undo, throw new Progress.Lang.AppError("Отсутствует запись СМЕНЫ shift_obj с документами продажи") .
    
    sendTableName = BufHandle:table.
    sendOldRowid  = BufHandle:rowid.
  if BufHandle:table <> "chk-doc" then do:  
    assign
      v-fld-host-code  = BufHandle:buffer-field( "host-code":U  ) 
      v-fld-obj-type   = BufHandle:buffer-field( "obj-type":U  )
      v-fld-obj-code   = BufHandle:buffer-field( "obj-code":U  )
      v-fld-shift-date = BufHandle:buffer-field( "shift-date":U  )
      v-fld-shift-num  = BufHandle:buffer-field( "shift-num":U  )
    .
    assign
      v-host-code  = v-fld-host-code:buffer-value  
      v-obj-type   = v-fld-obj-type:buffer-value
      v-obj-code   = v-fld-obj-code:buffer-value
      v-shift-date = v-fld-shift-date:buffer-value
      v-shift-num  = v-fld-shift-num:buffer-value
    .
    
    insw:start-element ({&tag-shift}) .
    /* обязательность не указана; выгружаем по аналогии с секцией <checks>
       (не спрашивайте, зачем выгружать дату и номер смены и внутри чека, и снаружи:
        так надо, чтобы программисты из 1с смогли это понять)
    */
    if v-shift-date = ? then insw:write-empty-element ( "shift-date":U ) . /* Дата смены (Дата) */
                        else insw:write-data-element (  "shift-date":U,  iso-date(v-shift-date)  ).
    if v-shift-num  = ? then insw:write-empty-element ( "shift-num":U  ) .  /* Номер смены (Число) */
                        else insw:write-data-element (  "shift-num":U,   string(v-shift-num)     ).
    insw:start-element ({&tag-checks}) .
    
    for each buf_inkas no-lock
       where buf_inkas.host-code  = v-host-code 
         and buf_inkas.obj-type   = v-obj-type
         and buf_inkas.obj-code   = v-obj-code
         and buf_inkas.shift-date = v-shift-date
         and buf_inkas.shift-num  = v-shift-num
         and buf_inkas.status_    = {&fact}
      /* and buf_inkas.fact-date  = buf_shift-obj.shift-date - не всегда, и не факт; не проверялось */
    :
    /* 17/I-2018 Operator – надо выводить ФИО пользователя */
	{ gbl/usrfulnm.i
      buf_inkas.user-name
      v-user-name }
      
    /* 28/XI-2017 при выгрузке чеков надо еще запускать размаз чеков, иначе chk-pay-r нет. */
    run rep/rpychk0.p ( input "bgepych2"
                      , input v-obj-type
                      , input v-obj-code
                      ,input ? /*p-date-from*/
                      ,input ? /*p-date-to*/
                      ,input ? /*p-shift-date-from*/
                      ,input ? /*p-shift-date-to*/
                      ,input ? /*p-shift-num-start*/
                      ,input ? /*p-shift-num-end*/
                      , input buf_inkas.inkas-code
                      ) .
                      
    v-inkas-dtime = datetime(buf_inkas.fact-date, buf_inkas.sys-time-int * 1000) .
    for each over_buf_chk-doc no-lock
       where over_buf_chk-doc.out-code = buf_inkas.inkas-code:
      /* 19/XII-2017 выгружаем только те типы, которые указаны в протоколе */
      v-en-chktype = enum-chk-type:GetEnum(over_buf_chk-doc.chk-type) no-error .
      if not error-status:error then
        CrContentInterfaceToSW (insw, buffer over_buf_chk-doc, v-inkas-dtime, v-user-name,
          v-host-code, v-obj-type, v-obj-code) .
    end . /* end_of for_each buf_chk-doc */

    for each chk-doc-attr where attr-code = 'CHFlag1S' and attr-value = 'no' exclusive-lock:
       for each over_buf_chk-doc  no-lock  where over_buf_chk-doc.doc-code = chk-doc-attr.doc-code:
          v-en-chktype = enum-chk-type:GetEnum(over_buf_chk-doc.chk-type) no-error .
          if not error-status:error 
          then
             CrContentInterfaceToSW (insw, 
                                     buffer over_buf_chk-doc, 
                                     v-inkas-dtime, 
                                     v-user-name,
                                     v-host-code, 
                                     v-obj-type, 
                                     v-obj-code) .
       end.
       delete chk-doc-attr.
    end.
  end. /* end_of for_each_inkas */
  insw:end-element ({&tag-checks}) .
  insw:end-element ({&tag-shift}) .

 END.   /*   if BufHandle:table <> "chk-doc" then do:   */


if BufHandle:table = "chk-doc" then do:    /* отдельная выгрузка чеков  открытия и закрытия с типом 40 и 13 */ 
      define variable v-curr-sv-date as date no-undo .
      run gbl/getcurdt.p  (output v-curr-sv-date ) .

    assign
      v-fld-obj-type   = BufHandle:buffer-field( "obj-type":U  )
      v-fld-obj-code   = BufHandle:buffer-field( "obj-code":U  )
      v-fld-shift-num  = BufHandle:buffer-field( "shift-num":U  )
    .

    assign
      v-obj-type   = v-fld-obj-type:buffer-value
      v-obj-code   = v-fld-obj-code:buffer-value
      v-shift-date = v-curr-sv-date
      v-shift-num  = v-fld-shift-num:buffer-value
    .

    find first shift-obj where shift-obj.status_ = "ТЕК" and shift-obj.obj-code = v-obj-code no-error.
    IF AVAILABLE shift-obj THEN v-shift-num = shift-obj.shift-num.
    else v-shift-num = 0.
    insw:start-element ({&tag-shift}) .

    insw:write-data-element (  "shift-date":U,  iso-date(v-shift-date) ).
    insw:write-data-element (  "shift-num":U,   string(v-shift-num)    ).

    insw:start-element ({&tag-checks}) .
    for each chk-doc-attr where chk-doc-attr.attr-code = 'CHFlag1S' and chk-doc-attr.attr-value = 'no' exclusive-lock:
       for each over_buf_chk-doc  no-lock  where 
                over_buf_chk-doc.doc-code = chk-doc-attr.doc-code:
          if over_buf_chk-doc.chk-type eq 40 or over_buf_chk-doc.chk-type eq 13 then
          do:
             v-en-chktype = enum-chk-type:GetEnum(over_buf_chk-doc.chk-type) no-error . 
             if not error-status:error then 
             CrContentInterfaceToSW (insw, buffer over_buf_chk-doc, v-inkas-dtime, v-user-name,
             v-host-code, v-obj-type, v-obj-code) .
             delete chk-doc-attr.
          end.
       end. 
    end .   
insw:end-element ({&tag-checks}) . 
insw:end-element ({&tag-shift}) . 

END. /*   if BufHandle:table = "chk-doc" then do:   */


    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg = "" then Msg = exAppErrors:GetMessage(1) .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) . 
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error occurred..." .
      undo, throw exAnyErrors .
    end catch .

    
  end method . /* end_of CrContentToSW */

  /*------------------------------------------------------------------------------
   Purpose: выгружает содержимое чека и вложенные секции в контекст контейнера SAX-writer
   Param:   insw = create sax-writer
  ------------------------------------------------------------------------------*/
  method private void CrTTFuelTran (buffer p-buf_chk-doc for ub.chk-doc):
   
   define buffer chk-doc-attr  for chk-doc-attr.
   define buffer chk-gds       for chk-gds.
   define buffer b-chk-gds     for chk-gds.
   define buffer bar-code      for bar-code.
   define buffer goods         for goods.
   define buffer prod-bc       for prod-bc.
   define buffer tran-fuel     for tran-fuel.
   define buffer b-tran-fuel   for tran-fuel.
   define buffer b2-tran-fuel  for tran-fuel.
   define buffer b-ttTranFuel  for ttTranFuel.

   define variable vRecId as recid   no-undo.
      
   empty temp-table ttTranFuel.
   for each chk-doc-attr where
            chk-doc-attr.doc-code  = p-buf_chk-doc.doc-code
        and chk-doc-attr.attr-code = "CheckId"
   no-lock,
       each chk-gds where
            chk-gds.doc-code = p-buf_chk-doc.doc-code
   no-lock:
      /* Обрабатываем только строку чека */
      if can-find(first ttTranFuel where ttTranFuel.uuid-cheq = chk-doc-attr.attr-value) then
         next.

      empty temp-table tt-recid-TranFuel.
      for first bar-code where
                bar-code.b-code = chk-gds.b-code
      no-lock,
          first goods where
                goods.gds-code = bar-code.gds-code
      no-lock:
         /* Находим транзакции с коротким кодом товара */
         for first prod-bc where
                   prod-bc.b-code = chk-gds.b-code
         no-lock,
             each tran-fuel where
                  tran-fuel.uuid-cheq = chk-doc-attr.attr-value
              and tran-fuel.fuel-code = integer(prod-bc.b-str)
         no-lock:
            create tt-recid-TranFuel.
            tt-recid-TranFuel.rec-id = recid(tran-fuel).
         end.
         /* Находим транзакции с полным кодом товара */
         for each tran-fuel where
                  tran-fuel.uuid-cheq = chk-doc-attr.attr-value
              and tran-fuel.fuel-code = goods.gds-code
         no-lock:
            create tt-recid-TranFuel.
            tt-recid-TranFuel.rec-id = recid(tran-fuel).
         end.
      end.
      
      for each tt-recid-TranFuel,
         first tran-fuel where
               recid(tran-fuel) = tt-recid-TranFuel.rec-id
      no-lock:

         find first tt-rep where
                    tt-rep.uuid      = tran-fuel.uuid
                and tt-rep.uuid-cheq = tran-fuel.uuid-cheq
         no-error.
         
         create ttTranFuel.
         assign
            ttTranFuel.line-num     = chk-gds.line-num
            ttTranFuel.trn-num      = tran-fuel.tran-num
            ttTranFuel.trn-start    = if avail tt-rep then
                                         tt-rep.datetime-beg
                                      else
                                         tran-fuel.date-beg + timezone * 60000
            ttTranFuel.trn-end      = if avail tt-rep then
                                         tt-rep.datetime-end
                                      else
                                         tran-fuel.date-end + timezone * 60000
            ttTranFuel.trk-num      = tran-fuel.trk-num + 1
            ttTranFuel.db-num       = tran-fuel.db-num
            ttTranFuel.uuid         = tran-fuel.uuid
            ttTranFuel.uuid-cheq    = tran-fuel.uuid-cheq
            ttTranFuel.chk-type     = p-buf_chk-doc.chk-type
            ttTranFuel.chk-date     = p-buf_chk-doc.chk-date
            ttTranFuel.chk-time     = p-buf_chk-doc.chk-time
            .

         /* Для чека ПеревТрнзкц создаем вторую транзакцию */
         if p-buf_chk-doc.chk-type = 16 then do:
            find first b-chk-gds where
                       b-chk-gds.doc-code =  p-buf_chk-doc.doc-code
                   and b-chk-gds.line-num <> chk-gds.line-num
            no-lock no-error.
            if avail b-chk-gds then do:
               find first b-tran-fuel where
                          b-tran-fuel.db-num    =  tran-fuel.db-num
                      and b-tran-fuel.uuid      =  tran-fuel.uuid
                      and b-tran-fuel.uuid-cheq <> tran-fuel.uuid-cheq
               no-lock no-error.
               if avail b-tran-fuel then do:
                  find first b2-tran-fuel where
                             b2-tran-fuel.db-num    =  b-tran-fuel.db-num
                         and b2-tran-fuel.uuid-cheq =  b-tran-fuel.uuid-cheq
                         and b2-tran-fuel.uuid      <> b-tran-fuel.uuid
                  no-lock no-error.
                  if avail b2-tran-fuel then do:
                     find first tt-rep where
                                tt-rep.uuid      = b2-tran-fuel.uuid
                            and tt-rep.uuid-cheq = b2-tran-fuel.uuid-cheq
                     no-error.
                     
                     create ttTranFuel.
                     assign
                        ttTranFuel.line-num     = b-chk-gds.line-num
                        ttTranFuel.trn-num      = b2-tran-fuel.tran-num
                        ttTranFuel.trn-start    = if avail tt-rep then
                                                     tt-rep.datetime-beg
                                                  else
                                                     b2-tran-fuel.date-beg + timezone * 60000
                        ttTranFuel.trn-end      = if avail tt-rep then
                                                     tt-rep.datetime-end
                                                  else
                                                     b2-tran-fuel.date-end + timezone * 60000
                        ttTranFuel.trk-num      = b2-tran-fuel.trk-num + 1
                        ttTranFuel.db-num       = b2-tran-fuel.db-num
                        ttTranFuel.uuid         = b2-tran-fuel.uuid
                        ttTranFuel.uuid-cheq    = tran-fuel.uuid-cheq
                        ttTranFuel.chk-type     = p-buf_chk-doc.chk-type
                        ttTranFuel.chk-date     = p-buf_chk-doc.chk-date
                        ttTranFuel.chk-time     = p-buf_chk-doc.chk-time
                        .
                  end.
               end.
            end.
         end.
      end.
   end.
   
   for each ttTranFuel:
      find first tt-rep where
                 tt-rep.uuid      = ttTranFuel.uuid
             and tt-rep.uuid-cheq = ttTranFuel.uuid-cheq
      no-error.
      if avail tt-rep then
         assign
            ttTranFuel.trn-start = tt-rep.datetime-beg
            ttTranFuel.trn-end   = tt-rep.datetime-end
            .
   end.
   
   /* Заполнение cвязей родительских и дочерних транзакций */
   vRecId = ?.
   for each ttTranFuel
   break
      by ttTranFuel.trn-start
      by ttTranFuel.trn-end
      by ttTranFuel.chk-date
      by ttTranFuel.chk-time:
      if vRecId <> ? then do:
         find first b-ttTranFuel where
                    recid(b-ttTranFuel) = vRecId
         no-error.
         if avail b-ttTranFuel then do:
            assign
               b-ttTranFuel.trn-chld     = ttTranFuel.trn-num
               b-ttTranFuel.trn-chld-trk = ttTranFuel.trk-num
               ttTranFuel.trn-prnt       = b-ttTranFuel.trn-num
               ttTranFuel.trn-prnt-trk   = b-ttTranFuel.trk-num
               .
         end.
      end.
      
      vRecId = recid(ttTranFuel).
   end.
   
  end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	destructor public check ( ):
       if valid-object(libFindtank) then delete object libFindtank .
    
	end destructor.


  /*------------------------------------------------------------------------------
   Purpose: выгружает содержимое чека и вложенные секции в контекст контейнера SAX-writer
   Param:   insw = create sax-writer
  ------------------------------------------------------------------------------*/
  method private void CrContentInterfaceToSW (insw as handle
                                          , buffer p-buf_chk-doc for ub.chk-doc
                                          , input p-inkas-dtime    as datetime
                                          , input p-inkas-operator as character
                                          , input p-host-code      as integer
                                          , input p-obj-type       as character
                                          , input p-obj-code       as integer
                                          ) :

    define buffer buf_dis-card     for ub.dis-card .
    define buffer buf_chk-doc-attr for ub.chk-doc-attr .
    define buffer chk-doc-attr for ub.chk-doc-attr .
    define buffer buf_chk-gds      for ub.chk-gds .
    define buffer buf_bar-code     for ub.bar-code .
    define buffer buf_goods        for ub.goods .
    define buffer buf_chk-gds-attr for ub.chk-gds-attr .
    define buffer buf_chk-pay      for ub.chk-pay .
    define buffer buf_chk-pay-attr for ub.chk-pay-attr .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr . 
    define buffer buf_chk-discnt   for ub.chk-discnt .
    define buffer bf_chk-discnt    for ub.chk-discnt .
    define buffer buf_chk-gds-pay  for ub.chk-gds-pay .
    define buffer buf_OperServ     for ub.OperServ .
    define buffer buf_cash-desk-attr for ub.cash-desk-attr .
    define buffer buf_clients      for ub.clients .
    define buffer buf_cash-desk    for ub.cash-desk .
    define buffer buf_doc-line     for ub.doc-line .
    define buffer buf_parts        for ub.parts .
    define buffer buf_marking-chk  for ub.marking-chk .
    define variable v-is-petrolium as logical no-undo . /* true = топливо */
    define variable v-price-azs    as decimal no-undo .
    define variable v-is-pieces    as logical no-undo .
    define variable v-loc1         as character no-undo . /* номер резервуара */
    define variable v-spump        as character no-undo . /* номер ТРК */ 
    define variable v-snozzle-code as character no-undo . /* номер пистолета */
    define variable v-key-one      as integer no-undo . /* для поиска оператора сотовой связи */
    define variable v-is-nds       as integer no-undo . /* 0/1 признак распределения НДС по платежу */
    define variable v-ex-Nds       as logical no-undo.
    define variable v-chk-pay-is-nds as logical no-undo . /* true: в чеке есть платёж с is-nds=1 */
    define variable v-sum-s        as decimal no-undo .
    define variable v-parts-qnty   as decimal no-undo .
    define variable v-marking      as character no-undo .
    define variable v-sum-promo    as decimal no-undo . /* сумма скидки по промо НП */
    define variable v-pcnt-promo   as decimal no-undo . /* процент скидки по промо НП */    
    define variable v-b-code       as integer no-undo. /* код топливного товара */
    define variable v-gds-qnty     as decimal no-undo. /* кол-во топливного товара */
    define variable v-disc-promo-id as integer no-undo. /* код промоакции */
    define variable v-disc-promo-count as int no-undo. /* сработала ли промоакция */
    define variable v-line-num-promo as int no-undo. /* код строки чека с промоакцией */
    
    insw:start-element ({&tag-message}) .

    /* обязательность 1-1 */
    if p-buf_chk-doc.shift-date = ? then insw:write-empty-element ( "shift-date":U ) . /* Дата смены (Дата) */
    else insw:write-data-element (  "shift-date":U,  iso-date(p-buf_chk-doc.shift-date)  ). 

    insw:write-data-element (  "shift-num":U,       string(if p-buf_chk-doc.shift-num = 0 then p-buf_chk-doc.shift-name else string(p-buf_chk-doc.shift-num))   ). /* Номер смены (Число) */
    insw:write-data-element (  "chk-num":U,         string(p-buf_chk-doc.chk-num)     ). /* Номер чека на кассе (Число) */
    insw:write-data-element (  "cb-num":U,          string(p-buf_chk-doc.pay-desk)    ). /* Номер кассы (Число) */
    insw:write-data-element (  "chk-id":U,                 p-buf_chk-doc.doc-code     ). /* Номер чека в GC (Строка) */
    
    /* 29/III-2019  признак какая это касса: ТСО, обычная касса или мобильная*/
    define variable v-c-type as integer no-undo .
    v-c-type = 0 .
    find first buf_clients no-lock
         where buf_clients.obj-code = p-obj-code
           and buf_clients.obj-type = p-obj-type no-error .
    if available buf_clients then do :
      find first buf_cash-desk no-lock
           where buf_cash-desk.db-num   = buf_clients.db-num
             and buf_cash-desk.obj-code = p-obj-code
          /* and buf_cash-desk.pos-type = в чеке отсутствует тип кассы */
             and buf_cash-desk.cash-num = p-buf_chk-doc.pay-desk no-error .
      if available buf_cash-desk then do :
        v-c-type = buf_cash-desk.device-kind .  
      end .
    end .
    insw:write-data-element (  "c-type":U,  string(v-c-type)  ). /* признак какая это касса */
    
    
    
    /* обязательность 0-1 для del-l, ext-num, direct-chk-num */
    
    /* 04/XII-2017 при удалении продажи чеки у нас не удаляются: они просто остаются непривязанными к продаже.
                   При удалении продажи надо посылать чеки с del-l = 1 (в протоколе поля del-l раньше не было) */
    /* 07/XII-2017 теперь чеки выгружаем вместе с закрытием смены, и никакое удаление продаж на них не влияет */

    /* 17/XI-2017 Добавляем поле «ext-num» в шапку.
       В поле хранятся внешние номера, в нашем случае номер карты активации, с типом платежа «Активация». */
    if p-buf_chk-doc.doc-num > "" then
    insw:write-data-element (  "ext-num":U,         p-buf_chk-doc.doc-num   ). /* Внешний номер. В случае типа платежа «активация» номер карты активации (Строка) */
    
    /* 17/XI-2017 Добавляем поле «direct-chk-num» в шапке.
       В этом поле будет номер прямого чека. */
    if p-buf_chk-doc.doc-num2 > "" then
    insw:write-data-element (  "direct-chk-num":U,  p-buf_chk-doc.doc-num2  ). /* Номер прямого чека (Строка) */
    
    /* обязательность 1-1 */
    if p-buf_chk-doc.chk-date = ? then insw:write-empty-element( "chk-date":U ). /* Дата чека (Дата) */
    else insw:write-data-element (  "chk-date":U,  iso-date(p-buf_chk-doc.chk-date)  ).        
        
    insw:write-data-element (  "chk-time",     timeFormat(p-buf_chk-doc.chk-time)    ). /* Время чека (Время) */
    insw:write-data-element (  "cashier",          string(p-buf_chk-doc.cashier)     ). /* Код кассира (Строка) */
    insw:write-data-element (  "z-num",            string(p-buf_chk-doc.z-number)    ). /* Номер z-отчета (Число) */
    insw:write-data-element (  "chk-type", left-trim(string(p-buf_chk-doc.chk-type, ">9"))    ). /* Тип чека (Число, enum) */
    insw:write-data-element (  "netto",   left-trim(string(p-buf_chk-doc.netto,   "->>>>>>>>9.9<"))  ). /* Сумма чека нетто в валюте продаж. Выручка со скидками. (Число) */
    insw:write-data-element (  "tot-doc", left-trim(string(p-buf_chk-doc.tot-doc, "->>>>>>>>9.9<"))  ). /* Сумма брутто по чеку в валюте продаж. Сумма по текущей розничной цене (Число) */

    /* обязательность 0-1 */
    if p-buf_chk-doc.chk-type <> 13 and p-buf_chk-doc.chk-type <> 40     then
     do:
        find first buf_chk-doc-attr where buf_chk-doc-attr.doc-code  eq p-buf_chk-doc.doc-code
                                  and buf_chk-doc-attr.attr-code eq "CHMgrKey"
             no-lock no-error.
       if avail buf_chk-doc-attr
       then
       insw:write-data-element( "CHMgrKey",  buf_chk-doc-attr.attr-value).

    end.


    /* Тип возвратных операций */

    if p-buf_chk-doc.chk-type <> 13 and p-buf_chk-doc.chk-type <> 40     then
     do:

	  find first chk-doc-attr where chk-doc-attr.doc-code = p-buf_chk-doc.doc-code
	    and chk-doc-attr.attr-code = 'CHFlag1' no-lock no-error.
	    if available chk-doc-attr then 
	    do:   
	      insw:write-data-element (  "CHFlag1",  string(chk-doc-attr.attr-value)  ) . /* Тип возвратных операций */  
	      if chk-doc-attr.attr-value = "0" then
	        insw:write-data-element (  "Dry-chk-th",  string(chk-doc-attr.attr-value)  ) . /* Сухой чек */      
	    end. 
    end.


    /* 28/XI-2017 term-num будет строкой, поэтому пустой можно, и необязательный. */
    find first buf_chk-doc-attr where buf_chk-doc-attr.doc-code  eq p-buf_chk-doc.doc-code
                                  and buf_chk-doc-attr.attr-code eq "CHNumberKKT"
             no-lock no-error.
    if avail buf_chk-doc-attr
    then
       insw:write-data-element( "CHNumberKKT",  buf_chk-doc-attr.attr-value).
    find first buf_chk-doc-attr where buf_chk-doc-attr.doc-code  eq p-buf_chk-doc.doc-code
                                  and buf_chk-doc-attr.attr-code eq "CHNumberFN"
             no-lock no-error.
    if avail buf_chk-doc-attr
    then
       insw:write-data-element( "CHNumberFN",  buf_chk-doc-attr.attr-value).
       
    if "" > "" then insw:write-data-element ( "term-num", "" ).  /* Номер терминала POS (Строка) */

    if p-buf_chk-doc.d-card > "" then do:
      insw:write-data-element (  "dc-num":U,     p-buf_chk-doc.src-d-card     ). /* Номер ДК (Строка) */
      find first buf_dis-card no-lock
           where buf_dis-card.d-card = p-buf_chk-doc.d-card no-error .
      if available buf_dis-card then do:
        /* обязательность 0-1 */
        if buf_dis-card.card-num > 0 then
      insw:write-data-element (  "dc-name":U,    string(buf_dis-card.type)  ). /* Наименование ДК (Строка) */
      end.
    end.  

    /* 16/I-2018 в каждый чек добавить поля с номером и датой документа «Продажа» в нашей системе,
                 и ФИО оператора, который оформлял документ */
    if p-inkas-operator > "" then
      insw:write-data-element (  "operator":U,   p-inkas-operator           ). /* Оператор создавший документ (Строка) */
    if p-buf_chk-doc.out-code > "" then // chk-doc.out-code хранит значение из inkas.inkas-code
      insw:write-data-element (  "prdoc-num":U,  p-buf_chk-doc.out-code     ). /* Номер документа продажи в GC (Строка) */
    if p-inkas-dtime = ? then insw:write-data-element ("prdoc-date":U, SUBSTITUTE("&1T&2", iso-date(p-buf_chk-doc.chk-date), timeFormat(p-buf_chk-doc.chk-time) )). 
    else  insw:write-data-element (  "prdoc-date":U, iso-date(p-inkas-dtime)    ). /* Дата документа продажи в GC со временем в формате ISO (Дата) */ 


    /* 19/II-2019  Если в чеке есть платеж, с is-nds = 1, то в товарных строках НДС выгружать,
                   если нет, то НДС не выгружать совсем. */
    /* сопоставление по кодам перечня типов, согласно COMBO-BOX cb-prop из ref/cashpayi.w */
    &scoped-define is-nds-eq-1 can-do ("1,2,3,6,7", buf_cash-pay-attr.attr-value)
    v-chk-pay-is-nds = false .
    for each buf_cash-pay-attr no-lock
       where buf_cash-pay-attr.attr-code  = "cash-prop"
         and {&is-nds-eq-1} :
      if can-find (first buf_chk-pay
                   where buf_chk-pay.doc-code  = p-buf_chk-doc.doc-code
                     and buf_chk-pay.pay-code  = buf_cash-pay-attr.cdpay-code
                     and buf_chk-pay.curr-code = buf_cash-pay-attr.curr-code) then do :
        v-chk-pay-is-nds = true .
        leave .
      end .
    end .

    /* 25/IV-2019 ФПД необходимо выгрузить в чеках в обмене с 1C ERP. Обязательность 0-1 */
    find first buf_chk-doc-attr no-lock
         where buf_chk-doc-attr.doc-code  eq p-buf_chk-doc.doc-code
           and buf_chk-doc-attr.attr-code eq "CHFiscalDocSign" no-error .
    if available buf_chk-doc-attr then
      insw:write-data-element (  "fpd":U,  buf_chk-doc-attr.attr-value     ). /* Фискальный признак документа (Строка) */


    /* section1 обязательность 1-1 */
    /* 21/XII-2018 несмотря на обязательность секции с товарами,
                   1с не может проглотить файл с секцией по товарам, если в ней нет товаров
                   Поэтому секцию с товарами при отсутствии товаров не выгружаем. */
    assign               
       v-ex-Nds = no
       v-b-code = 0
       v-gds-qnty = 0
       .
    if can-find (first buf_chk-gds where buf_chk-gds.doc-code = p-buf_chk-doc.doc-code) then do:
    insw:start-element ({&tag-section1}) .
      for each buf_chk-gds no-lock
         where buf_chk-gds.doc-code = p-buf_chk-doc.doc-code :
        v-ex-Nds = v-ex-Nds or buf_chk-gds.VAT-pc eq ? or buf_chk-gds.VAT-sum-rubl eq ? . 
        insw:start-element ({&tag-item1}) .
        
        insw:write-data-element (  "line-num",  string(buf_chk-gds.line-num)  ) . /* Номер строки чека (Число) */
        
        /* обязательность 1-1 на trk-num, tank-num, trk-pnum, gd-code;
           для нетоплива trk-num, tank-num, trk-pnum создавать пустыми;
           22/XI-2017 пустые числовые поля создавать с нулями */
        find first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code no-error.
        if available buf_bar-code then do:
          /* 1. товар в goods надо найти для того, чтобы получить artic, prod-type, prod-code */
          find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
          if available buf_goods then do:
            /* 2. внутри is-petrl.i поля artic, prod-type, prod-code используются для поиска товара в goods */
            { str/is-petrl.i
              buf_goods.artic
              buf_goods.prod-type
              buf_goods.prod-code
              v-is-petrolium
              v-is-pieces
            }
            if v-is-petrolium then
            assign 
               v-b-code = buf_chk-gds.b-code
               v-gds-qnty = buf_chk-gds.src-qnty
               .
            /* 3. внутри is-petrl.i не используется поле gds-code для поиска товара в goods */
          end .
          else v-is-petrolium = false .
        end .
        else v-is-petrolium = false .
        
        if v-is-petrolium then do :
          /* номер резервуара */
          if buf_chk-gds.pl-code > 0 then v-loc1 = string (buf_chk-gds.pl-code).
          else if available buf_bar-code then do:
            v-loc1 = getTankNum
              (input p-buf_chk-doc.obj-type
              ,input p-buf_chk-doc.obj-code
              ,input buf_chk-gds.pump
              ,input buf_chk-gds.nozzle-code
              ,input buf_chk-gds.src-pl-code
              ,input buf_chk-gds.pl-code  
              ,input buf_bar-code.gds-code
              ) .
          end.
          else v-loc1 = "" .

          /* номер ТРК, номер пистолета */
          assign
            v-spump        = string(buf_chk-gds.pump)
            v-snozzle-code = string(buf_chk-gds.nozzle-code)            
          .           
        end .
        else assign
          v-loc1  = ""
          v-spump = ""
          v-snozzle-code = ""
        .
    
        insw:write-data-element (  "trk-num",  if v-spump        > "" then v-spump        else "0"  ) . /* Номер ТРК (Число) */
        insw:write-data-element (  "tank-num", if v-loc1         > "" then v-loc1         else "0"  ) . /* Номер резервуара (Число) */
        insw:write-data-element (  "trk-pnum", if v-snozzle-code > "" then v-snozzle-code else "0"  ) . /* Номер пистолета ТРК (Число) */
          
        if available buf_bar-code then insw:write-data-element (  "gd-code",  string(buf_bar-code.gds-code)  ) .
                                  else insw:write-empty-element ( "gd-code" ) . /* Код товара (Строка) */
        
        insw:write-data-element (  "qnty",  left-trim(string(buf_chk-gds.doc-qnty, "->>>>>>>9.999"))  ) . /* Количество. Для НП количество литров. (Число 15,3) */

        /* обязательность 0-1; только для топливных чеков: к объёму в литрах прикладывается вес в киллограммах */
        if v-is-petrolium and (buf_chk-gds.density > 0) then do :
          insw:write-data-element (  "wght",
            left-trim( string(buf_chk-gds.doc-qnty * buf_chk-gds.density, "->>>>>>>>9.999") )
          ) . /* Объем, кг (Число 15,3) */ 
        end.
        /* ищем спец. скидку по промо НП */
        find first buf_chk-gds-attr no-lock where                 
                   buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code       
               and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num                 
               and buf_chk-gds-attr.attr-code = "CSPromoSum"
            no-error.
        if avail buf_chk-gds-attr then v-sum-promo = dec(buf_chk-gds-attr.attr-value) no-error.
        else v-sum-promo = 0.      
        /* 18/I-2018 даже если в БД в поле sum-base лежит ? - в выгрузке всё равно должен быть 0 */
        insw:write-data-element (  "sum",
          if buf_chk-gds.sum-base = ?
          then  "0"
          else  left-trim( string(buf_chk-gds.sum-base + v-sum-promo, "->>>>>>>>9.99") )
        ) . /* Сумма (Число 15,2) */
        
        if available buf_goods
        then do :
          assign
            v-sum-s = 0
            v-parts-qnty = 0
          .
          for each buf_parts no-lock where buf_parts.out-code   = p-buf_chk-doc.out-code
                                         and buf_parts.artic      = buf_goods.artic
                                         and buf_parts.prod-code  = buf_goods.prod-code
                                         and buf_parts.prod-type  = buf_goods.prod-type :
            assign
              v-parts-qnty = v-parts-qnty + buf_parts.fact-qnty
              v-sum-s = v-sum-s + (buf_parts.fact-qnty * buf_parts.price-rubl / (1 + (buf_parts.VAT-pc / 100)))
            .
          end.
          if v-parts-qnty > 0 then v-sum-s = v-sum-s / v-parts-qnty * buf_chk-gds.doc-qnty .
          if v-sum-s <> 0
          then do :
            insw:write-data-element (  "sum-s",
              left-trim( string(v-sum-s, "->>>>>>>>9.99") )
            ) . 
          end.
          else do :
            insw:write-data-element (  "sum-s", "0" ) .
          end.
        end. /* Себестоимость (Число 15,2) */
        
        /* далее обязательность 0-1 */

        /* chk-gds.discnt - скидка относительно цены; чтобы получить скидку по строке - её надо умножать на количество */
        if (buf_chk-gds.discnt <> 0) or (v-sum-promo <> 0) then
        insw:write-data-element (  "sum-discnt",
          left-trim( string(buf_chk-gds.doc-qnty * buf_chk-gds.discnt + v-sum-promo, "->>>>>>>>>9.9<<<<<<<<<") )
        ) . /* Скидка на строку товара - с учетом всех скидок на строку и на итог (Число) */
        
        if v-is-petrolium and (buf_chk-gds.density > 0) then
        insw:write-data-element (  "dnsty",  string(buf_chk-gds.density, "9.9999999999")  ) . /* Плотность (Число 12,10) */
        
        if buf_chk-gds.pass-gds > 0 then
        insw:write-data-element (  "dry-chk",  string(buf_chk-gds.pass-gds)  ) . /* Признак сухого чека (Число 1,0) */
        
        if v-chk-pay-is-nds then do :        
          if buf_chk-gds.VAT-pc ne ? then
            insw:write-data-element (  "vat-rate",  string(buf_chk-gds.VAT-pc)        ) .
        
          if buf_chk-gds.VAT-sum-rubl ne ? then
            insw:write-data-element (  "vat",       string(buf_chk-gds.VAT-sum-rubl)  ) .
        end .
        
        /* «Оператор» это оператор сотовой связи. Берется из атрибута строки чека с кодом oss-code.
           Название подтягивается из соответствующего справочника.
        */
        find first buf_chk-gds-attr no-lock
             where buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
               and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
               and buf_chk-gds-attr.attr-code = 'oss-code':U no-error .
        if available buf_chk-gds-attr then do:
          /* 20/II-2019  В выгрузке чеков изменить получение кода ОСС.
                         Брать из нового справочника и выгружать туда внешний код ОСС.
             28/II-2019  Надо оставить operator-code operator-name и туда класть наш ID и имя из справочника ОСС.
                                   
          insw:write-data-element (  "operator-code",  buf_chk-gds-attr.attr-value  ) . /* Код оператора(эмитента) (Строка) */
          v-key-one = integer (buf_chk-gds-attr.attr-value) no-error .
          find first buf_ext-classif no-lock
               where buf_ext-classif.classif-subject = {&extclass_oss-ref}
                 and buf_ext-classif.Key#_One        = v-key-one no-error .
          if available buf_ext-classif then
            insw:write-data-element (  "operator-name",  entry(1, buf_ext-classif.charkey_two, {&delim-par})  ) . /* Наименование оператора(эмитента) (Строка) */
          */
          v-key-one = integer (buf_chk-gds-attr.attr-value) no-error .
          find first buf_OperServ no-lock where buf_OperServ.id = v-key-one no-error .
          if available buf_OperServ then do :
            /* @NOTE OperServ.ext-code всегда равен ext-code его кассовой книги */
            insw:write-data-element (  "operator-code",  buf_OperServ.ext-code  ) . /* Код оператора(эмитента) (Строка) */
            insw:write-data-element (  "operator-name",  buf_OperServ.OSname    ) . /* Наименование оператора(эмитента) (Строка) */
          end .
        end .

        /* 15/II-2019  номер сертификата «Автопомощь» */
        find first buf_chk-gds-attr no-lock
             where buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
               and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
               and buf_chk-gds-attr.attr-code = "agent-gd-code":U no-error .
        if available buf_chk-gds-attr then do:
          /* сертификаты автопомощи (для товаров pay-agent-gd):
             строка через запятую, собранная из CBCBarcode_ с кассы */
          insw:write-data-element (  "srt-BC",  buf_chk-gds-attr.attr-value  ) . /* Полный штрих-код сертификата БП «Автопомощь» (Строка) */
        end .
        
        /* 17/XI-2017 Добавляем поле «price» (цена до применения скидок) в секции «chk-gd». */
        insw:write-data-element (  "price",  left-trim(string(buf_chk-gds.src-price, "->>>>>>>>9.99"))  ) . /* Цена до применения скидок (Число 15,2) */

        /* 16/I-2018 Деление сбросов (тип чека 14) на два типа (Пролито и не пролито).
                     Для разделения используется специальный флаг в товарной строке чека. */
        if enum-chk-type:GetEnum(p-buf_chk-doc.chk-type) = enum-chk-type:entranscancell then do:
          if buf_chk-gds.write-off-code >= 0 then
            insw:write-data-element (  "prolito",  string(buf_chk-gds.write-off-code)  ). /* Признак для сбросов: 0 – не пролито; 1 – пролито. (Число, enum) */
        end .
        /* Системный код */
        insw:write-data-element (  "src-code",  string(buf_chk-gds.src-code)  ) . /* Системный код */
   
        /* 23/V-2019  тэги для табачки - цена БД и датаматрикс */
        find first buf_chk-gds-attr no-lock
             where buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
               and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
               and buf_chk-gds-attr.attr-code = "CSPriceOrig":U no-error .
        if available buf_chk-gds-attr then do:
          v-price-azs = decimal(buf_chk-gds-attr.attr-value) .
          insw:write-data-element (  "price-azs",  left-trim(string(v-price-azs, "->>>>>>>>9.99"))  ) . /* Розничная цена в соответствии с данными БД на АЗК/АЗС (Число 15,2) */
        end .
        for each buf_marking-chk no-lock where buf_marking-chk.doc-code =  buf_chk-gds.doc-code and buf_marking-chk.line-num = buf_chk-gds.line-num:
          v-marking = repSpecSimbforXlm(GetCodeIdent(buf_marking-chk.mark)).
          /*          for first buf_marking no-lock where buf_marking.mark begins v-marking :*/
          if v-marking = "" then do:
          message "Ошибка. В чеке " buf_chk-gds.doc-code  " отсутствует марка." view-as alert-box.
          end.
          if v-marking <> "" then do:
          insw:write-data-element (  "dm",  v-marking ) . /* Datamatrix (строка) */
          end.

/*          insw:write-data-element (  "dm",  addBracketForCode(v-marking) ) . /* Datamatrix (строка) */*/
        end.       
/*        find first buf_chk-gds-attr no-lock                                                                      */
/*             where buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code                                             */
/*               and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num                                             */
/*               and buf_chk-gds-attr.attr-code = "tobacco-mark":U no-error .                                      */
/*        if available buf_chk-gds-attr then do:                                                                   */
/*          insw:write-data-element (  "dm",  base64-enc(buf_chk-gds-attr.attr-value) ) . /* Datamatrix (строка) */*/
/*        end .                                                                                                    */
 
        insw:end-element ({&tag-item1}) .
      end . /* end_of for each buf_chk-gds */
    insw:end-element ({&tag-section1}) .
    end .
    /* 21/XII-2018 отменена выгрузка секции при отсутствии товаров
    else do:
      insw:write-empty-element ({&tag-item1}) .
    end .
    */
    
    /* Топливные транзакции */
    if mRepShiftDate = ? or 
       (mRepShiftDate <> p-buf_chk-doc.shift-date and mRepShiftNum <> p-buf_chk-doc.shift-num) then do:
      
       empty temp-table tt-rep.
       empty temp-table tt-all-total-rep.
       empty temp-table tt-total-rep.
       empty temp-table tt-grp.
       empty temp-table tt-pay.

       assign
          mRepShiftNum  = p-buf_chk-doc.shift-num
          mRepShiftDate = p-buf_chk-doc.shift-date
          .

       initTT(yes,
              mRepShiftDate,
              mRepShiftDate,
              mRepShiftNum,
              mRepShiftNum,
              "*",
              "*",
              "*").
       AfterCalc(yes,
                 mRepShiftDate,
                 "*",
                 "*",
                 0).
    end.
    
    CrTTFuelTran(buffer p-buf_chk-doc).

    for each ttTranFuel
    break
      by ttTranFuel.trn-start
      by ttTranFuel.trn-end
      by ttTranFuel.chk-date
      by ttTranFuel.chk-time:
         
      if first(ttTranFuel.trn-start) then
         insw:start-element ({&tag-section1-a}) .
            
      insw:start-element ({&tag-item1-a}) .
      insw:write-data-element ("line-num",     string(ttTranFuel.line-num)).
      insw:write-data-element ("trn-num",      string(ttTranFuel.trn-num)).
      insw:write-data-element ("trn-start",    iso-date(ttTranFuel.trn-start)).
      insw:write-data-element ("trn-end",      iso-date(ttTranFuel.trn-end)).
      insw:write-data-element ("trn-prnt",     string(ttTranFuel.trn-prnt)).
      insw:write-data-element ("trn-prnt-trk", string(ttTranFuel.trn-prnt-trk)).
      insw:write-data-element ("trn-chld",     string(ttTranFuel.trn-chld)).
      insw:write-data-element ("trn-chld-trk", string(ttTranFuel.trn-chld-trk)).
      insw:end-element ({&tag-item1-a}) .
      if last(ttTranFuel.trn-start) then
         insw:end-element ({&tag-section1-a}) .
    end.

    /* section2 обязательность 0-1 */
    for each buf_chk-pay no-lock
       where buf_chk-pay.doc-code = p-buf_chk-doc.doc-code
    break by buf_chk-pay.doc-code :
      if first-of(buf_chk-pay.doc-code) then insw:start-element ({&tag-section2}) .
      insw:start-element ({&tag-item2}) .
      
      insw:write-data-element (  "pay-num",  string(buf_chk-pay.line-num)  ) . /* Номер строки платежа (Число) */
      insw:write-data-element (  "pay-code",  string(buf_chk-pay.pay-code)  ) . /* Код платежа (Строка) */
      
      /* обязательность 0-1 */
      if buf_chk-pay.pay-card > "" then 
      insw:write-data-element (  "pay-card",  string(buf_chk-pay.pay-card)  ) . /* Номер платежной карты (Строка) */
      
      for first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "cpdoc":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num :      
        insw:write-data-element (  "rrn",  buf_chk-pay-attr.attr-value  ) . /* RNN платежа (Строка) */
      end.
      for first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "RRN":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num :      
        insw:write-data-element (  "rrn",  buf_chk-pay-attr.attr-value  ) . /* RNN платежа (Строка) */
      end.
      for first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "RRN-VBRR":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num :      
        insw:write-data-element (  "rrn",  buf_chk-pay-attr.attr-value  ) . /* RNN платежа (Строка) */
      end.
      for first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "QRPay":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num :      
        insw:write-data-element (  "qrpay",  buf_chk-pay-attr.attr-value  ) . /* QRPay  платежа (Строка) */
      end.
      
      find first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "CPWithdrawal":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num no-error.
      if available buf_chk-pay-attr then 
      insw:write-data-element (  "cap-sum",  left-trim(string (dec(buf_chk-pay-attr.attr-value),">>>>>>>>>>>9.99") ) ) . /* CPWithdrawal (Строка) */
      
      find first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "CPAgreement":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num no-error.
      if available buf_chk-pay-attr then 
      insw:write-data-element (  "CPAgreement",  buf_chk-pay-attr.attr-value  ) . /* CPAgreement (Строка) */
      
      insw:write-data-element (  "sum",  left-trim(string(buf_chk-pay.tot-rubl, "->>>>>>>>>9.9<<<<<<<<<"))  ) . /* Сумма платежа (либо бонус в рублевом эквиваленте) (Число) */

      /* 15/XI-2018 С учетом того, что НДС с кассы приходит во всех чеках,
                    а к учету его нужно брать только для определенных платежей,
                    нам необходимо в 1С посылать информацию о том,
                    брать НДС из чека для этого платежа или нет.
         Определять это будем по настройкам типов платежей.
         Если в типе платежа стоит, что нал, банковская карты, банковская карта оф-лайн, QR-код или авансовый платеж,
         то в тэг is-nds секции платежей ставить 1. Во всех остальных случаях - 0.
         is-nds Число(0/1) 1-1 Признак распределения НДС по платежу
      */
      /* если ндс не расчитан то не надо передавать v-is-nds вообще  */
      if not v-ex-Nds then do:
         find first buf_cash-pay-attr no-lock
              where buf_cash-pay-attr.cdpay-code = buf_chk-pay.pay-code
                and buf_cash-pay-attr.curr-code  = buf_chk-pay.curr-code
                /* входят в первичный индекс, значения переданы во входных параметрах, но:
                   скопировано из ref/cashpayi.w, и там поиск выполняется без жтих полей.  
                and buf_cash-pay-attr.host-code  = p-host-code
                and buf_cash-pay-attr.obj-type   = p-obj-type
                and buf_cash-pay-attr.obj-code   = p-obj-code
                */
                and buf_cash-pay-attr.attr-code  = "cash-prop" no-error .
         if available buf_cash-pay-attr then do :
           v-is-nds = if {&is-nds-eq-1} then 1 else 0 .
         end .
         else v-is-nds = 0 .
         insw:write-data-element (  "is-nds",    string(v-is-nds)              ) . /* Признак распределения НДС по платежу (Число 0/1) */
      end.
      for first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "sbprrn":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num :  
         insw:write-data-element (  "sbprrn",    string(buf_chk-pay-attr.attr-value)              ) .
         end .
      for first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "sbpstat":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num :  
         insw:write-data-element (  "sbpstat",    string(buf_chk-pay-attr.attr-value)              ) .
         end .
      insw:end-element ({&tag-item2}) .
      if last-of(buf_chk-pay.doc-code) then insw:end-element ({&tag-section2}) .
    end . /* end_of for each buf_chk-pay */

    /* section3 обязательность 0-1 */
    /* если в чеке есть скидка по топливному купону, у которой discnt-type = 23 и discnt-value-pcnt = 0 - то
       из этого чека скидки не выгружаем вообще. Там попадается скидка -1000% */
    define variable vflg as logical no-undo.
    define variable vflg0 as logical no-undo.
    define variable v-discnt-value-abs as decimal no-undo.
    define variable v-promocode-list as character no-undo.
    define variable vflg-disc as logical no-undo.
    assign
       vflg  = no
       vflg0 = no
       v-discnt-value-abs = 0
       v-promocode-list = ""       
       v-disc-promo-id = 0
       vflg-disc = no
       .
    /* для возвратного чека возможно надо скидку по промоакции взять из прямого чека  */   
    if p-buf_chk-doc.chk-type = integer({&rcpt-return}) 
      and v-b-code <> 0
      and not can-find(first buf_chk-discnt no-lock
                       where buf_chk-discnt.doc-code    = p-buf_chk-doc.doc-code
                         and buf_chk-discnt.record-type    = 5
                         and buf_chk-discnt.promo-id <> "" ) 
    then do:
       v-disc-promo-id = get-chk-promo-id(p-buf_chk-doc.obj-code, 
                                          p-buf_chk-doc.obj-type, 
                                          p-buf_chk-doc.pay-desk, 
                                          p-buf_chk-doc.doc-num2, 
                                          v-b-code,
                                          v-gds-qnty,
                                          output v-line-num-promo,
                                          output v-disc-promo-count).
    end.    
    
    if not can-find (first chk-discnt where chk-discnt.doc-code = p-buf_chk-doc.doc-code
                                        and chk-discnt.discnt-type       = 23
                                        and chk-discnt.discnt-value-pcnt = 0) then do :    
            
    for each buf_chk-discnt no-lock
       where buf_chk-discnt.doc-code = p-buf_chk-doc.doc-code
        /* скидки обычные (record-type = 0) и скидки, которыми выравниваются погрешности (record-type = 2) */
         and ( buf_chk-discnt.record-type = 1 or
               buf_chk-discnt.record-type = 2 
               or buf_chk-discnt.value-type = 14)
    break by buf_chk-discnt.doc-code :
      if first-of(buf_chk-discnt.doc-code) then do:
         vflg-disc = yes. 
         insw:start-element ({&tag-section3}) .
      end.   
      if buf_chk-discnt.promo-id > "" and 
         not can-do(v-promocode-list,buf_chk-discnt.promo-id) then 
            v-promocode-list = if v-promocode-list = "" 
                                  then buf_chk-discnt.promo-id 
                                  else v-promocode-list + "," + buf_chk-discnt.promo-id. 
      /*если промоакции и скидка на подитог, необходимо размазать скидку на все товары*/
      if /* buf_chk-discnt.promo-id > "" and */  buf_chk-discnt.line-type = integer({&discnt-sub-total})
      and buf_chk-discnt.record-type = 1 
      and can-find(first  bf_chk-discnt no-lock
          where bf_chk-discnt.doc-code = buf_chk-discnt.doc-code and  bf_chk-discnt.record-type = 1 and bf_chk-discnt.discnt-id = buf_chk-discnt.discnt-id ) then 
      do:
         if not vflg
         then
         for each bf_chk-discnt no-lock
          where bf_chk-discnt.doc-code = buf_chk-discnt.doc-code and bf_chk-discnt.record-type = 1  and bf_chk-discnt.discnt-id = buf_chk-discnt.discnt-id  break by bf_chk-discnt.object-line-num:
          vflg = yes.
          
          insw:start-element ({&tag-item3}) .
          insw:write-data-element (  "discnt-num",       string(bf_chk-discnt.discnt-id)          ) . /* Номер строки скидки (Число) */
          insw:write-data-element (  "line-num",         string(bf_chk-discnt.object-line-num)           ) . /* Номер строки чека на которую предоставлена скидка (Число) */
          insw:write-data-element (  "discnt-type",      string(bf_chk-discnt.value-type)        ) . /* Тип скидки (Строка) */
          insw:write-data-element (  "discntValueAbs",   left-trim(string(bf_chk-discnt.discnt-value-abs,  "->>>>>>>>>9.9<<<<<<<<<"))  ) . /* Абсолютное значение скидки - сумма (Число) */
          insw:write-data-element (  "discntValuePcnt",  left-trim(string(bf_chk-discnt.discnt-value-pcnt, "->>>9.9<"))                 ) . /* % скидки (Число) */
          /* обязательность 0-1 */
          if bf_chk-discnt.promo-id > "" then 
          do:
            find first PromoAction where PromoAction.id =  int(bf_chk-discnt.promo-id) no-lock no-error.
         
            insw:write-data-element (  "promotion-code", if available PromoAction and PromoAction.ext-code > '' then PromoAction.ext-code else  bf_chk-discnt.promo-id  ) . /* Код промо-акции (Строка) */
        
          end.
          if bf_chk-discnt.templ-rl-root > 0 then  insw:write-data-element (  "discntGdsReason",       string(bf_chk-discnt.templ-rl-root)          ) .
          insw:end-element ({&tag-item3}) .
        
        end.
      end.
      else 
      do: 
        assign
          v-sum-promo = 0
          v-pcnt-promo = 0
          . 
        if buf_chk-discnt.record-type = 1 and 
           buf_chk-discnt.promo-id > "" then 
        do:
            find first buf_chk-gds-attr no-lock                  
                 where buf_chk-gds-attr.doc-code =  buf_chk-discnt.doc-code       
                   and buf_chk-gds-attr.line-num  =  buf_chk-discnt.line-num                 
                   and buf_chk-gds-attr.attr-code = "CSPromoSum"
               no-error.
            if avail buf_chk-gds-attr then do:
                v-sum-promo = dec(buf_chk-gds-attr.attr-value).
                find first  buf_chk-gds no-lock
                      where buf_chk-gds.doc-code = buf_chk-discnt.doc-code
                        and buf_chk-gds.line-num = buf_chk-discnt.line-num
                   no-error.                   
                if avail buf_chk-gds then
                   v-pcnt-promo = 100 * ( 1 - (buf_chk-gds.sum-base / (buf_chk-gds.sum-base + v-sum-promo))).
            end.
        end.
        if buf_chk-discnt.discnt-type = 999 and
           buf_chk-discnt.record-type = 2 and  
           buf_chk-discnt.value-type = 2 and  
           buf_chk-discnt.line-num = 0 and 
           buf_chk-discnt.promo-id = ""
           then do:           
           if not vflg0
           then do:
             v-discnt-value-abs = 0.  
             for each bf_chk-discnt no-lock
                where bf_chk-discnt.doc-code = buf_chk-discnt.doc-code 
                  and bf_chk-discnt.record-type = buf_chk-discnt.record-type
                  and bf_chk-discnt.discnt-type = buf_chk-discnt.discnt-type 
                  and bf_chk-discnt.value-type = buf_chk-discnt.value-type
                  and bf_chk-discnt.line-num = buf_chk-discnt.line-num
                  :
                  vflg0 = yes.
                  v-discnt-value-abs = v-discnt-value-abs + bf_chk-discnt.discnt-value-abs.    
             end.
             insw:start-element ({&tag-item3}) .
             insw:write-data-element (  "discnt-num",       string(buf_chk-discnt.discnt-id)          ) . /* Номер строки скидки (Число) */
             insw:write-data-element (  "line-num",         string(buf_chk-discnt.line-num)           ) . /* Номер строки чека на которую предоставлена скидка (Число) */
             insw:write-data-element (  "discnt-type",      string(buf_chk-discnt.value-type)        ) . /* Тип скидки (Строка) */
             insw:write-data-element (  "discntValueAbs",   left-trim(string(v-discnt-value-abs,  "->>>>>>>>>9.9<<<<<<<<<"))  ) . /* Абсолютное значение скидки - сумма (Число) */
             insw:write-data-element (  "discntValuePcnt",  left-trim(string(0, "->>>>9.9<"))                 ) . /* % скидки (Число) */
             /* обязательность 0-1 */
             if buf_chk-discnt.promo-id > "" then 
             do:
               find first PromoAction where PromoAction.id =  int(buf_chk-discnt.promo-id) no-lock no-error.             
               insw:write-data-element (  "promotion-code", if available PromoAction and PromoAction.ext-code > '' then PromoAction.ext-code else  buf_chk-discnt.promo-id  ) . /* Код промо-акции (Строка) */            
             end.
             if buf_chk-discnt.templ-rl-root > 0 then  insw:write-data-element (  "discntGdsReason",       string(buf_chk-discnt.templ-rl-root)          ) .
             insw:end-element ({&tag-item3}) .
           end.              
        end.   
        else do:   
            insw:start-element ({&tag-item3}) .
            insw:write-data-element (  "discnt-num",       string(buf_chk-discnt.discnt-id)          ) . /* Номер строки скидки (Число) */
            insw:write-data-element (  "line-num",         string(buf_chk-discnt.line-num)           ) . /* Номер строки чека на которую предоставлена скидка (Число) */
            insw:write-data-element (  "discnt-type",      string(buf_chk-discnt.value-type)        ) . /* Тип скидки (Строка) */
            insw:write-data-element (  "discntValueAbs",   left-trim(string(buf_chk-discnt.discnt-value-abs + v-sum-promo,  "->>>>>>>>>9.9<<<<<<<<<"))  ) . /* Абсолютное значение скидки - сумма (Число) */
            insw:write-data-element (  "discntValuePcnt",  left-trim(string(buf_chk-discnt.discnt-value-pcnt + v-pcnt-promo, "->>>>9.9<"))                 ) . /* % скидки (Число) */
            /* обязательность 0-1 */
            if buf_chk-discnt.promo-id > "" then 
            do:
              find first PromoAction where PromoAction.id =  int(buf_chk-discnt.promo-id) no-lock no-error.
             
              insw:write-data-element (  "promotion-code", if available PromoAction and PromoAction.ext-code > '' then PromoAction.ext-code else  buf_chk-discnt.promo-id  ) . /* Код промо-акции (Строка) */
            
            end.
            if buf_chk-discnt.templ-rl-root > 0 then  insw:write-data-element (  "discntGdsReason",       string(buf_chk-discnt.templ-rl-root)          ) .
            insw:end-element ({&tag-item3}) .        
        end.        
      
      end.
      if last-of(buf_chk-discnt.doc-code) then insw:end-element ({&tag-section3}) .
    end . /* end_of for each buf_chk-discnt */
    end . /* end_of if chk-discnt.discnt-type <> 23 or chk-discnt.discnt-value-pcnt <> 0 */
    
    if v-disc-promo-id <> 0 and     
       vflg-disc = no
    then do:
        insw:start-element ({&tag-section3}) .    
        insw:start-element ({&tag-item3}) .
        insw:write-data-element (  "discnt-num",       "1"    ) . /* Номер строки скидки (Число) */
        insw:write-data-element (  "line-num",         string(v-line-num-promo)  ) . /* Номер строки чека на которую предоставлена скидка (Число) */
        insw:write-data-element (  "discnt-type",      "0"    ) . /* Тип скидки (Строка) */
        insw:write-data-element (  "discntValueAbs",   "0.0"  ) . /* Абсолютное значение скидки - сумма (Число) */
        insw:write-data-element (  "discntValuePcnt",  "0.0"  ) . /* % скидки (Число) */

        find first PromoAction where PromoAction.id =  v-disc-promo-id no-lock no-error.         
        insw:write-data-element (  "promotion-code", if available PromoAction and PromoAction.ext-code > '' then PromoAction.ext-code else string(v-disc-promo-id)  ) . /* Код промо-акции (Строка) */        
        insw:end-element ({&tag-item3}) .  
        insw:end-element ({&tag-section3}) .     
    end.                                         
    
    /* section4 обязательность 0-1 */
    for each buf_chk-discnt no-lock
       where buf_chk-discnt.doc-code    = p-buf_chk-doc.doc-code
         and buf_chk-discnt.record-type = 4
         and buf_chk-discnt.discnt-value-abs <> 0
    break by buf_chk-discnt.doc-code :
      if first-of(buf_chk-discnt.doc-code) then insw:start-element ({&tag-section4}) .
      insw:start-element ({&tag-item4}) .

      insw:write-data-element (  "chk-line-num",  string(buf_chk-discnt.line-num)  ) . /* Номер строки чека (Число) */
      insw:write-data-element (  "sum-bonus",     left-trim(string(buf_chk-discnt.discnt-value-abs, "->>>>>>>>9.99"))   ) . /* Сумма начисленного бонуса (Число 15,2) */

      /* 17/XI-2017 Вид бонуса, поле «bonus-mode», в секции chk-bonus-p
         Сейчас везде используется начисление только на итог.
         Везде для выгрузки в процессинг используем - .
         Если в будущем понадобиться будем добавлять поле. */
      /* 22/XI-2017 поле bonus-mode исключено.
         Сейчас везде используется начисление только на итог.
         Везде для выгрузки в процессинг используем - 3.
         Если в будущем понадобиться будем добавлять поле. */
      /*   
      if buf_chk-discnt.line-type > 0 then 
        insw:write-data-element (  "bonus-mode",  string(buf_chk-discnt.line-type)  ) .
      */
        
      /* 21/XI-2017 добавлено dc-num, обязательность 0-1 */
      if buf_chk-discnt.d-card > "" then
      insw:write-data-element (  "dc-num",  buf_chk-discnt.d-card  ) . /* Номер ДК (Строка) */

      insw:end-element ({&tag-item4}) .
      if last-of(buf_chk-discnt.doc-code) then insw:end-element ({&tag-section4}) .
    end . /* end_of for each buf_chk-discnt */
/* Выгружаем итоговую инфу по скидкам */
        for each buf_chk-discnt no-lock
       where buf_chk-discnt.doc-code    = p-buf_chk-doc.doc-code
         and buf_chk-discnt.record-type = 5
         and can-do(v-promocode-list, buf_chk-discnt.promo-id)
    break by buf_chk-discnt.doc-code by buf_chk-discnt.promo-id :
      if first-of(buf_chk-discnt.doc-code) then insw:start-element ({&tag-section7}) .
        insw:start-element ({&tag-item7}) .
        find first PromoAction where PromoAction.id =  int(buf_chk-discnt.promo-id) no-lock no-error. 
            insw:write-data-element (  "promotion-code", if available PromoAction and PromoAction.ext-code > '' then PromoAction.ext-code else  buf_chk-discnt.promo-id  ) . /* Код промо-акции (Строка) */        
            insw:write-data-element (  "promotion-count",     left-trim(string(buf_chk-discnt.object-sum, "->>>>>>>>9.99"))   ) . /* Сумма начисленного бонуса (Число 15,2) */

       insw:end-element ({&tag-item7}) .
      if last-of(buf_chk-discnt.doc-code) then insw:end-element ({&tag-section7}) .
    end . /* end_of for each buf_chk-discnt */
    /* section5 исключена */
            
   /* если возвратный чек по топливу и скидок нет, то проверяем не было ли промоакции в чеке продажи */ 
   if v-disc-promo-id <> 0
   then do:            
      insw:start-element ({&tag-section7}) .    
      insw:start-element ({&tag-item7}) .   
      find first PromoAction where PromoAction.id =  v-disc-promo-id no-lock no-error.                    
      insw:write-data-element (  "promotion-code", if available PromoAction and PromoAction.ext-code > '' then PromoAction.ext-code else  string(v-disc-promo-id)  ) . /* Код промо-акции (Строка) */        
      insw:write-data-element (  "promotion-count",     left-trim(string(v-disc-promo-count, "->>>>>>>>9.99"))   ) . /* признак, что сработала промоакция (Число 0,1) */            
      insw:end-element ({&tag-item7}) .
      insw:end-element ({&tag-section7}) .                                    
   end. 
   
    /* section6 обязательность 0-1 */
    for each buf_chk-gds-pay no-lock
       where buf_chk-gds-pay.doc-code = p-buf_chk-doc.doc-code
    break by buf_chk-gds-pay.doc-code :
      if first-of(buf_chk-gds-pay.doc-code) then insw:start-element ({&tag-section6}) .
      insw:start-element ({&tag-item6}) .
      
      insw:write-data-element (  "pay-code",  string(buf_chk-gds-pay.pay-code)    ) . /* Код типа платежа (Число) */
      insw:write-data-element (  "line-num",  string(buf_chk-gds-pay.line-num)    ) . /* Номер строки с товарах чека (Число) */
      insw:write-data-element (  "pay-num",   string(buf_chk-gds-pay.cpline-num)  ) . /* Номер строки в оплатах чека (Число) */
      insw:write-data-element (  "sum",       left-trim(string(buf_chk-gds-pay.tot-r-b,      "->>>>>>>>9.99"))  ) . /* Сумма отнесенная на товар (либо бонус в рублевом эквиваленте) (Число 15,2) */
      /* 04/VI-2018 в чеках в chk-gds-pay сделать количество с 10 знаками после запятой */
      insw:write-data-element (  "qnty",      left-trim(string(buf_chk-gds-pay.eff-doc-qnty, "->>>>>>>>>9.9<<<<<<<<<"))  ) . /* Эффективное количество (Число 15,3) */

      /* 17/XI-2017 Добавляем поле «price-base» (цена) в секции «chk-pay-r». */
      /* обязательность 0-1 */
      if buf_chk-gds-pay.price-base > 0 then
      insw:write-data-element ( "price-base", left-trim(string(buf_chk-gds-pay.price-base, "->>>>>>>>9.99"))  ) . /* Цена (Число 15,2) */
      else insw:write-data-element ( "price-base", left-trim(string(0.0, "->>>>>>>>9.99"))  ) .

      /* 21/XI-2017 Добавлены поля pay-card (обязательность 0-1) и discntValueAbs (обязательность 1-1) */
      if buf_chk-gds-pay.pay-card > "" then
      insw:write-data-element (  "pay-card",               buf_chk-gds-pay.pay-card  ) . /* Номер платежной карты. Заполняется в случае оплаты банковской картой (Строка) */
      
      find first buf_chk-gds-attr no-lock where                 
                   buf_chk-gds-attr.doc-code = buf_chk-gds-pay.doc-code       
               and buf_chk-gds-attr.line-num  = buf_chk-gds-pay.line-num                 
               and buf_chk-gds-attr.attr-code = "CSPromoSum"
            no-error.
      v-sum-promo = if avail buf_chk-gds-attr then dec(buf_chk-gds-attr.attr-value) else 0 no-error.         
      if  v-sum-promo <> 0 and buf_chk-gds-pay.eff-doc-qnty <> 0 then  
         insw:write-data-element (  "discntValueAbs",  left-trim(string((buf_chk-gds-pay.discnt + (v-sum-promo / buf_chk-gds-pay.eff-doc-qnty)), "->>>>>>>>>9.9<<<<<<<<<"))  ) . /* Абсолютное значение скидки – сумма (Число) */
      else   
         insw:write-data-element (  "discntValueAbs",  left-trim(string((buf_chk-gds-pay.discnt), "->>>>>>>>>9.9<<<<<<<<<"))  ) . /* Абсолютное значение скидки – сумма (Число) */  
      insw:end-element ({&tag-item6}) .
      if last-of(buf_chk-gds-pay.doc-code) then insw:end-element ({&tag-section6}) .
    end . /* end_of for each buf_chk-gds-pay */

    insw:end-element ({&tag-message}) .
    
  end method .


  /* Формат даты ДД.ММ.ГГГГ
    <doc-date>01.01.2017</doc-date>
    <created-date>23.10.2017 12:08:15</created-date>
    28/XI-2017 - dataFormat() не используется: все даты в формате ISO
  */
  method private character timeFormat (p-time as integer) :
    define variable v-tm-format as character initial "hh:mm:ss" no-undo .
    return if (p-time >= 0) then string(p-time, v-tm-format) else "" .
  end method .
  method private character dateFormat (p-date as date) :
    define variable v-dt-format as character initial "99.99.9999" no-undo .
    return if (p-date = ?) then "" else string(p-date, v-dt-format) .
  end method .

  /* найти номер резервуара */
  method private character getTankNum (p-obj-type    as character,
                                       p-obj-code    as integer,
                                       p-pump        as integer,
                                       p-nozzle-code as integer,
                                       p-src-pl-code as integer,
                                       p-pl-code     as integer,
                                       p-gds-code    as integer) :
    define buffer buf_place for ub.place .
    define variable v-pl-code as integer no-undo .
    define variable v-loc1    as character no-undo .
                                       
         if p-src-pl-code > 0 then v-pl-code = p-src-pl-code.
    else if p-pl-code     > 0 then v-pl-code = p-pl-code.
    else do:
      /* если нет резервуара в чеке, найти в топологии текущую связку ТРК+Пистолет,
         определить по ней резервуар и выгрузить полученный код резервура */
      /* libFindtank всегда валидна: работа с классом ведётся только через метод CrContentToSW() */ 
      libFindtank:findtank_
      (input p-obj-type
      ,input p-obj-code
      ,input p-pump
      ,input p-nozzle-code
      ,input p-pl-code
      ,input p-gds-code
      ,output v-pl-code
      ) .
    end .
    
    if v-pl-code > 0 then do:
      find first buf_place no-lock where buf_place.pl-code = v-pl-code no-error .
      v-loc1 = if available buf_place then string(buf_place.pl-code) else "0" .
/*      v-loc1 = if available buf_place then buf_place.loc1 else "0" .*/
    end.
    else v-loc1 = "0" .

    return v-loc1 .        
  end method .
  
  method private character base64-enc ( input v-string as character ) :
    
    define variable v-base64-encode as character no-undo .
    
    
    do
    on error undo, return error return-value
    :
      define variable v-raw     as raw       no-undo .
      define variable v-raw-str as character no-undo .
    
      if v-string = ?
      then do:
        undo, return error "base64-encode: строка имеет неопределенное значение" .
        end.
    
        assign
          length(v-raw) = length(v-string) + 1
        .
        assign
          put-string(v-raw, 1) = v-string
        .
        assign
          v-raw-str = string(v-raw)
        .
        assign
          length(v-raw) = 0
        .
        assign
          v-base64-encode = substring(v-raw-str, 7)
        .
    end.
    
    return v-base64-encode .
  end.
  
  /* вычисление кода промоакции для возвратного чека по чеку продажи */
  method private integer get-chk-promo-id ( 
     input p-obj-code as integer, 
     input p-obj-type as character, 
     input p-pay-desk as integer, 
     input p-doc-num2 as character, 
     input p-b-code as integer,
     input p-gds-qnty as decimal,
     output o-disc-promo-line as integer,
     output o-disc-promo-count as integer ) :
    
    define buffer buf2_chk-doc for ub.chk-doc.
    define buffer buf2_chk-gds for ub.chk-gds.
    define buffer buf2_chk-discnt for ub.chk-discnt.
    
    define variable v-promo-id as character no-undo .
        
    v-promo-id = "".
    /* ищем чек продажи */
    for first buf2_chk-doc no-lock where 
             buf2_chk-doc.obj-code = p-obj-code 
         and buf2_chk-doc.obj-type = p-obj-type
         and buf2_chk-doc.pay-desk = p-pay-desk
         and buf2_chk-doc.chk-type = int({&rcpt-sale})
         and buf2_chk-doc.chk-num  = int(entry(1,p-doc-num2,":"))
         and buf2_chk-doc.z-number = int(entry(2,p-doc-num2,":"))
       :
       /* ищем этот товар в чеке продажи */    
       find first buf2_chk-gds no-lock where                 
                  buf2_chk-gds.doc-code = buf2_chk-doc.doc-code
             and  buf2_chk-gds.b-code   = p-b-code
       no-error.
       if avail buf2_chk-gds then do:                                           
           find first buf2_chk-discnt no-lock where 
                      buf2_chk-discnt.doc-code =  buf2_chk-doc.doc-code and
                      buf2_chk-discnt.record-type = 1 and 
                      buf2_chk-discnt.object-line-num = buf2_chk-gds.line-num and
                      buf2_chk-discnt.promo-id > "" 
           no-error .
           if avail buf2_chk-discnt
           then do:
               assign
                 v-promo-id = buf2_chk-discnt.promo-id
                 o-disc-promo-line = buf2_chk-gds.line-num
                 o-disc-promo-count = if buf2_chk-gds.src-qnty <> -1 * p-gds-qnty then 1 else 0 /* если весь товар вернули, то акция перестала действовать */
                 .                  
           end.   
       end.       
    end.                  
    return int(v-promo-id) .
  end.
  
end class.
