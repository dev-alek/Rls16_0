block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo.
define input  parameter p-handle      as handle no-undo.
define input  parameter p-trn-code    like ub.trn-doc.doc-code no-undo.
define input  parameter p-null        as logical   no-undo .
define input  parameter p-mess-neg    as logical   no-undo .
define variable  vss-revision    as character no-undo init "$Revision: 5baf537283c9, 2487, rls $":U .
define variable  vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable  vss-date        as character no-undo init "$Date: Пт июн 26 16:47:04 2020 +0300 $":U .
define variable  vss-workfile    as character no-undo init "$Workfile: rv-out.p $":U .
define variable  vss-archive     as character no-undo init "$Archive: str/rv-out.p $":U .
define variable  vss-description as character no-undo init "Переведение запроса в накладную с резервированием товара".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
define variable chg-qnty       like ub.gds-dtl.doc-qnty no-undo.
define variable v-today        as   date             no-undo.
define variable varconf-attr   as   character        no-undo.
define variable varpar-type    as   character        no-undo.
define variable v-is-parts as logical   no-undo .
define buffer t-doc for ub.trn-doc.
define buffer n-d for ub.trn-doc.
define buffer n-l for ub.doc-line.
define buffer n-g for ub.gds-dtl.
define buffer buf_bar-code for ub.bar-code  .
if v-cntxt-db-num <> v-cntxt-db-num-obj then do:
  message "На пассивной стороне резервирование невозможно.".
  return error.
end.
find t-doc where t-doc.doc-code = p-trn-code.
if not (can-do ('спи,возврат':U, t-doc.doc-type) and not t-doc.internal or t-doc.doc-type = 'рас':U) then do:
  message "Документ №" t-doc.doc-code skip
                  "По документу данного типа резервирование невозможно.".
  return error.
end.
if t-doc.status_ <> 'запрос':U then do:
  message "Документ №" t-doc.doc-code skip
                  "По документу с данным статусом резервирование невозможно.".
  return error.
