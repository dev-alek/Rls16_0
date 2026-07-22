block-level on error undo, throw.
define input parameter intMilliseconds as integer no-undo.
run Sleep(intMilliseconds).
procedure Sleep external "kernel32.DLL":
  define input parameter intMilliseconds as LONG.
end procedure.
