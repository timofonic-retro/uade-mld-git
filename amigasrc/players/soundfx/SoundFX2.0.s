;***************************************************************
;*    Sound FX 2.0 Moduleplayer for Eagleplayer/Delitracker    *
;*    SoundFX  = Modified Soundtracker !!                      *
;*    adapted by Buggs of DEFECT                               *
;***************************************************************
	;
	incdir	include:
	include	misc/EaglePlayer.i

	SECTION	0,Code
test	=	0
	ifne	test
	lea	mod,a0
	move.l	a0,fx_data
	bsr	getinfos
	endc

	PLAYERHEADER	Tags
	dc.b '$VER: SoundFX 2.0 Eagleplayer V1.1 (Aug/29/93)',0,0
Tags
	dc.l	DTP_RequestDTVersion,$ffff
	dc.l	EP_PlayerVersion,4
	dc.l	DTP_Volume,SetVoices
	dc.l	DTP_Balance,SetVoices
	dc.l	EP_Voices,SetVoices

	dc.l	DTP_PlayerVersion,3
	dc.l	DTP_PlayerName,Player
	dc.l	DTP_Creator,Creator

	dc.l	DTP_Check2,testmod

	dc.l	DTP_Interrupt,Playsong

	dc.l	DTP_InitSound,InitSnd
	dc.l	DTP_EndSound,PlayDisable

	dc.l	DTP_InitPlayer,InitPlay
	dc.l	DTP_EndPlayer,EndPlay

	dc.l	DTP_NextPatt,FX_NextPattern
	dc.l	DTP_PrevPatt,FX_BackPattern
	dc.l	EP_Getpositionnr,FX_Getposnr

	dc.l	EP_flags,EPB_Volvoices!EPB_Packable!EPB_Save!EPB_restart!EPB_songend!EPB_Volume!EPB_Balance!EPB_Voices!EPB_Analyzer!EPB_Prevpatt!EPB_Nextpatt

	dc.l	EP_StructInit,StrukInit

	dc.l	EP_Get_ModuleInfo,GetInfos

	dc.l	0
;=================== Player/Creatorname und lokale Daten ===============

Player	dc.b 	`SoundFX 2.0`,0
Creator	dc.b 	`C.Haller and C.A.Weber,`,10
	dc.b	`adapted by Buggs of DEFECT`,0,0

DTBASE		dc.l	0
FX_Data:	dc.l	0

FX_VolVoice1	dc.w	1
FX_VolVoice2	dc.w	1
FX_VolVoice3	dc.w	1
FX_VolVoice4	dc.w	1

FX_Structadr	ds.b	ups_sizeof

FX_InfoBuffer:	
	dc.l	MI_Samples,0			;4
	dc.l	MI_MaxSamples,15		;12
	dc.l	MI_Length,0			;20
	dc.l	MI_Pattern,0			;28
	dc.l	MI_SongSize,0			;36
	dc.l	MI_SamplesSize,0		;44
	dc.l	MI_Calcsize,0			;52
	dc.l	0
	cnop	0,4
;================ Struktur übergeben =====================================
Strukinit:
	lea	FX_StructAdr(pc),a0
Return	rts
;=======================================================================
FX_NextPattern:
	clr.w	Break
	clr.l	PosCounter		;PatternPos löschen

	addq.l	#$01,TrackPos		;Position erhöhen

	move.w	AnzPatt(pc),d0		;AnzahlPosition
	move.l	TrackPos(pc),d1		;Aktuelle Pos
	cmp.w	d0,d1			;Ende?
	bne.s	.NoEndPattern		;nein!

	move.l	a2,-(sp)
	move.l	dtbase(Pc),a2
	move.l	DTG_Songend(a2),a2
	jsr	(A2)
	move.l	(sp)+,a2

	clr.l	TrackPos		;ja/ Sound von vorne
.NoEndPattern
	move.l	trackpos(pc),d0
	rts
;=========================================================================
FX_Backpattern
	lea	trackpos(pc),a0
	clr.w	Break-trackpos(a0)
	clr.l	PosCounter-trackpos(a0)	;PatternPos löschen

	subq.l	#1,(a0)		;Position erhöhen
	bge.s	.ok

	moveq	#0,d0
	move.w	AnzPatt(pc),d0		;AnzahlPosition
	subq.l	#1,d0
	move.l	d0,(a0)
.ok
	move.l	(a0),d0
	rts
