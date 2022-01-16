//;defined symbols used as labels
 .var inpflg=		$11
 .var tansgn=       $12
 .var resho=        $26
 .var resmoh=       $27
 .var resmo=        $28
 .var opmask=       $4d
 .var grbpnt=       $4e
 .var four6=        $53
 .var size=         $55
 .var oldov=        $56
 .var expsgn=       $60
 .var facho=        $62
 .var facmoh=       $63
 .var facsgn=       $66
 .var status=       $90
 .var svxt=         $92
 .var prty=         $9b
 .var cntdn=        $a5
 .var bufpt=        $a6
 .var inbit=        $a7
 .var bitci=        $a8
 .var rinone=       $a9
 .var ridata=       $aa
 .var riprty=       $ab
 .var sal=          $ac
 .var sah=          $ad
 .var eal=          $ae
 .var eah=          $af
 .var cmp0=         $b0
 .var temp=         $b1
 .var bitts=        $b4
 .var nxtbit=       $b5
 .var fa=           $ba
 .var ndx=          $c6
 .var lstp=         $ca
 .var blnsw=        $cc
 .var m51ctr=     $0293
 .var lstnsa=     $ff93
 .var iecout=     $ffa8
 .var unlstn=     $ffae
 .var listen=     $ffb1
 .var chrout=     $ffd2
 .var stop=       $ffe1
 .var getin=      $ffe4
 .var plot=       $fff0
 

          * = $0801
          .pc = $801
:BasicUpstart(2061)

l080d:	  jsr l192c		// points to jsr $19e5
          jsr l1aa3		// flip out BASIC and kernal. Return here with I flag still set
          
          lda #$fb
          sta $0318
          lda #$19
          sta $0319 		//NMI vector to $19fb
          
          jsr l1f2d		//copy $1fb6-$25E6 to $D000-$D600 and fill $DE00-$DEFF and $DD00-$DDFF
          
l0820:    jmp l08b3
		 //.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80,$00,$00,$00,$00,$00
l0823:    brk
l0824:    brk		// $02 if C pressed
l0825:    brk		// $50 if C pressed but if half tracks enabled = $51
l0826:    brk		// 
l0827:    brk		// $02 if C pressed but if half tracks enabled = $01
l0828:    brk		
l0829:    brk
l082a:    brk		// this holds one byte read from user port after sending A, X and Y at $1f0b

l082b:    brk		// synchronised tracks Y/N $80/$00
l082c:    brk		// half tracks Y/N $80/$00 
l082d:    brk		// track shortening Y/N $80/$00
l082e:    .byte $80	// verify Y/N $80/$00
l082f:    brk		// transitions Y/N $80/$00

l0830:    brk
l0831:    brk
l0832:    brk
l0833:    brk
          
l0834:     ldy #$00
l0836:    lda $dd0d		// CIA2 ICR - wait for an interrupt
          beq l0836
          
          lda $dd01		// CIA2 PB - this register holds the CONTENTS of i/p and o/p lines on Port B
          sta (eal),y		// read 1 byte from from user port and store it at (eal) +Y
          beq l0860		// if we read a zero then rts
          iny
l0843:    lda $dd0d		// CIA2 ICR - wait for an interrupt
          beq l0843
          
          lda $dd01		// read 1 byte from from user port and store it at (eal) +Y
          sta (eal),y
          beq l0860		// if we read a zero then rts
          iny
          bne l0836		// go back to start if Y <= $ff
          
          inc eah			// as Y has counted past $ff we increase the hi byte at eah
          bne l0836		// and if hi byte <= $ff then go back to start 
          
l0856:    lda $dd0d		// CIA2 ICR - wait for an interrupt
          beq l0856
          
          lda $dd01		// read 1 byte from from user port
          bne l0856		// branch if we didn't read a zero
l0860:     rts

l0861:    ldy #$00
          sty $b0
l0865:	 ldx #$20		// we're going to read $20 pages
l0867:	 lda $dd0d		// CIA2 ICR - wait for an interrupt
          beq l0867
          
          lda $dd01		// CIA2 PB - this register holds the CONTENTS of i/p and o/p lines on Port B
          sta (eal),y		// read 1 byte from from user port and store it at (eal) +Y
          iny
          bne l0867		// go back to start if Y <= $ff
          inc eah
          dex
          bne l0867		// read 20 pages from PB
          
l0879:	 lda $dd0d		// CIA2 ICR - wait for an interrupt
          beq l0879
          
l087e:	 ldx #$00
          ldy $dd01
l0883:	 lda $dd0d
          bne l087e		// if there is an interrupt then go back again
          dex
          bne l0883
          rts
          
l088c:	 ldx #$ff		// set CIA2 PB to output
          stx $dd03		// CIA2 DDRB
          stx $dd01		// send X to user port
          inx
          ldy eal			// replace eal with X and use what WAS in eal as Y index. Continue where we left off??
          stx eal
          
l0899:     lda (eal),y	// load A with (eal) +eal previous value
l089b:     ldx $dd0d		// CIA2 ICR - wait for an interrupt
          beq l089b
          sta $dd01		// send A to user port
          iny
          bne l0899		// get next byte from memory and send to user port
          inc eah			// if we've counted past $FF then inc hi byte
          bne l0899		// and jump back up										how do we get out of this loop ??
l08aa:     ldx $dd0d
          beq l08aa
          sty $dd03		// CIA2 DDRB
          rts
          
          
l08b3:     				// arrive here after filling I/O space
			ldx #$e0
          txs
          jsr l1aac		// switch BASIC out and kernal in
          lda #$00
          sta $d015		// disable sprites. Timing issues?
          sta status
          tay
l08c1:     iny
          sta $0823,y		// put zero into $0824 to $0833
          cpy #$10
          bne l08c1
          
          lda #$80		// 
          sta $082e		// enable "V"erify by default
          
          lda #$01
          sta $07
          
          lda #$0b
          sta $d021		// change screen colours
          lda #$0b
          sta $d020
          
          lda #$13		// cursor HOME
          jsr chrout
          jsr l156f		// Print Doppelganger.....
          jsr l15b8		// print SYNC... Y/N
          				//		HALF
			        		//		TRACK
				    		//		VERIFY					
          jsr l1678		// print LHS of screen TRACK READ WRITE
          jsr l1729		// print RHS and 01 02 03 04..... 40 and densities 3,2,1,0
l08ed:     
		 jsr l15b8		// print SYNC... Y/N   Why a second JSR to here ??
          jsr choose_option // $1818		// print Please choose option
          jsr options  // $17be		// print OPTIONS
          jsr l18aa		// print the following
          
l08f9:     //.byte $43,$2f,$53,$2f,$48,$2f,$54,$2f,$56,$00	// "c/s/h/t/v" 01000011 01010011 01001000 10011000 10001100
           .text "C/S/H/T/V"
           .byte $00
l0903:     
			jsr l1a31		// get a key input
          ldx #$04
l0908:     
			cmp $0924,x		// is A= "cvths"
          beq l0912			// X=4 branch as "c" pressed, X=3 "v", X=2 "t", X=1 "h", X=0 "s"
          dex				// X counts down from 4 to 1 
          bpl l0908			// try next letter from the 5 options
          bmi l0903			// none of the 5 were pressed, go back up
          
l0912:     txa
          asl 				// multiply X by 2
          tax
          lda $0929,x			//get low byte for JMP 
          sta $0922
          lda $092a,x			//get high byte for JMP
          sta $0923
l0921:     
			jmp l0921				// this jump address is changed by above instructions c=$0966
			
l0924:    .byte $53,$48,$54,$56,$43 	// shtvc
          
l0929:    .byte $33,$09,$36,$09,$39,$09,$41,$09,$66,$09	//"c"=$0966, "v"=$0941, "t"=$0939, "h"=$0936, "s"=$0933

          
l0933:    // S pressed 
			ldy #$00
			// skip next 2 LDY instructions due to BIT masking           
l0935:      	.byte $2c		// BIT instruction so the following looks like BIT $01a0
	         
		    // H pressed
l0936:		ldy #$01
			// skip next LDY instruction due to BIT masking
l0938:		.byte $2c		// BIT instruction so the following looks like BIT $02a0
                    
   			// T pressed			
l0939:		ldy #$02      
 
   			// only follow these if S, H or T were pressed
          jsr l095d			// flip the hi bit of $082b +Y // synchronised tracks Y/N $80/$00
          jmp l08ed			// print OPTIONS: c/s/h/t/v
          
l0941:    // V pressed
			ldy #$03
          lda $082e			// Verify Y = $80 or N = $00
          bmi l094e			// branch if hi bit set "Y"
          jsr l095d			// flip the hi bit of $082b +Y // synchronised tracks Y/N $80/$00
          jmp l08ed			// print OPTIONS: c/s/h/t/v
          
l094e:     
		 lda $082f
          bpl l0956			// branch if hi bit NOT set - $7f or less
          jsr l095d			// flip the hi bit of $082b +Y // synchronised tracks Y/N $80/$00
          
l0956:     iny
          jsr l095d			// flip the hi bit of $082b +Y // synchronised tracks Y/N $80/$00
          jmp l08ed			// print OPTIONS: c/s/h/t/v
          
l095d:    lda $082b,y			// $082b Y=0 synchronised tracks, Y=1 half tracks, Y=2 track shortening, Y=3 verify, Y=4 transitions
          eor #$80			// 1000 0000 flip the hi bit of $082b +Y
          sta $082b,y
          rts
          
l0966:    // C pressed
			lda #$02			
          sta $0824			// $02 = "C"opy selected
          lda $082c			// check if half tracks selected $80/$00 "Y"/"N"
          bmi l0976			// branch if hi bit set "Y" selected
          
          lda #$50
          ldy #$02
          bne l097a			// this will never = zero so branch will always be taken. Skips next 2 instructions
l0976:     
		// Half tracks selected
			lda #$51
          ldy #$01
l097a:	  sta $0825		// $50 = half tracks disabled $51 = half tracks enabled
          sty $0827		// $02 = half tracks disabled $01 = half tracks enabled
          
          // blank $c000 to $c600
          ldy #$c0						// start filling at $c000
          ldx #$c6						// end filling at $c600
          lda #$00						// fill with zero
          jsr fill_memory_area			// $155d using above parameters, fill $c000 - $c600 with zero
          jsr blank_actions_area_of_screen // $1880		// print $14 spaces 7 time
          jsr source_disk //$17d2			// print "source disk"
          lda $0823
          beq l09cd
l0994:     
			jsr options  // $17be
          jsr l18aa
          .byte $59,$2f,$4e,$00		// "Y/N"
          jsr l1a2d		// cli, set $0823 to zero, send $04 on user port
          cmp #$4e		//"N"
          bne l09b6
          jsr l18aa
          .byte $20,$01,$02,$9d,$12,$4e,$92,$00	//space, marker, 2x crsr left, RVS on, "N" RVS off
          jsr l1838		// flash "press  <space>"
          jmp l09db
l09b6:     
		  cmp #$59		// "Y"
          bne l0994
          jsr l18aa		// print text below
          .byte $20,$01,$04,$9d,$12,$59,$92,$00	//space, marker, 4x crsr left, RVS on, "Y" RVS off
          lda #$04
          jsr l1ecb    	// switch user port to output, send contents of A then switch to input 
          jsr l189f		// delay - countdown from $c000 to zero
l09cd:     
		  jsr l1838		// flash "press  <space>"
          jsr l1910		// send M-W $006A,$01,$05 then unlisten then I
          lda #$80
          sta $0823
          jsr l1937
l09db:     
			jsr l1ab2	// blank the screen
          jsr l1eea		// send 2, 4 FF then 18
          jsr l1aa6		// BASIC and kernal out
          lda $0824
          bne l09f0
l09e9:     clc
          lda $0826
          adc $0827
