block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: cb37b650f92a, 1185, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:20:27 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: typl-ad.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/typl-ad.p $":U .
define variable vss-description as character no-undo init "Процедуры довавления и удаления типов прайс-листов".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
DEFINE TEMP-TABLE TT_cassa NO-UNDO LIKE ub.price-list-type-cassa.
DEFINE TEMP-TABLE TT_grp   NO-UNDO LIKE ub.price-list-type-gds-grp.
DEFINE TEMP-TABLE TT_pay-type NO-UNDO LIKE ub.price-list-type-pay-type.
DEFINE TEMP-TABLE TT_cash-pay NO-UNDO LIKE ub.price-list-type-cash-pay.
PROCEDURE type-price-list-ADD :
define input  parameter p-db-num                       as integer   no-undo .
define input  parameter p-id                           as integer   no-undo .
define input  parameter p-name                         as character no-undo .
define input  parameter p-ban-discnt                   like   ub.price-list-type.ban-discnt          no-undo .
define input  parameter p-calc-round-method            like   ub.price-list-type.calc-round-method    no-undo .
define input  parameter p-calc-round-base              like   ub.price-list-type.calc-round-base      no-undo .
define input  parameter p-calc-increase-pc             like   ub.price-list-type.calc-increase-pc     no-undo .
define input  parameter p-calc-method                  like   ub.price-list-type.calc-method          no-undo .
define input  parameter p-create-price-doc             like   ub.price-list-type.create-price-doc     no-undo .
define input  parameter p-fix-cource-crc-base          like   ub.price-list-type.fix-cource-crc-base  no-undo .
define input  parameter p-fix-cource-crc-doc           like   ub.price-list-type.fix-cource-crc-doc   no-undo .
define input  parameter p-have-rs-qnty-group           like   ub.price-list-type.have-rs-qnty-group   no-undo .
define input  parameter p-have-rs-sum-group            like   ub.price-list-type.have-rs-sum-group    no-undo .
define input  parameter p-main                         like   ub.price-list-type.main                 no-undo .
define input  parameter p-only-gbd                     like   ub.price-list-type.only-gbd             no-undo .
define input  parameter p-plt-main-db-num              like   ub.price-list-type.plt-main-db-num      no-undo .
define input  parameter p-plt-main-id                  like   ub.price-list-type.plt-main-id          no-undo .
define input  parameter p-priority                     like   ub.price-list-type.priority             no-undo .
define input  parameter p-rs-buyer                     like   ub.price-list-type.rs-buyer             no-undo .
define input  parameter p-send-cassa                   like   ub.price-list-type.send-cassa           no-undo .
define input  parameter p-under-hand-corr              like   ub.price-list-type.under-hand-corr      no-undo .
define input  parameter p-under-round-method           like   ub.price-list-type.under-round-method         no-undo .
define input  parameter p-under-perc                   like   ub.price-list-type.under-perc           no-undo .
define input  parameter p-under-type-list              like   ub.price-list-type.under-type-list      no-undo .
define input  parameter p-use-cassa                    like   ub.price-list-type.use-cassa            no-undo .
define input  parameter p-use-gds-group                like   ub.price-list-type.use-gds-group        no-undo .
define input  parameter p-use-obj                      like   ub.price-list-type.use-obj              no-undo .
define input  parameter p-work-date                    like   ub.price-list-type.work-date            no-undo .
define input  parameter p-bgr-db-num                   like   ub.price-list-type.bgr-db-num           no-undo .
define input  parameter p-bgr-id                       like   ub.price-list-type.bgr-id               no-undo .
define input  parameter p-curr-code                    like   ub.price-list-type.curr-code            no-undo .
define input  parameter p-gop-db-num                   like   ub.price-list-type.gop-db-num           no-undo .
define input  parameter p-gop-db-num-for-calc-turnover like   ub.price-list-type.gop-db-num-for-calc-turnover  no-undo .
define input  parameter p-gop-id                       like   ub.price-list-type.gop-id                        no-undo .
define input  parameter p-gop-id-for-calc-turnover     like   ub.price-list-type.gop-id-for-calc-turnover      no-undo .
define input  parameter p-qgr-db-num                   like   ub.price-list-type.qgr-db-num                    no-undo .
define input  parameter p-qgr-id                       like   ub.price-list-type.qgr-id                        no-undo .
define input  parameter p-sgr-db-num                   like   ub.price-list-type.sgr-db-num                    no-undo .
define input  parameter p-sgr-id                       like   ub.price-list-type.sgr-id                        no-undo .
define input  parameter p-tog-db-num                   like   ub.price-list-type.tog-db-num                    no-undo .
define input  parameter p-tog-id                       like   ub.price-list-type.tog-id                        no-undo .
define input  parameter p-obj-turnover                 like   ub.price-list-type.obj-turnover                  no-undo .
define input  parameter p-ttg-summa                    like   ub.price-list-type.ttg-summa                     no-undo .
define input  parameter p-userid                       as character no-undo .
define input  parameter p-db-num-usr                   as integer   no-undo .
define input  parameter p-have-rs-turn-group           like   ub.price-list-type.have-rs-turn-group no-undo .
define input  parameter p-have-tog-db-num              like   ub.price-list-type.have-tog-db-num    no-undo .
define input  parameter p-have-tog-id                  like   ub.price-list-type.have-tog-id        no-undo .
define input  parameter p-use-cash-pay                 like   ub.price-list-type.use-cash-pay no-undo .
define input  parameter p-use-pay-type                 like   ub.price-list-type.use-pay-type no-undo .
define output parameter p-recid                        as recid no-undo .
define input  parameter table for tt_cassa .
define input  parameter table for tt_grp   .
define input  parameter table for tt_pay-type .
define input  parameter table for tt_cash-pay .
define variable v-text as character no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
  do
  on error undo, return error return-value
  :
