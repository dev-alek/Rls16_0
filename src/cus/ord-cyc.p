block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-cyc.p $
$Archive: cus/ord-cyc.p $

Расчет  повторяющихся заказов по всей фирме

Автор: Чернова Светлана Александровна
Дата создания: 08/21/01
Author: Svetlana Chernova
Creation date: 08/21/01

*/

define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer   no-undo .
define input parameter p-log-handle  as handle no-undo .
define output parameter p-kol-zakz as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-cyc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-cyc.p $":U .
define variable vss-description as character no-undo init "Расчет  повторяющихся заказов по всей фирме".

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ cmp/df-sub.i   }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ cus/ord-code.i def }
{ gbl/thbjattr.i }
{ cus/orddoatt.i }
{ cus/ordlnatt.i }
{ str/cont-ms-def.i }


define variable log-file-name   as character no-undo init "ord-cycle.txt".
define variable v-error         as logical   no-undo .
define variable v-message       as character no-undo .
define variable v-contract-curr as integer   no-undo .

function string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date =  date(integer(substring(p-string, 4, 2))
                ,integer(substring(p-string, 1, 2))
                , year(date(p-string))
               ) no-error .
  if error-status:error then return ?.
  return v-date.

END FUNCTION.

define variable g#host-name    as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable g#db-remote    as logical   no-undo .
define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
define variable v-value-date      like ub.thbj-attr.property-value-date no-undo .
define variable v-value-decimal   like ub.thbj-attr.property-value-decimal no-undo .
define variable v-value-logical   like ub.thbj-attr.property-value-logical no-undo .
define variable v-value-integer   like ub.thbj-attr.property-value-integer no-undo .
define variable v-type     as character no-undo .
define variable v-ordcyclg as logical   no-undo .
define variable kk         as integer   no-undo .

define temp-table tt-ord-doc no-undo like  ub.ord-doc.
define temp-table tt-ord-line no-undo like ub.ord-line.

{ gbl/hostname.i p-obj-type p-obj-code  g#host-code g#host-name }
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
       input "get":U
      ,input ""
      ,input 0
      ,input {&attr-ord-global}
      ,input  "ordcyclg"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-ordcyclg
      ,output v-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then v-ordcyclg = false .


define buffer newb_ord-doc  for ub.ord-doc.
define buffer newb_ord-line for ub.ord-line.
define buffer grpb_contract-specif for ub.contract-specif  .
define buffer grpb_goods for ub.goods  .
define buffer buf_goods  for ub.goods  .


define variable i as integer no-undo init 0 .
define variable loc-ord-num1 as char no-undo  .
define variable loc-ord-num  as char no-undo  .
define variable loc-date-ship as date no-undo  .
define variable v-i-doc as character no-undo .
define variable v-make-from-specif as logical   no-undo .

/* Галка цикличный
0  копия уже сделана
1  копии еще нет
2  копии еще нет
 */
 if g#auto = false then do:
   { gbl/curobjdt.i p-obj-type p-obj-code to-day no-error }
end.
else do:
   { gbl/objdtget.i p-obj-type p-obj-code to-day no-error }
end.
if error-status :error then do:
v-message = substitute("&3&4 Ошибка при проверке даты на объекте: &2 &1" , error-status :get-message(1) , return-value ,p-obj-type, p-obj-code) .
       if g#auto = false then do:
          message v-message  view-as alert-box information .
       end.
       else do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-message ) no-error .

       end.
      return.
end.