l09f0:     
			sta $0826
          jsr l18e3
          lda #$00
          jsr l1ecb		//switch user port to output, send contents of A then switch to input 
          lda $0826
          jsr l1ecb		//switch user port to output, send contents of A then switch to input 
          jsr l1efd		//send $02, $08 and $ff on user port then read a byte and store in $082A
          jsr l1ad4		// ($eal) = $E000
          lda #$0a
          jsr l1ecb		//switch user port to output, send contents of A then switch to input 
          jsr l0834
          jsr l1f04
          jsr l1e19
          txa
          ldy #$01
          sta ($fe),y
          jsr l1f1f
          lda #$00
          sta eal
          lda #$60
          sta eah
          jsr l1efd
          lda #$06
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          jsr l0861
          tya
          pha
          jsr l1f04
          pla
          bne l0a3d
          jsr l1add
          lda cntdn
l0a3d:     					
			ldy #$00
          sta ($fe),y
          tay
          bne l0a4f
l0a44:     lda (sal),y
          beq l0a4f
          sta ($fc),y
          iny
          cpy #$08
          bne l0a44
l0a4f:     
			lda $0826
          cmp $0825
          bne l09e9
          jsr l1aac    //switch BASIC out and kernal in
          lda $082c		// half tracks Y/N $80/$00
          bpl l0a62
          jsr l1ce9
l0a62:     
			lda $0824
          bne l0a6e
l0a67:     clc
          lda $0826
          adc $0827
l0a6e:     
			sta $0826
          jsr l18e3
          ldy #$00
          lda ($fe),y
          cmp #$88			// "f7"
          beq l0aa9
          jsr l1eda			// compare contents of $0826 to $52,$3E,$32,$24 in reverse order
          txa
          ldy #$01
          cmp ($fe),y
          beq l0a92
          lda $0826
          cmp #$48			// "H"
          bcs l0a92
          lda #$12			// RVS on
          jsr chrout
l0a92:     
			lda ($fe),y
          pha
          ldy rinone
          ldx #$17
          clc
          jsr plot
          pla
          clc
          adc #$30
          jsr chrout
          lda #$92
          jsr chrout
l0aa9:     
			ldx #$14
          lda $0826
          lsr 
          bcc l0ab2
          inx
l0ab2:     
			ldy rinone
          clc
          jsr plot
          ldy #$00
          lda ($fe),y
          beq l0ad6
          cmp #$88
          beq l0ad3
          cmp #$44
          beq l0acd
          cmp #$82
          beq l0ad0
          lda #$42
          .byte $2c
l0acd:    lda #$3f
          .byte $2c
l0ad0:     lda #$4b
          .byte $2c
l0ad3:    lda #$2e
          .byte $2c
l0ad6:    lda #$2b
          jsr chrout
          lda $0826
          cmp $0825
          bne l0a67
          jsr l1ef6
          jsr l1abe
          lda #$00
          sta $0831
          lda #$88
          sta $0829
          lda $0824
          sta $0826
          sta $0828
          jmp l0c00
l0aff:     
			lda $0831
          bne l0b24
          lda $0833
          beq l0b12
          jsr blank_actions_area_of_screen // $1880		// print $14 spaces 7 times
          jsr source_disk					//$17d2
          jsr l1838
l0b12:     
			jsr l1ab2
          jsr l1eea
          jsr l1678
          ldy #$c5
          ldx #$d0
          lda #$00
          jsr fill_memory_area		// $155d fill $c500 to $d000 with $00
l0b24:     
			ldy #$00
          lda ($fe),y
          bne l0b5d
          lda $082b		// synchronised tracks Y/N $80/$00
          bpl l0b5d
          lda $0829
          bne l0b5d
          jsr l0c6f
          jsr l1ad4
          jsr l1efd
          lda #$12
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          sei
          jsr l0861
          cli
          jsr l1f04
          jsr l1ad4
          ldx #$00
          jsr l0caf
          ldy #$06
          lda eal
          sta ($fe),y
          iny
          lda eah
          sta ($fe),y
l0b5d:     
			lda #$00
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          lda $0826
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          ldy #$01
          lda ($fe),y
          jsr l1f1f
          ldx $0831
          lda $0e26,x
          sta eah
          lda #$00
          sta eal
          jsr l1efd
          ldy #$00
          lda ($fe),y
          sta $0829
          bne l0ba9
          jsr l0c4f
          ldy #$00
l0b8c:
			lda ($fc),y
          beq l0b97
          sta (eal),y
          iny
          cpy #$08
          bne l0b8c
l0b97:     
			sty $b0
          lda #$10
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          sei
          jsr l0865
          cli
          jsr l1f04
          jmp l0bd2
l0ba9:     
			cmp #$41		//"A"
          php
          beq l0bb1
          lda #$06
          .byte $2c
l0bb1:	 lda #$08
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          sei
          jsr l0861
          cli
          jsr l1f04
          plp
          bne l0bd2
          ldy #$02
          lda #$ff
          sta ($fe),y
          iny
          lda #$1f
          sta ($fe),y
          jsr l12e6
          jmp l0bee
l0bd2:     
			jsr l0cf3
          ldy #$02
          lda ridata
          sta ($fe),y
          iny
          lda riprty
          sta ($fe),y
          ldy #$04
          lda sal
          sta ($fe),y
          iny
          lda sah
          sta ($fe),y
          jsr l12ce
l0bee:     
			inc $0831
l0bf1:     
			lda $0826
          cmp $0825
          beq l0c13
          clc
          adc $0827
          sta $0826
l0c00:     
			jsr l18e3
          ldy #$00
          lda ($fe),y
          bmi l0bf1
          lda $0831
          cmp #$05			// white
          beq l0c16
          jmp l0aff
l0c13:     
			lda #$ff
          .byte $2c
l0c16:	 lda #$00
          pha
          jsr l1f04
          jsr l0e35
          pla
          bmi l0c30
          sta $0831
          jsr l1ef6
          jsr l1abe
          inc $0833
          bne l0c00
l0c30:     
			jsr l1eea
          lda #$00
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          lda #$24
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          jsr l1ef6
          jsr l1f04
          jsr blank_actions_area_of_screen // $1880		// print $14 spaces 7 times
          jsr l1abe
          jsr l1838
          jmp l08b3
l0c4f:     
			lda #$0c
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          ldy #$07
l0c56:     
			lda ($fc),y
          beq l0c5d
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
l0c5d:     
			dey
          bpl l0c56
          lda #$00
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          ldy #$01
          lda ($fe),y
          jmp l1f1f
l0c6c:
			lda #$80
			.byte $2c
l0c6f:	lda #$00
          sta bitci
          lda #$0e
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          lda $0826
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          ldy #$01
          lda ($fe),y
          tax
          lda $1f29,x
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          lda bitci
          beq l0cac
          lda $07
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          ldy #$02
          lda ($fe),y
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          iny
          lda ($fe),y
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          lda ridata
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          lda riprty
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          lda $082e
l0cac:    jmp l1ecb    //switch user port to output, send contents of A then switch to input 
l0caf:     
			jsr l1aa6	// BASIC and kernal out
l0cb2:     
			ldy #$00
          beq l0cc0
l0cb6:     
			inc eal
          bne l0cc0
          inc eah
          cpx eah
          beq l0ce0
l0cc0:     
			lda (eal),y
          cmp #$ff
          bne l0cb6
          inc eal
          bne l0cd0
          inc eah
          cpx eah
          beq l0ce0
l0cd0:     
			lda ($fc),y
          beq l0cdd
          cmp (eal),y
          bne l0cb2
          iny
          cpy #$08
          bne l0cd0
l0cdd:     
			jsr l0cea
l0ce0:     sec
          lda eah
          sbc #$e0
          sta eah
          jmp l1aac    //switch BASIC out and kernal in
l0cea:     
			lda eal
          bne l0cf0
          dec eah
l0cf0:     
			dec eal
          rts
l0cf3: 
			jsr l1aa3
          ldx $0831
          lda $0e26,x
          sta sah
          sta riprty
          sta nxtbit
          lda $0e2b,x
          sta eah
          lda $0e30,x
          sta temp
          clc
          lda #$16
          adc sah
          sta bufpt
          clc
          lda #$20
          adc sah
          sta inbit
          sta rinone
          sta $b3
          ldy #$00
          sty sal
          sty ridata
          sty eal
          sty $b0
          sty bitts
          sty cntdn
          sty bitci
          sty $b2
          lda ($fe),y
          beq l0d52
          lda bufpt
          sta sah
          bne l0d52
l0d3a:     
			inc sal
          bne l0d52
          inc sah
          lda sah
          cmp inbit
          bne l0d52
          beq l0d76
l0d48:    lda sal
          sta ridata
          lda sah
          sta riprty
          ldy #$00
l0d52:     lda (sal),y
l0d54:     and #$0f
          cmp #$0f
          bne l0d3a
          inc sal
          bne l0d66
          inc sah
          lda sah
          cmp inbit
          beq l0d76
l0d66:     lda (sal),y
          cmp #$ff
          bne l0d54
          inc sal
          bne l0d78
          inc sah
          lda sah
          cmp inbit
l0d76:     beq l0d9f
l0d78:     sec
          lda sal
          sbc ridata
          sta (eal),y
          lda sal
          sta ridata
          inc eal
          lda sah
          sbc riprty
          sta (eal),y
          lda sah
          sta riprty
          inc eal
          bne l0da1
          beq l0dfa
l0d95:     inc sal
          bne l0da1
          inc sah
          lda sah
          cmp inbit
l0d9f:     beq l0dfa
l0da1:     lda (sal),y
          cmp #$ff
          beq l0d95
          cmp #$7f
          bne l0db1
          lda #$ff
          sta (sal),y
          bne l0d95
l0db1:     sec
          lda sal
          sbc ridata
          sta ($b0),y
          inc $b0
          lda sah
          sbc riprty
          sta ($b0),y
          inc $b0
          lda sah
          cmp bufpt
          bcc $0d48
l0dc8:     lda (sal),y
          cmp (bitts),y
          beq l0ddf
          tax
          lda $dd00,x
          bmi l0ddf
          lda (bitts),y
          tax
          lda $dd00,x
          bmi l0ddf
          jmp l0d48
l0ddf:     iny
          bmi l0e0a
          cpy cntdn
          bcc l0dc8
          sty cntdn
          lda ridata
          sta $b2
          lda sal
          sta bitci
          lda riprty
          sta $b3
          lda sah
          sta rinone
          bne l0dc8
l0dfa:     lda bitci
          sta sal
          lda rinone
          sta sah
          lda $b2
          sta ridata
          lda $b3
          sta riprty
l0e0a:     sec
          ldx $0831
          lda sah
          sbc $0e26,x
          sta sah
          sec
          lda ridata
          sbc #$01
          sta ridata
          lda riprty
          sbc $0e26,x
          sta riprty
          jmp l1aac    //switch BASIC out and kernal in
          
l0e26:    .byte $20,$40,$60,$80,$a0
          .byte $c6,$c7,$c8,$c9,$ca,$cb,$cc,$cd,$ce,$cf
          
l0e35:     lda #$00

          sta $0832
          sta $f8
          lda $0828
          sta $0826
          jsr l18e3
          lda #$00
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          lda $0826
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          ldy #$00
          lda ($fe),y
          sta $0829
          bne l0e5c
          jsr l0c4f
l0e5c:     jsr l1ef6
          jsr l1abe
          lda $0833
          beq l0e98
          bne l0e8e
l0e69:     jsr l1aac    //switch BASIC out and kernal in
          inc $0832
          ldy #$00
          lda ($fe),y
          sta $0829
          bne l0e80
          lda $082b		// synchronised tracks Y/N $80/$00
          bpl l0e80
          jsr l0c4f
l0e80:     jsr l1f04
          lda $0826
          sta $0828
          cmp $0825
          beq l0eaa
l0e8e:     lda $0826
          clc
          adc $0827
          sta $0826
