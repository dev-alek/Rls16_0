block-level on error undo, throw.
/*

$Revision: 0100a4d3b790, 1441, test $
$Author: SMMolotkov $
$Date: Fri Jun 29 18:00:05 2018 +0300 $
$Workfile: exp-doc2.p $
$Archive: utl/exp-doc2.p $

Выгрузка остатков в формате импорта ПН

Автор: Молотков Сергей
Дата создания: 05/03/18
Author: Molotkov Sergey
Creation date: 05/03/18

*/
define input  parameter parparentproc as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 0100a4d3b790, 1441, test $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 29 18:00:05 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-doc2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/exp-doc2.p $":U .
define variable vss-description as character no-undo init "Выгрузка остатков в формате импорта ПН".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
/*{ rep/ostatok.i }*/
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cmp/library.i }
{ str/lib-trn.i }
{ gbl/waitfram.i }

define variable g-log        as logical no-undo .
define variable v-dir-name   as character no-undo .
define variable v-type       as character no-undo .
define variable v-can-write  as logical   no-undo .
define variable c_shift-list as character no-undo .
define variable r_shift-obj  as recid no-undo .
define variable f-name       as character no-undo .
define variable v-shift-start-fact-order  as decimal no-undo .
define variable is-petrolium as logical   no-undo . /* для типа товара */
define variable is-pieces    as logical   no-undo . /* для типа товара */
define variable v-unit-base  as character no-undo .
define variable v-host-code  as integer   no-undo . /* код фирмы */
define variable v-vat-tax-value as decimal no-undo .
define variable v-sum-rubl   as decimal no-undo .
define variable v-fact-qnty  as decimal no-undo .
define variable v-wait-msg   as character no-undo .
define variable v-lines      as integer no-undo .
define variable v-ln-prev    as integer no-undo .
define variable v-tm-prev    as integer no-undo .
define buffer buf_shift-obj for ub.shift-obj .
define buffer buf_gds-obj   for ub.gds-obj .
define buffer buf_goods     for ub.goods .
define buffer buf-stk-line  for ub.stk-line .
define buffer buf_tax-rate-gds   for ub.tax-rate-gds .
define buffer buf_tax-rate-value for ub.tax-rate-value .
define stream f-txt .


g-log = no.
message "Выгрузка остатков в формате импорта ПН" skip (2)
        "Продолжать ?"
        view-as alert-box question buttons OK-Cancel update g-log.
if not g-log then return.


/* Куда будем сохранять файлы */
run gbl/dir-sel.p
     ( output v-dir-name
      ,output v-type
      ,output v-can-write
      ).
if NOT v-can-write THEN DO:
  message
      "Путь для сохранения файлов не указан."
      view-as alert-box error.
  return.
