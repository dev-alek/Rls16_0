/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ФОрматы Img файлов понимаемых прогрессом

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/10/05
Author: Bakhtadze Natalya
Creation date: 06/10/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE VARIABLE v-image-order      AS CHARACTER NO-UNDO INIT "jpg,bmp":U.
define variable v-image-format     as character extent 62 init
[
 "Windows bitmap                                                          ", "*.bmp"
,"Computer-aided Acquisition and Logistics Support                        ", "*.cal"
,"Microsoft Windows Clipboard                                             ", "*.clp"
,"Halo CUT                                                                ", "*.cut"
,"Intel FAX format                                                        ", "*.dcx"
,"Windows device-independent bitmap                                       ", "*.dib"
,"Encapsulated PostScript                                                 ", "*.eps"
,"1 Graphics Interchange Format                                           ", "*.gif"
,"IBM IOCA                                                                ", "*.ica"
,"Microsoft Icon File format                                              ", "*.ico"
,"Amiga IFF                                                               ", "*.iff"
,"GEM bitmap                                                              ", "*.img"
,"Joint Bi-level Image Experts Group                                      ", "*.jbig"
,"JPEG                                                                    ", "*.jpg"
,"serView                                                                 ", "*.lv "
,"Macintosh MacPaint                                                      ", "*.mac"
,"Microsoft Windows Paint                                                 ", "*.msp"
,"Kodak Photo CD                                                          ", "*.pcd"
,"Macintosh PICT                                                          ", "*.pct"
,"PC Paintbrush                                                           ", "*.pcx"
,"GIF (Graphics Interchange Format) replacement                           ", "*.png"
,"Adobe Photoshop                                                         ", "*.psd"
,"Sun Raster (1-, 8-, 24-, or 32-bit Standard, BGR, RGB, and byte encoded)", "*.ras"
,"TARGA                                                                   ", "*.tga"
,"Tag image file format                                                   ", "*.tif"
,"Windows bitmap for wireless devices                                     ", "*.wbmp"
,"Windows metafiles                                                       ", "*.wmf"
,"WordPerfect graphics                                                    ", "*.wpg"
,"(also .bm) X bitmap                                                     ", "*.xbm"
,"Pixmap                                                                  ", "*.xpm"
,"UNIX X Window Dump File format                                          ", "*.xwd"

] no-undo.

/*,"Windows metafiles                                                       ", "*.wmf"
не поддерживает
*/

procedure get-custom-img-order :
/*готовит переменные для вызова d-file с солответствующие фильтрам по img файлам */
define output parameter p-descriptions as character no-undo .
define output parameter p-extensiond   as character no-undo .
define output parameter p-extensiont   as character no-undo .

define variable ii as integer no-undo .
define variable v-entry as integer no-undo .

  do
  on error undo, return error
  :
    assign
    p-descriptions = fill({&delim-par}, 30)
    p-extensiond   = fill({&delim-par}, 30)
    p-extensiont   = fill({&delim-par}, 30)
    .
    do ii = 2 to 62 by 2:
      assign
      v-entry = lookup(left-trim(v-image-format[ii], ".*"), v-image-order)
      .
      if v-entry > 0 then do:
        assign
        entry(v-entry, p-descriptions, {&delim-par}) = substitute("&1 &2", trim(v-image-format[ii - 1]), v-image-format[ii])
        entry(v-entry, p-extensiond, {&delim-par}) = v-image-format[ii]
        entry(v-entry, p-extensiont, {&delim-par}) = left-trim(v-image-format[ii], ".*")
        .
      end.
    end.
    assign
    p-descriptions = trim(p-descriptions, {&delim-par})
    p-extensiond   = trim(p-extensiond, {&delim-par})
    p-extensiont   = trim(p-extensiont, {&delim-par})
    p-descriptions = replace(p-descriptions, ({&delim-par} + {&delim-par}), {&delim-par})
    p-extensiond   = replace(p-extensiond, ({&delim-par} + {&delim-par}),  {&delim-par})
    p-extensiont   = replace(p-extensiont, ({&delim-par} + {&delim-par}), {&delim-par})
    .
  end.

end procedure. /* get-custom-img-order */


 /* $Workfile$ e n d */