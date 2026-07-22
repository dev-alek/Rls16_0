DEFINE TEMP-TABLE tt_price-list-type-cash-pay NO-UNDO LIKE ub.price-list-type-cash-pay.
DEFINE TEMP-TABLE tt_price-list-type-cassa NO-UNDO LIKE ub.price-list-type-cassa.
DEFINE TEMP-TABLE tt_price-list-type-gds-grp NO-UNDO LIKE ub.price-list-type-gds-grp.
DEFINE TEMP-TABLE tt_price-list-type-pay-type NO-UNDO LIKE ub.price-list-type-pay-type.
define input  parameter parparentproc as handle no-undo .
define input  parameter p-main-price as logical   no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter p-recid as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка типа прайс-листа".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
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
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table x_obj-group no-undo like ub.clients  .
define temp-table x_grp-obj-price no-undo like ub.grp-obj-price .
procedure metod-gop-obj :
  do
  on error undo, return error return-value
  :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-gop-id       as integer   no-undo .
define input  parameter p-gop-db-num   as integer   no-undo .
define buffer buf1_clients for ub.clients  .
define buffer buf_db-grp-obj-price   for ub.db-grp-obj-price  .
define buffer buf_host-grp-obj-price for ub.host-grp-obj-price  .
define buffer buf_obj-grp-obj-price  for ub.obj-grp-obj-price  .
for each  x_obj-group : delete x_obj-group. end.
if p-gop-id = 0 or p-gop-id = ?  then do:
   if p-cntxt-db-num = 0  then do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  )
                and
                buf1_clients.db-num >= 0  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
   else do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  ) and
                 buf1_clients.db-num = p-cntxt-db-num  and
                 buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
end.
else do:
      for each buf_db-grp-obj-price  where
              buf_db-grp-obj-price.gop-id     = p-gop-id and
              buf_db-grp-obj-price.gop-db-num = p-gop-db-num and
              buf_db-grp-obj-price.stts = 0  no-lock :
        for each buf1_clients no-lock where
               (buf1_clients.obj-type = 'маг':U  or
                buf1_clients.obj-type = 'скл':U  ) and
                buf1_clients.db-num = buf_db-grp-obj-price.dgo-db-num  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
      end.
    for each buf_host-grp-obj-price where
            buf_host-grp-obj-price.gop-id     = p-gop-id and
            buf_host-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_host-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
             (buf1_clients.obj-type = 'маг':U  or
              buf1_clients.obj-type = 'скл':U  ) and
              buf1_clients.host-code = buf_host-grp-obj-price.host-code and
              buf1_clients.stts = 0
              :
          find first x_obj-group no-lock  where
                    x_obj-group.obj-code   = buf1_clients.obj-code and
                    x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
    for each buf_obj-grp-obj-price where
            buf_obj-grp-obj-price.gop-id     = p-gop-id and
            buf_obj-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_obj-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
                buf1_clients.obj-type = buf_obj-grp-obj-price.obj-type and
                buf1_clients.obj-code = buf_obj-grp-obj-price.obj-code and
                buf1_clients.stts     = 0
                :
          find first  x_obj-group no-lock  where
                      x_obj-group.obj-code   = buf1_clients.obj-code and
                      x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
end.
end.
end procedure.
procedure metod-obj-in-gop :
define input  parameter p-curr-db-num as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define buffer buf_grp-obj-price for ub.grp-obj-price  .
  do
  on error undo, return error return-value
  :
    empty temp-table x_grp-obj-price.
    for each buf_grp-obj-price where
             buf_grp-obj-price.stts = 0
             no-lock :
               run metod-gop-obj (p-curr-db-num , buf_grp-obj-price.gop-id ,buf_grp-obj-price.gop-db-num) .
               for each x_obj-group where
                        x_obj-group.obj-type = p-obj-type and
                        x_obj-group.obj-code = p-obj-code :
                    create  x_grp-obj-price.
                    buffer-copy buf_grp-obj-price to x_grp-obj-price .
               end.
    end.
  end.
end procedure.
procedure metod-delobj-usr :
define input  parameter p-pdf-id  as integer   no-undo .
define input  parameter p-pdf-db  as integer   no-undo .
define input  parameter p-plt-id  as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
for each buf_price-doc-forming-attr no-lock  where
         buf_price-doc-forming-attr.pdf-id =     p-pdf-id and
         buf_price-doc-forming-attr.pdf-db =     p-pdf-db and
         buf_price-doc-forming-attr.plt-id =     p-plt-id and
         buf_price-doc-forming-attr.plt-db-num = p-plt-db-num and
         buf_price-doc-forming-attr.attr-code begins "obj" :
   for each x_obj-group  where
            x_obj-group.obj-type = substring(buf_price-doc-forming-attr.attr-code,4,3) and
            x_obj-group.obj-code = int(substring(buf_price-doc-forming-attr.attr-code,7,20)) :
     delete x_obj-group.
   end.
end.
  if not can-find (first x_obj-group) then do:
     return "nullobj" .
  end.
end.
end procedure.
procedure metod-obj-pdf :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-pdf-id     like ub.price-doc-forming.pdf-id   no-undo .
define input  parameter p-pdf-db-num like ub.price-doc-forming.pdf-db   no-undo .
define input  parameter p-plt-id     like ub.price-doc-forming.plt-id   no-undo .
define input  parameter p-plt-db-num like ub.price-doc-forming.plt-db-num  no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
  do
  on error undo, return error return-value
  :
 for each  x_obj-group : delete x_obj-group. end.
 find first buf_price-list-type no-lock where
            buf_price-list-type.plt-id = p-plt-id and
            buf_price-list-type.plt-db-num = p-plt-db-num no-error .
if error-status :error then return error return-value .
 find first buf_price-doc-forming no-lock where
            buf_price-doc-forming.plt-id     = p-plt-id and
            buf_price-doc-forming.plt-db-num = p-plt-db-num and
            buf_price-doc-forming.pdf-id     = p-pdf-id and
            buf_price-doc-forming.pdf-db     = p-pdf-db-num
            no-error .
if error-status :error then return error return-value .
  run metod-gop-obj in this-procedure (
      p-cntxt-db-num,
      buf_price-list-type.gop-id ,
      buf_price-list-type.gop-db-num
      ) no-error .
  run metod-delobj-usr in this-procedure (
    buf_price-doc-forming.pdf-id ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id ,
    buf_price-doc-forming.plt-db-num
    ) no-error .
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-x-button-1  as decimal   no-undo .
define variable v-x-button-2  as decimal   no-undo .
define variable v-x-button-3  as decimal   no-undo .
define variable v-y-button-1  as decimal   no-undo .
define variable v-y-button-2  as decimal   no-undo .
define variable v-y-button-3  as decimal   no-undo .
define variable l-x-button-1  as decimal   no-undo .
define variable l-x-button-2  as decimal   no-undo .
define variable l-x-button-3  as decimal   no-undo .
define variable l-y-button-1  as decimal   no-undo .
define variable l-y-button-2  as decimal   no-undo .
define variable l-y-button-3  as decimal   no-undo .
define variable v-nn as integer   no-undo .
define variable v-t-recid as character no-undo .
define variable loc_under-round-method AS CHARACTER NO-UNDO.
define variable loc_under-perc as decimal   no-undo .
define variable   loc_ie-gen-marg   as character no-undo .
define variable   loc_ie-gen-marg-parts   as character no-undo .
define variable   loc_ie-objfirst   as integer   no-undo .
define variable   loc_ie-objsecond  as integer   no-undo .
define variable   loc_ie-pr-nakl    as logical   no-undo .
define variable   loc_iv-gen-marg   as character no-undo .
define variable   loc_iv-gen-marg-parts   as character no-undo .
define variable   loc_iv-objfirst   as integer   no-undo .
define variable   loc_iv-objsecond  as integer   no-undo .
define variable   loc_iv-pr-nakl    as logical   no-undo .
define variable   loc_im-gen-marg   as character no-undo .
define variable   loc_im-gen-marg-parts   as character no-undo .
define variable   loc_im-objfirst   as integer   no-undo .
define variable   loc_im-objsecond  as integer   no-undo .
define variable   loc_im-pr-nakl    as logical   no-undo .
define temp-table temp-avto-price no-undo
field nn as integer
field ext-doc-type as character format "x(18)"
field gen-marg   as character format "x(15)"
field gen-marg-parts   as character format "x(15)"
field objfirst   as integer
field objsecond  as integer
field pr-nakl    as logical
index pi nn ext-doc-type.
DEFINE BUTTON b-ban-discnt
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Просмотр скидки".
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-save AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON BUTTON-1
     IMAGE-UP FILE "adeicon\ts-down":U
     IMAGE-DOWN FILE "adeicon\ts-up":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "Расширение"
     SIZE 14.5 BY 1.13
     FONT 4.
DEFINE BUTTON BUTTON-2
     IMAGE-UP FILE "adeicon\ts-down":U
     IMAGE-DOWN FILE "adeicon\ts-up":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "Butt"
     SIZE 14.5 BY 1.13.
DEFINE BUTTON BUTTON-3
     IMAGE-UP FILE "adeicon\ts-down":U
     IMAGE-DOWN FILE "adeicon\ts-up":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "Butt"
     SIZE 14.25 BY 1.13.
DEFINE BUTTON r-ban-discnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка ШАБЛОНОВ СКИДКИ".
DEFINE BUTTON r-cur
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".
DEFINE BUTTON r-rod-price-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".
DEFINE VARIABLE loc_calc-method AS CHARACTER FORMAT "X(256)":U
     LABEL "Расчет цены по умолчанию"
     VIEW-AS COMBO-BOX INNER-LINES 19
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 16 BY 1 TOOLTIP "Метод расчета цены" NO-UNDO.
DEFINE VARIABLE loc_calc-round-method AS CHARACTER FORMAT "X(256)":U
     LABEL "Метод округления по умолчанию"
     VIEW-AS COMBO-BOX INNER-LINES 7
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE create-price-doc-FILL-IN AS CHARACTER FORMAT "X(256)" INITIAL "Формировать переоценки:"
      VIEW-AS TEXT
     SIZE 23.5 BY .67.
DEFINE VARIABLE f-ban-discnt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 44.88 BY .67 NO-UNDO.
DEFINE VARIABLE label-button-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Привязка"
      VIEW-AS TEXT
     SIZE 7.5 BY .58
     FONT 4 NO-UNDO.
DEFINE VARIABLE label-button-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Распространение"
      VIEW-AS TEXT
     SIZE 11.75 BY .58
     FONT 4 NO-UNDO.
DEFINE VARIABLE label-button-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Ограничения"
      VIEW-AS TEXT
     SIZE 9.13 BY .58
     FONT 4 NO-UNDO.
DEFINE VARIABLE loc_abbr-doc AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4.13 BY .67 TOOLTIP "Валюта платежа"
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE loc_ban-discnt AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4.38 BY .67 NO-UNDO.
DEFINE VARIABLE loc_calc-increase-pc AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     LABEL "% наценки по умолчанию"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.
DEFINE VARIABLE loc_calc-round-base AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE loc_curr-code AS INTEGER FORMAT ">>9" INITIAL 0
     LABEL "Валюта"
      VIEW-AS TEXT
     SIZE 4 BY .67 NO-UNDO.
DEFINE VARIABLE loc_name LIKE ub.price-list-type.name
     LABEL "Тип прайс-листа"
     VIEW-AS FILL-IN
     SIZE 61.88 BY .92
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE loc_plt-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
     LABEL "БД"
      VIEW-AS TEXT
     SIZE 5.63 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE loc_plt-id LIKE ub.price-list-type.plt-id
     LABEL "Код"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE loc_plt-main-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 3 BY .75 TOOLTIP "БД"
     FGCOLOR 4 .
DEFINE VARIABLE loc_plt-main-id AS INTEGER FORMAT ">>>>>>>" INITIAL 0
     LABEL "->Родительский ПЛ"
      VIEW-AS TEXT
     SIZE 6.25 BY .67 TOOLTIP "Родительский тип прайс-листа"
     FGCOLOR 4 .
DEFINE VARIABLE loc_priority AS INTEGER FORMAT ">>>>>>9" INITIAL 0
     LABEL "Приоритет"
     VIEW-AS FILL-IN
     SIZE 9 BY .92.
DEFINE VARIABLE loc_rod-pt-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 38.75 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE use-cassa-FILL-IN AS CHARACTER FORMAT "X(256)" INITIAL "Отправлять на кассы:"
      VIEW-AS TEXT
     SIZE 20.5 BY .67.
DEFINE VARIABLE v-max AS INTEGER FORMAT "->>>>9":U INITIAL 0
     LABEL "сейчас MAX приоритет"
      VIEW-AS TEXT
     SIZE 9 BY .54 TOOLTIP "MAX приоритет на текущий момент в этой БД"
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE work-date-FILL-IN AS CHARACTER FORMAT "X(256)" INITIAL "Признак работы на объекте по:"
      VIEW-AS TEXT
     SIZE 30 BY .67
     FGCOLOR 1 .
DEFINE VARIABLE loc_create-price-doc AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "да", 1,
"нет", 2
     SIZE 10.5 BY .67 NO-UNDO.
DEFINE VARIABLE loc_send-cassa AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "да", 1,
"нет", 2
     SIZE 10.5 BY .67 NO-UNDO.
DEFINE VARIABLE loc_work-date AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "дате на объекте", 1,
"сменной дате и № смены", 2,
"дате и времени сервера", 3
     SIZE 24.88 BY 2.25 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 98.5 BY 11.29
     BGCOLOR 15 .
DEFINE VARIABLE l-ban-discnt AS LOGICAL INITIAL no
     LABEL "Шаблон скидки"
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .83 TOOLTIP "Есть ли привязка к правилам скидки" NO-UNDO.
DEFINE VARIABLE loc_fix-cource-crc-base AS LOGICAL INITIAL no
     LABEL "Фиксированный курс базовой валюты"
     VIEW-AS TOGGLE-BOX
     SIZE 36.5 BY .83 NO-UNDO.
DEFINE VARIABLE loc_fix-cource-crc-doc AS LOGICAL INITIAL no
     LABEL "Фиксированный курс валюты прайс-листа"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY .83 NO-UNDO.
DEFINE VARIABLE loc_only-gbd AS LOGICAL INITIAL no
     LABEL "Для автопереоценок"
     VIEW-AS TOGGLE-BOX
     SIZE 28.25 BY .83 TOOLTIP "Используется для создания переоценок по ПН. На 1 объекте может быть только 1 такой тип "
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_under-hand-corr AS LOGICAL INITIAL no
     LABEL "Подчиненный прайс-лист подлежит ручной коррекции"
     VIEW-AS TOGGLE-BOX
     SIZE 51.5 BY .71 NO-UNDO.
DEFINE VARIABLE loc_under-type-list AS LOGICAL INITIAL no
     LABEL "Пoдчиненный ПЛ"
     VIEW-AS TOGGLE-BOX
     SIZE 16.63 BY .67 TOOLTIP "Пoдчиненный прайс-лист" NO-UNDO.
DEFINE BUTTON b-have-tog
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Просмотр состава".
DEFINE BUTTON b-qnty-grp
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Просмотр состава".
DEFINE BUTTON b-qnty-sgr
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Просмотр состава".
DEFINE BUTTON r-have-tog
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".
DEFINE BUTTON r-qnty-grp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".
DEFINE BUTTON r-qnty-sgr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".
DEFINE VARIABLE loc_have-tog-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 2.5 BY .67 TOOLTIP "БД" NO-UNDO.
DEFINE VARIABLE loc_have-tog-id AS INTEGER FORMAT ">>>>>>>" INITIAL 0
      VIEW-AS TEXT
     SIZE 6.25 BY .67 NO-UNDO.
DEFINE VARIABLE loc_have-tog_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39.63 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE loc_qgr-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 2.5 BY .83 TOOLTIP "БД" NO-UNDO.
DEFINE VARIABLE loc_qgr-id AS INTEGER FORMAT ">>>>>>>" INITIAL 0
      VIEW-AS TEXT
     SIZE 6.25 BY .83 NO-UNDO.
DEFINE VARIABLE loc_qg_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39.75 BY .83
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE loc_sgr-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 2.5 BY .83 TOOLTIP "БД" NO-UNDO.
DEFINE VARIABLE loc_sgr-id LIKE ub.price-list-type.qgr-id
      VIEW-AS TEXT
     SIZE 6.25 BY .83 NO-UNDO.
DEFINE VARIABLE loc_sg_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39.63 BY .83
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-1 AS CHARACTER FORMAT "X(256)":U
     LABEL "first"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE loc_have-rs-qnty-group AS LOGICAL INITIAL no
     LABEL "Есть связь с количественной группой"
     VIEW-AS TOGGLE-BOX
     SIZE 38.88 BY .83 NO-UNDO.
DEFINE VARIABLE loc_have-rs-sum-group AS LOGICAL INITIAL no
     LABEL "Есть связь с суммовой группой"
     VIEW-AS TOGGLE-BOX
     SIZE 36.75 BY .83 NO-UNDO.
DEFINE VARIABLE loc_have-rs-turn-group AS LOGICAL INITIAL no
     LABEL "Есть связь с группой по оборотам"
     VIEW-AS TOGGLE-BOX
     SIZE 36 BY .83 NO-UNDO.
DEFINE BUTTON B-chga
     LABEL "Изменить"
     SIZE 9.5 BY 1 TOOLTIP "Изменить  настройки по типу документа".
DEFINE BUTTON b-gop
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Просмотр состава".
DEFINE BUTTON b-gop-2
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Просмотр состава".
DEFINE BUTTON b-gop-calc
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Просмотр состава".
DEFINE BUTTON b-qnty-tog
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Просмотр состава".
DEFINE BUTTON r-gop
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".
DEFINE BUTTON r-gop-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".
DEFINE BUTTON r-gop-calc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".
DEFINE BUTTON r-qnty-tog
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".
DEFINE VARIABLE v-spis-kass AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 36.5 BY 4
     tooltip "Список разрешенных к работе касс"
     FONT 0 NO-UNDO.
DEFINE VARIABLE f-ie-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Тип автопереоценки:"
      VIEW-AS TEXT
     SIZE 19.5 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE loc_bgr-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 2.5 BY .67 TOOLTIP "БД" NO-UNDO.
DEFINE VARIABLE loc_bgr-id AS INTEGER FORMAT ">>>>>>>" INITIAL 0
     LABEL "Группа покупателей"
      VIEW-AS TEXT
     SIZE 6.25 BY .67 NO-UNDO.
DEFINE VARIABLE loc_bgr_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39.63 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE loc_gop-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 2.5 BY .88 TOOLTIP "БД" NO-UNDO.
DEFINE VARIABLE loc_gop-db-num-for-calc-turnover AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 2.5 BY .83 TOOLTIP "БД" NO-UNDO.
DEFINE VARIABLE loc_gop-id LIKE ub.price-list-type.qgr-id
      VIEW-AS TEXT
     SIZE 6.25 BY .88 NO-UNDO.
DEFINE VARIABLE loc_gop-id-for-calc-turnover LIKE ub.price-list-type.qgr-id
      VIEW-AS TEXT
     SIZE 6.25 BY .83 NO-UNDO.
