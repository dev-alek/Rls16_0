/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с атрибутами товара на складском месте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".



/* ------------------------------------------------------------------- */
/* сюда добавлять новые атрибуты */
/* ------------------------------------------------------------------- */

&glob plgdattr-list '~
':u


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

&scop attr-copy-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-copy = ~{&copy-~{&attr-code~}~}. ~
  end.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure plgdattr-name :
/*-----------------------------------------------------------------------------------------------------------------------*/
do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */
    case p-code :
       /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("Неизвестный атрибут товара на складском месте &1",  p-code ).
      end.
    end.
  end.
end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure plgdattr-tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
     /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("Неизвестный атрибут товара складском месте &1" , p-code ).
      end.
    end.
  end.
end procedure.


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure plgdattr-value :
/*-----------------------------------------------------------------------------------------------------------------------*/

 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.pl-gds-attr.attr-code  no-undo .
    define input  parameter p-obj-type like ub.pl-gds-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.pl-gds-attr.obj-code   no-undo .
    define input  parameter p-pl-code  like ub.pl-gds-attr.pl-code    no-undo .
    define input  parameter p-gds-code like ub.pl-gds-attr.gds-code   no-undo .
    define output parameter p-value    like ub.pl-gds-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .

    define buffer buf_pl-gds-attr for ub.pl-gds-attr .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run plgdattr-name in this-procedure
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

    find first buf_pl-gds-attr no-lock where
               buf_pl-gds-attr.obj-type  = p-obj-type
           AND buf_pl-gds-attr.obj-code  = p-obj-code
           AND buf_pl-gds-attr.pl-code  = p-pl-code
           AND buf_pl-gds-attr.gds-code  = p-gds-code
           AND buf_pl-gds-attr.attr-code = p-code
      no-error .
    if avail buf_pl-gds-attr then do:
      assign
        p-value =  buf_pl-gds-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.


procedure plgdattr-write :

  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pl-gds-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pl-gds-attr.obj-code   no-undo .
    define input parameter p-pl-code  like ub.pl-gds-attr.pl-code    no-undo .
    define input parameter p-gds-code like ub.pl-gds-attr.gds-code   no-undo .
    define input parameter p-code     like ub.pl-gds-attr.attr-code  no-undo .
    define input parameter p-value    like ub.pl-gds-attr.attr-value no-undo .

    define buffer buf_pl-gds-attr for ub.pl-gds-attr .
    define buffer lock_pl-gds-attr for ub.pl-gds-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run plgdattr-name in this-procedure
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
    find first buf_pl-gds-attr exclusive-lock where
               buf_pl-gds-attr.obj-type  = p-obj-type
           AND buf_pl-gds-attr.obj-code  = p-obj-code
           AND buf_pl-gds-attr.pl-code  = p-pl-code
           AND buf_pl-gds-attr.gds-code  = p-gds-code
           AND buf_pl-gds-attr.attr-code = p-code no-error .
    if not available buf_pl-gds-attr then do:
      create buf_pl-gds-attr .
      assign
      buf_pl-gds-attr.obj-type  = p-obj-type
      buf_pl-gds-attr.obj-code  = p-obj-code
      buf_pl-gds-attr.pl-code  = p-pl-code
      buf_pl-gds-attr.gds-code  = p-gds-code
      buf_pl-gds-attr.attr-code = p-code
      buf_pl-gds-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_pl-gds-attr.attr-value = p-value no-error.
  end.

end procedure.


procedure plgdattr-exist :

  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pl-gds-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pl-gds-attr.obj-code   no-undo .
    define input parameter p-pl-code  like ub.pl-gds-attr.pl-code    no-undo .
    define input parameter p-gds-code like ub.pl-gds-attr.gds-code   no-undo .
    define input parameter p-code     like ub.pl-gds-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .

    define buffer buf_pl-gds-attr for ub.pl-gds-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run plgdattr-name in this-procedure
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

    find first buf_pl-gds-attr no-lock where
               buf_pl-gds-attr.obj-type  = p-obj-type
           AND buf_pl-gds-attr.obj-code  = p-obj-code
           AND buf_pl-gds-attr.pl-code  = p-pl-code
           AND buf_pl-gds-attr.gds-code  = p-gds-code
           AND buf_pl-gds-attr.attr-code = p-code no-error .
    if available buf_pl-gds-attr then do:
      P-EXIST = YES.
    end.
  end.

end procedure.

procedure plgdattr-delete :

  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pl-gds-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pl-gds-attr.obj-code   no-undo .
    define input parameter p-pl-code  like ub.pl-gds-attr.pl-code    no-undo .
    define input parameter p-gds-code like ub.pl-gds-attr.gds-code   no-undo .
    define input parameter p-code     like ub.pl-gds-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .

    define buffer buf_pl-gds-attr for ub.pl-gds-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run plgdattr-name in this-procedure
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

    find first buf_pl-gds-attr exclusive-lock where
               buf_pl-gds-attr.obj-type  = p-obj-type
           AND buf_pl-gds-attr.obj-code  = p-obj-code
           AND buf_pl-gds-attr.gds-code  = p-gds-code
           AND buf_pl-gds-attr.pl-code  = p-pl-code
           AND buf_pl-gds-attr.attr-code = p-code no-error .
    if not available buf_pl-gds-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_pl-gds-attr.
       P-DELETED = YES.
    END.
  end.

end procedure.

&if "{1}" = "interface" &then

&endif


/* $Workfile$ e n d */