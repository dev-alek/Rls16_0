block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отсылка на кассу параметров".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable p-obj-type as character no-undo .
define variable i-obj-code like ub.cash-desk.obj-code no-undo .
define variable action     as character no-undo init 'U':U.
define variable p-batch as logical no-undo .
define variable p-other    as character no-undo .
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
define  NEW shared  temp-table gds-list no-undo like ub.goods
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
define variable is-petrolium as logical no-undo .
define variable is-pieces as logical no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable dop-int as integer no-undo .
define buffer buf_place for ub.place.
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf_goods for ub.goods.
define variable v-is-err-stat as logical no-undo .
define variable v-err-mess1   as character no-undo .
assign
p-obj-type = entry(1, p-parameter, chr(4))
i-obj-code = integer(entry(2, p-parameter, chr(4)))
action     = entry(3, p-parameter, chr(4))
no-error
.
v-is-err-stat = error-status:error.
v-err-mess1 = error-status:get-message(1).
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared var bc-frmt as character no-undo .
def new shared var bc-pfx  as character no-undo .
def var bc-par-type as character no-undo .
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "",  no , output bc-frmt, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U OR not can-do ("EAN8,EAN13", bc-frmt) ) then
        do:
            message "Не задан или не верно задан ТИП собственного бар-кода!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "",  no , output bc-pfx, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U ) then
        do:
            message "Не задан или не верно задан ПРЕФИКС бар-кода складского места!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
PROCEDURE gen-bc:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str4  as character no-undo.
  define variable tmp-num4  as character no-undo.
  define variable i4        as integer   no-undo.
  define variable sum4      as integer   no-undo.
  define variable len-code4 as integer   no-undo.
  define variable varcont4  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str4 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str4 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont4 = yes then do:
    if integer( substring( tmp-str4, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str4, length( bc-pfx ) + 1, length( tmp-str4 ) - length( bc-pfx ) )
        len-code4    = length( full-b-code )
      .
      define variable v-sum-char4 as character no-undo .
      assign
        sum4 = 0
      .
      do i4 = 1 to len-code4 by 2
      :
        assign
          v-sum-char4 = substr(full-b-code, len-code4 - i4 + 1, 1)
        .
        if v-sum-char4 < "0"
        or v-sum-char4 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum4 = sum4 + integer(v-sum-char4)
        .
      end.
      if varcont4 = yes then do:
        assign
          sum4 = sum4 * 3
        .
        do i4 = 2 to len-code4 by 2
        :
          assign
            v-sum-char4 = substr(full-b-code, len-code4 - i4 + 1, 1)
          .
          if v-sum-char4 < "0"
          or v-sum-char4 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum4 = sum4 + integer(v-sum-char4)
          .
        end.
        if varcont4 = yes then do:
           if sum4 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum4 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile: defc-gds.i $ $Revision: 47e5c2a27e63, 2885, rls $".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table cash-ncr-dis-kat no-undo
field cd-subject-code as character
field cd-subject-name as character
field dis-kat    like ub.dis-rule.dis-kat
field rule-num   like ub.dis-rule.rule-num
field time-rule-num like ub.dis-rule.time-rule-num
field crf as integer
field subject-code   as character
FIELD cd-disc-string    as character
field cd-other  as character
index pi is unique primary crf
index isubject cd-subject-code dis-kat
index idiskat dis-kat cd-subject-code cd-disc-string
.
define temp-table temp-dis-kat-file no-undo
field temp-file as character
field send-file as character
field to-send as logical
field dis-kat as integer
index pi is unique primary dis-kat
index isend to-send
.
define temp-table cash-ncr-save-param no-undo
field cd-line as character
field cd-other as character
field dis-kat as integer
index pi is unique primary dis-kat cd-line
.
 define variable v-found-good as log no-undo .
 define variable i-host-code as int no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table cash-txr no-undo
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION round-m RETURNS DECIMAL(input  mysum as decimal,
                                                                  input  orders as integer):
define variable  round-m-sum as decimal no-undo.
if orders >= 0 then
round-m-sum = round(mysum,orders).
else
round-m-sum = round(mysum / exp(10, abs(orders)), 0) * EXP(10, abs(orders)).
return round-m-sum.
END FUNCTION.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define temp-table  tt-tax no-undo
  field tax-code    like ub.tax.tax-code
  field individual  like ub.tax.individual
  field tax-name    like ub.tax.tax-name format "x(12)" column-label "Налог"
  field rate-code   like ub.tax-rate.rate-code
  field rate-name   like ub.tax-rate.rate-name format "x(12)"
  field tax-type    like ub.tax.tax-type
  field rate-value  like ub.tax-rate-value.rate-value
  field tax-rate-gds-rc  as recid
  field to-cashdesk like ub.tax.to-cashdesk
  index tax-code is unique primary tax-code
  .
procedure tax-val :
  define input  parameter       parartic      like ub.doc-line.artic     no-undo.
  define input  parameter       parprod-type  like ub.doc-line.prod-type no-undo.
  define input  parameter       parprod-code  like ub.doc-line.prod-code no-undo.
  define input  parameter       parunit-base  like ub.goods.unit-base    no-undo.
  define input  parameter       parnode-code  like ub.gds-prt.node-code  no-undo.
  define input  parameter       parunits-type like ub.units.type         no-undo.
  define input  parameter       parrec-id     as recid                   no-undo.
  define input  parameter       paris-log     as logical                 no-undo.
  define input  parameter       rdtaxcdvalue  as integer                 no-undo.
  define input  parameter       vattaxcdvalue as integer                 no-undo.
  define input  parameter       exctaxcdvalue as integer                 no-undo.
  define input  parameter       only-check    as logical                 no-undo.
  define input  parameter       parhost-code  like ub.sysconf.host-code  no-undo.
  define input  parameter       parobj-type   like ub.clients.obj-type   no-undo.
  define input  parameter       parobj-code   like ub.clients.obj-code   no-undo.
  define input  parameter       parroad-tax   like ub.doc-line.road-tax  no-undo.
  define input  parameter       parexcise     like ub.doc-line.excise    no-undo.
  define output parameter       parerr-mes    as character               no-undo.
  define input-output parameter parprice-sale like ub.price-list.price-sale no-undo.
  do
  on error undo, return error return-value
  :
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
    define buffer buf_tax          for ub.tax .
    define buffer buf_tax-rate     for ub.tax-rate .
    define buffer buf_tax-units    for ub.tax-units .
    define buffer buf_tax-rate-gds for ub.tax-rate-gds .
    define buffer buf_goods        for ub.goods .
    define buffer buf_bar-code     for ub.bar-code .
    define buffer buf_prod-bc      for ub.prod-bc .
    define buffer buf_units        for ub.units .
    define buffer buf_shop         for ub.shop .
    define buffer buf_store        for ub.store .
    define buffer buf_gds-prt      for ub.gds-prt .
    define buffer buf_tt-tax       for tt-tax .
    define variable varrate-value    as decimal   initial ? no-undo.
    define variable pr-list-recid    as recid     initial ? no-undo.
    define variable varmes           as character no-undo.
    define variable varfactorrtvalue as char      initial ? no-undo.
    define variable varfactorrttype  as char      initial ? no-undo.
    define variable is-petrolium     as logical no-undo.
    define variable is-pieces        as logical no-undo.
    define variable vargds-code      like ub.goods.gds-code no-undo.
    define variable pargds-code      like ub.goods.gds-code no-undo.
    define variable var-fact-order   as decimal no-undo .
    define variable currate-code     like buf_tax-rate.rate-code no-undo .
    define variable currate-name     like buf_tax-rate.rate-name no-undo .
    define variable currate-gds-rc   as recid no-undo .
    define variable v-today          as date no-undo .
    define variable v-time           as integer no-undo .
    for each buf_tt-tax:
      delete buf_tt-tax.
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    run factord-end-day in this-procedure (input v-today, output var-fact-order).
    if parartic     = ?
    or parprod-type = ?
    or parprod-code = ?
    or parunit-base = ?
    then do:
      find first buf_goods no-lock
        where recid(buf_goods) = parrec-id
        no-error .
    end.
    else do:
      find first buf_goods no-lock
        where buf_goods.artic = parartic
          and buf_goods.prod-type = parprod-type
          and buf_goods.prod-code = parprod-code
        no-error .
    end.
    if not available buf_goods then do:
      assign varmes = "Ошибка при поиске товара. Программа tax-val.i" + chr(10) .
      if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
    end.
    assign
      parartic     = buf_goods.artic
      parprod-type = buf_goods.prod-type
      parprod-code = buf_goods.prod-code
      parunit-base = buf_goods.unit-base
      pargds-code  = buf_goods.gds-code
    .
    if parunits-type = ?
    then do:
      find buf_units no-lock
        where buf_units.unit-name = parunit-base
        no-error .
      if not available buf_units then do:
        assign
          varmes =  varmes + "Ошибка при поиске единицы измерения. Программа tax-val.i" + chr(10)
        .
        if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
      end.
      assign
        parunits-type = buf_units.type
      .
    end.
    if parhost-code = ?
    or parhost-code = 0
    then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  abs(parobj-code)
  ,output parhost-code
  ) no-error .
      if error-status :error then do:
        assign
          varmes =  varmes + substitute("Ошибка при определении фирмы для объекта &1 &2. Программа tax-val.i"
            ,string(parobj-type)
            ,string(parobj-code)
            ) + chr(10)
        .
        if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
      end.
    end.
    assign
      vargds-code = buf_goods.gds-code
    .
    for each buf_tax-units no-lock
      where LOOKUP(buf_tax-units.type, parunits-type) > 0
    ,first buf_tax no-lock
      where buf_tax.tax-code = buf_tax-units.tax-code
    :
      find first buf_tt-tax where
                 buf_tt-tax.tax-code = buf_tax.tax-code no-error .
      if not available buf_tt-tax then do:
        create buf_tt-tax .
      end.
      assign
        buf_tt-tax.tax-code = buf_tax.tax-code
      .
      if buf_tax.individual = false then do:
        assign
          currate-gds-rc = ?
        .
        _tax-rate-gds:
        for each buf_tax-rate-gds no-lock where
                buf_tax-rate-gds.gds-code = pargds-code and
                buf_tax-rate-gds.tax-code = buf_tax.tax-code,
        first buf_tax-rate where
              buf_tax-rate.tax-code  = buf_tax-rate-gds.tax-code and
              buf_tax-rate.rate-code = buf_tax-rate-gds.rate-code no-lock
        by buf_tax-rate-gds.host-code
        by buf_tax-rate-gds.obj-type
        by buf_tax-rate-gds.obj-code
        by buf_tax-rate-gds.fact-order
        :
          if buf_tax-rate-gds.fact-order > var-fact-order then do:
            next _tax-rate-gds.
          end.
          if buf_tax-rate-gds.host-code = 0 or
            ((buf_tax-rate-gds.host-code = parhost-code) or
            (buf_tax-rate-gds.obj-type = parobj-type AND
            buf_tax-rate-gds.obj-code = parobj-code))
          then do:
            assign
            currate-code = buf_tax-rate.rate-code
            currate-name = buf_tax-rate.rate-name
            currate-gds-rc = recid(buf_tax-rate)
            .
          end.
          else do:
            next _tax-rate-gds.
          end.
        end.
        if currate-gds-rc = ? then do:
          assign varmes = "Не найдена ставка налога: "  + string(buf_tt-tax.tax-code) + " " + buf_tt-tax.tax-name +
                          " к товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                          chr(10).
          if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
        end.
      end.
      assign
        buf_tt-tax.rate-code   = currate-code
        buf_tt-tax.individual  = buf_tax.individual
        buf_tt-tax.tax-name    = buf_tax.tax-name
        buf_tt-tax.rate-name   = currate-name
        buf_tt-tax.tax-type    = buf_tax.tax-type
        buf_tt-tax.to-cashdesk = buf_tax.to-cashdesk
        buf_tt-tax.tax-rate-gds-rc  = currate-gds-rc
      .
    end.
    if parprice-sale = ?
    or parexcise     = ?
    or parroad-tax   = ?
    then do:
      if parnode-code = ? then do:
          FIND buf_gds-prt WHERE buf_gds-prt.upper-code  = buf_goods.prt-root NO-LOCK.
          parnode-code = buf_gds-prt.node-code.
      end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  vargds-code
  ,input  parnode-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  parobj-type
  ,input  parobj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  parobj-type
  ,input  parobj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
      assign
        parprice-sale = gp-price-sale
        parexcise     = gp-excise
        parroad-tax   = gp-road-tax
      .
    end.
    if only-check then do:
      return .
    end.
    for each buf_tt-tax no-lock
    on error undo, return error
    :
      if buf_tt-tax.tax-rate-gds-rc = ? then NEXT.
      if not buf_tt-tax.individual then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  buf_tt-tax.tax-code
  ,input  buf_tt-tax.rate-code
  ,input  ?
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,output varrate-value
  ) no-error .
        if error-status:error or varrate-value = ? then do:
          assign varmes = "Не найдена величина ставки налога: "  + string(buf_tt-tax.tax-code) + " " + buf_tt-tax.tax-name + " " + string(buf_tt-tax.rate-code) +
                          " к товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                          " фирма: " + string(parhost-code) +
                          " объект: " + parobj-type + " " + string(parobj-code) + chr(10).
          if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
        end.
        assign
        buf_tt-tax.rate-value  = varrate-value
        .
      end.
      else do:
        if not avail buf_gds-prt then
        FIND buf_gds-prt WHERE buf_gds-prt.upper-code  = buf_goods.prt-root NO-LOCK.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
        if (is-petrolium  and not is-pieces) and buf_goods.gds-type = 'т':U then do:
          find FIRST buf_prod-bc where
                      buf_prod-bc.b-code     = buf_goods.gds-code     and
                      buf_prod-bc.bc-on = yes no-lock no-error.
          if not available buf_prod-bc then do:
            assign varmes = "Не найден ДОП.бар-код по товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                            " " + string(buf_gds-prt.node-code) + " " + string(parunit-base) + "~n".
            if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
          end.
        end.
        else do:
          find buf_bar-code where
                buf_bar-code.gds-code  = vargds-code     and
                buf_bar-code.node-code = buf_gds-prt.node-code and
                buf_bar-code.part-code = ""           and
                buf_bar-code.in-code   = ""           and
                buf_bar-code.unit-cli  = parunit-base  no-lock no-error.
          if not available buf_bar-code then do:
            assign varmes = "Не найден бар-код по товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                            " " + string(buf_gds-prt.node-code) + " " + string(parunit-base) + "~n".
            if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
          end.
        end.
        if buf_tt-tax.tax-code = rdtaxcdvalue then do:
          ASSIGN
          buf_tt-tax.rate-code   = if (is-petrolium  and not is-pieces) and buf_goods.gds-type = 'т':U
                                then integer(buf_prod-bc.b-str)
                                else buf_bar-code.b-code
          buf_tt-tax.rate-value  = parroad-tax
          buf_tt-tax.tax-rate-gds-rc  = ?
          NO-ERROR.
        end.
        if buf_tt-tax.tax-code = exctaxcdvalue then do:
          ASSIGN
          buf_tt-tax.rate-code   = if (is-petrolium  and not is-pieces) and buf_goods.gds-type = 'т':U
                                then integer(buf_prod-bc.b-str)
                                else buf_bar-code.b-code
          buf_tt-tax.rate-value  = parexcise
          buf_tt-tax.tax-rate-gds-rc  = ?
          NO-ERROR.
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
~
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure discfgru-check :
define input parameter p-table-name as character no-undo .
define input parameter p-templ-rl-root as integer no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-pos-type as character no-undo .
define output parameter p-disnct-role as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
  do
  on error undo, return error return-value
  :
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.table-name = p-table-name
        and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and (p-time-templ-rl-root = ? or  buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root)
        and buf_dis-cfg-rule.pos-type = p-pos-type no-error.
    if not available buf_dis-cfg-rule
    or p-pos-type = "":U
    then do:
       return error substitute("Для места использования типа &1 не определен тип скидки с шаблоном &2 &3"
                               ,entry (lookup (p-pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)
                               , p-templ-rl-root
                               , (if p-time-templ-rl-root = ?
                                  then '':U
                                  else substitute("с расписанием типа &1", p-time-templ-rl-root)
                                  )
                               ).
    end.
    assign
    p-disnct-role = buf_dis-cfg-rule.discnt-role
    .
  end.
end procedure.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
procedure disgdsru-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :
  define input  parameter p-templ-rl-root  as integer no-undo .
  define output parameter p-label          as character no-undo .
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.
  if available buf_dis-rule
  then do:
    if buf_dis-rule.rule-num > 0 then
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.
end.
end procedure.
function disgdsru-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disgdsru-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.
function disgdsru-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
return entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u).
end function.
procedure disgdsru-write :
  do
  on error undo, return error
  :
    define input parameter p-obj-type       like ub.dis-gds-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-gds-rule.obj-code   no-undo .
    define input parameter p-gds-code       like ub.dis-gds-rule.gds-code   no-undo .
    define input parameter p-pos-type       like ub.dis-gds-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-gds-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-gds-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-gds-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-gds-rule.rule-num    no-undo .
    define input parameter p-nonunique      like ub.dis-gds-rule.nonunique   no-undo .
    define buffer buf_dis-gds-rule for ub.dis-gds-rule .
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer lock_dis-gds-rule for ub.dis-gds-rule .
    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .
    run discfgru-check in this-procedure (
                                          input 'dis-gds-rule':U
                                         ,input p-templ-rl-root
                                         ,input p-time-templ-rl-root
                                         ,input p-pos-type
                                         ,output v-discnt-role
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-discnt-role = ? then do:
      p-discnt-role = v-discnt-role.
    end.
    if p-discnt-role <> v-discnt-role then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не может быть по шаблону &7 и расписанию &8"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if p-pos-type = ? then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type23 as character no-undo .
define variable v-value-date23 as date no-undo .
define variable v-value-decimal23 as decimal no-undo .
define variable v-value-integer23 as INTEGER no-undo .
define variable v-value-logical23 AS LOGICAL no-undo .
define variable v-tth23 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date23
    ,output v-value-decimal23
    ,output v-value-integer23
    ,output v-value-logical23
    ,output v-param-type23
    ,INPUT-OUTPUT table-handle v-tth23
    )  .
delete object v-tth23 no-error.
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не найдено правило скидки &7"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6правило скидки &7 - некорневое"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if not (p-obj-type = buf_dis-rule.obj-type
        and p-obj-code = buf_dis-rule.obj-code)
    and not ( (p-obj-type = 'маг':U or p-obj-type = 'скл':U )
             and
             (buf_dis-rule.obj-type = 'орг':U or buf_dis-rule.obj-type = ""))
     then do:
      undo, return error (substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ) +
                          substitute("Правило скидки &1 определено для &2&3" +
                                     "а привязка к товару для &4"
                                     ,buf_dis-rule.rule-num
                                     ,get-objregion( buf_dis-rule.obj-type, buf_Dis-rule.obj-code)
                                     ,chr(10)
                                     ,get-objregion( p-obj-type, p-obj-code)
                                     ))
                              .
    end.
    find first buf_dis-gds-rule exclusive-lock where
               buf_dis-gds-rule.gds-code  = p-gds-code
           AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
           AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
           AND buf_dis-gds-rule.pos-type  = p-pos-type
           AND buf_dis-gds-rule.discnt-role = p-discnt-role
           and buf_dis-gds-rule.nonunique = p-nonunique
           no-error .
    if not available buf_dis-gds-rule then do:
      find first buf_dis-gds-rule exclusive-lock where
                buf_dis-gds-rule.gds-code  = p-gds-code
            AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
            AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
            AND buf_dis-gds-rule.pos-type  = p-pos-type
            AND buf_dis-gds-rule.discnt-role = p-discnt-role
            no-error .
      if available buf_Dis-gds-rule then do:
        if p-nonunique = ''
        and available buf_dis-gds-rule
        then do:
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует (детализ. &3)"
                                   , entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                   , p-nonunique
                                  ).
        end.
        if available buf_dis-gds-rule
        and buf_dis-gds-rule.nonunique = ''
        and p-nonunique <> ''then do:
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует"
                                   , entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                  ).
        end.
      end.
      create buf_dis-gds-rule .
      assign
      buf_dis-gds-rule.gds-code  = p-gds-code
      buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
      buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
      buf_dis-gds-rule.pos-type = p-pos-type
      buf_dis-gds-rule.discnt-role = v-discnt-role
      buf_dis-gds-rule.rule-num = p-rule-num
      buf_dis-gds-rule.nonunique = p-nonunique
      no-error
      .
    end.
    ASSIGN
    buf_dis-gds-rule.rule-num = p-rule-num
    buf_dis-gds-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-gds-rule.templ-rl-root = p-templ-rl-root
    buf_dis-gds-rule.nonunique = p-nonunique
    no-error.
  end.
