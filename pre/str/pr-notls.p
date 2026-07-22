block-level on error undo, throw.
define input param d-num like ub.price-doc.doc-num no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-notls.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pr-notls.p $":U .
define variable vss-description as character no-undo init "проверка, что ни одна из старых цен в переоценке не потеряна".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.price-list.b-code     no-undo.
define buffer main-list      for ub.price-list.
define buffer sub-list       for ub.price-list.
define buffer old-list       for ub.price-list.
define buffer temp-price-doc for ub.price-doc.
define buffer buf_bar-code   for ub.bar-code  .
define buffer buf_parts      for ub.parts  .
define buffer buf_goods      for ub.goods  .
define variable v-str1        as character  no-undo .
define variable par-pr-notls  as character  no-undo .
define variable par-pr-dscnt  as character  no-undo .
define variable par-pr-equ-dq as integer    no-undo .
define variable ok-dscnt      as logical    no-undo .
find first temp-price-doc where temp-price-doc.doc-num =  d-num no-lock .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input temp-price-doc.obj-type
  ,input temp-price-doc.obj-code
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
    if thbjattr_thbj-attr.prop-code = 'pr-dscnt':U  then par-pr-dscnt  =  string( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-notls':U  then par-pr-notls  =  string( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-equ-dq':U then par-pr-equ-dq =  thbjattr_thbj-attr.property-value-integer .
end.
if par-pr-notls <> "yes" then
  return.
ok-dscnt = false  .
for each main-list where
         main-list.doc-num    = d-num and
         main-list.main-price = yes:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  main-list.obj-type
  ,input  main-list.obj-code
  ,input  main-list.b-code
  ,input  0
  ,input  0
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
      error-status :get-message(1)
      "Ошибка поиска цены главного кода "
      .
      return.
    end.
  for each  old-list no-lock where
            old-list.doc-num    = gp-doc-num and
            old-list.artic      = main-list.artic and
            old-list.prod-type  = main-list.prod-type and
            old-list.prod-code  = main-list.prod-code and
            old-list.main-price = no:
    find sub-list where
         sub-list.doc-num = d-num and
         sub-list.b-code  = old-list.b-code and
         sub-list.price-type = "" no-error.
    if not available sub-list then do:
      if par-pr-equ-dq = 1  then do:
         find first buf_bar-code no-lock where
                    buf_bar-code.b-code = old-list.b-code and
                    buf_bar-code.in-code <> "" no-error .
         find first buf_parts no-lock where
              buf_parts.out-code  = 'free-zone':U and
              buf_parts.rsrv-free = true  and
              buf_parts.status_   = false and
              buf_parts.obj-type  = main-list.obj-type and
              buf_parts.obj-code  = main-list.obj-code and
              buf_parts.artic     = old-list.artic and
              buf_parts.prod-type = old-list.prod-type and
              buf_parts.prod-code = old-list.prod-code and
              buf_parts.in-code   = buf_bar-code.in-code and
              buf_parts.part-code = buf_bar-code.part-code
              no-error .
      if available buf_bar-code then do:
         if buf_bar-code.in-code <> "" and not available buf_parts then next.
      end.
      message
        "Потеряна по крайней мере одна существующая цена," skip
        "что запрещено настройкой pr-notls." skip (2)
        "Код:" old-list.b-code skip
        "Номер предыдущей переоценки:" gp-doc-num
        view-as alert-box error.
      return error.
      end.
      else next.
    end.
    if par-pr-dscnt = "yes" then do:
          if not ok-dscnt and
            sub-list.d-pcnt <> old-list.d-pcnt then do:
              find first buf_goods no-lock where
                          buf_goods.artic     = sub-list.artic     and
                          buf_goods.prod-type = sub-list.prod-type and
                          buf_goods.prod-code = sub-list.prod-code no-error .
                v-str1 = substitute("Переоценка. Изменилась по крайней мере одна скидка&4 Товар &5 &6&4 Код: &1&4 Старая скидка: &2 % (переоценка &7)&4 Новая скидка: &3 %" ,
                                      old-list.b-code,
                                      old-list.d-pcnt,
                                      sub-list.d-pcnt,
                                      chr(10),
                                      buf_goods.artic,
                                      buf_goods.gds-name,
                                      old-list.doc-num
                                      ).
                message
                   v-str1 skip (2)
                  "Продолжать?"
                  view-as alert-box question buttons OK-Cancel update ok-dscnt.
              if not ok-dscnt then
                return error v-str1.
          end.
    end.
  end.
end.