l0e98:     jsr l18e3
          ldy #$00
          lda ($fe),y
          cmp #$88
          beq l0e80
          lda $0832
          cmp #$05
          bne l0eb0
l0eaa:     jsr l1ef6
          jmp l1abe
l0eb0:     lda $0832
          bne l0ec8
          lda $f8
          bne l0ec8
          jsr l1f04
          jsr blank_actions_area_of_screen // $1880		// print $14 spaces 7 times
          jsr destination_disk:   // $17f5 
          jsr l1838
          jsr l1eea
l0ec8:     jsr l1ab2
          lda $0833
          ora $0832
          beq l0f42
          ldy #$00
          lda ($fe),y
          bne l0f42
          lda $082b		// synchronised tracks Y/N $80/$00
          bpl l0f42
          lda $0829
          bne l0f42
          jsr l134c
l0ee6:     ldy #$06
          lda ($fe),y
          sta ridata
          iny
          lda ($fe),y
          sta riprty
          ldy #$01
          lda ($fe),y
          asl 
          tax
          ldy #$02
          sec
          lda $11ff,x
          sbc ($fe),y
          sta eal
          iny
          lda $1200,x
          sbc ($fe),y
          sta eah
          bcc l0f2b
          lda riprty
          cmp eah
          bcc l0f19
          bne l0f2b
          lda ridata
          cmp eal
          bcs l0f2b
l0f19:     ldy #$06
          clc
          lda ridata
          adc $11ff,x
          sta ridata
          iny
          lda riprty
          adc $1200,x
          sta riprty
l0f2b:     jsr l1529
          jsr l0c6c
          jsr l1aa6		// BASIC and kernal out
          jsr l1efd
          lda #$14
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          jsr l088c
          jmp l1027
l0f42:     lda #$00
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          lda $0826
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          lda $0832
          ora $0833
          bne l0f9f
          lda $f8
          bne l0f9f
          jsr l1207
          lda $0826
          pha
          ldy #$01
          sty $0826
l0f65:     lda #$00
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          tya
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          lda #$03
          jsr l1f1f
          jsr l1efd
          lda #$1a
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          lda #$00
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          jsr l1f04
          inc $0826
          ldy $0826
          cpy #$52
          bne l0f65
          pla
          sta $0826
          jsr l18e3
          lda #$00
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          lda $0826
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
l0f9f:     ldy #$01
          lda ($fe),y
          jsr l1f1f
          ldy #$00
          lda ($fe),y
          beq l1000
          sta $0829
          bpl l0fca
          ldy #$02
          lda #$ff
          sta ($fe),y
          iny
          lda #$1f
          sta ($fe),y
          ldy #$e0
          ldx #$00
          lda #$ff
          jsr fill_memory_area		// $155d fill $e000 to $0000 ($ffff) with $ff
          jsr l1ad4
          beq l0fcd
l0fca:     jsr l1529
l0fcd:     lda $082e
          pha
          lda #$00
          sta $082e
          jsr l1aa6		// BASIC and kernal out
          ldy #$01
          sty ridata
          sty riprty
          sty $07
          jsr l0c6c
          lda #$16
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          jsr l088c
          jsr l1309
          inc $f8
          lda $0829
          bmi l0ff9
          inc $0832
l0ff9:     pla
          sta $082e
          jmp l0e80
l1000:     jsr l134c
l1003:     ldy #$02
          sec
          lda #$00
          sbc ($fe),y
          sta ridata
          iny
          lda #$20
          sbc ($fe),y
          sta riprty
          jsr l1529
          jsr l1aa6		// BASIC and kernal out
          jsr l0c6c
          jsr l1efd
          lda #$16
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          jsr l088c
l1027:     lda $082e
          bpl l1060
          lda #$e0
          sta eah
          ldy #$00
          sty eal
          jsr l0861
          tya
          pha
          jsr l1f04
          pla
          beq l1066
          jsr l1aac    //switch BASIC out and kernal in
          jsr blank_actions_area_of_screen // $1880		// print $14 spaces 7 times
          jsr l1abe
          lda #$00
          jsr l1794
          lda $082a
          and #$10
          beq l1066
          jsr destination_disk:   // $17f5 
          jsr l1838
          jsr l1ab2
          jmp l1003
l1060:     jsr l1309
          jmp l11f9
l1066:     jsr l1aa3
          ldy #$02
          lda ($fe),y
          sta bufpt
          iny
          lda ($fe),y
          sta inbit
          jsr l1ad4
          ldy $0832
          lda $0e26,y
          sta sah
          ldy #$00
          sty sal
          ldx #$00
          stx cntdn
l1087:     lda (sal),y
          cmp (eal),y
          beq l10a3
          stx bitci
          tax
          lda $dd00,x
          bmi l109d
          lda (eal),y
          tax
          lda $dd00,x
          bpl l10b5
l109d:     lda #$80
          sta cntdn
          ldx bitci
l10a3:     cpy bufpt
          bne l10ab
          cpx inbit
          beq l10ce
l10ab:     iny
          bne l1087
          inc sah
          inc eah
          inx
          bne l1087
l10b5:     lda eah
          cmp #$e0
          bne l10c6
          cpy #$08
          bcs l10c6
          iny
          lda cntdn
          ora #$01
          bne l10cc
l10c6:     lda cntdn
          bmi l10cc
          ora #$02
l10cc:     sta cntdn
l10ce:     sty eal
          lda #$e0
          sta sah
          ldy #$00
          sty sal
          beq l10ec
l10da:     ldy #$00
          inc eal
          bne l10f1
          inc eah
          bne l10f1
          lda cntdn
          ora #$04
          sta cntdn
          bne l1135
l10ec:     ldx $082f
          bpl l1101
l10f1:     lda (eal),y
          cmp #$ff
          beq l10da
          cmp (sal),y
          beq l111b
          lda cntdn
          ora #$08
          sta cntdn
l1101:     ldy #$00
          inc eal
          bne l1115
          inc eah
          bne l1115
          lda cntdn
          and #$7f
          ora #$04
          sta cntdn
          bne l1135
l1115:     lda (eal),y
          cmp (sal),y
          bne l1101
l111b:     iny
          cpy #$08
          bne l1115
          sec
          lda eah
          sbc #$e0
          sta eah
          jsr l131d
          lda cntdn
          and #$7f
          sta cntdn
          bne l1135
          jmp l11f9
l1135:     dec $0830
          beq l1169
l113a:     lda $0829
          bne l1166
          lda $082b		// synchronised tracks Y/N $80/$00
          bpl l1166
          lda $0826
          pha
          lda #$00
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          lda $0828
          sta $0826
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          jsr l18e3
          jsr l0c4f
          pla
          sta $0826
          jsr l18e3
          jmp l0ee6
l1166:     jmp l1003
l1169:     jsr l1aac    //switch BASIC out and kernal in
          jsr blank_actions_area_of_screen // $1880		// print $14 spaces 7 times
          jsr l1abe
          lda #$00
          jsr l1794
          lda cntdn
          and #$08
          bne l119b
          lda cntdn
          cmp #$01
          beq l11b5
          jsr l18aa
          .byte $20,$20,$20,$20,$12
          .text "VERIFY ERROR"
          brk
          jmp l11cc
          
l119b:     jsr l18aa
          .byte $20,$20,$12
          .text "TRANSITION ERROR"
          brk
          jmp l11cc
          
l11b5:     jsr l18aa
          jsr l1220
          .text "OVER-WRITE ERROR"
          brk
          
l11cc:     lda #$92		// RVS off
          jsr chrout
          jsr options  // $17be
          jsr l18aa
          .byte $52,$2f,$49,$00		// "R/I" (retry or ignore)
l11db:     jsr l1a31
          cmp #$52		//"R" (retry)
          bne l11f5
          lda cntdn
          and #$01
          beq l11ea
          dec $07
l11ea:     lda #$05
          sta $0830
          jsr l1ab2
          jmp l113a
          
l11f5:     cmp #$49		//"I" (ignore)
          bne l11db
l11f9:     jsr l1f04
          jmp l0e69
          .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
l1207:     lda $082e
          pha
          lda #$80
          sta $082e
l1210:     jsr l1aa6		// BASIC and kernal out
          lda #$ca
          sta $fe
          lda #$12
          sta $ff
          lda #$03
          sta $0832
l1220:     ldy #$01
          lda $0832
          sta ($fe),y
          jsr l1f1f
          ldy #$e0
          ldx #$e8
          lda #$ff
          jsr fill_memory_area		// $155d fill $e000 to $e800 with $ff
          sec
          ldy #$e8
          ldx #$00
          lda #$55
          jsr fill_memory_area		// $155d fill $e800 to $0000 ($ffff) with $55
          lda #$01
          sta ridata
          sta riprty
          sta $07
          jsr l0c6c
          jsr l1ad4
          jsr l1efd
          lda #$16
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
          jsr l088c
          jsr l1ad4
          jsr l0861
          tya
          pha
          jsr l1f04
          pla
          beq l1285
          jsr l1aac    //switch BASIC out and kernal in
          jsr blank_actions_area_of_screen // $1880		// print $14 spaces 7 times
          jsr l1abe
          lda #$00
          jsr l1794
          lda $082a
          and #$10
          beq l1285
          jsr destination_disk:   // $17f5 
          jsr l1838
          jsr l1ab2
          jmp l1210
          
l1285:     jsr l1ad4
l1288:     lda (eal),y
          cmp #$ff
          beq l1295
          iny
          bne l1288
          inc eah
          bne l1288
l1295:     lda (eal),y
          cmp #$55			// "U"
          beq l12a2
          iny
          bne l1295
          inc eah
          bne l1295
l12a2:     lda $0832
          asl 
          tax
          sec
          tya
          sbc #$04
          sta $11ff,x
          lda eah
          sbc #$e0
          sta $1200,x
          dec $0832
          bmi l12bd
          jmp l1220
          
l12bd:     inc $0832
          jsr l18e3
          pla
          sta $082e
          jmp l1aac    //switch BASIC out and kernal in
          
          brk
          brk
          .byte $ff //;11111111
          .byte $1f //;00011111
          
l12ce:     jsr l12e6
          jsr l18aa
          .byte $1d,$1d,$24,$00	//crsr right x2, "$"
          ldy #$05
          lda ($fe),y
          jsr l1a83
          ldy #$04
          lda ($fe),y
          jmp l1a83
          
l12e6:     clc
          lda #$0c
          adc $0831
          tax			// add $0c to contents of $0831 and copy result to X
          ldy #$01
          clc
          jsr plot
          lda $0826		// guessing - this routine prints track (tens), track (units) . half track
          jsr l1a49
          jsr chrout
          txa
          jsr chrout
          lda #$2e		// "."
          jsr chrout
          tya
          jmp chrout
l1309:     ldy #$01
          lda ($fe),y
          asl 
          tax
          lda $11ff,x
          sta eal
          lda $1200,x
          sta eah
          lda #$00
          sta cntdn
l131d:     jsr l1aac    //switch BASIC out and kernal in
          clc
          lda #$0c
          adc $0832
          tax
          ldy #$0d
          clc
          jsr plot
          lda cntdn
          and #$7f		// 0111 1111 clear hi bit
          beq l1338
          lda #$12		// RVS on
          jsr chrout
l1338:     lda #$24		// "$"
          jsr chrout
          lda eah
          jsr l1a83
          lda eal
          jsr l1a83
          lda #$92		// RVS off
          jmp chrout
l134c:     jsr l1aa6		// BASIC and kernal out
          lda $082d
          bne l1357
l1354:     jmp l14d8

l1357:     ldy #$01
          lda ($fe),y
          asl 
          tax
          ldy #$02
          sec
          lda ($fe),y
          sta bitci
          sbc $11ff,x
          sta bufpt
          iny
          lda ($fe),y
          sta rinone
          sbc $1200,x
          sta inbit
          bcc l1354
          bne l1381
          dey
          lda ($fe),y
          cmp $11ff,x
          bcc l1354
          beq l1354
