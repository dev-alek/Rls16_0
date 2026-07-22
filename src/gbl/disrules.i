/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры и определения для работы с шаблонами скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/02/04
Author: Bakhtadze Natalya
Creation date: 09/02/04

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(disrules_i) = 0 &then

&glob disrules_i

&if "{1}" = "def" or  "{1}" = "work"  or  "{1}" = "create"  or "{1}" = "" &then

&glob rule-revision  "v16_0.1"

&glob num-dr-templates 93

&glob max-num-dr-template 99999

&endif

&if "{1}" = "create" &then

&glob rule-md5    { cmp/fixdr.md5 }

procedure check-dr-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule .


  do
  on error undo, return error
  :
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = 0 no-error .
    if (not available buf_dis-rule
    or buf_dis-rule.des <> {&rule-revision} )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_Dis-rule.des, "."))
      v-dopi2 = integer(entry(2, {&rule-revision}, "."))
      v-dopi3 = integer(entry(2, entry(1, buf_Dis-rule.des, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, {&rule-revision}, "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_Dis-rule.des, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.

end procedure. /* check-dr-version */

procedure get-dr-version :
define output parameter p-dr-version as character no-undo init ?.
define buffer buf_dis-rule for ub.dis-rule .

do
on error undo, return error
:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = 0 no-error .
  if available buf_dis-rule then do:
      p-dr-version = buf_dis-rule.des.
  end.
end.
end procedure. /* get-dr-version */

&endif


&if "{1}" = "work" &then

procedure dr-code :

  do
  on error undo, return error
  :
    define input  parameter  p-templ-rl-root     like ub.dis-rule.templ-rl-root     no-undo .
    define output parameter  p-des               like ub.dis-rule.des               no-undo .
    define output parameter  p-discnt-type       like ub.dis-rule.discnt-type       no-undo .
    define output parameter  p-subject-type      like ub.dis-rule.subject-type      no-undo .
    define output parameter  p-value-type        like ub.dis-rule.value-type        no-undo .
    define output parameter  p-level-1           as character no-undo .
    define output parameter  p-level-2           as character no-undo .
    define output parameter  p-global             as integer no-undo .
    define output parameter  p-host               as integer no-undo .
    define output parameter  p-object             as integer no-undo .
    define output parameter  p-output-display as logical   no-undo . /* виден в броусе имеет статус 0*/
    define output parameter  p-tree           as char  no-undo . /* может быть несколько с таким названием поля */
    define output parameter  p-other          as character no-undo . /* еще чего - нибудь */

    define variable v-other as character no-undo .
    define buffer buf_dis-rule for ub.dis-rule .
    define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-templ-rl-root no-error.

    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        and buf_dis-cfg-rule.pos-type = '':U
        and buf_dis-cfg-rule.table-name = '':U
        and buf_dis-cfg-rule.discnt-role = '':U
        and buf_dis-cfg-rule.self-nonunique = '':U
            no-error.
    if not available buf_Dis-cfg-rule then do:
        undo, return error substitute("неизвестный шаблон скидки &1", p-templ-rl-root ).
    end.
    assign
    p-des = buf_dis-rule.des
    p-discnt-type = buf_dis-rule.discnt-type
    p-subject-type = buf_dis-rule.subject-type
    p-value-type = buf_dis-rule.value-type
    p-global = (if available buf_dis-cfg-rule
                then buf_dis-cfg-rule.has-global
                else 0)
    p-host = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-host
              else 0)
    p-object = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-obj
              else 0)
    p-output-display = (buf_dis-rule.sts = integer({&used-status-int}))
    p-tree = buf_Dis-rule.uniq-field
    p-other = buf_dis-rule.other-inf
    p-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
    p-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                 then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                 else '')
    .
  end.
end procedure.

&endif
&endif

&if defined(disrules_temp-drt-prop) = 0 &then
define temp-table temp-drt-prop no-undo like ub.drt-prop.
&glob disrules_temp-drt-prop
&endif

&if defined(disrules_fill-properties) = 0 &then
&glob disrules_fill-properties
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:

  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.

end procedure.
&endif


&if "{1}" = "work" or "{1}" = "interface" &then
&if defined(disrules_get-interface-form) = 0 &then
&glob disrules_get-interface-form
procedure disrules-get-interface-form :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define output parameter p-form-name as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
find first buf_temp-drt-prop where
          buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
      and buf_temp-drt-prop.upper-prop-code = "InputForm"
      and buf_temp-drt-prop.prop-code = "FormName" no-error.
if not available buf_temp-drt-prop then do:
  find first buf_drt-prop where
            buf_drt-prop.templ-rl-root = p-templ-rl-root
        and buf_drt-prop.upper-prop-code = "InputForm"
        and buf_drt-prop.prop-code = "FormName" no-error.
  if available buf_drt-prop then do:
    p-form-name = buf_drt-prop.property-value.
  end.
  else do:
    p-form-name = "ref/dis-ruli.w".
  end.
end.
else do:
  p-form-name = buf_temp-drt-prop.property-value.
end.

end procedure.
&endif
&endif

&if "{1}" = "interface" &then