if p-plt-main-id                     = ? then p-plt-main-id = 0 .
if p-bgr-id                          = ? then p-bgr-id                        = 0 .
if p-gop-id                          = ? then p-gop-id                        = 0 .
if p-gop-id-for-calc-turnover        = ? then p-gop-id-for-calc-turnover      = 0 .
if p-qgr-db-num                      = ? then p-qgr-db-num                    = 0 .
if p-qgr-id                          = ? then p-qgr-id                        = 0 .
if p-sgr-db-num                      = ? then p-sgr-db-num                    = 0 .
if p-sgr-id                          = ? then p-sgr-id                        = 0 .
if p-tog-db-num                      = ? then p-tog-db-num                    = 0 .
if p-tog-id                          = ? then p-tog-id                        = 0 .
if p-gop-db-num                      = ? then p-gop-db-num                    = 0 .
if p-gop-db-num-for-calc-turnover    = ? then p-gop-db-num-for-calc-turnover  = 0 .
if p-have-tog-db-num                 = ? then p-have-tog-db-num  = 0 .
if p-have-tog-id                     = ? then p-have-tog-id      = 0 .
if p-gop-id = 0  then  p-use-obj = 1 .
if p-gop-id-for-calc-turnover  = 0  then  p-obj-turnover = false  .
if p-tog-id = 0   then  p-obj-turnover = false  .
if p-tog-id = 0 and  p-bgr-id = 0   then  p-rs-buyer = 0.
if p-name = ? or p-name = ""  then do:
  return error "Название типа прайс-листа не должно быть пустым!" .
end.
if logical(p-have-rs-qnty-group) = true and  ( p-qgr-id = 0 or p-qgr-id = ? ) then do:
  return error "Не задана количественная группа!" .
end.
if p-have-rs-sum-group = true and  ( p-sgr-id = 0 or p-sgr-id = ? ) then do:
  return error "Не задана суммовая группа!" .
end.
if logical(p-under-type-list) = true and  ( p-plt-main-id = 0 or p-plt-main-id = ? ) then do:
  return error "Не задан родительский прайс-лист !" .
end.
define buffer parent_price-list-type for ub.price-list-type  .
if  logical(p-under-type-list) = true and p-main = true  then do:
    find first parent_price-list-type  no-lock where
               parent_price-list-type.plt-id = p-plt-main-id  and
               parent_price-list-type.plt-db-num =  p-plt-main-db-num no-error .
    if not available parent_price-list-type then  return error "Родительский прайс-лист не найден !" .
    if parent_price-list-type.stts <> integer('0':U) then  return error "Родительский прайс-лист удален !" .
    if parent_price-list-type.main = false  then  return error "Родительский прайс-лист должен быть ГЛАВНЫМ !" .
    if parent_price-list-type.under-type-list <> 0  then return error "Родительский прайс-лист не должен быть подчиненным !"  .
end.
if  logical(p-under-type-list) = true and p-main = false   then do:
    find first parent_price-list-type  no-lock where
               parent_price-list-type.plt-id = p-plt-main-id  and
               parent_price-list-type.plt-db-num =  p-plt-main-db-num no-error .
    if not available parent_price-list-type then  return error "Родительский прайс-лист не найден !" .
    if parent_price-list-type.stts <> integer('0':U) then  return error "Родительский прайс-лист удален !" .
    if parent_price-list-type.under-type-list <> 0  then return error "Родительский прайс-лист не должен быть подчиненным !"  .
