.386p   
.model tiny 

Kod     	SEGMENT USE16             ;żeby korzytsał z 16-bitowych rejestrów
            org 100h
			ASSUME  CS:Kod, DS:Kod, SS:Kod
			
start:
    jmp Poczatek
	znak 	db	0
	mesg 	db 	"Podaj dwie liczby z nastepujacego przedzialu [-32768...32767]: $"
	blad_kom1	DB	13, 10, "Nie poprawne wprowadzenie liczby. Wprowadzono: '-liczba-' $"	
	blad_kom1_1 DB  13, 10, "Wprowadz liczby ponownie: $"
	blad_kom2	DB	13, 10, "Nie poprawne wprowadzenie liczby. Wprowadzono: '--liczba' $"
	blad_kom2_2 DB  13, 10, "Wprowadz liczby ponownie: $"
	blad_kom3   DB  13, 10, "Wprowadzono nie dozwolony znak. Wprowadz liczby ponownie: $"
	blad_kom4	DB	13, 10, "Liczba wyszla poza zakres. Wprowadz liczbe ponownie: $"
	
Poczatek:

;pierwszay komunikat do użytkownika
        mov dx, OFFSET mesg
        mov ah, 09h
        int 21h

;zaczynamy petelke		
		mov 	cx, 2

Pobieranie_1:
         mov byte ptr [znak], 0
		 xor ax, ax
		 push ax 
		 
		 
Pobieranie_2:
        
;funkcja pobierajaca znaki-zapisuje w al
		mov 	ax, 0100h		
		int 	21h	
		 
;przetwarzanie pobranego znaku na grupy:

;został wybrany enter-to skok
		cmp 	al, 0Dh		
		je 		Enter_

;sprawdzamy czy wprowadzono '-' czy liczbe 
		cmp		al, '-'	     		
		jne		Liczba                           ; jesli to nie '-' to pewnie to liczba i moze nie ujemna

;jeśli brak skoku to wiemy, że wprowadzono '-'

;prewenjca przed '-1-' zapisem:
		pop		ax		
		cmp		ax, 0			                 ;teraz spr flage ze stosu, jesli ax=0(dla odatniej)to dostaniemy flage 1, czyli brak skok
		push	ax				
		jne		Blad_wpisania1			         ;jesli ax=!0 to mamy flage 0 czyli bedzie skok bo '-' jest juz na stosie a nie moze byc dwa razy
        
;prewencja przed '--1' zapisem:						
		mov		al,	[znak]	                     ;wrzucamy wart znaku do al
								
		cmp 	al, 1			                 ;i tera spr czy al=1(czyli czy znak jest -)
		je		Blad_wpisania2			                 ;bedzie skok jesli jest juz znak na '-' to znacyz ze drugi raz wprowadzamy

;jesli nie bylo blędu zapisu to leecim dalej z tym '-':

		mov 	byte ptr [znak], 1	;ustawiamy w znaku ze ta dam byl '-'
		jmp		Pobieranie_2	    ;i pobieramy następną wartość 
	 
        
		
;tu skoczymy, jeśli daliśmy liczbe, a nie '-'
;może być ona nie ujemna, ale nie mamy jeszcze pewności, więc czas to rozkminić

Liczba:
;sprawdzamy czy wprowadzony znak jest cyfrą:

;rozkmina czy jest znak liczby czy jakieś inny:
;tu sprawdzamy czy są mniejsze w kodzie ASCII
		cmp 	al, '0'			
		jb		Blad_wpisania3	
;tu sprawdzamy czy są większe w kodzie ASCII		
		cmp 	al, '9'	
		ja		Blad_wpisania3
;skoro znak jest cyfrą to jest konwertowany na wartosc liczbowa 
		sub		al, '0'			;'0'=48 i tak zawsze konwertujemy liczby z ASCII
		xor 	bx,	bx
		mov		bl, al		    ;wynik jest wrzucony do bl
			  
		pop		ax
		
		mov		dx,000Ah           
		mul		dx			
		jo		Blad_wpisania4    ;spr czy nie wychodzi poza okreslony zakres/flaga przepłnienia 
		
		add		ax, bx			
		
		mov		dl, [znak]		;sprawdzamy wartosc znaku
		cmp 	dl, 1		    ;jesli 1 to skoacze bo ujemna jesli 0 zostaje bo dodatnia
		je 		Liczba_ujemna
		cmp		ax, 07FFFh		;porównuje wartość w rejestrze AX z maksymalną wartością bez znaku dla 16-bitowej liczby całkowitej, czyli 65535
		ja		Blad_wpisania4
		
