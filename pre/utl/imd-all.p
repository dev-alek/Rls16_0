block-level on error undo, throw.
define input  parameter parparentproc as handle              no-undo.
define input  parameter InputMode     as char                no-undo.
define input  parameter frame-title   as char                no-undo.
define input  parameter dfc-recid      as recid no-undo .
define input  parameter e-code        like ub.trn-doc.exch-code no-undo.
define input  parameter pardoc-code   like ub.trn-doc.doc-code  no-undo.
define input  parameter parcli-type   like ub.trn-doc.cli-type  no-undo.
define input  parameter parcli-code   like ub.trn-doc.cli-code  no-undo.
define input  parameter parhost-code  like ub.trn-doc.host-code no-undo.
define output parameter count-upd     as int init 0          no-undo.
define output parameter counter       as int init 0          no-undo.
define output parameter count-all     as int init 0          no-undo.
define variable vss-revision    as character no-undo initial "$Revision: f5e72f13272f, 2363, rls $":U .
define variable vss-author      as character no-undo initial "$Author: druban $":U .
define variable vss-date        as character no-undo initial "$Date: Ср июн 10 21:13:42 2020 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: imd-all.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/imd-all.p $":U .
define variable vss-description as character no-undo initial "Драйвер импорта из внешнего текстового файла любой информации".
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
function is-numeral return logical
  (input p-string   as character ,
   input char-avail as character) :
  define variable p-replace-string as character no-undo .
  define variable log-result       as logical  no-undo .
  if p-string = ? then
    return false .
  p-replace-string = p-string.
  if lookup ("*", char-avail) > 0 then
      p-replace-string = replace (p-replace-string, '*', '9').
  if lookup ("digit", char-avail) > 0 then
    assign
      p-replace-string = replace (p-replace-string, '0', '9')
      p-replace-string = replace (p-replace-string, '1', '9')
      p-replace-string = replace (p-replace-string, '2', '9')
      p-replace-string = replace (p-replace-string, '3', '9')
      p-replace-string = replace (p-replace-string, '4', '9')
      p-replace-string = replace (p-replace-string, '5', '9')
      p-replace-string = replace (p-replace-string, '6', '9')
      p-replace-string = replace (p-replace-string, '7', '9')
      p-replace-string = replace (p-replace-string, '8', '9')
      .
  else
     p-replace-string = replace (p-replace-string, '9', chr(15))
      .
  if lookup ("letter", char-avail) > 0 then
    assign
      p-replace-string = replace (p-replace-string, 'A', '9')
      p-replace-string = replace (p-replace-string, 'B', '9')
      p-replace-string = replace (p-replace-string, 'C', '9')
      p-replace-string = replace (p-replace-string, 'D', '9')
      p-replace-string = replace (p-replace-string, 'E', '9')
      p-replace-string = replace (p-replace-string, 'F', '9')
      p-replace-string = replace (p-replace-string, 'G', '9')
      p-replace-string = replace (p-replace-string, 'H', '9')
      p-replace-string = replace (p-replace-string, 'I', '9')
      p-replace-string = replace (p-replace-string, 'J', '9')
      p-replace-string = replace (p-replace-string, 'K', '9')
      p-replace-string = replace (p-replace-string, 'L', '9')
      p-replace-string = replace (p-replace-string, 'M', '9')
      p-replace-string = replace (p-replace-string, 'N', '9')
      p-replace-string = replace (p-replace-string, 'O', '9')
      p-replace-string = replace (p-replace-string, 'P', '9')
      p-replace-string = replace (p-replace-string, 'Q', '9')
      p-replace-string = replace (p-replace-string, 'R', '9')
      p-replace-string = replace (p-replace-string, 'S', '9')
      p-replace-string = replace (p-replace-string, 'T', '9')
      p-replace-string = replace (p-replace-string, 'U', '9')
      p-replace-string = replace (p-replace-string, 'V', '9')
      p-replace-string = replace (p-replace-string, 'W', '9')
      p-replace-string = replace (p-replace-string, 'X', '9')
      p-replace-string = replace (p-replace-string, 'Y', '9')
      p-replace-string = replace (p-replace-string, 'Z', '9')
      p-replace-string = replace (p-replace-string, '_', '9')
      .
  return p-replace-string = fill ('9', length (p-string)).
end.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define new global shared variable g#libbcrcn as handle no-undo .
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
DEFINE BUFFER buf_price-doc-forming FOR ub.price-doc-forming.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info24 as character format "X(65)" no-undo
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
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
if v-base = false then var-pr-r-b = "rubl":U .
                  else var-pr-r-b =  "base":U .
for each  x_obj-group :
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable var-pr-r-b as character no-undo .
define variable v-str2 as character no-undo .
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-pr-r-b
  )  .
function f-base-code return integer ( p-b-code as integer ).
  define variable main-b-code as integer   no-undo .
  define buffer buf_bar-code for ub.bar-code  .
  find first buf_bar-code no-lock where
            buf_bar-code.b-code = p-b-code no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  ?
  ,output main-b-code
  )  .
  return (main-b-code).
end function.
function fnc-cost-pc return decimal (buffer local-price-list for ub.price-doc-forming-gds ).
  define variable f-cost     as decimal no-undo .
  define variable f-cost-pc  as decimal no-undo .
  define variable v-qnty     as decimal no-undo .
  define variable v-sum      as decimal no-undo .
  define variable fact_price as decimal no-undo .
  find first ub.goods where ub.goods.artic     = local-price-list.artic and
                            ub.goods.prod-type = local-price-list.prod-type and
                            ub.goods.prod-code = local-price-list.prod-code no-lock
                            no-error .
  assign
    v-sum  =  0
    v-qnty =  0
    .
  for each x_obj-group :
      find ub.gds-obj no-lock where
          ub.gds-obj.gds-code = ub.goods.gds-code and
          ub.gds-obj.obj-type = x_obj-group.obj-type and
          ub.gds-obj.obj-code = x_obj-group.obj-code no-error.
      if  available ub.gds-obj then
        if ub.goods.gds-type = 'т':U then
          assign
            v-sum  = v-sum  + ( if var-pr-r-b = "rubl" then ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base) * ub.gds-obj.avrg-qnty
            v-qnty =  v-qnty + ub.gds-obj.avrg-qnty
            .
          else  v-sum = ?.
      else v-sum = ?.
  end.
  f-cost = v-sum / v-qnty .
  fact_price = if var-pr-r-b = "rubl" then local-price-list.price-sale-rubl else local-price-list.price-sale-base .
  f-cost-pc = ( round ( fact_price / f-cost , 2 ) -  1 ) * 100.
  return (f-cost-pc).
end function.
function fnc-pr-pc return decimal (buffer local-price-list for ub.price-doc-forming-gds ).
define variable f-pr     as decimal no-undo .
define variable f-pr-pc  as decimal no-undo.
define variable v-qnty as decimal   no-undo .
define variable v-sum as decimal   no-undo .
define variable fact_price as decimal   no-undo .
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
 assign
   v-sum  =  0
   v-qnty =  0
   .
for each x_obj-group :
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = x_obj-group.obj-type and
     ub.gds-obj.obj-code = x_obj-group.obj-code  no-error .
if  available ub.gds-obj then do:
  if ub.goods.gds-type = 'т':U then
    assign
      f-pr = (if var-pr-r-b = "rubl" then ub.gds-obj.last-rubl else ub.gds-obj.last-base)
      .
    else f-pr = ?.
end.
else f-pr = ?.
end.
  fact_price = if var-pr-r-b = "rubl" then local-price-list.price-sale-rubl else local-price-list.price-sale-base .
  f-pr-pc = ( round( fact_price / f-pr , 2 ) - 1 ) * 100 .
  return (f-pr-pc).
end function.
function fnc-cost return decimal (buffer local-price-list for ub.price-doc-forming-gds).
define variable f-cost   as decimal no-undo .
find first  x_obj-group.
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code  and
     ub.gds-obj.obj-type = x_obj-group.obj-type and
     ub.gds-obj.obj-code = x_obj-group.obj-code
     no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = 'т':U then
    assign
      f-cost = if var-pr-r-b = "rubl" then ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base
      .
    else  f-cost = ?.
else f-cost = ?.
  return ( f-cost ).
end function.
function fnc-pr return decimal (buffer local-price-list for ub.price-doc-forming-gds).
define variable f-pr   as decimal no-undo .
find first x_obj-group .
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = x_obj-group.obj-type and
     ub.gds-obj.obj-code = x_obj-group.obj-code
     no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = 'т':U then
    assign
      f-pr = if var-pr-r-b = "rubl" then ub.gds-obj.last-rubl  else ub.gds-obj.last-base
      .
    else  f-pr = ?.
else f-pr = ?.
   return ( f-pr ).
end function.
procedure make-fact-order-lib3 :
define input  parameter p-recid as recid no-undo .
define output parameter p-fact-order-sys-from as decimal   no-undo .
define output parameter p-fact-order-sys-to   as decimal   no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-list-type for ub.price-list-type  .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable v-fact-order           as decimal no-undo .
  do
  on error undo, return error return-value
  :
find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming ) = p-recid no-error .
  if error-status :error then return error error-status :get-message(1) .
