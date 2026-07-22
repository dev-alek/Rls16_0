/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с атрибутами пистолета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop bef-attr-nzzl-pulse-qnty pulse-qnty
&glob attr-nzzl-pulse-qnty '{&bef-attr-nzzl-pulse-qnty}':U
&glob type-attr-nzzl-pulse-qnty {&type-int}
&glob format-attr-nzzl-pulse-qnty  ">>>>"
&glob label-attr-nzzl-pulse-qnty   "Количество импульсов расходомера на 10 л"
&glob tooltip-attr-nzzl-pulse-qnty   "Количество импульсов расходомера на 10 л"
&glob user-can-edit-attr-nzzl-pulse-qnty  false
&glob output-display-attr-nzzl-pulse-qnty  false
&glob other-attr-nzzl-pulse-qnty  ""

&scop bef-attr-nzzl-max-no-overr-cnt-val max-no-overr-cnt-val
&glob attr-nzzl-max-no-overr-cnt-val '{&bef-attr-nzzl-max-no-overr-cnt-val}':U
&glob type-attr-nzzl-max-no-overr-cnt-val {&type-dec}
&glob format-attr-nzzl-max-no-overr-cnt-val  ">>>,>>>,>>>,>>9.9999"
&glob label-attr-nzzl-max-no-overr-cnt-val   "Max знач. необнуляемого счетчика"
&glob tooltip-attr-nzzl-max-no-overr-cnt-val   "Max знач. необнуляемого счетчика"
&glob user-can-edit-attr-nzzl-max-no-overr-cnt-val  false
&glob output-display-attr-nzzl-max-no-overr-cnt-val  false
&glob other-attr-nzzl-max-no-overr-cnt-val  ""



/* ------------------------------------------------------------------- */
/* сюда добавлять новые атрибуты */
/* ------------------------------------------------------------------- */

&glob nzzlattr-list '{&bef-attr-nzzl-pulse-qnty}~
,{&bef-attr-nzzl-max-no-overr-cnt-val}~
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
procedure nzzlattr-name :
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
      &scop attr-code attr-nzzl-pulse-qnty
      {&attr-temp-full-code}
      &scop attr-code attr-nzzl-max-no-overr-cnt-val
      {&attr-temp-full-code}


       /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут пистолета" + " " + p-code .
      end.
    end.
  end.
end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure nzzlattr-tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      &scop attr-code attr-nzzl-pulse-qnty
      {&attr-temp-code}
      &scop attr-code attr-nzzl-max-no-overr-cnt-val
      {&attr-temp-code}

     /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "Неизвестный атрибут пистолета" + " " + p-code .
      end.
    end.
  end.
end procedure.


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure nzzlattr-value :
/*-----------------------------------------------------------------------------------------------------------------------*/

 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.nozzle-attr.attr-code  no-undo .
    define input  parameter p-obj-type like ub.nozzle-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.nozzle-attr.obj-code   no-undo .
    define input  parameter p-nozzle-code like ub.nozzle-attr.nozzle-code   no-undo .
    define output parameter p-value    like ub.nozzle-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .

    define buffer buf_nozzle-attr for ub.nozzle-attr .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run nzzlattr-name in this-procedure
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

    find first buf_nozzle-attr no-lock where
               buf_nozzle-attr.obj-type  = p-obj-type
           AND buf_nozzle-attr.obj-code  = p-obj-code
           AND buf_nozzle-attr.nozzle-code  = p-nozzle-code
           AND buf_nozzle-attr.attr-code = p-code
      no-error .
    if avail buf_nozzle-attr then do:
      assign
        p-value =  buf_nozzle-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.


procedure nzzlattr-write :

  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.nozzle-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.nozzle-attr.obj-code   no-undo .
    define input parameter p-nozzle-code like ub.nozzle-attr.nozzle-code   no-undo .
    define input parameter p-code     like ub.nozzle-attr.attr-code  no-undo .
    define input parameter p-value    like ub.nozzle-attr.attr-value no-undo .

    define buffer buf_nozzle-attr for ub.nozzle-attr .
    define buffer lock_nzzl-attr for ub.nozzle-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run nzzlattr-name in this-procedure
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
    find first buf_nozzle-attr exclusive-lock where
               buf_nozzle-attr.obj-type  = p-obj-type
           AND buf_nozzle-attr.obj-code  = p-obj-code
           AND buf_nozzle-attr.nozzle-code  = p-nozzle-code
           AND buf_nozzle-attr.attr-code = p-code no-error .
    if not available buf_nozzle-attr then do:
      create buf_nozzle-attr .
      assign
        buf_nozzle-attr.nozzle-code  = p-nozzle-code
        buf_nozzle-attr.obj-type  = p-obj-type
        buf_nozzle-attr.obj-code  = p-obj-code
        buf_nozzle-attr.attr-code = p-code
        buf_nozzle-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_nozzle-attr.attr-value = p-value no-error.
  end.

end procedure.


procedure nzzlattr-exist :

  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.nozzle-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.nozzle-attr.obj-code   no-undo .
    define input parameter p-nozzle-code like ub.nozzle-attr.nozzle-code   no-undo .
    define input parameter p-code     like ub.nozzle-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .

    define buffer buf_nozzle-attr for ub.nozzle-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run nzzlattr-name in this-procedure
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
    find first buf_nozzle-attr no-lock where
               buf_nozzle-attr.obj-type  = p-obj-type
           AND buf_nozzle-attr.obj-code  = p-obj-code
           AND buf_nozzle-attr.nozzle-code  = p-nozzle-code
           AND buf_nozzle-attr.attr-code = p-code no-error .
    if available buf_nozzle-attr then do:
      P-EXIST = YES.
    end.
  end.

end procedure.

procedure nzzlattr-delete :

  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.nozzle-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.nozzle-attr.obj-code   no-undo .
    define input parameter p-nozzle-code like ub.nozzle-attr.nozzle-code   no-undo .
    define input parameter p-code     like ub.nozzle-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .

    define buffer buf_nozzle-attr for ub.nozzle-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run nzzlattr-name in this-procedure
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
    find first buf_nozzle-attr exclusive-lock where
               buf_nozzle-attr.obj-type  = p-obj-type
           AND buf_nozzle-attr.obj-code  = p-obj-code
           AND buf_nozzle-attr.nozzle-code  = p-nozzle-code
           AND buf_nozzle-attr.attr-code = p-code no-error .

    if not available buf_nozzle-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_nozzle-attr.
       P-DELETED = YES.
    END.
  end.

end procedure.

&if "{1}" = "interface" &then

&endif


/* $Workfile$ e n d */