/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отработка поиска товаров в справочнике весовых товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* для поиска по строкам */

on value-changed of a-n-c in frame {&frame-name} do:
  case input frame {&frame-name} a-n-c :
    when "art":U then do:
      apply "entry" to br-gds in frame {&frame-name}.
      hide loc-name loc-code in frame {&frame-name}.
      loc-art = "".
    end.
    when "name":U then do:
      enable loc-name with frame {&frame-name}.
      disp loc-name with frame {&frame-name}.
      hide loc-art loc-code in frame {&frame-name}.
      apply "entry" to loc-name in frame {&frame-name}.
    end.
    when "code":U then do:
      enable loc-code with frame {&frame-name}.
      loc-code:label = "Бар-код (весь)".
      disp loc-code with frame {&frame-name}.
      hide loc-art loc-name in frame {&frame-name}.
      apply "entry" to loc-code in frame {&frame-name}.
    end.
    when "ves":U then do:
      enable loc-code with frame {&frame-name}.
      loc-code:label = "Вес. код".
      disp loc-code with frame {&frame-name}.
      hide loc-art loc-name in frame {&frame-name}.
      apply "entry" to loc-code in frame {&frame-name}.
    end.
  end.
end.

on any-printable of br-gds in frame {&frame-name} do:
  if input frame {&frame-name} a-n-c = "art":U then do:
    if last-event:label = " " and loc-art = "" then return no-apply.
    FIND FIRST l-goods NO-LOCK WHERE
               l-goods.artic begins (loc-art + last-event:label) use-index pi NO-ERROR.

    if avail l-goods then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame {&frame-name}.
      line-rec = recid (l-goods).
      reposition br-gds to recid line-rec no-error.
      {&repos-true}
    end.
    else bell.
  end.
end.

on backspace of br-gds in frame {&frame-name} do:
  if input frame {&frame-name} a-n-c = "art":U then do:
    if loc-art = "" then return no-apply.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    FIND FIRST l-goods NO-LOCK WHERE
               l-goods.artic begins loc-art use-index pi NO-ERROR.
    disp loc-art with frame {&frame-name}.
    line-rec = recid (l-goods).
    reposition br-gds to recid line-rec no-error.
    {&repos-true}
  end.
end.

ON MOUSE-SELECT-DBLCLICK, return OF loc-code IN FRAME {&frame-name} do:
def var str-code as integer no-undo.
def var r-bar-code like ub.bar-code.b-code no-undo.
define variable varresult   as character                no-undo.
define variable vartype-bc  as character                no-undo.
define variable varweight   as decimal                  no-undo.
  assign loc-code a-n-c.
  case a-n-c:
    when "code":U then do:
     { str/bc-rcnz.i
       parparentproc
       loc-code
       ?
       p-obj-type
       p-obj-code
       yes
       no
       varscales-pref
       varpgscales-pref
       varresult
       vartype-bc
       varweight
       l-bar-code
       ub.prod-bc
       ub.place
       no-error
     }
     if error-status:error then do:
       message "Ошибка при разборе бар-кода".
       return no-apply.
     end.
     if avail l-bar-code then do:
        { gbl/gdsbcode.i l-bar-code.gds-code ? r-bar-code no-error}
        if error-status:error then do:
           message "Бар-код не найден.".
          return no-apply.
        end.
        FOR EACH  l-bar-code where
                  l-bar-code.b-code = integer (r-bar-code) NO-LOCK,
            FIRST l-goods No-LOCK WHERE
                  l-goods.gds-code = l-bar-code.gds-code:
            LEAVE.
       END.
       if avail l-goods then do:
         line-rec = recid (l-goods).
         reposition br-gds to recid line-rec no-error.
         {&repos-true}
       end.
       else message "Строка не найдена.".
     end.
     else message "Бар-код не найден.". /*not avail l-bar-code*/
    end. /*when "code"*/
    when "ves":U then do:
     FIND FIRST l-prod-bc WHERE l-prod-bc.b-str = string(integer(loc-code), "99999") NO-LOCK No-ERROR.
     IF AVAIl l-prod-bc then do:
        FOR EACH  l-prod-bc WHERE
                  l-prod-bc.bc-on = TRUE AND
                  l-prod-bc.b-str = string(integer(loc-code), "99999") NO-LOCK,
            FIRST l-bar-code WHERE
                  l-bar-code.b-code = l-prod-bc.b-code NO-LOCK,
            FIRST l-goods WHERE
                  l-goods.gds-code = l-bar-code.gds-code NO-LOCK:
           LEAVE.
       END.
         if avail l-goods then do:
             line-rec = recid (l-goods).
             reposition br-gds to recid line-rec no-error.
             {&repos-true}
         end.
         else message "Строка не найдена.".
     end.
     else message "Весовой код не найден.". /*not avail l-bar-code*/
    end.  /*when*/
  end case.
  apply "entry" to loc-code in frame {&frame-name}.
  return no-apply.
end.

ON MOUSE-SELECT-DBLCLICK, return OF loc-name IN FRAME {&frame-name} do:
  assign loc-name.
  FIND FIRST l-goods WHERE
          l-goods.gds-name begins loc-name NO-LOCK No-ERROR.
  if avail l-goods then do:
    assign
    line-rec = recid (l-goods).
    reposition br-gds to recid line-rec no-error.
         {&repos-true}
  end.
  else do:
       message "Строка не найдена.".
   end.
  apply "entry" to loc-name in frame {&frame-name}.
  return no-apply.
end.


on iteration-changed of br-gds in frame {&frame-name} do:
  if not avail X_goods or recid (X_goods) <> line-rec then do:
    hide loc-art in frame {&frame-name}.
    loc-art = "".
  end.
  /*  apply "entry" to br-gds in frame {&frame-name}. - чтоб в browse с enable field focus на строчку переключался за 1 click */

/* при вызове данного include - файла здесь дб приписан END */

/* $Workfile$ e n d */
