find first buf_price-list-type  no-lock where
           buf_price-list-type.plt-id = buf_price-doc-forming.plt-id and
           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
  if error-status :error then return error error-status :get-message(1) .
 if buf_price-doc-forming.have-start-period = 1 then do:
    case buf_price-list-type.work-date :
      when int('1':U)  then
        do :
           run day-begin-fact-order
                ( buf_price-doc-forming.start-date ,
                 output p-fact-order-sys-from ) no-error .
                 if error-status :error then
                 return error substitute ( "Ошибка из day-begin-fact-order &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
      when int('2':U)   then
        do :
          run factord (
             input   buf_price-doc-forming.start-shift-date
            ,input   buf_price-doc-forming.sys-time
            ,input   1
            ,input   buf_price-doc-forming.start-shift-date
            ,input   buf_price-doc-forming.start-shift-num
            ,input   true
            ,output  p-fact-order-sys-from
            ,output  v-shift-end-fact-order
            ,output  v-day-end-fact-order
            ) no-error  .
            if error-status :error then
                 return error substitute ( "Ошибка из factord &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
      when int('3':U)   then
        do :
          run factord (
            input    buf_price-doc-forming.start-sys-date
            ,input   buf_price-doc-forming.start-sys-time
            ,input   (if buf_price-doc-forming.start-sys-time = 0 or buf_price-doc-forming.start-sys-time = ? then 1 else buf_price-doc-forming.start-sys-time )
            ,input   ?
            ,input   ?
            ,input   false
            ,output  p-fact-order-sys-from
            ,output  v-shift-end-fact-order
            ,output  v-day-end-fact-order
            ) no-error .
            if error-status :error then
                 return error substitute ( "Ошибка из factord  - дата сервера &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
    end case.
  end.
 if buf_price-doc-forming.have-end-period = 1 then do:
    case buf_price-list-type.work-date :
      when int('1':U)   then
        do :
           run factord-end-day
              ( buf_price-doc-forming.end-date ,
                output p-fact-order-sys-to ) no-error .
                if error-status :error then
                 return error substitute ( "Ошибка из factord-end-day дата на объекте на конец периода &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
      when int('2':U)   then
        do :
          run factord (
             input   buf_price-doc-forming.end-shift-date
            ,input   buf_price-doc-forming.sys-time
            ,input   1
            ,input   buf_price-doc-forming.end-shift-date
            ,input   buf_price-doc-forming.end-shift-num
            ,input   true
            ,output  v-fact-order
            ,output  p-fact-order-sys-to
            ,output  v-day-end-fact-order
            ) no-error .
            if error-status :error then
              return error substitute ( "Ошибка из factord сменная дата на конец &1 &2" ,
                                        error-status :get-message(1) ,
                                        return-value ).
        end.
      when int('3':U)   then
        do :
          run factord (
             input   buf_price-doc-forming.end-sys-date
            ,input   buf_price-doc-forming.end-sys-time
            ,input   (if buf_price-doc-forming.end-sys-time  = 0 or buf_price-doc-forming.end-sys-time = ? then 1 else buf_price-doc-forming.end-sys-time )
            ,input   ?
            ,input   ?
            ,input   false
            ,output  p-fact-order-sys-to
            ,output  v-shift-end-fact-order
            ,output  v-day-end-fact-order
            ) no-error .
            if error-status :error then
              return error substitute ( "Ошибка из factord  - дата сервера &1 &2" ,
                                        error-status :get-message(1) ,
                                        return-value ).
        end.
    end case.
  end.
  end.
end procedure.
procedure ver-dfc-mpl-lib3 :
define input  parameter p-recid as recid no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-list-type for ub.price-list-type  .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .
define buffer buf_price-doc-sum  for ub.price-doc-forming-gds-sum  .
define buffer buf_price-doc-forming-gds-tnv  for ub.price-doc-forming-gds-tnv  .
define variable v-fact-order-sys-from   as decimal   no-undo .
define variable v-fact-order-sys-to     as decimal   no-undo .
  do
  on error undo, return error return-value
 :
find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming ) = p-recid no-error .
  if error-status :error then return error error-status :get-message(1) .
find first buf_price-list-type  no-lock where
           buf_price-list-type.plt-id = buf_price-doc-forming.plt-id and
           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
  if error-status :error then return error error-status :get-message(1) .
  if buf_price-list-type.stts = integer('1':U) then do:
     return error substitute(" ТПЛ &1 в статусе УДАЛЕН ! Закрывать с ним новые ДНЦ нельзя !" , buf_price-list-type.name )  .
  end.
  if buf_price-list-type.bgr-id > 0 then do:
      find ub.buyer-group where
            ub.buyer-group.stts       = 0  and
            ub.buyer-group.bgr-db-num = buf_price-list-type.bgr-db-num and
            ub.buyer-group.bgr-id     = buf_price-list-type.bgr-id
            no-lock no-error .
      if not available ub.buyer-group then
      return error substitute(" ТПЛ &1 содержит некорректную группу по покупателям &2(&3) !" , buf_price-list-type.name,buf_price-list-type.bgr-id,buf_price-list-type.bgr-db-num )  .
  end.
  if buf_price-list-type.sgr-id > 0 then do:
      find ub.sum-group where
            ub.sum-group.stts       = 0  and
            ub.sum-group.sgr-db-num = buf_price-list-type.sgr-db-num and
            ub.sum-group.sgr-id     = buf_price-list-type.sgr-id
            no-lock no-error .
      if not available ub.sum-group then
      return error substitute(" ТПЛ &1 содержит некорректную суммовую группу &2(&3) !" , buf_price-list-type.name,buf_price-list-type.sgr-id,buf_price-list-type.sgr-db-num )  .
  end.
  if buf_price-list-type.qgr-id > 0 then do:
      find ub.qnty-group where
           ub.qnty-group.stts       = 0  and
           ub.qnty-group.qgr-db-num = buf_price-list-type.qgr-db-num and
           ub.qnty-group.qgr-id     = buf_price-list-type.qgr-id
           no-lock no-error .
      if not available ub.qnty-group then
      return error substitute(" ТПЛ &1 содержит некорректную количественную группу &2(&3) !" , buf_price-list-type.name,buf_price-list-type.qgr-id,buf_price-list-type.qgr-db-num )  .
  end.
  if buf_price-list-type.tog-id > 0 then do:
      find ub.turnover-group where
           ub.turnover-group.stts       = 0  and
           ub.turnover-group.tog-db-num = buf_price-list-type.tog-db-num and
           ub.turnover-group.tog-id     = buf_price-list-type.tog-id
          no-lock no-error .
      if not available ub.turnover-group then
      return error substitute(" ТПЛ &1 содержит некорректную группу по оборотам &2(&3) !" , buf_price-list-type.name , buf_price-list-type.tog-id , buf_price-list-type.tog-db-num )  .
  end.
  if buf_price-list-type.gop-id > 0 then do:
      find ub.grp-obj-price where
            ub.grp-obj-price.stts       = 0  and
            ub.grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num and
            ub.grp-obj-price.gop-id     = buf_price-list-type.gop-id
            no-lock no-error .
      if not available ub.grp-obj-price then
      return error substitute(" ТПЛ &1 содержит некорректную группу по объектам &2(&3) !" , buf_price-list-type.name,buf_price-list-type.gop-id,buf_price-list-type.gop-db-num )  .
  end.
  if buf_price-list-type.gop-id-for-calc-turnover > 0 then do:
      find ub.grp-obj-price where
            ub.grp-obj-price.stts       = 0  and
            ub.grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num-for-calc-turnover and
            ub.grp-obj-price.gop-id     = buf_price-list-type.gop-id-for-calc-turnover
            no-lock no-error .
      if not available ub.grp-obj-price then
      return error substitute(" ТПЛ &1 содержит некорректную группу по объектам &2(&3) !" , buf_price-list-type.name,buf_price-list-type.gop-id-for-calc-turnover,buf_price-list-type.gop-db-num-for-calc-turnover )  .
  end.
   if buf_price-doc-forming.have-start-period = integer(true) then do:
      case buf_price-list-type.work-date :
          when int('1':U)     then
            do :
               if buf_price-doc-forming.start-date = ? then return error "Не задана дата начала действия цен !" .
            end.
          when int('2':U)   then
            do :
                if buf_price-doc-forming.start-shift-date = ? then return error "Не задана сменная дата начала действия цен !" .
                if buf_price-doc-forming.start-shift-num  = ? or
                   buf_price-doc-forming.start-shift-num = 0  then return error "Не задан порядок смены начала действия цен !" .
            end.
          when int('3':U)     then
            do :
                if buf_price-doc-forming.start-sys-date = ? then return error "Не задана дата начала действия цен !" .
                if buf_price-doc-forming.start-sys-time = ? then return error "Не задано время начала действия цен !" .
            end.
      end case.
   end.
   if buf_price-doc-forming.have-end-period = integer(true) then do:
      case buf_price-list-type.work-date :
          when int('1':U)     then
            do :
               if buf_price-doc-forming.end-date = ? then return error "Не задана дата окончания действия цен !" .
            end.
          when int('2':U)   then
            do :
                if buf_price-doc-forming.end-shift-date = ? then return error "Не задана сменная дата окончания действия цен !" .
                if buf_price-doc-forming.end-shift-num  = ? or
                   buf_price-doc-forming.end-shift-num = 0  then return error "Не задан порядок смены окончания  действия цен !" .
            end.
          when int('3':U)     then
            do :
                if buf_price-doc-forming.end-sys-date = ? then return error "Не задана дата окончания действия цен !" .
                if buf_price-doc-forming.end-sys-time = ? then return error "Не задано время окончания действия цен !" .
            end.
      end case.
   end.
   if buf_price-doc-forming.have-start-period = integer(true) and
      buf_price-doc-forming.have-end-period = integer(true) then do:
      case buf_price-list-type.work-date :
          when int('1':U)     then
            do :
               if buf_price-doc-forming.end-date < buf_price-doc-forming.start-date then return error "Не верно задан интервал дат !" .
            end.
          when int('2':U)   then
            do :
                if buf_price-doc-forming.end-shift-date < buf_price-doc-forming.start-shift-date then return error "Не верно задан интервал дат !" .
                if buf_price-doc-forming.end-shift-date = buf_price-doc-forming.start-shift-date then do:
                   if buf_price-doc-forming.end-shift-num < buf_price-doc-forming.start-shift-num then return error "Не верно задан интервал смен !" .
                end.
            end.
          when int('3':U)     then
            do :
                if buf_price-doc-forming.end-sys-date < buf_price-doc-forming.start-sys-date then return error "Не верно задан интервал дат !" .
                if buf_price-doc-forming.end-sys-date = buf_price-doc-forming.start-sys-date then do:
                   if buf_price-doc-forming.end-sys-time < buf_price-doc-forming.start-sys-time then return error "Не верно задан интервал времени !" .
                end.
            end.
      end case.
   end.
if buf_price-doc-forming.name = "" then return error "Не задано название ДНЦ !" .
if buf_price-list-type.main = false then do:
    run make-fact-order-lib3 in this-procedure
        ( input  p-recid ,
          output v-fact-order-sys-from ,
          output v-fact-order-sys-to   ) .
end.
define variable old-price as decimal   no-undo .
define variable v-kol-rec as integer   no-undo .
define variable v-gds-null-price as character no-undo initial "" .
define variable v-type as character no-undo .
v-kol-rec = 0.
for each buf_price-doc-forming-gds no-lock where
         buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
         buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
         buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
         buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      :
    find first ub.bar-code no-lock where
               ub.bar-code.b-code = buf_price-doc-forming-gds.b-code no-error .
               if error-status :error then return error substitute ("Не найден бар-код &1" ,  buf_price-doc-forming-gds.b-code ) .
    find first ub.goods no-lock where
               ub.goods.artic = buf_price-doc-forming-gds.artic         and
               ub.goods.prod-type = buf_price-doc-forming-gds.prod-type and
               ub.goods.prod-code = buf_price-doc-forming-gds.prod-code no-error .
               if error-status :error then return error substitute ("Не найден товар &1 &2 &3" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code) .
    if ub.bar-code.gds-code <> ub.goods.gds-code then return error substitute ("Бар-код &4 не соответствует товару &1 &2 &3" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.b-code ) .
    run gds-attr-value in this-procedure (input ub.goods.gds-code
                                         ,input 'null-price':U
                                         ,output v-gds-null-price
                                         ,output v-type ) no-error .
    if buf_price-doc-forming-gds.price-sale-doc   = ? or (buf_price-doc-forming-gds.price-sale-doc   = 0 and not logical(v-gds-null-price) )
                then return error substitute ("Продажная цена по товару &1 &2 &3 = &4" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.price-sale-doc  ) .
    if buf_price-doc-forming-gds.price-sale-rubl  = ? or (buf_price-doc-forming-gds.price-sale-rubl  = 0 and not logical(v-gds-null-price) )
                then return error substitute ("Продажная цена по товару &1 &2 &3 = &4" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.price-sale-rubl ) .
    if buf_price-doc-forming-gds.price-sale-base  = ? or (buf_price-doc-forming-gds.price-sale-base  = 0 and not logical(v-gds-null-price) )
                then return error substitute ("Продажная цена по товару &1 &2 &3 = &4" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.price-sale-base ) .
    if buf_price-doc-forming-gds.slt-pc = ? then return error substitute ("НсП по товару &1 &2 &3 не определен" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code) .
    if buf_price-doc-forming-gds.vat-pc = ? then return error substitute ("НДС по товару &1 &2 &3 не определен" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code) .
old-price = ? .
  for each buf_price-doc-forming-gds-qnty no-lock where
           buf_price-doc-forming-gds-qnty.plt-id = buf_price-doc-forming-gds.plt-id and
           buf_price-doc-forming-gds-qnty.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
           buf_price-doc-forming-gds-qnty.pdf-id = buf_price-doc-forming-gds.pdf-id and
           buf_price-doc-forming-gds-qnty.pdf-db = buf_price-doc-forming-gds.pdf-db and
           buf_price-doc-forming-gds-qnty.b-code = buf_price-doc-forming-gds.b-code
           by buf_price-doc-forming-gds-qnty.ggr-qnty :
           if old-price < buf_price-doc-forming-gds-qnty.price-sale-doc and old-price <> ? then do:
              return error substitute ("Цена по товару &1 &2 &3 по категории количество покупки >= &4  больше предыдущей категории (&5 и  &6)" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds-qnty.ggr-qnty ,old-price , buf_price-doc-forming-gds-qnty.price-sale-doc) .
           end.
           old-price = buf_price-doc-forming-gds-qnty.price-sale-doc .
  end.
old-price = ? .
  for each buf_price-doc-sum no-lock where
           buf_price-doc-sum.plt-id     = buf_price-doc-forming-gds.plt-id and
           buf_price-doc-sum.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
           buf_price-doc-sum.pdf-id     = buf_price-doc-forming-gds.pdf-id and
           buf_price-doc-sum.pdf-db     = buf_price-doc-forming-gds.pdf-db and
           buf_price-doc-sum.b-code     = buf_price-doc-forming-gds.b-code
           by buf_price-doc-sum.ssg-summa
           :
           if old-price < buf_price-doc-sum.price-sale-doc and old-price <> ? then do:
              return error substitute ("Цена по товару &1 &2 &3 по категории сумма покупки >= &4  больше предыдущей категории (&5 и  &6)" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-sum.ssg-summa , old-price , buf_price-doc-sum.price-sale-doc) .
           end.
           old-price = buf_price-doc-sum.price-sale-doc .
  end.
old-price = ? .
  for each buf_price-doc-forming-gds-tnv no-lock where
           buf_price-doc-forming-gds-tnv.plt-id     = buf_price-doc-forming-gds.plt-id and
           buf_price-doc-forming-gds-tnv.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
           buf_price-doc-forming-gds-tnv.pdf-id     = buf_price-doc-forming-gds.pdf-id and
           buf_price-doc-forming-gds-tnv.pdf-db     = buf_price-doc-forming-gds.pdf-db and
           buf_price-doc-forming-gds-tnv.b-code     = buf_price-doc-forming-gds.b-code
           by buf_price-doc-forming-gds-tnv.ttg-summa :
           if old-price < buf_price-doc-forming-gds-tnv.price-sale-doc and old-price <> ? then do:
              return error substitute ("Цена по товару &1 &2 &3 по категории сумма оборота покупателя >= &4  больше предыдущей категории (&5 и  &6)" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds-tnv.ttg-summa ,old-price , buf_price-doc-forming-gds-tnv.price-sale-doc) .
           end.
           old-price = buf_price-doc-forming-gds-tnv.price-sale-doc .
  end.
  define buffer old_price-doc-forming for ub.price-doc-forming  .
  define buffer old_price-doc-forming-gds for ub.price-doc-forming-gds  .
  define buffer old_price-all for ub.price-all.
  if buf_price-list-type.main = false then do:
     for each old_price-doc-forming no-lock where
              old_price-doc-forming.plt-id     = buf_price-list-type.plt-id     and
              old_price-doc-forming.plt-db-num = buf_price-list-type.plt-db-num and
              old_price-doc-forming.stts       = integer('3':U)  ,
              each old_price-doc-forming-gds no-lock where
                    old_price-doc-forming-gds.plt-id     = buf_price-list-type.plt-id      and
                    old_price-doc-forming-gds.plt-db-num = buf_price-list-type.plt-db-num  and
                    old_price-doc-forming-gds.pdf-id     = old_price-doc-forming.pdf-id    and
                    old_price-doc-forming-gds.pdf-db     = old_price-doc-forming.pdf-db    and
                    old_price-doc-forming-gds.b-code     = buf_price-doc-forming-gds.b-code :
             for each old_price-all no-lock where
                      old_price-all.plt-id     = old_price-doc-forming-gds.plt-id      and
                      old_price-all.plt-db-num = old_price-doc-forming-gds.plt-db-num  and
                      old_price-all.pdf-id     = old_price-doc-forming-gds.pdf-id      and
                      old_price-all.pdf-db     = old_price-doc-forming-gds.pdf-db      and
                      old_price-all.b-code     = old_price-doc-forming-gds.b-code      and
                      old_price-all.fact-order-sys-to   >= v-fact-order-sys-from       and
                      old_price-all.fact-order-sys-from <= v-fact-order-sys-to         :
                     return error substitute ("По товару &1 &2 &3 есть цена &6 в пересекающийся период с таким же приоритетом &7 (ДНЦ &4 &5) " ,
                                               buf_price-doc-forming-gds.artic ,
                                               buf_price-doc-forming-gds.prod-type ,
                                               buf_price-doc-forming-gds.prod-code,
                                               old_price-all.pdf-id ,
                                               old_price-all.pdf-db ,
                                               old_price-doc-forming-gds.price-sale-doc ,
                                               old_price-all.plt-priority
                                               ) .
             end.
     end.
     end.
    assign v-kol-rec = v-kol-rec + 1 .
end.
  run ver-pr-equ-qS in this-procedure
    ( input buf_price-doc-forming.plt-id ,
      input buf_price-doc-forming.plt-db-num,
      input buf_price-doc-forming.pdf-id ,
      input buf_price-doc-forming.pdf-db
      ) no-error .
  if error-status :error then  return error  "Ошибка при удалении строки ДНЦ "   .
if v-kol-rec = 0 then return error "no-records":U.
end.
end procedure.
procedure ver-pr-equ-qS :
define input parameter  p-plt-id      as integer   no-undo .
define input parameter  p-plt-db-num  as integer   no-undo .
define input parameter  p-pdf-id      as integer   no-undo .
define input parameter  p-pdf-db      as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable  l-doc-num2   like ub.price-list.doc-num    no-undo .
define buffer pdf_price-list  for ub.price-doc-forming-gds .
define buffer pp_price-list   for ub.price-doc-forming-gds .
define buffer main_price-list for ub.price-doc-forming-gds .
define buffer alt_price-list  for ub.price-doc-forming-gds .
define buffer buf1-bar-code   for ub.bar-code .
define buffer buf2-bar-code   for ub.bar-code .
define buffer buf_goods for ub.goods  .
define buffer buf2_goods for ub.goods  .
define variable v-num as integer init 0 no-undo .
define variable bbb   as logical no-undo .
define variable l-price-sale like ub.price-list.price-sale no-undo .
define variable l-road-tax   like ub.price-list.road-tax   no-undo .
define variable l-excise     like ub.price-list.excise     no-undo .
define variable l-ok          as logical no-undo .
define variable check-par     as logical no-undo .
define variable main-b-code   as integer no-undo .
define variable par-pr-equ-dq as integer no-undo .
define variable v-price-sale  as decimal no-undo .
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    if thbjattr_thbj-attr.prop-code = 'pr-equ-dq':U then par-pr-equ-dq = thbjattr_thbj-attr.property-value-integer .
end.
if par-pr-equ-dq = 1 then return .
for each pdf_price-list exclusive-lock where
         pdf_price-list.plt-id     = p-plt-id     and
         pdf_price-list.plt-db-num = p-plt-db-num and
         pdf_price-list.pdf-id     = p-pdf-id     and
         pdf_price-list.pdf-db     = p-pdf-db     by pdf_price-list.line-num
        :
    if not (pdf_price-list.b-code     = f-base-code (pdf_price-list.b-code) ) then next .
    check-par = false .
   find first x_obj-group no-error .
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,input  pdf_price-list.b-code
  ,input  0
  ,input  0
  ,output l-doc-num2
  ,output l-price-sale
  ,output l-road-tax
  ,output l-excise
  ) no-error .
    v-price-sale = l-price-sale .
   for each x_obj-group :
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,input  pdf_price-list.b-code
  ,input  0
  ,input  0
  ,output l-doc-num2
  ,output l-price-sale
  ,output l-road-tax
  ,output l-excise
  ) no-error .
    if v-price-sale <> l-price-sale  then do :
      v-price-sale = l-price-sale.
      leave .
    end.
   end.
   find first x_obj-group no-error .
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,input  pdf_price-list.b-code
  ,input  0
  ,input  0
  ,output l-doc-num2
  ,output l-price-sale
  ,output l-road-tax
  ,output l-excise
  ) no-error .
      if l-doc-num2 <> ? then do :
        if l-price-sale = pdf_price-list.price-sale-doc
        and v-price-sale = pdf_price-list.price-sale-doc
        then do:
             find first buf_goods no-lock where
                        buf_goods.artic     =  pdf_price-list.artic and
                        buf_goods.prod-type =  pdf_price-list.prod-type and
                        buf_goods.prod-code =  pdf_price-list.prod-code no-error .
            check-par = false .
               for each pp_price-list no-lock where
                        pp_price-list.plt-id     = p-plt-id     and
                        pp_price-list.plt-db-num = p-plt-db-num and
                        pp_price-list.pdf-id     = p-pdf-id     and
                        pp_price-list.pdf-db     = p-pdf-db     and
                        pp_price-list.artic      = pdf_price-list.artic and
                        pp_price-list.prod-type  = pdf_price-list.prod-type  and
                        pp_price-list.prod-code  = pdf_price-list.prod-code ,
                     first buf1-bar-code no-lock where
                          buf1-bar-code.b-code   = pp_price-list.b-code and
                          buf1-bar-code.unit-cli <> buf_goods.unit-base
                    :
                    if  pp_price-list.b-code = f-base-code (pp_price-list.b-code) then next .
                    check-par = true  .
                    leave.
                end.
               for each pp_price-list no-lock where
                        pp_price-list.plt-id     = p-plt-id     and
                        pp_price-list.plt-db-num = p-plt-db-num and
                        pp_price-list.pdf-id     = p-pdf-id     and
                        pp_price-list.pdf-db     = p-pdf-db     and
                        pp_price-list.artic      = pdf_price-list.artic and
                        pp_price-list.prod-type  = pdf_price-list.prod-type  and
                        pp_price-list.prod-code  = pdf_price-list.prod-code and
                        pp_price-list.price-sale-doc <> pdf_price-list.price-sale-doc  ,
                     first buf1-bar-code no-lock where
                          buf1-bar-code.b-code   = pp_price-list.b-code and
                          buf1-bar-code.unit-cli = buf_goods.unit-base
                    :
                    if  pp_price-list.b-code = f-base-code (pp_price-list.b-code) then next .
                    check-par = true  .
                    leave.
                end.
            if check-par = true then next.
            if par-pr-equ-dq = 2 then do:
                  if  ( v-num <= 2  and check-par = false ) then
                      run gbl/d-askw.w
                        (input "Удалить строку?"
                        ,input      "Предыдущая цена РАВНА цене по закрываемому документу " + chr(10)
                                    + " Объект "  + v-cntxt-obj-type + String(v-cntxt-obj-code)
                                    + " Артикул " + pdf_price-list.artic + " " +  buf_goods.gds-name + chr(10)
                                    + " Бар-код " + string(pdf_price-list.b-code)
                                    + " Цена по предыдущему документу переоценки № " + l-doc-num2 + " = "
                                    + string(pdf_price-list.price-sale-doc) + chr(10)
                                    + " Удалить строку? "
                        ,input "|^"
                        ,input "Да|Нет|Да для всех^confirm|Нет для всех^confirm"
                        ,input "Удалить строку|"
                            + "Не удалять строку|"
                            + "Удалять у всех товаров, цена на которые не изменилась|"
                            + "Не удалять у всех товаров, цена на которые не изменилась"
                        ,input 1
                        ,input 2
                        ,output v-num
                        ).
              end.
              else do:
                v-num = 3 .
              end.
                if v-num = 1 then do:
                  run del-doc-line ( input recid(pdf_price-list)) no-error  .
                                  if error-status :error then do:
                                          message  vss-workfile vss-revision vss-description skip
                                          "Ошибка при удаление строки ДНЦ"
                                          pdf_price-list.b-code skip
                                          error-status :get-message(1) .
                                          return error.
                                  end.
                end.
                if v-num = 3  then do:
                   run del-doc-line ( input recid(pdf_price-list)) no-error  .
                end.
        end.
       end.
