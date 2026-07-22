block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: florline.p $
$Archive: str/florline.p $

Добавление в набор

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 01/26/05

*/
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-mode       as character no-undo .
define input  parameter p-node-code  as integer   no-undo .
define input  parameter p-doc-code   as character no-undo .
define input  parameter p-gds-code   as integer   no-undo .
define input  parameter p-b-gds-code as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: florline.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/florline.p $":U .
define variable vss-description as character no-undo init "Добавление в набор".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/lineattr.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }

define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#rsrv-time as decimal   no-undo .
define variable g#db-remote as logical   no-undo .
define buffer buf_sysconf for ub.sysconf  .

{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
  g#db-remote   = (v-cntxt-db-num <> 0)
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
run get-report-num  in parParentProc ( output g#report-num ).

define buffer buf_goods for goods.
define buffer bk_goods for goods.
define buffer buf_gds-dtl for gds-dtl.
define buffer buf_doc-line-attr for doc-line-attr.
define buffer buf_doc-line for doc-line.
define variable v-value as decimal   no-undo init 0.
define variable v-all-value as decimal   no-undo  init 0.
define variable v-prt-value as decimal   no-undo  init 0.
define variable v-prt-code  as integer   no-undo .

find first bk_goods where bk_goods.gds-code  = p-b-gds-code   no-error .
if error-status :error then return .

find first buf_goods where buf_goods.gds-code  = p-gds-code   no-error .
if error-status :error then return .
/*
message p-mode skip
buf_goods.gds-name skip
bk_goods.gds-name skip
  "flor-line"
  . */

if p-mode = {&add-def} or p-mode = {&update} then do:
    /* добавлено по другим букетам */
    for each buf_gds-dtl no-lock where buf_gds-dtl.doc-code  = p-doc-code      and
                                       buf_gds-dtl.artic     = buf_goods.artic and
                                       buf_gds-dtl.prod-type = buf_goods.prod-type and
                                       buf_gds-dtl.prod-code = buf_goods.prod-code
        :
        v-all-value = 0 .
        for each buf_doc-line-attr no-lock
          where buf_doc-line-attr.doc-code  = p-doc-code
            and buf_doc-line-attr.gds-code  = p-gds-code
            and buf_doc-line-attr.attr-code begins {&lineattr-flora_gds-code} + {&comma-char} + string(buf_gds-dtl.prt-code) + {&comma-char}
            :
            v-all-value = v-all-value + decimal(buf_doc-line-attr.attr-value ) .
        end.
        v-value = buf_gds-dtl.fact-qnty -  v-all-value .

        run lineattr-write-flora-gds (
            input p-doc-code   ,
            input p-gds-code   ,
            input buf_gds-dtl.prt-code ,
            input p-b-gds-code ,
            input {&lineattr-flora_gds-code},
            input v-value ).
    end.
end.