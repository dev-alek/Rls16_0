block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ves-pbc.p $
$Archive: ref/ves-pbc.p $

Создание весового кода на товар

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode        as character no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-deadline like ub.scales-gds.deadline no-undo .
define input parameter p-deaddate like ub.scales-gds.deaddate no-undo .
define input parameter p-deadflag like ub.scales-gds.deadflag no-undo .
define input parameter p-wt-cart  like ub.scales-gds.wt-cart no-undo .
define parameter buffer bc for ub.bar-code.
define parameter buffer sc for ub.scales.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ves-pbc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/ves-pbc.p $":U .
define variable vss-description as character no-undo init "Создание весового кода на товар".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ trg/new-bcod.i }
{ gbl/waitfram.i }
{ ref/gdsoattr.i }

define variable ii as integer no-undo.
define buffer for-pbc for ub.prod-bc.
define variable v-found as logical no-undo .
define variable v-on as logical no-undo .
define variable v-b-str like ub.prod-bc.b-str no-undo .
define buffer buf_scales-gds for ub.scales-gds.
define buffer buf_goods for ub.goods.
define buffer buf_units for ub.units.

_main:
DO ON ERROR undo, leave on stop undo, leave:
CASE p-mode:
    when {&add-def} then do:
      FIND FIRST buf_goods No-LOCK where buf_goods.gds-code = bc.gds-code .
      find first buf_units no-lock where buf_units.unit-name = buf_goods.unit-base.
      if lookup({&pieces}, buf_units.unit-name) > 0
      and lookup(sc.scales-type, {&pg-scales-list}) = 0 then do:
       undo _main, return error substitute("На весы типа &1 нельзя добавлять штучный товар", sc.scales-type).
      end.
      { ref/cves-pbc.i bc _main buf_goods p-obj-type p-obj-code "" buf_units.type }
      create buf_scales-gds.
      assign
      sc.tot-gds  = sc.tot-gds + 1
      buf_scales-gds.obj-type  = p-obj-type
      buf_scales-gds.obj-code =  p-obj-code
      buf_scales-gds.b-code = bc.b-code
      buf_scales-gds.scales-num = sc.scales-num
      buf_scales-gds.db-num = sc.db-num
      buf_scales-gds.to-send = TRUE
      buf_scales-gds.plu-type = (if lookup({&weight}, buf_units.type) > 0
                                       then integer({&sc-gds-weight})
                                       else integer({&sc-gds-pieces})
                                       )
      sc.to-send = TRUE
      buf_scales-gds.to-del = FALSE    /* отметка, что запись нужна */
      buf_scales-gds.deadline = (if p-deadline = ? and p-deadflag = integer({&sc-gds-deadflag-days})
                                  then buf_goods.deadline
                                  else p-deadline)
      buf_scales-gds.deaddate = (if p-deaddate <> ? and p-deadflag = integer({&sc-gds-deadflag-date})
                                  then p-deaddate
                                  else buf_scales-gds.deaddate)
      buf_scales-gds.deadflag = (if p-deadflag <> ? then p-deadflag else buf_scales-gds.deadflag)
      buf_scales-gds.wt-cart = if lookup({&weight}, buf_units.type) > 0
                               then  (if p-wt-cart = ?
                                      then buf_goods.wt-cart
                                      else p-wt-cart)
                               else 0

      .
      DO ii = 1 to sc.max-gds :
          if not ( can-find ( ub.scales-gds WHERE
          ub.scales-gds.db-num = sc.db-num AND
          ub.scales-gds.scales-num = sc.scales-num AND
          ub.scales-gds.plu-code = ii ) ) then LEAVE .
      END .
      if ii > sc.max-gds then do:
          message
          substitute("Превышено&1максимально допустимое количество&1товаров для весов &2."
                      , {&new-line}
                      , sc.scales-num)
          view-as alert-box ERROR .
          undo _main, return error "max-gds":U.
      end.
      assign
      buf_scales-gds.PLU-code = ii
      sc.max-plu  = Maximum(sc.max-plu, ii)
      .
    end.
    when {&update} then do:
      find first buf_scales-gds where
              buf_scales-gds.b-code = bc.b-code
          and buf_scales-gds.scales-num = sc.scales-num
          and buf_scales-gds.db-num     = sc.db-num
          and buf_scales-gds.obj-type   = p-obj-type
          and buf_scales-gds.obj-code   = p-obj-code
          .
      assign
      buf_scales-gds.deadline = (if p-deadline <> ? and p-deadflag = integer({&sc-gds-deadflag-days})
                                  then p-deadline
                                  else buf_scales-gds.deadline)
      buf_scales-gds.deaddate = (if p-deaddate <> ? and p-deadflag = integer({&sc-gds-deadflag-date})
                                  then p-deaddate
                                  else buf_scales-gds.deaddate)
      buf_scales-gds.deadflag = (if p-deadflag <> ? then p-deadflag else buf_scales-gds.deadflag)
      buf_scales-gds.wt-cart = (if p-wt-cart <> ? and buf_scales-gds.plu-type = integer({&sc-gds-weight})
                                then p-wt-cart
                                else buf_scales-gds.wt-cart)
      buf_scales-gds.to-send  = true
      sc.to-send = TRUE
      .
    end.
  END CASE.
END.