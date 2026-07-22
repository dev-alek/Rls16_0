/*

$Revision: cf3f2bc9c0d7, 3321, rls $
$Author: EShklyar $
$Date: 2023/05/19 13:37:07 $
$Workfile: ds-promo.i $
$Archive: bge/ds-promo.i $

Расписания промо-акций

Автор: Молотков Сергей
Дата создания: 21/06/18
Author: Molotkov Sergey
Creation date: 21/06/18

*/
&if defined(ds-promo-i) = 0 &then
&global-define ds-promo-i

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: ds-promo.i $ $Revision: cf3f2bc9c0d7, 3321, rls $".

/* для списка акций */
define temp-table tt-promoaction no-undo
  like ub.PromoAction
  
  field status_lbl as character
  field sub        as class     Progress.Lang.Object serialize-hidden
  FIELD mode       AS char
  field Chang      as logical
  .

/* для редактирования акций */
define temp-table tt-promoaction-one no-undo
  like tt-promoaction
  
  before-table tt-promoaction-one-before
  
  //field TypeDiscontlbl   as character
  field TypeDiscontsolo  as logical 
  field TypeDiscontCombo as logical
  field TypeDiscontVisa  as logical 
  field methodCalclbl    as character
  field typecondlbl      as character
  field scheduleName     as character
  field changeBL         as logical
  field scheduleType     as logical
  field extCodeSched     as character
  field ChangDateFl      as logical
  field simpGiftFl       as logical
  field CritgoodsFl      as logical
  .

define temp-table tt-PromoBc no-undo
  like ub.PromoGoods
  field sub     as class Progress.Lang.Object
  field bc-code    as character
  field mode       as character
  FIELD gdsName AS char 
  field Chang      as logical
  .    
  
define temp-table tt-PromoGoodsAppl no-undo
  like ub.PromoGoods
  
  FIELD gdsName AS char 
  field sub     as class Progress.Lang.Object //serialize-hidden
  FIELD mode    AS char
  field Chang      as logical
  .
define temp-table tt-PromoGoodsCrite no-undo
  like tt-PromoGoodsAppl
  
  /* FIELD gdsName AS char 
  field sub as class Progress.Lang.Object serialize-hidden
  FIELD mode AS char */
  .  
define temp-table tt-PromoSet no-undo
  like tt-PromoGoodsAppl
  
  /*FIELD gdsName AS char  
  field sub as class Progress.Lang.Object serialize-hidden
  FIELD mode AS char*/
  .  
define temp-table tt-PromoSetGoods no-undo
  like tt-PromoGoodsAppl
  
  /* FIELD gdsName AS char 
  field sub as class Progress.Lang.Object serialize-hidden
  FIELD mode AS char */
  .
  
define temp-table tt-PromoCardsBin no-undo
  like tt-PromoGoodsAppl.  
define temp-table tt-PromoCriterion no-undo
  like ub.PromoCriterion
  field span as character  
  field sub  as Progress.Lang.Object serialize-hidden
  FIELD mode AS char
  field spanBef as character
  field maxcrit as decimal
  .

define temp-table tt-PromoGift no-undo
  like ub.PromoGift
   
  FIELD gdsName AS char
  field sub     as class Progress.Lang.Object serialize-hidden
  FIELD mode    AS char
  field mess-gks as character
  .

 
define temp-table tt-PromoObject no-undo
  like ub.PromoObject
   
  FIELD objName  AS char
  FIELD FirmCode AS integer 
  FIELD FirmName AS char
  FIELD objDbNum AS integer
  
  field sub      as class   Progress.Lang.Object serialize-hidden
  FIELD mode     AS char
  .

define temp-table tt-CashPay no-undo
  like ub.Cash-Pay
  .

define temp-table tt-promo-schedule-week no-undo
  like ub.promo-schedule-week

  field dtime-beg as datetime
  field dtime-end as datetime
  field isday_mon as logical
  field isday_tue as logical
  field isday_wed as logical
  field isday_thu as logical
  field isday_fri as logical
  field isday_sat as logical
  field isday_sun as logical
  
  field sub       as class     Progress.Lang.Object serialize-hidden
  field mode      as character
  .

define temp-table tt-promo-schedule-week2 no-undo
  like ub.promo-schedule-week

  field dtime-beg as datetime
  field dtime-end as datetime
//field wdaylabel as character
  field wdaynum   as integer
  
  field sub       as class     Progress.Lang.Object serialize-hidden
  field mode      as character
  .

define temp-table tt-promo-schedule-week3 no-undo
  like tt-promo-schedule-week
  .
define buffer tt-PromoCriterion-two for tt-PromoCriterion .
define buffer tt-PromoGift-two      for tt-PromoGift .

define dataset ds-promoaction-one
  for tt-promoaction-one
  , tt-CashPay
  , tt-PromoGoodsAppl
  , tt-PromoGoodsCrite
  , tt-PromoCriterion
  , tt-PromoGift
  , tt-PromoSet
  , tt-PromoSetGoods
  , tt-PromoObject
  , tt-PromoCardsBin
  , tt-PromoBc
//  , tt-promo-schedule
  , tt-promo-schedule-week
  , tt-promo-schedule-week2
  , tt-promo-schedule-week3
//  data-relation relGoodsAppl  for tt-promoaction-one, tt-PromoGoodsAppl     relation-fields (id, idaction)
  //data-relation relGoodsCrite for tt-promoaction-one, tt-PromoGoodsCrite    relation-fields (id, idaction) nested
  //data-relation relCriterion  for tt-promoaction-one, tt-PromoCriterion     relation-fields (id, idaction) nested
  //data-relation relGift       for tt-promoaction-one, tt-PromoGift          relation-fields (id, idaction) nested
//  data-relation relPromo      for tt-promoaction-one, tt-promo-schedule     relation-fields (id, idaction)
//  data-relation relPromoWeek  for tt-promo-schedule, tt-promo-schedule-week relation-fields (id, promosched-id)
  .

define variable hBuf-tt-PromoGoodsAppl-two as handle no-undo .
define dataset ds-PromoCriterion
  for tt-PromoCriterion-two
  , tt-PromoGift-two
  data-relation relGoodsAppl  for tt-PromoCriterion-two, tt-PromoGift-two  relation-fields (id, idcrit)
  .
define variable hDset-ds-promoaction-two as handle no-undo .
define variable hQtop-ds-promoaction-two as handle no-undo .
define variable hQrel-ds-promoaction-two as handle no-undo .
&endif
/* $Workfile: ds-promo.i $ e n d */