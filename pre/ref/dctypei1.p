block-level on error undo, throw.
define temp-table tt0-root-dis-card-type no-undo like ub.dis-card-type.
define temp-table tt0-dis-dct-rule no-undo like ub.dis-dct-rule.
define temp-table tt0-hist-nws-option no-undo like ub.hist-nws-option.
define temp-table tt0-rp-by-call no-undo like ub.rp-by-call.
define temp-table tt0-rule-by-call no-undo like ub.rule-by-call.
define temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .
define input parameter p-emitent-host-code like ub.dis-card-type.emitent-host-code no-undo .
define input parameter p-type like ub.dis-card-type.type no-undo .
define input parameter p-uniq-key-rec as character no-undo .
define input parameter parhost-code like ub.dis-card-type.host-code no-undo .
define input parameter parobj-type like ub.dis-card-type.obj-type no-undo .
define input parameter parobj-code like ub.dis-card-type.obj-code no-undo .
define input parameter pard-pcnt-byshop  like ub.dis-card-type.d-pcnt-byshop no-undo .
define input parameter pardflt-d-pcnt-method like ub.dis-card-type.dflt-d-pcnt-method no-undo .
define input parameter pardflt-credit-card like ub.dis-card-type.dflt-credit-card no-undo .
define input parameter parlim-kr like ub.dis-card-type.lim-kr no-undo .
define input parameter pardflt-debet-card like  ub.dis-card-type.dflt-debet-card  no-undo .
define input parameter pardflt-staff-card like  ub.dis-card-type.dflt-staff-card  no-undo .
define input parameter parfiscal-pay      like  ub.dis-card-type.fiscal-pay       no-undo .
define input parameter parmixed-pay       like  ub.dis-card-type.mixed-pay        no-undo .
define input parameter parpay-code        like  ub.dis-card-type.pay-code         no-undo .
define input parameter parcard-media      like  ub.dis-card-type.card-media       no-undo .
define input parameter parcardname-sent   like  ub.dis-card-type.cardname-sent    no-undo .
define input parameter parcustom-sent     like  ub.dis-card-type.custom-sent      no-undo .
define input parameter pardcbyshop like ub.dis-card-type.dcbyshop no-undo .
define input parameter pardc-pfx like ub.dis-card-type.dc-pfx no-undo .
define input parameter parcheck-by-mask    as logical no-undo .
define input parameter parho-join          as logical no-undo .
define input parameter table for tt0-dis-dct-rule.
define input parameter table for tt0-hist-nws-option.
define input parameter table for tt0-rp-by-call.
define input parameter table for tt0-rule-by-call.
define input parameter table for tt0-rule-call-param.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dctypei1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dctypei1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке типа дисконтной карты".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable dcard-algo-field-name as character no-undo extent 3 init [
 'd-pcnt':U
,'cash-d-pcnt':U
,'pcnt-kat':U].
define variable algo-field-abbr as character no-undo extent 3 init [
 'ITEM%':U
,'TOTAL%':U
,'CATEG':U].
FUNCTION dct-algo-Date-to-String returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + chr(47) +
             string(Month(p-date), "99":U) + chr(47) +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
