
;
;====================================================================
;	- Desenvolver um programa capaz de ler um arquivo 
;em formato texto (arquivo de entrada),processar os dados
;lidos e, ao final, escrever um arquivo com os resultados
;obtidos (arquivo de saída).
;
;	- Depois de lidos os números, o programa deverá calcular
;o dígito verificador de cada número, a soma dos valores e a
;média aritmética dos mesmos
;
;	- os valores lidos e calculados deverão ser escritos no
;arquivo de saída.
;
;====================================================================
;
;
	.model		small
	.stack
		
CR		equ		0dh
LF		equ		0ah

	.data
FileNameSrc		db		256 dup (?)		; Nome do arquivo a ser lido
FileNameDst		db		256 dup (?)		; Nome do arquivo a ser escrito
FileHandleSrc	dw		0				; Handler do arquivo origem
FileHandleDst	dw		0				; Handler do arquivo destino
FileBuffer		db		10 dup (?)		; Buffer de leitura/escrita do arquivo
Bufferlinhaint 	db		10 dup (?) 	; Buffer linha
Bufferlinhafrac 	db		10 dup (?) 	; Buffer linha
Bufferfimint	dw		100 dup (?)	; Buffer valores
Bufferfimfrac 	dw		100 dup (?)	; Buffer valores
contbuffint	db		0			; cont bufint
contbufffrac	db		0			; cont bufdec
statusfrac		db		0			; statusint
statusinvalid	db		0			; se achou inv lin
linhasvalidas	db		0			; nmr linhas valida
TempBuffer		dw		0			;buffer temporaria
controlbufint	db		0			;
contdoset		db		0			;

MsgPedeArquivoSrc	db	"Nome do arquivo origem: ", 0
MsgPedeArquivoDst	db	"Nome do arquivo destino: ", 0
MsgErroOpenFile		db	"Erro na abertura do arquivo.", CR, LF, 0
MsgErroCreateFile	db	"Erro na criacao do arquivo.", CR, LF, 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", CR, LF, 0
MsgErroWriteFile	db	"Erro na escrita do arquivo.", CR, LF, 0
MsgCRLF				db	CR, LF, 0

MAXSTRING	equ		15
String	db		MAXSTRING dup (?)		; Usado na funcao gets

	.code
	.startup

	call		GetFileNameSrc     ; Pega o nome do arquivoSRC
	lea		dx,FileNameSrc
	call		fopen
	mov		FileHandleSrc,bx
	jnc		Continua1
	lea		bx, MsgErroOpenFile
	call		printf_s
	.exit	1
Continua1:

	call		GetFileNameDst  ; Pega o nome do arquivoDST
	lea		dx,FileNameDst
	call		fcreate
	mov		FileHandleDst,bx
	jnc		Continua2
	mov		bx,FileHandleSrc
	call		fclose
	lea		bx, MsgErroCreateFile
	call		printf_s
	.exit	1
Continua2:

	mov		bx,FileHandleSrc
	call		getChar
	jnc		Continua3
	lea		bx, MsgErroReadFile
	call		printf_s
	mov		bx,FileHandleSrc
	call		fclose
	mov		bx,FileHandleDst
	call		fclose
	.exit	1
Continua3:

	cmp		ax,0
	jz		TerminouArquivo

			
	cmp		FileBuffer,9
	jz		Continua2
	cmp		FileBuffer,20h
	jz		Continua2
	cmp		FileBuffer,'.'
	jz		ativastatusfrac
	cmp		FileBuffer,','
	jz		ativastatusfrac
	cmp		FileBuffer,0dh
	jz		FimdaLinha
	cmp		FileBuffer,0ah
	jz		FimdaLinha
	cmp		FileBuffer,48
	jb		caracterinvalido
	cmp		FileBuffer,57
	ja		caracterinvalido
	;sub		FileBuffer,48
	cmp		statusfrac, 1
	jz		Fracsbuffer
	jmp		Inteirosbuffer
	
Inteirosbuffer:
	lea 		bp,Bufferlinhaint
	add		bp,contbuffint
	mov 		[bp],FileBuffer
	mov		cx,contbuffint
	cmp		contbuffint,2
	ja		caractereinvalido
	add		cx,1
	mov		contbuffint,cx
	jmp		Continua2
		
caractereinvalido:
	mov		statusinvalid,1
	jmp		Continua2
	
ativastatusfrac:
	cmp		1,statusfrac
	jz		caractereinvalido
	mov		statusfrac,1
	jmp		Continua2	