l1381:     clc
          lda bufpt
          adc #$04
          sta bufpt
          lda inbit
          adc #$00
          sta inbit
          ldx $0832
          lda $0e26,x
          sta sah
          clc
          adc rinone
          sta rinone
          lda $0e2b,x
          sta nxtbit
          lda $0e30,x
          sta $b3
          jsr l1ad4
          sty bitts
          sty $b2
          sty sal
          lda sal
          sta (eal),y
          inc eal
          lda sah
          sta (eal),y
          inc eal
          bne l13c2
l13bc:     inc bitts
          inc bitts
          beq l13fc
l13c2:     clc
          lda (bitts),y
          adc sal
          sta sal
          inc bitts
          lda (bitts),y
          adc sah
          sta sah
          dec bitts
          lda sah
          cmp rinone
          bcc l13e1
          bne l13fc
          lda sal
          cmp bitci
          bcs l13fc
l13e1:     clc
          lda ($b2),y
          adc sal
          sta sal
          sta (eal),y
          inc eal
          inc $b2
          lda ($b2),y
          adc sah
          sta sah
          sta (eal),y
          inc eal
          inc $b2
          bne l13bc
l13fc:     lda bitts
          sta cntdn
l1400:     ldy #$00
          sty $b2
          ldx #$00
          beq l1410
l1408:     lda inbit
          bne l1410
          lda bufpt
          beq l1442
l1410:     cpy cntdn
          beq l143f
          iny
          lda ($b2),y
          sta $fb
          dey
          lda ($b2),y
          sta $fa
          bne l1426
          lda $fb
          beq l143b
          dec $fb
l1426:     dec $fa
          tax
          lda $fa
          sta ($b2),y
          iny
          lda $fb
          sta ($b2),y
          dey
          lda bufpt
          bne l1439
          dec inbit
l1439:     dec bufpt
l143b:     iny
          iny
          bne l1408
l143f:     txa
          bne l1400
l1442:     ldx $0832
          lda $0e26,x
          sta sah
          jsr l1ad4
          sty bitts
          sty $b2
          sty sal
l1453:     lda (eal),y
          sta $b0
          inc eal
          lda (eal),y
          sta temp
          inc eal
          lda (bitts),y
          sta ridata
          inc bitts
          lda (bitts),y
          sta riprty
          dec bitts
l146b:     lda ridata
          bne l1473
          lda riprty
          beq l148e
l1473:     lda ($b0),y
          sta (sal),y
          inc $b0
          bne l147d
          inc temp
l147d:     inc sal
          bne l1483
          inc sah
l1483:     lda ridata
          bne l1489
          dec riprty
l1489:     dec ridata
          jmp l146b
l148e:     lda bitts
          cmp cntdn
          beq l14c4
          inc bitts
          inc bitts
          lda ($b2),y
          sta ridata
          inc $b2
          lda ($b2),y
          sta riprty
          inc $b2
l14a4:     lda ridata
          bne l14ac
          lda riprty
          beq l14c1
l14ac:     lda #$ff
          sta (sal),y
          inc sal
          bne l14b6
          inc sah
l14b6:     lda ridata
          bne l14bc
          dec riprty
l14bc:     dec ridata
          jmp l14a4
l14c1:     jmp l1453
l14c4:     ldx $0832
          sec
          ldy #$02
          lda sal
          sbc #$01
          sta ($fe),y
          iny
          lda sah
          sbc $0e26,x
          sta ($fe),y
l14d8:     jsr l1aac    //switch BASIC out and kernal in
          ldy #$01
          lda ($fe),y
          asl 
          tax
          ldy #$02
          sec
          lda ($fe),y
          sbc $11ff,x
          sta bufpt
          iny
          lda ($fe),y
          sbc $1200,x
          ldx #$01
          bcc l1507
          ldy #$04
l14f7:     asl bufpt
          rol 
          dey
          bne l14f7
          tay
          ldx $1511,y
          cpy #$18
          bcc l1507
          ldx #$08
l1507:     stx $07
          lda #$05
          sta $0830
          jmp l1aac    //switch BASIC out and kernal in
          
          .byte $41,$21,$21,$21,$11,$11,$11,$11,$11,$11
          .byte $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b
          .byte $09,$09,$09,$09,$09,$09
          
l1529:     ldy #$02
          sec
          lda #$ff
          sbc ($fe),y
          sta $b0
          sta eal
          iny
          lda #$ff
          sbc ($fe),y
          sta temp
          sta eah
          ldy $0832
          lda $0e26,y
          sta sah
          ldy #$00
          sty sal
          ldx #$00
l154b:     lda (sal),y
          sta ($b0,x)
          iny
          bne l1554
          inc sah
l1554:     inc $b0
          bne l154b
          inc temp
          bne l154b
          rts
          
fill_memory_area:     

			sty eah
          ldy #$00
          sty eal
l1563:     sta (eal),y
          iny
          bne l1563
          inc eah
          cpx eah
          bne l1563
l156e:          rts
          
	      
l156f:    jsr l18aa
l1572:    .byte $92			//RVS off
          .byte $13			// home
          .byte $9b 			// grey 3
          .byte $8e,$08		//upper case, disable shift C=
          .byte $20,$20,$b0	//spc, spc, top left corner
          .byte $01
          			//////////////////////////////////////
          .byte $22 // counter index - 22 chars to be printed
          .byte $63 // horiz centre line
          			//////////////////////////////////////
          .byte $ae,$20,$20	// top right corner, spc, spc
          .byte $b0,$63		// T rot 180 deg, horiz centre
          .byte $b3 			// T 90 deg cw
          
l1585:    .text "DOPPELGANGER V1.1F BY BILL BREMNER"
          
          .byte $ab			// T 90 deg ccw
          .byte $63			// horiz centre line
          .byte $ae,$62,$20	// top right corner, vert centre line, spc
          .byte $ad,$01		// bottom left corner, marker
          .byte $22,$63 		// horiz centre
          .byte $bd,$20		// bottom right corner, spc
          .byte $62,$62 		// vert centre line
          .byte $01,$26		// marker &
          .byte $20,$62,$00	// spc, vert centre line
          rts
          
l15b8:     clc
          ldx #$04
          ldy #$00
          jsr plot
          lda #$9b				//grey 3
          jsr chrout
          jsr l18aa
          
          .byte $62,$20,$20,$12 	//vert centre line, space x2, RVS on          
          .text "S"
          .byte $92 				//RVS off
          .text "YNCHRONISED TRACKS"
          .byte $01,$0a,$20,$00	// marker, 10x space, marker bottom left corner
          lda $082b				// synchronised tracks Y/N $80/$00
	      jsr $1658
	      jsr $18aa
          
          .byte $62,$20,$20,$12 	//cbm graphic, space x2, RVS on
          
          .text "H"
          .byte $92 				//RVS off
          .text "ALF TRACKS"          
          .byte $01,$12,$20,$00          
          lda $082c				// half tracks Y/N $80/$00
          jsr $1658
          jsr $18aa
          
          .byte $62,$20,$20,$12 //cbm graphic, space x2, RVS on          
          .text "T"          
          .byte $92 //RVS off
          .text "RACK SHORTENING"
          .byte $01,$0d,$20,$00
          lda $082d
          jsr $1658
          jsr $18aa
          
          .byte $62,$20,$20,$12 //cbm graphic, space x2, RVS on         
          .text "V"
          .byte $92 //RVS off
          .text "ERIFY"         
          .byte $20,$20,$00
          
 l163a:   lda $082e
          jsr $1658
          jsr $18aa
          .byte $9d,$9d,$20,$20	//cursor left x2, space x2
          .text "TRANSITIONS"
          .byte $20,$20,$00	//space x2 and end marker
          lda $082f
l1658:    bmi $1669
          
l165a:	 // "Y" normal "N" reversed 
		  jsr l18aa
	     .byte $2d,$20	// "-" space RVS off
		.byte $59,$2f,$12,$4e,$92,$20,$20	// "Y" RVS on "/N  "
          .byte $62 // vertical line
          brk
          rts
                    
l1669:     jsr $18aa		//print text below
          .byte $2d,$20,$12	//"-", space, RVS on
          .byte $59,$92,$2f	// "Y", RVS off, "/"
          .byte $4e,$20,$20,$62,$00	//"N", space x2, vertical middle line, marker
          rts
          
l1678:     clc
          ldx #$08
          ldy #$00
          jsr plot
          jsr l18aa
          
          /////////////////////////// These are mostly CBM ROM graphics for screen layout
          
          .byte $62,$01	//vertical middle line followed by marker
          .byte $26,$20,$62,$ab,$01 // "&", space, T ccw and vertical middle line
          .byte $05,$63,$b2,$01
          .byte $05,$63,$b2,$01
          .byte $05,$63,$b2,$01
          .byte $14,$63,$b3,$62
          
          .text"TRACK"
          
          .byte $62,$20
          
          .text"READ"
          
          .byte $62
          
          .text"WRITE"
          
          .byte $62,$01
          .byte $14,$20,$62,$ab,$01
          .byte $05,$63,$7b,$01
          .byte $05,$63,$7b,$01
          .byte $05,$63,$b3,$01
          .byte $14,$20,$62,$62,$01
          .byte $05,$20,$62,$01
          .byte $05,$20,$62,$01
          .byte $05,$20,$62,$01
          .byte $14,$20,$62,$62,$01
          .byte $05,$20,$62,$01
          .byte $05,$20,$62,$01
          .byte $05,$20,$62,$01
          .byte $14,$20,$62,$62,$01
          .byte $05,$20,$62,$01
          .byte $05,$20,$62,$01
          .byte $05,$20,$62,$01
          .byte $14,$20,$62,$62,$01
          .byte $05,$20,$62,$01
          .byte $05,$20,$62,$01
          .byte $05,$20,$62,$01
          .byte $14,$20,$62,$62,$01
          .byte $05,$20,$62,$01
          .byte $05,$20,$62,$01
          .byte $05,$20,$62,$01
          .byte $14,$20,$62,$ad,$01
          .byte $05,$63,$b1,$01
          .byte $05,$63,$b1,$01
          .byte $05,$63,$b1,$01
          .byte $14,$63,$bd,$00
          rts
          
l1729:     clc
          ldx #$12
          ldy #$00
          jsr plot
          jsr l18aa
          
          /////////////////              This section prints the lower part of the screen
          
          .byte $98,$01									//grey 2
          .byte $09,$30,$01								//nine times, "0", marker
          .byte $0a,$31,$01								//ten times "1"
l173c:    .byte $0a,$32,$01								//ten times "2"
		  .byte $0a,$33,$34								//ten times "3" "4"
		  .byte $31,$32,$33,$34,$35,$36,$37,$38,$39		//123456789
		  .byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39	//0123456789
		  .byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39	//0123456789
		  .byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39	//0123456789
		  .byte $30,$01									//0 then marker
		  .byte $28,$20,$01								//$28 spaces
		  .byte $28,$20,$75,$01							//$28 spaces then bottom right arc
		  .byte $07,$63,$33,$01,$07,$63,$69				//$33 = "3"
		  .byte $75,$63,$63,$32,$63,$63,$69				//$32 = "2"
		  .byte $75,$63,$63,$31,$63,$69					//$31 = "1"
		  .byte $75,$63,$30,$63,$69,$01					//$30 = "0"
		  .byte $28,$20,$01
		  .byte $27,$20,$9b,$00
		  rts
          
l1794:     clc
          adc #$0a
          tax
          ldy #$13
          clc
          jmp plot
          
please_insert: // $179e:     
			
			lda #$00
          jsr l1794					//add $0a to A, tax, Y=#$13, plot
          jsr l18aa
          .byte $20,$20,$20
          .byte $12					//RVS on
			.text"PLEASE INSERT"
          .byte $92					//RVS off
          .byte $20,$20,$20,$20,$00
          rts
                    