DEFINE VARIABLE loc_gop_name-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 37.25 BY .88
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE loc_gop_name-tnv AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 37.25 BY .83
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE loc_tog-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 2.5 BY .67 TOOLTIP "БД" NO-UNDO.
DEFINE VARIABLE loc_tog-id LIKE ub.price-list-type.qgr-id
     LABEL "Группа оборотов  ."
      VIEW-AS TEXT
     SIZE 6.25 BY .67 NO-UNDO.
DEFINE VARIABLE loc_tog_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39.63 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE loc_use-cassa_FILL-IN AS CHARACTER FORMAT "X(256)":U INITIAL "Распространение по кассам:"
      VIEW-AS TEXT
     SIZE 27 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE r-FILL-IN AS CHARACTER FORMAT "X(256)":U INITIAL "Распространение по покупателям"
      VIEW-AS TEXT
     SIZE 30.5 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE r-obj-fill-in AS CHARACTER FORMAT "X(256)":U INITIAL "Объекты для расчета оборота:"
      VIEW-AS TEXT
     SIZE 28.38 BY .83 TOOLTIP "Объекты для расчета совокупного оборота" NO-UNDO.
DEFINE VARIABLE r-use-obj-fill-in AS CHARACTER FORMAT "X(256)":U INITIAL "Распространение по объектам:"
      VIEW-AS TEXT
     SIZE 28 BY .88 TOOLTIP "Распространение по объектам"
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "second"
     VIEW-AS FILL-IN
     SIZE 1.5 BY 1 NO-UNDO.
DEFINE VARIABLE loc_obj-turnover AS LOGICAL
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", no,
"Группа", yes
     SIZE 14.5 BY .83 NO-UNDO.
DEFINE VARIABLE loc_rs-buyer AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 0,
"Группа", 1,
"Оборот", 2
     SIZE 23 BY .58 TOOLTIP "Распространение по покупателям" NO-UNDO.
DEFINE VARIABLE loc_use-cassa AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "не отправлять", 1,
"на все", 2,
"выборочно", 3
     SIZE 37 BY .71 TOOLTIP "Распространение по кассам" NO-UNDO.
DEFINE VARIABLE loc_use-obj AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Группа", 2
     SIZE 14.5 BY .88 NO-UNDO.
DEFINE VARIABLE v-spis-group AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 55 BY 3.54
     tooltip "Список разрешенных к работе групп"
     NO-UNDO.
DEFINE VARIABLE v-spis-type-pay AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 32.5 BY 3.54
     tooltip "Список разрешенных к работе типов"
     NO-UNDO.
DEFINE VARIABLE v-spis-use-cash-pay AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 33.13 BY 2.63
     tooltip "Список разрешенных к работе типов"
     NO-UNDO.
DEFINE VARIABLE F-ogran AS CHARACTER FORMAT "X(256)":U INITIAL "Есть ограничение:"
      VIEW-AS TEXT
     SIZE 17.5 BY .67 NO-UNDO.
DEFINE VARIABLE v-3 AS CHARACTER FORMAT "X(256)":U
     LABEL "tree"
     VIEW-AS FILL-IN
     SIZE 2.5 BY 1 NO-UNDO.
DEFINE VARIABLE loc_use-cash-pay AS LOGICAL INITIAL no
     LABEL "по типам кассовых платежей"
     VIEW-AS TOGGLE-BOX
     SIZE 28.63 BY .83 TOOLTIP "Есть ограничения по типам кассовых платежей" NO-UNDO.
DEFINE VARIABLE loc_use-gds-group AS LOGICAL INITIAL no
     LABEL "по группам товаров"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY .83 TOOLTIP "Есть ограничения по группам товаров" NO-UNDO.
DEFINE VARIABLE loc_use-pay-type AS LOGICAL INITIAL no
     LABEL "по типам платежа"
     VIEW-AS TOGGLE-BOX
     SIZE 18.75 BY .83 TOOLTIP "Есть ограничения по типам платежа" NO-UNDO.
DEFINE QUERY BR-tt FOR
      temp-avto-price SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      ub.price-list-type SCROLLING.
DEFINE BROWSE BR-tt
  QUERY BR-tt DISPLAY
      temp-avto-price.ext-doc-type COLUMN-LABEL " ! !Тип прихода"     format "x(17)"
 temp-avto-price.gen-marg     COLUMN-LABEL "!Тип!автопереоценки"  format "x(14)"
 temp-avto-price.gen-marg-parts     COLUMN-LABEL "!Автопереоценка!по партиям"  format "x(14)"
 if temp-avto-price.objfirst = 1 then "по группе объектов"  else "по тек. объекту"     COLUMN-LABEL "Автопереоценка!на новый товар!остаток 0 " format "x(18)"
 if temp-avto-price.objsecond   = 1 then "по группе объектов"  else "по тек. объекту"  COLUMN-LABEL "Автопереоценка!на НЕ новый!товар "        format "x(18)"
 string(temp-avto-price.pr-nakl,"да/нет")      COLUMN-LABEL "Задавать!продажную цену!в док.прихода"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.63 BY 5.75 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-save AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 90
     loc_priority AT ROW 2 COL 89.5 COLON-ALIGNED
     loc_name AT ROW 2.04 COL 16.13 COLON-ALIGNED HELP
          ""
          LABEL "Тип прайс-листа" FORMAT "X(80)"
          FGCOLOR 1
     r-cur AT ROW 3.13 COL 13.63
     loc_under-type-list AT ROW 3.96 COL 1.75
     BUTTON-1 AT ROW 11.04 COL 1.88
     r-rod-price-type AT ROW 3.96 COL 44.38
     loc_under-hand-corr AT ROW 4.75 COL 1.75
     loc_fix-cource-crc-base AT ROW 5.46 COL 1.75
     loc_work-date AT ROW 5.75 COL 74.88 NO-LABEL
     loc_fix-cource-crc-doc AT ROW 6.29 COL 1.75
     l-ban-discnt AT ROW 7.04 COL 1.75 WIDGET-ID 10
     r-ban-discnt AT ROW 7.04 COL 22.63 WIDGET-ID 4
     b-ban-discnt AT ROW 7.04 COL 25.25 WIDGET-ID 6
     loc_calc-method AT ROW 8 COL 81 COLON-ALIGNED
     loc_create-price-doc AT ROW 8.04 COL 25.5 NO-LABEL
     loc_calc-increase-pc AT ROW 9 COL 81 COLON-ALIGNED
     loc_send-cassa AT ROW 9.04 COL 25.5 NO-LABEL
     loc_only-gbd AT ROW 10 COL 2.13
     loc_calc-round-method AT ROW 10 COL 81 COLON-ALIGNED
     loc_calc-round-base AT ROW 11 COL 81 COLON-ALIGNED NO-LABEL
     BUTTON-2 AT ROW 11.04 COL 16.13
     BUTTON-3 AT ROW 11.04 COL 30.38
     loc_plt-db-num AT ROW 1 COL 66.13 COLON-ALIGNED
     loc_plt-id AT ROW 1 COL 77.13 COLON-ALIGNED HELP
          ""
          LABEL "Код" FORMAT ">>>>>>>"
          FGCOLOR 1
     v-max AT ROW 3.04 COL 89.5 COLON-ALIGNED
     loc_curr-code AT ROW 3.21 COL 7.63 COLON-ALIGNED
     loc_abbr-doc AT ROW 3.21 COL 14.88 COLON-ALIGNED NO-LABEL
     loc_plt-main-id AT ROW 3.96 COL 35.5 COLON-ALIGNED
     loc_plt-main-db-num AT ROW 3.96 COL 45.88 COLON-ALIGNED NO-LABEL
     loc_rod-pt-name AT ROW 3.96 COL 48 COLON-ALIGNED NO-LABEL
     work-date-FILL-IN AT ROW 5 COL 70.13 NO-LABEL
     loc_ban-discnt AT ROW 7.13 COL 15.63 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     f-ban-discnt AT ROW 7.13 COL 26.63 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     create-price-doc-FILL-IN AT ROW 8.04 COL 1.5 NO-LABEL
     use-cassa-FILL-IN AT ROW 9.04 COL 2.38 COLON-ALIGNED NO-LABEL
     label-button-1 AT ROW 11.25 COL 3 NO-LABEL
     label-button-2 AT ROW 11.25 COL 15.25 COLON-ALIGNED NO-LABEL
     label-button-3 AT ROW 11.25 COL 29.88 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 11.96 COL 1.5
     SPACE(0.50) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         TITLE "<insert dialog title>".
DEFINE FRAME page-2
     loc_use-obj AT ROW 1.08 COL 29.88 NO-LABEL
     r-gop AT ROW 1.08 COL 51.38
     b-gop AT ROW 1.08 COL 54 WIDGET-ID 6
     v-2 AT ROW 2.08 COL 92.5 COLON-ALIGNED
     BR-tt AT ROW 2.25 COL 1.38 WIDGET-ID 100
     loc_rs-buyer AT ROW 2.67 COL 32.25 NO-LABEL
     r-gop-2 AT ROW 3.33 COL 27.75
     b-gop-2 AT ROW 3.38 COL 30.38 WIDGET-ID 2
     r-qnty-tog AT ROW 4.25 COL 27.75
     b-qnty-tog AT ROW 4.29 COL 30.38 WIDGET-ID 4
     loc_obj-turnover AT ROW 5.29 COL 30.13 NO-LABEL
     r-gop-calc AT ROW 5.29 COL 51.5
     b-gop-calc AT ROW 5.29 COL 54.13 WIDGET-ID 8
     loc_use-cassa AT ROW 6.75 COL 28.25 NO-LABEL
     v-spis-kass AT ROW 7.5 COL 1.38 NO-LABEL
     B-chga AT ROW 8 COL 87.5 WIDGET-ID 10
     r-use-obj-fill-in AT ROW 1.08 COL 1 NO-LABEL
     loc_gop-id AT ROW 1.08 COL 43.38 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT ">>>>>>>"
     loc_gop-db-num AT ROW 1.08 COL 54.88 COLON-ALIGNED NO-LABEL
     loc_gop_name-name AT ROW 1.08 COL 57.75 COLON-ALIGNED NO-LABEL
     f-ie-3 AT ROW 2.42 COL 1.88 NO-LABEL
     r-FILL-IN AT ROW 2.58 COL 1.13 NO-LABEL
     loc_bgr-id AT ROW 3.42 COL 19.25 COLON-ALIGNED
     loc_bgr-db-num AT ROW 3.5 COL 31.38 COLON-ALIGNED NO-LABEL
     loc_bgr_name AT ROW 3.5 COL 34.5 COLON-ALIGNED NO-LABEL
     loc_tog-db-num AT ROW 4.25 COL 31.38 COLON-ALIGNED NO-LABEL
     loc_tog-id AT ROW 4.29 COL 19.25 COLON-ALIGNED HELP
          ""
          LABEL "Группа оборотов  ." FORMAT ">>>>>>>"
     r-obj-fill-in AT ROW 5.29 COL 1 NO-LABEL
     loc_gop-id-for-calc-turnover AT ROW 5.29 COL 43.5 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT ">>>>>>"
     loc_gop-db-num-for-calc-turnover AT ROW 5.29 COL 55 COLON-ALIGNED NO-LABEL
     loc_gop_name-tnv AT ROW 5.29 COL 57.88 COLON-ALIGNED NO-LABEL
     loc_use-cassa_FILL-IN AT ROW 6.75 COL 1 NO-LABEL
     loc_tog_name AT ROW 4.25 COL 34.5 COLON-ALIGNED NO-LABEL
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 3 ROW 12.21
         SIZE 96.5 BY 10.79.
DEFINE FRAME page-1
     v-1 AT ROW 1 COL 81.5 COLON-ALIGNED
     loc_have-rs-qnty-group AT ROW 3.5 COL 1.5
     r-qnty-grp AT ROW 3.5 COL 46.75
     b-qnty-grp AT ROW 3.5 COL 49.75 WIDGET-ID 4
     loc_have-rs-sum-group AT ROW 4.88 COL 1.25
     r-qnty-sgr AT ROW 4.88 COL 46.5
     b-qnty-sgr AT ROW 4.88 COL 49.5 WIDGET-ID 6
     loc_have-rs-turn-group AT ROW 6.25 COL 1.5
     r-have-tog AT ROW 6.25 COL 46.5
     b-have-tog AT ROW 6.25 COL 49.5 WIDGET-ID 2
     loc_qgr-id AT ROW 3.5 COL 38.25 COLON-ALIGNED NO-LABEL
     loc_qgr-db-num AT ROW 3.5 COL 51.13 COLON-ALIGNED NO-LABEL
     loc_qg_name AT ROW 3.5 COL 54.25 COLON-ALIGNED NO-LABEL
     loc_sgr-id AT ROW 4.88 COL 38 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT ">>>>>>>"
     loc_sgr-db-num AT ROW 4.88 COL 50.88 COLON-ALIGNED NO-LABEL
     loc_sg_name AT ROW 4.88 COL 54.13 COLON-ALIGNED NO-LABEL
     loc_have-tog-db-num AT ROW 6.25 COL 50.88 COLON-ALIGNED NO-LABEL
     loc_have-tog_name AT ROW 6.25 COL 54.13 COLON-ALIGNED NO-LABEL
     loc_have-tog-id AT ROW 6.29 COL 38 COLON-ALIGNED NO-LABEL
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 3 ROW 12.17
         SIZE 96.5 BY 6.58.
DEFINE FRAME page-3
     v-3 AT ROW 1.25 COL 92.5 COLON-ALIGNED
     loc_use-gds-group AT ROW 2 COL 1.5
     loc_use-pay-type AT ROW 2.25 COL 63.63
     v-spis-group AT ROW 2.92 COL 1.5 NO-LABEL
     v-spis-type-pay AT ROW 2.96 COL 63.5 NO-LABEL
     loc_use-cash-pay AT ROW 8.04 COL 63
     v-spis-use-cash-pay AT ROW 8.75 COL 63 NO-LABEL
     F-ogran AT ROW 1.25 COL 1 NO-LABEL
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 3 ROW 12.21
         SIZE 96.5 BY 10.79.
ASSIGN FRAME page-1:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME page-2:FRAME = FRAME Dialog-Frame:HANDLE
       FRAME page-3:FRAME = FRAME Dialog-Frame:HANDLE.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BUTTON-1:AUTO-RESIZE IN FRAME Dialog-Frame      = TRUE.
ASSIGN
       BUTTON-2:AUTO-RESIZE IN FRAME Dialog-Frame      = TRUE.
ASSIGN
       BUTTON-3:AUTO-RESIZE IN FRAME Dialog-Frame      = TRUE.
ASSIGN
       label-button-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       label-button-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       label-button-3:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       loc_ban-discnt:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-max:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-2:HIDDEN IN FRAME page-2           = TRUE.
ASSIGN
       v-spis-kass:READ-ONLY IN FRAME page-2        = TRUE.
ASSIGN
       v-spis-group:READ-ONLY IN FRAME page-3        = TRUE.
ASSIGN
       v-spis-type-pay:READ-ONLY IN FRAME page-3        = TRUE.
ASSIGN
       v-spis-use-cash-pay:READ-ONLY IN FRAME page-3        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
    RUN save-proc no-error .
    if error-status :error then do:
       case return-value :
          when "page-1" then do: APPLY "CHOOSE":U TO BUTTON-1 . return no-apply. end.
          when "page-2" then do: APPLY "CHOOSE":U TO BUTTON-2 . return no-apply. end.
          when "page-3" then do: APPLY "CHOOSE":U TO BUTTON-3 . return no-apply. end.
          otherwise do: return no-apply . end.
       end case.
    end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON GO OF FRAME page-1
DO:
  MESSAGE "go page-1" VIEW-AS ALERT-BOX.
  ASSIGN FRAME PAGE-1 loc_have-rs-qnty-group loc_have-rs-sum-group loc_have-rs-turn-group loc_qgr-id loc_qgr-db-num loc_sgr-id loc_sgr-db-num loc_have-tog-db-num loc_have-tog-id .
END.
ON GO OF FRAME page-2
DO:
  MESSAGE "go page-2" VIEW-AS ALERT-BOX.
  ASSIGN FRAME PAGE-2 loc_use-obj loc_rs-buyer loc_obj-turnover loc_use-cassa loc_gop-id loc_gop-db-num loc_bgr-id loc_bgr-db-num loc_tog-db-num loc_tog-id loc_gop-id-for-calc-turnover loc_gop-db-num-for-calc-turnover .
END.
ON GO OF FRAME page-3
DO:
  MESSAGE "go page-3" VIEW-AS ALERT-BOX.
  ASSIGN FRAME PAGE-3 loc_use-gds-group loc_use-pay-type loc_use-cash-pay .
END.
ON CHOOSE OF b-ban-discnt IN FRAME Dialog-Frame
DO:
define variable v-sts as integer no-undo init -1.
define variable v-rid-list as character no-undo .
run ref/dis-ruls.w (
                     input  parParentProc
                    ,input  v-cntxt-host-code-obj
                    ,input  v-cntxt-obj-type
                    ,input  v-cntxt-obj-code
                    ,input  "":U
                    ,input  "upper-rule-num":U
                    ,input  loc_ban-discnt
                    ,input -1
                    ,input 0
                    ,input-output v-sts
                    ,input-output v-rid-list ) no-error .
END.
ON CHOOSE OF B-chga IN FRAME page-2
DO:
if not available temp-avto-price then return .
case temp-avto-price.nn :
    when 1 then do:
    run ref/chavtp.w
        ( input-output  loc_ie-gen-marg
        , input-output  loc_ie-gen-marg-parts
        , input-output  loc_ie-objfirst
        , input-output  loc_ie-objsecond
        , input-output  loc_ie-pr-nakl
        , 'ie') .
    end.
    when 2 then do:
    run ref/chavtp.w
        ( input-output  loc_iv-gen-marg
        , input-output  loc_iv-gen-marg-parts
        , input-output  loc_iv-objfirst
        , input-output  loc_iv-objsecond
        , input-output  loc_iv-pr-nakl
        , 'iv') .
    end.
    when 3 then do:
    run ref/chavtp.w
        ( input-output  loc_im-gen-marg
        , input-output  loc_im-gen-marg-parts
        , input-output  loc_im-objfirst
        , input-output  loc_im-objsecond
        , input-output  loc_im-pr-nakl
        , 'im' ) .
    end.
end case.
run make-tt (
   loc_ie-gen-marg
  ,loc_ie-gen-marg-parts
  ,loc_ie-objfirst
  ,loc_ie-objsecond
  ,loc_ie-pr-nakl
  ,loc_iv-gen-marg
  ,loc_iv-gen-marg-parts
  ,loc_iv-objfirst
  ,loc_iv-objsecond
  ,loc_iv-pr-nakl
  ,loc_im-gen-marg
  ,loc_im-gen-marg-parts
  ,loc_im-objfirst
  ,loc_im-objsecond
  ,loc_im-pr-nakl
  ).
OPEN QUERY BR-tt FOR EACH temp-avto-price.
END.
ON CHOOSE OF b-gop IN FRAME page-2
DO:
 find first ub.grp-obj-price where
            ub.grp-obj-price.gop-db-num = loc_gop-db-num and
            ub.grp-obj-price.gop-id     = loc_gop-id
            no-lock no-error .
 if error-status :error then return .
 v-t-recid  = string(recid ( ub.grp-obj-price ))  .
 run ref/gr-objpr.w ( input parparentproc , input "" , input-output v-t-recid ) .
