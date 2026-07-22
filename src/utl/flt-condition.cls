/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Условие для фильтра

Автор: Сергей Палагин
Дата создания: 21/10/18
Author: Sergey Palagin
Creation date: 21/10/18

*/

block-level on error undo, throw.
 
{ utl/flt-operator.i }

class utl.flt-condition:
   
   /* Имя поля в БД */  
   define public property Field_ as char no-undo 
   get.
   set.
    
   /* Тип - char, date... */
   define public property FieldType as char no-undo 
   get.
   set.
   
   /* Имя буфера, по которому фильтруется элемент */ 
   define public property BufferName as char no-undo 
   get.
   set. 
   
   /* Имя условия для отображения в формах пользователю */
   define public property FieldName as char no-undo 
   get.
   set. 
   
   /* Значение поля */
   define public property Value as char no-undo 
   get.
   set. 

   /* Значение поля */
   define public property Value1 as char no-undo 
   get.
   set. 
   
   /* Операция - равно, не равно, содержит, список и пр.*/
   define public property Operation as char no-undo 
   get.
   set. 
   
   /* Список поддерживаемых условием операций */
   define public property SupportOp as char no-undo 
   get.
   private set. 
   
   define public property Enabled as logical no-undo 
   get.
   set.

   /* Получает строку с where выражением для данного условия */
   method public char GetWhere():
      
      def var vRes as char no-undo.
      
      if this-object:Enabled then
      do:
         case this-object:Operation:
            when {&flt-eq}        then vRes = get-flt("="). 
            when {&flt-ne}        then vRes = get-flt("<>").
            when {&flt-lt}        then vRes = get-flt("<").
            when {&flt-le}        then vRes = get-flt("<=").  
            when {&flt-gt}        then vRes = get-flt(">").
            when {&flt-ge}        then vRes = get-flt(">=").
            when {&flt-begins}    then vRes = get-flt("begins").
            when {&flt-between}   then vRes = get-flt-between().
            when {&flt-list}      then vRes = get-flt-list().
            when {&flt-contrains} then vRes = get-flt-contrains(). 
         end case.
      end.
         
      return vRes.

   end method.

   method public char AddOp(iOp as char):
      
      this-object:SupportOp = this-object:SupportOp + "," + iOp.       

   end method.

   method public char GetValue( ):
      
      def var vRes as char no-undo.
         
      case this-object:FieldType:
         when {&flt-type-int}  then vRes = this-object:value.
         when {&flt-type-char} then vRes = quoter(this-object:value).
         when {&flt-type-date} then vRes = quoter(date(this-object:value)).
         when {&flt-type-datetime} then vRes = quoter(datetime(this-object:value)).
      end case.
      
      return vRes.

   end method.

   method private char get-flt(iOp as char):
      
      def var vRes as char no-undo.

      vRes = substitute("&1.&2 &3 &4", 
                          this-object:BufferName,
                          this-object:Field_,
                          iOp,
                          GetValue()).
     
      return vRes.

   end method.
   
   method private char get-flt-between():
      
      def var vRes as char no-undo.
      
      case this-object:FieldType:
         when {&flt-type-date} then 
         do:
            vRes = substitute("(&1.&2 >= &3) and (&1.&2 <= &4)", 
                                this-object:BufferName,
                                this-object:Field_,
                                quoter(date(this-object:Value)),
                                quoter(date(this-object:Value1))).
         end.
         when {&flt-type-datetime} then 
         do:
            vRes = substitute("(&1.&2 >= &3) and (&1.&2 <= &4)", 
                                this-object:BufferName,
                                this-object:Field_,
                                quoter(datetime(this-object:Value)),
                                quoter(datetime(this-object:Value1))).
         end.      
               
      end case.
      
      return vRes.

   end method.

   method private char get-flt-list():
      
      def var vRes as char no-undo.
      
      if this-object:FieldType = {&flt-type-char} then
      do: 
         vRes = substitute("can-do(&3,&1.&2)", 
                            this-object:BufferName,
                            this-object:Field_,
                            GetValue()).
      end.
      
      if this-object:FieldType = {&flt-type-int} then
      do: 
         vRes = substitute("can-do(&3,string(&1.&2))", 
                            this-object:BufferName,
                            this-object:Field_,
                            quoter(GetValue())).
      end.
      
      return vRes.

   end method.

   method private char get-flt-contrains():
      
      def var vRes as char no-undo.
      
      if this-object:FieldType = {&flt-type-char} then
      do: 
         vRes = substitute("&1.&2 matches ('*&3*')", 
                            this-object:BufferName,
                            this-object:Field_,
                            this-object:value).
      end.
      
      return vRes.

   end method.
   
   
end class.