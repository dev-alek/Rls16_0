def new shared variable list-mode as char no-undo.
define input parameter parparentproc as widget-handle no-undo .
define input  parameter parobj-type like ub.clients.obj-type no-undo.
define input  parameter parobj-code like ub.clients.obj-code no-undo.
define output parameter parrec-id   as recid initial ?    no-undo.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Добавление связки резервуар-ТРК-пистолет".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function nzpl-spl returns logical
(input p-obj-type as character
                                , input p-obj-code as integer):
define variable v-dopi    as integer no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-tth as handle no-undo .
define variable dflt-cd as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type1 as character no-undo .
define variable v-value-date1 as date no-undo .
define variable v-value-decimal1 as decimal no-undo .
define variable v-value-integer1 as INTEGER no-undo .
define variable v-value-logical1 AS LOGICAL no-undo .
define variable v-tth1 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date1
    ,output v-value-decimal1
    ,output v-value-integer1
    ,output v-value-logical1
    ,output v-param-type1
    ,INPUT-OUTPUT table-handle v-tth1
    ) no-error .
delete object v-tth1 no-error.
if dflt-cd <> 'IBM':U
and dflt-cd <> 'IBM-XML':U then return no.
if dflt-cd = 'IBM-XML':U then return yes.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-type-ibm':U
    ,input  'ibmspool':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error then do:
  delete object v-tth.
  return no.
end.
delete object v-tth.
assign
v-dopi = v-value-integer no-error .
if v-dopi >= 6 then return yes.
end. // FUNCTION/method
FUNCTION nzpl-two returns logical
                                 (input p-obj-type as character
                                  , input p-obj-code as integer):
  define variable v-nzpl-two as logical no-undo.
  run
  nzpl-two-proc (input p-obj-type, input p-obj-code, output v-nzpl-two).
  return v-nzpl-two.
end. // FUNCTION/method
procedure nzpl-two-proc :
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define output parameter varge-two-pl as logical   no-undo.
define buffer bf_pl-gds-pump       for ub.pl-gds-pump.
define buffer bf-other_pl-gds-pump for ub.pl-gds-pump.
//do on error undo, return error return-value :
assign
  varge-two-pl = no.
for each bf_pl-gds-pump where bf_pl-gds-pump.obj-type = p-obj-type        and
                              bf_pl-gds-pump.obj-code = p-obj-code        and
                              bf_pl-gds-pump.status_  = 'тек':U no-lock on error undo, return error return-value :
  find first bf-other_pl-gds-pump where bf-other_pl-gds-pump.obj-type  =  bf_pl-gds-pump.obj-type  and
                                        bf-other_pl-gds-pump.obj-code  =  bf_pl-gds-pump.obj-code  and
                                        bf-other_pl-gds-pump.pump-code =  bf_pl-gds-pump.pump-code and
                                        bf-other_pl-gds-pump.gds-code  =  bf_pl-gds-pump.gds-code  and
                                        bf-other_pl-gds-pump.status_   =  'тек':U        and
                                        bf-other_pl-gds-pump.pl-code   <> bf_pl-gds-pump.pl-code   no-lock no-error.
  if available bf-other_pl-gds-pump then do:
    assign
      varge-two-pl = yes.
    leave.
  end.
