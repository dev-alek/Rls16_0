block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-crmpl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/pr-crmpl.p $":U .
define variable vss-description as character no-undo init "Процедура перехода на 15 версию по переоценкам".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_shop  for    ub.shop  .
define buffer buf_store for    ub.store  .
define variable v-curr-code as integer   no-undo .
define variable loc_calc-round-method  as character no-undo .
define variable loc_calc-round-base    as decimal   no-undo .
define variable loc_calc-increase-pc   as decimal   no-undo .
define variable loc_calc-method        as character no-undo .
define variable vcalc-round-base   as character no-undo .
define variable vcalc-increase-pc  as character no-undo .
define variable par-type as character no-undo .
define variable v-base-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as decimal   no-undo .
define variable v-curr-abbr-bv as character no-undo .
define variable v-exch-rate as decimal   no-undo .
define variable v-exch-scale as decimal   no-undo .
define variable v-curr-abbr-vd as character no-undo .
define variable v-is-base as logical   no-undo .
define variable t1 as integer   no-undo .
define variable t2 as integer   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-is-base
  )  .
loc_calc-method = 'Отсутствует':U.
t1 = time.
for each buf_shop no-lock :
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  buf_shop.host-code
  ,output v-base-code
  )  .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-curr in g#library
  (input  buf_shop.host-code
  ,output v-curr-code
  )  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-base-code
  ,input  TODAY
  ,output v-base-rate
  ,output v-base-scale
  ,output v-curr-abbr-bv
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-curr-code
  ,input  TODAY
  ,output v-exch-rate
  ,output v-exch-scale
  ,output v-curr-abbr-vd
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'pr-incpc'
  ,input  buf_shop.host-code
  ,input  'маг':U
  ,input  buf_shop.obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output vcalc-increase-pc
  ,output par-type
  ) no-error .
 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'pr-rndmt'
  ,input  buf_shop.host-code
  ,input  'маг':U
  ,input  buf_shop.obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output loc_calc-round-method
  ,output par-type
  ) no-error .
 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'pr-rndbs'
  ,input  buf_shop.host-code
  ,input  'маг':U
  ,input  buf_shop.obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output vcalc-round-base
  ,output par-type
  ) no-error .
 .
  loc_calc-increase-pc = decimal ( vcalc-increase-pc ) .
  loc_calc-round-base  = decimal ( vcalc-round-base  ) .
  case loc_calc-round-method:
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
  run proc-b in this-procedure ('маг':U , buf_shop.obj-code ) .
end.
for each buf_store no-lock :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  buf_store.host-code
  ,output v-base-code
  )  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-curr in g#library
  (input  buf_store.host-code
  ,output v-curr-code
  )  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-base-code
  ,input  TODAY
  ,output v-base-rate
  ,output v-base-scale
  ,output v-curr-abbr-bv
  )  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-curr-code
  ,input  TODAY
  ,output v-exch-rate
  ,output v-exch-scale
  ,output v-curr-abbr-vd
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'pr-incpc'
  ,input  buf_store.host-code
  ,input  'скл':U
  ,input  buf_store.obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output vcalc-increase-pc
  ,output par-type
  ) no-error .
 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'pr-rndmt'
  ,input  buf_store.host-code
  ,input  'скл':U
  ,input  buf_store.obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output loc_calc-round-method
  ,output par-type
  ) no-error .
 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'pr-rndbs'
  ,input  buf_store.host-code
  ,input  'скл':U
  ,input  buf_store.obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output vcalc-round-base
  ,output par-type
  ) no-error .
 .
   loc_calc-increase-pc = decimal ( vcalc-increase-pc ) .
   loc_calc-round-base  = decimal ( vcalc-round-base  ) .
  case loc_calc-round-method:
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
   run proc-b in this-procedure ('скл':U , buf_store.obj-code ) .
