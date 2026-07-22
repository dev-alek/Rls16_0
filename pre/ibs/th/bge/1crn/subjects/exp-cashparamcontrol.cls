using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.gbl.*.
using ibs.th.bge.1crn.export.send1cerpsub.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.exp-CashParamControl inherits send1cerpsub implements iexpsubject:
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
   define override public property vss-author      as character no-undo init "$Author:$":U get.
   define override public property vss-date        as character no-undo init "$Date:$":U get.
   define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
   define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define override public property  vss-description as character no-undo init "Выгрузка эталонных кассовых параметров" get.
      define override public property InitSecTag as character no-undo init 'Control-etalon-params':U
   get.
   define override public property sendTableName  as character  no-undo init "code"
   get.
   method override public void CheckParam(  ):
      return.
   end method.
   method override public void CrContentToSW( input insw as handle ):
      define buffer code for ub.code.
      for each code where code.parent begins "cash-param"
                      and num-entries (code.parent,chr(4)) eq 4
      no-lock:
         insw:start-element ("Control-etalon-param").
         insw:write-data-element (  "sign":U,          string(int(entry(2,Code.parent,chr(4))))).
         insw:write-data-element (  "source":U,                   entry(3,Code.parent,chr(4))      ).
         insw:write-data-element (  "section":U,                  entry(4,Code.parent,chr(4))      ).
         insw:write-data-element (  "name":U,                     Code.code                 ).
         insw:write-data-element (  "value-etalon":U,             Code.CodeValue            ).
         insw:write-data-element (  "required":U,                 string(Code.status_ + 1)  ).
         if      Code.CodeName ne ?
            and  Code.CodeName ne ?
         then
            insw:write-data-element (  "description":U,              Code.CodeName             ).
         insw:end-element("Control-etalon-param").
      end.
      return.
   end method.
end class.
