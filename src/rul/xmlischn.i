/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица соответствия схема-профайл

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/20/08
Author: Bakhtadze Natalya
Creation date: 01/20/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table temp-param-name no-undo
field profile_id as integer
field profile-type as character
field schema-name as character
field esys-id as integer
field call_id as character
field once-more as integer
field codex_id as integer
field ruleset_id as integer
field order_id as integer
field param-name as character
field param-type as character
field pack-process-uniq-key-rec as character
index pi is primary unique
esys-id
schema-name
profile_id
call_id
.

procedure xmlischn_fill :
define input  parameter p-codex-id  as integer   no-undo .
define input  parameter p-ruleset-id as integer   no-undo .
define buffer buf_rule-call-param  for ub.rule-call-param.
define buffer buf2_rule-call-param for ub.rule-call-param.
define buffer buf_temp-param-name for temp-param-name.

define variable v-esys-id-list as character no-undo .
define variable v-ii as integer no-undo .

  do
  on error undo, return error return-value
  :
    for each buf_rule-call-param where
            buf_rule-call-param.codex_id = p-codex-id
        and buf_rule-call-param.ruleset_id = p-ruleset-id
    break
    by buf_rule-call-param.call_id
    by buf_rule-call-param.profile_id
    by buf_rule-call-param.once-more
    :
      if first-of(buf_rule-call-param.once-more) then do:
        v-esys-id-list = ''.
        for each buf2_rule-call-param no-lock
           where buf2_rule-call-param.call_id    = buf_rule-call-param.call_id
             and buf2_rule-call-param.codex_id   = buf_rule-call-param.codex_id
             and buf2_rule-call-param.ruleset_id = buf_rule-call-param.ruleset_id
             and buf2_rule-call-param.profile_id = buf_rule-call-param.profile_id
             and buf2_rule-call-param.once-more  = buf_rule-call-param.once-more
             and buf2_rule-call-param.param-2-data-type = {&table_ext-system} :
          if buf2_rule-call-param.param-name = "p-esys-id"
               or
               (buf2_rule-call-param.param-name = "p-esys-id-list"
               and
               buf2_rule-call-param.p-index > 0)
          then do:
            assign
            v-esys-id-list = v-esys-id-list + (if v-esys-id-list = '' then '' else {&comma-char}) +
                            string( buf2_rule-call-param.param-value-integer)
            .
          end.
        end.
      end.
      if v-esys-id-list = "" then v-esys-id-list = "-1".
      if buf_rule-call-param.param-2-data-type = "xsd" then do:
        find first buf_temp-param-name where
                buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
          and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
          and buf_temp-param-name.call_id = buf_rule-call-param.call_id
          and buf_temp-param-name.once-more = buf_rule-call-param.once-more
          no-error.
        if not available buf_temp-param-name then do:
          do v-ii = 1 to num-entries(v-esys-id-list):
            find first buf_temp-param-name where
                    buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
              and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
              and buf_temp-param-name.call_id = buf_rule-call-param.call_id
              and buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
              no-error.
            if not available buf_temp-param-name then do:
&scop codex-code buf_rule-call-param.codex_id
          create buf_temp-param-name.
          assign
          buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
          buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
          buf_temp-param-name.call_id = buf_rule-call-param.call_id
          buf_temp-param-name.once-more = buf_rule-call-param.once-more
          buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
          buf_temp-param-name.ruleset_id = buf_rule-call-param.ruleset_id
          buf_temp-param-name.codex_id = buf_rule-call-param.codex_id
          buf_temp-param-name.order_id = buf_rule-call-param.order_id
          buf_temp-param-name.param-name = buf_rule-call-param.param-name
            buf_temp-param-name.param-type = "xsd"
            buf_temp-param-name.profile-type = {&codex-profile-type}
            buf_temp-param-name.pack-process-uniq-key-rec =
            substitute("&2&1&3&1&4&1&5"
                                                                      , {&delim-par}
                                                                      , buf_rule-call-param.call_id
                                                                      , buf_rule-call-param.codex_id
                                                                      , buf_rule-call-param.ruleset_id
                                                                      , buf_rule-call-param.order_id)
            .
            end.
          end.
        end.
      end.
      if buf_rule-call-param.param-2-data-type = "sub-type" then do:
        find first buf_temp-param-name where
                buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
          and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
          and buf_temp-param-name.call_id = buf_rule-call-param.call_id
          and buf_temp-param-name.once-more = buf_rule-call-param.once-more
          no-error.
        if not available buf_temp-param-name then do:
          do v-ii = 1 to num-entries(v-esys-id-list):
            find first buf_temp-param-name where
                    buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
              and buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
              and buf_temp-param-name.call_id = buf_rule-call-param.call_id
              and buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
              no-error.
            if not available buf_temp-param-name then do:
&scop codex-code buf_rule-call-param.codex_id
            create buf_temp-param-name.
            assign
            buf_temp-param-name.schema-name = buf_rule-call-param.param-value-character
            buf_temp-param-name.profile_id = buf_rule-call-param.profile_id
            buf_temp-param-name.call_id = buf_rule-call-param.call_id
            buf_temp-param-name.once-more = buf_rule-call-param.once-more
            buf_temp-param-name.esys-id = integer(entry(v-ii, v-esys-id-list))
            buf_temp-param-name.ruleset_id = buf_rule-call-param.ruleset_id
            buf_temp-param-name.codex_id = buf_rule-call-param.codex_id
            buf_temp-param-name.order_id = buf_rule-call-param.order_id
            buf_temp-param-name.param-name = buf_rule-call-param.param-name
            buf_temp-param-name.param-type = "no-xsd"
          buf_temp-param-name.profile-type = {&codex-profile-type}
          buf_temp-param-name.pack-process-uniq-key-rec =
          substitute("&2&1&3&1&4&1&5"
                                                                     , {&delim-par}
                                                                     , buf_rule-call-param.call_id
                                                                     , buf_rule-call-param.codex_id
                                                                     , buf_rule-call-param.ruleset_id
                                                                     , buf_rule-call-param.order_id)
          .
        end.
      end.
    end.
    end.
    end.

  end.

end procedure. /* xmlischn_fill */

/* $Workfile$ e n d */