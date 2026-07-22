/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Преобразование строки, содержащей специальные символы в строку, где символы не содержатся и обратно

Автор: Чернова Светлана Александровна
Дата создания: 02/14/07
Author: Svetlana Chernova
Creation date: 02/14/07

create: Перваков Михаил Сергеевич
Дата создания: 01/11/01

*/


&if defined(strcodec_i) = 0 &then

&glob strcodec_i


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ def/funcmet.i octal-to-char character}
( p-string as character ) :

  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .

  if length(p-string) <> 3 then do:
    return ? .
  end.

  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.

  return chr(v-asc) .
end function .

{ def/funcmet.i char-to-octal character}
( p-chr as character ) :

  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .

  if length(p-chr) <> 1 then do:
    return ? .
  end.

  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.

  return v-string .

end.

{ def/funcmet.i str-encode character}
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :

  def var p-encode-string as character no-undo .

  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .

  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.

  if p-init-string = ? then do:
    return "?" .
  end.

  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.

  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .

  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.

  return p-encode-string .

end.

function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :

  def var p-decode-string as character no-undo .

  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .

  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.

  if p-init-string = "?" then do:
    return ? .
  end.

  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .

  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .

      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .

      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.

  return p-decode-string .
end.
&endif

/* $Workfile$ e n d */