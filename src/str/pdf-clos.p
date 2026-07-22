block-level on error undo, throw.
/*

$Revision: dac5fd0fa801, 3654, test $
$Author: EShklyar $
$Date: 2024/01/25 16:33:07 $
$Workfile: pdf-clos.p $
$Archive: str/pdf-clos.p $

Закрытие документа назначения цены

Автор: Чернова Светлана Александровна
Дата создания: 03/09/06
Author: Svetlana Chernova
Creation date: 03/09/06

stts
when 0 then return {&g___new} .           integer({&pdf-new})
when 1 then return {&deleted-status} .
when 3 then return {&fact} .
*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
1 define input  parameter p-recid       as recid no-undo     .
2 define input  parameter p-esc-prd     as logical   no-undo .
3 define input  parameter p-esc-pra     as logical   no-undo .
4 define input  parameter p-ecs-type    as character no-undo .
5 define input  parameter p-ecs-code    as integer   no-undo .
6 define input  parameter p-action      as character no-undo .
7 define input  parameter p-trn-doc     as character no-undo .
8 define input  parameter p-ask-pr      as logical   no-undo .
9 define input  parameter p-ask-do      as logical   no-undo .
*/

define variable p-recid       as recid     no-undo     .
define variable p-esc-prd     as logical   no-undo . /* есть исключение из списка объектов для переоценок */
define variable p-esc-pra     as logical   no-undo . /* есть исключение из списка объектов для ден-цен  */
define variable p-ecs-type    as character no-undo . /* объект исключения */
define variable p-ecs-code    as integer   no-undo . /* объект исключения */
define variable p-action      as character no-undo . /* {&fact}  до какого статуса закрывать переоценки */
define variable p-trn-doc     as character no-undo . /* Номер ПН */
define variable p-ask-pr      as logical   no-undo . /* Молча закрывать переоценки */
define variable p-do      as logical   no-undo .  /* оптим или пессим закрытие */
define variable p-auto      as logical   no-undo . /* OXML, ... */

define variable log-file-name                as character      no-undo init "pdf-clos.txt".
define variable o-db-num as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: dac5fd0fa801, 3654, test $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2024/01/25 16:33:07 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pdf-clos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pdf-clos.p $":U .
define variable vss-description as character no-undo init "Закрытие документа назначения цены".

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i def }
{ ref/xobjgrp.i  }  /* список объектов  */
{ gbl/waitfram.i }
{ str/doc-code.i }
{ trg/factord.i  }
{ str/alt-calc.i "func"  }
p-auto  = logical (entry(10,p-parameter,{&delim-par})) no-error .
  if error-status :error then p-auto = false .
{ str/alt-calc.i "proc" "''"  "''" p-auto }
{ str/alt-calc.i "ver-modificator-price-is-null" }
{ str/mpl-lib2.i }
{ str/mpl-lib3.i }
{ trg/check-bc.i }
{ ref/gds-attr.i }
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer next_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .
define buffer next_price-doc-forming-gds-sum  for ub.price-doc-forming-gds-sum   .
define buffer next_price-doc-forming-gds-tnv  for ub.price-doc-forming-gds-tnv   .
define buffer buf_price-doc-forming-gds-sum   for ub.price-doc-forming-gds-sum   .
define buffer buf_price-doc-forming-gds-tnv   for ub.price-doc-forming-gds-tnv   .
define buffer buf_price-doc-forming-attr      for ub.price-doc-forming-attr  .

assign
  p-recid     = integer (entry(1,p-parameter,{&delim-par}))
  p-esc-prd   = logical (entry(2,p-parameter,{&delim-par}))
  p-esc-pra   = logical (entry(3,p-parameter,{&delim-par}))
  p-ecs-type  =          entry(4,p-parameter,{&delim-par})
  p-ecs-code  = integer (entry(5,p-parameter,{&delim-par}))
  p-action    =          entry(6,p-parameter,{&delim-par})
  p-trn-doc   =          entry(7,p-parameter,{&delim-par})
  p-ask-pr    = logical (entry(8,p-parameter,{&delim-par}))
  .
  p-do    = logical (entry(9,p-parameter,{&delim-par})) no-error .
  if error-status :error then p-do = false .
  

define buffer buf_price-list-type            for ub.price-list-type  .
define buffer buf_price-doc-forming-gds      for ub.price-doc-forming-gds  .
define buffer buf_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .

define variable v-fact-order-shift-from       as decimal   no-undo .
define variable v-fact-order-shift-to         as decimal   no-undo .
define variable v-fact-order-sys-from         as decimal   no-undo .
define variable v-fact-order-sys-to           as decimal   no-undo .
define variable v-old-auto                    as logical   no-undo .
define variable overval-err                   as logical   no-undo .
define variable overval-err-str               as character no-undo .
define variable v-base                        as logical   no-undo .
define variable l-ok as logical   no-undo .
define variable v-chk-act-host-code as integer   no-undo .
define variable v-mess as character no-undo .
define variable v-vid-action        as integer no-undo .
define variable v-vid-param         as longchar no-undo .
define variable varoldstatus        as character no-undo .
define variable varshift-date as date      no-undo.
define variable varshift-num  as integer   no-undo.
define variable varshift-name as character no-undo.
{ str/initiator.i }



