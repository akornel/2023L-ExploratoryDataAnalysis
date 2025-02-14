library(PogromcyDanych)
library(dplyr)
install.packages('stringi')
library('stringi')
data(auta2012)

# W kodzie wypisuj� czasami wi�cej wierszy niz (teoretycznie potrzeba), zeby sprawdzic, czy np. 
# nie ma tak naprawd� 2 tak samo popularnych modeli (z jakiejs kategorii)

# 1. Rozwa�aj�c tylko obserwacje z PLN jako walut� (nie zwa�aj�c na 
# brutto/netto): jaka jest mediana ceny samochod�w, kt�re maj� nap�d elektryczny?
auta2012 %>%
  filter(Waluta == 'PLN'& Rodzaj.paliwa == 'naped elektryczny') %>%
  summarise(mediana = median(Cena))



# Odp: Ta mediana wynosi 18900 zl.



# 2. W podziale samochod�w na marki oraz to, czy zosta�y wyprodukowane w 2001 
# roku i p�niej lub nie, podaj kombinacj�, dla kt�rej mediana liczby koni
# mechanicznych (KM) jest najwi�ksza.
auta2012 %>% 
  filter(Rok.produkcji >= 2001) %>% 
  group_by(Marka) %>% 
  summarise(mediana = median(KM)) %>% 
  arrange(desc(mediana)) %>% 
  head(3)
auta2012 %>% 
  filter(Rok.produkcji < 2001) %>% 
  group_by(Marka) %>% 
  summarise(mediana = median(KM)) %>% 
  arrange(desc(mediana)) %>% 
  head(3)

# Odp: Mediana  jest najwi�ksza (560 KM), gdy bierzemy pod uwag� samochody wyprodukowane przed 2001
#      roku przez firm� Bugatti.



# 3. Spo�r�d samochod�w w kolorze szary-metallic, kt�rych cena w PLN znajduje si�
# pomi�dzy jej �redni� a median� (nie zwa�aj�c na brutto/netto), wybierz te, 
# kt�rych kraj pochodzenia jest inny ni� kraj aktualnej rejestracji i poodaj ich liczb�.
auta2012 %>% 
  filter(Kolor == 'szary-metallic') %>% 
  summarise(mediana = median(Cena.w.PLN), srednia = mean(Cena.w.PLN))

srednia <- 44341.41
mediana <- 27480

auta2012 %>% 
  filter(Kolor == 'szary-metallic') %>%
  filter(Cena.w.PLN <= srednia , Cena.w.PLN >= mediana) %>% 
  filter(as.character(Kraj.aktualnej.rejestracji) != as.character(Kraj.pochodzenia)) %>% 
  count()



# Odp: 1331



# 4. Jaki jest rozst�p mi�dzykwartylowy przebiegu (w kilometrach) Passat�w
# w wersji B6 i z benzyn� jako rodzajem paliwa?
auta2012 %>% 
  filter(Rodzaj.paliwa == 'benzyna'& Model == 'Passat'& Wersja == "B6") %>% 
  filter(Przebieg.w.km != '') %>% 
  summarise(Rozstep = IQR(Przebieg.w.km))


# Odp: Rostep miedzykwartylowy wynosi 75977.5



# 5. Bior�c pod uwag� samochody, kt�rych cena jest podana w koronach czeskich,
# podaj �redni� z ich ceny brutto.
# Uwaga: Je�li cena jest podana netto, nale�y dokona� konwersji na brutto (podatek 2%).
auta2012 %>% 
  filter(Waluta == 'CZK') %>% 
  mutate(Cena_brutto = ifelse(Brutto.netto == 'brutto', Cena, Cena*1.02)) %>% 
  summarise(srednia_brutto = mean(Cena_brutto))


# Odp: �rednia cena brutto tych aut to 210678.3 CZK



# 6. Kt�rych Chevrolet�w z przebiegiem wi�kszym ni� 50 000 jest wi�cej: tych
# ze skrzyni� manualn� czy automatyczn�? Dodatkowo, podaj model, kt�ry najcz�ciej
# pojawia si� w obu przypadkach.
auta2012 %>% 
  filter(Marka == 'Chevrolet', Przebieg.w.km > 50000, Skrzynia.biegow == 'manualna') %>% 
  group_by(Model) %>% 
  summarise(n = n()) %>% 
  arrange(desc(n)) %>% 
  select(Model,n) %>% 
  head(10)

