%% 1. Parametri del Problema
m = 10;          % Numero di nodi (vertici)
M = 60;          % Numero di esperimenti (M >= m per il Problema 1)
T = 0.1;         % Tempo finale di osservazione (piccolo per l'euristica)
nt = 50;         % Numero di istanti temporali
t = linspace(0, T, nt); % Vettore dei tempi

%% 2. Generazione del Grafo e del Laplaciano
% Creiamo un grafo casuale: matrice fatta da 0 e 1 disposti casualmente ma da ottenere matrice simmetrica
prob_edge = 0.1; 
A = double(rand(m,m) < prob_edge);
A = triu(A,1); 
A = A + A'; % Rendiamo la matrice simmetrica (grafo non orientato)

% Visualizzazione opzionale del grafo originale
% figure; plot(graph(A)); title('Grafo Originale');

% Calcolo della matrice Laplaciana L = D - A
L = laplacian(graph(A));

% Diagonalizzazione di L: L = P * Lambda * P'
[P, Lambda] = eig(full(L)); 
% Lambda è una matrice diagonale con gli autovalori lambda_i

%% 3. Generazione dei Dati Iniziali (U{1})
% U{1} è una matrice m x M dove ogni colonna è un dato iniziale random (ogni nodo inizia con una temperatura random)
U = cell(1, nt);
U{1} = randn(m, M); 

%% 4. Simulazione della Diffusione (Riempimento della cella U)
% Usiamo la formula: u(t) = P * exp(-Lambda * t) * P' * u(0)
% Calcoliamo l'evoluzione per ogni istante temporale k

for k = 2:nt
    tk = t(k);
    
    % Calcoliamo la matrice esponenziale e^(-Lambda * tk)
    % Poiché Lambda è diagonale, basta elevare l'esponenziale degli elementi sulla diagonale
    exp_Lambda_tk = diag(exp(-diag(Lambda) * tk));
    
    % Calcoliamo la matrice di trasferimento: H(t) = P * exp(-Lambda*t) * P'
    H_tk = P * exp_Lambda_tk * P';
    
    % Calcoliamo lo snapshot al tempo k per tutti gli M esperimenti
    U{k} = H_tk * U{1};
    
    % (Opzionale) Aggiunta di rumore bianco per testare la robustezza
    % rumore = 1e-4 * randn(m, M);
    % U{k} = U{k} + rumore;
end

%% 5. Salvataggio dei Dati
% Questi sono i file che useranno Solutore1 e Solutore2
save('dati_sintetici.mat', 'A', 't', 'U', 'm', 'M');
fprintf('Dati sintetici generati e salvati correttamente.\n');