/*

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/08
Author: Bakhtadze Natalya
Creation date: 10/08/08

Библиотека для работы с esys-all-attr

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/08
Author: Bakhtadze Natalya
Creation date: 10/08/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* атрибуты essys-all-attr - СВАЛКА - для пакетов рутов и тю.дю--- */


&if "{1}" = "work" or "{1}" = "" or "{1}" = "interface" &then

&scop bef-attr-custom-pack-name custom-pack-name
&glob attr-custom-pack-name '{&bef-attr-custom-pack-name}':U
&glob type-attr-custom-pack-name ~{&type-char~}
&glob format-attr-custom-pack-name  "X(255)"
&glob label-attr-custom-pack-name   "Имя файла в ВС"
&glob tooltip-attr-custom-pack-name   "Имя файла в ВС"
&glob user-can-edit-attr-custom-pack-name  false
&glob output-display-attr-custom-pack-name  false
&glob other-attr-custom-pack-name  ""
&glob news-attr-custom-pack-name true
&scop manual-edit-attr-custom-pack-name 0
&scop batch-edit-attr-custom-pack-name  0


&scop bef-attr-route-custom-pack-name route-custom-pack-name
&glob attr-route-custom-pack-name '{&bef-attr-route-custom-pack-name}':U
&glob type-attr-route-custom-pack-name ~{&type-char~}
&glob format-attr-route-custom-pack-name  "X(255)"
&glob label-attr-route-custom-pack-name   "Иям файла в ВС"
&glob tooltip-attr-route-custom-pack-name   "Имя файла в ВС"
&glob user-can-edit-attr-route-custom-pack-name  false
&glob output-display-attr-route-custom-pack-name  false
&glob other-attr-route-custom-pack-name  ""
&glob news-attr-route-custom-pack-name true
&scop manual-edit-attr-route-custom-pack-name 0
&scop batch-edit-attr-route-custom-pack-name  0



/* ------------------------------------------------------------------- */
/* сюда добавлять новые параметры */
/* ------------------------------------------------------------------- */

&glob esallatr-list '{&bef-attr-custom-pack-name}~
,{&bef-attr-route-custom-pack-name}~
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

&scop attr-news-code ~
  when ~{&~{&attr-code~}~} then do: ~
    assign ~
    p-news = ~{&news-~{&attr-code~}~}. ~
  end.


/*-----------------------------------------------------------------------------------------------------------------------*/
procedure esallatr-name :
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
      &scop attr-code attr-custom-pack-name
      {&attr-temp-full-code}
      &scop attr-code attr-route-custom-pack-name
      {&attr-temp-full-code}

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code) .
      end.
    end.
  end.

end procedure.

&endif

&if  "{1}" = "" or "{1}" = "interface" &then

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure esallatr-tooltip :
/*-----------------------------------------------------------------------------------------------------------------------*/

do
  on error undo, return error
  :

    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .

    case p-code :
      &scop attr-code attr-custom-pack-name
      {&attr-temp-code}
      &scop attr-code attr-route-custom-pack-name
      {&attr-temp-code}

      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("Неизвестный атрибут ВС &1", p-code) .
      end.
    end.
  end.

end procedure.
&endif

&if "{1}" = "work" or "{1}" = "" or "{1}" = "interface" &then

/*-----------------------------------------------------------------------------------------------------------------------*/
procedure esallatr-value :
/*-----------------------------------------------------------------------------------------------------------------------*/
do
  on error undo, return error
  :

  define input  parameter p-table-name as character no-undo .
  define input  parameter p-key1     as int64 no-undo .
  define input  parameter p-key2     as int64 no-undo .
  define input  parameter p-key3     as character no-undo .
  define input  parameter p-key4     as character no-undo .
  define input  parameter p-key5     as int64 no-undo .
  define input  parameter p-key6     as int64 no-undo .
  define input  parameter p-key7     as character no-undo .
  define input  parameter p-key8     as character no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .

  define buffer buf_esys-all-attr for ub.esys-all-attr.

  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .


    run esallatr-name in this-procedure
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
    Find first  buf_esys-all-attr no-lock where
                buf_esys-all-attr.attr-code = p-code
           and  buf_esys-all-attr.table-name  = p-table-name
           and  buf_esys-all-attr.key1  = p-key1
           and  buf_esys-all-attr.key2  = p-key2
           and  buf_esys-all-attr.key3  = p-key3
           and  buf_esys-all-attr.key4  = p-key4
           and  buf_esys-all-attr.key5  = p-key5
           and  buf_esys-all-attr.key6  = p-key6
           and  buf_esys-all-attr.key7  = p-key7
           and  buf_esys-all-attr.key8  = p-key8  no-error .
   if avail buf_esys-all-attr then do:
    assign
    p-value = buf_esys-all-attr.attr-value.
   end.
   else do:
    assign
    p-value = if p-type = {&type-log} then "no":U else "".
   end.
end.
end procedure.

&endif

&if "{1}" = "" or "{1}" = "interface" &then

