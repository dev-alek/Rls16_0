block-level on error undo, throw.
define input parameter p-rvs-code          as character no-undo .
define input parameter p-action            as character no-undo .
define input parameter p-no-check-rvs-code as character no-undo .
define input parameter p-is-berate         as logical   no-undo .
define variable v-auto as logical no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Блокировка и расблокировка товаров по документу сверки":U .
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
main-block :
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first ub.rvs-doc no-lock
    where ub.rvs-doc.rvs-code = p-rvs-code
    no-error .
  if not available ub.rvs-doc then do:
    if p-is-berate = yes then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ сверки" skip
        "Документ сверки" p-rvs-code skip
      view-as alert-box error .
    end.
    undo main-block, return error substitute( '&1: не найден документ сверки "&2"', vss-workfile, p-rvs-code ) .
  end.
    find first  doc-attr where
        doc-attr.doc-code = rvs-doc.rvs-code and
        doc-attr.attr-code = "rvs-auto" and
        doc-attr.attr-value = "Yes" no-lock no-error.
    if available doc-attr then
    do:
        v-auto = yes .
    end.
    if v-auto <> yes then
    do:
        for each ub.rvs-line no-lock
            where ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code
            on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
            :
            if num-entries(ub.rvs-doc.rvs-code, "-") = 3
            and (p-action begins "assign-rvs-on=" or p-action begins "check-rvs-on=")
            then do :
              if p-action begins "assign-rvs-on="
              then do :
                for first ub.pl-gds no-lock where ub.pl-gds.obj-type = ub.rvs-line.obj-type
                                              and ub.pl-gds.obj-code = ub.rvs-line.obj-code
                                              and ub.pl-gds.pl-code  = ub.rvs-line.pl-code
                                              and ub.pl-gds.gds-code = ub.rvs-line.gds-code
                                              and ub.pl-gds.rvs-on  <> logical(entry(2, p-action, "="))
                :
                  if p-no-check-rvs-code = ? then p-no-check-rvs-code = "" .
                  p-no-check-rvs-code = p-no-check-rvs-code + "," + ub.rvs-doc.rvs-code .
                  p-no-check-rvs-code = trim(p-no-check-rvs-code, ",") .
                  run trg/lockplgd.p
                      ( input ub.rvs-line.obj-type
                      , input ub.rvs-line.obj-code
                      , input ub.rvs-line.pl-code
                      , input ub.rvs-line.gds-code
                      , input p-action
                      , input p-no-check-rvs-code
                      , input p-is-berate
                      ) .
                end .
              end .
              if p-action begins "check-rvs-on="
              then do :
                for first ub.pl-gds no-lock where ub.pl-gds.obj-type = ub.rvs-line.obj-type
                                              and ub.pl-gds.obj-code = ub.rvs-line.obj-code
                                              and ub.pl-gds.pl-code  = ub.rvs-line.pl-code
                                              and ub.pl-gds.gds-code = ub.rvs-line.gds-code
                                              and ub.pl-gds.rvs-on   = logical(entry(2, p-action, "="))
                :
                  run trg/lockplgd.p
                      ( input ub.rvs-line.obj-type
                      , input ub.rvs-line.obj-code
                      , input ub.rvs-line.pl-code
                      , input ub.rvs-line.gds-code
                      , input p-action
                      , input p-no-check-rvs-code
                      , input p-is-berate
                      ) .
                end .
              end .
            end .
            else do :
              run trg/lockplgd.p
                  ( input ub.rvs-line.obj-type
                  , input ub.rvs-line.obj-code
                  , input ub.rvs-line.pl-code
                  , input ub.rvs-line.gds-code
                  , input p-action
                  , input p-no-check-rvs-code
                  , input p-is-berate
                  ) .
            end .
        end.
    end.
end.
