USING Progress.Lang.*.
USING Progress.Lang.AppError.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS utl.LockedError INHERITS AppError:
   CONSTRUCTOR PUBLIC lockederror (  ):
      SUPER ().
   END CONSTRUCTOR.
   CONSTRUCTOR PUBLIC lockederror (INPUT ReturnValue AS CHARACTER):
      SUPER (ReturnValue).
   END CONSTRUCTOR.
   CONSTRUCTOR PUBLIC lockederror (
      INPUT ErrorMessage   AS CHARACTER,
      INPUT MessageNumber AS INTEGER):
      SUPER (ErrorMessage,MessageNumber).
   END CONSTRUCTOR.
END CLASS.