end.
if logical(p-have-rs-qnty-group) = false  and not ( p-qgr-id = 0 or p-qgr-id = ? ) then do:
   p-qgr-id = 0.
   p-qgr-db-num = 0.
end.
if p-have-rs-sum-group = false  and  not( p-sgr-id = 0 or p-sgr-id = ? ) then do:
  p-sgr-id = 0.
  p-sgr-db-num = 0.
end.
if logical(p-have-rs-turn-group) = false  and not ( p-have-tog-id = 0 or p-have-tog-id = ? ) then do:
   p-have-tog-id = 0.
   p-have-tog-db-num = 0.
end.
if p-priority  = 0  and p-main = false  and p-under-type-list = 0 then do:
   return error "Не задан ПРИОРИТЕТ типа прайс-листа"   .
end.
if p-priority > 0 and p-main = false and p-under-type-list = 0 then do:
    if can-find (
          first buf_price-list-type no-lock where
                buf_price-list-type.under-type-list = 0          and
                buf_price-list-type.priority        = p-priority and
                buf_price-list-type.main            = false      and
                buf_price-list-type.stts            = integer('0':U)          and
            not
              ( buf_price-list-type.plt-db-num = p-db-num and
                buf_price-list-type.plt-id     = p-id )
              ) then
    return error "Уже есть тип прайс-листа с приоритетом " + string ( p-priority ) .