function dct-algo-string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 6, 2))
                ,integer(substring(p-string, 9, 2))
                ,integer(substring(p-string, 1, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION dct-algo-get-sum-id-from-DT-CODE returns character ( input p-DT-CODE as integer):
define buffer buf_prop-ref for ub.prop-ref.
find first buf_prop-ref no-lock where
          buf_prop-ref.DT-CODE = p-DT-CODE no-error.
if not available buf_prop-ref then do:
  return chr(63).
end.
return buf_prop-ref.sum-id.
END FUNCTION.
FUNCTION dct-algo-get-description-sum-id returns character ( input p-dt-code as integer):
define variable v-des as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-head for ub.prop-head.
find first buf_prop-ref no-lock where
          buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then do:
  return substitute("Срез/итог по ДК c кодом &1 - срез не найден", p-dt-code).
end.
find first buf_prop-head no-lock where
        buf_prop-head.dtm-code = buf_prop-ref.dtm-code no-error.
if not available buf_prop-head then do:
  return substitute("Срез/итог по ДК &1 c кодом &2 - неизвестное", p-dt-code, buf_prop-ref.dtm-code).
end.
assign
v-des = substitute("&1  &2 &3"
                  , buf_prop-head.prop-name
                  , buf_prop-ref.sum-id
                  , buf_prop-ref.caller_id).
return v-des.
end FUNCTION.
FUNCTION dct-algo-get-description-node-code returns character ( input p-dtm-code as integer
                                                            ,input p-dt-code as integer
                                                            ,input p-node-code as integer
                                                            ):
define variable v-des as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-map for ub.prop-map.
find first buf_prop-ref no-lock where
          buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then do:
  return substitute("Срез/итог по ДК c кодом &1 - срез не найден", p-dt-code).
end.
find first buf_prop-head no-lock where
        buf_prop-head.dtm-code = p-dtm-code no-error.
if not available buf_prop-head then do:
  return substitute("Срез/итог по ДК &1 c кодом &2 - неизвестное", p-dt-code, p-dtm-code).
end.
find first buf_prop-map no-lock where
        buf_prop-map.dtm-code = p-dtm-code
    and buf_prop-map.node-code = p-node-code no-error .
if not available buf_prop-map then do:
  return substitute("Срез/итог по ДК &1, &2.&3 - неизвестно"
                    , p-dt-code
                    , buf_prop-head.prop-label
                    , p-node-code).
end.
assign
v-des = substitute("&1.&2 &3 &4"
                  , buf_prop-head.prop-label
                  , buf_prop-map.node-label
                  , buf_prop-ref.sum-id
                  , buf_prop-ref.caller_id).
return v-des.
end FUNCTION.
function dct-algo-get-prev-sum-id RETURNS integer (
                                                    input p-dt-code as integer
                                                   ):
define variable v-dtm-code as integer no-undo .
define variable v-sum-id as character no-undo .
define variable v-caller-id as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
find first buf_prop-ref no-lock where
        buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then return ?.
assign
v-dtm-code = buf_prop-ref.dtm-code
v-sum-id = buf_prop-ref.sum-id.
v-caller-id = buf_prop-ref.caller_id.
find last buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = v-dtm-code
     and  buf_prop-ref.sum-id < v-sum-id
     and  buf_prop-ref.caller_id = v-caller-id
     no-error.
if available buf_prop-ref then return buf_prop-ref.dt-code.
return -1 .
END FUNCTION.
FUNCTION dct-algo-get_dcproperty-value returns logical (
                                                          input p-prop-name as character
                                                        , input p-d-card    as character
                                                        , input p-host-code as integer
                                                        , input p-obj-type  as character
                                                        , input p-obj-code  as integer
                                                        , output p-value-character as character
                                                        , output p-value-date   as date
                                                        , output p-value-integer as integer
                                                        , output p-value-decimal as decimal
                                                        , output p-value-logical as logical):
  return no.
END FUNCTION.
FUNCTION dct-algo-get_dcproperty-value-chr returns logical (
                                                          input p-d-card    as character
                                                        , input p-emitent-host-code as integer
                                                        , input p-type as character
                                                        , input p-host-code as integer
                                                        , input p-obj-type  as character
                                                        , input p-obj-code  as integer
                                                        , output p-value-chr as character):
define variable v-dt-code as integer no-undo .
define variable v-node-code as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-storage-place as character no-undo .
define variable v-sum-id-value as character no-undo .
define variable v-sum-id-output as logical no-undo .
define variable v-value-chr as character no-undo .
define variable v-ii as integer no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_dis-obj for ub.dis-obj.
run get-cd-sumid in this-procedure (
                                      input p-emitent-host-code
                                     ,input p-type
                                     ,input p-host-code
                                     ,input p-obj-type
                                     ,input p-obj-code
                                     ,output v-sum-id-value
                                     ,output v-sum-id-output
                                    ) no-error.
if not v-sum-id-output then do:
  return no.
end.
do v-ii = 1 to num-entries(v-sum-id-value):
  assign
  v-storage-place = entry(1, entry(v-ii, v-sum-id-value), chr(4))
  v-dt-code = integer(entry(2, entry(v-ii, v-sum-id-value), chr(4)))
  v-node-code = integer(entry(3, entry(v-ii, v-sum-id-value), chr(4)))
  v-field-name = entry(4, entry(v-ii, v-sum-id-value), chr(4))
  no-error .
  if not error-status:error then do:
    case v-storage-place:
      when 'dis-card-property':U then do:
        find first buf_dis-card-property no-lock where
                  buf_dis-card-property.d-card = p-d-card
            and  buf_dis-card-property.host-code = p-host-code
            and  buf_dis-card-property.obj-type = p-obj-type
            and  buf_dis-card-property.obj-code = p-obj-code
            and  buf_dis-card-property.dt-code = v-dt-code
            and  buf_dis-card-property.node-code = v-node-code no-error .
        if available buf_dis-card-property then do:
          v-value-chr = buffer buf_dis-card-property:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
      when 'dis-obj':U then do:
        find first buf_dis-obj no-lock where
                  buf_dis-obj.d-card = p-d-card
            and  buf_dis-obj.obj-type = p-obj-type
            and  buf_dis-obj.obj-code = p-obj-code
            and  buf_dis-obj.dt-code = v-dt-code no-error .
        if available buf_dis-obj then do:
          v-value-chr = buffer buf_dis-obj:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
      when 'dis-host':U then do:
        find first buf_dis-host no-lock where
                  buf_dis-host.d-card = p-d-card
            and  buf_dis-host.host-code = p-host-code
            and  buf_dis-host.dt-code = v-dt-code no-error .
        if available buf_dis-host then do:
          v-value-chr = buffer buf_dis-host:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
    end.
  end.
  p-value-chr = p-value-chr + (if v-ii = 1 then '':U else chr(44)) + v-value-chr.
end.
END FUNCTION.
FUNCTION dct-algo_custom-sent-description RETURNS CHARACTER
  ( INPUT p-custom-sent as character ) :
DEFINE VARIABLE v-storage-place AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dtm-code AS integer NO-UNDO.
DEFINE VARIABLE v-sum-id AS character NO-UNDO.
DEFINE VARIABLE v-caller-id AS character NO-UNDO.
DEFINE VARIABLE v-node-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-sum-id-description AS CHARACTER.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
IF p-custom-sent = chr(63) THEN RETURN "Не отсылать".
assign
v-storage-place = entry(1, p-custom-sent, chr(4))
v-dtm-code = integer(entry(2, p-custom-sent, chr(4)))
v-sum-id   = entry(3, p-custom-sent, chr(4))
v-caller-id = entry(4, p-custom-sent, chr(4))
v-node-code = integer(entry(5, p-custom-sent, chr(4)))
no-error .
IF ERROR-STATUS:ERROR THEN DO:
  MESSAGE
  "Не могу разобрать строку, описывающую итог"
   VIEW-AS ALERT-BOX WARNING.
  RETURN chr(63).
END.
FIND FIRST buf_prop-ref NO-LOCK WHERE
          buf_prop-ref.dtm-code = v-dtm-code
     AND  buf_prop-ref.sum-id = v-sum-id
     AND  buf_prop-ref.caller_id = v-caller-id NO-ERROR.
IF NOT AVAILABLE buf_prop-ref THEN DO:
  FIND FIRST buf_prop-ref NO-LOCK WHERE
            buf_prop-ref.dtm-code = v-dtm-code
      AND  buf_prop-ref.caller_id = v-caller-id NO-ERROR.
  IF NOT AVAILABLE buf_prop-ref THEN DO:
      MESSAGE
      "Не могу разобрать строку, описывающую итог"
       VIEW-AS ALERT-BOX WARNING.
      RETURN chr(63).
   end.
end.
ASSIGN
v-sum-id-description =  dct-algo-get-description-node-code ( v-dtm-code
                                                       ,buf_prop-ref.dt-code
                                                       ,v-node-code).
RETURN v-sum-id-description.
END FUNCTION.
FUNCTION one-base-cur-for-objs  returns logical (output p-glob-curr-code as integer):
define variable v-glob-val as logical no-undo init yes.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
assign
p-glob-curr-code =  -1
.
FOR EACH buf_sysconf NO-LOCK,
    first buf_clients no-lock where
         buf_clients.host-code = buf_sysconf.host-code:
    if p-glob-curr-code = -1 then
    assign
    p-glob-curr-code = buf_sysconf.base-code
    .
    else if p-glob-curr-code <> buf_sysconf.base-code then do:
        assign
        v-glob-val = no
        p-glob-curr-code = ?
        .
        LEAVE.
    end.
END.
return v-glob-val.
END FUNCTION.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-mask-range no-undo
field mask-original   like ub.dis-card-mask.mask
field mask      like ub.dis-card-mask.mask
field mask-num as integer
field lvl-decompose as integer
field host-code like ub.sysconf.host-code
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
field first-code as decimal
field last-code as decimal
field to-check as logical
index pi is unique mask-num lvl-decompose first-code last-code
index iobj to-check first-code last-code host-code obj-type obj-code
.
procedure decompose-mask :
define input parameter p-mask-num  like ub.dis-card-mask.mask-num no-undo .
define input parameter p-mask      like ub.dis-card-mask.mask     no-undo .
define input parameter p-mask-original like ub.dis-card-mask.mask     no-undo .
define input parameter p-lvl-decompose  as integer no-undo .
define input parameter p-host-code like ub.sysconf.host-code      no-undo .
define input parameter p-obj-type  like ub.clients.obj-type       no-undo .
define input parameter p-obj-code  like ub.clients.obj-code       no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-kk as integer no-undo .
define variable v-max as integer no-undo .
define variable v-mask as character no-undo .
define variable v-mask0 as character no-undo .
define variable v-mask9 as character no-undo .
define variable v-mask-char as character no-undo .
define variable v-dec       as decimal no-undo .
  do
  on error undo, return error return-value
  :
    assign
    v-mask = p-mask
    v-max = length (p-mask).
    _do:
    do v-ii = 1 to v-max:
      assign
      v-mask-char = substring(p-mask, v-ii, 1)
      .
      if v-mask-char = chr(63) then do:
        do v-kk = 0 to 9:
          create temp-mask-range.
          assign
          substring(v-mask, v-ii, 1) = string(v-kk)
          temp-mask-range.mask     = v-mask
          temp-mask-range.mask-original = p-mask-original
          temp-mask-range.mask-num = p-mask-num
          temp-mask-range.host-code = p-host-code
          temp-mask-range.obj-type  = p-obj-type
          temp-mask-range.obj-code  = p-obj-code
          temp-mask-range.lvl-decompose = p-lvl-decompose + 1
          .
          assign
          v-dec = decimal(v-mask + "." ) no-error .
          if not error-status:error then
          assign
          temp-mask-range.first-code = decimal(v-mask + ".")
          temp-mask-range.last-code = decimal(v-mask + ".")
          temp-mask-range.to-check  = yes
          .
          else do:
            assign
            temp-mask-range.first-code = ?
            temp-mask-range.last-code = ?
            temp-mask-range.to-check  = no
            .
          end.
        end.
      end.
      if v-mask-char = "*":U then do:
        assign
        v-mask =  trim(v-mask, "*":U)
        v-mask0 = trim(v-mask, "*":U)
        v-mask9 = trim(v-mask, "*":U)
        .
        do v-jj = 1 to (19 - v-ii + 1) :
          create temp-mask-range.
          assign
          temp-mask-range.mask     = v-mask
          temp-mask-range.mask-original = p-mask-original
          temp-mask-range.mask-num = p-mask-num
          temp-mask-range.host-code = p-host-code
          temp-mask-range.obj-type  = p-obj-type
          temp-mask-range.obj-code  = p-obj-code
          temp-mask-range.lvl-decompose = p-lvl-decompose + 1
          v-mask  = v-mask + "0"
          v-mask0 = v-mask0 + "0"
          v-mask9 = v-mask9 + "9"
          .
          assign
          v-dec = decimal(v-mask0 + ".") no-error .
          if not error-status:error then
          assign
          temp-mask-range.first-code = decimal(v-mask0 + ".":U)
          temp-mask-range.last-code = decimal(v-mask9 + ".")
          temp-mask-range.to-check  = yes
          .
        end.
      end.
    end.
    for each temp-mask-range no-lock where
            temp-mask-range.mask-num = p-mask-num
        AND temp-mask-range.lvl-decompose = p-lvl-decompose + 1:
      if index(temp-mask-range.mask, "*":U) > 0 then
      run decompose-mask in this-procedure (
                                               input temp-mask-range.mask-num
                                              ,input temp-mask-range.mask
                                              ,input temp-mask-range.mask-original
                                              ,input temp-mask-range.lvl-decompose
                                              ,input temp-mask-range.host-code
                                              ,input temp-mask-range.obj-type
                                              ,input temp-mask-range.obj-code  ).
    end.
  end.
end procedure.
procedure check-mask-correct-ho-join :
define input parameter p-emitent-host-code like ub.dis-card-mask.emitent-host-code no-undo .
define input parameter p-type              like ub.dis-card-mask.type no-undo .
define input parameter p-new-mask          like ub.dis-card-mask.mask      no-undo .
define input parameter p-new-host-code     like ub.dis-card-mask.host-code no-undo .
define input parameter p-new-obj-type      like ub.dis-card-mask.obj-type  no-undo .
define input parameter p-new-obj-code      like ub.dis-card-mask.obj-code  no-undo .
define output parameter p-is-correct as logical no-undo .
define variable v-found as logical no-undo .
define buffer buf_temp-mask-range for temp-mask-range.
define buffer buf_dis-card-mask for ub.dis-card-mask.
  do
  on error undo, return error
  :
    for each temp-mask-range:
      delete temp-mask-range.
    end.
    for each buf_dis-card-mask no-lock where
            buf_dis-card-mask.emitent-host-code = p-emitent-host-code
        AND buf_dis-card-mask.type = p-type
        AND buf_dis-card-mask.stts = integer('0':U)
        :
      if buf_dis-card-mask.use-on = integer('1':U) then NEXT.
      run decompose-mask in this-procedure (
                                               input buf_dis-card-mask.mask-num
                                              ,input buf_dis-card-mask.mask
                                              ,input buf_dis-card-mask.mask
                                              ,input 0
                                              ,input buf_dis-card-mask.host-code
                                              ,input buf_dis-card-mask.obj-type
                                              ,input buf_dis-card-mask.obj-code  ).
    end.
    if p-new-mask <> "":U then do:
      run decompose-mask in this-procedure (
                                               input 0
                                              ,input p-new-mask
                                              ,input p-new-mask
                                              ,input 0
                                              ,input p-new-host-code
                                              ,input p-new-obj-type
                                              ,input p-new-obj-code   ).
    end.
    for each temp-mask-range no-lock where
            temp-mask-range.to-check = yes
    break
    by temp-mask-range.host-code
    by temp-mask-range.obj-type
    by temp-mask-range.obj-code:
      for each buf_temp-mask-range where
             buf_temp-mask-range.to-check = yes
         AND
             (buf_temp-mask-range.first-code >= temp-mask-range.first-code
         AND buf_temp-mask-range.first-code <= temp-mask-range.last-code)
         OR
             (buf_temp-mask-range.last-code >= temp-mask-range.first-code
         AND buf_temp-mask-range.last-code <= temp-mask-range.last-code):
        if recid(buf_temp-mask-range) = recid(temp-mask-range) then Next.
        if temp-mask-range.host-code <> 0
        and (buf_temp-mask-range.host-code = temp-mask-range.host-code
        AND buf_temp-mask-range.obj-type = temp-mask-range.obj-type
        AND buf_temp-mask-range.obj-code = temp-mask-range.obj-code) then NEXT.
        assign
        v-found = yes.
        return substitute("Могут существовать номера карт, удовлетворяющих маске &1 по фирме &2 объект &3 и маске &4 по фирме &5 объект &6"
                           , temp-mask-range.mask-original
                           , temp-mask-range.host-code
                           , (temp-mask-range.obj-type + string(temp-mask-range.obj-code))
                           , buf_temp-mask-range.mask-original
                           , buf_temp-mask-range.host-code
                           , (buf_temp-mask-range.obj-type + string(buf_temp-mask-range.obj-code))
                              ).
      end.
    end.
    assign
    p-is-correct = yes.
  end.
end procedure.
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info3 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info3, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info3, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info3 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info3, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info3, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info3, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info3, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info3, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info3, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info3 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info3, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info3 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE VAR-ENTRY as character no-undo .
DEFINE VARIABLE jj as integer no-undo .
define variable v-r-b-code like ub.currency.curr-code.
define variable v-curr-r-b as character no-undo .
define variable v-glob-curr-code like ub.currency.curr-code no-undo .
define variable glob-val as logical no-undo .
define variable vardeleted   as logical   no-undo.
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-ok as logical no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-cmd-proc-handle as handle no-undo .
define variable v-command as character no-undo .
define variable v-cmp as logical no-undo .
define variable v-cmp-loc as logical no-undo .
define variable v-last as integer no-undo .
define variable v-rec-ord as integer no-undo .
define buffer buf_Dis-card-type for ub.dis-card-type.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_db for ub.db.
define buffer buf_hist-nws-option for ub.hist-nws-option.
define buffer buf0_hist-nws-option for ub.hist-nws-option.
define buffer last_hist-nws-option for ub.hist-nws-option.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_tt0-dis-dct-rule for tt0-dis-dct-rule.
define buffer term_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card for ub.dis-card.
if g#db-num > 0  then do:
  message  vss-workfile vss-revision vss-description skip
          "Вызов процедуры в УБД запрещен"
  view-as alert-box ERROR.
  return error '':u.
end.
if par-mode <> 'ДОБАВЛЕНИЕ':U AND par-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр par-mode - " par-mode
  view-as alert-box error .
  return error '':u.
end.
if p-type = "" then do:
  message "Тип дисконтной карты не может быть пустым"
  view-as alert-box error .
  var-entry = "type":U.
  return error VAR-ENTRY.
end.
if p-type begins '@' then do:
  message "Тип дисконтной карты не может начинаться с символа @"
  view-as alert-box error .
  var-entry = "type":U.
  return error VAR-ENTRY.
end.
if p-emitent-host-code <> 0 and not can-find( first ub.sysconf No-LOCK WHERE
                       ub.sysconf.host-code = p-emitent-host-code) then do:
  message "Нет фирмы-эмитента дисконтной карты" p-emitent-host-code
  view-as alert-box error .
  var-entry = "emitent-host-code":U.
  return error var-entry.
end.
if pardflt-credit-card AND p-emitent-host-code = 0 then do:
  message
  "Глобальная дисконтная карта не может быть кредитной"
  view-as alert-box error .
  var-entry = "dflt-credit-card":U.
  return error var-entry.
end.
if pardflt-credit-card and parlim-kr <= 0 then do:
  message "Если дисконтная карта кредитная, лимит кредита должен быть положительным"
  view-as alert-box error .
  var-entry = "lim-kr":U.
  return error var-entry.
end.
if pardflt-credit-card and pardflt-debet-card then do:
  message "Карта не может быть одновременно и кредитной и дебетовой" skip
  view-as alert-box error .
  var-entry = "dflt-credit-card":U.
  return error var-entry.
end.
if not pardflt-credit-card
AND not pardflt-debet-card
and (parfiscal-pay
     or
     parmixed-pay)
then do:
  message "Свойста <Фискальный платеж> и <Разрешена смешанная оплата> имеют смысл только для кредитной или дебетовой карты" skip
  view-as alert-box error .
  var-entry = (if parfiscal-pay then "fiscal-pay":U else "mixed-pay":U).
  return error var-entry.
end.
if not pardflt-credit-card
AND not pardflt-debet-card
and parpay-code <> 0  then do:
  message "Свойство <Тип кассового платежа> имеет смысл только для кредитной или дебетовой карты" skip
  view-as alert-box error .
  var-entry = "pay-code":U.
  return error var-entry.
end.
if (pardflt-credit-card
or pardflt-debet-card)
and parpay-code = 0  then do:
  message "Для кредитной или дебетовой карты надо ввести код платежа" skip
  view-as alert-box error .
  var-entry = "pay-code":U.
  return error var-entry.
end.
if parpay-code <> 0 then do:
   run get-r-b in this-procedure (input p-emitent-host-code, output v-r-b-code) no-error .
  find first  buf_cash-pay no-lock where
            buf_cash-pay.cdpay-code = parpay-code
        AND buf_cash-pay.curr-code = v-r-b-code no-error .
  if not available buf_cash-pay then do:
    message substitute("Не найден тип кассового платежа с кодом &1 и кодом валюты &2", parpay-code, v-r-b-code) skip
    view-as alert-box error .
    var-entry = "pay-code":U.
    return error var-entry.
  end.
  if buf_Cash-pay.is-debet-card = no then do:
    message substitute("Тип кассового платежа для кредитной или дебетовой карты должен иметь свойство <РАСЧЕТНАЯ КАРТА>: тип кассового платежа с кодом &1 и кодом валюты &2", parpay-code, v-r-b-code) skip
    view-as alert-box error .
    var-entry = "pay-code":U.
    return error var-entry.
  end.
  if pardflt-credit-card = yes and buf_Cash-pay.is-credit = no then do:
    message substitute("Тип кассового платежа для кредитной карты должен иметь свойство <В КРЕДИТ>: тип кассового платежа с кодом &1 и кодом валюты &2", parpay-code, v-r-b-code) skip
    view-as alert-box error .
    var-entry = "pay-code":U.
    return error var-entry.
  end.
end.
if parcardname-sent <> 'card':U
and parcardname-sent <> 'name':U then do:
  message
  substitute("Неверное значение свойства карты <ДЕРЖАТЕЛЬ КАРТЫ на кассе>: &1, может быть только &2 или &3"
             ,parcardname-sent
             ,'ФИО':U
             ,'N карты':U
             ) skip
  view-as alert-box error .
  var-entry = "cardname-sent":U.
  return error var-entry.
end.
define variable V-VALUE-CHARACTER as character no-undo .
define variable v-ii as integer no-undo .
define variable V-STORAGE-PLACE as character no-undo .
define variable v-dtm-code as integer no-undo .
define variable V-SUM-ID as character no-undo .
define variable V-CALLER-ID as character no-undo .
define variable glog as logical no-undo .
do v-ii = 1 to num-entries(PARCUSTOM-SENT):
  assign
  v-value-character = entry(v-ii, PARCUSTOM-SENT)
  v-storage-place = entry(1, v-value-character, chr(4))
  v-dtm-code = integer(entry(2, v-value-character, chr(4)))
  no-error .
  if v-value-character = chr(63) then next.
  find first TT0-HIST-NWS-OPTION WHERE
            TT0-HIST-NWS-OPTION.db-num = 0
        and tt0-hist-nws-option.table-name = v-STORAGE-PLACE
        and tt0-hist-nws-option.obj-type = '':U
        and tt0-hist-nws-option.obj-code = 0
        and tt0-hist-nws-option.key#_one = V-dtm-code
        and tt0-hist-nws-option.subject-group = 'c-dc-hist':U NO-ERROR.
  IF AVAILABLE TT0-HIST-NWS-OPTION
  AND TT0-HIST-NWS-OPTION.SMART-NWS >= 0 THEN DO:
    message
    substitute("Для пересылки на кассу выбран срез/итог объекта-операнда&1&2&1" +
               "Однако для этого операнда включена настройка смарт-пересылки через СПН:&1" +
               "в нескольких или во всех УБД данные обновляться не будут&1" +
               "Вы уверены, что хотите пересылать на кассу данный срез/итог?"
               , chr(10)
               ,dct-algo_custom-sent-description(v-value-character)
                 )
    view-as alert-box question buttons yes-no
    update glog.
    if not glog then do:
      undo, return error ''.
    end.
  END.
END.
if entry (lookup (string(parcard-media), '0,1,2,3,4,5,6':U), 'Карта c магн.полосой,ТМ ключ,Смарт карта,Радио карта,Карта со штрихкодом,EASY FUEL,EasyFuel2':U) = "":U then do:
  message
  substitute("Неверный носитель для карты: &1"
             ,parcard-media
             ) skip
  view-as alert-box error .
  var-entry = "card-media":U.
  return error var-entry.
end.
if parcard-media = integer('5':U) then do:
define variable is-ef-chr as character no-undo .
define variable conf-type as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ef'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output is-ef-chr
  ,output conf-type
  ) no-error .
  if error-status:error
  or logical(is-ef-chr) = no then do:
    message
    substitute("В Вашей конфигурации нельзя ввести тип ДК с типом носителя &1,&2" +
              "так как не включен конфигурационный параметр is-ef"
              ,'EASY FUEL':U
              ,chr(10)
              )
    view-as alert-box .
    undo, return error .
  end.
end.
if par-mode = 'ИЗМЕНЕНИЕ':U then do:
  FIND FIRST buf_dis-card-type share-lock where
            recid(buf_dis-card-type) = par-rid No-ERROR.
  if not available buf_dis-card-type then do:
    message
    substitute("Не найден тип ДК recid &1", par-rid)
    view-as alert-box error .
    return error '':u.
  end.
  if buf_dis-card-type.card-media <> parcard-media
  and (buf_dis-card-type.card-media = integer('5':U)
       or
       parcard-media = integer('5':U))
  then do:
    find first buf_dis-card no-lock where
              buf_dis-card.type = par-type
          and buf_dis-card.emitent-host-code = p-emitent-host-code no-error.
    if available buf_dis-card then do:
       message
       "Нельзя сменить тип носителя" skip
       "В системе имеются ДК данного типа"
       view-as alert-box  error.
       return error "card-media".
    end.
  end.
end.
if lookup(string(pardflt-d-pcnt-method),
          string('1':U + chr(44) + '2':U + chr(44) + '3':U)
         ) = 0 then do:
  message
  "Неверное значение кода использования скидки"
  view-as alert-box error .
  var-entry = "dflt-d-pcnt-method":U.
  return error var-entry.
end.
DO jj = 1 to num-entries(pardcbyshop):
  find first ub.shop No-LOCK WHERE
             ub.shop.obj-code = integer(entry(jj, pardcbyshop)) NO-ERROR.
  if not avail ub.shop or (p-emitent-host-code > 0 and ub.shop.host-code <> p-emitent-host-code) then do:
    message "В списке магазинов принимающие только СВОИ карты есть неверный код магазина " entry(jj, pardcbyshop)
    view-as alert-box error .
    var-entry = "lim-kr":U.
    return error var-entry.
  end.
END.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
if pardflt-d-pcnt-method  = integer('2':U)
OR pardflt-d-pcnt-method  = integer('3':U)  then do:
  message
  "ВНИМАНИЕ!" SKIP
  "Использование скидок на итог имеет смысл только при условии применения POS NCR или IBS TH POS" SKIP
  "Продолжить?"
  view-as alert-box QUESTION Buttons YES-NO
  update loc#log .
  if not loc#log then do:
    var-entry = "dflt-d-pcnt-method":U.
    return error var-entry.
  end.
end.
if parcheck-by-mask
and parho-join then do:
  run check-mask-correct-ho-join in this-procedure (
                                                input p-emitent-host-code
                                              ,input p-type
                                              ,input "":U
                                              ,input 0
                                              ,input "":U
                                              ,input 0
                                              ,output v-ok
                                              ) no-error .
  if error-status:error then do:
    message substitute("Невозможно установить для ДК свойство&1<Проверка № карт по маске> с опцией <Привязка к фирме/объекту:&1&2 &3"
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
                            )
    view-as alert-box error .
    var-entry = "mask":U.
    undo, return error var-entry.
  end.
  if not v-ok then do:
    message substitute("Невозможно установить для ДК свойство&1<Проверка № карт по маске> с опцией <Привязка к фирме/объекту:&1&2"
                            , chr(10)
                            , return-value
                            )
    view-as alert-box error .
    var-entry = "mask":U.
    undo, return error var-entry.
  end.
end.
for each tt0-root-dis-card-type:
  delete tt0-root-dis-card-type.
end.
_MAIN:
do transaction
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
   if not valid-handle(v-cmd-proc-handle ) then dO:
    run nws/cmd-bush.p persistent set v-cmd-proc-handle no-error .
    if error-status :error
    then do:
      delete procedure v-cmd-proc-handle .
      undo _main, return error substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                          "&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,chr(10)
                                          ,error-status:get-message(1)
                                          ,return-value ).
    end.
  end.
  assign
  v-command =  substitute("&2&1&3&1&4"
                         , chr(6)
                         , 'cmd-dct-send':U
                         , p-emitent-host-code
                         , p-type
                         ).
  run begin-create-command in v-cmd-proc-handle
    (input v-command
    ,input "":U
    ,output v-cmd-code
    ) no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании команды &1", 'cmd-dct-send':U ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    delete procedure v-cmd-proc-handle .
    undo _main, return error return-value .
  end.
  create tt0-root-dis-card-type.
  if par-mode = 'ДОБАВЛЕНИЕ':U then do:
    if can-find( FIRST ub.dis-card-type No-LOCK where
                      ub.dis-card-type.emitent-host-code = p-emitent-host-code AND
                      ub.dis-card-type.type = p-type AND
                      ub.dis-card-type.host-code = parhost-code AND
                      ub.dis-card-type.obj-type = parobj-type AND
                      ub.dis-card-type.obj-code = parobj-code
                        ) then do:
      delete procedure v-cmd-proc-handle .
      message (if p-emitent-host-code = 0
              then "Уже есть такой тип глобальной дисконтной карты "
              else ("Уже есть такой тип дисконтной карты на фирме " + string(p-emitent-host-code)))
      view-as alert-box ERROR .
      var-entry = "type":U.
      undo _main, return error var-entry.
    end.
    if can-find( FIRST ub.dis-card-type No-LOCK where
                      ub.dis-card-type.type = p-type AND
                      ub.dis-card-type.host-code = parhost-code AND
                      ub.dis-card-type.obj-type = parobj-type AND
                      ub.dis-card-type.obj-code = parobj-code ) then do:
      delete procedure v-cmd-proc-handle .
      message "Уже есть такой тип дисконтной карты "
              (if p-emitent-host-code = 0
              then " - глобальный "
              else (" - на фирме " + string(p-emitent-host-code)))
      view-as alert-box ERROR .
      var-entry = "type":U.
      undo _main, return error var-entry.
    end.
    CREATE buf_dis-card-type.
    assign
    buf_dis-card-type.emitent-host-code = p-emitent-host-code
    buf_dis-card-type.type = p-type
    buf_dis-card-type.host-code = parhost-code
    buf_dis-card-type.obj-type = parobj-type
    buf_dis-card-type.obj-code = parobj-code
    par-rid = recid( buf_dis-card-type )
    .
    define variable v-uniq-key-rec as character no-undo .
    run gen-key-rec in this-procedure ( input 'dis-card-type':U
                                      ,input buffer buf_dis-card-type:handle
                                      ,output v-uniq-key-rec).
    assign
    buf_dis-card-type.uniq-key-rec = v-uniq-key-rec
    p-uniq-key-rec = v-uniq-key-rec
    .
  end.
  else do:
    FIND FIRST buf_dis-card-type exclusive-lock where
              recid(buf_dis-card-type) = par-rid No-ERROR.
    if not available buf_dis-card-type then return error '':u.
    if buf_dis-card-type.uniq-key-rec <> p-uniq-key-rec then do:
      delete procedure v-cmd-proc-handle .
      message
      substitute("Неверное значение параметра p-uniq-key-rec &1", p-uniq-key-rec)
      view-as alert-box error.
      undo _main, return error .
    end.
    buffer-copy buf_dis-card-type to tt0-root-dis-card-type.
  end.
  assign
  buf_dis-card-type.d-pcnt-byshop = pard-pcnt-byshop
  buf_dis-card-type.dflt-d-pcnt-method = pardflt-d-pcnt-method
  buf_dis-card-type.dflt-credit-card = pardflt-credit-card
  buf_dis-card-type.dflt-debet-card = pardflt-debet-card
  buf_dis-card-type.dflt-staff-card = pardflt-staff-card
  buf_dis-card-type.fiscal-pay = parfiscal-pay
  buf_dis-card-type.mixed-pay = parmixed-pay
  buf_dis-card-type.card-media = parcard-media
  buf_dis-card-type.cardname-sent = parcardname-sent
  buf_dis-card-type.custom-sent = parcustom-sent
  buf_dis-card-type.pay-code = parpay-code
  buf_dis-card-type.lim-kr = parlim-kr
  buf_dis-card-type.dc-pfx = pardc-pfx
  buf_dis-card-type.dcbyshop = pardcbyshop
  buf_dis-card-type.check-by-mask = (if parcheck-by-mask then 1 else 0)
  buf_dis-card-type.ho-join = (if parho-join then 1 else 0)
  .
  buffer-compare tt0-root-dis-card-type to buf_dis-card-type
  case-sensitive
  save result in v-cmp-loc.
  v-cmp = v-cmp and v-cmp-loc.
  if not v-cmp-loc then do:
     buffer-copy buf_dis-card-type to tt0-root-dis-card-type .
    run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'dis-card-type':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_dis-card-type:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-card-type':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
  end.
  release buf_dis-card-type no-error .
  if error-status:error then do:
    delete procedure v-cmd-proc-handle .
    message
    "Ошибка при сохранении записи ТИП ДИСКОНТНОЙ КАРТЫ" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo _main, return error .
  end.
  for each buf_tt0-dis-dct-rule
    on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    ON STOP undo _MAIN, return error '':u:
    if not (buf_tt0-dis-dct-rule.discnt-role = 'def-pcnt':U
            or
            buf_tt0-dis-dct-rule.discnt-role = 'def-cash-pcnt':U
            or
            buf_tt0-dis-dct-rule.discnt-role = 'def-categ':U) then next.
    find first buf_dis-dct-rule where
            buf_dis-dct-rule.emitent-host-code = buf_tt0-dis-dct-rule.emitent-host-code
        and buf_dis-dct-rule.type = buf_tt0-dis-dct-rule.type
        and buf_dis-dct-rule.host-code = buf_tt0-dis-dct-rule.host-code
        and buf_dis-dct-rule.obj-type = buf_tt0-dis-dct-rule.obj-type
        and buf_dis-dct-rule.obj-code = buf_tt0-dis-dct-rule.obj-code
        and buf_dis-dct-rule.pos-type = buf_tt0-dis-dct-rule.pos-type
        and buf_dis-dct-rule.discnt-role = buf_tt0-dis-dct-rule.discnt-role
        and buf_dis-dct-rule.nonunique = buf_tt0-dis-dct-rule.nonunique
        no-error.
    if not available buf_dis-dct-rule then do:
      v-cmp-loc = no.
      create buf_dis-dct-rule.
      buffer-copy buf_tt0-dis-dct-rule to buf_dis-dct-rule.
    end.
    else do:
      buffer-compare
      buf_tt0-dis-dct-rule except emitent-host-code type
      to buf_dis-dct-rule
      case-sensitive
      save result in v-cmp-loc.
      if not v-cmp-loc then do:
        assign
        buf_dis-dct-rule.rule-num = buf_tt0-dis-dct-rule.rule-num
        buf_dis-dct-rule.rl-root = buf_tt0-dis-dct-rule.rl-root
        buf_dis-dct-rule.templ-rl-root = buf_tt0-dis-dct-rule.templ-rl-root
        buf_dis-dct-rule.time-templ-rl-root = buf_tt0-dis-dct-rule.time-templ-rl-root
        buf_dis-dct-rule.nonunique = buf_tt0-dis-dct-rule.nonunique
        .
      end.
    end.
    if not v-cmp-loc then do:
      run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'dis-dct-rule':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_dis-dct-rule:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-dct-rule':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    end.
  end.
  _dis-dct-rule:
  for each buf_dis-dct-rule where
            buf_dis-dct-rule.emitent-host-code = p-emitent-host-code
        and buf_dis-dct-rule.type = p-type
  on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  ON STOP undo _MAIN, return error '':u:
    if not (buf_dis-dct-rule.discnt-role = 'def-pcnt':U
            or
            buf_dis-dct-rule.discnt-role = 'def-cash-pcnt':U
            or
            buf_dis-dct-rule.discnt-role = 'def-categ':U) then next.
     if not pard-pcnt-byshop and
     not ( buf_dis-dct-rule.host-code = 0
           and
           buf_dis-dct-rule.obj-type = '':U
           and
           buf_dis-dct-rule.obj-code = 0) then do:
         run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'dis-dct-rule':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_dis-dct-rule:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-dct-rule':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
       delete buf_dis-dct-rule.
       next _dis-dct-rule.
     end.
     find first buf_tt0-dis-dct-rule where
            buf_tt0-dis-dct-rule.emitent-host-code = buf_dis-dct-rule.emitent-host-code
        and buf_tt0-dis-dct-rule.type = buf_dis-dct-rule.type
        and buf_tt0-dis-dct-rule.host-code = buf_dis-dct-rule.host-code
        and buf_tt0-dis-dct-rule.obj-type = buf_dis-dct-rule.obj-type
        and buf_tt0-dis-dct-rule.obj-code = buf_dis-dct-rule.obj-code
        and buf_tt0-dis-dct-rule.pos-type = buf_dis-dct-rule.pos-type
        and buf_tt0-dis-dct-rule.discnt-role = buf_dis-dct-rule.discnt-role
        and buf_tt0-dis-dct-rule.nonunique = buf_dis-dct-rule.nonunique
        no-error .
     if not available buf_tt0-dis-dct-rule then do:
         run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'dis-dct-rule':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_dis-dct-rule:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-dct-rule':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
       delete buf_dis-dct-rule.
     end.
  end.
  if pard-pcnt-byshop = no then do:
    for each term_dis-card-type where
            term_dis-card-type.emitent-host-code = p-emitent-host-code
        and term_dis-card-type.type = p-type
  on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  ON STOP undo _MAIN, return error '':u:
    if term_dis-card-type.host-code = 0
    and term_dis-card-type.obj-type = '':U
    and term_dis-card-type.obj-code = 0 then next.
         run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'dis-card-type':U                                                                                          ,input '+delete'                                                                                         ,input buffer term_dis-card-type:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-card-type':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
       delete term_dis-card-type.
     end.
  end.
  else do:
    for each buf_dis-dct-rule where
              buf_dis-dct-rule.emitent-host-code = p-emitent-host-code
          and buf_dis-dct-rule.type = p-type
    on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    ON STOP undo _MAIN, return error '':u:
      if not (buf_dis-dct-rule.discnt-role = 'def-pcnt':U
              or
              buf_dis-dct-rule.discnt-role = 'def-cash-pcnt':U
              or
              buf_dis-dct-rule.discnt-role = 'def-categ':U) then next.
      if ( buf_dis-dct-rule.host-code = 0
            and
            buf_dis-dct-rule.obj-type = '':U
            and
            buf_dis-dct-rule.obj-code = 0) then do:
        next.
      end.
      v-cmp-loc = yes.
      find first term_dis-card-type where
                term_dis-card-type.emitent-host-code = p-emitent-host-code
            and term_dis-card-type.type = p-type
            and term_dis-card-type.host-code = buf_Dis-dct-rule.host-code
            and term_dis-card-type.obj-type = buf_Dis-dct-rule.obj-type
            and term_dis-card-type.obj-code = buf_Dis-dct-rule.obj-code
      no-error .
      if not available term_dis-card-type then do:
        v-cmp-loc = no.
        create term_dis-card-type.
        buffer-copy tt0-root-dis-card-type
        except host-code obj-type obj-code
        to term_dis-card-type
        assign
        term_dis-card-type.host-code = buf_dis-dct-rule.host-code
        term_dis-card-type.obj-type = buf_dis-dct-rule.obj-type
        term_dis-card-type.obj-code = buf_dis-dct-rule.obj-code
        .
        run gen-key-rec in this-procedure ( input 'dis-card-type':U
                                          ,input buffer term_dis-card-type:handle
                                          ,output term_dis-card-type.uniq-key-rec).
      end.
      v-cmp = v-cmp and v-cmp-loc.
      if not v-cmp-loc then do:
                run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'dis-card-type':U                                                                                          ,input '+update'                                                                                         ,input buffer term_dis-card-type:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-card-type':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
      end.
    end.
  end.
  for each buf_db no-lock,
     each buf_hist-nws-option where
            buf_hist-nws-option.db-num = buf_db.db-num
        and buf_hist-nws-option.subject-group = 'c-dc-hist':U
        and buf_hist-nws-option.host-code = p-emitent-host-code
        AND buf_hist-nws-option.charkey_one = p-type
        AND buf_hist-nws-option.obj-type = '':U
        AND buf_hist-nws-option.obj-code = 0
    on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    ON STOP undo _MAIN, return error '':u:
    find first tt0-hist-nws-option no-lock where
              tt0-hist-nws-option.db-num = 0
          and tt0-hist-nws-option.table-name = buf_hist-nws-option.table-name
          and tt0-hist-nws-option.host-code = buf_hist-nws-option.host-code
          AND tt0-hist-nws-option.charkey_one = buf_hist-nws-option.charkey_one
          AND tt0-hist-nws-option.obj-type = buf_hist-nws-option.obj-type
          AND tt0-hist-nws-option.obj-code = buf_hist-nws-option.obj-code
          AND tt0-hist-nws-option.key#_one = buf_hist-nws-option.key#_one no-error .
    if not available tt0-hist-nws-option then do:
         run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'hist-nws-option':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_hist-nws-option:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'hist-nws-option':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
      delete buf_hist-nws-option.
    end.
   end.
  for each tt0-hist-nws-option
  on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  ON STOP undo _MAIN, return error '':u:
    for each buf_db no-lock
    on ERROR UNDO _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    ON STOP undo _MAIN, return error '':u:
      find first buf_hist-nws-option where
                buf_hist-nws-option.db-num = buf_db.db-num
            and buf_hist-nws-option.table-name = tt0-hist-nws-option.table-name
            and buf_hist-nws-option.host-code = tt0-hist-nws-option.host-code
            AND buf_hist-nws-option.charkey_one = tt0-hist-nws-option.charkey_one
            AND buf_hist-nws-option.obj-type = tt0-hist-nws-option.obj-type
            AND buf_hist-nws-option.obj-code = tt0-hist-nws-option.obj-code
            AND buf_hist-nws-option.key#_one = tt0-hist-nws-option.key#_one no-error .
      if not available buf_hist-nws-option
      then do:
        find first buf_hist-nws-option where
                  buf_hist-nws-option.db-num = 0
              and buf_hist-nws-option.table-name = tt0-hist-nws-option.table-name
              and buf_hist-nws-option.host-code = tt0-hist-nws-option.host-code
              AND buf_hist-nws-option.charkey_one = tt0-hist-nws-option.charkey_one
              AND buf_hist-nws-option.obj-type = tt0-hist-nws-option.obj-type
              AND buf_hist-nws-option.obj-code = tt0-hist-nws-option.obj-code
              AND buf_hist-nws-option.key#_one = tt0-hist-nws-option.key#_one no-error .
        if available buf_hist-nws-option then do:
          v-last = buf_hist-nws-option.hn-id.
        end.
        else do:
          v-last = next-value(s-hn-id, ub).
          create buf0_hist-nws-option.
          assign
          buf0_hist-nws-option.db-num = 0
          buf0_hist-nws-option.table-name = tt0-hist-nws-option.table-name
          buf0_hist-nws-option.host-code = tt0-hist-nws-option.host-code
          buf0_hist-nws-option.charkey_one = tt0-hist-nws-option.charkey_one
          buf0_hist-nws-option.obj-type = tt0-hist-nws-option.obj-type
          buf0_hist-nws-option.obj-code = tt0-hist-nws-option.obj-code
          buf0_hist-nws-option.key#_one = tt0-hist-nws-option.key#_one
          buf0_hist-nws-option.option-descr = tt0-hist-nws-option.option-descr
          buf0_hist-nws-option.subject-group = 'c-dc-hist':U
          buf0_hist-nws-option.hn-id = v-last
          buf0_hist-nws-option.hist-from-prim = tt0-hist-nws-option.hist-from-prim
          buf0_hist-nws-option.hist-to-nws = tt0-hist-nws-option.hist-to-nws
          buf0_hist-nws-option.nws-to-cd = tt0-hist-nws-option.nws-to-cd
          buf0_hist-nws-option.nws-to-hist = tt0-hist-nws-option.nws-to-hist
          buf0_hist-nws-option.smart-nws = tt0-hist-nws-option.smart-nws
          buf0_hist-nws-option.get-hist-from-nws =  tt0-hist-nws-option.get-hist-from-nws
          .
         run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'hist-nws-option':U                                                                                          ,input '+update'                                                                                         ,input buffer buf0_hist-nws-option:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'hist-nws-option':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
        end.
        assign
        v-cmp-loc = no
        v-cmp = v-cmp and v-cmp-loc
        .
        if buf_db.db-num > 0 then do:
          create buf_hist-nws-option.
          assign
          buf_hist-nws-option.db-num = buf_db.db-num
          buf_hist-nws-option.table-name = tt0-hist-nws-option.table-name
          buf_hist-nws-option.host-code = tt0-hist-nws-option.host-code
          buf_hist-nws-option.charkey_one = tt0-hist-nws-option.charkey_one
          buf_hist-nws-option.obj-type = tt0-hist-nws-option.obj-type
          buf_hist-nws-option.obj-code = tt0-hist-nws-option.obj-code
          buf_hist-nws-option.key#_one = tt0-hist-nws-option.key#_one
          buf_hist-nws-option.option-descr = tt0-hist-nws-option.option-descr
          buf_hist-nws-option.subject-group = 'c-dc-hist':U
          buf_hist-nws-option.hn-id = v-last
          .
        end.
      end.
      if available buf_hist-nws-option then do:
        buffer-compare tt0-hist-nws-option
        except db-num hn-id
        to buf_hist-nws-option
        case-sensitive
        save result in v-cmp-loc.
        buffer-copy tt0-hist-nws-option except hn-id db-num
        to buf_hist-nws-option
        .
        if not v-cmp-loc then do:
                run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'hist-nws-option':U                                                                                          ,input '+update'                                                                                         ,input buffer buf_hist-nws-option:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo _main, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'hist-nws-option':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
        end.
      end.
    end.
  end.
  run rul/ruprcall.p (
                       input 'dis-card-type':U
                      ,input p-uniq-key-rec
                      ,input ('rp-by-call':U + chr(44) + 'rule-by-call':U + chr(44) + 'rule-call-param':U)
                      ,input v-cmd-proc-handle
                      ,input v-cmd-code
                      ,INPUT TABLE tt0-rp-by-call
                      ,INPUT TABLE tt0-rule-by-call
                      ,INPUT TABLE tt0-rule-call-param) no-error .
  if error-status:error then do:
    delete procedure v-cmd-proc-handle .
    message
    "Ошибка при сохранении привязок профайлов и/правил для записи ТИП ДИСКОНТНОЙ КАРТЫ" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo _main, return error .
  end.
  define variable v-db-list as character no-undo .
  for each buf_db no-lock
  where buf_db.db-num > 0
  :
    assign
    v-db-list = v-db-list + chr(1) + string(buf_db.db-num).
  end.
  v-db-list = trim(v-db-list, chr(1)).
  run send-command in v-cmd-proc-handle
    ( input v-cmd-code
      ,input v-db-list
      ) no-error .
  if error-status:error then do:
    delete procedure v-cmd-proc-handle .
    message
    vss-workfile vss-revision vss-description skip
    substitute( "Ошибка при отсылке команды &1", 'cmd-dct-send':U ) skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
    undo _main, return error .
  end.
  delete procedure v-cmd-proc-handle .
END.
RETURN '':u.
PROCEDURE get-r-b :
define input parameter p-emitent-host-code like ub.dis-card.emitent-host-code no-undo .
DEFINE OUTPUT PARAMETER p-r-b-curr-code LIKE ub.currency.curr-code NO-UNDO.
define variable v-curr-r-b  as character no-undo .
DEFINE BUFFER buf_sysconf FOR ub.sysconf.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  ) no-error .
if p-emitent-host-code = 0
and v-curr-r-b = 'base':U
then do:
  ASSIGN
  p-r-b-curr-code = 0
  .
end.
else do:
  IF p-emitent-host-code = 0 or
     v-curr-r-b = 'rubl':U
     THEN DO:
        ASSIGN
        p-r-b-curr-code = 0
        .
    END.
    ELSE DO:
       FIND FIRST buf_sysconf NO-LOCK WHERE
                 buf_sysconf.host-code = p-emitent-host-code .
       ASSIGN
       p-r-b-curr-code = buf_sysconf.base-code
        .
  END.
end.
END PROCEDURE.