procedure esallatr-write :

  do
  on error undo, return error
  :
    define input  parameter p-table-name as character no-undo .
    define input  parameter p-key1     as int64 no-undo .
    define input  parameter p-key2     as int64 no-undo .
    define input  parameter p-key3     as character no-undo .
    define input  parameter p-key4     as character no-undo .
    define input  parameter p-key5     as int64 no-undo .
    define input  parameter p-key6     as int64 no-undo .
    define input  parameter p-key7     as character no-undo .
    define input  parameter p-key8     as character no-undo .
    define input  parameter p-code     as character no-undo .
    define input  parameter p-value    like ub.esys-all-attr.attr-value no-undo .

    define buffer buf_esys-all-attr for ub.esys-all-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run esallatr-name in this-procedure
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

    Find first  buf_esys-all-attr exclusive-lock where
                buf_esys-all-attr.attr-code = p-code
           and  buf_esys-all-attr.table-name  = p-table-name
           and  buf_esys-all-attr.key1  = p-key1
           and  buf_esys-all-attr.key2  = p-key2
           and  buf_esys-all-attr.key3  = p-key3
           and  buf_esys-all-attr.key4  = p-key4
           and  buf_esys-all-attr.key5  = p-key5
           and  buf_esys-all-attr.key6  = p-key6
           and  buf_esys-all-attr.key7  = p-key7
           and  buf_esys-all-attr.key8  = p-key8  no-error .
    if not available buf_esys-all-attr then do:
      assign
      buf_esys-all-attr.attr-code = p-code
      buf_esys-all-attr.table-name  = p-table-name
      buf_esys-all-attr.key1  = p-key1
      buf_esys-all-attr.key2  = p-key2
      buf_esys-all-attr.key3  = p-key3
      buf_esys-all-attr.key4  = p-key4
      buf_esys-all-attr.key5  = p-key5
      buf_esys-all-attr.key6  = p-key6
      buf_esys-all-attr.key7  = p-key7
      buf_esys-all-attr.key8  = p-key8
      buf_esys-all-attr.attr-value = p-value
      no-error.
    end.
    ELSE
    assign
    buf_esys-all-attr.attr-value = p-value no-error
    .
  end.

end procedure.


procedure esallatr-exist :

  do
  on error undo, return error
  :
    define input  parameter p-table-name as character no-undo .
    define input  parameter p-key1     as int64 no-undo .
    define input  parameter p-key2     as int64 no-undo .
    define input  parameter p-key3     as character no-undo .
    define input  parameter p-key4     as character no-undo .
    define input  parameter p-key5     as int64 no-undo .
    define input  parameter p-key6     as int64 no-undo .
    define input  parameter p-key7     as character no-undo .
    define input  parameter p-key8     as character no-undo .
    define input  parameter p-code     like ub.esys-all-attr.attr-code  no-undo .

    define output parameter p-exist   AS LOGICAL no-undo .

    define buffer buf_esys-all-attr for ub.esys-all-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run esallatr-name in this-procedure
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

    Find first  buf_esys-all-attr no-lock where
                buf_esys-all-attr.attr-code = p-code
           and  buf_esys-all-attr.table-name  = p-table-name
           and  buf_esys-all-attr.key1  = p-key1
           and  buf_esys-all-attr.key2  = p-key2
           and  buf_esys-all-attr.key3  = p-key3
           and  buf_esys-all-attr.key4  = p-key4
           and  buf_esys-all-attr.key5  = p-key5
           and  buf_esys-all-attr.key6  = p-key6
           and  buf_esys-all-attr.key7  = p-key7
           and  buf_esys-all-attr.key8  = p-key8  no-error .
    if available buf_esys-all-attr then do:
      P-EXIST = YES.
    end.
  end.

end procedure.

procedure esallatr-delete :

  do
  on error undo, return error
  :
    define input  parameter p-table-name as character no-undo .
    define input  parameter p-key1     as int64 no-undo .
    define input  parameter p-key2     as int64 no-undo .
    define input  parameter p-key3     as character no-undo .
    define input  parameter p-key4     as character no-undo .
    define input  parameter p-key5     as int64 no-undo .
    define input  parameter p-key6     as int64 no-undo .
    define input  parameter p-key7     as character no-undo .
    define input  parameter p-key8     as character no-undo .
    define input parameter  p-code     like ub.esys-all-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .

    define buffer buf_esys-all-attr for ub.esys-all-attr .

    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run esallatr-name in this-procedure
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

    Find first  buf_esys-all-attr exclusive-lock where
                buf_esys-all-attr.attr-code = p-code
           and  buf_esys-all-attr.table-name  = p-table-name
           and  buf_esys-all-attr.key1  = p-key1
           and  buf_esys-all-attr.key2  = p-key2
           and  buf_esys-all-attr.key3  = p-key3
           and  buf_esys-all-attr.key4  = p-key4
           and  buf_esys-all-attr.key5  = p-key5
           and  buf_esys-all-attr.key6  = p-key6
           and  buf_esys-all-attr.key7  = p-key7
           and  buf_esys-all-attr.key8  = p-key8  no-error .

    if not available buf_esys-all-attr then do:
      p-DELETED = NO.
    end.
    ELSE DO:
      delete buf_esys-all-attr.
      p-DELETED = YES.
    END.
  end.

end procedure.

procedure esallatr-news :

  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo . /* код атрибута */
    define output parameter p-news           as logical   no-undo . /* ходит в новости */

    case p-code :
      &scop attr-code attr-custom-pack-name
      {&attr-news-code}
      &scop attr-code attr-route-custom-pack-name
      {&attr-news-code}


      /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code ).
      end.
    end.
  end.
end procedure.


&endif

/* $Workfile$ e n d */
