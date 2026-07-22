block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: os-errnm.p $
$Archive: gbl/os-errnm.p $

Строковые значения ошибок OS

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/10/05
Author: Bakhtadze Natalya
Creation date: 06/10/05

*/

define input parameter p-os-err-number as integer no-undo .
define output parameter p-os-err-name as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: os-errnm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/os-errnm.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
CASE p-os-err-number:
  when 0 then do:
    /*0 No error*/
    p-os-err-name = '':U.
  end.
  when 1 then do:
    /*1 Not owner*/
    p-os-err-name =  "Вы не имеет соответствующих прав на файл или директорию".
  end.
  when 2 then do:
    /*2 No such file or directory*/
    p-os-err-name =  "Нет такого файла или директории".
  end.
  when 3 then do:
    /*3 Interrupted system call*/
    p-os-err-name =  "Неверный системный вызов".
  end.
  when 4 then do:
    /*4 I/O error*/
    p-os-err-name = "Ошибка ввода/вывода".
  end.
  when 5 then do:
    /*5 Bad file number*/
    p-os-err-name = "Неверный номер файла".
  end.
  when 6 then do:
    /*6 No more processes*/
    p-os-err-name = "Нет свободных процессов".
  end.
  when 7 then do:
    /*7 Not enough core memory*/
    p-os-err-name = "Нет свободной памяти".
  end.
  when 8 then do:
    /*8 Permission denied    */
    p-os-err-name = "В доступе отказано".
  end.
  when 9 then do:
    /*9 Bad address    */
    p-os-err-name = "Неверный адрес".
  end.
  when 10 then do:
    /*10  File exists    */
    p-os-err-name = "Уже есть файл с таким именем".
  end.
  when 11 then do:
    /*11  No such device    */
    p-os-err-name = "Неверное устройство".
  end.
  when 12 then do:
    /*12  Not a directory    */
    p-os-err-name = "Указана не директория (а файл)".
  end.
  when 13 then do:
    /*13  Is a directory    */
    p-os-err-name = "Указана директория (а не файл)".
  end.
  when 14 then do:
    /*14  File table overflow*/
    p-os-err-name = "Переполнение таблицы файлов".
  end.
  when 15 then do:
    /*15  Too many open files*/
    p-os-err-name = "Слишком много открытых файлов".
  end.
  when 16 then do:
    /*16  File too large*/
    p-os-err-name = "Слишком длинный файл".
  end.
  when 17 then do:
    /*17 No space left on device*/
    p-os-err-name = "Нет свободного места на диске".
  end.
  when 18 then do:
    /*18  Directory not empty*/
    p-os-err-name = "Директория не пуста".
  end.
  when 999 then do:
    /*999 Unmapped error (Progress default)*/
    p-os-err-name = "Неизвестная ошибка операционной системы".
  end.
  otherwise do:
    p-os-err-name = substitute("Ошибка Операционной системы #&1", OS-ERROR).
  end.
END CASE.