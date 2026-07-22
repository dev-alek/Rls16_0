/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура проверки корректности ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 07/06/06
Author: Svetlana Chernova
Creation date: 07/06/06


*/
{ cmp/str-glbl.i }
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable var-pr-r-b as character no-undo .
define variable v-str2 as character no-undo .
{ gbl/curr-r-b.i  var-pr-r-b }

function f-base-code return integer ( p-b-code as integer ).
  define variable main-b-code as integer   no-undo .
  define buffer buf_bar-code for ub.bar-code  .
  find first buf_bar-code no-lock where
            buf_bar-code.b-code = p-b-code no-error .
  { gbl/gdsbcode.i buf_bar-code.gds-code ? main-b-code }
  return (main-b-code).
end function.

function fnc-cost-pc return decimal (buffer local-price-list for ub.price-doc-forming-gds ).
  define variable f-cost     as decimal no-undo . /* для вывода в список учетной к новой  */
  define variable f-cost-pc  as decimal no-undo . /* для вывода в список % новой к старой цене  */
  define variable v-qnty     as decimal no-undo .
  define variable v-sum      as decimal no-undo .
  define variable fact_price as decimal no-undo .
  find first ub.goods where ub.goods.artic     = local-price-list.artic and
                            ub.goods.prod-type = local-price-list.prod-type and
                            ub.goods.prod-code = local-price-list.prod-code no-lock
                            no-error .
  assign
    v-sum  =  0
    v-qnty =  0
    .
  for each x_obj-group :
      find ub.gds-obj no-lock where
          ub.gds-obj.gds-code = ub.goods.gds-code and
          ub.gds-obj.obj-type = x_obj-group.obj-type and
          ub.gds-obj.obj-code = x_obj-group.obj-code no-error.
      if  available ub.gds-obj then
        if ub.goods.gds-type = {&gds-goods} then
          assign
            v-sum  = v-sum  + ( if var-pr-r-b = "rubl" then ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base) * ub.gds-obj.avrg-qnty
            v-qnty =  v-qnty + ub.gds-obj.avrg-qnty
            .
          else  v-sum = ?.
      else v-sum = ?.
  end.

  f-cost = v-sum / v-qnty .
  fact_price = if var-pr-r-b = "rubl" then local-price-list.price-sale-rubl else local-price-list.price-sale-base .
  f-cost-pc = ( round ( fact_price / f-cost , 2 ) -  1 ) * 100.
  return (f-cost-pc).
end function.


/* Процент Новой к Приходной  */
function fnc-pr-pc return decimal (buffer local-price-list for ub.price-doc-forming-gds ).
define variable f-pr     as decimal no-undo . /* для вывода в список учетной к новой  */
define variable f-pr-pc  as decimal no-undo. /* для вывода в список % новой к старой цене  */
define variable v-qnty as decimal   no-undo .
define variable v-sum as decimal   no-undo .
define variable fact_price as decimal   no-undo .


find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
 assign
   v-sum  =  0
   v-qnty =  0
   .
for each x_obj-group :
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = x_obj-group.obj-type and
     ub.gds-obj.obj-code = x_obj-group.obj-code  no-error .
if  available ub.gds-obj then do:
  if ub.goods.gds-type = {&gds-goods} then
    assign
      f-pr = (if var-pr-r-b = "rubl" then ub.gds-obj.last-rubl else ub.gds-obj.last-base)
      .
    else f-pr = ?.
end.
else f-pr = ?.
end.
  fact_price = if var-pr-r-b = "rubl" then local-price-list.price-sale-rubl else local-price-list.price-sale-base .
  f-pr-pc = ( round( fact_price / f-pr , 2 ) - 1 ) * 100 .
  return (f-pr-pc).
end function.

function fnc-cost return decimal (buffer local-price-list for ub.price-doc-forming-gds).
define variable f-cost   as decimal no-undo . /* для вывода в список учетной к новой  */
find first  x_obj-group.
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .

find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code  and
     ub.gds-obj.obj-type = x_obj-group.obj-type and
     ub.gds-obj.obj-code = x_obj-group.obj-code

     no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = {&gds-goods} then
    assign
      f-cost = if var-pr-r-b = "rubl" then ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base
      .
    else  f-cost = ?.
else f-cost = ?.
  return ( f-cost ).
end function.


/*  Приходная  */
function fnc-pr return decimal (buffer local-price-list for ub.price-doc-forming-gds).
define variable f-pr   as decimal no-undo . /* для вывода в список учетной к новой  */
find first x_obj-group .
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .

find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = x_obj-group.obj-type and
     ub.gds-obj.obj-code = x_obj-group.obj-code
     no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = {&gds-goods} then
    assign
      f-pr = if var-pr-r-b = "rubl" then ub.gds-obj.last-rubl  else ub.gds-obj.last-base
      .
    else  f-pr = ?.
else f-pr = ?.
   return ( f-pr ).
end function.

procedure make-fact-order-lib3 :
define input  parameter p-recid as recid no-undo .
define output parameter p-fact-order-sys-from as decimal   no-undo .
define output parameter p-fact-order-sys-to   as decimal   no-undo .

define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-list-type for ub.price-list-type  .

define variable v-shift-end-fact-order as decimal no-undo . /* номер конца смены                    */
define variable v-day-end-fact-order   as decimal no-undo . /* номер конца дня                      */
define variable v-fact-order           as decimal no-undo .

  do
  on error undo, return error return-value
  :

find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming ) = p-recid no-error .
  if error-status :error then return error error-status :get-message(1) .

