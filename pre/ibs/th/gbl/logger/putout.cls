using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.gbl.logger.putout inherits ibs.th.gbl.sys.objth :
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Вывод информации в файл" get.
  define stream out.
  define private variable fileName_ as character no-undo.
  constructor public putout (inFileName as char ):
    super ().
    fileName_ = inFileName.
  end constructor.
  method public void PutMessage( inMsg as character ):
    output stream out to value(fileName_) append.
    put stream out unformatted (string(now) + ": " + inMsg) skip.
    output stream out close.
  end method.
  destructor public putout ( ):
    output stream out close.
  end destructor.
end class.
