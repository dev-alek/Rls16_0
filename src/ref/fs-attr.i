/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Атрибуты ПЛАТЕЖА и УДАЛЕННОГО ПЛАТЕЖА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/09/04
Author: Bakhtadze Natalya
Creation date: 12/09/04

АТРИБУТЫ ОДИНАКОВЫЕ ПРОЦЕДУРЫ РАЗНЫЕ

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&glob fs-attr-list '':u

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

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.



procedure fs-attr-code :

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
        undo, return error "неизвестный атрибут выписки" + " " + p-code .
      end.
    end.
  end.
end procedure.

procedure fs-attr-tooltip :

  do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут выписки" + " " + p-code .
      end.
    end.
  end.

end procedure.


procedure fin-statement-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-statement-attr.host-code  no-undo .
define input parameter p-sttm-code  like ub.fin-statement-attr.sttm-code   no-undo .
define input parameter p-attr-code     like ub.fin-statement-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-statement-attr.attr-value no-undo .

define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-statement-attr for ub.fin-statement-attr.

run fs-attr-code in this-procedure
                                  (input  p-attr-code           /* p-code           */
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



find first buf_fin-statement-attr  exclusive-lock  where
          buf_fin-statement-attr.attr-code    = p-attr-code
      AND buf_fin-statement-attr.host-code    = p-host-code
      AND buf_fin-statement-attr.sttm-code     = p-sttm-code  no-error .
  if not available  buf_fin-statement-attr then do:
      create buf_fin-statement-attr.
      assign
      buf_fin-statement-attr.attr-code    = p-attr-code
      buf_fin-statement-attr.attr-value   = p-attr-value
      buf_fin-statement-attr.host-code    = p-host-code
      buf_fin-statement-attr.sttm-code     = p-sttm-code
      .

  end.
  else do:
        buf_fin-statement-attr.attr-value   = p-attr-value .
  end.
 end. /* do */
end procedure. /* fin-statement-attr-write */


procedure fs-attr-exist :

  do
  on error undo, return error
  :
    define input parameter p-host-code     like ub.fin-statement-attr.host-code  no-undo .
    define input parameter p-sttm-code  like ub.fin-statement-attr.sttm-code   no-undo .
    define input parameter p-code          like ub.fin-statement-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .

    define buffer buf_fin-statement-attr for {&db-name}.fin-statement-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run fs-attr-code in this-procedure
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

    find first buf_fin-statement-attr exclusive-lock
      where buf_fin-statement-attr.host-code  = p-host-code
        and buf_fin-statement-attr.sttm-code  = p-sttm-code
        and buf_fin-statement-attr.attr-code = p-code
      no-error .

    if  available buf_fin-statement-attr then do:
      p-exist = yes.
    end.
  end.

end procedure.



procedure fs-attr-delete :
  do
  on error undo, return error
  :
  define input parameter p-host-code     like ub.fin-statement-attr.host-code  no-undo .
  define input parameter p-sttm-code  like ub.fin-statement-attr.sttm-code   no-undo .
  define input parameter p-code          like ub.fin-statement-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.

    define buffer buf_fin-statement-attr for {&db-name}.fin-statement-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run fs-attr-code in this-procedure
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
    find first buf_fin-statement-attr exclusive-lock
      where buf_fin-statement-attr.host-code  = p-host-code
        and buf_fin-statement-attr.sttm-code  = p-sttm-code
        and buf_fin-statement-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_fin-statement-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_fin-statement-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.

end procedure.



procedure fin-statement-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-statement-attr.host-code    no-undo .
define input  parameter p-sttm-code like ub.fin-statement-attr.sttm-code     no-undo .
define input  parameter p-attr-code    like ub.fin-statement-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-statement-attr.attr-value   no-undo .

define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-statement-attr for ub.fin-statement-attr.

run fs-attr-code in this-procedure
  (input  p-attr-code       /* p-code           */
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

find first buf_fin-statement-attr no-lock where
          buf_fin-statement-attr.attr-code    = p-attr-code
      AND buf_fin-statement-attr.host-code     = p-host-code
      AND buf_fin-statement-attr.sttm-code = p-sttm-code      no-error .
  if available  buf_fin-statement-attr then do:
    assign
    p-attr-value = buf_fin-statement-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.


 end. /* do */
end procedure. /* fin-statement-attr-value */

procedure fs-attr-news :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    case p-code :
      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестный атрибут выписки " + " " + p-code .
      end.
    end.
  end.
end procedure.

/*для таблиц истории процедуры написаны например с тем чтобы ставить атрибут выгрузки на удаленные платежи*/

procedure c-fin-statement-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.c-fin-statement-attr.host-code  no-undo .
define input parameter p-sttm-code  like ub.c-fin-statement-attr.sttm-code   no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-statement-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-statement-attr.chip-num   no-undo .
define input parameter p-attr-code     like ub.c-fin-statement-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.c-fin-statement-attr.attr-value no-undo .

define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-statement-attr for ub.c-fin-statement-attr.

run fs-attr-code in this-procedure
                                  (input  p-attr-code           /* p-code           */
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



find first buf_c-fin-statement-attr  exclusive-lock  where
          buf_c-fin-statement-attr.attr-code    = p-attr-code
      AND buf_c-fin-statement-attr.host-code    = p-host-code
      AND buf_c-fin-statement-attr.sttm-code     = p-sttm-code
      AND buf_c-fin-statement-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-statement-attr.chip-num         = p-chip-num      no-error .
  if not available  buf_c-fin-statement-attr then do:
      create buf_c-fin-statement-attr.
      assign
      buf_c-fin-statement-attr.attr-code    = p-attr-code
      buf_c-fin-statement-attr.attr-value   = p-attr-value
      buf_c-fin-statement-attr.host-code    = p-host-code
      buf_c-fin-statement-attr.sttm-code     = p-sttm-code
      .

  end.
  else do:
        buf_c-fin-statement-attr.attr-value   = p-attr-value .
  end.
 end. /* do */
end procedure. /* c-fin-statement-attr-write */



procedure c-fin-statement-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-statement-attr.host-code    no-undo .
define input  parameter p-sttm-code like ub.c-fin-statement-attr.sttm-code     no-undo .
define input parameter  p-corr-user-db-num  like ub.c-fin-statement-attr.corr-user-db-num   no-undo .
define input parameter  p-chip-num      like ub.c-fin-statement-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-statement-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-statement-attr.attr-value   no-undo .

define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-statement-attr for ub.c-fin-statement-attr.

run fs-attr-code in this-procedure
  (input  p-attr-code       /* p-code           */
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

find first buf_c-fin-statement-attr no-lock where
          buf_c-fin-statement-attr.attr-code    = p-attr-code
      AND buf_c-fin-statement-attr.sttm-code      = p-sttm-code
      AND buf_c-fin-statement-attr.host-code      = p-host-code
      AND buf_c-fin-statement-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-statement-attr.chip-num         = p-chip-num      no-error .

  if available  buf_c-fin-statement-attr then do:
    assign
    p-attr-value = buf_c-fin-statement-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.


 end. /* do */
end procedure. /* c-fin-statement-attr-value */



/* $Workfile$ e n d */