Liczba_ujemna:

		cmp		ax, 08000h		        ;czy liczna jest w zakresie
		ja		Blad_wpisania4			;jezeli wieksza, skocz do bledu

		push 	ax				        ;wpycha na stos wartosc z ax
		jmp		Pobieranie_2	        ;wraca zeby pobrac kolejny znak
;PO WPISANIU ENTERA, CZYLI MAMY WSZYTKO POBRANE I ROZDIELONE TERAZ KONWERSJA I WYPISANIE
Enter_:
;sprawdzamy czy liczba jest dodatnia
	    xor		bx, bx			
		mov		bl, [znak]	            
		cmp 	bx, 0
;jeżeli tak to skacze:		
		je 		Liczba_nie_ujemna	     
;jeżeli nie, wpisuje i neguje w kodzie U2
		pop		ax				          
		neg		ax				
		push	ax				
		
Liczba_nie_ujemna:

        loop 	Pobieranie_1	        ;wraca jezeli ma druga liczbe
		
		pop		ax				        ;wpisuje ze stosu 1 liczbe do ax
		pop		bx				        ;wpisuje ze stosu 2 liczbe do bx
		add		ax,	bx			        ;dodawanko je do siebie
		
		jo		Flaga_OF		        ;skocz jezeli flaga OF=1 (przepełnienie)
		js		FLAGA_SF		        ;skocz jezeli flaga SF=1	(znak)-skok jeśli ujemne bo wypisać minusa musimy
		jmp		koniec_obliczen			;jezeli obie flagi 0, idz do dalej
		
		
;przerywnik na zabawe z flagami:
Flaga_OF:
		js 		koniec_obliczen			         ;jezeli obie flagi 1 to lecimy do stosu
		
Flaga_SF:
		mov 	ebx, 0ffff0000h	         ;dopisz dopelnienie w U2
		
		add		bx,	ax			         ;dodaj do bx nasza liczbe z ax
		neg 	ebx				         ;zneguj wartosc w bx
		
		mov 	dl, '-'			         ;wpisuje do rejestru dl kod asci 
		mov		ah, 02h			         ;minusa, po czym wypisuje go na ekran
		int 	21h
		mov		eax,ebx			         ;przepisz wartosc liczby znowu do eax
		jmp		koniec_obliczen 


Konwertowanie:
	    cmp 	eax, 0000h		;porownuje czy liczba nie jest 0
		je		Output			;jezeli tak, to skacze


koniec_obliczen:

		mov		ebx, 10			;wpisuje do bx 10
		xor 	edx, edx
		div		ebx				;dzieli eax przez 10, reszta do edx
		add		dx, '0'			;dodaje do dx kod ascii "0"
		push	dx				;wpycha wartosc dx do rejestu
		inc		cx				;zwieksza cx, by program wiedzial
								;ile liczb ma wypisac
		jmp     Konwertowanie
				
		
Output:
		pop		dx				;wypycha zawartosc ze stosu do dx
		mov 	ax, 0200h		;wypisanie znaku z rejestru dx
		int 	21h				;wywowalnie funkcji 02 przerwania 21
		
		loop	Output			;wraca, jezeli ma wciaz znaki do wypisania
		
		mov 	ax, 4C00h		;konczy program, zwracajac sterowanie
		int 	21h				;do procesora

;blad wpisania liczby-'-1-'
Blad_wpisania1:
        pop		dx
		mov 	dx, OFFSET blad_kom1 	 
		mov 	ax, 0900h		      
		int 	21h	
		
        xor     dx, dx	
		
        pop		dx
		mov 	dx, OFFSET blad_kom1_1 	 
		mov 	ax, 0900h		      
		int 	21h	
        xor     dx, dx		
		jmp 	Pobieranie_2	
		
;blad wpisania liczby-'--1'
Blad_wpisania2:
        pop		dx
		mov 	dx, OFFSET blad_kom2 	 
		mov 	ax, 0900h		      
		int 	21h	
		
        xor     dx, dx	
		
        pop		dx
		mov 	dx, OFFSET blad_kom2_2	 
		mov 	ax, 0900h		      
		int 	21h	
        xor     dx, dx		
		jmp 	Pobieranie_2
		
;wprowadzono nie dozwolony znka
Blad_wpisania3:
        pop		dx
		mov 	dx, OFFSET blad_kom3 	 
		mov 	ax, 0900h		      
		int 	21h	
        jmp 	Pobieranie_2
		
Blad_wpisania4:
		mov 	dx, OFFSET blad_kom4 	 
		mov 	ax, 0900h		      
		int 	21h	
		jmp 	Pobieranie_2
    		
Stosik:
		db 100h dup (0)
		
Kod		ENDS

END		start		