for each ub.ord-doc where ub.ord-doc.cycle-day > 0
                       and ub.ord-doc.host-code = G#host-code
                       and ub.ord-doc.obj-type  = p-obj-type
                       and ub.ord-doc.obj-code  = p-obj-code
                       and (integer(to-day - ub.ord-doc.doc-date) >= ub.ord-doc.cycle-day)
                       and ub.ord-doc.order-type = 1
                       and ub.ord-doc.status_ <> {&g___new}
                         exclusive-lock   :

    { cus/ord-code.i
    'main'
    g#db-num
    ub.ord-doc.obj-type
    ub.ord-doc.obj-code
    v-i-doc
    loc-ord-num
    }

    if g#auto then do:
      v-message = substitute("&3&4 Создание нового заказа № &1 по заказу &2 " , loc-ord-num , ub.ord-doc.doc-code , ub.ord-doc.obj-type, ub.ord-doc.obj-code ) .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input v-message ) no-error .
    end.

    Assign
    i = i + 1
    loc-date-ship = ub.ord-doc.ship-date
    no-error.
    if i = 1 then loc-ord-num1 = loc-ord-num .

    create newb_ord-doc.
    buffer-copy ub.ord-doc except ub.ord-doc.doc-code to newb_ord-doc
           Assign newb_ord-doc.doc-code  = loc-ord-num
                  newb_ord-doc.doc-date  = to-day
                  newb_ord-doc.ship-date = if ( (loc-date-ship + ub.ord-doc.cycle-day) < to-day ) then  to-day
                                       else (loc-date-ship + ub.ord-doc.cycle-day)
                  newb_ord-doc.status_  = {&g___new}
                  newb_ord-doc.ord-int1 = 0
                  newb_ord-doc.ord-int2 = 0
                  newb_ord-doc.fact-date = ?
                  newb_ord-doc.fact-order = 0
                  newb_ord-doc.date-sale-1 = ub.ord-doc.date-sale-1 + ub.ord-doc.cycle-day
                  newb_ord-doc.date-sale-2 = ub.ord-doc.date-sale-2 + ub.ord-doc.cycle-day
                  newb_ord-doc.PS         =  substitute("по &1 " , ub.ord-doc.doc-code  )
           .
           kk = 0.
          /* поиск подходящего договора */
           run current-contract (input ub.ord-doc.doc-code , output v-contract-curr ) .
           newb_ord-doc.contract-code = v-contract-curr.
           for each ub.ord-line no-lock where
                    ub.ord-line.doc-code  = ub.ord-doc.doc-code ,
              first buf_goods no-lock where
                    buf_goods.gds-code = ub.ord-line.gds-code
                    by ub.ord-line.line-num :
              if v-ordcyclg then do: /* Копирование по спецификации и группам */
                  if  v-contract-curr <> 0 and
/*
                       can-find (first ub.contract-specif no-lock where
                                       ub.contract-specif.host-code    = ub.ord-doc.host-code and
                                       ub.contract-specif.contract-num = v-contract-curr and
                                       ub.contract-specif.gds-code     = ub.ord-line.gds-code )
*/ 
                      Can-Find-Spec  ( ub.ord-doc.host-code,
                                       v-contract-curr,
                                       ub.ord-line.gds-code)

                  then do: /* Спецификация есть по товару */
