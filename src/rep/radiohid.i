/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
if {1} <> "*":U then do :
  v-temp-str="".
  repeat l# =1 to num-entries({2}:radio-buttons) / 2
  :
      if lookup(string(l#),replace({1},"!","")) = 0 then
        v-temp-str = v-temp-str + string(l#) + ','.
  end.
  repeat l# = 1  to num-entries(v-temp-str)
  :
    r# = 0.
    repeat j# = 1 to num-entries({2}:radio-buttons) by 2
    :
      r# = r# + 1.
      if r# = integer(entry(l#,v-temp-str)) then
         ret# = {2}:disable(entry(j#,{2}:radio-buttons)).
    end.
  end.
  do l# = 1 to num-entries({1}):
    if entry(l#,{1}) begins "!" then
    do:
      r# = integer(substring(entry(l#,{1}),2)) no-error.
      {2}:screen-value = entry(r# * 2,{2}:radio-buttons).
      assign {2}.
    end.
  end.
end.