{ gbl/rbisbase.i v-base }
if v-base = false then var-pr-r-b = "rubl":U .
                  else var-pr-r-b =  "base":U .

find first buf_price-doc-forming exclusive-lock where recid ( buf_price-doc-forming) = p-recid no-error .
if error-status :error then return error error-status :get-message(1) .

find first buf_price-list-type no-lock where
           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num and
           buf_price-list-type.plt-id     = buf_price-doc-forming.plt-id
           no-error .
if error-status :error then return error error-status :get-message(1) .

run ver-dfc-mpl-lib3 in this-procedure ( recid (buf_price-doc-forming) ) no-error  .
if error-status :error then return error SUBSTITUTE("&1  &2" , return-value , error-status :get-message(1)) .

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Закрытие ДНЦ &1 БД&2", buf_price-doc-forming.pdf-id,buf_price-doc-forming.pdf-db)).

/* Проверка данных */
run str/mplnotls.p
    ( parParentProc ,
      buf_price-doc-forming.pdf-id ,
      buf_price-doc-forming.pdf-db ,
      buf_price-doc-forming.plt-id ,
      buf_price-doc-forming.plt-db-num
    ) no-error . /* проверяем, не потеряны ли цены */
if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute ( "Проверяем, не потеряны ли цены в ДНЦ &1 БД&2&5 &3 &4" , buf_price-doc-forming.pdf-id , buf_price-doc-forming.pdf-db , error-status :get-message(1) , return-value, {&new-line} )).
      return  error  return-value .
end.


/* формирование дат с у кого не было введено при создании ДНЦ */
run dfc-create-date in this-procedure no-error .
if error-status :error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Процедура формирования дат (dfc-create-date) ...&1 &2",error-status :get-message(1),return-value)).
      return error return-value .
end.
/* формирование fact-order  */

run make-fact-order-lib3 in this-procedure
   ( input recid (buf_price-doc-forming) ,
     output v-fact-order-sys-from   ,
     output v-fact-order-sys-to
   ) no-error  .
if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Определение интервала действия (make-fact-order-lib3) ... &1 &2",error-status :get-message(1),return-value)).
    return error return-value .
end.

/* список объектов */
   run metod-gop-obj in this-procedure ( v-cntxt-db-num,  buf_price-list-type.gop-id , buf_price-list-type.gop-db-num) no-error .
   if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Список объектов (metod-gop-obj) ...&1 &2",error-status :get-message(1),return-value)).
      return  error return-value .
   end.
    find first x_obj-group no-error .
    if not available x_obj-group then do:
      run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input "Не найден ни один объект для документа ДНЦ. Проверьте настройки группы ценообразования или, если Вы копировали документ, то убедитесь, что настройки групп ценообразования актуальны.").
       return  error return-value .
    end.
    { gbl/hostcode.i
      x_obj-group.obj-type
      x_obj-group.obj-code
      v-chk-act-host-code
      }
    run chec-par in this-procedure (output l-ok , input v-chk-act-host-code, input x_obj-group.obj-type,input x_obj-group.obj-code ) no-error .
    If l-ok <> true or error-status :error
    then do:
        undo, return error return-value .
    end.

/* Уберем исключения пользователя */
  run metod-delobj-usr in this-procedure (
    buf_price-doc-forming.pdf-id ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id ,
    buf_price-doc-forming.plt-db-num
    ) .


/* Уберем исключения*/
if p-esc-pra = true then do:
   for each x_obj-group  where
            x_obj-group.obj-type = p-ecs-type and
            x_obj-group.obj-code = p-ecs-code  :
   delete x_obj-group.
   end.
end.


/* Уберем для УБД чужие объекты */

if v-cntxt-db-num <> 0 then do:
   for each x_obj-group  :
    { gbl/objdbnum.i
    x_obj-group.obj-type
    x_obj-group.obj-code
    o-db-num
    }
    if o-db-num <> v-cntxt-db-num then do:
       delete x_obj-group.
    end.
   end.
end.
/* Проверка прав */

for each x_obj-group :

    { gbl/hostcode.i
      x_obj-group.obj-type
      x_obj-group.obj-code
      v-chk-act-host-code
    }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_overvalue_order':U
      {&cntxt-object}
      v-chk-act-host-code
      x_obj-group.obj-type
      x_obj-group.obj-code
      0
      0
      0
      true
      l-ok
    }
    if l-ok <> true
    then do:
      if error-status :error then return error return-value .
    end.
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_overvalue_preparation':U
      {&cntxt-object}
      v-chk-act-host-code
      x_obj-group.obj-type
      x_obj-group.obj-code
      0
      0
      0
      true
      l-ok
    }
    if l-ok <> true
    then do:
      if error-status :error then return error return-value .
    end.
end.
/* Проверка на pr-goods состав ДНЦ (можно ли вводить товары, топливо, услуги  ) */
define variable v-errstr as character no-undo .
run dfc-pr-good in this-procedure no-error .


if error-status :error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Проверка состава  ДНЦ...&1 &2",error-status :get-message(1),return-value)).
      return error v-errstr .
      /* return error "pr-goods":U  */
end.

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Создание таблицы поиска цены...")).

/* Создание ДЕН-таблицы */

define buffer buf_bar-code    for ub.bar-code.
define buffer buf_goods       for ub.goods   .
define buffer buf_gds-prt     for ub.gds-prt  .