/*
                      for each grpb_contract-specif no-lock where
                               grpb_contract-specif.host-code    = ub.ord-doc.host-code and
                               grpb_contract-specif.contract-num = v-contract-curr ,
*/ 
                      {str/cont-slave-inc.i
                           &FOR_ = YES
                           &EACH_ = YES
                           &BUFFER_SPECIF  = grpb_contract-specif
                           &P_HOST_CODE    = ub.ord-doc.host-code
                           &P_CONTRACT_NUM = v-contract-curr
                           &NO_LOCK=YES
                           &NO_END=YES
                       }
                       ,
                               first grpb_goods no-lock where
                                     grpb_goods.gds-code = grpb_contract-specif.gds-code and
                                     grpb_goods.grp-code  = buf_goods.grp-code :
                                 find first newb_ord-line no-lock where
                                            newb_ord-line.doc-code = loc-ord-num and
                                            newb_ord-line.gds-code =  grpb_contract-specif.gds-code no-error .
                                        if not available  newb_ord-line then do:
                                            run ver-izt (
                                              input newb_ord-doc.doc-type ,
                                              input grpb_goods.gds-code ,
                                              input newb_ord-doc.obj-type ,
                                              input newb_ord-doc.obj-code ,
                                              output v-error) .
                                            if not v-error then do:
                                            kk = kk + 1 .
                                            create newb_ord-line.
                                            assign
                                              newb_ord-line.doc-code      = loc-ord-num
                                              newb_ord-line.artic         = grpb_goods.artic
                                              newb_ord-line.prod-type     = grpb_goods.prod-type
                                              newb_ord-line.prod-code     = grpb_goods.prod-code
                                              newb_ord-line.gds-code      = grpb_goods.gds-code
                                              newb_ord-line.cli-qnty      = /*grpb_contract-specif.qnty*/ ?
                                              newb_ord-line.price-cli     = grpb_contract-specif.price-cli
                                              newb_ord-line.vat-pc        = grpb_contract-specif.vat-pc
                                              newb_ord-line.cli-base-rate = grpb_contract-specif.cli-base-rate
                                              newb_ord-line.unit-cli      = grpb_contract-specif.unit-base
                                              newb_ord-line.price-rubl    = grpb_contract-specif.price-cli * ub.ord-doc.exch-rate / ub.ord-doc.exch-scale / newb_ord-line.cli-base-rate
                                              newb_ord-line.price-base    = newb_ord-line.price-rubl / ub.ord-doc.base-rate * ub.ord-doc.base-scale
                                              newb_ord-line.qnty          = newb_ord-line.cli-qnty * newb_ord-line.cli-base-rate
                                              newb_ord-line.sum-rubl      = newb_ord-line.qnty * newb_ord-line.price-rubl
                                              newb_ord-line.sum-base      = newb_ord-line.qnty * newb_ord-line.price-base
                                              newb_ord-line.sum-cli       = newb_ord-line.cli-qnty * newb_ord-line.price-cli
                                              newb_ord-line.line-num      = kk
                                           .
                                            find first ub.ext-artic no-lock  where ub.ext-artic.cli-type = ub.ord-doc.cli-type
                                                      and ub.ext-artic.cli-code = ub.ord-doc.cli-code
                                                      and ub.ext-artic.gds-code = grpb_goods.gds-code
                                                      and ub.ext-artic.status_  = {&current-status}
                                                      no-error .
                                            if available ub.ext-artic then do:
                                              newb_ord-line.cli-art = ub.ext-artic.ext-artic.
                                            end.
                                            else do:
                                              newb_ord-line.cli-art = ''.
                                            end.
                                        end.
                                        end.
                      end.
                  end.
                  else do: /* Спецификации нет */
                     /*
                      find first newb_ord-line no-lock where
                                 newb_ord-line.doc-code = loc-ord-num and
                                 newb_ord-line.gds-code =  ub.ord-line.gds-code no-error .
                      if not available  newb_ord-line then do:
                          kk = kk + 1 .
                          create newb_ord-line.
                          buffer-copy ub.ord-line except ub.ord-line.doc-code to newb_ord-line
                          assign
                            newb_ord-line.doc-code = loc-ord-num
                            newb_ord-line.line-num = kk
                            .
                      end.
                      */
                  end.
              end.
              else do:
                  /* Простое копирование заказа */
                run ver-izt (ub.ord-doc.doc-type , ub.ord-line.gds-code ,ub.ord-doc.obj-type , ub.ord-doc.obj-code , output v-error) .
                if not v-error then do:
                  create newb_ord-line.
                  buffer-copy ub.ord-line except ub.ord-line.doc-code to newb_ord-line
                  assign
                    newb_ord-line.doc-code = loc-ord-num
                    .
                end.
              end.
           end.
    assign ub.ord-doc.order-type = 0.
end.

/* Еще один тип 2*/
define variable flag-all as logical   no-undo .