end.
//end.
end. // procedure/method .
define variable varmes-log as logical no-undo.
define variable varobj-type like ub.clients.obj-type no-undo.
define variable varobj-code like ub.clients.obj-code no-undo.
define variable varbuttons  as   character        no-undo.
define variable varps-upd   as   logical          no-undo.
procedure plpmnzav:
  define input parameter parobj-type    like ub.clients.obj-type   no-undo.
  define input parameter parobj-code    like ub.clients.obj-code   no-undo.
  define input parameter parpl-code     like ub.place.pl-code      no-undo.
  define input parameter parpump-code   like ub.pump.pump-code     no-undo.
  define input parameter parnozzle-code like ub.nozzle.nozzle-code no-undo.
  do
  on error undo, return error return-value
  :
    define buffer bf_clients              for ub.clients.
    define buffer bf_place                for ub.place.
    define buffer bf_pump                 for ub.pump.
    define buffer bf_nozzle               for ub.nozzle.
    define buffer bf_pl-pump              for ub.pl-pump.
    define buffer bf_pump-nozzle          for ub.pump-nozzle.
    define buffer bf_pl-pump-nozzle       for ub.pl-pump-nozzle.
    define buffer bf-other_pl-pump-nozzle for ub.pl-pump-nozzle.
    define buffer bf_rvs-doc              for ub.rvs-doc.
    define buffer bf_icnt-doc             for ub.icnt-doc.
    define buffer bf_pl-gds-pump          for ub.pl-gds-pump.
    define buffer bf-other_pl-gds-pump    for ub.pl-gds-pump.
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock no-error.
if not available bf_clients then
   return error SUBSTITUTE("Нет такого объекта &1 &2 .", parobj-type, parobj-code).
find first bf_pump where bf_pump.obj-type  = parobj-type  and
                         bf_pump.obj-code  = parobj-code  and
                         bf_pump.pump-code = parpump-code no-lock no-error.
if not available bf_pump then
   return error SUBSTITUTE("Нет ТРК с номером &1", parpump-code) + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code).
find first bf_place where bf_place.obj-type = parobj-type and
                          bf_place.obj-code = parobj-code and
                          bf_place.pl-code  = parpl-code  no-lock no-error.
if not available bf_place then return error SUBSTITUTE("Нет такого складского места &1", parpl-code) + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code).
find first bf_nozzle where bf_nozzle.obj-type    = parobj-type    and
                           bf_nozzle.obj-code    = parobj-code    and
                           bf_nozzle.nozzle-code = parnozzle-code no-lock no-error.
if not available bf_nozzle then
   return error SUBSTITUTE("Нет пистолета ТРК с номером &1", parnozzle-code) + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code).
find first bf_pl-pump where bf_pl-pump.obj-type  = parobj-type  and
                            bf_pl-pump.obj-code  = parobj-code  and
                            bf_pl-pump.pl-code   = parpl-code   and
                            bf_pl-pump.pump-code = parpump-code no-lock no-error.
if not available bf_pl-pump then
   return error SUBSTITUTE("Нет записи резервуар-ТРК с номером резервуара &1 и номером ТРК &2",
                           parpl-code, parpump-code) + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code).
find first bf_pump-nozzle where bf_pump-nozzle.obj-type    = parobj-type    and
                                bf_pump-nozzle.obj-code    = parobj-code    and
                                bf_pump-nozzle.pump-code   = parpump-code   and
                                bf_pump-nozzle.nozzle-code = parnozzle-code no-lock no-error.
if not available bf_pump-nozzle then
   return error SUBSTITUTE("Нет записи ТРК-пистолет с номером ТРК &1 и номером пистолета &2",
                                                        parpump-code,
                                                        parnozzle-code) + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code).
 find first bf_rvs-doc where bf_rvs-doc.obj-type =  parobj-type       and
                             bf_rvs-doc.obj-code =  parobj-code       and
                             bf_rvs-doc.status_  <> 'факт':U           and
                             bf_rvs-doc.rvs-type <> 'перед_док':U and
                             bf_rvs-doc.rvs-type <> 'после_док':U  and
                             bf_rvs-doc.rvs-type <> 'проверка':U       no-lock no-error.
if available bf_rvs-doc then do:
   return error SUBSTITUTE("На объекте есть открытый документ сверки &1 .", bf_rvs-doc.rvs-code).
end.
find first bf_icnt-doc where bf_icnt-doc.obj-type  =  parobj-type and
                             bf_icnt-doc.obj-code  =  parobj-code and
                             bf_icnt-doc.status_   <> 'факт':U     no-lock no-error.
