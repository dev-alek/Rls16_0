/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ѕиблиотека дл€ работы с атрибутами внешнего артикула

јвтор: ’ныкин ѕавел јндреевич
ƒата создани€: 02/28/06
Author: Pavel Khnykin
Creation date: 02/28/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character no-undo format "x(65)":U initial "@(#)$Workfile$ $Revision$":U.

/* атрибуты --------------------------------------- */

&scop bef-attr-alcohol-prod alcohol-prod
&glob attr-alcohol-prod '{&bef-attr-alcohol-prod}':U
&glob type-attr-alcohol-prod {&type-log}
&glob format-attr-alcohol-prod  "+/ "
&glob label-attr-alcohol-prod   "јлкогольна€ продукци€"
&glob tooltip-attr-alcohol-prod   "јлкогольна€ продукци€"
&glob user-can-edit-attr-alcohol-prod  true
&glob output-display-attr-alcohol-prod  true
&glob other-attr-alcohol-prod  ""
&glob news-attr-alcohol-prod true
&glob copy-attr-alcohol-prod  true


/* ------------------------------------------------------------------- */
/* сюда добавл€ть новые параметры */
/* ------------------------------------------------------------------- */

&glob ext-artic-attr-list '{&bef-attr-alcohol-prod}':U

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

&scop attr-copy-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-copy = ~{&copy-~{&attr-code~}~}. ~
  end.


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure ext-artic-attr-name :
/*-----------------------------------------------------------------------------------------------------------------------*/
do
  on error undo, return error
  :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может измен€ть в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */

  case p-code :
/*      &scop attr-code attr-alcohol-prod*/
/*      {&attr-temp-full-code}*/

      /* сюда добавл€ть новые параметры */
      otherwise do:
        undo, return error "неизвестный глобальный атрибут внешнего артикула" + " " + p-code .
      end.
  end case.
end.

end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure ext-artic-attr-tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
/*      &scop attr-code attr-alcohol-prod*/
/*      {&attr-temp-code}*/

      /* сюда добавл€ть новые параметры */
      otherwise do:
        undo, return error "Ќеизвестный глобальный атрибут внешнего артикула" + " " + p-code .
      end.
    end case.