end.
  for each main_price-list no-lock where
              main_price-list.plt-id      = p-plt-id and
              main_price-list.plt-db-num  = p-plt-db-num and
              main_price-list.pdf-id      = p-pdf-id and
              main_price-list.pdf-db      = p-pdf-db
              :
              if main_price-list.b-code <> f-base-code (main_price-list.b-code) then next.
                for each pp_price-list no-lock where
                          pp_price-list.plt-id       = main_price-list.plt-id     and
                          pp_price-list.plt-db-num   = main_price-list.plt-db-num and
                          pp_price-list.pdf-id       = main_price-list.pdf-id     and
                          pp_price-list.pdf-db       = main_price-list.pdf-db     and
                          pp_price-list.artic        = main_price-list.artic      and
                          pp_price-list.prod-type    = main_price-list.prod-type  and
                          pp_price-list.prod-code    = main_price-list.prod-code  and
                          pp_price-list.b-code      <> main_price-list.b-code     and
                          pp_price-list.price-sale-doc = main_price-list.price-sale-doc  ,
                    first buf_goods no-lock where
                          buf_goods.artic     =  pp_price-list.artic and
                          buf_goods.prod-type =  pp_price-list.prod-type and
                          buf_goods.prod-code =  pp_price-list.prod-code ,
                    first buf1-bar-code no-lock where
                          buf1-bar-code.b-code   = pp_price-list.b-code and
                          buf1-bar-code.unit-cli = buf_goods.unit-base
                          :
                          bbb = true .
                          for each alt_price-list no-lock where
                                  alt_price-list.plt-id     = pp_price-list.plt-id     and
                                  alt_price-list.plt-db-num = pp_price-list.plt-db-num and
                                  alt_price-list.pdf-id     = pp_price-list.pdf-id     and
                                  alt_price-list.pdf-db     = pp_price-list.pdf-db     and
                                  alt_price-list.artic      = pp_price-list.artic      and
                                  alt_price-list.prod-type  = pp_price-list.prod-type  and
                                  alt_price-list.b-code     <> main_price-list.b-code  and
                                  alt_price-list.b-code     <> pp_price-list.b-code    and
                                  alt_price-list.prod-code  = pp_price-list.prod-code ,
                            first buf2_goods no-lock where
                                  buf2_goods.artic     =  pp_price-list.artic     and
                                  buf2_goods.prod-type =  pp_price-list.prod-type and
                                  buf2_goods.prod-code =  pp_price-list.prod-code ,
                            first buf2-bar-code no-lock where
                                  buf2-bar-code.b-code   = alt_price-list.b-code and
                                  buf2-bar-code.unit-cli <> buf2_goods.unit-base and
                                  buf2-bar-code.node-code = buf1-bar-code.node-code
                                :
                                bbb = false.
                                leave.
                          end.
                          if bbb = true  then do:
                              run del-doc-line ( input recid (pp_price-list)) no-error  .
                              if error-status :error then do:
                                  message  vss-workfile vss-revision vss-description skip
                                  " Нельзя удалить " pp_price-list.b-code skip
                                  error-status :get-message(1) .
                              end.
                          end.
                end.
  end.
end.
end procedure.
procedure ver-pr-discnS :
define input  parameter p-plt-id        as integer   no-undo .
define input  parameter p-plt-db-num    as integer   no-undo .
define input  parameter p-pdf-id        as integer   no-undo .
define input  parameter p-pdf-db        as integer   no-undo .
define input  parameter p-mode        as character no-undo .
define input  parameter trn-doc-code  like ub.trn-doc.doc-code no-undo .
define output parameter p-err         as logical no-undo .
  do
  on error undo, return error return-value
  :
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
define buffer b_price-doc-forming-gds for ub.price-doc-forming-gds .
define buffer b_trn-doc    for ub.trn-doc .
define buffer b_doc-line   for ub.doc-line .
define buffer bl_goods     for ub.goods .
define buffer bl_gds-grp   for ub.gds-grp .
define buffer bl_bar-code  for ub.bar-code  .
define buffer buf_bar-code for ub.bar-code  .
define variable v-koff            as decimal   no-undo .
define variable t-prc             as decimal   no-undo .
define variable p-prc-min         as decimal   no-undo .
define variable p-prc-max         as decimal   no-undo .
define variable p-increase-pc     as decimal   no-undo .
define variable p-round-method    as character no-undo .
define variable p-base            as decimal   no-undo .
define variable var-pr-r-b        as character no-undo .
define variable tt-price-sale     as decimal   no-undo .
define variable p-node-code       as integer   no-undo .
define variable p-host-code       as integer   no-undo .
define variable p-obj-type        as character no-undo .
define variable p-obj-code        as integer   no-undo .
define variable p-value-margin    as integer   no-undo .
define variable p-type-margin     as logical   no-undo .
define variable p-value-increase  as integer   no-undo .
define variable p-type-increase   as logical   no-undo .
define variable p-value-rmethod   as integer   no-undo .
define variable p-type-rmethod    as logical   no-undo .
define variable l_price           as decimal   no-undo .
define variable l_pricewithvat    as decimal   no-undo .
define variable l_pricewithoutvat as decimal   no-undo .
define variable l_prod-vat        as decimal   no-undo .
define variable fact_price        as decimal   no-undo .
define variable pr-discm          as character no-undo .
define variable pr-gen-margin     as character no-undo .
p-err = false .
define variable cost-base     as decimal  no-undo .
define variable cost-rubl     as decimal  no-undo .
define variable v-price-base  as decimal  no-undo .
define variable v-price-rubl  as decimal  no-undo .
define variable cur-rt-base   as decimal  no-undo .
define variable cur-rt-rubl   as decimal  no-undo .
define variable f-cost as decimal no-undo .
define variable s-cost as decimal no-undo .
define variable f-qnty as decimal no-undo .
define variable s-qnty as decimal no-undo .
define variable p-attr-code    as character no-undo .
define variable p-b-code       as integer   no-undo .
define variable p-attr-value   as character no-undo .
define variable v-ok           as logical   no-undo .
define variable par-type       as character no-undo.
define variable v-main-b-code  as integer   no-undo .
define variable v-vat-pc       as decimal   no-undo .
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-pr-r-b
  )  .
find first x_obj-group .
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output p-host-code
  )  .
assign
  p-obj-type   = x_obj-group.obj-type
  p-obj-code   = x_obj-group.obj-code
.
define variable vss-include-info70 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_discount':U
    ,input  'object':U
    ,input  p-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-ok
    )  .
end.
  if v-ok = true then return .
if trim(par-pr-discm) = "" then return .
if par-pr-discm = 'sale-' then par-pr-discm = 'sale' .
for each  b_price-doc-forming-gds no-lock where
          b_price-doc-forming-gds.plt-id     = p-plt-id      and
          b_price-doc-forming-gds.plt-db-num = p-plt-db-num  and
          b_price-doc-forming-gds.pdf-id     = p-pdf-id      and
          b_price-doc-forming-gds.pdf-db     = p-pdf-db
          :
    find first buf_bar-code no-lock where
               buf_bar-code.b-code  = b_price-doc-forming-gds.b-code
               no-error .
    if available buf_bar-code then v-koff = buf_bar-code.cli-base-rate .
    else v-koff = 1.
    if v-koff = ? or v-koff = 0 then v-koff = 1.
   find first bl_goods no-lock   where
              bl_goods.artic     = b_price-doc-forming-gds.artic     and
              bl_goods.prod-code = b_price-doc-forming-gds.prod-code and
              bl_goods.prod-type = b_price-doc-forming-gds.prod-type
              .
    assign
      p-node-code  = bl_goods.grp-code
    .
    run gds-attr-margin-value
    (
      input   bl_goods.gds-code,
      input   p-obj-type ,
      input   p-obj-code ,
      output  p-prc-min  ,
      output  p-prc-max  ,
      output  p-increase-pc,
      output  p-round-method,
      output  p-base        ,
      output  p-value-margin    ,
      output  p-type-margin     ,
      output  p-value-increase   ,
      output  p-type-increase   ,
      output  p-value-rmethod   ,
      output  p-type-rmethod
      ) .
    if p-type-margin = false  then next.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bl_goods.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
    if  trn-doc-code = ? or trn-doc-code = "" then do:
        if v-main-b-code = b_price-doc-forming-gds.b-code then do :
          case  par-pr-discm :
             when "prod":u then do:
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
                  fact_price =  if var-pr-r-b = "rubl"
                                then  b_price-doc-forming-gds.price-sale-rubl
                                else  b_price-doc-forming-gds.price-sale-base
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
              when "prod-vat":u then do:
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
                  fact_price =  if var-pr-r-b = "rubl"
                                then  b_price-doc-forming-gds.price-sale-rubl
                                else  b_price-doc-forming-gds.price-sale-base
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
              when "cost-vat":u then do:
                  run str/mplnovat.p
                     (input 'Учет-НДСS':U,
                      input table x_obj-group ,
                      input b_price-doc-forming-gds.b-code,
                      input b_price-doc-forming-gds.artic,
                      input b_price-doc-forming-gds.prod-type,
                      input b_price-doc-forming-gds.prod-code,
                      input 0 ,
                      input ? ,
                      input b_price-doc-forming-gds.vat-pc ,
                      input b_price-doc-forming-gds.slt-pc ,
                      output cost-base   ,
                      output cost-rubl   ,
                      output v-price-base  ,
                      output v-price-rubl  ,
                      output cur-rt-base ,
                      output cur-rt-rubl
                      ).
                  assign
                    l_price    =  if var-pr-r-b = "rubl" then v-price-rubl else v-price-base
                    fact_price =  if var-pr-r-b = "rubl" then b_price-doc-forming-gds.price-sale-rubl else b_price-doc-forming-gds.price-sale-base
                  .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
            when "cost":u       then do:
              t-prc =  fnc-cost-pc (buffer b_price-doc-forming-gds) .
            end.
            when "sale":u then do:
              t-prc =  fnc-pr-pc   (buffer b_price-doc-forming-gds) .
            end.
          end case.
        end.
        else do:
 case  par-pr-discm :
            when "cost":u
            or when "cost-vat":u
            then do:
              l_price =  fnc-cost (buffer b_price-doc-forming-gds) .
              t-prc = ((b_price-doc-forming-gds.price-sale-rubl / v-koff)  / l_price - 1) * 100.
            end.
            when "sale":u then do:
              l_price =  fnc-pr   (buffer b_price-doc-forming-gds) .
              t-prc = (( b_price-doc-forming-gds.price-sale-rubl / v-koff) /  l_price - 1) * 100.
            end.
              when "prod":u then do:
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
                  fact_price =  if var-pr-r-b = "rubl"
                                then
                                   b_price-doc-forming-gds.price-sale-rubl  / v-koff
                                else
                                   b_price-doc-forming-gds.price-sale-base  / v-koff
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
              when "prod-vat":u then do:
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
                  fact_price =  if var-pr-r-b = "rubl"
                                then
                                   b_price-doc-forming-gds.price-sale-rubl  / v-koff
                                else
                                   b_price-doc-forming-gds.price-sale-base  / v-koff
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
          end case.
        end.
    end.
