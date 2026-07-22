define {2} temp-table tt-rep no-undo
   field obj-type          as character
   field obj-code          as integer
   field obj-name          as character
   field chk-date          as date
   field chk-time          as integer
   field sort-date         as date
   field sort-time         as integer
   field shift-date        as date
   field shift-name        as character
   field doc-code          as character
   field chk-num           as integer
   field line-num          as integer
   field doc-num2          as character
   field z-number          as integer
   field tran-num          as integer
   field chk-type-desc     as character
   field pay-desk          as character
   field cash-num          as integer
   field cashier           as character
   field trk-num           as integer
   field nozzle-num        as integer
   field fuel-code         as integer
   field gds-name          as character
   field volume            as decimal
   field price             as decimal
   field money             as decimal
   field cash-pay-code     as integer
   field cash-pay-name     as character
   field pay-card          as character
   field datetime-beg      as datetime
   field date-beg          as date
   field time-beg          as integer
   field datetime-end      as datetime
   field date-end          as date
   field time-end          as integer
   field time-length       as integer
   field all-time-length   as integer
   field all-time-length-2 as integer /* время от начала первой до окончания последней транзакции */
   field multi-pay         as logical
   field resume-tran       as logical
   field uuid              as character
   field uuid-cheq         as character
   field grp-num           as integer
   field db-num            as integer
index pi obj-code shift-date shift-name sort-date sort-time pay-desk fuel-code trk-num nozzle-num
index si1 obj-code grp-num datetime-beg
index CashPayNname cash-pay-name
index GrpNum grp-num
index ChkTypeDesc chk-type-desc
index iuuid db-num uuid-cheq uuid  
index UuidCheq db-num uuid uuid-cheq
index UuidCHKType db-num uuid chk-type-desc
index DateTimeBeg datetime-beg
index AllTimeLength2 all-time-length-2
index sort obj-code sort-date sort-time
.

define {2} temp-table tt-all-total-rep no-undo
   field obj-type           as character
   field obj-code           as integer
   field qty-chk            as integer  /* номер чека */
   field qty-tran           as integer  /* номер топливной транзакции */
   field qty-chk-fuel       as integer  /* номер чека + тип чека, ПРОДАЖА */
   field full-time-tran     as integer  /* номер чека + томер транзакции */
   field avg-time-tran      as integer  /* full-time-tran / qty-tran */
   field avg-time-tran-fuel as integer  /* full-time-tran / qty-chk-fuel */
index obj obj-type obj-code
.
define {2} temp-table tt-total-rep no-undo like tt-all-total-rep
   field obj-name           as character
index ObjName obj-type obj-code obj-name
.

define {2} temp-table tt-grp no-undo
   field obj-type           as character
   field obj-code           as integer
   field obj-name           as character
   field grp-num            as integer
   field all-time-length    as integer
   field all-time-length-2  as integer
   field cash-pay-code      as integer
   field cash-pay-name      as character
   field resume-tran        as logical
index ObjName obj-type obj-code obj-name
index ResumeTran  resume-tran
index GrpNum grp-num
.

define {2} temp-table tt-grp-uuid no-undo
   field grp-num            as integer
   field uuid               as character
 index uid uuid grp-num.
.

define {2} temp-table tt-grp-cheq-uuid no-undo
   field grp-num            as integer
   field uuid               as character
 index uid uuid grp-num.
.

define {2} temp-table tt-pay no-undo
   field seq             as integer
   field volume          as decimal
   field money           as decimal
   field cash-pay-code   as integer
   field cash-pay-name   as character
   field pay-card        as character
   field multi-pay       as logical
  index pi seq
  .

&if "{1}" = "class" &then
method private void CreateOneRec
      (buffer chk-doc   for chk-doc,
       buffer tran-fuel for tran-fuel,
       buffer chk-gds   for chk-gds,
       buffer goods     for goods):
&else   
procedure CreateOneRec:
   define parameter buffer obj-list  for obj-list.
   define parameter buffer chk-doc   for chk-doc.
   define parameter buffer tran-fuel for tran-fuel.
   define parameter buffer chk-gds   for chk-gds.
   define parameter buffer goods     for goods.
