using Progress.Lang.*.
using ibs.th.gbl.TypeMap.
using ibs.th.gbl.propmap.
block-level on error undo, throw.
class ibs.th.skt.Commands.ICommandStatus inherits TypeMap:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Статусы обработки запросов в сокет" get.
  define public property  GetCommand          as class propmap no-undo get.  protected set.
  define public property  WriteStatusAndWait  as class propmap no-undo get.  protected set.
  define public property  WaitResult          as class propmap no-undo get.  protected set.
  define public property  WriteResponse       as class propmap no-undo get.  protected set.
  define public property  ReciveCommand       as class propmap no-undo get.  protected set.
   constructor public ICommandStatus (  ):
      super ().
      GetCommand         = crProp(1,"GetCommand"        ,"Получена комманда").
      WriteStatusAndWait = crProp(2,"WriteStatusAndWait","Ожидает вывода статуса послечего перейдет в режим ожидания завершения").
      WaitResult         = crProp(3,"WaitResult"        ,"Ожидает завершения").
      WriteResponse      = crProp(4,"WriteResponse"     ,"ОТвет сформироваан и должен быть записан в сокет").
      ReciveCommand      = crProp(5,"ReciveCommand"     ,"Результат отправлен").
   end constructor.
end class.
