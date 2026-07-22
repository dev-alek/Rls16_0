block-level on error undo, throw.
/*

$Revision: e470dcf1e011, 295, rls $
$Author: SSlivenko $
$Date: Tue Dec 01 19:11:38 2015 +0300 $
$Workfile: ord-clos.p $
$Archive: cus/ord-clos.p $

Переход по графу статусов

Автор: Чернова Светлана Александровна
Дата создания: 04/09/02
Author: Svetlana Chernova
Creation date: 04/09/02

*/

define input parameter  parParentProc  as widget-handle no-undo.
define input parameter  p-rec          as recid no-undo .       /* recid  заказа  */
define input parameter  store-type     as character no-undo .   /* текущий объект , где закрывается поставка */
define input parameter  store-code     as integer   no-undo .   /* текущий объект  */
define input parameter  p-db-num       as integer   no-undo .   /* текущая база данных */
define input parameter  p-ask          as logical   no-undo .   /* задавать вопросы или молча=false */
define input parameter  p-param-list   as character no-undo .   /*p-param-list пока тока один параметр, говорит что edi или не edi*/

define variable vss-revision    as character no-undo init "$Revision: e470dcf1e011, 295, rls $":u .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":u .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:38 2015 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: ord-clos.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-clos.p $":u .
define variable vss-description as character no-undo init  "Переход по графу статусов" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ str/lib-trn.i  }
{ cmp/df-sub.i   }
{ cmp/r-pril.i   }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/thbjattr.i }
{ cus/vqntyrcv.i }
{ gbl/clntattr.i }
{ cus/vcopm.i    }
{ cus/str-edi.i  }
{ cus/ord-outp.i def }

&scop v-screen  ' экран':L
&scop v-printer ' принтер':L

define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable v-log      as logical   no-undo .
define variable g#log as logical   no-undo .
define variable v-file-name as character no-undo .
define variable v-Ok as logical   no-undo .
define variable v-mess as character no-undo .
define variable v-is-limit as logical   no-undo .
define variable vv-unit-cli           like ub.ext-artic.unit-cli           no-undo .
define variable vv-cli-base-rate      like ub.ext-artic.cli-base-rate      no-undo .
define variable vv-unit-cli-ord       like ub.ext-artic.unit-cli-ord       no-undo .
define variable vv-cli-base-rate-ord  like ub.ext-artic.cli-base-rate-ord  no-undo .
define variable vv-unit-cli-rcv       like ub.ext-artic.unit-cli-rcv       no-undo .
define variable vv-cli-base-rate-rcv  like ub.ext-artic.cli-base-rate-rcv  no-undo .
define variable v-dm-edi    as integer   no-undo .

define variable v-longchar as longchar no-undo .

define variable doc-db-num as integer   no-undo .
define buffer bf2_goods for ub.goods  .
define buffer bf3_goods for ub.goods  .
define buffer bf_contract-specif for ub.contract-specif.

define buffer bf2_ext-artic for ub.ext-artic  .
run gbl/_tmpfile.p ("ord", ".txt", output v-file-name) .
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }

if g#esys then do:
  run get-db-num in parparentproc ( output v-cntxt-db-num).
  run get-userid in parparentproc ( output v-cntxt-userid).
end.
else do:
{ gbl/getcntxt.i get }
end.

/* Проверка на активный объект */
define variable v-obj-active  as character no-undo .
{ gbl/objat.i
  store-type
  store-code
  'active=request':u
  v-obj-active
  }

define variable v-not-activ  as logical   no-undo .
if v-obj-active <> "yes" and p-db-num <> 0  then v-not-activ = true .
else v-not-activ = false .

define  buffer shar-buf_ord-doc    for ub.ord-doc.
define  buffer t-doc-rcv      for ub.ord-doc-rcv .
define  buffer t-ord-doc-rcv  for ub.ord-doc-rcv.
define  buffer t-doc-line     for ub.ord-line.
define  buffer t-doc-line-rcv for ub.ord-line-rcv.
define  buffer t-trn-line     for ub.doc-line.
define  buffer t-trn-doc      for ub.trn-doc.
define  buffer buf_ext-artic  for ub.ext-artic.

define temp-table temp-obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi obj-type obj-code
.

define variable  sum-ord like ub.ord-line.qnty no-undo .
define variable  sum-rcv like ub.ord-line.qnty no-undo .
define variable  sum-trn like ub.ord-line.qnty no-undo .
define variable  sum-trn1 like ub.ord-line.qnty no-undo .
define variable old-state like ub.ord-doc.status_ no-undo .
define variable old-flag like ub.ord-doc.flag_ no-undo .
define stream  errStream  .

define variable ord-op           as logical   no-undo .
define variable p-type           as character no-undo .
define variable c-ord-ofof       as logical   no-undo .
define variable v-tt-qnty        as logical   no-undo .
define variable ord-rcv1         as decimal   no-undo .
define variable v-ne             as logical   no-undo .
define variable g-log            as logical   no-undo .
define variable v-is-edi         as logical   no-undo .
define variable v-is-edoc-nn     as logical   no-undo .
define variable par-is-edi       as character no-undo .
define variable v-is-edi-doc     as logical   no-undo .
define variable v-is-edoc-nn-doc as logical   no-undo .
define variable v-erase          as logical   no-undo .


define buffer buf_1_ord-line for ub.ord-line  .
define buffer buf_1_ord-line-rcv for ub.ord-line-rcv .

run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input {&attr-ord-global}
  ,input {&attr-ord-global_ord-op}
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output ord-op
  ,output p-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .

for each thbjattr_thbj-attr :
  delete thbjattr_thbj-attr.
end.
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input {&attr-ord-global}
  ,input {&attr-ord-global_ord-ofof}
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output c-ord-ofof
  ,output p-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .

&glob send-to-news  if not (shar-buf_ord-doc.doc-type = ~{&o-p} and ord-op = no )  then do: ~
 run str/callnews.p ~
    (input {&table_ord-doc}  ~
    ,input (buffer shar-buf_ord-doc:handle) ~
    ) no-error .      ~
  if error-status:error then do: ~
    assign shar-buf_ord-doc.flag_ = old-flag  shar-buf_ord-doc.status_ = old-state . ~
    return error substitute( " Документ &1 , Ошибка при передаче в новости &2 &3 &4 &5 &6", shar-buf_ord-doc.doc-code ,vss-workfile, vss-revision, vss-description, return-value , error-status:get-message(1)   ) . ~
  end.                                                     ~
  end.

&glob send-to-news-fact  ~
  run str/callnews.p ~
    (input {&table_ord-doc}  ~
    ,input (buffer shar-buf_ord-doc:handle) ~
    ) no-error .      ~
  if error-status:error then do: ~
    assign shar-buf_ord-doc.flag_ = old-flag  shar-buf_ord-doc.status_ = old-state . ~
    return error substitute( " Документ &1 , Ошибка (факт) при передаче в новости &2 &3 &4 &5 &6", shar-buf_ord-doc.doc-code ,vss-workfile, vss-revision, vss-description, return-value , error-status:get-message(1)  ) . ~
  end.

 /*----------------------------------------------------------------------------------------------------------------------*/

  { gbl/curobjdt.i store-type store-code to-day }
 find first shar-buf_ord-doc where recid (shar-buf_ord-doc) = p-rec exclusive-lock no-error.
 assign
  old-state = shar-buf_ord-doc.status_
  old-flag  = shar-buf_ord-doc.flag_
  .
  /* Проверка по строкам */
  for each ub.ord-line no-lock where
           ub.ord-line.doc-code = shar-buf_ord-doc.doc-code :
      if (round(ub.ord-line.cli-qnty * ub.ord-line.cli-base-rate, 3) <> ub.ord-line.qnty) then do:
         return error substitute (
            " Документ &1, По товару неправильное соотношение количеств в единицах поставщика &2 &8 (коэфф.&3)  и в базовых единицах измерения &4 ! Товар &5 &6&7",
            shar-buf_ord-doc.doc-code ,
            ub.ord-line.cli-qnty ,
            ub.ord-line.cli-base-rate ,
            ub.ord-line.qnty  ,
            ub.ord-line.artic ,
            ub.ord-line.prod-type ,
            ub.ord-line.prod-code ,
            ub.ord-line.unit-cli ) .
      end.
  end.

 /* Для заказов ОО отдельная процедура закрытия */
  if shar-buf_ord-doc.doc-type = {&o-o}  then do:
    run cus/ordoocls.p
      (input parParentProc ,
       input p-rec ,
       input p-ask )
      no-error .
    return .
  end.
/* Для заказов ОR отдельная процедура закрытия */
  if shar-buf_ord-doc.doc-type = {&o-r}  then do:
    run cus/ordorcls.p ( parParentProc ,input p-rec, input p-ask ) no-error .
    if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1) skip
         return-value skip
         "Ошибка при закрытии заказа"
         view-as alert-box error
       .
    end.
    return .
  end.


  if shar-buf_ord-doc.ship-date = ? then do:
     return error substitute(" Документ &1 , Не задана дата заказа !", shar-buf_ord-doc.doc-code) .
  end.
  define variable t-date  as date      no-undo .
  define variable t-time  as integer   no-undo .

  run cur-time (output  t-date , output  t-time ).



  if shar-buf_ord-doc.date-sale-1 = ? then do:
      return error substitute( " Документ &1 , Не задан интервал продаж ! Нет даты начала !", shar-buf_ord-doc.doc-code) .
  end.

  if shar-buf_ord-doc.date-sale-2 = ? then do:
      return error substitute( " Документ &1 , Не задан интервал продаж ! Нет даты конца !", shar-buf_ord-doc.doc-code) .
  end.

  if can-find
    ( first   t-doc-line no-lock where t-doc-line.doc-code  = shar-buf_ord-doc.doc-code    and
            ( t-doc-line.qnty  =  0 or t-doc-line.qnty  = ?)) then do:
      return error substitute( " Документ &1 , В заказе есть строки с количеством равным 0 или ? !", shar-buf_ord-doc.doc-code) .
  end.

  if shar-buf_ord-doc.doc-type = {&f-p}  and  v-not-activ  then do:
      return error substitute( " Документ &1 , Закрыть заказ ФП можно только на активном объекте !", shar-buf_ord-doc.doc-code) .
  end.
  /* проверка АМ и ИЖТ до поставки  */
  if p-param-list <> "yes" and shar-buf_ord-doc.doc-type <> {&f-p} then do:
  if shar-buf_ord-doc.status_ =  {&g___new} or
     shar-buf_ord-doc.status_ = {&ord-accept} then do:
  for each ub.ord-line no-lock where
           ub.ord-line.doc-code = shar-buf_ord-doc.doc-code :
    { gbl/goassizt.i
      shar-buf_ord-doc.doc-type
      ub.ord-line.gds-code
      shar-buf_ord-doc.obj-type
      shar-buf_ord-doc.obj-code
      false
      v-Ok
      v-mess
      no-error }
        if v-Ok = false then do:
            run creat-tt (ub.ord-line.gds-code , v-mess ) .
            v-erase = true.
        end.
  end.
  if v-erase then do:
      run view-exept-gds ( substitute("В заказе есть некорректные линии !&1Просмотреть список ?", {&new-line})) .
            return.
  end.
 end.
end.

