define property {&Obj} as CLASS {&ObjClass} no-undo
    get():
       DEFINE VARIABLE vStorageOBj AS CLASS {&StorClass}.
       
       IF     this-object:refreshObj
          and not valid-object ({&Obj})
       THEN DO :
          vStorageOBj = NEW {&StorClass}().
          {&Obj} = vStorageOBj:{&storColec}.
          delete OBJECT vStorageOBj no-error.
       END.   
       RETURN {&Obj}.
    END.   
    set(arg as CLASS {&ObjClass}):
        {&Obj} = arg.
        setFlagChange (true).
      
    END.