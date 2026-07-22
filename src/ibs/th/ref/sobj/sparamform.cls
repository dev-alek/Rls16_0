 
 /*------------------------------------------------------------------------
    File        : sParamForm
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Sat Apr 04 13:28:06 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class ibs.th.ref.sobj.sParamForm: 
   { cmp\library.i class}
   define public variable init-date-start  as date no-undo .
   define public variable init-date-end    as date no-undo .
   define public variable init-date-alone  as date no-undo .
   define public variable init-shift-alone as integer  no-undo .
   define public variable init-shift-start as integer no-undo .
   define public variable init-shift-end   as integer   no-undo .
   define public variable init-set_pay_type as integer   no-undo .
   define public variable init-set_val_type as integer   no-undo .
   define public variable ref_date-start    as character   no-undo .
   define public variable ref_date-end      as character   no-undo .
   define public variable ref_date-alone    as character   no-undo .
   
   
   define public variable  Name-Sale-price   as character no-undo .  /* Название итем чекбокс по цена документов */
   define public variable  Format-Folder     as logical no-undo .      /* Есть страница с закладкой ФОРМАТ  */
   
   define public variable  Verify-Arc-ot      as logical  no-undo init false.  /* Делать или нет проверку расчета архива  */
   define public variable  Verify-Arc-stk     as logical  no-undo init false.  /* Делать или нет проверку расчета архива  */
   define public variable  Verify-Arc-supp    as logical  no-undo init false.  /* Делать или нет проверку расчета архива  */
   define public variable  Verify-Arc-hold    as logical  no-undo init false.  /* Делать или нет проверку расчета архива  */
   define public variable  Verify-Arc-aht     as logical  no-undo init false.  /* Делать или нет проверку расчета архива  */
   define public variable  Verify-send-check  as logical  no-undo init false. /* Делать или нет проверку по db.send-check  */
   define public variable  Verify-Arc-fin     as logical  no-undo init false.  /* Делать или нет проверку расчета архива  */
   define public variable  Verify-Arc-strong  as logical  no-undo init false.  /* Проверка архива жесткая, строго присутствует  */
   
   define public variable params-only      as logical   no-undo .  /* Для работы RUM  - отчет не запускается только на сохранение параметров*/
   
   define public variable temp-str                    as char no-undo.
   define public variable temp-param-date             as integer  no-undo.
   define public variable temp-param-date-type-period as character no-undo.
   define public variable temp-param-goods            as character.    /* Товары */
   define public variable temp-param-obj              as character.      /* Объекты */
   define public variable temp-param-obj-type         as character.      /* Объекты */
   define public variable temp-param-Pay              as character.      /* Цены */
   define public variable temp-param-Pay-hide         as character. /* Цены */
   define public variable temp-param-alon             as logical.      /* 1 закладка*/
   define public variable temp-param-customer         as character no-undo . /* контрагенты */
   define public variable temp-param-customer-type    as character no-undo . /* контрагенты */
   define public variable temp-param-schet            as character no-undo .
   define public variable  temp-param-schet-hide      as character no-undo .
   define public variable  temp-param-schet-init      as character no-undo .
   define public variable  temp-param-schet-mode      as character no-undo .
   define public variable all-object                  as logical   no-undo.
   define public variable my-request                  as logical  init false no-undo.
   
   define public variable var-report-r-b as character no-undo .
   define public variable v-r-b as character no-undo .
  
   
   define public variable gdsgrp_recids      as character no-undo.
   
   constructor public sParamForm (  ):
      super ().
      { gbl/curr-r-b.i var-report-r-b }
      { gbl/curr-r-b.i v-r-b }
   end constructor.

   destructor public sParamForm ( ):

   end destructor.
end class.