define buffer buf_contract for ub.contract.
define variable v-mastc           as logical   no-undo init false .
define variable varcontract       as character no-undo.
define variable varcontract-type  as character no-undo .
define variable v-ext-mode as character no-undo .

    run adm/shattri.p (
      input "get":U
      ,input shar-buf_ord-doc.obj-type
      ,input shar-buf_ord-doc.obj-code
      ,input {&attr-contr-in}
      ,input  "contr-in-income"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-mastc
      ,output varcontract-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "adm/shattri.p"
        view-as alert-box error
      .
  if (  shar-buf_ord-doc.doc-type = {&f-p}  or
        shar-buf_ord-doc.doc-type = {&o-p} )
      and
      ( shar-buf_ord-doc.contract-code = 0 or
        shar-buf_ord-doc.contract-code = ? )
      and
        shar-buf_ord-doc.order-type <> 4  /* не объединенный */
      and
       v-mastc = true
  then do:
      return error "На фирме " + string(shar-buf_ord-doc.host-code) + " задание договора по заказу ОП и ФП обязательны ! " .
  end.
  
  if shar-buf_ord-doc.doc-type = {&f-p} and shar-buf_ord-doc.contract-code > 0 and shar-buf_ord-doc.status_ =  {&g___new} then do:
     find first bf_contract-specif where bf_contract-specif.host-code    = shar-buf_ord-doc.host-code     and
                                          bf_contract-specif.contract-num = shar-buf_ord-doc.contract-code no-lock no-error.
      if available bf_contract-specif then do: /* спецификация есть */
         v-ok = true.
         for each ub.ord-line no-lock where
                  ub.ord-line.doc-code = shar-buf_ord-doc.doc-code :
            if not can-find (first bf_contract-specif no-lock where
                                   bf_contract-specif.host-code    = shar-buf_ord-doc.host-code and
                                   bf_contract-specif.contract-num = shar-buf_ord-doc.contract-code and
                                   bf_contract-specif.gds-code     = ub.ord-line.gds-code   ) then do:
                                      message
                                        "Выбран Договор со спецификацией !!!" skip
                                        "Несоответствие списка товаров заказа и спецификации " skip
                                        "Заказ      :" shar-buf_ord-doc.doc-code        skip
                                        "код товара :" ub.ord-line.gds-code skip
                                        "артикл     :" ub.ord-line.artic skip
                                        view-as alert-box error .
                                      v-ok = false.
                                   end.            
         end.
          if not v-ok
              then return error substitute ("Документ &1, не может быть закрыт, т.к. есть товары несоответствующие спецификации", shar-buf_ord-doc.doc-code).
       end.
  end.

  { gbl/conf-rd.i "'is-edi'" "''" "''" 0 "''" "''" "''" no par-is-edi par-type no-error  }
  if error-status :error then v-is-edi = false .
  assign
    v-is-edi = lookup(par-is-edi, "true,yes":U) > 0
  .

 case shar-buf_ord-doc.status_ :
      when {&ord-rejection} then do :
        return error substitute( " Документ &1  Тип &2 , Нельзя закрыть в статусе &3  ", shar-buf_ord-doc.doc-code ,  shar-buf_ord-doc.doc-type , shar-buf_ord-doc.status_ ) .
      end.
      when {&g___new} then do :
           if shar-buf_ord-doc.ship-date <= t-date then do:
              if p-ask then  do:
            message
            substitute(" Документ &1 , Дата заказа &2 меньше или равна текущей даты &3 ! ",
                              shar-buf_ord-doc.doc-code ,
                              string(shar-buf_ord-doc.ship-date, "99/99/9999" ) ,
                              string(t-date, "99/99/9999" ))
                  " Будем закрывать ? "
                    view-as alert-box question
                    buttons yes-no
                    title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  {&o-f} then " заявку " else " заказ " )
                    update g#log
                  .
              end.
              else g#log = false  .
          if not g#log
          and shar-buf_ord-doc.whole-send-news <> integer({&DOC-DM-EDI}) THEN DO:
            return error substitute( " Документ &1 , Дата заказа меньше или равна текущей дате !  ", shar-buf_ord-doc.doc-code  ) +
                            string(shar-buf_ord-doc.ship-date, "99/99/9999" ) + " " +
                            string(t-date, "99/99/9999" )
                            .
          END.
        end. /*if shar-buf_ord-doc.ship-date <= t-date then do:*/
          if shar-buf_ord-doc.doc-type = {&o-f}  and v-not-activ then do:
              if not (c-ord-ofof = true and p-db-num = 0 ) then do:
                  return error substitute( " Документ &1 , Закрыть заявку можно только на активном объекте ", shar-buf_ord-doc.doc-code  ) .
              end.
          end.

              /* Проверка на пустой */
        if not can-find (first  t-doc-line where t-doc-line.doc-code  = shar-buf_ord-doc.doc-code ) then do:
                    if p-ask then  do:
                        message  (if shar-buf_ord-doc.doc-type  =  {&o-f} then "Заявка "  else " Заказ")  shar-buf_ord-doc.doc-code  "  не содержит ни одной записи ! Будем закрывать ? "
                          view-as alert-box question
                          buttons yes-no
                          title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  {&o-f} then " заявку " else " заказ " )
                          update g#log
                        .
                    end.
                    else g#log = false  .

                    if not g#log then  return error substitute( " Документ &1 , не содержит ни одной записи ", shar-buf_ord-doc.doc-code  ) .
                    shar-buf_ord-doc.flag_ = false .

                 end.
              /* Проверка на 0 цены */
              if shar-buf_ord-doc.doc-type  <>  {&o-f}  then do:
                    find first  t-doc-line where
                          t-doc-line.doc-code  = shar-buf_ord-doc.doc-code and
                        ( t-doc-line.price-rubl  <= 0 or
                          t-doc-line.price-cli   <= 0 or
                          t-doc-line.price-rubl  = ? or
                          t-doc-line.price-cli   = ? )
                          no-lock no-error .
                    if available t-doc-line then do:
                        return error substitute( " Документ &1 , содержит товары с неопределенной ценой!  ", shar-buf_ord-doc.doc-code  ) .
                      end.
              end.
              /* Проверка Поставщика   */
        find first ub.clients no-lock
             where ub.clients.obj-code  = shar-buf_ord-doc.cli-code
               and ub.clients.obj-type  = shar-buf_ord-doc.cli-type  no-error .

              if not available ub.clients then do:
                  return error substitute( " Документ &1 , Проверьте правильность заполнения поля Поставщик  !  ", shar-buf_ord-doc.doc-code  ) .
              end.

              if  available ub.clients then do:
                assign
                v-is-edi-doc = status-is-edi ( input v-is-edi
                                        , input ub.clients.obj-type
                                        , input ub.clients.obj-code
                                        , input shar-buf_ord-doc.obj-type
                                        , input shar-buf_ord-doc.obj-code
                                        , output v-dm-edi
                                        ) .
          if shar-buf_ord-doc.whole-send-news = integer({&doc-dm-empty}) and v-is-edi-doc = yes then do :
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_pmnt-ord-doc_send-bypass-EDI':U
              {&cntxt-object}
              g#host-code
              store-type
              store-code
              0
              0
              0
              false
              g-log
            }
          if g-log = false then do:
            assign shar-buf_ord-doc.whole-send-news = integer({&doc-dm-edi}) .
            return error substitute( " Документ &1 , у Вас нет прав на работу без EDI. Документ отправлен по EDI!  ", shar-buf_ord-doc.doc-code ) .
          end.
          end.
                  if not ( ub.clients.obj-type = {&prs} or
                           ub.clients.obj-type = {&cmp} ) then do:
                            return error substitute( " Документ &1 , Поставщик может быть только &2 или  &3 !  ", shar-buf_ord-doc.doc-code  , {&prs} , {&cmp}  ) .
                  end.
                  if shar-buf_ord-doc.doc-type = {&f-p} and ( ub.clients.obj-code = shar-buf_ord-doc.host-code ) then do:
                            return error substitute( " Документ &1 , Поставщик не может быть текущей фирмой !  ", shar-buf_ord-doc.doc-code  ) .
                  end.
               end.

              /* Проверка совпадения периода продаж  */
              define variable v_ok as logical no-undo .

              run verif_1 in this-procedure (output v_ok) no-error .
                  if not v_ok then do:
                      if p-ask then  do:
                          message "В "  (if shar-buf_ord-doc.doc-type  =  {&o-f} then " Заявке " else " Заказе" ) shar-buf_ord-doc.doc-code " есть  повторный заказ на товары в пути ! Закрывать такой документ ? "
                            view-as alert-box question
                            buttons yes-no
                            title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  {&o-f} then " заявку " else "заказ" )
                            update g#log
                          .
                      end.
        else do:
          g#log = true .
        end.

                      if not g#log then   return error substitute( " Документ &1 , есть  повторный заказ на товары в пути !  ", shar-buf_ord-doc.doc-code  ) .
                   end.
             /* Проверка на расчет */
              if shar-buf_ord-doc.doc-type  =  {&o-p} then do:
      run ver-clients-calc (
            input shar-buf_ord-doc.cli-type
          , input shar-buf_ord-doc.cli-code
          , input shar-buf_ord-doc.obj-type
          , input shar-buf_ord-doc.obj-code
          , input shar-buf_ord-doc.e-method
          , output g#log
                            ) .
                 if g#log then do:
                    if p-ask then  do:
                       message 'Заказ не был раcсчитан !!!' view-as alert-box error .
                    end.
                    return error substitute ("Заказ не был раcсчитан !!! Поставщик &1&2" , shar-buf_ord-doc.cli-type , shar-buf_ord-doc.cli-code ) .
                 end.
              end.


              /* При переходе
                    со статуса новый
                    на разрешен
                    происходит
                    проставление артикла поставщика  ext-artic.ext-artic
                    проставление отметка об отмене заказа  gds-cli.cancel-date ------------------- */


                  run waitfram-show in this-procedure ("Ждите ! Идет проверка по строкам...") .
                  define variable v-err-ext as logical   no-undo .
                  v-err-ext = false .

                  for each t-doc-line  where t-doc-line.doc-code = shar-buf_ord-doc.doc-code no-lock :
                  if shar-buf_ord-doc.contract-code <> 0 and
                     shar-buf_ord-doc.doc-type  =  {&o-p}  then do:

                      { str/ckcntspc.i
                        shar-buf_ord-doc.host-code
                        shar-buf_ord-doc.contract-code
                        t-doc-line.gds-code
                        t-doc-line.price-cli
                        shar-buf_ord-doc.VAT-type
                        t-doc-line.VAT-pc
                        no-error
                      }
                      if error-status :error then do:
                        assign
                          v-err-ext = true
                          v-longchar = v-longchar + trim(return-value) + trim(error-status :get-message(1)) + {&new-line}
                        .
                      end.
                  end.
                        find first ub.cli-gds where
                              ub.cli-gds.artic     = t-doc-line.artic     and
                              ub.cli-gds.cli-code  = shar-buf_ord-doc.cli-code       and
                              ub.cli-gds.cli-type  = shar-buf_ord-doc.cli-type       and
                              ub.cli-gds.host-code = g#host-code and
                              ub.cli-gds.prod-code = t-doc-line.prod-code and
                              ub.cli-gds.prod-type = t-doc-line.prod-type exclusive-lock no-error .

                      if available ub.cli-gds then  do:
                          if ub.cli-gds.cancel-date <> t-doc-line.cancel-date
                              then
                                 assign
                                   ub.cli-gds.cancel-date = t-doc-line.cancel-date
                                   .

                      end.
                      /*if t-doc-line.cli-art <> "" then do:
                          find first buf_ext-artic no-lock
                            where buf_ext-artic.cli-type = shar-buf_ord-doc.cli-type
                              and buf_ext-artic.cli-code = shar-buf_ord-doc.cli-code
                              and buf_ext-artic.gds-code = t-doc-line.gds-code
                          no-error .
                          if available buf_ext-artic then do:
                            if buf_ext-artic.status_ = {&deleted-status} then do:
                              v-ext-mode = {&add-def}.
                            end.
                            else do:
                              v-ext-mode = {&update}.
                            end.
                          end.
                          else do:
                            v-ext-mode = {&add-def}.
                          end.

                        run ref/extarts.p ( input v-ext-mode
                                          , input shar-buf_ord-doc.cli-type
                                          , input shar-buf_ord-doc.cli-code
                                          , input t-doc-line.gds-code
                                          , input t-doc-line.cli-art
                                          , input "":U
                                          , input vv-unit-cli
                                          , input vv-cli-base-rate
                                          , input vv-unit-cli-ord
                                          , input vv-cli-base-rate-ord
                                          , input vv-unit-cli-rcv
                                          , input vv-cli-base-rate-rcv
                                          ) no-error .
                        if error-status :error then do :
                          assign
                            v-err-ext = true
                            v-longchar = v-longchar + trim(return-value) + trim(error-status :get-message(1)) + {&new-line}
                          .
                        end.
                      end.*/
                  end.

                  if v-err-ext = true  then do:
                      run gbl/d-longchar.w
                          ( input ?
                           ,input   'Editor_row=2\':u
                                  + 'title=Проверка артикулов Поставщика\':u
                                  + 'Editor_col=1\':u
                                  + 'Editor_width=96\':u
                                  + 'Editor_height=21\':u
                                  + 'readonly=yes\':u
                          ,input-output v-longchar
                          ,output v-ok ) no-error .
                          if error-status :error then message
                            vss-workfile vss-revision vss-description skip
                            error-status :get-message(1) skip
                            return-value skip
                            "Ошибка"
                            view-as alert-box error
                          .
                          assign
                          v-longchar = '':U.
                     return error "Заказ не может быть закрыт ! Исправьте внешние артикулы Поставщика" .
        end. /*if v-err-ext = true  then do:*/
                  if shar-buf_ord-doc.doc-type = {&f-p} then do:
                       /*--> в ПОСТАВКА */
                      assign
                        shar-buf_ord-doc.status_ = {&ord-rcv}
                        .
                  end.
                  else do:
            if shar-buf_ord-doc.doc-type = {&o-p}
            and (ord-op = no or shar-buf_ord-doc.whole-send-news = integer({&doc-dm-edi})) then do:
                          /*--> в ПОСТАВКА */
              /* не надо - мы должны вызывать эту процедуру при приеме 29 ORDRSP
              if v-is-edi and shar-buf_ord-doc.whole-send-news = integer({&doc-dm-edi})
              then do:
                            assign
                shar-buf_ord-doc.ord-int1 = integer({&edi-ordrsp-yes})
                              .
              end.

              */
			  if v-dm-edi = integer({&esys-dm-contour-edi})
              then do:
              assign
                shar-buf_ord-doc.ord-int1 = integer({&edi-ordrsp-sts})
              .
              end.

              assign
              shar-buf_ord-doc.status_ = {&ord-rcv}
              .
            end.
            else do:
            /*--> в CОГЛАСОВАНИЕ */
              assign
              shar-buf_ord-doc.status_ = {&ord-accept}
              .
            end.
          end.

        /* передаем документ в новости */
        {&send-to-news}
        run waitfram-hide in this-procedure .
       end. /*when {&g___new} then d*/
       when {&ord-accept} then do : /* согласование */
          if shar-buf_ord-doc.doc-type = {&o-f}   then do:
              return error substitute( " Документ &1 , Закрыть заявку можно автоматически в СЗФП!  ", shar-buf_ord-doc.doc-code  ) .
          end.
          if v-cntxt-db-num <> 0 then do:
            return error substitute( " Документ &1 , Закрыть Заказ в статусе СОГЛАСОВАНИЕ можно в ГБД !  ", shar-buf_ord-doc.doc-code  ) .
          end.

        if shar-buf_ord-doc.doc-type <> {&o-f} then do:
            assign
              shar-buf_ord-doc.status_ = {&ord-rcv}
              .
              {&send-to-news-fact} /* передаем документ в новости */
          end.
       end.
       when {&ord-rcv} then do : /* поставка */
            if shar-buf_ord-doc.doc-type = {&o-f}  then do:
               /* return error substitute( " Документ &1 , Закрыть заявку можно только автоматически в АРМе 'ОФИС' !  ", shar-buf_ord-doc.doc-code  ) . */
            end.
          /* проверка на закрытие */
            for each t-ord-doc-rcv where  t-ord-doc-rcv.doc-code     = shar-buf_ord-doc.doc-code
                                               and NOT ( t-ord-doc-rcv.status_   = {&ord-rcv}
                                                   OR  t-ord-doc-rcv.status_   = {&fact} ) no-lock :
                return error substitute( " Документ &1 , Поставка &2 имеет статус &3 , закрыть  Документ &1  до статуса ЗАКРЫТО невозможно ! Закройте поставку до статуса ПОСТАВКА ", shar-buf_ord-doc.doc-code , t-ord-doc-rcv.rcv-code , CAPS(t-ord-doc-rcv.status_) ) .
            end.

         /* сверка количеств по заказу и поставке */
         assign
           sum-ord = 0
           sum-rcv = 0
          .
           for each t-doc-line     where t-doc-line.doc-code     = shar-buf_ord-doc.doc-code  no-lock :
               for each  t-doc-line-rcv where t-doc-line-rcv.doc-code = t-doc-line.doc-code and
                                         t-doc-line-rcv.artic    = t-doc-line.artic         and
                                         t-doc-line-rcv.prod-type  = t-doc-line.prod-type   and
                                         t-doc-line-rcv.prod-code  = t-doc-line.prod-code
                no-lock :
                  sum-rcv = sum-rcv + t-doc-line-rcv.qnty.
                end.
                sum-ord = sum-ord + t-doc-line.qnty.
           end.

            if  sum-rcv = 0  then do:
               if p-ask then  do:
                  message  (if shar-buf_ord-doc.doc-type  =  {&o-f} then "Заявка "   + shar-buf_ord-doc.doc-code + " не имеет " else " Заказ"   + shar-buf_ord-doc.doc-code + "  не имеет "  )   "  поставок ! Закрыть в статус (ЗАКРЫТО-) ? "
                    view-as alert-box question
                    buttons yes-no
                    title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  {&o-f} then " заявку " else " заказ " )
                    update g#log
                  .
                end.
                else g#log = false .

                if not g#log then  return error substitute( " Документ &1 , Не имеет поставок ", shar-buf_ord-doc.doc-code  ) .
                shar-buf_ord-doc.flag_ = false .
            end.

            if  sum-ord > sum-rcv then do:
               if p-ask then  do:
                message  (if shar-buf_ord-doc.doc-type  =  {&o-f} then "Заявка "   + shar-buf_ord-doc.doc-code + " не покрыта " else " Заказ"   + shar-buf_ord-doc.doc-code + "  не покрыт "  )   "  поставками полностью ! Закрыть в статус (ЗАКРЫТО-) ? "
                  skip
                  "по заказу =" sum-ord   skip
                  "по поставкам =" sum-rcv
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  {&o-f} then " заявку " else " заказ " )
                  update g#log
                .
               end.
               else do:
                  /* Если отношение 1:1 то закрываем заказ */

                      run ver-qnty-rcv-from-ord (input shar-buf_ord-doc.doc-code , output v-is-limit ) .
                      if v-is-limit then do:
                         g#log = true .
                      end.
                      else do:
                         g#log = false .
                      end.
               end.

                if not g#log then do:
                  return error substitute( " Документ &1 , не покрыт поставками полностью !  ", shar-buf_ord-doc.doc-code  ) .
                end.
                shar-buf_ord-doc.flag_ = false .
            end.   /*  sum-ord > sum-rcv */

            if  sum-ord =  sum-rcv then do:
                shar-buf_ord-doc.flag_ = true  .
            end.
            if  sum-ord <  sum-rcv then do:

                ord-rcv1 = 0.
                v-ne = false  .
                for each buf_1_ord-line no-lock where buf_1_ord-line.doc-code = shar-buf_ord-doc.doc-code :
                    for each buf_1_ord-line-rcv no-lock where
                             buf_1_ord-line-rcv.doc-code  = shar-buf_ord-doc.doc-code and
                             buf_1_ord-line-rcv.artic     = buf_1_ord-line.artic      and
                             buf_1_ord-line-rcv.prod-type = buf_1_ord-line.prod-type  and
                             buf_1_ord-line-rcv.prod-code = buf_1_ord-line.prod-code
                             :
                             ord-rcv1 = ord-rcv1 + buf_1_ord-line-rcv.qnty.
                    end.
                    if buf_1_ord-line.qnty > ord-rcv1 then do:
                       v-ne = true .
                       leave.
                    end.
                end.
                shar-buf_ord-doc.flag_ = false  .
                if v-ne = false then do:
                    if p-ask then  do:
                        message "На "
                        if shar-buf_ord-doc.doc-type = {&o-f} then " Заявка " else "Заказ"
                        shar-buf_ord-doc.doc-code
                          " превышено количество по поставками  ! Закрыть в статус (ЗАКРЫТО+) ? " skip
                          "по заказу =" sum-ord   skip
                          "по поставкам =" sum-rcv

                          view-as alert-box question
                          buttons yes-no
                          title "Закрыть " + (if shar-buf_ord-doc.doc-type  =  {&o-f} then " заявку " else "заказ" )
                          update g#log
                        .
                    end.
                    else do:
                  /* Если отношение 1:1 то закрываем заказ */
                          run ver-qnty-rcv-from-ord (input shar-buf_ord-doc.doc-code , output v-is-limit ) .
                          if v-is-limit then do:
                            g#log = true .
                          end.
                          else do:
                            g#log = false .
                          end.
                    end.
                     .

                    if not g#log then  return error substitute( " Документ &1 , превышено количество по поставками !  ", shar-buf_ord-doc.doc-code  ) .
                    shar-buf_ord-doc.flag_ = true  .
                end.
            end.

            assign
              shar-buf_ord-doc.status_ = {&ord-close}
              .
              {&send-to-news-fact} /* передаем документ в новости */
      end.
       when {&ord-close} then do :


            if shar-buf_ord-doc.doc-type = {&o-f}  then do:
               return error substitute( " Документ &1 , Закрыть заявку можно только автоматически в АРМе 'ОФИС' !  ", shar-buf_ord-doc.doc-code  ) .
            end.
          /* Проверка на активный объект */
              define variable v-office      as character no-undo .
              { gbl/currdbat.i
                'office=request':u
                v-office
              }
              { gbl/objdbnum.i
                shar-buf_ord-doc.obj-type
                shar-buf_ord-doc.obj-code
                doc-db-num
              }
              if  v-obj-active <> "yes" and doc-db-num = p-db-num then  v-obj-active = "yes" .
              if  v-obj-active <> "yes"  then do:
                  return error substitute( " Документ &1 , Закрыть до факта можно только на АКТИВНОМ объекте !  ", shar-buf_ord-doc.doc-code  ) .
              end.
          /* проверка на закрытие */
            for each t-ord-doc-rcv where  t-ord-doc-rcv.doc-code     = shar-buf_ord-doc.doc-code no-lock :
                for each ub.ord-chain no-lock where
                          ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code and
                          ub.ord-chain.doc-type = 'rcv'                  and
                          ub.ord-chain.rel-doc-type = 'trn'
                          :
                 for each t-trn-doc no-lock where
                         (t-trn-doc.doc-type  = {&income}     or
                          t-trn-doc.doc-type  = {&expense} ) and
                          t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                          t-trn-doc.status_  <> {&fact}  :

                  return error substitute( " Заказ &1 , закрыть до статуса ЗАКРЫТО невозможно ! Закройте ПН &2 до статуса ФАКТ ", shar-buf_ord-doc.doc-code , t-trn-doc.doc-code ) .
                 end.
                 end.
            end.

         assign          /* сверка количеств по заказу и поставке */
           sum-ord = 0
           sum-rcv = 0
           sum-trn = 0
           v-tt-qnty = false
           sum-trn1 = 0.
          .

        for each t-doc-line     where
                 t-doc-line.doc-code     = shar-buf_ord-doc.doc-code  no-lock :
            for each  t-doc-line-rcv where
                      t-doc-line-rcv.doc-code = t-doc-line.doc-code and
                      t-doc-line-rcv.artic    = t-doc-line.artic         and
                      t-doc-line-rcv.prod-type  = t-doc-line.prod-type   and
                      t-doc-line-rcv.prod-code  = t-doc-line.prod-code no-lock ,
              first t-doc-rcv where t-doc-line-rcv.doc-code = t-doc-rcv.doc-code  and
                                    t-doc-line-rcv.rcv-code = t-doc-rcv.rcv-code  no-lock :
              for each ub.ord-chain no-lock where
                        ub.ord-chain.doc-code = t-doc-rcv.rcv-code and
                        ub.ord-chain.doc-type = 'rcv'                  and
                        ub.ord-chain.rel-doc-type = 'trn'
                        :

                  for each  t-trn-line where
                            t-trn-line.doc-code  = ub.ord-chain.rel-doc-code    and
                            t-trn-line.artic      = t-doc-line-rcv.artic        and
                            t-trn-line.prod-type  = t-doc-line-rcv.prod-type    and
                            t-trn-line.prod-code  = t-doc-line-rcv.prod-code
                            no-lock :

                      sum-trn = sum-trn + t-trn-line.fact-qnty.
                      sum-trn1 = sum-trn1 + t-trn-line.fact-qnty.
                  end.
               end.
              sum-rcv = sum-rcv + t-doc-line-rcv.qnty.
            end.
            sum-ord = sum-ord + t-doc-line.qnty.
            if t-doc-line.qnty > sum-trn1 then v-tt-qnty = true .
            sum-trn1 = 0 .
        end.

            if  sum-trn = 0  then do:
                if p-ask then  do:
                message  (if shar-buf_ord-doc.doc-type  =  {&o-f} then " Заявка " else " Заказ" ) shar-buf_ord-doc.doc-code " не имеет ПН (или полностью ей не соответствует) ! Закрыть в статус (ФАКТ-) ? "
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  {&o-f} then " заявку " else "заказ" )
                  update g#log
                .
                end.
                else g#log = false .
                if not g#log then return error substitute( " Документ &1 , не имеет ПН (или полностью ей не соответствует)!  ", shar-buf_ord-doc.doc-code  ) .
                shar-buf_ord-doc.flag_ = false .
            end.



            if  sum-ord > sum-trn then do:
                if p-ask then  do:
                    message  (if shar-buf_ord-doc.doc-type  =  {&o-f} then " Заявка " else " Заказ" ) shar-buf_ord-doc.doc-code
                     " не покрыт ПН полностью ! Закрыть в статус (ФАКТ-) ? " skip
                      "по заказу =" sum-ord skip
                      "по накладным ="sum-trn
                      view-as alert-box question
                      buttons yes-no
                      title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  {&o-f} then " заявку " else "заказ" )
                      update g#log
                    .
                end.
                else do:
                  /* Если отношение 1:1 то закрываем заказ */
                      run ver-qnty-rcv-from-ord (input shar-buf_ord-doc.doc-code , output v-is-limit ) .
                      if v-is-limit then do:
                        g#log = true .
                      end.
                      else do:
                        g#log = false .
                      end.
                end.

                if not g#log then  return error substitute( " Документ &1 , не покрыт ПН полностью !  ", shar-buf_ord-doc.doc-code  ) .
                shar-buf_ord-doc.flag_ = false .
            end.
            if  sum-ord =  sum-trn then do:
                shar-buf_ord-doc.flag_ = true  .
                if v-tt-qnty = true then shar-buf_ord-doc.flag_ = false .
            end.
            if  sum-ord <  sum-trn then do:
                if p-ask then  do:
                  message "На "  (if shar-buf_ord-doc.doc-type  =  {&o-f} then " Заявка " else " Заказ" ) shar-buf_ord-doc.doc-code
                  ( if v-tt-qnty = true
                    then "Несоответствие количеств по ПН ! Закрыть в статус (ФАКТ-) ? "
                    else "Превышено количество по ПН ! Закрыть в статус (ФАКТ+) ? "
                   )
                   skip
                   "по заказу =" sum-ord skip
                   "по накладным =" sum-trn
                    view-as alert-box question
                    buttons yes-no
                    title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  {&o-f} then " заявку " else "заказ" )
                    update g#log
                  .
                end.
                else do:
                  /* Если отношение 1:1 то закрываем заказ */
                      run ver-qnty-rcv-from-ord (input shar-buf_ord-doc.doc-code , output v-is-limit ) .
                      if v-is-limit then do:
                        g#log = true .
                      end.
                      else do:
                        g#log = false .
                      end.
                end.

                if not g#log then return error substitute( " Документ &1 , превышено количество по ПН !  ", shar-buf_ord-doc.doc-code  ) .
                shar-buf_ord-doc.flag_ = true  .
                if v-tt-qnty = true then shar-buf_ord-doc.flag_ = false .
            end.
            /* проставим по договору необходимость создания ФО */
            if shar-buf_ord-doc.contract-code <> 0 then do:
                find first buf_contract no-lock where
                           buf_contract.host-code = shar-buf_ord-doc.host-code and
                           buf_contract.contract-code = shar-buf_ord-doc.contract-code no-error .
                 if available buf_contract and
                     ( buf_contract.usl-opl = {&contr-pay-order}
                     or buf_contract.usl-opl = {&contr-pay-order-delay}) then do:
                    shar-buf_ord-doc.need-fo = 1 .
                    shar-buf_ord-doc.cr-fo = no .
                 end.

            end.

            for each t-ord-doc-rcv exclusive-lock where
                     t-ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code and
                     t-ord-doc-rcv.status_  <> {&fact}
                     :
              assign
                  t-ord-doc-rcv.status_ = {&fact}
                  t-ord-doc-rcv.flag_   = false
                  .
            end.

            assign
              shar-buf_ord-doc.status_   = {&fact}
              shar-buf_ord-doc.fact-date = to-day
             .
             {&send-to-news-fact} /* передаем документ в новости */
      end.
 end case.