END.
ON CHOOSE OF b-gop-2 IN FRAME page-2
DO:
  find first ub.buyer-group where
            ub.buyer-group.bgr-db-num = loc_bgr-db-num and
            ub.buyer-group.bgr-id     = loc_bgr-id
            no-lock no-error .
 if error-status :error then return .
 v-t-recid  = string(recid ( ub.buyer-group ))  .
 run ref/gr-bupr.w (input  parparentproc , "", input-output v-t-recid ).
END.
ON CHOOSE OF b-gop-calc IN FRAME page-2
DO:
 find first ub.grp-obj-price where
            ub.grp-obj-price.gop-db-num = loc_gop-db-num-for-calc-turnover and
            ub.grp-obj-price.gop-id     = loc_gop-id-for-calc-turnover
            no-lock no-error .
 if error-status :error then return .
 v-t-recid  = string(recid ( ub.grp-obj-price ))  .
 run ref/gr-objpr.w ( input parparentproc , input "" , input-output v-t-recid ) .
END.
ON CHOOSE OF b-have-tog IN FRAME page-1
DO:
 find first ub.turnover-group where
            ub.turnover-group.tog-db-num = loc_have-tog-db-num   and
            ub.turnover-group.tog-id     = loc_have-tog-id
            no-lock no-error .
 if error-status :error then return .
 v-t-recid  = string(recid ( ub.turnover-group ))  .
 run ref/gr-obupr.w (input  parparentproc ,"" , input-output v-t-recid ).
END.
ON CHOOSE OF b-qnty-grp IN FRAME page-1
DO:
 find first ub.qnty-group where
            ub.qnty-group.qgr-db-num = loc_qgr-db-num  and
            ub.qnty-group.qgr-id     = loc_qgr-id
            no-lock no-error .
 if error-status :error then return .
 v-t-recid  = string(recid ( ub.qnty-group ))  .
 run ref/gr-qupr.w (input  parparentproc ,"" ,  input-output v-t-recid ).
END.
ON CHOOSE OF b-qnty-sgr IN FRAME page-1
DO:
 find first ub.sum-group where
            ub.sum-group.sgr-db-num = loc_sgr-db-num   and
            ub.sum-group.sgr-id     = loc_sgr-id
            no-lock no-error .
 if error-status :error then return .
 v-t-recid  = string(recid ( ub.sum-group ))  .
run ref/gr-supr.w (input  parparentproc , "" ,  input-output v-t-recid ).
END.
ON CHOOSE OF b-qnty-tog IN FRAME page-2
DO:
 find first ub.turnover-group where
            ub.turnover-group.tog-db-num = loc_tog-db-num  and
            ub.turnover-group.tog-id     = loc_tog-id
            no-lock no-error .
 if error-status :error then return .
 v-t-recid  = string(recid ( ub.turnover-group ))  .
 run ref/gr-obupr.w (input  parparentproc ,"" , input-output v-t-recid ).
END.
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame
DO:
  button-1:LOAD-IMAGE-Up("adeicon\ts-up":U)        in frame Dialog-Frame .
  button-2:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame .
  button-3:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame .
  label-button-1:fgcolor in frame Dialog-Frame  = 1   .
  label-button-2:fgcolor in frame Dialog-Frame  = ?   .
  label-button-3:fgcolor in frame Dialog-Frame  = ?   .
  VIEW FRAME page-1.
  HIDE v-2 IN FRAME page-2 .
  HIDE loc_use-obj r-gop v-2 loc_rs-buyer r-gop-2 r-qnty-tog loc_obj-turnover r-gop-calc loc_use-cassa v-spis-kass r-use-obj-fill-in loc_gop-id loc_gop-db-num loc_gop_name-name r-FILL-IN loc_bgr-id loc_bgr-db-num loc_bgr_name loc_tog-db-num loc_tog-id r-obj-fill-in loc_gop-id-for-calc-turnover loc_gop-db-num-for-calc-turnover loc_gop_name-tnv loc_use-cassa_FILL-IN loc_tog_name IN FRAME page-2 .
  HIDE v-3 IN FRAME page-3 .
  HIDE v-3 loc_use-gds-group loc_use-pay-type v-spis-group v-spis-type-pay loc_use-cash-pay v-spis-use-cash-pay F-ogran IN FRAME page-3 .
  HIDE FRAME page-2.
  HIDE FRAME page-3.
  DISPLAY v-1 loc_have-rs-qnty-group r-qnty-grp loc_have-rs-sum-group r-qnty-sgr loc_have-rs-turn-group r-have-tog loc_qgr-id loc_qgr-db-num loc_qg_name loc_sgr-id loc_sgr-db-num loc_sg_name loc_have-tog-db-num loc_have-tog_name loc_have-tog-id WITH FRAME page-1 .
  RUN my_enable.
  APPLY "ENTRY":U TO v-1 IN FRAME page-1 .
  HIDE v-1 IN FRAME  PAGE-1.
END.
ON CHOOSE OF BUTTON-2 IN FRAME Dialog-Frame
DO:
  ASSIGN FRAME page-1 loc_have-rs-qnty-group loc_have-rs-sum-group loc_have-rs-turn-group loc_qgr-id loc_qgr-db-num loc_sgr-id loc_sgr-db-num loc_have-tog-db-num loc_have-tog-id.
  ASSIGN FRAME page-3 loc_use-gds-group loc_use-pay-type loc_use-cash-pay.
  button-2:LOAD-IMAGE-Up("adeicon\ts-up":U)      in frame Dialog-Frame .
  button-1:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame .
  button-3:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame .
  label-button-2:fgcolor = 1   .
  label-button-1:fgcolor = ?   .
  label-button-3:fgcolor = ?   .
  HIDE v-1 loc_have-rs-qnty-group r-qnty-grp loc_have-rs-sum-group r-qnty-sgr loc_have-rs-turn-group r-have-tog loc_qgr-id loc_qgr-db-num loc_qg_name loc_sgr-id loc_sgr-db-num loc_sg_name loc_have-tog-db-num loc_have-tog_name loc_have-tog-id IN FRAME page-1 .
  HIDE v-3 loc_use-gds-group loc_use-pay-type v-spis-group v-spis-type-pay loc_use-cash-pay v-spis-use-cash-pay F-ogran IN FRAME page-3 .
  HIDE FRAME page-1.
  HIDE FRAME page-3.
  VIEW FRAME page-2.
  DISPLAY loc_use-obj r-gop v-2 loc_rs-buyer r-gop-2 r-qnty-tog loc_obj-turnover r-gop-calc loc_use-cassa v-spis-kass r-use-obj-fill-in loc_gop-id loc_gop-db-num loc_gop_name-name r-FILL-IN loc_bgr-id loc_bgr-db-num loc_bgr_name loc_tog-db-num loc_tog-id r-obj-fill-in loc_gop-id-for-calc-turnover loc_gop-db-num-for-calc-turnover loc_gop_name-tnv loc_use-cassa_FILL-IN loc_tog_name WITH FRAME page-2.
  ENABLE loc_use-obj r-gop v-2 loc_rs-buyer r-gop-2 r-qnty-tog loc_obj-turnover r-gop-calc loc_use-cassa v-spis-kass r-use-obj-fill-in loc_gop-id loc_gop-db-num loc_gop_name-name r-FILL-IN loc_bgr-id loc_bgr-db-num loc_bgr_name loc_tog-db-num loc_tog-id r-obj-fill-in loc_gop-id-for-calc-turnover loc_gop-db-num-for-calc-turnover loc_gop_name-tnv loc_use-cassa_FILL-IN loc_tog_name WITH FRAME page-2.
  RUN my_enable .
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    run mode_add-init.
  end.
  APPLY  "ENTRY":U TO v-2 IN FRAME page-2 .
  HIDE v-2 IN FRAME  PAGE-2.
END.
ON CHOOSE OF BUTTON-3 IN FRAME Dialog-Frame
DO:
ASSIGN FRAME page-1 loc_have-rs-qnty-group loc_have-rs-sum-group loc_have-rs-turn-group loc_qgr-id loc_qgr-db-num loc_sgr-id loc_sgr-db-num loc_have-tog-db-num loc_have-tog-id.
ASSIGN FRAME page-2 loc_use-obj loc_rs-buyer loc_obj-turnover loc_use-cassa loc_gop-id loc_gop-db-num loc_bgr-id loc_bgr-db-num loc_tog-db-num loc_tog-id loc_gop-id-for-calc-turnover loc_gop-db-num-for-calc-turnover no-error .
  button-3:LOAD-IMAGE-Up("adeicon\ts-up":U)        in frame Dialog-Frame .
  button-2:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame .
  button-1:LOAD-IMAGE-Up("adeicon\ts-down":U)      in frame Dialog-Frame .
  label-button-3:fgcolor = 1   .
  label-button-2:fgcolor = ?   .
  label-button-1:fgcolor = ?   .
  HIDE v-1 loc_have-rs-qnty-group r-qnty-grp loc_have-rs-sum-group r-qnty-sgr loc_have-rs-turn-group r-have-tog loc_qgr-id loc_qgr-db-num loc_qg_name loc_sgr-id loc_sgr-db-num loc_sg_name loc_have-tog-db-num loc_have-tog_name loc_have-tog-id IN FRAME page-1 .
  HIDE loc_use-obj r-gop v-2 loc_rs-buyer r-gop-2 r-qnty-tog loc_obj-turnover r-gop-calc loc_use-cassa v-spis-kass r-use-obj-fill-in loc_gop-id loc_gop-db-num loc_gop_name-name r-FILL-IN loc_bgr-id loc_bgr-db-num loc_bgr_name loc_tog-db-num loc_tog-id r-obj-fill-in loc_gop-id-for-calc-turnover loc_gop-db-num-for-calc-turnover loc_gop_name-tnv loc_use-cassa_FILL-IN loc_tog_name IN FRAME page-2 .
  HIDE FRAME page-1.
  HIDE FRAME page-2.
  VIEW FRAME page-3.
  DISPLAY v-3 loc_use-gds-group loc_use-pay-type v-spis-group v-spis-type-pay loc_use-cash-pay v-spis-use-cash-pay F-ogran WITH FRAME page-3.
  ENABLE v-3 loc_use-gds-group loc_use-pay-type v-spis-group v-spis-type-pay loc_use-cash-pay v-spis-use-cash-pay F-ogran WITH FRAME page-3.
  RUN my_enable.
  APPLY  "ENTRY":U TO v-3 IN FRAME page-3 .
  HIDE v-3 IN FRAME  PAGE-3.
END.
ON VALUE-CHANGED OF l-ban-discnt IN FRAME Dialog-Frame
DO:
  assign l-ban-discnt.
  run tog-band .
END.
ON VALUE-CHANGED OF loc_calc-round-method IN FRAME Dialog-Frame
DO:
  if lookup( input frame Dialog-Frame loc_calc-round-method, 'Произвольно,Вверх,Коэффициент,9-99окончание':U ) > 0 then do:
     enable loc_calc-round-base with frame Dialog-Frame.
  end.
  ELSE hide loc_calc-round-base in frame Dialog-Frame.
END.
ON LEAVE OF loc_curr-code IN FRAME Dialog-Frame
DO:
  assign loc_curr-code .
END.
ON VALUE-CHANGED OF loc_have-rs-qnty-group IN FRAME page-1
DO:
  ASSIGN  loc_have-rs-qnty-group.
  IF loc_have-rs-qnty-group = TRUE THEN DO:
      assign
        loc_have-rs-sum-group  = false
        loc_have-rs-turn-group = false
        loc_have-rs-qnty-group = true
      .
      display loc_have-rs-sum-group when loc_have-rs-sum-group:visible
              loc_have-rs-turn-group  when     loc_have-rs-turn-group:visible
              loc_have-rs-qnty-group  when     loc_have-rs-qnty-group:visible
              WITH FRAME  page-1  .
      APPLY "CHOOSE":U TO r-qnty-grp.
      ENABLE r-qnty-grp WITH FRAME  page-1  .
  END.
  ELSE DO:
      ASSIGN loc_qgr-id = 0
             loc_qgr-db-num = 0
             loc_qg_name = ""
          .
      DISABLE r-qnty-grp WITH FRAME page-1 .
      IF loc_have-rs-qnty-group:VISIBLE  THEN
          DISPLAY
             loc_qgr-id
             loc_qgr-db-num
             loc_qg_name
          WITH FRAME page-1 .
  END.
END.
ON VALUE-CHANGED OF loc_have-rs-sum-group IN FRAME page-1
DO:
    ASSIGN  loc_have-rs-sum-group.
  IF loc_have-rs-sum-group = TRUE THEN DO:
      assign
        loc_have-rs-sum-group  = true
        loc_have-rs-turn-group = false
        loc_have-rs-qnty-group = false
      .
      display loc_have-rs-sum-group when loc_have-rs-sum-group:visible
              loc_have-rs-turn-group  when     loc_have-rs-turn-group:visible
              loc_have-rs-qnty-group  when     loc_have-rs-qnty-group:visible
              WITH FRAME  page-1  .
      APPLY "CHOOSE":U TO r-qnty-sgr.
      ENABLE r-qnty-sgr WITH FRAME page-1 .
  END.
  ELSE DO:
      ASSIGN loc_sgr-id = 0
             loc_sgr-db-num = 0
             loc_sg_name = ""
          .
      DISABLE r-qnty-sgr WITH FRAME page-1 .
      IF loc_have-rs-sum-group:VISIBLE  THEN
          DISPLAY
             loc_sgr-id
             loc_sgr-db-num
             loc_sg_name
          WITH FRAME page-1 .
  END.
END.
ON VALUE-CHANGED OF loc_have-rs-turn-group IN FRAME page-1
DO:
    ASSIGN  loc_have-rs-turn-group.
  IF loc_have-rs-turn-group = TRUE THEN DO:
      assign
        loc_have-rs-sum-group  = false
        loc_have-rs-qnty-group = false
      .
      display loc_have-rs-sum-group   when loc_have-rs-sum-group:visible
              loc_have-rs-turn-group  when loc_have-rs-turn-group:visible
              loc_have-rs-qnty-group  when loc_have-rs-qnty-group:visible
              WITH FRAME  page-1  .
      APPLY "CHOOSE":U TO r-have-tog.
      ENABLE r-have-tog WITH FRAME page-1 .
  END.
  ELSE DO:
      ASSIGN loc_have-tog-id = 0
             loc_have-tog-db-num = 0
             loc_have-tog_name = ""
          .
      DISABLE r-qnty-sgr WITH FRAME page-1 .
      IF loc_have-rs-sum-group:VISIBLE  THEN
          DISPLAY
             loc_have-tog-id
             loc_have-tog-db-num
             loc_have-tog_name
          WITH FRAME page-1 .
  END.
END.
ON LEAVE OF loc_name IN FRAME Dialog-Frame
DO:
  ASSIGN loc_name .
END.
ON VALUE-CHANGED OF loc_obj-turnover IN FRAME page-2
DO:
  ASSIGN  loc_obj-turnover  .
  case  loc_obj-turnover  :
    when yes then do:
      if loc_obj-turnover:visible then
      enable r-gop-calc with frame page-2 .
      apply "choose" to r-gop-calc .
    end.
    when no then do:
      disable r-gop-calc with frame page-2 .
    end.
  end case.
END.
ON VALUE-CHANGED OF loc_only-gbd IN FRAME Dialog-Frame
DO:
  ASSIGN loc_only-gbd.
  run runav.
END.
ON VALUE-CHANGED OF loc_rs-buyer IN FRAME page-2
DO:
  ASSIGN loc_rs-buyer .
  case loc_rs-buyer :
  when 0 then do:
     assign
      loc_bgr-id = 0
      loc_bgr-db-num = 0
      loc_bgr_name = ""
     .
     disable r-gop-2 with frame page-2 .
     assign
      loc_tog-id = 0
      loc_tog-db-num = 0
      loc_tog_name = ""
     .
     disable r-qnty-tog  loc_obj-turnover  r-gop-calc with frame page-2 .
     if loc_tog-id:visible   then display
     loc_tog-id
     loc_tog-db-num
     loc_tog_name
     with frame page-2 .
     if loc_bgr-id:visible   then display
     loc_bgr-id
     loc_bgr-db-num
     loc_bgr_name
     with frame page-2 .
  end.
  when 1 then do:
     APPLY "CHOOSE":U TO r-gop-2.
     enable r-gop-2 with frame page-2 .
     assign
      loc_tog-id = 0
      loc_tog-db-num = 0
      loc_tog_name = ""
     .
     disable r-qnty-tog loc_obj-turnover  r-gop-calc with frame page-2 .
     if loc_tog-id:visible   then display
     loc_tog-id
     loc_tog-db-num
     loc_tog_name
     with frame page-2 .
  end.
  when 2 then do:
     APPLY "CHOOSE":U TO r-qnty-tog.
     enable r-qnty-tog with frame page-2 .
     assign
      loc_bgr-id = 0
      loc_bgr-db-num = 0
      loc_bgr_name = ""
     .
     disable r-gop-2 with frame page-2 .
     if loc_bgr-id:visible   then display
     loc_bgr-id
     loc_bgr-db-num
     loc_bgr_name
     with frame page-2 .
     enable loc_obj-turnover  with frame page-2 .
  end.
  end case.
END.
ON VALUE-CHANGED OF loc_under-type-list IN FRAME Dialog-Frame
DO:
  assign  loc_under-type-list.
  if loc_under-type-list = true then do:
      apply "choose":u to r-rod-price-type in frame Dialog-Frame .
      enable r-rod-price-type
             loc_under-hand-corr
             with frame Dialog-Frame .
      display
          loc_plt-main-id
          loc_plt-main-db-num
          loc_rod-pt-name
      with frame Dialog-Frame .
  end.
  else do:
      assign loc_plt-main-id = 0
             loc_plt-main-db-num = 0
             loc_rod-pt-name = ""
             loc_under-hand-corr = no
      .
      hide r-rod-price-type
           loc_under-hand-corr
           loc_plt-main-id
           loc_plt-main-db-num
           loc_rod-pt-name
           in frame Dialog-Frame .
  end.
END.
ON VALUE-CHANGED OF loc_use-cash-pay IN FRAME page-3
DO:
define variable p-rid-list   as character no-undo .
define variable ii           as integer   no-undo .
define variable v-name       as character no-undo .
define buffer   buf_cash-pay for ub.cash-pay  .
for each TT_price-list-type-cash-pay : delete TT_price-list-type-cash-pay . end.
v-spis-use-cash-pay = "".
  ASSIGN loc_use-cash-pay.
  IF loc_use-cash-pay = true  THEN DO:
      DISPLAY v-spis-use-cash-pay WITH FRAME page-3.
      ENABLE v-spis-use-cash-pay WITH FRAME page-3.
      run ref/cashpays.w (
           input parparentproc
          ,input "b-sel,b-mark"
          ,input 'все':U
          ,input v-cntxt-host-code-obj
          ,input v-cntxt-obj-type
          ,input v-cntxt-obj-code
          ,output p-rid-list ) .
          if p-rid-list = "" or p-rid-list = ? then do:
             loc_use-cash-pay = false .
             display loc_use-cash-pay with frame page-3 .
             return.
          end.
          v-nn = num-entries(p-rid-list) .
          repeat ii = 1 to  v-nn :
            find first buf_cash-pay no-lock where  recid(buf_cash-pay) = integer (entry( ii , p-rid-list )) no-error .
            if available buf_cash-pay then do:
               create TT_price-list-type-cash-pay.
               assign
                 TT_price-list-type-cash-pay.cdpay-code    = buf_cash-pay.cdpay-code
                 TT_price-list-type-cash-pay.curr-code     = buf_cash-pay.curr-code
                 TT_price-list-type-cash-pay.plt-db-num    = -1
                 TT_price-list-type-cash-pay.plt-id        = -1
                 v-spis-use-cash-pay = v-spis-use-cash-pay + buf_cash-pay.obj-name  + chr(10)
               .
            end.
          end.
          DISPLAY v-spis-use-cash-pay WITH FRAME page-3.
  END.
  ELSE DO:
      HIDE v-spis-use-cash-pay IN FRAME page-3.
  END.