options:  // $17be:     

		  lda #$03
          jsr l1794					//add $0a to A, tax, Y=#$13, plot
          jsr l18aa					//prints below stuff on the screen
          .text" OPTIONS: "
          .byte $00
          rts
          
source_disk: //$17d2:     

			jsr please_insert 			// $179e
          lda #$01
          jsr l1794					//add $0a to A, tax, Y=#$13, plot
          jsr l18aa
          .byte $20,$20,$20,$20
          .byte $12					//RVS on
          .text"SOURCE DISK"
		  .byte $92					//RVS off
          .byte $20,$20,$20,$20,$20,$00
			rts
          
destination_disk:   // $17f5  

			jsr please_insert			// $179e
	      lda #$01
          jsr l1794					// add $0a to A, tax, Y=#$13, plot
          jsr l18aa
          .byte $20,$20,$12			// space x2, RVS on
          .text"DESTINATION DISK"
          .byte $92,$20,$20,$00		// RVS off, space x2
          rts
          
choose_option: // $1818:     

		  lda #$00
          jsr l1794		//add $0a to A, tax, Y=#$13, plot
          jsr l18aa
          .byte $12		//RVS on
          .text"PLEASE CHOOSE OPTION"
          .byte $92,$00	//RVS off and end marker
          rts
          
l1838:     lda #$06		// 0000 0110
          sta $02
          lda #$00
          sta cntdn		//$A5
          sta ndx			//$C6
          
l1842:     lda cntdn
          eor #$ff		// flip the bits of cntdn
          sta cntdn
          bne l184f		// if cntdn=0 then RVS on. If it = $FF then skip next instruction (leave RVS off)
          lda #$12		//RVS on
          jsr chrout
l184f:     jsr l189f		// delay - countdown from $c000
          lda $02
          jsr l1794		//add $0a to A, tax, Y=#$13, plot
          jsr l18aa
          .byte $20
          .text"PRESS  <SPACE> BAR"
          .byte $20
          .byte $92,$00
          jsr stop		//$FFE1
          bne l1878		// skip next instruction if not pressed
          jmp l1a12
l1878:     jsr getin
          cmp #$20		// was Space pressed ?
          bne l1842		// no - go back up
          rts
          
blank_actions_area_of_screen:
	     lda #$00
          sta $1893
l1885:     jsr l1894		// print $14 spaces
          inc $1893
          lda $1893
          cmp #$07		// print the above $14 spaces, 7 times
          bne l1885
          rts
          
l1893:     brk

l1894:     jsr l1794		//add $0a to A, tax, Y=#$13, plot
          jsr l18aa
          .byte $01,$14,$20,$00	// marker, PRINT x, char to print, marker. ($14 spaces)
          rts
          
l189f:     ldy #$c0		// delay for $c000 countdown
          ldx #$00
l18a3:     dex
          bne l18a3
          dey
	     bne l18a3	     
          rts
          
l18aa:     pla			//
          sta resmoh
          pla			// pull the return address from the stack
          sta resmo
l18b0:     inc resmoh		//add 1 to the return address ie PC+1 to point at text after the JSR

          bne l18b6		//resmoh hasn't reached #$FF yet so jump over next instruction
          inc resmo
          
l18b6:     ldy #$00
          lda (resmoh),y	//read from retrieved stack address +Y							// start printing chars until we meet $01 or $00
          
          beq l18dc		//branch as we just read a zero end of char block
          cmp #$01		//did we just read a #$01 marker ? $01 means the following byte is the number of repeated chars to print
          beq l18c6		//yes we did - branch
          
          jsr chrout		//no we didn't - print what we just read
          jmp l18b0		//go back and read next char to be printed
          
l18c6:     inc resmoh		//we just read a #$01 so inc $7a to point at instruction after the #$01.
          bne l18cc		//skip next instruction if resmoh has not passed #$FF
          inc resmo		//inc hi byte
l18cc:     lda (resmoh),y	//get the char following #$01 as it is the NUMBER OF CHARS to print
          tax			//use it as an index
          dex			//count down by 1 ///////why decrement it immediately ?? ///////////
          ldy #$01
          lda (resmoh),y	//get the char to be repeatedly printed
          
l18d4:     jsr chrout		//this routine prints the same char X times eg horizontal lines around "Doppelganger ....."
          dex			//print it X times
          bne l18d4
          
          beq l18b0		//once finished printing the same char go back up
          
l18dc:     lda resmo		//store the current address of ($resmo) and RTS
          pha
          lda resmoh
          pha
          rts		//////////////////////
          
         
l18e3:     lda $0826
          lsr 			//divide  by 2
          tay
          dey			// minus 1
          sty rinone		// $A9
          lda #$00
          sta $ff			// $ff = $00
          ldy $0826
          dey
          dey
          sty $fe			// $fe = contents of $0826 minus 2
          
          ldy #$04		// we're going to do this 4 times
l18f8:     asl $fe		// ($fe) *2 with MSB going to Carry
          rol $ff			// Carry moved into LSB of $ff			// 4 MSBs of $fe moved to 4 LSBs of $ff
          dey
          bne l18f8		// do the above 4 times
          
          clc
          lda $ff
          adc #$c0		// add 1100 0000 to contents of $ff
          sta $ff
          sta $fd
          clc
          lda $fe
          adc #$08		// add 0000 1000 to contents of $fe and store in $fc
          sta $fc
          rts
          
l1910:     lda #$57		// "W" used for memory write command
          jsr l19d3		// send "M-" followed by "W" above (memory write)
          lda #$6a		// m-w lo byte	REVCNT
          jsr iecout
          lda #$00		// m-w hi byte
          jsr iecout
          lda #$01		// only 1 char length
          jsr iecout
          lda #$05		// counter for error recovery (no of attempts so far - normally 5)
          jsr iecout
          jsr unlstn		//send $006A,$01,$05 then unlisten
          
l192c:     jsr l19e5		//initialise drive and RTS if OK.
          lda #$49		// "I" or is it $40 (Control code for TALK) + (device $09)?
          jsr iecout		//$FFA8 -> $EDDD output 1 char to serial bus or send already buffered char
          jmp unlstn		//$FFAB -> $EDFE send last buffered char with End Or Identify (EOI)
          
l1937:     jsr l1aa3		//Switch out BASIC and kernal routine
          lda #$b6		//
          sta eal			//end address = $1FB6
          lda #$1f
          sta eah
          
          ldy #$00		//start address = $D000
          sty sal
          lda #$d0
          sta sah
          
          ldx #$06		//6 pages to be moved
          ldy #$00
l194e:     lda (sal),y
          sta (eal),y
          iny			//move contents of $D000 - $D600
          bne l194e		//to $1FB6 - $1FB6+$600
          inc eah
          inc sah
          dex
          bne l194e		//
          
          jsr l1aac    	//switch BASIC out and kernal in
          lda #$b6		//
          sta eal
          lda #$1f		//end address = $1FB6
          sta eah
          lda #$13
          sta sah			//start address = $13xx
          ldy #$00          
l196d:     lda #$57		// "W" used for memory write command
          jsr l19d3		// send "M-" followed by "W" above (memory write)
          
          clc
          tya			// Y and A =0 here
          adc #$da		// lo byte for m-w address
          jsr iecout		//
          lda #$01		// hi byte for m-w address
          jsr iecout		
          lda #$13
          jsr iecout		// send $01da then $13 (no of chars to send) to 1541 over IEC
          
l1983:     lda (eal),y	// get 13 bytes from (eal) and send them over IEC to 1541
          jsr iecout		//
          iny
          cpy sah			// sah = $13 from $1969 above
          bne l1983		//       
          jsr unlstn
          
          lda #$26		// get another $26 chars
          sta sah			//
          cpy #$26
          bne l196d		// and send M-W them
          
          lda #$45		// "E" used for memory execute command
          jsr l19d3		// send "M-" followed by "E" above (memory execute)
          lda #$da
          jsr iecout
          lda #$01
          jsr iecout		// execute memory at $01da
          jsr unlstn
          
l19aa:    lda #$dc		///////////////////////The routine below moves 6 pages from $1fdc to $dd??????????
          sta eal
          lda #$1f
          sta eah			//$1fdc stored at (eal)
          sei
          lda #$ff
          sta $dd03		//DDRB typically zero
          ldx #$06
          ldy #$00
l19bc:     lda (eal),y
          sta $dd01
l19c1:     lda $dd0d		//ICR for CIA2
          beq l19c1
          iny
          bne l19bc
          inc eah
          dex
          bne l19bc
          stx $dd03		//X is now zero so store it in DDRB
          cli
          rts
          
l19d3:     pha			//save A onto stack. A will contain "E" or "W" for "M-E" or "M-W"
          jsr l19e5		//make drive 8 / sa 15 listen
          
          lda #$4d		// "M"
          jsr iecout
          lda #$2d		// "-"
          jsr iecout		
          pla
          jmp iecout		//send "M-" then retrieve A from stack and send it to drive
          				// after the above command runs, the RTS will go back to wherever called this section
          
l19e5:     lda #$00		// clear STATUS location		
          sta status		// $90
          lda fa			// $BA current device number
          jsr listen		// $FFB1 -> $EDOC. ORs the device number in the Ac­cumulator 
          				// with the LISTEN code (32, $20, %0010 0000) and sends it on the serial
			        		// bus. This commands the device to LISTEN.
						// device 8 is ORed with $20. 
					    	// 0010 0000 = $20
					    // 0000 1000 = $08
					    // 0010 1000 = $28
					    // $28= $20 (Control code for LISTEN) + $08 (device 8)
				        
          lda #$6f		// $6f= $60 (Control code for OPEN CHANNEL / DATA) + $0f (ch 15)
          				// 0110 1111 according to Bill Bremner article in YC22 p57, bits 5 and 6 are
          				// set then secondary address is ORed with $60) = $6F before calling LSTNSA
          
          jsr lstnsa		// FF93 -> $EDB9. Sends secondary address from Accumulator
          				// to the device on the serial bus that has just been com­manded to LISTEN.
          				// This is usually done to give the device more par­ticular instructions 
						// on how the I/O is to be carried out before infor­mation is sent.
					
          lda status		// $90
          bne l19f8		// is it still zero?
          rts			// yes - go back to return address (stack)		$192f ??
                   
l19f8:     pla			// no - ditch the return address 
          pla			// from stack (looking at SP)
          rts			// go back effectively two JSRs	$0810 ??
          
          
l19fb:          //////////////////////////////////////////////////////////NMI routine is here
          pha		//save A,X,Y and contents of $01
          txa		//
          pha		//
          tya		//
          pha		//
          lda $01		//
          pha		//
          
          lda #$37	//%0011 0111
          sta $01		//All ROMs in
          
          jsr $f6ed	//Test for STOP key
          			//checks to see if the STOP key was pressed during the last UDTIM call. If it
					//was, the Zero flag is set to 1, the CLRCHN routine is called to set
					//the input and output devices back to the keyboard and screen, and
					//the keyboard queue is emptied.
          bne l1a24	//branch if not pressed
          jsr $fda3	//initializes the Complex Interface Adapt­er (CIA) devices, and turns the volume
          			//of the SID chip off. As part of this initialization, it sets CIA #1 Timer A
					//to cause an IRQ inter­rupt every 50th of a second.
					
          jsr $ff5b	//Initialize Screen Editor and VIC-Chip
          
l1a12:     lda $0823	//this location starts off at zero when program loaded
          beq l1a21		//branch if it is still zero
          lda #$00		//no it's not zero so reset it to zero
          sta $0823
          lda #$04
          jsr l1ecb    //switch user port to output, send contents of A then switch to input 
l1a21:     jmp l08b3	//

l1a24:     pla
          sta $01
          pla
          tay
          pla
          tax
          pla
          rti
          /////////////////////////////////////////////////////////////////////////////////////
          
l1a2d:     lda #$00
          sta blnsw		//turn on cursor blink
