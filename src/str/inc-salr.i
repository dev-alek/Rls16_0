/*

$Revision: 5b89e89c1f45, 2641, rls $
$Author: EShklyar $
$Date: 2020/12/04 13:41:03 $
$Workfile: inc-salr.i $
$Archive: str/inc-salr.i $

Процедура закачки чеков в продажу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/21/05
Author: Bakhtadze Natalya
Creation date: 03/21/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: inc-salr.i $ $Revision: 5b89e89c1f45, 2641, rls $".

{ str/inc-salf.i }
{ gbl/thbj-def.i }
{ str/valddnst.i def }
{ rep/r-pychk0.i defalgo }
{ rep/r-pychk0.i def    }

procedure r-pychk0:
define input parameter v-base-code as integer no-undo .
define input parameter p-doc-code as character no-undo .
_chk-doc:
for first ub.chk-doc no-lock where
          ub.chk-doc.doc-code = p-doc-code,
    each ub.chk-pay NO-LOCK WHERE
        ub.chk-pay.doc-code = ub.chk-doc.doc-code
BREAK
BY CHK-pay.DOC-CODE
BY CHK-pay.LINE-NUM:
  { rep/r-pychk0.i }
end.
end.

procedure proc-main :
define input parameter p-status_ like ub.trn-doc.status_ no-undo .
/*облагается дор налогом*/
define variable road as logical no-undo.
define variable for-price as decimal no-undo.
define variable for-excise as decimal no-undo.
define variable for-road as decimal no-undo.
define variable bottle as logical no-undo.
define variable accum-chk-doc-tot-doc as decimal no-undo.
define variable accum-chk-doc-discnt as decimal no-undo.
define variable accum-chk-doc-netto as decimal no-undo.
define variable accum-chk-doc-sub-discnt as decimal no-undo.
define variable accum-chk-pay-tot-sum-by as decimal no-undo.
define variable accum-chk-pay-tot-base-by as decimal no-undo.
define variable accum-chk-pay-tot-rubl-by as decimal no-undo.
define variable KIND-TO-RESERV as character no-undo .
define variable KIND-TO-RESERV-GDS as character no-undo .
define variable cli-type-to-reserv as character no-undo.
define variable cli-code-to-reserv as integer no-undo.
define variable v-real-doc-kind as character no-undo .
define variable office-TO-RESERV as character no-undo .
define variable office-TO-RESERV-GDS as character no-undo .

define variable docs-to-reserv as integer no-undo .    /*количество документов для резеривирования ЧЕКА вобщем*/
define variable docs-to-reserv-gds as integer no-undo . /*количество документов для резеривирования строки*/
define variable v-add as logical no-undo .
define variable dtrg as integer no-undo . /*счетчик документов по которым резервируем одну строку временной таблицы*/
define variable dtrg-start as logical no-undo .
define variable cashparts as logical no-undo.
define variable cashparts-chk as logical no-undo.
define variable serparts as logical no-undo.
define variable plcode like ub.place.pl-code no-undo.
define variable cashfbrs as logical no-undo .
define variable v-is-dish as character no-undo .
define variable v-deleted as logical no-undo .
define variable varchip-code as integer no-undo .
define variable varchip-code2 as integer no-undo .
define variable v-mes as character no-undo .
define variable v-clcdoc-vat-pc                     like ub.doc-line.vat-pc           no-undo.
define variable v-clcdoc-slt-pc                     like ub.doc-line.slt-pc           no-undo.
define variable glog as logical no-undo .
define variable action as character no-undo .
define variable other-doc-code as character no-undo .
define variable v-is-tpsi-obj as logical no-undo .
define variable v-tpsi-mode as integer no-undo .
define variable v-main-tpsi as logical no-undo .
/*тип выручки*/
DEFINE VARIABLE var-doc-type like ub.inkas-pay-desk.doc-type no-undo .
define variable v-rc-ii as integer no-undo initial 1.
define variable v-rc-max as integer no-undo .
define variable v-first as logical no-undo init yes .
define variable v-created as logical no-undo .
define variable v-created-dtl as logical no-undo .
define variable add-nf-amount as integer   no-undo .
define variable add-NF-gds-amount as integer   no-undo .
define variable v-dop as character no-undo .
define variable v-rec-inv-line as recid no-undo .
define variable nff-chk-amount as integer no-undo .
define variable v-cash-pay-attr as character no-undo.

define variable par-alcohol as character no-undo .
define variable par-type    as character no-undo .
define variable mark-ii     as integer no-undo .

define variable v-doc-code_fbr as character no-undo .

define variable v-pl-code   like ub.place.pl-code no-undo .
define variable v-pl-list   as character no-undo .
define variable v-pl-ii     as integer   no-undo .
define variable v-value     as character no-undo .
define variable v-ok        as logical   no-undo .
define variable v-Reconc-tank-attr as character no-undo .

define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define buffer buf_c-chk-doc for ub.c-chk-doc.
define buffer buf_c-chk-gds for ub.c-chk-gds.
define buffer buf_c-chk-pay for ub.c-chk-pay.
define buffer buf_c-chk-discnt for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_inkas-pay for ub.inkas-pay.
define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.
define buffer buf_place       for ub.place.
define buffer com_place       for ub.place.

define buffer dop_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer BUF_sale-doc for ub.sale-doc.
define buffer tpsi_sale-doc for ub.sale-doc.


do
on error undo, return error return-value
:
  if ink-doc.status_ = {&fact}
  then do:
  &scop my-message substitute("Продажа &1 уже закрыта:&2Докачка чеков не может быть произведена"  ~
                              , ink-doc.inkas-code          ~
                              , ~{&new-line~}                  ~
                              )
  {&display-message-laud} .
     UNDO, return error.
  end.
  find first ub.sysconf no-lock where
            ub.sysconf.host-code = ink-doc.host-code .
  if v-curr-r-b = {&r-b-base} or
  ub.sysconf.base-code = 0 then pychk_NO-exch = yes.
  else pychk_No-exch = no.
  if v-curr-r-b = {&r-b-rubl} or
  ub.sysconf.base-code = 0 then pychk_NO-exch-rubl = yes.
  else pychk_No-exch-rubl = no.

  assign
  accum-chk-doc-tot-doc = 0
  accum-chk-doc-discnt = 0
  accum-chk-doc-netto = 0
  accum-chk-doc-sub-discnt = 0
  v-rc-max = (if p-rid-list <> '':U then num-entries(p-rid-list) else 1)
  v-rc-ii = (if p-rid-list <> '':U
             then (if available X_chk-doc
                   then lookup(string(recid(X_chk-doc)), p-rid-list)
                   else v-rc-ii)
             else v-rc-ii)
  .
  run get-inkas-ps in this-procedure (
                                      buffer ink-doc
                                    , output chk-amount
                                    , output gds-amount
                                    , output line-out
                                    , output dtl-out
                                    , output line-ret
                                    , output dtl-ret
                                    , output nf-chk-amount
                                    , output nf-gds-amount
                                    , output p-filter-rus
                                    ).


  run get-tpsi-params in this-procedure (
                                          input ink-doc.obj-type
                                         ,input ink-doc.obj-code
                                         ,output v-is-tpsi-obj
                                         ,output v-tpsi-mode
                                         ,output v-main-tpsi ) no-error.
end. /*doe*/