define variable v-type-price as integer   no-undo .

for each buf_price-doc-forming-gds no-lock  where
         buf_price-doc-forming-gds.stts       = integer({&pdf-new}) and
         buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
         buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
         buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
         buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id :

         find first buf_bar-code no-lock where buf_bar-code.b-code  = buf_price-doc-forming-gds.b-code .
         find first buf_goods    no-lock where buf_goods.gds-code   = buf_bar-code.gds-code .
         find first buf_gds-prt  no-lock where buf_gds-prt.node-code = buf_bar-code.node-code.

         if buf_goods.unit-base = buf_bar-code.unit-cli then do:
             if buf_gds-prt.upper-code = buf_goods.prt-root
               then v-type-price  = integer ({&mpl-type-main}) . /* основные */
               else v-type-price  = integer ({&mpl-type-spec}) . /* спец на основные */
         end.
         else do:
             if buf_gds-prt.upper-code = buf_goods.prt-root
               then v-type-price  = integer ({&mpl-type-nomain}) . /* неосновные */
               else v-type-price  = integer ({&mpl-type-specnomain}) . /* спец на неосновные */
         end.

         /* без привязок по кол, сумме, обороту */
         if buf_price-list-type.have-rs-qnty-group = 0 and
            buf_price-list-type.have-rs-sum-group  = false and
            buf_price-list-type.have-rs-turn-group = 0
         then do:
                run create-price-all in this-procedure
                  ( input {&bef-mpl-main}
                   ,input buf_price-doc-forming-gds.plt-id
                   ,input buf_price-doc-forming-gds.plt-db-num
                   ,input buf_price-doc-forming-gds.pdf-id
                   ,input buf_price-doc-forming-gds.pdf-db
                   ,input buf_price-doc-forming-gds.b-code
                   ,input buf_bar-code.gds-code
                   ,input v-type-price
                   ,input ? /* qnty */
                   ,input ?
                   ,input ? /* sum */
                   ,input ?
                   ,input ? /* tnv */
                   ,input ?
                   ,input v-fact-order-shift-from
                   ,input v-fact-order-shift-to
                   ,input v-fact-order-sys-from
                   ,input v-fact-order-sys-to
                   ,input buf_price-doc-forming-gds.price-sale-doc
                ) no-error .
                if error-status :error then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute("Создание ДЭН (create-price-all по ГТПЛ) ...&1 &2",error-status :get-message(1),return-value)).
                return error return-value .
                end.
         end.
         else do:
                  /* по количеству */
                  if buf_price-list-type.have-rs-qnty-group = 1 then do:
                        for each buf_price-doc-forming-gds-qnty no-lock  where
                                buf_price-doc-forming-gds-qnty.stts       = integer({&pdf-new}) and
                                buf_price-doc-forming-gds-qnty.b-code     = buf_price-doc-forming-gds.b-code and
                                buf_price-doc-forming-gds-qnty.pdf-db     = buf_price-doc-forming-gds.pdf-db and
                                buf_price-doc-forming-gds-qnty.pdf-id     = buf_price-doc-forming-gds.pdf-id and
                                buf_price-doc-forming-gds-qnty.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                                buf_price-doc-forming-gds-qnty.plt-id     = buf_price-doc-forming-gds.plt-id
                                :
                                find first  next_price-doc-forming-gds-qnty no-lock  where
                                            next_price-doc-forming-gds-qnty.stts       = integer({&pdf-new}) and
                                            next_price-doc-forming-gds-qnty.b-code     = buf_price-doc-forming-gds.b-code and
                                            next_price-doc-forming-gds-qnty.pdf-db     = buf_price-doc-forming-gds.pdf-db and
                                            next_price-doc-forming-gds-qnty.pdf-id     = buf_price-doc-forming-gds.pdf-id and
                                            next_price-doc-forming-gds-qnty.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                                            next_price-doc-forming-gds-qnty.plt-id     = buf_price-doc-forming-gds.plt-id and
                                            next_price-doc-forming-gds-qnty.ggr-qnty   > buf_price-doc-forming-gds-qnty.ggr-qnty
                                            use-index pi no-error .

                                run create-price-all in this-procedure
                                    (input {&bef-mpl-qnty}
                                    ,input buf_price-doc-forming-gds.plt-id
                                    ,input buf_price-doc-forming-gds.plt-db-num
                                    ,input buf_price-doc-forming-gds.pdf-id
                                    ,input buf_price-doc-forming-gds.pdf-db
                                    ,input buf_price-doc-forming-gds.b-code
                                    ,input buf_bar-code.gds-code
                                    ,input v-type-price
                                    ,input buf_price-doc-forming-gds-qnty.ggr-qnty   /* qnty */
                                    ,input ( if available next_price-doc-forming-gds-qnty then next_price-doc-forming-gds-qnty.ggr-qnty  else ? )
                                    ,input ? /* sum */
                                    ,input ?
                                    ,input ? /* tnv */
                                    ,input ?
                                    ,input v-fact-order-shift-from
                                    ,input v-fact-order-shift-to
                                    ,input v-fact-order-sys-from
                                    ,input v-fact-order-sys-to
                                    ,input buf_price-doc-forming-gds-qnty.price-sale-doc
                                  ) no-error .
                                  if error-status :error then do:
                                    run write-log-and-file in p-log-handle (
                                          input 1
                                        , input log-file-name
                                        , input 1
                                        , input substitute("Создание ДЭН (create-price-all ) привязка по количеству ...&1 &2",error-status :get-message(1),return-value)).
                                      return error return-value .
                                  end.
                        end.
                  end.
                  /* по суммам */
                  if int ( buf_price-list-type.have-rs-sum-group) = 1 then do:
                       for each buf_price-doc-forming-gds-sum       no-lock  where
                                buf_price-doc-forming-gds-sum.stts       = integer({&pdf-new}) and
                                buf_price-doc-forming-gds-sum.b-code     = buf_price-doc-forming-gds.b-code and
                                buf_price-doc-forming-gds-sum.pdf-db     = buf_price-doc-forming-gds.pdf-db and
                                buf_price-doc-forming-gds-sum.pdf-id     = buf_price-doc-forming-gds.pdf-id and
                                buf_price-doc-forming-gds-sum.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                                buf_price-doc-forming-gds-sum.plt-id     = buf_price-doc-forming-gds.plt-id
                                :
                                find first  next_price-doc-forming-gds-sum no-lock  where
                                            next_price-doc-forming-gds-sum.stts       = integer({&pdf-new}) and
                                            next_price-doc-forming-gds-sum.b-code     = buf_price-doc-forming-gds.b-code and
                                            next_price-doc-forming-gds-sum.pdf-db     = buf_price-doc-forming-gds.pdf-db and
                                            next_price-doc-forming-gds-sum.pdf-id     = buf_price-doc-forming-gds.pdf-id and
                                            next_price-doc-forming-gds-sum.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                                            next_price-doc-forming-gds-sum.plt-id     = buf_price-doc-forming-gds.plt-id and
                                            next_price-doc-forming-gds-sum.ssg-summa  > buf_price-doc-forming-gds-sum.ssg-summa
                                            use-index pi no-error .

                                run create-price-all in this-procedure
                                    (input {&bef-mpl-sum}
                                    ,input buf_price-doc-forming-gds.plt-id
                                    ,input buf_price-doc-forming-gds.plt-db-num
                                    ,input buf_price-doc-forming-gds.pdf-id
                                    ,input buf_price-doc-forming-gds.pdf-db
                                    ,input buf_price-doc-forming-gds.b-code
                                    ,input buf_bar-code.gds-code
                                    ,input v-type-price
                                    ,input ?   /* qnty */
                                    ,input ?
                                    ,input buf_price-doc-forming-gds-sum.ssg-summa /* sum */
                                    ,input ( if available next_price-doc-forming-gds-sum then next_price-doc-forming-gds-sum.ssg-summa  else ? )
                                    ,input ? /* tnv */
                                    ,input ?
                                    ,input v-fact-order-shift-from
                                    ,input v-fact-order-shift-to
                                    ,input v-fact-order-sys-from
                                    ,input v-fact-order-sys-to
                                    ,input buf_price-doc-forming-gds-sum.price-sale-doc
                                  ) no-error .
                                  if error-status :error then do:
                                    run write-log-and-file in p-log-handle (
                                          input 1
                                        , input log-file-name
                                        , input 1
                                        , input substitute("Создание ДЭН (create-price-all ) привязка по сумме ...&1 &2",error-status :get-message(1),return-value)).
                                      return error return-value .
                                  end.
                        end.

                  end.
                  if buf_price-list-type.have-rs-turn-group = 1 then do:
                        for each buf_price-doc-forming-gds-tnv no-lock  where
                                buf_price-doc-forming-gds-tnv.stts       = integer({&pdf-new}) and
                                buf_price-doc-forming-gds-tnv.b-code     = buf_price-doc-forming-gds.b-code and
                                buf_price-doc-forming-gds-tnv.pdf-db     = buf_price-doc-forming-gds.pdf-db and
                                buf_price-doc-forming-gds-tnv.pdf-id     = buf_price-doc-forming-gds.pdf-id and
                                buf_price-doc-forming-gds-tnv.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                                buf_price-doc-forming-gds-tnv.plt-id     = buf_price-doc-forming-gds.plt-id
                                :
                                find first  next_price-doc-forming-gds-tnv no-lock  where
                                            next_price-doc-forming-gds-tnv.stts       = integer({&pdf-new}) and
                                            next_price-doc-forming-gds-tnv.b-code     = buf_price-doc-forming-gds.b-code and
                                            next_price-doc-forming-gds-tnv.pdf-db     = buf_price-doc-forming-gds.pdf-db and
                                            next_price-doc-forming-gds-tnv.pdf-id     = buf_price-doc-forming-gds.pdf-id and
                                            next_price-doc-forming-gds-tnv.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                                            next_price-doc-forming-gds-tnv.plt-id     = buf_price-doc-forming-gds.plt-id and
                                            next_price-doc-forming-gds-tnv.ttg-summa   > buf_price-doc-forming-gds-tnv.ttg-summa
                                            use-index pi no-error .

                                run create-price-all in this-procedure
                                    (input {&bef-mpl-tnv}
                                    ,input buf_price-doc-forming-gds.plt-id
                                    ,input buf_price-doc-forming-gds.plt-db-num
                                    ,input buf_price-doc-forming-gds.pdf-id
                                    ,input buf_price-doc-forming-gds.pdf-db
                                    ,input buf_price-doc-forming-gds.b-code
                                    ,input buf_bar-code.gds-code
                                    ,input v-type-price
                                    ,input ?  /* qnty */
                                    ,input ?
                                    ,input ? /* sum */
                                    ,input ?
                                    ,input buf_price-doc-forming-gds-tnv.ttg-summa  /* tnv */
                                    ,input ( if available next_price-doc-forming-gds-tnv then next_price-doc-forming-gds-tnv.ttg-summa  else ? )
                                    ,input v-fact-order-shift-from
                                    ,input v-fact-order-shift-to
                                    ,input v-fact-order-sys-from
                                    ,input v-fact-order-sys-to
                                    ,input buf_price-doc-forming-gds-tnv.price-sale-doc
                                      ) no-error .
                                  if error-status :error then do:
                                    run write-log-and-file in p-log-handle (
                                          input 1
                                        , input log-file-name
                                        , input 1
                                        , input substitute("Создание ДЭН (create-price-all ) привязка по обороту ...&1 &2",error-status :get-message(1),return-value)).
                                      return error return-value .
                                  end.
                        end.
                  end.
               end.
  end.