end procedure.
PROCEDURE cmp-disgdsru-write :
do
on error undo, return error
:
  define input parameter p-gds-code like ub.dis-gds-rule.gds-code   no-undo .
  define input parameter p-obj-type like ub.dis-gds-rule.obj-type   no-undo .
  define input parameter p-obj-code like ub.dis-gds-rule.obj-code   no-undo .
  define input parameter p-pos-type like ub.dis-gds-rule.pos-type   no-undo .
  define input parameter p-templ-rl-root     like ub.dis-gds-rule.templ-rl-root  no-undo .
  define input parameter p-time-templ-rl-root     like ub.dis-gds-rule.time-templ-rl-root  no-undo .
  define input parameter p-discnt-role like ub.dis-gds-rule.discnt-role no-undo .
  define input parameter p-rule-num    like ub.dis-gds-rule.rule-num no-undo .
  define input parameter p-nonunique like ub.dis-gds-rule.nonunique no-undo .
  define variable v-rule-label          as character no-undo .
  define buffer buf_tt0-dis-gds-rule for ub.dis-gds-rule .
  define buffer buf_dis-rule     for ub.dis-rule.
  run disgdsru-name in this-procedure (
                                      input  p-templ-rl-root
                                      ,output v-rule-label
                                      ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  find first buf_tt0-dis-gds-rule exclusive-lock where
              buf_tt0-dis-gds-rule.gds-code  = p-gds-code
          AND buf_tt0-dis-gds-rule.obj-type  = p-obj-type
          AND buf_tt0-dis-gds-rule.obj-code  = p-obj-code
          AND buf_tt0-dis-gds-rule.pos-type  = p-pos-type
          AND buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
          AND buf_tt0-dis-gds-rule.nonunique = p-nonunique
          no-error .
  if not available buf_tt0-dis-gds-rule then do:
    create buf_tt0-dis-gds-rule .
    assign
    buf_tt0-dis-gds-rule.gds-code  = p-gds-code
    buf_tt0-dis-gds-rule.obj-type  = p-obj-type
    buf_tt0-dis-gds-rule.obj-code  = p-obj-code
    buf_tt0-dis-gds-rule.pos-type  = p-pos-type
    buf_tt0-dis-gds-rule.nonunique = p-nonunique
    buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
    no-error
    .
  end.
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-rule-num.
  ASSIGN
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rule-num = p-rule-num
  buf_tt0-dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
  buf_tt0-dis-gds-rule.nonunique = p-nonunique
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rl-root = buf_Dis-rule.rl-root
  no-error.
  release buf_tt0-dis-gds-rule no-error .
  if error-status:error then do:
    undo, return error return-value .
  end.
end.
END PROCEDURE.
define variable vss-include-info24 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-bgelib-bgefmt        as character         no-undo.
define variable v-bgelib-bgeflold      as character         no-undo.
define stream stmXMLOut.
define stream stmXMLLog.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info26 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable v-bgelib-bgeclall           as logical      no-undo.
define variable v-bgelib-bgedict            as logical      no-undo.
define temp-table temp_ext-doc-type no-undo
    field edt-key               as integer
    field ext-doc-type          as character
    field ext-doc-type-label    as character
    index pi is primary unique
        edt-key
.
define temp-table temp_bgelib_goods no-undo
    field gds-code as integer
    index pi is primary unique
        gds-code
.
define temp-table temp_bgelib_clients no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique
        obj-type
        obj-code
.
define temp-table temp_bgelib_dis-card no-undo
    field d-card as character
    index pi is primary unique
        d-card
.
define temp-table temp_bgelib_trn-doc no-undo
    field doc-code as integer
.
procedure bgelib-tag-open:
do
on error undo, return error
:
define input parameter v-tag-level  as integer      no-undo.
define input parameter v-tag-name   as character    no-undo.
define input parameter v-tag-value  as character    no-undo.
    put stream stmXMLOut unformatted
        chr(10)
        + fill(" ", 4 * v-tag-level)
        + "<" + v-tag-name
        + ( if v-tag-value = "" or v-tag-value = ? then "" else " " )
        + v-tag-value + ">"
    .
end.
end procedure.
procedure bgelib-tag-put:
do
on error undo, return error
:
define input parameter v-tag-level      as integer      no-undo.
define input parameter v-tag-name       as character    no-undo.
define input parameter v-tag-value      as character    no-undo.
define input parameter v-empty-mode     as integer      no-undo.
    v-tag-name = trim(v-tag-name).
    if  v-empty-mode = 1
    or (v-empty-mode = 0 and (v-tag-value <> "" and v-tag-value <> ?) )
    or (v-empty-mode = 2 and (v-tag-value <> "" and v-tag-value <> ? and v-tag-value <> "0"))
    or (v-empty-mode = 3 and (v-tag-value <> "" and v-tag-value <> ? and caps(v-tag-value) <> "no"))
    then do:
        run xmlchar-encode in this-procedure (
              input v-tag-value
            , output v-tag-value
        ).
        put stream stmXMLOut unformatted
            chr(10) + fill(" ", 4 * v-tag-level)
                        + '<' + v-tag-name + '>'
                        + v-tag-value
                        + '</' + v-tag-name + '>'
        .
    end.
end.
end procedure.
procedure bgelib-tag-close:
do
on error undo, return error
:
define input parameter v-tag-level as integer      no-undo.
define input parameter v-tag-name  as character    no-undo.
    put stream stmXMLOut unformatted
        chr(10)
        + fill( " ", 4 * v-tag-level)
        + '</' + v-tag-name + '>'
    .
end.
end procedure.
procedure bgelib-write-log:
do
on error undo, return error
:
define input parameter v-filename   as character    no-undo.
define input parameter v-log-level  as integer      no-undo.
define input parameter v-out-string as character    no-undo.
    output stream stmXMLLog to value( v-filename ) append.
    put stream stmXMLLog unformatted
        chr(10)
    .
    put stream stmXMLLog unformatted
        ( if v-log-level = 0
          or v-out-string = "&DLine"
          or v-out-string = "&Line"
          then ""
          else cur-time-string-sec() + " " )
    .
    put stream stmXMLLog unformatted
        ( if v-out-string = "&Line"
          then fill( "-", 80 )
          else if v-out-string = "&DLine"
               then fill( "=", 80 )
               else v-out-string )
    .
    output stream stmXMLLog close.
end.
end procedure.
procedure bgelib-write-edt:
do
on error undo, return error
:
define input parameter v-editor-handle    as handle       no-undo.
define input parameter v-log-level        as integer      no-undo.
define input parameter v-out-string       as character    no-undo.
    if valid-handle ( v-editor-handle )
    then do:
        v-editor-handle :move-to-eof().
        v-editor-handle :insert-string( ( if v-log-level = 0
                                          or v-out-string = "&DLine"
                                          or v-out-string = "&Line"
                                          then ""
                                          else cur-time-string-sec() + " "
                                      ) ).
        v-editor-handle :insert-string( ( if v-out-string = "&Line"
                                          then fill( "-", 80 )
                                          else if v-out-string = "&DLine" then fill("=", 80)
                                          else fill( " ", v-log-level) + v-out-string
                                      ) ).
        v-editor-handle :insert-string( chr(10) ).
    end.
    process events.
    output to 'bgescn.txt' append.
        put unformatted
            chr(10)
            string( ( if v-log-level = 0
                      or v-out-string = "&DLine"
                      or v-out-string = "&Line"
                      then ""
                      else string( today ) + " " + string( time, "hh:mm:ss" ) + " "
                  ) )
            string( ( if v-out-string = "&Line"
                      then fill( "-", 80 )
                      else if v-out-string = "&DLine"
                           then fill( "=", 80 )
                           else fill( " ", v-log-level ) + v-out-string
                  ) )
        .
    output close.
end.
end procedure.
procedure bgelib-show-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle     as handle   no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :visible = true
        .
    end.
end.
end procedure.
procedure bgelib-hide-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle     as handle   no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign v-fillin-handle :visible = false.
    end.
end.
end procedure.
procedure bgelib-write-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle    as handle       no-undo.
define input parameter v-fillin-string    as character    no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :SCREEN-value = v-fillin-string
        .
    end.
end.
end procedure.
procedure bgelib-write-header:
do
on error undo, return error
:
define input parameter p-first-file     as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-file-number    as integer      no-undo.
define input parameter p-have-prev      as logical      no-undo.
define input parameter p-prev-filename  as character    no-undo.
define input parameter p-obj-list       as character    no-undo.
define input parameter p-doc-type-list  as character    no-undo.
define input parameter p-parameter-list as character    no-undo.
    define variable v-counter    as integer        no-undo.
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>"
    .
    run bgelib-tag-open( input 0, input "root"  , input "" ).
    run bgelib-tag-open( input 0, input "header", input "" ).
    run bgelib-tag-put( input 1, input "fileName"       , input p-xml-file-name + "xml":U  , input 0 ).
    run bgelib-tag-put( input 1, input "fileNumber"     , input string( p-file-number     ), input 0 ).
    run bgelib-tag-put( input 1, input "havePrev"       , input string( p-have-prev       ), input 3 ).
    run bgelib-tag-put( input 1, input "prevFileName"   , input p-prev-filename            , input 0 ).
    run bgelib-tag-put( input 1, input "objList"        , input p-obj-list                 , input 0 ).
    run bgelib-tag-put( input 1, input "docTypeList"    , input p-doc-type-list            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run bgelib-tag-put(
              input 1
            , input entry( 2 * v-counter, p-parameter-list )
            , input entry( 2 * v-counter + 1, p-parameter-list )
            , input 0
        ).
    end.
    run bgelib-tag-close( input 0, input "header" ).
    output stream stmXMLOut close.
    output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
    if p-first-file = yes
    then do:
        put stream stmXMLOut unformatted
            "<?xml version='1.0' encoding='windows-1251'?>"
        .
        run bgelib-tag-open( input 0, input "export", input "" ).
    end.
    run bgelib-tag-open( input 1, input "file", input "" ).
    run bgelib-tag-put( input 2, input "fileName"       , input p-xml-file-name + "xml":U  , input 0 ).
    run bgelib-tag-put( input 2, input "fileNumber"     , input string( p-file-number     ), input 0 ).
    run bgelib-tag-put( input 2, input "havePrev"       , input string( p-have-prev       ), input 3 ).
    run bgelib-tag-put( input 2, input "prevFileName"   , input p-prev-filename            , input 0 ).
    run bgelib-tag-put( input 2, input "objList"        , input p-obj-list                 , input 0 ).
    run bgelib-tag-put( input 2, input "docTypeList"    , input p-doc-type-list            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run bgelib-tag-put(
              input 2
            , input trim(entry( 2 * v-counter, p-parameter-list ))
            , input trim(entry( 2 * v-counter + 1, p-parameter-list ))
            , input 0
        ).
    end.
    run bgelib-tag-close( input 1, input "file" ).
    output stream stmXMLOut close.
end.
end procedure.
procedure bgelib-write-footer:
do
on error undo, return error
:
define input parameter p-last-file      as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-have-next      as logical      no-undo.
define input parameter p-next-file-name as character    no-undo.
    define variable v-error-num     as integer           no-undo.
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    if p-have-next = yes
    then do:
        run bgelib-tag-open( input 0, input "footer", "" ).
        run bgelib-tag-put( input 1, input "haveNext"       , string( p-have-next ) , 3 ).
        run bgelib-tag-put( input 1, input "nextFileName"   , p-next-file-name      , 0 ).
        run bgelib-tag-close( input 0, input "footer" ).
    end.
    run bgelib-tag-close( input 0, input "root" ).
    output stream stmXMLOut close.
    run bge/os_copy.p (
          input "M"
        , input p-xml-file-name + "tmp"
        , input p-xml-file-name + "xml"
        , output v-error-num
    ).
    if p-last-file = yes
    then do:
        output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
            run bgelib-tag-close( input 0, input "export" ).
        output stream stmXMLOut close.
        run bge/os_copy.p (
              input "M"
            , input p-list-file-name + "tmp"
            , input p-list-file-name + "xml"
            , output v-error-num
        ).
    end.
end.
end procedure.
procedure bgelib-filename :
do
on error undo, return error
:
define input parameter p-prefix             as character    no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-list-file-name    as character    no-undo.
    define variable v-home-dir  as character    no-undo.
    define variable v-error-num as integer      no-undo.
    get-key-value section "BGE" key "outdir" value v-home-dir.
    if v-home-dir = ?
    then do:
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run gbl/dir-cre.p (
        input v-home-dir
    ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run bge/genfname.p (
          input v-home-dir
        , input p-prefix
        , input ""
        , input "xml"
        , input "tmp"
        , output p-xml-file-name
    ).
    assign
        p-xml-file-name     = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
        p-log-file-name     = v-home-dir + chr(92) + "actions.log"
        p-list-file-name    = v-home-dir + chr(92) + "lst":U + substring( p-xml-file-name, length( p-xml-file-name ) - 5, 5 ) + ".":U
    .
end.
end procedure.
procedure bgelib-read-config :
do
on error undo, return error
:
define variable v-par-type as character     no-undo.
  define variable v-param-type      as character  no-undo .
  define variable v-value-character as character  no-undo .
  define variable v-value-date      as date       no-undo .
  define variable v-value-decimal   as decimal    no-undo .
  define variable v-value-integer   as integer    no-undo .
  define variable v-value-logical   as logical    no-undo .
  define variable v-tth             as handle     no-undo .
    assign
        v-bgelib-bgeclall = no
        v-bgelib-bgedict  = no
    .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeclall':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgeclall = no
      .
    end.
    else do:
      assign
        v-bgelib-bgeclall = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgedict':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgedict = no
      .
    end.
    else do:
      assign
        v-bgelib-bgedict = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgefmt':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgefmt  = "xml":U
      .
    end.
    else do:
      assign
        v-bgelib-bgefmt  = v-value-character
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeflold':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgeflold  = "old":U
      .
    end.
    else do:
      assign
        v-bgelib-bgeflold  = v-value-character
      .
    end.
    delete object v-tth.
end.
end procedure.
procedure bgelib-check-file-size :
do
on error undo, return error
:
define input parameter p-out-filename   as character    no-undo.
define output parameter p-is-big        as logical      no-undo.
    define variable v-current-position    as integer        no-undo.
    assign
        v-current-position = seek( stmXMLOut )
    .
    if v-current-position / 1024 / 1024  >= 100
    then do:
        assign
            p-is-big = yes
        .
    end.
end.
end procedure.
procedure bgelib-init-ext-doc-type :
    define variable v-counter    as integer      no-undo.
    define buffer buf_temp_ext-doc-type     for temp_ext-doc-type.
do
for buf_temp_ext-doc-type
on error undo, return error
:
    empty temp-table buf_temp_ext-doc-type.
    do v-counter = 1 to num-entries( 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
    :
        create buf_temp_ext-doc-type.
        assign
            buf_temp_ext-doc-type.edt-key               = v-counter
            buf_temp_ext-doc-type.ext-doc-type          = entry( v-counter, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
            buf_temp_ext-doc-type.ext-doc-type-label    = entry( v-counter, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U )
        .
    end.
end.
end procedure.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-xml-file-name     as character            no-undo.
define variable v-xml-file-name-path as character            no-undo.
define variable v-log-file-name     as character            no-undo.
define variable v-locked            as logical              no-undo.
define variable v-log-string        as character            no-undo.
define variable v-oper-num          as integer              no-undo.
define variable v-obj-list          as character            no-undo.
DEF VAR strDummy    AS CHAR view-as editor size 50 by 4 NO-UNDO.
DEF VAR intRep      AS INT NO-UNDO.
define variable hEDT             AS HANDLE NO-UNDO.
define variable hCNT             AS HANDLE NO-UNDO.
procedure xml-cd-write-header:
do
on error undo, return error
:
define input parameter p-xml-file-name       as character    no-undo.
define input parameter p-xml-file-name-path  as character    no-undo.
define input parameter p-doc-name            as character    no-undo.
define input parameter p-version             as character    no-undo.
define input parameter p-obj-list            as character    no-undo.
define input parameter p-correspondent       as character    no-undo .
define input parameter p-write-header        as logical      no-undo .
define variable OS-time as character no-undo .
define variable id as character no-undo .
define buffer buf_db for ub.db.
output stream stmXMLOut to value( p-xml-file-name-path + "xm1":U ) convert target "1251" append.
put stream stmXMLOut unformatted "<?xml version='1.0' encoding='windows-1251'?>".
assign
OS-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
.
run bgelib-tag-open in this-procedure (
                                     1
                                    ,p-doc-name
                                    ,substitute("type='REQUEST' id='&1' from='&2' to='&3' tstamp='&4'", p-xml-file-name, p-obj-list, p-correspondent, OS-time )
                                      ).
if p-write-header then do:
  run bgelib-tag-open(2, "Header","").
  run bgelib-tag-put( 3, "DocumentName", p-doc-name, 1).
  run bgelib-tag-put( 3, "DateFormat", "DD.MM.YYYY":U, 1).
  run bgelib-tag-put( 3, "DocumentVersion", "1.02":U, 1).
  run bgelib-tag-put( 3, "DocumentVersionDate", "09.09.2004":U, 1).
  run bgelib-tag-put( 3, "ExportDate", string(today, "99.99.9999":U), 1).
  run bgelib-tag-put( 3, "ExportTime", string(time, "hh:mm:ss":U), 1).
  run bgelib-tag-put( 3, "objList",             p-obj-list                    , 1).
  find first buf_db where buf_db.db-num = g#db-num no-lock.
  run bgelib-tag-put( 3, "dbEncKey",            buf_db.db-key-enc, 1).
  run bgelib-tag-close( 2, "Header" ).
end.
output stream stmXMLOut close.
end.
end procedure.
procedure xml-cd-write-footer:
do
on error undo, return error
:
define input parameter p-pos-type      like ub.cash-desk.pos-type no-undo .
define input parameter p-xml-file-name as character    no-undo.
define input parameter p-doc-name      as character    no-undo .
define variable v-error-num     as integer           no-undo.
define variable v-md5-signature as character no-undo .
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251" append.
run bgelib-tag-close( 0, p-doc-name ).
put stream stmXMLOut unformatted skip.
output stream stmXMLOut close.
run bge/os_copy.p ("M", p-xml-file-name + "xm1", p-xml-file-name + "xml", output v-error-num ).
if v-error-num > 0
then do:
   return error.
end.
if opsys = "unix"
then do:
    os-command silent chmod 666 value (p-xml-file-name + "xml") 2>/dev/null.
end.
end.
end procedure.
procedure xml-cd-filename :
do
on error undo, return error
:
define input parameter  p-out               as character no-undo .
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-xml-file-name-path   as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-locked            as logical      no-undo.
define variable v-out as character     no-undo.
define variable loc#log as logical no-undo .
define variable BadFlag as logical no-undo .
define variable fq as integer no-undo .
define variable v-remote as character no-undo .
assign
p-xml-file-name = substring( string( next-value( s-spool, ub), '99999999999999999999'), 13, 8 )
p-xml-file-name-path = p-out + p-xml-file-name + ".":U
p-log-file-name = p-out + "actions.log"
p-locked = ( search ( p-xml-file-name-path + "lk" ) <> ? )
.
end.
end procedure.
FUNCTION Xml-CD-DatetoString returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
FUNCTION Xml-CD-DateTimetoString returns character (input  p-date as date, p-time as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U) + chr(32) +
             string(p-time, "HH:MM:SS").
return v-date-str.
END FUNCTION.
function string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 4, 2))
                ,integer(substring(p-string, 1, 2))
                ,integer(substring(p-string, 7, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION string-IS0-8601-to-sec returns integer (input p-string-iso-8601 as character ):
define variable v-time as integer no-undo init ?.
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
assign
v-dop1 = entry(1, p-string-iso-8601, chr(32) )
v-dop2 = entry(2, p-string-iso-8601, chr(32) )
no-error .
if error-status:error then return ?.
assign
v-time =  integer(entry(1, v-dop2, ";":U)) * 3600 +
          integer(entry(2, v-dop2, ";":U)) * 60 +
          integer(entry(3, v-dop2, ";":U)) no-error .
return v-time.
END FUNCTION.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdcstcod_cst-code :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-gds-code  as integer   no-undo .
  define input  parameter p-in-code   as character no-undo .
  define input  parameter p-part-code as character no-undo .
  define output parameter p-cst-code  as character no-undo .
  define buffer buf_goods for ub.goods .
  define buffer buf_parts for ub.parts .
  do
  on error undo, return error return-value
  :
    assign
      p-cst-code = ''
    .
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Не найден товар &1", p-gds-code) .
    end.
    if p-in-code = ?
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Неизвестное значение номера накладной &1", p-in-code) .
    end.
    if p-part-code = ?
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Неизвестное значение номера номера партии &1", p-part-code) .
    end.
    if p-in-code = '':u
    then do:
      find first buf_parts no-lock
        where buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = buf_goods.artic
          and buf_parts.prod-type = buf_goods.prod-type
          and buf_parts.prod-code = buf_goods.prod-code
          and buf_parts.out-code  = 'free-zone':U
          and buf_parts.status_   = false
        no-error .
      if available buf_parts
      then do:
        assign
          p-cst-code = buf_parts.cst-code
        .
      end.
    end.
    else do:
      find first buf_parts no-lock
        where buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = buf_goods.artic
          and buf_parts.prod-type = buf_goods.prod-type
          and buf_parts.prod-code = buf_goods.prod-code
          and buf_parts.out-code  = 'free-zone':U
          and buf_parts.in-code   = p-in-code
          and buf_parts.part-code = p-part-code
        no-error .
      if available buf_parts
      then do:
        assign
          p-cst-code = buf_parts.cst-code
        .
      end.
    end.
  end.
end procedure.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fname                        as character      no-undo .
define variable out                          as character      no-undo .
define variable out2                          as character      no-undo .
DEFINE VARIABLE in_                          as character      no-undo .
DEFINE VARIABLE spl                          as character      no-undo .
DEFINE VARIABLE sav                          as character      no-undo .
DEFINE VARIABLE v-remote                     as character      no-undo .
DEFINE VARIABLE start-paket                  as logical init yes no-undo .
define variable cr as integer no-undo.
define variable Cash-OS2                    as logical        no-undo .
define variable Cash-DOS                     as logical        no-undo .
define variable BadFlag                      as logical        no-undo .
define variable os-er                        as integer        no-undo .
DEFINE VARIABLE OS2-time                     as character      no-undo .
define variable glog as logical no-undo .
define variable log-file-name                as character      no-undo init "send-cd.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-md5-signature              as character      no-undo .
define variable v-cd-list-update             as character no-undo .
define variable v-cd-list-delete             as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define stream   IBMStream .
define temp-table temp-cd no-undo like ub.cash-desk .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure alienini-getkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define output parameter o-value as char.
define variable EntryPointer as integer no-undo.
define variable mem1 as memptr no-undo.
define variable mem2 as memptr no-undo.
define variable mem1size as integer no-undo.
define variable mem2size as integer no-undo.
define variable ii       as integer    no-undo.
define variable cbReturnSize  as integer    no-undo.
assign
set-size(mem1)  = 4000
mem1size = 4000.
if i-key = "" then EntryPointer = 0.
else do:
  assign
  set-size(mem2) = 128
  mem2size = 128
  EntryPointer = get-pointer-value(mem2)
  put-string(mem2, 1) = i-key.
end.
run getprivateprofilestringA
                              (i-section,
                               EntryPointer,
                               "",
                               get-pointer-value(mem1),
                               input mem1size,
                               i-filename,
                               output cbReturnSize).
do ii = 1 to cbReturnSize:
  o-value = if (get-byte(mem1, ii) = 0 and ii ne cbReturnSize)
               then o-value + ","
               else o-value + chr(get-byte(mem1, ii)).
end.
  set-size(mem1) = 0.
  set-size(mem2) = 0.
end procedure.
procedure alienini-putkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define input parameter i-value as char.
define variable cbReturnSize as integer.
run writeprivateprofilestringA
                               (i-section,
                                i-key,
                                i-value,
                                i-filename,
                                output cbReturnSize ).
end procedure.
PROCEDURE GetPrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection     AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry       AS LONG.
  DEFINE INPUT  PARAMETER lpszDefault     AS CHAR.
  DEFINE INPUT  PARAMETER memBuffer       AS LONG.
  DEFINE INPUT  PARAMETER cbReturnBuffer  AS LONG.
  DEFINE INPUT  PARAMETER lpszFilename    AS CHAR.
  DEFINE RETURN PARAMETER cbReturnedChars AS LONG.
END PROCEDURE.
PROCEDURE WritePrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection  AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry    AS CHAR.
  DEFINE INPUT  PARAMETER lpszString   AS CHAR.
  DEFINE INPUT  PARAMETER lpszFilename AS CHAR.
  DEFINE RETURN PARAMETER lpszValue    AS LONG.
END PROCEDURE.
define   temp-table temp-tekka-tsk no-undo
field filename      as character
field obj-num       as integer
field obj-name      as character
field num-records   as integer
field max-records   as integer
field min-plu       as integer
field max-plu       as integer
field num-fields    as integer
field task-num      as character
field by-record     as logical
field send-get      as character
field cash-num      as integer
field cash-num-char as character
field port-num      as character
field way           as character
field is-script     as logical
field pswd          as character
field waiting-sek   as integer
field other-info    as character
field order-num     as integer
field secondary     as integer
field shift-fields  as integer
field binary        as logical
field range         as integer
index pi is unique primary
filename
range
index lpi
filename
min-plu
index gpi
filename
max-plu
index iorder
order-num
.
define   temp-table temp-tekka-schema no-undo
field obj-num as integer
field obj-name as character
field field-num as integer
field field-name as character
field num-records as integer
field size_ as integer
field host as character
field progress-type as character
field custom-type as character
field start-pos as integer
field end-pos as integer
field bin-group as character
index pi is unique primary
host obj-num field-num
.
define temp-table temp-tekka-record no-undo
field obj-num as integer
field plu as integer
field body as character
field shift as integer
index pi is unique primary obj-num plu.
FUNCTION tekka-is-closed-shift-journal returns integer ( input p-journal-num as integer ):
define variable v-is-closed-shift-journal as integer no-undo .
assign
v-is-closed-shift-journal = (if lookup( string( p-journal-num), '30,31,32,33':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '43':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '17':U) > 0 then 1 else 0)
.
return v-is-closed-shift-journal.
END FUNCTION.
FUNCTION tekka-is-first-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-first-journal as logical no-undo .
assign
v-is-first-journal = (p-journal-num =  integer(entry(1, '30,31,32,33':U)))
                  or (p-journal-num = integer(entry(1, '26,27,28,29':U)))
                  or (p-journal-num =  integer(entry(1, '17':U)))
                  or (p-journal-num = integer(entry(1, '16':U)))
.
return v-is-first-journal.
END FUNCTION.
FUNCTION tekka-is-petrol-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-petrol-journal as logical no-undo .
assign
v-is-petrol-journal = lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0.
return v-is-petrol-journal.
END FUNCTION.
FUNCTION tekka-get-max-journal-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489
                    else 2340).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-get-max-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489 * num-entries('30,31,32,33':U)
                    else 2340 * num-entries('17':U)).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-num-recs returns integer( input p-journal-num as integer
                                        ,input p-rec-no as integer):
define variable v-num-recs as integer no-undo .
if tekka-is-petrol-journal (p-journal-num) then do:
  if tekka-is-closed-shift-journal(p-journal-num) = 1 then do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '30,31,32,33':U))) * 1489 + p-rec-no
    .
  end.
  else do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '26,27,28,29':U)) ) * 1489 + p-rec-no
    .
  end.
end.
else do:
  if lookup(string(p-journal-num), '16,17':U) > 0 then do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '17':U))) * 2340 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '16':U)) ) * 2340 + p-rec-no
      .
    end.
  end.
  else do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '43':U))) * 2978 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '42':U)) ) * 2978 + p-rec-no
      .
    end.
  end.
end.
return v-num-recs.
END FUNCTION.
FUNCTION tekka-get-obj-num returns integer( input p-num-recs as decimal
                                           ,input p-is-petrol as logical
                                           ,input p-is-current as logical
                                           ,output p-rec-no as decimal
                                           ):
define variable v-obj-num0 as integer no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-num2 as integer no-undo .
define variable p-num-recs2 as integer no-undo .
define variable p-rec-no2 as integer no-undo .
if p-is-petrol then do:
  assign
  v-obj-num0 = trunc(p-num-recs / 1489, 0)
  .
  if p-is-current and num-entries('26,27,28,29':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '26,27,28,29':U))
  p-rec-no = p-num-recs modulo 1489
  .
  if not p-is-current and num-entries('30,31,32,33':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '30,31,32,33':U))
  p-rec-no = p-num-recs modulo 1489
  .
