/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусок интерфейса списка заказа

Автор: Чернова Светлана Александровна
Дата создания: 03/02/02
Author: Svetlana Chernova
Creation date: 03/02/02


*/
/* ***************  Runtime Attributes and UIB Settings  ************** */
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/waitfram.i }
{ gbl/clntattr.i }
{ cus/str-edi.i no }
{ gbl/fltfield.i }
{ cus/ord-code.i def }
{ gbl/fltopend.i defproc }
{ gbl/key-rec.i  }
{ cus/orddoatt.i }
{ cus/ordlnatt.i }
{ cus/vqntyrcv.i }
{ gbl/isoraret.i }
{ cus/vcopm.i    }

define new shared variable x-make-avto as integer  no-undo .

define new shared buffer   buf-oo_ord-doc for ub.ord-doc.
define new shared buffer   buf-or_ord-doc for ub.ord-doc.
define temp-table tempclip-orddoc no-undo like ub.ord-doc.
 &scop order-field  base-rate~
,base-scale~
,buyer-out-code~
,cli-code~
,cli-out-doc~
,cli-point-code~
,cli-point-db-num~
,cli-type~
,cons-code~
,contract-code~
,cycle-day~
,date-pay~
,deliv-subj-code~
,deliv-type-code~
,doc-type~
,exch-code~
,exch-rate~
,exch-scale~
,fact-date~
,fact-order~
,fact-time~
,flag_~
,host-code~
,obj-code~
,obj-point-code~
,obj-point-db-num~
,obj-type~
,ord-date1~
,ord-date2~
,ord-date3~
,ord-dec1~
,ord-dec2~
,ord-dec3~
,ord-int1~
,ord-int2~
,ord-int3~
,order-type~
,pay-code~
,pay-day~
,shift-date~
,shift-name~
,shift-num~
,ship-date~
,ship-time~
,slt-type~
,vat-type~
,status_~
,sum-service~
,sum-ship~
,transport-cli-code~
,transport-cli-type~
,transport-condition~
,transport-contract~
,transport-host-code~
,transport-value~
,transport-VAT~

&scop order-field-rus  Баз.валюта_м.б.~
,Баз.валюта_шкала~
,Номер по поставщику~
,Код Поставщика~
,Номер по Поставщику~
,Пункты доставки~
,Пункты доставки~
,Тип Поставщика~
,Код~
,Договор~
,Цикл~
,Дата платежа~
,Код доставки~
,Код доставки~
,Тип заказа~
,Валюта~
,Курс валюты поставщика~
,М.б. валюты поставщика~
,факт дата~
,факт номер~
,факт врем~
,флаг~
,фирма~
,Объект код~
,Доставка код~
,Доставка БД~
,Объект тип~
,ord-date1~
,ord-date2~
,ord-date3~
,ord-dec1~
,ord-dec2~
,ord-dec3~
,Статус Edoc-NN\EDI~
,ord-int2~
,ord-int3~
,тип заказа~
,код платежа~
,дней продаж~
,сменная дата~
,смена~
,смена №~
,Дата доставки (Заказ на)~
,Время доставки~
,Тип НсП~
,Тип НДС~
,Статус~
,Сумма обслуживани~
,Сумма доставки~
,Транспортный договор (Контрагент код)~
,Транспортный договор (Контрагент тип)~
,Транспортный договор (условия)~
,Транспортный договор (№ договора)~
,Транспортный договор (код фирмы)~
,Транспортный договор~
,Транспортный договор (НДС)~


define variable varnext-prev      as logical   no-undo.
define variable p-file as character no-undo.
define variable bf-handle         as handle    no-undo.
define variable v-spis-status     as character no-undo .
define variable g-log             as logical   no-undo .
define variable v-doc-mode        as character no-undo .
define variable filter-point      as character no-undo init "zakz-rcv" .
define variable filter-point0     as character no-undo init "zakz-rcv" .
define variable filter-label      as character no-undo init "Список заказов" .
define variable sort-column-name  as character no-undo .
define variable g#db-remote       as logical   no-undo .
define variable v-fin-block       as logical   no-undo init true .
define variable par-is-finby      as character no-undo .
/*define variable par-type        as character no-undo .*/
define variable is-finby          as logical   no-undo .
define variable par-is-edi        as character no-undo .
define variable par-is-edoc-nn    as character no-undo .

define variable p-status   as date      no-undo .
define variable v-edoc-status as integer   no-undo .
define variable v-edoc-ora as logical   no-undo .
define variable v-dm-edi  as integer no-undo .
define variable kk as integer no-undo .
 v-edoc-ora = isoraret_on () .

if Lookup("fin-block", p-buttons) <> 0 then v-fin-block = true.
                                       else v-fin-block = false .

if v-cntxt-db-num <> 0 then g#db-remote = true .
                       else g#db-remote = false .
/* Проверка на активный объект */
define variable v-obj-active  as character no-undo .
if v-cntxt-obj-type <> "" then do:
{ gbl/objat.i
  v-cntxt-obj-type
  v-cntxt-obj-code
  'active=request':u
  v-obj-active
  }
end.
else do:
  v-obj-active = 'no' .
end.

define variable v-not-activ  as logical   no-undo .
if v-obj-active <> "yes" and g#db-remote = true then v-not-activ = true .
else v-not-activ = false .

ASSIGN
  frame {&frame-name}:scrollable       = false
  br-docs:num-locked-columns in frame {&frame-name} = 4
  b-rep:popup-menu in frame {&frame-name}   = menu m-rep:handle
  b-rep:menu-mouse   = 1
  b-print:popup-menu in frame {&frame-name} = menu m-print:handle
  b-print:menu-mouse = 1
  b-print-rcv:popup-menu in frame {&frame-name} = menu m-print-rcv:handle
  b-print-rcv:menu-mouse = 1
  {&browse-name}:num-locked-columns in frame {&frame-name} = 5
  b-payment:popup-menu in frame {&frame-name} = menu m-payment:handle
  b-payment:menu-mouse = 1
  b-exec:popup-menu in frame {&frame-name} = menu m-exec:handle
  b-exec:menu-mouse = 1
  shar-buf_ord-doc.cli-name:resizable in browse {&browse-name}   = true .
  shar-buf_ord-doc.cons-code:resizable in browse {&browse-name}   = true .
.

if  v-fin-block = true   then do:   /* финансовый блок */
{ gbl/conf-rd.i "'is-finby'" "''" "''" 0 "''" "''" "''" no par-is-finby par-type no-error }
if error-status :error then par-is-finby = 'no' .
  assign
    is-finby = lookup(par-is-finby, "true,yes":U) > 0
  .
define variable v-right-supp  as logical no-undo .
define variable v-right-buyer as logical no-undo .
  v-right-supp = true .
  v-right-buyer = true .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-supp':U
    {&cntxt-firm}
    g#host-code
    ''
    0
    0
    0
    0
    true
    v-right-supp
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-buyer':U
    {&cntxt-firm}
    g#host-code
    ''
    0
    0
    0
    0
    true
    v-right-buyer
  }
  if v-right-supp = false or v-right-buyer = false  then return .

    ASSIGN
      MENU-ITEM m_lkp-fo    :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-1     :SENSITIVE IN MENU m-exec =  ( if v-cntxt-db-num = 0 then true else false )
      MENU-ITEM m_gen-1_buyer :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-2     :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-3     :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-4     :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-2-2   :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-3-2   :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-4-2   :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-exp       :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-cycle     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-del-cycle :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-cl        :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-del       :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-imp       :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-edoc-nn   :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-edoc-ok   :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-sost      :SENSITIVE IN MENU m-exec = true
      b-exec:label in frame {&frame-name}  = "Генерация ФО"
      b-exec:width-chars in frame {&frame-name}  = 13
      b-exec:tooltip in frame {&frame-name}  = "Функции по генерации и просмотру ФО"
    .
    /* С покупателями */
    if is-finby = false or v-right-buyer = false then
    assign
      MENU-ITEM m_gen-1_buyer :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-2-2     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-3-2     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-4-2     :SENSITIVE IN MENU m-exec = false
    .
    /* Споставщиками */
    if v-right-supp = false then
    assign
      MENU-ITEM m_gen-1 :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-2 :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-3 :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-4 :SENSITIVE IN MENU m-exec = false
     .

    /* Прав нет по пост и покуп */
    if v-right-supp = false and v-right-buyer = false then
    assign
      MENU-ITEM m_gen-1_buyer :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-2-2     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-3-2     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-4-2     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_lkp-fo      :SENSITIVE IN MENU m-exec = false
    .


end.
else do:
    ASSIGN
      MENU-ITEM m_lkp-fo    :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-1     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-1_buyer :SENSITIVE IN MENU m-exec =  false
      MENU-ITEM m_gen-2     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-3     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-4     :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-2-2   :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-3-2   :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m_gen-4-2   :SENSITIVE IN MENU m-exec = false
      MENU-ITEM m-exp       :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-cycle     :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-del-cycle :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-cl        :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-del       :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-imp       :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-edoc-nn   :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-edoc-ok   :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m-sost      :SENSITIVE IN MENU m-exec = true
      b-exec:label in frame {&frame-name}   = "Функции"
      b-exec:tooltip in frame {&frame-name}  = "Функции по расчету заказов"
      .
end.


{ gbl/conf-rd.i "'is-edi'" "''" "''" 0 "''" "''" "''" no par-is-edi par-type no-error  }
if error-status :error then is-edi = false .
assign
  is-edi = lookup(par-is-edi, "true,yes":U) > 0
.
{ gbl/conf-rd.i "'edoc-nn'" "''" "''" 0 "''" "''" "''" no par-is-edoc-nn par-type no-error }
if error-status :error then is-edoc-nn = false .
assign
  is-edoc-nn = lookup(par-is-edoc-nn, "true,yes":U) > 0
.
                            /*TO DO */
if ( is-edi = false and is-edoc-nn = false ) then do:
   assign
    menu-item m-edoc-nn     :sensitive in menu m-exec = false
    menu-item m-edoc-ok     :sensitive in menu m-exec = false
    menu-item m-edoc-rpl-ok :sensitive in menu m-exec = false
    &if "{1}" = "true" &then
    menu-item m-edoc-trn    :sensitive in menu m-exec = false
    &endif
    .
end.
/* ************************  Control Triggers  ************************ */
{ cus/p-zkz.i }
ON RETURN, MOUSE-SELECT-DBLCLICK OF sch-code IN FRAME d-all-docs DO:
    run proc-doc-code in this-procedure( no, input frame {&frame-name} sch-code ) no-error.
    return no-apply.
END.
ON RETURN, MOUSE-SELECT-DBLCLICK OF sch-date IN FRAME d-all-docs DO:
    assign
      sch-date
      no-error
    .
    run proc-doc-date in this-procedure( no, sch-date ) no-error.
    return no-apply.
END.
ON RETURN, MOUSE-SELECT-DBLCLICK OF sch-fact IN FRAME d-all-docs DO:
   assign
     sch-fact
     no-error
   .
    run proc-fact-date in this-procedure( no, sch-fact ) no-error.
    return no-apply.
