&if defined(delim-html-text) eq 0
&then
   &scop delim-html-text skip
&endif
"<!DOCTYPE HTML>" {&delim-html-text}
' <html>' {&delim-html-text}
'  <head>' {&delim-html-text}
'   <meta charset="utf-8">' {&delim-html-text}
'    <style type="text/css">' {&delim-html-text}
                     
'      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) {&delim-html-text}
'      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) {&delim-html-text}
'      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black;' + chr(125) {&delim-html-text}
'   </style>' {&delim-html-text}
'  </head>' {&delim-html-text}