block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo.
define input parameter p-rowid       as rowid         no-undo .
define input parameter p-silent      as logical       no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkelcnt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chkelcnt.p $":U .
define variable vss-description as character no-undo init "Проверка показаний электронного и механических счетчиков сверки".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable ptrlprop-denstclc      as character no-undo initial 'shft_rvs-inc':U .
define variable ptrlprop-inpptrl       as character no-undo initial 'weight':U .
define variable ptrlprop-expptrl       as character no-undo initial 'volume':U .
define variable ptrlprop-autopump      as logical   no-undo initial false .
define variable ptrlprop-avtinvpm      as logical   no-undo initial false .
define variable ptrlprop-rvsnmter      as logical   no-undo initial false .
define variable ptrlprop-olddens       as logical   no-undo initial false .
define variable ptrlprop-invclipt      as integer   no-undo initial ? .
define variable ptrlprop-algrvspt      as integer   no-undo initial 1 .
define variable ptrlprop-temp-for-pomi as integer   no-undo initial 1 .
define variable ptrlprop-algoincome as integer no-undo init 0.
define variable ptrlprop-mand-choice-autocar as logical no-undo init false.
define variable ptrlprop-Delta-mass-horiz      as character no-undo .
define variable ptrlprop-Delta-mass-vert       as character no-undo .
define variable ptrlprop-calc-free-vol as logical no-undo init false.
define variable ptrlprop-calc-free-vol-sug as logical no-undo init false.
define variable ptrlprop-trn-reas-sug as logical no-undo init true.
define variable ptrlprop-rvd-own-nb as logical no-undo init false.
define variable ptrlprop-qr-scan-time as integer no-undo init 5000 .
define variable ptrlprop-block-nozzle as logical no-undo init false.
define variable ptrlprop-timeout-block-nozzle as integer no-undo init 5 .
define variable ptrlprop-autopump-skip-time as integer no-undo init 0 .
procedure get-ptrl-prop :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (get-ptrl-prop). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-ptrl-prop). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-ptrl-prop). endkey", vss-workfile )
  :
    define variable par-type          as character no-undo.
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    for each thbjattr_thbj-attr
    :
      delete thbjattr_thbj-attr .
    end.
    run adm/shattri.p
      ( input "get":U
      , input p-obj-type
      , input p-obj-code
      , input 'petrol':U
      , input  ""
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output par-type
      , input-output table thbjattr_thbj-attr
      ) no-error .
    for each thbjattr_thbj-attr
    on error undo, return error return-value
    :
      case thbjattr_thbj-attr.prop-code :
        when 'denstclc':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-denstclc = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'expptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-expptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'inpptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-inpptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'autopump':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-autopump = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'rvsnmter':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvsnmter = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'avtinvpm':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-avtinvpm = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'invclipt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-invclipt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'olddens':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-olddens = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'algrvspt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algrvspt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'temp-for-pomi':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-temp-for-pomi = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'algoincome':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algoincome = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'mand-choice-autocar':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-mand-choice-autocar = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-block-nozzle = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'timeout-block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-timeout-block-nozzle = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'Delta-mass-horiz':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-horiz = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'Delta-mass-vert':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-vert = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'calc-free-vol':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'calc-free-vol-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'trn-reas-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-trn-reas-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
              when 'rvd-own-nb':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvd-own-nb = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'qr-scan-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-qr-scan-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'autopump-skip-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-autopump-skip-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
      end case.
      delete thbjattr_thbj-attr .
    end.
  end.
  return .