end.
find first ub.price-list-type exclusive-lock where
           ub.price-list-type.plt-db-num   = p-db-num and
           ub.price-list-type.plt-id       = p-id
           no-error .
    if not available ub.price-list-type then do:
      if p-main = true and p-only-gbd = 1 then do:
        if can-find ( first buf_price-list-type no-lock where
                          buf_price-list-type.main = true and
                          buf_price-list-type.only-gbd = 1 and
                          buf_price-list-type.stts = integer('0':U) and
                          buf_price-list-type.gop-id = p-gop-id and
                          buf_price-list-type.gop-db-num = p-gop-db-num ) then  do:
            if p-gop-id = 0 or p-gop-id = ? then do:
              v-text  = "для всех объектов" .
              end.
              else do:
              v-text  = "для объектов из группы №"  + string(p-gop-id) + " БД:" + string(p-gop-db-num).
              end.
            release ub.price-list-type no-error .
            return error "Уже существует ГЛАВНЫЙ ПРАЙС-ЛИСТ для автопереоценок " + v-text .
            end.
      end.
      create ub.price-list-type .
      assign
          ub.price-list-type.plt-db-num   = p-db-num
          ub.price-list-type.plt-id       = p-id
      .
    end.
       assign
          ub.price-list-type.plt-db-num                     = p-db-num
          ub.price-list-type.plt-id                         = p-id
          ub.price-list-type.name                           = p-name
          ub.price-list-type.ban-discnt                     = p-ban-discnt
          ub.price-list-type.calc-round-method              = p-calc-round-method
          ub.price-list-type.calc-round-base                = p-calc-round-base
          ub.price-list-type.calc-increase-pc               = p-calc-increase-pc
          ub.price-list-type.calc-method                    = p-calc-method
          ub.price-list-type.create-price-doc               = p-create-price-doc
          ub.price-list-type.fix-cource-crc-base            = p-fix-cource-crc-base
          ub.price-list-type.fix-cource-crc-doc             = p-fix-cource-crc-doc
          ub.price-list-type.have-rs-qnty-group             = p-have-rs-qnty-group
          ub.price-list-type.have-rs-sum-group              = p-have-rs-sum-group
          ub.price-list-type.main                           = p-main
          ub.price-list-type.only-gbd                       = p-only-gbd
          ub.price-list-type.plt-main-db-num                = if p-plt-main-id = 0 then p-db-num else p-plt-main-db-num
          ub.price-list-type.plt-main-id                    = if p-plt-main-id = 0 then p-id else p-plt-main-id
          ub.price-list-type.priority                       = p-priority
          ub.price-list-type.rs-buyer                       = p-rs-buyer
          ub.price-list-type.send-cassa                     = p-send-cassa
          ub.price-list-type.under-hand-corr                = p-under-hand-corr
          ub.price-list-type.under-round-method             = p-under-round-method
          ub.price-list-type.under-perc                     = p-under-perc
          ub.price-list-type.under-type-list                = p-under-type-list
          ub.price-list-type.use-cassa                      = p-use-cassa
          ub.price-list-type.use-gds-group                  = p-use-gds-group
          ub.price-list-type.use-obj                        = p-use-obj
          ub.price-list-type.work-date                      = p-work-date
          ub.price-list-type.bgr-db-num                     = p-bgr-db-num
          ub.price-list-type.bgr-id                         = p-bgr-id
          ub.price-list-type.curr-code                      = p-curr-code
          ub.price-list-type.gop-db-num                     = p-gop-db-num
          ub.price-list-type.gop-db-num-for-calc-turnover   = p-gop-db-num-for-calc-turnover
          ub.price-list-type.gop-id                         = p-gop-id
          ub.price-list-type.gop-id-for-calc-turnover       = p-gop-id-for-calc-turnover
          ub.price-list-type.qgr-db-num                     = p-qgr-db-num
          ub.price-list-type.qgr-id                         = p-qgr-id
          ub.price-list-type.sgr-db-num                     = p-sgr-db-num
          ub.price-list-type.sgr-id                         = p-sgr-id
          ub.price-list-type.tog-db-num                     = p-tog-db-num
          ub.price-list-type.tog-id                         = p-tog-id
          ub.price-list-type.obj-turnover                   = p-obj-turnover
          ub.price-list-type.ttg-summa                      = p-ttg-summa
          ub.price-list-type.have-rs-turn-group             =   p-have-rs-turn-group
          ub.price-list-type.have-tog-db-num                =   p-have-tog-db-num
          ub.price-list-type.have-tog-id                    =   p-have-tog-id
          ub.price-list-type.use-cash-pay                   =   p-use-cash-pay
          ub.price-list-type.use-pay-type                   =   p-use-pay-type
          ub.price-list-type.stts                           = integer('0':U)
          ub.price-list-type.sys-date                       = today
          ub.price-list-type.sys-time                       = time
          ub.price-list-type.sys-time-chr                   = string ( ub.price-list-type.sys-time,"hh:mm" )
          ub.price-list-type.who                            = p-userid
          ub.price-list-type.db-num-chg                     = p-db-num-usr
          p-recid = recid ( ub.price-list-type )
      .
  if p-use-cassa < 3 then do:
     for each tt_cassa : delete tt_cassa . end.
  end.
  if p-use-gds-group = 0  then do:
     for each tt_grp : delete tt_grp . end.
  end.
  for each ub.price-list-type-gds-grp exclusive-lock where
           ub.price-list-type-gds-grp.plt-db-num  = p-db-num and
           ub.price-list-type-gds-grp.plt-id      = p-id :
       if not can-find (first  tt_grp where tt_grp.node-code = ub.price-list-type-gds-grp.node-code ) then
       ub.price-list-type-gds-grp.stts   = integer('1':U) .
  end.
  for each tt_grp :
      find first  ub.price-list-type-gds-grp exclusive-lock where
              ub.price-list-type-gds-grp.node-code  = tt_grp.node-code and
              ub.price-list-type-gds-grp.plt-db-num  = p-db-num and
              ub.price-list-type-gds-grp.plt-id      = p-id no-error .
      if not available ub.price-list-type-gds-grp then do:
             create ub.price-list-type-gds-grp.
              assign
                ub.price-list-type-gds-grp.node-code  = tt_grp.node-code
                ub.price-list-type-gds-grp.plt-db-num     = p-db-num
                ub.price-list-type-gds-grp.plt-id         = p-id
                ub.price-list-type-gds-grp.stts       = integer('0':U)
                ub.price-list-type-gds-grp.sys-date     = today
                ub.price-list-type-gds-grp.sys-time     = time
                ub.price-list-type-gds-grp.sys-time-chr = string ( ub.price-list-type-gds-grp.sys-time,"hh:mm" )
                ub.price-list-type-gds-grp.who          = p-userid
                ub.price-list-type-gds-grp.db-num-chg   = p-db-num-usr
              .
             end.
      else do:
         assign
          ub.price-list-type-gds-grp.stts   = integer('0':U)
          ub.price-list-type-gds-grp.sys-date     = today
          ub.price-list-type-gds-grp.sys-time     = time
          ub.price-list-type-gds-grp.sys-time-chr = string ( ub.price-list-type-gds-grp.sys-time,"hh:mm" )
          ub.price-list-type-gds-grp.who          = p-userid
          ub.price-list-type-gds-grp.db-num-chg   = p-db-num-usr
         .
      end.
  end.
  for each ub.price-list-type-cassa exclusive-lock where
           ub.price-list-type-cassa.plt-db-num  = p-db-num and
           ub.price-list-type-cassa.plt-id      = p-id :
       if not can-find (first tt_cassa where
                              tt_cassa.cash-num = ub.price-list-type-cassa.cash-num and
                              tt_cassa.obj-code = ub.price-list-type-cassa.obj-code and
                              tt_cassa.pos-type = ub.price-list-type-cassa.pos-type
                              ) then
       ub.price-list-type-cassa.stts   = integer('1':U)  .
  end.
  for each tt_cassa :
      find first  ub.price-list-type-cassa exclusive-lock where
                  ub.price-list-type-cassa.cash-num = tt_cassa.cash-num and
                  ub.price-list-type-cassa.obj-code = tt_cassa.obj-code and
                  ub.price-list-type-cassa.pos-type = tt_cassa.pos-type and
                  ub.price-list-type-cassa.plt-db-num        = p-db-num and
                  ub.price-list-type-cassa.plt-id            = p-id     no-error .
      if not available ub.price-list-type-cassa then do :
             create ub.price-list-type-cassa.
              assign
                ub.price-list-type-cassa.cash-num     = tt_cassa.cash-num
                ub.price-list-type-cassa.obj-code     = tt_cassa.obj-code
                ub.price-list-type-cassa.pos-type     = tt_cassa.pos-type
                ub.price-list-type-cassa.plt-db-num   = p-db-num
                ub.price-list-type-cassa.plt-id       = p-id
                ub.price-list-type-cassa.stts         = integer('0':U)
                ub.price-list-type-cassa.sys-date     = today
                ub.price-list-type-cassa.sys-time     = time
                ub.price-list-type-cassa.sys-time-chr = string ( ub.price-list-type-cassa.sys-time,"hh:mm" )
                ub.price-list-type-cassa.who          = p-userid
                ub.price-list-type-cassa.db-num-chg   = p-db-num-usr
                ub.price-list-type-cassa.db-num       = p-db-num-usr
              .
             end.
      else do:
         assign
          ub.price-list-type-cassa.stts   = integer('0':U)
          ub.price-list-type-cassa.sys-date     = today
          ub.price-list-type-cassa.sys-time     = time
          ub.price-list-type-cassa.sys-time-chr = string ( ub.price-list-type-cassa.sys-time,"hh:mm" )
          ub.price-list-type-cassa.who          = p-userid
          ub.price-list-type-cassa.db-num-chg   = p-db-num-usr
         .
      end.
  end.
  for each ub.price-list-type-pay-type exclusive-lock where
           ub.price-list-type-pay-type.plt-db-num  = p-db-num and
           ub.price-list-type-pay-type.plt-id      = p-id :
       if not can-find (first tt_pay-type where
                              tt_pay-type.pay-code = ub.price-list-type-pay-type.pay-code
                              ) then
       ub.price-list-type-pay-type.stts   = integer('1':U)  .
  end.
  for each tt_pay-type :
      find first  ub.price-list-type-pay-type exclusive-lock where
                  ub.price-list-type-pay-type.pay-code = tt_pay-type.pay-code and
                  ub.price-list-type-pay-type.plt-db-num        = p-db-num and
                  ub.price-list-type-pay-type.plt-id            = p-id     no-error .
      if not available ub.price-list-type-pay-type then do :
             create ub.price-list-type-pay-type.
              assign
                ub.price-list-type-pay-type.pay-code     = tt_pay-type.pay-code
                ub.price-list-type-pay-type.plt-db-num   = p-db-num
                ub.price-list-type-pay-type.plt-id       = p-id
                ub.price-list-type-pay-type.stts         = integer('0':U)
                ub.price-list-type-pay-type.sys-date     = today
                ub.price-list-type-pay-type.sys-time     = time
                ub.price-list-type-pay-type.sys-time-chr = string ( ub.price-list-type-pay-type.sys-time,"hh:mm" )
                ub.price-list-type-pay-type.who          = p-userid
                ub.price-list-type-pay-type.db-num-chg   = p-db-num-usr
                ub.price-list-type-pay-type.db-num       = p-db-num-usr
              .
             end.
      else do:
         assign
          ub.price-list-type-pay-type.stts   = integer('0':U)
          ub.price-list-type-pay-type.sys-date     = today
          ub.price-list-type-pay-type.sys-time     = time
          ub.price-list-type-pay-type.sys-time-chr = string ( ub.price-list-type-pay-type.sys-time,"hh:mm" )
          ub.price-list-type-pay-type.who          = p-userid
          ub.price-list-type-pay-type.db-num-chg   = p-db-num-usr
         .
      end.
  end.
  for each ub.price-list-type-cash-pay exclusive-lock where
           ub.price-list-type-cash-pay.plt-db-num  = p-db-num and
           ub.price-list-type-cash-pay.plt-id      = p-id :
       if not can-find (first tt_cash-pay where
                              tt_cash-pay.cdpay-code = ub.price-list-type-cash-pay.cdpay-code and
                              tt_cash-pay.curr-code  = ub.price-list-type-cash-pay.curr-code
                              ) then
       ub.price-list-type-cash-pay.stts   = 1 .
  end.
  for each tt_cash-pay :
      find first  ub.price-list-type-cash-pay exclusive-lock where
                  ub.price-list-type-cash-pay.cdpay-code = tt_cash-pay.cdpay-code and
                  ub.price-list-type-cash-pay.curr-code  = tt_cash-pay.curr-code and
                  ub.price-list-type-cash-pay.plt-db-num        = p-db-num and
                  ub.price-list-type-cash-pay.plt-id            = p-id     no-error .
      if not available ub.price-list-type-cash-pay then do :
             create ub.price-list-type-cash-pay.
              assign
                ub.price-list-type-cash-pay.cdpay-code     = tt_cash-pay.cdpay-code
                ub.price-list-type-cash-pay.curr-code     = tt_cash-pay.curr-code
                ub.price-list-type-cash-pay.plt-db-num   = p-db-num
                ub.price-list-type-cash-pay.plt-id       = p-id
                ub.price-list-type-cash-pay.stts         = integer('0':U)
                ub.price-list-type-cash-pay.sys-date     = today
                ub.price-list-type-cash-pay.sys-time     = time
                ub.price-list-type-cash-pay.sys-time-chr = string ( ub.price-list-type-cash-pay.sys-time,"hh:mm" )
                ub.price-list-type-cash-pay.who          = p-userid
                ub.price-list-type-cash-pay.db-num-chg   = p-db-num-usr
                ub.price-list-type-cash-pay.db-num       = p-db-num-usr
              .
             end.
      else do:
         assign
          ub.price-list-type-cash-pay.stts   = integer('0':U)
          ub.price-list-type-cash-pay.sys-date     = today
          ub.price-list-type-cash-pay.sys-time     = time
          ub.price-list-type-cash-pay.sys-time-chr = string ( ub.price-list-type-cash-pay.sys-time,"hh:mm" )
          ub.price-list-type-cash-pay.who          = p-userid
          ub.price-list-type-cash-pay.db-num-chg   = p-db-num-usr
         .
      end.
  end.
  end.
