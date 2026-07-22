block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: close-all-trn.p $
$Archive: utl/close-all-trn.p $

Закрытие накладных списком

Автор: Чернова Светлана Александровна
Дата создания: 07/24/09
Author: Svetlana Chernova
Creation date: 07/24/09

*/
define input  parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: close-all-trn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/close-all-trn.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ gbl/waitfram.i }
{ cmp/gds-list.i gds-list def "new shared" }

{ cmp/doc-list.i  doc-list def "new shared" }


define buffer buf_trn-doc for ub.trn-doc  .

define variable v-cntxt-cash-pay as integer   no-undo .
define variable v-cntxt-in-ov as logical   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
define variable v-cntxt-rsrv-time  as integer   no-undo .
define variable v-cntxt-load-time  as integer   no-undo .
define variable v-cntxt-holidays  as character no-undo .
define variable vt-host-code as integer   no-undo .
define variable vt-obj-type as character no-undo .
define variable vt-obj-code      as integer   no-undo .

  run str/fext-trn.w
      ( parparentproc ,
      v-cntxt-host-code-obj,
      v-cntxt-obj-type,
      v-cntxt-obj-code
      ).


run waitfram-show ( "Попытка потокового закрытия документов") .
define buffer buf_sysconf for ub.sysconf  .
define variable vvv as integer   no-undo .
define variable eee as integer   no-undo .
vvv = 0.
eee = 0.
for each doc-list :
vvv = vvv + 1.
    for each buf_trn-doc no-lock where
        buf_trn-doc.doc-code = doc-list.doc-code and
        buf_trn-doc.status_ <> {&fact}  :
        run waitfram-show ("Закрываю: " + buf_trn-doc.doc-code ) .
          find first   buf_sysconf where
              buf_trn-doc.host-code = buf_sysconf.host-code .
          assign
            v-cntxt-cash-pay   = buf_sysconf.cash-pay
            v-cntxt-base-code  = buf_sysconf.base-code
            v-cntxt-in-ov      = buf_sysconf.in-ov
            v-cntxt-rsrv-time  = buf_sysconf.rsrv-time
            v-cntxt-load-time  = buf_sysconf.load-time
            v-cntxt-holidays   = buf_sysconf.holidays
            v-cntxp-out-pay    = buf_sysconf.out-pay
            .

          run clos-trn2 in this-procedure (buf_trn-doc.doc-code) no-error .
          if error-status :error then do:
          eee = eee + 1.
          next.
          end.

      end.
end.
run waitfram-hide.





procedure clos-trn2 :
define input parameter p-trn-code as character no-undo .
define buffer buf_s-trn-doc for ub.trn-doc.
define variable varmode            as   character           no-undo.
define variable varstatus          like ub.trn-doc.status_  no-undo.
define variable varflag            like ub.trn-doc.flag     no-undo.
define variable varcopystatus      like ub.trn-doc.status_  no-undo.
define variable varcopyflag        like ub.trn-doc.flag     no-undo.
define variable varcheck-return as logical no-undo .
define variable varchg-inv as logical no-undo .

run str/trn-stat.p (
    input  parparentproc ,
    input  this-procedure ,
    input  {&close-doc} ,
    input  p-trn-code,
    input  false /* проверка старого возврата */ ,
    input  v-cntxt-db-num,
    input  false /* проверка переоценки */,
    input  v-cntxt-rsrv-time,
    input  v-cntxt-load-time,
    input  v-cntxt-holidays,
    input  false ,
    output varchg-inv ,
    output table gds-list)
    no-error.
end procedure. /* clos-trn2 */
