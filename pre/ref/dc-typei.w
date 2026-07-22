DEFINE TEMP-TABLE temp-dc-type NO-UNDO LIKE ub.dis-card-type.
DEFINE TEMP-TABLE tt-2-hist-nws-option NO-UNDO LIKE ub.hist-nws-option.
DEFINE TEMP-TABLE tt-rp-by-call NO-UNDO LIKE ub.rp-by-call.
DEFINE TEMP-TABLE tt-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt0-dis-dct-rule NO-UNDO LIKE ub.dis-dct-rule.
DEFINE TEMP-TABLE tt0-hist-nws-option NO-UNDO LIKE ub.hist-nws-option.
DEFINE TEMP-TABLE tt0-rp-by-call NO-UNDO LIKE ub.rp-by-call.
DEFINE TEMP-TABLE tt0-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt2-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE BUFFER X_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as char no-undo.
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input-output param rid as recid init ? no-undo.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Карточка типа дисконтной карты" .
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE fill-tt0-hist-nws-option :
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-type as character no-undo .
define buffer  buf_tt0-hist-nws-option for tt0-hist-nws-option.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-table-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-label0 AS CHARACTER NO-UNDO.
define variable v-region as character no-undo .
DEFINE VARIABLE v-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-done AS CHARACTER NO-UNDO.
define variable v-hn-id as integer no-undo .
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
FOR EACH buf_prop-head NO-LOCK WHERE
    buf_prop-head.general CONTAINS  'dis-card-type':U
    and
    buf_prop-head.general-view CONTAINS  'dis-card-type':U
ON ERROR UNDO, RETURN ERROR :
    v-label0 = buf_prop-head.prop-label.
    v-done = '':U.
    v-table-name = '':U.
   _v-ii:
   DO v-ii = 1 TO 3:
     IF v-ii = 1 THEN do:
        v-table-name = buf_prop-head.storage-place.
        v-label = substitute("&1_", v-label0).
        v-region = "".
     END.
     IF v-ii = 2 THEN do:
        v-table-name = buf_prop-head.storage-place-host.
        v-label = substitute("&1_Фирма", v-label0).
        v-region = "Фирма".
     END.
     IF v-ii = 3 THEN do:
        v-table-name = buf_prop-head.storage-place-obj.
        v-label = substitute("&1_Объект", v-label0).
        v-region = "Объект".
     END.
     IF v-table-name = '':U
     OR v-table-name = ?
     OR v-table-name = chr(63) THEN NEXT _v-ii.
     IF v-table-name > '':U and LOOKUP(v-table-name, v-done) = 0
     THEN do:
       FIND FIRST buf_tt0-hist-nws-option WHERE
                buf_tt0-hist-nws-option.db-num = 0
            AND buf_tt0-hist-nws-option.table-name = v-table-name
            and buf_tt0-hist-nws-option.host-code = p-emitent-host-code
            and buf_tt0-hist-nws-option.obj-type = '':U
            and buf_tt0-hist-nws-option.obj-code = 0
            and buf_tt0-hist-nws-option.key#_one = buf_prop-head.dtm-code
            and buf_tt0-hist-nws-option.charkey_one = p-type no-error.
       if not available buf_tt0-hist-nws-option then do:
         create buf_tt0-hist-nws-option.
         assign
         buf_tt0-hist-nws-option.db-num = 0
         buf_tt0-hist-nws-option.table-name = v-table-name
         buf_tt0-hist-nws-option.host-code = p-emitent-host-code
         buf_tt0-hist-nws-option.obj-type = '':U
         buf_tt0-hist-nws-option.obj-code = 0
         buf_tt0-hist-nws-option.key#_one = buf_prop-head.dtm-code
         buf_tt0-hist-nws-option.charkey_one = p-type
         buf_tt0-hist-nws-option.get-hist-from-nws = buf_prop-head.get-hist-from-nws
         buf_tt0-hist-nws-option.hist-to-nws = buf_prop-head.hist-to-nws
         buf_tt0-hist-nws-option.nws-to-hist = buf_prop-head.nws-to-hist
         buf_tt0-hist-nws-option.hist-from-prim = buf_prop-head.hist-from-prim
         buf_tt0-hist-nws-option.nws-to-cd = buf_prop-head.nws-to-cd
         buf_tt0-hist-nws-option.smart-nws = buf_prop-head.smart-nws
         buf_tt0-hist-nws-option.get-hist-from-nws = buf_prop-head.get-hist-from-nws
         buf_tt0-hist-nws-option.subject-group = 'c-dc-hist':U
         buf_tt0-hist-nws-option.option-desc = v-label
         buf_tt0-hist-nws-option.hn-id = v-hn-id
         v-hn-id = v-hn-id + 1
         .
      END.
      else do:
        if entry(num-entries(buf_tt0-hist-nws-option.option-desc, "_")
                  , buf_tt0-hist-nws-option.option-desc
                  , "_") <> v-region
          or v-ii = 1 then do:
          v-label = substitute("&1/&2"
                                , buf_tt0-hist-nws-option.option-desc
                                , (if v-ii = 1
                                    then "_Глобально"
                                    else (if v-ii = 2
                                        then "_Фирма"
                                        else "_Объект"
                                        )
                                  )
                                ).
          assign
          buf_tt0-hist-nws-option.option-desc = v-label
          .
        end.
      end.
    end.
    IF v-table-name > '':U and LOOKUP(v-table-name, v-done) > 0
    THEN do:
       FIND FIRST buf_tt0-hist-nws-option WHERE
                buf_tt0-hist-nws-option.db-num = 0
            AND buf_tt0-hist-nws-option.table-name = v-table-name
            and buf_tt0-hist-nws-option.host-code = p-emitent-host-code
            and buf_tt0-hist-nws-option.obj-type = '':U
            and buf_tt0-hist-nws-option.obj-code = 0
            and buf_tt0-hist-nws-option.key#_one = buf_prop-head.dtm-code
            and buf_tt0-hist-nws-option.charkey_one = p-type no-error.
       if available buf_tt0-hist-nws-option then do:
        if entry(num-entries(buf_tt0-hist-nws-option.option-desc, "_")
                , buf_tt0-hist-nws-option.option-desc
                , "_") <> v-region
        or v-ii = 1 then do:
          v-label = substitute("&1/&2"
                                , buf_tt0-hist-nws-option.option-desc
                                , (if v-ii = 1
                                    then "_Глобально"
                                    else (if v-ii = 2
                                        then "_Фирма"
                                        else "_Объект"
                                        )
                                  )
                                ).
          assign
          buf_tt0-hist-nws-option.option-desc = v-label
          .
        end.
      end.
    end.
    v-done = v-done + chr(44) + v-table-name.
  END.
END.
END PROCEDURE.
define variable old-emitent-host-code like ub.dis-card-type.emitent-host-code no-undo.
define variable v-r-b-code like ub.currency.curr-code no-undo .
define variable v-curr-r-b  as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION calldscr returns character ( input p-call-id as character):
define variable v-descr as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo.
define variable v-prop-label as character no-undo .
define variable v-node-label as character no-undo .
define variable v-dt-code as integer no-undo .
define variable v-host-code as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-label as character no-undo .
define variable v-node-code as integer no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-map for ub.prop-map.
run gen-key-fv in this-procedure ( input p-call-id
                                  ,output v-field-list
                                  ,output v-value-list) no-error .
