% Zeglarz plynie lodka od startu do mety uczac sie omijac przeszkody oraz
% zdobywac nagrody. 
% Z kazdego pola akwenu mozna dostac sie do jednego z
% czterech pol sasiednich (lewo prawo,gora,dol) wykonujac analogiczna do
% tego celu akcje, z tym ze z powodu przypadkowych podmuchow wiatru przejscie 
% do wybranego stanu nastepuje z pewnym prawdopodobienstwem < 1. Z niezerowym
% prawdopodobienstwem mozna zas poplynac w bok lub do tylu.
clear

liczba_epizodow = 2000                   % liczba epizodow uczenia 
max_liczba_krokow = 25                     % maksymalna liczba krokow w epizodzie
alfa = 0.5                             % szybkosc uczenia
gamma = 0.8                              % wspolczynnik dyskontowania
epsylon = 0.9                            % wspolczynnik eksploracji podczas uczenia

mozliwe_akcje = [1 2 3 4 1 2 3 4]; % z pliku srodowisko
load tablica_nagrod;


Q = zeros( [size(tablica_nagrod) 4]);     % tablica uzytecznosci par <stan,akcja>

for epizod=1:liczba_epizodow 
   stan = [ceil(rand*length(tablica_nagrod(:,1))) 1]; % losowe pole z pierwszej kolumny
   
   koniec = 0;
   nr_pos = 0;
   tablica_nag = tablica_nagrod;
   suma_nagr(epizod) = 0;
   while (koniec == 0)
      nr_pos = nr_pos + 1;                            % numer posuniecia
      
      % Wybor akcji: 
      if(rand(1) >= 1-epsylon)
        [~,maxAction] = max(Q(stan(1),stan(2),:)); %index maxa
        akcja = mozliwe_akcje(maxAction);
      else
        akcja = mozliwe_akcje(randi([1 8],1,1)); %losowanie pomiedzy mozliwymi akcjami  
      end    
         
      [stan_nast, nagroda,tablica_nag] = srodowisko(stan, akcja, tablica_nag); 
   
      % Modyfikacja uzytecznosci stanu:
      Q(stan(1),stan(2),akcja) =   Q(stan(1),stan(2),akcja) + alfa * (nagroda + gamma
      * max(Q(stan_nast(1),stan_nast(2),:)) - Q(stan(1),stan(2),akcja));
 
      stan = stan_nast;      % przejscie do nastepnego stanu
      
      % Koniec epizodu jesli uzyskano maksymalna liczbe krokow lub
      % dojechano do mety
      if (nr_pos == max_liczba_krokow || stan(2) == length(tablica_nagrod(1,:)))
         koniec = 1;                                  
      end
      suma_nagr(epizod) = suma_nagr(epizod) + nagroda;
      
   end % while
   if mod(epizod,1000)==0
       sprintf('epizod = %d srednia suma nagrod = %f',epizod,mean(suma_nagr))
   end
end
sprintf('srednia suma nagrod = %f',mean(suma_nagr))
save Q Q
rysuj_akwen(tablica_nagrod,Q);
tablica_nagrod