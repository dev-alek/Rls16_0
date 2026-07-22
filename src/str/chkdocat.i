/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/13/06
Author: Bakhtadze Natalya
Creation date: 04/13/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if defined(chkdocat_i) = 0 &then

&glob chkdocat_i

/*
АТрибут для блокирования остальных атрибутов в интерфейсе*/


&scop bef-attr-chk-doc-attr-lock lock
&glob attr-chk-doc-attr-lock '{&bef-attr-chk-doc-attr-lock}':U
&glob type-attr-chk-doc-attr-lock {&type-log}
&glob format-attr-chk-doc-attr-lock  "yes/no"
&glob label-attr-chk-doc-attr-lock   "Блокировка атрибутов на изменение"
&glob tooltip-attr-chk-doc-attr-lock   "Блокировка атрибутов на изменение"
&glob user-can-edit-attr-chk-doc-attr-lock  false
&glob output-display-attr-chk-doc-attr-lock  false
&glob other-attr-chk-doc-attr-lock  ""
&glob copy-attr-chk-doc-attr-lock  false
&scop manual-edit-attr-chk-doc-attr-lock 0
&scop batch-edit-attr-chk-doc-attr-lock  0


&scop bef-chk-doc-attr-out-code-2 out-code-2
&glob chk-doc-attr-out-code-2 '{&bef-chk-doc-attr-out-code-2}':U
&glob type-chk-doc-attr-out-code-2 {&type-char}
&glob format-chk-doc-attr-out-code-2  "X(14)"
&glob label-chk-doc-attr-out-code-2   "Номер док-та, использующего чек"
&glob tooltip-chk-doc-attr-out-code-2   "Номер док-та, использующего чек (кроме продажи)"
&glob user-can-edit-chk-doc-attr-out-code-2  false
&glob output-display-chk-doc-attr-out-code-2  true
&glob other-chk-doc-attr-out-code-2  ""
&glob copy-chk-doc-attr-out-code-2  true
&scop manual-edit-chk-doc-attr-out-code-2  0
&scop batch-edit-chk-doc-attr-out-code-2  0

&scop bef-chk-doc-attr-qr-alchol qr-alchol
&glob chk-doc-attr-qr-alchol '{&bef-chk-doc-attr-qr-alchol}':U
&glob type-chk-doc-attr-qr-alchol {&type-char}
&glob format-chk-doc-attr-qr-alchol  "X(64)"
&glob label-chk-doc-attr-qr-alchol   "Qr-коды от ЕГАИС по алкоголю (кроме пива)"
&glob tooltip-chk-doc-attr-qr-alchol   "Qr-коды от ЕГАИС по алкоголю, (кроме пива)"
&glob user-can-edit-chk-doc-attr-qr-alchol  false
&glob output-display-chk-doc-attr-qr-alchol  true
&glob other-chk-doc-attr-qr-alchol  '':u
&glob copy-chk-doc-attr-qr-alchol  true
&scop manual-edit-chk-doc-attr-qr-alchol  0
&scop batch-edit-chk-doc-attr-qr-alchol  0

&scop bef-chk-doc-attr-qr-alchol qr-alchol-pv
&glob chk-doc-attr-qr-alchol-pv '{&bef-chk-doc-attr-qr-alchol-pv}':U
&glob type-chk-doc-attr-qr-alchol-pv {&type-char}
&glob format-chk-doc-attr-qr-alchol-pv  "X(64)"
&glob label-chk-doc-attr-qr-alchol-pv   "Qr-коды от ЕГАИС по пиву)"
&glob tooltip-chk-doc-attr-qr-alchol-pv   "Qr-коды от ЕГАИС по пиву"
&glob user-can-edit-chk-doc-attr-qr-alchol-pv  false
&glob output-display-chk-doc-attr-qr-alchol-pv  true
&glob other-chk-doc-attr-qr-alchol-pv  '':u
&glob copy-chk-doc-attr-qr-alchol-pv  true
&scop manual-edit-chk-doc-attr-qr-alchol-pv  0
&scop batch-edit-chk-doc-attr-qr-alchol-pv  0

&glob chkdocat-list '{&bef-attr-chk-doc-attr-locko}~
,{&bef-chk-doc-attr-out-code-2}~
':U

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
    . ~
  end.


