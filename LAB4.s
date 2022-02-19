;Archivo: Prelab4.s
;Dispositivo: PIC16F887
;Autor: Jimena de la Rosa
;Compilador: pic-as (v2.30). MPLABX v5.40
;Programa: laboratorio 1
;Hardware: LEDs en el puerto A
;Creado: 13 FEB, 2022
;Ultima modificacion: 14 FEB, 2022
    
PROCESSOR 16F887

; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>

;-------- Declracion de variables------
 UP EQU 6; NOMBRAR EL BIT 6 COMO UP PARA INCREMENTAR
 DOWN EQU 7; NOMBRAR EL BIT 7 COMO DOWN PARA DECREMENTAR
PSECT UDATA_BANK0,global,class=RAM,space=1,delta=1,noexec
  
  GLOBAL  CONT, CONTU, CONTD, CONT1
    CONT: DS 2 ;SE NOMBRA UNA VARIABLE DE CONTADOR DE 4 BITS
    CONTU: DS 2; SE NOMBRA UNA VARIBLE PARA EL CONTADOR DE UNIDADES
    CONTD: DS 2; SE NOMBRA UNA VARIBLE PARA EL CONTADOR DE DECENAS
    CONT1: DS 2
; ------- VARIABLES EN MEMORIA --------
PSECT udata_shr		    ; Memoria compartida
    W_TEMP:		DS 1
    STATUS_TEMP:	DS 1

PSECT resVect, class=CODE, abs, delta=2
ORG 00h			    ; posición 0000h para el reset
;------------ VECTOR RESET --------------
resetVec:
    PAGESEL MAIN	    ; Cambio de pagina
    GOTO    MAIN
    
PSECT intVect, class=CODE, abs, delta=2
ORG 04h			    ; posición 0004h para interrupciones
;------- VECTOR INTERRUPCIONES ----------
PUSH:
    MOVWF   W_TEMP	    ; Guardamos W
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP	    ; Guardamos STATUS
    