&endif
                                          
   define buffer cash-pay    for cash-pay.
   define buffer b-chk-gds   for chk-gds.
   define buffer b-tran-fuel for tran-fuel.

   define variable v-chk-type-desc as character no-undo.
   define variable v-cash-pay-code as integer   no-undo.
   define variable v-cash-pay-name as character no-undo.
   define variable v-pay-card      as character no-undo.
   define variable v-psn-code      as integer   no-undo.
   define variable v-db-num        as integer   no-undo.
   define variable vDateBeg        as datetime  no-undo.
   define variable vDateEnd        as datetime  no-undo.
   define variable vSeq            as integer   no-undo.
   define variable vMoney          as decimal   no-undo.
   define variable vVolume         as decimal   no-undo.
   define variable vTotSum         as decimal   no-undo.

   do:
      /* Для чеков с типами возврат, сброс транзакции, перевод транзакции в отчет берем объем из чеков  */
      vVolume = if can-do("6,14,16", string(chk-doc.chk-type)) then chk-gds.doc-qnty else tran-fuel.volume. 
      
      empty temp-table tt-pay.
      v-chk-type-desc = entry(lookup(string(chk-doc.chk-type), {&CHK_CODE_LIST}), {&CHK_NAME_LIST}).

      for each chk-pay where
               chk-pay.doc-code = chk-gds.doc-code
      no-lock
      break
         by chk-pay.doc-code
         by chk-pay.tot-sum:
         /* Если одна оплата, то выходим */
         if first-of(chk-pay.doc-code) and last-of(chk-pay.doc-code) then
            leave.

         vSeq = vSeq + 1.
         v-pay-card = if chk-pay.pay-card = "0" then "" else chk-pay.pay-card.

         find first cash-pay where
                    cash-pay.cdpay-code = chk-pay.pay-code
         no-lock no-error.
         if avail cash-pay then
            assign
               v-cash-pay-code = chk-pay.pay-code
               v-cash-pay-name = cash-pay.obj-name
               .
         else
            assign
               v-cash-pay-code = 0
               v-cash-pay-name = ""
               .
         
         /* Если в чеке есть нетопливные товары, то вычтем из самой большого платежа сумму этих товаров */
         vTotSum = chk-pay.tot-sum - (if last-of(chk-pay.doc-code) then 
                                         (chk-doc.tot-doc - chk-gds.sum-base)
                                      else 0). 
         create tt-pay.
         assign
            tt-pay.seq           = vSeq
            tt-pay.volume        = round(vVolume * vTotSum / chk-gds.sum-base, 2)
            tt-pay.money         = vTotSum
            tt-pay.cash-pay-code = v-cash-pay-code
            tt-pay.cash-pay-name = v-cash-pay-name
            tt-pay.pay-card      = v-pay-card
            tt-pay.multi-pay     = yes
            .
            if tt-pay.volume = ? then
               tt-pay.volume = 0.0.
      end.
      
      find first tt-pay no-error.
      if not avail tt-pay then do:
         find first chk-pay where
                    chk-pay.doc-code = chk-gds.doc-code
         no-lock no-error.
         if avail chk-pay then
            assign
               v-pay-card      = if chk-pay.pay-card = "0" then "" else chk-pay.pay-card
               vMoney          = chk-gds.sum-base
               v-cash-pay-code = chk-pay.pay-code
               .
         else
            assign
               v-pay-card       = ""
               vMoney           = tran-fuel.money
               v-cash-pay-code  = (if chk-doc.chk-type = 8 then 0 else tran-fuel.pay-code) /* Для чеков аннуляций тип оплаты берем только с чека */
               .

         find first cash-pay where
                    cash-pay.cdpay-code = v-cash-pay-code
         no-lock no-error.
         v-cash-pay-name = if avail cash-pay then cash-pay.obj-name else "".
         create tt-pay.
         assign
            tt-pay.seq           = 1
            tt-pay.volume        = vVolume
            tt-pay.money         = if chk-doc.chk-type = 1 then vVolume * tran-fuel.price else vMoney
            tt-pay.cash-pay-code = v-cash-pay-code
            tt-pay.cash-pay-name = v-cash-pay-name
            tt-pay.pay-card      = v-pay-card
            .
      end.

      /* Попробуем найти первую из связанных в цепочке транзакций и возьмем из неё время начала */
      find first b-tran-fuel where
                 b-tran-fuel.db-num    = tran-fuel.db-num
             and b-tran-fuel.uuid      = tran-fuel.uuid
             and b-tran-fuel.uuid-cheq = ""
      no-lock no-error.
      if avail b-tran-fuel and b-tran-fuel.date-beg < tran-fuel.date-beg then
         vDateBeg = b-tran-fuel.date-beg.
      else
         vDateBeg = tran-fuel.date-beg.
      /* Корректировка по часовому поясу */
      assign
         vDateBeg = vDateBeg           + timezone * 60000
         vDateEnd = tran-fuel.date-end + timezone * 60000.
         .
      for each tt-pay:
         create tt-rep.
         assign
            &if "{1}" <> "class" &then
            tt-rep.obj-type        = obj-list.obj-type
            tt-rep.obj-code        = obj-list.obj-code
            tt-rep.obj-name        = obj-list.obj-name
            &endif
            tt-rep.chk-date        = chk-doc.chk-date
            tt-rep.chk-time        = chk-doc.chk-time
            tt-rep.sort-date       = chk-doc.chk-date
            tt-rep.sort-time       = chk-doc.chk-time
            tt-rep.shift-date      = chk-doc.shift-date
            tt-rep.shift-name      = chk-doc.shift-name + "(" + string(chk-doc.shift-num) + ")"
            tt-rep.doc-code        = chk-doc.doc-code
            tt-rep.chk-num         = chk-doc.chk-num
            tt-rep.line-num        = chk-gds.line-num
            tt-rep.doc-num2        = (if num-entries(chk-doc.doc-num2, ":") > 1 then entry(1, chk-doc.doc-num2, ":") else "")
            tt-rep.z-number        = chk-doc.z-number
            tt-rep.tran-num        = tran-fuel.tran-num
            tt-rep.chk-type-desc   = v-chk-type-desc
            tt-rep.cash-num        = tran-fuel.cash-num
            tt-rep.trk-num         = tran-fuel.trk-num + 1
            tt-rep.nozzle-num      = tran-fuel.nozzle-num + 1
            tt-rep.fuel-code       = chk-gds.b-code
            tt-rep.gds-name        = goods.gds-name
            tt-rep.volume          = tt-pay.volume
            tt-rep.price           = tran-fuel.price
            tt-rep.money           = if tt-pay.multi-pay then tt-pay.money else tt-pay.volume * tran-fuel.price
            tt-rep.cash-pay-code   = tt-pay.cash-pay-code
            tt-rep.cash-pay-name   = tt-pay.cash-pay-name
            tt-rep.pay-card        = tt-pay.pay-card
            tt-rep.datetime-beg    = vDateBeg
            tt-rep.date-beg        = date(vDateBeg)
            tt-rep.time-beg        = mtime(vDateBeg) / 1000
            tt-rep.datetime-end    = vDateEnd
            tt-rep.date-end        = date(vDateEnd)
            tt-rep.time-end        = mtime(vDateEnd) / 1000
            tt-rep.time-length     = (vDateEnd - vDateBeg) / 1000
            tt-rep.all-time-length = tt-rep.time-length
            tt-rep.multi-pay       = tt-pay.multi-pay
            tt-rep.resume-tran     = no
            tt-rep.uuid            = tran-fuel.uuid
            tt-rep.uuid-cheq       = tran-fuel.uuid-cheq
            tt-rep.db-num          = tran-fuel.db-num
            .
         /* Если перевод транзакции, то берем количество, номер колонки и пистолета из строки чека */
         if chk-doc.chk-type = 16 and chk-gds.src-qnty <= 0 then do:
            find first b-chk-gds where
                       b-chk-gds.doc-code = chk-gds.doc-code
                   and b-chk-gds.b-code   = chk-gds.b-code
                   and b-chk-gds.line-num > chk-gds.line-num
            no-lock no-error.
            if avail b-chk-gds then
               assign
                  tt-rep.volume     = b-chk-gds.doc-qnty
                  /* tt-rep.trk-num    = b-chk-gds.pump */
                  /* tt-rep.nozzle-num = b-chk-gds.nozzle-code */
                  .
         end.
      
         &if "{1}" <> "class" &then
         { gbl/objdbnum.i obj-list.obj-type obj-list.obj-code v-db-num }
   
         v-psn-code = gbclcode-is-this-db-role ({&role-cashier},
                                                v-db-num,
                                                chk-doc.cashier,
                                                chk-doc.chk-date
                                                ).
   
         find first clients where
                    clients.obj-type = {&prs}
                and clients.obj-code = v-psn-code
         no-lock no-error.
         if available clients then
            tt-rep.cashier = clients.obj-name.
         &endif
      end.
   end.
