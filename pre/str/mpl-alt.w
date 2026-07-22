define input  parameter parParentProc as widget-handle no-undo.
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-doc-rec  as recid no-undo .
define input  parameter doc-mode as character no-undo .
define input  parameter mode     as character no-undo .
define input  parameter p-b-code like ub.bar-code.b-code   no-undo.
define input-output parameter round-method as character    no-undo.
define input-output parameter round-base   as decimal no-undo.
define input-output parameter v-sec as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список неосновных цен приказа переоценки".
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
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define new shared buffer buf_base_bar-code for ub.bar-code.
define buffer buf_base_goods    for ub.goods.
define variable mark       as character                     no-undo.
define variable mark-list  as character                     no-undo.
define variable arg-base   like ub.price-doc-forming-gds.price-sale-doc no-undo.
define variable calc-dtl   as character                     no-undo.
define variable main-bc-br like ub.bar-code.b-code       no-undo.
define variable v-base-b-code like ub.bar-code.b-code       no-undo.
define variable v-line-num   as integer   no-undo .
define variable ref-list  as character                     no-undo.
define variable code-rec  as recid                    no-undo.
define variable filter-point as character no-undo init "mpl-alt" .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define new global shared variable g#libbcrcn as handle no-undo .
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION fnc-base-price RETURN decimal (local-bc      as integer,
                                        local-doc-num as char).
define buffer base-price        for ub.price-list.
define variable local-main-code like ub.bar-code.b-code no-undo.
define variable local-base-code like ub.bar-code.b-code no-undo.
  run prc-base-code (input local-bc, output local-base-code).
  find base-price no-lock where
       base-price.doc-num = local-doc-num and
       base-price.b-code  = local-base-code and
       base-price.price-type = "" no-error.
  if not available base-price then do:
    run prc-main-code (input local-bc, output local-main-code).
    find  base-price no-lock where
          base-price.doc-num = local-doc-num and
          base-price.b-code  = local-main-code and
          base-price.price-type = "" no-error.
  end.
  if available base-price then
    return (base-price.price-sale).
  else
    return (?).
END FUNCTION.
procedure prc-main-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-main-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code        for ub.bar-code.
define buffer local-goods           for ub.goods.
define buffer main-code             for ub.bar-code.
define buffer main-prt              for ub.gds-prt.
  local-main-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find first  main-prt no-lock where
              main-prt.upper-code = local-goods.prt-root.
  find  main-code no-lock where
        main-code.gds-code  = local-bar-code.gds-code and
        main-code.in-code   = "" and
        main-code.part-code = "" and
        main-code.unit-cli  = local-goods.unit-base and
        main-code.node-code = main-prt.node-code.
  local-main-code = main-code.b-code.
end procedure.
procedure prc-base-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-base-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code for ub.bar-code.
define buffer local-goods    for ub.goods.
define buffer base-code      for ub.bar-code.
  local-base-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find base-code no-lock where
       base-code.gds-code  = local-bar-code.gds-code and
       base-code.node-code = local-bar-code.node-code and
       base-code.in-code   = local-bar-code.in-code and
       base-code.part-code = local-bar-code.part-code and
       base-code.unit-cli  = local-goods.unit-base.
  local-base-code = base-code.b-code.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ver-modificator-price-is-null :
 do
 on error undo, return error return-value
 :
define input parameter p-artic     like ub.goods.artic no-undo.
define input parameter p-prod-type like ub.goods.prod-type no-undo.
define input parameter p-prod-code like ub.goods.prod-code no-undo.
define input parameter p-obj-type  like ub.clients.obj-type no-undo.
define input parameter p-obj-code  like ub.clients.obj-code no-undo.
define output parameter p-ret as logical no-undo .
define variable v-gds-code  like ub.goods.gds-code no-undo .
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
p-ret = true .
find first buf_fbr-gds-obj no-lock where
            buf_fbr-gds-obj.gds-code = v-gds-code and
            buf_fbr-gds-obj.obj-code = p-obj-code and
            buf_fbr-gds-obj.obj-type = p-obj-type use-index pi no-error .
 if available buf_fbr-gds-obj then
              if buf_fbr-gds-obj.is-modificator = true and
                 buf_fbr-gds-obj.is-null-price = true
                 then  p-ret = false .
 end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prcreate-new-price-doc :
do
on error undo, return error return-value
:
define input  parameter p-curr-db-num  as integer   no-undo .
define input  parameter p-obj-type     like ub.price-doc.obj-type no-undo.
define input  parameter p-obj-code     like ub.price-doc.obj-code no-undo.
define input  parameter p-plt-id       as integer   no-undo .
define input  parameter p-plt-db-num   as integer   no-undo .
define input  parameter p-pdf-id       as integer   no-undo .
define input  parameter p-pdf-db-num   as integer   no-undo .
define output parameter p-price-doc-recid  as recid                no-undo.
define variable v-host-code         like ub.sysconf.host-code        no-undo.
define variable v-obj-current-date  like ub.price-doc.doc-date      no-undo.
define variable v-base-rate    like ub.price-doc-forming.base-rate   no-undo .
define variable v-base-scale   like ub.price-doc-forming.base-scale  no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming.
define buffer buf_price-doc         for ub.price-doc.
find first buf_price-doc-forming no-lock where
           buf_price-doc-forming.pdf-db     = p-pdf-db-num and
           buf_price-doc-forming.pdf-id     = p-pdf-id     and
           buf_price-doc-forming.plt-db-num = p-plt-db-num and
           buf_price-doc-forming.plt-id     = p-plt-id
           no-error .
if not available buf_price-doc-forming and p-plt-id = ? then do:
   run create_new_price-doc-forming
        ( input p-obj-type ,
          input p-obj-code ,
          output p-pdf-db-num ,
          output p-pdf-id ,
          output p-plt-db-num ,
          output p-plt-id
          ).
    find first buf_price-doc-forming no-lock where
              buf_price-doc-forming.pdf-db     = p-pdf-db-num and
              buf_price-doc-forming.pdf-id     = p-pdf-id     and
              buf_price-doc-forming.plt-db-num = p-plt-db-num and
              buf_price-doc-forming.plt-id     = p-plt-id
              no-error .
end.
    create buf_price-doc .
    run doc-code in this-procedure
    (input  "main",
     input  p-obj-type  ,
     input  p-obj-code  ,
     input  ?,
     output buf_price-doc.doc-num) no-error.
    if error-status:error then do:
      message vss-workfile vss-revision vss-description skip
             error-status :get-message(1)
            "Ошибка при генерации номера документа." return-value view-as alert-box error.
      return error.
    end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    v-obj-current-date  = today .
    if not (buf_price-doc-forming.base-rate = 0 or buf_price-doc-forming.base-rate = ?) then do:
        v-base-rate   =  buf_price-doc-forming.base-rate  .
        v-base-scale  =  buf_price-doc-forming.base-scale .
    end.
    else do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  v-obj-current-date
  ,output v-base-rate
  ,output v-base-scale
  )  .
    end.
   assign
    buf_price-doc.base-rate      = v-base-rate
    buf_price-doc.base-scale     = v-base-scale
    buf_price-doc.cr-db-num      = p-curr-db-num
    buf_price-doc.doc-date       = v-obj-current-date
    buf_price-doc.fact-num       = 0
    buf_price-doc.host-code      = v-host-code
    buf_price-doc.is-corr        = false
    buf_price-doc.is-del         = false
    buf_price-doc.obj-code       = p-obj-code
    buf_price-doc.obj-type       = p-obj-type
    buf_price-doc.out-code       = ""
    buf_price-doc.pdf-db         = p-pdf-db-num
    buf_price-doc.pdf-id         = p-pdf-id
    buf_price-doc.plt-db-num     = p-plt-db-num
    buf_price-doc.plt-id         = p-plt-id
    buf_price-doc.PS             = "@ "
    buf_price-doc.rest-base      = 0
    buf_price-doc.rest-last      = 0
    buf_price-doc.rest-qnty      = 0
    buf_price-doc.rest-sale      = 0
    buf_price-doc.sale-base      = 0
    buf_price-doc.status_        = 'новый':U
    .
    buf_price-doc.doc-num-es     = entry(1, buf_price-doc-forming.des, chr(4)) no-error.
    buf_price-doc.uid-es         = entry(2, buf_price-doc-forming.des, chr(4)) no-error.
    buf_price-doc.doc-date       = date(entry(3, buf_price-doc-forming.des, chr(4))) no-error.
    if buf_price-doc.uid-es = "_" then buf_price-doc.uid-es = "" .
    assign
        p-price-doc-recid = recid ( buf_price-doc )
    .
end.
end procedure.
procedure prcreate-new-price-list :
do
on error undo, return error return-value
:
define input parameter p-price-doc-recid   as recid                    no-undo.
define input parameter p-gds-code          like ub.goods.gds-code         no-undo.
define input parameter p-price-sale        like ub.price-list.price-sale  no-undo.
define output parameter p-update           as logical                  no-undo.
define variable kk as integer no-undo .
define var v-b-code    like ub.bar-code.b-code     no-undo.
define variable p-hostcode as int no-undo .
define variable local_vat-pc like ub.price-list.vat-pc    no-undo.
define variable local_slt-pc like ub.price-list.slt-pc    no-undo.
define buffer buf_price-doc        for ub.price-doc.
define buffer buf_price-list       for ub.price-list.
define buffer buf_bar-code         for ub.bar-code.
define buffer buf_goods            for ub.goods.
define buffer buf_root_gds-prt     for ub.gds-prt.
define buffer buf_gds-prt          for ub.gds-prt.
find first buf_price-doc no-lock
     where recid( buf_price-doc ) = p-price-doc-recid
.
find first buf_goods no-lock
     where buf_goods.gds-code = p-gds-code
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
if error-status :error
then do:
    message
        "Не найден основной бар-код"
        skip "для товара "
        skip string(buf_goods.artic)
        skip buf_goods.gds-name
    view-as alert-box
    title "Ошибка при выполнении prcreate.i".
    undo, return error .
end.
find first buf_bar-code no-lock
     where buf_bar-code.b-code = v-b-code
no-error.
if error-status :error
then do:
    message
        "Не найдена запись bar-code"
        skip "для товара "
        skip string(buf_goods.artic)
        skip buf_goods.gds-name
        skip "С основным бар-кодом"
        skip string(v-b-code)
    view-as alert-box
    title "Ошибка при выполнении prcreate.i".
    undo, return error .
end.
find first buf_root_gds-prt no-lock
     where buf_root_gds-prt.upper-code = buf_goods.prt-root
.
if buf_root_gds-prt.node-name <> '_Пустая шкала':U
  and buf_bar-code.in-code <> ""
then do:
    message
        "Не допускается создавать спец. цены на партии для товаров с непустой шкалой!" skip (2)
        "Артикул:" buf_goods.artic "Код:" buf_goods.gds-code buf_goods.gds-name
        view-as alert-box error.
    undo, return error.
end.
find first buf_gds-prt no-lock
     where buf_gds-prt.node-code = buf_bar-code.node-code
.
find first buf_price-list
     where buf_price-list.doc-num = buf_price-doc.doc-num
       and buf_price-list.b-code  = v-b-code
no-error.
if available buf_price-list
then do:
    message "Строка с товаром арт." buf_price-list.artic " уже есть в данной переоценке."
       skip "  Цена:   " buf_price-list.price-sale
       skip "Цена будет изменена"
    view-as alert-box warning.
    assign
        p-update = yes
    .
end.
else do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
    kk = kk + 1.
define variable v-main-bar-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-bar-code
  )  .
    create buf_price-list.
    assign
        buf_price-list.line-num    = kk
        buf_price-list.doc-num     = buf_price-doc.doc-num
        buf_price-list.b-code      = buf_bar-code.b-code
        buf_price-list.artic       = buf_goods.artic
        buf_price-list.prod-type   = buf_goods.prod-type
        buf_price-list.prod-code   = buf_goods.prod-code
        buf_price-list.main-price  = (buf_bar-code.b-code = v-main-bar-code )
        buf_price-list.calc-method = 'Отсутствует':U
        buf_price-list.obj-type    = buf_price-doc.obj-type
        buf_price-list.obj-code    = buf_price-doc.obj-code
        buf_price-list.price-sale  = p-price-sale
        buf_price-list.vat-pc      = local_vat-pc
        buf_price-list.slt-pc      = local_slt-pc
        p-update                   = no
    .
end.
end.
end procedure.
procedure create_new_price-doc-forming :
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-plt-db-num as integer   no-undo .
define output parameter p-plt-id     as integer   no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define variable v-host-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as integer   no-undo .
define variable v-base as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  ?
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  yes
  ,output p-plt-id
  ,output p-plt-db-num
  )  .
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = p-plt-id
      ub.price-doc-forming.plt-db-num   = p-plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = v-base-rate
      ub.price-doc-forming.base-scale   = v-base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = if v-base then v-base-rate else 1
      ub.price-doc-forming.exch-scale   = if v-base then v-base-scale else 1
      ub.price-doc-forming.stts         = 0
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = "автосоздание"
   .
   assign
    p-pdf-db-num  = ub.price-doc-forming.pdf-db
    p-pdf-id      = ub.price-doc-forming.pdf-id
    p-plt-db-num  = ub.price-doc-forming.plt-db-num
    p-plt-id      = ub.price-doc-forming.plt-id
   .
  end.
end procedure.
procedure prcreate-new-price-doc-forming-gds :
define input  parameter p-price-doc-forming-recid as recid  no-undo.
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter par-pr-notls as character no-undo .
define input  parameter par-pr-altex as character no-undo .
define input  parameter par-pr-sclex as character no-undo .
define input  parameter p-line-num    as integer   no-undo .
define input  parameter p-gds-code    as integer   no-undo .
define input  parameter p-price-sale  as decimal   no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
define buffer main_bar-code for ub.bar-code  .
define variable main-b-code as integer   no-undo .
define variable v-sec as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal   no-undo .
define variable v-cur-rt as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .
find first buf_price-doc-forming no-lock where
           recid(buf_price-doc-forming) = p-price-doc-forming-recid  no-error .
           if error-status :error then return error .
find first buf_goods no-lock where
           buf_goods.gds-code  = p-gds-code no-error .
           if error-status :error then return error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output main-b-code
  ) no-error .
run check-use-bar-code (main-b-code) no-error .
if error-status :error then return .
run create-line-pdf-mpl-lib (
     input buf_price-doc-forming.plt-db-num
    ,input buf_price-doc-forming.plt-id
    ,input buf_price-doc-forming.pdf-db
    ,input buf_price-doc-forming.pdf-id
    ,input p-line-num
    ,input main-b-code
    ,input buf_goods.artic
    ,input buf_goods.prod-type
    ,input buf_goods.prod-code
    ,input ""
    ,input 0
    ,input p-price-sale
    ,input ""
    ,input 0
   ,input-output v-sec ) no-error .
   if error-status :error  then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "2"
       view-as alert-box error
     .
   end.
define buffer old_price-list for ub.price-list  .
if par-pr-notls = "yes" then do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  main-b-code
  ,input  0
  ,input  0
  ,output v-cur-dn
  ,output v-cur-pr
  ,output v-cur-rt
  ,output v-cur-ex
  )  .
end.
if par-pr-altex = "yes" and
   par-pr-notls = "yes" then do:
    if v-cur-dn <> "" then do:
        for each old_price-list no-lock where
                 old_price-list.doc-num = v-cur-dn and
                 old_price-list.artic      = buf_goods.artic and
                 old_price-list.prod-type  = buf_goods.prod-type and
                 old_price-list.prod-code  = buf_goods.prod-code and
                 old_price-list.main-price = no,
                first buf_bar-code no-lock where
                      buf_bar-code.b-code   = old_price-list.b-code and
                      buf_bar-code.unit-cli <> buf_goods.unit-base
                      :
                       run check-use-bar-code (buf_bar-code.b-code) no-error .
                       if error-status :error then next.
                 run create-line-pdf-mpl-lib (
                       input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input p-line-num
                      ,input old_price-list.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input old_price-list.price-sale
                      ,input ""
                      ,input 0
                     ,input-output v-sec ) no-error .
        end.
    end.
end.
if par-pr-sclex = "yes" and
   par-pr-notls = "yes" then do:
    if v-cur-dn <> "" then do:
        for each old_price-list no-lock where
                 old_price-list.doc-num    = v-cur-dn and
                 old_price-list.artic      = buf_goods.artic and
                 old_price-list.prod-type  = buf_goods.prod-type and
                 old_price-list.prod-code  = buf_goods.prod-code and
                 old_price-list.main-price = no,
                first buf_bar-code no-lock where
                      buf_bar-code.b-code   = old_price-list.b-code and
                      buf_bar-code.in-code  = "" and
                      buf_bar-code.unit-cli = buf_goods.unit-base
                      :
                       run check-use-bar-code (buf_bar-code.b-code) no-error .
                       if error-status :error then next.
                 run create-line-pdf-mpl-lib (
                       input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input p-line-num
                      ,input old_price-list.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input old_price-list.price-sale
                      ,input ""
                      ,input 0
                    ,input-output v-sec ) no-error .
        end.
    end.
end.
end.
end procedure.
procedure copy_new_price-doc-forming :
define input  parameter       p-recid      as recid no-undo .
define input-output parameter p-plt-db-num as integer   no-undo .
define input-output parameter p-plt-id     as integer   no-undo .
define output parameter       p-pdf-db-num as integer   no-undo .
define output parameter       p-pdf-id     as integer   no-undo .
define buffer buf_price-list-type        for ub.price-list-type  .
define buffer buf_price-doc-forming      for ub.price-doc-forming .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr .
define buffer buf_price-doc-forming-gds  for ub.price-doc-forming-gds .
define buffer buf_pd-forming-gds-attr    for ub.price-doc-forming-gdsattr .
define variable v-host-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as integer   no-undo .
define variable v-base as logical   no-undo .
define variable v-name as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
find first buf_price-list-type no-lock where
           buf_price-list-type.plt-db-num = p-plt-db-num and
           buf_price-list-type.plt-id     = p-plt-id no-error .
if error-status :error then return error "Не найден ТПЛ".
if buf_price-list-type.stts <> 0 then return error "ТПЛ удален" .
find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming )  = p-recid no-error .
    if available buf_price-doc-forming then do :
        assign
          v-base-rate  = buf_price-doc-forming.base-rate
          v-base-scale = buf_price-doc-forming.base-scale
          v-name       =  substitute("Скопировано с ДНЦ &1 &2",  buf_price-doc-forming.pdf-id , trim(buf_price-doc-forming.name)  )
        .
    end.
    else do:
        assign
          v-base-rate  = 1
          v-base-scale = 1
          v-name       = "Автосоздание"
        .
    end.
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = p-plt-id
      ub.price-doc-forming.plt-db-num   = p-plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = v-base-rate
      ub.price-doc-forming.base-scale   = v-base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = if v-base then v-base-rate else 1
      ub.price-doc-forming.exch-scale   = if v-base then v-base-scale else 1
      ub.price-doc-forming.stts         = 0
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = v-name
   .
   assign
    p-pdf-db-num  = ub.price-doc-forming.pdf-db
    p-pdf-id      = ub.price-doc-forming.pdf-id
    p-plt-db-num  = ub.price-doc-forming.plt-db-num
    p-plt-id      = ub.price-doc-forming.plt-id
   .
  end.
  if not available buf_price-doc-forming then return .
for each buf_price-doc-forming-attr no-lock where
         buf_price-doc-forming-attr.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_price-doc-forming-attr.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_price-doc-forming-attr.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_price-doc-forming-attr.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-attr.
    buffer-copy buf_price-doc-forming-attr to ub.price-doc-forming-attr
    assign
      ub.price-doc-forming-attr.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-attr.plt-id      = p-plt-id
      ub.price-doc-forming-attr.pdf-db     = p-pdf-db-num
      ub.price-doc-forming-attr.pdf-id      = p-pdf-id
      .
end.
for each buf_price-doc-forming-gds no-lock where
         buf_price-doc-forming-gds.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_price-doc-forming-gds.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_price-doc-forming-gds.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_price-doc-forming-gds.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-gds.
    buffer-copy buf_price-doc-forming-gds to ub.price-doc-forming-gds
    assign
      ub.price-doc-forming-gds.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-gds.plt-id      = p-plt-id
      ub.price-doc-forming-gds.pdf-db      = p-pdf-db-num
      ub.price-doc-forming-gds.pdf-id      = p-pdf-id
    .
end.
for each buf_pd-forming-gds-attr no-lock where
         buf_pd-forming-gds-attr.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_pd-forming-gds-attr.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_pd-forming-gds-attr.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_pd-forming-gds-attr.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-gdsattr.
    buffer-copy buf_pd-forming-gds-attr to ub.price-doc-forming-gdsattr
    assign
      ub.price-doc-forming-gdsattr.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-gdsattr.plt-id      = p-plt-id
      ub.price-doc-forming-gdsattr.pdf-db      = p-pdf-db-num
      ub.price-doc-forming-gdsattr.pdf-id      = p-pdf-id
    .
end.
end procedure.
define variable par-pr-incpc as character no-undo.
define variable par-pr-rndmt as character no-undo.
define variable par-pr-rndbs as character no-undo.
define variable par-pr-clt-q as character no-undo.
define variable par-pr-dpl-q as character no-undo.
define variable par-pr-rdc-q as character no-undo.
define variable par-pr-abs-d as character no-undo.
define variable par-pr-altex as character no-undo.
define variable par-pr-parex as character no-undo.
define variable par-pr-sclex as character no-undo.
define variable par-pr-notls as character no-undo.
define variable par-pr-equ-dq as integer  no-undo.
define variable par-pr-discm as character no-undo .
define variable par-pr-dscnt as character no-undo .
define variable par-pr-print as character no-undo .
define variable par-pr-sigma as character no-undo .
define variable par-pr-goods as character no-undo.
define variable par-pr-nogds as character no-undo.
define variable par-alcohol  as character no-undo.
define variable par-gen-mrgn-ie as character no-undo .
define variable par-gen-mrgn-iv as character no-undo .
define variable par-gen-mrgn-im as character no-undo .
define variable par-pr-nakl-ie  as logical   no-undo .
define variable par-pr-nakl-iv  as logical   no-undo .
define variable par-pr-nakl-im  as logical   no-undo .
define variable par-pr-nogds-long as longchar no-undo .
define temp-table tmp-proof-price no-undo
  field node-code like ub.gds-grp.node-code
  field proof as decimal
  field price as decimal
index pi node-code proof descending .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure ggoattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info27 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
procedure  chec-par :
define output parameter l-par as logical no-undo .
define input parameter l-host like ub.clients.obj-code no-undo .
define input parameter l-type like ub.clients.obj-type no-undo .
define input parameter l-code like ub.clients.obj-code no-undo .
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'alcohol'
  ,input  l-host
  ,input  l-type
  ,input  l-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-alcohol
  ,output par-type
  ) no-error .
 .
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input l-type
  ,input l-code
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
    if thbjattr_thbj-attr.prop-code = 'pr-clt-q':U then par-pr-clt-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-dpl-q':U then par-pr-dpl-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-rdc-q':U then par-pr-rdc-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-equ-dq':U then par-pr-equ-dq = thbjattr_thbj-attr.property-value-integer .
    if thbjattr_thbj-attr.prop-code = 'pr-abs-d':U then par-pr-abs-d = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-altex':U then par-pr-altex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-parex':U then par-pr-parex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-sclex':U then par-pr-sclex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-discm':U then par-pr-discm =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'pr-dscnt':U then par-pr-dscnt  = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-print':U then par-pr-print  = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-sigma':U then par-pr-sigma  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-incpc':U then par-pr-incpc  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-rndmt':U then par-pr-rndmt  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'pr-rndbs':U then par-pr-rndbs  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-notls':U then par-pr-notls = string ( thbjattr_thbj-attr.property-value-logical) .
    if v-cntxt-db-num = 0 then do:
      if thbjattr_thbj-attr.prop-code = 'pr-nogds0':U then par-pr-nogds =  thbjattr_thbj-attr.property-value-character.
      if thbjattr_thbj-attr.prop-code = 'pr-goods0':U then par-pr-goods =  thbjattr_thbj-attr.property-value-character.
    end.
    else do:
      if thbjattr_thbj-attr.prop-code = 'pr-nogds':U then par-pr-nogds =  thbjattr_thbj-attr.property-value-character.
      if thbjattr_thbj-attr.prop-code = 'pr-goods':U then par-pr-goods =  thbjattr_thbj-attr.property-value-character.
    end.
end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplmrgn in g#library2
  (input  ?
  ,input  l-type
  ,input  l-code
  ,output par-gen-mrgn-ie
  ,output par-gen-mrgn-iv
  ,output par-gen-mrgn-im
  ) no-error .
   IF error-status :error THEN message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "gbl/gtplmrgn.i"
     view-as alert-box error
   .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplpnakl in g#library2
  (input  ?
  ,input  l-type
  ,input  l-code
  ,output par-pr-nakl-ie
  ,output par-pr-nakl-iv
  ,output par-pr-nakl-im
  ) no-error .
   define variable ii as integer   no-undo .
   define variable nn as integer   no-undo .
   define variable v-fullname as character no-undo .
   nn = num-entries ( par-pr-nogds ).
   par-pr-nogds-long = "".
   if par-pr-nogds <> "0" and par-pr-nogds <> ""  then do:
      repeat ii = 1 to nn :
        run grplib-get-full-name  ( input integer(entry(ii,par-pr-nogds)) , output v-fullname ) .
        par-pr-nogds-long = par-pr-nogds-long + v-fullname + chr(4) .
      end.
      par-pr-nogds-long = trim (par-pr-nogds-long,chr(4)) .
   end.
l-par = true .
end procedure.
PROCEDURE cre-pr-list:
define input  parameter bc      like ub.price-list.b-code no-undo.
define input  parameter new-num like ub.price-doc.doc-num no-undo.
define output parameter new-rec as recid             no-undo.
define buffer buf-price-list for ub.price-list.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer buf-gds-prt    for ub.gds-prt.
define buffer root-gds-prt   for ub.gds-prt.
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable local_vat-pc like ub.price-list.vat-pc    no-undo.
define variable local_slt-pc like ub.price-list.slt-pc    no-undo.
define variable cur-rt-base as decimal no-undo .
define variable cur-rt-rubl as decimal no-undo .
define variable p-hostcode as int no-undo .
define variable v-line-num as integer no-undo .
define variable v-skip-del-gds as logical no-undo initial no .
cre-pr:
do on error undo cre-pr, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  run check-use-bar-code ( buf-bar-code.b-code ) no-error .
  if error-status :error then do:
    message
      return-value skip
      "Ошибка !"
      view-as alert-box error
    .
    undo cre-pr, return.
  end.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find first root-gds-prt no-lock where
            root-gds-prt.upper-code = buf-goods.prt-root.
  if root-gds-prt.node-name <> '_Пустая шкала':U and
    buf-bar-code.in-code <> "" then do:
    message
      "Не допускается создавать спец. цены на партии для товаров с непустой шкалой!" skip (2)
      "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
      view-as alert-box error.
    undo cre-pr, return.
  end.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  if buf-goods.stts <> 0 and not v-skip-del-gds then do:
    message
      "Не допускается создавать цены на удаленные товары!" skip (2)
      "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
      view-as alert-box error.
    undo cre-pr, return.
  end.
  find  buf-price-doc where
        buf-price-doc.doc-num = new-num.
define variable v-ret as logical no-undo .
   run ver-modificator-price-is-null (
          input    buf-goods.artic        ,
          input    buf-goods.prod-type    ,
          input    buf-goods.prod-code    ,
          input    buf-price-doc.obj-type   ,
          input    buf-price-doc.obj-code   ,
          output   v-ret ).
      if v-ret = false then dO:
          message
            "Не допускается создавать цены на модификаторы с нулевой ценой !" skip (2)
            "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
            view-as alert-box error.
          undo cre-pr, return.
        end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,input  bc
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  ) no-error .
  find first buf-price-list where
            buf-price-list.b-code  = buf-bar-code.b-code and
            buf-price-list.doc-num = new-num  and
            buf-price-list.price-type = ""    no-error .
  if not available buf-price-list then do:
    run calc-price-line-num (input  new-num , output v-line-num) .
    create buf-price-list.
    assign
      buf-price-list.line-num  = v-line-num
      buf-price-list.b-code    = buf-bar-code.b-code
      buf-price-list.doc-num   = buf-price-doc.doc-num
      buf-price-list.prod-type = buf-goods.prod-type
      buf-price-list.prod-code = buf-goods.prod-code
      buf-price-list.artic     = buf-goods.artic
      buf-price-list.obj-type  = buf-price-doc.obj-type
      buf-price-list.obj-code  = buf-price-doc.obj-code
      buf-price-list.vat-pc    = local_vat-pc
      buf-price-list.slt-pc    = local_slt-pc
      buf-price-list.price-prev = cur-pr
      .
    if  buf-gds-prt.upper-code = buf-goods.prt-root and
        buf-bar-code.in-code   = "" and
        buf-bar-code.part-code = "" and
        buf-bar-code.unit-cli  = buf-goods.unit-base then do:
      buf-price-list.main-price = yes.
      if cur-pr <> ? then do:
        run exp-prt (input buf-goods.gds-code,
                    input cur-dn,
                    input new-num,
                    output new-rec) no-error.
        if error-status :error then do:
          message
            "Ошибка вызова процедуры разворота специальных и неосновных цен."
            view-as alert-box error.
          undo cre-pr, return error.
        end.
      end.
    end.
    else do:
      if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
        buf-price-list.d-pcnt = ?.
      end.
      buf-price-list.main-price = no.
    end.
  end.
end.
new-rec = recid (buf-price-list).
END PROCEDURE.
procedure calc-price-line-num :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-num as character no-undo .
define output parameter p-num  as integer no-undo .
define variable v-fact as integer no-undo .
define buffer buf_1_price-list for ub.price-list .
p-num = 1 .
find last  buf_1_price-list no-lock where
           buf_1_price-list.doc-num = p-doc-num use-index line-num no-error .
           if available buf_1_price-list then
                assign
                  v-fact = buf_1_price-list.line-num
                .
