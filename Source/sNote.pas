{ 
  sNote.pas
  Copyright (c) 2019 Paul Davidson. All rights reserved.
  
  Usage .Note nick message_text  NOTE
  
  Note accept message text and when nick joins channel then  text is sent to channel
  Notes are deleted after one month in file
}


unit sNote;


  {$MODE OBJFPC}
  {$H+}


interface


  uses
    Classes;


  type


    tNote = class( TStringList )
      private
        fFileName : string;
        procedure Expire;
      public
        constructor Create;
        destructor  Destroy;  override;
        function    Check( nick : string ) : boolean;         // Check to see if note for nick exists
        function    Fetch( nick : string ) : string;          // Retrive note for nick
        function    Note( from, msg : string ) : string;      // Add note for nick
    end;  // tNote


  var
    fNote : tNote;

    
implementation


  uses
    DateUtils,
    SysUtils;

  
  const
    CRLF : string = #13 + #10;


  constructor tNote.Create;
  begin
    inherited Create;
    CaseSensitive      := FALSE;
    Duplicates         := dupIgnore;
    LineBreak          := CRLF;
    OwnsObjects        := TRUE;
    NameValueSeparator := '~';
    Sorted             := TRUE;
    fFileName          := 'shao.note';
    try
      LoadFromFile( fFileName );
    except
    end;
  end;  // tNote.Create

  
  destructor tNote.Destroy;
  begin
    inherited Destroy;
  end;  // tNote.Destroy


  function tNote.Check( nick : string ) : boolean;
    // Check if note exists for nick, return number present else 0
  begin
    if IndexOfName( uppercase( trim( nick ) ) ) >= 0
      then Check := TRUE
      else Check := FALSE;
  end;  // tNoteCheck


  procedure tNote.Expire;
    // Scans messages and expires those older than about 2 months
  var
    i : integer;
    s : string;
  begin
    i := 0;
    while i < Count do begin
      s := Strings[ i ];
      s := copy( s, pos( ',', s ) - 17, 11 );
      if DaysBetween( strToDate( s ), now ) > 60
        then Delete( i );
      Inc( i );
    end;
  end;  // tNote.Expire

  
  function tNote.Fetch( nick : string ) : string;
    // Fetch message for nick n and delete message
  var
    idx : integer;
    s   : string;
  begin
    idx := IndexOfName( uppercase( trim( nick ) ) );
    if idx >= 0 then begin
      GetNameValue( idx, s, Fetch );
      Delete( idx );
      try
        SaveToFile( fFileName );
      except
      end;
    end else Fetch := '';
  end;  // tNote.Fetch


  function tNote.Note( from, msg : string ) : string;
    // Add note from nick 
  var
    s : string;
  begin
    s   := leftStr( msg, pos( ' ', msg + ' ' ) - 1 );
    msg := trim( copy( msg, length( s ) + 1, length( msg ) ) );
    if ( length( s ) > 0 ) and ( s[ length( s ) ] = ',' ) then s := leftStr( s, length( s ) - 1 );
    if length( msg ) > 0 then begin
      Add( uppercase( s ) + NameValueSeparator + 'from ' + from + ' ' + FormatDateTime( 'yyyy/mmm/dd hh:nn, ', Now ) + msg );
      s := from + ', note left for ' + s;
    end else s := 'Usage: .Note <nick> <message>';
    SaveToFile( fFileName );
    Note := s;
  end;  // tNote.Note


end.  // tNote 