end.
run waitfram-hide in this-procedure.
t2 = time.
message "Все"  string ( t2 - t1  , "hh:mm:ss" ) .
procedure proc-b :
define input  parameter p-type as character no-undo .
define input  parameter p-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable  p-gop-id as integer no-undo .
define variable  p-recid  as recid   no-undo .
do
on error undo :
p-gop-id = next-value ( s-gop , ub ) .
create ub.grp-obj-price.
assign
  ub.grp-obj-price.gop-db-num   = v-cntxt-db-num
  ub.grp-obj-price.gop-id       = p-gop-id
  ub.grp-obj-price.db-num-chg   = v-cntxt-db-num
  ub.grp-obj-price.stts         = 0
  ub.grp-obj-price.sys-date     = today
  ub.grp-obj-price.sys-time     = time
  ub.grp-obj-price.sys-time-chr = string(ub.grp-obj-price.sys-time,"hh:mm")
  ub.grp-obj-price.who          = v-cntxt-userid
  ub.grp-obj-price.name-group   = "По объекту " + p-type + string ( p-code )
  .
  run  objo-ADD (
    input  v-cntxt-db-num  ,
    input  p-gop-id            ,
    input  p-type  ,
    input  p-code  ,
    input  0               ,
    input  v-cntxt-db-num  ,
    input  v-cntxt-userid  ,
    output p-recid ) .
define variable v-plt-id as integer   no-undo .
find first ub.price-list-type no-lock where
           ub.price-list-type.main = true and
           ub.price-list-type.gop-id = p-gop-id and
           ub.price-list-type.gop-db-num = v-cntxt-db-num and
           ub.price-list-type.stts       = integer('0':U) and
           ub.price-list-type.plt-db-num = v-cntxt-db-num no-error .
    if available ub.price-list-type then do:
       v-plt-id = ub.price-list-type.plt-id .
    end.
    else do:
    v-plt-id = next-value (s-plt, ub)  .
        run type-price-list-ADD (
            v-cntxt-db-num
          , v-plt-id
          , "ГТПЛ по объекту " + p-type + string (p-code)
          , int ( true )
          , loc_calc-round-method
          , loc_calc-round-base
          , loc_calc-increase-pc
          , loc_calc-method
          , int ( true )
          , false
          , false
          , int ( false )
          , false
          , true
          , int ( false )
          , v-cntxt-db-num
          ,  ?
          ,  0
          ,  0
          ,  true
          ,  int  ( true  )
          ,  ?
          ,  ?
          ,  int ( false )
          ,  0
          ,  int ( false )
          ,  2
          ,  0
          ,  v-cntxt-db-num
          ,  ?
          ,  v-curr-code
          ,  v-cntxt-db-num
          ,  v-cntxt-db-num
          ,  p-gop-id
          ,  ?
          ,  v-cntxt-db-num
          ,  ?
          ,  v-cntxt-db-num
          ,  ?
          ,  v-cntxt-db-num
          ,  ?
          ,  ?
          ,  v-cntxt-db-num
          ,  v-cntxt-userid
          ,  v-cntxt-db-num
          ,  int( false )
          ,  0
          ,  ?
          ,  int( false  )
          ,  int( false  )
          ,  output p-recid
          ,  input table TT_cassa
          ,  input table TT_grp
          ,  input table TT_pay-type
          ,  input table TT_cash-pay
          ) no-error .
          find first ub.price-list-type no-lock where recid(ub.price-list-type) =  p-recid no-error .
     end.
 end.