do
on error undo, return error return-value
:
  for each buf_sale-doc where
           buf_sale-doc.inkas-code = ink-doc.inkas-code
       and buf_sale-doc.order > 0:
    buf_sale-doc.chk-doc-code = '':U.
  end.
  c-d:
  DO WHILE available X_chk-doc or (p-rid-list <> '':U and  v-rc-ii <= v-rc-max) or action = "next"
  on error undo c-d, NEXT c-d
  on stop undo c-d, NEXT c-d:
    action = '':U.
    if not v-first then do:
      if p-rid-list = "":U then do:
        ASSIGN
        glog = QUERY query-chk-doc:GET-next(no-LOCK) NO-ERROR.
        if available X_chk-doc then do:
          ASSIGN
          glog = QUERY query-chk-doc:GET-current(exclusive-LOCK, no-wait) NO-ERROR.
          /*GET NEXT query-chk-doc EXCLUSIVE-LOCK No-WAIT .*/
          if locked(X_chk-doc)
          or X_chk-doc.out-code <> ?
          then do:
            error-status:error = no.
            action = "next".
            next c-d.
          end.
        end.
      end.
      else do:
        assign
        v-rc-ii = v-rc-ii + 1.
        _v-rc:
        do while v-rc-ii <= v-rc-max:
          find first X_chk-doc exclusive-lock where
                    recid(X_chk-doc) = integer(entry(v-rc-ii, p-rid-list))  no-error  NO-WAIT.
          if locked X_chk-doc or not available X_chk-doc
          or X_chk-doc.out-code <> ?
          then do:
            assign
            v-rc-ii = v-rc-ii + 1.
            next _v-rc.
          end.
          else LEAVE _v-rc.
        end.
        if v-rc-ii > v-rc-max then release X_chk-doc.
      end.
      if (not available X_chk-doc and action = '':U)
      or (p-rid-list <> "":U and v-rc-ii > v-rc-max) then LEAVE c-d.
    end. /*if not v-first then do:*/
    if v-first then v-first = no.
    cr = 0.
    if lookup(string(X_chk-doc.chk-type), {&pre-receipt-codes}) > 0
    or lookup(string(X_chk-doc.chk-type), {&no-inkas-receipt-codes}) > 0
    or X_chk-doc.out-code <> ?
    then do:
      next c-d.
    end.
    if lookup(string(X_chk-doc.chk-type), {&receipt-codes-all}) = 0
    then do:
      next c-d.
    end.
    if lookup(string(X_chk-doc.chk-type), {&wth-receipt-codes}) > 0
    and is-wth = yes then do:
      NEXT c-d .
    end.
    if v-is-tpsi-obj then do:
      if (p-status_ = {&inquiry}
      and index(X_chk-doc.doc-code, '>':U)  > 0 )
      or (p-status_ = {&cash-desk}
          and v-tpsi-mode = 2
          and index(X_chk-doc.doc-code, '>':U)  = 0
          )
      then next c-d.
    end.
    if cas-shft then do:
      if ink-doc.doc-date <> X_chk-doc.shift-date OR ink-doc.shift-num <> X_chk-doc.shift-num then do:
        NEXT c-d .    /* пропускаем, если не та дата */
      end.
    end. /*cas-shft*/
    else do:
      if p-day-only then do:
        if ink-doc.doc-date <> X_chk-doc.shift-date then do:
          NEXT c-d .
        end.
        /* пропускаем, если не та дата */
      end.
      else do:
        if X_chk-doc.shift-date > ink-doc.shift-date
        /*и не установлен фильтр и не выборочно*/
        and ((p-rid-list = "":U and p-filter-on = no)
            or
            p-filter-on = no)
        then do:
          NEXT c-d .
        end.
        /* пропускаем, если не та дата */
      end.
    end. /*not cas-shft*/
    if replace(replace(replace(X_chk-doc.office
                               , {&gds-goods}
                               , '':U)
                       , {&gds-office}
                       , '':U)
               , {&comma-char}
               , '':U) <> '':U
    then do:
      NEXT c-d .
    end.
    if one-curs
    and LOokup(string(X_chk-doc.chk-type), {&no-docum-receipt-codes}) = 0 then do:
      if cas-curs then do:
        find first buf_chk-pay where buf_chk-pay.doc-code = X_chk-doc.doc-code No-LOCK No-ERROR.
        if abs(buf_chk-pay.tot-rubl / buf_chk-pay.tot-base - cursh / cursh-scale) > 0.00005 then NEXT c-d.
      end.
      else do:
        if
        X_chk-doc.cash-rate <> cursh
        or
        X_chk-doc.cash-scale <> cursh-scale  then NEXT c-d.
      end.
    end. /*if one-curs then do:*/
    assign
    p-ii = p-ii + 1
    .
    if p-ii < 10
    or (p-ii < 1000 and chk-amount modulo 10 = 0)
    or (p-ii < 10000 and chk-amount modulo 100 = 0)
    then do:
      run display-chk in p-call-handle (chk-amount, nf-chk-amount).
    end.
    if X_chk-doc.chk-type <> integer({&rcpt-z-rep}) and X_chk-doc.office <> "" then do:  
    docs-to-reserv = get-inc-sal (
                                  input string(X_chk-doc.chk-type)
                                , input X_chk-doc.netto
                                , input yes
                                , input X_chk-doc.office
                                , input ?
                                , output v-add
                                , output office-to-reserv
                                , output kind-to-reserv
                                , output add-nf-amount
                                ) no-error .
    end.
    else docs-to-reserv = 0 .

  
    /* Создание доп документов */
    
    v-cash-pay-attr = "".
    cli-type-to-reserv = "".
    cli-code-to-reserv = 0.
    
    if X_chk-doc.chk-type = integer({&rcpt-tech-refuell}) then do:
    
        for each buf_chk-pay where buf_chk-pay.doc-code = X_chk-doc.doc-code no-lock:
            
            find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = buf_chk-pay.pay-code
                                         and buf_cash-pay-attr.curr-code = buf_chk-pay.curr-code
                                         and buf_cash-pay-attr.attr-code = "dop-doc" no-lock no-error.
            
            if not available(buf_cash-pay-attr) then next.
            
            v-cash-pay-attr = buf_cash-pay-attr.attr-value.
            
            case entry(1, v-cash-pay-attr, ','):
            
                when {&sale-add-write-off} then do: /* Списание */
                    v-add = no.
                    docs-to-reserv = 1.
                    office-to-reserv = {&gds-goods}.
                    kind-to-reserv = entry(1, v-cash-pay-attr, ','). /* {&sale-add-write-off} */
                    cli-type-to-reserv = entry(2, v-cash-pay-attr, ',').
                    cli-code-to-reserv = int(entry(3, v-cash-pay-attr, ',')).
                end.
                
                when {&sale-add-tech-refuell} then do: /* Техпролив */
                    cli-type-to-reserv = entry(2, v-cash-pay-attr, ',').
                    cli-code-to-reserv = int(entry(3, v-cash-pay-attr, ',')).
                end.
                
                when {&sale-add-vir-res} then do: /* Перемещение в вирт.рез. */
                    kind-to-reserv = {&sale-add-vir-res}. /* {&sale-add-write-off} */
                    cli-type-to-reserv = entry(2, v-cash-pay-attr, ',').
                    cli-code-to-reserv = int(entry(3, v-cash-pay-attr, ',')).
                end.
                
                when 'none' then do:
                    docs-to-reserv = 0.
                    kind-to-reserv = 'none'.
                end. /* не создавать */
                
            end case.
            
        end. /* for each buf_chk-pay */
    
    end. /* if X_chk-doc.doc-type */
    
    if docs-to-reserv > 0
    and not (KIND-TO-RESERV = {&TDEDT_Ras_Vnesh_Kass}
             and office-to-reserv = {&gds-goods}) then do:
      do dtrg = 1 to docs-to-reserv:
        find first buf_sale-doc where
                  buf_Sale-doc.inkas-code = ink-doc.inkas-code
              and buf_sale-doc.doc-kind = entry(dtrg, kind-to-reserv)
              and buf_sale-doc.chr-office = entry(dtrg, office-to-reserv) no-error .
        if not available buf_sale-doc then do:
          run str/cresalad.p (
                          buffer trn-doc
                        , buffer dop_trn-doc
                        , input entry(dtrg, kind-to-reserv)
                        , input entry(dtrg, office-to-reserv)
                        , input cli-type-to-reserv
                        , input cli-code-to-reserv
                        , output other-doc-code) no-error .
          if error-status:error then do:
      &scop my-message substitute("&1 &2 &3&4&5&4&6"  ~
                                  , vss-workfile                   ~
                                  , vss-revision                   ~
                                  , vss-description                ~
                                  , ~{&new-line~}                  ~
                                  , error-status:get-message(1)    ~
                                  , return-value)
      {&display-message-laud} .
            undo c-d, next c-d.
          end. /*es */
        end. /*fot avail buf_sale-doc*/
      end. /*do dtrg*/
    end. /*if doc-to-reserv > 0
          and KIND-TO-RESERV <> {&TDEDT_Ras_Vnesh_Kass} then do:*/
    _one-check:
    do
    on error undo _one-check, leave _one-check
    on stop undo _one-check, leave _one-check
    :
      /*обработка товаров*/
      _buf_chk-gds:
      FOR EACH buf_chk-gds WHERE buf_chk-gds.doc-code = X_chk-doc.doc-code
      by buf_chk-gds.price-base 
      on error undo _one-check, LEAVE _one-check
      on stop undo _one-check, leave _one-check
      :
        buf_chk-gds.out-code = ink-doc.inkas-code .
        if buf_chk-gds.doc-qnty = 0 then do:
          assign
          GDS-AMOUNT = GDS-AMOUNT + 1
          nf-gds-amount = nf-gds-amount  + 1 when (  lookup( string(X_chk-doc.chk-type), {&no-docum-receipt-codes} )  >  0  )
          .
          NEXT _Buf_chk-gds.
        end.
         if X_chk-doc.chk-type <> integer({&rcpt-z-rep}) and X_chk-doc.office = "" then
         do:
         &scop my-message substitute("Чек &1 не имеет тип чека. Чек не будет закачан в продажу&2&3"  ~
                                  , X_chk-doc.doc-code             ~
                                  , ~{&new-line~}                  ~
                                  , return-value                   ~
                                  )

            {&display-message-laud} .
            undo _one-check, leave _one-check.
         end.
        docs-to-reserv-gds = get-inc-sal(
                                      input string(X_chk-doc.chk-type)
                                    , input X_chk-doc.netto
                                    , input no
                                    , input entry(1, buf_chk-gds.line-type, {&delim-par})
                                    , input string(BUF_CHK-GDS.WRITE-OFF-CODE)
                                    , output v-add
                                    , output office-to-reserv-gds
                                    , output kind-to-reserv-gds
                                    , output add-nf-gds-amount
                                    ) no-error.
        
        if X_chk-doc.chk-type = integer({&rcpt-tech-refuell}) then do:
        
            for each buf_chk-pay where buf_chk-pay.doc-code = X_chk-doc.doc-code no-lock:
                
                find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = buf_chk-pay.pay-code
                                             and buf_cash-pay-attr.curr-code = buf_chk-pay.curr-code
                                             and buf_cash-pay-attr.attr-code = "dop-doc" no-lock no-error.
                
                if not available(buf_cash-pay-attr) then next.
                
                v-cash-pay-attr = buf_cash-pay-attr.attr-value.
                
                case entry(1, v-cash-pay-attr, ','):
                    when {&sale-add-vir-res} then do: /* Перемещение в вирт.рез. */
                        assign
                        kind-to-reserv-gds = {&sale-add-vir-res}
                        docs-to-reserv-gds = 1
                        v-add = no
                        office-TO-RESERV-GDS = 'т'.
                    end.
                    when 'none' then do:
                        assign
                        kind-to-reserv-gds = 'none'
                        docs-to-reserv-gds = 0
                        v-add = no
                        office-TO-RESERV-GDS = 'т'.
                        
                        /* Создадим sale-doc */
                        create buf_sale-doc.
                        assign
                        buf_sale-doc.inkas-code = ink-doc.inkas-code
                        buf_sale-doc.storage =  {&table_trn-doc}
                        buf_sale-doc.host-code = ink-doc.host-code
                        buf_sale-doc.obj-type = ink-doc.obj-type
                        buf_sale-doc.obj-code = ink-doc.obj-code
                        buf_sale-doc.doc-kind  = 'none'
                        buf_sale-doc.order = 0
                        buf_sale-doc.chr-office = 'т'
                        buf_sale-doc.doc-code = ''.
                        
                    end.
                 end case.       
            end. /* for each buf_chk-pay */
        
        end. /* if X_chk-doc.doc-type */
        
        assign
        GDS-AMOUNT = GDS-AMOUNT + 1
        nf-gds-amount = nf-gds-amount  + add-nf-gds-amount
        .
        assign
        office-to-reserv-gds = (if v-add
                              then (office-to-reserv + (if kind-to-reserv-gds = '':u
                                                      then '':u
                                                      else {&comma-char}) +
                                  office-to-reserv-gds)
                              else  office-to-reserv-gds)
        kind-to-reserv-gds = (if v-add
                              then (kind-to-reserv + (if kind-to-reserv-gds = '':u
                                                      then '':u
                                                      else {&comma-char}) +
                                  kind-to-reserv-gds)
                            else  kind-to-reserv-gds)
          docs-to-reserv-gds = (docs-to-reserv  + docs-to-reserv-gds) when v-add
        .

        FIND FIRST ub.bar-code WHERE ub.bar-code.b-code = buf_chk-gds.b-code NO-LOCK NO-ERROR.
        release ub.goods.
        if avail ub.bar-code then
          FIND FIRST ub.goods WHERE
                     ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK.

        if buf_chk-gds.pump > 0 then do :
          if not avail ub.bar-code then do:
        &scop my-message substitute("&1 &2 &3&4Чек &5 строка &6,&4отсутствует в БД бар-код &7&4Чек не будет закачан в продажу"  ~
                                    , vss-workfile                   ~
                                    , vss-revision                   ~
                                    , vss-description                ~
                                    , ~{&new-line~}                  ~
                                    , X_chk-doc.doc-code             ~
                                    , buf_chk-gds.line-num           ~
                                    , buf_chk-gds.b-code)

        {&display-message-laud} .
            undo _one-check, leave _one-check.
          end.
          run findtank in this-procedure
                              (input p-obj-type,
                              input p-obj-code,
                              input buf_chk-gds.pump,
                              input buf_chk-gds.nozzle-code,
                              input buf_chk-gds.pl-code,
                              input ub.bar-code.gds-code,
                              output plcode) no-error.
          if error-status :error or plcode = ? then do:
  &scop my-message substitute("Чек &1 Бар-код &2 ТРК &3&4Не удается определить танк&4Чек не будет закачан в продажу&4&5"  ~
                              , X_chk-doc.doc-code             ~
                              , buf_chk-gds.b-code                   ~
                              , buf_chk-gds.pump                     ~
                              , ~{&new-line~}                  ~
                              , return-value                   ~
                              )

  {&display-message-laud} .
            UNDO _one-check, leave _one-check.
          end.
          find first buf_place no-lock where buf_place.pl-code = plcode no-error .
          if not available buf_place then do:
  &scop my-message substitute("Чек &1 Бар-код &2 ТРК &3&4Не удается определить резервуар&4Чек не будет закачан в продажу&4&5"  ~
                              , X_chk-doc.doc-code             ~
                              , buf_chk-gds.b-code                   ~
                              , buf_chk-gds.pump                     ~
                              , ~{&new-line~}                  ~
                              , return-value                   ~
                              )

  {&display-message-laud} .
            UNDO _one-check, leave _one-check.
          end.
          assign
            v-pl-code           = plcode
            buf_chk-gds.pl-code = plcode
            buf_chk-gds.loc1    = buf_place.loc1
          .
          /* Если на резервуаре включен признак Автозадвижка, мы должны проводить анализ убыли для всех Сообщающихся Резервуаров, */
          /* чтобы определить по какому из них вычислять среднюю плотность (ЗИ 7700198420 РАЗДЕЛЕНИЕ УЧЕТА ПО СДВОЕННЫМ РЕЗЕРВУАРАМ) */
          run placelib_get-attr (
            input {&place-auto-gate-valve}
            ,input buf_place.obj-code
            ,input buf_place.obj-type
            ,input buf_place.pl-code
            ,output v-value
            ,output v-ok     )
          no-error.
          if v-ok
          and logical(v-value)
          then do :
            v-pl-list = "" .
            run placelib_get-attr (
              input {&place-com-tanks}
              ,input buf_place.obj-code
              ,input buf_place.obj-type
              ,input buf_place.pl-code
              ,output v-value
              ,output v-ok     )
            no-error.
            if v-ok
            and v-value > ""
            then do :
              v-pl-list = string(buf_place.pl-code) .
              do v-pl-ii = 1 to num-entries(v-value) :
                for first com_place no-lock where com_place.obj-type = p-obj-type
                                              and com_place.obj-code = p-obj-code
                                              and com_place.loc1 = entry(v-pl-ii, v-value)
                                              and com_place.status_ = ""
                :
                  v-pl-list = v-pl-list + "," + string(com_place.pl-code) .
                end .
              end .
            end .
            if num-entries(v-pl-list) > 1
            then do :
              { str/vollosan.i
                goods.gds-code
                X_chk-doc.obj-type
                X_chk-doc.obj-code
                v-pl-list
                X_chk-doc.shift-date
                X_chk-doc.shift-num
                X_chk-doc.chk-date
                X_chk-doc.chk-time
                v-pl-code
                no-error
              }
              if error-status:error then do:
                &scop my-message substitute("Чек &1 Бар-код &2 ТРК &3&4Не удается определить резервуар среди сообщающихся &4&5&4Чек не будет закачан в продажу"  ~
                                  , X_chk-doc.doc-code             ~
                                  , t-gds.b-code                   ~
                                  , t-gds.pump                     ~
                                  , ~{&new-line~}                  ~
                                  , v-pl-list                   ~
                                  )
      
                {&display-message-laud} .
                UNDO _one-check, leave _one-check.
              end.
              if v-pl-code = 0
              or v-pl-code = ?
              then do :
                assign v-pl-code = plcode .
              end .
            end .
          end .
          
          /* расчет плотности топлива */
          if valid-density( buf_chk-gds.density, (goods.unit-base = goods.unit-cli)  ) <> true then do:
            v-Reconc-tank-attr = "" .
            { str/avrgdens.i
              goods.gds-code
              X_chk-doc.obj-type
              X_chk-doc.obj-code
              v-pl-code
              X_chk-doc.shift-date
              X_chk-doc.shift-num
              X_chk-doc.chk-date
              X_chk-doc.chk-time
              buf_chk-gds.density
              v-Reconc-tank-attr
              no-error
            }
            if error-status:error then do:
              &scop my-message substitute("Чек &1 Бар-код &2 ТРК &3&4Не удается определить плотность топлива в танке&4&5&4Чек не будет закачан в продажу"  ~
                                , X_chk-doc.doc-code             ~
                                , t-gds.b-code                   ~
                                , t-gds.pump                     ~
                                , ~{&new-line~}                  ~
                                , return-value                   ~
                                )
    
              {&display-message-laud} .
              UNDO _one-check, leave _one-check.
            end.
            if v-Reconc-tank-attr > ""
            then do :
              find first chk-gds-attr exclusive-lock where chk-gds-attr.doc-code = buf_chk-gds.doc-code
                                                       and chk-gds-attr.line-num = buf_chk-gds.line-num
                                                       and chk-gds-attr.attr-code = "Reconc-tank"
                                                       no-error .
              if not available chk-gds-attr
              then do :
                create chk-gds-attr .
                assign
                  chk-gds-attr.doc-code = buf_chk-gds.doc-code
                  chk-gds-attr.line-num = buf_chk-gds.line-num
                  chk-gds-attr.attr-code = "Reconc-tank"
                .
              end .
              assign
                chk-gds-attr.attr-value = v-Reconc-tank-attr
              .
            end .
          end.
          
        end . /* end_of pump > 0 */
        