end procedure.
PROCEDURE type-price-list-delete :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
define buffer child_price-list-type for ub.price-list-type  .
  do
  on error undo, return error return-value
  :
find first ub.price-list-type exclusive-lock where
        ub.price-list-type.plt-db-num   = p-db-num  and
        ub.price-list-type.plt-id       = p-id
        no-error .
 if not available ub.price-list-type then  return error .
 if ub.price-list-type.ban-discnt > 0 then do:
 define buffer buf_dis-rule for ub.dis-rule  .
 find first buf_dis-rule no-lock where
            buf_dis-rule.templ-rl-root = ub.price-list-type.ban-discnt and
            buf_dis-rule.charkey_one   = substitute("&1-&2", ub.price-list-type.plt-id, ub.price-list-type.plt-db-num)
            no-error .
     if available buf_dis-rule then do:
        message  substitute
          ( "Удалить этот тип нельзя, так как есть ссылка на ПРАВИЛО СКИДОК &1 &2" ,
             ub.price-list-type.ban-discnt  ,
             buf_dis-rule.des
            ) view-as alert-box error .
        return .
     end.
 end.
 find first ub.price-doc-forming no-lock where
            ub.price-doc-forming.plt-id = ub.price-list-type.plt-id and
            ub.price-doc-forming.plt-db-num = ub.price-list-type.plt-db-num and
            ub.price-doc-forming.stts = integer('0':U) no-error .
 if available ub.price-doc-forming then do:
        message "Удалить этот тип нельзя, так как есть незакрытые ДНЦ " ub.price-doc-forming.pdf-id "БД:" ub.price-doc-forming.pdf-db
        view-as alert-box error .
        return .
 end.
      assign
        ub.price-list-type.db-num-chg    = p-db-num-usr
        ub.price-list-type.stts          = integer('1':U)
        ub.price-list-type.sys-date      = today
        ub.price-list-type.sys-time      = time
        ub.price-list-type.sys-time-chr  = string ( ub.price-list-type.sys-time,"hh:mm" )
        ub.price-list-type.who           = p-userid
      .
      for each child_price-list-type exclusive-lock where
               child_price-list-type.plt-main-db-num = p-db-num  and
               child_price-list-type.plt-main-id     = p-id
               :
            assign
              child_price-list-type.db-num-chg    = p-db-num-usr
              child_price-list-type.stts          = integer('1':U)
              child_price-list-type.sys-date      = today
              child_price-list-type.sys-time      = time
              child_price-list-type.sys-time-chr  = string ( child_price-list-type.sys-time , "hh:mm" )
              child_price-list-type.who           = p-userid
            .
      end.
  end.