define variable v-pl-recid as recid no-undo .
define variable v-list-recid as character no-undo .
define variable vv as integer   no-undo .
define variable i  as integer   no-undo .
define variable v-stat-mode as character no-undo .
define buffer buf_price-doc for ub.price-doc  .
define buffer ch_price-list-type for ub.price-list-type  .

 overval-err = false .
 overval-err-str = "" .
/* Создание переоценок */
if buf_price-list-type.create-price-doc = integer(true) then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Создание переоценок ...")).
end.

/* уже есть*/
for each buf_price-doc no-lock  where
         buf_price-doc.pdf-db     = buf_price-doc-forming.pdf-db and
         buf_price-doc.pdf-id     = buf_price-doc-forming.pdf-id and
         buf_price-doc.plt-db-num = buf_price-doc-forming.plt-db-num and
         buf_price-doc.plt-id     = buf_price-doc-forming.plt-id :
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute("уже Готова переоценка &1 в статусе &2 ",buf_price-doc.doc-num,buf_price-doc.status_)).

end.
/* список объектов */
  run metod-gop-obj in this-procedure ( v-cntxt-db-num, buf_price-list-type.gop-id , buf_price-list-type.gop-db-num) no-error .
  if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("список объектов ...&1 &2   текущая БД:&3    gop-id:&4   gop-db-num:&5",error-status :get-message(1),return-value,v-cntxt-db-num, buf_price-list-type.gop-id , buf_price-list-type.gop-db-num)).
        return error return-value .
  end.