END.
ON VALUE-CHANGED OF loc_use-cassa IN FRAME page-2
DO:
define variable p-rid-list as character no-undo .
define variable ii         as integer   no-undo .
define buffer   buf_cash-desk for ub.cash-desk  .
for each TT_price-list-type-cassa : delete TT_price-list-type-cassa . end.
v-spis-kass = "".
  ASSIGN loc_use-cassa.
  IF loc_use-cassa = 3 THEN DO:
      DISPLAY v-spis-kass WITH FRAME page-2.
      ENABLE v-spis-kass WITH FRAME page-2.
      run ref/cashlist.w (
          parparentproc
          ,"b-sel,b-mark"
          ,'все':U
          , v-cntxt-db-num
          ,v-cntxt-host-code-obj
          ,v-cntxt-obj-type
          ,v-cntxt-obj-code
          ,?
          ,OUTPUT p-rid-list ) .
          if p-rid-list = "" or p-rid-list = ? then do:
             loc_use-cassa = 1.
             display loc_use-cassa with frame page-2 .
             return.
          end.
          v-nn = num-entries(p-rid-list).
          repeat ii = 1 to  v-nn :
            find first buf_cash-desk no-lock where  recid(buf_cash-desk) = integer (entry( ii , p-rid-list )) no-error .
            if available buf_cash-desk then do:
               create TT_price-list-type-cassa.
               assign
                 TT_price-list-type-cassa.cash-num     = buf_cash-desk.cash-num
                 TT_price-list-type-cassa.db-num       = buf_cash-desk.db-num
                 TT_price-list-type-cassa.obj-code     = buf_cash-desk.obj-code
                 TT_price-list-type-cassa.plt-db-num   = -1
                 TT_price-list-type-cassa.plt-id       = -1
                 TT_price-list-type-cassa.pos-type     = buf_cash-desk.pos-type
               .
               v-spis-kass = v-spis-kass +
               "БД:"  + string(buf_cash-desk.db-num) +
               " маг" + string(buf_cash-desk.obj-code) +
               " №"   + string (buf_cash-desk.cash-num) +
               " "    +  buf_cash-desk.pos-type
                + chr(10) .
            end.
          end.
          DISPLAY v-spis-kass WITH FRAME page-2.
  END.
  ELSE DO:
      HIDE v-spis-kass IN FRAME page-2.
  END.
END.
ON VALUE-CHANGED OF loc_use-gds-group IN FRAME page-3
DO:
define variable p-rid-list  as character no-undo .
define variable ii          as integer   no-undo .
define variable v-name      as character no-undo .
define buffer   buf_gds-grp for ub.gds-grp  .
for each TT_price-list-type-gds-grp : delete TT_price-list-type-gds-grp . end.
v-spis-group = "".
  ASSIGN loc_use-gds-group.
  IF loc_use-gds-group = true  THEN DO:
      DISPLAY v-spis-group WITH FRAME page-3.
      ENABLE v-spis-group WITH FRAME page-3.
      run ref/gds-grp.w (
          parparentproc
          ,"b-sel,b-mark"
          ,v-cntxt-obj-type
          ,v-cntxt-obj-code
          ,input-output p-rid-list ) .
          if p-rid-list = "" or p-rid-list = ? then do:
             loc_use-gds-group = false .
             display loc_use-gds-group with frame page-3 .
             return.
          end.
          v-nn = num-entries(p-rid-list) .
          repeat ii = 1 to  v-nn :
            find first buf_gds-grp no-lock where  recid(buf_gds-grp) = integer (entry( ii , p-rid-list )) no-error .
            if available buf_gds-grp then do:
               create TT_price-list-type-gds-grp.
               assign
                 TT_price-list-type-gds-grp.node-code    = buf_gds-grp.node-code
                 TT_price-list-type-gds-grp.plt-db-num   = -1
                 TT_price-list-type-gds-grp.plt-id       = -1
               .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run grpgdsnm in g#library
  (input  buf_gds-grp.node-code
  ,output v-name
  )  .
               v-spis-group = v-spis-group + v-name + chr(10) .
            end.
          end.
          DISPLAY v-spis-group WITH FRAME page-3.
  END.
  ELSE DO:
      HIDE v-spis-group IN FRAME page-3.
  END.
END.
ON VALUE-CHANGED OF loc_use-obj IN FRAME page-2
DO:
  define variable g#log as logical no-undo .
  ASSIGN loc_use-obj .
  if loc_use-obj = 1 then do:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
    if not g#log then do:
      if error-status :error then do:
        loc_use-obj = 2.
        display loc_use-obj with frame page-2.
        return.
      end.
    end.
  end.
  case loc_use-obj :
    when 1 then do:
    disable r-gop with frame page-2 .
    end.
    when 2 then do:
      if loc_use-obj:visible then
      enable r-gop with frame page-2 .
      apply "choose":u to r-gop in frame page-2 .
    end.
  end case.
END.
ON VALUE-CHANGED OF loc_use-pay-type IN FRAME page-3
DO:
define variable p-rid-list   as character no-undo .
define variable ii           as integer   no-undo .
define variable v-name       as character no-undo .
define buffer   buf_pay-type for ub.pay-type  .
for each TT_price-list-type-pay-type : delete TT_price-list-type-pay-type . end.
v-spis-type-pay = "" .
  ASSIGN loc_use-pay-type .
  IF loc_use-pay-type = true  THEN DO:
      DISPLAY v-spis-type-pay WITH FRAME page-3.
      ENABLE  v-spis-type-pay WITH FRAME page-3.
      run ref/paytype.w (
            parparentproc
          , "b-sel,b-mark"
          , output p-rid-list ) .
          if p-rid-list = "" or p-rid-list = ? then do:
             loc_use-pay-type = false .
             display loc_use-pay-type with frame page-3 .
             return.
          end.
          v-nn = num-entries(p-rid-list) .
          repeat ii = 1 to v-nn :
            find first buf_pay-type no-lock where  recid(buf_pay-type) = integer (entry( ii , p-rid-list )) no-error .
            if available buf_pay-type then do:
               create TT_price-list-type-pay-type.
               assign
                 TT_price-list-type-pay-type.pay-code     = buf_pay-type.obj-code
                 TT_price-list-type-pay-type.plt-db-num   = -1
                 TT_price-list-type-pay-type.plt-id       = -1
               .
                 v-spis-type-pay = v-spis-type-pay + buf_pay-type.obj-name + chr(10) .
            end.
          end.
          DISPLAY v-spis-type-pay WITH FRAME page-3.
  END.
  ELSE DO:
      HIDE v-spis-type-pay IN FRAME page-3.
  END.
END.
ON CHOOSE OF r-ban-discnt IN FRAME Dialog-Frame
DO:
define variable v-sts as integer no-undo init 0.
define variable v-rid-list as character no-undo .
define buffer buf_dis-rule for ub.dis-rule.
    run ref/dis-ruls.w
      ( input parparentproc
      , input v-cntxt-host-code-obj
      , input v-cntxt-obj-type
      , input v-cntxt-obj-code
      , input "b-sel"
      , input ("template-value-type=" +  '13':U + chr(44) + '11':U + chr(44) + '12':U  )
      , input 0
      , input ?
      , input 0
      , input-output v-sts
      , input-output v-rid-list)
      no-error .
find first buf_dis-rule no-lock where
     recid (buf_dis-rule) = integer (v-rid-list)
     no-error.
    if error-status :error  then do:
     assign
      loc_ban-discnt = 0
      f-ban-discnt   = ""
      l-ban-discnt   = false
      .
    end.
    else do:
      assign
        loc_ban-discnt = buf_dis-rule.templ-rl-root
        f-ban-discnt   = buf_dis-rule.des
        l-ban-discnt   = true
        .
    end.
    display
      loc_ban-discnt
      f-ban-discnt
      l-ban-discnt
      with frame Dialog-Frame .
END.
ON CHOOSE OF r-cur IN FRAME Dialog-Frame
DO:
define variable ref-rec        as recid     no-undo .
define variable loc_exch-rate  as decimal   no-undo .
define variable loc_exch-scale as decimal   no-undo .
run ref/currency.w (input  parparentproc , "b-sel", input-output ref-rec ).
if ref-rec = ? then return no-apply.
find ub.currency where recid ( ub.currency ) = ref-rec no-lock.
  assign
    loc_curr-code  = ub.currency.curr-code
    loc_abbr-doc   = ub.currency.curr-abbr
  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  loc_curr-code
  ,input  TODAY
  ,output loc_exch-rate
  ,output loc_exch-scale
  ,output loc_abbr-doc
  )  .
display
  loc_curr-code
  loc_abbr-doc
  with frame Dialog-Frame .
assign frame Dialog-Frame
  loc_curr-code
  loc_abbr-doc
.
END.
ON CHOOSE OF r-gop IN FRAME page-2
DO:
define variable ref-rec   as recid     no-undo .
define variable s-ref-rec as character no-undo .
run ref/gr-objpr.w ( input parparentproc , input "b-sel" , input-output s-ref-rec ) .
ref-rec = int(s-ref-rec).
if ref-rec = ? or ref-rec = 0 then return no-apply.
find ub.grp-obj-price where recid ( ub.grp-obj-price ) = ref-rec no-lock no-error .
if error-status :error then do:
  return no-apply .
end.
assign
  loc_gop_name-name = ub.grp-obj-price.name
  loc_gop-db-num    = ub.grp-obj-price.gop-db-num
  loc_gop-id        = ub.grp-obj-price.gop-id
.
display
 loc_gop_name-name
 loc_gop-db-num
 loc_gop-id
 with frame page-2 .
run vis-bin.
END.
ON CHOOSE OF r-gop-2 IN FRAME page-2
DO:
define variable ref-rec   as recid     no-undo .
define variable s-ref-rec as character no-undo .
run ref/gr-bupr.w (input  parparentproc , "b-sel", input-output s-ref-rec ).
ref-rec = int(s-ref-rec) .
if ref-rec = ? or ref-rec = 0  then return no-apply.
find ub.buyer-group where recid ( ub.buyer-group ) = ref-rec no-lock no-error .
if error-status :error then do:
  return no-apply .
end.
assign
  loc_bgr_name   = ub.buyer-group.name
  loc_bgr-db-num = ub.buyer-group.bgr-db-num
  loc_bgr-id     = ub.buyer-group.bgr-id
.
display
 loc_bgr_name
 loc_bgr-db-num
 loc_bgr-id
 with frame page-2
 .
run vis-bin.
END.
ON CHOOSE OF r-gop-calc IN FRAME page-2
DO:
define variable ref-rec   as recid     no-undo .
define variable s-ref-rec as character no-undo .
run ref/gr-objpr.w (input  parparentproc , "b-sel" , input-output s-ref-rec ).
ref-rec = int (s-ref-rec).
if ref-rec = ? then return no-apply.
FIND ub.grp-obj-price where recid ( ub.grp-obj-price ) = ref-rec no-lock no-error .
if error-status :error then  do:
return no-apply .
end.
assign
  loc_gop_name-tnv                 = ub.grp-obj-price.name
  loc_gop-db-num-for-calc-turnover = ub.grp-obj-price.gop-db-num
  loc_gop-id-for-calc-turnover     = ub.grp-obj-price.gop-id
.
display
 loc_gop_name-tnv
 loc_gop-db-num-for-calc-turnover
 loc_gop-id-for-calc-turnover
 with frame page-2 .
run vis-bin.
END.
ON CHOOSE OF r-have-tog IN FRAME page-1
DO:
define variable ref-rec   as recid     no-undo .
define variable s-ref-rec as character no-undo .
run ref/gr-obupr.w (input  parparentproc ,"b-sel" , input-output s-ref-rec ).
ref-rec = int(s-ref-rec).
if ref-rec = ?  or ref-rec = 0  then return no-apply.
find ub.turnover-group where recid ( ub.turnover-group ) = ref-rec no-lock no-error .
if error-status :error then do:
   return no-apply .
end.
assign
  loc_have-tog_name    = ub.turnover-group.name
  loc_have-tog-db-num  = ub.turnover-group.tog-db-num
  loc_have-tog-id      = ub.turnover-group.tog-id
.
display
 loc_have-tog_name
 loc_have-tog-db-num
 loc_have-tog-id
 with frame page-1 .
run vis-bin.
END.
ON CHOOSE OF r-qnty-grp IN FRAME page-1
DO:
define variable v-t     as character no-undo .
define variable ref-rec as recid     no-undo .
run ref/gr-qupr.w (input  parparentproc ,"b-sel" ,  input-output v-t  ).
ref-rec = int (v-t) .
if ref-rec = ? or ref-rec = 0  then do:
   return no-apply.
end.
find ub.qnty-group where recid ( ub.qnty-group ) = ref-rec no-lock no-error .
if not available ub.qnty-group then return no-apply.
assign
  loc_qg_name    = ub.qnty-group.name
  loc_qgr-db-num = ub.qnty-group.qgr-db-num
  loc_qgr-id     = ub.qnty-group.qgr-id
.
display
 loc_qg_name
 loc_qgr-db-num
 loc_qgr-id
 with frame page-1 .
 run vis-bin.
END.
ON CHOOSE OF r-qnty-sgr IN FRAME page-1
DO:
define variable ref-rec   as recid     no-undo .
define variable s-ref-rec as character no-undo .
run ref/gr-supr.w (input  parparentproc , "b-sel" ,  input-output s-ref-rec ).
ref-rec = int(s-ref-rec) .
if ref-rec = ? or ref-rec = 0  then return no-apply.
find ub.sum-group where recid ( ub.sum-group ) = ref-rec no-lock no-error .
if error-status :error then do:
return no-apply .
end.
assign
  loc_sg_name    = ub.sum-group.name
  loc_sgr-db-num = ub.sum-group.sgr-db-num
  loc_sgr-id     = ub.sum-group.sgr-id
.
display
 loc_sg_name
 loc_sgr-db-num
 loc_sgr-id
 with frame page-1 .
run vis-bin.
END.
ON CHOOSE OF r-qnty-tog IN FRAME page-2
DO:
define variable ref-rec   as recid     no-undo .
define variable s-ref-rec as character no-undo .
run ref/gr-obupr.w (input  parparentproc ,"b-sel" , input-output s-ref-rec ).
ref-rec = int(s-ref-rec) .
if ref-rec = ?  or ref-rec = 0  then return no-apply.
find ub.turnover-group where recid ( ub.turnover-group ) = ref-rec no-lock no-error .
if error-status :error then do:
return no-apply .
end.
assign
  loc_tog_name   = ub.turnover-group.name
  loc_tog-db-num = ub.turnover-group.tog-db-num
  loc_tog-id     = ub.turnover-group.tog-id
.
display
 loc_tog_name
 loc_tog-db-num
 loc_tog-id
 with frame page-2 .
run vis-bin.
END.
ON CHOOSE OF r-rod-price-type IN FRAME Dialog-Frame
DO:
define variable ref-rec   as recid     no-undo .
define variable v-ref-rec as character no-undo .
define buffer buff_price-list-type for ub.price-list-type  .
run ref/typepric.w ( input  parparentproc , "b-sel" ,  input-output v-ref-rec ) .
 ref-rec = integer (v-ref-rec) .
if ref-rec = ?  or ref-rec = 0  then return no-apply.
FIND buff_price-list-type where recid ( buff_price-list-type ) = ref-rec no-lock no-error .
if error-status :error then do:
return no-apply .
end.
define buffer parent_price-list-type for ub.price-list-type  .
if p-main-price = true  then do:
    find first parent_price-list-type  no-lock where
               parent_price-list-type.plt-id     = buff_price-list-type.plt-id  and
               parent_price-list-type.plt-db-num = buff_price-list-type.plt-db-num no-error .
    if not available parent_price-list-type then do:
       message  "Родительский прайс-лист не найден !" view-as alert-box information .
       return no-apply .
    end.
    if parent_price-list-type.stts <> integer('0':U) then do:
       message  "Родительский прайс-лист удален !" view-as alert-box information  .
       return no-apply .
    end.
    if parent_price-list-type.main = false  then do:
     message  "Родительский прайс-лист должен быть ГЛАВНЫМ !" view-as alert-box information  .
     return no-apply .
     end.
    if parent_price-list-type.under-type-list <> 0  then do:
     message  "Родительский прайс-лист не должен быть подчиненным !" view-as alert-box information  .
     return no-apply .
     end.
end.
if p-main-price = false   then do:
    find first parent_price-list-type  no-lock where
               parent_price-list-type.plt-id     = buff_price-list-type.plt-id  and
               parent_price-list-type.plt-db-num = buff_price-list-type.plt-db-num no-error .
    if not available parent_price-list-type then  do:
       message "Родительский прайс-лист не найден !" view-as alert-box information .
       return no-apply .
    end.
    if parent_price-list-type.stts <> integer('0':U) then do:
       message  "Родительский прайс-лист удален !"  view-as alert-box information .
       return no-apply .
    end.
    if parent_price-list-type.under-type-list <> 0  then do:
     message  "Родительский прайс-лист не должен быть подчиненным !" view-as alert-box information  .
     return no-apply .
     end.
end.
assign
  loc_rod-pt-name     = buff_price-list-type.name
  loc_plt-main-db-num = buff_price-list-type.plt-db-num
  loc_plt-main-id     = buff_price-list-type.plt-id
  loc_priority        = buff_price-list-type.priority
.
display
 loc_rod-pt-name
 loc_plt-main-db-num
 loc_plt-main-id
 loc_priority WHEN loc_priority <> 0
 with frame Dialog-Frame .
run enable1 in this-procedure .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BR-tt :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable g#log as logical   no-undo .
if p-mode = 'ПРОСМОТР':U then do:
   if p-main-price then do:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_global-tpl-mpl_lookup':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
   end.
   else do:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tpl-mpl_lookup':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
   end.
end.
else do:
   if p-main-price then do:
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_global-tpl-mpl_update':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
   end.
   else do:
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_tpl-mpl_update':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
   end.
