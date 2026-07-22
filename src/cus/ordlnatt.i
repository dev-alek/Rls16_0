/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для атрибутов заказов и поставок СТРОКИ

Автор: Чернова Светлана Александровна
Дата создания: 11/27/08
Author: Svetlana Chernova
Creation date: 11/27/08

*/

&if defined(ordlnatt_i) = 0 &then

&glob ordlnatt_i


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
/*----------------------------ВНИМАНИЕ!!!------------------------------------------------- */
/*значения атрибутов имеющих логический тип должны записываться в базу чисто как yes или no*/
/*все форматирование осуществлять на верхнем уровне                                        */

/* Цикличные заказы сохранение значений  */
&glob type-ordlineattr-cli-qnty           {&type-dec}
&glob format-ordlineattr-cli-qnty         ">>>>>>>>>>>>>>>9.999"
&glob fillin_width-ordlineattr-cli-qnty   20
&glob fillin_height-ordlineattr-cli-qnty  1
&glob label-ordlineattr-cli-qnty          "Количество"
&glob tooltip-ordlineattr-cli-qnty        "Количество в едизм поставщика"
&glob user-can-edit-ordlineattr-cli-qnty  false
&glob output-display-ordlineattr-cli-qnty false
&glob other-ordlineattr-cli-qnty          '':u
&glob news-ordlineattr-cli-qnty           true
&glob sort-ordlineattr-cli-qnty           10
&glob proc-ordlineattr-cli-qnty           '':u
&glob func-ordlineattr-cli-qnty           '':u


/* Цикличные заказы сохранение значений  */
&glob type-attr-order-ean13           {&type-char}
&glob format-attr-order-ean13         "X(13)"
&glob fillin_width-attr-order-ean13   20
&glob fillin_height-attr-order-ean13  1
&glob label-attr-order-ean13          "EAN в EDI"
&glob tooltip-attr-order-ean13        "EAN в EDI"
&glob user-can-edit-attr-order-ean13  false
&glob output-display-attr-order-ean13 false
&glob other-attr-order-ean13          '':u
&glob news-attr-order-ean13           true
&glob sort-attr-order-ean13           10
&glob proc-attr-order-ean13           '':u
&glob func-attr-order-ean13           '':u


/* ------------------------------------------------------------------- */
procedure ordlineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.ord-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .

    run ordlineattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output p-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-fillin_width   /* p-fillin_width   */
      ,output v-fillin_height  /* p-fillin_height  */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-proc           /* p-other          */
      ,output v-func           /* p-other          */
      ,output v-sort           /* p-other          */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_ord-line-attr no-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if avail buf_ord-line-attr then do:
      assign
        p-value =  buf_ord-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.

procedure ordlineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.ord-line-attr.attr-value no-undo .

    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .

    run ordlineattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-fillin_width   /* p-fillin_width   */
      ,output v-fillin_height  /* p-fillin_height  */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-proc           /* p-other          */
      ,output v-func           /* p-other          */
      ,output v-sort           /* p-other          */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
      undo, return error return-value .
    end.

    find first buf_ord-line-attr exclusive-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if not available buf_ord-line-attr then do:
      create buf_ord-line-attr .
      assign
        buf_ord-line-attr.doc-code   = p-doc-code
        buf_ord-line-attr.gds-code   = p-gds-code
        buf_ord-line-attr.attr-code  = p-code
      .
    end.
    assign
      buf_ord-line-attr.attr-value = p-value
    .
end.
end procedure.

procedure ordlineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .

    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .

    run ordlineattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-fillin_width   /* p-fillin_width   */
      ,output v-fillin_height  /* p-fillin_height  */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-proc           /* p-other          */
      ,output v-func           /* p-other          */
      ,output v-sort           /* p-other          */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_ord-line-attr no-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if  available buf_ord-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.

procedure ordlineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.

    define buffer buf_ord-line-attr for ub.ord-line-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .

    define variable v-other          as character no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code           /* p-code           */
      ,output v-type           /* p-type           */
      ,output v-format         /* p-format         */
      ,output v-fillin_width   /* p-fillin_width   */
      ,output v-fillin_height  /* p-fillin_height  */
      ,output v-label          /* p-label          */
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-proc           /* p-other          */
      ,output v-func           /* p-other          */
      ,output v-sort           /* p-other          */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-line-attr exclusive-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_ord-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_ord-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.

&scop attr-temp-full-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-label          = ~{&label-~{&attr-code~}~} ~
    p-type           = ~{&type-~{&attr-code~}~}  ~
    p-format         = ~{&format-~{&attr-code~}~} ~
    p-fillin_width   = ~{&fillin_width-~{&attr-code~}~} ~
    p-fillin_height  = ~{&fillin_height-~{&attr-code~}~} ~
    p-label          = ~{&label-~{&attr-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&attr-code~}~} ~
    p-output-display = ~{&output-display-~{&attr-code~}~} ~
    p-sort           = ~{&sort-~{&attr-code~}~} ~
    p-proc           = ~{&proc-~{&attr-code~}~} ~
    p-func           = ~{&func-~{&attr-code~}~} ~
    p-other          = ~{&other-~{&attr-code~}~}  ~
    . ~
  end.

procedure ordlineattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo . /* код атрибута    */
    define output parameter p-type           as character no-undo . /* тип атрибута    */
    define output parameter p-format         as character no-undo . /* формат атрибута */
    define output parameter p-fillin_width   as integer   no-undo . /* ширина          */
    define output parameter p-fillin_height  as integer   no-undo . /* высота          */
    define output parameter p-label          as character no-undo . /* лабел атрибута */
    define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
    define output parameter p-output-display as logical   no-undo . /* виден в броусе */
    define output parameter p-proc           as character no-undo .
    define output parameter p-func           as character no-undo .
    define output parameter p-sort           as integer   no-undo .
    define output parameter p-other          as character no-undo . /* еще чего - нибудь */

    case p-code :
      &scop attr-code ordlineattr-cli-qnty
      {&attr-temp-full-code}
      &scop attr-code attr-order-ean13
      {&attr-temp-full-code}


      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут строки заказа" + " " + p-code .
      end.
    end.
  end.
end procedure.
&endif

/* $Workfile$ e n d */