define variable v-chk-gds-line-type-1    as character no-undo .
define variable v-office-to-reserv-gds-n as character no-undo .
define variable v-kind-to-reserv-gds-n   as character no-undo .

        if docs-to-reserv-gds <> 0 then do:
          v-chk-gds-line-type-1 = entry(1, buf_chk-gds.line-type, {&delim-par}) .
          
          
          if docs-to-reserv-gds > 0 then  do:
            if KIND-TO-RESERV-GDS <> 'none' then do :
              _dtrg-gds:
              do dtrg = 1 to docs-to-reserv-gds :
                v-office-to-reserv-gds-n = entry(dtrg, office-to-reserv-gds) . 
                if v-office-to-reserv-gds-n <> v-chk-gds-line-type-1 then next _dtrg-gds.
                v-kind-to-reserv-gds-n = entry(dtrg, kind-to-reserv-gds) .
              find first buf_sale-doc where
                        buf_Sale-doc.inkas-code = ink-doc.inkas-code
                    and buf_sale-doc.doc-kind = v-kind-to-reserv-gds-n
                    and buf_sale-doc.chr-office = v-office-to-reserv-gds-n
                    no-error .
              if available buf_sale-doc then next _dtrg-gds .
                run str/cresalad.p (
                                buffer trn-doc
                              , buffer dop_trn-doc
                              , input v-kind-to-reserv-gds-n
                              , input v-office-to-reserv-gds-n
                              , input cli-type-to-reserv
                              , input cli-code-to-reserv
                              , output other-doc-code) no-error .
                if error-status:error then do:
                  &scop my-message substitute("&1 &2 &3&4&5&4&6"  ~
                                              , vss-workfile                   ~
                                              , vss-revision                   ~
                                              , vss-description                ~
                                              , ~{&new-line~}                  ~
                                              , error-status:get-message(1)    ~
                                              , return-value)
                  {&display-message-laud} .
                  undo c-d, NEXT c-d.
                end. /*es */
              end. /* do dtrg = 1 to docs-to-reserv-gds :*/
            end . /* end_of if_kind-to-reserv */
          end. /* end_of if_rare_doc */


          dtrg-start = ?.
          v-real-doc-kind = ''.
          _dtrg-gds2:
          do dtrg = 1 to docs-to-reserv-gds:
            v-office-to-reserv-gds-n = entry(dtrg, office-to-reserv-gds) . 
            if v-office-to-reserv-gds-n <> v-chk-gds-line-type-1 then next _dtrg-gds2.
            
            v-kind-to-reserv-gds-n = entry(dtrg, kind-to-reserv-gds) .
            dtrg-start = (dtrg-start = ?) .
            v-real-doc-kind = v-real-doc-kind + v-kind-to-reserv-gds-n.
            find first buf_sale-doc where
                       buf_sale-doc.inkas-code = ink-doc.inkas-code
                   and buf_sale-doc.doc-kind = v-kind-to-reserv-gds-n
                   and buf_sale-doc.chr-office = v-office-to-reserv-gds-n
                   no-error.
                   
            if buf_chk-gds.grp-code = 0 then /* else - cуммовая строка */  do:
              /* find first t-gds: */
              if cr > 0 then do:
                if (buf_chk-gds.pump > 0) and (buf_chk-gds.pl-code = 0 or buf_chk-gds.pl-code = ?) then do:
                  if buf_chk-gds.nozzle-code <> 0 then