end.
req1:
do on stop undo req1, return error on error undo req1, return error :
  assign
    t-doc.status_ = 'накл':U
    t-doc.flag_ = no.
  create n-d.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
  run doc-code in this-procedure
  (input  "chip",
   input  v-cntxt-obj-type,
   input  v-cntxt-obj-code,
   input  t-doc.doc-code,
   output n-d.doc-code ) no-error.
  if error-status:error then do:
    message "Ошибка при генерации номера документа." return-value
    view-as alert-box error.
    undo req1, return error.
  end.
  buffer-copy t-doc except doc-code acc-date creid to n-d
  assign
    n-d.status_    = 'запрос':U
    n-d.flag_      = no
    n-d.rsrv-date  = today + v-cntxp-rsrv-time
    n-d.doc-qnty   = 0
    n-d.fact-base  = 0
    n-d.fact-num   = 0
    n-d.fact-qnty  = 0
    n-d.fact-rubl  = 0
    n-d.tot-cli    = 0
    n-d.tot-doc    = 0
    n-d.tot-fact   = 0
    n-d.tot-ov     = 0
    n-d.tot-rubl   = 0
    n-d.tot-sale   = 0
    n-d.PS = "@  Остаток от резервирования по документу : " + t-doc.doc-code + chr (10) +
                  "Для расчета итогов по документу нажмите Измен.".
  for each ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code
       on stop undo req1, return error on error undo req1, return error :
    create n-l.
    buffer-copy ub.doc-line to n-l
    assign
      n-l.doc-code  = n-d.doc-code
      n-l.doc-qnty  = 0
      n-l.cli-qnty  = 0
      n-l.fact-qnty = 0
      .
    find ub.goods where ub.goods.artic         = ub.doc-line.artic
                      and ub.goods.prod-type = ub.doc-line.prod-type
                      and ub.goods.prod-code = ub.doc-line.prod-code no-lock.
    for each ub.gds-dtl where ub.gds-dtl.doc-code  = t-doc.doc-code
                       and ub.gds-dtl.prod-code = ub.doc-line.prod-code
                       and ub.gds-dtl.prod-type = ub.doc-line.prod-type
                       and ub.gds-dtl.artic     = ub.doc-line.artic
         on stop undo req1, return error on error undo req1, return error :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(gds-dtl)
  , input no
  , input ?
  ) no-error.
      if error-status:error then do:
         undo req1, return error return-value .
      end.
      if ub.gds-dtl.price-base = ? or ub.gds-dtl.price-base = 0  THEN DO:
          FIND FIRST ub.gds-prt WHERE ub.gds-prt.node-code = ub.gds-dtl.prt-code NO-LOCK.
          FIND FIRST ub.goods WHERE ub.goods.artic = ub.gds-dtl.artic
                             AND ub.goods.prod-code = ub.gds-dtl.prod-code
                             AND ub.goods.prod-type = ub.gds-dtl.prod-type NO-LOCK.
          FIND FIRST ub.bar-code WHERE ub.bar-code.gds-code  = ub.goods.gds-code
                                AND ub.bar-code.node-code = ub.gds-dtl.prt-code
                                AND ub.bar-code.part-code = ''
                                AND ub.bar-code.in-code   = ''
                                AND ub.bar-code.unit-cli  = ub.goods.unit-base NO-LOCK.
         MESSAGE "Не определена валютная цена товара:" ub.gds-dtl.artic " " (if ub.gds-prt.node-name <> '_Пустая шкала':U and ub.gds-prt.upper-code <> ub.goods.prt-root then ub.goods.gds-name + ' - ' + ub.gds-prt.f-name else ub.goods.gds-name) "." SKIP
                 "Бар-код:" ub.bar-code.b-code
                  VIEW-AS ALERT-BOX ERROR BUTTONS OK.
            undo req1, return ERROR "Не определена валютная цена товара".
      END.
      if ub.gds-dtl.price-rubl = ? or ub.gds-dtl.price-rubl = 0 THEN DO:
          FIND FIRST ub.gds-prt WHERE ub.gds-prt.node-code = ub.gds-dtl.prt-code NO-LOCK.
          FIND FIRST ub.goods WHERE ub.goods.artic = ub.gds-dtl.artic
                             AND ub.goods.prod-code = ub.gds-dtl.prod-code
                             AND ub.goods.prod-type = ub.gds-dtl.prod-type NO-LOCK.
          FIND FIRST ub.bar-code WHERE ub.bar-code.gds-code  = ub.goods.gds-code
                            AND ub.bar-code.node-code = ub.gds-dtl.prt-code
                            AND ub.bar-code.part-code = ''
                            AND ub.bar-code.in-code   = ''
                            AND ub.bar-code.unit-cli  = ub.goods.unit-base NO-LOCK.
         MESSAGE "Не определена рублевая цена товара:" ub.gds-dtl.artic " " (if ub.gds-prt.node-name <> '_Пустая шкала':U and ub.gds-prt.upper-code <> ub.goods.prt-root then ub.goods.gds-name + ' - ' + ub.gds-prt.f-name else ub.goods.gds-name) "." SKIP
                 "Бар-код:" ub.bar-code.b-code
            VIEW-AS ALERT-BOX ERROR BUTTONS OK.
            undo req1, return ERROR "Не определена рублевая цена товара".
      END.
      accumulate ub.gds-dtl.doc-qnty (total).
      assign
        chg-qnty = ub.gds-dtl.doc-qnty
        .
      v-is-parts = false .
      define variable v-sumq as decimal   no-undo .
      define buffer free_parts for ub.parts  .
      v-sumq = 0.
      for each ub.doc-prts no-lock where
               ub.doc-prts.out-code  = p-trn-code and
               ub.doc-prts.gds-code  = ub.goods.gds-code ,
      first buf_bar-code no-lock where
                 buf_bar-code.b-code = ub.doc-prts.b-code ,
      first free_parts no-lock where
                 free_parts.obj-type  = t-doc.obj-type and
                 free_parts.obj-code  = t-doc.obj-code and
                 free_parts.artic     = ub.goods.artic and
                 free_parts.prod-type = ub.goods.prod-type and
                 free_parts.prod-code = ub.goods.prod-code and
                 free_parts.in-code   = buf_bar-code.in-code  and
                 free_parts.out-code  = 'free-zone':U  and
                 free_parts.part-code = buf_bar-code.part-code :
      v-is-parts = true  .
      chg-qnty = free_parts.qnty .
      run trg/rsrv-dtl.p (
          input parparentproc,
          ( 'reserv':U
              + ",":U + 'rsrv-single-part':U
              + ",":U + 'rsrv-in-code':U   + "=":U + str-encode ( buf_bar-code.in-code  ,  "", ",=":U )
              + ",":U + 'rsrv-part-code':U + "=":U + str-encode ( buf_bar-code.part-code,  "", ",=":U )
              + ( if p-mess-neg then "" else
                  ",":U + 'negative-check':U + "=1":U )
          ),
          buffer ub.gds-dtl,
          input-output chg-qnty,
          input-output ub.doc-line.price-base,
          input-output ub.doc-line.price-rubl,
          -1, "")
          no-error.
          v-sumq = v-sumq + chg-qnty .
          for each ub.parts exclusive-lock where
                 ( ub.parts.out-code     = t-doc.doc-code and
                   ub.parts.obj-type     = t-doc.obj-type and
                   ub.parts.obj-code     = t-doc.obj-code and
                   ub.parts.artic        = ub.gds-dtl.artic and
                   ub.parts.prod-type    = ub.gds-dtl.prod-type and
                   ub.parts.prod-code    = ub.gds-dtl.prod-code and
                   ub.parts.in-code      = buf_bar-code.in-code  and
                   ub.parts.part-code    = buf_bar-code.part-code ) or
                 ( ub.parts.out-code     = 'out-zone':U and
                   ub.parts.obj-type     = t-doc.obj-type and
                   ub.parts.obj-code     = t-doc.obj-code and
                   ub.parts.artic        = ub.gds-dtl.artic and
                   ub.parts.prod-type    = ub.gds-dtl.prod-type and
                   ub.parts.prod-code    = ub.gds-dtl.prod-code and
                   ub.parts.in-code      = buf_bar-code.in-code  and
                   ub.parts.part-code    = buf_bar-code.part-code )
                   :
                  if ub.parts.defect <> ub.doc-prts.defect then do:
                      assign
                        ub.parts.defect = ub.doc-prts.defect
                      .
                  end.
         end.
         chg-qnty = v-sumq .
       end.
      if v-is-parts = false  then do:
      run trg/rsrv-dtl.p (
          input parparentproc,
          'reserv':U
        + ( if p-mess-neg then "" else
            ",":U + 'negative-check':U + "=1":U )
          ,
          buffer ub.gds-dtl,
          input-output chg-qnty,
          input-output ub.doc-line.price-base,
          input-output ub.doc-line.price-rubl,
          -1, "")
          no-error.
      end.
      if error-status:error then do:
        undo req1, return error substitute("При резервировании из rsrv-dtl.p: &1 &2" , return-value , error-status :get-message(1)  ) .
      end.
      assign
        chg-qnty = ub.gds-dtl.doc-qnty  - chg-qnty.
      assign
        ub.doc-line.doc-qnty  = ub.doc-line.doc-qnty - chg-qnty
        ub.gds-dtl.doc-qnty   = ub.gds-dtl.doc-qnty  - chg-qnty
        ub.gds-dtl.fact-qnty  = ub.gds-dtl.doc-qnty
        ub.doc-line.fact-qnty = ub.doc-line.doc-qnty.
      accumulate ub.gds-dtl.fact-qnty (total).
      if chg-qnty <> 0 then do:
        create n-g.
        buffer-copy ub.gds-dtl to n-g
        assign
          n-g.doc-code = n-d.doc-code
          n-g.doc-qnty = chg-qnty
          n-g.fact-qnty = n-g.doc-qnty.
        assign
          n-l.doc-qnty  = n-l.doc-qnty + n-g.doc-qnty
          n-l.fact-qnty  = n-l.doc-qnty
          n-d.doc-qnty = n-d.doc-qnty + n-g.doc-qnty
          n-d.fact-qnty = n-d.doc-qnty
          t-doc.doc-qnty = t-doc.doc-qnty - n-g.doc-qnty.
      end.
      if ub.gds-dtl.doc-qnty = 0 then delete ub.gds-dtl.
    end.
  end.
  if p-null <> true then do:
      if (accum total ub.gds-dtl.fact-qnty) = 0 then do:
        message "Документ :" t-doc.doc-code skip (2)
                        "НЕ УДАЛОСЬ зарезервировать ничего !".
        undo req1, return error.
      end.
  end.
  if (accum total ub.gds-dtl.doc-qnty) <> (accum total ub.gds-dtl.fact-qnty) then do:
define variable v-mess as character no-undo .
define variable v-is-rt as logical   no-undo .
define variable v-uh as handle no-undo .
  v-mess  =  substitute("Документ : &2&1&1 НЕ ВСЕ количество УДАЛОСЬ зарезервировать ! &1&1 Было количество в запросе : &3&1 Удалось зарезервировать : &4 &1 &1  Остальное помещено в новый запрос : &5 " ,
           chr(10)  ,
           t-doc.doc-code ,
           (accum total ub.gds-dtl.doc-qnty) ,
           (accum total ub.gds-dtl.fact-qnty) ,
           n-d.doc-code )
            .
  assign
  v-uh = this-procedure:instantiating-procedure
  v-is-rt = false
  .
  do while valid-handle(v-uh):
    if lookup("w-reqsrv_print-log", v-uh:internal-entries) > 0 then do:
      v-is-rt = true .
      run cb-for-struct-i in v-uh ( input v-mess ) no-error.
      leave.
    end.
    v-uh = v-uh:instantiating-procedure.
  end.
  if v-is-rt = false then do:
     message v-mess view-as alert-box information .
  end.
    if substr (t-doc.PS, 1, 1) = "@" then
      t-doc.PS = "@  ЧАСТИЧНОЕ резервирование по запросу.  Остаток - в новом запросе : " + n-d.doc-code.
    n-d.out-code = t-doc.doc-code.
    run cus/oo-mkrcv.p (
         buffer t-doc ,
         buffer n-d  )
        no-error .
        if error-status:error then do:
          undo req1, return error.
        end.
  end.
  else delete n-d.
end.
