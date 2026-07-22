block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: 7b0cc5f31b3c, 1617, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Tue Nov 06 04:41:38 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-gds-draw.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-gds-draw.p $":U .
define variable vss-description as character no-undo init "Простая пересылка товаров на кассу по списку товаров":U.
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
define new shared variable himp2Cd as handle no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   new shared   temp-table dc-list-hist no-undo
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
define new shared temp-table dc-dis-card-mask no-undo like ub.dis-card-mask.
define new shared temp-table dc-dis-card-mask-attr no-undo like ub.dis-card-mask-attr.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def  new shared  temp-table dcp-list no-undo like ub.dis-card-property
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index d-card-i is primary d-card host-code obj-type obj-code dt-code node-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def  new shared  temp-table stpl-list no-undo like ub.stop-list
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index pi is primary classif-type stop-list-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared temp-table pbc-list no-undo like ub.prod-bc
                        field rc as recid
                        field del as  logical
                        index rci is unique rc del
                        index gds-code-i b-code del
                        index ibc-on-type bc-on-type
                        .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared temp-table bc-list no-undo like ub.bar-code
                        field del as  logical
                        index bc is unique b-code del
                        index gds-code-i gds-code del.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gdsolist no-undo like ub.goods
field qnty   as decimal
field to-del as logical
field order-num as integer
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index art  is primary unique artic prod-type prod-code obj-type obj-code
index code is         unique gds-code obj-type obj-code
index oi order-num
index iobj obj-type obj-code gds-code
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE cash-txn no-undo
FIELD tax-code like ub.tax.tax-code
FIELD tax-name like ub.tax.tax-name
FIELD news-action as logical
index pi IS UNIQUE PRIMARY tax-code.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table cash-txr no-undo
  field tax-code    like ub.tax.tax-code
  field rate-code   like ub.tax-rate.rate-code
  field host-code   like ub.sysconf.host-code
  field obj-type    like ub.clients.obj-type
  field obj-code    like ub.clients.obj-code
  field tax-type    like ub.tax.tax-type
  field status_     like ub.tax-rate-value.status_
  field rate-value  as decimal
  field rc          as recid
  field crf         as integer
  field news-action as logical
  index pi is unique primary tax-code host-code obj-type obj-code status_ rc
  index crf-i  crf host-code obj-type obj-code rc
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table pdf-list no-undo like ub.price-doc-forming
field to-del     as logical
field order-num  as integer
index pi  is primary unique plt-id plt-db-num pdf-id pdf-db
index oi order-num
.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE cash-pay-list no-undo
FIELD cdpay-code as integer
FIELD curr-code as integer
index pi IS PRIMARY unique cdpay-code curr-code
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE ext-classif-list no-undo
   FIELD db-num as integer
   field Key#One as integer
   field Key#Two as integer
   field CharKey_One as character
index pi IS PRIMARY unique db-num Key#Two Key#One CharKey_One
.
DEFINE new shared TEMP-TABLE c-ext-classif-list no-undo
   FIELD db-num as integer
   field Key#One as integer
   field Key#Two as integer
   field CharKey_One as character
   field chip-num as integer