;==========================================================================
FX_GetPosNr:
	move.l	Trackpos(pc),d0
	rts
;================ Daten in die Userprogramm-Struktur übergeben ===========
GetPera6
	move.l	d0,-(sp)
	move.w	(A6),d0
	bsr	fx_getper
	move.l	(sp)+,d0
	rts
GetPerd2
	move.l	d0,-(sp)
	move.w	d2,d0
	bsr	fx_getper
	move.l	(sp)+,d0
	rts
fx_getper
	move.l	a1,-(sp)

	lea	FX_Structadr(pc),a1	;1.Kanal
	cmp.l	#$dff0a0,a5
	beq.s	.yes
	lea	FX_Structadr+ups_modulo(pc),a1	;2.Kanal
	cmp.l	#$dff0b0,a5
	beq.s	.yes
	lea	FX_Structadr+ups_modulo*2(pc),a1	;3.Kanal
	cmp.l	#$dff0c0,a5
	beq.s	.yes
	lea	FX_Structadr+ups_modulo*3(pc),a1	;4.Kanal
.yes
	and.w	#$EFFF,d0
	move.w	d0,UPS_Voice1per(a1)
	move.l	(sp)+,a1
	rts
;=======================================================================
Getvoice:
	movem.l	d1/a1,-(sp)

	lea	FX_Structadr(pc),a1	;1.Kanal
	cmp.l	#$dff0a0,a4
	beq.s	.yes
	lea	FX_Structadr+ups_modulo(pc),a1	;2.Kanal
	cmp.l	#$dff0b0,a4
	beq.s	.yes
	lea	FX_Structadr+ups_modulo*2(pc),a1	;3.Kanal
	cmp.l	#$dff0c0,a4
	beq.s	.yes
	lea	FX_Structadr+ups_modulo*3(pc),a1	;4.Kanal
.yes
	move.w	8(a6),UPS_Voice1Len(a1)	;Samplelänge
	move.l	4(a6),UPS_Voice1Adr(a1)	;Sampleadresse
	move.w	(a6),d1
	and.w	#$EFFF,d1
	move.w	d1,UPS_Voice1Per(a1)

	moveq	#0,d1
	cmp.w	#1,14(a6)		;Repeat on ?
	bhi.s	.ok
	moveq	#1,d1			;nein,Repeat "off" setzen
.ok	move.w	d1,UPS_Voice1Repeat(a1)

	move.w	8(a6),UPS_Voice1len(a1)	;Länge/2

	movem.l	(sp)+,d1/a1
	rts
*-----------------------------------------------------------------------*
*		d0 Bit 0-3 = Set Voices Bit=1 Voice on			*
SetVoices:	lea	FX_StructAdr+UPS_DmaCon(pc),a0
		move.w	EPG_Voices(a5),(a0)				;Voices retten
		lea	FX_VolVoice1(pc),a1
		move.l	EPG_Voice1Vol(a5),(a1)
		move.l	EPG_Voice3Vol(a5),4(a1)

		lea	FX_StructAdr+UPS_Voice1Vol(pc),a0
		lea	$dff0a0,a4
		moveq	#3,d1
.SetNew		moveq	#0,d3
		move.w	(a0),d3
		bsr.s	FX_SetVoices
		moveq	#UPS_Modulo,d3
		add.l	d3,a0
		addq.l	#8,a4
		addq.l	#8,a4
		dbf	d1,.SetNew
		rts

*-----------------------------------------------------------------------*
FX_SetVoices:	movem.l	a0/d3,-(a7)
		and.w	#$7f,d3
		lea	FX_StructAdr(pc),a0
		cmp.l	#$dff0a0,a4			;Left Volume
		bne.s	.NoVoice1
		move.w	d3,UPS_Voice1Vol(a0)
		mulu.w	FX_VolVoice1(pc),d3
		bra.b	.SetIt
.NoVoice1:	cmp.l	#$dff0b0,a4			;Right Volume
		bne.s	.NoVoice2
		move.w	d3,UPS_Voice2Vol(a0)
		mulu.w	FX_VolVoice2(pc),d3
		bra.b	.SetIt
.NoVoice2:	cmp.l	#$dff0c0,a4			;Right Volume
		bne.s	.NoVoice3
		move.w	d3,UPS_Voice3Vol(a0)
		mulu.w	FX_VolVoice3(pc),d3
		bra.b	.SetIt
