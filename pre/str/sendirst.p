block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: defc-gds.i $ $Revision: 47e5c2a27e63, 2885, rls $".
DEFINE  TEMP-TABLE cash-gds no-undo
FIELD gds-code          like ub.goods.gds-code
FIELD artic             like ub.goods.artic
FIELD producer-int      as integer
FIELD b-code            like ub.bar-code.b-code
FIELD b-str             like ub.prod-bc.b-str
FIELD bc-on              like ub.prod-bc.bc-on
FIELD gds-name          like ub.goods.gds-name
FIELD gds-namelong      like ub.goods.gds-name
FIELD gds-name1         like ub.goods.gds-name
FIELD f-name            like ub.gds-prt.f-name
FIELD unit-base         like ub.goods.unit-base
FIELD unit-cli          like ub.bar-code.unit-cli
FIELD cli-base-rate     like ub.bar-code.cli-base-rate
FIELD std-discnt-rule   as integer
FIELD temp-discnt-rule  as integer
FIELD temp-discnt-method as character
FIELD VAT-pc            like ub.doc-line.VAT-pc
FIELD vat-code          like ub.tax-rate-gds.rate-code
FIELD SLT-pc            like ub.doc-line.SLT-pc
FIELD grp-code          like ub.goods.grp-code
FIELD gds-stat          as integer FORMAT "999"
FIELD wd-rule          as integer
FIELD wgd-rule         as integer
FIELD fp               as logical
FIELD zp               as integer
FIELD pp               as integer
FIELD need-auth        as integer
FIELD is-menu          as integer
FIELD is-semi-finished as integer
FIELD is-modificator   as integer
FIELD DepartId         as integer
FIELD fbr-grp-code-0   as integer
FIELD fbr-grp-code     as integer
FIELD office           as integer
field office-type      as character
FIELD CalculationMethod      as integer
FIELD CalculationMethodRestr as integer
FIELD price-sale       like ub.price-list.price-sale
FIELD unit-type        like ub.units.type
FIELD unit-cli-type    like ub.units.type
FIELD tax-string       as char FORMAT "X(255)"
FIELD qnty-discnt-rule as integer
FIELD kat-discnt-rule  as integer
FIELD kat-discnt-method as character
FIELD date-discnt-rule as integer
FIELD abs-discnt-rule  as integer
FIELD tot-discnt-rule  as integer
FIELD fact-qnty        like ub.gds-obj.fact-qnty
FIELD free-qnty        like ub.gds-obj.free-qnty
FIELD producer         as character format "X(40)"
FIELD ingredient       as character format "X(40)"
FIELD GTD              as character format "X(31)"
FIELD alpha1           like ub.goods.alpha
FIELD node-code        like ub.bar-code.node-code
FIELD okei             like ub.units.okei
FIELD kkt              as integer
FIELD is-gas           as logical
FIELD ptrl-as-good     as logical
FIELD taracode         as character
FIELD crf              as integer
FIELD new-good         as logical
FIELD rc               as recid
FIELD obj-type         as character
FIELD obj-code         as integer
field is-main-code     as logical
field bc-on-type       as character
field main-prt-b-code  as integer
field ean-lz as character
field ean-rz as character
field code-short as  character
index pi is unique primary crf
index bc b-code
index pbc b-str
index igds gds-code
index mbc obj-type obj-code main-prt-b-code
.
define temp-table temp-dis-gds-rule no-undo
like ub.dis-gds-rule.
define temp-table cash-gds-discnt
FIELD crf              as integer
FIELD b-code            like ub.bar-code.b-code
field discnt-value as decimal
FIELD rule-num     as integer
field obj-type     as character
field obj-code     as integer
index pi is unique primary crf
index bc
b-code
obj-type
obj-code
rule-num
.
define input  parameter p-parameter   as character no-undo .
define output parameter table for cash-gds .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendirst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendirst.p $":U .
define variable vss-description as character no-undo init "Подготовка остатков по основному БК":U.
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable inp-b-code as integer no-undo .
define variable p-obj-code as integer no-undo .
define variable cr as integer no-undo .
define variable l-terminal-prt as logical no-undo .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods    for ub.goods.
define buffer buf_gds-prt  for ub.gds-prt.
define buffer buf_clients  for ub.clients.
assign
inp-b-code = integer(entry(1, p-parameter, chr(4)))
p-obj-code = integer(entry(2, p-parameter, chr(4)))
no-error
.
if error-status:error then return error substitute("Неверно задан входной параметр").
FIND buf_bar-code WHERE buf_bar-code.b-code = inp-b-code NO-LOCK no-error .
if not available buf_bar-code then do:
  undo, return error substitute("Не найден бар-код &1"
                               , inp-b-code).