end.
else do:
  assign
  p-num-recs2 = (p-num-recs - trunc(p-num-recs, 0)) * 10000
  p-num-recs = trunc(p-num-recs, 0)
  v-obj-num0 = trunc(p-num-recs / 2340, 0)
  v-obj-num2 = trunc(p-num-recs2 / 2978, 0)
  .
  if p-is-current and num-entries('16':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '16':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if not p-is-current and num-entries('17':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '17':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if p-is-current and num-entries('42':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '42':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  if not p-is-current and num-entries('43':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '43':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  assign
  p-rec-no = p-rec-no + p-rec-no2 / 10000
  .
end.
if v-obj-num = 0 then v-obj-num = 100.
return v-obj-num.
END FUNCTION.
FUNCTION tekka-get-next-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '17':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
   if p-is-ptrl then
   return integer(entry(1, '26,27,28,29':U)).
   if not p-is-ptrl then
   return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
FUNCTION tekka-get-next-current-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical ):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '26,27,28,29':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
  if p-is-ptrl then
  return integer(entry(1, '26,27,28,29':U)).
  if not p-is-ptrl then
  return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
PROCEDURE maria-put:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-out    as character no-undo .
define input parameter p-fname as character no-undo .
define input parameter p-by-record as logical no-undo .
define input parameter p-shift-fields as integer no-undo .
define input parameter p-binary as logical no-undo .
define input parameter p-obj-num as integer no-undo .
define input parameter p-max-records as integer no-undo .
define input parameter p-plu as integer no-undo .
define input parameter p-value as character no-undo .
define variable v-file-name as character no-undo .
define variable v-create as logical no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
v-file-name =  p-out + p-fname + '.' + string(p-obj-num,  '999') .
output stream IBMSTREAM
to value(v-file-name) append .
Put  stream IBMSTREAM unformatted
p-plu
chr(3)
p-value
skip.
output stream IBMSTREAM
close.
if not p-by-record then do:
  find first buf_temp-tekka-tsk where
            buf_temp-tekka-tsk.filename  = v-file-name no-error .
  if not available buf_temp-tekka-tsk then do:
    v-create = yes.
  end.
end.
else do:
  find first buf_temp-tekka-tsk where
            buf_temp-tekka-tsk.filename  = v-file-name
        and buf_temp-tekka-tsk.max-plu = (p-plu - 1) use-index gpi no-error .
  if not available buf_temp-tekka-tsk
  then do:
    find first buf_temp-tekka-tsk where
              buf_temp-tekka-tsk.filename  = v-file-name
          and buf_temp-tekka-tsk.min-plu = (p-plu + 1) use-index lpi no-error .
    if not available buf_temp-tekka-tsk
    then do:
      v-create = yes.
    end.
  end.
end.
if v-create then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = v-file-name
  buf_temp-tekka-tsk.range    = p-plu
  buf_temp-tekka-tsk.obj-num = p-obj-num
  buf_temp-tekka-tsk.obj-name = '':U
  buf_temp-tekka-tsk.num-records = 0
  buf_temp-tekka-tsk.max-records = p-max-records
  buf_temp-tekka-tsk.num-fields = num-entries(p-value, chr(4) )
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = p-by-record
  buf_temp-tekka-tsk.shift-fields = p-shift-fields
  buf_temp-tekka-tsk.binary = p-binary
  buf_temp-tekka-tsk.send-get = 'send'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                        then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                        else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                              then 'local'
                              else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.min-plu     = p-plu
  buf_temp-tekka-tsk.max-plu     = p-plu
  .
end.
assign
buf_temp-tekka-tsk.num-records = buf_temp-tekka-tsk.num-records + 1
buf_temp-tekka-tsk.min-plu     = minimum(buf_temp-tekka-tsk.min-plu, p-plu)
buf_temp-tekka-tsk.max-plu     = maximum(buf_temp-tekka-tsk.max-plu, p-plu)
.
END PROCEDURE.
PROCEDURE maria-get:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-out    as character no-undo .
define input parameter p-fname as character no-undo .
define input parameter p-by-record as logical no-undo .
define input parameter p-obj-num as integer no-undo .
define input parameter p-num-fields as integer no-undo .
define input parameter p-max-records as integer no-undo .
define input parameter p-min-plu as integer no-undo .
define input parameter p-max-plu as integer no-undo .
define input parameter p-other as character no-undo .
define input parameter p-order-num as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-secondary-obj-num as character no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
if p-by-record then do:
  v-file-name =  p-out + p-fname + '-' + string(buf_cash-desk.cash-num) + '.' + string(p-obj-num,  '999') .
end.
else do:
  v-file-name =  p-out + p-fname + '-' + string(buf_cash-desk.cash-num) + '_html.' + string(p-obj-num,  '999').
end.
find first buf_temp-tekka-tsk where
          buf_temp-tekka-tsk.filename  = v-file-name no-error .
if not available buf_temp-tekka-tsk then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = v-file-name
  buf_temp-tekka-tsk.obj-num = p-obj-num
  buf_temp-tekka-tsk.obj-name = '':U
  buf_temp-tekka-tsk.max-records = p-max-records
  buf_temp-tekka-tsk.num-fields = p-num-fields
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = p-by-record
  buf_temp-tekka-tsk.send-get = 'get'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                          then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                          else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                                then 'local'
                                else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.min-plu     = p-min-plu
  buf_temp-tekka-tsk.max-plu     = p-max-plu
  buf_temp-tekka-tsk.num-records = (if p-min-plu <> ?
                                    and p-max-plu <> ?
                                    then p-max-plu - p-min-plu + 1
                                    else 0)
  buf_temp-tekka-tsk.other-info = p-other
  buf_temp-tekka-tsk.order-num = p-order-num
  .
  if index('16-42,17-43,':U, string(buf_temp-tekka-tsk.obj-num) + '-') > 0 then do:
    assign
    v-secondary-obj-num =  substring('16-42,17-43,':U, index('16-42,17-43,':U, string(buf_temp-tekka-tsk.obj-num) + '-'))
    v-secondary-obj-num = entry(2, v-secondary-obj-num, '-':U)
    v-secondary-obj-num = entry(1, v-secondary-obj-num)
    no-error
    .
    buf_temp-tekka-tsk.secondary = integer(v-secondary-obj-num).
  end.
end.
END PROCEDURE.
PROCEDURE maria-task:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-fname as character no-undo .
define input parameter p-obj-num-list as character no-undo .
define input parameter p-parameters as character no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
find first buf_temp-tekka-tsk where
          buf_temp-tekka-tsk.task-num  = p-fname no-error .
if not available buf_temp-tekka-tsk then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = ''
  buf_temp-tekka-tsk.range = 1
  buf_temp-tekka-tsk.obj-num = 0
  buf_temp-tekka-tsk.obj-name = p-obj-num-list
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = no
  buf_temp-tekka-tsk.send-get = 'task'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                          then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                          else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                                then 'local'
                                else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.other-info = p-parameters
  buf_temp-tekka-tsk.order-num = 0
  .
end.
END PROCEDURE.
procedure tekkatsk-verify-schema :
define input parameter p-obj-list as character no-undo .
define input parameter p-dir-path as character no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-name as character no-undo .
define variable v-num-records as integer no-undo .
define variable v-size_ as integer no-undo .
define variable v-value as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable ii-ibs as integer no-undo .
define variable ii-tekka as integer no-undo .
define variable v-result as character no-undo .
define buffer buf_temp-tekka-schema for temp-tekka-schema.
define buffer buf2_temp-tekka-schema for temp-tekka-schema.
  do
  on error undo, return error
  :
     for each buf_temp-tekka-schema:
       delete buf_temp-tekka-schema.
     end.
     input from value('tekkasch.d').
     repeat :
       create buf_temp-tekka-schema.
       import buf_temp-tekka-schema.
       assign
       buf_temp-tekka-schema.host = 'IBS'
       ii = ii + 1.
       .
     end.
     input close.
     ii-ibs = ii.
      _ii:
      do ii = 1 to 256:
        if p-obj-list = "ALL"
        or lookup(string(ii), p-obj-list) > 0 then do:
          assign
          v-obj-num = 0
          v-obj-name = ''
          v-num-records = 0
          v-size_ = 0
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'oname'
                                                  ,output v-value) no-error .
          if v-value = ? then next _ii.
          assign
          v-obj-num = ii
          v-obj-name = v-value
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'size'
                                                  ,output v-value) no-error .
          assign
          v-num-records = integer(v-value) no-error  .
          if error-status:error
          or v-num-records = 0 then next _ii.
          run alienini-getkey in this-procedure (
                                                   input  (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input 'obj' + string(ii, '999')
                                                  ,input 'f000'
                                                  ,output v-value) no-error .
          assign
          v-size_ = integer(v-value) no-error  .
          if error-status:error
          or v-size_ = 0 then next _ii.
          _jj:
          do jj = 1 to 256:
            run alienini-getkey in this-procedure (
                                                     input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999')
                                                    ,input 'f' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value = ? then next _ii.
            create buf_temp-tekka-schema.
            assign
            buf_temp-tekka-schema.host = 'tekka'
            buf_temp-tekka-schema.obj-num = v-obj-num
            buf_temp-tekka-schema.obj-name = v-obj-name
            buf_temp-tekka-schema.num-records = v-num-records
            buf_temp-tekka-schema.size_ = v-size_
            buf_temp-tekka-schema.field-num = jj
            buf_temp-tekka-schema.custom-type = entry(1, entry(2, v-value, '#'), ':')
            buf_temp-tekka-schema.bin-group = (if num-entries(entry(2, v-value, '#'), ':') > 1
                                               then entry(2, entry(2, v-value, '#'), ':')
                                               else '':U)
            buf_temp-tekka-schema.start-pos = integer(entry(1, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.end-pos = integer(entry(2, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.progress-type = entry( LOOKUP(buf_temp-tekka-schema.custom-type, 'Sx,B,BF,BN,UI,UL,FL,SL,VL':U)
                                                        , 'C,I,I,I,D,D,D,D,D':U)
            no-error
            .
            if error-status:error then do:
              delete buf_temp-tekka-schema.
              next _jj.
            end.
            run alienini-getkey in this-procedure (
                                                    input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999') + 'name'
                                                    ,input 'n' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value <> ? then
            buf_temp-tekka-schema.field-name = v-value.
          end.
        end.
      end.
      ii-tekka = ii - 1.
     if p-obj-list <> 'ALL' then do:
      if ii-tekka <> ii-ibs then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS &1 объектов&1по даным OLE-сервера &2"
                                , ii-ibs
                                , ii-tekka).
      end.
     end.
     for each buf_temp-tekka-schema where
            buf_temp-tekka-schema.host = 'tekka':
       find first buf2_temp-tekka-schema where
                 buf2_temp-tekka-schema.obj-num = buf_temp-tekka-schema.obj-num
             AND buf2_temp-tekka-schema.host = 'ibs'
             AND buf2_temp-tekka-schema.field-num = buf_temp-tekka-schema.field-num no-error .
       if not available buf2_temp-tekka-schema then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS нет поля &1 для объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
       buffer-compare buf_temp-tekka-schema
       to buf2_temp-tekka-schema
       save result in v-result.
       if v-result <> '':U then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS для поля &1 объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
     end.
  end.
end procedure.
FUNCTION set-Sx returns character (input p-string as character):
return p-string.
END FUNCTION.
FUNCTION get-Sx returns character (input p-string  as character):
return p-string.
END FUNCTION.
FUNCTION set-B returns character (input p-string  as character):
return chr(integer(p-string)).
END FUNCTION.
FUNCTION get-B returns character (input p-string  as character):
return string(asc(p-string)).
END FUNCTION.
FUNCTION set-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
do ii = 1 to 8:
  put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable ii as integer no-undo .
v-dopi = asc(p-string).
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
return v-dops.
END FUNCTION.
FUNCTION set-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-grp-nums as integer no-undo .
define variable v-dopi2 as integer no-undo .
v-grp-nums = num-entries(p-bin-group).
do jj = 0 to v-grp-nums - 1:
  v-dopi2 = integer(substring(p-string, jj + 1, 3)).
  do ii = 1 to 8:
    put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
  end.
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable v-grp-nums as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
v-dopi = asc(p-string).
v-grp-nums = num-entries(p-bin-group).
do jj = 1 to v-grp-nums:
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
end.
return v-dops.
END FUNCTION.
procedure fill-temp-cd :
define input parameter p-db-num   like ub.cash-desk.db-num no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-clear-table as logical no-undo .
define buffer buf_temp-cd for temp-cd.
define buffer buf_cash-desk for ub.cash-desk.
  do
  on error undo, return error
  :
     if p-clear-table  then do:
       for each buf_temp-cd:
         delete buf_temp-cd.
       end.
     end.
     for each buf_cash-desk no-lock where
            buf_cash-desk.db-num = p-db-num
        AND buf_cash-desk.obj-code = p-obj-code
        and buf_cash-desk.cash-on  = yes
     BREAK by buf_cash-desk.pos-type:
       if first-of(buf_cash-desk.pos-type) then do:
         create buf_temp-cd.
         buffer-copy buf_cash-desk to buf_temp-cd.
       end.
     end.
  end.
end procedure.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION name-2cdf returns character
                   (  input p-name-2cd as character
                    , input p-mode as logical
                    , input p-cod-pcod as logical
                    , input p-b-code  as integer
                    , input p-gds-code as integer
                    , input p-artic   as character
                    , input p-engl-name  as character
                    , input p-in-code as character
                    , input p-part-code as character
                    , input p-obj-type as character
                    , input p-obj-code as integer
                    , input p-alpha1 as character
                    , output p-gtd as character
                    ) :
define variable v-name-2cd as character no-undo .
define variable v-dop-alt-name as character no-undo.
define variable v-type as character no-undo.
define buffer buf_parts for ub.parts.
define buffer buf_code for ub.code.
if not p-mode and p-name-2cd = "PLU":U then do:
  return "PLU кассы":U.
end.
if not p-mode then do:
  if p-name-2cd <> "GTD":U
  and  p-name-2cd <> "alpha1|gtd":U
  then do:
  assign
  p-name-2cd = p-name-2cd + "-":U + "GTD":U.
end.
end.
if p-part-code = "":U or p-cod-pcod = no then do:
  run gdsoattr-value in this-procedure (
    'dt-seasons':U,
    p-gds-code,
    p-obj-type,
    p-obj-code,
    output v-dop-alt-name,
    output v-type
  ) no-error.
  if v-dop-alt-name <> "" then do:
    find first buf_code where
               buf_code.parent = "DTSeasons"
           and buf_code.code   = v-dop-alt-name
         no-lock no-error.
    if available buf_code then
      assign
        p-engl-name = ""
        v-dop-alt-name =  buf_code.misc1
      .
  end.
  else do:
    run gdsoattr-value in this-procedure
                        ( input  'dop-alt-name-o':U
                         ,input  p-gds-code
                         ,input  p-obj-type
                         ,input  p-obj-code
                         ,output v-dop-alt-name
                         ,output v-type
                        ) no-error .
  end.
  CASE p-name-2cd:
    when "name" then do:
      if p-mode then return p-engl-name + v-dop-alt-name.
      return "Англ. название".
    end.
    when "code":U then do:
      if p-mode then  return string( p-b-code, ">>>>>>>>>>>>>>>9" )  .
      return "Лок. код товара"  .
    end.
    when "GTD":U
    or
    when "name-GTD":U
    or
    when "code-GTD":U
    or
    when "alpha1|gtd":U
    or
    when "name-alpha1|gtd":U
    or
    when "code-alpha1|gtd":U
    then do:
      if p-mode then do:
        run gdcstcod_cst-code  in this-procedure (
                                                    input  p-obj-type
                                                    ,input  p-obj-code
                                                    ,input  p-gds-code
                                                    ,input  p-in-code
                                                    ,input  p-part-code
                                                    ,output p-gtd
                                                    ) no-error .
      end.
      if p-name-2cd = "name-gtd":U then do:
        if p-mode then return p-engl-name  + v-dop-alt-name.
        return "Англ. название".
      end.
      if p-name-2cd = "name-alpha1|gtd":U then do:
        if p-mode then return p-engl-name  + v-dop-alt-name.
        return "Англ. название".
      end.
      if p-name-2cd = "code-GTD":U then do:
        if p-mode then  return string( p-b-code, ">>>>>>>>>>>>>>>9" )  .
        return "Лок. код товара"  .
      end.
      if p-name-2cd = "code-alpha1|gtd":U then do:
        if p-mode then  return string( p-b-code, ">>>>>>>>>>>>>>>9" )  .
        return "Лок. код товара"  .
      end.
      if p-mode then do:
        if p-name-2cd = "GTD" then  return p-gtd.
        if p-name-2cd = "alpha1|gtd" then  return (p-alpha1 + "|" + p-gtd).
      end.
      if p-name-2cd = "GTD" then  return "Код ГТД".
      if p-name-2cd = "alpha1|gtd" then  return "Страна|Код ГТД".
    end.
  END CASE.
end.
else do:
  if p-name-2cd = "name-gtd":U
  or p-name-2cd = "code-GTD":U
  or p-name-2cd = "name-alpha1|GTD":U
  or p-name-2cd = "code-alpha1|GTD":U
  or p-name-2cd = "alpha1|GTD":U
  then do:
    if p-mode then do:
      run gdcstcod_cst-code  in this-procedure (
                                                   input  p-obj-type
                                                  ,input  p-obj-code
                                                  ,input  p-gds-code
                                                  ,input  p-in-code
                                                  ,input  p-part-code
                                                  ,output p-gtd
                                                  ) no-error .
    end.
    else do:
      if p-name-2cd = "gtd":U then
      p-gtd = "Код ГТД".
      if p-name-2cd = "alpha1|Gtd":U then
      p-gtd = "Страна|Код ГТД".
    end.
  end.
  if p-mode then  return p-part-code.
  return "Код партии".
end.
END FUNCTION.
function chk-name_ibm_maria_ibm-xml_infokiosk_ibs-th returns character ( input p-pos-type as character
                                         ,input p-nam-2str as logical
                                         ,input p-nam-artc as logical
                                         ,input p-unit-cli-type as character
                                         ,input p-unit-base as character
                                         ,input p-unit-cli as character
                                         ,input p-cli-base-rate as decimal
                                         ,input p-artic as character
                                         ,input p-f-name as character
                                         ,input p-gds-name as character
                                         ,input p-gds-name1 as character
                                         ,output p-second-name as character):
define variable v-length as integer no-undo .
define variable nam-2str-shift as integer no-undo .
define variable chk_name as character no-undo .
assign
v-length = (if p-pos-type = 'IBM':U then 25 else 40 )
v-length = (if p-pos-type = 'MARIA':U then 24 else v-length)
v-length = (if p-pos-type = 'MARIA':U and lookup('топ':U, p-unit-cli-type) > 0
            then 5
            else v-length)
v-length = (if p-pos-type = 'IBM-XML':U then 128 else v-length )
nam-2str-shift = (if p-nam-2str then v-length else 0)
.
if p-nam-artc then do:
  assign
  chk_name = substitute("&1 &2", p-artic, p-f-name)
    .
end.
else  do:
  assign
  chk_name = replace(p-gds-name, chr(34), "":U) + p-f-name
  .
end.
if p-unit-base <> p-unit-cli then do:
  if length (chk_name) > 109 then chk_name = substring (chk_name,1,109) .
  assign
  chk_name = string(substr(chk_name
                            ,1
                            ,max(14, v-length + nam-2str-shift - 1 - length(trim(string(p-cli-base-rate), chr(32)))) +  nam-2str-shift ) +
                    "*":U +
                    trim(string(p-cli-base-rate), chr(32)), "x(":U + string(v-length + nam-2str-shift) + ")":U ).
end.
else do:
  chk_name = string(chk_name, "X(":U + string(v-length + nam-2str-shift) + ")":U).
end.
if p-nam-2str then do:
  assign
  p-second-name = chr(34) + trim(substr(chk_name, v-length)," ") + chr(34)
  chk_name = substr(chk_name, 1, v-length)
  .
end.
else do:
  assign
  p-second-name = replace(p-gds-name1, chr(39), "":U)
  p-second-name =   (chr(34) +
                    TRIM(string( replace(p-second-name, chr(34), "":U), "X(":U + string(v-length) + ")":U ))
                    + chr(34) )
  .
end.
return chk_name.
end function.
def var vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure disrules-get-interface-form :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define output parameter p-form-name as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
find first buf_temp-drt-prop where
          buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
      and buf_temp-drt-prop.upper-prop-code = "InputForm"
      and buf_temp-drt-prop.prop-code = "FormName" no-error.
if not available buf_temp-drt-prop then do:
  find first buf_drt-prop where
            buf_drt-prop.templ-rl-root = p-templ-rl-root
        and buf_drt-prop.upper-prop-code = "InputForm"
        and buf_drt-prop.prop-code = "FormName" no-error.
  if available buf_drt-prop then do:
    p-form-name = buf_drt-prop.property-value.
  end.
  else do:
    p-form-name = "ref/dis-ruli.w".
  end.
end.
else do:
  p-form-name = buf_temp-drt-prop.property-value.
end.
end procedure.
~
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cd-attr-code :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  define output parameter p-prop-list      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-code in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ,output p-prop-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-tooltip :
  define input  parameter p-ucode   as character no-undo .
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-tooltip in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-value :
  define input  parameter p-db-num    like ub.cash-desk-attr.db-num        no-undo .
  define input  parameter p-obj-code  like ub.cash-desk-attr.obj-code      no-undo .
  define input  parameter p-pos-type  like ub.cash-desk-attr.pos-type      no-undo .
  define input  parameter p-cash-num  like ub.cash-desk-attr.cash-num      no-undo .
  define input  parameter p-ucode     like ub.cash-desk-attr.upper-attr-code      no-undo .
  define input  parameter p-code      like ub.cash-desk-attr.attr-code      no-undo .
  define output parameter p-character like ub.cash-desk-attr.attr-value-character    no-undo .
  define output parameter p-date      like ub.cash-desk-attr.attr-value-date         no-undo .
  define output parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal      no-undo .
  define output parameter p-integer   like ub.cash-desk-attr.attr-value-integer      no-undo .
  define output parameter p-logical   like ub.cash-desk-attr.attr-value-logical      no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-character
      ,output p-date
      ,output p-decimal
      ,output p-integer
      ,output p-logical
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-write :
  define input parameter p-db-num    like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code  like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type  like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num  like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code      like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-character like ub.cash-desk-attr.attr-value-character no-undo .
  define input parameter p-date      like ub.cash-desk-attr.attr-value-date      no-undo .
  define input parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal   no-undo .
  define input parameter p-integer   like ub.cash-desk-attr.attr-value-integer   no-undo .
  define input parameter p-logical   like ub.cash-desk-attr.attr-value-logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-write in g#attr-lib
      (input p-db-num
      ,input p-obj-code
      ,input p-pos-type
      ,input p-cash-num
      ,input p-ucode
      ,input p-code
      ,input p-character
      ,input p-date
      ,input p-decimal
      ,input p-integer
      ,input p-logical
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-exist :
  define input  parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input  parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input  parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-delete :
  define input parameter  p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter  p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter  p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter  p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter  p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter  p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-news :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  define output parameter p-from-gbd       as logical   no-undo .
  define output parameter p-from-ubd       as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-news in g#attr-lib
      (
       input  p-ucode
      ,input  p-code
      ,output p-news
      ,output p-from-gbd
      ,output p-from-ubd
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-hist :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-hist           as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-hist in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-hist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-parse-date-time returns date
(input  p-string as character
,output p-time   as integer
):
  define variable v-return-value as date      no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-parse-date-time-proc in g#attr-lib
    (input  p-string
    ,output p-time
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run last-check-date-time in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-cd-datetostring returns character
(input  p-date as date
):
  define variable v-return-value as character no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-cd-datetostring-proc in g#attr-lib
    (input  p-date
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr-last-report-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-report-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-maria in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-periodic-tasks :
define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-periodic-tasks in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr_get-attr-int returns integer
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as integer   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-int-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-int-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
function cd-attr_get-attr-log returns logical
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as logical   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-log-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-log-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr_check-marketer :
  define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_check-marketer in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-manual-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-manual-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-batch-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-batch-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-send-param :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-send-param     as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-send-param in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-send-param
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE cd-mrkt_plu-marketer :
define input parameter p-silence as logical no-undo .
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-id as character no-undo .
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-b-str like ub.prod-bc.b-str no-undo .
define input parameter p-loc-ean as logical no-undo .
define input parameter p-is-petrolium as logical no-undo .
define input parameter p-extra as character no-undo .
define variable v-tot-gds as integer no-undo .
define variable v-max-gds as integer no-undo .
define variable v-petrol-start as integer no-undo .
define variable v-petrol-range as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-plu-type as character no-undo .
define variable v-int as integer no-undo .
define buffer  buf_cd-plu for ub.cd-plu.
define buffer  loc_cd-plu for ub.cd-plu.
define variable  ii as integer no-undo.
define variable v-mes as character no-undo .
_main:
DO ON ERROR undo, leave on stop undo, leave:
  if buf_cash-desk.pos-type <> 'MARIA':U
  or buf_cash-desk.cash-num <> 0 then do:
    assign
    v-mes =
    substitute("Товары на кассах можно определять только для кассовых менеджеров (номер кассы = 0) для типов касс &1"
              , buf_cash-desk.pos-type).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    return error v-mes.
  end.
  v-tot-gds = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_operative':U
                                  ,input (if buf_cash-desk.pos-type = 'MARIA':U
                                        and p-is-petrolium
                                        then 'tot-petrol':U
                                        else 'tot-gds':U)
                                  , output v-mes).
  if v-tot-gds = ? then undo _main, return error v-mes.
  v-max-gds = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_general':U
                                  ,input 'max-gds':U
                                  ,output v-mes).
  if v-max-gds = ? then undo _main, return error v-mes.
  v-petrol-range = cd-attr_get-attr-int(buffer buf_cash-desk
                                       ,input 'petrolium-range':U
                                       ,input 'petrolium-range':U
                                       ,output v-mes).
  if v-petrol-range = ? then undo _main, return error v-mes.
  if buf_cash-desk.pos-type = 'MARIA':U then do:
    assign
    v-petrol-start = 1
    v-max-gds = (if p-is-petrolium
                 then v-petrol-range
                 else v-max-gds)
    v-plu-type = (if p-is-petrolium
               then 'топ':U
               else '':U)
    .
    if p-is-petrolium then do:
      if p-id = '':U then do:
        v-mes = substitute( "Топливо с кодом &1 не привязано к складскому месту&2" +
                            "Невозможно привязать к кассе типа &3"
                            , p-b-str
                            , chr(10)
                            , 'MARIA':U).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
      end.
      assign
      v-int = integer(p-id)
      no-error
      .
      if error-status:error
      or v-int > v-petrol-range then do:
        v-mes = substitute( "№ резервуара &1 для топлива с кодом &1 не укладывается&3" +
                            "в диапазоны номеров резервуаров для кассы типа &4"
                            , p-id
                            , p-b-str
                            , chr(10)
                            , 'MARIA':U).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
      end.
    end.
  end.
  if buf_cash-desk.pos-type = 'MARIA':U
  and p-is-petrolium then do:
    find first loc_cd-plu where
             loc_cd-plu.obj-type = 'маг':U
         and loc_cd-plu.obj-code = buf_cash-desk.obj-code
         and loc_cd-plu.pos-type = buf_cash-desk.pos-type
         and loc_cd-plu.plu-type = 'топ':U
   no-error .
   if available loc_cd-plu then do:
     if loc_cd-plu.b-code = p-b-code
     and loc_cd-plu.b-str = p-b-str then do:
        v-mes = substitute( "№ резервуара &1 на кассе УЖЕ привязан к топливу с кодом &1,&3"
                            , p-id
                            , p-b-str
                            , chr(10)
                            ).
        if not p-silence then
        message
        v-mes
        view-as alert-box WARNING .
        return v-mes.
     end.
     else do:
        v-mes = substitute( "№ резервуара &1 на кассе привязан к топливу с кодом &1,&3" +
                            "нельзя его привязать к топливу &2&3"
                            , p-id
                            , loc_cd-plu.b-str
                            , chr(10)
                            , p-b-str).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
     end.
   end.
   ii = v-int.
  end.
  else do:
    DO ii = (if p-is-petrolium
            then v-petrol-start
            else (if buf_cash-desk.pos-type = 'MARIA':U
                 then 1
                 else (if v-petrol-start = 1
                        then (v-petrol-range + 1)
                        else 1)
                )
            )
      to v-max-gds :
      if not can-find (loc_cd-plu where
                      loc_cd-plu.obj-type = 'маг':U
                   and loc_cd-plu.obj-code =  buf_Cash-desk.obj-code
                   and loc_cd-plu.pos-type = buf_Cash-desk.pos-type
                   and loc_cd-plu.plu-type = v-plu-type
                   and loc_cd-plu.plu-code = ii
                    )
      then LEAVE .
    END .
  end.
  if ii > v-max-gds then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество &5 &1" +
                "для касс &2 &3&4"
                , chr(10)
                , v-max-gds
                , 'маг':U
                , buf_cash-desk.obj-code
                , (if p-is-petrolium then "топлив" else "товаров")
                )
      view-as alert-box ERROR .
      undo, return error "max-gds":U.
  end.
  DO ii = (if p-is-petrolium
           then v-petrol-start
           else (if v-petrol-start = 1
                 then (v-petrol-range + 1)
                 else 1)
           )
     to v-max-gds :
    if not can-find (loc_cd-plu where
                      loc_cd-plu.obj-type = 'маг':U
                   and loc_cd-plu.obj-code =  buf_Cash-desk.obj-code
                   and loc_cd-plu.pos-type = buf_Cash-desk.pos-type
                   and loc_cd-plu.plu-type = v-plu-type
                   and loc_cd-plu.plu-code = ii
                   )
    then LEAVE .
  END .
  if ii > v-max-gds then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество &5 &1" +
                "для касс &2 &3&4"
                , chr(10)
                , v-max-gds
                , 'маг':U
                , buf_cash-desk.obj-code
                , (if p-is-petrolium then "топлив" else "товаров")
                )
      view-as alert-box ERROR .
      undo, return error "max-gds":U.
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_cd-plu.
  assign
  buf_cd-plu.b-code = p-b-code
  buf_cd-plu.b-str = p-b-str
  buf_cd-plu.charkey_two = (if buf_cash-desk.pos-type = 'MARIA':U
                                      then buf_cash-desk.addr-path
                                      else "U":U)
  buf_cd-plu.to-send = yes
  buf_cd-plu.charkey_one = "":U
  buf_cd-plu.to-del = no
  buf_cd-plu.plu-code = ii
  buf_cd-plu.obj-type = 'маг':U
  buf_cd-plu.obj-code = buf_cash-desk.obj-code
  buf_cd-plu.pos-type = buf_cash-desk.pos-type
  buf_cd-plu.plu-type = v-plu-type
  buf_cd-plu.logkey_one = p-loc-ean
  buf_cd-plu.key#_one = integer(p-extra)
  .
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  substitute("&1_operative", buf_cash-desk.pos-type)
                                        ,input (if buf_cash-desk.pos-type = 'MARIA':U
                                              and p-is-petrolium
                                              then 'tot-petrol':U
                                              else 'tot-gds':U)
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input  (v-tot-gds + 1)
                                        ,input no
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <текущее количество товаров на кассе> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'to-send':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input yes
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <Есть коды товаров, не отправленные на кассу> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  return "":U.
end.
END PROCEDURE.
procedure cd-mrkt_update-marketer :
define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
define input parameter p-is-petrolium as logical no-undo .
define variable v-to-send as logical no-undo .
define variable v-tot-gds as integer no-undo .
define variable v-max-plu as integer no-undo .
define buffer buf_cd-plu for ub.cd-plu.
define variable v-plu-type as character no-undo .
  do
  on error undo, return error
  :
    v-to-send = no.
    v-tot-gds = 0.
    assign
    v-plu-type = (if p-is-petrolium
                  then  'топ':U
                  else '':U
              )
    .
    FOR EACH buf_cd-plu WHERE
           buf_cd-plu.obj-type = 'маг':U
      and  buf_cd-plu.obj-code = p-obj-code
      and  buf_cd-plu.pos-type = p-pos-type
      and  buf_cd-plu.plu-type = v-plu-type
          :
      if  buf_cd-plu.to-del
      or  buf_cd-plu.to-send then do:
        assign
        v-to-send = yes.
      end.
      assign
      v-tot-gds = v-tot-gds + 1.
    end.
    run cd-attr-write  in this-procedure (
                                            input   p-db-num
                                            ,input  p-obj-code
                                            ,input  p-pos-type
                                            ,input  p-cash-num
                                            ,input  'MARIA_operative':U
                                            ,input  (if p-pos-type = 'MARIA':U
                                                     and p-is-petrolium
                                                     then  'tot-petrol':U
                                                     else 'tot-gds':U)
                                            ,input ''
                                            ,input ?
                                            ,input 0.0
                                            ,input v-tot-gds
                                            ,input no
                                                                                        ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.
    run cd-attr-write  in this-procedure (
                                            input   p-db-num
                                            ,input  p-obj-code
                                            ,input  p-pos-type
                                            ,input  p-cash-num
                                            ,input  'MARIA_operative':U
                                            ,input  (if p-pos-type = 'MARIA':U
                                                     and p-is-petrolium
                                                     then  'petrol-to-send':U
                                                     else 'to-send':U)
                                            ,input ''
                                            ,input ?
                                            ,input 0.0
                                            ,input 0
                                            ,input v-to-send
                                            ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.
    FIND LAST buf_cd-plu NO-LOCK  WHERE
             buf_cd-plu.obj-type = 'маг':U
         and buf_cd-plu.obj-code = p-obj-code
         and buf_cd-plu.pos-type = p-pos-type
         and buf_cd-plu.plu-type = v-plu-type  use-index pi no-error .
    if available buf_cd-plu then do:
      if v-max-plu < buf_cd-plu.plu-code
      then
      v-max-plu = buf_cd-plu.plu-code .
    end.
    else do:
      v-max-plu = 0.
    end.
    run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  'MARIA_operative':U
                                          ,input  (if p-pos-type = 'MARIA':U
                                                  and p-is-petrolium
                                                  then 'max-petrol-plu':U
                                                  else 'max-plu':U)
                                            ,input ''
                                            ,input ?
                                            ,input 0.0
                                            ,input v-max-plu
                                            ,input no
                                          ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.
  end.
end procedure.
PROCEDURE cd-mrkt_clu-marketer :
define input parameter p-silence as logical no-undo .
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define variable v-tot-cli as integer no-undo .
define variable v-max-cli as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer  buf_cd-clu for ub.cd-clu.
define buffer  loc_cd-clu for ub.cd-clu.
define variable  ii as integer no-undo.
define variable v-mes as character no-undo .
_main:
DO ON ERROR undo, leave on stop undo, leave:
  if buf_cash-desk.pos-type <> 'MARIA':U
  or buf_cash-desk.cash-num <> 0 then do:
    assign
    v-mes =
    substitute("Клиенты на кассах можно определять только для кассовых менеджеров (номер кассы = 0) для типов касс &1"
              , buf_cash-desk.pos-type).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    return error v-mes.
  end.
  v-tot-cli = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_operative':U
                                  ,input 'tot-cli':U
                                  ,output v-mes).
  if v-tot-cli = ? then undo _main, return error v-mes.
  v-max-cli = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_general':U
                                  ,input 'max-cli':U
                                  , output v-mes).
  if v-max-cli = ? then undo _main, return error v-mes.
  DO ii = 1
     to v-max-cli :
    if not can-find (loc_cd-clu where
                    loc_cd-clu.obj-type = 'маг':U
                and loc_cd-clu.obj-code = buf_cash-desk.obj-code
                and loc_cd-clu.pos-type = buf_cash-desk.pos-type
                and loc_cd-clu.clu-type = '':U
                and loc_cd-clu.clu-code = ii
                   )
    then LEAVE .
  END .
  if ii > v-max-cli then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество клиентов &1" +
                "для касс &2 &3&4"
                , chr(10)
                , v-max-cli
                , 'маг':U
                , buf_cash-desk.obj-code
                )
      view-as alert-box ERROR .
      undo, return error "max-cli":U.
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_cd-clu.
  assign
  buf_cd-clu.cli-code = p-obj-code
  buf_cd-clu.cli-type = p-obj-type
  buf_cd-clu.obj-type = 'маг':U
  buf_cd-clu.obj-code = buf_Cash-desk.obj-code
  buf_cd-clu.pos-type = buf_cash-desk.pos-type
  buf_cd-clu.clu-type = '':U
  buf_cd-clu.to-send = yes
  buf_cd-clu.charkey_two = (if buf_cash-desk.pos-type = 'MARIA':U
                            then buf_cash-desk.addr-path
                            else "U":U)
  buf_cd-clu.clu-code = ii
  .
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'tot-cli':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input  (v-tot-cli + 1)
                                        ,input no
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <текущее количество клиентов на кассе> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'cli-to-send':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input yes
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <Есть коды клиентов, не отправленные на кассу> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  return "":U.
end.
END PROCEDURE.
procedure cd-mrkt_update-marketer-cli :
define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
define variable v-cli-to-send as logical no-undo .
define variable v-tot-cli as integer no-undo .
define variable v-max-clu as integer no-undo .
define buffer buf_cd-clu for ub.cd-clu.
do
on error undo, return error return-value
:
  v-cli-to-send = no.
  v-tot-cli = 0.
  FOR EACH buf_cd-clu WHERE
        buf_cd-clu.obj-type = 'маг':U
    and buf_cd-clu.obj-code =  p-obj-code
    and buf_cd-clu.pos-type =  p-pos-type
    and buf_cd-clu.clu-type =  '':U
    :
    if buf_cd-clu.to-del = yes then do:
      assign
      v-cli-to-send = yes.
    end.
    assign
    v-tot-cli = v-tot-cli + 1.
  end.
  run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  'MARIA_operative':U
                                          ,input  'tot-cli':U
                                          ,input ''
                                          ,input ?
                                          ,input 0.0
                                          ,input v-tot-cli
                                          ,input no
                                          ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.
  run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  'MARIA_operative':U
                                          ,input  'cli-to-send':U
                                          ,input ''
                                          ,input ?
                                          ,input 0.0
                                          ,input 0
                                          ,input v-cli-to-send
                                          ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.
  FIND LAST buf_cd-clu WHERE
          buf_cd-clu.obj-type = 'маг':U
      and buf_cd-clu.obj-code = p-obj-code
      and buf_cd-clu.pos-type = p-pos-type
      and buf_cd-clu.clu-type = '':U
      NO-LOCK use-index pi no-error .
  if available buf_cd-clu then do:
    if v-max-clu < buf_cd-clu.clu-code
    then
    v-max-clu = buf_cd-clu.clu-code.
  end.
  else do:
    v-max-clu = 0.
  end.
  run cd-attr-write  in this-procedure (
                                        input   p-db-num
                                        ,input  p-obj-code
                                        ,input  p-pos-type
                                        ,input  p-cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'max-clu':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input v-max-clu
                                        ,input no
                                        ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.
end.
end procedure.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-attr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
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
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure bc-oattr_name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-range          as integer   no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-range
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
procedure bc-oattr_tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_tooltip in g#attr-lib
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
procedure bc-oattr_value :
  define input  parameter p-b-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_value in g#attr-lib
      (input  p-b-code
      ,input  p-code
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
end procedure.
procedure bc-oattr_write :
  define input parameter p-b-code like ub.bar-code-obj-attr.b-code   no-undo .
  define input parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-value    like ub.bar-code-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_write in g#attr-lib
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_exist :
  define input  parameter p-b-code like ub.bar-code-obj-attr.b-code   no-undo .
  define input  parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_exist in g#attr-lib
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_delete :
  define input  parameter p-b-code like ub.bar-code-obj-attr.b-code   no-undo .
  define input  parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_delete in g#attr-lib
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fact-order-mpl :
  do
  on error undo, return error return-value
  :
define input  parameter p-doc-date as date     no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-fact-order as decimal   no-undo .
define variable v-fact-date            as date    no-undo .
define variable v-fact-time            as integer no-undo .
define variable v-fact-order           as decimal no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable l-shift-on as logical no-undo .
define variable l-date as date      no-undo .
define variable l-time as integer   no-undo .
define variable shift-date as date      no-undo .
define variable shift-num  as integer   no-undo .
define variable shift-name as character no-undo .
define variable max-fact-order as decimal   no-undo .
define buffer buf_global-state for ub.global-state  .
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
  run cur-time in this-procedure
  ( output v-fact-date ,
    output v-fact-time  ).
if p-doc-date = ? then do:
if buf_global-state.pl-use-sys-date-time  = true then do:
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  ?
        ,input  ?
        ,input  false
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
else do:
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
      if error-status :error then return error "Неопределена дата на объекте " + return-value .
      if p-doc-date <> ? then do:
      end.
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error substitute(" Ошибка из factdate.p: &1 &2"  , return-value , error-status :get-message(1)   ) .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
end.
else do:
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error "Ошибка factdate.p " + return-value .
      v-fact-date = p-doc-date .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
  end.
end procedure.
DEFINE TEMP-TABLE tt_price-all NO-UNDO LIKE ub.price-all
field sale-qnty as decimal
field sale-sum  as decimal
field sale-tnv  as decimal
field price-sale-base as decimal
field price-sale-rubl as decimal
field road-tax-base   as decimal
field road-tax-rubl   as decimal
field excise-base as decimal
field excise-rubl as decimal
field date-1 as date
field date-2 as date
field shift-1 as int
field shift-2 as int
field time-1 as int
field time-2 as int
field grp-name as char
field interv-name as char
field pay-name as char
field unit-cli as char
index pi
plt-priority DESCENDING
fact-order DESCENDING
qnty-from asc
sum-from asc
turnover-from asc
date-1 DESCENDING
time-1 DESCENDING
date-2 DESCENDING
time-2 DESCENDING
type-price DESCENDING
.
procedure mpl-autoprice :
define input  parameter p-only-b-code as logical   no-undo .
define input  parameter p-cli-type    as character no-undo .
define input  parameter p-cli-code    as integer   no-undo .
define input  parameter p-main-b-code as integer   no-undo .
define input  parameter p-b-code      as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-qnty-doc    as decimal   no-undo .
define input  parameter p-sum-doc     as decimal   no-undo .
define input  parameter p-vid-pay        as character no-undo .
define input  parameter p-cash-pay-type  as character no-undo .
define input  parameter p-fact-order  as decimal   no-undo .
define output parameter p-plt-id          as integer   no-undo .
define output parameter p-plt-db-num      as integer   no-undo .
define output parameter p-pdf-id          as integer   no-undo .
define output parameter p-pdf-db-num      as integer   no-undo .
define output parameter p-sale-price-base as decimal   no-undo .
define output parameter p-sale-price-rubl as decimal   no-undo .
define output parameter p-road-tax-base as decimal   no-undo .
define output parameter p-road-tax-rubl as decimal   no-undo .
define output parameter p-excise-base   as decimal   no-undo .
define output parameter p-excise-rubl   as decimal   no-undo .
define variable v-cli-oborot-ALL as decimal   no-undo .
define buffer buf_buyer-in-buyer-group   for ub.buyer-in-buyer-group  .
define buffer buf_turnover-buyer-main    for ub.turnover-buyer-main  .
define buffer buf1_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf2_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf_price-all              for ub.price-all  .
define buffer buf_goods                  for ub.goods      .
define buffer buf_global-state           for ub.global-state  .
define buffer buf_buyer-group            for ub.buyer-group  .
define buffer buf_turnover-group         for ub.turnover-group  .
define buffer buf_main-code              for ub.bar-code  .
define buffer buf_bar-code               for ub.bar-code  .
define buffer buf_pay-type               for ub.pay-type  .
define buffer buf_cash-pay               for ub.cash-pay  .
define variable to-day          as date      no-undo .
define variable v-base-rate0    as decimal   no-undo .
define variable v-base-scale0   as decimal   no-undo .
define variable v-exch-rate0    as decimal   no-undo .
define variable v-exch-scale0   as decimal   no-undo .
define variable v-base-rate     as decimal   no-undo .
define variable v-base-scale    as decimal   no-undo .
define variable v-exch-rate     as decimal   no-undo .
define variable v-exch-scale    as decimal   no-undo .
define variable v-host-code     as integer   no-undo .
define variable v-curr-abbr     as character no-undo .
define variable v-grp-name      as character no-undo .
define variable v-date-1        as date      no-undo .
define variable v-date-2        as date      no-undo .
define variable v-interv        as character no-undo .
define variable v-pay-name      as character no-undo .
define variable v-cli-oborot    as decimal   no-undo .
define variable v-trn-pay-code  as integer   no-undo .
define variable v-cash-pay-curr as integer   no-undo .
define variable v-cash-pay-code as integer   no-undo .
do
on error undo, return error return-value
:
find first buf_main-code no-lock where buf_main-code.b-code = p-main-b-code .
find first buf_goods no-lock where buf_goods.gds-code = buf_main-code.gds-code.
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ).
end.
if p-vid-pay <> "" then do:
   find first buf_pay-type no-lock where  buf_pay-type.obj-code = integer(p-vid-pay) no-error .
   if available buf_pay-type
      then v-trn-pay-code = buf_pay-type.obj-code.
      else v-trn-pay-code =  0.
end.
else v-trn-pay-code = 0 .
if p-cash-pay-type <> "" then do:
   find first buf_cash-pay no-lock where  recid(buf_cash-pay) = integer(p-cash-pay-type) no-error .
   if available buf_pay-type
      then
        assign
          v-cash-pay-curr = buf_cash-pay.curr-code
          v-cash-pay-code = buf_cash-pay.cdpay-code
        .
      else
        assign
          v-cash-pay-curr = 0
          v-cash-pay-code = 0
          .
end.
else
  assign
    v-cash-pay-curr = 0
    v-cash-pay-code = 0
    .
for each tt_price-all  : delete tt_price-all . end.
assign
  p-plt-id             = ?
  p-plt-db-num         = ?
  p-pdf-id             = ?
  p-pdf-db-num         = ?
  p-sale-price-base    = ?
  p-sale-price-rubl    = ?
  v-cli-oborot         = 0
.
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output to-day
  )  .
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  to-day
  ,output v-base-rate0
  ,output v-base-scale0
  )  .
  v-cli-oborot-ALL  = 0 .
  for each buf_turnover-buyer-main no-lock  where
           buf_turnover-buyer-main.cli-type = p-cli-type  and
           buf_turnover-buyer-main.cli-code = p-cli-code
           :
           v-cli-oborot-ALL = v-cli-oborot-ALL + buf_turnover-buyer-main.sum-doc-rubl-itog .
  end.
for each buf_price-all no-lock where
         buf_price-all.obj-type = p-obj-type and
         buf_price-all.obj-code = p-obj-code and
         buf_price-all.gds-code = buf_goods.gds-code and
         buf_price-all.status_  = 'акт':U  and
       ( p-only-b-code = false   or
       ( buf_price-all.b-code = p-main-b-code or
         buf_price-all.b-code = p-b-code))    and
        ( p-only-b-code = true  or
          buf_price-all.b-code = p-b-code)
          and
          buf_price-all.fact-order-sys-from  <= p-fact-order  and
        ( buf_price-all.fact-order-sys-to = ? or
          buf_price-all.fact-order-sys-to    >= p-fact-order)
        :
         v-interv   = "" .
         v-grp-name = "" .
         v-pay-name = "" .
         if buf_price-all.fact-order = 0  and buf_price-all.plt-priority = 0  then next.
         if buf_price-all.bgr-id > 0 then do:
            find first buf_buyer-group no-lock where
                       buf_buyer-group.bgr-id     = buf_price-all.bgr-id  and
                       buf_buyer-group.bgr-db-num = buf_price-all.bgr-db-num  no-error .
            if available buf_buyer-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
               find first buf_buyer-in-buyer-group no-lock where
                          buf_buyer-in-buyer-group.stts         = 0 and
                          buf_buyer-in-buyer-group.bgr-id       = buf_buyer-group.bgr-id     and
                          buf_buyer-in-buyer-group.bgr-db-num   = buf_buyer-group.bgr-db-num  and
                          buf_buyer-in-buyer-group.bbg-obj-type = p-cli-type and
                          buf_buyer-in-buyer-group.bbg-obj-code = p-cli-code
                          no-error .
                          if not available buf_buyer-in-buyer-group then do:
                             v-grp-name = "".
                             next.
                          end.
                          v-grp-name = buf_buyer-group.name .
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.tog-id > 0 then do:
            find first buf_turnover-group no-lock where
                       buf_turnover-group.tog-id     = buf_price-all.tog-id      and
                       buf_turnover-group.tog-db-num = buf_price-all.tog-db-num  no-error .
            if available buf_turnover-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
                  v-cli-oborot = v-cli-oborot-all  .
                  find first buf1_tnv-in-turnover-group no-lock where
                             buf1_tnv-in-turnover-group.stts       =  0     and
                             buf1_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf1_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf1_tnv-in-turnover-group.ttg-summa  <=  v-cli-oborot no-error .
                  find first buf2_tnv-in-turnover-group no-lock where
                             buf2_tnv-in-turnover-group.stts       =  0     and
                             buf2_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf2_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf2_tnv-in-turnover-group.ttg-summa  >=  v-cli-oborot no-error .
                  if not (available buf1_tnv-in-turnover-group and
                          available buf2_tnv-in-turnover-group ) then do:
                          v-grp-name = "".
                          next .
                  end.
                  v-grp-name = buf_turnover-group.name.
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.plt-fix-cource-crc-base = true then
            assign
              v-base-rate  = buf_price-all.pdf-base-rate
              v-base-scale = buf_price-all.pdf-base-scale
            .
            else
            assign
              v-base-rate  = v-base-rate0
              v-base-scale = v-base-scale0
            .
         if buf_price-all.plt-fix-cource-crc-doc = true then
            assign
              v-exch-rate  = buf_price-all.pdf-exch-rate
              v-exch-scale = buf_price-all.pdf-exch-scale
            .
            else do:
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf_price-all.curr-code
  ,input  to-day
  ,output v-exch-rate0
  ,output v-exch-scale0
  ,output v-curr-abbr
  )  .
            assign
              v-exch-rate  = v-exch-rate0
              v-exch-scale = v-exch-scale0
              .
           end.
           v-date-1 = date ( "" )  .
           if buf_price-all.fact-order-sys-from > 0 then do:
              if buf_price-all.start-sys-date <> ?   then  v-date-1 = buf_price-all.start-sys-date.
              if buf_price-all.start-shift-date <> ? then  v-date-1 = buf_price-all.start-shift-date.
              if buf_price-all.start-date <> ?       then  v-date-1 = buf_price-all.start-date.
           end.
           v-date-2 =  date ( "" )  .
           if buf_price-all.fact-order-sys-to > 0 then do:
              if buf_price-all.end-sys-date <> ?     then  v-date-2 = buf_price-all.end-sys-date.
              if buf_price-all.end-shift-date <> ?   then  v-date-2 = buf_price-all.end-shift-date.
              if buf_price-all.end-date <> ?         then  v-date-2 = buf_price-all.end-date.
           end.
           if buf_price-all.qnty-from <> ? then do :
              if not (
              ( p-qnty-doc  >= buf_price-all.qnty-from and buf_price-all.qnty-to = ? ) or
              ( p-qnty-doc  >= buf_price-all.qnty-from and p-qnty-doc <= buf_price-all.qnty-to and buf_price-all.qnty-to <> ?)
              ) then do:
                     v-interv = "".
                     next.
              end.
              v-interv = "К: " + string(buf_price-all.qnty-from) + " - " + ( if buf_price-all.qnty-to = ? then "и более" else string(buf_price-all.qnty-to)) .
           end.
           if buf_price-all.sum-from <> ? then do :
              if not (
              ( p-sum-doc  >= buf_price-all.sum-from and buf_price-all.sum-to = ? ) or
              ( p-sum-doc  >= buf_price-all.sum-from and p-sum-doc <= buf_price-all.sum-to and buf_price-all.sum-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "C: " +  string(buf_price-all.sum-from) + " - " + ( if buf_price-all.sum-to = ? then "и более" else string(buf_price-all.sum-to)) .
           end.
           if buf_price-all.turnover-from <> ? then do :
              if not (
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and buf_price-all.turnover-to = ? ) or
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and v-cli-oborot-ALL <= buf_price-all.turnover-to and buf_price-all.turnover-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "O: " +  string(buf_price-all.turnover-from) + " - " + ( if buf_price-all.turnover-to = ? then "и более" else string(buf_price-all.turnover-to)) .
           end.
           if buf_price-all.use-pay-type = 1 then do :
              if buf_price-all.pay-code <> v-trn-pay-code then do:
                 v-pay-name = "" .
                 next.
               end.
               v-pay-name = 'Оплата':U +  ":" + string(buf_price-all.pay-code) .
           end.
           if buf_price-all.use-cash-pay = 1 then do :
              if v-cash-pay-code <> 0 and  not ( buf_price-all.curr-pay-code = v-cash-pay-curr and
                                                 buf_price-all.cdpay-code    = v-cash-pay-code ) then do:
                v-pay-name = "" .
                next.
              end.
              v-pay-name = 'Касс.платеж':U + ":" + string(buf_price-all.cdpay-code) + "_" + string(buf_price-all.curr-pay-code).
           end.
          find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-all.b-code no-error .
          create tt_price-all .
          buffer-copy buf_price-all to tt_price-all
          assign
            tt_price-all.price-sale-rubl = buf_price-all.price-sale  * v-exch-rate / v-exch-scale
            tt_price-all.road-tax-rubl   = buf_price-all.road-tax    * v-exch-rate / v-exch-scale
            tt_price-all.excise-rubl     = buf_price-all.excise      * v-exch-rate / v-exch-scale
            tt_price-all.price-sale-base = tt_price-all.price-sale-rubl  / v-base-rate * v-base-scale
            tt_price-all.road-tax-base   = tt_price-all.road-tax-rubl    / v-base-rate * v-base-scale
            tt_price-all.excise-base     = tt_price-all.excise-rubl      / v-base-rate * v-base-scale
            tt_price-all.price-sale     = buf_price-all.price-sale
            tt_price-all.road-tax       = buf_price-all.road-tax
            tt_price-all.excise         = buf_price-all.excise
            tt_price-all.pdf-exch-rate   = v-exch-rate
            tt_price-all.pdf-exch-scale  = v-exch-scale
            tt_price-all.pdf-base-rate   = v-base-rate
            tt_price-all.pdf-base-scale  = v-base-scale
            tt_price-all.grp-name        = v-grp-name
            tt_price-all.date-1          = v-date-1
            tt_price-all.shift-1         = buf_price-all.start-shift-num
            tt_price-all.time-1          = buf_price-all.start-sys-time
            tt_price-all.date-2          = v-date-2
            tt_price-all.shift-2         = buf_price-all.end-shift-num
            tt_price-all.time-2          = buf_price-all.end-sys-time
            tt_price-all.interv-name     = v-interv
            tt_price-all.pay-name        = v-pay-name
            tt_price-all.unit-cli        = buf_bar-code.unit-cli
          .
end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = p-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = neos_price-all.price-sale-base
            p-sale-price-rubl  = neos_price-all.price-sale-rubl
            p-road-tax-base    = neos_price-all.road-tax-base
            p-road-tax-rubl    = neos_price-all.road-tax-rubl
            p-excise-base      = neos_price-all.excise-base
            p-excise-rubl      = neos_price-all.excise-rubl
            .
         end.
         else do:
              find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
              if error-status :error    then do:
                message "Не найден бар-код" p-b-code view-as alert-box error .
                return error return-value .
              end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
end.
end procedure.
procedure mpl-tpl-auto :
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-fact-order as decimal   no-undo .
define output parameter p-sale-price as decimal   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ) .
end.
assign
  p-pdf-id      = ?
  p-pdf-db-num  = ?
  p-sale-price  = ?
.
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_goods for ub.goods  .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
if error-status :error then return error return-value .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
if error-status :error then return error return-value .
define variable v-main-b-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
define buffer buf_price-all for ub.price-all  .
for each tt_price-all : delete tt_price-all. end.
    for each buf_price-all no-lock where
            buf_price-all.plt-id     = p-plt-id                 and
            buf_price-all.plt-db-num = p-plt-db-num             and
            buf_price-all.obj-type   = p-obj-type               and
            buf_price-all.obj-code   = p-obj-code               and
            buf_price-all.gds-code   = buf_goods.gds-code       and
          ( buf_price-all.b-code = v-main-b-code or
            buf_price-all.b-code = p-b-code)    and
            buf_price-all.status_    = 'акт':U         and
            buf_price-all.fact-order-sys-from  <= p-fact-order  and
          ( buf_price-all.fact-order-sys-to = ? or
            buf_price-all.fact-order-sys-to >=  p-fact-order)
            :
              create tt_price-all .
              buffer-copy buf_price-all to tt_price-all
              assign
                tt_price-all.price-sale  = buf_price-all.price-sale
              .
    end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = v-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = neos_price-all.price-sale
            .
         end.
         else do:
        find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
        if error-status :error    then do:
           message "Не найден бар-код" p-b-code view-as alert-box error .
           return error return-value .
        end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
  end.
end procedure.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-del-mrkt-gds               as logical        no-undo .
define variable v-send-stock-qnty            as logical        no-undo .
DEFINE VARIABLE jj                           as integer        no-undo .
DEFINE VARIABLE crgd                         as integer        no-undo .
DEFINE VARIABLE cr-txr                       as integer        no-undo .
define variable cr-ncr-dis-kat               as integer        no-undo .
DEFINE VARIABLE start-paket-txr              as logical init yes no-undo .
define variable v-count                      as integer          no-undo .
DEFINE VARIABLE var-report-num               as integer          no-undo .
DEFINE VARIABLE g#log                        as logical          no-undo .
DEFINE VARIABLE v-today                      as date             no-undo .
DEFINE VARIABLE v-time                       as integer          no-undo .
define variable v-r-b-curr-magia             as integer          no-undo .
DEFINE VARIABLE ind                          as integer          no-undo .
DEFINE VARIABLE s as character no-undo.
define variable v-index as integer no-undo .
DEFINE VARIABLE conf-attr                         as character        no-undo .
DEFINE VARIABLE conf-par                         as character        no-undo .
DEFINE VARIABLE par-type                        as character        no-undo .
DEFINE VARIABLE prichina                     as character        no-undo .
define buffer lock-batchprocess for ub.batchprocess .
define buffer request_prod-bc for ub.prod-bc.
define buffer r-gds-prt for ub.gds-prt.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define stream plucash.
define stream bar.
DEFINE VARIABLE chk_name                     as character        no-undo .
DEFINE VARIABLE bar_code                     as character        no-undo .
DEFINE VARIABLE b_code                       as character        no-undo .
DEFINE VARIABLE curr_cass                    as decimal          no-undo .
DEFINE VARIABLE dob-curr                     as character        no-undo .
DEFINE VARIABLE l-empty-scale                as logical          no-undo .
DEFINE VARIABLE for-SHOP-NAME                as character        no-undo .
DEFINE VARIABLE for-producer                 as character        no-undo .
DEFINE VARIABLE for-producer-int             as integer          no-undo .
DEFINE VARIABLE for-fact-qnty                like ub.gds-obj.fact-qnty no-undo .
DEFINE VARIABLE for-okdp                     like ub.goods.okdp  no-undo .
DEFINE VARIABLE temp-discnt-rule_            as integer          no-undo .
DEFINE VARIABLE temp-discnt-method_          as character        no-undo .
DEFINE VARIABLE temp-discnt-rule_pdf         as integer          no-undo .
DEFINE VARIABLE std-discnt-rule_             as integer          no-undo .
DEFINE VARIABLE for-wd                       as integer          no-undo .
DEFINE VARIABLE for-wgd                      as integer          no-undo .
DEFINE VARIABLE for-fp                       as logical          no-undo .
define variable for-petrol-purse             as logical          no-undo .
define variable need-auth                    as logical          no-undo .
DEFINE VARIABLE for-grp-code                 like ub.sum-grp.grp-code no-undo .
DEFINE VARIABLE main-b-code                  like ub.bar-code.b-code  no-undo .
DEFINE VARIABLE for-price                    as decimal          no-undo .
DEFINE VARIABLE for-road                     as decimal          no-undo .
DEFINE VARIABLE for-excise                   as decimal          no-undo .
DEFINE VARIABLE cashparts                    like ub.gds-obj.cash-parts no-undo .
DEFINE VARIABLE petrol-trk                   as logical          no-undo .
DEFINE VARIABLE tax-string                   as character        no-undo init "" .
DEFINE VARIABLE new-good                     as logical          no-undo init yes .
DEFINE VARIABLE IBM-good-code                as character        no-undo .
DEFINE VARIABLE qnty-discnt-rule_            as integer          no-undo init 0 .
DEFINE VARIABLE kat-discnt-rule_             as integer          no-undo init 0 .
DEFINE VARIABLE kat-discnt-method_           as character        no-undo .
DEFINE VARIABLE kat-discnt-rule_pdf          as integer          no-undo .
DEFINE VARIABLE date-discnt-rule_            as integer          no-undo init 0 .
DEFINE VARIABLE abs-discnt-rule_             as integer          no-undo init 0 .
DEFINE VARIABLE tot-discnt-rule_             as integer          no-undo init 0 .
define variable for-taracode                 as character        no-undo init "00".
define variable dflt-cd                      as character        no-undo .
DEFINE VARIABLE is-sc                        as logical          no-undo .
DEFINE VARIABLE taracode-bc                  as character        no-undo .
DEFINE VARIABLE rdtaxcd                      as INTEGER          no-undo .
DEFINE VARIABLE vattaxcd                     as INTEGER          no-undo .
DEFINE VARIABLE exctaxcd                     as INTEGER          no-undo .
define variable v-is-null-price              like ub.fbr-gds-obj.is-null-price  no-undo .
define variable v-is-menu                    like ub.fbr-gds-obj.is-menu no-undo .
define variable v-is-semi-finished           like ub.fbr-gds-obj.is-semi-finished no-undo .
define variable v-is-modificator             like ub.fbr-gds-obj.is-modificator no-undo .
define variable v-fbr-grp-code               like ub.fbr-gds-grp.node-code no-undo .
define variable v-fbr-obj-code               like ub.fbr-gds-obj.fbr-obj-code no-undo .
DEFINE VARIABLE alllstcs                     as logical           no-undo init no .
DEFINE VARIABLE noautocs                     as logical           no-undo init no .
DEFINE VARIABLE mask_s-c                     as character         no-undo .
DEFINE VARIABLE unq-artc                     as logical           no-undo init no .
DEFINE VARIABLE nam-2str                     as logical           no-undo init no .
DEFINE VARIABLE nam-artc                     as logical           no-undo init no .
DEFINE VARIABLE name-2cd                     as character       no-undo .
DEFINE VARIABLE cod-pcod                     as logical           no-undo .
DEFINE VARIABLE tax-cass                     as logical           no-undo init no .
DEFINE VARIABLE ipcsc-pfx                    as integer           no-undo init 23 .
DEFINE VARIABLE ipcpg-pfx                    as integer           no-undo init 24 .
DEFINE VARIABLE ncrgmdsc                     as character         no-undo .
DEFINE VARIABLE ncrdsc                       as character         no-undo .
DEFINE VARIABLE ncrdrank                     as character         no-undo  init "TX":U.
DEFINE VARIABLE ncrsc-pfx                    as character         no-undo init "23":U .
DEFINE VARIABLE ncrsc-frmt                   as character         no-undo init "EAN13" .
DEFINE VARIABLE ncrpg-pfx                    as character         no-undo init "24":U .
DEFINE VARIABLE ncrpg-frmt                   as character         no-undo init "EAN13" .
define variable ncr-save-param               as character         no-undo init 'no'.
DEFINE VARIABLE txfixnum                     as INTEGER           no-undo .
DEFINE VARIABLE rnd-znak                     as integer           no-undo init 2 .
DEFINE VARIABLE amntdisc                     as integer           no-undo .
DEFINE VARIABLE how-temp-disc                as character         no-undo .
DEFINE VARIABLE how-pcnt-kat                 as character         no-undo .
DEFINE VARIABLE discnt-to-send               as character         no-undo .
define variable v-is-restaurant              as logical no-undo .
define variable cd-vat                       as integer           no-undo .
define variable cdtaxlst                     as character         no-undo .
define variable v-20-part1 as integer no-undo init 2621.
define variable v-record as character no-undo .
define variable dr-list as character no-undo .
define variable drgdsrank as character no-undo .
define buffer buf_currency for ub.currency.
define buffer buf_producer for ub.clients.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
def var vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table cash-dis-rule no-undo like ub.dis-rule.
define temp-table cash-dis-time-rule no-undo like ub.dis-time-rule.
procedure create-dis-rule :
define input parameter p-rule-num like ub.dis-rule.rule-num no-undo .
define input parameter p-tree as logical no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer term_dis-rule for ub.dis-rule.
define buffer term_dis-time-rule for ub.dis-time-rule.
define buffer root_cash-dis-rule for cash-dis-rule.
define buffer root_cash-dis-time-rule for cash-dis-time-rule.
define buffer term_cash-dis-rule for cash-dis-rule.
define buffer term_cash-dis-time-rule for cash-dis-time-rule.
  do
  on error undo, return error
  :
    find first root_cash-dis-rule no-lock where                                                         ~
              root_cash-dis-rule.rule-num = p-rule-num no-error.
    if not available root_cash-dis-rule then do:
      find first buf_dis-rule no-lock where
                buf_dis-rule.rule-num = p-rule-num no-error.
      if available buf_dis-rule then do:
        if buf_dis-rule.time-rule-num <> 0 then do:
          find first buf_dis-time-rule no-lock where
                    buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num no-error.
        end.
        create root_cash-dis-rule.
        buffer-copy buf_dis-rule to root_cash-dis-rule.
        if available buf_dis-time-rule then do:
          find first root_cash-dis-time-rule no-lock where
                    root_cash-dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num no-error.
          if not available root_cash-dis-time-rule then do:
            create root_cash-dis-time-rule.
            buffer-copy buf_dis-time-rule to root_cash-dis-time-rule.
          end.
        end.
        else do:
          assign
          root_cash-dis-rule.time-rule-num = 0.
        end.
        if buf_dis-rule.uniq-field <> "":U then do:
          for each term_dis-rule no-lock where
                  term_dis-rule.upper-rule-num =  buf_dis-rule.rule-num:
            if term_dis-rule.time-rule-num <> 0 then do:
              find first term_dis-time-rule no-lock where
                        term_dis-time-rule.time-rule-num = term_dis-rule.time-rule-num no-error.
            end.
            create term_cash-dis-rule.
            buffer-copy term_dis-rule to term_cash-dis-rule.
            if term_dis-rule.time-rule-num = 0
            or available term_dis-time-rule
            or root_cash-dis-rule.time-rule-num = 0
            then do:
              if available term_dis-time-rule then do:
                find first term_cash-dis-time-rule no-lock where
                          term_cash-dis-time-rule.time-rule-num = term_dis-rule.time-rule-num no-error.
                if not available term_cash-dis-time-rule then do:
                  create term_cash-dis-time-rule.
                  buffer-copy term_dis-time-rule to term_cash-dis-time-rule.
                end.
              end.
            end.
          end.
        end.
      end.
    end.
  end.
end procedure.
define temp-table temp-cd-plu no-undo like ub.cd-plu .
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function ncr-amnt-disc returns character (
  input p-pcnt-discnt-rule as integer, input p-price-sale as decimal).
define variable v-result as character no-undo .
define variable ii as integer no-undo .
define variable v-entry as character no-undo extent 3.
for each cash-dis-rule  no-lock where
      cash-dis-rule.upper-rule-num = p-pcnt-discnt-rule:
  assign
  ii = ii + 1
  v-entry[ii] = "000000":U + string(round(cash-dis-rule.doc-qnty / cash-gds.cli-base-rate, 0), "999999":U) +
                replace(string(p-price-sale * (1 - cash-dis-rule.discnt-value / 100), "999999.99"), ".":U, "":U)
  .
end.
if v-entry[2] = "":U then
assign
v-entry[2] = v-entry[1]
.
if v-entry[3] = "":U then
assign
v-entry[3] = v-entry[2]
.
assign
v-result = v-entry[1] + v-entry[2] + v-entry[3]
.
return v-result.
END FUNCTION.
function ncr-date-disc returns character (
  input p-date-discnt-rule  as integer, input p-price-sale as decimal).
define variable v-result as character no-undo .
define variable ii as integer no-undo .
define variable v-entry as character no-undo extent 3.
for each cash-dis-rule  no-lock where
      cash-dis-rule.upper-rule-num = p-date-discnt-rule,
    first cash-dis-time-rule no-lock where cash-dis-time-rule.time-rule-num = cash-dis-rule.time-rule-num :
  assign
  ii = ii + 1
  v-entry[ii] =
                substring(string(year(cash-dis-time-rule.date-from), "9999":U), 3, 2)   +
                string(month(cash-dis-time-rule.date-from), "99":U) +
                string(day(cash-dis-time-rule.date-from), "99":U)  +
                substring(string(year(cash-dis-time-rule.date-to), "9999":U), 3, 2)   +
                string(month(cash-dis-time-rule.date-to), "99":U) +
                string(day(cash-dis-time-rule.date-to), "99":U) +
                replace(string(cash-gds.price-sale * (1 - cash-dis-rule.discnt-value / 100), "999999.99"), ".":U, "":U).
end.
if v-entry[2] = "":U then
assign
v-entry[2] = v-entry[1]
.
if v-entry[3] = "":U then
assign
v-entry[3] = v-entry[2]
.
assign
v-result = v-entry[1] + v-entry[2] + v-entry[3]
.
return v-result.
END FUNCTION.
function ncr-temp-disc returns character (
  input p-temp-discnt-rule  as integer, input p-price-sale as decimal, p-temp-disc-dec as decimal).
define variable v-result as character no-undo .
define variable ii as integer no-undo .
define variable v-entry as character no-undo extent 3.
define variable v-dec as decimal no-undo .
define variable v-disc-price-sale as decimal no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer no-undo .
define buffer buf_cash-dis-rule for cash-dis-rule.
find first buf_cash-dis-rule where
         buf_cash-dis-rule.rule-num = p-temp-discnt-rule no-error .
if not available buf_cash-dis-rule then return "":U.
if buf_cash-dis-rule.templ-rl-root <> 29
and buf_cash-dis-rule.templ-rl-root <> 86
then do:
  assign
  v-entry[1] =
  "000"                                                   +
  "0"                                                     +
  "0000"                                                  +
  "2359"                                                     +
   replace(string(cash-gds.price-sale * (1 + p-temp-disc-dec / 100), "999999.99"), ".":U, "":U)
   .
end.
else do:
  for each cash-dis-rule  no-lock where
        cash-dis-rule.upper-rule-num = p-temp-discnt-rule ,
      first cash-dis-time-rule no-lock where cash-dis-time-rule.time-rule-num = cash-dis-rule.time-rule-num :
    case cash-dis-rule.value-type:
      when integer('1':U) then do:
        v-dec = cash-gds.price-sale * (1 - cash-dis-rule.discnt-value / 100).
      end.
      when integer('12':U) then do:
        find first cash-gds-discnt where
                  cash-gds-discnt.b-code = cash-gds.b-code
              and cash-gds-discnt.rule-num = cash-dis-rule.rule-num
              and cash-gds-discnt.obj-type = 'маг':U
              and cash-gds-discnt.obj-code = i-obj-code
              no-error.
        if not available cash-gds-discnt then do:
          v-dec = cash-gds.price-sale.
        end.
        else do:
          assign
          v-dec = cash-gds-discnt.discnt-value
          .
        end.
      end.
      otherwise do:
        v-dec = cash-gds.price-sale.
      end.
    end case.
    assign
    ii = ii + 1
    v-entry[ii] =
                  "000"                                                   +
                  (if cash-dis-time-rule.week-day-0 then "0" else "":U)   +
                  (if cash-dis-time-rule.week-day-7 then "1" else "":U)   +
                  (if cash-dis-time-rule.week-day-1 then "2" else "":U)   +
                  (if cash-dis-time-rule.week-day-2 then "3" else "":U)   +
                  (if cash-dis-time-rule.week-day-3 then "4" else "":U)   +
                  (if cash-dis-time-rule.week-day-4 then "5" else "":U)   +
                  (if cash-dis-time-rule.week-day-5 then "6" else "":U)   +
                  (if cash-dis-time-rule.week-day-6 then "7" else "":U)   +
                  replace(string(cash-dis-time-rule.time-from, "HH:MM"), ":":U, "":U) +
                  replace(string(cash-dis-time-rule.time-to, "HH:MM"), ":":U, "":U) +
                  replace(string(v-dec, "999999.99"), ".":U, "":U)
    .
if ii = 3 then leave.
  end.
end.
if v-entry[2] = "":U then
assign
v-entry[2] = v-entry[1]
.
if v-entry[3] = "":U then
assign
v-entry[3] = v-entry[2]
.
assign
v-result = v-entry[1] + v-entry[2] + v-entry[3]
.
return v-result.
END FUNCTION.
function ncr-d-rank returns character (
  input p-d-rank as character, input p-pcnt-discnt-rule  as integer, input p-temp-discnt-rule as integer, input p-date-discnt-rule as integer).
define variable v-result as character no-undo .
define variable ii as integer no-undo .
do ii = 1 to length(p-d-rank):
  CASE substr(p-d-rank, ii, 1):
    when "X":U then do:
      if p-pcnt-discnt-rule <> 0 then v-result = "X":U.
    end.
    when "T":U then do:
      if p-temp-discnt-rule <> 0 then v-result = "T":U.
    end.
    when "D":U then do:
      if p-date-discnt-rule <> 0 then v-result = "D":U.
    end.
  END CASE.
  if v-result <> "":U then LEAVE.
end.
if v-result = "":U then v-result = chr(32).
return v-result.
END FUNCTION.
FUNCTION check-ban-sales-via-cd return logical ( input p-gds-code as integer ) :
    define variable v-upper-code as int no-undo.
    define variable v-value as character no-undo.
    define variable v-type as character no-undo.
    define buffer lc_gds-grp for ub.gds-grp.
    define buffer lc_goods for ub.goods.
   if p-gds-code <> 0 then do:
    find first lc_goods where lc_goods.gds-code = p-gds-code.
    v-upper-code = lc_goods.grp-code.
    do while v-upper-code > 0 :
        find first lc_gds-grp where lc_gds-grp.node-code = v-upper-code.
        run ggoattr-value(
          input lc_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input 'ban-sales-via-cd':U,
          output v-value,
          output v-type
        ).
       if v-value = "yes" then
          return true.
       else
       do:
          run ggoattr-value(
             input lc_gds-grp.node-code,
             input shop.host-code,
             input "",
             input 0,
             input 'ban-sales-via-cd':U,
             output v-value,
             output v-type
             ).
          if v-value = "yes" then
             return true.
          else
          do:
             run ggoattr-value(
                input lc_gds-grp.node-code,
                input shop.host-code,
                input 'маг':U,
                input i-obj-code,
                input 'ban-sales-via-cd':U,
                output v-value,
                output v-type
                ).
             if v-value = "yes" then
                return true.
             else v-upper-code = lc_gds-grp.upper-code.
          end .
       end.
      end.
    end.
end.
FUNCTION convert-tax-code returns integer
                                          ( input p-rate-code as integer
                                           ,input p-cdtaxlst  as character
                                          ) :
define variable jj as integer no-undo .
  do jj = 1 to num-entries(p-cdtaxlst, ";"):
    if entry(jj, p-cdtaxlst, ";") begins (string(p-rate-code) + "-") then do:
      return integer(entry(2, entry(jj, p-cdtaxlst, ";"), "-":U)).
    end.
  end.
END FUNCTION.
FUNCTION convert-maria-tax-code returns character
                                          ( input p-vat-rate-code as integer
                                           ,input p-slt-rate-code as integer
                                           ,input p-cdtaxlst  as character
                                          ) :
define variable jj as integer no-undo .
define variable aa as character no-undo extent 8.
define variable v-return-value as character no-undo .
  do jj = 1 to 8:
    if jj <= num-entries(p-cdtaxlst, ";") then do:
      if entry(jj, p-cdtaxlst, ";") begins (string(p-vat-rate-code) + "-") then do:
        aa[jj] = '1'.
      end.
      if entry(jj, p-cdtaxlst, ";") begins (string(p-slt-rate-code) + "-") then do:
        aa[jj] = '1'.
      end.
    end.
    if aa[jj] = '':U then aa[jj] = '0'.
    v-return-value = aa[jj] + v-return-value.
  end.
return v-return-value.
END FUNCTION.
FUNCTION convert-maria-tax-code-2 returns integer
                                          ( input p-rate-code as integer
                                           ,input p-cdtaxlst  as character
                                          ) :
define variable jj as integer no-undo .
define variable v-return-value as integer no-undo .
  do jj = 1 to num-entries(p-cdtaxlst, ";"):
    if entry(jj, p-cdtaxlst, ";") begins (string(p-rate-code) + "-") then do:
      return jj.
    end.
  end.
return 0.
END FUNCTION.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type52 as character no-undo.
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
  ,output varscales-pref-type52
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type52 as character no-undo.
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
  ,output varpgscales-pref-type52
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
define variable callpoint                    as character      no-undo .
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE asc-gds.
DEFINE parameter buffer loc-goods for gds-list.
DEFINE parameter buffer loc-bar-code for ub.bar-code.
DEFINE parameter buffer loc-gds-prt-root for ub.gds-prt.
DEFINE parameter buffer loc-gds-obj for ub.gds-obj.
DEFINE parameter buffer loc-price-list for ub.price-list.
DEFINE parameter buffer loc-units for ub.units.
DEFINE parameter buffer loc-gds-prt-term for ub.gds-prt.
DEFINE input parameter loc-prod-bc like ub.prod-bc.b-str.
DEFINE input parameter loc-bc-on-type like ub.prod-bc.bc-on-type.
DEFINE input parameter loc-bc-units-cli-type like ub.units.type.
DEFINE input parameter loc-bc-units-okei like ub.units.okei.
define input parameter parhost-code like ub.sysconf.host-code no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define variable v-doc-num like ub.price-list.doc-num no-undo .
DEFINE VARIABLE vat-value like ub.doc-line.vat-pc no-undo .
DEFINE VARIABLE slt-value like ub.doc-line.slt-pc no-undo .
define variable v-disc-price-sale as decimal no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer no-undo .
define variable v-oss as character no-undo.
define variable v-gtd as character no-undo .
define variable v-is-gas as character no-undo .
define variable v-ban-bonus as character no-undo .
define variable v-ptrl-as-good as character no-undo .
define variable v-type as character no-undo .
define variable disc-b-code as integer no-undo .
define variable v-main-prt-b-code as integer no-undo .
define variable IBM-good-code as character no-undo .
define variable IBM-good-code-2 as character no-undo .
define variable IBM2-short      as character no-undo .
define variable v-gds-null-price as character no-undo .
define variable iii as integer no-undo .
define variable v-mask-full as character no-undo .
define variable v-mask-short as character no-undo .
define variable vKKT as integer no-undo.
define variable attrValue as character no-undo.
define variable attrType  as character no-undo.
DEFine BUFFER BUF_BAR-CODE FOR UB.BAR-CODE.
define buffer buf_price-list for ub.price-list.
define buffer buf_price-doc-forming-gds FOR UB.PRICE-doc-forming-gds.
define buffer buf_temp-dis-gds-rule for temp-dis-gds-rule.
define buffer main-prt-bar-code  for ub.bar-code.
define buffer buf_goods-attr for goods-attr.
define buffer b-code for code.
FIND FIRST cash-gds where cash-gds.crf = (cr + 1) No-ERROR.
start-paket = no.
if not avail cash-gds then do:
create cash-gds.
error-status:error = false.
end.
cash-gds.crf = cr + 1.
cr = cr + 1.
if loc-bar-code.in-code <> ''
or loc-bar-code.part-code <> ''
then do:
  find first main-prt-bar-code no-lock where
            main-prt-bar-code.gds-code = loc-goods.gds-code
        and main-prt-bar-code.node-code = loc-bar-code.node-code
        and main-prt-bar-code.unit-cli = loc-bar-code.unit-cli
        and main-prt-bar-code.part-code = ''
        and main-prt-bar-code.in-code = '' no-error.
  if available main-prt-bar-code then do:
    v-main-prt-b-code = main-prt-bar-code.b-code.
  end.
end.
else do:
  v-main-prt-b-code = loc-bar-code.b-code.
end.
find first tt-tax no-lock where
           tt-tax.tax-code = vattaxcd no-error .
do iii = 1 to num-entries(mask_s-c) :
  assign
    v-mask-full  = trim(entry(iii, mask_s-c))
    v-mask-short = entry(1, v-mask-full, "*")
    loc-prod-bc  = trim(loc-prod-bc)
  .
  if length(v-mask-full) = length(loc-prod-bc) and  substring(loc-prod-bc, 1, length(v-mask-short)) = v-mask-short then
    loc-prod-bc = "*" + substring(loc-prod-bc, length(v-mask-short) + 1).
end.
define variable vBc-on as logical no-undo.
if loc-prod-bc ne ?
then do:
    find first prod-bc where prod-bc.b-code eq loc-bar-code.b-code
                         and prod-bc.b-str  eq loc-prod-bc
                         no-lock no-error.
    if available prod-bc
    then
       vBc-on = prod-bc.bc-on.
    else
       vBc-on = yes.
end.
else
   vBc-on = yes.
run gdsoattr-value in this-procedure (
  'dt-seasons':U,
  loc-goods.gds-code,
  parobj-type,
  parobj-code,
  output attrValue,
  output attrType
) no-error.
if attrValue <> "" then do:
  find first b-code where
             b-code.parent = "DTSeasons"
         and b-code.code   = attrValue
       no-lock no-error.
  v-main-prt-b-code = integer(b-code.code).
end.
else release b-code.
assign
cash-gds.gds-code = loc-goods.gds-code
cash-gds.artic = loc-goods.artic
cash-gds.b-code = loc-bar-code.b-code
cash-gds.main-prt-b-code = v-main-prt-b-code
cash-gds.b-str = if loc-prod-bc = ? then "" else loc-prod-bc
cash-gds.bc-on-type = loc-bc-on-type
cash-gds.bc-on = vBc-on
cash-gds.unit-cli = loc-bar-code.unit-cli
cash-gds.cli-base-rate = loc-bar-code.cli-base-rate
cash-gds.std-discnt-rule = std-discnt-rule_
cash-gds.gds-namelong = loc-goods.gds-name
cash-gds.gds-name = IF nam-2str
                    then if available b-code then b-code.codename else loc-goods.gds-name
                    else (
                          IF nam-artc
                          then loc-goods.artic
                          else if available b-code
                               then b-code.codename
                               else (if loc-goods.chk-name <> ""
                                     then loc-goods.chk-name
                                     else loc-goods.gds-name)
                         )
cash-gds.f-name = if NOT l-empty-scale then loc-gds-prt-term.f-name else ""
cash-gds.unit-base = loc-goods.unit-base
cash-gds.grp-code = for-grp-code
cash-gds.fp = for-fp
cash-gds.ingredient = loc-goods.struct
cash-gds.producer = for-producer
cash-gds.producer-int = for-producer-int
cash-gds.alpha1     = loc-goods.alpha1.
  run gds-attr-value in this-procedure  ( input cash-gds.gds-code
                                         ,input 'office-type':U
                                         ,output v-oss
                                         ,output v-type) no-error.
cash-gds.office-type = v-oss.
  run gds-attr-value in this-procedure  ( input cash-gds.gds-code
                                         ,input 'type-method-calc':U
                                         ,output v-oss
                                         ,output v-type) no-error.
if v-oss <> "" then
  assign
    cash-gds.CalculationMethod = int(entry(1,v-oss,","))
    cash-gds.CalculationMethodRestr = if num-entries(v-oss,",") > 1 then int(entry(2,v-oss,",")) else 0
  .
else
  assign
    cash-gds.CalculationMethod = 0
    cash-gds.CalculationMethodRestr = 0
  .
assign
cash-gds.fact-qnty = for-fact-qnty
cash-gds.okei = loc-bc-units-okei
cash-gds.kat-discnt-method = kat-discnt-method_
cash-gds.temp-discnt-method = temp-discnt-method_
cash-gds.kat-discnt-rule = (if how-pcnt-kat = 'pcnt-kat-pdf':U
                             then  kat-discnt-rule_pdf
                             else  kat-discnt-rule_)
cash-gds.date-discnt-rule = date-discnt-rule_
cash-gds.abs-discnt-rule = abs-discnt-rule_
cash-gds.tot-discnt-rule = tot-discnt-rule_
cash-gds.wgd-rule = for-wgd
cash-gds.gds-stat = ( if lookup( 'вес':U, loc-bc-units-cli-type ) > 0 OR lookup('дро':U, loc-bc-units-cli-type) > 0
                        then 1
                        else 0)
cash-gds.gds-stat = (if (lookup('топ':U, loc-units.type) > 0 AND lookup('дро':U, loc-units.type) > 0)
                     or for-petrol-purse
                     then (cash-gds.gds-stat + 8)
                     else cash-gds.gds-stat)
cash-gds.gds-stat = if (loc-goods.gds-type = 'у':U and (cash-gds.gds-stat < 8 or for-petrol-purse))
                    then (cash-gds.gds-stat + 16)
                    else cash-gds.gds-stat
cash-gds.gds-stat = if cash-gds.fp
                    then (cash-gds.gds-stat + 2)
                    else cash-gds.gds-stat
cash-gds.gds-stat = if cash-gds.wgd-rule > 0
                    then (cash-gds.gds-stat + 128)
                    else cash-gds.gds-stat
cash-gds.office = if loc-goods.gds-type = 'у':U then 1 else 0
cash-gds.temp-discnt-rule = (if how-temp-disc = 'temp-disc-pdf':U
                             then temp-discnt-rule_pdf
                             else temp-discnt-rule_)
cash-gds.wd-rule = for-wd
cash-gds.pp = (if for-petrol-purse then 1 else 0)
cash-gds.need-auth = (if need-auth then 1 else 0)
cash-gds.price-sale =  for-price
cash-gds.unit-type = loc-units.type
cash-gds.unit-cli-type = loc-bc-units-cli-type
cash-gds.tax-string = tax-string
cash-gds.new-good = new-good
cash-gds.rc = recid(loc-goods)
cash-gds.qnty-discnt-rule = qnty-discnt-rule_
cash-gds.vat-pc = (if avail tt-tax
                   then tt-tax.rate-value
                   else 0)
cash-gds.vat-code = (if avail tt-tax
                     then tt-tax.rate-code
                     else ?)
cash-gds.is-menu  = (if v-is-menu then 1 else 0)
cash-gds.is-semi-finished = (if v-is-semi-finished then 1 else 0)
cash-gds.is-modificator = (if v-is-modificator then 1 else 0)
cash-gds.fbr-grp-code = v-fbr-grp-code
cash-gds.fbr-grp-code-0 = loc-goods.fbr-grp-code
cash-gds.DepartID = v-fbr-obj-code
cash-gds.zp = (if v-is-null-price then 1 else 0)
cash-gds.node-code = loc-bar-code.node-code
cash-gds.taracode = for-taracode
cash-gds.is-main-code = (if cash-gds.b-str = ""
                         and loc-bar-code.in-code = ""
                         and loc-bar-code.part-code = ""
                         and cash-gds.unit-base = cash-gds.unit-cli
                         then yes
                         else no)
cash-gds.obj-type = parobj-type
cash-gds.obj-code = parobj-code
.
assign
cash-gds.gds-name1 =   name-2cdf(
                      input name-2cd
                    , input yes
                    , input cod-pcod
                    , input cash-gds.b-code
                    , input loc-goods.gds-code
                    , input loc-goods.artic
                    , input loc-goods.engl-name
                    , input loc-bar-code.in-code
                    , input loc-bar-code.part-code
                    , input parobj-type
                    , input parobj-code
                    , input loc-goods.alpha1
                    , output v-gtd
                    )
cash-gds.gtd   = v-gtd
.
vKKT = 255.
find first b-code where
           b-code.parent  = "okei-kkt"
       and b-code.code    = string(cash-gds.okei)
       and b-code.status_ = 0
no-lock no-error.
if avail b-code then
   vKKT = integer(b-code.CodeName) no-error.
if error-status:error then vKKT = 255.
cash-gds.kkt = vKKT.
if (lookup('топ':U, loc-units.type) > 0 AND lookup('дро':U, loc-units.type) > 0) then do:
   run gds-attr-value in this-procedure  (
                                          input cash-gds.gds-code
                                         ,input 'fuel-type':U
                                         ,output v-is-gas
                                         ,output v-type) no-error.
   run gds-attr-value in this-procedure  (
                                          input cash-gds.gds-code
                                         ,input 'ptrl-as-good':U
                                         ,output v-ptrl-as-good
                                         ,output v-type) no-error.
   assign
   cash-gds.ptrl-as-good = logical(v-ptrl-as-good)
   no-error .
   assign
   cash-gds.is-gas = (v-is-gas = 'metan':U)
   no-error .
   if cash-gds.is-gas then do:
     cash-gds.gds-stat = cash-gds.gds-stat + 64.
   end.
end.
   run gds-attr-value in this-procedure  (
                                          input cash-gds.gds-code
                                         ,input 'ban-bonus':U
                                         ,output v-ban-bonus
                                         ,output v-type) no-error.
  assign
   cash-gds.wd = int(logical(v-ban-bonus))
   no-error .
if how-temp-disc = 'temp-disc':U then do:
  case temp-discnt-method_:
    when "" then do:
    end.
    when "bar-code.b-code" then do:
      if loc-bar-code.in-code <> ''
      or loc-bar-code.part-code <> ''
      then do:
        disc-b-code = cash-gds.main-prt-b-code.
      end.
      else do:
        disc-b-code = cash-gds.b-code.
      end.
      find first buf_temp-dis-gds-rule where
              buf_temp-dis-gds-rule.gds-code = cash-gds.gds-code
          and buf_temp-dis-gds-rule.nonunique = string( disc-b-code) no-error.
      if available buf_temp-dis-gds-rule then do:
          cash-gds.temp-discnt-rule = buf_temp-dis-gds-rule.rule-num.
      end.
    end.
    otherwise do:
      cash-gds.temp-discnt-rule = 0.
    end.
  end.
end.
assign
cash-gds.gds-name1 =   name-2cdf(
                      input name-2cd
                    , input yes
                    , input cod-pcod
                    , input cash-gds.b-code
                    , input loc-goods.gds-code
                    , input loc-goods.artic
                    , input loc-goods.engl-name
                    , input loc-bar-code.in-code
                    , input loc-bar-code.part-code
                    , input parobj-type
                    , input parobj-code
                    , input loc-goods.alpha1
                    , output v-gtd
                    )
cash-gds.gtd   = v-gtd
.
assign
cash-gds.ean-lz = ''
cash-gds.ean-rz = ''
cash-gds.code-short = ''
.
run ibm-gdsc in this-procedure (input no
                              , output cash-gds.ean-lz
                              , output cash-gds.ean-rz
                              , output cash-gds.code-short
                              ) no-error .
if new-good then new-good = not new-good.
if action = "U" then do:
  if cash-gds.kat-discnt-rule <> 0
  and how-pcnt-kat = 'pcnt-kat-pdf':U
  then do:
    for each cash-dis-rule no-lock where
          cash-dis-rule.upper-rule-num = cash-gds.kat-discnt-rule
    :
      run mpl-tpl-auto in this-procedure ( input cash-gds.b-code
                                          ,input 'маг':U
                                          ,input i-obj-code
                                          ,input integer(entry(1, cash-dis-rule.charkey_one,"-"))
                                          ,input integer(entry(2, cash-dis-rule.charkey_one,"-"))
                                          ,input ?
                                          ,output v-disc-price-sale
                                          ,output v-pdf-id
                                          ,output v-pdf-db-num ) no-error.
      if error-status:error
      or v-disc-price-sale = 0
      or v-disc-price-sale = ?
      then do:
      end.
      else do:
        find first  cash-gds-discnt where
                  cash-gds-discnt.b-code = cash-gds.b-code
                and  cash-gds-discnt.rule-num = cash-dis-rule.rule-num
                and cash-gds-discnt.obj-type = parobj-type
                and cash-gds-discnt.obj-code = parobj-code No-ERROR.
        if not available cash-gds-discnt then do:
          find first  cash-gds-discnt where
                    cash-gds-discnt.crf = (crgd + 1) No-ERROR.
          if not available cash-gds-discnt then do:
            create cash-gds-discnt.
            assign
            cash-gds-discnt.crf = crgd + 1.
          end.
          crgd = crgd + 1.
          assign
          cash-gds-discnt.b-code = cash-gds.b-code
          cash-gds-discnt.rule-num = cash-dis-rule.rule-num
          cash-gds-discnt.obj-type = parobj-type
          cash-gds-discnt.obj-code = parobj-code
          cash-gds-discnt.discnt-value = v-disc-price-sale
          .
          release cash-gds-discnt.
        end.
      end.
    end.
  end.
  if cash-gds.temp-discnt-rule <> 0
  and how-temp-disc = 'temp-disc-pdf':U
  then do:
    for each cash-dis-rule no-lock where
          (cash-dis-rule.upper-rule-num = cash-gds.temp-discnt-rule
      or cash-dis-rule.rule-num = cash-gds.temp-discnt-rule)
      and cash-dis-rule.is-term = yes
    :
      run mpl-tpl-auto in this-procedure ( input cash-gds.b-code
                                          ,input 'маг':U
                                          ,input i-obj-code
                                          ,input integer(entry(1, cash-dis-rule.charkey_one,"-"))
                                          ,input integer(entry(2, cash-dis-rule.charkey_one,"-"))
                                          ,input ?
                                          ,output v-disc-price-sale
                                          ,output v-pdf-id
                                          ,output v-pdf-db-num ) no-error.
      if error-status:error
      or v-disc-price-sale = 0
      or v-disc-price-sale = ?
      then do:
      end.
      else do:
        find first  cash-gds-discnt where
                  cash-gds-discnt.b-code = cash-gds.b-code
                and  cash-gds-discnt.rule-num = cash-dis-rule.rule-num
                and cash-gds-discnt.obj-type = parobj-type
                and cash-gds-discnt.obj-code = parobj-code No-ERROR.
        if not available cash-gds-discnt then do:
          find first  cash-gds-discnt where
                    cash-gds-discnt.crf = (crgd + 1) No-ERROR.
          if not available cash-gds-discnt then do:
            create cash-gds-discnt.
            assign
            cash-gds-discnt.crf = crgd + 1.
          end.
          crgd = crgd + 1.
          assign
          cash-gds-discnt.b-code = cash-gds.b-code
          cash-gds-discnt.rule-num = cash-dis-rule.rule-num
          cash-gds-discnt.obj-type = parobj-type
          cash-gds-discnt.obj-code = parobj-code
          cash-gds-discnt.discnt-value = v-disc-price-sale.
          release cash-gds-discnt.
        end.
      end.
    end.
  end.
end.
END PROCEDURE.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type54 as character no-undo .
define variable v-value-character54 as date no-undo .
define variable v-value-date54 as date no-undo .
define variable v-value-decimal54 as decimal no-undo .
define variable v-value-integer54 as INTEGER no-undo .
define variable v-value-logical54 AS LOGICAL no-undo .
define variable v-tth54 as handle no-undo .
define variable cdpcknum as integer no-undo init 200.
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  abs(i-obj-code)
    ,input  'cd-sending':U
    ,input  'cdpcknum':U
    ,output v-value-character54
    ,output v-value-date54
    ,output v-value-decimal54
    ,output cdpcknum
    ,output v-value-logical54
    ,output v-param-type54
    ,INPUT-OUTPUT table-handle v-tth54
    )  .
delete object v-tth54.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'txfixnum'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
IF not error-status:error then
txfixnum = integer(conf-par).
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
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
    if thbjattr_thbj-attr.prop-code = 'rnd-znk':U then rnd-znak = thbjattr_thbj-attr.property-value-integer .
end.
for each thbjattr_thbj-attr :
  delete thbjattr_thbj-attr .
end.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'gds-ref':U
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
    if thbjattr_thbj-attr.prop-code = 'unq-artc':U then unq-artc = thbjattr_thbj-attr.property-value-logical .
end.
assign
rdtaxcd  = integer('3':U)
vattaxcd = integer('1':U)
exctaxcd = integer('4':U).
assign
var-report-num = dynamic-next-value( "next-report":U, "ubflt":U)
.
FIND ub.shop WHERE ub.shop.obj-code = abs(i-obj-code) NO-LOCK .
find   FIRST ub.clients WHERE
          ub.clients.obj-type = 'маг':U AND
          ub.clients.obj-code = ub.shop.obj-code  no-error .
if available ub.clients then
assign
for-shop-name = ub.clients.obj-name.
else for-shop-name = 'маг':U + string(ub.shop.obj-code).
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  abs(i-obj-code)
    ,input  'cd-sending':U
    ,input  'alllstcs':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then alllstcs = v-value-logical.
delete object v-tth.
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  abs(i-obj-code)
    ,input  'cd-sending':U
    ,input  'noautocs':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then noautocs = v-value-logical.
delete object v-tth.
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  abs(i-obj-code)
    ,input  'cd-sending':U
    ,input  'mask_s-c':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then mask_s-c = v-value-character.
else mask_s-c = "".
delete object v-tth.
if noautocs
then do:
    message "Пошлите товары на кассы объекта МАГАЗИН "
    if i-obj-code > 0
    then i-obj-code
    else (- i-obj-code)
    view-as alert-box WARNING.
    return.
end.
  if (    ub.shop.cd-bc-alt
        or ub.shop.cd-bc-base
        or ub.shop.cd-loc-alt
        or ub.shop.cd-loc-base
        or ub.shop.cd-parts-all
        or ub.shop.cd-parts-not-blank
        or ub.shop.cd-parts-ser
        or ub.shop.cd-pb-alt
        or ub.shop.cd-pb-base
        or ub.shop.cd-sc-base   ) = no then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Не выбраны типы кодов для пересылки на кассы &1&2", 'маг':U, abs(i-obj-code))
                                            ).
    run finish-send in this-procedure no-error .
    return.
  end.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пересылка на кассы &1&2 информации о товарах", 'маг':U, abs(i-obj-code))
                                          ).
  if Not g#news and i-obj-code > 0 then callpoint = "R":U.
  if g#news then callpoint = "N":U.
if i-obj-code < 0 then i-obj-code = - i-obj-code.
FIND ub.sysconf WHERE ub.sysconf.host-code = ub.shop.host-code NO-LOCK.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-curr in g#library
  (input  ub.shop.host-code
  ,output v-r-b-curr-magia
  )  .
find first buf_currency no-lock where
           buf_currency.curr-code = v-r-b-curr-magia no-error .
if not available buf_currency or
buf_currency.okv-code = 0 then do:
  message
  "Не задан код ОКВ для валюты с кодом" buf_currency.curr-code
  view-as alert-box error .
  return error .
end.
assign
v-r-b-curr-magia = (if buf_currency.curr-code = 0 then 1 else buf_Currency.okv-code)
v-is-restaurant = ub.shop.is-catering
.
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type58 as character no-undo .
define variable v-value-date58 as date no-undo .
define variable v-value-decimal58 as decimal no-undo .
define variable v-value-integer58 as INTEGER no-undo .
define variable v-value-logical58 AS LOGICAL no-undo .
define variable v-tth58 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  abs(i-obj-code)
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date58
    ,output v-value-decimal58
    ,output v-value-integer58
    ,output v-value-logical58
    ,output v-param-type58
    ,INPUT-OUTPUT table-handle v-tth58
    ) no-error .
delete object v-tth58 no-error.
IF error-status:error then do:
  assign
  dflt-cd = ''.
end.
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  i-obj-code
    ,input  'cd-inf-send':U
    ,input  '':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error then return error .
for each thbjattr_thbj-attr where
        thbjattr_thbj-attr.obj-type = 'маг':U
    and thbjattr_thbj-attr.obj-code = i-obj-code
    and thbjattr_thbj-attr.upper-prop-code = 'cd-inf-send':U
on error undo, return error :
  case thbjattr_thbj-attr.prop-code:
    when 'nam-artc':U then do:
      nam-artc = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'cod-pcod':U then do:
      cod-pcod = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'tax-cass':U then do:
      tax-cass = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'nam-2str':U then do:
      nam-2str = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'name-2cd':U then do:
      name-2cd = thbjattr_thbj-attr.property-value-character.
    end.
    when 'amntdisc':U then do:
      amntdisc = thbjattr_thbj-attr.property-value-integer.
    end.
    when 'how-temp-disc':U then do:
      how-temp-disc = thbjattr_thbj-attr.property-value-character.
      if how-temp-disc = 'temp-disc-pdf':U then do:
        run get-thbj-rule in this-procedure ( input 'маг':U
                                             ,input i-obj-code
                                             ,input ub.shop.host-code
                                             ,input 'temp-disc-pdf':U
                                             ,input dflt-cd
                                             ,input "1,2,3"
                                             ,buffer buf_dis-thbj-rule
                                             ) no-error.
        if available buf_dis-thbj-rule then do:
          temp-discnt-rule_pdf = buf_dis-thbj-rule.rule-num.
        end.
      end.
      else do:
        temp-discnt-rule_pdf = 0.
      end.
    end.
    when 'how-pcnt-kat':U then do:
      how-pcnt-kat = thbjattr_thbj-attr.property-value-character.
      if how-pcnt-kat = 'pcnt-kat-pdf':U then do:
        run get-thbj-rule in this-procedure ( input 'маг':U
                                             ,input i-obj-code
                                             ,input ub.shop.host-code
                                             ,input 'pcnt-kat-pdf':U
                                             ,input dflt-cd
                                             ,input "1,2,3"
                                             ,buffer buf_dis-thbj-rule
                                             ) no-error.
        if available buf_dis-thbj-rule then do:
          kat-discnt-rule_pdf = buf_dis-thbj-rule.rule-num.
        end.
      end.
      else do:
        kat-discnt-rule_pdf = 0.
      end.
    end.
  end case.
end.
 run fill-temp-cd in this-procedure ( input g#db-num, input 'маг':U, input i-obj-code, input yes).
 if can-find(first temp-cd where
                  temp-cd.obj-code = i-obj-code
             AND  (temp-cd.pos-type = 'IBM-XML':U
                  or
                  temp-cd.pos-type = 'Autotank':U
                  )
             AND  temp-cd.db-num = g#db-num
             ) then do:
  if index(name-2cd,"GTD":U) = 0 then
  assign
  name-2cd = name-2cd + "-":U + "GTD":U.
end.
run adm/shattri.p (
  input "get":U
  ,input 'маг':U
  ,input ub.shop.obj-code
  ,input  'cd-type-ipc-servispl':U
  ,input  'ipcscpfx':U
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output v-param-type
  ,INPUT-OUTPUT table-handle v-tth
  ) no-error .
IF not error-status:error then
ipcsc-pfx = v-value-integer.
error-status:error = no.
run finish-send in this-procedure no-error .
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ibm-gdsc :
define input  parameter p-zeros         as logical no-undo .
define output parameter IBM-good-code as character no-undo .
define output parameter IBM-good-code-2 as character no-undo .
define output parameter IBM2-short      as character no-undo .
define variable v-delim as character no-undo .
define variable v-format-str-16 as character no-undo .
  do
  on error undo, return error
  :
    if p-zeros then do:
      assign
      v-delim = '0'
      v-format-str-16 =  "9999999999999999"
      .
    end.
    else do:
      assign
      v-delim = chr(32)
      v-format-str-16 =  ">>>>>>>>>>>>>>>9"
      .
    end.
    if cash-gds.b-str = "" then do:
      assign
      b_code = string( cash-gds.b-code, v-format-str-16 ) .
      if  LOOKUP( 'вес':U, cash-gds.unit-type ) = 0
      or cash-gds.unit-base <> cash-gds.unit-cli
      or (LOOKUP( 'вес':U, cash-gds.unit-type ) > 0  and not ub.shop.cd-sc-base)
      then
      do:
        if ((ub.shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
            (ub.shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
          RUN gen-bc( input cash-gds.b-code, output bar_code ).
          iBM2-short = bar_code.
          IBM-good-code  = string( fill( v-delim, 16 - length( trim( bar_code ) ) ) + trim( bar_code ), "9999999999999999" ) .
        END.
        if ((ub.shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
            (ub.shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
          IBM-good-code-2 = b_code.
        end.
      end.
    end.
    else do:
      IBm-good-code =
      ( if ( cash-gds.unit-cli = cash-gds.unit-base ) AND
        (LOOKUP( 'вес':U, cash-gds.unit-type ) > 0
         or
         cash-gds.bc-on-type = 'pglc':U)
      then string( decimal( cash-gds.b-str ), v-format-str-16)
      else string( fill( v-delim, 16 - length( trim( cash-gds.b-str ) ) ) + trim( cash-gds.b-str ), "9999999999999999" ) ).
    end.
  end.
end procedure.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ncr-gdsc :
define output parameter IBM-good-code as character no-undo .
define output parameter IBM-good-code-2 as character no-undo .
define output parameter is-sc as logical no-undo .
define output parameter p-taracode-bc as character no-undo .
define variable v-taracode-bc as character no-undo .
define variable v-type as character no-undo .
define variable v-bc-buf as character no-undo .
define variable iii as integer no-undo .
  do
  on error undo, return error
  :
    if cash-gds.b-str = "" then do:
      assign
      b_code = string(cash-gds.b-code,'>>>>>>>>>>>>9').
      if  LOOKUP( 'вес':U, cash-gds.unit-type ) = 0 or cash-gds.unit-base <> cash-gds.unit-cli then do:
        if ((ub.shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
            (ub.shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
          RUN gen-bc( input cash-gds.b-code, output bar_code ).
          IBM-good-code  = fill( " ", 13 - length( trim( bar_code ) ) ) + trim( bar_code ).
        end.
        if ((ub.shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
            (ub.shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
          IBM-good-code-2 = b_code.
        end.
      end.
    end.
    else do:
      if cash-gds.b-str begins "*" then cash-gds.b-str = left-trim(cash-gds.b-str, "*").
      IBm-good-code = ( if ( cash-gds.unit-cli = cash-gds.unit-base ) AND
                          (LOOKUP( 'вес':U, cash-gds.unit-type ) > 0
                           or
                           cash-gds.bc-on-type = 'pglc':U)
                        then string( integer( cash-gds.b-str ), ">>>>>>>>>>>>9" )
                        else string( fill( " ", 13 - length( trim( cash-gds.b-str ) ) ) +
                                    trim( cash-gds.b-str ), "9999999999999" ) ).
       if action <> "D":U then do:
        is-sc = no.
        find first request_prod-bc no-lock where
                  request_prod-bc.b-str = cash-gds.b-str no-error .
        if not avail request_prod-bc then do :
          if mask_s-c <> "" then do :
            iii_ :
            do iii = 1 to num-entries(mask_s-c) :
              if length(cash-gds.b-str) = (num-entries(entry(iii, mask_s-c), '*') - 1) then do :
                v-bc-buf = trim(entry(1, entry(iii, mask_s-c), '*') + cash-gds.b-str).
                find first request_prod-bc no-lock where request_prod-bc.b-str = v-bc-buf no-error .
                if available request_prod-bc then leave iii_ .
              end.
            end.
          end.
        end.
        if avail request_prod-bc then do :
          if LOOKUP( 'вес':U, cash-gds.unit-type ) > 0 then do:
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer request_prod-bc
  ,input  'scaleable=request'
  ,output is-sc
  ) no-error .
          end.
          if ( cash-gds.unit-cli = cash-gds.unit-base ) AND
             LOOKUP( 'вес':U, cash-gds.unit-type ) > 0
             then do:
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str62  as character no-undo.
  define variable tmp-num62  as character no-undo.
  define variable i62        as integer   no-undo.
  define variable sum62      as integer   no-undo.
  define variable len-code62 as integer   no-undo.
  define variable varcont62  as logical   initial yes no-undo.
  CASE ncrsc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str62 = string( decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U), "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str62 = string( decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U), "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " ncrsc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont62 = yes then do:
    if integer( substring( tmp-str62, 1, length( ncrsc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U)
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        IBm-good-code = ncrsc-pfx + substring( tmp-str62, length( ncrsc-pfx ) + 1, length( tmp-str62 ) - length( ncrsc-pfx ) )
        len-code62    = length( IBm-good-code )
      .
      define variable v-sum-char62 as character no-undo .
      assign
        sum62 = 0
      .
      do i62 = 1 to len-code62 by 2
      :
        assign
          v-sum-char62 = substr(IBm-good-code, len-code62 - i62 + 1, 1)
        .
        if v-sum-char62 < "0"
        or v-sum-char62 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U) skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum62 = sum62 + integer(v-sum-char62)
        .
      end.
      if varcont62 = yes then do:
        assign
          sum62 = sum62 * 3
        .
        do i62 = 2 to len-code62 by 2
        :
          assign
            v-sum-char62 = substr(IBm-good-code, len-code62 - i62 + 1, 1)
          .
          if v-sum-char62 < "0"
          or v-sum-char62 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U) skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum62 = sum62 + integer(v-sum-char62)
          .
        end.
        if varcont62 = yes then do:
           if sum62 mod 10 = 0 then do:
             assign
               IBm-good-code = IBm-good-code + '0'
             .
           end.
           else do:
             assign
               IBm-good-code = IBm-good-code + string(10 - sum62 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
          end.
          if ( cash-gds.unit-cli = cash-gds.unit-base ) AND
             cash-gds.bc-on-type = 'pglc':U
             then do:
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str63  as character no-undo.
  define variable tmp-num63  as character no-undo.
  define variable i63        as integer   no-undo.
  define variable sum63      as integer   no-undo.
  define variable len-code63 as integer   no-undo.
  define variable varcont63  as logical   initial yes no-undo.
  CASE ncrpg-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str63 = string( decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U), "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str63 = string( decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U), "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " ncrpg-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont63 = yes then do:
    if integer( substring( tmp-str63, 1, length( ncrpg-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U)
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        IBm-good-code = ncrpg-pfx + substring( tmp-str63, length( ncrpg-pfx ) + 1, length( tmp-str63 ) - length( ncrpg-pfx ) )
        len-code63    = length( IBm-good-code )
      .
      define variable v-sum-char63 as character no-undo .
      assign
        sum63 = 0
      .
      do i63 = 1 to len-code63 by 2
      :
        assign
          v-sum-char63 = substr(IBm-good-code, len-code63 - i63 + 1, 1)
        .
        if v-sum-char63 < "0"
        or v-sum-char63 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U) skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum63 = sum63 + integer(v-sum-char63)
        .
      end.
      if varcont63 = yes then do:
        assign
          sum63 = sum63 * 3
        .
        do i63 = 2 to len-code63 by 2
        :
          assign
            v-sum-char63 = substr(IBm-good-code, len-code63 - i63 + 1, 1)
          .
          if v-sum-char63 < "0"
          or v-sum-char63 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U) skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum63 = sum63 + integer(v-sum-char63)
          .
        end.
        if varcont63 = yes then do:
           if sum63 mod 10 = 0 then do:
             assign
               IBm-good-code = IBm-good-code + '0'
             .
           end.
           else do:
             assign
               IBm-good-code = IBm-good-code + string(10 - sum63 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
          end.
        end.
      end.
    end.
    if LOOKUP( 'вес':U, cash-gds.unit-type ) > 0
    and (LOOKUP( 'дро':U, cash-gds.unit-cli-type ) > 0
          or
          LOOKUP( 'вес':U, cash-gds.unit-cli-type ) > 0)
    then do:
        run bc-oattr_value in this-procedure ( input cash-gds.b-code
                                            ,input 'taracode-bc':U
                                            ,input 'маг':U
                                            ,input i-obj-code
                                            ,output v-taracode-bc
                                            ,output v-type) no-error.
        if not error-status:error
        and v-taracode-bc <> '' then do:
          is-sc = yes.
          p-taracode-bc = v-taracode-bc.
        end.
    end.
  end.
end procedure.
procedure finish-send :
  do
  on error undo, return error
  :
    if p-batch then do:
      if v-view-log then
      run set-view-log in p-log-handle(yes).
    end.
    else do:
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При отсылке информации на кассы произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action65   as character no-undo .
  define variable v-printed65       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При отсылке информации на кассы произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + log-file-name)
    ,input  7
    ,output v-user-action65
    ,output v-printed65
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
    end.
    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
    OS-APPEND value(log-file-name) value(v-save-file-name).
    OS-DELETE value(log-file-name).
  end.
end procedure.
procedure get-prt-and-unit :
define input parameter par-prt-root like ub.goods.prt-root no-undo .
define input parameter par-unit-base like ub.goods.unit-base no-undo .
define output parameter par-empty-scale as logical no-undo .
  do
  on error undo, return error
  :
    FIND FIRST ub.gds-prt where
               ub.gds-prt.upper-code = par-prt-root NO-LOCK .
    assign
    par-empty-scale = NOT (ub.shop.doc-prt AND ( ub.gds-prt.node-name <> '_Пустая шкала':U))
    .
    FIND FIRST ub.units WHERE
               ub.units.unit-name = par-unit-base NO-LOCK .
  end.
end procedure.
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure create-ncr-kat-discnt :
define input parameter p-subject-code as character no-undo .
define input parameter p-cd-subject-code as character no-undo .
define input parameter p-subject-name as character no-undo .
define input parameter p-dis-rule-num like ub.dis-rule.rule-num no-undo .
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define input parameter p-tree as character no-undo .
define input parameter p-discnt as decimal no-undo .
define variable v-dis-rule-num as integer no-undo .
define variable v-tree as logical no-undo init yes.
define variable v-discnt as decimal no-undo .
define variable v-dis-kat as integer   no-undo .
define buffer buf_cash-dis-rule for cash-dis-rule.
define buffer buf_cash-dis-time-rule for cash-dis-time-rule.
define buffer slave_cash-dis-rule for cash-dis-rule.
  do
  on error undo, return error
  :
    v-discnt = p-discnt.
    if p-dis-rule-num > 0 then do:
      find first buf_cash-dis-rule no-lock where
                buf_cash-dis-rule.rule-num = p-dis-rule-num no-error.
      if not available buf_cash-dis-rule
      or (buf_cash-dis-rule.templ-rl-root <> p-templ-rl-root
         and
         p-templ-rl-root <> ?)
      then do:
        return error .
      end.
      if p-templ-rl-root = ? then do:
        p-templ-rl-root = buf_cash-dis-rule.templ-rl-root.
      end.
      if buf_cash-dis-rule.uniq-field = ''
      or buf_cash-dis-rule.is-term
      then do:
        v-tree = no.
        v-dis-rule-num = buf_cash-dis-rule.upper-rule-num.
      end.
      if buf_cash-dis-rule.time-rule-num > 0 then do:
        find first buf_cash-dis-time-rule no-lock where
                buf_cash-dis-time-rule.time-rule-num = buf_cash-dis-rule.time-rule-num no-error.
        if not available buf_cash-dis-time-rule then do:
          return error .
        end.
        release buf_cash-dis-time-rule.
      end.
        _buf-cash-dis-rule:
        for each buf_cash-dis-rule no-lock where
                buf_cash-dis-rule.upper-rule-num = (if v-tree then p-dis-rule-num else v-dis-rule-num):
          if not v-tree then do:
            find first slave_cash-dis-rule no-lock where
                slave_cash-dis-rule.rule-num = v-dis-rule-num .
            assign v-dis-kat = slave_cash-dis-rule.dis-kat .
            if buf_cash-dis-rule.rule-num <> p-dis-rule-num then next _buf-cash-dis-rule.
          end.
          else
           do:
             assign v-dis-kat = buf_cash-dis-rule.dis-kat .
           end .
          if buf_cash-dis-rule.time-rule-num > 0 then do:
            find first buf_cash-dis-time-rule no-lock where
                      buf_cash-dis-time-rule.time-rule-num = buf_cash-dis-rule.time-rule-num no-error.
            if not available buf_cash-dis-time-rule then next _buf-cash-dis-rule.
          end.
          FIND FIRST cash-ncr-dis-kat where
                  cash-ncr-dis-kat.crf = (cr-ncr-dis-kat + 1) No-ERROR.
          if not avail cash-ncr-dis-kat then do:
            create cash-ncr-dis-kat.
            error-status:error = false.
          end.
          cash-ncr-dis-kat.crf = cr-ncr-dis-kat + 1.
          cr-ncr-dis-kat = cr-ncr-dis-kat + 1.
          if buf_cash-dis-rule.value-type = integer('12':U) then do:
            find first cash-gds-discnt where
                      cash-gds-discnt.b-code = integer(p-subject-code)
                  and  cash-gds-discnt.rule-num = buf_cash-dis-rule.rule-num
                  and cash-gds-discnt.obj-type = 'маг':U
                  and cash-gds-discnt.obj-code = i-obj-code
                  no-error.
            if available cash-gds-discnt then do:
              assign
              v-discnt = cash-gds-discnt.discnt-value
              .
            end.
            else do:
              v-discnt = p-discnt.
            end.
          end.
          assign
          cash-ncr-dis-kat.subject-code  =  p-subject-code
          cash-ncr-dis-kat.cd-subject-code  =  p-cd-subject-code
          cash-ncr-dis-kat.cd-subject-name  =  SUBSTRING(p-subject-name, 1, 20)
          cash-ncr-dis-kat.cd-subject-name  =  SUBSTRING(p-subject-name, 1, 20) +
                                             ( if length(p-subject-name) < 20 then fill( chr(32) , 20 - length(p-subject-name) ) else '' )
          cash-ncr-dis-kat.dis-kat =  (if v-dis-kat < 0 then 0 else v-dis-kat)
          cash-ncr-dis-kat.rule-num = buf_cash-dis-rule.rule-num
          cash-ncr-dis-kat.time-rule-num = buf_cash-dis-rule.time-rule-num
          cash-ncr-dis-kat.cd-disc-string   = "****":U  +
                                          (if buf_cash-dis-rule.templ-rl-root = 89
                                           then '80'
                                           else (if buf_cash-dis-rule.discnt-value > 0
                                                 then '80':U
                                                 else '00':U)
                                           )
          .
          if p-tree = 'time-rule-num':U then do:
            if available buf_cash-dis-time-rule
            and buf_cash-dis-time-rule.value-type <> '0':U
            then do:
              assign
              cash-ncr-dis-kat.cd-disc-string = cash-ncr-dis-kat.cd-disc-string +
                                            (if buf_cash-dis-time-rule.value-type = '2':U
                                              then
                                              ("D":U + substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 9, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 4, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 1, 2) +
                                                      "-":U +
                                                      substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 9, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 4, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 1, 2)
                                              )
                                              else
                                              ("T00":U +
                                                        (if buf_cash-dis-time-rule.week-day-0  then "0" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-1  then "2" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-2  then "3" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-3  then "4" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-4  then "5" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-5  then "6" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-6  then "7" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-7  then "1" else "":U) +
                                                      chr(47) +
                                                      replace(string(buf_cash-dis-time-rule.time-from, "HH:MM"), ':':U, '':U) + "-":U +
                                                      replace(string(buf_cash-dis-time-rule.time-to, "HH:MM"), ':':U, '':U)
                                              )
                                            )
              .
            end.
            else do:
              assign
              cash-ncr-dis-kat.cd-disc-string = cash-ncr-dis-kat.cd-disc-string + "D000101-991231":U
              .
            end.
          end.
          if p-tree = 'tot-sum':U then do:
            assign
            cash-ncr-dis-kat.cd-disc-string = cash-ncr-dis-kat.cd-disc-string +
            '>' + replace(string(round(buf_cash-dis-rule.tot-sum, 2), '99999999999.99'), '.':u , '':U)
            .
          end.
          assign
          cash-ncr-dis-kat.cd-other =   fill(chr(32), 10) +  "xx ":U +
                                        (if buf_cash-dis-rule.value-type = integer('12':U)
                                         or buf_cash-dis-rule.value-type = integer('3':U)
                                        then "=":U
                                        else "%":U) +
                                        replace(string(abs(if v-discnt <> ? then v-discnt else buf_cash-dis-rule.discnt-value),"9999999.9"), '.':U, '':U)
          .
        end.
    end.
    else do:
      FIND FIRST cash-ncr-dis-kat where
              cash-ncr-dis-kat.crf = (cr-ncr-dis-kat + 1) No-ERROR.
      if not avail cash-ncr-dis-kat then do:
      create cash-ncr-dis-kat.
      error-status:error = false.
      end.
      cash-ncr-dis-kat.crf = cr-ncr-dis-kat + 1.
      cr-ncr-dis-kat = cr-ncr-dis-kat + 1.
      assign
      cash-ncr-dis-kat.subject-code  = p-subject-code
      cash-ncr-dis-kat.cd-subject-code  = p-cd-subject-code
      cash-ncr-dis-kat.cd-subject-name  = p-subject-name
      cash-ncr-dis-kat.dis-kat =  - 1
      cash-ncr-dis-kat.rule-num = 0
      cash-ncr-dis-kat.time-rule-num = 0
      .
    end.
  end.
end procedure.
procedure output-ncr-bonus:
define input parameter i-host-code as integer no-undo .
define input parameter i-obj-code  as integer no-undo .
define input parameter out         as character no-undo .
define output parameter fname      as character no-undo .
def var v-found as log no-undo .
def var v-upd   as char no-undo .
def var v-ver   as char no-undo .
def var v-char-delim-1  as char initial ',' no-undo .
def var v-char-delim-2  as char initial ';' no-undo .
def var v-char-1        as char no-undo .
def var v-char-2        as char no-undo .
def var v-char-21       as char no-undo .
def var v-char-3        as char no-undo .
def var v-char-4        as char no-undo .
def var v-char-41       as char no-undo .
def var v-char-42       as char no-undo .
def var v-char-5        as char no-undo .
def var v-char-6        as char no-undo .
def var v-char-61       as char no-undo .
def var v-char-62       as char no-undo .
def var v-char-8        as char no-undo .
def var v-char-9        as char no-undo .
def var v-char-7        as char no-undo .
def var v-char-71       as char no-undo .
def var v-char-72       as char no-undo .
def var v-cassa         as char no-undo .
def var v-is-weight     as log  no-undo init false .
def var v-ean13         as char no-undo .
def var v-tmpchar       as char no-undo .
def var v-today         as date no-undo .
def buffer buf_dis-gds-rule-attr for ub.dis-gds-rule-attr.
def buffer buf_dis-gds-rule      for ub.dis-gds-rule .
def buffer chk_dis-gds-rule      for ub.dis-gds-rule .
def buffer buf_dis-thbj-rule     for ub.dis-thbj-rule .
def buffer buf_dis-rule          for ub.dis-rule .
def buffer buf_dis-time-rule     for ub.dis-time-rule .
def buffer buf_prod-bc           for ub.prod-bc .
def buffer buf_bar-code          for ub.bar-code .
def buffer buf_units             for ub.units .
def buffer buf_goods             for ub.goods .
def buffer buf_gds-obj           for ub.gds-obj .
assign
    fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 ).
assign
 v-ver = "2.02.00"
 v-char-1 = "0,0,0,,,,,0,1,0,0,1,;,0,0,1,0,0,"
 v-char-2 = "0,0,0,0,0,0,"
 v-char-21 = "0,0,0,"
 v-char-3 = "0,0,0,"
 v-char-4 =
 ",;,,;,;,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,0,0,6,0,0,"
 v-char-41 =
 ",,,,,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,0,0,6,0,0,"
 v-char-42 =
 ",,,,,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,1,0,21,0,0,"
 v-char-5 =
 "0,0,1,1,0,4,1,"
 v-char-6 =
 ",;,;,;,;,;,0;+                                       ;"
 v-char-61 =
 ",;,;,;,;,;,1;+                                       ;"
 v-char-62 =
 ",;,;,;,;,;,1;Message                                 ;"
 v-char-7 =
 "006;00;000;               ;          ;,0,0"
 v-char-71 =
 "006;04;000;               ;          ;,0,0"
 v-char-72 =
 "021;00;000;               ;          ;Выдать марок$FinalPointsBalance$ шт.,0,0,4,0,1,0,1,0,22,0,0,0,0,0,1,1,0,4,1,"
 v-char-8 =
 ";,;,;,;,;,;,1;" + fill(" ",40) + ";022;06;000;"
 v-char-9 =
 "               ;          ;________________________MAPOK=$FinalPointsBalance$,0,0"
.
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  'маг':U
  ,input  i-obj-code
  ,output v-today
  )  .
 output stream IBMStream to value(out + fname + ".dat") convert target "utf-8"  .
 _buf_dis-gds-rule:
 for each buf_dis-gds-rule no-lock
 where buf_dis-gds-rule.templ-rl-root = 91
   and buf_dis-gds-rule.pos-type = 'NCR-AS@R':U
   ,
   first buf_dis-rule no-lock
   where buf_dis-rule.rule-num = buf_dis-gds-rule.rule-num
     and buf_dis-rule.sts = integer('0':U),
    first buf_dis-time-rule no-lock
      where buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num
    and buf_dis-time-rule.date-to >= v-today
      :
       if buf_dis-gds-rule.obj-type = "" and buf_dis-gds-rule.obj-code = 0 then do:
           find first chk_dis-gds-rule no-lock
           where chk_dis-gds-rule.gds-code = buf_dis-gds-rule.gds-code and
                 chk_dis-gds-rule.templ-rl-root = buf_dis-gds-rule.templ-rl-root and
                 chk_dis-gds-rule.pos-type = buf_dis-gds-rule.pos-type and
              (( chk_dis-gds-rule.obj-type = 'орг':U  and chk_dis-gds-rule.obj-code = i-host-code ) or
               ( chk_dis-gds-rule.obj-type = 'маг':U and chk_dis-gds-rule.obj-code = i-obj-code  )) no-error .
           if avail chk_dis-gds-rule then next _buf_dis-gds-rule .
       end.
       if buf_dis-gds-rule.obj-type = 'орг':U and buf_dis-gds-rule.obj-code = i-host-code then do:
           find first chk_dis-gds-rule no-lock
           where chk_dis-gds-rule.gds-code = buf_dis-gds-rule.gds-code and
                 chk_dis-gds-rule.templ-rl-root = buf_dis-gds-rule.templ-rl-root and
                 chk_dis-gds-rule.pos-type = buf_dis-gds-rule.pos-type and
                 chk_dis-gds-rule.obj-type = 'маг':U and
                 chk_dis-gds-rule.obj-code = i-obj-code no-error .
           if avail chk_dis-gds-rule then next _buf_dis-gds-rule .
       end.
       find first buf_gds-obj no-lock
       where buf_gds-obj.gds-code = buf_dis-gds-rule.gds-code
         and buf_gds-obj.obj-type = 'маг':U
         and buf_gds-obj.obj-code = i-obj-code
       no-error.
       if avail buf_gds-obj and
         (( buf_dis-gds-rule.obj-type = ""      and buf_dis-gds-rule.obj-code = 0) or
          ( buf_dis-gds-rule.obj-type = 'орг':U  and buf_dis-gds-rule.obj-code = i-host-code) or
          ( buf_dis-gds-rule.obj-type = 'маг':U and buf_dis-gds-rule.obj-code = i-obj-code))
       then do:
          assign
            v-char-2 = "0,0,0,0,0,0,"
            v-is-weight = false
          .
          find buf_goods where buf_goods.gds-code = buf_dis-gds-rule.gds-code no-lock no-error.
          if avail buf_goods then do:
              find buf_units where buf_units.unit-name = buf_goods.unit-base no-lock no-error.
              if avail buf_units then do:
                  if lookup ('вес':U, buf_units.type) > 0 then do:
                      assign
                        v-char-2    = "0,0,0,2,0,0,"
                        v-is-weight = true
                      .
                  end.
              end.
          end.
          _bdr-attr:
    for each  buf_dis-gds-rule-attr WHERE
             buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
         AND buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
         AND buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
         AND buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
         AND buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
         and buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
                  :
           assign
     v-upd = entry(2,buf_dis-gds-rule-attr.attr-value,",")
             v-ean13 = entry(1,buf_dis-gds-rule-attr.attr-value,",")
     .
           if v-is-weight and length(v-ean13) = 5 then do:
               def var ncrsc-pfx as char no-undo init "23":U .
               def var ncrsc-frmt as char no-undo init "EAN13" .
               assign v-tmpchar = "" .
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str68  as character no-undo.
  define variable tmp-num68  as character no-undo.
  define variable i68        as integer   no-undo.
  define variable sum68      as integer   no-undo.
  define variable len-code68 as integer   no-undo.
  define variable varcont68  as logical   initial yes no-undo.
  CASE ncrsc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str68 = string( decimal(string(integer( v-ean13 ), '99999':U) + '00000':U), "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str68 = string( decimal(string(integer( v-ean13 ), '99999':U) + '00000':U), "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " ncrsc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont68 = yes then do:
    if integer( substring( tmp-str68, 1, length( ncrsc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " decimal(string(integer( v-ean13 ), '99999':U) + '00000':U)
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        v-tmpchar = ncrsc-pfx + substring( tmp-str68, length( ncrsc-pfx ) + 1, length( tmp-str68 ) - length( ncrsc-pfx ) )
        len-code68    = length( v-tmpchar )
      .
      define variable v-sum-char68 as character no-undo .
      assign
        sum68 = 0
      .
      do i68 = 1 to len-code68 by 2
      :
        assign
          v-sum-char68 = substr(v-tmpchar, len-code68 - i68 + 1, 1)
        .
        if v-sum-char68 < "0"
        or v-sum-char68 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " decimal(string(integer( v-ean13 ), '99999':U) + '00000':U) skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum68 = sum68 + integer(v-sum-char68)
        .
      end.
      if varcont68 = yes then do:
        assign
          sum68 = sum68 * 3
        .
        do i68 = 2 to len-code68 by 2
        :
          assign
            v-sum-char68 = substr(v-tmpchar, len-code68 - i68 + 1, 1)
          .
          if v-sum-char68 < "0"
          or v-sum-char68 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " decimal(string(integer( v-ean13 ), '99999':U) + '00000':U) skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum68 = sum68 + integer(v-sum-char68)
          .
        end.
        if varcont68 = yes then do:
           if sum68 mod 10 = 0 then do:
             assign
               v-tmpchar = v-tmpchar + '0'
             .
           end.
           else do:
             assign
               v-tmpchar = v-tmpchar + string(10 - sum68 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
               if not v-tmpchar = "":U then assign v-ean13 = v-tmpchar .
           end.
           if v-ean13 begins "20" and length(v-ean13) = 13 then next _bdr-attr .
     put stream IBMStream unformatted v-ver v-char-delim-1 v-upd v-char-delim-1
      buf_dis-gds-rule-attr.attr-code v-char-delim-1
      "3,MAPKA,"
      entry(1,iso-date(buf_dis-time-rule.date-from),"-") + entry(2,iso-date(buf_dis-time-rule.date-from),"-") + entry(3,iso-date(buf_dis-time-rule.date-from),"-") v-char-delim-1
      "0" v-char-delim-1
      entry(1,iso-date(buf_dis-time-rule.date-to),"-") + entry(2,iso-date(buf_dis-time-rule.date-to),"-") + entry(3,iso-date(buf_dis-time-rule.date-to),"-") v-char-delim-1
      "0" v-char-delim-1
      v-char-1
      v-char-2
      trim(string(buf_dis-rule.doc-qnty,'>>>>9')) v-char-delim-1
      v-char-3
            v-ean13 v-char-delim-2
      v-char-4
      trim(string(buf_dis-rule.discnt-value,">>>9")) v-char-delim-1
      v-char-5
            v-ean13 v-char-delim-2
      v-char-6 v-char-7 skip.
    end.
   end.
 end.
 for each buf_dis-thbj-rule no-lock where buf_dis-thbj-rule.templ-rl-root = 90
                   and buf_dis-thbj-rule.pos-type = 'NCR-AS@R':U,
    first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = buf_dis-thbj-rule.rule-num
    and buf_dis-rule.sts = integer('0':U),
    first buf_dis-time-rule no-lock
      where buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num
        and buf_dis-time-rule.date-to >= v-today
      :
   if (buf_dis-thbj-rule.obj-type = "" and
       buf_dis-thbj-rule.obj-code = 0) or
      (buf_dis-thbj-rule.obj-type = 'орг':U and
       buf_dis-thbj-rule.obj-code = i-host-code) or
      (buf_dis-thbj-rule.obj-type = 'маг':U and
       buf_dis-thbj-rule.obj-code = i-obj-code)
   then
   do:
     put stream IBMStream unformatted v-ver v-char-delim-1 v-upd v-char-delim-1
      buf_dis-rule.key#_one v-char-delim-1
      "3,MAPKA,"
      entry(1,iso-date(buf_dis-time-rule.date-from),"-") + entry(2,iso-date(buf_dis-time-rule.date-from),"-") + entry(3,iso-date(buf_dis-time-rule.date-from),"-") v-char-delim-1
      "0" v-char-delim-1
      entry(1,iso-date(buf_dis-time-rule.date-to),"-") + entry(2,iso-date(buf_dis-time-rule.date-to),"-") + entry(3,iso-date(buf_dis-time-rule.date-to),"-") v-char-delim-1
      "0" v-char-delim-1
      v-char-1
      v-char-21
      "9,0,0,"
      trim(string(buf_dis-rule.tot-sum * 100,">>>>>>>>>9")) v-char-delim-1
      v-char-3
      v-char-41
      trim(string(buf_dis-rule.discnt-value,">>>9")) v-char-delim-1
      v-char-5
       v-char-delim-2
      v-char-61 v-char-71 skip.
   end.
 end.
 for each buf_dis-thbj-rule no-lock where buf_dis-thbj-rule.templ-rl-root = 92
                   and buf_dis-thbj-rule.pos-type = 'NCR-AS@R':U,
    first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = buf_dis-thbj-rule.rule-num
    and buf_dis-rule.sts = integer('0':U),
    first buf_dis-time-rule no-lock
      where buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num
        and buf_dis-time-rule.date-to >= v-today
      :
   if (buf_dis-thbj-rule.obj-type = "" and
       buf_dis-thbj-rule.obj-code = 0) or
      (buf_dis-thbj-rule.obj-type = 'орг':U and
       buf_dis-thbj-rule.obj-code = i-host-code) or
      (buf_dis-thbj-rule.obj-type = 'маг':U and
       buf_dis-thbj-rule.obj-code = i-obj-code)
   then
   do:
     put stream IBMStream unformatted v-ver v-char-delim-1 v-upd v-char-delim-1
      buf_dis-rule.key#_one v-char-delim-1
      "4,MAPKA,"
      entry(1,iso-date(buf_dis-time-rule.date-from),"-") + entry(2,iso-date(buf_dis-time-rule.date-from),"-") + entry(3,iso-date(buf_dis-time-rule.date-from),"-") v-char-delim-1
      "0" v-char-delim-1
      entry(1,iso-date(buf_dis-time-rule.date-to),"-") + entry(2,iso-date(buf_dis-time-rule.date-to),"-") + entry(3,iso-date(buf_dis-time-rule.date-to),"-") v-char-delim-1
      "0" v-char-delim-1
      v-char-1
      v-char-21
      "4,1,0,"
      "1" v-char-delim-1
      v-char-3
      v-char-42
      "0" v-char-delim-1
      v-char-5
       v-char-delim-2
      v-char-62 v-char-72 v-char-8 v-char-9 skip.
   end.
 end.
 output stream IBMStream close .
end procedure .
procedure get-thbj-rule :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer no-undo .
define input  parameter p-host-code as integer no-undo .
define input  parameter p-discnt-role as character no-undo .
define input  parameter p-pos-type as character   no-undo .
define input  parameter p-reg-list as character no-undo .
define parameter buffer  buf_dis-thbj-rule for ub.dis-thbj-rule.
define variable v-region-type as character no-undo .
define variable v-region-code as integer   no-undo .
define variable v-region-host as integer   no-undo .
define variable v-region-ii as integer   no-undo .
_v-region-ii:
do v-region-ii = 1 to 3:
  if lookup(string(v-region-ii), p-reg-list) = 0 then next _v-region-ii.
  case v-region-ii:
    when 1 then do:
      assign
      v-region-type = p-obj-type
      v-region-code = p-obj-code
      v-region-host = p-host-code
      .
    end.
    when 2 then do:
      assign
      v-region-type = ''
      v-region-code = 0
      v-region-host = p-host-code
      .
    end.
    when 3 then do:
      assign
      v-region-type = ''
      v-region-code = 0
      v-region-host = 0
      .
    end.
  end case.
  find first buf_dis-thbj-rule no-lock where
            buf_dis-thbj-rule.obj-type = v-region-type
        and buf_dis-thbj-rule.obj-code = v-region-code
        and buf_dis-thbj-rule.host-code = v-region-host
        and buf_dis-thbj-rule.discnt-role = p-discnt-role
        and buf_dis-thbj-rule.pos-type = p-pos-type no-error.
  if available buf_dis-thbj-rule then do:
    find first buf_dis-rule no-lock where
              buf_Dis-rule.rule-num = buf_dis-thbj-rule.templ-rl-root no-error.
    if available buf_dis-rule then do:
      run create-dis-rule in this-procedure ( input buf_dis-thbj-rule.rule-num
                                            , (buf_Dis-rule.time-rule-num >= 0)) no-error .
    end.
    leave _v-region-ii.
  end.
end.
END PROCEDURE.
if v-is-err-stat then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3"
                         , p-parameter
                         , chr(10)
                         , v-err-mess1
                         )).
  v-view-log = yes.
  undo, return error .
end .
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table cash-place no-undo
like ub.place.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure putc-pet :
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-version like ub.cash-desk.version no-undo .
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
define input parameter p-cash-num like ub.cash-desk.cash-num  no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable IBM2-short as character no-undo .
DEFINE VARIABLE IBM-good-code-2 as character no-undo .
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf_pump for ub.pump.
define buffer buf_nozzle for ub.nozzle.
define buffer buf_pump-nozzle for ub.pump-nozzle.
define buffer buf_pl-pump for ub.pl-pump.
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
define buffer buf_pl-gds-pump for ub.pl-gds-pump.
  do
  on error undo, return error
  :
    CASE p-pos-type:
      when 'IBM':U then do:
        put stream IbmStream unformatted "41 -1":U skip.
        for each cash-place,
            each buf_pl-gds no-lock where
                buf_pl-gds.obj-type = cash-place.obj-type
            and buf_pl-gds.obj-code = cash-place.obj-code
            and buf_pl-gds.pl-code = cash-place.pl-code
            and buf_pl-gds.status_ <> 'удал':U,
            each cash-gds no-lock where
                 cash-gds.gds-code = buf_pl-gds.gds-code:
          if cash-gds.b-str = '':U then nEXT.
          assign
          IBM-good-code = "":U
          .
          run ibm-gdsc in this-procedure (
                                          input (p-pos-type = 'MARIA':U)
                                        , output IBM-good-code
                                        , output IBM-good-code-2
                                        , output IBM2-short
                                        ) no-error .
          if IBM-good-code = "":U then
          assign
          IBM-good-code = IBM-good-code-2
          .
          put stream IBMStream unformatted
          '41' chr(32)
          chr(34) action chr(34) chr(32)
          cash-place.loc1 chr(32)
          cash-place.pl-code chr(32)
          chr(34)
          cash-place.pl-name
          chr(34) chr(32)
          IBM-good-code chr(32)
          (if buf_pl-gds.status_ = 'тек':U
           then 1
           else 0) chr(32)
          OS2-time
          chr(10)
          .
          v-gds-code = cash-gds.gds-code.
        end.
        v-gds-code = 0.
        for each buf_pl-pump-nozzle no-lock where
                buf_pl-pump-nozzle.obj-type = p-obj-type
            AND buf_pl-pump-nozzle.obj-code = i-obj-code
            and buf_pl-pump-nozzle.status_  <> 'удал':U,
            first cash-place no-lock where
                  cash-place.obj-type = p-obj-type
              and cash-place.obj-code = i-obj-code
              and cash-place.pl-code = buf_pl-pump-nozzle.pl-code:
          find first buf_pl-gds-pump no-lock where
                    buf_pl-gds-pump.obj-type  = p-obj-type
                and buf_pl-gds-pump.obj-code  = i-obj-code
                and buf_pl-gds-pump.pump-code = buf_pl-pump-nozzle.pump-code
                and buf_pl-gds-pump.pl-code  = buf_pl-pump-nozzle.pl-code
                and buf_pl-gds-pump.status_   = 'тек':U  no-error.
          if available buf_pl-gds-pump
          then
          put stream IBMStream unformatted
          '42' chr(32)
          chr(34) action chr(34)  chr(32)
          buf_pl-pump-nozzle.pump-code chr(32)
          buf_pl-pump-nozzle.nozzle-code chr(32)
          cash-place.loc1 chr(32)
          (if available buf_pl-gds-pump and
          buf_pl-gds-pump.status_ = 'тек':U
          then 1
          else 0) chr(32)
          OS2-time
          chr(10)
          .
        end.
        put stream Ibmstream unformatted "41 -2":U skip.
      end.
      when 'IBM-XML':U then do:
        for each cash-place,
            each buf_pl-gds no-lock where
                buf_pl-gds.obj-type = cash-place.obj-type
            and buf_pl-gds.obj-code = cash-place.obj-code
            and buf_pl-gds.pl-code = cash-place.pl-code
            and buf_pl-gds.status_ <> 'удал':U,
            each cash-gds no-lock where
                 cash-gds.gds-code = buf_pl-gds.gds-code:
          if cash-gds.b-str = '':U then nEXT.
          assign
          IBM-good-code = "":U
          .
          run ibm-gdsc in this-procedure (
                                          input (p-pos-type = 'MARIA':U)
                                        , output IBM-good-code
                                        , output IBM-good-code-2
                                        , output IBM2-short
                                        ) no-error .
          if IBM-good-code = "":U then
          assign
          IBM-good-code = IBM-good-code-2
          .
          run bgelib-tag-open in this-procedure ( input 2, input "Tank"
                                                , input substitute("ctrl='&1' tms='&2' code='&3'"
                                                , (if action = 'U' then 'ADD':U else 'DEL')
                                                , OS2-time, cash-place.pl-code)).
          run bgelib-tag-put in this-procedure ( input 3, input "TankNum"       , input string(integer(cash-place.loc1)), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "TankName"      , input substring(cash-place.pl-name, 1, 15), input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "TankProduct"   , input IBM-good-code, input 1 ).
          run bgelib-tag-put in this-procedure ( input 3, input "TankActive"    ,input (if buf_pl-gds.status_ = 'тек':U
                                                                                        then 1
                                                                                        else 0) , INPUT 1).
          run bgelib-tag-close in this-procedure ( input 2, input "Tank").
          v-gds-code = cash-gds.gds-code.
        end.
        for each buf_pl-pump-nozzle no-lock where
                buf_pl-pump-nozzle.obj-type = p-obj-type
            AND buf_pl-pump-nozzle.obj-code = i-obj-code
            and buf_pl-pump-nozzle.status_  <> 'удал':U
        break
        by buf_pl-pump-nozzle.obj-type
        by buf_pl-pump-nozzle.obj-code
        by buf_pl-pump-nozzle.pump-code:
          find first cash-place no-lock where
                cash-place.obj-type = p-obj-type
            and cash-place.obj-code = i-obj-code
            and cash-place.pl-code = buf_pl-pump-nozzle.pl-code no-error .
          find first buf_pl-gds-pump no-lock where
                    buf_pl-gds-pump.obj-type  = p-obj-type
                and buf_pl-gds-pump.obj-code  = i-obj-code
                and buf_pl-gds-pump.pump-code = buf_pl-pump-nozzle.pump-code
                and buf_pl-gds-pump.pl-code  = buf_pl-pump-nozzle.pl-code
                and buf_pl-gds-pump.status_   = 'тек':U  no-error.
          if first-of (buf_pl-pump-nozzle.pump-code) then do:
            run bgelib-tag-open in this-procedure ( input 2, input "FuelPump"
                                                  , input substitute("ctrl='&1' tms='&2' code='&3'"
                                                  , (if action = 'U' then 'ADD':U else 'DEL')
                                                  , OS2-time, buf_pl-pump-nozzle.pump-code)).
          end.
                  if available buf_pl-gds-pump
          then do :
                  run bgelib-tag-open in this-procedure ( input 3, input "FPFuel", input '':U).
                  if not available cash-place
                  or not available buf_pl-gds-pump
                  then do:
                    run bgelib-tag-put in this-procedure ( input 4, input "FPFCode"       , input string(0), input 1 ).
                  end.
                  else do:
                    find first cash-gds where cash-gds.gds-code = buf_pl-gds-pump.gds-code.
                    run ibm-gdsc in this-procedure (
                                                    input (p-pos-type = 'MARIA':U)
                                                  , output IBM-good-code
                                                  , output IBM-good-code-2
                                                  , output IBM2-short
                                                  ) no-error .
                    if IBM-good-code = "":U then
                    assign
                    IBM-good-code = IBM-good-code-2
                    .
                    run bgelib-tag-put in this-procedure ( input 4, input "FPFCode"       , input IBM-good-code, input 1 ).
                  end.
                  run bgelib-tag-put in this-procedure ( input 4, input "FPFTank"       , input string(if available cash-place
                                                                                                       then integer(cash-place.loc1)
                                                                                                       else 0 ), input 1 ).
                  run bgelib-tag-put in this-procedure ( input 4, input "FPFNzl"        , input string(buf_pl-pump-nozzle.nozzle-code), input 1 ).
                  run bgelib-tag-put in this-procedure ( input 4, input "FPFActive"     , input string((if available buf_pl-gds-pump and
                                                                                                         buf_pl-gds-pump.status_ = 'тек':U
                                                                                                        then 1
                                                                                                        else 0)), input 1).
                  if not available cash-place then do:
                    run bgelib-tag-put in this-procedure ( input 4, input "FPFUnused"       , input string(0), input 1 ).
                  end.
                  find first buf_pump-nozzle no-lock where
                            buf_pump-nozzle.obj-type = p-obj-type
                       and  buf_pump-nozzle.obj-code = i-obj-code
                       and buf_pump-nozzle.pump-code = buf_pl-pump-nozzle.pump-code
                       and buf_pump-nozzle.nozzle-code = buf_pl-pump-nozzle.nozzle-code
                       and buf_pump-nozzle.status_  = 'тек':U no-error.
                  if available buf_pump-nozzle then do:
                    run bgelib-tag-put in this-procedure ( input 4, input "FPFNozzleID"       , input string(buf_pump-nozzle.ef-nid), input 1 ).
                  end.
                  run bgelib-tag-close in this-procedure ( input 3, input "FPFuel").
                  end.
          if last-of (buf_pl-pump-nozzle.pump-code) then do:
             run bgelib-tag-close in this-procedure ( input 2, input "FuelPump").
          end.
        end.
      end.
    END CASE.
  end.
end procedure.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE   for-cash-cycle:
DEFINE VARIABLE fname-list as character no-undo .
DEFINE VARIABLE out-list as character no-undo .
DEFINE VARIABLE var-file-num as integer no-undo .
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define variable v-plu as character no-undo .
define variable ss  as character no-undo .
define variable ss0  as character no-undo .
define variable v-temp-kat-file as character no-undo .
define variable v-kat-file as character no-undo .
define variable v-kat-file-save as character no-undo .
define variable v-updated-subject-dis-kat as logical no-undo .
define variable v-next as logical no-undo .
define variable v-cd-subject-code as character no-undo .
define variable v-cd-disc-string as character no-undo .
define variable v-versiond as decimal no-undo .
define buffer for-cash-desk for ub.cash-desk.
_for:
FOR EACH for-cash-desk NO-LOCK WHERE
        for-cash-desk.db-num = g#db-num AND
        for-cash-desk.pos-type = ub.cash-desk.pos-type AND
        for-cash-desk.obj-code = i-obj-code AND
        for-cash-desk.cash-on  = yes
    BREAK
    BY for-cash-desk.db-num
    BY for-cash-desk.obj-code
    BY for-cash-desk.pos-type
    BY for-cash-desk.cash-on
    :
  if LOOKUP(ub.cash-desk.pos-type,
            ('NCR-GM':U + chr(44) +
             'IBM-XML':U + chr(44) +
             'MAGIA-XML':U + chr(44) +
             'NCR-AS@R':U
               )) > 0
  and for-cash-desk.autonomy = integer('1':U) then NEXT.
  assign
  v-versiond = decimal(for-cash-desk.version)
  no-error .
  if error-status:error
  or ( v-versiond < 4.51 and for-cash-desk.pos-type = 'IBM':U )
  or (for-cash-desk.pos-type <> 'IBM':U and for-cash-desk.pos-type <> 'IBM-XML':U)
  then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Невозможно передать на кассу &1 &2&3&4" +
                            "Данный функционал доступен только для POS &5 с версии ПО кассы 4.51 или POS &6"
                          ,  for-cash-desk.cash-num
                          , 'маг':U
                          , for-cash-desk.obj-code
                          , chr(10)
                          , 'IBM':U
                          , 'IBM-XML':U
                          )
                                          ).
     next _for.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Пересылка - касса &1", for-cash-desk.cash-num
                        )
                                        ).
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run xml-cd-filename in this-procedure (
      input out
    , output v-xml-file-name
    , output v-xml-file-name-path
    , output v-log-file-name
    , output v-locked
).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( ("'Пересылка конфигурации АЗC'" + " &1")
                            , replace( v-xml-file-name-path, "/", "\" ) + "xm1"
                      )
                                      ).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "................с параметрами: ... магазин: &1", i-obj-code )
                                      ).
assign
v-obj-list = 'маг':U + string(i-obj-code)
.
run xml-cd-write-header in this-procedure (
      input v-xml-file-name
    , input v-xml-file-name-path
    , input 'data'
    , input "14.0 " + replace( vss-revision + vss-date, "$", " " )
    , input v-obj-list
    , input (
              (IF for-cash-desk.pos-type = 'IBM-XML':U
                then (if for-cash-desk.autonomy = integer('0':U)
                      then  ("маг" + string(for-cash-desk.obj-code) + "_касса" + string(for-cash-desk.cash-num))
                      else ("КМ"   )
                      )
                else ("маг" + string(for-cash-desk.obj-code) +  "_касса" + string(for-cash-desk.cash-num))
                )
            )
    , input (if for-cash-desk.autonomy = integer('0':U) then no else yes)
).
output stream stmxmlout to value( v-xml-file-name-path + "xm1" ) convert target "1251" append.
OS2-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9").
  end.
  when 'IBM':U
  then do:
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if for-cash-desk.cash-os = ""
AND for-cash-desk.pos-type <> 'Emulator-NKT-IBM':U
then NEXT.
assign
Cash-OS2 = (for-cash-desk.cash-os = "OS/2":U) OR (for-cash-desk.cash-os = "LINUX":U)
            AND for-cash-desk.pos-type <> 'Emulator-NKT-IBM':U
Cash-DOS = NOT CASH-OS2
fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 )
v-dir-remote-tmp = v-remote + "tmp":U
v-dir-remote = v-remote + "out":U + string(for-cash-desk.obj-code, "99999") + "-" + string(for-cash-desk.cash-num, "999")
.
if for-cash-desk.remote = 1 then do:
  run gbl/dir-cre.p ( input v-dir-remote-tmp) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Каталог &1  для отсылки запроса на удаленную кассу &2 не найден&3" +
                            "и/или попытка его создания не удалась"
                            ,v-dir-remote-tmp
                            ,for-cash-desk.cash-num
                            ,chr(10)
                            )
                                            ).
      NEXT.
  end.
  run gbl/dir-cre.p ( input v-dir-remote ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Каталог &1  для отсылки запроса на удаленную кассу &2 не найден&3" +
                            "и/или попытка его создания не удалась"
                            ,v-dir-remote
                            ,for-cash-desk.cash-num
                            ,chr(10)
                            )
                                            ).
      NEXT.
    end.
end.
output stream IBMStream
to value( (if for-cash-desk.remote = 1
            then (v-dir-remote-tmp + chr(47) + "fl":U)
            else out) + fname + '.dat' ) convert target "ibm866".
OS2-time =       ( if Cash-OS2 then
                                    string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
                      else "" )
.
  end.
END CASE.
  RUN putc-pet in this-procedure
               ( input for-cash-desk.pos-type
                ,input for-cash-desk.version
                ,input for-cash-desk.cash-os
                ,input for-cash-desk.cash-num
                ).
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream stmxmlout close.
run xml-cd-write-footer in this-procedure ( input for-cash-desk.pos-type, input v-xml-file-name-path
    , input 'data'
).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1"
                            , replace( v-xml-file-name-path, "/", "\" ) + "xml"
                      )
                                       ).
if (
not (g#news or g#auto or g#esys )
or
(
for-cash-desk.pos-type = 'MAGIA-XML':U
or
  (for-cash-desk.pos-type = 'IBM-XML':U
or (for-cash-desk.pos-type = 'Autotank':U
  and
  for-cash-desk.autonomy = integer('2':U))
  )))
then do:
  if for-cash-desk.pos-type = 'MAGIA-XML':U then do:
  end.
  if (for-cash-desk.pos-type = 'IBM-XML':U
  and for-cash-desk.autonomy = integer('0':U))
  or (for-cash-desk.pos-type = 'Autotank':U
  and for-cash-desk.autonomy = integer('2':U))
  then do:
    run str/post-xml.p
      (
       input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input g#news or g#esys
      ,input g#auto
      ,input 'send'
      ,input log-file-name
      ,input (entry(1, for-cash-desk.addr-path, chr(4)) + '://' + entry(2, for-cash-desk.addr-path, chr(4)))
      ,input (replace( v-xml-file-name-path, "/", "\" ) + "xml")
      ,input (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml")
      ,input 30
      ,input   ( if action = 'U'
                  then ('Ждите - ' + 'добавление/изменение конфигурации АЗС')
                  else ('Ждите - ' + 'удаление конфигурации АЗС') ) +
                  substitute("Маг&1 касса&2", for-cash-desk.obj-code, for-cash-desk.cash-num)
      ) no-error .
    if error-status:error
    or return-value = "error" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных:&3&4 &5"
                                ,for-cash-desk.obj-code
                                ,for-cash-desk.cash-num
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                            )
                                            ).
      assign
      v-view-log = yes
      .
    end.
  end.
  if not available ub.shop then do:
    find first ub.shop no-lock where
              ub.shop.obj-code = for-cash-desk.obj-code.
  end.
  if
  not (g#news or g#esys)
  then do:
    run str/getxibmf.p (
                    input parparentproc
                  ,input p-log-handle
                  ,input 'маг':U
                  ,input for-cash-desk.obj-code
                  ,input ub.shop.host-code
                  ,input in_
                  ,input spl
                  ,input (in_ + sav)
                  ,input for-cash-desk.pos-type
                  ,input (if (for-cash-desk.pos-type = 'IBM-XML':U
                          and for-cash-desk.autonomy = integer('0':U))
                          or (for-cash-desk.pos-type = 'Autotank':U
                          and for-cash-desk.autonomy = integer('2':U))
                          then "utf-8":U
                          else "windows-1251")
                  ,input log-file-name
                  ,input "data":U
                  ,input v-xml-file-name
                  ,input-output v-view-log
                  ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных"
                                ,for-cash-desk.obj-code
                                ,for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
    end.
  end.
end.
if g#news
or g#auto
or g#esys
and for-cash-desk.pos-type = 'MAGIA-XML':U
then do:
end.
  end.
  when 'IBM':U
  then do:
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream IBMStream close.
output stream IBMStream
to value( (if for-cash-desk.remote = 1
            then (v-dir-remote-tmp + chr(47) + "fl":U)
            else out) + fname + '.ad0' ) convert target "ibm866".
put stream IBMStream ' ' skip(1).
 put stream IBMStream unformatted '  ' for-cash-desk.addr-path ' plu' skip.
output stream IBMStream close.
OS-RENAME
VALUE((if for-cash-desk.remote = 1
        then (v-dir-remote-tmp + chr(47) + "fl":U)
        else out) + fname + '.ad0')
VALUE((if for-cash-desk.remote = 1
        then (v-dir-remote + chr(47) + "fl":U)
        else out) + fname + '.adr').
os-er = OS-ERROR.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1, файл адреса &2"
                        , ((if for-cash-desk.remote = 1
                            then (v-dir-remote + chr(47) + "fl":U)
                            else out) + fname + '.dat')
                        , ((if for-cash-desk.remote = 1
                            then (v-dir-remote + chr(47) + "fl":U)
                            else out) + fname + '.adr')
                        )
                                       ).
if os-er <> 0 then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки в работе локальной сети или нарушение прав доступа при обмене информацией с кассой &1",
                            for-cash-desk.cash-num
                        )
                                        ).
      assign
      v-view-log = yes
      .
      return "error":U.
end.
if for-cash-desk.remote = 1 then do:
  OS-RENAME
  VALUE(v-dir-remote-tmp + chr(47) + "fl":U + fname + '.dat')
  VALUE(v-dir-remote  + chr(47) + "fl":U + fname + '.dat').
  os-er = OS-ERROR.
  if os-er <> 0 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Ошибки в работе локальной сети или нарушение прав доступа при обмене информацией с кассой &1",
                                for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
      return "error":U.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Данные выгружены в файл &1",
                            (v-dir-remote  + chr(47) + "fl":U + fname + '.dat')
                        )
                                        ).