find first buf_price-list-type  no-lock where
           buf_price-list-type.plt-id = buf_price-doc-forming.plt-id and
           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
  if error-status :error then return error error-status :get-message(1) .



 if buf_price-doc-forming.have-start-period = 1 then do:
    case buf_price-list-type.work-date :
      when int({&mpl-date-obj}) /* дата на обкт */ then
        do : /* Начало дня */
           run day-begin-fact-order
                ( buf_price-doc-forming.start-date ,
                 output p-fact-order-sys-from ) no-error .
                 if error-status :error then
                 return error substitute ( "Ошибка из day-begin-fact-order &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
      when int({&mpl-date-shift})  /* сменная дата */ then
        do :
          run factord (
             input   buf_price-doc-forming.start-shift-date
            ,input   buf_price-doc-forming.sys-time
            ,input   1                                      /* фактический номер закрытия документа */
            ,input   buf_price-doc-forming.start-shift-date /* дата начала смены для документа      */
            ,input   buf_price-doc-forming.start-shift-num  /* номер смены для документа            */
            ,input   true
            ,output  p-fact-order-sys-from                  /* порядковый номер закрытия документа  */
            ,output  v-shift-end-fact-order                 /* номер конца смены                    */
            ,output  v-day-end-fact-order                   /* номер конца дня                      */
            ) no-error  .
            if error-status :error then
                 return error substitute ( "Ошибка из factord &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
      when int({&mpl-date-sys})  /* дата сервера */ then
        do :
          run factord (
            input    buf_price-doc-forming.start-sys-date
            ,input   buf_price-doc-forming.start-sys-time
            ,input   (if buf_price-doc-forming.start-sys-time = 0 or buf_price-doc-forming.start-sys-time = ? then 1 else buf_price-doc-forming.start-sys-time )  /* фактический номер закрытия документа */
            ,input   ?                                      /* дата начала смены для документа      */
            ,input   ?                                      /* номер смены для документа            */
            ,input   false
            ,output  p-fact-order-sys-from                  /* порядковый номер закрытия документа  */
            ,output  v-shift-end-fact-order                 /* номер конца смены                    */
            ,output  v-day-end-fact-order                   /* номер конца дня                      */
            ) no-error .
            if error-status :error then
                 return error substitute ( "Ошибка из factord  - дата сервера &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
    end case.
  end.
 if buf_price-doc-forming.have-end-period = 1 then do:
    case buf_price-list-type.work-date :
      when int({&mpl-date-obj})  /* дата на обкт */ then
        do : /* Начало дня */
           run factord-end-day
              ( buf_price-doc-forming.end-date ,
                output p-fact-order-sys-to ) no-error .
                if error-status :error then
                 return error substitute ( "Ошибка из factord-end-day дата на объекте на конец периода &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).

        end.
      when int({&mpl-date-shift})  /* сменная дата */ then
        do :
          run factord (
             input   buf_price-doc-forming.end-shift-date
            ,input   buf_price-doc-forming.sys-time
            ,input   1                                      /* фактический номер закрытия документа */
            ,input   buf_price-doc-forming.end-shift-date   /* дата начала смены для документа      */
            ,input   buf_price-doc-forming.end-shift-num    /* номер смены для документа            */
            ,input   true
            ,output  v-fact-order                           /* порядковый номер закрытия документа  */
            ,output  p-fact-order-sys-to                    /* номер конца смены                    */
            ,output  v-day-end-fact-order                   /* номер конца дня                      */
            ) no-error .
            if error-status :error then
              return error substitute ( "Ошибка из factord сменная дата на конец &1 &2" ,
                                        error-status :get-message(1) ,
                                        return-value ).
        end.
      when int({&mpl-date-sys})  /* дата сервера */ then
        do :
          run factord (
             input   buf_price-doc-forming.end-sys-date
            ,input   buf_price-doc-forming.end-sys-time
            ,input   (if buf_price-doc-forming.end-sys-time  = 0 or buf_price-doc-forming.end-sys-time = ? then 1 else buf_price-doc-forming.end-sys-time )   /* фактический номер закрытия документа */
            ,input   ?                                      /* дата начала смены для документа      */
            ,input   ?                                      /* номер смены для документа            */
            ,input   false
            ,output  p-fact-order-sys-to                    /* порядковый номер закрытия документа  */
            ,output  v-shift-end-fact-order                 /* номер конца смены                    */
            ,output  v-day-end-fact-order                    /* номер конца дня                      */
            ) no-error .
            if error-status :error then
              return error substitute ( "Ошибка из factord  - дата сервера &1 &2" ,
                                        error-status :get-message(1) ,
                                        return-value ).

        end.
    end case.
  end.


  end.

end procedure. /* make-fact-order-lib3 */

procedure ver-dfc-mpl-lib3 :

define input  parameter p-recid as recid no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-list-type for ub.price-list-type  .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .
define buffer buf_price-doc-sum  for ub.price-doc-forming-gds-sum  .
define buffer buf_price-doc-forming-gds-tnv  for ub.price-doc-forming-gds-tnv  .

define variable v-fact-order-sys-from   as decimal   no-undo .
define variable v-fact-order-sys-to     as decimal   no-undo .

  do
  on error undo, return error return-value
 :
find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming ) = p-recid no-error .
  if error-status :error then return error error-status :get-message(1) .

find first buf_price-list-type  no-lock where
           buf_price-list-type.plt-id = buf_price-doc-forming.plt-id and
           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
  if error-status :error then return error error-status :get-message(1) .

/* Проверка ТПЛ на его компоненты */
  if buf_price-list-type.stts = integer({&pdf-delete}) then do:
     return error substitute(" ТПЛ &1 в статусе УДАЛЕН ! Закрывать с ним новые ДНЦ нельзя !" , buf_price-list-type.name )  .
  end.
  if buf_price-list-type.bgr-id > 0 then do:
      find ub.buyer-group where
            ub.buyer-group.stts       = 0  and
            ub.buyer-group.bgr-db-num = buf_price-list-type.bgr-db-num and
            ub.buyer-group.bgr-id     = buf_price-list-type.bgr-id
            no-lock no-error .
      if not available ub.buyer-group then
      return error substitute(" ТПЛ &1 содержит некорректную группу по покупателям &2(&3) !" , buf_price-list-type.name,buf_price-list-type.bgr-id,buf_price-list-type.bgr-db-num )  .
  end.
  if buf_price-list-type.sgr-id > 0 then do:
      find ub.sum-group where
            ub.sum-group.stts       = 0  and
            ub.sum-group.sgr-db-num = buf_price-list-type.sgr-db-num and
            ub.sum-group.sgr-id     = buf_price-list-type.sgr-id
            no-lock no-error .
      if not available ub.sum-group then
      return error substitute(" ТПЛ &1 содержит некорректную суммовую группу &2(&3) !" , buf_price-list-type.name,buf_price-list-type.sgr-id,buf_price-list-type.sgr-db-num )  .
  end.
  if buf_price-list-type.qgr-id > 0 then do:
      find ub.qnty-group where
           ub.qnty-group.stts       = 0  and
           ub.qnty-group.qgr-db-num = buf_price-list-type.qgr-db-num and
           ub.qnty-group.qgr-id     = buf_price-list-type.qgr-id
           no-lock no-error .
      if not available ub.qnty-group then
      return error substitute(" ТПЛ &1 содержит некорректную количественную группу &2(&3) !" , buf_price-list-type.name,buf_price-list-type.qgr-id,buf_price-list-type.qgr-db-num )  .
  end.

  if buf_price-list-type.tog-id > 0 then do:
      find ub.turnover-group where
           ub.turnover-group.stts       = 0  and
           ub.turnover-group.tog-db-num = buf_price-list-type.tog-db-num and
           ub.turnover-group.tog-id     = buf_price-list-type.tog-id
          no-lock no-error .
      if not available ub.turnover-group then
      return error substitute(" ТПЛ &1 содержит некорректную группу по оборотам &2(&3) !" , buf_price-list-type.name , buf_price-list-type.tog-id , buf_price-list-type.tog-db-num )  .
  end.

  if buf_price-list-type.gop-id > 0 then do:
      find ub.grp-obj-price where
            ub.grp-obj-price.stts       = 0  and
            ub.grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num and
            ub.grp-obj-price.gop-id     = buf_price-list-type.gop-id
            no-lock no-error .
      if not available ub.grp-obj-price then
      return error substitute(" ТПЛ &1 содержит некорректную группу по объектам &2(&3) !" , buf_price-list-type.name,buf_price-list-type.gop-id,buf_price-list-type.gop-db-num )  .
  end.
  if buf_price-list-type.gop-id-for-calc-turnover > 0 then do:
      find ub.grp-obj-price where
            ub.grp-obj-price.stts       = 0  and
            ub.grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num-for-calc-turnover and
            ub.grp-obj-price.gop-id     = buf_price-list-type.gop-id-for-calc-turnover
            no-lock no-error .
      if not available ub.grp-obj-price then
      return error substitute(" ТПЛ &1 содержит некорректную группу по объектам &2(&3) !" , buf_price-list-type.name,buf_price-list-type.gop-id-for-calc-turnover,buf_price-list-type.gop-db-num-for-calc-turnover )  .
  end.



/* проверка шапки */
/* 1. ДАТЫ  */
   if buf_price-doc-forming.have-start-period = integer(true) then do:
      case buf_price-list-type.work-date :
          when int({&mpl-date-obj})    /* дата на обкт */ then
            do :
               if buf_price-doc-forming.start-date = ? then return error "Не задана дата начала действия цен !" .
            end.
          when int({&mpl-date-shift})  /* сменная дата */ then
            do :
                if buf_price-doc-forming.start-shift-date = ? then return error "Не задана сменная дата начала действия цен !" .
                if buf_price-doc-forming.start-shift-num  = ? or
                   buf_price-doc-forming.start-shift-num = 0  then return error "Не задан порядок смены начала действия цен !" .
            end.
          when int({&mpl-date-sys})    /* дата сервера */ then
            do :
                if buf_price-doc-forming.start-sys-date = ? then return error "Не задана дата начала действия цен !" .
                if buf_price-doc-forming.start-sys-time = ? then return error "Не задано время начала действия цен !" .
            end.
      end case.
   end.

   if buf_price-doc-forming.have-end-period = integer(true) then do:
      case buf_price-list-type.work-date :
          when int({&mpl-date-obj})    /* дата на обкт */ then
            do :
               if buf_price-doc-forming.end-date = ? then return error "Не задана дата окончания действия цен !" .
            end.
          when int({&mpl-date-shift})  /* сменная дата */ then
            do :
                if buf_price-doc-forming.end-shift-date = ? then return error "Не задана сменная дата окончания действия цен !" .
                if buf_price-doc-forming.end-shift-num  = ? or
                   buf_price-doc-forming.end-shift-num = 0  then return error "Не задан порядок смены окончания  действия цен !" .
            end.
          when int({&mpl-date-sys})    /* дата сервера */ then
            do :
                if buf_price-doc-forming.end-sys-date = ? then return error "Не задана дата окончания действия цен !" .
                if buf_price-doc-forming.end-sys-time = ? then return error "Не задано время окончания действия цен !" .
            end.
      end case.
   end.

   if buf_price-doc-forming.have-start-period = integer(true) and
      buf_price-doc-forming.have-end-period = integer(true) then do:

      case buf_price-list-type.work-date :
          when int({&mpl-date-obj})    /* дата на обкт */ then
            do :
               if buf_price-doc-forming.end-date < buf_price-doc-forming.start-date then return error "Не верно задан интервал дат !" .
            end.
          when int({&mpl-date-shift})  /* сменная дата */ then
            do :
                if buf_price-doc-forming.end-shift-date < buf_price-doc-forming.start-shift-date then return error "Не верно задан интервал дат !" .
                if buf_price-doc-forming.end-shift-date = buf_price-doc-forming.start-shift-date then do:
                   if buf_price-doc-forming.end-shift-num < buf_price-doc-forming.start-shift-num then return error "Не верно задан интервал смен !" .
                end.
            end.
          when int({&mpl-date-sys})    /* дата сервера */ then
            do :
                if buf_price-doc-forming.end-sys-date < buf_price-doc-forming.start-sys-date then return error "Не верно задан интервал дат !" .
                if buf_price-doc-forming.end-sys-date = buf_price-doc-forming.start-sys-date then do:
                   if buf_price-doc-forming.end-sys-time < buf_price-doc-forming.start-sys-time then return error "Не верно задан интервал времени !" .
                end.
            end.
      end case.
   end.

/* Наименование */
if buf_price-doc-forming.name = "" then return error "Не задано название ДНЦ !" .
if buf_price-list-type.main = false then do:
    run make-fact-order-lib3 in this-procedure
        ( input  p-recid ,
          output v-fact-order-sys-from ,
          output v-fact-order-sys-to   ) .
end.

define variable old-price as decimal   no-undo .
/* Проверка строк с gds */
define variable v-kol-rec as integer   no-undo .
define variable v-gds-null-price as character no-undo initial "" .
define variable v-type as character no-undo .
v-kol-rec = 0.
for each buf_price-doc-forming-gds no-lock where
         buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
         buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
         buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
         buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      :
    find first ub.bar-code no-lock where
               ub.bar-code.b-code = buf_price-doc-forming-gds.b-code no-error .
               if error-status :error then return error substitute ("Не найден бар-код &1" ,  buf_price-doc-forming-gds.b-code ) .
    find first ub.goods no-lock where
               ub.goods.artic = buf_price-doc-forming-gds.artic         and
               ub.goods.prod-type = buf_price-doc-forming-gds.prod-type and
               ub.goods.prod-code = buf_price-doc-forming-gds.prod-code no-error .
               if error-status :error then return error substitute ("Не найден товар &1 &2 &3" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code) .
    if ub.bar-code.gds-code <> ub.goods.gds-code then return error substitute ("Бар-код &4 не соответствует товару &1 &2 &3" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.b-code ) .
    run gds-attr-value in this-procedure (input ub.goods.gds-code
                                         ,input {&attr-null-price}
                                         ,output v-gds-null-price
                                         ,output v-type ) no-error .                                  
    if buf_price-doc-forming-gds.price-sale-doc   = ? or (buf_price-doc-forming-gds.price-sale-doc   = 0 and not logical(v-gds-null-price) ) 
                then return error substitute ("Продажная цена по товару &1 &2 &3 = &4" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.price-sale-doc  ) .
    if buf_price-doc-forming-gds.price-sale-rubl  = ? or (buf_price-doc-forming-gds.price-sale-rubl  = 0 and not logical(v-gds-null-price) )
                then return error substitute ("Продажная цена по товару &1 &2 &3 = &4" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.price-sale-rubl ) .
    if buf_price-doc-forming-gds.price-sale-base  = ? or (buf_price-doc-forming-gds.price-sale-base  = 0 and not logical(v-gds-null-price) )
                then return error substitute ("Продажная цена по товару &1 &2 &3 = &4" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.price-sale-base ) .
    if buf_price-doc-forming-gds.slt-pc = ? then return error substitute ("НсП по товару &1 &2 &3 не определен" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code) .
    if buf_price-doc-forming-gds.vat-pc = ? then return error substitute ("НДС по товару &1 &2 &3 не определен" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code) .


old-price = ? .
  for each buf_price-doc-forming-gds-qnty no-lock where
           buf_price-doc-forming-gds-qnty.plt-id = buf_price-doc-forming-gds.plt-id and
           buf_price-doc-forming-gds-qnty.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
           buf_price-doc-forming-gds-qnty.pdf-id = buf_price-doc-forming-gds.pdf-id and
           buf_price-doc-forming-gds-qnty.pdf-db = buf_price-doc-forming-gds.pdf-db and
           buf_price-doc-forming-gds-qnty.b-code = buf_price-doc-forming-gds.b-code
           by buf_price-doc-forming-gds-qnty.ggr-qnty :
           if old-price < buf_price-doc-forming-gds-qnty.price-sale-doc and old-price <> ? then do:
              return error substitute ("Цена по товару &1 &2 &3 по категории количество покупки >= &4  больше предыдущей категории (&5 и  &6)" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds-qnty.ggr-qnty ,old-price , buf_price-doc-forming-gds-qnty.price-sale-doc) .
           end.
           old-price = buf_price-doc-forming-gds-qnty.price-sale-doc .
  end.
old-price = ? .
  for each buf_price-doc-sum no-lock where
           buf_price-doc-sum.plt-id     = buf_price-doc-forming-gds.plt-id and
           buf_price-doc-sum.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
           buf_price-doc-sum.pdf-id     = buf_price-doc-forming-gds.pdf-id and
           buf_price-doc-sum.pdf-db     = buf_price-doc-forming-gds.pdf-db and
           buf_price-doc-sum.b-code     = buf_price-doc-forming-gds.b-code
           by buf_price-doc-sum.ssg-summa
           :

           if old-price < buf_price-doc-sum.price-sale-doc and old-price <> ? then do:
              return error substitute ("Цена по товару &1 &2 &3 по категории сумма покупки >= &4  больше предыдущей категории (&5 и  &6)" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-sum.ssg-summa , old-price , buf_price-doc-sum.price-sale-doc) .
           end.
           old-price = buf_price-doc-sum.price-sale-doc .

  end.
old-price = ? .
  for each buf_price-doc-forming-gds-tnv no-lock where
           buf_price-doc-forming-gds-tnv.plt-id     = buf_price-doc-forming-gds.plt-id and
           buf_price-doc-forming-gds-tnv.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
           buf_price-doc-forming-gds-tnv.pdf-id     = buf_price-doc-forming-gds.pdf-id and
           buf_price-doc-forming-gds-tnv.pdf-db     = buf_price-doc-forming-gds.pdf-db and
           buf_price-doc-forming-gds-tnv.b-code     = buf_price-doc-forming-gds.b-code
           by buf_price-doc-forming-gds-tnv.ttg-summa :
           if old-price < buf_price-doc-forming-gds-tnv.price-sale-doc and old-price <> ? then do:
              return error substitute ("Цена по товару &1 &2 &3 по категории сумма оборота покупателя >= &4  больше предыдущей категории (&5 и  &6)" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds-tnv.ttg-summa ,old-price , buf_price-doc-forming-gds-tnv.price-sale-doc) .
           end.
           old-price = buf_price-doc-forming-gds-tnv.price-sale-doc .
  end.

  define buffer old_price-doc-forming for ub.price-doc-forming  .
  define buffer old_price-doc-forming-gds for ub.price-doc-forming-gds  .
  define buffer old_price-all for ub.price-all.

  if buf_price-list-type.main = false then do:
     for each old_price-doc-forming no-lock where
              old_price-doc-forming.plt-id     = buf_price-list-type.plt-id     and
              old_price-doc-forming.plt-db-num = buf_price-list-type.plt-db-num and
              old_price-doc-forming.stts       = integer({&pdf-fact}) /*закрытые*/ ,
              each old_price-doc-forming-gds no-lock where
                    old_price-doc-forming-gds.plt-id     = buf_price-list-type.plt-id      and
                    old_price-doc-forming-gds.plt-db-num = buf_price-list-type.plt-db-num  and
                    old_price-doc-forming-gds.pdf-id     = old_price-doc-forming.pdf-id    and
                    old_price-doc-forming-gds.pdf-db     = old_price-doc-forming.pdf-db    and
                    old_price-doc-forming-gds.b-code     = buf_price-doc-forming-gds.b-code :
             for each old_price-all no-lock where
                      old_price-all.plt-id     = old_price-doc-forming-gds.plt-id      and
                      old_price-all.plt-db-num = old_price-doc-forming-gds.plt-db-num  and
                      old_price-all.pdf-id     = old_price-doc-forming-gds.pdf-id      and
                      old_price-all.pdf-db     = old_price-doc-forming-gds.pdf-db      and
                      old_price-all.b-code     = old_price-doc-forming-gds.b-code      and
                      old_price-all.fact-order-sys-to   >= v-fact-order-sys-from       and
                      old_price-all.fact-order-sys-from <= v-fact-order-sys-to         :
                     return error substitute ("По товару &1 &2 &3 есть цена &6 в пересекающийся период с таким же приоритетом &7 (ДНЦ &4 &5) " ,
                                               buf_price-doc-forming-gds.artic ,
                                               buf_price-doc-forming-gds.prod-type ,
                                               buf_price-doc-forming-gds.prod-code,
                                               old_price-all.pdf-id ,
                                               old_price-all.pdf-db ,
                                               old_price-doc-forming-gds.price-sale-doc ,
                                               old_price-all.plt-priority
                                               ) .
             end.
     end.
     end.
    assign v-kol-rec = v-kol-rec + 1 .
end.
/*  проверка параметра pr-equ-dq */
  run ver-pr-equ-qS in this-procedure
    ( input buf_price-doc-forming.plt-id ,
      input buf_price-doc-forming.plt-db-num,
      input buf_price-doc-forming.pdf-id ,
      input buf_price-doc-forming.pdf-db
      ) no-error .
  if error-status :error then  return error  "Ошибка при удалении строки ДНЦ "   .

if v-kol-rec = 0 then return error "no-records":U.
end.

end procedure. /* ver-dfc-mpl-lib3 */

procedure ver-pr-equ-qS :
define input parameter  p-plt-id      as integer   no-undo .
define input parameter  p-plt-db-num  as integer   no-undo .
define input parameter  p-pdf-id      as integer   no-undo .
define input parameter  p-pdf-db      as integer   no-undo .

  do
  on error undo, return error return-value
  :
/*
ДЛЯ ИНТЕРФЕЙСА ДНЦ
При закрытии ДНЦ удалять строки главных цен,
     цена по которым не изменилась,
     если для них нет специальных и неосновных;
     Удалять специальные и неосновные, цены которых равны главной
*/


define variable  l-doc-num2   like ub.price-list.doc-num    no-undo .

define buffer pdf_price-list  for ub.price-doc-forming-gds .
define buffer pp_price-list   for ub.price-doc-forming-gds .
define buffer main_price-list for ub.price-doc-forming-gds .
define buffer alt_price-list  for ub.price-doc-forming-gds .
define buffer buf1-bar-code   for ub.bar-code .
define buffer buf2-bar-code   for ub.bar-code .
define buffer buf_goods for ub.goods  .
define buffer buf2_goods for ub.goods  .

define variable v-num as integer init 0 no-undo .
define variable bbb   as logical no-undo .

define variable l-price-sale like ub.price-list.price-sale no-undo .
define variable l-road-tax   like ub.price-list.road-tax   no-undo .
define variable l-excise     like ub.price-list.excise     no-undo .
define variable l-ok          as logical no-undo .
define variable check-par     as logical no-undo .
define variable main-b-code   as integer no-undo .
define variable par-pr-equ-dq as integer no-undo .
define variable v-price-sale  as decimal no-undo .

/* удаление основной цены если равна прошлой */
{ gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-overval} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-equ-dq} then par-pr-equ-dq = thbjattr_thbj-attr.property-value-integer .
end.
if par-pr-equ-dq = 1 then return . /* не удалять */

/* СРАВНЕНИЕ С ПРОШЛОЙ ЦЕНОЙ */
for each pdf_price-list exclusive-lock where
         pdf_price-list.plt-id     = p-plt-id     and
         pdf_price-list.plt-db-num = p-plt-db-num and
         pdf_price-list.pdf-id     = p-pdf-id     and
         pdf_price-list.pdf-db     = p-pdf-db     by pdf_price-list.line-num
        :
    /* по главным ценам */
    if not (pdf_price-list.b-code     = f-base-code (pdf_price-list.b-code) ) then next .
    check-par = false .
   /* ищем предыдущую цену товара по текущему объекту */

   find first x_obj-group no-error .
  { gbl/bcodeprc.i
    x_obj-group.obj-type
    x_obj-group.obj-code
    pdf_price-list.b-code
    0
    0
    l-doc-num2
    l-price-sale
    l-road-tax
    l-excise
    no-error }
    v-price-sale = l-price-sale .

   for each x_obj-group :
  { gbl/bcodeprc.i
    x_obj-group.obj-type
    x_obj-group.obj-code
    pdf_price-list.b-code
    0
    0
    l-doc-num2
    l-price-sale
    l-road-tax
    l-excise
    no-error }
    if v-price-sale <> l-price-sale  then do :
      v-price-sale = l-price-sale.
      leave .
    end.
   end.

   find first x_obj-group no-error .
  { gbl/bcodeprc.i
    x_obj-group.obj-type
    x_obj-group.obj-code
    pdf_price-list.b-code
    0
    0
    l-doc-num2
    l-price-sale
    l-road-tax
    l-excise
    no-error }

      if l-doc-num2 <> ? then do :
        if l-price-sale = pdf_price-list.price-sale-doc
        and v-price-sale = pdf_price-list.price-sale-doc
        then do:
             find first buf_goods no-lock where
                        buf_goods.artic     =  pdf_price-list.artic and
                        buf_goods.prod-type =  pdf_price-list.prod-type and
                        buf_goods.prod-code =  pdf_price-list.prod-code no-error .

            /* если есть  неосн цены , то не удаляем */
            check-par = false .
               for each pp_price-list no-lock where
                        pp_price-list.plt-id     = p-plt-id     and
                        pp_price-list.plt-db-num = p-plt-db-num and
                        pp_price-list.pdf-id     = p-pdf-id     and
                        pp_price-list.pdf-db     = p-pdf-db     and
                        pp_price-list.artic      = pdf_price-list.artic and
                        pp_price-list.prod-type  = pdf_price-list.prod-type  and
                        pp_price-list.prod-code  = pdf_price-list.prod-code ,
                     first buf1-bar-code no-lock where
                          buf1-bar-code.b-code   = pp_price-list.b-code and
                          buf1-bar-code.unit-cli <> buf_goods.unit-base

                    :
                    if  pp_price-list.b-code = f-base-code (pp_price-list.b-code) then next .
                    check-par = true  .
                    leave.
                end.
                /* если есть  признаки  с другой ценой то не удаляем */
               for each pp_price-list no-lock where
                        pp_price-list.plt-id     = p-plt-id     and
                        pp_price-list.plt-db-num = p-plt-db-num and
                        pp_price-list.pdf-id     = p-pdf-id     and
                        pp_price-list.pdf-db     = p-pdf-db     and
                        pp_price-list.artic      = pdf_price-list.artic and
                        pp_price-list.prod-type  = pdf_price-list.prod-type  and
                        pp_price-list.prod-code  = pdf_price-list.prod-code and
                        pp_price-list.price-sale-doc <> pdf_price-list.price-sale-doc  ,
                     first buf1-bar-code no-lock where
                          buf1-bar-code.b-code   = pp_price-list.b-code and
                          buf1-bar-code.unit-cli = buf_goods.unit-base

                    :
                    if  pp_price-list.b-code = f-base-code (pp_price-list.b-code) then next .
                    check-par = true  .
                    leave.
                end.

            if check-par = true then next.  /* есть неглавные коды пропускаем */

            if par-pr-equ-dq = 2 then do: /* есть вопрос */
                  if  ( v-num <= 2  and check-par = false ) then
                      run gbl/d-askw.w
                        (input "Удалить строку?" /* Заголовок окна */
                        ,input      "Предыдущая цена РАВНА цене по закрываемому документу " + {&new-line}
                                    + " Объект "  + v-cntxt-obj-type + String(v-cntxt-obj-code)
                                    + " Артикул " + pdf_price-list.artic + " " +  buf_goods.gds-name + {&new-line}
                                    + " Бар-код " + string(pdf_price-list.b-code)
                                    + " Цена по предыдущему документу переоценки № " + l-doc-num2 + " = "
                                    + string(pdf_price-list.price-sale-doc) + {&new-line}
                                    + " Удалить строку? "
                        ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                        ,input "Да|Нет|Да для всех^confirm|Нет для всех^confirm" /* список названий кнопок  */
                        ,input "Удалить строку|" /* список описаний кнопок */
                            + "Не удалять строку|"
                            + "Удалять у всех товаров, цена на которые не изменилась|"
                            + "Не удалять у всех товаров, цена на которые не изменилась"
                        ,input 1 /* значение возвращаемое при нажатии enter */
                        ,input 2 /* значение возвращаемое при нажатии escape */
                        ,output v-num /* выбор пользователя */
                        ).
              end.
              else do:
                v-num = 3 .
              end.
                if v-num = 1 then do:
                  run del-doc-line ( input recid(pdf_price-list)) no-error  .
                                  if error-status :error then do:
                                          message  vss-workfile vss-revision vss-description skip
                                          "Ошибка при удаление строки ДНЦ"
                                          pdf_price-list.b-code skip
                                          error-status :get-message(1) .
                                          return error.
                                  end.
                end.
                if v-num = 3  then do:
                   run del-doc-line ( input recid(pdf_price-list)) no-error  .
                end.
        end. /* цена равна */
       end.  /* есть предыдущая цена */
end. /* foreach*/


/* СРАВННЕНИЕ С ТЕКУШЕЙ ЦЕНОЙ */

  /* если есть признаки с одинаковой ценой  */
  /* удаление признаков с ценой как у товара  Если есть параметр то молча удаляем */

  for each main_price-list no-lock where  /* по главным ценам */
              main_price-list.plt-id      = p-plt-id and
              main_price-list.plt-db-num  = p-plt-db-num and
              main_price-list.pdf-id      = p-pdf-id and
              main_price-list.pdf-db      = p-pdf-db

              :
              if main_price-list.b-code <> f-base-code (main_price-list.b-code) then next.
            /* в этойже ДНЦ есть равные цены основной */
                for each pp_price-list no-lock where
                          pp_price-list.plt-id       = main_price-list.plt-id     and
                          pp_price-list.plt-db-num   = main_price-list.plt-db-num and
                          pp_price-list.pdf-id       = main_price-list.pdf-id     and
                          pp_price-list.pdf-db       = main_price-list.pdf-db     and
                          pp_price-list.artic        = main_price-list.artic      and
                          pp_price-list.prod-type    = main_price-list.prod-type  and
                          pp_price-list.prod-code    = main_price-list.prod-code  and
                          pp_price-list.b-code      <> main_price-list.b-code     and
                          pp_price-list.price-sale-doc = main_price-list.price-sale-doc  ,
                    first buf_goods no-lock where
                          buf_goods.artic     =  pp_price-list.artic and
                          buf_goods.prod-type =  pp_price-list.prod-type and
                          buf_goods.prod-code =  pp_price-list.prod-code ,
                    first buf1-bar-code no-lock where
                          buf1-bar-code.b-code   = pp_price-list.b-code and
                          buf1-bar-code.unit-cli = buf_goods.unit-base
                          :
                          bbb = true .
                          /* есть ли неосновные цены */
                          for each alt_price-list no-lock where
                                  alt_price-list.plt-id     = pp_price-list.plt-id     and
                                  alt_price-list.plt-db-num = pp_price-list.plt-db-num and
                                  alt_price-list.pdf-id     = pp_price-list.pdf-id     and
                                  alt_price-list.pdf-db     = pp_price-list.pdf-db     and
                                  alt_price-list.artic      = pp_price-list.artic      and
                                  alt_price-list.prod-type  = pp_price-list.prod-type  and
                                  alt_price-list.b-code     <> main_price-list.b-code  and
                                  alt_price-list.b-code     <> pp_price-list.b-code    and
                                  alt_price-list.prod-code  = pp_price-list.prod-code ,
                            first buf2_goods no-lock where
                                  buf2_goods.artic     =  pp_price-list.artic     and
                                  buf2_goods.prod-type =  pp_price-list.prod-type and
                                  buf2_goods.prod-code =  pp_price-list.prod-code ,
                            first buf2-bar-code no-lock where
                                  buf2-bar-code.b-code   = alt_price-list.b-code and
                                  buf2-bar-code.unit-cli <> buf2_goods.unit-base and
                                  buf2-bar-code.node-code = buf1-bar-code.node-code
                                :
                                bbb = false.
                                leave.
                          end.
                          if bbb = true  then do:
                              run del-doc-line ( input recid (pp_price-list)) no-error  .
                              if error-status :error then do:
                                  message  vss-workfile vss-revision vss-description skip
                                  " Нельзя удалить " pp_price-list.b-code skip
                                  error-status :get-message(1) .
                              end.
                          end.
                end.
  end.
end.
end procedure. /* ver-pr-equ-qS */

procedure ver-pr-discnS :
define input  parameter p-plt-id        as integer   no-undo .
define input  parameter p-plt-db-num    as integer   no-undo .
define input  parameter p-pdf-id        as integer   no-undo .
define input  parameter p-pdf-db        as integer   no-undo .
define input  parameter p-mode        as character no-undo .
define input  parameter trn-doc-code  like ub.trn-doc.doc-code no-undo .
define output parameter p-err         as logical no-undo .
  do
  on error undo, return error return-value
  :
{ str/in-vatp.i def }

define buffer b_price-doc-forming-gds for ub.price-doc-forming-gds .
define buffer b_trn-doc    for ub.trn-doc .
define buffer b_doc-line   for ub.doc-line .
define buffer bl_goods     for ub.goods .
define buffer bl_gds-grp   for ub.gds-grp .
define buffer bl_bar-code  for ub.bar-code  .
define buffer buf_bar-code for ub.bar-code  .

define variable v-koff            as decimal   no-undo .
define variable t-prc             as decimal   no-undo .
define variable p-prc-min         as decimal   no-undo .
define variable p-prc-max         as decimal   no-undo .
define variable p-increase-pc     as decimal   no-undo .
define variable p-round-method    as character no-undo .
define variable p-base            as decimal   no-undo .
define variable var-pr-r-b        as character no-undo .
define variable tt-price-sale     as decimal   no-undo .
define variable p-node-code       as integer   no-undo .    /* код группы   */
define variable p-host-code       as integer   no-undo .    /* код фирмы    */
define variable p-obj-type        as character no-undo .    /* тип объекта  */
define variable p-obj-code        as integer   no-undo .    /* код объекта  */
define variable p-value-margin    as integer   no-undo .    /* область действия */
define variable p-type-margin     as logical   no-undo .
define variable p-value-increase  as integer   no-undo .    /* область действия */
define variable p-type-increase   as logical   no-undo .
define variable p-value-rmethod   as integer   no-undo .
define variable p-type-rmethod    as logical   no-undo .
define variable l_price           as decimal   no-undo .
define variable l_pricewithvat    as decimal   no-undo .
define variable l_pricewithoutvat as decimal   no-undo .
define variable l_prod-vat        as decimal   no-undo .
define variable fact_price        as decimal   no-undo .
define variable pr-discm          as character no-undo .
define variable pr-gen-margin     as character no-undo .
p-err = false .

define variable cost-base     as decimal  no-undo .
define variable cost-rubl     as decimal  no-undo .
define variable v-price-base  as decimal  no-undo .
define variable v-price-rubl  as decimal  no-undo .
define variable cur-rt-base   as decimal  no-undo .
define variable cur-rt-rubl   as decimal  no-undo .

define variable f-cost as decimal no-undo .
define variable s-cost as decimal no-undo .
define variable f-qnty as decimal no-undo .
define variable s-qnty as decimal no-undo .

define variable p-attr-code    as character no-undo .
define variable p-b-code       as integer   no-undo .
define variable p-attr-value   as character no-undo .
define variable v-ok           as logical   no-undo .
define variable par-type       as character no-undo.    /* тип параметра конфигурации */
define variable v-main-b-code  as integer   no-undo .
define variable v-vat-pc       as decimal   no-undo .


{ gbl/curr-r-b.i  var-pr-r-b }
find first x_obj-group .
{ gbl/hostcode.i x_obj-group.obj-type x_obj-group.obj-code p-host-code}
assign
  p-obj-type   = x_obj-group.obj-type
  p-obj-code   = x_obj-group.obj-code
.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_overvalue_discount':U
  {&cntxt-object}
  p-host-code
  p-obj-type
  p-obj-code
  0
  0
  0
  false
  v-ok
}

  if v-ok = true then return .


if trim(par-pr-discm) = "" then return .
if par-pr-discm = 'sale-' then par-pr-discm = 'sale' .

for each  b_price-doc-forming-gds no-lock where
          b_price-doc-forming-gds.plt-id     = p-plt-id      and
          b_price-doc-forming-gds.plt-db-num = p-plt-db-num  and
          b_price-doc-forming-gds.pdf-id     = p-pdf-id      and
          b_price-doc-forming-gds.pdf-db     = p-pdf-db
          :

    find first buf_bar-code no-lock where
               buf_bar-code.b-code  = b_price-doc-forming-gds.b-code
               no-error .
    if available buf_bar-code then v-koff = buf_bar-code.cli-base-rate .
    else v-koff = 1.
    if v-koff = ? or v-koff = 0 then v-koff = 1.

   find first bl_goods no-lock   where
              bl_goods.artic     = b_price-doc-forming-gds.artic     and
              bl_goods.prod-code = b_price-doc-forming-gds.prod-code and
              bl_goods.prod-type = b_price-doc-forming-gds.prod-type
              .
    assign
      p-node-code  = bl_goods.grp-code
    .
    run gds-attr-margin-value
    (
      input   bl_goods.gds-code,
      input   p-obj-type ,
      input   p-obj-code ,
      output  p-prc-min  ,
      output  p-prc-max  ,
      output  p-increase-pc,
      output  p-round-method,
      output  p-base        ,
      output  p-value-margin    ,
      output  p-type-margin     ,
      output  p-value-increase   ,
      output  p-type-increase   ,
      output  p-value-rmethod   ,
      output  p-type-rmethod
      ) .
    if p-type-margin = false  then next.

{ gbl/gdsbcode.i bl_goods.gds-code ? v-main-b-code}

    if  trn-doc-code = ? or trn-doc-code = "" then do:               /*  это созданные вручную переоценки */
        if v-main-b-code = b_price-doc-forming-gds.b-code then do :  /*  главные цены */
          case  par-pr-discm :
             when "prod":u then do:
                 { gbl/proprice.i
                   b_price-doc-forming-gds.b-code
                   p-obj-type
                   p-obj-code
                   l_pricewithoutvat
                   l_price
                   l_prod-vat
                   v-str2
                   v-str2
                   }
                  fact_price =  if var-pr-r-b = "rubl"
                                then  b_price-doc-forming-gds.price-sale-rubl
                                else  b_price-doc-forming-gds.price-sale-base
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
              when "prod-vat":u then do:
                 { gbl/proprice.i
                   b_price-doc-forming-gds.b-code
                   p-obj-type
                   p-obj-code
                   l_price
                   l_pricewithvat
                   l_prod-vat
                   v-str2
                   v-str2
                   }
                  fact_price =  if var-pr-r-b = "rubl"
                                then  b_price-doc-forming-gds.price-sale-rubl
                                else  b_price-doc-forming-gds.price-sale-base
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.

              when "cost-vat":u then do:
                  run str/mplnovat.p
                     (input {&pr-calc-cost-novat-gr},
                      input table x_obj-group ,
                      input b_price-doc-forming-gds.b-code,
                      input b_price-doc-forming-gds.artic,
                      input b_price-doc-forming-gds.prod-type,
                      input b_price-doc-forming-gds.prod-code,
                      input 0 ,
                      input ? ,
                      input b_price-doc-forming-gds.vat-pc ,
                      input b_price-doc-forming-gds.slt-pc ,
                      output cost-base   ,
                      output cost-rubl   ,
                      output v-price-base  ,
                      output v-price-rubl  ,
                      output cur-rt-base ,
                      output cur-rt-rubl
                      ).
                  assign
                    l_price    =  if var-pr-r-b = "rubl" then v-price-rubl else v-price-base
                    fact_price =  if var-pr-r-b = "rubl" then b_price-doc-forming-gds.price-sale-rubl else b_price-doc-forming-gds.price-sale-base
                  .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
            when "cost":u       then do:
              t-prc =  fnc-cost-pc (buffer b_price-doc-forming-gds) .
            end.
            when "sale":u then do:
              t-prc =  fnc-pr-pc   (buffer b_price-doc-forming-gds) .
            end.
          end case.
        end.
        else do:
         /* неосновные коды и признаки */
 case  par-pr-discm :
            when "cost":u
            or when "cost-vat":u
            then do:
              l_price =  fnc-cost (buffer b_price-doc-forming-gds) .
              t-prc = ((b_price-doc-forming-gds.price-sale-rubl / v-koff)  / l_price - 1) * 100.
            end.
            when "sale":u then do:
              l_price =  fnc-pr   (buffer b_price-doc-forming-gds) .
              t-prc = (( b_price-doc-forming-gds.price-sale-rubl / v-koff) /  l_price - 1) * 100.
            end.
              when "prod":u then do:
                 { gbl/proprice.i
                   b_price-doc-forming-gds.b-code
                   p-obj-type
                   p-obj-code
                   l_pricewithoutvat
                   l_price
                   l_prod-vat
                   v-str2
                   v-str2
                   }
                  fact_price =  if var-pr-r-b = "rubl"
                                then
                                   b_price-doc-forming-gds.price-sale-rubl  / v-koff
                                else
                                   b_price-doc-forming-gds.price-sale-base  / v-koff
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
              when "prod-vat":u then do:
                 { gbl/proprice.i
                   b_price-doc-forming-gds.b-code
                   p-obj-type
                   p-obj-code
                   l_price
                   l_pricewithvat
                   l_prod-vat
                   v-str2
                   v-str2
                   }
                  fact_price =  if var-pr-r-b = "rubl"
                                then
                                   b_price-doc-forming-gds.price-sale-rubl  / v-koff
                                else
                                   b_price-doc-forming-gds.price-sale-base  / v-koff
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
          end case.
        end.
    end.

if  trn-doc-code <> ? and trn-doc-code <> "" then do:
    find first b_trn-doc where b_trn-doc.doc-code = trn-doc-code no-lock no-error .
    if available b_trn-doc then find first b_doc-line where
    b_doc-line.doc-code  = b_trn-doc.doc-code and
    b_doc-line.artic     = bl_goods.artic     and
    b_doc-line.prod-code = bl_goods.prod-code and
    b_doc-line.prod-type = bl_goods.prod-type no-lock no-error .

    if b_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then   pr-gen-margin = par-gen-mrgn-ie.
    if b_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} then   pr-gen-margin = par-gen-mrgn-iv.
    if b_trn-doc.ext-doc-type = {&TDEDT_Pri_Prvo}  then   pr-gen-margin = par-gen-mrgn-im.

    pr-gen-margin = lc(pr-gen-margin).


      if available b_doc-line then do:
      case  par-pr-discm :
        when "cost":u then do:
                f-qnty = 0.
                find ub.gds-obj no-lock where
                    ub.gds-obj.gds-code = bl_goods.gds-code and
                    ub.gds-obj.obj-type = b_trn-doc.obj-type and
                    ub.gds-obj.obj-code = b_trn-doc.obj-code no-error.
                if  available ub.gds-obj then
                  if bl_goods.gds-type = {&gds-goods} then do:
                          if var-pr-r-b = "rubl" then
                              assign
                                f-cost = if  ub.gds-obj.avrg-rubl = ? then 0 else ub.gds-obj.avrg-rubl
                                f-qnty = ub.gds-obj.avrg-qnty
                                .
                          else
                              assign
                                f-cost = if  ub.gds-obj.avrg-base = ? then 0 else ub.gds-obj.avrg-base
                                f-qnty = ub.gds-obj.avrg-qnty
                                .
                      end.
                    else  f-cost = ?.
                else f-cost = ?.

           if pr-gen-margin = {&typeprice_before-margin} then do:
           { str/in-vatp.i calc b_doc-line. b_trn-doc. }
             if var-pr-r-b = "rubl" then
                 s-cost = price-rubl-with-tax-loc.
               else
                 s-cost = price-base-with-tax-loc.

             s-qnty = b_doc-line.fact-qnty .
           end.
           else do:
             assign
              s-cost = 0
              s-qnty = 0
             .
           end.
           l_price  =  (f-cost * f-qnty + s-cost * s-qnty ) / (f-qnty + s-qnty)  .

        end.
        when "cost-vat":u then do:
             run str/gdsnovat.p ({&pr-calc-cost-wbill-novat},
                     b_trn-doc.obj-type,
                     b_trn-doc.obj-code,
                     b_trn-doc.host-code,
                     b_doc-line.artic,
                     b_doc-line.prod-type,
                     b_doc-line.prod-code,
                     0 ,
                     b_doc-line.doc-code,
                     ?,
                     ?,
                     output cost-base   ,
                     output cost-rubl   ,
                     output v-price-base  ,
                     output v-price-rubl  ,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
                     if var-pr-r-b = "rubl"
                        then l_price = v-price-rubl.
                        else l_price = v-price-base.


        end.
        when "sale":u then do:
              l_price = ( if var-pr-r-b = "rubl"
                             then b_doc-line.price-rubl
                             else b_doc-line.price-base ).
        end.
        when "prod":u then do:
        { gbl/proprice.i
          b_price-doc-forming-gds.b-code
          p-obj-type
          p-obj-code
          l_pricewithoutvat
          l_price
          l_prod-vat
          v-str2
          v-str2
          }
    end.
   when "prod-vat":u then do:
        { gbl/proprice.i
          b_price-doc-forming-gds.b-code
          p-obj-type
          p-obj-code
          l_price
          l_pricewithvat
          l_prod-vat
          v-str2
          v-str2
          }
    end.

      end case.
        tt-price-sale = b_price-doc-forming-gds.price-sale-rubl .  /* TODO переделать на новое поле */
        t-prc = (( tt-price-sale /  v-koff ) / l_price - 1) * 100.
   end.

end.
  if  p-prc-max <> ? then do:
    if  t-prc <> ? and ( p-prc-max < t-prc  or p-prc-min > t-prc)
    then do:
      message (if v-main-b-code = b_price-doc-forming-gds.b-code then "По товару :"
          else "По признаку"  )
          b_price-doc-forming-gds.artic
          b_price-doc-forming-gds.prod-type
          b_price-doc-forming-gds.prod-code skip
          "бар-код: " b_price-doc-forming-gds.b-code
           ( if v-koff > 1 then substitute("Упаковка на: &1" , v-koff)
             else "" ) skip
          fnc-pr  (buffer b_price-doc-forming-gds)
          skip
        "Процент торговой наценки вышел за интервал возможных значений !!! " skip
        "Процент не менее :" p-prc-min "%" skip
        "Процент не более :" p-prc-max "%" skip
        "Процент фактический :" t-prc  "%"  skip
        "ДНЦ №: " b_price-doc-forming-gds.pdf-id         skip
        "БД" b_price-doc-forming-gds.pdf-db
          view-as alert-box error .
              p-err = true .
              undo , return error .
    end.
    else do:
       if  t-prc = ? then  do:
          message (if v-main-b-code = b_price-doc-forming-gds.b-code then "По товару :"
          else "По признаку"  )
          b_price-doc-forming-gds.artic
          b_price-doc-forming-gds.prod-type
          b_price-doc-forming-gds.prod-code skip
          "бар-код: " b_price-doc-forming-gds.b-code
           ( if v-koff > 1 then substitute("Упаковка на: &1" , v-koff)
             else "" ) skip
          fnc-pr  (buffer b_price-doc-forming-gds)
          skip
          "Нет базовой цены для расчета процента наценки !" skip
          "Процент торговой наценки вышел за интервал возможных значений !!! " skip
          "Процент не менее :" p-prc-min "%" skip
          "Процент не более :" p-prc-max "%" skip
          "Процент фактический :" t-prc  "%"  skip
          "ДНЦ №_: " b_price-doc-forming-gds.pdf-id         skip
          "БД" b_price-doc-forming-gds.pdf-db
          view-as alert-box error .
          p-err = true .
          undo , return error .
       end.
    end.
  end.
end.

  end.

end procedure. /* ver-pr-discnS */

procedure del-doc-line :
define input  parameter p-recid as recid no-undo .

  do
  on error undo, return error return-value
  :
  find first ub.price-doc-forming-gds exclusive-lock where
       recid ( ub.price-doc-forming-gds ) = p-recid  no-error .

   if available ub.price-doc-forming-gds then do:
      delete ub.price-doc-forming-gds no-error .
   end.
  end.

end procedure. /* del-doc-line */