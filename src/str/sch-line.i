/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

триггеры для поиска строки в документе, справочнике

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/05/05
Author: Bakhtadze Natalya
Creation date: 11/05/05


1 - буфер главной таблицы query
2 - имя query (browse)
3 - необязательный - имя переменной recid для поиска (для reposition)
4 - необязательный - where-condition

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable varscales-pref{&vssseq} as character no-undo .
define variable varpgscales-pref{&vssseq} as character no-undo.

{ str/sclspref.i varscales-pref{&vssseq} varpgscales-pref{&vssseq} }

/* не требуется никакой доп. обработки - начальное значение */
&scop repos-true

&if "{1}" = "price-list" &then
  &scop where-cond l-{1}.doc-num = p-doc.doc-num and
&elseif "{1}" = "doc-line" or "{1}" = "gds-dtl" &then
  &scop where-cond l-{1}.doc-code = t-doc.doc-code and
&elseif "{1}" = "gds-list" or "{1}" = "scn-list" or "{1}" = "bb-list" or "{1}" = "scnblist" &then
  /* нужно в списках товаров */
  &scop repos-true apply "value-changed" to {2} in frame {&frame-name}.
&elseif "{1}" = "goo-doc" or "{1}" = "gob-doc" &then

&scop repos-true if error-status:error then do: ~
    run ref/gdsrepos.p (input 1, ~
                   input g-cond, ~
                   input g-list, ~
                   input g-stat, ~
                   input flt-rec, ~
                   output g#log, ~
                   output contin). ~
    if g#log then do: ~
      run full-sch. ~
      return error. ~
    end. ~
  end. ~
  apply "VALUE-changed" to br-gds in frame {&frame-name}.

&scop repos-true-contin if error-status:error then do: ~
    run ref/gdsrepos.p (input 2, ~
                   input g-cond, ~
                   input g-list, ~
                   input g-stat, ~
                   input flt-rec, ~
                   output g#log, ~
                   output contin). ~
    if not contin then do: ~
      run full-sch. ~
      return error. ~
    end.   ~
  end. ~
  apply "VALUE-changed" to br-gds in frame {&frame-name}.
&endif

&if "{3}" = "" &then
  &scop sch-rec line-rec
&else
  &scop sch-rec {3}
&endif

&if "{4}" <> "" &then
  &scop where-cond {4}
&endif

on value-changed of a-n-c in frame {&frame-name} do:
  run proc-valchg-a-n-c in this-procedure  no-error.
  return no-apply.
end.

on any-printable of {2} in frame {&frame-name} do:
  run proc-any-printable-{2} in this-procedure   no-error.
  return no-apply.
end.

on backspace of {2} in frame {&frame-name} do:
  run proc-backspace-{2} in this-procedure   no-error.
  return no-apply.
end.

ON return OF loc-code IN FRAME {&frame-name} do:
  run proc-mouse-dbl-click-loc-code in this-procedure   no-error.
  return no-apply.
end.

&if "{1}" = "bb-list" or "{1}" = "scnblist" &then
ON return, Ctrl-J OF loc-b-str IN FRAME {&frame-name} do:
  run proc-mouse-dbl-click-loc-b-str in this-procedure   no-error.
  return no-apply.
end.
&endif

ON return, Ctrl-J OF loc-name IN FRAME {&frame-name} do:
  run proc-mouse-dbl-click-loc-name in this-procedure   no-error.
  return no-apply.
end.

&if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
ON return OF NameContext IN FRAME {&frame-name} do:
  run proc-mouse-dbl-click-namec in this-procedure   no-error.
  return no-apply.
end.
&endif

PROCEDURE proc-valchg-a-n-c:
  case input frame {&frame-name} a-n-c :
    when "art" then do:
      apply "entry" to {2} in frame {&frame-name}.
      hide loc-name loc-code
&if "{1}" = "bb-list"  or "{1}" = "scnblist"  &then
     loc-b-str
&endif
      in frame {&frame-name}.
      loc-art = "".
      &if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
        NameContext = "" .
        hide NameContext in frame {&frame-name}.
        if a-n-c <> a-n-c:screen-value then do:
          assign a-n-c.
          RUN openbr in this-procedure ( input no, input yes ,input no, input '').
        end.
      &endif
    end. /*when art*/
    when "name" then do:
      enable loc-name with frame {&frame-name}.
      disp loc-name with frame {&frame-name}.
      hide loc-art loc-code