end.
else do:
  if not g#news
  and not g#auto
  and not g#esys
  then do:
  end.
end.
  end.
END CASE.
END .
END PROCEDURE.
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE SENDING:
_cash-desk:
FOR EACH ub.cash-desk NO-LOCK WHERE
         ub.cash-desk.db-num = g#db-num AND
         ub.cash-desk.obj-code = i-obj-code AND
        ub.cash-desk.cash-on
BREAK
By ub.cash-desk.pos-type :
  IF FIRST-OF(ub.cash-desk.pos-type) then do:
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable dflt-cd79 as character no-undo .
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type80 as character no-undo .
define variable v-value-date80 as date no-undo .
define variable v-value-decimal80 as decimal no-undo .
define variable v-value-integer80 as INTEGER no-undo .
define variable v-value-logical80 AS LOGICAL no-undo .
define variable v-tth80 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  ub.cash-desk.obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd79
    ,output v-value-date80
    ,output v-value-decimal80
    ,output v-value-integer80
    ,output v-value-logical80
    ,output v-param-type80
    ,INPUT-OUTPUT table-handle v-tth80
    ) no-error .
delete object v-tth80 no-error.
case ub.cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
  then do:
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
if ub.cash-desk.pos-type = 'IBM-XML':U
or ub.cash-desk.pos-type = 'Autotank':U
then do:
  file-info:file-name = (out  + "undelivered").
  if file-info:FULL-PATHNAME <> ? then do:
    run str/rsndxibm.p ( input parparentproc
                        ,input p-parent-handle
                        ,input p-log-handle
                        ,input out  + "undelivered" ) no-error.
  end.
