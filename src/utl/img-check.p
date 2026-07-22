block-level on error undo, throw.
/*
$Revision: 7d87d3dadc23, 307, rls $
$Author: EShklyar $
$Date: Tue Dec 01 19:12:20 2015 +0300 $
$Workfile: img-check.p $
$Archive: utl/img-check.p $

Утилита проверки фото товаров

Автор: Шкляр Елена
Дата создания: 05/09/15
Author: Elena Shklyar
Creation date: 05/09/15
Last change: 05/09/15
*/
DEFINE INPUT PARAMETER parParentProc AS HANDLE NO-UNDO.
DEFINE var v-ask AS logical NO-UNDO.


/*DEFINE VARIABLE mOldDir       AS CHARACTER*/
/*    FORMAT "X(256)":U                     */
/*    VIEW-AS FILL-IN SIZE 75 BY 1          */
/*    LABEL "Исходная директория" NO-UNDO.  */

define variable vss-revision    as character no-undo init "$Revision: 7d87d3dadc23, 307, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:12:20 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: img-check.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/img-check.p $":U .
define variable vss-description as character no-undo init "Утилита проверки фото товаров".

{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ ref/gds-attr.i }
{ cmp/ini-lib.i }

DEFINE VARIABLE mLogical       AS LOGICAL     NO-UNDO.
DEFINE VARIABLE mLogFile       AS CHARACTER   NO-UNDO.
DEFINE STREAM mLogStr.
DEFINE STREAM mDirStr.
DEFINE STREAM mPrevDirStr.
DEFINE STREAM mGdsDirStr.
DEFINE VARIABLE mF_select_photo AS LOGICAL     NO-UNDO.
DEFINE VARIABLE vPhotoPath       AS CHARACTER   NO-UNDO.


define buffer buf_goods-attr for ub.goods-attr .
define buffer bf_goods-attr  for ub.goods-attr .


message 
"Проверка или удаление некорректных ссылок" skip
skip
"Для удаления ссылок - нажмите  ДА" skip
"Для проверки ссылок - нажмите НЕТ" skip
view-as alert-box question button yes-no update v-ask .

define variable v-attr-value      as character no-undo .
define variable ii                as integer   no-undo .
define variable v-full-path-image as character no-undo FORMAT "X(155)".
define variable fullname          as character no-undo .
define variable v-value           as character no-undo .
define variable v-delete          as character no-undo .

{ref/imagelist.i}
IF mImagePh THEN .
ELSE RETURN.

output to image-check.txt.    
/*находим товары, в которых есть атрибут*/
for each buf_goods-attr where buf_goods-attr.attr-code = "image-list" 
  and buf_goods-attr.attr-value <> "": 
  v-value = "".                        
  v-attr-value = trim (buf_goods-attr.attr-value).


  do ii = 1 to num-entries(v-attr-value):
    
    IF v-val-integer = 2 then vPhotoPath =  mImagePreDir + string(buf_goods-attr.gds-code) .
    ELSE vPhotoPath =  mImagePreDir .
        
    v-full-path-image = vPhotoPath + "\" + entry(ii, v-attr-value).

    fullname = search (v-full-path-image).
    if fullname =? then 
    do:
        put 
          buf_goods-attr.gds-code
          ';' 
          v-full-path-image
              
          skip.
    end.
    else 
    do:
      if v-ask = yes then 
      do: 
        if v-value = "" then v-value = entry(ii, v-attr-value).
        else v-value = v-value + "," + entry(ii, v-attr-value).
      end.  
    end.  

  end.
  if v-ask = yes then 
  do: 
    if v-value = "" then do:
                      RUN gds-attr-delete IN THIS-PROCEDURE (
                                                        input buf_goods-attr.gds-code
                                                        ,INPUT "image-list"
                                                        ,output v-delete ) NO-ERROR.
    end.
    else  
    RUN gds-attr-write (buf_goods-attr.gds-code, "image-list":U, v-value). 
  end.

end. 
output close . 

if v-ask = yes then do:
  message "Удаление некорректных ссылок завершено, вся информация в image-check.txt"
  view-as alert-box.
end.
else   message "Проверка некорректных ссылок завершена, вся информация в image-check.txt"
  view-as alert-box.