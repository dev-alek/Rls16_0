block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: h_toc.p $
$Archive: utl/h_toc.p $

формирование TOC

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 09/09/04 5:32

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: h_toc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/h_toc.p $":U .
define variable vss-description as character no-undo init "TOC ".
{ cmp/vssrevis.i }
{ gbl/filelist.i }

define variable  v-fill-name   as character no-undo .
define variable  v-workfile_   as character no-undo .
define variable  v-author      as character no-undo .
define variable  v-description as character no-undo .
define variable  v-hlp as logical no-undo .
define variable g#log as logical no-undo .
define variable my-dir as character no-undo init "c:\help\".
define variable v-exist as logical no-undo init false .
g#log =  session:SET-WAIT-STATE("GENERAL") .

define stream old-stream .
define stream toc-stream .
define stream in-stream .

input stream old-stream from value (my-dir + "toc.hhc") .
output stream toc-stream to value ( my-dir + "new-toc.hhc") .


define variable i as integer no-undo init 0 .
define variable pp as integer no-undo init 0 .

define work-table temp-tt no-undo
field v-temp-char as character
.

repeat :
  create temp-tt.
  import stream old-Stream unformatted temp-tt.v-temp-char no-error .
  i = i + 1.
  temp-tt.v-temp-char = caps(temp-tt.v-temp-char).
end.

/* message "Закачали старый" view-as alert-box . */

run filelist-init
    ( "c:/help" ,
      true                        ,
      "htm"                       ,
      "c:/help"
      )  no-error .

        if error-status :error then
                message vss-workfile vss-revision vss-description skip
              "Ошибка 2 " skip
                skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error
        .

      for each temp-filelist
          on error undo, return error :

          run h_tt (
              input temp-filelist.full-name ,
              output   v-fill-name   ,
              output   v-workfile_   ,
              output   v-author      ,
              output   v-description ,
              output   v-hlp
                )
              no-error .
              if error-status :error then message vss-workfile vss-revision vss-description skip
                     "Ошибка 3 " skip
                      skip
                      error-status :get-message(1) skip
                      return-value skip
                      view-as alert-box error
              .

            find first temp-tt where  index(temp-tt.v-temp-char , caps('"' + temp-filelist.file-name-no-ext + ".htm")) > 0 no-error .
            if not available temp-tt then do:
                        run make-toc (temp-filelist.file-name-no-ext , v-description ).
            end.

      end. /* for each */


input  stream old-stream close.
output stream toc-stream close.
input stream in-stream close.

g#log =  session:SET-WAIT-STATE("") .

message "ВСЕ готово в " my-dir "new-toc.txt" .






procedure make-toc :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input  parameter  var-htm as character no-undo .
define input  parameter  var-name as character no-undo .

if var-htm  = ? then var-htm  = "" .
if var-name  = ? then var-name  = "" .

put stream toc-stream unformatted
'  <LI> <OBJECT type="text/sitemap">'                    skip
'    <param name="Name" value="' + var-name + '">'       skip
'    <param name="Local" value="' + var-htm + '.htm">'   skip
'    <param name="ImageNumber" value="41">           '   skip
'    </OBJECT>'                                          skip
.

 end. /* do */
end procedure. /* make-toc */


procedure h_tt :

  do
  on error undo, return error return-value
  :
define input parameter   p-file-name as character no-undo .

define output parameter  fill-name   as character no-undo .
define output parameter  workfile_   as character no-undo .
define output parameter  author      as character no-undo .
define output parameter  description as character no-undo .
define output parameter app_help as logical no-undo .


input stream in-stream from value( p-file-name ) .

define variable v-temp-char as character no-undo .
define variable start1 as integer   no-undo .
define variable len as integer   no-undo .
description = "".

repeat :
  import stream In-Stream unformatted v-temp-char no-error .
  v-temp-char = trim (v-temp-char) no-error .

  if v-temp-char begins "<title>" then do:
    start1 = 7 + index(v-temp-char,"<title>") .
    len =  index(v-temp-char,"</title>")  - start1.
    if len < 0 then len = 10 .
    if start1 < 0 then start1 = 1.
    description = trim(substring(v-temp-char,start1,len )) .
    leave.
  end.
end.


/*
message
fill-name   skip
workfile_   skip
author      skip
description
.
*/




  end.

end procedure. /* h_tt */
