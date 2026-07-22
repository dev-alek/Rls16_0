block-level on error undo, throw.
/*

$Revision: c76f4a5df326, 143, rls $
$Author: ASMorozov $
$Date: Mon Feb 16 20:48:31 2015 +0400 $
$Workfile: fix-atgo.p $
$Archive: adm/fix-atgo.p $

Утилита проверки/инициализации атрибутов товара на объекте

Автор: Комаров Иван Сергеевич
Дата создания: 02/11/10
Author: Komarov Ivan
Creation date: 02/11/10

*/

define input parameter p-forced as logical no-undo .
define input parameter p-read-only as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: c76f4a5df326, 143, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:48:31 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fix-atgo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/fix-atgo.p $":U .
define variable vss-description as character no-undo init "Утилита проверки/инициализации параметров при запуске ТН".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/lib-trn.i  }
{ ref/gds-attr.i }
{ cmp/trg-def.i  }


do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-is-petrol  as logical    no-undo.
  define variable v-is-pieces  as logical    no-undo.
  define variable v-value      as character  no-undo.
  define variable v-type       as character  no-undo.

  define buffer buf_goods   for ub.goods .



  do transaction
  on error  undo, return error substitute( "&1 (sys-key). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (sys-key). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (sys-key). endkey", vss-workfile )
  :

  if ( g#db-num = 0 ) then do:

    /* перенос норм естественной убыли */
    for each buf_goods
       where buf_goods.normal-wastage <> 0
       no-lock :
  
        { str/is-petrl.i
            buf_goods.artic
            buf_goods.prod-type
            buf_goods.prod-code
            v-is-petrol
            v-is-pieces
        }
        if  v-is-petrol = yes
        and v-is-pieces = no
        then do : /* проверим на ТНП через ТРК */
          run gds-attr-value in this-procedure (
                                           input buf_goods.gds-code
                                          ,input {&attr-ptrl-as-good}
                                          ,output v-value
                                          ,output v-type) no-error.
          if NOT logical(v-value) then do: /* нет атрибута */
            if p-read-only = false then do:
              run adm/initnwas.p
                  ( input buf_goods.artic ,
                    input buf_goods.prod-type ,
                    input buf_goods.prod-code
                  ) no-error .
              if error-status :error then do:
                return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ).
              end.
            end.
            else do:
              return error substitute("До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!") .
            end.
          end.
        end.
    end.
  end.
  
  /* Перенесем атрибут Платеж Сотовой связи в Тип услуги */
  &glob attr-is-oss-payment 'is-oss-payment'
  
  /* удалим без запуска в новости на каждой базе */
  disable triggers for load of ub.goods-attr.
  
  define buffer bf_goods-attr-1 for ub.goods-attr.
  define buffer bf_goods-attr-2 for ub.goods-attr.
  
  for each bf_goods-attr-1 exclusive-lock
    where bf_goods-attr-1.attr-code = {&attr-is-oss-payment}:
    
    find first bf_goods-attr-2 exclusive-lock
      where bf_goods-attr-2.gds-code = bf_goods-attr-1.gds-code
      and bf_goods-attr-2.attr-code = {&attr-office-type}
      no-error.
    
    if not available bf_goods-attr-2 then
      create bf_goods-attr-2.
      
    assign
      bf_goods-attr-2.gds-code = bf_goods-attr-1.gds-code
      bf_goods-attr-2.whole-send-news = bf_goods-attr-1.whole-send-news
      bf_goods-attr-2.attr-code = {&attr-office-type}
      bf_goods-attr-2.attr-value = {&attr-office-type_oss-pay}
    .
    release bf_goods-attr-2.
    
    delete bf_goods-attr-1.
  end.
  
end.
end.