/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами типов ДК карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/02/05
Author: Bakhtadze Natalya
Creation date: 12/02/05

*/

&if defined(dct-attr_i) = 0 &then

&glob dct-attr_i


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/cur-time.i }

/*----------------------------ВНИМАНИЕ!!!------------------------------------------------- */
/*значения атрибутов имеющих логический тип должны записываться в базу чисто как yes или no*/
/*все форматирование осуществлять на верхнем уровне                                        */

/*
/* пример параметра */
&scop bef-dct-attr-test test
&glob dct-attr-test '{&bef-dct-attr-test}':U
&scop type-dct-attr-test {&type-log}
&scop format-dct-attr-test "+/-"
&scop range-dct-attr-test  1
&scop label-dct-attr-test "тест"
&scop tooltip-dct-attr-test "тесттттттттттт"
&scop user-can-edit-dct-attr-test no
&scop output-display-dct-attr-test true
&scop other-dct-attr-test '':u
&scop news-dct-attr-test yes

&glob dct-attr-list '{&bef-dct-attr-test}~
':u


*/

/* сюда добавлять новые параметры */

&glob dct-attr-list '~
':u


/* ------------------------------------------------------------------- */
&scop attr-temp-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} . ~
  end.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-type = ~{&type-~{&attr-code~}~}  ~
    p-format = ~{&format-~{&attr-code~}~} ~
    p-label = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-other = ~{&other-~{&attr-code~}~}  ~
    p-range = ~{&range-~{&attr-code~}~}  ~
    . ~
  end.

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.



procedure dct-attr-code :

  do
  on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-type           as character no-undo . /* тип атрибута */
    define output parameter p-format         as character no-undo . /* формат атрибута */
    define output parameter p-label          as character no-undo . /* лабел атрибута */
    define output parameter p-range          as integer   no-undo . /* область действия атрибута */
    define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
    define output parameter p-output-display as logical   no-undo . /* виден в броусе */
    define output parameter p-other          as character no-undo . /* еще чего - нибудь */
    if index(p-code, {&delim-par}) > 0 then do:
      p-code = entry(1, p-code, {&delim-par}).
    end.
    case p-code :
      /* сюда добавлять новые параметры */
      /*
      &scop attr-code dct-attr-test
      {&attr-temp-full-code}
      */

      otherwise do:
        undo, return error substitute("неизвестный атрибут типа дисконтной карты &1", p-code ).
      end.
    end.
  end.
end procedure.

procedure dct-attr-tooltip :

  do
  on error undo, return error return-value
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    if index(p-code, {&delim-par}) > 0 then do:
      p-code = entry(1, p-code, {&delim-par}).
    end.
    case p-code :
      /*
      &scop attr-code dct-attr-test
      {&attr-temp-code}
      */

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа дисконтной карты &1",  p-code ).
      end.
    end.
  end.

end procedure.


procedure dct-attr-value :

  do
  on error undo, return error return-value
  :
    define input parameter p-emitent-host-code  like ub.dis-card-type.emitent-host-code no-undo .
    define input parameter p-type-card               like ub.dis-card-type.type no-undo .
    define input  parameter p-host-code like ub.dis-card-type-attr.host-code  no-undo .
    define input  parameter p-obj-type  like ub.dis-card-type-attr.obj-type   no-undo .
    define input  parameter p-obj-code  like ub.dis-card-type-attr.obj-code   no-undo .
    define input  parameter p-code      like ub.dis-card-type-attr.attr-code  no-undo .
    define output parameter p-value     like ub.dis-card-type-attr.attr-value no-undo .
    define output parameter p-type      as character no-undo .

    define buffer buf_dis-card-type-attr for ub.dis-card-type-attr .

    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-range          as integer   no-undo .

    run dct-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-range          /* p-range          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if v-range <= 4 then do:
      CASE v-range:
        when 1 then do:
          assign
          p-host-code = 0
          p-obj-type = "":U
          p-obj-code = 0
          .
        end.
        when 2 then do:
          assign
          p-obj-type = "":U
          p-obj-code = 0
          .
        end.
        when 4 then do:
        end.
      END CASE.
    end.
    find first buf_dis-card-type-attr no-lock
      where
            buf_dis-card-type-attr.emitent-host-code   = p-emitent-host-code
        and buf_dis-card-type-attr.type                = p-type-card
        and buf_dis-card-type-attr.host-code = p-host-code
        and buf_dis-card-type-attr.obj-type  = p-obj-type
        and buf_dis-card-type-attr.obj-code  = p-obj-code
        and buf_dis-card-type-attr.attr-code = p-code
      no-error .
    if avail buf_dis-card-type-attr then do:
      assign
        p-value =  buf_dis-card-type-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.


procedure dct-attr-write :

  do
  on error undo, return error return-value
  :
    define input parameter p-emitent-host-code  like ub.dis-card-type.emitent-host-code no-undo .
    define input parameter p-type               like ub.dis-card-type.type no-undo .
    define input parameter p-host-code like ub.dis-card-type-attr.host-code  no-undo .
    define input parameter p-obj-type  like ub.dis-card-type-attr.obj-type   no-undo .
    define input parameter p-obj-code  like ub.dis-card-type-attr.obj-code   no-undo .
    define input parameter p-code      like ub.dis-card-type-attr.attr-code  no-undo .
    define input parameter p-value     like ub.dis-card-type-attr.attr-value no-undo .
    define input parameter p-cmd-proc-handle as handle no-undo .
    define input parameter p-cmd-code as integer no-undo .

    define buffer buf_dis-card-type-attr for ub.dis-card-type-attr .
    define buffer buf_dis-card-type for ub.dis-card-type.

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-send           as logical   no-undo .

    run dct-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-range          /* p-range          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_dis-card-type-attr exclusive-lock
      where
            buf_dis-card-type-attr.emitent-host-code   = p-emitent-host-code
        and buf_dis-card-type-attr.type                = p-type
        and buf_dis-card-type-attr.host-code = p-host-code
        and buf_dis-card-type-attr.obj-type  = p-obj-type
        and buf_dis-card-type-attr.obj-code  = p-obj-code
        and buf_dis-card-type-attr.attr-code = p-code
      no-error .
    if not available buf_dis-card-type-attr then do:
      find first buf_dis-card-type no-lock where
            buf_dis-card-type.emitent-host-code   = p-emitent-host-code
        and buf_dis-card-type.type                = p-type
                 .
      create buf_dis-card-type-attr .
      assign
        buf_dis-card-type-attr.emitent-host-code = p-emitent-host-code
        buf_dis-card-type-attr.type = p-type
        buf_dis-card-type-attr.host-code = p-host-code
        buf_dis-card-type-attr.emitent-host-code = p-emitent-host-code
        buf_dis-card-type-attr.obj-type  = p-obj-type
        buf_dis-card-type-attr.obj-code  = p-obj-code
        buf_dis-card-type-attr.attr-code = p-code
      .
      assign
      v-send = yes.
    end.
    else do:
      if p-value <> buf_Dis-card-type-attr.attr-value then do:
        v-send = yes.
      end.
    end.
    assign
      buf_dis-card-type-attr.attr-value = p-value
    .
    if v-send
    and valid-handle(p-cmd-proc-handle) then do:
      run add-dump in p-cmd-proc-handle
        (input p-cmd-code
        ,input {&table_dis-card-type-attr}
        ,input '+update'
        ,input buffer buf_dis-card-type-attr:handle
        ,input '':U
        ) no-error .
      if error-status:error then do:
        /*обработку с удалением cmd-proc-handle надо делать наверху*/
          undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
      end.
    end.
  end.

