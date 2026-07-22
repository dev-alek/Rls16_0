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

class ibs.th.bge.1crn.subjects.exp-mark inherits send1cerpsub:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Выгрузка марок в 1с" get.
 
  { cmp/str-glbl.i class }
  { utl/gtin.i class}
 /* { str/lib-trn.i  class }
  { cmp/library.i  class }
  { ref/extclass.i }*/

  /* 16/VIII-2018 надо вокруг чеков сделать еще одну секцию с номером смены.
     Связано это с тем, что если в пакет попадает несколько раз одна и таже смена,
     1С уже не понимает какой набор чеков был последний, т.к. они все валятся в один раздел.
  */
  &scop tag-interface 'marks':U
  &scop tag-marks   'marks':U     
  &scop tag-mark   'mark':U

  define override public property InitSecTag as character no-undo init {&tag-interface}
  get.

  define override public property sendTableName as character no-undo init "marking"
    get.
   
   method override public void CheckParam(  ):
      if not valid-handle (oldbh)
      then
         return error "Не передан старый буфер".
      if oldbh:table ne "marking"
      then 
         return error "Старый буфер не marking: " + oldbh:table. 
      return.

   end method.

  /*------------------------------------------------------------------------------
   Purpose: выгружает несколько чеков со всеми потрохами в контекст контейнера SAX-writer
   Notes:   обязательный метод
   Param:   insw = create sax-writer
  ------------------------------------------------------------------------------*/
method override public void CrContentToSW (insw as handle):


   find first marking where marking.mark eq string(oldbh:buffer-field( "mark":U  ):buffer-value)
   no-lock no-error.
   if available marking
   then do:
      sendOldRowid = rowid(marking).
/*      insw:start-element ({&tag-marks}) .*/
      insw:start-element ({&tag-mark}) .
      insw:write-data-element (  "mark-code":U,     repSpecSimbforXlm(   addBracketForCode(marking.mark))   ).
      insw:write-data-element (  "unit-ext":U,        if marking.unit-ext eq ? then "" else marking.unit-ext  ).
      insw:write-data-element (  "qnty-box":U,        if marking.box-qnty eq ? then "" else string( marking.box-qnty )   ).
      insw:write-data-element (  "stts":U,       ObjSrv:Env:marking:sts:mark:GetNameProp(marking.sts)).
      insw:write-data-element (  "mark-parent":U,     repSpecSimbforXlm(  addBracketForCode( marking.mark-parent ))  ).
      if marking.gds-ext-id <> "" and marking.gds-ext-id <> ? then
        insw:write-data-element (  "GTIN":U,       marking.gds-ext-id   ).
      insw:write-data-element (  "gds-code":U,       if marking.gds-code eq ? then "" else string(marking.gds-code)   ).
      find first marking-attr where marking-attr.mark eq marking.mark
                                and marking-attr.attr-code eq "mrc"  
                                and marking-attr.attr-value <> '0'
                                and marking-attr.attr-value <> ''
      no-lock no-error.
      if available marking-attr
      then
         insw:write-data-element (  "mrc":U,       marking-attr.attr-value   ).
      /*else
         insw:write-data-element (  "mrc":U,       ""   ).*/
      find first marking-attr where marking-attr.mark eq marking.mark
                                and marking-attr.attr-code eq "weight"  
                                and marking-attr.attr-value <> '0'
                                and marking-attr.attr-value <> ''
      no-lock no-error.
      if available marking-attr
      then
         insw:write-data-element (  "weight":U,       marking-attr.attr-value   ).   
      insw:end-element ({&tag-mark}) .
/*      insw:end-element ({&tag-marks}) .*/
   end.
  end method . /* end_of CrContentToSW */

end class.