end procedure.
define variable v-sec as integer   no-undo .
PROCEDURE obji-add :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-dgo-db-num   as integer   no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
define output parameter p-recid as recid no-undo .
  do
  on error undo, return error return-value
  :
find first ub.grp-obj-price exclusive-lock where
        ub.grp-obj-price.gop-db-num   = p-db-num  and
        ub.grp-obj-price.gop-id       = p-id
        no-error .
  if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
      return error .
  end.
find first ub.db-grp-obj-price exclusive-lock where
        ub.db-grp-obj-price.gop-db-num   = p-db-num  and
        ub.db-grp-obj-price.gop-id       = p-id      and
        ub.db-grp-obj-price.dgo-db-num   = p-dgo-db-num
        no-error .
      if not available ub.db-grp-obj-price then do:
          create ub.db-grp-obj-price.
            assign
                ub.db-grp-obj-price.gop-db-num = p-db-num
                ub.db-grp-obj-price.gop-id     = p-id
                ub.db-grp-obj-price.dgo-db-num = p-dgo-db-num
            .
      end.
      assign
        ub.db-grp-obj-price.num-chg    = p-db-num-usr
        ub.db-grp-obj-price.stts          = p-stts
        ub.db-grp-obj-price.sys-date      = today
        ub.db-grp-obj-price.sys-time      = time
        ub.db-grp-obj-price.sys-time-chr  = string ( ub.db-grp-obj-price.sys-time,"hh:mm" )
        ub.db-grp-obj-price.who           = p-userid
        p-recid = recid ( ub.db-grp-obj-price )
      .
      ub.grp-obj-price.sys-time = time .
      run ref/h-grpo.p (buffer ub.db-grp-obj-price , input-output v-sec )  .
  end.
