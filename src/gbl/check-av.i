/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка наличия товара или бар-кода

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/03
Author: Dmitry Ukhanov
Creation date: 03/22/03

*/

procedure check-avail-artic:
  define input parameter chg-artic     like ub.goods.artic     no-undo.
  define input parameter chg-prod-type like ub.goods.prod-type no-undo.
  define input parameter chg-prod-code like ub.goods.prod-code no-undo.

  do
  on error  undo, return error
  on stop   undo, return error
  on endkey undo, return error :

    define buffer buf_goods for ub.goods .

    if not can-find( buf_goods where buf_goods.artic     = chg-artic
                                 and buf_goods.prod-type = chg-prod-type
                                 and buf_goods.prod-code = chg-prod-code
                               no-lock )
    then do:
      &if "{1}" = "nws" &then
        run write-to-log ( "Не найден товар: артикул" + {&space-char} + chg-artic + {&space-char}
                           + "производитель" + {&space-char} + chg-prod-type + {&space-char}
                           + string( chg-prod-code )
                           + {&new-line} + "Возможно этот товар был переименован."
                           + {&new-line} + "Обменяйтесь новостями и повторите прием пакета."
                         ).
      &endif
      return error.
    end.
  end.

  return.

end procedure.

procedure check-avail-gds-code:
  define input-output parameter chg-gds-code like ub.goods.gds-code no-undo.

  do
  on error  undo, return error
  on stop   undo, return error
  on endkey undo, return error :

    define buffer buf_goods for ub.goods .
    define buffer buf_route for ub.route .

    find buf_goods where buf_goods.gds-code = chg-gds-code
                  no-lock no-error.
    if not available buf_goods then do:
      do-sch:
      for each buf_route no-lock
        where buf_route.name-rec begins ("command" + {&delim-nws}
                                         + "goods" + {&delim-nws}
                                         + "ren-gds-code" + {&delim-nws}
                                         + string(chg-gds-code)
                                        )
/*      break by buf_route.tbl-ord descending*/
      on error  undo, return error
      :
        assign
          chg-gds-code = int(entry(5,buf_route.name-rec,{&delim-nws}))
          .
        leave do-sch.
      end.
    end.
  end.

  return.

end procedure.

PROCEDURE check-avail-b-code :
  define input-output parameter loc-b-code like ub.bar-code.b-code no-undo.

  do
  on error  undo, return error
  on endkey undo, return error
  on stop   undo, return error :

    define variable sought-b-code  like ub.bar-code.b-code no-undo.
    define variable bar_code      like ub.prod-bc.b-str   no-undo .
    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_prod-bc  for ub.prod-bc .

    assign sought-b-code = loc-b-code .

    find buf_bar-code where buf_bar-code.b-code = sought-b-code no-lock no-error.
    if available buf_bar-code then do:
      assign loc-b-code = buf_bar-code.b-code.
    end.
    else do : /* попробуем найти среди prod-bc */
      run gen-bc( input sought-b-code, output bar_code ).
      find first buf_prod-bc where buf_prod-bc.b-str = bar_code no-lock no-error.
      if available buf_prod-bc then do:
        assign loc-b-code = buf_prod-bc.b-code .
        /* на всякий случай проверим, вдруг есть еще один prod-bc с таким же b-str */
        find next buf_prod-bc where buf_prod-bc.b-str = bar_code no-lock no-error.
        if available buf_prod-bc then do:
          assign loc-b-code = ? .
          &if "{1}" = "nws" &then
            run write-to-log ( "Системная ошибка!!! При перепривязке к собственному коду найдено несколько Доп.БК с одинаковыми кодами" ).
          &endif
          return error.
        end.
      end.
      else do:
        assign loc-b-code = ?.
        &if "{1}" = "nws" &then
          run write-to-log ( substitute( "Системная ошибка!!! Нет собственного кода (&1), к которому можно перепривязать Доп.БК или строку переоценки", sought-b-code ) ).
        &endif
        return error.
      end.
    end.

  end.
END PROCEDURE.

/* $Workfile$ e n d */