end.
  end.
  when 'IBM':U
  then do:
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
  end.
END CASE.
    RUN for-cash-cycle no-error.
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("&1 &2", error-status:get-message(1), return-value)
                                              ).
      assign
      v-view-log = yes
      .
    end.
  END.
  IF LAST-OF(ub.cash-desk.pos-type) then do:
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case ub.cash-desk.pos-type:
END CASE.
  END.
END.
END PROCEDURE.
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE term-prt.
define input parameter c-root like ub.gds-prt.prt-root no-undo.
define input parameter c-node like ub.gds-prt.node-code no-undo.
define buffer b-g-p for ub.gds-prt.
define buffer pr-bc for ub.bar-code .
define buffer b-bc for ub.bar-code .
define buffer p-bar-code for ub.bar-code .
define buffer b-units for ub.units.
define variable pusto as char init "" no-undo.
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if action = "U" then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-list.gds-code
  ,input  ?
  ,output main-b-code
  ) no-error .
      find first buf_producer no-lock where
                 buf_producer.obj-type = gds-list.prod-type
             AND buf_producer.obj-code = gds-list.prod-code no-error .
      assign
      for-producer = (if available buf_producer
                      then buf_producer.obj-name
                      else (gds-list.prod-type + string(gds-list.prod-code)))
      for-producer-int = (if gds-list.prod-type = 'орг':U then 1000000 else 0 ) + gds-list.prod-code
      .
  end.
  if LOOKUP('топ':U, ub.units.type) > 0 and
      LOOKUP('дро':U, ub.units.type) > 0 AND
      gds-list.gds-type = 'т':U
  then do:
        petrol-trk = yes.
  end.
  else petrol-trk = no.
  _b-g-p:
   FOR EACH ub.bar-code NO-LOCK where
            ub.bar-code.gds-code = gds-list.gds-code,
      FIRST b-g-p NO-LOCK WHERE
            b-g-p.node-code = ub.bar-code.node-code
       AND  b-g-p.prt-root = c-root
       AND  b-g-p.is-term = yes
     :
     if ub.bar-code.part-code <> ""
     OR ub.bar-code.in-code <> ""
     OR ub.bar-code.unit-cli <> gds-list.unit-base then NEXT _b-g-p.
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST ub.prt-obj WHERE
        ub.prt-obj.obj-type = 'маг':U AND
        ub.prt-obj.obj-code = ub.shop.obj-code AND
        ub.prt-obj.prod-type = gds-list.prod-type AND
        ub.prt-obj.prod-code = gds-list.prod-code AND
        ub.prt-obj.artic = gds-list.artic AND
        ub.prt-obj.prt-code = b-g-p.node-code NO-LOCK NO-ERROR .
