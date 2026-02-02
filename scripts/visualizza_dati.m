
function visualizza_dati(U, t, A, A_rec, options)

    arguments
        U
        t
        A
        A_rec
        options.velocita_animazione (1,1) double = 0.005
        options.esperimento (1,1) double = NaN
    end

    % Gestione del default dinamico per n_esperimenti
    if isnan(options.esperimento)
        options.esperimento = 1:length(U(1,:));
    end
    
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
    
    %% Animazione (Ciclo sui passi temporali)
    % Eseguiamo l'animazione su entrambi contemporaneamente
    while true
        for esperimento = options.esperimento
            for k = 1:length(U)
                % Estraiamo le temperature al tempo k per l'esperimento scelto
                temp_k = U{k}(:, esperimento); 
                
                % Aggiorniamo i colori dei nodi in entrambi i grafici
                h1.NodeCData = temp_k;
                h2.NodeCData = temp_k;
                
                % Aggiorniamo il titolo con il tempo corrente
                sgtitle(sprintf('Evoluzione Temporale - t = %.2f, esperimento = %d', t(k), esperimento));
                
                drawnow; % Forza il disegno a video
                pause(options.velocita_animazione); % Piccola pausa per l'effetto animazione
            end
        end
    end

end