block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: h_ttable.p $
$Archive: utl/h_ttable.p $

Скачивание из файла-исходника в переменные


Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 09/09/04 4:30

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: h_ttable.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/h_ttable.p $":U .
define variable vss-description as character no-undo init "Скачивание из файла-исходника в переменные".
{ cmp/vssrevis.i }
define input parameter   p-file-name as character no-undo .

define output parameter  fill-name   as character no-undo .
define output parameter  workfile_   as character no-undo .
define output parameter  author      as character no-undo .
define output parameter  description as character no-undo .
define output parameter app_help as logical no-undo .

define stream in-stream .

define variable v-temp-char as character no-undo .
define variable i as integer no-undo init 0 .
define variable pp as integer no-undo init 0 .
&scop doll '$'

fill-name = p-file-name.

input stream in-stream from value( p-file-name ) .

repeat :
  import stream In-Stream unformatted v-temp-char no-error .
  i = i + 1.
  v-temp-char = trim (v-temp-char) .
  if v-temp-char begins {&doll} + "Author" then do:
    author = entry( 2, v-temp-char, " " ) .
  end.

  if v-temp-char begins {&doll} + "Workfile" then do:
    workfile_ = entry( 2, v-temp-char, " " ) .
  end.


  if v-temp-char begins {&doll} + "Archive:" then do:
     pp = i .
  end.

  if i  >= pp + 1 and
     i  < pp + 3  and
     pp <> 0           then do:
     if v-temp-char <> ? and v-temp-char <> "" then   description = description + " " + v-temp-char.
  end.
  app_help = false .
  if index (lc(v-temp-char) , "gbl/app_help.i" ) > 0 then
      do:
        app_help = true .
        leave.
     end.

end.

input stream in-stream close.
/*
message
fill-name   skip
workfile_   skip
author      skip
description
.
*/