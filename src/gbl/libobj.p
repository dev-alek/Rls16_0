block-level on error undo, throw.


/*

$Revision: 47c30cad4995, 3593, rls $
$Author: DRuban $
$Date: 2023/12/28 12:56:36 $
$Workfile: libobj.p $
$Archive: gbl/libobj.p $

Запрос глобального/синглтон объека objserv

Автор: Морозов Александр Сергеевич
Дата создания: 09/02/2020
Author: Alexandr Morozov
Creation date: 09/02/2020


*/

using ibs.th.gbl.sys.objsrv.


define variable ObjSrv as class objsrv no-undo.
define new global shared variable g#libobj  as handle no-undo .
procedure GetObjServ:
  define input-output parameter objServ as class objsrv no-undo.
  if not valid-object (ObjSrv)
  then do:
    ObjSrv = new objsrv().
    ObjSrv:Initialization().
  end.
  else do:
     { gbl/objserref.i &checkupd = yes }
  end.
  objServ = ObjSrv.
end.

on delete of this-procedure do:
  if valid-object (ObjSrv)
    then delete object ObjSrv.
  assign
    g#libobj = ?
  .
end.

main:
do:
  if valid-handle (g#libobj)
  and g#libobj <> this-procedure :handle
  then do:
    message
/*      vss-workfile vss-revision vss-description skip*/
      "Попытка повторной загрузки библиотеки" skip
      g#libobj skip
      g#libobj :type skip
      g#libobj :file-name skip
      valid-handle(g#libobj) skip
      this-procedure :handle skip
      this-procedure :type skip
      this-procedure :file-name skip
      valid-handle(this-procedure) skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  else do:
    assign
      g#libobj = this-procedure :handle
    .
  end.

  if this-procedure :persistent <> true
  then do:
    message
/*      vss-workfile vss-revision vss-description skip*/
      "Ошибка запуска библиотеки" program-name(1) skip
      "Попытка запустить ее как обычную процедуру" skip
      view-as alert-box error .
  end.
  
end.
