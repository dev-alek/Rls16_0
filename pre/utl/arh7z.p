block-level on error undo, throw.
define input  parameter iFilearh as character no-undo.
define input  parameter iFileSourse as character no-undo.
define variable m-arh-name as character no-undo.
m-arh-name = search('exe/7z.exe':U).
if m-arh-name = ?
then do:
   m-arh-name = search('exe/7za.exe':U).
end.
os-command silent
    value( substitute( "&1 a -tzip -y &2 &3":U, m-arh-name, iFilearh, iFileSourse ) )
