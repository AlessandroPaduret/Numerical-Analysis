function visualizza_dati(U, t, A, A_rec, options)
    arguments
        U, t, A, A_rec
        options.velocita (1,1) double = 0.05 % Velocità di animazione
    end

    %% Setup dati
    [n_nodi, ~] = size(U{1}); % Prendiamo il numero dei nodi tramite il numero di righe della prima matrice della cell U
    c_mat = pinv(U{1}, 1e-5); % Matrice per i Ping
    x_coords = []; % Placeholder per coordinate x
    y_coords = []; % Placeholder per coordinate y
    CLIM_RANGE = [-0.1, 0.8]; % Scala colori fissa: da rosso scuro (caldo) a blu scuro (freddo)

    %% Setup finestra
    figure('Color', 'w', 'Position', [100, 100, 1200, 500]); % Colore sfondo (bianco), posizione e grandezza della finestra 
    colormap jet; % Abbiamo usato la mappa di colori "jet" perchè ci sembrava la più opportuna

    % Grafo nella zona di sinistra = grafo costruito inizialmente
    subplot(1,2,1); % Creiamo ed interveniamo sul subplot a sinistra
    % Mostra a video il grafo basato sulla matrice di adiacenza A
    % Archi attirano i nodi connessi, che si respingono così da creare spazio
    % Colore iniziale dei pallini: blu
    % Diametro dei pallini: 7 punti
    h1 = plot(graph(A), 'Layout', 'force', 'NodeColor', 'b', 'MarkerSize', 7); 
    x_coords = h1.XData; % "Congela" coordinate x per poter creare un grafico con nodi nella posizione uguale nella ricostruzione
    y_coords = h1.YData; % "Congela" coordinate y per poter creare un grafico con nodi nella posizione uguale nella ricostruzione
    title('GRAFO INIZIALE');
    axis off tight; % Nasconde gli assi cartesiani e stringe i margini
    colorbar; % Forziamo la visualizzazione della colorbar
    clim(CLIM_RANGE); % Impostiamo la scala di colori da usare nella colorbar

    % Grafo nella zona di destra = grafo ricostruito
    subplot(1,2,2); % Creiamo ed interveniamo sul subplot a destra
    % Mostra a video un grafo inizialmente senza archi (matrice di adiacenza di soli zeri)
    % Coordinate dei punti uguali a quelli del grafo già costruito
    % Colore iniziale dei pallini: blu
    % Diametro dei pallini: 7 punti
    h2 = plot(graph(zeros(n_nodi)), 'XData', x_coords, 'YData', y_coords, 'NodeColor', 'b', 'MarkerSize', 7);
    title('GRAFO IN RICOSTRUZIONE');
    axis off tight; % Nasconde gli assi cartesiani e stringe i margini
    colorbar; % Forziamo la visualizzazione della colorbar
    clim(CLIM_RANGE); % Impostiamo la scala di colori da usare nella colorbar

    fprintf('Avvio animazione...\n');

    %% Animazione
    while true
        % M_built = matrice che tiene in memoria gli archi ricostruiti
        M_built = zeros(n_nodi); % Qui viene resettata per il caso in cui l'animazione stia ripartendo da capo
        
        for node = 1:n_nodi
            % Calcola diffusione per il nodo corrente
            coeff = c_mat(:, node);
            vicini = find(A_rec(node, :)); % "find" restituisce un vettore contenente gli indici lineari di ciascun elemento diverso da zero
            
            for k = 1:length(U)
                % Calcola colore (temperatura) e vediamone gli effetti nei grafi
                temp = U{k} * coeff;
                h1.NodeCData = temp;
                h2.NodeCData = temp;
                
                % Aggiunta archi solo dal passo k=2, perchè è quando comincia effettivamente la diffusione
                if k == 2 && ~isempty(vicini)
                    % Aggiungiamo i vicini alla matrice d'appoggio e costruiamo un arco se non è già stato costruito
                    new_edges = false;
                    for v = vicini
                        if M_built(node, v) == 0
                            M_built(node, v) = 1;
                            M_built(v, node) = 1;
                            new_edges = true;
                        end
                    end
                    
                    % Se la matrice è cambiata, ridisegna il grafo e il subplot
                    if new_edges
                        subplot(1,2,2); % Interveniamo sul subplot a destra
                        h2 = plot(graph(M_built), 'XData', x_coords, 'YData', y_coords, 'NodeColor', 'b', 'MarkerSize', 7, 'LineWidth', 1.5);
                        h2.NodeCData = temp; % Riapplica subito il colore nel grafo
                        % Ripristina subito le proprietà del subplot
                        axis off tight;
                        colorbar;
                        clim(CLIM_RANGE); 
                        title(sprintf('GRAFO RICOSTRUITO'));
                    end
                end
                
                sgtitle(sprintf('RICOSTRUZIONE IN CORSO: ping nodo %d, t=%.3f', node, t(k)));
                drawnow; % Forza il ridisegno
                pause(options.velocita); % Pausa per notare i cambiamenti di calore
            end
        end

        sgtitle('Ricostruzione Completata! Riavvio...');
        pause(2); % Pausa fine animazione prima di ricominciare da capo
        
        % Reset visuale grafo destro per il prossimo giro, ovviamente "congelando" sempre le coordinate dei nodi
        subplot(1,2,2);
        h2 = plot(graph(zeros(n_nodi)), 'XData', x_coords, 'YData', y_coords, 'NodeColor', 'b', 'MarkerSize', 7);
        axis off tight;
        colorbar;
        clim(CLIM_RANGE);
    end
end