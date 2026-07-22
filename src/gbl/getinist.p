block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getinist.p $
$Archive: gbl/getinist.p $

Считать строку из *.ini файла

Автор: Перваков Михаил Сергеевич
Дата создания: 02/25/05
Author: Mikhail Pervakov
Creation date: 02/25/05

GetPrivateProfileString
The GetPrivateProfileString function retrieves a string from
the specified section in an initialization file.

Note  This function is provided only for compatibility with
16-bit Windows-based applications.
Applications should store initialization information in the registry.

DWORD GetPrivateProfileString(
  LPCTSTR lpAppName,
  LPCTSTR lpKeyName,
  LPCTSTR lpDefault,
  LPTSTR lpReturnedString,
  DWORD nSize,
  LPCTSTR lpFileName
);

Parameters
  lpAppName
    [in] Pointer to a null-terminated string that specifies
    the name of the section containing the key name.
    If this parameter is NULL, the GetPrivateProfileString
    function copies all section names in the file to the supplied buffer.

  lpKeyName
    [in] Pointer to the null-terminated string specifying
    the name of the key whose associated string is to be retrieved.
    If this parameter is NULL, all key names in the section specified
    by the lpAppName parameter are copied to the buffer specified
    by the lpReturnedString parameter.

  lpDefault
    [in] Pointer to a null-terminated default string.
    If the lpKeyName key cannot be found in the initialization file,
    GetPrivateProfileString copies the default string to the
    lpReturnedString buffer.
    If this parameter is NULL, the default is an empty string, "".

    Avoid specifying a default string with trailing blank characters.
    The function inserts a null character
    in the lpReturnedString buffer to strip any trailing blanks.

    Windows Me/98/95:
      Although lpDefault is declared as a constant parameter,
      the system strips any trailing blanks by inserting a null character
      into the lpDefault string before copying it to the lpReturnedString buffer.

  lpReturnedString
    [out] Pointer to the buffer that receives the retrieved string.

    Windows Me/98/95:
      The string cannot contain control characters
      (character code less than 32).
      Strings containing control characters may be truncated.

  nSize
    [in] Size of the buffer pointed to by the lpReturnedString parameter,
    in TCHARs.

  lpFileName
    [in] Pointer to a null-terminated string that specifies the name
    of the initialization file.
    If this parameter does not contain a full path to the file,
    the system searches for the file in the Windows directory.

Return Values

  The return value is the number of characters copied to the buffer,
  not including the terminating null character.

If neither lpAppName nor lpKeyName is NULL and the supplied destination
buffer is too small to hold the requested string,
the string is truncated and followed by a null character,
and the return value is equal to nSize minus one.

If either lpAppName or lpKeyName is NULL and the supplied
destination buffer is too small to hold all the strings,
the last string is truncated and followed by two null characters.
In this case, the return value is equal to nSize minus two.

Remarks

The GetPrivateProfileString function searches
the specified initialization file for a key that matches
the name specified by the lpKeyName parameter under
the section heading specified by the lpAppName parameter.
If it finds the key, the function copies
the corresponding string to the buffer.

If the key does not exist, the function copies
the default character string specified by the lpDefault parameter.
A section in the initialization file must have the following form:

[section]
key=string

If lpAppName is NULL, GetPrivateProfileString copies
all section names in the specified file to the supplied buffer.
If lpKeyName is NULL, the function copies
all key names in the specified section to the supplied buffer.
An application can use this method to enumerate
all of the sections and keys in a file.

In either case, each string is followed by a null character
and the final string is followed by a second null character.
If the supplied destination buffer is too small to hold all the strings,
the last string is truncated and followed by two null characters.

If the string associated with lpKeyName is enclosed in single
or double quotation marks, the marks are discarded
when the GetPrivateProfileString function retrieves the string.

The GetPrivateProfileString function is not case-sensitive;
the strings can be a combination of uppercase and lowercase letters.

To retrieve a string from the Win.ini file, use the GetProfileString function.

