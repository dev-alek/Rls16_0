find first buf_{1} exclusive-lock where
           recid(buf_{1}) = recid({1}) no-error no-wait.
if not avail buf_{1} then
do:
  undo, return error "Ошибка удаления {1}. Запись занята другим пользователем.".  
end.
delete buf_{1}.
vDeleted = vDeleted + 1.

