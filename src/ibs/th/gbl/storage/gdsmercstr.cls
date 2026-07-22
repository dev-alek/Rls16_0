/*

$Revision: eebbd9e2b4b7, 2528, test $
$Author: SSlivenko $
$Date: ¬т авг 04 12:57:18 2020 +0300 $
$Workfile: gdsmercstr.cls $
$Archive: ibs/th/gbl/storage/gdsmercstr.cls $

Связка товара Mercury с товаром TH 
Модуль взаимодействия сущностей TH с базой данных

Автор: Морозов Александр Сергеевич
Дата создания: 04/23/18
Author: Morozov Alexandr
Creation date: 04/23/18
 

*/

using Progress.Lang.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
block-level on error undo, throw.


class ibs.th.gbl.storage.gdsmercstr: 
  
  { cmp/str-glbl.i class }
  
  define buffer buf_gdsmerc for ub.gds-mercury.
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method private void exception( arg as handle, ingdsmercObj as class gdsmercsub, t-h as handle ):
    
    ingdsmercObj:setMsg(arg:get-message (1)).
    ingdsmercObj:setStatusErr(arg:error).
    t-h:buffer-delete () no-error.
    message "ќшибка - "  ingdsmercObj:Msg view-as alert-box.
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void insertDB( input gdsmercObj as class gdsmercsub ):
    
    create buf_gdsmerc.
    
    assign
      buf_gdsmerc.id     = next-value (s-gds-mercury-id, ub)
      buf_gdsmerc.db-num = 0
    no-error.
    if error-status:error
    then do:
      exception(error-status, gdsmercObj, buffer buf_gdsmerc:handle).
      return.
    end.
    
    setDataStorage(input gdsmercObj, buffer buf_gdsmerc).
    
    return.

  end method.
  
  method public void updateDB( input gdsmercObj as gdsmercsub  ):
    
    find first buf_gdsmerc where
      buf_gdsmerc.id     = gdsmercObj:ID and
      buf_gdsmerc.db-num = gdsmercObj:DBNum no-error.

    if not available (buf_gdsmerc)
    then do:
      exception(error-status, gdsmercObj, buffer buf_gdsmerc:handle).
      return.
    end.
    setDataStorage(input gdsmercObj, buffer buf_gdsmerc).
    release buf_gdsmerc.
    return.

  end method.
  
  method public void deleteDB( input gdsmercObj as gdsmercsub  ):
    
    find first buf_gdsmerc where
      buf_gdsmerc.id     = gdsmercObj:ID and
      buf_gdsmerc.db-num = gdsmercObj:DBNum no-error.

    if not available (buf_gdsmerc)
    then do:
      exception(error-status, gdsmercObj, buffer buf_gdsmerc:handle).
      return.
    end.
    
    delete buf_gdsmerc.
    return.

  end method.
  
  method public class gdsmercsubs getgdsmercs (input inGdsCode as integer ):
    
    define variable gdsmercsObj as class gdsmercsubs no-undo .
    gdsmercsObj = new gdsmercsubs ().
    for each buf_gdsmerc where buf_gdsmerc.gds-code = inGdsCode:
      gdsmercsObj:AddItem(getDataStorage (buffer buf_gdsmerc)).
    end. 
    return gdsmercsObj.
    
  end method.
  
    method public class gdsmercsubs getguidmercs (input inGUID as character ):
    
    define variable gdsmercsObj as class gdsmercsubs no-undo .
    gdsmercsObj = new gdsmercsubs ().
    for each buf_gdsmerc where buf_gdsmerc.GUID = inGUID:
      gdsmercsObj:AddItem(getDataStorage (buffer buf_gdsmerc)).
    end. 
    return gdsmercsObj.
    
  end method.
  
  method private void setDataStorage (input ingdsmercObj as class gdsmercsub, buffer inbf_gdsmerc for ub.gds-mercury ):
    
    inbf_gdsmerc.UUID         = ingdsmercObj:UUID.
    inbf_gdsmerc.gds-code     = ingdsmercObj:GdsCode.
    inbf_gdsmerc.cr-date      = ingdsmercObj:DateCr.
    inbf_gdsmerc.update-date  = ingdsmercObj:DateUpdate.           
    inbf_gdsmerc.merc-name    = ingdsmercObj:MercName.
    inbf_gdsmerc.GUID         = ingdsmercObj:GUID_.
    inbf_gdsmerc.GUID-subtype = ingdsmercObj:GUIDSubType.
    inbf_gdsmerc.GUID-type    = ingdsmercObj:GUIDType.
    inbf_gdsmerc.prod-type    = ingdsmercObj:ProdType.

    release inbf_gdsmerc.
    
  end.
  
  method private class gdsmercsub getDataStorage ( buffer inbf_gdsmerc for ub.gds-mercury ):
    
    define variable gdsmercObj  as class gdsmercsub no-undo .
      
    gdsmercObj = new gdsmercsub ().
    
    assign
      gdsmercObj:ID          = inbf_gdsmerc.id
      gdsmercObj:DBNum       = inbf_gdsmerc.db-num
      gdsmercObj:UUID        = inbf_gdsmerc.UUID         
      gdsmercObj:GdsCode     = inbf_gdsmerc.gds-code     
      gdsmercObj:DateCr      = inbf_gdsmerc.cr-date      
      gdsmercObj:DateUpdate  = inbf_gdsmerc.update-date  
      gdsmercObj:MercName    = inbf_gdsmerc.merc-name    
      gdsmercObj:GUID_       = inbf_gdsmerc.GUID         
      gdsmercObj:GUIDSubType = inbf_gdsmerc.GUID-subtype 
      gdsmercObj:GUIDType    = inbf_gdsmerc.GUID-type    
      gdsmercObj:ProdType    = inbf_gdsmerc.prod-type    
      .
    return gdsmercObj.
    
  end.
  

end class.