.NoVoice3:	move.w	d3,UPS_Voice4Vol(a0)
		mulu.w	FX_VolVoice4(pc),d3
.SetIt:		lsr.w	#6,d3
		move.w	d3,8(a4)
.Return:	movem.l	(a7)+,a0/d3
		rts
;=======================================================================
Testmod
	move.l	dtg_ChkData(a5),a0
	move.l	124(a0),d0
	sub.l	#'SO31',d0
	rts
;=======================================================================
InitPlay
	moveq	#0,d0
	move.l	dtg_GetListData(a5),a0
	jsr	(a0)
	move.l	a5,dtbase
	move.l	a0,FX_Data

	move.l	dtg_AudioAlloc(a5),a0
	jmp	(a0)
;=======================================================================
EndPlay
	clr.l	fx_data

	move.l	dtg_AudioFree(a5),a0
	jmp	(a0)
;=======================================================================
Getinfos:
	lea	FX_infobuffer(pc),a0

	move.l	FX_Data(pc),d0
	beq	.rts
	move.l	d0,a1		Zeiger auf SongDaten
	moveq	#0,d2
	move.b	$0432(a1),d2
	move.l	d2,20(a0)		Länge des Sounds

	lea	$0434(a1),a2

	subq.w	#$01,d2

	moveq	#$00,d1
	moveq	#$00,d0
.SongLenLoop
	move.b	(a2)+,d0		Patternnummer holen
	cmp.b	d0,d1			ist es die höchste ?
	bhi.s	.LenHigher		nein!
	move.b	d0,d1			ja
.LenHigher
	dbf	d2,.SongLenLoop
	move.l	d1,d0			Hoechste BlockNummer nach d0
	addq.w	#$01,d0			plus 1
	move.l	d0,28(a0)		Numpatts
	mulu	#$0400,d0		Laenge eines Block

	add.l	#$4b8,d0		Vorblock
	move.l	d0,36(a0)		Songlen
	move.l	d0,52(a0)		Calclen

	lea	$90+$16(a1),a1		1. Sample Länge
	moveq	#$1e,d0
	moveq	#0,d2
	moveq	#0,d3
.numsam
	moveq	#0,d1
	move.w	(a1),d1
	cmp.w	#2,d1
	blo.s	.wei
	addq.w	#1,d2
	add.l	d1,d1
	add.l	d1,d3
.wei	add.w	#30,a1
	dbf	d0,.numsam

	move.l	d3,44(a0)		;Samplelänge
	add.l	d3,52(a0)		;Gesamtlänge
	move.l	d2,4(a0)		;Anzahl
.rts	rts
;=======================================================================
InitSnd
	move.l	fx_data(pc),a0
	move.w	128(a0),dtg_Timer(a5)

****************************************************************************
*									   *
*									   *
*		  Sound Abspiel Routine zu Sound FX			   *
*									   *
*									   *
****************************************************************************

;--------------------------------------------------------------------

StartSound
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,SongPointer		;Zeiger auf SongDaten
	moveq	#$00,d0
	move.b	$0432(a0),d0
	move.w	d0,AnzPatt

	bsr	SongLen			;Länge der Songdaten berechnen
	add.l	d0,a0
	lea	$04B8(a0),a0

	move.l	SongPointer(pc),a2
	lea	Instruments(pc),a1	;Tabelle auf Samples
	moveq	#$1E,d7			;31 Instrumente
CalcIns
	move.l	a0,(a1)+		;Startadresse des Instr.
	add.l	(a2)+,a0		;berechnen un speichern
	dbra	d7,CalcIns
	bsr	PlayInit		;Loop Bereich setzen
	bsr	PlayEnable		;Player erlauben
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SongLen
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	SongPointer(pc),a0
	lea	$0434(a0),a0
	move.w	AnzPatt(pc),d2		;wieviel Positions
	subq.w	#$01,d2
	moveq	#$00,d1
	moveq	#$00,d0
SongLenLoop
	move.b	(a0)+,d0		;Patternnummer holen
	cmp.b	d0,d1			;ist es die höchste ?
	bhi.s	LenHigher		;nein!
	move.b	d0,d1			;ja
LenHigher
	dbra	d2,SongLenLoop
	move.l	d1,d0			;Hoechste BlockNummer nach d0
	addq.w	#$01,d0			;plus 1
	mulu	#$0400,d0		;Laenge eines Block
	movem.l	(sp)+,d1-d7/a0-a6
	rts