for each ub.ord-doc exclusive-lock where
      ub.ord-doc.host-code = G#host-code
  and ub.ord-doc.obj-type  = p-obj-type
  and ub.ord-doc.obj-code  = p-obj-code
  and ub.ord-doc.order-type = 4
  and ub.ord-doc.status_ <> {&g___new} :

  run make-tt-doc (buffer ub.ord-doc ). /* сделаем временную таблицу цикличных заказов */
    flag-all = true .
    for each tt-ord-doc :
        if not ( integer(to-day - tt-ord-doc.doc-date) >= tt-ord-doc.cycle-day ) then do:
           flag-all = false .
           next.  /* рано рассчитывать */
        end.

        run orddocattr-write (
              input ub.ord-doc.doc-code + {&delim-par} + tt-ord-doc.doc-code
            , input {&orddocattr-cycle-done}
            , input "yes") no-error .
            if error-status :error then do:
            if g#auto = false then
                message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  "Ошибка из orddocattr-write"
                  view-as alert-box error
                .
           end.

        { cus/ord-code.i
        'main'
         g#db-num
         tt-ord-doc.obj-type
         tt-ord-doc.obj-code
         v-i-doc
         loc-ord-num
        }

    if g#auto then do:
      v-message = substitute("&3&4 Создание нового заказа № &1 по совокупному заказу № &2 (№ &5) " , loc-ord-num , ub.ord-doc.doc-code , tt-ord-doc.obj-type, tt-ord-doc.obj-code , tt-ord-doc.doc-code) .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input v-message ) no-error .
    end.

    Assign
    i = i + 1
    loc-date-ship = tt-ord-doc.ship-date
    no-error.
    if i = 1 then loc-ord-num1 = loc-ord-num .

    create newb_ord-doc.
    buffer-copy tt-ord-doc except tt-ord-doc.doc-code to newb_ord-doc
           Assign newb_ord-doc.doc-code   = loc-ord-num
                  newb_ord-doc.order-type = 1
                  newb_ord-doc.doc-date   = to-day
                  newb_ord-doc.ship-date  = if ( (loc-date-ship + tt-ord-doc.cycle-day) < to-day ) then  to-day
                                       else (loc-date-ship + tt-ord-doc.cycle-day)
                  newb_ord-doc.status_  = {&g___new}
                  newb_ord-doc.fact-date = ?
                  newb_ord-doc.fact-order = 0
                  newb_ord-doc.ord-int1 = 0
                  newb_ord-doc.ord-int2 = 0
                  newb_ord-doc.date-sale-1 = tt-ord-doc.date-sale-1  + tt-ord-doc.cycle-day
                  newb_ord-doc.date-sale-2 = tt-ord-doc.date-sale-2  + tt-ord-doc.cycle-day
                  newb_ord-doc.PS         =  substitute("по &1 " ,  tt-ord-doc.doc-code   )
           .
           kk = 0.
           run current-contract (input tt-ord-doc.doc-code , output v-contract-curr ) .
           newb_ord-doc.contract-code = v-contract-curr.
           for each ub.ord-line no-lock where
                    ub.ord-line.doc-code = ub.ord-doc.doc-code ,
              first tt-ord-line where
                    tt-ord-line.doc-code = tt-ord-doc.doc-code and
                    tt-ord-line.gds-code = ub.ord-line.gds-code ,
              first buf_goods no-lock where
                    buf_goods.gds-code = ub.ord-line.gds-code
                    :
              if v-ordcyclg then do: /* Копирование по спецификации и группам */
                  if  v-contract-curr <> 0 and
/*
                       can-find (first ub.contract-specif no-lock where
                                       ub.contract-specif.host-code    = tt-ord-doc.host-code and
                                       ub.contract-specif.contract-num = v-contract-curr      and
                                       ub.contract-specif.gds-code     = tt-ord-line.gds-code )
*/
                      Can-Find-Spec  ( tt-ord-doc.host-code,
                                       v-contract-curr,
                                       tt-ord-line.gds-code)
                  then do: /* Спецификация есть по товару */
