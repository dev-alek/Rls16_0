block-level on error undo, throw.
class utl.gpwdbrw-filter:
   define public property User as utl.flt-condition no-undo
   get.
   set.
   define public property HostName as utl.flt-condition no-undo
   get.
   set.
   define public property DateGen as utl.flt-condition no-undo
   get.
   set.
   define public property ObjectNum as utl.flt-condition no-undo
   get.
   set.
   define public property CashNum as utl.flt-condition no-undo
   get.
   set.
   define public property Fio as utl.flt-condition no-undo
   get.
   set.
   define public property DateProl as utl.flt-condition no-undo
   get.
   set.
   define public property Modifier as char init "and" no-undo
   get.
   set.
   method public static utl.gpwdbrw-filter GetObject():
      def var vFilter as class utl.gpwdbrw-filter no-undo.
      def var vCond   as class utl.flt-condition  no-undo.
      vFilter = new utl.gpwdbrw-filter().
      assign
         vCond = new utl.flt-condition()
         vCond:BufferName = "b-tech-prol-pwd"
         vCond:Field_ = "f-user"
         vCond:FieldName = "Идентификатор пользователя:"
         vCond:FieldType = "char"
      .
      vCond:AddOp("равно").
      vCond:AddOp("не равно").
      vCond:AddOp("список").
      vFilter:user = vCond.
      assign
         vCond = new utl.flt-condition()
         vCond:BufferName = "b-tech-prol-pwd"
         vCond:Field_ = "f-hostname"
         vCond:FieldName = "Имя хоста:"
         vCond:FieldType = "char"
      .
      vCond:AddOp("равно").
      vCond:AddOp("не равно").
      vCond:AddOp("содержит").
      vCond:AddOp("список").
      vFilter:HostName = vCond.
      assign
         vCond = new utl.flt-condition()
         vCond:BufferName = "b-tech-prol-pwd"
         vCond:Field_ = "f-time"
         vCond:FieldName = "Дата и время генерации пароля:"
         vCond:FieldType = "datetime"
      .
      vCond:AddOp("больше").
      vCond:AddOp("больше или равно").
      vCond:AddOp("меньше").
      vCond:AddOp("меньше или равно").
      vCond:AddOp("между").
      vFilter:DateGen = vCond.
      assign
         vCond = new utl.flt-condition()
         vCond:BufferName = "b-tech-prol-pwd"
         vCond:Field_ = "f-date"
         vCond:FieldName = "Дата проведения техпролива:"
         vCond:FieldType = "date"
      .
      vCond:AddOp("больше").
      vCond:AddOp("больше или равно").
      vCond:AddOp("меньше").
      vCond:AddOp("меньше или равно").
      vCond:AddOp("между").
      vFilter:DateProl = vCond.
      assign
         vCond = new utl.flt-condition()
         vCond:BufferName = "b-tech-prol-pwd"
         vCond:Field_ = "f-object-num"
         vCond:FieldName = "Объект:"
         vCond:FieldType = "int"
      .
      vCond:AddOp("равно").
      vCond:AddOp("не равно").
      vCond:AddOp("список").
      vFilter:ObjectNum = vCond.
      assign
         vCond = new utl.flt-condition()
         vCond:BufferName = "b-tech-prol-pwd"
         vCond:Field_ = "f-cash-num"
         vCond:FieldName = "Касса:"
         vCond:FieldType = "int"
      .
      vCond:AddOp("равно").
      vCond:AddOp("не равно").
      vCond:AddOp("список").
      vFilter:CashNum = vCond.
      assign
         vCond = new utl.flt-condition()
         vCond:BufferName = "b-tech-prol-pwd"
         vCond:Field_ = "f-fio"
         vCond:FieldName = "ФИО заказчика пароля:"
         vCond:FieldType = "char"
      .
      vCond:AddOp("равно").
      vCond:AddOp("не равно").
      vCond:AddOp("содержит").
      vCond:AddOp("начинается с").
      vCond:AddOp("список").
      vFilter:Fio = vCond.
      return vFilter.
   end method.
   method public log AllFiltersDisabled():
      return not (CashNum:Enabled  or
                  DateGen:Enabled  or
                  DateProl:Enabled or
                  Fio:Enabled      or
                  HostName:Enabled or
                  ObjectNum:enabled or
                  User:enabled).
   end method.
   method public character SubstWhere(iWhere as char, iString as char):
      def var vWhere as char no-undo.
      if iString <> "" then
      do:
         vWhere = substitute("&1 &2 (&3)",iWhere,this-object:Modifier,iString).
      end.
      else
         vWhere = iWhere.
      return vWhere.
   end method.
   method public character GetWhere():
      def var vWhere as char no-undo.
      assign
         vWhere = SubstWhere(vWhere,this-object:HostName:GetWhere())
         vWhere = SubstWhere(vWhere,this-object:Fio:GetWhere())
         vWhere = SubstWhere(vWhere,this-object:User:GetWhere())
         vWhere = SubstWhere(vWhere,this-object:DateGen:GetWhere())
         vWhere = SubstWhere(vWhere,this-object:DateProl:GetWhere())
         vWhere = SubstWhere(vWhere,this-object:ObjectNum:GetWhere())
         vWhere = SubstWhere(vWhere,this-object:CashNum:GetWhere())
         vWhere = trim(vWhere," ")
         vWhere = trim(vWhere,Modifier)
      .
      return vWhere.
   end method.
   method public character GetModifierName():
      define variable result as character no-undo.
      case this-object:Modifier:
         when "and" then result = "И".
         when "or" then result = "ИЛИ".
      end case.
      return result.
   end method.
end class.