define variable v-pdf as integer   no-undo .
define variable v-line-num   as integer   no-undo .
define variable v-excise-base       as decimal   no-undo .
define variable v-excise-doc        as decimal   no-undo .
define variable v-excise-rubl       as decimal   no-undo .
define variable v-price-calc-base   as decimal   no-undo .
define variable v-price-calc-doc    as decimal   no-undo .
define variable v-price-calc-rubl   as decimal   no-undo .
define variable v-price-prev-base   as decimal   no-undo .
define variable v-price-prev-doc    as decimal   no-undo .
define variable v-price-prev-rubl   as decimal   no-undo .
define variable v-price-sale-base   as decimal   no-undo .
define variable v-price-sale-doc    as decimal   no-undo .
define variable v-price-sale-rubl   as decimal   no-undo .
define variable v-road-tax-base     as decimal   no-undo .
define variable v-road-tax-doc      as decimal   no-undo .
define variable v-road-tax-rubl     as decimal   no-undo .
define variable   v-b-code          as integer   no-undo .
define variable   v-doc-num         as character no-undo .
define variable   v-price-sale      as decimal   no-undo .
define variable   v-road-tax        as decimal   no-undo .
define variable   v-excise          as decimal   no-undo .
v-line-num = 0 .
find first ub.price-doc-forming no-lock where
           ub.price-doc-forming.stts       = integer('0':U) and
           ub.price-doc-forming.plt-id     = ub.price-list-type.plt-id and
           ub.price-doc-forming.plt-db-num = ub.price-list-type.plt-db-num no-error .
  if available ub.price-doc-forming then do:
    v-pdf = ub.price-doc-forming.plt-id .
  end.
  else do:
   v-pdf = next-value ( s-pdf , ub ) .
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id            = v-plt-id
      ub.price-doc-forming.plt-db-num        = v-cntxt-db-num
      ub.price-doc-forming.pdf-id            = v-pdf
      ub.price-doc-forming.pdf-db            = v-cntxt-db-num
      ub.price-doc-forming.base-rate         = v-base-rate
      ub.price-doc-forming.base-scale        = v-base-scale
      ub.price-doc-forming.db-num-chg        = v-cntxt-db-num
      ub.price-doc-forming.exch-rate         = v-exch-rate
      ub.price-doc-forming.exch-scale        = v-exch-scale
      ub.price-doc-forming.stts              = integer('0':U)
      ub.price-doc-forming.sys-date          = today
      ub.price-doc-forming.sys-time          = time
      ub.price-doc-forming.sys-time-chr      = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who               = v-cntxt-userid
      ub.price-doc-forming.name              = "ДНЦ при переходе на 15v "  + p-type + string (p-code)
      ub.price-doc-forming.have-start-period = int( false )
      ub.price-doc-forming.start-sys-date    = ?
      ub.price-doc-forming.start-shift-num   = ?
      ub.price-doc-forming.start-shift-date  = ?
      ub.price-doc-forming.have-end-period   = int ( false  )
      ub.price-doc-forming.end-sys-date      = ?
      ub.price-doc-forming.end-shift-num     = ?
      ub.price-doc-forming.end-date          = ?
      ub.price-doc-forming.end-shift-date    = ?
      ub.price-doc-forming.out-code          = if available ub.price-doc then ub.price-doc.out-code else ""
      ub.price-doc-forming.start-date        = if available ub.price-doc then ub.price-doc.fact-date  else ?
      .
  end.
