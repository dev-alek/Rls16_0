define property {&PropertyName} as integer no-undo
    get.
    set(arg as integer):
      if arg <> {&PropertyName}
      then do:
        {&PropertyName} = arg.
        setFlagChange (true).
      end.
    end.
    
    define property {&PropertyName}lbl as character  no-undo
    get():
         if valid-object({&ObjType})
         then
         return  {&ObjType}:typeLbl ("{&PropertyName}", {&PropertyName}).
         else
         return "".
    end.    
    set(arg as character):
        {&PropertyName} =  {&ObjType}:typeint("{&PropertyName}",arg).
      
    end. 
    &if defined (propertyType) ne 0
    &then
    define property {&PropertyName}enum as {&PropertyType} no-undo
    get():
        define variable v{&PropertyName}enum as {&PropertyType} no-undo.
        v{&PropertyName}enum = {&propertyType}:GetEnum({&PropertyName}) no-error.
        return   v{&PropertyName}enum.
    end.    
    set(arg as {&PropertyType}):
        {&PropertyName} =  arg:GetValue(). .
      
    end.
    &endif