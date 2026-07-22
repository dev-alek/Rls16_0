block-level on error undo, throw.
class utl.flt-condition:
   define public property Field_ as char no-undo
   get.
   set.
   define public property FieldType as char no-undo
   get.
   set.
   define public property BufferName as char no-undo
   get.
   set.
   define public property FieldName as char no-undo
   get.
   set.
   define public property Value as char no-undo
   get.
   set.
   define public property Value1 as char no-undo
   get.
   set.
   define public property Operation as char no-undo
   get.
   set.
   define public property SupportOp as char no-undo
   get.
   private set.
   define public property Enabled as logical no-undo
   get.
   set.
   method public char GetWhere():
      def var vRes as char no-undo.
      if this-object:Enabled then
      do:
         case this-object:Operation:
            when "равно"        then vRes = get-flt("=").
            when "не равно"        then vRes = get-flt("<>").
            when "меньше"        then vRes = get-flt("<").
            when "меньше или равно"        then vRes = get-flt("<=").
            when "больше"        then vRes = get-flt(">").
            when "больше или равно"        then vRes = get-flt(">=").
            when "начинается с"    then vRes = get-flt("begins").
            when "между"   then vRes = get-flt-between().
            when "список"      then vRes = get-flt-list().
            when "содержит" then vRes = get-flt-contrains().
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
         when "int"  then vRes = this-object:value.
         when "char" then vRes = quoter(this-object:value).
         when "date" then vRes = quoter(date(this-object:value)).
         when "datetime" then vRes = quoter(datetime(this-object:value)).
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
         when "date" then
         do:
            vRes = substitute("(&1.&2 >= &3) and (&1.&2 <= &4)",
                                this-object:BufferName,
                                this-object:Field_,
                                quoter(date(this-object:Value)),
                                quoter(date(this-object:Value1))).
         end.
         when "datetime" then
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
      if this-object:FieldType = "char" then
      do:
         vRes = substitute("can-do(&3,&1.&2)",
                            this-object:BufferName,
                            this-object:Field_,
                            GetValue()).
      end.
      if this-object:FieldType = "int" then
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
      if this-object:FieldType = "char" then
      do:
         vRes = substitute("&1.&2 matches ('*&3*')",
                            this-object:BufferName,
                            this-object:Field_,
                            this-object:value).
      end.
      return vRes.
   end method.
end class.