The system maps most .ini file references to the registry,
using the mapping defined under the following registry key:

HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\
     CurrentVersion\IniFileMapping

This mapping is likely if an application modifies
system-component initialization files, such as Control.ini,
System.ini, and Winfile.ini.
In these cases, the function retrieves information from the registry,
not from the initialization file;
the change in the storage location has no effect on the function's behavior.

The profile functions use the following steps
to locate initialization information:

Look in the registry for the name of the initialization file,
say MyFile.ini, under IniFileMapping.

Look for the section name specified by lpAppName.
This will be a named value under myfile.ini, or a subkey of myfile.ini,
or will not exist.

If the section name specified by lpAppName
is a named value under myfile.ini,
then that value specifies where in the registry you will find
the keys for the section.

If the section name specified by lpAppName is a subkey of myfile.ini,
then named values under that subkey specify where in the registry
you will find the keys for the section.
If the key you are looking for does not exist as a named value,
then there will be an unnamed value (shown as <No Name>)
that specifies the default location in the registry where you will find the key.

If the section name specified by lpAppName does
not exist as a named value or as a subkey under myfile.ini,
then there will be an unnamed value (shown as <No Name>)
under myfile.ini that specifies the default location
in the registry where you will find the keys for the section.

If there is no myfile.ini subkey, or if it does not contain
an entry for the section name, then look for the actual MyFile.ini
on the disk and read its contents.

When looking at values in the registry that specify other registry locations,
there are several prefixes that change the behavior of the .ini file mapping:

! - this character forces all writes to go both to the registry
    and to the .ini file on disk.

# - this character causes the registry value to be set to the value
    in the Windows 3.1 .ini file when a new user logs
    in for the first time after setup.

@ - this character prevents any reads from going to the .ini file
    on disk if the requested data is not found in the registry.

USR: - this prefix stands for HKEY_CURRENT_USER,
    and the text after the prefix is relative to that key.

SYS: - this prefix stands for HKEY_LOCAL_MACHINE\SOFTWARE,
    and the text after the prefix is relative to that key.

Requirements

Client
Requires Windows XP, Windows 2000 Professional,
Windows NT Workstation, Windows Me, Windows 98, or Windows 95.

Server
Requires Windows Server 2003, Windows 2000 Server, or Windows NT Server.

Requires Kernel32.dll.

Implemented as GetPrivateProfileStringW (Unicode)
and GetPrivateProfileStringA (ANSI).
Note that Unicode support on Windows Me/98/95 requires Microsoft Layer
for Unicode.

*/

define input  parameter p-ini-filename as character no-undo .
define input  parameter p-section      as character no-undo .
define input  parameter p-key          as character no-undo .
define output parameter p-value        as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getinist.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/getinist.p $":U .
define variable vss-description as character no-undo init "Считать строку из *.ini файла".
{ cmp/vssrevis.i "substitute('&1|&2|&3',p-ini-filename,p-section,p-key)"}
{ gbl/windows.i  }

do
on error undo, return error return-value
:

  define variable v-return-value as integer   no-undo .
  define variable v-key-size     as integer   no-undo .
  define variable v-key-value    as memptr    no-undo .

  assign
    v-key-size = 256
    set-size(v-key-value) = v-key-size
  .

  run GetPrivateProfileString{&A} in hpApi
    (input  p-section                      /* LPCTSTR lpAppName,               */
    ,input  p-key                          /* LPCTSTR lpKeyName,               */
    ,input  ""                             /* LPCTSTR lpDefault,               */
    ,input  get-pointer-value(v-key-value) /* LPTSTR lpReturnedString,         */
    ,input  v-key-size                     /* DWORD nSize,                     */
    ,input  p-ini-filename                 /* LPCTSTR lpFileName               */
    ,output v-return-value
    ) .

  assign
    p-value = get-string(v-key-value, 1)
  .

  assign
    set-size(v-key-value) = 0
  .

end.