l1a31:     lda #$01
          sta $dc0e		// CIA1 timer A stop
          cli
          jsr stop		//zero flag set if Run Stop pressed
          bne l1a3f		//branch as it was not pressed
          jmp l1a12
          
l1a3f:     jsr getin
          beq l1a3f	
          ldx #$01
          stx blnsw		// turn off cursor blink
          rts
          
l1a49:     // A= contents of $0826 on arriving here
		  ldy #$30		// 48 decimal or 0011 0000
          lsr			// divide A by 2
          bcc l1a50		// skip next instruction if LSB was "0"
          ldy #$35		// 53 decimal or 0011 0101
l1a50:     pha			// save A to stack ($0826) divided by 2
          lsr
          lsr
          lsr
          lsr			// divide A by 16 (now divided by 32 total)
          sed
          tax			// use A as an index
          beq l1a61		// branch if it's zero
          
          clc
          lda #$00
l1a5c:     adc #$16		// 16 BCD, 22 decimal or 0001 0110
          dex
          bne l1a5c
          
l1a61:     sta $05		// store result of about calculation at $05
          cld
          pla			// retrieve A from stack
          and #$0f		// 0000 1111 clear upper nybble
          cmp #$0a		// 0000 1010
          bcc l1a6d		// branch if A < $0a, continue if A >= $0a
          adc #$05		//
l1a6d:     sed
          adc $05			// BCD add contents of $05
          cld
          pha			// push A to stack
          lsr
          lsr
          lsr
          lsr			// divide A by 16 or eject lower nybble
          ora #$30		// 0011 0000 set bits 5 and 6
          sta $05			// store result in $05
          pla			// retrieve A from stack
          and #$0f		// 0000 1111 clear upper nybble
          ora #$30		// 0011 000 set bits 5 and 6
          tax			// use A as index
          lda $05
          rts
          
l1a83:     pha			// store A on stack
          jsr l1a97		// returns with A = $3x or 0011 xxxx
          tay			// store A in Y temporarily
          pla			// retrieve A from stack (above)
          lsr
          lsr
          lsr
          lsr			// divide A by 16 or eject lower nybble
          jsr l1a97		// returns with A = $3x or 0011 xxxx
          jsr chrout		// print value in A
          tya			// retrieve A from Y
          jmp chrout		// print value in A
          
l1a97:     and #$0f		// 0000 1111 clear upper nybble
          ora #$30		// 0011 0000 set bits 5 and 6
          cmp #$3a		// ":" 0011 1010 (illegal BCD)
          bcc l1aa2		// branch to RTS if A < $3a, continue if >= $3a
          clc
          adc #$07		// add 7 to $0a or greater, $0a = $11, $0b = $12, $0c = $13 etc
l1aa2:     rts


l1aa3:    lda #$34		//; 0011 0100 BASIC and kernal out

						// The next command should read BIT $35A9
						// BIT prevents lda #$35 being picked up but 
						// some branches will go straight to $1aa6
						
		.byte $2c		// BIT
l1aa6:    lda #$35 		//; 0011 0101 BASIC in and kernal out
						//
			
          sei
          sta $01	
          rts
          
l1aac:     lda #$36	//0011 0110 switch BASIC out and kernal in
          sta $01
          cli
          rts
          
l1ab2:     lda #$ef	//1110 1111
          sta $d030	//Not Connected
					//The VIC-II chip has only 47 registers for 64 bytes of possible address
					//space. Therefore, the remaining 17 addresses do not access any
					//memory. When read, they will always give a value of 255 ($FF).
					//This value will not change after writing to them.
					
          and $d011	//clear bit 4 
          sta $d011	//blank screen 
          rts
          
l1abe:     lda #$10	//0001 0000
          sta $d030	//see note above          
          			
          ldy #$80	//delay of $8000
          ldx #$00
l1ac7:     dex
          bne l1ac7
          dey
          bne l1ac7
          ora $d011	//set bit 4
          sta $d011	//unblank screen
          rts
          
l1ad4:     lda #$e0	//end address = $E000
          sta eah
          ldy #$00
          sty eal
          rts
          
l1add:     jsr l1aa3 //BASIC and kernal out
          lda #$60	// start address = $6000
          sta sah
          sta riprty //$AB This location is used to help detect if data was lost during RS-232
					// transmission, or if a tape leader is completed.
					
          lda #$00	
          sta sal
          sta ridata //$AA Serial routines use this area to reassemble the bits received into a
					//byte that will be stored in the receiving buffer pointed to by 247($F7).
          lda #$e0	//end address = $E000
          sta eah
          sta inbit	//This location is used to temporarily store each bit of serial data that
					//is received
          ldy #$00
          sty eal
          sty bufpt	//tape pointer - not used with Phantom. Temp storage ?
          sty cntdn	//tape pointer - not used with Phantom. Temp storage ?
          jmp l1b56
          
l1afd:     inc sal		//sal=sal+1
          bne l1b05		//branch if SAL has not counted past $FF
          inc sah			//if sal has counted past $FF then sah=sah+1
          bmi l1b21		//branch if sah has counted to $FF
l1b05:     lda (sal),y	//load A with one byte at start address+Y
l1b07:     and #$0f		//%0000 1111 clears bits 4-7
          cmp #$0f		//are contents of start address+Y = 0000 1111
          bne l1afd		//No? go back thru loop
          
l1b0d:     inc sal		//sal=sal+1
          bne l1b15		//branch if SAL has not counted to $FF
          inc sah			//if sal has counted to $FF then sah=sah+1
          bmi l1b21		//branch if sah >=$80 (is bit 7 set?)
l1b15:     lda (sal),y	//load A with one byte at start address+Y
          cmp #$ff		//now looking for $FF after finding $0F in above routine
          bne l1b07		//branch if sah has counted to $FF
          
l1b1b:     inc sal		//sal=sal+1
          bne l1b23		//branch if SAL has not counted to $FF
          inc sah			//if sal has counted to $FF then sah=sah+1
l1b21:     bmi l1b74		//branch if sah >=$80 (is bit 7 set?)
l1b23:     lda (sal),y	//load A with one byte at start address+Y
          cmp #$ff		//is it $FF
          beq l1b1b		//yes? jump back up
          
          lda sah
          cmp #$76		//is sah = %0111 0110
          bcc l1b56		//branch if it is <= $76
          
l1b2f:     lda (sal),y	//load A with one byte from ($AC) + Y
          cmp (ridata),y	//compare it to data in ($AA) + Y
          beq l1b43		//branch if they are the same
          tax			//use whatever was in (sal) as an index
          lda $dd00,x		//load A with contents of CIA2 + X
          bmi l1b43		//is A >=$80 branch if bit 7 set (minus number)
          lda (ridata),y	//load A with ($AA) + Y
          tax			//use it as an index
          lda $dd00,x		//load A with contents of CIA2 + X
          bpl l1b56		//branch if bit 7 is NOT set (positive number)
          
l1b43:     iny			//Y=Y+1
          bmi l1b74		//is Y >= $80 (is bit 7 set)
          cpy cntdn		//subtract contents of $A5 from Y
          bcc l1b2f		//branch if result is positive
          sty cntdn		//Y now stored in $A5
          lda eal			//copy contents of eal to $A6
          sta bufpt
          lda eah			//copy contents of eah to $A7
          sta inbit
          bne l1b2f		//branch if contents of $A7 were zero
          
l1b56:     ldy #$00
          lda sal			//copy start address low byte(xx00)
          sta (eal),y		//to end address + Y
          inc eal			//increase end address low byte by 1 (xx01)
          lda sah			//copy start address high byte
          sta (eal),y		//to end address+1 + Y (xx01)
          inc eal        //increase end address low byte by 1 (xx02)
          
          lda #$09		//$0900 = buffer start address 
          sta $f8			//RIBUF - When device number 2 (the RS-232 channel) is opened, two buffers
						//of 256 bytes each are created at the top of memory. This location
						//points to the address of the one which is used to store characters as they are received.
          bne l1b76		//is ($F8) = zero? No - goto $1B76
l1b6a:     dec $f8		//reduce buffer pointer by 1
          beq l1b9e		//branch if buffer empty
          inc sal			//next 
          bne l1b76
          inc sah
l1b74:     bmi l1bac

l1b76:     lda (sal),y	//load A with one byte at start address + Y
          tax			//use this number as a count index
          lda $dd00,x		//load A with contents of CIA2 + X
          bmi l1b9e		//check if bit 7 (DATA IN) is set
          txa
          and #$0f		//0000 1111 clear bits 3 to 7
          cmp #$0f
          bne l1b6a
          dec $f8
          beq l1ba5
          inc sal
          bne l1b91
          inc sah
          bmi l1bac
l1b91:     lda (sal),y
          cmp #$ff
          bne l1b76
          lda #$00
          sta (sal),y
          jmp l1b1b
          
l1b9e:     lda #$00		//
          sta (sal),y		//put zero into start address + Y
          jmp l1afd
          
l1ba5:     lda #$00
          sta (sal),y
          jmp l1b0d
l1bac:     ldy #$ff
          sty $f9
          iny
          sty $f7
          lda #$00
          sta sal
          lda #$e0
          sta sah
          lda (sal),y
          sta $fa
          iny
          lda (sal),y
          sta $fb
          bne l1bd2
l1bc6:     inc sal
          inc sal
          bne l1bd2
          inc sah
          ldy #$00
          sty cntdn
l1bd2:     lda inbit
          sta eah
          lda bufpt
          sta eal
l1bda:     jsr l1cd5
l1bdd:     lda ($b2),y
          beq l1c04
          cmp ($b0),y
          bne l1bec
          iny
          cpy #$08
          bne l1bdd
          beq l1c04
l1bec:     jsr l0cea
          jsr l0cea
          lda eal
          cmp sal
          bne l1bda
          lda eah
          cmp sah
          bne l1bda
          lda cntdn
          ora #$04
          sta cntdn
l1c04:     ldx #$ff
          ldy #$00
          lda ($b2),y
          cmp #$52
          bne l1c3b
          lda cntdn
          ora #$02
          sta cntdn
          ldy #$02
          lda ($b2),y
          beq l1c3b
          and #$0f
          sta $f8
          iny
          lda ($b2),y
          beq l1c3b
          asl 
          rol $f8
          lsr 
          lsr 
          lsr 
          and #$1f
          tax
          lda $1cb5,x
          ldx $f8
          ora $1c95,x
          tax
          lda cntdn
          ora #$01
          sta cntdn
l1c3b:     lda cntdn
          cmp $f7
          bcc l1c56
          bne l1c4a
          txa
          cmp $f9
          bcs l1c56
          sta $f9
l1c4a:     lda $b2
          sta $fa
          lda $b3
l1c50:     sta $fb
          lda cntdn
          sta $f7
l1c56:     lda sah
          cmp inbit
          bcc l1c64
          bne l1c67
          lda sal
          cmp bufpt
          bcs l1c67
l1c64:     jmp l1bc6
l1c67:     lda $fa
          sta $b2
          lda $fb
          sta $b3
          ldy #$01
          lda ($b2),y
          bne l1c80
          dey
          lda ($b2),y
          beq l1c8e
          and #$0f
          cmp #$0f
          beq l1c8e
l1c80:     lda $b2
          sta sal
          lda $b3
          sta sah
          lda #$00
          .byte $2c
l1c8b:    lda #$44
          .byte $2c
l1c8e:    lda #$82
          sta cntdn
          jmp l1aa6		// BASIC and kernal out
          
          .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          .byte $ff,$80,$00,$10,$ff,$c0,$40,$50
          .byte $ff,$ff,$20,$30,$ff,$f0,$60,$70
          .byte $ff,$90,$a0,$b0,$ff,$d0,$e0,$ff
		  .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		  .byte $ff,$08,$00,$01,$ff,$0c,$04,$05
		  .byte $ff,$ff,$02,$03,$ff,$0f,$06,$07
		  .byte $ff,$09,$0a,$0b,$ff,$0d,$0e,$ff
          