END.
ON CTRL-J OF sch-code IN FRAME {&frame-name} /* номеру */
DO:
  run proc-doc-code in this-procedure(yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-date IN FRAME {&frame-name} /* номеру */
DO:
  assign
    sch-date
  .
  run proc-doc-date in this-procedure(yes, sch-date) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-fact IN FRAME {&frame-name} /* номеру */
DO:
assign
  sch-fact
.
  run proc-fact-date in this-procedure(yes,  sch-fact) no-error.
  if error-status:error then return no-apply.
END.

ON CHOOSE OF MENU-ITEM m-sost in menu m-exec DO:  /* Состояние */
define variable pardoc-rec as recid no-undo .
find current shar-buf_ord-doc no-lock no-error .
if not  available shar-buf_ord-doc then return no-apply .
varnext-prev = no.
br-handle = br-docs:handle  in frame {&frame-name} .
bf-handle = buffer shar-buf_ord-doc:handle in frame {&frame-name} .
do while varnext-prev <> ?:
  if not available shar-buf_ord-doc then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
  pardoc-rec = recid (shar-buf_ord-doc)  .
  run cus/ord-sost.w
    ( parParentProc ,
      {&lookup} ,
      shar-buf_ord-doc.doc-code ,
      br-handle ,
      bf-handle ,
      input-output varnext-prev ,
      input-output pardoc-rec
      )  .
  if br-handle = ? then do:
     reposition br-docs to recid pardoc-rec no-error.
     apply "value-changed" to br-docs in frame {&frame-name} .
  end.

 end.
END.

ON CHOOSE OF MENU-ITEM m-edoc-nn in menu m-exec DO:  /* шапки */
define variable v-rec as recid no-undo .
define variable v-err as logical no-undo .
define variable is-edi-doc as logical no-undo .
 if ( is-edoc-nn = false and is-edi = false ) then return .     /*TO DO*/
    find current shar-buf_ord-doc no-lock no-error .
    v-rec = recid(shar-buf_ord-doc) .
    /*повторной выгрузки в EDI не должно быть -но это выгрузка нового заказа - !!!*/
    run ver-clients-calc (
          input shar-buf_ord-doc.cli-type
        , input shar-buf_ord-doc.cli-code
        , input shar-buf_ord-doc.obj-type
        , input shar-buf_ord-doc.obj-code
        , input shar-buf_ord-doc.e-method
        , output v-err
                          ) .
    if v-err then do:
     message 'Заказ не был раcсчитан !!!' view-as alert-box error .
     return .
    end.
    run ver-ord-line (input shar-buf_ord-doc.doc-code, output v-err ) .
    if v-err then do:
     message 'Имеются ошибки в линиях !!!' view-as alert-box error .
     return .
    end.
    run cus/edocsord.p ( input parparentproc
                        ,input v-rec
                        ,input {&table_ord-doc}
                        ,input no
                        )  .
    run UI-on in this-procedure (yes, no, '':U).
    reposition br-docs to recid v-rec no-error.
    apply "value-changed" to br-docs in frame {&frame-name} .

END.

ON CHOOSE OF MENU-ITEM m-edoc-ok in menu m-exec DO:  /* шапки */
define variable v-rec as recid no-undo .
/* if ( is-edoc-nn = false and is-edi = false ) then return .     /*TO DO*/*/
    find current shar-buf_ord-doc no-lock no-error .
    v-rec = recid(shar-buf_ord-doc) .
    if  ( is-edi     = false or shar-buf_ord-doc.whole-send-news <> integer({&doc-dm-edi}) )
    and ( is-edoc-nn = false or shar-buf_ord-doc.whole-send-news <> integer({&doc-dm-edoc-nn}) )
    then return.
    run cus/edocrok.p ( input parparentproc).
    run UI-on in this-procedure (yes, no, '':U).
    reposition br-docs to recid v-rec no-error.
    apply "value-changed" to br-docs in frame {&frame-name} .

END.

ON CHOOSE OF MENU-ITEM m-edoc-rpl-ok in menu m-exec DO:  /* шапки */
define variable v-rec as recid no-undo .
if ( is-edoc-nn = false and is-edi = false ) then return .
    find current shar-buf_ord-doc share-lock no-error .
    v-rec = recid (shar-buf_ord-doc) .
    if  ( is-edoc-nn = false or shar-buf_ord-doc.whole-send-news <> integer({&doc-dm-edoc-nn}) )
    then return.
    if not
    (shar-buf_ord-doc.whole-send-news = integer({&doc-dm-edoc-nn})
      and (shar-buf_ord-doc.ord-int1  =  integer({&edoc-rpl})
            or
            shar-buf_ord-doc.ord-int1  =  integer({&edoc-pst})
          )
            )
    then do:
    &scop order-stts-int1 string(shar-buf_ord-doc.ord-int1)
      message
      substitute("Заказ &1 находится в статусе &2&3" +
                 "отсылка подтверждения в этом статусе НЕПРЕДУСМОТРЕНА&3" +
                 "Попробуйте ОБНОВИТЬ данные на экране (нажмите F5),&3" +
                 "чтобы увидеть текущий статус заказа"
                , shar-buf_ord-doc.doc-code
                , {&edoc-stts-name}
                , {&new-line})
     view-as alert-box error .
     return no-apply.
    end.
    run cus/edocsord.p ( input parparentproc
                        ,input v-rec
                        ,input {&table_ord-doc}
                        ,input no
                        )  .
    run UI-on in this-procedure (yes, no, '':U).
    reposition br-docs to recid v-rec no-error.
    apply "value-changed" to br-docs in frame {&frame-name} .
END.

&if "{1}" = "true" &then
ON CHOOSE OF MENU-ITEM m-edoc-trn in menu m-exec DO:  /* шапки */
define variable v-rec1 as recid no-undo .
define variable v-rec2 as recid no-undo .
define variable v-rec as recid no-undo .
 if is-edoc-nn = false then return .     /*TO DO*/

    find current shar-buf_ord-doc no-lock no-error .
    v-rec2 = recid( shar-buf_ord-doc ) .
if  ( is-edoc-nn = false or shar-buf_ord-doc.whole-send-news <> integer({&doc-dm-edoc-nn}) )
    then return.

    find current ord-doc-rcv no-lock no-error .
    v-rec1 = recid( ord-doc-rcv ) .
    find current trn-doc no-lock no-error .
    if not available trn-doc then do:
       message "Накладной нет! " view-as alert-box information .
       return .
    end.

    if trn-doc.status_ <>  {&fact} then do:
       message "Статус накладной должен быть ФАКТ ! " view-as alert-box information .
       return .
    end.

    v-rec = recid ( trn-doc ) .
    Message
    substitute("Пересылать вручную накладную &1. Продолжать ?" , trn-doc.doc-code  )view-as alert-box
              QUESTION buttons YES-NO update g#log.
              if NOT g#log then return .

    run cus/edocsord.p ( input parparentproc
                        ,input v-rec
                        ,input {&table_trn-doc}
                        ,input no
                        )  .

    run ui-on in this-procedure (yes, no, '':u).
    reposition br-rcv to recid v-rec1 no-error.
    apply "value-changed" to br-rcv in frame {&frame-name} .

    reposition br-docs to recid v-rec2 no-error.
    apply "value-changed" to br-docs in frame {&frame-name} .

END.
&endif

ON CHOOSE OF MENU-ITEM m-exp in menu m-exec DO:  /* шапки */
   run cus/g-allord.p (parParentProc , g#type ).
END.
ON CHOOSE OF MENU-ITEM m-imp in menu m-exec DO:  /* шапки */
   run cus/ord-load.p (parParentProc , g#type) .
   run UI-on (yes, no, '':U) .
END.
ON CHOOSE OF MENU-ITEM m-cycle in menu m-exec DO:  /* шапки */
  define variable ll-recid as recid no-undo .
  define variable v-kol-ord as integer   no-undo .
  find current shar-buf_ord-doc no-lock no-error .
  if avail shar-buf_ord-doc then do:
    ll-recid = recid ( shar-buf_ord-doc ).
    run cus/ord-cyc.p
      (input v-cntxt-obj-type ,
       input v-cntxt-obj-code ,
       input this-procedure ,
       output v-kol-ord
    ).
    run UI-on in this-procedure  (yes, no, '':U) .
    /*reposition br-docs to recid ll-recid no-error.*/
    apply "value-changed" to br-docs in frame {&frame-name} .
END.
END.
ON CHOOSE OF MENU-ITEM m-del-cycle in menu m-exec DO:  /* шапки */
  define variable ll-recid as recid no-undo .
  
  find current shar-buf_ord-doc no-lock no-error .
  if avail shar-buf_ord-doc then do:
    ll-recid = recid (shar-buf_ord-doc).
    run cus/ord-dcyc.p ( ll-recid) .
    run UI-on in this-procedure (yes, no, '':U) .
    reposition br-docs to recid ll-recid no-error.
    apply "value-changed" to br-docs in frame {&frame-name} .
  end.
END.
ON CHOOSE OF MENU-ITEM m-del in menu m-exec DO:  /* шапки */
   If v-cntxt-db-num <> 0  Then message "Расчет возможен только в ГБД" view-as alert-box .
   Else DO :
      run cus/ord-date.w ( parParentProc , g#type).
      run UI-on in this-procedure  (yes, no, '':U) .
   End.
END.

ON CHOOSE OF MENU-ITEM m-cl in menu m-exec DO:  /* шапки */
    run UI-on in this-procedure  (yes, no, '':U) .
    Message "Автоматическое закрытие документов в текущем списке в статусе ЗАКРЫТО. Продолжать ?" view-as alert-box
              QUESTION buttons YES-NO update g#log.
              if NOT g#log then return .

      DO WHILE AVAILABLE(shar-buf_ord-doc)  :
        if shar-buf_ord-doc.status_ = {&ord-close} then do:
                 run cus/ord-clos.p
                 (
                   input   parParentProc
                  ,input   recid(shar-buf_ord-doc) /* recid  заказа  */
                  ,input   store-type     /* текущий объект , где закрывается поставка */
                  ,input   store-code     /* текущий объект  */
                  ,input   v-cntxt-db-num /*  текущая база данных */
                  ,input   false          /* задавать вопросы или молча=false */
                  , input  "no" /*p-param-list пока тока один параметр, говорит что edi или не edi*/
                  ) no-error .
        end.
        GET NEXT br-docs.
      END.
    run UI-on in this-procedure (yes, no, '':U) .
END.

ON CHOOSE OF MENU-ITEM m-client in menu m-payment DO:  /* контрагент в целом*/
    payment-type = {&client-cmp}.
    apply "choose" to b-payment in frame {&frame-name}.
END.

ON CHOOSE OF MENU-ITEM m-doc in menu m-payment DO:  /* документ */
    payment-type = {&documents}.
    apply "choose" to b-payment in frame {&frame-name}.
END.

ON CHOOSE OF b-history IN FRAME {&frame-name}  /* История */
DO:
    if available shar-buf_ord-doc then do:
        run cus/ordcdoc.w
        (
        parParentProc,
        shar-buf_ord-doc.host-code,
        shar-buf_ord-doc.doc-code,
        "" ) .
    end.
END.

on choose of b-mark in frame {&frame-name} do:
  run local-mark  in this-procedure no-error .
  if error-status :error  then return .
  g#log = {&browse-name}:select-next-row ().
  apply "entry" to {&browse-name} in frame {&frame-name}.
end.


on choose of b-sost in frame {&frame-name} do:
   define variable g-log as logical   no-undo .
   if not available shar-buf_ord-doc then return.
   if not ( shar-buf_ord-doc.doc-type = {&o-f} or shar-buf_ord-doc.doc-type = {&o-p}  ) then return no-apply .
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_pmnt-ord-doc_reject':U
        {&cntxt-object}
        g#host-code
        shar-buf_ord-doc.obj-type
        shar-buf_ord-doc.obj-code
        0
        0
        0
        true
        g-log
      }
   if not g-log then do:
      message
        "Отказ от заказа запрещен!"
      view-as alert-box error.
      return .
   end.
   run set-reject  in this-procedure no-error .
   if error-status :error then
   message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "Ошибка в процедуре  set-reject"
     view-as alert-box error
   .
end.

/* для устранения подвисания при неправильных нажатиях */
on any-printable of br-docs in frame {&frame-name} do:
  apply "entry" to sch-code in frame {&frame-name}.
end.

ON CHOOSE OF b-copy IN FRAME {&frame-name} /* Copy */
DO:
 define variable g-log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pmnt-ord-doc_add-def':U
    {&cntxt-object}
    g#host-code
    store-type
    store-code
    0
    0
    0
    true
    g-log
  }
 if not g-log then  return .
 run pp-1 in this-procedure .
End.

ON CHOOSE OF b-add IN FRAME {&frame-name} /* Добав */
DO:
 define variable g-log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pmnt-ord-doc_add-def':U
    {&cntxt-object}
    g#host-code
    store-type
    store-code
    0
    0
    0
    true
    g-log
  }
 if not g-log then  return .

  run proc-b-add in this-procedure .
END.

ON CHOOSE OF b-chg IN FRAME {&frame-name} /* Изм */
DO:
 define variable g-log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pmnt-ord-doc_update':U
    {&cntxt-object}
    g#host-code
    shar-buf_ord-doc.obj-type
    shar-buf_ord-doc.obj-code
    0
    0
    0
    true
    g-log
  }
 if not g-log then  return .

  run proc-b-chg in this-procedure .
END.

ON CHOOSE OF b-del IN FRAME {&frame-name} /* Удал */ DO:
 define variable g-log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pmnt-ord-doc_deletion':U
    {&cntxt-object}
    g#host-code
    store-type
    store-code
    0
    0
    0
    true
    g-log
  }
 if not g-log then  return .

run pp-2 in this-procedure .
END.


