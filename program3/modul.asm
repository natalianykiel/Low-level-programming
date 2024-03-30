.MODEL		SMALL, C


.CODE
PUBLIC		sredniatablicy
PUBLIC		liczbaznakow

sredniatablicy		PROC
			push 		bp 					;zachowanie starej wartosci bp
			mov 		bp, sp				;ustawienie wartosci rejestru bp na aktualny wierzchołek stosu
			sub			sp, 2				;zarezerwowanie na stosie 2 bajtow na zmienna lokalna, czyli nasz iterator
			mov 		dx, [bp-2]  		;przesuwa do dx offset naszej zmiennej
			
			
			mov			bx,  [bp+4] 		;przesuwa do bx offset pierwszej liczby z tablicy
			fld			qword ptr [bx] 		;odkłada na górę stosu zmiennoprzecinkowego liczbę z tablicy
			add 		bx, 8				;przesunięcie bx na offset kolejnej liczby z tablicy(double ma 8 bajtow)
			mov			word ptr dx, 1  	;ustawienie zmiennej na 1
			
petla1:
			cmp			dx, [bp+6] 			;sprawdzenie czy nasza zmienna jest już równa ilości liczb w tablicy
			je			koniec1				;jeśli tak to skok do koniec
			
			fadd		qword ptr [bx]		;dodanie do liczby na górze stosu koprocesora liczby, na którą wskazuje bx
			add			bx, 8				; przesunięcie bx na kolejną liczbę
			inc			word ptr dx			;inkrementacja naszej zmiennej
			jmp 		petla1				;skok na początek pętli
			
			
koniec1:			
			fidiv		word ptr [bp+6] 	;podzielenie sumy liczb znajdującej się na górze stosu koprocesora przez ich ilość
			mov 		sp, bp 				;zdjęcie ze stosu zmiennych lokalnych
			pop			bp    				;odtworzenie starej wartości bp	
			ret								;powrot z funkcji
			
sredniatablicy ENDP

liczbaznakow		PROC
			push		bp 					;zachowanie starej wartosci bp
			mov			bp, sp 				;ustawienie wartosci rejestru bp na aktualny wierzchołek stosu
			sub			sp, 2 				;zarezerwowanie na stosie 2 bajtow na zmienna lokalna, czyli nasz iterator
			mov 		dx, [bp-2] 			;przesuwa do dx offset naszej zmiennej
			mov			word ptr dx, 0 		;ustawienie zmiennej na 0
			
			mov			al, [bp+6] 			;przesunięcie do al poszukiwanego znaku
			mov			bx, [bp+4] 			;przesunięcie do bx adresu tablicy
			
			
			
petla2:
			mov 		ah, [bx] 			;wczytanie do ah pierwszego znaku z tablicy
			cmp			ah, 00h 			;sprawdzenie czy znak ten jest znakiem końca linii
			je			koniec2 			;jeśli tak to skok do koniec 2
			
			cmp    		ah, al 				;sprawdzenie czy znak z tablicy jest poszukiwanym znakiem
			jne 		nrw  				;jesli nie to skok do nrw
			inc			word ptr dx 		;inkrementacja naszej zmiennej(zwiększenie powtórzeń naszego poszukiwanego znaku w łańcuchu)
nrw:
			inc 		bx					;inkrementacja bx(przesunięcie na ofset kolejnejgo znaku w tablicy, bo char ma 1 bajt)
			jmp 		petla2 				;skok na początek pętli
			
koniec2:
			mov			ax, dx 				;wczytanie do ax naszej zmiennej
			mov			sp, bp 				; zdjęcie ze stosu zmiennych lokalnych
			pop			bp 					;odtworzenie starej wartości bp
			ret 							;powrot z funkcji
liczbaznakow 	ENDP
			
.STACK
DB 100h DUP (?)
END			