/* Уберем исключения пользователя */
  run metod-delobj-usr in this-procedure (
    buf_price-doc-forming.pdf-id ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id ,
    buf_price-doc-forming.plt-db-num
    ) .

if p-esc-prd = true then do:
   for each x_obj-group  where
            x_obj-group.obj-type = p-ecs-type and
            x_obj-group.obj-code = p-ecs-code  :
   delete x_obj-group.
   end.
end.


/* Уберем для УБД чужие объекты  */
/* Переоценки создающиеся в статусе факт можно создавать только в своей БД , так что для них тоже уберем чужие  */
if v-cntxt-db-num <> 0 or p-action = "cost-price-act" then do:
   for each x_obj-group  :
    { gbl/objdbnum.i
    x_obj-group.obj-type
    x_obj-group.obj-code
    o-db-num
    }
    if o-db-num <> v-cntxt-db-num then do:
       delete x_obj-group.
    end.
   end.
end.

/* только для главных ТПЛ и если явно указано что создавать */
if buf_price-list-type.main = true then do:
  run create-price-list-mpl in this-procedure
  (   input  buf_price-doc-forming.pdf-db ,
      input  buf_price-doc-forming.pdf-id ,
      input  buf_price-doc-forming.plt-db-num ,
      input  buf_price-doc-forming.plt-id ,
      output v-pl-recid ,
      output v-list-recid
      ) no-error .
      if error-status :error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("create-price-list-mpl ...&1 &2   ",error-status :get-message(1),return-value)).
          return error return-value .
      end.
      vv = num-entries (v-list-recid).
      repeat i = 1 to vv :

        find first buf_price-doc no-lock where recid(buf_price-doc) = integer ( entry (i,v-list-recid)) no-error .
        if available buf_price-doc then do:

            case p-action :
              when {&fact} then do:
                  v-stat-mode = "close-act" /* закрыть до акта пройдя по всем статусам */  .
                  if v-cntxt-db-num = 0  then do:
                      { gbl/objdbnum.i
                        buf_price-doc.obj-type
                        buf_price-doc.obj-code
                        o-db-num
                      }
                        if o-db-num <> 0 then do:
                          v-stat-mode = "close"     /* закрыть до сл статуса чтоб ушло по новостям */  .
                        end.
                  end.
              end.
              when "cost-price-act"  then do:
                  v-stat-mode = "act" /* проставить акт  */  .
              end.
              otherwise do:
                  v-stat-mode = "close"     /* закрыть до сл статуса*/  .
              end.
            end case.
            find first buf_price-doc exclusive-lock where recid(buf_price-doc) = integer ( entry (i,v-list-recid) ) no-error .
            assign
              buf_price-doc.out-code  = buf_price-doc-forming.out-code
            .
            if trim(buf_price-doc-forming.name,"@") <> "" then
                    buf_price-doc.PS  =  trim ( buf_price-doc-forming.name,"@" ) .
            
            varoldstatus = buf_price-doc.status_.
            { gbl/curshift.i
                buf_price-doc.obj-type
                buf_price-doc.obj-code
                varshift-date
                varshift-num
                varshift-name
                no-error
              }
            run str/pr-stat.p
              ( input parParentProc
              , input p-log-handle
              , input v-stat-mode              /* p-mode    */
              , input buf_price-doc.doc-num    /* p-doc-num */
              , input buf_price-doc.out-code   /* связь с накладной  */
              , input p-ask-pr                 /* молча */
              , input p-do                     /* оптим */
              ) no-error .
              if error-status :error then do:
                 v-mess = substitute("Ошибка закрытия переоценки N &3...&1 &2   ",error-status :get-message(1),return-value, buf_price-doc.doc-num). 
                  run write-log-and-file in p-log-handle (
                        input 1
                      , input log-file-name
                      , input 1
                      , input v-mess ).
                overval-err = true .
                overval-err-str = overval-err-str + return-value + " №" + buf_price-doc.doc-num + " " .
                if available (buf_price-doc)
                then do:
                  v-vid-action = 57 .
                  v-vid-param = "Initiator=" + v-initiator + {&delim-par} +
                                "SHOP_NUM=" + string(buf_price-doc.obj-code) + {&delim-par} +
                                "DocNum=" + string(buf_price-doc.doc-num) + {&delim-par} +
                                "DocType=" + "Переоценка" + {&delim-par} +
                                "FactDate=" + (if string(buf_price-doc.fact-date) = ? then '' else string(buf_price-doc.fact-date)) + {&delim-par} +
                                "ShiftNum=" + (if string(buf_price-doc.shift-num) = ? then '' else string(buf_price-doc.shift-num)) + {&delim-par} +
                                "ShiftDate=" + (if string(buf_price-doc.shift-date) = ? then '' else string(buf_price-doc.shift-date)) + {&delim-par} +
                                "ShiftNumCurr=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + {&delim-par} +
                                "ShiftDateCurr=" + (if string(varshift-date) = ? then '' else string(varshift-date)) + {&delim-par} +
                                "StatusOld=" + varoldstatus + {&delim-par} +
                                "StatusNew=" + string(buf_price-doc.status_) + {&delim-par} +
                                "RESULT=1" + {&delim-par} + 
                                "Description=" + v-mess.
                  
                  run trg/userlog.p (
                        input {&nwsdochs_action_update_err}
                      , input {&table_price-doc}
                      , input ( buffer buf_price-doc :handle )
                      , input v-vid-action
                      , input v-vid-param
                  ) no-error.
                end.
                return error return-value + {&new-line} + v-mess .
                
              end.
              find current buf_price-doc no-lock no-error .
              if available buf_price-doc then do:
                  run write-log-and-file in p-log-handle (
                        input 1
                      , input log-file-name
                      , input 1
                      , input substitute("Готова переоценка &1 в статусе &2 ",buf_price-doc.doc-num,buf_price-doc.status_)).
                  v-vid-action = 57 .
                  v-vid-param = "Initiator=" + v-initiator + {&delim-par} +
                                "SHOP_NUM=" + string(buf_price-doc.obj-code) + {&delim-par} +
                                "DocNum=" + string(buf_price-doc.doc-num) + {&delim-par} +
                                "DocType=" + "Переоценка" + {&delim-par} +
                                "FactDate=" + (if string(buf_price-doc.fact-date) = ? then '' else string(buf_price-doc.fact-date)) + {&delim-par} +
                                "SHIFT_NUM_DOC=" + (if string(buf_price-doc.shift-num) = ? then '' else string(buf_price-doc.shift-num)) + (if string(buf_price-doc.shift-date) = ? then '' else string(buf_price-doc.shift-date, "99999999")) + {&delim-par} +
                                "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + {&delim-par} +
                                "StatusOld=" + varoldstatus + {&delim-par} +
                                "StatusNew=" + string(buf_price-doc.status_) + {&delim-par} +
                                "RESULT=" + {&delim-par} + 
                                "Description=" no-error.
                  
                  find last ub.c-price-doc no-lock where ub.c-price-doc.doc-num = buf_price-doc.doc-num no-error.   
                  if available (ub.c-price-doc)
                  then do:
                    run trg/userlog.p (
                          input {&nwsdochs_action_update}
                        , input {&table_c-price-doc}
                        , input ( buffer ub.c-price-doc :handle )
                        , input v-vid-action
                        , input v-vid-param
                    ) no-error.
                  end.
              
              end.

        end.
      end.
      if overval-err = false then do:
          run str/pdfdisca.p (
              input parParentProc,
              input recid(buf_price-doc-forming),
              input p-log-handle ,
              input log-file-name
              ) no-error.
              if error-status :error then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute("Ошибка формирования автоматических ДНЦ в момент закрытия  ДНЦ ГТПЛ  &1 &2 ",error-status :get-message(1),return-value )).
                undo, return error return-value .
              end.
              /*Закрытые на АКТ переоценки  */
              for each buf_price-doc no-lock where
                       buf_price-doc.pdf-id  = buf_price-doc-forming.pdf-id and
                       buf_price-doc.pdf-db  = buf_price-doc-forming.pdf-db and
                       buf_price-doc.plt-id  = buf_price-doc-forming.plt-id and
                       buf_price-doc.plt-db  = buf_price-doc-forming.plt-db and
                       buf_price-doc.status_ = {&act-overvalue}
              :
              /* Процедура закрытия на АКТ скидочных ДНЦ по Атрибутам закрытой переоценки  */
                  /* message buf_price-doc.doc-num 'По этим нужно запустить закрытие скидочного ДНЦ' . */
                  run str/pdfdiscl.p ( Parparentproc , buf_price-doc.doc-num ) no-error .
                  if error-status :error then do:
                      if return-value = 'no-records'  then do:
                      message
                        error-status :get-message(1) skip
                        "Нет ни одной записи!"
                        view-as alert-box error
                      .
                      undo, return error "Ошибка при закрытиии порожденных ДНЦ. Нет записей ." .
                      end.
                      else do:
                      message
                        vss-workfile vss-revision vss-description skip
                        error-status :get-message(1) skip
                        return-value skip
                        "pdfdiscl"
                        view-as alert-box error
                      .
                      undo, return error "Ошибка при закрытиии порожденных ДНЦ." + return-value .
                      end.
                  end.
              end.
      end.