PlayInit
	move.l	d0,-(sp)
	lea	Instruments(pc),a0	;Zeiger auf instr.Tabelle
	moveq	#$1E,d7			;31 Instrumente
InitLoop
	move.l	(a0)+,a1		;Zeiger holen
	move.l	a1,d0
	beq.s	InitLoop2

	clr.l	(a1)			;erstes Longword löschen
InitLoop2
	dbra	d7,InitLoop
	move.l	(sp)+,d0
	rts

PlayEnable
	lea	$00DFF000,a0
	move.l	d0,-(sp)
	move.w	#$FFFF,PlayLock		;player zulassen
	moveq	#$00,d0
	move.w	d0,$00A8(a0)
	move.w	d0,$00B8(a0)
	move.w	d0,$00C8(a0)
	move.w	d0,$00D8(a0)
	clr.w	Timer			;zahler auf 0
	clr.l	TrackPos		;zeiger auf pos
	clr.l	PosCounter		;zeiger innehalb des pattern
	move.l	(sp)+,d0
	rts

;--------------------------------------------------------------------

PlayDisable
	lea	$00DFF000,a0
	clr.w	PlayLock		;player sperren
	move.l	d0,-(sp)
	moveq	#$00,d0
	move.w	d0,$00A8(a0)
	move.w	d0,$00B8(a0)
	move.w	d0,$00C8(a0)
	move.w	d0,$00D8(a0)
	move.w	#$000F,$0096(a0)
	move.l	(sp)+,d0
	rts

PlaySong				;HauptAbspielRoutine
	movem.l	d0-d7/a0-a6,-(sp)
	lea	FX_StructAdr(pc),a0
	move.w	#UPSB_Adr!UPSB_LEN!UPSB_Per!UPSB_Vol!UPSB_DMACON,UPS_Flags(a0)
	clr.w	UPS_Voice1per(a0)
	clr.w	UPS_Voice2per(a0)
	clr.w	UPS_Voice3per(a0)
	clr.w	UPS_Voice4per(a0)
	move.w	#1,UPS_Enabled(A0)

	addq.w	#$01,Timer		;zähler erhöhen
	cmp.w	#$0006,Timer		;schon 6?
	bne.s	CheckEffects		;wenn nicht -> effekte
	clr.w	Timer			;sonst zähler löschen
	bsr	PlaySound		;und sound spielen

	lea	FX_StructAdr(pc),a0
	clr.w	UPS_Enabled(A0)

	movem.l	(sp)+,d0-d7/a0-a6
	rts

CheckEffects
	moveq	#$03,d7			;4 kanäle
	lea	ChannelData0(pc),a6	;zeiger auf daten für 0
	lea	$00DFF0A0,a3
EffLoop
	bsr.s	MakeEffekts		;Effekt spielen
	add.w	#$0010,a3		;nächster Kanal
	add.w	#$0024,a6		;Nächste KanalDaten
	dbra	d7,EffLoop

	lea	FX_StructAdr(pc),a0
	clr.w	UPS_Enabled(A0)

	movem.l	(sp)+,d0-d7/a0-a6
	rts

MakeEffekts
	move.w	$0016(a6),d0
	beq.s	NoStep
	bmi.s	StepItUp
	add.w	d0,$0018(a6)
	move.w	$0018(a6),d0
	move.w	d0,$0010(a6)
	move.w	$001A(a6),d1
	cmp.w	d0,d1
	bhi.s	StepOk
	clr.w	$0016(a6)
	move.w	d1,d0
	move.w	d0,$0010(a6)
StepOk
	move.w	d0,$0006(a3)
	move.w	d0,$0018(a6)
	bsr	fx_getper
	rts

StepItUp
	add.w	d0,$0018(a6)
	move.w	$0018(a6),d0
	move.w	d0,$0010(a6)
	move.w	$001A(a6),d1
	cmp.w	d0,d1
	blt.s	StepOk2
	clr.w	$0016(a6)
	move.w	d1,d0
	move.w	d0,$0010(a6)
StepOk2
	move.w	d0,$0006(a3)
	move.w	d0,$0018(a6)
	bsr	fx_getper
	rts

