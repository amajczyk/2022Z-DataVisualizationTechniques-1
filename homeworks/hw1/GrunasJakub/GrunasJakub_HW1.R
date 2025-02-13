library(PogromcyDanych)
library(dplyr)
library(tidyr)
library(stringr)


colnames(auta2012)
dim(auta2012)
head(auta2012[,-ncol(auta2012)])
sum(is.na(auta2012))

## 1. Z kt�rego rocznika jest najwi�cej aut i ile ich jest?

auta2012 %>%
  group_by(Rok.produkcji) %>%
  summarise(n = n()) %>%
  arrange(-n)

## Odp: 2011, 17418


## 2. Kt�ra marka samochodu wyst�puje najcz�ciej w�r�d aut wyprodukowanych w 2011 roku?

auta2012 %>%
  filter(Rok.produkcji == 2011) %>%
  group_by(Marka) %>%
  summarise(n = n()) %>%
  arrange(-n)

## Odp: Skoda


## 3. Ile jest aut z silnikiem diesla wyprodukowanych w latach 2005-2011?

auta2012 %>%
  filter(Rok.produkcji >= 2005 & Rok.produkcji <= 2011, Rodzaj.paliwa == 'olej napedowy (diesel)') %>%
  dim()

## Odp: 59534


## 4. Spo�r�d aut z silnikiem diesla wyprodukowanych w 2011 roku, kt�ra marka jest �rednio najdro�sza?

auta2012 %>%
  filter(Rok.produkcji == 2011, Rodzaj.paliwa == 'olej napedowy (diesel)') %>%
  group_by(Marka) %>%
  summarise(srednia_cena = mean(Cena.w.PLN)) %>%
  arrange(-srednia_cena)

## Odp: Porsche


## 5. Spo�r�d aut marki Skoda wyprodukowanych w 2011 roku, kt�ry model jest �rednio najta�szy?

auta2012 %>%
  filter(Rok.produkcji == 2011, Marka == 'Skoda') %>%
  group_by(Model) %>%
  summarise(srednia_cena = mean(Cena.w.PLN)) %>%
  arrange(srednia_cena)

## Odp: Fabia


## 6. Kt�ra skrzynia bieg�w wyst�puje najcz�ciej w�r�d 2/3-drzwiowych aut,
##    kt�rych stosunek ceny w PLN do KM wynosi ponad 600?

auta2012 %>%
  mutate(Cena_a_KM = Cena.w.PLN/Przebieg.w.km) %>%
  filter(Liczba.drzwi == '2/3', Cena_a_KM > 600) %>%
  group_by(Skrzynia.biegow) %>% 
  summarise(n = n()) %>%
  arrange(-n)

## Odp: automatyczna


## 7. Spo�r�d aut marki Skoda, kt�ry model ma najmniejsz� r�nic� �rednich cen 
##    mi�dzy samochodami z silnikiem benzynowym, a diesel?

auta2012 %>%
  filter(Marka == 'Skoda', Rodzaj.paliwa == 'benzyna' | Rodzaj.paliwa == 'olej napedowy (diesel)') %>%
  group_by(Model, Rodzaj.paliwa) %>%
  summarise(Srednia_cena = mean(Cena.w.PLN)) %>%
  group_by(Model) %>%
  summarise(Roznica_cen = abs(diff(Srednia_cena))) %>%
  arrange(Roznica_cen)

## Odp: Felicia


## 8. Znajd� najrzadziej i najcz�ciej wyst�puj�ce wyposa�enie/a dodatkowe 
##    samochod�w marki Lamborghini

auta2012 %>% 
  filter(Marka == 'Lamborghini')%>%
  select(Wyposazenie.dodatkowe) %>%
  mutate(Wyposazenie.dodatkowe = str_split(Wyposazenie.dodatkowe, ',')) %>%
  unnest(Wyposazenie.dodatkowe) %>%
  group_by(Wyposazenie.dodatkowe) %>%
  summarise(n = n()) %>%
  arrange(n)

## Odp: Najrzadziej: blokada skrzyni biegow, klatka; Najczesciej: alufelgi, wspomaganie kierownicy, ABS


## 9. Por�wnaj �redni� i median� mocy KM mi�dzy grupami modeli A, S i RS 
##    samochod�w marki Audi

# Zakladamy, ze samochody Audi TT RS oraz Audi TT S nie naleza do grupy modeli odpowiednio RS i S
auta2012 %>%
  filter(Marka == 'Audi', str_detect(Model, regex('A.')) == TRUE | 
         str_detect(Model, regex('S.')) == TRUE | str_detect(Model, regex('RS.')) == TRUE) %>%
  mutate(Model = str_replace(Model, regex('A.*'), 'A')) %>%
  mutate(Model = str_replace(Model, regex('S.'), 'S')) %>%
  mutate(Model = str_replace(Model, regex('RS.'), 'RS')) %>%
  group_by(Model) %>%
  summarise(srednia = mean(na.omit(kW)), mediana = median(na.omit(kW)))

## Odp: Grupa A: srednia = 117, mediana = 103
##      Grupa RS: srednia = 368, mediana = 331
##      Grupa S: srednia = 253, mediana = 253


## 10. Znajd� marki, kt�rych auta wyst�puj� w danych ponad 10000 razy.
##     Podaj najpopularniejszy kolor najpopularniejszego modelu dla ka�dej z tych marek.

#Najpopularniejsze marki (>10000 razy)
auta2012 %>%
  group_by(Marka) %>%
  summarise(n = n()) %>%
  filter(n>10000)

#Najpopularniejsze modele sposrod znalezionych marek
auta2012 %>%
  filter(Marka == 'Audi' | Marka == 'BMW' | Marka == 'Ford' | 
         Marka == 'Mercedes-Benz' | Marka == 'Opel' | Marka == 'Renault' | Marka == 'Volkswagen') %>%
  group_by(Marka, Model) %>% 
  summarise(n = n()) %>%
  arrange(-n) %>%
  slice_head()

#Najpopularniejsze kolory najpopularniejszych modeli
auta2012 %>%
  filter((Marka == 'Audi' & Model == 'A4') | (Marka == 'BMW' & Model == '320') | (Marka == 'Ford' & Model == 'Focus') | 
           (Marka == 'Mercedes-Benz' & Model == 'C 220') | (Marka == 'Opel' & Model == 'Astra') | 
           (Marka == 'Renault' & Model == 'Megane') | (Marka == 'Volkswagen' & Model == 'Passat')) %>%
  group_by(Marka, Model, Kolor) %>%
  summarise(n = n()) %>%
  arrange(-n) %>%
  slice_head()

## Odp: czarny-metallic: Audi A4;
##      srebrny-metallic: BMW 320, Ford Focus, Mercedes-Benz C 220, Opel Astra, Renault Megane, Volkswagen Passat