end.
if not g#log then return .
  ASSIGN
      frame Dialog-Frame:TITLE = "Описание типа прайс-листа  -- " + caps(p-mode)
      label-button-1 = "Привязка"
      label-button-2 = "Распространение"
      label-button-3 = "Ограничения"
      v-spis-kass:READ-ONLY = TRUE
      .
  if p-main-price  then do:
      frame Dialog-Frame:TITLE = "Описание ГЛАВНОГО типа прайс-листа  -- " + caps(p-mode) .
  end.
  SELECT MAX( ub.price-list-type.priority ) INTO v-max FROM ub.price-list-type WHERE ub.price-list-type.stts = integer('0':U).
  display v-max with frame Dialog-Frame .
  loc_calc-method:list-items in frame Dialog-Frame  = 'Товар,УчетнаяS,Учет-рзрвS,ПриходнаяS,Старая,Новая,Объект,Накладная,Переоценка,ДокФормЦены,Накл-безНДС,Учет-НДСS,Стар-безНДС,Единая,Отсутствует,Откат_цен,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U.
    define variable p-list as character no-undo .
    run str/pr-listv.p
        (input 'Товар,УчетнаяS,Учет-рзрвS,ПриходнаяS,Старая,Новая,Объект,Накладная,Переоценка,ДокФормЦены,Накл-безНДС,Учет-НДСS,Стар-безНДС,Единая,Отсутствует,Откат_цен,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U  ,
        input 'Не-считать':U,
        output p-list
        ) .
    loc_calc-method:list-items in frame Dialog-Frame  = p-list .
  loc_calc-round-method:list-items in frame Dialog-Frame = '9-окончание,9-99окончание,Без-дробных,Произвольно,Вверх,Коэффициент,Отключено':U .
define variable par-pr-incpc  as decimal   no-undo .
define variable par-pr-rndmt  as character no-undo .
define variable par-pr-rndbs  as decimal   no-undo .
 if p-mode = 'ДОБАВЛЕНИЕ':U then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
  ,input 'overval':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'pr-incpc':U then par-pr-incpc = thbjattr_thbj-attr.property-value-decimal .
      if thbjattr_thbj-attr.prop-code = 'pr-rndmt':U then par-pr-rndmt = thbjattr_thbj-attr.property-value-character .
      if thbjattr_thbj-attr.prop-code = 'pr-rndbs':U then par-pr-rndbs = thbjattr_thbj-attr.property-value-decimal .
  end.
  assign
    loc_calc-increase-pc  = par-pr-incpc
    loc_calc-round-base   = par-pr-rndbs
  .
  case par-pr-rndmt:
    when "pr-round-9end" then
      loc_calc-round-method = '9-окончание':U.
    when "pr-round-9-99end" then
      loc_calc-round-method = '9-99окончание':U.
    when "pr-round-integer" then
      loc_calc-round-method = 'Без-дробных':U.
    when "pr-round-select" then
      loc_calc-round-method = 'Произвольно':U.
    when "pr-round-up" then
      loc_calc-round-method = 'Вверх':U.
    when "pr-round-coef" then
      loc_calc-round-method = 'Коэффициент':U.
    when "pr-round-off" then
      loc_calc-round-method = 'Отключено':U.
    otherwise
      loc_calc-round-method = 'Отключено':U.
  end case.
  if loc_calc-round-method = "" then do:
    loc_calc-round-method = 'Отключено':U.
  end.
  if loc_calc-method = "" or loc_calc-method = ?  then do:
     loc_calc-method = 'Отсутствует':U.
  end.
  if lookup( input frame Dialog-Frame loc_calc-round-method, 'Произвольно,Вверх,Коэффициент,9-99окончание':U ) > 0 then do:
    enable loc_calc-round-base with frame Dialog-Frame.
  end.
  else
    hide loc_calc-round-base in frame Dialog-Frame.
  if p-main-price = true
     then do:
         assign
            loc_create-price-doc = 1
            loc_send-cassa = 1
         .
         run avtoinit
             ( input   loc_plt-id
              ,input   loc_plt-db-num
              ,output  loc_ie-gen-marg
              ,output  loc_ie-gen-marg-parts
              ,output  loc_ie-objfirst
              ,output  loc_ie-objsecond
              ,output  loc_ie-pr-nakl
              ,output  loc_iv-gen-marg
              ,output  loc_iv-gen-marg-parts
              ,output  loc_iv-objfirst
              ,output  loc_iv-objsecond
              ,output  loc_iv-pr-nakl
              ,output  loc_im-gen-marg
              ,output  loc_im-gen-marg-parts
              ,output  loc_im-objfirst
              ,output  loc_im-objsecond
              ,output  loc_im-pr-nakl   ) .
         end.
      else do:
         assign
            loc_create-price-doc = 2
            loc_send-cassa = 2
         .
      end.
end.
  if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
     find ub.price-list-type no-lock where recid(ub.price-list-type) =  p-recid no-error .
     if error-status :error then return .
     if p-main-price = false  then do:
          run init-spis-kass.
          run init-spis-gds-grp.
     end.
     run init-spis-pay-type.
     run init-spis-cash-pay.
     run init-proc .
  end.
  run enable1 .
  if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
    if ub.price-list-type.stts = integer('1':U) then do:
      frame Dialog-Frame:TITLE = trim (frame Dialog-Frame:TITLE) + " -- УДАЛЕН !!!"    .
    end.
  end.
  APPLY "CHOOSE":U TO BUTTON-1 .
  assign
    v-x-button-1 = BUTTON-1:row
    v-x-button-2 = BUTTON-2:row
    v-x-button-3 = BUTTON-3:row
    v-y-button-1 = BUTTON-1:column
    v-y-button-2 = BUTTON-2:column
    v-y-button-3 = BUTTON-3:column
    l-x-button-1 = label-BUTTON-1:row
    l-x-button-2 = label-BUTTON-2:row
    l-x-button-3 = label-BUTTON-3:row
    l-y-button-1 = label-BUTTON-1:column
    l-y-button-2 = label-BUTTON-2:column
    l-y-button-3 = label-BUTTON-3:column
  .
   define buffer ch0_price-list-type for ub.price-list-type  .
   define variable str-inf as character no-undo .
   str-inf = "".
   find first ch0_price-list-type no-lock where
        ch0_price-list-type.stts            = integer('0':U) and
        ch0_price-list-type.under-type-list = 1 and
        ch0_price-list-type.plt-main-id     = loc_plt-id and
        ch0_price-list-type.plt-main-db-num = loc_plt-db-num  no-error .
        if available ch0_price-list-type then
           str-inf = "  -- << РОДИТЕЛЬСКИЙ >> -- "  .
    frame Dialog-Frame:TITLE = "Описание типа прайс-листа  "  + str-inf  + caps(p-mode).
    if p-main-price  then do:
        frame Dialog-Frame:TITLE = "Описание ГЛАВНОГО типа прайс-листа  -- " + str-inf  + caps(p-mode) .
    end.
    if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
      if ub.price-list-type.stts = integer('1':U)  then do:
        frame Dialog-Frame:TITLE = trim (frame Dialog-Frame:TITLE) + " -- УДАЛЕН !!!"    .
      end.
    end.
  run vis-bin.
  if p-main-price = true   then do:
  hide v-max in frame  Dialog-Frame .
  hide b-gop-2 b-qnty-tog b-gop-calc in frame page-2.
  enable b-gop with frame page-2 .
  assign
    v-x-button-3 = v-x-button-2
    v-x-button-2 = v-x-button-1
    v-y-button-3 = v-y-button-2
    v-y-button-2 = v-y-button-1
    l-x-button-3 = l-x-button-2
    l-x-button-2 = l-x-button-1
    l-y-button-3 = l-y-button-2
    l-y-button-2 = l-y-button-1
    BUTTON-2:row                  = v-x-button-2
    BUTTON-3:row                  = v-x-button-3
    BUTTON-2:column               = v-y-button-2
    BUTTON-3:column               = v-y-button-3
    label-BUTTON-2:row            = l-x-button-2
    label-BUTTON-3:row            = l-x-button-3
    label-BUTTON-2:column         = l-y-button-2
    label-BUTTON-3:column         = l-y-button-3
  .
    APPLY "CHOOSE":U TO BUTTON-2 .
    run runav in this-procedure .
  end.
  else do:
    hide loc_only-gbd  in frame Dialog-Frame .
    hide br-tt B-chga  In FRAME  page-2 .
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    run mode_add-init.
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame  .
END.
RUN disable_UI.
PROCEDURE all-mode :
define buffer buf_global-state for ub.global-state  .
define variable g-log as logical   no-undo .
    find last buf_global-state no-lock  no-error .
    if error-status :error then do:
       message "Не заданы глобальные настройки ценообразования !!!" view-as alert-box error .
       return error return-value .
    end.
    if buf_global-state.pl-use-val = false then do:
       hide
       r-cur in frame Dialog-Frame
       loc_fix-cource-crc-doc  in frame Dialog-Frame .
    end.
    if buf_global-state.pl-use-qnty-group = false then do:
       hide
       loc_have-rs-qnty-group in frame page-1
       loc_qgr-id             in frame page-1
       loc_qgr-db-num         in frame page-1
       r-qnty-grp             in frame page-1
       loc_qg_name            in frame page-1  .
    end.
    if buf_global-state.pl-use-sum-group = false then do:
       hide
       loc_have-rs-sum-group
           loc_sgr-id
           loc_sgr-db-num
           r-qnty-sgr
           loc_sg_name
       in frame page-1 .
    end.
    if buf_global-state.pl-use-grp-buy  = false then do:
       hide
       loc_bgr-id in frame page-2
       loc_bgr-db-num
       r-gop-2
       loc_bgr_name in frame page-2
       .
       g-log = loc_rs-buyer:disable ( radio-label(string(1), loc_rs-buyer:radio-buttons) ).
    end.
    if buf_global-state.pl-use-oborot-buy  = false then do:
       hide
        loc_tog-id
        loc_tog-db-num
        r-qnty-tog
        loc_tog_name
        r-obj-fill-in
        loc_obj-turnover
        loc_gop-id-for-calc-turnover
        loc_gop-db-num-for-calc-turnover
        r-gop-calc
        loc_obj-turnover
        in frame page-2 .
       hide
        loc_have-tog-id
        loc_have-tog-db-num
        r-have-tog
        loc_have-tog_name
        loc_have-rs-turn-group
        in frame page-1 .
        g-log = loc_rs-buyer:disable(radio-label("2", loc_rs-buyer:radio-buttons)).
    end.
    if buf_global-state.pl-use-oborot-buy  = false and buf_global-state.pl-use-grp-buy  = false then do:
       hide r-FILL-IN loc_rs-buyer in frame page-2 .
    end.
    if buf_global-state.pl-use-sys-date-time  = false then do:
       g-log = loc_work-date:disable(radio-label("3", loc_work-date:radio-buttons)).
    end.
    if buf_global-state.pl-use-shift-date-num  = false then do:
       g-log = loc_work-date:disable(radio-label("2", loc_work-date:radio-buttons)).
    end.
    if buf_global-state.pl-use-cassa  = false then do:
       hide
       loc_use-cassa
       loc_use-cassa_fill-in
       v-spis-kass
       in frame page-2 .
    end.
    if buf_global-state.pl-use-pay-type  = false then do:
       hide
       loc_use-pay-type in frame page-3
       v-spis-type-pay
       in frame page-3 .
    end.
    if buf_global-state.pl-use-cash-pay  = false then do:
       hide
       loc_use-cash-pay in frame page-3
       v-spis-use-cash-pay
       in frame page-3 .
    end.
    if buf_global-state.pl-use-child  = false then do:
       hide
          loc_under-type-list
          loc_plt-main-id
          loc_plt-main-db-num
          r-rod-price-type
          loc_rod-pt-name
          loc_under-hand-corr
       in frame Dialog-Frame .
    end.
END PROCEDURE.
PROCEDURE avtoinit :
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define output parameter p-ie-gen-marg  as character no-undo .
define output parameter p-ie-gen-marg-parts  as character no-undo .
define output parameter p-ie-objfirst  as integer   no-undo .
define output parameter p-ie-objsecond as integer   no-undo .
define output parameter p-ie-pr-nakl   as logical   no-undo .
define output parameter p-iv-gen-marg  as character no-undo .
define output parameter p-iv-gen-marg-parts  as character no-undo .
define output parameter p-iv-objfirst  as integer   no-undo .
define output parameter p-iv-objsecond as integer   no-undo .
define output parameter p-iv-pr-nakl   as logical   no-undo .
define output parameter p-im-gen-marg  as character no-undo .
define output parameter p-im-gen-marg-parts  as character no-undo .
define output parameter p-im-objfirst  as integer   no-undo .
define output parameter p-im-objsecond as integer   no-undo .
define output parameter p-im-pr-nakl   as logical   no-undo .
define buffer buf_price-list-type-attr for ub.price-list-type-attr  .
assign
p-ie-gen-marg  = 'no-margin':U
p-ie-gen-marg-parts  = 'no-margin':U
p-ie-objfirst  = 0
p-ie-objsecond = 1
p-ie-pr-nakl   = false
p-iv-gen-marg  = 'no-margin':U
p-iv-gen-marg-parts  = 'no-margin':U
p-iv-objfirst  = 0
p-iv-objsecond = 1
p-iv-pr-nakl   =  false
p-im-gen-marg  = 'no-margin':U
p-im-gen-marg-parts  = 'no-margin':U
p-im-objfirst  = 0
p-im-objsecond = 1
p-im-pr-nakl   = false
 .
for each  buf_price-list-type-attr no-lock where
          buf_price-list-type-attr.plt-id     = p-plt-id and
          buf_price-list-type-attr.plt-db-num = p-plt-db-num  :
  if buf_price-list-type-attr.attr-code = 'ie-gen-marg':U  then p-ie-gen-marg   = buf_price-list-type-attr.attr-value.
  if buf_price-list-type-attr.attr-code = 'ie-gen-marg-parts':U  then p-ie-gen-marg-parts   = buf_price-list-type-attr.attr-value.
  if buf_price-list-type-attr.attr-code = 'ie-objfirst':U  then p-ie-objfirst   = int(buf_price-list-type-attr.attr-value).
  if buf_price-list-type-attr.attr-code = 'ie-objsecond':U then p-ie-objsecond = int(buf_price-list-type-attr.attr-value).
  if buf_price-list-type-attr.attr-code = 'ie-pr-nakl':U   then p-ie-pr-nakl   = if buf_price-list-type-attr.attr-value = 'yes' then true  else false .
  if buf_price-list-type-attr.attr-code = 'iv-gen-marg':U  then p-iv-gen-marg   = buf_price-list-type-attr.attr-value.
  if buf_price-list-type-attr.attr-code = 'iv-gen-marg-parts':U  then p-iv-gen-marg-parts   = buf_price-list-type-attr.attr-value.
  if buf_price-list-type-attr.attr-code = 'iv-objfirst':U  then p-iv-objfirst   = int(buf_price-list-type-attr.attr-value).
  if buf_price-list-type-attr.attr-code = 'iv-objsecond':U then p-iv-objsecond = int(buf_price-list-type-attr.attr-value).
  if buf_price-list-type-attr.attr-code = 'iv-pr-nakl':U   then p-iv-pr-nakl   = if buf_price-list-type-attr.attr-value = 'yes' then true  else false .
  if buf_price-list-type-attr.attr-code = 'im-gen-marg':U  then p-im-gen-marg   = buf_price-list-type-attr.attr-value.
  if buf_price-list-type-attr.attr-code = 'im-gen-marg-parts':U  then p-im-gen-marg-parts   = buf_price-list-type-attr.attr-value.
  if buf_price-list-type-attr.attr-code = 'im-objfirst':U  then p-im-objfirst   = int(buf_price-list-type-attr.attr-value).
  if buf_price-list-type-attr.attr-code = 'im-objsecond':U then p-im-objsecond = int(buf_price-list-type-attr.attr-value).
  if buf_price-list-type-attr.attr-code = 'im-pr-nakl':U   then p-im-pr-nakl   = if buf_price-list-type-attr.attr-value = 'yes' then true  else false .
end.
run make-tt (
   p-ie-gen-marg
  ,p-ie-gen-marg-parts
  ,p-ie-objfirst
  ,p-ie-objsecond
  ,p-ie-pr-nakl
  ,p-iv-gen-marg
  ,p-iv-gen-marg-parts
  ,p-iv-objfirst
  ,p-iv-objsecond
  ,p-iv-pr-nakl
  ,p-im-gen-marg
  ,p-im-gen-marg-parts
  ,p-im-objfirst
  ,p-im-objsecond
  ,p-im-pr-nakl
  ).
END PROCEDURE.
PROCEDURE avtoper :
display br-tt B-chga  with frame  page-2 .
enable
  br-tt
  B-chga  when  p-mode <> 'ПРОСМОТР':U
  with frame  page-2 .
hide loc_gop-id-for-calc-turnover in frame  page-2 .
END PROCEDURE.
PROCEDURE avtosave :
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input parameter p-ie-gen-marg  as character no-undo .
define input parameter p-ie-gen-marg-parts  as character no-undo .
define input parameter p-ie-objfirst  as integer   no-undo .
define input parameter p-ie-objsecond as integer   no-undo .
define input parameter p-ie-pr-nakl   as logical   no-undo .
define input parameter p-iv-gen-marg  as character no-undo .
define input parameter p-iv-gen-marg-parts  as character no-undo .
define input parameter p-iv-objfirst  as integer   no-undo .
define input parameter p-iv-objsecond as integer   no-undo .
define input parameter p-iv-pr-nakl   as logical   no-undo .
define input parameter p-im-gen-marg  as character no-undo .
define input parameter p-im-gen-marg-parts  as character no-undo .
define input parameter p-im-objfirst  as integer   no-undo .
define input parameter p-im-objsecond as integer   no-undo .
define input parameter p-im-pr-nakl   as logical   no-undo .
define buffer buf_price-list-type-attr for ub.price-list-type-attr  .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = 'ie-gen-marg':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'ie-gen-marg':U
        buf_price-list-type-attr.attr-value = p-ie-gen-marg
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = 'ie-gen-marg-parts':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'ie-gen-marg-parts':U
        buf_price-list-type-attr.attr-value = p-ie-gen-marg-parts
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = 'ie-objfirst':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'ie-objfirst':U
        buf_price-list-type-attr.attr-value = string( p-ie-objfirst)
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = 'ie-objsecond':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'ie-objsecond':U
        buf_price-list-type-attr.attr-value = string(p-ie-objsecond)
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num  and
           buf_price-list-type-attr.attr-code  = 'ie-pr-nakl':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'ie-pr-nakl':U
        buf_price-list-type-attr.attr-value = string(p-ie-pr-nakl,"yes/no")
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = 'iv-gen-marg':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'iv-gen-marg':U
        buf_price-list-type-attr.attr-value = p-iv-gen-marg
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = 'iv-gen-marg-parts':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'iv-gen-marg-parts':U
        buf_price-list-type-attr.attr-value = p-iv-gen-marg-parts
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = 'iv-objfirst':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'iv-objfirst':U
        buf_price-list-type-attr.attr-value = string( p-iv-objfirst)
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = 'iv-objsecond':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'iv-objsecond':U
        buf_price-list-type-attr.attr-value = string(p-iv-objsecond)
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num  and
           buf_price-list-type-attr.attr-code  = 'iv-pr-nakl':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'iv-pr-nakl':U
        buf_price-list-type-attr.attr-value = string(p-iv-pr-nakl,"yes/no")
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = 'im-gen-marg':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'im-gen-marg':U
        buf_price-list-type-attr.attr-value = p-im-gen-marg
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = 'im-gen-marg-parts':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'im-gen-marg-parts':U
        buf_price-list-type-attr.attr-value = p-im-gen-marg-parts
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = 'im-objfirst':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'im-objfirst':U
        buf_price-list-type-attr.attr-value = string( p-im-objfirst)
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num and
           buf_price-list-type-attr.attr-code  = 'im-objsecond':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'im-objsecond':U
        buf_price-list-type-attr.attr-value = string(p-im-objsecond)
        .