end procedure.
_main-block:
do
on error  undo _main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main-block, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_rvs-doc         for ub.rvs-doc.
  define buffer prev_rvs-doc        for ub.rvs-doc.
  define buffer buf_rvs-line-pump   for ub.rvs-line-pump.
  define buffer prev_rvs-line-pump  for ub.rvs-line-pump.
  define variable v-is-overflow   as logical    no-undo .
  define variable v-log           as logical    no-undo .
  find first buf_rvs-doc no-lock
    where rowid(buf_rvs-doc) = p-rowid
    no-error .
  if not available buf_rvs-doc then do:
    undo _main-block, return error "Не найдена сверка для проверки показаний счетчиков.":U.
  end.
  if buf_rvs-doc.rvs-type <> 'смена':U then do:
    return.
  end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input buf_rvs-doc.obj-type
  , input buf_rvs-doc.obj-code
  ) .
  if ptrlprop-avtinvpm <> true then do:
    return .
  end.
  find first prev_rvs-doc no-lock
    where prev_rvs-doc.obj-type = buf_rvs-doc.obj-type
      and prev_rvs-doc.obj-code = buf_rvs-doc.obj-code
      and prev_rvs-doc.status_  = 'факт':U
      and prev_rvs-doc.rvs-type = 'смена':U
  no-error .
  if not available prev_rvs-doc then do:
    return.
  end.
  _rvs-line-pump :
  for each buf_rvs-line-pump no-lock
    where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
  on error  undo _main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo _main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first prev_rvs-line-pump no-lock
      where prev_rvs-line-pump.rvs-code     = prev_rvs-doc.rvs-code
        and prev_rvs-line-pump.obj-type     = prev_rvs-doc.obj-type
        and prev_rvs-line-pump.obj-code     = prev_rvs-doc.obj-code
        and prev_rvs-line-pump.pl-code      = buf_rvs-line-pump.pl-code
        and prev_rvs-line-pump.gds-code     = buf_rvs-line-pump.gds-code
        and prev_rvs-line-pump.pump-code    = buf_rvs-line-pump.pump-code
        and prev_rvs-line-pump.nozzle-code  = buf_rvs-line-pump.nozzle-code
    no-error .
    if available prev_rvs-line-pump then do:
      if buf_rvs-line-pump.state-el-cnt < prev_rvs-line-pump.state-el-cnt then do:
        assign
          v-is-overflow  = yes
        .
        leave _rvs-line-pump.
      end.
    end.
  end.
  if v-is-overflow = yes then do:
    if p-silent = no then do:
      message
        "ВНИМАНИЕ!" skip
        "Показания механического счетчика по сверке на конец смены МЕНЬШЕ, чем показания на начало смены." skip
        "Необходимо провести инвентаризацию счетчиков ТРК." skip
        "Сделать это автоматически?":U
      view-as alert-box question buttons yes-no update v-log.
      if v-log <> yes then do:
        undo _main-block, return error "Необходимо создать автоматический документ инвентаризации счетчиков ТРК":U .
      end.
    end.
    run str/icntauto.p
      ( input parparentproc
       ,input p-rowid
      ) no-error .
    if error-status :error then do:
      undo _main-block, return error return-value .
    end.
    for each buf_rvs-line-pump no-lock
      where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
    on error  undo _main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      find first prev_rvs-line-pump no-lock
        where prev_rvs-line-pump.rvs-code     = prev_rvs-doc.rvs-code
          and prev_rvs-line-pump.obj-type     = prev_rvs-doc.obj-type
          and prev_rvs-line-pump.obj-code     = prev_rvs-doc.obj-code
          and prev_rvs-line-pump.pl-code      = buf_rvs-line-pump.pl-code
          and prev_rvs-line-pump.gds-code     = buf_rvs-line-pump.gds-code
          and prev_rvs-line-pump.pump-code    = buf_rvs-line-pump.pump-code
          and prev_rvs-line-pump.nozzle-code  = buf_rvs-line-pump.nozzle-code
        no-error .
      if available prev_rvs-line-pump then do:
        if buf_rvs-line-pump.state-mh-cnt < prev_rvs-line-pump.state-mh-cnt then do:
          undo _main-block, return error substitute( "Показания механического счетчика ТРК &1 пистолет &2 на конец смены меньше чем на начало.&3"
                                                     + "Невозможно закрыть сверку"
                                                    , prev_rvs-line-pump.pump-code
                                                    , prev_rvs-line-pump.nozzle-code
                                                    , chr(10)
                                                    ).
        end.
      end.
    end.
  end.
end.