NoStep
	move.b	$0002(a6),d0
	and.w	#$000F,d0
	tst.w	d0
	beq.s	NoEff
	subq.w	#$01,d0
	lsl.w	#$02,d0
	lea	EffTable(pc),a0
	move.l	$00(a0,d0.w),d0
	beq.s	NoEff
	move.l	d0,a0
	jsr	(a0)
NoEff
	rts

EffTable
	dc.l	appreggiato
	dc.l	pitchbend
	dc.l	LedOn
	dc.l	LedOff
	dc.l	0
	dc.l	0
	dc.l	SetStepUp
	dc.l	SetStepDown
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0

LedOn
LedOff
;	bset	#$01,$00BFE001
	rts

;LedOff
;	bclr	#$01,$00BFE001
;	rts

SetStepDown
	st	d4
	bra.s	StepFinder

SetStepUp
	moveq	#$00,d4
StepFinder
	clr.w	$0016(a6)
	move.w	$0010(a6),$0018(a6)
	move.b	$0003(a6),d2
	and.w	#$000F,d2
	tst.w	d4
	beq.s	NoNegIt
	neg.w	d2
NoNegIt
	move.w	d2,$0016(a6)
	moveq	#$00,d2
	move.b	$0003(a6),d2
	lsr.w	#$04,d2
	move.w	$0010(a6),d0
	lea	NoteTable(pc),a0
StepUpFindLoop
	move.w	(a0),d1
	cmp.w	#$FFFF,d1
	beq.s	EndStepUpFind
	cmp.w	d1,d0
	beq.s	StepUpFound
	addq.w	#$02,a0
	bra.s	StepUpFindLoop

StepUpFound
	add.w	d2,d2
	tst.w	d4
	bne.s	NoNegStep
	neg.w	d2
NoNegStep
	move.w	$00(a0,d2.w),d0
	move.w	d0,$001A(a6)
	rts

EndStepUpFind
	move.w	d0,$001A(a6)
	rts

appreggiato
	lea	ArpeTable(pc),a0
	moveq	#$00,d0
	move.w	Timer(pc),d0
	subq.w	#$01,d0
	lsl.w	#$02,d0
	move.l	$00(a0,d0.w),a0
	jmp	(a0)

ArpeTable
	dc.l	Arpe1
	dc.l	Arpe2
	dc.l	Arpe3
	dc.l	Arpe2
	dc.l	Arpe1

Arpe4
	add.w	d0,d0
	move.w	$0010(a6),d1
	lea	NoteTable(pc),a0
Arpe5
	move.w	$00(a0,d0.l),d2
	tst.w	(a0)
	bmi.s	Arpe7
	cmp.w	(a0),d1
	beq.s	Arpe6
	addq.w	#$02,a0
	bra.s	Arpe5

Arpe1
	moveq	#$00,d0
	move.b	$0003(a6),d0
	lsr.b	#$04,d0
	bra.s	Arpe4

Arpe2
	moveq	#$00,d0
	move.b	$0003(a6),d0
	and.b	#$0F,d0
	bra.s	Arpe4

Arpe3
	move.w	$0010(a6),d2
Arpe6
	move.w	d2,$0006(a3)
	bsr	getperd2
	rts

Arpe7
	move.w	#$00F0,$00DFF180
	rts

pitchbend
	moveq	#$00,d0
	move.b	$0003(a6),d0
	lsr.b	#$04,d0
	tst.b	d0
	beq.s	pitch2
	move.w	(a6),d1
	and.w	#$1000,d1
	and.w	#$EFFF,(a6)
	add.w	d0,(a6)
	move.w	(a6),d0
	move.w	d0,$0006(a3)
	or.w	d1,(a6)
	bsr	fx_getper
	rts

pitch2
	moveq	#$00,d0
	move.b	$0003(a6),d0
	and.b	#$0F,d0
	tst.b	d0
	beq.s	pitch3
	move.w	(a6),d1
	and.w	#$1000,d1
	and.w	#$EFFF,(a6)
	sub.w	d0,(a6)
	move.w	(a6),d0
	move.w	d0,$0006(a3)
	or.w	d1,(a6)
	bsr	fx_getper
pitch3
	rts

