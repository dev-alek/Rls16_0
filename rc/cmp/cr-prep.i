/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формирование глобальных определений и списков

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/
&IF "{1}" = "1" &THEN
  &scop gd-name {2}
  &scop gd-value {{&lang-value}}
  &scop gd-description {{&lang-description}}
&if "{3}" = "" or "{&gd-value}" = "" &then
  &message {&gd-name}: не задано русское или {&language} значение для определения.
&endif
&if "{4}" <> "" and "{&gd-description}}" = "" &then
  &message {&gd-name}: задано русское описание и не задано {&language} описание определения.
&endif
  &glob bef-{&gd-name} {&gd-value}
  run filwrlib_append-new-line in this-procedure ( input "&global-define bef-{&gd-name} {&bef-{&gd-name}}" ).
  &glob {&gd-name} '{&bef-{&gd-name}}':U
  run filwrlib_append-new-line in this-procedure ( input "&global-define {&gd-name} '~{~&bef-{&gd-name}~}':U" ).
  &IF "{&gd-description}" <> "" &THEN
      &glob bef-{&gd-name}-full {&gd-description}
      run filwrlib_append-new-line in this-procedure ( input "&global-define bef-{&gd-name}-full {&bef-{&gd-name}-full}" ).
      &glob {&gd-name}-full '{&bef-{&gd-name}-full}':U
      run filwrlib_append-new-line in this-procedure ( input "&global-define {&gd-name}-full '~{~&bef-{&gd-name}-full~}':U" ).
  &ENDIF
&ENDIF
&IF "{1}" = "2" &THEN
    &if "{10}" <> "" and defined(bef-{10}) = 0 &then &message Ошибка при создании списка. Не определен препроцессинг для {10}
    &endif
    &if "{9}"  <> "" and defined(bef-{9})  = 0 &then &message Ошибка при создании списка. Не определен препроцессинг для {9}
    &endif
    &if "{8}"  <> "" and defined(bef-{8})  = 0 &then &message Ошибка при создании списка. Не определен препроцессинг для {8}
    &endif
    &if "{7}"  <> "" and defined(bef-{7})  = 0 &then &message Ошибка при создании списка. Не определен препроцессинг для {7}
    &endif
    &if "{6}"  <> "" and defined(bef-{6})  = 0 &then &message Ошибка при создании списка. Не определен препроцессинг для {6}
    &endif
    &if "{5}"  <> "" and defined(bef-{5})  = 0 &then &message Ошибка при создании списка. Не определен препроцессинг для {5}
    &endif
    &if "{4}"  <> "" and defined(bef-{4})  = 0 &then &message Ошибка при создании списка. Не определен препроцессинг для {4}
    &endif
    &if "{3}"  <> "" and defined(bef-{3})  = 0 &then &message Ошибка при создании списка. Не определен препроцессинг для {3}
    &endif
    &if "{2}"  <> "" and defined(bef-{2})  = 0 &then &message Ошибка при создании списка. Не определен препроцессинг для {2}
    &endif
    &IF "{10}" <> "" &THEN
        &glob {2}_{3}_{4}_{5}_{6}_{7}_{8}_{9}_{10} '~{~&bef-{2}~},~{~&bef-{3}~},~{~&bef-{4}~},~{~&bef-{5}~},~{~&bef-{6}~},~{~&bef-{7}~},~{~&bef-{8}~},~{~&bef-{9}~},~{~&bef-{10}~}':U
        run filwrlib_append-new-line in this-procedure ( input "&global-define {2}_{3}_{4}_{5}_{6}_{7}_{8}_{9}_{10} {&{2}_{3}_{4}_{5}_{6}_{7}_{8}_{9}_{10}}" ).
    &ELSEIF "{9}" <> "" &THEN
        &glob {2}_{3}_{4}_{5}_{6}_{7}_{8}_{9} '~{~&bef-{2}~},~{~&bef-{3}~},~{~&bef-{4}~},~{~&bef-{5}~},~{~&bef-{6}~},~{~&bef-{7}~},~{~&bef-{8}~},~{~&bef-{9}~}':U
        run filwrlib_append-new-line in this-procedure ( input "&global-define {2}_{3}_{4}_{5}_{6}_{7}_{8}_{9} {&{2}_{3}_{4}_{5}_{6}_{7}_{8}_{9}}" ).
    &ELSEIF "{8}" <> "" &THEN
        &glob {2}_{3}_{4}_{5}_{6}_{7}_{8} '~{~&bef-{2}~},~{~&bef-{3}~},~{~&bef-{4}~},~{~&bef-{5}~},~{~&bef-{6}~},~{~&bef-{7}~},~{~&bef-{8}~}':U
        run filwrlib_append-new-line in this-procedure ( input "&global-define {2}_{3}_{4}_{5}_{6}_{7}_{8} {&{2}_{3}_{4}_{5}_{6}_{7}_{8}}" ).
    &ELSEIF "{7}" <> "" &THEN
        &glob {2}_{3}_{4}_{5}_{6}_{7} '~{~&bef-{2}~},~{~&bef-{3}~},~{~&bef-{4}~},~{~&bef-{5}~},~{~&bef-{6}~},~{~&bef-{7}~}':U
        run filwrlib_append-new-line in this-procedure ( input "&global-define {2}_{3}_{4}_{5}_{6}_{7} {&{2}_{3}_{4}_{5}_{6}_{7}}" ).
    &ELSEIF "{6}" <> "" &THEN
        &glob {2}_{3}_{4}_{5}_{6} '~{~&bef-{2}~},~{~&bef-{3}~},~{~&bef-{4}~},~{~&bef-{5}~},~{~&bef-{6}~}':U
        run filwrlib_append-new-line in this-procedure ( input "&global-define {2}_{3}_{4}_{5}_{6} {&{2}_{3}_{4}_{5}_{6}}" ).
    &ELSEIF "{5}" <> "" &THEN
        &glob {2}_{3}_{4}_{5} '~{~&bef-{2}~},~{~&bef-{3}~},~{~&bef-{4}~},~{~&bef-{5}~}':U
        run filwrlib_append-new-line in this-procedure ( input "&global-define {2}_{3}_{4}_{5} {&{2}_{3}_{4}_{5}}" ).
    &ELSEIF "{4}" <> "" &THEN
        &glob {2}_{3}_{4} '~{~&bef-{2}~},~{~&bef-{3}~},~{~&bef-{4}~}':U
        run filwrlib_append-new-line in this-procedure ( input "&global-define {2}_{3}_{4} {&{2}_{3}_{4}}" ).
    &ELSE
        &glob {2}_{3} '~{~&bef-{2}~},~{~&bef-{3}~}':U
        run filwrlib_append-new-line in this-procedure ( input "&global-define {2}_{3} {&{2}_{3}}" ).
    &ENDIF
&ENDIF
/* $Workfile$ e n d */