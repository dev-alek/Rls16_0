block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись МАППИНГА СВОЙСТВ ОБЪЕКТА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/27/06
Author: Bakhtadze Natalya
Creation date: 09/27/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.prop-map.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись МАППИНГА СВОЙСТВ ОБЪЕКТА".
{ cmp/vssrevis.i "substitute('&1'
                         , ub.prop-map.dtm-code
                         , ub.prop-map.node-code
                         ) " }

{ cmp/trg-def.i }

{ gbl/key-rec.i }

define variable v-uniq-key-rec as character no-undo .
define variable v-ii as integer no-undo .
define variable v-region as character no-undo .
define variable v-region-nl as character no-undo .
define variable v-region2 as character no-undo .
define variable v-confirmed as logical   no-undo .
define variable level as integer   no-undo .
define variable v-p as character no-undo .

define buffer buf_prop-head for ub.prop-head.
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
    run gen-key-rec in this-procedure (
                                        input {&table_prop-map}
                                        ,input  buffer ub.prop-map:handle
                                        ,output v-uniq-key-rec
                                        ).
    assign
    ub.prop-map.uniq-key-rec = v-uniq-key-rec
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

    if ub.prop-map.is-term = yes
    and not ub.prop-map.node-name begins '#'
    then do:
      find first buf_prop-head no-lock where
                buf_prop-head.dtm-code = ub.prop-map.dtm-code.
      _v-ii:
      do v-ii = 1 to 3:
        if v-ii = 1 then do:
          assign
          v-region = buf_prop-head.storage-place
          v-region2 = '_'
          v-region-nl = "_"
          .
        end.
        if v-ii = 2 then do:
          assign
          v-region = buf_prop-head.storage-place-host
          v-region2 = '_host'
          v-region-nl = "_Фирма"
          .
        end.
        if v-ii = 3 then do:
          assign
          v-region = buf_prop-head.storage-place-obj
          v-region2 = '_obj'
          v-region-nl = "_Объект"
          .
        end.
        if v-region = '':U then next _v-ii.
        if not v-confirmed then do:
          find first buf_ruledict where
                    buf_ruledict.entry-type  = 'node-name':U + v-region2
                and buf_ruledict.uniq-key-rec  = v-uniq-key-rec no-error.
          if not available buf_ruledict then do:
            find first first_ruledict exclusive-lock use-index pi no-error.
            find last last_ruledict no-lock use-index pi no-error.
            create buf_ruledict.
            assign
            buf_ruledict.entry-type = 'node-name':U + v-region2
            buf_ruledict.uniq-key-rec = v-uniq-key-rec
            buf_ruledict.entry-id = (if available last_ruledict
                                     then last_ruledict.entry-id + 1
                                     else 1)
            buf_ruledict.language = "ABL"
            .
          end.
          assign
          buf_ruledict.script-al = ub.prop-map.node-name
          buf_ruledict.script-nl = buf_prop-head.prop-label + v-region-nl + '.':U + ub.prop-map.node-label
          .
        end.
      end. /*v-ii = 1 to 3*/
    end. /*if p-is-term*/
  end.

  if not g#news
  and g#db-num = 0
  then do:
    run str/callnews.p
      (input {&table_prop-map}
      ,input (buffer ub.prop-map:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_prop-map}
        , input ( buffer ub.prop-map:handle )
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
end.