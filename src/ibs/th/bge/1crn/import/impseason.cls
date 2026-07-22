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
using ibs.th.bge.1crn.subjects.*.
using ibs.th.gbl.*.

block-level on error undo, throw.

class ibs.th.bge.1crn.import.impseason implements ibs.th.bge.1crn.import.iimpsubject:
  
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
		define buffer buf_gds-season for ub.gds-season .
		define buffer buf_blob-bind for ub.blob-bind .
		
    define variable objSeason as class     season no-undo.
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
    
    define variable v-part-num as integer   no-undo .
    define variable v-blob-db-num as integer   no-undo .
    define variable v-int64-id as int64 no-undo .
    
    define variable mem1    as memptr no-undo .
    define variable v-size  as integer no-undo .
    
    find first ub.clients no-lock where ub.clients.db-num   = ibs.th.gbl.gbl-var:g#db-num
                                    and ub.clients.obj-type = {&shop}
                                    and ub.clients.stts = 0  no-error.
    if not available ub.clients
    then do:
      Msg = substitute("Не найден ни один активный магазин для бд &1", ibs.th.gbl.gbl-var:g#db-num ) .
      undo, return false .
    end.
    
    objSeason = cast (subjectObj, season).
    
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
      v-dir-name = v-dir1-name + "grp\" .
    end.
    else do :
      v-dir1-name = "C:\TB-image\" .
      v-dir-name = "C:\TB-image\grp\" .
    end.

		
    if objSeason:del-f = 1
    or objSeason:del-l = 1
    then
    do:
      find first buf_season where buf_season.sea-code = integer(objSeason:Tbg-code) no-error .
      if AVAILABLE buf_season then
      do:
        for each buf_gds-season no-lock where buf_gds-season.db-num   = buf_season.db-num
                                          and buf_gds-season.sea-code = buf_season.sea-code :
          v-file-name = v-dir1-name + "gds\" + string(buf_season.sea-code) + ".png" .
          os-delete value(v-file-name) no-error .                                 
        end.
        v-file-name = v-dir-name + string(buf_season.sea-code) + ".png" .
        os-delete value(v-file-name) no-error .
        delete buf_season .
      end.  		
    end.
    else
    do:
      find first buf_season where buf_season.sea-code = integer(objSeason:Tbg-code) no-error .
      if AVAILABLE buf_season then 
      do:
        assign
          buf_season.sea-name = objSeason:Tb-name 
          buf_season.sea-month-1 = 0
          buf_season.sea-month-2 = 0
        .
      end.                                
      else 
      do:
        create buf_season .		
        assign
          buf_season.db-num   = gbl-var:g#db-num
          buf_season.sea-code = integer(objSeason:Tbg-code)
          buf_season.sea-name = objSeason:Tb-name
          buf_season.sea-month-1 = 0
          buf_season.sea-month-2 = 0
        .
      end.
      if objSeason:Tb-image > ''
      then do :
        file-info:file-name = v-dir1-name .
        if file-info:full-pathname = ?
        then do :
          os-create-dir value(right-trim(v-dir1-name, "\")) .
          if os-error <> 0 then do:
            Msg =  substitute("Невозможно создать директорию &1 для изображений",v-dir1-name) .
            return false .
          end.
        end.
        
        file-info:file-name = v-dir-name .
        if file-info:full-pathname = ?
        then do :
          os-create-dir value(right-trim(v-dir-name, "\")) .
          if os-error <> 0 then do:
            Msg =  substitute("Невозможно создать директорию &1 для изображений",v-dir-name) .
            return false .
          end.
        end.
        
        v-file-name = v-dir-name + string(buf_season.sea-code) + ".png" .
        
        v-size = length(objSeason:Tb-image) .
        set-size(mem1) = integer(8 / 6 * v-size) + 1.
        mem1 = BASE64-DECODE(objSeason:Tb-image).
        
        copy-lob from mem1 to file v-file-name no-convert no-error .
        if error-status:error
        then do :
          os-delete value(v-file-name) .
          if os-error <> 0
          then do :
            Msg =  substitute("Не могу обновить изображение &1",v-file-name) .
            return false .
          end.
          copy-lob from mem1 to file v-file-name no-convert no-error .
          if error-status:error
          then do :
            Msg =  substitute("Не могу сохранить изображение &1",v-file-name) .
            return false .
          end.
        end .
        
        keyrecObj = new keyrec ().
        keyrecObj:GenKeyRec({&table_season}, buffer buf_season:handle, output keyrec).
        delete object keyrecObj.
        
        find first buf_blob-bind exclusive-lock where buf_blob-bind.uniq-key-rec = keyrec
                                                  and buf_blob-bind.field-name_  = {&blob-collec-image}
                                                  no-error .
        if available buf_blob-bind
        then do :
          v-blob-db-num = buf_blob-bind.db-num .
          v-int64-id = buf_blob-bind.int64-id .
          v-part-num = buf_blob-bind.part-num .
    
          run gbl/file2blb.p ( input {&update}
                              ,input  "override"
                              ,input (buffer buf_season:handle)
                              ,input keyrec
                              ,input {&blob-collec-image} /*p-field-*/
                              ,input {&blob-collec-image}
                              ,input-output v-part-num
                              ,input {&lob-res-data} /*p-resource-type*/
                              ,input-output v-blob-db-num
                              ,input-output v-int64-id
                              ,input v-file-name
                              ) no-error .
          if error-status :error then do:
            Msg = substitute("Не могу обновить изображение &1 в базe",v-file-name) .
            return false .
          end.
        end.
        else do :
          v-blob-db-num = ? .
          v-int64-id = 0 .
    
          run gbl/file2blb.p ( input {&add-def}
                              ,input  "yes"
                              ,input (buffer buf_season:handle)
                              ,input keyrec
                              ,input {&blob-collec-image} /*p-field-*/
                              ,input {&blob-collec-image}
                              ,input-output v-part-num
                              ,input {&lob-res-data} /*p-resource-type*/
                              ,input-output v-blob-db-num
                              ,input-output v-int64-id
                              ,input v-file-name
                              ) no-error .
          if error-status :error then do:
            Msg = substitute("Не могу сохранить изображение &1 в базу",v-file-name) .
            return false .
          end.
        end.
        
      end .
    end.
    
    return true.
  end method.

end class.