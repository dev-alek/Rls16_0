/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Абстрактый класс репозитариев

Автор: Сергей Палагин
Дата создания: 21/10/18
Author: Sergey Palagin
Creation date: 21/10/18

*/

using Progress.Lang.*.

block-level on error undo, throw.

/* Работа с базой данных */
class utl.repository ABSTRACT: 

   method public abstract void Save( ).
   method public abstract void Refresh().
   
end class.