on choose of b-sch in frame {&frame-name} do:
assign
  tbl = 'ord-doc'
  join-tbl = 'shar-buf_ord-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code'                      , '№ заказа'  , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('order-type'                    , 'Цикличность' , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-type'                      , 'Тип'       , 'order-type-all',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_'                       , 'Статус'    , 'order-status-all',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('flag_'                         , 'ОК'        , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date'                      , 'Дата док-та', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date'                     , 'Дата факт'  , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code'  , 'Контрагент' , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code'  , 'Объект'     , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('agnt'                          , 'Исполнитель', 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('boss'                          , 'Менеджер'   , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('wrkr'                          , 'Кладовщик'  , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('creid'                         , 'Создал'     , 'usr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code'                     , 'Фирма'      , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-code'                      , 'Код оплаты' , 'pay',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ship-date'                     , 'Дата отгрузки' , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ship-time'                     , 'Время отгрузки', 'time',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS'                            , 'Примечание', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('buyer-out-code'                , '', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-out-doc'                   , '', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('contract-code'                 , 'Вн.№ договора', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('exch-code'                     , 'Валюта','curr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name'                     , 'Правил', 'usr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

    Filter-Block:
    DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
        ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
        ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
      run gbl/filter.w (
        INPUT parparentproc,
        INPUT filter-point  + {&delim-par} + filter-label + {&delim-par} + "yes",
        INPUT tbl,
        INPUT join-tbl,
        INPUT fld,
        INPUT lab,
        INPUT spr,
        INPUT dim ).
      run UI-on in this-procedure (yes, no, '':U).
    END. /* Filter-Block */
end.



ON CHOOSE OF b-lkp IN FRAME {&frame-name} /* Просмотр */
DO:
 define variable g-log as logical   no-undo .

  /* todo - сделать отдельную проверку прав для заказов по фирме */

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pmnt-ord-doc_lookup':U
    {&cntxt-object}
    g#host-code
    store-type
    store-code
    0
    0
    0
    true
    g-log
  }

  if not g-log
  then do:
    return . /* --->>>--- */
  end.

{&net-proc-lkp}
next-prev = no.
br-handle = br-docs:handle.
do while next-prev <> ?:
  if not available shar-buf_ord-doc then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
  bf-handle = buffer shar-buf_ord-doc:handle in frame {&frame-name} .
  run cus/ord-zakz.p (
     input        parParentProc ,
     input        {&lookup} ,
     input        shar-buf_ord-doc.doc-type ,
     output       doc-rec ,
     input-output br-handle ,
     input-output bf-handle ,
     input-output next-prev
     ) .
end.
if br-handle = ? then do:
  reposition br-docs to recid doc-rec no-error.
end.
  apply "value-changed" to br-docs in frame {&frame-name} .

END.

ON CHOOSE OF b-print IN FRAME {&frame-name} /* {&print} */
DO:
    run gbl/pop-up.p ( self:handle, no) no-error.
    if error-status:error then return no-apply.
END.
ON CHOOSE OF b-email IN FRAME {&frame-name}
    DO:  
         g#log = true  .   
         IF NOT AVAILABLE shar-buf_ord-doc THEN RETURN .

  message "Отправить письмо по e-mail? ." skip "Продолжать ?"
           view-as alert-box question buttons ok-cancel update g#log.
           {&if-not-true}
     
        run cus/z-tott.p (parParentProc, shar-buf_ord-doc.doc-code,  shar-buf_ord-doc.obj-type, shar-buf_ord-doc.obj-code, output p-file).

        RETURN NO-APPLY.
    END.
ON CHOOSE OF b-cons IN FRAME {&frame-name}
DO:
  define variable v-recid as recid no-undo .
  run clip-ord in this-procedure ( output v-recid ).
  run UI-on    in this-procedure ( yes, no, '':U  ).
  reposition br-docs to recid v-recid no-error.
  apply "value-changed" to br-docs in frame {&frame-name} .
END.

ON CHOOSE OF b-print-rcv IN FRAME {&frame-name}
DO:
    run gbl/pop-up.p ( self:handle, no) no-error.
    if error-status:error then return no-apply.
END.


ON CHOOSE OF b-rep IN FRAME {&frame-name} /* {&reports} */
DO:
    if choice = ? then do:
        run gbl/pop-up.p (self:handle, no) no-error.
        if error-status:error then return no-apply.
    end.
END.

ON CHOOSE OF b-exec IN FRAME {&frame-name}
DO:
    if choice = ? then do:
        run gbl/pop-up.p (self:handle, no) no-error.
        if error-status:error then return no-apply.
    end.
END.

ON CHOOSE OF b-sel IN FRAME {&frame-name} /* {&choose} */
DO:
if not available shar-buf_ord-doc then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
doc-rec = recid (shar-buf_ord-doc).
if del-list = ? or del-list = "" then del-list = string(recid (shar-buf_ord-doc)).

DELETE WIDGET-POOL "My-pool" no-error  .
apply "go" to frame {&frame-name}.
END.

ON CHOOSE OF b-quit IN FRAME {&frame-name} /* Выход */
DO:
  if not ( del-list = ?  or  del-list = "" )  then do:
      run gbl/markqwa.p (
                    input b-mark:sensitive
                  , input ? ) no-error.
      if error-status:error then return no-apply.
  end.
  doc-rec = ?.
  del-list = ? .

  DELETE WIDGET-POOL "My-pool" no-error  .
END.

ON entry OF ed-notes IN FRAME {&frame-name}
DO:
if not available shar-buf_ord-doc then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
doc-rec = recid (shar-buf_ord-doc).
if shar-buf_ord-doc.status_ <> {&fact} and substring (shar-buf_ord-doc.PS, 1, 1) = "@" then
  message "Чтобы программа не могла заново переписать Ваше примечание, удалите знак @.".
END.

on leave of ed-notes in frame {&frame-name}
do:
  do on stop undo, return no-apply:
    find first t-d-b where t-d-b.doc-code = shar-buf_ord-doc.doc-code exclusive-lock no-error .
    if available t-d-b then
      t-d-b.ps = input frame {&frame-name} ed-notes.
    find first t-d-b where t-d-b.doc-code = shar-buf_ord-doc.doc-code no-lock  no-error .
  end.
end.

ON RETURN, MOUSE-SELECT-DBLCLICK OF ed-notes IN FRAME {&frame-name} DO:
apply "entry" to br-docs in frame {&frame-name}.
return no-apply.
END.

ON RETURN, MOUSE-SELECT-DBLCLICK OF br-docs IN FRAME {&frame-name} DO:
apply "choose" to b-lkp in frame {&frame-name}.
END.

ON iteration-changed OF br-docs do:
  if available shar-buf_ord-doc then do:
    find cli-buf where cli-buf.obj-type = {&prs} and cli-buf.obj-code = shar-buf_ord-doc.boss no-lock no-error.
    if available cli-buf then boss-name = cli-buf.obj-name. else boss-name = ?.
    find cli-buf where cli-buf.obj-type = {&prs} and cli-buf.obj-code = shar-buf_ord-doc.agnt no-lock no-error.
    if available cli-buf then agnt-name = cli-buf.obj-name. else agnt-name = ?.
    find cli-buf where cli-buf.obj-type = {&prs} and cli-buf.obj-code = shar-buf_ord-doc.wrkr no-lock no-error.
    if available cli-buf then wrkr-name = cli-buf.obj-name. else wrkr-name = ?.
    { gbl/usrfulnm.i
    shar-buf_ord-doc.creid
    v-user-name
    }
    find ub.pay-type where ub.pay-type.obj-code = shar-buf_ord-doc.pay-code no-lock no-error.
    if available ub.pay-type then pay-type = ub.pay-type.obj-name .

    ed-notes = trim(shar-buf_ord-doc.PS).
    disp ed-notes  boss-name agnt-name wrkr-name v-user-name shar-buf_ord-doc.tot-lines pay-type with frame {&frame-name}.
&if "{1}" = "true" &then
    {&OPEN-QUERY-BR-rcv}

    if shar-buf_ord-doc.doc-type = {&o-o} or
       shar-buf_ord-doc.doc-type = {&o-r} then do:
    disable b-add-2
            b-lkp-2
            b-chg-2
            b-del-2
            b-close-2  with frame {&frame-name} .
    end.
    else do:
    if x-mode <> "contract" /* and x-mode <> "firm-fintypestatus"  */ then
        enable b-add-2
                b-lkp-2
                b-chg-2
                b-del-2
                b-close-2  with frame {&frame-name} .
    end.

&endif
    if doc-rec <> recid (shar-buf_ord-doc) then do:
      sch-num = 0.
      hide sch-num in frame {&frame-name}.
    end.
  end.
end.

ON ROW-DISPLAY OF BR-DOCS DO:
define variable v-str as character no-undo .
define variable v-loc-color as integer no-undo .
assign
v-str = status-edoc-edi-light(buffer shar-buf_ord-doc, input is-edoc-nn, input is-edi, output v-loc-color)
no-error.

if error-status:error then do:
            str-status-edoc-nn:bgcolor in browse BR-DOCS = ?.
          end.
    else do:
  str-status-edoc-nn:bgcolor in browse BR-DOCS = v-loc-color.
    end.
    if ( shar-buf_ord-doc.need-fo = 1    and
       shar-buf_ord-doc.cr-fo    = true  and
       shar-buf_ord-doc.need-fo2  = 1    and
    shar-buf_ord-doc.cr-fo2 = false   )   then do:
       v-fo:fgcolor in browse BR-DOCS = 5  /* purpul - ждем доплату */ .
end.
end. /*ON ROW-DISPLAY OF BR-DOCS DO:*/
&if "{1}" = "true" &then
ON CHOOSE OF b-add-obj-2 IN FRAME {&frame-name} /* Добав по объектам */
DO:
define variable t-ret as logical no-undo .
 define variable g-log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ord-rcv_add-def':U
    {&cntxt-object}
    g#host-code
    store-type
    store-code
    0
    0
    0
    true
    g-log
  }
 if not g-log then  return .

{&net-proc}
  t-ret =  session:SET-WAIT-STATE("GENERAL") .


   if shar-buf_ord-doc.status_ <> {&ord-rcv}
     then do:
     message
     "Нельзя делать Поставку на  Заказ в статусе " caps(shar-buf_ord-doc.status_) " !"
                 view-as alert-box information .
        return.
   end.
   if (( ( shar-buf_ord-doc.ord-int1 = int({&edoc-acc})
      or shar-buf_ord-doc.ord-int1 = int({&edoc-acc-ok}) )
     and is-edoc-nn
          and shar-buf_ord-doc.whole-send-news = integer({&doc-dm-edoc-nn})
      )
   or (  shar-buf_ord-doc.ord-int1 = int({&edi-ordrsp-sts})
     and is-edi
        and shar-buf_ord-doc.whole-send-news = integer({&doc-dm-edi})
      )
   )
   and   shar-buf_ord-doc.doc-type = {&O-P} then do:
     message
     "Нельзя делать Поставки на Заказ при работе в EDOC\EDI ! Она придет в электронном виде от поставщика."
                 view-as alert-box information .
        return.
   end.

   if can-find (first ord-doc-rcv where ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code no-lock ) then do:
        message "Не могу сделать автоматические поставки по заказу " caps(shar-buf_ord-doc.doc-code) "!" "Поставки уже сформированы !"
                 view-as alert-box information .
        return.
        end.
   if shar-buf_ord-doc.e-method = "" then do:
     message
     "Не могу сделать автоматические поставки по заказу " caps(shar-buf_ord-doc.doc-code) "!" "Неизвестен список объектов."
                 view-as alert-box information .
        return.
   end.
   e-method = shar-buf_ord-doc.e-method .
   define buffer buf55_ord-line for ub.ord-line  .
   define buffer buf55_ord-line-attr for ub.ord-line-attr  .

   find first buf55_ord-line no-lock where
              buf55_ord-line.doc-code = shar-buf_ord-doc.doc-code no-error .
   if (not can-find ( first buf55_ord-line-attr where
                       buf55_ord-line-attr.doc-code = buf55_ord-line.doc-code and
                       buf55_ord-line-attr.gds-code = buf55_ord-line.gds-code and
                       buf55_ord-line-attr.attr-code  begins "objqnty" ) )
      or
      ( can-find ( first buf55_ord-line where
                          buf55_ord-line.doc-code = shar-buf_ord-doc.doc-code and
                          buf55_ord-line.qnty <> buf55_ord-line.order-qnty ) )
     then do:
     message "Количество заказа по объектам не определено или изменено вручную, предлагается распределение по поставкам пропорционально темпу продаж на объекте"
     view-as alert-box information .
     run cus/ord-mthd.w ( input parParentProc , input recid(shar-buf_ord-doc) ,input  shar-buf_ord-doc.doc-type ) .
   end.
   else do:
   run cus/ord-fpat.p ( input parParentProc ,input shar-buf_ord-doc.doc-code  ) .
   end.

  {&OPEN-QUERY-BR-rcv}
  t-ret =  session:SET-WAIT-STATE("") .
END.

ON CHOOSE OF b-add-2 IN FRAME {&frame-name} /* Добав */
DO:
define variable ll-rec as recid no-undo .
define variable t-ret as logical no-undo .
 define variable g-log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ord-rcv_add-def':U
    {&cntxt-object}
    g#host-code
    store-type
    store-code
    0
    0
    0
    true
    g-log
  }
 if not g-log then  return .

{&net-proc}
  t-ret =  session:SET-WAIT-STATE("GENERAL") .
  run make-fp-rcv in this-procedure (output ll-rec).
  {&OPEN-QUERY-BR-rcv}
  reposition BR-rcv to recid ll-rec no-error .
  t-ret =  session:SET-WAIT-STATE("") .
END.

ON CHOOSE OF b-chg-2 IN FRAME {&frame-name} /* Изм */
DO:
define variable ll-rec as recid no-undo .
define variable t-ret as logical no-undo .
define variable  v-line-mode  as character no-undo .
define variable  v-doc-mode   as character no-undo .
define variable  v-list-mode  as character no-undo .

 define variable g-log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ord-rcv_update':U
    {&cntxt-object}
    g#host-code
    store-type
    store-code
    0
    0
    0
    true
    g-log
  }
 if not g-log then  return .


{&net-proc}
  t-ret =  session:SET-WAIT-STATE("GENERAL") .
  find current ub.ord-doc-rcv no-lock no-error.
    if available ub.ord-doc-rcv then do:
      if ub.ord-doc-rcv.status_ = {&fact} then do :
        message "Документ в статусе" ub.ord-doc-rcv.status_  "изменять нельзя! " view-as alert-box error .
        return.
      end.
      if ub.ord-doc-rcv.cons-code <> ""  and  not v-edoc-ora
        then  do:
        Message "Внимание !!! Поставка из СЗФП ." view-as alert-box information  .
      end.

        v-doc-mode  = {&update}.
        ll-rec = recid(ub.ord-doc-rcv) .
        if ub.ord-doc-rcv.status_ = {&ord-rcv} then  do:
          assign
            v-line-mode  = {&lookup}
            v-doc-mode   = {&lookup}
            v-list-mode  = {&ord-rcv}
            .
        end.
        else  do:
          assign
            v-line-mode = {&update}
            v-doc-mode  = {&update}
            .
        end.
        run cus/or-obj.w
        (      input  parParentProc
             , input  ub.ord-doc-rcv.host-code
             , input  recid(ub.ord-doc-rcv)
             , input  3
             , input  v-list-mode
             , input  v-line-mode
             , input-output  v-doc-mode  ) .
        {&OPEN-QUERY-BR-rcv}
        reposition BR-rcv to recid ll-rec no-error .
    end.
  find current shar-buf_ord-doc no-lock .
  t-ret =  session:SET-WAIT-STATE("") .
END.

ON CHOOSE OF b-lkp-2 IN FRAME {&frame-name} /* Изм */
DO:
define variable ll-rec as recid no-undo .
define variable t-ret as logical no-undo .
define variable g-log as logical   no-undo .

   /* todo - сделать отдельную проверку прав для ord-rcv по фирме */

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ord-rcv_lookup':U
    {&cntxt-object}
    g#host-code
    store-type
    store-code
    0
    0
    0
    true
    g-log
  }

 if not g-log then  return .


next-prev = no.
br-rcv-handle = br-rcv:handle.

apply "entry" to BR-rcv .

do while next-prev <> ?:
  if not available bufs_ord-doc-rcv then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
{&net-proc-lkp}
  t-ret =  session:SET-WAIT-STATE("GENERAL") .
find current ub.ord-doc-rcv no-lock no-error.
    if available ub.ord-doc-rcv then do:
        ll-rec = recid(ub.ord-doc-rcv) .
        run cus/lkp-rcv.w (input parParentProc, input-output ll-rec ) .
        {&OPEN-QUERY-BR-rcv}
        reposition BR-rcv to recid ll-rec no-error .
    end.
    else
      t-ret =  session:SET-WAIT-STATE("") .
end.
  if br-rcv-handle = ? then do:
    reposition  br-rcv to recid ll-rec no-error.
  end.
  t-ret =  session:SET-WAIT-STATE("") .
END.

ON CHOOSE OF b-del-2 IN FRAME {&frame-name} /* Удалить */
DO:
 define variable g-log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ord-rcv_deletion':U
    {&cntxt-object}
    g#host-code
    store-type
    store-code
    0
    0
    0
    true
    g-log
  }
 if not g-log then  return .


   run proc-b-del-2 in this-procedure .
END.

oN CHOOSE OF b-close-2 IN FRAME {&frame-name}  /* Закрыть */
DO:
   run proc-close-2 in this-procedure .
END.


&endif

 on choose of b-payment in frame {&frame-name} do:
 {&net-proc-lkp}
    define variable ri-list as char no-undo .
    if payment-type = "" then do:
       run gbl/pop-up.p (self:handle, no) no-error.
    end.
    if payment-type = "" then return no-apply.
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_payments-reference_lookup':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      g#log
    }
    if not g#log then do:
      return no-apply.
    end.
    case payment-type:
      when {&documents} then do:
        if (shar-buf_ord-doc.status_  = {&fact} and shar-buf_ord-doc.flag_ = yes) then do:
          run ref/payments.w
          (
            input parparentproc ,
            input (if v-cntxt-db-num = 0  then "b-add" else ""),
            input {&documents} ,
            input ?,
            input ?,
            input {&pmnt-ord-doc},
            input shar-buf_ord-doc.doc-code,
            input "",
            output ri-list) no-error.
        end.
        else do:
          assign
          payment-type = "".
          return no-apply.
        end.
      end.
      when {&client-cmp} then do:
        find first ub.clients WHERE
                   ub.clients.obj-code = shar-buf_ord-doc.cli-code  AND
                   ub.clients.obj-type = shar-buf_ord-doc.cli-type  No-LOCK No-ERROR.
        run ref/payments.w
        (input parparentproc ,
                      input (if v-cntxt-db-num = 0 then "b-add" else ""),
                      input {&client-cmp} ,
                      input recid(clients),
                      input ?,
                      input "",
                      input "",
                      input "",
                      output ri-list) no-error.
      end.
    end case.
    assign
    payment-type = "".
    .
run UI-on in this-procedure (yes, no, '':U) .
end.

ON CHOOSE OF MENU-ITEM m_gen-1 /* Генерация */ IN MENU m-exec DO:
run proc-m_gen-1 in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.

ON CHOOSE OF MENU-ITEM m_gen-1_buyer /* Генерация */ IN MENU m-exec DO:
run proc-m_gen-1_buyer in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.

ON CHOOSE OF MENU-ITEM m_gen-2 /* Генерация */ IN MENU m-exec DO:
run proc-m_gen-2 in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-3 /* Генерация */ IN MENU m-exec DO:
run proc-m_gen-3 in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-4 /* Генерация */ in MENU m-exec DO:
run proc-m_gen-4 in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_lkp-fo /* Генерация */ in MENU m-exec DO:
run proc-m_lkp-fo in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-2-2 /* Генерация */ IN MENU m-exec DO:
run proc-m_gen-2-2 in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-3-2 /* Генерация */ IN MENU m-exec DO:
run proc-m_gen-3-2 in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-4-2 /* Генерация */ IN MENU m-exec DO:
run proc-m_gen-4-2 in this-procedure no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.

&Scop if-not-clos if not g#log then return error.