/*
                      for each grpb_contract-specif no-lock where
                               grpb_contract-specif.host-code    = tt-ord-doc.host-code and
                               grpb_contract-specif.contract-num = v-contract-curr ,
*/ 
                      {str/cont-slave-inc.i
                           &FOR_ = YES
                           &EACH_ = YES
                           &BUFFER_SPECIF  = grpb_contract-specif
                           &P_HOST_CODE    = tt-ord-doc.host-code
                           &P_CONTRACT_NUM = v-contract-curr
                           &NO_LOCK=YES
                           &NO_END=YES
                       }
                       ,
                               first grpb_goods no-lock where
                                     grpb_goods.gds-code = grpb_contract-specif.gds-code and
                                     grpb_goods.grp-code  = buf_goods.grp-code :
                                 find first newb_ord-line no-lock where
                                            newb_ord-line.doc-code = loc-ord-num and
                                            newb_ord-line.gds-code =  grpb_contract-specif.gds-code no-error .
                                        if not available  newb_ord-line then do:
                                            kk = kk + 1 .
                                            create newb_ord-line.
                                            assign
                                              newb_ord-line.doc-code      = loc-ord-num
                                              newb_ord-line.artic         = grpb_goods.artic
                                              newb_ord-line.prod-type     = grpb_goods.prod-type
                                              newb_ord-line.prod-code     = grpb_goods.prod-code
                                              newb_ord-line.gds-code      = grpb_goods.gds-code
                                              newb_ord-line.cli-qnty      = /*grpb_contract-specif.qnty*/ ?
                                              newb_ord-line.price-cli     = grpb_contract-specif.price-cli
                                              newb_ord-line.vat-pc        = grpb_contract-specif.vat-pc
                                              newb_ord-line.cli-base-rate = grpb_contract-specif.cli-base-rate
                                              newb_ord-line.unit-cli      = grpb_contract-specif.unit-base
                                              newb_ord-line.price-rubl    = grpb_contract-specif.price-cli * tt-ord-doc.exch-rate / tt-ord-doc.exch-scale / newb_ord-line.cli-base-rate
                                              newb_ord-line.price-base    = newb_ord-line.price-rubl / tt-ord-doc.base-rate * tt-ord-doc.base-scale
                                              newb_ord-line.qnty          = newb_ord-line.cli-qnty * newb_ord-line.cli-base-rate
                                              newb_ord-line.sum-rubl      = newb_ord-line.qnty * newb_ord-line.price-rubl
                                              newb_ord-line.sum-base      = newb_ord-line.qnty * newb_ord-line.price-base
                                              newb_ord-line.sum-cli       = newb_ord-line.cli-qnty * newb_ord-line.price-cli
                                              newb_ord-line.line-num      = kk
                                           .
                                            find first ub.ext-artic no-lock  where
                                                          ub.ext-artic.cli-type = tt-ord-doc.cli-type
                                                      and ub.ext-artic.cli-code = tt-ord-doc.cli-code
                                                      and ub.ext-artic.gds-code = grpb_goods.gds-code
                                                      and ub.ext-artic.status_  = {&current-status}
                                                      no-error .
                                            if available ub.ext-artic then do:
                                              newb_ord-line.cli-art = ub.ext-artic.ext-artic.
                                            end.
                                            else do:
                                              newb_ord-line.cli-art = ''.
                                            end.
                                        end.
                      end.
                  end.
                  else do: /* Спецификации нет */
                     /*
                      find first newb_ord-line no-lock where
                                 newb_ord-line.doc-code = loc-ord-num and
                                 newb_ord-line.gds-code =  ub.ord-line.gds-code no-error .
                      if not available  newb_ord-line then do:
                          kk = kk + 1 .
                          create newb_ord-line.
                          buffer-copy ub.ord-line except ub.ord-line.doc-code to newb_ord-line
                          assign
                            newb_ord-line.doc-code = loc-ord-num
                            newb_ord-line.line-num = kk
                            .
                      end.
                      */
                  end.
              end.
              else do:
                  /* Простое копирование заказа */
                  create newb_ord-line.
                  buffer-copy tt-ord-line except tt-ord-line.doc-code to newb_ord-line
                  assign
                    newb_ord-line.doc-code = loc-ord-num
                    .
              end.
           end.
  end.