PlaySound
	move.l	SongPointer(pc),a0	;Zeiger auf SongFile
	lea	$0434(a0),a2		;Zeiger auf Patterntab.
	lea	$0090(a0),a3		;Zeiger auf Instr.Daten
	lea	$04B8(a0),a0		;Zeiger auf BlockDaten
	move.l	TrackPos(pc),d0		;Postionzeiger
	moveq	#$00,d1
	move.b	$00(a2,d0.l),d1
	moveq	#$0A,d7
	lsl.l	d7,d1			;*1024 / länge eines Pattern
	add.l	PosCounter(pc),d1	;Offset ins Pattern
	clr.w	DmaCon
	lea	$00DFF0A0,a4
	lea	ChannelData0(pc),a6	;Daten für Kanal0
	moveq	#$03,d7			;4 Kanäle
SoundHandleLoop
	bsr	PlayNote		;aktuelle Note spielen
	add.w	#$0010,a4		;nächster Kanal
	add.w	#$0024,a6		;nächste Daten
	dbra	d7,SoundHandleLoop
	move.w	DmaCon(pc),d0
	and.w	#$000F,d0
	or.w	#$8000,d0
	move.w	d0,$00DFF096
	bsr	Delay
	lea	ChannelData3(pc),a6
	lea	$00DFF0D0,a4
	moveq	#$03,d7
SetRegsLoop
	move.l	$000A(a6),(a4)		;Adresse
	move.w	$000E(a6),$0004(a4)	;Länge
	sub.w	#$0024,a6		;nächste Daten
	sub.w	#$0010,a4		;nächster Kanal
	dbra	d7,SetRegsLoop
	tst.w	PlayLock
	beq.s	NoEndPattern
	tst.w	Break
	beq.s	NoBreakPattern
	move.l	#$000003F0,PosCounter
	clr.w	Break
NoBreakPattern
	add.l	#$00000010,PosCounter	;PatternPos erhöhen
	cmp.l	#$00000400,PosCounter	;schon Ende ?
	blt.s	NoEndPattern
	clr.l	PosCounter		;PatternPos löschen
	tst.b	PlayLock
	beq.s	NoAddPos
	addq.l	#$01,TrackPos		;Position erhöhen
NoAddPos
	move.w	AnzPatt(pc),d0		;AnzahlPosition
	move.l	TrackPos(pc),d1		;Aktuelle Pos
	cmp.w	d0,d1			;Ende?
	bne.s	NoEndPattern		;nein!

	move.l	a2,-(sp)
	move.l	dtbase(Pc),a2
	move.l	DTG_Songend(a2),a2
	jsr	(A2)
	move.l	(sp)+,a2

	clr.l	TrackPos		;ja/ Sound von vorne
NoEndPattern
	rts

PlayNote
	tst.b	$0014(a6)
	bne.s	NoGetNote
	clr.l	(a6)
	tst.w	PlayLock
	beq.s	NoGetNote
	move.l	$00(a0,d1.l),(a6)
NoGetNote
	addq.w	#$04,d1
	moveq	#$00,d2
	cmp.w	#$FFFD,(a6)
	beq	NoInstr2
	move.b	$0002(a6),d2
	and.b	#$F0,d2
	lsr.b	#$04,d2
	btst	#$04,(a6)
	beq.s	PlayInstr
	add.b	#$10,d2
PlayInstr
	tst.b	d2
	beq	NoInstr2
	lea	Instruments(pc),a1
	subq.w	#$01,d2
	move.w	d2,d4
	lsl.w	#$02,d2
	mulu	#$001E,d4
	move.l	$00(a1,d2.w),$0004(a6)
	move.w	$16(a3,d4.l),$0008(a6)
	move.w	$18(a3,d4.l),$0012(a6)
	moveq	#$00,d3
	move.w	$1A(a3,d4.l),d3
	tst.w	d3
	beq.s	NoRepeat
	move.l	$0004(a6),d2
	add.l	d3,d2
	move.l	d2,$000A(a6)
	move.w	$1C(a3,d4.w),$000E(a6)
	move.w	$0012(a6),d3
	bra.s	NoInstr
NoRepeat
	move.l	$0004(a6),d2
	add.l	d3,d2
	move.l	d2,$000A(a6)
	move.w	$1C(a3,d4.l),$000E(a6)
	move.w	$0012(a6),d3
NoInstr
	move.b	$0002(a6),d2
	and.w	#$000F,d2
	cmp.b	#$05,d2
	beq.s	ChangeUpVolume
	cmp.b	#$06,d2
	bne.s	SetVolume2
	moveq	#$00,d2
	move.b	$0003(a6),d2
	sub.w	d2,d3
	tst.w	d3
	bpl.s	SetVolume2
	clr.w	d3
	bra.s	SetVolume2