find first t-gds
     WHERE t-gds.doc-code    = buf_sale-doc.doc-code
       and t-gds.b-code      = buf_chk-gds.b-code
       and t-gds.drc         = recid(X_chk-doc)
       AND t-gds.pump        = buf_chk-gds.pump
       AND t-gds.nozzle-code = buf_chk-gds.nozzle-code NO-ERROR.
                  else
find first t-gds
     WHERE t-gds.doc-code    = buf_sale-doc.doc-code
       and t-gds.b-code      = buf_chk-gds.b-code
       and t-gds.drc         = recid(X_chk-doc)
       AND t-gds.pump        = buf_chk-gds.pump NO-ERROR.
                end.
                else do:
                  if buf_chk-gds.nozzle-code <> 0 then
find first t-gds
     WHERE t-gds.doc-code    = buf_sale-doc.doc-code
       and t-gds.b-code      = buf_chk-gds.b-code
       and t-gds.drc         = recid(X_chk-doc)
       AND t-gds.pump        = buf_chk-gds.pump
       AND t-gds.nozzle-code = buf_chk-gds.nozzle-code
       AND t-gds.pl-code     = buf_chk-gds.pl-code NO-ERROR.
                  else
find first t-gds
     WHERE t-gds.doc-code    = buf_sale-doc.doc-code
       and t-gds.b-code      = buf_chk-gds.b-code
       and t-gds.drc         = recid(X_chk-doc)
       AND t-gds.pump        = buf_chk-gds.pump
       AND t-gds.pl-code     = buf_chk-gds.pl-code NO-ERROR.
                end.
              end. /* end_of cr>0 */
              if not avail t-gds
              or cr = 0
              OR (t-gds.grc <> ? AND t-gds.grc <> recid(buf_chk-gds))
              or NOT (t-gds.fbr-obj-type = buf_chk-gds.depart-type
                      AND
                      t-gds.fbr-obj-code = buf_chk-gds.depart-code)
              then  do:
                /*второй раз искать не будем - сэкономим время*/
                if dtrg-start = yes then do:
                  assign
                  cashparts-chk = no
                  serparts = no
                  cashfbrs = no
                  .
                  if not avail bar-code then do:
        &scop my-message substitute("&1 &2 &3&4Чек &5 строка &6,&4отсутствует в БД бар-код &7&4Чек не будет закачан в продажу"  ~
                                    , vss-workfile                   ~
                                    , vss-revision                   ~
                                    , vss-description                ~
                                    , ~{&new-line~}                  ~
                                    , X_chk-doc.doc-code             ~
                                    , buf_chk-gds.line-num           ~
                                    , buf_chk-gds.b-code)

        {&display-message-laud} .
                    undo _one-check, leave _one-check.
                  end.
                  /*обычная продажа по партиям*/
                  if ub.bar-code.in-code <> "" then cashparts-chk = yes.
                  else cashparts-chk = no.

                  if buf_chk-gds.price-base = 0
                  and goods.gds-type = {&gds-office}
                  and (buf_Chk-gds.write-off-code = 0
                      or
                      buf_Chk-gds.write-off-code = ?) then do:
        &scop my-message substitute("&1 &2 &3&4Чек &5 строка &6, цена товара-услуги с бар-кодом &7=0&4Чек не будет закачан в продажу"  ~
                                    , vss-workfile                   ~
                                    , vss-revision                   ~
                                    , vss-description                ~
                                    , ~{&new-line~}                  ~
                                    , X_chk-doc.doc-code             ~
                                    , buf_chk-gds.line-num           ~
                                    , buf_chk-gds.b-code)
        {&display-message-laud} .

                    undo _one-check, leave _one-check.
                  end.
                  FIND FIRST ub.units No-LOCK WHERE
                            ub.units.unit-name = ub.goods.unit-base No-ERROR.
                  /*две единицы измерения */
                  if lookup({&twounit}, ub.units.type) > 0 then cashparts-chk = yes.
                  if prcl-spl or
                  can-find(first ub.tax-units No-LOCK WHERE
                                ub.tax-units.tax-code = exctaxcd AND
                                lookup(ub.tax-units.type , units.type) > 0 ) or
                  can-find(first ub.tax-units No-LOCK WHERE
                                ub.tax-units.tax-code = btltaxcd AND
                                lookup(ub.tax-units.type , units.type) > 0 )
                                then do:
                    { gbl/bcodeprc.i
                      p-obj-type
                      p-obj-code
                      ub.bar-code.b-code
                      0
                      0
                      gp-doc-num
                      gp-price-sale
                      for-road
                      for-excise
                      no-error
                    }
      &scop wro-code STRING(if buf_chk-gds.write-off-code <> ? then buf_chk-gds.write-off-code else 0)
                    if gp-price-sale = ?
                    and not {&wro-is-modificator}
                    then DO:
      &scop my-message substitute("Чек &1 Строка &2&3Бар-код &4 Артикул &5 &6&3Нет продажной цены&3Чек не будет закачан в продажу"  ~
                                  , X_chk-doc.doc-code             ~
                                  , Buf_chk-gds.line-num           ~
                                  , ~{&new-line~}                  ~
                                  , ub.bar-code.b-code                ~
                                  , ub.goods.artic                    ~
                                  , ub.goods.gds-name)

      {&display-message-laud} .
                      undo _one-check, leave _one-check.
                    END.
                    assign
                    for-price = gp-price-sale
                    for-excise = if can-find(first ub.tax-units No-LOCK WHERE
                                ub.tax-units.tax-code = exctaxcd AND
                                LOOKUP(ub.tax-units.type, units.type) > 0)
                                        then gp-excise
                                        else 0
                    .
                  end. /*prcl-spl*/
                  else
                  assign
                  for-price = buf_chk-gds.price-base + buf_chk-gds.price-service
                  for-excise = 0.
                  if can-find(first ub.tax-units No-LOCK WHERE
                                    ub.tax-units.tax-code = rdtaxcd AND
                                    LOOKUP(ub.tax-units.type, units.type) > 0)
                                    then road = yes.
                  else road = no.
                  assign
                  v-is-dish = "":u
                  .
                  if NOT (buf_chk-gds.depart-type = "":U and
                          buf_chk-gds.depart-code = 0)
                  AND NOT (buf_chk-gds.depart-type = ? and
                          buf_chk-gds.depart-code = ?)
                          then do:
                    { gbl/fgdsobjt.i p-obj-type p-obj-code goods.gds-code "'is-dish=request'" v-is-dish no-error  }
                  end.
                  if not error-status:error then do:
                    assign
                    cashfbrs = (integer(v-is-dish) > 0)
                    no-error .
                  end.
                end. /*if dtrg-start = yes*/
                { gbl/pftxvalg.i goods.gds-code {&vat-tax-code} ? ink-doc.host-code ink-doc.obj-type ink-doc.obj-code v-clcdoc-vat-pc no-error }
                find first dop_trn-doc no-lock where
                          dop_trn-doc.doc-code = buf_sale-doc.doc-code.
                { str/st-sltpc.i
                  recid(goods)
                  recid(dop_trn-doc)
                  buf_sale-doc.pay-code
                  v-clcdoc-slt-pc
                }
                
                cr = cr + 1 .
                FIND FIRST t-gds where t-gds.crf = cr use-index crfi No-ERROR.
                if available t-gds then do :
                  t-gds.marks = ''.
                end .
                else do :
                  create t-gds.
                  assign
                    t-gds.crf   = cr
                    t-gds.marks = ''
                  .
                end .

                if avail t-gds then do:
                  assign
                  t-gds.is-modificator = no
                  t-gds.price-base = 0
                  t-gds.price-service = 0
                  t-gds.doc-code = '':U
                  .
                end.
                assign
                t-gds.doc-code = buf_sale-doc.doc-code
                t-gds.b-code = buf_chk-gds.b-code
                t-gds.gds-code = goods.gds-code
                t-gds.artic = goods.artic
                t-gds.prod-type = goods.prod-type
                t-gds.prod-code = goods.prod-code
                t-gds.unit-base = goods.unit-base
                t-gds.cashparts = cashparts-chk
                t-gds.doc-qnty = 0
                t-gds.node-code = bar-code.node-code
                t-gds.drc = recid(X_chk-doc)
                t-gds.new-price = for-price
                t-gds.prt-root = goods.prt-root
                t-gds.price-sum = 0
                t-gds.discnt-sum = 0
                t-gds.service-sum = 0
                t-gds.road-sum = 0
                t-gds.num-lines = 0
                t-gds.pump = buf_chk-gds.pump
                t-gds.nozzle-code = buf_chk-gds.nozzle-code
                t-gds.loc1 = buf_chk-gds.loc1
                t-gds.pl-code = buf_chk-gds.pl-code
                t-gds.slt-pc = v-clcdoc-slt-pc
                t-gds.vat-pc = v-clcdoc-vat-pc
                t-gds.excise = for-excise
                t-gds.grc = (if LOOKUP({&twounit}, units.type) > 0 then recid(t-gds) else ?)
                t-gds.type = units.type
                t-gds.fbr-obj-type = buf_chk-gds.depart-type
                t-gds.fbr-obj-code = buf_chk-gds.depart-code
                t-gds.is-modificator =  if {&wro-is-modificator}
                                        or t-gds.is-modificator
                                        then yes
                                        else t-gds.is-modificator
                .
              end.
              assign
              t-gds.doc-qnty = t-gds.doc-qnty + buf_chk-gds.doc-qnty
              t-gds.num-lines = t-gds.num-lines + 1
              t-gds.price-base = if (buf_chk-gds.price-base + buf_chk-gds.price-service) > 0 then
                                (buf_chk-gds.price-base + buf_chk-gds.price-service)
                                                               else t-gds.price-base
              t-gds.price-service = if (buf_chk-gds.price-base + buf_chk-gds.price-service) > 0 then
                                    buf_chk-gds.price-service
                                                               else t-gds.price-service
              t-gds.discnt        = (if buf_sale-doc.doc-type = {&write-off}
                              then 0
                              else buf_chk-gds.discnt)
              t-gds.price-sum = t-gds.price-sum + GetRoundSum(buf_chk-gds.doc-code, buf_chk-gds.line-num, buf_chk-gds.doc-qnty, (buf_chk-gds.price-base + buf_chk-gds.price-service ))
                              /*  (buf_chk-gds.price-base + buf_chk-gds.price-service ) * buf_chk-gds.doc-qnty*/
              t-gds.discnt-sum  = t-gds.discnt-sum + (if buf_sale-doc.doc-type = {&write-off}
                                                      then 0
                                                      else buf_chk-gds.discnt * buf_chk-gds.doc-qnty)
              t-gds.road-sum = t-gds.road-sum + buf_chk-gds.road-tax * buf_chk-gds.doc-qnty
              t-gds.service-sum = t-gds.service-sum + buf_chk-gds.price-service * buf_chk-gds.doc-qnty
              t-gds.density = buf_chk-gds.density
              .
              run gds-attr-value(
                    t-gds.gds-code,
                    {&attr-mark},
                    output par-alcohol,
                    output par-type
              ).
              if par-alcohol = "yes" then do :
                find first chk-gds-attr exclusive-lock where chk-gds-attr.doc-code = buf_chk-gds.doc-code
                                                  and chk-gds-attr.line-num = buf_chk-gds.line-num
                                                  and chk-gds-attr.attr-code = "mark-code"
                                                  no-error .
                if available chk-gds-attr
