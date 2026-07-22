block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-unit-type-list as character no-undo .
define input parameter p-gds-type-list  as character no-undo .
define output parameter p-lns-cnt as integer no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: gdsunitt.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/gdsunitt.p $":U .
def var vss-description as character no-undo init "Дополняет в список товары c указанным типом единицы измерения.".
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
define shared temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table gds-list-hist no-undo
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
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
def var ind as integer no-undo .
do ind = 1 to num-entries(p-unit-type-list) :
  def var v-unit-type as character no-undo .
  assign
    v-unit-type = entry(ind, p-unit-type-list)
  .
  if not can-do( 'шту,дро,сер,вес,топ,2ед,прп,доп,сте':U, v-unit-type) then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный тип единицы измерения v-unit-type" skip
      "v-unit-type" v-unit-type skip
      "p-unit-type-list" p-unit-type-list skip
      "unit-types" 'штучный,дробный,серийный,весовой,топливо,2едизма,прпарт,дополнительный,стеклопосуда':U skip
      view-as alert-box error .
    undo, return error .
  end.
  for each ub.units no-lock
    where can-do( ub.units.type, v-unit-type )
  , each ub.goods no-lock
    where ub.goods.unit-base = ub.units.unit-name
      and can-do(p-gds-type-list, ub.goods.gds-type)
  :
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = goods.prod-type
    and gds-list.prod-code = goods.prod-code
    and gds-list.artic     = goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last2 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last2 = gds-list.order-num .
  end.
  else do:
    v-last2 = 0 .
  end.
  create gds-list .
  buffer-copy goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last2 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
    p-lns-cnt = lns-cnt.
  end.
end.
