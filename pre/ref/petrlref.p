block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as character no-undo .
define output parameter p-rid-list as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: petrlref.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/petrlref.p $":U .
define variable vss-description as character no-undo init "Список топлив в механизме списка товаров".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define     temp-table macro-list-hist no-undo
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
PROCEDURE request-create-macro-list-hist :
DEFINE INPUT PARAMETER p-child-handle AS HANDLE NO-UNDO.
define buffer buf_macro-list-hist for macro-list-hist.
for each buf_macro-list-hist :
   RUN proc-create-macro-list-hist IN p-child-handle (
                                                       input buf_macro-list-hist.list-table
                                                      ,input buf_macro-list-hist.id
                                                      ,input buf_macro-list-hist.line
                                                      ,input buf_macro-list-hist.hist-mode
                                                      ,input buf_macro-list-hist.des
                                                      ,input buf_macro-list-hist.option_
                                                      ,input buf_macro-list-hist.item_
                                                      ,input buf_macro-list-hist.status_
                                                       ) no-error .
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-ii as integer no-undo .
define variable v-bttns as character no-undo .
define buffer buf_macro-list-hist for macro-list-hist.
define buffer buf_gds-list for gds-list.
define buffer buf_goods for ub.goods.
do
on error undo, return error
:
  for each buf_macro-list-hist:
    delete buf_macro-list-hist.
  end.
  for each gds-list-hist:
    delete gds-list-hist.
  end.
  create buf_macro-list-hist.
  assign
  buf_macro-list-hist.list-table = '':U
  buf_macro-list-hist.id         = 1
  buf_macro-list-hist.line       = 0
  buf_macro-list-hist.hist-mode  = '+'
  buf_macro-list-hist.option_    = "is-ptrl"
  buf_macro-list-hist.status_    = 'все':U
  buf_macro-list-hist.des        = "ВСЕ товары-топлива"
  buf_macro-list-hist.item_      = "":U
  .
  release buf_macro-list-hist.
  for each gds-list:
    delete gds-list.
  end.
  assign
  v-bttns = (if lookup("b-sel", bttns) > 0
             then "b-sel"
             else '':U)
  v-bttns = v-bttns + (if v-bttns = '':U then '':U else chr(44)) +
          (if lookup("b-mark", bttns) > 0
                    then "b-mark"
                    else '':U)
  .
  run str/gdsqlist.w (
                   input parparentproc
                  ,input this-procedure:handle
                  ,input v-cntxt-host-code-obj
                  ,input v-cntxt-obj-type
                  ,input v-cntxt-obj-code
                  ,input v-bttns
                  ,input "ВСЕ товары-топлива"
                  ,input yes
                  ).
  find first gds-list where
           gds-list.to-sel = yes no-error.
  if not available gds-list then return '':U.
  for each buf_gds-list
       where buf_gds-list.to-sel = yes,
      FIRST buf_goods NO-LOCK WHERE
            buf_goods.gds-code = gds-list.gds-code :
    assign
    v-ii = v-ii + 1
    p-rid-list = P-RID-LIST + (if v-ii = 1
                  then '':U
                  else chr(44)) + string(recid(buf_goods))
    .
  end.
end.
