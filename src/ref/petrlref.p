block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: petrlref.p $
$Archive: ref/petrlref.p $

Список топлив в механизме списка товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/20/07
Author: Bakhtadze Natalya
Creation date: 04/20/07

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as character no-undo .
define output parameter p-rid-list as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: petrlref.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/petrlref.p $":U .
define variable vss-description as character no-undo init "Список топлив в механизме списка товаров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/runanlst.i }
{ cmp/gds-list.i gds-list def "new shared" }

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
  buf_macro-list-hist.status_    = {&all}
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
  v-bttns = v-bttns + (if v-bttns = '':U then '':U else {&comma-char}) +
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
                  else {&comma-char}) + string(recid(buf_goods))
    .
  end.
end. /*doe*/