Fracsbuffer:
	lea 		bp,Bufferlinhafrac
	add		bp,contbufffrac
	mov 		[bp],FileBuffer
	cmp		contbufffrac,1
	ja		caractereinvalido
	mov		cx,contbufffrac
	add		cx,1
	mov		contbufffrac,cx
	jmp		Continua2
		
FimdaLinha:
	cmp	statusinvalid,1
	jz	linhainvalida
	cmp	contbuffint,0
	jz	linhainvalida
	cmp	statusfrac,0
	jz	linhainvalida
	cmp	contbufffrac,0
	jz	linhainvalida
	;add	linhasvalidas,1
calculaint:
	cmp	contbuffint, 3
	jz	tresnumeros
	jmp 	stchteste
tresnumeros:
	cmp	Bufferlinhaint,53
	jae	linhainvalida
	add	linhasvalidas,1
	jmp 	stchteste
	;mov	TempBuffer	,Bufferlinhaint
	;mov	ax,100
	;mul	TempBuffer
	;mov	Bufferfimint+controlbufint,ax
	;add	controlbufint,2
	;;mov	Bufferfimint+controlbufint,dx
	;add	controlbufint,2

linhainvalida:
	jmp zerarvariaveis

zerarvariaveis:
	mov	statusinvalid,0
	mov	contbuffint,0
	mov	statusfrac,0
	mov	contbufffrac,0
	jmp	zerarvetores
		
zerarvetores:
limpabufffrac:
	lea 	bp,Bufferlinhafrac
	add		bp,contbufffrac
	mov		[bp],' '	
	mov		cx,contbufffrac
	add		cx,1
	mov		contbufffrac,cx
	cmp		contbufffrac,10
	jnz		limpabufffrac
	mov		contbufffrac,0
limpabuffint:
	lea 		bp,Bufferlinhaint
	add		bp,contbuffint
	mov		[bp],' '	
	mov		cx,contbuffint
	add		cx,1
	mov		contbuffint,cx
	cmp		contbuffint,10
	jnz		limpabuffint
	mov		contbuffint,0
Buscarnovalinha:
	jmp 		Continua2


stchteste:
loopset:
	lea		bp,Bufferlinhaint
	add		bp, contdoset
	mov		dl,[bp]
	mov		bx,FileHandleDst
	call		setChar
	jc		erroresc
	add		contdoset,1
	cmp		contbuffint,contdoset
	ja		loopset
	mov		contdoset,0
	
	mov		dl,','
	call		setChar
	jc		erroresc

loopset2:
	lea		bp,Bufferlinhafrac
	add		bp, contdoset
	mov		dl,[bp]
	mov		bx,FileHandleDst
	call		setChar
	jc		erroresc
	add		contdoset,1
	cmp		contbufffrac,contdoset
	ja		loopset

	mov		dl,0dh
	call		setChar
	jc		erroresc
	
	jmp		linhainvalida
	
	;	if ( setChar(FileHandleDst, DL) == 0) continue;
	;mov		bx,FileHandleDst
	;call		setChar
	;jnc		Continua2
erroresc:
	;	printf ("Erro na escrita....;)")
	;	fclose(FileHandleSrc)
	;	fclose(FileHandleDst)
	;	exit(1)
	lea		bx, MsgErroWriteFile
	call	printf_s
	mov		bx,FileHandleSrc		; Fecha arquivo origem
	call	fclose
	mov		bx,FileHandleDst		; Fecha arquivo destino
	call	fclose
	.exit	1
	
	;} while(1);
		
TerminouArquivo:
	;fclose(FileHandleSrc)
	;fclose(FileHandleDst)
	;exit(0)
	mov		bx,FileHandleSrc	; Fecha arquivo origem
	call	fclose
	mov		bx,FileHandleDst	; Fecha arquivo destino
	call	fclose
	.exit	0

		
;--------------------------------------------------------------------
;Funcao Pede o nome do arquivo de origem salva-o em FileNameSrc
;--------------------------------------------------------------------
GetFileNameSrc	proc	near
	;printf("Nome do arquivo origem: ")
	lea		bx, MsgPedeArquivoSrc
	call	printf_s

	;gets(FileNameSrc);
	lea		bx, FileNameSrc
	call	gets
	
	;printf("\r\n")
	lea		bx, MsgCRLF
	call	printf_s
	
	ret
GetFileNameSrc	endp


