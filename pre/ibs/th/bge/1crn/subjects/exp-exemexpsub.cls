using Progress.Lang.*.
using ibs.th.bge.1crn.export.send1cerpsub.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.exp-exemexpsub inherits send1cerpsub:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Пример класса выгрузки в 1с" get.
   define override public property InitSecTag as character no-undo init "test-export"
   get.
   define override public property sendTableName  as character  no-undo init ""
   get.
   method override public void CheckParam(  ):
      return.
   end method.
   method override public void CrContentToSW( input hSaxWriter as handle ):
      hSAXWriter:start-element("slips") no-error.
         hSAXWriter:insert-attribute("type",   "REQUEST")       no-error.
         hSAXWriter:insert-attribute("obj",   "ep44")       no-error.
         hSAXWriter:write-data-element ("test", params:getParamValue("test")).
         hSAXWriter:write-data-element ("test7", params:getParamValue("test7")).
         hSAXWriter:write-data-element ("test9", substitute ("&1", params:getParamValue("test9"))).
      hSAXWriter:end-element("slips") no-error.
      return.
   end method.
end class.