if error-status:error then return p-call-id.
CASE entry(1, p-call-id, chr(3)):
  when 'dis-card-type':U then do:
    v-descr = substitute("Тип ДК: эмитент &1 тип: &2"
                         ,integer(entry(lookup("emitent-host-code", v-field-list, chr(3)), v-value-list, chr(3)) )
                         ,entry(lookup("type", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'dis-card':U then do:
    v-descr = substitute("ДК: № &1"
                         ,entry(lookup("d-card", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'dis-card-property':U then do:
    v-dt-code = integer(entry(lookup("dt-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-node-code = integer(entry(lookup("node-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-host-code = integer(entry(lookup("host-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-obj-type = entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3)) .
    v-obj-code = integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    find first buf_prop-ref no-lock where
              buf_prop-ref.dt-code = v-dt-code no-error .
    if available buf_prop-ref then do:
      find first buf_prop-head no-lock where
                buf_prop-head.dtm-code = buf_prop-ref.dtm-code no-error .
      v-prop-label = buf_prop-head.prop-label.
      find first buf_prop-map no-lock where
                buf_prop-map.dtm-code = buf_prop-ref.dtm-code
            and buf_prop-map.node-code = v-node-code no-error .
      if available buf_prop-map then do:
        v-label = buf_prop-map.node-label.
      end.
    end.
    v-descr = substitute("ДК: № &1 &2:&3 &4"
                         ,entry(lookup("d-card", v-field-list, chr(3)), v-value-list, chr(3))
                         ,v-prop-label
                         ,v-label
                         ,get-region(v-host-code, v-obj-type, v-obj-code)
                         ).
  end.
  when 'clients':U then do:
    v-descr = substitute("&1&2"
                         ,entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3))
                         ,integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) )
                         ).
  end.
  when 'ext-system':U then do:
    v-descr = substitute("Внешняя система &1"
                         ,integer(entry(lookup("esys-id", v-field-list, chr(3)), v-value-list, chr(3)))
                         ).
  end.
  WHEN 'thbj-attr':U then do:
    if entry(lookup("upper-prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rum':U
    or entry(lookup("upper-prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rum_obj':U
    then do:
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'goods':U then do:
        v-descr = "Операции с товарами".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'clients':U then do:
        v-descr = "Операции с клиентами".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'gds-grp':U then do:
        v-descr = "Операции с группами товаров".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'cli-grp':U then do:
        v-descr = "Операции с группами клиентов".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'chk-doc_ibs-th':U then do:
        v-descr = "Операции с чеками на POS IBS-TH".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'chk-doc_ibs-th-mob':U then do:
        v-descr = "Операции с чеками на POS IBS-TH-MOB".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'edoc':U then do:
        v-descr = "Операции в системе электронного документооборота".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'thref':U then do:
        v-descr = "Операции со справочниками".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'pdf':U then do:
        v-descr = "Операции с ДНЦ и переоценками".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rep':U then do:
        v-descr = "Отчеты".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'ord':U then do:
        v-descr = "Операции с заказами".
      end.
    end.
  end.
  when 'cash-desk':U then do:
    v-descr = substitute("БД &1 Маг &2 Касса № &4 &3"
                         ,entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("cash-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("pos-type", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'ext-file':U then do:
    v-descr = substitute("БД &1 Файл № &3 (из БД &2)"
                         ,entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("from-db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("file-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
end case.
return v-descr.
end function.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE dc-typei_fill-table :
define input  parameter p-mode as character no-undo .
define input  parameter p-silent as logical   no-undo .
define output parameter f-dflt-pcnt as decimal no-undo .
define output parameter f-dflt-cash-pcnt as decimal no-undo .
define output parameter f-dflt-pcnt-kat as integer   no-undo .
DEFINE VARIABLE v-dct-algo-call-id AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_hist-nws-option FOR ub.hist-nws-option.
DEFINE BUFFER buf_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER buf_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
DEFINE BUFFER buf_rule-by-profile FOR ub.rule-by-profile.
DEFINE BUFFER buf_rule-call-param FOR ub.rule-call-param.
DEFINE BUFFER buf_dis-dct-rule FOR ub.dis-dct-rule.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
fill-block:
do
on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
:
IF p-mode <> 'ДОБАВЛЕНИЕ':U THEN DO:
  FOR EACH buf_hist-nws-option  NO-LOCK WHERE
        buf_hist-nws-option.db-num = 0
    AND buf_hist-nws-option.host-code = temp-dc-type.emitent-host-code
    AND buf_hist-nws-option.obj-type = '':U
    AND buf_hist-nws-option.obj-code = 0
    and buf_hist-nws-option.charkey_one = temp-dc-type.TYPE
    and buf_hist-nws-option.subject-group = 'c-dc-hist':U
    and buf_hist-nws-option.host-code = temp-dc-type.emitent-host-code
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
    CREATE tt0-hist-nws-option.
    BUFFER-COPY buf_hist-nws-option TO tt0-hist-nws-option.
  END.
  FOR EACH buf_dis-dct-rule NO-LOCK WHERE
          buf_dis-dct-rule.TYPE = temp-dc-type.TYPE
       AND buf_dis-dct-rule.emitent-host-code = temp-dc-type.emitent-host-code
      on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
      :
    CREATE tt0-dis-dct-rule.
    BUFFER-COPY buf_dis-dct-rule TO tt0-dis-dct-rule.
    if (buf_dis-dct-rule.discnt-role = 'def-pcnt':U
        or
        buf_dis-dct-rule.discnt-role = 'def-cash-pcnt':U
        or
        buf_dis-dct-rule.discnt-role = 'def-categ':U) then do:
      IF buf_dis-dct-rule.host-code = 0
      AND buf_dis-dct-rule.obj-type = '':U
      AND buf_dis-dct-rule.obj-code = 0 THEN DO:
        FIND FIRST buf_dis-rule NO-LOCK WHERE
                  buf_dis-rule.rule-num = buf_dis-dct-rule.rule-num NO-ERROR.
        IF AVAILABLE buf_Dis-rule THEN DO:
          CASE buf_dis-dct-rule.discnt-role:
            WHEN 'def-pcnt':U THEN DO:
                f-dflt-pcnt = buf_Dis-rule.discnt-value.
            END.
              WHEN 'def-cash-pcnt':U THEN DO:
                f-dflt-cash-pcnt = buf_Dis-rule.discnt-value.
              END.
              WHEN 'def-categ':U THEN DO:
                f-dflt-pcnt-kat = buf_Dis-rule.dis-kat.
              END.
          END CASE.
        END.
      END.
    end.
    release tt0-dis-dct-rule.
  END.
  FOR EACH buf_rp-by-call NO-LOCK WHERE
           buf_rp-by-call.call_id = temp-dc-type.uniq-key-rec
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
    CREATE tt0-rp-by-call.
    BUFFER-COPY buf_rp-by-call TO tt0-rp-by-call.
  END.
  FOR EACH buf_rule-by-call  NO-LOCK WHERE
            buf_rule-by-call.call_id = temp-dc-type.uniq-key-rec
  on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
  :
    CREATE tt0-rule-by-call.
    BUFFER-COPY buf_rule-by-call TO tt0-rule-by-call.
    FOR EACH buf_rule-call-param NO-LOCK WHERE
          buf_rule-call-param.codex_id = tt0-rule-by-call.codex_id
      AND buf_rule-call-param.ruleset_id = tt0-rule-by-call.ruleset_id
      AND buf_rule-call-param.call_id = tt0-rule-by-call.call_id
      AND buf_rule-call-param.order_id = tt0-rule-by-call.order_id
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
      CREATE tt0-rule-call-param.
      BUFFER-COPY buf_rule-call-param TO tt0-rule-call-param.
    END.
  END.
END.
IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
  FOR EACH buf_rule-profile NO-LOCK WHERE
            buf_rule-profile.profile-type = 'dis-card-type':U
       AND buf_rule-profile.IS_dynamic = no
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
    run dc-typei_proc-b-addalgo in this-procedure (  input p-silent
                                                    ,input yes
                                                    ,buffer buf_rule-profile) no-error .
    if error-status:error then do:
      undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
  END.
  _rule-profile:
  FOR EACH buf_rule-profile NO-LOCK WHERE
            buf_rule-profile.profile-type = 'dis-card-type':U
       AND buf_rule-profile.IS_dynamic = ?
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
    if buf_rule-profile.param-code <> '':U then do:
      define variable v-par-val as character no-undo .
      define variable v-par-type as character no-undo .
      if buf_rule-profile.param-code = 'sys-key' then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-par-val
  ) no-error .
        if error-status:error then do:
          message
          substitute("Ошибка при определении значения конфигурационного параметра &1,&2" +
                      "который должен быть включен для работы профайла &3"
                      ,buf_rule-profile.param-code
                      ,chr(10)
                      ,buf_rule-profile.profile_id)
          view-as alert-box error .
          next.
        end.
      end.
      else do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  buf_rule-profile.param-code
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-par-val
  ,output v-par-type
  ) no-error .
        if error-status:error then do:
          message
          substitute("Ошибка при определении значения конфигурационного параметра &1,&2" +
                      "который должен быть включен для работы профайла &3"
                      ,buf_rule-profile.param-code
                      ,chr(10)
                      ,buf_rule-profile.profile_id)
          view-as alert-box error .
          next.
        end.
      end.
      if lookup(v-par-val, buf_rule-profile.param-value, chr(4)) = 0
      and not (buf_rule-profile.param-code = 'sys-key'
                and
                v-par-val = 'IBS')
      then do:
        next _rule-profile.
      end.
      if buf_rule-profile.param-code = 'sys-key'
      and v-par-val = 'IBS' then next _rule-profile.
    end.
    run dc-typei_proc-b-addalgo in this-procedure (  input p-silent
                                           ,input yes
                                           ,buffer buf_rule-profile) no-error .
    if error-status:error then do:
      undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
  END.
  run fill-tt0-hist-nws-option in this-procedure ( input 0
                                                  ,input ''
                                                  ) no-error .
  if error-status:error then do:
    undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
END.
end.
END PROCEDURE.
procedure dc-typei_proc-b-addalgo :
define input  parameter p-silent as logical   no-undo .
define input  parameter p-start as logical   no-undo .
DEFINE PARAMETER BUFFER buf_rule-profile FOR ub.rule-profile.
DEFINE VARIABLE v-order-id AS INTEGER NO-UNDO.
define variable v-rule-uniq-key-rec as character no-undo .
define variable v-dcta-uniq-key-rec as character no-undo .
define variable v-found-params as logical no-undo .
define variable v-found-can-calc as logical no-undo .
define variable v-disabled as logical no-undo .
define variable glog as logical no-undo .
define variable v-once-more as integer no-undo .
define variable v-par-val as character no-undo .
define variable v-par-type as character no-undo .
define variable v-rule-profile-uniq-key-rec as character no-undo .
DEFINE BUFFER buf_tt0-rp-by-call FOR tt0-rp-by-call.
DEFINE BUFFER buf_rule-by-profile FOR ub.rule-by-profile.
DEFINE BUFFER buf_rule FOR ub.RULE.
DEFINE BUFFER buf_tt0-rule-by-call FOR tt0-rule-by-call.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict2 for ub.ruledict.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_ruledict-param2 for ub.ruledict-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
main-block:
do
on error undo, return error return-value
:
FIND LAST buf_tt0-rp-by-call NO-LOCK WHERE
          buf_tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec
      AND buf_tt0-rp-by-call.profile_id = buf_rule-profile.profile_id NO-ERROR.
IF AVAILABLE buf_tt0-rp-by-call THEN DO:
  v-once-more = buf_tt0-rp-by-call.once-more.
  if buf_rule-profile.is_dynamic = no
  or buf_rule-profile.reusable-params = '-':U
  then do:
   RETURN ERROR substitute("алгоритм &1 уже подключен к данному типу ДК", buf_rule-profile.is_dynamic).
  end.
  v-disabled = yes.
  for each buf_rule-by-profile no-lock where
         buf_rule-by-profile.profile_id = buf_rule-profile.profile_id,
     first buf_rule no-lock where
          buf_rule.rule_id = buf_rule-by-profile.rule_id:
     v-disabled = v-disabled and (buf_rule.reusable-params = "-":U).
  end.
  if v-disabled then do:
    RETURN ERROR substitute( "Алгоритм &1 уже подключен к типу ДК &2&3" +
                             "В нем нет ни одного правила, которое можно выполнить повторно"
                             , buf_rule-profile.is_dynamic
                             , temp-dc-type.type
                             , chr(10)
                             ).
  end.
  else do:
    if not p-silent then do:
      MESSAGE
      "Данный алгоритм уже подключен к данному типу ДК" skip
      "Выполнение привязанных к нему правил повторно возможно только при указании соответствущих значений параметров" skip
      "Все равно подключить алгоритм"
      VIEW-AS ALERT-BOX question buttons YES-NO update glog.
      if not glog then    RETURN ERROR.
    end.
    else do:
      return error substitute("Алгоритм &1 уже подключен к типу ДК &2&3"  +
                              "Выполнение привязанных к нему правил повторно возможно только при указании соответствущих значений параметров"
                              ,buf_rule-profile.is_dynamic
                              ,temp-dc-type.type
                              , chr(10)
                              ).
    end.
  end.
  if buf_rule-profile.param-code <> '':U then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  buf_rule-profile.param-code
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-par-val
  ,output v-par-type
  ) no-error .
    if error-status:error then do:
      undo main-block, return error
      substitute("Ошибка при определении значения конфигурационного параметра &1,&2" +
                  "который должен быть включен для работы профайла &3"
                  ,buf_rule-profile.param-code
                  ,chr(10)
                  ,buf_rule-profile.profile_id).
    end.
    if lookup(v-par-val, buf_rule-profile.param-value, chr(4)) = 0 then do:
      undo main-block, return error
      substitute("Значения конфигурационного параметра &1=&2,&3" +
                  "что не удовлетворяет условиям работы профайла &4"
                  ,buf_rule-profile.param-code
                  ,v-par-val
                  ,chr(10)
                  ,buf_rule-profile.profile_id).
    end.
  end.
END.
define variable v-ps as character no-undo .
if not p-silent then do:
  run gbl/d-prompt.w (
    'title=':u + "Комментарий к привязке" + '\':u
  + 'text1=':u + "Вы можете добавить поясняющий комментарий"  + '\':u
  + 'format=' + "X(256)" + '\':u
  + 'type=' + 'EDIT' + '\':u
  + 'fillin_row=2\':u
  + 'fillin_col=4\':u
  + 'fillin_width=70\':u
  + 'fillin_height=4\':u
  + 'max-chars=280\':u
  + 'readonly=no' +  '\':u
  , input-output v-ps
      ).
end.
CREATE buf_tt0-rp-by-call.
BUFFER-COPY buf_rule-profile TO buf_tt0-rp-by-call
ASSIGN
buf_tt0-rp-by-call.CALL_id = temp-dc-type.uniq-key-rec
buf_tt0-rp-by-call.once-more = v-once-more + 1
buf_tt0-rp-by-call.ps = v-ps
.
for each tt2-rule-call-param:
  delete tt2-rule-call-param.
end.
_rule-by-profile:
FOR EACH buf_rule-by-profile NO-LOCK WHERE
        buf_rule-by-profile.profile_id = buf_tt0-rp-by-call.profile_id
BY buf_rule-by-profile.profile_id
BY buf_rule-by-profile.codex_id
BY buf_rule-by-profile.ruleset_id
BY buf_rule-by-profile.rp_order_id
ON error undo, return error :
 FIND FIRST buf_rule NO-LOCK WHERE
                buf_rule.RULE_id = buf_rule-by-profile.RULE_id NO-ERROR.
 IF NOT AVAILABLE buf_rule THEN DO:
   undo main-block, return error
   SUBSTITUTE("Не найдено правило &1, которое должно быть подключено по алгоритму &2&3" +
                   "кодекс правил &4, свод правил &5"
                   , buf_rule-by-profile.RULE_id
                   , buf_rule-by-profile.profile_id
                   , chr(10)
                   , buf_rule-by-profile.codex_id
                   , buf_rule-by-profile.ruleset_id).
 END.
  FIND LAST buf_tt0-rule-by-call WHERE
            buf_tt0-rule-by-call.codex_id =  buf_rule-by-profile.codex_id
        AND buf_tt0-rule-by-call.ruleset_id = buf_rule-by-profile.ruleset_id
  USE-INDEX imain NO-ERROR.
  IF AVAILABLE buf_tt0-rule-by-call THEN DO:
     v-order-id = buf_tt0-rule-by-call.order_id + 1.
  END.
  ELSE DO:
     v-order-id = 0.
  END.
  CREATE buf_tt0-rule-by-call.
  BUFFER-COPY buf_rule-by-profile TO buf_tt0-rule-by-call
  ASSIGN
  buf_tt0-rule-by-call.order_id = v-order-id
  buf_tt0-rule-by-call.algo-des = substitute("Профайл &1. &2", buf_rule-profile.profile_id, buf_rule.NAME)
  buf_tt0-rule-by-call.is_dynamic = buf_rule-by-profile.IS_dynamic
  buf_tt0-rule-by-call.can-calc = (IF buf_tt0-rule-by-call.is_dynamic
                                     THEN buf_rule-by-profile.dflt-can-calc
                                     ELSE YES)
  buf_tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec
  buf_tt0-rule-by-call.once-more = v-once-more + 1
  v-found-can-calc = v-found-can-calc or buf_tt0-rule-by-call.can-calc
  .
  find first buf_ruledict no-lock where
          buf_ruledict.entry-type = 'rule':U
      and  buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.
  run gen-key-rec in this-procedure (
                                     input  'rule-profile':U
                                    ,input buffer buf_rule-profile:handle
                                    ,output v-rule-profile-uniq-key-rec).
  find first buf_ruledict2 no-lock where
          buf_ruledict2.entry-type = 'rule-profile':U
      and  buf_ruledict2.uniq-key-rec = v-rule-profile-uniq-key-rec.
  for each buf_ruledict-param no-lock where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id
  on error undo, return error:
  find first buf_rp-rule-param no-lock where
            buf_rp-rule-param.profile_id = buf_rule-profile.profile_id
        and buf_rp-rule-param.rule-param-name = buf_ruledict-param.param-name
        and buf_rp-rule-param.codex_id = buf_rule-by-profile.codex_id
        and buf_rp-rule-param.ruleset_id = buf_rule-by-profile.ruleset_id
        and buf_rp-rule-param.rule_id = buf_rule-by-profile.rule_id
        and buf_rp-rule-param.rp_order_id = buf_rule-by-profile.rp_order_id.
    find first buf_ruledict-param2 no-lock where
          buf_ruledict-param2.entry-id = buf_ruledict2.entry-id
      and buf_ruledict-param2.param-name = buf_rp-rule-param.rp-param-name.
    create buf_tt0-rule-call-param.
    assign
    buf_tt0-rule-call-param.codex_id = buf_tt0-rule-by-call.codex_id
    buf_tt0-rule-call-param.ruleset_id = buf_tt0-rule-by-call.ruleset_id
    buf_tt0-rule-call-param.call_id  = buf_tt0-rule-by-call.call_id
    buf_tt0-rule-call-param.order_id = buf_tt0-rule-by-call.order_id
    buf_tt0-rule-call-param.rule_id = buf_rule.rule_id
    buf_tt0-rule-call-param.param-name = buf_ruledict-param.param-name
    buf_tt0-rule-call-param.p-index = 0
    buf_tt0-rule-call-param.param-des = buf_ruledict-param.documentation
    buf_tt0-rule-call-param.param-num = buf_ruledict-param.param-num
    buf_tt0-rule-call-param.param-label = buf_ruledict-param.param-label
    buf_tt0-rule-call-param.param-mode = buf_ruledict-param.param-mode
    buf_tt0-rule-call-param.param-data-type = buf_ruledict-param.param-data-type
    buf_tt0-rule-call-param.param-2-data-type = buf_ruledict-param.param-2-data-type
    buf_tt0-rule-call-param.param-3-data-type = buf_ruledict-param.param-3-data-type
    buf_tt0-rule-call-param.param-value-character = buf_ruledict-param2.init-value-character
    buf_tt0-rule-call-param.param-value-date = buf_ruledict-param2.init-value-date
    buf_tt0-rule-call-param.param-value-decimal = buf_ruledict-param2.init-value-decimal
    buf_tt0-rule-call-param.param-value-integer = buf_ruledict-param2.init-value-integer
    buf_tt0-rule-call-param.param-value-logical = buf_ruledict-param2.init-value-logical
    buf_tt0-rule-call-param.profile_id          = buf_tt0-rule-by-call.profile_id
    buf_tt0-rule-call-param.once-more           = buf_tt0-rule-by-call.once-more
    .
    if buf_ruledict-param.param-2-data-type = "r-b" then do:
      buf_tt0-rule-call-param.param-value-character = (if v-curr-r-b = 'rubl':U
                                                       then 'rubl':U
                                                       else 'base':U).
    end.
    assign
    v-found-params = yes.
    create tt2-rule-call-param.
    buffer-copy buf_tt0-rule-call-param to tt2-rule-call-param.
    release tt2-rule-call-param.
  end.
END.
if v-found-params
and v-found-can-calc = yes
and not p-start
and not p-silent
then do:
 define variable v-param-form as character no-undo .
  assign
  v-param-form = (if buf_rule-profile.custom-param-form > 0
                  then  substitute("rul/rcps-&1.w", buf_rule-profile.profile_id)
                  else "ref/rulercps.w")
  .
  run value(v-param-form) (
                       input parparentproc
                      ,input this-procedure:handle
                      ,input "b-chg":U
                      ,input 'ДОБАВЛЕНИЕ':U
                      ,input 'rp-rule-param':U
                      ,input buf_tt0-rp-by-call.profile_id
                      ,input buf_tt0-rp-by-call.once-more
                      ,input buf_tt0-rp-by-call.call_id
                      ,input 0
                      ,input 0
                      ,INPUT 0
                      ,input 0
                      ,INput substitute("алгоритм &1 &2"
                                       , buf_rule-profile.name
                                       , calldscr(buf_tt0-rp-by-call.call_id)
                                       )
                      ,input-output table tt2-rule-call-param) no-error.
  if not error-status:error then do:
    for each tt2-rule-call-param
    on error undo, return error:
      find first buf_tt0-rule-call-param where
                buf_tt0-rule-call-param.call_id = tt2-rule-call-param.call_id
            and buf_tt0-rule-call-param.codex_id = tt2-rule-call-param.codex_id
            and buf_tt0-rule-call-param.ruleset_id = tt2-rule-call-param.ruleset_id
            and buf_tt0-rule-call-param.order_id = tt2-rule-call-param.order_id
            and buf_tt0-rule-call-param.param-name = tt2-rule-call-param.param-name
            and buf_tt0-rule-call-param.p-index = tt2-rule-call-param.p-index no-error .
      if not available buf_tt0-rule-call-param
      and lookup("LIST", tt2-rule-call-param.param-3-data-type) > 0
      then do:
        create buf_tt0-rule-call-param.
      end.
      buffer-copy tt2-rule-call-param to buf_tt0-rule-call-param.
      delete tt2-rule-call-param.
    end.
  end.
end.
end.
end procedure.
define variable add-option as character no-undo.
DEFINE VARIABLE v-mode AS CHARACTER NO-UNDO EXTENT 3.
DEFINE VARIABLE rule-display-option AS CHARACTER NO-UNDO.
define variable v-start as logical no-undo .
FUNCTION get-profile-dynamic RETURNS LOGICAL
  ( p-profile_id AS INTEGER )  FORWARD.
FUNCTION get-profile-name RETURNS CHARACTER
  ( p-profile_id AS INTEGER )  FORWARD.
DEFINE MENU MENU-B-rule
       MENU-ITEM m_text         LABEL "Текст"
       MENU-ITEM m_graph        LABEL "Граф"          .
DEFINE BUTTON b-addalgo
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-cashpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-cd
     LABEL "На кассу"
     SIZE 10 BY 1.
DEFINE BUTTON b-d-pcnt-byshop
     LABEL "Все скидки по умолч."
     SIZE 22 BY 1.
DEFINE BUTTON B-dcbyshop
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-def-cash-pcnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-def-categ
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-def-pcnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-delalgo
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-disc
     LABEL "Пр-ла скидок"
     SIZE 15 BY 1.
DEFINE BUTTON B-emitent
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-history
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-hn
     LABEL "Маршрутиз. и ист."
     SIZE 20 BY 1.
DEFINE BUTTON B-mask
     LABEL "&Маски"
     SIZE 10 BY 1.
DEFINE BUTTON b-params
     LABEL "Параметры"
     SIZE 10 BY 1.
DEFINE BUTTON b-prop-ref
     LABEL "Итоги/Срезы"
     SIZE 15 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-rule
     LABEL "Правило"
     SIZE 10 BY 1.
DEFINE BUTTON b-rule-on-off
     LABEL "Вкл"
     SIZE 5 BY 1.
DEFINE BUTTON B-ruleset
     LABEL "Т-ка вызова"
     SIZE 14 BY 1.
DEFINE VARIABLE E-rule-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.17
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE emitent-name AS CHARACTER FORMAT "X(25)":U
      VIEW-AS TEXT
     SIZE 47.88 BY 1 NO-UNDO.
DEFINE VARIABLE f-cash-pay-name LIKE ub.cash-pay.obj-name
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE f-dflt-cash-pcnt AS DECIMAL FORMAT "->>9.99" INITIAL 0
     LABEL "%скидки по умолч. на итог чека"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 TOOLTIP "Используется только для POS NCR и IBS TH POS".
DEFINE VARIABLE f-dflt-pcnt AS DECIMAL FORMAT "->>9.99" INITIAL 0
     LABEL "%скидки по умолч. на товары"
     VIEW-AS FILL-IN
     SIZE 7 BY 1.
DEFINE VARIABLE f-dflt-pcnt-kat AS INTEGER FORMAT ">9" INITIAL 0
     LABEL "Катег. по умолч."
     VIEW-AS FILL-IN
     SIZE 6 BY 1.
DEFINE VARIABLE var-r-b-abbr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 9.5 BY 1 NO-UNDO.
DEFINE VARIABLE Rs-algo-profile AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2"
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE rs-algo-types AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Настраив.", 2
     SIZE 18 BY .75 NO-UNDO.
DEFINE VARIABLE v-dflt-d-pcnt-method AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 4", "3"
     SIZE 39.88 BY .88 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 74.5 BY 2.54.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 74.25 BY 3.79.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23 BY 4.75.
DEFINE VARIABLE T-check-by-mask AS LOGICAL INITIAL no
     LABEL "Пров. № ДК по маске"
     VIEW-AS TOGGLE-BOX
     SIZE 22.5 BY .75 TOOLTIP "Проверка номеров при вводе ДК по маске, действующей на фирме/объекте" NO-UNDO.
DEFINE VARIABLE T-ho-join AS LOGICAL INITIAL no
     LABEL "Привязка по фирме/объекту"
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY 1 NO-UNDO.
DEFINE QUERY br-profile FOR
      tt0-rp-by-call SCROLLING.
DEFINE QUERY br-rule-by-call FOR
      tt0-rule-by-call,
      X_rule-profile SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      temp-dc-type SCROLLING.
DEFINE BROWSE br-profile
  QUERY br-profile NO-LOCK DISPLAY
      tt0-rp-by-call.profile_id COLUMN-LABEL "Про!файл" FORMAT ">>9":U
get-profile-name ( INPUT tt0-rp-by-call.profile_id) COLUMN-LABEL "Название алгоритма" FORMAT "X(255)"
get-profile-dynamic ( INPUT tt0-rp-by-call.profile_id) COLUMN-LABEL "Отклю!чаемый" FORMAT "+/":U
tt0-rp-by-call.once-more COLUMN-LABEL "№ привязки" FORMAT ">9"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 5.75
         FONT 4 ROW-HEIGHT-CHARS .67.
DEFINE BROWSE br-rule-by-call
  QUERY br-rule-by-call NO-LOCK DISPLAY
      tt0-rule-by-call.can-calc COLUMN-LABEL "Вкл." FORMAT "+/":U
tt0-rule-by-call.algo-des COLUMN-LABEL "Описание алгоритма/правила" FORMAT "X(255)":U WIDTH 40
tt0-rule-by-call.is_dynamic COLUMN-LABEL "Отклю!чаемое?" FORMAT "+/":U
tt0-rule-by-call.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">,>>>,>>9":U
tt0-rule-by-call.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">,>>>,>>9":U
tt0-rule-by-call.order_id COLUMN-LABEL "Порядок!вызова" FORMAT ">>9":U WIDTH 9
tt0-rule-by-call.rule_id COLUMN-LABEL "Код!правила" FORMAT ">>>,>>>,>>9":U WIDTH 9
tt0-rule-by-call.profile_id COLUMN-LABEL "Алгоритм" FORMAT ">>9":U WIDTH 8
tt0-rule-by-call.once-more COLUMN-LABEL "№ привязки" FORMAT ">9"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 5.75
         FONT 4 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     b-quit AT ROW 1 COL 11.13
     B-mask AT ROW 1 COL 21
     b-hn AT ROW 1 COL 31
     b-cd AT ROW 1 COL 51 WIDGET-ID 10
     b-prop-ref AT ROW 1 COL 61 WIDGET-ID 8
     b-disc AT ROW 1 COL 76 WIDGET-ID 12
     B-history AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     temp-dc-type.type AT ROW 2.13 COL 10.25 COLON-ALIGNED
          LABEL "Тип карты"
          VIEW-AS FILL-IN
          SIZE 10 BY 1 TOOLTIP "Буквенно-цифровой код типа карты"
          FGCOLOR 4
     T-check-by-mask AT ROW 2.25 COL 23.5
     T-ho-join AT ROW 2.25 COL 47
     temp-dc-type.emitent-host-code AT ROW 3.38 COL 10.25 COLON-ALIGNED
          LABEL "Эмитент"
                  FORMAT ">>>>>>>>99"
          VIEW-AS FILL-IN
          SIZE 10 BY 1 TOOLTIP "Код фирмы эмитента или 0 (если карта глобальна)"
          FGCOLOR 4
     B-emitent AT ROW 3.42 COL 23.13
     f-dflt-pcnt AT ROW 4.46 COL 32 COLON-ALIGNED
     temp-dc-type.d-pcnt-byshop AT ROW 4.46 COL 47.5 WIDGET-ID 20
          LABEL "Скидка/катег. по объектам"
          VIEW-AS TOGGLE-BOX
          SIZE 27.63 BY 1 TOOLTIP "Процент скидки дифференциирован по объектам и фирмам"
     B-def-pcnt AT ROW 4.5 COL 41.5 WIDGET-ID 14
     b-d-pcnt-byshop AT ROW 4.5 COL 76 WIDGET-ID 24
     f-dflt-cash-pcnt AT ROW 5.46 COL 32 COLON-ALIGNED
     f-dflt-pcnt-kat AT ROW 5.46 COL 64 COLON-ALIGNED
     B-def-cash-pcnt AT ROW 5.5 COL 41.5 WIDGET-ID 16
     B-def-categ AT ROW 5.5 COL 72.5 WIDGET-ID 18
     v-dflt-d-pcnt-method AT ROW 6.58 COL 34.13 NO-LABEL
     b-addalgo AT ROW 7.67 COL 40
     b-delalgo AT ROW 7.67 COL 50
     b-params AT ROW 7.67 COL 60 WIDGET-ID 6
     B-rule AT ROW 7.67 COL 70
     B-ruleset AT ROW 7.67 COL 80 WIDGET-ID 26
     b-rule-on-off AT ROW 7.67 COL 94
     Rs-algo-profile AT ROW 7.75 COL 1 NO-LABEL WIDGET-ID 2
     rs-algo-types AT ROW 7.75 COL 22 NO-LABEL
     br-rule-by-call AT ROW 8.75 COL 1
     br-profile AT ROW 8.75 COL 1 WIDGET-ID 100
     E-rule-name AT ROW 14.75 COL 1 NO-LABEL
     temp-dc-type.dflt-credit-card AT ROW 17.13 COL 2
          LABEL "Кредитная карта"
          VIEW-AS TOGGLE-BOX
          SIZE 19.5 BY 1
     temp-dc-type.dflt-debet-card AT ROW 17.13 COL 24.5
          LABEL "Дебетовая карта"
          VIEW-AS TOGGLE-BOX
          SIZE 21 BY 1
     temp-dc-type.dflt-staff-card AT ROW 17.13 COL 46
          LABEL "Карта персонала"
          VIEW-AS TOGGLE-BOX
          SIZE 21 BY 1
     temp-dc-type.card-media AT ROW 18 COL 77 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Item 1", 1,
"Item 2", 2,
"Item 3", 3,
"Item 4", 4
          SIZE 21.5 BY 3.42
     temp-dc-type.lim-kr AT ROW 18.25 COL 24.5 COLON-ALIGNED
          LABEL "Лимит кредита по умолч."
          VIEW-AS FILL-IN
          SIZE 24.13 BY 1
     temp-dc-type.fiscal-pay AT ROW 19.5 COL 3
          LABEL "Фиск-ный пл-ж"
          VIEW-AS TOGGLE-BOX
          SIZE 16.5 BY 1
     temp-dc-type.mixed-pay AT ROW 19.5 COL 19.5
          LABEL "Разр.смеш.оплату"
          VIEW-AS TOGGLE-BOX
          SIZE 18.5 BY 1
     B-cashpay AT ROW 19.5 COL 46.5
     f-cash-pay-name AT ROW 19.5 COL 48 COLON-ALIGNED HELP
          "" NO-LABEL
     B-dcbyshop AT ROW 22 COL 72
     emitent-name AT ROW 3.38 COL 24.75 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     var-r-b-abbr AT ROW 18.25 COL 54.38 COLON-ALIGNED NO-LABEL
     temp-dc-type.dcbyshop AT ROW 22 COL 2 NO-LABEL
           VIEW-AS TEXT
          SIZE 69.5 BY 1
     "Использование процента скидки" VIEW-AS TEXT
          SIZE 30.63 BY 1 AT ROW 6.58 COL 2.75
     "Магазины, принимающие только СВОИ карты" VIEW-AS TEXT
          SIZE 52.25 BY 1 TOOLTIP "Магазины, принимающие только карты, выданные в этом же магазине" AT ROW 21 COL 2
     "Тип носителя" VIEW-AS TEXT
          SIZE 21.5 BY .67 AT ROW 17.29 COL 77
     "Платеж" VIEW-AS TEXT
          SIZE 7 BY 1 AT ROW 19.5 COL 40
     RECT-1 AT ROW 20.71 COL 1
     RECT-3 AT ROW 17 COL 1
     RECT-4 AT ROW 17 COL 76
     SPACE(0.00) SKIP(1.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тип дисконтной карты"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-rule:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-rule:HANDLE.
ASSIGN
       E-rule-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-cash-pay-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-dflt-cash-pcnt:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-dflt-pcnt:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
    rid = ?.
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-addalgo IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
run ref/rulprofs.w (
                     INPUT parparentproc
                    ,INPUT "b-sel"
                    ,INPUT 'dis-card-type':U
                    ,INPUT-OUTPUT v-ref-list) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-apply.
END.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          recid(buf_rule-profile) = INTEGER(v-ref-list) NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN NO-APPLY.
  RUN proc-b-addalgo IN THIS-PROCEDURE ( BUFFER buf_rule-profile) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF B-cashpay IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
 run ref/cashpays.w (
                 input parparentproc
                ,input "b-sel":U
                ,input 'все':U
                ,input parhost-code
                ,input parobj-type
                ,input parobj-code
                ,output v-rid-list ) .
  IF v-rid-list <> "":U THEN DO:
      FIND FIRST buf_cash-pay NO-LOCK WHERE
                recid(buf_cash-pay) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_cash-pay THEN DO:
          ASSIGN
          temp-dc-type.pay-code = 0
         f-cash-pay-name = "":U.
      END.
      ELSE DO:
          IF AVAILABLE buf_cash-pay
          AND buf_cash-pay.curr-code <> v-r-b-code THEN DO:
              MESSAGE
              substitute("Дебетовой или кредитовой карте для данного эмитента можно сопоставить тип кассового платежа только с кодом валюты &1", v-r-b-code)
              VIEW-AS ALERT-BOX ERROR.
              ASSIGN
              temp-dc-type.pay-code = 0
              f-cash-pay-name = "":U.
          END.
          ASSIGN
          temp-dc-type.pay-code = buf_cash-pay.cdpay-code
          f-cash-pay-name = buf_cash-pay.obj-name.
      END.
  END.
  DISPLAY
  f-cash-pay-name
  WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF b-cd IN FRAME Dialog-Frame
DO:
  define variable glog as logical no-undo .
  if p-mode <> 'ПРОСМОТР':U then do:
    message
    substitute("Внимание! Если Вы уже делали какие-либо изменения,&1" +
               "то перед настройкой данных, передаваемых на кассы&1"  +
               "рекомендуется сначала сохранить ТИП ДК&1&1" +
               "Все равно продолжить?"
               , chr(10))
    view-as alert-box warning buttons YES-NO update glog.
    if not glog then return no-apply.
  end.
  RUN proc-b-cd IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-d-pcnt-byshop IN FRAME Dialog-Frame
DO:
  run ref/dis-dcti.w ( INPUt parparentproc
                        ,INPUT p-mode
                        ,INPUT temp-dc-type.TYPE
                        ,INPUT temp-dc-type.emitent-host-code
                        ,INPUT parhost-code
                        ,INPUT parobj-type
                        ,INPUT parobj-code
                        ,INPUT 'bo':U
                        ,input ('def-pcnt':U + chr(44) +
                                'def-cash-pcnt':U + chr(44) +
                                'def-categ':U
                               )
                        ,INPUT-OUTPUT TABLE tt0-dis-dct-rule) NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
run proc-b-dis-dct-rule ( INPUT 'def-pcnt':U, input 'ПРОСМОТР':U) NO-ERROR.
run proc-b-dis-dct-rule ( INPUT 'def-cash-pcnt':U, input 'ПРОСМОТР':U) NO-ERROR.
run proc-b-dis-dct-rule ( INPUT 'def-categ':U, input 'ПРОСМОТР':U) NO-ERROR.
run dpcnt-byshop-enable-disable in this-procedure .
END.
ON CHOOSE OF B-dcbyshop IN FRAME Dialog-Frame
DO:
  run proc-dcbyshop no-error.
    if error-status:error then return no-apply.
END.
ON CHOOSE OF B-def-cash-pcnt IN FRAME Dialog-Frame
DO:
  run proc-b-dis-dct-rule ( INPUT 'def-cash-pcnt':U, input 'ИЗМЕНЕНИЕ':U) NO-ERROR.
  if error-status:error then return no-apply.
  APPLY "LEAVE" to temp-dc-type.emitent-host-code.
END.
ON CHOOSE OF B-def-categ IN FRAME Dialog-Frame
DO:
  run proc-b-dis-dct-rule ( INPUT 'def-categ':U, input 'ИЗМЕНЕНИЕ':U) NO-ERROR.
  if error-status:error then return no-apply.
  APPLY "LEAVE" to temp-dc-type.emitent-host-code.
END.
ON CHOOSE OF B-def-pcnt IN FRAME Dialog-Frame
DO:
  run proc-b-dis-dct-rule ( INPUT 'def-pcnt':U, input 'ИЗМЕНЕНИЕ':U) NO-ERROR.
  if error-status:error then return no-apply.
  APPLY "LEAVE" to temp-dc-type.emitent-host-code.
END.
ON CHOOSE OF b-delalgo IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  IF NOT AVAILABLE tt0-rp-by-call THEN RETURN NO-APPLY.
  run proc-b-delalgo IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  APPLY "value-changed" TO br-rule-by-call.
END.
ON CHOOSE OF b-disc IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-loc-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE temp-dc-type THEN RETURN NO-APPLY.
        run ref/dis-dcts.w (
                             INPUT parparentproc
                            ,INPUT '':U
                            ,INPUT (if p-mode = 'ПРОСМОТР':U
                                   then 'dis-card-type':U
                                   else ('dis-card-type':U   + chr(44) + "temp")
                                   )
                            ,input temp-dc-type.emitent-host-code
                            ,input temp-dc-type.type
                            ,input 0
                            ,input '':U
                            ,input 0
                            ,input 0
                            ,input '':U
                            ,input '':U
                            ,input 0
                            ,input-output v-loc-rid-list ) no-error.
END.
ON CHOOSE OF B-emitent IN FRAME Dialog-Frame
DO:
  run proc-b-emitent no-error.
  if error-status:error then return no-apply.
  APPLY "LEAVE" to temp-dc-type.emitent-host-code.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-history IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE ri-list AS CHARACTER NO-UNDO.
   run ref/dcctypes.w (
                   input parparentproc
                  ,input '':U
                  ,input  ?
                  ,input  ub.dis-card-type.emitent-host-code
                  ,input  parhost-code
                  ,input  parobj-type
                  ,input  parobj-code
                  ,input  dis-card-type.TYPE
                  ,input "one":U
                  ,input '':U
                  ,output ri-list ).
END.
ON CHOOSE OF b-hn IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
define buffer last_tt0-hist-nws-option for tt0-hist-nws-option.
FOR EACH tt-2-hist-nws-option:
  DELETE tt-2-hist-nws-option.
END.
FOR EACH tt0-hist-nws-option :
  CREATE tt-2-hist-nws-option.
  BUFFER-COPY tt0-hist-nws-option TO tt-2-hist-nws-option.
END.
run ref/dcta-1.w (
                INPUT parparentproc
               ,INPUT p-mode
               ,INPUT temp-dc-type.TYPE
               ,INPUT temp-dc-type.emitent-host-code
               ,INPUT-OUTPUT TABLE tt-2-hist-nws-option
               ,OUTPUT v-ok) NO-ERROR.
IF v-ok THEN DO:
   FOR EACH tt-2-hist-nws-option:
     FIND FIRST tt0-hist-nws-option WHERE
           tt0-hist-nws-option.db-num = tt-2-hist-nws-option.db-num
       and tt0-hist-nws-option.table-name = tt-2-hist-nws-option.table-name
       AND tt0-hist-nws-option.host-code = tt-2-hist-nws-option.host-code
       AND tt0-hist-nws-option.obj-type = tt-2-hist-nws-option.obj-type
       AND tt0-hist-nws-option.obj-code = tt-2-hist-nws-option.obj-code
       and tt0-hist-nws-option.key#_one = tt-2-hist-nws-option.key#_one
       and tt0-hist-nws-option.charkey_one = tt-2-hist-nws-option.charkey_one no-error.
     IF NOT AVAILABLE tt0-hist-nws-option THEN DO:
       find last last_tt0-hist-nws-option where
            last_tt0-hist-nws-option.db-num = tt-2-hist-nws-option.db-num no-error .
       CREATE tt0-hist-nws-option.
       ASSIGN
       tt0-hist-nws-option.db-num = tt-2-hist-nws-option.db-num
       tt0-hist-nws-option.table-name = tt-2-hist-nws-option.table-name
       tt0-hist-nws-option.host-code = tt-2-hist-nws-option.host-code
       tt0-hist-nws-option.obj-type = tt-2-hist-nws-option.obj-type
       tt0-hist-nws-option.obj-code = tt-2-hist-nws-option.obj-code
       tt0-hist-nws-option.key#_one = tt-2-hist-nws-option.key#_one
       tt0-hist-nws-option.charkey_one = tt-2-hist-nws-option.charkey_one
       tt0-hist-nws-option.option-descr = tt-2-hist-nws-option.option-descr
       tt0-hist-nws-option.hn-id = (if available last_tt0-hist-nws-option
                                    then (last_tt0-hist-nws-option.hn-id  + 1)
                                    else 1)
      .
      END.
      ASSIGN
      tt0-hist-nws-option.hist-to-nws = tt-2-hist-nws-option.hist-to-nws
      tt0-hist-nws-option.nws-to-hist = tt-2-hist-nws-option.nws-to-hist
      tt0-hist-nws-option.hist-from-prim = tt-2-hist-nws-option.hist-from-prim
      tt0-hist-nws-option.nws-to-cd = tt-2-hist-nws-option.nws-to-cd
      tt0-hist-nws-option.smart-nws = tt-2-hist-nws-option.smart-nws
      tt0-hist-nws-option.get-hist-from-nws = tt-2-hist-nws-option.get-hist-from-nws
      .
      release tt0-hist-nws-option.
      delete tt-2-hist-nws-option.
   END.
 END.
END.
ON CHOOSE OF B-mask IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo .
  run ref/dc-masks.w (
                    INPUT parparentproc
                   ,INPUT parhost-code
                   ,INPUT parobj-type
                   ,INPUT parobj-code
                   ,input "":U
                   ,INPUT "one":U
                   ,INPUT ub.dis-card-type.TYPE
                   ,INPUT ub.dis-card-type.emitent-host-code
                   ,INPUT ?
                   ,input-output v-rid-list
                    ) NO-ERROR.
  IF ERROR-STATUS:error  THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-params IN FRAME Dialog-Frame
DO:
  if tt0-rp-by-call.call_id = '' then do:
    message
    "Пожалуйста, заполните поле <тип ДК>"
    view-as alert-box warning.
    return no-apply.
  end.
  CASE Rs-algo-profile:
    when 'rule-by-call':U then do:
      IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
      run ref/rulercps.w (
                             input parparentproc
                            ,input this-procedure:handle
                            ,input '':U
                            ,input p-mode
                            ,input 'rule-call-param':U
                            ,input 0
                            ,input ?
                            ,input tt0-rule-by-call.call_id
                            ,input tt0-rule-by-call.codex_id
                            ,input tt0-rule-by-call.ruleset_id
                            ,input tt0-rule-by-call.order_id
                            ,input tt0-rule-by-call.RULE_id
                            ,INput substitute("Правило &1 &2"
                                             , tt0-rule-by-call.RULE_id
                                             , calldscr(tt0-rule-by-call.call_id)
                                             )
                            ,input-output table tt0-rule-call-param  ) no-error.
     end.
     when 'rp-by-call':U then do:
      IF NOT AVAILABLE tt0-rp-by-call THEN RETURN NO-APPLY.
      define variable v-param-form as character no-undo .
      define buffer buf_rule-profile for ub.rule-profile.
      find first buf_rule-profile no-lock where
                buf_rule-profile.profile_id = tt0-rp-by-call.profile_id.
      assign
      v-param-form = (if buf_rule-profile.custom-param-form > 0
                      then  substitute("rul/rcps-&1.w", buf_rule-profile.profile_id)
                      else "ref/rulercps.w")
      .
      run value(v-param-form) (
                            input parparentproc
                            ,input this-procedure:handle
                            ,input 'b-chg':U
                            ,input p-mode
                            ,input 'rp-rule-param':U
                            ,input tt0-rp-by-call.profile_id
                            ,input tt0-rp-by-call.once-more
                            ,input tt0-rp-by-call.call_id
                            ,input 0
                            ,input 0
                            ,input ?
                            ,input 0
                            ,INput substitute("Профайл &1 № привязки &2 &3"
                                              ,tt0-rp-by-call.profile
                                              ,tt0-rp-by-call.once-more
                                              ,calldscr(tt0-rp-by-call.call_id)
                                              )
                            ,input-output table tt0-rule-call-param  ) no-error.
     end.
   end case.
END.
ON CHOOSE OF b-prop-ref IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  run ref/proprefs.w ( INPUT parparentproc
                  ,INPUT "":U
                  ,INPUT "call_id"
                  ,INPUT 0
                  ,input '':U
                  ,INPUT temp-dc-type.uniq-key-rec
                  ,INPUT-OUTPUT v-rid-list) NO-ERROR.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
  rid = ?.
END.
ON CHOOSE OF B-rule IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  IF rule-display-option = "" THEN DO:
   run gbl/pop-up.p ( input self:handle, input no) no-error.
  END.
  IF rule-display-option = "" THEN DO:
    RETURN NO-APPLY.
  END.
  RUN proc-display-rule IN THIS-PROCEDURE (
                                             INPUT rule-display-option
                                            ,input tt0-rule-by-call.codex_id
                                            ,input tt0-rule-by-call.ruleset_id
                                            ,input tt0-rule-by-call.call_id
                                            ,input tt0-rule-by-call.order_id
                                            ,INPUT tt0-rule-by-call.rule_id) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    ASSIGN
    rule-display-option = "".
    RETURN NO-APPLY.
  END.
  ASSIGN
  rule-display-option = "".
END.
ON CHOOSE OF b-rule-on-off IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if Rs-algo-profile <> 'rule-by-call':U then return no-apply.
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  IF X_rule-profile.IS_dynamic = NO  THEN DO:
     MESSAGE
     substitute("Данное правило не может быть включено/выключено,&1" +
                "так как принадлежит алгоритму, приписанному к карте ПО УМОЛЧАНИЮ!"
                , chr(10))
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.
  if tt0-rule-by-call.is_dynamic = no then do:
     MESSAGE
     substitute("Данное правило не может быть включено/выключено,&1" +
                "согласно определенной профайлом логике!"
                , chr(10))
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  end.
  IF tt0-rule-by-call.can-calc THEN DO:
    MESSAGE
    "Вы уверены, что хотите выключить правило?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE gLOG.
    IF NOT glog THEN RETURN NO-APPLY.
  END.
  ELSE DO:
      MESSAGE
      "Вы уверены, что хотите включить правило?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE gLOG.
      IF NOT glog THEN RETURN NO-APPLY.
  END.
  ASSIGN
  tt0-rule-by-call.can-calc = NOT (tt0-rule-by-call.can-calc).
  glog = br-rule-by-call:REFRESH() IN FRAME Dialog-Frame.
END.
ON CHOOSE OF B-ruleset IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
define buffer buf_ruleset for ub.ruleset.
  IF NOT AVAILABLe tt0-rule-by-call THEN DO:
      RETURN NO-APPLY.
  END.
  FIND FIRST buf_ruleset NO-LOCK WHERE
            buf_ruleset.codex_id = tt0-rule-by-call.codex_id
        AND buf_ruleset.ruleset_id = tt0-rule-by-call.ruleset_id.
  run rul/ruleset-i.w ( input parparentproc
                       ,input 'ПРОСМОТР':U
                       ,input buf_ruleset.codex_id
                       ,input buf_ruleset.ruleset_id
                       ,input-output v-rec) no-error.
END.
ON VALUE-CHANGED OF br-profile IN FRAME Dialog-Frame
DO:
if br-profile:visible in frame Dialog-Frame then do:
  IF NOT AVAILABLE tt0-rp-by-call THEN DO:
     e-rule-name:SCREEN-VALUE = ''.
  END.
  ELSE DO:
    e-rule-name:SCREEN-VALUE = tt0-rp-by-call.ps.
  END.
end.
END.
ON VALUE-CHANGED OF br-rule-by-call IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER buf_rule FOR ub.RULE.
  define buffer buf_rule-profile for ub.rule-profile.
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  FIND FIRST buf_rule NO-LOCK WHERE
            buf_rule.RULE_id = tt0-rule-by-call.RULE_id NO-ERROR.
  IF NOT AVAILABLE buf_rule THEN DO:
     e-rule-name:SCREEN-VALUE = SUBSTITUTE("!!!Правило &1 не найдено", tt0-rule-by-call.RULE_Id).
  END.
  ELSE DO:
    e-rule-name:SCREEN-VALUE = buf_rule.name + chr(10) + buf_rule.documentation.
  END.
  find first buf_rule-profile no-lock where
            buf_rule-profile.profile_id = tt0-rule-by-call.profile_id.
  b-rule-on-off:sensitive in frame Dialog-Frame = (p-mode <> 'ПРОСМОТР':U)
                                               and buf_rule-profile.custom-param-form = 0
                                               and (Rs-algo-profile = 'rule-by-call':U).
END.
ON VALUE-CHANGED OF temp-dc-type.dflt-credit-card IN FRAME Dialog-Frame
DO:
 RUN BUTTONS IN THIS-PROCEDURE NO-ERROR.
END.
ON VALUE-CHANGED OF temp-dc-type.dflt-debet-card IN FRAME Dialog-Frame
DO:
  RUN BUTTONS IN THIS-PROCEDURE NO-ERROR.
END.
ON LEAVE OF E-rule-name IN FRAME Dialog-Frame
DO:
  run local-notes in this-procedure no-error.
END.
ON ENTRY OF temp-dc-type.emitent-host-code IN FRAME Dialog-Frame
DO:
  old-emitent-host-code = integer(temp-dc-type.emitent-host-code:screen-value).
END.
ON LEAVE OF temp-dc-type.emitent-host-code IN FRAME Dialog-Frame
DO:
if integer(temp-dc-type.emitent-host-code:screen-value) <>   old-emitent-host-code then do:
  display
  "":U @ temp-dc-type.dcbyshop
  with frame Dialog-Frame.
end.
run display-r-b-abbr in this-procedure ( output v-r-b-code) no-error.
RUN proc-refresh-tt IN THIS-PROCEDURE NO-ERROR.
OPEN QUERY br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" to br-profile.
OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" to br-rule-by-call.
END.
ON CHOOSE OF MENU-ITEM m_graph
DO:
    IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  ASSIGN
  rule-display-option = "graph".
  RUN proc-display-rule IN THIS-PROCEDURE (  INPUT rule-display-option
                                            ,INPUT tt0-rule-by-call.codex_id
                                            ,INPUT tt0-rule-by-call.ruleset_id
                                            ,INPUT tt0-rule-by-call.call_id
                                            ,INPUT tt0-rule-by-call.order_id
                                            ,INPUT tt0-rule-by-call.rule_id) NO-ERROR.
  ASSIGN
  rule-display-option = "".
END.
ON CHOOSE OF MENU-ITEM m_text
DO:
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  ASSIGN
  rule-display-option = "text".
  RUN proc-display-rule IN THIS-PROCEDURE (  INPUT rule-display-option
                                            ,INPUT tt0-rule-by-call.codex_id
                                            ,INPUT tt0-rule-by-call.ruleset_id
                                            ,INPUT tt0-rule-by-call.call_id
                                            ,INPUT tt0-rule-by-call.order_id
                                            ,INPUT tt0-rule-by-call.rule_id) NO-ERROR.
  ASSIGN
  rule-display-option = "".
END.
ON VALUE-CHANGED OF Rs-algo-profile IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-algo-profile.
  CASE rs-algo-profile:
    WHEN 'rule-by-call':U THEN DO:
      e-rule-name:read-only = yes.
      HIDE
      br-profile
      b-addalgo
      b-delalgo
      IN FRAME Dialog-Frame.
      .
      DISPLAY
      rs-algo-types
      br-rule-by-call
      b-rule
      b-ruleset
      b-rule-on-off
      WITH FRAME Dialog-Frame.
      APPLY "VALUE-CHANGED" to br-rule-by-call.
    END.
    WHEN 'rp-by-call':U THEN DO:
      e-rule-name:read-only = (if p-mode <> 'ПРОСМОТР':U then no else yes).
      HIDE
      br-rule-by-call
      rs-algo-types
      b-rule
      b-ruleset
      b-rule-on-off
      IN FRAME Dialog-Frame.
      DISPLAY
      br-profile
      b-addalgo
      b-delalgo
      WITH FRAME Dialog-Frame.
      APPLY "VALUE-CHANGED" to br-profile.
    END.
  END CASE.
END.
ON VALUE-CHANGED OF rs-algo-types IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-algo-types.
  OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
  APPLY "VALUE-CHANGED" TO br-rule-by-call IN FRAME Dialog-Frame.
END.
ON VALUE-CHANGED OF T-check-by-mask IN FRAME Dialog-Frame
DO:
  ASSIGN
  t-check-by-mask.
  CASE t-check-by-mask:
  WHEN YES THEN DO:
    IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
      ENABLE
      t-ho-join
      WITH FRAME Dialog-Frame.
    END.
    else do:
      disable
      t-ho-join
      WITH FRAME Dialog-Frame.
    end.
  END.
  WHEN NO THEN DO:
    ASSIGN
    t-ho-join = NO.
    display
    t-ho-join
    with frame Dialog-Frame .
    DISABLE
    t-ho-join
    WITH FRAME Dialog-Frame.
  END.
END CASE.
END.
ON LEAVE OF temp-dc-type.type IN FRAME Dialog-Frame
DO:
  IF p-mode = 'ДОБАВЛЕНИЕ':U  THEN DO:
     ASSIGN
     temp-dc-type.TYPE.
     RUN proc-refresh-tt IN THIS-PROCEDURE no-error.
     OPEN QUERY br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION.
     APPLY "VALUE-CHANGED" to br-profile.
     OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
      APPLY "VALUE-CHANGED" to br-rule-by-call.
  END.
END.
ON VALUE-CHANGED OF v-dflt-d-pcnt-method IN FRAME Dialog-Frame
DO:
 ASSIGN
  v-dflt-d-pcnt-method.
  CASE v-dflt-d-pcnt-method:
      WHEN '1':U THEN DO:
         ASSIGN
         v-mode[2] = 'ПРОСМОТР':U
         v-mode[1] = p-mode
         .
      END.
      WHEN '2':U THEN DO:
          ASSIGN
          v-mode[1] = 'ПРОСМОТР':U
          v-mode[2] = p-mode
          .
      END.
      WHEN '3':U THEN DO:
          ASSIGN
          v-mode[1] = p-mode
          v-mode[2] = p-mode
          .
      END.
  END CASE.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-profile :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
procedure rcpscont_get-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define output parameter p-on-off as logical no-undo .
define buffer buf_tt0-rule-by-call for tt0-rule-by-call.
find first buf_tt0-rule-by-call where
         buf_tt0-rule-by-call.codex_id = p-codex-id
     and buf_tt0-rule-by-call.ruleset_id = p-ruleset-id
     and buf_tt0-rule-by-call.profile_id = p-profile-id
     and buf_tt0-rule-by-call.once-more = p-once-more
     and buf_tt0-rule-by-call.rule_id = p-rule-id
     no-error .
if available buf_tt0-rule-by-call then do:
   p-on-off = buf_tt0-rule-by-call.can-calc.
end.
end procedure.
procedure rcpscont_set-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter p-on-off as logical no-undo .
define variable v-h as handle no-undo .
define buffer buf_tt0-rule-by-call for tt0-rule-by-call.
v-h = buffer tt0-rule-by-call:handle.
if v-h:table <> ''
and v-h:table <> ? then do:
  find first buf_tt0-rule-by-call where
          buf_tt0-rule-by-call.codex_id = p-codex-id
      and buf_tt0-rule-by-call.ruleset_id = p-ruleset-id
      and buf_tt0-rule-by-call.profile_id = p-profile-id
      and buf_tt0-rule-by-call.once-more = p-once-more
      and buf_tt0-rule-by-call.rule_id = p-rule-id   no-error .
  if not available buf_tt0-rule-by-call then do:
    undo, return error .
  end.
  buf_tt0-rule-by-call.can-calc = p-on-off .
  release buf_tt0-rule-by-call.
end.
OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  if p-mode <> 'ИЗМЕНЕНИЕ':U and p-mode <> 'ДОБАВЛЕНИЕ':U AND p-mode <> 'ПРОСМОТР':U then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова p-mode"
        view-as alert-box ERROR.
        return error.
    end.
    for each temp-dc-type:
        delete temp-dc-type.
    end.
  if p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ПРОСМОТР':U then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      do transaction
      on error undo, return error
      on stop undo, return error
      :
        find first dis-card-type EXclusive-lock where recid(dis-card-type) = rid no-wait no-error.
        if locked dis-card-type then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись типа дисконтной карты занята"
          view-as alert-box error .
          return error.
        end.
      end.
    end.
    else do:
      find first dis-card-type no-lock where recid(dis-card-type) = rid.
    end.
    if not available dis-card-type then do:
      message vss-workfile vss-revision vss-description skip
              "Не найдена запись типа дисконтной карты"
      view-as alert-box error .
    end.
    create temp-dc-type.
    buffer-copy dis-card-type to temp-dc-type.
  end.
  ELSE DO:
    CREATE temp-dc-type.
    assign
    temp-dc-type.cardname-sent = 'name':U
    temp-dc-type.custom-sent = substitute("&1,&1"
                                            ,chr(63) )
    .
  END.
  RUN dc-typei_FILL-table IN THIS-PROCEDURE ( input p-mode
                                             ,input no
                                             ,output f-dflt-pcnt
                                             ,output f-dflt-cash-pcnt
                                             ,output f-dflt-pcnt-kat
                                            ) no-error .
  if error-status:error then do:
    message
    error-status:get-message(1) return-value
    view-as alert-box error .
    undo main-block, return error .
  end.
  OPEN QUERY br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION.
  APPLY "VALUE-CHANGED" to br-profile IN FRAME Dialog-Frame.
  OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
  APPLY "value-changed" TO br-rule-by-call IN FRAME Dialog-Frame.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE buttons :
define variable v-found as logical no-undo .
define buffer buf_tt0-dis-dct-rule for tt0-dis-dct-rule.
if temp-dc-type.dflt-credit-card:screen-value IN FRAME Dialog-Frame = "yes":U
AND p-mode <> 'ПРОСМОТР':U THEN DO:
  enable
  temp-dc-type.lim-kr
  with frame Dialog-Frame.
  assign
  temp-dc-type.dflt-debet-card = no
  .
  display
  temp-dc-type.dflt-debet-card
  with frame Dialog-Frame.
  DISABLE
  temp-dc-type.dflt-debet-card
  with frame Dialog-Frame.
 END.
  else do:
    if p-mode <> 'ДОБАВЛЕНИЕ':U
    and
    ub.dis-card-type.emitent-host-code = 0
    then do:
      DISABLE
      temp-dc-type.dflt-credit-card
      with frame Dialog-Frame.
    end.
    if p-mode = 'ДОБАВЛЕНИЕ':U then
    display
    0 @ temp-dc-type.lim-kr
    with frame Dialog-Frame.
    disable
    temp-dc-type.lim-kr
    with frame Dialog-Frame.
    IF p-mode <> 'ПРОСМОТР':U THEN
    ENABLE
    temp-dc-type.dflt-debet-card
    with frame Dialog-Frame.
    IF temp-dc-type.dflt-credit-card:screen-value = "no":U THEN DO:
        DISABLE
        temp-dc-type.fiscal-pay
        with frame Dialog-Frame.
    END.
  end.
  IF (temp-dc-type.dflt-credit-card:screen-value = "yes":U
  OR    temp-dc-type.dflt-debet-card:screen-value = "yes":U)
  THEN DO:
      IF p-mode <> 'ПРОСМОТР':U THEN
      ENABLE
      temp-dc-type.fiscal-pay
      temp-dc-type.mixed-pay
      b-cashpay
      WITH FRAME Dialog-Frame.
  END.
  ELSE DO:
     DISABLE
      temp-dc-type.fiscal-pay
      temp-dc-type.mixed-pay
      b-cashpay
      WITH FRAME Dialog-Frame.
      ASSIGN
      f-cash-pay-name = "":U
      temp-dc-type.pay-code = 0    .
      DISPLAY
      f-cash-pay-name
      with frame Dialog-Frame .
  END.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-r-b-abbr :
DEFINE OUTPUT PARAMETER p-r-b-curr-code LIKE ub.currency.curr-code NO-UNDO.
define var varemitent-host-code like ub.dis-card-type.emitent-host-code no-undo.
DEFINE BUFFER buf_sysconf FOR ub.sysconf.
varemitent-host-code = integer(temp-dc-type.emitent-host-code:screen-value in frame Dialog-Frame).
if varemitent-host-code = 0
and v-curr-r-b = 'base':U
then do:
  ASSIGN
  p-r-b-curr-code = 0
  var-r-b-abbr = ?.
end.
else do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-abbr in g#library
  (input  varemitent-host-code
  ,output var-r-b-abbr
  ) no-error .
    IF varemitent-host-code = 0 or
     v-curr-r-b = 'rubl':U
     THEN DO:
        ASSIGN
        p-r-b-curr-code = 0
        .
    END.
    ELSE DO:
       FIND FIRST buf_sysconf NO-LOCK WHERE
                 buf_sysconf.host-code = varemitent-host-code .
       ASSIGN
       p-r-b-curr-code = buf_sysconf.base-code
        .
  END.
end.
display
var-r-b-abbr
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE dpcnt-byshop-enable-disable :
define buffer buf_tt0-dis-dct-rule for tt0-dis-dct-rule.
define variable v-found as logical no-undo .
disable
temp-dc-type.d-pcnt-byshop
with frame Dialog-Frame .
for each buf_tt0-dis-dct-rule no-lock :
  if not (buf_tt0-dis-dct-rule.discnt-role = 'def-pcnt':U
          or
          buf_tt0-dis-dct-rule.discnt-role = 'def-cash-pcnt':U
          or
          buf_tt0-dis-dct-rule.discnt-role = 'def-categ':U) then next.
  if buf_tt0-dis-dct-rule.host-code = 0
  and buf_tt0-dis-dct-rule.obj-type = '':U
  and buf_tt0-dis-dct-rule.obj-code = 0 then next.
  v-found = yes.
end.
if not v-found
and p-mode <> 'ПРОСМОТР':U then do:
  enable
  temp-dc-type.d-pcnt-byshop
  with frame Dialog-Frame .
end.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH temp-dc-type SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY T-check-by-mask T-ho-join f-dflt-pcnt f-dflt-cash-pcnt f-dflt-pcnt-kat
          v-dflt-d-pcnt-method Rs-algo-profile rs-algo-types E-rule-name
          f-cash-pay-name emitent-name var-r-b-abbr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE temp-dc-type THEN
    DISPLAY temp-dc-type.type temp-dc-type.emitent-host-code
          temp-dc-type.d-pcnt-byshop temp-dc-type.dflt-credit-card
          temp-dc-type.dflt-debet-card temp-dc-type.dflt-staff-card
          temp-dc-type.card-media temp-dc-type.lim-kr temp-dc-type.fiscal-pay
          temp-dc-type.mixed-pay temp-dc-type.dcbyshop
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-3 RECT-4 B-exit b-quit B-mask b-hn b-cd b-prop-ref b-disc
         B-history B-Help temp-dc-type.type T-check-by-mask T-ho-join
         temp-dc-type.emitent-host-code B-emitent f-dflt-pcnt
         temp-dc-type.d-pcnt-byshop B-def-pcnt b-d-pcnt-byshop f-dflt-cash-pcnt
         f-dflt-pcnt-kat B-def-cash-pcnt B-def-categ v-dflt-d-pcnt-method
         b-addalgo b-delalgo b-params B-rule B-ruleset b-rule-on-off
         Rs-algo-profile rs-algo-types br-rule-by-call br-profile E-rule-name
         temp-dc-type.dflt-credit-card temp-dc-type.dflt-debet-card
         temp-dc-type.dflt-staff-card temp-dc-type.card-media
         temp-dc-type.lim-kr temp-dc-type.fiscal-pay temp-dc-type.mixed-pay
         B-cashpay B-dcbyshop emitent-name var-r-b-abbr temp-dc-type.dcbyshop
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION.    OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE fill-tt0-dis-card-type :
define input parameter p-dis-card-type-bh as handle no-undo.
p-dis-card-type-bh:buffer-create().
p-dis-card-type-bh:buffer-copy(buffer temp-dc-type:handle).
p-dis-card-type-bh:buffer-release().
END PROCEDURE.
PROCEDURE fill-tt0-dis-dct-rule :
define input parameter p-dis-dct-rule-bh as handle no-undo.
define buffer buf_tt0-dis-dct-rule for tt0-dis-dct-rule.
for each buf_tt0-dis-dct-rule:
  p-dis-dct-rule-bh:buffer-create().
  p-dis-dct-rule-bh:buffer-copy(buffer buf_tt0-dis-dct-rule:handle).
  p-dis-dct-rule-bh:buffer-release().
end.
END PROCEDURE.
PROCEDURE local-notes :
define variable v-updated as logical no-undo .
define buffer buf_tt0-rp-by-call for tt0-rp-by-call.
do on stop undo, return no-apply:
  find buf_tt0-rp-by-call where recid (buf_tt0-rp-by-call) = recid(tt0-rp-by-call) exclusive no-error no-wait.
  if not available buf_tt0-rp-by-call then do:
  end.
  else do:
    assign
    buf_tt0-rp-by-call.PS = input frame Dialog-Frame e-rule-name
    v-updated = yes
    .
  end.
  if not v-updated then do:
    e-rule-name:edit-undo().
  end.
end.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-check-by-mask AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-tooltip AS CHARACTER NO-UNDO.
DEFINE VARIABLE clh AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE ii AS integer NO-UNDO.
define buffer b_clients for ub.clients.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
OPEN QUERY Dialog-Frame FOR EACH temp-dc-type SHARE-LOCK.
  GET FIRST Dialog-Frame.
ASSIGN
v-mode[1] = p-mode
v-mode[2] = p-mode
v-mode[3] = p-mode
v-mode[1] = (IF temp-dc-type.dflt-d-pcnt-method = integer('2':U)
                        THEN 'ПРОСМОТР':U
                        ELSE p-mode)
v-mode[2] = (IF temp-dc-type.dflt-d-pcnt-method = integer('1':U)
                        THEN 'ПРОСМОТР':U
                        ELSE p-mode)
.
ASSIGN
rs-algo-profile:RADIO-BUTTONS IN FRAME Dialog-Frame = "Алгоритмы" + chr(44) +
                                 'rp-by-call':U + chr(44) +
                                "Правила" + chr(44) + 'rule-by-call':U.
rs-algo-profile = 'rp-by-call':U.
ASSIGN
tt0-rule-by-call.algo-des:RESIZABLE IN BROWSE br-rule-by-call = YES .
DO ii = 1 TO br-profile:NUM-COLUMNS IN FRAME Dialog-Frame:
    clh = BROWSE br-profile:get-browse-column(ii).
    IF clh:LABEL BEGINS "Название" THEN DO:
      ASSIGN
      clh:RESIZABLE = YES
      clh:width = 72
      .
    END.
END.
  assign
   v-dflt-d-pcnt-method:Radio-buttons in frame Dialog-Frame =
     "Товар" + chr(44) + string('1':U) + chr(44) +
     "Итог_чека" + chr(44) + string('2':U) + chr(44) +
     "Товары_и_итог_чека" + chr(44) + string('3':U)
    b-rule:MENU-MOUSE in frame Dialog-Frame = 1
    temp-dc-type.card-media:RADIO-BUTTONS = mixlist('Карта c магн.полосой,ТМ ключ,Смарт карта,Радио карта,Карта со штрихкодом,EASY FUEL,EasyFuel2':U, '0,1,2,3,4,5,6':U, chr(44), chr(44))
    .
  if p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ПРОСМОТР':U then do:
    if temp-dc-type.emitent-host-code > 0 then do:
        find first b_clients No-LOCK WHERE
                    b_clients.obj-type = 'орг':U and
                    b_clients.obj-code = temp-dc-type.emitent-host-code No-ERROR.
        if avail b_clients then
        emitent-name = b_clients.obj-name.
    end.
    else do:
        emitent-name = "Глобальная".
    end.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    display
    0 @ temp-dc-type.emitent-host-code
    0 @ f-dflt-pcnt
    0 @ f-dflt-cash-pcnt
    0 @ temp-dc-type.lim-kr
    WITH FRAME Dialog-Frame.
  end.
  assign
   v-dflt-d-pcnt-method = (if p-mode = 'ДОБАВЛЕНИЕ':U
                            then string('1':U)
                            else string(temp-dc-type.dflt-d-pcnt-method)
                            ).
assign
T-check-by-mask  = (if temp-dc-type.check-by-mask = 1 then yes else no)
T-ho-join        = (if temp-dc-type.ho-join = 1 then yes else no)
T-check-by-mask:tooltip = v-tooltip
no-error .
DISPLAY
emitent-name
var-r-b-abbr
rs-algo-types
rs-algo-profile
WITH FRAME Dialog-Frame.
IF AVAILABLE temp-dc-type THEN DO:
  DISPLAY
  temp-dc-type.type
  temp-dc-type.emitent-host-code
  f-dflt-pcnt
  f-dflt-pcnt-kat
  f-dflt-cash-pcnt
  temp-dc-type.dflt-credit-card
  temp-dc-type.dflt-debet-card
  temp-dc-type.dflt-staff-card
  temp-dc-type.fiscal-pay
  temp-dc-type.mixed-pay
  temp-dc-type.card-media
  temp-dc-type.lim-kr
  temp-dc-type.dcbyshop
  temp-dc-type.d-pcnt-byshop
  v-dflt-d-pcnt-method
  T-check-by-mask
  t-ho-join
  WITH FRAME Dialog-Frame.
END.
ENABLE
B-exit when p-mode <> 'ПРОСМОТР':U
b-quit
b-mask WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
b-history WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
b-cd WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
b-hn
B-Help
rs-algo-profile
b-rule
b-ruleset
b-addalgo when p-mode <> 'ПРОСМОТР':U
b-delalgo when p-mode <> 'ПРОСМОТР':U
b-rule-on-off when p-mode <> 'ПРОСМОТР':U
b-cd when p-mode <> 'ПРОСМОТР':U
b-params
temp-dc-type.type when p-mode = 'ДОБАВЛЕНИЕ':U
temp-dc-type.emitent-host-code when p-mode = 'ДОБАВЛЕНИЕ':U
B-emitent when p-mode = 'ДОБАВЛЕНИЕ':U
b-def-pcnt when p-mode <> 'ПРОСМОТР':U
b-def-cash-pcnt when p-mode <> 'ПРОСМОТР':U
b-def-categ when p-mode <> 'ПРОСМОТР':U
temp-dc-type.dflt-credit-card when p-mode <> 'ПРОСМОТР':U
temp-dc-type.dflt-staff-card when p-mode <> 'ПРОСМОТР':U
temp-dc-type.lim-kr when p-mode <> 'ПРОСМОТР':U
temp-dc-type.dcbyshop when p-mode <> 'ПРОСМОТР':U
B-dcbyshop when p-mode <> 'ПРОСМОТР':U
temp-dc-type.d-pcnt-byshop when p-mode <> 'ПРОСМОТР':U AND (p-mode = 'ДОБАВЛЕНИЕ':U or not temp-dc-type.d-pcnt-byshop)
v-dflt-d-pcnt-method when p-mode <> 'ПРОСМОТР':U
temp-dc-type.card-media WHEN p-mode  <> 'ПРОСМОТР':U
t-check-by-mask WHEN p-mode  <> 'ПРОСМОТР':U
t-ho-join WHEN (p-mode  <> 'ПРОСМОТР':U and t-check-by-mask)
br-rule-by-call
br-profile
b-prop-ref WHEN p-mode  <> 'ДОБАВЛЕНИЕ':U
rs-algo-types
b-disc WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
b-d-pcnt-byshop
e-rule-name
WITH FRAME Dialog-Frame.
if p-mode = 'ПРОСМОТР':U then do:
    HIDE
    b-exit in frame Dialog-Frame.
    assign
    b-quit:label in frame Dialog-Frame = "&Выход"
    b-quit:column in frame Dialog-Frame = 1
    e-rule-name:read-only in frame Dialog-Frame = yes
    .
end.
VIEW FRAME Dialog-Frame.
RUN BUTTONS IN THIS-PROCEDURE NO-ERROR.
run display-r-b-abbr in this-procedure ( output v-r-b-code) no-error.
IF temp-dc-type.pay-code <> 0 THEN DO:
FIND FIRST buf_cash-pay NO-LOCK WHERE
          buf_cash-pay.cdpay-code = temp-dc-type.pay-code
       AND buf_cash-pay.curr-code = v-r-b-code NO-ERROR.
  IF NOT AVAILABLE buf_cash-pay THEN DO:
      ASSIGN
     f-cash-pay-name = "":U.
  END.
  ELSE DO:
      f-cash-pay-name = buf_cash-pay.obj-name.
  END.
  DISPLAY
  f-cash-pay-name
  WITH FRAME Dialog-Frame.
END.
OPEN QUERY br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION.    OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" TO rs-algo-profile.
APPLY "VALUE-CHANGED" TO T-check-by-mask.
END PROCEDURE.
PROCEDURE proc-b-addalgo :
DEFINE PARAMETER BUFFER buf_rule-profile FOR ub.rule-profile.
run dc-typei_proc-b-addalgo in this-procedure (
                                                 input no
                                                ,input v-start
                                                ,buffer buf_rule-profile) no-error .
    if error-status:error then do:
      message
  return-value
  view-as alert-box .
  return.
end.
OPEN QUERY br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" to br-profile IN FRAME Dialog-Frame.
OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
APPLY "value-changed" TO br-rule-by-call IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-cd :
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-cardname-sent AS character NO-UNDO.
DEFINE VARIABLE v-custom-sent AS character NO-UNDO.
ASSIGN
v-cardname-sent = temp-dc-type.cardname-sent
v-custom-sent = temp-dc-type.custom-sent
.
run ref/dctypecd.w ( INPUT parparentproc
                    ,INPUT p-mode
                    ,input temp-dc-type.emitent-host-code
                    ,input temp-dc-type.type
                    ,INPUT-OUTPUT v-cardname-sent
                    ,INPUT-OUTPUT v-custom-sent
                    ,OUTPUT v-ok) NO-ERROR.
IF NOT ERROR-STATUS:ERROR
AND v-ok THEN DO:
   ASSIGN
   temp-dc-type.cardname-sent = v-cardname-sent
   temp-dc-type.custom-sent = v-custom-sent
   .
END.
END PROCEDURE.
PROCEDURE proc-b-delalgo :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-rule-nums AS INTEGER NO-UNDO.
DEFINE VARIABLE v-profile-id AS INTEGER NO-UNDO.
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
DEFINE BUFFER buf_tt0-rule-by-call FOR tt0-rule-by-call.
DEFINE BUFFER buf_rule-by-profile FOR ub.rule-by-profile.
DEFINE BUFFER buf_tt0-rp-by-call FOR tt0-rp-by-call.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
IF NOT AVAILABLE tt0-rp-by-call THEN RETURN ERROR.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = tt0-rp-by-call.profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN DO:
   MESSAGE
   substitute("Не найден алгоритм с кодом &1", tt0-rp-by-call.profile_id)
   VIEW-AS ALERT-BOX ERROR.
   RETURN ERROR.
END.
IF buf_rule-profile.IS_dynamic = NO THEN DO:
   MESSAGE
   "Привязку к данному алгоритму НЕЛЬЗЯ удалить!"
   VIEW-AS ALERT-BOX ERROR.
   RETURN ERROR.
END.
MESSAGE
"Вы уверены, что хотите удалить привязку к данному алгоритму?"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN RETURN ERROR.
FIND FIRST buf_rule-profile EXCLUSIVE-LOCK WHERE buf_rule-profile.profile_id = tt0-rp-by-call.profile_id.
FOR EACH buf_tt0-rule-by-call where
      buf_tt0-rule-by-call.profile_id = tt0-rp-by-call.profile_id
  and buf_tt0-rule-by-call.once-more = tt0-rp-by-call.once-more
ON error UNDO, RETURN ERROR:
  for each buf_tt0-rule-call-param where
          buf_tt0-rule-call-param.codex_id = buf_tt0-rule-by-call.codex_id
    and buf_tt0-rule-call-param.ruleset_id = buf_tt0-rule-by-call.ruleset_id
    and buf_tt0-rule-call-param.call_id  = buf_tt0-rule-by-call.call_id
    and buf_tt0-rule-call-param.order_id = buf_tt0-rule-by-call.order_id
    ON error UNDO, RETURN ERROR:
    delete buf_tt0-rule-call-param.
  end.
  DELETE buf_tt0-rule-by-call.
END.
DELETE tt0-rp-by-call.
OPEN QUERY br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" to br-profile IN FRAME Dialog-Frame.
OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
APPLY "value-changed" TO br-rule-by-call  IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-dis-dct-rule :
DEFINE INPUT PARAMETER p-discnt-role AS CHARACTER NO-UNDO.
define input parameter p-mode as character no-undo .
DEFINE BUFFER buf_dis-dct-rule FOR ub.dis-dct-rule.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sts AS integer NO-UNDO.
define variable glog as logical no-undo .
DEFINE BUFFER buf_tt0-dis-dct-rule FOR tt0-dis-dct-rule.
FIND FIRST buf_tt0-dis-dct-rule NO-LOCK WHERE
          buf_tt0-dis-dct-rule.emitent-host-code = temp-dc-type.emitent-host-code
      AND buf_tt0-dis-dct-rule.type = temp-dc-type.TYPE
      AND buf_tt0-dis-dct-rule.host-code = 0
      AND buf_tt0-dis-dct-rule.obj-type = '':U
      AND buf_tt0-dis-dct-rule.obj-code = 0
    AND buf_tt0-dis-dct-rule.pos-type = 'bo':U
    AND buf_tt0-dis-dct-rule.discnt-role = p-discnt-role NO-ERROR.
IF AVAILABLE buf_tt0-dis-dct-rule  THEN DO:
  FIND FIRST buf_dis-rule NO-LOCK WHERE
            buf_Dis-rule.rule-num = buf_tt0-dis-dct-rule.rule-num NO-ERROR.
  IF AVAILABLE buf_dis-rule THEN DO:
    v-rid-list = STRING(recid(buf_Dis-rule)).
  END.
END.
if p-mode <> 'ПРОСМОТР':U then do:
  run ref/dis-ruls.w ( input  parparentproc
                      ,input 0
                      ,input '':U
                      ,input 0
                      ,input "b-sel,b-add"
                      ,input 'dis-dct-rule':U + "=" + p-discnt-role
                      ,input 0
                      ,input ?
                      ,input 0
                      ,input-output v-sts
                      ,input-OUTPUT v-rid-list) NO-ERROR.
  if NOT ERROR-STATUS:ERROR
  AND v-rid-list <> '':U then do:
      find first buf_dis-rule no-lock where
                recid(buf_dis-rule) = integer(v-rid-list) no-error.
      if not available buf_dis-rule then do:
          message
          substitute("Не найдено правило скидки c recid &1", v-rid-list)
          VIEW-AS ALERT-BOX ERROR.
          UNDO, RETURN ERROR.
      END.
      IF NOT AVAILABLE buf_tt0-dis-dct-rule THEN DO:
        CREATE buf_tt0-dis-dct-rule.
        assign
        buf_tt0-dis-dct-rule.emitent-host-code = temp-dc-type.emitent-host-code
        buf_tt0-dis-dct-rule.type = temp-dc-type.type
        buf_tt0-dis-dct-rule.host-code = buf_dis-rule.host-code
        buf_tt0-dis-dct-rule.obj-type = '':U
        buf_tt0-dis-dct-rule.obj-code = 0
        buf_tt0-dis-dct-rule.pos-type = 'bo':U
        buf_tt0-dis-dct-rule.discnt-role = p-discnt-role
        buf_tt0-dis-dct-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        buf_tt0-dis-dct-rule.time-templ-rl-root = buf_dis-rule.time-templ-rl-root
        buf_tt0-dis-dct-rule.rule-num = buf_dis-rule.rule-num
        buf_tt0-dis-dct-rule.rl-root = buf_dis-rule.rl-root
        .
    END.
    ASSIGN
    buf_tt0-dis-dct-rule.templ-rl-root = buf_dis-rule.templ-rl-root
    buf_tt0-dis-dct-rule.time-templ-rl-root = buf_dis-rule.time-templ-rl-root
    buf_tt0-dis-dct-rule.rule-num = buf_dis-rule.rule-num
    buf_tt0-dis-dct-rule.rl-root = buf_dis-rule.rl-root
    .
  end.
end.
CASE p-discnt-role:
  WHEN 'def-categ':U THEN DO:
    DISPLAY
    (if available buf_Dis-rule
    then buf_dis-rule.dis-kat
    else 0)
    @ f-dflt-pcnt-kat
    WITH FRAME Dialog-Frame.
  END.
  WHEN 'def-pcnt':U THEN DO:
    DISPLAY
    (if available buf_Dis-rule
    then buf_dis-rule.discnt-value
    else 0.0)
    @ f-dflt-pcnt
    WITH FRAME Dialog-Frame.
  END.
  WHEN 'def-cash-pcnt':U THEN DO:
    DISPLAY
    (if available buf_Dis-rule
    then buf_dis-rule.discnt-value
    else 0.0)
    @ f-dflt-cash-pcnt
    WITH FRAME Dialog-Frame.
  END.
END CASE.
END PROCEDURE.
PROCEDURE proc-b-emitent :
define variable ref-list as char no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer h-cli for ub.clients.
run adm/sconfs.w (
                INPUT parparentproc
                ,INPUT "b-sel":U
                ,input no
                ,input 0
                ,output v-host-code
                ,input-output ref-list
                ).
if v-host-code = 0
or v-host-code = ?
then do:
  return error.
end.
find h-cli no-lock where
      h-cli.obj-type = 'орг':U
  AND h-cli.obj-code = v-host-code  .
      .
if not can-find (ub.sysconf where ub.sysconf.host-code = v-host-code no-lock) then do:
  message "Выбранная организация не является одной из фирм БД."
          view-as alert-box error.
  return error.
end.
old-emitent-host-code  = integer(temp-dc-type.emitent-host-code:screen-value in frame Dialog-Frame).
  display
h-cli.obj-code @ temp-dc-type.emitent-host-code
with frame Dialog-Frame.
RUN proc-refresh-tt IN THIS-PROCEDURE NO-ERROR.
OPEN QUERY br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" to br-profile.
OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" to br-rule-by-call.
END PROCEDURE.
PROCEDURE proc-dcbyshop :
define variable var-sel-value as char no-undo.
define variable var-input-value as char no-undo.
define variable var-output-value as char no-undo.
define variable var-labels as char no-undo.
define variable jj as integer no-undo.
do jj = 1 to num-entries(temp-dc-type.dcbyshop:screen-value in frame Dialog-Frame):
find first ub.clients No-LOCK WHERE
            ub.clients.obj-type = 'маг':U and
            ub.clients.obj-code = integer(entry(jj, temp-dc-type.dcbyshop:screen-value)) no-error.
if avail ub.clients then do:
  assign
  var-sel-value = var-sel-value + (if var-sel-value = "":U then "":U else chr(44)) + entry(jj, temp-dc-type.dcbyshop:screen-value)
  .
end.
end.
for each ub.clients NO-LOCK WHERE
            ub.clients.obj-type = 'маг':U,
  first ub.shop no-lock where
          ub.shop.obj-code = ub.clients.obj-code AND
          (integer(temp-dc-type.emitent-host-code:screen-value) = 0 OR
            ub.shop.host-code = integer(temp-dc-type.emitent-host-code:screen-value)):
  assign
  var-input-value = var-input-value + (if var-input-value = "":U then "":U else chr(44)) + string(clients.obj-code)
  var-labels = var-labels + (if var-labels = "":U
                              then "":U
                              else chr(44)) +
                string(ub.shop.obj-code, "99999") + chr(32) +
                replace(ub.clients.obj-name, chr(44), "":U)
  .
end.
run gbl/d-list.w (
                   input "b-sel,b-mark":U
                  ,input "Выберите магазины"
                  ,input var-input-value
                  ,input var-labels
                  ,input chr(44)
                  ,input var-sel-value
                  ,output var-output-value) no-error.
if error-status:error then return error.
if var-output-value = var-sel-value  then do:
  return error.
end.
else do:
  display
  var-output-value @ temp-dc-type.dcbyshop
  with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE proc-display-rule :
DEFINE INPUT PARAMETER p-display-mode AS CHARACTER NO-UNDO.
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
  run rul/disprule.p (
                       input p-DISPLAY-MODE
                      ,input p-rule-id
                      ,input p-codex-id
                      ,input p-ruleset-id
                      ,input p-call-id
                      ,input p-order-id
                       ).
END PROCEDURE.
PROCEDURE proc-refresh-tt :
DEFINE VARIABLE v-old-call-id AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-new-call-id AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt0-rule-by-call FOR tt0-rule-by-call.
DEFINE BUFFER buf_tt0-rp-by-call FOR tt0-rp-by-call.
DEFINE BUFFER buf_tt0-rule-call-param FOR tt0-rule-call-param.
DEFINE BUFFER buf_tt0-hist-nws-option FOR tt0-hist-nws-option.
DEFINE BUFFER buf_tt0-dis-dct-rule FOR tt0-dis-dct-rule.
IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
   FOR EACH buf_tt0-dis-dct-rule:
      buf_tt0-dis-dct-rule.emitent-host-code = temp-dc-type.emitent-host-code.
   END.
   run gen-key-rec in this-procedure (
                                     input 'dis-card-type':U
                                     ,input  BUFFER temp-dc-type:handle
                                     ,output temp-dc-type.uniq-key-rec
                                       ).
    FOR EACH buf_tt0-rp-by-call:
       buf_tt0-rp-by-call.CALL_id = temp-dc-type.uniq-key-rec.
    END.
    FOR EACH buf_tt0-rule-by-call:
      v-old-call-id = buf_tt0-rule-by-call.call_id.
      ASSIGN
      buf_tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec
      .
       FOR EACH buf_tt0-rule-call-param WHERE
               buf_tt0-rule-call-param.codex_id = buf_tt0-rule-by-call.codex_id
           AND buf_tt0-rule-call-param.ruleset_id = buf_tt0-rule-by-call.ruleset_id
           AND buf_tt0-rule-call-param.call_id = v-old-call-id:
          ASSIGN
          buf_tt0-rule-call-param.CALL_id = buf_tt0-rule-by-call.call_id.
       END.
    END.
END.
FOR EACH buf_tt0-hist-nws-option:
   ASSIGN
   buf_tt0-hist-nws-option.charkey_one = temp-dc-type.TYPE
   buf_tt0-hist-nws-option.host-code = temp-dc-type.emitent-host-code
   .
END.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-old-call-id AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-new-call-id AS CHARACTER NO-UNDO.
define variable glog as logical no-undo .
define variable v-ok as logical no-undo .
define variable v-found-new as logical no-undo .
define variable v-found-d-pcnt-byshop as logical   no-undo .
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_tt0-rp-by-call for tt0-rp-by-call.
DEFINE BUFFER buf_tt0-dis-dct-rule FOR tt0-dis-dct-rule.
define buffer buf_rule-profile for ub.rule-profile.
find first temp-dc-type  no-error.
ASSIGN FRAME Dialog-Frame
temp-dc-type.emitent-host-code
temp-dc-type.type
temp-dc-type.host-code = 0
temp-dc-type.obj-type  = "":U
temp-dc-type.obj-code  = 0
.
assign
temp-dc-type.dflt-credit-card
temp-dc-type.lim-kr
temp-dc-type.d-pcnt-byshop
temp-dc-type.dcbyshop
temp-dc-type.dc-pfx  = "":U
v-dflt-d-pcnt-method
temp-dc-type.dflt-d-pcnt-method = integer(v-dflt-d-pcnt-method)
temp-dc-type.card-media
temp-dc-type.dflt-debet-card
temp-dc-type.fiscal-pay
temp-dc-type.mixed-pay
temp-dc-type.dflt-staff-card
t-check-by-mask
t-ho-join
.
RUN proc-refresh-tt IN this-procedure.
  for each buf_tt0-dis-dct-rule no-lock where
          buf_tt0-dis-dct-rule.emitent-host-code = temp-dc-type.emitent-host-code
      and buf_tt0-dis-dct-rule.type = temp-dc-type.type
      and (buf_tt0-dis-dct-rule.host-code > 0
      or  buf_tt0-dis-dct-rule.obj-code  > 0)
      and buf_tt0-dis-dct-rule.pos-type = 'bo':U:
    if buf_tt0-dis-dct-rule.discnt-role = 'def-pcnt':U
    or buf_tt0-dis-dct-rule.discnt-role = 'def-cash-pcnt':U
    or buf_tt0-dis-dct-rule.discnt-role = 'def-categ':U then do:
    v-found-d-pcnt-byshop = yes.
    if temp-dc-type.d-pcnt-byshop = no then do:
      message
      "Для данного типа ДК НЕ установлен флаг СКИДКА/КАТЕГОРИЯ ПО ФИРМАМ/ОБЪЕКТАМ" skip
      "но ЗАДАНЫ скидки по умолчанию для объектов" skip
      "Данные скидки НЕ будут сохранены" skip
      "Продолжать?"
      view-as alert-box question buttons yes-no update glog.
      if not glog then do:
        undo, return error.
      end.
      else do:
        leave.
      end.
    end.
  end.
end.
if v-found-d-pcnt-byshop = no and
temp-dc-type.d-pcnt-byshop = yes then do:
  message
  "Для данного типа ДК УСТАНОВЛЕН флаг СКИДКА/КАТЕГОРИЯ ПО ФИРМАМ/ОБЪЕКТАМ," skip
  "но НЕ заданы скидки по умолчанию для объектов" skip
  "Продолжать?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then do:
    undo, return error.
  end.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U
and dis-card-type.d-pcnt-byshop <> temp-dc-type.d-pcnt-byshop then do:
 message
 "ВНИМАНИЕ! Вы изменили флаг СКИДКА/КАТЕГОРИЯ ПО ФИРМАМ/ОБЪЕКТАМ!" skip
 "Для того, чтобы на кассах были корректные данные по скидкам по ДК (соответствующие текущему значению флага"
 "рекомендуется послать ДК данного типу на кассу ВО ВСЕХ МАГАЗИНАХ СЕТИ!"
 "Продолжить?"
 view-as alert-box QUESTION buttons yes-no  update glog.
 if not glog then do:
   undo, return error.
  end.
end.
for each buf_rp-by-call where
          buf_rp-by-call.call_id = temp-dc-type.uniq-key-rec,
    first buf_rule-profile no-lock where
          buf_rule-profile.profile_id = buf_rp-by-call.profile_id
      and buf_rule-profile.is_Dynamic = yes
  on ERROR UNDO, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  ON STOP undo, return error '':u:
  find first buf_tt0-rp-by-call where
            buf_tt0-rp-by-call.call_id = buf_rp-by-call.call_id
        and buf_tt0-rp-by-call.profile_id =  buf_rp-by-call.profile_id
        and buf_tt0-rp-by-call.once-more =  buf_rp-by-call.once-more no-error.
  if not available buf_tt0-rp-by-call then do:
     message
     "ВНИМАНИЕ!!!" skip(0)
     "Вы собираетесь удалить профайл(ы), привязанные к данному типу ДК" skip(0)
     "ПРЕДУПРЕЖДЕНИЕ!!!" skip(0)
     "1. Изменения в работе системы лояльности по данному типу ДК" skip(0)
     "на УБД будут вступать в силу ПОСТЕПЕНЕННО - после получения пакета с данными изменениями по СПН" skip(0)
     "Это может привести к РАССИНХРОНИЗАЦИИ данных по ДК данного типа - например, к несоответствию данных по объекту и фирме и т.д." skip(0)
     "2. Даже если Вы передумаете и вновь добавите удаленные профайл(ы)," skip(0)
     "данные по продажам(накладным), закрытым в этот период будут отсутствовать" skip(0)
     "ПРОДОЛЖИТЬ СОХРАНЕНИЕ              ?"
     view-as alert-box WARNING buttons yes-no update v-ok.
     if not v-ok then do:
       undo, return .
     end.
  end.
end.
for each tt0-rp-by-call where
          tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec,
    first buf_rule-profile no-lock where
          buf_rule-profile.profile_id = tt0-rp-by-call.profile_id
      and buf_rule-profile.is_Dynamic = yes
  on ERROR UNDO, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  ON STOP undo, return error '':u:
  find first buf_rp-by-call where
            buf_rp-by-call.call_id = buf_tt0-rp-by-call.call_id
        and buf_rp-by-call.profile_id =  buf_tt0-rp-by-call.profile_id
        and buf_rp-by-call.once-more =  buf_tt0-rp-by-call.once-more no-error.
  if not available buf_rp-by-call then do:
     v-found-new = yes.
     message
     "ВНИМАНИЕ!!!" skip(0)
     "Вы собираетесь добавить профайл(ы) к данному типу ДК" skip(0)
     "ПРЕДУПРЕЖДЕНИЕ!!!" skip(0)
     "1. Изменения в работе системы лояльности по данному типу ДК" skip(0)
     "на УБД будут вступать в силу ПОСТЕПЕНЕННО - после получения пакета с данными изменениями по СПН" skip(0)
     "Это может привести к неполноте данных по некоторым объектам и т.д." skip(0)
     "2. Для некоторых профайлов предусмотрено включение/выключение правил профайла в соответствии с их бизнес-логикой," skip(0)
     "несвоевременное включение/выключение любого из этих правил МОЖЕТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
     "3. Неверно выставленные параметры МОГУТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
     "ПРОДОЛЖИТЬ СОХРАНЕНИЕ              ?"
     view-as alert-box WARNING buttons yes-no update v-ok.
     if not v-ok then do:
       undo, return .
     end.
  end.
end.
if not v-found-new  then do:
  message
  "ВНИМАНИЕ!!!" skip(0)
  "ПРЕДУПРЕЖДЕНИЕ!!!" skip(0)
  "1. Изменения в работе системы лояльности по данному типу ДК" skip(0)
  "на УБД будут вступать в силу ПОСТЕПЕНЕННО - после получения пакета с данными изменениями по СПН" skip(0)
  "Это может привести к неполноте данных по некоторым объектам и т.д." skip(0)
  "2. Для некоторых профайлов предусмотрено включение/выключение правил профайла в соответствии с их бизнес-логикой," skip(0)
  "несвоевременное включение/выключение любого правил из этих МОЖЕТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
  "3. Неверно выставленные параметры МОГУТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
  "ПРОДОЛЖИТЬ СОХРАНЕНИЕ              ?"
   view-as alert-box WARNING buttons yes-no update v-ok.
  if not v-ok then do:
    undo, return .
  end.
end.
run ref/dctypei1.p (
                 input-output rid
                ,input p-mode
                ,input temp-dc-type.emitent-host-code
                ,input temp-dc-type.type
                ,input temp-dc-type.uniq-key-rec
                ,input 0
                ,input "":U
                ,input 0
                ,INPUT temp-dc-type.d-pcnt-byshop
                ,input temp-dc-type.dflt-d-pcnt-method
                ,input temp-dc-type.dflt-credit-card
                ,input (if temp-dc-type.dflt-credit-card then temp-dc-type.lim-kr else 0)
                ,INPUT temp-dc-type.dflt-debet-card
                ,INPUT temp-dc-type.dflt-staff-card
                ,INPUT temp-dc-type.fiscal-pay
                ,INPUT temp-dc-type.mixed-pay
                ,INPUT temp-dc-type.pay-code
                ,INPUT temp-dc-type.card-media
                ,INPUT temp-dc-type.cardname-sent
                ,INPUT temp-dc-type.custom-sent
                ,input temp-dc-type.dcbyshop
                ,input temp-dc-type.dc-pfx
                ,INPUT t-check-by-mask
                ,input t-ho-join
                ,input table tt0-dis-dct-rule
                ,INPUT TABLE tt0-hist-nws-option
                ,INPUT TABLE tt0-rp-by-call
                ,INPUT TABLE tt0-rule-by-call
                ,INPUT TABLE tt0-rule-call-param) no-error .
if error-status:error then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
if return-value <> '':U then do:
  message
  error-status:get-message(1)
  return-value
  view-as alert-box .
end.
return error.
end.
END PROCEDURE.
FUNCTION get-profile-dynamic RETURNS LOGICAL
  ( p-profile_id AS INTEGER ) :
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = p-profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN ?.
RETURN buf_rule-profile.is_dynamic.
END FUNCTION.
FUNCTION get-profile-name RETURNS CHARACTER
  ( p-profile_id AS INTEGER ) :
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = p-profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN chr(63).
RETURN buf_rule-profile.NAME.
END FUNCTION.