end.

&if "{1}" = "class" &then
method private void InitTT
         (i-tog-shift       as logical,
          i-date-start      as date,
          i-date-end        as date,
          i-Shift-Start     as integer,
          i-Shift-End       as integer,
          iChkTypeCodeList  as character,
          iGdsCodeList      as character,
          iTRKList          as character):
&else
procedure InitTT:
   define input parameter i-tog-shift       as logical   no-undo.
   define input parameter i-date-start      as date      no-undo.
   define input parameter i-date-end        as date      no-undo.
   define input parameter i-Shift-Start     as integer   no-undo.
   define input parameter i-Shift-End       as integer   no-undo.
   define input parameter iChkTypeCodeList  as character no-undo.
   define input parameter iGdsCodeList      as character no-undo.
   define input parameter iTRKList          as character no-undo.
&endif   
   define buffer chk-doc      for chk-doc.
   define buffer chk-doc-attr for chk-doc-attr.
   define buffer chk-gds      for chk-gds.
   define buffer goods        for goods.
   define buffer cash-pay     for cash-pay.
   define buffer prod-bc      for prod-bc.
   define buffer b-tran-fuel  for tran-fuel.
   
   define variable v-gds-code as integer  no-undo.
   define variable vDateBeg   as datetime no-undo.
   define variable vDateEnd   as datetime no-undo.
   define variable vCount     as integer  no-undo.
   
   if i-tog-shift then do:
      for 
          &if "{1}" <> "class" &then
          each obj-list,
          &endif
          each chk-doc where
           &if "{1}" <> "class" &then
               chk-doc.obj-type    = obj-list.obj-type
           and chk-doc.obj-code    = obj-list.obj-code
           and 
           &endif
               chk-doc.shift-date >= i-date-start
           and chk-doc.shift-date <= i-date-end
           and can-do(iChkTypeCodeList, string(chk-doc.chk-type))
      no-lock,
         first chk-doc-attr where
               chk-doc-attr.doc-code  = chk-doc.doc-code
           and chk-doc-attr.attr-code = "CheckId"
      no-lock,
         each tran-fuel where
              tran-fuel.uuid-cheq = chk-doc-attr.attr-value
          /* and can-do(iProdBcStrList, string(tran-fuel.fuel-code)) */
          and can-do(iTRKList, string(tran-fuel.trk-num + 1))
      no-lock:
         v-gds-code = tran-fuel.fuel-code.
         if v-gds-code < 100 then do: /* Если короткий код, то ищем полный код */
            find first prod-bc where
                       prod-bc.b-str = string(v-gds-code)
            no-lock no-error.
            if avail prod-bc then do:
               find first chk-gds where
                          chk-gds.doc-code = chk-doc.doc-code
                      and chk-gds.b-code   = prod-bc.b-code
               no-lock no-error.
               find first goods where
                          goods.gds-code = prod-bc.b-code
               no-lock no-error.
               if not avail chk-gds or not avail goods
               then
                  next.
               v-gds-code = goods.gds-code.
            end.
            else next.
         end.
         else do:
            find first chk-gds where
                       chk-gds.doc-code = chk-doc.doc-code
                   and chk-gds.b-code   = v-gds-code
            no-lock no-error.
            find first goods where
                       goods.gds-code = v-gds-code
            no-lock no-error.
            if not avail chk-gds or not avail goods
            then
               next.
         end.
         if not can-do(iGdsCodeList, string(v-gds-code)) then next.
         if (chk-doc.shift-date = i-date-start and chk-doc.shift-num < i-Shift-Start) or
            (chk-doc.shift-date = i-date-end   and chk-doc.shift-num > i-Shift-End) 
         then
            next.
         &if "{1}" = "class" &then
         CreateOneRec(buffer chk-doc,
                      buffer tran-fuel,
                      buffer chk-gds,
                      buffer goods
                      ).
         &else
         run CreateOneRec(buffer obj-list,
                          buffer chk-doc,
                          buffer tran-fuel,
                          buffer chk-gds,
                          buffer goods
                          ).
         &endif
      end.
   end.
   else do:
     TRAN-FUEL:
     for each tran-fuel where
              tran-fuel.date-beg >= datetime(string(i-date-start) + " 00:00:00") - timezone * 60000
          and tran-fuel.date-beg <= datetime(string(i-date-end + 2) + " 23:59:59") - timezone * 60000 /* Отберем транзакции за 2 дня вперед. Отфильтруем после корректировки даты начала транзакции */
          /* and can-do(iProdBcStrList, string(tran-fuel.fuel-code)) */
          and can-do(iTRKList, string(tran-fuel.trk-num + 1))
     no-lock:
        
       release chk-doc-attr.
       if tran-fuel.num-cheq > 0 then do:
         {rep/r-tranf-chk.i {1}}
       end.
       if not available chk-doc-attr then do:
         &if "{1}" <> "class" &then
         /* Отбор транзакций, по которым нет чеков */
           {rep/r-tranf-nochk.i}
         &endif
       end.    
     end.   /* for each tran-fuel */
