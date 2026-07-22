/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с атрибутами ТРК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop bef-attr-pump-net-address net-address
&glob attr-pump-net-address '{&bef-attr-pump-net-address}':U
&glob type-attr-pump-net-address {&type-char}
&glob format-attr-pump-net-address  "X(15)"
&glob label-attr-pump-net-address   "Сетевой адрес КТРК"
&glob tooltip-attr-pump-net-address   "Сетевой адрес КТРК"
&glob user-can-edit-attr-pump-net-address  false
&glob output-display-attr-pump-net-address  false
&glob other-attr-pump-net-address  ""

&scop bef-attr-pump-protocol-id protocol-id
&glob attr-pump-protocol-id '{&bef-attr-pump-protocol-id}':U
&glob type-attr-pump-protocol-id {&type-int}
&glob format-attr-pump-protocol-id  "99999"
&glob label-attr-pump-protocol-id   "Идентификатор протокола КТРК"
&glob tooltip-attr-pump-protocol-id   "Идентификатор протокола КТРК"
&glob user-can-edit-attr-pump-protocol-id  false
&glob output-display-attr-pump-protocol-id  false
&glob other-attr-pump-protocol-id  ""

&scop bef-attr-pump-UART-channel-no UART-channel-no
&glob attr-pump-UART-channel-no '{&bef-attr-pump-UART-channel-no}':U
&glob type-attr-pump-UART-channel-no {&type-int}
&glob format-attr-pump-UART-channel-no  "9"
&glob label-attr-pump-UART-channel-no   "№ канала UART"
&glob tooltip-attr-pump-UART-channel-no   "№ канала UART"
&glob user-can-edit-attr-pump-UART-channel-no  false
&glob output-display-attr-pump-UART-channel-no  false
&glob other-attr-pump-UART-channel-no  ""


&scop bef-attr-pump-no-overr-cnt-use no-overr-cnt-use
&glob attr-pump-no-overr-cnt-use '{&bef-attr-pump-no-overr-cnt-use}':U
&glob type-attr-pump-no-overr-cnt-use {&type-log}
&glob format-attr-pump-no-overr-cnt-use  "yes/no"
&glob label-attr-pump-no-overr-cnt-use   "Признак исп-я необнуляемых счетчиков"
&glob tooltip-attr-pump-no-overr-cnt-use   "Признак исп-я необнуляемых счетчиков"
&glob user-can-edit-attr-pump-no-overr-cnt-use  false
&glob output-display-attr-pump-no-overr-cnt-use  false
&glob other-attr-pump-no-overr-cnt-use  ""

&scop bef-attr-pump-tech-refuell-calc-use tech-refuell-calc-use
&glob attr-pump-tech-refuell-calc-use '{&bef-attr-pump-tech-refuell-calc-use}':U
&glob type-attr-pump-tech-refuell-calc-use {&type-log}
&glob format-attr-pump-tech-refuell-calc-use  "yes/no"
&glob label-attr-pump-tech-refuell-calc-use   "Признак расчета аварийного пролива"
&glob tooltip-attr-pump-tech-refuell-calc-use   "Признак расчета аварийного пролива"
&glob user-can-edit-attr-pump-tech-refuell-calc-use  false
&glob output-display-attr-pump-tech-refuell-calc-use  false
&glob other-attr-pump-tech-refuell-calc-use  ""

&scop bef-attr-pump-velocity-id velocity-id
&glob attr-pump-velocity-id '{&bef-attr-pump-velocity-id}':U
&glob type-attr-pump-velocity-id {&type-int}
&glob format-attr-pump-velocity-id  "99999"
&glob label-attr-pump-velocity-id   "Идентификатор скорости"
&glob tooltip-attr-pump-velocity-id   "Идентификатор скорости"
&glob user-can-edit-attr-pump-velocity-id  false
&glob output-display-attr-pump-velocity-id  false
&glob other-attr-pump-velocity-id  ""



/* ------------------------------------------------------------------- */
/* сюда добавлять новые атрибуты */
/* ------------------------------------------------------------------- */

&glob pumpattr-list '{&bef-attr-pump-net-address}~
,{&bef-attr-pump-protocol-id}~
,{&bef-attr-pump-UART-channel-no}~
,{&bef-attr-pump-no-overr-cnt-use}~
,{&bef-attr-pump-tech-refuell-calc-use}~
,{&bef-attr-pump-velocity-id velocity-id}~
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
procedure pumpattr-name :
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
      &scop attr-code attr-pump-net-address
      {&attr-temp-full-code}
      &scop attr-code attr-pump-protocol-id
      {&attr-temp-full-code}
      &scop attr-code attr-pump-UART-channel-no
      {&attr-temp-full-code}
      &scop attr-code attr-pump-no-overr-cnt-use
      {&attr-temp-full-code}
      &scop attr-code attr-pump-tech-refuell-calc-use
      {&attr-temp-full-code}
      &scop attr-code attr-pump-velocity-id
      {&attr-temp-full-code}
       /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут ТРК" + " " + p-code .
      end.
    end.
  end.