if v-is-restaurant and v-is-null-price then.
else do:
    def var l-in-ov87 as logical no-undo .
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  'маг':U
  ,input  ub.shop.obj-code
  ,input  gds-list.artic
  ,input  gds-list.prod-type
  ,input  gds-list.prod-code
  ,input  'in-ov=request'
  ,output l-in-ov87
  ) no-error .
  if error-status:error then do:
    message
      "Ошибка получения признака товара на объекте" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  if (ub.shop.in-ov and  l-in-ov87 ) then
              NEXT _b-g-p.
if (NOT ub.shop.all-prt )
    AND  gds-list.gds-type = 'т':U
    AND  NOT l-empty-scale then do:
  if not available ub.prt-obj then do:
    if ub.shop.sub-store-on then do:
      if NOT can-find( first ub.gds-dtl where
                          ub.gds-dtl.artic = gds-list.artic AND
                          ub.gds-dtl.prod-type = gds-list.prod-type AND
                          ub.gds-dtl.prod-code = gds-list.prod-code AND
                          ub.gds-dtl.prt-code = b-g-p.node-code AND
                          ub.gds-dtl.obj-type =  ub.shop.sub-store-type AND
                          ub.gds-dtl.obj-code = ub.shop.sub-store-code) then
                  NEXT _b-g-p.
    end.
    else do:
                  NEXT _b-g-p.
    end.
  end.
