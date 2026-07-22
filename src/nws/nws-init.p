block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: nws-init.p $
$Archive: nws/nws-init.p $

инициализация глобальных переменных системы передачи новостей

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/
/*
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
В ЭТОМ ФАЙЛЕ НЕДОПУСТИМО ИСПОЛЬЗОВАТЬ ССЫЛКИ НА КАКУЮ-ЛИБО БАЗУ ДАННЫХ
Т.Е. ЭТОТ ФАЙЛ ДОЛЖЕН КОМПИЛЛИРОВАТЬСЯ БЕЗ БД
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: nws-init.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/nws-init.p $":U .
def var vss-description as character no-undo init "инициализация глобальных переменных системы передачи новостей".
{ cmp/vssrevis.i }
{ nws/nws-def.i  }

do
on error undo, return error
:
  define variable v-str-err  as character no-undo .
  define variable v-set-prop as logical no-undo .

  assign
    v-str-err = "first":U
    v-set-prop = true
  .

  do while v-str-err <> "":U
           and v-set-prop = true
  :

    assign
      v-str-err = "":U
    .
    /* дирректории в которых происходит обмен пакетами */
    get-key-value section "news"
                      key "nws-exch-dir"
                    value nws-exch-dir.
    if nws-exch-dir = ? then do:
      assign
        v-str-err = v-str-err + substitute( "Отсутствует настройка каталога СПН (nws-exch-dir).&1", {&new-line} )
      .
    end.
    else do:
      assign
        file-info:file-name = nws-exch-dir
      .
      if file-info:file-type = ?
        or not ( file-info:file-type begins "D":U )
      then do:
        assign
          v-str-err = v-str-err + substitute( "Каталог &1 отсутствует.&2", nws-exch-dir, {&new-line} )
        .
      end.
      else do:
        assign
          nws-exch-dir = file-info:full-pathname
        .
      end.
    end.
    get-key-value section "news"
                      key "nws-heap-dir"
                    value nws-heap-dir.
    if nws-heap-dir = ? then do:
      assign
        v-str-err = v-str-err + substitute( "Отсутствует настройка каталога СПН (nws-heap-dir).&1", {&new-line} )
      .
    end.
    else do:
      assign
        file-info:file-name = nws-heap-dir
      .
      if file-info:file-type = ?
        or not ( file-info:file-type begins "D":U )
      then do:
        assign
          v-str-err = v-str-err + substitute( "Каталог &1 отсутствует.&2", nws-heap-dir, {&new-line} )
        .
      end.
      else do:
        assign
          nws-heap-dir = file-info:full-pathname
          log-file-name = nws-heap-dir + {&back-slash-char} + "news.log"
        .
      end.
    end.
    assign
      v-str-err = right-trim( v-str-err, {&new-line} )
    .
    if v-str-err <> "":U then do:
      message
        substitute( "&1", v-str-err ) skip
        substitute( "Вы хотите произвести настройку сейчас?" ) skip
        view-as alert-box question buttons yes-no update v-set-prop
      .
      if v-set-prop = true then do:
        run nws/nws-prp.w no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Ошибка при вызове процедуры настройки СПН" ) skip
            return-value skip
            error-status :get-message ( error-status :num-messages )
            view-as alert-box error
          .
        end.
      end.
    end.
  end.
  if v-str-err <> "":U then do:
    return error v-str-err.
  end.
end.

/* $Workfile: nws-init.p $  end */