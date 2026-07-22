/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение складского места для партии

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/13/06
Author: Dmitry Ukhanov
Creation date: 04/13/06

*/

/*

Входные параметры:

p-chk-and-chs   задает режим работы процедуры
                true  - проверка того, что товар резервируется по складским местам
                        и выбор складского места
                false - только проверка
p-obj-type      тип объекта
p-obj-code      код объекта
p-gds-code      уникальный код товара

Возвращаемые параметры:

p-reserv-pl-code
   true  - товар резервируется по складским местам
   false - товар не резервируется по складским местам

p-pl-code
   0 - товар не резервируется по складским местам или не выбрано складское место
   если p-pl-code <> 0 то это код складского места,
                       по которому необходимо резервировать товар

Также программа может вернуть ошибку - это означает, что необходимо отказаться от
резервирования.
В этом случае RETURN-VALUE будет содержать описание ошибки.

*/

procedure plgdsfnd :
  define input  parameter p-chk-and-chs    as logical               no-undo .
  define input  parameter p-obj-type       like ub.gds-obj.obj-type no-undo .
  define input  parameter p-obj-code       like ub.gds-obj.obj-code no-undo .
  define input  parameter p-gds-code       like ub.goods.gds-code   no-undo .
  define output parameter p-reserv-pl-code as   logical             no-undo .
  define output parameter p-pl-code        like ub.pl-gds.pl-code   no-undo .

  define buffer buf_goods         for ub.goods .
  define buffer buf_pl-gds        for ub.pl-gds .
  define buffer buf_second_pl-gds for ub.pl-gds .

  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods
  then do:
    return error "Не найден товар. Первичный бар-код " + string( p-gds-code ) .
  end.

  { gbl/gdsobjat.i
      p-obj-type
      p-obj-code
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      "'place-rsrv=request'"
      p-reserv-pl-code
      no-error
  }
  if error-status :error
  then do:
    return error substitute("Ошибка при запросе атрибута place-rsrv товара на объекте  &1 &2 " , error-status :get-message(1) , return-value  )  .
  end.

  if p-reserv-pl-code = no
  then do: /* товар не резервируется по складским местам */
    return .
  end.

  /* Если только проверка, то закончили */
  if p-chk-and-chs <> yes
  then do:
    return . /* --->>>--- */
  end.

  find first buf_pl-gds no-lock where
             buf_pl-gds.obj-type = p-obj-type and
             buf_pl-gds.obj-code = p-obj-code and
             buf_pl-gds.gds-code = p-gds-code no-error .
  if not available buf_pl-gds
  then do:
    return error "К товару не привязано ни одного места хранения" .
  end.

  /* проверяем, существует ли более чем одно складское место */
  find first buf_second_pl-gds no-lock where
             buf_second_pl-gds.obj-type  = p-obj-type          and
             buf_second_pl-gds.obj-code  = p-obj-code          and
             buf_second_pl-gds.gds-code  = p-gds-code          and
             recid( buf_second_pl-gds ) <> recid( buf_pl-gds ) no-error .
  if not available buf_second_pl-gds
  then do: /* возвращаем */
    assign
      p-pl-code = buf_pl-gds.pl-code
    .
  end.
  else do: /* существует более чем одно складское место - пользователь должен выбрать */
&if "{1}" = "no-interface" &then
    return error "Не выбрано место хранения " + {&new-line} .
&else
  &if "{1}" = ""  &then
    if not valid-handle( parparentproc )
    then do:
      return error "Не выбрано место хранения " + {&new-line} .
    end.
  &endif

    run str/plgdssel.p
      (
  &if "{1}" <> " " &then
         input {1}
  &else
         input parparentproc
  &endif
      ,  input p-obj-type
      ,  input p-obj-code
      ,  input p-gds-code
      , output p-pl-code
      ) no-error .
    if error-status :error
    then do:
      return error substitute( 'Ошибка при вызове программы &1&2&3&2&4&2'
                             , 'plgdssel.p':U
                             , {&new-line}
                             , error-status :get-message( 1 )
                             , return-value
                             ) .
    end.
    if p-pl-code = ? or
       p-pl-code = 0
    then do:
      return error "Не выбрано место хранения " + {&new-line} .
    end.
&endif
  end.
end procedure. /* plgdsfnd */

/* $Workfile$   E n d */
