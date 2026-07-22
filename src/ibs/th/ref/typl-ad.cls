/*

$Revision: cb37b650f92a, 1185, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:20:27 2017 +0300 $
$Workfile: typl-ad.cls $
$Archive: ibs/th/ref/typl-ad.cls $



Автор: Молотков Сергей Михайлович
Дата создания: 01/11/17
Author: Molotkov Sergey
Creation date: 01/11/17

*/

using Progress.Lang.*.
using ibs.th.gbl.gbl-var.
block-level on error undo, throw.

      
class ibs.th.ref.typl-ad: 

  { cmp/str-glbl.i class }
  
  define property ReturnMsg as character no-undo
    get.
    private set.

DEFINE TEMP-TABLE TT_cassa NO-UNDO LIKE ub.price-list-type-cassa.
DEFINE TEMP-TABLE TT_grp   NO-UNDO LIKE ub.price-list-type-gds-grp.
DEFINE TEMP-TABLE TT_pay-type NO-UNDO LIKE ub.price-list-type-pay-type.
DEFINE TEMP-TABLE TT_cash-pay NO-UNDO LIKE ub.price-list-type-cash-pay.

  define variable hndl-proc-key-rec as handle.
 
  constructor public typl-ad ():
    run ref/typl-ad.p persistent set hndl-proc-key-rec .
  end constructor.
  
  destructor public typl-ad ():
    if valid-object(hndl-proc-key-rec) then delete object hndl-proc-key-rec .
  end destructor.

  /* ========================================================================== */
  method public recid objo-add (
    input p-db-num     as integer,
    input p-id         as integer,
    input p-obj-type   as character,
    input p-obj-code   as integer,
    input p-stts       as integer,
    input p-db-num-usr as integer,
    input p-userid     as character
  ) :
    define variable v-recid as recid no-undo .
    run objo-add in hndl-proc-key-rec
      (input p-db-num
      ,input p-id
      ,input p-obj-type
      ,input p-obj-code
      ,input p-stts
      ,input p-db-num-usr
      ,input p-userid
     ,output v-recid
      ) .
    return v-recid .  
  end method. /* end_of objo-add */
  /* ========================================================================== */
  /* Добавить тип прайс-листа */
  method public void type-price-list-ADD (  
    input p-plt-id as integer,
    input p-db-num as integer,
    input p-name       as character,
    input p-ban-discnt as integer,
    input p-calc-round-method   as character,
    input p-calc-round-base     as decimal,
    input p-calc-increase-p     as decimal,
    input p-calc-method         as character,
    input p-create-price-doc    as integer,
    input p-fix-cource-crc-base as logical,
    input p-fix-cource-crc-doc  as logical,
    input p-main            as logical,
    input p-plt-main-id     as integer,
    input p-plt-main-db-num as integer,
    input p-priority        as integer,
    input p-only-gbd        as integer,
    input p-under-type-list    as integer,
    input p-under-round-method as character,
    input p-under-perc         as decimal,
    input p-under-hand-corr    as integer,
    input p-send-cassa         as integer,
    input p-use-cassa          as integer,
    input p-use-gds-group      as integer,
    input p-work-date          as integer,
    input p-curr-code          as integer,
    input p-use-cash-pay       as integer,
    input p-use-pay-type       as integer,
    input p-have-rs-qnty-group  as integer,
    input p-qgr-db-num          as integer,
    input p-qgr-id              as integer,
    input p-have-rs-sum-group   as logical,
    input p-sgr-db-num          as integer,
    input p-sgr-id              as integer,
    input p-rs-buyer            as integer,
    input p-bgr-db-num          as integer,
    input p-bgr-id              as integer,
    input p-obj-turnover        as logical,
    input p-tog-db-num          as integer,
    input p-tog-id              as integer,
    input p-ttg-summa           as decimal,
    input p-have-rs-turn-group  as integer,
    input p-have-tog-db-num     as integer,
    input p-have-tog-id         as integer,
    input p-gop-db-num          as integer,
    input p-gop-id              as integer,
    input p-use-obj             as integer,
    input p-gop-db-num-for-calc-turnover as integer,
    input p-gop-id-for-calc-turnover     as integer,
    input p-userid          as character,
    input p-db-num-usr      as integer,
   output p-recid  as recid,
    input table TT_cassa,
    input table TT_grp,
    input table TT_pay-type,
    input table TT_cash-pay
  ):
    
    
  /* скопировано из cmp/ththovr.p */
  if p-gop-id = 0 then do: /* если нет группы объектов */
    /* p.s. группы объектов всегда нет: в cmp/ththovr.p переменная p-gop-id не инициализируется,
            а из импорта магазинов всегда передаётся 0 */
    define variable v-recid as recid no-undo .
    assign
      p-gop-id = next-value ( s-gop , {&db-name_schema} )
    .

      create ub.grp-obj-price.
      assign
      ub.grp-obj-price.gop-db-num   = p-gop-db-num
      ub.grp-obj-price.gop-id       = p-gop-id
      ub.grp-obj-price.name-group   = substitute("По объекту &1&2", {&shop}, p-db-num)
      /* при импорте obj-type = строго по магазину, obj-code совпадает с номером БД */
      ub.grp-obj-price.stts         = 0 /* 0:текущий, 1:удален */
      /* str-glbl.i: status-int-name '0,1,50,99' -> 'тек,удал,блок,удаление' */
      
      /* кто последний менял запись и база данных, где произошло последнее изменение */    
      /* ! корректировать группу можно только в той БД, где произошло последнее изменение ! */
      ub.grp-obj-price.who          = gbl-var:g#userid
      ub.grp-obj-price.db-num-chg   = gbl-var:g#db-num /* при импорте = 0, т.к. мы создаём в ГБД запись об УБД */
      ub.grp-obj-price.sys-date     = today /* физическая дата последнего изменения */
      ub.grp-obj-price.sys-time     = time  /* физическое время последнего изменения */
      ub.grp-obj-price.sys-time-chr = string(ub.grp-obj-price.sys-time,"hh:mm")
      .
      v-recid = objo-add (input p-gop-db-num
                         ,input p-gop-id
                         ,input {&shop}
                         ,input p-db-num
                         ,input 0
                         ,input gbl-var:g#db-num
                         ,input gbl-var:g#userid
                         ) .
  end. /*if p-gop-id = 0 then do*/
  
  
    run type-price-list-ADD in hndl-proc-key-rec
      (input p-db-num
      ,input p-plt-id
      ,input p-name
      ,input p-ban-discnt
      ,input p-calc-round-method
      ,input p-calc-round-base
      ,input p-calc-increase-p
      ,input p-calc-method
      ,input p-create-price-doc
      ,input p-fix-cource-crc-base
      ,input p-fix-cource-crc-doc
      ,input p-have-rs-qnty-group
      ,input p-have-rs-sum-group
      ,input p-main
      ,input p-only-gbd
      ,input p-plt-main-db-num
      ,input p-plt-main-id
      ,input p-priority
      ,input p-rs-buyer
      ,input p-send-cassa
      ,input p-under-hand-corr
      ,input p-under-round-method
      ,input p-under-perc
      ,input p-under-type-list
      ,input p-use-cassa
      ,input p-use-gds-group
      ,input p-use-obj
      ,input p-work-date
      ,input p-bgr-db-num
      ,input p-bgr-id
      ,input p-curr-code
      ,input p-gop-db-num
      ,input p-gop-db-num-for-calc-turnover
      ,input p-gop-id
      ,input p-gop-id-for-calc-turnover
      ,input p-qgr-db-num
      ,input p-qgr-id
      ,input p-sgr-db-num
      ,input p-sgr-id
      ,input p-tog-db-num
      ,input p-tog-id
      ,input p-obj-turnover
      ,input p-ttg-summa
      ,input p-userid
      ,input p-db-num-usr
      ,input p-have-rs-turn-group
      ,input p-have-tog-db-num
      ,input p-have-tog-id
      ,input p-use-cash-pay
      ,input p-use-pay-type
     ,output p-recid
     , input table TT_cassa
     , input table TT_grp
     , input table TT_pay-type
     , input table TT_cash-pay
      ) .

  end method. /* end_of type-price-list-ADD */

  /* Удалить тип прайс-листа */
  method public void type-price-list-delete (  
    input p-db-num     as integer,
    input p-id         as integer,
    input p-db-num-usr as integer,
    input p-userid     as character,
    buffer child_price-list-type for ub.price-list-type
  ) :
    run type-price-list-delete in hndl-proc-key-rec
      (input p-db-num
      ,input p-id
      ,input p-db-num-usr
      ,input p-userid
      ,buffer child_price-list-type
      ).
  end method. /* end_of type-price-list-delete */


end class.
