/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отработка поиска товаров на весах по различным кодам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* для поиска по строкам */

&if "{3}" = "scalelst" &then
  &scop where-cond l-{1}.db-num = p-db-num and l-{1}.scales-num = scalenum
&else
  &scop where-cond l-{1}.db-num = p-db-num
&endif

on value-changed of a-n-c in frame {&frame-name} do:
  case input frame {&frame-name} a-n-c :
    when "art" then do:
     if db-mode = "self" then do:
      apply "entry" to {2} in frame {&frame-name}.
     end.
     else do:
       apply "entry" to {2}-db in frame {&frame-name}.
     end.


      hide loc-name loc-code in frame {&frame-name}.
      loc-art = "".
    end.
    when "name" then do:
      enable loc-name with frame {&frame-name}.
      disp loc-name with frame {&frame-name}.
      hide loc-art loc-code in frame {&frame-name}.
      apply "entry" to loc-name in frame {&frame-name}.
    end.
    when "code" then do:
      enable loc-code with frame {&frame-name}.
      loc-code:label = "Бар-код (весь)".
      disp loc-code with frame {&frame-name}.
      hide loc-art loc-name in frame {&frame-name}.
      apply "entry" to loc-code in frame {&frame-name}.
    end.
    when "ves" then do:
      enable loc-code with frame {&frame-name}.
      loc-code:label = "Вес. код".
      disp loc-code with frame {&frame-name}.
      hide loc-art loc-name in frame {&frame-name}.
      apply "entry" to loc-code in frame {&frame-name}.
    end.
    when "PLU" then do:
      enable loc-code with frame {&frame-name}.
      loc-code:label = "PLU".
      disp loc-code with frame {&frame-name}.
      hide loc-art loc-name in frame {&frame-name}.
      apply "entry" to loc-code in frame {&frame-name}.
    end.
    when "shtrih" then do:
      enable loc-code with frame {&frame-name}.
      loc-code:label = "Штрих.код".
      disp loc-code with frame {&frame-name}.
      hide loc-art loc-name in frame {&frame-name}.
      apply "entry" to loc-code in frame {&frame-name}.
    end.
  end.
end.

on any-printable of {2} in frame {&frame-name},
                    {2}-db in frame {&frame-name}
  do:
  if input frame {&frame-name} a-n-c = "art" then do:
    if last-event:label = " " and loc-art = "" then return no-apply.
    if db-mode = "self" then do:
      FOR EACH l-scales-gds WHERE {&where-cond} NO-LOCK ,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods NO-LOCK WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.artic begins (loc-art + last-event:label),
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                                l-gds-obj-attr.attr-code = {&attr-scales-code-o} No-LOCK,
                          FIRST l-prod-bc WHERE
                                l-prod-bc.b-str = l-gds-obj-attr.attr-value NO-LOCK
                        BY l-scales-gds.db-num
                        BY l-scales-gds.scales-num
                        BY l-scales-gds.plu-code:
                        LEAVE.
      END.
    end. /*if db-mode = "self" then do:*/
    else do:
      FOR EACH l-scales-gds WHERE {&where-cond} NO-LOCK ,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods NO-LOCK WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.artic begins (loc-art + last-event:label),
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
            l-gds-obj-attr.attr-code = {&attr-scales-code-o} No-LOCK
                        BY l-scales-gds.db-num
                        BY l-scales-gds.scales-num
                        BY l-scales-gds.plu-code:
          find  FIRST l-prod-bc-db no-lock WHERE
                l-prod-bc-db.b-str = l-gds-obj-attr.attr-value
            and l-prod-bc-db.db-num = l-scales-gds.db-num no-error.
        if not available l-prod-bc-db then do:
          find first l-prod-bc no-lock where
                    l-prod-bc.b-code = l-bar-code.b-code
                and l-prod-bc.b-str = l-gds-obj-attr.attr-value no-error.
          if not available l-prod-bc then next.
        end.
                        LEAVE.
      END.
    end.
    if avail l-{1} then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame {&frame-name}.
      line-rec = recid (l-{1}).
      if db-mode = "self" then do:
      reposition {2} to recid line-rec no-error.
      end.
      else do:
        reposition {2}-db to recid line-rec no-error.
      end.
      {&repos-true}
    end.
    else do:
      bell.
    end.
  end.