ISR:
    BTFSC   T0IF; SE REVISA SI ESTA ENCENDIDO
    CALL    INT_TMR0	    ; SE EJECUTA LA INSTRUCCI[ON DE LA INTERRUPCION DEL TMR0
    BTFSC   RBIF	    ; Fue interrupción del PORTB? No=0 Si=1
    CALL    INT_IOCB	    ; Si -> Subrutina o macro con codigo a ejecutar
    
    
POP:
    SWAPF   STATUS_TEMP, W  
    MOVWF   STATUS	    ; Recuperamos el valor de reg STATUS
    SWAPF   W_TEMP, F	    
    SWAPF   W_TEMP, W	    ; Recuperamos valor de W
    RETFIE		    ; Regresamos a ciclo principal
    
    
PSECT code, delta=2, abs
ORG 100h		    ; posición 100h para el codigo
;------------- CONFIGURACION ------------
MAIN:
    CALL    CONFIG_IO	    ; Configuración de I/O
    CALL    CONFIG_RELOJ    ; Configuración de Oscilador
    CALL    CONFIG_TMR0	    ; Configuración de TMR0
    CALL    CONFIG_INT	    ; Configuración de interrupciones
    CALL    CONFIG_IOCRB
    BANKSEL PORTB	    ; Cambio a banco 00
 
LOOP:
    goto    LOOP
    
;------------- SUBRUTINAS ---------------
INT_TMR0:
    CALL REINICIO_TMR0; SI ESTA ENCENDIDO, SE REINICIA EL TMR0
    DECFSZ CONT, 1  ;DECRECER 1 EN CONT
    return
 
CONTADOR1:
    MOVLW  50	    ; ESCRIBIR 50 EN W
    MOVWF  CONT     ;PASAR EL 50 A CONT
    INCF  PORTA	    ;sE INCREMENTA 1 EN LA SALIDA DEL PORT A
    MOVF  CONTU, W ; DE MUEVE EL VALOR DEL CONTADOR A W
    CALL TABLA
    MOVWF PORTD
    INCF CONTU
    MOVF CONTU, W; se mueve el valor del contador a W
    SUBLW 11; se resta el valor del PortD a W
    BANKSEL STATUS
    BTFSS STATUS, 2; se revisa si la resta es igual a cero
    RETURN; si tiene se regresa
    MOVLW   0; SE DEJA EL CONTADOR DE UNIDADES EN CERO
    MOVWF   CONTU
    MOVLW   01000000B ;SE DEJA EL PORTD CON EL VALOR CERO EN EL 7 SEG
    MOVWF   PORTD 
    MOVF  CONTD, W ;SE MUEVE EL VALOR DEL CONTADOR A W
    CALL TABLA	    
    MOVWF PORTC
    INCF CONTD
    MOVF CONTD, W; se mueve el valor del contador a W
    SUBLW 7; se resta el valor del PortD a W
    BANKSEL STATUS
    BTFSS STATUS, 2; se revisa si la resta es igual a cero
    RETURN; si tiene se regresa
    MOVLW   0
    MOVWF   CONTD
    MOVLW   01000000B
    MOVWF   PORTC
    RETURN
    
    
INT_IOCB:
    BANKSEL PORTB ; SE SELECCIONA EL BANCO 0
    BTFSS PORTB, UP ; SE REVISA SI EL BIT ESTA ENCENDIDO
    INCF PORTB	    ;SI NO ESTA ENCENDIDO, SE INCREMNATA EL PORTB
    BTFSS PORTB, DOWN; SE REVISA SI EL BIT ESTA ENCENDIDO
    DECF PORTB ; SI NO ESTA ENCENDIDO SE DECREMENTA
    BCF RBIF
    
    RETURN
    
CONFIG_IOCRB:
    BANKSEL TRISB
    BSF IOCB, UP    ; SE CONFIGURAN LOS PULL UPS DE LAS ENTRADAS
    BSF IOCB, DOWN
    
    BANKSEL PORTB
    MOVF    PORTB, W 
    BCF	    RBIF    ; SE LIMPIA LA BANDERA DEL CAMBIO EN EL PORT B
    RETURN
 
 CONFIG_IO:
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH	    ; I/O digitales
    BANKSEL TRISB
    MOVLW   0xF0     ; usar 11110000 para dejar solo 4 bits de salida
    MOVWF   TRISB    ; usar esa configuracion en la salida B
    MOVWF   TRISA
    CLRF    TRISC   ; SE DEJAN EL PORT C Y B COMO SALIDAS
    CLRF    TRISD
    BSF	    TRISB, UP ; UP Y DOWN COMO ENTRADAS
    BSF	    TRISB, DOWN 
    BCF	    OPTION_REG, 7; SE HABILITAN LOS PULL_UPS
    BSF	    WPUB, UP	
    BSF	    WPUB, DOWN
    BANKSEL PORTB
    CLRF    PORTB	    ; Apagamos PORTB
    CLRF    PORTA	    ; Apagamos PORTA
    MOVLW   01000000B	    ; COMENZAR CON EL VALOR DE CERO EN LOS 7SEGMENTOS
    MOVWF   PORTC
    MOVWF   PORTD
    MOVLW  50	    ; ESCRIBIR 50 EN W
    MOVWF  CONT     ;PASAR EL 50 A CONT
    MOVLW  1	    ; EL VALOR INICIAL DE LOS CONTADORES DE DECENA Y UNIDADES ES 1
    MOVWF  CONTU
    MOVWF  CONTD
    RETURN
    
CONFIG_INT:
    BANKSEL INTCON
    BSF	    GIE		    ; Habilitamos interrupciones
    BSF	    T0IE	    ; Habilitamos interrupcion TMR0
    BCF	    T0IF	    ; Limpiamos bandera de TMR0
    bsf	    RBIE
    bcf	    RBIF
    movf    PORTB, F
    RETURN

CONFIG_RELOJ:
    BANKSEL OSCCON
    BSF OSCCON, 0; RELOJ INTERNO
    BCF OSCCON, 4; OSCILADOR DE 4MH
    BSF OSCCON, 5
    BSF OSCCON, 6
    RETURN
    
CONFIG_TMR0:
   BANKSEL OPTION_REG
    BCF PSA
    BCF PS0; PRESCALER DE 1:128
    BSF PS1
    BSF PS2 
    BCF T0CS ; RELOJ INTERNO
    MOVLW 100 ; 20MS
    
    BANKSEL TMR0
    MOVWF TMR0 ; CARGAMOS EL VALOR INICIAL
    BCF   T0IF; LIMPIAMOS LA BANDERA
    RETURN
    
    
REINICIO_TMR0:
    BANKSEL TMR0
    MOVLW   100		; 20 ms 
    MOVWF   TMR0	; Cargamos valor inicial
    BCF	    T0IF	; Limpiamos bandera
    RETURN

ORG 200H
TABLA:
    CLRF PCLATH
    BSF  PCLATH, 1
    ANDLW 0X0F; SE ASEGURA QUE SOLO EXISTAN 4 BITS
    ADDWF PCL
    RETLW 01000000B;0
    RETLW 01111001B;1
    RETLW 00100100B;2
    RETLW 00110000B;3
    RETLW 00011001B;4
    RETLW 00010010B;5
    RETLW 00000010B;6
    RETLW 01111000B;7
    RETLW 00000000B;8
    RETLW 00010000B;9
    RETLW 00001000B;A

END