index pi IS PRIMARY unique db-num Key#Two Key#One CharKey_One chip-num
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE PromoAction-list no-undo
FIELD ID as int64
FIELD db-num as integer
FIELD del_ as logical
index pi IS PRIMARY unique ID db-num
.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new shared TEMP-TABLE thbjattr-list no-undo like ub.thbj-attr .
define new shared var sendEMRC   as logical no-undo.
define new shared var settingUpd as logical no-undo.
define new shared var sendMarkType as logical no-undo.
define new shared var sendGisMt as logical no-undo.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure send-to-cash:
  if not can-find(first ub.cash-desk where
                  ub.cash-desk.db-num = ibs.th.gbl.gbl-var:g#db-num AND
                  ub.cash-desk.cash-on = yes) then return.
  do
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    if can-find(first gds-list no-lock)
    or can-find(first gdsolist no-lock)
    or can-find(first bc-list no-lock)
    or can-find(first pbc-list no-lock)
    or can-find(first cash-txn no-lock)
    or can-find(first cash-txr no-lock)
    or can-find(first dc-list no-lock)
    or can-find(first dc-dis-card-mask no-lock)
    or can-find(first stpl-list no-lock)
    or can-find(first pdf-list no-lock)
    or can-find(first cash-pay-list no-lock)
    or can-find(first ext-classif-list no-lock)
    or can-find(first c-ext-classif-list no-lock)
    or can-find(first PromoAction-list no-lock)
    or can-find(first thbjattr-list no-lock)
    or sendEMRC
    or settingUpd
    or sendMarkType
    then do:
      run str/diallog.w (
                         input parparentproc
                        ,input ?
                        ,input 'str/sendnall.p':U
                        ,input string(ibs.th.gbl.gbl-var:g#db-num)
                        ,input yes
                        ,input '':U
                        ,input 'Отправка информации на кассу') no-error .
    end.
  end.
end procedure.
procedure fill-setting :
   define input parameter i-obj      as character no-undo .
   define input parameter i-obj-type as character no-undo .
   define input parameter i-obj-code as integer   no-undo .
   define input parameter i-parent   as character no-undo .
   define input parameter i-code     as character no-undo .
   define buffer buf_thbj-attr for ub.thbj-attr.
   define buffer buf_sys-ctrl for ub.sys-ctrl.
   define buffer buf_clients for ub.clients.
   define variable v-db-num    as integer no-undo.
   define variable v-shop-code as integer no-undo.
   define variable v-reg-code  as integer no-undo.
   settingUpd = yes.
   sendGisMt = no.
   if i-obj = "thbj-attr"
   then do:
      v-db-num  = ibs.th.gbl.gbl-var:g#db-num.
      if v-db-num <> 0 then do:
          find first buf_clients no-lock
               where buf_clients.obj-type = 'маг':U
                 and buf_clients.db-num   = v-db-num
             no-error.
          if available buf_clients then v-shop-code = buf_clients.obj-code.
      end.
   end.
   if i-obj = "thbj-attr" and
      (i-parent = 'gisMT':U or i-parent = 'marking':U)
   then do:
      if i-parent = 'gisMT':U and i-obj-type = "" and i-obj-code = 0 then do:
          if not can-find(first buf_thbj-attr no-lock where
                                buf_thbj-attr.obj-type = 'БД':U
                            and buf_thbj-attr.obj-code = v-db-num
                            and buf_thbj-attr.upper-prop-code = i-parent
                            and buf_thbj-attr.prop-code = i-code)
          then sendGisMt = yes.
      end.
      if i-parent = 'gisMT':U and i-obj-type = 'регион':U then do:
          sendGisMt = yes.
      end.
      else if (i-parent = 'gisMT':U and i-obj-type = 'БД':U and i-obj-code = v-db-num)
         then sendGisMt = yes.
      else if i-parent = 'marking':U and i-obj-type = 'маг':U and i-obj-code = v-shop-code
         then sendGisMt = yes.
      else if i-parent = 'marking':U and i-obj-type = "" then do:
          if not can-find(first buf_thbj-attr no-lock where
                                buf_thbj-attr.obj-type = 'маг':U
                            and buf_thbj-attr.obj-code = v-shop-code
                            and buf_thbj-attr.upper-prop-code = i-parent
                            and buf_thbj-attr.prop-code = i-code)
          then sendGisMt = yes.
      end.
      if sendGisMt = yes then do:
          if not can-find(first thbjattr-list where
                                thbjattr-list.obj-type = i-obj-type
                            and thbjattr-list.obj-code = i-obj-code
                            and thbjattr-list.upper-prop-code = i-parent
                            and thbjattr-list.prop-code = i-code)
          then do:
              create thbjattr-list.
              assign
                 thbjattr-list.obj-type = i-obj-type
                 thbjattr-list.obj-code = i-obj-code
                 thbjattr-list.upper-prop-code = i-parent
                 thbjattr-list.prop-code = i-code
                 .
          end.
      end.
   end.
end procedure.
procedure fill-code :
   define input parameter i-parent as character no-undo .
   define input parameter i-code   as character no-undo .
   if i-parent begins "EMC"
   then
      sendEMRC = yes.
   if i-parent begins "MarkType"
   then
      sendMarkType = yes.
end procedure.
procedure fill-gds-list :
define parameter buffer buf_goods for ub.goods.
do
on error undo, return error
:
  for first gds-list where gds-list.gds-code = buf_goods.gds-code:
    delete gds-list.
  end.
  create gds-list.
  buffer-copy buf_goods to gds-list no-error.
  if error-status:error then message error-status:get-message(1) view-as alert-box.
  release gds-list.
end.
end procedure.
procedure fill-dc-list :
define parameter buffer buf_dis-card for ub.dis-card .
do
on error undo, return error
:
  find first dc-list where
            dc-list.d-card = buf_dis-card.d-card no-lock no-error.
  if not available dc-list then do:
    create dc-list.
    buffer-copy buf_dis-card to dc-list.
    release dc-list.
  end.
end.
end procedure.
procedure fill-dc-list-mask :
define parameter buffer buf_dis-card-mask for ub.dis-card-mask .
do
on error undo, return error
:
   find first dc-list where
            dc-list.d-card = buf_dis-card-mask.mask no-lock no-error.
   if not available dc-list
   then do:
      find first ub.dis-card no-lock where
                 ub.dis-card.d-card = buf_dis-card-mask.mask no-error .
      if  available dis-card
      then
         run fill-dc-list(buffer dis-card) .
   end.
  find first dc-dis-card-mask where
             dc-dis-card-mask.mask-num = buf_dis-card-mask.mask-num no-lock no-error.
  buffer-copy buf_dis-card-mask to dc-dis-card-mask.
  release dc-dis-card-mask.
end.
end procedure.
procedure fill-dc-list-mask-attr :
define parameter buffer buf_dis-card-mask-attr for ub.dis-card-mask-attr .
define buffer dis-card-mask for ub.dis-card-mask .
do
on error undo, return error
:
  find first dc-dis-card-mask where
             dc-dis-card-mask.mask-num = buf_dis-card-mask-attr.mask-num no-lock no-error.
  if not available dc-dis-card-mask
  then do:
     find first dis-card-mask where dis-card-mask.mask-num eq buf_dis-card-mask-attr.mask-num no-lock no-error.
     if available dis-card-mask
     then
        run  fill-dc-list-mask (buffer dis-card-mask).
  end.
  find first dc-dis-card-mask-attr where
            dc-dis-card-mask-attr.mask-num  = buf_dis-card-mask-attr.mask-num
       and  dc-dis-card-mask-attr.attr-code = buf_dis-card-mask-attr.attr-code
            no-lock no-error.
  buffer-copy buf_dis-card-mask-attr to dc-dis-card-mask-attr.
  release dc-dis-card-mask-attr.
end.
end procedure.
procedure fill-dc-list-attr :
define input parameter p-d-card as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
do
on error undo, return error
:
  find first dc-list where
            dc-list.d-card = p-d-card no-error .
  if not avail dc-list then do:
    create dc-list.
    assign
    dc-list.d-card = p-d-card
    dc-list.emitent-host-code = p-emitent-host-code
    .
    release dc-list.
  end.
end.
end procedure.
procedure fill-cash-pay :
define input parameter p-cdpay-code as integer no-undo .
define input parameter p-curr-code  as integer no-undo .
do
on error undo, return error
:
  if not can-find( cash-pay-list where cash-pay-list.cdpay-code = p-cdpay-code
                                   and cash-pay-list.curr-code  = p-curr-code )
  then do:
    create cash-pay-list.
    assign
       cash-pay-list.cdpay-code = p-cdpay-code
       cash-pay-list.curr-code  = p-curr-code
    .
    release cash-pay-list.
  end.
end.
end procedure.
procedure fill-PromoAction :
define input parameter p-id as int64 no-undo .
define input parameter p-db-num  as integer no-undo .
do
on error undo, return error
:
  if not can-find( PromoAction-list where PromoAction-list.id = p-id
                                      and PromoAction-list.db-num  = p-db-num )
  then do:
    create PromoAction-list.
    assign
       PromoAction-list.id = p-id
       PromoAction-list.db-num  = p-db-num
    .
    release PromoAction-list.
  end.
end.
end procedure.
procedure fill-ext-classif:
define input parameter p-db-num as integer no-undo .
define input parameter p-Key#One  as integer no-undo .
define input parameter p-Key#Two  as integer no-undo .
define input parameter p-CharKey_One  as character no-undo .
do
on error undo, return error
:
  if not can-find( ext-classif-list where ext-classif-list.db-num = p-db-num
                                   and ext-classif-list.Key#One  = p-Key#One
                                   and ext-classif-list.Key#Two = p-Key#Two
                                   and ext-classif-list.CharKey_One = p-CharKey_One )
  then do:
    create ext-classif-list.
    assign
    ext-classif-list.db-num = p-db-num
    ext-classif-list.Key#One  = p-Key#One
    ext-classif-list.Key#Two = p-Key#Two
    ext-classif-list.CharKey_One = p-CharKey_One
    .
    release ext-classif-list.
  end.
end.
end procedure.
procedure fill-c-ext-classif:
define input parameter p-db-num as integer no-undo .
define input parameter p-Key#One  as integer no-undo .
define input parameter p-Key#Two  as integer no-undo .
define input parameter p-CharKey_One  as character no-undo .
define input parameter p-chip-num as integer no-undo .
do
on error undo, return error
:
  if not can-find( c-ext-classif-list where c-ext-classif-list.db-num = p-db-num
                                   and c-ext-classif-list.Key#One  = p-Key#One
                                   and c-ext-classif-list.Key#Two = p-Key#Two
                                   and c-ext-classif-list.CharKey_One = p-CharKey_One
                                   and c-ext-classif-list.chip-num = p-chip-num )
  then do:
    create c-ext-classif-list.
    assign
        c-ext-classif-list.db-num = p-db-num
        c-ext-classif-list.Key#One  = p-Key#One
        c-ext-classif-list.Key#Two = p-Key#Two
        c-ext-classif-list.CharKey_One = p-CharKey_One
        c-ext-classif-list.chip-num = p-chip-num
    .
    release c-ext-classif-list.
  end.
end.
end procedure.
procedure fill-g-list :
define input parameter p-gds-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define buffer buf_goods for ub.goods.
do
on error undo, return error
:
  find first gds-list where
            gds-list.gds-code = p-gds-code no-error .
  if not avail gds-list then do:
    if p-obj-type = 'маг':U then do:
      find first gdsolist where
                gdsolist.gds-code = p-gds-code
          AND  gdsolist.obj-type = p-obj-type
          AND  gdsolist.obj-code = p-obj-code   no-error .
    end.
    else do:
      find first buf_goods no-lock where
                  buf_goods.gds-code = p-gds-code no-error .
      create gds-list.
      buffer-copy buf_goods to gds-list.
    end.
  end.
  if p-obj-type = 'маг':U and not avail gdsolist then do:
    find first gdsolist where
              gdsolist.gds-code = p-gds-code
        AND  gdsolist.obj-type = p-obj-type
        AND  gdsolist.obj-code = p-obj-code   no-error .
    if not available gdsolist then do:
      find first buf_goods no-lock where
                  buf_goods.gds-code = p-gds-code no-error .
      if avail buf_goods then do:
        create gdsolist.
        buffer-copy buf_goods to gdsolist
        assign
        gdsolist.obj-type = p-obj-type
        gdsolist.obj-code = p-obj-code
        .
      end.
    end.
  end.
  if avail gdsolist then do:
    assign
    gdsolist.to-del = no
    .
    release gdsolist.
  end.
  if avail gds-list then do:
    assign
    gds-list.to-del = no
    .
    release gds-list.
  end.
end.
end procedure.
procedure fill-cash-txn :
define parameter buffer buf_tax for ub.tax.
do
on error undo, return error
:
  if not can-find( cash-txn where
                  cash-txn.tax-code = buf_tax.tax-code
              and cash-txn.tax-name = buf_tax.tax-name
                 ) then do:
    create cash-txn.
    assign
    cash-txn.tax-code = buf_tax.tax-code
    cash-txn.tax-name = buf_tax.tax-name
    .
    release cash-txn.
  end.
end.
end procedure.
procedure fill-cash-txr :
define input parameter p-tax-code as integer no-undo .
define input parameter p-rate-code as integer no-undo .
define input parameter p-status_ as character no-undo .
define input parameter p-host-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-tax-type as character no-undo .
define input parameter p-value as decimal no-undo .
define input parameter p-crf as integer no-undo .
define input parameter p-rec as recid no-undo .
define buffer buf_tax for ub.tax.
do
on error undo, return error
:
  find first cash-txr where
          cash-txr.tax-code = p-tax-code
      AND cash-txr.host-code = p-host-code
      AND cash-txr.rate-code = p-rate-code
      AND cash-txr.obj-type = p-obj-type
      AND cash-txr.obj-code = p-obj-code
      AND cash-txr.rc = p-rec no-error .
  if not avail cash-txr then do:
    find first  cash-txn where
                    cash-txn.tax-code = p-tax-code no-error .
    if not available cash-txn then do:
      find first buf_tax no-lock where buf_tax.tax-code = p-tax-code.
      create cash-txn.
      assign
      cash-txn.tax-code = buf_tax.tax-code
      cash-txn.tax-name = buf_tax.tax-name
      .
      release cash-txn.
      define variable II as integer no-undo.
      find last  cash-txr where cash-txr.crf > 0 no-error.
      if available cash-txr
      then
         II = cash-txr.crf + 1.
      else
         II = 1.
         _tax-rate:
      FOR EACH ub.tax-rate NO-LOCK WHERE
                          ub.tax-rate.tax-code = buf_tax.tax-code
                      and ub.tax-rate.status_  <>   'удал':U:
                        create cash-txr.
                        assign
                        cash-txr.tax-code = tax-rate.tax-code
                        cash-txr.rate-code = tax-rate.rate-code
                        cash-txr.tax-type = buf_tax.tax-type
                        cash-txr.host-code = p-host-code
                        cash-txr.obj-type = p-obj-type
                        cash-txr.obj-code = p-obj-code
                        cash-txr.status_ = tax-rate.status_
                        cash-txr.rc = RECID(tax-rate)
                        cash-txr.crf = ii
                        ii = ii + 1
                        .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  recid(ub.tax-rate)
  ,input  0
  ,input  0
  ,input  ?
  ,input  p-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output cash-txr.rate-value
  ) no-error .
                        if error-status:error then next _tax-rate.
       END.
    end.
    else do:
       for each cash-txr where cash-txr.tax-code = tax-rate.tax-code:
          delete cash-txr.
       end.
       _tax-rate2:
        FOR EACH ub.tax-rate NO-LOCK WHERE
                          ub.tax-rate.tax-code = buf_tax.tax-code
                      and ub.tax-rate.status_  <>   'удал':U:
                        create cash-txr.
                        assign
                        cash-txr.tax-code = tax-rate.tax-code
                        cash-txr.rate-code = tax-rate.rate-code
                        cash-txr.tax-type = buf_tax.tax-type
                        cash-txr.host-code = p-host-code
                        cash-txr.obj-type = p-obj-type
                        cash-txr.obj-code = p-obj-code
                        cash-txr.status_ = tax-rate.status_
                        cash-txr.rc = RECID(tax-rate)
                        cash-txr.crf = ii
                        ii = ii + 1
                        .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  recid(ub.tax-rate)
  ,input  0
  ,input  0
  ,input  ?
  ,input  p-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output cash-txr.rate-value
  ) no-error .
                        if error-status:error then next _tax-rate2.
       END.
    end.
    find first cash-txr where
          cash-txr.tax-code = p-tax-code
      AND cash-txr.rate-code = p-rate-code
      no-error .
    if not avail cash-txr and  p-status_ <> 'удал':U
    then do:
       create cash-txr.
       assign
       cash-txr.tax-code  = p-tax-code
       cash-txr.rate-code = p-rate-code
       cash-txr.host-code = p-host-code
       cash-txr.obj-type  = p-obj-type
       cash-txr.obj-code  = p-obj-code
       cash-txr.tax-type  = p-tax-type
       cash-txr.crf       = p-crf
       cash-txr.rc        = p-rec
       cash-txr.status_   = (if p-status_ = ? then 'тек':U else p-status_)
       .
    end.
    if  avail cash-txr
    then do:
       if p-status_ eq 'удал':U
       then
          delete cash-txr.
       else assign
       cash-txr.tax-code  = p-tax-code
       cash-txr.rate-code = p-rate-code
       cash-txr.host-code = p-host-code
       cash-txr.obj-type  = p-obj-type
       cash-txr.obj-code  = p-obj-code
       cash-txr.tax-type  = p-tax-type
       cash-txr.crf       = p-crf
       cash-txr.rc        = p-rec
       cash-txr.status_   = (if p-status_ = ? then 'тек':U else p-status_)
       .
    end.
    release cash-txr.
  end.
