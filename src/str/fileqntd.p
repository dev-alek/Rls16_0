block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fileqntd.p $
$Archive: str/fileqntd.p $

Подсчет количества файлов с учетом поддиректорий

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: fileqntd.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/fileqntd.p $":U .
def var vss-description as character no-undo init "Подсчет количества файлов с учетом поддиректорий".
{ cmp/vssrevis.i }

define input parameter  DirPath as character no-undo.
define input parameter shablon as character no-undo .
/*  *  - рассматривать все поддиректории */
define output parameter fileqnty as integer no-undo .
define output parameter BadRetFlag as log no-undo.

{ cmp/str-glbl.i }

DEFINE VARIABLE file as character no-undo .
DEFINE VARIABLE path as character no-undo .
DEFINE VARIABLE atr as character no-undo .
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-flag as logical no-undo .


input from os-dir ( DirPath ) .
REPEAT :
    import file path atr.
    if can-do( "f", atr ) then do:
        assign
        fileqnty = fileqnty + 1
        .
    end.
    if can-do( "d", atr) and (file = ".":U or file = "..") then do:
      if shablon = "*":U then do:
      end.
      else do:
        do ii = 1 to num-entries(shablon):
          if file begins entry(ii, shablon) then do:
            run str/fileqntd.p (path, shablon, output jj, output v-flag).
            assign
            fileqnty = fileqnty + jj
            .
          end.
        end. /*do ii*/
      end. /*not * */
    end. /*d*/
END .
input close.
if fileqnty > 500 then
    BadRetFlag = TRUE.
else
    BadRetFlag = FALSE .