find first buf_price-list-type-attr exclusive-lock where
           buf_price-list-type-attr.plt-id     = p-plt-id and
           buf_price-list-type-attr.plt-db-num = p-plt-db-num  and
           buf_price-list-type-attr.attr-code  = 'im-pr-nakl':U  no-error .
    if not available buf_price-list-type-attr then create buf_price-list-type-attr.
      assign
        buf_price-list-type-attr.plt-id     = p-plt-id
        buf_price-list-type-attr.plt-db-num = p-plt-db-num
        buf_price-list-type-attr.attr-code  = 'im-pr-nakl':U
        buf_price-list-type-attr.attr-value = string(p-im-pr-nakl,"yes/no")
        .
END PROCEDURE.
PROCEDURE avts :
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
  HIDE FRAME page-1.
  HIDE FRAME page-2.
  HIDE FRAME page-3.
END PROCEDURE.
PROCEDURE enable1 :
  define variable g#log as logical no-undo.
  OPEN QUERY Dialog-Frame FOR EACH ub.price-list-type SHARE-LOCK.
  OPEN QUERY BR-tt FOR EACH temp-avto-price.
  GET FIRST Dialog-Frame.
  DISPLAY loc_name loc_priority loc_create-price-doc loc_fix-cource-crc-base
          loc_send-cassa loc_fix-cource-crc-doc loc_calc-method
          loc_calc-increase-pc loc_calc-round-method
          loc_calc-round-base
          loc_work-date
          loc_only-gbd loc_plt-db-num loc_plt-id create-price-doc-FILL-IN
          loc_curr-code loc_abbr-doc use-cassa-FILL-IN work-date-FILL-IN
          label-button-1 label-button-2 label-button-3
          loc_under-type-list
      WITH FRAME Dialog-Frame.
  ENABLE B-save RECT-1 B-Cancel B-Help loc_name loc_priority
          r-cur loc_fix-cource-crc-base
         loc_fix-cource-crc-doc loc_calc-method loc_calc-increase-pc
         loc_calc-round-method
         loc_work-date loc_only-gbd BUTTON-2
         BUTTON-3 BUTTON-1 loc_plt-db-num loc_plt-id create-price-doc-FILL-IN
         loc_curr-code  use-cassa-FILL-IN work-date-FILL-IN
         label-button-1 label-button-2 label-button-3
         loc_under-type-list
      WITH FRAME Dialog-Frame.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g#log
    )  .
end.
    if g#log then do:
      loc_use-obj = 1.
      disable r-gop with frame page-2 .
    end.
    else do:
      loc_use-obj = 2.
      enable r-gop with frame page-2 .
    end.
  end.
  if p-main-price = false   then do:
      enable
       loc_send-cassa when p-mode = 'ДОБАВЛЕНИЕ':U
       l-ban-discnt   when p-mode = 'ДОБАВЛЕНИЕ':U
       r-ban-discnt   when p-mode = 'ДОБАВЛЕНИЕ':U
       b-ban-discnt
       with frame Dialog-Frame.
      display
       loc_ban-discnt
       f-ban-discnt
       with frame Dialog-Frame.
  end.
  run tog-band .
  if loc_under-type-list then do:
      display  loc_plt-main-id loc_plt-main-db-num loc_rod-pt-name loc_under-hand-corr  WITH FRAME Dialog-Frame.
      enable   loc_under-hand-corr with frame Dialog-Frame.
      HIDE v-3 IN FRAME page-3 .
      HIDE v-3 loc_use-gds-group loc_use-pay-type v-spis-group v-spis-type-pay loc_use-cash-pay v-spis-use-cash-pay F-ogran IN FRAME page-3 .
      HIDE v-1 IN FRAME page-1 .
      HIDE v-1 loc_have-rs-qnty-group r-qnty-grp loc_have-rs-sum-group r-qnty-sgr loc_have-rs-turn-group r-have-tog loc_qgr-id loc_qgr-db-num loc_qg_name loc_sgr-id loc_sgr-db-num loc_sg_name loc_have-tog-db-num loc_have-tog_name loc_have-tog-id IN FRAME page-1 .
      hide frame page-1  frame page-3  .
      hide  button-1 label-button-1 in frame Dialog-Frame .
      hide  button-3 label-button-3
            loc_fix-cource-crc-base
            loc_fix-cource-crc-doc
            loc_ban-discnt
            loc_only-gbd
            loc_calc-method
      in frame Dialog-Frame .
      loc_calc-increase-pc:label = "% наценки от родителя" .
      loc_calc-round-method:label = "Метод округления"     .
      APPLY "CHOOSE":U TO BUTTON-2 .
      disable  loc_under-type-list  with frame Dialog-Frame.
  end.
  if lookup( loc_calc-round-method, 'Произвольно,Вверх,Коэффициент,9-99окончание':U ) > 0 then do:
    enable loc_calc-round-base with frame Dialog-Frame.
  end.
  else
    hide loc_calc-round-base in frame Dialog-Frame.
  DISPLAY v-1 loc_have-rs-qnty-group loc_have-rs-sum-group loc_qgr-id
            loc_qgr-db-num loc_qg_name loc_sgr-id loc_sgr-db-num loc_sg_name
            loc_have-tog-id
            loc_have-tog-db-num
            r-have-tog
            loc_have-tog_name
            loc_have-rs-turn-group
      WITH FRAME page-1.
  ENABLE v-1 loc_have-rs-qnty-group r-qnty-grp loc_have-rs-sum-group r-qnty-sgr
         loc_qgr-id loc_qgr-db-num loc_qg_name loc_sgr-id loc_sgr-db-num
         loc_sg_name  loc_have-rs-turn-group
      WITH FRAME page-1.
  run vis-bin .
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH ub.price-list-type SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY loc_priority loc_name loc_under-type-list loc_fix-cource-crc-base
          loc_work-date loc_fix-cource-crc-doc l-ban-discnt loc_calc-method
          loc_create-price-doc loc_calc-increase-pc loc_send-cassa loc_only-gbd
          loc_calc-round-method loc_calc-round-base loc_plt-db-num loc_plt-id
          v-max loc_curr-code loc_abbr-doc work-date-FILL-IN loc_ban-discnt
          f-ban-discnt create-price-doc-FILL-IN use-cassa-FILL-IN label-button-1
          label-button-2 label-button-3
      WITH FRAME Dialog-Frame.
  ENABLE B-save B-Cancel B-Help RECT-1 loc_priority loc_name r-cur
         loc_under-type-list BUTTON-1 loc_fix-cource-crc-base loc_work-date
         loc_fix-cource-crc-doc l-ban-discnt b-ban-discnt loc_calc-method
         loc_calc-increase-pc loc_only-gbd loc_calc-round-method
         loc_calc-round-base BUTTON-2 BUTTON-3 loc_plt-db-num loc_plt-id
         loc_curr-code loc_abbr-doc work-date-FILL-IN loc_ban-discnt
         f-ban-discnt create-price-doc-FILL-IN use-cassa-FILL-IN
      WITH FRAME Dialog-Frame.
  DISPLAY v-1 loc_have-rs-qnty-group loc_have-rs-sum-group
          loc_have-rs-turn-group loc_qgr-id loc_qgr-db-num loc_qg_name
          loc_sgr-id loc_sgr-db-num loc_sg_name loc_have-tog-db-num
          loc_have-tog_name loc_have-tog-id
      WITH FRAME page-1.
  ENABLE v-1 loc_have-rs-qnty-group r-qnty-grp b-qnty-grp loc_have-rs-sum-group
         r-qnty-sgr b-qnty-sgr loc_have-rs-turn-group r-have-tog b-have-tog
         loc_qgr-id loc_qgr-db-num loc_qg_name loc_sgr-id loc_sgr-db-num
         loc_sg_name loc_have-tog-db-num loc_have-tog_name loc_have-tog-id
      WITH FRAME page-1.
  DISPLAY r-use-obj-fill-in loc_gop-db-num f-ie-3 loc_tog-db-num r-obj-fill-in
          loc_gop-db-num-for-calc-turnover
      WITH FRAME page-2.
  ENABLE b-gop BR-tt b-gop-2 r-qnty-tog b-qnty-tog b-gop-calc B-chga
         r-use-obj-fill-in f-ie-3 loc_tog-db-num r-obj-fill-in
      WITH FRAME page-2.
  OPEN QUERY BR-tt FOR EACH temp-avto-price.
  DISPLAY v-3
      WITH FRAME page-3.
  ENABLE v-3
      WITH FRAME page-3.
END PROCEDURE.
PROCEDURE init-proc :
assign
      loc_abbr-doc                          =    ""
      loc_ban-discnt                        =    ub.price-list-type.ban-discnt
      loc_bgr_name                          =    ""
      loc_calc-round-method                 =    ub.price-list-type.calc-round-method
      loc_calc-round-base                   =    ub.price-list-type.calc-round-base
      loc_calc-increase-pc                  =    ub.price-list-type.calc-increase-pc
      loc_calc-method                       =    ub.price-list-type.calc-method
      loc_create-price-doc                  =    ub.price-list-type.create-price-doc
      loc_fix-cource-crc-base               =    ub.price-list-type.fix-cource-crc-base
      loc_fix-cource-crc-doc                =    ub.price-list-type.fix-cource-crc-doc
      loc_gop_name-name                     =    ""
      loc_gop_name-tnv                      =    ""
      loc_have-rs-qnty-group                =    logical(ub.price-list-type.have-rs-qnty-group)
      loc_have-rs-sum-group                 =    ub.price-list-type.have-rs-sum-group
      loc_only-gbd                          =    logical(ub.price-list-type.only-gbd)
      loc_plt-main-db-num                   =    ub.price-list-type.plt-main-db-num
      loc_plt-main-id                       =    ub.price-list-type.plt-main-id
      loc_priority                          =    ub.price-list-type.priority
      loc_qg_name                           =    ""
      loc_rod-pt-name                       =    ""
      loc_rs-buyer                          =    ub.price-list-type.rs-buyer
      loc_send-cassa                        =    ub.price-list-type.send-cassa
      loc_sg_name                           =    ""
      loc_tog_name                          =    ""
      loc_under-hand-corr                   =    logical(ub.price-list-type.under-hand-corr)
      loc_under-round-method                =    ub.price-list-type.under-round-method
      loc_under-perc                        =    ub.price-list-type.under-perc
      loc_under-type-list                   =    logical(ub.price-list-type.under-type-list)
      loc_use-cassa                         =    ub.price-list-type.use-cassa
      loc_use-gds-group                     =    logical(ub.price-list-type.use-gds-group)
      loc_use-obj                           =    ub.price-list-type.use-obj
      loc_work-date                         =    ub.price-list-type.work-date
      loc_bgr-db-num                        =    ub.price-list-type.bgr-db-num
      loc_bgr-id                            =    ub.price-list-type.bgr-id
      loc_curr-code                         =    ub.price-list-type.curr-code
      loc_gop-db-num                        =    ub.price-list-type.gop-db-num
      loc_gop-db-num-for-calc-turnover      =    ub.price-list-type.gop-db-num-for-calc-turnover
      loc_gop-id                            =    ub.price-list-type.gop-id
      loc_gop-id-for-calc-turnover          =    ub.price-list-type.gop-id-for-calc-turnover
      loc_name                              =    ub.price-list-type.name
      loc_plt-db-num                        =    ub.price-list-type.plt-db-num
      loc_plt-id                            =    ub.price-list-type.plt-id
      loc_qgr-db-num                        =    ub.price-list-type.qgr-db-num
      loc_qgr-id                            =    ub.price-list-type.qgr-id
      loc_sgr-db-num                        =    ub.price-list-type.sgr-db-num
      loc_sgr-id                            =    ub.price-list-type.sgr-id
      loc_tog-db-num                        =    ub.price-list-type.tog-db-num
      loc_tog-id                            =    ub.price-list-type.tog-id
      loc_obj-turnover                      =    ub.price-list-type.obj-turnover
      loc_have-rs-turn-group                =   logical( ub.price-list-type.have-rs-turn-group)
      loc_have-tog-db-num                   =   ub.price-list-type.have-tog-db-num
      loc_have-tog-id                       =   ub.price-list-type.have-tog-id
      loc_use-cash-pay                      =   logical(ub.price-list-type.use-cash-pay )
      loc_use-pay-type                      =   logical(ub.price-list-type.use-pay-type )
      .
define buffer buf_dis-rule for ub.dis-rule  .
  if loc_ban-discnt > 0 then do:
    assign
      l-ban-discnt = true
    .
    find first buf_dis-rule no-lock where
               buf_dis-rule.templ-rl-root =  loc_ban-discnt
               no-error .
  if available buf_dis-rule then do:
      assign
        f-ban-discnt   = buf_dis-rule.des
      .
      end.
      else do:
        l-ban-discnt = false .
      end.
  end.
  else do:
    assign
      l-ban-discnt = false
    .
  end.
run  tog-band.
define variable loc_exch-rate  as decimal   no-undo .
define variable loc_exch-scale as decimal   no-undo .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  loc_curr-code
  ,input  TODAY
  ,output loc_exch-rate
  ,output loc_exch-scale
  ,output loc_abbr-doc
  )  .
find ub.qnty-group no-lock where
     ub.qnty-group.qgr-id     = loc_qgr-id     and
     ub.qnty-group.qgr-db-num = loc_qgr-db-num no-error .
if available ub.qnty-group then  loc_qg_name    = ub.qnty-group.name  .
find ub.buyer-group no-lock where
     ub.buyer-group.bgr-db-num = loc_bgr-db-num  and
     ub.buyer-group.bgr-id     = loc_bgr-id      no-error .
if available ub.buyer-group then  loc_bgr_name   = ub.buyer-group.name  .
find ub.grp-obj-price no-lock where
     ub.grp-obj-price.gop-db-num  = loc_gop-db-num     and
     ub.grp-obj-price.gop-id      = loc_gop-id         no-error .
if available ub.grp-obj-price then loc_gop_name-name = ub.grp-obj-price.name  .
find ub.grp-obj-price no-lock where
     ub.grp-obj-price.gop-db-num  = loc_gop-db-num-for-calc-turnover     and
     ub.grp-obj-price.gop-id      = loc_gop-id-for-calc-turnover         no-error .
if available ub.grp-obj-price then loc_gop_name-tnv = ub.grp-obj-price.name  .
find ub.price-list-type no-lock where
     ub.price-list-type.plt-db-num =  loc_plt-main-db-num  and
     ub.price-list-type.plt-id     =  loc_plt-main-id      no-error .
if available ub.price-list-type then loc_rod-pt-name     = ub.price-list-type.name  .
find ub.sum-group no-lock where
     ub.sum-group.sgr-db-num = loc_sgr-db-num and
     ub.sum-group.sgr-id     = loc_sgr-id     no-error .
if available ub.sum-group then loc_sg_name    = ub.sum-group.name  .
find ub.turnover-group no-lock where
     ub.turnover-group.tog-db-num = loc_tog-db-num and
     ub.turnover-group.tog-id     = loc_tog-id     no-error .
if available ub.turnover-group then loc_tog_name    = ub.turnover-group.name  .
find ub.turnover-group no-lock where
     ub.turnover-group.tog-db-num = loc_have-tog-db-num and
     ub.turnover-group.tog-id     = loc_have-tog-id     no-error .
if available ub.turnover-group then loc_have-tog_name    = ub.turnover-group.name  .
         run avtoinit
             ( input   loc_plt-id
              ,input   loc_plt-db-num
              ,output  loc_ie-gen-marg
              ,output  loc_ie-gen-marg-parts
              ,output  loc_ie-objfirst
              ,output  loc_ie-objsecond
              ,output  loc_ie-pr-nakl
              ,output  loc_iv-gen-marg
              ,output  loc_iv-gen-marg-parts
              ,output  loc_iv-objfirst
              ,output  loc_iv-objsecond
              ,output  loc_iv-pr-nakl
              ,output  loc_im-gen-marg
              ,output  loc_im-gen-marg-parts
              ,output  loc_im-objfirst
              ,output  loc_im-objsecond
              ,output  loc_im-pr-nakl   ) .
run runav.
END PROCEDURE.
PROCEDURE init-spis-cash-pay :
define buffer buf_price-list-type-cash-pay for ub.price-list-type-cash-pay  .
define buffer buf_cash-pay for ub.cash-pay  .
define variable v-name as character no-undo .
for each TT_price-list-type-cash-pay : delete TT_price-list-type-cash-pay . end.
v-spis-use-cash-pay = "".
   for each buf_price-list-type-cash-pay no-lock where
            buf_price-list-type-cash-pay.stts       = 0 and
            buf_price-list-type-cash-pay.plt-id     = ub.price-list-type.plt-id and
            buf_price-list-type-cash-pay.plt-db-num = ub.price-list-type.plt-db-num
            :
            create TT_price-list-type-cash-pay.
            BUFFER-COPY buf_price-list-type-cash-pay TO TT_price-list-type-cash-pay.
            find first buf_cash-pay no-lock   where
                 buf_cash-pay.cdpay-code  = TT_price-list-type-cash-pay.cdpay-code  and
                 buf_cash-pay.curr-code   = TT_price-list-type-cash-pay.curr-code
                 no-error .
            if available  buf_cash-pay then .
            v-spis-use-cash-pay  = v-spis-use-cash-pay +  buf_cash-pay.obj-name + v-name + chr(10) .
    end.
END PROCEDURE.
PROCEDURE init-spis-gds-grp :
do
on error undo, return error return-value
  :
define buffer buf_price-list-type-gds-grp for ub.price-list-type-gds-grp  .
define variable v-name as character no-undo .
for each TT_price-list-type-gds-grp : delete TT_price-list-type-gds-grp . end.
v-spis-group = "".
    for each buf_price-list-type-gds-grp no-lock where
            buf_price-list-type-gds-grp.stts       = 0 and
            buf_price-list-type-gds-grp.plt-id     = ub.price-list-type.plt-id and
            buf_price-list-type-gds-grp.plt-db-num = ub.price-list-type.plt-db-num
            :
            create TT_price-list-type-gds-grp.
            BUFFER-COPY buf_price-list-type-gds-grp TO TT_price-list-type-gds-grp.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run grpgdsnm in g#library
  (input  buf_price-list-type-gds-grp.node-code
  ,output v-name
  )  .
             v-spis-group = v-spis-group + v-name + chr(10) .
    end.
end.
END PROCEDURE.
PROCEDURE init-spis-kass :
do
on error undo, return error return-value
  :
define buffer buf_price-list-type-cassa for ub.price-list-type-cassa  .
for each TT_price-list-type-cassa : delete TT_price-list-type-cassa . end.
v-spis-kass = "".
    for each buf_price-list-type-cassa no-lock where
            buf_price-list-type-cassa.stts       = 0  and
            buf_price-list-type-cassa.plt-id     = ub.price-list-type.plt-id and
            buf_price-list-type-cassa.plt-db-num = ub.price-list-type.plt-db-num
            :
            create TT_price-list-type-cassa.
            BUFFER-COPY buf_price-list-type-cassa TO TT_price-list-type-cassa.
              v-spis-kass = v-spis-kass +
              "БД:"  + string ( buf_price-list-type-cassa.db-num   ) +
              " маг" + string ( buf_price-list-type-cassa.obj-code ) +
              " №"   + string ( buf_price-list-type-cassa.cash-num ) +
              " "    +  buf_price-list-type-cassa.pos-type
              + chr(10) .
    end.
