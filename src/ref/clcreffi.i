/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с вычисляемыеми полями в gdsreffi

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

требует library.i и v-curr-r-b

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop bef-cf-last-pcnt-gds-obj last-pcnt
&glob cf-last-pcnt-gds-obj '{&bef-cf-last-pcnt-gds-obj}':U
&glob type-cf-last-pcnt-gds-obj {&type-dec}
&glob format-cf-last-pcnt-gds-obj  "->>>,>>9.9%"
&glob label-cf-last-pcnt-gds-obj   "Торговая наценка"
&glob tooltip-cf-last-pcnt-gds-obj   "Наценка относительно последней приходной цены"
&glob user-can-edit-cf-last-pcnt-gds-obj  true
&glob output-display-cf-last-pcnt-gds-obj  true
&glob other-cf-last-pcnt-gds-obj  "spr=last-pcnt-gds-obj"

/* ------------------------------------------------------------------- */
/* сюда добавлять новые выичсляемые поля */
/* ------------------------------------------------------------------- */

&glob cf-list '{&bef-cf-last-pcnt-gds-obj}':u

&scop cf-temp-code ~
  when ~{&~{&cf-code~}~} then do: ~
    assign ~
    p-tooltip = ~{&tooltip-~{&cf-code~}~} ~
    p-label = ~{&label-~{&cf-code~}~} . ~
  end.

&scop cf-temp-full-code ~
  when ~{&~{&cf-code~}~} then do: ~
    assign ~
    p-label = ~{&label-~{&cf-code~}~} ~
    p-type = ~{&type-~{&cf-code~}~}  ~
    p-format = ~{&format-~{&cf-code~}~} ~
    p-label = ~{&label-~{&cf-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&cf-code~}~} ~
    p-output-display = ~{&output-display-~{&cf-code~}~} ~
    p-other = ~{&other-~{&cf-code~}~}  ~
    . ~
  end.



/*-----------------------------------------------------------------------------------------------------------------------*/
procedure cf-name :
/*-----------------------------------------------------------------------------------------------------------------------*/
do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код вычисляемого поля */
  define output parameter p-type           as character no-undo . /* тип вычисляемого пол  */
  define output parameter p-format         as character no-undo . /* формат вычисляемого пол */
  define output parameter p-label          as character no-undo . /* лабел вычисляемого пол  */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */
    case p-code :
      &scop cf-code cf-last-pcnt-gds-obj
      {&cf-temp-full-code}

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестное вычисляемое поле" + " " + p-code .
      end.
    end.
  end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure cf-tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      &scop cf-code cf-last-pcnt-gds-obj
      {&cf-temp-code}

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "Неизвестное вычисляемое поле" + " " + p-code .
      end.
    end.
  end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure cf-value :
/*-----------------------------------------------------------------------------------------------------------------------*/

 do
  on error undo, return error
  :
    define input  parameter p-code         as character no-undo .
    define input  parameter p-input-value as character no-undo .
    define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .

    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    def var v-proc           as logical   no-undo .
    def var jj               as integer   no-undo .

    run cf-name in this-procedure
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

    do jj = 1 to num-entries(v-other, {&slash-char}):
        if entry(1, entry(jj, v-other, {&slash-char}), "=":U) = "spr":U then do:
          assign
          v-proc = yes
          .
        end.
    end.
    assign
    jj = jj - 1
    .
    if v-proc then dO:
        run  value(
                string(entry(2, entry(jj, v-other, {&slash-char}), "=":U)))
                in this-procedure (
                                    input p-input-value
                                   ,input v-format
                                   ,output p-value) no-error .
        if error-status:error then return error return-value.
    end.

  end.

end procedure.



/*процедуры расчета значение добавлять сюда*/


procedure last-pcnt-gds-obj :
define input parameter p-input-value as character no-undo .
define input parameter p-format as character no-undo .
define output parameter p-output-value as character no-undo .

DEFINE VARIABLE v-gds-code like ub.gds-obj.gds-code no-undo .
DEFINE VARIABLE v-obj-type like ub.gds-obj.obj-type no-undo .
DEFINE VARIABLE v-obj-code like ub.gds-obj.obj-code no-undo .
DEFINE VARIABLE v-value    as decimal no-undo .

define buffer buf_gds-obj for ub.gds-obj.


  do
  on error undo, return error
  :

    assign
    v-gds-code = integer(entry(1, p-input-value, {&delim-par}))
    v-obj-type = entry(2, p-input-value, {&delim-par})
    v-obj-code = integer(entry(3, p-input-value, {&delim-par}))
    .
    find first buf_gds-obj no-lock where
               buf_gds-obj.gds-code = v-gds-code
          AND  buf_gds-obj.obj-type = v-obj-type
          AND  buf_gds-obj.obj-code = v-obj-code no-error .
    if available buf_gds-obj then do:
      assign
      v-value =
                (buf_gds-obj.price-sale / (if v-curr-r-b = {&r-b-base}
                                          then buf_gds-obj.last-base
                                          else buf_gds-obj.last-rubl)
                  * 100 - 100)
      p-output-value = if v-value = ?
                        then {&question-mark}
                        else string(v-value, p-format)
                        no-error
      .
    end.
    else do:
      p-output-value = {&question-mark}
      .
    end.
  end.

end procedure. /* past-pcnt-gds-obj */


/* $Workfile$ e n d */