end.

/* Проставление статуса ЗАКРЫТО в ДНЦ */
if overval-err = true then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка закрытия переоценки  &3...&1 &2   ",error-status :get-message(1),return-value, overval-err-str)).
    return error overval-err-str .
end.
else do:
    assign
      buf_price-doc-forming.stts = integer({&pdf-fact})
    .
     release buf_price-doc-forming no-error . /* !!! */

     find first buf_price-doc-forming exclusive-lock where recid ( buf_price-doc-forming ) = p-recid no-error .

    /* Отправка на кассы , если нужно */
    define variable v-ask  as logical   no-undo init false .

    { gbl/a-nwspdf.i
      buf_price-doc-forming.plt-id
      buf_price-doc-forming.plt-db-num
      buf_price-doc-forming.pdf-id
      buf_price-doc-forming.pdf-db
      v-ask
    }

    if v-ask then do: /* Нужно отправлять */
      run str/diallog.w
              ( input parparentproc
              , input p-log-handle
              , input 'str/sendpdfr.p':U
              , input ("U":U + {&delim-par} +
                      string(buf_price-doc-forming.plt-id) + {&delim-par}  +
                      string(buf_price-doc-forming.plt-db-num) + {&delim-par} +
                      string(buf_price-doc-forming.pdf-id) + {&delim-par}  +
                      string(buf_price-doc-forming.pdf-db)
                      )
              , input yes /*p-auto-go*/
              , input '':U
              , input '') no-error .
    end.
 end.


   /* Создание и закрытие подчиненных ПДФ */
   if  can-find ( first ch_price-list-type no-lock where
                        ch_price-list-type.stts            = integer({&pdf-new}) and
                        ch_price-list-type.plt-main-id     = buf_price-list-type.plt-id and
                        ch_price-list-type.plt-main-db-num = buf_price-list-type.plt-db-num ) then do:
        run str/cr-chpdf.p
            ( parparentproc ,
              p-recid ,
              p-action ,
              p-trn-doc ,
              p-ask-pr  ) no-error .
              if error-status :error then do:
                  run write-log-and-file in p-log-handle (
                        input 1
                      , input log-file-name
                      , input 1
                      , input substitute("Создание и закрытие подчиненных ДНЦ ...&1 &2   ",error-status :get-message(1),return-value)).
              end.
   end.