end.
end.
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if ((LOOKUP('сер':U, ub.units.type) = 0  and not cashparts) OR
      (LOOKUP('сер':U, ub.units.type) > 0 and NOT ub.shop.cd-parts-ser)
     )
    then do:
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = ub.bar-code.unit-cli No-ERROR.
if (ub.shop.cd-bc-base or ub.shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer ub.bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input 'маг':U,
      input ub.shop.obj-code
      )  no-error .
     if error-status:error then return error.
end.
if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = ub.bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( ub.bar-code.b-code )
          AND
          (
          (gds-list.unit-base = ub.bar-code.unit-cli AND ub.shop.cd-loc-base) OR
          (NOT gds-list.unit-base = ub.bar-code.unit-cli AND ub.shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if ub.shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    ub.bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer ub.bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((ub.shop.cd-pb-base AND ub.bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (ub.shop.cd-pb-alt AND ub.bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer ub.bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = ub.bar-code.node-code AND
            b-bc.part-code = pusto AND
            b-bc.in-code = pusto NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input 'маг':U,
            input ub.shop.obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if ub.shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND ub.shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input 'маг':U,
          input ub.shop.obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
  end.
  if petrol-trk then return.
  if ub.shop.doc-prt AND b-g-p.node-name <> '_Пустая шкала':U then NEXT _b-g-p.
  if ub.shop.cd-parts-all or (cashparts AND LOOKUP('сер':U, units.type) = 0) then do:
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = gds-list.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          FIRST ub.parts No-LOCK WHERE
                ub.parts.obj-type  = 'маг':U
            AND ub.parts.obj-code  = ub.shop.obj-code
            AND ub.parts.artic     = gds-list.artic
            AND ub.parts.prod-type = gds-list.prod-type
            AND ub.parts.prod-code = gds-list.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
      IF p-bar-code.unit-cli <> gds-list.unit-base then next.
      IF FIRST-OF(p-bar-code.part-code) then do:
define variable vss-include-info92 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (ub.shop.cd-bc-base or ub.shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input 'маг':U,
      input ub.shop.obj-code
      )  no-error .
     if error-status:error then return error.
end.
if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if ub.shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info93 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((ub.shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (ub.shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input 'маг':U,
            input ub.shop.obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if ub.shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND ub.shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input 'маг':U,
          input ub.shop.obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
      end.
    end.
   end.
   else do:
      FOR EACH ub.parts NO-LOCK WHERE
                ub.parts.obj-type  = 'маг':U AND
                ub.parts.obj-code  = ub.shop.obj-code AND
                ub.parts.artic     = gds-list.artic AND
                ub.parts.prod-type = gds-list.prod-type AND
                ub.parts.prod-code = gds-list.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then
        FOR EACH p-bar-code NO-LOCK WHERE
                p-bar-code.gds-code = gds-list.gds-code AND
                p-bar-code.in-code = ub.parts.in-code AND
                p-bar-code.part-code = ub.parts.part-code AND
                p-bar-code.node-code = ub.bar-code.node-code AND
                p-bar-code.unit-cli = gds-list.unit-base:
define variable vss-include-info94 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (ub.shop.cd-bc-base or ub.shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input 'маг':U,
      input ub.shop.obj-code
      )  no-error .
     if error-status:error then return error.
end.
if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if ub.shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((ub.shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (ub.shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input 'маг':U,
            input ub.shop.obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if ub.shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND ub.shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input 'маг':U,
          input ub.shop.obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        END.
      END.
    end.
    return.
  end.
  if ub.shop.cd-parts-not-blank or (cashparts AND LOOKUP('сер':U, units.type) = 0) then do:
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = gds-list.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          EACH ub.parts No-LOCK WHERE
               ub.parts.obj-type  = 'маг':U
            AND ub.parts.obj-code  = ub.shop.obj-code
            AND ub.parts.artic     = gds-list.artic
            AND ub.parts.prod-type = gds-list.prod-type
            AND ub.parts.prod-code = gds-list.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
        if p-bar-code.part-code = "":U then NEXT.
        if p-bar-code.unit-cli <> gds-list.unit-base then NEXT.
        IF FIRST-OF(p-bar-code.part-code) then do:
define variable vss-include-info96 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (ub.shop.cd-bc-base or ub.shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input 'маг':U,
      input ub.shop.obj-code
      )  no-error .
     if error-status:error then return error.
end.
if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if ub.shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info97 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((ub.shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (ub.shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input 'маг':U,
            input ub.shop.obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if ub.shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND ub.shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input 'маг':U,
          input ub.shop.obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        end.
      end.
    end.
    else do:
      FOR EACH ub.parts NO-LOCK  WHERE
                ub.parts.obj-type  = 'маг':U AND
                ub.parts.obj-code  = ub.shop.obj-code AND
                ub.parts.artic     = gds-list.artic AND
                ub.parts.prod-type = gds-list.prod-type AND
                ub.parts.prod-code = gds-list.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no AND
                ub.parts.part-code <> ""
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then
        FOR   EACH p-bar-code NO-LOCK WHERE
                    p-bar-code.gds-code = gds-list.gds-code AND
                    p-bar-code.in-code = ub.parts.in-code AND
                    p-bar-code.part-code = ub.parts.part-code AND
                    p-bar-code.node-code = ub.bar-code.node-code AND
                    p-bar-code.unit-cli = gds-list.unit-base:
define variable vss-include-info98 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (ub.shop.cd-bc-base or ub.shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input 'маг':U,
      input ub.shop.obj-code
      )  no-error .
     if error-status:error then return error.
end.
if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if ub.shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((ub.shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (ub.shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input 'маг':U,
            input ub.shop.obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if ub.shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND ub.shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input 'маг':U,
          input ub.shop.obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        END.
      END.
    end.
  end.
  if LOOKUP('сер':U, units.type) > 0 AND ub.shop.cd-parts-ser then do:
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = gds-list.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          EACH ub.parts No-LOCK WHERE
               ub.parts.obj-type  = 'маг':U
            AND ub.parts.obj-code  = ub.shop.obj-code
            AND ub.parts.artic     = gds-list.artic
            AND ub.parts.prod-type = gds-list.prod-type
            AND ub.parts.prod-code = gds-list.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
        if p-bar-code.unit-cli <> gds-list.unit-base then NEXT.
        if ub.parts.part-code <> "" and  ub.shop.cd-parts-not-blank then NEXT.
        IF FIRST-OF(p-bar-code.part-code) then do:
define variable vss-include-info100 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (ub.shop.cd-bc-base or ub.shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input 'маг':U,
      input ub.shop.obj-code
      )  no-error .
     if error-status:error then return error.
end.
if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if ub.shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info101 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((ub.shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (ub.shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input 'маг':U,
            input ub.shop.obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if ub.shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND ub.shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input 'маг':U,
          input ub.shop.obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        end.
      end.
    end.
    else do:
      FOR EACH ub.parts NO-LOCK  WHERE
                ub.parts.obj-type  = 'маг':U AND
                ub.parts.obj-code  = ub.shop.obj-code AND
                ub.parts.artic     = gds-list.artic AND
                ub.parts.prod-type = gds-list.prod-type AND
                ub.parts.prod-code = gds-list.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no AND
                ub.parts.part-code <> ""
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then do:
          if ub.parts.part-code <> "" and  ub.shop.cd-parts-not-blank then NEXT.
          FOR EACH p-bar-code NO-LOCK WHERE
                    p-bar-code.gds-code = gds-list.gds-code AND
                    p-bar-code.in-code = ub.parts.in-code AND
                    p-bar-code.part-code = ub.parts.part-code AND
                    p-bar-code.node-code = ub.bar-code.node-code AND
                    p-bar-code.unit-cli = gds-list.unit-base:
define variable vss-include-info102 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (ub.shop.cd-bc-base or ub.shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input 'маг':U,
      input ub.shop.obj-code
      )  no-error .
     if error-status:error then return error.
end.
if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if ub.shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info103 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((ub.shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (ub.shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input 'маг':U,
            input ub.shop.obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if ub.shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND ub.shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input 'маг':U,
          input ub.shop.obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
          END.
        END.
      END.
    end.
  end.
  end.
END PROCEDURE .
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пересылка конфигурации АЗС на кассы &1&2", p-obj-type, i-obj-code)
                                                                                 ).
for each cash-place:
  delete cash-place.
end.
_buf_place:
for each buf_place no-lock where
        buf_place.obj-type = p-obj-type
    AND buf_place.obj-code = i-obj-code
    and buf_place.status_  <> 'удал':U,
    first buf_pl-gds no-lock where
          buf_pl-gds.obj-type = p-obj-type
      AND buf_pl-gds.obj-code = i-obj-code
      and buf_pl-gds.pl-code = buf_place.pl-code
      and buf_pl-gds.status_ = 'тек':U,
    first buf_goods no-lock where buf_goods.gds-code = buf_pl-gds.gds-code and buf_goods.stts = integer('0':U) :
  assign
  dop-int = integer(buf_place.loc1)
  no-error .
  if error-status:error
  or buf_place.loc1 = '':U
  or dop-int > 999
  then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Ошибка при пересылке конфигурации АЗС:&1" +
                           "для резервуара с кодом скл места &2&1" +
                           "не задан или неверно задан порядкой код резервуара (коорд1) = &3"
                            , chr(10)
                            , buf_place.pl-code
                            , Buf_place.loc1 )).
    v-view-log = yes.
    next _buf_place.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
  if not (is-petrolium and not is-pieces) then NEXT.
define variable vss-include-info104 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = buf_goods.prod-type
    and gds-list.prod-code = buf_goods.prod-code
    and gds-list.artic     = buf_goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last104 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last104 = gds-list.order-num .
  end.
  else do:
    v-last104 = 0 .
  end.
  create gds-list .
  buffer-copy buf_goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last104 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
  find first cash-place no-lock where
            cash-place.loc1 = buf_place.loc1 no-error .
  if not available cash-place then do:
    create cash-place.
    buffer-copy buf_place to cash-place.
  end.
  else do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Ошибка при пересылке конфигурации АЗС:&1" +
                           "на &2&3 имеется два резервуара (складских места) - &4 и &5 &1" +
                           "c одним и тем же порядковым номером = &6 (коорд1)&1"
                            , chr(10)
                            , buf_place.obj-type
                            , buf_place.obj-code
                            , cash-place.pl-code
                            , buf_place.pl-code
                            , Buf_place.loc1 )).
    v-view-log = yes.
  end.
end.
_gds-list:
FOR EACH gds-list :
    assign
      v-count = v-count + 1
    .
    run get-prt-and-unit in this-procedure (
                                            input gds-list.prt-root
                                            ,input gds-list.unit-base
                                            ,output l-empty-scale
                                            ) .
    FIND FIRST ub.gds-obj WHERE
               ub.gds-obj.obj-type = 'маг':U AND
               ub.gds-obj.obj-code = i-obj-code AND
               ub.gds-obj.artic = gds-list.artic AND
               ub.gds-obj.prod-type = gds-list.prod-type AND
               ub.gds-obj.prod-code = gds-list.prod-code nO-LOCK NO-ERROR.
    if g#news and not avail gds-obj then NEXT.
    if not g#news then do:
      if v-count modulo 10 = 0 then do:
        run show-counter in p-log-handle .
        run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - товар &2 &3&4"
                                           , v-count
                                           , gds-list.artic
                                           , gds-list.prod-type
                                           , gds-list.prod-code)) no-error.
      end.
    end.
    RUN term-prt( ub.gds-prt.prt-root, ?) no-error.
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Ошибка при обработке товара &1 &2&3"
                              , gds-list.artic
                              , gds-list.prod-type
                              , gds-list.prod-code
                              )
                                ).
      assign
      v-view-log = yes
      .
      if g#news then return error.
    end.
    ACCUMULATE gds-list.artic (COUNT).
    delete gds-list.
END .
RUN SENDING no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке конфигурации АЗС на кассы &1&2"
                         , p-obj-type, i-obj-code
                        )
                                        ).
  assign
  v-view-log = yes
  .
end.
if v-view-log then return error .
  finally :
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1", chr(10))
    ).
    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
    OS-APPEND value(log-file-name) value(v-save-file-name).
    OS-DELETE value(log-file-name).
  end finally .
