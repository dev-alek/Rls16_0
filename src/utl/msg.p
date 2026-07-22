block-level on error undo, throw.
/*

$Revision: 00556a14f793, 2650, rls $
$Author: ASMorozov $
$Date: Пт окт 23 21:03:42 2020 +0300 $
$Workfile: msg.p $
$Archive: utl/msg.p $

Сообщение в отдельной сессии.

Автор: Морозов Александр Сергеевич
Дата создания: 10/14/20
Author: Alexandr Morozov
Creation date: 20/14/20

*/

define variable FullFileName  as character no-undo.
define variable v-param       as character no-undo .
define variable ind           as integer   no-undo .
define variable v-num-entries as integer   no-undo .
define variable v-msg         as character no-undo .
define stream   s-imp.

if session:parameter <> "":U
  and session:parameter <> ?
then do:
  assign
    v-num-entries = num-entries( session:parameter, ",":U )
  .
  do ind = 1 to v-num-entries :
    assign
      v-param = entry( ind, session:parameter, ",":U )
    .
      if v-param begins 'FullFileName' then do:
        assign
          FullFileName = entry( 2, v-param, "?":U )
        .
      end.
  end.
end.

if FullFileName = ? or FullFileName = ""
  then quit. 

input stream s-imp from value( FullFileName ) .
import stream s-imp unformatted v-msg no-error .
message v-msg view-as alert-box information title "Информация.".

quit.