define variable v-main-b-code as integer   no-undo .
define variable v-type-price as integer   no-undo .
define buffer buf_goods    for ub.goods     .
define buffer buf_gds-prt  for ub.gds-prt   .
  for each ub.gds-obj no-lock where
           ub.gds-obj.obj-type = p-type and
           ub.gds-obj.obj-code = p-code :
       find first buf_goods    no-lock where buf_goods.gds-code   = ub.gds-obj.gds-code .
       run waitfram-show in this-procedure ( buf_goods.artic + " " + p-type + string(p-code) ) .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.gds-obj.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
       for each ub.bar-code no-lock where
           ub.bar-code.gds-code = ub.gds-obj.gds-code:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-type
  ,input  p-code
  ,input  ub.bar-code.b-code
  ,input  0
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
        if error-status :error = false and v-doc-num <> ?  then do:
         find first ub.price-list no-lock where
                    ub.price-list.doc-num = v-doc-num and
                    ub.price-list.price-type = ""     and
                    ub.price-list.b-code  = ub.bar-code.b-code no-error .
         if not available ub.price-list then next.
      find first ub.price-doc no-lock where
                 ub.price-doc.doc-num = v-doc-num and
            not (
            ub.price-doc.pdf-id               = v-pdf and
            ub.price-doc.pdf-db               = v-cntxt-db-num and
            ub.price-doc.plt-id               = v-plt-id and
            ub.price-doc.plt-db-num           = v-cntxt-db-num ) no-error .
       if available ub.price-doc then do:
           find current ub.price-doc exclusive-lock no-error .
           assign
            ub.price-doc.pdf-id               = v-pdf
            ub.price-doc.pdf-db               = v-cntxt-db-num
            ub.price-doc.plt-id               = v-plt-id
            ub.price-doc.plt-db-num           = v-cntxt-db-num
            ub.price-doc-forming.start-date   = ub.price-doc.fact-date
           .
       end.
      if v-is-base = true then do:
      assign
        v-excise-base      = ub.price-list.excise
        v-price-calc-base  = ub.price-list.price-calc
        v-price-prev-base  = ub.price-list.price-prev
        v-price-sale-base  = ub.price-list.price-sale
        v-road-tax-base    = ub.price-list.road-tax
        v-excise-rubl       = v-excise-base       * v-base-rate / v-base-scale
        v-price-calc-rubl   = v-price-calc-base   * v-base-rate / v-base-scale
        v-price-prev-rubl   = v-price-prev-base   * v-base-rate / v-base-scale
        v-price-sale-rubl   = v-price-sale-base   * v-base-rate / v-base-scale
        v-road-tax-rubl     = v-road-tax-base     * v-base-rate / v-base-scale
        v-excise-doc      = v-excise-base
        v-price-calc-doc  = v-price-calc-base
        v-price-prev-doc  = v-price-prev-base
        v-price-sale-doc  = v-price-sale-base
        v-road-tax-doc    = v-road-tax-base
      .
      end.
      else do:
      assign
        v-excise-rubl     = ub.price-list.excise
        v-price-calc-rubl = ub.price-list.price-calc
        v-price-prev-rubl = ub.price-list.price-prev
        v-price-sale-rubl = ub.price-list.price-sale
        v-road-tax-rubl   = ub.price-list.road-tax
        v-excise-base     = v-excise-rubl     / v-base-rate * v-base-scale
        v-price-calc-base = v-price-calc-rubl / v-base-rate * v-base-scale
        v-price-prev-base = v-price-prev-rubl / v-base-rate * v-base-scale
        v-price-sale-base = v-price-sale-rubl / v-base-rate * v-base-scale
        v-road-tax-base   = v-road-tax-rubl   / v-base-rate * v-base-scale
        v-excise-doc      = v-excise-rubl
        v-price-calc-doc  = v-price-calc-rubl
        v-price-prev-doc  = v-price-prev-rubl
        v-price-sale-doc  = v-price-sale-rubl
        v-road-tax-doc    = v-road-tax-rubl
      .
      end.
      find first ub.price-doc no-lock where
                 ub.price-doc.doc-num = ub.price-list.doc-num no-error .
      v-line-num  = v-line-num   + 1.
      create ub.price-doc-forming-gds.
      buffer-copy ub.price-doc-forming to ub.price-doc-forming-gds
      assign
          ub.price-doc-forming-gds.line-num        = v-line-num
          ub.price-doc-forming-gds.b-code          = ub.price-list.b-code
          ub.price-doc-forming-gds.artic           = ub.price-list.artic
          ub.price-doc-forming-gds.prod-code       = ub.price-list.prod-code
          ub.price-doc-forming-gds.prod-type       = ub.price-list.prod-type
          ub.price-doc-forming-gds.calc-method     = ub.price-list.calc-method
          ub.price-doc-forming-gds.d-pcnt          = ub.price-list.d-pcnt
          ub.price-doc-forming-gds.excise-base     = v-excise-base
          ub.price-doc-forming-gds.excise-doc      = v-excise-doc
          ub.price-doc-forming-gds.excise-rubl     = v-excise-rubl
          ub.price-doc-forming-gds.price-calc-base = v-price-calc-base
          ub.price-doc-forming-gds.price-calc-doc  = v-price-calc-doc
          ub.price-doc-forming-gds.price-calc-rubl = v-price-calc-rubl
          ub.price-doc-forming-gds.price-prev-base = v-price-prev-base
          ub.price-doc-forming-gds.price-prev-doc  = v-price-prev-doc
          ub.price-doc-forming-gds.price-prev-rubl = v-price-prev-rubl
          ub.price-doc-forming-gds.price-sale-base = v-price-sale-base
          ub.price-doc-forming-gds.price-sale-doc  = v-price-sale-doc
          ub.price-doc-forming-gds.price-sale-rubl = v-price-sale-rubl
          ub.price-doc-forming-gds.road-tax-base   = v-road-tax-base
          ub.price-doc-forming-gds.road-tax-doc    = v-road-tax-doc
          ub.price-doc-forming-gds.road-tax-rubl   = v-road-tax-rubl
          ub.price-doc-forming-gds.slt-pc          = ub.price-list.slt-pc
          ub.price-doc-forming-gds.vat-pc          = ub.price-list.vat-pc
      .
         find first buf_gds-prt  no-lock where buf_gds-prt.node-code = ub.bar-code.node-code.
         if buf_goods.unit-base = ub.bar-code.unit-cli then do:
             if buf_gds-prt.upper-code = buf_goods.prt-root
               then v-type-price  = integer ('0':U) .
               else v-type-price  = integer ('2':U) .
         end.
         else do:
             if buf_gds-prt.upper-code = buf_goods.prt-root
               then v-type-price  = integer ('0':U) .
               else v-type-price  = integer ('1':U) .
         end.
         create ub.price-all.
         assign
            ub.price-all.main-indication = 0
            ub.price-all.type-price      = if ub.bar-code.b-code = v-main-b-code then 0  else 1
            ub.price-all.pal-db-num      = v-cntxt-db-num
            ub.price-all.pal-id          = next-value ( s-pal , ub )
            ub.price-all.b-code          = ub.price-doc-forming-gds.b-code
            ub.price-all.gds-code        = ub.bar-code.gds-code
            ub.price-all.obj-code        = p-code
            ub.price-all.obj-type        = p-TYPE
            ub.price-all.bgr-db-num      = 0
            ub.price-all.bgr-id          = 0
            ub.price-all.curr-code       = ub.price-list-type.curr-code
            ub.price-all.pdf-id               = ub.price-doc-forming-gds.pdf-id
            ub.price-all.pdf-db               = ub.price-doc-forming-gds.pdf-db
            ub.price-all.pdf-base-rate        = v-base-rate
            ub.price-all.pdf-base-scale       = v-base-scale
            ub.price-all.pdf-exch-rate        = v-exch-rate
            ub.price-all.pdf-exch-scale       = v-exch-scale
            ub.price-all.plt-id               = ub.price-doc-forming-gds.plt-id
            ub.price-all.plt-db-num           = ub.price-doc-forming-gds.plt-db-num
            ub.price-all.plt-fix-cource-crc-base   = ub.price-list-type.fix-cource-crc-base
            ub.price-all.plt-fix-cource-crc-doc    = ub.price-list-type.fix-cource-crc-doc
            ub.price-all.plt-priority           = ub.price-list-type.priority
            ub.price-all.plt-work-date          = ub.price-list-type.work-date
            ub.price-all.qnty-from              = ?
            ub.price-all.qnty-to                = ?
            ub.price-all.sum-from               = ?
            ub.price-all.sum-to                 = ?
            ub.price-all.turnover-from          = ?
            ub.price-all.turnover-to            = ?
            ub.price-all.tog-db-num             = 0
            ub.price-all.tog-id                 = 0
            ub.price-all.use-cash-pay           = ub.price-list-type.use-cash-pay
            ub.price-all.use-pay-type           = ub.price-list-type.use-pay-type
            ub.price-all.price-sale             = ub.price-list.price-sale
            ub.price-all.start-date             =  ub.price-doc-forming.start-date
            ub.price-all.start-shift-date       =  ub.price-doc-forming.start-shift-date
            ub.price-all.start-shift-name       =  ub.price-doc-forming.start-shift-name
            ub.price-all.start-shift-num        =  ub.price-doc-forming.start-shift-num
            ub.price-all.start-sys-date         =  ub.price-doc-forming.start-sys-date
            ub.price-all.start-sys-time         =  ub.price-doc-forming.start-sys-time
            ub.price-all.end-date               =  ub.price-doc-forming.end-date
            ub.price-all.end-shift-date         =  ub.price-doc-forming.end-shift-date
            ub.price-all.end-shift-name         =  ub.price-doc-forming.end-shift-name
            ub.price-all.end-shift-num          =  ub.price-doc-forming.end-shift-num
            ub.price-all.end-sys-date           =  ub.price-doc-forming.end-sys-date
            ub.price-all.end-sys-time           =  ub.price-doc-forming.end-sys-time
            ub.price-all.fact-order-shift-from  = ?
            ub.price-all.fact-order-shift-to   = ?
            ub.price-all.fact-order-sys-from   = ?
            ub.price-all.fact-order-sys-to     = ?
            ub.price-all.extra-pcnt            = ?
            ub.price-all.extra-round           = ?
            ub.price-all.work-acc-price        = ?
            ub.price-all.work-acc-price        = ?
            ub.price-all.out-code    =  v-doc-num
            ub.price-all.status_     =  ub.price-doc.status_
            ub.price-all.last-pr     = true
            ub.price-all.fact-order  =  ub.price-doc.fact-order
            .
      end.
   end.
   end.
   find current ub.price-doc-forming exclusive-lock .
   if not can-find (first ub.price-doc-forming-gds no-lock   where
            ub.price-doc-forming-gds.pdf-id               = ub.price-doc-forming.pdf-id and
            ub.price-doc-forming-gds.pdf-db               = ub.price-doc-forming.pdf-db and
            ub.price-doc-forming-gds.plt-id               = ub.price-doc-forming.plt-id   and
            ub.price-doc-forming-gds.plt-db-num           = ub.price-doc-forming.plt-db-num ) then
                 delete ub.price-doc-forming .
            else ub.price-doc-forming.stts = integer('3':U)  .
  end.
end procedure.
