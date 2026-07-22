/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт сообщения с чеком в 1С ERPRN check

Автор: Молотков Сергей Михайлович
Дата создания: 03/11/17
Author: Molotkov Sergey
Creation date: 03/11/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.bge.1crn.export.send1cerpsub.
block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.exp-edi-doc inherits send1cerpsub:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Выгрузка ЭДО в 1С" get.
 
  { cmp/str-glbl.i class }
  { utl/gtin.i class}
  { str/utd-attr.i class}
/*  { gbl/xmlchar.i }*/
 /* { str/lib-trn.i  class }
  { cmp/library.i  class }
  { ref/extclass.i }*/

  /* 16/VIII-2018 надо вокруг чеков сделать еще одну секцию с номером смены.
     Связано это с тем, что если в пакет попадает несколько раз одна и таже смена,
     1С уже не понимает какой набор чеков был последний, т.к. они все валятся в один раздел.
  */
  &scop tag-interface 'edi-docs':U
  &scop tag-edi-doc   'edi-doc':U
  &scop tag-message   'edo-doc':U
  &scop tag-section1  'gds':U
  &scop tag-item1     'gd':U
  &scop tag-section2  'marks':U
  &scop tag-item2     'mark':U
  
  define override public property InitSecTag as character no-undo init {&tag-interface}
  get.

  define override public property sendTableName  as character  no-undo init "utd"
  get.
   
   method override public void CheckParam(  ):
      if not valid-handle (oldbh)
      then
         return error "Не передан старый буфер".
      if oldbh:table ne "utd" AND oldbh:table ne "tt-utd"
      then 
         return error "Старый буфер не utd: " + oldbh:table.
      return.

   end method.

  /*------------------------------------------------------------------------------
   Purpose: выгружает несколько чеков со всеми потрохами в контекст контейнера SAX-writer
   Notes:   обязательный метод
   Param:   insw = create sax-writer
  ------------------------------------------------------------------------------*/
method override public void CrContentToSW (insw as handle):

   define variable vdb-num as integer no-undo.
   define variable vdoc-id as integer no-undo.
   define variable ii as integer no-undo .
   define variable sertif as character no-undo .
   define variable is-initial-set as logical no-undo .
   define variable VText as character no-undo.
   
    vdb-num = int(oldbh:buffer-field( "db-num":U  ):buffer-value ).
    vdoc-id = int(oldbh:buffer-field( "doc-id":U  ):buffer-value).
   find first utd where utd.db-num eq vdb-num
                    and utd.doc-id eq vdoc-id
   no-lock no-error.
 
   if available utd
   then do:
      sendOldRowid  = rowid(utd).
/*      insw:start-element ({&tag-edi-docs}) .*/
      insw:start-element ({&tag-edi-doc}) .
      
      if utd.EDocType        = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB
      then do :
        find first utd-attr no-lock where utd-attr.db-num = utd.db-num
                                      and utd-attr.doc-id = utd.doc-id
                                      and utd-attr.attr-code = "is-initial-set"
                                      no-error .
        if available utd-attr
        and logical(utd-attr.attr-value)
        then do :
          is-initial-set = yes .
          VText = "new_set" .
        end .
        else do :
          is-initial-set = no .
          VText = "set" .
        end .
        insw:write-data-element (  "edoc-id":U,      utd.DocumentNumber   ).
        insw:write-data-element (  "edoc-num":U,       utd.DocumentNumber   ).
        insw:write-data-element (  "edoc-date":U,       iso-date(utd.DocumentDate)    ).
        insw:write-data-element (  "edoc-type":U,       VText).
        insw:write-data-element (  "edoc-stts":U,       ObjSrv:Env:Utd:Sts:th:GetNameProp(utd.sts)   ).
