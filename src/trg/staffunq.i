/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка уникальности записи персонала

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/02/06
Author: Bakhtadze Natalya
Creation date: 07/02/06

{1} проверяемая запись
{2} найденная при проверке запись
{3} мода - новый или нет

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


if {3} then do:
  find first {2} no-lock where
            {2}.role = {1}.role
        and {2}.role-level = {1}.role-level
        and {2}.work-place = {1}.work-place
        and {2}.staff-code = {1}.staff-code
        and {2}.date-start >= {1}.date-start no-error .
  if available {2}
  and recid({2}) <> recid({1})
  then do:
      {4} = yes.
  end.
end.
if not {4} then do:
  find first {2} no-lock where
            {2}.role = {1}.role
        and {2}.role-level = {1}.role-level
        and {2}.work-place = {1}.work-place
        and {2}.staff-code = {1}.staff-code
        and {2}.date-start = {1}.date-start no-error .
  if available {2}
  and recid({2}) <> recid({1})
  then do:
      {4} = yes.
  end.
end.
if not {4} then do:
  find first {2} no-lock where
            {2}.role = {1}.role
        and {2}.role-level = {1}.role-level
        and {2}.work-place = {1}.work-place
        and {2}.staff-code = {1}.staff-code
        and {2}.date-start <= {1}.date-start
        and {2}.date-end >= {1}.date-start
        no-error .
  if available {2}
  and recid({2}) <> recid({1})
  then do:
      {4} = yes.
  end.
end.
if not {4} then do:
  find first {2} no-lock where
            {2}.role = {1}.role
        and {2}.role-level = {1}.role-level
        and {2}.work-place = {1}.work-place
        and {2}.staff-code = {1}.staff-code
        and {2}.date-start <= {1}.date-end
        and {2}.date-end >= {1}.date-end
        no-error .
  if available {2}
  and recid({2}) <> recid({1})
  then do:
      {4} = yes.
  end.
end.
if not {4} then do:
  find first {2} no-lock where
            {2}.role = {1}.role
        and {2}.role-level = {1}.role-level
        and {2}.work-place = {1}.work-place
        and {2}.staff-code = {1}.staff-code
        and {2}.date-start >= {1}.date-start
        and {2}.date-start <= {1}.date-end
        no-error .
  if available {2} and
  recid({2}) <> recid({1})
  then do:
      {4} = yes.
  end.
end.
if not {4} then do:
  find first {2} no-lock where
            {2}.role = {1}.role
        and {2}.role-level = {1}.role-level
        and {2}.work-place = {1}.work-place
        and {2}.staff-code = {1}.staff-code
        and {2}.date-end >= {1}.date-start
        and {2}.date-end <= {1}.date-end
        no-error .
  if available {2}
  and recid({2}) <> recid({1})
  then do:
      {4} = yes.
  end.
end.
if {4} then do:
  {5} =  substitute("Запись ПЕРСОНАЛА с определенным кодом должна быть уникальна&1" +
              "в пределах БД или фирмы или объекта во всем периоде действия&1" +
              "(Добавлять можно только если начиная с текущего момента других таких записей нет)&1" +
              "Попытка сохранить запись - &2 Действует с &3 по &4&1" +
              "Найдена уже существующая запись - &5 Действует с &6 по &7"
              ,{&new-line}
              ,gbclcode-get-position  ( input {1}.role
                                        ,input {1}.role-level
                                        ,input {1}.work-place
                                        ,input {1}.staff-code )
              ,string({1}.date-start, "99/99/9999")
              ,(if {1}.date-end = {&end-of-age} then "настоящее время" else string({1}.date-end, "99/99/9999"))
              ,gbclcode-get-position  ( input {2}.role
                                        ,input {2}.role-level
                                        ,input {2}.work-place
                                        ,input {2}.staff-code )
              ,string({2}.date-start, "99/99/9999")
              ,(if {2}.date-end = {&end-of-age} then "настоящее время" else string({2}.date-end, "99/99/9999"))
              ).
end.

/* $Workfile$ e n d */