v-fact = v-fact + 1.
if v-fact <> ? then if p-num < v-fact then p-num = v-fact .
 end.
end procedure.
PROCEDURE del-pr-list:
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter round-method as character         no-undo.
define input parameter round-base   as decimal      no-undo.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define variable l-ov-on as logical no-undo .
del-pr:
do on error undo del-pr, return error:
  find first  buf-price-list no-lock where
              buf-price-list.doc-num    = d-num and
              buf-price-list.b-code     = bc and
              buf-price-list.price-type = "" no-error.
  if not available buf-price-list then
    undo del-pr, return error.
  find  buf-goods no-lock where
        buf-goods.prod-type = buf-price-list.prod-type and
        buf-goods.prod-code = buf-price-list.prod-code and
        buf-goods.artic     = buf-price-list.artic.
  if buf-price-list.main-price then do:
    for each  buf-price-list exclusive-lock where
              buf-price-list.doc-num   = d-num and
              buf-price-list.artic     = buf-goods.artic and
              buf-price-list.prod-type = buf-goods.prod-type and
              buf-price-list.prod-code = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code = buf-price-list.b-code
    on error undo del-pr, return error:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.buf-price-list.obj-type
  ,input  ub.buf-price-list.obj-code
  ,input  ub.buf-price-list.artic
  ,input  ub.buf-price-list.prod-type
  ,input  ub.buf-price-list.prod-code
  ,input  'ov-on=request:exclusive'
  ,output l-ov-on
  ) no-error .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка получения признака товара на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      if l-ov-on then do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.buf-price-list.obj-type
  ,input  ub.buf-price-list.obj-code
  ,input  ub.buf-price-list.artic
  ,input  ub.buf-price-list.prod-type
  ,input  ub.buf-price-list.prod-code
  ,input  'ov-on=false'
  ,output l-ov-on
  ) no-error .
        if error-status :error then do:
        end.
       end.
      delete buf-price-list.
    end.
  end.
  else do:
    find  buf-bar-code no-lock where
          buf-bar-code.b-code = buf-price-list.b-code.
    if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
      message
        "Нельзя удалить неосновную цену." skip
        "Неосновная цена (скидка) не может быть неопределенной." skip
        "Код:" bc skip
        "Переоценка:" d-num
        view-as alert-box error.
      undo del-pr, return error.
    end.
    find current buf-price-list exclusive-lock no-error .
    delete buf-price-list.
    run calc-base-upd (input buf-bar-code.b-code,
                      input d-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      undo del-pr, return error.
  end.
end.
END PROCEDURE.
PROCEDURE calc-base-upd:
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter round-method as character         no-undo.
define input parameter round-base   as decimal      no-undo.
define buffer alt-bar-code   for ub.bar-code.
define buffer alt-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
calc-base:
do on error undo calc-base, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  for each  alt-bar-code no-lock where
            alt-bar-code.gds-code  = buf-bar-code.gds-code and
            alt-bar-code.node-code = buf-bar-code.node-code and
            alt-bar-code.part-code = buf-bar-code.part-code and
            alt-bar-code.in-code   = buf-bar-code.in-code and
            alt-bar-code.unit-cli <> buf-goods.unit-base,
      each  alt-price-list where
            alt-price-list.doc-num    = d-num and
            alt-price-list.b-code     = alt-bar-code.b-code and
            alt-price-list.price-type = ""
      on error undo calc-base, return error:
    run calc-pr-alt (input d-num,
                    input alt-bar-code.b-code,
                    input round-method,
                    input round-base) no-error.
    if error-status:error then
      undo calc-base, return error.
  end.
end.
END PROCEDURE.
PROCEDURE calc-pr-alt:
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter r-method as character             no-undo.
define input parameter r-base   as decimal              no-undo.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer old-price-list for ub.price-list.
define variable pr-rec   as   recid                  no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
pr-alt:
do on error undo pr-alt, return error:
  if r-method = ? or
     r-base = ? then do:
    message
      "Нельзя удалить основную цену." skip
      "Не задан способ округления для расчета зависящих от нее неосновных цен." skip
      "Код:" bc skip
      "Переоценка:" d-num
      view-as alert-box error.
    undo pr-alt, return error.
  end.
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-list where
        buf-price-list.doc-num = buf-price-doc.doc-num and
        buf-price-list.b-code  = bc.
  if buf-price-list.d-pcnt = ? then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,input  bc
  ,input  0
  ,input  0
  ,output pr-rec
  ,output pr-c-b-r
  )  .
    find old-price-list no-lock where
        recid (old-price-list) = pr-rec no-error.
    if available old-price-list and
      old-price-list.b-code = bc then
      buf-price-list.d-pcnt = old-price-list.d-pcnt.
    else
      buf-price-list.d-pcnt = 0.
  end.
   if buf-price-list.d-pcnt = ? then do:
      assign
        buf-price-list.price-sale =   if available old-price-list then old-price-list.price-sale else 0
        buf-price-list.calc-method =  'Не-считать':U + 'Основная':U
        .
  end.
  else do:
      assign
        buf-price-list.price-sale =   fnc-base-price (buf-bar-code.b-code, buf-price-list.doc-num) *
                                      buf-bar-code.cli-base-rate *
                                      (1 - buf-price-list.d-pcnt / 100)
        buf-price-list.calc-method =  'Основная':U
        .
case r-method :
  when '9-окончание':U then do:
    if buf-price-list.price-sale < 29 then do:
      if (buf-price-list.price-sale - truncate (buf-price-list.price-sale, 0)) <> 0 then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 1
        .
      end.
    end.
    else do:
      if (buf-price-list.price-sale modulo 10) < 3 then do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if buf-price-list.price-sale < r-base then do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 0.99
      .
    end.
    else do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
    .
  end.
  when 'Произвольно':U then do:
    if r-base <> 0 then do:
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale / r-base, 0) * r-base
      .
      if buf-price-list.price-sale = 0 then do:
        assign
          buf-price-list.price-sale = r-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if r-base <> 0 then do:
      if truncate ( buf-price-list.price-sale / r-base, 0 ) <> (buf-price-list.price-sale / r-base) then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale / r-base, 0) * r-base + r-base
        .
      end.
    end.
    if buf-price-list.price-sale = 0 then do:
      assign
        buf-price-list.price-sale = r-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if r-base <> 0 then do:
      assign
        buf-price-list.price-sale = buf-price-list.price-sale * r-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" r-method skip
      "round-base"   r-base   skip
      "price"        buf-price-list.price-sale             skip
      view-as alert-box error .
  end.
end.
  end.
end.
END PROCEDURE.
PROCEDURE calc-pr-discnt:
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter bc    like ub.bar-code.b-code   no-undo.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer old-price-list for ub.price-list.
define variable pr-rec   as   recid                  no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
pr-discnt:
do on error undo pr-discnt, return error:
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-list where
        buf-price-list.doc-num = buf-price-doc.doc-num and
        buf-price-list.b-code  = bc.
  buf-price-list.d-pcnt = (1 -
                           buf-price-list.price-sale /
                           fnc-base-price (buf-bar-code.b-code, buf-price-list.doc-num) /
                           buf-bar-code.cli-base-rate) *
                           100
                           .
end.
END PROCEDURE.
PROCEDURE calc-pr-sub :
define  input  parameter bc             like ub.price-list.b-code no-undo.
define  input  parameter d-num          like ub.price-doc.doc-num no-undo.
define  input  parameter calc-method  as character    no-undo.
define  input  parameter increase-pc  as decimal      no-undo.
define  input  parameter round-method as character    no-undo.
define  input  parameter round-base   as decimal      no-undo.
define  output parameter calc-rec     as recid        no-undo.
define  buffer buf-price-list for ub.price-list.
define  buffer buf-bar-code   for ub.bar-code.
define  buffer buf-goods      for ub.goods.
define  buffer buf-gds-prt    for ub.gds-prt.
define  buffer buf-gds-grp    for ub.gds-grp.
define  buffer buf-price-doc  for ub.price-doc.
calc-sub:
do on error undo calc-sub, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-list where
        buf-price-list.doc-num    = d-num and
        buf-price-list.b-code     = bc and
        buf-price-list.price-type = "".
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  calc-rec = recid (buf-price-list).
  if buf-price-list.main-price then do:
    for each  buf-price-list where
              buf-price-list.doc-num    = buf-price-doc.doc-num and
              buf-price-list.main-price = no and
              buf-price-list.artic      = buf-goods.artic and
              buf-price-list.prod-type  = buf-goods.prod-type and
              buf-price-list.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code   = buf-price-list.b-code and
              buf-bar-code.unit-cli = buf-goods.unit-base
        on error undo calc-sub, return error:
      run calc-pr-list (input  buf-bar-code.b-code,
                        input  buf-price-list.doc-num,
                        input  calc-method,
                        input  increase-pc,
                        input  round-method,
                        input  round-base,
                        input ? ,
                        input ? ,
                        input ? ,
                        input ? ,
                        output calc-rec) no-error.
      if error-status :error then
        undo calc-sub, return error.
      calc-rec = recid (buf-price-list).
    end.
    for each  buf-price-list where
              buf-price-list.doc-num    = buf-price-doc.doc-num and
              buf-price-list.main-price = no and
              buf-price-list.artic      = buf-goods.artic and
              buf-price-list.prod-type  = buf-goods.prod-type and
              buf-price-list.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code    = buf-price-list.b-code and
              buf-bar-code.unit-cli <> buf-goods.unit-base
        on error undo calc-sub, return error:
      run calc-pr-alt (input buf-price-doc.doc-num,
                      input buf-bar-code.b-code,
                      input round-method,
                      input round-base) no-error.
      if error-status :error then
        undo calc-sub, return error.
    end.
  end.
  else do:
    run calc-base-upd (input buf-bar-code.b-code,
                      input buf-price-doc.doc-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      undo calc-sub, return error.
  end.
end.
END PROCEDURE.
procedure ver-pr-nogds :
define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-par-pr-nogds  as character no-undo .
define output parameter p-not           as logical   no-undo .
define output parameter p-str           as character no-undo .
define buffer buf_goods for ub.goods  .
define variable nn as integer   no-undo .
define variable ii as integer   no-undo .
define variable v-namegrp as character no-undo .
  do
  on error undo, return error return-value
  :
  if p-par-pr-nogds = "1" then do:
     assign
      p-not = true
      p-str = ""
     .
     return .
  end.
  assign
    p-not = false
    p-str = ""
  .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  nn = num-entries(par-pr-nogds-long,chr(4)) .
  repeat ii = 1 to nn:
     v-namegrp = entry(ii , par-pr-nogds-long , chr(4) ) no-error .
     if buf_goods.grp-name  begins v-namegrp  then do:
        assign
          p-not = true
          p-str = substitute ( "Товар &1 &2 &3  может быть включен в ДНЦ из-за исключения запрета по группе : &4"  , buf_goods.artic, buf_goods.gds-name , buf_goods.grp-name , v-namegrp )
        .
        leave .
     end.
  end.
  end.
end procedure.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-level-dis-attr no-undo
      field attr-code   like global-state-attr.attr-code
      field attr-value  like global-state-attr.attr-value
      index pi   attr-value descending
      index pi1 is unique attr-value
            attr-code .
procedure lvldsc-byattr :
define input  parameter p-attr-code  as character no-undo .
define input  parameter p-attr-value as character no-undo .
define output parameter p-val1       as decimal   no-undo .
define output parameter p-val2       as decimal   no-undo .
define output parameter p-prc        as decimal   no-undo .
  do
  on error undo, return error return-value
  :
  define variable v-str1 as character no-undo .
  v-str1 = trim ( p-attr-code , 'level-discnt':U ) .
  v-str1 = trim ( v-str1 , chr(4) ) .
 run lvldsc-bytt (
      input   v-str1
    , input   p-attr-value
    , output  p-val1
    , output  p-val2
    , output  p-prc )
      no-error .
  end.
end procedure.
procedure lvldsc-bytt :
define input  parameter p-attr-code as character no-undo .
define input  parameter p-attr-value as character no-undo .
define output parameter p-val1 as decimal   no-undo .
define output parameter p-val2 as decimal   no-undo .
define output parameter p-prc  as decimal   no-undo .
define variable v-str1 as character no-undo .
  do
  on error undo, return error return-value
  :
  assign
     v-str1 = trim ( p-attr-code , "[]()" )
     p-val1 = decimal(entry(1,v-str1, ";"))
     p-val2 = decimal(entry(2,v-str1, ";"))
     p-prc  = decimal(p-attr-value)
     no-error
  .
  end.
end procedure.
procedure level-dis-value :
define input  parameter p-price-prod as decimal   no-undo .
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-prc as decimal   no-undo .
define variable v-level-dis-attr as character no-undo .
define variable v-type as character no-undo .
define variable v-val1 as decimal   no-undo .
define variable v-val2 as decimal   no-undo .
define variable v-prc  as decimal   no-undo .
define variable ix     as integer   no-undo .
do
 on error undo, return error return-value
 :
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
run ggoattr-value (
   input   buf_goods.grp-code
  ,input   v-cntxt-host-code-obj
  ,input   p-obj-type
  ,input   p-obj-code
  ,input   'level-dis':U
  ,output  v-level-dis-attr
  ,output  v-type ) no-error .
repeat ix = 1 to num-entries (v-level-dis-attr, chr(4)) - 1 :
  create
    tt-level-dis-attr
  .
  tt-level-dis-attr.attr-code = entry (1, entry (ix, v-level-dis-attr, chr(4)), chr(44)) .
  tt-level-dis-attr.attr-value = entry (2, entry (ix, v-level-dis-attr, chr(4)), chr(44)) .
end.
p-prc = 0 .
  if p-price-prod = 0 then do:
      for each tt-level-dis-attr no-lock
              :
            run lvldsc-bytt (
              input   tt-level-dis-attr.attr-code
            , input   tt-level-dis-attr.attr-value
            , output  v-val1
            , output  v-val2
            , output  v-prc  )
            .
            if v-val1  = 0  then do:
               p-prc = v-prc .
              leave.
            end.
      end.
  end.
  else do:
      for each tt-level-dis-attr no-lock
              :
            run lvldsc-bytt (
              input   tt-level-dis-attr.attr-code
            , input   tt-level-dis-attr.attr-value
            , output  v-val1
            , output  v-val2
            , output  v-prc  )
            .
            if p-price-prod   > v-val1 and
               p-price-prod  <= v-val2 then do:
               p-prc = v-prc .
              leave.
            end.
      end.
  end.
for each tt-level-dis-attr no-lock. delete tt-level-dis-attr. end.
 end.
end procedure.
procedure calc-price-levelprod :
define input  parameter p-mode     as integer   no-undo .
define input  parameter p-rb       as character no-undo .
define input  parameter p-b-code   as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-price-sale as decimal   no-undo .
define output parameter p-descript-calc as character no-undo .
define variable  v-PriceWithoutVat as decimal   no-undo init 0.
define variable  v-PriceWithVat    as decimal   no-undo init 0.
define variable  v-prod-vat        as decimal   no-undo init 0.
define variable  v-discnt          as decimal   no-undo init 0.
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_parts for ub.parts  .
define variable v-part-code as character no-undo .
define variable v-in-code   as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  p-b-code
 , input  p-obj-type
 , input  p-obj-code
 , output v-PriceWithoutVat
 , output v-PriceWithVat
 , output v-prod-vat
 , output v-part-code
 , output v-in-code
        ) no-error .
      if error-status :error then do:
        return error "Нет цены производителя!".
      end.
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
find first buf_parts no-lock where
           buf_parts.artic      = buf_goods.artic        and
           buf_parts.prod-type  = buf_goods.prod-type    and
           buf_parts.prod-code  = buf_goods.prod-code    and
           buf_parts.in-code    = buf_bar-code.in-code   and
           buf_parts.out-code   = buf_bar-code.in-code   and
           buf_parts.part-code  = buf_bar-code.part-code
           no-error .
            if error-status :error then do:
                find first buf_parts no-lock where
                          buf_parts.artic      = buf_goods.artic        and
                          buf_parts.prod-type  = buf_goods.prod-type    and
                          buf_parts.prod-code  = buf_goods.prod-code    and
                          buf_parts.in-code    = v-in-code              and
                          buf_parts.out-code   = v-in-code              and
                          buf_parts.part-code  = v-part-code
                          no-error .
                if error-status :error then do:
                   message
                    substitute("Нет цены производителя !  &1 &2&3&4&5"  ,
                                v-in-code,
                                v-part-code ,
                                buf_goods.artic   ,
                                buf_goods.prod-type,
                                buf_goods.prod-code ) .
                   return error "Нет цены производителя !!!".
                end.
            end.
run level-dis-value ( input (if p-mode = 2 then v-PriceWithoutVat else v-PriceWithVat) , input p-b-code, input p-obj-type, input p-obj-code, output v-discnt ) no-error .
define variable v-postWithoutVat-rubl as decimal   no-undo .
define variable v-postWithoutVat-base as decimal   no-undo .
   case p-mode :
    when 1 then do:
       if p-rb = "rubl" then do:
          p-price-sale = buf_parts.price-rubl + ( MINIMUM ( buf_parts.price-rubl , v-PriceWithVat ) * v-discnt / 100 ).
       end.
       else do:
          p-price-sale = buf_parts.price-base + ( MINIMUM ( v-PriceWithVat , buf_parts.price-base ) * v-discnt / 100 ).
       end.
    end.
    when 2 then do:
      if p-rb = "rubl" then do:
        v-postWithoutVat-rubl =  buf_parts.price-rubl - (buf_parts.price-rubl * buf_parts.vat-pc / (100 + buf_parts.vat-pc) ).
        p-price-sale = v-postWithoutVat-rubl + ( MINIMUM ( v-PriceWithoutVat , v-postWithoutVat-rubl ) * v-discnt / 100 ) .
      end.
      else do:
        v-postWithoutVat-base = buf_parts.price-base - (buf_parts.price-base * buf_parts.vat-pc / ( 100 + buf_parts.vat-pc) ) .
        p-price-sale = v-postWithoutVat-base + ( MINIMUM ( v-PriceWithoutVat, v-postWithoutVat-base) * v-discnt / 100 ) .
      end.
    end.
   end case.
p-descript-calc =
  string(p-mode) + '_Элементы расчета: ' +  chr(10)  +
  buf_goods.gds-name                  +  chr(10) +
  buf_goods.artic +
  buf_goods.prod-type +
  string(buf_goods.prod-code)         + chr(10) +
  "бар-код " +  string(p-b-code)      + chr(10)  +
  'ПН    ' + v-in-code  +
  ' серия ' + v-part-code             +  chr(10)  + chr(10) +
  'Цена поставщика без ндс    '  + string((buf_parts.price-rubl - (buf_parts.price-rubl * buf_parts.vat-pc / (100 + buf_parts.vat-pc) ) ))  + chr(10) +
  'Цена поставщика   c ндс    '  + string ( buf_parts.price-rubl )  + chr(10) +
  'Цена производителя без ндс ' +  string( v-PriceWithoutVat)       + chr(10) +
  'Цена производителя   c ндс ' +  string( v-PriceWithVat  )        + chr(10) +
  chr(10) +
  "% пороговой наценки        "  + string(v-discnt)                 + chr(10) +
  chr(10) +
  "сумма наценки от произв без ндс "  + string( v-PriceWithoutVat * v-discnt / 100 ) +  chr(10) +
  "сумма наценки от произв   с ндс "  + string( v-PriceWithVat * v-discnt / 100 )    +  chr(10)  +
  chr(10) +
  string(p-price-sale)                                                               +  chr(10) +
  (if p-mode = 1 then substitute("ПорогПр+НДС  &1 + ( min(&2или &1) * &3 / 100 )  = &4 " , buf_parts.price-rubl , v-PriceWithVat , v-discnt , p-price-sale)
  else                substitute("ПорогПр-НДС  &1 - ( &1 * &2 / 100 ) + ( min(&3 или &6 ) * &4 / 100 ) = &5 и еще накручивается НДС " , buf_parts.price-rubl , buf_parts.vat-pc , v-PriceWithoutVat , v-discnt , p-price-sale , v-postWithoutVat-rubl))
.
  end.
end procedure.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE write-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
               ub.contract-specif-attr.contract-num = p-contract-num  and
               ub.contract-specif-attr.host-code    = p-host-code     and
               ub.contract-specif-attr.gds-code     = p-gds-code      and
               ub.contract-specif-attr.attr-code    = 'bonus':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'bonus':U
         .
      end.
      ub.contract-specif-attr.attr-value  = string (v-bonus) .
end.
END PROCEDURE.
PROCEDURE read-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'bonus':U
           no-error .
   if available ub.contract-specif-attr then  v-bonus = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-bonus = 0 .
end.
END PROCEDURE.
PROCEDURE write-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-prc-min        as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              ub.contract-specif-attr.attr-value  = string (v-prc-min)
         .
      end.
      else do:
         ub.contract-specif-attr.attr-value  = string (v-prc-min) .
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-prc-min as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'prc-min':U
           no-error .
   if available ub.contract-specif-attr then  v-prc-min = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-prc-min = 0 .
end.
END PROCEDURE.
PROCEDURE write-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = "retro-bonus"
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = "retro-bonus"
         .
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
      else do:
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = "retro-bonus"
           no-error .
   if available ub.contract-specif-attr then  v-retro-bonus = ub.contract-specif-attr.attr-value  .
                                        else  v-retro-bonus = "" .
end.
END PROCEDURE.
define variable v-str1 as character no-undo .
FUNCTION fnc-base-price-doc RETURN decimal
  ( local-bc as integer, p-recid as recid ).
define buffer   base-price       for ub.price-doc-forming-gds .
define variable local-main-code like ub.bar-code.b-code no-undo.
define variable local-base-code like ub.bar-code.b-code no-undo.
define buffer   buf_main-pdf     for ub.price-doc-forming .
find first buf_main-pdf no-lock where recid (buf_main-pdf) = p-recid .
  run prc-base-code in this-procedure (input local-bc, output local-base-code).
  find base-price no-lock where
       base-price.pdf-id = buf_main-pdf.pdf-id and
       base-price.pdf-db = buf_main-pdf.pdf-db and
       base-price.plt-id = buf_main-pdf.plt-id and
       base-price.plt-db-num = buf_main-pdf.plt-db-num and
       base-price.b-code  = local-base-code
       no-error.
  if not available base-price then do:
    run prc-main-code in this-procedure
       ( input local-bc, output local-main-code ).
    find  base-price no-lock where
          base-price.pdf-id = buf_main-pdf.pdf-id and
          base-price.pdf-db = buf_main-pdf.pdf-db and
          base-price.plt-id = buf_main-pdf.plt-id and
          base-price.plt-db-num = buf_main-pdf.plt-db-num and
          base-price.b-code  = local-main-code
          no-error.
  end.
  if available base-price then
    return (base-price.price-sale-doc).
  else
    return (?).
END FUNCTION.
procedure set-price-line :
  do
  on error undo, return error return-value
  :
define input  parameter p-plt-id as integer   no-undo .
define input  parameter p-plt-db as integer   no-undo .
define input  parameter  p-calc-method      as character no-undo .
define input  parameter  p-increase-pc      as decimal   no-undo .
define input  parameter  p-round-method     as character no-undo .
define input  parameter  p-round-base       as decimal   no-undo .
define input  parameter  p-b-code           as integer   no-undo .
define input  parameter  p-gds-code         as integer   no-undo .
define input  parameter  p-artic            as character no-undo .
define input  parameter  p-prod-type        as character no-undo .
define input  parameter  p-prod-code        as integer   no-undo .
define input  parameter  p-base-rate        as decimal   no-undo .
define input  parameter  p-base-scale       as decimal   no-undo .
define input  parameter  p-exch-scale       as decimal   no-undo .
define input  parameter  p-exch-rate        as decimal   no-undo .
define input  parameter  v-doc-code         as character no-undo .
define input  parameter  common-price       as decimal   no-undo .
define input  parameter  v-copy-type        as character no-undo .
define input  parameter  v-copy-code        as integer   no-undo .
define output parameter  p-new-calc-method  as character no-undo .
define output parameter  p-price-calc-base  as decimal   no-undo .
define output parameter  p-price-calc-doc   as decimal   no-undo .
define output parameter  p-price-calc-rubl  as decimal   no-undo .
define output parameter  p-price-prev-base  as decimal   no-undo .
define output parameter  p-price-prev-doc   as decimal   no-undo .
define output parameter  p-price-prev-rubl  as decimal   no-undo .
define output parameter  p-price-sale-base  as decimal   no-undo .
define output parameter  p-price-sale-doc   as decimal   no-undo .
define output parameter  p-price-sale-rubl  as decimal   no-undo .
define output parameter  p-road-tax-base    as decimal   no-undo .
define output parameter  p-road-tax-doc     as decimal   no-undo .
define output parameter  p-road-tax-rubl    as decimal   no-undo .
define output parameter  p-excise-base      as decimal   no-undo .
define output parameter  p-excise-doc       as decimal   no-undo .
define output parameter  p-excise-rubl      as decimal   no-undo .
define output parameter  p-vat-pc           as decimal   no-undo .
define output parameter  p-slt-pc           as decimal   no-undo .
define output parameter  p-prev-doc-code    as character no-undo .
define output parameter  p-d-pcnt           as decimal   no-undo .
define variable cost-base    as decimal   no-undo .
define variable cost-rubl    as decimal   no-undo .
define variable cur-rt-base  as decimal   no-undo .
define variable cur-rt-rubl  as decimal   no-undo .
define variable local_vat-pc as decimal   no-undo .
define variable local_slt-pc as decimal   no-undo .
define variable new_vat-pc   as character no-undo  init "".
define variable new_slt-pc   as character no-undo  init "".
define variable new_round    as character no-undo  init "".
define variable loc_round    as character no-undo  init "".
define variable v-hostcode   as integer   no-undo .
define variable v-plt-id       as integer   no-undo .
define variable v-plt-db-num   as integer   no-undo .
define variable v-pdf-id       as integer   no-undo .
define variable v-pdf-db-num   as integer   no-undo .
define variable v-plt-id2      as integer   no-undo .
define variable v-plt-db-num2  as integer   no-undo .
define variable v1-recid       as recid no-undo .
define variable v1-cur-rt      as decimal   no-undo .
define variable v1-cur-ex      as decimal   no-undo .
define variable v1 as integer   no-undo .
define variable v2 as integer   no-undo .
define variable v3 as integer   no-undo .
define variable v4 as integer   no-undo .
define variable vd as decimal   no-undo .
define variable v-PriceWithVat as decimal   no-undo .
define variable v-PriceWithoutVat as decimal   no-undo .
define variable v-prod-vat     as decimal   no-undo .
define variable v-descript as character no-undo .
define buffer prev-list                     for ub.price-list  .
define buffer buf_price-list-type           for ub.price-list-type  .
define buffer buf_buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer b_price-doc-forming-gds       for ub.price-doc-forming-gds  .
define buffer b_price-doc-forming           for ub.price-doc-forming  .
define buffer buf_gds-obj                   for ub.gds-obj  .
define buffer buf_trn-doc                   for ub.trn-doc  .
define buffer buf_doc-line                  for ub.doc-line  .
define buffer buf_bar-code                  for ub.bar-code  .
define buffer buf_gds-dtl                   for ub.gds-dtl  .
define buffer buf-goods                     for ub.goods  .
define buffer buf-gds-grp                   for ub.gds-grp  .
define variable loc-increase-pc       as decimal   no-undo .
define variable loc-grp-increase-pc   as decimal   no-undo .
define variable loc-grp-round-method  as character no-undo .
define variable loc-grp-round-base    as decimal   no-undo .
define variable p-prc-min             as decimal   no-undo .
define variable p-prc-max             as decimal   no-undo .
define variable p-value-margin        as integer   no-undo.
define variable p-type-margin         as logical   no-undo .
define variable p-value-increase      as integer   no-undo.
define variable p-type-increase       as logical   no-undo .
define variable p-value-rmethod       as integer   no-undo.
define variable p-type-rmethod        as logical   no-undo .
define variable loc-rez               as character no-undo .
define variable t-type                as character no-undo .
define variable g-g                   as logical   no-undo .
define variable var-pr-r-b as character no-undo .
define variable v-base as logical   no-undo .
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  ) no-error .
if error-status :error then do:
   message
     error-status :get-message(1) skip
     return-value skip
     "rbisbase"
     view-as alert-box error
   .