procedure disrules-override-labels :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
define buffer bufformat_temp-drt-prop for ub.drt-prop.

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  if not can-find(first temp-drt-prop) then do:
    run disrules-fill-properties in this-procedure ( input p-templ-rl-root).
  end.

  if can-find(first buf_temp-drt-prop no-lock where
                    buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
                and buf_temp-drt-prop.prop-code = "Label"
                ) then do:
    for each buf_temp-drt-prop no-lock where
                    buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
                and buf_temp-drt-prop.prop-code = "Label":U:
      assign
      fh = frame {&frame-name}:first-child
      hh = fh:first-child
      .
      do while valid-handle(hh):
        if index(hh:name, buf_temp-drt-prop.upper-prop-code) > 0
        and (index(hh:name, buf_temp-drt-prop.upper-prop-code) + length(buf_temp-drt-prop.upper-prop-code) - 1 =
             length(hh:name))
        then do:
          assign
          hh:label = buf_temp-drt-prop.property-value
          .
          /*
          find first bufformat_temp-drt-prop no-lock where
                bufformat_temp-drt-prop.templ-rl-root = p-templ-rl-root
            and bufformat_temp-drt-prop.upper-node-code = buf_temp-drt-prop.upper-node-code
            and bufformat_temp-drt-prop.prop-code = "Format" no-error.
          if available bufformat_temp-drt-prop then do:
            assign
            hh:format = bufformat_temp-drt-prop.property-value
            .
          end.
          */
        end.
        hh = hh:next-sibling.
      end. /*do while*/
    end. /*for each*/
    &if "{2}" <> "no-br-term-dr" &then
    for each buf_temp-drt-prop no-lock where
                    buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
                and buf_temp-drt-prop.prop-code = "Column-Label":U:

      assign
      fh = browse BR-term-dr:first-column
      .
      do while valid-handle(fh):
        if index(fh:name, buf_temp-drt-prop.upper-prop-code) > 0 then do:
          assign
          fh:label = buf_temp-drt-prop.property-value
          .
          /*
          find first bufformat_temp-drt-prop no-lock where
                bufformat_temp-drt-prop.templ-rl-root = p-templ-rl-root
            and bufformat_temp-drt-prop.upper-node-code = buf_temp-drt-prop.upper-node-code
            and bufformat_temp-drt-prop.prop-code = "Format" no-error.
          if available bufformat_temp-drt-prop then do:
            assign
            fh:format = bufformat_temp-drt-prop.property-value
            .
          end.
          */
        end.
        fh = fh:next-column.
      end. /*do while*/
    end. /*for each */
    &endif
  end. /*if can-find(first buf_temp-drt-prop no-lock where*/
end. /*doe*/

end procedure. /* disrules-override-labels */

&endif

&if "{1}" = "cash-desk" &then

define temp-table cash-dis-rule no-undo like ub.dis-rule.
define temp-table cash-dis-time-rule no-undo like ub.dis-time-rule.

procedure create-dis-rule :
define input parameter p-rule-num like ub.dis-rule.rule-num no-undo .
define input parameter p-tree as logical no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer term_dis-rule for ub.dis-rule.
define buffer term_dis-time-rule for ub.dis-time-rule.
define buffer root_cash-dis-rule for cash-dis-rule.
define buffer root_cash-dis-time-rule for cash-dis-time-rule.
define buffer term_cash-dis-rule for cash-dis-rule.
define buffer term_cash-dis-time-rule for cash-dis-time-rule.


  do
  on error undo, return error
  :
    find first root_cash-dis-rule no-lock where                                                         ~
              root_cash-dis-rule.rule-num = p-rule-num no-error.
    if not available root_cash-dis-rule then do:
      find first buf_dis-rule no-lock where
                buf_dis-rule.rule-num = p-rule-num no-error.
      if available buf_dis-rule then do:
        if buf_dis-rule.time-rule-num <> 0 then do:
          find first buf_dis-time-rule no-lock where
                    buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num no-error.
        end.
        create root_cash-dis-rule.
        buffer-copy buf_dis-rule to root_cash-dis-rule.
        if available buf_dis-time-rule then do:
          find first root_cash-dis-time-rule no-lock where
                    root_cash-dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num no-error.
          if not available root_cash-dis-time-rule then do:
            create root_cash-dis-time-rule.
            buffer-copy buf_dis-time-rule to root_cash-dis-time-rule.
          end.
        end.
        else do:
          assign
          root_cash-dis-rule.time-rule-num = 0.
        end.
        if buf_dis-rule.uniq-field <> "":U then do:
          for each term_dis-rule no-lock where
                  term_dis-rule.upper-rule-num =  buf_dis-rule.rule-num:
            if term_dis-rule.time-rule-num <> 0 then do:
              find first term_dis-time-rule no-lock where
                        term_dis-time-rule.time-rule-num = term_dis-rule.time-rule-num no-error.
            end.
            create term_cash-dis-rule.
            buffer-copy term_dis-rule to term_cash-dis-rule.
            if term_dis-rule.time-rule-num = 0
            or available term_dis-time-rule
            or root_cash-dis-rule.time-rule-num = 0
            then do:
              if available term_dis-time-rule then do:
                find first term_cash-dis-time-rule no-lock where
                          term_cash-dis-time-rule.time-rule-num = term_dis-rule.time-rule-num no-error.
                if not available term_cash-dis-time-rule then do:
                  create term_cash-dis-time-rule.
                  buffer-copy term_dis-time-rule to term_cash-dis-time-rule.
                end.
              end.
            end.
          end.
        end.
      end.  /*if available buf_dis-rule then do:                                                           */
    end. /*if not available cash-dis-rule then do:                                                        */
  end.

end procedure. /* create-dis-rule */

&endif

/* $Workfile$ e n d */