procedure verif_1 :
do
on error undo, return error return-value
:
define output parameter v-ret as logical no-undo .
 v-ret = true .

/* Проверка совпадения периода продаж  */
define buffer later-ord-doc  for  ub.ord-doc  .
define buffer later-ord-line for  ub.ord-line .
define buffer today-ord-line for  ub.ord-line .

define variable v-qnty as decimal no-undo .
define variable v-exis as logical no-undo .
define variable v-txt as character no-undo .

 output stream errStream to value( v-file-name )  .

v-exis = false .
for each  temp-obj-list :
  delete temp-obj-list .
end.

define variable str-pos as integer no-undo .
define variable str-pos2 as integer no-undo .
define variable str-1 as character no-undo .
define variable i  as integer no-undo .
define variable e1 as character no-undo .
define variable e2 as integer no-undo .
define variable k1 as integer no-undo .
define variable v-nn as integer   no-undo .
if shar-buf_ord-doc.doc-type = {&f-p} then do:
    k1 = 0 .

    str-pos = index (  shar-buf_ord-doc.e-method , "&" ) .
    str-pos2 = length ( shar-buf_ord-doc.e-method ) - str-pos .

    str-1 = substring (shar-buf_ord-doc.e-method , str-pos + 1 , str-pos2 ).
    v-nn = num-entries (str-1) .
    do i = 1 to v-nn :
        assign
          e1 = entry(1, (entry( i , str-1, "," )) , " ")
          e2 = integer(entry(2, (entry( i , str-1, "," )), " " ))
          no-error .
          if error-status :error then next.
          k1 = k1 + 1.
          create temp-obj-list.
          assign
            temp-obj-list.obj-type = e1
            temp-obj-list.obj-code = e2
          .
    end .

    if k1 < 1 then do :
       /* все объекты фирмы */
       run sss in this-procedure .
    end.