end.

on backspace of {2} in frame {&frame-name},
                {2}-db in frame {&frame-name}
do:
  if input frame {&frame-name} a-n-c = "art" then do:
    if loc-art = "" then return no-apply.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    if db-mode = "self" then do:
      FOR EACH l-scales-gds WHERE {&where-cond} NO-LOCK,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.artic begins loc-art NO-LOCK,
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                                l-gds-obj-attr.attr-code = {&attr-scales-code-o} No-LOCK,
                          FIRST l-prod-bc WHERE
                                l-prod-bc.b-str = l-gds-obj-attr.attr-value NO-LOCK
                        BY l-scales-gds.db-num
                        BY l-scales-gds.scales-num
                        BY l-scales-gds.plu-code:
                        LEAVE.
      END.
    end. /*if db-mode = "self" then do:*/
    else do:
      FOR EACH l-scales-gds WHERE {&where-cond} NO-LOCK,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.artic begins loc-art NO-LOCK,
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                                l-gds-obj-attr.attr-code = {&attr-scales-code-o} No-LOCK
                        BY l-scales-gds.db-num
                        BY l-scales-gds.scales-num
                        BY l-scales-gds.plu-code:
        find  FIRST l-prod-bc-db no-lock WHERE
              l-prod-bc-db.b-str = l-gds-obj-attr.attr-value
          and l-prod-bc-db.db-num = l-scales-gds.db-num no-error.
        if not available l-prod-bc-db then do:
          find first l-prod-bc no-lock where
                    l-prod-bc.b-code = l-bar-code.b-code
                and l-prod-bc.b-str = l-gds-obj-attr.attr-value no-error.
          if not available l-prod-bc then next.
        end.
                        LEAVE.
      END.
    end.
    display
    loc-art with frame {&frame-name}.
    line-rec = recid (l-{1}).
    if db-mode = "self" then do:
    reposition {2} to recid line-rec no-error.
    end.
    else do:
      reposition {2}-db to recid line-rec no-error.
    end.
    {&repos-true}
  end.
end.