/* --------------------------------------------- начало триггера b-close ------------------------------------------- */
ON CHOOSE OF b-close IN FRAME {&frame-name} /* Закр */
DO:
define variable ll-recid as recid no-undo .
define variable mark-list as character no-undo.
define buffer buf_clients for ub.clients  .
define buffer buf_ext-classif for ub.ext-classif  .
define buffer buf1_ord-doc for ub.ord-doc.

  find current shar-buf_ord-doc no-lock no-error.
  if del-list = "" then 
    assign 
      mark-list = string(recid(shar-buf_ord-doc))
      .
  else
    assign 
      mark-list = del-list
      .
  
  do kk = 1 to num-entries(mark-list) :
    for each shar-buf_ord-doc share-lock where recid(shar-buf_ord-doc) = integer(entry(kk,mark-list)):

      if shar-buf_ord-doc.status_ = {&fact} and shar-buf_ord-doc.flag_= true  then do:
         message "Заказ закрыт до статуса ФАКТ .".
         next. 
      end.

  if ( shar-buf_ord-doc.status_ = {&g___new} or
       shar-buf_ord-doc.status_ = {&ord-rcv}) and
       shar-buf_ord-doc.doc-type = {&O-P} then do:
    if status-is-edoc-nn ( input is-edoc-nn
                          , input shar-buf_ord-doc.cli-type
                          , input shar-buf_ord-doc.cli-code
                          , input shar-buf_ord-doc.obj-type
                          , input shar-buf_ord-doc.obj-code
                          )
     or  (status-is-edi ( input is-edi
                      , input shar-buf_ord-doc.cli-type
                      , input shar-buf_ord-doc.cli-code
                      , input shar-buf_ord-doc.obj-type
                      , input shar-buf_ord-doc.obj-code
                      , output v-dm-edi
                      )
          and
          shar-buf_ord-doc.whole-send-news = integer({&doc-dm-edi})
          )
    then do:
      if shar-buf_ord-doc.status_ = {&g___new} then do:
        message
        substitute(" По ПОСТАВЩИКУ &1&2 система работает по EDOC\EDI , Закрыть можно будет при корректировке заказа в статусе EDOC\EDI ПОДТВЕРЖДЕН"
                   ,shar-buf_ord-doc.cli-type
                   ,shar-buf_ord-doc.cli-code
                   )
        view-as alert-box information .
            next .
      end. /*if shar-buf_ord-doc.status_ = {&g___new} then do:*/
      if shar-buf_ord-doc.status_ = {&ord-rcv} then do:
       define variable vv-ok as logical   no-undo .
       vv-ok = false .
       message
        substitute(" По ПОСТАВЩИКУ &1&2 система работает по EDOC\EDI. Заказ ожидает поставку. Вы уверены что хотите закрыть заказ без поставки?"
                   ,shar-buf_ord-doc.cli-type
                   ,shar-buf_ord-doc.cli-code)
           view-as alert-box question
           buttons yes-no
           update vv-ok
          .
            if not vv-ok then  next .
      end. /*if shar-buf_ord-doc.status_ = {&ord-rcv} then do:*/
    end. /*if status-is-edoc-nn ( input is-edoc-nn*/
  end. /*if ( shar-buf_ord-doc.status_ = {&g___new} or*/

  message
    "Закрыть " (if shar-buf_ord-doc.doc-type  =  {&o-f} then " заявку " else " заказ " ) shar-buf_ord-doc.doc-code  " ?"
    view-as alert-box question
    buttons yes-no
    update g#log .

      if not g#log then next.
      ll-recid = recid(shar-buf_ord-doc).
      run cus/ord-clos.p
        (input  parParentProc
        ,input  recid(shar-buf_ord-doc)       /* recid  заказа  */
        ,input  store-type                    /* текущий объект , где закрывается поставка */
        ,input  store-code                    /* текущий объект  */
        ,input  v-cntxt-db-num                /*  текущая база данных */
        ,input  true                          /* задавать вопросы или молча=false */
        ,input  "no" /*p-param-list пока тока один параметр, говорит что edi или не edi*/
        ) no-error .
        if error-status :error or return-value <> "" then do:
            message return-value         skip
            error-status :get-message(1) skip
            view-as alert-box error
            title "Закрытие заказа"
          .
        end.
    end.
  end.
  
  find current shar-buf_ord-doc no-lock no-error.
  run ui-on in this-procedure (yes, no, '':U).
  reposition br-docs to recid ll-recid no-error.
  apply "value-changed" to br-docs in frame {&frame-name} .
  return no-apply.
 END.


{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-lkp   }
{ gbl/hot-key.i b-add   }
{ gbl/hot-key.i b-chg   }
{ gbl/hot-key.i b-close }
{ gbl/hot-key.i b-del   }
{ gbl/hot-key.i b-mark  }
/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.


&if "{1}" = "true" &then
{ gbl/app_help.i &disable_diasize_init=true &browse-name="BR-docs"}
&endif
&if "{1}" <> "true" &then
{ gbl/app_help.i }
&endif

{ gbl/brwrefre.i "run UI-on (yes, no, '':U) ." }
{ gbl/ed_date.i sch-date}
{ gbl/ed_date.i sch-fact}
 x-mode =  list-mode.

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:


/* для жесткого фильтра по контр., м-ру, исп-лю, кл-ку */
find sch-cli where recid (sch-cli) = p-doc-rec no-lock no-error.

/* для жесткого фильтра по конc */
find sch-cons where recid (sch-cons) = p-doc-rec no-lock no-error.

/* для жесткого фильтра по Договорам */
find sch-contract where recid (sch-contract) = p-doc-rec no-lock no-error.
doc-rec = ?.
define variable v-ok as logical   no-undo .
define variable v-mail as logical no-undo.

v-mail = b-email:load-image ("cmp/www.bmp").
v-ok = b-cons:load-IMAGE ("cmp/group.bmp") .
ENABLE b-quit  b-print b-sch b-history b-help br-docs  sch-code sch-date sch-fact ed-notes  b-rep  b-exec b-cons b-email
&if "{1}" = "true" &then
 b-print-rcv
 br-rcv
&endif
WITH FRAME {&frame-name}.
 hide b-open in frame {&frame-name} .
/*&if "{1}" = "true" &then*/
/*/* не видно было */*/
/*if is-edi = false   then  do:*/
/*    v-st-edi:VISIBLE IN BROWSE {&browse-name} = FALSE.*/
/*end.*/
/*if g#type = {&F-P}  then*/
/*    assign*/
/*      v-st-edi:VISIBLE IN BROWSE {&browse-name} = FALSE*/
/*    .*/
/*&endif*/
if is-edoc-nn = false and is-edi = false then  do:
   str-status-edoc-nn:VISIBLE IN BROWSE {&browse-name} = FALSE.
end.

if g#type = {&F-P} or  g#type = {&O-F} then
    assign
      str-status-edoc-nn:VISIBLE IN BROWSE {&browse-name} = FALSE
    .


if lookup (x-mode,"firm-fin,firm-fintypestatus,without-fotypestatus,without-fo,with-fotypestatus,with-fo") > 0 then
{&browse-name}:MOVE-COLUMN ( 15, 8 ) IN FRAME {&frame-name} .


&if "{1}" = "true" &then
run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-rcv :handle
    ) .

run diasize_init in this-procedure .
&endif

run UI-on in this-procedure (yes, no, '':U).
run mode-g#type in this-procedure.

apply "value-changed" to br-docs in frame {&frame-name}   .

WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-docs.
END.

run disable_UI in this-procedure .

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE UI-on :
define input  parameter   p-open-query     as logical   no-undo init true .
define input  parameter   p-find-next      as logical   no-undo init false .
define input  parameter   p-find-condition as character no-undo .

  if p-open-query then frame {&frame-name}:title = "ВСЕ  ДОКУМЕНТЫ".
  sch-num = 0.
  hide sch-num in frame {&frame-name}.

define variable v-l-mode as character no-undo .
v-l-mode = list-mode .

x-mode  = list-mode.
if g#type <> "all" and g#type <> ? then x-mode  = list-mode + "type" .
if g#stat <> "all" and g#stat <> ? then x-mode  = list-mode + "type" + "status".

Disable b-payment  WITH FRAME {&frame-name}.

define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
filter-point = filter-point0 + v-l-mode.

{&SetCursorWait}
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.


&scop flt-open-open-query OPEN QUERY br-docs FOR EACH shar-buf_ord-doc no-lock

&scop flt-open-dyn_open-query  FOR EACH shar-buf_ord-doc

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name shar-buf_ord-doc

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name      set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          shar-buf_ord-doc

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer shar-buf_ord-doc for ub.ord-doc .

&scop flt-open-debug-file

&scop flt-open-waitfram             true

define variable l-open-query as logical   no-undo .

if Lookup("nob-exec",p-buttons) <> 0 then disable b-exec WITH FRAME {&frame-name}. else enable b-exec  WITH FRAME {&frame-name}.
if Lookup("nob-copy",p-buttons) <> 0 then disable b-copy WITH FRAME {&frame-name}. else enable b-copy  WITH FRAME {&frame-name}.

/* if Lookup("b-mark",p-buttons) <> 0 then enable b-mark WITH FRAME {&frame-name}. else disable b-mark  WITH FRAME {&frame-name}.*/
enable b-mark WITH FRAME {&frame-name}.
if Lookup("b-sel",p-buttons) <> 0 then enable  b-sel WITH FRAME {&frame-name}.  else disable b-sel   WITH FRAME {&frame-name}.
if Lookup("b-del",p-buttons) <> 0 then
   enable  b-del   &if "{1}" = "true" &then b-del-2 &endif   WITH FRAME {&frame-name}.
   else disable b-del &if "{1}" = "true" &then   b-del-2  &endif  WITH FRAME {&frame-name}.
if Lookup("b-lkp",p-buttons) <> 0 then
   enable b-lkp  &if "{1}" = "true" &then b-lkp-2 &endif   WITH FRAME {&frame-name}.
   else  disable b-lkp &if "{1}" = "true" &then   b-lkp-2 &endif     WITH FRAME {&frame-name}.
if Lookup("b-chg",p-buttons) <> 0 then
   enable b-chg  &if "{1}" = "true" &then b-chg-2 &endif   WITH FRAME {&frame-name}.
   else  disable b-chg &if "{1}" = "true" &then   b-chg-2 &endif     WITH FRAME {&frame-name}.
if Lookup("b-add",p-buttons) <> 0 then
   enable b-add  &if "{1}" = "true" &then b-add-2 &endif   WITH FRAME {&frame-name}.
   else  disable b-add &if "{1}" = "true" &then   b-add-2 &endif     WITH FRAME {&frame-name}.

if Lookup("b-close",p-buttons) <> 0 then
   enable b-close &if "{1}" = "true" &then b-close-2 &endif WITH FRAME {&frame-name}.
   else  disable b-close &if "{1}" = "true" &then  b-close-2 &endif  WITH FRAME {&frame-name}.


if Lookup("fin-block",p-buttons) <> 0 then
   disable b-close b-payment  b-copy &if "{1}" = "true" &then
           b-add-2
           b-chg-2
           b-close-2
           b-del-2
           b-add-obj-2
           &endif  WITH FRAME {&frame-name}.

if g#type = ?  then  do:
  disable b-add with frame {&frame-name} .
end.
if g#type = {&o-f} and v-cntxt-db-num = 0  then  do:
  disable  b-copy   with frame {&frame-name} .
end.



&if "{1}" = "true" &then
if g#type = {&o-p} and v-cntxt-db-num = 0  then  do:
  disable b-copy with frame {&frame-name} .
end.
&endif

