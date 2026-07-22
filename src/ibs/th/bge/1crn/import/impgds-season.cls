/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс ипорта данных season из 1С

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.gbl.*.
using ibs.th.bge.1crn.subjects.*.

block-level on error undo, throw.

class ibs.th.bge.1crn.import.impgds-season implements ibs.th.bge.1crn.import.iimpsubject:
  
  { cmp/str-glbl.i class }
  
  define property Msg as character no-undo
    get. 
    set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
		
		define buffer buf_season for ub.season .
		define buffer buf_goods for ub.goods .
		define buffer buf_gds-season for ub.gds-season .
		
		define buffer buf_blob-data for ub.blob-data.
    define buffer self_blob-bind for ub.blob-bind.

    define variable objGds-season as class     gds-season no-undo.
    define variable keyrecObj as class keyrec no-undo.
    define variable keyrec as character no-undo.
    
    define variable v-dir-name as character no-undo .
    define variable v-dir1-name as character no-undo .
    define variable v-file-name as character no-undo .
    
    define variable v-param-type as character no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date as date no-undo .
    define variable v-value-decimal as decimal no-undo .
    define variable v-value-integer as INTEGER no-undo .
    define variable v-value-logical AS LOGICAL no-undo .
    define variable v-tth as handle no-undo .
    
    objGds-season = cast (subjectObj, gds-season).
    
    find first ub.clients no-lock where ub.clients.db-num   = ibs.th.gbl.gbl-var:g#db-num
                                    and ub.clients.obj-type = {&shop}
                                    and ub.clients.stts = 0  no-error.
    if not available ub.clients
    then do:
      Msg = substitute("Не найден ни один активный магазин для бд &1", ibs.th.gbl.gbl-var:g#db-num ) .
      undo, return false .
    end.
    
    delete object v-tth no-error.
    run adm/shattri.p (
           input "get":U
          ,input ub.clients.obj-type
          ,input ub.clients.obj-code
          ,input {&attr-gds-ref_obj}
          ,input {&attr-gds-ref_obj_image-dir}
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-param-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
    delete object v-tth no-error.
    if trim(v-value-character) > ""
    then do :
      v-dir1-name = trim(v-value-character, "\") .
      v-dir1-name = trim(v-dir1-name, "/") .
      v-dir1-name = v-dir1-name + "\" .
      v-dir-name = v-dir1-name + "gds\" .
    end.
    else do :
      v-dir1-name = "C:\TB-image\" .
      v-dir-name = "C:\TB-image\gds\" .
    end.

		
    if objGds-season:del-f = 1
    or objGds-season:del-l = 1
    then
    do:
      find first buf_gds-season where buf_gds-season.sea-code = integer(objGds-season:Tbg-code) 
                                 and buf_gds-season.gds-code = integer(objGds-season:gds-code) no-error .
      if AVAILABLE buf_gds-season then
      do:
        v-file-name = v-dir-name + string(buf_gds-season.gds-code) + ".png" .
        os-delete value(v-file-name) no-error .
        delete buf_gds-season .
      end.  		
    end.
    else
    do:
      find first buf_goods no-lock where buf_goods.gds-code = integer(objGds-season:gds-code) no-error .
      if not available buf_goods
      then do:
        Msg = substitute("Не найден товар с кодом &1", objGds-season:gds-code ) .
        undo, return false .
      end.
      
      find first buf_season where buf_season.sea-code = integer(objGds-season:Tbg-code) no-error .
      if AVAILABLE buf_season then 
      do:
        find first buf_gds-season where buf_gds-season.sea-code = integer(objGds-season:Tbg-code) 
                                    and buf_gds-season.gds-code = integer(objGds-season:gds-code) no-error .
        if not available buf_gds-season
        then do :
          create buf_gds-season .
          assign
            buf_gds-season.db-num   = gbl-var:g#db-num
            buf_gds-season.sea-code = integer(objGds-season:Tbg-code)
            buf_gds-season.gds-code = integer(objGds-season:gds-code)
          .
        end .  
        assign buf_gds-season.min-stock = 0 . 
        
        
        v-file-name = v-dir-name + string(buf_gds-season.gds-code) + ".png" .
        
        keyrecObj = new keyrec ().
        keyrecObj:GenKeyRec({&table_goods}, buffer buf_goods:handle, output keyrec).
        delete object keyrecObj.
        
        find first self_blob-bind  no-lock where
                self_blob-bind.uniq-key-rec = keyrec
            and self_blob-bind.field-name = {&blob-gds-collec-image}
            and self_blob-bind.part-num = 1
            no-error.
        if available self_blob-bind then do:
          find first buf_blob-data  no-lock where
                buf_blob-data.db-num = self_blob-bind.db-num
            and buf_blob-data.int64-id = self_blob-bind.int64-id no-error.                              
        end.
        if available buf_blob-data then do:
          COPY-LOB
            FROM  OBJECT buf_blob-data.bdata
            TO    FILE   v-file-name
            No-convert
            NO-ERROR .
          if error-status :error
          then do :
            os-delete value(v-file-name) .
            if os-error <> 0
            then do :
              Msg =  substitute("Не могу обновить изображение &1",v-file-name) .
              return false .
            end.
            COPY-LOB
              FROM  OBJECT buf_blob-data.bdata
              TO    FILE   v-file-name
              No-convert
              NO-ERROR .
            if error-status :error
            then do :  
              Msg =  substitute("Не могу сохранить изображение &1",v-file-name) .
              return false .
            end .  
          end .  
        end .                   
      end.                                
      else 
      do:
        Msg = "Не найдена коллекция с кодом " + objGds-season:Tbg-code .
        return false .
      end.

      return true.

    end.
  end method.

end class.