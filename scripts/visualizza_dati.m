%% Script di Animazione della Diffusione
load('dati_sintetici.mat'); % Carica A, t, U, m, M

% Scegliamo un esperimento specifico da visualizzare (es. il primo)
esperimento = 1;

% Creiamo l'oggetto grafo di Matlab
G = graph(A);

% Prepariamo la figura
figure('Color', 'w');
h = plot(G, 'Layout', 'force'); % Layout 'force' mantiene i nodi in posizioni fisse
title(sprintf('Diffusione del Calore - Esperimento %d', esperimento));
colorbar; % Mostra la scala del calore
axis off;

% Determiniamo i limiti dei colori per mantenere la scala costante
tutti_i_valori = cell2mat(U); 
c_min = min(tutti_i_valori(:));
c_max = max(tutti_i_valori(:));
clim([c_min, c_max]);

% Ciclo per l'animazione
while true
    for k = 1:length(t)
        % Estraiamo i valori di calore per tutti i nodi al tempo k
        calore_nodi = U{k}(:, esperimento);
        
        % Aggiorniamo i colori dei nodi nel grafico
        h.NodeCData = calore_nodi;
        
        % Aggiorniamo il titolo con il tempo corrente
        title(sprintf('Diffusione al tempo t = %.3f', t(k)));
        
        % Pausa per rendere l'animazione fluida
        pause(0.1); 
    end
end