end.
else do:
   create temp-obj-list.
   assign
     temp-obj-list.obj-type = shar-buf_ord-doc.obj-type
     temp-obj-list.obj-code = shar-buf_ord-doc.obj-code
   .
end.


for each today-ord-line where today-ord-line.doc-code = shar-buf_ord-doc.doc-code and today-ord-line.qnty > 0 no-lock :
      v-qnty = 0.
      v-txt  = "" .
        for each later-ord-line where
                                later-ord-line.artic     = today-ord-line.artic     and
                                later-ord-line.prod-type = today-ord-line.prod-type and
                                later-ord-line.prod-code = today-ord-line.prod-code no-lock ,
            each  later-ord-doc where  later-ord-line.doc-code = later-ord-doc.doc-code and
                              ( later-ord-doc.status_ = {&ord-accept} or
                                later-ord-doc.status_ = {&ord-rcv} or
                                later-ord-doc.status_ = {&ord-close}
                                ) and
                                later-ord-doc.doc-code <> today-ord-line.doc-code and

                                ( if shar-buf_ord-doc.cons-code <> "" then
                                   later-ord-doc.cons-code <> shar-buf_ord-doc.cons-code
                                   else
                                   true = true )
                                 and
                                later-ord-doc.date-sale-1 <= shar-buf_ord-doc.date-sale-2  and
                                later-ord-doc.date-sale-2 >= shar-buf_ord-doc.date-sale-1   and
                                later-ord-doc.host-code = shar-buf_ord-doc.host-code   no-lock ,
             each temp-obj-list where temp-obj-list.obj-code = later-ord-doc.obj-code and
                                      temp-obj-list.obj-type = later-ord-doc.obj-type no-lock :
          v-qnty = v-qnty +  later-ord-line.qnty .
          v-txt  = v-txt  +  trim(later-ord-line.doc-code) + ";" .
        end.

        if v-qnty > 0 then do:
          find first ub.goods where
                today-ord-line.artic     = ub.goods.artic      and
                today-ord-line.prod-type = ub.goods.prod-type  and
                today-ord-line.prod-code = ub.goods.prod-code  no-lock no-error.
          Put  stream  errStream unformatted
          "По объекту :"  shar-buf_ord-doc.obj-type shar-buf_ord-doc.obj-code  skip
          "По товару :"  today-ord-line.artic       today-ord-line.prod-type       today-ord-line.prod-code skip
          ub.goods.gds-name skip
          "По документам :"    v-txt skip
          "Уже заказано (в пути) :" v-qnty    " "    ub.goods.unit-base   skip
          skip
          "По текущему документу № " shar-buf_ord-doc.doc-code  " кол-во заказа : " today-ord-line.qnty " " ub.goods.unit-base skip
          "Анализируемый период продаж с " shar-buf_ord-doc.date-sale-1 " по " shar-buf_ord-doc.date-sale-2 skip
          "Итого :"  ( v-qnty  + today-ord-line.qnty )   skip
          "--------------------------------------------------------------------"
          skip.
          v-exis = true.
        end.