/*                and not t-gds.marks matches ("*" + chk-gds-attr.attr-value + "*")*/
                then do :
                  if buf_chk-gds.doc-qnty < 0
                  then do mark-ii = 1 to num-entries(chk-gds-attr.attr-value) :
                      entry(mark-ii, chk-gds-attr.attr-value) = (if entry(mark-ii, chk-gds-attr.attr-value) begins "-" then "" else "-") 
                                                              + entry(mark-ii, chk-gds-attr.attr-value) .
                  end.
                  t-gds.marks = t-gds.marks + (if t-gds.marks = '' then '' else ',') + chk-gds-attr.attr-value .  
                end.  
                release chk-gds-attr no-error .
              end.
            end. /*несуммовой чек*/
          end. /*do dtrg to docs-to-reserv */

          if available t-gds then release t-gds .
          assign
          buf_chk-gds.line-type = entry(1, buf_chk-gds.line-type) + {&delim-par} +
                                  trim(v-real-doc-kind, {&comma-char})
                                  .

        end. /*fi docs-to-reserv > 0 */


      end. /*for each buf_chk-gds*/


      if docs-to-reserv > 0 or KIND-TO-RESERV = 'none' then do:
      /*к этому моменту имеем массив t-gds в которых лежат все данные для создания строк документов*/

        FOR EACH t-gds where t-gds.crf <= cr,
                 first buf_sale-doc where
                       buf_sale-doc.inkas-code = ink-doc.inkas-code
                   and buf_sale-doc.doc-code = t-gds.doc-code:
          if t-gds.doc-qnty = 0 AND
              t-gds.price-sum = 0 AND
              t-gds.discnt-sum = 0 then NEXT.
              
          /* ищем строку для товара в накладных */
          FIND FIRST buf_doc-line WHERE buf_doc-line.doc-code = t-gds.doc-code
                                and buf_doc-line.artic = t-gds.artic
                                and buf_doc-line.prod-type = t-gds.prod-type
                                and buf_doc-line.prod-code = t-gds.prod-code NO-ERROR .
          if NOT available buf_doc-line then do:
            assign
            v-created = yes
            .
              { str/crdoclin.i
                t-gds.doc-code
                t-gds.artic
                t-gds.prod-type
                t-gds.prod-code
                p-obj-type
                p-obj-code
                '':U
                buf_sale-doc.ext-doc-type
                t-gds.prt-root
                t-gds.VAT-pc
                t-gds.SLT-pc
                ub.sysconf.cons-vat-pc
                no-error
                }
            find first buf_doc-line where
                    buf_doc-line.doc-code = t-gds.doc-code
                AND buf_doc-line.artic = t-gds.artic
                AND buf_doc-line.prod-type = t-gds.prod-type
                AND buf_doc-line.prod-code = t-gds.prod-code .
            assign
            buf_doc-line.doc-qnty = 0
            buf_doc-line.fact-qnty = 0
            buf_doc-line.price-base = 0
            buf_doc-line.price-rubl = 0
            buf_doc-line.prt-OK = yes
            buf_doc-line.unit-cli = (if t-gds.pump > 0
                                     then t-gds.unit-cli
                                     else t-gds.unit-base)
            buf_doc-line.cli-base-rate = 1
            .
          end.  /*not avail doc-line*/
          else v-created = no.
          assign
          buf_doc-line.fact-qnty = buf_doc-line.fact-qnty + abs( t-gds.doc-qnty )
          .
          run gds-attr-value(
                t-gds.gds-code,
                {&attr-mark},
                output par-alcohol,
                output par-type
            ).
          if t-gds.marks <> '' and par-alcohol = "yes"
          then do :
            find first doc-line-attr exclusive-lock where doc-line-attr.doc-code = buf_doc-line.doc-code
                                                      and doc-line-attr.gds-code = t-gds.gds-code
                                                      and doc-line-attr.attr-code = 'mark-code'
                                                      no-error.
            if not available doc-line-attr
            then do :
              create doc-line-attr .
              assign
                doc-line-attr.doc-code = buf_doc-line.doc-code
                doc-line-attr.gds-code = t-gds.gds-code
                doc-line-attr.attr-code = 'mark-code'
              .  
            end.
            doc-line-attr.attr-value = doc-line-attr.attr-value + ',' + t-gds.marks .
            doc-line-attr.attr-value = trim(doc-line-attr.attr-value, ',') .
          end.  
          /*ищем нужное складское место*/
          if t-gds.pump > 0 then do:
            define variable v-doc-pl-rowid as rowid no-undo .
            define variable v-qnty as decimal no-undo .
            define variable v-cli-qnty as decimal no-undo .
            { str/crdocpl.i
              t-gds.doc-code
              t-gds.gds-code
              t-gds.pl-code
              X_chk-doc.obj-type
              X_chk-doc.obj-code
              v-doc-pl-rowid
              no-error
            }
            if error-status:error then do:
&scop my-message substitute("Чек &1 Бар-код &2 скл.место &3&4Не удается создать строку документа для скл.места&4&5&4Чек не будет закачан в продажу"  ~
                            , X_chk-doc.doc-code             ~
                            , t-gds.b-code                   ~
                            , t-gds.pl-code                  ~
                            , ~{&new-line~}                  ~
                            , return-value                   ~
                            )

  {&display-message-laud} .
              UNDO _one-check, leave _one-check.
            end.
            FIND FIRST ub.doc-pl WHERE rowid(ub.doc-pl) = v-doc-pl-rowid.
            assign
            ub.doc-pl.fact-qnty = ub.doc-pl.fact-qnty + abs( t-gds.doc-qnty )
            .

            assign
            ub.doc-pl.cli-fact-qnty = ub.doc-pl.cli-fact-qnty + abs( t-gds.doc-qnty ) * t-gds.density
            .
            release doc-pl.
            assign
            v-qnty     = 0.0
            v-cli-qnty = 0.0
            .
            for each ub.doc-pl no-lock where
                    ub.doc-pl.out-code = t-gds.doc-code
                and ub.doc-pl.gds-code = t-gds.gds-code:
              assign
              v-qnty     = v-qnty + ub.doc-pl.fact-qnty
              v-cli-qnty = v-cli-qnty + ub.doc-pl.cli-fact-qnty
              .
            end.
            assign
            buf_doc-line.fact-density = v-cli-qnty / v-qnty
            buf_doc-line.doc-density = buf_doc-line.fact-density
            .
            { str/corinvln.i
              buf_doc-line.doc-code
              buf_doc-line.artic
              buf_doc-line.prod-type
              buf_doc-line.prod-code
              ?
              ?
              ?
              ?
              " buf_doc-line.fact-qnty * buf_doc-line.fact-density "
              buf_doc-line.fact-density
              v-rec-inv-line
            }
            FIND FIRST ub.doc-pl-pump WHERE ub.doc-pl-pump.out-code = t-gds.doc-code AND
                                        ub.doc-pl-pump.gds-code = t-gds.gds-code AND
                                        ub.doc-pl-pump.pl-code = t-gds.pl-code AND
                                        ub.doc-pl-pump.obj-type = p-obj-type AND
                                        ub.doc-pl-pump.obj-code = p-obj-code AND
                                        ub.doc-pl-pump.pump-code = t-gds.pump
                                        NO-ERROR.
            IF not avail ub.doc-pl-pump THEN do:
              create ub.doc-pl-pump.
              assign
              ub.doc-pl-pump.obj-type = p-obj-type
              ub.doc-pl-pump.obj-code = p-obj-code
              ub.doc-pl-pump.out-code = t-gds.doc-code
              ub.doc-pl-pump.gds-code = t-gds.gds-code
              ub.doc-pl-pump.pl-code = t-gds.pl-code
              ub.doc-pl-pump.doc-qnty = 0
              ub.doc-pl-pump.fact-qnty = 0
              ub.doc-pl-pump.pump-code = t-gds.pump
              .
            end.
            assign
            ub.doc-pl-pump.fact-qnty = ub.doc-pl-pump.fact-qnty + abs( t-gds.doc-qnty ).

          end. /*if t-gds.pump > 0 */
          /*нельзя торговать одновременно по складским местам и по партиям*/
          if not t-gds.pump > 0 then do:
            /*ищем нужную партию*/
            if t-gds.cashparts then do:
              define variable v-nonunique as integer no-undo .
              if lookup({&twounit}, t-gds.type) > 0 then do:
                FIND FIRST ub.doc-prts WHERE
                            ub.doc-prts.out-code = t-gds.doc-code
                        AND ub.doc-prts.gds-code = t-gds.gds-code  NO-ERROR.
                v-nonunique = if available ub.doc-prts then (ub.doc-prts.b-code - 1) else -1 .
              end.
              else v-nonunique = t-gds.b-code .
              FIND FIRST ub.doc-prts
                   WHERE ub.doc-prts.out-code = t-gds.doc-code
                     AND ub.doc-prts.b-code   = v-nonunique 
                     AND ub.doc-prts.gds-code = t-gds.gds-code NO-ERROR.
                /*ДА ИМЕННО ТАК !!! если (if lookup({&twounit}, t-gds.type) > 0 то все кусочки по отдельности резервируем!!!*/
                IF not avail ub.doc-prts THEN do:
                  create ub.doc-prts.
                  assign
                  ub.doc-prts.out-code = t-gds.doc-code
                  ub.doc-prts.gds-code = t-gds.gds-code
                  ub.doc-prts.b-code =  (if lookup({&twounit}, t-gds.type) > 0
                                      then v-nonunique
                                      else t-gds.b-code)
                  ub.doc-prts.doc-qnty = 0
                  ub.doc-prts.fact-qnty = 0
                  .
                end. /*IF not avail doc-prts THEN do:*/
              assign
              ub.doc-prts.fact-qnty = ub.doc-prts.fact-qnty + abs( t-gds.doc-qnty ).
            END. /*if t-gds.cashparts then do:*/
          end. /*if not t-gds.pump > 0 then do:*/

          /*if buf_chk-gds.grp-code = 0 then /* else - cуммовая строка */  do:*/
          /* ищем признак для товара в накладных */
          assign
          v-created-dtl = no.
          if not v-created then do:
            FIND FIRST buf_gds-dtl WHERE buf_gds-dtl.doc-code  = buf_doc-line.doc-code
                                  and buf_gds-dtl.artic     = buf_doc-line.artic
                                  and buf_gds-dtl.prod-code = buf_doc-line.prod-code
                                  and buf_gds-dtl.prod-type = buf_doc-line.prod-type
                                  and buf_gds-dtl.prt-code  = t-gds.node-code NO-ERROR .
          end.
          if v-created or NOT available buf_gds-dtl then do:
            { str/crgdsdtl.i
              buf_doc-line.obj-code
              buf_doc-line.obj-type
              buf_doc-line.doc-code
              buf_doc-line.artic
              buf_doc-line.prod-code
              buf_doc-line.prod-type
              t-gds.node-code
              no
              no-error }
            if error-status:error then do:
  &scop my-message substitute("Чек &1 Бар-код &2&3Ошибка при создании признака для товара с кодом &4:&3&5&6&3Чек не будет закачан в продажу"  ~
                              , X_chk-doc.doc-code             ~
                              , t-gds.b-code                   ~
                              , ~{&new-line~}                  ~
                              , t-gds.gds-code                 ~
                              , error-status:get-message(1)    ~
                              , return-value                   ~
                              )

  {&display-message-laud}.
              UNDO _one-check, leave _one-check.
            end.
            assign
            v-created-dtl = yes
            .
            FIND FIRST buf_gds-dtl WHERE buf_gds-dtl.doc-code  = buf_doc-line.doc-code
                                and buf_gds-dtl.artic     = buf_doc-line.artic
                                and buf_gds-dtl.prod-code = buf_doc-line.prod-code
                                and buf_gds-dtl.prod-type = buf_doc-line.prod-type
                                and buf_gds-dtl.prt-code  = t-gds.node-code.
            assign
            buf_gds-dtl.discnt-type = no /* сумма */
            buf_gds-dtl.discnt-base = 0
            buf_gds-dtl.fact-qnty = 0
            buf_gds-dtl.doc-qnty = 0
            buf_gds-dtl.ov = yes.
          end.
          if Not (t-gds.fbr-obj-type = "":U and t-gds.fbr-obj-code = 0)
          and Not (t-gds.fbr-obj-type = ? and t-gds.fbr-obj-code = ?)