/* если все рассчитаны */
  flag-all = true .
  for each tt-ord-doc :
      if not ( integer(to-day - tt-ord-doc.doc-date) >= tt-ord-doc.cycle-day ) then do:
          flag-all = false .
          next.  /* рано рассчитывать */
      end.
  end.
  if flag-all = true then
     assign
       ub.ord-doc.order-type = 0
       .
end.

p-kol-zakz = i .

if i > 0 then  do:
       v-message = substitute("&4&5 Добавлено &1 ЗАКАЗОВ. Номера С &2 ПО &3 ." , i , loc-ord-num1 , loc-ord-num , p-obj-type, p-obj-code) .
       if g#auto = false then do:
          message v-message  view-as alert-box information .
       end.
       else do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-message ) no-error .

       end.
end.
else  do:
       if can-find (first ub.ord-doc  where ub.ord-doc.cycle-day > 0
                       and ub.ord-doc.doc-date = to-day
                       and ub.ord-doc.obj-type = p-obj-type
                       and ub.ord-doc.obj-code = p-obj-code
                       and ub.ord-doc.host-code = g#host-code
                       and ub.ord-doc.order-type = 1  ) then do:
            v-message = substitute("&2&3 На сегодня повторяющиеся заказы уже рассчитаны !  &1" , to-day , p-obj-type, p-obj-code) .
            if g#auto = false then do:
              message v-message  view-as alert-box  information.
            end.
            else do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input v-message ) no-error .
            end.
        end.
        else do:
          v-message = substitute("&2&3 Повторяющиеся заказы не обнаружены !  &1" , to-day , p-obj-type, p-obj-code ) .
          if g#auto = false then do:
            message v-message view-as alert-box  information.
          end.
            else do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input v-message ) no-error .
            end.
        end.
end.

procedure clear-tt-doc :

  do
  on error undo, return error return-value
  :
   for each tt-ord-doc:
     delete tt-ord-doc.
   end.
   for each tt-ord-line:
     delete tt-ord-line.
   end.

  end.

end procedure. /* clear-tt-doc */

procedure make-tt-doc :
define parameter buffer  buf_ord-doc  for ub.ord-doc .
define variable v-type as character no-undo .
define buffer buf_ord-doc-attr   for ub.ord-doc-attr  .
define buffer buf_ord-line-attr  for ub.ord-line-attr  .
define buffer buf_ord-line       for ub.ord-line  .

