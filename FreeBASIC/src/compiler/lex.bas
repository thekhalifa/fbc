''	FreeBASIC - 32-bit BASIC Compiler.
''	Copyright (C) 2004-2005 Andre Victor T. Vicentini (av1ctor@yahoo.com.br)
''
''	This program is free software; you can redistribute it and/or modify
''	it under the terms of the GNU General Public License as published by
''	the Free Software Foundation; either version 2 of the License, or
''	(at your option) any later version.
''
''	This program is distributed in the hope that it will be useful,
''	but WITHOUT ANY WARRANTY; without even the implied warranty of
''	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
''	GNU General Public License for more details.
''
''	You should have received a copy of the GNU General Public License
''	along with this program; if not, write to the Free Software
''	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA.


'' lexical scanner
''
''
'' chng: sep/2004 written [v1ctor]
'' 	     dec/2004 pre-processor added (all code at lexpp.bas) [v1ctor]

option explicit
option escape

defint a-z
#include once "inc\fb.bi"
#include once "inc\fbint.bi"
#include once "inc\lex.bi"
#include once "inc\ast.bi"

''
const FB_LEX_MAXK	= 1

''
const UINVALID as uinteger = cuint( INVALID )

''
type LEXCTX
	tokenTB(0 to FB_LEX_MAXK) as FBTOKEN
	k				as integer					'' look ahead cnt (1..MAXK)

	currchar		as uinteger					'' current char
	lahdchar		as uinteger					'' look ahead char

	linenum 		as integer
	colnum 			as integer
	lasttoken 		as integer

	reclevel 		as integer					'' PP recursion

	'' last #define's text
	deftext			as zstring * FB_MAXINTDEFINELEN+1
	defptr 			as zstring ptr
	deflen 			as integer

	'' last WITH
	withcnt 		as integer

	'' input buffer
	bufflen			as integer
	buffptr			as zstring ptr
	buff			as zstring * 8192+1
	filepos			as integer
	lastfilepos 	as integer
end type

declare function 	lexCurrentChar          ( byval skipwhitespc as integer = FALSE ) as uinteger
declare function 	lexEatChar              ( ) as uinteger
declare function 	lexGetLookAheadChar        ( byval skipwhitespc as integer = FALSE ) as uinteger
declare sub 		lexNextToken 			( t as FBTOKEN, _
											  byval flags as LEXCHECK_ENUM = LEXCHECK_EVERYTHING )

'' globals
	dim shared ctx as LEXCTX
	dim shared curline as string

	dim shared ctxcopyTB( 0 TO FB_MAXINCRECLEVEL-1 ) as LEXCTX

'':::::
sub lexSaveCtx( byval level as integer )

	ctxcopyTB(level) = ctx

end sub

'':::::
sub lexRestoreCtx( byval level as integer )

	ctx = ctxcopyTB(level)

end sub

'':::::
sub lexInit( )
    dim i as integer

	ctx.k = 0

	for i = 0 to FB_LEX_MAXK
		ctx.tokenTB(i).id = INVALID
	next i

	ctx.currchar 	= UINVALID
	ctx.lahdchar	= UINVALID

	ctx.linenum		= 1
	ctx.colnum		= 1
	ctx.lasttoken	= INVALID

	ctx.reclevel	= 0

	''
	ctx.deflen		= 0
	ctx.defptr		= NULL

	ctx.withcnt		= 0

	ctx.bufflen		= 0
	ctx.buffptr		= NULL

	ctx.filepos		= 0
	ctx.lastfilepos = 0

	'' only if it's not on an inc file
	if( env.reclevel = 0 ) then
		curline = ""
	end if

end sub

'':::::
sub lexEnd( )

	if( env.reclevel = 0 ) then
		curline = ""
	end if

end sub

''::::
private sub hLoadDefine( byval s as FBSYMBOL ptr )
    static as string oldtext
    dim as string text, newtext
    dim as FBDEFARG ptr a
    dim as FBTOKEN t
    dim as integer prntcnt, lgt

	'' define has args?
	if( s->def.args > 0 ) then

		'' '('
		lexNextToken( t, LEXCHECK_NOSUFFIX )
		if( t.id <> CHAR_LPRNT ) then
			hReportError( FB_ERRMSG_EXPECTEDLPRNT )
			exit sub
		end if

		text = s->def.text

		prntcnt = 1

		'' for each arg
		a = s->def.arghead
		do
			newtext = ""

			'' read text until a comma or right-parentheses is found
			do
				lexNextToken( t, LEXCHECK_NOWHITESPC or LEXCHECK_NOSUFFIX )
				select case t.id
				'' (
				case CHAR_LPRNT
					prntcnt += 1
				'' )
				case CHAR_RPRNT
					prntcnt -= 1
					if( prntcnt = 0 ) then
						exit do
					end if
				'' ,
				case CHAR_COMMA
					if( prntcnt = 1 ) then
						exit do
					end if
				''
				case FB_TK_EOL, FB_TK_EOF
					hReportError( FB_ERRMSG_EXPECTEDRPRNT )
					exit sub
				end select

                '' not a literal string?
    			if( t.class <> FB_TKCLASS_STRLITERAL ) then
    				newtext += t.text

    			'' lit string, add quotes
    			else
    				newtext += "\"
    				newtext += t.text
    				newtext += "\"
    			end if
            loop

            if( symbGetLen( s ) > 0 ) then
            	'' replace pattern with new text
            	oldtext = "\27"
            	oldtext += hex( a->id )
            	oldtext += "\27"
            	newtext = trim( newtext )
            	hReplace( text, oldtext, newtext )
            end if

			'' closing parentheses?
			if( prntcnt = 0 ) then
				exit do
			end if

			'' next
			a = a->next
		loop while( a <> NULL )

		lgt = len( text )

		''
		if( ctx.deflen = 0 ) then
			ctx.deftext = text
		else
			ctx.deftext = text + _
					  	  mid( ctx.deftext, _
					  	  	  1 + cuint(ctx.defptr) - cuint(@ctx.deftext), _
					  	  	  ctx.deflen )
		end if

	'' no args
	else

		'' should we call a function to get definition text?
		if( s->def.proc <> NULL ) then
			'' call function
            if( not bit( s->def.flags, 0 ) ) then
				s->def.text = "\"" + s->def.proc( ) + "\""
            else
				s->def.text = s->def.proc( )
            end if
			lgt = len( s->def.text )

		'' just load text as-is
		else
			if( s->def.isargless ) then
				'' '(' ')'?
				if( lexCurrentChar( ) = CHAR_LPRNT ) then
					if( lexGetLookAheadChar( TRUE ) = CHAR_RPRNT ) then
						lexEatChar( )
						lexEatChar( )
					end if
				end if
			end if

			lgt = symbGetLen( s )
		end if

		if( ctx.deflen = 0 ) then
			ctx.deftext = s->def.text
		else
			ctx.deftext = s->def.text + _
					  	  mid( ctx.deftext, _
					  	  	   1 + cuint(ctx.defptr) - cuint(@ctx.deftext), _
					  	  	   ctx.deflen )
		end if

	end if

    ''
	ctx.defptr = @ctx.deftext
	ctx.deflen += lgt

	if( ctx.deflen > FB_MAXINTDEFINELEN ) then
		ctx.deflen = FB_MAXINTDEFINELEN
		hReportError( FB_ERRMSG_MACROTEXTTOOLONG )
	end if

	'' force a re-read
	ctx.currchar = UINVALID