end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure pumpattr-tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      &scop attr-code attr-pump-net-address
      {&attr-temp-code}
      &scop attr-code attr-pump-protocol-id
      {&attr-temp-code}
      &scop attr-code attr-pump-UART-channel-no
      {&attr-temp-code}
      &scop attr-code attr-pump-no-overr-cnt-use
      {&attr-temp-code}
      &scop attr-code attr-pump-tech-refuell-calc-use
      {&attr-temp-code}
      &scop attr-code attr-pump-velocity-id
      {&attr-temp-code}
     /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "Неизвестный атрибут ТРК" + " " + p-code .
      end.
    end.
  end.
end procedure.


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure pumpattr-value :
/*-----------------------------------------------------------------------------------------------------------------------*/

 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.pump-attr.attr-code  no-undo .
    define input  parameter p-obj-type like ub.pump-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.pump-attr.obj-code   no-undo .
    define input  parameter p-pump-code like ub.pump-attr.pump-code   no-undo .
    define output parameter p-value    like ub.pump-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .

    define buffer buf_pump-attr for ub.pump-attr .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run pumpattr-name in this-procedure
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

    find first buf_pump-attr no-lock where
               buf_pump-attr.obj-type  = p-obj-type
           AND buf_pump-attr.obj-code  = p-obj-code
           AND buf_pump-attr.pump-code  = p-pump-code
           AND buf_pump-attr.attr-code = p-code
      no-error .
    if avail buf_pump-attr then do:
      assign
        p-value =  buf_pump-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = {&type-log} then "no":U else ""
      .
    end.
  end.

end procedure.


procedure pumpattr-write :

  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pump-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pump-attr.obj-code   no-undo .
    define input parameter p-pump-code like ub.pump-attr.pump-code   no-undo .
    define input parameter p-code     like ub.pump-attr.attr-code  no-undo .
    define input parameter p-value    like ub.pump-attr.attr-value no-undo .

    define buffer buf_pump-attr for ub.pump-attr .
    define buffer lock_pump-attr for ub.pump-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run pumpattr-name in this-procedure
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
    find first buf_pump-attr exclusive-lock where
               buf_pump-attr.obj-type  = p-obj-type
           AND buf_pump-attr.obj-code  = p-obj-code
           AND buf_pump-attr.pump-code  = p-pump-code
           AND buf_pump-attr.attr-code = p-code no-error .
    if not available buf_pump-attr then do:
      create buf_pump-attr .
      assign
        buf_pump-attr.pump-code  = p-pump-code
        buf_pump-attr.obj-type  = p-obj-type
        buf_pump-attr.obj-code  = p-obj-code
        buf_pump-attr.attr-code = p-code
        buf_pump-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_pump-attr.attr-value = p-value no-error.
  end.

end procedure.


procedure pumpattr-exist :

  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pump-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pump-attr.obj-code   no-undo .
    define input parameter p-pump-code like ub.pump-attr.pump-code   no-undo .
    define input parameter p-code     like ub.pump-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .

    define buffer buf_pump-attr for ub.pump-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run pumpattr-name in this-procedure
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

    find first buf_pump-attr no-lock where
               buf_pump-attr.obj-type  = p-obj-type
           AND buf_pump-attr.obj-code  = p-obj-code
           AND buf_pump-attr.pump-code  = p-pump-code
           AND buf_pump-attr.attr-code = p-code no-error .
    if available buf_pump-attr then do:
      P-EXIST = YES.
    end.
  end.

end procedure.

procedure pumpattr-delete :

  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pump-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pump-attr.obj-code   no-undo .
    define input parameter p-pump-code like ub.pump-attr.pump-code   no-undo .
    define input parameter p-code     like ub.pump-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .

    define buffer buf_pump-attr for ub.pump-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run pumpattr-name in this-procedure
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

    find first buf_pump-attr exclusive-lock where
               buf_pump-attr.obj-type  = p-obj-type
           AND buf_pump-attr.obj-code  = p-obj-code
           AND buf_pump-attr.pump-code  = p-pump-code
           AND buf_pump-attr.attr-code = p-code no-error .
    if not available buf_pump-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_pump-attr.
       P-DELETED = YES.
    END.
  end.

end procedure.

&if "{1}" = "interface" &then

&endif


/* $Workfile$ e n d */