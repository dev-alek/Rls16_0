block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись ДЕКЛАРАЦИИ СВОЙСТВ ОБЪЕКТА СКИДОК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/18/06
Author: Bakhtadze Natalya
Creation date: 09/18/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.prop-head OLD old_prop-head.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись ДЕКЛАРАЦИИ СВОЙСТВ ОБЪЕКТА СКИДОК".
{ cmp/vssrevis.i "substitute('&1'
                         , ub.prop-head.dtm-code
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ gbl/key-rec.i }
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-storage as character no-undo .
define variable v-region-nl as character no-undo .
define variable v-region as character no-undo .
define variable v-confirmed as logical   no-undo .
define variable level as integer   no-undo .
define variable v-p as character no-undo .
define buffer buf_c-prop-head for ub.c-prop-head.
define buffer buf_ruledict for ub.ruledict.
define buffer first_ruledict for ub.ruledict.
define buffer last_ruledict for ub.ruledict.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news
  then do:
    run gen-key-rec in this-procedure ( input {&table_prop-head}
                                        ,input buffer ub.prop-head:handle
                                        ,output v-uniq-key-rec).
    assign
    ub.prop-head.uniq-key-rec = v-uniq-key-rec
    .
    assign
      level = 2
    .
    _repeat:
    repeat while program-name( level ) <> ? :
      v-p = program-name( level ).
      if index(v-p, "fixrum.") > 0
      then do:
        v-confirmed = yes.
        leave _repeat.
      end.
      assign
        level = level + 1
      .
    end.
    _v-ii:
    do v-ii = 1 to 3:
      CASE v-ii:
        when 1 then do:
           assign
           v-storage = ub.prop-head.storage-place
           v-region-nl = "_"
           v-region = '_':U
           .
        end.
        when 2 then do:
           assign
           v-storage = ub.prop-head.storage-place-host
           v-region-nl = "_Фирма"
           v-region = '_host':U
           .
        end.
        when 3 then do:
           assign
           v-storage = ub.prop-head.storage-place-obj
           v-region-nl = "_Объект"
           v-region = '_obj':U
           .
        end.
      END CASE.
      if v-storage = '':U then next _v-ii.
      if not v-confirmed then do:
        find first buf_ruledict where
                  buf_ruledict.entry-type  = 'prop-name' + v-region
              and buf_ruledict.uniq-key-rec  = v-uniq-key-rec no-error.
        if not available buf_ruledict then do:
          find first first_ruledict exclusive-lock use-index pi no-error.
          find last last_ruledict no-lock use-index pi no-error.
          create buf_ruledict.
          assign
          buf_ruledict.entry-type = 'prop-name':U + v-region
          buf_ruledict.uniq-key-rec = v-uniq-key-rec
          buf_ruledict.entry-id = (if available last_ruledict
                                  then (last_ruledict.entry-id + 1)
                                  else 1)
          buf_ruledict.language = "ABL"
          .
        end.
        assign
        buf_ruledict.script-al = ub.prop-head.prop-name  + v-region
        buf_ruledict.script-nl = ub.prop-head.prop-label + v-region-nl
        .
      end.
    end.
  end. /*if not g#news*/
  if not g#news
  or g#db-num <> 0 then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-prop-head.
    buffer-copy old_prop-head to buf_c-prop-head
    assign
    buf_c-prop-head.action             = integer(if new(ub.prop-head) then {&hn-create} else {&hn-update})
    buf_C-prop-head.subject            = {&table_prop-head}
    buf_c-prop-head.dtm-code           = ub.prop-head.dtm-code
    buf_c-prop-head.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-prop-head.corr-time          = v-time
    buf_c-prop-head.corr-user-db-num   = g#db-num
    buf_c-prop-head.corr-user-name     = (if g#news
                                    then {&nts-user}
                                    else g#userid)
    buf_c-prop-head.corr-date          = v-date
    .
  end.
  if not g#news
  and g#db-num = 0
  then do:
    run str/callnews.p
      (input {&table_prop-head}
      ,input (buffer ub.prop-head:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_prop-head}
        , input ( buffer ub.prop-head:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end. /*doe*/