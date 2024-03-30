#include <iostream.h>

extern "C" double sredniatablicy(double tab[], int ilosc);
extern "C" int liczbaznakow(char tab[], char znak);

int main()
{
    int wybor;
    cout << "Wybierz funkcje:\n1)srednia arytmetyczna liczb w tablicy\n2)liczba wystapien znaku\n";
    cin >> wybor;

    if (wybor == 1)
    {
        int ilosc;

        cout << "Wprowadz ilosc liczb: ";
        cin >> ilosc;

        double *tab1=new double[ilosc];

        for (int i=0; i<ilosc; i++)
        {
            cout << "Znak numer " << i+1 <<": ";
            cin >> tab1[i];
        }

        double srednia=sredniatablicy(tab1, ilosc);

	cout << "\nSrednia tablicy to: " << srednia;

	delete []tab1;
    }
    else if (wybor == 2)
    {
	char tab2[40];
		char znak;

        cout << "Podaj lancuch tekstowy (40 znakow maks): ";
		cin.sync();
		cin.getline(tab2,40);

        cout << "Wprowadz poszukiwany znak: ";
        cin >> znak;

        int wystapienia=liczbaznakow(tab2, znak);

		cout << "\nPoszukiwany znak wystapil " << wystapienia << " razy.";
    }
    else
        cout << "\nNie ma tej metody :C\n\n";

    return 0;
}
