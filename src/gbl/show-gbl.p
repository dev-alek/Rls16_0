block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: show-gbl.p $
$Archive: gbl/show-gbl.p $

Показывает глобальные переменные системы

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: show-gbl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/show-gbl.p $":U .
define variable vss-description as character no-undo init "Показывает глобальные переменные системы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ str/getctxtp.i def }
{ gbl/attrprps.i }
{ gbl/disrules.i "create" }
{ gbl/distruls.i "create" }
{ gbl/cstmlabs.i }
{ gbl/rumconf.i }
{ gbl/gateconf.i }
{ gbl/layconf.i }
{ gbl/thbjattr.i fix }


define variable base-type             as character no-undo .
define variable base-code             as integer   no-undo .
define variable g#report-num          as integer   no-undo .
define variable g#gds-engl            as logical   no-undo .
define variable g#quest-print         as logical   no-undo .
define variable g#inp-jewel           as logical   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
define variable v-host-code-obj       as integer   no-undo .
define variable v-obj-data-name       as character no-undo .
define variable v-curr-r-b            as character no-undo .


define buffer buf_rep_currency for ub.currency.
define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.

def var lok as logical no-undo .

assign
  lok = true
.

if valid-handle(parparentproc)
then do:

  { gbl/getcntxt.i get }

  run get-report-num  in parparentproc (output g#report-num ).
  run get-gds-engl    in parparentproc (output g#gds-engl ).
  run get-quest-print in parparentproc (output g#quest-print ).
  run get-inp-jewel   in parparentproc (output g#inp-jewel ).
  { gbl/curr-r-b.i v-curr-r-b }

  message
    "Параметры системы"                           skip
    "parparentproc"         parparentproc         skip
    "v-cntxt-db-num"        v-cntxt-db-num        skip
    "v-cntxt-userid"        v-cntxt-userid        skip
    "v-cntxt-level"         v-cntxt-level         skip
    "v-cntxt-host-code-obj" v-cntxt-host-code-obj skip
    "v-cntxt-obj-type"      v-cntxt-obj-type      skip
    "v-cntxt-obj-code"      v-cntxt-obj-code      skip
    "v-cntxt-db-num-obj"    v-cntxt-db-num-obj    skip
    "g#report-num"          g#report-num          skip
    "g#gds-engl"            g#gds-engl            skip
    "g#quest-print"         g#quest-print         skip
    "g#inp-jewel"           g#inp-jewel           skip(2)
    "g#userid"              g#userid              skip
    "g#db-num"              g#db-num              skip
    "g#auto"                g#auto                skip
    "g#news"                g#news                skip
    "g#news-souce-db"       g#news-source-db      skip
    "g#oxml"                g#oxml                skip(2)
    "Тип валюты продажи"    v-curr-r-b            skip(2)
    view-as alert-box information buttons yes-no update lok.

  if not lok then do:
    return.
  end.

  if  v-cntxt-obj-code <> 0
  and v-cntxt-obj-code <> ?
  and v-cntxt-obj-type <> ""
  and v-cntxt-obj-type <> ?
  then do:
    { gbl/hostname.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code-obj
      v-cntxt-host-name-obj
    }
    { gbl/basecode.i
      v-host-code-obj
      base-code
    }

    find first buf_rep_currency no-lock
      where buf_rep_currency.curr-code = base-code
      no-error .
    if available buf_rep_currency
    then do:
      assign
        base-type = buf_rep_currency.curr-abbr
      .
    end.

    { str/getctxtp.i get  }

    /*найдем версии всяких эталонных файлов*/
    define variable v-ap-version as character no-undo .
    define variable v-dr-version as character no-undo .
    define variable v-dtr-version as character no-undo .
    define variable v-cl-version as character no-undo .
    define variable v-rum-version as character no-undo .
    define variable v-gate-version as character no-undo .
    define variable v-layout-version as character no-undo .
    define variable v-thbj-version as character no-undo .

    run get-ap-version in this-procedure ( output v-ap-version).
    run get-dr-version in this-procedure ( output v-dr-version).
    run get-dtr-version in this-procedure ( output v-dtr-version).
    run get-cl-version in this-procedure ( output v-cl-version).
    run get-rum-version in this-procedure ( output v-rum-version).
    run get-gate-version in this-procedure ( output v-gate-version).
    run get-layout-version in this-procedure ( output v-layout-version).
    run get-thbj-version in this-procedure ( output v-thbj-version).




    message
    v-obj-data-name                                       skip
    "v-cntxt-obj-type"         v-cntxt-obj-type           skip
    "v-cntxt-obj-code"         v-cntxt-obj-code           skip
    "base-code"                base-code                  skip
    "base-type"                base-type                  skip
    "v-cntxp-doc-prt"          v-cntxp-doc-prt            skip
    "v-cntxp-price-calc"       v-cntxp-price-calc         skip
    "v-cntxp-inout-price"      v-cntxp-inout-price        skip
    "v-cntxp-unit-cli-perm"    v-cntxp-unit-cli-perm      skip
    "v-cntxp-out-rate"         v-cntxp-out-rate           skip
    "v-cntxp-out-line-discnt"  v-cntxp-out-line-discnt    skip
    "v-cntxp-in-ov"            v-cntxp-in-ov              skip
    "v-cntxp-in-perm"          v-cntxp-in-perm            skip
    "v-cntxp-no-eq"            v-cntxp-no-eq              skip
    "v-cntxp-rsrv-time"        v-cntxp-rsrv-time          skip
    "v-cntxp-load-time"        v-cntxp-load-time          skip
    "v-cntxp-holidays"         v-cntxp-holidays           skip
    "v-cntxp-in-pay"           v-cntxp-in-pay             skip
    "v-cntxp-out-pay"          v-cntxp-out-pay            skip
    "v-cntxp-ret-pay"          v-cntxp-ret-pay            skip
    "v-cntxp-ret-sup-pay"      v-cntxp-ret-sup-pay        skip
    "v-cntxp-down-pay"         v-cntxp-down-pay           skip
    "v-cntxp-inv-pay"          v-cntxp-inv-pay            skip
    "v-cntxp-chk-pay"          v-cntxp-chk-pay            skip
    "v-cntxp-retail"           v-cntxp-retail             skip
    "v-cntxp-osn-base"         v-cntxp-osn-base           skip(2)
    "v-ap-version"             v-ap-version               skip
    "v-dr-version"             v-dr-version               skip
    "v-dtr-version"            v-dtr-version              skip
    "v-cl-version"             v-cl-version               skip
    "v-rum-version"            v-rum-version              skip
    "v-gate-version"           v-gate-version             skip
    "v-layout-version"         v-layout-version           skip
    "v-thbj-version"           v-thbj-version           skip
    view-as alert-box information buttons yes-no update lok.
    if not lok then return.
  end.
end.
else do:
  { gbl/curr-r-b.i v-curr-r-b }
  message
  "Параметры системы" skip
  "g#userid"          g#userid          skip
  "g#db-num"          g#db-num          skip
  "g#auto"            g#auto            skip
  "g#news"            g#news            skip
  "g#news-souce-db"   g#news-source-db  skip(2)
  "Тип валюты продажи"    v-curr-r-b            skip(2)
  "(Контекст текущего объекта и текущей фирмы получить невозможно - запуск НЕ из ГЛАВНОГО МЕНЮ!"
  view-as alert-box information .

end.
if lok <> true then do:
  return . /* --->>>--- */
end.