if  trn-doc-code <> ? and trn-doc-code <> "" then do:
    find first b_trn-doc where b_trn-doc.doc-code = trn-doc-code no-lock no-error .
    if available b_trn-doc then find first b_doc-line where
    b_doc-line.doc-code  = b_trn-doc.doc-code and
    b_doc-line.artic     = bl_goods.artic     and
    b_doc-line.prod-code = bl_goods.prod-code and
    b_doc-line.prod-type = bl_goods.prod-type no-lock no-error .
    if b_trn-doc.ext-doc-type = 'ie':U then   pr-gen-margin = par-gen-mrgn-ie.
    if b_trn-doc.ext-doc-type = 'iv':U then   pr-gen-margin = par-gen-mrgn-iv.
    if b_trn-doc.ext-doc-type = 'im':U  then   pr-gen-margin = par-gen-mrgn-im.
    pr-gen-margin = lc(pr-gen-margin).
      if available b_doc-line then do:
      case  par-pr-discm :
        when "cost":u then do:
                f-qnty = 0.
                find ub.gds-obj no-lock where
                    ub.gds-obj.gds-code = bl_goods.gds-code and
                    ub.gds-obj.obj-type = b_trn-doc.obj-type and
                    ub.gds-obj.obj-code = b_trn-doc.obj-code no-error.
                if  available ub.gds-obj then
                  if bl_goods.gds-type = 'т':U then do:
                          if var-pr-r-b = "rubl" then
                              assign
                                f-cost = if  ub.gds-obj.avrg-rubl = ? then 0 else ub.gds-obj.avrg-rubl
                                f-qnty = ub.gds-obj.avrg-qnty
                                .
                          else
                              assign
                                f-cost = if  ub.gds-obj.avrg-base = ? then 0 else ub.gds-obj.avrg-base
                                f-qnty = ub.gds-obj.avrg-qnty
                                .
                      end.
                    else  f-cost = ?.
                else f-cost = ?.
           if pr-gen-margin = 'before-margin':U then do:
assign
  price-rubl-with-tax-loc = b_doc-line.price-rubl
  price-base-with-tax-loc = b_doc-line.price-base