end procedure.
PROCEDURE obji-del :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-dgo-db-num   as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
  do
  on error undo, return error return-value
  :
find first ub.grp-obj-price exclusive-lock where
        ub.grp-obj-price.gop-db-num   = p-db-num  and
        ub.grp-obj-price.gop-id       = p-id
        .
find first ub.db-grp-obj-price exclusive-lock where
        ub.db-grp-obj-price.gop-db-num   = p-db-num  and
        ub.db-grp-obj-price.gop-id       = p-id      and
        ub.db-grp-obj-price.dgo-db-num = p-dgo-db-num
        no-error .
 if not available ub.db-grp-obj-price then  return error .
      assign
        ub.db-grp-obj-price.num-chg    = p-db-num-usr
        ub.db-grp-obj-price.stts          = 1
        ub.db-grp-obj-price.sys-date      = today
        ub.db-grp-obj-price.sys-time      = time
        ub.db-grp-obj-price.sys-time-chr  = string(ub.db-grp-obj-price.sys-time,"hh:mm")
        ub.db-grp-obj-price.who           = p-userid
      .
      run ref/h-grpo.p (buffer ub.db-grp-obj-price , input-output v-sec )  .
      ub.grp-obj-price.sys-time = time .
  end.
end procedure.
PROCEDURE objf-add :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-host-code    as integer   no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
define output parameter p-recid as recid no-undo .
  do
  on error undo, return error return-value
  :
find first ub.sysconf no-lock where recid(ub.sysconf) = p-host-code .
if available ub.sysconf then do:
   p-host-code = ub.sysconf.host-code .
end.
find first ub.grp-obj-price exclusive-lock where
        ub.grp-obj-price.gop-db-num   = p-db-num  and
        ub.grp-obj-price.gop-id       = p-id
        .
find first ub.host-grp-obj-price exclusive-lock where
        ub.host-grp-obj-price.gop-db-num   = p-db-num  and
        ub.host-grp-obj-price.gop-id       = p-id      and
        ub.host-grp-obj-price.host-code    = p-host-code
        no-error .
      if not available ub.host-grp-obj-price then do:
          create ub.host-grp-obj-price.
            assign
                ub.host-grp-obj-price.gop-db-num   = p-db-num
                ub.host-grp-obj-price.gop-id       = p-id
                ub.host-grp-obj-price.host-code    = p-host-code
            .
      end.
      assign
        ub.host-grp-obj-price.db-num-chg    = p-db-num-usr
        ub.host-grp-obj-price.stts          = p-stts
        ub.host-grp-obj-price.sys-date      = today
        ub.host-grp-obj-price.sys-time      = time
        ub.host-grp-obj-price.sys-time-chr  = string ( ub.host-grp-obj-price.sys-time,"hh:mm" )
        ub.host-grp-obj-price.who           = p-userid
        p-recid = recid ( ub.host-grp-obj-price )
      .
      ub.grp-obj-price.sys-time = time .
      run ref/h-grph.p (buffer ub.host-grp-obj-price , input-output v-sec )  .
  end.