ON MOUSE-SELECT-DBLCLICK, return OF loc-code IN FRAME {&frame-name} do:
define variable str-code    as integer           no-undo.
define variable r-bar-code  like ub.bar-code.b-code no-undo.
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
  assign loc-code a-n-c.
  case a-n-c:
    when "code" or when "shtrih"  then do:
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
     IF AVAIl l-bar-code then do:
        { gbl/gdsbcode.i l-bar-code.gds-code ? r-bar-code no-error}
        if error-status:error then do:
           message "Бар-код не найден.".
          return no-apply.
        end.
        if db-mode = "self" then do:
          FOR EACH l-scales-gds WHERE {&where-cond} NO-LOCK,
              FIRST l-bar-code WHERE
                    l-bar-code.b-code = l-scales-gds.b-code AND
                    l-bar-code.b-code = integer (r-bar-code) NO-LOCK,
              FIRST l-gds-obj-attr WHERE
                    l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                    l-gds-obj-attr.attr-code = {&attr-scales-code-o} No-LOCK,
              FIRST l-prod-bc WHERE
                    l-prod-bc.b-str = l-gds-obj-attr.attr-value NO-LOCK
              BY l-scales-gds.db-num
              BY l-scales-gds.scales-num
              BY l-scales-gds.plu-code:
              LEAVE.
         END.
       end. /*if db-mode = "self" then do:*/
       else do:
          FOR EACH l-scales-gds WHERE {&where-cond} NO-LOCK,
              FIRST l-bar-code WHERE
                    l-bar-code.b-code = l-scales-gds.b-code AND
                    l-bar-code.b-code = integer (r-bar-code) NO-LOCK,
              FIRST l-gds-obj-attr WHERE
                    l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                    l-gds-obj-attr.attr-code = {&attr-scales-code-o} No-LOCK
              BY l-scales-gds.db-num
              BY l-scales-gds.scales-num
              BY l-scales-gds.plu-code:
          find  FIRST l-prod-bc-db no-lock WHERE
                l-prod-bc-db.b-str = l-gds-obj-attr.attr-value
            and l-prod-bc-db.db-num = l-scales-gds.db-num no-error.
          if not available l-prod-bc-db then do:
            find first l-prod-bc no-lock where
                      l-prod-bc.b-code = l-bar-code.b-code
                  and l-prod-bc.b-str = l-gds-obj-attr.attr-value no-error.
            if not available l-prod-bc then next.
          end.
              LEAVE.
         END.
       end.
       if avail l-{1} then do:
         line-rec = recid (l-{1}).
         if db-mode = "self" then do:
         reposition {2} to recid line-rec no-error.
         end.
         else do:
           reposition {2}-db to recid line-rec no-error.
         end.
         {&repos-true}
        end.
        else do:
          message "Строка не найдена.".
        end.
      end. /*IF AVAIl l-bar-code then do:*/
      else DO:
         message "Бар-код не найден.". /*not avail l-bar-code*/
      end.
    end. /*when "code"*/
    when "ves" then do:
      if db-mode = "self" then do:
        FIND FIRST l-prod-bc WHERE l-prod-bc.b-str = string(integer(loc-code), "99999") NO-LOCK No-ERROR.
        IF AVAIl l-prod-bc then do:
            FOR EACH l-scales-gds WHERE {&where-cond} NO-LOCK,
                            FIRST l-prod-bc WHERE
                                  l-prod-bc.b-code = l-scales-gds.b-code AND
                                  l-prod-bc.bc-on = TRUE AND
                                  l-prod-bc.b-str = string(integer(loc-code), "99999") NO-LOCK,
                            FIRST l-bar-code WHERE
                                  l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                            FIRST l-goods WHERE
                                  l-goods.gds-code = l-bar-code.gds-code NO-LOCK
                          BY l-scales-gds.db-num
                          BY l-scales-gds.scales-num
                          BY l-scales-gds.plu-code:
                LEAVE.
        END.
        if avail l-{1} then do:
            line-rec = recid (l-{1}).
            if db-mode = "self" then do:
            reposition {2} to recid line-rec no-error.
            end.
            else do:
              reposition {2}-db to recid line-rec no-error.
            end.
            {&repos-true}
          end.
          else message "Строка не найдена.".
        end.
        else do:
          message "Весовой код не найден.". /*not avail l-bar-code*/
        end.
      end. /*      if db-mode = "self" then do:*/
      else do:
        FIND FIRST l-prod-bc-db WHERE
               l-prod-bc-db.b-str = string(integer(loc-code), "99999")
           and l-prod-bc-db.db-num = p-db-num  NO-LOCK No-ERROR.
        IF AVAIl l-prod-bc-db then do:
            FOR EACH l-scales-gds WHERE {&where-cond} NO-LOCK,
                            FIRST l-prod-bc-db WHERE
                                  l-prod-bc-db.b-code = l-scales-gds.b-code AND
                                  l-prod-bc-db.bc-on = TRUE AND
                                  l-prod-bc-db.b-str = string(integer(loc-code), "99999")
                                  and l-prod-bc-db.db-num = l-scales-gds.db-num
                                  NO-LOCK,
                            FIRST l-bar-code WHERE
                                  l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                            FIRST l-goods WHERE
                                  l-goods.gds-code = l-bar-code.gds-code NO-LOCK
                          BY l-scales-gds.db-num
                          BY l-scales-gds.scales-num
                          BY l-scales-gds.plu-code:
                LEAVE.
          END.
          if avail l-{1} then do:
              line-rec = recid (l-{1}).
              if db-mode = "self" then do:
              reposition {2} to recid line-rec no-error.
              end.
              else do:
                reposition {2}-db to recid line-rec no-error.
              end.
              {&repos-true}
          end.
          else do:
            message "Строка не найдена.".
          end.
        end. /*IF AVAIl l-prod-bc-db then do:*/
        else do:
          find first l-prod-bc where
               l-prod-bc.b-str = string(integer(loc-code), "99999")  NO-LOCK No-ERROR.
          if available l-prod-bc then do:
            FOR EACH l-scales-gds WHERE {&where-cond} NO-LOCK,
            FIRST l-prod-bc WHERE
                  l-prod-bc.b-code = l-scales-gds.b-code AND
                  l-prod-bc.bc-on = TRUE AND
                  l-prod-bc.b-str = string(integer(loc-code), "99999")
                  NO-LOCK,
            FIRST l-bar-code WHERE
                  l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
            FIRST l-goods WHERE
                  l-goods.gds-code = l-bar-code.gds-code NO-LOCK
            BY l-scales-gds.db-num
            BY l-scales-gds.scales-num
            BY l-scales-gds.plu-code:
              LEAVE.
            END.
            if avail l-{1} then do:
                line-rec = recid (l-{1}).
                if db-mode = "self" then do:
                reposition {2} to recid line-rec no-error.
                end.
                else do:
                  reposition {2}-db to recid line-rec no-error.
                end.
                {&repos-true}
            end.
          end.
          else do:
            message "Весовой код не найден.". /*not avail l-bar-code*/
        end.
        end.
      end. /*else if db-mode = "self"*/
    end.  /*when*/
    when "PLU" then do:
      FIND FIRST l-scales-gds WHERE
               {&where-cond}
           AND l-scales-gds.plu-code = integer(loc-code) NO-LOCK No-ERROR.
     IF AVAIl l-scales-gds then do:
        line-rec = recid (l-{1}).
        if db-mode = "self" then do:
        reposition {2} to recid line-rec no-error.
        end.
        else do:
          reposition {2}-db to recid line-rec no-error.
        end.
        {&repos-true}
     end.
     else message "PLU не найден.". /*not avail l-bar-code*/
    end.
  end case.
  apply "entry" to loc-code in frame {&frame-name}.
  return no-apply.