.
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = b_trn-doc.doc-code
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
   find first in-vatp-goods where in-vatp-goods.artic     = b_doc-line.artic     and
                                     in-vatp-goods.prod-type = b_doc-line.prod-type and
                                     in-vatp-goods.prod-code = b_doc-line.prod-code no-lock.
   if (not b_trn-doc.internal and
           b_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = b_doc-line.road-tax
          road-tax-rubl-loc = b_doc-line.road-tax * b_trn-doc.base-rate / b_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = b_doc-line.road-tax
          road-tax-base-loc = b_doc-line.road-tax / b_trn-doc.base-rate * b_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if b_doc-line.transport-base = ? then 0 else b_doc-line.transport-base)
        transport-rubl-loc = (if b_doc-line.transport-rubl = ? then 0 else b_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if b_doc-line.other-base     = ? then 0 else b_doc-line.other-base)
        other-rubl-loc     = (if b_doc-line.other-rubl     = ? then 0 else b_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if b_doc-line.vat-pc         = ? then 0 else b_doc-line.vat-pc)
        slt-pc-loc         = (if b_doc-line.slt-pc         = ? then 0 else b_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = b_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = b_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = b_doc-line.obj-code  and
                                      in-vatp-parts.artic     = b_doc-line.artic     and
                                      in-vatp-parts.prod-type = b_doc-line.prod-type and
                                      in-vatp-parts.prod-code = b_doc-line.prod-code
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
        road-tax-base-loc   = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        transport-base-loc  = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        other-base-loc      = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        other-rubl-loc      = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b_doc-line.fact-qnty   else 0
        slt-base-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b_doc-line.fact-qnty   else 0
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
             if var-pr-r-b = "rubl" then
                 s-cost = price-rubl-with-tax-loc.
               else
                 s-cost = price-base-with-tax-loc.
             s-qnty = b_doc-line.fact-qnty .
           end.
           else do:
             assign
              s-cost = 0
              s-qnty = 0
             .
           end.
           l_price  =  (f-cost * f-qnty + s-cost * s-qnty ) / (f-qnty + s-qnty)  .
        end.
        when "cost-vat":u then do:
             run str/gdsnovat.p ('Уч+накл-НДС':U,
                     b_trn-doc.obj-type,
                     b_trn-doc.obj-code,
                     b_trn-doc.host-code,
                     b_doc-line.artic,
                     b_doc-line.prod-type,
                     b_doc-line.prod-code,
                     0 ,
                     b_doc-line.doc-code,
                     ?,
                     ?,
                     output cost-base   ,
                     output cost-rubl   ,
                     output v-price-base  ,
                     output v-price-rubl  ,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
                     if var-pr-r-b = "rubl"
                        then l_price = v-price-rubl.
                        else l_price = v-price-base.
        end.
        when "sale":u then do:
              l_price = ( if var-pr-r-b = "rubl"
                             then b_doc-line.price-rubl
                             else b_doc-line.price-base ).
        end.
        when "prod":u then do:
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
    end.
   when "prod-vat":u then do:
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
    end.
      end case.
        tt-price-sale = b_price-doc-forming-gds.price-sale-rubl .
        t-prc = (( tt-price-sale /  v-koff ) / l_price - 1) * 100.
   end.
end.
  if  p-prc-max <> ? then do:
    if  t-prc <> ? and ( p-prc-max < t-prc  or p-prc-min > t-prc)
    then do:
      message (if v-main-b-code = b_price-doc-forming-gds.b-code then "По товару :"
          else "По признаку"  )
          b_price-doc-forming-gds.artic
          b_price-doc-forming-gds.prod-type
          b_price-doc-forming-gds.prod-code skip
          "бар-код: " b_price-doc-forming-gds.b-code
           ( if v-koff > 1 then substitute("Упаковка на: &1" , v-koff)
             else "" ) skip
          fnc-pr  (buffer b_price-doc-forming-gds)
          skip
        "Процент торговой наценки вышел за интервал возможных значений !!! " skip
        "Процент не менее :" p-prc-min "%" skip
        "Процент не более :" p-prc-max "%" skip
        "Процент фактический :" t-prc  "%"  skip
        "ДНЦ №: " b_price-doc-forming-gds.pdf-id         skip
        "БД" b_price-doc-forming-gds.pdf-db
          view-as alert-box error .
              p-err = true .
              undo , return error .
    end.
    else do:
       if  t-prc = ? then  do:
          message (if v-main-b-code = b_price-doc-forming-gds.b-code then "По товару :"
          else "По признаку"  )
          b_price-doc-forming-gds.artic
          b_price-doc-forming-gds.prod-type
          b_price-doc-forming-gds.prod-code skip
          "бар-код: " b_price-doc-forming-gds.b-code
           ( if v-koff > 1 then substitute("Упаковка на: &1" , v-koff)
             else "" ) skip
          fnc-pr  (buffer b_price-doc-forming-gds)
          skip
          "Нет базовой цены для расчета процента наценки !" skip
          "Процент торговой наценки вышел за интервал возможных значений !!! " skip
          "Процент не менее :" p-prc-min "%" skip
          "Процент не более :" p-prc-max "%" skip
          "Процент фактический :" t-prc  "%"  skip
          "ДНЦ №_: " b_price-doc-forming-gds.pdf-id         skip
          "БД" b_price-doc-forming-gds.pdf-db
          view-as alert-box error .
          p-err = true .
          undo , return error .
       end.
    end.
  end.
end.
  end.
end procedure.
procedure del-doc-line :
define input  parameter p-recid as recid no-undo .
  do
  on error undo, return error return-value
  :
  find first ub.price-doc-forming-gds exclusive-lock where
       recid ( ub.price-doc-forming-gds ) = p-recid  no-error .
   if available ub.price-doc-forming-gds then do:
      delete ub.price-doc-forming-gds no-error .
   end.
  end.
end procedure.
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdsoattr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
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
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
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
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
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
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure last-incom-S :
define input parameter  p-artic      like ub.gds-obj.artic      no-undo .
define input parameter  p-prod-type  like ub.gds-obj.prod-type  no-undo .
define input parameter  p-prod-code  like ub.gds-obj.prod-code  no-undo .
define output parameter p-in-code   as character no-undo .
define output parameter p-obj-type  as character no-undo .
define output parameter p-obj-code  as integer   no-undo .
  do
  on error undo, return error return-value
  :
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_gds-obj for ub.gds-obj  .
  do
  on error undo, return error
  :
    assign
      p-in-code  = ""
      p-obj-type = ""
      p-obj-code = 0
    .
     for each x_obj-group ,
      each buf_gds-obj no-lock
      where buf_gds-obj.obj-type  = x_obj-group.obj-type
        and buf_gds-obj.obj-code  = x_obj-group.obj-code
        and buf_gds-obj.artic     = p-artic
        and buf_gds-obj.prod-type = p-prod-type
        and buf_gds-obj.prod-code = p-prod-code
    , first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_gds-obj.in-code
        and buf_trn-doc.status_  = 'факт':U
    on error undo, return error
    by buf_trn-doc.fact-order descending
    :
      assign
        p-in-code  = buf_gds-obj.in-code
        p-obj-type = buf_gds-obj.obj-type
        p-obj-code = buf_gds-obj.obj-code
      .
      leave .
    end.
  end.
  end.
end procedure.
procedure main-road-tax :
def input param p-obj-type  like ub.gds-obj.obj-type  no-undo .
def input param p-obj-code  like ub.gds-obj.obj-code  no-undo .
def input param p-artic     like ub.gds-obj.artic     no-undo .
def input param p-prod-type like ub.gds-obj.prod-type no-undo .
def input param p-prod-code like ub.gds-obj.prod-code no-undo .
def input-output param p-road-tax-base as decimal no-undo .
def input-output param p-road-tax-rubl as decimal no-undo .
define buffer     buff-goods    for ub.goods   .
define buffer     buf_gds-obj   for ub.gds-obj .
define buffer     buf_parts     for ub.parts   .
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
define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line .
define variable   is-petrolium  as logical             no-undo.
define variable   is-pieces     as logical             no-undo.
define variable v-last-in-code  like ub.gds-obj.in-code  no-undo .
define variable v-last-obj-type like ub.gds-obj.obj-type no-undo .
define variable v-last-obj-code like ub.gds-obj.obj-code no-undo .
def var v-rec as recid no-undo.
def var t-ret as logical no-undo .
def var v-total-avrg-base as decimal no-undo .
def var v-total-avrg-rubl as decimal no-undo .
def var v-total-avrg-qnty as decimal no-undo .
def var v-total-road-tax-base     as decimal no-undo .
def var v-total-road-tax-rubl     as decimal no-undo .
def var v-all-total-road-tax-base as decimal no-undo .
def var v-all-total-road-tax-rubl as decimal no-undo .
assign
  p-road-tax-base = ?
  p-road-tax-rubl = ?
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
                p-road-tax-base = ?
                p-road-tax-rubl = ?
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
      for each x_obj-group,
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
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
          if v-total-avrg-qnty > 0 then  DO :
              assign
                p-road-tax-base =  v-all-total-road-tax-base  / v-total-avrg-qnty
                p-road-tax-rubl =  v-all-total-road-tax-rubl  / v-total-avrg-qnty
                .
          end.
            if v-total-avrg-qnty <= 0 then do :
                run last-incom-S in this-procedure
                ( input   p-artic ,
                  input   p-prod-type,
                  input   p-prod-code ,
                  output  v-last-in-code,
                  output  v-last-obj-type,
                  output  v-last-obj-code ).
                      find buf_trn-doc where buf_trn-doc.doc-code  = v-last-in-code no-lock no-error .
                      find buf_doc-line where     buf_doc-line.doc-code  = v-last-in-code
                                      and buf_doc-line.artic     = p-artic
                                      and buf_doc-line.prod-type = p-prod-type
                                      and buf_doc-line.prod-code = p-prod-code no-lock no-error.
                      if avail buf_doc-line then do :
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
                      Assign
                          p-road-tax-rubl =  road-tax-rubl-loc
                          p-road-tax-base =  road-tax-base-loc
                          .
                      end.
    end.
end procedure.
def var vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-use-bar-code :
  define input  parameter p-b-code    like ub.bar-code.b-code no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info82, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info82 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info82 )
  :
    define buffer buf_bar-code for ub.bar-code .
    find first buf_bar-code no-lock
      where buf_bar-code.b-code     = p-b-code
      no-error .
    if not available buf_bar-code then do:
      return error substitute( "&1 (check-use-bar-code). Не найден бар-код &2", vss-include-info82, p-b-code ) .
    end.
    if buf_bar-code.stts = integer('99':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Выполняется удаление бар-кода"
                              ,vss-include-info82
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    if buf_bar-code.stts = integer('79':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Бар-код выключен"
                              ,vss-include-info82
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    return .
  end.
end procedure.
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-param-type      as character  no-undo.
define variable v-tth             as handle     no-undo.
define variable varis-petrolium   as logical    no-undo.
define variable varis-pieces      as logical    no-undo.
define variable v-sec as integer   no-undo .
define variable imp-save as integer   no-undo .
define variable l-par as logical   no-undo .
   run chec-par in this-procedure (
         output l-par
        ,input  v-cntxt-host-code-obj
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
      ) no-error .
define shared stream inp.
define shared stream err.
define shared stream wrn.
define variable source-string  as char FORMAT "x(232)"      no-undo.
define variable text-string    as char FORMAT "x(232)"      no-undo.
define variable string-type    as char                      no-undo.
define variable i-artic         like ub.goods.artic            no-undo.
define variable i-artic-supp    like ub.cli-gds.cli-art        no-undo.
define variable i-code          like ub.prod-bc.b-str          no-undo.
define variable i-prod-code     like ub.goods.prod-code        no-undo.
define variable i-scale         like ub.gds-prt.f-name         no-undo.
define variable i-doc-code      like ub.parts.in-code          no-undo.
define variable i-part-code     like ub.parts.part-code        no-undo.
define variable i-prod-bc       like ub.prod-bc.b-str          no-undo.
define variable i-price         like ub.doc-line.price-cli     no-undo.
define variable i-qnty          like ub.doc-line.cli-qnty      no-undo.
define variable i-vat           like ub.doc-line.vat-pc        no-undo.
define variable i-slt           like ub.doc-line.vat-pc        no-undo.
define variable i-wt-brutto     like ub.doc-line.wt-brutto     no-undo.
define variable i-num-place     like ub.doc-line.num-place     no-undo.
define variable i-last-date     like ub.parts.last-date        no-undo.
define variable i-price-prod     as decimal   no-undo .
define variable i-price-prod-vat as decimal   no-undo .
define variable i-d-pcnt        like ub.price-doc-forming-gds.d-pcnt      no-undo.
define variable i-unit-cli      like ub.bar-code.unit-cli      no-undo.
define variable i-cli-base-rate like ub.bar-code.cli-base-rate no-undo.
define variable i-bc-on         as   logical                no-undo.
define variable i-cst-code      like ub.parts.cst-code         no-undo.
define variable local-code      like ub.goods.gds-code         no-undo.
define variable size           as dec                       no-undo.
define variable scale-level    as int                       no-undo.
define variable msg-line       as int init 0                no-undo.
define variable wrn-line       as int init 0                no-undo.
define variable par-bc-pfx     as char                      no-undo.
define variable par-pl-pfx     as char                      no-undo.
define variable par-bc-frmt    as char                      no-undo.
define variable par-pl-frmt    as char                      no-undo.
define variable par-dif-pdbc   as logical                   no-undo.
define variable par-dpl-off    as logical                   no-undo.
define variable varfile-scan   as logical                   no-undo.
define variable varcode-scan   as char                      no-undo.
define variable varqnty-scan   as char                      no-undo.
define variable varprice-scan  as char                      no-undo.
define variable v-host-code    like ub.sysconf.host-code  no-undo.
define variable v-obj-type     like ub.trn-doc.obj-type   no-undo.
define variable v-obj-code     like ub.trn-doc.obj-code   no-undo.
define variable varresult   as character       no-undo.
define variable vartype-bc  as character       no-undo.
define variable varweight   as decimal         no-undo.
define variable vararticle-supplier as logical no-undo.
define variable varlog      as logical         no-undo.
define buffer other-goods for ub.goods.
define buffer goods-units for ub.units.
define buffer bf_clients  for ub.clients.
define buffer bf_cli-gds  for ub.cli-gds.
define buffer trouble-goods for ub.goods.
define variable pdf-id      like ub.price-doc-forming.pdf-id  no-undo.
define variable pdf-db      like ub.price-doc-forming.pdf-db  no-undo.
define variable plt-id      like ub.price-doc-forming.plt-id     no-undo.
define variable plt-db-num  like ub.price-doc-forming.plt-db-num no-undo.
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type84 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type84
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type84 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type84
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
def frame a
counter   label "Закачано"
count-upd label "Изменено"
count-all label "Просмотрено"
with side-labels view-as dialog-box.
view frame a.
case InputMode:
  when "prod-bc" then do:
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "", yes, output par-bc-pfx, output par-type) no-error.
    if error-status:error or
      par-type <> "C":U then do:
      message "Ошибка параметра bc-pfx."
              view-as alert-box error.
      hide frame a.
      return error.
    end.
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "", yes, output par-bc-frmt, output par-type) no-error.
    if error-status:error or
      par-type <> "C":U then do:
      message "Ошибка параметра bc-frmt."
              view-as alert-box error.
      hide frame a.
      return error.
    end.
    run gbl/conf-rd.p ("pl-pfx", "", "", 0, "", "", "", no, output par-pl-pfx, output par-type) no-error.
    if error-status:error or
      par-type <> "C":U then
      par-pl-pfx = ?.
    run gbl/conf-rd.p ("pl-frmt", "", "", 0, "", "", "", no, output par-pl-frmt, output par-type) no-error.
    if error-status:error or
      par-type <> "C":U then
      par-pl-frmt = ?.
    run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'dif-pdbc':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output par-dif-pdbc
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error.
    delete object v-tth.
    run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'dpl-off':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output par-dpl-off
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error.
    delete object v-tth.
  end.
  when "input-way-bill" then do:
    on write of ub.trn-doc override do: end.
    clear-imp:
    do transaction
      on error undo clear-imp, return error
      on stop  undo clear-imp, return error :
      find ub.trn-doc where ub.trn-doc.doc-code = pardoc-code no-error.
      if available ub.trn-doc then do:
        run delete-trn-doc in this-procedure .
      end.
      create ub.trn-doc .
      assign
        ub.trn-doc.doc-code  = pardoc-code
        ub.trn-doc.cr-db-num = v-cntxt-db-num
        ub.trn-doc.doc-type  = 'при':U
        ub.trn-doc.internal  = no
        ub.trn-doc.exch-code = e-code
        ub.trn-doc.obj-type = v-cntxt-obj-type
        ub.trn-doc.obj-code = v-cntxt-obj-code
      .
      assign
          v-obj-type = v-cntxt-obj-type
          v-obj-code = v-cntxt-obj-code
      .
    end.
  end.
  when "way-bill-delete" then do:
    del-imp:
    do transaction
      on error undo del-imp, return error
      on stop  undo del-imp, return error :
      find ub.trn-doc where ub.trn-doc.doc-code = pardoc-code no-error.
      if available ub.trn-doc then do:
        run delete-trn-doc in this-procedure .
      end.
    end.
    return.
  end.
  when "overvalue" then do:
    find buf_price-doc-forming where recid( buf_price-doc-forming) = dfc-recid .
    assign
        pdf-id = buf_price-doc-forming.pdf-id
        pdf-db = buf_price-doc-forming.pdf-db
        plt-id      = buf_price-doc-forming.plt-id
        plt-db-num  = buf_price-doc-forming.plt-db-num
    .
  end.
  otherwise do:
    message
      "Неправильное значение параметра InputMode:" InputMode
      view-as alert-box error.
    hide frame a.
    return error.
  end.
end case.
frame a :title = frame-title.
put stream err unformatted fill (chr(10), 2) frame a :title fill (chr(10), 3).
assign varfile-scan = ?
       vararticle-supplier = no.
file-line:
repeat on endkey undo, leave :
  disp count-upd counter count-all with frame a.
  do on endkey undo, leave:
    import stream  inp unformatted source-string no-error.
  end.
  if error-status:error then undo, leave.
  if source-string = "" then
    next file-line.
  count-all = count-all + 1.
  if source-string = "ARTICLE-SUPPLIER" then do:
    assign
      vararticle-supplier = yes.
    if parcli-type = ? and
       parcli-code = ? then do:
      message "Из данного интерфейса нельзя обрабатывать данные по артикулу поставщика."
      view-as alert-box error.
      return error.
    end.
    else do:
      find first bf_clients where bf_clients.obj-type = parcli-type and
                                  bf_clients.obj-code = parcli-code no-lock no-error.
      if not available bf_clients then do:
        message "Ведем импорт по артикулу поставщика." skip
                "Не найден поставщик " parcli-type parcli-code " ."
        view-as alert-box error.
        return error.
      end.
    end.
    next file-line.
  end.
  if varfile-scan = ?              and
     index (source-string, ",") > 0 then do:
     message "Формат строки " source-string " содержит запятую." skip
             "Будем разбирать все необработаные строки файла как формат сканера?"
     view-as alert-box question buttons yes-no update varlog.
     if varlog = yes then do:
          if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Начиная со строки " + source-string + " разбираем данные по формату сканера." skip.
          assign varfile-scan = yes.
       end.
       else do:
          assign varfile-scan = no.
       end.
  end.
  if varfile-scan = yes then do:
     ASSIGN varcode-scan  = ENTRY(1, source-string, ",")
            varqnty-scan  = ENTRY(2, source-string, ",")
            varprice-scan = ENTRY(3, source-string, ",").
     if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Строка " + source-string + " сконвертирована в CODE:" + varcode-scan + ";;;;;" + varprice-scan + ";" + varqnty-scan + ";;;;;;;" skip.
     source-string = "CODE:" + varcode-scan + ";;;;;" + varprice-scan + ";" + varqnty-scan + ";;;;;;;".
  end.
  else do:
     if index (source-string, ":") = 0 then do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Не указан тип строки (ITEM,SCALE,PART,CODE) или отсутствует двоеточие. Пропускаем." chr(10).
        if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
        next file-line.
      end.
  end.
  assign
    string-type     = substring (source-string, 1, index (source-string, ":") - 1)
    text-string     = substring (source-string, index (source-string, ":") + 1)
    i-artic-supp    = ""
    i-artic         = ""
    i-code          = ""
    i-prod-code     = 0
    i-scale         = ""
    i-doc-code      = ""
    i-part-code     = ""
    i-prod-bc       = ""
    i-price         = 0
    i-qnty          = 0
    i-unit-cli      = ""
    i-cli-base-rate = 1
    i-d-pcnt        = 0
    i-VAT           = 0
    i-SLT           = 0
    size            = 1
    i-bc-on         = ?
    i-cst-code      = ""
    i-wt-brutto     = 0
    i-num-place     = 0
    i-last-date     = ?
    i-price-prod     = 0
    i-price-prod-vat     = 0
    .
  if num-entries (text-string, ";") <> 14 and
     num-entries (text-string, ";") <> 16 and
     num-entries (text-string, ";") <> 17 and
     num-entries (text-string, ";") <> 18 and
     num-entries (text-string, ";") <> 19
     then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Неправильное число параметров: " string (num-entries (text-string, ";"))
                  " (должно быть 14,16,17,18 или 19). Пропускаем." chr(10).
    if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
    next file-line.
  end.
  if string-type = "CODE" then do:
    assign
      i-code = trim (entry (1, text-string, ";")).
  end.
  else do:
    if vararticle-supplier = yes then do:
      assign
        i-artic-supp =  trim (entry (1, text-string, ";")).
      find first bf_cli-gds where bf_cli-gds.cli-type  = parcli-type  and
                                  bf_cli-gds.cli-code  = parcli-code  and
                                  bf_cli-gds.host-code = parhost-code and
                                  bf_cli-gds.cli-art   = i-artic-supp no-lock no-error.
      if not available bf_cli-gds then do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) substitute ("Не найден артикул поставщика &1 по фирме &2 для поставщика &3 &4. Пропускаем.", i-artic-supp, parhost-code, parcli-type, parcli-code) chr(10).
        if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
        next file-line.
      end.
      assign
        i-artic     = bf_cli-gds.artic
        i-prod-code = bf_cli-gds.prod-code.
    end.
    else do:
      assign
        i-artic     = trim (entry (1, text-string, ";"))
        i-prod-code = integer (trim (entry (2, text-string, ";"))).
    end.
  end.
  assign
    i-scale         = trim    (entry (3, text-string, ";"))
    i-doc-code      = trim    (entry (3, text-string, ";"))
    i-part-code     = trim    (entry (4, text-string, ";"))
    i-prod-bc       = trim    (entry (5, text-string, ";"))
    i-price         = decimal (entry (6, text-string, ";"))
    i-qnty          = decimal (entry (7, text-string, ";"))
    i-unit-cli      =          entry (8, text-string, ";")
    i-cli-base-rate = decimal (entry (9, text-string, ";"))
    i-d-pcnt        = decimal (entry (10, text-string, ";"))
    i-VAT           = decimal (entry (11, text-string, ";"))
    i-SLT           = decimal (entry (12, text-string, ";"))
    .
    if entry (13, text-string, ";") = "yes" then do:
       assign i-bc-on = yes.
    end.
    else do:
       if entry (13, text-string, ";") = "no" then do:
          assign i-bc-on = no.
       end.
       else do:
         if lookup (InputMode, "prod-bc,all") > 0 then do:
            if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Неверный параметр 13. Должен быть yes или no." chr(10).
            if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
            next file-line.
         end.
       end.
    end.
    assign i-cst-code = entry (14, text-string, ";").
    if num-entries (text-string, ";") = 16 then do:
      assign
        i-wt-brutto = decimal(entry (15, text-string, ";"))
        i-num-place = decimal(entry (16, text-string, ";"))
      .
    end.
    if num-entries (text-string, ";") = 17 then do:
      assign
        i-wt-brutto = decimal(entry (15, text-string, ";"))
        i-num-place = decimal(entry (16, text-string, ";"))
        i-last-date = date(entry (17, text-string, ";"))
      .
    end.
    if num-entries (text-string, ";") = 18 then do:
      assign
        i-wt-brutto = decimal(entry (15, text-string, ";"))
        i-num-place = decimal(entry (16, text-string, ";"))
        i-last-date = date(entry (17, text-string, ";"))
        i-price-prod = decimal(entry (18, text-string, ";"))
      .
    end.
    if num-entries (text-string, ";") = 19 then do:
      assign
        i-wt-brutto = decimal(entry (15, text-string, ";"))
        i-num-place = decimal(entry (16, text-string, ";"))
        i-last-date = date(entry (17, text-string, ";"))
        i-price-prod = decimal(entry (18, text-string, ";"))
        i-price-prod-vat = decimal(entry (19, text-string, ";"))
      .
    end.
  case string-type:
    when "ITEM" then do:
      if i-artic = "" then do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Пустой артикул. Пропускаем." chr(10).
        if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
        next file-line.
      end.
      assign
        i-code = ""
        i-doc-code = ""
        i-part-code = ""
        .
    end.
    when "SCALE" then do:
      if i-artic = "" then do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Пустой артикул. Пропускаем." chr(10).
        if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
        next file-line.
      end.
      if i-scale = "" then do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Пустое название признака. Пропускаем." chr(10).
        if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
        next file-line.
      end.
      assign
        i-code = ""
        i-doc-code = ""
        i-part-code = ""
        .
    end.
    when "PART" then do:
      if i-artic = "" then do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Пустой артикул. Пропускаем." chr(10).
        if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
        next file-line.
      end.
      i-code = "".
    end.
    when "CODE" then do:
      if i-code = "" then do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Пустой код. Пропускаем." chr(10).
        if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
        next file-line.
      end.
      i-artic = "".
    end.
    otherwise do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Неправильный тип строки (должно быть ITEM,SCALE,PART,CODE). Пропускаем." chr(10).
      if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
      next file-line.
    end.
  end case.
  release ub.goods.
  release ub.gds-prt.
  release ub.parts.
  if lookup (string-type, "ITEM,SCALE,PART") > 0 then do:
    if i-prod-code = 0 then do:
      FIND first ub.goods WHERE
                 ub.goods.artic = i-artic and
                 ub.goods.stts = 0 no-lock no-error.
      if available ub.goods then do:
        find first other-goods where
                   other-goods.artic = i-artic and
                   other-goods.stts  = 0       and
                   recid (other-goods) <> recid (goods) no-lock no-error.
        if available other-goods then do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Производитель не указан. Есть больше одного включенного товара с этим артикулом. Взят первый подходящий." chr(10).
        end.
        find first other-goods where
                   other-goods.artic = i-artic and
                   recid (other-goods) <> recid (goods) no-lock no-error.
        if available other-goods then do:
          if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Производитель не указан. Есть больше одного товара с этим артикулом. Взят первый неудаленный." chr(10).
        end.
      end.
      else do:
        FIND first other-goods WHERE
                   other-goods.artic = i-artic no-lock no-error.
        if available other-goods then do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Производитель не указан. Есть УДАЛЕННЫЙ товар с производителем : "
                        other-goods.prod-code " Название: " other-goods.gds-name " Пропускаем." chr(10).
          if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
          next file-line.
        end.
        else do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "В справочнике товаров нет товара с артикулом : " i-artic " Пропускаем." chr(10).
          if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
          next file-line.
        end.
      end.
    end.
    else do:
      FIND first ub.goods WHERE
                 ub.goods.artic = i-artic and
                 ub.goods.prod-type = 'орг':U and
                 ub.goods.prod-code = i-prod-code NO-LOCK no-error.
      if not available ub.goods then do:
        FIND first ub.goods WHERE
                   ub.goods.artic = i-artic and
                   ub.goods.prod-type = 'чел':U and
                   ub.goods.prod-code = i-prod-code NO-LOCK no-error.
        if available ub.goods then do:
        end.
        else do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Товар с данными артикулом и кодом производителя (подразумевается организация) в БД отсутствует. Пропускаем." chr(10).
          if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
          next file-line.
        end.
      end.
      find first trouble-goods where trouble-goods.artic     =  ub.goods.artic     and
                                     trouble-goods.prod-code =  ub.goods.prod-code and
                                     trouble-goods.prod-type <> ub.goods.prod-type no-lock no-error.
      if available trouble-goods then do:
         if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Есть товары с артикулом: " + ub.goods.artic + " кодом производителя: " + string(goods.prod-code) + " и типами производителя: " + ub.goods.prod-type + " и " + trouble-goods.prod-type + " Импорт невозможен. Пропускаем." chr(10).
         if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
         next file-line.
      end.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.goods.artic
  ,  input ub.goods.prod-type
  ,  input ub.goods.prod-code
  , output varis-petrolium
  , output varis-pieces
  ) .
    if varis-petrolium = yes and
       varis-pieces    = no  then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Товар " + ub.goods.artic + " " + ub.goods.prod-type + " " + string(goods.prod-code) + " является жидким топливом. Товар нельзя импортировать." + " Импорт невозможен. Пропускаем." chr(10).
      if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
      next file-line.
    end.
    if lookup (string-type, "ITEM,PART") > 0 then do:
      FIND first ub.gds-prt WHERE
                 ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
    end.
    if string-type = "SCALE" then do:
      find first  ub.gds-prt where
                  ub.gds-prt.prt-root = ub.goods.prt-root and
                  ub.gds-prt.is-term  = yes            and
                  ub.gds-prt.f-name   = i-scale        no-lock no-error.
      if not available ub.gds-prt then do:
        define variable varqnty-slash as integer no-undo.
        define variable varnum-symb   as integer no-undo.
        define variable vari-scale    like i-scale no-undo.
        assign varqnty-slash = 0.
        do varnum-symb = 1 to length(i-scale):
          if substring (i-scale, varnum-symb , 1) = "/" then do:
            assign
              varqnty-slash = varqnty-slash + 1.
          end.
        end.
        if varqnty-slash = 1 then do:
          assign
            vari-scale = substring (i-scale, r-index (i-scale, "/") + 1).
          find first  ub.gds-prt where
                  ub.gds-prt.prt-root = ub.goods.prt-root and
                  ub.gds-prt.is-term  = yes            and
                  ub.gds-prt.f-name   = vari-scale        no-lock no-error.
          if not available ub.gds-prt then do:
            if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Узел шкалы не найден. Пропускаем." chr(10).
            next file-line.
          end.
          else do:
            if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Узел шкалы не найден. Но НАЙДЕН для одноуровневой шкалы по нижнему уровню. Пропускаем." chr(10).
            next file-line.
          end.
        end.
        else do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Узел шкалы не найден. Пропускаем." chr(10).
          next file-line.
        end.
      end.
    end.
  end.
  if string-type = "CODE" then do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  i-code
