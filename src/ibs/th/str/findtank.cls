/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обёртка для использования процедур из str/findtank.i в классах 

Автор: Молотков Сергей Михайлович
Дата создания: 10/11/17
Author: Molotkov Sergey
Creation date: 10/11/17

*/

using Progress.Lang.*.


class ibs.th.str.findtank: 

  
  define property ReturnMsg as character no-undo
    get.
    private set.

  define variable hndl-proc-key-rec as handle no-undo.
 
  constructor public findtank ():
    run str/findtank.p persistent set hndl-proc-key-rec .
  end constructor.
  
  destructor public findtank ():
    delete object hndl-proc-key-rec .
  end destructor.

  /*
     Вызовы процедур из findtank.i реализуются по мере потребности.
     Пожалуйста добавляйте сюда новые вызовы, если их ещё не реализовали.
     Кто реализует последний вызов - сотрите этот комментарий.
     Перечень процедур findtank.i:
     *findtank
     find-nzl
     find-nzl-without-pl
  */
  
  method public void findtank_ (
    input p-obj-type     as character,
    input p-obj-code     as integer,
    input p-pump-code    as integer,
    input p-nozzle-code  as integer,
    input p-from-pl-code as integer,
    input p-gds-code     as integer,
   output p-pl-code      as integer ):
    run findtank in hndl-proc-key-rec
      (input p-obj-type
      ,input p-obj-code
      ,input p-pump-code
      ,input p-nozzle-code
      ,input p-from-pl-code
      ,input p-gds-code
      ,output p-pl-code
      ) .
  end method. /* end_of findtank */


end class.