procedure exp-prt :
define input  param g-code  like ub.goods.gds-code    no-undo.
define input  param old-num like ub.price-doc.doc-num no-undo.
define input  param new-num like ub.price-doc.doc-num no-undo.
define output param new-rec as recid               no-undo.

end procedure.

procedure dfc-create-date :
define variable v-shift-date as date      no-undo .
define variable v-shift-num  as integer   no-undo .
define variable v-shift-name as character no-undo .
define variable v-obj-date   as date      no-undo .
define variable l-shift-on as logical   no-undo .
  do
  on error undo, return error return-value
  :

{ gbl/curobjdt.i
  v-cntxt-obj-type
  v-cntxt-obj-code
  v-obj-date
  no-error}
  if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("curobjdt: &1 &2 объект &3&4  " , error-status :get-message(1),return-value,v-cntxt-obj-type, v-cntxt-obj-code )).

  end.
  /*если об сменный   */
{ gbl/objat.i
  v-cntxt-obj-type
  v-cntxt-obj-code
  "'shift-on=request':U"
  l-shift-on
  no-error
}
  if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("objat: &1 &2 объект &3&4" , error-status :get-message(1),return-value,v-cntxt-obj-type, v-cntxt-obj-code )).
  end.

if l-shift-on then do:
  { gbl/curshift.i
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-shift-date
    v-shift-num
    v-shift-name
    no-error }
  if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("curshift: &1 &2 объект &3&4" , error-status :get-message(1),return-value,v-cntxt-obj-type, v-cntxt-obj-code )).
  end.