&if "{1}" = "bb-list"  or "{1}" = "scnblist"  &then
     loc-b-str
&endif
      in frame {&frame-name}.
      &if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
      NameContext = "" .
      hide NameContext in frame {&frame-name}.
      if a-n-c <> a-n-c:screen-value then do:
        assign a-n-c.
        RUN openbr in this-procedure ( input no, input yes ,input no, input '').
      end.
      &endif
      apply "entry" to loc-name in frame {&frame-name}.
    end. /*when name*/
    when "code"  
 or when "DataMatrix" then
    do:
      enable loc-code with frame {&frame-name}.
      disp loc-code with frame {&frame-name}.
      hide loc-art loc-name
&if "{1}" = "bb-list"  or "{1}" = "scnblist"  &then
     loc-b-str
&endif
      in frame {&frame-name}.
      &if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
      NameContext = "" .
      hide NameContext in frame {&frame-name}.
      if a-n-c <> a-n-c:screen-value then do:
        assign a-n-c.
        RUN openbr in this-procedure ( input no, input yes ,input no, input '').
      end.
      &endif
      apply "entry" to loc-code in frame {&frame-name}.
    end. /*when code*/
    &if "{1}" = "bb-list"  or "{1}" = "scnblist" &then
    when "b-str" then do:
      enable loc-b-str with frame {&frame-name}.
      disp loc-b-str with frame {&frame-name}.
      hide loc-art loc-name loc-code in frame {&frame-name}.
      apply "entry" to loc-b-str in frame {&frame-name}.
    end.
    &endif
    &if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
    when "context" then do:
      assign a-n-c .
      enable NameContext with frame {&frame-name}.
      disp NameContext with frame {&frame-name}.
      apply "entry" to NameContext in frame {&frame-name}.
      HIDE loc-art loc-name loc-code in frame {&frame-name}.
    end . /*when*/
    &endif
  end CASE.
END PROCEDURE.

PROCEDURE proc-any-printable-{2} :
  if input frame {&frame-name} a-n-c = "art" then do:
    if last-event:label = " " and
       loc-art = "" then
    return error.
    &if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
    { ref/gds-sch.i {1} art+ }
    &else
    find first l-{1} where
               {&where-cond} l-{1}.artic begins (loc-art + last-event:label)
               no-lock no-error.
    &endif
    if available l-{1} then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame {&frame-name}.
      {&sch-rec} = recid (l-{1}).
      reposition {2} to recid {&sch-rec} no-error.
      {&repos-true}
    end.
  end.
END PROCEDURE.

PROCEDURE proc-backspace-{2}:
  if input frame {&frame-name} a-n-c = "art" then do:
    if loc-art = "" then
      return error.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    &if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
    { ref/gds-sch.i {1} art- }
    &else
    find first l-{1} where
               {&where-cond} l-{1}.artic begins loc-art
               no-lock.
    &endif
    disp loc-art with frame {&frame-name}.
    {&sch-rec} = recid (l-{1}).
    reposition {2} to recid {&sch-rec} no-error.
    {&repos-true}
  end.
END PROCEDURE.


PROCEDURE proc-mouse-dbl-click-loc-code:
def var str-code as integer no-undo.
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define buffer l-goods for ub.goods.
define buffer l-bar-code for ub.bar-code.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.
&if "{1}" = "bb-list" or "{1}" = "scnblist" &then
  if
  frame {&frame-name}
  loc-code <> loc-code:screen-value OR
     last-event:label = "Ctrl-J" then
    contin = no.
&endif


  assign
  frame {&frame-name}
  loc-code
  a-n-c.