end sub

'':::::
private function lexReadChar as uinteger static
    dim char as uinteger

	'' WITH?
	if( ctx.withcnt > 0 ) then
		'' '>'?
		if( ctx.withcnt = 2 ) then
			char = CHAR_MINUS
		'' '-'
		else
			char = CHAR_GT
		end if

	'' any #define'd text?
	elseif( ctx.deflen > 0 ) then
		char = *ctx.defptr

	else

		'' buffer empty?
		if( ctx.bufflen = 0 ) then
			if( not eof( env.inf.num ) ) then
				ctx.filepos = seek( env.inf.num )
				if( get( #env.inf.num, , ctx.buff ) = 0 ) then
					ctx.bufflen = seek( env.inf.num ) - ctx.filepos
					ctx.buffptr = @ctx.buff
					ctx.filepos += ctx.bufflen
				end if
			end if
		end if

		''
		if( ctx.bufflen > 0 ) then
			char = *ctx.buffptr
		else
			char = 0
		end if

	end if

	'' only save current src line if it's not on an inc file
	if( env.reclevel = 0 ) then
		if( env.clopt.debug ) then
			select case char
			case 0, 13, 10
			case else
				curline += chr( char )
			end select
		end if
	end if

	function = char

end function

'':::::
private function lexEatChar as uinteger static

	ctx.colnum += 1

    ''
    function = ctx.currchar

	'' update if a look ahead char wasn't read already
	if( ctx.lahdchar = UINVALID ) then

		'' WITH?
		if( ctx.withcnt > 0 ) then
			ctx.withcnt -= 1

		'' #define'd text?
		elseif( ctx.deflen > 0 ) then
			ctx.deflen -= 1
			ctx.defptr += 1

		'' input stream (not EOF?)
		elseif( ctx.currchar <> 0 ) then
			ctx.bufflen -= 1
			ctx.buffptr += 1

		end if

    	ctx.currchar = UINVALID

    '' current= lookahead; lookhead = INVALID
    else
    	ctx.currchar = ctx.lahdchar
    	ctx.lahdchar = UINVALID
	end if

end function

'':::::
private sub lexSkipChar static

	'' WITH?
	if( ctx.withcnt > 0 ) then
		ctx.withcnt -= 1

	'' #define'd text?
	elseif( ctx.deflen > 0 ) then
		ctx.deflen -= 1
		ctx.defptr += 1

	'' input stream (not EOF?)
	elseif( ctx.currchar <> 0 ) then
		ctx.bufflen -= 1
		ctx.buffptr += 1

	end if

end sub

'':::::
private function lexCurrentChar( byval skipwhitespc as integer = FALSE ) as uinteger static

    if( ctx.currchar = UINVALID ) then
    	ctx.currchar = lexReadChar( )
    end if

    if( skipwhitespc ) then
    	do while( (ctx.currchar = CHAR_TAB) or (ctx.currchar = CHAR_SPACE) )
    		lexEatChar( )
    		ctx.currchar = lexReadChar( )
    	loop
    end if

    function = ctx.currchar

end function

'':::::
private function lexGetLookAheadChar( byval skipwhitespc as integer = FALSE ) as uinteger

	if( ctx.lahdchar = UINVALID ) then
		lexSkipChar( )
		ctx.lahdchar = lexReadChar( )
	end if

    if( skipwhitespc ) then
    	do while( (ctx.lahdchar = CHAR_TAB) or (ctx.lahdchar = CHAR_SPACE) )
    		lexSkipChar( )
    		ctx.lahdchar = lexReadChar( )
    	loop
    end if

	function = ctx.lahdchar

end function

''
''char classes:
''
''ALPHA          'A' - 'Z'
''DIGIT          '0' - '9'
''HEXDIG         'A' - 'F' | DIGIT
''OCTDIG         '0' - '7'
''BINDIG         '0' | '1'
''ALPHADIGIT     ALPHA | DIGIT
''ISUFFIX        '%' | '&'
''FSUFFIX        '!' | '#'
''SUFFIX         ISUFFIX | FSUFFIX | '$'
''
''EXPCHAR        'D' | 'E'
''
''OPERATOR       '=' | '<' | '>' | '+' | '-' | '*' | '/' | '\' | '^'
''DELIMITER      '.' | ':' | ',' | ';' | '"' | '''
''

'':::::
''indentifier    = (ALPHA | '_') { [ALPHADIGIT | '_' | '.'] } [SUFFIX].
''
private sub lexReadIdentifier( byval pid as zstring ptr, _
							   tlen as integer, _
							   typ as integer, _
							   dpos as integer, _
							   byval flags as LEXCHECK_ENUM ) static
	dim c as uinteger

	'' (ALPHA | '_' | '.' )
	*pid = lexEatChar( )
	if( pid[0] = CHAR_DOT ) then
		dpos = 1
	else
		dpos = 0
	end if
	pid += 1

	tlen = 1

	'' { [ALPHADIGIT | '_' | '.'] }
	do
		c = lexCurrentChar( )
		select case as const c
		case CHAR_AUPP to CHAR_ZUPP, CHAR_ALOW to CHAR_ZLOW, CHAR_0 to CHAR_9, CHAR_UNDER

		case CHAR_DOT
			if( dpos = 0 ) then
				dpos = tlen + 1
			end if

		case else
			exit do
		end select

		tlen += 1
		if( tlen > FB_MAXNUMLEN ) then
 			if( (flags and LEXCHECK_NOLINECONT) = 0 ) then
 				hReportError( FB_ERRMSG_IDNAMETOOBIG, TRUE )
				exit function
			else
				tlen -= 1
				exit do
			end if
		end if

		*pid = lexEatChar( )
		pid += 1

	loop

	'' null-term
	*pid = 0

	'' [SUFFIX]
	typ = INVALID

	if( (flags and LEXCHECK_NOSUFFIX) = 0 ) then
		select case as const lexCurrentChar( )
		'' '%' or '&'?
		case FB_TK_INTTYPECHAR, FB_TK_LNGTYPECHAR
			typ = FB_SYMBTYPE_INTEGER

		'' '!'?
		case FB_TK_SGNTYPECHAR
			typ = FB_SYMBTYPE_SINGLE

		'' '#'?
		case FB_TK_DBLTYPECHAR
			'' isn't it a '##'?
			if( lexGetLookAheadChar( ) <> FB_TK_DBLTYPECHAR ) then
				typ = FB_SYMBTYPE_DOUBLE
			end if

		'' '$'?
		case FB_TK_STRTYPECHAR
			typ = FB_SYMBTYPE_STRING
		end select

		if( typ <> INVALID ) then
			c = lexEatChar( )
		end if

	end if

end sub

''::::
''hex_oct_bin     = 'H' HEXDIG+
''                | 'O' OCTDIG+
''                | 'B' BINDIG+
''
private sub lexReadNonDecNumber( pnum as zstring ptr, _
								 tlen as integer, _
								 isneg as integer, _
								 islong as integer, _
								 byval flags as LEXCHECK_ENUM ) static
	dim as uinteger value, c, first_c
	dim as ulongint value64
	dim as integer tb(0 to 15), i, lgt

	isneg = FALSE
	islong = FALSE
	value = 0
	lgt = 0

	select case as const lexCurrentChar( )
	'' hex
	case CHAR_HUPP, CHAR_HLOW
		lexEatChar( )

		'' skip trailing zeroes
		while( lexCurrentChar( ) = CHAR_0 )
			lexEatChar( )
		wend

		do
			select case lexCurrentChar( )
			case CHAR_ALOW to CHAR_FLOW, CHAR_AUPP to CHAR_FUPP, CHAR_0 to CHAR_9
				c = lexEatChar( ) - CHAR_0
                if( c > 9 ) then
					c -= (CHAR_AUPP - CHAR_9 - 1)
                end if
                if( c > 16 ) then
                  	c -= (CHAR_ALOW - CHAR_AUPP)
                end if

				lgt += 1
				if( lgt > 8 ) then
					if( lgt = 9 ) then
						islong = TRUE
				    	value64 = (culngint( value ) * 16) + c
				    elseif( lgt = 17 ) then
				    	hReportError( FB_ERRMSG_NUMBERTOOBIG, TRUE )
				    	exit do
					else
				    	value64 = (value64 * 16) + c
				    end if
				else
                	value = (value * 16) + c
                end if
			case else
				exit do
			end select
		loop

	'' oct
	case CHAR_OUPP, CHAR_OLOW
		lexEatChar( )

		'' skip trailing zeroes
		while( lexCurrentChar( ) = CHAR_0 )
			lexEatChar( )
		wend

		first_c = lexCurrentChar( )
		do
			select case lexCurrentChar( )
			case CHAR_0 to CHAR_7
				c = lexEatChar( ) - CHAR_0

				lgt += 1
				if( lgt > 10 ) then
					select case as const lgt
					case 11
						if( first_c > CHAR_3 ) then
							islong = TRUE
							value64 = (culngint( value ) * 8) + c
						else
							value = (value * 8) + c
						end if
					case 12
						if( not islong ) then
							islong = TRUE
							value64 = culngint( value )
						end if
						value64 = (value64 * 8) + c
					case 22
						if( first_c > CHAR_1 ) then
							hReportError( FB_ERRMSG_NUMBERTOOBIG, TRUE )
							exit do
						else
							value64 = (value64 * 8) + c
						end if
					case 23
						hReportError( FB_ERRMSG_NUMBERTOOBIG, TRUE )
						exit do
					case else
						value64 = (value64 * 8) + c
					end select
				else
					value = (value * 8) + c
				end if
			case else
				exit do
			end select
		loop

	'' bin
	case CHAR_BUPP, CHAR_BLOW
		lexEatChar( )

		'' skip trailing zeroes
		while( lexCurrentChar( ) = CHAR_0 )
			lexEatChar( )
		wend

		do
			select case lexCurrentChar( )
			case CHAR_0, CHAR_1
				c = lexEatChar( ) - CHAR_0
				lgt += 1
				if( lgt > 32 ) then
					if( lgt = 33 ) then
						islong = TRUE
				    	value64 = (culngint( value ) * 2) + c
				    elseif( lgt = 65 ) then
				    	hReportError( FB_ERRMSG_NUMBERTOOBIG, TRUE )
				    	exit do
				    else
				    	value64 = (value64 * 2) + c
				    end if
				else
					value = (value * 2) + c
				end if
			case else
				exit do
			end select
		loop

	case else
		exit sub
	end select

	if( not islong ) then
		'' int to ascii
		if( value = 0 ) then
			*pnum = CHAR_0
			pnum += 1
			tlen += 1

		else

			'' convert to unsigned
			if( (value and &h80000000) > 0 ) then
				value = -value

				isneg = TRUE
				*pnum = CHAR_MINUS
				pnum += 1
				tlen += 1
			end if

			i = 0
			do while( value > 0 )
				tb(i) = value mod 10
				i += 1
				value \= 10
			loop

			do while( i > 0 )
				i -= 1
				*pnum = CHAR_0 + tb(i)
				pnum += 1
				tlen += 1
			loop
		end if

	else
		if( value64 < 0 ) then
			isneg = TRUE
		end if
		*pnum = str$( value64 )
		tlen = len( *pnum )
		pnum += tlen
	end if

end sub

'':::::
''float           = DOT DIGIT { DIGIT } [FSUFFIX | { EXPCHAR [opadd] DIGIT { DIGIT } } | ].
''
private sub lexReadFloatNumber( pnum as zstring ptr, _
								tlen as integer, _
								typ as integer, _
								byval flags as LEXCHECK_ENUM ) static
    dim c as uinteger
    dim llen as integer

	typ = FB_SYMBTYPE_DOUBLE

	llen = tlen

	'' DIGIT { DIGIT }
	do
		c = lexCurrentChar( )
		select case c
		case CHAR_0 to CHAR_9
			*pnum = lexEatChar( )
			pnum += 1
			tlen += 1
		case else
			exit do
		end select

		if( tlen > FB_MAXNUMLEN ) then
 			if( (flags and LEXCHECK_NOLINECONT) = 0 ) then
 				hReportError( FB_ERRMSG_NUMBERTOOBIG, TRUE )
				exit function
			else
				tlen -= 1
				exit do
			end if
		end if

	loop

	'' [FSUFFIX | { EXPCHAR [opadd] DIGIT { DIGIT } } | ]
	select case as const lexCurrentChar( )
	'' '!' | 'F' | 'f'
	case FB_TK_SGNTYPECHAR, CHAR_FUPP, CHAR_FLOW
		c = lexEatChar( )
		typ = FB_SYMBTYPE_SINGLE
	'' '#'
	case FB_TK_DBLTYPECHAR
		c = lexEatChar( )
		typ = FB_SYMBTYPE_DOUBLE

	case CHAR_ELOW, CHAR_EUPP, CHAR_DLOW, CHAR_DUPP
		'' EXPCHAR
		c = lexEatChar( )
		*pnum = CHAR_ELOW
		pnum += 1
		tlen += 1

		'' [opadd]
		c = lexCurrentChar( )
		if( (c = CHAR_PLUS) or (c = CHAR_MINUS) ) then
			*pnum = lexEatChar( )
			pnum += 1
			tlen += 1
		end if

		do
			c = lexCurrentChar( )
			select case as const c
			case CHAR_0 to CHAR_9
				*pnum = lexEatChar( )
				pnum += 1
				tlen += 1
			case else
				exit do
			end select
		loop

	end select

	if( tlen - llen = 0 ) then
		'' '0'
		*pnum = CHAR_0
		pnum += 1
		tlen += 1
	end if

end sub

'':::::
''number          = DIGIT dig_dot_nil i_fsufx_nil
''                | '.' float
''                | '&' hex_oct_bin
''
''dig_dot_nil     = DIGIT dig_dot_nil
''                | ('.'|EXPCHAR) float
''                | .
''
''i_fsufx_nil     = ISUFFIX                       # is integer
''                | FSUFFIX                       # is float
''                | .                             # is def### !!! context sensitive !!!
''
private sub lexReadNumber( byval pnum as zstring ptr, _
						   typ as integer, _
						   tlen as integer, _
				   		   byval flags as LEXCHECK_ENUM ) static
	dim as uinteger c
	dim as integer isfloat, issigned, islong
	dim as zstring ptr pnum_start

	isfloat    = FALSE
	issigned   = TRUE
	islong     = FALSE
	typ 	   = INVALID
	*pnum 	   = 0
	pnum_start = pnum
	tlen 	   = 0

	c = lexEatChar( )

	select case as const c
	'' integer part
	case CHAR_0 to CHAR_9

		if( c <> CHAR_0 ) then
			*pnum = c
			pnum += 1
			tlen += 1
		end if

		do
			c = lexCurrentChar( )
			select case as const c
			case CHAR_0
				lexEatChar( )
				if( tlen > 0 ) then
					*pnum = CHAR_0
					pnum += 1
					tlen += 1
				end if

			case CHAR_1 to CHAR_9
				*pnum = lexEatChar( )
				pnum += 1
				tlen += 1

			case CHAR_DOT, CHAR_ELOW, CHAR_EUPP, CHAR_DLOW, CHAR_DUPP
				isfloat = TRUE
				if( c = CHAR_DOT ) then
					c = lexEatChar( )
					*pnum = CHAR_DOT
					pnum += 1
					tlen += 1
				end if
				lexReadFloatNumber( pnum, tlen, typ, flags )
				exit do

			case else
				exit do
			end select

			select case as const tlen
			case 10
				if( *pnum_start > "2147483647" ) then
					issigned = FALSE
					if( *pnum_start > "4294967295" ) then
						issigned = TRUE
						islong = TRUE
					end if
				end if

			case 11
				islong = TRUE
				issigned = TRUE

			case 19
				if( *pnum_start > "9223372036854775807" ) then
					issigned = FALSE
				end if

			case 20
				issigned = FALSE
				if( *pnum_start > "18446744073709551615" ) then
					hReportError( FB_ERRMSG_NUMBERTOOBIG, TRUE )
					exit function
				end if

			case 21
				hReportError( FB_ERRMSG_NUMBERTOOBIG, TRUE )
				exit function
			end select

			if( tlen > FB_MAXNUMLEN ) then
 				if( (flags and LEXCHECK_NOLINECONT) = 0 ) then
 					hReportError( FB_ERRMSG_NUMBERTOOBIG, TRUE )
					exit function
				else
					tlen -= 1
					exit do
				end if
			end if

		loop

		if( tlen = 0 ) then
			*pnum = CHAR_0
			pnum += 1
			tlen = 1
		end if

	'' fractional part
	case CHAR_DOT
		isfloat = TRUE
		'' add '.'
		*pnum = CHAR_DOT
		pnum += 1
		tlen = 1
        lexReadFloatNumber( pnum, tlen, typ, flags )

	'' hex, oct, bin
	case CHAR_AMP
		tlen = 0
		lexReadNonDecNumber( pnum, tlen, issigned, islong, flags )
	end select

	'' null-term
	*pnum = 0

	'' check suffix type
	if( not isfloat ) then
		if( (flags and LEXCHECK_NOSUFFIX) = 0 ) then

			'' 'U' | 'u'
			select case lexCurrentChar( )
			case CHAR_UUPP, CHAR_ULOW
				lexEatChar( )
				issigned = FALSE
			end select

			select case as const lexCurrentChar( )
			'' 'L' | 'l'
			case CHAR_LUPP, CHAR_LLOW
				lexEatChar( )
				'' 'LL'?
				c = lexCurrentChar( )
				if( (c = CHAR_LUPP) or (c = CHAR_LLOW) ) then
					lexEatChar( )
					islong = TRUE
				else
					if( islong ) then
						hReportError( FB_ERRMSG_NUMBERTOOBIG, TRUE )
						exit function
					end if
				end if

			'' '%' | '&'
			case FB_TK_INTTYPECHAR, FB_TK_LNGTYPECHAR
				lexEatChar( )
				if( islong ) then
					hReportError( FB_ERRMSG_NUMBERTOOBIG, TRUE )
					exit function
				end if

			'' '!' | 'F' | 'f'
			case FB_TK_SGNTYPECHAR, CHAR_FUPP, CHAR_FLOW
				lexEatChar( )
				typ = FB_SYMBTYPE_SINGLE

			'' '#' | 'D' | 'd'
			case FB_TK_DBLTYPECHAR, CHAR_DUPP, CHAR_DLOW
				'' isn't it a '##'?
				if( lexGetLookAheadChar( ) <> FB_TK_DBLTYPECHAR ) then
					lexEatChar( )
					typ = FB_SYMBTYPE_DOUBLE
				end if

			end select

		end if
	end if

	if( typ = INVALID ) then
		if( not isfloat ) then
			if( islong ) then
				if( issigned ) then
					typ = FB_SYMBTYPE_LONGINT
				else
					typ = FB_SYMBTYPE_ULONGINT
				end if
			else
				if( issigned ) then
					typ = FB_SYMBTYPE_INTEGER
				else
					typ = FB_SYMBTYPE_UINT
				end if
			end if
		else
			typ = FB_SYMBTYPE_DOUBLE
		end if
	end if

end sub

'':::::
''string          = '"' { ANY_CHAR_BUT_QUOTE } '"'.   # less quotes
''
private sub lexReadString ( byval ps as zstring ptr, _
							tlen as integer, _
							byval flags as LEXCHECK_ENUM ) static

	static as zstring * 16 nval
	dim as integer rlen, p, ntyp, nlen

	*ps = 0
	tlen = 0
	rlen = 0

	lexEatChar( )								'' skip open quote

	do
		select case as const lexCurrentChar( )
		case 0, CHAR_CR, CHAR_LF
			exit do

		case CHAR_QUOTE
			lexEatChar( )
			'' check for double-quotes
			if( lexCurrentChar <> CHAR_QUOTE ) then
				exit do
			end if

		case CHAR_RSLASH
			'' process the scape sequence
			if( env.opt.escapestr ) then

				'' can't use '\', it will be escaped anyway because GAS
				lexEatChar( )
				*ps = FB_INTSCAPECHAR
				ps += 1
				rlen += 1

				select case lexCurrentChar( )
				'' if it's a literal number, convert to octagonal
				case CHAR_0 to CHAR_9, CHAR_AMP
					lexReadNumber( @nval, ntyp, nlen, 0 )
					if( nlen > 3 ) then
						nval[3] = 0
					end if

					nval = oct( valint( nval ) )
					'' save the oct len, or concatenation would fail if number chars follow
					*ps = len( nval )
					ps += 1
					rlen += 1

					p = 0
					do until( nval[p] = 0 )
						*ps = nval[p]
						ps += 1
						rlen += 1
						p += 1
					loop
					tlen += 1
					continue do
				end select

			end if
		end select

		rlen += 1
		if( rlen > FB_MAXLITLEN ) then
			if( (flags and LEXCHECK_NOLINECONT) = 0 ) then
				hReportError( FB_ERRMSG_LITSTRINGTOOBIG, TRUE )
				exit function
			else
				rlen -= 1
				exit do
			end if
		end if

		*ps = lexEatChar( )
		ps += 1
		tlen += 1
	loop

	'' null-term
	*ps = 0

end sub

'':::::
private sub hLoadWith( t as FBTOKEN, _
					   byval flags as LEXCHECK_ENUM ) static

	'' skip the '.'
	lexEatChar( )

	'' fake an identifier
	t.text   = "{fbwith}"
	t.tlen   = 8
	t.typ    = INVALID
	t.dotpos = 0
	t.sym    = env.withvar
	t.id 	 = FB_TK_ID
	t.class  = FB_TKCLASS_IDENTIFIER

	'' tell readChar to return '-' followed by '>'
	ctx.withcnt = 1 + 1

	'' force a re-read
	ctx.currchar = UINVALID

end sub

'':::::
private sub lexNextToken ( t as FBTOKEN, _
						   byval flags as LEXCHECK_ENUM ) static
	dim as uinteger char
	dim as integer islinecont, isnumber, lgt
	dim as FBSYMBOL ptr s

reread:
	t.text[0] = 0									'' t.text = ""
	t.tlen 	  = 0
	t.sym 	  = NULL

	'' skip white space
	islinecont = FALSE
	do
		char = lexCurrentChar( )

		'' !!!FIXME!!! this shouldn't be here
		'' only emit current src line if it's not on an inc file
		if( env.clopt.debug ) then
			if( env.reclevel = 0 ) then
				if( (char = CHAR_CR) or (char = CHAR_LF) or (char = 0) ) then
					astAdd( astNewLIT( curline, FALSE ) )
					curline = ""
				end if
			end if
		end if

		select case as const char
		'' EOF?
		case 0
			t.id    = FB_TK_EOF
			t.class = FB_TKCLASS_DELIMITER
			exit sub

		'' line continuation?
		case CHAR_UNDER

			'' alread skipping?
			if( islinecont ) then
				lexEatChar( )
				continue do
			end if

			'' check for line cont?
			if( (flags and LEXCHECK_NOLINECONT) = 0 ) then

				'' is next char a valid identifier char? then, read it
				select case as const lexGetLookAheadChar( )
				case CHAR_AUPP to CHAR_ZUPP, CHAR_ALOW to CHAR_ZLOW, _
					 CHAR_0 to CHAR_9, CHAR_UNDER
                	goto readid

				'' otherwise, skip until new-line is found
				case else
					lexEatChar( )
					islinecont = TRUE
					continue do
				end select

			'' else, take it as-is
			else
				exit do
			end if

		'' EOL
		case CHAR_CR, CHAR_LF
			lexEatChar( )

			'' CRLF on DOS, LF only on *NIX
			if( char = CHAR_CR ) then
				if( lexCurrentChar( ) = CHAR_LF ) then
					lexEatChar( )
				end if
			end if

			if( not islinecont ) then
				t.id    = FB_TK_EOL
				t.class = FB_TKCLASS_DELIMITER
				exit sub
			else
				ctx.linenum += 1
				islinecont = FALSE
				continue do
			end if

		'' white-space?
		case CHAR_TAB, CHAR_SPACE
			if( not islinecont ) then
				if( (flags and LEXCHECK_NOWHITESPC) <> 0 ) then
					exit do
				end if
			end if

			lexEatChar( )

		''
		case else
			if( not islinecont ) then
				exit do
			end if

			lexEatChar( )
		end select

	loop

	ctx.lastfilepos = ctx.filepos - ctx.bufflen - 1

	select case as const char
	'':::::
	case CHAR_DOT

	    isnumber = FALSE

	    '' only check for fpoint literals if not inside a comment or parsing an $include
	    if( (flags and (LEXCHECK_NOLINECONT or LEXCHECK_NOSUFFIX)) = 0 ) then

	    	select case as const lexGetLookAheadChar( TRUE )
	    	'' 0 .. 9
	    	case CHAR_0 to CHAR_9
				isnumber = TRUE

			'' E | D
			case CHAR_ELOW, CHAR_EUPP, CHAR_DLOW, CHAR_DUPP
				if( ctx.lasttoken <> CHAR_RPRNT ) then
					if( ctx.lasttoken <> CHAR_RBRACKET ) then
						'' not WITH?
						if( env.withvar = NULL ) then
							isnumber = TRUE
						else
							hLoadWith( t, flags )
							exit sub
						end if
					end if
				end if

			'' anything else
			case else
				if( (ctx.lasttoken <> CHAR_RPRNT) and _
					(ctx.lasttoken <> CHAR_RBRACKET) ) then
					'' WITH?
					if( env.withvar <> NULL ) then
						hLoadWith( t, flags )
						exit sub
					end if
				end if
			end select

		end if

		if( isnumber ) then
			goto readnumber
		else
			goto readid
		end if

	'':::::
	case CHAR_AMP
		select case lexGetLookAheadChar( )
		case CHAR_HUPP, CHAR_HLOW, CHAR_OUPP, CHAR_OLOW, CHAR_BUPP, CHAR_BLOW
			goto readnumber
		end select
		t.class     = FB_TKCLASS_OPERATOR
		t.id		= lexEatChar( )
		t.tlen		= 1
		t.typ		= t.id
		t.text[0] = char                            '' t.text = chr$( char )
		t.text[1] = 0                               '' /

	'':::::
	case CHAR_0 to CHAR_9
readnumber:
		lexReadNumber( @t.text, t.id, t.tlen, flags )
		t.class 	= FB_TKCLASS_NUMLITERAL
		t.typ		= t.id

	'':::::
	case CHAR_AUPP to CHAR_ZUPP, CHAR_ALOW to CHAR_ZLOW
readid:
		lexReadIdentifier( @t.text, t.tlen, t.typ, t.dotpos, flags )

		t.sym = symbLookup( @t.text, t.id, t.class )

		if( (flags and LEXCHECK_NODEFINE) = 0 ) then
			'' is it a define?
			s = symbFindByClass( t.sym, FB_SYMBCLASS_DEFINE )
			if( s <> NULL ) then
				hLoadDefine( s  )
				goto reread
        	end if
        end if

	'':::::
	case CHAR_QUOTE
		t.id		= FB_TK_STRLIT
		lexReadString( @t.text, t.tlen, flags )
		t.class 	= FB_TKCLASS_STRLITERAL
		t.typ		= t.id

	'':::::
	case else
		t.id		= lexEatChar( )
		t.tlen		= 1
		t.typ		= t.id

		t.text[0] = char                            '' t.text = chr$( char )
		t.text[1] = 0                               '' /

		select case as const char
		'':::
		case CHAR_LT, CHAR_GT, CHAR_EQ
			t.class = FB_TKCLASS_OPERATOR

			select case char
			case CHAR_LT
				select case lexCurrentChar( TRUE )
				'' '<='?
				case CHAR_EQ
					'' t.text += chr$( lexEatChar )
					t.text[t.tlen+0] = lexEatChar( )
					t.text[t.tlen+1] = 0
					t.tlen += 1
					t.id   = FB_TK_LE

				'' '<>'?
				case CHAR_GT
					'' t.text += chr$( lexEatChar )
					t.text[t.tlen+0] = lexEatChar( )
					t.text[t.tlen+1] = 0
					t.tlen += 1
					t.id   = FB_TK_NE

				case else
					t.id = FB_TK_LT
				end select

			case CHAR_GT
				'' '>='?
				if( lexCurrentChar( TRUE ) = CHAR_EQ ) then
					'' t.text += chr$( lexEatChar )
					t.text[t.tlen+0] = lexEatChar( )
					t.text[t.tlen+1] = 0
					t.tlen += 1
					t.id   = FB_TK_GE
				else
					t.id = FB_TK_GT
				end if

			case CHAR_EQ
				'' '=>'?
				if( lexCurrentChar( TRUE ) = CHAR_GT ) then
					'' t.text += chr$( lexEatChar )
					t.text[t.tlen+0] = lexEatChar( )
					t.text[t.tlen+1] = 0
					t.tlen += 1
					t.id   = FB_TK_DBLEQ
				else
					t.id = FB_TK_EQ
				end if
			end select

		'':::
		case CHAR_PLUS, CHAR_MINUS, CHAR_TIMES, CHAR_SLASH, CHAR_RSLASH
			t.class = FB_TKCLASS_OPERATOR

			'' check for type-field dereference
			if( char = CHAR_MINUS ) then
				if( lexCurrentChar( TRUE ) = CHAR_GT ) then
					'' t.text += chr$( lexEatChar )
					t.text[t.tlen+0] = lexEatChar( )
					t.text[t.tlen+1] = 0
					t.tlen += 1
					t.id   = FB_TK_FIELDDEREF
				end if
			end if

		'':::
		case CHAR_LPRNT, CHAR_RPRNT, CHAR_COMMA, CHAR_COLON, CHAR_SEMICOLON, CHAR_AT
			t.class	= FB_TKCLASS_DELIMITER

		'':::
		case CHAR_SPACE, CHAR_TAB
			t.class	= FB_TKCLASS_DELIMITER

			do
				select case as const lexCurrentChar( )
				case CHAR_SPACE, CHAR_TAB
					t.text[t.tlen] = lexEatChar( )        	'' t.text += chr$( lexEatChar )
					t.tlen += 1
				case else
					t.text[t.tlen] = 0                      '' t.text += chr$( 0 )
					exit do
				end select
			loop

		'':::
		case else
			t.class = FB_TKCLASS_UNKNOWN
		end select

	end select

end sub

'':::::
private sub hCheckPP( )

	'' not already inside the PP? (ie: not skipping a false #IF or #ELSE)
	if( ctx.reclevel = 0 ) then
		'' '#' char?
		if( ctx.tokenTB(0).id = CHAR_SHARP ) then
			'' at beginning of line (or top of source-file)?
			if( (ctx.lasttoken = FB_TK_EOL) or (ctx.lasttoken = INVALID) ) then
                ctx.reclevel += 1
                lexSkipToken( )

       			'' not a keyword? error, parser will catch it..
       			if( ctx.tokenTB(0).class <> FB_TKCLASS_KEYWORD ) then
       				ctx.reclevel -= 1
       				exit sub
       			end if

       			'' pp failed? exit
       			if( not lexPreProcessor( ) ) then
       				ctx.reclevel -= 1
       				exit sub
       			end if

				ctx.reclevel -= 1
			end if
		end if
	end if

end sub

'':::::
function lexGetToken( byval flags as LEXCHECK_ENUM ) as integer static

    if( ctx.tokenTB(0).id = INVALID ) then
    	lexNextToken( ctx.tokenTB(0), flags )
    	hCheckPP( )
    end if

    function = ctx.tokenTB(0).id

end function

'':::::
function lexGetClass( byval flags as LEXCHECK_ENUM ) as integer static

    if( ctx.tokenTB(0).id = INVALID ) then
    	lexNextToken( ctx.tokenTB(0), flags )
    	hCheckPP( )
    end if

    function = ctx.tokenTB(0).class

end function

'':::::
function lexGetLookAhead( byval k as integer, _
						  byval flags as LEXCHECK_ENUM ) as integer static

    if( k > FB_LEX_MAXK ) then
    	exit function
    end if

    if( ctx.tokenTB(k).id = INVALID ) then
	    lexNextToken( ctx.tokenTB(k), flags )
	end if

	if( k > ctx.k ) then
		ctx.k = k
	end if

	function = ctx.tokenTB(k).id

end function

'':::::
function lexGetLookAheadClass( byval k as integer, _
							   byval flags as LEXCHECK_ENUM ) as integer static

    if( k > FB_LEX_MAXK ) then
    	exit function
    end if

    if( ctx.tokenTB(k).id = INVALID ) then
    	lexNextToken( ctx.tokenTB(k), flags )
    end if

	if( k > ctx.k ) then
		ctx.k = k
	end if

    function = ctx.tokenTB(k).class

end function

'':::::
private sub hMoveKDown( ) static
    dim i as integer

    for i = 0 to ctx.k-1
    	ctx.tokenTB(i) = ctx.tokenTB(i+1)
    next i

    ctx.tokenTB(ctx.k).id = INVALID

    ctx.k -= 1

end sub

'':::::
sub lexEatToken( byval token as string, _
				 byval flags as LEXCHECK_ENUM ) static

    ''
    token = ctx.tokenTB(0).text

    ''
    if( ctx.tokenTB(0).id = FB_TK_EOL ) then
    	ctx.linenum += 1
    	ctx.colnum  = 1
    end if

    ctx.lasttoken = ctx.tokenTB(0).id

    if( ctx.k = 0 ) then
    	lexNextToken( ctx.tokenTB(0), flags )
    else
    	hMoveKDown( )
    end if

    hCheckPP( )

end sub

'':::::
sub lexSkipToken( byval flags as LEXCHECK_ENUM ) static

    if( ctx.tokenTB(0).id = FB_TK_EOL ) then
    	ctx.linenum += 1
    	ctx.colnum  = 1
    end if

    ctx.lasttoken = ctx.tokenTB(0).id

    ''
    if( ctx.k = 0 ) then
    	lexNextToken( ctx.tokenTB(0), flags )
    else
    	hMoveKDown( )
    end if

    hCheckPP( )

end sub

'':::::
sub lexReadLine( byval endchar as uinteger = INVALID, _
				 byval dst as string, _
				 byval skipline as integer = FALSE ) static

    dim char as uinteger

	if( not skipline ) then
		dst = ""
	end if

    '' check look ahead tokens if any
    do while( ctx.k > 0 )
    	select case ctx.tokenTB(0).id
    	case FB_TK_EOF, FB_TK_EOL, endchar
    		exit sub
    	case else
    		if( not skipline ) then
   				dst += ctx.tokenTB(0).text
    		end if
    	end select

    	hMoveKDown( )
    loop

   	'' check current token
    select case ctx.tokenTB(0).id
    case FB_TK_EOF, FB_TK_EOL, endchar
   		exit sub
   	case else
   		if( not skipline ) then
    		dst += ctx.tokenTB(0).text
   		end if
   	end select

    ''
	do
		char = lexCurrentChar( )

		'' !!!FIXME!!! this shouldn't be here
		'' only emit current src line if it's not on an inc file
		if( env.clopt.debug ) then
			if( env.reclevel = 0 ) then
				if( (char = CHAR_CR) or (char = CHAR_LF) or (char = 0) ) then
					astAdd( astNewLIT( curline, FALSE ) )
					curline = ""
				end if
			end if
		end if

		'' EOF?
		select case as const char
		case 0
			ctx.tokenTB(0).id = FB_TK_EOF
			ctx.tokenTB(0).class = FB_TKCLASS_DELIMITER
			exit sub

		'' EOL?
		case CHAR_CR, CHAR_LF
			lexEatChar( )
			'' CRLF on DOS, LF only on *NIX
			if( char = CHAR_CR ) then
				if( lexCurrentChar( ) = CHAR_LF ) then lexEatChar
			end if

			ctx.tokenTB(0).id 	 = FB_TK_EOL
			ctx.tokenTB(0).class = FB_TKCLASS_DELIMITER
			exit sub

		case else
			'' closing char?
			if( char = endchar ) then
				ctx.tokenTB(0).id 	 = endchar
				ctx.tokenTB(0).class = FB_TKCLASS_DELIMITER
				exit sub
			end if
		end select

		lexEatChar( )
		if( not skipline ) then
			dst += chr( char )
		end if
	loop

end sub

'':::::
sub lexSkipLine( ) static

	lexReadLine( , byval NULL, TRUE )

end sub


''::::
function lexLineNum( ) as integer

	function = ctx.linenum

end function

''::::
function lexColNum( ) as integer

	function = ctx.colnum - ctx.tokenTB(0).tlen + 1

end function

''::::
function lexGetText( ) as zstring ptr

    function = @ctx.tokenTB(0).text

end function

''::::
function lexGetTextLen( ) as integer

	function = ctx.tokenTB(0).tlen

end function

''::::
function lexGetType( ) as integer

	function = ctx.tokenTB(0).typ

end function

''::::
function lexGetSymbol( ) as FBSYMBOL ptr

	function = ctx.tokenTB(0).sym

end function

''::::
function lexGetPeriodPos( ) as integer

	function = ctx.tokenTB(0).dotpos

end function

'':::::
sub lexSetToken( byval id as integer, _
						byval class as integer )

	ctx.tokenTB(0).tlen 	= 0
	ctx.tokenTB(0).id 		= id
	ctx.tokenTB(0).class 	= class

end sub

'':::::
function lexPeekCurrentLine( token_pos as string ) as string
	static as zstring * 1024+1 buffer
	dim as string res
	dim as integer p, old_p, start, token_len
	dim as zstring ptr c

	function = ""

	'' get file contents around current token
	old_p = seek( env.inf.num )
	p = ctx.lastfilepos - 512
	start = 512
	if( p < 0 ) then
		start += p
		p = 0
	end if
	get #env.inf.num, p + 1, buffer
	seek #env.inf.num, old_p

	'' find source line start
	c = strptr(buffer) + start
	token_len = 0
	if( start > 0 ) then
		c = c - 1
		while( ( *c <> 10 ) and ( *c <> 13 ) and ( start > 0 ) )
			token_len += 1
			c -= 1
			start -= 1
		wend
	end if

	'' build source line
	res = ""
	token_pos = ""
	if( start > 0 ) then
		c += 1
	end if
	while( ( *c <> 0 ) and ( *c <> 10 ) and ( *c <> 13 ) )
		res += chr(*c)
		if( token_len > 0 ) then
			token_pos += chr( iif( *c = 9, 9, 32 ) )
			token_len -= 1
		end if
		c += 1
	wend
	token_pos += "^"

	function = res

end function