end.
end procedure.
procedure fill-stpl-list :
define parameter buffer buf_stop-list for ub.stop-list.
do
on error undo, return error
:
  find first stpl-list where
            stpl-list.classif-type =  buf_stop-list.classif-type
        and stpl-list.stop-list-code = buf_stop-list.stop-list-code no-error .
  if not avail stpl-list then do:
    create stpl-list.
    buffer-copy buf_stop-list
    to stpl-list.
    release stpl-list.
  end.
end.
end procedure.
procedure fill-pbc-list :
define input parameter p-rc as recid no-undo .
define input parameter p-gds-code as integer no-undo .
define input parameter p-b-code as integer no-undo .
define input parameter p-b-str as character no-undo .
define input parameter p-bc-on as logical no-undo .
define input parameter p-del as logical no-undo .
do
on error undo, return error
:
  if p-bc-on = false
  or p-del = yes
  or not can-find(gds-list where gds-list.gds-code     = p-gds-code
                            no-lock ) then do:
    find first pbc-list where pbc-list.rc = p-rc no-error.
    if not available pbc-list then do:
      create pbc-list.
    end.
    assign
    pbc-list.b-code = p-b-code
    pbc-list.b-str = p-b-str
    pbc-list.rc = p-rc
    pbc-list.bc-on = p-bc-on
    pbc-list.del = p-del
    .
    release pbc-list .
  end.