&if "{1}" = "gob-doc" or "{1}" = "goo-doc" or "{5}" = "sale" &then
  if a-n-c = "datamatrix"
  then do:
     { str/dm-rcnz.i
       parparentproc
       loc-code
       ?
       p-obj-type
       p-obj-code
       yes
       no
       varscales-pref{&vssseq}
       varpgscales-pref{&vssseq}
       varresult
       vartype-bc
       varweight
       buf_bar-code
       buf_prod-bc
       buf_place
       no-error
     }
     if varresult eq "prod-bc"
     then
        loc-code:screen-value in frame {&frame-name} = buf_prod-bc.b-str.
  end.
  else do:
     { str/bc-rcnz.i
       parparentproc
       loc-code
       ?
       p-obj-type
       p-obj-code
       yes
       no
       varscales-pref{&vssseq}
       varpgscales-pref{&vssseq}
       varresult
       vartype-bc
       varweight
       buf_bar-code
       buf_prod-bc
       buf_place
       no-error
     }
  end.
  
&elseif "{1}" = "bb-list"  or "{1}" = "scnblist"  &then
    find first l-bar-code no-lock where
          l-bar-code.b-code = integer(loc-code) no-error.
&else
&if defined(store-type) = 0 &then
&global-define store-type store-type
&endif
&if defined(store-code) = 0 &then
&global-define store-code store-code
&endif
  if a-n-c = "datamatrix"
  then do:
     { str/dm-rcnz.i
       parparentproc
       loc-code
       ?
       {&store-type}
       {&store-code}
       yes
       no
       varscales-pref{&vssseq}
       varpgscales-pref{&vssseq}
       varresult
       vartype-bc
       varweight
       buf_bar-code
       buf_prod-bc
       buf_place
       no-error
     }
     if varresult eq "prod-bc"
     then
        loc-code:screen-value in frame {&frame-name} = buf_prod-bc.b-str.
  end.
  else do:
     { str/bc-rcnz.i
       parparentproc
       loc-code
       ?
       {&store-type}
       {&store-code}
       yes
       no
       varscales-pref{&vssseq}
       varpgscales-pref{&vssseq}
       varresult
       vartype-bc
       varweight
       buf_bar-code
       buf_prod-bc
       buf_place
       no-error
  }
end.
&endif
  &if "{1}" = "bb-list"  or "{1}" = "scnblist"  &then
  if available l-bar-code then do:
  &else
  if available buf_bar-code then do:
  &endif
    &if "{1}" = "gob-doc" &then
    /* это не всегда точное условие поиска, но хотя бы по тому же объекту ... */
    find first l-gob-doc where
               l-gob-doc.gds-code = buf_bar-code.gds-code AND
               l-gob-doc.obj-type = p-obj-type AND
               l-gob-doc.obj-code = p-obj-code no-lock no-error.
    if not available l-gob-doc then
    find first l-{1} where
               {&where-cond} buf_bar-code.gds-code = l-{1}.gds-code
               no-lock no-error.
    &else
      &if "{1}" = "bb-list"  or "{1}" = "scnblist" &then

      if last-event:label = "Ctrl-J" then
        find next l-{1} where
                {&where-cond} l-{1}.gds-code = l-bar-code.gds-code
                          and l-{1}.b-code   = l-bar-code.b-code
                no-lock no-error.
      else
        find first l-{1} where
                {&where-cond} l-{1}.gds-code = l-bar-code.gds-code
                          and l-{1}.b-code   = l-bar-code.b-code
                no-lock no-error.
      &else

        find first l-goods where
                  l-goods.gds-code =
  &if "{1}" = "bb-list"  or "{1}" = "scnblist"  &then
  l-bar-code.gds-code No-LOCK.
  &else
  buf_bar-code.gds-code No-LOCK.
  &endif

        find first l-{1} where {&where-cond}
                  l-{1}.artic = l-goods.artic AND
                  l-{1}.prod-type = l-goods.prod-type AND
                  l-{1}.prod-code = l-goods.prod-code no-lock no-error.
      &endif
    &endif
    if available l-{1} then do:
      {&sch-rec} = recid (l-{1}).
      reposition {2} to recid {&sch-rec} no-error.
      {&repos-true}
      &if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
      if b-mark:sensitive then apply "choose" to b-mark in frame {&frame-name}.
      &endif
    end.
    else do:
     &if "{1}" = "bb-list"  or "{1}" = "scnblist" &then

     &endif
      message "Строка не найдена."
              view-as alert-box error.
    end.
  end. /*avail buf_bar-code*/
  else
    message "Бар-код не найден."
            view-as alert-box error.
  &if "{1}" = "bb-list"  or "{1}" = "scnblist" &then
  &endif
  apply "entry" to loc-code in frame {&frame-name}.