ChangeUpVolume
	moveq	#$00,d2
	move.b	$0003(a6),d2
	add.w	d2,d3
	tst.w	d3
	cmp.w	#$0040,d3
	ble.s	SetVolume2
	moveq	#$40,d3
SetVolume2
	bsr	fx_setvoices
;	move.w	d3,$0008(a4)
NoInstr2
	cmp.w	#$FFFD,(a6)
	bne.s	NoPic
	clr.w	$0002(a6)
	bra.s	NoNote

NoPic
	tst.w	(a6)
	beq.s	NoNote
	clr.w	$0016(a6)
	move.w	(a6),d0
	and.w	#$EFFF,d0
	move.w	d0,$0010(a6)
	move.w	$0014(a6),d0
	ext.w	d0
	move.w	d0,$00DFF096
	bsr	Delay
	cmp.w	#$FFFE,(a6)
	bne.s	NoStop
	move.w	#$0000,$0008(a4)
	bra.s	Super

NoStop
	cmp.w	#$FFFC,(a6)
	bne.s	NoBreak
	st	Break
	and.w	#$EFFF,(a6)
	bra	EndNote

NoPic2
	and.w	#$EFFF,(a6)
	bra.s	NoNote
NoBreak
	cmp.w	#$FFFB,(a6)
	beq.s	NoPic2

	move.l	$0004(a6),(a4)
	move.w	$0008(a6),$0004(a4)
	bsr	getvoice

	move.w	(a6),d0
	and.w	#$EFFF,d0
	move.w	d0,$0006(a4)
Super
	move.w	$0014(a6),d0
	ext.w	d0
	or.w	d0,DmaCon
NoNote
	clr.b	$0014(a6)
EndNote
	rts

Delay
	movem.l	d0-d1,-(sp)
	moveq	#7,d0
.wait1
	move.b	$dff006,d1
.wait2
	cmp.b	$dff006,d1
	beq.s	.wait2

	dbf	d0,.wait1

	movem.l	(sp)+,d0-d1
	rts

;--------------------------------------------------------------------

ChannelData0	dcb.b	$14,0			;Daten für Note
		dc.w	$0001
		dcb.b	$0E,0

ChannelData1	dcb.b	$14,0			;u.s.w
		dc.w	$0002
		dcb.b	$0E,0

ChannelData2	dcb.b	$14,0			;etc.
		dc.w	$0004
		dcb.b	$0E,0

ChannelData3	dcb.b	$14,0			;a.s.o
		dc.w	$0008
		dcb.b	$0E,0

Instruments	dcb.l 31,0			;Zeiger auf die 31 Instrumente

PosCounter	dc.l 0				;Offset ins Pattern

TrackPos	dc.l 0				;Position Counter

Break		dc.w 0				;Flag fuer 'Pattern abbrechen'

Timer		dc.w 0				;Zähler 0-5

DmaCon		dc.w 0				;Zwischenspeicher für DmaCon

AnzPatt		dc.w 0				;Anzahl Positions

PlayLock	dc.w 0				;Flag fuer 'Sound erlaubt'

SongPointer	dc.l 0

	dc.w	$0434,$0434,$0434,$0434,$0434,$0434,$0434,$0434,$0434,$0434
	dc.w	$0434,$0434,$0434,$0434,$0434,$0434,$0434,$0434,$0434,$0434
NoteTable
	dc.w	$0434,$03F8,$03C0,$038A,$0358,$0328,$02FA,$02D0,$02A6,$0280
	dc.w	$025C,$023A,$021A,$01FC,$01E0,$01C5,$01AC,$0194,$017D,$0168
	dc.w	$0153,$0140,$012E,$011D,$010D,$00FE,$00F0,$00E2,$00D6,$00CA
	dc.w	$00BE,$00B4,$00AA,$00A0,$0097,$008F,$0087,$007F,$0078,$0071
	dc.w	$0071,$0071,$0071,$0071,$0071,$0071,$0071,$0071,$0071,$0071
	dc.w	$0071,$0071,$0071,$0071,$0071,$0071,$0071,$0071,$0071,$0071
	dc.w	$0071,$0071,$0071,$0071,$0071,$0071,$FFFF

	ifne	test
mod
	incdir	vr0:
	incbin	SFX20.Coloris
	endc

	end