end. /* foreach */

/* есть err */
if v-exis = true then do:
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical no-undo .

    if p-ask then  do:
      message
       "При проверке товаров по периоду продаж были обнаружены повторы ! " skip
       "Вы можете просмотреть и распечатать их список . "
       skip "Документ" shar-buf_ord-doc.doc-code
       view-as alert-box error .
    end.

   Output stream errStream   close .
  if p-ask then do:
    run gbl/prnfilen.w
      (input  "Повторы, обнаруженные при проверке товаров по периоду продаж"
      ,input  0
      ,input  v-file-name
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .

       if not ( lookup( {&v-screen}, v-user-action ,";")  > 0 or
                lookup( {&v-printer}, v-user-action ,";")  > 0  ) then do:
        message "Внимание! Вы не просмотрели список повторных заказов ! "  .
       end.
  end. /*if p-ask then do:*/
      v-ret = false .
      return.
end.
v-ret = true .
return.
end. /* do */
end procedure. /* verif_1 */




procedure sss :

  define variable v-object-available as logical   no-undo .

  define buffer buf_clients for ub.clients .

  do
  on error undo, return error return-value
  :
    /* все объекты по фирме g#host-code,
       для всех объектов (если в ГБД) или только по объектам УБД,
       для объектов у которых у пользователя есть права */

    for each buf_clients no-lock
      where buf_clients.host-code = g#host-code
        and ( ( buf_clients.db-num = p-db-num ) or p-db-num = 0 )
    on error undo, return error return-value
    :
      { gbl/usobjava.i
        v-cntxt-db-num
        {&action-head-code-main}
        v-cntxt-userid
        buf_clients.obj-type
        buf_clients.obj-code
        v-object-available
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры gbl/usobjava.i" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return no-apply .
      end.

      if v-object-available = true
      then do:
        create temp-obj-list.
        assign
          temp-obj-list.obj-type = buf_clients.obj-type
          temp-obj-list.obj-code = buf_clients.obj-code
        .
      end.
    end.
  end.

end procedure. /* sss */