CASE x-mode :
  when "firm":U then do:
      if p-open-query then frame {&frame-name}:title = " Фирма : " + g#host-name.
      Disable b-add b-chg b-del b-close   b-close b-copy b-sost  WITH FRAME {&frame-name}.
      Enable b-lkp

            /* b-payment  when NOT g#db-remote*/
      WITH FRAME {&frame-name}.
      if v-cntxt-level <>  {&cntxt-object} then do:  /* финансовый блок */
        Disable b-payment   WITH FRAME {&frame-name}.
        &if "{1}" = "true" &then
        disable b-add-2
              b-chg-2
              b-del-2
              b-close-2
              with frame {&frame-name} .
          &endif

      end.

      { gbl/fltopend.i
        &where-cond = " shar-buf_ord-doc.host-code = g#host-code "
        &dyn_where-cond = " substitute(' shar-buf_ord-doc.host-code =  &1 ' , g#host-code ) "
        &use-ind    = " USE-INDEX ByFirm "
        &by         = " " }
  end.
  when "firmord":U then do:
      if p-open-query then frame {&frame-name}:title = " Фирма : " + g#host-name + " и для объекта " + string( store-code) +  store-type .
      Disable b-add b-chg b-del b-close   b-close b-copy b-sost  WITH FRAME {&frame-name}.
      Enable b-lkp
            /* b-payment  when NOT g#db-remote*/
      WITH FRAME {&frame-name}.
      if v-cntxt-level <>  {&cntxt-object} then do:  /* финансовый блок */
        Disable b-payment   WITH FRAME {&frame-name}.
        &if "{1}" = "true" &then
        disable b-add-2
              b-chg-2
              b-del-2
              b-close-2
              with frame {&frame-name} .
          &endif
      end.

      { gbl/fltopend.i
        &where-cond                  = " (shar-buf_ord-doc.host-code = g#host-code or ( shar-buf_ord-doc.cli-code = store-code and  shar-buf_ord-doc.cli-type = store-type)) "
        &dyn_where-cond = " substitute(' (shar-buf_ord-doc.host-code =  &1         or ( shar-buf_ord-doc.cli-code = &2         and  shar-buf_ord-doc.cli-type = &4&3&4 ))' , g#host-code , store-code, store-type, ~{&double-quote~} ) "
        &by         = " "
        }
  end.


  when "firmtype":U then do:
      if p-open-query then frame {&frame-name}:title = "Фирма : " + g#host-name  + "  Тип : " + {&g-type-tit}.
      Enable  /* b-payment when NOT g#db-remote*/
             b-sost WITH FRAME {&frame-name}.
      {&ch-b-sost}
      { gbl/fltopend.i
        &where-cond = " shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.doc-type = g#type"
        &dyn_where-cond = " substitute(' shar-buf_ord-doc.host-code =  &1 and shar-buf_ord-doc.doc-type = &3&2&3 ' , g#host-code , g#type , ~{&double-quote~} ) "
        &use-ind    = " USE-INDEX ByType "
        &by         = " " }
  end.

  when "firmtypestatus" then do:
      if p-open-query then frame {&frame-name}:title = "Фирма : " + g#host-name
                              + "  Тип : " + {&g-type-tit}
                              + "  Статус : " + g#stat.
      Enable b-sost
             /*b-payment when NOT g#db-remote*/
             WITH FRAME {&frame-name}.
      {&ch-b-sost}
      { gbl/fltopend.i
        &where-cond = " shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.doc-type = g#type and shar-buf_ord-doc.status_ = g#stat"
        &dyn_where-cond = " substitute(' shar-buf_ord-doc.host-code =  &1 and shar-buf_ord-doc.doc-type = &3&2&3  and shar-buf_ord-doc.status_ = &3&4&3 ' , g#host-code , g#type , ~{&double-quote~} , g#stat) "
        &use-ind    = " USE-INDEX ByType "
        &by         = " " }
  end.
  when "firm-fintypestatus" then do:
      if p-open-query then frame {&frame-name}:title = "Фирма : " + g#host-name
                              + "  Статус : " + g#stat.

      v-spis-status = {&fact} + ","  + {&ord-rcv} .
      Enable b-mark b-sost    WITH FRAME {&frame-name}.
      disable b-add b-chg b-del b-close   b-close b-copy b-payment  WITH FRAME {&frame-name}.
        &if "{1}" = "true" &then
        disable b-add-2
                b-chg-2
                b-del-2
                b-close-2
             with frame {&frame-name} .
          &endif
      {&ch-b-sost}
      { gbl/fltopend.i
        &where-cond = " ((shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.status_ = g#stat and  shar-buf_ord-doc.doc-type = ~{&f-p~}) or
       (shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.status_ = g#stat and  shar-buf_ord-doc.doc-type = ~{&o-p~}) or
       (shar-buf_ord-doc.host-code = g#host-code and lookup (shar-buf_ord-doc.status_,v-spis-status) > 0 and  shar-buf_ord-doc.doc-type = ~{&p-o~})) "

       &dyn_where-cond = " substitute(' ~
       ((shar-buf_ord-doc.host-code = &2  and shar-buf_ord-doc.status_ = &1&3&1 and  shar-buf_ord-doc.doc-type = &1&4&1) or ~
       (shar-buf_ord-doc.host-code = &2 and shar-buf_ord-doc.status_ = &1&3&1 and  shar-buf_ord-doc.doc-type = &1&5&1) or    ~
       (shar-buf_ord-doc.host-code = &2 and lookup (shar-buf_ord-doc.status_,&1&6&1) > 0 and  shar-buf_ord-doc.doc-type = &1&7&1)) ~
       ' , ~{&double-quote~}  ~
       , g#host-code ~
       , g#stat     ~
       , ~{&f-p~}   ~
       , ~{&o-p~}   ~
       , v-spis-status ~
       , ~{&p-o~}  ~
       ) "
        &use-ind    = " USE-INDEX bytype "
        &by         = " " }
  end.
  when "without-fotypestatus" then do:
      if p-open-query then frame {&frame-name}:title = "НЕТ финансовых обязательств    Фирма : " + g#host-name .
      Enable b-mark b-sost     WITH FRAME {&frame-name}.
      disable b-add b-chg b-del b-close   b-close b-copy b-payment   WITH FRAME {&frame-name}.
        &if "{1}" = "true" &then
        disable b-add-2
              b-chg-2
              b-del-2
              b-close-2
             with frame {&frame-name} .
          &endif
      {&ch-b-sost}
      { gbl/fltopend.i
         &where-cond = " ( shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = no ) "
         &dyn_where-cond = " substitute(' shar-buf_ord-doc.host-code =  &1 and and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = no ' , g#host-code ) "
         &use-ind   = " USE-INDEX By_need-fo "
         &by        = " " }
  end.
  when "with-fotypestatus" then do:
      if p-open-query then frame {&frame-name}:title = "ЕСТЬ финансовые обязательства    Фирма : " + g#host-name .
      Enable b-mark  b-sost      WITH FRAME {&frame-name}.
      disable b-add b-chg b-del b-close   b-close b-copy b-payment   WITH FRAME {&frame-name}.
        &if "{1}" = "true" &then
        disable b-add-2
              b-chg-2
              b-del-2
              b-close-2
             with frame {&frame-name} .
          &endif
      {&ch-b-sost}
      { gbl/fltopend.i
        &where-cond = " shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = yes "
        &dyn_where-cond = " substitute(' shar-buf_ord-doc.host-code =  &1 and shar-buf_ord-doc.need-fo = 1  and  shar-buf_ord-doc.cr-fo = yes  ' , g#host-code ) "
         &use-ind   = " USE-INDEX By_need-fo "
         &by        = " " }
  end.

  when {&client-cmp} OR
  when {&client-cmp} + "typestatus":U then do:
      if p-open-query then frame {&frame-name}:title = "Контрагент : " + sch-cli.obj-name.
      Enable b-sost
             /*b-payment  when NOT g#db-remote*/
      WITH FRAME {&frame-name}.
      { gbl/fltopend.i
        &where-cond = " shar-buf_ord-doc.cli-type  = sch-cli.obj-type and shar-buf_ord-doc.cli-code  = sch-cli.obj-code and shar-buf_ord-doc.host-code = g#host-code "
        &dyn_where-cond = " substitute(' shar-buf_ord-doc.host-code =  &2 and ~
                            shar-buf_ord-doc.cli-type  = &1&3&1 and ~
                            shar-buf_ord-doc.cli-code  =  &4' , ~{&double-quote~} , g#host-code , sch-cli.obj-type , sch-cli.obj-code ) "
        &use-ind    = " USE-INDEX Bycli "
        &by         = " " }
  end.

  when "obj":U then do:
      if p-open-query then frame {&frame-name}:title = "Объект : " + store-type + " " + string(store-code)   .
      Disable b-add WITH FRAME {&frame-name}.
      Enable  b-sost WITH FRAME {&frame-name}.
      { gbl/fltopend.i
        &where-cond = " shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type"
        &dyn_where-cond = " substitute(' shar-buf_ord-doc.obj-code = &2 and ~
                            shar-buf_ord-doc.obj-type  = &1&3&1 ~
                            ' , ~{&double-quote~} , store-code , store-type ) "

        &use-ind    = " "
        &by         = " " }
  end.

  when "objtype":U then do:
      if p-open-query then frame {&frame-name}:title = "Объект : " + store-type + " " + string(store-code)  +
             "  Тип : " + {&g-type-tit}.
      Enable b-sost
             WITH FRAME {&frame-name}.
      { gbl/fltopend.i
        &where-cond = " shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type and shar-buf_ord-doc.doc-type = g#type "
        &dyn_where-cond = " substitute(' ~
                            shar-buf_ord-doc.obj-code =  &3 and ~
                            shar-buf_ord-doc.obj-type = &1&2&1 and ~
                            shar-buf_ord-doc.doc-type = &1&4&1 ~
                            ' , ~{&double-quote~} , store-type , store-code , g#type ) "
        &use-ind    = " "
        &by         = " " }
  end.

  when "objtypestatus":U then do:
      if p-open-query then frame {&frame-name}:title = "Объект : "   + store-type    + " " + string(store-code)
                                + "  Тип : "    + {&g-type-tit}
                                + "  Статус : " + g#stat.

      Enable
            /*b-payment when NOT g#db-remote*/
            b-sost WITH FRAME {&frame-name}.
      { gbl/fltopend.i
        &where-cond = " shar-buf_ord-doc.obj-code = store-code and shar-buf_ord-doc.obj-type = store-type and shar-buf_ord-doc.doc-type = g#type and shar-buf_ord-doc.status_  = g#stat "
        &dyn_where-cond = " substitute(' ~
                            shar-buf_ord-doc.obj-code =  &3 and ~
                            shar-buf_ord-doc.obj-type = &1&2&1 and ~
                            shar-buf_ord-doc.doc-type = &1&4&1 and ~
                            shar-buf_ord-doc.status_  = &1&5&1 ~
                            ' , ~{&double-quote~} , store-type , store-code , g#type , g#stat) "

        &use-ind    = "  "
        &by         = " " }
  end.

  when "constype":U then do:
      if p-open-query then frame {&frame-name}:title = "Фирма : " + g#host-name  + "  Тип : " + {&g-type-tit} +  " № СЗФП: " +  sch-cons.cons-code.
      Enable  /*b-payment when NOT g#db-remote*/
             b-sost WITH FRAME {&frame-name}.
      {&ch-b-sost}
      { gbl/fltopend.i
        &where-cond = " shar-buf_ord-doc.host-code = g#host-code and shar-buf_ord-doc.cons-code = sch-cons.cons-code and shar-buf_ord-doc.doc-type = g#type "
        &dyn_where-cond = " substitute(' ~
                            shar-buf_ord-doc.host-code =  &2 and ~
                            shar-buf_ord-doc.cons-code = &1&3&1 and ~
                            shar-buf_ord-doc.doc-type = &1&4&1  ~
                            ' , ~{&double-quote~} , g#host-code , sch-cons.cons-code , g#type ) "

        &use-ind    = "use-index ByType "
        &by         = " " }
  end.
  when "contract":U then do:
      if p-open-query then frame {&frame-name}:title = "По договору : " + sch-contract.contract-prn-code + "/" + string( sch-contract.contract-code)  .
      disable b-add b-chg b-del b-close   b-close b-copy b-payment b-sost with frame {&frame-name} .
       &if "{1}" = "true" &then
       disable b-add-2
            b-chg-2
            b-del-2
            b-close-2
            with frame {&frame-name} .
        &endif
      { gbl/fltopend.i
        &where-cond     = " shar-buf_ord-doc.contract-code = sch-contract.contract-code and shar-buf_ord-doc.host-code = g#host-code "
        &dyn_where-cond = " substitute(' ~
                            shar-buf_ord-doc.host-code =  &2 and ~
                            shar-buf_ord-doc.contract-code = &3 ~
                            ' , ~{&double-quote~} , g#host-code , sch-contract.contract-code ) "

        &use-ind    = "use-index by_contract "
        &by         = " " }
  end.
end case.

/*if v-cntxt-db-num <> 0  then  do:
  disable  b-sost  with frame {&frame-name} .
end.
*/

if not p-open-query then do:
   reposition br-docs to recid doc-rec no-error.
   if error-status :error then message "Документ не найден." view-as alert-box information .
   apply "value-changed" to br-docs in frame {&frame-name} .
end.

apply "entry" to br-docs in frame {&frame-name}.

&if "{1}" = "true" &then
    {&OPEN-QUERY-BR-rcv}
&endif

END PROCEDURE.


PROCEDURE local-mark:
  if not available shar-buf_ord-doc then do:
    message "Неправильный выбор строки.".
    return error.
  end.

  { gbl/markstrn.i shar-buf_ord-doc del-list }
  if lookup(string( recid(shar-buf_ord-doc) ), del-list ) > 0
      then disp "*"  @ mark with browse  {&browse-name}.
      else disp "" @ mark with browse  {&browse-name}.

END PROCEDURE.


procedure set-reject :
define buffer t-ord-line for ub.ord-line.
{&net-proc}
 find current shar-buf_ord-doc no-lock  no-error.

  if avail shar-buf_ord-doc and shar-buf_ord-doc.status_ = {&ord-rejection} then do:
      Message "Документ уже находится в статусе " shar-buf_ord-doc.status_ view-as alert-box.
      return.
  end.
  if not( shar-buf_ord-doc.status_ = {&g___new} OR
          shar-buf_ord-doc.status_ = {&ord-accept} or
          shar-buf_ord-doc.status_ = {&ord-rcv}
          ) then do:
      Message "Документ  находится в статусе " CAPS(shar-buf_ord-doc.status_) " Отказать нельзя !" view-as alert-box.
      return.
  end.

  if shar-buf_ord-doc.status_ = {&ord-rcv} then do:
  g#log = false .
  Message "Вы собираетесь проставить статус ОТКАЗАТЬ заказу в статусе ПОСТАВКА !" skip (2)
          "Это означает, что ВЫ не сможете по нему сформировать или получить ПН !" skip(2)
           " Если поставки и накладные уже созданы, то они будут существовать самостоятельно !" skip(2)
          "Отказать заказу № " shar-buf_ord-doc.doc-code  " ?"
           view-as alert-box question
           buttons YES-NO
           title "В Н И М А Н И Е !!! "
           update g#log

           .
           if NOT g#log then return .

  end.

  Message "Отказать заказу № " shar-buf_ord-doc.doc-code  " ?" view-as alert-box
           QUESTION buttons YES-NO update g#log.
           if NOT g#log then return .

 if shar-buf_ord-doc.cons-code <> "" and shar-buf_ord-doc.cons-code <> ? then do:
 define buffer b_ord-cons for ub.ord-cons.
    find first b_ord-cons where b_ord-cons.cons-code = shar-buf_ord-doc.cons-code no-lock no-error .
    if avail b_ord-cons and b_ord-cons.status_ <> {&g___new} then do:
        Message "Нельзя отказать заказу № " shar-buf_ord-doc.doc-code  " , так как СЗФП уже находится в статусе " b_ord-cons.status_ view-as alert-box.
        return.
    end.
 end.

 define variable tt as character no-undo .
 define variable tt2 as character no-undo .

 find current shar-buf_ord-doc EXCLUSIVE-LOCK no-error.
    if available shar-buf_ord-doc then do:
      if shar-buf_ord-doc.status_ = {&ord-rcv} then do:
         shar-buf_ord-doc.PS =  substitute("ОТКАЗ со статуса ПОСТАВКА !!! &1" ,shar-buf_ord-doc.PS ) .
      end.
      assign
        tt = shar-buf_ord-doc.cons-code
        shar-buf_ord-doc.status_ = {&ord-rejection}
        shar-buf_ord-doc.fact-date = to-day
        shar-buf_ord-doc.cons-code  = shar-buf_ord-doc.cons-code + {&ord-rejection} .
        .
       if tt <> "" and tt <> ? then do:
          for each t-ord-line where t-ord-line.doc-code = shar-buf_ord-doc.doc-code :
                find first  ub.ord-gds-cons where
                  ub.ord-gds-cons.cons-code = tt                    and
                  ub.ord-gds-cons.artic =     t-ord-line.artic       and
                  ub.ord-gds-cons.prod-code = t-ord-line.prod-code   and
                  ub.ord-gds-cons.prod-type = t-ord-line.prod-type   exclusive-lock use-index pi no-error .
                  if available ub.ord-gds-cons then do:
                      ub.ord-gds-cons.sum-qnty = ub.ord-gds-cons.sum-qnty - t-ord-line.qnty.
                      if ub.ord-gds-cons.sum-qnty  = 0 then do:
                        delete ub.ord-gds-cons.
                      end.
                  end.

          end.

        end.
       find current shar-buf_ord-doc  no-lock  no-error .
       define variable v-recid as recid no-undo .
       if error-status :error then
          message 'ошибка поиска shar-buf_ord-doc'skip
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) .
        v-recid = recid (shar-buf_ord-doc) .
       {&send-to-news}
        run UI-on in this-procedure (yes, no, '':U) no-error .
        if error-status :error then
            message 'ошибка процедуры UI-on' skip
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) .
         reposition br-docs to recid v-recid no-error .
         apply "value-changed" to br-docs in frame {&frame-name} .
    end.


END PROCEDURE.


PROCEDURE mode-g#type :
define variable  m-i-of  as widget-handle.
define variable  m-i-op  as widget-handle.
define variable  m-i-fp  as widget-handle.
CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
if  g#type <> {&o-f}
and g#type <> {&o-p}
and g#type <> {&f-p}
then do:
  disable b-rep with frame {&frame-name} .
end.
if g#type = {&o-f} then  do:
frame {&frame-name}:title = "ЗАЯВКИ   " + frame {&frame-name}:title .
    create menu-item m-i-of IN WIDGET-POOL "My-pool"
      assign parent = menu m-rep:handle
      label = 'Отчет об исполнении заявок'
      .
      ON CHOOSE OF m-i-of PERSISTENT
       run run-rep (1) .
end.

if g#type = {&o-p} then  do:
frame {&frame-name}:title = "ЗАКАЗЫ   " + frame {&frame-name}:title .
    create menu-item m-i-op IN WIDGET-POOL "My-pool"
      assign parent = menu m-rep:handle
            label = 'Отчет об исполнении заказов ОП'
      .
      ON CHOOSE OF m-i-op PERSISTENT run run-rep (2) .

      g#log =  {&browse-name}:MOVE-COLUMN(10, 14) IN FRAME {&frame-name}  no-error .
      shar-buf_ord-doc.cons-code:label in browse  {&browse-name} = "Ссылка".
end.

if g#type = {&f-p} then  do:
frame {&frame-name}:title = "ЗАКАЗЫ   " + frame {&frame-name}:title .
    create menu-item m-i-fp IN WIDGET-POOL "My-pool"
      assign parent = menu m-rep:handle
            label = 'Отчет об исполнении заказов ФП'
      .
      ON CHOOSE OF m-i-fp PERSISTENT run run-rep (3) .
end.
end procedure.


procedure run-rep :
define input parameter j as integer no-undo .
if j = 1 then do:
   run cus/g-isp-zy.p
     (input parparentproc
     ) .
end.
if j = 2 then do:
   run cus/g-isp-zk.p
     (input parparentproc
     ) .
end.
if j = 3 then do:
   run cus/g-isp-zf.p
     (input parparentproc
     ) .
end.
end procedure.

procedure proc-b-chg:
 {&net-proc}
 /*
в 15 не понятно нужно ли
define variable par-ord-ofof   as integer   no-undo .
define variable type-par     as character no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .

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
  ,output par-ord-ofof
  ,output type-par
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
*/
  if (( shar-buf_ord-doc.ord-int1 = int({&edoc-stk})
     or shar-buf_ord-doc.ord-int1 = int({&edoc-stk-ok}) )
    and shar-buf_ord-doc.whole-send-news = integer({&doc-dm-edoc-nn}))
  or (( shar-buf_ord-doc.ord-int1 = int({&edi-orders})
     or shar-buf_ord-doc.ord-int1 = int({&edi-orders-sts}) )
    and shar-buf_ord-doc.whole-send-news = integer({&doc-dm-edi}))
  then do:
    message
    "Документ "  shar-buf_ord-doc.doc-code  " нельзя корректировать, по системе EDOC\EDI заказ направлен поставщику"  view-as  alert-box .
        return .
  end.

  if v-cntxt-db-num = 0 then do: /* в ГБД можно корректировать согласование */
    if not (shar-buf_ord-doc.status_  = {&g___new} or
            shar-buf_ord-doc.status_  = {&ord-accept})
        or (shar-buf_ord-doc.status_  = {&g___new} and not v-obj-active = "yes")
    then do:
        message "Документ "  shar-buf_ord-doc.doc-code  " нельзя корректировать ,  статус " caps(shar-buf_ord-doc.status_) if v-not-activ then "на неактивном складе" else ""  view-as  alert-box .
        return .
    end.
  end.
  else do:
    if shar-buf_ord-doc.status_  <> {&g___new} then do:
        message "Документ "  shar-buf_ord-doc.doc-code  " нельзя корректировать ,  статус " caps(shar-buf_ord-doc.status_) view-as  alert-box .
        return .
    end.
  end.


 if shar-buf_ord-doc.doc-type  =  {&f-p} and v-not-activ then do :
    message "Заказ "  shar-buf_ord-doc.doc-code  " нельзя корректировать ,  статус " shar-buf_ord-doc.status_ " на неактивном складе "
    view-as alert-box information.
    return .
  end.

