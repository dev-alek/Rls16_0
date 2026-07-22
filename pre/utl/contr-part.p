block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: contr-part.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/contr-part.p $":U .
define variable vss-description as character no-undo init "Проверка и правка партий на соответствие догора и контрагента".
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
define buffer buf_parts for ub.parts  .
for each ub.sysconf no-lock :
  for each ub.parts no-lock where
           ub.parts.host-code = ub.sysconf.host-code and
           ub.parts.contract-code > 0 :
      find first ub.contract no-lock where
           ub.contract.host-code    = ub.parts.host-code and
           ub.contract.contract-code = ub.parts.contract-code no-error .
           if available ub.contract then do:
              if not (  ub.parts.supp-code = ub.contract.cli-code and
                        ub.parts.supp-type = ub.contract.cli-type ) then do:
               find first buf_parts exclusive-lock where recid(buf_parts) = recid(ub.parts) .
                  assign
                        buf_parts.supp-code = ub.contract.cli-code
                        buf_parts.supp-type = ub.contract.cli-type
                  .
                  find first ub.goods no-lock where
                             ub.goods.artic     = ub.parts.artic and
                             ub.goods.prod-type = ub.parts.prod-type and
                             ub.goods.prod-code = ub.parts.prod-code no-error .
                  find first ub.parts-attr exclusive-lock where
                             ub.parts-attr.part-code = ub.parts.part-code and
                             ub.parts-attr.in-code   = ub.parts.in-code   and
                             ub.parts-attr.gds-code  = ub.goods.gds-code  no-error .
                    if available ub.parts-attr then do:
                        if not (  ub.parts-attr.supp-code = ub.contract.cli-code and
                                  ub.parts-attr.supp-type = ub.contract.cli-type ) then do:
                        assign
                            ub.parts-attr.supp-code = ub.contract.cli-code
                            ub.parts-attr.supp-type = ub.contract.cli-type
                         .
                        end.
                    end.
              end.
           end.
  end.
end.