end procedure.


procedure dct-attr-exist :

  do
  on error undo, return error return-value
  :

    define input parameter p-emitent-host-code  like ub.dis-card-type.emitent-host-code no-undo .
    define input parameter p-type               like ub.dis-card-type.type no-undo .
    define input parameter p-host-code like ub.dis-card-type-attr.host-code  no-undo .
    define input parameter p-obj-type  like ub.dis-card-type-attr.obj-type   no-undo .
    define input parameter p-obj-code  like ub.dis-card-type-attr.obj-code   no-undo .
    define input parameter p-code      like ub.dis-card-type-attr.attr-code  no-undo .
    define output parameter p-exist    as logical  no-undo .

    define buffer buf_dis-card-type-attr for ub.dis-card-type-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable V-RANGE          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run dct-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,OUTPUT V-RANGE          /* P-RANGE          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_dis-card-type-attr no-lock
      where
            buf_dis-card-type-attr.emitent-host-code   = p-emitent-host-code
        and buf_dis-card-type-attr.type                = p-type
       and buf_dis-card-type-attr.host-code = p-host-code
        and buf_dis-card-type-attr.obj-type  = p-obj-type
        and buf_dis-card-type-attr.obj-code  = p-obj-code
        and buf_dis-card-type-attr.attr-code = p-code
      no-error .
    if  available buf_dis-card-type-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.

procedure dct-attr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-emitent-host-code  like ub.dis-card-type.emitent-host-code no-undo .
    define input parameter p-type               like ub.dis-card-type.type no-undo .
    define input parameter p-host-code like ub.dis-card-type-attr.host-code  no-undo .
    define input parameter p-obj-type like ub.dis-card-type-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.dis-card-type-attr.obj-code   no-undo .
    define input parameter p-code     like ub.dis-card-type-attr.attr-code  no-undo .
    define input parameter p-cmd-proc-handle as handle no-undo .
    define input parameter p-cmd-code as integer no-undo .
    define output parameter p-deleted  as logical no-undo.

    define buffer buf_dis-card-type-attr for ub.dis-card-type-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-rec-ord_        as integer no-undo .

    run dct-attr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-range          /* p-range          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_dis-card-type-attr exclusive-lock
      where
            buf_dis-card-type-attr.emitent-host-code   = p-emitent-host-code
        and buf_dis-card-type-attr.type                = p-type
        and buf_dis-card-type-attr.host-code = p-host-code
        and buf_dis-card-type-attr.obj-type  = p-obj-type
        and buf_dis-card-type-attr.obj-code  = p-obj-code
        and buf_dis-card-type-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_dis-card-type-attr then do:
      p-deleted = no.
    end.
    else do:
      if valid-handle(p-cmd-proc-handle) then do:
        run add-dump in p-cmd-proc-handle
          (input p-cmd-code
          ,input {&table_dis-card-type-attr}
          ,input '+delete'
          ,input buffer buf_dis-card-type-attr:handle
          ,input '':U
          ,output v-rec-ord_
          ) no-error .
        if error-status:error then do:
          /*обработку с удалением cmd-proc-handle надо делать наверху*/
          undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
        end.
      end.
      delete buf_dis-card-type-attr.
      p-deleted = yes.
    end.
  end.

end procedure.


procedure dct-attr-news :

  do
  on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    if index(p-code, {&delim-par}) > 0 then do:
      p-code = entry(1, p-code, {&delim-par}).
    end.
    case p-code :
      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа дисконтной карты &1", p-code ).
      end.
    end.
  end.
end procedure.

&endif

/* $Workfile$ e n d */