/*        insw:write-data-element (  "comment":U,       if utd.comment = ? then "" else utd.comment   ).*/
      end .
      else do :
        insw:write-data-element (  "edoc-id":U,      if utd.DocumentExt eq "" or utd.DocumentExt eq ? then string(utd.doc-id ) else utd.DocumentExt   ).
        insw:write-data-element (  "edoc-num":U,       utd.DocumentNumber   ).
        insw:write-data-element (  "edoc-date":U,       iso-date(utd.DocumentDate)    ).
        
        VText = ObjSrv:Env:Utd:edoctype:GetNameProp(utd.EDocType).
        if VText eq ?
        then
           VText = "".
        insw:write-data-element (  "edoc-type":U,       VText).
        insw:write-data-element (  "edoc-stts":U,       ObjSrv:Env:Utd:Sts:th:GetNameProp(utd.sts)   ).
        insw:write-data-element (  "contr-code":U,       utd.CounteragentId   ).
        insw:write-data-element (  "dog-code":U,       string(utd.contract-code)   ).
        insw:write-data-element (  "orig-edoc-id":U,       utd.parentDocumentExt   ).
        insw:write-data-element (  "comment":U,       if utd.comment = ? then "" else xmlchar-encode-1c( utd.comment)   ).
        insw:write-data-element (  "sum":U,       string(utd.total)   ).
        insw:write-data-element (  "sum-nonds":U,       string(utd.total - utd.vat )    ).
        if utd.EDocType        = objSrv:Env:Utd:EDocType:returns:KeyIntDB
        then
           insw:write-data-element (  "trn-doc-code":U,      utd.doc-code ).
      end .
      find first utd-lines  where utd-lines.db-num = utd.db-num
                              and utd-lines.doc-id = utd.doc-id 
      no-lock no-error.
      if available utd-lines
      then do:
         define variable VFlagStsMark as logical no-undo.
         VFlagStsMark = yes /*utd.EDocType eq ObjSrv:Env:Utd:edoctype:Introduce:KeyIntDB*/ . /* всегда выгружаем статус марок */ 
         insw:start-element ({&tag-section1}) .
         for each utd-lines  where utd-lines.db-num = utd.db-num
                              and utd-lines.doc-id = utd.doc-id 
         no-lock:
            if utd.EDocType = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB
            and not is-initial-set
            then do :
              find first utd-marking-lines no-lock where utd-marking-lines.db-num  = utd-lines.db-num
                                                     and utd-marking-lines.doc-id  = utd-lines.doc-id
                                                     and utd-marking-lines.LineNum = utd-lines.LineNum
                                                     and utd-marking-lines.doc-level = 1 
                                                     and (utd-marking-lines.sts = 0
                                                       or utd-marking-lines.site = "only-send")
                                                     no-error .
              if not available utd-marking-lines
              then do :
                next .
              end .
            end .
            insw:start-element ({&tag-item1}) .
            if utd.EDocType = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB
            then do :
              insw:write-data-element (  "line-num",       string(utd-lines.LineNum)          ) .
              insw:write-data-element (  "gd-code",      string(utd-lines.gds-code)        ) .
              insw:write-data-element (  "price-nonds",      string(0)        ) .
              insw:write-data-element (  "qnty-ttn",   string(utd-lines.Quantity)  ) .
              insw:write-data-element (  "sum",  string(0)                 ) .
            end .
            else do :
              insw:write-data-element (  "line-num",       string(utd-lines.LineNum)          ) .
             /* find last tax-rate-value where    /*Значение ставки налога    НДС    */
                            tax-rate-value.tax-code = 1 and
                          tax-rate-value.rate-value = utd-lines.TaxRate no-lock no-error.
              if available tax-rate-value then*/
                 insw:write-data-element (  "nds-code",         if utd-lines.TaxRate = ? then "" else string( utd-lines.TaxRate )           ) .
              if utd-lines.gds-code ne ?
              then
                 insw:write-data-element (  "gd-code",      string(utd-lines.gds-code)        ) . 
              insw:write-data-element (  "price-nonds",      string(utd-lines.Price)        ) . 
              insw:write-data-element (  "qnty-ttn",   string(utd-lines.Quantity)  ) . 
              insw:write-data-element (  "sum",  string(utd-lines.Total)                 ) .
              insw:write-data-element (  "sum-nds",  string(utd-lines.vat)                 ) .
              insw:write-data-element (  "Qnty-accepted",  
                                       getattrutdlinesex(utd-lines.db-num, utd-lines.doc-id, utd-lines.lineNum,"QuantityBarCode","0")                 
                                       ) .  
            end .
            find first utd-marking-lines  where utd-marking-lines.db-num  = utd-lines.db-num
                                            and utd-marking-lines.doc-id  = utd-lines.doc-id
                                            and utd-marking-lines.LineNum = utd-lines.LineNum
                                            and utd-marking-lines.doc-level = 1 
            no-lock no-error.
            if available utd-marking-lines 
            then do:
               insw:start-element ({&tag-section2}) .
               if utd.EDocType = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB
               and not is-initial-set
               then do :
                 for each utd-marking-lines  where utd-marking-lines.db-num  = utd-lines.db-num
                                               and utd-marking-lines.doc-id  = utd-lines.doc-id
                                               and utd-marking-lines.LineNum = utd-lines.LineNum
                                               and utd-marking-lines.doc-level = 1 
                                               and (utd-marking-lines.sts = 0
                                                 or utd-marking-lines.site = "only-send")
                 no-lock:
                    insw:start-element ({&tag-item2}) .
                    insw:write-data-element (  "mark-code",        repSpecSimbforXlm( addBracketForCode(utd-marking-lines.mark) )         ) . 
                    if VFlagStsMark
                    then do:
                       find first marking where marking.mark eq utd-marking-lines.mark
                       no-lock no-error.
                       if available marking
                       then 
                          insw:write-data-element (  "stts",      ObjSrv:Env:marking:Sts:mark:GetNameProp(    marking.sts      )        ) . 
                       else
                          insw:write-data-element (  "stts",      ObjSrv:Env:marking:Sts:mark:GetNameProp(utd-marking-lines.sts)        ) .  
                    end.
                    else
                       insw:write-data-element (  "stts",         ObjSrv:Env:marking:Sts:mark:GetNameProp(utd-marking-lines.sts)        ) . 
            
                    insw:end-element ({&tag-item2}) .
                 end.
               end .
               else do :
                 for each utd-marking-lines  where utd-marking-lines.db-num  = utd-lines.db-num
                                               and utd-marking-lines.doc-id  = utd-lines.doc-id
                                               and utd-marking-lines.LineNum = utd-lines.LineNum
                                               and utd-marking-lines.doc-level = 1 
                 no-lock:
                    if utd-marking-lines.site = "only-send" then next .
                    insw:start-element ({&tag-item2}) .
                    insw:write-data-element (  "mark-code",        repSpecSimbforXlm( addBracketForCode(utd-marking-lines.mark) )         ) . 
                    if VFlagStsMark
                    then do:
                       find first marking where marking.mark eq utd-marking-lines.mark
                       no-lock no-error.
                       if available marking
                       then 
                          insw:write-data-element (  "stts",      ObjSrv:Env:marking:Sts:mark:GetNameProp(    marking.sts      )        ) . 
                       else
                          insw:write-data-element (  "stts",      ObjSrv:Env:marking:Sts:mark:GetNameProp(utd-marking-lines.sts)        ) .  
                    end.
                    else
                       insw:write-data-element (  "stts",         ObjSrv:Env:marking:Sts:mark:GetNameProp(utd-marking-lines.sts)        ) . 
            
                    insw:end-element ({&tag-item2}) .
                 end.
               end .
               insw:end-element ({&tag-section2}) .
            end.
            sertif = GetAttrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.linenum,"doc_sertif").
            if sertif <> ? then do:
              do ii = 1 to num-entries(sertif,{&delim-par}):
                insw:write-data-element (  "cert-decl",   entry(ii,sertif,{&delim-par})  ) .
              end.
            end.
            insw:end-element ({&tag-item1}) .
         end.
         
         insw:end-element ({&tag-section1}) .
      end.
      insw:end-element ({&tag-edi-doc}) .
/*      insw:end-element ({&tag-edi-docs}) .*/
   end.

  end method . /* end_of CrContentToSW */

end class.