l1cd5:     ldy #$01
          lda (eal),y
          sta temp
          lda (sal),y
          sta $b3
          dey
          lda (eal),y
          sta $b0
          lda (sal),y
          sta $b2
          rts
l1ce9:     jsr l1dcc
          jmp l1d1e
l1cef:     jsr l1df1
          ldy #$05
          lda (sal),y
          cmp (eal),y
          bcc l1d1e
          dey
          lda (sal),y
          cmp (eal),y
          bcc l1d1e
          iny
          lda (sal),y
          cmp (ridata),y
          bcc l1d1e
          dey
          lda (sal),y
          cmp (ridata),y
          bcc l1d1e
          ldy #$00
          lda #$88
          sta (sal),y
          ldy #$04
          lda #$ff
          sta (sal),y
          iny
          sta (sal),y
l1d1e:     lda sal
          cmp #$e0
          bne l1cef
          lda sah
          cmp #$c4
          bne l1cef
          jsr l1dcc
          ldy #$05
          jmp l1d45
l1d32:     jsr l1df1
          ldy #$05
          lda (sal),y
          cmp (ridata),y
          bcs l1d52
          dey
          lda (sal),y
          cmp (ridata),y
          bcs l1d52
          iny
l1d45:     lda (sal),y
          cmp (eal),y
          bcs l1d52
          dey
          lda (sal),y
          cmp (eal),y
          bcs l1d52
l1d52:     lda sal
          cmp #$e0
          bne l1d32
          lda sah
          cmp #$c4
          bne l1d32
          jsr l1dcc
          jmp l1d67
l1d64:     jsr l1df1
l1d67:     lda (sal),y
          bne l1d71
          lda #$88
          sta (ridata),y
          sta (eal),y
l1d71:     lda sal
          cmp #$e0
          bne l1d64
          lda sah
          cmp #$c4
          bne l1d64
          jsr l1dcc
          lda #$88
          sta (ridata),y
          bne l1d95
l1d86:     lda sal
          cmp #$e0
          bne l1d92
          lda sah
          cmp #$c4
          beq l1dcb
l1d92:     jsr l1df1
l1d95:     lda (sal),y
          beq l1d86
          cmp #$88
          beq l1d86
          cmp #$44
          beq l1db7
          lda (eal),y
          bne l1dab
l1da5:     lda #$88
          sta (sal),y
          bne l1d86
l1dab:     lda (ridata),y
          beq l1da5
          lda (eal),y
          cmp #$44
          beq l1da5
          bne l1d86
l1db7:     lda (eal),y
          beq l1da5
          lda (ridata),y
          beq l1da5
          lda #$00
          sta (sal),y
          lda #$88
          sta (eal),y
          sta (ridata),y
          bne l1d86
l1dcb:     rts
l1dcc:     ldy #$00
          lda #$00
          sta sal
          lda #$c0
          sta sah
          sec
          lda sal
          sbc #$10
          sta ridata
          lda sah
          sbc #$00
          sta riprty
          clc
          lda sal
          adc #$10
          sta eal
          lda sah
          adc #$00
          sta eah
          rts
l1df1:     clc
          lda eal
          adc #$10
          sta eal
          lda eah
          adc #$00
          sta eah
          clc
          lda ridata
          adc #$10
          sta ridata
          lda riprty
          adc #$00
          sta riprty
          clc
          lda sal
          adc #$10
          sta sal
          lda sah
          adc #$00
          sta sah
          rts
l1e19:     jsr l1aa3
          jsr l1ad4
          sty bufpt
          sty inbit
          tya
l1e24:     sta $0030,y
          iny
          cpy #$10
          bne l1e24
          bit $082c			// half tracks Y/N $80/$00
          bmi l1e51
l1e31:     lda (eal),y
          beq l1e92
          tax
          lda $df00,x
          bpl l1e3e
          lsr
          bcc l1e48
l1e3e:     lda $de00,x
          tax
          inc $30,x
          bne l1e48
          inc $38,x
l1e48:     iny
          bne l1e31
          inc eah
          bne l1e31
          beq l1e92
l1e51:     lda (eal),y
          tax
          lda $de00,x
          sta cntdn
l1e59:     lda (eal),y
          beq l1e87
          tax
          lda $df00,x
          bpl l1e6a
          asl 
          bmi l1e7a
          and #$1e
          beq l1e80
l1e6a:     lda $de00,x 
			tax
          inc $30,x
          bne l1e74
          inc $38,x
l1e74:     cmp cntdn
          beq l1e80
          sta cntdn
l1e7a:     inc bufpt
          bne l1e80
          inc inbit
l1e80:     iny
          bne l1e59
          inc eah
          bne l1e59
l1e87:     ldy #$04
          lda bufpt
          sta ($fe),y
          iny
          lda inbit
          sta ($fe),y
l1e92:     jsr l1aa6		// BASIC and kernal out
          ldx #$03
          stx cntdn
l1e99:     dec cntdn
          ldy cntdn
l1e9d:     lda $0038,y
          cmp $38,x
          bcc l1eaf
          bne l1eb4
          lda $0030,y
          cmp $30,x
          beq l1ebb
          bcs l1eb4
l1eaf:     dey
          bpl l1e9d
          bmi l1ec1
l1eb4:     dex
          bne l1e99
          tya
          tax
          beq l1ec1
l1ebb:     dex
          bne l1e99
          jsr l1eda			// compare contents of $0826 to $52,$3E,$32,$24 in reverse order
l1ec1:     rts

l1ec2:     lda $dd0d		//wait for interrupt
          beq l1ec2		//
          lda $dd01		//load A with user port data and return
          rts
          
l1ecb:     dec $dd03		//decrement DDRB which is typically zero (all inputs)
						//decrementing it will switch all bits to $FF outputs
						
          sta $dd01		//store A in PB user port / RS232          
						//Bit 0: Pin C of User Port
						//Bit 1: Pin D of User Port
						//Bit 2: Pin E of User Port
						//Bit 3: Pin F of User Port
						//Bit 4: Pin H of User Port
						//Bit 5: Pin J of User Port
						//Bit 6: Pin K of User Port
						//		Toggle or pulse data output for Timer A
						//Bit 7: Pin L of User Port
						//		Toggle or pulse data output for Timer B
						
l1ed1:     lda $dd0d	//
          beq l1ed1		//keep reading CIA 2 ICR until there is an interrupt
          inc $dd03		//increment DDRB
          				//this might be switching user port from $FF to $00 outputs to inputs
          rts
          
l1eda:     lda $0826		//this location contains zero when program is loaded
          ldx #$04
l1edf:     cmp $1ee5,x	//$1EE6 onward contains $52,$3E,$32,$24
          dex
          bcs l1edf		//compare the contents of $0826 to the above 4 bytes in reverse order. branch if A >= byte
          rts
          
          .byte $52,$3E,$32,$24		// 01010010, 00111110, 00110010, 00100100
          
l1eea:     ldx #$04
          ldy #$ff
          jsr l1f0b		//send $02, $04 and $ff on user port then read a byte and store in $082A
          lda #$18
          jmp l1ecb    	//switch user port to output, send contents of A then switch to input 
          
l1ef6:     ldx #$00
          ldy #$fb
          jmp l1f0b		//send $02, $00 and $fb on user port then read a byte and store in $082A		
          
l1efd:     ldx #$08
          ldy #$ff
          jmp l1f0b		//send $02, $08 and $ff on user port then read a byte and store in $082A
          
l1f04:     ldx #$00
          ldy #$f7
          jmp l1f0b		//send $02, $00 and $f7 on user port then read a byte and store in $082A
          
l1f0b:     lda #$02
          jsr l1ecb     //switch user port to output, send contents of A then switch to input 
          txa
          jsr l1ecb     //switch user port to output, send contents of A then switch to input 
          tya
          jsr l1ecb     //switch user port to output, send contents of A then switch to input 
          jsr l1ec2		//load A with user port data
          sta $082a		//store user port data here
          rts
          
l1f1f:     tax
          lda $1f29,x
          tax
l1f24:     ldy #$9f
          jmp l1f0b		//send $02, X (a no from below) and Y ($9f) on user port then read a byte and store in $082A
          
l1f29:    .byte $0c 		// are these some sort of command or parameter for the 1541 ??
          .byte $2c
          .byte $4c
l1f2c:    .byte $6c

	// Prepare to relocate code to $d000
l1f2d:     
						// $1fb6 put into (eah/eal)
		lda #$b6
          sta eal 		//; end address low for load / save
          lda #$1f
          sta eah 		//; end address high for load / save
          
          				// $d000 into (sah/sal)
          lda #$00
          sta sal 		//; start address low load / save
          lda #$d0
          sta sah 		//; start address high load / save
          
          ldx #$06 		//6 pages to be moved
          ldy #$00
          
 //relocate code at $1fb6 - $25b6 to $d000 - $d600
          
l1f41:    lda (eal),y		//source addr $1fb6,y
          sta (sal),y 	//dest addr $d000,y
          iny
          bne l1f41
          inc eah
          inc sah
          dex
          bne l1f41
          		
		        // fill de00-deff and df00-dfff with byte patterns--------------------
l1f4f:     txa
				// get rid of two LSBs 
          lsr			// divide by 2
          lsr			// divide by 2 again
          and #$27		// 0010 0111
          cmp #$20		// 0010 0000
          bcc l1f66		// branch if A < $20
          beq l1f64		// branch if = $20
          cmp #$27		// 0010 0111
          beq l1f62		// = $27
          lda #$c0		
          bne l1f66
l1f62:     ora #$2f		// 0010 1111
l1f64:    eor #$a0		// 1010 0000
l1f66:     sta $df00,x
          txa
          lsr
          and #$30		// 0011 0000
          ora $df00,x
          sta $df00,x
          lsr
          lsr
          lsr
          lsr
          and #$07		// 0000 0111
          sta $de00,x
          inx
          bne l1f4f
				//-----------------------------------------------------------------
				
				//fill $dd00-$ddff with byte patterns at $1f96 onward          
l1f7f:     txa
          lsr
          lsr
          lsr
          tay			// divide X by 16 and copy it to Y
          lda $1f96,y		// get 1 byte from the below table indexed by Y
          ldy #$08		// set Y to 8 for this loop. We're going to ASL 8 times on the same byte
          
l1f89:     sta $dd00,x	// store the value read from the table at $DD00 indexed by X
          asl 			// 
          inx			// increase $DD00 address
          dey			// count down Y for this loop
          bne l1f89		// go back up if Y <> zero
          cpx #$00		// if Y=0 then check if X=0
          bne l1f7f		// go back up if X<>0
          rts			// go back to $081d ??
l1f96:          
			.byte $ff,$ff,$ff,$ff,$f0,$80,$c0,$80
			.byte $ff,$80,$c0,$80,$f0,$80,$c0,$80
			.byte $ff,$ff,$c0,$80,$f0,$80,$c0,$80
			.byte $ff,$80,$c0,$80,$f0,$80,$c0,$80
			
			
 						// the below section is copied to $D000         self-modifying code ??
l1fb6:    sei
          lda #$eb		// sideways T
          sta $180c		// destinati"O"n disk			////////////////////          No idea what's going on here
          ldy #$00
          sty $1803		// "D"estination disk
          
          ldx #$06		// 6 pages ?
l1fc3:     lda #$10		// 0001 0000
l1fc5:     bit $180d		// Destinatio"N" Disk
          beq l1fc5
          sta $180d		// Destinatio"N" Disk
          lda $1801		// space $20
          sta $0200,y		// fill $0200 to $07ff with spaces
          iny
          bne l1fc3
          inc $01f6		// this is in the stack
          dex
          bne l1fc3
          
          lda #$24		// "$", BIT zero page
          sta $22
          iny
          sty $1a04		// at $1a04 $37 0011 0111 gets loaded into A and stored in $01	///// guesswork here /////
          stx $1a05		// $1a05 is STA
          stx $1a03		// $1a03 is LDA
          stx $1c03		// $1c03 is the "$05" of sta $05
          lda #$ec		//lower right square, CPX
          sta $1c0c		// changing a BNE offset ??
          lda #$23		//"#", RLA (oper,X)
          sta $1a0b		// changing a BNE offset ??
          lda #$a0		//
          sta $1a00
          lda #$88
          sta $1a02
          lda #$0e
          sta $1a0c
          lda #$7f
          sta $1a0d
          lda #$00
          sta $1800
          txa