END PROCEDURE.


&if "{1}" = "bb-list"  or "{1}" = "scnblist"  &then
PROCEDURE proc-mouse-dbl-click-loc-b-str:
def var str-code as integer no-undo.
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define buffer l-prod-bc for ub.prod-bc.
define buffer l-bar-code for ub.bar-code.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.

  assign
  frame {&frame-name}
  loc-b-str.
  { str/bc-rcnz.i
    parparentproc
    loc-b-str
    ?
    p-curr-obj-type
    p-curr-obj-code
    yes
    no
    varscales-pref{&vssseq}
    varpgscales-pref{&vssseq}
    varresult
    vartype-bc
    varweight
    buf_bar-code
    buf_prod-bc
    buf_place
    no-error
  }
  if available buf_prod-bc then do:
    find first l-prod-bc where
                l-prod-bc.b-str = buf_prod-bc.b-str
            AND l-prod-bc.b-code = buf_bar-code.b-code No-LOCK.
    find first l-{1} where {&where-cond}
                l-{1}.gds-code = buf_bar-code.gds-code AND
                l-{1}.b-code = buf_bar-code.b-code AND
                l-{1}.b-str = buf_prod-bc.b-str no-lock no-error.

    if available l-{1} then do:
      {&sch-rec} = recid (l-{1}).
      reposition {2} to recid {&sch-rec} no-error.
      {&repos-true}
    end.
    else
      message "Строка не найдена."
              view-as alert-box error.
  end. /*avail buf_bar-code*/
  else do:
    if available buf_bar-code then do:
      find first l-bar-code where
                  l-bar-code.b-code = buf_bar-code.b-code No-LOCK.
      find first l-{1} where {&where-cond}
                  l-{1}.gds-code = buf_bar-code.gds-code AND
                  l-{1}.b-code = buf_bar-code.b-code AND
                  l-{1}.b-str = loc-b-str no-lock no-error.
      if available l-{1} then do:
        {&sch-rec} = recid (l-{1}).
        reposition {2} to recid {&sch-rec} no-error.
        {&repos-true}
      end.
      else
        message "Строка не найдена."
                view-as alert-box error.
    end.
    else
      message "ДопБК не найден."
              view-as alert-box error.

  end.
  apply "entry" to loc-b-str in frame {&frame-name}.
END PROCEDURE.
&endif


PROCEDURE  proc-mouse-dbl-click-loc-name:
&if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
  if
  frame {&frame-name}
  loc-name <> loc-name:screen-value OR
     last-event:label = "Ctrl-J" then
    contin = no.