end.
for each  x_obj-group :
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-increase-pc in g#library
  (input  p-gds-code
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output  loc-increase-pc
  ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка метода поиска наценки товара на объекте" skip
     error-status :get-message(1) .
  end.
run gds-attr-margin-value
( input   p-gds-code           ,
  input   x_obj-group.obj-type ,
  input   x_obj-group.obj-code ,
  output  p-prc-min            ,
  output  p-prc-max            ,
  output  loc-grp-increase-pc  ,
  output  loc-grp-round-method ,
  output  loc-grp-round-base   ,
  output  p-value-margin       ,
  output  p-type-margin        ,
  output  p-value-increase     ,
  output  p-type-increase      ,
  output  p-value-rmethod      ,
  output  p-type-rmethod
  ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка процедуры поиска наценки по группе товара на объекте" skip
     error-status :get-message(1) .
  end.
  g-g = false .
  find first buf-goods no-lock where buf-goods.gds-code =  p-gds-code no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  case p-calc-method:
    when 'Единая':U or
    when 'Отсутствует':U or
    when 'Не-считать':U or
    when 'Откат_цен':U
    then do:
       p-increase-pc  = 0  .
       p-round-method = 'Отключено':U .
    end.
    when 'Товар':U then do:
      case buf-goods.calc-method:
        when 'Группа':U then do:
          find buf-gds-grp no-lock where
               buf-gds-grp.node-code = buf-goods.grp-code.
           assign
            p-increase-pc  = loc-grp-increase-pc
            p-round-method = loc-grp-round-method
            p-round-base   = loc-grp-round-base
            g-g = true
           .
        end.
        otherwise do:
           p-increase-pc  =  loc-increase-pc .
        end.
      end case.
      if g-g = false then do:
          run gdsoattr-value
             ( input 'round-method':U ,
               input p-gds-code ,
               input x_obj-group.obj-type ,
               input x_obj-group.obj-code ,
               output loc-rez ,
               output t-type
               ) no-error  .
              if error-status :error then message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                "gdsoattr-value"
                view-as alert-box error .
          case NUM-ENTRIES (loc-rez," ") :
              when 0 then do:
              end.
              when 1 then do:
                p-round-method = loc-rez .
                p-round-base   = 0 .
              end.
              when 2 then do:
                p-round-method = entry(1 , loc-rez, " " ).
                p-round-base   = decimal(entry(2 , loc-rez, " " )) .
              end.
              otherwise do:
                p-round-method = entry(1 , loc-rez, " " ).
                p-round-base   = decimal(entry(NUM-ENTRIES (loc-rez," ") , loc-rez, " " )) .
              end.
          end case.
      end.
    end.
  end case.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output v-hostcode
  ) no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "hostcode"
        view-as alert-box error
      .
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  p-gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-hostcode
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output local_vat-pc
  ) no-error .
     if error-status :error then message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "НДС"
       view-as alert-box error
     .
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  p-gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-hostcode
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output local_slt-pc
  ) no-error .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "НсП"
      view-as alert-box error
    .
    new_slt-pc = new_slt-pc + string(local_slt-pc) + chr(4) .
    new_vat-pc = new_vat-pc + string(local_vat-pc) + chr(4) .
    new_round  = new_round  + string(p-increase-pc) + "% " +  string(p-round-method) + "^" +  string(p-round-base)   + chr(4) .
    loc_round  = string(p-increase-pc) + "% " +  string(p-round-method) + "^" +  string(p-round-base)  .
    find current buf_price-doc-forming no-lock no-error .
    if not available buf_price-doc-forming then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "qqqqqqqq"
       view-as alert-box error
     .
    end.
end.
assign
  v-plt-id     = p-plt-id
  v-plt-db-num = p-plt-db
  p-new-calc-method = p-calc-method
.
run re-define in this-procedure (
    input-output p-calc-method
  , input p-gds-code
  ) no-error .
  if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "re-define"
       view-as alert-box error
     .
  end.
  define variable v-sps as character no-undo .
v-sps =
 "Товар,
Группа,
Учетная,
Учет-объект,
Учет-резерв,
Приходная,
Прих-объект,
Начальная,
Старая,
Новая,
Объект,
Накладная,
Накл-безНДС,
Учет-безНДС,
Стар-безНДС,
Переоценка,
ДокФормЦены,
Отсутствует,
Признак,
Специальная,
Не-считать,
Основная,
Единая,
Учет+накл,
Уч+накл-НДС,
НсП,
НсП+накл,
УчетнаяS,
Учет-рзрвS,
ПриходнаяS,
Учет-НДСS,
Производит,
Произв-НДС,
ПорогПр-НДС,
ПорогПр+НДС,
Откат_цен"
  .
if lookup ( p-calc-method , v-sps )  = 0 then  do:
    p-calc-method = entry (1,p-calc-method, " ") no-error .
    if error-status :error then message p-calc-method.
end.
define variable v-i as integer   no-undo init 0.
  for each  x_obj-group :
      v-i = v-i + 1.
      if entry( v-i, new_round , chr(4) ) <> string ( loc_round ) then do:
          message "На выбранных объектах используются разные параметры Наценки и округления ! Для расчета выбран" string ( loc_round ) skip "для товара  "
          skip
          "код     :" p-gds-code  skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic     skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
      if entry( v-i, new_vat-pc , chr(4) ) <> string ( local_vat-pc ) then do:
          message "На выбранных объектах используются разные НДС ! Для расчета выбран" string ( local_vat-pc ) "%" skip "для товара  "
          skip
          "код     :" p-gds-code  skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic     skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
      if entry( v-i, new_slt-pc , chr(4) ) <> string ( local_slt-pc ) then do:
          message "На выбранных объектах используются разные НсП ! Для расчета выбран" string ( local_slt-pc )
          skip
          "код     :" p-gds-code   skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic             skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
  end.
assign
  p-vat-pc  = local_vat-pc
  p-slt-pc  = local_slt-pc
.
find first buf_price-list-type no-lock where
           buf_price-list-type.plt-id     = v-plt-id    and
           buf_price-list-type.plt-db-num = v-plt-db-num
           no-error .
   if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "q5"
      view-as alert-box error
    .
   return error return-value .
   end.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-mpl in g#library2
  (input  buf_price-list-type.gop-id
  ,input  buf_price-list-type.gop-db-num
  ,input  p-b-code
  ,input  0
  ,input  0
  ,output v1-recid
  ,output p-price-prev-doc
  ,output v1-cur-rt
  ,output v1-cur-ex
  ) no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "bc-mpl"
      view-as alert-box error
    .
define buffer old1_price-doc-forming     for ub.price-doc-forming  .
define buffer old1_price-doc-forming-gds for ub.price-doc-forming-gds  .
find first old1_price-doc-forming no-lock where
           recid(old1_price-doc-forming) = v1-recid no-error .
find first old1_price-doc-forming-gds no-lock where
           old1_price-doc-forming-gds.pdf-db      = old1_price-doc-forming.pdf-db      and
           old1_price-doc-forming-gds.pdf-id      = old1_price-doc-forming.pdf-id      and
           old1_price-doc-forming-gds.plt-db-num  = old1_price-doc-forming.plt-db-num  and
           old1_price-doc-forming-gds.plt-id      = old1_price-doc-forming.plt-id      and
           old1_price-doc-forming-gds.b-code      = p-b-code
           no-error .
if available old1_price-doc-forming-gds then do:
   p-d-pcnt = old1_price-doc-forming-gds.d-pcnt .
end.
else do:
  p-d-pcnt = 0 .
end.
case p-calc-method :
   when 'Новая':U or
   when 'Не-считать':U then do:
    assign
      p-new-calc-method = p-calc-method
      cost-rubl = ?
      cost-base = ?
    .
      if available buf_price-doc-forming then do:
        assign
          v-pdf-id      = buf_price-doc-forming.pdf-id
          v-pdf-db-num  = buf_price-doc-forming.pdf-db
          v-plt-id2     = buf_price-doc-forming.plt-id
          v-plt-db-num2 = buf_price-doc-forming.plt-db-num
        .
        find first buf_buf_price-doc-forming-gds no-lock where
              buf_buf_price-doc-forming-gds.pdf-id =  v-pdf-id and
              buf_buf_price-doc-forming-gds.pdf-db =  v-pdf-db-num and
              buf_buf_price-doc-forming-gds.plt-id =  v-plt-id2     and
              buf_buf_price-doc-forming-gds.plt-db-num =  v-plt-db-num2 and
              buf_buf_price-doc-forming-gds.b-code =  p-b-code
              no-error .
            if available buf_buf_price-doc-forming-gds then do:
                assign
                  cost-rubl = buf_buf_price-doc-forming-gds.price-sale-rubl
                  cost-base = buf_buf_price-doc-forming-gds.price-sale-base
                .
            end.
      end.
   end.
   when 'УчетнаяS':U  or
   when 'Учет-рзрвS':U  or
   when 'ПриходнаяS':U
   then do:
      run str/sgdsavrg.p
      (   input  p-calc-method    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
   end.
   when 'Учет-НДСS':U or
   when 'Накл-безНДС':U or
   when 'Стар-безНДС':U or
   when 'Старая':U or
   when 'Учет+накл':U or
   when 'Уч+накл-НДС':U or
   when 'Откат_цен':U then do:
      run str/mplnovat.p
        ( input  p-calc-method    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          input  0 ,
          input  v-doc-code ,
          input  p-vat-pc      ,
          input  p-slt-pc      ,
          output vd  ,
          output vd  ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
   end.
   when 'Накладная':U then do:
        find first buf_trn-doc no-lock where buf_trn-doc.doc-code = v-doc-code no-error .
        find first buf_doc-line  no-lock where
                  buf_doc-line.doc-code = v-doc-code      and
                  buf_doc-line.artic    = p-artic         and
                  buf_doc-line.prod-type   = p-prod-type  and
                  buf_doc-line.prod-code   = p-prod-code no-error .
        find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
        find first buf_gds-dtl no-lock where
                   buf_gds-dtl.doc-code  = v-doc-code   and
                   buf_gds-dtl.artic     = p-artic      and
                   buf_gds-dtl.prod-type = p-prod-type  and
                   buf_gds-dtl.prod-code = p-prod-code  and
                   buf_gds-dtl.prt-code  = buf_bar-code.node-code no-error .
        assign
          v1 = recid (buf_trn-doc)
          v2 = recid (buf_doc-line)
          v3 = recid (buf_gds-dtl)
          v4  = buf_gds-dtl.prt-code
          no-error .
          if not v-base then do:
            run str/pr-wbil.p
            ( input ""            ,
              input 'Накладная':U ,
              input v1               ,
              input v2               ,
              input v3               ,
              input v-doc-code       ,
              input ""               ,
              input p-gds-code       ,
              input p-artic          ,
              input p-prod-type      ,
              input p-prod-code      ,
              input v4               ,
              input 0                ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-rubl else buf_gds-dtl.price-rubl ) ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-base else buf_gds-dtl.price-base ) ,
              output cost-rubl       ,
              output v4
              ) no-error .
          end.
          else do:
            run str/pr-wbil.p
            ( input ""            ,
              input 'Накладная':U ,
              input v1               ,
              input v2               ,
              input v3               ,
              input v-doc-code       ,
              input ""               ,
              input p-gds-code       ,
              input p-artic          ,
              input p-prod-type      ,
              input p-prod-code      ,
              input v4               ,
              input 0                ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-rubl else buf_gds-dtl.price-rubl ) ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-base else buf_gds-dtl.price-base ) ,
              output cost-base       ,
              output v4
              ) no-error .
          end.
          if not error-status :error then
              assign
                p-new-calc-method = 'Накладная':U + " " + v-doc-code
             .
    end.
    when 'Переоценка':U then do:
      find prev-list where
           prev-list.b-code     = p-b-code and
           prev-list.price-type = "" and
           prev-list.doc-num    = v-doc-code no-lock no-error.
      if available prev-list then
        assign
          p-new-calc-method = 'Переоценка':U + " " + v-doc-code
          cur-rt-base = prev-list.road-tax
          cur-rt-rubl = prev-list.road-tax
          cost-rubl = prev-list.price-sale
          cost-base = prev-list.price-sale
          .
      else
        message "Нет строки в переоценке :" v-doc-code "для товара :" p-artic
                "- расчет невозможен."
                view-as alert-box information .
    end.
    when 'ДокФормЦены':U then do:
    find first b_price-doc-forming no-lock where
               b_price-doc-forming.pdf-id     = integer(entry(1,v-doc-code,"|")) and
               b_price-doc-forming.pdf-db     = integer(entry(2,v-doc-code,"|"))
               no-error .
      find b_price-doc-forming-gds no-lock where
           b_price-doc-forming-gds.b-code     = p-b-code and
           b_price-doc-forming-gds.plt-db-num = b_price-doc-forming.plt-db-num and
           b_price-doc-forming-gds.plt-id     = b_price-doc-forming.plt-id and
           b_price-doc-forming-gds.pdf-id     = b_price-doc-forming.pdf-id and
           b_price-doc-forming-gds.pdf-db     = b_price-doc-forming.pdf-db
           no-error.
      if available b_price-doc-forming-gds then
        assign
          p-new-calc-method = 'ДокФормЦены':U + " " + v-doc-code
          cur-rt-base = b_price-doc-forming-gds.road-tax-base
          cur-rt-rubl = b_price-doc-forming-gds.road-tax-rubl
          cost-rubl   = b_price-doc-forming-gds.price-sale-rubl
          cost-base   = b_price-doc-forming-gds.price-sale-base
          .
      else
        message "Нет строки в ДНЦ :" integer(entry(1,v-doc-code,"|")) integer(entry(2,v-doc-code,"|")) skip
                "для товара :" skip
                 "Бар-код" p-b-code     skip
                 "Артикул" p-artic      skip
                  p-prod-type  skip
                  p-prod-code  skip
                "- расчет невозможен."
                view-as alert-box information .
    end.
    when 'Единая':U then do:
        assign
          p-new-calc-method = 'Единая':U + " " + string(common-price)
          cost-rubl = common-price
          cost-base = common-price
          .
    end.
    when 'Объект':U then do:
    find first buf_gds-obj no-lock where
               buf_gds-obj.gds-code = p-gds-code and
               buf_gds-obj.obj-type = v-copy-type and
               buf_gds-obj.obj-code = v-copy-code no-error .
        if available buf_gds-obj then do:
        assign
          p-new-calc-method = 'Объект':U + " " + v-copy-type + string(v-copy-code)
          cost-rubl = buf_gds-obj.price-sale
          cost-base = buf_gds-obj.price-sale
          .
        end.
        else do:
            message "Нет товара на объекте :" v-copy-type v-copy-code skip
                    "для товара :" p-artic  "- расчет невозможен."
                    view-as alert-box information .
        end.
    end.
   when 'Отсутствует':U or
   when "" then do:
      run str/mplnovat.p
        ( input  'Отсутствует':U    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          input  0 ,
          input  v-doc-code ,
          input  p-vat-pc      ,
          input  p-slt-pc      ,
          output vd  ,
          output vd  ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
          cost-rubl = vd * p-exch-rate / p-exch-scale .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = 'Отсутствует':U .
   end.
   when 'Основная':U then do:
   end.
  when 'ПорогПр-НДС':U then do:
    message 1.
  end.
  when 'ПорогПр+НДС':U then do:
    message 2.
  end.
  when 'Производит':U
     then do:
      find first x_obj-group .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  p-b-code
 , input  x_obj-group.obj-type
 , input  x_obj-group.obj-code
 , output v-PriceWithVat
 , output vd
 , output v-prod-vat
 , output v-str1
 , output v-str1
        ) no-error .
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара :" p-artic  p-b-code
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#2" update g#log as logical .
      end.
      else do:
          cost-rubl = vd * p-exch-rate / p-exch-scale .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
      end.
  end.
  when 'Произв-НДС':U
    then do:
      find first x_obj-group .
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  p-b-code
 , input  x_obj-group.obj-type
 , input  x_obj-group.obj-code
 , output vd
 , output v-PriceWithVat
 , output v-prod-vat
 , output v-str1
 , output v-str1
        ) no-error .
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара :" p-artic  p-b-code
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          cost-rubl = vd * p-exch-rate / p-exch-scale .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
      end.
    end.
   otherwise do:
     message  "Не просчитывается метод p-calc-method = " p-calc-method  skip
               p-new-calc-method  skip
              "p-price-prev-doc " p-price-prev-doc  skip
              "mpl-lib ERR !!! " skip
              'артикул ' p-artic skip
              view-as alert-box information .
   end.
 end case.
run main-road-taxs in this-procedure
  ( input p-artic     ,
    input p-prod-type ,
    input p-prod-code ,
    input-output cur-rt-base ,
    input-output cur-rt-rubl )
    no-error .
    if error-status :error then do:
       message
         error-status :get-message(1) skip
         return-value skip
         "main-road-taxs"
         view-as alert-box error
       .
    end.
  if p-exch-scale = 0  or  p-exch-scale = ?  then do:
    return error "Не определен курс валюты документа" .
  end.
  if p-base-scale = 0  or  p-base-scale = ?  then do:
     return error "Не определен курс базовой валюты " .
  end.
if v-base = false then var-pr-r-b = "rubl":U .
                  else var-pr-r-b =  "base":U .
    if var-pr-r-b = "rubl":U then do:
        case p-calc-method :
         when 'ПорогПр-НДС':U then do:
            message 3.
         end.
         when 'ПорогПр+НДС':U then do:
             message 4.
         end.
         when 'Производит':U then do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100)   .
         end.
         when 'Произв-НДС':U then do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100) * (1 +  p-vat-pc / 100)  .
         end.
         otherwise do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100) .
         end.
        end case.
        assign
          p-price-calc-rubl  =  cost-rubl
          p-road-tax-rubl    =  cur-rt-rubl
          p-price-calc-doc   =  p-price-calc-rubl / p-exch-rate * p-exch-scale
          p-price-sale-doc   =  p-price-sale-rubl / p-exch-rate * p-exch-scale
          p-road-tax-doc     =  p-road-tax-rubl   / p-exch-rate * p-exch-scale
        .
    end.
    else dO:
         case p-calc-method :
         when 'ПорогПр-НДС':U then do:
            message 5.
         end.
         when 'ПорогПр+НДС':U then do:
             message 6.
         end.
         when 'Производит':U then do:
            p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) .
         end.
         when 'Произв-НДС':U then do:
            p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) * (1 + p-vat-pc / 100)  .
         end.
         otherwise do:
            p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) .
         end.
         end case.
        assign
          p-price-calc-base  =  cost-base
          p-road-tax-base    =  cur-rt-base
          p-price-calc-rubl  =  p-price-calc-base * p-base-rate / p-base-scale
          p-price-sale-rubl  =  p-price-sale-base * p-base-rate / p-base-scale
          p-road-tax-rubl    =  p-road-tax-base   * p-base-rate / p-base-scale
          p-price-calc-doc   =  p-price-calc-rubl / p-exch-rate * p-exch-scale
          p-price-sale-doc   =  p-price-sale-rubl / p-exch-rate * p-exch-scale
          p-road-tax-doc     =  p-road-tax-rubl   / p-exch-rate * p-exch-scale
        .
    end.
