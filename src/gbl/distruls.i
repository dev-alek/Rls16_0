/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры и определения для работы с шаблонами расписаний

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/02/04
Author: Bakhtadze Natalya
Creation date: 09/02/04

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" or  "{1}" = "work" or  "{1}" = "create"  or  "{1}" = ""  &then

&glob time-rule-revision  "v16_0.1"

&glob num-dtr-templates 13

&glob max-num-dr-template 99999

&glob dtr-templates-shift 50000

&endif

/*week-day-a один из week-day-0 week-day-1 week-day-2 week-day-3 week-day-4 week-day-5 week-day-6 week-day-7 */
/*week-day-b один из week-day-1 week-day-2 week-day-3 week-day-4 week-day-5 week-day-6 week-day-7 */
/*week-day-c один или несколько из week-day-1 week-day-2 week-day-3 week-day-4 week-day-5 week-day-6 week-day-7 */

&if "{1}" = "create" &then

procedure check-dtr-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define buffer buf_dis-time-rule for ub.dis-time-rule .

  do
  on error undo, return error
  :
    find first buf_dis-time-rule no-lock where
              buf_dis-time-rule.time-rule-num = {&dtr-templates-shift}  no-error .
    if not available buf_dis-time-rule
    or buf_dis-time-rule.des <> {&time-rule-revision} then do:
      assign
      v-dopi1 = integer(entry(2, buf_Dis-time-rule.des, "."))
      v-dopi2 = integer(entry(2, {&time-rule-revision}, "."))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or left-trim(entry(1, buf_Dis-time-rule.des, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes .
      end.
    end.

  end.

end procedure. /* check-dtr-version */

procedure get-dtr-version :
define output parameter p-dtr-version as character no-undo init ?.
define buffer buf_dis-time-rule for ub.dis-time-rule .

do
on error undo, return error
:
  find first buf_dis-time-rule no-lock where
            buf_dis-time-rule.time-rule-num = {&dtr-templates-shift} no-error .
  if available buf_dis-time-rule then do:
      p-dtr-version = buf_dis-time-rule.des.
  end.
end.
end procedure. /* get-dr-version */


&endif


&if "{1}" = "work" &then



procedure dtr-code :

  do
  on error undo, return error
  :
    define input  parameter  p-templ-rl-root     like ub.dis-time-rule.templ-rl-root     no-undo .
    define output parameter  p-des               like ub.dis-time-rule.des               no-undo .
    define output parameter  p-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
    define output parameter  p-value-type        like ub.dis-time-rule.value-type        no-undo .
    define output parameter  p-level-1 as character no-undo .
    define output parameter  p-level-2 as character no-undo .
    define output parameter  p-output-display as logical   no-undo . /* виден в броусе */
    define output parameter  p-tree           as char  no-undo . /* может быть несколько с таким названием поля */
    define output parameter  p-other          as character no-undo . /* еще чего - нибудь */
    define variable v-templ-rl-root like ub.dis-time-rule.templ-rl-root no-undo .

    define buffer buf_dis-time-rule for ub.dis-time-rule .
    define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.

    if p-templ-rl-root < {&dtr-templates-shift} then
    v-templ-rl-root = (p-templ-rl-root + {&dtr-templates-shift}).
    else v-templ-rl-root = p-templ-rl-root.
    find first buf_dis-time-rule no-lock where
              buf_dis-time-rule.time-rule-num = v-templ-rl-root no-error .
    if not available buf_dis-time-rule then do:
      undo, return error substitute("неизвестный тип расписания &1", p-templ-rl-root) .
    end.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = 0
        and buf_dis-cfg-rule.time-templ-rl-root = p-templ-rl-root
        and buf_dis-cfg-rule.pos-type = '':U
        and buf_dis-cfg-rule.table-name = '':U
        and buf_dis-cfg-rule.discnt-role = '':U
        and buf_dis-cfg-rule.self-nonunique = '':U
            no-error.
    if not available buf_Dis-cfg-rule then do:
        undo, return error substitute("неизвестный тип расписания &1", p-templ-rl-root ).
    end.
    assign
    p-des = buf_dis-time-rule.des
    p-upper-time-rule-num = (buf_dis-time-rule.upper-time-rule-num - {&dtr-templates-shift})
    p-value-type = buf_dis-time-rule.value-type
    p-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
    p-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                 then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                 else '')
    p-output-display = (buf_dis-time-rule.sts = integer({&used-status-int}))
    p-tree = buf_dis-time-rule.uniq-field
    p-other = buf_dis-time-rule.other-inf
    .
  end.
end procedure.

&endif



/* $Workfile$ e n d */