,input  ?
,input  v-cntxt-obj-type
,input  v-cntxt-obj-code
,input  yes
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output varresult
,output vartype-bc
,output varweight
,buffer ub.bar-code
,buffer ub.prod-bc
,buffer ub.place
) no-error.
    if not available ub.bar-code then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Код для поиска в БД отсутствует. Пропускаем." chr(10).
      if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
      next file-line.
    end.
    find first ub.goods   where ub.goods.gds-code    = ub.bar-code.gds-code no-lock.
    if i-unit-cli = "" then do:
      assign
        i-cli-base-rate = ub.bar-code.cli-base-rate
        i-unit-cli      = ub.bar-code.unit-cli
        .
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   " Собственный код : "                     ub.bar-code.b-code   " Единица измерения собственного кода : " ub.bar-code.unit-cli   " коэффициент собственного кода : "        ub.bar-code.cli-base-rate   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Не указаны единица измерения и коэффициент. Берем из собственного кода." chr(10).
    end.
    find first ub.gds-prt where ub.gds-prt.node-code = ub.bar-code.node-code no-lock.
    if InputMode = "input-way-bill" and
       ub.gds-prt.is-term <> yes       then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Код " i-code " не является кодом терминального признака. Пропускаем." chr(10).
      if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.
      next file-line.
    end.
  end.
  find goods-units where
       goods-units.unit-name = ub.goods.unit-base no-lock.
  if i-unit-cli = "" then
    assign
      i-unit-cli = ub.goods.unit-base
      i-cli-base-rate = 1
      .
  if v-obj-type = ? or
     v-obj-code = ? then do:
     assign
       v-obj-type = v-cntxt-obj-type
       v-obj-code = v-cntxt-obj-code.
  end.
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-host-code
  )  .
  define variable v-vat-pc as decimal   no-undo .
  define variable v-slt-pc as decimal   no-undo .
  define variable v-today  as date      no-undo .
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-today
  )  .
  assign
    v-vat-pc = ?
    v-slt-pc = ?
  .
  define variable v-inout-price as logical   no-undo .
  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop .
  case v-obj-type :
    when 'скл':U
    then do:
      find buf_store no-lock
        where buf_store.obj-code = v-obj-code
        no-error .
      if not available buf_store
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден склад." skip
          v-obj-type v-obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        v-inout-price = buf_store.inout-price
      .
    end.
    when 'маг':U
    then do:
      find buf_shop no-lock
        where buf_shop.obj-code = v-obj-code
        no-error .
      if not available buf_shop
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден магазин." skip
          v-obj-type v-obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        v-inout-price = buf_shop.inout-price
      .
    end.
  end.
  if v-inout-price = true
  then do:
    if i-VAT = 0
    then do:
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-vat-pc
  ) no-error .
    end.
    else do:
      assign
        v-vat-pc = i-VAT
      .
    end.
  end.
  else do:
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  '1':U
  ,input  i-VAT
  ,input  v-today
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-vat-pc
  ) no-error .
  end.
  if v-inout-price = true
  then do:
    if i-SLT = 0
    then do:
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-slt-pc
  ) no-error .
    end.
    else do:
      assign
        v-slt-pc = i-SLT
      .
    end.
  end.
  else do:
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  '2':U
  ,input  i-SLT
  ,input  v-today
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-slt-pc
  ) no-error .
  end.
  if lookup (InputMode, "input-way-bill,all") > 0 then do:
    if v-vat-pc = ?
    then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted substitute("Получено неопреледенное значение НДС. Код ставки НДС &1. Пропускаем.", i-vat) chr(10).
      next file-line.
    end.
    if v-slt-pc = ?
    then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted substitute("Получено неопреледенное значение НП. Код ставки НП &1. Пропускаем.", i-slt) chr(10).
      next file-line.
    end.
  end.
  if lookup ('шту':U, goods-units.type) > 0 and
     i-cli-base-rate <> truncate (i-cli-base-rate, 0) then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Для штучного товара коэффициент должен быть целым числом. Пропускаем." chr(10).
    next file-line.
  end.
  if lookup ('вес':U, goods-units.type)  > 0 and
     not lookup (string-type, "ITEM,PART") > 0 and
     inputmode <> "input-way-bill"            then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Товар весовой : Тип строки должен быть ITEM, PART, либо CODE для товара. Пропускаем." chr(10).
    next file-line.
  end.
  if lookup ('сер':U, goods-units.type) > 0 and
     not lookup (string-type, "ITEM,PART") > 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Товар серийный : Тип строки должен быть ITEM, PART, либо CODE для товара. Пропускаем." chr(10).
    next file-line.
  end.
  if lookup ('топ':U, goods-units.type) > 0 and
     lookup ('дро':U, goods-units.type) > 0 and
     ub.goods.gds-type = 'т':U then do:
    if not lookup (string-type, "ITEM") > 0 then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Товар топливный : Тип строки должен быть ITEM, либо CODE для товара. Пропускаем." chr(10).
      next file-line.
    end.
    if i-unit-cli <> ub.goods.unit-base then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Товар топливный : Единица измерения должна совпадать с основной. Пропускаем." chr(10).
      next file-line.
    end.
  end.
  find ub.units where ub.units.unit-name = i-unit-cli no-lock no-error.
  if not available ub.units then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Единица измерения отсутствует в справочнике. Пропускаем." chr(10).
    next file-line.
  end.
  if i-cli-base-rate <= 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Коэффициент должен быть больше 0. Пропускаем." chr(10).
    next file-line.
  end.
  if i-cli-base-rate = ? then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Коэффициент не должен иметь неопределенное значение. Пропускаем." chr(10).
    next file-line.
  end.
  if i-unit-cli <> ub.goods.unit-base and
     i-cli-base-rate = 1 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Единица измерения не совпадает с основной - а коэффициент 1! Пропускаем. " chr(10).
    next file-line.
  end.
  if i-unit-cli = ub.goods.unit-base and
     i-cli-base-rate <> 1 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Единица измерения совпадает с основной. Коэффициент должен быть равен 1. Пропускаем." chr(10).
    next file-line.
  end.
  run get-bar-code no-error.
  if error-status:error then
    next file-line.
  if  i-cli-base-rate = 1 and
      i-d-pcnt <> 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Коэффициент равен 1. Скидка должна быть равна 0. Пропускаем." chr(10).
    next file-line.
  end.
  if i-cli-base-rate > 1 and
      i-d-pcnt < 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Коэффициент больше 1. Скидка должна быть больше или равна 0. Пропускаем." chr(10).
    next file-line.
  end.
  if i-cli-base-rate < 1 and
      i-d-pcnt > 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Коэффициент меньше 1. Скидка должна быть меньше или равна 0. Пропускаем." chr(10).
    next file-line.
  end.
  if  i-price < 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Цена неправильная. Пропускаем." chr(10).
    next file-line.
  end.
  if lookup (InputMode, "prod-bc,all") > 0 then do:
    run imp-prod-bc no-error.
    if error-status:error then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted SUBSTITUTE("Ошибка при вызове внутренней процедуры imp-prod-bc &1 &2 &3",
                            return-value,
                            error-status:get-message(1),
                            error-status:get-message(2))  + chr(10).
      next file-line.
    end.
  end.
  if lookup (InputMode, "input-way-bill,all") > 0 then do:
    if i-price = ? or
       i-price = 0 then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Цена неправильная. Пропускаем." chr(10).
      next file-line.
    end.
    run imp-input-way-bill no-error.
    if error-status:error then do:
       if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted SUBSTITUTE("Ошибка при вызове внутренней процедуры imp-input-way-bill &1 &2 &3",
                                                    return-value,
                                                    error-status:get-message(1),
                                                    error-status:get-message(2))  + chr(10).
       next file-line.
     end.
  end.
  if lookup (InputMode, "overvalue,all") > 0 then do:
    if  i-price = ? or
        i-price = 0 then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Цена неправильная. Пропускаем." chr(10).
      next file-line.
    end.
    run imp-overvalue no-error.
    if error-status:error then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted SUBSTITUTE("Ошибка при вызове внутренней процедуры imp-overvalue &1 &2 &3",
                                                return-value,
                                                error-status:get-message(1),
                                                error-status:get-message(2))  + chr(10).
      next file-line.
   end.
  end.
END.
hide frame a .
procedure get-bar-code:
define variable s-in-code   like ub.parts.in-code   no-undo.
define variable s-part-code like ub.parts.part-code no-undo.
define variable new-bar-code as log              no-undo.
  assign
    s-in-code   = ""
    s-part-code = ""
    .