if available bf_icnt-doc then do:
   return error SUBSTITUTE("На объекте есть открытый документ инвентаризации счетчиков ТРК &1 .", bf_icnt-doc.doc-code).
end.
    if nzpl-spl(parobj-type, parobj-code) <> yes then do:
      find first bf_pl-pump-nozzle no-lock
        where bf_pl-pump-nozzle.obj-type   = parobj-type
          and bf_pl-pump-nozzle.obj-code   = parobj-code
          and bf_pl-pump-nozzle.pl-code    = parpl-code
          and bf_pl-pump-nozzle.pump-code  = parpump-code
        no-error.
      if available bf_pl-pump-nozzle then do:
        return error substitute("Резервуар &1 уже связан с ТРК &2, через пистолет &3", parpl-code, parpump-code, bf_pl-pump-nozzle.nozzle-code) + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code).
      end.
    end.
    do transaction
    on error undo, return error return-value
    :
      find first bf_pl-gds-pump no-lock
        where bf_pl-gds-pump.obj-type  = parobj-type
          and bf_pl-gds-pump.obj-code  = parobj-code
          and bf_pl-gds-pump.pl-code   = parpl-code
          and bf_pl-gds-pump.pump-code = parpump-code
        no-error.
      if available bf_pl-gds-pump then do:
        find first bf-other_pl-gds-pump no-lock
          where bf-other_pl-gds-pump.obj-type  = bf_pl-gds-pump.obj-type
            and bf-other_pl-gds-pump.obj-code  = bf_pl-gds-pump.obj-code
            and bf-other_pl-gds-pump.gds-code  = bf_pl-gds-pump.gds-code
            and bf-other_pl-gds-pump.pump-code = bf_pl-gds-pump.pump-code
            and bf-other_pl-gds-pump.pl-code  <> bf_pl-gds-pump.pl-code
          no-error.
        if available bf-other_pl-gds-pump then do:
          if nzpl-spl(parobj-type, parobj-code) <> yes then do:
            find first bf-other_pl-pump-nozzle no-lock
              where bf-other_pl-pump-nozzle.obj-type  = bf-other_pl-gds-pump.obj-type
                and bf-other_pl-pump-nozzle.obj-code  = bf-other_pl-gds-pump.obj-code
                and bf-other_pl-pump-nozzle.pl-code   = bf-other_pl-gds-pump.pl-code
                and bf-other_pl-pump-nozzle.pump-code = bf-other_pl-gds-pump.pump-code
              no-error.
            if available bf-other_pl-pump-nozzle then do:
              if bf-other_pl-pump-nozzle.nozzle-code <> parnozzle-code then do:
                return error substitute ("На объекте &1 &2 ТРК &3 через пистолет &4 торгует топливом с внутренним кодом &5 из резервуара &6.&7"
                                         + "КАСССА не возвращает номер пистолета в чеке, .&7"
                                         + "поэтому нельзя торговать одним и тем же топливом на одной ТРК через разные пистолеты.&7"
                                         , bf-other_pl-pump-nozzle.obj-type
                                         , bf-other_pl-pump-nozzle.obj-code
                                         , bf-other_pl-pump-nozzle.pump-code
                                         , bf-other_pl-pump-nozzle.nozzle-code
                                         , bf-other_pl-gds-pump.gds-code
                                         , bf-other_pl-gds-pump.pl-code
                                         , chr(10)
                                        ).
              end.
            end.
          end.
          else do:
            find current bf_pl-gds-pump exclusive-lock.
            assign
              bf_pl-gds-pump.status_ = 'блок':U.
          end.
        end.
        for each bf-other_pl-pump-nozzle where bf-other_pl-pump-nozzle.obj-type    = parobj-type
                                            and bf-other_pl-pump-nozzle.obj-code    = parobj-code
                                            and bf-other_pl-pump-nozzle.pump-code   = parpump-code
                                            and bf-other_pl-pump-nozzle.nozzle-code = parnozzle-code
                                            no-lock on error undo, return error return-value :
          find first bf-other_pl-gds-pump where bf-other_pl-gds-pump.obj-type  = bf-other_pl-pump-nozzle.obj-type
                                            and bf-other_pl-gds-pump.obj-code  = bf-other_pl-pump-nozzle.obj-code
                                            and bf-other_pl-gds-pump.pl-code   = bf-other_pl-pump-nozzle.pl-code
                                            and bf-other_pl-gds-pump.pump-code = bf-other_pl-pump-nozzle.pump-code no-lock no-error.
          if available bf-other_pl-gds-pump then do:
            if bf-other_pl-gds-pump.gds-code <> bf_pl-gds-pump.gds-code then do:
              return error substitute ("На объекте &1 &2 ТРК &3 через пистолет &4 торгует топливом с внутренним кодом &5 из резервуара &6. Вы хотите торговать топливом с внутренним кодом &7. Разными видами топлива через один пистолет на одной ТРК торговать нельзя.",
                                        bf-other_pl-pump-nozzle.obj-type,
                                        bf-other_pl-pump-nozzle.obj-code,
                                        bf-other_pl-pump-nozzle.pump-code,
                                        bf-other_pl-pump-nozzle.nozzle-code,
                                        bf-other_pl-gds-pump.gds-code,
                                        bf-other_pl-gds-pump.pl-code,
                                        bf_pl-gds-pump.gds-code).
            end.
          end.
        end.
      end.
      create bf_pl-pump-nozzle.
      assign
        bf_pl-pump-nozzle.obj-type    = parobj-type
        bf_pl-pump-nozzle.obj-code    = parobj-code
        bf_pl-pump-nozzle.pl-code     = parpl-code
        bf_pl-pump-nozzle.pump-code   = parpump-code
        bf_pl-pump-nozzle.nozzle-code = parnozzle-code
      .
    end.
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
function is-sug returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'lgas':U) no-error.
return result.
end function.
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-nozzle
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-nozzle"
     SIZE 3 BY .88.
