block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter  b-c       as char no-undo.
define output parameter parb-code like bar-code.b-code initial ? no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
def var rate LIKE doc-line.cli-base-rate NO-UNDO.
DEF var ret-mode AS CHAR                 NO-UNDO.
DEF var add-scan AS LOG INITIAL NO       NO-UNDO.
def var bar-str  LIKE prod-bc.b-str      NO-UNDO.
def var is-err   as log                  no-undo.
if b-c = ? then do:
  REPEAT:
    run str/chs-bc.w (input parparentproc,
                  "Анализ бар-кода", ?, ?, NO,
                  output b-c,
                  output rate,
                  output ret-mode,
                  input-output add-scan,
                  input-output bar-str) no-error.
    if error-status :error then do:
      message "Неверный выбор бар-кода."
              view-as alert-box.
      return error.
    end.
    if b-c = ? THEN
      LEAVE.
    run analize-one no-error.
  END.
end.
else do:
  run analize-one no-error.
  if error-status:error then
  message "Ошибка при поиске бар-кода."
  view-as alert-box error.
end.
procedure analize-one:
  FOR EACH un-bc:
    DELETE un-bc.
  END.
  run str/bc-anlz.p (parparentproc, "code-add", b-c, yes, output is-err, output table in-bc) no-error.
  if error-status:error then do:
    message "Неверный анализ бар-кода."
            view-as alert-box error.
    return error.
  end.
  FIND LAST un-bc NO-ERROR.
  IF AVAILABLE un-bc then do:
     ASSIGN parb-code = un-bc.b-c.
     run str/bc-inf.w (
                    input parparentproc
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,recid (un-bc)
                   ,output table in-bc) no-error.
  end.
  else return error.
end.