find-create-bc:
do transaction
on error undo find-create-bc, return error
on stop  undo find-create-bc, return error:
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  ub.goods.gds-code
  ,input  ub.gds-prt.node-code
  ,input  s-part-code
  ,input  s-in-code
  ,input  i-unit-cli
  ,input  i-cli-base-rate
  ,output new-bar-code
  ,buffer ub.bar-code
  ) no-error .
  if error-status:error then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   " Собственный код : "                     ub.bar-code.b-code   " Единица измерения собственного кода : " ub.bar-code.unit-cli   " коэффициент собственного кода : "        ub.bar-code.cli-base-rate   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Ошибка при поиске / создании собственного кода. Пропускаем." chr(10).
    undo find-create-bc, return error.
  end.
  if new-bar-code then do:
    if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   " Собственный код : "                     ub.bar-code.b-code   " Единица измерения собственного кода : " ub.bar-code.unit-cli   " коэффициент собственного кода : "        ub.bar-code.cli-base-rate   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Создан собственный код с единицей измерения из входного файла." chr(10).
  end.
  if ub.bar-code.cli-base-rate <> i-cli-base-rate then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   " Собственный код : "                     ub.bar-code.b-code   " Единица измерения собственного кода : " ub.bar-code.unit-cli   " коэффициент собственного кода : "        ub.bar-code.cli-base-rate   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Коэффициент в собственном коде не совпадает с указанным в файле. Пропускаем." chr(10).
    undo find-create-bc, return error.
  end.
end.
end procedure.
procedure imp-prod-bc:
def buffer same-prod-bc  for ub.prod-bc.
def buffer same-bar-code for ub.bar-code.
def buffer same-goods    for ub.goods.
define buffer buf_prod-bc-attr for prod-bc-attr.
define variable vMarkType as integer no-undo.
vMarkType = int(i-cst-code)no-error.
tr:
do on error undo tr, return error SUBSTITUTE("Ошибка при импорте доп. бар-кода &1 &2 &3 ", i-prod-bc, error-status:get-message(1), error-status:get-message(2)):
if  length (i-prod-bc) > 13  and
    not is-numeral (i-prod-bc,
                    "letter,digit") or
    length (i-prod-bc) <= 13  and
    not is-numeral (i-prod-bc,
                    "digit") then do:
  if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Доп. БК содержит пробелы или недопустимые символы. Пропускаем." chr(10).
  return.
end.
if  i-prod-bc begins par-bc-pfx and
    (length (i-prod-bc) = 13 and
    par-bc-frmt = "EAN13" or
    length (i-prod-bc) = 8 and
    par-bc-frmt = "EAN8") or
    (i-prod-bc begins par-pl-pfx and
    par-pl-pfx <> ? and
    par-pl-frmt <> ?) and
    (length (i-prod-bc) = 13 and
    par-pl-frmt = "EAN13" or
    length (i-prod-bc) = 8 and
    par-pl-frmt = "EAN8") then do:
  if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Доп. БК имеет префикс, зарезервированный для собственных товарных (складских мест) бар-кодов. Пропускаем." chr(10).
  return.
end.
if length (i-prod-bc) < 6 then do:
  if (lookup ('топ':U, goods-units.type) > 0 and
      lookup ('дро':U, goods-units.type) > 0 or
      lookup ('вес':U, goods-units.type) > 0) and
      ub.goods.gds-type = 'т':U then do:
    if  lookup ('топ':U, goods-units.type) > 0 and
        lookup ('дро':U, goods-units.type) > 0 then do:
      if  lookup ('топ':U, ub.units.type) > 0 and
          lookup ('дро':U, ub.units.type) > 0 then do:
        if length (i-prod-bc) > 2 then do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Топливный код: " + i-prod-bc + " не должен быть длиннее 2 разрядов. Пропускаем." chr(10).
          return.
        end.
        find first  ub.prod-bc where
                    ub.prod-bc.b-code = ub.bar-code.b-code and
                    ub.prod-bc.b-str <> i-prod-bc no-lock no-error.
        if available ub.prod-bc then do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Товар топливный. Уже есть топливный код у этого товара: " ub.prod-bc.b-str
                     " Он должен быть только один. Пропускаем." chr(10).
          return.
        end.
      end.
      else do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Товар топливный. Можно импортировать только топливный код (с дробно-топливной единицей измерения). Пропускаем." chr(10).
        return.
      end.
    end.
  end.
  else do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Код короче 6 разрядов  " + i-prod-bc + " может соответствовать только весовому или дробному топливному товару. Пропускаем." chr(10).
    return.
  end.
end.
else do:
  if  lookup ('топ':U, ub.units.type) > 0 and
      lookup ('дро':U, ub.units.type) > 0 or
      lookup ('вес':U, ub.units.type) > 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Весовой или топливный код  " + i-prod-bc + " не может быть длиннее 5 разрядов. Пропускаем." chr(10).
    return.
  end.
end.
find first  same-prod-bc where
            same-prod-bc.b-str  = i-prod-bc and
            same-prod-bc.b-code = bar-code.b-code no-lock no-error.
if available same-prod-bc then do trans:
  find current  same-prod-bc  exclusive-lock no-error.
  if available same-prod-bc
  then do:
     if i-bc-on eq yes
     then do:
         find first prod-bc where
                   prod-bc.b-str = i-prod-bc and
                   prod-bc.bc-on = yes       exclusive-lock no-error.
         if available prod-bc
         then do:
            if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "В БД уже есть такой доп. БК для товара: код : " prod-bc.b-code
                         ", он включен. Добавляемый код тоже включен. ВЫключаем уже имеющийся в базе код. Добавляемый оставляем включенным." chr(10).
            prod-bc.bc-on = no.
         end.
     end.
     same-prod-bc.bc-on = i-bc-on.
  end.
  if vMarkType eq 1
  then
     same-prod-bc.bc-on-type = 'GTIN':U.
  else
     same-prod-bc.bc-on-type = "".
  find first buf_prod-bc-attr
     where
            buf_prod-bc-attr.b-str  = i-prod-bc
        and buf_prod-bc-attr.b-code = same-prod-bc.b-code
        and buf_prod-bc-attr.attr-code = 'mark':U
     no-lock no-error.
  if vMarkType eq 2
  then do:
     if available buf_prod-bc-attr
     then do:
        if buf_prod-bc-attr.attr-value = "yes"
        then do:
           find current buf_prod-bc-attr exclusive-lock no-error.
           if available buf_prod-bc-attr
           then do:
              buf_prod-bc-attr.attr-value = "yes".
           end.
           else do:
             create buf_prod-bc-attr.
             assign
                buf_prod-bc-attr.b-str  = i-prod-bc
                buf_prod-bc-attr.b-code = same-prod-bc.b-code
                buf_prod-bc-attr.attr-code = 'mark':U
                buf_prod-bc-attr.attr-value = "yes"
             .
           end.
        end.
     end.
     else do:
        create buf_prod-bc-attr.
        assign
           buf_prod-bc-attr.b-str  = i-prod-bc
           buf_prod-bc-attr.b-code = same-prod-bc.b-code
           buf_prod-bc-attr.attr-code = 'mark':U
           buf_prod-bc-attr.attr-value = "yes"
        .
     end.
  end.
  else if available buf_prod-bc-attr
  then do:
     find current buf_prod-bc-attr exclusive-lock no-error
       .
     if available buf_prod-bc-attr
     then
        delete buf_prod-bc-attr.
  end.
end.
else do:
    find first same-prod-bc where
               same-prod-bc.b-str = i-prod-bc and
               same-prod-bc.bc-on = yes       no-lock no-error.
    if available same-prod-bc then do:
      find same-bar-code where
           same-bar-code.b-code = same-prod-bc.b-code no-lock.
      find same-goods where
           same-goods.gds-code = same-bar-code.gds-code no-lock.
      if  same-goods.prod-type = goods.prod-type AND
          same-goods.prod-code = goods.prod-code AND
          par-dif-pdbc = yes  then do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic
                   ", он включен и соответствует тому же производителю. Пропускаем в соответствии с настройкой." chr(10).
        return.
      end.
      if par-dpl-off = yes then do:
        if i-bc-on = no then do:
          if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                     ", он включен. Добавляемый код вЫключен. Таким его и добавляем." chr(10).
        end.
        else do:
          if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                     ", он включен. Добавляемый код тоже включен. Добавляем его вЫключеным в соответствии с настройкой." chr(10).
          assign
            i-bc-on = no.
          do transaction on error undo, return error return-value:
            find current same-prod-bc exclusive-lock.
            if same-prod-bc.bc-on-type eq 'GTIN':U
            then
               delete same-prod-bc.
            else
            assign
              same-prod-bc.bc-on = no.
          end.
          if available same-prod-bc
          then do:
          if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Имевшийся в БД доп. БК (см. предыдущее сообщение) для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                     ", который был включен, вЫключаем в соответствии с настройкой" chr(10).
          end.
       end.
      end.
      else do:
        if i-bc-on = yes then do:
          if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                     ", он включен. Добавляемый код тоже включен. ВЫключаем уже имеющийся в базе код. Добавляемый оставляем включенным." chr(10).
          do transaction on error undo, return error return-value :
            find current same-prod-bc exclusive-lock.
            if same-prod-bc.bc-on-type eq 'GTIN':U
            then
               delete same-prod-bc.
            else
                assign
                  same-prod-bc.bc-on = no.
          end.
          if available same-prod-bc
          then do:
              if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                         ", он включен. Добавляемый код выключен. Добавляем код без изменений." chr(10).
           end.
           else do:
              if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                         ". Переносим." chr(10).
           end.
        end.
      end.
    end.
    else do:
      find first same-prod-bc where
                 same-prod-bc.b-str = i-prod-bc and
                 recid (same-prod-bc) <> recid (prod-bc) no-lock no-error.
      if available same-prod-bc then do:
        find  same-bar-code where
              same-bar-code.b-code = same-prod-bc.b-code no-lock.
        find same-goods where
             same-goods.gds-code = same-bar-code.gds-code no-lock.
        if  same-goods.prod-type = goods.prod-type AND
            same-goods.prod-code = goods.prod-code AND
            par-dif-pdbc = yes  then do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic
                     ", он выключен и соответствует тому же производителю. Пропускаем в соответствии с настройкой dif-pdbc." chr(10).
          return.
        end.
        if i-bc-on = yes then do:
            do transaction on error undo, return error return-value:
            find current same-prod-bc exclusive-lock.
            if same-prod-bc.bc-on-type eq 'GTIN':U
            then
               delete same-prod-bc.
            else
            assign
              same-prod-bc.bc-on = no.
          end.
          if available same-prod-bc
          then
              if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                         ", он выключен. Добавляемый код включен. Добавляем код без изменений." chr(10).
        end.
        else do:
            if same-prod-bc.bc-on-type eq 'GTIN':U
            then do transaction on error undo, return error return-value:
            find current same-prod-bc exclusive-lock.
               delete same-prod-bc.
             end.
          if available same-prod-bc
          then
          if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                     ", он выключен. Добавляемый код вЫключен. Добавляем код без изменений." chr(10).
        end.
      end.
    end.
    if i-cst-code eq "1" and length (i-prod-bc) ne 14
    then do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted " GTIN должен быть 14 символов. Импортированный GTIN: " i-prod-bc   chr(10).
        return.
    end.
    do transaction on error undo, return error return-value :
      define variable rid as recid no-undo .
      rid = ?.
  run trg/prod-bc2.p (
                      input  parparentproc
                      ,input yes
                      ,input par-dif-pdbc
                      ,input ?
                      ,input no
                      ,input if i-cst-code eq "1" then 'GTIN':U else (if lookup ('вес':U, goods-units.type) > 0 then 'sclc':U else '')
                      ,input ""
                      ,buffer goods
                      ,input bar-code.b-code
                      ,input i-cst-code eq "2"
                      ,input-output i-prod-bc
                      ,output rid
                      ) no-error.
      if error-status :error
      then do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Ошибка при импорте доп. БК для товара: арт. : " goods.artic ", пр-ль : " goods.prod-code chr(10)
                     error-status:get-message(1) chr(10) return-value  chr(10).
          return.
      end.
      else if rid = ? then do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted "Невозможно импортировать доп. БК для товара: арт. : " goods.artic ", пр-ль : " goods.prod-code chr(10)
                     error-status:get-message(1) chr(10) return-value  chr(10).
          return.
      end.
      else do :
          find first  prod-bc where recid(prod-bc) eq rid
          exclusive-lock no-error.
          if available prod-bc
          then do:
             prod-bc.bc-on = i-bc-on.
          end.
      end.
    end.
end.
assign
  counter = counter + 1.
end.
end procedure.
procedure imp-input-way-bill:
define variable n-c like ub.gds-prt.node-code no-undo.
define buffer bf_doc-line-attr for ub.doc-line-attr.
find ub.doc-line where
     ub.doc-line.doc-code  = ub.trn-doc.doc-code and
     ub.doc-line.artic     = ub.goods.artic and
     ub.doc-line.prod-code = ub.goods.prod-code and
     ub.doc-line.prod-type = ub.goods.prod-type no-error.
if available ub.doc-line then do:
  if ub.doc-line.unit-cli      = i-unit-cli and
     ub.doc-line.cli-base-rate = i-cli-base-rate then
    assign
      ub.doc-line.cli-qnty      = ub.doc-line.cli-qnty + i-qnty
      ub.doc-line.price-cli     = i-price
      ub.doc-line.unit-cli      = i-unit-cli
      ub.doc-line.cli-base-rate = i-cli-base-rate
      .
  else do:
    if ub.doc-line.cli-base-rate = i-cli-base-rate then do:
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Единица измерения поставщика в строке ПН: " ub.doc-line.unit-cli
                 " Не совпадает с импортируемой. Заменяем на: " i-unit-cli chr(10).
      ub.doc-line.unit-cli = i-unit-cli.
    end.
    else do:
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Коэффициент в строке ПН: " ub.doc-line.cli-base-rate
                 " Не совпадает с импортируемым. Заменяем единицу измерения поставщика на основную: " ub.goods.unit-base
                 " и пересчитываем количества поставщика." chr(10).
      assign
        ub.doc-line.unit-cli      = ub.goods.unit-base
        ub.doc-line.cli-qnty      = ub.doc-line.cli-qnty * ub.doc-line.cli-base-rate +
                                 i-qnty * i-cli-base-rate
        ub.doc-line.cli-base-rate = 1
        ub.doc-line.price-cli     = i-price / i-cli-base-rate
        .
    end.
  end.