end procedure.
PROCEDURE objf-del :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-host-code   as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
  do
  on error undo, return error return-value
  :
find first ub.grp-obj-price exclusive-lock where
        ub.grp-obj-price.gop-db-num   = p-db-num  and
        ub.grp-obj-price.gop-id       = p-id
        .
find first ub.host-grp-obj-price exclusive-lock where
        ub.host-grp-obj-price.gop-db-num   = p-db-num  and
        ub.host-grp-obj-price.gop-id       = p-id      and
        ub.host-grp-obj-price.host-code    = p-host-code
        no-error .
 if not available ub.host-grp-obj-price then  return error .
      assign
        ub.host-grp-obj-price.db-num-chg    = p-db-num-usr
        ub.host-grp-obj-price.stts          = 1
        ub.host-grp-obj-price.sys-date      = today
        ub.host-grp-obj-price.sys-time      = time
        ub.host-grp-obj-price.sys-time-chr  = string(ub.host-grp-obj-price.sys-time,"hh:mm")
        ub.host-grp-obj-price.who           = p-userid
      .
       ub.grp-obj-price.sys-time = time .
       run ref/h-grph.p (buffer ub.host-grp-obj-price , input-output v-sec )  .
  end.
end procedure.
PROCEDURE objo-add :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-obj-type     as character no-undo .
define input  parameter p-obj-code     as integer   no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
define output parameter p-recid as recid no-undo .
  do
  on error undo, return error return-value
  :
find first ub.grp-obj-price exclusive-lock where
        ub.grp-obj-price.gop-db-num   = p-db-num  and
        ub.grp-obj-price.gop-id       = p-id
        .
find first ub.obj-grp-obj-price exclusive-lock where
        ub.obj-grp-obj-price.gop-db-num   = p-db-num  and
        ub.obj-grp-obj-price.gop-id       = p-id      and
        ub.obj-grp-obj-price.obj-type    = p-obj-type and
        ub.obj-grp-obj-price.obj-code    = p-obj-code
        no-error .
      if not available ub.obj-grp-obj-price then do:
          create ub.obj-grp-obj-price.
            assign
                ub.obj-grp-obj-price.gop-db-num   = p-db-num
                ub.obj-grp-obj-price.gop-id       = p-id
                ub.obj-grp-obj-price.obj-type    = p-obj-type
                ub.obj-grp-obj-price.obj-code    = p-obj-code
            .
      end.
      assign
        ub.obj-grp-obj-price.db-num-chg    = p-db-num-usr
        ub.obj-grp-obj-price.stts          = p-stts
        ub.obj-grp-obj-price.sys-date      = today
        ub.obj-grp-obj-price.sys-time      = time
        ub.obj-grp-obj-price.sys-time-chr  = string ( ub.obj-grp-obj-price.sys-time,"hh:mm" )
        ub.obj-grp-obj-price.who           = p-userid
        p-recid = recid ( ub.obj-grp-obj-price )
      .
      ub.grp-obj-price.sys-time = time .
      run ref/h-grpi.p (buffer ub.obj-grp-obj-price , input-output v-sec )  .
  end.
end procedure.
PROCEDURE objo-del :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
  do
  on error undo, return error return-value
  :
find first ub.grp-obj-price exclusive-lock where
        ub.grp-obj-price.gop-db-num   = p-db-num  and
        ub.grp-obj-price.gop-id       = p-id
        .
find first ub.obj-grp-obj-price exclusive-lock where
        ub.obj-grp-obj-price.gop-db-num   = p-db-num  and
        ub.obj-grp-obj-price.gop-id       = p-id      and
        ub.obj-grp-obj-price.obj-type    = p-obj-type and
        ub.obj-grp-obj-price.obj-code    = p-obj-code
        no-error .
 if not available ub.obj-grp-obj-price then  return error .
      assign
        ub.obj-grp-obj-price.db-num-chg    = p-db-num-usr
        ub.obj-grp-obj-price.stts          = 1
        ub.obj-grp-obj-price.sys-date      = today
        ub.obj-grp-obj-price.sys-time      = time
        ub.obj-grp-obj-price.sys-time-chr  = string(ub.obj-grp-obj-price.sys-time,"hh:mm")
        ub.obj-grp-obj-price.who           = p-userid
      .
     ub.grp-obj-price.sys-time = time .
     run ref/h-grpi.p (buffer ub.obj-grp-obj-price , input-output v-sec )  .
  end.
end procedure.
