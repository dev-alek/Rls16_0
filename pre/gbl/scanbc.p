block-level on error undo, throw.
define input  parameter parparentproc   as handle    no-undo.
define input  parameter p-b-c           as character no-undo .
define output parameter p-bar-code      as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: scanbc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/scanbc.p $":U .
define variable vss-description as character no-undo init "Распознавание бар-кода".
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
    assign
      p-vss-parameters = substitute('&1':u,p-b-c)
    .
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
define variable is-err as logical   no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE in-bc NO-UNDO
     FIELD nm        as INTEGER
     FIELD bar-str   AS CHARACTER
     FIELD bar-code  as CHARACTER
     FIELD rez       as CHARACTER
     FIELD err-msg   as CHARACTER
     FIELD des       as CHARACTER
     INDEX pi IS PRIMARY nm.
DEFINE new SHARED TEMP-TABLE un-bc NO-UNDO
     FIELD nm             as INTEGER
     FIELD bar-code       as CHARACTER
     FIELD entity         as character
     FIELD b-c            as INTEGER
     FIELD rate           as DECIMAL
     FIELD TYPE-bc        as CHARACTER
     FIELD wt             as DECIMAL
     FIELD file-qnty      as decimal
     FIELD scn-qnty       as DECIMAL
     FIELD scn-pl         as CHARACTER
     FIELD artic          LIKE ub.goods.artic
     FIELD prod-type      LIKE ub.goods.prod-type
     FIELD prod-code      LIKE ub.goods.prod-code
     FIELD gds-name       LIKE ub.goods.gds-name
     FIELD prod-name      LIKE ub.clients.obj-name
     FIELD unit-base      LIKE ub.goods.unit-base
     FIELD units-type     LIKE ub.units.type
     FIELD f-name         LIKE ub.gds-prt.f-name
     FIELD in-code        LIKE ub.parts.in-code
     FIELD fact-date      LIKE ub.parts.fact-date
     FIELD part-code      LIKE ub.parts.part-code
     FIELD rez            as CHARACTER
     FIELD err-msg        as CHARACTER
     FIELD des            as CHARACTER
     FIELD pl-name        AS CHARACTER
     FIELD loc1           AS CHARACTER
     FIELD loc2           AS CHARACTER
     FIELD loc3           AS CHARACTER
     FIELD loc4           AS CHARACTER
     FIELD unit-name      LIKE ub.units.unit-name
     FIELD long-name      LIKE ub.units.long-name
     FIELD b-c-base       LIKE ub.bar-code.b-code
     FIELD unit-name-base LIKE ub.units.unit-name
     FIELD long-name-base LIKE ub.units.long-name
     INDEX pi IS PRIMARY  nm
     INDEX bar-code bar-code
     INDEX b-c b-c
     INDEX file-qnty file-qnty.
DEFINE new SHARED TEMP-TABLE anlz-bc NO-UNDO
     FIELD nm       as INTEGER
     FIELD b-c      as integer
     FIELD scn-qnty as DECIMAL
     FIELD scn-pl   as CHARACTER
     FIELD rez      as CHARACTER
     FIELD err-msg  as CHARACTER
     FIELD des      as CHARACTER
     FIELD upd-line as logical initial no
     INDEX pi IS PRIMARY nm
     INDEX b-c b-c.
DEFINE new SHARED TEMP-TABLE main-bc NO-UNDO
     FIELD nm       as INTEGER
     FIELD b-c      as integer
     FIELD scn-qnty as DECIMAL
     FIELD scn-pl   as CHARACTER
     FIELD rez      as CHARACTER
     FIELD des      as CHARACTER
     INDEX pi IS PRIMARY nm
     INDEX b-c b-c.
do
on error undo, return error return-value
:
  for each un-bc
  on error undo, return error return-value
  :
    delete un-bc.
  end.
  run str/bc-anlz.p
    (input parparentproc
    ,input  'code-add':u
    ,input  p-b-c
    ,input  yes
    ,output is-err
    ,output table in-bc
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при анализе бар-кода" skip
      "Бар-код" p-b-c skip
      view-as alert-box error.
    undo, return error.
  end.
  find last un-bc no-error.
  if  available un-bc
  and un-bc.rez <> "ERR"
  then do:
     assign
       p-bar-code = un-bc.b-c
     .
  end.
  else do:
    undo, return error.
  end.
end.