DEFINE BUTTON b-place
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON b-pump
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE varnozzle-code AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Номер пистолета ТРК"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE varpl-code AS INTEGER FORMAT "99999999999":U INITIAL 0
     LABEL "Бар-код резервуара"
     VIEW-AS FILL-IN
     SIZE 10.38 BY 1 NO-UNDO.
DEFINE VARIABLE varpump-code AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Номер ТРК"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varpl-code AT ROW 2.54 COL 2.88
     b-place AT ROW 2.67 COL 34
     varpump-code AT ROW 3.92 COL 20.88 COLON-ALIGNED
     b-pump AT ROW 4.04 COL 34
     varnozzle-code AT ROW 5.29 COL 20.88 COLON-ALIGNED
     b-nozzle AT ROW 5.29 COL 34
     SPACE(0.99) SKIP(0.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Добавление  резервуар-ТРК"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-nozzle IN FRAME Dialog-Frame
DO:
  define variable varrec-id_nozzle as recid initial ? no-undo.
  define buffer bf_nozzle for ub.nozzle.
  run str/nozzlerf.w
    ( input  parparentproc
     ,input  parobj-type
     ,input  parobj-code
     ,output varrec-id_nozzle
    ).
  if varrec-id_nozzle <> ? then do:
     find first bf_nozzle where recid(bf_nozzle) = varrec-id_nozzle no-lock no-error.
     if available bf_nozzle then do:
        display bf_nozzle.nozzle-code @ varnozzle-code with frame Dialog-Frame.
     end.
  end.
END.
ON CHOOSE OF b-place IN FRAME Dialog-Frame
DO:
  define variable place-list as character no-undo .
  define variable v-value           as character no-undo .
  define variable v-ok              as logical   no-undo .
  define buffer buf_pl-gds for ub.pl-gds .
  run ref/pl-list.w (
                 input parparentproc
                ,input "b-sel"
                ,input parobj-type
                ,input parobj-code
                ,input 'объект':U
               , input-output place-list).
  if place-list = "cancel"
  then do :
    return no-apply .
  end .
  if place-list <> '':U then do:
    FIND FIRST place No-LOCK WHERE recid(place) = integer(entry(1, place-list)) NO-ERROR.
    if available place
    then do :
      find first buf_pl-gds no-lock where buf_pl-gds.obj-type = place.obj-type
                                      and buf_pl-gds.obj-code = place.obj-code
                                      and buf_pl-gds.pl-code = place.pl-code
                                      no-error .
      if available buf_pl-gds
      then do :
        run placelib_get-attr  (
           input "place-com-tanks"
          ,input buf_pl-gds.obj-code
          ,input buf_pl-gds.obj-type
          ,input buf_pl-gds.pl-code
          ,output v-value
          ,output v-ok      )
        no-error.
        if v-ok
        and v-value > ""
        then do :
          run placelib_get-attr  (
             input "place-is-main"
            ,input buf_pl-gds.obj-code
            ,input buf_pl-gds.obj-type
            ,input buf_pl-gds.pl-code
            ,output v-value
            ,output v-ok      )
          no-error.
          if v-ok
          and not logical(v-value)
          then do :
            message 'Установить связь Резервуар-ТРК-Пистолеты можно только с резервуаром с отметкой "Главный"!' view-as alert-box .
            return no-apply .
          end .
        end .
      end .
      display place.pl-code @ varpl-code with frame Dialog-Frame.
    end .
  end.
END.
ON CHOOSE OF b-pump IN FRAME Dialog-Frame
DO:
  define variable varrec-id_pump as recid initial ? no-undo.
  define buffer bf_pump for ub.pump.
  run str/pumprf.w
    ( input parparentproc
     ,input  parobj-type
     ,input  parobj-code
     ,output varrec-id_pump
    ).
  if varrec-id_pump <> ? then do:
     find first bf_pump where recid(bf_pump) = varrec-id_pump no-lock no-error.
     if available bf_pump then do:
        display bf_pump.pump-code @ varpump-code with frame Dialog-Frame.
     end.
  end.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  assign frame Dialog-Frame
    varpl-code
    varpump-code
    varnozzle-code
  .
  run plpmnzav in this-procedure
    ( input parobj-type
     ,input parobj-code
     ,input varpl-code
     ,input varpump-code
     ,input varnozzle-code
    ) no-error.
  if error-status:error then do:
message
  vss-workfile vss-revision vss-description skip
  "Ошибка при создании записи резервуар-ТРК-пистолет" skip
  "-----------Cистемная ошибка------------" skip
  return-value skip
  "------Ошибка исполнения программы------" skip
  trim(error-status :get-message(1)) +
  trim(error-status :get-message(2)) +
  trim(error-status :get-message(3)) +
  trim(error-status :get-message(4)) +
  trim(error-status :get-message(5)) skip
  view-as alert-box error .
     return no-apply.
  end.
  find first ub.pl-pump-nozzle no-lock
    where ub.pl-pump-nozzle.obj-type    = parobj-type
      and ub.pl-pump-nozzle.obj-code    = parobj-code
      and ub.pl-pump-nozzle.pl-code     = varpl-code
      and ub.pl-pump-nozzle.pump-code   = varpump-code
      and ub.pl-pump-nozzle.nozzle-code = varnozzle-code
    .
  assign
    parrec-id = recid( ub.pl-pump-nozzle )
  .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varpl-code varpump-code varnozzle-code
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help varpl-code b-place varpump-code b-pump
         varnozzle-code b-nozzle
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