end.
end procedure.
PROCEDURE init-spis-pay-type :
define buffer buf_price-list-type-pay-type for ub.price-list-type-pay-type  .
define buffer buf_pay-type for ub.pay-type  .
define variable v-name as character no-undo .
for each TT_price-list-type-pay-type : delete TT_price-list-type-pay-type . end.
v-spis-type-pay = "".
   for each buf_price-list-type-pay-type no-lock where
            buf_price-list-type-pay-type.stts       = 0 and
            buf_price-list-type-pay-type.plt-id     = ub.price-list-type.plt-id and
            buf_price-list-type-pay-type.plt-db-num = ub.price-list-type.plt-db-num
            :
            create TT_price-list-type-pay-type.
            BUFFER-COPY buf_price-list-type-pay-type TO TT_price-list-type-pay-type.
            find first buf_pay-type no-lock   where  buf_pay-type.obj-code  = TT_price-list-type-pay-type.pay-code no-error .
            if available  buf_pay-type then .
            v-spis-type-pay = v-spis-type-pay + buf_pay-type.obj-name + chr(10) .
    end.
END PROCEDURE.
PROCEDURE make-tt :
define input parameter p-ie-gen-marg  as character no-undo .
define input parameter p-ie-gen-marg-parts  as character no-undo .
define input parameter p-ie-objfirst  as integer   no-undo .
define input parameter p-ie-objsecond as integer   no-undo .
define input parameter p-ie-pr-nakl   as logical   no-undo .
define input parameter p-iv-gen-marg  as character no-undo .
define input parameter p-iv-gen-marg-parts  as character no-undo .
define input parameter p-iv-objfirst  as integer   no-undo .
define input parameter p-iv-objsecond as integer   no-undo .
define input parameter p-iv-pr-nakl   as logical   no-undo .
define input parameter p-im-gen-marg  as character no-undo .
define input parameter p-im-gen-marg-parts  as character no-undo .
define input parameter p-im-objfirst  as integer   no-undo .
define input parameter p-im-objsecond as integer   no-undo .
define input parameter p-im-pr-nakl   as logical   no-undo .
empty temp-table temp-avto-price .
create temp-avto-price.
assign
  temp-avto-price.nn             =  1
  temp-avto-price.ext-doc-type   =  "Приход внешний"
  temp-avto-price.gen-marg       =  p-ie-gen-marg
  temp-avto-price.gen-marg-parts =  p-ie-gen-marg-parts
  temp-avto-price.objfirst       =  p-ie-objfirst
  temp-avto-price.objsecond      =  p-ie-objsecond
  temp-avto-price.pr-nakl        =  p-ie-pr-nakl
.
create temp-avto-price.
assign
  temp-avto-price.nn             =  2
  temp-avto-price.ext-doc-type   =  "Внутр.перемещение"
  temp-avto-price.gen-marg       =  p-iv-gen-marg
  temp-avto-price.gen-marg-parts =  p-iv-gen-marg-parts
  temp-avto-price.objfirst       =  p-iv-objfirst
  temp-avto-price.objsecond      =  p-iv-objsecond
  temp-avto-price.pr-nakl        =  p-iv-pr-nakl
.
create temp-avto-price.
assign
  temp-avto-price.nn             =  3
  temp-avto-price.ext-doc-type   =  "Производство"
  temp-avto-price.gen-marg       =  p-im-gen-marg
  temp-avto-price.gen-marg-parts =  p-im-gen-marg-parts
  temp-avto-price.objfirst       =  p-im-objfirst
  temp-avto-price.objsecond      =  p-im-objsecond
  temp-avto-price.pr-nakl        =  p-im-pr-nakl
.
END PROCEDURE.
PROCEDURE mode_add-init :
disable r-rod-price-type    with frame Dialog-Frame  .
disable loc_under-hand-corr with frame Dialog-Frame  .
hide    r-rod-price-type
        loc_under-hand-corr
        loc_plt-main-id
        in frame Dialog-Frame  .
disable r-qnty-grp          with frame page-1  .
disable r-qnty-sgr          with frame page-1  .
if loc_use-obj = 1 then do:
  disable r-gop with frame page-2 .
end.
else do:
  enable r-gop with frame page-2 .
end.
disable loc_obj-turnover    with frame page-2 .
disable r-gop-calc          with frame page-2 .
disable r-gop-2             with frame page-2 .
disable r-qnty-tog          with frame page-2 .
define variable loc_exch-rate  as decimal   no-undo .
define variable loc_exch-scale as decimal   no-undo .
if loc_curr-code:modified = false  then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-curr in g#library
  (input  v-cntxt-host-code-obj
  ,output loc_curr-code
  )  .
end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  loc_curr-code
  ,input  today
  ,output loc_exch-rate
  ,output loc_exch-scale
  ,output loc_abbr-doc
  )  .
  display loc_curr-code
          loc_abbr-doc
          with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE my_enable :
define variable g-log as logical   no-undo .
  if p-mode = 'ДОБАВЛЕНИЕ':U or  p-mode = 'ПРОСМОТР':U then do:
     run all-mode.
  end.
  if p-mode = 'ПРОСМОТР':U then do:
     run my_lookup in this-procedure .
  end.
  if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
  find ub.price-list-type no-lock where recid(ub.price-list-type) =  p-recid no-error .
      disable
        r-cur
        loc_work-date
        loc_fix-cource-crc-doc
        with frame Dialog-Frame
        .
      disable
        loc_under-type-list
        r-rod-price-type
        loc_under-hand-corr          WHEN loc_under-type-list = false
        with frame Dialog-Frame
        .
       if  loc_under-type-list = false then do:
            hide
              loc_plt-main-id
              r-rod-price-type
              loc_under-hand-corr
              in frame Dialog-Frame
              .
       end.
       else do:
         HIDE v-3 IN FRAME page-3 .
         HIDE v-3 loc_use-gds-group loc_use-pay-type v-spis-group v-spis-type-pay loc_use-cash-pay v-spis-use-cash-pay F-ogran IN FRAME page-3 .
         HIDE v-1 IN FRAME page-1 .
         HIDE v-1 loc_have-rs-qnty-group r-qnty-grp loc_have-rs-sum-group r-qnty-sgr loc_have-rs-turn-group r-have-tog loc_qgr-id loc_qgr-db-num loc_qg_name loc_sgr-id loc_sgr-db-num loc_sg_name loc_have-tog-db-num loc_have-tog_name loc_have-tog-id IN FRAME page-1 .
         hide frame page-1  frame page-3  .
         hide  button-1 label-button-1 in frame Dialog-Frame .
         hide  button-3 label-button-3
               loc_fix-cource-crc-base
               loc_fix-cource-crc-doc
               loc_ban-discnt
               loc_only-gbd
               loc_calc-method
         in frame Dialog-Frame .
         loc_calc-increase-pc:label = "% наценки от родителя" .
         loc_calc-round-method:label = "Метод округления"     .
         APPLY "CHOOSE":U TO BUTTON-2 .
       end.
      disable
        loc_have-rs-qnty-group
        r-qnty-grp
        loc_have-rs-sum-group
        r-qnty-sgr
        loc_have-rs-turn-group
        r-have-tog
        with frame page-1
      .
    if ub.price-list-type.rs-buyer = 2 then do:
       disable r-gop-2 with frame page-2 .
    end.
    if ub.price-list-type.rs-buyer = 1 then do:
       disable r-qnty-tog   loc_obj-turnover  r-gop-calc with frame page-2 .
    end.
    if ub.price-list-type.rs-buyer = 0 then do:
       disable r-gop-2 r-qnty-tog   loc_obj-turnover  r-gop-calc with frame page-2.
    end.
    if ub.price-list-type.use-obj = 1 then do:
       disable r-gop with frame page-2.
    end.
    if ub.price-list-type.obj-turnover = false   then do:
       disable r-gop-calc with frame page-2 .
    end.
    run all-mode.
  end.
  if ( p-mode <> 'ДОБАВЛЕНИЕ':U and ub.price-list-type.main = true ) or ( p-mode = 'ДОБАВЛЕНИЕ':U and  p-main-price = true ) THEN DO:
      HIDE v-1 IN FRAME page-1
          v-1 loc_have-rs-qnty-group r-qnty-grp loc_have-rs-sum-group r-qnty-sgr loc_have-rs-turn-group r-have-tog loc_qgr-id loc_qgr-db-num loc_qg_name loc_sgr-id loc_sgr-db-num loc_sg_name loc_have-tog-db-num loc_have-tog_name loc_have-tog-id IN FRAME page-1
          .
      HIDE    v-2 IN FRAME page-2
          loc_bgr_name
          loc_bgr-db-num
          loc_bgr-id
          loc_tog-id
          loc_gop_name-tnv
          loc_gop-db-num-for-calc-turnover
          loc_obj-turnover
          loc_rs-buyer
          loc_tog_name
          loc_tog-db-num
          loc_use-cassa
          loc_use-cassa_FILL-IN
          r-FILL-IN
          r-obj-fill-in
          r-gop-2
          r-gop-calc
          r-qnty-tog
          v-spis-kass
          .
       HIDE   v-3 IN FRAME page-3
       v-3 loc_use-gds-group loc_use-pay-type v-spis-group v-spis-type-pay loc_use-cash-pay v-spis-use-cash-pay F-ogran
       IN FRAME page-3
       .
       HIDE
          loc_fix-cource-crc-doc   in frame Dialog-Frame
          loc_fix-cource-crc-base  in frame Dialog-Frame
          r-cur
          loc_priority
          button-1
          label-button-1
          button-2
          label-button-2
          button-3
          label-button-3
          RECT-1
          loc_under-type-list
          in frame Dialog-Frame .
          g-log = loc_work-date:disable(radio-label("3", loc_work-date:radio-buttons)).
          g-log = loc_work-date:disable(radio-label("2", loc_work-date:radio-buttons)).
  END.
  run vis-bin .
END PROCEDURE.
PROCEDURE my_lookup :
  disable  loc_have-rs-qnty-group loc_have-rs-sum-group loc_have-rs-turn-group loc_qgr-id loc_qgr-db-num loc_sgr-id loc_sgr-db-num loc_have-tog-db-num loc_have-tog-id  WITH FRAME page-1.
  disable  loc_use-obj loc_rs-buyer loc_obj-turnover loc_use-cassa loc_gop-id loc_gop-db-num loc_bgr-id loc_bgr-db-num loc_tog-db-num loc_tog-id loc_gop-id-for-calc-turnover loc_gop-db-num-for-calc-turnover loc_use-obj r-gop v-2 loc_rs-buyer r-gop-2 r-qnty-tog loc_obj-turnover r-gop-calc loc_use-cassa v-spis-kass r-use-obj-fill-in loc_gop-id loc_gop-db-num loc_gop_name-name r-FILL-IN loc_bgr-id loc_bgr-db-num loc_bgr_name loc_tog-db-num loc_tog-id r-obj-fill-in loc_gop-id-for-calc-turnover loc_gop-db-num-for-calc-turnover loc_gop_name-tnv loc_use-cassa_FILL-IN loc_tog_name WITH FRAME page-2.
  disable  loc_use-gds-group loc_use-pay-type loc_use-cash-pay  WITH FRAME page-3.
  disable  loc_name loc_priority loc_create-price-doc loc_fix-cource-crc-base loc_send-cassa loc_fix-cource-crc-doc loc_calc-method loc_calc-increase-pc loc_calc-round-base loc_calc-round-method loc_ban-discnt loc_work-date loc_only-gbd loc_curr-code loc_under-hand-corr loc_under-type-list loc_plt-main-id loc_plt-main-db-num  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if p-main-price = true  then  VIEW FRAME page-2.
  hide B-save in frame Dialog-Frame .
  B-Cancel:label in frame Dialog-Frame  = "Выход" .
  B-Cancel:column in frame Dialog-Frame  = 1 .
END PROCEDURE.
PROCEDURE noavtoper :
hide br-tt
in frame page-2
b-chga
in frame page-2
.
END PROCEDURE.
PROCEDURE runav :
  IF  loc_only-gbd
  THEN RUN avtoper .
  ELSE RUN noavtoper .
END PROCEDURE.
PROCEDURE save-proc :
define buffer buf_cash-pay for ub.cash-pay  .
assign frame page-1 loc_have-rs-qnty-group loc_have-rs-sum-group loc_have-rs-turn-group loc_qgr-id loc_qgr-db-num loc_sgr-id loc_sgr-db-num loc_have-tog-db-num loc_have-tog-id no-error .
if error-status :error then do:
   return error "page-1":U .
end.
if (loc_have-rs-sum-group   and loc_have-rs-turn-group )
                            or
   (loc_have-rs-qnty-group  and loc_have-rs-sum-group  )
                            or
   (loc_have-rs-qnty-group  and loc_have-rs-turn-group ) then do:
   message "Неверно задана привязка " view-as alert-box error .
   return error "Выбрать одну привязку!".
   end.
ASSIGN FRAME PAGE-2 loc_use-obj loc_rs-buyer loc_obj-turnover loc_use-cassa loc_gop-id loc_gop-db-num loc_bgr-id loc_bgr-db-num loc_tog-db-num loc_tog-id loc_gop-id-for-calc-turnover loc_gop-db-num-for-calc-turnover no-error .
if error-status :error then do:
   return error "page-2":U .
end.
ASSIGN FRAME PAGE-3 loc_use-gds-group loc_use-pay-type loc_use-cash-pay no-error .
if error-status :error then do:
   return error "page-3":U .
end.
ASSIGN frame Dialog-Frame loc_name loc_priority loc_create-price-doc loc_fix-cource-crc-base loc_send-cassa loc_fix-cource-crc-doc loc_calc-method loc_calc-increase-pc loc_calc-round-base loc_calc-round-method loc_ban-discnt loc_work-date loc_only-gbd loc_curr-code loc_under-hand-corr loc_under-type-list loc_plt-main-id loc_plt-main-db-num.
define buffer ch_price-list-type for ub.price-list-type  .
define buffer pr_price-list-type for ub.price-list-type  .
find first pr_price-list-type no-lock where
           pr_price-list-type.stts            = integer('0':U) and
           pr_price-list-type.plt-main-id     = loc_plt-id     and
           pr_price-list-type.plt-main-db-num = loc_plt-db-num no-error .
  define variable v-is-mmr as character no-undo .
  define variable par-type as character no-undo .
  define variable v-cntxt-valid           as logical   no-undo .
  define variable v-cntxt-menu-code       as integer   no-undo .
  define variable v-cntxt-menu-group-code as integer   no-undo .
  define variable v-cntxt-level           as character no-undo .
  define variable v-cntxt-host-code-obj   as integer   no-undo .
  define variable v-cntxt-obj-type        as character no-undo .
  define variable v-cntxt-obj-code        as integer   no-undo .
  define variable g#log                   as logical   no-undo .
  if p-mode = 'ИЗМЕНЕНИЕ':U and loc_use-obj = 1 then do:
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g#log
    )  .
end.
    if not g#log then do:
        message "Функция назначения цен на все объекты для данного пользователя запрещена !  Выберите группу объектов ценообразования . "
        view-as alert-box information .
        return error .
    end.
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-mmr':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-mmr
  ,output par-type
  ) no-error .
    if  error-status :error then v-is-mmr = 'no' .
    if loc_use-obj = 1   and v-is-mmr = 'yes'   then do:
      run gbl/cntxtget.p (
           INPUT  v-cntxt-db-num
         , INPUT  v-cntxt-userid
         , OUTPUT v-cntxt-valid
         , OUTPUT v-cntxt-menu-code
         , OUTPUT v-cntxt-menu-group-code
         , OUTPUT v-cntxt-level
         , OUTPUT v-cntxt-host-code-obj
         , OUTPUT v-cntxt-obj-type
         , OUTPUT v-cntxt-obj-code
      ).
      if v-cntxt-menu-group-code = 5  then do :
        message "Функция назначения цен на все объекты в Минимаркете запрещена !  Выберите группу объектов ценообразования . "
        view-as alert-box information .
        return error .
      end.
    end.
if p-main-price = true and loc_only-gbd = true
then do:
    if loc_use-obj = 1    then do:
        message "Главный прайс-лист не может быть по всем объектам ценообразования !" view-as alert-box information .
        return error .
    end.
define variable vv-obj-db-num as integer   no-undo .
define variable s-vv as character no-undo .
define variable i as integer   no-undo .
run metod-gop-obj in this-procedure ( v-cntxt-db-num , loc_gop-id , loc_gop-db-num) .
define variable locs-plt-id     as integer   no-undo .
define variable locs-plt-db-num as integer   no-undo .
define variable v-err           as logical   no-undo .
define variable v-n             as character no-undo .
define buffer old1_price-list-type for ub.price-list-type  .
define variable v-col-tp as integer   no-undo .
define variable v-ii-o   as integer   no-undo .
v-err = false .
v-ii-o = 0    .
for each x_obj-group where
:
v-ii-o = v-ii-o + 1   .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobjq in g#library2
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output locs-plt-id
  ,output locs-plt-db-num
  ,output v-col-tp
  ) no-error .
  if error-status :error then do:
     v-err = true .
     leave .
  end.
  if v-col-tp > 0 and not (
      locs-plt-id     = loc_plt-id      and
      locs-plt-db-num = loc_plt-db-num
      ) then do:
     find first old1_price-list-type no-lock where
                old1_price-list-type.plt-id     = locs-plt-id and
                old1_price-list-type.plt-db-num = locs-plt-db-num
     no-error .
     if error-status :error then do:
       v-n = ''.
     end.
     else do:
       v-n = old1_price-list-type.name .
     end.
     message substitute ( "Для объекта &1 &2 уже есть ГТПЛ для автопереоценок &3(&4) &5" , x_obj-group.obj-code , x_obj-group.obj-type , locs-plt-id , locs-plt-db-num , v-n ) view-as alert-box error  .
     v-err = true .
     leave .
  end.
end.
if v-ii-o = 0  then do:
   message "В выбранной группе нет ни одного объекта !"  view-as alert-box information .
   return error .
end.
  if error-status :error or v-err = true  then return error .
  run avts.
end.
if p-main-price = true  then do:
   if loc_send-cassa = 2 or loc_create-price-doc = 2 then do:
      message substitute ( "По главному типу прайс-листов должны создаваться переоценки и цены уходить на кассу" ) view-as alert-box error  .
      return error.
   end.
end.
else do:
   if loc_send-cassa = 1  and loc_ban-discnt = 0   then do:
      message substitute ( "На кассу по неглавному ТПЛ можно отправлять только СКИДКИ!  (установите номер шаблона скидки или поле <<ОТПРАВЛЯТЬ НА КАССЫ>> установите нет)  " ) view-as alert-box error  .
      return error.
   end.
   if loc_send-cassa = 2  and loc_ban-discnt > 0   then do:
      message substitute ( "Если установлено правило скидки, то его надо отправлять на кассы ! " ) view-as alert-box error  .
      return error.
   end.