procedure chkdocat-name :
/*-----------------------------------------------------------------------------------------------------------------------*/
do
  on error undo, return error return-value
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */
    case p-code :
      &scop attr-code attr-chk-doc-attr-lock
      {&attr-temp-full-code}
      &scop attr-code chk-doc-attr-out-code-2
      {&attr-temp-full-code}
      &scop attr-code chk-doc-attr-qr-alchol
      {&attr-temp-full-code}
      &scop attr-code chk-doc-attr-qr-alchol-pv
      {&attr-temp-full-code}

       /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут чека &1", p-code ).
      end.
    end.
  end.
end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure chkdocat-tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error return-value
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      &scop attr-code attr-chk-doc-attr-lock
      {&attr-temp-code}
      &scop attr-code chk-doc-attr-out-code-2
      {&attr-temp-code}
      &scop attr-code chk-doc-attr-qr-alchol
      {&attr-temp-code}
      &scop attr-code chk-doc-attr-qr-alchol-pv
      {&attr-temp-code}

     /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("Неизвестный атрибут чека &1", p-code ).
      end.
    end.
  end.
end procedure.


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure chkdocat-value :
/*-----------------------------------------------------------------------------------------------------------------------*/

 do
  on error undo, return error
  :
    define input  parameter p-doc-code like ub.chk-doc-attr.doc-code   no-undo .
    define input  parameter p-code     like ub.chk-doc-attr.attr-code  no-undo .
    define output parameter p-value    like ub.chk-doc-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .

    define buffer buf_chk-doc-attr for ub.chk-doc-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run chkdocat-name in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_chk-doc-attr no-lock where
               buf_chk-doc-attr.doc-code  = p-doc-code AND
               buf_chk-doc-attr.attr-code = p-code
      no-error .
    if avail buf_chk-doc-attr then do:
      assign
        p-value =  buf_chk-doc-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.


procedure chkdocat-write :

  do
  on error undo, return error
  :
    define input parameter p-doc-code like ub.chk-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.chk-doc-attr.attr-code  no-undo .
    define input parameter p-value    like ub.chk-doc-attr.attr-value no-undo .

    define buffer buf_chk-doc-attr for ub.chk-doc-attr .
    define buffer lock_chk-doc-attr for ub.chk-doc-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run chkdocat-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    /*
    воможный вариант локировки с помощью дополнительного атрибута
    find first lock_chk-doc-attr exclusive-lock where
               lock_chk-doc-attr.doc-code  = p-doc-code AND
              lock_chk-doc-attr.attr-code = {&attr-lock} no-error no-wait .
    if locked lock_chk-doc-attr then do:
      undo, return error {&attr-lock}.
    end.
    if not available lock_chk-doc-attr
    and not locked lock_chk-doc-attr
    then do:
      create lock_chk-doc-attr.
      assign
      lock_chk-doc-attr.doc-code  = p-doc-code
      lock_chk-doc-attr.attr-code = {&attr-lock}
      no-error
      .
    end.
    find current lock_chk-doc-attr share-lock.
    */
    find first buf_chk-doc-attr exclusive-lock where
               buf_chk-doc-attr.doc-code  = p-doc-code AND
               buf_chk-doc-attr.attr-code = p-code no-error .
    if not available buf_chk-doc-attr then do:
      create buf_chk-doc-attr .
      assign
        buf_chk-doc-attr.doc-code  = p-doc-code
        buf_chk-doc-attr.attr-code = p-code
        buf_chk-doc-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_chk-doc-attr.attr-value = p-value no-error.
  end.

end procedure.


procedure chkdocat-exist :

  do
  on error undo, return error
  :
    define input parameter p-doc-code like ub.chk-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.chk-doc-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .

    define buffer buf_chk-doc-attr for ub.chk-doc-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run chkdocat-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_chk-doc-attr no-lock where
               buf_chk-doc-attr.doc-code  = p-doc-code AND
               buf_chk-doc-attr.attr-code = p-code no-error .
    if available buf_chk-doc-attr then do:
      P-EXIST = YES.
    end.
  end.

end procedure.

procedure chkdocat-delete :

  do
  on error undo, return error
  :
    define input parameter p-doc-code like ub.chk-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.chk-doc-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .

    define buffer buf_chk-doc-attr for ub.chk-doc-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run chkdocat-name in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_chk-doc-attr exclusive-lock where
               buf_chk-doc-attr.doc-code  = p-doc-code AND
               buf_chk-doc-attr.attr-code = p-code no-error .
    if not available buf_chk-doc-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_chk-doc-attr.
       P-DELETED = YES.
    END.
  end.

end procedure.

&endif

/* $Workfile$ e n d */
