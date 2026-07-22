/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами скидок товара на объекте (bonus-qnty) вынесено из disgdsr1.p

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure cr_dis-gds-rule-attr :

def input parameter v-recid-rule-gds as int no-undo .

def buffer buf_dis-gds-rule-attr for dis-gds-rule-attr .

def buffer buf_dis-gds-rule for dis-gds-rule .
def buffer buf_bar-code for ub.bar-code .
def buffer buf_prod-bc  for prod-bc .
def buffer buf_templ-dis-rule for dis-rule .
def buffer buf_templ-dis-time-rule for dis-time-rule .
def buffer buf_dis-cfg-rule   for dis-cfg-rule .
def buffer buf_dis-rule   for dis-rule .

define variable v-upd as character no-undo .
define variable v-number-action as character no-undo .
define variable v-bar-code as character no-undo .

find buf_dis-gds-rule no-lock where recid(buf_dis-gds-rule) = v-recid-rule-gds  no-error.
if avail buf_dis-gds-rule then
do:
  find first buf_dis-rule no-lock where buf_dis-rule.rule-num = buf_dis-gds-rule.rule-num  no-error .

  find first buf_templ-dis-rule no-lock where buf_templ-dis-rule.rule-num = buf_dis-rule.templ-rl-root  no-error .
  if avail buf_templ-dis-rule and avail buf_dis-rule then
  do:
     find first buf_dis-cfg-rule no-lock where
                buf_dis-cfg-rule.table-name = "dis-gds-rule"
            and buf_dis-cfg-rule.pos-type = buf_dis-gds-rule.pos-type
            and buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
            and buf_dis-cfg-rule.time-templ-rl-root =  buf_dis-rule.time-templ-rl-root
            and buf_dis-cfg-rule.self-nonunique = ""
            and buf_dis-cfg-rule.nonunique = "bar-code.b-code"
            no-error.
     if avail buf_dis-cfg-rule then
     do:
       find first buf_bar-code no-lock where buf_bar-code.b-code = integer(buf_dis-gds-rule.nonunique) no-error.
       if avail buf_bar-code then
       do:
          run gen-bc(input buf_bar-code.b-code,output v-bar-code) .
          for each buf_prod-bc no-lock where buf_prod-bc.b-code = buf_bar-code.b-code :

            if buf_prod-bc.bc-on = yes then
            do:
               v-upd = 'A' .
            end.
            else
            do:
               v-upd = "D" .
            end.
            find first  buf_dis-gds-rule-attr WHERE
                buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
            AND buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
            AND buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
            AND buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
            AND buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
            and buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
            and entry(1,buf_dis-gds-rule-attr.attr-value,",") = buf_prod-bc.b-str
                 exclusive-lock no-error .

            if (not avail buf_dis-gds-rule-attr) and (not locked buf_dis-gds-rule-attr) then
            do:
                if v-upd = "A" then
                do:
                    run def-number-action(buf_templ-dis-rule.rule-num,output v-number-action) .
                    create buf_dis-gds-rule-attr .
                    assign
                     buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
                     buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
                     buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
                     buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
                     buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
                     buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
                     buf_dis-gds-rule-attr.attr-code = v-number-action
                     buf_dis-gds-rule-attr.attr-value = buf_prod-bc.b-str + "," + v-upd
                    .


                end.

            end.
            else
            do:
              if avail buf_dis-gds-rule-attr and  buf_dis-gds-rule-attr.attr-value <> v-upd then
              do:
               assign
                buf_dis-gds-rule-attr.attr-value = buf_prod-bc.b-str + "," + v-upd
                .

              end.
            end.

          end.  /* for each prod-bc*/
          if v-bar-code <> '' then
          do:
            find first  buf_dis-gds-rule-attr WHERE
                buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
            AND buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
            AND buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
            AND buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
            AND buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
            and buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
            and entry(1,buf_dis-gds-rule-attr.attr-value,",") = v-bar-code
                 exclusive-lock no-error .
            if not avail buf_dis-gds-rule-attr  then
            do:
                    run def-number-action(buf_templ-dis-rule.rule-num,output v-number-action) .
                    create buf_dis-gds-rule-attr .
                    assign
                     buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
                     buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
                     buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
                     buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
                     buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
                     buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
                     buf_dis-gds-rule-attr.attr-code = v-number-action
                     buf_dis-gds-rule-attr.attr-value = v-bar-code + "," + "A"
                    .

            end.

          end.
          for each  buf_dis-gds-rule-attr WHERE
                buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
            AND buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
            AND buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
            AND buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
            AND buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
            and buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
                  :
             find first buf_prod-bc no-lock where
                  buf_prod-bc.b-str = entry(1,buf_dis-gds-rule-attr.attr-value,",")
                     and can-find(first buf_bar-code where buf_bar-code.b-code = int(buf_dis-gds-rule.nonunique))
                     no-error.
             if not avail buf_prod-bc or (avail buf_prod-bc and buf_prod-bc.bc-on = no) then
             do:
               if entry(1,buf_dis-gds-rule-attr.attr-value,",") <> v-bar-code then
               do:
                 v-upd = "D" .
                 if buf_dis-gds-rule-attr.attr-value <> v-upd then
                 do:
                   assign
                   buf_dis-gds-rule-attr.attr-value = buf_prod-bc.b-str + "," + v-upd
                   .

                 end.

               end.

             end.

          end.
       end.     /* if avail bar-code     */
     end.
  end.   /*  if avail dis-rule  */
end.

end procedure .

procedure def-number-action :
  define input  parameter p-templ-rl-root as int no-undo .
  define output parameter p-number-action as char no-undo .
  define variable v-action as integer   no-undo .
  def buffer buf_dis-rule-attr for dis-rule-attr .
  find first buf_dis-rule-attr exclusive-lock where buf_dis-rule-attr.rule-num = p-templ-rl-root
                                       and buf_dis-rule-attr.attr-code =  "NCR bonus-qnty"
                                       no-error.
  if not avail buf_dis-rule-attr then
  do:
    create buf_dis-rule-attr .
    assign
       buf_dis-rule-attr.rule-num = p-templ-rl-root
       buf_dis-rule-attr.attr-code =  "NCR bonus-qnty"
       buf_dis-rule-attr.attr-value = "3100101"
       p-number-action = buf_dis-rule-attr.attr-value
       .

  end.
  else
  do:
     v-action = integer(buf_dis-rule-attr.attr-value) no-error .
     if error-status:error = no then
     do:
       assign
          v-action = v-action + 1
          buf_dis-rule-attr.attr-value = string(v-action)
          p-number-action = buf_dis-rule-attr.attr-value
          .

     end.
  end.
end procedure.

/* $Workfile$ e n d */