/*      run test\printtt.p("tt-rep 3",temp-table tt-rep:handle).*/
   end.
/*   run test\printtt.p("tt-rep 4",temp-table tt-rep:handle).*/
   
   release tt-rep.
end.

&if "{1}" = "class" &then
method private void AfterCalc(i-tog-shift  as logical,
                              i-date-end   as date,
                              iTRKList     as character,
                              iCashPayList as character,
                              iTranTimeMax as integer):
&else
procedure AfterCalc:
   define input parameter i-tog-shift  as logical   no-undo.
   define input parameter i-date-end   as date      no-undo.
   define input parameter iTRKList     as character no-undo.
   define input parameter iCashPayList as character no-undo.
   define input parameter iTranTimeMax as integer   no-undo.
&endif

   define buffer b-chk-gds    for chk-gds.
   define buffer b-tt-rep     for tt-rep.
   define buffer b2-tt-rep    for tt-rep.
   
   define variable vI                   as integer   no-undo.
   define variable vCheck               as logical   no-undo.
   define variable vCheckResumeTran     as logical   no-undo.
   define variable v-all-time-length    as integer   no-undo.
   define variable v-count-grp-num      as integer   no-undo.
   define variable v-prev-datetime-end  as datetime  no-undo.
   define variable v-first-datetime-beg as datetime  no-undo.
   define variable vResumeTran          as logical   no-undo.
   define variable vUuidCheq            as character no-undo.
   define variable vFirstRecId          as recid     no-undo.
   define variable vConfirmResumeTran   as logical   no-undo.
   define variable vRecId               as recid     no-undo.
   define variable vRowId               as rowid     no-undo.
   define variable vRowIdList           as character no-undo.
   define variable v-gds-code           as integer   no-undo.
   define variable vTrkNum              as integer   no-undo.
   for each  tt-grp:
      delete tt-grp.
   end.
   for each  tt-grp-uuid:
      delete tt-grp-uuid.
   end.
   for each  tt-grp-cheq-uuid:
      delete tt-grp-cheq-uuid.
   end.
   /* Постобработка данных по фильтру */   
   for each tt-rep where
            not can-do(iTRKList, string(tt-rep.trk-num)):
      delete tt-rep.
   end.
/*   run test\printtt.p("tt-rep 6",temp-table tt-rep:handle).*/
   
   /* Попробуем найти отсутствующую информацию в связанном чеке */
   for each tt-rep where
            tt-rep.cash-pay-name = "":
      find first tran-fuel where
                 tran-fuel.db-num   = tt-rep.db-num
             and tran-fuel.tran-num = tt-rep.tran-num
             and tran-fuel.num-cheq = integer(tt-rep.doc-num2)
      no-lock no-error.
      if avail tran-fuel then do:
         for first chk-doc-attr where
                   chk-doc-attr.attr-code  = "CheckId"
               and chk-doc-attr.attr-value = tran-fuel.uuid-cheq
         no-lock,
             first chk-doc where
                   chk-doc.doc-code = chk-doc-attr.doc-code
         no-lock
         &if "{1}" <> "class" &then
	       ,
             first obj-list where
                   obj-list.obj-type = chk-doc.obj-type
               and obj-list.obj-code = chk-doc.obj-code
         no-lock
         &endif
	       :
            v-gds-code = tran-fuel.fuel-code.
            if v-gds-code < 100 then do: /* Если короткий код, то ищем полный код */
               find first prod-bc where
                          prod-bc.b-str = string(tran-fuel.fuel-code)
               no-lock no-error.
               if avail prod-bc then do:
                  find first chk-gds where
                             chk-gds.doc-code = chk-doc.doc-code
                         and chk-gds.b-code   = prod-bc.b-code
                  no-lock no-error.
                  find first goods where
                             goods.gds-code = prod-bc.b-code
                  no-lock no-error.
                  if not avail chk-gds or not avail goods
                  then
                     next.
                  v-gds-code = goods.gds-code.
               end.
            end.
            else do:
               find first chk-gds where
                          chk-gds.doc-code = chk-doc.doc-code
                      and chk-gds.b-code   = v-gds-code
               no-lock no-error.
               find first goods where
                          goods.gds-code = v-gds-code
               no-lock no-error.
               if not avail chk-gds or not avail goods
               then
                  next.
            end.
   
            find first chk-pay where
                       chk-pay.doc-code = chk-gds.doc-code
            no-lock no-error.
            if avail chk-pay then do:
               find first cash-pay where
                          cash-pay.cdpay-code = chk-pay.pay-code
               no-lock no-error.
               if avail cash-pay then
                  assign
                     tt-rep.cash-pay-code = chk-pay.pay-code
                     tt-rep.cash-pay-name = cash-pay.obj-name.
                     
            end.
         end.
      end.
   end.
/*   run test\printtt.p("tt-rep 7",temp-table tt-rep:handle).*/
   
   /* Группировка транзакций */
   v-count-grp-num = 0.
   for each tt-rep
      by tt-rep.obj-code
      by tt-rep.sort-date
      by tt-rep.sort-time:
/*
      block-grp:
      for each tt-grp where
                 tt-grp.obj-type = tt-rep.obj-type 
             and tt-grp.obj-code = tt-rep.obj-code
             and tt-grp.obj-name = tt-rep.obj-name
             :
             find first tt-grp-uuid where tt-grp-uuid.grp-num = tt-grp.grp-num
                                      and tt-grp-uuid.uuid     = tt-rep.uuid
             no-error.
             find first tt-grp-cheq-uuid where tt-grp-cheq-uuid.grp-num = tt-grp.grp-num
                                           and tt-grp-cheq-uuid.uuid     = tt-rep.uuid
             no-error.
             if    available tt-grp-cheq-uuid
                or available tt-grp-uuid
             then do:
                leave block-grp.
             end.
      end.
  */
  
      block-grp-uuid:
      for each tt-grp-uuid where  tt-grp-uuid.uuid     = tt-rep.uuid
      no-lock:
             
         for each tt-grp where
                    tt-grp.obj-type = tt-rep.obj-type 
                and tt-grp.obj-code = tt-rep.obj-code
                and tt-grp.obj-name = tt-rep.obj-name
                and tt-grp.grp-num  = tt-grp-uuid.grp-num
                :
                find first tt-grp-cheq-uuid where tt-grp-cheq-uuid.grp-num = tt-grp.grp-num
                                              and tt-grp-cheq-uuid.uuid     = tt-rep.uuid-cheq
                no-error.
                leave block-grp-uuid.
             end.
      end.
      if not available tt-grp
      then do:
         block-grp-cheq:
         for each tt-grp-cheq-uuid where  tt-grp-cheq-uuid.uuid     = tt-rep.uuid-cheq
         no-lock:
                
            for each tt-grp where
                       tt-grp.obj-type = tt-rep.obj-type 
                   and tt-grp.obj-code = tt-rep.obj-code
                   and tt-grp.obj-name = tt-rep.obj-name
                   and tt-grp.grp-num  = tt-grp-cheq-uuid.grp-num
                   :
                   find first tt-grp-uuid where tt-grp-uuid.grp-num = tt-grp.grp-num
                                            and tt-grp-uuid.uuid     = tt-rep.uuid
                   no-error.
                   leave block-grp-cheq.
            end.
         end.
      end.
      if     not avail tt-grp
      then do:
         v-count-grp-num = v-count-grp-num + 1.
         create tt-grp.
         assign
            tt-grp.obj-type = tt-rep.obj-type
            tt-grp.obj-code = tt-rep.obj-code
            tt-grp.obj-name = tt-rep.obj-name
            tt-grp.grp-num  = v-count-grp-num
            .
      end.
      
      if not available tt-grp-cheq-uuid 
      then do:
         create tt-grp-cheq-uuid.
         assign
            tt-grp-cheq-uuid.grp-num  = tt-grp.grp-num
            tt-grp-cheq-uuid.uuid     = tt-rep.uuid-cheq
         .
      end.
      
                  
      if not available tt-grp-uuid 
      then do:
         create tt-grp-uuid.
         assign
            tt-grp-uuid.grp-num = tt-grp.grp-num
            tt-grp-uuid.uuid     = tt-rep.uuid
         .
      end.
      tt-rep.grp-num = tt-grp.grp-num.
      if tt-grp.cash-pay-name = "" then
         assign
            tt-grp.cash-pay-code = tt-rep.cash-pay-code
            tt-grp.cash-pay-name = tt-rep.cash-pay-name
            .
      release tt-grp.
   end.
   
   /* Продолжение налива */
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.sort-date
      by tt-rep.sort-time
      by tt-rep.datetime-beg:

      if first-of(tt-rep.grp-num) then do:
         assign
            vUuidCheq          = ""
            vResumeTran        = no
            vConfirmResumeTran = no
            .
         if tt-rep.chk-type-desc = "Продажа" then
            assign
               vUuidCheq   = tt-rep.uuid-cheq
               vResumeTran = yes
               vTrkNum     = tt-rep.trk-num
               .
         find first b-tt-rep where recid(b-tt-rep) = vFirstRecId no-error.
      end.
      else do:
         if tt-rep.chk-type-desc = "Продажа" and 
            tt-rep.uuid-cheq     = vUuidCheq and
            tt-rep.multi-pay     = no        and /* Транзакции со смешанной оплатой не помечаем как продолжение налива */
            vResumeTran          = yes     /*  and  EXPSD-4570 - закомментировано, если это перенос транзакции? 
            tt-rep.trk-num       = vTrkNum       /* Продолжение налива может быть только на той же ТРК */ */
         then
            assign
               tt-rep.resume-tran = yes
               vConfirmResumeTran = yes
               .
         else 
            if tt-rep.chk-type-desc = "Продажа" and 
               tt-rep.uuid-cheq     = vUuidCheq and
               tt-rep.multi-pay     = no            /* Транзакции со смешанной оплатой не помечаем как продолжение налива */
            then
               assign
                  vResumeTran = yes
                  vTrkNum     = tt-rep.trk-num
               .
            else
               vResumeTran = no.
         
         /* EXPSD-4570 проверим было ли включение "продолжение налива" при постоплате */
         for first b-tt-rep where
                   b-tt-rep.db-num   = tt-rep.db-num
               and b-tt-rep.uuid     = tt-rep.uuid
               and b-tt-rep.chk-num = 0:
           assign
             tt-rep.resume-tran = yes
             vConfirmResumeTran = yes
           .
           for first tt-grp-uuid where 
                     tt-grp-uuid.uuid = b-tt-rep.uuid:
              delete tt-grp-uuid.
           end.   
           delete b-tt-rep.
         end.
      end.

      if last-of(tt-rep.grp-num) and not first-of(tt-rep.grp-num) and vConfirmResumeTran then do:
         for first tt-grp where tt-grp.grp-num = tt-rep.grp-num:
            tt-grp.resume-tran = yes.
         end.
      end. 
   end.
   
   /* Корректировка времени окончания и продолжительности транзакций при продолжении налива */
   for each tt-grp where
            tt-grp.resume-tran = yes:
      for each tt-rep where
               tt-rep.grp-num = tt-grp.grp-num
      break
         by tt-rep.obj-code
         by tt-rep.grp-num
         by tt-rep.datetime-beg
         by tt-rep.sort-date
         by tt-rep.sort-time:
         
         if not first-of(tt-rep.grp-num) and tt-rep.chk-type-desc = "Продажа" then do:
            find first b-tt-rep where
                       recid(b-tt-rep)        = vRecId
                   and b-tt-rep.chk-type-desc = "Продажа"
            no-error.
            if avail b-tt-rep then do:
               assign
                  b-tt-rep.datetime-end    = tt-rep.datetime-beg
                  b-tt-rep.date-end        = tt-rep.date-beg
                  b-tt-rep.time-end        = tt-rep.time-beg
                  b-tt-rep.time-length     = (b-tt-rep.datetime-end - b-tt-rep.datetime-beg) / 1000
                  .
            end.
         end.
         
         vRecId = recid(tt-rep).
      end.
   end.
   
   /* Для чека ПеревТрнзкц создаем вторую транзакцию */
   repeat preselect each tt-rep where
                         tt-rep.chk-type-desc = "ПеревТрнзкц":
      /* Перевод откуда */                           
      find next tt-rep.
      find first b-chk-gds where
                 b-chk-gds.doc-code =  tt-rep.doc-code
             and b-chk-gds.line-num <> chk-gds.line-num
      no-lock no-error.
      if avail b-chk-gds then do:
         /* Первоначальная продажа */
         find first b-tt-rep where
                    b-tt-rep.db-num    =  tt-rep.db-num
                and b-tt-rep.uuid      =  tt-rep.uuid
                and b-tt-rep.uuid-cheq <> tt-rep.uuid-cheq
         no-error.
         if avail b-tt-rep then do:
            /* Конечная продажа */
            find first b2-tt-rep where
                       b2-tt-rep.db-num    =  B-tt-rep.db-num
                   and b2-tt-rep.uuid-cheq =  b-tt-rep.uuid-cheq
                   and b2-tt-rep.uuid      <> b-tt-rep.uuid
            no-lock no-error.
            if avail b2-tt-rep then do:
               /* Перевод куда */
               create b-tt-rep.
               buffer-copy b2-tt-rep to b-tt-rep
                  assign
                     b-tt-rep.chk-date        = tt-rep.chk-date
                     b-tt-rep.chk-time        = tt-rep.chk-time
                     b-tt-rep.sort-date       = tt-rep.sort-date
                     b-tt-rep.sort-time       = tt-rep.sort-time
                     b-tt-rep.doc-code        = tt-rep.doc-code
                     b-tt-rep.chk-num         = tt-rep.chk-num
                     b-tt-rep.line-num        = b-chk-gds.line-num
                     b-tt-rep.doc-num2        = tt-rep.doc-num2
                     b-tt-rep.z-number        = tt-rep.z-number
                     b-tt-rep.chk-type-desc   = tt-rep.chk-type-desc 
                     b-tt-rep.resume-tran     = no
                     b-tt-rep.uuid-cheq       = tt-rep.uuid-cheq
                     /*
                     b-tt-rep.datetime-beg    = tt-rep.datetime-beg
                     b-tt-rep.date-beg        = tt-rep.date-beg
                     b-tt-rep.time-beg        = tt-rep.time-beg
                     b-tt-rep.time-length     = (b2-tt-rep.datetime-end - b2-tt-rep.datetime-beg) / 1000
                     b-tt-rep.all-time-length = b2-tt-rep.time-length
                     */
                     .
            end.
         end.
      end.
   end.
   
   /* Корректировка времени окончания и продолжительности транзакций при переводе транзакции */
   for each tt-grp:
      for each tt-rep where
               tt-rep.grp-num = tt-grp.grp-num
      break
         by tt-rep.obj-code
         by tt-rep.grp-num
         by tt-rep.datetime-beg
         by tt-rep.sort-date
         by tt-rep.sort-time:
         
         if not first-of(tt-rep.grp-num) and tt-rep.chk-type-desc = "ПеревТрнзкц" then do:
            find first b-tt-rep where
                       recid(b-tt-rep)        = vRecId
                   and b-tt-rep.chk-type-desc = "Продажа"
            no-error.
            if avail b-tt-rep then do:
               assign
                  b-tt-rep.datetime-end    = tt-rep.datetime-end
                  b-tt-rep.date-end        = tt-rep.date-end
                  b-tt-rep.time-end        = tt-rep.time-end
                  b-tt-rep.time-length     = (b-tt-rep.datetime-end - b-tt-rep.datetime-beg) / 1000
                  .
            end.
         end.
         vRecId = recid(tt-rep).
      end.
   end.
   
   /* Корректировка времени начала и продолжительности для транзакций возврата */
   for each tt-rep where
            tt-rep.chk-type-desc = "Возврат":
      find last b-tt-rep where
                b-tt-rep.DB-NUM        = tt-rep.db-num
            and b-tt-rep.uuid          = tt-rep.uuid
            and b-tt-rep.chk-type-desc = "Продажа"
      no-error.
      if avail b-tt-rep then do:
         assign
            tt-rep.datetime-beg = b-tt-rep.datetime-beg
            tt-rep.date-beg     = b-tt-rep.date-beg
            tt-rep.time-beg     = b-tt-rep.time-beg
            tt-rep.time-length  = (tt-rep.datetime-end - tt-rep.datetime-beg) / 1000
            .
      end. 
   end.
   
   /* Корректировка времени начала и продолжительности для транзакций сброса */
   for each tt-rep where
            tt-rep.chk-type-desc = "СбросТрнзкц":
      find last b-tt-rep where
                b-tt-rep.DB-NUM        = tt-rep.db-num
            and b-tt-rep.uuid          = tt-rep.uuid
            and b-tt-rep.chk-type-desc = "Продажа"
      no-error.
      if avail b-tt-rep then do:
         assign
            tt-rep.datetime-beg = b-tt-rep.datetime-beg
            tt-rep.date-beg     = b-tt-rep.date-beg
            tt-rep.time-beg     = b-tt-rep.time-beg
            tt-rep.time-length  = (tt-rep.datetime-end - tt-rep.datetime-beg) / 1000
            .
      end. 
   end.
   
   /* Корректировка времени начала и продолжительности для транзакций перевода */
   for each tt-rep where
            tt-rep.chk-type-desc = "ПеревТрнзкц":
      find first b-tt-rep where
                 b-tt-rep.DB-NUM        = tt-rep.db-num
             and b-tt-rep.uuid          = tt-rep.uuid
             and b-tt-rep.chk-type-desc = "Продажа"
      no-error.
      if avail b-tt-rep then do:
         assign
            tt-rep.datetime-beg = b-tt-rep.datetime-beg
            tt-rep.date-beg     = b-tt-rep.date-beg
            tt-rep.time-beg     = b-tt-rep.time-beg
            tt-rep.time-length  = (tt-rep.datetime-end - tt-rep.datetime-beg) / 1000
            .
      end. 
   end.
   
   /* Корректировка времени начала и продолжительности для транзакций техпролива */
   for each tt-rep where
            tt-rep.chk-type-desc = "ТехПролив":
      find first tran-fuel where
                 tran-fuel.db-num    =  tt-rep.db-num
             and tran-fuel.uuid      =  tt-rep.uuid
             and tran-fuel.uuid-cheq <> tt-rep.uuid-cheq
      no-lock no-error.
      if avail tran-fuel then do:
         assign
            tt-rep.datetime-beg = tran-fuel.date-beg + timezone * 60000
            tt-rep.date-beg     = date(tt-rep.datetime-beg)
            tt-rep.time-beg     = mtime(tt-rep.datetime-beg) / 1000
            tt-rep.time-length  = (tt-rep.datetime-end - tt-rep.datetime-beg) / 1000
            .
      end. 
   end.
   
   /* Корректировка времени окончания и продолжительности транзакций, где следующей строкой идет Сброс или Возврат */
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.datetime-beg
      by tt-rep.sort-date
      by tt-rep.sort-time:

      if first-of(tt-rep.grp-num) then do:
         vRowId = ?.
      end.

      if can-do("Возврат,СбросТрнзкц", tt-rep.chk-type-desc) and vRowId <> ? then do:
         for first b-tt-rep where rowid(b-tt-rep) = vRowId:
            assign
               b-tt-rep.datetime-end    = tt-rep.datetime-end
               b-tt-rep.date-end        = tt-rep.date-end
               b-tt-rep.time-end        = tt-rep.time-end
               b-tt-rep.time-length     = (b-tt-rep.datetime-end - b-tt-rep.datetime-beg) / 1000
               .
         end.
      end. 

      vRowId = rowid(tt-rep).
   end.
   
   /* Корректировка времени окончания и продолжительности транзакций, где идет последовательность "аннуляц-ия(ии), продажа" */
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.datetime-beg
      by tt-rep.sort-date
      by tt-rep.sort-time:

      if first-of(tt-rep.grp-num) then do:
         vRowIdList = "".
      end.

      if tt-rep.chk-type-desc = "Аннуляция" then
         vRowIdList = vRowIdList + (if vRowIdList > "" then "," else "") + string(rowid(tt-rep)).
      else if tt-rep.chk-type-desc = "Продажа" then do:
         do vI = 1 to num-entries(vRowIdList):
            vRowId = to-rowid(entry(vI, vRowIdList)).
            for first b-tt-rep where rowid(b-tt-rep) = vRowId:
               assign
                  b-tt-rep.datetime-end    = tt-rep.datetime-end
                  b-tt-rep.date-end        = tt-rep.date-end
                  b-tt-rep.time-end        = tt-rep.time-end
                  b-tt-rep.time-length     = (b-tt-rep.datetime-end - b-tt-rep.datetime-beg) / 1000
                  .
            end.
         end.
         vRowIdList = "".
      end. 
   end.
   
   /* В аннуляциях уберем тип оплаты */
   /*
   for each tt-rep where tt-rep.chk-type-desc = "Аннуляция":
      assign
         tt-rep.cash-pay-code = 0
         tt-rep.cash-pay-name = ""
         .
   end.
   */
   
   /* Определим транзакции перелива */
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.sort-date
      by tt-rep.sort-time
      by tt-rep.datetime-beg:

      if first-of(tt-rep.grp-num) then do:
         vI = 0.
         find first b-tt-rep where
                    rowid(b-tt-rep) = rowid(tt-rep).
      end.
      
      vI = vI + 1.
      
      if last-of(tt-rep.grp-num) and vI = 2 then do:
         if b-tt-rep.chk-type-desc  = "Продажа"           and 
            b-tt-rep.uuid           = tt-rep.uuid         and
            tt-rep.uuid-cheq        begins "empty-"       and
            b-tt-rep.trk-num        = tt-rep.trk-num      and
            b-tt-rep.nozzle-num     = tt-rep.nozzle-num   and
            b-tt-rep.fuel-code      = tt-rep.fuel-code    and
            b-tt-rep.volume         = tt-rep.volume       and
            b-tt-rep.datetime-beg  <= tt-rep.datetime-beg
         then
            tt-rep.chk-type-desc = "Перелив".
      end.
   end.
   
   /* Постобработка данных по фильтру тип оплаты */   
   for each tt-rep where
            not can-do(iCashPayList, string(tt-rep.cash-pay-code)):
      delete tt-rep.
   end.

   if i-tog-shift = no then do:
      /* Постобработка: удалим тразакции не входящие в период расчета */
      for each tt-rep where
               tt-rep.datetime-beg > datetime(string(i-date-end) + " 23:59:59"):
         delete tt-rep.
      end.
   end.
   
   /* Общее время отпуска НП */
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.datetime-beg
      by tt-rep.sort-date
      by tt-rep.sort-time:

      if first-of(tt-rep.grp-num) then do:
         assign
            v-all-time-length    = 0
            v-prev-datetime-end  = datetime("01/01/1990 00:00:00")
            v-first-datetime-beg = tt-rep.datetime-beg
            .
      end.

      if tt-rep.datetime-end > v-prev-datetime-end then
         v-all-time-length = v-all-time-length + (tt-rep.datetime-end - max(tt-rep.datetime-beg, v-prev-datetime-end)) / 1000.
      
      v-prev-datetime-end = max(tt-rep.datetime-end, v-prev-datetime-end).
      
      if last-of(tt-rep.grp-num) then do:
         find first tt-grp where
                    tt-grp.grp-num = tt-rep.grp-num
         no-error.
         if avail tt-grp then
            assign
               tt-grp.all-time-length   = v-all-time-length
               tt-grp.all-time-length-2 = (tt-rep.datetime-end - v-first-datetime-beg) / 1000
               .
      end.
   end.
   
   for each tt-rep:
      find first tt-grp where
                 tt-grp.grp-num = tt-rep.grp-num
      no-error.
      if avail tt-grp then do:
         assign
            tt-rep.all-time-length   = tt-grp.all-time-length
            tt-rep.all-time-length-2 = tt-grp.all-time-length-2
            .
         /*
         if tt-rep.cash-pay-name = "" then
            assign
               tt-rep.cash-pay-code = tt-grp.cash-pay-code
               tt-rep.cash-pay-name = tt-grp.cash-pay-name.
         */
      end.
   end.
   
   /* Оставляем записи только со временем отпуска НП >= параметру из фильтра отчета */ 
   for each tt-rep where
            tt-rep.all-time-length-2 < iTranTimeMax * 60:
      delete tt-rep.
   end.
   
   /* Итоги по АЗК */
   for each tt-grp-uuid:
      delete tt-grp-uuid.
   end.
   for each tt-rep
   break
      by tt-rep.obj-type
      by tt-rep.obj-code
      by tt-rep.sort-date
      by tt-rep.sort-time
      by tt-rep.uuid-cheq
      by tt-rep.datetime-beg:

      if first-of(tt-rep.obj-code) then do:
         create tt-total-rep.
         assign
            tt-total-rep.obj-type = tt-rep.obj-type
            tt-total-rep.obj-code = tt-rep.obj-code
            tt-total-rep.obj-name = tt-rep.obj-name
            .
      end.
      if first-of(tt-rep.uuid-cheq) then do:
         vCheck = no.
         tt-total-rep.qty-chk = tt-total-rep.qty-chk + 1.
      end.
      find first tt-grp-uuid where tt-grp-uuid.grp-num = 0 
                               and tt-grp-uuid.uuid     = tt-rep.uuid
      no-error.
                  
      if not available tt-grp-uuid
      then do:
         vCheck = yes.
         create tt-grp-uuid.
         assign
            tt-grp-uuid.grp-num = 0 
            tt-grp-uuid.uuid     = tt-rep.uuid
         .
      end.

      if last-of(tt-rep.uuid-cheq) then do:
         if vCheck then
            tt-total-rep.qty-chk-fuel = tt-total-rep.qty-chk-fuel + 1.
      end.
   end.
   
   release tt-total-rep.
   
   for each tt-rep,
      first tt-total-rep where
            tt-total-rep.obj-type = tt-rep.obj-type
        and tt-total-rep.obj-code = tt-rep.obj-code
        and tt-total-rep.obj-name = tt-rep.obj-name
   break
      by tt-rep.obj-type
      by tt-rep.obj-code
      by tt-rep.obj-name
      by tt-rep.tran-num:
      if first-of(tt-rep.tran-num) then do:
         tt-total-rep.qty-tran       = tt-total-rep.qty-tran + 1.
         tt-total-rep.full-time-tran = tt-total-rep.full-time-tran + tt-rep.time-length.
      end.
   end.
   
   for each tt-total-rep:
      tt-total-rep.avg-time-tran      = tt-total-rep.full-time-tran / tt-total-rep.qty-tran.
      tt-total-rep.avg-time-tran-fuel = tt-total-rep.full-time-tran / tt-total-rep.qty-chk-fuel.
   end.
   
   /* Общие итоги по фирме */
   for each tt-grp-uuid:
      delete tt-grp-uuid.
   end.
   
   for each tt-rep
   break
      by tt-rep.obj-type
      by tt-rep.obj-code
      by tt-rep.sort-date
      by tt-rep.sort-time
      by tt-rep.uuid-cheq
      by tt-rep.datetime-beg:

      if first-of(tt-rep.obj-code) then do:
         create tt-all-total-rep.
         assign
            tt-all-total-rep.obj-type = tt-rep.obj-type
            tt-all-total-rep.obj-code = tt-rep.obj-code
            .
      end.
      if first-of(tt-rep.uuid-cheq) then do:
         vCheck = no.
         tt-all-total-rep.qty-chk = tt-all-total-rep.qty-chk + 1.
      end.
      find first tt-grp-uuid where tt-grp-uuid.grp-num = 0 
                               and tt-grp-uuid.uuid     = tt-rep.uuid
      no-error.
      
      if not available tt-grp-uuid
      then do:
         vCheck = yes.
         create tt-grp-uuid.
         assign
            tt-grp-uuid.grp-num = 0 
            tt-grp-uuid.uuid     = tt-rep.uuid
         .
      end.

      if last-of(tt-rep.uuid-cheq) then do:
         if vCheck then
            tt-all-total-rep.qty-chk-fuel = tt-all-total-rep.qty-chk-fuel + 1.
      end.
   end.
   
   release tt-all-total-rep.
   
   for each tt-rep,
      first tt-all-total-rep where
            tt-all-total-rep.obj-type = tt-rep.obj-type
        and tt-all-total-rep.obj-code = tt-rep.obj-code
   break
      by tt-rep.obj-type
      by tt-rep.obj-code
      by tt-rep.tran-num:
      if first-of(tt-rep.tran-num) then do:
         tt-all-total-rep.qty-tran       = tt-all-total-rep.qty-tran + 1.
         tt-all-total-rep.full-time-tran = tt-all-total-rep.full-time-tran + tt-rep.time-length.
      end.
   end.
   
   for each tt-all-total-rep:
      tt-all-total-rep.avg-time-tran      = tt-all-total-rep.full-time-tran / tt-all-total-rep.qty-tran.
      tt-all-total-rep.avg-time-tran-fuel = tt-all-total-rep.full-time-tran / tt-all-total-rep.qty-chk-fuel.
   end.
  
end.