&endif
  assign
  frame {&frame-name}
  loc-name.
  &if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
  REPEAT :
    { ref/gds-sch.i {1} name }
  &else
    if last-event:label = "Ctrl-J" then
      find next l-{1} where {&where-cond}
                can-find (ub.goods where ub.goods.artic = l-{1}.artic and
                ub.goods.prod-type = l-{1}.prod-type and
                ub.goods.prod-code = l-{1}.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    else
      find first l-{1} where {&where-cond}
                can-find (ub.goods where ub.goods.artic = l-{1}.artic and
                ub.goods.prod-type = l-{1}.prod-type and
                ub.goods.prod-code = l-{1}.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    &endif
    if available l-{1} then do:
      {&sch-rec} = recid (l-{1}).
      reposition {2} to recid {&sch-rec} no-error.
     &if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
         {&repos-true-contin}
      &else
         {&repos-true}
     &endif
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
      &if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
      contin = no.
      &endif
    end.
    &if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
    if not contin then
      leave.
    if contin = ? then
      return error.
  end. /* repeat */
  &endif
  apply "entry" to loc-name in frame {&frame-name}.
END PROCEDURE.

&if "{1}" = "goo-doc" or "{1}" = "gob-doc" &then
PROCEDURE proc-mouse-dbl-click-namec:
  assign
  frame {&frame-name}
  NameContext .
  NameContext = prep-nameorcode (NameContext).
  if NameContext = "" then  return error .
  display
  trim(namecontext, "*") @ namecontext
  with frame {&frame-name} .
  run openbr in this-procedure ( input no, input yes ,input no, input '').

  apply "entry" to NameContext in frame {&frame-name}.
END PROCEDURE.
&endif

on value-changed of {2} in frame {&frame-name} do:
  &if "{1}" = "price-list"
  or  "{1}" = "doc-line"
  or  "{1}" = "gds-dtl"
&then
if not available ub.{1} or recid (ub.{1}) <> {&sch-rec} then do:
&else
if not available {1} or recid ({1}) <> {&sch-rec} then do:
&endif

    hide loc-art in frame {&frame-name}.
    loc-art = "".
end.

&if "{5}" = "out-doc" &then
if available ub.goods
then do :
  define variable  p-type     as character no-undo .
  
  define variable v-isweighed as logical no-undo .
  define variable vRightChngQntyCode as character no-undo .
  define variable vIsExemplarGoods as logical no-undo .
  define variable vRightChngQnty as logical no-undo .
  
  define buffer buf_marking-lines for ub.marking-lines.
  
  run lineattr-value (
    input   t-doc.doc-code ,
    input   ub.goods.gds-code ,
    input   {&lineattr-flora_ps},
    output  flora-ps ,
    output  p-type      )
  .
  
  display flora-ps with frame {&frame-name} .
  
  if t-doc.ext-doc-type = {&TDEDT_Ras_Perem} or 
     t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} then
  do:
      run isExemplarGoods in this-procedure 
        (t-doc.obj-type, t-doc.obj-code, ub.goods.gds-code, output vIsExemplarGoods).
      v-isweighed = WghProdVariable(t-doc.obj-type, t-doc.obj-code, ub.goods.gds-code).
      if vIsExemplarGoods
      or v-isweighed 
      then do:
        if t-doc.ext-doc-type = {&TDEDT_Ras_Perem} and 
           can-find(first buf_marking-lines no-lock where 
                            buf_marking-lines.out-code = ub.gds-dtl.doc-code
                        and buf_marking-lines.gds-code = ub.goods.gds-code) then
        do:  /* для ПЕРЕМЕЩЕНИЯ РАСХОД проверим есть ли марки по товару, и если есть, то кол-во редактировать нельзя */
          vRightChngQnty = false.  
        end.
        else
        do:
            vRightChngQntyCode = if t-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} 
                then 'actn_write-off_add-no-mark':U
                else 'actn_tdedt-ras-perem_add-no-mark':U.
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              vRightChngQntyCode
              {&cntxt-object}
              t-doc.host-code
              t-doc.obj-type
              t-doc.obj-code
              0
              0
              0
              false
              vRightChngQnty
            }
        end.
        if not vRightChngQnty then
        assign
          ub.gds-dtl.doc-qnty:read-only  in browse {&browse-name} = yes
          ub.gds-dtl.fact-qnty:read-only  in browse {&browse-name} = yes
        .
        else
        assign
          ub.gds-dtl.doc-qnty:read-only  in browse {&browse-name} = no
          ub.gds-dtl.fact-qnty:read-only  in browse {&browse-name} = no
        .
        
      end.
      else do :
        assign
          ub.gds-dtl.doc-qnty:read-only  in browse {&browse-name} = no
          ub.gds-dtl.fact-qnty:read-only  in browse {&browse-name} = no
        .
      end .
      case t-doc.status_ :
        when {&wayb} then do:
           if t-doc.flag_ then assign ub.gds-dtl.doc-qnty:read-only  in browse {&browse-name} = yes.
           assign ub.gds-dtl.fact-qnty:read-only  in browse {&browse-name} = yes.
        end.
        when {&permitted} then assign ub.gds-dtl.doc-qnty:read-only  in browse {&browse-name} = yes.
        otherwise   assign ub.gds-dtl.doc-qnty:read-only  in browse {&browse-name} = yes
                          ub.gds-dtl.fact-qnty:read-only in browse {&browse-name} = yes.
      end case.
  end.
end .
&endif
/* при вызове данного include - файла здесь дб приписан END */

/* $Workfile$ e n d */