/*          and t-gds.doc-qnty >= 0*/
          then do:
            if t-gds.doc-qnty < 0
            then do :
              v-doc-code_fbr = replace(t-gds.doc-code, "=", "-") .
            end.
            else do :
              v-doc-code_fbr = t-gds.doc-code .
            end.  
            FIND FIRST ub.doc-fbr-gds WHERE ub.doc-fbr-gds.out-code = v-doc-code_fbr AND
                                    ub.doc-fbr-gds.gds-code = t-gds.gds-code AND
                                    ub.doc-fbr-gds.fbr-obj-type = t-gds.fbr-obj-type AND
                                    ub.doc-fbr-gds.fbr-obj-code = t-gds.fbr-obj-code AND
                                    ub.doc-fbr-gds.obj-type = p-obj-type AND
                                    ub.doc-fbr-gds.obj-code = p-obj-code
                                    NO-ERROR.
            IF not avail ub.doc-fbr-gds THEN do:
              create ub.doc-fbr-gds.
              assign
              ub.doc-fbr-gds.obj-type = p-obj-type
              ub.doc-fbr-gds.obj-code = p-obj-code
              ub.doc-fbr-gds.out-code = v-doc-code_fbr
              ub.doc-fbr-gds.gds-code = t-gds.gds-code
              ub.doc-fbr-gds.fbr-obj-type = t-gds.fbr-obj-type
              ub.doc-fbr-gds.fbr-obj-code = t-gds.fbr-obj-code
              ub.doc-fbr-gds.doc-qnty = 0
              ub.doc-fbr-gds.fact-qnty = 0
              .
            end. /*IF not avail doc-fbr-gds THEN do:*/
            assign
            ub.doc-fbr-gds.fact-qnty = ub.doc-fbr-gds.fact-qnty +  t-gds.doc-qnty .
          end.
  &scop discnt-r-b (if v-curr-r-b = {&r-b-base} then buf_gds-dtl.discnt-base else buf_gds-dtl.discnt-rubl)
  &scop price-r-b  (if v-curr-r-b = {&r-b-base} then buf_gds-dtl.price-base else buf_gds-dtl.price-rubl)
  define variable v-discnt-r-b like ub.gds-dtl.discnt-rubl no-undo .
  define variable v-price-r-b like ub.gds-dtl.price-rubl no-undo .
          assign
          v-discnt-r-b = (if (buf_gds-dtl.fact-qnty + abs(t-gds.doc-qnty)) = 0
                          then 0
                          else (if prcl-spl
                                  then
                                  (t-gds.new-price * (buf_gds-dtl.fact-qnty + abs(t-gds.doc-qnty))
                                  - ({&price-r-b} - {&discnt-r-b}) * buf_gds-dtl.fact-qnty
                                  - buf_sale-doc.msign * (t-gds.price-sum - t-gds.discnt-sum)
                                  ) / (buf_gds-dtl.fact-qnty + abs(t-gds.doc-qnty))
                                  else
                                  (t-gds.price-base * (buf_gds-dtl.fact-qnty + abs(t-gds.doc-qnty))
                                  - ({&price-r-b} - {&discnt-r-b}) * buf_gds-dtl.fact-qnty
                                  - buf_sale-doc.msign * (t-gds.price-sum - t-gds.discnt-sum)
                                  ) / (buf_gds-dtl.fact-qnty + abs(t-gds.doc-qnty))
                                )
                          )
          buf_gds-dtl.fact-qnty = buf_gds-dtl.fact-qnty + abs( t-gds.doc-qnty )
          v-price-r-b =  (if prcl-spl then  t-gds.new-price  else t-gds.price-base )
          buf_gds-dtl.price-base = (if v-curr-r-b = {&r-b-rubl}
                                then  v-price-r-b / trn-doc.base-rate * trn-doc.base-scale
                                else v-price-r-b)
          buf_gds-dtl.discnt-base = (if v-curr-r-b = {&r-b-rubl}
                                  then v-discnt-r-b / trn-doc.base-rate * trn-doc.base-scale
                                  else v-discnt-r-b )
          buf_gds-dtl.price-rubl = (if v-curr-r-b = {&r-b-base}
                                then v-price-r-b * trn-doc.base-rate / trn-doc.base-scale
                                else v-price-r-b)
          buf_gds-dtl.discnt-rubl = (if v-curr-r-b = {&r-b-base}
                                then v-discnt-r-b  * trn-doc.base-rate / trn-doc.base-scale
                                else v-discnt-r-b )
          buf_doc-line.road-tax = (if road
                              then
                              (buf_doc-line.road-tax * (buf_doc-line.fact-qnty - abs(t-gds.doc-qnty) ) +
                                buf_sale-doc.msign * t-gds.road-sum ) / (buf_doc-line.fact-qnty )
                              else 0)
          buf_doc-line.excise = (if road
                            then
                            t-gds.excise
                            else 0)
          buf_gds-dtl.discnt-pc = (if t-gds.is-modificator then 0 else buf_gds-dtl.discnt-pc)
          .

          if X_chk-doc.doc-code <> buf_sale-doc.chk-doc-code
          AND buf_sale-doc.main-receipt-type = X_chk-doc.chk-type
          then do:
            assign
            buf_sale-doc.chk-doc-code = X_chk-doc.doc-code
            buf_sale-doc.chk-amount = buf_sale-doc.chk-amount + 1
            .
          end.
          assign
          buf_sale-doc.tot-lines = buf_sale-doc.tot-lines + (if v-created then 1 else 0)
          line-out = line-out + (if buf_sale-doc.doc-kind = {&TDEDT_Ras_Vnesh_KASS}
                                 and v-created
                                 then 1
                                 else 0)
          line-ret = line-ret + (if buf_sale-doc.doc-kind = {&TDEDT_Vozvrat_Vnesh_KASS}
                                 and v-created
                                 then 1
                                 else 0)
          buf_sale-doc.tot-dtl = buf_sale-doc.tot-dtl + (if v-created-dtl then 1 else 0)
          dtl-out = dtl-out + (if buf_sale-doc.doc-kind = {&TDEDT_Ras_Vnesh_KASS}
                               and v-created-dtl
                               then 1
                               else 0)
          dtl-ret = dtl-ret + (if buf_sale-doc.doc-kind = {&TDEDT_Vozvrat_Vnesh_KASS}
                               and v-created-dtl
                               then 1
                               else 0)
          buf_sale-doc.gds-amount = buf_sale-doc.gds-amount + t-gds.num-lines
          buf_sale-doc.fact-qnty = buf_sale-doc.fact-qnty  + t-gds.doc-qnty * buf_sale-doc.msign.
        END . /*FOR EACH t-gds*/
        var-doc-type = '':U.
        if kind-to-reserv begins {&TDEDT_Ras_Vnesh_Kass} then do:
          var-doc-type =  {&income}.
        end.
        if kind-to-reserv begins {&TDEDT_Vozvrat_Vnesh_Kass} or v-cash-pay-attr <> "" then do: /* Тоже в расход пока (иначе не создастся оплата по чеку) */
          var-doc-type =  {&expense} .
        end.
        FOR  EACH buf_chk-pay WHERE buf_chk-pay.doc-code = X_chk-doc.doc-code
        BREAK
        BY buf_chk-pay.doc-code
        BY buf_chk-pay.pay-code
        BY buf_chk-pay.curr-code :
          if var-doc-type <> '':U
          or (X_chk-doc.chk-type <> integer({&cd-drawer})
              and
              lookup(string(X_chk-doc.chk-type), {&wth-receipt-codes}) > 0
              )
          then do:
            find first buf_inkas-pay-wth where
                      buf_inkas-pay-wth.inkas-code = ink-doc.inkas-code
                  and buf_inkas-pay-wth.pay-code = buf_chk-pay.pay-code
                  and buf_inkas-pay-wth.curr-code = buf_chk-pay.curr-code
                  and buf_inkas-pay-wth.wth-code = buf_chk-pay.wth-code
                  and buf_inkas-pay-wth.par-code = buf_chk-pay.par-code
                  and buf_inkas-pay-wth.pay-desk = X_chk-doc.pay-desk
                  and buf_inkas-pay-wth.cashier = X_chk-doc.cashier
                  and buf_inkas-pay-wth.chk-type = X_chk-doc.chk-type no-error.
            if not available  buf_inkas-pay-wth then do:
              create buf_inkas-pay-wth.
              assign
              buf_inkas-pay-wth.inkas-code = ink-doc.inkas-code
              buf_inkas-pay-wth.pay-code = buf_chk-pay.pay-code
              buf_inkas-pay-wth.curr-code = buf_chk-pay.curr-code
              buf_inkas-pay-wth.wth-code = buf_chk-pay.wth-code
              buf_inkas-pay-wth.par-code = buf_chk-pay.par-code
              buf_inkas-pay-wth.pay-desk = X_chk-doc.pay-desk
              buf_inkas-pay-wth.cashier = X_chk-doc.cashier
              buf_inkas-pay-wth.chk-type = X_chk-doc.chk-type
              buf_inkas-pay-wth.par-val = buf_chk-pay.par-val
              .
            end.
            assign
            buf_inkas-pay-wth.tot-sum = buf_inkas-pay-wth.tot-sum + buf_chk-pay.tot-sum
            buf_inkas-pay-wth.tot-base = buf_inkas-pay-wth.tot-base + buf_chk-pay.tot-base
            buf_inkas-pay-wth.tot-rubl = buf_inkas-pay-wth.tot-rubl + buf_chk-pay.tot-rubl
            buf_inkas-pay-wth.doc-qnty = buf_inkas-pay-wth.doc-qnty + buf_chk-pay.doc-qnty
            buf_inkas-pay-wth.tot-lines = buf_inkas-pay-wth.tot-lines + 1
            .
          end. /*          if var-doc-type <> '':U */
          IF FIRST-OF(buf_chk-pay.curr-code) then do:
            assign
            accum-chk-pay-tot-sum-by = 0
            accum-chk-pay-tot-base-by = 0
            accum-chk-pay-tot-rubl-by = 0
            .
          end. /*IF FIRST-OF(buf_chk-pay.curr-code) then do:*/
          assign
          accum-chk-pay-tot-sum-by = accum-chk-pay-tot-sum-by + buf_chk-pay.tot-sum
          accum-chk-pay-tot-base-by = accum-chk-pay-tot-base-by + buf_chk-pay.tot-base
          accum-chk-pay-tot-rubl-by = accum-chk-pay-tot-rubl-by + buf_chk-pay.tot-rubl
          .
          buf_chk-pay.out-code = ink-doc.inkas-code .
          if last-of( buf_chk-pay.curr-code ) then  do:
            FIND FIRST buf_inkas-pay WHERE
                        buf_inkas-pay.inkas-code = ink-doc.inkas-code AND
                        buf_inkas-pay.pay-code = buf_chk-pay.pay-code AND
                        buf_inkas-pay.curr-code = buf_chk-pay.curr-code NO-ERROR.
            if NOT available buf_inkas-pay then do:
              CREATE buf_inkas-pay.
              assign
              buf_inkas-pay.inkas-code = ink-doc.inkas-code
              buf_inkas-pay.pay-code = buf_chk-pay.pay-code
              buf_inkas-pay.curr-code = buf_chk-pay.curr-code
              buf_inkas-pay.tot-sum = 0
              buf_inkas-pay.tot-base = 0
              buf_inkas-pay.tot-rubl = 0
              .
            end. /*if NOT available buf_inkas-pay then do:*/
            if var-doc-type <> '':U then do:
              FIND FIRST buf_inkas-pay-desk WHERE
                          buf_inkas-pay-desk.inkas-code = ink-doc.inkas-code AND
                          buf_inkas-pay-desk.pay-code = buf_chk-pay.pay-code AND
                          buf_inkas-pay-desk.curr-code = buf_chk-pay.curr-code AND
                          buf_inkas-pay-desk.pay-desk = X_chk-doc.pay-desk AND
                          buf_inkas-pay-desk.doc-type = var-doc-type AND
                          buf_inkas-pay-desk.cashier = X_chk-doc.cashier
                          NO-ERROR.
              if NOT available buf_inkas-pay-desk then do:
                CREATE buf_inkas-pay-desk.
                assign
                buf_inkas-pay-desk.inkas-code = ink-doc.inkas-code
                buf_inkas-pay-desk.pay-code = buf_chk-pay.pay-code
                buf_inkas-pay-desk.curr-code = buf_chk-pay.curr-code
                buf_inkas-pay-desk.pay-desk = X_chk-doc.pay-desk
                buf_inkas-pay-desk.tot-sum = 0
                buf_inkas-pay-desk.tot-base = 0
                buf_inkas-pay-desk.tot-rubl = 0
                buf_inkas-pay-desk.doc-type = var-doc-type
                buf_inkas-pay-desk.cashier = X_chk-doc.cashier
                .
              end. /*if NOT available buf_inkas-pay-desk then do:*/
              assign
              buf_inkas-pay.tot-sum = buf_inkas-pay.tot-sum + accum-chk-pay-tot-sum-by
              buf_inkas-pay.tot-base = buf_inkas-pay.tot-base + accum-chk-pay-tot-base-by
              buf_inkas-pay.tot-rubl = buf_inkas-pay.tot-rubl + accum-chk-pay-tot-rubl-by
              buf_inkas-pay-desk.tot-sum = buf_inkas-pay-desk.tot-sum + accum-chk-pay-tot-sum-by
              buf_inkas-pay-desk.tot-base = buf_inkas-pay-desk.tot-base + accum-chk-pay-tot-base-by
              buf_inkas-pay-desk.tot-rubl = buf_inkas-pay-desk.tot-rubl + accum-chk-pay-tot-rubl-by
              .
            end. /*if vardoc-type <> '':U*/
          end.  /*        if last-of( buf_chk-pay.curr-code )*/
        END. /* FOR  EACH buf_chk-pay WHERE buf_chk-pay.doc-code = X_chk-doc.doc-code конец обработки оплат*/
        FOR EACH buf_chk-discnt where
                  buf_chk-discnt.doc-code = X_chk-doc.doc-code
        on error undo _one-check, leave _one-check:
          assign
          buf_chk-discnt.out-code = ink-doc.inkas-code
          .
        end.
      end. /*if docs-to0-resertv > 0 */


     if X_chk-doc.chk-type = integer({&rcpt-z-rep})
     or X_chk-doc.chk-type = integer({&income-corr})
     or X_chk-doc.chk-type = integer({&expense-corr})
     then do:
        for each buf_chk-pay where
               buf_chk-pay.doc-code = X_chk-doc.doc-code
         on error undo c-d, NEXT c-d:
           buf_chk-pay.out-code = ink-doc.inkas-code .
        end.
      end.
      /*история*/
      for each buf_c-chk-doc where
              buf_c-chk-doc.doc-code = X_chk-doc.doc-code
      on error undo c-d, NEXT c-d:
        assign
        buf_c-chk-doc.out-code = ink-doc.inkas-code
        .
      end.
      for each buf_c-chk-gds where
              buf_c-chk-gds.doc-code = X_chk-doc.doc-code
      on error undo c-d, NEXT c-d:
        assign
        buf_c-chk-gds.out-code = ink-doc.inkas-code
        .
      end.
      for each buf_c-chk-discnt where
              buf_c-chk-discnt.doc-code = X_chk-doc.doc-code
      on error undo c-d, NEXT c-d:
        assign
        buf_c-chk-discnt.out-code = ink-doc.inkas-code
        .
      end.
      for each buf_c-chk-pay where
              buf_c-chk-pay.doc-code = X_chk-doc.doc-code
      on error undo c-d, NEXT c-d:
        assign
        buf_c-chk-pay.out-code = ink-doc.inkas-code
        .
      end.
      for each buf_c-chk-doc-attr where
              buf_c-chk-doc-attr.doc-code = X_chk-doc.doc-code
      on error undo c-d, NEXT c-d:
        assign
        buf_c-chk-doc-attr.out-code = ink-doc.inkas-code
        .
      end.
      for each buf_chk-gds-pay where
              buf_chk-gds-pay.doc-code = X_chk-doc.doc-code
      on error undo c-d, NEXT c-d:
        assign
        buf_chk-gds-pay.out-code = ink-doc.inkas-code
        .
      end.
      
      X_chk-doc.out-code = ink-doc.inkas-code.
      
      if pay-gds-algo <> '' then do:
        if lookup(string(X_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then do:
        end.
        else do:
          run r-pychk0 in this-procedure ( input ub.sysconf.base-code
                                          ,input X_chk-doc.doc-code) no-error.
          if error-status:error then do:              
              &scop my-message substitute("Чек &1 возникла ошибка при формировании распределения платежей. Чек не будет закачан в продажу&2&3"  ~
                                  , X_chk-doc.doc-code             ~
                                  , ~{&new-line~}                  ~
                                  , return-value                   ~
                                  )

              {&display-message-laud} .               
              undo _one-check, leave _one-check.
          end.                                    
        end.
      end.
      
      /*чек в целом*/
      assign      
      chk-amount = chk-amount + 1
      nf-chk-amount = nf-chk-amount + add-nf-amount
      nff-chk-amount = nff-chk-amount + (if lookup(string(X_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then 1 else 0)
      .
      if X_chk-doc.chk-type <> integer({&income-corr}) and X_chk-doc.chk-type <> integer({&expense-corr})
      then
      assign
      accum-chk-doc-tot-doc = accum-chk-doc-tot-doc  + X_chk-doc.tot-doc
      accum-chk-doc-discnt = accum-chk-doc-discnt + X_chk-doc.discnt
      accum-chk-doc-netto = accum-chk-doc-netto + X_chk-doc.netto
      accum-chk-doc-sub-discnt = accum-chk-doc-sub-discnt + X_chk-doc.sub-discnt
      .
      
      if p-ii < 10
      or (p-ii < 1000 and chk-amount modulo 10 = 0)
      or (p-ii < 10000 and chk-amount modulo 100 = 0)
      then
      run display-ink-doc in p-call-handle(
                                            input gds-amount
                                           ,input nf-gds-amount
                                           ,input line-out
                                           ,input line-ret
                                           ,input dtl-out
                                           ,input dtl-ret
                                            ).
      assign
      p-ii-ok = p-ii-ok + 1
      .
    end. /*doe - one-ch*/
  END. /* do _c-d*/
  /* формирование отчета о выручке */
  assign
  ink-doc.tot-doc = ink-doc.tot-doc + accum-chk-doc-tot-doc
  ink-doc.discnt = ink-doc.discnt + accum-chk-doc-discnt
  ink-doc.netto = ink-doc.netto + accum-chk-doc-netto
  ink-doc.sub-discnt = ink-doc.sub-discnt + accum-chk-doc-sub-discnt
  ink-doc.num-chk = chk-amount
  ink-doc.num-chk-nf = nf-chk-amount
  ink-doc.num-chk-nff = nff-chk-amount
  .
  assign
  ink-doc.qnty = 0
  .
  for each buf_sale-doc where
           buf_sale-doc.inkas-code = ink-doc.inkas-code
       and buf_sale-doc.order > 0,
      first dop_trn-doc where dop_trn-doc.doc-code = buf_sale-doc.doc-code:
    assign
    dop_trn-doc.fact-qnty = buf_sale-doc.fact-qnty
    dop_trn-doc.tot-lines = buf_sale-doc.tot-lines
    buf_sale-doc.filled = buf_sale-doc.tot-lines <> 0 or buf_sale-doc.fact-qnty <> 0
    .
    dop_trn-doc.ps = set-sale-doc-ps(buffer buf_sale-doc)
    .
    /*количествов СЧИТАЕМ ТОЛЬКО ПО расход и возврат БЕЗ ДОПОЛНИТЕЛЬНЫХ!!*/
    if buf_sale-doc.in-inkas then
    assign
    ink-doc.qnty = ink-doc.qnty + buf_sale-doc.fact-qnty * (if lookup(buf_sale-doc.ext-doc-type, {&TDEDT_incorrect_sign}) > 0 then - 1 else 1)
    .
  END.
  /*количествов чеков и строк чеков считается вместе с PETROL!!!*/
  assign
  ink-doc.PS = set-inkas-ps (
                          input ink-doc.ps
                        , input chk-amount
                        , input gds-amount
                        , input line-out
                        , input dtl-out
                        , input line-ret
                        , input dtl-ret
                        , input nf-chk-amount
                        , input nf-gds-amount
                        , input p-filter-rus
                        ).

    for each buf_sale-doc where
            buf_sale-doc.inkas-code = ink-doc.inkas-code,
      first dop_trn-doc where dop_trn-doc.doc-code = buf_sale-doc.doc-code:
    if buf_sale-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_Kass}
    and not can-find(first buf_doc-line no-lock where
                    buf_doc-line.doc-code = dop_trn-doc.doc-code) then do:
      assign
      dop_trn-doc.status_ = {&wayb}
      dop_trn-doc.flag_ = no.
      run str/del-doc.p (
          input parparentproc,
          input  buf_sale-doc.doc-code,
          input  g#db-num,
          input  "del-doc.err",
          input  ?,
          input  ?,
          input  g#userid,
          input  '0',
          input  varchip-code,
          output varchip-code2)
          no-error.
      if error-status:error then do:
        assign
        v-mes =  substitute("Ошибка при удалении ПУСТОГО документа &1 для продажи &2&3:&3&4&3&5"
                                , buf_sale-doc.doc-code
                                , ink-doc.inkas-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).

&scop my-message v-mes
{&display-message-laud} .

        next .
      end.
      else do:
        delete buf_sale-doc.
      end.
    end.
  end. /*for each buf_sale-doc*/


  /*дальнейшее заполнение примечаний по паре накладных перенесено в sale.w*/
  if can-find(first buf_doc-line no-lock where
                  buf_doc-line.doc-code = trn-doc.doc-code)
  and
  not (old-doc-date = new-doc-date
        AND
        old-shift-date = new-shift-date
        AND
        old-shift-num  = new-shift-num) then do:
    _tpsi_sale-doc:
    for each tpsi_sale-doc where
            tpsi_sale-doc.inkas-code = ink-doc.inkas-code
        and tpsi_sale-doc.tpsidoc = yes,
      first buf_trn-doc EXCLUSIVE-LOCK where
          buf_trn-doc.doc-code = tpsi_sale-doc.doc-code
    on error undo, return error
    :
      assign
      buf_trn-doc.status_ = {&wayb}
      buf_trn-doc.flag_ = no.
      run str/del-doc.p (
          input parparentproc,
          input  tpsi_sale-doc.doc-code,
          input  g#db-num,
          input  "del-doc.err",
          input  ?,
          input  ?,
          input  g#userid,
          input  '0',
          input  varchip-code,
          output varchip-code2)
          no-error.
      if error-status:error then do:
        assign
        v-mes =  substitute("Ошибка при удалении ПУСТОГО расходного документа ЧУЖИХ товаров &1 по объекту &2&3 для продажи &4 &5:&3&6 &7"
                                , tpsi_sale-doc.doc-code
                                , (tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code))
                                , {&new-line}
                                , ink-doc.inkas-code
                                , (ink-doc.obj-type + string(ink-doc.obj-code))
                                , error-status:get-message(1)
                                , return-value ).

&scop my-message v-mes
{&display-message-laud} .

        UNDO , return error.
      end.
      else do:
        delete tpsi_sale-doc.
      end.
    end. /* for each tpsi_sale-doc */
    for each tt0-gds-dtl:
      delete tt0-gds-dtl.
    end.
    for each tt0-doc-line:
      delete tt0-doc-line.
    end.
  end. /**/
  run display-chk in p-call-handle (chk-amount, nf-chk-amount).
  run display-ink-doc in p-call-handle(
                                         input gds-amount
                                        ,input nf-gds-amount
                                        ,input line-out
                                        ,input line-ret
                                        ,input dtl-out
                                        ,input dtl-ret
                                        ).
end. /*doe*/
end procedure. /* proc-main */

PROCEDURE Get-tpsi-params :
define input  parameter p-obj-type like ub.clients.obj-type no-undo.
define input  parameter p-obj-code like ub.clients.obj-code no-undo.
define output parameter p-is-tpsi-obj as logical no-undo .
define output parameter p-tpsi-mode as integer no-undo .
define output parameter p-main-tpsi as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .



run gbl/tpsi-obj.p (
                input p-obj-type
              , input p-obj-code
              , output p-is-tpsi-obj) no-error .

if p-is-tpsi-obj then do:
   /*проверим моду ТПСИ*/
  run adm/shattri.p (
      input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  {&attr-autosale}
    ,input  "":U /*p-param-code*/
    , output v-value-character
    , output v-value-date
    , output v-value-decimal
    , output v-value-integer
    , output v-value-logical
    , output v-param-type
    , INPUT-OUTPUT table-handle v-tth
    ) no-error .
  IF error-status:error then do:
     message
     substitute("Ошибка при получении опций продажи НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , p-obj-type
              , p-obj-code
              , {&new-line}
              , error-status:get-message(1)
              , return-value )
     view-as alert-box error .
     undo, return error .
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
        and thbjattr_thbj-attr.prop-code = {&attr-autosale_tpsi-mode} no-error.
  if available thbjattr_thbj-attr then do:
    p-tpsi-mode = thbjattr_thbj-attr.property-value-integer.
  end.
  if p-tpsi-mode = 2 then do:
    /*проверим главный ли*/
    find first thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = p-obj-type
          and thbjattr_thbj-attr.obj-code = p-obj-code
          and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
          and thbjattr_thbj-attr.prop-code = {&attr-autosale_main-tpsi} no-error.
    if available thbjattr_thbj-attr then do:
      p-main-tpsi = thbjattr_thbj-attr.property-value-logical.
    end.
  end.
end.

END PROCEDURE.


/* $Workfile: inc-salr.i $   E n d */