end.
find first buf_goods no-lock where
          buf_goods.gds-code = buf_bar-code.gds-code no-error.
if not available buf_goods then do:
  undo, return error substitute("Не найден товар для бар-кода &1 (код товара &2)"
                                , inp-b-code
                                , buf_bar-code.gds-code).
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  buf_bar-code.node-code
  ,input  'terminal-prt=request':u
  ,output l-terminal-prt
  ) no-error .
if error-status :error
then do:
  undo, return error substitute("Ошибка при определении терминальности признака")
    .
end.
if not l-terminal-prt then do:
  undo, return error substitute("Запрошен нетерминальный бар-код &1 (код признака &2)"
                                , inp-b-code
                                , buf_bar-code.node-code).
end.
_shop:
FOR EACH buf_clients no-lock where
        buf_Clients.db-num = G#db-num
    and buf_clients.obj-type = 'маг':U
   and
   (p-obj-code = 0
   or
   buf_clients.obj-code = p-obj-code):
   run term-prt in this-procedure ( buffer buf_bar-code
                                   ,input buf_clients.obj-type
                                   ,input buf_clients.obj-code
                                   ,input buf_goods.artic
                                   ,input buf_goods.prod-type
                                   ,input buf_goods.prod-code) no-error.
end.
PROCEDURE term-prt.
define parameter buffer buf_bar-code for ub.bar-code.
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-artic as character no-undo .
define input parameter p-prod-type as character no-undo .
define input parameter p-prod-code as integer no-undo .
define variable for-fact-qnty as decimal no-undo .
define variable for-free-qnty as decimal no-undo .
define buffer b-g-p for ub.gds-prt.
define buffer buf_prt-obj for ub.prt-obj.
FIND FIRST buf_prt-obj WHERE
        buf_prt-obj.obj-type = 'маг':U
    AND buf_prt-obj.obj-code = p-obj-code
    AND buf_prt-obj.prod-type = p-prod-type
    AND buf_prt-obj.prod-code = p-prod-code
    AND buf_prt-obj.artic = p-artic
    AND buf_prt-obj.prt-code = buf_bar-code.node-code NO-LOCK NO-ERROR .
if available buf_prt-obj then do:
  assign
  for-fact-qnty  = buf_prt-obj.fact-qnty
  for-free-qnty  = buf_prt-obj.free-qnty
  .
end.
else do:
  assign
  for-fact-qnty  = 0
  for-free-qnty  = 0
  .
end.
FIND FIRST cash-gds where cash-gds.crf = (cr + 1) No-ERROR.
if not avail cash-gds then do:
  create cash-gds.
  assign
  cash-gds.crf = cr + 1
  cr = cr + 1
  cash-gds.gds-code = buf_bar-code.gds-code
  cash-gds.b-code = buf_bar-code.b-code
  cash-gds.fact-qnty = for-fact-qnty
  cash-gds.free-qnty = for-free-qnty
  cash-gds.obj-type = p-obj-type
  cash-gds.obj-code = p-obj-code
  .
end.
END PROCEDURE.
