USING Progress.Lang.*.
USING Progress.Lang.AppError.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS utl.ValidateError INHERITS AppError:
   CONSTRUCTOR PUBLIC ValidateError (  ):
      SUPER ().
   END CONSTRUCTOR.
   CONSTRUCTOR PUBLIC ValidateError (INPUT ReturnValue AS CHARACTER):
      SUPER (ReturnValue).
   END CONSTRUCTOR.
   CONSTRUCTOR PUBLIC ValidateError (
      INPUT ErrorMessage   AS CHARACTER,
      INPUT MessageNumber AS INTEGER):
      SUPER (ErrorMessage,MessageNumber).
   END CONSTRUCTOR.
END CLASS.
