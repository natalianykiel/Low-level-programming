#include <dos.h>
#include <iostream.h>
#include <stdio.h>
#include <conio. h>



	typedef unsigned char BYTE;
	typedef unsigned int WORD;
	typedef unsigned int UINT;
	typedef unsigned long DWORD;
	typedef unsigned long LONG; 
 
	struct BITMAPFILEHEADER
	{
		UINT bfType; //Opis formatu pliku. Musi być ‘BM’.
		DWORD bfSize; //Rozmiar pliku BMP w bajtach.
		UINT bfReserved1; //Zarezerwowane. Musi być równe 0.
		UINT bfReserved2; //Zarezerwowane. Musi być równe 0.
		DWORD bfOffBits; //Przesunięcie w bajtach początku danych
	}; 
	
	struct BITMAPINFOHEADER
	 {
		 DWORD biSize; //Rozmiar struktury BITMAPINFOHEADER.
		 LONG biWidth; //Szerokość bitmapy w pikselach.
		 LONG biHeight; //Wysokość bitmapy w pikselach.
		 WORD biPlanes; //Ilość płaszczyzn. Musi być 1.
		 WORD biBitCount; //Głębia kolorów w bitach na piksel.
		 DWORD biCompression; //Rodzaj kompresji (0 – brak).
		 DWORD biSizeImage; //Rozmiar obrazu w bajtach. Uwaga może być 0.
		 LONG biXPelsPerMeter;//Rozdzielczość pozioma w pikselach na metr.
		 LONG biYPelsPerMeter;//Rozdzielczość pionowa w pikselach na metr.
		 DWORD biClrUsed; //Ilość używanych kolorów z palety.
		 DWORD biClrImportant; //Ilość kolorów z palety niezbędnych do
	 }; //wyświetlenia obrazu. 


	FILE *pliczek_banknocikow; //Plik bitmapy
	BITMAPFILEHEADER bmfh; //nagłówek nr 1 bitmapy
	BITMAPINFOHEADER bmih; //nagłówek nr 2 bitmapy
	unsigned char far* video_memory = (BYTE *)0xA0000000L;			//Ogolnie to musi byc far, far away, ale kto by sie tym przejmowal...
	
void tryb_graficzny_on();
void tryb_tekstowy_on();
void show_obraz(char tab[]);
void ponieranie_opcji(char tab[]);
void negatyw(char tab[]);
void zmiana_jasnosci(char tab[]);


	

int main(){
	int nr= 5, j = 0 ;
		while(nr !=0 && j < 6){
			clrscr();
            tryb_tekstowy_on();
			cout
				<<"---MENU GLOWNE--- \n"
				<<"[0] Exit \n"
				<<"[1] Lena \n"
				<<"[2] Boat \n"
				<<"[3] Bridge \n"
				<<"[4] Aero \n"
				<<"Wybierz opcje: ";
			cin >> nr;
			switch(nr){
				case 1:{
					ponieranie_opcji ("lena.bmp");	
					break;
				}
				case 2:{
					ponieranie_opcji("boat.bmp");
					break;
				}
				case 3:{
					ponieranie_opcji("bridge.bmp");
					break;
				}
				case 4:{
					ponieranie_opcji("aero.bmp");
					break;
				}
				case 0:
					break;
				default:{
					cout << "Brak takiej opcji\n";
				}	
			}				
			j++;	
		}
return 0;
}

	void tryb_tekstowy_on(){
		REGPACK regs;
		regs.r_ax = 0x10;
		intr(0x10, &regs);
	}
	
	void tryb_graficzny_on(){
		REGPACK regs;					
		regs.r_ax = 0x13;
		intr(0x10, &regs);
	}
	
	void ponieranie_opcji(char sztaluga[]){
		int wybor;
		while(wybor !=0){
		
				clrscr();
				tryb_tekstowy_on();
				cout
					<< "WITAJ W PROGRAMIE GRAFICZNYM \n"
					<< "[0] Exit\n"
					<< "[1] Show picture\n"
					<< "[2] Negatyw\n"
					<< "[3] Zmien jasnosc obrazu\n"
					<< "Wybierz opcje: ";
				cin >> wybor;
				switch(wybor){
				case 1:{
					clrscr();
					show_obraz(sztaluga);
					getch();		
					break;
				}
				case 2:{
					clrscr();
					negatyw(sztaluga);
					getch();
					break;
				}
				case 3:{
					clrscr();
					zmiana_jasnosci(sztaluga);
					getch();
					break;
				}
				case 0:{
					break;
				
					
				}	
			
			
               	
	}
	}
	}
	
	void show_obraz(char sztaluga[]){
	tryb_graficzny_on();
	outportb(0x03C8, 0); 				//rozpocznij ustawianie palety od koloru nr 0
		for (int i = 0; i < 256; i++) 		//ilość kolorów w palecie 8-bitowej
		{
			 outp(0x03C9, i * 63 / 255); 	//skalowana składowa R
			 outp(0x03C9, i * 63 / 255); 	//skalowana składowa G
			 outp(0x03C9, i * 63 / 255); 	//skalowana składowa B
		}
		pliczek_banknocikow = fopen(sztaluga, "rb");
		
		fread(&bmfh, sizeof(BITMAPFILEHEADER), 1, pliczek_banknocikow);
		fread(&bmih, sizeof(BITMAPINFOHEADER), 1, pliczek_banknocikow); 
		
		fseek(pliczek_banknocikow,bmfh.bfOffBits,SEEK_SET);  				//Tego to w sumie nie dali w instrukcji, ale to ustawienie kursora na poczatek
		
		for(int k=199; k>=0; k--){											//Wczytywanie jest "od dolu", stad dekrementacja 
			for(int j=0; j<320; j++){
				 video_memory[320*k + j] = fgetc(pliczek_banknocikow); 		//Ogolnie to dzialamy na calym obrazku jako na jednowymiarowej tablicy...
			}																//Kazda linijka jest wczytywana co 320 znak
		}																	//Stad to kazdego pojedynczego piksela zaczytujemy piksel obrazka
			
		fclose(pliczek_banknocikow);
	}
	void negatyw (char sztaluga[]){
		show_obraz(sztaluga);							//Najpierw ladujemy obraz, pozniej wykonujemy na nim operacje
		for(long int i=0; i<64000; i++)
			video_memory[i] = ~video_memory[i];			//Negacja, czyli negatyw 
	}
	void zmiana_jasnosci (char sztaluga[]){
		int jasnosc;
		cout << "Jak bardzo chcesz blyszczec?: "; 		//Mozna dac tez ujemne; wtedy przyciemniamy obraz ;d 
		cin >> jasnosc;
		show_obraz(sztaluga);
		for(long int i=0; i<64000; i++){
			if(video_memory[i] + jasnosc > 255 )			//"Bielsze nie bedzie!" Po przekroczeniu zakresu wystepuje "zalamanie", a tego nie lubimy...
				video_memory[i] = 255;
			else if(video_memory[i] + jasnosc < 1 )		//Czarne tez nie bedzie...
				video_memory[i] = 1;
			else 
				video_memory[i] += jasnosc;				//Jezeli nie grozi nam zalamanie... to po co nam leki?
		}
	}