case p-round-method :
  when '9-окончание':U then do:
    if p-price-sale-doc < 29 then do:
      if (p-price-sale-doc - truncate (p-price-sale-doc, 0)) <> 0 then do:
        assign
          p-price-sale-doc = truncate (p-price-sale-doc, 0) + 1
        .
      end.
    end.
    else do:
      if (p-price-sale-doc modulo 10) < 3 then do:
        assign
          p-price-sale-doc = (p-price-sale-doc - (p-price-sale-doc modulo 100))
              + ( truncate (((p-price-sale-doc modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          p-price-sale-doc = (p-price-sale-doc - (p-price-sale-doc modulo 100))
              + ( truncate (((p-price-sale-doc modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        p-price-sale-doc = round (p-price-sale-doc, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if p-price-sale-doc < p-round-base then do:
      assign
        p-price-sale-doc = truncate (p-price-sale-doc, 0) + 0.99
      .
    end.
    else do:
      assign
        p-price-sale-doc = truncate (p-price-sale-doc / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      p-price-sale-doc = round (p-price-sale-doc, 0)
    .
  end.
  when 'Произвольно':U then do:
    if p-round-base <> 0 then do:
      assign
        p-price-sale-doc = round (p-price-sale-doc / p-round-base, 0) * p-round-base
      .
      if p-price-sale-doc = 0 then do:
        assign
          p-price-sale-doc = p-round-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if p-round-base <> 0 then do:
      if truncate ( p-price-sale-doc / p-round-base, 0 ) <> (p-price-sale-doc / p-round-base) then do:
        assign
          p-price-sale-doc = truncate (p-price-sale-doc / p-round-base, 0) * p-round-base + p-round-base
        .
      end.
    end.
    if p-price-sale-doc = 0 then do:
      assign
        p-price-sale-doc = p-round-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if p-round-base <> 0 then do:
      assign
        p-price-sale-doc = p-price-sale-doc * p-round-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" p-round-method skip
      "round-base"   p-round-base   skip
      "price"        p-price-sale-doc             skip
      view-as alert-box error .
  end.
end.
    if error-status :error then do:
    message
      error-status :get-message(1) skip
      return-value skip
      "pr-99"
      view-as alert-box error
    .
    end.
  p-price-calc-rubl = p-price-calc-doc * p-exch-rate / p-exch-scale .
  p-price-sale-rubl = p-price-sale-doc * p-exch-rate / p-exch-scale .
  p-road-tax-rubl   = p-road-tax-doc   * p-exch-rate / p-exch-scale .
  p-price-prev-rubl = p-price-prev-doc * p-exch-rate / p-exch-scale .
  p-price-calc-base = p-price-calc-rubl / p-base-rate * p-base-scale .
  p-price-sale-base = p-price-sale-rubl / p-base-rate * p-base-scale .
  p-road-tax-base   = p-road-tax-rubl   / p-base-rate * p-base-scale .
  p-price-prev-base = p-price-prev-rubl / p-base-rate * p-base-scale .
  define buffer bufold_price-doc-forming for ub.price-doc-forming  .
  find first bufold_price-doc-forming where  recid(bufold_price-doc-forming) = v1-recid no-lock no-error .
  p-prev-doc-code = if available bufold_price-doc-forming
                       then (string(bufold_price-doc-forming.pdf-id) + " БД" + string(bufold_price-doc-forming.pdf-db))
                       else "" .
  end.
end procedure.
PROCEDURE calc-price-line :
define input  parameter  p-calc-method      as character no-undo .
define input  parameter  p-increase-pc      as decimal   no-undo .
define input  parameter  p-round-method     as character no-undo .
define input  parameter  p-round-base       as decimal   no-undo .
define input  parameter  p-b-code           as integer   no-undo .
define input  parameter  p-gds-code         as integer   no-undo .
define input  parameter  p-artic            as character no-undo .
define input  parameter  p-prod-type        as character no-undo .
define input  parameter  p-prod-code        as integer   no-undo .
define input  parameter  p-base-rate        as decimal   no-undo .
define input  parameter  p-base-scale       as decimal   no-undo .
define input  parameter  p-exch-scale       as decimal   no-undo .
define input  parameter  p-exch-rate        as decimal   no-undo .
define input  parameter  v-doc-code         as character no-undo .
define input  parameter  common-price       as decimal   no-undo .
define input  parameter  v-copy-type        as character no-undo .
define input  parameter  v-copy-code        as integer   no-undo .
define output parameter  p-new-calc-method  as character no-undo .
define output parameter  p-price-calc-base  as decimal   no-undo .
define output parameter  p-price-calc-doc   as decimal   no-undo .
define output parameter  p-price-calc-rubl  as decimal   no-undo .
define output parameter  p-price-prev-base  as decimal   no-undo .
define output parameter  p-price-prev-doc   as decimal   no-undo .
define output parameter  p-price-prev-rubl  as decimal   no-undo .
define output parameter  p-price-sale-base  as decimal   no-undo .
define output parameter  p-price-sale-doc   as decimal   no-undo .
define output parameter  p-price-sale-rubl  as decimal   no-undo .
define output parameter  p-road-tax-base    as decimal   no-undo .
define output parameter  p-road-tax-doc     as decimal   no-undo .
define output parameter  p-road-tax-rubl    as decimal   no-undo .
define output parameter  p-excise-base      as decimal   no-undo .
define output parameter  p-excise-doc       as decimal   no-undo .
define output parameter  p-excise-rubl      as decimal   no-undo .
define output parameter  p-vat-pc           as decimal   no-undo .
define output parameter  p-slt-pc           as decimal   no-undo .
define output parameter  p-prev-doc-code    as character no-undo .
define output parameter  p-d-pcnt           as decimal   no-undo .
define variable cost-base    as decimal   no-undo .
define variable cost-rubl    as decimal   no-undo .
define variable cur-rt-base  as decimal   no-undo .
define variable cur-rt-rubl  as decimal   no-undo .
define variable local_vat-pc as decimal   no-undo .
define variable local_slt-pc as decimal   no-undo .
define variable new_vat-pc   as character no-undo  init "".
define variable new_slt-pc   as character no-undo  init "".
define variable new_round    as character no-undo  init "".
define variable loc_round    as character no-undo  init "".
define variable v-hostcode   as integer   no-undo .
define variable v-plt-id       as integer   no-undo .
define variable v-plt-db-num   as integer   no-undo .
define variable v-pdf-id       as integer   no-undo .
define variable v-pdf-db-num   as integer   no-undo .
define variable v-plt-id2      as integer   no-undo .
define variable v-plt-db-num2  as integer   no-undo .
define variable v1-recid       as recid no-undo .
define variable v1-cur-rt      as decimal   no-undo .
define variable v1-cur-ex      as decimal   no-undo .
define variable v1 as integer   no-undo .
define variable v2 as integer   no-undo .
define variable v3 as integer   no-undo .
define variable v4 as integer   no-undo .
define variable vd as decimal   no-undo .
define variable v-descript as character no-undo .
define buffer prev-list                     for ub.price-list  .
define buffer buf_price-list-type           for ub.price-list-type  .
define buffer buf_buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer b_price-doc-forming-gds       for ub.price-doc-forming-gds  .
define buffer b_price-doc-forming           for ub.price-doc-forming  .
define buffer buf_gds-obj                   for ub.gds-obj  .
define buffer buf_trn-doc                   for ub.trn-doc  .
define buffer buf_doc-line                  for ub.doc-line  .
define buffer buf_bar-code                  for ub.bar-code  .
define buffer buf_gds-dtl                   for ub.gds-dtl  .
define buffer buf-goods                     for ub.goods  .
define buffer buf-gds-grp                   for ub.gds-grp  .
define buffer buf_contract-specif           for ub.contract-specif .
define buffer buf_contract                  for ub.contract .
define variable loc-increase-pc       as decimal   no-undo .
define variable loc-grp-increase-pc   as decimal   no-undo .
define variable loc-grp-round-method  as character no-undo .
define variable loc-grp-round-base    as decimal   no-undo .
define variable p-prc-min             as decimal   no-undo .
define variable p-prc-max             as decimal   no-undo .
define variable p-value-margin        as integer   no-undo.
define variable p-type-margin         as logical   no-undo .
define variable p-value-increase      as integer   no-undo.
define variable p-type-increase       as logical   no-undo .
define variable p-value-rmethod       as integer   no-undo.
define variable p-type-rmethod        as logical   no-undo .
define variable loc-rez               as character no-undo .
define variable t-type                as character no-undo .
define variable g-g                   as logical   no-undo .
define variable v-PriceWithVat as decimal   no-undo .
define variable v-prod-vat     as decimal   no-undo .
define variable var-pr-r-b as character no-undo .
define variable v-base as logical   no-undo .
define variable v-num-specif          as integer   no-undo .
define variable v-spis                as character no-undo .
define variable v-contract-code       as integer   no-undo .
define variable v-bonus               as decimal   no-undo .
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
if v-base = false then var-pr-r-b = "rubl":U .
                  else var-pr-r-b =  "base":U .
for each  x_obj-group :
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-increase-pc in g#library
  (input  p-gds-code
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output  loc-increase-pc
  ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка метода поиска наценки товара на объекте" skip
     error-status :get-message(1) .
  end.
run gds-attr-margin-value
( input   p-gds-code           ,
  input   x_obj-group.obj-type ,
  input   x_obj-group.obj-code ,
  output  p-prc-min            ,
  output  p-prc-max            ,
  output  loc-grp-increase-pc  ,
  output  loc-grp-round-method ,
  output  loc-grp-round-base   ,
  output  p-value-margin       ,
  output  p-type-margin        ,
  output  p-value-increase     ,
  output  p-type-increase      ,
  output  p-value-rmethod      ,
  output  p-type-rmethod
  ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка процедуры поиска наценки по группе товара на объекте" skip
     error-status :get-message(1) .
  end.
  g-g = false .
  find first buf-goods no-lock where buf-goods.gds-code =  p-gds-code no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  case p-calc-method:
    when 'Единая':U or
    when 'Отсутствует':U or
    when 'Не-считать':U or
    when 'Откат_цен':U
    then do:
       p-increase-pc  = 0  .
       p-round-method = 'Отключено':U .
    end.
    when 'Товар':U then do:
      case buf-goods.calc-method:
        when 'Группа':U then do:
          find buf-gds-grp no-lock where
               buf-gds-grp.node-code = buf-goods.grp-code.
           p-increase-pc  = loc-grp-increase-pc .
           p-round-method = loc-grp-round-method .
           p-round-base   = loc-grp-round-base .
           g-g = true  .
        end.
        otherwise do:
           p-increase-pc  =  loc-increase-pc .
        end.
      end case.
      if g-g = false then do:
          run gdsoattr-value
             ( input 'round-method':U ,
               input p-gds-code ,
               input x_obj-group.obj-type ,
               input x_obj-group.obj-code ,
               output loc-rez ,
               output t-type
               ) no-error  .
              if error-status :error then message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                "gdsoattr-value"
                view-as alert-box error .
          case NUM-ENTRIES (loc-rez," ") :
              when 0 then do:
              end.
              when 1 then do:
                p-round-method = loc-rez .
                p-round-base   = 0 .
              end.
              when 2 then do:
                p-round-method = entry(1 , loc-rez, " " ).
                p-round-base   = decimal(entry(2 , loc-rez, " " )) .
              end.
              otherwise do:
                p-round-method = entry(1 , loc-rez, " " ).
                p-round-base   = decimal(entry(NUM-ENTRIES (loc-rez," ") , loc-rez, " " )) .
              end.
          end case.
      end.
    end.
  end case.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output v-hostcode
  ) no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "hostcode"
        view-as alert-box error
      .
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  p-gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-hostcode
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output local_vat-pc
  ) no-error .
     if error-status :error then message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "НДС"
       view-as alert-box error
     .
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  p-gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-hostcode
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output local_slt-pc
  ) no-error .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "НсП"
      view-as alert-box error
    .
    new_slt-pc = new_slt-pc + string(local_slt-pc) + chr(4) .
    new_vat-pc = new_vat-pc + string(local_vat-pc) + chr(4) .
    new_round  = new_round  + string(p-increase-pc) + "% " +  string(p-round-method) + "^" +  string(p-round-base)   + chr(4) .
    loc_round  = string(p-increase-pc) + "% " +  string(p-round-method) + "^" +  string(p-round-base)  .
    find current buf_price-doc-forming no-lock no-error .
    if not available buf_price-doc-forming then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "qqqqqqqq"
       view-as alert-box error
     .
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  ?
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,input  no
  ,output v-plt-id
  ,output v-plt-db-num
  ) no-error .
      if error-status :error then return error return-value .
    end.
end.
p-new-calc-method = p-calc-method .
run re-define in this-procedure (
    input-output p-calc-method
  , input p-gds-code
  ) .
  define variable v-sps as character no-undo .
v-sps =
 "Товар,
Группа,
Учетная,
Учет-объект,
Учет-резерв,
Приходная,
Прих-объект,
Начальная,
Старая,
Новая,
Объект,
Накладная,
Накл-безНДС,
Учет-безНДС,
Стар-безНДС,
Переоценка,
ДокФормЦены,
Отсутствует,
Признак,
Специальная,
Не-считать,
Основная,
Единая,
Учет+накл,
Уч+накл-НДС,
НсП,
НсП+накл,
УчетнаяS,
Учет-рзрвS,
ПриходнаяS,
Учет-НДСS,
Откат_цен,
Спецификация
"
  .
if lookup ( p-calc-method , v-sps )  = 0 then  do:
    p-calc-method = entry (1,p-calc-method, " ") no-error .
    if error-status :error then message p-calc-method.
end.
define variable v-i as integer   no-undo init 0.
  for each  x_obj-group :
      v-i = v-i + 1.
      if entry( v-i, new_round , chr(4) ) <> string ( loc_round ) then do:
          message "На выбранных объектах используются разные параметры Наценки и округления ! Для расчета выбран" string ( loc_round ) skip "для товара  "
          skip
          "код     :" p-gds-code  skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic     skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
      if entry( v-i, new_vat-pc , chr(4) ) <> string ( local_vat-pc ) then do:
          message "На выбранных объектах используются разные НДС ! Для расчета выбран" string ( local_vat-pc ) "%" skip "для товара  "
          skip
          "код     :" p-gds-code  skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic     skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
      if entry( v-i, new_slt-pc , chr(4) ) <> string ( local_slt-pc ) then do:
          message "На выбранных объектах используются разные НсП ! Для расчета выбран" string ( local_slt-pc )
          skip
          "код     :" p-gds-code   skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic             skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
  end.
p-vat-pc  = local_vat-pc .
p-slt-pc  = local_slt-pc .
  if available buf_price-doc-forming then do:
     find first buf_price-list-type no-lock where
                buf_price-list-type.plt-id     = buf_price-doc-forming.plt-id    and
                buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num
                no-error .
     if error-status :error then return error return-value .
  end.
  else do:
find first buf_price-list-type no-lock where
           buf_price-list-type.plt-id     = v-plt-id    and
           buf_price-list-type.plt-db-num = v-plt-db-num
           no-error .
   if error-status :error then return error return-value .
  end.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-mpl in g#library2
  (input  buf_price-list-type.gop-id
  ,input  buf_price-list-type.gop-db-num
  ,input  p-b-code
  ,input  0
  ,input  0
  ,output v1-recid
  ,output p-price-prev-doc
  ,output v1-cur-rt
  ,output v1-cur-ex
  ) no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "bc-mpl"
      view-as alert-box error
    .
define buffer old1_price-doc-forming     for ub.price-doc-forming  .
define buffer old1_price-doc-forming-gds for ub.price-doc-forming-gds  .
find first old1_price-doc-forming no-lock where
           recid(old1_price-doc-forming) = v1-recid no-error .
find first old1_price-doc-forming-gds no-lock where
           old1_price-doc-forming-gds.pdf-db      = old1_price-doc-forming.pdf-db      and
           old1_price-doc-forming-gds.pdf-id      = old1_price-doc-forming.pdf-id      and
           old1_price-doc-forming-gds.plt-db-num  = old1_price-doc-forming.plt-db-num  and
           old1_price-doc-forming-gds.plt-id      = old1_price-doc-forming.plt-id      and
           old1_price-doc-forming-gds.b-code      = p-b-code
           no-error .
if available old1_price-doc-forming-gds then do:
   p-d-pcnt = old1_price-doc-forming-gds.d-pcnt .
end.
else do:
  p-d-pcnt = 0 .
end.
case p-calc-method :
   when 'Новая':U or
   when 'Не-считать':U then do:
    assign
      p-new-calc-method = p-calc-method
      cost-rubl = ?
      cost-base = ?
    .
      if available buf_price-doc-forming then do:
        assign
          v-pdf-id      = buf_price-doc-forming.pdf-id
          v-pdf-db-num  = buf_price-doc-forming.pdf-db
          v-plt-id2     = buf_price-doc-forming.plt-id
          v-plt-db-num2 = buf_price-doc-forming.plt-db-num
        .
        find first buf_buf_price-doc-forming-gds no-lock where
              buf_buf_price-doc-forming-gds.pdf-id =  v-pdf-id and
              buf_buf_price-doc-forming-gds.pdf-db =  v-pdf-db-num and
              buf_buf_price-doc-forming-gds.plt-id =  v-plt-id2     and
              buf_buf_price-doc-forming-gds.plt-db-num =  v-plt-db-num2 and
              buf_buf_price-doc-forming-gds.b-code =  p-b-code
              no-error .
            if available buf_buf_price-doc-forming-gds then do:
                assign
                  cost-rubl = buf_buf_price-doc-forming-gds.price-sale-rubl
                  cost-base = buf_buf_price-doc-forming-gds.price-sale-base
                .
            end.
      end.
   end.
   when 'УчетнаяS':U  or
   when 'Учет-рзрвS':U  or
   when 'ПриходнаяS':U
   then do:
      run str/sgdsavrg.p
      (   input  p-calc-method    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
   end.
   when 'Учет-НДСS':U or
   when 'Накл-безНДС':U or
   when 'Стар-безНДС':U or
   when 'Старая':U or
   when 'Учет+накл':U or
   when 'Уч+накл-НДС':U or
   when 'Откат_цен':U then do:
      run str/mplnovat.p
        ( input  p-calc-method    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          input  0 ,
          input  v-doc-code ,
          input  p-vat-pc      ,
          input  p-slt-pc      ,
          output vd  ,
          output vd  ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
   end.
   when 'Накладная':U then do:
        find first buf_trn-doc no-lock where buf_trn-doc.doc-code = v-doc-code no-error .
        find first buf_doc-line  no-lock where
                  buf_doc-line.doc-code = v-doc-code      and
                  buf_doc-line.artic    = p-artic         and
                  buf_doc-line.prod-type   = p-prod-type  and
                  buf_doc-line.prod-code   = p-prod-code no-error .
        find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
        find first buf_gds-dtl no-lock where
                   buf_gds-dtl.doc-code  = v-doc-code   and
                   buf_gds-dtl.artic     = p-artic      and
                   buf_gds-dtl.prod-type = p-prod-type  and
                   buf_gds-dtl.prod-code = p-prod-code  and
                   buf_gds-dtl.prt-code  = buf_bar-code.node-code no-error .
        assign
          v1 = recid (buf_trn-doc)
          v2 = recid (buf_doc-line)
          v3 = recid (buf_gds-dtl)
          v4  = buf_gds-dtl.prt-code
          no-error .
          if not v-base then do:
            run str/pr-wbil.p
            ( input ""            ,
              input 'Накладная':U ,
              input v1               ,
              input v2               ,
              input v3               ,
              input v-doc-code       ,
              input ""               ,
              input p-gds-code       ,
              input p-artic          ,
              input p-prod-type      ,
              input p-prod-code      ,
              input v4               ,
              input 0                ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-rubl else buf_gds-dtl.price-rubl ) ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-base else buf_gds-dtl.price-base ) ,
              output cost-rubl       ,
              output v4
              ) no-error .
          end.
          else do:
            run str/pr-wbil.p
            ( input ""            ,
              input 'Накладная':U ,
              input v1               ,
              input v2               ,
              input v3               ,
              input v-doc-code       ,
              input ""               ,
              input p-gds-code       ,
              input p-artic          ,
              input p-prod-type      ,
              input p-prod-code      ,
              input v4               ,
              input 0                ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-rubl else buf_gds-dtl.price-rubl ) ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-base else buf_gds-dtl.price-base ) ,
              output cost-base       ,
              output v4
              ) no-error .
          end.
          if not error-status :error then
              assign
                p-new-calc-method = 'Накладная':U + " " + v-doc-code
             .
    end.
    when 'Переоценка':U then do:
      find prev-list where
           prev-list.b-code     = p-b-code and
           prev-list.price-type = "" and
           prev-list.doc-num    = v-doc-code no-lock no-error.
      if available prev-list then
        assign
          p-new-calc-method = 'Переоценка':U + " " + v-doc-code
          cur-rt-base = prev-list.road-tax
          cur-rt-rubl = prev-list.road-tax
          cost-rubl = prev-list.price-sale
          cost-base = prev-list.price-sale
          .
      else
        message "Нет строки в переоценке :" v-doc-code "для товара :" p-artic
                "- расчет невозможен."
                view-as alert-box information .
    end.
    when 'ДокФормЦены':U then do:
    find first b_price-doc-forming no-lock where
               b_price-doc-forming.pdf-id     = integer(entry(1,v-doc-code,"|")) and
               b_price-doc-forming.pdf-db     = integer(entry(2,v-doc-code,"|"))
               no-error .
      find b_price-doc-forming-gds no-lock where
           b_price-doc-forming-gds.b-code     = p-b-code and
           b_price-doc-forming-gds.plt-db-num = b_price-doc-forming.plt-db-num and
           b_price-doc-forming-gds.plt-id     = b_price-doc-forming.plt-id and
           b_price-doc-forming-gds.pdf-id     = b_price-doc-forming.pdf-id and
           b_price-doc-forming-gds.pdf-db     = b_price-doc-forming.pdf-db
           no-error.
      if available b_price-doc-forming-gds then
        assign
          p-new-calc-method = 'ДокФормЦены':U + " " + v-doc-code
          cur-rt-base = b_price-doc-forming-gds.road-tax-base
          cur-rt-rubl = b_price-doc-forming-gds.road-tax-rubl
          cost-rubl   = b_price-doc-forming-gds.price-sale-rubl
          cost-base   = b_price-doc-forming-gds.price-sale-base
          .
      else
        message "Нет строки в ДНЦ :" integer(entry(1,v-doc-code,"|")) integer(entry(2,v-doc-code,"|")) skip
                "для товара :" skip
                 "Бар-код" p-b-code     skip
                 "Артикул" p-artic      skip
                  p-prod-type  skip
                  p-prod-code  skip
                "- расчет невозможен."
                view-as alert-box information .
    end.
    when 'Единая':U then do:
        assign
          p-new-calc-method = 'Единая':U + " " + string(common-price)
          cost-rubl = common-price
          cost-base = common-price
          .
    end.
    when 'Объект':U then do:
    find first buf_gds-obj no-lock where
               buf_gds-obj.gds-code = p-gds-code and
               buf_gds-obj.obj-type = v-copy-type and
               buf_gds-obj.obj-code = v-copy-code no-error .
        if available buf_gds-obj then do:
        assign
          p-new-calc-method = 'Объект':U + " " + v-copy-type + string(v-copy-code)
          cost-rubl = buf_gds-obj.price-sale
          cost-base = buf_gds-obj.price-sale
          .
        end.
        else do:
            message "Нет товара на объекте :" v-copy-type v-copy-code skip
                    "для товара :" p-artic  "- расчет невозможен."
                    view-as alert-box information .
        end.
    end.
   when 'Отсутствует':U or
   when "" then do:
      run str/mplnovat.p
        ( input  'Отсутствует':U    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          input  0 ,
          input  v-doc-code ,
          input  p-vat-pc      ,
          input  p-slt-pc      ,
          output vd  ,
          output vd  ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
          cost-rubl = vd * p-exch-rate / p-exch-scale .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = 'Отсутствует':U .
   end.
   when 'Основная':U then do:
   end.
    when 'ПорогПр-НДС':U then do:
      find first x_obj-group.
          run calc-price-levelprod (
            input 2          ,
            input var-pr-r-b ,
            input p-b-code   ,
            input x_obj-group.obj-type ,
            input x_obj-group.obj-code ,
            output vd,
            output v-descript
          ) no-error.
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара или цена = 0 :" p-artic  p-b-code skip
                "На объекте" x_obj-group.obj-type x_obj-group.obj-code skip
                "- расчет по производителю от последней приходной накладной c пороговой наценкой невозможен."
                view-as alert-box question buttons OK-Cancel title "#4" update g#log1 as logical .
      end.
      else do:
          cost-rubl = vd .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = substitute("&1&2&3" ,p-calc-method, chr(4),v-descript ) .
      end.
    end.
    when 'ПорогПр+НДС':U then do:
      find first x_obj-group.
          run calc-price-levelprod (
            input 1          ,
            input var-pr-r-b ,
            input p-b-code   ,
            input x_obj-group.obj-type ,
            input x_obj-group.obj-code ,
            output vd ,
            output v-descript
          ) no-error.
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара или цена = 0 :" p-artic  p-b-code skip
                "На объекте" x_obj-group.obj-type x_obj-group.obj-code skip
                "- расчет по производителю от последней приходной накладной c пороговой наценкой невозможен."
                view-as alert-box information .
      end.
      else do:
          cost-rubl = vd .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = substitute("&1&2&3" ,p-calc-method, chr(4),v-descript ) .
      end.
    end.
    when 'Производит':U
    then do:
      find first x_obj-group.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  p-b-code
 , input  x_obj-group.obj-type
 , input  x_obj-group.obj-code
 , output v-PriceWithVat
 , output vd
 , output v-prod-vat
 , output v-str1
 , output v-str1
        ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "proprice.i"
        view-as alert-box error
      .
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара или цена = 0 :" p-artic  p-b-code skip
                "На объекте" x_obj-group.obj-type x_obj-group.obj-code skip
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#3" update g#log as logical .
      end.
      else do:
          cost-rubl = vd .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = p-calc-method .
      end.
    end.
    when 'Произв-НДС':U
    then do:
      find first x_obj-group.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  p-b-code
 , input  x_obj-group.obj-type
 , input  x_obj-group.obj-code
 , output vd
 , output v-PriceWithVat
 , output v-prod-vat
 , output v-str1
 , output v-str1
        ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "proprice.i"
        view-as alert-box error
      .
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара или цена = 0 :" p-artic  p-b-code skip
                "На объекте" x_obj-group.obj-type x_obj-group.obj-code skip
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box  .
      end.
      else do:
          cost-rubl = vd .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = p-calc-method .
      end.
    end.
   when 'Спецификация':U
   then do:
      find first x_obj-group.
      assign
        v-num-specif    = 0
        v-contract-code = 0
      .
      for each buf_contract no-lock
      where buf_contract.host-code = v-cntxt-host-code-obj
      :
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
           :
            if buf_contract-specif.gds-code = p-gds-code then do:
              assign
                v-num-specif = v-num-specif + 1
                v-contract-code = buf_contract.contract-code
              .
            end.
        end.
      end.
      if v-num-specif > 1 then do:
         run str/gds-cnts.w
            (input parparentproc
            ,input p-gds-code
            , "b-sel":U
            ,output v-spis
          ) no-error.
        find first buf_contract-specif no-lock
        where recid(buf_contract-specif) = integer(v-spis)
          no-error.
          if available buf_contract-specif then do:
              run read-bonus (
                  input  buf_contract-specif.contract-num  ,
                  input  buf_contract-specif.host-code     ,
                  input  buf_contract-specif.gds-code      ,
                  output v-bonus  ) .
              assign
                cost-rubl = buf_contract-specif.price-cli
                cost-base = buf_contract-specif.price-cli / p-base-rate * p-base-scale
                p-new-calc-method = 'Спецификация':U
              .
              if v-bonus <> ? and v-bonus <> 0 then do:
                 assign
                 cost-rubl = cost-rubl + ( cost-rubl * v-bonus / 100 )
                 cost-base = cost-base + ( cost-base * v-bonus / 100 )
                 .
              end.
          end.
          else do:
            message "Не найдена спецификация с recid " v-spis skip
                    "для товара с артикулом " p-artic skip
                    "на объекте " x_obj-group.obj-type x_obj-group.obj-code skip
                    view-as alert-box information .
          end.
      end.
      if v-num-specif = 0 then do:
          message "Не найдена ни одна спецификация" skip
                  "для товара с артикулом " p-artic skip
                  "на объекте " x_obj-group.obj-type x_obj-group.obj-code skip
                  view-as alert-box information .
      end.
      if v-num-specif = 1 then do:
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  v-contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = v-contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            :
            if buf_contract-specif.gds-code = p-gds-code then do:
              run read-bonus (
                  input  buf_contract-specif.contract-num  ,
                  input  buf_contract-specif.host-code     ,
                  input  buf_contract-specif.gds-code      ,
                  output v-bonus  ) .
              assign
                cost-rubl = buf_contract-specif.price-cli
                cost-base = buf_contract-specif.price-cli / p-base-rate * p-base-scale
                p-new-calc-method = 'Спецификация':U
              .
              if v-bonus <> ? and v-bonus <> 0 then do:
                 assign
                 cost-rubl = cost-rubl + ( cost-rubl * v-bonus / 100 )
                 cost-base = cost-base + ( cost-base * v-bonus / 100 )
                 .
              end.
            end.
          end.
      end.
   end.
   otherwise do:
     message  "Не просчитывается метод p-calc-method = " p-calc-method  skip
               p-new-calc-method  skip
              "p-price-prev-doc " p-price-prev-doc  skip
              "mpl-lib ERR !!! " skip
              'артикул ' p-artic skip
              view-as alert-box information .
   end.
 end case.
run main-road-taxs in this-procedure
  ( input p-artic     ,
    input p-prod-type ,
    input p-prod-code ,
    input-output cur-rt-base ,
    input-output cur-rt-rubl )
    .
  if p-exch-scale = 0  or  p-exch-scale = ?  then do:
    return error "Не определен курс валюты документа" .
  end.
  if p-base-scale = 0  or  p-base-scale = ?  then do:
     return error "Не определен курс базовой валюты " .
  end.
if v-base = false then var-pr-r-b = "rubl":U .
                  else var-pr-r-b =  "base":U .
    if var-pr-r-b = "rubl":U then do:
         case p-calc-method :
         when 'ПорогПр-НДС':U then do:
            p-price-sale-rubl  =  cost-rubl + (cost-rubl * p-vat-pc / 100)  .
         end.
         when 'ПорогПр+НДС':U then do:
            p-price-sale-rubl  =  cost-rubl .
         end.
         when  'Производит':U then do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100)  .
         end.
         when  'Произв-НДС':U then do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100) * (1 + p-vat-pc / 100)   .
         end.
         otherwise do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100) .
         end.
        end case.
        assign
          p-price-calc-rubl  =  cost-rubl
          p-road-tax-rubl    =  cur-rt-rubl
          p-price-calc-doc   =  p-price-calc-rubl / p-exch-rate * p-exch-scale
          p-price-sale-doc   =  p-price-sale-rubl / p-exch-rate * p-exch-scale
          p-road-tax-doc     =  p-road-tax-rubl   / p-exch-rate * p-exch-scale
        .
    end.
    else do:
         case p-calc-method:
            when 'ПорогПр-НДС':U then do:
                p-price-sale-base  =  cost-base + (cost-base * p-vat-pc / 100)  .
            end.
            when 'ПорогПр+НДС':U then do:
                p-price-sale-base  =  cost-base .
            end.
            when 'Производит':U then do:
                p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100)  .
            end.
            when 'Произв-НДС':U then do:
                p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) * (1 + p-vat-pc / 100)  .
            end.
            otherwise do:
                p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) .
            end.
         end case.
        assign
          p-price-calc-base  =  cost-base
          p-road-tax-base    =  cur-rt-base
          p-price-calc-rubl  =  p-price-calc-base * p-base-rate / p-base-scale
          p-price-sale-rubl  =  p-price-sale-base * p-base-rate / p-base-scale
          p-road-tax-rubl    =  p-road-tax-base   * p-base-rate / p-base-scale
          p-price-calc-doc   =  p-price-calc-rubl / p-exch-rate * p-exch-scale
          p-price-sale-doc   =  p-price-sale-rubl / p-exch-rate * p-exch-scale
          p-road-tax-doc     =  p-road-tax-rubl   / p-exch-rate * p-exch-scale
        .
    end.
   if p-price-sale-doc <> 0 then do:
case p-round-method :
  when '9-окончание':U then do:
    if p-price-sale-doc < 29 then do:
      if (p-price-sale-doc - truncate (p-price-sale-doc, 0)) <> 0 then do:
        assign
          p-price-sale-doc = truncate (p-price-sale-doc, 0) + 1
        .
      end.
    end.
    else do:
      if (p-price-sale-doc modulo 10) < 3 then do:
        assign
          p-price-sale-doc = (p-price-sale-doc - (p-price-sale-doc modulo 100))
              + ( truncate (((p-price-sale-doc modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          p-price-sale-doc = (p-price-sale-doc - (p-price-sale-doc modulo 100))
              + ( truncate (((p-price-sale-doc modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        p-price-sale-doc = round (p-price-sale-doc, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if p-price-sale-doc < p-round-base then do:
      assign
        p-price-sale-doc = truncate (p-price-sale-doc, 0) + 0.99
      .
    end.
    else do:
      assign
        p-price-sale-doc = truncate (p-price-sale-doc / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      p-price-sale-doc = round (p-price-sale-doc, 0)
    .
  end.
  when 'Произвольно':U then do:
    if p-round-base <> 0 then do:
      assign
        p-price-sale-doc = round (p-price-sale-doc / p-round-base, 0) * p-round-base
      .
      if p-price-sale-doc = 0 then do:
        assign
          p-price-sale-doc = p-round-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if p-round-base <> 0 then do:
      if truncate ( p-price-sale-doc / p-round-base, 0 ) <> (p-price-sale-doc / p-round-base) then do:
        assign
          p-price-sale-doc = truncate (p-price-sale-doc / p-round-base, 0) * p-round-base + p-round-base
        .
      end.
    end.
    if p-price-sale-doc = 0 then do:
      assign
        p-price-sale-doc = p-round-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if p-round-base <> 0 then do:
      assign
        p-price-sale-doc = p-price-sale-doc * p-round-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" p-round-method skip
      "round-base"   p-round-base   skip
      "price"        p-price-sale-doc             skip
      view-as alert-box error .
  end.
end.
  end.
  assign
    p-price-calc-rubl = p-price-calc-doc * p-exch-rate / p-exch-scale
    p-price-sale-rubl = p-price-sale-doc * p-exch-rate / p-exch-scale
    p-road-tax-rubl   = p-road-tax-doc   * p-exch-rate / p-exch-scale
    p-price-prev-rubl = p-price-prev-doc * p-exch-rate / p-exch-scale
   .
  assign
    p-price-calc-base = p-price-calc-rubl / p-base-rate * p-base-scale
    p-price-sale-base = p-price-sale-rubl / p-base-rate * p-base-scale
    p-road-tax-base   = p-road-tax-rubl   / p-base-rate * p-base-scale
    p-price-prev-base = p-price-prev-rubl / p-base-rate * p-base-scale
  .
  define buffer bufold_price-doc-forming for ub.price-doc-forming  .
  find first bufold_price-doc-forming where  recid(bufold_price-doc-forming) = v1-recid no-lock no-error .
  p-prev-doc-code = if available bufold_price-doc-forming
                       then (string(bufold_price-doc-forming.pdf-id) + " БД" + string(bufold_price-doc-forming.pdf-db))
                       else "" .
END PROCEDURE.
PROCEDURE create-line :
define input  parameter p-plt-db-num        like ub.price-doc-forming-gds.plt-db-num  no-undo .
define input  parameter p-plt-id            like ub.price-doc-forming-gds.plt-id      no-undo .
define input  parameter p-pdf-db            like ub.price-doc-forming-gds.pdf-db      no-undo .
define input  parameter p-pdf-id            like ub.price-doc-forming-gds.pdf-id  no-undo .
define input  parameter p-line-num          like ub.price-doc-forming-gds.line-num no-undo .
define input  parameter p-b-code            like ub.price-doc-forming-gds.b-code   no-undo .
define input  parameter p-artic             like ub.price-doc-forming-gds.artic    no-undo .
define input  parameter p-prod-type         like ub.price-doc-forming-gds.prod-type no-undo .
define input  parameter p-prod-code         like ub.price-doc-forming-gds.prod-code no-undo .
define input  parameter p-calc-method       like ub.price-doc-forming-gds.calc-method  no-undo .
define input  parameter p-d-pcnt            like ub.price-doc-forming-gds.d-pcnt       no-undo .
define input  parameter p-have-start-period like ub.price-doc-forming-gds.have-start-period no-undo .
define input  parameter p-start-date        like ub.price-doc-forming-gds.start-date        no-undo .
define input  parameter p-start-shift-date  like ub.price-doc-forming-gds.start-shift-date  no-undo .
define input  parameter p-start-shift-name  like ub.price-doc-forming-gds.start-shift-name  no-undo .
define input  parameter p-start-shift-num   like ub.price-doc-forming-gds.start-shift-num   no-undo .
define input  parameter p-start-sys-date    like ub.price-doc-forming-gds.start-sys-date    no-undo .
define input  parameter p-start-sys-time    like ub.price-doc-forming-gds.start-sys-time    no-undo .
define input  parameter p-have-end-period   like ub.price-doc-forming-gds.have-end-period   no-undo .
define input  parameter p-end-date          like ub.price-doc-forming-gds.end-date          no-undo .
define input  parameter p-end-shift-date    like ub.price-doc-forming-gds.end-shift-date    no-undo .
define input  parameter p-end-shift-name    like ub.price-doc-forming-gds.end-shift-name    no-undo .
define input  parameter p-end-shift-num     like ub.price-doc-forming-gds.end-shift-num     no-undo .
define input  parameter p-end-sys-date      like ub.price-doc-forming-gds.end-sys-date      no-undo .
define input  parameter p-end-sys-time      like ub.price-doc-forming-gds.end-sys-time      no-undo .
define input  parameter p-price-calc-base   like ub.price-doc-forming-gds.price-calc-base   no-undo .
define input  parameter p-price-calc-doc    like ub.price-doc-forming-gds.price-calc-doc    no-undo .
define input  parameter p-price-calc-rubl   like ub.price-doc-forming-gds.price-calc-rubl   no-undo .
define input  parameter p-price-prev-base   like ub.price-doc-forming-gds.price-prev-base   no-undo .
define input  parameter p-price-prev-doc    like ub.price-doc-forming-gds.price-prev-doc    no-undo .
define input  parameter p-price-prev-rubl   like ub.price-doc-forming-gds.price-prev-rubl   no-undo .
define input  parameter p-price-sale-base   like ub.price-doc-forming-gds.price-sale-base   no-undo .
define input  parameter p-price-sale-doc    like ub.price-doc-forming-gds.price-sale-doc    no-undo .
define input  parameter p-price-sale-rubl   like ub.price-doc-forming-gds.price-sale-rubl   no-undo .
define input  parameter p-road-tax-base     like ub.price-doc-forming-gds.road-tax-base     no-undo .
define input  parameter p-road-tax-doc      like ub.price-doc-forming-gds.road-tax-doc      no-undo .
define input  parameter p-road-tax-rubl     like ub.price-doc-forming-gds.road-tax-rubl     no-undo .
define input  parameter p-excise-base       like ub.price-doc-forming-gds.excise-base       no-undo .
define input  parameter p-excise-doc        like ub.price-doc-forming-gds.excise-doc        no-undo .
define input  parameter p-excise-rubl       like ub.price-doc-forming-gds.excise-rubl       no-undo .
define input  parameter p-vat-pc            like ub.price-doc-forming-gds.vat-pc            no-undo .
define input  parameter p-slt-pc            like ub.price-doc-forming-gds.slt-pc            no-undo .
define input  parameter p-prev-doc-code     as character no-undo .
define input  parameter p-stts              like ub.price-doc-forming-gds.stts              no-undo .
define input-output parameter  v-sec        as integer   no-undo .
  run check-use-bar-code ( p-b-code ) no-error .
  if error-status :error then do:
    message
      return-value skip
      "Ошибка !"
      view-as alert-box error
    .
    undo, return error return-value.
  end.
find first ub.price-doc-forming-gds exclusive-lock where
           ub.price-doc-forming-gds.plt-db-num  =  p-plt-db-num and
           ub.price-doc-forming-gds.plt-id      =  p-plt-id     and
           ub.price-doc-forming-gds.pdf-db      =  p-pdf-db     and
           ub.price-doc-forming-gds.pdf-id      =  p-pdf-id     and
           ub.price-doc-forming-gds.b-code      =  p-b-code     no-error .
    if not available ub.price-doc-forming-gds then
    do:
      create ub.price-doc-forming-gds .
       assign
        ub.price-doc-forming-gds.plt-db-num = p-plt-db-num
        ub.price-doc-forming-gds.plt-id     = p-plt-id
        ub.price-doc-forming-gds.pdf-db     = p-pdf-db
        ub.price-doc-forming-gds.pdf-id     = p-pdf-id
        ub.price-doc-forming-gds.b-code     = p-b-code
        ub.price-doc-forming-gds.line-num   = p-line-num
       .
    end.
  assign
    ub.price-doc-forming-gds.artic            = p-artic
    ub.price-doc-forming-gds.prod-type        = p-prod-type
    ub.price-doc-forming-gds.prod-code        = p-prod-code
    ub.price-doc-forming-gds.calc-method      = p-calc-method
    ub.price-doc-forming-gds.d-pcnt            = p-d-pcnt
    ub.price-doc-forming-gds.have-start-period = p-have-start-period
    ub.price-doc-forming-gds.start-date       = p-start-date
    ub.price-doc-forming-gds.start-shift-date = p-start-shift-date
    ub.price-doc-forming-gds.start-shift-name = p-start-shift-name
    ub.price-doc-forming-gds.start-shift-num  = p-start-shift-num
    ub.price-doc-forming-gds.start-sys-date   = p-start-sys-date
    ub.price-doc-forming-gds.start-sys-time   = p-start-sys-time
    ub.price-doc-forming-gds.have-end-period  = p-have-end-period
    ub.price-doc-forming-gds.end-date         = p-end-date
    ub.price-doc-forming-gds.end-shift-date   = p-end-shift-date
    ub.price-doc-forming-gds.end-shift-name   = p-end-shift-name
    ub.price-doc-forming-gds.end-shift-num    = p-end-shift-num
    ub.price-doc-forming-gds.end-sys-date     = p-end-sys-date
    ub.price-doc-forming-gds.end-sys-time     = p-end-sys-time
    ub.price-doc-forming-gds.price-calc-base  = p-price-calc-base
    ub.price-doc-forming-gds.price-calc-doc   = p-price-calc-doc
    ub.price-doc-forming-gds.price-calc-rubl  = p-price-calc-rubl
    ub.price-doc-forming-gds.price-prev-base  = p-price-prev-base
    ub.price-doc-forming-gds.price-prev-doc   = p-price-prev-doc
    ub.price-doc-forming-gds.price-prev-rubl  = p-price-prev-rubl
    ub.price-doc-forming-gds.road-tax-base    = p-road-tax-base
    ub.price-doc-forming-gds.road-tax-doc     = p-road-tax-doc
    ub.price-doc-forming-gds.road-tax-rubl    = p-road-tax-rubl
    ub.price-doc-forming-gds.excise-base      = p-excise-base
    ub.price-doc-forming-gds.excise-doc       = p-excise-doc
    ub.price-doc-forming-gds.excise-rubl      = p-excise-rubl
    ub.price-doc-forming-gds.vat-pc           = p-vat-pc
    ub.price-doc-forming-gds.slt-pc           = p-slt-pc
    ub.price-doc-forming-gds.prev-doc-code    = p-prev-doc-code
    ub.price-doc-forming-gds.stts             = p-stts
    ub.price-doc-forming-gds.price-sale-base  = p-price-sale-base
    ub.price-doc-forming-gds.price-sale-doc   = p-price-sale-doc
    ub.price-doc-forming-gds.price-sale-rubl  = p-price-sale-rubl
    .
  run ref/h-pdfgds.p
    ( buffer ub.price-doc-forming-gds ,
      input p-price-sale-doc ,
      input-output v-sec
      ) .
END PROCEDURE.
PROCEDURE last-num :
define input  parameter p-recid as recid no-undo .
define output parameter p-last-id as integer   no-undo .
define buffer buf2_price-doc-forming     for ub.price-doc-forming  .
define buffer buf2_price-doc-forming-gds for ub.price-doc-forming-gds  .
find first buf2_price-doc-forming no-lock where recid(buf2_price-doc-forming) = p-recid no-error .
      if error-status :error then do:
        p-last-id = ? .
        return .
      end.
    for each buf2_price-doc-forming-gds no-lock  where
            buf2_price-doc-forming-gds.plt-id     = buf2_price-doc-forming.plt-id     and
            buf2_price-doc-forming-gds.plt-db-num = buf2_price-doc-forming.plt-db-num and
            buf2_price-doc-forming-gds.pdf-id     = buf2_price-doc-forming.pdf-id     and
            buf2_price-doc-forming-gds.pdf-db     = buf2_price-doc-forming.pdf-db
            by buf2_price-doc-forming-gds.line-num
            :
            p-last-id = buf2_price-doc-forming-gds.line-num .
    end.
END PROCEDURE.
PROCEDURE calc-price-alt :
define input parameter bc         like ub.bar-code.b-code   no-undo.
define input parameter p-recid as recid no-undo .
define input parameter d-pcnt as decimal   no-undo .
define input parameter r-method   as character no-undo .
define input parameter r-base     as decimal   no-undo .
define output parameter pa-price-sale-base  as decimal   no-undo .
define output parameter pa-price-sale-doc   as decimal   no-undo .
define output parameter pa-price-sale-rubl  as decimal   no-undo .
pr-alt:
do on error undo pr-alt, return error:
  if r-method = ? or
     r-base = ? then do:
    message
      "Не задан способ округления для расчета зависящих от нее неосновных цен." skip
      "Код:" bc skip
      view-as alert-box error.
    undo pr-alt, return error.
  end.
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_main_bar-code for ub.bar-code  .
define buffer buf_main_price-doc-forming for ub.price-doc-forming  .
define buffer buf_main_price-doc-forming-gds for ub.price-doc-forming-gds  .
find first buf_main_price-doc-forming no-lock where recid(buf_main_price-doc-forming) = p-recid  no-error .
if error-status :error then
message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка "
  view-as alert-box error
.
find first buf_bar-code no-lock where
           buf_bar-code.b-code = bc no-error .
if error-status :error then
message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "3"
  view-as alert-box error
.
      assign
        pa-price-sale-doc = fnc-base-price-doc ( input bc , input p-recid ) *
                            buf_bar-code.cli-base-rate *
                            (1 - d-pcnt / 100)
                              .
  if pa-price-sale-doc <> 0 then do:
case r-method :
  when '9-окончание':U then do:
    if pa-price-sale-doc < 29 then do:
      if (pa-price-sale-doc - truncate (pa-price-sale-doc, 0)) <> 0 then do:
        assign
          pa-price-sale-doc = truncate (pa-price-sale-doc, 0) + 1
        .
      end.
    end.
    else do:
      if (pa-price-sale-doc modulo 10) < 3 then do:
        assign
          pa-price-sale-doc = (pa-price-sale-doc - (pa-price-sale-doc modulo 100))
              + ( truncate (((pa-price-sale-doc modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          pa-price-sale-doc = (pa-price-sale-doc - (pa-price-sale-doc modulo 100))
              + ( truncate (((pa-price-sale-doc modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        pa-price-sale-doc = round (pa-price-sale-doc, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if pa-price-sale-doc < r-base then do:
      assign
        pa-price-sale-doc = truncate (pa-price-sale-doc, 0) + 0.99
      .
    end.
    else do:
      assign
        pa-price-sale-doc = truncate (pa-price-sale-doc / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      pa-price-sale-doc = round (pa-price-sale-doc, 0)
    .
  end.
  when 'Произвольно':U then do:
    if r-base <> 0 then do:
      assign
        pa-price-sale-doc = round (pa-price-sale-doc / r-base, 0) * r-base
      .
      if pa-price-sale-doc = 0 then do:
        assign
          pa-price-sale-doc = r-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if r-base <> 0 then do:
      if truncate ( pa-price-sale-doc / r-base, 0 ) <> (pa-price-sale-doc / r-base) then do:
        assign
          pa-price-sale-doc = truncate (pa-price-sale-doc / r-base, 0) * r-base + r-base
        .
      end.
    end.
    if pa-price-sale-doc = 0 then do:
      assign
        pa-price-sale-doc = r-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if r-base <> 0 then do:
      assign
        pa-price-sale-doc = pa-price-sale-doc * r-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" r-method skip
      "round-base"   r-base   skip
      "price"        pa-price-sale-doc             skip
      view-as alert-box error .
  end.
end.
  end.
  pa-price-sale-rubl = pa-price-sale-doc * buf_main_price-doc-forming.exch-rate / buf_main_price-doc-forming.exch-scale .
  pa-price-sale-base = pa-price-sale-rubl / buf_main_price-doc-forming.base-rate * buf_main_price-doc-forming.base-scale .
end.
END PROCEDURE.
procedure calc-price-discnt :
  do
  on error undo, return error return-value
  :
define input parameter p-recid as recid no-undo .
define input parameter bc    like ub.bar-code.b-code   no-undo.
define buffer buf-price-doc-forming             for ub.price-doc-forming.
define buffer buf-price-doc-forming-gds for ub.price-doc-forming-gds.
define buffer buf-bar-code                      for ub.bar-code.
define buffer buf-goods                         for ub.goods.
define buffer old-price-doc-forming-gds         for ub.price-doc-forming-gds.
define variable pr-rec   as   recid                     no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
pr-discnt:
do on error undo pr-discnt, return error:
  find  buf-price-doc-forming no-lock where
        recid(buf-price-doc-forming) = p-recid .
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-doc-forming-gds exclusive-lock where
        buf-price-doc-forming-gds.pdf-id = buf-price-doc-forming.pdf-id and
        buf-price-doc-forming-gds.plt-id = buf-price-doc-forming.plt-id and
        buf-price-doc-forming-gds.pdf-db     = buf-price-doc-forming.pdf-db and
        buf-price-doc-forming-gds.plt-db-num = buf-price-doc-forming.plt-db-num and
        buf-price-doc-forming-gds.b-code  = bc.
   if available buf-price-doc-forming-gds then do:
      buf-price-doc-forming-gds.d-pcnt =
      (1 - buf-price-doc-forming-gds.price-sale-doc /
            fnc-base-price-doc ( buf-bar-code.b-code, p-recid ) /
            buf-bar-code.cli-base-rate) * 100 .
   end.
end.
  end.
end procedure.
procedure calc-price-sub :
define  input  parameter bc           like ub.price-doc-forming-gds.b-code no-undo.
define  input  parameter p-recid      as recid no-undo .
define  input  parameter calc-method  as character         no-undo.
define  input  parameter increase-pc  as decimal           no-undo.
define  input  parameter round-method as character         no-undo.
define  input  parameter round-base   as decimal           no-undo.
define  input  parameter doc-code     as character no-undo .
define  input  parameter common-price as decimal   no-undo .
define  input  parameter copy-type    as character no-undo .
define  input  parameter copy-code    as integer   no-undo .
define  output parameter calc-rec     as recid             no-undo.
define  buffer buf-price-doc-forming-gds for ub.price-doc-forming-gds.
define  buffer buf-bar-code              for ub.bar-code.
define  buffer buf-goods                 for ub.goods.
define  buffer buf-gds-prt               for ub.gds-prt.
define  buffer buf-gds-grp               for ub.gds-grp.
define  buffer buf-price-doc-forming     for ub.price-doc-forming.
calc-sub:
do on error undo calc-sub, return error:
  find  buf-price-doc-forming no-lock where
        recid (buf-price-doc-forming) =  p-recid .
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-doc-forming-gds where
        buf-price-doc-forming-gds.pdf-id    = buf-price-doc-forming.pdf-id and
        buf-price-doc-forming-gds.plt-id    = buf-price-doc-forming.plt-id and
        buf-price-doc-forming-gds.pdf-db    = buf-price-doc-forming.pdf-db and
        buf-price-doc-forming-gds.plt-db-num  = buf-price-doc-forming.plt-db-num and
        buf-price-doc-forming-gds.b-code      = bc no-error .
  calc-rec = recid (buf-price-doc-forming-gds).
  if buf-gds-prt.upper-code = buf-goods.prt-root and  buf-goods.unit-base = buf-bar-code.unit-cli  then do:
    for each  buf-price-doc-forming-gds exclusive-lock where
              buf-price-doc-forming-gds.pdf-id    = buf-price-doc-forming.pdf-id and
              buf-price-doc-forming-gds.plt-id    = buf-price-doc-forming.plt-id and
              buf-price-doc-forming-gds.pdf-db    = buf-price-doc-forming.pdf-db and
              buf-price-doc-forming-gds.plt-db-num    = buf-price-doc-forming.plt-db-num and
              buf-price-doc-forming-gds.artic      = buf-goods.artic and
              buf-price-doc-forming-gds.prod-type  = buf-goods.prod-type and
              buf-price-doc-forming-gds.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code   = buf-price-doc-forming-gds.b-code and
              buf-bar-code.unit-cli = buf-goods.unit-base ,
        first buf-gds-prt no-lock where
              buf-gds-prt.node-code = buf-bar-code.node-code and
              buf-gds-prt.upper-code <> buf-goods.prt-root
        on error undo calc-sub, return error:
          run calc-price-line  in this-procedure
            ( input  calc-method
            , input  increase-pc
            , input  round-method
            , input  round-base
            , input  buf-bar-code.b-code
            , input  buf-goods.gds-code
            , input  buf-goods.artic
            , input  buf-goods.prod-type
            , input  buf-goods.prod-code
            , input  buf-price-doc-forming.base-rate
            , input  buf-price-doc-forming.base-scale
            , input  buf-price-doc-forming.exch-scale
            , input  buf-price-doc-forming.exch-rate
            , input  doc-code
            , input  common-price
            , input  copy-type
            , input  copy-code
            , output buf-price-doc-forming-gds.calc-method
            , output buf-price-doc-forming-gds.price-calc-base
            , output buf-price-doc-forming-gds.price-calc-doc
            , output buf-price-doc-forming-gds.price-calc-rubl
            , output buf-price-doc-forming-gds.price-prev-base
            , output buf-price-doc-forming-gds.price-prev-doc
            , output buf-price-doc-forming-gds.price-prev-rubl
            , output buf-price-doc-forming-gds.price-sale-base
            , output buf-price-doc-forming-gds.price-sale-doc
            , output buf-price-doc-forming-gds.price-sale-rubl
            , output buf-price-doc-forming-gds.road-tax-base
            , output buf-price-doc-forming-gds.road-tax-doc
            , output buf-price-doc-forming-gds.road-tax-rubl
            , output buf-price-doc-forming-gds.excise-base
            , output buf-price-doc-forming-gds.excise-doc
            , output buf-price-doc-forming-gds.excise-rubl
            , output buf-price-doc-forming-gds.vat-pc
            , output buf-price-doc-forming-gds.slt-pc
            , output buf-price-doc-forming-gds.prev-doc-code
            , output buf-price-doc-forming-gds.d-pcnt
            ) no-error .
          if error-status :error then do :
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              "calc-price-line"
              view-as alert-box error
            .
            undo calc-sub, return error.
            end.
      calc-rec = recid (buf-price-doc-forming-gds).
    end.
    for each  buf-price-doc-forming-gds exclusive-lock where
              buf-price-doc-forming-gds.pdf-id    = buf-price-doc-forming.pdf-id and
              buf-price-doc-forming-gds.plt-id    = buf-price-doc-forming.plt-id and
              buf-price-doc-forming-gds.pdf-db    = buf-price-doc-forming.pdf-db and
              buf-price-doc-forming-gds.plt-db-num    = buf-price-doc-forming.plt-db-num and
              buf-price-doc-forming-gds.artic      = buf-goods.artic and
              buf-price-doc-forming-gds.prod-type  = buf-goods.prod-type and
              buf-price-doc-forming-gds.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code    = buf-price-doc-forming-gds.b-code and
              buf-bar-code.unit-cli <> buf-goods.unit-base ,
        first buf-gds-prt no-lock where
              buf-gds-prt.node-code = buf-bar-code.node-code
        on error undo calc-sub, return error:
    end.
  end.
  else do:
  end.
end.
end procedure.
procedure calc-base-update :
define input parameter bc           like ub.bar-code.b-code   no-undo.
define input parameter p-recid      as recid no-undo .
define input parameter round-method as character    no-undo.
define input parameter round-base   as decimal      no-undo.
define buffer alt-bar-code              for ub.bar-code.
define buffer alt-price-doc-forming-gds for ub.price-doc-forming-gds.
define buffer buf-bar-code              for ub.bar-code.
define buffer buf-goods                 for ub.goods.
define buffer buf-price-doc-forming     for ub.price-doc-forming  .
calc-base:
do on error undo calc-base, return error :
  find  buf-price-doc-forming no-lock where
        recid (buf-price-doc-forming) =  p-recid .
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  for each  alt-bar-code no-lock where
            alt-bar-code.gds-code  = buf-bar-code.gds-code and
            alt-bar-code.node-code = buf-bar-code.node-code and
            alt-bar-code.part-code = buf-bar-code.part-code and
            alt-bar-code.in-code   = buf-bar-code.in-code and
            alt-bar-code.unit-cli <> buf-goods.unit-base,
      each  alt-price-doc-forming-gds exclusive-lock where
            alt-price-doc-forming-gds.pdf-id      = buf-price-doc-forming.pdf-id and
            alt-price-doc-forming-gds.plt-id      = buf-price-doc-forming.plt-id and
            alt-price-doc-forming-gds.pdf-db      = buf-price-doc-forming.pdf-db and
            alt-price-doc-forming-gds.plt-db-num  = buf-price-doc-forming.plt-db-num and
            alt-price-doc-forming-gds.b-code      = alt-bar-code.b-code
      on error undo calc-base, return error:
  run calc-price-alt in this-procedure
      ( input  alt-price-doc-forming-gds.b-code
      , input  p-recid
      , input  alt-price-doc-forming-gds.d-pcnt
      , input  round-method
      , input  round-base
      , output alt-price-doc-forming-gds.price-sale-base
      , output alt-price-doc-forming-gds.price-sale-doc
      , output alt-price-doc-forming-gds.price-sale-rubl
      ) no-error .
    if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "calc-price-alt"
      view-as alert-box error
    .
      undo calc-base, return error.
    end.
  end.
end.
end procedure.
define temp-table temp-exp-partbc no-undo
field b-code  as integer
index pi b-code
.
procedure expose-prt :
define input  parameter p-calc-method  as character no-undo .
define input  parameter p-increase-pc as decimal   no-undo .
define input  parameter p-main-code    like ub.goods.gds-code    no-undo.
define input  parameter old-recid      as recid no-undo .
define input  parameter new-recid      as recid no-undo .
define input  parameter p-round-method as character no-undo .
define input  parameter p-round-base   as decimal   no-undo .
define input  parameter v-doc-code     as character no-undo .
define input  parameter v-common-price as decimal   no-undo .
define input  parameter v-copy-type    as character no-undo .
define input  parameter v-copy-code    as integer   no-undo .
define input-output parameter v-line-num as integer   no-undo .
define input-output parameter v-sec      as integer   no-undo .
define output parameter new-rec-str      as recid   no-undo.
define buffer buf-bar-code              for ub.bar-code.
define buffer buf-goods                 for ub.goods.
define buffer buf-price-doc-forming-gds for ub.price-doc-forming-gds.
define buffer buf-price-list            for ub.price-doc-forming-gds.
define buffer buf-price-doc-forming     for ub.price-doc-forming.
define buffer new-price-doc-forming     for ub.price-doc-forming.
define buffer new-price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf-gds-prt               for ub.gds-prt  .
define buffer buf_parts for ub.parts  .
define buffer buf_goods for ub.goods  .
  do
  on error undo, return error return-value
  :
  find  buf-price-doc-forming no-lock where
        recid(buf-price-doc-forming) = old-recid .
  find  new-price-doc-forming no-lock where
        recid(new-price-doc-forming) = new-recid .
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = p-main-code.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-doc-forming-gds no-lock  where
        buf-price-doc-forming-gds.pdf-id = buf-price-doc-forming.pdf-id and
        buf-price-doc-forming-gds.plt-id = buf-price-doc-forming.plt-id and
        buf-price-doc-forming-gds.pdf-db     = buf-price-doc-forming.pdf-db and
        buf-price-doc-forming-gds.plt-db-num = buf-price-doc-forming.plt-db-num and
        buf-price-doc-forming-gds.b-code  = p-main-code no-error .
  if error-status :error then return .
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
if par-pr-altex = "yes" and
   par-pr-notls = "yes" then do:
for each  buf-price-list where
          buf-price-list.pdf-id = buf-price-doc-forming.pdf-id and
          buf-price-list.plt-id = buf-price-doc-forming.plt-id and
          buf-price-list.pdf-db     = buf-price-doc-forming.pdf-db and
          buf-price-list.plt-db-num = buf-price-doc-forming.plt-db-num and
          buf-price-list.b-code     <> p-main-code and
          buf-price-list.artic       = buf-goods.artic  and
          buf-price-list.prod-type   = buf-goods.prod-type and
          buf-price-list.prod-code   = buf-goods.prod-code
          ,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.unit-cli <> buf-goods.unit-base:
   run create-calc-bc in this-procedure
       ( input  recid( new-price-doc-forming )
        ,input  p-calc-method
        ,input  p-increase-pc
        ,input  p-round-method
        ,input  p-round-base
        ,input  buf-bar-code.b-code
        ,input  buf-goods.gds-code
        ,input  buf-goods.artic
        ,input  buf-goods.prod-type
        ,input  buf-goods.prod-code
        ,input  new-price-doc-forming.base-rate
        ,input  new-price-doc-forming.base-scale
        ,input  new-price-doc-forming.exch-scale
        ,input  new-price-doc-forming.exch-rate
        ,input  v-doc-code
        ,input  v-common-price
        ,input  v-copy-type
        ,input  v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .
  if error-status:error then do:
    message
      "Ошибка cre-pr-list."                skip
      "Код:" buf-bar-code.b-code           skip
      error-status :get-message(1)         skip
      return-value                         skip
       "pdf" new-price-doc-forming.pdf-id  skip
      view-as alert-box.
    next.
  end.
end.
end.
if par-pr-sclex = "yes" and
   par-pr-notls = "yes" then do:
for each  buf-price-list where
          buf-price-list.pdf-id = buf-price-doc-forming.pdf-id and
          buf-price-list.plt-id = buf-price-doc-forming.plt-id and
          buf-price-list.pdf-db     = buf-price-doc-forming.pdf-db and
          buf-price-list.plt-db-num = buf-price-doc-forming.plt-db-num and
          buf-price-list.b-code     <> p-main-code and
          buf-price-list.artic       = buf-goods.artic  and
          buf-price-list.prod-type   = buf-goods.prod-type and
          buf-price-list.prod-code   = buf-goods.prod-code  ,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.unit-cli = buf-goods.unit-base and
          buf-bar-code.in-code = ""
          :
   run create-calc-bc in this-procedure
       ( input  recid( new-price-doc-forming )
        ,input  p-calc-method
        ,input  p-increase-pc
        ,input  p-round-method
        ,input  p-round-base
        ,input  buf-bar-code.b-code
        ,input  buf-goods.gds-code
        ,input  buf-goods.artic
        ,input  buf-goods.prod-type
        ,input  buf-goods.prod-code
        ,input  new-price-doc-forming.base-rate
        ,input  new-price-doc-forming.base-scale
        ,input  new-price-doc-forming.exch-scale
        ,input  new-price-doc-forming.exch-rate
        ,input v-doc-code
        ,input v-common-price
        ,input v-copy-type
        ,input v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .
      if error-status:error then do:
        message
          "Ошибка cre-pr-list.2" skip
          "Код:" buf-bar-code.b-code
          view-as alert-box.
        next.
      end.
    end.
end.
if par-pr-parex = "yes" and
   par-pr-notls = "yes" then do:
define buffer bt_trn-doc  for ub.trn-doc  .
define buffer bf_parts    for ub.parts  .
define buffer free_parts  for ub.parts  .
define buffer buf_gds-obj for ub.gds-obj  .
find first buf_gds-obj no-lock where
           buf_gds-obj.gds-code = buf-goods.gds-code and
           buf_gds-obj.obj-type = v-cntxt-obj-type   and
           buf_gds-obj.obj-code = v-cntxt-obj-code   and
           buf_gds-obj.cash-parts = true
           no-error .
if not available buf_gds-obj then return .
 find first bt_trn-doc no-lock where
            bt_trn-doc.doc-code = v-doc-code no-error .
 if v-doc-code <> "" and available bt_trn-doc then do:
 for each temp-exp-partbc :
     delete temp-exp-partbc.
 end.
 for each bf_parts no-lock where
          bf_parts.out-code   = bt_trn-doc.doc-code and
          bf_parts.obj-type   = bt_trn-doc.obj-type and
          bf_parts.obj-code   = bt_trn-doc.obj-code and
          bf_parts.artic      = buf-goods.artic     and
          bf_parts.prod-type  = buf-goods.prod-type and
          bf_parts.prod-code  = buf-goods.prod-code  ,
        first free_parts no-lock where
              free_parts.in-code   = bf_parts.in-code   and
              free_parts.part-code = bf_parts.part-code and
              free_parts.out-code  = 'free-zone':U       and
              free_parts.rsrv-free = true               and
              free_parts.status_   = false              and
              free_parts.obj-type  = bf_parts.obj-type  and
              free_parts.obj-code  = bf_parts.obj-code  and
              free_parts.artic     = bf_parts.artic     and
              free_parts.prod-type = bf_parts.prod-type and
              free_parts.prod-code = bf_parts.prod-code ,
        first buf-bar-code no-lock where
              buf-bar-code.gds-code  = buf-goods.gds-code and
              buf-bar-code.unit-cli  = buf-goods.unit-base and
              buf-bar-code.in-code   = bf_parts.in-code and
              buf-bar-code.part-code = bf_parts.part-code
              :
   run create-calc-bc in this-procedure
       ( input  recid( new-price-doc-forming )
        ,input  p-calc-method
        ,input  p-increase-pc
        ,input  p-round-method
        ,input  p-round-base
        ,input  buf-bar-code.b-code
        ,input  buf-goods.gds-code
        ,input  buf-goods.artic
        ,input  buf-goods.prod-type
        ,input  buf-goods.prod-code
        ,input  new-price-doc-forming.base-rate
        ,input  new-price-doc-forming.base-scale
        ,input  new-price-doc-forming.exch-scale
        ,input  new-price-doc-forming.exch-rate
        ,input v-doc-code
        ,input v-common-price
        ,input v-copy-type
        ,input v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .
      if error-status:error then do:
        message
          "Ошибка cre-pr-list.3-" skip
          "Код:" buf-bar-code.b-code
          view-as alert-box.
        next.
      end.
      create temp-exp-partbc.
      assign
         temp-exp-partbc.b-code = buf-bar-code.b-code
      .
 end.
end.
for each  buf-price-list where
          buf-price-list.pdf-id     = buf-price-doc-forming.pdf-id and
          buf-price-list.plt-id     = buf-price-doc-forming.plt-id and
          buf-price-list.pdf-db     = buf-price-doc-forming.pdf-db and
          buf-price-list.plt-db-num = buf-price-doc-forming.plt-db-num and
          buf-price-list.b-code     <> p-main-code         and
          buf-price-list.artic       = buf-goods.artic     and
          buf-price-list.prod-type   = buf-goods.prod-type and
          buf-price-list.prod-code   = buf-goods.prod-code ,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.unit-cli = buf-goods.unit-base and
          buf-bar-code.in-code <> "" ,
    first buf_parts no-lock where
          buf_parts.out-code    = 'free-zone':U and
          buf_parts.rsrv-free   = true  and
          buf_parts.status_     = false and
          buf_parts.artic       = buf-goods.artic and
          buf_parts.prod-type   = buf-goods.prod-type and
          buf_parts.prod-code   = buf-goods.prod-code and
          buf_parts.obj-type   = v-cntxt-obj-type and
          buf_parts.obj-code   = v-cntxt-obj-code and
          buf_parts.part-code   = buf-bar-code.part-code and
          buf_parts.in-code     = buf-bar-code.in-code
          :
          find first temp-exp-partbc where
                     temp-exp-partbc.b-code = buf-bar-code.b-code no-error .
        if available temp-exp-partbc then next.
   run create-calc-bc in this-procedure
       ( input  recid( new-price-doc-forming )
        ,input  'Старая':U
        ,input  0
        ,input  'Отключено':U
        ,input  0
        ,input  buf-bar-code.b-code
        ,input  buf-goods.gds-code
        ,input  buf-goods.artic
        ,input  buf-goods.prod-type
        ,input  buf-goods.prod-code
        ,input  new-price-doc-forming.base-rate
        ,input  new-price-doc-forming.base-scale
        ,input  new-price-doc-forming.exch-scale
        ,input  new-price-doc-forming.exch-rate
        ,input v-doc-code
        ,input v-common-price
        ,input v-copy-type
        ,input v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .
      if error-status:error then do:
        message
          "Ошибка cre-pr-list.3" skip
          "Код:" buf-bar-code.b-code
          view-as alert-box.
        next.
      end.
    end.
  for each buf_parts no-lock where
          buf_parts.out-code    = 'free-zone':U and
          buf_parts.rsrv-free   = true  and
          buf_parts.status_     = false and
          buf_parts.artic       = buf-goods.artic and
          buf_parts.prod-type   = buf-goods.prod-type and
          buf_parts.prod-code   = buf-goods.prod-code and
          buf_parts.obj-type    = v-cntxt-obj-type and
          buf_parts.obj-code    = v-cntxt-obj-code and
          buf_parts.part-code   = buf-bar-code.part-code and
          buf_parts.in-code     = buf-bar-code.in-code,
        first buf-bar-code no-lock where
              buf-bar-code.gds-code  = buf-goods.gds-code and
              buf-bar-code.unit-cli  = buf-goods.unit-base and
              buf-bar-code.in-code   = buf_parts.in-code and
              buf-bar-code.part-code = buf_parts.part-code
          :
          find first temp-exp-partbc where
                     temp-exp-partbc.b-code = buf-bar-code.b-code no-error .
        if available temp-exp-partbc then next.
          find first new-price-doc-forming-gds where
                     new-price-doc-forming-gds.pdf-id     = new-price-doc-forming.pdf-id and
                     new-price-doc-forming-gds.pdf-db     = new-price-doc-forming.pdf-db and
                     new-price-doc-forming-gds.plt-id     = new-price-doc-forming.plt-id and
                     new-price-doc-forming-gds.plt-db-num = new-price-doc-forming.plt-db-num  and
                     new-price-doc-forming-gds.b-code = buf-bar-code.b-code
                     no-error .
        if available new-price-doc-forming-gds then next.
   run create-calc-bc in this-procedure
       ( input recid( new-price-doc-forming )
        ,input 'Старая':U
        ,input 0
        ,input 'Отключено':U
        ,input 0
        ,input buf-bar-code.b-code
        ,input buf-goods.gds-code
        ,input buf-goods.artic
        ,input buf-goods.prod-type
        ,input buf-goods.prod-code
        ,input new-price-doc-forming.base-rate
        ,input new-price-doc-forming.base-scale
        ,input new-price-doc-forming.exch-scale
        ,input new-price-doc-forming.exch-rate
        ,input v-doc-code
        ,input v-common-price
        ,input v-copy-type
        ,input v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .
      if error-status:error then do:
        message
          "Ошибка cre-pr-list.4" skip
          "Код:" buf-bar-code.b-code
          view-as alert-box.
        next.
      end.
    end.
end.
  end.
end procedure.
procedure create-calc-bc :
define input parameter  v-new-recid as recid no-undo .
define input parameter  p-calc-method  as character no-undo .
define input parameter  p-increase-pc  as decimal   no-undo .
define input parameter  round-method as character no-undo .
define input parameter  round-base   as decimal   no-undo .
define input parameter  p-b-code     as integer   no-undo .
define input parameter  p-gds-code   as integer   no-undo .
define input parameter  p-artic      as character no-undo .
define input parameter  p-prod-type  as character no-undo .
define input parameter  p-prod-code  as integer   no-undo .
define input parameter  v-base-rate  as decimal   no-undo .
define input parameter  v-base-scale as decimal   no-undo .
define input parameter  v-exch-scale as decimal   no-undo .
define input parameter  v-exch-rate  as decimal   no-undo .
define input parameter  v-doc-code   as character no-undo .
define input parameter  v-common-price as decimal   no-undo .
define input parameter  v-copy-type as character no-undo .
define input parameter  v-copy-code as integer   no-undo .
define input-output parameter v-line-num as integer   no-undo .
define input-output parameter v-sec     as integer   no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define variable v-price-calc-base as decimal   no-undo .
define variable v-price-calc-doc  as decimal   no-undo .
define variable v-price-calc-rubl as decimal   no-undo .
define variable v-price-prev-base as decimal   no-undo .
define variable v-price-prev-doc  as decimal   no-undo .
define variable v-price-prev-rubl as decimal   no-undo .
define variable v-price-sale-base as decimal   no-undo .
define variable v-price-sale-doc  as decimal   no-undo .
define variable v-price-sale-rubl as decimal   no-undo .
define variable v-road-tax-base   as decimal   no-undo .
define variable v-road-tax-doc    as decimal   no-undo .
define variable v-road-tax-rubl   as decimal   no-undo .
define variable v-excise-base     as decimal   no-undo .
define variable v-excise-doc      as decimal   no-undo .
define variable v-excise-rubl     as decimal   no-undo .
define variable v-vat-pc          as decimal   no-undo .
define variable v-slt-pc          as decimal   no-undo .
define variable v-prev-doc-code   as character no-undo .
define variable v-d-pcnt as decimal   no-undo .
  do
  on error undo, return error return-value
  :
  find  buf_price-doc-forming no-lock where
        recid(buf_price-doc-forming) = v-new-recid no-error .
   if error-status :error then return error error-status :get-message(1) .
   v-line-num = v-line-num + 1.
   run calc-price-line  in this-procedure (
     input  p-calc-method
   , input  p-increase-pc
   , input  round-method
   , input  round-base
   , input  p-b-code
   , input  p-gds-code
   , input  p-artic
   , input  p-prod-type
   , input  p-prod-code
   , input  v-base-rate
   , input  v-base-scale
   , input  v-exch-scale
   , input  v-exch-rate
   , input  v-doc-code
   , input  v-common-price
   , input  v-copy-type
   , input  v-copy-code
   , output p-calc-method
   , output v-price-calc-base
   , output v-price-calc-doc
   , output v-price-calc-rubl
   , output v-price-prev-base
   , output v-price-prev-doc
   , output v-price-prev-rubl
   , output v-price-sale-base
   , output v-price-sale-doc
   , output v-price-sale-rubl
   , output v-road-tax-base
   , output v-road-tax-doc
   , output v-road-tax-rubl
   , output v-excise-base
   , output v-excise-doc
   , output v-excise-rubl
   , output v-vat-pc
   , output v-slt-pc
   , output v-prev-doc-code
   , output v-d-pcnt
   ) no-error .
   if error-status :error then
   message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "123calc-price-line"
     "p-calc-method     "  p-calc-method     skip
     "p-increase-pc     "  p-increase-pc     skip
     "round-method      "    round-method    skip
     "round-base        "    round-base      skip
     "p-b-code          "    p-b-code        skip
     "p-gds-code        "    p-gds-code      skip
     "p-artic           "    p-artic         skip
     "p-prod-type       "    p-prod-type     skip
     "p-prod-code       "    p-prod-code     skip
     "v-base-rate       "   v-base-rate     skip
     "v-base-scale      "  v-base-scale    skip
     "v-exch-scale      "  v-exch-scale    skip
     "v-exch-rate       "  v-exch-rate     skip
     "v-doc-code        "  v-doc-code      skip
     "v-common-price    "  v-common-price  skip
     "v-copy-type       "  v-copy-type     skip
     "v-copy-code       "  v-copy-code     skip
     "v-d-pcnt          "  v-d-pcnt
     view-as alert-box error
   .
   run create-line  in this-procedure (
     buf_price-doc-forming.plt-db-num
    ,buf_price-doc-forming.plt-id
    ,buf_price-doc-forming.pdf-db
    ,buf_price-doc-forming.pdf-id
    ,v-line-num
    ,p-b-code
    ,p-artic
    ,p-prod-type
    ,p-prod-code
    ,p-calc-method
    ,v-d-pcnt
    ,buf_price-doc-forming.have-start-period
    ,buf_price-doc-forming.start-date
    ,buf_price-doc-forming.start-shift-date
    ,buf_price-doc-forming.start-shift-name
    ,buf_price-doc-forming.start-shift-num
    ,buf_price-doc-forming.start-sys-date
    ,buf_price-doc-forming.start-sys-time
    ,buf_price-doc-forming.have-end-period
    ,buf_price-doc-forming.end-date
    ,buf_price-doc-forming.end-shift-date
    ,buf_price-doc-forming.end-shift-name
    ,buf_price-doc-forming.end-shift-num
    ,buf_price-doc-forming.end-sys-date
    ,buf_price-doc-forming.end-sys-time
    ,v-price-calc-base
    ,v-price-calc-doc
    ,v-price-calc-rubl
    ,v-price-prev-base
    ,v-price-prev-doc
    ,v-price-prev-rubl
    ,v-price-sale-base
    ,v-price-sale-doc
    ,v-price-sale-rubl
    ,v-road-tax-base
    ,v-road-tax-doc
    ,v-road-tax-rubl
    ,v-excise-base
    ,v-excise-doc
    ,v-excise-rubl
    ,v-vat-pc
    ,v-slt-pc
    ,v-prev-doc-code
    ,0
    ,input-output v-sec
     ) no-error  .
     if error-status :error then
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "4567"
       view-as alert-box error
     .
  end.
end procedure.
procedure re-define :
define input-output parameter p-calc-method      as character no-undo .
define input        parameter p-gds-code         as integer   no-undo .
  do
  on error undo, return error return-value
  :
define buffer buf_goods for ub.goods  .
define buffer buf_gds-grp for ub.gds-grp  .
    case p-calc-method :
      when 'Товар':U then do:
           find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
                case buf_goods.calc-method:
                  when 'Группа':U then do:
                    find first buf_gds-grp no-lock where
                               buf_gds-grp.node-code = buf_goods.grp-code no-error .
                    p-calc-method  = buf_gds-grp.calc-method.
                  end.
                otherwise do:
                    p-calc-method  =  buf_goods.calc-method .
                end.
                end case.
           run  re-define in this-procedure (
                      input-output  p-calc-method ,
                      input p-gds-code )  .
      end.
      when 'Группа':U then do:
           find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
           find first buf_gds-grp no-lock where
                      buf_gds-grp.node-code = buf_goods.grp-code no-error .
           run re-define in this-procedure (
                      input-output buf_gds-grp.calc-method ,
                      input p-gds-code )  .
      end.
      when 'Учетная':U or
      when 'Учет-объект':U then do:
           p-calc-method = 'УчетнаяS':U .
      end.
      when 'Учет-резерв':U then do:
           p-calc-method = 'Учет-рзрвS':U.
      end.
      when 'Приходная':U or
      when 'Прих-объект':U then do:
           p-calc-method = 'ПриходнаяS':U.
      end.
      when 'Учет-безНДС':U then do:
           p-calc-method = 'Учет-НДСS':U .
      end.
    end case.
  end.
end procedure.
procedure create-line-pdf-mpl-lib :
define input  parameter  p-plt-db-num as integer   no-undo .
define input  parameter  p-plt-id     as integer   no-undo .
define input  parameter  p-pdf-db     as integer   no-undo .
define input  parameter  p-pdf-id     as integer   no-undo .
define input  parameter  p-line-num   as integer   no-undo .
define input  parameter  p-b-code     as integer   no-undo .
define input  parameter  p-artic      as character no-undo .
define input  parameter  p-prod-type  as character no-undo .
define input  parameter  p-prod-code  as integer   no-undo .
define input  parameter  p-met    as character no-undo .
define input  parameter  p-d-pcnt as decimal   no-undo .
define input  parameter  p-price  as decimal   no-undo .
define input  parameter  p-out-code as character no-undo .
define input  parameter  p-stts as integer   no-undo .
define input-output  parameter v-sec   as integer   no-undo .
define variable v-price-calc-base  as decimal   no-undo .
define variable v-price-calc-doc   as decimal   no-undo .
define variable v-price-calc-rubl  as decimal   no-undo .
define variable v-price-prev-base  as decimal   no-undo .
define variable v-price-prev-doc   as decimal   no-undo .
define variable v-price-prev-rubl  as decimal   no-undo .
define variable v-price-sale-base  as decimal   no-undo .
define variable v-price-sale-doc   as decimal   no-undo .
define variable v-price-sale-rubl  as decimal   no-undo .
define variable v-road-tax-base    as decimal   no-undo .
define variable v-road-tax-doc     as decimal   no-undo .
define variable v-road-tax-rubl    as decimal   no-undo .
define variable v-excise-base      as decimal   no-undo .
define variable v-excise-doc       as decimal   no-undo .
define variable v-excise-rubl      as decimal   no-undo .
define variable V-base-rate       as decimal   no-undo .
define variable V-base-scale      as decimal   no-undo .
define variable V-exch-scale      as decimal   no-undo .
define variable V-exch-rate       as decimal   no-undo .
define variable v-curr-abbr as character no-undo .
define variable p-vat-pc as decimal   no-undo .
define variable p-slt-pc as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.price-list-type  no-lock  where
           ub.price-list-type.plt-db-num = p-plt-db-num  and
           ub.price-list-type.plt-id     = p-plt-id
           no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка!"
  view-as alert-box error
.
find first ub.price-doc-forming no-lock  where
           ub.price-doc-forming.plt-db-num = p-plt-db-num and
           ub.price-doc-forming.plt-id     = p-plt-id     and
           ub.price-doc-forming.pdf-db     = p-pdf-db     and
           ub.price-doc-forming.pdf-id     = p-pdf-id
            no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка!"
  view-as alert-box error
.
find first ub.goods no-lock where
 ub.goods.artic = p-artic and
 ub.goods.prod-type = p-prod-type and
 ub.goods.prod-code = p-prod-code no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка!"
  view-as alert-box error
.
if ub.price-list-type.fix-cource-crc-base = true then do:
    assign
      V-base-rate  = ub.price-doc-forming.base-rate
      V-base-scale = ub.price-doc-forming.base-scale
    .
end.
else do:
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-cntxt-host-code-obj
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
end.
if ub.price-list-type.fix-cource-crc-doc = true then do:
    assign
      V-exch-rate  = ub.price-doc-forming.exch-rate
      V-exch-scale = ub.price-doc-forming.exch-scale
    .
end.
else do:
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  ub.price-list-type.curr-code
  ,input  today
  ,output v-exch-rate
  ,output v-exch-scale
  ,output v-curr-abbr
  )  .
end.
define variable p-new-calc-method as character no-undo .
define variable v-prev-doc-code as character no-undo .
define variable v-d-pcnt as decimal   no-undo .
if ub.price-list-type.main then do:
run calc-price-line in this-procedure (
 input  'Единая':U
,input  0
,input  'Отключено':U
,input  0
,input  p-b-code
,input  ub.goods.gds-code
,input  p-artic
,input  p-prod-type
,input  p-prod-code
,input  V-base-rate
,input  V-base-scale
,input  V-exch-scale
,input  V-exch-rate
,input  ""
,input  p-price
,input  ""
,input  ?
,output p-new-calc-method
,output v-price-calc-base
,output v-price-calc-doc
,output v-price-calc-rubl
,output v-price-prev-base
,output v-price-prev-doc
,output v-price-prev-rubl
,output v-price-sale-base
,output v-price-sale-doc
,output v-price-sale-rubl
,output v-road-tax-base
,output v-road-tax-doc
,output v-road-tax-rubl
,output v-excise-base
,output v-excise-doc
,output v-excise-rubl
,output p-vat-pc
,output p-slt-pc
,output v-prev-doc-code
,output v-d-pcnt
).
end.
else do:
run set-price-line in this-procedure (
 input p-plt-id
,input p-plt-db-num
,input  'Единая':U
,input  0
,input  'Отключено':U
,input  0
,input  p-b-code
,input  ub.goods.gds-code
,input  p-artic
,input  p-prod-type
,input  p-prod-code
,input  V-base-rate
,input  V-base-scale
,input  V-exch-scale
,input  V-exch-rate
,input  ""
,input  p-price
,input  ""
,input  ?
,output p-new-calc-method
,output v-price-calc-base
,output v-price-calc-doc
,output v-price-calc-rubl
,output v-price-prev-base
,output v-price-prev-doc
,output v-price-prev-rubl
,output v-price-sale-base
,output v-price-sale-doc
,output v-price-sale-rubl
,output v-road-tax-base
,output v-road-tax-doc
,output v-road-tax-rubl
,output v-excise-base
,output v-excise-doc
,output v-excise-rubl
,output p-vat-pc
,output p-slt-pc
,output v-prev-doc-code
,output v-d-pcnt
) no-error .
if error-status :error then do:
   message
     error-status :get-message(1) skip
     return-value skip
     ""
     view-as alert-box error
   .
end.
end.
run create-line (
 input  p-plt-db-num
,input  p-plt-id
,input  p-pdf-db
,input  p-pdf-id
,input  p-line-num
,input  p-b-code
,input  p-artic
,input  p-prod-type
,input  p-prod-code
,input  p-met
,input  p-d-pcnt
,input  price-doc-forming.have-start-period
,input  price-doc-forming.start-date
,input  price-doc-forming.start-shift-date
,input  price-doc-forming.start-shift-name
,input  price-doc-forming.start-shift-num
,input  price-doc-forming.start-sys-date
,input  price-doc-forming.start-sys-time
,input  price-doc-forming.have-end-period
,input  price-doc-forming.end-date
,input  price-doc-forming.end-shift-date
,input  price-doc-forming.end-shift-name
,input  price-doc-forming.end-shift-num
,input  price-doc-forming.end-sys-date
,input  price-doc-forming.end-sys-time
,input  v-price-calc-base
,input  v-price-calc-doc
,input  v-price-calc-rubl
,input  v-price-prev-base
,input  v-price-prev-doc
,input  v-price-prev-rubl
,input  v-price-sale-base
,input  v-price-sale-doc
,input  v-price-sale-rubl
,input  v-road-tax-base
,input  v-road-tax-doc
,input  v-road-tax-rubl
,input  v-excise-base
,input  v-excise-doc
,input  v-excise-rubl
,input  p-vat-pc
,input  p-slt-pc
,input  p-out-code
,input  p-stts
,input-output v-sec   ).
  end.
end procedure.
procedure main-road-taxs :
define input param p-artic     like ub.gds-obj.artic     no-undo .
define input param p-prod-type like ub.gds-obj.prod-type no-undo .
define input param p-prod-code like ub.gds-obj.prod-code no-undo .
define input-output param p-road-tax-base as decimal no-undo .
define input-output param p-road-tax-rubl as decimal no-undo .
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
  do
  on error undo, return error return-value
  :
define buffer buff-goods   for ub.goods    .
define buffer buf_gds-obj  for ub.gds-obj  .
define buffer buf_parts    for ub.parts    .
define buffer buf_trn-doc  for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line .
define variable is-petrolium as logical   no-undo .
define variable is-pieces   as  logical   no-undo .
define variable p-in-code   as  character no-undo .
define variable p-obj-type  as  character no-undo .
define variable p-obj-code  as  integer   no-undo .
define variable v-rec as recid no-undo .
define variable t-ret as logical no-undo .
define variable v-total-avrg-base as decimal no-undo .
define variable v-total-avrg-rubl as decimal no-undo .
define variable v-total-avrg-qnty as decimal no-undo .
define variable v-total-road-tax-base     as decimal no-undo .
define variable v-total-road-tax-rubl     as decimal no-undo .
define variable v-all-total-road-tax-base as decimal no-undo .
define variable v-all-total-road-tax-rubl as decimal no-undo .
assign
  p-road-tax-base = 0
  p-road-tax-rubl = 0
  .
  Find first buff-goods no-lock where
             buff-goods.artic     = p-artic and
             buff-goods.prod-type = p-prod-type and
             buff-goods.prod-code = p-prod-code
      no-error .
      if available buff-goods then do:
         v-rec = recid (buff-goods).
         t-ret =  session:SET-WAIT-STATE("GENERAL") .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input p-artic
  ,  input p-prod-type
  ,  input p-prod-code
  , output is-petrolium
  , output is-pieces
  ) .
           t-ret =  session:SET-WAIT-STATE("") .
           if not ( hvrdtax( v-rec ) = true and  is-petrolium = false  )   then  do:
              assign
                p-road-tax-base = 0
                p-road-tax-rubl = 0
                .
               return.
           end.
      end.
      assign
          v-total-avrg-qnty = 0
          v-total-road-tax-base =  0
          v-total-road-tax-rubl =  0
          v-all-total-road-tax-base =  0
          v-all-total-road-tax-rubl =  0
          .
    for each  x_obj-group ,
        each buf_parts no-lock
        where buf_parts.obj-type  = x_obj-group.obj-type
          and buf_parts.obj-code  = x_obj-group.obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.status_   = no
          and buf_parts.out-code  = 'free-zone':U
          and buf_parts.qnty      > 0
      on error undo, return error
      :
         v-total-avrg-qnty = v-total-avrg-qnty + buf_parts.fact-qnty.
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        assign
          v-all-total-road-tax-base =  v-all-total-road-tax-base + (road-tax-base-loc * buf_parts.fact-qnty)
          v-all-total-road-tax-rubl =  v-all-total-road-tax-rubl + (road-tax-rubl-loc * buf_parts.fact-qnty)
         .
     end.
      if v-total-avrg-qnty > 0 then  do :
      assign
          p-road-tax-base =  v-all-total-road-tax-base  / v-total-avrg-qnty
          p-road-tax-rubl =  v-all-total-road-tax-rubl  / v-total-avrg-qnty
          .
      end.
      if v-total-avrg-qnty <= 0 then do :
          run last-incom-S in this-procedure
             ( input p-artic
              ,input p-prod-type
              ,input p-prod-code
              ,output p-in-code
              ,output p-obj-type
              ,output p-obj-code ).
            find first  buf_trn-doc no-lock  where buf_trn-doc.doc-code  = p-in-code no-error .
            find first  buf_doc-line no-lock where  buf_doc-line.doc-code = p-in-code
                    and buf_doc-line.artic     = p-artic
                    and buf_doc-line.prod-type = p-prod-type
                    and buf_doc-line.prod-code = p-prod-code
            no-error.
            if available buf_doc-line then do :
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
              assign
                p-road-tax-rubl =  road-tax-rubl-loc
                p-road-tax-base =  road-tax-base-loc
                .
            end.
      end.
  end.
end procedure.
procedure calc-sigma :
 do
 on error undo, return error return-value
 :
define input parameter l-bcode like ub.price-list.b-code no-undo .
define input-output parameter new-price as decimal no-undo .
define input parameter l-host as integer no-undo .
define input parameter l-code as integer no-undo .
define input parameter l-type as character no-undo .
define output parameter p-ret as logical no-undo .
define variable conf-par     as character no-undo.
define variable par-type     as character no-undo.
define variable i-sigma as decimal no-undo .
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable old-price as decimal no-undo .
p-ret = true  .
if par-pr-sigma <> ? and par-pr-sigma <> "" and par-pr-sigma <> "0" then do:
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  l-type
  ,input  l-code
  ,input  l-bcode
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  )  .
old-price = cur-pr .
if old-price =  new-price then do:
   p-ret = true .
   return.
end.
   i-sigma = decimal(par-pr-sigma) .
   if ( 100 * ABSOLUTE( old-price - new-price ) / old-price ) <= i-sigma then do:
       p-ret = false .
       new-price = old-price.
       end.
   else p-ret = true .
end.
 end.
end procedure.
def var vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-use-bar-code :
  define input  parameter p-b-code    like ub.bar-code.b-code no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info65, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info65 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info65 )
  :
    define buffer buf_bar-code for ub.bar-code .
    find first buf_bar-code no-lock
      where buf_bar-code.b-code     = p-b-code
      no-error .
    if not available buf_bar-code then do:
      return error substitute( "&1 (check-use-bar-code). Не найден бар-код &2", vss-include-info65, p-b-code ) .
    end.
    if buf_bar-code.stts = integer('99':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Выполняется удаление бар-кода"
                              ,vss-include-info65
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    if buf_bar-code.stts = integer('79':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Бар-код выключен"
                              ,vss-include-info65
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    return .
  end.
end procedure.
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define buffer l-price-doc-forming-gds for ub.price-doc-forming-gds.
define variable   rdtaxcdvalue  as character initial ? no-undo.
define variable   rdtaxcdtype   as character initial ? no-undo.
define buffer     rt_tax            for ub.tax.
define variable dor-nal as character no-undo .
define variable g#log as logical   no-undo .
define variable gds-rec as recid no-undo .
define variable rep-rec as recid no-undo .
define variable ref-rec as recid no-undo .
define new shared buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds.
define new shared buffer buf_bar-code   for ub.bar-code.
define new shared buffer buf_goods      for ub.goods.
define new shared buffer buf_gds-prt    for ub.gds-prt.
define new shared QUERY br-alt for buf_price-doc-forming-gds except, buf_bar-code, buf_goods, buf_gds-prt SCROLLING.
define variable sort-column-name as character no-undo .
FUNCTION fnc-mark RETURN character (local-bc as integer).
define buffer local-price-doc-forming-gds for ub.price-doc-forming-gds.
  find first local-price-doc-forming-gds no-lock where
             local-price-doc-forming-gds.b-code     = local-bc and
             local-price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             local-price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             local-price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             local-price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
             no-error.
  if not available local-price-doc-forming-gds then  return (?).
  if lookup (string (recid (local-price-doc-forming-gds)), mark-list) > 0 then
    return "*".
  else
    return "".
END FUNCTION.
FUNCTION fnc-main-code RETURN integer (local-bc as integer).
define variable local-main-code like ub.bar-code.b-code no-undo.
   run prc-main-code (input local-bc, output local-main-code).
return (local-main-code).
END FUNCTION.
FUNCTION fnc-base-code RETURN integer (local-bc as integer).
define variable local-base-code like ub.bar-code.b-code no-undo.
run prc-base-code (input local-bc, output local-base-code).
return (local-base-code).
END FUNCTION.
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход":L
     SIZE 8 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 6 BY 1.
DEFINE MENU m-add
       MENU-ITEM m-cur-add      LABEL "Список имеющихся спеццен"
       MENU-ITEM m-lst-add      LABEL "Список неосновных кодов"
       .
DEFINE BUTTON b-add
     LABEL "&Добав":L
     SIZE 8 BY 1.
DEFINE BUTTON b-discnt
     LABEL "С&кидка":L
     SIZE 8 BY 1.
DEFINE BUTTON b-chg
     LABEL "Рас&чет":L
     SIZE 8 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удал":L
     SIZE 8 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 8 BY 1.
define RECTANGLE rect-line EDGE-PIXELS 2 GRAPHIC-EDGE SIZE 98.5 BY 5.4 BGCOLOR GRAY_COLOR.
DEFINE VARIABLE calc-price AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" label "Цена расчет."
VIEW-AS TEXT SIZE 15 BY 0.79
tooltip "Цена, рассчитанная для данной единицы измерения через скидку и коэффициент"
no-undo.
define variable loc-art  AS character VIEW-AS fill-in size 14 by 1 fgcolor RED_COLOR no-undo.
define variable loc-name AS character VIEW-AS fill-in size 20 by 1 fgcolor RED_COLOR no-undo.
define variable loc-code AS character VIEW-AS fill-in size 20 by 1 fgcolor RED_COLOR no-undo.
define variable conf-par     as character no-undo.
define variable a-n-c AS character VIEW-AS RADIO-SET horizontal RADIO-BUTTONS
"&А","art",
"&Н","name",
"&К","code"
SIZE 12 BY 1 no-undo.
DEFINE BROWSE br-alt QUERY br-alt NO-LOCK
    DISPLAY fnc-mark (Buf_price-doc-forming-gds.b-code)   @ mark                 COLUMN-LABEL '*'  FORMAT "x(1)" if buf_gds-prt.upper-code = buf_goods.prt-root then         if buf_bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl             COLUMN-LABEL 'Тип'  FORMAT "x(3)" fnc-main-code (Buf_price-doc-forming-gds.b-code)   @ main-bc-br           COLUMN-LABEL 'Глав. код'  fnc-base-code (Buf_price-doc-forming-gds.b-code)   @ v-base-b-code        COLUMN-LABEL 'Осн. код'  buf_bar-code.b-code                          COLUMN-LABEL 'Код'  fnc-base-price-doc (Buf_price-doc-forming-gds.b-code, recid(buf_price-doc-forming) )   @ arg-base             COLUMN-LABEL 'Осн. цена' LABEL-FGCOLOR 15 LABEL-BGCOLOR 1 buf_goods.unit-base                          COLUMN-LABEL 'Изм'  FORMAT "x(3)" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1 buf_bar-code.cli-base-rate                          COLUMN-LABEL 'Коэф'  buf_price-doc-forming-gds.d-pcnt                          COLUMN-LABEL 'Скидка'  buf_price-doc-forming-gds.price-sale-doc                         COLUMN-LABEL 'Цена' LABEL-FGCOLOR 15 LABEL-BGCOLOR 1 buf_bar-code.unit-cli                         COLUMN-LABEL 'Изм' FORMAT "x(3)" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1 buf_price-doc-forming-gds.road-tax-doc                          buf_price-doc-forming-gds.excise-doc                         COLUMN-LABEL 'Акциз'
    buf_price-doc-forming-gds.price-sale-rubl  COLUMN-LABEL  "Цена (нац.вал.)"
    buf_price-doc-forming-gds.price-sale-base  COLUMN-LABEL  "Цена (баз.вал.)"
    ENABLE buf_price-doc-forming-gds.d-pcnt  buf_price-doc-forming-gds.price-sale-doc  buf_price-doc-forming-gds.road-tax-doc  buf_price-doc-forming-gds.excise-doc
    WITH SIZE 98 BY 10.5
    bgcolor WHITE_COLOR
    separators.
DEFINE FRAME d-pr-alt
     b-exit        AT ROW 1 COL 1
     b-mark        AT ROW 1 COL 9
     b-add         AT ROW 1 COL 15
     b-discnt      AT ROW 1 COL 23
     b-chg         AT ROW 1 COL 31
     b-del         AT ROW 1 COL 39
     b-help        AT ROW 1 COL 79
     round-method  AT ROW 2 COL 73 COLON-ALIGNED LABEL "Окру&гление"
        format "x(15)" VIEW-AS COMBO-BOX INNER-LINES 7 LIST-ITEMS
        '9-окончание':U,
        '9-99окончание':U,
        'Без-дробных':U,
        'Произвольно':U,
        'Вверх':U,
        'Коэффициент':U,
        'Отключено':U SIZE 15 BY 1  bgcolor WHITE_COLOR
     round-base    AT ROW 2    COL 88 COLON-ALIGNED no-LABEL
        format "->>,>>9.99" VIEW-AS FILL-IN SIZE 10 BY 1 bgcolor WHITE_COLOR
     loc-art       AT ROW 2.5  COL 39 COLON-ALIGNED label "Начало артикула"
     loc-name      AT ROW 2.5  COL 39 COLON-ALIGNED label "Начало названия" format "x(40)"
     loc-code      AT ROW 2.5  COL 39 COLON-ALIGNED label "Бар-код (весь)"  format "x(13)"
     br-alt        AT ROW 3    COL 1.5
     a-n-c         at row 1    col 88 no-label
     rect-line     at row 13.6 col 1.5
     " Информация по строке " VIEW-AS TEXT SIZE 22 BY 0.8 AT ROW 13.1 COL 38
     buf_price-doc-forming-gds.price-sale-doc
                   AT ROW 14.1 COL 80 COLON-ALIGNED label "Цена" fgcolor BROWN_COLOR
                   view-as fill-in size 15 by 0.79
     calc-price    AT ROW 15.1 COL 80 COLON-ALIGNED
     buf_goods.artic   AT ROW 14.1 COL 10 COLON-ALIGNED label "Артикул"
                   view-as fill-in size 16 by 1
     buf_goods.gds-name
                   AT ROW 14.1 COL 27 COLON-ALIGNED no-label fgcolor BROWN_COLOR
                   view-as fill-in size 35 by 1
     buf_goods.prod-type
                   AT ROW 15.1 COL 10 COLON-ALIGNED label "Пр-тель"
                   view-as fill-in size 3 by 1
     buf_goods.prod-code
                   AT ROW 15.1 COL 13 COLON-ALIGNED no-label
                   view-as fill-in size 9 by 1
     clients.obj-name
                   AT ROW 15.1 COL 27 COLON-ALIGNED no-label fgcolor BROWN_COLOR
                   view-as fill-in size 35 by 1
     buf_gds-prt.f-name
                   AT ROW 16.1 COL 10 COLON-ALIGNED label "Признак" fgcolor BROWN_COLOR
                   view-as fill-in size 16 by 1
     buf_bar-code.in-code
                   AT ROW 16.1 COL 27 COLON-ALIGNED label "ПН" fgcolor BROWN_COLOR
                   view-as fill-in size 16 by 1
     buf_bar-code.part-code
                   AT ROW 16.1 COL 47 COLON-ALIGNED label "Партия" fgcolor BROWN_COLOR
                   view-as fill-in size 16 by 1
     SPACE(0) SKIP(0)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         TITLE "Список неосновных цен":L
         DEFAULT-BUTTON b-exit
         bgcolor grey_color.
ASSIGN
  FRAME d-pr-alt:SCROLLABLE = FALSE
  br-alt   :NUM-LOCKED-COLUMNS IN FRAME d-pr-alt = 1
  b-add     :POPUP-MENU IN FRAME d-pr-alt         = MENU m-add  :HANDLE
  b-add     :MENU-MOUSE                                = 1
  .
def var sort-labelbr-alt   as character no-undo .
def var sort-clmnbr-alt    as handle    no-undo .
def var cur-clmnbr-alt     as handle    no-undo .
def var cur-clmn-locbr-alt as integer   no-undo .
def var re-querybr-alt     as logical   initial no no-undo .
on start-search, ctrl-o of br-alt in frame d-pr-alt do:
   run sort-brbr-alt
     (input (if available buf_price-doc-forming-gds
             then recid(buf_price-doc-forming-gds)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-alt :
  define input parameter p-recid as recid no-undo .
  if re-querybr-alt = no then do:
    assign
       cur-clmnbr-alt = br-alt:current-column in frame d-pr-alt
    .
    if sort-clmnbr-alt <> ? then sort-clmnbr-alt:column-fgcolor = 0.
    if cur-clmnbr-alt = sort-clmnbr-alt then do:
      assign
         sort-labelbr-alt = ""
         sort-clmnbr-alt = ?
      .
     end.
     else do:
       assign
         sort-labelbr-alt = cur-clmnbr-alt:label
         sort-clmnbr-alt  = cur-clmnbr-alt
         sort-clmnbr-alt:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-alt = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-alt:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-alt then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-alt = cur-clmn-locbr-alt + 1
    .
  end.
  case sort-labelbr-alt:
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1fnc-mark&1,  Buf_price-doc-forming-gds.b-code )' , chr(34))     .     run open-br.   . END.
        when 'Тип'  then DO:    assign       sort-column-name = "if buf_gds-prt.upper-code = buf_goods.prt-root then         if buf_bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U"     .     run open-br.   . END.
        when 'Глав. код'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1fnc-main-code&1,  Buf_price-doc-forming-gds.b-code )' , chr(34))     .     run open-br.   . END.
        when 'Осн. код'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1fnc-base-code&1, Buf_price-doc-forming-gds.b-code )' , chr(34))     .     run open-br.   . END.
        when 'Код'  then DO:    assign       sort-column-name = "buf_bar-code.b-code"     .     run open-br.   . END.
        when 'Осн. цена'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1fnc-base-price-doc&1, ( Buf_price-doc-forming-gds.b-code ), (&1&2&1)) ' , chr(34),  recid(buf_price-doc-forming) )     .     run open-br.   . END.
        when 'Изм'  then DO:    assign       sort-column-name = "buf_goods.unit-base"     .     run open-br.   . END.
        when 'Коэф'  then DO:    assign       sort-column-name = "buf_bar-code.cli-base-rate"     .     run open-br.   . END.
        when 'Скидка'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.d-pcnt"     .     run open-br.   . END.
        when 'Цена'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.price-sale-doc"     .     run open-br.   . END.
        when 'Изм'  then DO:    assign       sort-column-name = "buf_bar-code.unit-cli"     .     run open-br.   . END.
        when dor-nal  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.road-tax-doc"     .     run open-br.   . END.
        when 'Акциз'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.excise-doc"     .     run open-br.   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run open-br.
      if sort-labelbr-alt <> "" then do:
        assign
          cur-clmnbr-alt:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-alt = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-alt to recid p-recid no-error.
    apply "value-changed" to br-alt in frame d-pr-alt.
  end.
  apply "entry" to br-alt in frame d-pr-alt.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-alt:
if cur-clmnbr-alt = ? then do:
   run open-br.
end.
else do:
   assign re-querybr-alt = yes.
   run sort-brbr-alt
     (input (if available buf_price-doc-forming-gds
             then recid(buf_price-doc-forming-gds)
             else ?
            )
     ).
   assign re-querybr-alt = no.
end.
end.
define variable vss-include-info69 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-pr-alt anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-pr-alt. END.
  return no-apply.
end.
define variable vss-include-info70 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame d-pr-alt anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame d-pr-alt. END.
  return no-apply.
end.
define variable vss-include-info71 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-pr-alt anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-pr-alt. END.
  return no-apply.
end.
define variable vss-include-info72 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame d-pr-alt anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame d-pr-alt. END.
  return no-apply.
end.
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame d-pr-alt anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-alt in frame d-pr-alt.
  return no-apply.
end.
on SHIFT-F9 of frame d-pr-alt anywhere do:
  if not available goods then
    return no-apply.
  gds-rec = recid (goods).
  run ref/gds-form.w ( input parParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-alt in frame d-pr-alt.
  return no-apply.
end.
on end-error of buf_price-doc-forming-gds.price-sale-doc, buf_price-doc-forming-gds.road-tax-doc, buf_price-doc-forming-gds.excise-doc in browse br-alt do:
  display  fnc-mark (Buf_price-doc-forming-gds.b-code)   @ mark                 COLUMN-LABEL '*'  FORMAT "x(1)" if buf_gds-prt.upper-code = buf_goods.prt-root then         if buf_bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl             COLUMN-LABEL 'Тип'  FORMAT "x(3)" fnc-main-code (Buf_price-doc-forming-gds.b-code)   @ main-bc-br           COLUMN-LABEL 'Глав. код'  fnc-base-code (Buf_price-doc-forming-gds.b-code)   @ v-base-b-code        COLUMN-LABEL 'Осн. код'  buf_bar-code.b-code                          COLUMN-LABEL 'Код'  fnc-base-price-doc (Buf_price-doc-forming-gds.b-code, recid(buf_price-doc-forming) )   @ arg-base             COLUMN-LABEL 'Осн. цена'  buf_goods.unit-base                          COLUMN-LABEL 'Изм'  FORMAT "x(3)"  buf_bar-code.cli-base-rate                          COLUMN-LABEL 'Коэф'  buf_price-doc-forming-gds.d-pcnt                          COLUMN-LABEL 'Скидка'  buf_price-doc-forming-gds.price-sale-doc                         COLUMN-LABEL 'Цена'  buf_bar-code.unit-cli                         COLUMN-LABEL 'Изм' FORMAT "x(3)"  buf_price-doc-forming-gds.road-tax-doc                          buf_price-doc-forming-gds.excise-doc                         COLUMN-LABEL 'Акциз' buf_price-doc-forming-gds.price-sale-rubl  buf_price-doc-forming-gds.price-sale-base with browse br-alt.
  return no-apply.
end.
ON MOUSE-SELECT-DBLCLICK, return OF br-alt IN FRAME d-pr-alt DO:
apply "choose" to b-mark in frame d-pr-alt.
END.
ON CHOOSE OF b-mark IN FRAME d-pr-alt
DO:
define variable vss-include-info74 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if not available buf_price-doc-forming-gds then
  return no-apply.
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid76 as character no-undo .
define variable v-num-entry76 as integer   no-undo .
assign
  v-str-recid76 = trim( string( recid( buf_price-doc-forming-gds ) , "->>>>>>>>>>>9":U ) )
  v-num-entry76 = lookup( v-str-recid76 , mark-list )
.
if v-num-entry76 > 0 then do:
  assign
    entry( v-num-entry76, mark-list ) = "":U
    mark-list = trim( replace( mark-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    mark-list = mark-list + ( if mark-list = "":U then "":U else chr(44) ) + v-str-recid76
  .
end.
br-alt :refresh ().
if last-event :function <> "mouse-select-dblclick" then
  br-alt :select-next-row ().
apply "entry" to br-alt in frame d-pr-alt.
END.
on row-display of br-alt do:
  if sort-column-name <> "calc-dtl"  then
    if buf_gds-prt.upper-code = buf_goods.prt-root then
      if buf_bar-code.in-code = '' then
        calc-dtl :fgcolor in browse br-alt = BLACK_COLOR.
      else
        calc-dtl :fgcolor in browse br-alt = BLUE_COLOR.
    else
      calc-dtl :fgcolor in browse br-alt = DARK_GREEN_COLOR.
end.
on value-changed of br-alt in frame d-pr-alt do:
  if not available buf_price-doc-forming-gds then do:
    hide calc-price
         buf_price-doc-forming-gds.price-sale-doc
         buf_goods.artic
         buf_goods.gds-name
         buf_goods.prod-type
         buf_goods.prod-code
         clients.obj-name
         buf_gds-prt.f-name
         buf_bar-code.in-code
         buf_bar-code.part-code in frame d-pr-alt.
    return no-apply.
  end.
  if doc-mode = 'ИЗМЕНЕНИЕ':U then do:
    calc-price = fnc-base-price-doc (buf_bar-code.b-code, recid (buf_price-doc-forming)) *
                buf_bar-code.cli-base-rate *
                (1 - buf_price-doc-forming-gds.d-pcnt / 100)
                .
case input frame d-pr-alt round-method :
  when '9-окончание':U then do:
    if calc-price < 29 then do:
      if (calc-price - truncate (calc-price, 0)) <> 0 then do:
        assign
          calc-price = truncate (calc-price, 0) + 1
        .
      end.
    end.
    else do:
      if (calc-price modulo 10) < 3 then do:
        assign
          calc-price = (calc-price - (calc-price modulo 100))
              + ( truncate (((calc-price modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          calc-price = (calc-price - (calc-price modulo 100))
              + ( truncate (((calc-price modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        calc-price = round (calc-price, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if calc-price < input frame d-pr-alt round-base then do:
      assign
        calc-price = truncate (calc-price, 0) + 0.99
      .
    end.
    else do:
      assign
        calc-price = truncate (calc-price / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      calc-price = round (calc-price, 0)
    .
  end.
  when 'Произвольно':U then do:
    if input frame d-pr-alt round-base <> 0 then do:
      assign
        calc-price = round (calc-price / input frame d-pr-alt round-base, 0) * input frame d-pr-alt round-base
      .
      if calc-price = 0 then do:
        assign
          calc-price = input frame d-pr-alt round-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if input frame d-pr-alt round-base <> 0 then do:
      if truncate ( calc-price / input frame d-pr-alt round-base, 0 ) <> (calc-price / input frame d-pr-alt round-base) then do:
        assign
          calc-price = truncate (calc-price / input frame d-pr-alt round-base, 0) * input frame d-pr-alt round-base + input frame d-pr-alt round-base
        .
      end.
    end.
    if calc-price = 0 then do:
      assign
        calc-price = input frame d-pr-alt round-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if input frame d-pr-alt round-base <> 0 then do:
      assign
        calc-price = calc-price * input frame d-pr-alt round-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" input frame d-pr-alt round-method skip
      "round-base"   input frame d-pr-alt round-base   skip
      "price"        calc-price             skip
      view-as alert-box error .
  end.
end.
    display  calc-price with frame d-pr-alt.
  end.
  else
    hide calc-price in frame d-pr-alt.
  find clients no-lock where
       clients.obj-type = buf_goods.prod-type and
       clients.obj-code = buf_goods.prod-code.
  display  buf_price-doc-forming-gds.price-sale-doc
       buf_goods.artic
       buf_goods.gds-name
       buf_goods.prod-type
       buf_goods.prod-code
       clients.obj-name with frame d-pr-alt.
  if buf_gds-prt.upper-code = buf_goods.prt-root then
    hide buf_gds-prt.f-name in frame d-pr-alt.
  else
    display  buf_gds-prt.f-name with frame d-pr-alt.
  if buf_bar-code.in-code = "" then
    hide buf_bar-code.in-code buf_bar-code.part-code in frame d-pr-alt.
  else
    display  buf_bar-code.in-code buf_bar-code.part-code with frame d-pr-alt.
end.
on leave of buf_price-doc-forming-gds.price-sale-doc in browse br-alt or
   leave of buf_price-doc-forming-gds.d-pcnt     in browse br-alt or
   leave of buf_price-doc-forming-gds.road-tax-doc   in browse br-alt or
   leave of buf_price-doc-forming-gds.excise-doc     in browse br-alt do:
  if not available buf_price-doc-forming-gds then
    return.
  if decimal  (buf_price-doc-forming-gds.price-sale-doc :screen-value in browse br-alt) <> buf_price-doc-forming-gds.price-sale-doc or
     decimal  (buf_price-doc-forming-gds.d-pcnt     :screen-value in browse br-alt) <> buf_price-doc-forming-gds.d-pcnt or
     decimal  (buf_price-doc-forming-gds.road-tax-doc   :screen-value in browse br-alt) <> buf_price-doc-forming-gds.road-tax-doc or
     decimal  (buf_price-doc-forming-gds.excise-doc     :screen-value in browse br-alt) <> buf_price-doc-forming-gds.excise-doc then do:
    g#log = yes.
    message "Строка изменена. Записать это изменение?"
            view-as alert-box question buttons YES-NO update g#log.
    if g#log then do:
      if decimal  (buf_price-doc-forming-gds.d-pcnt     :screen-value in browse br-alt) <> buf_price-doc-forming-gds.d-pcnt then do:
        run upd-br-field.
        run calc-price-alt in this-procedure (
             input  buf_price-doc-forming-gds.b-code
            ,input recid(buf_price-doc-forming)
            ,input  d-pcnt
            ,input  round-method
            ,input  round-base
            ,output buf_price-doc-forming-gds.price-sale-base
            ,output buf_price-doc-forming-gds.price-sale-doc
            ,output buf_price-doc-forming-gds.price-sale-rubl
            ) no-error .
      end.
      else do:
        run upd-br-field.
        run calc-price-discnt in this-procedure (
            input recid(buf_price-doc-forming),
            input buf_bar-code.b-code
            ) no-error.
      end.
    end.
  end.
  display  fnc-mark (Buf_price-doc-forming-gds.b-code)   @ mark                 COLUMN-LABEL '*'  FORMAT "x(1)" if buf_gds-prt.upper-code = buf_goods.prt-root then         if buf_bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl             COLUMN-LABEL 'Тип'  FORMAT "x(3)" fnc-main-code (Buf_price-doc-forming-gds.b-code)   @ main-bc-br           COLUMN-LABEL 'Глав. код'  fnc-base-code (Buf_price-doc-forming-gds.b-code)   @ v-base-b-code        COLUMN-LABEL 'Осн. код'  buf_bar-code.b-code                          COLUMN-LABEL 'Код'  fnc-base-price-doc (Buf_price-doc-forming-gds.b-code, recid(buf_price-doc-forming) )   @ arg-base             COLUMN-LABEL 'Осн. цена'  buf_goods.unit-base                          COLUMN-LABEL 'Изм'  FORMAT "x(3)"  buf_bar-code.cli-base-rate                          COLUMN-LABEL 'Коэф'  buf_price-doc-forming-gds.d-pcnt                          COLUMN-LABEL 'Скидка'  buf_price-doc-forming-gds.price-sale-doc                         COLUMN-LABEL 'Цена'  buf_bar-code.unit-cli                         COLUMN-LABEL 'Изм' FORMAT "x(3)"  buf_price-doc-forming-gds.road-tax-doc                          buf_price-doc-forming-gds.excise-doc                         COLUMN-LABEL 'Акциз' buf_price-doc-forming-gds.price-sale-rubl  buf_price-doc-forming-gds.price-sale-base with browse br-alt.
  apply "value-changed" to br-alt in frame d-pr-alt.
end.
on return of buf_price-doc-forming-gds.price-sale-doc in browse br-alt or
   return of buf_price-doc-forming-gds.d-pcnt     in browse br-alt or
   return of buf_price-doc-forming-gds.road-tax-doc   in browse br-alt or
   return of buf_price-doc-forming-gds.excise-doc     in browse br-alt do:
  if decimal  (buf_price-doc-forming-gds.price-sale-doc :screen-value in browse br-alt) <> buf_price-doc-forming-gds.price-sale-doc or
     decimal  (buf_price-doc-forming-gds.d-pcnt     :screen-value in browse br-alt) <> buf_price-doc-forming-gds.d-pcnt or
     decimal  (buf_price-doc-forming-gds.road-tax-doc   :screen-value in browse br-alt) <> buf_price-doc-forming-gds.road-tax-doc or
     decimal  (buf_price-doc-forming-gds.excise-doc     :screen-value in browse br-alt) <> buf_price-doc-forming-gds.excise-doc then
      if decimal  (buf_price-doc-forming-gds.d-pcnt     :screen-value in browse br-alt) <> buf_price-doc-forming-gds.d-pcnt then do:
        run upd-br-field.
        run calc-price-alt in this-procedure (
             input  buf_price-doc-forming-gds.b-code
            ,input recid(buf_price-doc-forming)
            ,input  d-pcnt
            ,input  round-method
            ,input  round-base
            ,output buf_price-doc-forming-gds.price-sale-base
            ,output buf_price-doc-forming-gds.price-sale-doc
            ,output buf_price-doc-forming-gds.price-sale-rubl
            ) no-error .
      end.
      else do:
        run upd-br-field.
        run calc-price-discnt in this-procedure (
            input recid(buf_price-doc-forming),
            input buf_bar-code.b-code
            ) no-error.
      end.
  display  fnc-mark (Buf_price-doc-forming-gds.b-code)   @ mark                 COLUMN-LABEL '*'  FORMAT "x(1)" if buf_gds-prt.upper-code = buf_goods.prt-root then         if buf_bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl             COLUMN-LABEL 'Тип'  FORMAT "x(3)" fnc-main-code (Buf_price-doc-forming-gds.b-code)   @ main-bc-br           COLUMN-LABEL 'Глав. код'  fnc-base-code (Buf_price-doc-forming-gds.b-code)   @ v-base-b-code        COLUMN-LABEL 'Осн. код'  buf_bar-code.b-code                          COLUMN-LABEL 'Код'  fnc-base-price-doc (Buf_price-doc-forming-gds.b-code, recid(buf_price-doc-forming) )   @ arg-base             COLUMN-LABEL 'Осн. цена'  buf_goods.unit-base                          COLUMN-LABEL 'Изм'  FORMAT "x(3)"  buf_bar-code.cli-base-rate                          COLUMN-LABEL 'Коэф'  buf_price-doc-forming-gds.d-pcnt                          COLUMN-LABEL 'Скидка'  buf_price-doc-forming-gds.price-sale-doc                         COLUMN-LABEL 'Цена'  buf_bar-code.unit-cli                         COLUMN-LABEL 'Изм' FORMAT "x(3)"  buf_price-doc-forming-gds.road-tax-doc                          buf_price-doc-forming-gds.excise-doc                         COLUMN-LABEL 'Акциз' buf_price-doc-forming-gds.price-sale-rubl  buf_price-doc-forming-gds.price-sale-base with browse br-alt.
  apply "value-changed" to br-alt in frame d-pr-alt.
end.
ON CHOOSE OF b-exit in frame d-pr-alt DO:
define variable vss-include-info77 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
end.
ON CHOOSE OF b-discnt in frame d-pr-alt DO:
define variable vss-include-info78 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if not available buf_price-doc-forming-gds then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
run calc-price-discnt in this-procedure
    (
    input recid(buf_price-doc-forming),
    input buf_bar-code.b-code
    ) no-error.
display  fnc-mark (Buf_price-doc-forming-gds.b-code)   @ mark                 COLUMN-LABEL '*'  FORMAT "x(1)" if buf_gds-prt.upper-code = buf_goods.prt-root then         if buf_bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl             COLUMN-LABEL 'Тип'  FORMAT "x(3)" fnc-main-code (Buf_price-doc-forming-gds.b-code)   @ main-bc-br           COLUMN-LABEL 'Глав. код'  fnc-base-code (Buf_price-doc-forming-gds.b-code)   @ v-base-b-code        COLUMN-LABEL 'Осн. код'  buf_bar-code.b-code                          COLUMN-LABEL 'Код'  fnc-base-price-doc (Buf_price-doc-forming-gds.b-code, recid(buf_price-doc-forming) )   @ arg-base             COLUMN-LABEL 'Осн. цена'  buf_goods.unit-base                          COLUMN-LABEL 'Изм'  FORMAT "x(3)"  buf_bar-code.cli-base-rate                          COLUMN-LABEL 'Коэф'  buf_price-doc-forming-gds.d-pcnt                          COLUMN-LABEL 'Скидка'  buf_price-doc-forming-gds.price-sale-doc                         COLUMN-LABEL 'Цена'  buf_bar-code.unit-cli                         COLUMN-LABEL 'Изм' FORMAT "x(3)"  buf_price-doc-forming-gds.road-tax-doc                          buf_price-doc-forming-gds.excise-doc                         COLUMN-LABEL 'Акциз' buf_price-doc-forming-gds.price-sale-rubl  buf_price-doc-forming-gds.price-sale-base with browse br-alt.
apply "value-changed" to br-alt in frame d-pr-alt.
END.
ON CHOOSE OF b-chg in frame d-pr-alt DO:
define variable vss-include-info79 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if not available buf_price-doc-forming-gds then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
  find current buf_price-doc-forming-gds exclusive-lock no-error .
  run calc-price-alt in this-procedure
      (input  buf_price-doc-forming-gds.b-code
      ,input recid(buf_price-doc-forming)
      ,input  d-pcnt
      ,input  round-method
      ,input  round-base
      ,output buf_price-doc-forming-gds.price-sale-base
      ,output buf_price-doc-forming-gds.price-sale-doc
      ,output buf_price-doc-forming-gds.price-sale-rubl
      ).
display  fnc-mark (Buf_price-doc-forming-gds.b-code)   @ mark                 COLUMN-LABEL '*'  FORMAT "x(1)" if buf_gds-prt.upper-code = buf_goods.prt-root then         if buf_bar-code.in-code = '' then           'ТОВАР':U         else           'ПАРТИЯ':U       else         'ПРИЗНАК':U   @ calc-dtl             COLUMN-LABEL 'Тип'  FORMAT "x(3)" fnc-main-code (Buf_price-doc-forming-gds.b-code)   @ main-bc-br           COLUMN-LABEL 'Глав. код'  fnc-base-code (Buf_price-doc-forming-gds.b-code)   @ v-base-b-code        COLUMN-LABEL 'Осн. код'  buf_bar-code.b-code                          COLUMN-LABEL 'Код'  fnc-base-price-doc (Buf_price-doc-forming-gds.b-code, recid(buf_price-doc-forming) )   @ arg-base             COLUMN-LABEL 'Осн. цена'  buf_goods.unit-base                          COLUMN-LABEL 'Изм'  FORMAT "x(3)"  buf_bar-code.cli-base-rate                          COLUMN-LABEL 'Коэф'  buf_price-doc-forming-gds.d-pcnt                          COLUMN-LABEL 'Скидка'  buf_price-doc-forming-gds.price-sale-doc                         COLUMN-LABEL 'Цена'  buf_bar-code.unit-cli                         COLUMN-LABEL 'Изм' FORMAT "x(3)"  buf_price-doc-forming-gds.road-tax-doc                          buf_price-doc-forming-gds.excise-doc                         COLUMN-LABEL 'Акциз' buf_price-doc-forming-gds.price-sale-rubl  buf_price-doc-forming-gds.price-sale-base with browse br-alt.
apply "value-changed" to br-alt in frame d-pr-alt.
END.
ON return OF round-base IN FRAME d-pr-alt DO:
  apply "entry" to br-alt in frame d-pr-alt.
  return no-apply.
END.
on end-error, stop of frame d-pr-alt do:
  apply "choose" to b-exit in frame d-pr-alt.
  return no-apply.
end.
ON CHOOSE OF MENU-ITEM m-lst-add DO:
define variable vss-include-info80 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-add :type in frame d-pr-alt
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-pr-alt skip
    "Тип" self :type in frame d-pr-alt skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-add in frame d-pr-alt .
  if focus :handle <> b-add :handle in frame d-pr-alt then do:
    return no-apply .
  end.
end.
run add-alt ("all").
END.
ON CHOOSE OF MENU-ITEM m-cur-add DO:
define variable vss-include-info81 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(b-add :type in frame d-pr-alt
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name in frame d-pr-alt skip
    "Тип" self :type in frame d-pr-alt skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to b-add in frame d-pr-alt .
  if focus :handle <> b-add :handle in frame d-pr-alt then do:
    return no-apply .
  end.
end.
  run add-alt ("current").
END.
ON CHOOSE OF b-del in frame d-pr-alt DO:
define variable vss-include-info82 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if not available buf_price-doc-forming-gds then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
assign
  code-rec = recid (buf_price-doc-forming-gds)
  g#log = no
  .
message "Удалить строку документа?   Вы уверены?"
        view-as alert-box question buttons OK-Cancel update g#log.
if not g#log then
  return no-apply.
get next br-alt.
if available buf_price-doc-forming-gds then
  rep-rec = recid (buf_price-doc-forming-gds).
else do:
  reposition br-alt to recid code-rec no-error.
  get prev br-alt.
  if available buf_price-doc-forming-gds then
    rep-rec = recid (buf_price-doc-forming-gds).
end.
reposition br-alt to recid code-rec no-error.
find first buf_price-doc-forming-gds exclusive-lock where recid (buf_price-doc-forming-gds) = code-rec .
delete buf_price-doc-forming-gds.
code-rec = rep-rec.
doc-mode = 'ИЗМЕНЕНИЕ':U.
run open-br.
END.
ON value-changed OF round-method IN FRAME d-pr-alt DO:
assign
  round-method.
run UI-on.
END.
ON LEAVE OF round-base IN FRAME d-pr-alt DO:
if input frame d-pr-alt round-base = 0 then do:
  if input frame d-pr-alt round-method = 'Произвольно':U then
    message "Такое округление невозможно - деление на 0."
            view-as alert-box error.
  else
    message "Пересчет по нулевому коэффициенту невозможен - получится 0."
            view-as alert-box error.
end.
else
  assign
    round-base.
display  round-base with frame d-pr-alt.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-pr-alt:PARENT eq ? THEN
  FRAME d-pr-alt:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-pr-alt APPLY "END-ERROR":U TO SELF.
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-pr-alt
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
on choose of b-help in frame d-pr-alt
do:
  apply "help":u to frame d-pr-alt .
end.
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-pr-alt:width - 0.3
                fh            = frame d-pr-alt:first-child
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define variable l-par as logical   no-undo .
    run chec-par in this-procedure (
          output l-par
          ,input  v-cntxt-host-code-obj
          ,input  v-cntxt-obj-type
          ,input  v-cntxt-obj-code
        ) no-error .
   run tax-name( input 'rdt':U, output  dor-nal) .
   assign buf_price-doc-forming-gds.road-tax-doc :label  = dor-nal.
  if doc-mode <> 'ПРОСМОТР':U then
    code-rec = ?.
  find first buf_price-doc-forming no-lock where
        recid (buf_price-doc-forming) = p-doc-rec.
  find first buf_base_bar-code no-lock where
             buf_base_bar-code.b-code = p-b-code no-error.
  if available buf_base_bar-code then
    find first buf_base_goods no-lock where
               buf_base_goods.gds-code = buf_base_bar-code.gds-code.
  case mode:
    when "code" then do:
    end.
    when "scl-gds" then do:
    end.
    when "par-gds" then do:
    end.
    when "scl-doc" then do:
    end.
    when "par-doc" then do:
    end.
    when "doc" then do:
    end.
  end case.
  run UI-on.
  run open-br.
  WAIT-FOR GO OF FRAME d-pr-alt focus br-alt.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-pr-alt.
END PROCEDURE.
PROCEDURE UI-on :
disable all with frame d-pr-alt.
hide loc-art loc-name loc-code in frame d-pr-alt.
loc-art = "".
enable a-n-c b-exit b-help br-alt with frame d-pr-alt.
frame d-pr-alt:title = "Список неосновных цен ДНЦ № " + string(buf_price-doc-forming.pdf-id).
case mode:
  when "code"    then
    frame d-pr-alt:title = frame d-pr-alt:title +
                                "      Код: " + string (p-b-code, ">>>>>>>>9").
  when "scl-gds" then
    frame d-pr-alt:title = frame d-pr-alt:title +
                                "      Товар: " + buf_base_goods.artic + "  " + buf_base_goods.gds-name +
                                "      ПРИЗНАКИ".
  when "par-gds" then
    frame d-pr-alt:title = frame d-pr-alt:title +
                                "      Товар: " + buf_base_goods.artic + "  " + buf_base_goods.gds-name +
                                "      ПАРТИИ".
  when "scl-doc" then
    frame d-pr-alt:title = frame d-pr-alt:title +
                                "      ПРИЗНАКИ по ДНЦ".
  when "par-doc" then
    frame d-pr-alt:title = frame d-pr-alt:title +
                                "      ПАРТИИ по ДНЦ".
  when "doc"     then
    frame d-pr-alt:title = frame d-pr-alt:title +
                                "      Все по ДНЦ".
end.
frame d-pr-alt:title = frame d-pr-alt:title + "              " +
                            doc-mode.
if doc-mode = 'ПРОСМОТР':U then do:
  assign
    buf_price-doc-forming-gds.d-pcnt :read-only in browse br-alt = yes buf_price-doc-forming-gds.price-sale-doc :read-only in browse br-alt = yes buf_price-doc-forming-gds.road-tax-doc :read-only in browse br-alt = yes buf_price-doc-forming-gds.excise-doc :read-only in browse br-alt = yes
    .
  hide round-method in frame d-pr-alt.
end.
else do:
  assign
    buf_price-doc-forming-gds.d-pcnt :read-only in browse br-alt = no buf_price-doc-forming-gds.price-sale-doc :read-only in browse br-alt = no buf_price-doc-forming-gds.road-tax-doc :read-only in browse br-alt = no buf_price-doc-forming-gds.excise-doc :read-only in browse br-alt = no
    .
  display  round-method round-base with frame d-pr-alt.
  if lookup (mode, "code,scl-gds,par-gds") > 0 then
    enable b-add with frame d-pr-alt.
  enable b-mark b-discnt b-chg b-del round-method with frame d-pr-alt.
  if lookup( input frame d-pr-alt round-method, 'Произвольно,Вверх,Коэффициент,9-99окончание':U ) > 0 then do:
    enable round-base with frame d-pr-alt.
    display  round-base with frame d-pr-alt.
  end.
  else
    hide round-base in frame d-pr-alt.
end.
apply "entry" to br-alt in frame d-pr-alt.
END PROCEDURE.
PROCEDURE open-br :
define variable l-query-was-opened as logical no-undo .
define variable sort-column-phrase as character    no-undo .
define variable d-num like ub.price-doc-forming.pdf-id  no-undo.
define variable d-db  like ub.price-doc-forming.pdf-db  no-undo.
assign
  l-query-was-opened = false
  d-num = buf_price-doc-forming.pdf-id
  d-db = buf_price-doc-forming.pdf-db
  .
if sort-column-name = "" then
  sort-column-phrase = "".
else
  sort-column-phrase = "by " + sort-column-name.
if available buf_price-doc-forming-gds then
  code-rec = recid (buf_price-doc-forming-gds).
case mode:
  when 'code-old'    then do:
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-86  as logical   no-undo .
define variable  l-filter-open-86    as logical   .
define variable  flt-rec-86       as recid     no-undo .
define variable  filter-name-86      as character no-undo .
define variable  where-phrase-86     as character no-undo .
define variable  sort-phrase-86      as character no-undo .
define variable  where-phrase-rus-86 as character no-undo .
define variable  sort-phrase-rus-86  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-86
  ,output filter-name-86
  ,output where-phrase-86
  ,output sort-phrase-86
  ,output where-phrase-rus-86
  ,output sort-phrase-rus-86
  ).
  assign
    l-filter-open-86 = false
  .
  if flt-rec-86 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-86 as character no-undo .
    define variable  parameter-3-86 as character no-undo .
    define variable  parameter-4-86 as character no-undo .
    define variable  parameter-5-86 as character no-undo .
    define variable  parameter-6-86 as character no-undo .
    define variable  parameter-7-86 as character no-undo .
      assign
      parameter-3-86 =
                              "FOR EACH BUF_PRICE-DOC-FORMING-GDS"
      parameter-4-86 =
        (
          if (" buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  " + " " + where-phrase-86) <> ""
          then  substitute(' buf_price-doc-forming-gds.pdf-id =  &1 and buf_price-doc-forming-gds.pdf-db =  &2 ' , d-num , d-db)  + " " + where-phrase-86
          else "true"
        )
      parameter-5-86 = (" " + "" + " " + substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code                buf_bar-code.gds-code  = &2 and               buf_bar-code.node-code = &3 and               buf_bar-code.in-code   = &1&4&1 and               buf_bar-code.part-code = &1&5&1 ,  ,  each buf_goods no-lock where          buf_goods.gds-code = buf_bar-code.gds-code and          buf_goods.unit-base <> buf_bar-code.unit-cli ,     each buf_gds-prt no-lock where          buf_gds-prt.node-code = buf_bar-code.node-code ', chr(34) ,          buf_base_bar-code.gds-code ,          buf_base_bar-code.node-code ,          buf_base_bar-code.in-code ,           buf_base_bar-code.part-code  ))
      parameter-6-86 = if sort-phrase-86 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-86
        )
      parameter-7-86 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-86 =
          (" buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  " + " " + where-phrase-86 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-alt:handle
                          ,input parameter-3-86
                          ,input parameter-4-86
                          ,input parameter-5-86
                          ,input parameter-6-86
                          ,input parameter-7-86
                          )
      .
      assign
        l-filter-open-86 = true
      .
    end.
    if l-filter-open-86 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-86 = false then do:
    open query br-alt  for each buf_price-doc-forming-gds no-lock
      where  buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db
    ,         each buf_bar-code no-lock  where               buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code  and               buf_bar-code.gds-code  = buf_base_bar-code.gds-code  and               buf_bar-code.node-code = buf_base_bar-code.node-code and               buf_bar-code.in-code   = buf_base_bar-code.in-code   and               buf_bar-code.part-code = buf_base_bar-code.part-code ,         each buf_goods no-lock where              buf_goods.gds-code = buf_bar-code.gds-code and              buf_goods.unit-base <> buf_bar-code.unit-cli ,         each buf_gds-prt no-lock where              buf_gds-prt.node-code = buf_bar-code.node-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  end.
  when 'code'    then do:
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-88  as logical   no-undo .
define variable  l-filter-open-88    as logical   .
define variable  flt-rec-88       as recid     no-undo .
define variable  filter-name-88      as character no-undo .
define variable  where-phrase-88     as character no-undo .
define variable  sort-phrase-88      as character no-undo .
define variable  where-phrase-rus-88 as character no-undo .
define variable  sort-phrase-rus-88  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-88
  ,output filter-name-88
  ,output where-phrase-88
  ,output sort-phrase-88
  ,output where-phrase-rus-88
  ,output sort-phrase-rus-88
  ).
  assign
    l-filter-open-88 = false
  .
  if flt-rec-88 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-88 as character no-undo .
    define variable  parameter-3-88 as character no-undo .
    define variable  parameter-4-88 as character no-undo .
    define variable  parameter-5-88 as character no-undo .
    define variable  parameter-6-88 as character no-undo .
    define variable  parameter-7-88 as character no-undo .
      assign
      parameter-3-88 =
                              "FOR EACH BUF_PRICE-DOC-FORMING-GDS"
      parameter-4-88 =
        (
          if (" buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  " + " " + where-phrase-88) <> ""
          then  substitute(' buf_price-doc-forming-gds.pdf-id =  &1 and buf_price-doc-forming-gds.pdf-db =  &2 ' , d-num , d-db)  + " " + where-phrase-88
          else "true"
        )
      parameter-5-88 = (" " + "" + " " + substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code and buf_bar-code.gds-code  = &2  ,  each buf_goods no-lock where          buf_goods.gds-code = buf_bar-code.gds-code and          buf_goods.unit-base <> buf_bar-code.unit-cli ,     each buf_gds-prt no-lock where          buf_gds-prt.node-code = buf_bar-code.node-code ', chr(34) , buf_base_bar-code.gds-code  ))
      parameter-6-88 = if sort-phrase-88 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-88
        )
      parameter-7-88 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-88 =
          (" buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  " + " " + where-phrase-88 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-alt:handle
                          ,input parameter-3-88
                          ,input parameter-4-88
                          ,input parameter-5-88
                          ,input parameter-6-88
                          ,input parameter-7-88
                          )
      .
      assign
        l-filter-open-88 = true
      .
    end.
    if l-filter-open-88 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-88 = false then do:
    open query br-alt  for each buf_price-doc-forming-gds no-lock
      where  buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db
    ,         each buf_bar-code no-lock where             buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code  and             buf_bar-code.gds-code  = buf_base_bar-code.gds-code           ,         each buf_goods no-lock where              buf_goods.gds-code = buf_bar-code.gds-code and              buf_goods.unit-base <> buf_bar-code.unit-cli ,         each buf_gds-prt no-lock where              buf_gds-prt.node-code = buf_bar-code.node-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  end.
  when 'scl-gds' then do:
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-90  as logical   no-undo .
define variable  l-filter-open-90    as logical   .
define variable  flt-rec-90       as recid     no-undo .
define variable  filter-name-90      as character no-undo .
define variable  where-phrase-90     as character no-undo .
define variable  sort-phrase-90      as character no-undo .
define variable  where-phrase-rus-90 as character no-undo .
define variable  sort-phrase-rus-90  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-90
  ,output filter-name-90
  ,output where-phrase-90
  ,output sort-phrase-90
  ,output where-phrase-rus-90
  ,output sort-phrase-rus-90
  ).
  assign
    l-filter-open-90 = false
  .
  if flt-rec-90 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-90 as character no-undo .
    define variable  parameter-3-90 as character no-undo .
    define variable  parameter-4-90 as character no-undo .
    define variable  parameter-5-90 as character no-undo .
    define variable  parameter-6-90 as character no-undo .
    define variable  parameter-7-90 as character no-undo .
      assign
      parameter-3-90 =
                              "FOR EACH BUF_PRICE-DOC-FORMING-GDS"
      parameter-4-90 =
        (
          if (" buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  " + " " + where-phrase-90) <> ""
          then  substitute(' buf_price-doc-forming-gds.pdf-id =  &1 and buf_price-doc-forming-gds.pdf-db =  &2 ' , d-num , d-db)  + " " + where-phrase-90
          else "true"
        )
      parameter-5-90 = (" " + "" + " " + substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code and          buf_bar-code.gds-code  = &3   and          buf_bar-code.node-code = &4   and          buf_bar-code.in-code   = &1&1 and          buf_bar-code.part-code = &1&1  ,  each buf_goods no-lock where          buf_goods.gds-code   = buf_bar-code.gds-code and          buf_goods.unit-base <> buf_bar-code.unit-cli ,     each buf_gds-prt no-lock where          buf_gds-prt.node-code = buf_bar-code.node-code ', chr(34) ,          buf_base_bar-code.gds-code  ,          buf_base_bar-code.node-code          ))
      parameter-6-90 = if sort-phrase-90 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-90
        )
      parameter-7-90 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-90 =
          (" buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  " + " " + where-phrase-90 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-alt:handle
                          ,input parameter-3-90
                          ,input parameter-4-90
                          ,input parameter-5-90
                          ,input parameter-6-90
                          ,input parameter-7-90
                          )
      .
      assign
        l-filter-open-90 = true
      .
    end.
    if l-filter-open-90 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-90 = false then do:
    open query br-alt  for each buf_price-doc-forming-gds no-lock
      where  buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db
    ,         each buf_bar-code no-lock where              buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code  and              buf_bar-code.gds-code  = buf_base_bar-code.gds-code  and              buf_bar-code.node-code = buf_base_bar-code.node-code and              buf_bar-code.in-code   = ''                          and              buf_bar-code.part-code = ''            ,         each buf_goods no-lock where              buf_goods.gds-code = buf_bar-code.gds-code and              buf_goods.unit-base <> buf_bar-code.unit-cli ,         each buf_gds-prt no-lock where              buf_gds-prt.node-code = buf_bar-code.node-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  end.
  when 'par-gds' then do:
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-92  as logical   no-undo .
define variable  l-filter-open-92    as logical   .
define variable  flt-rec-92       as recid     no-undo .
define variable  filter-name-92      as character no-undo .
define variable  where-phrase-92     as character no-undo .
define variable  sort-phrase-92      as character no-undo .
define variable  where-phrase-rus-92 as character no-undo .
define variable  sort-phrase-rus-92  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-92
  ,output filter-name-92
  ,output where-phrase-92
  ,output sort-phrase-92
  ,output where-phrase-rus-92
  ,output sort-phrase-rus-92
  ).
  assign
    l-filter-open-92 = false
  .
  if flt-rec-92 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-92 as character no-undo .
    define variable  parameter-3-92 as character no-undo .
    define variable  parameter-4-92 as character no-undo .
    define variable  parameter-5-92 as character no-undo .
    define variable  parameter-6-92 as character no-undo .
    define variable  parameter-7-92 as character no-undo .
      assign
      parameter-3-92 =
                              "FOR EACH BUF_PRICE-DOC-FORMING-GDS"
      parameter-4-92 =
        (
          if (" buf_price-doc-forming-gds.pdf-id = d-num and buf_price-doc-forming-gds.pdf-db = d-db  " + " " + where-phrase-92) <> ""
          then  substitute(' buf_price-doc-forming-gds.pdf-id =  &1 and buf_price-doc-forming-gds.pdf-db =  &2 ' , d-num , d-db)  + " " + where-phrase-92
          else "true"
        )
      parameter-5-92 = (" " + "" + " " + substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code and           buf_bar-code.gds-code  = and &2           buf_bar-code.in-code  <> &1&1  ,  each buf_goods no-lock where          buf_goods.gds-code = buf_bar-code.gds-code and          buf_goods.unit-base <> buf_bar-code.unit-cli ,     each buf_gds-prt no-lock where          buf_gds-prt.node-code = buf_bar-code.node-code ' ,  chr(34) , buf_base_bar-code.gds-code ))
      parameter-6-92 = if sort-phrase-92 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-92
        )
      parameter-7-92 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-92 =
          (" buf_price-doc-forming-gds.pdf-id = d-num and buf_price-doc-forming-gds.pdf-db = d-db  " + " " + where-phrase-92 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-alt:handle
                          ,input parameter-3-92
                          ,input parameter-4-92
                          ,input parameter-5-92
                          ,input parameter-6-92
                          ,input parameter-7-92
                          )
      .
      assign
        l-filter-open-92 = true
      .
    end.
    if l-filter-open-92 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-92 = false then do:
    open query br-alt  for each buf_price-doc-forming-gds no-lock
      where  buf_price-doc-forming-gds.pdf-id = d-num and buf_price-doc-forming-gds.pdf-db = d-db
    ,         each buf_bar-code no-lock where              buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code  and              buf_bar-code.gds-code  = buf_base_bar-code.gds-code  and              buf_bar-code.in-code  <> ''         ,         each buf_goods no-lock where              buf_goods.gds-code = buf_bar-code.gds-code and              buf_goods.unit-base <> buf_bar-code.unit-cli ,         each buf_gds-prt no-lock where              buf_gds-prt.node-code = buf_bar-code.node-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  end.
  when 'scl-doc' then do:
define variable vss-include-info93 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-94  as logical   no-undo .
define variable  l-filter-open-94    as logical   .
define variable  flt-rec-94       as recid     no-undo .
define variable  filter-name-94      as character no-undo .
define variable  where-phrase-94     as character no-undo .
define variable  sort-phrase-94      as character no-undo .
define variable  where-phrase-rus-94 as character no-undo .
define variable  sort-phrase-rus-94  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-94
  ,output filter-name-94
  ,output where-phrase-94
  ,output sort-phrase-94
  ,output where-phrase-rus-94
  ,output sort-phrase-rus-94
  ).
  assign
    l-filter-open-94 = false
  .
  if flt-rec-94 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-94 as character no-undo .
    define variable  parameter-3-94 as character no-undo .
    define variable  parameter-4-94 as character no-undo .
    define variable  parameter-5-94 as character no-undo .
    define variable  parameter-6-94 as character no-undo .
    define variable  parameter-7-94 as character no-undo .
      assign
      parameter-3-94 =
                              "FOR EACH BUF_PRICE-DOC-FORMING-GDS"
      parameter-4-94 =
        (
          if (" buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  " + " " + where-phrase-94) <> ""
          then  substitute(' buf_price-doc-forming-gds.pdf-id =  &1 and buf_price-doc-forming-gds.pdf-db =  &2 ' , d-num , d-db)  + " " + where-phrase-94
          else "true"
        )
      parameter-5-94 = (" " + "" + " " + substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code  and               buf_bar-code.in-code   = &1&1  and               buf_bar-code.part-code = &1&1   ,  each buf_goods no-lock where          buf_goods.gds-code = buf_bar-code.gds-code and          buf_goods.unit-base <> buf_bar-code.unit-cli ,     each buf_gds-prt no-lock where          buf_gds-prt.node-code = buf_bar-code.node-code ', chr(34)))
      parameter-6-94 = if sort-phrase-94 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-94
        )
      parameter-7-94 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-94 =
          (" buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  " + " " + where-phrase-94 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-alt:handle
                          ,input parameter-3-94
                          ,input parameter-4-94
                          ,input parameter-5-94
                          ,input parameter-6-94
                          ,input parameter-7-94
                          )
      .
      assign
        l-filter-open-94 = true
      .
    end.
    if l-filter-open-94 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-94 = false then do:
    open query br-alt  for each buf_price-doc-forming-gds no-lock
      where  buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db
    ,         each buf_bar-code no-lock where               buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code and               buf_bar-code.in-code   = ''                      and               buf_bar-code.part-code = ''         ,         each buf_goods no-lock where              buf_goods.gds-code = buf_bar-code.gds-code and              buf_goods.unit-base <> buf_bar-code.unit-cli ,         each buf_gds-prt no-lock where              buf_gds-prt.node-code = buf_bar-code.node-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  end.
  when 'par-doc' then do:
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-96  as logical   no-undo .
define variable  l-filter-open-96    as logical   .
define variable  flt-rec-96       as recid     no-undo .
define variable  filter-name-96      as character no-undo .
define variable  where-phrase-96     as character no-undo .
define variable  sort-phrase-96      as character no-undo .
define variable  where-phrase-rus-96 as character no-undo .
define variable  sort-phrase-rus-96  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-96
  ,output filter-name-96
  ,output where-phrase-96
  ,output sort-phrase-96
  ,output where-phrase-rus-96
  ,output sort-phrase-rus-96
  ).
  assign
    l-filter-open-96 = false
  .
  if flt-rec-96 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-96 as character no-undo .
    define variable  parameter-3-96 as character no-undo .
    define variable  parameter-4-96 as character no-undo .
    define variable  parameter-5-96 as character no-undo .
    define variable  parameter-6-96 as character no-undo .
    define variable  parameter-7-96 as character no-undo .
      assign
      parameter-3-96 =
                              "FOR EACH BUF_PRICE-DOC-FORMING-GDS"
      parameter-4-96 =
        (
          if (" buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  " + " " + where-phrase-96) <> ""
          then  substitute(' buf_price-doc-forming-gds.pdf-id =  &1 and buf_price-doc-forming-gds.pdf-db =  &2 ' , d-num , d-db)  + " " + where-phrase-96
          else "true"
        )
      parameter-5-96 = (" " + "" + " " + substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code and     buf_bar-code.in-code  <> &1&1  ,  each buf_goods no-lock where          buf_goods.gds-code = buf_bar-code.gds-code and          buf_goods.unit-base <> buf_bar-code.unit-cli ,     each buf_gds-prt no-lock where          buf_gds-prt.node-code = buf_bar-code.node-code ', chr(34)))
      parameter-6-96 = if sort-phrase-96 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-96
        )
      parameter-7-96 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-96 =
          (" buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  " + " " + where-phrase-96 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-alt:handle
                          ,input parameter-3-96
                          ,input parameter-4-96
                          ,input parameter-5-96
                          ,input parameter-6-96
                          ,input parameter-7-96
                          )
      .
      assign
        l-filter-open-96 = true
      .
    end.
    if l-filter-open-96 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-96 = false then do:
    open query br-alt  for each buf_price-doc-forming-gds no-lock
      where  buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db
    ,         each buf_bar-code no-lock where              buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code       and              buf_bar-code.in-code  <> ''         ,         each buf_goods no-lock where              buf_goods.gds-code = buf_bar-code.gds-code and              buf_goods.unit-base <> buf_bar-code.unit-cli ,         each buf_gds-prt no-lock where              buf_gds-prt.node-code = buf_bar-code.node-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  end.
  when 'doc'     then do:
define variable vss-include-info97 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-98  as logical   no-undo .
define variable  l-filter-open-98    as logical   .
define variable  flt-rec-98       as recid     no-undo .
define variable  filter-name-98      as character no-undo .
define variable  where-phrase-98     as character no-undo .
define variable  sort-phrase-98      as character no-undo .
define variable  where-phrase-rus-98 as character no-undo .
define variable  sort-phrase-rus-98  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-98
  ,output filter-name-98
  ,output where-phrase-98
  ,output sort-phrase-98
  ,output where-phrase-rus-98
  ,output sort-phrase-rus-98
  ).
  assign
    l-filter-open-98 = false
  .
  if flt-rec-98 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-98 as character no-undo .
    define variable  parameter-3-98 as character no-undo .
    define variable  parameter-4-98 as character no-undo .
    define variable  parameter-5-98 as character no-undo .
    define variable  parameter-6-98 as character no-undo .
    define variable  parameter-7-98 as character no-undo .
      assign
      parameter-3-98 =
                              "FOR EACH BUF_PRICE-DOC-FORMING-GDS"
      parameter-4-98 =
        (
          if (" buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  " + " " + where-phrase-98) <> ""
          then  substitute(' buf_price-doc-forming-gds.pdf-id =  &1 and buf_price-doc-forming-gds.pdf-db =  &2 ' , d-num , d-db)  + " " + where-phrase-98
          else "true"
        )
      parameter-5-98 = (" " + "" + " " + substitute(' , each buf_bar-code no-lock where buf_bar-code.b-code = buf_price-doc-forming-gds.b-code   ,  each buf_goods no-lock where          buf_goods.gds-code = buf_bar-code.gds-code and          buf_goods.unit-base <> buf_bar-code.unit-cli ,     each buf_gds-prt no-lock where          buf_gds-prt.node-code = buf_bar-code.node-code ', chr(34)))
      parameter-6-98 = if sort-phrase-98 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-98
        )
      parameter-7-98 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-98 =
          (" buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db  " + " " + where-phrase-98 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-alt:handle
                          ,input parameter-3-98
                          ,input parameter-4-98
                          ,input parameter-5-98
                          ,input parameter-6-98
                          ,input parameter-7-98
                          )
      .
      assign
        l-filter-open-98 = true
      .
    end.
    if l-filter-open-98 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-98 = false then do:
    open query br-alt  for each buf_price-doc-forming-gds no-lock
      where  buf_price-doc-forming-gds.pdf-id = d-num  and buf_price-doc-forming-gds.pdf-db = d-db
    ,         each buf_bar-code no-lock where              buf_bar-code.b-code    = buf_price-doc-forming-gds.b-code         ,         each buf_goods no-lock where              buf_goods.gds-code = buf_bar-code.gds-code and              buf_goods.unit-base <> buf_bar-code.unit-cli ,         each buf_gds-prt no-lock where              buf_gds-prt.node-code = buf_bar-code.node-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  end.
end case.
if code-rec <> ? then
  reposition br-alt to recid code-rec no-error.
apply "entry" to br-alt in frame d-pr-alt.
apply "value-changed" to br-alt in frame d-pr-alt.
END PROCEDURE.
PROCEDURE add-alt :
define input parameter add-list as character no-undo.
define variable d-pcnt as decimal   no-undo .
define variable rec-list as character  no-undo.
define variable num-rec  as integer    no-undo.
define variable v-price-calc-base as decimal   no-undo .
define variable v-price-calc-doc  as decimal   no-undo .
define variable v-price-calc-rubl as decimal   no-undo .
define variable v-price-prev-base as decimal   no-undo .
define variable v-price-prev-doc  as decimal   no-undo .
define variable v-price-prev-rubl as decimal   no-undo .
define variable v-price-sale-base as decimal   no-undo .
define variable v-price-sale-doc  as decimal   no-undo .
define variable v-price-sale-rubl as decimal   no-undo .
define variable v-road-tax-base   as decimal   no-undo .
define variable v-road-tax-doc    as decimal   no-undo .
define variable v-road-tax-rubl   as decimal   no-undo .
define variable v-excise-base     as decimal   no-undo .
define variable v-excise-doc      as decimal   no-undo .
define variable v-excise-rubl     as decimal   no-undo .
define variable v-vat-pc          as decimal   no-undo .
define variable v-slt-pc          as decimal   no-undo .
define buffer bb_bar-code for ub.bar-code  .
run ref/alt-cds.w
    ( parParentProc
    ,input p-obj-type
    ,input p-obj-code
    ,input (mode + "-" + add-list)
    ,input buf_base_goods.gds-code
    ,input p-b-code
    ,output rec-list).
apply "entry" to br-alt in frame d-pr-alt.
if rec-list = '' then
  return no-apply.
code-rec = ?.
run last-num ( input recid(buf_price-doc-forming) , output v-line-num ) .
define variable v-nn as integer   no-undo .
v-nn = num-entries (rec-list) .
do num-rec = 1 to v-nn :
  ref-rec = integer (entry (num-rec, rec-list)).
  find first bb_bar-code no-lock where recid (bb_bar-code) = ref-rec .
define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal no-undo .
define variable v-cur-rt as decimal no-undo .
define variable v-cur-ex as decimal no-undo .
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  bb_bar-code.b-code
  ,input  0
  ,input  0
  ,output v-cur-dn
  ,output v-cur-pr
  ,output v-cur-rt
  ,output v-cur-ex
  )  .
define buffer old1_price-list    for ub.price-list  .
find first old1_price-list no-lock where
           old1_price-list.doc-num     = v-cur-dn      and
           old1_price-list.price-type  = ""            and
           old1_price-list.b-code      = bb_bar-code.b-code
           no-error .
if available old1_price-list then do:
   d-pcnt = old1_price-list.d-pcnt .
end.
else do:
  d-pcnt = 0 .
end.
    run calc-price-alt in this-procedure
      ( input  bb_bar-code.b-code
      , input recid(buf_price-doc-forming)
      , input  d-pcnt
      , input  round-method
      , input  round-base
      , output v-price-sale-base
      , output v-price-sale-doc
      , output v-price-sale-rubl
        ).
    v-line-num = v-line-num + 1 .
    define buffer bb_price-doc-forming-gds for ub.price-doc-forming-gds  .
    find first bb_price-doc-forming-gds no-lock where
               bb_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
               bb_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id     and
               bb_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db     and
               bb_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id     and
               bb_price-doc-forming-gds.artic      = buf_base_goods.artic             and
               bb_price-doc-forming-gds.prod-type  = buf_base_goods.prod-type         and
               bb_price-doc-forming-gds.prod-code  = buf_base_goods.prod-code         no-error .
    if available bb_price-doc-forming-gds then
    assign
      v-vat-pc = bb_price-doc-forming-gds.vat-pc
      v-slt-pc = bb_price-doc-forming-gds.slt-pc
      .
    else
    assign
      v-vat-pc = 0
      v-slt-pc = 0
      .
    run create-line  in this-procedure (
       buf_price-doc-forming.plt-db-num
      ,buf_price-doc-forming.plt-id
      ,buf_price-doc-forming.pdf-db
      ,buf_price-doc-forming.pdf-id
      ,v-line-num
      ,bb_bar-code.b-code
      ,buf_base_goods.artic
      ,buf_base_goods.prod-type
      ,buf_base_goods.prod-code
      ,'Основная':U
      ,d-pcnt
      ,buf_price-doc-forming.have-start-period
      ,buf_price-doc-forming.start-date
      ,buf_price-doc-forming.start-shift-date
      ,buf_price-doc-forming.start-shift-name
      ,buf_price-doc-forming.start-shift-num
      ,buf_price-doc-forming.start-sys-date
      ,buf_price-doc-forming.start-sys-time
      ,buf_price-doc-forming.have-end-period
      ,buf_price-doc-forming.end-date
      ,buf_price-doc-forming.end-shift-date
      ,buf_price-doc-forming.end-shift-name
      ,buf_price-doc-forming.end-shift-num
      ,buf_price-doc-forming.end-sys-date
      ,buf_price-doc-forming.end-sys-time
      ,v-price-calc-base
      ,v-price-calc-doc
      ,v-price-calc-rubl
      ,v-price-prev-base
      ,v-price-prev-doc
      ,v-price-prev-rubl
      ,v-price-sale-base
      ,v-price-sale-doc
      ,v-price-sale-rubl
      ,v-road-tax-base
      ,v-road-tax-doc
      ,v-road-tax-rubl
      ,v-excise-base
      ,v-excise-doc
      ,v-excise-rubl
      ,v-vat-pc
      ,v-slt-pc
      ,""
      ,0
      ,input-output v-sec
      ) .
end.
run open-br.
END PROCEDURE.
procedure upd-br-field:
  find current buf_price-doc-forming-gds share-lock.
  if decimal  (buf_price-doc-forming-gds.price-sale-doc :screen-value in browse br-alt) <> buf_price-doc-forming-gds.price-sale-doc then do:
    assign
      buf_price-doc-forming-gds.calc-method = 'Отсутствует':U
      buf_price-doc-forming-gds.price-calc-doc  = buf_price-doc-forming-gds.price-sale-doc
      buf_price-doc-forming-gds.price-sale-doc  = decimal  (buf_price-doc-forming-gds.price-sale-doc :screen-value in browse br-alt)
      buf_price-doc-forming-gds.price-sale-rubl = buf_price-doc-forming-gds.price-sale-doc * buf_price-doc-forming.exch-rate / buf_price-doc-forming.exch-scale .
      buf_price-doc-forming-gds.price-sale-base = buf_price-doc-forming-gds.price-sale-rubl / buf_price-doc-forming.base-rate * buf_price-doc-forming.base-scale .
      .
    if buf_price-doc-forming-gds.d-pcnt = ? then do:
    end.
  end.
  else do:
    if decimal  (buf_price-doc-forming-gds.d-pcnt     :screen-value in browse br-alt) <> buf_price-doc-forming-gds.d-pcnt then do:
      buf_price-doc-forming-gds.d-pcnt     = decimal  (buf_price-doc-forming-gds.d-pcnt     :screen-value in browse br-alt).
      if buf_price-doc-forming-gds.d-pcnt <> ? then do:
        run calc-price-alt in this-procedure
            (input  buf_price-doc-forming-gds.b-code
            ,input recid(buf_price-doc-forming)
            ,input  buf_price-doc-forming-gds.d-pcnt
            ,input  round-method
            ,input  round-base
            ,output buf_price-doc-forming-gds.price-sale-base
            ,output buf_price-doc-forming-gds.price-sale-doc
            ,output buf_price-doc-forming-gds.price-sale-rubl
            ) no-error .
              if error-status:error then
                 return error.
      end.
    end.
    else
      assign
        buf_price-doc-forming-gds.road-tax-doc   = decimal  (buf_price-doc-forming-gds.road-tax-doc   :screen-value in browse br-alt)
        buf_price-doc-forming-gds.excise-doc     = decimal  (buf_price-doc-forming-gds.excise-doc     :screen-value in browse br-alt)
        .
  end.
end procedure.