end.
if p-main-price = true and loc_under-type-list = true then do:
   if loc_use-obj = 1    then do:
      message "Подчиненный прайс-лист по ГПЛ не может быть по всем объектам ценообразования !" view-as alert-box information .
      return error .
   end.
   else do:
      if can-find ( first ch_price-list-type no-lock where
                    ch_price-list-type.stts            = integer('0':U) and
                    ch_price-list-type.plt-main-id     = loc_plt-main-id and
                    ch_price-list-type.plt-main-db-num = loc_plt-main-db-num and
                    ch_price-list-type.gop-id          = loc_gop-id and
                    ch_price-list-type.gop-db-num      = loc_gop-db-num and
                not (ch_price-list-type.plt-id         = loc_plt-id and
                     ch_price-list-type.plt-db-num     = loc_plt-db-num )
                    )
                    then do:
                      message substitute ( "Уже есть прайс-лист с группой объектов № &1 БД &2" , loc_gop-id , loc_gop-db-num ) view-as alert-box information .
                      return error.
                    end.
   end.
end.
if p-main-price = true and loc_under-type-list = false
   and can-find ( first ch_price-list-type no-lock where
                  ch_price-list-type.stts            = integer('0':U) and
                  ch_price-list-type.plt-main-id     = loc_plt-id and
                  ch_price-list-type.plt-main-db-num = loc_plt-db-num and
                not ( ch_price-list-type.plt-id      = loc_plt-id and
                      ch_price-list-type.plt-db-num  = loc_plt-db-num )
                  )
   then do:
      if loc_use-obj = 1    then do:
          message "Родительский прайс-лист по ГПЛ не может быть по всем объектам ценообразования !" view-as alert-box information .
          return error .
      end.
      else do:
            if can-find ( first ch_price-list-type no-lock where
                    ch_price-list-type.stts            = integer('0':U) and
                    ch_price-list-type.plt-main-id     = loc_plt-id and
                    ch_price-list-type.plt-main-db-num = loc_plt-db-num and
                    ch_price-list-type.gop-id          = loc_gop-id and
                    ch_price-list-type.gop-db-num      = loc_gop-db-num and
                not (ch_price-list-type.plt-id     = loc_plt-id and
                     ch_price-list-type.plt-db-num = loc_plt-db-num )
                    ) then do:
                    message "Нельзя менять ГТПЛ, у которого есть подчиненные ТПЛ" view-as alert-box information .
                    return error.
                    end.
      end.
end.
if p-main-price = false and loc_under-type-list = true then do:
  if loc_use-obj = 1 and loc_rs-buyer = 0 then do:
     message "В сочетании параметров <все объекты> и <все группы покупателей> нельзя создавать подчиненый прайс-лист, так как нет вариантов отличия "  view-as alert-box information .
     return error.
  end.
end.
if p-main-price = false and loc_under-type-list = false
   and can-find ( first ch_price-list-type no-lock where
                  ch_price-list-type.stts            = integer('0':U) and
                  ch_price-list-type.plt-main-id     = loc_plt-id and
                  ch_price-list-type.plt-main-db-num = loc_plt-db-num and
            not (ch_price-list-type.plt-id     = loc_plt-id and
                  ch_price-list-type.plt-db-num = loc_plt-db-num )
                  )
then do:
  if loc_use-obj = 1 and loc_rs-buyer = 0 then do:
     message "В сочетании параметров <все объекты> и <все группы покупателей> нельзя создавать подчиненый прайс-лист, так как нет вариантов отличия "   view-as alert-box information .
     return error.
  end.
end.
if p-main-price = false  and loc_under-type-list = true then do:
  find first ch_price-list-type no-lock where
                ch_price-list-type.stts            = integer('0':U) and
                ch_price-list-type.plt-main-id     = loc_plt-main-id and
                ch_price-list-type.plt-main-db-num = loc_plt-main-db-num and
                ch_price-list-type.gop-id          = loc_gop-id and
                ch_price-list-type.gop-db-num      = loc_gop-db-num  and
                ch_price-list-type.bgr-id          = loc_bgr-id and
                ch_price-list-type.bgr-db-num      = loc_bgr-db-num  and
                ch_price-list-type.tog-id          = loc_tog-id and
                ch_price-list-type.tog-db-num      = loc_tog-db-num  and
                not (ch_price-list-type.plt-id     = loc_plt-id and
                     ch_price-list-type.plt-db-num = loc_plt-db-num )
                 no-error .
                if available ch_price-list-type then do:
                    message "Уже есть прайс-лист № " ch_price-list-type.plt-id "/" ch_price-list-type.plt-db-num skip
                    "с таким же набором параметров :"  skip
                    'Родительский прайс-лист:' loc_plt-main-id "/" loc_plt-main-db-num skip
                    'группа объектов    :' loc_gop-id "/"  loc_gop-db-num skip
                    'группа покупателей :' loc_bgr-id "/"  loc_bgr-db-num skip
                    'группа оборотов    :' loc_tog-id "/"  loc_tog-db-num
                    view-as alert-box information .
                    return error.
                end.
end.
if p-main-price = false and loc_under-type-list = false
   and can-find ( first ch_price-list-type no-lock where
                  ch_price-list-type.stts            = integer('0':U) and
                  ch_price-list-type.plt-main-id     = loc_plt-id and
                  ch_price-list-type.plt-main-db-num = loc_plt-db-num )
then do:
  if can-find ( first ch_price-list-type no-lock where
                ch_price-list-type.stts            = integer('0':U) and
                ch_price-list-type.plt-main-id     = loc_plt-id and
                ch_price-list-type.plt-main-db-num = loc_plt-db-num and
                ch_price-list-type.gop-id          = loc_gop-id and
                ch_price-list-type.gop-db-num      = loc_gop-db-num  and
                ch_price-list-type.bgr-id          = loc_bgr-id and
                ch_price-list-type.bgr-db-num      = loc_bgr-db-num  and
                ch_price-list-type.tog-id          = loc_tog-id and
                ch_price-list-type.tog-db-num      = loc_tog-db-num and
                not (ch_price-list-type.plt-id     = loc_plt-id and
                     ch_price-list-type.plt-db-num = loc_plt-db-num )
                ) then do:
                    message "Уже есть прайс-лист с таким же набором параметров" view-as alert-box information .
                    return error.
                end.
end.
run avtosave in this-procedure
  (  loc_plt-id
  ,  loc_plt-db-num
  ,  loc_ie-gen-marg
  ,  loc_ie-gen-marg-parts
  ,  loc_ie-objfirst
  ,  loc_ie-objsecond
  ,  loc_ie-pr-nakl
  ,  loc_iv-gen-marg
  ,  loc_iv-gen-marg-parts
  ,  loc_iv-objfirst
  ,  loc_iv-objsecond
  ,  loc_iv-pr-nakl
  ,  loc_im-gen-marg
  ,  loc_im-gen-marg-parts
  ,  loc_im-objfirst
  ,  loc_im-objsecond
  ,  loc_im-pr-nakl   ) .
define buffer buf2_price-list-type   for ub.price-list-type  .
define buffer buf2_price-doc-forming for ub.price-doc-forming  .
if p-mode <> 'ПРОСМОТР':U then do:
if loc_under-type-list = true and available pr_price-list-type then do:
    assign
        loc_calc-method         = pr_price-list-type.calc-method
        loc_create-price-doc    = pr_price-list-type.create-price-doc
        loc_fix-cource-crc-base = pr_price-list-type.fix-cource-crc-base
        loc_fix-cource-crc-doc  = pr_price-list-type.fix-cource-crc-doc
        loc_have-rs-qnty-group  = logical(pr_price-list-type.have-rs-qnty-group)
        loc_have-rs-sum-group   = pr_price-list-type.have-rs-sum-group
        loc_only-gbd            = logical(pr_price-list-type.only-gbd)
        loc_priority            = pr_price-list-type.priority
        loc_send-cassa          = pr_price-list-type.send-cassa
        loc_use-cassa           = pr_price-list-type.use-cassa
        loc_work-date           = pr_price-list-type.work-date
        loc_curr-code           = pr_price-list-type.curr-code
        loc_qgr-db-num          = pr_price-list-type.qgr-db-num
        loc_qgr-id              = pr_price-list-type.qgr-id
        loc_sgr-db-num          = pr_price-list-type.sgr-db-num
        loc_sgr-id              = pr_price-list-type.sgr-id
        loc_have-rs-turn-group  = logical(pr_price-list-type.have-rs-turn-group)
        loc_have-tog-db-num     = pr_price-list-type.have-tog-db-num
        loc_have-tog-id         = pr_price-list-type.have-tog-id
        loc_use-cash-pay        = logical(pr_price-list-type.use-cash-pay)
        loc_use-pay-type        = logical(pr_price-list-type.use-pay-type)
        .
end.
        if  p-mode = 'ИЗМЕНЕНИЕ':U and loc_priority > 0 and p-main-price = false  then do:
            if can-find ( first buf2_price-list-type no-lock where
                  buf2_price-list-type.main = false  and
                  buf2_price-list-type.stts = integer('0':U)      and
                  buf2_price-list-type.plt-db-num = loc_plt-db-num and
                  buf2_price-list-type.plt-id     = loc_plt-id  and
                  not (
                      buf2_price-list-type.bgr-id     = loc_bgr-id and
                      buf2_price-list-type.bgr-db-num = loc_bgr-db-num ))
                  then do:
                      find first buf2_price-doc-forming no-lock where
                            buf2_price-doc-forming.plt-db-num = loc_plt-db-num and
                            buf2_price-doc-forming.plt-id     = loc_plt-id     and
                            buf2_price-doc-forming.stts       = integer('3':U)
                            no-error .
                            if available buf2_price-doc-forming then do:
                              message "Изменилась группа покупателей в  ТИПе ПРАЙС-ЛИСТА !" skip
                              "ДА - изменить группу покупателей у действующих цен "      skip
                              "НЕТ - изменить группу покупателей только у новых цен "           skip
                              view-as alert-box question
                              buttons yes-no
                              update v-ok_bgr as logical.
                            end.
                  end.
        end.
        if  p-mode = 'ИЗМЕНЕНИЕ':U and loc_priority > 0 and p-main-price = false  then do:
            if can-find ( first buf2_price-list-type no-lock where
                  buf2_price-list-type.priority <> loc_priority and
                  buf2_price-list-type.main = false  and
                  buf2_price-list-type.stts = integer('0':U)      and
                  buf2_price-list-type.plt-db-num = loc_plt-db-num and
                  buf2_price-list-type.plt-id     = loc_plt-id )
                  then do:
                      find first buf2_price-doc-forming no-lock where
                            buf2_price-doc-forming.plt-db-num = loc_plt-db-num and
                            buf2_price-doc-forming.plt-id     = loc_plt-id     and
                            buf2_price-doc-forming.stts       = integer('3':U)
                            no-error .
                            if available buf2_price-doc-forming then do:
                              message "Изменился приоритет  ТИПА ПРАЙС-ЛИСТА !" skip
                              "ДА - изменить приоритет у действующих цен "      skip
                              "НЕТ - изменить приоритет у новых цен "           skip
                              view-as alert-box question
                              buttons yes-no
                              update v-ok as logical.
                            end.
                  end.
        end.
if loc_use-cash-pay then do:
 for each TT_price-list-type-cash-pay :
      if TT_price-list-type-cash-pay.curr-code <> loc_curr-code then do:
         find first buf_cash-pay no-lock where
                    buf_cash-pay.curr-code  = TT_price-list-type-cash-pay.curr-code and
                    buf_cash-pay.cdpay-code = TT_price-list-type-cash-pay.cdpay-code no-error .
         if error-status :error then do:
            message error-status :get-message(1) .
            return error return-value .
         end.
         message 'Платеж' buf_cash-pay.obj-name
         "Не соответствует валюте прайс-листа"
         view-as alert-box error .
         return error return-value .
      end.
 end.
end.
if loc_use-obj = 1 then do:
   message "Прайс-лист задан по ВСЕМ объектам ценообразования !" skip
     "Вы уверены ?"
     view-as alert-box question
     buttons yes-no
     title "Внимание !!!"
     update vv as log
    .
    if vv = false then return error return-value .
end.
else do:
 find first ub.grp-obj-price where
            ub.grp-obj-price.gop-db-num = loc_gop-db-num and
            ub.grp-obj-price.gop-id     = loc_gop-id
            no-lock no-error .
  if not available  ub.grp-obj-price  then do:
     message "Группа объектов не найдена "  view-as alert-box information .
     return error.
  end.
  if ub.grp-obj-price.stts = 1  then do:
        message "Группа объектов удалена" view-as alert-box error .
        return error  .
  end.
end.
if loc_have-rs-qnty-group then do:
 find first ub.qnty-group where
            ub.qnty-group.qgr-db-num = loc_qgr-db-num  and
            ub.qnty-group.qgr-id     = loc_qgr-id
            no-lock no-error .
    if error-status :error then do:
        message "Не найдена количественная группа" view-as alert-box error .
        return error  .
    end.
    if ub.qnty-group.stts = 1 then do:
        message "Количественная группа удалена" view-as alert-box error .
        return error  .
    end.
end.
else do:
   assign
    loc_qgr-id      = 0
    loc_qgr-db-num  = 0
   .
end.
if loc_have-rs-sum-group then do:
 find first ub.sum-group where
            ub.sum-group.sgr-db-num = loc_sgr-db-num  and
            ub.sum-group.sgr-id     = loc_sgr-id
            no-lock no-error .
    if error-status :error then do:
        message "Не найдена суммовая группа" view-as alert-box error .
        return error  .
    end.
    if ub.sum-group.stts = 1 then do:
        message "Суммовая группа удалена" view-as alert-box error .
        return error  .
    end.
end.
else do:
   assign
    loc_sgr-id      = 0
    loc_sgr-db-num  = 0
   .
end.
if loc_have-rs-turn-group then do:
 find first ub.turnover-group where
            ub.turnover-group.tog-db-num = loc_have-tog-db-num   and
            ub.turnover-group.tog-id     = loc_have-tog-id
            no-lock no-error .
    if error-status :error then do:
        message "Не найдена суммовая группа" view-as alert-box error .
        return error  .
    end.
    if ub.turnover-group.stts = 1 then do:
        message "Суммовая группа удалена" view-as alert-box error .
        return error  .
    end.
end.
else do:
   assign
    loc_have-tog-id      = 0
    loc_have-tog-db-num  = 0
   .
end.
 run type-price-list-add (
            ( if p-mode = 'ДОБАВЛЕНИЕ':U then  v-cntxt-db-num                        else loc_plt-db-num )
          , ( if p-mode = 'ДОБАВЛЕНИЕ':U then  next-value (s-plt, ub) else loc_plt-id   )
          , loc_name
          , loc_ban-discnt
          , loc_calc-round-method
          , loc_calc-round-base
          , loc_calc-increase-pc
          , loc_calc-method
          , loc_create-price-doc
          , loc_fix-cource-crc-base
          , loc_fix-cource-crc-doc
          , integer (loc_have-rs-qnty-group)
          , loc_have-rs-sum-group
          , p-main-price
          , integer (loc_only-gbd)
          , loc_plt-main-db-num
          , loc_plt-main-id
          , loc_priority
          , loc_rs-buyer
          , loc_send-cassa
          , integer (loc_under-hand-corr)
          , loc_under-round-method
          , loc_under-perc
          , integer (loc_under-type-list)
          , loc_use-cassa
          , integer (loc_use-gds-group)
          , loc_use-obj
          , loc_work-date
          , loc_bgr-db-num
          , loc_bgr-id
          , loc_curr-code
          , loc_gop-db-num
          , loc_gop-db-num-for-calc-turnover
          , loc_gop-id
          , loc_gop-id-for-calc-turnover
          , loc_qgr-db-num
          , loc_qgr-id
          , loc_sgr-db-num
          , loc_sgr-id
          , loc_tog-db-num
          , loc_tog-id
          , loc_obj-turnover
          , 0
          , v-cntxt-userid
          , v-cntxt-db-num
          , integer (loc_have-rs-turn-group)
          , loc_have-tog-db-num
          , loc_have-tog-id
          , integer (loc_use-cash-pay )
          , integer (loc_use-pay-type )
          , output  p-recid
          , input table TT_price-list-type-cassa
          , input table TT_price-list-type-gds-grp
          , input table TT_price-list-type-pay-type
          , input table TT_price-list-type-cash-pay
          ) no-error .
          if error-status :error then do:
              message
                error-status :get-message(1) skip
                return-value skip
                "Ошибка ввода"
                view-as alert-box error
              .
              return error.
          end.
        if v-ok or v-ok_bgr then do:
        if not transaction then do:
            run waitfram-show in this-procedure ("Изменение действующих цен...") .
            for each ub.price-all exclusive-lock where
                ub.price-all.plt-db-num = loc_plt-db-num and
                ub.price-all.plt-id     = loc_plt-id
                :
                if ub.price-all.plt-priority <> loc_priority   and v-ok     then ub.price-all.plt-priority = loc_priority   .
                if ub.price-all.bgr-id       <> loc_bgr-id     and v-ok_bgr then ub.price-all.bgr-id       = loc_bgr-id     .
                if ub.price-all.bgr-db-num   <> loc_bgr-db-num and v-ok_bgr then ub.price-all.bgr-db-num   = loc_bgr-db-num .
            end.
            run waitfram-hide in this-procedure  .
            end.
            else do:
               message "Нельзя выполнить массовое обновление в одной транзакции. Воспользуйтесь утилитой смены значений ТПЛ !" view-as alert-box information .
            end.
        end.
 end.
END PROCEDURE.
PROCEDURE tog-band :
  if l-ban-discnt = true then do:
     display
     loc_ban-discnt
     r-ban-discnt
     f-ban-discnt
     b-ban-discnt
     l-ban-discnt
     with frame Dialog-Frame .
  end.
  else do:
    loc_ban-discnt = 0 .
     display
     loc_ban-discnt
     r-ban-discnt
     f-ban-discnt
     b-ban-discnt
     l-ban-discnt
     with frame Dialog-Frame .
  hide
     loc_ban-discnt
     r-ban-discnt
     f-ban-discnt
     b-ban-discnt
     in frame Dialog-Frame .
  end.
END PROCEDURE.
PROCEDURE vis-bin :
if loc_have-tog-id               = 0  then hide b-have-tog in frame page-1 loc_have-tog-db-num                . else do: enable   b-have-tog with frame page-1 . display loc_have-tog-db-num              with frame page-1 . end.
if loc_qgr-id                    = 0  then hide b-qnty-grp in frame page-1 loc_qgr-db-num                     . else do: enable   b-qnty-grp with frame page-1 . display loc_qgr-db-num                   with frame page-1 . end.
if loc_sgr-id                    = 0  then hide b-qnty-sgr in frame page-1 loc_sgr-db-num                     . else do: enable   b-qnty-sgr with frame page-1 . display loc_sgr-db-num                   with frame page-1 . end.
if loc_gop-id                    = 0  then hide b-gop      in frame page-2 loc_gop-db-num                     . else do: enable   b-gop      with frame page-2 . display loc_gop-db-num                   with frame page-2 . end.
if loc_bgr-id                    = 0  then hide b-gop-2    in frame page-2 loc_bgr-db-num                     . else do: enable   b-gop-2    with frame page-2 . display loc_bgr-db-num                   with frame page-2 . end.
if loc_gop-id-for-calc-turnover  = 0  then hide b-gop-calc in frame page-2 loc_gop-db-num-for-calc-turnover   . else do: enable   b-gop-calc with frame page-2 . display loc_gop-db-num-for-calc-turnover with frame page-2 . end.
if loc_tog-id                    = 0  then hide b-qnty-tog in frame page-2 loc_tog-db-num                     . else do: enable   b-qnty-tog with frame page-2 . display loc_tog-db-num                   with frame page-2 . end.
END PROCEDURE.