;--------------------------------------------------------------------
;Funcao Pede o nome do arquivo de destino salva-o em FileNameDst
;--------------------------------------------------------------------
GetFileNameDst	proc	near
	;printf("Nome do arquivo destino: ");
	lea		bx, MsgPedeArquivoDst
	call	printf_s
	
	;gets(FileNameDst);
	lea		bx, FileNameDst
	call	gets
	
	;printf("\r\n")
	lea		bx, MsgCRLF
	call	printf_s
	
	ret
GetFileNameDst	endp

;--------------------------------------------------------------------
;Função	Abre o arquivo cujo nome está no string apontado por DX
;		boolean fopen(char *FileName -> DX)
;Entra: DX -> ponteiro para o string com o nome do arquivo
;Sai:   BX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fopen	proc	near
	mov		al,0
	mov		ah,3dh
	int		21h
	mov		bx,ax
	ret
fopen	endp

;--------------------------------------------------------------------
;Função Cria o arquivo cujo nome está no string apontado por DX
;		boolean fcreate(char *FileName -> DX)
;Sai:   BX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fcreate	proc	near
	mov		cx,0
	mov		ah,3ch
	int		21h
	mov		bx,ax
	ret
fcreate	endp

;--------------------------------------------------------------------
;Entra:	BX -> file handle
;Sai:	CF -> "0" se OK
;--------------------------------------------------------------------
fclose	proc	near
	mov		ah,3eh
	int		21h
	ret
fclose	endp

;--------------------------------------------------------------------
;Função	Le um caractere do arquivo identificado pelo HANLDE BX
;		getChar(handle->BX)
;Entra: BX -> file handle
;Sai:   dl -> caractere
;		AX -> numero de caracteres lidos
;		CF -> "0" se leitura ok
;--------------------------------------------------------------------
getChar	proc	near
	mov		ah,3fh
	mov		cx,1
	lea		dx,FileBuffer
	int		21h
	;mov		dl,FileBuffer
	ret
getChar	endp
		
;--------------------------------------------------------------------
;Entra: BX -> file handle
;       dl -> caractere
;Sai:   AX -> numero de caracteres escritos
;		CF -> "0" se escrita ok
;--------------------------------------------------------------------
setChar	proc	near
	mov		ah,40h
	mov		cx,1
	mov		FileBuffer,dl
	lea		dx,FileBuffer
	int		21h
	ret
setChar	endp	

;
;--------------------------------------------------------------------
;Funcao Le um string do teclado e coloca no buffer apontado por BX
;		gets(char *s -> bx)
;--------------------------------------------------------------------
gets	proc	near
	push	bx

	mov		ah,0ah						; Lê uma linha do teclado
	lea		dx,String
	mov		byte ptr String, MAXSTRING-4	; 2 caracteres no inicio e um eventual CR LF no final
	int		21h

	lea		si,String+2					; Copia do buffer de teclado para o FileName
	pop		di
	mov		cl,String+1
	mov		ch,0
	mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
	mov		es,ax
	rep 	movsb

	mov		byte ptr es:[di],0			; Coloca marca de fim de string
	ret
gets	endp

;====================================================================
; A partir daqui, estão as funções já desenvolvidas
;	1) printf_s
;====================================================================
	
;--------------------------------------------------------------------
;Função Escrever um string na tela
;		printf_s(char *s -> BX)
;--------------------------------------------------------------------
printf_s	proc	near
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

	push	bx
	mov		ah,2
	int		21H
	pop		bx

	inc		bx		
	jmp		printf_s
		
ps_1:
	ret
printf_s	endp

;--------------------------------------------------------------------
;--------------------------------------------------------------------

;
;--------------------------------------------------------------------
;Função:Converte um ASCII-DECIMAL para HEXA
;Entra: (S) -> DS:BX -> Ponteiro para o string de origem
;Sai:	(A) -> AX -> Valor "Hex" resultante
;Algoritmo:
;	A = 0;
;	while (*S!='\0') {
;		A = 10 * A + (*S - '0')
;		++S;
;	}
;	return
;--------------------------------------------------------------------
atoi	proc near

		; A = 0;
		mov		ax,0
		
atoi_2:
		; while (*S!='\0') {
		cmp		byte ptr[bx], 0
		jz		atoi_1

		; 	A = 10 * A
		mov		cx,10
		mul		cx

		; 	A = A + *S
		mov		ch,0
		mov		cl,[bx]
		add		ax,cx

		; 	A = A - '0'
		sub		ax,'0'

		; 	++S
		inc		bx
		
		;}
		jmp		atoi_2

atoi_1:
		; return
		ret

atoi	endp

;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------
