/*
Прием в новостях марок

Автор: Александр Ростовцев
Дата создания: 23.11.2023

*/
if not available tb-marking then 
do:
  gtin = GetCodeIdent(wt-marking.mark).
  find first tb-marking                 
    where tb-marking.mark begins gtin
    exclusive-lock no-error.
end.

if not available tb-marking then 
do:
  create tb-marking.
  compare-log = no.
end.
else 
do:
    buffer-compare tb-marking TO wt-marking case-sensitive save result in compare-log no-error.
end.
if not compare-log then
  buffer-copy wt-marking TO tb-marking.
