block-level on error undo, throw.
/*

$Revision: f0ffd58b8bac, 1562, rls $
$Author: SMMolotkov $
$Date: Tue Nov 06 04:41:34 2018 +0300 $
$Workfile: oxml-ini.p $
$Archive: bge/oxml-ini.p $

Инициализация глобальных переменных системы OpenXML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/17/08
Author: Bakhtadze Natalya
Creation date: 02/17/08

*/

/*
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
В ЭТОМ ФАЙЛЕ НЕДОПУСТИМО ИСПОЛЬЗОВАТЬ ССЫЛКИ НА КАКУЮ-ЛИБО БАЗУ ДАННЫХ
Т.Е. ЭТОТ ФАЙЛ ДОЛЖЕН КОМПИЛЛИРОВАТЬСЯ БЕЗ БД
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*/

define variable vss-revision    as character no-undo init "$Revision: f0ffd58b8bac, 1562, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Nov 06 04:41:34 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: oxml-ini.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/oxml-ini.p $":U .
define variable vss-description as character no-undo init "Инициализация глобальных переменных системы OpenXML".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/ini-lib.i }
{ bge/oxml-def.i }

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
    oxml-exch-dir = ibs.th.gbl.gbl-inipar:oxmlExchDir .
    oxml-heap-dir = ibs.th.gbl.gbl-inipar:oxmlDir .
    if oxml-exch-dir = ? then
      v-str-err = v-str-err + substitute( "Отсутствует настройка каталога OpenXML (oxml-exch-dir).&1", {&new-line} ) .
    else if oxml-heap-dir = ? then
      v-str-err = v-str-err + substitute( "Отсутствует настройка каталога OpenXML (oxml-dir).&1", {&new-line} ) .
    else if oxml-exch-dir = oxml-heap-dir then do:
      v-str-err = v-str-err +
      substitute("Каталог EXCH (&2)&1" +
                 "и каталог HEAP (&3)&1" +
                 "должны быть различными.&1"  +
                 "Совпадение каталогов EXCH и HEAP нарушит работу системы OXML!"
                 , {&New-line}
                 , ibs.th.gbl.gbl-inipar:oxmlExchDirKeyName
                 , ibs.th.gbl.gbl-inipar:oxmlDirKeyName).
    end.
    else do:
      file-info:file-name = oxml-exch-dir .
      if file-info:file-type = ? or not ( file-info:file-type begins "D":U ) then assign
        v-str-err = v-str-err + substitute( "Каталог &1 отсутствует.&2", oxml-exch-dir, {&new-line} )
      .
      else assign
        oxml-exch-dir = file-info:full-pathname
      .
      
      file-info:file-name = oxml-heap-dir .
      if file-info:file-type = ? or not ( file-info:file-type begins "D":U ) then assign
        v-str-err = v-str-err + substitute( "Каталог &1 отсутствует.&2", oxml-heap-dir, {&new-line} )
      .
      else assign
        oxml-heap-dir = file-info:full-pathname
        log-file-name = oxml-heap-dir + {&back-slash-char} + "openxml.log"
      .
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
        run bge/oxml-prp.w no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Ошибка при вызове процедуры настройки OpenXML" ) skip
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