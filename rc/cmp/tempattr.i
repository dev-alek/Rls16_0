/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Таблица хранения шаблонов атрибутов различных сущностей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/18/06
Author: Bakhtadze Natalya
Creation date: 01/18/06


1 - new shared , shared , "":U
2  - имя таблицы с которой работаем
3 - текущий host
4 - текущий объект
5 - текцущий объект

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table temp-attr no-undo
field attr-code like ub.gds-obj-attr.attr-code
field attr-value like ub.gds-obj-attr.attr-value
field host-code as integer
field obj-type as character
field obj-code as integer
field user-can-edit as log
field code as char
field action as logical
field other-inf as character
index pi is  unique primary
attr-code host-code obj-type obj-code ASCENDING
index action
action
.


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure tempattr-value :
/*-----------------------------------------------------------------------------------------------------------------------*/

 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input  parameter p-host-code as integer no-undo .
    define input  parameter p-obj-type as character no-undo .
    define input  parameter p-obj-code as integer no-undo .
    define input  parameter p-mode      as character no-undo .
    define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .

    define buffer buf_temp-attr for temp-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable jj               as integer   no-undo .
    define variable v-spr            as logical   no-undo .
    define variable v-spr-name       as character no-undo .
    define variable v-spr-param      as character no-undo .
    define variable v-setted         as logical   no-undo .
    case {2}:
      when {&table_gds-obj-attr}
      then do:
        run gdsoattr-name in this-procedure
          (input  p-code           /* p-code           */
          ,output p-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      when {&table_gds-host-attr}
      then do:
        run gdshattr-name in this-procedure
          (input  p-code           /* p-code           */
          ,output p-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      when {&table_clients-attr}
      then do:
        run clntattr-code in this-procedure
          (input  p-code           /* p-code           */
          ,output p-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      when {&table_goods-attr}
      then do:
        run gds-attr-name in this-procedure
          (input  p-code           /* p-code           */
          ,output p-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      otherwise do:
        undo, return error .
      end.
    end case.
    if error-status :error
    then do:
      undo, return error return-value .
    end.
    if v-user-can-edit
    then do:
      do jj = 1 to num-entries(v-other, {&slash-char}):
        if entry(1, entry(jj, v-other, {&slash-char}), "=":U) = "spr":U then do:
          assign
          v-spr-name = entry(2, entry(jj, v-other, {&slash-char}), "=":U)
          .
        end.
        if entry(1, entry(jj, v-other, {&slash-char}), "=":U) = "spr-param":U then do:
          assign
          v-spr-param = entry(2, entry(jj, v-other, {&slash-char}), "=":U)
          .
        end.
     end.
      if v-spr-name <> "":U then do:
        if p-mode = "change":U
        then do:
          find first buf_temp-attr no-lock where
                    buf_temp-attr.attr-code = p-code
                and buf_temp-attr.host-code = p-host-code
                and buf_temp-attr.obj-type = p-obj-type
                and buf_temp-attr.obj-code = p-obj-code
            no-error .
          if avail buf_temp-attr then do:
            assign
              p-value =  buf_temp-attr.attr-value
            .
          end.
          else do:
            assign
              p-value = if p-type = {&type-log} then "no":U else ""
            .
          end.
        end.
        CASE {2}:
          when {&table_gds-obj-attr} then do:
            if v-spr-param = "":U then do:
              run value (
                          v-spr-name)
                          in this-procedure (
                                                input 0
                                              ,input parobj-type
                                              ,input parobj-code
                                              ,input-output p-value
                                              ,output v-setted) no-error .
            end.
            else do:
              run value (
                          v-spr-name)
                          in this-procedure (
                                                input 0
                                              ,input parobj-type
                                              ,input parobj-code
                                              ,input v-spr-param
                                              ,input-output p-value
                                              ,output v-setted) no-error .
            end.
            if error-status :error then do:
              undo, return error "Неизвестный справочник для получения значения атрибут товара на объекте" + " " + p-code .
            end.
          end.
          when {&table_clients-attr} then do:
          if v-spr-param = "":U then do:
            run   value ( v-spr-name ) in this-procedure
                (  input 0
                  ,input parobj-type
                  ,input parobj-code
                  ,input-output p-value
                  ,output v-setted )
                  no-error .
          end.
          end.
          END CASE.
        if v-setted = no then do:
          return "not-set":U.
        end.
        assign
        v-spr = yes
        .
      end.
    end.
    if not v-spr then do:
      find first buf_temp-attr no-lock where
                buf_temp-attr.attr-code = p-code
            and buf_temp-attr.host-code = p-host-code
            and buf_temp-attr.obj-type = p-obj-type
            and buf_temp-attr.obj-code = p-obj-code
        no-error .
      if avail buf_temp-attr then do:
        assign
          p-value =  buf_temp-attr.attr-value
        .
      end.
      else do:
        assign
          p-value = if p-type = {&type-log} then "no":U else ""
        .
      end.
    end.
  end.

end procedure.


procedure tempattr-write :

  do
  on error undo, return error
  :
    define input parameter p-add      as logical no-undo .
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input parameter p-host-code as integer no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
    define input parameter p-action   like temp-attr.action no-undo .
    define buffer buf_temp-attr for temp-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable var-region  as character no-undo.
    DEFINE VARIABLE v-sel-vals as character no-undo .
    DEFINE VARIABLE v-sel-labels as character no-undo .
    define variable varhost-code like ub.sysconf.host-code no-undo.
    define variable varobj-type like ub.clients.obj-type no-undo.
    define variable varobj-code like ub.clients.obj-code no-undo.
    define variable choice as integer no-undo .


    case {2}:
      when {&table_gds-obj-attr}
      then do:
        run gdsoattr-name in this-procedure
          (input  p-code           /* p-code           */
          ,output v-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      when {&table_gds-host-attr}
      then do:
        run gdshattr-name in this-procedure
          (input  p-code           /* p-code           */
          ,output v-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      when {&table_clients-attr}
      then do:
        run clntattr-code in this-procedure
          (input  p-code           /* p-code           */
          ,output v-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      when {&table_goods-attr}
      then do:
        run gds-attr-name in this-procedure
          (input  p-code           /* p-code           */
          ,output v-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      otherwise do:
        undo, return error .
      end.
    END CASE.

    if error-status :error then do:
      undo, return error return-value .
    end.
    if not v-user-can-edit then do:
      message
      "Запрещено редактировать атрибут" v-label
      view-as alert-box error .
      undo, return error.
    end.

    find first buf_temp-attr exclusive-lock where
               buf_temp-attr.attr-code = p-code
            and buf_temp-attr.host-code = p-host-code
            and buf_temp-attr.obj-type = p-obj-type
            and buf_temp-attr.obj-code = p-obj-code no-error .
    if not available buf_temp-attr then do:
      create buf_temp-attr .
      assign
        buf_temp-attr.attr-code = p-code
        buf_temp-attr.host-code = p-host-code
        buf_temp-attr.obj-type = p-obj-type
        buf_temp-attr.obj-code = p-obj-code
        buf_temp-attr.attr-value = p-value
        buf_temp-attr.action = p-action
        buf_temp-attr.code = v-label
        buf_temp-attr.other-inf = v-other
        no-error
      .
    end.
    ELSE
    ASSIGN
    buf_temp-attr.attr-value = p-value no-error.
  end.

end procedure.


procedure tempattr-exist :

  do
  on error undo, return error
  :
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input parameter p-host-code as integer no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define output parameter p-exist    as logical no-undo .
    define output parameter p-action as logical no-undo .

    define buffer buf_temp-attr for temp-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-range          as integer   no-undo .

    case {2}:
      when {&table_gds-obj-attr} then do:
        run gdsoattr-name in this-procedure
          (input  p-code           /* p-code           */
          ,output v-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      when {&table_gds-host-attr}
      then do:
        run gdshattr-name in this-procedure
          (input  p-code           /* p-code           */
          ,output v-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      when {&table_clients-attr}
      then do:
        run clntattr-code in this-procedure
          (input  p-code           /* p-code           */
          ,output v-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      when {&table_goods-attr} then do:
        run gds-attr-name in this-procedure
          (input  p-code           /* p-code           */
          ,output v-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      otherwise do:
        undo, return error .
      end.
    end case.

    if error-status :error
    then do:
      undo, return error return-value .
    end.

    find first buf_temp-attr no-lock where
               buf_temp-attr.attr-code = p-code
            and buf_temp-attr.host-code = p-host-code
            and buf_temp-attr.obj-type = p-obj-type
            and buf_temp-attr.obj-code = p-obj-code no-error .
    if available buf_temp-attr then do:
      P-EXIST = YES.
      p-action = buf_temp-attr.action.
    end.
  end.

end procedure.

procedure tempattr-delete :

  do
  on error undo, return error
  :
    define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
    define input parameter p-host-code as integer no-undo .
    define input parameter p-obj-type as character no-undo .
    define input parameter p-obj-code as integer no-undo .
    define output parameter p-deleted  as logical no-undo .

    define buffer buf_temp-attr for temp-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-range          as integer   no-undo .

    case {2}:
      when {&table_gds-obj-attr}
      then do:
        run gdsoattr-name in this-procedure
          (input  p-code           /* p-code           */
          ,output v-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      when {&table_gds-host-attr}
      then do:
        run gdshattr-name in this-procedure
          (input  p-code           /* p-code           */
          ,output v-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      when {&table_clients-attr}
      then do:
        run clntattr-code in this-procedure
          (input  p-code           /* p-code           */
          ,output v-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.
      when {&table_goods-attr}
      then do:
        run gds-attr-name in this-procedure
          (input  p-code           /* p-code           */
          ,output v-type           /* p-type           */
          ,output v-format         /* p-format         */
          ,output v-label          /* p-label          */
          ,output v-user-can-edit  /* p-user-can-edit  */
          ,output v-output-display /* p-output-display */
          ,output v-other          /* p-other          */
          ) no-error .
      end.

      otherwise do:
        undo, return error .
      end.
    END CASE.

    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_temp-attr exclusive-lock where
               buf_temp-attr.attr-code = p-code
            and buf_temp-attr.host-code = p-host-code
            and buf_temp-attr.obj-type = p-obj-type
            and buf_temp-attr.obj-code = p-obj-code no-error .
    if not available buf_temp-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_temp-attr.
       P-DELETED = YES.
    END.
  end.

end procedure.


/* $Workfile$ e n d */