define variable v-new-code as character no-undo .
define variable v-date as character no-undo .
define variable v-ok-done as character no-undo .


  do
  on error undo, return error return-value
  :

  run clear-tt-doc.
  for each buf_ord-doc-attr no-lock where
           buf_ord-doc-attr.doc-code   begins  string( buf_ord-doc.doc-code + {&delim-par} ) and
           buf_ord-doc-attr.attr-code = {&orddocattr-cycle-doc-code} :

      v-new-code = buf_ord-doc-attr.doc-code .
      run orddocattr-value (
          input  v-new-code,
          input  {&orddocattr-cycle-done} ,
          output v-ok-done,
          output v-type ) .
      if v-ok-done = "yes" then next .

      create tt-ord-doc.
      buffer-copy buf_ord-doc to tt-ord-doc
      assign
        tt-ord-doc.doc-code = buf_ord-doc-attr.attr-value
        tt-ord-doc.order-type = 1
        .

      run orddocattr-value (
          input  v-new-code,
          input  {&orddocattr-cycle-day} ,
          output tt-ord-doc.cycle-day,
          output v-type ) .

      run orddocattr-value (
          input  v-new-code,
          input  {&orddocattr-cycle-contract-code},
          output tt-ord-doc.contract-code,
          output v-type ) .

      run orddocattr-value (
          input  v-new-code,
          input  {&orddocattr-cycle-ship-date} ,
          output v-date,
          output v-type ) .
      tt-ord-doc.ship-date =string-to-date(v-date) .

      run orddocattr-value (
          input  v-new-code,
          input  {&orddocattr-cycle-ship-time} ,
          output tt-ord-doc.ship-time,
          output v-type ) .


      run orddocattr-value (
          input  v-new-code,
          input  {&orddocattr-cycle-date1}  ,
          output v-date ,
          output v-type ) .
          tt-ord-doc.date-sale-1 = string-to-date(v-date) .

      run orddocattr-value (
          input  v-new-code,
          input  {&orddocattr-cycle-date2} ,
          output v-date,
          output v-type ) .
          tt-ord-doc.date-sale-2 = string-to-date(v-date).

      run orddocattr-value (
          input  v-new-code,
          input  {&orddocattr-cycle-doc-date}  ,
          output  v-date,
          output v-type ) .
          tt-ord-doc.doc-date =string-to-date(v-date) .
          for each buf_ord-line-attr no-lock where
                   buf_ord-line-attr.doc-code = v-new-code and
                   buf_ord-line-attr.attr-code = {&ordlineattr-cli-qnty} ,
             first buf_ord-line no-lock where
                   buf_ord-line.doc-code = buf_ord-doc.doc-code  and
                   buf_ord-line.gds-code = buf_ord-line-attr.gds-code
                   :
              create  tt-ord-line .
              buffer-copy buf_ord-line to tt-ord-line
              assign
                  tt-ord-line.doc-code = tt-ord-doc.doc-code
                  tt-ord-line.cli-qnty = decimal (buf_ord-line-attr.attr-value)
                  tt-ord-line.qnty     = tt-ord-line.cli-qnty * tt-ord-line.cli-base-rate
                  tt-ord-line.sum-rubl = tt-ord-line.qnty * tt-ord-line.price-rubl
                  tt-ord-line.sum-base = tt-ord-line.qnty * tt-ord-line.price-base
                  tt-ord-line.sum-cli  = tt-ord-line.cli-qnty * tt-ord-line.price-cli
              .
          end.
  end.
  end.
end procedure. /* make-tt-doc */

procedure ver-izt :
define input  parameter p-event-code as character no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-error as logical   no-undo .

define variable p-Ok as logical   no-undo .
define variable p-mess as character no-undo .
  do
  on error undo, return error return-value
  :
  p-error = false .
    { gbl/goassizt.i
    p-event-code
    p-gds-code
    p-obj-type
    p-obj-code
    no
    p-Ok
    p-mess
    no-error }
     if p-mess <> "" then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input p-mess ) no-error .
     end.
    if p-ok = false then p-error = true  .
  end.

end procedure. /* ver-izt */


procedure current-contract :

define input  parameter p-ord-doc       as character no-undo .
define output parameter p-contract-code as integer   no-undo .

define buffer buf_ord-doc for ub.ord-doc  .
define buffer buf-contract for ub.contract  .

  do
  on error undo, return error return-value
  :
  p-contract-code = 0.
  find first buf_ord-doc no-lock where
              buf_ord-doc.doc-code = p-ord-doc no-error .

  find first buf-contract no-lock where
             buf-contract.host-code = buf_ord-doc.host-code    and
             buf-contract.cli-type  = buf_ord-doc.cli-type     and
             buf-contract.cli-code  = buf_ord-doc.cli-code     and
             buf-contract.status_   = {&current-contr}         and
             buf-contract.contract-date-beg <= buf_ord-doc.ship-date and
             ( buf-contract.contract-date-end >= buf_ord-doc.ship-date  or
               buf-contract.contract-date-end = date('') )
             no-error .
      if not available buf-contract then do:
          find first buf-contract no-lock where
                     buf-contract.host-code = buf_ord-doc.host-code    and
                     buf-contract.cli-type  = buf_ord-doc.cli-type     and
                     buf-contract.cli-code  = buf_ord-doc.cli-code     and
                     buf-contract.status_   = {&current-contr}         no-error .
      end.

      if available buf-contract then do:
         p-contract-code = buf-contract.contract-code.
      end.

      /* message p-contract-code 'p-contract-code' . */

  end.

end procedure. /* current-contract */