l2011:     sta $84,x
          inx
          cpx #$45
          bne l2011
          txs
          jsr $057a
          tax
          stx $8a
          lda $0719,x
          sta $0251
          lda $0718,x
          sta $0250
          jsr $024f
          jmp $023d
          jsr $057a
          pha
          sec
          sbc $22
          beq l205e
          bcs l2040
          eor #$ff
          adc #$01
l2040:     tay
l2041:     ldx $1c00
          bcc $2048
          inx
          .byte $24		// BIT
l2048:    dex			// this is a masked DEX command
          txa
          and #$03
l204c:     sta $85
          lda $1c00
          and #$fc		// 1111 1100
          ora $85
          sta $1c00
          jsr $0640
          dey
          bne l2041
l205e:     pla
          sta $22
          rts
          
          jsr $05a9
          sta $1a09
          jmp $04c9
          jsr $05a9
          clv
l206f:     bvc l206f
          clv
          ldx $1a01
          sta $1a09
          jmp $02ee
          
l207b:     dec $87
          bmi l20c1
          jmp $02b8
          
          lda #$60
          .byte $2c		// BIT
          lda #$2c		// masked lda #$2c
          .byte $2c		// BIT
          lda #$2f		// masked lda #$2f
          .byte $2c		// BIT
          lda #$02		// masked lda #$02
          sta $02e6
          lda #$0a
          sta $87
          jsr $05a9
          sta $1a09
          bne l20a1
l209c:     bit $1a0d
          bne l207b
l20a1:     ldx $1c00
          bmi l209c
          ldy #$00
l20a8:     bit $1a0d
          bne l207b
          ldx $1c00
          bpl l20a8
          ldx $1a01
          clv
l20b6:     ldx status,y
l20b8:     bvc l20b8
          clv
          cpx $1a01
          bne l209c
          dey
l20c1:     bmi l20c5
          bpl l20b6
l20c5:     sta $1a09
          ldy #$00
l20ca:     bvc l20ca
          clv
          ldx $1a01
          stx $1801
          lda $1a0d
          and #$20
          beq l20ca
          lda #$10
l20dc:     ldx #$40
          sta $180d
l20e1:     bit $180d
          bne l20dc
          dex
          bne l20e1
          sty $1801
          jmp $059d
          jmp $0412
          lda $88
          jsr $0258
          lda $1c00
          and #$9f
          ora $89
          sta $1c00
          lda $1a01
          clv
          lda #$20
          jmp m51ctr
          jsr $05a9
          sty $1a00
          jsr $0511
          lda $1c00
          sta $85
          and #$9f
          ora #$20
          sta $1c00
          ldx $1a01
          clv
l2123:     bvc l2123
          clv
          lda #$63
          sta $1c02
          lda #$20
          clv
l212e:     bvc l212e
          clv
          sta $1a09
          ldx #$02
l2136:     dex
          bne l2136
          ldx $00
          bvs l2147
          bvs l2147
          bvs l2147
          bvs l2147
          bvs l2147
          bvs l2147
l2147:     clv
          ldy $1a01
          lda #$20
          pha
          pla
          pha
          pla
          bvs l2159
          bvs l2176
          bvs l21a2
          bne l21bf
l2159:     bit $1a0d
          bne l21dc
          ldy $1a01
          ldx $7c00,y
          stx $1c00
          stx $1801
          bvs l2159
          bvs l2159
          bvs l2176
          bvs l21a2
          bvs l21bf
          bne l2191
l2176:     bit $1a0d
          bne l21dc
          ldy $1a01
          ldx $7d00,y
          stx $1c00
          stx $1801
          bvs l2159
          bvs l2176
          bvs l2176
          bvs l21a2
          bvs l21bf
l2191:     pha
          txa
          and #$63
          ora #$90
          sta $1801
          pla
          clv
l219c:     bvc l219c
          clv
          jmp $0358
l21a2:     bit $1a0d
          bne l21dc
          ldy $1a01
          ldx $7e00,y
          stx $1c00
          stx $1801
          bvs l2159
          bvs l2176
          bvs l21a2
          bvs l21a2
          bvs l21bf
          bne l2191
l21bf:     bit $1a0d
          bne l21dc
          ldy $1a01
          ldx $7f00,y
          stx $1c00
          stx $1801
          bvs l2159
          bvs l2176
          bvs l21a2
          bvs l21bf
          bvs l21bf
          bne l2191
l21dc:     lda $85
          sta $1c00
          lda #$6f
          sta $1c02
          lda #$80
          sta $1a00
          jmp $0588
          inc $1803
          lda $88
          jsr $0258
          lda $1c00
          and #$9f
          ora $89
          sta $1c00
          lda #$02
          sta $84
          ldy $8e
          lda $1c00
          ldx #$88
          stx $1a00
          ldx #$ce
          stx $1c0c
          ldx $1801
          stx $1c03
          stx $1c01
          clv
          ldx $8b
          jmp $045a
l2222:     dec $8f
l2224:     dex
          bne $222e
          ldx $8b
          beq l2233
          and #$fb
          bit $0409
          sta $1c00
l2233:     bvc l2233
          clv
          dey
          bne l2224
          cpy $8f
          bne l2222
          ora #$04
          sta $1c00
l2242:     bvc l2242
          clv
          lda $8c
          sty $8c
          tay
          lsr
          bcs l225c
l224d:     bvc l224d
          ldx $1801
          clv
          stx $1c01
          lda ($8c),y
          sta $1c00
          iny
l225c:     bvc l225c
          ldx $1801
          clv
          stx $1c01
          lda ($8c),y
          sta $1c00
          iny
          bne l224d
          inc $8d
          bpl l224d
          ldx #$ec
          and #$60
          cmp #$60
          beq l2285
          cmp #$40
          beq l2285
          cmp #$20
          beq l2285
          cmp #$00
          beq l2285
l2285:     asl $86
          lda #$80
          stx $1c0c
          sty $1c03
          ldx #$10
          stx $180d
          sta $1a00
          bcs l229a
          rts
          
l229a:     lda #$20
          dec $1803
          sty $1a08
          sta $1a09
l22a5:     bit $1a0d
          bne l22e5
          ldx $1c00
          bmi l22a5
l22af:     bit $1a0d
          bne l22e9
          ldx $1c00
          bpl l22af
l22b9:     ldx $1a01
          clv
          sta $1a09
l22c0:     bvc l22c0
          clv
          ldx $1a01
          stx $1801
          lda $1a0d
          and #$20
          beq l22c0
          lda #$10
l22d2:     ldx #$40
          sta $180d
l22d7:     bit $180d
          bne l22d2
          dex
          bne l22d7
          sty $1801
          jmp $059d
l22e5:     ldy #$41
          bne l22b9
l22e9:     ldy #$82
          bne l22b9
          lda $1c00
          and #$03
          sta $00
          ldy #$00
l22f6:     tya
          lsr
          tax
          lda $068f,x
          lsr
          lsr
          lsr
          lsr
          tax
          lda $070f,x
          ora $00
          sta $7c00,y
          eor #$20
          sta $7d00,y
          eor #$60
          sta $7e00,y
          eor #$20
          sta $7f00,y
          tya
          iny
          lsr
          tax
          lda $068f,x
          and #$0f
          tax
          lda $070f,x
          ora $00
          sta $7c00,y
          eor #$20
          sta $7d00,y
          eor #$60
          sta $7e00,y
          eor #$20
          sta $7f00,y
          iny
          bne l22f6
          rts
          
          jsr $057a
          sta $85
          jsr $057a
          and $1c00
          ora $85
          sta $1c00
          jsr $0640
          dec $1803
          jmp $0598
          lda #$10
l2358:     bit $180d
          beq l2358
          sta $180d
          lda $1801
          rts
          
l2364:    jsr $05a8
          nop
          lda #$10
l236a:     bit $180d
          beq l236a
          sta $180d
          lda #$00
          sta $1801
          lda #$10
l2379:     bit $180d
          beq l2379
          sta $180d
          inc $1803
          rts
          
l2385:    ldy #$ff
          sty $1803
          iny
          sty $1a08
          lda #$20
          rts
          
          ldx #$00
l2393:     jsr $057a
          beq l239d
          sta status,x
          inx
          bne l2393
l239d:     dex
          stx $02cb
          rts
          
          jsr $057a
          sta $88
          jsr $057a
          sta $89
          jsr $057a
          beq l241b
          tax
          dex
          stx $8b
          ldx $1c00
          sec
          lda $88
          sbc $22
          beq l23c4
          tay
l23c0:     inx
          dey
          bne l23c0
l23c4:     txa
          and #$03
          ora $89
          ldx #$60
          stx $8d
          ldy #$00
          sty $8c
l23d1:     sta ($8c),y
          iny
          bne l23d1
          inc $8d
          bpl l23d1
          stx $8d
          ldx $8b
          beq l23f5
          eor #$04
l23e2:     dex
          bne l23e9
          sta ($8c),y
          ldx $8b
l23e9:     iny
          bne l23e2
          inc $8d
          bpl l23e2
          ora #$04
          sta $7fff
l23f5:     jsr $057a
          sta $8c
          jsr $057a
          sta $8d
          sec
          lda #$ff
          sbc $8c
          sta $8c
          lda #$7f
          sbc $8d
          sta $8d
          jsr $057a
          sta $8e
          jsr $057a
          sta $8f
          jsr $057a
          sta $86
l241b:     rts

          lda #$94
          sta $1805
l2421:     bit $1805
          bmi l2421
          rts
          
          lda $1c00
          ora #$04
          sta $1c00
          lda #$23
          jsr $0258
          lda #$ee
          sta $1c0c
          jmp $eaa0
          jsr $057a
          ldx #$21
          ldy #$88
          sty $1a00
          ldy #$ce
          sty $1c0c
          ldy #$ff
          sty $1c03
          clv
l2451:     bvc l2451
          clv
          sta $1c01
          dey
          bne l2451
          dex
          bne l2451
          ldx #$ec
          stx $1c0c
          sty $1c03
          ldx #$80
          stx $1a00
          rts
          
l246b:    .byte $01,$22,$23,$33,$23,$44,$34,$44,$23,$44,$45,$55,$34,$55,$45,$55
          .byte $23,$44,$45,$55,$45,$66,$56,$66,$34,$55,$56,$66,$45,$66,$56,$66
		 .byte $23,$44,$45,$55,$45,$55,$45,$55,$45,$66,$67,$77,$56,$77,$67,$77
		 .byte $34,$55,$56,$66,$56,$77,$67,$77,$45,$66,$67,$77,$56,$77,$67,$77
		 .byte $12,$33,$34,$44,$34,$55,$45,$55,$34,$55,$56,$66,$45,$66,$56,$66 
		 .byte $34,$55,$56,$66,$56,$77,$67,$77,$45,$66,$67,$77,$56,$77,$67,$77
		 .byte $23,$44,$45,$55,$45,$66,$56,$66,$45,$66,$67,$77,$56,$77,$67,$77
		 .byte $34,$55,$56,$66,$56,$77,$67,$77,$45,$66,$67,$77,$56,$77,$67,$78
		 .byte $e0,$64,$68,$6c,$70,$74,$78,$7c,$fc,$55,$02,$61,$05,$4b,$06,$86
		 .byte $02,$8f,$02,$2e,$03,$b5,$05,$c6,$05,$af,$02,$ac,$02,$a9,$02,$24