auta2012 %>% 
  filter(Marka == 'Chevrolet', Przebieg.w.km > 50000, Skrzynia.biegow == 'manualna') %>% 
  count()

auta2012 %>% 
  filter(Marka == 'Chevrolet', Przebieg.w.km > 50000, Skrzynia.biegow == 'automatyczna') %>% 
  group_by(Model) %>% 
  summarise(n = n()) %>% 
  arrange(desc(n)) %>% 
  select(Model,n) %>% 
  head(10)

auta2012 %>% 
  filter(Marka == 'Chevrolet', Przebieg.w.km > 50000, Skrzynia.biegow == 'automatyczna') %>% 
  count()

# Odp: Wi�cej jest tych Chevroletow z przebiegiem wi�kszym od 50000 km, kt�re maj� manualna skrzynie bieg�w.
#      Z tych kt�re mia�y manualn� skrzyni�, najcz�ciej wyst�pi� model Lacetti, a z automatycznych Corvette.



# 7. Jak zmieni�a si� mediana pojemno�ci skokowej samochod�w marki Mercedes-Benz,
# je�li we�miemy pod uwag� te, kt�re wyprodukowano przed lub w roku 2003 i po nim?
auta2012 %>% 
  filter(Marka == 'Mercedes-Benz', Rok.produkcji <= 2003) %>%
  filter(!is.na(Pojemnosc.skokowa)) %>% 
  summarise(mediana = median(Pojemnosc.skokowa))

auta2012 %>% 
  filter(Marka == 'Mercedes-Benz', Rok.produkcji > 2003) %>%
  filter(!is.na(Pojemnosc.skokowa)) %>% 
  summarise(mediana = median(Pojemnosc.skokowa))

# Odp: Nie zmieni�a si�.



# 8. Jaki jest najwi�kszy przebieg w samochodach aktualnie zarejestrowanych w
# Polsce i pochodz�cych z Niemiec?
auta2012 %>% 
  filter(Kraj.pochodzenia == 'Niemcy', Kraj.aktualnej.rejestracji == 'Polska') %>% 
  arrange(desc(Przebieg.w.km)) %>% 
  select(Przebieg.w.km) %>% 
  head(1)


# Odp: 1e+09 km, no nie�le 



# 9. Jaki jest drugi najmniej popularny kolor w samochodach marki Mitsubishi
# pochodz�cych z W�och?
auta2012 %>% 
  filter(Marka == 'Mitsubishi', Kraj.pochodzenia == 'Wlochy') %>% 
  group_by(Kolor) %>% 
  summarise(n = n()) %>% 
  arrange(n) %>% 
  select(Kolor,n) %>% 
  head(10)


# Odp: Okazuje si�, �e 4 ro�ne kolory zajmuj� 1 miejsce pod k�tem najmniejszej popularno�ci,
#      a na 2 miejscu jest 1 kolor. Ten kolor to granatowy-metallic.



# 10. Jaka jest warto�� kwantyla 0.25 oraz 0.75 pojemno�ci skokowej dla 
# samochod�w marki Volkswagen w zale�no�ci od tego, czy w ich wyposa�eniu 
# dodatkowym znajduj� si� elektryczne lusterka?
auta2012 %>% 
  filter(Marka == 'Volkswagen', stri_detect_fixed(Wyposazenie.dodatkowe, 'el. lusterka') == TRUE) %>%
  na.omit() %>% 
  summarise(q1 = quantile(Pojemnosc.skokowa, probs = 0.25), q3 = quantile(Pojemnosc.skokowa, probs = 0.75))

auta2012 %>% 
  filter(Marka == 'Volkswagen', stri_detect_fixed(Wyposazenie.dodatkowe, 'el. lusterka') == FALSE) %>%
  na.omit() %>% 
  summarise(q1 = quantile(Pojemnosc.skokowa, probs = 0.25), q3 = quantile(Pojemnosc.skokowa, probs = 0.75))  


# Odp: Dla samochod�w z el. lusterkami: kwartyl 0.25: 1896, kwartyl 0.75: 1968, bez el. lusterek:
#      kwartyl 0.25: 1391, kwartyl 0.75: 1900.