define variable v-ri as recid no-undo .

v-ri = recid (shar-buf_ord-doc) .
run cus/ord-zakz.p
  (  input parParentProc ,
     input {&update} ,
     input shar-buf_ord-doc.doc-type ,
     output doc-rec ,
     input-output  br-handle ,
     input-output  bf-handle ,
     input-output  next-prev
    ) .
run UI-on in this-procedure (yes, no, '':U).
reposition br-docs to recid v-ri no-error.
apply "value-changed" to br-docs in frame {&frame-name} .
end procedure.

&if "{1}" = "true" &then
PROCEDURE make-fp-rcv :
/* -----------------------------------------------------------
  Purpose: генерация поставок ФП  внешних по заказу
-------------------------------------------------------------*/
define output param r-rec as recid no-undo.
define variable l-recid as recid no-undo.

define variable ks          as  integer no-undo .
define variable loc-ord-num as  character no-undo .
define variable ii          as  integer no-undo .
define buffer   b-goods     for ub.goods .
define buffer   bfp-ord-doc for ub.ord-doc .
define buffer   buf2-ord-line-rcv for ub.ord-line-rcv.
define variable last-all-rcv as decimal no-undo .
define variable glog as logical no-undo .

ks = 0.
define variable v-i-doc as character no-undo .
{&net-proc}
   find current shar-buf_ord-doc  no-lock no-error .
      if not available  shar-buf_ord-doc then do:
        message "Не выбран Заказ ФП !!! " .
        return.
      end.

  find first bfp-ord-doc where bfp-ord-doc.doc-code = shar-buf_ord-doc.doc-code no-lock no-error.
            if error-status :error  then return.

   if bfp-ord-doc.status_ <> {&ord-rcv}
     then do:
        message "Нельзя делать Поставку на  Заказ в статусе " caps(bfp-ord-doc.status_) " !"
                 view-as alert-box information .
        return.
   end.
   if (( bfp-ord-doc.ord-int1 = int({&edoc-acc})
      or bfp-ord-doc.ord-int1 = int({&edoc-acc-ok}))
     and is-edoc-nn
     and bfp-ord-doc.whole-send-news = integer({&doc-dm-edoc-nn}) )   /*TODO а если вручную? */
  or  (
  is-edi
     and bfp-ord-doc.whole-send-news = integer({&doc-dm-edi}) )
        and bfp-ord-doc.doc-type = {&O-P}
     then do:
    if is-edi
    and bfp-ord-doc.whole-send-news = integer({&doc-dm-edi}) then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_ord-rcv_add-def-bypass-EDI':U
      {&cntxt-object}
      g#host-code
      store-type
      store-code
      0
      0
      0
      true
      g-log
    }
      if g-log = false then do:
        return.
      end.
      else do:
        glog = no.
        message
        "Вы уверены, что хотите сделать вручную поставку на Заказ, маршрутизируемый по EDI?" skip

        view-as alert-box question buttons yes-no update glog .
        if not glog then return.
      end.
    end. /*if is-edi*/
    if is-edoc-nn
    and bfp-ord-doc.whole-send-news = integer({&doc-dm-edoc-nn}) then do:
     message
      "Нельзя делать Поставку на Заказ при работе в EDOC ! Она придет в электронном виде от поставщика."
                 view-as alert-box information .
        return.
   end.
   end. /*if (( bfp-ord-doc.ord-int1 = int({&edoc-acc})*/

   if ( trim(bfp-ord-doc.cons-code) = ""  or  bfp-ord-doc.cons-code = ? ) and bfp-ord-doc.doc-type = {&O-P}  and v-edoc-ora then do:
     message
     "Нельзя делать Поставку на Заказ . Заказ отправлен во внешнюю систему ! Ждем подтверждения от внешней системы."
                 view-as alert-box information .
        return.
   end.

   define variable v-is-limit as logical   no-undo .
   run ver-qnty-rcv-from-ord (input bfp-ord-doc.doc-code , output v-is-limit ) .
   if v-is-limit then do:
        message "Нельзя делать Поставку на Заказ. Система настроена на работу 1:1."
                 view-as alert-box information .
        return.
   end.


{ cus/ord-code.i
    'main'
    v-cntxt-db-num
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-i-doc
    loc-ord-num
    }

/* Шапка поставки */
create ub.ord-doc-rcv.
buffer-copy bfp-ord-doc
except whole-send-news /*дорогу не наследуем*/
to ub.ord-doc-rcv
   assign
      ub.ord-doc-rcv.rcv-code  = loc-ord-num
      ub.ord-doc-rcv.doc-type  = "out":u
      ub.ord-doc-rcv.doc-date  = to-day
      ub.ord-doc-rcv.status_   = {&g___new}
      ub.ord-doc-rcv.sub-par   = trim(entry(1, bfp-ord-doc.cli-out-doc, {&delim-par})) + {&delim-par} +
                              trim(bfp-ord-doc.vat-type) + {&delim-par}
   .
v-doc-mode  = {&add-def}.
x-make-avto = 2 .
define variable loc-make-avto as logical no-undo .
        run cus/or-obj.w
        ( input  parParentProc
        , input  ub.ord-doc-rcv.host-code
        , input  recid(ub.ord-doc-rcv)
        , input  1
        , input  {&update}
        , input  {&update}
        , input-output  v-doc-mode  ) .
        case x-make-avto :
          when 1 then loc-make-avto = true  .
          when 4 then loc-make-avto = true  .
          when 2 then loc-make-avto = false  .
          when 3 then loc-make-avto = ? .
        end case.

  if v-doc-mode = "cancel":U then do :
      find first ub.ord-doc-rcv where ub.ord-doc-rcv.rcv-code  = loc-ord-num  exclusive-lock  no-error .
      delete ub.ord-doc-rcv .
      r-rec = ? .
      return .
  end .

 r-rec = recid ( ub.ord-doc-rcv ) .

v-doc-mode  = {&add-def} .


if loc-make-avto <> ? then do:
   for each ub.ord-line where ub.ord-line.doc-code = bfp-ord-doc.doc-code  no-lock :
        ks = ks + 1 .
        if not can-find  (first ub.ord-line-rcv where
          ub.ord-line-rcv.doc-code  = ub.ord-doc-rcv.doc-code and
          ub.ord-line-rcv.rcv-code  = ub.ord-doc-rcv.rcv-code and
          ub.ord-line-rcv.artic     = ub.ord-line.artic and
          ub.ord-line-rcv.prod-code = ub.ord-line.prod-code and
          ub.ord-line-rcv.prod-type = ub.ord-line.prod-type no-lock ) then do:
          last-all-rcv = 0 .

          for each buf2-ord-line-rcv where
                  buf2-ord-line-rcv.doc-code  = ub.ord-doc-rcv.doc-code and
                  buf2-ord-line-rcv.artic     = ub.ord-line.artic and
                  buf2-ord-line-rcv.prod-code = ub.ord-line.prod-code and
                  buf2-ord-line-rcv.prod-type = ub.ord-line.prod-type no-lock
                  :
                  last-all-rcv =  last-all-rcv + buf2-ord-line-rcv.qnty .
          end.

         create ub.ord-line-rcv.
         buffer-copy ub.ord-line to ub.ord-line-rcv
         assign
           ub.ord-line-rcv.rcv-code  = ub.ord-doc-rcv.rcv-code
           ub.ord-line-rcv.line-num  = ks
           ub.ord-line-rcv.qnty      = if (ub.ord-line.qnty - last-all-rcv) < 0 then 0 else  (ub.ord-line.qnty - last-all-rcv)
           ub.ord-line-rcv.cli-qnty  = ub.ord-line-rcv.qnty / ub.ord-line-rcv.cli-base-rate
         .

         l-recid = recid(ub.ord-line-rcv) .
         case loc-make-avto :
              when false  then do:
                    v-doc-mode  = {&add-def}.
                    run cus/or-obj.w
                    ( input  parParentProc
                    , input  bfp-ord-doc.host-code
                    , input  recid(ub.ord-line-rcv)
                    , input  2
                    , input  {&update}
                    , input "ЦИКЛ":U
                    , input-output  v-doc-mode  ) .

                    if v-doc-mode =  "stopcycle":U   then do:
                          find first ub.ord-line-rcv where
                              recid(ub.ord-line-rcv) = l-recid exclusive-lock  no-error .
                          delete ub.ord-line-rcv.
                          ks = ks - 1 .
                          leave .
                      end.
                    if v-doc-mode =  "cancel":U   then do:
                          find first ub.ord-line-rcv where
                              recid(ub.ord-line-rcv) = l-recid exclusive-lock  no-error .
                          delete ub.ord-line-rcv.
                          ks = ks - 1 .
                      end.
                  l-recid = recid(ub.ord-line-rcv).
              end.
              when true then do:
                  l-recid = recid(ub.ord-line-rcv).
              end.
           end case.
         end.
   end.
end.

if x-make-avto = 3 then do:
   ks = 1.
   run cus/scan-r.p (parparentproc,ub.ord-doc-rcv.rcv-code,ub.ord-doc-rcv.doc-code) .
end.

 if ks > 0 then do:
    r-rec = recid(ord-doc-rcv).
    define variable g-log as logical   no-undo .

    if x-make-avto = 4 then do:
/* Закрытие поставки на статус ПОСТАВКА и создание накладной НАКЛ- */
   find first ord-doc-rcv exclusive-lock where recid(ord-doc-rcv) =  r-rec .

    run cus/rcv-clos.p
    (
        input parparentproc ,
        input ord-doc-rcv.rcv-code ,
        input yes ,
        input store-type ,
        input store-code ,
        input false
        ) no-error .
    if error-status :error then do:
          message  return-value  view-as alert-box error .
          release ord-doc-rcv .
          find first ord-doc-rcv no-lock where recid(ord-doc-rcv) = r-rec no-error .
          return .
    end.
    {&OPEN-QUERY-BR-rcv}
    reposition BR-rcv to recid r-rec no-error  .
    g-log =  br-docs:refresh()  in frame {&frame-name} .
    release ord-doc-rcv .
    find first ord-doc-rcv no-lock where recid(ord-doc-rcv) = r-rec no-error .
    /* Создание накладной */
       run cus/ord-trn.p ( parParentProc ,  recid(ord-doc-rcv), no) no-error .
       if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1) skip
         return-value skip
         "Ошибка при создании накладной"
         view-as alert-box error
       .
       end.
    end.

  message "Сделана поставка № " loc-ord-num .
 end.
 else do:
   find first ord-doc-rcv where ord-doc-rcv.rcv-code  = loc-ord-num  exclusive-lock  .
   delete ord-doc-rcv .
   r-rec = ?.
 end.
END PROCEDURE.

procedure proc-close-2:
  define variable g-log as logical   no-undo .
  define variable ll-rec as recid no-undo .
  find current ub.ord-doc-rcv no-lock no-error.
  if not available ub.ord-doc-rcv then return .
  ll-rec = recid(ub.ord-doc-rcv) .
    run cus/rcv-clos.p
    (
        input parparentproc ,
        input ub.ord-doc-rcv.rcv-code ,
        input yes ,
        input store-type ,
        input store-code ,
        input yes
        ) no-error .
    if error-status :error then do:
          message  return-value  view-as alert-box error .
          release ub.ord-doc-rcv .
          find first ub.ord-doc-rcv no-lock where recid(ub.ord-doc-rcv) = ll-rec no-error .
          return .
    end.
    {&OPEN-QUERY-BR-rcv}
    reposition BR-rcv to recid ll-rec no-error  .
    g-log =  br-docs:refresh() in frame {&frame-name} .
    release ub.ord-doc-rcv .
    find first ub.ord-doc-rcv no-lock where recid(ub.ord-doc-rcv) = ll-rec no-error .
END procedure.


procedure proc-b-del-2 :
define variable t-ret as logical no-undo .
{&net-proc}
  t-ret =  session:SET-WAIT-STATE("GENERAL") .
find current ub.ord-doc-rcv no-lock no-error.
if available ub.ord-doc-rcv then do:
  find current ub.ord-doc-rcv exclusive-lock no-error.
  if available ub.ord-doc-rcv then do:
    if ub.ord-doc-rcv.status_ <> {&g___new} then do :
    message "Статус" ub.ord-doc-rcv.status_ "удалять нельзя! " view-as alert-box error .
    return.
    end.
    message "Удалить поставку №"  ub.ord-doc-rcv.rcv-code "?" view-as alert-box
          question buttons yes-no title "Вопрос" update g#log.
      if g#log then do:
        delete  ub.ord-doc-rcv .
        {&OPEN-QUERY-BR-rcv }
      end.
    end.
end.
  t-ret =  session:SET-WAIT-STATE("") .
END PROCEDURE.
&endif