end.
else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclin in g#lib-trn
(input ub.trn-doc.doc-code
,input ub.goods.artic
,input ub.goods.prod-type
,input ub.goods.prod-code
,input ''
,input 0
,input ''
,input ''
,input ub.goods.prt-root
,input 0
,input 0
,input 0
) no-error
.
  if error-status:error then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted SUBSTITUTE("Ошибка при вызове процедуры crdoclin &1 &2 &3",
                            return-value,
                            error-status:get-message(1),
                            error-status:get-message(2))  + chr(10).
      return error.
  end.
  find first ub.doc-line where ub.doc-line.doc-code  = ub.trn-doc.doc-code and
                            ub.doc-line.artic     = ub.goods.artic      and
                            ub.doc-line.prod-type = ub.goods.prod-type  and
                            ub.doc-line.prod-code = ub.goods.prod-code .
  assign
    ub.doc-line.cli-qnty      = 0
    ub.doc-line.doc-qnty      = 0
    ub.doc-line.fact-qnty     = 0
    ub.doc-line.price-cli     = i-price
    ub.doc-line.unit-cli      = i-unit-cli
    ub.doc-line.cli-base-rate = i-cli-base-rate
    ub.doc-line.cli-qnty      = i-qnty
    ub.doc-line.wt-brutto     = i-wt-brutto
    ub.doc-line.num-place     = i-num-place
    .
end.
assign
  ub.doc-line.VAT-pc        = v-VAT-pc
  ub.doc-line.SLT-pc        = v-SLT-pc
  .
find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = ub.doc-line.doc-code and
                                  bf_doc-line-attr.gds-code  = ub.goods.gds-code    and
                                  bf_doc-line-attr.attr-code = "last-date"        no-error.
if not available bf_doc-line-attr and i-last-date <> ? then do:
   create bf_doc-line-attr.
   assign
     bf_doc-line-attr.doc-code   = ub.doc-line.doc-code
     bf_doc-line-attr.gds-code   = ub.goods.gds-code
     bf_doc-line-attr.attr-code  = "last-date"
     bf_doc-line-attr.attr-value = string(i-last-date)
   .
end.
find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = ub.doc-line.doc-code and
                                  bf_doc-line-attr.gds-code  = ub.goods.gds-code    and
                                  bf_doc-line-attr.attr-code = "cst-code"        no-error.
if not available bf_doc-line-attr then do:
   create bf_doc-line-attr.
   assign
   bf_doc-line-attr.doc-code   = ub.doc-line.doc-code
   bf_doc-line-attr.gds-code   = ub.goods.gds-code
   bf_doc-line-attr.attr-code  = "cst-code"
   bf_doc-line-attr.attr-value = i-cst-code.
end.
else do:
  if i-cst-code <> "" then do:
   assign
     bf_doc-line-attr.attr-value = i-cst-code
   .
   end.
end.
find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = doc-line.doc-code and
                                  bf_doc-line-attr.gds-code  = goods.gds-code    and
                                  bf_doc-line-attr.attr-code = 'price-prod':U    no-error.
if not available bf_doc-line-attr and i-price-prod <> 0 then do:
   create bf_doc-line-attr.
   assign
     bf_doc-line-attr.doc-code   = doc-line.doc-code
     bf_doc-line-attr.gds-code   = goods.gds-code
     bf_doc-line-attr.attr-code  = 'price-prod':U
     bf_doc-line-attr.attr-value = string(i-price-prod)
   .
end.
else do:
  if  available bf_doc-line-attr and i-price-prod <> 0 then do:
    assign
      bf_doc-line-attr.attr-value = string(i-price-prod)
    .
   end.
end.
find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = doc-line.doc-code and
                                  bf_doc-line-attr.gds-code  = goods.gds-code    and
                                  bf_doc-line-attr.attr-code = 'price-prodvat':U    no-error.
if not available bf_doc-line-attr and i-price-prod-vat <> 0 then do:
   create bf_doc-line-attr.
   assign
     bf_doc-line-attr.doc-code   = doc-line.doc-code
     bf_doc-line-attr.gds-code   = goods.gds-code
     bf_doc-line-attr.attr-code  = 'price-prodvat':U
     bf_doc-line-attr.attr-value = string(i-price-prod-vat)
   .
end.
else do:
  if  available bf_doc-line-attr and i-price-prod-vat <> 0 then do:
    assign
      bf_doc-line-attr.attr-value = string(i-price-prod-vat)
    .
   end.
end.
if string-type = "SCALE" OR
   string-type = "CODE"  then do:
  n-c = ub.gds-prt.node-code.
end.
if string-type = "ITEM" then do:
  find first ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root
       use-index level no-lock no-error.
  do while true:
    n-c = ub.gds-prt.node-code.
    find first ub.gds-prt where ub.gds-prt.upper-code = n-c
         use-index level no-lock no-error.
    if not available ub.gds-prt then
      leave.
  end.
end.
find ub.gds-dtl where
     ub.gds-dtl.doc-code  = ub.trn-doc.doc-code and
     ub.gds-dtl.artic     = ub.goods.artic and
     ub.gds-dtl.prod-code = ub.goods.prod-code and
     ub.gds-dtl.prod-type = ub.goods.prod-type and
     ub.gds-dtl.prt-code  = n-c no-error.
if not available ub.gds-dtl then do:
  assign counter = counter + 1.
  create ub.gds-dtl .
  assign
    ub.gds-dtl.obj-type      = ub.trn-doc.obj-type
    ub.gds-dtl.obj-code      = ub.trn-doc.obj-code
    ub.gds-dtl.doc-code      = ub.trn-doc.doc-code
    ub.gds-dtl.artic         = ub.goods.artic
    ub.gds-dtl.prod-code     = ub.goods.prod-code
    ub.gds-dtl.prod-type     = ub.goods.prod-type
    ub.gds-dtl.prt-code      = n-c
  .
end.
assign
  ub.doc-line.obj-type      = v-obj-type
  ub.doc-line.obj-code      = v-obj-code
  ub.doc-line.doc-qnty      = ub.doc-line.doc-qnty + (i-qnty * i-cli-base-rate)
  ub.doc-line.fact-qnty     = ub.doc-line.doc-qnty
  ub.doc-line.cli-base-rate = ub.doc-line.doc-qnty / ub.doc-line.cli-qnty
  ub.gds-dtl.doc-qnty       = ub.gds-dtl.doc-qnty + (i-qnty * i-cli-base-rate)
  ub.gds-dtl.fact-qnty      = ub.gds-dtl.doc-qnty
  count-upd              = count-upd + 1
  .
if string-type = "PART" then do:
  create ub.parts .
  buffer-copy   ub.doc-line  EXCEPT status_ to ub.parts
  assign
    ub.parts.out-code  = ub.doc-line.doc-code
    ub.parts.part-code = i-part-code
    ub.parts.cst-code  = i-cst-code
    ub.parts.last-date = i-last-date
    ub.parts.cli-qnty  = i-qnty
    ub.parts.qnty      = i-qnty * ub.doc-line.cli-base-rate
    ub.parts.fact-qnty = ub.parts.qnty
    ub.parts.dop       = substitute("&1;&2" ,i-price-prod,i-price-prod-vat )
  .
end.
for each ub.gds-dtl exclusive-lock where
        ub.gds-dtl.doc-code  = ub.trn-doc.doc-code and
        ub.gds-dtl.obj-type  = ub.trn-doc.obj-type and
        ub.gds-dtl.obj-code  = ub.trn-doc.obj-code and
        ub.gds-dtl.doc-code  = ub.trn-doc.doc-code and
        ub.gds-dtl.artic     = ub.goods.artic      and
        ub.gds-dtl.prod-code = ub.goods.prod-code  and
        ub.gds-dtl.prod-type = ub.goods.prod-type
        :
  find first ub.gds-prt no-lock  where ub.gds-prt.node-code = ub.gds-dtl.prt-code no-error .
  if not available ub.gds-prt then do:
    delete ub.gds-dtl .
  end.
end.
end procedure.
procedure imp-overvalue:
define variable v-price like ub.price-list.price-sale no-undo.
define variable v-bar-code as integer no-undo.
define variable  main-b-code  as integer   no-undo .
define buffer main_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf_gds-obj for ub.gds-obj  .
define buffer bf_bar-code for ub.bar-code  .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
find ub.price-doc-forming-gds where
     ub.price-doc-forming-gds.plt-id     = plt-id         and
     ub.price-doc-forming-gds.plt-db-num = plt-db-num     and
     ub.price-doc-forming-gds.pdf-id     = pdf-id         and
     ub.price-doc-forming-gds.pdf-db     = pdf-db         and
     ub.price-doc-forming-gds.b-code     = ub.bar-code.b-code no-error.
if available ub.price-doc-forming-gds then do:
  if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Уже есть в данной переоценке. Цена: " ub.price-doc-forming-gds.price-sale-doc " Скидка: " ub.price-doc-forming-gds.d-pcnt " Заменяем цену, скидку." chr(10).
  count-upd = count-upd + 1.
end.
  define buffer buf_goods for ub.goods .
  find first buf_goods no-lock
    where buf_goods.gds-code = ub.bar-code.gds-code
    .
  assign
    counter = counter + 1
  .
  v-price    = i-price .
  v-bar-code = ub.bar-code.b-code  .
     find first bf_bar-code where bf_bar-code.b-code = v-bar-code
     no-lock no-error.
     if not available bf_bar-code then do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted SUBSTITUTE("Отсутствует БК для товара с bar-code: &1 &2 &3",
                    return-value,
                     v-bar-code,
                     error-status:get-message(1))  + chr(10).
         return .
     end.
     find first buf_goods where buf_goods.gds-code = bf_bar-code.gds-code  no-lock no-error.
     if not available buf_goods then do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted SUBSTITUTE("Отсутствует товар с gds-code: &1 &2 &3",
                    bf_bar-code.gds-code ,
                    return-value,
                    error-status:get-message(1))  + chr(10).
     end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output main-b-code
  )  .
      find first buf_price-doc-forming-gds exclusive-lock where
                 buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
            and  buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
            and  buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id
            and  buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db
            and  buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code no-error .
      if available buf_price-doc-forming-gds then do:
        delete buf_price-doc-forming-gds.
      end.
      imp-save = imp-save + 1 .
      if buf_goods.unit-base = bf_bar-code.unit-cli then do:
          find first buf_price-doc-forming-gds exclusive-lock where
                     buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
                and  buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
                and  buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id
                and  buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db
                and  buf_price-doc-forming-gds.b-code     = main-b-code no-error .
          if not available buf_price-doc-forming-gds then do:
          run prcreate-new-price-doc-forming-gds in this-procedure (
              input recid ( buf_price-doc-forming )
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , input par-pr-notls
            , input par-pr-altex
            , input par-pr-sclex
            , input imp-save
            , input buf_goods.gds-code
            , input v-price
            ) no-error.
            if error-status :error then do:
                if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted SUBSTITUTE("prcreate-new-price-doc-forming-gds: &1 &2",
                          return-value,
                          error-status:get-message(1))  + chr(10).
            end.
            end.
            if main-b-code  <>  bf_bar-code.b-code then do:
                find first buf_price-doc-forming-gds exclusive-lock where
                          buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                          buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                          buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                          buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                          buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code no-error .
                if available buf_price-doc-forming-gds then do:
                  delete buf_price-doc-forming-gds .
                end.
                imp-save = imp-save + 1.
                v-sec =  v-sec + 1 .
                  run create-line-pdf-mpl-lib (
                      input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input imp-save
                      ,input bf_bar-code.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input v-price
                      ,input ""
                      ,input 0
                      ,input-output v-sec ) no-error .
            end.
        end.
        else do:
        find first main_price-doc-forming-gds no-lock where
                   main_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   main_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   main_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   main_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   main_price-doc-forming-gds.b-code     = main-b-code no-error .
        if not available main_price-doc-forming-gds then do:
        find first buf_gds-obj no-lock where
                   buf_gds-obj.obj-type = v-cntxt-obj-type  and
                   buf_gds-obj.obj-code = v-cntxt-obj-code  and
                   buf_gds-obj.gds-code = buf_goods.gds-code     no-error .
        run prcreate-new-price-doc-forming-gds in this-procedure (
            input recid ( buf_price-doc-forming )
          , input v-cntxt-obj-type
          , input v-cntxt-obj-code
          , input par-pr-notls
          , input par-pr-altex
          , input par-pr-sclex
          , input imp-save
          , input buf_goods.gds-code
          , input ( if available buf_gds-obj and buf_gds-obj.price-sale <> 0 then buf_gds-obj.price-sale else v-price / bf_bar-code.cli-base-rate )
          ) no-error.
          if error-status :error then do:
                if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted SUBSTITUTE("Создание основного кода для неосновному: &1 &2",
                          return-value,
                          error-status:get-message(1))  + chr(10).
          end.
        end.
        find first buf_price-doc-forming-gds exclusive-lock where
                   buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code no-error .
        if available buf_price-doc-forming-gds then do:
           delete buf_price-doc-forming-gds .
        end.
        imp-save = imp-save + 1.
        v-sec =  v-sec + 1 .
        run create-line-pdf-mpl-lib (
             input buf_price-doc-forming.plt-db-num
            ,input buf_price-doc-forming.plt-id
            ,input buf_price-doc-forming.pdf-db
            ,input buf_price-doc-forming.pdf-id
            ,input imp-save
            ,input bf_bar-code.b-code
            ,input buf_goods.artic
            ,input buf_goods.prod-type
            ,input buf_goods.prod-code
            ,input ""
            ,input 0
            ,input v-price
            ,input ""
            ,input 0
            ,input-output v-sec ) no-error .
            if error-status :error then do:
                if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      ub.goods.artic   " Производитель : "                ub.goods.prod-type   " "                                ub.goods.prod-code   " Код товара : "                   ub.goods.gds-code   " Основная единица измерения : "   ub.goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).     msg-line = count-all.   end.   put stream err unformatted SUBSTITUTE("неосновной код: &1 &2",
                          return-value,
                          error-status:get-message(1))  + chr(10).
            end.
        find first buf_price-doc-forming-gds exclusive-lock where
                   buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code
                   no-error .
        find first main_price-doc-forming-gds no-lock where
                   main_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   main_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   main_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   main_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   main_price-doc-forming-gds.b-code     = main-b-code
                   no-error .
        if available buf_price-doc-forming-gds then do:
           buf_price-doc-forming-gds.d-pcnt =
           (( (main_price-doc-forming-gds.price-sale-doc * bf_bar-code.cli-base-rate) - v-price  ) * 100) /
             ( main_price-doc-forming-gds.price-sale-doc * bf_bar-code.cli-base-rate) no-error .
        end.
        end.
end procedure.
procedure delete-trn-doc :
  do
  on error undo, return error
  :
    for each ub.doc-line
      where ub.doc-line.doc-code = ub.trn-doc.doc-code
    on error undo, return error
    :
      delete ub.doc-line .
    end.
    for each ub.gds-dtl
      where ub.gds-dtl.doc-code = ub.trn-doc.doc-code
    on error undo, return error
    :
      delete ub.gds-dtl .
    end.
    delete ub.trn-doc .
  end.
end procedure.