end.

ON MOUSE-SELECT-DBLCLICK, return, Ctrl-J OF loc-name IN FRAME {&frame-name} do:
  assign loc-name.
  if last-event:label = "Ctrl-J" then do:
&if "{&where-cond}" = "scalelst" &then
 if db-mode = "self" then do:
    FOR EACH l-scales-gds WHERE {&where-cond} AND
                                (l-scales-gds.plu >= current-plu)
                                                     NO-LOCK,
                        FIRST l-bar-code WHERE
                              l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                        FIRST l-goods WHERE
                              l-goods.gds-code = l-bar-code.gds-code AND
                              l-goods.gds-name begins loc-name  NO-LOCK,
                        FIRST l-gds-obj-attr WHERE
                              l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                              l-gds-obj-attr.attr-code = {&attr-scales-code-o} No-LOCK,
                        FIRST l-prod-bc WHERE
                              l-prod-bc.b-str = l-gds-obj-attr.attr-value NO-LOCK
                       BY l-scales-gds.db-num
                       BY l-scales-gds.scales-num
                       BY l-scales-gds.plu-code:

                       LEAVE.
    END.
 end.
 else do:
    FOR EACH l-scales-gds WHERE {&where-cond} AND
                                (l-scales-gds.plu >= current-plu)
                                                     NO-LOCK,
                        FIRST l-bar-code WHERE
                              l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                        FIRST l-goods WHERE
                              l-goods.gds-code = l-bar-code.gds-code AND
                              l-goods.gds-name begins loc-name  NO-LOCK,
                        FIRST l-gds-obj-attr WHERE
                              l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
          l-gds-obj-attr.attr-code = {&attr-scales-code-o} No-LOCK
                       BY l-scales-gds.db-num
                       BY l-scales-gds.scales-num
                       BY l-scales-gds.plu-code:
      find FIRST l-prod-bc-db no-lock WHERE
                l-prod-bc-db.b-str = l-gds-obj-attr.attr-value
            and l-prod-bc-db.db-num = l-scales-gds.db-num no-error.
      if not available l-prod-bc-db then do:
        find first l-prod-bc no-lock where
                  l-prod-bc.b-code = l-bar-code.b-code
              and l-prod-bc.b-str = l-gds-obj-attr.attr-value no-error.
        if not available l-prod-bc then next.
      end.
      LEAVE.
    END.
 end.