end.
end procedure.
procedure fill-bar-code :
define input parameter p-b-code as integer no-undo .
define input parameter p-gds-code as integer no-undo .
define input parameter p-del as logical no-undo .
define input parameter p-node-code as integer no-undo .
define input parameter p-in-code as character no-undo .
define input parameter p-part-code as character no-undo .
define input parameter p-cli-base-rate as decimal no-undo .
define input parameter p-unit-cli as character no-undo .
do
on error undo, return error
:
  if p-del = yes
  or not can-find(gds-list where gds-list.gds-code     = p-gds-code
                            no-lock ) then do:
    find first bc-list where
            bc-list.b-code = p-b-code and bc-list.del = p-del no-error.
    if not avail bc-list then do:
      create bc-list.
      assign
      bc-list.gds-code = p-gds-code
      bc-list.b-code = p-b-code
      bc-list.node-code = p-node-code
      bc-list.in-code = p-in-code
      bc-list.part-code = p-part-code
      bc-list.cli-base-rate = p-cli-base-rate
      bc-list.unit-cli = p-unit-cli
      bc-list.del = p-del
      .
    end.
  end.
end.
end procedure.
procedure fill-pdf :
define input parameter p-plt-id as integer no-undo .
define input parameter p-plt-db-num as integer no-undo .
define input parameter p-pdf-id as integer no-undo .
define input parameter p-pdf-db-num as integer no-undo .
define input parameter p-del as logical no-undo .
define buffer buf_pdf-list for pdf-list.
do
on error undo, return error
:
  find first pdf-list where
           pdf-list.plt-id = p-plt-id
       and pdf-list.plt-db-num = p-plt-db-num
       and pdf-list.pdf-id = p-pdf-id
       and pdf-list.pdf-db = p-pdf-db-num no-error.
  if not available pdf-list then do:
    find last buf_pdf-list use-index oi no-error.
    create pdf-list.
    assign
    pdf-list.plt-id = p-plt-id
    pdf-list.plt-db-num = p-plt-db-num
    pdf-list.pdf-id = p-pdf-id
    pdf-list.pdf-db = p-pdf-db-num
    pdf-list.to-del = p-del
    pdf-list.order-num = (if available buf_pdf-list then buf_pdf-list.order-num + 1 else 1)
    .
    release pdf-list.
  end.
end.
end procedure.
for each ub.goods no-lock:
    run fill-gds-list(buffer ub.goods).
end.
run send-to-cash.