PROCEDURE proc-b-add :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 define variable v-par-prt as logical no-undo .
 define buffer buff_ord-doc for ub.ord-doc  .
 if g#type = {&o-p}  then do:
    if v-cntxt-db-num <> v-cntxt-db-num-obj then do:
       message  substitute("Заказ &1 можно создать только в  БД №  &2" ,  g#type,v-cntxt-db-num-obj )
                view-as alert-box information .
       return .
    end.
 end.
  run cus/ord-zakz.p
    (input  parParentProc,
     input  {&add-def} ,
     input  g#type,
     output doc-rec ,
     input-output  br-handle ,
     input-output  bf-handle ,
     input-output  next-prev
      ) no-error .
     if error-status :error then
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "Ошибка при создании заказа"
       view-as alert-box error
     .

  find first buff_ord-doc no-lock where recid(buff_ord-doc) =  doc-rec no-error .
  if  available buff_ord-doc then do:
      run UI-on in this-procedure (yes, no, '':U).
      reposition br-docs to recid doc-rec no-error.
      apply "value-changed" to br-docs in frame {&frame-name} .
  end.

END PROCEDURE.



procedure pp-1 :
 do
 on error undo, return error return-value
 :
  {&net-proc-lkp}
  run cus/ord-zakz.p
 (input parParentProc,
  input "copy":u ,
  input  shar-buf_ord-doc.doc-type ,
  output doc-rec ,
  input-output  br-handle ,
  input-output  bf-handle ,
  input-output  next-prev
  ) .
  run UI-on in this-procedure (yes, no, '':U).
  reposition br-docs to recid doc-rec no-error.
  apply "value-changed" to br-docs in frame {&frame-name} .
 end. /* do */
end procedure. /* pp-1 */



procedure pp-2 :
 do
 on error undo, return error return-value
 :
define variable del-rec as recid no-undo.    /* recid for reposition */
define variable unrv-qnty as dec no-undo.    /* количество из ub.gds-dtl */
    {&net-proc}
    find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec no-lock.
    if shar-buf_ord-doc.status_ <> {&g___new} or (shar-buf_ord-doc.status_ = {&g___new} and not v-obj-active = "yes") then do:
      message "Документ в статусе" shar-buf_ord-doc.status_ "удалять нельзя! " view-as alert-box error .
      return no-apply.
    end.

    if (( shar-buf_ord-doc.ord-int1 = int({&edoc-stk})
       or shar-buf_ord-doc.ord-int1 = int({&edoc-stk-ok}) )
      and is-edoc-nn
      and shar-buf_ord-doc.whole-send-news = integer({&doc-dm-edoc-nn}) )
    or (( shar-buf_ord-doc.ord-int1 = int({&edi-orders})
       or shar-buf_ord-doc.ord-int1 = int({&edi-orders-sts}) )
      and is-edi
      and shar-buf_ord-doc.whole-send-news = integer({&doc-dm-edi}) )
      then do:
      message
      "Документ "  shar-buf_ord-doc.doc-code  " нельзя удалить ,  статус EDOC\EDI " caps({&edoc-stk-full}) "(Отправлен поставщику)"  view-as  alert-box .
          return .
    end.
    if (( shar-buf_ord-doc.ord-int1 = int({&edoc-rpl})
       or shar-buf_ord-doc.ord-int1 = int({&edoc-rpl-ok}) )
      and is-edoc-nn
      and shar-buf_ord-doc.whole-send-news = integer({&doc-dm-edoc-nn}) )
    or (( shar-buf_ord-doc.ord-int1 = int({&edi-ordrsp})
       or shar-buf_ord-doc.ord-int1 = int({&edi-ordrsp-yes}))
      and is-edi
      and shar-buf_ord-doc.whole-send-news = integer({&doc-dm-edi}) )
      then do:
      message
      "Документ "  shar-buf_ord-doc.doc-code  " нельзя удалить ,  статус EDOC\EDI " caps({&edoc-stk-full}) "(Ожидает решения)"  view-as  alert-box .
          return .
    end.
    g#log = no.
    message "Удалить документ №" shar-buf_ord-doc.doc-code "?   Вы уверены ?"
                    view-as alert-box question buttons OK-Cancel update g#log.
    {&if-not-true}
    run waitfram-show in this-procedure ("Удаление документа № " + shar-buf_ord-doc.doc-code + ". Ждите...").
    br-handle  = br-docs:handle  in frame {&frame-name} .
    if valid-handle (br-handle) then do:
      g#log = br-handle:select-next-row().
      if not g#log then g#log = br-handle:select-prev-row().
      del-rec = recid (shar-buf_ord-doc).
    end.

    find shar-buf_ord-doc where recid (shar-buf_ord-doc) = doc-rec.
    del-doc:
    do on stop undo del-doc, return no-apply on error undo del-doc, return no-apply:
      delete shar-buf_ord-doc.
    end.
    doc-rec = del-rec.
    run waitfram-hide in this-procedure .
    run UI-on in this-procedure (yes, no, '':U).


 end. /* do */
end procedure. /* pp-2 */

PROCEDURE set-filter-name :
define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = frame {&frame-name}:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.

  end. /* do with frame */

END PROCEDURE.


procedure proc-doc-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as char no-undo.
  do
  on error undo, return error return-value
  :
display "" @ sch-date with frame {&frame-name}.
display "" @ sch-fact with frame {&frame-name}.

assign
  pardoc-code = {&double-quote} + pardoc-code + {&double-quote} .

     run Ui-on in this-procedure
          (input false      /* p-open-query */
          ,input par-next  /* p-find-next  */
          ,input substitute ( "and shar-buf_ord-doc.doc-code begins &1 "
            , pardoc-code)
          ) no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "ui-on"
      view-as alert-box error
    .
 apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
 apply "entry" to sch-code in frame {&frame-name}.

  end.

end procedure. /* proc-doc-code */

procedure proc-doc-date :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as date      no-undo .
  do
  on error undo, return error return-value
  :
define variable ppp as character no-undo .
display "" @ sch-code with frame {&frame-name}.
display "" @ sch-fact with frame {&frame-name}.

assign

  ppp =  string( day(pardoc-code)) + "/" +  string( month(pardoc-code)) + "/" +  string( year(pardoc-code)) .
     run Ui-on in this-procedure
          (input false      /* p-open-query */
          ,input par-next  /* p-find-next  */
          ,input substitute ( "and shar-buf_ord-doc.doc-date = &1 "
            , ppp)
          ) no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "ui-on"
      view-as alert-box error
    .
 apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
 apply "entry" to sch-date in frame {&frame-name}.

  end.

end procedure. /* proc-doc-date */

procedure proc-fact-date :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as date      no-undo .
  do
  on error undo, return error return-value
  :
define variable ppp as character no-undo .
display "" @ sch-code with frame {&frame-name}.
display "" @ sch-date with frame {&frame-name}.

assign

  ppp =  string( day(pardoc-code)) + "/" +  string(  month(pardoc-code)) + "/" +  string( year(pardoc-code)) .
     run Ui-on in this-procedure
          (input false      /* p-open-query */
          ,input par-next  /* p-find-next  */
          ,input substitute ( "and shar-buf_ord-doc.fact-date = &1 "
            , ppp)
          ) no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "ui-on"
      view-as alert-box error
    .
 apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
 apply "entry" to sch-fact in frame {&frame-name}.

  end.

end procedure. /* proc-fact-date */

procedure  proc-m_gen-1 :
  do
  on error undo, return error return-value
  :
    if num-entries(del-list) = 0 then do:
      message "Не выделено ни одного Заказа для генерации ФО !".
      return error .
    end.

    run str/gen-fl.w
    (
        input parparentproc,
        input g#host-code,
        input del-list,
        input "order"
        ) .
    assign del-list = "" .
    run UI-on in this-procedure (yes, no, '':U) .
  end.

end procedure. /*  proc-m_gen-1 */
procedure  proc-m_gen-1_buyer :
  do
  on error undo, return error return-value
  :
    if num-entries(del-list) = 0 then do:
      message "Не выделено ни одного Заказа для генерации ФО !".
      return error .
    end.
    run str/gen-fbuy.w
    (   input parparentproc,
        input g#host-code,
        input del-list,
        input "order"
        ) .
    assign del-list = "" .
    run UI-on in this-procedure (yes, no, '':U) .
  end.

end procedure. /*  proc-m_gen-1 */

PROCEDURE proc-m_gen-2 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc for ub.ord-doc.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.

do on error undo, return error return-value
:
if del-list = "" then do:
  if available shar-buf_ord-doc then assign del-list = string(recid(shar-buf_ord-doc)).
end.
define variable v-nn as integer   no-undo .
v-nn = num-entries (del-list).
v-i-cycle:
  do v-i = 1 to v-nn :
    assign v-doc-code = integer(entry (v-i, del-list)).
    find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code exclusive-lock.
    if bf_ord-doc.status_ <> {&fact} then do:
      message "Документ " bf_ord-doc.status_ " не в статусе " {&fact} " . Пропускаем." view-as alert-box.
      next v-i-cycle.
    end.

    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_ord-doc.doc-type <> {&P-O} then do:
        if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
          message "Главная БД для фирмы по документу с кодом " bf_ord-doc.doc-code " не является текущей БД." skip
                  "Текущая БД: " v-cntxt-db-num skip "Главная БД фирмы: " bf_sysconf.firm-db-num
          view-as alert-box error.
          next v-i-cycle.
        end.
    end.
    if bf_ord-doc.cr-fo = yes then do:
      message "По документу " bf_ord-doc.doc-code " уже создавался ФО от " bf_ord-doc.fo-date " числа." view-as alert-box.
      next v-i-cycle.
    end.
    else do:
      if bf_ord-doc.need-fo = 1 or bf_ord-doc.need-fo = 2 then assign  bf_ord-doc.need-fo = 0.
      else do:
        message "Данный документ не нуждался в генерации ФО." view-as alert-box.
        next v-i-cycle.
      end.
      reposition {&browse-name} to recid recid(bf_ord-doc) no-error.
      if not error-status:error then do:
         apply "value-changed" to br-docs in frame {&frame-name} .
         display f-fo (buffer bf_ord-doc) @ v-fo  mark  with browse {&browse-name}.
      end.
    end.
  end.
  find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code no-lock no-error .
  assign del-list = "".
end.
end procedure.


PROCEDURE proc-m_gen-3 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc for ub.ord-doc.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.
define variable v-log as logical   no-undo .

do on error undo, return error return-value
:
  if del-list = "" then do:
    if available shar-buf_ord-doc then assign del-list = string(recid(shar-buf_ord-doc)).
  end.
define variable v-nn as integer   no-undo .
v-nn = num-entries (del-list).
v-i-cycle:
  do v-i = 1 to v-nn :
    assign v-doc-code = integer(entry (v-i, del-list)).
    find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code exclusive-lock.
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if lookup(bf_ord-doc.status_, {&fact} + "," + {&ord-rcv}) = 0 then do:
      message "Документ " bf_ord-doc.status_ " не в статусе " {&fact} " . Пропускаем." view-as alert-box.
      next v-i-cycle.
    end.
    if bf_ord-doc.doc-type <> {&P-O} then do:
        if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
          message "Главная БД для фирмы по документу с кодом " bf_ord-doc.doc-code " не является текущей БД." skip
                  "Текущая БД: " v-cntxt-db-num skip   "Главная БД фирмы: " bf_sysconf.firm-db-num
          view-as alert-box error.
          next v-i-cycle.
        end.
    end.
    if bf_ord-doc.cr-fo = yes then do:
      assign
        v-log = no.
        message "По документу " bf_ord-doc.doc-code " был создан ФО от " bf_ord-doc.fo-date " ." skip
                "Вы действительно хотите снять признак, чтобы по этому документу был ФО?"
        view-as alert-box question buttons yes-no update v-log.
       if v-log <> yes then  next v-i-cycle.
       assign
         bf_ord-doc.cr-fo   = no
         bf_ord-doc.fo-date = 01/01/1990
       .
       reposition {&browse-name} to recid recid(bf_ord-doc) no-error.
      if not error-status:error then do:
        apply "value-changed" to br-docs in frame {&frame-name} .
        display f-fo (buffer bf_ord-doc) @ v-fo mark with browse {&browse-name}.
      end.
    end.
    else do:
      message "По документу " bf_ord-doc.doc-code " не было генерации."
      view-as alert-box.
   end.
 end.
 assign del-list = "".
end.
end procedure.

PROCEDURE proc-m_gen-4 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc for ub.ord-doc.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.
define variable v-need-fo as logical no-undo.
define buffer bf_contract for ub.contract.

do on error undo, return error return-value
:
  if del-list = "" then do:
    if available shar-buf_ord-doc then assign del-list = string(recid(shar-buf_ord-doc)).
  end.

define variable v-nn as integer   no-undo .
v-nn = num-entries (del-list) .

v-i-cycle:
  do v-i = 1 to v-nn:
    assign v-doc-code = integer(entry (v-i, del-list)) .
    find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code exclusive-lock.
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_ord-doc.status_ <> {&fact} then do:
      message "Документ " bf_ord-doc.doc-code " не в статусе " {&fact} " . Пропускаем."  view-as alert-box.
      next.
    end.
    if bf_ord-doc.doc-type <> {&P-O} then do:
        if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
          message "Главная БД для фирмы по документу с кодом " bf_ord-doc.doc-code " не является текущей БД." skip
                  "Текущая БД: " v-cntxt-db-num skip "Главная БД фирмы: " bf_sysconf.firm-db-num
          view-as alert-box error.
          return error.
        end.
    end.
    if bf_ord-doc.need-FO = 2 then do:
      if bf_ord-doc.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = bf_ord-doc.host-code   and
                                     bf_contract.contract-code = bf_ord-doc.contract-code no-lock no-error.
        if available bf_contract then do:
          if /* bf_contract.usl-opl = по заказу  или по заказу с отсрочкой  */ true  then do:
            assign bf_ord-doc.need-FO = 1  .
            reposition {&browse-name} to recid recid(bf_ord-doc) no-error.
            if not error-status:error then do:
              apply "value-changed" to br-docs in frame {&frame-name} .
              display f-FO (buffer bf_ord-doc) @ v-FO  mark with browse {&browse-name}.
            end.
          end.
          else message "По документу " bf_ord-doc.doc-code " нет договоров для генерации ФО."  view-as alert-box.
        end.
      end.
    end.
    else do:
      message "Документ " bf_ord-doc.doc-code "не имеет признака 'не опред' генерация ФО."
      view-as alert-box.
      next v-i-cycle.
    end.
  end.
  assign del-list = "" .
find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code no-lock no-error .
end.
end procedure.

procedure proc-m_lkp-fo :
  do
  on error undo, return error return-value
  :
  if available shar-buf_ord-doc then do:
    run str/fi-trns.w
    (   input parparentproc,
        input shar-buf_ord-doc.host-code,
        input ?              ,
        input shar-buf_ord-doc.doc-code ,
        input "order":U
        ) .
    end.

  end.

end procedure. /* proc-m_lkp-fo */


PROCEDURE proc-m_gen-3-2 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc for ub.ord-doc.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.
define variable v-log as logical   no-undo .

do on error undo, return error return-value
:
  if del-list = "" then do:
    if available shar-buf_ord-doc then assign del-list = string(recid(shar-buf_ord-doc)).
  end.
define variable v-nn as integer   no-undo .
v-nn = num-entries (del-list).
v-i-cycle:
  do v-i = 1 to v-nn :
    assign v-doc-code = integer(entry (v-i, del-list)).
    find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code exclusive-lock.
    if bf_ord-doc.doc-type <> {&p-o} then next.
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.

    if bf_ord-doc.cr-fo2 = yes then do:
      assign
        v-log = no.
        message "По документу " bf_ord-doc.doc-code " был создан ФО от " bf_ord-doc.fo-date2 " ." skip
                "Вы действительно хотите снять признак, чтобы по этому документу был ФО?"
        view-as alert-box question buttons yes-no update v-log.
       if v-log <> yes then  next v-i-cycle.
       assign
         bf_ord-doc.cr-fo2   = no
         bf_ord-doc.fo-date2 = 01/01/1990
       .

      reposition {&browse-name} to recid recid (bf_ord-doc) no-error.

      if not error-status:error then do:
        apply "value-changed" to br-docs in frame {&frame-name} .
        display f-fo (buffer bf_ord-doc) @ v-fo mark  with browse {&browse-name}.
      end.
    end.
    else do:
      message "По документу " bf_ord-doc.doc-code " не было генерации."
      view-as alert-box.
   end.
 end.
 assign del-list = "".
find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code no-lock  no-error .
end.
end procedure.


PROCEDURE proc-m_gen-2-2 :
define buffer bf_sysconf   for ub.sysconf.
define buffer bf_ord-doc   for ub.ord-doc.
define variable v-i        as integer no-undo.
define variable v-doc-code as integer no-undo.

do on error undo, return error return-value
:
if del-list = "" then do:
  if available shar-buf_ord-doc then assign del-list = string(recid(shar-buf_ord-doc)).
end.

define variable v-nn as integer   no-undo .
v-nn = num-entries (del-list).
v-i-cycle:
  do v-i = 1 to v-nn :
    assign v-doc-code = integer(entry (v-i, del-list)).
    find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code exclusive-lock.
    if bf_ord-doc.doc-type <> {&p-o} then next.
    if bf_ord-doc.status_ <> {&fact} then do:
      message "Документ " bf_ord-doc.status_ " не в статусе " {&fact} " . Пропускаем." view-as alert-box.
      next v-i-cycle.
    end.

    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_ord-doc.cr-fo2 = yes then do:
      message "По документу " bf_ord-doc.doc-code " уже создавался ФО от " bf_ord-doc.fo-date2 " числа." view-as alert-box.
      next v-i-cycle.
    end.
    else do:
      if bf_ord-doc.need-fo2 = 1 or bf_ord-doc.need-fo2 = 2 then assign  bf_ord-doc.need-fo2 = 0.
      else do:
        message "Данный документ не нуждался в генерации ФО." view-as alert-box.
        next v-i-cycle.
      end.
      reposition {&browse-name} to recid recid(bf_ord-doc) no-error.
      if not error-status:error then do:
        apply "value-changed" to br-docs in frame {&frame-name} .
        display f-fo (buffer bf_ord-doc) @ v-fo with browse {&browse-name}.
        display  mark with browse {&browse-name}.
      end.
    end.
  end.
  assign del-list = "".
find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code no-lock no-error .
end.
end procedure.

PROCEDURE proc-m_gen-4-2 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc for ub.ord-doc.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.
define variable v-need-fo as logical no-undo.
define buffer bf_contract for ub.contract.

do on error undo, return error return-value
:
if del-list = "" then do:
  if available shar-buf_ord-doc then assign del-list = string(recid(shar-buf_ord-doc)).
end.

define variable v-nn as integer   no-undo .
v-nn = num-entries (del-list) .
v-i-cycle:
  do v-i = 1 to v-nn:
    assign v-doc-code = integer(entry (v-i, del-list)) .
    find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code exclusive-lock.
    if bf_ord-doc.doc-type <> {&p-o} then next.
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_ord-doc.status_ <> {&fact} then do:
      message "Документ " bf_ord-doc.doc-code " не в статусе " {&fact} " . Пропускаем."  view-as alert-box.
      next.
    end.
    if bf_ord-doc.need-FO2 = 2 then do:
      if bf_ord-doc.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = bf_ord-doc.host-code   and
                                     bf_contract.contract-code = bf_ord-doc.contract-code no-lock no-error.
        if available bf_contract then do:
          if /* bf_contract.usl-opl = по заказу  или по заказу с отсрочкой  */ true  then do:
            assign bf_ord-doc.need-FO2 = 1  .
            reposition {&browse-name} to recid recid(bf_ord-doc) no-error.
            if not error-status:error then do:
               apply "value-changed" to br-docs in frame {&frame-name} .
               display f-FO (buffer bf_ord-doc) @ v-FO   mark  with browse {&browse-name}.
               end.
          end.
          else message "По документу " bf_ord-doc.doc-code " нет договоров для генерации ФО."  view-as alert-box.
        end.
      end.
    end.
    else do:
      message "Документ " bf_ord-doc.doc-code "не имеет признака 'не опред' генерация ФО."
      view-as alert-box.
      next v-i-cycle.
    end.
  end.
  assign del-list = "" .
find first bf_ord-doc where recid(bf_ord-doc) = v-doc-code no-lock no-error .
end.
end procedure.


procedure clip-ord :
/* Объединение */
define output parameter p-recid as recid no-undo .

define buffer buf_ord-doc  for ub.ord-doc  .
define buffer new_ord-doc  for ub.ord-doc  .
define buffer new_ord-line for ub.ord-line  .
define buffer buf_ord-line for ub.ord-line  .
define buffer bb2_ord-line for ub.ord-line.
define buffer bb_ord-line  for ub.ord-line.
define buffer bb_goods for ub.goods  .

define variable loc-ord-num as character no-undo .
  do
  on error undo, return error return-value
  :
for each tempclip-orddoc :
  delete tempclip-orddoc.
end.

find current shar-buf_ord-doc no-lock .
p-recid = recid(shar-buf_ord-doc) .

 if num-entries (del-list) < 2 then do:
    message "Для объединения в один заказ нужно выделить не менее двух заказов!"  view-as alert-box information .
    return .
 end.

define variable v-nn   as integer   no-undo .
define variable v-i    as integer   no-undo .
define variable v-str  as character no-undo .
define variable v-diff as character no-undo .
define variable v-diff-contract as character no-undo init "" .

v-nn = num-entries (del-list).

find first buf_ord-doc exclusive-lock where
      recid(buf_ord-doc) = integer ( entry (1, del-list)) no-error .
if error-status :error then return .
if buf_ord-doc.ord-int1 <> 0 then do:
   message "Нельзя объединять заказы , которые уже начали обработку по EDOC\EDI !"
   view-as alert-box information .
   return .
end.

 create tempclip-orddoc.
 buffer-copy buf_ord-doc to tempclip-orddoc .

 find first tempclip-orddoc.

define variable v-longchar as longchar no-undo .
define variable v-err-clip as logical   no-undo .
v-err-clip = false .

  do v-i = 1 to v-nn : /* по списку заказов */
    find first  buf_ord-doc exclusive-lock where
         recid (buf_ord-doc) = integer ( entry (v-i, del-list))  .
         if not available buf_ord-doc then next.
    if buf_ord-doc.status_ <> {&g___new} then do:
      message "Объединять заказы  можно только в статусе НОВЫЙ !"
      view-as alert-box information .
      return .
    end.
    if buf_ord-doc.doc-type <> {&O-P} then do:
      message "Объединять  можно только заказы ОП !"
      view-as alert-box information .
      return .

    end.

    buffer-compare tempclip-orddoc EXCEPT
      agnt
      boss
      cli-qnty
      creid
      date-sale-1
      date-sale-2
      doc-code
      doc-date
      e-method
      end-date
      exch-date
      ord-method
      out-code
      qnty
      real-date-create
      real-time-create
      start-date
      sub-par
      sum-base
      sum-cli
      sum-rubl
      sys-date
      sys-time-int
      sys-time
      tot-lines
      user-db-num
      user-name
      whole-send-news
      wrkr
      fact-num
      ps
      cli-name
      exch-date
      transport-cli-code
      transport-cli-type
      transport-condition
      transport-contract
      transport-host-code
      transport-value
      transport-VAT
      pay-day
      contract-code
      order-type
      cycle-day
      cli-out-doc

    to buf_ord-doc save result in v-diff .
    .
    if entry(1, buf_ord-doc.cli-out-doc, {&delim-par}) <> entry(1, tempclip-orddoc.cli-out-doc, {&delim-par}) then do:
      v-diff = v-diff + (if v-diff = '' then '' else {&comma-char}) + "cli-out-doc".
    end.
    if v-diff <> ""
    then do:
          define variable v-str2 as character no-undo .
          define variable newstr as character no-undo .
          define variable i as integer   no-undo .
          define variable l as integer   no-undo .
          v-str2 = v-diff .
          newstr = "" .

          repeat i = 1 to num-entries (v-str2) :
            l = lookup ( entry (i,v-str2) , "{&order-field}" )  .
            newstr  = newstr + entry ( l , "{&order-field-rus}" )  + ", " .
          end.
          newstr = trim(trim(newstr),"," ).

          v-err-clip = true .
          v-longchar = v-longchar +
          substitute ( "Нельзя объединить заказ &1 c &2 , есть несовпадения (&3)&4" ,buf_ord-doc.doc-code,tempclip-orddoc.doc-code, newstr,{&new-line} ) .
    end.
    else do:
     /* Если все совпало теперь проверим договор. Если были несовпадения ставим "" */
        buffer-compare tempclip-orddoc USING
          contract-code
        to buf_ord-doc save result in v-diff-contract .
          if v-diff-contract <> "" then do:
            v-diff-contract = "".
          end.
          else do:
              v-diff-contract = string (buf_ord-doc.contract-code) .
          end.
    end.

    v-str = v-str + buf_ord-doc.doc-code + ", ".

     /*  Проверим артикул поставщика  */
          for each  bb_ord-line no-lock where
                 bb_ord-line.doc-code = tempclip-orddoc.doc-code :
           find first bb2_ord-line no-lock where
                      bb2_ord-line.doc-code = buf_ord-doc.doc-code and
                      bb2_ord-line.gds-code = bb_ord-line.gds-code and
                      bb2_ord-line.cli-art <> bb_ord-line.cli-art
                      no-error .
            if available bb2_ord-line then do:
                find first bb_goods no-lock where
                           bb_goods.gds-code = bb2_ord-line.gds-code no-error .
                v-err-clip = true .
                v-longchar = v-longchar +
                substitute ( "Нельзя объединить заказ &1 c &2 , есть несовпадения по артикулу поставщика Товар &3 &4&5 &6 &7" ,buf_ord-doc.doc-code,tempclip-orddoc.doc-code,bb_ord-line.artic,bb_ord-line.prod-type,bb_ord-line.prod-code ,bb_goods.gds-name,{&new-line}) .
            end.
           find first bb2_ord-line no-lock where
                      bb2_ord-line.doc-code = buf_ord-doc.doc-code and
                      bb2_ord-line.gds-code = bb_ord-line.gds-code and
                      bb2_ord-line.price-cli <>  bb_ord-line.price-cli
                      no-error .
            if available bb2_ord-line then do:
                find first bb_goods no-lock where
                           bb_goods.gds-code = bb2_ord-line.gds-code no-error .
                v-err-clip = true .
                v-longchar = v-longchar +
                substitute ( "Нельзя объединить заказ &1 c &2 , есть несовпадения по цене поставщика Товар &3 &4&5 &6 (&8 и &9)&7" ,buf_ord-doc.doc-code,tempclip-orddoc.doc-code,bb_ord-line.artic,bb_ord-line.prod-type,bb_ord-line.prod-code ,bb_goods.gds-name,{&new-line}, bb2_ord-line.price-cli , bb_ord-line.price-cli) .
            end.
        end.
  end.

  if v-err-clip = true   then do:
      run gbl/d-longchar.w (
              ?,
              'Editor_row=2\':u
            + 'title=Ошибки объединения заказов\':u
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
            "4"
            view-as alert-box error
          .
          assign
          v-longchar = '':U.
    return error "Заказ не может быть закрыт ! Исправьте внешние артикулы Поставщика" .
  end.

  v-str = trim(trim(v-str),"," ).
  message "Объединять заказы " v-str
          "в один ? "
          view-as alert-box question
          buttons yes-no
          update v-okk as logical
        .
  if v-okk = false then return .

define variable v-i-doc as character no-undo .
{ cus/ord-code.i
    'main'
    v-cntxt-db-num
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-i-doc
    loc-ord-num
    }

  define variable v-ln as integer   no-undo .
  v-ln = 0.
  do v-i = 1 to v-nn : /* по списку заказов */

    find first buf_ord-doc exclusive-lock where
         recid(buf_ord-doc) = integer ( entry (v-i, del-list))  no-error .
         if not available buf_ord-doc then next.
         run save-orddoc ( buffer buf_ord-doc , input loc-ord-num) .

          for each buf_ord-line exclusive-lock where
                   buf_ord-line.doc-code =  buf_ord-doc.doc-code by  buf_ord-line.line-num :
                   run save-ordline
                       ( input loc-ord-num ,
                         input buf_ord-line.doc-code,
                         input buf_ord-line.gds-code,
                         input buf_ord-line.cli-qnty,
                         input buf_ord-doc.order-type
                         ) no-error  .
                   if error-status :error then message
                     vss-workfile vss-revision vss-description skip
                     error-status :get-message(1) skip
                     return-value skip
                     "save-ordline"
                     view-as alert-box error
                   .

                  find first new_ord-line exclusive-lock where
                             new_ord-line.doc-code =  loc-ord-num and
                             new_ord-line.gds-code =  buf_ord-line.gds-code no-error .

                  if available new_ord-line then do:
                      new_ord-line.qnty     =  new_ord-line.qnty     + buf_ord-line.qnty .
                      new_ord-line.cli-qnty =  new_ord-line.cli-qnty + buf_ord-line.cli-qnty.
                      new_ord-line.sum-rubl =  new_ord-line.sum-rubl + buf_ord-line.sum-rubl.
                      new_ord-line.sum-base =  new_ord-line.sum-base + buf_ord-line.sum-base.
                      new_ord-line.sum-cli  =  new_ord-line.sum-cli  + buf_ord-line.sum-cli.
                      new_ord-line.sum-vat  =  new_ord-line.sum-vat  + buf_ord-line.sum-vat.
                  end.
                  else do:
                     v-ln = v-ln + 1.
                     assign
                      buf_ord-line.doc-code = loc-ord-num
                      buf_ord-line.line-num = v-ln
                      .
                  end.
            end.
  delete buf_ord-doc.

  end.

  create new_ord-doc.
  buffer-copy tempclip-orddoc to new_ord-doc
    assign
      new_ord-doc.doc-code     = loc-ord-num
      new_ord-doc.doc-date     = to-day
      new_ord-doc.contract-code = integer(v-diff-contract)
    .
    p-recid = recid ( new_ord-doc ) .
    del-list = "" .
end.
end procedure. /* clip-ord */


procedure save-orddoc :
define parameter buffer  buf_ord-doc for ub.ord-doc.
define input  parameter p-new-ord-num as character no-undo .

define variable v-new-code as character no-undo .

  do
  on error undo, return error return-value
  :
  if buf_ord-doc.order-type = 0 then return .
  assign
    tempclip-orddoc.order-type    = 4
    tempclip-orddoc.contract-code = 0
    tempclip-orddoc.cycle-day     = 0
  .

  v-new-code = p-new-ord-num + {&delim-par} + buf_ord-doc.doc-code .

  run orddocattr-write (
       input v-new-code
      ,input {&orddocattr-cycle-doc-code}
      ,input buf_ord-doc.doc-code) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input {&orddocattr-cycle-day}
      ,input string(buf_ord-doc.cycle-day)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .

  run orddocattr-write (
       input v-new-code
      ,input {&orddocattr-cycle-doc-date}
      ,input string(buf_ord-doc.doc-date , "99/99/9999" )) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .

  run orddocattr-write (
       input v-new-code
      ,input {&orddocattr-cycle-exch-code}
      ,input string(buf_ord-doc.exch-code)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input {&orddocattr-cycle-exch-rate}
      ,input string(buf_ord-doc.exch-rate)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input {&orddocattr-cycle-base-rate}
      ,input string(buf_ord-doc.base-rate)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input {&orddocattr-cycle-base-scale}
      ,input string(buf_ord-doc.base-scale)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input {&orddocattr-cycle-done}
      ,input "no") no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .


  run orddocattr-write (
       input  v-new-code
      ,input {&orddocattr-cycle-contract-code}
      ,input string(buf_ord-doc.contract-code)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .

  run orddocattr-write (
       input v-new-code
      ,input {&orddocattr-cycle-ship-date}
      ,input string(buf_ord-doc.ship-date, "99/99/9999" )) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .

  run orddocattr-write (
       input v-new-code
      ,input {&orddocattr-cycle-ship-time}
      ,input string(buf_ord-doc.ship-time)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .

  run orddocattr-write (
       input v-new-code
      ,input {&orddocattr-cycle-date1}
      ,input string(buf_ord-doc.date-sale-1, "99/99/9999" )) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .
  run orddocattr-write (
       input v-new-code
      ,input {&orddocattr-cycle-date2}
      ,input string(buf_ord-doc.date-sale-2, "99/99/9999")) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из orddocattr-write"
        view-as alert-box error
      .


  end.

end procedure. /* save-orddoc */


procedure save-ordline :

define input  parameter p-new-code as character no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-gds-code  as integer   no-undo .
define input  parameter p-cli-qnty as decimal   no-undo .
define input  parameter p-order-type as integer   no-undo .

  do
  on error undo, return error return-value
  :

  if p-order-type = 0 then return .

  run ordlineattr-write (
       input p-new-code + {&delim-par} + p-doc-code
      ,input p-gds-code
      ,input {&ordlineattr-cli-qnty}
      ,input string(p-cli-qnty)) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "Ошибка из ordlineattr-write"
        view-as alert-box error
      .
  end.

end procedure. /* save-ordline */


&UNDEFINE BROWSE-NAME
&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME

/* $Workfile$ e n d */