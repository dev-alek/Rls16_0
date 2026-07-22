define input  parameter parparentproc      as widget-handle no-undo .
define input  parameter p-callback-handle  as handle    no-undo .
define input  parameter p-db-num           as integer   no-undo .
define input  parameter p-user-id          as character no-undo .
define input  parameter p-curr-host-code   as integer   no-undo .
define input  parameter p-bttns            as character NO-UNDO .
define output parameter p-user-select      as logical   no-undo .
define output parameter p-select-host-code as integer   no-undo .
DEFINE OUTPUT PARAMETER p-List-select-host-code AS CHARACTER NO-UNDO INITIAL "".
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список фирм системы".
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
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-b-attr :
define input parameter p-mode as character no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define variable v-sts as integer no-undo .
define variable vattr-codes as character no-undo .
define variable vattr-labels as character no-undo .
define variable ii as integer no-undo .
define variable v-attr-code like ub.clients-attr.attr-code no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical   no-undo .
define variable attr-value as char no-undo .
define variable v-spr as character no-undo .
define variable v-title as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ok as integer no-undo .
define variable v-rid-list as character no-undo .
define variable v-rec as recid no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-firm-code as integer   no-undo .
define variable v-from-obj-code  as integer no-undo .
define variable v-found as decimal no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_db for ub.db.
do
on error undo, return error
:
assign
vattr-codes = "":U
vattr-labels = "":U
.
_II:
DO ii = 1 to num-entries('autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U):
  run thbjattr_code (
                       input entry(ii, 'autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U)
                      ,input   '':U
                      ,output  attr-label
                      ,output  attr-user-can-edit
                      ,output  attr-output-display
                      ,output  attr-other
                      ,output v-prop-list
                      ,output v-prop-type-list
                      ,output v-prop-label-list
                      ,output v-global
                      ,output v-host
                      ,output v-shop
                      ,output v-store
                      ,output v-db
                    ) no-error.
    .
    if NOT error-status:error
    and attr-user-can-edit
    and index(attr-other, "spr-ext=") > 0
    anD (if p-obj-type = 'маг':U
         then v-shop
         else (if p-obj-type = 'скл':U
               then v-store
               else (if p-obj-type = 'орг':U
                     then v-host
                     else (if p-obj-type = 'БД':U
                          then v-db
                          else v-global)
                    )
               )
         ) then do:
      if entry(ii, 'autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U) = 'alias-tpsi':U then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'tpsi'
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
        if error-status:error
        or (conf-par <> "yes") then next _ii.
      end.
      assign
      vattr-codes = vattr-codes + chr(44) + entry(ii, 'autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U)
      vattr-labels = vattr-labels + chr(44) + attr-label
      .
    end.
end.
CASE p-mode:
  when 'ПРОСМОТР':U then do:
    assign
    v-title = "Выберите типы параметров для просмотра".
  end.
  when 'ИЗМЕНЕНИЕ':U then do:
    assign
    v-title = "Выберите типы параметров для редактирования".
  end.
  when  'КОПИРОВАНИЕ':U then do:
    assign
    v-title = "Выберите типы параметров для копирования".
  end.
END CASE.
run gbl/d-list.w (
               INPUT (if p-mode = 'КОПИРОВАНИЕ':U then "b-sel,b-mark":U else "b-sel":U)
              ,INPUT v-title
              ,INPUT vattr-codes
              ,INPUT vattr-labels
              ,INPUT chr(44)
              ,INPUT "":U
              ,output v-attr-code).
IF v-attr-code = "":u THEN do:
  RETURN ''.
end.
if p-mode = 'ПРОСМОТР':U
or p-mode = 'ИЗМЕНЕНИЕ':U then do:
  run thbjattr_code  in this-procedure (
       input   v-attr-code
      ,input   '':U
      ,output  attr-label
      ,output  attr-user-can-edit
      ,output  attr-output-display
      ,output  attr-other
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
  ).
  do ii = 1 to num-entries(attr-other, chr(47)):
    if entry(ii, attr-other, chr(47)) begins "spr-ext=":U then do:
      assign
      v-spr = entry(2, entry(ii, attr-other, chr(47)), "=").
    end.
  end.
  run value(v-spr) (
                   input parparentproc
                  ,input p-mode
                  ,input p-obj-type
                  ,input p-obj-code
                  ).
end.
else do:
   if p-obj-type = 'маг':U then do:
    message
    "Выберите магазин для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
      run adm/shops.w ( input parparentproc
                       ,input "b-sel"
                       ,input-output v-rid-list
                       ,no ).
     if v-rid-list = "":U then return.
     find first buf_shop no-lock where
              recid(buf_shop) = integer(v-rid-list) .
     v-from-obj-code = buf_shop.obj-code.
   end.
   if p-obj-type = 'орг':U then do:
      message
      "Выберите ФИРМУ для копирования ПАРАМЕТРОВ"
      view-as alert-box WARNING.
      run adm/sconfs.w (
            input parParentProc
          , input "b-sel":U
          , input no
          , input 0
          , output v-firm-code
          , input-output v-rid-list
      ) no-error.
      if v-rid-list = "":U then return.
    find first buf_sysconf no-lock
                      where recid(buf_sysconf) = integer(entry(1, v-rid-list)).
    v-from-obj-code = buf_sysconf.host-code.
   end.
   if p-obj-type = 'скл':U then do:
    message
    "Выберите склад для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
      run adm/stores.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output v-rid-list
                        ,input no ).
     if v-rid-list = "":U then return.
     find first buf_store no-lock where
              recid(buf_store) = integer(v-rid-list) .
     v-from-obj-code = buf_store.obj-code.
   end.
   if p-obj-type = 'БД':U then do:
      message
      "Выберите БД для копирования ПАРАМЕТРОВ"
      view-as alert-box WARNING.
      run adm/dbs.w (
            input parParentProc
          , input 'ПРОСМОТР':U
          , output v-rec
      ) no-error.
      if v-rec = ? then return.
    find first buf_db no-lock
                      where recid(buf_db) = v-rec.
    v-from-obj-code = buf_db.db-num.
   end.
   if (p-obj-type = 'маг':U
   AND p-obj-code = buf_shop.obj-code )
   or (p-obj-type = 'скл':U
   AND p-obj-code = buf_store.obj-code )
   or (p-obj-type = 'орг':U
   AND p-obj-code = buf_sysconf.host-code )
   or (p-obj-type = 'БД':U
   AND p-obj-code = buf_db.db-num )
   or (p-obj-type = '':U
   AND p-obj-code = 0 )
   then do:
     message "Нельзя копировать ПАРАМЕТРЫ самих в себя"
     view-as alert-box error .
     return error .
   end.
   run waitfram-show in this-procedure ( input "Ждите..." ).
   DO ii = 1 to num-entries(v-attr-code):
      for each thbjattr_thbj-attr:
        delete thbjattr_thbj-attr.
      end.
      assign
      v-ii = v-ii + 1.
      run thbjattr_get-section  in this-procedure (
           input  p-obj-type
          ,input  v-from-obj-code
          ,input  entry(ii, v-attr-code)
          ,input '':U
          ,input-output table thbjattr_thbj-attr
          ,output v-found
                                              ) no-error .
      if not error-status:error then do:
        run thbjattr_set-section in this-procedure (
                                               input p-obj-type
                                              ,input p-obj-code
                                              ,input entry(ii, v-attr-code)
                                              ,input table thbjattr_thbj-attr ) no-error .
        if not error-status:error then
        assign
        v-ok = v-ok + 1
        .
      end.
   end.
   run waitfram-hide in this-procedure .
   if v-ii = v-ok then do:
      message
      substitute("Скопировано &1 параметров с &4&5 на &2&3"
                 , v-ok
                 , p-obj-type
                 , p-obj-code
                 , p-obj-type
                 , v-from-obj-code
                 )
      view-as alert-box .
   end.
   else do:
      message
      substitute("Из &1 параметров удалось скопировать &2 параметров с &3&4 на &5&6"
                 , v-ii
                 , v-ok
                 , p-obj-type
                 , p-obj-code
                 , p-obj-type
                 , v-from-obj-code
                 )
      view-as alert-box WARNING.
   end.
end.
end.
end procedure.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-colwidth-db-num          as integer   no-undo .
define variable v-colwidth-user-id         as character no-undo .
define variable v-colwidth-program-name    as character no-undo .
define variable v-colwidth-width-01        as decimal   no-undo .
define variable v-colwidth-width-02        as decimal   no-undo .
define variable v-colwidth-width-03        as decimal   no-undo .
define variable v-colwidth-width-04        as decimal   no-undo .
define variable v-colwidth-width-05        as decimal   no-undo .
define variable v-colwidth-width-06        as decimal   no-undo .
define variable v-colwidth-width-07        as decimal   no-undo .
define variable v-colwidth-width-08        as decimal   no-undo .
define variable v-colwidth-width-09        as decimal   no-undo .
define variable v-colwidth-width-10        as decimal   no-undo .
define variable v-colwidth-width-11        as decimal   no-undo .
define variable v-colwidth-width-12        as decimal   no-undo .
define variable v-colwidth-width-13        as decimal   no-undo .
define variable v-colwidth-width-14        as decimal   no-undo .
define variable v-colwidth-width-15        as decimal   no-undo .
define variable v-colwidth-width-16        as decimal   no-undo .
define variable v-colwidth-width-17        as decimal   no-undo .
define variable v-colwidth-width-18        as decimal   no-undo .
define variable v-colwidth-width-19        as decimal   no-undo .
define variable v-colwidth-width-20        as decimal   no-undo .
define variable v-colwidth-width-01-shadow as decimal   no-undo .
define variable v-colwidth-width-02-shadow as decimal   no-undo .
define variable v-colwidth-width-03-shadow as decimal   no-undo .
define variable v-colwidth-width-04-shadow as decimal   no-undo .
define variable v-colwidth-width-05-shadow as decimal   no-undo .
define variable v-colwidth-width-06-shadow as decimal   no-undo .
define variable v-colwidth-width-07-shadow as decimal   no-undo .
define variable v-colwidth-width-08-shadow as decimal   no-undo .
define variable v-colwidth-width-09-shadow as decimal   no-undo .
define variable v-colwidth-width-10-shadow as decimal   no-undo .
define variable v-colwidth-width-11-shadow as decimal   no-undo .
define variable v-colwidth-width-12-shadow as decimal   no-undo .
define variable v-colwidth-width-13-shadow as decimal   no-undo .
define variable v-colwidth-width-14-shadow as decimal   no-undo .
define variable v-colwidth-width-15-shadow as decimal   no-undo .
define variable v-colwidth-width-16-shadow as decimal   no-undo .
define variable v-colwidth-width-17-shadow as decimal   no-undo .
define variable v-colwidth-width-18-shadow as decimal   no-undo .
define variable v-colwidth-width-19-shadow as decimal   no-undo .
define variable v-colwidth-width-20-shadow as decimal   no-undo .
procedure colwidth-read :
  define input  parameter p-db-num       as integer   no-undo .
  define input  parameter p-user-id      as character no-undo .
  define input  parameter p-program-name as character no-undo .
  define output parameter p-data-exist   as logical   no-undo .
  define buffer buf_rpt-option for ubflt.rpt-option .
  do
  on error undo, return error return-value
  :
    assign
      v-colwidth-db-num       = p-db-num
      v-colwidth-user-id      = p-user-id
      v-colwidth-program-name = p-program-name
    .
    find first buf_rpt-option no-lock
      where buf_rpt-option.rpt-name    = p-program-name
        and buf_rpt-option.rpt-code    = 'column-width':U
        and buf_rpt-option.user-db-num = p-db-num
        and buf_rpt-option.user-id     = p-user-id
      no-error .
    if available buf_rpt-option
    then do:
      assign
        p-data-exist        = true
        v-colwidth-width-01 = buf_rpt-option.param-decimal-01-value
        v-colwidth-width-02 = buf_rpt-option.param-decimal-02-value
        v-colwidth-width-03 = buf_rpt-option.param-decimal-03-value
        v-colwidth-width-04 = buf_rpt-option.param-decimal-04-value
        v-colwidth-width-05 = buf_rpt-option.param-decimal-05-value
        v-colwidth-width-06 = buf_rpt-option.param-decimal-06-value
        v-colwidth-width-07 = buf_rpt-option.param-decimal-07-value
        v-colwidth-width-08 = buf_rpt-option.param-decimal-08-value
        v-colwidth-width-09 = buf_rpt-option.param-decimal-09-value
        v-colwidth-width-10 = buf_rpt-option.param-decimal-10-value
        v-colwidth-width-11 = buf_rpt-option.param-decimal-11-value
        v-colwidth-width-12 = buf_rpt-option.param-decimal-12-value
        v-colwidth-width-13 = buf_rpt-option.param-decimal-13-value
        v-colwidth-width-14 = buf_rpt-option.param-decimal-14-value
        v-colwidth-width-15 = buf_rpt-option.param-decimal-15-value
        v-colwidth-width-16 = buf_rpt-option.param-decimal-16-value
        v-colwidth-width-17 = buf_rpt-option.param-decimal-17-value
        v-colwidth-width-18 = buf_rpt-option.param-decimal-18-value
        v-colwidth-width-19 = buf_rpt-option.param-decimal-19-value
        v-colwidth-width-20 = buf_rpt-option.param-decimal-20-value
      .
    end.
    else do:
      assign
        p-data-exist        = false
        v-colwidth-width-01 = 0
        v-colwidth-width-02 = 0
        v-colwidth-width-03 = 0
        v-colwidth-width-04 = 0
        v-colwidth-width-05 = 0
        v-colwidth-width-06 = 0
        v-colwidth-width-07 = 0
        v-colwidth-width-08 = 0
        v-colwidth-width-09 = 0
        v-colwidth-width-10 = 0
        v-colwidth-width-11 = 0
        v-colwidth-width-12 = 0
        v-colwidth-width-13 = 0
        v-colwidth-width-14 = 0
        v-colwidth-width-15 = 0
        v-colwidth-width-16 = 0
        v-colwidth-width-17 = 0
        v-colwidth-width-18 = 0
        v-colwidth-width-19 = 0
        v-colwidth-width-20 = 0
      .
    end.
    assign
      v-colwidth-width-01-shadow = v-colwidth-width-01
      v-colwidth-width-02-shadow = v-colwidth-width-02
      v-colwidth-width-03-shadow = v-colwidth-width-03
      v-colwidth-width-04-shadow = v-colwidth-width-04
      v-colwidth-width-05-shadow = v-colwidth-width-05
      v-colwidth-width-06-shadow = v-colwidth-width-06
      v-colwidth-width-07-shadow = v-colwidth-width-07
      v-colwidth-width-08-shadow = v-colwidth-width-08
      v-colwidth-width-09-shadow = v-colwidth-width-09
      v-colwidth-width-10-shadow = v-colwidth-width-10
      v-colwidth-width-11-shadow = v-colwidth-width-11
      v-colwidth-width-12-shadow = v-colwidth-width-12
      v-colwidth-width-13-shadow = v-colwidth-width-13
      v-colwidth-width-14-shadow = v-colwidth-width-14
      v-colwidth-width-15-shadow = v-colwidth-width-15
      v-colwidth-width-16-shadow = v-colwidth-width-16
      v-colwidth-width-17-shadow = v-colwidth-width-17
      v-colwidth-width-18-shadow = v-colwidth-width-18
      v-colwidth-width-19-shadow = v-colwidth-width-19
      v-colwidth-width-20-shadow = v-colwidth-width-20
    .
  end.
end procedure.
procedure colwidth-write :
  define buffer buf_rpt-option for ubflt.rpt-option .
  do
  on error undo, return error return-value
  :
    if v-colwidth-width-01-shadow <> v-colwidth-width-01
    or v-colwidth-width-02-shadow <> v-colwidth-width-02
    or v-colwidth-width-03-shadow <> v-colwidth-width-03
    or v-colwidth-width-04-shadow <> v-colwidth-width-04
    or v-colwidth-width-05-shadow <> v-colwidth-width-05
    or v-colwidth-width-06-shadow <> v-colwidth-width-06
    or v-colwidth-width-07-shadow <> v-colwidth-width-07
    or v-colwidth-width-08-shadow <> v-colwidth-width-08
    or v-colwidth-width-09-shadow <> v-colwidth-width-09
    or v-colwidth-width-10-shadow <> v-colwidth-width-10
    or v-colwidth-width-11-shadow <> v-colwidth-width-11
    or v-colwidth-width-12-shadow <> v-colwidth-width-12
    or v-colwidth-width-13-shadow <> v-colwidth-width-13
    or v-colwidth-width-14-shadow <> v-colwidth-width-14
    or v-colwidth-width-15-shadow <> v-colwidth-width-15
    or v-colwidth-width-16-shadow <> v-colwidth-width-16
    or v-colwidth-width-17-shadow <> v-colwidth-width-17
    or v-colwidth-width-18-shadow <> v-colwidth-width-18
    or v-colwidth-width-19-shadow <> v-colwidth-width-19
    or v-colwidth-width-20-shadow <> v-colwidth-width-20
    then do:
      do transaction
      on error undo, return error return-value
      :
        find first buf_rpt-option exclusive-lock
          where buf_rpt-option.rpt-name    = v-colwidth-program-name
            and buf_rpt-option.rpt-code    = 'column-width':U
            and buf_rpt-option.user-db-num = v-colwidth-db-num
            and buf_rpt-option.user-id     = v-colwidth-user-id
          no-error .
        if not available buf_rpt-option
        then do:
          create buf_rpt-option .
          assign
            buf_rpt-option.rpt-name    = v-colwidth-program-name
            buf_rpt-option.rpt-code    = 'column-width':U
            buf_rpt-option.user-db-num = v-colwidth-db-num
            buf_rpt-option.user-id     = v-colwidth-user-id
          .
        end.
        assign
          buf_rpt-option.param-decimal-01-value = v-colwidth-width-01
          buf_rpt-option.param-decimal-02-value = v-colwidth-width-02
          buf_rpt-option.param-decimal-03-value = v-colwidth-width-03
          buf_rpt-option.param-decimal-04-value = v-colwidth-width-04
          buf_rpt-option.param-decimal-05-value = v-colwidth-width-05
          buf_rpt-option.param-decimal-06-value = v-colwidth-width-06
          buf_rpt-option.param-decimal-07-value = v-colwidth-width-07
          buf_rpt-option.param-decimal-08-value = v-colwidth-width-08
          buf_rpt-option.param-decimal-09-value = v-colwidth-width-09
          buf_rpt-option.param-decimal-10-value = v-colwidth-width-10
          buf_rpt-option.param-decimal-11-value = v-colwidth-width-11
          buf_rpt-option.param-decimal-12-value = v-colwidth-width-12
          buf_rpt-option.param-decimal-13-value = v-colwidth-width-13
          buf_rpt-option.param-decimal-14-value = v-colwidth-width-14
          buf_rpt-option.param-decimal-15-value = v-colwidth-width-15
          buf_rpt-option.param-decimal-16-value = v-colwidth-width-16
          buf_rpt-option.param-decimal-17-value = v-colwidth-width-17
          buf_rpt-option.param-decimal-18-value = v-colwidth-width-18
          buf_rpt-option.param-decimal-19-value = v-colwidth-width-19
          buf_rpt-option.param-decimal-20-value = v-colwidth-width-20
        .
      end.
      assign
        v-colwidth-width-01-shadow = v-colwidth-width-01
        v-colwidth-width-02-shadow = v-colwidth-width-02
        v-colwidth-width-03-shadow = v-colwidth-width-03
        v-colwidth-width-04-shadow = v-colwidth-width-04
        v-colwidth-width-05-shadow = v-colwidth-width-05
        v-colwidth-width-06-shadow = v-colwidth-width-06
        v-colwidth-width-07-shadow = v-colwidth-width-07
        v-colwidth-width-08-shadow = v-colwidth-width-08
        v-colwidth-width-09-shadow = v-colwidth-width-09
        v-colwidth-width-10-shadow = v-colwidth-width-10
        v-colwidth-width-11-shadow = v-colwidth-width-11
        v-colwidth-width-12-shadow = v-colwidth-width-12
        v-colwidth-width-13-shadow = v-colwidth-width-13
        v-colwidth-width-14-shadow = v-colwidth-width-14
        v-colwidth-width-15-shadow = v-colwidth-width-15
        v-colwidth-width-16-shadow = v-colwidth-width-16
        v-colwidth-width-17-shadow = v-colwidth-width-17
        v-colwidth-width-18-shadow = v-colwidth-width-18
        v-colwidth-width-19-shadow = v-colwidth-width-19
        v-colwidth-width-20-shadow = v-colwidth-width-20
      .
    end.
  end.
end procedure.
define variable vss-include-info7 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_twowin_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmName       as character
    field itmDesc       as character
    field itmSelected   as logical
    field selLeft       as logical
    field selRight      as logical
    index pi is primary unique
        itm-key
    index ie
        itmExtKey
.
define temp-table temp_twowin_itemsSelected no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-twowin7-itm-key    as integer      no-undo.
procedure twowin_clear :
    define buffer buf_temp_twowin_items        for temp_twowin_items.
do
for buf_temp_twowin_items
on error undo, return error
:
    empty temp-table buf_temp_twowin_items.
end.
end procedure.
procedure twowin_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
    define buffer buf_temp_twowin_items        for temp_twowin_items.
do
for buf_temp_twowin_items
on error undo, return error
:
    assign
        v-twowin7-itm-key = v-twowin7-itm-key + 1
    .
    create temp_twowin_items.
    assign
        temp_twowin_items.itm-key      = v-twowin7-itm-key
        temp_twowin_items.itmExtKey    = p-ext-key
        temp_twowin_items.itmName      = p-item-name
        temp_twowin_items.itmDesc      = p-item-desc
        temp_twowin_items.itmSelected  = p-selected
        temp_twowin_items.selLeft      = no
        temp_twowin_items.selRight     = no
    .
end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrnickf returns character ( input p-user-id as character):
   define variable v-nick      as character    no-undo.
   if p-user-id = ?
   OR p-user-id = "":U
   then do:
      return '':U .
   end.
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrnick in g#library
  (input  p-user-id
  ,output v-nick
  ) no-error .
   if error-status :error
   then do:
      return p-user-id.
   end.
   else do:
      return v-nick.
   end.
end function.
define variable v-default-object as character no-undo format "X(9)" .
define variable v-brws-mark        as character no-undo column-label "*"        format "x(1)":u  .
define variable v-host-name        as character no-undo .
define variable v-curr-name        as character no-undo .
define variable attr-option        as character no-undo .
define variable v-object-name      as character no-undo column-label "Имя" format "X(40)":U .
define variable v-object-db-num    as integer   no-undo column-label "БД"  format ">>>>9" .
define variable v-object-available as character no-undo column-label "Доступен для тек.пользователя" format "X(8)":U .
define variable v-total-select-num as integer   no-undo .
define temp-table temp-user-host no-undo
  field host-code as integer
  field db-num    as integer
  field host-name as character
  index xpk is primary unique
        host-code
        db-num
  .
define temp-table temp-user-menu-group no-undo
  field menu-group-code as integer
  field menu-group-name as character
  field menu-group-description as character
  field sel-color       as integer
  index pu is primary unique
        menu-group-code
  .
FUNCTION get-curr-name RETURNS CHARACTER
  ( input p-curr-code as integer )  FORWARD.
FUNCTION get-default-object RETURNS CHARACTER
  ( input p-host-code as integer )  FORWARD.
FUNCTION get-host-name RETURNS CHARACTER
  ( INPUT p-host-code AS integer )  FORWARD.
FUNCTION get-object-db-num RETURNS INTEGER
  ( INPUT p-obj-type AS CHARACTER, INPUT p-obj-code AS integer )  FORWARD.
FUNCTION get-object-name RETURNS CHARACTER
  ( INPUT p-obj-type AS CHARACTER, INPUT p-obj-code AS integer )  FORWARD.
FUNCTION mark-string RETURNS CHARACTER
  ( INPUT p-host-code AS integer )  FORWARD.
DEFINE BUTTON b-action
     LABEL "Права"
     SIZE 10 BY 1 TOOLTIP "Права, доступные пользователю на фирме".
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-company
     LABEL "&Фирма"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удал."
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-menu
     LABEL "Меню"
     SIZE 10 BY 1 TOOLTIP "Группы меню, доступные пользователю на фирме".
DEFINE BUTTON B-obj
     LABEL "Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sel AUTO-GO
     LABEL "В&ыбор"
     SIZE 10 BY 1.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY br-host FOR
      ub.user-host SCROLLING.
DEFINE QUERY br-obj FOR
      ub.user-obj SCROLLING.
DEFINE BROWSE br-host
  QUERY br-host NO-LOCK DISPLAY
      mark-string(ub.user-host.host-code) @ v-brws-mark
      ub.user-host.host-code format "999999999"
      get-host-name(ub.user-host.host-code) @ v-host-name COLUMN-LABEL "Название" FORMAT "X(40)":U
      get-default-object(ub.user-host.host-code) @ v-default-object COLUMN-LABEL "Главн.объект!межфирм.перем."
    WITH NO-ROW-MARKERS SEPARATORS SIZE 53.5 BY 17 ROW-HEIGHT-CHARS .67.
DEFINE BROWSE br-obj
  QUERY br-obj NO-LOCK DISPLAY
      ub.user-obj.obj-type column-label "Тип"
      ub.user-obj.obj-code column-label "Код"
      get-object-name(ub.user-obj.obj-type, ub.user-obj.obj-code)   @ v-object-name
      get-object-db-num(ub.user-obj.obj-type, ub.user-obj.obj-code) @ v-object-db-num
    WITH NO-ROW-MARKERS SEPARATORS SIZE 42.5 BY 17 ROW-HEIGHT-CHARS .67.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     b-action AT ROW 1 COL 31 WIDGET-ID 8
     b-menu AT ROW 1 COL 41 WIDGET-ID 10
     B-Help AT ROW 1 COL 88
     b-add AT ROW 2 COL 1 WIDGET-ID 2
     B-lookup AT ROW 2 COL 11
     B-company AT ROW 2 COL 21
     b-del AT ROW 2 COL 31 WIDGET-ID 4
     B-obj AT ROW 2 COL 55.5
     br-host AT ROW 3.25 COL 1
     br-obj AT ROW 3.25 COL 55.5
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(77.99) SKIP(18.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список <Своих> фирм системы"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       br-host:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.
ON GO OF FRAME Dialog-Frame
DO:
  run choose-select in this-procedure .
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-action IN FRAME Dialog-Frame
DO:
   if not available ub.user-host
   then do:
      return no-apply.
   end.
   run str/usractn1.w ( INPUT parparentproc
                      , INPUT ub.user-host.user-id
                      , INPUT ub.user-host.db-num
                      , INPUT 'орг':U
                      , INPUT ub.user-host.host-code
                      ) NO-ERROR.
   if error-status :error
   then do:
        message
              vss-workfile vss-revision vss-description
           skip(1)
           skip "Ошибка изменения прав пользователя на фирме"
           skip return-value
           skip trim( error-status :get-message( 1 ) )
              trim( error-status :get-message( 2 ) )
              trim( error-status :get-message( 3 ) )
        view-as alert-box error.
      return no-apply.
   end.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
  run create_user_host.
  run enable_UI.
  run MyEnable in this-procedure .
END.
ON CHOOSE OF B-company IN FRAME Dialog-Frame
DO:
  define variable v-ok as logical   no-undo .
  if available ub.user-host
  then do:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_host-reference_lookup':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
    if v-ok <> true
    then do:
      return no-apply.
    end.
    run adm/config.w
      (input parParentProc
      ,input ub.user-host.host-code
      ,input  'ПРОСМОТР':U
      ,input no
      ) no-error.
    if error-status :error
    then do:
      return no-apply.
    end.
  end.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
   if not available ub.user-host
   then do:
      return no-apply.
   end.
   run delete_user_host.
   run enable_UI.
   run MyEnable in this-procedure .
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
if available ub.user-host
then do:
  run ref/showcli.p (
    input parParentProc
    ,input 'орг':U
    ,input ub.user-host.host-code
    ).
end.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
   run choose-mark in this-procedure .
END.
ON CHOOSE OF b-menu IN FRAME Dialog-Frame
DO:
   if not available ub.user-host
   then do:
      return no-apply.
   end.
   run str/usrmngr1.w ( INPUT parparentproc
                      , INPUT ub.user-host.db-num
                      , INPUT ub.user-host.user-id
                      , INPUT 'орг':U
                      , INPUT ub.user-host.host-code
                      ) NO-ERROR.
   if error-status :error
   then do:
        message
              vss-workfile vss-revision vss-description
           skip(1)
           skip "Ошибка изменения меню пользователя на фирме"
           skip return-value
           skip trim( error-status :get-message( 1 ) )
              trim( error-status :get-message( 2 ) )
              trim( error-status :get-message( 3 ) )
        view-as alert-box error.
      return no-apply.
   end.
END.
ON CHOOSE OF B-obj IN FRAME Dialog-Frame
DO:
  run br-obj-show-object in this-procedure .
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
  assign
    p-select-host-code =  ?
    p-List-select-host-code =  ""
  .
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
END.
ON DEFAULT-ACTION OF br-host IN FRAME Dialog-Frame
DO:
   if INDEX ( p-bttns, "b-sel") > 0
   then do:
      apply 'go':u to frame Dialog-Frame .
   end.
   else do:
      run choose-mark in this-procedure .
   end.
END.
ON VALUE-CHANGED OF br-host IN FRAME Dialog-Frame
DO:
  run update-br-host-dependent in this-procedure .
END.
ON DEFAULT-ACTION OF br-obj IN FRAME Dialog-Frame
DO:
  run br-obj-show-object in this-procedure .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-host :handle
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
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse br-obj :handle
  ) .
run diasize_init in this-procedure .
assign
  p-user-select      = false
  p-select-host-code = ?
  p-List-select-host-code = ""
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
  assign
    v-host-name   :resizable in browse br-host = true
    v-object-name :resizable in browse br-obj  = true
  .
  define variable v-colwidth-data-exist as logical   no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run colwidth-read in this-procedure
  (input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  'gbl/userhsts.w':U
  ,output v-colwidth-data-exist
  )  .
  if v-colwidth-data-exist = true
  then do:
    assign
      v-host-name   :width in browse br-host = v-colwidth-width-01
      v-object-name :width in browse br-obj  = v-colwidth-width-02
    .
  end.
  else do:
    assign
      v-host-name   :width in browse br-host = 25
      v-object-name :width in browse br-obj  = 25
    .
  end.
  RUN MyEnable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
assign
  v-colwidth-width-01 = v-host-name   :width in browse br-host
  v-colwidth-width-02 = v-object-name :width in browse br-obj
.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run colwidth-write in this-procedure
  .
RUN disable_UI.
PROCEDURE br-obj-show-object :
  do
  on error undo, return error return-value
  :
    if available ub.user-obj
    then do:
      run ref/showcli.p
        (input parparentproc
        ,input ub.user-obj.obj-type
        ,input ub.user-obj.obj-code
        ) no-error.
    end.
  end.
END PROCEDURE.
PROCEDURE change-menu :
define buffer buf_user-menu-group for ub.user-menu-group.
define buffer buf_menu-group      for ub.menu-group.
define buffer buf_temp-user-host  for temp-user-host.
define buffer buf_temp-user-menu-group    for temp-user-menu-group.
define variable v-menu-group-code    as integer      no-undo.
define variable v-ok                 as logical      no-undo.
define variable v-accepted    as logical      no-undo.
define variable v-changed    as logical      no-undo.
define variable v-user-menu-group-code    as integer      no-undo.
do for buf_user-menu-group
   on error undo, return no-apply
   :
   run twowin_clear in this-procedure.
   FOR EACH  buf_menu-group
       NO-LOCK
       on error undo, return error
       :
define variable vss-include-info22 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chkmngr in g#library2
  (input  buf_menu-group.menu-group-id
  ,input  'firm':U
  ,input  'орг':U
  ,input  ub.user-host.host-code
  ,input  p-db-num
  ,output v-ok
  ) no-error .
       IF NOT v-ok THEN DO:
          NEXT.
       end.
       FIND FIRST buf_temp-user-menu-group
       where buf_temp-user-menu-group.menu-group-code    = buf_menu-group.menu-group-code
       no-lock
       no-error
       .
       run twowin_add-item in this-procedure
         ( input string( buf_menu-group.menu-group-code  )
         , input buf_menu-group.menu-group-name
         , input buf_menu-group.menu-group-description
         , input ( available buf_temp-user-menu-group )
         ) .
   end.
   run gbl/twowin.w
      ( input parparentproc
      , input 1
      , input "Добавление меню фирме"
      , input "":U
      , input "&Тест"
      , input table temp_twowin_items
      , output table temp_twowin_itemsSelected
      , output v-changed
      , output v-accepted
      ) .
   IF NOT v-accepted THEN DO:
      RETURN.
   END.
   find first buf_temp-user-host
      no-error
      .
   if available buf_temp-user-host then do:
   define variable v-list-host    as character    no-undo.
   define variable v-ccc    as integer      no-undo.
      assign
         v-ok  = FALSE
         v-ccc = 0
      .
      FOR EACH buf_temp-user-host
      :
        assign
         v-list-host = SUBSTITUTE("&1&2&3 &4"
                                    , v-list-host
                                    , (if v-list-host = "":U then "":U else chr(10))
                                    , buf_temp-user-host.host-code
                                    , buf_temp-user-host.host-name
                                    )
         v-ccc = v-ccc + 1
        .
      END.
      IF v-ccc > 1 THEN DO:
         message
            "Будет изменен список доступных меню для фирм пользователя:"
            SKIP(1)
            v-list-host
            SKIP(1) "Вы уверены?"
         view-as alert-box buttons yes-no
         update v-ok .
         if v-ok = no then do:
            undo, return.
         end.
      end.
      FOR EACH buf_temp-user-host
      :
         for each  buf_user-menu-group
            where buf_user-menu-group.db-num = p-db-num
               and buf_user-menu-group.user-id = p-user-id
               and buf_user-menu-group.host-code = buf_temp-user-host.host-code
               and buf_user-menu-group.menu-group-context = 'firm':U
            exclusive-lock
            on error undo, return error
            :
            find first temp_twowin_itemsSelected
                  where temp_twowin_itemsSelected.itmExtKey = string( buf_user-menu-group.user-menu-group-code )
            no-error.
            if not available temp_twowin_itemsSelected
            then do:
               delete buf_user-menu-group.
            end.
         end.
         for each temp_twowin_itemsSelected
         :
            assign
               v-menu-group-code = integer( temp_twowin_itemsSelected.itmExtKey )
            no-error.
            if error-status :error
            then do:
               message
                     vss-workfile vss-revision vss-description
                  skip(1)
                  skip "Ошибка передачи первичного ключа из двухоконного интерфейса."
                  skip return-value
                  skip trim( error-status :get-message( 1 ) )
                     trim( error-status :get-message( 2 ) )
                     trim( error-status :get-message( 3 ) )
               view-as alert-box error.
               undo, return error.
            end.
            find first  buf_user-menu-group
            where buf_user-menu-group.db-num = p-db-num
               and buf_user-menu-group.user-id = p-user-id
               and buf_user-menu-group.host-code = buf_temp-user-host.host-code
               and buf_user-menu-group.menu-group-context = 'firm':U
               and buf_user-menu-group.menu-group-code =v-menu-group-code
            no-lock
            no-error
            .
            if not available buf_user-menu-group
            then do:
               FIND FIRST buf_menu-group
                  WHERE buf_menu-group.menu-code = 0
                  and buf_menu-group.menu-group-code =v-menu-group-code
                  NO-LOCK
                  no-error
                  .
                  if error-status :error
                  then do:
                     message
                           vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка поиска Меню в системе."
                        skip return-value
                        skip trim( error-status :get-message( 1 ) )
                           trim( error-status :get-message( 2 ) )
                           trim( error-status :get-message( 3 ) )
                     view-as alert-box error.
                     undo, return error.
                  end.
                  assign
                  v-user-menu-group-code = NEXT-VALUE(s-user-menu-group, ub)
                  .
                     CREATE buf_user-menu-group .
                     ASSIGN
                        buf_user-menu-group.db-num               = p-db-num
                        buf_user-menu-group.user-id              = p-user-id
                        buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                        buf_user-menu-group.menu-code            = buf_menu-group.menu-code
                        buf_user-menu-group.menu-group-code      = buf_menu-group.menu-group-code
                        buf_user-menu-group.menu-group-id        = buf_menu-group.menu-group-id
                        buf_user-menu-group.menu-group-context   = 'firm':U
                        buf_user-menu-group.host-code            = buf_temp-user-host.host-code
                        buf_user-menu-group.obj-type             = '':U
                        buf_user-menu-group.obj-code             = 0
                     .
            end.
         end.
      end.
   end.
   else do:
      IF NOT v-changed THEN DO:
         RETURN.
      END.
      for each  buf_user-menu-group
         where buf_user-menu-group.db-num = p-db-num
            and buf_user-menu-group.user-id = p-user-id
            and buf_user-menu-group.host-code = ub.user-host.host-code
            and buf_user-menu-group.menu-group-context = 'firm':U
         exclusive-lock
         on error undo, return error
         :
         find first temp_twowin_itemsSelected
               where temp_twowin_itemsSelected.itmExtKey = string( buf_user-menu-group.user-menu-group-code )
         no-error.
         if not available temp_twowin_itemsSelected
         then do:
            delete buf_user-menu-group.
         end.
      end.
      for each temp_twowin_itemsSelected
      :
         assign
            v-menu-group-code = integer( temp_twowin_itemsSelected.itmExtKey )
         no-error.
         if error-status :error
         then do:
            message
                  vss-workfile vss-revision vss-description
               skip(1)
               skip "Ошибка передачи первичного ключа из двухоконного интерфейса."
               skip return-value
               skip trim( error-status :get-message( 1 ) )
                  trim( error-status :get-message( 2 ) )
                  trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return error.
         end.
         find first  buf_user-menu-group
         where buf_user-menu-group.db-num = p-db-num
            and buf_user-menu-group.user-id = p-user-id
            and buf_user-menu-group.host-code = ub.user-host.host-code
            and buf_user-menu-group.menu-group-context = 'firm':U
            and buf_user-menu-group.menu-group-code =v-menu-group-code
         no-lock
         no-error
         .
         if not available buf_user-menu-group
         then do:
            FIND FIRST buf_menu-group
               WHERE buf_menu-group.menu-code = 0
               and buf_menu-group.menu-group-code =v-menu-group-code
               NO-LOCK
               no-error
               .
               if error-status :error
               then do:
                  message
                        vss-workfile vss-revision vss-description
                     skip(1)
                     skip "Ошибка поиска Меню в системе."
                     skip return-value
                     skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
                  view-as alert-box error.
                  undo, return error.
               end.
               assign
               v-user-menu-group-code = NEXT-VALUE(s-user-menu-group, ub)
               .
                  CREATE buf_user-menu-group .
                  ASSIGN
                     buf_user-menu-group.db-num               = p-db-num
                     buf_user-menu-group.user-id              = p-user-id
                     buf_user-menu-group.user-menu-group-code = v-user-menu-group-code
                     buf_user-menu-group.menu-code            = buf_menu-group.menu-code
                     buf_user-menu-group.menu-group-code      = buf_menu-group.menu-group-code
                     buf_user-menu-group.menu-group-id        = buf_menu-group.menu-group-id
                     buf_user-menu-group.menu-group-context   = 'firm':U
                     buf_user-menu-group.host-code            = ub.user-host.host-code
                     buf_user-menu-group.obj-type             = '':U
                     buf_user-menu-group.obj-code             = 0
                  .
         end.
      end.
   end.
end.
END PROCEDURE.
PROCEDURE check-selection :
  define variable v-ok as logical   no-undo .
  define buffer buf_temp-user-host for temp-user-host .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      if can-do ( p-bttns, "b-mark")
      then do:
        find first buf_temp-user-host
          no-error .
        if available buf_temp-user-host
        then do:
          message
            "Информация о выбранных элементах будет потеряна" Skip
            "Продолжить?" Skip
            view-as alert-box question buttons yes-no update v-ok .
          if v-ok = true
          then do:
            for each buf_temp-user-host
            on error undo, return error return-value
            :
              delete buf_temp-user-host .
            end.
          end.
          else do:
            undo, return error return-value .
          end.
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE choose-mark :
  define variable v-log as logical no-undo .
  define buffer buf_temp-user-host for temp-user-host .
  do
  on error undo, return error return-value
  :
    if available ub.user-host
    then do:
      find first buf_temp-user-host
        where buf_temp-user-host.host-code = ub.user-host.host-code
        no-error .
      if available buf_temp-user-host
      then do:
        run userhsts_delete in this-procedure
          ( input  ub.user-host.host-code
          , input  ub.user-host.db-num
          ) .
      end.
      else do:
        run userhsts_append in this-procedure
          ( input  ub.user-host.host-code
          , input  ub.user-host.db-num
          ) .
      end.
      v-log = br-host:refresh() in frame Dialog-Frame.
      if last-event :function <> "MOUSE-SELECT-DBLCLICK"
      then do:
        v-log = br-host:select-next-row ().
        run update-br-host-dependent in this-procedure .
      end.
      run display-select-num in this-procedure .
      apply 'entry':U to br-host in frame Dialog-Frame.
    end.
  end.
END PROCEDURE.
PROCEDURE choose-select :
  define buffer buf_temp-user-host for temp-user-host .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      if available ub.user-host
      then do:
        if INDEX ( p-bttns, "b-mark") > 0
        then do:
          find first buf_temp-user-host
            no-error .
          if not available buf_temp-user-host
          then do:
            run userhsts_append in this-procedure
              ( input  ub.user-host.host-code
              , input  ub.user-host.db-num
              ) .
          end.
          run userhsts_clear in p-callback-handle .
          for each buf_temp-user-host
          on error undo, return error return-value
          :
            run userhsts_append in p-callback-handle
              ( input  buf_temp-user-host.host-code
              ) .
          ASSIGN
             p-List-Select-Host-code = p-List-select-host-code +
                                       (IF p-List-select-host-code = "" THEN "" ELSE "," ) +
                                       STRING(buf_temp-user-host.host-code).
          end.
        end.
        else do:
          assign
            p-select-host-code = ub.user-host.host-code
          .
        end.
      end.
    end.
    assign
      p-user-select = true
    .
  end.
END PROCEDURE.
PROCEDURE create_user_host :
DEFINE VARIABLE v-out-host-code AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-rid-list      AS CHARACTER NO-UNDO .
define variable v-count         as integer   no-undo.
define buffer buf_sysconf       FOR ub.sysconf.
define buffer buf_clients     for ub.clients .
define buffer buf_user-host      for ub.user-host .
do
on error undo, return error return-value
:
   run adm/sconfs.w ( INPUT parparentproc
                    , INPUT "b-sel,b-mark"
                    , FALSE
                    , p-curr-host-code
                    , OUTPUT v-out-host-code
                    , INPUT-OUTPUT v-rid-list
                    ) .
   IF  v-rid-list <> ""
   AND v-rid-list <> ?
   THEN
   count_:
   DO v-count = 1 to num-entries(v-rid-list)
   transaction
   :
      FIND FIRST buf_sysconf
         WHERE RECID( buf_sysconf ) = INTEGER(ENTRY(v-count, v-rid-list))
         NO-LOCK
         NO-ERROR.
      if ERROR-STATUS :ERROR
      OR NOT AVAILABLE buf_sysconf
      then do:
           NEXT count_.
      end.
      IF CAN-FIND (buf_user-host where buf_user-host.host-code     = buf_sysconf.host-code
                                    and buf_user-host.user-id      = p-user-id
                                    AND buf_user-host.db-num       = p-db-num
                           no-lock)
      then do:
         next count_.
      end.
      CREATE ub.user-host.
      ASSIGN
         ub.user-host.db-num    = p-db-num
         ub.user-host.user-id   = p-user-id
         ub.user-host.host-code = buf_sysconf.host-code
      .
   END.
END.
END PROCEDURE.
PROCEDURE delete_user_host :
  DEFINE VARIABLE v-out-host-code AS INTEGER   NO-UNDO.
  DEFINE VARIABLE v-rid-list      AS CHARACTER NO-UNDO .
  do
  transaction
  on error undo, return error return-value
  :
     define variable v-ok                    as logical   no-undo .
     define variable v-message-text          as character no-undo .
     define variable v-cntxt-valid           as logical   no-undo .
     define variable v-cntxt-menu-code       as integer   no-undo .
     define variable v-cntxt-menu-group-code as integer   no-undo .
     define variable v-cntxt-level           as character no-undo .
     define variable v-cntxt-host-code-obj   as integer   no-undo .
     define variable v-cntxt-obj-type        as character no-undo .
     define variable v-cntxt-obj-code        as integer   no-undo .
     define buffer   buf_user-host for ub.user-host.
     v-ok = no.
     run gbl/cntxtget.p ( INPUT  p-db-num
                        , INPUT  p-user-id
                        , OUTPUT v-cntxt-valid
                        , OUTPUT v-cntxt-menu-code
                        , OUTPUT v-cntxt-menu-group-code
                        , OUTPUT v-cntxt-level
                        , OUTPUT v-cntxt-host-code-obj
                        , OUTPUT v-cntxt-obj-type
                        , OUTPUT v-cntxt-obj-code
                        ) .
     if  v-cntxt-host-code-obj = ub.user-host.host-code
     THEN DO:
        v-message-text = "Удаляемая фирма - текущая для данного пользователя.~n".
     END.
     v-message-text = v-message-text + SUBSTITUTE("Удалить фирму &1 (сделать ее недоступной для данного пользователя) ?", get-host-name(ub.user-host.host-code) ).
     MESSAGE v-message-text
     VIEW-AS ALERT-BOX
     BUTTONS OK-CANCEL
     TITLE "Удаление фирмы":U
     UPDATE v-ok.
     IF NOT v-ok THEN RETURN NO-APPLY.
     run userhsts_delete in this-procedure ( INPUT ub.user-host.host-code
                                           , INPUT ub.user-host.db-num
                                           ) .
     FIND buf_user-host WHERE buf_user-host.db-num    = ub.user-host.db-num
                          AND buf_user-host.user-id   = p-user-id
                          AND buf_user-host.host-code = ub.user-host.host-code
                        EXCLUSIVE-LOCK.
     DELETE buf_user-host.
     IF INDEX("текущая", v-message-text) > 0 THEN DO:
        run gbl/cntxtstr.p ( INPUT  p-db-num
                           , INPUT  p-user-id
                           , INPUT  v-cntxt-menu-code
                           , INPUT  v-cntxt-menu-group-code
                           , INPUT  'global':U
                           , INPUT  ""
                           , INPUT  ""
                           , INPUT  ""
                           )  .
        MESSAGE "Удалена текущая фирма для данного пользователя." skip (2)
                "Пользователю по умолчанию выставлен контекст без фирмы"
        VIEW-AS ALERT-BOX WARNING.
     END.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-select-num :
  do
  on error undo, return error return-value
  :
    assign
      mark-num = string(v-total-select-num)
    .
    if v-total-select-num = 0
    then do:
      hide
        mark-num
        in frame Dialog-Frame.
    end.
    else do:
      display
        mark-num
        with frame Dialog-Frame.
    end.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-action b-menu B-Help b-add B-lookup B-company
         b-del B-obj br-host br-obj mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run open-query-user-host in this-procedure .    run open-query-user-obj in this-procedure .
END PROCEDURE.
PROCEDURE fill-temp-menu-group :
do
on error undo, return error
:
define buffer buf_temp-user-host    for temp-user-host.
define buffer buf_user-menu-group   for ub.user-menu-group.
define buffer buf_menu-group        for ub.menu-group.
define variable v-sel-host-count    as integer      no-undo.
   find first buf_temp-user-host
      no-error
      .
   if NOT available buf_temp-user-host then do:
      empty temp-table temp-user-menu-group.
      FOR EACH  buf_user-menu-group
         WHERE buf_user-menu-group.db-num     = p-db-num
            AND buf_user-menu-group.user-id   = p-user-id
            AND buf_user-menu-group.host-code = ub.user-host.host-code
            AND buf_user-menu-group.menu-group-context = 'firm':U
         NO-LOCK
         ,
         FIRST buf_menu-group
         WHERE buf_menu-group.menu-code       = buf_user-menu-group.menu-code
           AND buf_menu-group.menu-group-code = buf_user-menu-group.menu-group-code
         NO-LOCK
         :
         create temp-user-menu-group.
         assign
            temp-user-menu-group.menu-group-code = buf_user-menu-group.menu-group-code
            temp-user-menu-group.menu-group-name = buf_menu-group.menu-group-name
            temp-user-menu-group.menu-group-description = buf_menu-group.menu-group-description
            temp-user-menu-group.sel-color       = 0
         .
      END.
  END.
  else do:
     empty temp-table temp-user-menu-group.
     assign
        v-sel-host-count = 0
     .
     for each buf_temp-user-host
     :
        assign
           v-sel-host-count = v-sel-host-count + 1
        .
     end.
     for each buf_temp-user-host
     :
         FOR EACH  buf_user-menu-group
            WHERE buf_user-menu-group.db-num     = p-db-num
               AND buf_user-menu-group.user-id   = p-user-id
               AND buf_user-menu-group.host-code = buf_temp-user-host.host-code
               AND buf_user-menu-group.menu-group-context = 'firm':U
            NO-LOCK
            ,
            FIRST buf_menu-group
            WHERE buf_menu-group.menu-code       = buf_user-menu-group.menu-code
            AND buf_menu-group.menu-group-code = buf_user-menu-group.menu-group-code
            NO-LOCK
            :
            find first temp-user-menu-group
               where temp-user-menu-group.menu-group-code = buf_user-menu-group.menu-group-code
               no-error
               .
            IF NOT AVAILABLE temp-user-menu-group then do:
               create temp-user-menu-group.
               assign
                  temp-user-menu-group.menu-group-code = buf_user-menu-group.menu-group-code
                  temp-user-menu-group.menu-group-name = buf_menu-group.menu-group-name
                  temp-user-menu-group.sel-color       = v-sel-host-count
                  temp-user-menu-group.menu-group-description = buf_menu-group.menu-group-description
               .
            end.
            assign
               temp-user-menu-group.sel-color = temp-user-menu-group.sel-color - 1
            .
         END.
     end.
  end.
end.
END PROCEDURE.
PROCEDURE get-host-name-proc :
  define input  parameter p-host-code as integer   no-undo .
  define output parameter p-host-name as character no-undo .
  define buffer buf_clients for ub.clients .
  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = 'орг':U
        and buf_clients.obj-code = p-host-code
      no-error .
    if available buf_clients
    then do:
      assign
        p-host-name = (if buf_clients.stts = 0
                       then buf_clients.obj-name
                       else (substring (buf_clients.obj-name, 1, 20)
                            + fill (" " , 20 - length (substring (buf_clients.obj-name, 1, 20)))
                            + '---  УДАЛЕН  ---':U
                            )
                      )
      .
    end.
  end.
END PROCEDURE.
PROCEDURE get-object-db-num-proc :
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-object-db-num as integer   no-undo .
  define buffer buf_clients for ub.clients .
  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if available buf_clients
    then do:
      assign
        p-object-db-num = buf_clients.db-num
      .
    end.
    else do:
      assign
        p-object-db-num = ?
      .
    end.
  end.
END PROCEDURE.
PROCEDURE get-object-name-proc :
  define input  parameter p-obj-type    as character no-undo .
  define input  parameter p-obj-code    as integer   no-undo .
  define output parameter p-object-name as character no-undo .
  define buffer buf_clients for ub.clients .
  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if available buf_clients
    then do:
      assign
        p-object-name = buf_clients.obj-name
      .
    end.
    else do:
      assign
        p-object-name = ?
      .
    end.
  end.
END PROCEDURE.
PROCEDURE host-default-object :
   define input parameter p-host-code as integer no-undo .
   define output parameter p-obj-type as character no-undo .
   define output parameter p-obj-code as integer no-undo .
   define buffer buf_firm for ub.firm .
   find first buf_firm no-lock
     where buf_firm.firm-code = p-host-code
     no-error .
   if available buf_firm then do:
     assign
       p-obj-type = main-obj-type
       p-obj-code = main-obj-code
     .
   end.
END PROCEDURE.
PROCEDURE mark-string-proc :
  define input  parameter p-host-code   as integer   no-undo .
  define output parameter p-mark-string as character no-undo .
  define buffer buf_temp-user-host for temp-user-host .
  do
  on error undo, return error return-value
  :
    find first buf_temp-user-host
         where buf_temp-user-host.host-code = p-host-code
         no-error
         .
    if available buf_temp-user-host
    then do:
      assign
        p-mark-string = '*':U
      .
    end.
    else do:
      assign
        p-mark-string = '':U
      .
    end.
  end.
END PROCEDURE.
PROCEDURE MyEnable :
  do
  on error undo, return error return-value
  :
    disable
    all
    with frame dialog-frame
    .
    define variable v-user-name as character no-undo .
    assign
      frame dialog-frame :title = substitute("Фирмы пользователя &1"
                                            , usrnickf( p-user-id )
                                            )
    .
    enable
      b-quit
      b-sel  when can-do ( p-bttns, "b-sel")
      b-mark when can-do ( p-bttns, "b-mark")
      b-add  when can-do ( p-bttns, "b-add")
      b-del  when can-do ( p-bttns, "b-add")
      b-lookup
      b-company
      b-action
      b-menu
      b-help
      br-host
      br-obj
      b-obj
    with frame dialog-frame.
    view frame dialog-frame.
    run open-query-user-host in this-procedure .    run open-query-user-obj in this-procedure .
    hide
      mark-num
      in frame Dialog-Frame .
    if p-curr-host-code <> ?
    then do:
      define variable v-user-host-rowid as rowid no-undo .
      define buffer buf_reposition_user-host for ub.user-host .
      find first buf_reposition_user-host no-lock
        where buf_reposition_user-host.db-num    = p-db-num
          and buf_reposition_user-host.user-id   = p-user-id
          and buf_reposition_user-host.host-code = p-curr-host-code
        no-error .
      if available buf_reposition_user-host
      then do:
        reposition br-host to rowid rowid(buf_reposition_user-host) no-error .
      end.
    end.
    apply 'entry':U to br-host .
    run update-br-host-dependent in this-procedure .
  end.
END PROCEDURE.
PROCEDURE open-query-user-host :
  do
  on error undo, return error return-value
  :
    open query br-host for each ub.user-host no-lock
         where ub.user-host.db-num  = p-db-num
           and ub.user-host.user-id = p-user-id
         indexed-reposition
         .
  end.
END PROCEDURE.
PROCEDURE open-query-user-obj :
  do
  on error undo, return error return-value
  :
    do
    on error undo, return error return-value
    :
      if available ub.user-host
      then do:
        open query br-obj
          for each ub.user-obj
             no-lock
             where ub.user-obj.db-num    = ub.user-host.db-num
               and ub.user-obj.user-id   = ub.user-host.user-id
               and ub.user-obj.host-code = ub.user-host.host-code
                by ub.user-obj.obj-type
                by ub.user-obj.obj-code
          indexed-reposition
          .
      end.
      else do:
        open query br-obj for  each ub.user-obj no-lock
             where ub.user-obj.db-num  = 0
               and ub.user-obj.user-id = '':U
           indexed-reposition
          .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE update-br-host-dependent :
  do
  on error undo, return error return-value
  :
    run open-query-user-obj in this-procedure .
    IF AVAILABLE ub.user-obj THEN DO:
       enable b-obj
       with frame dialog-frame.
    END.
    ELSE do:
       disable b-obj
       with frame dialog-frame.
    end.
  end.
END PROCEDURE.
PROCEDURE userhsts_append :
  define input  parameter p-host-code as integer   no-undo .
  define input  parameter p-db-num    as integer   no-undo .
  define buffer buf_temp-user-host for temp-user-host .
  do
  on error undo, return error return-value
  :
    find first buf_temp-user-host
         where buf_temp-user-host.host-code = p-host-code
           and buf_temp-user-host.db-num    = p-db-num
         no-error
         .
    if not available buf_temp-user-host
    then do:
      create buf_temp-user-host .
      assign
        buf_temp-user-host.host-code = p-host-code
        buf_temp-user-host.db-num    = p-db-num
      .
      assign
        buf_temp-user-host.host-name = get-host-name(p-host-code)
        v-total-select-num = v-total-select-num + 1
      .
    end.
  end.
END PROCEDURE.
PROCEDURE userhsts_delete :
  define input  parameter p-host-code as integer   no-undo .
  define input  parameter p-db-num    as integer   no-undo .
  define buffer buf_temp-user-host for temp-user-host .
  do
  on error undo, return error return-value
  :
    find first buf_temp-user-host
      where buf_temp-user-host.host-code = p-host-code
        and buf_temp-user-host.db-num    = p-db-num
      no-error .
    if available buf_temp-user-host
    then do:
      delete buf_temp-user-host .
      assign
        v-total-select-num = v-total-select-num - 1
      .
    end.
  end.
END PROCEDURE.
FUNCTION get-curr-name RETURNS CHARACTER
  ( input p-curr-code as integer ) :
  find first ub.currency no-lock where
                 ub.currency.curr-code = p-curr-code no-error.
    if available ub.currency then do:
        return ub.currency.curr-abbr.
    end.
    else do:
        return chr(63).
    end.
END FUNCTION.
FUNCTION get-default-object RETURNS CHARACTER
  ( input p-host-code as integer ) :
  define variable v-obj-type as character no-undo .
  define variable v-obj-code as integer no-undo .
  run host-default-object
    (input p-host-code
    ,output v-obj-type
    ,output v-obj-code
    ) .
  if v-obj-type <> "" then do:
    return substitute('&1 &2':u, v-obj-type, v-obj-code) .
  end.
  else do:
    return "" .
  end.
END FUNCTION.
FUNCTION get-host-name RETURNS CHARACTER
  ( INPUT p-host-code AS integer ) :
  define variable v-host-name as character no-undo .
  run get-host-name-proc in this-procedure
    (input  p-host-code
    ,output v-host-name
    ) .
  return v-host-name .
END FUNCTION.
FUNCTION get-object-db-num RETURNS INTEGER
  ( INPUT p-obj-type AS CHARACTER, INPUT p-obj-code AS integer ) :
  define variable v-object-db-num as integer   no-undo .
  run get-object-db-num-proc in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,output v-object-db-num
    ) .
  return v-object-db-num .
END FUNCTION.
FUNCTION get-object-name RETURNS CHARACTER
  ( INPUT p-obj-type AS CHARACTER, INPUT p-obj-code AS integer ) :
  define variable v-object-name as character no-undo .
  run get-object-name-proc in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,output v-object-name
    ) .
  return v-object-name .
END FUNCTION.
FUNCTION mark-string RETURNS CHARACTER
  ( INPUT p-host-code AS integer ) :
  define variable v-mark-string as character no-undo .
  run mark-string-proc in this-procedure
    (input  p-host-code
    ,output v-mark-string
    ) .
  return v-mark-string .
END FUNCTION.