end.

   if buf_price-doc-forming.have-start-period = integer( false ) then do:
      case buf_price-list-type.work-date :
          when int({&mpl-date-obj})    /* дата на обкт */ then
            do :
               buf_price-doc-forming.start-date = v-obj-date .
            end.
          when int({&mpl-date-shift})  /* сменная дата */ then
            do :
                 assign
                    buf_price-doc-forming.start-shift-date  = v-shift-date
                    buf_price-doc-forming.start-shift-num   = v-shift-num
                    buf_price-doc-forming.start-shift-name  = v-shift-name
                    .
            end.
          when int({&mpl-date-sys})    /* дата сервера */ then
            do :
                buf_price-doc-forming.start-sys-date = today .
            end.
      end case.
      buf_price-doc-forming.start-sys-time = time .
   end.
  end.
end procedure. /* dfc-create-date */



procedure dfc-pr-good :
  do
  on error undo, return error return-value
  :

    define variable v-type-goods as integer   no-undo .
    define variable i as integer   no-undo .
    define variable is-petrolium as logical   no-undo .
    define variable is-pieces    as logical   no-undo .
    define variable v-next as logical   no-undo .

    if par-pr-goods = "" or num-entries (par-pr-goods,".") <> 2 then v-type-goods = integer({&pr-gds-ino-ban}) .
    repeat i = 1 to 8 :
      if par-pr-goods begins string(i) + "."  then  do:
        v-type-goods = i .
        leave.
      end.
    end.
 /*  define variable v-errstr as character no-undo . */ 
  v-errstr = "" .


      for each buf_price-doc-forming-gds  where
               buf_price-doc-forming-gds.pdf-id = buf_price-doc-forming.pdf-id and
               buf_price-doc-forming-gds.pdf-db = buf_price-doc-forming.pdf-db and
               buf_price-doc-forming-gds.plt-id = buf_price-doc-forming.plt-id and
               buf_price-doc-forming-gds.plt-db = buf_price-doc-forming.plt-db
      :
        find first buf_goods no-lock
          where buf_goods.artic     = buf_price-doc-forming-gds.artic
            and buf_goods.prod-type = buf_price-doc-forming-gds.prod-type
            and buf_goods.prod-code = buf_price-doc-forming-gds.prod-code
          no-error .
   { str/is-petrl.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      is-petrolium
      is-pieces
    }

  /* Исключение из Запрета */
  if g#esys
  then do :
    v-next = true .
  end.
  else do :
    run ver-pr-nogds ( input  buf_goods.gds-code , input par-pr-nogds, output v-next , output v-errstr ) .
  end.
  if not v-next then do:

    case string(v-type-goods) :
    when {&pr-gds-iban}       then do:
      v-errstr = "Запрет на включение в переоценку товаров, услуг и топлива." .
            return error v-errstr .
    end.
    when {&pr-gds-igoods}     then do:
        if buf_goods.gds-type = {&gds-goods}  and is-petrolium = false  then do:
          v-errstr = substitute("Запрет на добавление товаров в переоценку. " , buf_goods.artic, buf_goods.gds-name, buf_goods.gds-type ) .
            return error v-errstr .
        end.
    end.
    when {&pr-gds-ipetrol}    then do:
        if is-petrolium then do:
           v-errstr = substitute("Запрет на добавление топлива в переоценку. " , buf_goods.artic, buf_goods.gds-name ) .
            return error v-errstr .

        end.
    end.
    when {&pr-gds-iserv}      then do:
        if buf_goods.gds-type = {&gds-office} then do:
           v-errstr = substitute("Запрет на добавление услуг в переоценку. " , buf_goods.artic, buf_goods.gds-name, buf_goods.gds-type ) .
            return error v-errstr .

        end.
    end.
    when {&pr-gds-igds-serv}  then do:
        if buf_goods.gds-type = {&gds-goods} and is-petrolium = false  then do:
           v-errstr = substitute("Запрет на добавление товаров и услуг в переоценку. " , buf_goods.artic, buf_goods.gds-name, buf_goods.gds-type , buf_goods.unit-base ) .
            return error v-errstr .
        end.
        if buf_goods.gds-type = {&gds-office} then do:
           v-errstr = substitute("Запрет на добавление товаров и услуг в переоценку. " , buf_goods.artic, buf_goods.gds-name, buf_goods.gds-type ) .
            return error v-errstr .
        end.
    end.
    when {&pr-gds-igds-ptrl}  then do:
        if buf_goods.gds-type <> {&gds-office}  then do:
           v-errstr = substitute("Запрет на добавление топлива и товара в переоценку. " , buf_goods.artic, buf_goods.gds-name, buf_goods.gds-type, buf_goods.unit-base ) .
            return error v-errstr .
        end.
    end.
    when {&pr-gds-iserv-ptrl} then do:
        if buf_goods.gds-type = {&gds-goods} and is-petrolium = true   then do:
          v-errstr = substitute("Запрет на добавление услуг и топлива в переоценку. " , buf_goods.artic, buf_goods.gds-name, buf_goods.unit-base ) .
            return error v-errstr .
        end.
        if buf_goods.gds-type = {&gds-office} then do:
           v-errstr = substitute("Запрет на добавление услуг и топлива в переоценку. " , buf_goods.artic, buf_goods.gds-name, buf_goods.gds-type ) .
            return error v-errstr .
        end.
    end.
  end case.
  end.

end.

  end.

end procedure. /* dfc-pr-good */