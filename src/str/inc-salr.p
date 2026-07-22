block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закачка чеков в продажу - вызывается из интерфейса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/04
Author: Bakhtadze Natalya
Creation date: 12/28/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-call-handle  as handle no-undo .
define input-output parameter p-ii as integer no-undo .
define input-output parameter p-ii-ok as integer no-undo .
define input parameter p-filter-on as logical no-undo .
define input parameter p-filter-rus as character no-undo .
define input parameter p-rid-list as character no-undo . /*список recid chk-doc если по нескольким */
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter v-curr-r-b  as character no-undo .
define input parameter is-wth      as logical   no-undo .
define input parameter cas-shft    as logical no-undo init no.
define input parameter one-curs    as logical no-undo init no.
define input parameter cas-curs    as logical no-undo init no.
define input parameter cursh       like ub.curr-shop.exch-rate init 0.
define input parameter cursh-scale like ub.curr-shop.exch-rate.
define input parameter prcl-spl    as logical no-undo init no.
define input parameter pay-gds-algo as character no-undo .
/*код дорожного налога*/
define input parameter rdtaxcd     as INTEGER                  no-undo.
/*код акциза*/
define input parameter exctaxcd    as INTEGER                  no-undo.
/*фактор дор налога*/
define input parameter factorrt    as decimal no-undo.
/*код стеклопосуды*/
define input parameter btltaxcd    as INTEGER                  no-undo.
define input parameter gds-amount  as integer .
define input parameter chk-amount  as integer .
define input parameter line-out    as integer .
define input parameter line-ret    as integer .
define input parameter dtl-out     as integer .
define input parameter dtl-ret     as integer .
define input parameter nf-chk-amount as integer.
define input parameter nf-gds-amount as integer.
define input parameter p-day-only  as logical no-undo .
define input parameter old-doc-date   like ub.inkas.doc-date no-undo .
define input parameter old-shift-date like ub.inkas.shift-date no-undo .
define input parameter old-shift-num  like ub.inkas.shift-num  no-undo .
define input parameter new-doc-date   like ub.inkas.doc-date no-undo .
define input parameter new-shift-date like ub.inkas.shift-date no-undo .
define input parameter new-shift-num  like ub.inkas.shift-num  no-undo .

define parameter buffer ink-doc for ub.inkas.
define parameter buffer trn-doc for ub.trn-doc.
define parameter buffer ret-doc for ub.trn-doc.
define parameter buffer buf_sysconf for ub.sysconf.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Закачка чеков в продажу".
{ cmp/vssrevis.i }
{ str/get-pr.i def }
{ cmp/trg-def.i  }
{ str/clc-exc.i  }
{ cmp/operlist.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ str/saledoc.i  }
{ str/lib-def.i  }
{ str/inkas-ps.i }
{ str/tpsidoc.i "SHARED" proc }
{ str/t-gds.i  def inc-sale }
{ str/findtank.i }
{ gbl/clntattr.i }
{ rep/real3tm.i }
{ ref/gds-attr.i }
{ str/placelib.i }


define shared buffer X_chk-doc for ub.chk-doc.
DEFINE shared QUERY QUERY-chk-doc FOR X_chk-doc SCROLLING.

&glob display-message  run waitfram-show in this-procedure (~{&MY-MESSAGE~} )

&glob display-message-laud  MESSAGE ~{&MY-MESSAGE~} view-as alert-box ERROR

&glob display-count-message run waitfram-show in this-procedure (input ~{&MY-count-MESSAGE~} )

&glob hide-count-message  run waitfram-hide in this-procedure

{ str/inc-salr.i }


run proc-main in this-procedure ( input trn-doc.status_ ) no-error .
if error-status:error then undo, return error return-value .

procedure proc-next-c-d :

  do
  on error undo, return error
  :
  end.

end procedure. /* proc-next-c-d */