&else
   if db-mode = "self" then do:
      FOR EACH l-scales-gds WHERE
              ((l-scales-gds.db-num = current-db-num AND  l-scales-gds.scales-num = current-scales AND l-scales-gds.b-code > current-b-code ) OR
                l-scales-gds.scales-num > current-scales)
                                                      NO-LOCK,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.gds-name begins loc-name NO-LOCK,
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                                l-gds-obj-attr.attr-code = {&attr-scales-code-o} No-LOCK,
                          FIRST l-prod-bc WHERE
                                l-prod-bc.b-str = l-gds-obj-attr.attr-value NO-LOCK
                        BY l-scales-gds.db-num
                        BY l-scales-gds.scales-num
                        BY l-scales-gds.plu-code:
                        LEAVE.
      END.
   end.
   else do:
      FOR EACH l-scales-gds WHERE
              ((l-scales-gds.db-num = current-db-num AND  l-scales-gds.scales-num = current-scales AND l-scales-gds.b-code > current-b-code ) OR
                l-scales-gds.scales-num > current-scales) NO-LOCK,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.gds-name begins loc-name NO-LOCK,
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
            l-gds-obj-attr.attr-code = {&attr-scales-code-o} No-LOCK
      BY l-scales-gds.db-num
      BY l-scales-gds.scales-num
      BY l-scales-gds.plu-code:

       find FIRST l-prod-bc-db no-lock WHERE
            l-prod-bc-db.b-str = l-gds-obj-attr.attr-value
        and l-prod-bc-db.db-num = l-scales-gds.db-num no-error.
        if not available l-prod-bc-db then do:
          find first l-prod-bc no-lock where
                    l-prod-bc.b-code = l-bar-code.b-code
                and l-prod-bc.b-str = l-gds-obj-attr.attr-value no-error.
          if not available l-prod-bc then next.
        end.
        LEAVE.
      END.
   end.
&endif
  end.
  else do:
    if db-mode = "self" then do:
      FOR EACH l-scales-gds WHERE {&where-cond} NO-LOCK,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.gds-name begins loc-name NO-LOCK,
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
                                l-gds-obj-attr.attr-code = {&attr-scales-code-o} No-LOCK,
                          FIRST l-prod-bc WHERE
                                l-prod-bc.b-str = l-gds-obj-attr.attr-value NO-LOCK
                        BY l-scales-gds.db-num
                        BY l-scales-gds.scales-num
                        BY l-scales-gds.plu-code:
                        LEAVE.
      END.
    end.
    else do:
      FOR EACH l-scales-gds WHERE {&where-cond} NO-LOCK,
                          FIRST l-bar-code WHERE
                                l-bar-code.b-code = l-scales-gds.b-code NO-LOCK,
                          FIRST l-goods WHERE
                                l-goods.gds-code = l-bar-code.gds-code AND
                                l-goods.gds-name begins loc-name NO-LOCK,
                          FIRST l-gds-obj-attr WHERE
                                l-gds-obj-attr.gds-code = l-bar-code.gds-code AND
            l-gds-obj-attr.attr-code = {&attr-scales-code-o} No-LOCK
                        BY l-scales-gds.db-num
                        BY l-scales-gds.scales-num
                        BY l-scales-gds.plu-code:
        find FIRST l-prod-bc-db no-lock WHERE
            l-prod-bc-db.b-str = l-gds-obj-attr.attr-value
        and l-prod-bc-db.db-num = l-scales-gds.db-num no-error.
        if not available l-prod-bc-db then do:
          find first l-prod-bc no-lock where
                    l-prod-bc.b-code = l-bar-code.b-code
                and l-prod-bc.b-str = l-gds-obj-attr.attr-value no-error.
          if not available l-prod-bc then next.
        end.
                        LEAVE.
      END.
    end.
  end.
  if avail l-{1} then do:
    assign
    current-db-num = l-{1}.db-num
    current-plu = l-{1}.plu-code
    current-scales = l-{1}.scales-num
    current-b-code =l-{1}.b-code
    line-rec = recid (l-{1}).
    if db-mode = "self" then do:
    reposition {2} to recid line-rec no-error.
    end.
    else do:
      reposition {2}-db to recid line-rec no-error.
    end.
         {&repos-true}
  end.
  else do:
       message "Строка не найдена.".
   end.
  apply "entry" to loc-name in frame {&frame-name}.
  return no-apply.
end.


on iteration-changed of {2} in frame {&frame-name},
                        {2}-db in frame {&frame-name}
do:
  if not avail {5} or recid ({5}) <> line-rec then do:
    hide loc-art in frame {&frame-name}.
    loc-art = "".
  end.
  /*  apply "entry" to {2} in frame {&frame-name}. - чтоб в browse с enable field focus на строчку переключался за 1 click */

/* при вызове данного include - файла здесь дб приписан END */

/* $Workfile$ e n d */