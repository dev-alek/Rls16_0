/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с скидками товара на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/disrules.i }
{ gbl/discfgru.i }
{ gbl/get-regf.i }

procedure disgdsru-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :

  define input  parameter p-templ-rl-root  as integer no-undo . /* код атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.

  if available buf_dis-rule
  then do:
    if buf_dis-rule.rule-num > 0 then
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.


end.
end procedure.

function disgdsru-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disgdsru-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.

function disgdsru-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
&scoped-define dis-gds-rule-code p-discnt-role
return {&dis-gds-rule-name}.
end function.


procedure disgdsru-write :

  do
  on error undo, return error
  :
    define input parameter p-obj-type       like ub.dis-gds-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-gds-rule.obj-code   no-undo .
    define input parameter p-gds-code       like ub.dis-gds-rule.gds-code   no-undo .
    define input parameter p-pos-type       like ub.dis-gds-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-gds-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-gds-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-gds-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-gds-rule.rule-num    no-undo .
    define input parameter p-nonunique      like ub.dis-gds-rule.nonunique   no-undo .
    define buffer buf_dis-gds-rule for ub.dis-gds-rule .
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer lock_dis-gds-rule for ub.dis-gds-rule .

    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .

    run discfgru-check in this-procedure (
                                          input {&table_dis-gds-rule}
                                         ,input p-templ-rl-root   /* p-templ-rl-root   */
                                         ,input p-time-templ-rl-root
                                         ,input p-pos-type        /**/
                                         ,output v-discnt-role
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-discnt-role = ? then do:
      p-discnt-role = v-discnt-role.
    end.
    if p-discnt-role <> v-discnt-role then do:

&scop dis-gds-rule-code p-discnt-role
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не может быть по шаблону &7 и расписанию &8"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,{&dis-gds-rule-name}
                              ,{&new-line}
                              ,p-templ-rl-root
                              ,p-rule-num).


    end.
    if p-pos-type = ? then do:
      { gbl/dflt-cd.i p-obj-type p-obj-code p-pos-type }
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не найдено правило скидки &7"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,{&dis-gds-rule-name}
                              ,{&new-line}
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6правило скидки &7 - некорневое"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,{&dis-gds-rule-name}
                              ,{&new-line}
                              ,p-rule-num).

    end.
    if not (p-obj-type = buf_dis-rule.obj-type
        and p-obj-code = buf_dis-rule.obj-code)
    and not ( (p-obj-type = {&shop} or p-obj-type = {&stock} )
             and
             (buf_dis-rule.obj-type = {&cmp} or buf_dis-rule.obj-type = ""))
     then do:
      undo, return error (substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,{&dis-gds-rule-name}
                              ,{&new-line}
                              ) +
                          substitute("Правило скидки &1 определено для &2&3" +
                                     "а привязка к товару для &4"
                                     ,buf_dis-rule.rule-num
                                     ,get-objregion( buf_dis-rule.obj-type, buf_Dis-rule.obj-code)
                                     ,{&new-line}
                                     ,get-objregion( p-obj-type, p-obj-code)
                                     ))
                              .
    end.
    find first buf_dis-gds-rule exclusive-lock where
               buf_dis-gds-rule.gds-code  = p-gds-code
           AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
           AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
           AND buf_dis-gds-rule.pos-type  = p-pos-type
           AND buf_dis-gds-rule.discnt-role = p-discnt-role
           and buf_dis-gds-rule.nonunique = p-nonunique
           no-error .
    if not available buf_dis-gds-rule then do:
      find first buf_dis-gds-rule exclusive-lock where
                buf_dis-gds-rule.gds-code  = p-gds-code
            AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
            AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
            AND buf_dis-gds-rule.pos-type  = p-pos-type
            AND buf_dis-gds-rule.discnt-role = p-discnt-role
            no-error .
      if available buf_Dis-gds-rule then do:
        if p-nonunique = ''
        and available buf_dis-gds-rule
        then do:
&scoped-define dis-gds-rule-code p-discnt-role
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует (детализ. &3)"
                                   , {&dis-gds-rule-name}
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                   , p-nonunique
                                  ).
        end.
        if available buf_dis-gds-rule
        and buf_dis-gds-rule.nonunique = ''
        and p-nonunique <> ''then do:
&scoped-define dis-gds-rule-code p-discnt-role
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует"
                                   , {&dis-gds-rule-name}
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                  ).
        end.
      end.
      create buf_dis-gds-rule .
      assign
      buf_dis-gds-rule.gds-code  = p-gds-code
      buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
      buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
      buf_dis-gds-rule.pos-type = p-pos-type
      buf_dis-gds-rule.discnt-role = v-discnt-role
      buf_dis-gds-rule.rule-num = p-rule-num
      buf_dis-gds-rule.nonunique = p-nonunique
      no-error
      .
    end.
    ASSIGN
    buf_dis-gds-rule.rule-num = p-rule-num
    buf_dis-gds-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-gds-rule.templ-rl-root = p-templ-rl-root
    buf_dis-gds-rule.nonunique = p-nonunique
    no-error.
  end.

end procedure.

/*использульзуется в dgr-lst.p и dgrbylst.w для привязки фирменных правил*/
PROCEDURE cmp-disgdsru-write :
do
on error undo, return error
:

  define input parameter p-gds-code like ub.dis-gds-rule.gds-code   no-undo .
  define input parameter p-obj-type like ub.dis-gds-rule.obj-type   no-undo .
  define input parameter p-obj-code like ub.dis-gds-rule.obj-code   no-undo .
  define input parameter p-pos-type like ub.dis-gds-rule.pos-type   no-undo .
  define input parameter p-templ-rl-root     like ub.dis-gds-rule.templ-rl-root  no-undo .
  define input parameter p-time-templ-rl-root     like ub.dis-gds-rule.time-templ-rl-root  no-undo .
  define input parameter p-discnt-role like ub.dis-gds-rule.discnt-role no-undo .
  define input parameter p-rule-num    like ub.dis-gds-rule.rule-num no-undo .
  define input parameter p-nonunique like ub.dis-gds-rule.nonunique no-undo .

  define variable v-rule-label          as character no-undo .

  define buffer buf_tt0-dis-gds-rule for ub.dis-gds-rule .
  define buffer buf_dis-rule     for ub.dis-rule.

  run disgdsru-name in this-procedure (
                                      input  p-templ-rl-root           /* p-templ-rl-root           */
                                      ,output v-rule-label          /* p-label          */
                                      ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.

  find first buf_tt0-dis-gds-rule exclusive-lock where
              buf_tt0-dis-gds-rule.gds-code  = p-gds-code
          AND buf_tt0-dis-gds-rule.obj-type  = p-obj-type
          AND buf_tt0-dis-gds-rule.obj-code  = p-obj-code
          AND buf_tt0-dis-gds-rule.pos-type  = p-pos-type
          AND buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
          AND buf_tt0-dis-gds-rule.nonunique = p-nonunique
          no-error .
  if not available buf_tt0-dis-gds-rule then do:
    create buf_tt0-dis-gds-rule .
    assign
    buf_tt0-dis-gds-rule.gds-code  = p-gds-code
    buf_tt0-dis-gds-rule.obj-type  = p-obj-type
    buf_tt0-dis-gds-rule.obj-code  = p-obj-code
    buf_tt0-dis-gds-rule.pos-type  = p-pos-type
    buf_tt0-dis-gds-rule.nonunique = p-nonunique
    buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
    no-error
    .
  end.
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-rule-num.
  ASSIGN
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rule-num = p-rule-num
  buf_tt0-dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
  buf_tt0-dis-gds-rule.nonunique = p-nonunique
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rl-root = buf_Dis-rule.rl-root
  no-error.
  release buf_tt0-dis-gds-rule no-error .
  if error-status:error then do:
    undo, return error return-value .
  end.
end.

END PROCEDURE.

&if "{1}" = "interface"  &then
 &if "{3}" <> ""  &then

procedure disgdsru-edit :
define input parameter p-mode as character no-undo .
define input parameter p-gds-code like ub.dis-gds-rule.gds-code no-undo .
define input parameter p-obj-type like ub.dis-gds-rule.obj-type no-undo .
define input parameter p-obj-code like ub.dis-gds-rule.obj-code no-undo .
define input parameter p-pos-type like ub.dis-gds-rule.pos-type no-undo .
define input parameter p-discnt-role like ub.dis-gds-rule.discnt-role no-undo .
define input parameter p-templ-rl-root like ub.dis-gds-rule.templ-rl-root no-undo .
define input parameter p-time-templ-rl-root like ub.dis-gds-rule.time-templ-rl-root no-undo .
define input parameter p-cfg-NONUNIQUE as character no-undo .
define input parameter p-check as integer no-undo .
define input-output parameter p-rule-num as integer no-undo .
define input-output parameter p-NONUNIQUE like ub.dis-gds-rule.NONUNIQUE no-undo .
define output parameter p-setted as logical no-undo .

define variable v-sts as integer no-undo .
define variable v-rid-list as character no-undo .
define variable r-b-code like ub.bar-code.b-code no-undo .
define variable v-label as character no-undo .
DEFINE VARIABLE v-rule-num as integer no-undo .
define variable v-cd-dr-correct  as logical no-undo .
define variable jj as integer no-undo .
define variable conf-par as character no-undo .
define variable conf-attr as character no-undo .
define variable par-type as character no-undo .
define variable dflt-cd as character no-undo .
define variable v-cd-list as character no-undo .
define variable v-is-time-rule as logical no-undo .
define variable v-nonunique as character no-undo .
define variable v-mode as character no-undo .
define variable v-time-templ-rl-root as integer   no-undo .
define variable v-cfg-nonunique as character no-undo .

define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer term_dis-rule for ub.dis-rule.
define buffer buf_{3} for {3}.

assign
v-rule-num = p-rule-num.
v-sts = integer({&current-status-int}).
if v-rule-num <> 0
and v-rule-num <> ?
then do:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = v-rule-num no-error .
  if error-status:error then do:
    message
    "Ошибка при поиске правила с номером" v-rule-num
    view-as alert-box error .
    return .
  end.
  assign
  v-rid-list = string(recid(buf_dis-rule))
  .
end.
if p-gds-code <> 0 then do:
  { gbl/gdsbcode.i p-gds-code ? r-b-code }
end.
run disgdsru-name in this-procedure (
                                  input p-templ-rl-root
                                 ,output v-label) no-error.
if p-pos-type = ?
or p-pos-type = '':U then do:
  { gbl/dflt-cd.i p-obj-type p-obj-code dflt-cd }
end.
else do:
  dflt-cd = p-pos-type.
end.
v-mode = (if p-obj-type = {&shop}
          or p-obj-type = {&stock}
/*{&all}  "upper-rule-num"  "template" {&g___object} "time-rule-num" upper-rule-num-object upper-rule-num-host upper-rule-num-global
"upper-rule-num-gds-obj  dis-gds-rule-gds-obj cd-obj  "template-value-type"*/
          /*then (if p-gds-code = 0 then "upper-rule-num-object":u else "upper-rule-num-gds-obj":U)*/
          then (if p-gds-code = 0 then "upper-rule-num-all-obj" else "upper-rule-num-gds-obj":U)
          else ({&table_dis-gds-rule} + "=" + p-discnt-role)).
if p-discnt-role <> ''
and p-pos-type <> '' then do:
  find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.table-name = {&table_dis-gds-rule}
        and buf_dis-cfg-rule.discnt-role = p-discnt-role
        and buf_dis-cfg-rule.pos-type = p-pos-type
        and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        no-error .
  if available buf_dis-cfg-rule then do:
    assign
    v-cfg-nonunique = buf_dis-cfg-rule.nonunique.
  end.
end.
if v-cfg-nonunique <> ''
and num-entries(v-cfg-nonunique, ".") > 1
then do:
  case v-cfg-nonunique:
    when "bar-code.b-code" then do:
      r-b-code = integer(p-nonunique).
    end.
  end case.
end.

run ref/dis-ruls.w (
             input {2}
            ,input 0 /*p-host-code*/
            ,input p-obj-type
            ,input p-obj-code
            ,input "b-add,b-sel":U
            ,input v-mode
            ,input p-templ-rl-root
            ,input p-time-templ-rl-root
            ,input r-b-code
            ,input-output v-sts
            ,input-output v-rid-list ) no-error .
do
on error undo, return error return-value
:
  if v-rid-list <> "":U then do:
    find first buf_dis-rule exclusive-lock where
                recid(buf_dis-rule) = integer(v-rid-list) no-wait no-error .
    if not available buf_dis-rule
    then do:
      message
      "Ошибка при поиске правила с recid" v-rid-list
      view-as alert-box error .
      return .
    end.
    if buf_dis-rule.sts <> integer({&used-status-int}) then do:
&scop used-status-code string(buf_dis-rule.sts)
      message
      "Правило скидки имеет статус" {&used-status-int-name} skip
      "Нельзя привязать к нему скидку на товар"
      view-as alert-box error .
      return .
    end.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        and buf_dis-cfg-rule.time-templ-rl-root = (if buf_dis-rule.time-templ-rl-root = 0
                                                   then 0
                                                   else buf_dis-rule.time-templ-rl-root)
        and buf_dis-cfg-rule.pos-type = dflt-cd
        and buf_dis-cfg-rule.table-name = {&table_dis-gds-rule}
        no-error.
    if available buf_dis-cfg-rule then do:
      assign
      v-cd-dr-correct = yes
      .
    end.
    else do:
       if buf_dis-rule.is-term = no then do:
         for each term_dis-rule no-lock where
            term_dis-rule.upper-rule-num = buf_dis-rule.rule-num:
           find first buf_dis-cfg-rule no-lock where
                  buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
              and buf_dis-cfg-rule.time-templ-rl-root = term_dis-rule.time-templ-rl-root
              and buf_dis-cfg-rule.pos-type = dflt-cd
              and buf_dis-cfg-rule.table-name = {&table_dis-gds-rule}
              no-error.
           if available buf_dis-cfg-rule
           and v-time-templ-rl-root = 0
           then do:
              v-time-templ-rl-root = term_dis-rule.time-templ-rl-root.
              v-cd-dr-correct = yes.
           end.
           if not available buf_dis-cfg-rule
           or v-time-templ-rl-root <> term_dis-rule.time-templ-rl-root then do:
             v-cd-dr-correct = no.
             leave.
           end.
         end.
       end.
    end.
    if not v-cd-dr-correct
    then do:
      message
      substitute("Правило скидки &1 неприменимо для касс &2.&3" +
                "(АРМ АДМИНИСТРАТОР-Магазины(Фирмы)-Параметры-Общие опции коммуникации с кассами)"
                ,buf_dis-rule.rule-num
                ,dflt-cd
                ,{&new-line}
                )
      view-as alert-box error .
      undo, return error .
    end.
    assign
    v-nonunique = if p-cfg-nonunique = '':U
                  then '':U
                  else (if p-cfg-nonunique begins "@"
                        then left-trim(p-cfg-nonunique, "@")
                        else string(buffer buf_Dis-rule:handle:buffer-field(p-cfg-nonunique):buffer-value)
                        )
                  .
    if p-check = 0
    or p-check = 2
    then do:
      find first buf_dis-gds-rule no-lock where
                  buf_dis-gds-rule.obj-type = p-obj-type
              and buf_dis-gds-rule.obj-code = p-obj-code
              and buf_dis-gds-rule.gds-code = p-gds-code
              and buf_dis-gds-rule.pos-type = p-pos-type
              and buf_dis-gds-rule.discnt-role = p-discnt-role
              and buf_dis-gds-rule.nonunique = v-nonunique no-error .
      if available buf_dis-gds-rule
      and p-mode <> {&update}
      then do:
        message
        "Скидка такого типа на данный товар уже существует"
        view-as alert-box error .
        return error.
      end.
      find first buf_dis-gds-rule no-lock where
                  buf_dis-gds-rule.obj-type = p-obj-type
              and buf_dis-gds-rule.obj-code = p-obj-code
              and buf_dis-gds-rule.gds-code = p-gds-code
              and buf_dis-gds-rule.pos-type = p-pos-type
              and buf_dis-gds-rule.discnt-role = p-discnt-role
              no-error .
      if v-nonunique = ''
      and available buf_dis-gds-rule
      and p-mode <> {&update}
      then do:
        message
        "Скидка такого типа на данный товар уже существует"
        view-as alert-box error .
        return error.
      end.
      if available buf_dis-gds-rule
      and buf_dis-gds-rule.nonunique = ''
      and v-nonunique <> ''
      and p-mode <> {&update}
      then do:
        message
        "Скидка такого типа на данный товар уже существует"
        view-as alert-box error .
        return error.
      end.
    end.
    if p-check = 1
    or p-check = 2
    then do:
      find first buf_{3} no-lock where
                  buf_{3}.obj-type = p-obj-type
              and buf_{3}.obj-code = p-obj-code
              &if "{3}" = "temp-disc" &then
              &else
              and buf_{3}.gds-code = p-gds-code
              &endif
              and buf_{3}.pos-type = p-pos-type
              and buf_{3}.discnt-role = p-discnt-role
              and buf_{3}.nonunique = v-nonunique no-error .
      if available buf_{3}
      and buf_{3}.rule-num <> 0
      and p-mode <> {&update}
      then do:
        message
        "Скидка такого типа на данный товар уже существует"
        view-as alert-box error .
        return error.
      end.
      find first buf_{3} no-lock where
                  buf_{3}.obj-type = p-obj-type
              and buf_{3}.obj-code = p-obj-code
              &if "{3}" = "temp-disc" &then
              &else
              and buf_{3}.gds-code = p-gds-code
              &endif
              and buf_{3}.pos-type = p-pos-type
              and buf_{3}.discnt-role = p-discnt-role
              no-error .
      if v-nonunique = ''
      and available buf_{3}
      and p-mode <> {&update}
      then do:
        message
        "Скидка такого типа на данный товар уже существует"
        view-as alert-box error .
        return error.
      end.
      if available buf_{3}
      and buf_{3}.nonunique = ''
      and v-nonunique <> ''
      and p-mode <> {&update}
      then do:
        message
        "Скидка такого типа на данный товар уже существует"
        view-as alert-box error .
        return error.
      end.
    end.
    if p-rule-num <> buf_dis-rule.rule-num then do:
      assign
      p-setted = yes
      p-rule-num = buf_dis-rule.rule-num
      p-nonunique = v-nonunique
      .
    end.
  end.
end. /*doe*/

end procedure. /* disgdsru-edit */
 &endif


procedure dsp-dis-rule :
define input parameter p-gds-code like ub.dis-gds-rule.gds-code no-undo .
define input parameter p-nonunique as character no-undo .
define input parameter p-obj-type like ub.dis-gds-rule.obj-type no-undo .
define input parameter p-obj-code like ub.dis-gds-rule.obj-code no-undo .
define input parameter p-discnt-role as character no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-value like ub.dis-gds-rule.rule-num no-undo .
define buffer buf_dis-rule for ub.dis-rule.
DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable r-b-code like ub.bar-code.b-code no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define variable v-cfg-nonunique as character no-undo .


  do
  on error undo, return error
  :
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-value no-error .
    if not available buf_dis-rule then do:
      message substitute("Не найдено правило скидки с номером &1", p-value)
      view-as alert-box error .
      .
      return.
    end.
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_discount_work':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
    }
    if not loc#log then return error.
    ASSIGN
    loc-doc-rec = recid(buf_dis-rule)
    .
    if p-gds-code <> ? then do:
      { gbl/gdsbcode.i p-gds-code ? r-b-code }
    end.
    define variable v-form-name as character no-undo init "ref/dis-ruli.w".
    run disrules-get-interface-form in this-procedure ( input buf_dis-rule.templ-rl-root
                                                      ,output v-form-name) .
    if p-discnt-role <> ''
    and p-pos-type <> '' then do:
      find first buf_dis-cfg-rule no-lock where
                buf_dis-cfg-rule.table-name = {&table_dis-gds-rule}
            and buf_dis-cfg-rule.discnt-role = p-discnt-role
            and buf_dis-cfg-rule.pos-type = p-pos-type
            and buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
            no-error .
      if available buf_dis-cfg-rule then do:
        assign
        v-cfg-nonunique = buf_dis-cfg-rule.nonunique.
      end.
    end.
    if v-cfg-nonunique <> ''
    and num-entries(v-cfg-nonunique, ".") > 1
    then do:
      case v-cfg-nonunique:
        when "bar-code.b-code" then do:
          r-b-code = integer(p-nonunique).
        end.
      end case.
    end.
    run value(v-form-name) (
                     input {2}
                    ,input {&lookup}
                    ,input buf_dis-rule.templ-rl-root
                    ,input buf_dis-rule.host-code
                    ,input buf_dis-rule.obj-type
                    ,input buf_dis-rule.obj-code
                    ,input buf_dis-rule.rule-num /*p-rule-num*/
                    ,input buf_dis-rule.upper-rule-num
                    ,input r-b-code
                    ,input buf_dis-rule.time-templ-rl-root
                    ,input '':U
                    ,input-output loc-doc-rec
                                ) /*no-error*/
    .
  end.

end procedure. /* dsp-dis-rule */


&endif

/* $Workfile$ e n d */