end.
end procedure.

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure ext-artic-attr-value :
/*-----------------------------------------------------------------------------------------------------------------------*/
do
  on error undo, return error
  :

  define input  parameter p-code as character no-undo .   /* код атрибута */
  define input  parameter p-gds-code as int no-undo .        /*  gds-code */
  define input  parameter p-cli-type like ub.ext-artic-attr.cli-type no-undo .
  define input  parameter p-cli-code like ub.ext-artic-attr.cli-code no-undo .
  define output parameter p-value as character no-undo .  /* значение атрибута */
  define output parameter p-type     as character no-undo .

  define buffer buf_ext-artic-attr for ub.ext-artic-attr.

  def var v-format         as character no-undo .
  def var v-label          as character no-undo .
  def var v-user-can-edit  as logical   no-undo .
  def var v-output-display as logical   no-undo .
  def var v-other          as character no-undo .


    run ext-artic-attr-name in this-procedure
      ( input  p-code           /* p-code           */
      , output p-type           /* p-type           */
      , output v-format         /* p-format         */
      , output v-label          /* p-label          */
      , output v-user-can-edit  /* p-user-can-edit  */
      , output v-output-display /* p-output-display */
      , output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first  buf_ext-artic-attr no-lock
          where buf_ext-artic-attr.attr-code = p-code
           and  buf_ext-artic-attr.gds-code  = p-gds-code
           and  buf_ext-artic-attr.cli-type  = p-cli-type
           and  buf_ext-artic-attr.cli-code  = p-cli-code
           no-error .
   if avail buf_ext-artic-attr then do:
    assign
      p-value = buf_ext-artic-attr.attr-value
    .
   end.
   else do:
    assign
      p-value = if p-type = {&type-log} then "no":U else ""
    .
   end.
end.
end procedure.

procedure ext-artic-attr-write :

do
  on error undo, return error
  :
    define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
    define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
    define input parameter p-cli-type like ub.ext-artic-attr.cli-type no-undo .
    define input parameter p-cli-code like ub.ext-artic-attr.cli-code no-undo .
    define input parameter p-value    like ub.goods-attr.attr-value no-undo .

    define buffer buf_ext-artic-attr for ub.ext-artic-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run ext-artic-attr-name in this-procedure
      ( input  p-code           /* p-code           */
      , output v-type           /* p-type           */
      , output v-format         /* p-format         */
      , output v-label          /* p-label          */
      , output v-user-can-edit  /* p-user-can-edit  */
      , output v-output-display /* p-output-display */
      , output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_ext-artic-attr exclusive-lock
        where buf_ext-artic-attr.gds-code  = p-gds-code
          and buf_ext-artic-attr.cli-type  = p-cli-type
          and buf_ext-artic-attr.cli-code  = p-cli-code
          and buf_ext-artic-attr.attr-code = p-code
          no-error .
    if not available buf_ext-artic-attr then do:
      create buf_ext-artic-attr .
      assign
        buf_ext-artic-attr.gds-code   = p-gds-code
        buf_ext-artic-attr.cli-type   = p-cli-type
        buf_ext-artic-attr.cli-code   = p-cli-code
        buf_ext-artic-attr.attr-code  = p-code
        buf_ext-artic-attr.attr-value = p-value
      no-error
      .
    end.
    else
      assign
        buf_ext-artic-attr.attr-value = p-value
      no-error
      .

end.

end procedure.


procedure ext-artic-attr-exist :

do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
    define input parameter p-cli-type like ub.ext-artic-attr.cli-type no-undo .
    define input parameter p-cli-code like ub.ext-artic-attr.cli-code no-undo .
    define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
    define output parameter p-exist   as logical   no-undo .

    define buffer buf_ext-artic-attr for ub.ext-artic-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run ext-artic-attr-name in this-procedure
      ( input  p-code           /* p-code           */
      , output v-type           /* p-type           */
      , output v-format         /* p-format         */
      , output v-label          /* p-label          */
      , output v-user-can-edit  /* p-user-can-edit  */
      , output v-output-display /* p-output-display */
      , output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_ext-artic-attr no-lock
          where buf_ext-artic-attr.gds-code  = p-gds-code
            and buf_ext-artic-attr.cli-type  = p-cli-type
            and buf_ext-artic-attr.cli-code  = p-cli-code
            and buf_ext-artic-attr.attr-code = p-code
            no-error .
    if available buf_ext-artic-attr then do:
        assign
          p-exist  = yes
        .
    end.
end.

end procedure.

procedure ext-artic-attr-delete :

do
  on error undo, return error
  :
    define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
    define input parameter p-cli-type like ub.ext-artic-attr.cli-type no-undo .
    define input parameter p-cli-code like ub.ext-artic-attr.cli-code no-undo .
    define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical   no-undo .

    define buffer buf_ext-artic-attr for ub.ext-artic-attr .

    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .

    run ext-artic-attr-name in this-procedure
      ( input  p-code           /* p-code           */
      , output v-type           /* p-type           */
      , output v-format         /* p-format         */
      , output v-label          /* p-label          */
      , output v-user-can-edit  /* p-user-can-edit  */
      , output v-output-display /* p-output-display */
      , output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.

    find first buf_ext-artic-attr exclusive-lock
          where buf_ext-artic-attr.gds-code  = p-gds-code
            and buf_ext-artic-attr.cli-type  = p-cli-type
            and buf_ext-artic-attr.cli-code  = p-cli-code
            and buf_ext-artic-attr.attr-code = p-code
            no-error .
    if not available buf_ext-artic-attr then do:
      assign
        p-deleted = no .
      .
    end.
    else do:
      delete buf_ext-artic-attr.
      assign
        p-deleted = yes .
      .
    END.
end.

end procedure.

procedure ext-artic-attr-news :

do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    case p-code :
/*      &scop attr-code attr-alcohol-prod*/
/*      {&attr-news-code}*/

      /* сюда добавл€ть новые параметры */
      otherwise do:
        undo, return error "неизвестный глобальный атрибут внешнего артикула" + " " + p-code .
      end.
    end case.
end.
end procedure.

procedure ext-artic-attr-copy :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-copy           as logical   no-undo . /* копируетс€ при копировании товара - если включены соответ настройки */

    case p-code :
/*      &scop attr-code attr-alcohol-prod*/
/*      {&attr-copy-code}*/

      /* сюда добавл€ть новые параметры */
      otherwise do:
        undo, return error "неизвестный глобальный атрибут внешнего артикула" + " " + p-code .
      end.
    end.
  end.
end procedure.

/* $Workfile$ e n d */