%% Script di Confronto Diffusione: Originale vs Ricostruito
load('dati_sintetici.mat'); % Carica A, t, U, m, M
% Assumiamo che A_rec sia già stata calcolata e salvata
load('A_rec.mat'); 

esperimento = 1;
% Creiamo i grafi
G_orig = graph(A);
G_rec = graph(A_rec);

% Prepariamo la figura con due pannelli (1 riga, 2 colonne)
figure('Color', 'w', 'Position', [100, 100, 1200, 500]);

% --- GRAFO ORIGINALE ---
subplot(1,2,1);
% Calcoliamo il layout una volta sola e lo salviamo
h1 = plot(G_orig, 'Layout', 'force');
% Salviamo le coordinate dei nodi per usarle nel secondo grafico
x_coords = h1.XData;
y_coords = h1.YData;

title('Grafo Originale (Verità)');
colorbar;
clim([min(U{1}(:)), max(U{1}(:))]);
axis tight; axis off;

% --- GRAFO RICOSTRUITO ---
subplot(1,2,2);
% Usiamo le STESSE coordinate (x_coords, y_coords)
h2 = plot(G_rec, 'XData', x_coords, 'YData', y_coords);

title('Grafo Ricostruito (A\_rec)');
colorbar;
clim([min(U{1}(:)), max(U{1}(:))]);
axis tight; axis off;

% Conta quanti archi hai azzeccato rispetto alla matrice A originale
errori = sum(sum(abs(A_rec - A))); 
accuratezza = 1 - (errori / numel(A));
fprintf('Accuratezza della ricostruzione: %.2f%%\n', accuratezza * 100);

%% Animazione (Ciclo sui passi temporali)
% Eseguiamo l'animazione su entrambi contemporaneamente
while true
for k = 1:length(U)
    % Estraiamo le temperature al tempo k per l'esperimento scelto
    temp_k = U{k}(:, esperimento); 
    
    % Aggiorniamo i colori dei nodi in entrambi i grafici
    h1.NodeCData = temp_k;
    h2.NodeCData = temp_k;
    
    % Aggiorniamo il titolo con il tempo corrente
    sgtitle(sprintf('Evoluzione Temporale - t = %.2f', t(k)));
    
    drawnow; % Forza il disegno a video
    pause(0.05); % Piccola pausa per l'effetto animazione
end
end