END.


  /* выбор смены: скопировано с bge/e-exp-atd.w */
  c_shift-list = "".
  run str/sht-all.w
    ( parparentproc
    , ? /* v-cntxt-obj-type */
    , ? /* v-cntxt-obj-code */
    , "b-sel"
    , "all"
    ,  v-cntxt-obj-type
    ,  v-cntxt-obj-code
    ,  ""
    ,  input-output c_shift-list
    ) no-error.
    if error-status:error then do:
      message
            vss-workfile vss-revision vss-description skip
            "Ошибка при выборе смены"  skip
            error-status :get-message( 1 ) skip
            return-value skip
            view-as alert-box error .
      return.
    end.
    if c_shift-list = "":U then do:
      message
        "Смена не выбрана"
      view-as alert-box error.
      return.
    end.
    
    r_shift-obj = integer(c_shift-list) no-error .
    find first buf_shift-obj no-lock where recid (buf_shift-obj) = r_shift-obj no-error .
    if available buf_shift-obj then
      f-name = substitute("&1\&2&3_&4&5&6_&7.adb", v-dir-name,
       buf_shift-obj.obj-type, buf_shift-obj.obj-code,
       year(buf_shift-obj.shift-date), month(buf_shift-obj.shift-date), day(buf_shift-obj.shift-date),
       buf_shift-obj.shift-num)
    no-error .
    if error-status:error then do:
      message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске смены"  skip
            error-status :get-message( 1 ) skip
            return-value skip
            view-as alert-box error .
      return.
    end.

    
    /* fact-order на начало периода;
       скопировано из rep/ostatok.i */
    define buffer buf_stk-tot for ub.stk-tot .
    find last buf_stk-tot no-lock
        where buf_stk-tot.obj-type = buf_shift-obj.obj-type
          and buf_stk-tot.obj-code = buf_shift-obj.obj-code
          and buf_stk-tot.shift-date = buf_shift-obj.shift-date
          and buf_stk-tot.shift-num  < buf_shift-obj.shift-num
          and buf_stk-tot.shift-num  > 0
          and buf_stk-tot.sum-type = {&arh-crsa}
          and buf_stk-tot.cat-id   = {&root-cat-id}
    USE-INDEX Shift-num no-error .
    if not available buf_stk-tot then do:
    find last buf_stk-tot no-lock
        where buf_stk-tot.obj-type = buf_shift-obj.obj-type
          and buf_stk-tot.obj-code = buf_shift-obj.obj-code
          and buf_stk-tot.shift-date < buf_shift-obj.shift-date
          and buf_stk-tot.shift-num  > 0
          and buf_stk-tot.sum-type = {&arh-crsa}
          and buf_stk-tot.cat-id   = {&root-cat-id}
      USE-INDEX Shift-num no-error .
    end.
    if available buf_stk-tot then v-shift-start-fact-order = buf_stk-tot.Fact-order .
    else do:
      message
        substitute( "Для смены &1 от &2 по объекту &3&4 отсуствуют предшествующие остатки"
                  , buf_shift-obj.shift-num
                  , buf_shift-obj.shift-date
                  , buf_shift-obj.obj-type, buf_shift-obj.obj-code
        )
      view-as alert-box error .
      return .
    end .

    /* host-code используется для менее точного поиска ставки НДС на товаре */
    {gbl/hostcode.i buf_shift-obj.obj-type buf_shift-obj.obj-code v-host-code}
  
    assign
      v-wait-msg = "Выгрузка в файл " + f-name + " строк: &1"
      v-lines    = 0
      v-ln-prev  = v-lines + 100
      v-tm-prev  = time + 1
    .
    run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
    
    /* выгрузка таблицы в файл */
    output stream f-txt to value (f-name) .
  
    
    for each buf_gds-obj no-lock
       where buf_gds-obj.obj-type = buf_shift-obj.obj-type
         and buf_gds-obj.obj-code = buf_shift-obj.obj-code :

      /* Остатки выводить по всем товарам кроме топлива. */
      { str/is-petrl.i
          buf_gds-obj.artic
          buf_gds-obj.prod-type
          buf_gds-obj.prod-code
          is-petrolium
          is-pieces
      }
      if is-petrolium then next .
      
      v-lines = v-lines + 1 .
      if v-lines > v-ln-prev then do:
        v-ln-prev = v-lines + 100.
        if v-tm-prev < time then do:
          v-tm-prev  = time + 1 .
          run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
        end .
      end.
      
      /* остатки по fact-order, предшествующие началу периода;
         скопировано из rep/ost-line.i */
      find last buf-stk-line no-lock
          where buf-stk-line.obj-type = buf_gds-obj.obj-type
            and buf-stk-line.obj-code = buf_gds-obj.obj-code
            and buf-stk-line.artic     = buf_gds-obj.artic
            and buf-stk-line.prod-type = buf_gds-obj.prod-type
            and buf-stk-line.prod-code = buf_gds-obj.prod-code
            and buf-stk-line.sum-type = {&arh-cost}
            and buf-stk-line.cat-id   = {&root-cat-id}
            and buf-stk-line.fact-order <= v-shift-start-fact-order
            and buf-stk-line.shift-num  > 0
      use-index category no-error .
      if available buf-stk-line then assign
        v-sum-rubl  = buf-stk-line.sum-rubl
        v-fact-qnty = buf-stk-line.fact-qnty
      .
      else assign
        v-sum-rubl  = 0
        v-fact-qnty = 0
      .
      
      /*      
      find first buf_goods no-lock where buf_goods.gds-code = buf_gds-obj.gds-code no-error.
      v-unit-base = if available buf_goods then buf_goods.unit-base else "" .
      */

      /* ----- найти ставку НДС ----- */      
      /* скопировано из bge/bge-exp-sap.p */
      find last buf_tax-rate-gds no-lock
          where buf_tax-rate-gds.gds-code  = buf_gds-obj.gds-code
            and buf_tax-rate-gds.tax-code  = {&bef-vat-tax-code}
            and buf_tax-rate-gds.host-code = v-host-code
            and buf_tax-rate-gds.obj-type  = buf_shift-obj.obj-type
            and buf_tax-rate-gds.obj-code  = buf_shift-obj.obj-code
            and buf_tax-rate-gds.fact-order <= v-shift-start-fact-order no-error .
      if not available buf_tax-rate-gds then
      find last buf_tax-rate-gds no-lock
          where buf_tax-rate-gds.gds-code  = buf_gds-obj.gds-code
            and buf_tax-rate-gds.tax-code  = {&bef-vat-tax-code}
            and buf_tax-rate-gds.host-code = 0
            and buf_tax-rate-gds.obj-type  = ''
            and buf_tax-rate-gds.obj-code  = 0
            and buf_tax-rate-gds.fact-order <= v-shift-start-fact-order no-error.
      if available buf_tax-rate-gds then do:
        /* скопировано из library.p::pftaxval(), т.к. оригинальный pftaxval() используетс свой fact-order */ 
        find last buf_tax-rate-value no-lock
            where buf_tax-rate-value.tax-code  = buf_tax-rate-gds.tax-code
              and buf_tax-rate-value.rate-code = buf_tax-rate-gds.rate-code
              and buf_tax-rate-value.host-code = v-host-code
              and buf_tax-rate-value.obj-type  = buf_shift-obj.obj-type
              and buf_tax-rate-value.obj-code  = buf_shift-obj.obj-code
              and buf_tax-rate-value.fact-order <= v-shift-start-fact-order
              and buf_tax-rate-value.status_   = {&current-status} no-error .
        if not available buf_tax-rate-value then 
        find last buf_tax-rate-value no-lock
            where buf_tax-rate-value.tax-code  = buf_tax-rate-gds.tax-code
              and buf_tax-rate-value.rate-code = buf_tax-rate-gds.rate-code
              and buf_tax-rate-value.host-code = v-host-code
              and buf_tax-rate-value.obj-type  = ""
              and buf_tax-rate-value.obj-code  = 0
              and buf_tax-rate-value.fact-order <= v-shift-start-fact-order
              and buf_tax-rate-value.status_   = {&current-status} no-error .
        if not available buf_tax-rate-value then 
        find last buf_tax-rate-value no-lock
            where buf_tax-rate-value.tax-code  = buf_tax-rate-gds.tax-code
              and buf_tax-rate-value.rate-code = buf_tax-rate-gds.rate-code
              and buf_tax-rate-value.host-code = 0
              and buf_tax-rate-value.obj-type  = ""
              and buf_tax-rate-value.obj-code  = 0
              and buf_tax-rate-value.fact-order <= v-shift-start-fact-order
              and buf_tax-rate-value.status_   = {&current-status} no-error .
        v-vat-tax-value = if available buf_tax-rate-value then buf_tax-rate-value.rate-value else 0 .
      end .
      else v-vat-tax-value = 0 .
      /* ----- end_of найти ставку НДС ----- */
            
      put stream f-txt unformatted
          substitute("ITEM:&1;", buf_gds-obj.artic)
          /* buf_gds-obj.prod-code*/ ";"
          ";"
          ";"
          buf_gds-obj.gds-code ";"
          (if v-fact-qnty <> 0 then v-sum-rubl / v-fact-qnty else v-sum-rubl) ";"
          v-fact-qnty ";"
          /* v-unit-base */ ";"
          ";"
          ";"
          v-vat-tax-value ";"
          ";"
          ";"
          ";"
          ";"
          "" skip
      .
    end . /* end_of for_each_gds-obj */
    
    output stream f-txt close .
    
  run waitfram-hide in this-procedure .
message "Выгрузка закончена." view-as alert-box information buttons ok.
