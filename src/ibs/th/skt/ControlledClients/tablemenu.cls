/*

$Revision: 43c09557cdee, 3584, rls $
$Author: DRuban $
$Date: 2023/12/28 12:56:36 $
$Workfile: TableMenu.cls $
$Archive: ibs/th/skt/ControlledClients/TableMenu.cls $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

&scop CRLF chr(13) + chr(10)
&scop HdEnd chr(13) + chr(10) + chr(13) + chr(10)


using Progress.Lang.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.

class ibs.th.skt.ControlledClients.TableMenu: 

  /*содержит записанную csv*/
  define public property CSVStr as longchar no-undo
    get.
    private set.

    
  define public property SomeStr as char no-undo
    get.
    set.

  

  
  define variable logWrite      as class   LogWrite no-undo.
  define variable mbuffer-out   as memptr  no-undo.
  define variable v-cont-length as integer no-undo.
  { cmp/str-glbl.i class}
  { gbl/attr-lib.i CLASS}
  { gbl/objsrv.i def}
  constructor public TableMenu (  ):
    define variable vTmpStr as character no-undo.
    { gbl/attr-lib.i get}
    { gbl/objsrv.i get} 
    logWrite = new LogWrite().
    
  end constructor.


  method public void WriteCSVGrp ():
    define variable response   as character no-undo.
    define variable v-grp-rus  as character no-undo.
    define variable v-grp-eng  as character no-undo.
    
    for each ub.season no-lock:
      if ub.season.stts <> 0 then next.

      v-grp-rus = entry(1, ub.season.sea-name, '/').
      v-grp-eng = ''.
      assign
        v-grp-eng = entry(2, ub.season.sea-name, '/') no-error.
        
      response = response + string(ub.season.sea-code) + ',' + v-grp-rus + ',' + v-grp-eng + '|'.
    end.
    SomeStr = response.
  
  end method.


  method public void WriteCSVGds (cont as longchar):
    define variable response   as character no-undo.
    define variable v-parsed   as character no-undo.
    define variable v-sea-code as integer   no-undo.
    define variable v-obj-code as integer   no-undo.
    
    v-parsed = trim(substring(cont, (index(cont, 'grp=') + 4), (index(cont, '/') - (index(cont, 'grp=') + 4))), '"').
    v-obj-code = integer(entry(1, v-parsed, ';')) no-error.
    if error-status:error
    then do:
       SomeStr = "Не передан объект в запросе".
       return .
    end.
       
    v-sea-code = integer(entry(2, v-parsed, ';')) no-error.
    if error-status:error
    then do:
       SomeStr = "Не передан группа в запросе".
       return .
    end.
    logWrite:LogStr = "".
    for each ub.gds-season where ub.gds-season.sea-code = v-sea-code no-lock:
      find first ub.goods where ub.goods.gds-code = ub.gds-season.gds-code no-lock no-error.
      if ub.goods.stts <> 0 then next.
      find first ub.gds-obj where ub.gds-obj.obj-code = v-obj-code
        and ub.gds-obj.obj-type = 'маг'
        and ub.gds-obj.gds-code = ub.goods.gds-code no-lock no-error.
      if not available(ub.gds-obj) then 
      do:
        logWrite:WriteFileToLog( substitute ('&3Ошибка: Товар "&1" Код: "&2". Убедитесь, что на товар назначена цена.', ub.goods.gds-name, ub.goods.gds-code,{&new-line})).
        next.
      end.
      
      define variable v-value as character no-undo.
      define variable v-type  as character no-undo.
      &scop proc-name gds-attr-value
       {&run_proc_attr-lib}
         (input  ub.goods.gds-code
         ,input  {&attr-mark-type}
         ,output v-value
         ,output v-type
         ) no-error .
       if error-status :error
       then do:
         undo, return error return-value .
       end.
      define variable MarkType as ibs.th.str.marking.Types no-undo.
      MarkType = ObjSrv:Env:Marking:Types.
      define variable objType  as ibs.th.gbl.propmap no-undo.
      objType = MarkType:GetProp(v-value).
      if objType ne MarkType:Unknow
      then do:
         logWrite:WriteFileToLog( substitute ('&4Товар "&1" Код: "&2" установлен тип маркировки "&3". Товар пропущен.',  ub.goods.gds-name, string(ub.goods.gds-code), objType:Label_,{&new-line})).
         next.
      end.
      find first ub.bar-code where ub.bar-code.gds-code = ub.goods.gds-code
        and ub.bar-code.unit-cli = ub.goods.unit-base 
        and ub.bar-code.in-code = ''
        and ub.bar-code.part-code = '' no-lock no-error.
      if not available(ub.bar-code) then next.
      response = response + string(ub.bar-code.b-code) + ',' +
        replace(replace(replace(replace(ub.goods.label-name, "&", "&amp;"), '"', "&quot;") , "'", "&apos;"), ',', '.') + ',' +
        replace(replace(replace(replace(if ub.goods.engl-name = ? then "" else ub.goods.engl-name, "&", "&amp;"), '"', "&quot;") , "'", "&apos;"), ',', '.') + ',' +
        trim(string(ub.gds-obj.price-sale, "->>>>>>>>>>>9.99")) + '|'.
    end.
    SomeStr = response.

  end method.
  
end class.